/**
 * Catalogue Stats
 *
 * The two figures the app prints but nobody authors: `cocktailCount` ("in 11
 * drinks", on the bar's item sheet) and `unlocks` ("add lime, unlocks 11
 * more", which ranks the near-miss list on a zero-results screen).
 *
 * Both are functions of the whole cocktail collection, so they cannot be
 * maintained from an item's own edit form -- adding one cocktail changes the
 * numbers on every ingredient it touches. They are recomputed in one sweep
 * instead, and the admin panel shows them read-only.
 */

import { firestore } from 'firebase-admin';
import { Timestamp } from 'firebase-admin/firestore';

import type { CocktailDocument } from '../cocktail/cocktail.model';
import type { IngredientDocument } from '../ingredient/ingredient.model';
import type { EquipmentDocument } from '../equipment/equipment.model';

/**
 * How many of the most common ingredients count as already being on a shelf
 * when measuring what one more bottle would unlock.
 *
 * `unlocks` only means anything relative to some shelf, and the recount has no
 * real one to read -- shelves live on the devices. The stand-in is the head of
 * the catalogue's own frequency distribution: the bottles a person who owns
 * anything is most likely to own. Too small and nothing is ever unlockable;
 * too large and every drink is already makeable and nothing unlocks anything.
 */
export const TYPICAL_SHELF_SIZE = 20;

/** Firestore caps a batched write at 500 operations. */
const BATCH_LIMIT = 500;

export interface RecountResult {
  cocktails: number;
  ingredientsUpdated: number;
  equipmentUpdated: number;
  /** The stand-in shelf the `unlocks` figures were measured against. */
  typicalShelf: string[];
}

/**
 * Strips a Firestore path down to its document id: "ingredients/gin" -> "gin".
 * References are stored as paths in some code paths and bare ids in others.
 */
function toId(reference: string): string {
  const trimmed = reference.trim();
  const lastSlash = trimmed.lastIndexOf('/');
  return lastSlash >= 0 ? trimmed.substring(lastSlash + 1) : trimmed;
}

/**
 * The ingredients that actually gate making the drink.
 *
 * A garnish or a top-up marked `optional` in `measures` does not: nobody is
 * blocked from a Negroni by a missing orange twist, and counting one as
 * required would make half the catalogue look unmakeable.
 */
function requiredIngredientIds(cocktail: CocktailDocument): string[] {
  const measures = cocktail.measures ?? {};

  return (cocktail.ingredients ?? [])
    .map(toId)
    .filter((id) => measures[id]?.optional !== true);
}

/**
 * Recomputes `cocktailCount` on every ingredient and every piece of equipment,
 * and `unlocks` on every ingredient, then writes back only what changed.
 */
export async function runCatalogueRecount(): Promise<RecountResult> {
  const fs = firestore();

  const [cocktailsSnapshot, ingredientsSnapshot, equipmentSnapshot] = await Promise.all([
    fs.collection('cocktails').get(),
    fs.collection('ingredients').get(),
    fs.collection('equipment').get(),
  ]);

  const cocktails = cocktailsSnapshot.docs.map((doc) => doc.data() as CocktailDocument);

  // --- "in N drinks", for both catalogues.
  //
  // Counted over every listed ingredient, optional ones included: the sheet is
  // answering "where does this show up", not "what gates a pour".
  const ingredientCounts = new Map<string, number>();
  const equipmentCounts = new Map<string, number>();

  for (const cocktail of cocktails) {
    for (const id of new Set((cocktail.ingredients ?? []).map(toId))) {
      ingredientCounts.set(id, (ingredientCounts.get(id) ?? 0) + 1);
    }

    for (const id of new Set((cocktail.equipments ?? []).map(toId))) {
      equipmentCounts.set(id, (equipmentCounts.get(id) ?? 0) + 1);
    }
  }

  // --- The stand-in shelf: the head of the frequency distribution.
  //
  // Ties break on id so two runs over an unchanged catalogue produce the same
  // shelf, and therefore the same `unlocks` figures.
  const typicalShelf = Array.from(ingredientCounts.entries())
    .sort(([idA, countA], [idB, countB]) => countB - countA || idA.localeCompare(idB))
    .slice(0, TYPICAL_SHELF_SIZE)
    .map(([id]) => id);

  const typicalShelfSet = new Set(typicalShelf);

  const requiredByCocktail = cocktails.map(requiredIngredientIds);

  /**
   * What adding this one bottle to the typical shelf would make pourable.
   *
   * The bottle has to be genuinely required by the drink, and everything else
   * the drink requires has to already be on the shelf. Measuring against the
   * shelf *without* this ingredient is what makes the figure meaningful for
   * something already common enough to be in the top twenty.
   */
  const unlocksFor = (ingredientId: string): number => {
    let unlocked = 0;

    for (const required of requiredByCocktail) {
      if (required.length === 0 || !required.includes(ingredientId)) {
        continue;
      }

      const everythingElseOnShelf = required.every(
        (id) => id === ingredientId || typicalShelfSet.has(id)
      );

      if (everythingElseOnShelf) {
        unlocked += 1;
      }
    }

    return unlocked;
  };

  // --- Write back, skipping documents whose figures did not move.
  const writes: Array<{ ref: FirebaseFirestore.DocumentReference; data: Record<string, unknown> }> = [];

  for (const doc of ingredientsSnapshot.docs) {
    const current = doc.data() as IngredientDocument;
    const cocktailCount = ingredientCounts.get(doc.id) ?? 0;
    const unlocks = unlocksFor(doc.id);

    if (current.cocktailCount === cocktailCount && current.unlocks === unlocks) {
      continue;
    }

    writes.push({ ref: doc.ref, data: { cocktailCount, unlocks, updatedAt: Timestamp.now() } });
  }

  const ingredientsUpdated = writes.length;

  for (const doc of equipmentSnapshot.docs) {
    const current = doc.data() as EquipmentDocument;
    const cocktailCount = equipmentCounts.get(doc.id) ?? 0;

    if (current.cocktailCount === cocktailCount) {
      continue;
    }

    writes.push({ ref: doc.ref, data: { cocktailCount, updatedAt: Timestamp.now() } });
  }

  const equipmentUpdated = writes.length - ingredientsUpdated;

  for (let offset = 0; offset < writes.length; offset += BATCH_LIMIT) {
    const batch = fs.batch();

    for (const write of writes.slice(offset, offset + BATCH_LIMIT)) {
      batch.update(write.ref, write.data);
    }

    await batch.commit();
  }

  return {
    cocktails: cocktails.length,
    ingredientsUpdated,
    equipmentUpdated,
    typicalShelf,
  };
}
