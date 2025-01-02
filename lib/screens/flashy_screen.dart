import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import '../services/flashcard_generator.dart';

class FlashyScreen extends StatefulWidget {
  final bool isDayMode;

  const FlashyScreen({Key? key, required this.isDayMode}) : super(key: key);

  @override
  _FlashyScreenState createState() => _FlashyScreenState();
}

class _FlashyScreenState extends State<FlashyScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlashcardGenerator _flashcardGenerator = FlashcardGenerator();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController questionController = TextEditingController();
  final TextEditingController answerController = TextEditingController();

  String? selectedFolder;
  List<String> availableFolders = [];
  Color selectedColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    _loadAvailableFolders();
  }

  @override
  void dispose() {
    titleController.dispose();
    questionController.dispose();
    answerController.dispose();
    super.dispose();
  }

  /// Firestore'dan klasörleri yükler
  void _loadAvailableFolders() async {
    final snapshot = await _firestore.collection('folders').get();
    setState(() {
      availableFolders = snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  Future<void> _addFlashcardsFromFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      String filePath = result.files.single.path!;
      try {

        List<Map<String, String>> flashcards =
        await _flashcardGenerator.processFileAndGenerateFlashcards(filePath);

        if (flashcards.isNotEmpty) {
          final folderName = filePath.split('/').last.split('.').first;
          final folderRef = _firestore.collection('folders').doc(folderName);

          await folderRef.set({
            'name': folderName,
            'createdAt': DateTime.now(),
          });
          for (var card in flashcards) {
            await folderRef.collection('flashcards').add({
              'title': 'ଳ',
              'question': card['question'],
              'answer': card['answer'],
              'color': Colors.blue.value,
              'showAnswer': false,
              'createdAt': DateTime.now(),
            });
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Flashcards added to folder: $folderName')),
          );

          _loadAvailableFolders(); // Klasörleri yeniden yükle
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No flashcards generated from the file.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file selected.')),
      );
    }
  }


  void _addOrEditFlashcard(
      {String? cardId,
        Map<String, dynamic>? existingCard,
        String? folderName}) async {
    if (existingCard != null) {
      titleController.text = existingCard['title'];
      questionController.text = existingCard['question'];
      answerController.text = existingCard['answer'];
      selectedColor = Color(existingCard['color']);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Başlık'),
              ),
              TextField(
                controller: questionController,
                decoration: const InputDecoration(labelText: 'Soru'),
              ),
              TextField(
                controller: answerController,
                decoration: const InputDecoration(labelText: 'Cevap'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Kart Rengi:"),
                  Wrap(
                    spacing: 8.0,
                    children: [
                      _buildColorCircle(Colors.blue),
                      _buildColorCircle(Colors.green),
                      _buildColorCircle(Colors.orange),
                      _buildColorCircle(Colors.red),
                      _buildColorCircle(Colors.purple),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (titleController.text.isNotEmpty &&
                      questionController.text.isNotEmpty &&
                      answerController.text.isNotEmpty &&
                      folderName != null) {
                    final folderRef = _firestore.collection('folders').doc(folderName);
                    final cardData = {
                      'title': titleController.text,
                      'question': questionController.text,
                      'answer': answerController.text,
                      'color': selectedColor.value,
                      'showAnswer': false,
                      'createdAt': DateTime.now(),
                    };

                    if (cardId != null) {
                      await folderRef
                          .collection('flashcards')
                          .doc(cardId)
                          .update(cardData);
                    } else {
                      await folderRef.collection('flashcards').add(cardData);
                    }

                    titleController.clear();
                    questionController.clear();
                    answerController.clear();
                    Navigator.pop(context); // Modal'ı kapat
                  }
                },
                child: Text(existingCard == null ? "Kartı Ekle" : "Kartı Güncelle"),
              ),
              if (cardId != null)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Sil butonuna kırmızı renk
                  ),
                  onPressed: () async {
                    final folderRef = _firestore.collection('folders').doc(folderName);
                    await folderRef.collection('flashcards').doc(cardId).delete();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Kart silindi.')),
                    );
                    Navigator.pop(context); // Modal'ı kapat
                  },
                  child: const Text("Kartı Sil"),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildColorCircle(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
        });
      },
      child: CircleAvatar(
        backgroundColor: color,
        radius: 20,
        child: selectedColor == color
            ? const Icon(Icons.check, color: Colors.white)
            : null,
      ),
    );
  }

  Widget _buildFlashcards(String folderName) {
    return StreamBuilder<QuerySnapshot>(
      stream:
      _firestore.collection('folders').doc(folderName).collection('flashcards').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("Bu klasörde flashcard yok."));
        }

        final flashcards = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: flashcards.length,
          itemBuilder: (context, index) {
            final card = flashcards[index].data() as Map<String, dynamic>;
            final cardId = flashcards[index].id;

            return GestureDetector(
              onTap: () async {
                final docRef = flashcards[index].reference;
                final currentShowAnswer = card['showAnswer'] ?? false;
                await docRef.update({'showAnswer': !currentShowAnswer});
              },
              onLongPress: () {
                _addOrEditFlashcard(
                    cardId: cardId, existingCard: card, folderName: folderName);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Color(card['color']),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card['title'] ?? 'Question',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Question: ${card['question']}",
                      style: const TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    if (card['showAnswer'] ?? false)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          "Answer: ${card['answer']}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDayMode = widget.isDayMode;

    return Scaffold(
      backgroundColor: isDayMode ? Color(0xFFE0F7FA) : Color(0xFF263238),
      body: Column(
        children: [
          Container(
            height: 60.0, // TopBar'ın yüksekliği kadar
            color: isDayMode ? Color(0xFF4DD0E1) : Color(0xFF37474F), // AppBar rengiyle aynı renk
          ),

          // AppBar
          PreferredSize(
            preferredSize: const Size.fromHeight(56.0), // AppBar yüksekliği
            child: AppBar(
              backgroundColor: isDayMode ? Color(0xFF4DD0E1) : Color(0xFF37474F),
              title: const Text("Flashy"),
              actions: [
                IconButton(
                  icon: const Icon(Icons.upload_file),
                  onPressed: _addFlashcardsFromFile, // Dosya yükleme
                ),
              ],
            ),
          ),

          // İçerik
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DropdownButton<String>(
                    value: selectedFolder,
                    hint: const Text("Select a Folder"),
                    items: availableFolders.map((folder) {
                      return DropdownMenuItem(
                        value: folder,
                        child: Text(folder),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedFolder = value;
                      });
                    },
                  ),
                ),
                if (selectedFolder != null)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _buildFlashcards(selectedFolder!),
                    ),
                  )
                else
                  const Expanded(
                    child: Center(
                      child: Text("Please, select a folder."),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );


  }
}
