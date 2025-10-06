<script setup lang="ts">
import { useLocale } from '~/composables/useLocale';
import type { I18nArrayField } from '~/types';

const model = defineModel<I18nArrayField>({ required: true });

const locale = useLocale();

const inputModel = computed({
  get: () => model.value[locale.value] ?? [],
  set: () => {}
});
</script>

<template>
  <UFormField :ui="{ container: 'space-y-2' }">
    <UInput
      v-for="(_, i) in inputModel"
      :key="i"
      v-model="inputModel[i]"
    >
      <template #leading>
        {{ i +1 }}
      </template>

      <template #trailing>
        <UButton
          icon="i-lucide-x"
          variant="link"
          color="error"
          class="cursor-pointer"
          @click="inputModel.splice(i, 1)"
        />
      </template>
    </UInput>

    <UButton
      icon="i-lucide-plus"
      variant="ghost"
      @click="inputModel.push('')"
    >
      Add step
    </UButton>
  </UFormField>
</template>
