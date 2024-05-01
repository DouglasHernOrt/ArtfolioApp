import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class RequestScreen extends StatefulWidget {
  @override
  _RequestScreenStateState createState() => _RequestScreenStateState();
}

class _RequestScreenStateState extends State<RequestScreen> {
  late List<bool> _isChecked;

  @override
  void initState() {
    super.initState();
    _isChecked = List<bool>.filled(
        0, false); // Initialize _isChecked list with default values
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      // Handle the case where the user is not logged in
      return const Scaffold(
        body: Center(
          child: Text('User not logged in'),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Message Requests'),
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('requests')
              .where('receiver', isEqualTo: currentUser.displayName)
              .snapshots(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text('No message requests'),
              );
            } else {
              // Update _isChecked list length if needed
              if (_isChecked.length != snapshot.data!.docs.length) {
                _isChecked =
                    List<bool>.filled(snapshot.data!.docs.length, false);
              }

              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  var request = snapshot.data!.docs[index];
                  var sender = request['sender'];
                  var message = request['message'];
                  var timestamp = request['timestamp'];
                  var formattedDate =
                      DateFormat('MMM dd, yyyy').format(timestamp.toDate());

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('From: $sender'),
                          Text(
                            'Message: $message',
                            style: const TextStyle(fontSize: 16.0),
                          ),
                          Text('Time: $formattedDate'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Checkbox(
                                value: _isChecked[index],
                                onChanged: (bool? value) {
                                  setState(() {
                                    _isChecked[index] = value ?? false;
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  request.reference.delete();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      );
    }
  }
}
