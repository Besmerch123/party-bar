<script setup lang="ts">
import CocktailsTable from '~/components/cocktails/CocktailsTable.vue';
import { useCocktails } from '~/composables/useCocktails';
import AddCocktailForm from '~/components/cocktails/AddCocktailForm.vue';
import DefaultPageToolbar from '~/components/DefaultPageToolbar.vue';
import { COCKTAIL_CATEGORIES } from '../../../../functions/src/cocktail/cocktail.model';

const { data, isLoading, search, page, filters } = useCocktails();

const categories = Object.values(COCKTAIL_CATEGORIES);
</script>

<template>
  <UDashboardPanel id="cocktails">
    <template #header>
      <DefaultPageToolbar title="Cocktails" />
    </template>

    <template #body>
      <UContainer>
        <div class="flex gap-4 items-center mb-4">
          <UInput
            v-model="search"
            placeholder="Search cocktails..."
            class="max-w-xs"
            :loading="isLoading"
          >
            <template #trailing>
              <UButton
                v-if="search"
                icon="i-lucide-x"
                color="neutral"
                variant="link"
                size="sm"
                @click="search = ''"
              />
            </template>
          </UInput>

          <USelectMenu
            v-model="filters.categories"
            multiple
            :items="categories"
            placeholder="Filter by category"
            class="max-w-xs"
          />

          <UPopover class="ml-auto">
            <UButton label="Add cocktail" />

            <template #content>
              <AddCocktailForm class="p-4" />
            </template>
          </UPopover>
        </div>

        <CocktailsTable :cocktails="data?.items || []" :loading="isLoading" />

        <UPagination
          v-if="data?.totalPages && data.totalPages > 1"
          v-model:page="page"
          :total="data?.total"
          :items-per-page="data?.pageSize"
          :ui="{
            root: 'mt-4',
            list: 'justify-center'
          }"
        />
      </UContainer>
    </template>
  </UDashboardPanel>
</template>
