import 'package:flutter/material.dart';
import 'package:mobile/screens/activity/widgets/activities_goals_list.dart';
import 'package:mobile/services/http_service.dart';
import '../../utils/app_colors.dart';

class GoalsTemplatesScreen extends StatefulWidget {
  final int dogId;

  const GoalsTemplatesScreen({
    super.key,
    required this.dogId,
  });

  @override
  _GoalsTemplatesScreenState createState() => _GoalsTemplatesScreenState();
}

class _GoalsTemplatesScreenState extends State<GoalsTemplatesScreen> {
  List<Map<String, dynamic>> templatesArr = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchTemplates();
  }

  Future<void> _fetchTemplates() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      List<Map<String, dynamic>>? fetchedTemplates = await HttpService.getGoalsTemplatesList(widget.dogId);

      setState(() {
        if (fetchedTemplates != null) {
          templatesArr = fetchedTemplates;
        } else {
          templatesArr = [];
        }
      });
    } catch (e) {
      print("Error fetching goal templates: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          "Periodic Goals",
          style: TextStyle(
            color: AppColors.blackColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.primaryG,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ActivitiesGoalsList(
                  ItemsArr: templatesArr,
                  dogId: widget.dogId,
                  type: 'template',
                ),
              ),
            ),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(
                  color: AppColors.secondaryColor1,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
