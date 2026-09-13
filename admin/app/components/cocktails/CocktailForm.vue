<script setup lang="ts">
import {
  COCKTAIL_CATEGORIES,
  COCKTAIL_METHODS,
  BASE_SPIRITS,
  FLAVOR_PROFILES
} from '../../../../functions/src/cocktail/cocktail.model';
import type { Cocktail } from '~/types';
import GeneratableImageFormField from '~/components/image-generation/GeneratableImageFormField.vue';
import { useCocktailForm } from '~/composables/useCocktailForm';

import I18nArrayFormField from '../I18nArrayFormField.vue';
import IngredientCard from './IngredientCard.vue';
import EquipmentCard from './EquipmentCard.vue';
import PourStepsFormField from './PourStepsFormField.vue';

const props = defineProps<{
  cocktail?: Cocktail;
}>();

const {
  state,
  isSaving,
  submit,

  addEquipment,
  isAddingEquipment,
  removeEquipment,

  addIngredient,
  isAddingIngredient,
  removeIngredient,
  setMeasure
} = useCocktailForm(props.cocktail);

const categoryOptions: string[] = Object.values(COCKTAIL_CATEGORIES);

// The three fields Explore filters on. Each offers a blank entry because
// "not decided yet" is a real state -- it is how an un-backfilled drink reads.
const methodOptions = [
  { label: '—', value: null },
  ...Object.values(COCKTAIL_METHODS).map(value => ({ label: value, value }))
];

const baseSpiritOptions = [
  { label: '—', value: null },
  ...Object.values(BASE_SPIRITS).map(value => ({ label: value, value }))
];

const flavorOptions = [
  { label: '—', value: null },
  ...Object.values(FLAVOR_PROFILES).map(value => ({ label: value, value }))
];

const ingredientGenerationPrompt = computed(() => {
  return `${state.title.en} cocktail. ${state.description?.en}
Ingredients: ${state.ingredients.map(ing => ing.title.en).join(', ')}.`;
});

const addIngredientId = ref('');
const addEquipmentId = ref('');

defineExpose({
  isSaving
});
</script>

<template>
  <UForm
    id="cocktail-form"
    :state="state"
    :disabled="isSaving"
    class="grid grid-cols-2 gap-4"
    @submit="submit"
  >
    <!-- Title Field -->
    <UFormField label="Title" name="title" required>
      <I18nFormField v-model="state.title" />
    </UFormField>

    <GeneratableImageFormField
      v-model:image-src="state.image"
      label="Cocktail Image"
      template="cocktail"
      :title="state.title.en || ''"
      :prompt="ingredientGenerationPrompt"
    />

    <!-- Categories Field -->
    <UFormField
      label="Categories"
      name="categories"
      required
    >
      <USelectMenu
        v-model="state.categories"
        :items="categoryOptions"
        multiple
      />
    </UFormField>

    <UFormField label="ABV, %" name="abv">
      <UInputNumber v-model="state.abv" class="w-full" :step="0.1" />
    </UFormField>

    <!-- Description Field -->
    <UFormField label="Description" name="description" class="col-span-2">
      <I18nFormField v-slot="{ value, setValue }" v-model="state.description!">
        <UTextarea
          :model-value="value"
          class="w-full"
          :rows="5"
          @update:model-value="setValue"
        />
      </I18nFormField>
    </UFormField>

    <!--
      The recipe vocabulary. Explore's filters read these directly: a drink
      with no method never matches "no shaker needed", one with no base spirit
      never appears under browse-by-spirit, and one with no prep time is
      dropped by "under 3 minutes". Leaving them blank hides the drink rather
      than showing it unfiltered.
    -->
    <div class="col-span-2 grid grid-cols-3 gap-4 rounded-lg border border-default p-4">
      <UFormField label="Method" name="method" help="How it is assembled">
        <USelect
          v-model="state.method"
          :items="methodOptions"
          value-key="value"
          class="w-full"
        />
      </UFormField>

      <UFormField label="Base spirit" name="baseSpirit" help="What it is built around">
        <USelect
          v-model="state.baseSpirit"
          :items="baseSpiritOptions"
          value-key="value"
          class="w-full"
        />
      </UFormField>

      <UFormField label="Flavour" name="flavor" help="The dominant taste">
        <USelect
          v-model="state.flavor"
          :items="flavorOptions"
          value-key="value"
          class="w-full"
        />
      </UFormField>

      <UFormField label="Prep time, min" name="prepTimeMinutes" help="Active work, whole minutes">
        <UInputNumber
          v-model="state.prepTimeMinutes"
          class="w-full"
          :min="1"
          :max="240"
        />
      </UFormField>

      <UFormField label="Popularity" name="popularity" help="0–100, how widely known">
        <UInputNumber
          v-model="state.popularity"
          class="w-full"
          :min="0"
          :max="100"
        />
      </UFormField>

      <UFormField label="Seasonal score" name="seasonalScore" help="0–100, fit for the season">
        <UInputNumber
          v-model="state.seasonalScore"
          class="w-full"
          :min="0"
          :max="100"
        />
      </UFormField>
    </div>

    <I18nArrayFormField v-model="state.preparationSteps" label="Preparation steps" class="col-span-2" />

    <PourStepsFormField v-model="state.pourSteps!" class="col-span-2" />

    <UFormField class="col-span-2" :ui="{ label: 'flex w-full items-center justify-between' }">
      <template #label>
        Ingredients

        <UPopover>
          <UIcon
            name="i-lucide-plus"
            class="size-4 cursor-pointer"
          />

          <template #content>
            <UFieldGroup>
              <UInput v-model="addIngredientId" placeholder="Enter Ingredient ID" />
              <UButton
                color="neutral"
                variant="subtle"
                icon="i-lucide-check"
                class="cursor-pointer"
                :disabled="!addIngredientId"
                :loading="isAddingIngredient"
                @click="addIngredient(addIngredientId).then(() => addIngredientId = '')"
              />
            </UFieldGroup>
          </template>
        </UPopover>
      </template>
      <div class="grid grid-cols-4 gap-2 mt-4">
        <IngredientCard
          v-for="ingredient in state.ingredients"
          :id="ingredient.id"
          :key="ingredient.id"
          :measure="state.measures?.[ingredient.id]"
          :ingredient="ingredient"
          @remove="removeIngredient"
          @update:measure="setMeasure(ingredient.id, $event)"
        />
      </div>
    </UFormField>

    <!-- Equipment Field -->
    <UFormField class="col-span-2" :ui="{ label: 'flex w-full items-center justify-between' }">
      <template #label>
        Equipment

        <UPopover>
          <UIcon
            name="i-lucide-plus"
            class="size-4 cursor-pointer"
          />

          <template #content>
            <UFieldGroup>
              <UInput v-model="addEquipmentId" placeholder="Enter Equipment ID" />
              <UButton
                color="neutral"
                variant="subtle"
                icon="i-lucide-check"
                class="cursor-pointer"
                :disabled="!addEquipmentId"
                :loading="isAddingEquipment"
                @click="addEquipment(addEquipmentId).then(() => addEquipmentId = '')"
              />
            </UFieldGroup>
          </template>
        </UPopover>
      </template>

      <div class="grid grid-cols-4 gap-2 mt-4">
        <EquipmentCard
          v-for="equipment in state.equipments"
          :id="equipment.id"
          :key="equipment.id"
          :equipment="equipment"
          @remove="removeEquipment"
        />
      </div>
    </UFormField>
  </UForm>
</template>
