import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain_local_mapper.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/local_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/remote_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/customer/local_customer_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/app_log.dart';

class ViewLocalCustomersUseCase {
  final LocalCustomerRepository _localCustomerRepository;

  ViewLocalCustomersUseCase({
    required LocalCustomerRepository localCustomerRepository,
  }) : _localCustomerRepository = localCustomerRepository;

  Future<TaskResult<List<Customer>>> execute({
    required int page,
    required int pageSize,
  }) async {
    AppLog.I.i(
      "ViewLocalCustomersUseCase",
      "Fetching local customers: page=$page, pageSize=$pageSize",
    );

    var result = await _localCustomerRepository.getLocalCustomers(
      page: page,
      pageSize: pageSize,
    );

    switch (result) {
      case SuccessResult<List<Customer>>():
        AppLog.I.i(
          "ViewLocalCustomersUseCase",
          "${result.data.length} local customers fetched successfully",
        );
      case ErrorResult<List<Customer>>():
        AppLog.I.e(
          "ViewLocalCustomersUseCase",
          "Failed to fetch local customers: ${result.error}",
          trace: result.trace,
        );
    }

    return result;
  }
}