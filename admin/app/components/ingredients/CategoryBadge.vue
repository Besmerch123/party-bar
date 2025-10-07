<script setup lang="ts">
import type { IngredientCategory } from '~/types';
import type { BadgeProps } from '@nuxt/ui';

defineProps<{ category: IngredientCategory }>();

const colorsMap: Partial<Record<IngredientCategory, BadgeProps['color']>> = {
  spirit: 'error',
  liqueur: 'warning',
  mixer: 'info',
  syrup: 'secondary',
  bitters: 'neutral',
  garnish: 'neutral',
  fruit: 'success'
};
</script>

<template>
  <UBadge
    :color="colorsMap[category]"
    class="capitalize"
    variant="subtle"
  >
    {{ category }}
  </UBadge>
</template>
