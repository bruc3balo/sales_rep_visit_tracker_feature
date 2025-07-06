import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain_local_mapper.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/customer/local_customer_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/customer/remote_customer_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/app_log.dart';

class CreateCustomerUseCase {
  final RemoteCustomerRepository _remoteCustomerRepository;
  final LocalCustomerRepository _localCustomerRepository;

  CreateCustomerUseCase({
    required RemoteCustomerRepository remoteCustomerRepository,
    required LocalCustomerRepository localCustomerRepository,
  })  : _remoteCustomerRepository = remoteCustomerRepository,
        _localCustomerRepository = localCustomerRepository;

  Future<TaskResult<Customer>> execute({required String name}) async {
    AppLog.I.i(
      "CreateCustomerUseCase",
      "Creating customer with name: $name",
    );

    var createResult = await _remoteCustomerRepository.createCustomer(name: name);

    switch (createResult) {
      case ErrorResult<void>():
        AppLog.I.e(
          "CreateCustomerUseCase",
          "Failed to create customer: ${createResult.error}",
          trace: createResult.trace,
        );
        return ErrorResult(
          error: createResult.error,
          failure: createResult.failure,
          trace: createResult.trace,
        );

      case SuccessResult<void>():
        AppLog.I.i(
          "CreateCustomerUseCase",
          "Customer created remotely. Fetching for confirmation...",
        );

        var fetchCreatedCustomer = await _remoteCustomerRepository.getCustomers(
          equalName: name,
          pageSize: 1,
          page: 0,
        );

        switch (fetchCreatedCustomer) {
          case ErrorResult<List<Customer>>():
            AppLog.I.e(
              "CreateCustomerUseCase",
              "Failed to fetch created customer: ${fetchCreatedCustomer.error}",
              trace: fetchCreatedCustomer.trace,
            );
            return ErrorResult(
              error: fetchCreatedCustomer.error,
              trace: fetchCreatedCustomer.trace,
              failure: fetchCreatedCustomer.failure,
            );

          case SuccessResult<List<Customer>>():
            var data = fetchCreatedCustomer.data.first;

            AppLog.I.i(
              "CreateCustomerUseCase",
              "Fetched customer with id=${data.id}. Caching locally...",
            );

            _localCustomerRepository.setLocalCustomer(customer: data);

            return SuccessResult(data: data, message: "Customer created");
        }
    }
  }
}