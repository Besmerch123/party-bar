<script setup lang="ts">
import { useEquipmentDetail } from '~/composables/useEquipmentDetail';
import { useLocale } from '~/composables/useLocale';

const route = useRoute();
const equipmentId = route.params.id as string;

const locale = useLocale();

const { data, isLoading, error } = useEquipmentDetail(equipmentId);
</script>

<template>
  <UDashboardPanel id="equipment">
    <template #header>
      <DefaultPageToolbar :title="data?.equipment.title[locale]" />
    </template>
    <template #body>
      <UContainer>
        <div v-if="isLoading" class="flex justify-center items-center h-64">
          <UIcon name="i-lucide-loader-circle" class="animate-spin size-8" />
        </div>

        <div v-else-if="error" class="flex justify-center items-center h-64">
          <p class="text-error">
            Error loading equipment: {{ error.message }}
          </p>
        </div>

        <div v-else-if="data" class="py-8">
          <EquipmentForm
            :equipment-id="equipmentId"
            :equipment-document="data.equipment"
          />
        </div>
      </UContainer>
    </template>
  </UDashboardPanel>
</template>
