# Houseslice — Final Project Report (Technical Sections)

**Group 22 — African Leadership University**
Aime Ndayambaje · Isimbi Nelly · Gift · Nkuba Junior · David Muotoh

> **How to use this file.** Your research sections (literature review, problem
> statement, personas, empathy maps, competitor analysis, journey map,
> storyboard, reflection, references) are already written. This document
> supplies the *technical* half the rubric asks for. Paste both halves into one
> document, apply Times New Roman 12pt body / 14pt headings, and export as
> `Group22_Final_Project_Submission.pdf`.
>
> Placeholders marked **[SCREENSHOT]** need images captured from the running
> app — see "Screenshots to capture" at the end.

---

## 1. Repository and Access

- **GitHub:** https://github.com/davidmuo/houslice
- **Firebase project:** `houseslice-69a7f`
- **Android package:** `com.group22.houslice`

The repository is public. All five group members are collaborators, and the
commit history shows per-feature branches merged into `main`.

---

## 2. Setup Instructions

### Prerequisites

| Tool | Version used |
|---|---|
| Flutter SDK | 3.44.1 (stable) |
| Dart SDK | ^3.12.1 |
| Android SDK | 36.1.0 |
| Minimum Android | API 23 (required by `firebase_auth`) |

### Running the app

```sh
git clone https://github.com/davidmuo/houslice.git
cd houslice
flutter pub get
flutter run          # debug
flutter build apk --release   # release APK for the demo
```

The project ships with `lib/firebase_options.dart` already generated for
`houseslice-69a7f`, so it connects to the live backend on first run. Firebase
client keys are public identifiers, not secrets — access is controlled by the
Firestore security rules in section 5, not by hiding the key.

### Connecting a different Firebase project

```sh
dart pub global activate flutterfire_cli
flutterfire configure --project=<your-project-id> --platforms=android,ios
firebase deploy --only firestore:rules,firestore:indexes
```

Then enable **Authentication → Email/Password** and **Google**, and register
your debug SHA-1 (`keytool -list -v -keystore ~/.android/debug.keystore
-alias androiddebugkey -storepass android`) against the Android app.

### Demo mode

If `firebase_options.dart` is a placeholder, `main.dart` catches the
initialisation failure and the dependency container registers in-memory data
sources instead. The app remains fully navigable without any backend — useful
for UI work and for the widget test suite.

---

## 3. Architecture

Houseslice follows **Clean Architecture** with **BLoC** for state management.
There is no `setState` anywhere in the codebase; `StatefulWidget` appears only
to own controller lifecycles (text fields, page views, animation controllers).

```
lib/
├── main.dart                 # Firebase bootstrap, preference preload
├── app.dart                  # MaterialApp + global bloc providers
├── injection_container.dart  # get_it dependency graph
├── core/                     # theme, errors, Result type, use case base,
│                             # validators, formatters, shared widgets, router
└── features/
    ├── auth/          # email/password + Google, reset, verification
    ├── lifestyle/     # questionnaire, compatibility scoring
    ├── onboarding/    # splash, intro slides, location picker
    ├── property/      # listings, search, favourites, create listing
    ├── booking/       # checkout, calendar, payment, my bookings
    ├── settings/      # persisted user preferences
    ├── notifications/
    ├── profile/
    └── shell/         # bottom-nav main shell
```

Every feature follows the same dependency rule:
**presentation → domain ← data**. The domain layer imports nothing from
Flutter or Firebase. Use cases return a `Result<T>` (`Success` / `Err(Failure)`)
so blocs never see exceptions or data-layer types.

### State management

| Concern | Solution |
|---|---|
| Auth session, sign in/up/out, Google, profile, verification | `AuthBloc` |
| Password reset flow | `PasswordResetCubit` |
| Listings + favourites | `PropertyBloc` (optimistic favourite toggle) |
| Publishing a listing | `CreateListingCubit` |
| Search results + recents | `SearchCubit` |
| Bookings (load/create/cancel) | `BookingBloc` |
| Checkout form (dates, payment method) | `BookingFormCubit` |
| Lifestyle answers (app-wide) | `LifestyleCubit` |
| Questionnaire progress | `QuizCubit` |
| User preferences | `PreferencesCubit` |
| Small UI state (tabs, toggles, gallery index) | `ToggleCubit` / `IndexCubit` |

`LifestyleCubit` and `PreferencesCubit` are registered as **singletons** rather
than factories: the theme and the compatibility baseline must be identical
everywhere in the app, so every screen scores against the same answers.

---

## 4. Database Design

The full entity–relationship diagram, field-by-field tables, and the rationale
for every relationship are in [`docs/ERD.md`](ERD.md). Summary:

| Path | Document id | Owner |
|---|---|---|
| `properties/{propertyId}` | slug or auto-id | publisher (`ownerUid`) |
| `users/{uid}` | Firebase Auth uid | that user |
| `users/{uid}/favorites/{propertyId}` | the listing id | that user |
| `users/{uid}/bookings/{bookingId}` | auto-id | that user |

Per-user data is nested **under** `users/{uid}` rather than kept in top-level
collections with a `userId` field. Ownership therefore becomes a property of
the document path, so a single rule (`request.auth.uid == uid`) secures every
subcollection, and cross-user queries are impossible by construction.

**On denormalisation.** Bookings store `propertyName`, `propertyAddress`,
`propertyImage`, and `monthlyPrice` alongside `propertyId`. This is a deliberate
snapshot, not accidental duplication: a booking is a financial record, and if a
host later edits their listing's price, past bookings must still show what was
actually agreed. Everything else is stored exactly once.

**Indexes.** `firestore.indexes.json` declares composite indexes for filtering
bookings by `status` while ordering by `startDate` — the query behind the
Upcoming / Completed / Cancelled tabs. Single-field indexes are omitted because
Firestore maintains them automatically and rejects them at deploy time.

---

## 5. Firebase Security Rules

Full rules: [`firestore.rules`](../firestore.rules). They are deployed and live.

| Path | Read | Write |
|---|---|---|
| `properties/{id}` | any signed-in user | create only as yourself (`ownerUid == auth.uid`); edit/delete only your own; `ownerUid` immutable |
| `users/{uid}` | owner only | owner only; `email` immutable after creation; `username` ≥ 3 chars |
| `users/{uid}/favorites/{id}` | owner only | owner only; body must be exactly `{savedAt}` |
| `users/{uid}/bookings/{id}` | owner only | owner only; on update **only `status` may change** |
| anything else | denied | denied |

Four properties are worth calling out, because each protects against a specific
attack rather than being generic boilerplate:

1. **Nothing is readable while signed out.** There is no public path. A
   catch-all `match /{document=**} { allow read, write: if false; }` closes
   anything not explicitly matched.

2. **Booking money is immutable.** The update rule uses
   `request.resource.data.diff(resource.data).affectedKeys().hasOnly(['status'])`,
   so a client can move a booking through its status lifecycle but cannot
   rewrite `monthlyPrice` or the dates on a stay that has already been agreed.

3. **Listings cannot be hijacked.** Creation requires
   `ownerUid == request.auth.uid`, and updates additionally require the
   incoming `ownerUid` to equal the stored one. A student can neither publish
   on someone else's behalf nor claim an existing listing.

4. **Verification status is not client-writable.** `emailVerified` is read from
   Firebase Auth and deliberately never persisted to the user document, so it
   cannot be spoofed by writing to Firestore.

---

## 6. Authentication

Two working methods, as required.

**Email / password.** Registration is gated to university domains
(`alustudent.com`, `alueducation.com`, `ur.ac.rw`, `auca.ac.rw` — see
`lib/core/utils/validators.dart`). A verification link is sent immediately on
sign-up, and the profile screen shows a persistent prompt with a resend button
until the address is confirmed.

**Google Sign-In.** Uses `google_sign_in` 7.x with the project's web OAuth
client as `serverClientId`. Critically, **the same university-domain rule is
enforced on Google accounts**: the email is checked before any Firebase session
is created, and the Google session is signed out again if it fails. Without
this, anyone with a personal Gmail could bypass the entire student-verification
premise the product rests on.

**Password reset** uses `sendPasswordResetEmail`. Requests for unknown
addresses succeed silently so the endpoint cannot be used to discover which
emails are registered.

**Session persistence.** Firebase Auth restores the session across restarts;
the splash screen dispatches `AuthCheckRequested` and routes to the main shell
or to sign-in accordingly.

**Error handling.** `FirebaseAuthException` codes are mapped to plain-language
messages in one place (`_friendlyMessage`), covering wrong credentials,
duplicate email, weak password, network failure, stale login, and rate
limiting.

---

## 7. Implemented Functionality

### Onboarding
Branded splash, three intro slides, and a location step. Whether the intro is
shown is a persisted preference, so returning users skip straight to sign-in.

### Lifestyle questionnaire and compatibility matching
The distinguishing feature, built directly from the user research: interviews
identified compatibility — not price — as the strongest predictor of housemate
satisfaction.

Eleven questions plus a free-text introduction: gender and gender preference,
budget band, bedtime, cleanliness, social life, overnight guests, study
environment, smoking, sharing habits, and pets.

Scoring is a weighted model over nine dimensions, with cleanliness (18%) and
social style (16%) weighted highest because interviews named them the most
common causes of conflict. Three rules are not plain arithmetic:

- **Smoking** — a smoker paired with someone who wants a smoke-free home scores
  zero on that dimension regardless of how close the answers are.
- **Pets** — an allergy against a pet owner scores zero.
- **Gender** — a same-gender-only requirement is a hard block; the match is
  reported as unavailable with a reason rather than merely scored low. If
  either student declined to state a gender the rule cannot be checked, so the
  match is allowed through rather than silently hidden.

Every listing shows a live percentage, and a **"Why?"** button opens a
breakdown listing all nine dimensions ranked by agreement, each with a bar and
a sentence naming both students' answers.

Compatibility is shown **only for shared-home listings**. An entire empty
property has no housemate to be compatible with, so the banner is hidden.

### Listings
Compatibility-ranked home feed, grid browsing, live search with recents and an
empty state, photo gallery with thumbnails, verified host card, and a share
sheet. Each card carries a **badge showing whether the listing came from a
fellow student or a letting agent** — the single most requested signal in
interviews, where students said they could not tell peers from agents on
Facebook.

### Publishing and managing a listing
Students can sublet a room and agents can post a whole property. Selecting
"Realtor" automatically forces "Entire place" and disables the housemate
option, since an agency has no lifestyle profile to match against. A student
listing a room has their questionnaire answers attached automatically.

**My Listings** (Profile → My Listings) completes the CRUD surface: it shows
everything the signed-in student has published and offers **Edit** and
**Delete** on each. Editing reuses the publish form rather than duplicating it,
opening on the listing's current values; the rating and baseline compatibility
the listing has already earned are preserved rather than reset. Deleting asks
for confirmation, removes the row optimistically, and restores it with an error
message if the write is rejected.

Which listings appear is decided by `ownerUid` — the same field
`firestore.rules` checks — so the actions the UI offers and the writes the
backend permits cannot drift apart. A student never sees an Edit button for a
listing the rules would refuse to let them edit.

### Booking
Custom range calendar, payment method selection (card / mobile money), an Add
Card screen with Luhn checksum and expiry validation, price breakdown with tax,
and a success sheet. **No card data is stored or transmitted** — the app has no
PCI-compliant processor, so only the last four digits are retained to label the
chosen method.

### Favourites, bookings, notifications, settings
Per-user favourites synced to Firestore with an optimistic heart toggle;
Upcoming / Completed / Cancelled booking tabs with review and call-agent
actions; a notification feed; and a settings screen exposing four persisted
preferences (theme, notification opt-in, preferred district, onboarding replay).

---

## 8. Testing

```sh
flutter analyze lib test   # 0 issues
flutter test               # 265 tests, all passing
flutter test --coverage    # 72.3% line coverage (3,477 / 4,806)
```

The suite covers validators, formatters, entities, models, data sources,
repositories, blocs and cubits, and every screen — including the modal sheets.

Widget tests run against the **real dependency graph in demo mode** rather than
mocked blocs, so a single screen test exercises presentation, domain, and data
together. `test/features/responsive_layout_test.dart` additionally pumps every
argument-free screen at three viewports — 320×568 (smallest supported), 430×932
(the design reference), and 932×430 (landscape rotation) — and fails on any
`RenderFlex` overflow. Screens that need route arguments get the same treatment
inside their own feature tests.

That approach paid for itself: the widget tests exposed **ten real layout
overflow bugs** that had shipped unnoticed — in the explore search bar, listing
cards, property facilities, booking tiles, the registration consent line, the
booking price row, the select-date sheet, the My Bookings segments, and finally
the location chooser (134 px in landscape) and the create-new-password form
(34 px). All are fixed; the responsive suite is what keeps them fixed.

**[SCREENSHOT]** — terminal output of `flutter analyze` showing 0 issues
**[SCREENSHOT]** — terminal output of `flutter test` showing all tests passing
**[SCREENSHOT]** — coverage percentage

---

## 9. Known Limitations and Future Work

Being explicit about what is not finished is more useful than implying the
product is complete.

**Listing photos are embedded in Firestore, not held in Cloud Storage.**
Choosing photos from the device gallery *is* implemented — `PhotoService` opens
the picker, caps images at 900px, and re-encodes them at quality 60. Where they
land is the compromise: Cloud Storage requires the Blaze billing plan, which
this project is not on, so `InlinePhotoService` stores each photo as a
compressed data URI on the listing document itself, refusing anything over
180 KB to stay clear of Firestore's ~1 MiB document ceiling. A production build
would swap in `FirebasePhotoService` — already written and interface-compatible
— and keep only the download URL on the document.

**Payments are not processed.** The Add Card screen validates input and renders
a preview, but nothing is charged and no card data leaves the device. A real
implementation would integrate a PCI-compliant processor and MTN MoMo's API,
which is the natural next step for Kigali.

**The location step is a searchable neighbourhood list, not a map.** Rendering
tiles requires the Google Maps SDK and a billable API key. The list covers the
Kigali neighbourhoods students actually named in interviews and feeds the
preferred-district preference.

**Catalogue seeding requires an administrator.** Because `properties` only
accepts listings owned by the caller, the demo catalogue cannot self-seed from
the client. Listings created in-app work normally; a starter catalogue must be
imported by an admin or created through the app.

**In-app messaging is not built.** The research identified secure messaging as
a key trust feature — students currently share phone numbers publicly in
Facebook groups. This is the highest-value next feature.

**Facebook sign-in is decorative.** Two authentication methods are implemented
and working; the Facebook button states plainly that it is unavailable rather
than pretending otherwise.

**Neighbourhood guides are not implemented.** Identified in research as a gap
no competitor fills; deferred to a future milestone.

### Roadmap

1. In-app messaging between verified students
2. Real payment capture (card + MTN MoMo)
3. Photo upload via Firebase Storage
4. Student-written neighbourhood guides
5. Map view with real tiles
6. Expansion beyond Kigali to other African university cities

---

## 10. Screenshots to capture

Capture on a physical device, in release build:

1. Splash and the three onboarding slides
2. Register, with the university-email validation error visible
3. Sign in, including the Google button
4. The lifestyle questionnaire — a scale question and the free-text step
5. Home feed showing compatibility percentages and student/realtor badges
6. A listing's detail screen with the Lifestyle match banner
7. **The "Why?" compatibility breakdown sheet** — the distinguishing feature
8. Explore grid and search with results
9. Create listing, showing Realtor forcing "Entire place"
10. Booking: date calendar, payment selection, Add Card, price breakdown, success
11. My Bookings across all three tabs, including an empty state
12. Profile, Edit Profile, and Settings in **both light and dark theme**
13. The Firebase Console showing a document written by the app
14. `flutter analyze` and `flutter test` terminal output
