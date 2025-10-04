import { CallableRequest, Request } from 'firebase-functions/https';
import { type  SupportedLocale, SUPPORTED_LOCALES } from './types';

export function getLocaleHeader(request: Request | CallableRequest): SupportedLocale {
  const headers = isCallableRequest(request) ? request?.rawRequest?.headers : request.headers;

  const locale = headers['locale']?.toString().split(',')[0].trim().toLowerCase();

  if (!locale || !SUPPORTED_LOCALES.includes(locale as SupportedLocale)) {
    return 'en';
  }

  return locale as SupportedLocale;
}

function isCallableRequest(request: Request | CallableRequest): request is CallableRequest {
  return request && typeof request === 'object' && 'data' in request && 'auth' in request;
}
