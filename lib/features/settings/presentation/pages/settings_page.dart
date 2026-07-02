import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentTheme = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─── Appearance Section ───
          _SectionLabel(label: 'Appearance'),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.dark_mode_rounded,
                  iconColor: colorScheme.primary,
                  iconBg: colorScheme.primaryContainer,
                  title: 'Theme',
                  subtitle: _themeName(currentTheme),
                  trailing: SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode_rounded, size: 18),
                      ),
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: Icon(Icons.brightness_auto_rounded, size: 18),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode_rounded, size: 18),
                      ),
                    ],
                    selected: {currentTheme},
                    onSelectionChanged: (modes) {
                      ref
                          .read(themeModeProvider.notifier)
                          .setThemeMode(modes.first);
                    },
                    showSelectedIcon: false,
                    style: ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ─── Data Section ───
          _SectionLabel(label: 'Data'),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.backup_rounded,
                  iconColor: colorScheme.secondary,
                  iconBg: colorScheme.secondaryContainer,
                  title: 'Backup Data',
                  subtitle: 'Export your inventory data',
                  onTap: () {},
                ),
                Divider(
                  height: 1,
                  indent: 72,
                  color: colorScheme.outlineVariant.withAlpha(80),
                ),
                _SettingsTile(
                  icon: Icons.restore_rounded,
                  iconColor: colorScheme.tertiary,
                  iconBg: colorScheme.tertiaryContainer,
                  title: 'Restore Data',
                  subtitle: 'Import from a backup file',
                  onTap: () {},
                ),
                Divider(
                  height: 1,
                  indent: 72,
                  color: colorScheme.outlineVariant.withAlpha(80),
                ),
                _SettingsTile(
                  icon: Icons.delete_forever_rounded,
                  iconColor: colorScheme.error,
                  iconBg: colorScheme.errorContainer,
                  title: 'Clear All Data',
                  subtitle: 'Permanently delete everything',
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ─── About Section ───
          _SectionLabel(label: 'About'),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.info_outline_rounded,
                  iconColor: colorScheme.onSurfaceVariant,
                  iconBg: colorScheme.surfaceContainerHighest,
                  title: 'Inventory Pro',
                  subtitle: 'Version 1.0.0',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _themeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System Default';
    }
  }
}

// ─── Helpers ────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            ?trailing,
            if (trailing == null && onTap != null)
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant.withAlpha(150),
              ),
          ],
        ),
      ),
    );
  }
}
