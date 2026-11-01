import 'dart:io';

/// Validates image uploads before sending to the API.
class UploadValidator {
  UploadValidator._();

  static const maxBytes = 5 * 1024 * 1024; // 5 MB
  static const allowedExtensions = {'jpg', 'jpeg', 'png', 'webp'};

  static String? validateImage(File file) {
    final ext = file.path.split('.').last.toLowerCase();
    if (!allowedExtensions.contains(ext)) {
      return 'Formato inválido. Use JPG, PNG ou WEBP.';
    }

    final length = file.lengthSync();
    if (length <= 0) return 'Ficheiro vazio';
    if (length > maxBytes) {
      return 'Imagem demasiado grande (máx. 5 MB).';
    }

    return null;
  }

  static bool isAllowedExtension(String path) {
    final ext = path.split('.').last.toLowerCase();
    return allowedExtensions.contains(ext);
  }
}
