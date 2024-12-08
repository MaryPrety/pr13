import 'package:flutter/material.dart';

// Константы для цветов и размеров
const Color primaryColor = Color(0xFFC84B31);
const Color secondaryColor = Color(0xFFECDBBA);
const Color textColor = Color(0xFF56423D);
const Color backgroundColor = Color(0xFF191919);
const double defaultPadding = 16.0;
const double defaultRadius = 10.0;
const double defaultTextSize = 14.0;

class Authorization extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _rememberMe = false;
  String? _gender = 'М'; // Инициализация пола
  String? _country = 'Россия'; // Инициализация страны
  bool _isEditing = false; // Переменная для контроля состояния редактирования

  final TextEditingController _fullNameController = TextEditingController(text: 'Наруто Узумаки');
  final TextEditingController _emailController = TextEditingController(text: 'naruto@example.com');
  final TextEditingController _passwordController = TextEditingController(text: 'rasengan123');
  final TextEditingController _confirmPasswordController = TextEditingController(text: 'rasengan123');
  final TextEditingController _ageController = TextEditingController(text: '17');
  final TextEditingController _avatarUrlController = TextEditingController(text: 'https://i.pinimg.com/736x/36/d8/5a/36d85aa74c895789fdb04c86ac69550e.jpg');

  // Переменные для хранения сохраненных данных
  String? _savedFullName = 'Наруто Узумаки';
  String? _savedEmail = 'naruto@example.com';
  String? _savedAge = '17';
  String? _savedCountry = 'Япония';
  String? _savedGender = 'М';
  String? _savedAvatarUrl = 'https://i.pinimg.com/736x/36/d8/5a/36d85aa74c895789fdb04c86ac69550e.jpg';

  void _saveProfile() {
    setState(() {
      _savedFullName = _fullNameController.text;
      _savedEmail = _emailController.text;
      _savedAge = _ageController.text;
      _savedCountry = _country;
      _savedGender = _gender;
      _savedAvatarUrl = _avatarUrlController.text;
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final cardWidth = isMobile ? screenWidth : screenWidth * 0.4;
    final fontSize = isMobile ? 24.0 : 32.0;

    return Padding(
      padding: const EdgeInsets.all(defaultPadding),
      child: Center(
        child: SingleChildScrollView(
          child: Card(
            color: secondaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(defaultRadius),
            ),
            child: Container(
              width: cardWidth,
              padding: const EdgeInsets.all(defaultPadding),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'MANgo100',
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _isEditing ? _buildEditableForm(isMobile) : _buildProfileView(isMobile), // Логика переключения между режимами
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (bool? value) {
                            setState(() {
                              _rememberMe = value ?? false;
                            });
                          },
                          activeColor: primaryColor,
                        ),
                        const Text(
                          'Прочитал и согласен с правилами',
                          style: TextStyle(color: textColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: isMobile ? double.infinity : 200,
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            if (_isEditing) {
                              _saveProfile(); // Сохранение данных
                            } else {
                              _isEditing = true; // Переход в режим редактирования
                            }
                          });
                        },
                        child: Text(
                          _isEditing ? 'Сохранить профиль' : 'Редактировать профиль',
                          style: TextStyle(color: primaryColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditableForm(bool isMobile) {
    return isMobile ? _buildSingleColumnLayout() : _buildDoubleColumnLayout();
  }

  Widget _buildProfileView(bool isMobile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_savedAvatarUrl != null && _savedAvatarUrl!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: defaultPadding),
            child: Container(
              width: isMobile ? MediaQuery.of(context).size.width * 0.3 : 150,
              height: isMobile ? MediaQuery.of(context).size.width * 0.90 : 300,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(defaultRadius),
                image: DecorationImage(
                  image: NetworkImage(_savedAvatarUrl!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileItem('ФИО', _savedFullName),
              const SizedBox(height: 16),
              _buildProfileItem('Пол', _savedGender),
              const SizedBox(height: 16),
              _buildProfileItem('Возраст', _savedAge),
              const SizedBox(height: 16),
              _buildProfileItem('Страна', _savedCountry),
              const SizedBox(height: 16),
              _buildProfileItem('Почта', _savedEmail),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileItem(String label, String? value) {
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
        Text(
          value ?? 'Не указано',
          style: const TextStyle(
            color: textColor,
            fontSize: defaultTextSize,
          ),
        ),
      ],
    );
  }

  Widget _buildSingleColumnLayout() {
    return Column(
      children: [
        _buildInputField('ФИО', _fullNameController, hintText: 'Иванов Иван Иванович'),
        const SizedBox(height: 24),
        _buildGenderAndAgeSelection(),
        const SizedBox(height: 24),
        _buildCountrySelection(),
        const SizedBox(height: 24),
        _buildInputField('Почта', _emailController, hintText: 'example@example.com'),
        const SizedBox(height: 24),
        _buildInputField('Пароль', _passwordController, obscureText: true, hintText: 'Минимум 8 символов'),
        const SizedBox(height: 24),
        _buildInputField('Повторите пароль', _confirmPasswordController, obscureText: true, hintText: 'Повторите пароль'),
        const SizedBox(height: 24),
        _buildInputField('Ссылка на аватар', _avatarUrlController, hintText: 'Введите ссылку на изображение'),
      ],
    );
  }

  Widget _buildDoubleColumnLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInputField('ФИО', _fullNameController, hintText: 'Иванов Иван Иванович'),
              const SizedBox(height: 24),
              _buildGenderAndAgeSelection(),
              const SizedBox(height: 24),
              _buildCountrySelection(),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInputField('Почта', _emailController, hintText: 'example@example.com'),
              const SizedBox(height: 24),
              _buildInputField('Пароль', _passwordController, obscureText: true, hintText: 'Минимум 8 символов'),
              const SizedBox(height: 24),
              _buildInputField('Повторите пароль', _confirmPasswordController, obscureText: true, hintText: 'Повторите пароль'),
              const SizedBox(height: 24),
              _buildInputField('Ссылка на аватар', _avatarUrlController, hintText: 'Введите ссылку на изображение'),
            ],
          ),
        ),
      ],
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

  Widget _buildGenderAndAgeSelection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Пол',
                style: TextStyle(
                  color: textColor,
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Radio<String>(
                    value: 'М',
                    groupValue: _gender,
                    onChanged: (value) {
                      setState(() {
                        _gender = value;
                      });
                    },
                    activeColor: primaryColor,
                  ),
                  const Text('М', style: TextStyle(color: textColor)),
                  Radio<String>(
                    value: 'Ж',
                    groupValue: _gender,
                    onChanged: (value) {
                      setState(() {
                        _gender = value;
                      });
                    },
                    activeColor: primaryColor,
                  ),
                  const Text('Ж', style: TextStyle(color: textColor)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildInputField('Возраст', _ageController, hintText: 'Ваш возраст'),
        ),
      ],
    );
  }

  Widget _buildCountrySelection() {
    const List<String> countries = [
      'Россия', 'Украина', 'Беларусь', 'Казахстан', 'Другая'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Страна',
          style: TextStyle(
            color: textColor,
            fontSize: 16.0,
          ),
        ),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: _country,
          onChanged: (String? newValue) {
            setState(() {
              _country = newValue;
            });
          },
          items: countries.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          decoration: InputDecoration(
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
          icon: const Icon(Icons.arrow_drop_down, color: textColor),
        ),
      ],
    );
  }
}