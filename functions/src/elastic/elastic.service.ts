import { Client } from '@elastic/elasticsearch';
import type { estypes } from '@elastic/elasticsearch';
import { defineSecret, defineString } from 'firebase-functions/params';

import type { ElasticDocument } from './elastic.types';

const elasticNode = defineString('ELASTIC_NODE');
const elasticApiKey = defineSecret('ELASTIC_API_KEY');
const stage = defineString('STAGE', {
  default: 'dev',
});

class ElasticService {
  client: Client;

  constructor() {
    this.client = new Client({
      node: elasticNode.value(),
      auth: {
        apiKey: elasticApiKey.value()
      },
      serverMode: 'serverless',
    });
  }

  public async insertDocument<Document extends ElasticDocument>(index: string, document: Document): Promise<void> {
    await this.client.index({
      index: this.getIndexName(index),
      id: document.id as string,
      document,
    });
  }

  public async deleteDocument(index: string, documentId: string): Promise<void> {
    await this.client.delete({
      index: this.getIndexName(index),
      id: documentId,
    });
  }

  public async searchDocuments<Document extends ElasticDocument>(
    index: string,
    query: estypes.QueryDslQueryContainer
  ): Promise<Document[]> {
    const response = await this.client.search<Document>({
      index: this.getIndexName(index),
      query
    });

    return response.hits.hits.map(hit => hit._source!);
  }

  public async searchDocumentsWithMetadata<Document extends ElasticDocument>(
    index: string,
    body: estypes.SearchRequest['body']
  ): Promise<{
    documents: Document[];
    total: number;
    took: number;
  }> {
    const response = await this.client.search<Document>({
      index: this.getIndexName(index),
      body
    });

    const total = typeof response.hits.total === 'number' 
      ? response.hits.total 
      : response.hits.total?.value || 0;

    return {
      documents: response.hits.hits.map(hit => hit._source!),
      total,
      took: response.took || 0
    };
  }

  public async deleteIndex(index: string): Promise<void> {
    await this.client.indices.delete({
      index: this.getIndexName(index),
    });
  }

  private getIndexName(baseIndex: string): string {
    return `${baseIndex}-${stage.value()}`;
  }
}

let elasticService: ElasticService;

export function getElasticService(): ElasticService {
  if (!elasticService) {
    elasticService = new ElasticService();
  }
  return elasticService;
}

