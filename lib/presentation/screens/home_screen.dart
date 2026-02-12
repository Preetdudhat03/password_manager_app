import 'package:flutter/material.dart';
import 'dart:ui';
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

class _VaultItemCard extends StatefulWidget {
  final VaultItem item;

  const _VaultItemCard({required this.item});

  @override
  State<_VaultItemCard> createState() => _VaultItemCardState();
}

class _VaultItemCardState extends State<_VaultItemCard> {
  OverlayEntry? _overlayEntry;

  void _showOverlay(BuildContext context) {
    _removeOverlay();

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final mQuery = MediaQuery.of(context);
    final screenHeight = mQuery.size.height;
    final screenWidth = mQuery.size.width;

    // Smart Positioning:
    // If item is in bottom half of screen, show card ABOVE it.
    // If item is in top half, show card BELOW it.
    final isBottomHalf = offset.dy > (screenHeight / 2);
    
    // Gap between finger/item and the card
    const double verticalGap = 24.0;
    const double horizontalMargin = 24.0;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Blurred Backdrop
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                color: Colors.black.withOpacity(0.6), // Darker dim for focus
              ),
            ),
          ),
          
          // Preview Card
          Positioned(
            left: horizontalMargin,
            width: screenWidth - (horizontalMargin * 2),
            // Position above or below based on screen location
            top: isBottomHalf ? null : (offset.dy + size.height + verticalGap),
            bottom: isBottomHalf ? (screenHeight - offset.dy + verticalGap) : null,
            
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.tertiary,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              widget.item.title.isNotEmpty ? widget.item.title[0].toUpperCase() : '?',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.item.title,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.item.username,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    const Divider(height: 1),
                    const SizedBox(height: 24),

                    // Password Section
                    Text(
                      'PASSWORD',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5), 
                        ),
                      ),
                      child: SelectableText( // Allow copying if they want, though long press might conflict
                        widget.item.password,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    // Notes Section (Conditional)
                    if (widget.item.notes?.isNotEmpty == true) ...[
                      const SizedBox(height: 24),
                      Text(
                        'NOTES',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.item.notes!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (details) {
        _showOverlay(context);
        // Add Haptic feedback if possible, but keeping it simple for now
      },
      onLongPressEnd: (details) => _removeOverlay(),
      onLongPressCancel: () => _removeOverlay(),
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            child: Text(
              widget.item.title.isNotEmpty ? widget.item.title[0].toUpperCase() : '?',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(widget.item.title),
          subtitle: Text(widget.item.username),
          onTap: () {
            context.push('/edit_password', extra: widget.item);
          },
        ),
      ),
    );
  }
}
