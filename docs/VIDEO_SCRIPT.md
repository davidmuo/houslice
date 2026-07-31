# Houseslice — Demo Video Script

**Group 22 · Narration order: David → Aime → Nelly → Gift → Nkuba → David**

David operates the phone and shares the screen throughout. The other four narrate
over his navigation. **David follows the speaker — if someone is mid-sentence,
wait.**

Segments 1–5 are the app, on the phone. Segment 6 is the Firebase Console, after
one share switch.

---

## Setup

- [ ] Release APK installed (`flutter build apk --release`)
- [ ] Signed in on David's phone, questionnaire completed
- [ ] **Listing A** already published — deleted in Segment 1
- [ ] **Listing Y** already favourited — un-favourited in Segment 4
- [ ] Settings → **"Replay the intro slides" ON** — the slides only render when
      signed out, and Segment 2 needs them
- [ ] Firebase Console open at **Firestore → Data**, in the tab you'll share
- [ ] Spare university email in a notes app, ready to paste
- [ ] University-domain Google account on the phone
- [ ] Do Not Disturb on, **auto-rotate on**, battery above 50%
- [ ] One timed dry run

---

## Segment 1 — David

**Does:** launches the app cold from the home screen.

> "Houseslice — a student-only housing marketplace for Kigali, running as a
> release build on a physical phone. Cold launch, and it goes straight to the
> home feed: the session persisted across the restart."

**Does:** opens a listing, taps **"Why?"**.

> "Every listing shows a match percentage, computed on the device from my
> lifestyle answers against the host's. This breaks that score across nine
> dimensions and explains each one."

**Does:** closes the sheet → **Profile → My Listings**.

> "These are the listings I've published. Which rows appear is decided by
> `ownerUid` — the same field the security rules check — so the app can't offer
> an action the backend would refuse."

**Does:** **+ New listing** → submits with a required field blank.

> *(pause)* "Validation stops it before anything reaches the network."

**Does:** fills the form, saying the title and price aloud while typing.

> "Calling this one *Sunny double room in Remera*, at **190 dollars** a month."

**Does:** attaches a photo, publishes.

> "Published. **Create.**"

**Does:** taps **Edit**, changes the price to **210**, saves.

> "And editing it to **210**. **Update** — the rules run the same field checks on
> an edit as on a create."

**Does:** taps **Delete** on **listing A** → confirms.

> *(pause)* "Row gone instantly — optimistic, the UI leads and reverts if the
> write fails. **Delete.**"

> ⚠️ New listing exists at **210**; listing A is gone.

**Does:** Profile → **Sign Out**.

> "Signing out so Aime can take you through registration."

---

## Segment 2 — Aime narrates

**David does:** the intro slides appear; he pages through them.

> "A signed-out user sees the intro slides. I built the authentication feature,
> and Houseslice is student-only — enforced, not just stated. Let's try a
> personal address first."

**David does:** Register → `someone@gmail.com` + password → submit.

> *(pause)* "Rejected. The validator only accepts approved university domains."

**David does:** registers with a real university address.

> **Read the address aloud as David types it:** "Registering as *(address)*."

**David does:** the questionnaire appears; he skips through it, then signs out.

> "A new account goes straight to the questionnaire — Nelly will walk that.
> First, our second authentication method."

**David does:** taps **Google**, signs in with a **university** Google account.

> "The domain is checked before a Firebase session is created, so a personal
> Gmail would be rejected even though Google authenticated it. Two methods, both
> gated. Nelly."

---

## Segment 3 — Nelly narrates

**David does:** Profile → Lifestyle questionnaire; answers three or four
questions, submits.

> "I built the app's infrastructure — the wiring, theme system, shared widgets
> and routing. This is the questionnaire that feeds David's matching engine:
> eleven questions on what people actually fall out over as housemates."

**David does:** returns to the home feed.

> *(pause)* "Every match percentage has changed — all recomputed from the answers
> just given. One state change, every card updates."

**David does:** Profile → Settings → theme to **Dark**, sets the preferred
district.

> "Four preferences, all saved to the device."

**David does:** **fully closes the app** — swipes from recents — relaunches.

> *(pause)* "Straight into dark mode, no flash of the light theme, because
> preferences load before the first frame is drawn. The district held, and we're
> still signed in."

**David does:** opens Settings to show both values retained.

**David does:** **rotates to landscape**, scrolls, visits Notifications, Profile
and Explore while rotated.

> "Landscape, no overflow on any screen. We assert every screen at three viewport
> sizes in the test suite."

**David does:** rotates back to portrait.

> "Gift has browsing and search."

---

## Segment 4 — Gift narrates

**David does:** Explore tab → Search → a partial query, then a nonsense query.

> "I built the property module across all three layers. Explore and search run
> off the same catalogue state. Live filtering, and an empty state rather than a
> blank screen."

**David does:** returns to Explore, taps the heart on a listing.

> **Name the listing aloud:** "Favouriting *(listing name)*."

**David does:** switches to the Favourites tab. *(pause)*

> "Filled instantly and it's in Favourites — one state change, two parts of the
> UI."

**David does:** un-favourites **listing Y**.

> **Name Y aloud:** *(pause)* "And removing *(Y)*, which deletes its document.
> Nkuba has booking."

> ⚠️ Newly hearted listing is favourited; **Y** is not.

---

## Segment 5 — Nkuba narrates

**David does:** opens a listing → **Book** → selects a start and end date.

> "I built the booking module. Dates on a range calendar, then payment — card or
> mobile money."

**David does:** Add Card → an **invalid** card number.

> *(pause)* "Rejected by a Luhn checksum, the same algorithm real processors use."

**David does:** valid test number and expiry → price breakdown.

> "Rent, tax and total. Nothing is charged and no card data leaves the device."

**David does:** confirms. Success sheet appears.

> "Booking created."

**David does:** My Bookings → **Upcoming** tab → taps **Cancel booking** on it →
confirms the dialog.

> *(pause)* "Cancelling asks first, because it can't be undone. A create and an
> update on the same record — and `status` is the only field that can change."

**David does:** shows the Cancelled tab.

> "That's the app end to end. David will bring up Firebase now."

> ⚠️ Booking exists with `status: cancelled`.

---

## Segment 6 — David

> **Switch the Zoom share to the browser. Keep talking while you do it.**

> "Let me bring up the Firebase Console — the same project the phone has been
> talking to."

**Does:** Firestore → Data → **`properties`** → newest document.

> "The listing published in the first segment. `name` is *Sunny double room in
> Remera*, the title you watched me type. `pricePerMonth` is **210** — the edited
> value, not the 190 it was published at. **Create** and **update**, both landed."

**Does:** points at `ownerUid`.

> "`ownerUid` is my Firebase Auth UID — the field every security rule checks and
> the field My Listings filters on."

**Does:** points at `images[0]`.

> "The photo is stored inline as a `data:image` URI rather than a Cloud Storage
> URL, because Storage needs the Blaze plan."

**Does:** scrolls the `properties` document list.

> "And the listing I deleted isn't here. **Delete.**"

**Does:** **Authentication → Users**.

> "The account Aime registered, created during this recording — you can see the
> timestamp."

**Does:** Firestore → **`users`** → that UID.

> "And its profile document. Note what isn't in it: no `emailVerified` field.
> Verification is read from the Auth token every time, never stored."

**Does:** `users` → his UID → **`favorites`**.

> "The listing Gift favourited is here — the document ID *is* the listing ID, so
> favouriting twice is idempotent. The one he removed is absent."

**Does:** `users` → his UID → **`bookings`** → newest document.

> "And the booking, `status` set to `cancelled`. It stores the property's name
> and price alongside the ID — a snapshot, because a booking is a financial
> record."

> "So every action on the phone is here in the backend: listings created, updated
> and deleted, an account registered, favourites added and removed, a booking
> created and cancelled — all behind rules that scope every write to its owner.
> Thanks for watching."

---

## Coverage check

| Requirement | Where |
|---|---|
| Cold-start launch | 1 |
| Auth state kept after restart | 1, 3 |
| Register → logout → login | 1, 2 |
| Both authentication flows | 2 |
| Visit every screen | 1–5 |
| Rotate once | 3 |
| **Create** + console | 1, 2, 4, 5 → 6 |
| **Read** | 1, 3, 4 |
| **Update** + console | 1 (190→210), 5 (booking status) → 6 |
| **Delete** + console | 1 (listing), 4 (favourite) → 6 |
| State update, two widgets | 3 (quiz → every card), 4 (heart → Favourites) |
| SharedPrefs → restart → persisted | 3 |
| Validation error | 1, 2, 5 |
| Every member speaks | 1–5 |
