import {notFound} from 'next/navigation';
import {getRequestConfig} from 'next-intl/server';

const locales = ['en', 'ru', 'tr', 'de', 'hy'];

export default getRequestConfig(async ({locale}) => {
  // If next internally queries getRequestConfig without a locale (e.g favicon, missing routes), default to en
  const safeLocale = locales.includes(locale) ? locale : 'en';

  try {
    const messages = (await import(`./messages/${safeLocale}.json`)).default;
    return { locale: safeLocale, messages };
  } catch (err) {
    console.error("===> Error importing messages JSON:", err.message);
    notFound();
  }
});
