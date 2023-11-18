import 'package:cricket_app/models/game_model.dart';
import 'package:cricket_app/screens/archives_screen.dart';
import 'package:cricket_app/screens/ballbyball_screen.dart';
import 'package:cricket_app/screens/battle_screen.dart';
import 'package:cricket_app/screens/bowler_screen.dart';
import 'package:cricket_app/screens/summary_screen.dart';
import 'package:cricket_app/service/sqliteService.dart';
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
  bool isLoading = false;

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

    setState(() {
      isLoading = true;
    });
    GameModel model = Provider.of<GameModel>(context, listen: false);
    SqliteService.getStatus().then((savedModel) {
      if (savedModel.inning < 3 && savedModel.isGameStarted == true) {
        model.deepCopy(savedModel);
      }
      setState(() {
        isLoading = false;
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

  void startGame() {
    GameModel model = Provider.of<GameModel>(context, listen: false);
    model.startGame();
  }

  void goToSummary() async {
    final result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => SummaryScreen()));
    if (result == 'reset') {
      batController.reset!();
    }
  }

  void gotoBallbyball() async {
    final result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => const BallByBallScreen()));
    if (result == 'reset') {
      batController.reset!();
    }
  }

  void gotoArchive() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const ArchiveScreen()));
  }

  @override
  Widget build(BuildContext context) {
    GameModel model = Provider.of<GameModel>(context);
    return Scaffold(
        body: SafeArea(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(children: [
                    CricketHeaderWidget(
                        model.inning == 1 ? "1st Innings" : "2nd Innings",
                        _selectedIndex == 0
                            ? model.batTeam.name
                            : model.bowTeam.name,
                        _selectedIndex,
                        onChanged: !model.isGameStarted
                            ? (String name) => changeCurrentTeamName(name)
                            : null),
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
                    !model.isGameStarted
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              children: [
                                Expanded(
                                    child: ElevatedButton(
                                  onPressed: model.canStart ? startGame : null,
                                  child: const Text('Game Start'),
                                )),
                                const SizedBox(width: 20),
                                Expanded(
                                    child: ElevatedButton(
                                  onPressed: gotoArchive,
                                  child: const Text('Archives'),
                                ))
                              ],
                            ))
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                    child: ElevatedButton(
                                  onPressed: goToSummary,
                                  child: const Text(
                                    'Summary',
                                    style: TextStyle(fontSize: 11),
                                  ),
                                )),
                                const SizedBox(width: 16),
                                Expanded(
                                    child: ElevatedButton(
                                  onPressed: gotoBallbyball,
                                  child: const Text(
                                    'Ball by ball',
                                    style: TextStyle(fontSize: 11),
                                  ),
                                )),
                                const SizedBox(width: 16),
                                Expanded(
                                    child: ElevatedButton(
                                  onPressed: gotoArchive,
                                  child: const Text(
                                    'Archives',
                                    style: TextStyle(fontSize: 11),
                                  ),
                                )),
                              ],
                            ))
                  ])));
  }
}
