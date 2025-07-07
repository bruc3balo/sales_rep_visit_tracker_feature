import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/loader.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/customers/search_customers/model/search_customers_models.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/customers/search_customers/view_model/search_customers_view_model.dart';

class CustomerSearchDialog extends StatefulWidget {
  const CustomerSearchDialog({
    this.initialCustomer,
    required this.customerIdsToIgnore,
    required this.searchCustomersViewModel,
    required this.onSelect,
    super.key,
  });

  final Customer? initialCustomer;
  final HashSet<int> customerIdsToIgnore;
  final SearchCustomersViewModel searchCustomersViewModel;
  final Function(Customer) onSelect;

  @override
  State<CustomerSearchDialog> createState() => _CustomerSearchDialogState();
}

class _CustomerSearchDialogState extends State<CustomerSearchDialog> {
  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
    _performSearch(); // initial load
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _performSearch);
  }

  void _performSearch() {
    widget.searchCustomersViewModel.searchCustomers(
      customerName: searchController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Search Customer",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Search field
            TextFormField(
              controller: searchController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: "Search by customer name ...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    _performSearch();
                  },
                )
                    : null,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Search results
            Expanded(
              child: ListenableBuilder(
                listenable: widget.searchCustomersViewModel,
                builder: (_, __) {
                  final state = widget.searchCustomersViewModel.state;
                  final isLoading = state is LoadingCustomersSearchState;

                  var data = switch (state) {
                    LoadingCustomersSearchState() => widget.searchCustomersViewModel.customers,
                    LoadedCustomersSearchState() =>
                    state.searchResults?.toList() ?? widget.searchCustomersViewModel.customers,
                  };

                  // Filter ignored customers
                  data = data.where((c) => !widget.customerIdsToIgnore.contains(c.id)).toList();

                  if (data.isEmpty && isLoading) {
                    return const InfiniteLoader();
                  }

                  if (data.isEmpty) {
                    return const Center(child: Text("No matching customers found."));
                  }

                  return NotificationListener<ScrollNotification>(
                    onNotification: (scrollInfo) {
                      final isAtBottom = scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 100;
                      if (isAtBottom && !isLoading) {
                        widget.searchCustomersViewModel.searchCustomers(
                          customerName: searchController.text,
                        );
                      }
                      return false;
                    },
                    child: ListView.builder(
                      itemCount: data.length + (isLoading ? 1 : 0),
                      itemBuilder: (_, i) {
                        if (i >= data.length) return InfiniteLoader();

                        final customer = data[i];
                        return ListTile(
                          selected: customer.id == widget.initialCustomer?.id,
                          title: Text(customer.name),
                          onTap: () {
                            Navigator.of(context).pop();
                            widget.onSelect(customer);
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}