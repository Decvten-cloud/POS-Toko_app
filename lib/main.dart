import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toko_app/providers/cart_provider.dart';
import 'package:toko_app/providers/debt_provider.dart';
import 'package:toko_app/providers/product_provider.dart';
import 'package:toko_app/screens/cashier_screen.dart';
import 'package:toko_app/screens/debt_screen.dart';
import 'package:toko_app/screens/products_screen.dart';
import 'package:toko_app/screens/summary_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => DebtProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Warung Kasir',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.teal,
            primary: Colors.teal,
            secondary: Colors.orangeAccent,
          ),
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            elevation: 0.8,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            centerTitle: false,
          ),
          textTheme: const TextTheme(
            headlineSmall: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            bodyLarge: TextStyle(fontSize: 18),
            bodyMedium: TextStyle(fontSize: 16),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          navigationBarTheme: NavigationBarThemeData(
            height: 76,
            indicatorColor: Colors.teal.shade100,
            labelTextStyle: MaterialStateProperty.all(
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            iconTheme: MaterialStateProperty.all(const IconThemeData(size: 32)),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0.8,
      upperBound: 1.08,
    )..repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeNavigator()),
      );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ScaleTransition(
            scale: _ctrl,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.flash_on, size: 80, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeNavigator extends StatefulWidget {
  const HomeNavigator({super.key});

  @override
  State<HomeNavigator> createState() => _HomeNavigatorState();
}

class _HomeNavigatorState extends State<HomeNavigator> {
  int _selectedIndex = 0;

  static const List<String> _pageTitles = [
    'Kasir',
    'Barang',
    'Ringkasan',
    'Utang',
  ];

  static const List<Widget> _pages = [
    CashierScreen(),
    ProductsScreen(),
    SummaryScreen(),
    DebtScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _pageTitles[_selectedIndex],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: IndexedStack(index: _selectedIndex, children: _pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onTabTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.point_of_sale),
            label: 'Kasir',
          ),
          NavigationDestination(icon: Icon(Icons.inventory_2), label: 'Barang'),
          NavigationDestination(
            icon: Icon(Icons.bar_chart),
            label: 'Ringkasan',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Utang',
          ),
        ],
      ),
    );
  }
}
