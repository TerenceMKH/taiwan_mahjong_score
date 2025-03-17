import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '台灣麻將分數記錄',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<List<TextEditingController>> controllers;
  late List<List<int>> scores;
  List<int> totalScores = [0, 0, 0]; // 三位玩家的總分
  List<String> playerNames = ['上家', '對家', '下家']; // 固定玩家名稱
  late List<List<FocusNode>> focusNodes;

  @override
  void initState() {
    super.initState();
    // 初始化 controllers, scores, and focusNodes
    controllers = List.generate(3, (playerIndex) => List.generate(6, (index) => TextEditingController()));
    scores = List.generate(3, (playerIndex) => List.filled(6, 0));
    focusNodes = List.generate(3, (playerIndex) => List.generate(6, (index) => FocusNode()));
  }

  void _updateScore(int playerIndex, int fieldIndex, String value) {
    setState(() {
      int points = int.tryParse(value) ?? 0;
      scores[playerIndex][fieldIndex] = points;
      _calculateTotalScore(playerIndex);
    });
  }

  void _calculateTotalScore(int playerIndex) {
    int total = 0;
    for (int i = 0; i < scores[playerIndex].length; i++) {
      if (i == 0) {
        total += scores[playerIndex][i];
      } else if (controllers[playerIndex][i].text.isNotEmpty) {
        total = (total * 1.5).ceil() + scores[playerIndex][i];
      }
    }
    setState(() {
      totalScores[playerIndex] = total;
    });
  }

  void _kickHalf(int playerIndex) {
    setState(() {
      if (totalScores[playerIndex] < 0) {
        totalScores[playerIndex] = (totalScores[playerIndex] / 2).ceil();
      } else {
        totalScores[playerIndex] = (totalScores[playerIndex] / 2).floor();
      }
    });
  }

  void _clearScore(int playerIndex) {
    setState(() {
      totalScores[playerIndex] = 0;
      scores[playerIndex] = List.filled(6, 0);
      controllers[playerIndex] = List.generate(6, (index) => TextEditingController());
    });
  }

  Widget _buildPlayerScoreCard(int playerIndex, BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth > 600 ? 24 : 16; // Smaller font size for small screens
    bool isSmallScreen = screenWidth < 600; // Check if the screen is small

    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              playerNames[playerIndex],
              style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '${totalScores[playerIndex]}',
              style: TextStyle(
                fontSize: fontSize + 6,
                fontWeight: FontWeight.bold,
                color: totalScores[playerIndex] >= 0 ? Colors.green : Colors.red,
              ),
            ),
            SizedBox(height: 8),
            // Stack buttons vertically on small screens
            if (isSmallScreen)
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () => _kickHalf(playerIndex),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300], // Light grey background
                      foregroundColor: Colors.black, // Black text
                    ),
                    child: Text('劈半'),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _clearScore(playerIndex),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300], // Light grey background
                      foregroundColor: Colors.black, // Black text
                    ),
                    child: Text('找數'),
                  ),
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => _kickHalf(playerIndex),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300], // Light grey background
                      foregroundColor: Colors.black, // Black text
                    ),
                    child: Text('劈半'),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () => _clearScore(playerIndex),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300], // Light grey background
                      foregroundColor: Colors.black, // Black text
                    ),
                    child: Text('找數'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerInputFields(int playerIndex, BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double padding = screenWidth > 600 ? 16.0 : 8.0;
    double fontSize = screenWidth > 600 ? 18 : 14; // Adjusted font size for input fields

    return SizedBox(
      width: screenWidth > 600 ? 200 : 120, // Thinner input fields
      child: Card(
        margin: EdgeInsets.all(padding),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            children: [
              for (int j = 0; j < controllers[playerIndex].length; j++)
                Column(
                  children: [
                    TextField(
                      controller: controllers[playerIndex][j],
                      focusNode: focusNodes[playerIndex][j],
                      keyboardType: TextInputType.numberWithOptions(signed: true), // Allow "-" sign
                      onChanged: (value) => _updateScore(playerIndex, j, value),
                      style: TextStyle(
                        fontSize: fontSize,
                        color: (int.tryParse(controllers[playerIndex][j].text) ?? 0) >= 0 ? Colors.green : Colors.red,
                      ),
                      decoration: InputDecoration(
                        labelText: null, // No label text
                      ),
                    ),
                    if (j == controllers[playerIndex].length - 1)
                      _buildCustomKeyboardRow(playerIndex, j),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomKeyboardRow(int playerIndex, int fieldIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: Icon(Icons.remove),
          onPressed: () {
            // Insert "-" sign at the beginning of the text
            final controller = controllers[playerIndex][fieldIndex];
            final text = controller.text;
            if (!text.startsWith('-')) {
              controller.text = '-$text';
              controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
            }
          },
        ),
        IconButton(
          icon: Icon(Icons.keyboard_return),
          onPressed: () {
            // Unfocus the current input field
            focusNodes[playerIndex][fieldIndex].unfocus();
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double padding = screenWidth > 600 ? 24.0 : 16.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('台灣麻將分數記錄'),
      ),
      body: SingleChildScrollView(
        scrollDirection: screenWidth > 600 ? Axis.vertical : Axis.horizontal,
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < 3; i++)
                Column(
                  children: [
                    _buildPlayerScoreCard(i, context),
                    SizedBox(height: 16),
                    _buildPlayerInputFields(i, context),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}