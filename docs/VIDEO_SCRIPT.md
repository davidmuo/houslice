# Houseslice — Demo Video Script

**Group 22 · Target length 10 minutes · Five speakers**

**Speaking order:** David → Aime → Nelly → Gift → Nkuba

Each member presents the part of the application they built, so any question put
to a speaker is about their own code. The order also follows a coherent journey
through the app: a returning user, then a new registration, then the
questionnaire that drives matching, then browsing, then booking.

### Timing budget

| Segment | Speaker | Target | Running total |
|---|---|---|---|
| 1 | David | 2 min 45 s | 2:45 |
| 2 | Aime | 2 min 15 s | 5:00 |
| 3 | Nelly | 2 min 00 s | 7:00 |
| 4 | Gift | 1 min 30 s | 8:30 |
| 5 | Nkuba | 1 min 45 s | 10:15 |

**10 minutes is the rubric's floor, not a target to beat.** If you finish at
9:30 you are under the requirement. Pad by letting the *(pause)* beats breathe —
never by cutting an action.

**Every action in this script is scored.** If you run long, speak faster and
narrate less; do not drop a step. The coverage table at the end shows which
rubric line each action satisfies.

---

## Before you record — non-negotiables

| Requirement | Why it matters |
|---|---|
| **Release APK on a physical Android phone** | A web, desktop or Chrome build scores **zero**. Build with `flutter build apk --release` and install it. |
| **One continuous recording** | No cuts, no speed-ups, no transitions. One take. |
| **No slide deck, no team introductions** | The brief says so twice. Start on the app. |
| **≥ 1080p, clear audio** | Screen-record on the phone, or use `scrcpy` and capture the window. Quiet room; no fans or echo. |
| **Firebase Console visible during CRUD** | Second screen or split view. The document must be legible when it changes. |
| **Every member speaks** | Each of the five presents their own segment. Hand off by name. |
| **Rotate the device at least once** | The rubric asks for it explicitly. |

### Setup checklist

At 10 minutes there is no room to fix anything mid-take. Do all of this first.

- [ ] Release APK installed on the phone
- [ ] **Signed in already, questionnaire completed**, so Segment 1's cold start
      shows a persisted session. Aime registers a fresh account live in Segment 2
- [ ] **Two listings already published by your account**, so My Listings has
      something to edit and delete without publishing one first
- [ ] Firebase Console open at **Firestore → Data**, second tab at
      **Authentication → Users**, both already scrolled to the right place
- [ ] A spare university email typed into a notes app, ready to paste
- [ ] A university-domain Google account already added to the phone
- [ ] Phone on Do Not Disturb, battery above 50%, **auto-rotate on**
- [ ] Screen recorder at 1080p+
- [ ] One person drives the phone throughout; speakers change, the driver does not
- [ ] **Do one full dry run.** At this length, a single fumbled navigation costs
      10% of the video

---

## Segment 1 — Cold start, compatibility, and listing CRUD
### Speaker: **David Muotoh** · 2 min 45 s

> "Houseslice — a verified student-only housing marketplace for Kigali, running
> as a release build on a physical phone. Starting cold."

**Do:** Tap the app icon.

> "Straight to the home feed, no sign-in screen: the session persisted across
> the restart."

**Do:** Scroll the feed briefly.

> "Every card carries two things. A **Student** or **Realtor** badge — on
> Facebook you can't tell a peer from a letting agent, here you always can. And
> a **match percentage**, which isn't stored in the database. It's computed on
> the device from my lifestyle answers against the host's."

**Do:** Open a high-scoring listing. Tap **"Why?"**.

> "Rather than just asserting a number, it breaks the score across nine
> dimensions and explains each one — so I can see we match on sleep schedule but
> differ on guests, and judge for myself."

**Do:** Close the sheet. **Profile → My Listings**.

> "These are the listings I've published. What decides which rows appear is
> `ownerUid` — the same field the Firestore security rules check — so the app
> can never offer me an action the backend would refuse."

**Do:** **New listing**. Submit with a required field blank.

> **(pause)** "Validation stops it before anything hits the network."

**Do:** Complete the form, attach a photo, publish.

> **(switch to console)** **(pause)** "New document in `properties`, `ownerUid`
> set to my UID. **Create.**"

**Do:** My Listings → **Edit** → change the price → Save.

> **(switch to console)** **(pause)** "Same document, new price. **Update** — and
> the rules run the same field validation on an edit as on a create."

**Do:** **Delete** → confirmation dialog appears.

> "Delete confirms first, because it can't be undone."

**Do:** Confirm. *(pause)*

> "Row gone instantly — optimistic, the UI leads and reverts if the write fails
> — and the document is gone in the console. **Delete.**"

**Do:** Profile → **Sign Out**.

> "Signing out so Aime can register from scratch. This clears the Google session
> too, which matters shortly."

---

## Segment 2 — Registration, validation and both authentication methods
### Speaker: **Aime Ndayambaje** · 2 min 15 s

> "I built authentication. Houseslice is student-only, and that's enforced, not
> just stated."

**Do:** Register → enter `someone@gmail.com` and a password → submit.

> **(pause)** "Rejected — the validator only accepts approved university
> domains."

**Do:** Clear it. Leave username blank, enter a 3-character password. Submit.

> "Username at least three characters, password at least six, and nothing
> reaches the network until every field passes."

**Do:** Register with a real university address.

> **(switch to console → Authentication → Users)** **(pause)** "The account,
> created just now. A verification email has already gone out."

**Do:** Switch to Firestore → `users`.

> "And a profile document at `users/` and the new UID. Note what *isn't* there:
> no `emailVerified` field. Verification is read from the Auth token every time,
> never stored — so writing to your own profile can't fake a verified badge."

**Do:** Back on the phone — the new account lands on the questionnaire. Skip
through it.

> "A new account goes straight to the questionnaire; Nelly will walk that. First
> our second method — signing out and back in with Google."

**Do:** Sign out → tap **Google**.

> "Because the earlier sign-out cleared the Google session, we get the account
> picker rather than silently reusing the last account."

**Do:** Complete Google sign-in with a **university** Google account.

> "The important part is invisible: the domain is checked *before* a Firebase
> session is created. A personal Gmail would authenticate fine with Google and
> we'd still reject it and drop the session. Two methods, both gated. Nelly."

---

## Segment 3 — Questionnaire, preferences, persistence and rotation
### Speaker: **Isimbi Nelly** · 2 min

> "I built the app's infrastructure — the wiring, theme system, shared widgets
> and routing. Starting with the questionnaire that feeds David's matching
> engine."

**Do:** Profile → Lifestyle questionnaire. Answer three or four questions
briskly — bedtime, cleanliness, guests.

> "Eleven questions covering what people actually fall out over as housemates:
> sleep schedule, tidiness, guests, smoking, pets, sharing."

**Do:** Finish and submit. Return to the home feed.

> **(pause)** "Every match percentage on the feed has changed — all recomputed
> against the answers I just gave. One state change, every card across the app
> updates, because they all read from a single `LifestyleCubit` instance
> registered as a singleton so two screens can never disagree."

**Do:** Profile → Settings → switch to **Dark**. *(pause on the change)*

> "Four preferences: theme, notifications, preferred district, onboarding
> replay. Only `MaterialApp` rebuilds on a theme change — the rest of the tree
> isn't torn down."

**Do:** Also set the preferred district. Then **fully close the app** (swipe from
recents — not just background it). Relaunch.

> **(pause while it launches)** "Straight into dark mode, with no flash of the
> light theme first, because preferences load before the first frame is drawn in
> `main.dart`. District held, and I'm still signed in."

**Do:** Open Settings to show both values retained.

**Do:** **Rotate to landscape.** Hold. Scroll. Navigate to one other screen.

> "Landscape, no overflow. We test this automatically — every screen asserted at
> three viewport sizes, which is how we found ten layout bugs that were
> invisible in portrait."

**Do:** Rotate back to portrait.

> "Gift has browsing and search."

---

## Segment 4 — Explore, search and favourites
### Speaker: **Gift Don-Emmanuel** · 1 min 30 s

> "I built the property module, across all three layers."

**Do:** Explore tab.

> "Explore is a grid over the same catalogue — the same `PropertyBloc` state
> rendered differently, so the two views can't disagree."

**Do:** Search → type a partial query → then a nonsense query.

> "Live filtering, and a proper empty state rather than a blank screen."

**Do:** Clear, return to Explore.

> "Now watch two things at once — the heart on this card, and the Favourites tab
> below."

**Do:** Tap the heart. *(pause)* Switch to Favourites — it's there.

> "Filled instantly, and it's in Favourites. Optimistic again."

**Do:** **(switch to console)** show the new favourites document.

> "In Firestore the document ID *is* the listing ID, so favouriting twice is
> idempotent, and the body holds only a timestamp — no duplicated listing data."

**Do:** Back on the phone, un-heart it. *(pause)*

> "Gone from Favourites, and the document is deleted. Create and delete, live.
> Nkuba has booking."

---

## Segment 5 — Booking, payment validation and cancellation
### Speaker: **Nkuba Junior Igiraneza** · 1 min 45 s

> "I built the booking module."

**Do:** Open a listing → **Book**. Select a start and end date.

> "Dates first, on a custom range calendar. Then payment — card or mobile money."

**Do:** Card → Add Card → enter an **invalid** number.

> **(pause)** "Rejected. That's a Luhn checksum, the same algorithm real
> processors use, so an obviously fake number never gets through."

**Do:** Enter a valid test number and expiry. Continue to the price breakdown.

> "Rent, tax, total. To be clear on scope: nothing is charged and no card data
> leaves the device."

**Do:** Confirm. Success sheet appears.

> **(switch to console)** **(pause)** "The booking document, written just now. It
> stores the property's name and price alongside the ID — a deliberate snapshot,
> because a booking is a financial record. If the host later changes their
> price, this booking still shows what was agreed."

**Do:** My Bookings → cancel a booking.

> **(switch to console)** **(pause)** "`status` flips to `cancelled` — and it's
> the only field that *can* change. The rules use a diff check, so a client can
> move a booking through its lifecycle but never rewrite the price or dates of a
> stay already agreed."

**Do:** Show the Cancelled tab.

> "So: two authentication methods, both domain-gated; full create, read, update
> and delete against Firestore behind owner-scoped security rules; BLoC on a
> Clean Architecture codebase with no business logic in the UI; five preferences
> that survive a restart; and 298 passing tests at 74.5% coverage. Thanks for
> watching."

---

## Coverage check against the rubric

Tick each before submitting. Every one is a scored line item.

| Rubric requirement | Segment | Speaker |
|---|---|---|
| Cold-start launch | 1 | David |
| Auth state kept after restart | 1 and 3 | David, Nelly |
| Register → logout → login | 1 (logout) and 2 | David, Aime |
| Both authentication flows (email/password + Google) | 2 | Aime |
| Visit every screen | 1–5 | All |
| Rotate the device once | 3 | Nelly |
| **Create** in Firestore, console visible | 1 (listing), 4 (favourite), 5 (booking) | David, Gift, Nkuba |
| **Read** from Firestore | 1, 3, 4 | David, Nelly, Gift |
| **Update** in Firestore, console visible | 1 (listing price), 5 (booking status) | David, Nkuba |
| **Delete** in Firestore, console visible | 1 (listing), 4 (unfavourite) | David, Gift |
| State update touching two widgets | 3 (quiz → every card's score), 4 (heart → Favourites tab) | Nelly, Gift |
| SharedPreferences change → restart → persisted | 3 | Nelly |
| Forced validation error with a polite message | 1, 2, 5 | David, Aime, Nkuba |
| Every member speaks | 1–5 | All |
| No slide deck, no team introductions | — | — |

---

## If you run over or under

**Over 11 minutes** — cut narration, never actions. The safe lines to lose are
the architectural asides: the singleton explanation in Segment 3, the snapshot
rationale in Segment 5, the `emailVerified` note in Segment 2. Each buys about
fifteen seconds and none is a scored item.

**Under 10 minutes** — you are below the requirement. Hold the *(pause)* beats
longer, especially on the Firebase Console, and scroll the home feed and the
"Why?" breakdown more slowly. Do not add new material mid-take.

## If something goes wrong

Don't stop unless the app crashes — a brief stumble costs far less than a
visible cut, and the rubric rewards a single continuous recording. If a network
call is slow, say what you're waiting for rather than going silent.

If the app does crash, restart from the beginning of that speaker's segment.
