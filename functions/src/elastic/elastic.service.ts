import { Client } from '@elastic/elasticsearch';
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

