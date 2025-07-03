import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain_local_mapper.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/local_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/remote_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/customer/local_customer_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/customer/remote_customer_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';

class ViewRemoteCustomersUseCase {
  final RemoteCustomerRepository _remoteCustomerRepository;
  final LocalCustomerRepository _localCustomerRepository;

  ViewRemoteCustomersUseCase({
    required RemoteCustomerRepository remoteCustomerRepository,
    required LocalCustomerRepository localCustomerRepository,
  }): _remoteCustomerRepository = remoteCustomerRepository,
        _localCustomerRepository = localCustomerRepository;

  Future<TaskResult<List<Customer>>> execute({
    List<int>? ids,
    String? likeName,
    String? equalName,
    required int page,
    required int pageSize,
    String? order,
  }) async {
    var getActivitiesResult = await _remoteCustomerRepository.getCustomers(
      ids: ids,
      page: page,
      pageSize: pageSize,
      likeName: likeName,
      equalName: equalName,
      order: order,
    );

    //Cache activities async
    if (getActivitiesResult is SuccessResult<List<Customer>>) {
      _localCustomerRepository.setLocalCustomers(
        customer: getActivitiesResult.data,
      );
    }

    return getActivitiesResult;
  }
}
