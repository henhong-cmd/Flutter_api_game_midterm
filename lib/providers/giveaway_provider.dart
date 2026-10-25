import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../apps/Models/giveaway_model.dart';
import '../apps/Servieces/giveaway_service.dart';

final giveawayServiceProvider = Provider<GiveawayService>((ref) {
  return GiveawayService();
});

/// Loads the giveaway list. Pull-to-refresh / retry call `ref.invalidate`.
class GiveawayNotifier extends AsyncNotifier<List<Giveaway>> {
  @override
  FutureOr<List<Giveaway>> build() {
    return ref.watch(giveawayServiceProvider).fetchGiveaways();
  }
}

final giveawayNotifierProvider =
    AsyncNotifierProvider<GiveawayNotifier, List<Giveaway>>(
  GiveawayNotifier.new,
  // Show errors immediately instead of silently auto-retrying (Riverpod 3).
  retry: (_, _) => null,
);

/// Selected type filter on the game screen ('All' or a giveaway type).
class TypeFilterNotifier extends Notifier<String> {
  @override
  String build() => 'All';

  void select(String value) => state = value;
}

final typeFilterProvider =
    NotifierProvider<TypeFilterNotifier, String>(TypeFilterNotifier.new);

/// Distinct types present in the loaded data, prefixed with 'All'.
final giveawayTypesProvider = Provider<List<String>>((ref) {
  final items = ref.watch(giveawayNotifierProvider).value ?? const [];
  final types = items.map((e) => e.type).where((t) => t.isNotEmpty).toSet().toList()
    ..sort();
  return ['All', ...types];
});

/// The list after applying the type filter.
final filteredGiveawaysProvider = Provider<AsyncValue<List<Giveaway>>>((ref) {
  final filter = ref.watch(typeFilterProvider);
  return ref.watch(giveawayNotifierProvider).whenData(
        (items) => filter == 'All'
            ? items
            : items.where((e) => e.type == filter).toList(),
      );
});
