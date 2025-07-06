import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/local_database/local_visit_statistics_crud.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/extensions.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';

class MockLocalVisitStatisticsCrud extends Mock implements LocalVisitStatisticsCrud {}

class FakeLocalVisitStatistics extends Fake implements LocalVisitStatistics {}

void main() {
  late LocalVisitStatisticsCrud crud;
  final stats = LocalVisitStatistics(

    statistics: {
      VisitStatus.completed.name.capitalize : 8,
      VisitStatus.cancelled.name.capitalize : 2,
    },
    createdAt: DateTime.now(),
  );

  setUpAll(() {
    registerFallbackValue(FakeLocalVisitStatistics());
  });

  setUp(() {
    crud = MockLocalVisitStatisticsCrud();
  });

  group('LocalVisitStatisticsCrud', () {
    test('setStatistics returns success', () async {
      when(() => crud.setStatistics(stats: any(named: 'stats')))
          .thenAnswer((_) async => SuccessResult(data: null));

      final result = await crud.setStatistics(stats: stats);
      expect(result is SuccessResult<void>, true);
    });

    test('getStatistics returns stats', () async {
      when(() => crud.getStatistics())
          .thenAnswer((_) async => SuccessResult(data: stats));

      final result = await crud.getStatistics();
      expect(result is SuccessResult<LocalVisitStatistics?>, true);
    });
  });
}