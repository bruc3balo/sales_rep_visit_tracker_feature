import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/extensions.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/themes/shared_theme.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/loader.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/extensions/extensions.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/activities/search_activities/view/search_activities_screen.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/activities/search_activities/view_model/search_activities_view_model.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/customers/search_customers/view/search_customers_screen.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/customers/search_customers/view_model/search_customers_view_model.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/update_unsynced_visit/model/update_unsynced_visit_models.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/update_unsynced_visit/view_model/update_unsynced_visit_view_model.dart';

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
  UpdateUnsyncedVisitViewModel get viewModel => widget.updateUnsyncedVisitViewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Update Visit"),
      ),
      body: ListenableBuilder(
        listenable: widget.updateUnsyncedVisitViewModel,
        builder: (_, __) {
          return ListView(
            children: [
              // Customer search
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  onTap: () {
                    //Select customer
                    showDialog(
                      context: context,
                      builder: (context) {
                        return CustomerSearchDialog(
                          searchCustomersViewModel: widget.searchCustomersViewModel,
                          onSelect: (c) {
                            viewModel.update(
                              customerId: c.id,
                            );
                          },
                        );
                      },
                    );
                  },
                  title: Text("Customer"),
                  subtitle: wrappedContainer(
                    child: Text(viewModel.visit.customer?.name ?? "Tap to select a customer"),
                  ),
                ),
              ),

              //Visit date
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  onTap: () async {
                    var date = await showDatePicker(
                      context: context,
                      firstDate: DateTime(DateTime.now().year - 1),
                      lastDate: DateTime.now(),
                    );

                    if (date == null) return;
                    if (!context.mounted) return;

                    var time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );

                    if (time == null) return;
                    if (!context.mounted) return;

                    var newVisitDate = date.copyWith(
                      hour: time.hour,
                      minute: time.minute,
                    );

                    if (newVisitDate.isAfter(DateTime.now())) {
                      //TODO: Notify user of error
                      return;
                    }

                    viewModel.update(
                      visitDate: newVisitDate,
                    );
                  },
                  title: Text("Visit date"),
                  subtitle: wrappedContainer(
                    child: Text(viewModel.visit.visitDate.humanReadable),
                  ),
                ),
              ),

              // Visit status
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text("Visit status"),
                  subtitle: DropdownMenu<VisitStatus>(
                    trailingIcon: SizedBox.shrink(),
                    width: double.infinity,
                    initialSelection: viewModel.visit.status,
                    hintText: "What is the status of your visit",
                    dropdownMenuEntries: VisitStatus.values
                        .map(
                          (o) => DropdownMenuEntry<VisitStatus>(
                            value: o,
                            label: o.name.capitalize,
                            style: ButtonStyle(
                              foregroundColor: WidgetStatePropertyAll(
                                Colors.black,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onSelected: (o) {
                      viewModel.update(
                        status: o,
                      );
                    },
                  ),
                ),
              ),

              // Activity search
              ListTile(
                title: ListTile(
                  title: Text("Activities"),
                  trailing: CircleAvatar(
                    child: IconButton(
                        onPressed: () {
                          //Select activity
                          showDialog(
                            context: context,
                            builder: (context) {
                              return ActivitySearchDialog(
                                searchActivitiesViewModel: widget.searchActivitiesViewModel,
                                onSelect: (a) {
                                  if (viewModel.visit.activityMap.containsKey(a.id)) return;

                                  viewModel.visit.activityMap.update(
                                    a.id,
                                    (_) => ActivityRef(a.id, a.description),
                                    ifAbsent: () => ActivityRef(a.id, a.description),
                                  );

                                  viewModel.update(
                                    activityIdsDone: viewModel.visit.activityMap.values.map((a) => a.id).toList(),
                                  );
                                },
                              );
                            },
                          );
                        },
                        icon: Icon(Icons.add)),
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: wrappedContainer(
                    child: Visibility(
                      visible: viewModel.visit.activityMap.isNotEmpty,
                      replacement: Text("No activities recorded"),
                      child: Container(
                        constraints: BoxConstraints(
                          maxHeight: 300,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: viewModel.visit.activityMap.values
                              .map(
                                (a) => ListTile(
                                  title: Text(a.description),
                                  trailing: IconButton(
                                    onPressed: () {
                                      viewModel.visit.activityMap.remove(a.id);
                                      viewModel.update(
                                        activityIdsDone: viewModel.visit.activityMap.values.map((a) => a.id).toList(),
                                      );
                                    },
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Location
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text("Location"),
                  subtitle: TextFormField(
                    initialValue: viewModel.visit.location,
                    onChanged: (s) {
                      viewModel.update(
                        location: s,
                      );
                    },
                    decoration: InputDecoration(
                      hintText: "Where is the visit located",
                    ),
                  ),
                ),
              ),

              // Notes
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text("Notes"),
                  subtitle: TextFormField(
                    initialValue: viewModel.visit.notes,
                    onChanged: (s) {
                      viewModel.update(
                        notes: s,
                      );
                    },
                    decoration: InputDecoration(
                      hintText: "Add any relevant notes",
                    ),
                    maxLines: null,
                    minLines: 4,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
