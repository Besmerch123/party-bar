<script setup lang="ts">
import type { ButtonProps } from '@nuxt/ui';

defineProps<{ imageSrc?: string; title?: string; subtitle?: string; to?: ButtonProps['to'] }>();

defineEmits<{
  (e: 'remove'): void;
}>();
</script>

<template>
  <div class="rounded-xl overflow-hidden shadow-sm bg-elevated relative group">
    <UButton
      icon="i-lucide-x"
      color="error"
      variant="ghost"
      class="absolute top-0 right-0 cursor-pointer z-10 invisible group-hover:visible"
      @click="$emit('remove')"
    />

    <div class="bg-muted aspect-square mb-2 flex items-center justify-center">
      <img
        v-if="imageSrc"
        :src="imageSrc"
        class="w-full h-full object-contain"
      >
      <UIcon v-else name="i-lucide-wine" class="size-16 text-muted mb-2" />
    </div>

    <h3 class="text-md font-semibold mb-2 px-2">
      <NuxtLink
        :to
        target="_blank"
      >
        {{ title }}
      </NuxtLink>
    </h3>
    <p class="text-sm text-muted px-2 mb-2">
      {{ subtitle }}
    </p>
  </div>
</template>
