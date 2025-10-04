<script setup lang="ts">
import { useLocale } from '~/composables/useLocale';
import type { I18nField } from '../../../functions/src/shared/types';

const model = defineModel<I18nField>({ required: true });

const locale = useLocale();

const setModelValue = (value?: string) => {
  model.value[locale.value] = value;
};

const inputModel = computed({
  get: () => model.value[locale.value],
  set: setModelValue
});
</script>

<template>
  <UFormField>
    <slot :value="inputModel" :set-value="setModelValue">
      <UInput
        v-model="inputModel"
      />
    </slot>
  </UFormField>
</template>
