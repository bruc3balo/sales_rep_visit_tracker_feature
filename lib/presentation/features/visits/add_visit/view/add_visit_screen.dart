import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/extensions.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/themes/shared_theme.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text("New Visit"),
      ),
      body: ListenableBuilder(
        listenable: widget.addVisitViewModel,
        builder: (_, __) {
          var state = widget.addVisitViewModel.state;
          return switch (state) {
            InitialAddVisitState() => ListView(
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
                              customerIdsToIgnore: HashSet.from([customerNotifier.value?.id].where((e) => e != null)),
                              searchCustomersViewModel: widget.searchCustomersViewModel,
                              onSelect: (c) {
                                customerNotifier.value = c;
                              },
                            );
                          },
                        );
                      },
                      title: Text("Customer"),
                      subtitle: borderedContainer(
                        child: ValueListenableBuilder(
                          valueListenable: customerNotifier,
                          builder: (_, customer, __) {
                            if (customer == null) {
                              return Text("Tap to select a customer");
                            }
                            return Text(customer.name);
                          },
                        ),
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

                        visitDateNotifier.value = newVisitDate;
                      },
                      title: Text("Visit date"),
                      subtitle: borderedContainer(
                        child: ValueListenableBuilder(
                          valueListenable: visitDateNotifier,
                          builder: (_, visitDate, __) {
                            return Text(visitDate.humanReadable);
                          },
                        ),
                      ),
                    ),
                  ),

                  // Visit status
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text("Visit status"),
                      subtitle: ValueListenableBuilder(
                        valueListenable: visitStatusNotifier,
                        builder: (_, visitStatus, __) {
                          return DropdownMenu<VisitStatus>(
                            trailingIcon: SizedBox.shrink(),
                            width: double.infinity,
                            initialSelection: visitStatus,
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
                              visitStatusNotifier.value = o;
                            },
                          );
                        },
                      ),
                    ),
                  ),

                  // Activity search
                  ValueListenableBuilder(
                    valueListenable: activitiesNotifier,
                    builder: (_, activities, __) {
                      return ListTile(
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
                                        activitiesToIgnore: HashSet.from(activitiesNotifier.value.map((e) => e.id)),
                                        searchActivitiesViewModel: widget.searchActivitiesViewModel,
                                        onSelect: (a) {
                                          if (activitiesNotifier.value.any((e) => e.id == a.id)) return;
                                          activitiesNotifier.value.add(a);
                                          activitiesNotifier.value = List.from(activitiesNotifier.value);
                                        },
                                      );
                                    },
                                  );
                                },
                                icon: Icon(Icons.add)),
                          ),
                        ),
                        subtitle: borderedContainer(
                          child: Visibility(
                            visible: activities.isNotEmpty,
                            replacement: Text("No activities recorded"),
                            child: Container(
                              constraints: BoxConstraints(
                                maxHeight: 300,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: activities
                                    .map(
                                      (a) => ListTile(
                                        title: Text(a.description),
                                        trailing: IconButton(
                                          onPressed: () {
                                            activitiesNotifier.value.remove(a);
                                            activitiesNotifier.value = List.from(activitiesNotifier.value);
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
                      );
                    },
                  ),

                  // Location
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text("Location"),
                      subtitle: TextFormField(
                        controller: locationController,
                        textInputAction: TextInputAction.next,
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
                        controller: notesController,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          hintText: "Add any relevant notes",
                        ),
                        maxLines: null,
                        minLines: 4,
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Customer? customer = customerNotifier.value;
                        if (customer == null) {
                          GlobalToastMessage().add(InfoMessage(message: "Customer required"));
                          return;
                        }

                        DateTime visitDate = visitDateNotifier.value;

                        VisitStatus? status = visitStatusNotifier.value;
                        if (status == null) {
                          GlobalToastMessage().add(InfoMessage(message: "Select status"));
                          return;
                        }

                        String location = locationController.text;
                        if (location.isEmpty) {
                          GlobalToastMessage().add(InfoMessage(message: "Please enter visit location"));
                          return;
                        }

                        String notes = notesController.text;
                        if (notes.isEmpty) {
                          GlobalToastMessage().add(InfoMessage(message: "Provide a brief summary your visit"));
                          return;
                        }

                        List<Activity> activities = activitiesNotifier.value;

                        widget.addVisitViewModel.addNewVisit(
                          customer: customer,
                          visitDate: visitDate,
                          status: status,
                          location: location,
                          notes: notes,
                          activities: activities,
                        );
                      },
                      child: Text("Submit"),
                    ),
                  ),
                ],
              ),
            LoadingAddVisitState() => InfiniteLoader(),
            SuccessAddingVisitState() => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Visit saved",
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
                    child: ElevatedButton(
                      onPressed: Navigator.of(context).pop,
                      child: Text("Back"),
                    ),
                  ),
                ],
              ),
          };
        },
      ),
    );
  }
}
