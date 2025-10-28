// lib/view/account_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/fetchrecipe.dart';

class AccountView extends StatelessWidget {
  const AccountView({super.key});

  final orangeColor = const Color(0xFFE55800);
  final darkCardColor = const Color(0xFF2C2C2C);
  final darkBgColor = const Color(0xFF1B1B1B);

  // Widget simulasi untuk mengganti foto
  void _showChangePhotoDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Simulasi: Fungsi ganti foto dipanggil!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewmodel = Provider.of<FetchRecipe>(context);

    // Ambil data dari ViewModel
    final userName = viewmodel.userName ?? 'Pengguna';
    final userEmail = viewmodel.userEmail ?? 'Email tidak tersedia';
    final userPhone = viewmodel.phoneNumber ?? 'Belum Diatur';
    final photoUrl = viewmodel.photoUrl;

    if (!viewmodel.isLoggedIn && viewmodel.userEmail == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF1B1B1B),
        body: Center(
          child: Text(
            "Anda belum login.",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: darkBgColor,
      // AppBar dihilangkan sesuai permintaan
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // SECTION 1: HEADER PROFIL (Tanpa Ikon Back/Settings)
          _buildProfileHeaderCard(context, userName, userEmail, photoUrl),

          // SECTION 2: DETAIL AKUN
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 10.0,
            ),
            child: Text(
              "Data Akun",
              style: TextStyle(fontSize: 14, color: Colors.grey[400]),
            ),
          ),

          // 1. Email
          _buildDetailSection('Email', Icons.email, userEmail),

          // 2. NOMOR TELEPON
          _buildDetailSection('Nomor Telepon', Icons.phone_android, userPhone),

          // 3. Favorit
          _buildDetailSection(
            'Favorit',
            Icons.favorite,
            "${viewmodel.favoriteRecipes.length} Resep Tersimpan",
          ),

          // 🛑 Menu Keamanan telah dihapus sesuai permintaan.

          // SECTION 3: LOGOUT BUTTON
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: ElevatedButton.icon(
              onPressed: () {
                viewmodel.logout();
              },
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                "Logout",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Widget _buildProfileHeaderCard yang sudah disederhanakan (tanpa Stack dan Positioned)
  Widget _buildProfileHeaderCard(
    BuildContext context,
    String userName,
    String userEmail,
    String? photoUrl,
  ) {
    return Container(
      width: double.infinity,
      // Padding atas disesuaikan untuk mengkompensasi hilangnya AppBar
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: darkCardColor),
      child: Center(
        child: Column(
          children: [
            // FOTO PROFIL INTERAKTIF
            GestureDetector(
              onTap: () => _showChangePhotoDialog(context),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: orangeColor,
                backgroundImage: photoUrl != null
                    ? AssetImage(photoUrl) as ImageProvider
                    : null,
                child: photoUrl == null
                    ? const Icon(Icons.person, size: 50, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(height: 15),

            // USERNAME (Mengambil data dari ViewModel yang sudah di-register)
            Text(
              userName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, IconData icon, String subtitle) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: orangeColor),
          title: Text(title, style: const TextStyle(color: Colors.white)),
          subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[400])),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.white54,
          ),
          onTap: () {
            // Aksi ketika ListTile diklik
          },
        ),
        Divider(height: 1, color: Colors.grey[700], indent: 20, endIndent: 20),
      ],
    );
  }
}
