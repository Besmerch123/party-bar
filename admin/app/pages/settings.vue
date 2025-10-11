<script setup lang="ts">
import { useMutation } from '@tanstack/vue-query';
import { httpsCallable } from 'firebase/functions';

const functions = useFunctions();

const reStreamCocktailsFunction = httpsCallable<unknown, { processed: number; errors: number }>(functions, 'reStreamCocktails');
const toast = useToast();

const { mutate: reStreamCocktails, isPending } = useMutation({
  mutationFn: () => reStreamCocktailsFunction(),
  onSuccess: (data) => {
    toast.add({
      color: 'success',
      title: 'Re-stream initiated',
      description: `Processed: ${data.data.processed}, Errors: ${data.data.errors}`,
      duration: 5000
    });
  },
  onError: (error) => {
    toast.add({
      color: 'error',
      title: 'Error',
      description: error.message || 'An error occurred while re-streaming cocktails.',
      duration: 5000
    });
  }
});
</script>

<template>
  <UDashboardPanel id="settings">
    <template #header>
      <DefaultPageToolbar title="Settings" />
    </template>

    <template #body>
      <UContainer>
        <UDashboardToolbar
          title="Settings"
          subtitle="Manage your application settings"
        >
          <UButton
            color="primary"
            :loading="isPending"
            @click="reStreamCocktails()"
          >
            Re-stream Cocktails
          </UButton>
        </UDashboardToolbar>
      </UContainer>
    </template>
  </UDashboardPanel>
</template>
