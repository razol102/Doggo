import 'package:flutter/material.dart';
import 'package:mobile/screens/activity/widgets/outdoor_activity_goal_row.dart';

class ActivitiesGoalsList extends StatelessWidget {
  final List<Map<String, dynamic>> ItemsArr;
  final int? dogId;
  final String type; // "activity" or "goal" or "template"

  const ActivitiesGoalsList({
    Key? key,
    required this.ItemsArr,
    required this.dogId,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (ItemsArr.isEmpty) {
      return const Center(child: Text("No Data Available."));
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: ItemsArr.length,
      itemBuilder: (context, index) {
        var wObj = ItemsArr[index];
        return InkWell(
          onTap: () {
          },
          child: OutdoorActivityGoalRow(
            item: wObj,
            dogId: dogId!,
            type: type, // Pass the type down to the OutdoorActivityRow
          ),
        );
      },
    );
  }
}
