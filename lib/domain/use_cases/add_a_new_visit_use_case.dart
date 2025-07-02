import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain_local_mapper.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/activity/local_activity_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/customer/local_customer_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/visit/local_unsynced_visit_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/visit/remote_visit_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/exception_utils.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/extensions.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';

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
  }) : _visitRepository = visitRepository,
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

   var result =  await _visitRepository.createVisit(
      customerIdVisited: customer.id,
      visitDate: visitDate,
      status: status,
      location: location,
      notes: notes,
      activityIdsDone: activitiesDone.map((a) => a.id).toList(),
    );

   switch(result) {

     case ErrorResult<void>():

       //Store offline if error is no internet
       if(FailureType.noInternet == result.failure) {
         //Offline storage
         var localSaveResult = await _localUnsyncedVisitRepository
             .setUnsyncedVisit(
           visit: UnSyncedLocalVisit(
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
             return ErrorResult(
               error: localSaveResult.error,
               trace: localSaveResult.trace,
             );
           case SuccessResult<void>():
           //Cache activity and customer for offline resolution async
             _localActivityRepository.setLocalActivities(
                 activities: activitiesDone.map((a) => a.toLocal).toList()
             );

             _localCustomerRepository.setLocalCustomer(
                 customer: customer.toLocal
             );

             return SuccessResult(data: null,
                 message: "Visit created offline, will be synced later");
         }
       }

       return ErrorResult(
           error: result.error,
           trace: result.trace,
           failure: result.failure,
       );
     case SuccessResult<void>():
       return result;
   }

  }
}
