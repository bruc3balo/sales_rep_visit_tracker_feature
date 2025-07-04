import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/extensions.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/themes/shared_theme.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/global_toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/visit_filter/visit_filter_models.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/extensions/extensions.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/activities/search_activities/view/search_activities_screen.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/activities/search_activities/view_model/search_activities_view_model.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/customers/search_customers/view_model/search_customers_view_model.dart';

class VisitFilterComponent extends StatelessWidget {
  final VisitFilterState initialState;
  final Function(VisitFilterState) onChange;
  final SearchCustomersViewModel searchCustomersViewModel;
  final SearchActivitiesViewModel searchActivitiesViewModel;
  late final ValueNotifier<VisitFilterState> filterNotifier = ValueNotifier(initialState);

  VisitFilterComponent({
    super.key,
    required this.initialState,
    required this.onChange,
    required this.searchCustomersViewModel,
    required this.searchActivitiesViewModel,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: filterNotifier,
      builder: (_, filter, __) {
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
                      filterNotifier.value = filterNotifier.value.changeVisitStatus(
                        visitStatus: selected ? null : option,
                      );
                    },
                    selectedColor: Theme.of(context).colorScheme.primary,
                    backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
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
                  ActionChip(
                    onPressed: () async {
                      var date = await showDatePicker(
                        context: context,
                        firstDate: DateTime(DateTime.now().year - 1),
                        lastDate: DateTime.now(),
                      );

                      if (date == null) return;
                      if (!context.mounted) return;

                      filterNotifier.value = filterNotifier.value.copyWith(
                        fromDateInclusive: date,
                      );
                    },
                    label: Text(filter.fromDateInclusive?.readableDate ?? 'Start Date'),
                  ),

                  ActionChip(
                    onPressed: () async {
                      var date = await showDatePicker(
                        context: context,
                        firstDate: DateTime(DateTime.now().year - 1),
                        lastDate: DateTime.now(),
                      );

                      if (date == null) return;
                      if (!context.mounted) return;

                      filterNotifier.value = filterNotifier.value.copyWith(
                        toDateInclusive: date,
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
                          filterNotifier.value.activities.removeWhere((ar) => ar.id == a.id);
                          filterNotifier.value = filterNotifier.value.copyWith(
                            activities: List.from(filterNotifier.value.activities),
                          );
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
                            searchActivitiesViewModel: searchActivitiesViewModel,
                            onSelect: (c) {
                              filterNotifier.value.activities.add(ActivityRef(c.id, c.description));

                              filterNotifier.value = filterNotifier.value.copyWith(
                                activities: List.from(filterNotifier.value.activities),
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
              subtitle: ActionChip(
                onPressed: () {},
                label: Text(filter.customer?.name ?? 'Filter by customer'),
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
                      filterNotifier.value = filterNotifier.value.copyWith(
                        orderBy: option,
                      );
                    },
                    selectedColor: Theme.of(context).colorScheme.primary,
                    backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
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
                      filterNotifier.value = filterNotifier.value.copyWith(
                        sortBy: option,
                      );
                    },
                    selectedColor: Theme.of(context).colorScheme.primary,
                    backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.black87,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

Future<VisitFilterState?> showVisitFilterModal({
  required BuildContext context,
  required SearchCustomersViewModel searchCustomersViewModel,
  required SearchActivitiesViewModel searchActivitiesViewModel,
  required VisitFilterState currentFilters,
}) async {
  ValueNotifier<VisitFilterState> tempFilterNotifier = ValueNotifier(currentFilters);

  return await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: MediaQuery.of(context).viewInsets.copyWith(
              bottom: 20,
            ),
        child: BottomSheet(
          onClosing: () {},
          builder: (_) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Filter Visits", style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 12),
              ValueListenableBuilder(
                valueListenable: tempFilterNotifier,
                builder: (_, state, __) {
                  return VisitFilterComponent(
                    searchActivitiesViewModel: searchActivitiesViewModel,
                    searchCustomersViewModel: searchCustomersViewModel,
                    initialState: state,
                    onChange: (newState) {
                      GlobalToastMessage().add(InfoMessage(message: "Filter updated"));
                      tempFilterNotifier.value = newState;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              Flex(
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
                        Navigator.of(context).pop(tempFilterNotifier.value);
                      },
                      child: const Text("Apply"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
