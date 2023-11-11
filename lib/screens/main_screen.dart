import 'package:cricket_app/models/game_model.dart';
import 'package:cricket_app/screens/battle_screen.dart';
import 'package:cricket_app/screens/bowler_screen.dart';
import 'package:cricket_app/screens/summary_screen.dart';
import 'package:cricket_app/widgets/cricket_header.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late final TabController _tabController;
  int _selectedIndex = 0;
  final BattingScreenController batController = BattingScreenController();

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 2, vsync: this, animationDuration: Duration.zero);

    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void changeCurrentTeamName(String name) {
    GameModel model = Provider.of<GameModel>(context, listen: false);
    if (_selectedIndex == 0) {
      model.batTeam.name = name;
    } else {
      model.bowTeam.name = name;
    }
  }

  void goToSummary() async {
    final result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => const SummaryScreen()));
    if (result == 'reset') {
      batController.reset!();
    }
  }

  @override
  Widget build(BuildContext context) {
    GameModel model = Provider.of<GameModel>(context);
    return Scaffold(
        body: SafeArea(
            child: Column(children: [
      CricketHeaderWidget(
          "${model.inning}st Innings",
          _selectedIndex == 0 ? model.batTeam.name : model.bowTeam.name,
          _selectedIndex,
          onChanged: (String name) => changeCurrentTeamName(name)),
      TabBar(
        controller: _tabController,
        labelColor: Colors.green,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(5.0),
        indicatorColor: Colors.green,
        tabs: const <Widget>[
          Tab(
            text: "Batting",
          ),
          Tab(
            text: "Bowling",
          ),
        ],
      ),
      Expanded(
        child: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: <Widget>[
            BattingScreen(controller: batController),
            const BowlerScreen()
          ],
        ),
      ),
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Expanded(
                  child: ElevatedButton(
                onPressed: goToSummary,
                child: const Text('Summary'),
              ))
            ],
          ))
    ])));
  }
}
