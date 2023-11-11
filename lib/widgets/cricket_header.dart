import 'package:cricket_app/widgets/input_widget.dart';
import 'package:flutter/material.dart';

const TextStyle titleStyle =
    TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

const TextStyle teamStyle =
    TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

class CricketHeaderWidget extends StatelessWidget {
  String title = 'None';
  String teamName = 'None';
  int index = 1;
  static const STATUS = ["Batting", "Bowling"];

  Function? onChanged;
  CricketHeaderWidget(this.title, this.teamName, this.index, {this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(children: [
          Expanded(child: Text(title, style: titleStyle)),
          GestureDetector(
              onTap: onChanged != null
                  ? () => {
                        inputDialog(
                            context, "Team Name", "Input Team Name", teamName,
                            onSubmit: (String name) {
                          teamName = name;
                          if (onChanged != null) onChanged!(name);
                        })
                      }
                  : null,
              child: Text("${teamName} is ${STATUS[index]}",
                  style: teamStyle, textAlign: TextAlign.right))
        ]));
  }
}
