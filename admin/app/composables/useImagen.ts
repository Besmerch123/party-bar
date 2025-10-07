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
      model: 'imagen-4.0-generate-001',
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
    return description;
  },

  cocktail: (description: string) => {
    return description;
  }
};
