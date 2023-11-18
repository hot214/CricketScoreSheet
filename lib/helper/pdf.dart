import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:cricket_app/models/game_model.dart';
import 'package:cricket_app/models/team_model.dart';
// import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// import 'package:filesystem_picker/filesystem_picker.dart';
String getCurrentDate() {
  var now = DateTime.now();
  return "${now.month}/${now.day}/${now.year}";
}

pw.Page SummaryPage(
    String headerInfo, String subTitle, List<pw.Widget> content) {
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
              child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    pw.Text("Cricket App",
                        style: const pw.TextStyle(fontSize: 24)),
                    pw.Text(headerInfo)
                  ]),
            ),
            pw.Text(subTitle, textAlign: pw.TextAlign.right),
            pw.Row(
              children: content.slice(0, 2),
            ),
            content.length > 2
                ? pw.Row(
                    children: content.slice(2),
                  )
                : pw.SizedBox.shrink()
          ],
        ),
      );
    },
  );
}

Future<Uint8List> pdfGenerate(GameModel model) async {
  final pdf = pw.Document();

  final pw.Widget team1Bat = buildSection(model.team1.getSummary());
  final pw.Widget team1Bow =
      buildSection(model.team1.getSummary(type: 'Bowling'));
  final pw.Widget team2Bat = buildSection(model.team2.getSummary());
  final pw.Widget team2Bow =
      buildSection(model.team2.getSummary(type: 'Bowling'));
  if (model.team1.playerList.length > 12) {
    pdf.addPage(
        SummaryPage(model.gameSummary, model.gameResult, [team1Bat, team2Bow]));
    pdf.addPage(
        SummaryPage(model.gameSummary, model.gameResult, [team2Bat, team1Bow]));
  } else {
    pdf.addPage(SummaryPage(model.gameSummary, model.gameResult,
        [team1Bat, team2Bow, pw.SizedBox(height: 20), team2Bat, team1Bow]));
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
          child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("${summary.name} ${summary.type} statistics"),
                /* pw.Text(summary.type == "Batting"
                    ? "Runs: ${summary.run} Balls: ${summary.ball} Overs: ${summary.overs}"
                    : "Balls: ${summary.ball}"), */
              ]),
        ),
        pw.TableHelper.fromTextArray(
            headers: summary.header,
            cellAlignment: pw.Alignment.center,
            data: summary.data),
        pw.Padding(padding: const pw.EdgeInsets.only(top: 5)),
        pw.Text(summary.type == "Batting"
            ? "Runs: ${summary.run}, Balls: ${summary.ball}, Overs: ${summary.overs}"
            : ""),
        /*
        pw.Text(summary.type == "Batting"
            ? "Total: ${summary.run} runs in ${summary.overs} statistics"
            : "Total: ${summary.ball} balls"),*/
      ],
    ),
  );
}
