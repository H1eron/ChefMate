import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../viewmodel/fetchrecipe.dart';
import '../view/detail_view.dart'; 

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final FetchRecipe viewmodel;
  
  const RecipeCard({
    required this.recipe, 
    required this.viewmodel, 
    super.key
  });

  @override
  Widget build(BuildContext context) {
    // Gunakan key (String) untuk favorit
    bool isFav = viewmodel.isFavorite(recipe.key); 

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailView(recipe: recipe)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C), 
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  // Ganti Image.asset ke Image.network untuk URL dari API
                  child: Image.network(
                    recipe.imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    // Tambahkan builder untuk loading dan error
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 200, 
                        width: double.infinity,
                        color: const Color(0xFF2C2C2C),
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                            color: const Color(0xFFE55800),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200, 
                      width: double.infinity,
                      color: const Color(0xFF2C2C2C),
                      child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey, size: 50)),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    // Gunakan key (String)
                    onTap: () => viewmodel.toggleFavorite(recipe.key), 
                    child: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.grey, size: 16),
                      const SizedBox(width: 4),
                      Text(recipe.duration, style: const TextStyle(color: Colors.grey)),
                      const SizedBox(width: 16),
                      const Icon(Icons.people, color: Colors.grey, size: 16),
                      const SizedBox(width: 4),
                      Text(recipe.servings, style: const TextStyle(color: Colors.grey)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          recipe.difficulty,
                          style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}