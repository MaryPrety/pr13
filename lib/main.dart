import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'pages/home_page.dart';
import 'pages/manga_selected.dart';
import 'pages/cart_page.dart'; // Импортируем страницу корзины
import 'pages/login_page.dart'; // Импортируем страницу входа
import 'pages/register_page.dart'; // Импортируем страницу регистрации
import 'pages/profile_page.dart'; // Импортируем страницу профиля
import 'providers/favorite_provider.dart';
import 'providers/cart_provider.dart'; // Импортируем CartProvider

void main() async {
  // Инициализация Supabase
  await Supabase.initialize(
    url: 'https://mqohkpdemmfqlespuvxe.supabase.co',
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1xb2hrcGRlbW1mcWxlc3B1dnhlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzE4Mjg1NzUsImV4cCI6MjA0NzQwNDU3NX0.uocESaHYfax5qdZnKV7rAkEmOjT2GtWsarAUFjoV3JY",
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()), // Добавляем CartProvider
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690), // Размер дизайна для мобильных устройств
      builder: (context, child) {
        return MaterialApp(
          title: 'MANgo100',
          theme: ThemeData(
            fontFamily: 'Russo One',
            scaffoldBackgroundColor: const Color.fromRGBO(45, 66, 99, 1),
            appBarTheme: const AppBarTheme(
              color: Color.fromRGBO(45, 66, 99, 1),
              iconTheme: IconThemeData(color: Color(0xFFECDBBA)),
              titleTextStyle: TextStyle(
                color: Color(0xFFECDBBA),
                fontFamily: 'Russo One',
                fontSize: 20,
              ),
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Color.fromRGBO(45, 66, 99, 1), // Темно-синий фон
              selectedItemColor: Color.fromRGBO(200, 75, 49, 1),
              unselectedItemColor: Color(0xFFECDBBA),
            ),
          ),
          home: const AuthGate(),
          onUnknownRoute: (settings) {
            return MaterialPageRoute(builder: (context) => const MainPage(initialIndex: 0)); // Перенаправление на домашнюю страницу при ошибке маршрута
          },
          routes: {
            '/login': (context) => const LoginPage(),
            '/register': (context) => const RegisterPage(),
            '/profile': (context) => const ProfilePage(),
            '/home': (context) => const MainPage(initialIndex: 0),
            '/manga_selected': (context) => const MainPage(initialIndex: 1),
            '/cart': (context) => const MainPage(initialIndex: 2),
          },
        );
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final session = snapshot.data?.session;
          if (session != null) {
            return const MainPage(initialIndex: 0);
          } else {
            return const LoginPage();
          }
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class MainPage extends StatefulWidget {
  final int initialIndex;

  const MainPage({super.key, required this.initialIndex});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late int _selectedIndex;

  final List<Widget> _pages = [
    HomePage(),
    MangaSelectedPage(),
    CartPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final totalCartItems = cartProvider.cartItems.fold(0, (sum, item) => sum + cartProvider.getItemQuantity(item));

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
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
            icon: Stack(
              alignment: Alignment.center, // Центрируем элементы
              children: [
                Icon(Icons.shopping_cart), // Кнопка корзины
                if (totalCartItems > 0)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        '$totalCartItems',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Корзина',
            backgroundColor: Color.fromRGBO(45, 66, 99, 1),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Профиль',
            backgroundColor: Color.fromRGBO(45, 66, 99, 1),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromRGBO(200, 75, 49, 1),
        unselectedItemColor: const Color(0xFFECDBBA),
        onTap: (index) {
          if (index == 3) {
            _handleProfileIconTap(context);
          } else {
            _onItemTapped(index);
          }
        },
      ),
    );
  }

  void _handleProfileIconTap(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      Navigator.pushNamed(context, '/profile');
    } else {
      Navigator.pushNamed(context, '/login');
    }
  }
}