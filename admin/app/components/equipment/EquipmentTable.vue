<script setup lang="ts">
import { h } from 'vue';
import type { TableColumn } from '#ui/types';
import { ULink } from '#components';
import { useLocale } from '~/composables/useLocale';
import type { Equipment } from '../../../../functions/src/equipment/equipment.model';

interface Props {
  equipment: Equipment[];
  loading?: boolean;
}

defineProps<Props>();

const locale = useLocale();

const formatter = new Intl.DateTimeFormat('en-US', {
  year: 'numeric',
  month: 'short',
  day: 'numeric'
});

const columns: TableColumn<Equipment>[] = [
  {
    accessorKey: 'id',
    header: 'ID'
  },
  {
    accessorKey: 'title',
    header: 'Title',
    cell: ({ row }) => {
      return h(ULink, { class: 'font-medium', to: `/equipment/${row.original.id}` }, () => row.original.title[locale.value] || 'N/A');
    }
  },
  {
    accessorKey: 'image',
    header: 'Image',
    cell: ({ row }) => {
      const hasImage = !!row.getValue('image');
      return h('span', { class: 'text-sm text-muted' }, hasImage ? 'Yes' : 'No');
    }
  },
  {
    accessorKey: 'createdAt',
    header: 'Created',
    cell: ({ row }) => {
      return h('span', { class: 'text-sm text-muted' }, formatter.format(new Date(row.original.createdAt || '')));
    }
  }
];
</script>

<template>
  <UTable
    :data="equipment"
    :columns="columns"
    :loading="loading"
    class="flex-1"
  />
</template>
