<script setup lang="ts">
import type { FormSubmitEvent } from '@nuxt/ui';
import { INGREDIENT_CATEGORIES } from '../../../../functions/src/ingredient/ingredient.model';
import type { IngredientDocument, IngredientCategory, I18nField } from '~/types';
import GeneratableImageFormField from '~/components/image-generation/GeneratableImageFormField.vue';

const props = defineProps<{
  ingredientId?: string;
  ingredientDocument?: IngredientDocument;
}>();

type FormState = {
  title: I18nField;
  category: IngredientCategory;
  image?: string | null;
  slug?: string | null;
};

// Form state
const formData = ref<FormState>({
  title: { en: '', uk: '', ...props.ingredientDocument?.title },
  category: props.ingredientDocument?.category || 'other',
  image: props.ingredientDocument?.image,
  slug: props.ingredientDocument?.slug ?? ''
});

// Category options for select
const categoryOptions: string[] = Object.values(INGREDIENT_CATEGORIES);

const { mutate: saveIngredient, isPending } = useIngredientSave();

const submitHandler = async (event: FormSubmitEvent<FormState>) => {
  const data = event.data;

  await saveIngredient({
    id: props.ingredientId,
    ...data,
    // An emptied field means "no shelf key", not an empty one.
    slug: data.slug?.trim() || null
  });
};

const ingredientGenerationPrompt = computed(() => {
  return `${formData.value.title.en} - ${formData.value.category} - cocktail ingredient`;
});

defineExpose({
  isSaving: isPending
});
</script>

<template>
  <UForm
    id="ingredient-form"
    :state="formData"
    :disabled="isPending"
    class="grid grid-cols-2 gap-4"
    @submit="submitHandler"
  >
    <!-- Title Field -->
    <UFormField label="Title" name="title" required>
      <I18nFormField v-model="formData.title" />
    </UFormField>

    <!-- Category Field -->
    <UFormField
      label="Category"
      name="category"
      required
    >
      <USelectMenu
        v-model="formData.category"
        :items="categoryOptions"
        class="capitalize"
      />
    </UFormField>

    <!--
      The key the on-device shelf is stored as. A shelf is collected during
      onboarding before any account exists, so it holds these rather than
      document ids -- this field is what lets that shelf resolve to a real
      ingredient later. camelCase, unlike the kebab-case document id.
    -->
    <UFormField
      label="Shelf slug"
      name="slug"
      help="camelCase key the app's shelf stores, e.g. sweetVermouth. Leave blank if unused."
    >
      <UInput
        v-model="formData.slug"
        placeholder="sweetVermouth"
        class="w-full"
      />
    </UFormField>

    <!-- Image Field -->
    <GeneratableImageFormField
      v-model:image-src="formData.image"
      label="Image"
      name="image"
      template="ingredient"
      :title="ingredientDocument?.title.en || ''"
      :prompt="ingredientGenerationPrompt"
    />

    <!--
      Derived from the whole cocktail collection, so there is nothing to edit
      here: adding one cocktail moves these on every ingredient it touches.
      Settings › Recount catalogue recomputes them.
    -->
    <div v-if="ingredientId" class="col-span-2 flex gap-8 rounded-lg border border-default p-4">
      <div>
        <p class="text-xs text-muted uppercase">
          In drinks
        </p>
        <p class="text-lg font-medium">
          {{ ingredientDocument?.cocktailCount ?? '—' }}
        </p>
      </div>

      <div>
        <p class="text-xs text-muted uppercase">
          Unlocks
        </p>
        <p class="text-lg font-medium">
          {{ ingredientDocument?.unlocks ?? '—' }}
        </p>
      </div>

      <p class="text-xs text-muted self-end">
        Computed from the catalogue — recount from Settings to refresh.
      </p>
    </div>
  </UForm>
</template>
