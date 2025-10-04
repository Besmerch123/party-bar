<script setup lang="ts">
import { useLocale } from '~/composables/useLocale';
import type { IngredientDocument } from '../../../../functions/src/ingredient/ingredient.model';

const locale = useLocale();

defineProps<{ ingredient: IngredientDocument }>();
</script>

<template>
  <div class="rounded p-2 shadow-sm">
    <h3 class="text-md font-semibold mb-2">
      {{ ingredient.title[locale] }}
    </h3>
    <p class="text-sm text-muted mb-1">
      {{ ingredient.category }}
    </p>
  </div>
</template>
