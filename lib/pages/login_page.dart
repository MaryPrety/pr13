import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Константы для цветов и размеров
const Color primaryColor = Color(0xFFC84B31);
const Color secondaryColor = Color(0xFFECDBBA);
const Color textColor = Color(0xFF56423D);
const Color backgroundColor = Color(0xFF191919);
const double defaultPadding = 16.0;
const double defaultRadius = 10.0;
const double defaultTextSize = 14.0;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.session != null) {
        Navigator.pushReplacementNamed(context, '/profile');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error $e')));
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              color: secondaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(defaultRadius),
              ),
              child: Container(
                padding: const EdgeInsets.all(defaultPadding),
                width: screenWidth < 600 ? screenWidth * 0.9 : 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'MANgo100',
                      style: TextStyle(
                        fontSize: screenWidth < 600 ? 24.0 : 32.0,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildInputField('Email', _emailController, hintText: 'example@example.com'),
                    const SizedBox(height: 24),
                    _buildInputField('Password', _passwordController, obscureText: true, hintText: 'Минимум 8 символов'),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Login'),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/register'),
                      child: const Text('Do not have an account? Sign Up'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller,
      {bool obscureText = false, String? hintText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: textColor,
            fontSize: 16.0,
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: secondaryColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(defaultRadius),
              borderSide: const BorderSide(color: textColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(defaultRadius),
              borderSide: const BorderSide(color: textColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(defaultRadius),
              borderSide: const BorderSide(color: primaryColor),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          style: const TextStyle(
            color: textColor,
            fontSize: defaultTextSize,
            fontFamily: 'Tektur',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Пожалуйста, введите $label';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Главная',
          backgroundColor: Color.fromRGBO(45, 66, 99, 1),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'Избранное',
          backgroundColor: Color.fromRGBO(45, 66, 99, 1),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Корзина',
          backgroundColor: Color.fromRGBO(45, 66, 99, 1),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Профиль',
          backgroundColor: Color.fromRGBO(45, 66, 99, 1),
        ),
      ],
      currentIndex: 3, // Устанавливаем текущий индекс на "Профиль"
      selectedItemColor: const Color.fromRGBO(200, 75, 49, 1),
      unselectedItemColor: const Color(0xFFECDBBA),
      onTap: (index) {
        if (index == 0) {
          Navigator.pushReplacementNamed(context, '/home');
        } else if (index == 1) {
          Navigator.pushReplacementNamed(context, '/manga_selected');
        } else if (index == 2) {
          Navigator.pushReplacementNamed(context, '/cart');
        } else if (index == 3) {
          Navigator.pushReplacementNamed(context, '/profile');
        }
      },
    );
  }
}