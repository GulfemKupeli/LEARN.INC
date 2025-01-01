import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:learn_inc/services/api_service.dart';
import 'package:learn_inc/providers/user_provider.dart';
import 'package:learn_inc/file_upload_helper.dart';
import 'package:learn_inc/services/file_summary_helper.dart';

class ChatScreen extends StatefulWidget {
  final bool isDayMode;

  const ChatScreen({Key? key, required this.isDayMode}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ApiService _apiService = ApiService();
  final FileSummaryHelper _fileSummaryHelper = FileSummaryHelper();
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> messages = [];
  bool isLoading = false;
  bool isFilePickerOpen = false;

  // Theme colors based on mode
  late final ThemeColors _colors;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _colors = ThemeColors(isDayMode: widget.isDayMode);
  }

  Future<void> _addWelcomeMessage() async {
    setState(() {
      messages.add({
        "sender": "bot",
        "messageType": "text",
        "message": "Hi! How can Sashimi assist you today?"
      });
    });
  }

  Future<void> sendMessage() async {
    if (_chatController.text.isNotEmpty) {
      final userMessage = _chatController.text.trim();

      setState(() {
        messages.add({
          "sender": "user",
          "messageType": "text",
          "message": userMessage
        });
        isLoading = true;
      });
      _scrollToBottom();
      _chatController.clear();

      try {
        final response = await _apiService.callChatbot(userMessage);
        setState(() {
          messages.add({
            "sender": "bot",
            "messageType": "text",
            "message": response
          });
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          messages.add({
            "sender": "bot",
            "messageType": "text",
            "message": "An error occurred. Please try again later."
          });
          isLoading = false;
        });
      }

      _scrollToBottom();
    }
  }

  Future<void> _handleFileUpload(BuildContext context) async {
    if (isFilePickerOpen) return;
    setState(() => isFilePickerOpen = true);

    try {
      final filePath = await FileUploadHelper.pickFile();

      if (filePath != null) {
        final fileName = filePath.split('/').last;
        setState(() {
          messages.add({
            "sender": "user",
            "messageType": "text",
            "message": "Selected file: $fileName"
          });
        });

        final flashcards = await _fileSummaryHelper.pickFileAndGenerateFlashcards();

        if (flashcards != null) {
          if (flashcards.length == 1 &&
              (flashcards[0].contains("No file was selected.") ||
                  flashcards[0].contains("No text could be extracted") ||
                  flashcards[0].contains("error occurred"))) {
            setState(() {
              messages.add({
                "sender": "bot",
                "messageType": "text",
                "message": flashcards[0],
              });
            });
          } else {
            setState(() {
              messages.add({
                "sender": "bot",
                "messageType": "flashcards",
                "flashcardsList": flashcards,
              });
            });
          }
        } else {
          setState(() {
            messages.add({
              "sender": "bot",
              "messageType": "text",
              "message": "No file was selected or an unexpected error occurred."
            });
          });
        }
      }
    } catch (e) {
      setState(() {
        messages.add({
          "sender": "bot",
          "messageType": "text",
          "message": "An error occurred during file upload: $e"
        });
      });
    } finally {
      setState(() => isFilePickerOpen = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _colors.backgroundColor,
        body: Column(
        children: [
        // Üst boşluğu doldur
        Container(
        height: 40.0, // Üst boşluk yüksekliği (istenilen kadar ayarlayabilirsiniz)
        color: const Color(0xFF4DD0E1), // AppBar rengiyle aynı renk
    ),

    // AppBar
    PreferredSize(
    preferredSize: const Size.fromHeight(56.0), // AppBar yüksekliği
    child: AppBar(
    backgroundColor: _colors.appBarColor, // AppBar rengi
    title: Text(
    "Chat Assistant",
    style: TextStyle(color: _colors.appBarTextColor), // AppBar metin rengi
    ),
    iconTheme: IconThemeData(color: _colors.appBarTextColor), // Simge rengi
    elevation: 2, // AppBar gölgesi
    ),
    ),
    Expanded(
    child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isUser = message["sender"] == "user";
                final messageType = message["messageType"];

                if (messageType == "flashcards") {
                  final flashcardsList = message["flashcardsList"] as List<String>? ?? [];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: flashcardsList.map((flashcard) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6.0,
                          horizontal: 12.0,
                        ),
                        child: Card(
                          color: _colors.flashcardColor,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            side: BorderSide(
                              color: _colors.flashcardBorderColor,
                              width: 0.5,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              flashcard,
                              style: TextStyle(
                                color: _colors.flashcardTextColor,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6.0,
                    horizontal: 12.0,
                  ),
                  child: Row(
                    mainAxisAlignment:
                    isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isUser) ...[
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _colors.avatarBorderColor,
                              width: 1,
                            ),
                          ),
                          child: const CircleAvatar(
                            backgroundImage: AssetImage('assets/octopus.png'),
                            radius: 20,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                      ],
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: isUser
                                ? _colors.userMessageColor
                                : _colors.botMessageColor,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(12.0),
                              topRight: const Radius.circular(12.0),
                              bottomLeft: isUser
                                  ? const Radius.circular(12.0)
                                  : Radius.zero,
                              bottomRight: isUser
                                  ? Radius.zero
                                  : const Radius.circular(12.0),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _colors.messageShadowColor,
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Text(
                            message["message"] ?? "",
                            style: TextStyle(
                              color: isUser
                                  ? _colors.userMessageTextColor
                                  : _colors.botMessageTextColor,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: _colors.inputBarColor,
              boxShadow: [
                BoxShadow(
                  color: _colors.inputBarShadowColor,
                  blurRadius: 4,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.attach_file,
                    color: _colors.iconColor,
                  ),
                  onPressed: () => _handleFileUpload(context),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    style: TextStyle(color: _colors.inputTextColor),
                    decoration: InputDecoration(
                      hintText: "Send a message...",
                      hintStyle: TextStyle(color: _colors.hintTextColor),
                      filled: true,
                      fillColor: _colors.inputFillColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                IconButton(
                  icon: Icon(
                    Icons.send,
                    color: _colors.sendButtonColor,
                  ),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    ),],),);
  }
}

// Separate class to manage theme colors
class ThemeColors {
  final bool isDayMode;

  ThemeColors({required this.isDayMode});

  Color get backgroundColor => isDayMode
      ? const Color(0xFFF5F5F5)
      : const Color(0xFF121212);

  Color get appBarColor => isDayMode
      ? const Color(0xFF4DD0E1)
      : const Color(0xFF1E1E1E);

  Color get appBarTextColor => isDayMode
      ? Colors.black
      : Colors.white;

  Color get userMessageColor => isDayMode
      ? const Color(0xFF2196F3)
      : const Color(0xFF1565C0);

  Color get botMessageColor => isDayMode
      ? Colors.white
      : const Color(0xFF2C2C2C);

  Color get userMessageTextColor => Colors.white;

  Color get botMessageTextColor => isDayMode
      ? Colors.black87
      : Colors.white;

  Color get flashcardColor => isDayMode
      ? Colors.white
      : const Color(0xFF2C2C2C);

  Color get flashcardBorderColor => isDayMode
      ? Colors.grey.withOpacity(0.2)
      : Colors.grey.withOpacity(0.1);

  Color get flashcardTextColor => isDayMode
      ? Colors.black87
      : Colors.white;

  Color get inputBarColor => isDayMode
      ? Colors.white
      : const Color(0xFF1E1E1E);

  Color get inputBarShadowColor => Colors.black.withOpacity(0.1);

  Color get inputFillColor => isDayMode
      ? const Color(0xFFF5F5F5)
      : const Color(0xFF2C2C2C);

  Color get inputTextColor => isDayMode
      ? Colors.black87
      : Colors.white;

  Color get hintTextColor => isDayMode
      ? Colors.black54
      : Colors.white70;

  Color get iconColor => isDayMode
      ? Colors.black54
      : Colors.white70;

  Color get sendButtonColor => isDayMode
      ? const Color(0xFF4DD0E1)
      : const Color(0xFF2196F3);

  Color get messageShadowColor => Colors.black.withOpacity(0.1);

  Color get avatarBorderColor => isDayMode
      ? Colors.grey.withOpacity(0.2)
      : Colors.white24;
}
