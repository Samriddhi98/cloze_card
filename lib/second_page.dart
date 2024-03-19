import 'dart:developer';

import 'package:flutter/material.dart';

class SecondPage extends StatefulWidget {
  const SecondPage({super.key});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  List<String> extracts = [];
  List<String> extractTextWithNesting(String input) {
    List<String> extractedTexts = [];
    int i = 0;
    while (i < input.length) {
      i = _extractTextWithNestingHelper(input, i, extractedTexts);
    }
    return extractedTexts;
  }

  int _extractTextWithNestingHelper(
      String input, int start, List<String> extractedTexts) {
    StringBuffer currentText = StringBuffer();
    int nesting = 0;
    int i = start;

    while (i < input.length) {
      if (i + 1 < input.length && input[i] == '{' && input[i + 1] == '{') {
        nesting++;
        if (nesting == 1) {
          i++; // Skip the next '{' as it's part of the opening
        }
      } else if (i + 1 < input.length &&
          input[i] == '}' &&
          input[i + 1] == '}') {
        if (nesting == 1) {
          extractedTexts.add(currentText.toString());
          currentText.clear();
        }
        nesting--;
        if (nesting == 0) {
          i += 2; // Move past the closing '}}'
          return i; // Return the current position for further processing
        } else {
          i++; // Skip the next '}' as it's part of the closing
        }
      }
      if (nesting >= 1) {
        currentText.write(input[i]);
      }
      i++;
    }
    return i; // Return the current position for further processing
  }

  List<String> processNestedClozes(String input) {
    List<String> results = [];
    List<String> firstPass = extractTextWithNesting(input);

    for (String cloze in firstPass) {
      if (cloze.contains("{{") && cloze.contains("}}")) {
        results.addAll(extractTextWithNesting(cloze));
      } else {
        results.add(cloze);
      }
    }

    return results;
  }

  @override
  void initState() {
    String input =
        //  "An apple is a {{fruit}}. It is {{yellow {{color}} in color}}";
        "Some text statement {{{{shows}}}} a cloze statement.";

    extracts = processNestedClozes(input);
    log('extracts $extracts');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
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
