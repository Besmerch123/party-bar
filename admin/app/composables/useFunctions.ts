import { getFunctions, connectFunctionsEmulator } from 'firebase/functions';
import { getApp } from 'firebase/app';

export function useFunctions() {
  const app = getApp();
  const config = useRuntimeConfig();

  const functions = getFunctions(app, 'us-central1');

  // For local development, use emulator
  if (config.public.useEmulators) {
    connectFunctionsEmulator(functions, 'localhost', 5001);
  }

  return functions;
}
