<script setup lang="ts">
import { COCKTAIL_CATEGORIES } from '../../../../functions/src/cocktail/cocktail.model';
import type { Cocktail } from '~/types';
import GeneratableImageFormField from '~/components/image-generation/GeneratableImageFormField.vue';
import { useCocktailForm } from '~/composables/useCocktailForm';

import I18nArrayFormField from '../I18nArrayFormField.vue';
import IngredientCard from './IngredientCard.vue';
import EquipmentCard from './EquipmentCard.vue';

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
  removeIngredient
} = useCocktailForm(props.cocktail);

// Category options for select
const categoryOptions: string[] = Object.values(COCKTAIL_CATEGORIES);

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

    <I18nArrayFormField v-model="state.preparationSteps" label="Preparation steps" class="col-span-2" />

    <UFormField :ui="{ label: 'flex w-full items-center justify-between' }">
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
      <div class="grid grid-cols-4 gap-2 col-span-2 mt-4">
        <IngredientCard
          v-for="(ingredient, i) in state.ingredients"
          :id="ingredient.id"
          :key="i"
          :ingredient="ingredient"
          class="basis-1/4"
          @remove="removeIngredient"
        />
      </div>
    </UFormField>

    <!-- Equipment Field -->
    <UFormField :ui="{ label: 'flex w-full items-center justify-between' }">
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

      <div class="grid grid-cols-4 gap-2 col-span-2 mt-4">
        <EquipmentCard
          v-for="(equipment, i) in state.equipments"
          :id="equipment.id"
          :key="i"
          :equipment="equipment"
          @remove="removeEquipment"
        />
      </div>
    </UFormField>
  </UForm>
</template>
