<script setup lang="ts">
import { h } from 'vue';
import type { TableColumn } from '#ui/types';
import { ULink, UBadge } from '#components';
import { useLocale } from '~/composables/useLocale';
import type { CocktailSearchDocument } from '~/types';

defineProps<{ cocktails: CocktailSearchDocument[] }>();

const locale = useLocale();

// const formatter = new Intl.DateTimeFormat('en-US', {
//   year: 'numeric',
//   month: 'short',
//   day: 'numeric'
// });

const columns: TableColumn<CocktailSearchDocument>[] = [
  {
    accessorKey: 'title',
    header: 'Title',
    cell: ({ row }) => {
      return h(ULink, { class: 'font-medium', to: `/cocktails/${row.original.id}` }, row.original.title[locale.value] || 'N/A');
    }
  },
  {
    accessorKey: 'categories',
    header: 'Categories',
    cell: ({ row }) => {
      const categories = row.getValue('categories') as string[];
      return h(
        'div',
        { class: 'flex flex-wrap gap-1' },
        categories.map(category =>
          h(
            UBadge,
            {
              key: category,
              color: 'primary',
              variant: 'subtle'
            },
            () => category
          )
        )
      );
    }
  },
  {
    accessorKey: 'ingredients',
    header: 'Ingredients',
    cell: ({ row }) => {
      const items = row.original.ingredients.map(i => i.title[locale.value] || 'N/A').join(', ');

      return h('span', { class: 'text-sm text-muted max-w-xs inline-block truncate' }, items);
    }
  },
  {
    accessorKey: 'equipments',
    header: 'Equipment',
    cell: ({ row }) => {
      const items = row.original.equipment.map(e => e.title[locale.value] || 'N/A').join(', ');

      return h('span', { class: 'text-sm text-muted max-w-xs inline-block truncate' }, items);
    }
  }
  // {
  //   accessorKey: 'createdAt',
  //   header: 'Created',
  //   cell: ({ row }) => {
  //     const date = row.getValue('createdAt') as Date | undefined;
  //     if (!date) return 'N/A';
  //     const formatted = new Intl.DateTimeFormat('en-US', {
  //       year: 'numeric',
  //       month: 'short',
  //       day: 'numeric'
  //     }).format(date);
  //     return h('span', { class: 'text-sm text-muted' }, formatted);
  //   }
  // }
];
</script>

<template>
  <UTable :data="cocktails" :columns="columns" class="flex-1" />
</template>
