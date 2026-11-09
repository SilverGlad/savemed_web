import 'package:flutter/material.dart';

import '../../core/api/api_error_message.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/services/inventory_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/catalog_layout.dart';
import '../../core/widgets/inventory_card.dart';
import '../../core/widgets/savemed_footer.dart';
import '../../core/widgets/savemed_header.dart';
import '../../models/inventory_item.dart';
import '../../models/pharmacy.dart';

class PharmacyPage extends StatefulWidget {
  static const routeName = AppRoutes.pharmacy;

  final Pharmacy pharmacy;
  final InventoryService? inventoryService;

  const PharmacyPage({
    super.key,
    required this.pharmacy,
    this.inventoryService,
  });

  @override
  State<PharmacyPage> createState() => _PharmacyPageState();
}

class _PharmacyPageState extends State<PharmacyPage> {
  late final InventoryService _inventoryService =
      widget.inventoryService ?? InventoryService();
  final _searchController = TextEditingController();
  List<InventoryItem> _items = [];
  bool _loading = true;
  String? _error;

  List<InventoryItem> get _visibleItems {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _items;
    return _items
        .where((item) {
          final searchable = [
            item.medication.name,
            item.medication.description,
            item.medication.brand ?? '',
            ...item.medication.activeIngredients.map(
              (ingredient) => ingredient.name,
            ),
          ].join(' ').toLowerCase();
          return searchable.contains(query);
        })
        .toList(growable: false);
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load({bool retry = false}) async {
    if (retry) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final items = await _inventoryService.getInventoryForPharmacy(
        widget.pharmacy,
      );
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = ApiErrorMessage.forUser(
          error,
          fallback: 'Não foi possível carregar os produtos desta farmácia.',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = width <= 600 ? 12.0 : 24.0;
    final items = _visibleItems;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          SaveMedHeader(),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      16,
                      horizontalPadding,
                      12,
                    ),
                    child: _pharmacySummary(context),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      0,
                      horizontalPadding,
                      16,
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Buscar produtos nesta farmácia',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Limpar busca',
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                                icon: const Icon(Icons.close),
                              ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                ),
                if (_loading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_error != null)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _loadError(context),
                  )
                else if (items.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          _searchController.text.isEmpty
                              ? 'Esta farmácia ainda não tem produtos para exibir.'
                              : 'Nenhum produto encontrado nesta farmácia.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (_, index) => InventoryCard(item: items[index]),
                        childCount: items.length,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: CatalogLayout.columns(
                          context,
                          width - horizontalPadding * 2,
                        ),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        mainAxisExtent: CatalogLayout.cardHeight(context),
                      ),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      24,
                      horizontalPadding,
                      24,
                    ),
                    child: const SaveMedFooter(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pharmacySummary(BuildContext context) {
    final pharmacy = widget.pharmacy;
    final statusColor = pharmacy.isOpen
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.error;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _pharmacyImage(pharmacy),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pharmacy.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Semantics(
                      label: pharmacy.isOpen
                          ? 'Farmácia aberta para pedidos'
                          : 'Farmácia temporariamente fechada',
                      child: ExcludeSemantics(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              pharmacy.isOpen
                                  ? Icons.check_circle
                                  : Icons.pause_circle,
                              color: statusColor,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                pharmacy.isOpen
                                    ? 'Aberta para pedidos'
                                    : 'Temporariamente fechada',
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (pharmacy.addressLine.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(pharmacy.addressLine),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (pharmacy.acceptsPickup)
                const Chip(
                  avatar: Icon(Icons.store_mall_directory_outlined, size: 18),
                  label: Text('Retirada no local'),
                ),
              if (pharmacy.acceptsOwnDelivery)
                const Chip(
                  avatar: Icon(Icons.delivery_dining_outlined, size: 18),
                  label: Text('Entrega da farmácia'),
                ),
              if (pharmacy.preparationMinutes != null)
                Chip(
                  avatar: const Icon(Icons.schedule_outlined, size: 18),
                  label: Text(
                    'Preparo informado: ${pharmacy.preparationMinutes} min',
                  ),
                ),
            ],
          ),
          if (!pharmacy.isOpen) ...[
            const SizedBox(height: 4),
            Text(
              'Não é possível adicionar produtos desta farmácia ao carrinho enquanto ela estiver fechada.',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
    );
  }

  Widget _pharmacyImage(Pharmacy pharmacy) {
    const size = 64.0;
    final imageUrl = pharmacy.image?.trim();
    return Semantics(
      label: 'Imagem da farmácia ${pharmacy.name}',
      image: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox.square(
          dimension: size,
          child: imageUrl == null || imageUrl.isEmpty
              ? const ColoredBox(
                  color: AppColors.surfaceMuted,
                  child: Icon(Icons.storefront_outlined, size: 32),
                )
              : Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const ColoredBox(
                    color: AppColors.surfaceMuted,
                    child: Icon(Icons.storefront_outlined, size: 32),
                  ),
                  loadingBuilder: (context, child, progress) => progress == null
                      ? child
                      : const ColoredBox(
                          color: AppColors.surfaceMuted,
                          child: Center(
                            child: SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                ),
        ),
      ),
    );
  }

  Widget _loadError(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 36,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 12),
          Semantics(
            liveRegion: true,
            child: Text(_error!, textAlign: TextAlign.center),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _loading ? null : () => _load(retry: true),
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}
