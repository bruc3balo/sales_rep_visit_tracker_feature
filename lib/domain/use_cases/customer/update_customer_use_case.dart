
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain_local_mapper.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/local_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/remote_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/customer/local_customer_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/customer/remote_customer_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';

class UpdateCustomerUseCase {
  final RemoteCustomerRepository _remoteCustomerRepository;
  final LocalCustomerRepository _localCustomerRepository;

  UpdateCustomerUseCase({
    required RemoteCustomerRepository remoteCustomerRepository,
    required LocalCustomerRepository localCustomerRepository,
  }) : _remoteCustomerRepository = remoteCustomerRepository,
        _localCustomerRepository = localCustomerRepository;


  Future<TaskResult<Customer>> execute({
    required int customerId,
    String? name,
  }) async {

    var createResult = await _remoteCustomerRepository.updateCustomer(
      customerId: customerId,
      name: name,
    );

    switch(createResult) {

      case ErrorResult<void>():
        return ErrorResult(
            error: createResult.error,
            failure: createResult.failure,
            trace: createResult.trace,
        );
      case SuccessResult<void>():
        var fetchUpdatedActivity = await _remoteCustomerRepository.getCustomers(
          ids: [customerId],
          pageSize: 1,
          page: 0,
        );
        switch (fetchUpdatedActivity) {
          case ErrorResult<List<Customer>>():
            return ErrorResult(
              error: fetchUpdatedActivity.error,
              trace: fetchUpdatedActivity.trace,
              failure: fetchUpdatedActivity.failure,
            );

          case SuccessResult<List<Customer>>():
            var data = fetchUpdatedActivity.data.first;

            //Cache activity async
            _localCustomerRepository.setLocalCustomer(customer: data);

            return SuccessResult(data: data, message: "Customer updated");

        }
    }



  }
}