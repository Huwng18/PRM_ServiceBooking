# PRM393 Technical Report — Service Booking

> Template to adapt with your team's actual development evidence and implementation.

## 1. Team introduction
- Team (3–5 members): [fill]
- Roles & contributions: [fill]

## 2. Case study
Customers need to browse available services, select date/time and track appointments without calling providers. The prototype focuses on consumer booking on a single device; real provider availability is not yet connected.

## 3. Business analysis / system design
### Actors
- Customer: mock sign-in, browse/filter, favorite services, create, view, reschedule and cancel own bookings.
### Functional requirements
- FR01 Mock login/logout and session restore.
- FR02 Browse and search predefined services.
- FR03 View service details and pricing.
- FR04 Create booking for a future timeslot from 08:00–18:00.
- FR05 Detect overlap for the same service/user under prototype rules.
- FR06 Display booking history, allow cancelling future booking.
- FR07 Keep bookings after app restart.
- FR08 Persistent favorites and display name per email.
- FR09 Reschedule future bookings without changing ID; rebook cancelled/past services.
- FR10 Upcoming/past/cancelled groups and in-app upcoming reminders.
### Non-functional requirements
- Simple mobile navigation and human-readable errors.
- State synchronization through Provider.
- Offline local-only demo storage; not secure for production.
- Unit and widget tests.
### Architecture
UI/screens -> Provider/ChangeNotifier -> BookingRepository -> SQLite database.
### Data model
Service(id, name, category, description, durationMinutes, priceVnd).
Booking(id, userEmail, serviceId, startAt, note, cancelled).
### Known design limitations
No real user verification, shared booking inventory, server-side concurrency, encryption, admin UI, push notifications or real payment. SQLite is the implemented local database engine.

## 4. Development and deployment
Flutter/Dart, Material 3, Provider, SharedPreferences, Android build instructions in README. SQLite is used for booking persistence; document schema and screenshots from your own build. Record screenshots and logs from the actual debug build. Release signing/build remain unverified until the team performs them.

## 5. Demonstration (15 minutes)
Use [DEMO_15_MIN.md](DEMO_15_MIN.md) for the implemented 15-minute flow. See [qa/VERIFICATION.md](qa/VERIFICATION.md) for measured checks and screenshots. Add team-specific evidence.

## 6. Conclusion & discussion
Pros: small offline prototype, clear booking flow, separable layers, state management. Cons: mock auth, no remote backend, no real availability, local-only records. Future: server/database, administrative approvals, role management, notifications.

## 7. Contribution
Fill actual percentages for case study, business analysis, design, implementation, documentation. Must reflect real team work, do not copy sample percentages.

## Submission checklist
- Source ZIP; code comments and citations for reused sources.
- PDF report; team roles, complete functional/nonfunctional requirements, UI flow, architecture and database/API design.
- Build signed/unsigned release APK or AAB, proof of running in release mode.
- Unit test + widget test outputs, demo slides and 15-minute defense.
