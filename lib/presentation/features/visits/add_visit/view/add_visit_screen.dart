import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/extensions.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/global_toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/card_tile.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/drop_down_tile.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/text_field_tile.dart';
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

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return PopScope(
      onPopInvokedWithResult: (_, __) async {
        bool exit = await showDialog<bool>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text(
                    'Exiting',
                    textAlign: TextAlign.center,
                  ),
                  content: Text(
                    'Did you want to continue later?',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Back'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                        widget.addVisitViewModel.clearDraft();
                      },
                      child: const Text(
                        'No',
                        style: TextStyle(
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        widget.addVisitViewModel.saveFormToDraft();
                        Navigator.of(context).pop(true);
                      },
                      child: const Text(
                        'Yes',
                        style: TextStyle(
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ) ??
            false;

        if (!exit || !context.mounted) return;
        Navigator.of(context).pop();
      },
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text("New Visit"),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ListenableBuilder(
            listenable: widget.addVisitViewModel,
            builder: (_, __) {
              var state = widget.addVisitViewModel.state;
              var form = widget.addVisitViewModel.form;
              return switch (state) {
                DraftingAddVisitState() => ListView(
                    children: [
                      const SizedBox(height: 8),

                      // Customer search
                      CardTile(
                        label: "Customer",
                        icon: Icons.person_outline,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => CustomerSearchDialog(
                              customerIdsToIgnore: HashSet.from([form.customer?.id].whereType<String>()),
                              searchCustomersViewModel: widget.searchCustomersViewModel,
                              onSelect: (c) => widget.addVisitViewModel.updateVisitForm(form: form.copyWith(customer: c)),
                            ),
                          );
                        },
                        child: Text(
                          form.customer?.name ?? "Tap to select a customer",
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ),

                      //Visit date
                      CardTile(
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
                            initialEntryMode: TimePickerEntryMode.input,
                          );
                          if (time == null || !context.mounted) return;
                          var newVisitDate = date.copyWith(hour: time.hour, minute: time.minute);
                          if (newVisitDate.isAfter(DateTime.now())) {
                            GlobalToastMessage().add(InfoMessage(message: "Visit date should not be in the future"));
                            return;
                          }
                          widget.addVisitViewModel.updateVisitForm(form: form.copyWith(visitDate: newVisitDate));
                        },
                        child: Text(
                          form.visitDate?.humanReadable ?? 'Select visit date',
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ),

                      // Visit status
                      DropdownTile<VisitStatus>(
                        label: "Visit Status",
                        items: VisitStatus.values,
                        selectedItem: form.status,
                        onSelected: (t) => widget.addVisitViewModel.updateVisitForm(form: form.copyWith(status: t)),
                        itemLabelBuilder: (e) => e.name.capitalize,
                      ),

                      ActivitySelectionTile(
                        label: "Activities",
                        onDelete: (a) => widget.addVisitViewModel.updateVisitForm(
                          form: form.copyWith(
                            activities: form.activities.where((e) => e.id != a.id).toList(),
                          ),
                        ),
                        onAdd: (a) => widget.addVisitViewModel.updateVisitForm(
                          form: form.copyWith(
                            activities: [...form.activities, a],
                          ),
                        ),
                        selectedActivities: form.activities,
                        viewModel: widget.searchActivitiesViewModel,
                      ),

                      TextFieldTile(
                        initialValue: form.location,
                        label: "Location",
                        hintText: "Where is the visit located",
                        debounceDuration: Duration(seconds: 1),
                        onDebouncedChanged: (v) => widget.addVisitViewModel.updateVisitForm(
                          form: form.copyWith(
                            location: v,
                          ),
                        ),
                      ),

                      TextFieldTile(
                        initialValue: form.notes,
                        label: "Notes",
                        hintText: "Add any relevant notes",
                        debounceDuration: Duration(seconds: 1),
                        onDebouncedChanged: (v) => widget.addVisitViewModel.updateVisitForm(
                          form: form.copyWith(
                            notes: v,
                          ),
                        ),
                        minLines: 4,
                      ),

                      const SizedBox(height: 12),

                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: widget.addVisitViewModel.isValid ? null : WidgetStatePropertyAll(Colors.grey),
                        ),
                        onPressed: () {
                          widget.addVisitViewModel.addNewVisit();
                        },
                        child: const Text("Submit"),
                      ),

                      const SizedBox(height: 16),

                    ],
                  ),
                LoadingAddVisitState() => const InfiniteLoader(),
                SuccessAddingVisitState() => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
      ),
    );
  }
}

class ActivitySelectionTile extends StatelessWidget {
  const ActivitySelectionTile({
    super.key,
    required this.label,
    required this.selectedActivities,
    required this.onDelete,
    required this.onAdd,
    required this.viewModel,
  });

  final String label;
  final List<Activity> selectedActivities;
  final Function(Activity) onDelete;
  final Function(Activity) onAdd;
  final SearchActivitiesViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
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
                    activitiesToIgnore: HashSet.from(selectedActivities.map((e) => e.id)),
                    searchActivitiesViewModel: viewModel,
                    onSelect: (a) {
                      if (!selectedActivities.any((e) => e.id == a.id)) {
                        onAdd(a);
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
                visible: selectedActivities.isNotEmpty,
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
                    itemCount: selectedActivities.length,
                    itemBuilder: (_, i) {
                      var activity = selectedActivities[i];
                      return ListTile(
                        title: Text(activity.description),
                        trailing: IconButton(
                          onPressed: () => onDelete(activity),
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
