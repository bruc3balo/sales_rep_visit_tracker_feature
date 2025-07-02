import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain_local_mapper.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/local_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/remote_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/customer/local_customer_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/customer/remote_customer_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';

class SearchRemoteCustomerUseCase {

  final RemoteCustomerRepository _remoteCustomerRepository;
  final LocalCustomerRepository _localCustomerRepository;

  SearchRemoteCustomerUseCase({
    required RemoteCustomerRepository remoteCustomerRepository,
    required LocalCustomerRepository localCustomerRepository,
  }) : _remoteCustomerRepository = remoteCustomerRepository,
        _localCustomerRepository = localCustomerRepository;

  Future<TaskResult<List<Customer>>> execute({
    required String likeName,
    required int page,
    required int pageSize,
}) async {

    var searchResult = await _remoteCustomerRepository.getCustomers(
      page: page,
      pageSize: pageSize,
      likeName: likeName,
    );

    //cache activities async
    if(searchResult is SuccessResult<List<Customer>>) {
      _localCustomerRepository.setLocalCustomers(
        customer: searchResult.data.map((a) => a.toLocal).toList(),
      );
    }

    return searchResult;
  }

}