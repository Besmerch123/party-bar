<script setup lang="ts">
import type { FormSubmitEvent } from '@nuxt/ui';
import { INGREDIENT_CATEGORIES } from '../../../../functions/src/ingredient/ingredient.model';
import type { IngredientDocument, IngredientCategory, I18nField } from '~/types';
import GeneratableImageFormField from '~/components/image-generation/GeneratableImageFormField.vue';

const props = defineProps<{
  ingredientId: string;
  ingredientDocument?: IngredientDocument;
}>();

type FormState = {
  title: I18nField;
  category: IngredientCategory;
  image?: string;
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
</script>

<template>
  <UForm :state="formData" :disabled="isPending" @submit="submitHandler">
    <div class="grid grid-cols-2 gap-4">
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

      <!-- Submit Button -->
      <div class="flex justify-end gap-2 col-span-2">
        <UButton
          type="submit"
          color="primary"
          :loading="isPending"
        >
          {{ ingredientDocument ? 'Update' : 'Create' }} Ingredient
        </UButton>
      </div>
    </div>
  </UForm>
</template>
