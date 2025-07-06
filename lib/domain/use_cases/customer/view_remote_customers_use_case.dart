import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain_local_mapper.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/local_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/remote_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/customer/local_customer_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/customer/remote_customer_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/app_log.dart';

class ViewRemoteCustomersUseCase {
  final RemoteCustomerRepository _remoteCustomerRepository;
  final LocalCustomerRepository _localCustomerRepository;

  ViewRemoteCustomersUseCase({
    required RemoteCustomerRepository remoteCustomerRepository,
    required LocalCustomerRepository localCustomerRepository,
  })  : _remoteCustomerRepository = remoteCustomerRepository,
        _localCustomerRepository = localCustomerRepository;

  Future<TaskResult<List<Customer>>> execute({
    List<int>? ids,
    String? likeName,
    String? equalName,
    required int page,
    required int pageSize,
    String? order,
  }) async {
    AppLog.I.i(
      "ViewRemoteCustomersUseCase",
      "Fetching remote customers with filters: ids=$ids, likeName=$likeName, equalName=$equalName, page=$page, pageSize=$pageSize, order=$order",
    );

    var getActivitiesResult = await _remoteCustomerRepository.getCustomers(
      ids: ids,
      page: page,
      pageSize: pageSize,
      likeName: likeName,
      equalName: equalName,
      order: order,
    );

    switch (getActivitiesResult) {
      case SuccessResult<List<Customer>>():
        AppLog.I.i(
          "ViewRemoteCustomersUseCase",
          "Fetched ${getActivitiesResult.data.length} remote customers. Caching locally.",
        );
        _localCustomerRepository.setLocalCustomers(
          customer: getActivitiesResult.data,
        );
      case ErrorResult<List<Customer>>():
        AppLog.I.e(
          "ViewRemoteCustomersUseCase",
          "Failed to fetch remote customers: ${getActivitiesResult.error}",
          trace: getActivitiesResult.trace,
        );
    }

    return getActivitiesResult;
  }
}