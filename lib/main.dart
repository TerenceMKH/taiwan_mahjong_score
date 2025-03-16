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

  @override
  void initState() {
    super.initState();
    // 初始化 controllers 和 scores
    controllers = List.generate(3, (playerIndex) => [TextEditingController()]);
    scores = List.generate(3, (playerIndex) => []);
  }

  void _updateScore(int playerIndex, int fieldIndex, String value) {
    setState(() {
      int points = int.tryParse(value) ?? 0;
      if (scores[playerIndex].length > fieldIndex) {
        scores[playerIndex][fieldIndex] = points;
      } else {
        scores[playerIndex].add(points);
      }
      _calculateTotalScore(playerIndex);

      // 自動添加新的輸入欄位
      if (fieldIndex == controllers[playerIndex].length - 1 && value.isNotEmpty) {
        controllers[playerIndex].add(TextEditingController());
      }
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
      scores[playerIndex].clear();
      controllers[playerIndex].clear();
      controllers[playerIndex].add(TextEditingController()); // Add one empty field
    });
  }

  Widget _buildPlayerScoreCard(int playerIndex, BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth > 600 ? 24 : 18;

    return Column(
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
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
    );
  }

  Widget _buildPlayerInputFields(int playerIndex, BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double padding = screenWidth > 600 ? 24.0 : 16.0;

    return Expanded(
      child: Card(
        margin: EdgeInsets.all(padding),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            children: [
              for (int j = 0; j < controllers[playerIndex].length; j++)
                TextField(
                  controller: controllers[playerIndex][j],
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _updateScore(playerIndex, j, value),
                  decoration: InputDecoration(
                    labelText: controllers[playerIndex][j].text.isEmpty ? '-' : null, // Hide "-" after input
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
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(padding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (int i = 0; i < 3; i++) _buildPlayerScoreCard(i, context),
                ],
              ),
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (int i = 0; i < 3; i++) _buildPlayerInputFields(i, context),
              ],
            ),
          ],
        ),
      ),
    );
  }
}