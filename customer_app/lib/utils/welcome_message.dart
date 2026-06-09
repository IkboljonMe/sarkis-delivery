/// Localized welcome message sent automatically from the admin (Sarkis) to a
/// customer the first time they register. Falls back to English.
class WelcomeMessage {
  WelcomeMessage._();

  static const String senderName = 'Sarkis';

  static String forLang(String lang) => _messages[lang] ?? _messages['en']!;

  static const Map<String, String> _messages = {
    'en':
        'Hi! 👋 I\'m Sarkis, the admin of Sarkis Bread.\n\n'
            'I\'ll keep you posted right here about your order status — when it\'s '
            'confirmed, on the way, and delivered. If a delivery is ever delayed, '
            'I\'ll let you know here first.\n\n'
            'This is also your support chat. If anything is wrong with your order, '
            'or the bread doesn\'t arrive in good shape, just text me — you can also '
            'send 🎤 voice messages and 📷 photos of the product. I\'m happy to help. '
            'Enjoy your fresh bread! 🥖',
    'ru':
        'Здравствуйте! 👋 Я Саркис, администратор Sarkis Bread.\n\n'
            'Здесь я буду сообщать вам о статусе заказа — когда он подтверждён, в пути '
            'и доставлен. Если доставка задержится, я первым делом напишу вам сюда.\n\n'
            'Это также чат поддержки. Если с заказом что-то не так или хлеб пришёл не в '
            'лучшем виде — просто напишите мне. Можно отправлять 🎤 голосовые сообщения '
            'и 📷 фото продукта. Буду рад помочь. Приятного аппетита! 🥖',
    'de':
        'Hallo! 👋 Ich bin Sarkis, der Admin von Sarkis Bread.\n\n'
            'Hier halte ich dich über deinen Bestellstatus auf dem Laufenden — '
            'bestätigt, unterwegs und geliefert. Sollte eine Lieferung sich '
            'verspäten, erfährst du es zuerst hier.\n\n'
            'Das ist auch dein Support-Chat. Wenn mit deiner Bestellung etwas nicht '
            'stimmt oder das Brot nicht gut ankommt, schreib mir einfach — du kannst '
            'auch 🎤 Sprachnachrichten und 📷 Fotos des Produkts senden. Ich helfe '
            'gerne. Guten Appetit! 🥖',
    'tr':
        'Merhaba! 👋 Ben Sarkis, Sarkis Bread yöneticisiyim.\n\n'
            'Sipariş durumunu burada bildireceğim — onaylandığında, yolda ve teslim '
            'edildiğinde. Teslimat gecikirse ilk olarak buradan haber veririm.\n\n'
            'Burası aynı zamanda destek sohbetin. Siparişinle ilgili bir sorun olursa '
            'ya da ekmek iyi durumda gelmezse bana yaz — 🎤 sesli mesaj ve 📷 ürün '
            'fotoğrafı da gönderebilirsin. Yardımcı olmaktan memnuniyet duyarım. Afiyet '
            'olsun! 🥖',
    'hy':
        'Բարև! 👋 Ես Սարկիսն եմ՝ Sarkis Bread-ի ադմինը։\n\n'
            'Այստեղ կտեղեկացնեմ ձեր պատվերի կարգավիճակի մասին՝ երբ այն հաստատվի, '
            'ճանապարհին լինի և առաքվի։ Եթե առաքումը ուշանա, առաջինը կգրեմ ձեզ այստեղ։\n\n'
            'Սա նաև ձեր աջակցության զրույցն է։ Եթե պատվերի հետ խնդիր լինի կամ հացը լավ '
            'վիճակում չհասնի, պարզապես գրեք ինձ — կարող եք ուղարկել նաև 🎤 ձայնային '
            'հաղորդագրություններ և 📷 ապրանքի լուսանկարներ։ Ուրախ կլինեմ օգնել։ Բարի '
            'ախորժակ! 🥖',
  };
}
