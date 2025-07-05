import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/extensions.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/customers/search_customers/view/search_customers_screen.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/visit_filter/model/visit_filter_models.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/extensions/extensions.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/activities/search_activities/view/search_activities_screen.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/activities/search_activities/view_model/search_activities_view_model.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/customers/search_customers/view_model/search_customers_view_model.dart';

class VisitFilterComponent extends StatelessWidget {
  final VisitFilterState filter;
  final Function(VisitFilterState) onChange;
  final SearchCustomersViewModel searchCustomersViewModel;
  final SearchActivitiesViewModel searchActivitiesViewModel;

  const VisitFilterComponent({
    super.key,
    required this.filter,
    required this.onChange,
    required this.searchCustomersViewModel,
    required this.searchActivitiesViewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text("Visit Status"),
          subtitle: Wrap(
            spacing: 8,
            children: VisitStatus.values.map((option) {
              bool selected = option == filter.visitStatus;
              return ChoiceChip(
                label: Text(option.name.capitalize),
                selected: selected,
                onSelected: (_) {
                  var updatedFilter = filter..visitStatus = selected ? null : option;
                  onChange(updatedFilter);
                },
                selectedColor: Theme.of(context).colorScheme.primary,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : Colors.black87,
                ),
              );
            }).toList(),
          ),
        ),
        ListTile(
          title: Text("Date Range"),
          subtitle: Wrap(
            spacing: 8,
            direction: Axis.horizontal,
            children: [
              FilterChip(
                onSelected: (_) async {
                  var date = await showDatePicker(
                    context: context,
                    firstDate: DateTime(DateTime.now().year - 1),
                    lastDate: DateTime.now(),
                  );

                  if (date == null) return;
                  if (!context.mounted) return;

                  var updatedFilter = filter..fromDateInclusive = date;
                  onChange(updatedFilter);
                },
                deleteIcon: Icon(Icons.cancel_outlined),
                onDeleted: filter.fromDateInclusive == null
                    ? null
                    : () {
                        onChange(
                          filter..fromDateInclusive = null,
                        );
                      },
                label: Text(filter.fromDateInclusive?.readableDate ?? 'Start Date'),
              ),
              FilterChip(
                onSelected: (_) async {
                  var date = await showDatePicker(
                    context: context,
                    firstDate: DateTime(DateTime.now().year - 1),
                    lastDate: DateTime.now(),
                  );

                  if (date == null) return;
                  if (!context.mounted) return;

                  var updatedFilter = filter..toDateInclusive = date;
                  onChange(updatedFilter);
                },
                deleteIcon: Icon(Icons.cancel_outlined),
                onDeleted: filter.toDateInclusive == null
                    ? null
                    : () {
                        onChange(
                          filter..toDateInclusive = null,
                        );
                      },
                label: Text(filter.toDateInclusive?.readableDate ?? 'End Date'),
              ),
            ],
          ),
        ),
        ListTile(
          title: Text("Activities"),
          subtitle: Wrap(
            spacing: 8,
            children: [
              ...filter.activities.map(
                (a) {
                  return FilterChip(
                    label: Text(a.description),
                    deleteIcon: Icon(Icons.cancel_outlined),
                    onDeleted: () {
                      var updatedFilter = filter
                        ..activities.removeWhere(
                          (ar) => ar.id == a.id,
                        );
                      onChange(updatedFilter);
                    },
                    onSelected: (selected) {},
                  );
                },
              ),
              ActionChip(
                label: Icon(Icons.add),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return ActivitySearchDialog(
                        activitiesToIgnore: HashSet.from(filter.activities.map((e) => e.id)),
                        searchActivitiesViewModel: searchActivitiesViewModel,
                        onSelect: (c) {
                          onChange(
                            filter..activities.add(ActivityRef(c.id, c.description)),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
        ListTile(
          title: Text("Customer"),
          subtitle: Wrap(
            spacing: 8,
            children: [
              FilterChip(
                onSelected: (_) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return CustomerSearchDialog(
                        customerIdsToIgnore: HashSet.from([filter.customer?.id].where((e) => e != null)),
                        searchCustomersViewModel: searchCustomersViewModel,
                        onSelect: (c) {
                          onChange(
                            filter..customer = CustomerRef(c.id, c.name),
                          );
                        },
                      );
                    },
                  );
                },
                deleteIcon: Icon(Icons.cancel_outlined),
                onDeleted: filter.customer == null
                    ? null
                    : () {
                        var updatedFilter = filter..customer = null;
                        onChange(updatedFilter);
                      },
                label: Text(filter.customer?.name ?? '-'),
              ),
            ],
          ),
        ),
        ListTile(
          title: Text("Order"),
          subtitle: Wrap(
            spacing: 8,
            children: VisitOrderBy.values.map((option) {
              bool selected = filter.orderBy == option;
              return ChoiceChip(
                label: Text(option.label),
                selected: selected,
                onSelected: (bool selected) {
                  var updatedFilter = filter..orderBy = option;
                  onChange(updatedFilter);
                },
                selectedColor: Theme.of(context).colorScheme.primary,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : Colors.black87,
                ),
              );
            }).toList(),
          ),
        ),
        ListTile(
          title: Text("Sort"),
          subtitle: Wrap(
            spacing: 8,
            children: VisitSortBy.values.map((option) {
              bool selected = filter.sortBy == option;
              return ChoiceChip(
                label: Text(option.label),
                selected: selected,
                onSelected: (bool selected) {
                  var updatedFilter = filter..sortBy = option;
                  onChange(updatedFilter);
                },
                selectedColor: Theme.of(context).colorScheme.primary,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : Colors.black87,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

Future<VisitFilterState?> showVisitFilterBottomSheet({
  required BuildContext context,
  required SearchCustomersViewModel searchCustomersViewModel,
  required SearchActivitiesViewModel searchActivitiesViewModel,
  required VisitFilterState initialFilter,
}) async {
  final ValueNotifier<VisitFilterState> updatedFilterNotifier = ValueNotifier(initialFilter);
  return await showModalBottomSheet<VisitFilterState?>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: BottomSheet(
          onClosing: () {},
          builder: (_) => ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  "Filter Visits",
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ValueListenableBuilder(
                  valueListenable: updatedFilterNotifier,
                  builder: (_, currentFilter, __) {
                    return VisitFilterComponent(
                      searchActivitiesViewModel: searchActivitiesViewModel,
                      searchCustomersViewModel: searchCustomersViewModel,
                      filter: currentFilter,
                      onChange: (updatedFilter) {
                        updatedFilterNotifier.value = updatedFilter.copy();
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context), // Cancel
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(updatedFilterNotifier.value);
                        },
                        child: const Text("Apply"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
