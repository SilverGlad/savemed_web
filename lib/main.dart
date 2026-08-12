import 'package:flutter/material.dart' hide SearchController;
import 'package:provider/provider.dart';
import 'package:savemed/core/controllers/address_controller.dart';
import 'package:savemed/core/controllers/auth_controller.dart';
import 'package:savemed/core/controllers/card_controller.dart';
import 'package:savemed/core/controllers/cart_controller.dart';
import 'package:savemed/core/controllers/home_inventory_controller.dart';
import 'package:savemed/core/controllers/order_controller.dart';
import 'package:savemed/core/controllers/payment_controller.dart';
import 'package:savemed/core/controllers/pharmacy_controller.dart';
import 'package:savemed/core/controllers/search_controller.dart';
import 'core/controllers/category_controller.dart';
import 'core/controllers/inventory_controller.dart';
import 'core/services/category_service.dart';
import 'core/services/inventory_service.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/admin/admin_page.dart';
import 'features/auth/auth_page.dart';
import 'features/home/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔹 Serviços (single instance)
    final inventoryService = InventoryService();
    final categoryService = CategoryService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              InventoryController(inventoryService: inventoryService),
        ),

        ChangeNotifierProvider(
          create: (_) => CategoryController(categoryService: categoryService),
        ),

        ChangeNotifierProvider(create: (_) => AddressController()),
        ChangeNotifierProvider(create: (_) => CartController()),
        ChangeNotifierProvider(create: (_) => AuthController()),

        ChangeNotifierProvider(create: (_) => OrderController()),

        ChangeNotifierProvider(create: (_) => HomeInventoryController()),

        ChangeNotifierProvider(create: (_) => PharmacyController()),

        ChangeNotifierProvider(create: (_) => CardController()),

        ChangeNotifierProvider(create: (_) => PaymentController()),

        ChangeNotifierProvider(
          create: (context) =>
              SearchController(home: context.read<HomeInventoryController>()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SaveMed',
        theme: AppTheme.light,
        home: const _SessionGate(),
      ),
    );
  }
}

class _SessionGate extends StatefulWidget {
  const _SessionGate();

  @override
  State<_SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<_SessionGate> {
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    context.read<AuthController>().restoreSession(
      context.read<AddressController>(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    if (auth.loading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!auth.isLogged) return const AuthPage();
    return auth.isAdmin ? const AdminPage() : const HomePage();
  }
}
