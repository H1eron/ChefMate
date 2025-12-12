class Recipe {
  // Menggunakan idMeal dari TheMealDB sebagai key
  final String key; 
  final String title;
  // strCategory dari TheMealDB
  final String? category; 
  // strInstructions yang disingkat dari TheMealDB akan menjadi description
  final String? description; 
  // strMealThumb dari TheMealDB
  final String imageUrl;
  
  // Properti duration, servings, dan difficulty telah dihapus
  
  final List<String> ingredients; 
  final List<String> steps;

  Recipe({
    required this.key,
    required this.title,
    this.category,
    this.description,
    required this.imageUrl,
    this.ingredients = const [], 
    this.steps = const [], 
  });

  // Factory constructor untuk memparsing data dari API list/search/filter
  factory Recipe.fromJsonList(Map<String, dynamic> json) {
    final String idMeal = json['idMeal'] as String? ?? 'N/A';
    final String strMeal = json['strMeal'] as String? ?? 'Nama Resep Tidak Tersedia';
    // strCategory mungkin tidak ada di endpoint filter, gunakan default
    final String strCategory = json['strCategory'] as String? ?? 'Umum'; 
    final String strMealThumb = json['strMealThumb'] as String? ?? 
        'https://via.placeholder.com/150';

    return Recipe(
      key: idMeal,
      title: strMeal,
      category: strCategory.isNotEmpty ? strCategory : 'Umum', 
      imageUrl: strMealThumb, 
      ingredients: [],
      steps: [], 
    );
  }
  
  // Method untuk memperbarui objek Recipe dengan detail dari API lookup (lookup.php?i=...)
  Recipe copyWithDetail(Map<String, dynamic> detailJson) {
    // 1. Ambil instruksi (strInstructions)
    final String instructions = detailJson['strInstructions'] as String? ?? 'Instruksi tidak tersedia.';

    // 2. Buat daftar bahan (ingredients)
    List<String> ingredientsList = [];
    for (int i = 1; i <= 20; i++) {
        final ingredient = detailJson['strIngredient$i'] as String?;
        final measure = detailJson['strMeasure$i'] as String?;

        if (ingredient != null && ingredient.isNotEmpty) {
            final formattedIngredient = measure != null && measure.isNotEmpty && measure.trim() != '-'
                ? "${measure.trim()} ${ingredient.trim()}"
                : ingredient.trim();
            ingredientsList.add(formattedIngredient);
        }
    }
    
    // 3. Pisahkan instruksi (strInstructions) menjadi langkah-langkah (steps)
    List<String> stepsList = instructions
        .split(RegExp(r'[\r\n]+')) 
        .map((step) => step.trim())
        .where((step) => step.isNotEmpty)
        .toList();

    // 4. Buat deskripsi singkat dari instruksi
    String shortDescription = instructions.substring(0, instructions.length.clamp(0, 300));
    if (instructions.length > 300) {
      shortDescription += '...';
    }

    return Recipe(
      key: key,
      title: title,
      category: detailJson['strCategory'] as String? ?? this.category,
      description: shortDescription,
      imageUrl: detailJson['strMealThumb'] as String? ?? this.imageUrl, 
      ingredients: ingredientsList,
      steps: stepsList,
    );
  }
}