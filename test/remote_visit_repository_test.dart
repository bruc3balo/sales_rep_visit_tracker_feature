import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/visit/remote_visit_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/extensions.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';

class MockRemoteVisitRepository extends Mock implements RemoteVisitRepository {}

class FakeVisit extends Fake implements Visit {}

void main() {
  late RemoteVisitRepository repository;

  final visit = Visit(
    id: 1,
    visitDate: DateTime.now(),
    status: VisitStatus.completed.name.capitalize,
    location: 'Nairobi',
    notes: 'Follow-up visit',
    customerId: 1,
    createdAt: DateTime.now(),
    activitiesDone: [1],
  );

  final visitList = [visit];

  setUpAll(() {
    registerFallbackValue(FakeVisit());
    registerFallbackValue(VisitStatus.completed); // 👈 required for VisitStatus
  });

  setUp(() {
    repository = MockRemoteVisitRepository();
  });

  group('RemoteVisitRepository', () {
    test('createVisit returns success', () async {
      when(() => repository.createVisit(
        customerIdVisited: any(named: 'customerIdVisited'),
        visitDate: any(named: 'visitDate'),
        status: any(named: 'status'),
        location: any(named: 'location'),
        notes: any(named: 'notes'),
        activityIdsDone: any(named: 'activityIdsDone'),
        createdAt: any(named: 'createdAt'),
      )).thenAnswer((_) async => SuccessResult(data: null));

      final result = await repository.createVisit(
        customerIdVisited: 1,
        visitDate: DateTime.now(),
        status: VisitStatus.completed,
        location: 'Nairobi',
        notes: 'Met client',
        activityIdsDone: [1, 2],
      );

      expect(result is SuccessResult<void>, true);
    });

    test('getVisits returns list of visits', () async {
      when(() => repository.getVisits(
        customerId: any(named: 'customerId'),
        fromDateInclusive: any(named: 'fromDateInclusive'),
        toDateInclusive: any(named: 'toDateInclusive'),
        activityIdsDone: any(named: 'activityIdsDone'),
        status: any(named: 'status'),
        page: any(named: 'page'),
        pageSize: any(named: 'pageSize'),
        order: any(named: 'order'),
      )).thenAnswer((_) async => SuccessResult(data: visitList));

      final result = await repository.getVisits(
        customerId: 1,
        fromDateInclusive: DateTime.now().subtract(const Duration(days: 7)),
        toDateInclusive: DateTime.now(),
        activityIdsDone: [1],
        status: VisitStatus.completed,
        page: 0,
        pageSize: 10,
        order: 'desc',
      );

      expect(result is SuccessResult<List<Visit>>, true);
    });

    test('updateVisit returns updated visit', () async {
      when(() => repository.updateVisit(
        visitId: any(named: 'visitId'),
        customerId: any(named: 'customerId'),
        visitDate: any(named: 'visitDate'),
        status: any(named: 'status'),
        location: any(named: 'location'),
        notes: any(named: 'notes'),
        activityIdsDone: any(named: 'activityIdsDone'),
      )).thenAnswer((_) async => SuccessResult(data: visit));

      final result = await repository.updateVisit(
        visitId: 1,
        location: 'Updated Location',
      );

      expect(result is SuccessResult<Visit>, true);
    });

    test('deleteVisitById returns success', () async {
      when(() => repository.deleteVisitById(visitId: any(named: 'visitId')))
          .thenAnswer((_) async => SuccessResult(data: null));

      final result = await repository.deleteVisitById(visitId: 1);
      expect(result is SuccessResult<void>, true);
    });
  });
}