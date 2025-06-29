import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/components.dart';
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
        title: Text("Add visit"),
      ),
      body: ListenableBuilder(
        listenable: widget.addVisitViewModel,
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
                            customerNotifier.value = c;
                          },
                        );
                      },
                    );
                  },
                  title: Text("Customer"),
                  subtitle: ValueListenableBuilder(
                    valueListenable: customerNotifier,
                    builder: (_, customer, __) {
                      if (customer == null) return Text("Tap to select a customer");
                      return Text(customer.name);
                    },
                  ),
                ),
              ),

              // Activity search
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ValueListenableBuilder(
                  valueListenable: activitiesNotifier,
                  builder: (_, activities, __) {
                    return ExpansionTile(
                      leading: IconButton(
                        onPressed: () {
                          //Select activity
                          showDialog(
                            context: context,
                            builder: (context) {
                              return ActivitySearchDialog(
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
                        icon: Icon(Icons.add),
                      ),
                      title: Text("Activity"),
                      subtitle: Visibility(
                        visible: activities.isEmpty,
                        replacement: Text("${activities.length} activities done"),
                        child: Text("Tap to add an activity"),
                      ),
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
                    );
                  },
                ),
              ),

              // Visit status
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ValueListenableBuilder(
                  valueListenable: visitStatusNotifier,
                  builder: (_, visitStatus, __) {
                    return DropdownMenu<VisitStatus>(
                      trailingIcon: SizedBox.shrink(),
                      width: double.infinity,
                      initialSelection: visitStatus,
                      label: Text("Status"),
                      hintText: "What is the status of your visit",
                      dropdownMenuEntries: VisitStatus.values
                          .map(
                            (o) => DropdownMenuEntry<VisitStatus>(
                              value: o,
                              label: o.capitalize,
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

              // Location
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: locationController,
                  decoration: InputDecoration(
                    labelText: "Location",
                    hintText: "Where is the visit located",
                  ),
                ),
              ),

              // Notes
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: notesController,
                  decoration: InputDecoration(
                    labelText: "Notes",
                    hintText: "Write your findings",
                  ),
                  maxLines: null,
                  minLines: 4,
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
                    visitDateNotifier.value = date;
                  },
                  title: Text("Visit date"),
                  subtitle: ValueListenableBuilder(
                      valueListenable: visitDateNotifier,
                      builder: (_, visitDate, __) {
                        return Text(visitDate.toString());
                      }),
                ),
              ),


              switch(widget.addVisitViewModel.state) {
                InitialAddVisitState() => ElevatedButton(
                  onPressed: () {

                    Customer? customer = customerNotifier.value;
                    if(customer == null) return;

                    DateTime visitDate = visitDateNotifier.value;

                    VisitStatus? status = visitStatusNotifier.value;
                    if(status == null) return;

                    String location = locationController.text;
                    if(location.isEmpty) return;

                    String notes = notesController.text;
                    if(notes.isEmpty) return;

                    List<Activity> activities = activitiesNotifier.value;

                    widget.addVisitViewModel.addNewVisit(
                      customerId: customer.id,
                      visitDate: visitDate,
                      status: status,
                      location: location,
                      notes: notes,
                      activities: activities,
                    );
                  },
                  child: Text("Submit"),
                ),
                LoadingAddVisitState() => InfiniteLoader(),
                SuccessAddingVisitState() => ElevatedButton(
                  onPressed: Navigator.of(context).pop,
                  child: Text("Back"),
                ),
              }
            ],
          );
        }
      ),
    );
  }
}
