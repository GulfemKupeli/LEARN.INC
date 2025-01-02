import 'dart:convert';
import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../services/api_service.dart';

class FlashcardGenerator {
  final ApiService _apiService = ApiService();

  /// Processes the provided file path, extracts text, summarizes it, and generates flashcards
  Future<List<Map<String, String>>> processFileAndGenerateFlashcards(String filePath) async {
    try {
      // Step 1: Extract Text from PDF
      String extractedText = await _extractTextFromPDF(filePath);
      if (extractedText.isEmpty) {
        throw Exception("Unable to extract text from the selected PDF.");
      }

      // Step 2: Summarize Text using ApiService
      String summary = await _apiService.summarizeDocument(extractedText);
      if (summary.isEmpty) {
        throw Exception("Summarization failed. Please try with a different document.");
      }

      // Step 3: Generate Flashcards using ApiService
      List<String> rawFlashcards = await _apiService.generateFlashcards(summary);

      // Step 4: Parse Flashcards
      List<Map<String, String>> flashcards = _parseFlashcards(rawFlashcards.join('\n'));
      if (flashcards.isEmpty) {
        throw Exception("Failed to parse flashcards from the API response.");
      }

      return flashcards;
    } catch (e) {
      print("Error during processing: $e");
      rethrow; // Rethrow to handle in UI
    }
  }

  /// Extracts text from a PDF file
  Future<String> _extractTextFromPDF(String filePath) async {
    try {
      final bytes = await File(filePath).readAsBytes();
      final pdfDocument = PdfDocument(inputBytes: bytes);
      String text = PdfTextExtractor(pdfDocument).extractText();
      pdfDocument.dispose();
      return text;
    } catch (e) {
      print("PDF Text Extraction Error: $e");
      rethrow;
    }
  }

  /// Parses raw flashcards into a structured format
  List<Map<String, String>> _parseFlashcards(String rawFlashcards) {
    try {
      // Regex pattern to match flashcard format
      final qaPattern = RegExp(
          r'(?:\*\*Front:?\*\*|Front:|\d+\.\s*Front:?)\s*(.*?)\s*(?:\*\*Back:?\*\*|Back:)\s*(.*?)(?=(?:\n\s*(?:\*\*Front:?\*\*|Front:|\d+\.\s*Front:?))|$)',
          dotAll: true,
          multiLine: true);

      final matches = qaPattern.allMatches(rawFlashcards);

      return matches.map((match) {
        final question = match.group(1)?.trim();
        final answer = match.group(2)?.trim();

        if (question == null || answer == null || question.isEmpty || answer.isEmpty) {
          return null;
        }

        return {
          'question': question,
          'answer': answer,
        };
      }).whereType<Map<String, String>>().toList();
    } catch (e) {
      print("Parsing Error: $e");
      return [];
    }  }

  /// Processes a picked file
  Future<List<Map<String, String>>> processPickedFile(String? filePath) async {
    if (filePath == null || filePath.isEmpty) {
      throw Exception("No file selected.");
    }
    return await processFileAndGenerateFlashcards(filePath);
  }

  /// Validates the file path from FilePicker
  String? validateFilePath(dynamic filePickerResult) {
    if (filePickerResult == null) return null;

    // Handle FilePickerResult platform-specific path extraction
    if (filePickerResult is List && filePickerResult.isNotEmpty) {
      final firstFile = filePickerResult.first;
      return firstFile['path'] as String?;
    } else if (filePickerResult is Map) {
      return filePickerResult['path'] as String?;
    }

    return null;
  }
}
