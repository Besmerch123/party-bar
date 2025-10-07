import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { logger } from 'firebase-functions';
import { storage } from 'firebase-admin';

import {
  StorageUploadRequest,
  StorageUploadResponse,
  StorageUploadFile,
  StorageUploadedFileResult,
} from '../types';

const MAX_FILENAME_LENGTH = 200;

const sanitizePathPrefix = (prefix: string): string => {
  return prefix
    .split('/')
    .map((segment) => segment.trim())
    .filter((segment) => segment.length > 0)
    .map((segment) => segment.replace(/[^a-zA-Z0-9._-]/g, '-'))
    .join('/');
};

const sanitizeFileName = (name: string): string => {
  const trimmed = name.trim().replace(/[/\\]/g, '-');
  const normalized = trimmed.replace(/[^a-zA-Z0-9._-]/g, '-');
  const collapsed = normalized.replace(/-+/g, '-');
  const result = collapsed.slice(0, MAX_FILENAME_LENGTH) || 'file';

  return result;
};

const extractFileBuffer = (file: StorageUploadFile): { buffer: Buffer; contentType: string } => {
  let data = file.data.trim();
  let contentType = file.contentType?.trim();

  const dataUriMatch = /^data:([^;]+);base64,(.+)$/i.exec(data);
  if (dataUriMatch) {
    contentType = contentType ?? dataUriMatch[1];
    data = dataUriMatch[2];
  }

  const cleanedBase64 = data.replace(/\s/g, '');

  if (!cleanedBase64) {
    throw new HttpsError('invalid-argument', `File data for "${file.name}" cannot be empty.`);
  }

  let buffer: Buffer;
  try {
    buffer = Buffer.from(cleanedBase64, 'base64');
  } catch (error) {
    logger.error('Failed to decode base64 file data', error);
    throw new HttpsError('invalid-argument', `Unable to decode base64 data for "${file.name}".`);
  }

  if (!buffer.length) {
    throw new HttpsError('invalid-argument', `Decoded file for "${file.name}" is empty.`);
  }

  return {
    buffer,
    contentType: contentType ?? 'application/octet-stream',
  };
};

const ensureUniqueObjectPath = async (objectPath: string): Promise<string> => {
  const bucket = storage().bucket();
  let candidate = objectPath;
  let counter = 1;

  const extensionIndex = objectPath.lastIndexOf('.');
  const baseName =
    extensionIndex === -1 ? objectPath : objectPath.slice(0, extensionIndex);
  const extension = extensionIndex === -1 ? '' : objectPath.slice(extensionIndex);

  while (true) {
    const [exists] = await bucket.file(candidate).exists();
    if (!exists) {
      return candidate;
    }

    candidate = `${baseName}-${counter}${extension}`;
    counter += 1;
  }
};

const validatePayload = (data: unknown): StorageUploadRequest => {
  if (!data || typeof data !== 'object') {
    throw new HttpsError('invalid-argument', 'Upload payload must be an object.');
  }

  const { pathPrefix, files } = data as Partial<StorageUploadRequest>;

  if (!pathPrefix || typeof pathPrefix !== 'string') {
    throw new HttpsError('invalid-argument', 'Property "pathPrefix" is required and must be a string.');
  }

  if (!Array.isArray(files) || !files.length) {
    throw new HttpsError('invalid-argument', 'Property "files" must be a non-empty array.');
  }

  files.forEach((file, index) => {
    if (!file || typeof file !== 'object') {
      throw new HttpsError('invalid-argument', `File at index ${index} must be an object.`);
    }

    if (!file.name || typeof file.name !== 'string') {
      throw new HttpsError('invalid-argument', `File at index ${index} is missing a valid "name".`);
    }

    if (!file.data || typeof file.data !== 'string') {
      throw new HttpsError('invalid-argument', `File "${file.name}" must include "data" as a base64 string.`);
    }
  });

  return {
    pathPrefix,
    files: files as StorageUploadFile[],
  };
};

export const uploadStorageFiles = onCall<StorageUploadRequest, Promise<StorageUploadResponse>>(
  async (request) => {
    const payload = validatePayload(request.data);

    const bucket = storage().bucket();
    const sanitizedPrefix = sanitizePathPrefix(payload.pathPrefix);

    const responses: StorageUploadedFileResult[] = [];

    for (const file of payload.files) {
      const fileName = sanitizeFileName(file.name);
      const objectPath = sanitizedPrefix ? `${sanitizedPrefix}/${fileName}` : fileName;
      const uniqueObjectPath = await ensureUniqueObjectPath(objectPath);

      const { buffer, contentType } = extractFileBuffer(file);
      const storageFile = bucket.file(uniqueObjectPath);

      await storageFile.save(buffer, {
        resumable: false,
        metadata: {
          contentType,
        },
      });

      // Make the file publicly accessible
      await storageFile.makePublic();

      // Get the public URL
      const publicUrl = `https://storage.googleapis.com/${bucket.name}/${encodeURIComponent(uniqueObjectPath)}`;

      responses.push({
        objectPath: uniqueObjectPath,
        mediaLink: publicUrl,
        contentType,
      });
    }

    logger.info('Uploaded files to Cloud Storage', {
      count: responses.length,
      prefix: sanitizedPrefix,
    });

    return{
      files: responses,
    };
  }
);
