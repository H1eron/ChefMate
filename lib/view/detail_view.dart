import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../viewmodel/fetchrecipe.dart';

// Ganti StatelessWidget menjadi StatefulWidget untuk memuat detail
class DetailView extends StatefulWidget { 
  final Recipe recipe;
  const DetailView({super.key, required this.recipe});
  
  // Tambahkan getter untuk key
  String get recipeKey => recipe.key;

  @override
  State<DetailView> createState() => _DetailViewState();
}

class _DetailViewState extends State<DetailView> {
  final orangeColor = const Color(0xFFE55800);
  final darkCardColor = const Color(0xFF2C2C2C);
  final darkBgColor = const Color(0xFF1B1B1B);

  // Menyimpan data resep lengkap setelah dimuat
  Recipe? _detailedRecipe;

  @override
  void initState() {
    super.initState();
    _loadRecipeDetails();
  }

  // Fungsi untuk memuat detail resep dari ViewModel
  Future<void> _loadRecipeDetails() async {
    // Gunakan listen: false karena ini di dalam initState
    final viewmodel = Provider.of<FetchRecipe>(context, listen: false); 
    // Menggunakan key untuk mengambil detail lengkap
    final fullRecipe = await viewmodel.getRecipeWithDetails(widget.recipeKey); 
    
    // Periksa apakah widget masih mounted sebelum memanggil setState
    if(mounted) {
      setState(() {
        _detailedRecipe = fullRecipe;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Gunakan _detailedRecipe jika sudah dimuat, jika tidak, gunakan data dasar.
    final recipeToShow = _detailedRecipe ?? widget.recipe;
    final viewmodel = Provider.of<FetchRecipe>(context);
    bool isFav = viewmodel.isFavorite(recipeToShow.key);
    
    // Tampilkan loading jika detail belum dimuat (description kosong/null)
    if (_detailedRecipe == null || recipeToShow.description == null || recipeToShow.description!.isEmpty) {
      return Scaffold(
        backgroundColor: darkBgColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: orangeColor),
              SizedBox(height: 16),
              Text('Memuat detail resep...', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: darkBgColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kirim semua data yang diperlukan ke header
            _buildImageHeader(context, viewmodel, isFav, recipeToShow.imageUrl, recipeToShow.key), 
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRecipeInfo(recipeToShow),
                  const SizedBox(height: 24),
                  _buildIngredientsList(recipeToShow), 
                  const SizedBox(height: 24),
                  _buildStepsList(recipeToShow), 
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageHeader(BuildContext context, FetchRecipe viewmodel, bool isFav, String imageUrl, String recipeKey) {
    return Stack(
      children: [
        Image.network( // Menggunakan Image.network
          imageUrl,
          height: 300,
          width: double.infinity,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 300, 
              width: double.infinity,
              color: darkCardColor,
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                  color: orangeColor,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => Container(
            height: 300, 
            width: double.infinity,
            color: darkCardColor,
            child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey, size: 50)),
          ),
        ),
        // Tombol Kembali
        Positioned(
          top: 40,
          left: 10,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        // Tombol Favorit
        Positioned(
          top: 40,
          right: 10,
          child: IconButton(
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () => viewmodel.toggleFavorite(recipeKey), // Gunakan key
          ),
        ),
      ],
    );
  }

  Widget _buildRecipeInfo(Recipe recipeToShow) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: darkCardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  recipeToShow.title,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              // Label Kesulitan
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  recipeToShow.difficulty,
                  style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            // Gunakan description dari data detail
            recipeToShow.description ?? 'Deskripsi tidak tersedia.',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.access_time, color: orangeColor, size: 20),
              const SizedBox(width: 4),
              Text(recipeToShow.duration, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(width: 20),
              Icon(Icons.people, color: orangeColor, size: 20),
              const SizedBox(width: 4),
              Text(recipeToShow.servings, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsList(Recipe recipeToShow) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: darkCardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.kitchen, color: orangeColor, size: 20),
              const SizedBox(width: 8),
              const Text(
                "Bahan-Bahan",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(color: Colors.grey, height: 20),
          // Daftar Bahan (List<String>)
          if (recipeToShow.ingredients.isEmpty) 
            const Text('Bahan belum dimuat atau tidak tersedia.', style: TextStyle(color: Colors.white70)),
          
          ...recipeToShow.ingredients.map((ing) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("• ", style: TextStyle(color: orangeColor, fontSize: 18)),
                Expanded(
                  child: Text(
                    // String sudah diformat dari API
                    ing, 
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildStepsList(Recipe recipeToShow) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: darkCardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Cara Memasak",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(color: Colors.grey, height: 20),
          if (recipeToShow.steps.isEmpty) 
            const Text('Langkah-langkah belum dimuat atau tidak tersedia.', style: TextStyle(color: Colors.white70)),
            
          // Daftar Langkah (List<String>)
          ...recipeToShow.steps.asMap().entries.map((entry) {
            String step = entry.value;

            // Cek apakah step sudah diawali dengan penomoran dari API (misalnya "1. ")
            bool isNumbered = RegExp(r'^\d+\.?\s').hasMatch(step.trim());
            // Jika belum ada nomor dari API, tambahkan secara manual
            String stepText = isNumbered ? step.trim() : "${entry.key + 1}. ${step.trim()}";

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      stepText, // Tampilkan teks langkah yang sudah diformat
                      style: const TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}