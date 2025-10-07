/**
 * Ingredient Domain Tests
 * 
 * Basic test examples for the ingredient functionality.
 * You can expand these with a proper testing framework later.
 */

import { IngredientService } from './ingredient.service';
import { CreateIngredientDto } from './ingredient.model';

// Example usage (for testing locally)
export async function testIngredientOperations() {
  const service = new IngredientService();
  
  try {
    // Example 1: Create ingredients
    const vodkaData: CreateIngredientDto = {
      title: {
        en: 'Vodka',
        uk: 'Горілка'
      },
      category: 'spirit',
      image: 'gs://party-bar/ingredients/vodka.png'
    };
    
    const limeData: CreateIngredientDto = {
      title: {
        en: 'Fresh Lime Juice',
        uk: 'Свіжий сік лайма'
      },
      category: 'mixer',
      image: 'gs://party-bar/ingredients/fresh-lime-juice.png'
    };
    
    console.log('Creating ingredients...');
    const vodka = await service.createIngredient(vodkaData);
    const lime = await service.createIngredient(limeData);
    
    console.log('Created:', vodka);
    console.log('Created:', lime);
    
    // Example 2: Get all ingredients
    console.log('\nGetting all ingredients...');
    const allIngredients = await service.getAllIngredients();
    console.log('All ingredients:', allIngredients);
    
    // Example 3: Get ingredients by category
    console.log('\nGetting spirits...');
    const spirits = await service.getIngredientsByCategory('spirit');
    console.log('Spirits:', spirits);
    
    // Example 4: Update an ingredient
    console.log('\nUpdating vodka...');
    const updatedVodka = await service.updateIngredient({
      id: vodka.id,
      title: {
        en: 'Premium Vodka',
        uk: 'Преміум Горілка'
      },
      image: 'gs://party-bar/ingredients/premium-vodka.png'
    });
    console.log('Updated:', updatedVodka);
    
    // Example 5: Get available categories
    console.log('\nAvailable categories:');
    const categories = service.getAvailableCategories();
    console.log(categories);
    
  } catch (error) {
    console.error('Test error:', error);
  }
}

// Uncomment to run tests locally
// testIngredientOperations();
