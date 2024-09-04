// import 'package:mobile/utils/app_colors.dart';
// import 'package:mobile/screens/activity/widgets/upcoming_workout_row.dart';
// import 'package:mobile/screens/activity/widgets/what_train_row.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
//
// import '../../common_widgets/round_button.dart';
//
// class ActivityScreen extends StatefulWidget {
//   const ActivityScreen({Key? key}) : super(key: key);
//   static String routeName = "/ActivityScreen";
//
//
//   @override
//   State<ActivityScreen> createState() => _ActivityScreenState();
// }
//
// class _ActivityScreenState extends State<ActivityScreen> {
//
//   List latestArr = [
//     {
//       "image": "assets/images/Workout1.png",
//       "title": "Fullbody Workout",
//       "time": "Today, 03:00pm"
//     },
//     {
//       "image": "assets/images/Workout2.png",
//       "title": "Upperbody Workout",
//       "time": "June 05, 02:00pm"
//     },
//   ];
//
//   List whatArr = [
//     {
//       "image": "assets/images/what_1.png",
//       "title": "Fullbody Workout",
//       "exercises": "11 Exercises",
//       "time": "32mins"
//     },
//     {
//       "image": "assets/images/what_2.png",
//       "title": "Lowebody Workout",
//       "exercises": "12 Exercises",
//       "time": "40mins"
//     },
//     {
//       "image": "assets/images/what_3.png",
//       "title": "AB Workout",
//       "exercises": "14 Exercises",
//       "time": "20mins"
//     }
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     var media = MediaQuery.of(context).size;
//     return Container(
//       decoration:
//       BoxDecoration(gradient: LinearGradient(colors: AppColors.primaryG)),
//       child: NestedScrollView(
//         headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
//           return [
//             const SliverAppBar(
//               backgroundColor: Colors.transparent,
//               centerTitle: true,
//               elevation: 0,
//               // pinned: true,
//               title: Text(
//                 "Dog Activities",
//                 style: TextStyle(
//                     color: AppColors.whiteColor,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w700),
//               ),
//               actions: [
//
//               ],
//             ),
//             SliverAppBar(
//               backgroundColor: Colors.transparent,
//               centerTitle: true,
//               elevation: 0,
//               leadingWidth: 0,
//               leading: const SizedBox(),
//               expandedHeight: media.height * 0.21,
//               flexibleSpace: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 height: media.width * 0.5,
//                 width: double.maxFinite,
//                 child: LineChart(
//                   LineChartData(
//                     lineTouchData: LineTouchData(
//                       enabled: true,
//                       handleBuiltInTouches: false,
//                       touchCallback:
//                           (FlTouchEvent event, LineTouchResponse? response) {
//                         if (response == null || response.lineBarSpots == null) {
//                           return;
//                         }
//                       },
//                       mouseCursorResolver:
//                           (FlTouchEvent event, LineTouchResponse? response) {
//                         if (response == null || response.lineBarSpots == null) {
//                           return SystemMouseCursors.basic;
//                         }
//                         return SystemMouseCursors.click;
//                       },
//                       getTouchedSpotIndicator:
//                           (LineChartBarData barData, List<int> spotIndexes) {
//                         return spotIndexes.map((index) {
//                           return TouchedSpotIndicatorData(
//                             const FlLine(
//                               color: Colors.transparent,
//                             ),
//                             FlDotData(
//                               show: true,
//                               getDotPainter: (spot, percent, barData, index) =>
//                                   FlDotCirclePainter(
//                                     radius: 3,
//                                     color: Colors.white,
//                                     strokeWidth: 3,
//                                     strokeColor: AppColors.secondaryColor1,
//                                   ),
//                             ),
//                           );
//                         }).toList();
//                       },
//                       touchTooltipData: LineTouchTooltipData(
//                         //tooltipBgColor: AppColors.secondaryColor1,
//                         tooltipRoundedRadius: 20,
//                         getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
//                           return lineBarsSpot.map((lineBarSpot) {
//                             return LineTooltipItem(
//                               "${lineBarSpot.x.toInt()} mins ago",
//                               const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             );
//                           }).toList();
//                         },
//                       ),
//                     ),
//                     lineBarsData: lineBarsData1,
//                     minY: -0.5,
//                     maxY: 110,
//                     titlesData: FlTitlesData(
//                         show: true,
//                         leftTitles: AxisTitles(),
//                         topTitles: AxisTitles(),
//                         bottomTitles: AxisTitles(
//                           sideTitles: bottomTitles,
//                         ),
//                         rightTitles: AxisTitles(
//                           sideTitles: rightTitles,
//                         )),
//                     gridData: FlGridData(
//                       show: true,
//                       drawHorizontalLine: true,
//                       horizontalInterval: 25,
//                       drawVerticalLine: false,
//                       getDrawingHorizontalLine: (value) {
//                         return FlLine(
//                           color: AppColors.whiteColor.withOpacity(0.15),
//                           strokeWidth: 2,
//                         );
//                       },
//                     ),
//                     borderData: FlBorderData(
//                       show: true,
//                       border: Border.all(
//                         color: Colors.transparent,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             )
//           ];
//         },
//         body: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             decoration: const BoxDecoration(
//                 color: AppColors.whiteColor,
//                 borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(25),
//                     topRight: Radius.circular(25))),
//             child: Scaffold(
//               backgroundColor: Colors.transparent,
//               body: SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     const SizedBox(
//                       height: 10,
//                     ),
//                     Container(
//                       width: 50,
//                       height: 4,
//                       decoration: BoxDecoration(
//                           color: AppColors.grayColor.withOpacity(0.3),
//                           borderRadius: BorderRadius.circular(3)),
//                     ),
//                     SizedBox(
//                       height: media.width * 0.05,
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 15, horizontal: 15),
//                       decoration: BoxDecoration(
//                         color: AppColors.primaryColor2.withOpacity(0.3),
//                         borderRadius: BorderRadius.circular(15),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Text(
//                             "Daily Workout Schedule",
//                             style: TextStyle(
//                                 color: AppColors.blackColor,
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w700),
//                           ),
//                           SizedBox(
//                             width: 70,
//                             height: 25,
//                             child: RoundButton(
//                               title: "Check",
//                               onPressed: () {
//                                 // Navigator.push(
//                                 //   context,
//                                 //   MaterialPageRoute(
//                                 //     builder: (context) =>
//                                 //         const ActivityTrackerView(),
//                                 //   ),
//                                 // );
//                               }, backgroundColor: AppColors.blackColor, titleColor: AppColors.whiteColor,
//                             ),
//                           )
//                         ],
//                       ),
//                     ),
//                     SizedBox(
//                       height: media.width * 0.05,
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Text(
//                           "Upcoming Workout",
//                           style: TextStyle(
//                               color: AppColors.blackColor,
//                               fontSize: 16,
//                               fontWeight: FontWeight.w700),
//                         ),
//                         TextButton(
//                           onPressed: () {},
//                           child: const Text(
//                             "See More",
//                             style: TextStyle(
//                                 color: AppColors.grayColor,
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w700),
//                           ),
//                         )
//                       ],
//                     ),
//                     ListView.builder(
//                         padding: EdgeInsets.zero,
//                         physics: const NeverScrollableScrollPhysics(),
//                         shrinkWrap: true,
//                         itemCount: latestArr.length,
//                         itemBuilder: (context, index) {
//                           var wObj = latestArr[index] as Map? ?? {};
//                           return UpcomingWorkoutRow(wObj: wObj);
//                         }),
//                     SizedBox(
//                       height: media.width * 0.05,
//                     ),
//                     const Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           "What Do You Want to Train",
//                           style: TextStyle(
//                               color: AppColors.blackColor,
//                               fontSize: 16,
//                               fontWeight: FontWeight.w700),
//                         ),
//                       ],
//                     ),
//                     ListView.builder(
//                         padding: EdgeInsets.zero,
//                         physics: const NeverScrollableScrollPhysics(),
//                         shrinkWrap: true,
//                         itemCount: whatArr.length,
//                         itemBuilder: (context, index) {
//                           var wObj = whatArr[index] as Map? ?? {};
//                           return InkWell(
//                               onTap: (){
//                                 //Navigator.push(context, MaterialPageRoute(builder: (context) =>  WorkoutDetailView( dObj: wObj, ) ));
//                               },
//                               child:  WhatTrainRow(wObj: wObj) );
//                         }),
//                     SizedBox(
//                       height: media.width * 0.1,
//                     ),
//                   ],
//                 ),
//               ),
//             )),
//       ),
//     );
//   }
//
//   LineTouchData get lineTouchData1 => const LineTouchData(
//     handleBuiltInTouches: true,
//     touchTooltipData: LineTouchTooltipData(
//       //tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
//     ),
//   );
//
//   List<LineChartBarData> get lineBarsData1 => [
//     lineChartBarData1_1,
//     lineChartBarData1_2,
//   ];
//
//   LineChartBarData get lineChartBarData1_1 => LineChartBarData(
//     isCurved: true,
//     color: AppColors.whiteColor,
//     barWidth: 4,
//     isStrokeCapRound: true,
//     dotData: FlDotData(show: false),
//     belowBarData: BarAreaData(show: false),
//     spots: const [
//       FlSpot(1, 35),
//       FlSpot(2, 70),
//       FlSpot(3, 40),
//       FlSpot(4, 80),
//       FlSpot(5, 25),
//       FlSpot(6, 70),
//       FlSpot(7, 35),
//     ],
//   );
//
//   LineChartBarData get lineChartBarData1_2 => LineChartBarData(
//     isCurved: true,
//     color: AppColors.whiteColor.withOpacity(0.5),
//     barWidth: 2,
//     isStrokeCapRound: true,
//     dotData: FlDotData(show: false),
//     belowBarData: BarAreaData(
//       show: false,
//     ),
//     spots: const [
//       FlSpot(1, 80),
//       FlSpot(2, 50),
//       FlSpot(3, 90),
//       FlSpot(4, 40),
//       FlSpot(5, 80),
//       FlSpot(6, 35),
//       FlSpot(7, 60),
//     ],
//   );
//
//   SideTitles get rightTitles => SideTitles(
//     getTitlesWidget: rightTitleWidgets,
//     showTitles: true,
//     interval: 20,
//     reservedSize: 40,
//   );
//
//   Widget rightTitleWidgets(double value, TitleMeta meta) {
//     String text;
//     switch (value.toInt()) {
//       case 0:
//         text = '0%';
//         break;
//       case 20:
//         text = '20%';
//         break;
//       case 40:
//         text = '40%';
//         break;
//       case 60:
//         text = '60%';
//         break;
//       case 80:
//         text = '80%';
//         break;
//       case 100:
//         text = '100%';
//         break;
//       default:
//         return Container();
//     }
//
//     return Text(text,
//         style: const TextStyle(
//           color: AppColors.whiteColor,
//           fontSize: 12,
//         ),
//         textAlign: TextAlign.center);
//   }
//
//   SideTitles get bottomTitles => SideTitles(
//     showTitles: true,
//     reservedSize: 32,
//     interval: 1,
//     getTitlesWidget: bottomTitleWidgets,
//   );
//
//   Widget bottomTitleWidgets(double value, TitleMeta meta) {
//     var style = const TextStyle(
//       color: AppColors.whiteColor,
//       fontSize: 12,
//     );
//     Widget text;
//     switch (value.toInt()) {
//       case 1:
//         text = Text('Sun', style: style);
//         break;
//       case 2:
//         text = Text('Mon', style: style);
//         break;
//       case 3:
//         text = Text('Tue', style: style);
//         break;
//       case 4:
//         text = Text('Wed', style: style);
//         break;
//       case 5:
//         text = Text('Thu', style: style);
//         break;
//       case 6:
//         text = Text('Fri', style: style);
//         break;
//       case 7:
//         text = Text('Sat', style: style);
//         break;
//       default:
//         text = const Text('');
//         break;
//     }
//
//     return SideTitleWidget(
//       axisSide: meta.axisSide,
//       space: 10,
//       child: text,
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:mobile/screens/activity/start_new_activity.dart';
import 'package:mobile/screens/activity/widgets/activities_list.dart';
import 'package:mobile/screens/activity/widgets/activity_circles_widget.dart';
import '../../common_widgets/round_button.dart';
import '../../main.dart';
import '../../services/http_service.dart';
import '../../services/preferences_service.dart';
import '../../utils/app_colors.dart';
import 'activities_history.dart';

class ActivityScreen extends StatefulWidget {
  static String routeName = "/ActivityScreen";

  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> with RouteAware{
  int? _dogId;
  late List<Map<String, dynamic>> goalsArr = [];

  @override
  void initState() {
    super.initState();
    _loadDogId();
    _fetchDog3LatestGoals();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void didPopNext() {
    _fetchDog3LatestGoals();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  Future<void> _loadDogId() async {
    final dogId = await PreferencesService.getDogId();
    setState(() {
      _dogId = dogId;
    });
  }

  Future<void> _startActivity(BuildContext context, String activityType) async {
    if (_dogId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StartNewActivityScreen(activityType: activityType, dogId: _dogId!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to retrieve dog ID')),
      );
    }
  }

  void _fetchDog3LatestGoals() async {
    final dogId = await PreferencesService.getDogId();
    if (dogId != null) {
      final goals = await HttpService.getGoalsList(dogId, 3, 0); // request for the latest 3 activities
      if (goals != null) {
        setState(() {
          goalsArr = goals;
        });
      }
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "Activities & Goals",
          style: TextStyle(
              color: AppColors.blackColor,
              fontSize: 16,
              fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView( // Add this to enable scrolling
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16), // Padding inside the container
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: AppColors.primaryG), // Gradient background
                borderRadius: BorderRadius.circular(media.width * 0.065), // Rounded corners
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    "assets/icons/bg_dots.png",
                    height: media.width * 0.4,
                    width: double.maxFinite,
                    fit: BoxFit.fitHeight,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 1),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Add New Activity",
                          style: TextStyle(
                              color: AppColors.blackColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 7),
                        ActivityCirclesWidget(
                          onActivitySelected: (activityType) {
                            _startActivity(context, activityType);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: media.width * 0.05),
            const Divider(),
            SizedBox(height: media.width * 0.0005),
            RoundButton(
                title: "Show Activities History",
                onPressed: () {
                  if (_dogId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ActivitiesHistoryScreen(dogId: _dogId!, type: 'activity',),
                      ),
                    );
                  } else {
                    // Handle case where dogId is null, e.g., show an error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to retrieve dog ID')),
                    );
                  }
                },
                backgroundColor: AppColors.primaryColor2,
                titleColor: AppColors.whiteColor),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Latest Goals",
                  style: TextStyle(
                    color: AppColors.blackColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit),
                  color: AppColors.primaryColor1,
                  onPressed: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => GoalsHistoryScreen(dogId: dogId!),
                    //   ),
                    // );
                  },
                  tooltip: 'Create Goal',
                ),
                SizedBox(width: media.width * 0.35),
                IconButton(
                  icon: Icon(Icons.open_in_new),
                  color: AppColors.primaryColor1,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ActivitiesHistoryScreen(dogId: _dogId!, type: 'goal',),
                      ),
                    );
                  },
                  tooltip: 'Open Goals History',
                ),
              ],
            ),
            ActivitiesList(activitiesArr: goalsArr, dogId: _dogId, type: 'goal',),
            SizedBox(
              height: media.width * 0.1,
            ),
          ],
        ),
      ),
    );
  }
}
