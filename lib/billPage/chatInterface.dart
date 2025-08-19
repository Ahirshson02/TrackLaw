import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:provider/provider.dart';
import 'package:tracklaw/billPage/messageService.dart';
import 'package:tracklaw/models/congress.dart';
import "../apis/firebaseAPI.dart";
import '../models/chatMessage.dart';
import '../models/legislativePrompt.dart';



class ChatContainer extends StatefulWidget {
  List<ChatMessage> messages;
  final Bill bill;
   ChatContainer({
    super.key, 
    required this.messages,
    required this.bill,
    //this.scrollController,
  });

State<ChatContainer> createState() => _ChatContainer();
}
class _ChatContainer extends State<ChatContainer>{
  final ScrollController? scrollController = ScrollController();
  //late StreamSubscription<ChatMessage> _subscription;
 
  @override
void initState() {
  super.initState();
  // _subscription = MessageService().messageStream.listen((message) {
  //   setState(() {
  //     widget.messages.add(message);
  //   });
  // });
}

@override
void dispose(){
 // _subscription.cancel();
  scrollController?.dispose();
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: 50,
        maxHeight: 300,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 10,
            spreadRadius: 0.5,
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.all(12),
          itemCount: widget.messages.length,
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final message = widget.messages[index];
            return MessageBubble(
              message: message.text,
              isUser: message.isFromUser,
            );
          },
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isUser;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? Theme.of(context).primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  
}

class ChatInput extends StatefulWidget {
  final Bill bill;
  final String filepath;
  const ChatInput({Key? key, required this.bill, required this.filepath}) : super(key: key);
  

  @override
  State<ChatInput> createState() => _ChatInputState();
}
class _ChatInputState extends State<ChatInput> {
  
  final String apiKey = dotenv.env['GEMINI_API'] ?? 'default_key';
  final FirestoreService firestore = FirestoreService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  late final GenerativeModel model;
  late final String fileContents;

  @override initState(){
    super.initState();
    model = GenerativeModel(
      model: 'gemini-2.5-flash-lite',
      apiKey: apiKey,
    );
   // fileContents = textFromPdf(widget.filepath).toString();
   // print("filecontents: $fileContents");
    loadText();
  }
  Future<void> loadText() async{
    try {
    final content = await textFromPdf(widget.filepath);
    setState(() {
      fileContents = content; // Update state when ready
    });
    print("filecontents: $fileContents");
  } catch (e) {
    print("Error loading PDF: $e");
  }
  }
  Future<String> textFromPdf(String filepath) async{
    final bytes = await File(filepath).readAsBytes();
    final document = PdfDocument(inputBytes: bytes);
    String text = PdfTextExtractor(document).extractText();
    document.dispose();
    return text;
  }


  Widget build(BuildContext context) {
    //String userId = context.read<UserNotifier>().user!.id;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            offset: const Offset(0, -1),
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 10.0,
                ),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          const SizedBox(width: 8.0),
          CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () {
                // Send message logic
                if (_textController.text.trim().isNotEmpty) {
                  setState(() {
                    //send new message object to list of messages in ChatContainer;
                    _sendMessage(true, _textController.text);
                   _textController.clear();
                  });

                  // Auto-scroll to the bottom
                  // Future.delayed(const Duration(milliseconds: 100), () {
                  //   _scrollController.animateTo(
                  //     _scrollController.position.maxScrollExtent,
                  //     duration: const Duration(milliseconds: 300),
                  //     curve: Curves.easeOut,
                  //   );
                  // });
                }
              },
            ),
          ),
        ],
      ),
    );
  }
  void _sendMessage(bool isUser, String text) {

    final messageID = FirestoreService().getNewMessageID();
    final user = FirebaseAuth.instance.currentUser;
    String userId = user!.uid;
    final ChatMessage message = ChatMessage(id: messageID, userId: userId, billId: widget.bill.billId, text: text, isFromUser: isUser, timestamp: DateTime.now());
    firestore.sendMessage(message);
    MessageService().sendMessage(message);
    sendToGemini(text, userId);
  }

  Future<void> sendToGemini(String userInput, String userId) async {
    
    List<List<String>> chatHistory = MessageService().readMessages();
    final prompt = LegislativePrompt(documentName: widget.bill.title!, documentText: fileContents, chatHistory: chatHistory).build();
    final content = Content.text(prompt);
    print("sending to Gemini");
    final response = await model.generateContent([content]);
    final textResponse = response.text ?? "No response";

    setState(() {
      final messageID = FirestoreService().getNewMessageID();
      final ChatMessage message = ChatMessage(
          id: messageID,
          userId: userId,
          billId: widget.bill.billId,
          text: textResponse,
          isFromUser: false,
          timestamp: DateTime.now());
      firestore.sendMessage(message);
      MessageService().sendMessage(message);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }


}