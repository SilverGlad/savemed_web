import 'package:flutter/material.dart' hide SearchController;
import 'package:provider/provider.dart';

import 'package:SaveMed/core/controllers/auth_controller.dart';
import 'package:SaveMed/core/controllers/cart_controller.dart';
import 'package:SaveMed/core/controllers/search_controller.dart';
import 'package:SaveMed/core/theme/app_colors.dart';

import 'package:SaveMed/features/auth/auth_page.dart';
import 'package:SaveMed/features/cart/cart_page.dart';
import 'package:SaveMed/features/profile/profile_page.dart';

class SaveMedHeader extends StatefulWidget {
  SaveMedHeader({super.key});

  @override
  State<SaveMedHeader> createState() => _SaveMedHeaderState();
}

class _SaveMedHeaderState extends State<SaveMedHeader> {
  OverlayEntry? _overlay;

  void _showOverlay() {
    if (_overlay != null) return;

    _overlay = OverlayEntry(
      builder: (context) => Positioned(
        top: 60, // abaixo do header
        left: 24,
        right: 24,
        child: const _SearchOverlay(),
      ),
    );

    Overlay.of(context).insert(_overlay!);
  }

  void _hideOverlay() {
    _overlay?.remove();
    _overlay = null;
  }

  @override
  void dispose() {
    _hideOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          // =====================
          // LOGO
          // =====================
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: Row(
              children: [
                Image.asset('assets/images/logo.png', height: 36),
                const SizedBox(width: 8),
                Text(
                  'SaveMed',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 32),

          // =====================
          // BUSCA
          // =====================
          Expanded(
            child: Consumer<SearchController>(
              builder: (context, search, _) {
                // controla overlay
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (search.query.isNotEmpty && search.products.isNotEmpty) {
                    _showOverlay();
                  } else {
                    _hideOverlay();
                  }
                });

                return TextField(
                  onChanged: search.search,
                  decoration: InputDecoration(
                    hintText: 'Busque um produto...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: search.query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              search.clear();
                              _hideOverlay();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(width: 16),

          // =====================
          // CARRINHO
          // =====================
          Consumer<CartController>(
            builder: (context, cart, _) {
              final count = cart.totalItems;

              return InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () {
                  _hideOverlay();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartPage()),
                  );
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.shopping_cart_outlined, size: 26),
                    ),
                    if (count > 0)
                      Positioned(
                        top: -2,
                        right: -2,
                        child: _CartBadge(count: count),
                      ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(width: 8),

          // =====================
          // PERFIL / LOGIN
          // =====================
          auth.isLogged
              ? _UserMenu(userName: auth.user!['NAME'])
              : _LoginButton(),
        ],
      ),
    );
  }
}

class _SearchOverlay extends StatelessWidget {
  const _SearchOverlay();

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchController>(
      builder: (context, search, _) {
        return Material(
          elevation: 12,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            constraints: const BoxConstraints(maxHeight: 320),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PRODUTOS',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    children: search.products.take(6).map((item) {
                      final image = item.medication.image;

                      return ListTile(
                        dense: true,
                        leading: image != null && image.isNotEmpty
                            ? Image.network(
                                image,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.medication_outlined,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                              ),
                        title: Text(item.medication.name),
                        onTap: () {
                          // TODO: abrir página do produto
                        },
                      );
                    }).toList(),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      // TODO: navegar para listagem completa
                    },
                    child: Text(
                      'VER TODOS OS PRODUTOS (${search.products.length})',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CartBadge extends StatelessWidget {
  final int count;
  const _CartBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AuthPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primary.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_outline, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'Entrar',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserMenu extends StatelessWidget {
  final String userName;
  const _UserMenu({required this.userName});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 42),
      onSelected: (value) {
        if (value == 'profile') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfilePage()),
          );
        }

        if (value == 'logout') {
          context.read<AuthController>().logout();
          context.read<CartController>().clear();

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const AuthPage()),
            (route) => false,
          );
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              Icon(Icons.person_outline, size: 18),
              SizedBox(width: 8),
              Text('Meu perfil'),
            ],
          ),
        ),
        PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, size: 18),
              SizedBox(width: 8),
              Text('Sair'),
            ],
          ),
        ),
      ],
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary.withOpacity(0.15),
            child: Text(
              userName.substring(0, 1).toUpperCase(),
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            userName.split(' ').first,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.expand_more, size: 18),
        ],
      ),
    );
  }
}
