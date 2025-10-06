<script setup lang="ts">
import CocktailsTable from '~/components/cocktails/CocktailsTable.vue';
import { useCocktails } from '~/composables/useCocktails';
import AddCocktailForm from '~/components/cocktails/AddCocktailForm.vue';
import DefaultPageToolbar from '~/components/DefaultPageToolbar.vue';
import type { Cocktail } from '~/types';

const { data, fetchNextPage, hasNextPage, isPending, isLoading } = useCocktails();

const cocktails = computed<Cocktail[]>(() => {
  return (data?.value?.pages || []).flatMap((page) => {
    const cocktails = page.cocktails || [];

    return cocktails.map((doc) => {
      const { title, description, createdAt, updatedAt, ...restData } = doc.data();

      return {
        id: doc.id,
        title,
        description,
        createdAt: createdAt?.toDate() || undefined,
        updatedAt: updatedAt?.toDate() || undefined,
        ...restData
      };
    });
  });
});
</script>

<template>
  <UDashboardPanel id="cocktails">
    <template #header>
      <DefaultPageToolbar title="Cocktails" />
    </template>

    <template #body>
      <UContainer>
        <div class="flex justify-end mb-4">
          <UPopover>
            <UButton label="Add cocktail" />

            <template #content>
              <AddCocktailForm class="p-4" />
            </template>
          </UPopover>
        </div>

        <CocktailsTable :cocktails :loading="isPending || isLoading" />

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
