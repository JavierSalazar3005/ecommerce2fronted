import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/order_provider.dart';
import 'providers/cart_provider.dart';
import 'services/api_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/client/catalog_screen.dart';
import 'screens/empresa/empresa_products_screen.dart';
import 'models/role.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(apiService)),
        ChangeNotifierProvider(create: (_) => ProductProvider(apiService)),
        ChangeNotifierProvider(create: (_) => OrderProvider(apiService)),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'Javier\'s Ecommerce',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
        ),
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const AuthWrapper(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (!authProvider.isAuthenticated) {
      return const LoginScreen();
    }

    // Redirigir según el rol del usuario
    if (authProvider.userRole == Role.cliente) {
      return const CatalogScreen();
    } else if (authProvider.userRole == Role.empresa) {
      return const EmpresaProductsScreen();
    }

    // Fallback
    return const LoginScreen();
  }
}
