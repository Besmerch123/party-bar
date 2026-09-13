<script setup lang="ts">
import type { GenerateImageResponse, ImageTemplate } from '~/types';
import { useGenerateImage } from '~/composables/useGenerateImage';

defineProps<{ template: ImageTemplate; prompt: string }>();

defineEmits<{ choice: [file: GenerateImageResponse] }>();

const { mutateAsync: generateImage, isPending: isGeneratingImage, data } = useGenerateImage();
</script>

<template>
  <UModal
    :dismissible="false"
    :ui="{ content: 'max-w-4xl w-full', footer: 'justify-end gap-2' }"
    @after:enter="generateImage({ template, description: prompt })"
  >
    <template #title>
      Generate Images
    </template>

    <template #body>
      <USkeleton v-if="isGeneratingImage" class="w-full aspect-square rounded-md" />

      <img
        v-else
        :src="`data:${data?.mimeType};base64,${data?.data}`"
        class="w-full aspect-square object-cover cursor-pointer"
        @click="$emit('choice', data!)"
      >
    </template>

    <template #footer>
      <UButton
        label="Regenerate"
        class="cursor-pointer"
        :loading="isGeneratingImage"
        @click="generateImage({ template, description: prompt })"
      />

      <UButton
        label="Accept"
        color="success"
        class="cursor-pointer"
        :disabled="isGeneratingImage"
        @click="$emit('choice', data!)"
      />
    </template>
  </UModal>
</template>
