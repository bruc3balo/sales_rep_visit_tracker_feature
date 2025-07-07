import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/extensions.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/global_toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/loader.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/extensions/extensions.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/activities/search_activities/view/search_activities_screen.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/activities/search_activities/view_model/search_activities_view_model.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/customers/search_customers/view/search_customers_screen.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/customers/search_customers/view_model/search_customers_view_model.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/add_visit/model/add_visit_models.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/add_visit/view_model/add_visit_view_model.dart';

class AddVisitScreen extends StatefulWidget {
  const AddVisitScreen({
    required this.addVisitViewModel,
    required this.searchCustomersViewModel,
    required this.searchActivitiesViewModel,
    super.key,
  });

  final AddVisitViewModel addVisitViewModel;
  final SearchCustomersViewModel searchCustomersViewModel;
  final SearchActivitiesViewModel searchActivitiesViewModel;

  @override
  State<AddVisitScreen> createState() => _AddVisitScreenState();
}

class _AddVisitScreenState extends State<AddVisitScreen> {
  final TextEditingController notesController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final ValueNotifier<VisitStatus?> visitStatusNotifier = ValueNotifier(null);
  final ValueNotifier<DateTime> visitDateNotifier = ValueNotifier(DateTime.now());
  final ValueNotifier<Customer?> customerNotifier = ValueNotifier(null);
  final ValueNotifier<List<Activity>> activitiesNotifier = ValueNotifier([]);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("New Visit"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: ListenableBuilder(
          listenable: widget.addVisitViewModel,
          builder: (_, __) {
            var state = widget.addVisitViewModel.state;
            return switch (state) {
              InitialAddVisitState() => ListView(
                  children: [
                    const SizedBox(height: 8),
                    _LabeledCard(
                      label: "Customer",
                      icon: Icons.person_outline,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => CustomerSearchDialog(
                            customerIdsToIgnore: HashSet.from([customerNotifier.value?.id].whereType<String>()),
                            searchCustomersViewModel: widget.searchCustomersViewModel,
                            onSelect: (c) => customerNotifier.value = c,
                          ),
                        );
                      },
                      child: ValueListenableBuilder<Customer?>(
                        valueListenable: customerNotifier,
                        builder: (_, customer, __) => Text(
                          customer?.name ?? "Tap to select a customer",
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ),
                    ),
                    _LabeledCard(
                      label: "Visit Date",
                      icon: Icons.calendar_today_outlined,
                      onTap: () async {
                        var date = await showDatePicker(
                          context: context,
                          firstDate: DateTime(DateTime.now().year - 1),
                          lastDate: DateTime.now(),
                        );
                        if (date == null || !context.mounted) return;
                        var time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time == null || !context.mounted) return;
                        var newVisitDate = date.copyWith(hour: time.hour, minute: time.minute);
                        if (newVisitDate.isAfter(DateTime.now())) return;
                        visitDateNotifier.value = newVisitDate;
                      },
                      child: ValueListenableBuilder<DateTime>(
                        valueListenable: visitDateNotifier,
                        builder: (_, date, __) => Text(
                          date.humanReadable,
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ),
                    ),
                    _LabeledDropdown(
                      label: "Visit Status",
                      notifier: visitStatusNotifier,
                      items: VisitStatus.values,
                      itemLabelBuilder: (e) => e.name.capitalize,
                    ),
                    _LabeledActivities(
                      label: "Activities",
                      notifier: activitiesNotifier,
                      viewModel: widget.searchActivitiesViewModel,
                    ),
                    _LabeledTextField(
                      label: "Location",
                      controller: locationController,
                      hintText: "Where is the visit located",
                    ),
                    _LabeledTextField(
                      label: "Notes",
                      controller: notesController,
                      hintText: "Add any relevant notes",
                      minLines: 4,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        final customer = customerNotifier.value;
                        final visitDate = visitDateNotifier.value;
                        final status = visitStatusNotifier.value;
                        final location = locationController.text.trim();
                        final notes = notesController.text.trim();
                        final activities = activitiesNotifier.value;

                        if (customer == null) {
                          GlobalToastMessage().add(InfoMessage(message: "Customer required"));
                          return;
                        }
                        if (status == null) {
                          GlobalToastMessage().add(InfoMessage(message: "Select status"));
                          return;
                        }
                        if (location.isEmpty) {
                          GlobalToastMessage().add(InfoMessage(message: "Please enter visit location"));
                          return;
                        }
                        if (notes.isEmpty) {
                          GlobalToastMessage().add(InfoMessage(message: "Provide a brief summary your visit"));
                          return;
                        }

                        widget.addVisitViewModel.addNewVisit(
                          customer: customer,
                          visitDate: visitDate,
                          status: status,
                          location: location,
                          notes: notes,
                          activities: activities,
                        );
                      },
                      child: const Text("Submit"),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              LoadingAddVisitState() => const InfiniteLoader(),
              SuccessAddingVisitState() => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Visit saved", textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: Navigator.of(context).pop,
                      child: const Text("Back"),
                    )
                  ],
                ),
            };
          },
        ),
      ),
    );
  }
}

class _LabeledCard extends StatelessWidget {
  const _LabeledCard({
    required this.label,
    required this.icon,
    required this.child,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        title: Text(label, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: child,
        ),
        trailing: Icon(icon),
      ),
    );
  }
}

class _LabeledDropdown<T> extends StatelessWidget {
  const _LabeledDropdown({
    required this.label,
    required this.notifier,
    required this.items,
    required this.itemLabelBuilder,
  });

  final String label;
  final ValueNotifier<T?> notifier;
  final List<T> items;
  final String Function(T) itemLabelBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(label, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: ValueListenableBuilder<T?>(
          valueListenable: notifier,
          builder: (_, selected, __) {
            return DropdownMenu<T>(
              trailingIcon: const Icon(Icons.arrow_drop_down),
              width: MediaQuery.of(context).size.width - 24,
              initialSelection: selected,
              hintText: "Select $label",
              textStyle: theme.textTheme.bodyMedium,
              dropdownMenuEntries: items.map((e) {
                return DropdownMenuEntry<T>(
                  value: e,
                  label: itemLabelBuilder(e),
                  style: ButtonStyle(
                    foregroundColor: WidgetStatePropertyAll(theme.colorScheme.onSurface),
                  ),
                );
              }).toList(),
              onSelected: (val) => notifier.value = val,
            );
          },
        ),
      ),
    );
  }
}

class _LabeledTextField extends StatelessWidget {
  const _LabeledTextField({
    required this.label,
    required this.controller,
    this.hintText,
    this.minLines,
  });

  final String label;
  final TextEditingController controller;
  final String? hintText;
  final int? minLines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(hintText: hintText),
            minLines: minLines,
            maxLines: minLines != null ? null : 1,
          ),
        ],
      ),
    );
  }
}

class _LabeledActivities extends StatelessWidget {
  const _LabeledActivities({
    required this.label,
    required this.notifier,
    required this.viewModel,
  });

  final String label;
  final ValueNotifier<List<Activity>> notifier;
  final SearchActivitiesViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ValueListenableBuilder<List<Activity>>(
        valueListenable: notifier,
        builder: (_, activities, __) {
          return ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => ActivitySearchDialog(
                        activitiesToIgnore: HashSet.from(activities.map((e) => e.id)),
                        searchActivitiesViewModel: viewModel,
                        onSelect: (a) {
                          if (!notifier.value.any((e) => e.id == a.id)) {
                            notifier.value = [...notifier.value, a];
                          }
                        },
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  Visibility(
                    visible: activities.isNotEmpty,
                    replacement: Text(
                      "No activities recorded",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: activities.length,
                        itemBuilder: (_, i) => ListTile(
                          title: Text(activities[i].description),
                          trailing: IconButton(
                            onPressed: () {
                              notifier.value.removeAt(i);
                              notifier.value = [...notifier.value];
                            },
                            icon: const Icon(Icons.delete, color: Colors.red),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
