import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  static const String id =  'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  String messageText;
  User loggedInUser;
  void initState(){
    super.initState();
    getcurrentUser();
  }
  void getcurrentUser() async {
    try{
    final user = await _auth.currentUser;
    if (user != null ){
      loggedInUser = user;
      print(loggedInUser.email);
    }
    }catch(e){
      print(e);
    }
  }

  // void getMessages() async {
  //   final messages = await _firestore.collection('messages').get();
  //   for (var message in messages.docs){
  //     print(message.data);
  //   }
  // }

  void messagesStream()async{
    await for(var snapshot in _firestore.collection('messages').snapshots()){
       for (var message in snapshot.docs){
         print(message.data);
    }
  }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                messagesStream();
                // _auth.signOut();
                // Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>
            (stream:_firestore.collection('messages').snapshots(),
            builder:(context,snapshot){
              if(!snapshot.hasData){
                return Center(child: CircularProgressIndicator(backgroundColor: Colors.lightBlueAccent,),);
              }
                 final messages = snapshot.data.docs.reversed;
                List<MessageBubble> messageBubbles = [];
                for (var message in messages){
                  final messageText = message['text'];
                  final messageSender = message['sender'];
                
                final messageBubble = MessageBubble(sender:messageSender,text:messageText);
                messageBubbles.add(messageBubble);
              }
              return Expanded(
                child: ListView(
                  padding:EdgeInsets.symmetric(horizontal:10.0, vertical: 20.0),
                  children: messageBubbles,
                ),
              );
              }
               
              
              ,
             ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      messageTextController.clear();
                      _firestore.collection('messages').add({
                        'text':messageText,
                        'sender':loggedInUser.email
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
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
class MessageStream extends StatelessWidget {
  

  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}
class MessageBubble extends StatelessWidget {
    MessageBubble({this.sender,this.text});
    
    final String sender;
    final String text;
  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(sender,
          style: TextStyle(
            fontSize: 12.0,
            color:Colors.black54 ),),
          Material(
            borderRadius: BorderRadius.circular(30.0),
            elevation: 5.0,
            color: Colors.lightBlueAccent,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0,horizontal: 20.0),
              child: Text(text,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize:15.0, ),),
            ),
          ),
        ],
      ),
    );
  
    
  }
}