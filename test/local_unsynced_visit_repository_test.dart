import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_value_objects.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/visit/local_unsynced_visit_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/extensions.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/random_gen.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';

class MockLocalUnsyncedVisitRepository extends Mock implements LocalUnsyncedVisitRepository {}

class FakeUnSyncedLocalVisit extends Fake implements UnSyncedLocalVisit {}
class FakeLocalVisitHash extends Fake implements LocalVisitHash {}

void main() {
  late LocalUnsyncedVisitRepository repository;
  final visit = UnSyncedLocalVisit(
    key: generateRandomKey(15),
    hash: generateRandomKey(64),
    visitDate: DateTime.now(),
    location: 'Test Location',
    notes: 'Test notes',
    customerIdVisited: 1,
    status: VisitStatus.completed.name.capitalize,
    createdAt: DateTime.now(),
    activityIdsDone: [1],
  );
  final visitList = [visit];
  final hash = LocalVisitHash(value: 'a' * 64);

  setUpAll(() {
    registerFallbackValue(FakeUnSyncedLocalVisit());
    registerFallbackValue(FakeLocalVisitHash());
  });

  setUp(() {
    repository = MockLocalUnsyncedVisitRepository();
  });

  group('LocalUnsyncedVisitRepository', () {
    test('countUnsyncedVisits returns success count', () async {
      when(() => repository.countUnsyncedVisits())
          .thenAnswer((_) async => SuccessResult(data: 5));

      final result = await repository.countUnsyncedVisits();
      expect(result is SuccessResult<int>, true);
    });

    test('findByHash returns a visit', () async {
      when(() => repository.findByHash(hash: any(named: 'hash')))
          .thenAnswer((_) async => SuccessResult(data: visit));

      final result = await repository.findByHash(hash: hash);
      expect(result is SuccessResult<UnSyncedLocalVisit?>, true);
    });

    test('getUnsyncedVisits returns success list', () async {
      when(() => repository.getUnsyncedVisits(
        page: any(named: 'page'),
        pageSize: any(named: 'pageSize'),
      )).thenAnswer((_) async => SuccessResult(data: visitList));

      final result = await repository.getUnsyncedVisits(page: 0, pageSize: 10);
      expect(result is SuccessResult<List<UnSyncedLocalVisit>>, true);
    });

    test('setUnsyncedVisit returns success', () async {
      when(() => repository.setUnsyncedVisit(visit: any(named: 'visit')))
          .thenAnswer((_) async => SuccessResult(data: null));

      final result = await repository.setUnsyncedVisit(visit: visit);
      expect(result is SuccessResult<void>, true);
    });

    test('removeUnsyncedVisit returns success', () async {
      when(() => repository.removeUnsyncedVisit(visit: any(named: 'visit')))
          .thenAnswer((_) async => SuccessResult(data: null));

      final result = await repository.removeUnsyncedVisit(visit: visit);
      expect(result is SuccessResult<void>, true);
    });

    test('removeUnsyncedVisitByHash returns success', () async {
      when(() => repository.removeUnsyncedVisitByHash(hash: any(named: 'hash')))
          .thenAnswer((_) async => SuccessResult(data: null));

      final result = await repository.removeUnsyncedVisitByHash(hash: hash);
      expect(result is SuccessResult<void>, true);
    });
  });
}