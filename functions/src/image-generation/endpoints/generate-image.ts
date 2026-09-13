/**
 * Generate Image Endpoint
 *
 * Runs server-side, on the function's own service credentials, rather than
 * calling Gemini from the admin panel directly. The client-facing route
 * (Firebase AI Logic's client SDK) requires App Check enforcement to guard
 * against abuse; a callable function has no such requirement, since it's
 * already gated by Firebase Auth and never exposes the model to a browser.
 */

import { onCall, HttpsError } from 'firebase-functions/https';
import { GoogleGenAI } from '@google/genai';

import type { GenerateImageRequest, GenerateImageResponse } from '../image-generation.model';
import { promptTemplates } from '../image-generation.model';

// TODO: Vertex AI lists `gemini-3.1-flash-image` as GA in the model catalog,
// but this project gets a 404 "not found or your project does not have
// access to it" when actually calling it -- rollout/allowlisting hasn't
// reached this project yet. Falling back to the previous generation, which
// works today but is scheduled to shut down 2026-10-02. Retry 3.1 (or
// whatever has replaced it) before then.
const IMAGE_MODEL = 'gemini-2.5-flash-image';

export const generateImage = onCall<GenerateImageRequest, Promise<GenerateImageResponse>>(
  { timeoutSeconds: 120 },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'User must be authenticated');
    }

    const { template, description } = request.data ?? {};

    if (!template || !(template in promptTemplates)) {
      throw new HttpsError('invalid-argument', `Unknown image template: ${template}`);
    }

    if (!description || typeof description !== 'string' || !description.trim()) {
      throw new HttpsError('invalid-argument', 'A description is required to generate an image.');
    }

    const projectId = process.env.GCLOUD_PROJECT || process.env.GOOGLE_CLOUD_PROJECT;
    if (!projectId) {
      throw new HttpsError('internal', 'Project ID is not configured');
    }

    const location = process.env.GOOGLE_CLOUD_LOCATION || process.env.VERTEX_LOCATION || 'us-central1';
    const ai = new GoogleGenAI({ vertexai: true, project: projectId, location });

    const prompt = promptTemplates[template](description.trim());

    try {
      const result = await ai.models.generateContent({
        model: IMAGE_MODEL,
        contents: prompt,
        config: {
          responseModalities: ['IMAGE'],
          imageConfig: { aspectRatio: '1:1' },
        },
      });

      const imagePart = result.candidates?.[0]?.content?.parts?.find((part) => part.inlineData?.data);
      const image = imagePart?.inlineData;

      if (!image?.data) {
        throw new Error('The model did not return an image');
      }

      return { mimeType: image.mimeType ?? 'image/png', data: image.data };
    } catch (error) {
      console.error(`Error generating ${template} image:`, error);

      if (error instanceof HttpsError) {
        throw error;
      }

      throw new HttpsError(
        'internal',
        error instanceof Error ? error.message : 'An error occurred while generating the image'
      );
    }
  }
);
