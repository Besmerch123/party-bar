<script setup lang="ts">
import CocktailsTable from '~/components/cocktails/CocktailsTable.vue';
import { useCocktails } from '~/composables/useCocktails';
import type { Cocktail } from '../../../../functions/src/cocktail/cocktail.model';

const { fetchCocktails } = useCocktails();

const { data } = fetchCocktails({ pageSize: 10 });

const locale = 'en';

const cocktails = computed<Cocktail[]>(() => {
  return (data?.value?.cocktails || []).map((doc) => {
    const { title, description, createdAt, updatedAt, ...restData } = doc.data();

    return {
      id: doc.id,
      title: title[locale] || 'N/A',
      description: description[locale] || 'N/A',
      createdAt: createdAt?.toDate() || undefined,
      updatedAt: updatedAt?.toDate() || undefined,
      ...restData
    };
  });
});
</script>

<template>
  <UDashboardPanel id="cocktails">
    <template #header>
      <UDashboardNavbar title="Cocktails" :ui="{ right: 'gap-3' }">
        <template #leading>
          <UDashboardSidebarCollapse />
        </template>
      </UDashboardNavbar>
    </template>

    <template #body>
      <UContainer>
        <CocktailsTable :cocktails />
      </UContainer>
    </template>
  </UDashboardPanel>
</template>
