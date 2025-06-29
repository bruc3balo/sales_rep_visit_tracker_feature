import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/components.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/customers/view_customers/model/view_customers_model.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/customers/view_customers/view_model/view_customers_view_model.dart';

class ViewCustomersScreen extends StatelessWidget {
  const ViewCustomersScreen({
    required this.viewCustomersViewModel,
    super.key,
  });

  final ViewCustomersViewModel viewCustomersViewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewCustomersViewModel,
      builder: (context, __) {
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
                  title: Text(customer.name),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
