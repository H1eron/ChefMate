import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Diperlukan untuk Firebase Auth
import '../models/recipe.dart';
import '../services/recipe_service.dart';

class FetchRecipe with ChangeNotifier {
  final RecipeService _recipeService = RecipeService();
  final FirebaseAuth _auth = FirebaseAuth.instance; // Instance Firebase Auth

  // Recipe State
  List<Recipe> _recipes = []; 
  bool _isLoading = false;
  String _activeCategory = 'Semua';
  String _searchQuery = '';
  
  // Auth/User State
  // Gunakan User? dari Firebase untuk menentukan status login
  User? _currentUser; 
  String? _userName;
  String? _phoneNumber;
  String? _photoUrl; 
  
  // Favorite State
  final Map<String, Recipe> _favoriteRecipes = {}; 

  FetchRecipe() {
    // Memantau perubahan status autentikasi dari Firebase
    _auth.authStateChanges().listen((User? user) {
      _currentUser = user;
      _updateUserState(user); // Memperbarui state lokal
      notifyListeners();
    });
  }
  
  // MARK: - Getters

  bool get isLoading => _isLoading;
  String get activeCategory => _activeCategory;
  
  // Auth Getters
  // Status login ditentukan dari keberadaan _currentUser
  bool get isLoggedIn => _currentUser != null;
  String? get userEmail => _currentUser?.email;
  // Gunakan _userName lokal, karena Firebase hanya menyediakan displayName (yang mungkin kosong)
  String? get userName => _userName ?? _currentUser?.displayName ?? 'Pengguna';
  String? get phoneNumber => _phoneNumber;
  String? get photoUrl => _photoUrl; 
  
  // Favorite Getters
  List<Recipe> get favoriteRecipes => _favoriteRecipes.values.toList();
  bool isFavorite(String key) => _favoriteRecipes.containsKey(key);

  List<Recipe> get recipes {
    if (_searchQuery.isEmpty) {
      return _recipes;
    }
    
    return _recipes.where((recipe) {
      final titleLower = recipe.title.toLowerCase();
      final searchLower = _searchQuery.toLowerCase();
      return titleLower.contains(searchLower);
    }).toList();
  }
  
  // MARK: - Internal User State Update

  // Memperbarui state lokal (misalnya _userName, _phoneNumber) saat status auth berubah
  void _updateUserState(User? user) {
    if (user != null) {
      // Di sini Anda bisa mengambil data profil tambahan dari Firestore/Database 
      // (asumsi: saat register, Anda menyimpan nama/phone ke Firestore)
      // Untuk tujuan UAS, kita akan gunakan nilai default/dummy yang disimpan sebelumnya
      _userName = user.displayName ?? 'Pengguna Baru'; // Gunakan displayName dari Firebase jika ada
      _phoneNumber = user.phoneNumber ?? 'Belum Diatur'; 
      _photoUrl = user.photoURL;
    } else {
      _userName = null;
      _phoneNumber = null;
      _photoUrl = null;
    }
  }

  // MARK: - Firebase Auth Methods

  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Login berhasil, state akan diupdate oleh authStateChanges listener
      return null; // Return null menandakan sukses
    } on FirebaseAuthException catch (e) {
      // Handle error spesifik dari Firebase
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> register(String name, String email, String password, String phoneNumber) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update display name (nama pengguna) di Firebase
      await userCredential.user?.updateDisplayName(name);

      // Catatan: Menyimpan nomor telepon di Firebase Auth memerlukan verifikasi SMS.
      // Untuk memenuhi UAS, kita hanya menyimpan nama dan email di Auth.
      // Jika Anda perlu menyimpan phone number, Anda harus menggunakan Firestore/Realtime DB.
      
      _userName = name;
      _phoneNumber = phoneNumber;
      _currentUser = userCredential.user; // Update state
      notifyListeners();
      return null; // Return null menandakan sukses
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    // Logout berhasil, state akan diupdate oleh authStateChanges listener
  }

  // MARK: - Favorite Methods (Tetap sama)

  void toggleFavorite(String key) {
    if (isFavorite(key)) {
      _favoriteRecipes.remove(key);
    } else {
      Recipe? recipeToAdd;
      try {
        recipeToAdd = _recipes.firstWhere((r) => r.key == key);
      } catch (_) {
        debugPrint('Recipe minimal not found in current list for key: $key');
        return; 
      }
      _favoriteRecipes[key] = recipeToAdd;
    }
    notifyListeners();
  }
  
  // MARK: - Recipe API Methods (Tetap sama)

  Future<void> loadRecipes() async {
    _isLoading = true;
    notifyListeners();
    
    try {
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
    loadRecipes(); 
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners(); 
  }

  Future<Recipe> getRecipeWithDetails(String key) async {
    Recipe minimalRecipe;
    
    try {
      minimalRecipe = _recipes.firstWhere((r) => r.key == key);
    } catch (_) {
       if (_favoriteRecipes.containsKey(key)) {
        minimalRecipe = _favoriteRecipes[key]!;
      } else {
        throw Exception("Recipe object not found for key: $key. Cannot fetch details.");
      }
    }
    
    final detailJson = await _recipeService.fetchRecipeDetails(key);
    
    return minimalRecipe.copyWithDetail(detailJson);
  }
}