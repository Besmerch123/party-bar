<script setup lang="ts">
import { h } from 'vue';
import type { TableColumn } from '#ui/types';
import { ULink } from '#components';
import { useLocale } from '~/composables/useLocale';
import type { Ingredient, IngredientCategory } from '~/types';
import CategoryBadge from './CategoryBadge.vue';

interface Props {
  ingredients: Ingredient[];
  loading?: boolean;
}

defineProps<Props>();

const locale = useLocale();

const formatter = new Intl.DateTimeFormat('en-US', {
  year: 'numeric',
  month: 'short',
  day: 'numeric'
});

const columns: TableColumn<Ingredient>[] = [
  {
    accessorKey: 'id',
    header: 'ID'
  },
  {
    accessorKey: 'title',
    header: 'Title',
    cell: ({ row }) => {
      return h(ULink, { class: 'font-medium', to: `/ingredients/${row.original.id}` }, () => row.original.title[locale.value] || 'N/A');
    }
  },
  {
    accessorKey: 'category',
    header: 'Category',
    cell: ({ row }) => {
      const category = row.getValue<IngredientCategory>('category');
      return h(CategoryBadge, { category });
    }
  },
  {
    accessorKey: 'createdAt',
    header: 'Created',
    cell: ({ row }) => {
      const date = row.getValue('createdAt') as Date | undefined;
      if (!date) return 'N/A';
      return h('span', { class: 'text-sm text-muted' }, formatter.format(new Date(row.original.createdAt!)));
    }
  }
];
</script>

<template>
  <UTable
    :data="ingredients"
    :columns="columns"
    :loading="loading"
    class="flex-1"
  />
</template>
