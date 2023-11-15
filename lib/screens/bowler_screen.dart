import 'package:cricket_app/models/game_model.dart';
import 'package:cricket_app/models/player_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BowlerScreen extends StatefulWidget {
  const BowlerScreen({super.key});

  @override
  State<BowlerScreen> createState() => _MyHomePageState();
}

const TextStyle titleStyle =
    TextStyle(fontSize: 12, fontWeight: FontWeight.normal);

const TextStyle valueStyle =
    TextStyle(fontSize: 14, fontWeight: FontWeight.bold);

const TextStyle infoStyle =
    TextStyle(fontSize: 12, fontWeight: FontWeight.normal);

const TextStyle boldInfoStyle =
    TextStyle(fontSize: 13, fontWeight: FontWeight.bold);

const TextStyle smallStyle =
    TextStyle(fontSize: 8, fontWeight: FontWeight.normal);

class _MyHomePageState extends State<BowlerScreen> {
  // Function to open a dialog for entering player name.
  Future<void> _editPlayerName(String playerName, {onSave}) async {
    var controller = TextEditingController(text: playerName);
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Player Name'),
          content: TextField(
            controller: controller,
            onChanged: (value) {},
            decoration: const InputDecoration(hintText: 'Enter Player Name'),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () {
                onSave(controller.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    GameModel model = Provider.of<GameModel>(context);
    List<PlayerModel> bowlerList = model.bowTeam.playerList;
    PlayerModel currentBowler = model.currentBowman;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
                child: SingleChildScrollView(
                    child: Column(children: [
              for (int index = 0; index < bowlerList.length; index++)
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color.fromARGB(100, 100, 100, 100),
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(0),
                    visualDensity: const VisualDensity(vertical: -4),
                    title: GestureDetector(
                        onTap: !model.isGameStarted
                            ? () {
                                _editPlayerName(bowlerList[index].name,
                                    onSave: (String name) {
                                  bowlerList[index].name = name;
                                  model.bowTeam.setPlayer(bowlerList);
                                });
                              }
                            : null,
                        child: currentBowler == bowlerList[index]
                            ? Text(bowlerList[index].name, style: boldInfoStyle)
                            : Text(bowlerList[index].name, style: infoStyle)),
                    trailing: GestureDetector(
                        child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'R: ${bowlerList[index].givenRun}',
                          style: infoStyle,
                        ),
                        const SizedBox(width: 32),
                        Text('B: ${bowlerList[index].givenBall}',
                            style: infoStyle),
                      ],
                    )),
                  ),
                ),
            ]))),
          ],
        ),
      ),
    );
  }
}

class Player {
  String name;
  int rValue;
  int bValue;

  Player({required this.name, required this.rValue, required this.bValue});
}

class ScoreState {
  bool isWideChecked = false;
  bool isNoBallChecked = false;
  bool isOut = false;
  int score = 0;
  int penalty = 0;
  int selectedPlayer = 0;

  ScoreState(
      {this.selectedPlayer = 0,
      this.isWideChecked = false,
      this.isNoBallChecked = false,
      this.isOut = false,
      this.score = 0,
      this.penalty = 0});
}
