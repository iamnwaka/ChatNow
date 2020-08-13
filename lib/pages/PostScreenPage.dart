import 'package:chatnow/pages/HomePage.dart';
import 'package:chatnow/widgets/HeaderWidget.dart';
import 'package:chatnow/widgets/PostWidget.dart';
import 'package:chatnow/widgets/ProgressWidget.dart';
import 'package:flutter/material.dart';

class PostScreenPage extends StatelessWidget {
  final String postId;
  final String userId;

  PostScreenPage({
    this.postId,
    this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: postsReference
            .document(userId)
            .collection("usersPost")
            .document(postId)
            .get(),
        builder: (context, dataSnapshot) {
          if (!dataSnapshot.hasData) {
            return circularProgress();
          }

          Post post = Post.fromDocument(dataSnapshot.data);
          return Center(
            child: Scaffold(
              appBar: header(context:context, strTitle: post.description),
              body: ListView(
                children: [
                  Container(
                    child: post,
                  ),
                ],
              ),
            ),
          );
        });
  }
}
