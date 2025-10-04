<script setup lang="ts">
import { useLocale } from '~/composables/useLocale';

const locale = useLocale();
</script>

<template>
  <UFieldGroup orientation="horizontal">
    <UButton
      color="neutral"
      :variant="locale === 'en' ? 'solid' : 'outline'"
      label="en"
      @click="locale = 'en'"
    />
    <UButton
      color="neutral"
      :variant="locale === 'uk' ? 'solid' : 'outline'"
      label="uk"
      @click="locale = 'uk'"
    />
  </UFieldGroup>
</template>
