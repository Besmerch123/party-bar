<script setup lang="ts">
/**
 * The guided pour.
 *
 * `preparationSteps` stays the readable recipe; this is the same recipe cut
 * into the units a person actually performs with their hands busy, plus the
 * countdown a step needs. A cocktail without these still works -- "Make it
 * now" falls back to the plain steps -- so the whole field is optional, but a
 * step with an empty title is rejected on save: a blank screen mid-pour is
 * worse than no guided pour at all.
 */
import { useLocale } from '~/composables/useLocale';
import type { PourStep } from '~/types';

const model = defineModel<PourStep[]>({ required: true });

const locale = useLocale();

const addStep = () => {
  model.value = [...model.value, { title: {}, durationSeconds: null }];
};

const removeStep = (index: number) => {
  model.value = model.value.filter((_, i) => i !== index);
};

const moveStep = (index: number, offset: number) => {
  const target = index + offset;
  if (target < 0 || target >= model.value.length) return;

  const next = [...model.value];
  const [moved] = next.splice(index, 1);
  next.splice(target, 0, moved!);
  model.value = next;
};

/**
 * Only the active locale is edited at a time, matching every other translated
 * field in the panel. Writing into the step's own object keeps the other
 * locale's text intact.
 */
const setTitle = (index: number, value: string) => {
  const next = [...model.value];
  next[index] = { ...next[index]!, title: { ...next[index]!.title, [locale.value]: value } };
  model.value = next;
};

const setBody = (index: number, value: string) => {
  const next = [...model.value];
  const body = { ...next[index]!.body, [locale.value]: value };

  // An emptied body is dropped rather than stored as "" -- the app renders the
  // step without a detail line, which is what most steps want.
  const hasText = Object.values(body).some(text => text && text.trim().length > 0);

  next[index] = { ...next[index]!, body: hasText ? body : undefined };
  model.value = next;
};

/**
 * A timer runs only where the step is genuinely timed. Blank means no
 * countdown, which is the common case.
 */
const setDuration = (index: number, value: number | undefined) => {
  const next = [...model.value];
  next[index] = { ...next[index]!, durationSeconds: value && value > 0 ? value : null };
  model.value = next;
};
</script>

<template>
  <UFormField
    label="Pour steps"
    :ui="{ container: 'space-y-3' }"
  >
    <template #hint>
      <span class="text-xs text-muted">
        Optional — the app falls back to the preparation steps when empty
      </span>
    </template>

    <div
      v-for="(step, i) in model"
      :key="i"
      class="rounded-lg border border-default p-3 space-y-2"
    >
      <div class="flex items-center gap-2">
        <span class="text-xs font-medium text-muted w-6 shrink-0">{{ i + 1 }}</span>

        <UInput
          :model-value="step.title?.[locale] ?? ''"
          placeholder="Shake hard"
          class="flex-1"
          @update:model-value="setTitle(i, String($event))"
        />

        <UInputNumber
          :model-value="step.durationSeconds ?? undefined"
          placeholder="Timer"
          :min="0"
          class="w-28 shrink-0"
          @update:model-value="setDuration(i, $event)"
        />

        <span class="text-xs text-muted shrink-0">sec</span>

        <UButton
          icon="i-lucide-chevron-up"
          variant="ghost"
          color="neutral"
          size="xs"
          class="cursor-pointer"
          :disabled="i === 0"
          @click="moveStep(i, -1)"
        />

        <UButton
          icon="i-lucide-chevron-down"
          variant="ghost"
          color="neutral"
          size="xs"
          class="cursor-pointer"
          :disabled="i === model.length - 1"
          @click="moveStep(i, 1)"
        />

        <UButton
          icon="i-lucide-x"
          variant="ghost"
          color="error"
          size="xs"
          class="cursor-pointer"
          @click="removeStep(i)"
        />
      </div>

      <UInput
        :model-value="step.body?.[locale] ?? ''"
        placeholder="Detail (optional) — until the tin frosts over"
        class="w-full"
        size="sm"
        @update:model-value="setBody(i, String($event))"
      />
    </div>

    <UButton
      icon="i-lucide-plus"
      variant="ghost"
      class="cursor-pointer"
      @click="addStep"
    >
      Add pour step
    </UButton>
  </UFormField>
</template>
