import 'dart:convert';
import 'dart:math';

import 'package:cricket_app/helper/game.dart';
import 'package:cricket_app/models/player_model.dart';
import 'package:cricket_app/models/team_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const int APP_VERSION = 2;

class GameModel extends ChangeNotifier {
  late TeamModel _teamA;
  late TeamModel _teamB;

  int _inning = 1;
  int _outPenalty = -1;
  int _limitBall = -1;

  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now();

  bool _isGameStarted = false;

  GameModel() {
    _teamA = TeamModel("T1");
    _teamB = TeamModel("T2");
    _teamA.addListener(() => notifyListeners());
    _teamB.addListener(() => notifyListeners());
  }

  bool get isGameStarted => _isGameStarted;
  bool get canDelete => team1.playerList.length > 1;
  List<GameState> get history => batTeam.history;
  bool get canUndo => history.isNotEmpty;
  bool get canStart => _limitBall > 0 && _outPenalty > 0;

  TeamModel get batTeam => _inning == 1 ? _teamA : _teamB;
  TeamModel get bowTeam => _inning == 2 ? _teamA : _teamB;

  TeamModel get team1 => _teamA;
  TeamModel get team2 => _teamB;

  String get over => overString(batTeam.over);

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
    if (_inning < 3) endTime = DateTime.now();
    notifyListeners();
    return _inning < 3;
  }

  int get outPenalty => _outPenalty;
  set outPenalty(int penalty) {
    _outPenalty = penalty;
    notifyListeners();
  }

  int get limitBall => _limitBall;
  set limitBall(int limitBall) {
    _limitBall = limitBall;
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
      return '${team2.name} has beaten ${team1.name} with successful run chase having $remainBall ${remainBall > 1 ? 'balls' : 'ball'} left.';
    } else {
      final diffRun = team1.run - team2.run;
      return '${team1.name} has beaten ${team2.name} by $diffRun runs.';
    }
  }

  String get gameSummary {
    return "${DateFormat('dd MMM yyyy hh:mm a').format(startTime)} ${team1.name}: ${team1.run} runs (${overString(team1.over)} overs) vs ${team2.name}: ${team2.run} runs (${overString(team2.over)} overs) [Out penalty: ${outPenalty}]";
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

  void startGame() {
    _isGameStarted = true;
    notifyListeners();
  }

  void reset() {
    _teamA = TeamModel("T1");
    _teamB = TeamModel("T2");
    _inning = 1;
    _outPenalty = -1;
    _limitBall = -1;
    _isGameStarted = false;

    _teamA.addListener(() => notifyListeners());
    _teamB.addListener(() => notifyListeners());
    notifyListeners();
  }

  void startOver() {
    _teamA.reset();
    _teamB.reset();
    _inning = 1;
    _isGameStarted = true;
    startTime = DateTime.now();

    _teamA.addListener(() => notifyListeners());
    _teamB.addListener(() => notifyListeners());
    notifyListeners();
  }

  void addPlayer() {
    team1.addPlayer();
    team2.addPlayer();
    notifyListeners();
  }

  void removePlayer() {
    team1.removePlayer();
    team2.removePlayer();
    notifyListeners();
  }

  AddStateType add(
      bool isWideChecked, bool isNoBallChecked, bool isOut, int score) {
    // calculate score
    if (currentBatman.ball == limitBall) return AddStateType.batmanLimitBall;
    if (currentBowman.givenBall == limitBall) {
      return AddStateType.bolwerLimitBall;
    }

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
      int i = currentBatman.outBowmanStack.list.length - 1;
      while (score < 0 && i >= 0) {
        currentBatman.outBowmanStack.list[i--].givenRun -= APP_VERSION == 1
            ? max(score, -outPenalty)
            : -max(score, -outPenalty);
        score += outPenalty;
      }
    }
    batTeam.updateScore();

    history.add(GameState(
        currentBatman: currentBatman,
        currentBowman: currentBowman,
        isWideChecked: isWideChecked,
        isNoBallChecked: isNoBallChecked,
        isOut: isOut,
        score: score,
        over: batTeam.over));

    notifyListeners();
    return checkGameFinished()
        ? AddStateType.nextInnings
        : AddStateType.success;
  }

  bool undo() {
    // calculate score
    if (history.isEmpty) return false;
    GameState state = history.last;
    history.removeLast();

    // case of batman's score reaches to max-ball
    if (state.currentBatman!.ball == limitBall) {
      int score = state.currentBatman!.run;
      int i = state.currentBatman!.outBowmanStack.list.length - 1;
      while (score < 0 && i >= 0) {
        state.currentBatman!.outBowmanStack.list[i--].givenRun +=
            APP_VERSION == 1
                ? max(score, -outPenalty)
                : -max(score, -outPenalty);
        score += outPenalty;
      }
    }

    int reward =
        (state.isWideChecked ? 1 : 0) + (state.isNoBallChecked ? 1 : 0);
    int penalty = (state.isOut ? outPenalty : 0);
    bool isValidDelivery = (!state.isWideChecked && !state.isNoBallChecked);

    // update batman's score
    state.currentBatman!.run -= reward + state.score - penalty;
    state.currentBatman!.ball -= isValidDelivery ? 1 : 0;
    if (state.isOut) state.currentBatman!.outBowmanStack.pop();

    // calculate over
    batTeam.over -= (!state.isWideChecked && !state.isNoBallChecked) ? 1 : 0;

    // update bowmans score;
    state.currentBowman!.givenRun -= reward + state.score - penalty;
    state.currentBowman!.givenBall -= isValidDelivery ? 1 : 0;

    currentBatman = state.currentBatman!;
    currentBatman = state.currentBowman!;

    batTeam.updateScore();
    notifyListeners();
    return checkGameFinished();
  }

  String get lastGameState {
    return history.last.toString();
  }

  GameModel fromMap(Map<String, dynamic> data) {
    _teamA = TeamModel.fromMap(data["teamA"]);
    _teamB = TeamModel.fromMap(data["teamB"]);
    _outPenalty = data["outPenalty"];
    _limitBall = data["limitBall"];
    _inning = 3;
    _isGameStarted = false;
    startTime = DateTime.fromMillisecondsSinceEpoch(data["startTime"]);
    endTime = DateTime.fromMillisecondsSinceEpoch(data["endTime"]);
    return this;
  }

  Map<String, Object> toMap() {
    Map<String, Object> result = {};
    result["teamA"] = _teamA.toMap();
    result["teamB"] = _teamB.toMap();
    result["outPenalty"] = _outPenalty;
    result["limitBall"] = _limitBall;
    result["startTime"] = startTime.millisecondsSinceEpoch;
    result["endTime"] = endTime.millisecondsSinceEpoch;
    return result;
  }

  String toJson() {
    return json.encode(toMap());
  }

  GameModel.fromJson(String jsonData) {
    fromMap(json.decode(jsonData));
  }
}

enum AddStateType { success, batmanLimitBall, bolwerLimitBall, nextInnings }

class GameState {
  bool isWideChecked = false, isNoBallChecked = false, isOut = false;
  PlayerModel? currentBatman, currentBowman;
  int score = 0, over = 0;

  GameState(
      {this.currentBatman,
      this.currentBowman,
      this.isWideChecked = false,
      this.isNoBallChecked = false,
      this.isOut = false,
      this.score = 0,
      this.over = 0});

  @override
  String toString() {
    String message = "";
    if (isWideChecked) message += "Wide";
    if (isNoBallChecked) {
      message += "${message.isEmpty ? "" : "+"}No Ball";
    }
    if (isOut) {
      message += "${message.isEmpty ? "" : "+"}Out";
    }
    if (score > 0) {
      message += "${message.isEmpty ? "" : "+"}$score";
    }
    return message;
  }
}
