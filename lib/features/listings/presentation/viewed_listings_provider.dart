import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Reines In-Memory-Tracking, welche Inserate diese App-Session schon
/// gesehen hat -- keine Persistenz gewollt, `incrementView` soll pro
/// Neustart wieder zaehlen. Kein `NotifierProvider`-Codegen (Projekt-
/// Konvention seit Task 1.9, siehe listing_feed_controller.dart).
class ViewedListingsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  /// Markiert [listingId] als gesehen. Liefert `true`, wenn es das erste Mal
  /// in dieser Session ist (== der Aufrufer soll `incrementView` ausloesen),
  /// sonst `false`.
  bool markViewed(String listingId) {
    if (state.contains(listingId)) return false;
    state = {...state, listingId};
    return true;
  }
}

final viewedListingsProvider =
    NotifierProvider<ViewedListingsNotifier, Set<String>>(
      ViewedListingsNotifier.new,
    );
