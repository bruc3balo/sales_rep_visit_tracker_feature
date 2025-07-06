import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/local_database/local_customer_crud.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';

class MockLocalCustomerCrud extends Mock implements LocalCustomerCrud {}

class FakeLocalCustomer extends Fake implements LocalCustomer {}

void main() {
  late LocalCustomerCrud crud;
  final customer = LocalCustomer(
    id: 1,
    name: 'Test Customer',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
  final customerList = [
    LocalCustomer(
      id: 1,
      name: 'Customer 1',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    LocalCustomer(
      id: 2,
      name: 'Customer 2',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];
  final customerMap = {1: customer};

  setUpAll(() {
    registerFallbackValue(FakeLocalCustomer());
  });

  setUp(() {
    crud = MockLocalCustomerCrud();
  });

  group('LocalCustomerCrud', () {
    test('setLocalCustomer returns success', () async {
      when(() => crud.setLocalCustomer(customer: any(named: 'customer'))).thenAnswer((_) async => SuccessResult(data: null));

      final result = await crud.setLocalCustomer(customer: customer);
      expect(result is SuccessResult<void>, true);
    });

    test('setLocalCustomers returns success', () async {
      when(() => crud.setLocalCustomers(customers: any(named: 'customers'))).thenAnswer((_) async => SuccessResult(data: null));

      final result = await crud.setLocalCustomers(customers: customerList);
      expect(result is SuccessResult<void>, true);
    });

    test('getLocalCustomers returns list', () async {
      when(() => crud.getLocalCustomers(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenAnswer((_) async => SuccessResult(data: customerList));

      final result = await crud.getLocalCustomers(page: 0, pageSize: 10);
      expect(result is SuccessResult<List<LocalCustomer>>, true);
    });

    test('searchLocalCustomers returns filtered list', () async {
      when(() => crud.searchLocalCustomers(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
            likeName: any(named: 'likeName'),
          )).thenAnswer((_) async => SuccessResult(data: customerList));

      final result = await crud.searchLocalCustomers(
        page: 0,
        pageSize: 10,
        likeName: 'Test',
      );
      expect(result is SuccessResult<List<LocalCustomer>>, true);
    });

    test('getLocalCustomerByIds returns customer map', () async {
      when(() => crud.getLocalCustomerByIds(ids: any(named: 'ids'))).thenAnswer((_) async => SuccessResult(data: customerMap));

      final result = await crud.getLocalCustomerByIds(ids: [1]);
      expect(result is SuccessResult<Map<int, LocalCustomer>>, true);
    });

    test('deleteLocalCustomer returns success', () async {
      when(() => crud.deleteLocalCustomer(customerId: any(named: 'customerId'))).thenAnswer((_) async => SuccessResult(data: null));

      final result = await crud.deleteLocalCustomer(customerId: 1);
      expect(result is SuccessResult<void>, true);
    });

    test('clearAllLocalCustomers returns success', () async {
      when(() => crud.clearAllLocalCustomers()).thenAnswer((_) async => SuccessResult(data: null));

      final result = await crud.clearAllLocalCustomers();
      expect(result is SuccessResult<void>, true);
    });
  });
}
