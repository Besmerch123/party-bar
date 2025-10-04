import { getApp } from 'firebase/app';
import { getFunctions, connectFunctionsEmulator } from 'firebase/functions';

export default defineNuxtPlugin(() => {
  const app = getApp();

  const auth = useFirebaseAuth();
  if (!auth) {
    console.error('Firebase Auth not initialized!');
    return;
  }

  // Monitor auth state changes
  auth.onAuthStateChanged((user) => {
    if (user) {
      console.log('User authenticated:', user.email);
    }
  });

  const config = useRuntimeConfig();

  const functions = getFunctions(app);

  if (config.public.useEmulators) {
    connectFunctionsEmulator(functions, 'localhost', 5001);
  }
});
