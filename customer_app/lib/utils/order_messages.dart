/// Localized "thank you for your order" message, sent from the admin (Sarkis)
/// into the customer's chat as an order attachment right after they order.
class OrderMessages {
  OrderMessages._();

  static String thankYou(String lang) => _thankYou[lang] ?? _thankYou['en']!;

  static const Map<String, String> _thankYou = {
    'en': 'Thank you for ordering from us! 🥖 We received your order and will '
        'confirm it shortly. Tap below to see the details.',
    'ru': 'Спасибо за заказ! 🥖 Мы получили ваш заказ и скоро его подтвердим. '
        'Нажмите ниже, чтобы посмотреть детали.',
    'de': 'Danke für deine Bestellung! 🥖 Wir haben sie erhalten und bestätigen '
        'sie in Kürze. Tippe unten für die Details.',
    'tr': 'Sipariş verdiğiniz için teşekkürler! 🥖 Siparişinizi aldık ve kısa '
        'süre içinde onaylayacağız. Detaylar için aşağıya dokunun.',
    'hy': 'Շնորհակալություն պատվերի համար! 🥖 Ստացանք ձեր պատվերը և շուտով '
        'կհաստատենք այն։ Սեղմեք ներքևում՝ մանրամասները տեսնելու համար։',
  };
}
