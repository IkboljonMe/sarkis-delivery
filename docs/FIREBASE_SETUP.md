# Firebase Setup — Sarkis Bread

This guide configures the Firebase backend shared by both apps
(`customer_app` and `admin_app`).

---

## 1. Create a Firebase project
1. Go to <https://console.firebase.google.com>.
2. Click **Add project**, name it e.g. `sarkis-bread`, and finish the wizard.
3. (Optional) Disable Google Analytics if you don't need it.

## 2. Enable Authentication
1. In the console: **Build → Authentication → Get started**.
2. Under **Sign-in method**, enable:
   - **Phone** (used by the customer app).
   - **Email/Password** (used by the single admin account).
3. For Phone Auth testing, add test numbers under
   **Authentication → Sign-in method → Phone → Phone numbers for testing**.

## 3. Create Firestore (production mode)
1. **Build → Firestore Database → Create database**.
2. Choose **Production mode**.
3. Select a region close to Germany (e.g. `europe-west3`).

## 4. Apply security rules
1. Open **Firestore → Rules**.
2. Paste the contents of [`../firestore.rules`](../firestore.rules).
3. Replace `YOUR_ADMIN_UID_HERE` with the admin UID (see step 6).
4. Click **Publish**.

## 5. Create the admin account
1. **Authentication → Users → Add user**.
2. Enter the admin email (e.g. `admin@sarkisbread.de`) and a password.
3. Save.

## 6. Copy the Admin UID
1. In **Authentication → Users**, copy the admin account's **User UID**.
2. Paste it into:
   - `admin_app/lib/utils/constants.dart` → `adminUid`
   - `customer_app/lib/utils/constants.dart` → `adminUid`
   - `firestore.rules` → `adminUid()`

## 7. Seed initial data
In **Firestore → Data**, create the following.

### `products` (3 sample Armenian breads)
Create three documents (auto-id) each with:

```jsonc
// Lavash
{
  "name": { "en": "Lavash", "hy": "Լավաշ", "ru": "Лаваш", "tr": "Lavaş", "de": "Lavash" },
  "price": 2.50, "unit": "pack", "maxQty": 10, "isActive": true, "imageUrl": ""
}
// Matnakash
{
  "name": { "en": "Matnakash", "hy": "Մատնաքաշ", "ru": "Матнакаш", "tr": "Matnakaş", "de": "Matnakasch" },
  "price": 3.00, "unit": "piece", "maxQty": 10, "isActive": true, "imageUrl": ""
}
// Gata
{
  "name": { "en": "Gata", "hy": "Գաթա", "ru": "Гата", "tr": "Gata", "de": "Gata" },
  "price": 4.50, "unit": "piece", "maxQty": 10, "isActive": true, "imageUrl": ""
}
```
> The `id` field is filled in automatically by the app on first write; for
> manually seeded docs you may set `id` equal to the document id.

### `delivery_dates` (one per group)
```jsonc
{ "date": <Timestamp: next week>, "group": "Berlin",  "isOpen": true, "createdAt": <serverTimestamp> }
{ "date": <Timestamp: next week>, "group": "Hamburg", "isOpen": true, "createdAt": <serverTimestamp> }
```

### `settings/config`
Create a document with **Document ID = `config`** in the `settings` collection:
```jsonc
{ "maxQty": 10, "minQty": 1, "whatsappNumber": "49XXXXXXXXXX" }
```

## 8. Add Android apps
For **each** app (`customer_app`, `admin_app`):
1. **Project settings → Your apps → Add app → Android**.
2. Use distinct package names, e.g.
   - `de.sarkisbread.customer`
   - `de.sarkisbread.admin`
3. Register the app.

## 9. Download `google-services.json`
1. Download the generated `google-services.json` for each app.
2. Place each in its app's `android/app/` directory:
   - `customer_app/android/app/google-services.json`
   - `admin_app/android/app/google-services.json`

## 10. Enable Cloud Messaging (FCM)
1. **Build → Messaging** is enabled by default with the project.
2. For the **HTTP v1 API** used by `admin_app/lib/services/fcm_service.dart`:
   - **Project settings → Service accounts → Generate new private key**.
   - Either paste the JSON into `fcm_service.dart` (testing only) **or**
     deploy a Cloud Function that sends the message and call it from the app
     (recommended for production — never ship a service-account key in an apk).

## 11. Deploy indexes (optional but recommended)
Using the Firebase CLI:
```bash
firebase deploy --only firestore:indexes
```
or create them manually from [`../firebase_indexes.json`](../firebase_indexes.json).
Firestore will also prompt you with a direct link the first time a query needs
an index.
