import 'package:cricket_app/const/global.dart';
import 'package:cricket_app/helper/game.dart';
import 'package:cricket_app/helper/string.dart';
import 'package:cricket_app/models/game_model.dart';
import 'package:cricket_app/models/player_model.dart';
import 'package:cricket_app/models/team_model.dart';
import 'package:cricket_app/screens/archives_screen.dart';
import 'package:cricket_app/screens/pdf_screen.dart';
import 'package:cricket_app/widgets/msg_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const TextStyle teamStyle =
    TextStyle(fontSize: 14, fontWeight: FontWeight.bold);

const TextStyle infoStyle =
    TextStyle(fontSize: 14, fontWeight: FontWeight.normal);

Widget TabItem(String title, String info) {
  return Tab(
      child: Column(
    children: [
      Text(
        title,
        style: teamStyle,
        textAlign: TextAlign.center,
      ),
      Text(
        info,
        style: infoStyle,
        textAlign: TextAlign.center,
      ),
    ],
  ));
}

Widget SummaryPage(TeamModel team, bool isBatTeam) {
  List<PlayerModel> playerList = team.playerList;
  return Column(children: [
    Text(
      "${team.name} ${isBatTeam ? 'Batting' : 'Bowling'} Stats",
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    ),
    isBatTeam
        ? Text(
            "Runs: ${team.run} / Balls: ${team.ball} / Overs: ${overString(team.over)}",
            style: const TextStyle(fontSize: 10))
        : const Text(" ", style: TextStyle(fontSize: 10)),
    Expanded(
        child: SingleChildScrollView(
            child: Column(children: [
      for (int index = 0; index < playerList.length; index++)
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
              contentPadding: const EdgeInsets.all(0),
              visualDensity: const VisualDensity(vertical: -4),
              title: Text(playerList[index].name, style: infoStyle),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'R: ${isBatTeam ? playerList[index].run : playerList[index].givenRun}',
                    style: infoStyle,
                  ),
                  const SizedBox(width: 32),
                  Text(
                      'B: ${isBatTeam ? playerList[index].ball : playerList[index].givenBall}',
                      style: infoStyle),
                ],
              )),
        ),
    ])))
  ]);
}

class SummaryScreen extends StatefulWidget {
  GameModel? model;
  SummaryScreen({Key? key, this.model = null}) : super(key: key);

  @override
  _SummaryScreenState createState() => _SummaryScreenState(model);
}

class _SummaryScreenState extends State<SummaryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  GameModel? model;
  _SummaryScreenState(GameModel? gm) {
    print(gm);
    model = gm;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void download() {
    // pdfGenerate(context);
    GameModel originModel = Provider.of<GameModel>(context, listen: false);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PdfScreen(model: model ?? originModel)));
  }

  void reset() {
    GameModel originModel = Provider.of<GameModel>(context, listen: false);
    alertDialog(context, GLOBAL['APPNAME'], GLOBAL['RESET_MESSAGE'],
        onSubmit: () {
      alertDialog(context, GLOBAL['APPNAME'], GLOBAL['RESET_MESSAGE'],
          onSubmit: () {
        alertDialog(context, GLOBAL['APPNAME'], GLOBAL['RESET_MESSAGE'],
            onSubmit: () {
          originModel.startOver();
          Navigator.pop(context, 'reset');
        });
      });
    });
  }

  void goToArchive() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const ArchiveScreen()));
  }

  @override
  Widget build(BuildContext context) {
    GameModel originModel = Provider.of<GameModel>(context, listen: false);
    GameModel model = this.model ?? originModel;

    return DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            leading: model.inning != 3
                ? BackButton(
                    onPressed: () => Navigator.of(context).pop(),
                  )
                : const SizedBox.shrink(),
            title: const Text('Summary'),
            actions: <Widget>[
              model.inning == 3 && originModel == model
                  ? IconButton(
                      icon: const Icon(Icons.reset_tv),
                      onPressed: () {
                        reset();
                      },
                    )
                  : const SizedBox.shrink(),
              /*originModel == model
                  ? IconButton(
                      icon: const Icon(Icons.archive),
                      onPressed: () {
                        goToArchive();
                      },
                    )
                  : const SizedBox.shrink(),*/
              IconButton(
                icon: const Icon(Icons.preview_sharp),
                onPressed: () {
                  download();
                },
              )
            ],
          ),
          bottomNavigationBar: menu(model),
          body: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(children: [
                model!.inning == 3
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          children: [
                            Text(
                              "Result: ${model!.gameSummary}",
                              style: const TextStyle(fontSize: 11),
                            ),
                            Text(model!.gameResult,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.red))
                          ],
                        ))
                    : const SizedBox.shrink(),
                Expanded(
                    child: SafeArea(
                  child: TabBarView(
                    children: [
                      SummaryPage(model!.team1, true),
                      SummaryPage(model!.team2, false),
                      SummaryPage(model!.team2, true),
                      SummaryPage(model!.team1, false)
                    ],
                  ),
                ))
              ])),
        ));
  }

  Widget menu(GameModel model) {
    return TabBar(
      labelColor: Colors.green,
      indicatorSize: TabBarIndicatorSize.tab,
      indicatorPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      indicatorColor: Colors.green,
      tabs: [
        TabItem(model.team1.name.truncateTo(5), "Batting"),
        TabItem(model.team2.name.truncateTo(5), "Bowl"),
        TabItem(model.team2.name.truncateTo(5), "Batting"),
        TabItem(model.team1.name.truncateTo(5), "Bowl"),
      ],
    );
  }
}
