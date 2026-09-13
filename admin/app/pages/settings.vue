<script setup lang="ts">
import { useMutation } from '@tanstack/vue-query';
import { httpsCallable } from 'firebase/functions';

const functions = useFunctions();
const toast = useToast();

// --- Re-stream to Elastic
const reStreamCocktailsFunction = httpsCallable<unknown, { processed: number; errors: number }>(functions, 'reStreamCocktails');

const { mutate: reStreamCocktails, isPending: isReStreaming } = useMutation({
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

// --- Recount the derived figures
interface RecountResult {
  cocktails: number;
  ingredientsUpdated: number;
  equipmentUpdated: number;
  typicalShelf: string[];
}

const recountCatalogueFunction = httpsCallable<unknown, RecountResult>(functions, 'recountCatalogue');

const { mutate: recountCatalogue, isPending: isRecounting } = useMutation({
  mutationFn: () => recountCatalogueFunction(),
  onSuccess: ({ data }) => {
    toast.add({
      color: 'success',
      title: 'Catalogue recounted',
      description: `${data.cocktails} cocktails scanned · ${data.ingredientsUpdated} ingredients and ${data.equipmentUpdated} equipment updated`,
      duration: 8000
    });
  },
  onError: (error) => {
    toast.add({
      color: 'error',
      title: 'Recount failed',
      description: error.message,
      duration: 10000
    });
  }
});

// --- Backfill the recipe vocabulary
interface BackfillResult {
  processed: number;
  updated: number;
  skipped: number;
  failures: Array<{ id: string; error: string }>;
  hasMore: boolean;
}

const backfillCocktailsFunction = httpsCallable<
  { limit?: number; force?: boolean },
  BackfillResult
>(functions, 'backfillCocktails');

/**
 * Each cocktail is a Gemini round trip, so the backfill runs in batches rather
 * than sweeping the catalogue in one invocation. `hasMore` says whether there
 * is still work left.
 */
const backfillLimit = ref(10);
const backfillForce = ref(false);
const lastBackfill = ref<BackfillResult | null>(null);

const { mutate: backfillCocktails, isPending: isBackfilling } = useMutation({
  mutationFn: () => backfillCocktailsFunction({
    limit: backfillLimit.value,
    force: backfillForce.value
  }),
  onSuccess: ({ data }) => {
    lastBackfill.value = data;

    toast.add({
      color: data.failures.length > 0 ? 'warning' : 'success',
      title: 'Backfill batch complete',
      description: `${data.updated} updated, ${data.failures.length} failed, ${data.skipped} already complete`
        + (data.hasMore ? ' — more remaining, run again.' : ''),
      duration: 8000
    });
  },
  onError: (error) => {
    toast.add({
      color: 'error',
      title: 'Backfill failed',
      description: error.message,
      duration: 10000
    });
  }
});

const isBusy = computed(() => isReStreaming.value || isRecounting.value || isBackfilling.value);
</script>

<template>
  <UDashboardPanel id="settings">
    <template #header>
      <DefaultPageToolbar title="Settings" />
    </template>

    <template #body>
      <UContainer class="space-y-4 py-4">
        <UCard>
          <template #header>
            <h2 class="font-medium">
              Search index
            </h2>
            <p class="text-sm text-muted">
              Rebuilds the Elasticsearch index from Firestore. Run after a bulk edit,
              or when search results look stale.
            </p>
          </template>

          <UButton
            color="neutral"
            class="cursor-pointer"
            :loading="isReStreaming"
            :disabled="isBusy && !isReStreaming"
            @click="reStreamCocktails()"
          >
            Re-stream cocktails
          </UButton>
        </UCard>

        <UCard>
          <template #header>
            <h2 class="font-medium">
              Catalogue figures
            </h2>
            <p class="text-sm text-muted">
              Recomputes “in N drinks” on every ingredient and piece of equipment, and
              “unlocks N more” on every ingredient. These are derived from the whole
              cocktail collection, so one cocktail edit can move them across the
              catalogue — run this after adding or backfilling drinks.
            </p>
          </template>

          <UButton
            color="neutral"
            class="cursor-pointer"
            :loading="isRecounting"
            :disabled="isBusy && !isRecounting"
            @click="recountCatalogue()"
          >
            Recount catalogue
          </UButton>
        </UCard>

        <UCard>
          <template #header>
            <h2 class="font-medium">
              Backfill recipe details
            </h2>
            <p class="text-sm text-muted">
              Fills method, base spirit, flavour, prep time, measures and pour steps on
              cocktails that predate them. Until a drink has these it matches none of
              Explore's filters. Each drink is a separate AI generation, so this runs in
              batches — repeat until nothing remains.
            </p>
          </template>

          <div class="flex flex-wrap items-end gap-4">
            <UFormField label="Batch size" class="w-32">
              <UInputNumber
                v-model="backfillLimit"
                :min="1"
                :max="50"
                class="w-full"
              />
            </UFormField>

            <UFormField label="Re-generate complete drinks too">
              <USwitch v-model="backfillForce" />
            </UFormField>

            <UButton
              color="neutral"
              class="cursor-pointer"
              :loading="isBackfilling"
              :disabled="isBusy && !isBackfilling"
              @click="backfillCocktails()"
            >
              Run backfill batch
            </UButton>
          </div>

          <div v-if="lastBackfill" class="mt-4 space-y-2">
            <p class="text-sm">
              Last run: {{ lastBackfill.updated }} updated, {{ lastBackfill.skipped }} already complete,
              {{ lastBackfill.failures.length }} failed.
              <span v-if="lastBackfill.hasMore" class="text-warning">More cocktails still need backfilling.</span>
            </p>

            <ul v-if="lastBackfill.failures.length" class="text-sm text-error space-y-1">
              <li v-for="failure in lastBackfill.failures" :key="failure.id">
                <NuxtLink :to="`/cocktails/${failure.id}`" class="underline">
                  {{ failure.id }}
                </NuxtLink>
                — {{ failure.error }}
              </li>
            </ul>
          </div>
        </UCard>
      </UContainer>
    </template>
  </UDashboardPanel>
</template>
