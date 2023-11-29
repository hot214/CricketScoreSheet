import 'package:cricket_app/const/global.dart';
import 'package:cricket_app/helper/game.dart';
import 'package:cricket_app/models/game_model.dart';
import 'package:cricket_app/models/team_model.dart';
import 'package:cricket_app/widgets/msg_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const TextStyle teamStyle =
    TextStyle(fontSize: 14, fontWeight: FontWeight.bold);

const TextStyle infoStyle =
    TextStyle(fontSize: 14, fontWeight: FontWeight.normal);

Widget TeamBallPage(TeamModel team) {
  List<GameState> history = team.history;
  return Column(children: [
    Expanded(
        child: SingleChildScrollView(
            child: Column(children: [
      for (int index = 0; index < history.length; index++)
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
              title: Text(history[index].toString(), style: infoStyle),
              leading: Text(overString(history[index].over), style: infoStyle)),
        ),
    ])))
  ]);
}

class BallByBallScreen extends StatefulWidget {
  const BallByBallScreen({Key? key}) : super(key: key);

  @override
  _BallByBallScreenState createState() => _BallByBallScreenState();
}

class _BallByBallScreenState extends State<BallByBallScreen>
    with TickerProviderStateMixin {
  void startOver() {
    GameModel model = Provider.of<GameModel>(context, listen: false);
    alertDialog(context, GLOBAL['APPNAME'], GLOBAL['STARTOVER_MESSAGE'],
        onSubmit: () {
      alertDialog(context, GLOBAL['APPNAME'], GLOBAL['STARTOVER_MESSAGE'],
          onSubmit: () {
        alertDialog(context, GLOBAL['APPNAME'], GLOBAL['STARTOVER_MESSAGE'],
            onSubmit: () {
          model.startOver();
          Navigator.pop(context, 'reset');
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    GameModel model = Provider.of<GameModel>(context);
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            leading: BackButton(
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text('Ball by Ball'),
          ),
          body: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(children: [
                menu(),
                Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Color.fromARGB(230, 230, 230, 230),
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: const ListTile(
                      contentPadding: EdgeInsets.all(0),
                      visualDensity: VisualDensity(vertical: -4),
                      title: Text("Score", style: infoStyle),
                      leading: Text("Over", style: infoStyle),
                    )),
                Expanded(
                    child: SafeArea(
                  child: TabBarView(
                    children: [
                      TeamBallPage(model.team1),
                      TeamBallPage(model.team2)
                    ],
                  ),
                ))
              ])),
        ));
  }

  Widget menu() {
    GameModel model = Provider.of<GameModel>(context, listen: false);
    return TabBar(
      labelColor: Colors.green,
      indicatorSize: TabBarIndicatorSize.tab,
      indicatorPadding: const EdgeInsets.all(5.0),
      indicatorColor: Colors.green,
      tabs: <Widget>[
        Tab(
          text: "${model.team1.name} Batting",
        ),
        Tab(
          text: "${model.team2.name} Batting",
        ),
      ],
    );
  }
}
