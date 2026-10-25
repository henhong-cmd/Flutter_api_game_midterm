import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../apps/Models/giveaway_model.dart';
import '../providers/giveaway_provider.dart';
import '../widgets/giveaway_image.dart';
import 'detail_screen.dart';

const _gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: 240,
  crossAxisSpacing: 10,
  mainAxisSpacing: 12,
  childAspectRatio: 0.72,
);

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(giveawayNotifierProvider);
    try {
      await ref.read(giveawayNotifierProvider.future);
    } catch (_) {
      // The error state is rendered by the screen itself.
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final giveaways = ref.watch(filteredGiveawaysProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Free Games'),
        foregroundColor: scheme.onPrimaryContainer,
        backgroundColor: scheme.primaryContainer,
      ),
      body: Column(
        children: [
          const _TypeFilterBar(),
          Expanded(
            child: giveaways.when(
              loading: () => const _SkeletonGrid(),
              error: (error, _) => _ErrorView(
                onRetry: () => ref.invalidate(giveawayNotifierProvider),
              ),
              data: (items) => RefreshIndicator(
                onRefresh: () => _refresh(ref),
                child: items.isEmpty
                    ? ListView(
                        // Keeps pull-to-refresh working on an empty list.
                        children: const [
                          SizedBox(height: 120),
                          Center(child: Text('No giveaways found.')),
                        ],
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                        gridDelegate: _gridDelegate,
                        itemCount: items.length,
                        itemBuilder: (context, index) =>
                            _GiveawayCard(giveaway: items[index]),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeFilterBar extends ConsumerWidget {
  const _TypeFilterBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final types = ref.watch(giveawayTypesProvider);
    final selected = ref.watch(typeFilterProvider);
    if (types.length <= 2) return const SizedBox.shrink();

    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: types.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final type = types[index];
          return ChoiceChip(
            label: Text(type),
            selected: selected == type,
            onSelected: (_) =>
                ref.read(typeFilterProvider.notifier).select(type),
          );
        },
      ),
    );
  }
}

class _GiveawayCard extends StatelessWidget {
  const _GiveawayCard({required this.giveaway});

  final Giveaway giveaway;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final image = GiveawayImage(
      imageUrl: giveaway.thumbnail,
      fit: BoxFit.cover,
      errorWidget: const Center(child: Icon(Icons.videogame_asset, size: 40)),
    );

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: InkWell(
        onTap: () {
          // Root navigator -> detail covers the bottom navigation bar.
          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute<void>(
              builder: (_) => DetailScreen(giveaway: giveaway),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  kIsWeb
                      ? image
                      : Hero(tag: 'giveaway-${giveaway.id}', child: image),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _WorthBadge(giveaway: giveaway),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    giveaway.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    giveaway.platforms,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    giveaway.type,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorthBadge extends StatelessWidget {
  const _WorthBadge({required this.giveaway});

  final Giveaway giveaway;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (giveaway.hasWorth) ...[
            Text(
              giveaway.worth,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                decoration: TextDecoration.lineThrough,
                decorationColor: Colors.white70,
              ),
            ),
            const SizedBox(width: 6),
          ],
          const Text(
            'FREE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonGrid extends StatelessWidget {
  const _SkeletonGrid();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
        gridDelegate: _gridDelegate,
        itemCount: 12,
        itemBuilder: (context, index) => Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: Container(color: Colors.grey.shade400)),
              const Padding(
                padding: EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text('Loading game title here'), Text('Platform')],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 48),
            const SizedBox(height: 12),
            const Text(
              'Could not load giveaways. Check your connection and try again.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
