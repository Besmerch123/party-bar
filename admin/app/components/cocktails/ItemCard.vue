<script setup lang="ts">
defineProps<{ imageSrc?: string; title?: string; subtitle?: string }>();
</script>

<template>
  <div class="rounded-xl overflow-hidden shadow-sm bg-elevated">
    <div class="bg-muted aspect-square mb-2 flex items-center justify-center">
      <img
        v-if="imageSrc"
        :src="imageSrc"
        class="w-full h-full object-contain"
      >
      <UIcon v-else name="i-lucide-wine" class="size-16 text-muted mb-2" />
    </div>

    <h3 class="text-md font-semibold mb-2 px-2">
      {{ title }}
    </h3>
    <p class="text-sm text-muted px-2 mb-2">
      {{ subtitle }}
    </p>
  </div>
</template>
