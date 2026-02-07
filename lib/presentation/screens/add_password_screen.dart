import 'package:flutter/material.dart';
import 'dart:math';
import 'package:lucide_icons/lucide_icons.dart';
import '../widgets/smart_copy_actions.dart';
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

  void _showGeneratorSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return _PasswordGeneratorSheet(
          onSelect: (password) {
            _passwordController.text = password;
            // Also update the obscure state to visible so they can see what they picked?
            // User requirement didn't specify, but it's good UX.
            // keeping it obscured is safer though.
          },
        );
      },
    );
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
                  
                  // SMART COPY ACTIONS (Only when viewing/editing existing item)
                  if (isEditing) ...[
                    SmartCopyActions(
                      username: _usernameController.text,
                      password: _passwordController.text,
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),
                  ],
                  
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
                            onPressed: _showGeneratorSheet,
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

class _PasswordGeneratorSheet extends StatefulWidget {
  final ValueChanged<String> onSelect;
  const _PasswordGeneratorSheet({required this.onSelect});

  @override
  State<_PasswordGeneratorSheet> createState() => _PasswordGeneratorSheetState();
}

class _PasswordGeneratorSheetState extends State<_PasswordGeneratorSheet> {
  String _generated = '';
  double _length = 16;
  bool _useSymbols = true;
  bool _useNumbers = true;
  bool _useUppercase = true;

  @override
  void initState() {
    super.initState();
    _generate();
  }

  void _generate() {
    const lower = 'abcdefghijklmnopqrstuvwxyz';
    const upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const numbers = '0123456789';
    const symbols = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

    String chars = lower;
    if (_useUppercase) chars += upper;
    if (_useNumbers) chars += numbers;
    if (_useSymbols) chars += symbols;

    // Fallback if nothing selected
    if (chars.isEmpty) chars = lower;

    final random = Random.secure();
    setState(() {
      _generated = List.generate(
        _length.toInt(), 
        (index) => chars[random.nextInt(chars.length)],
      ).join();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Generate Password',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: Text(
              _generated,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _length,
                  min: 8,
                  max: 32,
                  divisions: 24,
                  label: _length.round().toString(),
                  onChanged: (v) {
                    setState(() => _length = v);
                    _generate();
                  },
                ),
              ),
              Text('${_length.toInt()} chars'),
            ],
          ),
          const SizedBox(height: 16),
           Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FilterChip(
                label: const Text('ABC'), 
                selected: _useUppercase, 
                onSelected: (v) { setState(() => _useUppercase = v); _generate(); }
              ),
              FilterChip(
                label: const Text('123'), 
                selected: _useNumbers, 
                onSelected: (v) { setState(() => _useNumbers = v); _generate(); }
              ),
              FilterChip(
                label: const Text('#@!'), 
                selected: _useSymbols, 
                onSelected: (v) { setState(() => _useSymbols = v); _generate(); }
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _generate,
                  icon: const Icon(LucideIcons.refreshCw),
                  label: const Text('Regenerate'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    widget.onSelect(_generated);
                    Navigator.pop(context);
                  },
                  icon: const Icon(LucideIcons.check),
                  label: const Text('Use Password'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
