import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Sello/core/constants/app_strings.dart';
import 'package:Sello/features/listings/presentation/search_results_screen.dart';
import 'package:Sello/features/listings/providers/post_listing_provider.dart';
import 'package:Sello/features/listings/providers/search_provider.dart';
import 'package:Sello/shared/models/filter_model.dart';
import 'package:Sello/shared/models/category_model.dart';

class _EmptySearchResultsNotifier extends SearchResultsNotifier {
  @override
  SearchResultsState build() =>
      const SearchResultsState(items: [], totalCount: 0);
}

class _QueryFilterNotifier extends FilterNotifier {
  @override
  FilterModel build() =>
      const FilterModel(query: 'no-match-xyz-12345');
}

void main() {
  testWidgets('shows Arabic empty-results message for no-match query',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          searchResultsProvider.overrideWith(_EmptySearchResultsNotifier.new),
          filterProvider.overrideWith(_QueryFilterNotifier.new),
          allCategoriesProvider.overrideWith(
            (ref) async => const <CategoryModel>[],
          ),
        ],
        child: const MaterialApp(home: SearchResultsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('search_empty_results_message')), findsOneWidget);
    expect(find.text(AppStrings.noResults), findsOneWidget);
    expect(find.textContaining('لم يتم العثور على نتائج'), findsOneWidget);
  });
}
