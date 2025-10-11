<script setup lang="ts">
import { useEquipmentDetail } from '~/composables/useEquipmentDetail';
import { useLocale } from '~/composables/useLocale';

const route = useRoute();

const equipmentId = computed(() => route.params.id as string);
const isCreatePage = computed(() => equipmentId.value === 'create');

const locale = useLocale();

const { data, isLoading, error } = useEquipmentDetail(equipmentId.value);

const equipmentForm = useTemplateRef('equipmentForm');
</script>

<template>
  <UDashboardPanel id="equipment">
    <template #header>
      <DefaultPageToolbar :title="data?.equipment.title[locale]" />
    </template>
    <template #body>
      <UContainer>
        <UDashboardToolbar :ui="{ root: 'mb-6 px-0 sm:px-0 border-none' }">
          <template #left>
            <UButton
              variant="ghost"
              color="neutral"
              icon="i-lucide-chevron-left"
              to="/equipment"
            >
              Back to Equipment
            </UButton>
          </template>

          <template #right>
            <UButton
              form="equipment-form"
              type="submit"
              color="neutral"
              class="cursor-pointer"
              :loading="equipmentForm?.isSaving"
            >
              Save
            </UButton>
          </template>
        </UDashboardToolbar>

        <div v-if="isLoading" class="flex justify-center items-center h-64">
          <UIcon name="i-lucide-loader-circle" class="animate-spin size-8" />
        </div>

        <div v-else-if="error" class="flex justify-center items-center h-64">
          <p class="text-error">
            Error loading equipment: {{ error.message }}
          </p>
        </div>

        <div v-else class="py-8">
          <EquipmentForm
            ref="equipmentForm"
            :equipment-id="isCreatePage ? undefined : equipmentId"
            :equipment-document="data?.equipment"
          />
        </div>
      </UContainer>
    </template>
  </UDashboardPanel>
</template>
