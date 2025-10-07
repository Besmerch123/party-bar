import { httpsCallable, getFunctions } from 'firebase/functions';
import { useMutation } from '@tanstack/vue-query';
import type { StorageUploadRequest, StorageUploadResponse } from '~/types';

export function useFileUpload() {
  const app = useFirebaseApp();
  const toast = useToast();

  const functions = getFunctions(app);

  const uploadFiles = httpsCallable<StorageUploadRequest, StorageUploadResponse>(
    functions,
    'uploadStorageFiles'
  );

  return useMutation({
    mutationKey: ['upload-files'],
    mutationFn: async (payload: StorageUploadRequest) => {
      const result = await uploadFiles(payload);

      return result.data;
    },
    onSuccess: (result) => {
      toast.add({
        color: 'success',
        title: 'Files uploaded successfully',
        description: `${result.files.length} file(s) uploaded`,
        duration: 5000
      });
    },
    onError: (error: Error) => {
      toast.add({
        color: 'error',
        title: 'Error uploading files',
        description: error.message,
        duration: 10000
      });
    }
  });
}
