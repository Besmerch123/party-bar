<script setup lang="ts">
/**
 * How much of one ingredient the recipe wants.
 *
 * Sits on the ingredient's own card rather than in a separate table, because a
 * measure only means anything next to the ingredient it belongs to -- the
 * stored map is keyed by ingredient id and a stray key is rejected on save.
 */
import { MEASURE_UNITS } from '../../../../functions/src/cocktail/cocktail.model';
import type { IngredientMeasure, MeasureUnit } from '~/types';

const model = defineModel<IngredientMeasure | undefined>({ required: true });

const unitOptions: MeasureUnit[] = Object.values(MEASURE_UNITS);

/**
 * `splash` and `topUp` carry no meaningful amount -- the app prints "top up
 * with tonic", never "1 top up with tonic" -- so the amount input goes away
 * rather than sitting there inviting a number nothing will render.
 */
const showsAmount = computed(
  () => model.value?.unit !== MEASURE_UNITS.TOP_UP && model.value?.unit !== MEASURE_UNITS.SPLASH
);

const amount = computed({
  get: () => model.value?.amount ?? 0,
  set: (value: number) => {
    model.value = { ...defaults(), ...model.value, amount: value ?? 0 };
  }
});

const unit = computed({
  get: () => model.value?.unit ?? MEASURE_UNITS.ML,
  set: (value: MeasureUnit) => {
    const next = { ...defaults(), ...model.value, unit: value };

    // Switching to a unit that carries no amount clears the stale number
    // instead of storing "0 topUp".
    if (value === MEASURE_UNITS.TOP_UP || value === MEASURE_UNITS.SPLASH) {
      next.amount = 0;
    }

    model.value = next;
  }
});

/**
 * Garnishes and top-ups. Marked optional they stop counting against "makeable
 * with my bar" -- nobody is blocked from a Negroni by a missing orange twist.
 */
const optional = computed({
  get: () => model.value?.optional ?? false,
  set: (value: boolean) => {
    model.value = { ...defaults(), ...model.value, optional: value };
  }
});

function defaults(): IngredientMeasure {
  return { amount: 0, unit: MEASURE_UNITS.ML, optional: false };
}
</script>

<template>
  <div class="px-2 pb-2 space-y-2">
    <UFieldGroup class="w-full">
      <UInputNumber
        v-if="showsAmount"
        v-model="amount"
        :min="0"
        :step="0.5"
        class="w-full"
        :ui="{ base: 'text-sm' }"
      />

      <USelect
        v-model="unit"
        :items="unitOptions"
        class="w-full"
        size="sm"
      />
    </UFieldGroup>

    <USwitch
      v-model="optional"
      label="Optional"
      size="sm"
      :ui="{ label: 'text-xs text-muted' }"
    />
  </div>
</template>
