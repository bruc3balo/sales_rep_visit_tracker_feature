import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/loader.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/activities/search_activities/model/search_activities_models.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/activities/search_activities/view_model/search_activities_view_model.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/customers/search_customers/model/search_customers_models.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/customers/search_customers/view_model/search_customers_view_model.dart';

class ActivitySearchDialog extends StatelessWidget {
   ActivitySearchDialog({
    this.initialActivity,
    required this.searchActivitiesViewModel,
    required this.onSelect,
    super.key,
  });

  final Activity? initialActivity;
  final SearchActivitiesViewModel searchActivitiesViewModel;
  final Function(Activity) onSelect;
  final TextEditingController searchController = TextEditingController();

  void search () {
    String query = searchController.text;
    searchActivitiesViewModel.searchActivities(
      activityDescription: query,
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
                hintText: "Search by activity description ...",
                suffix: IconButton(onPressed: search, icon: Icon(Icons.search),)
              ),
            ),
            ListenableBuilder(
              listenable: searchActivitiesViewModel,
              builder: (_, __) {
                var state = searchActivitiesViewModel.state;
                switch (state) {
                  case LoadingActivitySearchState():
                    return InfiniteLoader();
                  case LoadedActivitySearchState():
                    List<Activity> filtered = state.searchResults.toList();
                    return Expanded(
                      child: ListView.builder(
                        itemCount: filtered.length,
                        shrinkWrap: true,
                        itemBuilder: (_, i) {
                          Activity c = filtered[i];
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
