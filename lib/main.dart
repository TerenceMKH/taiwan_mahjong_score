import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  List<bool> isNegative = [false, false, false]; // Track if total score is negative
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
      totalScores[playerIndex] = isNegative[playerIndex] ? -total : total;
    });
  }

  void _toggleSign(int playerIndex) {
    setState(() {
      isNegative[playerIndex] = !isNegative[playerIndex];
      _calculateTotalScore(playerIndex); // Recalculate total score with new sign
    });
  }

  void _kickHalf(int playerIndex) {
    setState(() {
      if (totalScores[playerIndex] < 0) {
        totalScores[playerIndex] = (totalScores[playerIndex] / 2).ceil(); // Round up for negative
      } else {
        totalScores[playerIndex] = (totalScores[playerIndex] / 2).floor(); // Round down for positive
      }
    });
  }

  void _clearScore(int playerIndex) {
    setState(() {
      totalScores[playerIndex] = 0;
      scores[playerIndex] = List.filled(6, 0); // Reset scores to 0
      controllers[playerIndex] = List.generate(6, (index) => TextEditingController()); // Reset controllers
    });
  }

  // Helper function to normalize -0.0 to 0
  String _normalizeScore(int score) {
    return score == 0 ? '0' : score.toString();
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
              _normalizeScore(totalScores[playerIndex]), // Normalize -0.0 to 0
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
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _toggleSign(playerIndex),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isNegative[playerIndex] ? Colors.red : Colors.green, // Green if positive, red if negative
                      foregroundColor: Colors.white, // White text
                    ),
                    child: Text('+/-'),
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
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () => _toggleSign(playerIndex),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isNegative[playerIndex] ? Colors.red : Colors.green, // Green if positive, red if negative
                      foregroundColor: Colors.white, // White text
                    ),
                    child: Text('+/-'),
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
                TextField(
                  controller: controllers[playerIndex][j],
                  focusNode: focusNodes[playerIndex][j],
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*')), // Allow only positive integers
                  ],
                  onChanged: (value) => _updateScore(playerIndex, j, value),
                  style: TextStyle(
                    fontSize: fontSize,
                    color: Colors.black, // Input text color
                  ),
                  decoration: InputDecoration(
                    labelText: null, // No label text
                  ),
                ),
            ],
          ),
        ),
      ),
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
        reverse: true, // Scroll to the bottom when keyboard appears
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < 3; i++)
                    Expanded(
                      child: Column(
                        children: [
                          _buildPlayerScoreCard(i, context),
                          SizedBox(height: 16),
                          _buildPlayerInputFields(i, context),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}