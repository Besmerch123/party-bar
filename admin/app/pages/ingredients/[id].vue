<script setup lang="ts">
import { useIngredient } from '~/composables/useIngredient';
import { useLocale } from '~/composables/useLocale';
import IngredientForm from '~/components/ingredients/IngredientForm.vue';

const route = useRoute();
const ingredientId = route.params.id as string;

const locale = useLocale();

const { data: ingredient, isLoading, error } = useIngredient(ingredientId);

const ingredientForm = useTemplateRef('ingredientForm');
</script>

<template>
  <UDashboardPanel id="ingredient">
    <template #header>
      <DefaultPageToolbar :title="ingredient?.title?.[locale]" />
    </template>

    <template #body>
      <UContainer>
        <UDashboardToolbar :ui="{ root: 'mb-6 px-0 sm:px-0 border-none' }">
          <template #left>
            <UButton
              variant="ghost"
              color="neutral"
              icon="i-lucide-chevron-left"
              to="/ingredients"
            >
              Back to Ingredients
            </UButton>
          </template>

          <template #right>
            <UButton
              form="ingredient-form"
              type="submit"
              color="neutral"
              class="cursor-pointer"
              :loading="ingredientForm?.isSaving"
            >
              Save
            </UButton>
          </template>
        </UDashboardToolbar>

        <div v-if="isLoading" class="flex justify-center items-center h-64">
          <UIcon name="i-lucide-loader-circle" class="animate-spin size-8" />
        </div>

        <div v-else-if="error" class="flex justify-center items-center h-64">
          <p class="text-error">
            Error loading ingredient: {{ error.message }}
          </p>
        </div>

        <div v-else-if="ingredient" class="py-8">
          <IngredientForm
            ref="ingredientForm"
            :ingredient-id="ingredientId"
            :ingredient-document="ingredient"
          />
        </div>
      </UContainer>
    </template>
  </UDashboardPanel>
</template>
