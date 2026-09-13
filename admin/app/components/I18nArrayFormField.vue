<script setup lang="ts">
import { useLocale } from '~/composables/useLocale';
import type { I18nArrayField } from '~/types';

const model = defineModel<I18nArrayField>({ required: true });

const locale = useLocale();

/**
 * The active locale's list.
 *
 * Every edit replaces the whole array through the setter rather than mutating
 * what the getter handed back. The previous version mutated that array in
 * place, which silently did nothing whenever the locale had no entry yet: the
 * `?? []` fallback handed out a throwaway nothing was holding on to.
 */
const items = computed<string[]>({
  get: () => model.value[locale.value] ?? [],
  set: (value: string[]) => {
    model.value = { ...model.value, [locale.value]: value };
  }
});

const setItem = (index: number, value: string) => {
  items.value = items.value.map((item, i) => (i === index ? value : item));
};

const addItem = () => {
  items.value = [...items.value, ''];
};

const removeItem = (index: number) => {
  items.value = items.value.filter((_, i) => i !== index);
};
</script>

<template>
  <UFormField :ui="{ container: 'space-y-2' }">
    <UInput
      v-for="(item, i) in items"
      :key="i"
      :model-value="item"
      class="w-full"
      @update:model-value="setItem(i, String($event))"
    >
      <template #leading>
        {{ i + 1 }}
      </template>

      <template #trailing>
        <UButton
          icon="i-lucide-x"
          variant="link"
          color="error"
          class="cursor-pointer"
          @click="removeItem(i)"
        />
      </template>
    </UInput>

    <UButton
      icon="i-lucide-plus"
      variant="ghost"
      class="cursor-pointer"
      @click="addItem"
    >
      Add step
    </UButton>
  </UFormField>
</template>
