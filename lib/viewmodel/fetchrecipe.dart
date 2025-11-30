import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';

class FetchRecipe with ChangeNotifier {
  // Ganti Set<int> menjadi Set<String> untuk menyimpan key resep
  final Set<String> _favoriteRecipeIds = {}; 
  final RecipeService _recipeService = RecipeService();

  List<Recipe> _recipes = [];
  bool _isLoading = false;
  
  // Cache untuk menyimpan detail resep yang sudah dimuat agar tidak perlu memanggil API berulang kali
  final Map<String, Recipe> _recipeDetailsCache = {}; 
  
  String _activeCategory = "Semua";
  String _searchQuery = "";
  bool _isLoggedIn = false;

  String? _userName;
  String? _userEmail;
  String? _userPassword;
  String? _photoUrl;
  String? _phoneNumber;

  bool get isLoggedIn => _isLoggedIn;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get phoneNumber => _phoneNumber;
  String get activeCategory => _activeCategory;
  bool get isLoading => _isLoading;
  String? get photoUrl => null;

  FetchRecipe() {
    loadRecipes();
  }

  Future<void> loadRecipes() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _recipes = await _recipeService.fetchRecipes();
      // Pastikan resep yang sudah ada di cache juga diperbarui jika ada yang terlewat dari fetch awal
      _recipes.forEach((recipe) {
        if (_recipeDetailsCache.containsKey(recipe.key)) {
          // Hanya update data dasar (title, times, etc.)
          _recipeDetailsCache[recipe.key] = recipe.copyWithDetail({}); 
        }
      });
      
    } catch (e) {
      // Biarkan _recipes kosong jika gagal memuat, tampilan akan menunjukkan loading error
      _recipes = []; 
    }
    
    _isLoading = false;
    notifyListeners();
  }

  // Mengambil detail resep dari cache atau API
  Future<Recipe> getRecipeWithDetails(String key) async {
    // 1. Cek cache
    if (_recipeDetailsCache.containsKey(key)) {
      return _recipeDetailsCache[key]!;
    }
    
    // 2. Cari data dasar dari list _recipes
    // Gunakan find atau cari dummy/base jika tidak ada di list (seharusnya ada)
    Recipe? baseRecipe;
    try {
      baseRecipe = _recipes.firstWhere((r) => r.key == key);
    } catch (e) {
       // Buat resep minimal jika tidak ditemukan di list (kasus aneh, tapi aman)
       baseRecipe = Recipe(
        key: key, 
        title: 'Memuat Detail...', 
        imageUrl: 'https://via.placeholder.com/150',
        duration: 'N/A', 
        servings: 'N/A', 
        difficulty: 'N/A',
      );
    }

    // 3. Ambil detail dari API
    try {
      final detailJson = await _recipeService.fetchRecipeDetails(key);
      final detailedRecipe = baseRecipe.copyWithDetail(detailJson);
      
      // Simpan ke cache
      _recipeDetailsCache[key] = detailedRecipe; 
      
      // Notify listener agar detail view bisa rebuild dengan data baru
      notifyListeners(); 

      return detailedRecipe;

    } catch (e) {
      // Jika gagal memuat detail, kembalikan data dasar yang ada
      return baseRecipe; 
    }
  }


  List<Recipe> get favoriteRecipes {
    return _recipes
        .where((recipe) => _favoriteRecipeIds.contains(recipe.key))
        .toList();
  }

  // Mengubah tipe filter: sekarang hanya mencari 'difficulty' karena kategori dari API tidak sesuai
  List<Recipe> get recipes {
    Iterable<Recipe> filteredRecipes = _recipes;
    if (_activeCategory != "Semua") {
      // Kita coba filter berdasarkan kata kunci dari kategori di UI (Misal: "Berkuah" di search title, atau "Mudah" di difficulty)
      final filterQuery = _activeCategory.toLowerCase();
      filteredRecipes = filteredRecipes.where(
        (r) => r.difficulty.toLowerCase().contains(filterQuery) || r.title.toLowerCase().contains(filterQuery),
      );
    }
    if (_searchQuery.isNotEmpty) {
      filteredRecipes = filteredRecipes.where(
        (r) => r.title.toLowerCase().contains(_searchQuery),
      );
    }
    return filteredRecipes.toList();
  }

  void setCategory(String category) {
    _activeCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    notifyListeners();
  }

  // Gunakan key (String)
  bool isFavorite(String key) {
    return _favoriteRecipeIds.contains(key);
  }

  // Gunakan key (String)
  void toggleFavorite(String key) {
    if (_favoriteRecipeIds.contains(key)) {
      _favoriteRecipeIds.remove(key);
    } else {
      _favoriteRecipeIds.add(key);
    }
    notifyListeners();
  }

  void login(String email, String password) {
    if (email.isNotEmpty && password.isNotEmpty) {
      _isLoggedIn = true;

      if (_userName == null || _userName!.isEmpty) {
        _userName = "Pengguna Aktif";
      }
      _userEmail = email;
    } else {
      _isLoggedIn = false;
      _userName = null;
      _userEmail = null;
    }
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _userName = null;
    _userEmail = null;
    _photoUrl = null;
    _phoneNumber = null; 
    notifyListeners();
  }

  void register(
    String fullName,
    String email,
    String password,
    String phoneNumber,
  ) {
    if (fullName.isNotEmpty &&
        email.isNotEmpty &&
        password.isNotEmpty &&
        phoneNumber.isNotEmpty) {
      _userName = fullName;
      _userEmail = email;
      _userPassword = password;
      _phoneNumber = phoneNumber; 
      _isLoggedIn = false;
    } else {
      _isLoggedIn = false;
    }
    notifyListeners();
  }
}