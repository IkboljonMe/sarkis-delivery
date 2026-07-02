/**
 * Sarkis Delivery push notifications (FCM HTTP v1 via firebase-admin).
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
const {onCall} = require("firebase-functions/v2/https");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");
const logger = require("firebase-functions/logger");

initializeApp();
const db = getFirestore();

// ---- Pre-registration phone check ------------------------------------------
// Callable (works unauthenticated): returns whether an E.164 phone number
// already belongs to a registered customer, so the register screen can offer
// "log in" instead of creating a duplicate. Reads run with admin privileges,
// so no user-facing rule needs to expose other people's numbers.
exports.phoneExists = onCall(async (request) => {
  const phone = ((request.data && request.data.phone) || "").toString().trim();
  if (!phone) return {exists: false};
  const snap = await db
      .collection("users")
      .where("phone", "==", phone)
      .limit(1)
      .get();
  return {exists: !snap.empty};
});

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

// Google Cloud Translate key (same key the apps use for in-chat translation).
const TRANSLATE_KEY = "AIzaSyCJBefvwd9C4uKc2wCp8m_n2ZZ0AmyDGRw";

/**
 * Translates [text] into [target] (ISO code). Returns the original text on any
 * failure so a push is never lost just because translation hiccuped.
 */
async function translate(text, target) {
  if (!text || !target) return text;
  try {
    const res = await fetch(
        `https://translation.googleapis.com/language/translate/v2?key=${TRANSLATE_KEY}`,
        {
          method: "POST",
          headers: {"Content-Type": "application/json"},
          body: JSON.stringify({q: text, target, format: "text"}),
        },
    );
    if (!res.ok) return text;
    const data = await res.json();
    const out = data && data.data && data.data.translations &&
      data.data.translations[0] && data.data.translations[0].translatedText;
    return out || text;
  } catch (e) {
    logger.warn("translate failed", {error: String(e)});
    return text;
  }
}

/**
 * Sends a notification to a set of tokens, pruning obvious empties.
 * Returns the number of successful deliveries.
 */
async function sendToTokens(tokens, title, body, data, tag) {
  const list = [...new Set((tokens || []).filter((t) => t && t.length > 10))];
  if (list.length === 0) return 0;
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
  return res.successCount;
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
        // Deliver the push already translated into the customer's language.
        const lang = user.get("language") || "en";
        const body = await translate(preview, lang);
        const ok = await sendToTokens(
            [user.get("fcmToken")],
            "Sarkis Delivery",
            body,
            {type: "chat", topicId, senderName: "Sarkis Delivery"},
            `chat_${topicId}`,
        );
        if (ok > 0) await event.data.ref.update({delivered: true}).catch(() => {});
      } else {
        // Customer -> all admins (admins read in Russian).
        const name = (msg.senderName || "").toString().trim() || "Клиент";
        const body = await translate(preview, "ru");
        const ok = await sendToTokens(
            await adminTokens(),
            `New message from ${name}`,
            body,
            {type: "chat", topicId, senderName: name},
            `chat_${topicId}`,
        );
        if (ok > 0) await event.data.ref.update({delivered: true}).catch(() => {});
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

// ---- New order placed -> notify admins (+ optional auto-accept) ------------
exports.onOrderCreated = onDocumentCreated(
    "orders/{orderId}",
    async (event) => {
      const o = event.data && event.data.data();
      if (!o) return;
      const orderId = event.params.orderId;
      const name = (o.userName || "Клиент").toString();
      const total = Number(o.totalPrice || 0).toFixed(2);

      // Tell every admin a new order arrived.
      await sendToTokens(
          await adminTokens(),
          "Новый заказ",
          `${name} — €${total}`,
          {type: "order", orderId},
          `neworder_${orderId}`,
      );

      // Auto-accept new orders when enabled in settings/config.
      try {
        const cfg = await db.collection("settings").doc("config").get();
        const auto = cfg.exists && cfg.get("autoAcceptOrders") === true;
        if (auto && o.pendingApproval === true) {
          await event.data.ref.update(
              {pendingApproval: false, status: "confirmed"});
        }
      } catch (e) {
        logger.warn("auto-accept failed", {error: String(e)});
      }
    },
);

// ---- New user registered -> notify admins ---------------------------------
exports.onUserCreated = onDocumentCreated(
    "users/{uid}",
    async (event) => {
      const u = event.data && event.data.data();
      if (!u) return;
      const uid = event.params.uid;
      const name = (u.name || u.userName || u.firstName || "Новый пользователь")
          .toString().trim() || "Новый пользователь";

      // Tell every admin a new customer signed up.
      await sendToTokens(
          await adminTokens(),
          "Новый пользователь",
          `${name} зарегистрировался`,
          {type: "user", uid},
          `newuser_${uid}`,
      );
    },
);
