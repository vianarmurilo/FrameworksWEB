import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/admin_controller.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applySearch() {
    ref.read(adminSearchProvider.notifier).state = _searchController.text;
    ref.read(adminPageProvider.notifier).state = 1;
  }

  Widget _buildToolbar() {
    final sortOrder = ref.watch(adminSortOrderProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _applySearch(),
              decoration: InputDecoration(
                labelText: 'Buscar por nome ou e-mail',
                suffixIcon: IconButton(
                  onPressed: _applySearch,
                  icon: const Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('Ordenação:'),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: sortOrder,
                  items: const [
                    DropdownMenuItem(value: 'desc', child: Text('Mais novos')),
                    DropdownMenuItem(value: 'asc', child: Text('Mais antigos')),
                  ],
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    ref.read(adminSortOrderProvider.notifier).state = value;
                    ref.read(adminPageProvider.notifier).state = 1;
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(adminUsersProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(adminUsersProvider.future),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildToolbar(),
          const SizedBox(height: 12),
          users.when(
            loading: () => const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (error, _) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Falha ao carregar usuários: $error'),
              ),
            ),
            data: (pageData) {
              if (pageData.items.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nenhum usuário encontrado para os filtros atuais.',
                        ),
                        SizedBox(height: 6),
                        Text('Dica: limpe a busca ou altere a ordenação.'),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Total: ${pageData.total} usuários cadastrados',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                  ),
                  ...pageData.items.map((user) {
                    final createdAt = user.createdAt;
                    final createdAtLabel = createdAt == null
                        ? '--/--/----'
                        : '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}';

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            user.name.isNotEmpty
                                ? user.name[0].toUpperCase()
                                : '?',
                          ),
                        ),
                        title: Text(user.name),
                        subtitle: Text(
                          '${user.email}\nPerfil: ${user.role} · Moeda: ${user.currency} · Criado em: $createdAtLabel',
                        ),
                        isThreeLine: true,
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton.icon(
                        onPressed: pageData.page > 1
                            ? () {
                                ref.read(adminPageProvider.notifier).state =
                                    pageData.page - 1;
                              }
                            : null,
                        icon: const Icon(Icons.chevron_left),
                        label: const Text('Anterior'),
                      ),
                      Text('Página ${pageData.page} de ${pageData.totalPages}'),
                      OutlinedButton.icon(
                        onPressed: pageData.page < pageData.totalPages
                            ? () {
                                ref.read(adminPageProvider.notifier).state =
                                    pageData.page + 1;
                              }
                            : null,
                        icon: const Icon(Icons.chevron_right),
                        label: const Text('Próxima'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
