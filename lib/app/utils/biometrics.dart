import 'package:biometric_storage/biometric_storage.dart';

class Biometrics {
  static final BiometricStorage _storage = BiometricStorage();

  Biometrics._();

  static Future<BiometricStorageFile> _getStorageFileForKey(String key) async {
    return _storage.getStorage(key);
  }

  static Future<void> addRepositoryPassword(
      {required String repositoryName, required String password}) async {
    final storageFile = await _getStorageFileForKey(repositoryName);
    storageFile.write(password);
  }

  static Future<String?> getRepositoryPassword(
      {required String repositoryName}) async {
    final storageFile = await _getStorageFileForKey(repositoryName);
    return storageFile.read();
  }

  static Future<void> deleteRepositoryPassword(
      {required String repositoryName}) async {
    final storageFile = await _getStorageFileForKey(repositoryName);
    return storageFile.delete();
  }
}
