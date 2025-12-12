import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Wajib ada untuk database
import '../models/recipe.dart';
import '../services/recipe_service.dart';

class FetchRecipe with ChangeNotifier {
  final RecipeService _recipeService = RecipeService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Instance Firestore

  // Recipe State
  List<Recipe> _recipes = []; 
  bool _isLoading = false;
  String _activeCategory = 'Semua';
  String _searchQuery = '';
  
  // Auth/User State
  User? _currentUser; 
  String? _userName;
  String? _phoneNumber;
  String? _photoUrl; 
  
  // Favorite State
  final Map<String, Recipe> _favoriteRecipes = {}; 

  FetchRecipe() {
    // Listener untuk mendeteksi Login/Logout secara otomatis
    _auth.authStateChanges().listen((User? user) {
      _currentUser = user;
      if (user != null) {
        // Jika user login: Ambil data profil DAN data favoritnya dari database
        _fetchUserProfile(user.uid);
        _fetchUserFavorites(user.uid);
      } else {
        // Jika logout: Bersihkan data di aplikasi agar tidak tercampur
        _clearLocalUserData();
      }
      notifyListeners();
    });
  }
  
  // MARK: - Getters
  bool get isLoading => _isLoading;
  String get activeCategory => _activeCategory;
  
  bool get isLoggedIn => _currentUser != null;
  String? get userEmail => _currentUser?.email;
  String? get userName => _userName ?? _currentUser?.displayName ?? 'Pengguna';
  String? get phoneNumber => _phoneNumber;
  String? get photoUrl => _photoUrl; 
  
  List<Recipe> get favoriteRecipes => _favoriteRecipes.values.toList();
  bool isFavorite(String key) => _favoriteRecipes.containsKey(key);

  List<Recipe> get recipes {
    if (_searchQuery.isEmpty) return _recipes;
    
    return _recipes.where((recipe) {
      final titleLower = recipe.title.toLowerCase();
      final searchLower = _searchQuery.toLowerCase();
      return titleLower.contains(searchLower);
    }).toList();
  }
  
  // Membersihkan data lokal saat Logout
  void _clearLocalUserData() {
    _userName = null;
    _phoneNumber = null;
    _photoUrl = null;
    _favoriteRecipes.clear(); // PENTING: Kosongkan favorit saat logout
  }

  // MARK: - Firestore Logic (Ini yang membuat data tersimpan!)

  // 1. Mengambil Profil User
  Future<void> _fetchUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        _userName = data['name'] ?? _currentUser?.displayName;
        _phoneNumber = data['phoneNumber'];
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Gagal mengambil profil: $e");
    }
  }

  // 2. Mengambil Favorit User dari Database
  Future<void> _fetchUserFavorites(String uid) async {
    try {
      // Mengambil data dari sub-collection 'favorites' milik user yang sedang login
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('favorites')
          .get();

      _favoriteRecipes.clear(); // Bersihkan list lama

      for (var doc in snapshot.docs) {
        final data = doc.data();
        // Masukkan data dari database ke list aplikasi
        final recipe = Recipe(
          key: data['key'],
          title: data['title'],
          imageUrl: data['imageUrl'],
          category: data['category'],
          description: data['description'],
          ingredients: List<String>.from(data['ingredients'] ?? []),
          steps: List<String>.from(data['steps'] ?? []),
        );
        _favoriteRecipes[recipe.key] = recipe;
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Gagal mengambil favorit: $e");
    }
  }

  // 3. Menambah/Menghapus Favorit ke Database
  Future<void> toggleFavorite(String key) async {
    if (_currentUser == null) return; // Pastikan user login
    
    final uid = _currentUser!.uid;
    final docRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(key);

    if (isFavorite(key)) {
      // HAPUS dari Database
      try {
        await docRef.delete();
        _favoriteRecipes.remove(key); // Update tampilan
        notifyListeners();
      } catch (e) {
        debugPrint("Gagal menghapus favorit: $e");
      }
    } else {
      // SIMPAN ke Database
      Recipe? recipeToAdd;
      try {
        recipeToAdd = _recipes.firstWhere((r) => r.key == key);
      } catch (_) {
        debugPrint('Resep tidak ditemukan di list saat ini');
        return; 
      }

      try {
        // Simpan semua detail resep agar nanti bisa diambil tanpa API call ulang
        await docRef.set({
          'key': recipeToAdd.key,
          'title': recipeToAdd.title,
          'category': recipeToAdd.category,
          'imageUrl': recipeToAdd.imageUrl,
          'description': recipeToAdd.description,
          'ingredients': recipeToAdd.ingredients,
          'steps': recipeToAdd.steps,
          'addedAt': FieldValue.serverTimestamp(),
        });

        _favoriteRecipes[key] = recipeToAdd; // Update tampilan
        notifyListeners();
      } catch (e) {
        debugPrint("Gagal menyimpan favorit: $e");
      }
    }
  }

  // MARK: - Auth Methods

  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> register(String name, String email, String password, String phoneNumber) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User? user = userCredential.user;
      await user?.updateDisplayName(name);

      // Simpan data user ke Firestore saat register
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': name,
          'email': email,
          'phoneNumber': phoneNumber,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      
      _userName = name;
      _phoneNumber = phoneNumber;
      _currentUser = user;
      notifyListeners();
      return null; 
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    // Data akan dibersihkan oleh listener di constructor
  }
  
  // MARK: - Recipe API Methods

  Future<void> loadRecipes() async {
    _isLoading = true;
    notifyListeners();
    try {
      _recipes = await _recipeService.fetchRecipesByQuery(_activeCategory);
    } catch (e) {
      debugPrint('Error loading recipes: $e');
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
       // Cek di favorit jika tidak ada di list utama (misal buka detail dari tab Favorit)
       if (_favoriteRecipes.containsKey(key)) {
        minimalRecipe = _favoriteRecipes[key]!;
      } else {
        throw Exception("Recipe not found");
      }
    }
    
    final detailJson = await _recipeService.fetchRecipeDetails(key);
    return minimalRecipe.copyWithDetail(detailJson);
  }
}