<script setup lang="ts">
import type { FormSubmitEvent } from '@nuxt/ui';
import { EQUIPMENT_KINDS } from '../../../../functions/src/equipment/equipment.model';
import type { EquipmentDocument, EquipmentKind, I18nField } from '~/types';
import GeneratableImageFormField from '~/components/image-generation/GeneratableImageFormField.vue';

const props = defineProps<{
  equipmentId?: string;
  equipmentDocument?: EquipmentDocument;
}>();

type FormState = {
  title: I18nField;
  image?: string | null;
  slug?: string | null;
  kind: EquipmentKind;
};

// Form state
const formData = ref<FormState>({
  title: { en: '', uk: '', ...props.equipmentDocument?.title },
  image: props.equipmentDocument?.image,
  slug: props.equipmentDocument?.slug ?? '',
  // The pre-Flow-04 catalogue recorded no kind at all; the app reads those as
  // tools, so the form defaults the same way rather than forcing a choice.
  kind: props.equipmentDocument?.kind ?? EQUIPMENT_KINDS.TOOL
});

const kindOptions: EquipmentKind[] = Object.values(EQUIPMENT_KINDS);

const { mutateAsync: saveEquipment, isPending } = useEquipmentSave();

const submitHandler = async (event: FormSubmitEvent<FormState>) => {
  const data = event.data;

  await saveEquipment({
    id: props.equipmentId,
    ...data,
    slug: data.slug?.trim() || null
  });
};

defineExpose({
  isSaving: isPending
});
</script>

<template>
  <UForm
    id="equipment-form"
    :state="formData"
    :disabled="isPending"
    class="grid grid-cols-2 gap-4"
    @submit="submitHandler"
  >
    <!-- Title Field -->
    <UFormField label="Title" name="title" required>
      <I18nFormField v-model="formData.title" />
    </UFormField>

    <!--
      How the app's shelf files this. Tools and glassware sit together there,
      but ice goes with the ice ingredients instead, so the distinction has to
      be recorded rather than guessed from the title.
    -->
    <UFormField
      label="Kind"
      name="kind"
      required
      help="Where the app's shelf files this — ice sits with the ice ingredients"
    >
      <USelectMenu
        v-model="formData.kind"
        :items="kindOptions"
        class="capitalize"
      />
    </UFormField>

    <UFormField
      label="Shelf slug"
      name="slug"
      help="camelCase key the app's shelf stores, e.g. bostonShaker. Leave blank if unused."
    >
      <UInput
        v-model="formData.slug"
        placeholder="bostonShaker"
        class="w-full"
      />
    </UFormField>

    <GeneratableImageFormField
      v-model:image-src="formData.image"
      label="Image"
      name="image"
      template="equipment"
      :title="equipmentDocument?.title.en || ''"
      :prompt="formData.title.en || ''"
    />

    <!-- Derived from the cocktail collection; recount from Settings. -->
    <div v-if="equipmentId" class="col-span-2 flex gap-8 rounded-lg border border-default p-4">
      <div>
        <p class="text-xs text-muted uppercase">
          In drinks
        </p>
        <p class="text-lg font-medium">
          {{ equipmentDocument?.cocktailCount ?? '—' }}
        </p>
      </div>

      <p class="text-xs text-muted self-end">
        Computed from the catalogue — recount from Settings to refresh.
      </p>
    </div>
  </UForm>
</template>
