import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/local_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';


class MockLocalActivityRepository extends Mock implements LocalActivityRepository {}

class FakeActivity extends Fake implements Activity {}


void main() {
  late LocalActivityRepository repository;
  final activity = Activity(id: 1, description: 'Test Activity',createdAt: DateTime.now());
  final activityList = [
    Activity(id: 1, description: 'Test 1',createdAt: DateTime.now()),
    Activity(id: 2, description: 'Test 2',createdAt: DateTime.now()),
  ];

  setUpAll(() {
    registerFallbackValue(FakeActivity());
  });

  setUp(() {
    repository = MockLocalActivityRepository();
  });

  group('LocalActivityRepository', () {
    test('setLocalActivity returns success', () async {
      when(() => repository.setLocalActivity(activity: any(named: 'activity')))
          .thenAnswer((_) async => SuccessResult(data: null));

      final result = await repository.setLocalActivity(activity: activity);
      expect(result is SuccessResult<void>, true);
    });

    test('setLocalActivities returns success', () async {
      when(() => repository.setLocalActivities(activities: any(named: 'activities')))
          .thenAnswer((_) async => SuccessResult(data: null));

      final result = await repository.setLocalActivities(activities: activityList);
      expect(result is SuccessResult<void>, true);
    });

    test('getLocalActivities returns success map', () async {
      final map = {1: activity};
      when(() => repository.getLocalActivities(activityIds: any(named: 'activityIds')))
          .thenAnswer((_) async => SuccessResult(data: map));

      final result = await repository.getLocalActivities(activityIds: [1]);
      expect(result is SuccessResult<Map<int, Activity>>, true);
    });

    test('searchLocalActivities returns success list', () async {
      when(() => repository.searchLocalActivities(
        likeDescription: any(named: 'likeDescription'),
        page: any(named: 'page'),
        pageSize: any(named: 'pageSize'),
      )).thenAnswer((_) async => SuccessResult(data: activityList));

      final result = await repository.searchLocalActivities(
        likeDescription: 'Test',
        page: 1,
        pageSize: 10,
      );
      expect(result is SuccessResult<List<Activity>>, true);
    });

    test('fetchLocalActivities returns success list', () async {
      when(() => repository.fetchLocalActivities(
        page: any(named: 'page'),
        pageSize: any(named: 'pageSize'),
      )).thenAnswer((_) async => SuccessResult(data: activityList));

      final result = await repository.fetchLocalActivities(page: 0, pageSize: 5);
      expect(result is SuccessResult<List<Activity>>, true);
    });

    test('deleteLocalActivity returns success', () async {
      when(() => repository.deleteLocalActivity(activityId: any(named: 'activityId')))
          .thenAnswer((_) async => SuccessResult(data: null));

      final result = await repository.deleteLocalActivity(activityId: 1);
      expect(result is SuccessResult<void>, true);
    });

    test('clearLocalActivities returns success', () async {
      when(() => repository.clearLocalActivities())
          .thenAnswer((_) async => SuccessResult(data: null));

      final result = await repository.clearLocalActivities();
      expect(result is SuccessResult<void>, true);
    });
  });
}