import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/connectivity/connectivity_service.dart';

class MockConnectivityService extends Mock implements ConnectivityService {}

void main() {
  late ConnectivityService service;
  late StreamController<bool> controller;

  setUp(() {
    service = MockConnectivityService();
    controller = StreamController<bool>();
  });

  tearDown(() {
    controller.close();
  });

  group('ConnectivityService', () {
    test('hasInternetConnection returns true', () async {

      when(() => service.hasInternetConnection())
          .thenAnswer((_) async => true);

      final result = await service.hasInternetConnection();
      expect(result, true);
    });

    test('onConnectionChange emits true and false', () async {
      when(() => service.onConnectionChange)
          .thenAnswer((_) => controller.stream);

      final results = <bool>[];
      final sub = service.onConnectionChange.listen(results.add);

      controller.add(true);
      controller.add(false);

      await Future.delayed(Duration.zero); // allow event loop to flush
      expect(results, [true, false]);

      await sub.cancel();
    });

    test('lastResult returns true', () {
      when(() => service.lastResult).thenReturn(true);

      final result = service.lastResult;
      expect(result, true);
    });
  });
}