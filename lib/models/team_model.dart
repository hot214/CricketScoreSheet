import 'package:cricket_app/const/global.dart';
import 'package:cricket_app/models/player_model.dart';
import 'package:flutter/material.dart';

class TeamModel extends ChangeNotifier {
  String _name = 'None';
  int _current = 0;
  int _over = 0;
  List<PlayerModel> _player_list = [];
  List<PlayerModel> get playerList => _player_list;

  int _run = 0;
  int _ball = 0;

  int get over => _over;
  set over(int over) {
    _over = over;
    notifyListeners();
  }

  int get run => _run;
  set run(int run) {
    _run = run;
    notifyListeners();
  }

  int get ball => _ball;
  set ball(int ball) {
    _ball = ball;
    notifyListeners();
  }

  TeamModel(this._name) {
    _player_list.clear();
    for (int i = 0; i < GLOBAL['PLAYER_COUNT']; i++) {
      _player_list.add(PlayerModel("Player ${i + 1}"));
    }
  }

  PlayerModel get currentPlayer => _player_list[_current];
  set currentPlayer(PlayerModel player) {
    for (var i = 0; i < _player_list.length; i++) {
      if (_player_list[i] == player) _current = i;
    }
    notifyListeners();
  }

  String get name => _name;

  set name(String name) {
    _name = name;
    notifyListeners();
  }

  void setPlayer(List<PlayerModel> player) {
    _player_list = player;
    notifyListeners();
  }

  void updateScore() {
    var totalRun = 0;
    var totalBall = 0;

    for (var index = 0; index < _player_list.length; index++) {
      totalRun += _player_list[index].run > 0 ? _player_list[index].run : 0;
      totalBall += _player_list[index].ball;
    }
    _run = totalRun;
    _ball = totalBall;
    notifyListeners();
  }

  void switchOrder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    var current = _player_list[_current];
    var item = _player_list.removeAt(oldIndex);
    _player_list.insert(newIndex, item);
    _current = _player_list.indexOf(current);
    print(_current);
    notifyListeners();
  }

  TeamSummary getSummary({String type = 'bat'}) {
    TeamSummary data =
        TeamSummary(name: name, run: run, ball: ball, type: type);
    List<List<String>> stat = [];
    for (var i = 0; i < playerList.length; i++) {
      List<String> item = [];
      item.add("${i + 1}");
      item.add(playerList[i].name);
      if (type == 'bat') {
        item.add("${playerList[i].run}");
        item.add("${playerList[i].ball}");
      } else if (type == 'bow') {
        item.add("${playerList[i].givenBall}");
        item.add("${playerList[i].givenRun}");
      }
      stat.add(item);
    }
    data.data = stat;
    return data;
  }
}

class TeamSummary {
  String name;
  String type;
  int run, ball;

  List<List<String>> data = List.empty();
  final List<String> header = <String>['No', 'Player', 'Run', 'Ball'];

  TeamSummary({this.name = '', this.run = 0, this.ball = 0, this.type = 'bat'});
}
