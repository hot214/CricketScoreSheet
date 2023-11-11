import 'dart:math';

import 'package:cricket_app/models/player_model.dart';
import 'package:cricket_app/models/team_model.dart';
import 'package:flutter/material.dart';

class GameModel extends ChangeNotifier {
  late TeamModel _teamA;
  late TeamModel _teamB;

  int _inning = 1;
  int _outPenalty = 5;
  int _limitBall = 5;

  bool _outPenaltyConfirmed = false;
  bool _limitBallConfirmed = false;

  GameModel() {
    _teamA = TeamModel("T1");
    _teamB = TeamModel("T2");
    _teamA.addListener(() => notifyListeners());
    _teamB.addListener(() => notifyListeners());
  }

  bool get outPenaltyConfirmed => _outPenaltyConfirmed;
  bool get limitBallConfirmed => _limitBallConfirmed;

  TeamModel get batTeam => _inning == 1 ? _teamA : _teamB;
  TeamModel get bowTeam => _inning == 2 ? _teamA : _teamB;

  TeamModel get team1 => _teamA;
  TeamModel get team2 => _teamB;

  String get over {
    int aOver = (batTeam.over / 6.0).floor();
    int bOver = batTeam.over % 6;

    return '$aOver.$bOver';
  }

  PlayerModel get currentBowman => bowTeam.currentPlayer;
  set currentBowman(PlayerModel player) {
    bowTeam.currentPlayer = player;
  }

  PlayerModel get currentBatman => batTeam.currentPlayer;
  set currentBatman(PlayerModel player) {
    batTeam.currentPlayer = player;
    notifyListeners();
  }

  int get inning => _inning;
  bool nextInning() {
    _inning++;
    bowTeam.currentPlayer = bowTeam.playerList[0];
    batTeam.currentPlayer = batTeam.playerList[0];
    _outPenaltyConfirmed = true;
    _limitBallConfirmed = true;
    notifyListeners();
    return _inning < 3;
  }

  int get outPenalty => _outPenalty;
  set outPenalty(int penalty) {
    if (_outPenaltyConfirmed) return;
    _outPenalty = penalty;
    _outPenaltyConfirmed = true;
    notifyListeners();
  }

  int get limitBall => _limitBall;
  set limitBall(int limitBall) {
    if (_limitBallConfirmed) return;
    _limitBall = limitBall;
    _limitBallConfirmed = true;
    notifyListeners();
  }

  String get strategy {
    final target = bowTeam.run + 1;
    final remainRun = target - batTeam.run;
    final remainBall = limitBall * batTeam.playerList.length - batTeam.ball;

    return 'Target: $target. Need $remainRun runs from $remainBall balls';
  }

  String get gameResult {
    if (_inning < 3) return '';
    if (team1.run == team2.run) {
      return 'The match between ${team1.name} and ${team2.name} has been tied.';
    } else if (team1.run < team2.run) {
      final remainBall = limitBall * team2.playerList.length - team2.ball;

      print(limitBall);
      print(team2.playerList.length);
      print(team1.ball);

      return '${team2.name} has beaten ${team1.name} with successful run chase having $remainBall ${remainBall > 1 ? 'balls' : 'ball'} left.';
    } else {
      final diffRun = team1.ball - team2.ball;
      return '${team1.name} has beaten ${team2.name} by $diffRun runs.';
    }
  }

  bool checkGameFinished() {
    if (inning > 1 && team2.run > team1.run) {
      return true;
    }
    for (var i = 0; i < batTeam.playerList.length; i++) {
      if (batTeam.playerList[i].ball < limitBall) {
        return false;
      }
    }
    return true;
  }

  void reset() {
    _teamA = TeamModel("T1");
    _teamB = TeamModel("T2");
    _inning = 1;
    _outPenalty = 5;
    _limitBall = 5;
    _outPenaltyConfirmed = false;
    _limitBallConfirmed = false;
    _teamA.addListener(() => notifyListeners());
    _teamB.addListener(() => notifyListeners());
    notifyListeners();
  }

  bool add(bool isWideChecked, bool isNoBallChecked, bool isOut, int score) {
    // calculate score
    if (currentBatman.ball == limitBall) return false;

    int reward = (isWideChecked ? 1 : 0) + (isNoBallChecked ? 1 : 0);
    int penalty = (isOut ? outPenalty : 0);
    bool isValidDelivery = (!isWideChecked && !isNoBallChecked);

    // update batman's score
    currentBatman.run += reward + score - penalty;
    currentBatman.ball += isValidDelivery ? 1 : 0;
    if (isOut) currentBatman.outBowmanStack.push(currentBowman);

    // calculate over
    batTeam.over += (!isWideChecked && !isNoBallChecked) ? 1 : 0;

    // update bowmans score;
    currentBowman.givenRun += reward + score - penalty;
    currentBowman.givenBall += isValidDelivery ? 1 : 0;

    // case of batman's score reaches to max-ball
    if (currentBatman.ball == limitBall) {
      int score = currentBatman.run;
      while (score < 0) {
        currentBatman.outBowmanStack.pop()!.givenRun += max(score, -outPenalty);
        score += outPenalty;
      }
      currentBatman.outBowmanStack.clear();
    }
    batTeam.updateScore();
    notifyListeners();
    return checkGameFinished();
  }
}
