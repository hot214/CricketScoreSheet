import 'package:cricket_app/types/stack.dart';

class PlayerModel {
  String name;
  int run = 0;
  int ball = 0;

  int givenRun = 0;
  int givenBall = 0;

  Stack<PlayerModel> outBowmanStack = Stack<PlayerModel>();

  PlayerModel(this.name);
}
