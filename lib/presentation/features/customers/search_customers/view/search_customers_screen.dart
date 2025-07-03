import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/loader.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/customers/search_customers/model/search_customers_models.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/customers/search_customers/view_model/search_customers_view_model.dart';

class CustomerSearchDialog extends StatelessWidget {
   CustomerSearchDialog({
    this.initialCustomer,
    required this.searchCustomersViewModel,
    required this.onSelect,
    super.key,
  });

  final Customer? initialCustomer;
  final SearchCustomersViewModel searchCustomersViewModel;
  final Function(Customer) onSelect;
  final TextEditingController searchController = TextEditingController();


  void search() {
    String query = searchController.text;
    searchCustomersViewModel.searchCustomers(
      customerName: query,
      pageSize: min(query.length, 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Flex(
          direction: Axis.vertical,
          children: [
            TextFormField(
              controller: searchController,
              onFieldSubmitted: (s) => search(),
              decoration: InputDecoration(
                hintText: "Search by customer name ...",
                suffix: IconButton(
                  onPressed: search,
                  icon: Icon(Icons.search),
                ),
              ),
            ),
            ListenableBuilder(
              listenable: searchCustomersViewModel,
              builder: (_, __) {
                var state = searchCustomersViewModel.state;
                bool isLoading = state is LoadingCustomersSearchState;
                var data = switch(state) {
                  LoadingCustomersSearchState() => [],
                  LoadedCustomersSearchState() => state.searchResults?.toList() ?? searchCustomersViewModel.customers,
                };
                return Expanded(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (scrollInfo) {
                      bool isAtEndOfList = scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent;
                      if (!isLoading && isAtEndOfList) {
                        searchCustomersViewModel.searchCustomers(
                          customerName: searchController.text,
                          pageSize: 10,
                        );
                      }
                      return true;
                    },
                    child: ListView.builder(
                      itemCount: data.length,
                      shrinkWrap: true,
                      itemBuilder: (_, i) {
                        Customer c = data[i];
                        return ListTile(
                          selected: c.id == initialCustomer?.id,
                          onTap: () {
                            Navigator.of(context).pop();
                            onSelect(c);
                          },
                          title: Text(c.name),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: Text("Close"),
            ),
          ],
        ),
      ),
    );
  }
}
