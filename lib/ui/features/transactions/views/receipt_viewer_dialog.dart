import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../data/services/receipt_storage_service.dart';

class ReceiptViewerDialog extends StatelessWidget {
  final String relativePath;
  final VoidCallback? onDelete;

  const ReceiptViewerDialog({
    super.key,
    required this.relativePath,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'รูปสลิป / ใบเสร็จ',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          actions: [
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () {
                  Navigator.of(context).pop();
                  onDelete?.call();
                },
              ),
          ],
        ),
        body: FutureBuilder<File?>(
          future: ReceiptStorageService().getReceiptFile(relativePath),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }
            final file = snapshot.data;
            if (file == null || !file.existsSync()) {
              return const Center(
                child: Text('ไม่พบไฟล์รูปภาพสลิป', style: TextStyle(color: Colors.white70)),
              );
            }
            return Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.file(file),
              ),
            );
          },
        ),
      ),
    );
  }
}
