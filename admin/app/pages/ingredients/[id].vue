<script setup lang="ts">
import { useIngredient } from '~/composables/useIngredient';
import { useLocale } from '~/composables/useLocale';
import IngredientForm from '~/components/ingredients/IngredientForm.vue';

const route = useRoute();
const ingredientId = route.params.id as string;

const locale = useLocale();

const { data: ingredient, isLoading, error } = useIngredient(ingredientId);
</script>

<template>
  <UDashboardPanel id="ingredient">
    <template #header>
      <DefaultPageToolbar :title="ingredient?.title?.[locale]" />
    </template>

    <template #body>
      <UContainer>
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
            :ingredient-id="ingredientId"
            :ingredient-document="ingredient"
          />
        </div>
      </UContainer>
    </template>
  </UDashboardPanel>
</template>
