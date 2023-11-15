import 'package:cricket_app/types/stack.dart';

class PlayerModel {
  String name = "";
  int run = 0;
  int ball = 0;

  int givenRun = 0;
  int givenBall = 0;

  Stack<PlayerModel> outBowmanStack = Stack<PlayerModel>();

  PlayerModel(this.name);

  static PlayerModel normal = PlayerModel("");

  void reset() {
    run = ball = 0;
    givenBall = givenRun = 0;
    outBowmanStack.clear();
  }

  PlayerModel.fromMap(Map<String, dynamic> data) {
    name = data["name"];
    run = data["run"];
    ball = data["ball"];
    givenRun = data["givenRun"];
    givenBall = data["givenBall"];
  }

  Map<String, Object> toMap() {
    Map<String, Object> result = {};
    result["name"] = name;
    result["run"] = run;
    result["ball"] = ball;
    result["givenRun"] = givenRun;
    result["givenBall"] = givenBall;
    return result;
  }
}
