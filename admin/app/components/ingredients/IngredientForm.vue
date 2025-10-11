<script setup lang="ts">
import type { FormSubmitEvent } from '@nuxt/ui';
import { INGREDIENT_CATEGORIES } from '../../../../functions/src/ingredient/ingredient.model';
import type { IngredientDocument, IngredientCategory, I18nField } from '~/types';
import GeneratableImageFormField from '~/components/image-generation/GeneratableImageFormField.vue';

const props = defineProps<{
  ingredientId?: string;
  ingredientDocument?: IngredientDocument;
}>();

type FormState = {
  title: I18nField;
  category: IngredientCategory;
  image?: string | null;
};

// Form state
const formData = ref<FormState>({
  title: { en: '', uk: '', ...props.ingredientDocument?.title },
  category: props.ingredientDocument?.category || 'other',
  image: props.ingredientDocument?.image
});

// Category options for select
const categoryOptions: string[] = Object.values(INGREDIENT_CATEGORIES);

const { mutate: saveIngredient, isPending } = useIngredientSave();

const submitHandler = async (event: FormSubmitEvent<FormState>) => {
  const data = event.data;

  await saveIngredient({
    id: props.ingredientId,
    ...data
  });
};

const ingredientGenerationPrompt = computed(() => {
  return `${formData.value.title.en} - ${formData.value.category} - cocktail ingredient`;
});

defineExpose({
  isSaving: isPending
});
</script>

<template>
  <UForm
    id="ingredient-form"
    :state="formData"
    :disabled="isPending"
    class="grid grid-cols-2 gap-4"
    @submit="submitHandler"
  >
    <!-- Title Field -->
    <UFormField label="Title" name="title" required>
      <I18nFormField v-model="formData.title" />
    </UFormField>

    <!-- Category Field -->
    <UFormField
      label="Category"
      name="category"
      required
    >
      <USelectMenu
        v-model="formData.category"
        :items="categoryOptions"
        class="capitalize"
      />
    </UFormField>

    <!-- Image Field -->
    <GeneratableImageFormField
      v-model:image-src="formData.image"
      label="Image"
      name="image"
      template="ingredient"
      :title="ingredientDocument?.title.en || ''"
      :prompt="ingredientGenerationPrompt"
    />
  </UForm>
</template>
