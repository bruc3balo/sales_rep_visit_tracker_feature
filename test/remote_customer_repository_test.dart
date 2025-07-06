import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/customer/remote_customer_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';

class MockRemoteCustomerRepository extends Mock implements RemoteCustomerRepository {}

class FakeCustomer extends Fake implements Customer {}

void main() {
  late RemoteCustomerRepository repository;
  final customer = Customer(id: 1, name: 'John Doe', createdAt: DateTime.now());
  final customerList = [
    Customer(id: 1, name: 'John Doe', createdAt: DateTime.now()),
    Customer(id: 2, name: 'Jane Smith', createdAt: DateTime.now()),
  ];

  setUpAll(() {
    registerFallbackValue(FakeCustomer());
  });

  setUp(() {
    repository = MockRemoteCustomerRepository();
  });

  group('RemoteCustomerRepository', () {
    test('createCustomer returns success', () async {
      when(() => repository.createCustomer(name: any(named: 'name')))
          .thenAnswer((_) async => SuccessResult(data: null));

      final result = await repository.createCustomer(name: 'New Customer');
      expect(result is SuccessResult<void>, true);
    });

    test('getCustomers returns success list', () async {
      when(() => repository.getCustomers(
        ids: any(named: 'ids'),
        equalName: any(named: 'equalName'),
        likeName: any(named: 'likeName'),
        page: any(named: 'page'),
        pageSize: any(named: 'pageSize'),
        order: any(named: 'order'),
      )).thenAnswer((_) async => SuccessResult(data: customerList));

      final result = await repository.getCustomers(
        ids: [1],
        equalName: null,
        likeName: 'John',
        page: 0,
        pageSize: 10,
        order: 'desc',
      );

      expect(result is SuccessResult<List<Customer>>, true);
    });

    test('updateCustomer returns success', () async {
      when(() => repository.updateCustomer(
        customerId: any(named: 'customerId'),
        name: any(named: 'name'),
      )).thenAnswer((_) async => SuccessResult(data: null));

      final result = await repository.updateCustomer(
        customerId: 1,
        name: 'Updated Name',
      );

      expect(result is SuccessResult<void>, true);
    });

    test('deleteCustomerById returns success', () async {
      when(() => repository.deleteCustomerById(customerId: any(named: 'customerId')))
          .thenAnswer((_) async => SuccessResult(data: null));

      final result = await repository.deleteCustomerById(customerId: 1);
      expect(result is SuccessResult<void>, true);
    });
  });
}