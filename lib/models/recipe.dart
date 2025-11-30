import 'dart:convert';
class Recipe {
  // Mengganti 'id' (int) dengan 'key' (String) dari API sebagai ID unik
  final String key; 
  final String title;
  // Menggunakan String? karena kategori tidak tersedia di endpoint list API
  final String? category; 
  // Menggunakan String? karena deskripsi hanya tersedia di endpoint detail
  final String? description; 
  // Sekarang berupa URL gambar dari API, bukan path asset lokal
  final String imageUrl;
  final String duration;
  final String servings;
  final String difficulty;
  // Menggunakan List<String> karena API detail mengembalikan ingredients dan steps dalam bentuk string siap pakai
  final List<String> ingredients; 
  final List<String> steps;

  Recipe({
    required this.key,
    required this.title,
    this.category,
    this.description,
    required this.imageUrl,
    required this.duration,
    required this.servings,
    required this.difficulty,
    this.ingredients = const [], // Inisialisasi kosong
    this.steps = const [], // Inisialisasi kosong
  });

  // Factory constructor untuk memparsing data dari API list (/api/recipes)
  factory Recipe.fromJsonList(Map<String, dynamic> json) {
    return Recipe(
      key: json['key'] as String,
      title: json['title'] as String,
      // API list tidak menyediakan kategori. Kita gunakan nilai default/placeholder.
      category: json['difficulty'] as String? ?? 'Umum', 
      // Menggunakan 'thumb' dari API
      imageUrl: json.containsKey('thumb') && json['thumb'] != null 
          ? json['thumb'] as String 
          : 'https://via.placeholder.com/150', // Placeholder jika thumb null
      duration: json['times'] as String? ?? 'N/A', // Menggunakan 'times' dari API
      servings: json['serving'] as String? ?? 'N/A', // Menggunakan 'serving' dari API
      difficulty: json['difficulty'] as String? ?? 'N/A',
      ingredients: [],
      steps: [], 
    );
  }
  
  // Method untuk memperbarui objek Recipe dengan detail dari API detail (/api/recipe/:key)
  Recipe copyWithDetail(Map<String, dynamic> detailJson) {
    List<String> ingredients = List<String>.from(detailJson['ingredient'] ?? []);
    List<String> steps = List<String>.from(detailJson['step'] ?? []);

    return Recipe(
      key: key,
      title: title,
      category: category,
      description: detailJson['desc'] as String? ?? this.description, // Menggunakan 'desc' dari API
      imageUrl: detailJson['thumb'] as String? ?? this.imageUrl, 
      duration: detailJson['times'] as String? ?? this.duration, 
      servings: detailJson['servings'] as String? ?? this.servings,
      difficulty: detailJson['difficulty'] as String? ?? this.difficulty,
      ingredients: ingredients,
      steps: steps,
    );
  }
}

// Hapus list dummyRecipes di sini.