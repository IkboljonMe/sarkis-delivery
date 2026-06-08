/**
 * Sarkis Bread push notifications (FCM HTTP v1 via firebase-admin).
 *
 * Triggers:
 *  - New chat message  -> notify the other party (customer <-> admins)
 *  - Order status change -> notify the ordering customer
 *
 * The service-account credentials live on Google's servers (Application Default
 * Credentials), so no key ships inside the apps.
 */
const {onDocumentCreated, onDocumentUpdated} =
  require("firebase-functions/v2/firestore");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");
const logger = require("firebase-functions/logger");

initializeApp();
const db = getFirestore();

// ---- Localized order-status copy -------------------------------------------
const STATUS_TEXT = {
  pending: {
    en: "Order received", de: "Bestellung erhalten", ru: "Заказ получен",
    tr: "Sipariş alındı", hy: "Պատվերն ընդունված է",
  },
  confirmed: {
    en: "Your order is confirmed", de: "Ihre Bestellung ist bestätigt",
    ru: "Ваш заказ подтверждён", tr: "Siparişiniz onaylandı",
    hy: "Ձեր պատվերը հաստատված է",
  },
  on_the_way: {
    en: "Your order is on the way", de: "Ihre Bestellung ist unterwegs",
    ru: "Ваш заказ в пути", tr: "Siparişiniz yolda",
    hy: "Ձեր պատվերը ճանապարհին է",
  },
  delivered: {
    en: "Your order was delivered", de: "Ihre Bestellung wurde geliefert",
    ru: "Ваш заказ доставлен", tr: "Siparişiniz teslim edildi",
    hy: "Ձեր պատվերը առաքվել է",
  },
  cancelled: {
    en: "Your order was cancelled", de: "Ihre Bestellung wurde storniert",
    ru: "Ваш заказ отменён", tr: "Siparişiniz iptal edildi",
    hy: "Ձեր պատվերը չեղարկվել է",
  },
};

const pick = (map, lang) => (map && (map[lang] || map.en)) || "";

/** Sends a notification to a set of tokens, pruning obvious empties. */
async function sendToTokens(tokens, title, body, data, tag) {
  const list = [...new Set((tokens || []).filter((t) => t && t.length > 10))];
  if (list.length === 0) return;
  const res = await getMessaging().sendEachForMulticast({
    tokens: list,
    notification: {title, body},
    data: data || {},
    android: {
      priority: "high",
      // tag groups a chat's notifications: a new message replaces the
      // previous one instead of stacking (Telegram-style, one per chat).
      collapseKey: tag,
      notification: tag ? {tag} : undefined,
    },
    apns: {payload: {aps: {sound: "default"}}},
  });
  logger.info(`sent ${res.successCount}/${list.length}`, {title});
}

/** Tokens of every admin user. */
async function adminTokens() {
  const snap = await db.collection("users").where("isAdmin", "==", true).get();
  return snap.docs.map((d) => d.get("fcmToken")).filter(Boolean);
}

// ---- New chat message ------------------------------------------------------
exports.onChatMessageCreated = onDocumentCreated(
    "messages/{topicId}/messages/{msgId}",
    async (event) => {
      const msg = event.data && event.data.data();
      if (!msg) return;
      // Status-update messages are posted into the chat for visibility but
      // their push is handled by onOrderStatusChanged — avoid double-notifying.
      if (msg.silent === true) return;
      const topicId = event.params.topicId; // == customer userId
      let text = (msg.text || "").toString();
      if (!text) {
        // Media messages have no text — show a content label instead of blank.
        if (msg.type === "image") text = "📷 Фото";
        else if (msg.type === "voice") text = "🎤 Голосовое сообщение";
        else if (msg.type === "video") text = "🎥 Видео";
      }
      const preview = text.length > 80 ? `${text.slice(0, 79)}…` : text;

      if (msg.isFromAdmin === true) {
        // Admin -> the customer who owns this topic.
        const user = await db.collection("users").doc(topicId).get();
        if (!user.exists) return;
        await sendToTokens(
            [user.get("fcmToken")],
            "Sarkis Bread",
            preview,
            {type: "chat", topicId, senderName: "Sarkis Bread"},
            `chat_${topicId}`,
        );
      } else {
        // Customer -> all admins.
        const name = (msg.senderName || "").toString().trim() || "Клиент";
        await sendToTokens(
            await adminTokens(),
            `New message from ${name}`,
            preview,
            {type: "chat", topicId, senderName: name},
            `chat_${topicId}`,
        );
      }
    },
);

// ---- Order status change ---------------------------------------------------
exports.onOrderStatusChanged = onDocumentUpdated(
    "orders/{orderId}",
    async (event) => {
      const before = event.data.before.data();
      const after = event.data.after.data();
      if (!before || !after) return;
      if (before.status === after.status) return; // only on real changes

      const userId = after.userId;
      if (!userId) return;
      const user = await db.collection("users").doc(userId).get();
      if (!user.exists) return;
      const token = user.get("fcmToken");
      if (!token) return;

      const lang = user.get("language") || "en";
      const body = pick(STATUS_TEXT[after.status], lang) || "Order updated";
      const shortId = String(event.params.orderId).slice(0, 6).toUpperCase();

      await sendToTokens(
          [token],
          `Order #${shortId}`,
          body,
          {type: "order", orderId: event.params.orderId, status: after.status},
          `order_${event.params.orderId}`,
      );
    },
);
