# Houseslice — Demo Video Script

**Group 22 · Five speakers · Order: David → Aime → Nelly → Gift → Nkuba → David**

The whole app is demonstrated first, on the phone. The Firebase Console comes
once at the end, as a single verification pass. That means **one Zoom share
switch in the entire recording** instead of switching back and forth for every
write.

This script contains only what the rubric scores. Nothing here is padding, so
nothing here is safe to cut. A brisk team lands around 8 minutes, a measured one
around 10, a slow one around 12.

---

## Recording setup

You are sharing one source at a time in Zoom, so:

1. **Share the phone** (mirrored, or a phone-screen share) for Segments 1–5.
2. **Switch the share once**, to the browser, for Segment 6.
3. Keep talking across the switch — "let me bring up the console now" — so the
   audio never goes dead. The switch is not a cut; the recording stays continuous.

Before you start, open the Firebase Console at **Firestore → Data** in the tab
you'll share, so the switch lands somewhere useful rather than on a login screen.

### One thing to be deliberate about

The rubric asks for CRUD "in Firestore while the Firebase Console is visible."
Showing the console after the fact is weaker than showing it alongside, because
the grader doesn't see cause and effect in one frame. **Segment 6 is written to
close that gap** — every document is tied back to a value the audience watched
being typed, so the connection is verifiable rather than asserted.

For that to work, the app segments must leave the right traces. The setup
checklist and the "leave this state" notes are not optional.

---

## Setup checklist

- [ ] Release APK installed (`flutter build apk --release`)
- [ ] **Signed in, questionnaire completed** — so Segment 1's cold start shows a
      persisted session
- [ ] **One listing already published**, titled distinctively. This script calls
      it **listing A**; David deletes it in Segment 1 so the console can show it
      gone
- [ ] **In Settings, turn ON "Replay the intro slides"** — the onboarding screens
      only render when signed out, so this is what makes them appear for Aime
      after David signs out
- [ ] **At least one listing already favourited** — call it **Y**; Gift
      un-favourites it so the console can show that document deleted
- [ ] Firebase Console open at **Firestore → Data**, in the tab you will share
- [ ] Spare university email ready to paste
- [ ] University-domain Google account already on the phone
- [ ] Do Not Disturb on, **auto-rotate on**, battery above 50%
- [ ] One person drives the phone throughout; only the speaker changes
- [ ] **One full dry run**, timed

---

## Segment 1 — David Muotoh
### Cold start · listing create, update, delete · validation error

**Do:** Launch the app cold from the home screen.

> "Houseslice — a student-only housing marketplace for Kigali, running as a
> release build on a physical phone. Cold launch, and it goes straight to the
> home feed: the session persisted across the restart."

**Do:** Open a listing. Tap **"Why?"**.

> "Every listing shows a match percentage, computed on the device from my
> lifestyle answers against the host's. This breaks that score across nine
> dimensions and explains each one."

**Do:** Close. **Profile → My Listings.**

> "These are the listings I've published. Which rows appear is decided by
> `ownerUid` — the same field the security rules check — so the app can't offer
> an action the backend would refuse."

**Do:** **+ New listing.** Submit with a required field blank.

> *(pause)* "Validation stops it before anything reaches the network."

**Do:** Fill the form. **Say the title and price out loud as you type them** —
the console will show these exact values in Segment 6.

> "Calling this one *Sunny double room in Remera*, at **190 dollars** a month."

**Do:** Attach a photo, publish.

> "Published. **Create** — we'll see the document at the end."

**Do:** On the new listing, tap **Edit**. Change the price to **210**. Save.

> "And editing it to **210**. **Update** — the rules run the same field checks on
> an edit as on a create, so an edit can't write something that would have been
> rejected as new."

**Do:** On **listing A** (the pre-published one), tap **Delete** → confirm.

> *(pause)* "Row gone instantly — that's optimistic, the UI leads and reverts if
> the write fails. **Delete.** Remember this one is gone; the console will show
> the collection without it."

> ⚠️ **Leave this state:** the new listing exists at **210**, listing A is gone.

**Do:** Profile → **Sign Out**.

> "Signing out so Aime can register from scratch."

---

## Segment 2 — Aime Ndayambaje
### Onboarding · registration · validation error · both auth methods

**Do:** The intro slides appear. Page through them.

> "A signed-out user sees the intro slides. I'll register a new account."

**Do:** Register → `someone@gmail.com` + a password → submit.

> *(pause)* "Rejected. Houseslice only accepts approved university domains —
> enforced, not just stated."

**Do:** Register with a real university address. **Say the address out loud.**

> "Registering as *(read the address)*. That account and its profile document
> will both be in the console at the end."

**Do:** The questionnaire appears. Skip through it. Sign out.

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

**Do:** **Fully close the app** — swipe it from recents. Relaunch.

> *(pause)* "Straight into dark mode with no flash of the light theme, because
> preferences load before the first frame is drawn. The district held, and I'm
> still signed in."

**Do:** Open Settings to show both values retained.

**Do:** **Rotate to landscape.** Scroll. Visit Notifications, Profile and Explore
while rotated.

> "Landscape, no overflow on any screen. We assert every screen at three viewport
> sizes in the test suite."

**Do:** Rotate back to portrait.

> "Gift has browsing."

---

## Segment 4 — Gift Don-Emmanuel
### Explore and search · favourite create and delete

**Do:** Explore tab. Then Search — a partial query, then a nonsense query.

> "Explore and search run off the same catalogue state. Live filtering, and an
> empty state rather than a blank screen."

**Do:** Return to Explore. **Tap the heart on a listing — say its name out loud.**
*(pause)* Switch to the Favourites tab.

> "Favouriting *(name)*. Filled instantly and it's in Favourites — one state
> change, two parts of the UI. That creates a document we'll see shortly."

**Do:** Now **un-favourite listing Y** (the one already favourited before
recording). **Say its name.**

> *(pause)* "And removing *(name of Y)*, which deletes its document. So that's a
> favourite created and a favourite deleted. Nkuba has booking."

> ⚠️ **Leave this state:** the newly hearted listing is favourited; **Y** is not.

---

## Segment 5 — Nkuba Junior Igiraneza
### Booking create · payment validation error · cancellation update

**Do:** Open a listing → **Book** → select a start and end date.

> "Dates on a range calendar, then payment — card or mobile money."

**Do:** Add Card → an **invalid** card number.

> *(pause)* "Rejected by a Luhn checksum, the same algorithm real processors use."

**Do:** Valid test number and expiry. Continue to the price breakdown.

> "Rent, tax and total. Nothing is charged and no card data leaves the device."

**Do:** Confirm. Success sheet appears.

> "Booking created."

**Do:** My Bookings → **cancel that booking**.

> *(pause)* "And cancelled. That's a create and an update on the same record —
> and `status` is the only field that *can* change; the rules block any edit to
> the price or the dates of a booking already agreed."

**Do:** Show the Cancelled tab.

> "That's the app end to end. David will bring up Firebase now and show that
> every one of those actions landed in the backend."

> ⚠️ **Leave this state:** the booking exists with `status: cancelled`.

---

## Segment 6 — David Muotoh
### Firebase Console verification

> **Switch the Zoom share to the browser now.** Keep talking while you do it.

> "Let me bring up the Firebase Console — this is the same project the phone has
> been talking to for the last eight minutes."

### 6.1 The listing that was created and updated

**Do:** Firestore → Data → **`properties`** → open the newest document.

> "Here's the listing published in the first segment. `name` is *Sunny double
> room in Remera* — the title typed on screen. `pricePerMonth` is **210**, which
> is the edited value, not the 190 it was published at. So **create** and
> **update**, both landed."

**Do:** Point at `ownerUid`.

> "`ownerUid` is my Firebase Auth UID. This is the field every security rule
> checks and the field My Listings filters on, which is why the interface can
> never offer an action the backend would refuse."

**Do:** Point at `images[0]`.

> "And the photo is stored inline as a `data:image` URI rather than a Cloud
> Storage URL, because Storage needs the Blaze plan. We say so plainly in the
> report rather than implying we use Storage."

### 6.2 The listing that was deleted

**Do:** Scroll the `properties` document list.

> "And the listing I deleted is not here. You watched it disappear from My
> Listings; it's gone from the collection too. **Delete.**"

### 6.3 The account registered live

**Do:** **Authentication → Users**.

> "The account Aime registered, created during this recording — you can see the
> timestamp."

**Do:** Back to Firestore → **`users`** → that UID.

> "And its profile document. Note what *isn't* in it: there's no `emailVerified`
> field. Verification is read from the Auth token every time, never stored, so
> writing to your own profile can't manufacture a verified badge."

### 6.4 Favourites

**Do:** `users` → your UID → **`favorites`**.

> "The listing Gift favourited is here — and the document ID *is* the listing ID,
> so favouriting twice is idempotent and the body holds nothing but a timestamp.
> The one he removed is absent. Create and delete."

### 6.5 The booking

**Do:** `users` → your UID → **`bookings`** → the newest document.

> "And the booking, with `status` set to `cancelled`. It also stores the
> property's name and price alongside the ID — a deliberate snapshot, because a
> booking is a financial record. If the host later changes their price, this
> booking still shows what was agreed."

> "So every action you saw on the phone is here in the backend: listings created,
> updated and deleted, an account registered, favourites added and removed, and a
> booking created and cancelled — all behind rules that scope every write to its
> owner. Thanks for watching."

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
| **Create** in Firestore, console shown | 1 + 6.1 (listing), 2 + 6.3 (account), 4 + 6.4 (favourite), 5 + 6.5 (booking) |
| **Read** from Firestore | 1, 3, 4 |
| **Update** in Firestore, console shown | 1 + 6.1 (price 190→210), 5 + 6.5 (booking status) |
| **Delete** in Firestore, console shown | 1 + 6.2 (listing), 4 + 6.4 (favourite) |
| State update touching two widgets | 3 (quiz → every card), 4 (heart → Favourites tab) |
| SharedPreferences change → restart → persisted | 3 |
| Validation error with a polite message | 1, 2, 5 |
| Every member speaks | 1–5 |
| No slide deck, no introductions | — |

---

## Why the spoken values matter

Segment 6 only works as evidence if the audience can match each document to
something they watched happen. That is what the "say it out loud" instructions
are for:

| Say it in the app | Prove it in the console |
|---|---|
| "Calling this *Sunny double room in Remera*" | `name` field matches |
| "at 190 a month… editing to **210**" | `pricePerMonth` is 210, not 190 |
| "Favouriting *(listing name)*" | document ID matches that listing |
| "Removing *(listing Y)*" | no document for Y |
| Read the registration email aloud | same address in Authentication → Users |

Skip the spoken values and Segment 6 becomes a tour of a database rather than
proof that the app wrote to it.

---

## Fallback if a take goes wrong

Don't stop unless the app crashes — a stumble costs far less than a visible cut.
If the app crashes, restart from the beginning of that speaker's segment.

If you realise during Segment 6 that a document is missing because an app step
was skipped, **say so and move on**. Do not fake it. An honest "we didn't get to
that one" costs a fraction of what a grader finding a staged document would.

---

## Add-backs if you finish under 10 minutes

Written out so nobody improvises on camera. Add in order.

**1. David, after the "Why?" sheet (~20 s)**
> "The scorer is a plain Dart class in the domain layer — no Flutter or Firebase
> imports, which is why we can unit-test the matching logic directly."

**2. David, at the badges (~15 s)**
> "Every card also carries a Student or Realtor badge. On Facebook you can't tell
> a fellow student from a letting agent; here you always can."

**3. Nelly, after the scores recompute (~20 s)**
> "They all read from a single `LifestyleCubit` instance, registered as a
> singleton so two screens can never disagree about a score."

**4. Nelly, at the theme change (~15 s)**
> "Only `MaterialApp` rebuilds — the rest of the tree isn't torn down, because
> the rebuild is scoped to that one preference."

**5. Aime, after the blank-field rejection (~15 s)**
> "Username at least three characters, password at least six, and nothing reaches
> the network until every field passes."

**6. Nelly, at the rotation (~15 s)**
> "That suite is how we found ten real layout bugs that were invisible in
> portrait."

**7. David, in Segment 6.1 (~20 s)**
> "The rules also pin `ownerUid` as immutable, so a listing can't be handed to
> someone else or claimed by someone else after the fact."
