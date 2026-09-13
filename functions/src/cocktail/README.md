# Cocktail Domain

The Cocktail domain for the Party Bar app, following Domain-Driven Design (DDD).

## Structure

```
src/cocktail/
├── cocktail.model.ts       # Domain models and DTOs
├── cocktail.repository.ts  # Firestore access + the Elasticsearch query builder
├── cocktail.service.ts     # Business logic and validation
├── cocktail.generation.ts  # The AI prompt, its response shape, and its validation
├── cocktail.seed.ts        # One-off CLI seeding script
├── index.ts                # Domain exports
└── endpoints/
    ├── get-cocktail.ts
    ├── search-cocktails.ts
    ├── update-cocktail.ts
    ├── delete-cocktail.ts
    ├── generate-cocktail.ts
    ├── backfill-cocktails.ts
    ├── on-document-written.ts   # Firestore trigger -> Elastic index
    ├── re-stream.ts             # Rebuild the whole Elastic index
    └── index.ts
```

## Domain Model

A `Cocktail` is a finished recipe composed from ingredients and equipment that
already exist in the catalogue.

**Identity and prose**

- **id** – Firestore document id, slugified from the English title on create
- **title**, **description** – `I18nField`, keyed by locale (`en`, `uk`)
- **image** – Cloud Storage path
- **categories** – discovery tags from `COCKTAIL_CATEGORIES`
- **preparationSteps** – `I18nArrayField`, the readable recipe

**The recipe vocabulary**

Everything below is optional on the document but is what the app's Explore
screen filters and sorts on. A cocktail missing these is not "partly
described" — it is *invisible* to the filter that reads the missing field,
because a null reads as "does not match". `backfillCocktails` exists to close
exactly that gap.

| Field | Meaning | What reads it |
| --- | --- | --- |
| `method` | Build technique (`COCKTAIL_METHODS`) | The "no shaker needed" filter, the card meta line |
| `baseSpirit` | The bottle it is built around (`BASE_SPIRITS`) | Browse-by-spirit and the spirit filter |
| `flavor` | Editorial taste note (`FLAVOR_PROFILES`) | The detail eyebrow, beside the method |
| `prepTimeMinutes` | Whole minutes of active work | The "under 3 minutes" filter |
| `abv` | Alcohol by volume, 0–100 | The ABV range filter |
| `popularity` | 0–100, how widely known | The "popular" sort |
| `seasonalScore` | 0–100, fit for the season | The "seasonal" sort |
| `measures` | Quantities, keyed by ingredient id | The recipe card, and makeability |
| `pourSteps` | The guided "make it now" breakdown | Falls back to `preparationSteps` |

`method` is judged on the actual technique, not the equipment list: a drink
stirred in the glass is `built` even when a shaker is listed for chilling.

### `measures`

Kept beside `ingredients` rather than inside it, so the ingredient list stays a
plain array of references and this map carries the quantity. Keyed by
ingredient id; a key the recipe does not list is rejected on write.

`optional: true` marks garnishes and top-ups. Those **do not** count against
"makeable with my bar" — nobody is blocked from a Negroni by a missing orange
twist — so every garnish should be optional and no core spirit ever should be.
A drink where every ingredient is optional is rejected.

`splash` and `topUp` carry no meaningful amount and render as the label alone.

### `pourSteps`

The same recipe cut into the units a person performs with their hands busy,
with the countdown a step needs. Absent for much of the catalogue, which is why
every caller falls back to `preparationSteps`. A step with an empty title is
rejected: a blank screen mid-pour is worse than no guided pour at all.

## Cloud Functions

All require an authenticated caller.

### `getCocktail`

```typescript
{ id: string } -> Cocktail
```

### `searchCocktails`

```typescript
CocktailsSearchSchema -> ElasticSearchResults<CocktailSearchDocument>
```

Filters, sorts and paginates through Elasticsearch. See `CocktailsSearchSchema`
for the filter surface. Note that `makeableOnly` is only a **broadening
pre-filter** server-side — `ingredients` is a flattened object, so a terms
query over it can ask "uses any of these", never "needs only these". The exact
makeability test knows which ingredients are optional per drink and runs on the
device, which is also the only place the shelf really lives.

### `updateCocktail`

```typescript
UpdateCocktailDto -> Cocktail
```

Partial update. Every field present is validated; fields left out are untouched.

### `deleteCocktail`

```typescript
{ id: string } -> void
```

### `generateCocktail`

```typescript
{ name: string, preferences?: string } -> Cocktail
```

Generates a complete recipe from a name via Gemini, choosing ingredients and
equipment only from the existing catalogue. "Complete" means the whole recipe
vocabulary above, not just a title and steps.

### `backfillCocktails`

```typescript
{ limit?: number, force?: boolean, cocktailId?: string } -> BackfillResult
```

Fills the recipe vocabulary on cocktails that predate it, running the same
prompt with the drink's current description, ingredients and steps as context —
so the result is the existing drink described more richly, not a different
drink under the same name. The title and image are never touched.

Each drink is a separate Gemini round trip, so this works in batches: repeat
while `hasMore` is true. `force` re-generates drinks that are already complete.

### `reStreamCocktails`

Deletes and rebuilds the Elasticsearch index from Firestore. The index is
recreated with the **explicit mapping** in `elastic/elastic.mappings.ts` before
any write — under dynamic mapping, ids and enum values get analysed into
tokens and every term-query filter silently matches nothing.

### `onDocumentWritten`

Firestore trigger keeping the Elastic index in step with `cocktails/{id}`.

## Business Rules

1. **Title** – required, at least one locale, 2+ characters per locale
2. **Description** – required `I18nField`
3. **Ingredient / equipment references** – non-empty arrays of document paths
   (`ingredients/<id>`, `equipment/<id>` — note the singular collection name)
4. **Categories** – non-empty; every value must be in `COCKTAIL_CATEGORIES`
5. **Enum fields** – `method`, `baseSpirit` and `flavor` must be a known value
   or null; an unrecognised one is rejected rather than stored, because on the
   device it would decode to null and drop the drink out of every filter
6. **Scores** – `popularity` and `seasonalScore` are whole numbers 0–100
7. **`prepTimeMinutes`** – a whole number of minutes, 1–240
8. **`measures`** – keyed by an ingredient the recipe lists; known unit;
   non-negative amount
9. **Authentication** – every callable requires an authenticated caller
10. **Timestamps** – managed automatically on create and update

## Related

- `catalogue/` — recomputes the figures derived from this collection
  (`cocktailCount`, `unlocks`) onto ingredients and equipment.
