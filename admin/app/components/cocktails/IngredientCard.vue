<script setup lang="ts">
import { useLocale } from '~/composables/useLocale';
import type { IngredientDocument } from '~/types';
import ItemCard from './ItemCard.vue';

const locale = useLocale();

defineProps<{ ingredient: IngredientDocument }>();
</script>

<template>
  <ItemCard
    :image-src="ingredient.image"
    :title="ingredient.title[locale]"
    :subtitle="ingredient.category"
  />
</template>
