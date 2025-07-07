import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain_local_mapper.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/local_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/customer/local_customer_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/visit/local_unsynced_visit_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/visit/remote_visit_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/exception_utils.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/extensions.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/random_gen.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/app_log.dart';

class AddANewVisitUseCase {
  final RemoteVisitRepository _visitRepository;
  final LocalUnsyncedVisitRepository _localUnsyncedVisitRepository;
  final LocalCustomerRepository _localCustomerRepository;
  final LocalActivityRepository _localActivityRepository;

  AddANewVisitUseCase({
    required RemoteVisitRepository visitRepository,
    required LocalUnsyncedVisitRepository localUnsyncedVisitRepository,
    required LocalCustomerRepository localCustomerRepository,
    required LocalActivityRepository localActivityRepository,
  })  : _visitRepository = visitRepository,
        _localUnsyncedVisitRepository = localUnsyncedVisitRepository,
        _localCustomerRepository = localCustomerRepository,
        _localActivityRepository = localActivityRepository;

  Future<TaskResult<void>> execute({
    required Customer customer,
    required DateTime visitDate,
    required VisitStatus status,
    required String location,
    required String notes,
    required List<Activity> activitiesDone,
  }) async {
    AppLog.I.i(
      "AddANewVisitUseCase",
      "Creating visit for customer ${customer.id} with ${activitiesDone.length} activities",
    );

    var result = await _visitRepository.createVisit(
      customerIdVisited: customer.id,
      visitDate: visitDate,
      status: status,
      location: location,
      notes: notes,
      activityIdsDone: activitiesDone.map((a) => a.id).toList(),
    );

    switch (result) {
      case ErrorResult<void>():
        AppLog.I.e(
          "AddANewVisitUseCase",
          "Remote visit creation failed. FailureType: ${result.failure}, Error: ${result.error}",
          trace: result.trace,
        );

        // Store offline if error is no internet
        if (FailureType.network == result.failure) {
          var key = generateHash(
            customerIdVisited: customer.id,
            visitDate: visitDate,
            status: status.name.capitalize,
            location: location,
            notes: notes,
            activityIdsDone: activitiesDone.map((a) => a.id).toList(),
          );

          AppLog.I.i(
            "AddANewVisitUseCase",
            "Storing visit offline with hash ${key.value}",
          );


          var localSaveResult = await _localUnsyncedVisitRepository.setUnsyncedVisit(
            visit: UnSyncedLocalVisit(
              key: generateRandomKey(15),
              hash: key.value,
              customerIdVisited: customer.id,
              visitDate: visitDate,
              status: status.name.capitalize,
              location: location,
              notes: notes,
              activityIdsDone: activitiesDone.map((a) => a.id).toList(),
              createdAt: DateTime.now(),
            ),
          );

          switch (localSaveResult) {
            case ErrorResult<void>():
              AppLog.I.e(
                "AddANewVisitUseCase",
                "Failed to save unsynced visit locally: ${localSaveResult.error}",
                trace: localSaveResult.trace,
              );
              return ErrorResult(
                error: localSaveResult.error,
                trace: localSaveResult.trace,
              );
            case SuccessResult<void>():
              AppLog.I.i(
                "AddANewVisitUseCase",
                "Visit saved offline successfully. Caching activities and customer.",
              );
              _localActivityRepository.setLocalActivities(activities: activitiesDone);
              _localCustomerRepository.setLocalCustomer(customer: customer);
              return SuccessResult(data: null, message: "Visit created offline, will be synced later");
          }
        }

        return ErrorResult(
          error: result.error,
          trace: result.trace,
          failure: result.failure,
        );

      case SuccessResult<void>():
        AppLog.I.i(
          "AddANewVisitUseCase",
          "Visit successfully created remotely",
        );
        return result;
    }
  }
}