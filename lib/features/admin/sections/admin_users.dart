part of '../admin_page.dart';

class _PharmacyUsersDialog extends StatefulWidget {
  final Map<String, dynamic> pharmacy;
  final AdminService service;
  final VoidCallback onCreateUser;
  final ValueChanged<Map<String, dynamic>> onResetUser;

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
  late Future<List<dynamic>> usersFuture;

  @override
  void initState() {
    super.initState();
    usersFuture = _loadUsers();
  }

  Future<List<dynamic>> _loadUsers() =>
      widget.service.listPharmacyUsers(widget.pharmacy['ID'] as int);

  void _reload() {
    setState(() => usersFuture = _loadUsers());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: Text(
        'Usuarios - ${_str(widget.pharmacy['NAME'], fallback: 'Farmacia')}',
      ),
      content: SizedBox(
        width: 620,
        child: FutureBuilder<List<dynamic>>(
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
                    label: const Text('Criar usuario admin'),
                  ),
                ),
                const SizedBox(height: 12),
                if (users.isEmpty)
                  const _InfoPanel(
                    icon: Icons.person_off_outlined,
                    title: 'Nenhum usuario vinculado',
                    body:
                        'Esta farmacia ainda nao possui usuarios administrativos cadastrados.',
                  )
                else
                  ...users.map(
                    (user) => _PharmacyUserTile(
                      user: user as Map<String, dynamic>,
                      onReset: () => widget.onResetUser(user),
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
