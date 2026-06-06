# Google Cloud Setup — Geocoding API

The customer app validates addresses with the **Google Geocoding API**
(`customer_app/lib/services/geocoding_service.dart`).

> Your Firebase project is also a Google Cloud project — use the same project.

---

## 1. Enable the Geocoding API
1. Go to <https://console.cloud.google.com>.
2. Select the project that backs your Firebase app (top project picker).
3. **APIs & Services → Library**.
4. Search for **Geocoding API** → **Enable**.
   - (Optional) Also enable **Maps SDK for Android** if you later embed maps.
     The admin navigation only opens the external Maps app via `url_launcher`,
     so the SDK is not strictly required.

## 2. Create an API key
1. **APIs & Services → Credentials → Create credentials → API key**.
2. Copy the generated key.

## 3. Restrict the API key
1. Click the new key to edit it.
2. **Application restrictions → Android apps**:
   - Add your customer app package name (e.g. `de.sarkisbread.customer`).
   - Add the SHA-1 fingerprint of your signing key:
     ```bash
     keytool -list -v -keystore ~/.android/debug.keystore \
       -alias androiddebugkey -storepass android -keypass android
     ```
3. **API restrictions → Restrict key** → select **Geocoding API**.
4. Save.

> The Geocoding **web service** is called over HTTPS from the device. Android
> application restrictions apply when the key is sent from your registered app.
> For server-side calls, prefer an IP-restricted key in a backend instead.

## 4. Add the key to the customer app
Edit `customer_app/lib/utils/constants.dart`:
```dart
static const String googleGeocodingApiKey = 'PASTE_YOUR_KEY_HERE';
```

## 5. (If embedding Maps later) Android manifest
Add to `customer_app/android/app/src/main/AndroidManifest.xml` inside
`<application>`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="PASTE_YOUR_KEY_HERE"/>
```

## 6. Billing
The Geocoding API requires a billing account on the Google Cloud project.
Google provides a recurring free tier credit; monitor usage under
**Billing → Reports**.
