<script setup lang="ts">
import IngredientsTable from '~/components/ingredients/IngredientsTable.vue';
import { useIngredients } from '~/composables/useIngredients';
import DefaultPageToolbar from '~/components/DefaultPageToolbar.vue';
import type { Ingredient } from '~/types';
import { INGREDIENT_CATEGORIES } from '../../../../functions/src/ingredient/ingredient.model';

const { data, fetchNextPage, hasNextPage, isPending, isLoading, filters } = useIngredients();

const ingredients = computed<Ingredient[]>(() => {
  return (data?.value?.pages || []).flatMap((page) => {
    const ingredients = page.ingredients || [];

    return ingredients.map((doc) => {
      const { title, image, category, createdAt, updatedAt } = doc.data();

      return {
        id: doc.id,
        title,
        image,
        category,
        createdAt: createdAt?.toDate().toString() || undefined,
        updatedAt: updatedAt?.toDate().toString() || undefined
      };
    });
  });
});

const categories = Object.values(INGREDIENT_CATEGORIES);
</script>

<template>
  <UDashboardPanel id="ingredients">
    <template #header>
      <DefaultPageToolbar title="Ingredients" />
    </template>

    <template #body>
      <UContainer>
        <div class="flex gap-4 items-center mb-4">
          <USelectMenu
            v-model="filters.category"
            :items="categories"
            placeholder="Filter by category"
            class="max-w-xs"
            clearable
          />
        </div>

        <IngredientsTable :ingredients="ingredients" :loading="isPending || isLoading" />

        <div class="mt-4 flex justify-center">
          <LoadMore
            v-if="hasNextPage"
            :loading="isLoading"
            @click="fetchNextPage()"
          >
            Load more
          </LoadMore>
        </div>
      </UContainer>
    </template>
  </UDashboardPanel>
</template>
