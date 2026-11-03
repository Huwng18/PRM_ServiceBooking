# PRM393 Technical Report — Service Booking

> Template to adapt with your team's actual development evidence and implementation.

## 1. Team introduction
- Team (3–5 members): [fill]
- Roles & contributions: [fill]

## 2. Case study
Customers need to browse available services, select date/time and track appointments without calling providers. The prototype focuses on consumer booking on a single device; real provider availability is not yet connected.

## 3. Business analysis / system design
### Actors
- Customer: mock sign-in, browse, search, create, view and cancel own bookings.
### Functional requirements
- FR01 Mock login/logout and session restore.
- FR02 Browse and search predefined services.
- FR03 View service details and pricing.
- FR04 Create booking for a future timeslot from 08:00–18:00.
- FR05 Detect overlap for the same service/user under prototype rules.
- FR06 Display booking history, allow cancelling future booking.
- FR07 Keep bookings after app restart.
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
No real user verification, shared booking inventory, server-side concurrency, encryption, database engine, admin UI or real payment.

## 4. Development and deployment
Flutter/Dart, Material 3, Provider, SharedPreferences, Android build instructions in README. SQLite is used for booking persistence; document schema and screenshots from your own build. Screenshot release APK on device and include build logs.

## 5. Demonstration (15 minutes)
1 min scenario, 2 min architecture, 7 min core flow, 2 min state/persistence, 2 min unit/widget testing, 1 min conclusion. Include screenshots and outputs recorded from local environment.

## 6. Conclusion & discussion
Pros: small offline prototype, clear booking flow, separable layers, state management. Cons: mock auth, no remote backend, no real availability, local-only records. Future: server/database, administrative approvals, role management, notifications.

## 7. Contribution
Fill actual percentages for case study, business analysis, design, implementation, documentation. Must reflect real team work, do not copy sample percentages.

## Submission checklist
- Source ZIP; code comments and citations for reused sources.
- PDF report; team roles, complete functional/nonfunctional requirements, UI flow, architecture and database/API design.
- Build signed/unsigned release APK or AAB, proof of running in release mode.
- Unit test + widget test outputs, demo slides and 15-minute defense.
