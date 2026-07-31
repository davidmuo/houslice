# Houseslice — Demo Video Script

**Group 22 · Target length 12–14 minutes · Five speakers**

---

## Before you record — non-negotiables

These come straight from the rubric. Getting any of them wrong costs marks no
matter how good the demo is.

| Requirement | Why it matters |
|---|---|
| **Release APK on a physical Android phone** | A web, desktop or Chrome build scores **zero**. Build with `flutter build apk --release` and install it. |
| **One continuous recording** | No cuts, no speed-ups, no transitions. Record in one take. |
| **No slide deck, no team introductions** | The brief says so twice. Start on the app. |
| **≥ 1080p, clear audio** | Screen-record on the phone itself, or use `scrcpy` and capture the window. Record audio in a quiet room; avoid fans and echo. |
| **Firebase Console visible during CRUD** | Have the console open on a second screen or split view. The document must be legible when it changes. |
| **Every member speaks** | Each of the five presents their own segment. Hand-offs by name. |
| **Rotate the device at least once** | The rubric asks for it explicitly. |

### Setup checklist

- [ ] Release APK installed, app **fully uninstalled and reinstalled** so the first launch is a genuine cold start
- [ ] Firebase Console open at **Firestore → Data**, and a second tab at **Authentication → Users**
- [ ] A spare university email ready for the live registration
- [ ] A Google account on a university domain ready for the Google sign-in
- [ ] At least one listing already published by your account, so My Listings is not empty when you reach it
- [ ] Phone on Do Not Disturb, battery above 50%, auto-rotate **on**
- [ ] Screen recorder at 1080p or higher
- [ ] One person drives the phone throughout; speakers change, the driver does not

### Speaking notes

Speak to what is on screen. Where a line below says *(pause)*, actually stop
talking and let the screen show the result — silence while a document appears in
Firestore is more convincing than narration over it. Timings are guides, not
targets; do not rush a CRUD operation to hit a number.

---

## Segment 1 — Cold start, onboarding and registration
### Speaker: **Aime Ndayambaje** · ~2 min 30 s

> "This is Houseslice, a student-only housing marketplace for Kigali, running as
> a release build on a physical Android device. I'll start from a cold launch."

**Do:** Tap the app icon from the home screen.

> "The splash screen checks for an existing session while it's showing. There
> isn't one, so we go to onboarding — three intro slides, then the location
> chooser. Whether these slides appear is a saved preference, so a returning
> student never sees them twice."

**Do:** Page through the three slides → Get Started → location screen → Skip.

> "Now registration. Houseslice is student-only, and that's enforced, not just
> stated. Let me show you what happens with a personal address."

**Do:** Type `someone@gmail.com` and a password. Tap Register.

> "Rejected — 'Use your university email'. The validator only accepts approved
> university domains. Let me also show the other validators."

**Do:** Clear the email. Leave username blank, enter a 3-character password. Tap
Register so the field errors appear.

> "Username has to be at least three characters, password at least six, and
> nothing reaches the network until every field passes. Now a real registration."

**Do:** Register with a genuine university address.

> **(pause — switch to Firebase Console → Authentication → Users)**

> "There's the account in Firebase Authentication, created just now. A
> verification email has already gone out, and a profile document was written to
> Firestore at `users/` and the user's UID."

**Do:** Show the `users/{uid}` document in the console.

> "Handing over to Nelly for the questionnaire and the matching engine."

---

## Segment 2 — Lifestyle questionnaire and compatibility
### Speaker: **Isimbi Nelly** · ~2 min 30 s

> "A new student lands straight in the lifestyle questionnaire, because
> Houseslice can't match anyone it knows nothing about. There are eleven
> questions plus a free-text introduction."

**Do:** Answer through several questions — bedtime, cleanliness, social life,
smoking — narrating as you go. Show the progress indicator advancing.

> "These cover the things people actually fall out over as housemates: sleep
> schedule, tidiness, guests, smoking, pets, and how much you want to share."

**Do:** Finish the questionnaire and submit.

> "The answers are saved to device storage, not the server. They're needed on
> every listing card, so fetching them over the network per card would be
> wasteful — and they're not sensitive enough to require server storage."

**Do:** Arrive at the home feed.

> "And here's the payoff. Every shared-home listing now carries a live match
> percentage, computed against the answers I just gave. These aren't static
> numbers baked into the data — they're calculated on the device from my profile
> against each host's."

**Do:** Open a listing with a high score → tap **"Why?"**.

> "This is the feature we're proudest of. Rather than asserting a number, it
> breaks the score down across nine dimensions and explains each one in a
> sentence. So I can see we match on sleep schedule and cleanliness, but differ
> on how often we have guests — and decide for myself whether that matters."

**Do:** Scroll the breakdown sheet.

> "Also note the badge on every listing — Student or Realtor. On Facebook you
> can't tell a fellow student from an agent. Here you always can. Over to Gift."

---

## Segment 3 — Browsing, search, favourites and the state demo
### Speaker: **Gift Don-Emmanuel** · ~2 min 30 s

> "I built the property module. Let me show browsing, then a state update that
> touches two screens at once."

**Do:** Home feed → scroll → tap into Explore.

> "Explore is a grid view over the same catalogue — the same `PropertyBloc`
> state, rendered differently, so the two can never disagree."

**Do:** Open Search. Type a partial query.

> "Search filters live as I type, with Recent and Result sections."

**Do:** Type a nonsense query.

> "And a proper empty state rather than a blank screen."

**Do:** Clear it, return to Explore.

> "Now the state demo. Watch two things at once — the heart on this card, and
> the Favourites tab at the bottom."

**Do:** Tap the heart on a listing. *(pause)*

> "The heart filled instantly. That's an optimistic update — the UI changes
> before the network round trip finishes, and reverts with an error message if
> Firestore rejects the write."

**Do:** Switch to the Favourites tab — the listing is there.

> **(switch to Firebase Console)**

> "And in Firestore, under `users`, my UID, `favorites`, there's a new document.
> The document ID is the listing ID itself, so favouriting twice is idempotent
> and the document body holds nothing but a timestamp — no duplicated listing
> data."

**Do:** Show the favourites document. Then back on the phone, un-heart it.

> **(pause)** "Gone from Favourites, and the document is deleted in the console.
> That's create and delete, both live. Nkuba will take the booking flow."

---

## Segment 4 — Booking flow, rotation and validation error
### Speaker: **Nkuba Junior Igiraneza** · ~3 min

> "I built the booking module. Starting from a listing's details screen."

**Do:** Open a listing → scroll through gallery, about section, verified-host
card → tap Book.

> "First the dates, on a custom range calendar."

**Do:** Select a start and end date.

> "Then payment method — card or mobile money. Let me add a card, because
> that's where the validation is."

**Do:** Choose card → Add Card → enter an **invalid** card number.

> **(pause)** "Rejected. That's a Luhn checksum, the same algorithm real payment
> processors use, so an obviously fake number never gets through. The expiry
> date is validated too."

**Do:** Enter a valid test number and expiry.

> "To be clear about scope: nothing is charged and no card data leaves the
> device. We say that plainly in the report rather than implying we process
> payments."

**Do:** Continue to the price breakdown.

> "Monthly rent, tax, and the total across the period."

**Do:** Confirm the booking. Success sheet appears.

> **(switch to Firebase Console)**

> "There's the booking document under my user, written just now — with the
> property name, address, price and dates. We deliberately snapshot the price and
> name onto the booking rather than only storing a reference, because a booking
> is a financial record. If the host later changes their price, this booking
> still shows what was actually agreed."

**Do:** Back on the phone, go to My Bookings.

> "Upcoming, Completed and Cancelled tabs. Now the rotation the brief asks for."

**Do:** **Rotate the phone to landscape.** Hold for a few seconds. Scroll.

> "Landscape, no overflow. We test this automatically — every screen is asserted
> at three viewport sizes in the test suite, which is how we found ten real
> layout bugs that were invisible in portrait."

**Do:** Rotate back to portrait. Cancel a booking.

> **(switch to console)** "And the status field flips to `cancelled` — an update,
> live. The rules only let the status change; the price and dates are locked once
> a booking exists. David will finish with listings, settings and persistence."

---

## Segment 5 — My Listings CRUD, settings persistence and sign-out
### Speaker: **David Muotoh** · ~3 min 30 s

> "I'll cover the remaining CRUD operations and preference persistence."

**Do:** Profile tab → **List your place**.

> "A student sublets a room; an agent posts a whole property. Watch what happens
> when I select Realtor."

**Do:** Tap Realtor.

> "It forces 'Entire place' and disables the housemate option, because an agency
> has no lifestyle profile to match against — the matching feature would be
> meaningless."

**Do:** Switch back to Student. Fill in the form. Add a photo from the gallery.

> "Photos come from the device gallery, compressed on the way in."

**Do:** Try to submit with a **blank required field** first.

> **(pause)** "Validation catches it before anything is sent."

**Do:** Complete the form and publish.

> **(switch to console)** "New document in `properties`, with `ownerUid` set to my
> UID. That field is the whole security model — I'll come back to it."

**Do:** Profile → **My Listings**.

> "Here's everything I've published, with Edit and Delete on each. What decides
> whether a row appears here is `ownerUid` — the exact same field the Firestore
> security rules check. So the app can never offer me an action the backend would
> refuse. I'm never shown an Edit button for a listing I can't actually edit."

**Do:** Tap **Edit**. Change the price. Save.

> **(switch to console)** "Price updated on the same document. That's the U in
> CRUD, on a listing this time."

**Do:** Tap **Delete**. Confirmation dialog appears.

> "Delete asks first, because it can't be undone."

**Do:** Confirm. *(pause)*

> "Row gone immediately — optimistic again — and in the console the document is
> gone too. Create, read, update, delete, all four, all live."

**Do:** Profile → Settings.

> "Four preferences here. Let me change the theme."

**Do:** Switch to **Dark**. *(pause on the theme change)*

> "Theme, notification opt-in, preferred district, and whether onboarding shows
> again. Now the part that matters — persistence."

**Do:** **Fully close the app** (swipe from recents, don't just background it).
Relaunch.

> **(pause while it launches)** "Relaunched, and it opens straight into dark mode
> — no flash of the light theme first, because preferences load before the first
> frame is drawn. I'm also still signed in: the session survived the restart."

**Do:** Show the district and notification settings still as set.

> "All the settings held."

**Do:** Profile → Sign Out. Then sign back in with **Google**.

> "Signing out clears the Google session as well as the Firebase one, so the
> account picker appears rather than silently reusing the last account. And
> here's our second authentication method."

**Do:** Complete Google sign-in with a university Google account.

> "Google Sign-In — but the domain is checked *before* a Firebase session is
> created. A personal Gmail account is rejected at this point even though Google
> itself authenticated it. Two independent methods, both domain-gated."

> "That's Houseslice: two authentication methods, full CRUD against Firestore
> with owner-scoped security rules, BLoC state management on a Clean Architecture
> codebase, persisted preferences, and 298 passing tests at 74.5% coverage.
> Thanks for watching."

---

## Coverage check against the rubric

Tick each before you submit. Every one of these is a scored line item.

| Rubric requirement | Segment |
|---|---|
| Cold-start launch | 1 |
| Register → logout → login | 1 and 5 |
| Both authentication flows (email/password + Google) | 1 and 5 |
| Visit every screen | 1–5 |
| Rotate the device once | 4 |
| **Create** in Firestore with console visible | 3 (favourite), 4 (booking), 5 (listing) |
| **Read** from Firestore | 2, 3 |
| **Update** in Firestore with console visible | 4 (booking status), 5 (listing price) |
| **Delete** in Firestore with console visible | 3 (unfavourite), 5 (listing) |
| State update touching two widgets | 3 (heart + Favourites tab) |
| SharedPreferences change → restart → persisted | 5 |
| Forced validation error with a polite message | 1, 4, 5 |
| Every member speaks | All five |
| No slide deck, no team introductions | — |

---

## If something goes wrong mid-take

Don't stop and restart unless the app crashes. A brief stumble is far less
costly than a visible cut, and the rubric explicitly rewards a single continuous
recording. If a network call is slow, say what you're waiting for — "this is
writing to Firestore now" — rather than going silent.

If the app *does* crash, restart the recording from the beginning of that
segment's speaker rather than from the very top.
