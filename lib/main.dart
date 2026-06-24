
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:confetti/confetti.dart';

void main() {
  runApp(const MyApp());
}

const String storyText =
    "Once upon a time, a clever little robot named Pip lost his shiny blue gear in the Whispering Woods...";

final Map<String, dynamic> quizJson = {
  "question": "What colour was Pip the Robot's lost gear?",
  "options": ["Red", "Green", "Blue", "Yellow"],
  "answer": "Blue"
};

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Peblo Challenge',
      theme: ThemeData(
        colorSchemeSeed: Colors.orange,
        useMaterial3: true,
      ),
      home: const StoryScreen(),
    );
  }
}

class StoryScreen extends StatefulWidget {
  const StoryScreen({super.key});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  final FlutterTts flutterTts = FlutterTts();
  late ConfettiController confettiController;

  bool isSpeaking = false;
  bool showQuiz = false;
  bool success = false;
  String message = "";

  @override
  void initState() {
    super.initState();

    confettiController =
        ConfettiController(duration: const Duration(seconds: 3));

    flutterTts.setCompletionHandler(() {
      setState(() {
        isSpeaking = false;
        showQuiz = true;
      });
    });
  }

  Future<void> speakStory() async {
    try {
      setState(() {
        isSpeaking = true;
        showQuiz = false;
        success = false;
        message = "";
      });

      await flutterTts.speak(storyText);
    } catch (e) {
      setState(() {
        isSpeaking = false;
        message = "Failed to play story.";
      });
    }
  }

  void checkAnswer(String selected) {
    if (selected == quizJson["answer"]) {
      setState(() {
        success = true;
        message = "Great Job! Pip found his blue gear!";
      });

      confettiController.play();
    } else {
      setState(() {
        message = "Try Again!";
      });
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF7E6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                ),
              ),

              const SizedBox(height: 20),

              const CircleAvatar(
                radius: 60,
                child: Icon(Icons.smart_toy, size: 60),
              ),

              const SizedBox(height: 20),

              const Text(
                "AI Story Buddy",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    storyText,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: isSpeaking ? null : speakStory,
                child: Text(
                  isSpeaking
                      ? "Reading Story..."
                      : "Read Me A Story",
                ),
              ),

              const SizedBox(height: 20),

              if (showQuiz)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          quizJson["question"],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 15),

                        ...List.generate(
                          quizJson["options"].length,
                          (index) {
                            final option =
                                quizJson["options"][index];

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(
                                      vertical: 5),
                              child: ElevatedButton(
                                onPressed: () =>
                                    checkAnswer(option),
                                child: Text(option),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              Text(
                message,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
