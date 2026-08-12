import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:savemed/core/auth/user_role.dart';
import 'package:savemed/core/controllers/auth_controller.dart';
import 'package:savemed/core/domain/order_status.dart';
import 'package:savemed/core/services/admin_service.dart';
import 'package:savemed/core/theme/app_colors.dart';
import 'package:savemed/core/utils/document_validator.dart';
import 'package:savemed/core/utils/field_validators.dart';
import 'package:savemed/core/utils/input_formatters.dart';
import 'package:savemed/features/auth/auth_page.dart';
import 'package:savemed/features/admin/domain/order_status_rules.dart';

part 'sections/admin_overview.dart';
part 'sections/admin_list_base.dart';
part 'sections/admin_pharmacies.dart';
part 'sections/admin_users.dart';
part 'sections/admin_categories.dart';
part 'sections/admin_medications.dart';
part 'sections/admin_inventory.dart';
part 'sections/admin_promotions.dart';
part 'sections/admin_orders.dart';
part 'sections/admin_widgets.dart';

enum _AdminSection {
  overview,
  pharmacies,
  categories,
  medications,
  inventory,
  promotions,
  orders,
}

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  _AdminSection _section = _AdminSection.overview;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.user ?? {};
    final role = auth.role;
    final pharmacyId = user['PHARMACY_ID'] as int?;
    final isAppAdmin = role == UserRole.appAdmin;
    final isPharmacyAdmin = role == UserRole.pharmacyAdmin;

    if (!isAppAdmin && !isPharmacyAdmin) {
      return const Scaffold(
        backgroundColor: _AdminColors.background,
        body: Center(child: _AdminAccessDenied()),
      );
    }

    final sections = _sectionsFor(isAppAdmin);
    if (!sections.any((item) => item.section == _section)) {
      _section = _AdminSection.overview;
    }

    return _AdminShell(
      user: user,
      sections: sections,
      selected: _section,
      onSelected: (section) => setState(() => _section = section),
      child: _AdminContent(
        section: _section,
        pharmacyId: isAppAdmin ? null : pharmacyId,
        isAppAdmin: isAppAdmin,
      ),
    );
  }
}

List<_AdminNavItem> _sectionsFor(bool isAppAdmin) {
  return [
    const _AdminNavItem(
      section: _AdminSection.overview,
      icon: Icons.dashboard_outlined,
      label: 'Visao geral',
    ),
    _AdminNavItem(
      section: _AdminSection.pharmacies,
      icon: Icons.storefront_outlined,
      label: isAppAdmin ? 'Farmacias' : 'Minha loja',
    ),
    const _AdminNavItem(
      section: _AdminSection.categories,
      icon: Icons.category_outlined,
      label: 'Categorias',
    ),
    const _AdminNavItem(
      section: _AdminSection.medications,
      icon: Icons.medication_outlined,
      label: 'Produtos',
    ),
    _AdminNavItem(
      section: _AdminSection.inventory,
      icon: Icons.inventory_2_outlined,
      label: isAppAdmin ? 'Inventario' : 'Estoque',
    ),
    const _AdminNavItem(
      section: _AdminSection.promotions,
      icon: Icons.local_offer_outlined,
      label: 'Promocoes',
    ),
    const _AdminNavItem(
      section: _AdminSection.orders,
      icon: Icons.receipt_long_outlined,
      label: 'Pedidos',
    ),
  ];
}

class _AdminNavItem {
  final _AdminSection section;
  final IconData icon;
  final String label;

  const _AdminNavItem({
    required this.section,
    required this.icon,
    required this.label,
  });
}

class _AdminColors {
  static const background = Color(0xFFF5F7F8);
  static const sidebar = Color(0xFF102924);
  static const sidebarMuted = Color(0xFF8FB5AD);
  static const line = Color(0xFFE1E7EA);
  static const muted = Color(0xFF687A80);
  static const text = Color(0xFF172B31);
}

class _AdminShell extends StatelessWidget {
  final Map<String, dynamic> user;
  final List<_AdminNavItem> sections;
  final _AdminSection selected;
  final ValueChanged<_AdminSection> onSelected;
  final Widget child;

  const _AdminShell({
    required this.user,
    required this.sections,
    required this.selected,
    required this.onSelected,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 980;
        final sidebar = _AdminSidebar(
          user: user,
          sections: sections,
          selected: selected,
          onSelected: onSelected,
          closeDrawerOnTap: !desktop,
        );

        return Scaffold(
          backgroundColor: _AdminColors.background,
          drawer: desktop ? null : Drawer(width: 280, child: sidebar),
          body: Row(
            children: [
              if (desktop) SizedBox(width: 272, child: sidebar),
              Expanded(
                child: Column(
                  children: [
                    _AdminTopBar(user: user, selected: selected),
                    Expanded(child: child),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AdminSidebar extends StatelessWidget {
  final Map<String, dynamic> user;
  final List<_AdminNavItem> sections;
  final _AdminSection selected;
  final ValueChanged<_AdminSection> onSelected;
  final bool closeDrawerOnTap;

  const _AdminSidebar({
    required this.user,
    required this.sections,
    required this.selected,
    required this.onSelected,
    required this.closeDrawerOnTap,
  });

  @override
  Widget build(BuildContext context) {
    final role = UserRole.fromApi(user['USER_ROLE']) == UserRole.appAdmin
        ? 'Admin SaveMed'
        : 'Portal da farmacia';

    return Container(
      color: _AdminColors.sidebar,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.local_pharmacy_outlined,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'SaveMed',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user['EMAIL']?.toString() ?? '',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _AdminColors.sidebarMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: sections.length,
                separatorBuilder: (_, __) => const SizedBox(height: 2),
                itemBuilder: (context, index) {
                  final item = sections[index];
                  final active = item.section == selected;
                  return _SidebarButton(
                    item: item,
                    active: active,
                    onTap: () {
                      onSelected(item.section);
                      if (closeDrawerOnTap) Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: OutlinedButton.icon(
                onPressed: () async {
                  await context.read<AuthController>().logout();
                  if (!context.mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const AuthPage()),
                    (_) => false,
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
                  minimumSize: const Size.fromHeight(42),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Sair'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarButton extends StatelessWidget {
  final _AdminNavItem item;
  final bool active;
  final VoidCallback onTap;

  const _SidebarButton({
    required this.item,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? Colors.white.withValues(alpha: 0.12) : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(
            children: [
              Icon(
                item.icon,
                size: 19,
                color: active ? Colors.white : _AdminColors.sidebarMuted,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.label,
                  style: TextStyle(
                    color: active ? Colors.white : _AdminColors.sidebarMuted,
                    fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminTopBar extends StatelessWidget {
  final Map<String, dynamic> user;
  final _AdminSection selected;

  const _AdminTopBar({required this.user, required this.selected});

  @override
  Widget build(BuildContext context) {
    final title = _titleFor(
      selected,
      UserRole.fromApi(user['USER_ROLE']) == UserRole.appAdmin,
    );

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _AdminColors.line)),
      ),
      child: Row(
        children: [
          Builder(
            builder: (context) => IconButton(
              onPressed: Scaffold.maybeOf(context)?.openDrawer,
              icon: const Icon(Icons.menu),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _AdminColors.text,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          _RolePill(role: UserRole.fromApi(user['USER_ROLE'])),
        ],
      ),
    );
  }
}

class _RolePill extends StatelessWidget {
  final UserRole role;

  const _RolePill({required this.role});

  @override
  Widget build(BuildContext context) {
    final label = role == UserRole.appAdmin ? 'Admin geral' : 'Farmacia';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primaryDark,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

String _titleFor(_AdminSection section, bool isAppAdmin) {
  return switch (section) {
    _AdminSection.overview =>
      isAppAdmin ? 'Visao geral SaveMed' : 'Visao geral da loja',
    _AdminSection.pharmacies => isAppAdmin ? 'Farmacias' : 'Minha loja',
    _AdminSection.categories => 'Categorias',
    _AdminSection.medications => 'Produtos',
    _AdminSection.inventory => isAppAdmin ? 'Inventario' : 'Estoque',
    _AdminSection.promotions => 'Promocoes',
    _AdminSection.orders => 'Pedidos',
  };
}

class _AdminContent extends StatelessWidget {
  final _AdminSection section;
  final int? pharmacyId;
  final bool isAppAdmin;

  const _AdminContent({
    required this.section,
    required this.pharmacyId,
    required this.isAppAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return switch (section) {
      _AdminSection.overview => _OverviewPage(
        pharmacyId: pharmacyId,
        isAppAdmin: isAppAdmin,
      ),
      _AdminSection.pharmacies => _PharmaciesPage(
        pharmacyId: pharmacyId,
        canCreate: isAppAdmin,
      ),
      _AdminSection.categories => _CategoriesPage(pharmacyId: pharmacyId),
      _AdminSection.medications => _MedicationsPage(pharmacyId: pharmacyId),
      _AdminSection.inventory => _InventoryPage(pharmacyId: pharmacyId),
      _AdminSection.promotions => _PromotionsPage(pharmacyId: pharmacyId),
      _AdminSection.orders => _OrdersPage(pharmacyId: pharmacyId),
    };
  }
}

class _AdminAccessDenied extends StatelessWidget {
  const _AdminAccessDenied();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 460),
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: _panelDecoration(),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_outline, size: 40, color: _AdminColors.muted),
          SizedBox(height: 14),
          Text(
            'Acesso administrativo indisponivel',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _AdminColors.text,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Esta area e restrita ao admin geral da SaveMed e aos administradores de farmacia.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _AdminColors.muted),
          ),
        ],
      ),
    );
  }
}
