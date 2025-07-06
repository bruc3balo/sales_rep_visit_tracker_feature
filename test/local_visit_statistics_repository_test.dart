import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/visit/local_visit_statistics_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/domain/models/aggregation_models.dart';

class MockLocalVisitStatisticsRepository extends Mock implements LocalVisitStatisticsRepository {}

class FakeVisitStatisticsModel extends Fake implements VisitStatisticsModel {}

void main() {
  late LocalVisitStatisticsRepository repository;
  final statistics = VisitStatisticsModel(
    data: {
      VisitStatus.completed : 6,
      VisitStatus.pending : 4,
    },
    calculatedAt: DateTime.now()
  );

  setUpAll(() {
    registerFallbackValue(FakeVisitStatisticsModel());
  });

  setUp(() {
    repository = MockLocalVisitStatisticsRepository();
  });

  group('LocalVisitStatisticsRepository', () {
    test('fetchLocalStatistics returns success with model', () async {
      when(() => repository.fetchLocalStatistics())
          .thenAnswer((_) async => SuccessResult(data: statistics));

      final result = await repository.fetchLocalStatistics();
      expect(result is SuccessResult<VisitStatisticsModel?>, true);
    });

    test('setLocalStatistics returns success', () async {
      when(() => repository.setLocalStatistics(statistics: any(named: 'statistics')))
          .thenAnswer((_) async => SuccessResult(data: null));

      final result = await repository.setLocalStatistics(statistics: statistics);
      expect(result is SuccessResult<void>, true);
    });
  });
}