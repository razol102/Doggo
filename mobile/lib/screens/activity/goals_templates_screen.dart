import 'package:flutter/material.dart';
import 'package:mobile/screens/activity/widgets/activities_goals_list.dart';
import 'package:mobile/services/http_service.dart';
import '../../main.dart';
import '../../utils/app_colors.dart';
import 'add_update_goal_template.dart';

class GoalsTemplatesScreen extends StatefulWidget {
  final int dogId;

  const GoalsTemplatesScreen({
    super.key,
    required this.dogId,
  });

  @override
  _GoalsTemplatesScreenState createState() => _GoalsTemplatesScreenState();
}

class _GoalsTemplatesScreenState extends State<GoalsTemplatesScreen> with RouteAware {
  List<Map<String, dynamic>> templatesArr = [];
  bool isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void didPopNext() {
    _fetchTemplates();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch goal templates. Please try again.')),
        );
      }
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
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddUpdateGoalTemplateScreen(templateId: null,), // null for add
                ),
              );
            },
          ),
        ],
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
