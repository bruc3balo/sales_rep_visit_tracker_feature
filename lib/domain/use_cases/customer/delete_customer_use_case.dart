import 'package:sales_rep_visit_tracker_feature/data/repositories/customer/local_customer_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/customer/remote_customer_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/app_log.dart';

class DeleteCustomerUseCase {
  final RemoteCustomerRepository _remoteCustomerRepository;
  final LocalCustomerRepository _localCustomerRepository;

  DeleteCustomerUseCase({
    required RemoteCustomerRepository remoteCustomerRepository,
    required LocalCustomerRepository localCustomerRepository,
  })  : _remoteCustomerRepository = remoteCustomerRepository,
        _localCustomerRepository = localCustomerRepository;

  Future<TaskResult<void>> execute({required int customerId}) async {
    AppLog.I.i(
      "DeleteCustomerUseCase",
      "Attempting to delete customer with ID: $customerId",
    );

    var deleteResult = await _remoteCustomerRepository.deleteCustomerById(
      customerId: customerId,
    );

    switch (deleteResult) {
      case ErrorResult<void>():
        AppLog.I.e(
          "DeleteCustomerUseCase",
          "Failed to delete customer: ${deleteResult.error}",
          trace: deleteResult.trace,
        );
        return ErrorResult(
          error: deleteResult.error,
          failure: deleteResult.failure,
          trace: deleteResult.trace,
        );

      case SuccessResult<void>():
        AppLog.I.i(
          "DeleteCustomerUseCase",
          "Customer deleted remotely. Removing from local cache...",
        );
        _localCustomerRepository.deleteLocalCustomer(customerId: customerId);
        return deleteResult;
    }
  }
}