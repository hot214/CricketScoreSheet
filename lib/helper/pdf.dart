import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:cricket_app/models/game_model.dart';
import 'package:cricket_app/models/team_model.dart';
// import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';

// import 'package:filesystem_picker/filesystem_picker.dart';
String getCurrentDate() {
  var now = DateTime.now();
  return "${now.month}/${now.day}/${now.year}";
}

pw.Page SummaryPage(String subTitle, List<pw.Widget> content) {
  return pw.Page(
    pageFormat: PdfPageFormat.a4.copyWith(
        marginLeft: 20, marginRight: 20, marginTop: 20, marginBottom: 20),
    build: (pw.Context context) {
      return pw.Container(
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.start,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(
              level: 0,
              child: pw.Text('Cricket Game - ${getCurrentDate()}'),
            ),
            pw.Text(subTitle, textAlign: pw.TextAlign.right),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: content.slice(0, 2),
            ),
            content.length > 2
                ? pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: content.slice(2),
                  )
                : pw.SizedBox.shrink()
          ],
        ),
      );
    },
  );
}

Future<Uint8List> pdfGenerate(context) async {
  final pdf = pw.Document();
  GameModel model = Provider.of<GameModel>(context, listen: false);

  final pw.Widget team1Bat = buildSection(model.team1.getSummary());
  final pw.Widget team1Bow = buildSection(model.team1.getSummary(type: 'bow'));
  final pw.Widget team2Bat = buildSection(model.team2.getSummary());
  final pw.Widget team2Bow = buildSection(model.team2.getSummary(type: 'bow'));
  if (model.team1.playerList.length > 12) {
    pdf.addPage(SummaryPage(model.gameResult, [team1Bat, team1Bow]));
    pdf.addPage(SummaryPage(model.gameResult, [team2Bat, team2Bow]));
  } else {
    pdf.addPage(SummaryPage(model.gameResult,
        [team1Bat, team1Bow, pw.SizedBox(height: 20), team2Bat, team2Bow]));
  }

  return pdf.save();

/*
  String path = await FilesystemPicker.open(
    title: 'Save to folder',
    context: context,
    rootDirectory: rootPath,
    fsType: FilesystemType.folder,
    pickText: 'Save file to this folder',
  );

  final file =
      File("${path}/cricket_${DateTime.now().millisecondsSinceEpoch}.pdf");
  */
  /*
  List<Directory>? dirs =
      await getExternalStorageDirectories(type: StorageDirectory.downloads);
  print(dirs![0].path);
  final file = File(
      "${dirs![0].path}/cricket_${DateTime.now().millisecondsSinceEpoch}.pdf");
  await file.writeAsBytes(await pdf.save());
  */
}

pw.Widget buildSection(TeamSummary summary) {
  return pw.Container(
    width: PdfPageFormat.a4.width / 2 - 40,
    margin: const pw.EdgeInsets.all(5),
    padding: const pw.EdgeInsets.all(10),
    child: pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.start,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Header(
          level: 2,
          child: pw.Text("${summary.name}'s ${summary.type}",
              textAlign: pw.TextAlign.center),
        ),
        pw.TableHelper.fromTextArray(
            headers: summary.header,
            cellAlignment: pw.Alignment.center,
            data: summary.data),
      ],
    ),
  );
}
