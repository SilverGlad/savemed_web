import 'package:flutter/material.dart' hide SearchController;
import 'package:provider/provider.dart';
import 'package:SaveMed/core/controllers/address_controller.dart';
import 'package:SaveMed/core/controllers/auth_controller.dart';
import 'package:SaveMed/core/controllers/card_controller.dart';
import 'package:SaveMed/core/controllers/cart_controller.dart';
import 'package:SaveMed/core/controllers/home_inventory_controller.dart';
import 'package:SaveMed/core/controllers/order_controller.dart';
import 'package:SaveMed/core/controllers/payment_controller.dart';
import 'package:SaveMed/core/controllers/pharmacy_controller.dart';
import 'package:SaveMed/core/controllers/search_controller.dart';
import 'core/controllers/category_controller.dart';
import 'core/controllers/inventory_controller.dart';
import 'core/services/category_service.dart';
import 'core/services/inventory_service.dart';
import 'core/theme/app_theme.dart';
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
        ChangeNotifierProvider(
          create: (context) {
            final auth = AuthController();
            auth.restoreSession(context);
            return auth;
          },
        ),

        ChangeNotifierProvider(create: (_) => OrderController()),

        ChangeNotifierProvider(create: (_) => HomeInventoryController()),

        ChangeNotifierProvider(create: (_) => PharmacyController()),

        ChangeNotifierProvider(create: (_) => CardController()),

        ChangeNotifierProvider(create: (_) => PaymentController()),
        ChangeNotifierProvider(
          create: (_) => HomeInventoryController()..load(),
        ),

        ChangeNotifierProvider(
          create: (context) =>
              SearchController(home: context.read<HomeInventoryController>()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const HomePage(),
      ),
    );
  }
}
