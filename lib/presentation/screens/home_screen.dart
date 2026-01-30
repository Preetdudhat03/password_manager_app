import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passwordsAsync = ref.watch(passwordsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Passwords'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/add-password');
          ref.invalidate(passwordsProvider);
        },
        child: const Icon(Icons.add),
      ),
      body: passwordsAsync.when(
        data: (passwords) {
          if (passwords.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_open, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No passwords yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: passwords.length,
            itemBuilder: (context, index) {
              final entry = passwords[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      entry.title.isNotEmpty ? entry.title[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  title: Text(entry.title),
                  subtitle: Text(entry.username),
                  trailing: IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      // TODO: Copy password to clipboard (requires decryption)
                    },
                  ),
                  onTap: () {
                    // TODO: Navigate to details
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
