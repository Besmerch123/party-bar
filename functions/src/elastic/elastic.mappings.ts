/**
 * Elasticsearch index mappings.
 *
 * The cocktails index used to be created implicitly by the first write, which
 * meant dynamic mapping decided every field's type. That is wrong for this
 * document in two ways that both fail silently:
 *
 *  - Ids and enum values were mapped as `text`, so they were analysed before
 *    being indexed. A term query for "sweet-vermouth" then matches nothing,
 *    because the indexed tokens are ["sweet", "vermouth"]; "zeroProof"
 *    matches nothing because the indexed token is "zeroproof". Every filter
 *    that reads an id or an enum -- the shelf filter included -- returns an
 *    empty set rather than an error.
 *
 *  - `measures` is keyed by ingredient id, so dynamic mapping adds three
 *    fields to the index for every ingredient the catalogue has ever used.
 *    That walks into Elastic's 1000-field limit as the catalogue grows, and
 *    the index starts rejecting writes.
 *
 * Both are fixed by mapping the index explicitly: exact-match fields are
 * `keyword`, prose is `text`, and the id-keyed blobs are stored but not
 * indexed.
 */

import type { estypes } from '@elastic/elasticsearch';

/** Prose: analysed, and what the multi_match queries actually search. */
const text: estypes.MappingProperty = { type: 'text' };

/** Exact match: ids, enum values, anything a term query reads. */
const keyword: estypes.MappingProperty = { type: 'keyword' };

/**
 * Returned to the app in `_source` but never indexed.
 *
 * Nothing queries these, and `measures` in particular must not be indexed:
 * its keys are ingredient ids, so indexing it grows the mapping without bound.
 */
const storedOnly: estypes.MappingProperty = { type: 'object', enabled: false };

/** The translated-string fields, as the documents actually carry them. */
const i18nText: estypes.MappingProperty = {
  type: 'object',
  properties: {
    en: text,
    uk: text,
  },
};

export const COCKTAILS_INDEX_MAPPING: estypes.MappingTypeMapping = {
  // Anything not named here is kept in `_source` and left unindexed, so a new
  // field cannot quietly change the shape of the index before someone decides
  // how it should be queried.
  dynamic: false,

  properties: {
    id: keyword,

    title: i18nText,
    description: i18nText,

    categories: keyword,

    // The filter and sort vocabulary. All exact-match.
    method: keyword,
    baseSpirit: keyword,
    flavor: keyword,

    abv: { type: 'float' },
    prepTimeMinutes: { type: 'integer' },
    popularity: { type: 'integer' },
    seasonalScore: { type: 'integer' },
    ingredientCount: { type: 'integer' },

    image: { type: 'keyword', index: false },

    // Arrays of objects, left as flattened objects rather than `nested`: every
    // query over them asks "does this drink use any ingredient matching X",
    // which is what flattening gives, and `nested` would cost a join per hit.
    ingredients: {
      type: 'object',
      properties: {
        id: keyword,
        title: i18nText,
        category: keyword,
        image: { type: 'keyword', index: false },
        slug: keyword,
      },
    },

    equipments: {
      type: 'object',
      properties: {
        id: keyword,
        title: i18nText,
        image: { type: 'keyword', index: false },
        slug: keyword,
      },
    },

    measures: storedOnly,
    pourSteps: storedOnly,
    preparationSteps: storedOnly,

    createdAt: { type: 'date' },
    updatedAt: { type: 'date' },
  },
};
