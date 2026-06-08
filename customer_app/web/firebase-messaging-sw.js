// Background FCM handler for the web build. Shows a notification when a push
// arrives while the tab is closed/backgrounded.
// NOTE: web push also requires a VAPID key (Firebase console > Cloud Messaging >
// Web Push certificates) passed to getToken(vapidKey:) for tokens to be issued.
importScripts(
    'https://www.gstatic.com/firebasejs/10.12.2/firebase-app-compat.js');
importScripts(
    'https://www.gstatic.com/firebasejs/10.12.2/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyBxRHDfeqfjKeE2982uS8sKp1_sLtHXlBE',
  appId: '1:889234012731:android:ec3eed6029461cf8b7fa1e',
  messagingSenderId: '889234012731',
  projectId: 'sarkisbread',
  authDomain: 'sarkisbread.firebaseapp.com',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const n = payload.notification || {};
  self.registration.showNotification(n.title || 'Sarkis Bread', {
    body: n.body || '',
    icon: '/icons/Icon-192.png',
  });
});
