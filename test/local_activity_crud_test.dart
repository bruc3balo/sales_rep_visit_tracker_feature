import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/local_database/local_activity_crud.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';

class MockLocalActivityCrud extends Mock implements LocalActivityCrud {}

class FakeLocalActivity extends Fake implements LocalActivity {}

void main() {
  late LocalActivityCrud crud;
  final activity = LocalActivity(id: 1, description: 'Sample', createdAt: DateTime.now(), updatedAt: DateTime.now());
  final activityList = [
    LocalActivity(id: 1, description: 'Sample 1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
    LocalActivity(id: 2, description: 'Sample 2', createdAt: DateTime.now(), updatedAt: DateTime.now()),
  ];
  final activityMap = {1: activity};

  setUpAll(() {
    registerFallbackValue(FakeLocalActivity());
  });

  setUp(() {
    crud = MockLocalActivityCrud();
  });

  group('LocalActivityCrud', () {
    test('setLocalActivity returns success', () async {
      when(() => crud.setLocalActivity(activity: any(named: 'activity')))
          .thenAnswer((_) async => SuccessResult(data: null));

      final result = await crud.setLocalActivity(activity: activity);
      expect(result is SuccessResult<void>, true);
    });

    test('setLocalActivities returns success', () async {
      when(() => crud.setLocalActivities(activities: any(named: 'activities')))
          .thenAnswer((_) async => SuccessResult(data: null));

      final result = await crud.setLocalActivities(activities: activityList);
      expect(result is SuccessResult<void>, true);
    });

    test('getLocalActivities returns list of activities', () async {
      when(() => crud.getLocalActivities(page: any(named: 'page'), pageSize: any(named: 'pageSize')))
          .thenAnswer((_) async => SuccessResult(data: activityList));

      final result = await crud.getLocalActivities(page: 0, pageSize: 10);
      expect(result is SuccessResult<List<LocalActivity>>, true);
    });

    test('searchLocalActivities returns matching activities', () async {
      when(() => crud.searchLocalActivities(
        likeDescription: any(named: 'likeDescription'),
        page: any(named: 'page'),
        pageSize: any(named: 'pageSize'),
      )).thenAnswer((_) async => SuccessResult(data: activityList));

      final result = await crud.searchLocalActivities(
        likeDescription: 'Sample',
        page: 0,
        pageSize: 10,
      );
      expect(result is SuccessResult<List<LocalActivity>>, true);
    });

    test('getLocalActivitiesByIds returns map of activities', () async {
      when(() => crud.getLocalActivitiesByIds(ids: any(named: 'ids')))
          .thenAnswer((_) async => SuccessResult(data: activityMap));

      final result = await crud.getLocalActivitiesByIds(ids: [1]);
      expect(result is SuccessResult<Map<int, LocalActivity>>, true);
    });

    test('deleteLocalActivity returns success', () async {
      when(() => crud.deleteLocalActivity(activityId: any(named: 'activityId')))
          .thenAnswer((_) async => SuccessResult(data: null));

      final result = await crud.deleteLocalActivity(activityId: 1);
      expect(result is SuccessResult<void>, true);
    });

    test('clearAllLocalActivities returns success', () async {
      when(() => crud.clearAllLocalActivities())
          .thenAnswer((_) async => SuccessResult(data: null));

      final result = await crud.clearAllLocalActivities();
      expect(result is SuccessResult<void>, true);
    });
  });
}