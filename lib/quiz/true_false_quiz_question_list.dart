import 'package:flutter/material.dart';
import '../widget/button.dart';

class TrueFalseQuizListScreen extends StatefulWidget {
  @override
  _TrueFalseQuizListScreenState createState() => _TrueFalseQuizListScreenState();
}

class _TrueFalseQuizListScreenState extends State<TrueFalseQuizListScreen> {
  final List<Map<String, dynamic>> quizData = [
    {
      'quiz_name': '5+3 = 17',
      'answer': 'False',
    },
    {
      'quiz_name': 'The Earth is flat',
      'answer': 'False',
    },
    {
      'quiz_name': 'Water boils at 100°C',
      'answer': 'True',
    },
  ];

  @override
  Widget build(BuildContext context) {
    if (quizData.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("No quizzes available.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test 11',style: TextStyle(fontWeight: FontWeight.bold,
            color: Colors.white),),
          backgroundColor: Color(0xFF00AFEE),
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        titleTextStyle: const TextStyle(color: Colors.blue, fontSize: 20),

      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: quizData.length,
              itemBuilder: (context, index) {
                final quiz = quizData[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        'Question',
                        quiz['quiz_name'],
                        flex: 2,
                        maxLines: 3,
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 10),
                      _buildInfoRow(
                        'Answer',
                        quiz['answer'],
                        flex: 1,
                        isCorrect: quiz['answer'] == 'True',
                      ),
                      const SizedBox(height: 10),
                      _buildInfoRow('Action', '', flex: 1, isAction: true),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomButton(
              onTap: () => Navigator.pop(context),
              buttonText: 'Back to Quiz',
              buttonColor: const Color(0xFF00AFEE),
              textColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, dynamic value,
      {int flex = 1,
        int maxLines = 1,
        bool isCorrect = false,
        bool isAction = false,
        TextAlign textAlign = TextAlign.right}) {
    return Row(
      children: [
        Expanded(
          flex: flex,
          child: Text(
            label,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.blue),
            textAlign: TextAlign.left,
          ),
        ),
        if (isAction)
          Expanded(
            flex: flex,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.grey),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.grey),
                  onPressed: () {},
                ),
              ],
            ),
          )
        else if (isCorrect)
          Expanded(
            flex: flex,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.check, color: Colors.green),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    value?.toString() ?? '',
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                    textAlign: textAlign,
                    maxLines: maxLines,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          )
        else
          Expanded(
            flex: flex,
            child: Text(
              value?.toString() ?? '',
              style: const TextStyle(fontSize: 14, color: Colors.black),
              textAlign: textAlign,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}