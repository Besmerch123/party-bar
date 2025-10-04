<script setup lang="ts">
import { h, resolveComponent } from 'vue'
import type { TableColumn } from '#ui/types'
import { ULink } from '#components'
import type { Cocktail } from '../../../../functions/src/cocktail/cocktail.model'

const UBadge = resolveComponent('UBadge')

interface Props {
  cocktails: Cocktail[]
}

defineProps<Props>()

const columns: TableColumn<Cocktail>[] = [
  {
    accessorKey: 'title',
    header: 'Title',
    cell: ({ row }) => {
      return h(ULink, { class: 'font-medium', to: `/cocktails/${row.original.id}` }, row.getValue('title'))
    }
  },
  {
    accessorKey: 'categories',
    header: 'Categories',
    cell: ({ row }) => {
      const categories = row.getValue('categories') as string[]
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
      )
    }
  },
  {
    accessorKey: 'ingredients',
    header: 'Ingredients',
    cell: ({ row }) => {
      const items = row.getValue('ingredients') as string[]
      const count = items.length
      const text = count > 0 ? `${count} item${count !== 1 ? 's' : ''}` : 'None'
      return h('span', { class: 'text-sm text-muted' }, text)
    }
  },
  {
    accessorKey: 'equipments',
    header: 'Equipment',
    cell: ({ row }) => {
      const items = row.getValue('equipments') as string[]
      const count = items.length
      const text = count > 0 ? `${count} item${count !== 1 ? 's' : ''}` : 'None'
      return h('span', { class: 'text-sm text-muted' }, text)
    }
  },
  {
    accessorKey: 'createdAt',
    header: 'Created',
    cell: ({ row }) => {
      const date = row.getValue('createdAt') as Date | undefined
      if (!date) return 'N/A'
      const formatted = new Intl.DateTimeFormat('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric'
      }).format(date)
      return h('span', { class: 'text-sm text-muted' }, formatted)
    }
  }
]
</script>

<template>
  <UTable :data="cocktails" :columns="columns" class="flex-1" />
</template>
