import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:greennursery/data/plant_model.dart';

class CommentsPage extends StatelessWidget {
  final Plants plant;

  const CommentsPage({Key? key, required this.plant}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comments for ${plant.name}'),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('ratings')
            .where('plantId', isEqualTo: plant.id)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var comments = snapshot.data!.docs;

          return ListView.builder(
            itemCount: comments.length,
            itemBuilder: (context, index) {
              var comment = comments[index];
              return ListTile(
                title: Text(comment['comment']),
                subtitle: Text('Rating: ${comment['rating']} - by ${comment['userName']}'),
              );
            },
          );
        },
      ),
    );
  }
}