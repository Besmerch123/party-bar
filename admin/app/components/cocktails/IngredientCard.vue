<script setup lang="ts">
import { useLocale } from '~/composables/useLocale';
import type { IngredientDocument } from '~/types';
import ItemCard from './ItemCard.vue';

const locale = useLocale();

defineProps<{ ingredient: IngredientDocument; id: string }>();

defineEmits<{ remove: [id: string] }>();
</script>

<template>
  <ItemCard
    :image-src="ingredient.image"
    :title="ingredient.title[locale]"
    :subtitle="ingredient.category"
    :to="`/ingredients/${id}`"
    @remove="$emit('remove', id)"
  />
</template>
