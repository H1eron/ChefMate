import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';

class FetchRecipe with ChangeNotifier {
  final RecipeService _recipeService = RecipeService();
  
  // Recipe State
  List<Recipe> _recipes = []; 
  bool _isLoading = false;
  String _activeCategory = 'Semua';
  String _searchQuery = '';
  
  // Auth/User State (Dummy Implementation)
  bool _isLoggedIn = false;
  String? _userEmail;
  String? _userName;
  String? _phoneNumber;
  String? _photoUrl; 
  
  // Favorite State
  final Map<String, Recipe> _favoriteRecipes = {}; 
  
  // MARK: - Getters

  bool get isLoading => _isLoading;
  String get activeCategory => _activeCategory;
  
  // Auth Getters
  bool get isLoggedIn => _isLoggedIn;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  String? get phoneNumber => _phoneNumber;
  String? get photoUrl => _photoUrl; 
  
  // Favorite Getters
  List<Recipe> get favoriteRecipes => _favoriteRecipes.values.toList();
  bool isFavorite(String key) => _favoriteRecipes.containsKey(key);

  List<Recipe> get recipes {
    if (_searchQuery.isEmpty) {
      return _recipes;
    }
    
    // Melakukan filter judul secara lokal 
    return _recipes.where((recipe) {
      final titleLower = recipe.title.toLowerCase();
      final searchLower = _searchQuery.toLowerCase();
      return titleLower.contains(searchLower);
    }).toList();
  }
  
  // MARK: - Auth Methods (Dummy Logic)

  void login(String email, String password) {
    if (email.isNotEmpty && password.length >= 6) {
      _isLoggedIn = true;
      _userEmail = email;
      _userName = 'Chef $email'; 
      _phoneNumber = '081234567890';
    } else {
      _isLoggedIn = false;
    }
    notifyListeners();
  }

  void register(String name, String email, String password, String phoneNumber) {
    if (password.length >= 6) {
      _isLoggedIn = true; 
      _userEmail = email;
      _userName = name;
      _phoneNumber = phoneNumber;
    }
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _userEmail = null;
    _userName = null;
    _phoneNumber = null;
    notifyListeners();
  }

  // MARK: - Favorite Methods

  void toggleFavorite(String key) {
    if (isFavorite(key)) {
      _favoriteRecipes.remove(key);
    } else {
      Recipe? recipeToAdd;
      // Coba cari di list resep saat ini
      try {
        recipeToAdd = _recipes.firstWhere((r) => r.key == key);
      } catch (_) {
        // Jika tidak ditemukan, abaikan atau gunakan objek minimal
        debugPrint('Recipe minimal not found in current list for key: $key');
        return; 
      }
      _favoriteRecipes[key] = recipeToAdd;
    }
    notifyListeners();
  }
  
  // MARK: - Recipe API Methods

  Future<void> loadRecipes() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Panggil API dengan kategori aktif, yang kini menangani logika gabungan untuk 'Semua'
      _recipes = await _recipeService.fetchRecipesByQuery(_activeCategory);
    } catch (e) {
      debugPrint('Error loading recipes for $_activeCategory: $e');
      _recipes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(String category) {
    if (_activeCategory == category) return;
    
    _activeCategory = category;
    _searchQuery = ''; 
    // Memuat data baru dari API berdasarkan kategori yang dipilih
    loadRecipes(); 
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners(); 
  }

  // Fungsi Detail Loader
  Future<Recipe> getRecipeWithDetails(String key) async {
    Recipe minimalRecipe;
    
    // 1. Dapatkan objek resep minimal (dari list yang sedang tampil atau favorit)
    try {
      minimalRecipe = _recipes.firstWhere((r) => r.key == key);
    } catch (_) {
       if (_favoriteRecipes.containsKey(key)) {
        minimalRecipe = _favoriteRecipes[key]!;
      } else {
        throw Exception("Recipe object not found for key: $key. Cannot fetch details.");
      }
    }
    
    // 2. Fetch detail lengkap dari API
    final detailJson = await _recipeService.fetchRecipeDetails(key);
    
    // 3. Return objek resep yang diperbarui
    return minimalRecipe.copyWithDetail(detailJson);
  }
}