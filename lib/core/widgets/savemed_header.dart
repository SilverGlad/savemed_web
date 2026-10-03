import 'package:flutter/material.dart' hide SearchController;
import 'package:provider/provider.dart';

import 'package:savemed/core/controllers/auth_controller.dart';
import 'package:savemed/core/controllers/cart_controller.dart';
import 'package:savemed/core/controllers/search_controller.dart';
import 'package:savemed/core/theme/app_colors.dart';
import 'package:savemed/core/widgets/savemed_logo.dart';

import 'package:savemed/features/admin/admin_page.dart';
import 'package:savemed/features/auth/auth_page.dart';
import 'package:savemed/features/cart/cart_page.dart';
import 'package:savemed/features/product_detail/product_detail_page.dart';
import 'package:savemed/features/profile/profile_page.dart';
import 'package:savemed/models/inventory_item.dart';

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
  double _searchHeight = 320;
  final _searchText = TextEditingController();
  final _searchFocus = FocusNode();

  void _showOverlay() {
    final renderBox =
        _searchFieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    _searchFieldWidth = renderBox.size.width;
    final media = MediaQuery.of(context);
    final bottom = renderBox.localToGlobal(Offset(0, renderBox.size.height)).dy;
    _searchHeight = (media.size.height - media.viewInsets.bottom - bottom - 12)
        .clamp(0, 320);
    if (_searchHeight < 120) {
      _hideOverlay();
      return;
    }
    if (_overlay != null) {
      _overlay!.markNeedsBuild();
      return;
    }

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
                height: _searchHeight,
                child: TextFieldTapRegion(
                  child: _SearchOverlay(
                    hideOverlay: () {
                      _searchFocus.unfocus();
                      _hideOverlay();
                    },
                  ),
                ),
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
    _searchText.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 1100;
    final isCompact = width <= 430;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isMobile ? (isCompact ? 8 : 12) : 24,
        isCompact ? 8 : 12,
        isMobile ? (isCompact ? 8 : 12) : 24,
        isCompact ? 8 : 12,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          padding: EdgeInsets.fromLTRB(
            isMobile ? (isCompact ? 12 : 16) : 20,
            isCompact ? 12 : 14,
            isMobile ? (isCompact ? 12 : 16) : 20,
            isCompact ? 12 : 14,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isMobile ? 22 : 999),
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
                    SizedBox(height: isCompact ? 10 : 14),
                    _searchField(),
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
        if (Navigator.of(context).canPop())
          IconButton(
            tooltip: 'Voltar',
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back),
          ),
        Expanded(child: _brand(context)),
        const SizedBox(width: 10),
        _cartAction(context),
        const SizedBox(width: 8),
        if (auth.isLogged)
          _UserMenu(userName: auth.user!.name)
        else
          const _LoginButton(compact: true),
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
            ? _UserMenu(userName: auth.user!.name)
            : const _LoginButton(),
      ],
    );
  }

  Widget _brand(BuildContext context) {
    void goHome() => Navigator.popUntil(context, (route) => route.isFirst);
    return Semantics(
      button: true,
      label: 'Ir para a página inicial',
      onTap: goHome,
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: goHome,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (MediaQuery.sizeOf(context).width >= 360)
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.greenTint,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: const SaveMedLogoMark(width: 20, height: 34),
                ),
              ),
            if (MediaQuery.sizeOf(context).width >= 360)
              const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SaveMed',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  if (MediaQuery.sizeOf(context).width > 430)
                    Text(
                      'Sua farmácia online',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textLight.withValues(alpha: 0.9),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchField() {
    return Consumer<SearchController>(
      builder: (context, search, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (search.query.length >= 2 && _searchFocus.hasFocus) {
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
              controller: _searchText,
              focusNode: _searchFocus,
              onTap: () {
                if (search.query.length >= 2) _showOverlay();
              },
              onTapOutside: (_) {
                _searchFocus.unfocus();
                _hideOverlay();
              },
              onChanged: search.search,
              decoration: InputDecoration(
                hintText: 'Busque medicamentos, higiene e beleza',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: search.query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        tooltip: 'Limpar busca',
                        onPressed: () {
                          search.clear();
                          _searchText.clear();
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
        void openCart() {
          _hideOverlay();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CartPage()),
          );
        }

        return Semantics(
          button: true,
          onTap: openCart,
          label: count == 0
              ? 'Abrir carrinho, vazio'
              : 'Abrir carrinho, $count ${count == 1 ? 'item' : 'itens'}',
          excludeSemantics: true,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: openCart,
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
                  Positioned(
                    top: -4,
                    right: -4,
                    child: _CartBadge(count: count),
                  ),
              ],
            ),
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${search.products.length} resultados',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Fechar resultados',
                      onPressed: hideOverlay,
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: search.products.isEmpty
                      ? const Center(
                          child: Text(
                            'Nenhum produto encontrado. Tente outro nome.',
                          ),
                        )
                      : ListView(
                          children: search.products
                              .map(
                                (item) => _SearchResultTile(
                                  item: item,
                                  onSelected: () {
                                    search.clear();
                                    hideOverlay();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            ProductDetailPage(item: item),
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
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : Container(
                        width: 42,
                        height: 42,
                        color: AppColors.surfaceMuted,
                        child: const Icon(Icons.medication_outlined),
                      ),
                errorBuilder: (_, __, ___) => Container(
                  width: 42,
                  height: 42,
                  color: AppColors.surfaceMuted,
                  child: const Icon(Icons.medication_outlined),
                ),
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
    void openLogin() => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AuthPage()),
    );
    return Semantics(
      button: true,
      label: 'Entrar na conta',
      onTap: openLogin,
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: openLogin,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 14 : 18,
            vertical: compact ? 10 : 12,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.14),
            ),
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
      ),
    );
  }
}

class _UserMenu extends StatelessWidget {
  final String userName;
  const _UserMenu({required this.userName});

  @override
  Widget build(BuildContext context) {
    final canAccessAdmin = context.watch<AuthController>().isAdmin;

    return PopupMenuButton<String>(
      tooltip: 'Minha conta',
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
                Text('Administração'),
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
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                userName.isEmpty ? '?' : userName.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (MediaQuery.sizeOf(context).width >= 1100) ...[
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 120),
                child: Text(
                  userName.split(' ').first,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const Icon(Icons.expand_more, size: 18),
            ],
          ],
        ),
      ),
    );
  }
}
