<script setup lang="ts">
import type { ImagenInlineImage } from 'firebase/ai';
import type { ImageTemplate } from '~/types';
import { useImagen } from '~/composables/useImagen';

defineProps<{ template: ImageTemplate; prompt: string }>();

defineEmits<{ choice: [file: ImagenInlineImage] }>();

const { mutateAsync: generateImage, isPending: isGeneratingImage, data } = useImagen();
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
        :src="`data:${data?.[0]?.mimeType};base64,${data?.[0]?.bytesBase64Encoded}`"
        class="w-full aspect-square object-cover cursor-pointer"
        @click="$emit('choice', data?.[0]!)"
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
        @click="$emit('choice', data?.[0]!)"
      />
    </template>
  </UModal>
</template>
