<template>
  <UDashboardPanel id="cocktails">
    <template #header>
      <UDashboardNavbar title="Cocktails" :ui="{ right: 'gap-3' }">
        <template #leading>
          <UDashboardSidebarCollapse />
        </template>
      </UDashboardNavbar>
    </template>

    <template #body>
      <UContainer>
        Cocktails page
      </UContainer>
    </template>
  </UDashboardPanel>
</template>
