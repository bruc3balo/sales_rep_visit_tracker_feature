import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/loader.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/customers/search_customers/model/search_customers_models.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/customers/search_customers/view_model/search_customers_view_model.dart';

class CustomerSearchDialog extends StatelessWidget {
  const CustomerSearchDialog({
    this.initialCustomer,
    required this.searchCustomersViewModel,
    required this.onSelect,
    super.key,
  });

  final Customer? initialCustomer;
  final SearchCustomersViewModel searchCustomersViewModel;
  final Function(Customer) onSelect;

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
              onFieldSubmitted: (s) {
                searchCustomersViewModel.searchCustomers(
                  customerName: s,
                  pageSize: min(s.length, 20),
                );
              },
              decoration: InputDecoration(
                hintText: "Search by customer name ...",
              ),
            ),
            ListenableBuilder(
              listenable: searchCustomersViewModel,
              builder: (_, __) {
                var state = searchCustomersViewModel.state;
                switch (state) {
                  case LoadingCustomersSearchState():
                    return InfiniteLoader();
                  case LoadedCustomersSearchState():
                    List<Customer> filtered = state.searchResults.toList();
                    return Expanded(
                      child: ListView.builder(
                        itemCount: filtered.length,
                        shrinkWrap: true,
                        itemBuilder: (_, i) {
                          Customer c = filtered[i];
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
                    );
                }
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
