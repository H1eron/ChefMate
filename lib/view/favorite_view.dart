import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/fetchrecipe.dart';
import '../widgets/recipe_card.dart';

class FavoriteView extends StatelessWidget {
  const FavoriteView({super.key});

  final orangeColor = const Color(0xFFE55800);

  @override
  Widget build(BuildContext context) {
    return Consumer<FetchRecipe>(
      builder: (context, viewmodel, child) {
        final favoriteRecipes = viewmodel.favoriteRecipes;

        return Scaffold(
          backgroundColor: const Color(0xFF1B1B1B),
          body: Column(
            children: [
              _buildFavoriteHeader(favoriteRecipes.length),
              Expanded(
                child: favoriteRecipes.isEmpty
                    ? _buildEmptyState() 
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: favoriteRecipes.length,
                        itemBuilder: (context, index) {
                          return RecipeCard(recipe: favoriteRecipes[index], viewmodel: viewmodel);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFavoriteHeader(int count) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 20),
      decoration: BoxDecoration(
        color: orangeColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.favorite, color: Colors.white, size: 28),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Resep Favorit", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Text("$count resep tersimpan", style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite_border, color: Colors.grey, size: 80),
          const SizedBox(height: 16),
          const Text("Belum Ada Favorit", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            "Tambahkan resep ke favorit untuk melihatnya di sini",
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}