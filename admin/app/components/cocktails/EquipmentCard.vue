<script setup lang="ts">
import { useLocale } from '~/composables/useLocale';
import type { EquipmentDocument } from '../../../../functions/src/equipment/equipment.model';

const locale = useLocale();

defineProps<{ equipment: EquipmentDocument }>();
</script>

<template>
  <div class="rounded p-2 shadow-sm">
    <h3 class="text-md font-semibold mb-2">
      {{ equipment.title[locale] }}
    </h3>
  </div>
</template>
