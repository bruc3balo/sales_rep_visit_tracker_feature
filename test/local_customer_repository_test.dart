import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/customer/local_customer_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';

class MockLocalCustomerRepository extends Mock implements LocalCustomerRepository {}

class FakeCustomer extends Fake implements Customer {}

void main() {
  late LocalCustomerRepository repository;
  final customer = Customer(id: 1, name: 'John Doe', createdAt: DateTime.now());
  final customerList = [
    Customer(id: 1, name: 'John Doe', createdAt: DateTime.now()),
    Customer(id: 2, name: 'Jane Smith', createdAt: DateTime.now()),
  ];

  setUpAll(() {
    registerFallbackValue(FakeCustomer());
  });

  setUp(() {
    repository = MockLocalCustomerRepository();
  });

  group('LocalCustomerRepository', () {
    test('setLocalCustomer returns success', () async {
      when(() => repository.setLocalCustomer(customer: any(named: 'customer')))
          .thenAnswer((_) async => SuccessResult(data: null));

      final result = await repository.setLocalCustomer(customer: customer);
      expect(result is SuccessResult<void>, true);
    });

    test('setLocalCustomers returns success', () async {
      when(() => repository.setLocalCustomers(customer: any(named: 'customer')))
          .thenAnswer((_) async => SuccessResult(data: null));

      final result = await repository.setLocalCustomers(customer: customerList);
      expect(result is SuccessResult<void>, true);
    });

    test('getLocalCustomers returns success list', () async {
      when(() => repository.getLocalCustomers(
        page: any(named: 'page'),
        pageSize: any(named: 'pageSize'),
      )).thenAnswer((_) async => SuccessResult(data: customerList));

      final result = await repository.getLocalCustomers(page: 0, pageSize: 10);
      expect(result is SuccessResult<List<Customer>>, true);
    });

    test('getLocalCustomersByIds returns success map', () async {
      final map = {1: customer};
      when(() => repository.getLocalCustomersByIds(customerIds: any(named: 'customerIds')))
          .thenAnswer((_) async => SuccessResult(data: map));

      final result = await repository.getLocalCustomersByIds(customerIds: [1]);
      expect(result is SuccessResult<Map<int, Customer>>, true);
    });

    test('deleteLocalCustomer returns success', () async {
      when(() => repository.deleteLocalCustomer(customerId: any(named: 'customerId')))
          .thenAnswer((_) async => SuccessResult(data: null));

      final result = await repository.deleteLocalCustomer(customerId: 1);
      expect(result is SuccessResult<void>, true);
    });

    test('clearLocalCustomers returns success', () async {
      when(() => repository.clearLocalCustomers())
          .thenAnswer((_) async => SuccessResult(data: null));

      final result = await repository.clearLocalCustomers();
      expect(result is SuccessResult<void>, true);
    });

    test('searchLocalCustomers returns success list', () async {
      when(() => repository.searchLocalCustomers(
        page: any(named: 'page'),
        pageSize: any(named: 'pageSize'),
        likeName: any(named: 'likeName'),
      )).thenAnswer((_) async => SuccessResult(data: customerList));

      final result = await repository.searchLocalCustomers(
        page: 1,
        pageSize: 10,
        likeName: 'John',
      );
      expect(result is SuccessResult<List<Customer>>, true);
    });
  });
}