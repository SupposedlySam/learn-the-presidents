import 'dart:convert';

import 'package:flutter/material.dart';

void main() {
  runApp(const LearnThePresidentsApp());
}

class LearnThePresidentsApp extends StatelessWidget {
  static const americanFlagBlue = Color(0xFF3C3B6E);
  static const americanFlagRed = Color(0xFFB22234);

  const LearnThePresidentsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      colorScheme: const ColorScheme(
        primary: americanFlagRed,
        secondary: americanFlagBlue,
        onSecondary: Colors.white,
        onSurface: americanFlagBlue,
        brightness: Brightness.light,
        error: Colors.red,
        onError: Colors.white,
        surface: Colors.white,
        primaryContainer: Colors.red,
        secondaryContainer: Colors.blue,
        outline: Colors.grey,
        onPrimary: Colors.white,
      ),
      useMaterial3: true,
    );

    return MaterialApp(
      title: 'Learn the Presidents',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: const HomePage(title: 'Learn the Presidents'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> presidents = [];

  @override
  void initState() {
    super.initState();
    _loadPresidents().then((_) {
      _splitIntoSections();
      _shuffleSections();
    });
  }

  Future<void> _loadPresidents() async {
    String data = await DefaultAssetBundle.of(context)
        .loadString('assets/presidents.json');
    final jsonResult = json.decode(data) as List<dynamic>;
    setState(() {
      presidents =
          jsonResult.map((president) => president['name'] as String).toList();
    });
  }

  List<List<String>> sections = [];
  List<List<String>> shuffledSections = [];

  void _splitIntoSections() {
    for (int i = 0; i < presidents.length; i += 5) {
      sections.add(presidents.sublist(
          i, i + 5 > presidents.length ? presidents.length : i + 5));
    }
  }

  void _shuffleSections() {
    shuffledSections = sections
        .map((section) => List<String>.from(section)..shuffle())
        .toList();
  }

  void _checkOrder() {
    bool allCorrect = true;
    for (int i = 0; i < sections.length; i++) {
      for (int j = 0; j < sections[i].length; j++) {
        if (sections[i][j] != shuffledSections[i][j]) {
          allCorrect = false;
          break;
        }
      }
    }
    if (allCorrect) {
      _showWinDialog();
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Congratulations!'),
          content: const Text(
              'You have placed all presidents in the correct order.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Restart'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _shuffleSections();
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
      ),
      body: ListView.builder(
        itemCount: shuffledSections.length,
        itemBuilder: (context, sectionIndex) {
          final primary = Theme.of(context).colorScheme.primary;
          final secondary = Theme.of(context).colorScheme.secondary;
          final onSecondary = Theme.of(context).colorScheme.onSecondary;
          final onPrimary = Theme.of(context).colorScheme.onPrimary;
          return Column(
            children: [
              Text('Section ${sectionIndex + 1}'),
              ReorderableListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    final item =
                        shuffledSections[sectionIndex].removeAt(oldIndex);
                    shuffledSections[sectionIndex].insert(newIndex, item);
                    _checkOrder();
                  });
                },
                children: [
                  for (int i = 0;
                      i < shuffledSections[sectionIndex].length;
                      i++)
                    ReorderableDragStartListener(
                      key: ValueKey(shuffledSections[sectionIndex][i]),
                      index: i,
                      child: ListTile(
                        title: Text(
                          shuffledSections[sectionIndex][i],
                          style: TextStyle(
                              color: sections[sectionIndex][i] ==
                                      shuffledSections[sectionIndex][i]
                                  ? onSecondary
                                  : onPrimary),
                        ),
                        tileColor: sections[sectionIndex][i] ==
                                shuffledSections[sectionIndex][i]
                            ? secondary
                            : primary,
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
