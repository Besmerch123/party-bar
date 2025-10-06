<script setup lang="ts">
import { useCocktail } from '~/composables/useCocktail';
import { useLocale } from '~/composables/useLocale';
import CocktailForm from '~/components/cocktails/CocktailForm.vue';
import DefaultPageToolbar from '~/components/DefaultPageToolbar.vue';

const route = useRoute();
const id = route.params.id as string;

const locale = useLocale();

const { data, error, isFetched, isPending } = useCocktail(id);
</script>

<template>
  <UDashboardPanel id="cocktail">
    <template #header>
      <DefaultPageToolbar>
        <template #title>
          <h1 class="text-lg font-medium">
            {{ data?.cocktail.title[locale] }}
          </h1>
          <h2 class="text-sm font-medium text-muted">
            ID: {{ id }}
          </h2>
        </template>
      </DefaultPageToolbar>
    </template>

    <template #body>
      <UContainer>
        <UAlert v-if="error" type="error" class="mb-4">
          Error loading cocktail: {{ error.message }}
        </UAlert>

        <USkeleton v-if="isPending" class="h-12 w-full mb-4" />

        <CocktailForm
          v-if="isFetched"
          :cocktail-id="id"
          :cocktail-document="data?.cocktail"
          :ingredients="data?.ingredients"
          :equipments="data?.equipments"
        />
      </UContainer>
    </template>
  </UDashboardPanel>
</template>
