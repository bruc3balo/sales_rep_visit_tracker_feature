import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/components.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/extensions/extensions.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/activities/add_activity/model/add_activity_models.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/activities/add_activity/view_model/add_activity_view_model.dart';

class AddActivityScreen extends StatefulWidget {
   const AddActivityScreen({
    required this.addActivityViewModel,
    super.key,
  });

  final AddActivityViewModel addActivityViewModel;

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final TextEditingController descriptionController = TextEditingController();
  late final StreamSubscription<ToastMessage> toastSubscription;

  @override
  void initState() {
    toastSubscription = widget.addActivityViewModel.toastStream.listen((t) => t.show());
    super.initState();
  }

  @override
  void dispose() {
    toastSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New Activity"),
      ),
      body: Center(
        child: ListenableBuilder(
          listenable: widget.addActivityViewModel,
          builder: (_, __) {
            var state = widget.addActivityViewModel.state;
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
                          controller: descriptionController,
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
                          String description = descriptionController.text;
                          if(description.isEmpty) return;

                          widget.addActivityViewModel.addActivity(description);
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
                    Text("'${state.activity.description}' added",
                    style: Theme.of(context).textTheme.bodyLarge,
                    ),
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
