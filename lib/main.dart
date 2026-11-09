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
import 'core/services/admin_service.dart';
import 'core/services/category_service.dart';
import 'core/services/inventory_service.dart';
import 'features/pharmacy/pharmacy_page.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/admin/admin_page.dart';
import 'features/auth/auth_page.dart';
import 'features/home/home_page.dart';
import 'models/pharmacy.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  final AuthController? authController;
  final AddressController? addressController;
  final CategoryController? categoryController;
  final HomeInventoryController? homeInventoryController;
  final AdminService? adminService;

  const MyApp({
    super.key,
    this.authController,
    this.addressController,
    this.categoryController,
    this.homeInventoryController,
    this.adminService,
  });

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
          create: (_) =>
              categoryController ??
              CategoryController(categoryService: categoryService),
        ),

        ChangeNotifierProvider(
          create: (_) => addressController ?? AddressController(),
        ),
        ChangeNotifierProvider(create: (_) => CartController()),
        ChangeNotifierProvider(create: (_) => OrderController()),
        ChangeNotifierProvider(create: (_) => CardController()),
        ChangeNotifierProvider(create: (_) => PaymentController()),
        ChangeNotifierProvider(
          create: (context) =>
              authController ??
              AuthController(
                cards: context.read<CardController>(),
                cart: context.read<CartController>(),
                orders: context.read<OrderController>(),
                payments: context.read<PaymentController>(),
              ),
        ),

        ChangeNotifierProvider(
          create: (_) => homeInventoryController ?? HomeInventoryController(),
        ),

        ChangeNotifierProvider(create: (_) => PharmacyController()),

        ChangeNotifierProvider(
          create: (context) =>
              SearchController(home: context.read<HomeInventoryController>()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SaveMed',
        theme: AppTheme.light,
        builder: (context, child) => SafeArea(child: child!),
        routes: {
          PharmacyPage.routeName: (context) {
            final pharmacy = ModalRoute.of(context)?.settings.arguments;
            if (pharmacy is Pharmacy) {
              return PharmacyPage(pharmacy: pharmacy);
            }
            return const _InvalidPharmacyRoute();
          },
        },
        home: _SessionGate(adminService: adminService ?? const AdminService()),
      ),
    );
  }
}

class _InvalidPharmacyRoute extends StatelessWidget {
  const _InvalidPharmacyRoute();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Não foi possível abrir esta farmácia.')),
    );
  }
}

class _SessionGate extends StatefulWidget {
  final AdminService adminService;

  const _SessionGate({required this.adminService});

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

    if (auth.sessionRestoreError != null) {
      return _SessionRestoreFailure(message: auth.sessionRestoreError!);
    }

    if (!auth.isLogged) return const AuthPage();
    return auth.isAdmin
        ? AdminPage(service: widget.adminService)
        : const HomePage();
  }
}

class _SessionRestoreFailure extends StatelessWidget {
  final String message;

  const _SessionRestoreFailure({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cloud_off_outlined,
                    size: 48,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Não foi possível entrar agora',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => context
                          .read<AuthController>()
                          .restoreSession(context.read<AddressController>()),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar novamente'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: context.read<AuthController>().logout,
                    child: const Text('Entrar com outra conta'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
