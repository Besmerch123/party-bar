<script setup lang="ts">
import IngredientsTable from '~/components/ingredients/IngredientsTable.vue';
import { useIngredients } from '~/composables/useIngredients';
import DefaultPageToolbar from '~/components/DefaultPageToolbar.vue';
import type { Ingredient } from '~/types';

const { data, fetchNextPage, hasNextPage, isPending, isLoading } = useIngredients();

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
        createdAt: createdAt?.toDate() || undefined,
        updatedAt: updatedAt?.toDate() || undefined
      };
    });
  });
});
</script>

<template>
  <UDashboardPanel id="ingredients">
    <template #header>
      <DefaultPageToolbar title="Ingredients" />
    </template>

    <template #body>
      <UContainer>
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
