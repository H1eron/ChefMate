class Ingredient {
  final String name;
  final String amount;

  Ingredient({required this.name, required this.amount});

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient (
      name: json['name'] as String,
      amount: json['amount'] as String,
    );
  }
}

class Recipe {
  final int id;
  final String title;
  final String category;
  final String description;
  final String imageUrl;
  final String duration;
  final String servings;
  final String difficulty;
  final List<Ingredient> ingredients;
  final List<String> steps;

  Recipe({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.duration,
    required this.servings,
    required this.difficulty,
    required this.ingredients,
    required this.steps, 
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    var ingredientsList = json['ingredients'] as List;
    List<Ingredient> ingredients = ingredientsList
        .map((i) => Ingredient.fromJson(i as Map<String, dynamic>))
        .toList();
        
    List<String> steps = List<String>.from(json['steps'] ?? []);

    return Recipe(
      id: json['id'] as int,
      title: json['title'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      duration: json['duration'] as String,
      servings: json['servings'] as String,
      difficulty: json['difficulty'] as String,
      ingredients: ingredients,
      steps: steps, 
    );
  }
}

final dummyRecipes = [
  Recipe(
    id: 1,
    title: "Nasi Goreng Spesial",
    category: "Makanan Utama",
    description: "Nasi goreng khas Indonesia dengan bumbu rempah yang nikmat dan aroma yang menggugah selera.",
    imageUrl: "assets/images/nasigoreng.jpg",
    duration: "30 menit",
    servings: "3 porsi",
    difficulty: "Mudah",
    ingredients: [
      Ingredient(name: "nasi putih (dingin)", amount: "3 piring"),
      Ingredient(name: "telur", amount: "2 butir"),
      Ingredient(name: "ayam, potong dadu", amount: "100 gram"),
      Ingredient(name: "kecap manis", amount: "2 sdm"),
    ],
    steps: [
      "Siapkan wajan, panaskan sedikit minyak, dan orak-arik telur hingga matang. Sisihkan.",
      "Masukkan bumbu dasar, bawang putih, dan bawang merah. Tumis hingga harum.",
      "Masukkan ayam, masak hingga berubah warna.",
      "Masukkan nasi putih dan kecap manis, aduk rata hingga semua bumbu tercampur sempurna.",
      "Koreksi rasa, sajikan selagi hangat."
    ],
  ),
  Recipe(
    id: 2,
    title: "Sate Ayam Madura",
    category: "Makanan Utama",
    description: "Potongan ayam yang dibakar dan disajikan dengan bumbu kacang khas Madura yang kaya rasa.",
    imageUrl: "assets/images/sateayam.jpg",
    duration: "45 menit",
    servings: "4 porsi",
    difficulty: "Sedang",
    ingredients: [
      Ingredient(name: "daging ayam fillet", amount: "500 gram"),
      Ingredient(name: "bumbu kacang", amount: "200 gram"),
      Ingredient(name: "kecap manis", amount: "3 sdm"),
    ],
    steps: [ 
      "Potong daging ayam bentuk dadu, tusuk menggunakan tusuk sate.",
      "Campur bumbu kacang dengan sedikit air panas dan kecap manis.",
      "Lumuri sate dengan sedikit bumbu kacang, lalu bakar hingga setengah matang.",
      "Olesi sate dengan sisa bumbu kacang dan bakar kembali hingga matang sempurna.",
      "Sajikan sate dengan taburan bawang goreng dan acar."
    ],
  ),

  Recipe(
    id: 3,
    title: "Soto Ayam Bening",
    category: "Berkuah",
    description: "Soto ayam dengan kuah bening khas Nusantara, segar dan gurih.",
    imageUrl: "assets/images/sotoayam.jpg",
    duration: "60 menit",
    servings: "5 porsi",
    difficulty: "Sedang",
    ingredients: [
      Ingredient(name: "ayam", amount: "1/2 ekor"),
      Ingredient(name: "soun", amount: "1 bungkus"),
      Ingredient(name: "kol iris", amount: "100 gram"),
      Ingredient(name: "bumbu soto instan", amount: "1 bungkus"),
    ],
    steps: [
      "Rebus ayam hingga matang, ambil air kaldunya.",
      "Tumis bumbu soto hingga harum, masukkan ke dalam kaldu.",
      "Suwir ayam dan tata di mangkok bersama soun dan kol.",
      "Siram dengan kuah soto panas dan sajikan."
    ],
  ),

  Recipe(
    id: 4,
    title: "Es Cendol Dawet",
    category: "Minuman",
    description: "Minuman segar dari santan, gula merah, dan cendol hijau.",
    imageUrl: "assets/images/escendol.jpg",
    duration: "20 menit",
    servings: "3 gelas",
    difficulty: "Mudah",
    ingredients: [
      Ingredient(name: "cendol/dawet siap pakai", amount: "200 gram"),
      Ingredient(name: "santan kental", amount: "100 ml"),
      Ingredient(name: "gula merah cair", amount: "sesuai selera"),
      Ingredient(name: "es batu", amount: "secukupnya"),
    ],
    steps: [
      "Siapkan gelas, masukkan es batu.",
      "Tambahkan cendol dan gula merah cair.",
      "Tuang santan kental di atasnya.",
      "Aduk rata dan nikmati segera."
    ],
  ),

  Recipe(
    id: 5,
    title: "Rendang Sapi Pedas",
    category: "Makanan Utama",
    description: "Masakan daging sapi kaya rempah dari Sumatera Barat.",
    imageUrl: "assets/images/rendang.jpeg",
    duration: "240 menit",
    servings: "8 porsi",
    difficulty: "Sulit",
    ingredients: [
      Ingredient(name: "daging sapi", amount: "1 kg"),
      Ingredient(name: "santan kental", amount: "1 liter"),
      Ingredient(name: "bumbu rendang halus", amount: "250 gram"),
    ],
    steps: [
      "Masukkan daging, santan, dan bumbu halus ke wajan.",
      "Masak dengan api sedang sambil terus diaduk hingga santan mengering dan bumbu meresap.",
      "Kecilkan api, masak hingga rendang berwarna gelap dan minyak keluar."
    ],
  ),

  Recipe(
    id: 6,
    title: "Pisang Goreng Keju",
    category: "Cemilan",
    description: "Pisang yang digoreng krispi dengan topping keju parut.",
    imageUrl: "assets/images/pisanggoreng.jpg",
    duration: "15 menit",
    servings: "2 porsi",
    difficulty: "Mudah",
    ingredients: [
      Ingredient(name: "pisang kepok", amount: "5 buah"),
      Ingredient(name: "tepung terigu", amount: "100 gram"),
      Ingredient(name: "keju parut", amount: "secukupnya"),
    ],
    steps: [
      "Celupkan pisang ke adonan tepung.",
      "Goreng hingga kuning keemasan.",
      "Angkat, taburi dengan susu kental manis dan keju parut."
    ],
  ),

  Recipe(
    id: 7,
    title: "Sayur Asem Jakarta",
    category: "Berkuah",
    description: "Sayur tradisional dengan rasa asam, manis, dan pedas yang menyegarkan.",
    imageUrl: "assets/images/sayurasem.jpeg",
    duration: "40 menit",
    servings: "6 porsi",
    difficulty: "Mudah",
    ingredients: [
      Ingredient(name: "kacang panjang", amount: "1 ikat"),
      Ingredient(name: "jagung manis", amount: "1 buah"),
      Ingredient(name: "asam jawa", amount: "2 sdm"),
      Ingredient(name: "bumbu sayur asem instan", amount: "1 bungkus"),
    ],
    steps: [
      "Rebus air, masukkan jagung dan bumbu.",
      "Masukkan kacang panjang dan bumbu lainnya.",
      "Masak hingga semua sayuran matang dan kuah mendidih."
    ],
  ),
];