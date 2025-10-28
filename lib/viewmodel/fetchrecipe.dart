// lib/viewmodel/fetchrecipe.dart

import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';

class FetchRecipe with ChangeNotifier {
  final Set<int> _favoriteRecipeIds = {};
  final RecipeService _recipeService = RecipeService();

  List<Recipe> _recipes = [];
  bool _isLoading = false;

  // State Logic
  String _activeCategory = "Semua";
  String _searchQuery = "";
  bool _isLoggedIn = false;

  // States Autentikasi
  String? _userName;
  String? _userEmail;
  String? _userPassword;
  String? _photoUrl;
  String? _phoneNumber; // ✅ State untuk Nomor Telepon

  // Getters
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
    _recipes = await _recipeService.fetchRecipes();
    _isLoading = false;
    notifyListeners();
  }

  // Logic Getter Resep
  List<Recipe> get favoriteRecipes {
    return _recipes
        .where((recipe) => _favoriteRecipeIds.contains(recipe.id))
        .toList();
  }

  List<Recipe> get recipes {
    Iterable<Recipe> filteredRecipes = _recipes;
    if (_activeCategory != "Semua") {
      filteredRecipes = filteredRecipes.where(
        (r) => r.category == _activeCategory,
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

  bool isFavorite(int id) {
    return _favoriteRecipeIds.contains(id);
  }

  void toggleFavorite(int id) {
    if (_favoriteRecipeIds.contains(id)) {
      _favoriteRecipeIds.remove(id);
    } else {
      _favoriteRecipeIds.add(id);
    }
    notifyListeners();
  }

  // ⭐️ LOGIC AUTENTIKASI SIMPLIFIED (SYNCHRONOUS) ⭐️

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
    _phoneNumber = null; // ✅ Reset Nomor Telepon
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
      _phoneNumber = phoneNumber; // ✅ Menyimpan nilai input
      _isLoggedIn = false; // TIDAK LANGSUNG LOGIN
    } else {
      _isLoggedIn = false;
    }
    notifyListeners();
  }
}
