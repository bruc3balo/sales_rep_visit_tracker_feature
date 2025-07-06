import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/remote_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';

class MockRemoteActivityRepository extends Mock implements RemoteActivityRepository {}

class FakeActivity extends Fake implements Activity {}

void main() {
  late RemoteActivityRepository repository;
  final activity = Activity(id: 1, description: 'Test Activity', createdAt: DateTime.now());
  final activityList = [
    Activity(id: 1, description: 'Test 1', createdAt: DateTime.now()),
    Activity(id: 2, description: 'Test 2', createdAt: DateTime.now()),
  ];

  setUpAll(() {
    registerFallbackValue(FakeActivity());
  });

  setUp(() {
    repository = MockRemoteActivityRepository();
  });

  group('RemoteActivityRepository', () {
    test('createActivity returns success', () async {
      when(() => repository.createActivity(description: any(named: 'description')))
          .thenAnswer((_) async => SuccessResult(data: null));

      final result = await repository.createActivity(description: 'New activity');
      expect(result is SuccessResult<void>, true);
    });

    test('getActivities returns success list', () async {
      when(() => repository.getActivities(
        ids: any(named: 'ids'),
        likeDescription: any(named: 'likeDescription'),
        equalDescription: any(named: 'equalDescription'),
        page: any(named: 'page'),
        pageSize: any(named: 'pageSize'),
        order: any(named: 'order'),
      )).thenAnswer((_) async => SuccessResult(data: activityList));

      final result = await repository.getActivities(
        ids: [1],
        likeDescription: 'Test',
        equalDescription: null,
        page: 0,
        pageSize: 10,
        order: 'desc',
      );

      expect(result is SuccessResult<List<Activity>>, true);
    });

    test('updateActivity returns success', () async {
      when(() => repository.updateActivity(
        activityId: any(named: 'activityId'),
        description: any(named: 'description'),
      )).thenAnswer((_) async => SuccessResult(data: null));

      final result = await repository.updateActivity(
        activityId: 1,
        description: 'Updated description',
      );

      expect(result is SuccessResult<void>, true);
    });

    test('deleteActivity returns success', () async {
      when(() => repository.deleteActivity(activityId: any(named: 'activityId')))
          .thenAnswer((_) async => SuccessResult(data: null));

      final result = await repository.deleteActivity(activityId: 1);
      expect(result is SuccessResult<void>, true);
    });
  });
}