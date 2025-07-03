import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/loader.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/activities/edit_activity/model/edit_activity_models.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/activities/edit_activity/view_model/edit_activity_view_model.dart';

class EditActivityScreen extends StatelessWidget {
  EditActivityScreen({
    required this.editActivityViewModel,
    super.key,
  });

  final EditActivityViewModel editActivityViewModel;
  final TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(

      child: ListenableBuilder(
        listenable: editActivityViewModel,
        builder: (_, __) {
          var state = editActivityViewModel.state;
            switch(state) {


              case InitialEditActivityState():
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Update activity",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text("Update description"),
                        subtitle: TextFormField(
                          controller: descriptionController..text = state.activity.description,
                          decoration: InputDecoration(
                            hintText: state.activity.description,
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

                          editActivityViewModel.editActivity(description);
                        },
                        child: Text("Update"),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextButton(
                        onPressed: Navigator.of(context).pop,
                        child: Text("Close", style: TextStyle(color: Colors.red),),
                      ),
                    ),

                  ],
                );
              case LoadingEditActivityState():
                return InfiniteLoader();

              case SuccessEditActivityState():
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("'${state.activity.description}' updated",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(state.activity),
                      child: Text("Close"),
                    ),
                  ],
                );
            }
        }
      ),
    );
  }
}
