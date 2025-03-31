import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tracklaw/src/messageService.dart';
import "/APIs/firebaseAPI.dart";
import '/APIs/congressAPI.dart';
import 'legistlationPage.dart';
class ChatContainer extends StatefulWidget {
  List<ChatMessage> messages;
  final Bill bill;
   ChatContainer({
    Key? key, 
    required this.messages,
    required this.bill,
    //this.scrollController,
  }) : super(key: key);

State<ChatContainer> createState() => _ChatContainer();
}
class _ChatContainer extends State<ChatContainer>{
  final ScrollController? scrollController = ScrollController();
  late StreamSubscription<ChatMessage> _subscription;
 
  @override
void initState() {
  super.initState();
  _subscription = MessageService().messageStream.listen((message) {
    setState(() {
      widget.messages.add(message);
    });
  });
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
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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
  const ChatInput({Key? key, required this.bill}) : super(key: key);

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {

  final FirestoreService firestore = FirestoreService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();


 Widget build(BuildContext context) {
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
                  setState(() async {
                    //send new message object to list of messages in ChatContainer
                    _sendMessage();
                   _textController.clear();
                  });
                  
                  // Auto-scroll to the bottom
                  Future.delayed(const Duration(milliseconds: 100), () {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }
  void _sendMessage() {
    final messageID = FirestoreService().getNewMessageID();
    final ChatMessage message = ChatMessage(id: messageID, userId: "1", billId: widget.bill.billId, text: _textController.text, isFromUser: true, timestamp: DateTime.now());
    firestore.sendMessage(message);
    MessageService().sendMessage(message);
  }
  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }
}