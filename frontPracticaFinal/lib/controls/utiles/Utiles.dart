import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Utiles{
  final _storage = const FlutterSecureStorage();
  void saveValue(key, value) async{
    await _storage.write(key: key, value: value);
  }
  // sacar el value
  Future<String?> getValue(key) async {
    return await _storage.read(key: key);
  } 
  void removeAllItem() async {
    await _storage.deleteAll();
  }
}