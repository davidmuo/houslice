# Houseslice — Demo Video Script

**Group 22 · Five speakers · Narration order: David → Aime → Nelly → Gift → Nkuba → David**

## How this recording works

**David operates the phone and shares the screen for the entire video.** Nobody
else touches the device. The other four speak over his navigation, each
presenting the part of the application they built.

So every step below is written in two parts:

> **David does:** taps, types, navigates
>
> **[Speaker] says:** the narration over it

This matters for pacing: **David follows the speaker, not the other way round.**
If Aime is mid-sentence, wait. A tap landing before the sentence that explains it
is the most common way a demo like this looks rushed.

The whole app is demonstrated first, on the phone. The Firebase Console comes
once at the end, so there is **one Zoom share switch in the entire recording**
rather than one per write.

This script contains only what the rubric scores. A brisk team lands around
8 minutes, a measured one around 10, a slow one around 12.

---

## Recording setup

You share one source at a time in Zoom, so:

1. **Share the phone** for Segments 1–5.
2. **Switch the share once**, to the browser, for Segment 6.
3. Keep talking across the switch so the audio never goes dead. The switch is not
   a cut; the recording stays continuous.

Open the Firebase Console at **Firestore → Data** in the tab you'll share
*before* you start, so the switch lands somewhere useful rather than on a login
screen.

### One thing to be deliberate about

The rubric asks for CRUD "in Firestore while the Firebase Console is visible."
Showing the console afterwards is weaker than showing it alongside, because the
grader doesn't see cause and effect in one frame. **Segment 6 closes that gap**
by tying every document back to a value the audience watched being typed.

That only works if the speaker **announces the value and David types it**. Those
cues are marked below. Skip them and Segment 6 becomes a database tour rather
than proof the app wrote to it.

---

## Setup checklist

- [ ] Release APK installed (`flutter build apk --release`)
- [ ] **Signed in on David's phone, questionnaire completed** — so the cold start
      in Segment 1 shows a persisted session
- [ ] **One listing already published** — this script calls it **listing A**;
      David deletes it in Segment 1 so the console can show it gone
- [ ] **At least one listing already favourited** — call it **Y**; it gets
      un-favourited in Segment 4 so the console can show that document deleted
- [ ] **In Settings, turn ON "Replay the intro slides"** — the onboarding screens
      only render when signed out, so this is what makes them appear in Segment 2
- [ ] Firebase Console open at **Firestore → Data**, in the tab you will share
- [ ] Spare university email in a notes app on the phone, ready to paste
- [ ] University-domain Google account already on the phone
- [ ] Do Not Disturb on, **auto-rotate on**, battery above 50%
- [ ] **One full dry run**, timed, with the real hand-offs

---

## Segment 1 — David narrates and drives
### Cold start · listing create, update, delete · validation error

**David does:** launches the app cold from the home screen.

**David says:**
> "Houseslice — a student-only housing marketplace for Kigali, running as a
> release build on a physical phone. Cold launch, and it goes straight to the
> home feed: the session persisted across the restart."

**David does:** opens a listing, taps **"Why?"**.

**David says:**
> "Every listing shows a match percentage, computed on the device from my
> lifestyle answers against the host's. This breaks that score across nine
> dimensions and explains each one."

**David does:** closes the sheet → **Profile → My Listings**.

**David says:**
> "These are the listings I've published. Which rows appear is decided by
> `ownerUid` — the same field the security rules check — so the app can't offer
> an action the backend would refuse."

**David does:** **+ New listing** → submits with a required field blank.

**David says:** *(pause)*
> "Validation stops it before anything reaches the network."

**David does:** fills the form, **saying the title and price aloud as he types
them**.

**David says:**
> "Calling this one *Sunny double room in Remera*, at **190 dollars** a month."

**David does:** attaches a photo, publishes.

**David says:**
> "Published. **Create** — we'll see the document at the end."

**David does:** taps **Edit** on the new listing, changes the price to **210**,
saves.

**David says:**
> "And editing it to **210**. **Update** — the rules run the same field checks on
> an edit as on a create, so an edit can't write something that would have been
> rejected as new."

**David does:** taps **Delete** on **listing A** → confirms.

**David says:** *(pause)*
> "Row gone instantly — optimistic, the UI leads and reverts if the write fails.
> **Delete.** Remember this one; the console will show the collection without it."

> ⚠️ **Leave this state:** the new listing exists at **210**; listing A is gone.

**David does:** Profile → **Sign Out**.

**David says:**
> "Signing out so Aime can take you through registration."

---

## Segment 2 — Aime narrates, David drives
### Onboarding · registration · validation error · both auth methods

**David does:** the intro slides appear; he pages through them.

**Aime says:**
> "A signed-out user sees the intro slides. I built the authentication feature,
> and Houseslice is student-only — enforced, not just stated. Let's try a
> personal address first."

**David does:** Register → types `someone@gmail.com` and a password → submits.

**Aime says:** *(pause)*
> "Rejected. The validator only accepts approved university domains."

**David does:** clears it, registers with a real university address.

**Aime says** — *read the address aloud as David types it:*
> "Registering as *(read the address)*. That account and its profile document
> will both be in the console at the end."

**David does:** the questionnaire appears; he skips through it, then signs out.

**Aime says:**
> "A new account goes straight to the questionnaire — Nelly will walk that.
> First, our second authentication method."

**David does:** taps **Google**, completes sign-in with a **university** Google
account.

**Aime says:**
> "The domain is checked before a Firebase session is created, so a personal
> Gmail would be rejected even though Google authenticated it perfectly happily.
> Two methods, both gated. Nelly."

---

## Segment 3 — Nelly narrates, David drives
### State update across widgets · preference persistence · rotation

**David does:** Profile → Lifestyle questionnaire; answers three or four
questions and submits.

**Nelly says:**
> "I built the app's infrastructure — the wiring, theme system, shared widgets
> and routing. This is the questionnaire that feeds David's matching engine:
> eleven questions on what people actually fall out over as housemates."

**David does:** returns to the home feed.

**Nelly says:** *(pause)*
> "And every match percentage has changed — all recomputed from the answers just
> given. One state change, every card across the app updates."

**David does:** Profile → Settings → switches the theme to **Dark**, sets the
preferred district.

**Nelly says:**
> "Four preferences, all saved to the device."

**David does:** **fully closes the app** — swipes it from recents — then
relaunches.

**Nelly says:** *(pause while it launches)*
> "Straight into dark mode, with no flash of the light theme first, because
> preferences load before the first frame is drawn in `main.dart`. The district
> held, and we're still signed in."

**David does:** opens Settings to show both values retained.

**David does:** **rotates the phone to landscape**, scrolls, visits
Notifications, Profile and Explore while rotated.

**Nelly says:**
> "Landscape, no overflow on any screen. We assert every screen at three viewport
> sizes in the test suite — that's how we found ten layout bugs that were
> invisible in portrait."

**David does:** rotates back to portrait.

**Nelly says:**
> "Gift has browsing and search."

---

## Segment 4 — Gift narrates, David drives
### Explore and search · favourite create and delete

**David does:** Explore tab → Search → types a partial query, then a nonsense
query.

**Gift says:**
> "I built the property module across all three layers. Explore and search run
> off the same catalogue state, so the two views can't disagree. Live filtering,
> and a proper empty state rather than a blank screen."

**David does:** returns to Explore, **taps the heart on a listing**.

**Gift says** — *name the listing aloud:*
> "Favouriting *(listing name)*."

**David does:** switches to the Favourites tab. *(pause)*

**Gift says:**
> "Filled instantly and it's in Favourites — one state change, two parts of the
> UI. That created a document we'll see shortly."

**David does:** un-favourites **listing Y**.

**Gift says** — *name Y aloud:*
> *(pause)* "And removing *(name of Y)*, which deletes its document. A favourite
> created and a favourite deleted. Nkuba has booking."

> ⚠️ **Leave this state:** the newly hearted listing is favourited; **Y** is not.

---

## Segment 5 — Nkuba narrates, David drives
### Booking create · payment validation error · cancellation update

**David does:** opens a listing → **Book** → selects a start and end date.

**Nkuba says:**
> "I built the booking module. Dates first, on a custom range calendar, then
> payment — card or mobile money."

**David does:** Add Card → types an **invalid** card number.

**Nkuba says:** *(pause)*
> "Rejected by a Luhn checksum, the same algorithm real processors use, so an
> obviously fake number never gets through."

**David does:** enters a valid test number and expiry, continues to the price
breakdown.

**Nkuba says:**
> "Rent, tax and total. To be clear on scope: nothing is charged and no card data
> leaves the device."

**David does:** confirms. The success sheet appears.

**Nkuba says:**
> "Booking created."

**David does:** My Bookings → **cancels that booking**.

**Nkuba says:** *(pause)*
> "And cancelled. A create and an update on the same record — and `status` is the
> only field that *can* change. The rules block any edit to the price or the
> dates of a booking already agreed."

**David does:** shows the Cancelled tab.

**Nkuba says:**
> "That's the app end to end. David's going to bring up Firebase now and show
> that every one of those actions landed in the backend."

> ⚠️ **Leave this state:** the booking exists with `status: cancelled`.

---

## Segment 6 — David narrates and drives
### Firebase Console verification

> **Switch the Zoom share to the browser now.** Keep talking while you do it.

**David says:**
> "Let me bring up the Firebase Console — the same project the phone has been
> talking to for the last eight minutes."

### 6.1 The listing that was created and updated

**David does:** Firestore → Data → **`properties`** → opens the newest document.

**David says:**
> "Here's the listing published in the first segment. `name` is *Sunny double
> room in Remera* — the title you watched me type. `pricePerMonth` is **210**,
> the edited value, not the 190 it was published at. So **create** and
> **update**, both landed."

**David does:** points at `ownerUid`.

**David says:**
> "`ownerUid` is my Firebase Auth UID — the field every security rule checks and
> the field My Listings filters on, which is why the interface can never offer an
> action the backend would refuse."

**David does:** points at `images[0]`.

**David says:**
> "And the photo is stored inline as a `data:image` URI rather than a Cloud
> Storage URL, because Storage needs the Blaze plan. We say so plainly in the
> report rather than implying we use Storage."

### 6.2 The listing that was deleted

**David does:** scrolls the `properties` document list.

**David says:**
> "And the listing I deleted isn't here. You watched it disappear from My
> Listings; it's gone from the collection too. **Delete.**"

### 6.3 The account registered live

**David does:** **Authentication → Users**.

**David says:**
> "The account Aime registered, created during this recording — you can see the
> timestamp."

**David does:** Firestore → **`users`** → that UID.

**David says:**
> "And its profile document. Note what *isn't* in it: no `emailVerified` field.
> Verification is read from the Auth token every time, never stored, so writing
> to your own profile can't manufacture a verified badge."

### 6.4 Favourites

**David does:** `users` → his UID → **`favorites`**.

**David says:**
> "The listing Gift favourited is here — and the document ID *is* the listing ID,
> so favouriting twice is idempotent and the body holds nothing but a timestamp.
> The one he removed is absent. Create and delete."

### 6.5 The booking

**David does:** `users` → his UID → **`bookings`** → the newest document.

**David says:**
> "And the booking, with `status` set to `cancelled`. It also stores the
> property's name and price alongside the ID — a deliberate snapshot, because a
> booking is a financial record. If the host later changes their price, this
> booking still shows what was agreed."

**David says:**
> "So every action on the phone is here in the backend: listings created, updated
> and deleted, an account registered, favourites added and removed, a booking
> created and cancelled — all behind rules that scope every write to its owner.
> Thanks for watching."

---

## Coverage check

| Rubric requirement | Where |
|---|---|
| Cold-start launch | 1 |
| Auth state kept after restart | 1, 3 |
| Register → logout → login | 1 (logout), 2 |
| Both authentication flows | 2 |
| Visit every screen | 1–5 |
| Rotate the device once | 3 |
| **Create** in Firestore, console shown | 1 + 6.1, 2 + 6.3, 4 + 6.4, 5 + 6.5 |
| **Read** from Firestore | 1, 3, 4 |
| **Update** in Firestore, console shown | 1 + 6.1 (190→210), 5 + 6.5 (booking status) |
| **Delete** in Firestore, console shown | 1 + 6.2 (listing), 4 + 6.4 (favourite) |
| State update touching two widgets | 3 (quiz → every card), 4 (heart → Favourites tab) |
| SharedPreferences change → restart → persisted | 3 |
| Validation error with a polite message | 1, 2, 5 |
| Every member speaks | 1–5 (all five narrate their own feature) |
| No slide deck, no introductions | — |

---

## Spoken values → console proof

Segment 6 only works as evidence if each document matches something the audience
heard. The speaker announces the value; David types it.

| Announced in the app | Proves it in the console |
|---|---|
| "*Sunny double room in Remera*" | `name` matches |
| "190 a month… editing to **210**" | `pricePerMonth` is 210, not 190 |
| "Favouriting *(listing name)*" | document ID matches that listing |
| "Removing *(listing Y)*" | no document for Y |
| Aime reads the registration email aloud | same address in Authentication → Users |

---

## If a take goes wrong

Don't stop unless the app crashes — a stumble costs far less than a visible cut,
and the rubric rewards a single continuous recording. If a write is slow, say
what you're waiting for rather than going quiet.

If the app crashes, restart from the beginning of that speaker's segment.

If a document turns out to be missing in Segment 6 because an app step was
skipped, **say so and move on**. Do not stage one. An honest "we didn't get to
that" costs a fraction of what a grader finding a fabricated document would.

---

## Add-backs if you finish under 10 minutes

Written out so nobody improvises on camera. Add in order.

**1. David, after the "Why?" sheet (~20 s)**
> "The scorer is a plain Dart class in the domain layer — no Flutter or Firebase
> imports, which is why we can unit-test the matching logic directly."

**2. David, at the home feed (~15 s)**
> "Every card also carries a Student or Realtor badge. On Facebook you can't tell
> a fellow student from a letting agent; here you always can."

**3. Aime, after the blank-field rejection (~15 s)**
> "Username at least three characters, password at least six, and nothing reaches
> the network until every field passes."

**4. Nelly, after the scores recompute (~20 s)**
> "They all read from a single `LifestyleCubit` instance, registered as a
> singleton so two screens can never disagree about a score."

**5. Nelly, at the theme change (~15 s)**
> "Only `MaterialApp` rebuilds — the rest of the tree isn't torn down, because
> the rebuild is scoped to that one preference."

**6. Nkuba, at the price breakdown (~15 s)**
> "The tax line is computed in the domain layer, not in the widget, so the same
> calculation is unit-tested independently of the screen."

**7. David, in Segment 6.1 (~20 s)**
> "The rules also pin `ownerUid` as immutable, so a listing can't be handed to
> someone else, or claimed by someone else after the fact."
