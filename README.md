# Houseslice (HOUSLICE)

A verified, student-only housing marketplace for Kigali — find compatible
housemates, book rooms and short-term sublets, all inside a trusted student
community. Built by **Group 22** (African Leadership University) as the
Flutter + Firebase implementation of our Figma prototype.

## Features

- **Onboarding** — branded splash, three intro slides, location chooser.
- **Verified student auth** — registration is gated to university email
  domains (`alustudent.com`, `ur.ac.rw`, `auca.ac.rw`, ... — see
  `lib/core/utils/validators.dart`), backed by Firebase Authentication.
- **Compatibility home feed** — listings ranked by lifestyle compatibility
  score, matching the Figma "Compatibility" screen.
- **Explore + Search** — grid browsing, live search with Recent /
  Result sections and a "Search not found" empty state.
- **Listing details** — photo gallery with thumbnails, about section,
  verified host card, share sheet.
- **Favorites** — per-user, synced to Firestore, optimistic heart toggle.
- **Booking flow** — custom range calendar ("Select Date" sheet), payment
  method selection (card / MoMo), price breakdown with tax, "Confirm and
  Pay", success sheet.
- **My Booking** — Upcoming / Completed / Cancelled tabs with status chips,
  write-review sheet and call-agent action, playful "Opps!!" empty states.
- **Notifications**, **Profile** (change password, about, sign out).

## Architecture

Clean Architecture with **BLoC** (`flutter_bloc`) — no `setState` anywhere;
`StatefulWidget` appears only to own controller lifecycles (text fields,
page views).

```
lib/
├── main.dart                 # Firebase bootstrap (falls back to demo mode)
├── app.dart                  # MaterialApp + global bloc providers
├── injection_container.dart  # get_it dependency injection
├── firebase_options.dart     # PLACEHOLDER — run `flutterfire configure`
├── core/                     # theme, errors, Result type, use case base,
│                             # validators, formatters, shared widgets, router
└── features/
    ├── auth/
    │   ├── data/         # models, Firebase + mock data sources, repo impl
    │   ├── domain/       # entities, repository contracts, use cases
    │   └── presentation/ # AuthBloc, pages, widgets
    ├── onboarding/       # splash, slides, location (presentation only)
    ├── property/         # listings: home, explore, favorites, search, details
    ├── booking/          # checkout, calendar, my bookings
    ├── notifications/
    ├── profile/
    └── shell/            # bottom-nav main shell
```

Each feature follows the same dependency rule:
**presentation → domain ← data**. Use cases return a `Result<T>`
(`Success` / `Err(Failure)`), so blocs never see exceptions or
data-layer types.

### State management

| Concern | Solution |
|---|---|
| Auth session, sign in/up/out, password change | `AuthBloc` |
| Listings + favorites | `PropertyBloc` (optimistic favorite toggle) |
| Search results + recents | `SearchCubit` |
| Bookings (load/create/cancel) | `BookingBloc` |
| Checkout form (dates, payment method) | `BookingFormCubit` |
| Small UI state (tabs, toggles, gallery index) | `ToggleCubit` / `IndexCubit` |

## Getting started

```sh
flutter pub get
flutter run
```

That's it for a first run: without Firebase configured the app boots in
**demo mode** (in-memory data sources) so every flow is testable
immediately. Demo account: `j.simmons@alustudent.com` / `password123`,
or register a new account with any allowed university email.

### Connecting Firebase (production mode)

1. Create a Firebase project at <https://console.firebase.google.com>.
2. Enable **Authentication → Email/Password** and **Cloud Firestore**.
3. Run the FlutterFire CLI from the project root:

   ```sh
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

   This regenerates `lib/firebase_options.dart` with your project keys.
4. `flutter run` — `main.dart` detects the real config and switches the
   dependency container from mock to Firebase data sources automatically.

On first launch the app seeds the `properties` collection with the Kigali
catalogue. Per-user data lives at `users/{uid}` (profile),
`users/{uid}/favorites` and `users/{uid}/bookings`.

Suggested starter Firestore rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /properties/{id} {
      allow read: if request.auth != null;
      allow write: if request.auth != null; // tighten before production
    }
    match /users/{uid}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
  }
}
```

## Quality checks

```sh
flutter analyze   # 0 issues
flutter test      # widget smoke test: splash → onboarding
```

## Notes

- Android `minSdk` is 23 (required by `firebase_auth`).
- Listing photos are Unsplash URLs with offline placeholders, so the UI
  degrades gracefully without a network connection.
- Social sign-in buttons, vouchers and payment capture are visual-only in
  this milestone, as in the prototype.
