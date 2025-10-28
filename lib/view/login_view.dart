// lib/view/login_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/fetchrecipe.dart';
import 'account_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _registerEmailController =
      TextEditingController();
  final TextEditingController _registerPasswordController =
      TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneNumberController =
      TextEditingController(); // ✅ Controller Nomor Telepon

  final orangeColor = const Color(0xFFE55800);
  bool _isLoginMode = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewmodel = Provider.of<FetchRecipe>(context, listen: false);
      if (viewmodel.userEmail != null) {
        _emailController.text = viewmodel.userEmail!;
        _isLoginMode = true;
      } else {
        _isLoginMode = false;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _confirmPasswordController.dispose();
    _phoneNumberController.dispose(); // ✅ Dispose Controller Nomor Telepon
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewmodel = Provider.of<FetchRecipe>(context);

    if (viewmodel.isLoggedIn) {
      return const AccountView();
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildAuthHeader(),
            Transform.translate(
              offset: const Offset(0, -100),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2C),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: _isLoginMode
                      ? _buildLoginFormContent(context, viewmodel)
                      : _buildRegisterFormContent(context, viewmodel),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // MARK: - Core Logic (Synchronous)

  void _performLogin(BuildContext context, FetchRecipe viewmodel) {
    final email = _emailController.text;
    final password = _passwordController.text;

    viewmodel.login(email, password);

    if (!viewmodel.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login Gagal. Email/Password kosong.')),
      );
    }
  }

  void _performRegister(BuildContext context, FetchRecipe viewmodel) {
    if (_registerPasswordController.text.length >= 6) {
      // ✅ Panggilan register dengan 4 parameter
      viewmodel.register(
        _nameController.text,
        _registerEmailController.text,
        _registerPasswordController.text,
        _phoneNumberController.text,
      );

      if (!viewmodel.isLoggedIn) {
        _emailController.text = _registerEmailController.text;
        _nameController.clear();
        _registerEmailController.clear();
        _registerPasswordController.clear();
        _confirmPasswordController.clear();
        _phoneNumberController.clear();

        setState(() {
          _isLoginMode = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrasi Berhasil! Silakan Masuk.')),
        );
      }
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi Gagal: Password harus minimal 6 karakter.'),
        ),
      );
    }
  }

  // MARK: - Layout Methods

  Widget _buildAuthHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 150),
      decoration: BoxDecoration(
        color: orangeColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.ramen_dining, color: Colors.white, size: 28),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Selamat Datang",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Mulai petualangan kuliner Anda",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoginFormContent(BuildContext context, FetchRecipe viewmodel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Tombol Switch Masuk/Daftar
        Row(
          children: [
            _buildAuthTab("Masuk", true, () {}),
            _buildAuthTab("Daftar", false, () {
              setState(() {
                _isLoginMode = false;
              });
            }),
          ],
        ),
        const SizedBox(height: 24),
        const Center(child: Icon(Icons.person, size: 50, color: Colors.white)),
        const SizedBox(height: 8),
        const Text(
          "Masuk ke Akun",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          "Akses resep favorit Anda",
          style: TextStyle(color: Colors.grey[400]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),

        _buildAuthInput(
          _emailController,
          "Email",
          "nama@email.com",
          Icons.email,
        ),
        const SizedBox(height: 16),
        _buildAuthInput(
          _passwordController,
          "Password",
          "Masukkan password",
          Icons.lock,
          isPassword: true,
        ),
        const SizedBox(height: 30),

        ElevatedButton(
          onPressed: () {
            _performLogin(context, viewmodel);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: orangeColor,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            "Masuk",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Dengan mendaftar, Anda menyetujui syarat dan ketentuan kami",
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRegisterFormContent(
    BuildContext context,
    FetchRecipe viewmodel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Tombol Switch Masuk/Daftar
        Row(
          children: [
            _buildAuthTab("Masuk", false, () {
              setState(() {
                _isLoginMode = true;
              });
            }),
            _buildAuthTab("Daftar", true, () {}),
          ],
        ),
        const SizedBox(height: 24),
        const Center(
          child: Icon(Icons.person_add, size: 50, color: Colors.white),
        ),
        const SizedBox(height: 8),
        const Text(
          "Buat Akun Baru",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          "Bergabung dengan komunitas pecinta kuliner",
          style: TextStyle(color: Colors.grey[400]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),

        _buildAuthInput(
          _nameController,
          "Nama Lengkap",
          "Masukkan nama Anda",
          Icons.person,
        ),
        const SizedBox(height: 16),
        _buildAuthInput(
          _registerEmailController,
          "Email",
          "nama@email.com",
          Icons.email,
        ),
        const SizedBox(height: 16),
        _buildAuthInput(
          _phoneNumberController,
          "Nomor Telepon",
          "Masukkan nomor telepon",
          Icons.phone,
        ), // ✅ Field Nomor Telepon
        const SizedBox(height: 16),
        _buildAuthInput(
          _registerPasswordController,
          "Password",
          "Minimal 6 karakter",
          Icons.lock,
          isPassword: true,
        ),
        const SizedBox(height: 16),
        _buildAuthInput(
          _confirmPasswordController,
          "Konfirmasi Password",
          "Ulangi password",
          Icons.lock,
          isPassword: true,
        ),
        const SizedBox(height: 30),

        ElevatedButton(
          onPressed: () {
            _performRegister(context, viewmodel);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: orangeColor,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            "Daftar Sekarang",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Dengan mendaftar, Anda menyetujui syarat dan ketentuan kami",
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAuthInput(
    TextEditingController controller,
    String label,
    String hint,
    IconData icon, {
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: isPassword,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[600]),
            fillColor: const Color(0xFF1B1B1B),
            filled: true,
            prefixIcon: Icon(icon, color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAuthTab(String title, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? orangeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
