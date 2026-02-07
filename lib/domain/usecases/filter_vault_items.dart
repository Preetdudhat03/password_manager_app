import '../entities/vault_item.dart';

/// Use case for filtering vault items based on a search query.
/// 
/// WHY THIS EXISTS:
/// - To centralize the filtering logic.
/// - To ensure search is case-insensitive and handles various input types safe.
/// - To keep the UI and State layers clean of business logic.
class FilterVaultItems {
  /// Filters the list of [items] based on the [query].
  /// 
  /// Rules:
  /// - Case-insensitive
  /// - Partial matches allowed
  /// - Search matches against: Title (App/Service), Username.
  /// - Returns the full list if query is empty or whitespace.
  /// - Non-destructive (returns a new list, does not modify originals).
  List<VaultItem> call(List<VaultItem> items, String query) {
    if (query.trim().isEmpty) {
      return items;
    }

    final sanitizedQuery = query.trim().toLowerCase();
    final queryParts = sanitizedQuery.split(' ').where((part) => part.isNotEmpty).toList();

    return items.where((item) {
      final title = item.title.toLowerCase();
      final username = item.username.toLowerCase();
      final notes = (item.notes ?? '').toLowerCase();
      
      // Optimization: Create a single searchable string for the item
      // This allows "google john" to match an item with title "Google" and user "John"
      // simply by checking if all parts exist in the combined string.
      // Use a distinct separator to avoid accidental cross-field concatenation matches
      // e.g. title "bet", user "ter" matching query "better".
      final searchableContent = '$title | $username | $notes';

      // ALL parts of the query must be present in the item (AND logic)
      // This is "Search As You Type" standard behavior for finding specific items.
      for (final part in queryParts) {
        if (!searchableContent.contains(part)) {
          return false;
        }
      }
      return true;
    }).toList();
  }
}
