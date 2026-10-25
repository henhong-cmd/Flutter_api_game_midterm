import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../apps/Models/giveaway_model.dart';
import '../widgets/giveaway_image.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.giveaway});

  final Giveaway giveaway;

  void _showGetGameGuide(BuildContext context) {
    final parsedUrl = Uri.tryParse(giveaway.openGiveawayUrl);
    final claimUrl =
        parsedUrl != null &&
            (parsedUrl.scheme == 'https' || parsedUrl.scheme == 'http') &&
            parsedUrl.host.isNotEmpty
        ? parsedUrl.toString()
        : null;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20 + MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How to get ${giveaway.title}',
                  style: Theme.of(sheetContext).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  giveaway.instructions.trim().isEmpty
                      ? 'No claiming instructions are available for this giveaway.'
                      : giveaway.instructions,
                ),
                if (giveaway.platforms.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text('Platform: ${giveaway.platforms}'),
                ],
                const SizedBox(height: 12),
                Text(
                  'Continue to the giveaway website to claim this game.',
                  style: Theme.of(sheetContext).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: claimUrl == null
                        ? null
                        : () async {
                            Navigator.of(sheetContext).pop();
                            try {
                              final opened = await launchUrl(
                                Uri.parse(claimUrl),
                                mode: LaunchMode.externalApplication,
                              );
                              if (!opened && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Could not open the giveaway website.',
                                    ),
                                  ),
                                );
                              }
                            } on Exception {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Could not open the giveaway website.',
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                    icon: const Icon(Icons.open_in_new),
                    label: Text(
                      claimUrl == null
                          ? 'Claim link unavailable'
                          : 'Open claim website',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final image = ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: GiveawayImage(
        imageUrl: giveaway.image.isNotEmpty
            ? giveaway.image
            : giveaway.thumbnail,
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: const Center(child: CircularProgressIndicator()),
        errorWidget: const Center(child: Icon(Icons.broken_image, size: 48)),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          giveaway.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        foregroundColor: scheme.onPrimaryContainer,
        backgroundColor: scheme.primaryContainer,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _showGetGameGuide(context),
              icon: const Icon(Icons.card_giftcard),
              label: const Text('Get game'),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          kIsWeb ? image : Hero(tag: 'giveaway-${giveaway.id}', child: image),
          const SizedBox(height: 12),
          Text(giveaway.title, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              if (giveaway.type.isNotEmpty)
                Chip(
                  avatar: const Icon(Icons.category_outlined, size: 18),
                  label: Text(giveaway.type),
                ),
              if (giveaway.hasWorth)
                Chip(
                  avatar: const Icon(Icons.sell_outlined, size: 18),
                  label: Text('Worth ${giveaway.worth}'),
                ),
              Chip(
                avatar: const Icon(Icons.people_outline, size: 18),
                label: Text('${giveaway.users} claimed'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _InfoCard(
            children: [
              _InfoRow(
                icon: Icons.devices,
                label: 'Platforms',
                value: giveaway.platforms.isEmpty ? '-' : giveaway.platforms,
              ),
              _InfoRow(
                icon: Icons.event_busy,
                label: 'Ends',
                value: giveaway.hasEndDate ? giveaway.endDate : 'No end date',
              ),
              _InfoRow(
                icon: Icons.event_available,
                label: 'Published',
                value: giveaway.publishedDate.isEmpty
                    ? '-'
                    : giveaway.publishedDate,
              ),
            ],
          ),
          _TextCard(title: 'Description', body: giveaway.description),
          _TextCard(title: 'How to claim', body: giveaway.instructions),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: children),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          SizedBox(
            width: 84,
            child: Text(label, style: Theme.of(context).textTheme.labelLarge),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _TextCard extends StatelessWidget {
  const _TextCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    if (body.trim().isEmpty) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(body),
          ],
        ),
      ),
    );
  }
}
