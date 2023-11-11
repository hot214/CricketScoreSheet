import 'package:cricket_app/const/global.dart';
import 'package:cricket_app/models/game_model.dart';
import 'package:cricket_app/models/player_model.dart';
import 'package:cricket_app/screens/summary_screen.dart';
import 'package:cricket_app/widgets/input_widget.dart';
import 'package:cricket_app/widgets/msg_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BattingScreenController {
  void Function()? reset;
}

class BattingScreen extends StatefulWidget {
  final BattingScreenController? controller;

  const BattingScreen({super.key, this.controller});

  @override
  State<BattingScreen> createState() => _BattingScreenState(controller);
}

const TextStyle titleStyle =
    TextStyle(fontSize: 12, fontWeight: FontWeight.normal);

const TextStyle valueStyle =
    TextStyle(fontSize: 14, fontWeight: FontWeight.bold);

const TextStyle infoStyle =
    TextStyle(fontSize: 12, fontWeight: FontWeight.normal);

const TextStyle smallStyle =
    TextStyle(fontSize: 8, fontWeight: FontWeight.normal);

const TextStyle disabledStyle = TextStyle(
    fontSize: 12, fontWeight: FontWeight.normal, color: Colors.redAccent);

const TextStyle confirmedStyle =
    TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.blue);

class _BattingScreenState extends State<BattingScreen> {
  // Define variables to store the state of the checkboxes and input fields.
  bool isWideChecked = false;
  bool isNoBallChecked = false;
  bool isOut = false;
  int score = 0;

  String teamScore = 'R: 0 / B: 0';
  String over = '0.0';
  int overValue = 0;
  int selectedPlayer = 0;
  int rValue = 0;
  int bValue = 0;
  int outPenalty = 0;
  int resetFlag = 0;
  bool isOutPenaltyConfirmed = false;

  final _penaltyController = TextEditingController(text: '0');
  final _scoreController = TextEditingController(text: '0');

  // Create a list of players.
  List<Player> players = List.generate(
    11,
    (index) => Player(
      name: 'Player ${index + 1}',
      rValue: 0,
      bValue: 0,
    ),
  );

  List<ScoreState> history = [];

  _BattingScreenState(BattingScreenController? _controller) {
    _controller!.reset = reset;
  }

  void reset() {
    setState(() {
      isWideChecked = false;
      isNoBallChecked = false;
      isOut = false;
      score = 0;
    });
  }

  void _undo() {
    if (history.isEmpty) return;

    ScoreState last = history.last;

    // calculate score
    var reward = (last.isWideChecked ? 1 : 0) + (last.isNoBallChecked ? 1 : 0);
    var penalty = (last.isOut ? last.penalty : 0);
    var isValidDelivery = (!last.isWideChecked && !last.isNoBallChecked);

    setState(() {
      players[last.selectedPlayer].rValue -= reward + score - penalty;
      players[last.selectedPlayer].bValue -= isValidDelivery ? 1 : 0;
    });

    // _updateTeamScore();

    _scoreController.text = '0';
    score = 0;

    // calculate over
    int overs = (!last.isWideChecked && !last.isNoBallChecked) ? 1 : 0;
    overValue -= overs;
    int aOver = (overValue / 6.0).floor();
    int bOver = overValue % 6;
    setState(() {
      over = '$aOver.$bOver';
    });

    history.removeLast();
  }

  void goToSummary() async {
    final result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => const SummaryScreen()));
    if (result == 'reset') {
      reset();
    }
  }

  void handleAdd(
      bool isWideChecked, bool isNoBallChecked, bool isOut, int score) {
    GameModel model = Provider.of<GameModel>(context, listen: false);
    var state = model.add(isWideChecked, isNoBallChecked, isOut, score);
    if (state == true) {
      model.nextInning();
      if (model.inning == 1) {
        // The 1st innings has ended. The innings history has now been archived
        alertDialog(context, 'Cricket Game',
            'The 1st innings has ended!\nThe innings history has now been archived',
            onSubmit: () {
          goToSummary();
        });
      } else {
        alertDialog(
            context, 'Cricket Game', 'Game has ended!\n${model.gameResult}',
            onSubmit: () {
          goToSummary();
        });
      }
    }
  }

  void handleReset() {
    GameModel model = Provider.of<GameModel>(context, listen: false);
    alertDialog(context, GLOBAL['APPNAME'], GLOBAL['RESET_MESSAGE'],
        onSubmit: () {
      alertDialog(context, GLOBAL['APPNAME'], GLOBAL['RESET_MESSAGE'],
          onSubmit: () {
        alertDialog(context, GLOBAL['APPNAME'], GLOBAL['RESET_MESSAGE'],
            onSubmit: () {
          model.reset();
          setState(() {
            isWideChecked = false;
            isNoBallChecked = false;
            isOut = false;
            score = 0;
          });
        });
      });
    });
  }

  Widget showNotification() {
    GameModel model = Provider.of<GameModel>(context);
    if (model.inning == 1) return const SizedBox.shrink();
    return Row(children: [
      Expanded(
          child: Text(model.strategy,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, color: Colors.red)))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    GameModel model = Provider.of<GameModel>(context);
    List<PlayerModel> batmanList = model.batTeam.playerList;
    List<PlayerModel> bowmanList = model.bowTeam.playerList;
    PlayerModel currentBowman = model.currentBowman;
    PlayerModel currentBatman = model.currentBatman;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Team Score
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Team Score',
                      style: titleStyle,
                    ),
                    Text(
                      'R: ${model.batTeam.run} / B: ${model.batTeam.ball}',
                      style: valueStyle,
                    )
                  ],
                ),
                // Over
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Over',
                      style: titleStyle,
                    ),
                    Text(
                      model.over,
                      style: valueStyle,
                    ), // Add your over value here
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Text("Bowman: "),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: DropdownButton<PlayerModel>(
                    isExpanded: true,
                    value: currentBowman,
                    elevation: 16,
                    onChanged: (PlayerModel? value) {
                      // This is called when the user selects an item.
                      model.currentBowman = value!;
                    },
                    items: bowmanList.map<DropdownMenuItem<PlayerModel>>(
                        (PlayerModel player) {
                      return DropdownMenuItem<PlayerModel>(
                        value: player,
                        child: Text(player.name, style: infoStyle),
                      );
                    }).toList(),
                  ),
                )
              ],
            ),
            showNotification(),
            Expanded(
                child: ReorderableListView(
              children: [
                for (int index = 0; index < batmanList.length; index++)
                  Container(
                    key: Key('$index'),
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
                          onTap: () {
                            if (model.inning > 1) return;
                            inputDialog(context, "Player Name",
                                "Input Player Name", batmanList[index].name,
                                onSubmit: (String name) {
                              batmanList[index].name = name;
                              model.batTeam.setPlayer(batmanList);
                            });
                          },
                          child: Text(
                              batmanList[index].ball == model.limitBall
                                  ? "${batmanList[index].name} (completed)"
                                  : batmanList[index].name,
                              style: batmanList[index].ball == model.limitBall
                                  ? disabledStyle
                                  : infoStyle)),
                      subtitle: currentBatman == batmanList[index]
                          ? GestureDetector(
                              onTap: () {
                                if (model.inning > 1) return;
                                inputDialog(context, "Player Name",
                                    "Input Player Name", batmanList[index].name,
                                    onSubmit: (String name) {
                                  batmanList[index].name = name;
                                  model.batTeam.setPlayer(batmanList);
                                });
                              },
                              child: const Text('Striker', style: smallStyle))
                          : null,
                      leading: Radio(
                        value: batmanList[index],
                        groupValue: currentBatman,
                        onChanged: (value) {
                          model.currentBatman = value!;
                        },
                      ),
                      trailing: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedPlayer = index;
                            });
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'R: ${batmanList[index].run}',
                                style: infoStyle,
                              ),
                              const SizedBox(width: 32),
                              Text('B: ${batmanList[index].ball}',
                                  style: infoStyle),
                            ],
                          )),
                    ),
                  ),
              ],
              onReorder: (int oldIndex, int newIndex) {
                model.batTeam.switchOrder(oldIndex, newIndex);
              },
            )),

            // Wide, No ball, Score, Out
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                    flex: 1,
                    child: Row(
                      children: [
                        Checkbox(
                          value: isWideChecked,
                          onChanged: (value) {
                            setState(() {
                              isWideChecked = value ?? false;
                              isNoBallChecked =
                                  isNoBallChecked && !isWideChecked;
                            });
                          },
                        ),
                        const Text(
                          'Wide',
                          style: infoStyle,
                        )
                      ],
                    )),
                Flexible(
                    flex: 1,
                    child: Row(children: [
                      Checkbox(
                        value: isNoBallChecked,
                        onChanged: (value) {
                          setState(() {
                            isNoBallChecked = value ?? false;
                            isWideChecked = isWideChecked && !isNoBallChecked;
                          });
                        },
                      ),
                      const Text(
                        'No ball',
                        style: infoStyle,
                      )
                    ])),
                Flexible(
                    flex: 1,
                    child: Row(
                      children: [
                        Checkbox(
                          value: isOut,
                          onChanged: (value) {
                            setState(() {
                              isOut = value ?? false;
                            });
                          },
                        ),
                        const Text(
                          'Out',
                          style: infoStyle,
                        )
                      ],
                    )),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Checkbox(
                  value: true,
                  onChanged: null,
                ),
                Flexible(
                    flex: 1,
                    child: TextFormField(
                      controller: _scoreController,
                      style: infoStyle,
                      decoration: const InputDecoration(labelText: 'Score'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          score = int.tryParse(value) ?? 0;
                        });
                      },
                    )),
              ],
            ),
            const SizedBox(height: 8),
            // Add, Undo, Reset buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                    child: ElevatedButton(
                  onPressed: () {
                    // model.add();
                    handleAdd(isWideChecked, isNoBallChecked, isOut, score);
                  },
                  child: const Text('Add'),
                )),
                const SizedBox(width: 16),
                Expanded(
                    child: ElevatedButton(
                  onPressed: history.isEmpty
                      ? null
                      : () {
                          _undo();
                        },
                  child: const Text('Undo'),
                )),
                const SizedBox(width: 16),
                Expanded(
                    child: ElevatedButton(
                  onPressed: () {
                    handleReset();
                  },
                  child: const Text('Del All'),
                )),
              ],
            ),
            // Out Penalty Input
            Row(
              children: [
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: GestureDetector(
                      onTap: () => {
                            if (!model.outPenaltyConfirmed)
                              {
                                inputDialog(context, "Out Penalty",
                                    "Input Out Penalty", "${model.outPenalty}",
                                    onSubmit: (String out_penalty) {
                                  model.outPenalty = int.parse(out_penalty);
                                })
                              }
                          },
                      child: Text(
                        'Out Penalty: ${model.outPenalty}',
                        style: model.outPenaltyConfirmed
                            ? confirmedStyle
                            : infoStyle,
                      )),
                ),
                const SizedBox(
                  width: 16,
                  height: 48,
                ),
                Expanded(
                  child: GestureDetector(
                      onTap: () => {
                            if (!model.limitBallConfirmed)
                              {
                                inputDialog(context, "Ball Limit",
                                    "Input Max Balls", "${model.limitBall}",
                                    onSubmit: (String ball_limit) {
                                  model.limitBall = int.parse(ball_limit);
                                })
                              }
                          },
                      child: Text(
                        'Max Balls: ${model.limitBall}',
                        style: model.limitBallConfirmed
                            ? confirmedStyle
                            : infoStyle,
                      )),
                ),
                const SizedBox(
                  width: 20,
                ),
              ],
            ),
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
