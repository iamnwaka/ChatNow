import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatnow/models/user.dart';
import 'package:chatnow/pages/CommentsPage.dart';
import 'package:chatnow/pages/HomePage.dart';
import 'package:chatnow/pages/ProfilePage.dart';
import 'package:chatnow/widgets/ProgressWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  // final String timestamp;
  final dynamic likes;
  final String username;
  final String description;
  final String location;
  final String url;

  Post({
    this.postId,
    this.ownerId,
    // this.timestamp,
    this.likes,
    this.username,
    this.description,
    this.location,
    this.url,
  });

  factory Post.fromDocument(DocumentSnapshot documentSnapshot) {
    return Post(
      postId: documentSnapshot["postId"],
      ownerId: documentSnapshot["ownerId"],
      // timestamp: documentSnapshot["timestamp"],
      likes: documentSnapshot["likes"],
      username: documentSnapshot["username"],
      description: documentSnapshot["description"],
      location: documentSnapshot["location"],
      url: documentSnapshot["url"],
    );
  }

  int getTotalNumberOfLikes(likes) {
    if (likes == null) {
      return 0;
    }

    int counter = 0;
    likes.values.forEach((eachValue) {
      counter = counter + 1;
    });
    return counter;
  }

  @override
  _PostState createState() => _PostState(
        postId: this.postId,
        ownerId: this.ownerId,
        //timestamp: this.timestamp,
        likes: this.likes,
        username: this.username,
        description: this.description,
        location: this.location,
        url: this.url,
        likecount: getTotalNumberOfLikes(this.likes),
      );
}

class _PostState extends State<Post> {
  final String postId;
  final String ownerId;
  // final String timestamp;
  Map likes;
  final String username;
  final String description;
  final String location;
  final String url;
  int likecount;
  bool isLiked;
  bool showHeart = false;
  final String currentOnlinerUserId = currentUser?.id;

  _PostState({
    this.postId,
    this.ownerId,
    // this.timestamp,
    this.likes,
    this.username,
    this.description,
    this.location,
    this.url,
    this.likecount,
  });

  @override
  Widget build(BuildContext context) {
    isLiked = (likes[currentOnlinerUserId] == true);
    return Padding(
      padding: EdgeInsets.only(bottom: 12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [createPostHead(), createPostPicture(), createPostFooter()],
      ),
    );
  }

  createPostHead() {
    return FutureBuilder(
      future: usersReference.document(ownerId).get(),
      builder: (context, dataSnapshot) {
        if (!dataSnapshot.hasData) {
          return circularProgress();
        }
        User user = User.fromDocument(dataSnapshot.data);
        bool isPostOwner = currentOnlinerUserId == ownerId;

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(user.url),
            backgroundColor: Colors.grey,
          ),
          title: GestureDetector(
            onTap: () => displayUserProfile(context, userProfileId: user.id),
            child: Text(
              user.username,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          subtitle: Text(
            location,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          trailing: isPostOwner
              ? IconButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.white,
                  ),
                  onPressed: () => print("deleted"),
                )
              : Text(""),
        );
      },
    );
  }

  removeLiked() {
    bool isNotPostOwner = currentOnlinerUserId != ownerId;

    if (isNotPostOwner) {
      activityFeedReference
          .document(ownerId)
          .collection("feedItems")
          .document(postId)
          .get()
          .then((document) {
        if (document.exists) {
          document.reference.delete();
        }
      });
    }
  }

  addLike() {
    bool isNotPostOwner = currentOnlinerUserId != ownerId;

    if (isNotPostOwner) {
      activityFeedReference
          .document(ownerId)
          .collection("feedItems")
          .document(postId)
          .setData({
        "type": "like",
        "username": currentUser.username,
        "userId": currentUser.id,
        "timestamp": DateTime.now(),
        "url": url,
        "postId": postId,
        "userProfileImg": currentUser.url,
      });
    }
  }

  controlUserLikedPost() {
    bool _liked = likes[currentOnlinerUserId] = true;

    if (_liked) {
      postsReference
          .document(ownerId)
          .collection("usersPots")
          .document(postId)
          .updateData({"$likes.$currentOnlinerUserId": false});
      removeLiked();

      setState(() {
        likecount = likecount - 1;
        isLiked = false;
        likes[currentOnlinerUserId] = false;
      });
    } else if (!_liked) {
      postsReference
          .document(ownerId)
          .collection("usersPosts")
          .document(postId)
          .updateData({"likes.$currentOnlinerUserId": true});

      addLike();

      setState(() {
        likecount = likecount + 1;
        isLiked = true;
        likes[currentOnlinerUserId] = true;
        showHeart = true;
      });
      Timer(Duration(milliseconds: 800), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  createPostPicture() {
    return GestureDetector(
      onDoubleTap: () => controlUserLikedPost,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.network(url),
          showHeart
              ? Icon(
                  Icons.favorite,
                  size: 140.0,
                  color: Colors.pink,
                )
              : Text("")
        ],
      ),
    );
  }

  createPostFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 40.0, left: 20.0),
            ),
            GestureDetector(
              onTap: () => controlUserLikedPost(),
              child: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                size: 20.0,
                color: Colors.pink,
              ),
            ),
            Padding(
                padding: EdgeInsets.only(
              right: 20.0,
            )),
            GestureDetector(
              onTap: () => displayComments(context,
                  postId: postId, ownerId: ownerId, url: url),
              child: Icon(
                Icons.chat_bubble,
                size: 28.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                "$likecount likes",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                "$username",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: Text(
                description,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  displayComments(BuildContext context,
      {String postId, String ownerId, String url}) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return CommentsPage(
        postId:postId,
        postOwnerId: ownerId,
        postImageUrl: url,
      );
    }));
  }
  displayUserProfile(BuildContext context, {String userProfileId}) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProfilePage(
                  userProfileId: userProfileId,
                )));
  }
}
