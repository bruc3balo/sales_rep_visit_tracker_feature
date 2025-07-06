
import 'dart:convert';
import 'dart:math';
import 'package:hive/hive.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HiveKeyGenerator {
  final String _keyName;

  HiveKeyGenerator({required String keyName}) : _keyName = keyName;

  ///Retrieves base64 encoded hive key or creates one if doesn't exist
  Future<HiveAesCipher> obtainHiveAesCipher() async {
    const FlutterSecureStorage storage = FlutterSecureStorage();

    // Check if the key exists in secure storage
    String? encodedHiveKey = await storage.read(key: _keyName);
    if(encodedHiveKey != null) {
      final key = base64Url.decode(encodedHiveKey);
      return HiveAesCipher(key);
    }

    // Generate a new 32-byte key
    final key = List<int>.generate(32, (i) => Random.secure().nextInt(256));

    // Store the key securely
    await storage.write(key: _keyName, value: base64UrlEncode(key));
    return HiveAesCipher(key);
  }
}

