import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../state/vault_state.dart';
import '../../domain/entities/vault_item.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isSearchExpanded = false;
  final TextEditingController _searchController = TextEditingController();

  void _toggleSearch() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
    });

    if (!_isSearchExpanded) {
      // Clear search when closing
      _searchController.clear();
      ref.read(vaultSearchQueryProvider.notifier).state = '';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allItems = ref.watch(sortedVaultListProvider);
    final filteredItems = ref.watch(filteredVaultListProvider);
    // final query = ref.watch(vaultSearchQueryProvider); // Not strictly needed to watch here if handled via controller

    return Scaffold(
      appBar: AppBar(
        // If expanded, show TextField, else show Title
        title: _isSearchExpanded
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: const InputDecoration(
                  hintText: 'Search passwords...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  ref.read(vaultSearchQueryProvider.notifier).state = value;
                },
              )
            : const Text('My Vault'),
        centerTitle: false, // Better alignment for search
        leading: _isSearchExpanded
            ? IconButton(
                icon: const Icon(LucideIcons.arrowLeft),
                onPressed: _toggleSearch,
              )
            : null, // Default back button or drawer if any
        actions: [
          if (!_isSearchExpanded)
            IconButton(
              icon: const Icon(LucideIcons.search),
              onPressed: _toggleSearch,
              tooltip: 'Search',
            ),
          
          // Hide other actions when searching to avoid clutter?
          // User requirement: "when search is done it will minimize" implies temporary mode.
          // Usually search takes over the app bar.
          if (!_isSearchExpanded) ...[
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
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: allItems.isEmpty
              ? Center( // CASE 1: TRULY EMPTY VAULT
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
              : filteredItems.isEmpty
                  ? Center( // CASE 2: NO MATCHING ENTRIES
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.searchX, size: 48, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            'No matching entries',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.grey,
                                ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder( // CASE 3: SHOW LIST
                      padding: const EdgeInsets.all(8),
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
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
