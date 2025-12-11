import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/fetchrecipe.dart';
import '../widgets/recipe_card.dart';

class HomeView extends StatefulWidget { 
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController _searchController = TextEditingController();
  final orangeColor = const Color(0xFFE55800);
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Panggil loadRecipes saat pertama kali view dimuat
      Provider.of<FetchRecipe>(context, listen: false).loadRecipes();
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipeProvider = Provider.of<FetchRecipe>(context);
    final recipes = recipeProvider.recipes;
    
    return Scaffold(
      backgroundColor: const Color(0xFF1B1B1B),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Kategori", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildCategoryList(context),

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Semua Resep", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("${recipes.length} resep", style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                  const SizedBox(height: 12),

                  recipeProvider.isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.orange))
                      : (recipes.isEmpty && !recipeProvider.isLoading && recipeProvider.activeCategory != '')
                        ? _buildErrorState(recipeProvider) 
                        : Column(
                            children: recipes.map((recipe) => RecipeCard(recipe: recipe, viewmodel: recipeProvider)).toList(),
                          ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final viewmodel = Provider.of<FetchRecipe>(context, listen: false); 
    
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 20),
      decoration: BoxDecoration(
        color: orangeColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.restaurant_menu, color: Colors.white, size: 28),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("ChefMate", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("Jelajahi cita rasa Dunia", style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1B1B1B).withOpacity(0.8), 
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Cari resep yang diinginkan...",
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search, color: Colors.grey),
              ),
              onChanged: (query) {
                  viewmodel.setSearchQuery(query);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context) {
    // Kategori dari TheMealDB
    final categories = ["Semua", "Beef", "Chicken", "Dessert", "Side", "Pasta"];
    final viewmodel = Provider.of<FetchRecipe>(context);

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == viewmodel.activeCategory; 

          return GestureDetector( 
            onTap: () {
              viewmodel.setCategory(category); 
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? orangeColor : const Color(0xFF2C2C2C),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                category,
                style: TextStyle(color: isSelected ? Colors.white : Colors.grey),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(FetchRecipe viewmodel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, color: Colors.grey, size: 50),
            const SizedBox(height: 16),
            Text("Tidak ada resep untuk kategori ${viewmodel.activeCategory}", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
            const SizedBox(height: 8),
            Text(
              "Coba ganti kategori atau periksa koneksi internet Anda.",
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => viewmodel.loadRecipes(),
              style: ElevatedButton.styleFrom(backgroundColor: orangeColor),
              child: const Text("Coba Lagi"),
            ),
          ],
        ),
      ),
    );
  }
}