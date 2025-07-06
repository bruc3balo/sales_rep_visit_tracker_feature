import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/networking/network_service.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/networking/src/network_base_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/exception_utils.dart';

class MockNetworkService extends Mock implements NetworkService {}

class FakeNetworkRequest extends Fake implements NetworkRequest {}

void main() {
  late NetworkService service;

  final request = NetworkRequest(
    uri: Uri.parse('https://example.com/test'),
    method: HttpMethod.get,
  );

  final successResponse = SuccessNetworkResponse(
    statusCode: 200,
    data: {'message': 'ok'},
  );

  final failResponse = FailNetworkResponse(
    statusCode: 500,
    description: 'Server error',
    failureType: FailureType.unknown,
  );

  setUpAll(() {
    registerFallbackValue(FakeNetworkRequest());
  });

  setUp(() {
    service = MockNetworkService();
  });

  group('NetworkService', () {
    test('sendJsonRequest returns SuccessNetworkResponse', () async {
      when(() => service.sendJsonRequest(request: any(named: 'request')))
          .thenAnswer((_) async => successResponse);

      final result = await service.sendJsonRequest(request: request);

      expect(result, isA<SuccessNetworkResponse>());
      expect((result as SuccessNetworkResponse).statusCode, 200);
      expect(result.data, {'message': 'ok'});
    });

    test('sendJsonRequest returns FailNetworkResponse', () async {
      when(() => service.sendJsonRequest(request: any(named: 'request')))
          .thenAnswer((_) async => failResponse);

      final result = await service.sendJsonRequest(request: request);

      expect(result, isA<FailNetworkResponse>());
      expect((result as FailNetworkResponse).statusCode, 500);
      expect(result.description, 'Server error');
    });
  });
}