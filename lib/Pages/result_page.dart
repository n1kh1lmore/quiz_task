import 'package:bitblue_task/components/my_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';

import 'home_page.dart';

class ResultPage extends StatefulWidget {
  final int score;
  final int total;

  const ResultPage({super.key, required this.score, required this.total});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> saveOrUpdateScore() async {
    User? user = _auth.currentUser;
    if (user != null) {
      final userDoc = _firestore.collection('users').doc(user.uid);
      var userData = await userDoc.get();
      if (userData.exists && userData.data()!.containsKey('score')) {
        await userDoc.update({
          'score': widget.score,
        });
      } else {
        await userDoc.set({
          'score': widget.score,
        }, SetOptions(merge: true));
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    saveOrUpdateScore();
    _sendNotification();
  }

  Future<void> _sendNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'quiz_app_channel',
      'Quiz App Notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Test Finished!',
      'You scored ${widget.score} out of ${widget.total}',
      platformChannelSpecifics,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
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
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.blue.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Container(
            height: size.height * 0.5,
            width: size.width * 0.8,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFe8cefe), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Your Score',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '${widget.score} / ${widget.total}',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: widget.score == widget.total
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
                if (widget.score == widget.total)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Congratulations! Perfect Score!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 20),
                ButtonComponent(
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomePage()));
                    },
                    text: 'Play Again')
              ],
            ),
          ),
        ),
      ),
    );
  }
}
