<script setup lang="ts">
import type { DocumentSnapshot } from 'firebase/firestore';
import type { CocktailDocument, CocktailCategory } from '../../../../functions/src/cocktail/cocktail.model';
import { COCKTAIL_CATEGORIES } from '../../../../functions/src/cocktail/cocktail.model';
import type { EquipmentDocument } from '../../../../functions/src/equipment/equipment.model';
import type { IngredientDocument } from '../../../../functions/src/ingredient/ingredient.model';
import type { I18nField } from '../../../../functions/src/shared/types';

import IngredientCard from './IngredientCard.vue';
import EquipmentCard from './EquipmentCard.vue';
import type { FormSubmitEvent } from '@nuxt/ui';

const props = defineProps<{
  cocktailId: string;
  cocktailDocument?: CocktailDocument;
  ingredients?: DocumentSnapshot<IngredientDocument>[];
  equipments?: DocumentSnapshot<EquipmentDocument>[];
}>();

type FormState = {
  title: I18nField;
  description: I18nField;
  ingredients: DocumentSnapshot<IngredientDocument>[];
  equipments: DocumentSnapshot<EquipmentDocument>[];
  categories: CocktailCategory[];
};

// Form state
const formData = ref<FormState>({
  title: props.cocktailDocument?.title || { en: '', uk: '' },
  description: props.cocktailDocument?.description || { en: '', uk: '' },
  ingredients: props?.ingredients || [],
  equipments: props?.equipments || [],
  categories: props.cocktailDocument?.categories || []
});

// Category options for select
const categoryOptions: string[] = Object.values(COCKTAIL_CATEGORIES);

const { mutate: saveCocktail, isPending } = useCocktailSave();

const submitHandler = async (event: FormSubmitEvent<FormState>) => {
  const data = event.data;

  const cocktailDocument: Partial<CocktailDocument> = {
    title: data.title,
    description: data.description,
    ingredients: data.ingredients.map(ing => ing.ref.path),
    equipments: data.equipments.map(eq => eq.ref.path),
    categories: data.categories
  };

  await saveCocktail({
    id: props.cocktailId,
    cocktailDocument
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

      <!-- Description Field -->
      <UFormField label="Description" name="description" class="col-span-2">
        <I18nFormField v-slot="{ value, setValue }" v-model="formData.description">
          <UTextarea :model-value="value" class="w-full" @update:model-value="setValue" />
        </I18nFormField>
      </UFormField>

      <UFormField label="Ingredients">
        <div class="flex  gap-2 col-span-2">
          <IngredientCard
            v-for="(ingredient, i) in formData.ingredients"
            :key="i"
            :ingredient="ingredient.data()!"
          />
        </div>
      </UFormField>

      <!-- Equipment Field -->
      <UFormField label="Equipment">
        <div class="flex  gap-2 col-span-2">
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
