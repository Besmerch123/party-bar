import { httpsCallable } from 'firebase/functions';
import { useMutation } from '@tanstack/vue-query';
import type { GenerateImageRequest, GenerateImageResponse } from '~/types';
import { useFunctions } from '~/composables/useFunctions';

export function useGenerateImage() {
  const functions = useFunctions();

  const generateImageCallable = httpsCallable<GenerateImageRequest, GenerateImageResponse>(
    functions,
    'generateImage'
  );

  return useMutation({
    mutationKey: ['generate-image'],
    mutationFn: async (payload: GenerateImageRequest): Promise<GenerateImageResponse> => {
      const result = await generateImageCallable(payload);

      return result.data;
    }
  });
}
