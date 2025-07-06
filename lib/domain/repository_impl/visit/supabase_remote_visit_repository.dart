import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain_remote_mapper.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/remote/remote_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/visit/remote_visit_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/networking/apis/visit/visit_supabase_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/networking/src/network_base_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/exception_utils.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/extensions.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/app_log.dart';

class SupabaseVisitRepository implements RemoteVisitRepository {
  final SupabaseVisitApi _visitApi;
  static const _tag = 'SupabaseVisitRepository';

  SupabaseVisitRepository({
    required SupabaseVisitApi visitApi,
  }) : _visitApi = visitApi;

  @override
  Future<TaskResult<void>> createVisit({
    required int customerIdVisited,
    required DateTime visitDate,
    required VisitStatus status,
    required String location,
    required String notes,
    required List<int> activityIdsDone,
    DateTime? createdAt,
  }) async {
    AppLog.I.i(_tag, "createVisit: customerId=$customerIdVisited, date=$visitDate, status=$status");

    try {
      var newVisitResponse = await _visitApi.sendAddVisitRequest(
        customerId: customerIdVisited,
        visitDate: visitDate,
        status: status.name.capitalize,
        location: location,
        notes: notes,
        activityIdsDone: activityIdsDone,
        createdAt: createdAt ?? DateTime.now(),
      );

      switch (newVisitResponse) {
        case FailNetworkResponse():
          AppLog.I.e(_tag, "Failed to create visit", error: newVisitResponse.description, trace: newVisitResponse.trace);
          return ErrorResult(
            error: newVisitResponse.description,
            trace: newVisitResponse.trace,
            failure: newVisitResponse.failureType,
          );
        case SuccessNetworkResponse():
          AppLog.I.i(_tag, "Visit created successfully");
          return SuccessResult(data: null, message: "Visit created");
      }
    } catch (e, trace) {
      AppLog.I.e(_tag, "Exception in createVisit", error: e, trace: trace);
      return ErrorResult(
        error: e.toString(),
        trace: trace,
        failure: FailureType.unknown,
      );
    }
  }

  @override
  Future<TaskResult<void>> deleteVisitById({required int visitId}) async {
    AppLog.I.i(_tag, "deleteVisitById: visitId=$visitId");

    try {
      var deletedVisit = await _visitApi.sendDeleteVisitRequest(visitId: visitId);

      switch (deletedVisit) {
        case FailNetworkResponse():
          AppLog.I.e(_tag, "Failed to delete visit", error: deletedVisit.description, trace: deletedVisit.trace);
          return ErrorResult(
            error: deletedVisit.description,
            trace: deletedVisit.trace,
          );
        case SuccessNetworkResponse():
          AppLog.I.i(_tag, "Visit deleted successfully");
          return SuccessResult(data: null, message: "Visit deleted");
      }
    } catch (e, trace) {
      AppLog.I.e(_tag, "Exception in deleteVisitById", error: e, trace: trace);
      return ErrorResult(
        error: e.toString(),
        trace: trace,
        failure: FailureType.unknown,
      );
    }
  }

  @override
  Future<TaskResult<Visit>> updateVisit({
    required int visitId,
    int? customerId,
    DateTime? visitDate,
    VisitStatus? status,
    String? location,
    String? notes,
    List<int>? activityIdsDone,
  }) async {
    AppLog.I.i(_tag, "updateVisit: visitId=$visitId");

    try {
      var updatedVisitResponse = await _visitApi.sendUpdateVisitRequest(
        visitId: visitId,
        customerId: customerId,
        visitDate: visitDate,
        status: status?.name.capitalize,
        location: location,
        notes: notes,
        activityIdsDone: activityIdsDone,
      );

      switch (updatedVisitResponse) {
        case FailNetworkResponse():
          AppLog.I.e(_tag, "Failed to update visit", error: updatedVisitResponse.description, trace: updatedVisitResponse.trace);
          return ErrorResult(
            error: updatedVisitResponse.description,
            trace: updatedVisitResponse.trace,
          );

        case SuccessNetworkResponse():
          AppLog.I.i(_tag, "Visit update API success, fetching updated visit");

          var getUpdatedVisitResponse = await _visitApi.sendGetVisitsRequest(
            visitId: visitId,
            page: 0,
            pageSize: 1,
          );

          switch (getUpdatedVisitResponse) {
            case FailNetworkResponse():
              AppLog.I.e(_tag, "Failed to fetch updated visit", error: getUpdatedVisitResponse.description, trace: getUpdatedVisitResponse.trace);
              return ErrorResult(
                error: getUpdatedVisitResponse.description,
                trace: getUpdatedVisitResponse.trace,
              );
            case SuccessNetworkResponse():
              var data = (getUpdatedVisitResponse.data as List<dynamic>)
                  .map((e) => RemoteVisit.fromJson(e))
                  .first;

              AppLog.I.i(_tag, "Fetched updated visit successfully");
              return SuccessResult(data: data.toDomain, message: "Visit updated");
          }
      }
    } catch (e, trace) {
      AppLog.I.e(_tag, "Exception in updateVisit", error: e, trace: trace);
      return ErrorResult(
        error: e.toString(),
        trace: trace,
        failure: FailureType.unknown,
      );
    }
  }

  @override
  Future<TaskResult<List<Visit>>> getVisits({
    int? customerId,
    DateTime? fromDateInclusive,
    DateTime? toDateInclusive,
    List<int>? activityIdsDone,
    VisitStatus? status,
    required int page,
    required int pageSize,
    String? order,
  }) async {
    AppLog.I.i(_tag, "getVisits(page=$page, pageSize=$pageSize)");

    try {
      var getVisitResponse = await _visitApi.sendGetVisitsRequest(
        customerId: customerId,
        fromDateInclusive: fromDateInclusive,
        toDateInclusive: toDateInclusive,
        activityIdsDone: activityIdsDone,
        status: status?.name.capitalize,
        page: page,
        pageSize: pageSize,
        order: order,
      );

      switch (getVisitResponse) {
        case FailNetworkResponse():
          AppLog.I.e(_tag, "Failed to fetch visits", error: getVisitResponse.description, trace: getVisitResponse.trace);
          return ErrorResult(
            error: getVisitResponse.description,
            trace: getVisitResponse.trace,
            failure: getVisitResponse.failureType,
          );
        case SuccessNetworkResponse():
          var data = (getVisitResponse.data as List<dynamic>)
              .map((e) => RemoteVisit.fromJson(e).toDomain)
              .toList();

          AppLog.I.i(_tag, "${data.length} visits found");
          return SuccessResult(message: "${data.length} visits found", data: data);
      }
    } catch (e, trace) {
      AppLog.I.e(_tag, "Exception in getVisits", error: e, trace: trace);
      return ErrorResult(
        error: e.toString(),
        trace: trace,
        failure: FailureType.unknown,
      );
    }
  }
}