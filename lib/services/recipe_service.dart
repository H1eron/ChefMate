import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';

// Base URL TheMealDB
const String API_BASE_URL = 'https://www.themealdb.com/api/json/v1/1';

class RecipeService {
  
  // Fungsi untuk mengambil daftar semua kategori yang tersedia
  Future<List<String>> fetchAllCategories() async {
    // Endpoint list all categories
    final url = Uri.parse('$API_BASE_URL/list.php?c=list');
    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['meals'] is List) {
        return (data['meals'] as List)
            .map((e) => e['strCategory'] as String)
            .toList();
      }
      return [];
    } else {
      throw Exception('Gagal memuat daftar kategori: ${response.statusCode}');
    }
  }
  
  // Fungsi utama yang diperbarui untuk mengambil resep berdasarkan query atau SEMUA
  Future<List<Recipe>> fetchRecipesByQuery(String query) async {
    if (query.toLowerCase() == 'semua') {
      // Panggil fungsi gabungan jika query adalah 'semua'
      return await _fetchCombinedRecipesFromAllCategories();
    } 
    
    // Logic untuk filter spesifik (Beef, Chicken, dll) menggunakan endpoint filter
    final url = Uri.parse('$API_BASE_URL/filter.php?c=$query');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['meals'] is List) {
          List<dynamic> mealsJson = data['meals'];
          return mealsJson
              .map((json) => Recipe.fromJsonList(json as Map<String, dynamic>))
              .toList();
        } else {
          return [];
        }
      } else {
        throw Exception('Gagal memuat resep untuk query "$query" dengan status code: ${response.statusCode}');
      }
    } catch (e) {
      rethrow; 
    }
  }
  
  // Fungsi baru untuk menggabungkan resep dari semua kategori
  Future<List<Recipe>> _fetchCombinedRecipesFromAllCategories() async {
    // 1. Ambil semua kategori
    final categories = await fetchAllCategories();
    
    // 2. Batasi jumlah kategori yang diambil agar tidak terlalu lambat/rate-limited
    // Kita ambil 10-12 kategori pertama yang paling populer jika list terlalu panjang.
    final limitedCategories = categories.take(12).toList();
    
    // 3. Buat daftar Future untuk mengambil resep dari setiap kategori secara paralel
    List<Future<List<Recipe>>> futures = limitedCategories.map((category) {
      // Panggil fetchRecipesByQuery untuk setiap kategori
      return fetchRecipesByQuery(category);
    }).toList();

    // 4. Tunggu hingga semua request selesai
    final results = await Future.wait(futures);

    // 5. Gabungkan semua daftar resep dan hilangkan duplikat
    final Map<String, Recipe> uniqueRecipes = {};
    for (var recipeList in results) {
      for (var recipe in recipeList) {
        // Gunakan key (idMeal) untuk memastikan keunikan
        uniqueRecipes[recipe.key] = recipe;
      }
    }

    return uniqueRecipes.values.toList();
  }
  
  // Mengambil detail resep dari endpoint lookup.php?i={id}
  Future<Map<String, dynamic>> fetchRecipeDetails(String key) async {
    final url = Uri.parse('$API_BASE_URL/lookup.php?i=$key');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['meals'] is List && data['meals'].isNotEmpty) {
          return data['meals'][0]; 
        } else {
          throw Exception('Gagal memuat detail resep untuk key $key: API mengembalikan data kosong.');
        }
      } else {
        throw Exception('Gagal memuat detail resep dengan status code: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}