import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/vault_item.dart';
import '../state/vault_state.dart';

class AddPasswordScreen extends ConsumerStatefulWidget {
  final VaultItem? itemToEdit;

  const AddPasswordScreen({super.key, this.itemToEdit});

  @override
  ConsumerState<AddPasswordScreen> createState() => _AddPasswordScreenState();
}

class _AddPasswordScreenState extends ConsumerState<AddPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _notesController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.itemToEdit?.title ?? '');
    _usernameController = TextEditingController(text: widget.itemToEdit?.username ?? '');
    _passwordController = TextEditingController(text: widget.itemToEdit?.password ?? '');
    _notesController = TextEditingController(text: widget.itemToEdit?.notes ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _generatePassword() {
    // Simple generator for now
    // In real app, open Generator BottomSheet
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*';
    final random = DateTime.now().microsecondsSinceEpoch;
    // Just a placeholder "random" generation logic
    final generated = List.generate(16, (index) => chars[(random + index * 7) % chars.length]).join();
    _passwordController.text = generated;
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      
      try {
        if (widget.itemToEdit != null) {
          // Edit
          final updatedItem = widget.itemToEdit!.copyWith(
            title: _titleController.text,
            username: _usernameController.text,
            password: _passwordController.text,
            notes: _notesController.text,
            updatedAt: now,
          );
          await ref.read(vaultListProvider.notifier).update(updatedItem);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Password updated successfully'), backgroundColor: Colors.green),
            );
          }
        } else {
          // Add
          final newItem = VaultItem(
            id: const Uuid().v4(),
            title: _titleController.text,
            username: _usernameController.text,
            password: _passwordController.text,
            notes: _notesController.text,
            createdAt: now,
            updatedAt: now,
          );
          await ref.read(vaultListProvider.notifier).add(newItem);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Password added successfully'), backgroundColor: Colors.green),
            );
          }
        }
        if (mounted) context.pop();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving password: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  void _delete() {
    if (widget.itemToEdit != null) {
      ref.read(vaultListProvider.notifier).delete(widget.itemToEdit!.id);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.itemToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Password' : 'Add Password'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(LucideIcons.trash2, color: Colors.red),
              onPressed: _delete,
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title (e.g. Google)'),
                    validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username / Email',
                      prefixIcon: Icon(LucideIcons.user),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(LucideIcons.key),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(LucideIcons.refreshCw),
                            onPressed: _generatePassword,
                            tooltip: 'Generate',
                          ),
                          IconButton(
                            icon: Icon(_obscurePassword ? LucideIcons.eye : LucideIcons.eyeOff),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _save,
                    child: Text(isEditing ? 'Save Changes' : 'Add Password'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
