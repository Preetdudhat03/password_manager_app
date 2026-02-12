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
                            tooltip: _obscurePassword ? 'Show Password' : 'Hide Password',
                          ),
                        ],
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                    onChanged: (_) => setState(() {}),
                  ),
                  
                  // Security Analysis Section
                  if (_passwordController.text.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _SecurityAnalysis(
                      password: _passwordController.text,
                      originalDate: widget.itemToEdit?.updatedAt,
                      otherPasswords: ref.read(vaultListProvider)
                          .where((item) => item.id != widget.itemToEdit?.id)
                          .map((e) => e.password)
                          .toList(),
                    ),
                  ],

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
  bool _excludeAmbiguous = false;

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
    const ambiguous = 'O0lI';

    String chars = lower;
    if (_useUppercase) chars += upper;
    if (_useNumbers) chars += numbers;
    if (_useSymbols) chars += symbols;

    if (_excludeAmbiguous) {
      for (var char in ambiguous.split('')) {
        chars = chars.replaceAll(char, '');
      }
    }

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

  Color _getStrengthColor() {
    if (_generated.length < 12) return Colors.red;
    if (_generated.length < 16) return Colors.orange;
    return Colors.green;
  }

  String _getStrengthText() {
    if (_generated.length < 12) return 'Weak';
    if (_generated.length < 16) return 'Good';
    return 'Strong';
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
            child: Column(
              children: [
                Text(
                  _generated,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Strength: ',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      _getStrengthText(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _getStrengthColor(),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _length,
                  min: 8,
                  max: 64,
                  divisions: 56,
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
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Exclude Ambiguous (O, 0, l, I)'),
            value: _excludeAmbiguous,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (v) {
              setState(() => _excludeAmbiguous = v ?? false);
              _generate();
            },
          ),
          const SizedBox(height: 16),
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

class _SecurityAnalysis extends StatelessWidget {
  final String password;
  final DateTime? originalDate;
  final List<String> otherPasswords;

  const _SecurityAnalysis({
    required this.password,
    required this.otherPasswords,
    this.originalDate,
  });

  bool get _isRepeated => otherPasswords.contains(password);

  bool get _isOld {
    if (originalDate == null) return false;
    final diff = DateTime.now().difference(originalDate!);
    return diff.inDays > 90;
  }

  int get _strengthScore {
    int score = 0;
    if (password.isEmpty) return 0;
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (RegExp(r'[A-Z]').hasMatch(password) && RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) score++;
    if (score > 4) score = 4;
    return score;
  }

  bool get _isWeak {
    if (password.length < 8) return true;
    // Simple heuristic: if only numbers or only letters, it's weak
    if (RegExp(r'^[0-9]+$').hasMatch(password)) return true;
    if (RegExp(r'^[a-zA-Z]+$').hasMatch(password)) return true;
    return false;
  }

  Color _getScoreColor(int score) {
    if (score <= 1) return Colors.red;
    if (score == 2) return Colors.orange;
    if (score == 3) return Colors.blue;
    return Colors.green;
  }

  String _getScoreLabel(int score) {
    if (score <= 1) return 'Weak';
    if (score == 2) return 'Fair';
    if (score == 3) return 'Good';
    return 'Strong';
  }

  @override
  Widget build(BuildContext context) {
    // Check weak based on score or heuristic
    final score = _strengthScore;
    final isWeak = _isWeak || score <= 1;
    final isOld = _isOld;
    final isRepeated = _isRepeated;

    // Calculate display score (0-4)
    // If weak by heuristic but score > 1, maybe cap it?
    // Let's stick to score mainly.
    // Actually, "Weak" label logic:
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.shieldCheck, size: 16),
              const SizedBox(width: 8),
              Text(
                'Security Check',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                _getScoreLabel(score),
                style: TextStyle(
                  color: _getScoreColor(score),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: (score == 0 && password.isNotEmpty) ? 0.1 : score / 4,
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor(score)),
              minHeight: 4,
            ),
          ),
          if (isRepeated || isWeak || isOld) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (isRepeated)
                  Chip(
                    avatar: const Icon(LucideIcons.copy, size: 14, color: Colors.white),
                    label: const Text('Repeated', style: TextStyle(fontSize: 10, color: Colors.white)),
                    backgroundColor: Colors.red,
                    visualDensity: VisualDensity.compact,
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                    labelPadding: const EdgeInsets.only(right: 4),
                  ),
                if (isWeak)
                  Chip(
                    avatar: const Icon(LucideIcons.alertCircle, size: 14, color: Colors.white),
                    label: const Text('Weak', style: TextStyle(fontSize: 10, color: Colors.white)),
                    backgroundColor: Colors.orange,
                    visualDensity: VisualDensity.compact,
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                    labelPadding: const EdgeInsets.only(right: 4),
                  ),
                if (isOld)
                  Chip(
                    avatar: const Icon(LucideIcons.clock, size: 14, color: Colors.white),
                    label: const Text('Old (>90d)', style: TextStyle(fontSize: 10, color: Colors.white)),
                    backgroundColor: Colors.amber[800],
                    visualDensity: VisualDensity.compact,
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                    labelPadding: const EdgeInsets.only(right: 4),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
