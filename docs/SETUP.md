# Sarkis Bread v2 — Backend Setup

The two apps (`customer_app`, `admin_app`) share one Firebase project.

---

## 1. Create the Firebase project
Console → **Add project** → e.g. `sarkis-bread`.

## 2. Enable Authentication
**Build → Authentication → Sign-in method**:
- Enable **Phone** (customer login). Add test numbers under
  *Phone numbers for testing* (e.g. `+49 170 1234567 / 123456`).
- Enable **Email/Password** (admin login).
- **Settings → SMS region policy** → allow **Germany (+49)**.
- **Settings → Authorized domains** → keep `localhost` for web testing.

## 3. Firestore (production mode)
**Build → Firestore Database → Create** → production mode, region `europe-west3`.

## 4. Apply rules + indexes
- **Rules** tab → paste [`../firestore.rules`](../firestore.rules) → **Publish**.
- Indexes: `firebase deploy --only firestore:indexes` using
  [`../firebase_indexes.json`](../firebase_indexes.json), or let Firestore
  prompt you with the create-index link the first time a query runs.

## 5. Create the admin account
1. **Authentication → Users → Add user** (email + password).
2. Copy its **UID**.
3. **Firestore → Data** → create `users/{thatUid}` with:
   ```jsonc
   { "name": "Admin", "isAdmin": true, "group": "Berlin", "language": "ru" }
   ```
   The `isAdmin: true` flag is what unlocks admin access (enforced by rules).

## 6. Seed initial data
You can seed by hand, or simply **log into the admin app** and use the
Products / Shifts screens — they write straight to Firestore.

Minimum to make the customer app show content:
- `categories` — at least 1 active (e.g. Bread, Cheese) with a `name` map
  `{en,hy,ru,tr,de}`, `isActive: true`, `sortOrder`.
- `products` — a few active, each with `categoryId`, `name` map, `price`,
  `unit`, `maxQty`, `isActive: true`.
- `shifts` — one per group with `group`, `date` (Timestamp), `label`,
  `isOpen: true`.
- `settings/config` — `{ maxQty: 10, minQty: 1, adminWhatsapp: "+49..." }`.

## 7. Register apps + config
- **Project settings → Add app**: add a **Web** app (for `flutter run -d chrome`)
  and **Android** apps for `customer_app` and `admin_app`.
- For Android, download each `google-services.json` into
  `<app>/android/app/google-services.json`.
- The apps initialize Firebase from `lib/demo_firebase_options.dart`
  (already populated with the project's web/Android config). Replace with your
  own `flutterfire configure` output for production, and register a dedicated
  **Web app** appId for production web phone-auth.

## 8. Cloud Messaging
- FCM is enabled with the project.
- The admin app sends pushes via the **HTTP v1 API**
  (`admin_app/lib/services/fcm_service.dart`). For production, deploy a Cloud
  Function holding the service-account key and call it from the app — never
  ship a service-account key inside an apk.

## 9. Constants to update
- `customer_app/lib/utils/constants.dart` → `adminWhatsappNumber`, `adminUid`.
- `admin_app/lib/utils/constants.dart` → `adminWhatsappNumber`.
