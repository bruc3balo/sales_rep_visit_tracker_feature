import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/extensions.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';
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

class UpdateUnsyncedVisitScreen extends StatefulWidget {
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
  State<UpdateUnsyncedVisitScreen> createState() => _UpdateUnsyncedVisitScreenState();
}

class _UpdateUnsyncedVisitScreenState extends State<UpdateUnsyncedVisitScreen> {
  late final ValueNotifier<CustomerRef?> customerNotifier = ValueNotifier(
    widget.updateUnsyncedVisitViewModel.originalVisit.customer,
  );

  late final ValueNotifier<DateTime> visitDateNotifier = ValueNotifier(
    widget.updateUnsyncedVisitViewModel.originalVisit.visitDate,
  );

  late final ValueNotifier<List<int>> activitiesNotifier = ValueNotifier(
    widget.updateUnsyncedVisitViewModel.originalVisit.activityMap.keys.toList(),
  );

  late final ValueNotifier<VisitStatus> visitStatusNotifier = ValueNotifier(
    widget.updateUnsyncedVisitViewModel.originalVisit.status,
  );

  late final TextEditingController notesController = TextEditingController(
    text: widget.updateUnsyncedVisitViewModel.originalVisit.notes,
  );

  late final TextEditingController locationController = TextEditingController(
    text: widget.updateUnsyncedVisitViewModel.originalVisit.location,
  );

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Update Visit"),
      ),
      body: ListenableBuilder(
        listenable: widget.updateUnsyncedVisitViewModel,
        builder: (_, __) {
          var state = widget.updateUnsyncedVisitViewModel.state;

          switch (state) {
            case InitialUpdateUnsyncedVisitState():
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ListView(
                  children: [
                    // Customer search
                    ValueListenableBuilder(
                      valueListenable: customerNotifier,
                      builder: (_, customer, __) {
                        return CardTile(
                          label: "Customer",
                          icon: Icons.person_outline,
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => CustomerSearchDialog(
                                customerIdsToIgnore: HashSet.from([customer?.id].where((e) => e != null)),
                                searchCustomersViewModel: widget.searchCustomersViewModel,
                                onSelect: (c) {
                                  customerNotifier.value = c.toRef;
                                },
                              ),
                            );
                          },
                          child: Text(
                            customer?.name ?? "Tap to select a customer",
                            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                        );
                      },
                    ),

                    //Visit date
                    ValueListenableBuilder(
                      valueListenable: visitDateNotifier,
                      builder: (_, visitDate, __) {
                        return CardTile(
                          label: "Visit Date",
                          icon: Icons.calendar_today_outlined,
                          onTap: () async {
                            var date = await showDatePicker(
                              context: context,
                              initialDate: visitDate,
                              firstDate: DateTime(DateTime.now().year - 1),
                              lastDate: DateTime.now(),
                            );
                            if (date == null || !context.mounted) return;
                            var time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(visitDate),
                              initialEntryMode: TimePickerEntryMode.input,
                            );
                            if (time == null || !context.mounted) return;
                            var newVisitDate = date.copyWith(hour: time.hour, minute: time.minute);
                            if (newVisitDate.isAfter(DateTime.now())) {
                              GlobalToastMessage().add(InfoMessage(message: "Visit date should not be in the future"));
                              return;
                            }

                            visitDateNotifier.value = newVisitDate;
                          },
                          child: Text(
                            visitDate.humanReadable,
                            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                        );
                      },
                    ),

                    // Visit status
                    ValueListenableBuilder(
                      valueListenable: visitStatusNotifier,
                      builder: (_, visitStatus, __) {
                        return DropdownTile<VisitStatus>(
                          label: "Visit Status",
                          items: VisitStatus.values,
                          selectedItem: visitStatus,
                          onSelected: (t) => visitStatusNotifier.value = t ?? visitStatusNotifier.value,
                          itemLabelBuilder: (e) => e.name.capitalize,
                        );
                      },
                    ),

                    // Activity search
                    ValueListenableBuilder(
                      valueListenable: activitiesNotifier,
                      builder: (_, activityIds, __) {
                        return ActivitySelectionTile(
                          label: "Activities",
                          onDelete: (a) {
                            activitiesNotifier.value = List.from(activityIds.where((e) => e != a.id));
                          },
                          onAdd: (a) {
                            if (activityIds.contains(a.id)) return;
                            activitiesNotifier.value = List.from([...activityIds, a.id]);
                          },
                          selectedActivities:
                              activityIds.where((e) => widget.updateUnsyncedVisitViewModel.originalVisit.activityMap.containsKey(e)).map(
                            (e) {
                              var a = widget.updateUnsyncedVisitViewModel.originalVisit.activityMap[e]!;
                              return Activity(
                                id: a.id,
                                description: a.description,
                                //Default date time here as not considered
                                createdAt: DateTime.now(),
                              );
                            },
                          ).toList(),
                          viewModel: widget.searchActivitiesViewModel,
                        );
                      },
                    ),

                    // Location
                    TextFieldTile(
                      controller: locationController,
                      label: "Location",
                      hintText: "Where is the visit located",
                    ),
                    TextFieldTile(
                      controller: notesController,
                      label: "Notes",
                      hintText: "Add any relevant notes",
                      minLines: 4,
                    ),

                    ElevatedButton(
                      onPressed: () async {
                        final customer = customerNotifier.value;
                        final visitDate = visitDateNotifier.value;
                        final status = visitStatusNotifier.value;
                        final location = locationController.text;
                        final notes = notesController.text;
                        final activities = activitiesNotifier.value;

                        if (customer == null) {
                          GlobalToastMessage().add(InfoMessage(message: "Customer required"));
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

                        widget.updateUnsyncedVisitViewModel.update(
                          visitDate: visitDate,
                          status: status,
                          location: location,
                          notes: notes,
                          activityIdsDone: activities,
                          customerId: customer.id,
                        );
                      },
                      child: const Text("Update"),
                    )
                  ],
                ),
              );

            case LoadingUpdateUnsyncedVisitState():
              return InfiniteLoader();

            case CompletedUpdateUnsyncedVisitState():
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text("Visit updated", textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: Navigator.of(context).pop,
                    child: const Text("Back"),
                  )
                ],
              );
          }
        },
      ),
    );
  }
}
