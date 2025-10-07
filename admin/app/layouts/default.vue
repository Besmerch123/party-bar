<script setup lang="ts">
import type { NavigationMenuItem } from '@nuxt/ui';

const open = ref(false);

const onSelect = () => {
  open.value = false;
};

const links = [
  {
    label: 'Cocktails',
    icon: 'i-lucide-martini',
    to: '/cocktails',
    onSelect
  },
  {
    label: 'Ingredients',
    icon: 'i-lucide-cherry',
    to: '/ingredients',
    onSelect
  },
  {
    label: 'Equipment',
    icon: 'i-lucide-amphora',
    to: '/equipment',
    onSelect
  }
] satisfies NavigationMenuItem[];
</script>

<template>
  <UDashboardGroup unit="rem">
    <UDashboardSidebar
      id="default"
      v-model:open="open"
      collapsible
      resizable
      class="bg-elevated/25"
      :ui="{ footer: 'lg:border-t lg:border-default' }"
    >
      <template #header="{ collapsed }">
        <UserMenu :collapsed="collapsed" />
      </template>

      <template #default="{ collapsed }">
        <UNavigationMenu
          :collapsed="collapsed"
          :items="links"
          orientation="vertical"
          tooltip
          popover
        />
      </template>
    </UDashboardSidebar>

    <slot />

    <NotificationsSlideover />
  </UDashboardGroup>
</template>
