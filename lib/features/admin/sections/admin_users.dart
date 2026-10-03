part of '../admin_page.dart';

class _PharmacyUsersDialog extends StatefulWidget {
  final Pharmacy pharmacy;
  final AdminService service;
  final VoidCallback onCreateUser;
  final ValueChanged<AppUser> onResetUser;

  const _PharmacyUsersDialog({
    required this.pharmacy,
    required this.service,
    required this.onCreateUser,
    required this.onResetUser,
  });

  @override
  State<_PharmacyUsersDialog> createState() => _PharmacyUsersDialogState();
}

class _PharmacyUsersDialogState extends State<_PharmacyUsersDialog> {
  late Future<List<AppUser>> usersFuture;

  @override
  void initState() {
    super.initState();
    usersFuture = _loadUsers();
  }

  Future<List<AppUser>> _loadUsers() =>
      widget.service.listPharmacyUsers(widget.pharmacy.id);

  void _reload() {
    setState(() => usersFuture = _loadUsers());
  }

  Future<void> _toggleStatus(AppUser user) async {
    final isActive = user.isActive;
    final nextActive = !isActive;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(nextActive ? 'Ativar usuário?' : 'Inativar usuário?'),
        content: Text(
          nextActive
              ? '${user.name} poderá acessar novamente o painel da farmácia.'
              : '${user.name} perderá o acesso ao painel imediatamente. Pedidos e histórico serão preservados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(nextActive ? 'Ativar' : 'Inativar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await widget.service.updateUserStatus(user.id, isActive: nextActive);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            nextActive
                ? 'Usuário ativado com sucesso.'
                : 'Usuário inativado com sucesso.',
          ),
        ),
      );
      _reload();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_cleanError(error))));
    }
  }

  Future<void> _resendInvitation(AppUser user) async {
    try {
      await widget.service.resendUserInvitation(user.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Convite reenviado com sucesso.')),
      );
      _reload();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_cleanError(error))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: Text('Usuários - ${widget.pharmacy.name}'),
      content: SizedBox(
        width: 620,
        child: FutureBuilder<List<AppUser>>(
          future: usersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return _InlineError(message: _cleanError(snapshot.error!));
            }
            final users = snapshot.data ?? const [];
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onCreateUser();
                    },
                    icon: const Icon(Icons.person_add_alt_outlined, size: 18),
                    label: const Text('Convidar usuário'),
                  ),
                ),
                const SizedBox(height: 12),
                if (users.isEmpty)
                  const _InfoPanel(
                    icon: Icons.person_off_outlined,
                    title: 'Nenhum usuário vinculado',
                    body:
                        'Esta farmácia ainda não possui usuários administrativos cadastrados.',
                  )
                else
                  ...users.map(
                    (user) => _PharmacyUserTile(
                      user: user,
                      onReset: () => widget.onResetUser(user),
                      onResendInvitation: () => _resendInvitation(user),
                      onToggleStatus: () => _toggleStatus(user),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(onPressed: _reload, child: const Text('Atualizar')),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fechar'),
        ),
      ],
    );
  }
}
