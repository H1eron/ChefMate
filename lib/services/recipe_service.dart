import '../models/recipe.dart';

class RecipeService {
  
  Future<List<Recipe>> fetchRecipes() async {
    await Future.delayed(const Duration(milliseconds: 500)); 

    return dummyRecipes;
  }
}