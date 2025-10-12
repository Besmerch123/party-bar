<script setup lang="ts">
import type { FormSubmitEvent } from '@nuxt/ui';
import { COCKTAIL_CATEGORIES } from '../../../../functions/src/cocktail/cocktail.model';
import type {
  Cocktail,
  Ingredient,
  Equipment,
  CocktailCategory,
  I18nField,
  I18nArrayField
} from '~/types';
import GeneratableImageFormField from '~/components/image-generation/GeneratableImageFormField.vue';

import I18nArrayFormField from '../I18nArrayFormField.vue';
import IngredientCard from './IngredientCard.vue';
import EquipmentCard from './EquipmentCard.vue';

const props = defineProps<{
  cocktail?: Cocktail;
}>();

type FormState = {
  title: I18nField;
  description: I18nField;
  abv?: number | null;
  image?: string | null;
  preparationSteps: I18nArrayField;
  ingredients: Ingredient[];
  equipments: Equipment[];
  categories: CocktailCategory[];
};

// Form state
const formData = ref<FormState>({
  title: { en: '', uk: '', ...props.cocktail?.title },
  description: { en: '', uk: '', ...props.cocktail?.description },
  abv: props.cocktail?.abv,
  image: props.cocktail?.image ?? '',
  preparationSteps: { en: [''], uk: [''], ...props.cocktail?.preparationSteps },
  categories: props.cocktail?.categories || [],
  ingredients: props?.cocktail?.ingredients || [],
  equipments: props?.cocktail?.equipments || []
});

const handleIngredientRemove = (id: string) => {
  formData.value.ingredients = formData.value.ingredients.filter(ing => ing.id !== id);
};

const handleEquipmentRemove = (id: string) => {
  formData.value.equipments = formData.value.equipments.filter(eq => eq.id !== id);
};

// Category options for select
const categoryOptions: string[] = Object.values(COCKTAIL_CATEGORIES);

const { mutate: saveCocktail, isPending } = useCocktailSave();

const submitHandler = async (event: FormSubmitEvent<FormState>) => {
  const data = event.data;

  const ingredients = data.ingredients.map(ing => `ingredients/${ing.id}`);
  const equipments = data.equipments.map(eq => `equipments/${eq.id}`);

  await saveCocktail({
    id: props.cocktail!.id,
    title: data.title,
    description: data.description,
    abv: data.abv,
    image: data.image,
    preparationSteps: data.preparationSteps,
    ingredients,
    equipments,
    categories: data.categories
  });
};

const ingredientGenerationPrompt = computed(() => {
  return `${formData.value.title.en} cocktail. ${formData.value.description.en}
Ingredients: ${formData.value.ingredients.map(ing => ing.title.en).join(', ')}.`;
});

defineExpose({
  isSaving: isPending
});
</script>

<template>
  <UForm
    id="cocktail-form"
    :state="formData"
    :disabled="isPending"
    class="grid grid-cols-2 gap-4"
    @submit="submitHandler"
  >
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
          :id="ingredient.id"
          :key="i"
          :ingredient="ingredient"
          class="basis-1/4"
          @remove="handleIngredientRemove"
        />
      </div>
    </UFormField>

    <!-- Equipment Field -->
    <UFormField label="Equipment">
      <div class="grid grid-cols-4 gap-2 col-span-2 mt-4">
        <EquipmentCard
          v-for="(equipment, i) in formData.equipments"
          :id="equipment.id"
          :key="i"
          :equipment="equipment"
          @remove="handleEquipmentRemove"
        />
      </div>
    </UFormField>
  </UForm>
</template>
