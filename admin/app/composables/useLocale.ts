import { useStorage } from '@vueuse/core'
import type { SupportedLocale } from '../../../functions/src/shared/types'

export function useLocale() {
  return useStorage<SupportedLocale>('locale', () => 'en')
}
