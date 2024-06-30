import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:bitblue_task/components/my_button.dart';
import 'package:bitblue_task/constants/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../model/questions_model.dart';
import '../services/auth/auth_service.dart';
import '../services/quiz/quiz_services.dart';
import 'result_page.dart';
import 'package:shimmer/shimmer.dart';

import 'splash_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  int currentPage = 0;
  int score = 0;
  List<String> selectedOptions = [];
  List<Question> questions = [];
  bool isLoading = true;
  int lastScore = 0;

  @override
  void initState() {
    super.initState();
    fetchQuestions();
    fetchLastScore();
  }


//fetch questions from firebase
  void fetchQuestions() {
    final firebaseService = Provider.of<QuizService>(context, listen: false);
    firebaseService.getQuestions().then((fetchedQuestions) {
      if (fetchedQuestions.length < 3) {
        setState(() {
          questions = [];
          isLoading = false;
        });
      } else {
        setState(() {
          questions = fetchedQuestions.take(5).toList();
          selectedOptions = List<String>.filled(questions.length, '');
        });
      }
    }).catchError((error) {
      setState(() {
        questions = [];
        isLoading = false;
      });
    });
  }


//fetch last score from firebase
  void fetchLastScore() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId =  authService.getCurrentUserId();
    if (userId != null) {
      final quizService = Provider.of<QuizService>(context, listen: false);
      final fetchedScore = await quizService.getLastScore(userId);
      setState(() {
        lastScore = fetchedScore;
      });
    }
  }


  void signOut() async{
    await FirebaseAuth.instance.signOut();
Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => SplashScreen()),
    (Route<dynamic> route) => false, 
  );    // final authService = Provider.of<AuthService>(context, listen: false);
    // authService.signOut();
  }

  void goToNextPage() {
    setState(() {
      if (currentPage < questions.length - 1) {
        currentPage++;
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ResultPage(score: score, total: questions.length),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Quiz App',
          style: GoogleFonts.lobster(
            textStyle: const TextStyle(
                fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white, size: 30),
            onPressed: () {
              AwesomeDialog(
                context: context,
                dialogType: DialogType.warning,
                animType: AnimType.topSlide,
                title: 'Logout',
                desc: 'Are you sure you want to logout?',
                btnCancelOnPress: () {},
                btnOkOnPress: () {
                  signOut();
                },
              ).show();
            },
          ),
        ],
      ),
      body: questions.isEmpty
          ? isLoading
              ? _buildShimmerLoading()
              : Center(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/images/notfound.svg',
                      height: screenHeight * 0.3,
                      width: screenWidth * 0.3,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No questions found',
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ButtonComponent(onTap: fetchQuestions, text: 'Retry')
                  ],
                ))
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent, Colors.blue[100]!],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: const EdgeInsets.all(16.0),
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  return buildQuestionPage(index);
                },
              ),
            ),
    );
  }

  Widget buildQuestionPage(int questionIndex) {
    var question = questions[questionIndex];

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
              ],
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Text(
              'Question ${questionIndex + 1} of ${questions.length}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFe8cefe), Colors.white, Colors.white],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(40)),
              child: Column(
                children: [
                  Text(
                    "(${currentPage + 1}) ${question.title}",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: question.options.entries.map((entry) {
                      String optionKey = entry.key;
                      String optionValue = entry.value;
                      return buildOptionTile(
                          questionIndex, optionKey, optionValue);
                    }).toList(),
                  ),
                  const Spacer(),
                  Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
              ],
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Text(
              'Last Score: $lastScore',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildOptionTile(
      int questionIndex, String optionKey, String optionValue) {
    Color tileColor = Colors.white;
    IconData? icon;
    if (selectedOptions[questionIndex] != '') {
      tileColor = optionKey == questions[questionIndex].correctOption
          ? kGreenColor
          : selectedOptions[questionIndex] == optionKey
              ? kRedColor
              : Colors.white;
      icon = optionKey == questions[questionIndex].correctOption
          ? Icons.check
          : selectedOptions[questionIndex] == optionKey
              ? Icons.close
              : null;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(50.0),
        border: Border.all(
          color: selectedOptions[questionIndex] == optionKey
              ? Colors.blueAccent
              : Colors.grey,
          width: 2.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: icon != null
            ? Icon(icon, color: icon == Icons.check ? kGreenColor : kRedColor)
            : null,
        title: Text(
          optionValue,
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ),
        onTap: selectedOptions[questionIndex] == ''
            ? () {
                setState(() {
                  selectedOptions[questionIndex] = optionKey;
                  if (selectedOptions[questionIndex] ==
                      questions[questionIndex].correctOption) {
                    score++;
                  }
                  Future.delayed(
                      const Duration(milliseconds: 500), goToNextPage);
                });
              }
            : null,
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        period: const Duration(milliseconds: 1000),
        child: Center(
          child: Column(
            children: [
              const Spacer(),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 60,
                  width: 200,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 100,
                  width: 400,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 300,
                  width: 400,
                  color: Colors.white,
                ),
              ),
              const Spacer()
            ],
          ),
        ));
  }
}
