import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/loader.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/activities/edit_activity/model/edit_activity_models.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/activities/edit_activity/view_model/edit_activity_view_model.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/customers/edit_customer/model/edit_customer_model.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/customers/edit_customer/view_model/edit_customer_view_model.dart';

class EditCustomerScreen extends StatelessWidget {
  EditCustomerScreen({
    required this.editCustomerViewModel,
    super.key,
  });

  final EditCustomerViewModel editCustomerViewModel;
  final TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(

      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListenableBuilder(
            listenable: editCustomerViewModel,
            builder: (_, __) {
              var state = editCustomerViewModel.state;
              switch(state) {


                case InitialEditCustomerState():
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Update customer",
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text("Update name"),
                          subtitle: TextFormField(
                            controller: nameController..text = state.customer.name,
                            decoration: InputDecoration(
                              hintText: state.customer.name,
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            String name = nameController.text;
                            if(name.isEmpty) return;

                            editCustomerViewModel.editCustomer(name);
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
                case LoadingEditCustomerState():
                  return Wrap(
                    children: [
                      InfiniteLoader(),
                    ],
                  );

                case SuccessEditCustomerState():
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("'${state.customer.name}' updated",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(state.customer),
                        child: Text("Close"),
                      ),
                    ],
                  );
              }
            }
        ),
      ),
    );
  }
}
