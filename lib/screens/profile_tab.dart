import 'package:flutter/material.dart';

import '../models/event.dart';
import '../models/profile.dart';
import '../utils/validators.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.profile,
    required this.events,
    required this.themeMode,
    required this.onChanged,
    required this.onThemeChanged,
  });

  final Profile profile;
  final List<Event> events;
  final ThemeMode themeMode;
  final ValueChanged<Profile> onChanged;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _nameKey = GlobalKey<FormFieldState<String>>();
  final _groupKey = GlobalKey<FormFieldState<String>>();
  final _nameFocus = FocusNode();
  final _groupFocus = FocusNode();
  late final TextEditingController _name;
  late final TextEditingController _group;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.profile.name);
    _group = TextEditingController(text: widget.profile.group);
  }

  @override
  void didUpdateWidget(covariant ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile.name != widget.profile.name) {
      _name.text = widget.profile.name;
    }
    if (oldWidget.profile.group != widget.profile.group) {
      _group.text = widget.profile.group;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _group.dispose();
    _nameFocus.dispose();
    _groupFocus.dispose();
    super.dispose();
  }

  void _saveName(String value) {
    if (!(_nameKey.currentState?.validate() ?? false)) return;
    widget.onChanged(widget.profile.copyWith(name: value.trim()));
    _groupFocus.requestFocus();
  }

  void _saveGroup(String value) {
    if (!(_groupKey.currentState?.validate() ?? false)) return;
    widget.onChanged(widget.profile.copyWith(group: value.trim()));
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final memberships = widget.events.fold<int>(
      0,
      (total, event) =>
          total + (widget.profile.name.isNotEmpty && event.contains(widget.profile.name) ? 1 : 0),
    );

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(
                  child: CircleAvatar(radius: 36, child: Icon(Icons.person_outline, size: 36)),
                ),
                const SizedBox(height: 16),
                Text(
                  'You are on $memberships lists',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Press Enter or Done to save each field. Your name identifies your registrations.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                TextFormField(
                  key: _nameKey,
                  controller: _name,
                  focusNode: _nameFocus,
                  decoration: const InputDecoration(labelText: 'Your name', border: OutlineInputBorder()),
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: Validators.requiredText,
                  onFieldSubmitted: _saveName,
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  key: _groupKey,
                  controller: _group,
                  focusNode: _groupFocus,
                  decoration: const InputDecoration(labelText: 'Group', helperText: 'For example CS-101', border: OutlineInputBorder()),
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: Validators.group,
                  onFieldSubmitted: _saveGroup,
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                ),
                const SizedBox(height: 32),
                Text('Appearance', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final mode in ThemeMode.values)
                      ChoiceChip(
                        label: Text(switch (mode) {
                          ThemeMode.system => 'System',
                          ThemeMode.light => 'Light',
                          ThemeMode.dark => 'Dark',
                        }),
                        selected: widget.themeMode == mode,
                        onSelected: (_) => widget.onThemeChanged(mode),
                      ),
                  ],
                ),
                const SizedBox(height: 28),
                Text(
                  'Everything stays in memory. Restarting the app restores the example events and clears the profile.',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
