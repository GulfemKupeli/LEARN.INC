import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../services/api_service.dart'; // Import ApiService
import '../file_upload_helper.dart'; // Import FileUploadHelper

class QuizzesScreen extends StatefulWidget {
  final bool isDayMode; // Theme Mode (Day/Night)

  const QuizzesScreen({Key? key, required this.isDayMode}) : super(key: key);

  @override
  _QuizzesScreenState createState() => _QuizzesScreenState();
}

class _QuizzesScreenState extends State<QuizzesScreen> {
  bool isLoading = false;
  List<QuizQuestion> quizQuestions = [];
  Map<int, int> selectedAnswers = {};
  bool showResults = false;
  String? errorMessage;
  final ApiService _apiService = ApiService(); // Instance of ApiService

  // Handle file upload and read its content
  Future<void> handleFileUpload() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final filePath = await FileUploadHelper.pickFile(); // Pick a file using FileUploadHelper
      if (filePath == null) {
        setState(() {
          errorMessage = 'No file selected.';
          isLoading = false; // Stop loading if no file selected
        });
        return;
      }

      // Read the file as binary data (bytes)
      final file = File(filePath);
      final fileBytes = await file.readAsBytes(); // Read file content as bytes

      // Process the file based on its type (e.g., PDF)
      await generateQuizFromFile(fileBytes); // Process the file bytes to generate the quiz
    } catch (e) {
      setState(() {
        errorMessage = 'Error handling file: $e';
        isLoading = false;
      });
    }
  }

  // Generate quiz using ApiService
  Future<void> generateQuizFromFile(List<int> fileBytes) async {
    try {
      // Create a PDF document from the file bytes
      final pdfDocument = PdfDocument(inputBytes: fileBytes);

      // Extract text from the PDF
      String extractedText = PdfTextExtractor(pdfDocument).extractText();
      pdfDocument.dispose();

      if (extractedText.isEmpty) {
        throw Exception("Unable to extract text from the selected PDF.");
      }

      // Generate quiz questions from extracted text
      List<QuizQuestion> questions = await _apiService.generateQuizQuestions(extractedText);

      setState(() {
        quizQuestions = questions;
        isLoading = false; // Set loading state to false once quiz is generated
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error generating quiz: $e';
        isLoading = false; // Stop loading if an error occurs
      });
    }
  }

  // Handle answer selection
  void handleAnswerSelect(int questionIndex, int optionIndex) {
    setState(() {
      selectedAnswers[questionIndex] = optionIndex;
    });
  }

  // Calculate the quiz score
  Map<String, dynamic> calculateResults() {
    int correct = 0;
    Map<int, bool> questionResults = {};

    for (int i = 0; i < quizQuestions.length; i++) {
      bool isCorrect = selectedAnswers[i] == quizQuestions[i].options.indexOf(quizQuestions[i].answer);
      questionResults[i] = isCorrect;
      if (isCorrect) correct++;
    }

    return {
      'score': correct,
      'total': quizQuestions.length,
      'percentage': (correct / quizQuestions.length * 100).round(),
      'questionResults': questionResults,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Generator'),
        backgroundColor: widget.isDayMode ? Colors.blue : Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: handleFileUpload,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
            ? Center(child: Text(errorMessage!))
            : quizQuestions.isEmpty
            ? const Center(
          child: Text('No quiz generated yet. Upload a file to generate quiz.'),
        )
            : SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              if (showResults) _buildResultsSummary(),
              ...List.generate(
                quizQuestions.length,
                    (qIndex) => _buildQuestionCard(qIndex),
              ),
              const SizedBox(height: 16),
              if (!showResults)
                ElevatedButton(
                  onPressed: selectedAnswers.length == quizQuestions.length
                      ? () {
                    setState(() {
                      showResults = true;
                    });
                  }
                      : null,
                  child: const Text('Submit Quiz'),
                ),
              if (showResults)
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showResults = false;
                      selectedAnswers.clear();
                    });
                  },
                  child: const Text('Retry Quiz'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsSummary() {
    final results = calculateResults();
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Quiz Results',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Score: ${results['score']} out of ${results['total']}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              'Percentage: ${results['percentage']}%',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: results['percentage'] >= 70 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(int qIndex) {
    final question = quizQuestions[qIndex];
    final results = showResults ? calculateResults() : null;
    final isCorrect = results?['questionResults'][qIndex] ?? false;
    final correctAnswerIndex = question.options.indexOf(question.answer);

    return Card(
      key: ValueKey(qIndex),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Question ${qIndex + 1}: ${question.question}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (showResults)
                  Icon(
                    isCorrect ? Icons.check_circle : Icons.cancel,
                    color: isCorrect ? Colors.green : Colors.red,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            ...List.generate(
              question.options.length,
                  (oIndex) => RadioListTile<int>(
                title: Text(
                  question.options[oIndex],
                  style: showResults && oIndex == correctAnswerIndex
                      ? const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)
                      : null,
                ),
                value: oIndex,
                groupValue: selectedAnswers[qIndex],
                onChanged: showResults ? null : (value) => handleAnswerSelect(qIndex, value!),
                subtitle: showResults && oIndex == correctAnswerIndex
                    ? const Text('Correct Answer', style: TextStyle(color: Colors.green))
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}