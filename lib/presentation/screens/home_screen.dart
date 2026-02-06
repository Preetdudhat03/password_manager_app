import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../state/vault_state.dart';
import '../../domain/entities/vault_item.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vaultItems = ref.watch(sortedVaultListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Vault'),
        actions: [
          PopupMenuButton<SortType>(
            icon: const Icon(LucideIcons.arrowUpDown),
            tooltip: 'Sort By',
            onSelected: (SortType result) {
              ref.read(sortProvider.notifier).state = result;
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<SortType>>[
              const PopupMenuItem<SortType>(
                value: SortType.dateNewest,
                child: Row(
                  children: [
                    Icon(LucideIcons.calendar, size: 18),
                    SizedBox(width: 8),
                    Text('Newest First'),
                  ],
                ),
              ),
              const PopupMenuItem<SortType>(
                value: SortType.dateOldest,
                child: Row(
                  children: [
                    Icon(LucideIcons.calendarClock, size: 18),
                    SizedBox(width: 8),
                    Text('Oldest First'),
                  ],
                ),
              ),
              const PopupMenuItem<SortType>(
                value: SortType.alphaAZ,
                child: Row(
                  children: [
                    Icon(LucideIcons.arrowDown, size: 18),
                    SizedBox(width: 8),
                    Text('A-Z'),
                  ],
                ),
              ),
              const PopupMenuItem<SortType>(
                value: SortType.alphaZA,
                child: Row(
                  children: [
                    Icon(LucideIcons.arrowUp, size: 18),
                    SizedBox(width: 8),
                    Text('Z-A'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(LucideIcons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: vaultItems.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.shieldCheck, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'Your vault is empty',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey,
                              ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: vaultItems.length,
                  itemBuilder: (context, index) {
                    final item = vaultItems[index];
                    return _VaultItemCard(item: item);
                  },
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add_password'),
        child: const Icon(LucideIcons.plus),
      ),
    );
  }
}

class _VaultItemCard extends StatelessWidget {
  final VaultItem item;

  const _VaultItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          child: Text(
            item.title.isNotEmpty ? item.title[0].toUpperCase() : '?',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(item.title),
        subtitle: Text(item.username),
        onTap: () {
          context.push('/edit_password', extra: item);
        },
      ),
    );
  }
}
