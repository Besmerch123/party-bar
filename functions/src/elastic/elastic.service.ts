import { Client } from '@elastic/elasticsearch';
import { defineSecret, defineString } from 'firebase-functions/params';
import { SupportedLocale } from '../shared/types';

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

  public async insertDocument<Document extends Record<string, unknown>>(index: string, locale: SupportedLocale, document: Document): Promise<void> {
    await this.client.index({
      index: this.getIndexName(index, locale),
      id: document.id as string,
      body: document,
    });
  }

  private getIndexName(baseIndex: string, locale: SupportedLocale): string {
    return `${baseIndex}-${locale}-${stage.value()}`;
  }
}

let elasticService: ElasticService;

export function getElasticService(): ElasticService {
  if (!elasticService) {
    elasticService = new ElasticService();
  }
  return elasticService;
}

