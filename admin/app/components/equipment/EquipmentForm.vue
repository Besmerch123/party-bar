<script setup lang="ts">
import type { FormSubmitEvent } from '@nuxt/ui';
import type { EquipmentDocument, I18nField } from '~/types';

const props = defineProps<{
  equipmentId: string;
  equipmentDocument?: EquipmentDocument;
}>();

type FormState = {
  title: I18nField;
};

// Form state
const formData = ref<FormState>({
  title: { en: '', uk: '', ...props.equipmentDocument?.title }
});

const { mutate: saveEquipment, isPending } = useEquipmentSave();

const submitHandler = async (event: FormSubmitEvent<FormState>) => {
  const data = event.data;

  const equipmentDocument: Partial<EquipmentDocument> = {
    title: data.title
  };

  await saveEquipment({
    id: props.equipmentId,
    equipmentDocument
  });
};
</script>

<template>
  <UForm :state="formData" :disabled="isPending" @submit="submitHandler">
    <div class="grid grid-cols-1 gap-4">
      <!-- Title Field -->
      <UFormField label="Title" name="title" required>
        <I18nFormField v-model="formData.title" />
      </UFormField>

      <!-- Submit Button -->
      <div class="flex justify-end gap-2">
        <UButton type="submit" color="primary" :loading="isPending">
          {{ equipmentDocument ? 'Update' : 'Create' }} Equipment
        </UButton>
      </div>
    </div>
  </UForm>
</template>
