<script setup lang="ts">
import type { ImageTemplate } from '~/types';
import { useFileUpload } from '~/composables/useFileUpload';
import ImageGenerationModal from './ImageGenerationModal.vue';

const props = defineProps<{ prompt: string; title: string; template: ImageTemplate }>();

const imageSrc = defineModel<string | null>('image-src');

const overlay = useOverlay();

const imageGenerationModal = overlay.create(ImageGenerationModal);
const toast = useToast();
const { mutateAsync: uploadFile, isPending: isUploading } = useFileUpload();

const generateHandler = async () => {
  if (!props.prompt) {
    toast.add({
      title: 'Warning',
      description: 'Please enter the prompt in English to generate an image.',
      color: 'warning'
    });
    return;
  }

  imageGenerationModal.open({
    template: props.template,
    prompt: props.prompt,
    onChoice: (image) => {
      const type = image.mimeType.split('/')[1] || 'jpg';
      uploadFile({
        pathPrefix: props.template,
        files: [
          {
            name: `${props.title.toLowerCase()}.${type}`,
            contentType: image.mimeType,
            data: image.bytesBase64Encoded
          }
        ]
      }, {
        onSuccess: (result) => {
          imageSrc.value = result.files[0]?.mediaLink;
        }
      });

      imageGenerationModal.close();
    }
  });
};
</script>

<template>
  <UFormField label="Image" name="image">
    <USkeleton v-if="isUploading" class="w-full aspect-square rounded-md" />
    <img v-else-if="imageSrc" :src="imageSrc">
    <div v-else class="aspect-square bg-muted flex items-center justify-center">
      <UIcon name="i-lucide-image-off" class="size-48 text-muted" />
    </div>

    <div class="flex gap-2 justify-center mt-2">
      <UButton
        color="secondary"
        variant="subtle"
        label="Generate image"
        @click="generateHandler"
      />
      <UButton
        v-if="imageSrc"
        color="error"
        variant="outline"
        label="Remove image"
        @click="imageSrc = ''"
      />
    </div>
  </UFormField>
</template>
