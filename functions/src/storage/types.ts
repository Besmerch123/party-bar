export interface StorageUploadFile {
  /**
   * Original filename provided by the client. The name MUST NOT contain path separators.
   */
  name: string;

  /**
   * Base64-encoded file content. May optionally include a data URI prefix.
   */
  data: string;

  /**
   * MIME type of the uploaded file. If omitted, the handler attempts to derive it from the data URI.
   */
  contentType?: string;
}

export interface StorageUploadRequest {
  /**
   * Directory path prefix (relative to the bucket root) where files should be stored.
   */
  pathPrefix: string;

  /**
   * Collection of files to store in Cloud Storage.
   */
  files: StorageUploadFile[];
}

export interface StorageUploadedFileResult {
  /**
   * Final, unique object name written to Cloud Storage (including prefix).
   */
  objectPath: string;

  /**
   * Download URL that can be used to access the stored file with proper permissions.
   */
  mediaLink: string;

  /**
   * Resolved content type saved with the file.
   */
  contentType: string;
}

export interface StorageUploadResponse {
  /**
   * Summary of the files written to Cloud Storage.
   */
  files: StorageUploadedFileResult[];
}
