import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/activities/search_activities/model/search_activities_models.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/activities/search_activities/view_model/search_activities_view_model.dart';

class ActivitySearchDialog extends StatelessWidget {
  ActivitySearchDialog({
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
  final TextEditingController searchController = TextEditingController();

  void search() {
    String query = searchController.text;
    searchActivitiesViewModel.searchActivities(
      activityDescription: query,
      pageSize: min(query.length, 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Flex(
          direction: Axis.vertical,
          children: [
            TextFormField(
              controller: searchController,
              onFieldSubmitted: (s) => search(),
              decoration: InputDecoration(
                hintText: "Search by activity description ...",
                suffix: IconButton(
                  onPressed: search,
                  icon: Icon(Icons.search),
                ),
              ),
            ),
            ListenableBuilder(
              listenable: searchActivitiesViewModel,
              builder: (_, __) {
                var state = searchActivitiesViewModel.state;
                var data = switch(state) {
                  LoadingActivitySearchState() => <Activity> [],
                  LoadedActivitySearchState() => state.searchResults?.toList() ?? searchActivitiesViewModel.activities,
                };
                bool isLoading = state is LoadingActivitySearchState;

                data.removeWhere((e) => activitiesToIgnore.contains(e.id));

                return Expanded(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (scrollInfo) {
                      bool isAtEndOfList = scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent;
                      if (!isLoading && isAtEndOfList) {
                        searchActivitiesViewModel.searchActivities(
                          activityDescription: searchController.text,
                          pageSize: 10,
                        );
                      }
                      return true;
                    },
                    child: ListView.builder(
                      itemCount: data.length,
                      shrinkWrap: true,
                      itemBuilder: (_, i) {
                        Activity c = data[i];
                        return ListTile(
                          selected: c.id == initialActivity?.id,
                          onTap: () {
                            Navigator.of(context).pop();
                            onSelect(c);
                          },
                          title: Text(c.description),
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
