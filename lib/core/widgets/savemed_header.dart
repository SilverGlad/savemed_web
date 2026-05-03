import 'package:flutter/material.dart' hide SearchController;
import 'package:provider/provider.dart';

import 'package:SaveMed/core/controllers/auth_controller.dart';
import 'package:SaveMed/core/controllers/cart_controller.dart';
import 'package:SaveMed/core/controllers/search_controller.dart';
import 'package:SaveMed/core/theme/app_colors.dart';

import 'package:SaveMed/features/admin/admin_page.dart';
import 'package:SaveMed/features/auth/auth_page.dart';
import 'package:SaveMed/features/cart/cart_page.dart';
import 'package:SaveMed/features/product_detail/product_detail_page.dart';
import 'package:SaveMed/features/profile/profile_page.dart';
import 'package:SaveMed/models/inventory_item.dart';

const double _shellMaxWidth = 1180;

class SaveMedHeader extends StatefulWidget {
  const SaveMedHeader({super.key});

  @override
  State<SaveMedHeader> createState() => _SaveMedHeaderState();
}

class _SaveMedHeaderState extends State<SaveMedHeader> {
  final LayerLink _searchLayerLink = LayerLink();
  final GlobalKey _searchFieldKey = GlobalKey();
  OverlayEntry? _overlay;
  double _searchFieldWidth = 0;

  void _showOverlay() {
    if (_overlay != null) return;

    final renderBox =
        _searchFieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    _searchFieldWidth = renderBox.size.width;

    _overlay = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: IgnorePointer(
          ignoring: false,
          child: CompositedTransformFollower(
            link: _searchLayerLink,
            showWhenUnlinked: false,
            offset: Offset(0, renderBox.size.height + 8),
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: _searchFieldWidth,
                child: _SearchOverlay(hideOverlay: _hideOverlay),
              ),
            ),
          ),
        ),
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
    final isMobile = MediaQuery.of(context).size.width <= 760;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 12 : 64,
        12,
        isMobile ? 12 : 64,
        12,
      ),
      child: Center(
        child: Container(
          padding: EdgeInsets.fromLTRB(
            isMobile ? 16 : 64,
            14,
            isMobile ? 16 : 64,
            14,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _topRow(context, auth),
                    const SizedBox(height: 14),
                    _searchField(),
                    const SizedBox(height: 12),
                    _mobileActions(context, auth),
                  ],
                )
              : Row(
                  children: [
                    _brand(context),
                    const SizedBox(width: 24),
                    Expanded(child: _searchField()),
                    const SizedBox(width: 16),
                    _desktopActions(context, auth),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _topRow(BuildContext context, AuthController auth) {
    return Row(
      children: [
        Expanded(child: _brand(context)),
        const SizedBox(width: 10),
        _cartAction(context),
      ],
    );
  }

  Widget _desktopActions(BuildContext context, AuthController auth) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _cartAction(context),
        const SizedBox(width: 12),
        auth.isLogged
            ? _UserMenu(userName: auth.user!['NAME'])
            : const _LoginButton(),
      ],
    );
  }

  Widget _mobileActions(BuildContext context, AuthController auth) {
    return Row(
      children: [
        Expanded(
          child: Text(
            auth.isLogged
                ? 'Ola, ${auth.user!['NAME'].toString().split(' ').first}'
                : 'Acesse sua conta para continuar',
            style: const TextStyle(
              color: AppColors.textLight,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        auth.isLogged
            ? _UserMenu(userName: auth.user!['NAME'])
            : const _LoginButton(compact: true),
      ],
    );
  }

  Widget _brand(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.popUntil(context, (route) => route.isFirst);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Image.asset('assets/images/logo.png'),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SaveMed',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                'cuidado rapido e bonito',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textLight.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _searchField() {
    return Consumer<SearchController>(
      builder: (context, search, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (search.query.isNotEmpty && search.products.isNotEmpty) {
            _showOverlay();
          } else {
            _hideOverlay();
          }
        });

        return CompositedTransformTarget(
          link: _searchLayerLink,
          child: Container(
            key: _searchFieldKey,
            child: TextField(
              onChanged: search.search,
              decoration: InputDecoration(
                hintText: 'Busque medicamentos, higiene e beleza',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: search.query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          search.clear();
                          _hideOverlay();
                        },
                      )
                    : null,
                fillColor: AppColors.background,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _cartAction(BuildContext context) {
    return Consumer<CartController>(
      builder: (context, cart, _) {
        final count = cart.totalItems;

        return InkWell(
          borderRadius: BorderRadius.circular(20),
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.shopping_bag_outlined, size: 22),
              ),
              if (count > 0)
                Positioned(top: -4, right: -4, child: _CartBadge(count: count)),
            ],
          ),
        );
      },
    );
  }
}

class _SearchOverlay extends StatelessWidget {
  final VoidCallback hideOverlay;

  const _SearchOverlay({required this.hideOverlay});

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchController>(
      builder: (context, search, _) {
        return Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryDark.withValues(alpha: 0.1),
                  blurRadius: 22,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            constraints: const BoxConstraints(maxHeight: 320),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resultados rapidos',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    children: search.products
                        .take(6)
                        .map(
                          (item) => _SearchResultTile(
                            item: item,
                            onSelected: () {
                              search.clear();
                              hideOverlay();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductDetailPage(item: item),
                                ),
                              );
                            },
                          ),
                        )
                        .toList(),
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

class _SearchResultTile extends StatelessWidget {
  final InventoryItem item;
  final VoidCallback onSelected;

  const _SearchResultTile({required this.item, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final image = item.medication.image;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: image != null && image.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                image,
                width: 42,
                height: 42,
                fit: BoxFit.cover,
              ),
            )
          : Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.medication_outlined),
            ),
      title: Text(
        item.medication.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        'R\$ ${item.price.toStringAsFixed(2).replaceAll('.', ',')}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: onSelected,
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
        color: AppColors.danger,
        borderRadius: BorderRadius.circular(999),
      ),
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  final bool compact;

  const _LoginButton({this.compact = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AuthPage()),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 14 : 18,
          vertical: compact ? 10 : 12,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.14)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_outline, size: 18, color: AppColors.primary),
            if (!compact) ...[
              const SizedBox(width: 8),
              const Text(
                'Entrar',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
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
    final role = context.watch<AuthController>().user?['USER_ROLE'];
    final canAccessAdmin = role == 'app_admin' || role == 'pharmacy_admin';

    return PopupMenuButton<String>(
      offset: const Offset(0, 42),
      onSelected: (value) {
        if (value == 'admin') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminPage()),
          );
        }

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
      itemBuilder: (context) => [
        if (canAccessAdmin)
          const PopupMenuItem(
            value: 'admin',
            child: Row(
              children: [
                Icon(Icons.admin_panel_settings_outlined, size: 18),
                SizedBox(width: 8),
                Text('Administracao'),
              ],
            ),
          ),
        const PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              Icon(Icons.person_outline, size: 18),
              SizedBox(width: 8),
              Text('Meu perfil'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 15,
              backgroundColor: AppColors.primary.withValues(alpha: 0.16),
              child: Text(
                userName.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              userName.split(' ').first,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.expand_more, size: 18),
          ],
        ),
      ),
    );
  }
}
