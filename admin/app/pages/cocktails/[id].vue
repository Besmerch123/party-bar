<script setup lang="ts">
import { useCocktail } from '~/composables/useCocktail';
import { useLocale } from '~/composables/useLocale';
import CocktailForm from '~/components/cocktails/CocktailForm.vue';

const route = useRoute();
const id = route.params.id as string;

const locale = useLocale();

const { data, error } = await useCocktail(id);
</script>

<template>
  <UDashboardPanel id="cocktail">
    <template #header>
      <UDashboardToolbar>
        <template #left>
          <h1 class="text-lg font-medium">
            {{ data?.cocktailData.title[locale] }}
          </h1>
          <h2 class="text-sm font-medium text-muted">
            ID: {{ id }}
          </h2>
        </template>

        <template #right>
          <UFieldGroup orientation="horizontal">
            <UButton
              color="neutral"
              :variant="locale === 'en' ? 'subtle' : 'outline'"
              label="en"
              @click="locale = 'en'"
            />
            <UButton
              color="neutral"
              :variant="locale === 'uk' ? 'subtle' : 'outline'"
              label="uk"
              @click="locale = 'uk'"
            />
          </UFieldGroup>
        </template>
      </UDashboardToolbar>
    </template>

    <template #body>
      <UContainer>
        <UAlert v-if="error" type="error" class="mb-4">
          Error loading cocktail: {{ error.message }}
        </UAlert>

        <CocktailForm
          :cocktail-id="id"
          :cocktail-document="data?.cocktailData"
          :ingredients="data?.ingredients"
          :equipments="data?.equipments"
        />
      </UContainer>
    </template>
  </UDashboardPanel>
</template>
