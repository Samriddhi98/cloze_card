import 'dart:developer';

import 'package:cloze_card/second_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  bool areBracesBalanced(String expression) {
    if (expression.contains('{{')) {
      List<String> stack = [];

      for (int i = 0; i < expression.length; i++) {
        String char = expression[i];

        // Push the opening brace onto stack
        if (char == '{') {
          stack.add(char);
        } else if (char == '}') {
          // If a closing brace is encountered and stack is empty, it's unbalanced
          if (stack.isEmpty) {
            return false;
          } else {
            stack.removeLast(); // Pop the matching opening brace
          }
        }
      }

      // If stack is empty, all braces were matched and it's balanced
      return stack.isEmpty;
    } else {
      return false;
    }
  }

  bool containsPattern(String input) {
    final areBalanced = areBracesBalanced(input);
    print('is bracket balanced $areBalanced');
    //  return input.contains('{') || input.contains("}");
    return areBalanced;
  }

  List<String> processText(String input) {
    if (!containsPattern(input)) return [];

    List<String> results = [];
    List<String> initialExtractions = extractTextWithNesting(input);
    for (var text in initialExtractions) {
      if (containsPattern(text)) {
        results
            .addAll(processText(text)); // Recursively process nested patterns
      } else {
        results.add(text);
      }
    }

    return results;
  }

  List<String> extractTextWithNesting(String input) {
    int nesting = 0;
    List<String> extractedTexts = [];
    StringBuffer currentText = StringBuffer();
    bool recording = false;

    for (int i = 0; i < input.length; i++) {
      if (input[i] == '{' && i + 1 < input.length && input[i + 1] == '{') {
        nesting++;
        if (nesting == 1) {
          recording = true;
          i++;
          continue;
        }
      } else if (input[i] == '}' &&
          i + 1 < input.length &&
          input[i + 1] == '}') {
        nesting--;
        if (nesting == 0) {
          if (recording) {
            // Only add non-empty strings
            String text = currentText.toString().trim();
            if (text.isNotEmpty) {
              extractedTexts.add(text);
            }
            currentText.clear();
          }
          recording = false;
          i++;
          continue;
        }
      }

      if (recording && nesting >= 1) {
        currentText.write(input[i]);
      }
    }
    log('extracted text $extractedTexts');
    return extractedTexts;
  }

  List<String> extracts = [];
  String input = '';
  @override
  void initState() {
    String input1 =
        // "An apple is a {{fruit}}. It is {{yellow {{color}} in color}}";
        "An apple is a {{fruit}} and is {{red}}. It is {{yellow {{color}} in color}}";
    String input2 = 'Fill {{in the}blanks}}';
    input = input1;
    extracts = processText(input);
    log('extracted clozes $extracts');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
          child: Column(
        children: extracts.map((e) => Text(e)).toList(),
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => SecondPage()));
        },
      ),
      // This trailing comma makes auto-format ting nicer for build methods.
    );
  }
}
