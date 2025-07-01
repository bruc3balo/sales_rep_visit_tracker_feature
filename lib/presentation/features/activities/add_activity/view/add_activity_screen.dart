import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/components.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/activities/add_activity/model/add_activity_models.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/activities/add_activity/view_model/add_activity_view_model.dart';

class AddActivityScreen extends StatelessWidget {
   AddActivityScreen({
    required this.addActivityViewModel,
    super.key,
  });

  final AddActivityViewModel addActivityViewModel;
  final TextEditingController activityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New Activity"),
      ),
      body: Center(
        child: ListenableBuilder(
          listenable: addActivityViewModel,
          builder: (_, __) {
            var state = addActivityViewModel.state;
            switch(state) {

              case InitialAddActivityState():
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text("Description"),
                        subtitle: TextFormField(
                          controller: activityController,
                          decoration: InputDecoration(
                            hintText: "e.g. Networking",
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          String description = activityController.text;
                          if(description.isEmpty) return;

                          addActivityViewModel.addActivity(description);
                        },
                        child: Text("Create"),
                      ),
                    ),
                  ],
                );

              case LoadingAddActivityState():
                return InfiniteLoader();

              case SuccessAddActivityState():
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Activity added"),
                    ElevatedButton(
                      onPressed: Navigator.of(context).pop,
                      child: Text("Close"),
                    ),
                  ],
                );
            }
          },
        ),
      ),
    );
  }
}
