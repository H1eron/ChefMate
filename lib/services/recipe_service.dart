import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';

// Ganti base URL dengan API yang Anda sediakan
const String API_BASE_URL = 'https://masak-apa.tomorisakura.vercel.app';

class RecipeService {
  // Mengambil daftar resep dari endpoint /api/recipes
  Future<List<Recipe>> fetchRecipes() async {
    // Memberikan timeout untuk menghindari hang selamanya
    final url = Uri.parse('$API_BASE_URL/api/recipes');
    
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['status'] == true && data['results'] is List) {
          List<dynamic> recipesJson = data['results'];
          // Menggunakan Recipe.fromJsonList untuk parsing
          return recipesJson
              .map((json) => Recipe.fromJsonList(json as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception('Gagal memuat resep: API mengembalikan error atau format tidak sesuai.');
        }
      } else {
        throw Exception('Gagal memuat resep dengan status code: ${response.statusCode}');
      }
    } catch (e) {
      // Re-throw exception agar dapat ditangani di ViewModel
      rethrow; 
    }
  }
  
  // Mengambil detail resep dari endpoint /api/recipe/:key
  Future<Map<String, dynamic>> fetchRecipeDetails(String key) async {
    final url = Uri.parse('$API_BASE_URL/api/recipe/$key');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['status'] == true && data['results'] is Map) {
          return data['results'];
        } else {
          throw Exception('Gagal memuat detail resep untuk key $key: API mengembalikan error atau format tidak sesuai.');
        }
      } else {
        throw Exception('Gagal memuat detail resep dengan status code: ${response.statusCode}');
      }
    } catch (e) {
      // Re-throw exception agar dapat ditangani di ViewModel
      rethrow;
    }
  }
}