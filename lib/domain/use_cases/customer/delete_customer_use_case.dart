import 'package:sales_rep_visit_tracker_feature/data/repositories/customer/local_customer_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/customer/remote_customer_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';

class DeleteCustomerUseCase {
  final RemoteCustomerRepository _remoteCustomerRepository;
  final LocalCustomerRepository _localCustomerRepository;

  DeleteCustomerUseCase({
    required RemoteCustomerRepository remoteCustomerRepository,
    required LocalCustomerRepository localCustomerRepository,
  }) : _remoteCustomerRepository = remoteCustomerRepository,
        _localCustomerRepository = localCustomerRepository;


  Future<TaskResult<void>> execute({required int customerId}) async {

    var deleteResult = await _remoteCustomerRepository.deleteCustomerById(
      customerId: customerId,
    );

    switch(deleteResult) {

      case ErrorResult<void>():
        return ErrorResult(
            error: deleteResult.error,
            failure: deleteResult.failure,
            trace: deleteResult.trace,
        );
      case SuccessResult<void>():
        _localCustomerRepository.deleteLocalCustomer(customerId: customerId);
        return deleteResult;
    }

  }
}