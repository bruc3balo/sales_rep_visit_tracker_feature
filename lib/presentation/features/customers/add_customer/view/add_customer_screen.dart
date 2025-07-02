import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/components.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/customers/add_customer/model/add_customer_models.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/customers/add_customer/view_model/add_customer_view_model.dart';

class AddCustomerScreen extends StatelessWidget {
  AddCustomerScreen({
    required this.addCustomerViewModel,
    super.key,
  });

  final AddCustomerViewModel addCustomerViewModel;
  final TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New Customer"),
      ),
      body: Center(
        child: ListenableBuilder(
          listenable: addCustomerViewModel,
          builder: (_, __) {
            var state = addCustomerViewModel.state;
            switch(state) {

              case InitialAddCustomerState():
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text("Customer name"),
                        subtitle: TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                            hintText: "e.g. John doe",
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

                          addCustomerViewModel.addCustomer(name);
                        },
                        child: Text("Create"),
                      ),
                    ),
                  ],
                );

              case LoadingAddCustomerState():
                return InfiniteLoader();

              case SuccessAddCustomerState():
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("'${state.customer.name}' added",
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
