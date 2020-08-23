import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:provider/provider.dart';
import 'package:water_recommender/model/user.dart';
import 'package:water_recommender/model/waterIntake.dart';
import 'package:water_recommender/screens/home/graph.dart';
import 'package:water_recommender/screens/home/waterDrinkingRecords.dart';
import 'package:water_recommender/services/database.dart';
import 'package:water_recommender/services/utils.dart';
import 'addDrinkBottomSheet.dart';
import 'package:intl/intl.dart';

class HomePageContent extends StatefulWidget {
  @override
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  int amount = 0;
  bool _showMonthGraph = false;
  Future setAmount(int intake) async {
    while (amount < intake) {
      setState(() {
        amount += 1;
      });

      await Future.delayed(Duration(microseconds: 5000));
    }
    while (intake < amount) {
      setState(() {
        amount -= 1;
      });
      await Future.delayed(Duration(microseconds: 500));
    }
  }

  List<bool> isSelected = [true, false];

  double percentGoalAchieved = 0.0;
  bool _isUpdating = false;

  @override
  Widget build(BuildContext context) {
    var dataConnectionStatus = Provider.of<DataConnectionStatus>(context);
    var allData = Provider.of<Map<String, List<WaterIntake>>>(context);

    UserData userData = Provider.of<UserData>(context) ??
        UserData(goal: 0, name: "new user", uid: "");

    int _avgWaterIntake;
    int _avgFreqIntake;
    int _targetAchiveRate;
    void _showRecordDringkSheet() {
      showModalBottomSheet(
          enableDrag: false,
          context: context,
          builder: (context) {
            return Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                child: RecordDrinkPage());
          });
    }

    final List<WaterIntake> intakes = Provider.of<List<WaterIntake>>(context);
    setState(() {
      percentGoalAchieved =
          Utils().getGoalAchievedPercent(intakes, userData.goal);
      _avgWaterIntake = Utils().getAverageIntake(allData).round();
      _avgFreqIntake = Utils().getFrequencyOfIntakePerDay(allData).round();
      _targetAchiveRate =
          (Utils().getTargetAchievementRate(allData, userData.goal) * 100)
              .round();
    });
    setAmount(Utils().getTotalIntakeTodayFromListOfIntakes(intakes));

    var children2 = [
      LiquidLinearProgressIndicator(
        value: percentGoalAchieved,
        direction: Axis.vertical,
        backgroundColor: Colors.transparent,
        valueColor: AlwaysStoppedAnimation(Colors.indigo.shade200),
      ),
      Column(
        children: [
          Row(
            children: [
              FlatButton(
                  onPressed: () {},
                  child: Container(
                    child: Row(
                      children: [
                        Icon(Icons.report,
                            size: 18.0, color: Colors.indigo.shade700),
                        SizedBox(width: 4.0),
                        Text(
                          "Drink some Water ${userData.name.toUpperCase()}",
                          style: TextStyle(
                              color: Colors.indigo.shade600,
                              fontWeight: FontWeight.normal),
                        ),
                        SizedBox(width: 8.0),
                        Icon(Icons.arrow_forward_ios,
                            size: 15.0, color: Colors.indigo.shade600)
                      ],
                    ),
                  )),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
          Text(
            amount.toString(),
            style: TextStyle(color: Colors.indigo.shade800, fontSize: 90.0),
          ),
          Row(
            children: [
              FlatButton(
                child: Text(
                    "${(percentGoalAchieved * 100).round()} % completed",
                    style: TextStyle(fontWeight: FontWeight.normal)),
                onPressed: () {},
                padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 6.0),
              ),
              FlatButton(
                onPressed: () {},
                child: Row(children: [
                  Text(
                    "Goal ${userData.goal} ml",
                    style: TextStyle(fontWeight: FontWeight.normal),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 18.0,
                  )
                ]),
                padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 6.0),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
          SizedBox(
            height: 80.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildClipOval(50, dataConnectionStatus),
              buildClipOval(150, dataConnectionStatus),
              buildClipOval(200, dataConnectionStatus),
              buildClipOval(250, dataConnectionStatus),
              buildClipOval(300, dataConnectionStatus)
            ],
          ),
        ],
      ),
    ];

    return  Container(
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        SizedBox(
          height: MediaQuery.of(context).size.height / 2,
          child: Stack(children: children2),
        ),

        SizedBox(
          child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
              colors: [Colors.indigo.shade200, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.center,
            )),
            child: Column(
              children: [
                FlatButton(
                  onPressed: _showRecordDringkSheet,
                  child: Text(
                    "Record drink",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.normal),
                  ),
                  padding:
                      EdgeInsets.symmetric(vertical: 2.0, horizontal: 32.0),
                  color: Colors.blue.shade800,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                SizedBox(height: 20.0),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(Radius.circular(20.0))),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 8.0, 8.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Today's water drinking records"),
                              IconButton(
                                icon: Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.grey.shade500,
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          WaterRecordPage(
                                            intakes: intakes,
                                          )));
                                },
                              )
                            ],
                          ),
                          AbsorbPointer(
                            child: Container(
                              height: intakes.length > 3
                                  ? 3 * 56.0
                                  : intakes.length * 56.0,
                              child: ListView.builder(
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text("${intakes[index].drinkType}"),
                                    leading: _getDrinkIcon(index, intakes),
                                    trailing: Text("${intakes[index].time}"),
                                  );
                                },
                                itemCount:
                                    intakes.length > 3 ? 3 : intakes.length,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                SizedBox(
                  height: 40.0,
                  child: ToggleButtons(
                    children: [
                      Padding(
                        child: Text("Past 7 days"),
                        padding: EdgeInsets.symmetric(
                            vertical: 0.0, horizontal: 8.0),
                      ),
                      Padding(
                        child: Text("Last month"),
                        padding: EdgeInsets.symmetric(
                            vertical: 0.0, horizontal: 8.0),
                      ),
                    ],
                    borderColor: Colors.indigo.shade400,
                    disabledBorderColor: Colors.indigo.shade400,
                    selectedBorderColor: Colors.indigo.shade400,
                    fillColor: Colors.indigo.shade400,
                    color: Colors.indigo.shade400,
                    selectedColor: Colors.white,
                    isSelected: isSelected,
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    onPressed: (int index) {
                      setState(() {
                        isSelected = isSelected.reversed.toList();
                        _showMonthGraph = !_showMonthGraph;
                      });
                    },
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              "$_avgWaterIntake",
                              style: TextStyle(
                                  fontSize: 36.0,
                                  fontWeight: FontWeight.normal),
                            ),
                            Text("ml/days",
                                textAlign: TextAlign.left,
                                style:
                                    TextStyle(fontWeight: FontWeight.normal)),
                            Text(
                              "Average water \nintake",
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  "$_avgFreqIntake",
                                  style: TextStyle(
                                      fontSize: 36.0,
                                      fontWeight: FontWeight.normal),
                                ),
                                Text("times/day",
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal))
                              ],
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                            ),
                            Text(
                              "Average \nfrequency of \nwater intake",
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  "$_targetAchiveRate",
                                  style: TextStyle(
                                      fontSize: 36.0,
                                      fontWeight: FontWeight.normal),
                                ),
                                Text("%",
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal))
                              ],
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                            ),
                            Text(
                              "Target \nachievement rate",
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        ),
                      ),
                    ],
                  ),
                ),
                Provider.value(child: GraphView(), value: _showMonthGraph,),
              ],
            ),
          ),
        ),
        // Test(),
      ]),
    );
  }

  Icon _getDrinkIcon(int index, List<WaterIntake> intakes) {
    switch (intakes[index].drinkType) {
      case "soda":
        {
          return Icon(
            Icons.local_drink_outlined,
            size: 20.0,
            color: Colors.indigo.shade400,
          );
        }
      case "coffee":
        {
          return Icon(
            Icons.local_cafe_outlined,
            size: 20.0,
            color: Colors.indigo.shade400,
          );
        }
      case "tea":
        {
          return Icon(
            Icons.emoji_food_beverage_outlined,
            size: 20.0,
            color: Colors.indigo.shade400,
          );
        }
      case "juice":
        {
          return Icon(
            Icons.local_bar_outlined,
            size: 20.0,
            color: Colors.indigo.shade400,
          );
        }

      default:
        {
          return Icon(
            SimpleLineIcons.drop,
            size: 20.0,
            color: Colors.indigo.shade400,
          );
        }
    }
  }

  Widget buildClipOval(int capacity, DataConnectionStatus connectionStatus) {
    var user = Provider.of<User>(context);
    var allData = Provider.of<Map<String, List<WaterIntake>>>(context);
    return _isUpdating && connectionStatus == DataConnectionStatus.connected
        ? CircularProgressIndicator(
            backgroundColor: Colors.white,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo.shade600),
          )
        : Opacity(
            opacity: 0.8,
            child: GestureDetector(
              onTap: () async {
                setState(() {
                  _isUpdating = true;
                });
                print(allData);
                await DatabaseService(uid: user.uid).addDailyData(WaterIntake(
                    amount: capacity,
                    time: "${DateFormat.Hms().format(DateTime.now())}",
                    drinkType: "water",
                    calories: 0));
                setState(() {
                  _isUpdating = false;
                });
              },
              child: Card(
                color: Colors.white,
                elevation: 8.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30.0))),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(
                        SimpleLineIcons.drop,
                        color: Colors.indigo.shade500,
                        size: 16.0,
                      ),
                      Text(
                        capacity.toString(),
                        style: TextStyle(
                            color: Colors.indigo.shade500,
                            fontWeight: FontWeight.normal,
                            fontSize: 12.0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
