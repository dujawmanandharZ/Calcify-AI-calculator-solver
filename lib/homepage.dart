import 'package:flutter/material.dart';
import 'package:test_app/buttons.dart'; // Your custom button widget
import 'package:math_expressions/math_expressions.dart'; // Logic for solving math strings
import 'camerapage.dart'; // The AI/Camera logic we worked on
import 'package:flutter/services.dart'; // Required for HapticFeedback (vibrations)
import 'history.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  // State variables to track what the user types and the calculated result
  var userQuestion = '';
  var userAnswer = '';

  // List of button labels to be rendered in the GridView
  final List<String> buttons = [
    'C',
    'DEL',
    '%',
    '/',
    '9',
    '8',
    '7',
    'X',
    '6',
    '5',
    '4',
    '+',
    '3',
    '2',
    '1',
    '-',
    'H',
    '0',
    '.',
    '=',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 246, 245, 245),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 244, 240, 240),
        title: const Text(
          "CALCIFY",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Padding(
              padding: EdgeInsets.only(right: 2.0),
              child: Icon(Icons.camera_alt, size: 45),
            ),
            onPressed: () {
              // HapticFeedback provides a premium feel by vibrating the phone slightly on tap
              HapticFeedback.mediumImpact();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CameraPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          // TOP SECTION: The Display Screen
          Expanded(
            child: Container(
              width: 400,
              decoration: BoxDecoration(
                color: const Color.fromARGB(
                  255,
                  209,
                  213,
                  187,
                ), // Calculator "LCD" color
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  // Displays the current input string
                  Container(
                    padding: const EdgeInsets.all(10),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      userQuestion,
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
                  // Displays the calculated answer
                  Container(
                    padding: const EdgeInsets.all(10),
                    alignment: Alignment.centerRight,
                    child: Text(
                      userAnswer,
                      style: const TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // BOTTOM SECTION: The Button Grid
          Expanded(
            flex: 3, // Takes up 3/4ths of the vertical space
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: GridView.builder(
                itemCount: buttons.length,
                // Creates a 4-column layout
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                ),
                itemBuilder: (BuildContext context, int index) {
                  // CLEAR BUTTON
                  if (index == 0) {
                    return Mybutton(
                      buttontapped: () {
                        HapticFeedback.mediumImpact();
                        setState(() {
                          userQuestion = '';
                          userAnswer = '';
                        });
                      },
                      buttonText: buttons[index],
                      color: Colors.redAccent,
                      textColor: Colors.white,
                    );
                  }
                  // DELETE BUTTON
                  else if (index == 1) {
                    return Mybutton(
                      buttontapped: () {
                        HapticFeedback.mediumImpact();
                        setState(() {
                          if (userQuestion.isNotEmpty) {
                            userQuestion = userQuestion.substring(
                              0,
                              userQuestion.length - 1,
                            );
                          }
                        });
                      },
                      buttonText: buttons[index],
                      color: Colors.orange,
                      textColor: Colors.white,
                    );
                  }
                  // EQUALS BUTTON
                  else if (index == buttons.length - 1) {
                    return Mybutton(
                      buttontapped: () {
                        HapticFeedback.heavyImpact();
                        setState(() {
                          equalPressed();
                        });
                      },
                      buttonText: buttons[index],
                      color: Colors.orange,
                      textColor: Colors.white,
                    );
                  } else if (index == 16) { //route to history page
                    return Mybutton(
                      buttontapped: () {
                        HapticFeedback.heavyImpact();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HistoryPage(),
                          ),
                        );
                      },
                      buttonText: buttons[index],
                      color: Colors.orange,
                      textColor: Colors.white,
                    );
                  }
                  // NUMBER AND OPERATOR BUTTONS
                  else {
                    return Mybutton(
                      buttontapped: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          userQuestion += buttons[index];
                        });
                      },
                      buttonText: buttons[index],
                      // Checks if the button is an operator to give it a unique color
                      color: isOperator(buttons[index])
                          ? Colors.orange
                          : const Color.fromARGB(255, 212, 212, 212),
                      textColor: isOperator(buttons[index])
                          ? Colors.white
                          : Colors.black,
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to identify mathematical operators for styling
  bool isOperator(String x) {
    if (x == '%' ||
        x == '/' ||
        x == '+' ||
        x == '-' ||
        x == '=' ||
        x == 'DEL' ||
        x == 'X' ||
        x == 'H') {
      return true;
    }
    return false;
  }

 

  // Function to evaluate the string as a math expression
  void equalPressed() {
    try {
      String finalQuestion = userQuestion;
      // Replace 'X' with '*' so the math_expressions parser understands it
      finalQuestion = finalQuestion.replaceAll('X', '*');

      /* Logic flow: 
         1. Parse the string into an 'Expression'
         2. Create a 'ContextModel' (handles variables if any)
         3. Evaluate the expression as a real number
      */
      Parser p = Parser();
      Expression exp = p.parse(finalQuestion);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      userAnswer = eval.toString();
    } catch (e) {
      // If the user enters an invalid equation (like '5++2'), show Error
      userAnswer = "Error";
    }
  }
}
