import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/customer/local_customer_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/customer/remote_customer_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/extensions.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/customer/update_customer_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/loader.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/customers/edit_customer/view/edit_customer_screen.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/customers/edit_customer/view_model/edit_customer_view_model.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/customers/view_customers/model/view_customers_model.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/customers/view_customers/view_model/view_customers_view_model.dart';

class ViewCustomersScreen extends StatelessWidget {
  const ViewCustomersScreen({
    required this.viewCustomersViewModel,
    required this.localCustomerRepository,
    required this.remoteCustomerRepository,
    super.key,
  });

  final LocalCustomerRepository localCustomerRepository;
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

        var itemCount = viewCustomersViewModel.customers.length + (isLoading ? 1 : 0);

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
              itemCount: itemCount,
              itemBuilder: (context, index) {
                if (index >= customers.length) {
                  return InfiniteLoader();
                }
                var customer = customers[index];

                if (deleteState is LoadingDeleteCustomerState && deleteState.customer.id == customer.id) {
                  return Icon(
                    Icons.auto_delete_outlined,
                    color: Colors.red,
                  );
                }

                bool isLastItem = index + 1 >= itemCount;
                var padding = (isLastItem) ? 120.0 : 0.0;

                return Dismissible(
                  key: ValueKey(customer.id),
                  onDismissed: (d) {
                    switch (d) {
                      case DismissDirection.endToStart:
                        viewCustomersViewModel.deleteCustomer(customer: customer);
                        break;

                      default:
                        break;
                    }
                  },
                  confirmDismiss: (d) async {
                    switch (d) {
                      case DismissDirection.endToStart:
                        return await showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Delete Customer'),
                                  content: Text('Confirm to delete ${customer.name},',style: TextStyle(color: Colors.black),),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: const Text('No'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(true);
                                      },
                                      child: const Text('Yes'),
                                    ),
                                  ],
                                );
                              },
                            ) ??
                            false;
                      case DismissDirection.startToEnd:
                        var updatedCustomer = await showDialog<Customer?>(
                          context: context,
                          builder: (context) {
                            return EditCustomerScreen(
                              editCustomerViewModel: EditCustomerViewModel(
                                customer: customer,
                                updateCustomerUseCase: UpdateCustomerUseCase(
                                  remoteCustomerRepository: remoteCustomerRepository,
                                  localCustomerRepository: localCustomerRepository,
                                ),
                              ),
                            );
                          },
                        );
                        if (updatedCustomer != null) viewCustomersViewModel.updateItem(updatedCustomer);
                        return false;

                      default:
                        return false;
                    }
                  },
                  background: Container(
                    color: Theme.of(context).colorScheme.primary,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Icon(Icons.edit, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: padding),
                    child: CustomerListTile(
                      customer: customer,
                    ),
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

class CustomerListTile extends StatelessWidget {
  const CustomerListTile({
    required this.customer,
    super.key,
  });

  final Customer customer;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(
          Icons.person_2_outlined,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      title: Text(customer.name),
    );
  }
}
