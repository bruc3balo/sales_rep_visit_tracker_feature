import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain_local_mapper.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/local_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/remote_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/customer/local_customer_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/customer/remote_customer_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/app_log.dart';

class UpdateCustomerUseCase {
  final RemoteCustomerRepository _remoteCustomerRepository;
  final LocalCustomerRepository _localCustomerRepository;

  UpdateCustomerUseCase({
    required RemoteCustomerRepository remoteCustomerRepository,
    required LocalCustomerRepository localCustomerRepository,
  })  : _remoteCustomerRepository = remoteCustomerRepository,
        _localCustomerRepository = localCustomerRepository;

  Future<TaskResult<Customer>> execute({
    required int customerId,
    String? name,
  }) async {
    AppLog.I.i(
      "UpdateCustomerUseCase",
      "Updating remote customer: id=$customerId, name=$name",
    );

    var createResult = await _remoteCustomerRepository.updateCustomer(
      customerId: customerId,
      name: name,
    );

    switch (createResult) {
      case ErrorResult<void>():
        AppLog.I.e(
          "UpdateCustomerUseCase",
          "Remote customer update failed: ${createResult.error}",
          trace: createResult.trace,
        );
        return ErrorResult(
          error: createResult.error,
          failure: createResult.failure,
          trace: createResult.trace,
        );

      case SuccessResult<void>():
        AppLog.I.i(
          "UpdateCustomerUseCase",
          "Remote customer update successful, fetching updated customer",
        );
        var fetchUpdatedActivity = await _remoteCustomerRepository.getCustomers(
          ids: [customerId],
          pageSize: 1,
          page: 0,
        );
        switch (fetchUpdatedActivity) {
          case ErrorResult<List<Customer>>():
            AppLog.I.e(
              "UpdateCustomerUseCase",
              "Failed to fetch updated customer after update: ${fetchUpdatedActivity.error}",
              trace: fetchUpdatedActivity.trace,
            );
            return ErrorResult(
              error: fetchUpdatedActivity.error,
              trace: fetchUpdatedActivity.trace,
              failure: fetchUpdatedActivity.failure,
            );

          case SuccessResult<List<Customer>>():
            var data = fetchUpdatedActivity.data.first;
            AppLog.I.i(
              "UpdateCustomerUseCase",
              "Fetched updated customer: ${data.id} - ${data.name}, caching locally",
            );

            _localCustomerRepository.setLocalCustomer(customer: data);

            return SuccessResult(data: data, message: "Customer updated");
        }
    }
  }
}