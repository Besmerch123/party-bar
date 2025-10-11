/**
 * Cocktail Repository
 *
 * Handles data persistence operations for cocktails using Firestore.
 * Following DDD principles, this abstracts the database layer.
 */

import { firestore } from 'firebase-admin';
import { CollectionReference, DocumentSnapshot, Timestamp } from 'firebase-admin/firestore';
import * as esb from 'elastic-builder';

import { getElasticService } from '../elastic/elastic.service';
import { AbstractRepository } from '../shared/abstract.repository';
import { ElasticSearchResults } from '../elastic/elastic.types';

import { CocktailDocument, CocktailSearchDocument, CreateCocktailDto, UpdateCocktailDto, CocktailsSearchSchema } from './cocktail.model';



class CocktailRepository extends AbstractRepository {
  readonly collection = firestore().collection('cocktails') as CollectionReference<CocktailDocument>;

  readonly elastic: ReturnType<typeof getElasticService>;

  constructor() {
    super();

    this.elastic = getElasticService();
  }

  /**
   * Creates a new cocktail in Firestore
   */
  async create(cocktailData: CreateCocktailDto): Promise<CocktailDocument> {
    const englishTitle = cocktailData.title['en'];

    if (!englishTitle) {
      throw new Error('English title is required to create a cocktail');
    }

    const slug = await this.getSafeSlug(englishTitle);
    const docRef = this.collection.doc(slug);

    const timestamp = Timestamp.now();
    const cocktailDoc: CocktailDocument = {
      title: cocktailData.title,
      description: cocktailData.description,
      ingredients: cocktailData.ingredients,
      equipments: cocktailData.equipments,
      categories: cocktailData.categories,
      abv: cocktailData.abv,
      image: cocktailData.image,
      preparationSteps: cocktailData.preparationSteps,
      createdAt: timestamp,
      updatedAt: timestamp,
    };

    await docRef.set(cocktailDoc);

    return cocktailDoc;
  }

  /**
   * Retrieves a cocktail by ID
   */
  async findById(id: string): Promise<DocumentSnapshot<CocktailDocument> | null> {
    const doc = await this.collection.doc(id).get();

    if (!doc.exists) {
      return null;
    }

    return doc; 
  }

  /**
   * Updates an existing cocktail
   */
  async update({ id, ...updateData }: UpdateCocktailDto): Promise<DocumentSnapshot<CocktailDocument> | null> {
    const docRef = this.collection.doc(id);
    const doc = await docRef.get();

    if (!doc.exists) {
      throw new Error(`Cocktail ${id} not found`);
    }

    await docRef.update({ ...updateData, 
      updatedAt: Timestamp.now()
    });

    return this.findById(id);
  }

  /**
   * Deletes a cocktail by ID
   */
  async delete(id: string): Promise<boolean> {
    const docRef = this.collection.doc(id);
    const doc = await docRef.get();

    if (!doc.exists) {
      return false;
    }

    await docRef.delete();
    return true;
  }

  /**
   * Gets all cocktails with cursor pagination
   */
  async getAllCocktails(batchSize: number = 100, lastDoc?: DocumentSnapshot<CocktailDocument>): Promise<{
    documents: DocumentSnapshot<CocktailDocument>[];
    hasMore: boolean;
    lastDoc?: DocumentSnapshot<CocktailDocument>;
  }> {
    let query = this.collection.orderBy('createdAt', 'asc').limit(batchSize);
    
    if (lastDoc) {
      query = query.startAfter(lastDoc);
    }
    
    const snapshot = await query.get();
    const documents = snapshot.docs;
    
    return {
      documents,
      hasMore: documents.length === batchSize,
      lastDoc: documents.length > 0 ? documents[documents.length - 1] : undefined
    };
  }

  /**
   * Searches cocktails based on the provided search schema
   */
  async searchCocktails(searchSchema: CocktailsSearchSchema): Promise<ElasticSearchResults<CocktailSearchDocument>> {
    const query = this.buildSearchQuery(searchSchema);
    const { pagination } = searchSchema;
    const page = pagination?.page || 1;
    const pageSize = pagination?.pageSize || 20;
    
    const searchResult = await this.elastic.searchDocumentsWithMetadata<CocktailSearchDocument>(
      'cocktails', 
      query.toJSON()
    );

    const totalPages = Math.ceil(searchResult.total / pageSize);

    return {
      items: searchResult.documents,
      total: searchResult.total,
      page,
      pageSize,
      totalPages,
      hasNextPage: page < totalPages,
      hasPreviousPage: page > 1
    };
  }

  /**
   * Builds an Elasticsearch query from the search schema
   */
  private buildSearchQuery(searchSchema: CocktailsSearchSchema): esb.RequestBodySearch {
    const requestBody = esb.requestBodySearch();
    const boolQuery = esb.boolQuery();

    // Handle text search query
    if (searchSchema.query && searchSchema.query.trim()) {
      const searchTerm = searchSchema.query.trim();
      
      // Create a multi-match query with boosting for different fields
      const multiMatchQuery = esb.multiMatchQuery(
        [
          'title.en^3',
          'title.uk^3',
          'description.en^2',
          'description.uk^2',
          'ingredients.title.en^1.5',
          'ingredients.title.uk^1.5',
        ],
        searchTerm
      )
        .fuzziness('AUTO')
        .type('best_fields')
        .minimumShouldMatch('50%');

      // Also add a phrase match for exact matches with higher scoring
      const phraseQuery = esb.multiMatchQuery(
        [
          'title.en^5',
          'title.uk^5',
          'description.en^3',
          'description.uk^3',
        ],
        searchTerm
      ).type('phrase');

      // Combine both queries with should (OR) logic
      const textQuery = esb.boolQuery()
        .should([multiMatchQuery, phraseQuery])
        .minimumShouldMatch(1);

      boolQuery.must(textQuery);
    } else {
      // If no search query, match all documents
      boolQuery.must(esb.matchAllQuery());
    }

    // Handle filters
    if (searchSchema.filters) {
      const { categories, ingredients, equipments, abvRange } = searchSchema.filters;

      // Filter by categories
      if (categories && categories.length > 0) {
        boolQuery.filter(
          esb.termsQuery('categories', categories)
        );
      }

      // Filter by ingredients - all specified ingredients must be present
      if (ingredients && ingredients.length > 0) {
        ingredients.forEach(ingredientId => {
          boolQuery.filter(
            esb.termQuery('ingredients.id', ingredientId)
          );
        });
      }

      // Filter by equipments - all specified equipments must be present
      if (equipments && equipments.length > 0) {
        equipments.forEach(equipmentId => {
          boolQuery.filter(
            esb.termQuery('equipment.id', equipmentId)
          );
        });
      }

      // Filter by ABV range
      if (abvRange && (abvRange.min !== undefined || abvRange.max !== undefined)) {
        const rangeQuery = esb.rangeQuery('abv');
        
        if (abvRange.min !== undefined) {
          rangeQuery.gte(abvRange.min);
        }
        
        if (abvRange.max !== undefined) {
          rangeQuery.lte(abvRange.max);
        }

        boolQuery.filter(rangeQuery);
      }
    }

    // Set the main query
    requestBody.query(boolQuery);

    // Handle pagination
    if (searchSchema.pagination) {
      const { page = 1, pageSize = 20 } = searchSchema.pagination;
      const from = (page - 1) * pageSize;
      const maxSize = Math.min(pageSize, 100); // Limit max page size
      
      requestBody
        .from(from)
        .size(maxSize);
    } else {
      // Default pagination
      requestBody.size(20);
    }

    // Add sorting - prioritize relevance for text searches, recency for browse
    if (searchSchema.query && searchSchema.query.trim()) {
      // For text searches, prioritize relevance
      requestBody
        .sort(esb.sort('_score', 'desc'))
        .sort(esb.sort('createdAt', 'desc'));
    } else {
      // For browsing/filtering, prioritize recency
      requestBody
        .sort(esb.sort('createdAt', 'desc'))
        .sort(esb.sort('_score', 'desc'));
    }

    // Add track_total_hits to get accurate count
    requestBody.trackTotalHits(true);

    return requestBody;
  }
}

let cocktailRepository: CocktailRepository;

export function getCocktailRepository(): CocktailRepository {
  if (!cocktailRepository) {
    cocktailRepository = new CocktailRepository();
  }

  return cocktailRepository;
}
