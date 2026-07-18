// Multilingual Privacy Policy & Terms content for Sarko Delivery.
// Languages mirror the apps: English, Russian, German, Turkish, Armenian.

export const LANGS = [
  { code: "en", label: "English" },
  { code: "ru", label: "Русский" },
  { code: "de", label: "Deutsch" },
  { code: "tr", label: "Türkçe" },
  { code: "hy", label: "Հայերեն" },
];

export const DEFAULT_LANG = "en";
export function pickLang(code) {
  return LANGS.some((l) => l.code === code) ? code : DEFAULT_LANG;
}

const UPDATED = "2 July 2026";

export const TERMS = {
  en: {
    title: "Terms of Service",
    updated: `Last updated: ${UPDATED}`,
    sections: [
      { h: "1. Acceptance", p: "By using Sarko Delivery you agree to these terms. Sarko Delivery connects our old and new customers with fresh Armenian bread and related products, delivered to your door." },
      { h: "2. The service", p: "We deliver within the Berlin and Hamburg delivery zones. Orders are prepared for the delivery date you select. Prices are shown in EUR and may change." },
      { h: "3. Orders & payment", p: "Payment is cash on delivery. When you place an order we agree a delivery date and may contact you about it through the app or by phone." },
      { h: "4. Account verification", p: "New accounts are reviewed by our team. We may contact you to confirm your delivery address and explain the details before your account is verified." },
      { h: "5. Cancellations & changes", p: "Orders can be changed or cancelled up to the number of days before delivery shown in the app. After that the order is being prepared and can no longer be changed." },
      { h: "6. Contact", p: "Questions about these terms? Reach us in the app chat or via WhatsApp." },
    ],
  },
  ru: {
    title: "Условия использования",
    updated: `Обновлено: ${UPDATED}`,
    sections: [
      { h: "1. Принятие условий", p: "Используя Sarko Delivery, вы соглашаетесь с этими условиями. Sarko Delivery — это мост между нашими старыми и новыми клиентами: свежий армянский хлеб и сопутствующие товары с доставкой до двери." },
      { h: "2. Сервис", p: "Мы доставляем в зонах Берлина и Гамбурга. Заказы готовятся к выбранной вами дате доставки. Цены указаны в евро и могут меняться." },
      { h: "3. Заказы и оплата", p: "Оплата — наличными при доставке. При оформлении заказа мы согласуем дату доставки и можем связаться с вами через приложение или по телефону." },
      { h: "4. Подтверждение аккаунта", p: "Новые аккаунты проверяются нашей командой. Мы можем связаться с вами, чтобы уточнить адрес доставки и объяснить детали до подтверждения аккаунта." },
      { h: "5. Отмена и изменения", p: "Заказ можно изменить или отменить за указанное в приложении число дней до доставки. После этого заказ готовится и изменению не подлежит." },
      { h: "6. Контакты", p: "Вопросы по условиям? Напишите нам в чат приложения или в WhatsApp." },
    ],
  },
  de: {
    title: "Nutzungsbedingungen",
    updated: `Zuletzt aktualisiert: ${UPDATED}`,
    sections: [
      { h: "1. Zustimmung", p: "Mit der Nutzung von Sarko Delivery stimmen Sie diesen Bedingungen zu. Sarko Delivery verbindet unsere alten und neuen Kunden mit frischem armenischem Brot und zugehörigen Produkten, direkt an Ihre Tür geliefert." },
      { h: "2. Der Dienst", p: "Wir liefern in den Liefergebieten Berlin und Hamburg. Bestellungen werden für das von Ihnen gewählte Lieferdatum vorbereitet. Die Preise sind in EUR angegeben und können sich ändern." },
      { h: "3. Bestellungen & Zahlung", p: "Die Zahlung erfolgt per Barzahlung bei Lieferung. Bei einer Bestellung vereinbaren wir ein Lieferdatum und kontaktieren Sie ggf. über die App oder per Telefon." },
      { h: "4. Kontoverifizierung", p: "Neue Konten werden von unserem Team geprüft. Wir können Sie kontaktieren, um Ihre Lieferadresse zu bestätigen und die Details zu erklären, bevor Ihr Konto verifiziert wird." },
      { h: "5. Stornierung & Änderungen", p: "Bestellungen können bis zu der in der App angegebenen Anzahl von Tagen vor der Lieferung geändert oder storniert werden. Danach wird die Bestellung vorbereitet und kann nicht mehr geändert werden." },
      { h: "6. Kontakt", p: "Fragen zu diesen Bedingungen? Kontaktieren Sie uns im App-Chat oder über WhatsApp." },
    ],
  },
  tr: {
    title: "Kullanım Koşulları",
    updated: `Son güncelleme: ${UPDATED}`,
    sections: [
      { h: "1. Kabul", p: "Sarko Delivery'i kullanarak bu koşulları kabul edersiniz. Sarko Delivery, eski ve yeni müşterilerimizi taze Ermeni ekmeği ve ilgili ürünlerle kapınıza kadar teslimatla buluşturur." },
      { h: "2. Hizmet", p: "Berlin ve Hamburg teslimat bölgelerinde teslimat yapıyoruz. Siparişler seçtiğiniz teslimat tarihine göre hazırlanır. Fiyatlar EUR cinsindendir ve değişebilir." },
      { h: "3. Siparişler & ödeme", p: "Ödeme kapıda nakit olarak yapılır. Sipariş verdiğinizde bir teslimat tarihi belirleriz ve uygulama veya telefon yoluyla sizinle iletişime geçebiliriz." },
      { h: "4. Hesap doğrulama", p: "Yeni hesaplar ekibimiz tarafından incelenir. Hesabınız doğrulanmadan önce teslimat adresinizi onaylamak ve ayrıntıları açıklamak için sizinle iletişime geçebiliriz." },
      { h: "5. İptal & değişiklik", p: "Siparişler, uygulamada gösterilen teslimattan önceki gün sayısına kadar değiştirilebilir veya iptal edilebilir. Sonrasında sipariş hazırlanır ve değiştirilemez." },
      { h: "6. İletişim", p: "Bu koşullarla ilgili sorular mı var? Uygulama sohbetinden veya WhatsApp üzerinden bize ulaşın." },
    ],
  },
  hy: {
    title: "Օգտագործման պայմաններ",
    updated: `Վերջին թարմացումը՝ ${UPDATED}`,
    sections: [
      { h: "1. Համաձայնություն", p: "Օգտագործելով Sarko Delivery-ն՝ դուք համաձայնում եք այս պայմաններին։ Sarko Delivery-ն կամուրջ է մեր հին և նոր հաճախորդների միջև՝ թարմ հայկական հաց և հարակից ապրանքներ առաքմամբ մինչև ձեր դուռ։" },
      { h: "2. Ծառայությունը", p: "Մենք առաքում ենք Բեռլինի և Համբուրգի առաքման գոտիներում։ Պատվերները պատրաստվում են ձեր ընտրած առաքման ամսաթվի համար։ Գները նշված են եվրոյով և կարող են փոխվել։" },
      { h: "3. Պատվերներ և վճարում", p: "Վճարումը՝ կանխիկ առաքման պահին։ Պատվեր կատարելիս մենք համաձայնեցնում ենք առաքման ամսաթիվը և կարող ենք կապվել ձեզ հետ հավելվածի կամ հեռախոսի միջոցով։" },
      { h: "4. Հաշվի հաստատում", p: "Նոր հաշիվները ստուգվում են մեր թիմի կողմից։ Մենք կարող ենք կապվել ձեզ հետ՝ հաստատելու ձեր առաքման հասցեն և բացատրելու մանրամասները մինչ հաշվի հաստատումը։" },
      { h: "5. Չեղարկում և փոփոխություններ", p: "Պատվերները կարելի է փոփոխել կամ չեղարկել առաքումից առաջ հավելվածում նշված օրերի ընթացքում։ Դրանից հետո պատվերը պատրաստվում է և այլևս չի կարող փոփոխվել։" },
      { h: "6. Կապ", p: "Հարցե՞ր այս պայմանների վերաբերյալ։ Կապվեք մեզ հետ հավելվածի չաթում կամ WhatsApp-ով։" },
    ],
  },
};

export const PRIVACY = {
  en: {
    title: "Privacy Policy",
    updated: `Last updated: ${UPDATED}`,
    sections: [
      { h: "1. What we collect", p: "We collect your name, phone number, delivery address and preferred language — the information needed to deliver your orders and contact you about them." },
      { h: "2. How we use it", p: "Your data is used solely to fulfil your orders, verify your account, and contact you about deliveries. We do not sell your data or use it for advertising." },
      { h: "3. Where it is stored", p: "Your data is stored securely in Google Firebase. Access is limited to the Sarko Delivery team for the purposes above." },
      { h: "4. Messages & notifications", p: "Chats with our team and delivery notifications are processed to keep you informed about your orders. Incoming chat messages may be translated into your chosen language." },
      { h: "5. Your rights & deletion", p: "You can view and edit your details in the app at any time. You can delete your account and associated data directly in the app (Settings → Delete account) or by asking us via WhatsApp." },
      { h: "6. Contact", p: "Privacy questions? Reach us in the app chat or via WhatsApp." },
    ],
  },
  ru: {
    title: "Политика конфиденциальности",
    updated: `Обновлено: ${UPDATED}`,
    sections: [
      { h: "1. Какие данные мы собираем", p: "Мы собираем ваше имя, номер телефона, адрес доставки и предпочитаемый язык — информацию, необходимую для выполнения заказов и связи по ним." },
      { h: "2. Как мы их используем", p: "Ваши данные используются исключительно для выполнения заказов, подтверждения аккаунта и связи по доставкам. Мы не продаём ваши данные и не используем их для рекламы." },
      { h: "3. Где они хранятся", p: "Ваши данные надёжно хранятся в Google Firebase. Доступ ограничен командой Sarko Delivery для указанных выше целей." },
      { h: "4. Сообщения и уведомления", p: "Чаты с нашей командой и уведомления о доставке обрабатываются, чтобы держать вас в курсе заказов. Входящие сообщения могут переводиться на выбранный вами язык." },
      { h: "5. Ваши права и удаление", p: "Вы можете просматривать и изменять свои данные в приложении в любой момент. Вы можете удалить аккаунт и связанные данные прямо в приложении (Настройки → Удалить аккаунт) или попросив нас через WhatsApp." },
      { h: "6. Контакты", p: "Вопросы о конфиденциальности? Напишите нам в чат приложения или в WhatsApp." },
    ],
  },
  de: {
    title: "Datenschutzerklärung",
    updated: `Zuletzt aktualisiert: ${UPDATED}`,
    sections: [
      { h: "1. Was wir erheben", p: "Wir erheben Ihren Namen, Ihre Telefonnummer, Ihre Lieferadresse und Ihre bevorzugte Sprache — die Informationen, die zur Lieferung Ihrer Bestellungen und zur Kontaktaufnahme nötig sind." },
      { h: "2. Wie wir sie nutzen", p: "Ihre Daten werden ausschließlich verwendet, um Ihre Bestellungen auszuführen, Ihr Konto zu verifizieren und Sie zu Lieferungen zu kontaktieren. Wir verkaufen Ihre Daten nicht und nutzen sie nicht für Werbung." },
      { h: "3. Wo sie gespeichert werden", p: "Ihre Daten werden sicher in Google Firebase gespeichert. Der Zugriff ist auf das Sarko-Delivery-Team für die oben genannten Zwecke beschränkt." },
      { h: "4. Nachrichten & Benachrichtigungen", p: "Chats mit unserem Team und Lieferbenachrichtigungen werden verarbeitet, um Sie über Ihre Bestellungen zu informieren. Eingehende Nachrichten können in Ihre gewählte Sprache übersetzt werden." },
      { h: "5. Ihre Rechte & Löschung", p: "Sie können Ihre Daten jederzeit in der App einsehen und bearbeiten. Sie können Ihr Konto und die zugehörigen Daten direkt in der App löschen (Einstellungen → Konto löschen) oder uns über WhatsApp darum bitten." },
      { h: "6. Kontakt", p: "Datenschutzfragen? Kontaktieren Sie uns im App-Chat oder über WhatsApp." },
    ],
  },
  tr: {
    title: "Gizlilik Politikası",
    updated: `Son güncelleme: ${UPDATED}`,
    sections: [
      { h: "1. Neleri topluyoruz", p: "Adınızı, telefon numaranızı, teslimat adresinizi ve tercih ettiğiniz dili topluyoruz — siparişlerinizi teslim etmek ve bunlarla ilgili sizinle iletişime geçmek için gereken bilgiler." },
      { h: "2. Nasıl kullanıyoruz", p: "Verileriniz yalnızca siparişlerinizi yerine getirmek, hesabınızı doğrulamak ve teslimatlar hakkında sizinle iletişime geçmek için kullanılır. Verilerinizi satmayız ve reklam için kullanmayız." },
      { h: "3. Nerede saklanıyor", p: "Verileriniz Google Firebase'de güvenle saklanır. Erişim, yukarıdaki amaçlar için Sarko Delivery ekibiyle sınırlıdır." },
      { h: "4. Mesajlar & bildirimler", p: "Ekibimizle yapılan sohbetler ve teslimat bildirimleri, sizi siparişleriniz hakkında bilgilendirmek için işlenir. Gelen mesajlar seçtiğiniz dile çevrilebilir." },
      { h: "5. Haklarınız & silme", p: "Bilgilerinizi uygulamada istediğiniz zaman görüntüleyip düzenleyebilirsiniz. Hesabınızı ve ilgili verileri doğrudan uygulamadan (Ayarlar → Hesabı sil) veya WhatsApp üzerinden bizden isteyerek silebilirsiniz." },
      { h: "6. İletişim", p: "Gizlilik soruları mı var? Uygulama sohbetinden veya WhatsApp üzerinden bize ulaşın." },
    ],
  },
  hy: {
    title: "Գաղտնիության քաղաքականություն",
    updated: `Վերջին թարմացումը՝ ${UPDATED}`,
    sections: [
      { h: "1. Ի՞նչ ենք հավաքում", p: "Մենք հավաքում ենք ձեր անունը, հեռախոսահամարը, առաքման հասցեն և նախընտրած լեզուն՝ ձեր պատվերները առաքելու և դրանց վերաբերյալ ձեզ հետ կապվելու համար անհրաժեշտ տվյալները։" },
      { h: "2. Ինչպես ենք օգտագործում", p: "Ձեր տվյալները օգտագործվում են բացառապես ձեր պատվերները կատարելու, ձեր հաշիվը հաստատելու և առաքումների վերաբերյալ ձեզ հետ կապվելու համար։ Մենք չենք վաճառում ձեր տվյալները և չենք օգտագործում գովազդի համար։" },
      { h: "3. Որտեղ են պահվում", p: "Ձեր տվյալները ապահով պահվում են Google Firebase-ում։ Հասանելիությունը սահմանափակված է Sarko Delivery-ի թիմով՝ վերոնշյալ նպատակների համար։" },
      { h: "4. Հաղորդագրություններ և ծանուցումներ", p: "Մեր թիմի հետ չաթերը և առաքման ծանուցումները մշակվում են՝ ձեզ ձեր պատվերների մասին տեղեկացնելու համար։ Մուտքային հաղորդագրությունները կարող են թարգմանվել ձեր ընտրած լեզվով։" },
      { h: "5. Ձեր իրավունքները և ջնջումը", p: "Դուք կարող եք ցանկացած պահի դիտել և խմբագրել ձեր տվյալները հավելվածում։ Դուք կարող եք ջնջել ձեր հաշիվը և հարակից տվյալները անմիջապես հավելվածում (Կարգավորումներ → Ջնջել հաշիվը) կամ WhatsApp-ով մեզ խնդրելով։" },
      { h: "6. Կապ", p: "Գաղտնիության հարցե՞ր։ Կապվեք մեզ հետ հավելվածի չաթում կամ WhatsApp-ով։" },
    ],
  },
};
