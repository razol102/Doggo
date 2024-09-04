// import 'package:flutter/material.dart';
// import 'package:mobile/common_widgets/outdoor_activity_row.dart';
//
// class ActivitiesList extends StatelessWidget {
//   final List<Map<String, dynamic>> activitiesArr;
//   final int? dogId;
//
//   const ActivitiesList({
//     Key? key,
//     required this.activitiesArr,
//     required this.dogId,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     if (activitiesArr.isEmpty) {
//       return const Center(child: Text("No Activities Available."));
//     }
//
//     return ListView.builder(
//       padding: EdgeInsets.zero,
//       physics: const NeverScrollableScrollPhysics(),
//       shrinkWrap: true,
//       itemCount: activitiesArr.length,
//       itemBuilder: (context, index) {
//         var wObj = activitiesArr[index];
//         return InkWell(
//           onTap: () {
//             //Navigator.pushNamed(context, FinishWorkoutScreen.routeName);
//           },
//           child: OutdoorActivityRow(wObj: wObj, dogId: dogId),
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:mobile/common_widgets/outdoor_activity_row.dart';

class ActivitiesList extends StatelessWidget {
  final List<Map<String, dynamic>> activitiesArr;
  final int? dogId;
  final String type; // "activity" or "goal"

  const ActivitiesList({
    Key? key,
    required this.activitiesArr,
    required this.dogId,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (activitiesArr.isEmpty) {
      return const Center(child: Text("No Data Available."));
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: activitiesArr.length,
      itemBuilder: (context, index) {
        var wObj = activitiesArr[index];
        return InkWell(
          onTap: () {
            // You can add navigation or any other action here when an item is tapped.
          },
          child: OutdoorActivityRow(
            item: wObj,
            dogId: dogId!,
            type: type, // Pass the type down to the OutdoorActivityRow
          ),
        );
      },
    );
  }
}
