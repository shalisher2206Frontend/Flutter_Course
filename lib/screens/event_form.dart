import 'package:flutter/material.dart';

import '../models/category.dart';
import '../models/event.dart';
import '../utils/confirm.dart';
import '../utils/format.dart';
import '../utils/validators.dart';

typedef _FormValues = ({
  String title,
  String location,
  String limit,
  String description,
  EventCategory? category,
  bool online,
  DateTime when,
});

class EventForm extends StatefulWidget {
  const EventForm({super.key, this.event});
  final Event? event;

  @override
  State<EventForm> createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleFocus = FocusNode();
  final _locationFocus = FocusNode();
  final _limitFocus = FocusNode();
  final _dateFocus = FocusNode();
  final _timeFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  late final TextEditingController _title;
  late final TextEditingController _location;
  late final TextEditingController _limit;
  late final TextEditingController _description;
  late final TextEditingController _date;
  late final TextEditingController _time;
  late final Event _original;
  late EventCategory? _category;
  late bool _online;
  late DateTime _when;
  late _FormValues _baseline;
  bool _saving = false;
  bool _asking = false;

  @override
  void initState() {
    super.initState();
    _original = widget.event ?? Event.empty();
    _title = TextEditingController(text: _original.title);
    _location = TextEditingController(text: _original.location);
    _limit = TextEditingController(text: _original.limit.toString());
    _description = TextEditingController(text: _original.description ?? '');
    _date = TextEditingController();
    _time = TextEditingController();
    _category = _original.category;
    _online = _original.online;
    _when = _original.when;
    _updatePickerText();
    _baseline = _values;
  }

  _FormValues get _values => (
    title: _title.text,
    location: _location.text,
    limit: _limit.text,
    description: _description.text,
    category: _category,
    online: _online,
    when: _when,
  );

  bool get _dirty => _values != _baseline;

  void _updatePickerText() {
    _date.text = '${formatDate(_when)} ${_when.year}';
    _time.text = formatTime(_when);
  }

  @override
  void dispose() {
    for (final controller in [_title, _location, _limit, _description, _date, _time]) {
      controller.dispose();
    }
    for (final node in [
      _titleFocus, _locationFocus, _limitFocus,
      _dateFocus, _timeFocus, _descriptionFocus,
    ]) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _when,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5, 12, 31),
    );
    if (!mounted || picked == null) return;
    setState(() {
      _when = DateTime(picked.year, picked.month, picked.day, _when.hour, _when.minute);
      _updatePickerText();
    });
    _timeFocus.requestFocus();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_when),
    );
    if (!mounted || picked == null) return;
    setState(() {
      _when = DateTime(_when.year, _when.month, _when.day, picked.hour, picked.minute);
      _updatePickerText();
    });
    _descriptionFocus.requestFocus();
  }

  Future<void> _save() async {
    if (_saving || !(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    final description = _description.text.trim();
    final saved = _original.copyWith(
      title: _title.text.trim(),
      category: _category,
      location: _location.text.trim(),
      limit: int.parse(_limit.text.trim()),
      when: _when,
      online: _online,
      description: description,
      clearDescription: description.isEmpty,
    );
    // Update PopScope before popping, so Save never asks about discarding.
    setState(() => _baseline = _values);
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    Navigator.of(context).pop(saved);
  }

  Future<void> _onPop(bool didPop, Event? result) async {
    if (didPop || _saving || _asking) return;
    _asking = true;
    final discard = await confirm(
      context,
      title: 'Discard changes?',
      message: 'Your changes have not been saved.',
      action: 'Discard',
    );
    if (!mounted) return;
    _asking = false;
    if (!discard) return;
    setState(() => _baseline = _values);
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _dismissKeyboard(PointerDownEvent event) =>
      FocusScope.of(context).unfocus();

  @override
  Widget build(BuildContext context) => PopScope<Event>(
    canPop: !_dirty,
    onPopInvokedWithResult: _onPop,
    child: Scaffold(
      appBar: AppBar(title: Text(widget.event == null ? 'New event' : 'Edit event')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                // Controllers hold the changes; rebuild the PopScope comparison.
                onChanged: () => setState(() {}),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _title,
                      focusNode: _titleFocus,
                      enabled: !_saving,
                      decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                      maxLength: 60,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _locationFocus.requestFocus(),
                      onTapOutside: _dismissKeyboard,
                      validator: Validators.title,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<EventCategory>(
                      initialValue: _category,
                      decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                      items: EventCategory.values.map((category) =>
                        DropdownMenuItem(value: category, child: Text(category.label)),
                      ).toList(),
                      onChanged: _saving ? null : (value) => setState(() => _category = value),
                      validator: (value) => value == null ? 'Choose a category.' : null,
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Online event'),
                      subtitle: const Text('Use a meeting link instead of a room.'),
                      value: _online,
                      onChanged: _saving ? null : (value) => setState(() => _online = value),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _location,
                      focusNode: _locationFocus,
                      enabled: !_saving,
                      decoration: InputDecoration(labelText: _online ? 'Meeting link' : 'Location', border: const OutlineInputBorder()),
                      keyboardType: _online ? TextInputType.url : TextInputType.streetAddress,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _limitFocus.requestFocus(),
                      onTapOutside: _dismissKeyboard,
                      validator: (value) => Validators.location(value, online: _online),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _limit,
                      focusNode: _limitFocus,
                      enabled: !_saving,
                      decoration: const InputDecoration(labelText: 'Maximum people', helperText: '1 to 500', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _dateFocus.requestFocus(),
                      onTapOutside: _dismissKeyboard,
                      validator: (value) => Validators.limit(value, taken: _original.count),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _date,
                            focusNode: _dateFocus,
                            enabled: !_saving,
                            readOnly: true,
                            decoration: const InputDecoration(labelText: 'Date', suffixIcon: Icon(Icons.calendar_today_outlined), border: OutlineInputBorder()),
                            keyboardType: TextInputType.datetime,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => _timeFocus.requestFocus(),
                            onTap: _pickDate,
                            onTapOutside: _dismissKeyboard,
                            validator: (value) => Validators.date(value, when: _when, isNew: widget.event == null),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _time,
                            focusNode: _timeFocus,
                            enabled: !_saving,
                            readOnly: true,
                            decoration: const InputDecoration(labelText: 'Time', suffixIcon: Icon(Icons.access_time), border: OutlineInputBorder()),
                            keyboardType: TextInputType.datetime,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => _descriptionFocus.requestFocus(),
                            onTap: _pickTime,
                            onTapOutside: _dismissKeyboard,
                            validator: Validators.requiredText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _description,
                      focusNode: _descriptionFocus,
                      enabled: !_saving,
                      decoration: const InputDecoration(labelText: 'Description (optional)', border: OutlineInputBorder()),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                      onTapOutside: _dismissKeyboard,
                      validator: (_) => null,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.check),
                      label: Text(_saving ? 'Saving...' : 'Save event'),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
