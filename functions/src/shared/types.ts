/**
 * Supported locales in the app
 */
export const SUPPORTED_LOCALES = ['en', 'uk'] as const;

export type SupportedLocale = typeof SUPPORTED_LOCALES[number];

export type I18nField = Partial<Record<SupportedLocale, string>>;

export type I18nArrayField = Partial<Record<SupportedLocale, string[]>>;
