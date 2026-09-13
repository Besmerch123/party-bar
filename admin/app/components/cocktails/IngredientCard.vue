<script setup lang="ts">
import { useLocale } from '~/composables/useLocale';
import type { Ingredient, IngredientMeasure } from '~/types';
import ItemCard from './ItemCard.vue';
import MeasureField from './MeasureField.vue';

const locale = useLocale();

defineProps<{ ingredient: Ingredient; id: string }>();

defineEmits<{ remove: [id: string] }>();

/** The recipe's quantity for this ingredient. Absent until someone sets one. */
const measure = defineModel<IngredientMeasure | undefined>('measure');
</script>

<template>
  <ItemCard
    :image-src="ingredient.image"
    :title="ingredient.title[locale]"
    :subtitle="ingredient.category"
    :to="`/ingredients/${id}`"
    @remove="$emit('remove', id)"
  >
    <MeasureField v-model="measure" />
  </ItemCard>
</template>
