import 'dart:io';

import 'package:cricket_app/helper/pdf.dart';
import 'package:cricket_app/widgets/msg_dialog.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';

Directory findRoot(FileSystemEntity entity) {
  final Directory parent = entity.parent;
  if (parent.path == entity.path) return parent;
  return findRoot(parent);
}

class PdfScreen extends StatefulWidget {
  const PdfScreen({super.key});

  @override
  State<PdfScreen> createState() => _PdfScreenState();
}

class _PdfScreenState extends State<PdfScreen> {
  void download() async {
    final Directory root = findRoot(await getApplicationDocumentsDirectory());
    String? path = await FilesystemPicker.open(
      title: 'Save to folder',
      context: context,
      rootDirectory: root!,
      fsType: FilesystemType.folder,
      pickText: 'Save file',
    );
    if (path == null) return;
    try {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();

      if (statuses[Permission.storage] != PermissionStatus.granted) return;
      final file = File(
          "$path/cricket_game_${DateTime.now().millisecondsSinceEpoch}.pdf");
      File target = await file.writeAsBytes(await pdfGenerate(context));
      await alertDialog(
          context, "Save Report", "Save Document successfully\n${target.path}.",
          onSubmit: () {});
    } catch (e) {
      print(e);
      await alertDialog(context, "Save Report", "Save Failed!",
          onSubmit: () {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Preview'),
      ),
      body: PdfPreview(
        build: (ctx) async => await pdfGenerate(context),
        canChangePageFormat: false,
        canDebug: false,
        allowSharing: false,
        allowPrinting: false,
        canChangeOrientation: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              download();
            },
          )
        ],
      ),
    );
  }
}
