import 'dart:collection';
import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/loader.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/activities/search_activities/model/search_activities_models.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/activities/search_activities/view_model/search_activities_view_model.dart';

class ActivitySearchDialog extends StatefulWidget {
  const ActivitySearchDialog({
    this.initialActivity,
    required this.activitiesToIgnore,
    required this.searchActivitiesViewModel,
    required this.onSelect,
    super.key,
  });

  final Activity? initialActivity;
  final HashSet<int> activitiesToIgnore;
  final SearchActivitiesViewModel searchActivitiesViewModel;
  final Function(Activity) onSelect;

  @override
  State<ActivitySearchDialog> createState() => _ActivitySearchDialogState();
}

class _ActivitySearchDialogState extends State<ActivitySearchDialog> {
  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
    _performSearch();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _performSearch();
    });
  }

  void _performSearch() {
    final query = searchController.text;
    widget.searchActivitiesViewModel.searchActivities(
      activityDescription: query.isEmpty ? null : query,
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
            // Dialog title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Search Activity",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Search input
            TextFormField(
              controller: searchController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: "Search by activity description ...",
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

            // Results list
            Expanded(
              child: ListenableBuilder(
                listenable: widget.searchActivitiesViewModel,
                builder: (_, __) {
                  final state = widget.searchActivitiesViewModel.state;
                  final isLoading = state is LoadingActivitySearchState;

                  var data = switch (state) {
                    LoadingActivitySearchState() => widget.searchActivitiesViewModel.activities,
                    LoadedActivitySearchState() =>
                    state.searchResults?.toList() ?? widget.searchActivitiesViewModel.activities,
                  };

                  data = data.where((e) => !widget.activitiesToIgnore.contains(e.id)).toList();

                  if (data.isEmpty && isLoading) {
                    return const InfiniteLoader();
                  }

                  if (data.isEmpty) {
                    return const Center(child: Text("No matching activities found."));
                  }

                  return NotificationListener<ScrollNotification>(
                    onNotification: (scrollInfo) {
                      final reachedBottom = scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 100;
                      if (reachedBottom && !isLoading) {
                        widget.searchActivitiesViewModel.searchActivities(
                          activityDescription: searchController.text,
                        );
                      }
                      return false;
                    },
                    child: ListView.builder(
                      itemCount: data.length + (isLoading ? 1 : 0),
                      itemBuilder: (_, i) {
                        if (i >= data.length) return InfiniteLoader();

                        final activity = data[i];
                        return ListTile(
                          selected: activity.id == widget.initialActivity?.id,
                          title: Text(activity.description),
                          onTap: () {
                            Navigator.of(context).pop();
                            widget.onSelect(activity);
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