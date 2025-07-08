import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_value_objects.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/local_database/local_unsynced_local_visit_crud.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/extensions.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/random_gen.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';

class MockLocalUnSyncedLocalVisitCrud extends Mock implements LocalUnSyncedLocalVisitCrud {}

class FakeUnSyncedLocalVisit extends Fake implements UnSyncedLocalVisit {}
class FakeLocalVisitHash extends Fake implements LocalVisitHash {}

void main() {
  late LocalUnSyncedLocalVisitCrud crud;
  final hash = LocalVisitHash(value: generateRandomKey(64));
  final visit = UnSyncedLocalVisit(
    key: generateRandomKey(15),
    visitDate: DateTime.now(),
    status: VisitStatus.pending.name.capitalize,
    location: 'Test Location',
    notes: 'Notes',
    activityIdsDone: [1],
    hash: hash.value,
    createdAt: DateTime.now(),
    customerIdVisited: 1,
  );
  final visitList = [visit];

  setUpAll(() {
    registerFallbackValue(FakeUnSyncedLocalVisit());
    registerFallbackValue(FakeLocalVisitHash());
  });

  setUp(() {
    crud = MockLocalUnSyncedLocalVisitCrud();
  });

  group('LocalUnSyncedLocalVisitCrud', () {
    test('countUnsyncedVisits returns count', () async {
      when(() => crud.countUnsyncedVisits())
          .thenAnswer((_) async => SuccessResult(data: 5));

      final result = await crud.countUnsyncedVisits();
      expect(result is SuccessResult<int>, true);
    });

    test('findByHash returns visit', () async {
      when(() => crud.findByHash(hash: any(named: 'hash')))
          .thenAnswer((_) async => SuccessResult(data: visit));

      final result = await crud.findByHash(hash: hash);
      expect(result is SuccessResult<UnSyncedLocalVisit?>, true);
    });

    test('setLocalVisit returns success', () async {
      when(() => crud.setLocalVisit(visit: any(named: 'visit')))
          .thenAnswer((_) async => SuccessResult(data: null));

      final result = await crud.setLocalVisit(visit: visit);
      expect(result is SuccessResult<void>, true);
    });

    test('getUnsyncedLocalVisits returns list', () async {
      when(() => crud.getUnsyncedLocalVisits(
        page: any(named: 'page'),
        pageSize: any(named: 'pageSize'),
      )).thenAnswer((_) async => SuccessResult(data: visitList));

      final result = await crud.getUnsyncedLocalVisits(page: 0, pageSize: 10);
      expect(result is SuccessResult<List<UnSyncedLocalVisit>>, true);
    });

    test('removeLocalVisit returns success', () async {
      when(() => crud.removeLocalVisit(visit: any(named: 'visit')))
          .thenAnswer((_) async => SuccessResult(data: null));

      final result = await crud.removeLocalVisit(visit: visit);
      expect(result is SuccessResult<void>, true);
    });

    test('removeLocalVisitByHash returns success', () async {
      when(() => crud.removeLocalVisitByHash(hash: any(named: 'hash')))
          .thenAnswer((_) async => SuccessResult(data: null));

      final result = await crud.removeLocalVisitByHash(hash: hash);
      expect(result is SuccessResult<void>, true);
    });
  });
}