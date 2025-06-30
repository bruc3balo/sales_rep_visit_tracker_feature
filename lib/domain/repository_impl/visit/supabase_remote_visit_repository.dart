import 'dart:io';

import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain_remote_mapper.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/local/local_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/remote/remote_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/repositories/visit/remote_visit_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/local_database/local_database_service.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/networking/apis/visit/visit_supabase_repository.dart';
import 'package:sales_rep_visit_tracker_feature/data/services/networking/src/network_base_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/exception_utils.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';

class SupabaseVisitRepository implements RemoteVisitRepository {
  final SupabaseVisitApi _visitApi;
  final LocalDatabaseService _localDatabaseService;

  SupabaseVisitRepository({
    required SupabaseVisitApi visitApi,
    required LocalDatabaseService localDatabaseService,
  }) : _visitApi = visitApi, _localDatabaseService = localDatabaseService;

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
    try {
      var newVisitResponse = await _visitApi.sendAddVisitRequest(
        customerId: customerIdVisited,
        visitDate: visitDate,
        status: status.capitalize,
        location: location,
        notes: notes,
        activityIdsDone: activityIdsDone,
        createdAt: createdAt ?? DateTime.now(),
      );

      switch (newVisitResponse) {
        case FailNetworkResponse():
          return ErrorResult(
            error: newVisitResponse.description,
            trace: newVisitResponse.trace,
          );
        case SuccessNetworkResponse():
          //TODO: Refresh visits for newly created visit
          return SuccessResult(data: null, message: "Visit created");
      }
    } on SocketException catch(e, trace) {

      return ErrorResult(
        error: e.toString(),
        trace: trace,
        failure: FailureType.noInternet,
      );


    }
  }

  @override
  Future<TaskResult<void>> deleteVisitById({required int visitId}) async {
    var deletedVisit = await _visitApi.sendDeleteVisitRequest(visitId: visitId);
    switch (deletedVisit) {
      case FailNetworkResponse():
        return ErrorResult(
          error: deletedVisit.description,
          trace: deletedVisit.trace,
        );
      case SuccessNetworkResponse():
        return SuccessResult(
          data: null,
          message: "Visit deleted",
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
    var updatedVisitResponse = await _visitApi.sendUpdateVisitRequest(
      visitId: visitId,
      customerId: customerId,
      visitDate: visitDate,
      status: status?.capitalize,
      location: location,
      notes: notes,
      activityIdsDone: activityIdsDone,
    );

    switch (updatedVisitResponse) {
      case FailNetworkResponse():
        return ErrorResult(
          error: updatedVisitResponse.description,
          trace: updatedVisitResponse.trace,
        );
      case SuccessNetworkResponse():
        var getUpdatedVisitResponse = await _visitApi.sendGetVisitsRequest(
          visitId: visitId,
          page: 0,
          pageSize: 1,
        );

        switch (getUpdatedVisitResponse) {
          case FailNetworkResponse():
            return ErrorResult(
              error: getUpdatedVisitResponse.description,
              trace: getUpdatedVisitResponse.trace,
            );
          case SuccessNetworkResponse():
            var data = (getUpdatedVisitResponse.data as List<dynamic>).map((e) => RemoteVisit.fromJson(e)).first;
            return SuccessResult(data: data.toDomain, message: "Visit updated");
        }
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
    var getVisitResponse = await _visitApi.sendGetVisitsRequest(
      customerId: customerId,
      fromDateInclusive: fromDateInclusive,
      toDateInclusive: toDateInclusive,
      activityIdsDone: activityIdsDone,
      status: status?.capitalize,
      page: page,
      pageSize: pageSize,
      order: order,
    );

    switch (getVisitResponse) {
      case FailNetworkResponse():
        return ErrorResult(
          error: getVisitResponse.description,
          trace: getVisitResponse.trace,
        );
      case SuccessNetworkResponse():
        var data = (getVisitResponse.data as List<dynamic>).map((e) => RemoteVisit.fromJson(e).toDomain).toList();
        return SuccessResult(
          message: "${data.length} visits found",
          data: data,
        );
    }
  }


}
