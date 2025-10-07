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
      <div class="grid grid-cols-2 gap-4">
        <template v-if="isGeneratingImage">
          <USkeleton v-for="i in 4" :key="i" class="w-full aspect-square rounded-md" />
        </template>

        <template v-else>
          <img
            v-for="(image, i) in data || []"
            :key="i"
            :src="`data:${image.mimeType};base64,${image.bytesBase64Encoded}`"
            class="w-full aspect-square object-cover cursor-pointer"
            @click="$emit('choice', image)"
          >
        </template>
      </div>
    </template>

    <template #footer>
      <UButton
        label="Regenerate"
        class="cursor-pointer"
        :loading="isGeneratingImage"
        @click="generateImage({ template, description: prompt })"
      />
    </template>
  </UModal>
</template>
