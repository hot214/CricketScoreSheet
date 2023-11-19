import 'package:cricket_app/const/global.dart';
import 'package:cricket_app/models/game_model.dart';
import 'package:cricket_app/screens/summary_screen.dart';
import 'package:cricket_app/service/sqliteService.dart';
import 'package:cricket_app/widgets/msg_dialog.dart';
import 'package:flutter/material.dart';

const TextStyle teamStyle =
    TextStyle(fontSize: 14, fontWeight: FontWeight.bold);

const TextStyle infoStyle =
    TextStyle(fontSize: 14, fontWeight: FontWeight.normal);

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({Key? key}) : super(key: key);

  @override
  _ArchiveScreenState createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  Future<List<GameModel>> history = SqliteService.getItems();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void deleteAll() async {
    alertDialog(context, GLOBAL['APPNAME'], GLOBAL['RESET_MESSAGE'],
        onSubmit: () {
      alertDialog(context, GLOBAL['APPNAME'], GLOBAL['RESET_MESSAGE'],
          onSubmit: () {
        alertDialog(context, GLOBAL['APPNAME'], GLOBAL['RESET_MESSAGE'],
            onSubmit: () async {
          await SqliteService.deleteAll();
          history = SqliteService.getItems();
          setState(() {});
        });
      });
    });
  }

  void delete(GameModel model) async {
    await SqliteService.delete(model);
    history = SqliteService.getItems();
    Navigator.of(context).pop();
    setState(() {});
  }

  void triggerItemMenu(GameModel model) {
    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return Padding(
              padding: const EdgeInsets.all(32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        delete(model);
                      },
                      child: const Text("Delete")),
                  const SizedBox(width: 32),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Cancle"))
                ],
              ));
        });
  }

  void triggerSummary(GameModel model) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SummaryScreen(
                  model: model,
                  isArchive: true,
                )));
  }

  Widget archiveListWidget(List<GameModel>? data) {
    return SingleChildScrollView(
        child: Column(children: [
      for (GameModel model in data!)
        Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color.fromARGB(230, 230, 230, 230),
                width: 1.0,
              ),
            ),
          ),
          child: ListTile(
              contentPadding: const EdgeInsets.all(8),
              visualDensity: const VisualDensity(vertical: -4),
              title: Text(model.gameSummary, style: infoStyle),
              onLongPress: () => triggerItemMenu(model),
              onTap: () => triggerSummary(model)),
        ),
    ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: BackButton(
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Archives'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.delete_forever),
              onPressed: () {
                deleteAll();
              },
            )
          ],
        ),
        body: SafeArea(
            child: FutureBuilder(
                future: history,
                builder: (context, data) {
                  if (data.hasData) {
                    return archiveListWidget(data.data);
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                })));
  }
}
