<script setup lang="ts">
import EquipmentTable from '~/components/equipment/EquipmentTable.vue';
import { useEquipment } from '~/composables/useEquipment';
import DefaultPageToolbar from '~/components/DefaultPageToolbar.vue';
import type { Equipment } from '~/types';

const { data, fetchNextPage, hasNextPage, isPending, isLoading } = useEquipment();

const equipment = computed<Equipment[]>(() => {
  return (data?.value?.pages || []).flatMap((page) => {
    const equipments = page.equipments || [];

    return equipments.map((doc) => {
      const { title, image, createdAt, updatedAt } = doc.data();

      return {
        id: doc.id,
        title,
        image,
        createdAt: createdAt?.toDate().toString() || undefined,
        updatedAt: updatedAt?.toDate().toString() || undefined
      };
    });
  });
});
</script>

<template>
  <UDashboardPanel id="equipments">
    <template #header>
      <DefaultPageToolbar title="Equipment" />
    </template>

    <template #body>
      <UContainer>
        <div class="flex gap-4 items-center justify-end mb-4">
          <UButton
            icon="i-lucide-plus"
            to="/equipment/create"
          >
            Add Equipment
          </UButton>
        </div>

        <EquipmentTable :equipment :loading="isPending || isLoading" />

        <div class="mt-4 flex justify-center">
          <LoadMore
            v-if="hasNextPage"
            :loading="isLoading"
            @click="fetchNextPage()"
          >
            Load more
          </LoadMore>
        </div>
      </UContainer>
    </template>
  </UDashboardPanel>
</template>
