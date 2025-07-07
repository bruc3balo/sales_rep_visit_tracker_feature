import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sales_rep_visit_tracker_feature/data/models/domain/domain_models.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/task_result.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/domain/use_cases/visit/add_a_new_visit_use_case.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/core/ui/components/global_toast_message.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/add_visit/model/add_form_storage.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/add_visit/model/add_visit_models.dart';

class AddVisitViewModel extends ChangeNotifier {
  final AddANewVisitUseCase _addANewVisitUseCase;
  AddVisitState _state = DraftingAddVisitState();
  AddVisitForm _form = AddVisitForm(activities: []);

  AddVisitViewModel({
    required AddANewVisitUseCase addANewVisitUseCase,
  }) : _addANewVisitUseCase = addANewVisitUseCase {
    _loadFromDraft();
  }

  AddVisitState get state => _state;

  AddVisitForm get form => _form;

  bool get isValid {
    if (_form.visitDate == null) return false;
    if (_form.customer == null) return false;
    if (_form.status == null) return false;

    final location = _form.location;
    if (location == null || location.isEmpty) return false;

    final notes = _form.notes;
    if (notes == null || notes.isEmpty) return false;

    return true;
  }

  Future<void> _loadFromDraft() async {
    var loadedForm = await AddVisitFormStorage().loadForm();
    if (loadedForm == null) return;

    _form = loadedForm;
    notifyListeners();
  }

  Future<void> saveFormToDraft() async {
    await AddVisitFormStorage().saveForm(_form);
  }

  Future<void> clearDraft() async {
    await AddVisitFormStorage().clearForm();
  }

  void updateVisitForm({
    required AddVisitForm form,
  }) async {
    _form = form;
    notifyListeners();
  }

  Future<void> addNewVisit() async {
    if (_state is! DraftingAddVisitState) return;

    final customer = _form.customer;
    final visitDate = _form.visitDate;
    final status = _form.status;
    final location = _form.location;
    final notes = _form.notes;
    final activities = _form.activities;


    if (customer == null) {
      GlobalToastMessage().add(InfoMessage(message: "Customer required"));
      return;
    }


    if (visitDate == null) {
      GlobalToastMessage().add(InfoMessage(message: "Select visit date"));
      return;
    }

    if (status == null) {
      GlobalToastMessage().add(InfoMessage(message: "Select status"));
      return;
    }

    if (location == null || location.isEmpty) {
      GlobalToastMessage().add(InfoMessage(message: "Please enter visit location"));
      return;
    }

    if (notes == null || notes.isEmpty) {
      GlobalToastMessage().add(InfoMessage(message: "Provide a brief summary your visit"));
      return;
    }

    try {
      _state = LoadingAddVisitState();
      notifyListeners();

      var addResult = await _addANewVisitUseCase.execute(
        customer: customer,
        visitDate: visitDate,
        status: status,
        location: location,
        notes: notes,
        activitiesDone: activities,
      );

      switch (addResult) {
        case ErrorResult<void>():
          _state = DraftingAddVisitState();
          GlobalToastMessage().add(ErrorMessage(message: addResult.error));
          break;
        case SuccessResult<void>():
          clearDraft();
          _state = SuccessAddingVisitState();
          GlobalToastMessage().add(SuccessMessage(message: addResult.message));
          break;
      }
    } finally {
      notifyListeners();
    }
  }
}
