import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/extensions.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/model_mapper.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/card_tile.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/drop_down_tile.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/global_toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/loader.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/text_field_tile.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/extensions/extensions.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/activities/search_activities/view_model/search_activities_view_model.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/customers/search_customers/view/search_customers_screen.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/customers/search_customers/view_model/search_customers_view_model.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/add_visit/view/add_visit_screen.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/update_unsynced_visit/model/update_unsynced_visit_models.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/update_unsynced_visit/view_model/update_unsynced_visit_view_model.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/routing/routes.dart';

class UpdateUnsyncedVisitScreen extends StatelessWidget {
  const UpdateUnsyncedVisitScreen({
    required this.updateUnsyncedVisitViewModel,
    required this.searchCustomersViewModel,
    required this.searchActivitiesViewModel,
    super.key,
  });

  final UpdateUnsyncedVisitViewModel updateUnsyncedVisitViewModel;
  final SearchCustomersViewModel searchCustomersViewModel;
  final SearchActivitiesViewModel searchActivitiesViewModel;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return PopScope(
      onPopInvokedWithResult: (_, __) {
        Navigator.of(context).pushReplacementNamed(
          AppRoutes.visitUnsyncedVisits.path,
        );
      },
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Update Visit"),
        ),
        body: ListenableBuilder(
          listenable: updateUnsyncedVisitViewModel,
          builder: (_, __) {
            var state = updateUnsyncedVisitViewModel.state;

            switch (state) {
              case LoadedUpdateUnsyncedVisitState():
                var visit = state.visit;
                debugPrint("Rebuilding UI with customer: ${visit.customer?.name}");
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ListView(
                    children: [
                      // Customer search
                      CardTile(
                        label: "Customer",
                        icon: Icons.person_outline,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => CustomerSearchDialog(
                              customerIdsToIgnore: HashSet.from([visit.customer?.id].where((e) => e != null)),
                              searchCustomersViewModel: searchCustomersViewModel,
                              onSelect: (c) {
                                updateUnsyncedVisitViewModel.update(
                                  customerId: c.id,
                                );
                              },
                            ),
                          );
                        },
                        child: Text(
                          visit.customer?.name ?? "Tap to select a customer",
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
                            initialDate: visit.visitDate,
                            firstDate: DateTime(DateTime.now().year - 1),
                            lastDate: DateTime.now(),
                          );
                          if (date == null || !context.mounted) return;
                          var time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(visit.visitDate),
                            initialEntryMode: TimePickerEntryMode.input,
                          );
                          if (time == null || !context.mounted) return;
                          var newVisitDate = date.copyWith(hour: time.hour, minute: time.minute);
                          if (newVisitDate.isAfter(DateTime.now())) {
                            GlobalToastMessage().add(InfoMessage(message: "Visit date should not be in the future"));
                            return;
                          }

                          updateUnsyncedVisitViewModel.update(
                            visitDate: newVisitDate,
                          );
                        },
                        child: Text(
                          visit.visitDate.humanReadable,
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ),

                      // Visit status
                      DropdownTile<VisitStatus>(
                        label: "Visit Status",
                        items: VisitStatus.values,
                        selectedItem: visit.status,
                        onSelected: (t) => updateUnsyncedVisitViewModel.update(
                          status: t,
                        ),
                        itemLabelBuilder: (e) => e.name.capitalize,
                      ),

                      // Activity search
                      ActivitySelectionTile(
                        label: "Activities",
                        onDelete: (a) {
                          visit.activityMap.remove(a.id);
                          updateUnsyncedVisitViewModel.update(
                            activityIdsDone: visit.activityMap.values.map((a) => a.id).toList(),
                          );
                        },
                        onAdd: (a) {
                          if (visit.activityMap.containsKey(a.id)) return;

                          visit.activityMap.update(
                            a.id,
                            (_) => a.toRef,
                            ifAbsent: () => a.toRef,
                          );

                          updateUnsyncedVisitViewModel.update(
                            activityIdsDone: visit.activityMap.values.map((a) => a.id).toList(),
                          );
                        },
                        selectedActivities: visit.activityMap.values
                            .map(
                              (e) => Activity(
                                id: e.id,
                                description: e.description,

                                //Default date time here as not considered
                                createdAt: DateTime.now(),
                              ),
                            )
                            .toList(),
                        viewModel: searchActivitiesViewModel,
                      ),

                      // Location
                      TextFieldTile(
                        initialValue: visit.location,
                        label: "Location",
                        hintText: "Where is the visit located",
                        onDebouncedChanged: (s) {
                          updateUnsyncedVisitViewModel.update(
                            location: s,
                          );
                        },
                      ),
                      TextFieldTile(
                        initialValue: visit.notes,
                        label: "Notes",
                        hintText: "Add any relevant notes",
                        minLines: 4,
                        onDebouncedChanged: (s) {
                          updateUnsyncedVisitViewModel.update(
                            notes: s,
                          );
                        },
                      ),
                    ],
                  ),
                );

              case LoadingUpdateUnsyncedVisitState():
                return InfiniteLoader();
            }
          },
        ),
      ),
    );
  }
}
