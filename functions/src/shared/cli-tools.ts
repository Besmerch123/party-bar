import { VertexAI } from '@google-cloud/vertexai';
import type { SupportedLocale } from './types';

/**
 * Configuration for Vertex AI integration
 */
export const DEFAULT_VERTEX_MODEL = 'gemini-2.5-flash';
export const DEFAULT_VERTEX_LOCATION = 'us-central1';

/**
 * Parses CLI arguments in a generic way
 */
export type CliParser<T> = {
  parse: (args: string[]) => T;
  printUsage: () => void;
};

/**
 * Gets the Google Cloud project ID from environment variables
 */
export function getProjectId(): string | undefined {
  if (process.env.GOOGLE_CLOUD_PROJECT) {
    return process.env.GOOGLE_CLOUD_PROJECT;
  }
  if (process.env.GCLOUD_PROJECT) {
    return process.env.GCLOUD_PROJECT;
  }
  if (process.env.FIREBASE_CONFIG) {
    try {
      const config = JSON.parse(process.env.FIREBASE_CONFIG) as { projectId?: string };
      return config.projectId;
    } catch (error) {
      console.warn('Failed to parse FIREBASE_CONFIG env variable.', error);
    }
  }
  return undefined;
}

/**
 * Initializes Vertex AI with project configuration
 */
export function initializeVertexAI(projectId: string): VertexAI {
  const location = process.env.GOOGLE_CLOUD_LOCATION || process.env.VERTEX_LOCATION || DEFAULT_VERTEX_LOCATION;
  return new VertexAI({ project: projectId, location });
}

/**
 * Gets the configured Vertex AI model name
 */
export function getVertexModel(): string {
  return process.env.VERTEX_MODEL || DEFAULT_VERTEX_MODEL;
}

/**
 * Gets the configured Vertex AI location
 */
export function getVertexLocation(): string {
  return process.env.GOOGLE_CLOUD_LOCATION || process.env.VERTEX_LOCATION || DEFAULT_VERTEX_LOCATION;
}

/**
 * Extracts text from a Vertex AI generation result
 */
export function extractTextResponse(
  result: Awaited<ReturnType<ReturnType<VertexAI['getGenerativeModel']>['generateContent']>>
): string | undefined {
  const candidates = result?.response?.candidates;
  if (!candidates || candidates.length === 0) {
    return undefined;
  }

  const parts = candidates[0]?.content?.parts;
  if (!parts || parts.length === 0) {
    return undefined;
  }

  return parts
    .map((part) => ('text' in part ? part.text : undefined))
    .filter((text): text is string => Boolean(text))
    .join('')
    .trim();
}

/**
 * Attempts to parse JSON from text, including relaxed parsing for malformed responses
 */
export function parseJsonResponse<T>(text: string): T {
  try {
    const parsed = JSON.parse(text);
    if (Array.isArray(parsed)) {
      return parsed as T;
    }
    console.warn('Gemini returned non-array JSON. Wrapping into array.');
    return [parsed] as T;
  } catch (error) {
    console.warn('Failed to parse JSON response directly. Attempting relaxed parsing...', error);
    const fallback = relaxedJsonParse<T>(text);
    if (fallback) {
      return fallback;
    }
    throw new Error('Unable to parse response into JSON.');
  }
}

/**
 * Attempts to extract and parse JSON array from text with surrounding content
 */
function relaxedJsonParse<T>(text: string): T | undefined {
  const start = text.indexOf('[');
  const end = text.lastIndexOf(']');
  if (start === -1 || end === -1 || end <= start) {
    return undefined;
  }

  try {
    const sliced = text.slice(start, end + 1);
    return JSON.parse(sliced) as T;
  } catch (error) {
    console.warn('Relaxed JSON parse also failed.', error);
    return undefined;
  }
}

/**
 * Creates a URL-safe slug from input string
 */
export function createSlug(input: string, maxLength: number = 60): string {
  return input
    .normalize('NFD')
    .replace(/\p{Diacritic}+/gu, '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/(^-|-$)/g, '')
    .slice(0, maxLength);
}

/**
 * Validates that an object has all required localized titles
 */
export function hasAllLocaleTitles(
  title: Record<string, unknown> | undefined,
  locales: readonly SupportedLocale[]
): title is Record<SupportedLocale, string> {
  if (!title || typeof title !== 'object') {
    return false;
  }

  console.log('Validating generated cocktail', title, locales);

  return locales.every((locale) => {
    const value = title[locale];
    return typeof value === 'string' && value.trim().length > 0;
  });
}

/**
 * Generic request to Gemini with JSON response
 */
export async function requestGeminiJson<T>(
  generativeModel: ReturnType<VertexAI['getGenerativeModel']>,
  prompt: string,
  temperature: number = 0.4
): Promise<T> {
  const result = await generativeModel.generateContent({
    contents: [
      {
        role: 'user',
        parts: [{ text: prompt }]
      }
    ],
    generationConfig: {
      responseMimeType: 'application/json',
      temperature
    }
  });

  const textResponse = extractTextResponse(result);
  if (!textResponse) {
    throw new Error('Gemini response contained no text.');
  }

  return parseJsonResponse<T>(textResponse);
}
