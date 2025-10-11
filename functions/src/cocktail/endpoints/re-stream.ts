import 'firebase-functions/logger/compat';
import { onCall } from 'firebase-functions/https';
import { getCocktailService } from '../cocktail.service';
import { DocumentSnapshot } from 'firebase-admin/firestore';
import { CocktailDocument } from '../cocktail.model';

export const reStreamCocktails = onCall(async () => {
  let processed = 0;
  let errors = 0;
  let hasMore = true;
  let lastDoc: DocumentSnapshot<CocktailDocument> | undefined;
  const batchSize = 10; // Process in smaller batches to avoid memory issues

  const cocktailService = getCocktailService();

  console.info('Starting cocktail re-streaming to Elastic index...');

  await cocktailService.repository.elastic.deleteIndex('cocktails');

  console.info('Deleted existing cocktails index, starting re-indexing...');

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
