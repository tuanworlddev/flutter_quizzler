import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quizzler/question.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Quizzler',
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final List<Question> _questions = [
    Question(
      title: 'Flutter uses Dart as its programming language.',
      answer: true,
      explanation: 'Flutter was specifically designed to work with Dart.',
    ),
    Question(
      title: 'Widgets in Flutter are immutable.',
      answer: true,
      explanation: 'Widgets are immutable and can be recreated when needed.',
    ),
    Question(
      title: 'StatefulWidgets are more performant than StatelessWidgets.',
      answer: false,
      explanation: 'StatelessWidgets are generally more performant as they don\'t maintain state.',
    ),
    Question(
      title: 'Hot Reload works with changes to the app\'s state.',
      answer: false,
      explanation: 'Hot Reload works with UI changes but state is preserved, not reset.',
    ),
    Question(
      title: 'Flutter can only build mobile applications.',
      answer: false,
      explanation: 'Flutter can build for mobile, web, desktop, and embedded devices.',
    ),
    Question(
      title: 'The build() method can return null in a Widget.',
      answer: false,
      explanation: 'The build() method must always return a Widget, it cannot return null.',
    ),
    Question(
      title: 'Flutter uses a declarative approach to UI development.',
      answer: true,
      explanation: 'Flutter uses a declarative UI paradigm similar to React.',
    ),
    Question(
      title: 'setState() is the only way to manage state in Flutter.',
      answer: false,
      explanation: 'There are many state management solutions like Provider, Riverpod, Bloc, etc.',
    ),
    Question(
      title: 'The MaterialApp widget is required in every Flutter app.',
      answer: false,
      explanation: 'You can use CupertinoApp or even build your own app structure.',
    ),
    Question(
      title: 'Flutter compiles to native ARM code for mobile devices.',
      answer: true,
      explanation: 'Flutter uses Dart\'s native compilation to produce ARM binaries.',
    ),
  ];

  int _currentQuestionIndex = 0;
  int _score = 0;
  final List<Icon> _scoreKeeper = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _isAnswerSelected = false;
  Color? _lastButtonColor;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _checkAnswer(bool userAnswer) {
    if (_isAnswerSelected) return;
    _isAnswerSelected = true;

    bool correctAnswer = _questions[_currentQuestionIndex].answer;
    Color buttonColor = userAnswer == correctAnswer ? Colors.green : Colors.red;
    _lastButtonColor = buttonColor;

    setState(() {
      if (userAnswer == correctAnswer) {
        _score++;
        _scoreKeeper.add(Icon(Icons.check, color: Colors.green.shade300));
      } else {
        _scoreKeeper.add(Icon(Icons.close, color: Colors.red.shade300));
      }
    });

    // Vibrate on answer
    HapticFeedback.mediumImpact();

    // Show feedback and move to next question
    _animationController.reverse().then((_) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (_currentQuestionIndex < _questions.length - 1) {
          _currentQuestionIndex++;
          _isAnswerSelected = false;
          _animationController.forward();
          setState(() {});
        } else {
          _showQuizOverDialog();
        }
      });
    });
  }

  void _showQuizOverDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          backgroundColor: Colors.grey.shade800,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.celebration,
                  size: 60,
                  color: Colors.amber,
                ),
                const SizedBox(height: 20),
                Text(
                  'Quiz Completed!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent.shade200,
                  ),
                ),
                const SizedBox(height: 20),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Your score: ',
                        style: const TextStyle(fontSize: 18),
                      ),
                      TextSpan(
                        text: '$_score/${_questions.length}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: _score >= _questions.length / 2
                              ? Colors.green.shade300
                              : Colors.red.shade300,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _resetQuiz();
                  },
                  child: const Text(
                    'Restart Quiz',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _resetQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
      _scoreKeeper.clear();
      _isAnswerSelected = false;
      _animationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FLUTTER QUIZZLER'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10,),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Question ${_currentQuestionIndex + 1}/${_questions.length}',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      color: Colors.grey.shade800,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Center(
                          child: Text(
                            _questions[_currentQuestionIndex].title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 25.0,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (_questions[_currentQuestionIndex].explanation != null &&
                _isAnswerSelected)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Card(
                  color: Colors.blueGrey.shade900,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Text(
                      _questions[_currentQuestionIndex].explanation!,
                      style: TextStyle(
                        color: Colors.blueAccent.shade200,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: _isAnswerSelected && _questions[_currentQuestionIndex].answer
                        ? Colors.green
                        : null,
                    border: _isAnswerSelected && _questions[_currentQuestionIndex].answer
                        ? Border.all(color: Colors.green.shade300, width: 2)
                        : null,
                  ),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: _isAnswerSelected && _questions[_currentQuestionIndex].answer
                          ? Colors.green
                          : Colors.green.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () => _checkAnswer(true),
                    child: const Text(
                      'TRUE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: _isAnswerSelected && !_questions[_currentQuestionIndex].answer
                        ? Colors.red
                        : null,
                    border: _isAnswerSelected && !_questions[_currentQuestionIndex].answer
                        ? Border.all(color: Colors.red.shade300, width: 2)
                        : null,
                  ),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: _isAnswerSelected && !_questions[_currentQuestionIndex].answer
                          ? Colors.red
                          : Colors.red.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () => _checkAnswer(false),
                    child: const Text(
                      'FALSE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _scoreKeeper.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: _scoreKeeper[index],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}