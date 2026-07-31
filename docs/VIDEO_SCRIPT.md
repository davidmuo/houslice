# Houseslice — Demo Video Script

**Group 22 · Five speakers · Order: David → Aime → Nelly → Gift → Nkuba**

This script contains **only what the rubric scores**. Nothing here is padding,
so nothing here is safe to cut. Read at whatever pace is natural: a brisk team
will land around 7 minutes, a measured one around 10, a slow one around 12. All
three are fine — the brief asks for 10 to 15 minutes and a slow read gets there
on its own.

**If your dry run finishes under 10:00**, use the add-back lines at the end of
this document. They are written out so nobody has to improvise on camera.

Each member presents the part of the application they built, so any question put
to a speaker is about their own code.

---

## Before you record

| Requirement | Detail |
|---|---|
| **Release APK on a physical Android phone** | Web, desktop or Chrome build scores **zero**. `flutter build apk --release`. |
| **One continuous take** | No cuts, no speed-ups, no transitions. |
| **No slide deck, no introductions** | Start on the app. |
| **≥ 1080p, clear audio** | Quiet room. No fans, no echo. |
| **Firebase Console legible during every CRUD step** | Second screen or split view. |
| **Every member speaks** | Five segments, five speakers. |
| **Rotate the device once** | Segment 3. |

### Setup — do all of this before recording

- [ ] Release APK installed
- [ ] **Signed in, questionnaire completed** — so Segment 1's cold start shows a
      persisted session
- [ ] **Two listings already published by your account** — so My Listings has
      something to edit and delete
- [ ] **In Settings, turn ON "Replay the intro slides"** — the onboarding screens
      only appear when signed out, so this is what makes them show for Aime after
      David signs out. Without it, that screen never appears in the video.
- [ ] Firebase Console open: **Firestore → Data** in one tab, **Authentication →
      Users** in another, both pre-scrolled
- [ ] Spare university email in a notes app, ready to paste
- [ ] University-domain Google account already on the phone
- [ ] Do Not Disturb on, **auto-rotate on**, battery above 50%
- [ ] One person drives the phone for the whole video; only the speaker changes
- [ ] **One full dry run**, timed

---

## Segment 1 — David Muotoh
### Cold start · listing create, update, delete · validation error

**Do:** Launch the app from the home screen (cold).

> "Houseslice — a student-only housing marketplace for Kigali, running as a
> release build on a physical phone. Cold launch, and it goes straight to the
> home feed: the session persisted across the restart."

**Do:** Open a listing. Tap **"Why?"**.

> "Every listing shows a match percentage, computed on the device from my
> lifestyle answers against the host's. This breaks that score down across nine
> dimensions and explains each one."

**Do:** Close the sheet. **Profile → My Listings → New listing.** Submit with a
required field left blank.

> *(pause)* "Validation stops it before anything reaches the network."

**Do:** Complete the form, attach a photo, publish. **Switch to the console.**

> *(pause)* "New document in `properties`. That's **create**."

**Do:** My Listings → **Edit** → change the price → Save. **Switch to the
console.**

> *(pause)* "Same document, new price. **Update**."

**Do:** **Delete** → confirm the dialog. **Switch to the console.**

> *(pause)* "Row gone instantly, and the document is gone. **Delete**. Which rows
> appear here is decided by `ownerUid` — the same field the security rules check
> — so the app can't offer an action the backend would refuse."

**Do:** Profile → **Sign Out**.

> "Signing out so Aime can register from scratch."

---

## Segment 2 — Aime Ndayambaje
### Onboarding · registration · validation error · both auth methods

**Do:** The intro slides appear. Page through them.

> "A signed-out user sees the intro slides. I'll register a new account."

**Do:** Register → enter `someone@gmail.com` and a password → submit.

> *(pause)* "Rejected. Houseslice only accepts approved university domains —
> that's enforced, not just stated."

**Do:** Register with a real university address.

**Do:** **Switch to console → Authentication → Users**, then **Firestore →
`users`**.

> *(pause)* "The account in Firebase Authentication, and a profile document
> written at `users/` and the new UID. A verification email has already gone out."

**Do:** Back on the phone — the questionnaire appears. Skip through it. Sign out.

**Do:** Tap **Google**. Complete sign-in with a **university** Google account.

> "Our second authentication method. The domain is checked before a Firebase
> session is created, so a personal Gmail would be rejected even though Google
> authenticated it. Nelly."

---

## Segment 3 — Isimbi Nelly
### State update across widgets · preference persistence across restart · rotation

**Do:** Profile → Lifestyle questionnaire. Answer three or four questions. Submit.

**Do:** Return to the home feed.

> *(pause)* "Every match percentage on the feed has changed — all recomputed from
> the answers I just gave. One state change, every card updates."

**Do:** Profile → Settings → switch the theme to **Dark**. Set the preferred
district.

> "Four preferences, all saved to the device."

**Do:** **Fully close the app** — swipe it from recents, don't just background
it. Relaunch.

> *(pause)* "Straight into dark mode with no flash of the light theme, because
> preferences load before the first frame is drawn. The district held, and I'm
> still signed in."

**Do:** Open Settings to show both values retained.

**Do:** **Rotate to landscape.** Scroll. Visit Notifications, Profile and Explore
while still rotated.

> "Landscape, no overflow on any screen. We assert every screen at three viewport
> sizes in the test suite."

**Do:** Rotate back to portrait.

> "Gift has browsing."

---

## Segment 4 — Gift Don-Emmanuel
### Explore and search · favourite create and delete

**Do:** Explore tab. Then Search — type a partial query, then a nonsense query.

> "Explore and search run off the same catalogue state. Live filtering, and an
> empty state rather than a blank screen."

**Do:** Return to Explore. Tap the heart on a listing. *(pause)* Switch to the
Favourites tab.

> "The heart filled instantly and it's in Favourites — one state change, two
> parts of the UI."

**Do:** **Switch to the console** — show the new favourites document.

> *(pause)* "The document ID is the listing ID, so favouriting twice is
> idempotent, and the body holds only a timestamp."

**Do:** Back on the phone, un-heart it. **Switch to the console.**

> *(pause)* "Gone from Favourites and deleted in Firestore. Nkuba has booking."

---

## Segment 5 — Nkuba Junior Igiraneza
### Booking create · payment validation error · cancellation update

**Do:** Open a listing → **Book** → select a start and end date.

> "Dates on a range calendar, then payment — card or mobile money."

**Do:** Add Card → enter an **invalid** card number.

> *(pause)* "Rejected by a Luhn checksum, the same algorithm real processors use."

**Do:** Enter a valid test number and expiry. Continue to the price breakdown.

> "Rent, tax and total. Nothing is charged and no card data leaves the device."

**Do:** Confirm. **Switch to the console.**

> *(pause)* "The booking document, written just now."

**Do:** My Bookings → cancel a booking. **Switch to the console.**

> *(pause)* "`status` flips to `cancelled`, and it's the only field that can
> change — the rules block any edit to the price or the dates of a booking that's
> already been agreed."

**Do:** Show the Cancelled tab.

> "So: two authentication methods, full create, read, update and delete against
> Firestore behind owner-scoped security rules, BLoC on a Clean Architecture
> codebase, preferences that survive a restart, and 298 passing tests at 74.5%
> coverage. Thanks for watching."

---

## Coverage check

Every scored item, and where it happens. If a take misses one, it must be redone.

| Rubric requirement | Segment |
|---|---|
| Cold-start launch | 1 |
| Auth state kept after restart | 1, 3 |
| Register → logout → login | 1 (logout), 2 |
| Both authentication flows | 2 |
| Visit every screen | 1–5 |
| Rotate the device once | 3 |
| **Create** in Firestore, console visible | 1 (listing), 2 (profile), 4 (favourite), 5 (booking) |
| **Read** from Firestore | 1, 3, 4 |
| **Update** in Firestore, console visible | 1 (listing price), 5 (booking status) |
| **Delete** in Firestore, console visible | 1 (listing), 4 (unfavourite) |
| State update touching two widgets | 3 (quiz → every card), 4 (heart → Favourites tab) |
| SharedPreferences change → restart → persisted | 3 |
| Validation error with a polite message | 1, 2, 5 |
| Every member speaks | 1–5 |
| No slide deck, no introductions | — |

---

## Add-backs — only if your dry run finishes under 10:00

Add these in order until you clear 10 minutes. Each is written out so nobody
improvises on camera. They add explanation, never new navigation, so they cannot
break the take.

**1. David, after the "Why?" sheet (~20 s)**
> "The scorer is a plain Dart class in the domain layer — it doesn't import
> Flutter or Firebase, which is why we can unit-test the matching logic directly
> without a widget tree or an emulator."

**2. David, at the badges on the home feed (~15 s)**
> "Every card also carries a Student or Realtor badge. On Facebook you can't tell
> a fellow student from a letting agent; here you always can. It was the signal
> students asked for most."

**3. Aime, at the `users` document in the console (~20 s)**
> "Note what isn't in this document — there's no `emailVerified` field.
> Verification status is read from the Firebase Auth token every time, never
> stored, so writing to your own profile can't manufacture a verified badge."

**4. Aime, after the blank-field rejection (~15 s)**
> "Username has to be at least three characters and the password at least six,
> and nothing reaches the network until every field passes."

**5. Nelly, after the scores recompute (~20 s)**
> "They all read from a single `LifestyleCubit` instance, registered as a
> singleton precisely so two screens can never disagree about a score."

**6. Nelly, at the theme change (~15 s)**
> "Only `MaterialApp` rebuilds when the theme changes — the rest of the widget
> tree isn't torn down, because the rebuild is scoped to that one preference."

**7. Nkuba, at the booking document (~20 s)**
> "It stores the property's name and price alongside the ID. That's a deliberate
> snapshot, not duplication — a booking is a financial record, so if the host
> later changes their price, this booking still shows what was agreed."

**8. Nelly, at the rotation (~15 s)**
> "That suite is how we found ten real layout bugs that were completely invisible
> in portrait."

Eight add-backs total roughly two and a half minutes.

---

## If something goes wrong

Don't stop unless the app crashes — a stumble costs far less than a visible cut.
If a network call is slow, say what you're waiting for rather than going silent.
If the app does crash, restart from the beginning of that speaker's segment.
