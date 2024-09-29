import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> messages = [];
  bool isEditing = false;
  int editingIndex = -1;

  Map<String, String> botResponses = {
    'hello': 'Hi! How can I help you today?',
    'bye': 'Goodbye! Have a nice day!',
    'summarize chats with sonal': '''
Here’s a summary of the chats with Sonal based on the provided input:

Initial Conversation:
Sonal initiates the conversation with "Hi baby" and shares an Instagram post.
The user responds with "Hello" and a thank you.

Emotional Expression:
The user expresses deep affection, stating that they love Sonal very much, asking them to accept their love. 
They mention proposing to Sonal multiple times and ask for Sonal’s feelings.

Sonal's Response:
Sonal remains non-committal, responding with "Okay" and "Nah" at first. Eventually, Sonal states they can't be in a relationship, saying "Sorry, but I can’t." They mention being focused on their career and unable to commit to a relationship.

User's Persistence:
Despite Sonal's responses, the user tries to persuade them, stating they really love Sonal and would ask for confirmation one last time. The user expresses a lot of emotional pain, repeating that they care for Sonal deeply.

Final Outcome:
Sonal stands firm, explaining that they don’t feel ready for a relationship and reiterate the need to focus on their career. The conversation ends with Sonal suggesting that the user should make their own decisions, while the user acknowledges that they will have to accept Sonal’s decision.
It’s a conversation filled with affection from the user and a polite but clear rejection from Sonal.
'''
  };

  void sendMessage() {
    String messageText = _controller.text.trim().toLowerCase();
    if (messageText.isNotEmpty) {
      setState(() {
        if (isEditing) {
          messages[editingIndex]['text'] = messageText;
          isEditing = false;
          editingIndex = -1;
        } else {
          messages.add({'text': messageText, 'sender': 'user'});
          botReply(messageText);
        }
      });
      _controller.clear();
    }
  }

  void botReply(String userMessage) {
    String botMessage = botResponses.containsKey(userMessage)
        ? botResponses[userMessage]!
        : "I'm not sure how to respond to that.";

    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        messages.add({
          'text': botMessage,
          'sender': 'bot',
        });
      });
    });
  }

  void editMessage(int index) {
    setState(() {
      isEditing = true;
      editingIndex = index;
      _controller.text = messages[index]['text'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [ // Light cream (soft yellow)
              Color(0xFFFFFDE7),
              Color(0xFFFFE0B2),//(0xFFFFE0B2),
            ],

            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 80,),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(10),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Align(
                      alignment: messages[index]['sender'] == 'user'
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: messages[index]['sender'] == 'user'
                              ? Colors.lightBlueAccent.shade200
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          messages[index]['text'],
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    trailing: messages[index]['sender'] == 'user'
                        ? IconButton(
                      icon: Icon(Icons.edit, color: Colors.grey),
                      onPressed: () => editMessage(index),
                    )
                        : null,
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: isEditing
                            ? 'Editing message...'
                            : 'Type your message...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 15),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  IconButton(
                    icon: Icon(isEditing ? Icons.check : Icons.send),
                    onPressed: sendMessage,
                    color: Colors.blueAccent,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
