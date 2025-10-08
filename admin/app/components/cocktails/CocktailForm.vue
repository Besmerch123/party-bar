<script setup lang="ts">
import type { FormSubmitEvent } from '@nuxt/ui';
import type { DocumentSnapshot } from 'firebase/firestore';
import { COCKTAIL_CATEGORIES } from '../../../../functions/src/cocktail/cocktail.model';
import type {
  CocktailDocument,
  CocktailCategory,
  EquipmentDocument,
  IngredientDocument,
  I18nField,
  I18nArrayField
} from '~/types';
import GeneratableImageFormField from '~/components/image-generation/GeneratableImageFormField.vue';

import I18nArrayFormField from '../I18nArrayFormField.vue';
import IngredientCard from './IngredientCard.vue';
import EquipmentCard from './EquipmentCard.vue';

const props = defineProps<{
  cocktailId: string;
  cocktailDocument?: CocktailDocument;
  ingredients?: DocumentSnapshot<IngredientDocument>[];
  equipments?: DocumentSnapshot<EquipmentDocument>[];
}>();

type FormState = {
  title: I18nField;
  description: I18nField;
  abv?: number;
  image?: string;
  preparationSteps: I18nArrayField;
  ingredients: DocumentSnapshot<IngredientDocument>[];
  equipments: DocumentSnapshot<EquipmentDocument>[];
  categories: CocktailCategory[];
};

// Form state
const formData = ref<FormState>({
  title: { en: '', uk: '', ...props.cocktailDocument?.title },
  description: { en: '', uk: '', ...props.cocktailDocument?.description },
  abv: props.cocktailDocument?.abv,
  image: props.cocktailDocument?.image ?? '',
  preparationSteps: { en: [''], uk: [''], ...props.cocktailDocument?.preparationSteps },
  ingredients: props?.ingredients || [],
  equipments: props?.equipments || [],
  categories: props.cocktailDocument?.categories || []
});

// Category options for select
const categoryOptions: string[] = Object.values(COCKTAIL_CATEGORIES);

const { mutate: saveCocktail, isPending } = useCocktailSave();

const submitHandler = async (event: FormSubmitEvent<FormState>) => {
  const data = event.data;

  await saveCocktail({
    id: props.cocktailId,
    title: data.title,
    description: data.description,
    abv: data.abv,
    image: data.image,
    preparationSteps: data.preparationSteps,
    ingredients: data.ingredients.map(ing => ing.ref.path),
    equipments: data.equipments.map(eq => eq.ref.path),
    categories: data.categories
  });
};

const ingredientGenerationPrompt = computed(() => {
  return `${formData.value.title.en} cocktail. ${formData.value.description.en}
Ingredients: ${formData.value.ingredients.map(ing => ing.data()?.title.en).join(', ')}.`;
});
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
        label="Cocktail Image"
        template="cocktail"
        :title="formData.title.en || ''"
        :prompt="ingredientGenerationPrompt"
      />

      <!-- Categories Field -->
      <UFormField
        label="Categories"
        name="categories"
        required
      >
        <USelectMenu
          v-model="formData.categories"
          :items="categoryOptions"
          multiple
        />
      </UFormField>

      <UFormField label="ABV, %" name="abv">
        <UInputNumber v-model="formData.abv" class="w-full" :step="0.1" />
      </UFormField>

      <!-- Description Field -->
      <UFormField label="Description" name="description" class="col-span-2">
        <I18nFormField v-slot="{ value, setValue }" v-model="formData.description">
          <UTextarea
            :model-value="value"
            class="w-full"
            :rows="5"
            @update:model-value="setValue"
          />
        </I18nFormField>
      </UFormField>

      <I18nArrayFormField v-model="formData.preparationSteps" label="Preparation steps" class="col-span-2" />

      <UFormField label="Ingredients">
        <div class="grid grid-cols-4 gap-2 col-span-2 mt-4">
          <IngredientCard
            v-for="(ingredient, i) in formData.ingredients"
            :key="i"
            :ingredient="ingredient.data()!"
            class="basis-1/4"
          />
        </div>
      </UFormField>

      <!-- Equipment Field -->
      <UFormField label="Equipment">
        <div class="grid grid-cols-4 gap-2 col-span-2 mt-4">
          <EquipmentCard
            v-for="(equipment, i) in formData.equipments"
            :key="i"
            :equipment="equipment.data()!"
          />
        </div>
      </UFormField>

      <!-- Submit Button -->
      <div class="col-span-2 flex justify-end gap-2">
        <UButton type="submit" color="primary" :loading="isPending">
          {{ cocktailDocument ? 'Update' : 'Create' }} Cocktail
        </UButton>
      </div>
    </div>
  </UForm>
</template>
