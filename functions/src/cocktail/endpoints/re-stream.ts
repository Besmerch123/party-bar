import 'firebase-functions/logger/compat';
import { onCall } from 'firebase-functions/https';
import { getCocktailService } from '../cocktail.service';
import { DocumentSnapshot } from 'firebase-admin/firestore';
import { CocktailDocument } from '../cocktail.model';
import { COCKTAILS_INDEX_MAPPING } from '../../elastic/elastic.mappings';

export const reStreamCocktails = onCall(async () => {
  let processed = 0;
  let errors = 0;
  let hasMore = true;
  let lastDoc: DocumentSnapshot<CocktailDocument> | undefined;
  const batchSize = 10; // Process in smaller batches to avoid memory issues

  const cocktailService = getCocktailService();

  console.info('Starting cocktail re-streaming to Elastic index...');

  // Deleting an index that is not there is an error, not a no-op.
  if (await cocktailService.repository.elastic.indexExists('cocktails')) {
    await cocktailService.repository.elastic.deleteIndex('cocktails');
    console.info('Deleted existing cocktails index.');
  }

  // Recreate it with the explicit mapping before the first write, so the
  // filters that read ids and enum values keep working.
  await cocktailService.repository.elastic.createIndex('cocktails', COCKTAILS_INDEX_MAPPING);

  console.info('Created cocktails index with explicit mapping, starting re-indexing...');

  while (hasMore) {
    try {
      // Get next batch of cocktails
      const result = await cocktailService.repository.getAllCocktails(batchSize, lastDoc);
        
      if (result.documents.length === 0) {
        break;
      }

      console.info(`Processing batch of ${result.documents.length} cocktails...`);

      // Process each cocktail in the batch
      for (const cocktailDoc of result.documents) {
        try {
          await cocktailService.insertCocktailToElasticIndex(cocktailDoc);
          processed++;
            
          console.info(`Processed ${processed} cocktails so far...`);
        } catch (error) {
          console.error(`Error processing cocktail ${cocktailDoc.id}:`, error);
          errors++;
        }
      }

      hasMore = result.hasMore;
      lastDoc = result.lastDoc;

      // Small delay between batches to avoid overwhelming the system
      if (hasMore) {
        await new Promise(resolve => setTimeout(resolve, 1000));
      }

    } catch (error) {
      console.error('Error fetching cocktail batch:', error);
      errors++;
      break;
    }
  }

  console.info(`Cocktail re-streaming completed. Processed: ${processed}, Errors: ${errors}`);
  return { processed, errors };
});
