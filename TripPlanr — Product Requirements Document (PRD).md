**TRIPPLANNR** **—** **Updated** **Product** **Requirements**
**Document** **(PRD)**

**Version:** MVP 2.0 (Native iOS Pivot)

**Owner:** Marlon

**Platform:** Native iOS App (SwiftUI)

**Backend:** Firebase (Firestore + Functions optional), Google Places
API, Gemini/Claude optional for text generation

**Primary** **Objective:** Enable groups to choose a meetup location in
under 60 seconds.

**1.** **Product** **Overview**

TripPlannr is a native iOS app that allows groups to quickly choose a
place to meet—usually for food, drinks, coffee, or sightseeing—with
minimal effort. The app is activated when a user shares a TripPlannr
link with their friends. Friends tap the link, enter their name,
optionally add preferences, and submit a one-time location. Once enough
people have joined, the app recommends the top three fair, relevant
meetup spots and generates a poll so the group can democratically
choose.

This app completely avoids heavy Apple API usage (iMessage extensions,
Find My entitlements) and focuses on a smooth, fast in-app flow.

**2.** **Core** **Principles** **of** **the** **MVP**

> 1\. **Decide** **in** **under** **60** **seconds.**
>
> 2\. **One-time** **location** **sharing,** **not** **tracking.**
>
> 3\. **No** **accounts** **required.**
>
> 4\. **Minimal** **questionnaire.**
>
> 5\. **Three** **venue** **recommendations,** **max.**
>
> 6\. **Drag-up/drag-down** **interface** **(map** **+** **list).**
>
> 7\. **Real-time** **group** **session** **via** **link.**

**3.** **User** **Flow**

**Step** **1** **—** **Host** **creates** **a** **session**

> ● Host opens the app
>
> ● Taps “Start a Trip”
>
> ● Chooses broad category:
>
> ○ Food
>
> ○ Drinks
>
> ○ Coffee/Tea
>
> ○ Dessert
>
> ○ Scenic Spot
>
> ○ No preference
>
> ● App generates a **trip** **link** to share with friends

**Step** **2** **—** **Friends** **join** **via** **link**

> ● Friends tap the link
>
> ● Are taken into the app (universal link)
>
> ● They enter:
>
> ○ Name
>
> ○ Auto avatar is assigned
>
> ○ One-time location permission
>
> ○ Optional preferences:
>
> ■ Activity type
>
> ■ Diet
>
> ■ Price sensitivity
>
> ■ Travel mode (walk, drive, Uber)

**Step** **3** **—** **Group** **session** **screen**

UI is split into two panels:

**Top** **Panel:**

> **Map**

Shows:

> ● Participants (one-time location snapshot markers)
>
> ● Drag-down mode (expanded map)
>
> ● After recommendations: venue pins appear

**Bottom** **Panel:**

> **Group** **List**

Shows:

> ● Participant name
>
> ● Avatar
>
> ● Their preferences
>
> ● Travel mode icon
>
> ● Drag-up mode shows full poll/options list

Updates in real-time as people join.

**Step** **4** **—** **Host** **triggers** **“Generate** **Places”**

Once either:

> ● Everyone has joined, or
>
> ● Minimum 3 members joined, or
>
> ● Timeout reached (2-minute auto-detect)

The app:

> ● Computes midpoint/fairness
>
> ● Calls Google Places API for candidates
>
> ● Ranks by:
>
> ○ Distance fairness
>
> ○ Relevance
>
> ○ Price
>
> ○ Rating
>
> ○ Availability
>
> ● Selects **top** **3**

**Step** **5** **—** **Poll** **appears**

> ● A clean, simple 3-option poll pops up
>
> ● Each option includes:
>
> ○ Name
>
> ○ Rating
>
> ○ Price
>
> ○ Distance for each user (relative, not exact)
>
> ○ Short vibe description

**Step** **6** **—** **Group** **votes**

> ● Majority wins
>
> ● Host can break ties
>
> ● Final result displayed

**4.** **Technical** **Architecture** **(MVP)**

**4.1** **Frontend**

Native iOS App (SwiftUI)

> ● Core views:
>
> ○ Home Screen (Start Session)
>
> ○ Join Session (via link)
>
> ○ Group Session (map + list)
>
> ○ Poll View
>
> ○ Place Details Modal
>
> ● Uses:
>
> ○ MapleKit
>
> ○ CoreLocation for one-time permission
>
> ○ SwiftUI bottom sheet for drag-up panel

**4.2** **Backend**

Use Firebase:

**Firestore**

> ● Session documents:
>
> ○ Host
>
> ○ Timestamp
>
> ○ Category
>
> ○ Options (optional)
>
> ○ Poll state
>
> ● Participants subcollection:
>
> ○ Name
>
> ○ Preferences
>
> ○ One-time location

**Firebase** **Functions** **(optional)**

> ● Trigger venue generation
>
> ● Handle poll logic

**4.3** **External** **APIs**

> ● **Google** **Places** **API**
>
> ○ Nearby Search
>
> ○ Text Search
>
> ○ Place Details
>
> ● Optional: Clifford AI (Gemini/Claude) for short summaries

**5.** **Recommendation** **Engine** **Logic**

**Input:**

> ● Participant locations
>
> ● Preferences
>
> ● Category
>
> ● Travel modes

**Processing:**

> 1\. Compute centroid (simple or weighted)
>
> 2\. Query Google Places (radius based)
>
> 3\. Score each place using:
>
> ○ Fairness score (minimizing max travel differential)
>
> ○ Relevance score (matching activity/prefs)
>
> ○ Rating
>
> ○ Price
>
> ○ Hours
>
> 4\. Select top 3

**Output:**

> ● 3 recommended venues
>
> ● Metadata for poll
>
> ● Pin positions for map

**6.** **Poll** **Logic**

Poll supports:

> ● Multiple votes
>
> ● Host tie-breaking
>
> ● Live updates
>
> ● Locking results
>
> ● Optional recount / recompute button

**7.** **Privacy** **&** **Data** **Policy**

> ● One-time location
>
> ● Location deleted when trip ends
>
> ● No tracking
>
> ● No background location
>
> ● No chat access
>
> ● No account needed

**8.** **Non-Goals** **for** **MVP**

> ● Continuous GPS tracking
>
> ● iMessage integration
>
> ● Calendar sync
>
> ● Payment integration
>
> ● Ride-sharing pairing
>
> ● Multi-stop itineraries
>
> ● Advanced AI reasoning

**9.** **Success** **Metrics** **(MVP)**

**Quantitative:**

> ● 90% session creation success
>
> ● \<10 second venue generation
>
> ● \<3 taps to join trip
>
> ● 80% users complete flow once joined

**Qualitative:**

> ● “This was faster than deciding ourselves.”
>
> ● “This is easier than texting.”
