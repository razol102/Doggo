import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../services/http_service.dart'; // Assuming this is where the HttpService is located

class BcsPieChart extends StatefulWidget {
  final int dogId;  // Pass the dogId to fetch the BCS

  const BcsPieChart({Key? key, required this.dogId}) : super(key: key);

  @override
  _BcsPieChartState createState() => _BcsPieChartState();
}

class _BcsPieChartState extends State<BcsPieChart> {
  int? currentScore;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBcsScore();
  }

  Future<void> _fetchBcsScore() async {
    try {
      int? fetchedScore = await HttpService.getBCS(widget.dogId);
      // int fetchedScore = 7;
      if (fetchedScore != null) {
        setState(() {
          currentScore = fetchedScore;
          isLoading = false;
        });
      } else {
        throw Exception();
      }
    } catch (e) {
      // Handle the error by setting a default or showing a message
      setState(() {
        currentScore = null;
        isLoading = false;
      });
      print("Failed to fetch BCS: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Container(
      height: media.width * 0.4,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: AppColors.primaryG),
        borderRadius: BorderRadius.circular(media.width * 0.065),
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
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "BCS",
                        style: TextStyle(
                            color: AppColors.whiteColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                      ),
                      const Text(
                        "(Body Condition Score)",
                        style: TextStyle(
                            color: AppColors.whiteColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: media.width * 0.02),
                      // Display a loading message or the actual score message
                      isLoading
                          ? Text(
                        "Loading...",
                        style: TextStyle(
                          color: AppColors.whiteColor.withOpacity(0.95),
                          fontSize: 12,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w400,
                        ),
                      )
                          : Text(
                        currentScore != null
                            ? getBcsMessage(currentScore!)
                            : "Error fetching BCS",
                        style: TextStyle(
                          color: AppColors.whiteColor.withOpacity(0.95),
                          fontSize: 12,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: media.width * 0.05),
                    ],
                  ),
                ),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: isLoading || currentScore == null
                        ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.whiteColor),
                    )
                        : PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (FlTouchEvent event, pieTouchResponse) {},
                        ),
                        startDegreeOffset: 250,
                        borderData: FlBorderData(
                          show: false,
                        ),
                        sectionsSpace: 1,
                        centerSpaceRadius: 0,
                        sections: showingSections(currentScore!),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Function to generate the appropriate message based on BCS score
  String getBcsMessage(int score) {
    if (score <= 3) {
      return "Your dog is underweight";
    } else if (score <= 6) {
      return "Your dog has a normal weight";
    } else if (score <= 9) {
      return "Your dog is overweight";
    } else {
      return "Invalid BCS score";
    }
  }

  // Adjust the PieChart sections based on the current score
  List<PieChartSectionData> showingSections(int currentScore) {
    const maxScore = 9;  // Maximum value for the chart
    final scorePercentage = (currentScore / maxScore) * 100;
    final remainingPercentage = 100 - scorePercentage;

    return List.generate(
      2,
          (i) {
        const color0 = AppColors.secondaryColor2;
        const color1 = AppColors.whiteColor;

        switch (i) {
          case 0:
            return PieChartSectionData(
                color: color0,
                value: scorePercentage,
                title: '',
                radius: 55,
                titlePositionPercentageOffset: 0.55,
                badgeWidget: Text(
                  "$currentScore / $maxScore",
                  style: const TextStyle(
                      color: AppColors.whiteColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 12),
                ));
          case 1:
            return PieChartSectionData(
              color: color1,
              value: remainingPercentage,
              title: '',
              radius: 42,
              titlePositionPercentageOffset: 0.55,
            );
          default:
            throw Error();
        }
      },
    );
  }
}
