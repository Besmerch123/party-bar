<script setup lang="ts">
defineProps<{ title?: string }>();
</script>

<template>
  <UDashboardToolbar>
    <template #left>
      <UDashboardSidebarCollapse />

      <slot name="title">
        <h1 class="text-lg font-medium">
          {{ title }}
        </h1>
      </slot>
    </template>

    <template #right>
      <LocaleSwitcher />
    </template>
  </UDashboardToolbar>
</template>
