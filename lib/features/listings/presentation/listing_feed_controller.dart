import 'package:asm/core/errors/app_exception.dart';
import 'package:asm/features/listings/domain/listing_filter.dart';
import 'package:asm/features/listings/domain/listing_summary.dart';
import 'package:asm/features/listings/presentation/listing_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef ListingFeedState = ({
  List<ListingSummary> items,
  int total,
  bool isLoadingMore,
});

/// Paginierter Feed. Siehe 02-IMPLEMENTATION-PLAN.md Task 3.2. Die Seitengroesse
/// ist bewusst nirgends dupliziert -- jeder Aufruf nutzt den Default aus
/// `ListingRepository.search()` (24), damit es nur eine Quelle dafuer gibt.
class ListingFeedNotifier
    extends FamilyAsyncNotifier<ListingFeedState, ListingFilter> {
  @override
  Future<ListingFeedState> build(ListingFilter arg) async {
    final result = await ref.watch(listingRepositoryProvider).search(arg);
    return (items: result.items, total: result.total, isLoadingMore: false);
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null ||
        current.isLoadingMore ||
        current.items.length >= current.total) {
      return;
    }

    state = AsyncData((
      items: current.items,
      total: current.total,
      isLoadingMore: true,
    ));
    try {
      final result = await ref
          .read(listingRepositoryProvider)
          .search(arg, offset: current.items.length);
      state = AsyncData((
        items: [...current.items, ...result.items],
        total: result.total,
        isLoadingMore: false,
      ));
    } on AppException {
      // Nachladen-Fehler wirft die bestehende Liste nicht weg -- naechster
      // Scroll-Trigger versucht loadMore() einfach erneut.
      state = AsyncData((
        items: current.items,
        total: current.total,
        isLoadingMore: false,
      ));
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(listingRepositoryProvider).search(arg);
      return (items: result.items, total: result.total, isLoadingMore: false);
    });
  }
}

final AsyncNotifierProviderFamily<
  ListingFeedNotifier,
  ListingFeedState,
  ListingFilter
>
listingFeedProvider =
    AsyncNotifierProvider.family<
      ListingFeedNotifier,
      ListingFeedState,
      ListingFilter
    >(ListingFeedNotifier.new);
