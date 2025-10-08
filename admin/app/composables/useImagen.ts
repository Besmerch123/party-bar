import { useMutation } from '@tanstack/vue-query';
import { getAI, getImagenModel, VertexAIBackend } from 'firebase/ai';
import type { ImageTemplate } from '~/types';

export interface GenerateImagePayload {
  /** Template type: equipment, ingredient, or cocktail */
  template: ImageTemplate;
  /** Description of what should be in the image */
  description: string;
}
export function useImagen() {
  const app = useFirebaseApp();

  const ai = getAI(app, { backend: new VertexAIBackend('us-central1') });

  const model = getImagenModel(
    ai,
    {
      model: 'imagen-4.0-fast-generate-001',
      generationConfig: {
        numberOfImages: 4,
        aspectRatio: '1:1',
        imageFormat: {
          mimeType: 'image/jpeg'
        },
        addWatermark: false
      }
    }
  );

  return useMutation({
    mutationKey: ['generate-image'],
    mutationFn: async ({ template, description }: GenerateImagePayload) => {
      const prompt = promptTemplates[template](description);

      if (!prompt || prompt.trim() === '') {
        throw new Error(`Image generation for template "${template}" is not yet implemented`);
      }

      const response = await model.generateImages(prompt);

      return response.images;
    }
  });
}

export const promptTemplates: Record<ImageTemplate, (description: string) => string> = {
  equipment: (description: string) => {
    return `Create a high-quality, professional photograph of bar equipment: ${description}

Style requirements:
- Dark blue gradient background with dark grey
- Only show the described bar equipment, nothing else in the image
- Professional product photography lighting
- Sharp focus with proper depth of field
- Realistic materials and textures
- Show the item at a slight angle for dimension
- No text, watermarks, or labels on the image or on the object itself
- Clean, isolated product shot
- High resolution, studio-quality image

The equipment should look pristine, professional, and ready for use in a high-end bar.`;
  },

  ingredient: (description: string) => {
    return `Create a high-quality, professional photograph of a bar ingredient: ${description}

Style requirements:
- Background gradient should match the ingredient's natural color blending into dark grey:
  * For colorful fruits (orange, lemon, lime): use their natural color (orange, yellow, green) gradient with dark grey
  * For green ingredients (mint, basil, green apple): use green gradient with dark grey
  * For red ingredients (strawberry, cherry, grenadine): use red gradient with dark grey
  * For spirits and liqueurs: match the bottle's typical color (amber for whiskey, clear for vodka, etc.) with dark grey
  * For neutral/white ingredients: use soft white to dark grey gradient
- ALL liquids, spirits, and liqueurs MUST be shown in their characteristic bottles
- Bottles should be premium, elegant, and professional-looking
- For fresh ingredients (fruits, herbs): show them fresh and vibrant
- Professional product photography lighting
- Sharp focus with proper depth of field
- Realistic materials and textures
- Show the item at a slight angle for dimension
- No text, watermarks, brand names, or labels on the image or bottles
- Clean, isolated product shot
- High resolution, studio-quality image

The ingredient should look premium, fresh, and ready for use in a high-end cocktail bar.`;
  },

  cocktail: (description: string) => {
    return `Create a high-quality, professional photograph of a cocktail ready to serve: ${description}

Scene requirements:
- Cocktail positioned on a polished dark wood bar counter or elegant bar surface
- Natural bar lighting with subtle ambient atmosphere
- The cocktail should be in an appropriate glass for its style (martini glass, rocks glass, highball, etc.)
- Perfectly mixed and presented, ready for a customer to pick up
- Show the cocktail with all described ingredients and garnishes
- Include appropriate ice if mentioned (crushed, cubed, or large ice sphere)
- Garnishes should be fresh, properly placed, and match the description
- Background should be softly blurred bar environment (bokeh effect)
- Professional bar photography style
- Warm, inviting lighting that highlights the drink
- Sharp focus on the cocktail glass
- Realistic condensation on glass if it's a cold drink
- No text, watermarks, labels, or menus in the image
- The drink should look refreshing, appealing, and professionally made

The cocktail should look as if it was just expertly crafted by a skilled bartender and is ready to be served to a guest at a premium cocktail bar.`;
  }
};
