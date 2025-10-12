<script setup lang="ts">
import { useCocktail } from '~/composables/useCocktail';
import { useLocale } from '~/composables/useLocale';
import CocktailForm from '~/components/cocktails/CocktailForm.vue';
import DefaultPageToolbar from '~/components/DefaultPageToolbar.vue';

const route = useRoute();
const id = route.params.id as string;

const locale = useLocale();

const { data: cocktail, error, isFetched, isPending } = useCocktail(id);

const cocktailForm = useTemplateRef('cocktailForm');
</script>

<template>
  <UDashboardPanel id="cocktail">
    <template #header>
      <DefaultPageToolbar>
        <template #title>
          <h1 class="text-lg font-medium">
            {{ cocktail?.title[locale] }}
          </h1>
          <h2 class="text-sm font-medium text-muted">
            ID: {{ id }}
          </h2>
        </template>
      </DefaultPageToolbar>
    </template>

    <template #body>
      <UContainer>
        <UDashboardToolbar :ui="{ root: 'mb-6 px-0 sm:px-0 border-none' }">
          <template #left>
            <UButton
              variant="ghost"
              color="neutral"
              icon="i-lucide-chevron-left"
              to="/cocktails"
            >
              Back to Cocktails
            </UButton>
          </template>

          <template #right>
            <UButton
              form="cocktail-form"
              type="submit"
              color="neutral"
              class="cursor-pointer"
              :loading="cocktailForm?.isSaving"
            >
              Save
            </UButton>
          </template>
        </UDashboardToolbar>

        <UAlert v-if="error" type="error" class="mb-4">
          Error loading cocktail: {{ error.message }}
        </UAlert>

        <USkeleton v-if="isPending" class="h-12 w-full mb-4" />

        <CocktailForm
          v-if="isFetched"
          ref="cocktailForm"
          :cocktail-id="id"
          :cocktail="cocktail"
        />
      </UContainer>
    </template>
  </UDashboardPanel>
</template>
