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
            child: Visibility(
              visible: itemCount > 0,
              replacement: Center(
                child: Text(
                  "Nothing to see here",
                  textAlign: TextAlign.center,
                ),
              ),
              child: ListView.builder(
                itemCount: itemCount + 1, // One extra for the SizedBox
                itemBuilder: (context, index) {
                  if (index >= customers.length) {
                    // Show InfiniteLoader if still loading
                    if (isLoading && index == customers.length) return InfiniteLoader();

                    // Otherwise, show bottom spacer
                    return const SizedBox(height: 120);
                  }

                  var customer = customers[index];

                  if (deleteState is LoadingDeleteCustomerState && deleteState.customer.id == customer.id) {
                    return const Icon(
                      Icons.auto_delete_outlined,
                      color: Colors.red,
                    );
                  }

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
                                    title: const Text(
                                      'Delete Customer',
                                      textAlign: TextAlign.center,
                                    ),
                                    content: Text(
                                      "Confirm deletion of '${customer.name}'",
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.secondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
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
                          if (updatedCustomer != null) {
                            viewCustomersViewModel.updateItem(updatedCustomer);
                          }
                          return false;

                        default:
                          return false;
                      }
                    },
                    background: Container(
                      color: Theme.of(context).colorScheme.primary,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.edit, color: Colors.white),
                    ),
                    secondaryBackground: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: CustomerListTile(
                      customer: customer,
                    ),
                  );
                },
              ),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        leading: CircleAvatar(
          backgroundColor: colorScheme.primary,
          child: Icon(
            Icons.person_2_outlined,
            color: colorScheme.onPrimary,
          ),
        ),
        title: Text(
          customer.name,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
