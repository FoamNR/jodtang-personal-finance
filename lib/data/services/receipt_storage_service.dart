import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ReceiptStorageService {
  static const String slipsFolderName = 'slips';

  Future<Directory> getSlipsDirectory() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final slipsDir = Directory(p.join(appDocDir.path, slipsFolderName));
    if (!await slipsDir.exists()) {
      await slipsDir.create(recursive: true);
    }
    return slipsDir;
  }

  /// Copies an image file into the local app slips directory and returns the relative path
  Future<String> saveReceiptImage(File sourceFile) async {
    final slipsDir = await getSlipsDirectory();
    final ext = p.extension(sourceFile.path);
    final fileName = 'slip_${DateTime.now().millisecondsSinceEpoch}$ext';
    final targetPath = p.join(slipsDir.path, fileName);

    await sourceFile.copy(targetPath);
    return p.join(slipsFolderName, fileName).replaceAll(r'\', '/');
  }

  /// Resolves a relative path to a full absolute File
  Future<File?> getReceiptFile(String? relativePath) async {
    if (relativePath == null || relativePath.isEmpty) return null;
    final appDocDir = await getApplicationDocumentsDirectory();
    final fullPath = p.join(appDocDir.path, relativePath.replaceAll('/', Platform.pathSeparator));
    final file = File(fullPath);
    if (await file.exists()) {
      return file;
    }
    return null;
  }

  /// Deletes a receipt file if it exists
  Future<void> deleteReceiptImage(String? relativePath) async {
    if (relativePath == null || relativePath.isEmpty) return;
    final appDocDir = await getApplicationDocumentsDirectory();
    final fullPath = p.join(appDocDir.path, relativePath.replaceAll('/', Platform.pathSeparator));
    final file = File(fullPath);
    if (await file.exists()) {
      try {
        await file.delete();
      } catch (_) {}
    }
  }

  /// Clears all receipt files
  Future<void> clearAllReceipts() async {
    final slipsDir = await getSlipsDirectory();
    if (await slipsDir.exists()) {
      final files = slipsDir.listSync();
      for (var file in files) {
        if (file is File) {
          try {
            await file.delete();
          } catch (_) {}
        }
      }
    }
  }
}
