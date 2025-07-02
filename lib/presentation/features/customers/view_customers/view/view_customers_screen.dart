import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/customer/remote_customer_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/extensions.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/components.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/customers/edit_customer/view/edit_customer_screen.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/customers/edit_customer/view_model/edit_customer_view_model.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/customers/view_customers/model/view_customers_model.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/customers/view_customers/view_model/view_customers_view_model.dart';

class ViewCustomersScreen extends StatelessWidget {
  const ViewCustomersScreen({
    required this.viewCustomersViewModel,
    required this.remoteCustomerRepository,
    super.key,
  });

  final RemoteCustomerRepository remoteCustomerRepository;
  final ViewCustomersViewModel viewCustomersViewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewCustomersViewModel,
      builder: (context, __) {
        var deleteState = viewCustomersViewModel.deleteState;
        bool isLoading = viewCustomersViewModel.itemsState is LoadingViewCustomerState;
        var customers = viewCustomersViewModel.customers;

        return NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            bool isAtEndOfList = scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent;
            if (!isLoading && isAtEndOfList) {
              viewCustomersViewModel.loadMoreItems();
            }

            return true;
          },
          child: RefreshIndicator(
            onRefresh: () => viewCustomersViewModel.refresh(),
            child: ListView.builder(
              itemCount: viewCustomersViewModel.customers.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= customers.length) {
                  return InfiniteLoader();
                }
                var customer = customers[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.shade300,
                    child: Icon(Icons.person, color: Colors.black,),
                  ),
                  title: Text(customer.name),
                  trailing: Builder(
                    builder: (context) {
                      if(
                      deleteState is LoadingDeleteCustomerState
                          &&
                          deleteState.customer.id == customer.id) {
                        return Icon(Icons.auto_delete_outlined, color: Colors.red,);
                      }

                      return MenuAnchor(
                        builder: (_, controller, __) {
                          return IconButton(
                            onPressed: () {
                              if (controller.isOpen) {
                                controller.close();
                                return;
                              }
                              controller.open();
                            },
                            icon: const Icon(Icons.more_vert),
                            tooltip: 'Activity options',
                          );
                        },
                        menuChildren: CustomerTileMenuItem.values
                            .map((menu) => MenuItemButton(
                          onPressed: () async {
                            switch(menu) {

                              case CustomerTileMenuItem.delete:
                                viewCustomersViewModel.deleteCustomer(
                                    customer: customer
                                );
                                break;
                              case CustomerTileMenuItem.edit:
                                var updatedCustomer = await showDialog<Customer?>(
                                  context: context,
                                  builder: (context) {
                                    return EditCustomerScreen(
                                      editCustomerViewModel: EditCustomerViewModel(
                                        remoteCustomerRepository: remoteCustomerRepository,
                                        customer: customer,
                                      ),
                                    );
                                  },
                                );
                                if(updatedCustomer == null) return;
                                viewCustomersViewModel.updateItem(updatedCustomer);
                                break;
                            }
                          },
                          child: Text(
                            menu.name.capitalize,
                            style: TextStyle(color:  Colors.black),
                          ),
                        ),
                        ).toList(),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
