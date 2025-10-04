/**
 * Cocktail Domain Tests
 *
 * Basic test examples for the cocktail functionality.
 * You can expand these with a proper testing framework later.
 */

import { CocktailService } from './cocktail.service';
import { CreateCocktailDto } from './cocktail.model';

// Example usage (for testing locally)

export async function testCocktailOperations() {
  const service = new CocktailService();

  try {
    const espressoMartini: CreateCocktailDto = {
      title: {
        en: 'Espresso Martini',
        uk: 'Еспресо Мартіні',
      },
      description: {
        en: 'Shake all ingredients with ice and fine strain into a chilled coupe glass.',
        uk: 'Збовтайте всі інгредієнти з льодом і процідіть у охолоджений келих.',
      },
      ingredients: [
        'ingredients/vodka',
        'ingredients/coffee-liqueur',
        'ingredients/espresso',
        'ingredients/simple-syrup',
      ],
      equipments: [
        'equipment/cocktail-shaker',
        'equipment/coupe-glass',
        'equipment/strainer',
      ],
      categories: ['classic', 'signature'],
    };

    console.log('Creating cocktail...');
    const created = await service.createCocktail(espressoMartini);
    console.log('Created:', created);

    console.log('\nGetting all cocktails...');
    const allCocktails = await service.getAllCocktails();
    console.log('All cocktails:', allCocktails);

    console.log('\nFiltering cocktails by category "classic"...');
    const classics = await service.getCocktailsByCategory('classic');
    console.log('Classics:', classics);

    console.log('\nUpdating cocktail title...');
    const updated = await service.updateCocktail(created.id, {
      title: {
        en: 'Midnight Espresso Martini',
        uk: 'Нічний Еспресо Мартіні',
      },
    });
    console.log('Updated:', updated);

    console.log('\nDeleting cocktail...');
    await service.deleteCocktail(created.id);
    console.log('Deleted successfully');

    console.log('\nAvailable categories:');
    console.log(service.getAvailableCategories());
  } catch (error) {
    console.error('Cocktail test error:', error);
  }
}

// Uncomment to run tests locally
// testCocktailOperations();
