<script setup lang="ts">
import type { FormSubmitEvent } from '@nuxt/ui';
import type { EquipmentDocument, I18nField } from '~/types';
import GeneratableImageFormField from '~/components/image-generation/GeneratableImageFormField.vue';

const props = defineProps<{
  equipmentId: string;
  equipmentDocument?: EquipmentDocument;
}>();

type FormState = {
  title: I18nField;
  image?: string;
};

// Form state
const formData = ref<FormState>({
  title: { en: '', uk: '', ...props.equipmentDocument?.title },
  image: props.equipmentDocument?.image
});

const { mutate: saveEquipment, isPending } = useEquipmentSave();

const submitHandler = async (event: FormSubmitEvent<FormState>) => {
  const data = event.data;

  await saveEquipment({
    id: props.equipmentId,
    ...data
  });
};
</script>

<template>
  <UForm :state="formData" :disabled="isPending" @submit="submitHandler">
    <div class="grid grid-cols-2 gap-4">
      <!-- Title Field -->
      <UFormField label="Title" name="title" required>
        <I18nFormField v-model="formData.title" />
      </UFormField>

      <GeneratableImageFormField
        v-model:image-src="formData.image"
        label="Image"
        name="image"
        template="equipment"
        :title="equipmentDocument?.title.en || ''"
        :prompt="formData.title.en || ''"
      />

      <!-- Submit Button -->
      <div class="flex justify-end gap-2 col-span-2">
        <UButton
          type="submit"
          color="primary"
          :loading="isPending"
        >
          {{ equipmentDocument ? 'Update' : 'Create' }} Equipment
        </UButton>
      </div>
    </div>
  </UForm>
</template>
