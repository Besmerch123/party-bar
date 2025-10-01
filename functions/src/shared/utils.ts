import { Request } from 'firebase-functions/https';
import { type  SupportedLocale, SUPPORTED_LOCALES } from './types';

export function getLocaleHeader(request: Request): SupportedLocale {
  const locale = request.headers['locale']?.toString().split(',')[0].trim().toLowerCase();

  if (!locale || !SUPPORTED_LOCALES.includes(locale as SupportedLocale)) {
    return 'en';
  }

  return locale as SupportedLocale;
}
