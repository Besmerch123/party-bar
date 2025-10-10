<script setup lang="ts">
import { useLocale } from '~/composables/useLocale';
import type { EquipmentDocument } from '~/types';
import ItemCard from './ItemCard.vue';

const locale = useLocale();

defineProps<{ equipment: EquipmentDocument; id: string }>();

defineEmits<{ remove: [id: string] }>();
</script>

<template>
  <ItemCard
    :image-src="equipment.image"
    :title="equipment.title[locale]"
    :to="`/equipment/${id}`"
    @remove="$emit('remove', id)"
  />
</template>
