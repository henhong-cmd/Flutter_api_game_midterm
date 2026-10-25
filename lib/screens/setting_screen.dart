import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../apps/app_colors.dart';
import '../providers/color_notifier_provider.dart';
import '../providers/theme_notifier_provider.dart';

class SettingScreen extends ConsumerWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = ref.watch(themeNotifierProvider);
    final selectedIndex = ref.watch(colorNotifierProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        foregroundColor: scheme.onPrimaryContainer,
        backgroundColor: scheme.primaryContainer,
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.dark_mode_outlined),
              title: const Text('Night Mode'),
              trailing: Switch(
                value: dark,
                onChanged: (_) =>
                    ref.read(themeNotifierProvider.notifier).toggleDark(),
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Accent color',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: colorList.length,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 80,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemBuilder: (context, index) {
                      final color = colorList[index];
                      final isSelected = selectedIndex == index;
                      final iconColor =
                          ThemeData.estimateBrightnessForColor(color) ==
                                  Brightness.dark
                              ? Colors.white
                              : Colors.black;

                      return Semantics(
                        label: 'Theme color ${index + 1}',
                        selected: isSelected,
                        button: true,
                        child: Material(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => ref
                                .read(colorNotifierProvider.notifier)
                                .changeIndex(index),
                            child: Center(
                              child: isSelected
                                  ? Icon(Icons.check, color: iconColor)
                                  : null,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}