import 'package:flutter/material.dart';
import 'package:mobile/services/http_service.dart';
import '../../utils/app_colors.dart';

class FaqScreen extends StatefulWidget {
  static String routeName = "/FaqScreen";

  @override
  _FaqScreenState createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  Map<String, String> _faqQuestions = {};
  final Map<String, String> _faqAnswers = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    try {
      final questions = await HttpService.getFrequentlyQuestions();
      setState(() {
        _faqQuestions = Map<String, String>.from(questions as Map);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching questions: $e');
    }
  }

  Future<void> _fetchAnswer(String questionId) async {
    if (_faqAnswers.containsKey(questionId)) return;

    try {
      final answer = await HttpService.getAnswer(questionId);
      final cleanedAnswer = answer.replaceAll('"', '').trim();

      setState(() {
        _faqAnswers[questionId] = cleanedAnswer;
      });
    } catch (e) {
      print('Error fetching answer: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Image.asset(
                    "assets/images/faq_background.png", // Replace with your image
                    width: media.width * 0.8, // Adjust the width as needed
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'Frequently Asked Questions',
                    style: TextStyle(
                      color: AppColors.blackColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primaryColor2,))
                    : ListView.builder(
                  physics: const NeverScrollableScrollPhysics(), // Prevent scrolling inside the list
                  shrinkWrap: true, // Allows the list to take only as much space as needed
                  itemCount: _faqQuestions.length,
                  itemBuilder: (context, index) {
                    final questionId = _faqQuestions.keys.elementAt(index);
                    final questionText = _faqQuestions[questionId]!;
                    final answerText = _faqAnswers[questionId];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      elevation: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: AppColors.primaryG,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ExpansionTile(
                          title: Text(
                            questionText,
                            style: const TextStyle(
                              color: AppColors.blackColor,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          iconColor: AppColors.blackColor,
                          collapsedIconColor: AppColors.blackColor,
                          backgroundColor: Colors.transparent,
                          collapsedBackgroundColor: Colors.transparent,
                          children: [
                            if (answerText == null)
                              FutureBuilder(
                                future: _fetchAnswer(questionId),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: CircularProgressIndicator(),
                                    );
                                  } else if (snapshot.hasError) {
                                    return const Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Text('Error loading answer.'),
                                    );
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      _faqAnswers[questionId] ?? '',
                                      style: const TextStyle(
                                        color: AppColors.grayColor,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  );
                                },
                              )
                            else
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  answerText,
                                  style: const TextStyle(
                                    color: AppColors.grayColor,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w300,

                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
