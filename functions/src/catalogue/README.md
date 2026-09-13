# Catalogue Domain

Cross-cutting work over the whole catalogue — the figures that belong to no
single cocktail, ingredient or piece of equipment.

## Why this is not on the item

Two fields the app prints are functions of the *entire* cocktail collection:

- **`cocktailCount`** — "in 11 drinks", on the bar's item sheet. On both
  ingredients and equipment.
- **`unlocks`** — "add lime, unlocks 11 more", which ranks the near-miss list
  on a zero-results screen. On ingredients only.

Neither can be maintained from an item's own edit form, because editing one
*cocktail* moves the numbers on every ingredient it touches. So they are not
authored at all: the admin panel shows them read-only and recomputes them in
one sweep.

## `unlocks` and the typical shelf

`unlocks` only means something relative to some shelf, and the recount has no
real one to read — shelves live on the devices. The stand-in is the head of the
catalogue's own frequency distribution: the `TYPICAL_SHELF_SIZE` most common
ingredients, the bottles a person who owns anything is most likely to own.

For each ingredient, `unlocks` counts the cocktails that would become pourable
if it were added to that shelf — the drink must genuinely require it, and
everything else it requires must already be on the shelf. Measuring against the
shelf *minus this ingredient* is what keeps the figure meaningful for something
already common enough to be in the top twenty.

Tuning `TYPICAL_SHELF_SIZE`: too small and nothing is ever unlockable, too
large and every drink is already makeable so nothing unlocks anything.

Ties in the frequency sort break on document id, so two runs over an unchanged
catalogue produce the same shelf and therefore the same figures.

Ingredients marked `optional` in a cocktail's `measures` do not count as
required — a garnish never gates a pour, and counting one would make half the
catalogue look unmakeable.

## Cloud Functions

### `recountCatalogue`

```typescript
void -> {
  cocktails: number;
  ingredientsUpdated: number;
  equipmentUpdated: number;
  typicalShelf: string[];
}
```

Recomputes both figures across the catalogue and writes back only the documents
whose numbers actually moved. Triggered from the admin panel's Settings page
rather than on every cocktail write — one cocktail edit can move a dozen
ingredients, so doing it per-write would fan out a burst of updates for a
figure nothing reads in real time.

Run it after adding cocktails, and after a `backfillCocktails` pass: the
backfill can change which ingredients a drink lists, and marking a garnish
optional changes what counts as required.
