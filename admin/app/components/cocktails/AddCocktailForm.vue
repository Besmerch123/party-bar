<script setup lang="ts">
import { useCocktailGenerate } from '~/composables/useCocktailGenerate';

const name = ref('');
const preferences = ref('');

const { mutateAsync: generateCocktail, isPending } = useCocktailGenerate();

const submitHandler = async () => {
  await generateCocktail({ name: name.value, preferences: preferences.value });
  name.value = '';
  preferences.value = '';
};
</script>

<template>
  <UForm :disabled="isPending">
    <UFormField label="Cocktail name">
      <UInput v-model="name" placeholder="Enter cocktail name in English" />
    </UFormField>

    <UFormField label="Preferences">
      <UTextarea v-model="preferences" placeholder="E.g. I like sweet and sour cocktails with rum." />
    </UFormField>

    <div class="mt-4 flex justify-end">
      <UButton
        label="Add"
        color="primary"
        :disabled="name.length < 2"
        :loading="isPending"
        @click="submitHandler"
      />
    </div>
  </UForm>
</template>
