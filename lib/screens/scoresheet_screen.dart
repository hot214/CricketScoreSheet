import 'package:flutter/material.dart';

class ScoreSheetScreen extends StatefulWidget {
  const ScoreSheetScreen({super.key});

  @override
  State<ScoreSheetScreen> createState() => _MyHomePageState();
}

const TextStyle titleStyle =
    TextStyle(fontSize: 14, fontWeight: FontWeight.bold);

const TextStyle valueStyle =
    TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

const TextStyle infoStyle =
    TextStyle(fontSize: 12, fontWeight: FontWeight.normal);

const TextStyle smallStyle =
    TextStyle(fontSize: 8, fontWeight: FontWeight.normal);

class _MyHomePageState extends State<ScoreSheetScreen> {
  // Define variables to store the state of the checkboxes and input fields.
  bool isWideChecked = false;
  bool isNoBallChecked = false;
  bool isOut = false;
  String teamScore = 'R: 0 / B: 0';
  int score = 0;
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

  void _updateTeamScore() {
    var totalScore = 0;
    var totalBall = 0;

    for (int index = 0; index < players.length; index++) {
      totalScore += players[index].rValue > 0 ? players[index].rValue : 0;
      totalBall += players[index].bValue;
    }
    setState(() {
      teamScore = 'R: $totalScore / B: $totalBall';
    });
  }

  void _add() {
    print(overValue);
    // calculate score
    var reward = (isWideChecked ? 1 : 0) + (isNoBallChecked ? 1 : 0);
    var penalty = (isOut ? outPenalty : 0);
    var isValidDelivery = (!isWideChecked && !isNoBallChecked);

    setState(() {
      players[selectedPlayer].rValue += reward + score - penalty;
      players[selectedPlayer].bValue += isValidDelivery ? 1 : 0;
    });

    history.add(ScoreState(
        selectedPlayer: selectedPlayer,
        isNoBallChecked: isNoBallChecked,
        isWideChecked: isWideChecked,
        isOut: isOut,
        score: score,
        penalty: outPenalty));

    _updateTeamScore();

    _scoreController.text = '0';
    score = 0;

    // calculate over
    int overs = (!isWideChecked && !isNoBallChecked) ? 1 : 0;
    overValue += overs;
    int aOver = (overValue / 6.0).floor();
    int bOver = overValue % 6;
    setState(() {
      over = '$aOver.$bOver';
    });
  }

  void _undo() {
    if (history.isEmpty) return;

    ScoreState last = history.last;
    print(last);
    print(players[last.selectedPlayer].rValue);

    // calculate score
    var reward = (last.isWideChecked ? 1 : 0) + (last.isNoBallChecked ? 1 : 0);
    var penalty = (last.isOut ? last.penalty : 0);
    var isValidDelivery =
        (!last.isWideChecked && !last.isNoBallChecked);

    setState(() {
      players[last.selectedPlayer].rValue -= reward + score - penalty;
      players[last.selectedPlayer].bValue -= isValidDelivery ? 1 : 0;
    });

    _updateTeamScore();

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

  void _resetSheet() {
    setState(() {
      resetFlag = 0;
      teamScore = 'R: 0 / B: 0';
      outPenalty = 0;
      isOutPenaltyConfirmed = false;
      selectedPlayer = 0;
      isWideChecked = false;
      isNoBallChecked = false;
      isOut = false;
      score = 0;
      over = '0.0';
      overValue = 0;
      history = [];
      players = List.generate(
        11,
        (index) => Player(
          name: 'Player ${index + 1}',
          rValue: 0,
          bValue: 0,
        ),
      );
    });
    _penaltyController.text = '0';
  }

  // Function to open a dialog for entering player name.
  Future<void> _editPlayerName(Player player) async {
    var controller = TextEditingController(text: player.name);
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Player Name'),
          content: TextField(
            controller: controller,
            onChanged: (value) {
              setState(() {
                player.name = value;
              });
            },
            decoration: const InputDecoration(hintText: 'Enter Player Name'),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _reset() async {
    setState(() {
      resetFlag = resetFlag + 1;
    });
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cricket Score Sheet'),
          content: const Text('Do you want to really reset sheet?'),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                if (resetFlag < 2)
                  _reset();
                else
                  _resetSheet();
              },
            ),
            ElevatedButton(
              child: const Text('Cancel'),
              onPressed: () {
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
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
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
                      '$teamScore',
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
                      '$over',
                      style: valueStyle,
                    ), // Add your over value here
                  ],
                ),
              ],
            ),
            
            // List of Players
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (int index = 0; index < players.length; index++)
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
                        title: GestureDetector(
                            onTap: () {
                              _editPlayerName(players[index]);
                            },
                            child: Text(
                              players[index].name,
                              style: infoStyle
                              )  
                            ),
                        subtitle: index == selectedPlayer
                            ? GestureDetector(
                                onTap: () {
                                  _editPlayerName(players[index]);
                                },
                                child: const Text('Striker', style: smallStyle))
                            : null,
                        leading: Radio(
                          value: index,
                          groupValue: selectedPlayer,
                          onChanged: (value) {
                            setState(() {
                              selectedPlayer = value ?? 0;
                            });
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
                                  'R: ${players[index].rValue}',
                                  style: infoStyle,
                                ),
                                const SizedBox(width: 32),
                                Text(
                                  'B: ${players[index].bValue}',
                                  style: infoStyle
                                ),
                              ],
                            )),
                        onTap: () {
                          setState(() {
                            selectedPlayer = index;
                          });
                        },
                      ),
                    ),
                  ]
                )
              )
            ),

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
                        const Text('Wide', style: infoStyle,)
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
                      const Text('No ball', style: infoStyle,)
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
                        const Text('Out', style: infoStyle,)
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
            const SizedBox(height: 16),
            // Add, Undo, Reset buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                    child: ElevatedButton(
                  onPressed: () {
                    _add();
                  },
                  child: Text('Add'),
                )),
                const SizedBox(width: 32),
                Expanded(
                    child: ElevatedButton(
                  onPressed: history.isEmpty
                      ? null
                      : () {
                          _undo();
                        },
                  child: Text('Undo'),
                )),
                const SizedBox(width: 32),
                Expanded(
                    child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      resetFlag = 0;
                    });
                    _reset();
                  },
                  child: const Text('Reset'),
                )),
              ],
            ),
            // Out Penalty Input
            Row(
              children: [
                Expanded(
                  child: !isOutPenaltyConfirmed
                      ? TextFormField(
                          controller: _penaltyController,
                          style: infoStyle,
                          decoration:
                              const InputDecoration(labelText: 'Out Penalty'),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              outPenalty = int.tryParse(value) ?? 0;
                            });
                          },
                        )
                      : Text(
                          'Out Penalty: $outPenalty',
                          style: infoStyle,
                        ),
                ),
                const SizedBox(
                  width: 16,
                ),
                ElevatedButton(
                  onPressed: () {
                    // Add your logic for the "Submit" button here
                    setState(() {
                      isOutPenaltyConfirmed = true;
                    });
                  },
                  child: const Text('Submit'),
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
