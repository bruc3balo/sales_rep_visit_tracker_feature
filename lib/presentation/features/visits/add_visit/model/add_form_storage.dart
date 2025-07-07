import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sales_rep_visit_tracker_feature/presentation/features/visits/add_visit/model/add_visit_models.dart';

class AddVisitFormStorage {
  static final AddVisitFormStorage _instance = AddVisitFormStorage._();

  factory AddVisitFormStorage() => _instance;

  AddVisitFormStorage._();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _key = 'add_visit_form';

  Future<void> saveForm(AddVisitForm form) async {
    await _storage.write(key: _key, value: form.toString());
  }

  Future<AddVisitForm?> loadForm() async {
    final jsonString = await _storage.read(key: _key);
    if (jsonString == null) return null;
    return AddVisitForm.fromString(jsonString);
  }

  Future<void> clearForm() async {
    await _storage.delete(key: _key);
  }
}