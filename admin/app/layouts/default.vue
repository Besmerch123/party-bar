<script setup lang="ts">
import type { NavigationMenuItem } from '@nuxt/ui'

const open = ref(false)

const onSelect = () => {
  open.value = false
}

const links = [{
  label: 'Home',
  icon: 'i-lucide-house',
  to: '/',
  onSelect
}, {
  label: 'Cocktails',
  icon: 'i-lucide-martini',
  to: '/cocktails',
  onSelect
}, {
  label: 'Customers',
  icon: 'i-lucide-users',
  to: '/customers',
  onSelect
}, {
  label: 'Settings',
  to: '/settings',
  icon: 'i-lucide-settings',
  defaultOpen: true,
  type: 'trigger',
  children: [{
    label: 'General',
    to: '/settings',
    exact: true,
    onSelect
  }, {
    label: 'Members',
    to: '/settings/members',
    onSelect
  }, {
    label: 'Notifications',
    to: '/settings/notifications',
    onSelect
  }, {
    label: 'Security',
    to: '/settings/security',
    onSelect
  }]
}] satisfies NavigationMenuItem[]
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
