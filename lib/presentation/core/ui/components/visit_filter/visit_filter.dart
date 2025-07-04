import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/extensions.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/global_toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/visit_filter/visit_filter_models.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/extensions/extensions.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/activities/search_activities/view/search_activities_screen.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/activities/search_activities/view_model/search_activities_view_model.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/customers/search_customers/view/search_customers_screen.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/customers/search_customers/view_model/search_customers_view_model.dart';

class VisitFilterComponent extends StatelessWidget {
  final VisitFilterState state;
  final Function(VisitFilterState) onChange;
  late final List<ActiveFilters> activeFilters = state.activeFilters;
  final SearchCustomersViewModel searchCustomersViewModel;
  final SearchActivitiesViewModel searchActivitiesViewModel;

  VisitFilterComponent({
    super.key,
    required this.state,
    required this.onChange,
    required this.searchCustomersViewModel,
    required this.searchActivitiesViewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: VisitFilters.values
          .map(
            (f) => VisitFilterChips(
              state: state,
              filter: f,
              activeFilters: state.filters[f] ?? [],
              searchCustomersViewModel: searchCustomersViewModel,
              searchActivitiesViewModel: searchActivitiesViewModel,
              onUpdateState: onChange,
            ),
          )
          .toList(),
    );
  }
}

class VisitFilterChips extends StatelessWidget {
  const VisitFilterChips({
    required this.filter,
    required this.activeFilters,
    required this.state,
    required this.onUpdateState,
    required this.searchCustomersViewModel,
    required this.searchActivitiesViewModel,
    super.key,
  });

  final VisitFilters filter;
  final SearchCustomersViewModel searchCustomersViewModel;
  final SearchActivitiesViewModel searchActivitiesViewModel;
  final List<dynamic> activeFilters;
  final VisitFilterState state;
  final Function(VisitFilterState) onUpdateState;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: activeFilters.isNotEmpty,
      replacement: ActionChip(
        label: Text(filter.label.capitalize),
        onPressed: () async {
          switch (filter) {
            case VisitFilters.fromDate:
              var date = await showDatePicker(
                context: context,
                firstDate: DateTime(DateTime.now().year - 1),
                lastDate: DateTime.now(),
              );

              if (date == null) return;
              if (!context.mounted) return;

              state.setFromDate(date);
              onUpdateState(state);
              break;

            case VisitFilters.toDate:
              var date = await showDatePicker(
                context: context,
                firstDate: DateTime(DateTime.now().year - 1),
                lastDate: DateTime.now(),
              );

              if (date == null) return;
              if (!context.mounted) return;

              state.setToDate(date);
              onUpdateState(state);

              break;

            case VisitFilters.customer:
              showDialog(
                context: context,
                builder: (context) {
                  return CustomerSearchDialog(
                    searchCustomersViewModel: searchCustomersViewModel,
                    onSelect: (c) {
                      state.addCustomer(CustomerRef(c.id, c.name));
                    },
                  );
                },
              );
              break;
            case VisitFilters.activity:
              showDialog(
                context: context,
                builder: (context) {
                  return ActivitySearchDialog(
                    searchActivitiesViewModel: searchActivitiesViewModel,
                    onSelect: (c) {
                      state.addActivity(ActivityRef(c.id, c.description));
                    },
                  );
                },
              );
              break;

            case VisitFilters.status:
              break;

            case VisitFilters.order:
              break;
          }
        },
      ),
      child: Wrap(
        children: activeFilters.map((f) {
          var data = switch (filter) {
            VisitFilters.fromDate => (f as DateTime).readableDate,
            VisitFilters.toDate => (f as DateTime).readableDate,
            VisitFilters.activity => (f as ActivityRef).description,
            VisitFilters.customer => (f as CustomerRef).name,
            VisitFilters.status => (f as VisitStatus).name.capitalize,
            VisitFilters.order => (f as String),
          };

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(filter.label.capitalize),
              FilterChip(
                label: Text(data),
                deleteIcon: Icon(
                  Icons.cancel_outlined,
                  color: Colors.red,
                ),
                onDeleted: () {
                  switch (filter) {
                    case VisitFilters.fromDate:
                      state.setFromDate(null);
                      onUpdateState(state);
                      break;
                    case VisitFilters.toDate:
                      state.setToDate(null);
                      onUpdateState(state);
                      break;

                    case VisitFilters.activity:
                      state.removeActivity(f as ActivityRef);
                      onUpdateState(state);
                      break;

                    case VisitFilters.customer:
                      state.removeCustomer(f as CustomerRef);
                      onUpdateState(state);
                      break;

                    case VisitFilters.status:
                      break;

                    case VisitFilters.order:
                      break;
                  }
                },
                selected: true,
                onSelected: (value) {},
              ),
            ],
          );
        }).toList(),
      ),
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
        padding: MediaQuery.of(context).viewInsets,
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
                    state: state,
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
