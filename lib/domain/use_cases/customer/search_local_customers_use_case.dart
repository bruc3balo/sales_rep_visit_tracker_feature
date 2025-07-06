import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain_local_mapper.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/local_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/remote_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/customer/local_customer_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/app_log.dart';

class SearchLocalCustomersUseCase {
  final LocalCustomerRepository _localCustomerRepository;

  SearchLocalCustomersUseCase({
    required LocalCustomerRepository localCustomerRepository,
  }) : _localCustomerRepository = localCustomerRepository;

  Future<TaskResult<List<Customer>>> execute({
    String? likeName,
    required int page,
    required int pageSize,
  }) async {
    AppLog.I.i(
      "SearchLocalCustomersUseCase",
      "Executing search: likeName=$likeName, page=$page, pageSize=$pageSize",
    );

    if (likeName == null) {
      AppLog.I.i("SearchLocalCustomersUseCase", "Fetching all local customers.");
      return await _localCustomerRepository.getLocalCustomers(
        page: page,
        pageSize: pageSize,
      );
    }

    AppLog.I.i("SearchLocalCustomersUseCase", "Searching local customers with name like '$likeName'");
    return await _localCustomerRepository.searchLocalCustomers(
      page: page,
      pageSize: pageSize,
      likeName: likeName,
    );
  }
}