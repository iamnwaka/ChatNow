import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatnow/models/user.dart';
import 'package:chatnow/pages/EditProfilePage.dart';
import 'package:chatnow/pages/HomePage.dart';
import 'package:chatnow/widgets/HeaderWidget.dart';
import 'package:chatnow/widgets/PostTileWidget.dart';
import 'package:chatnow/widgets/PostWidget.dart';
import 'package:chatnow/widgets/ProgressWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final String userProfileId;
  ProfilePage({this.userProfileId});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final String currentOnlineUserId = currentUser?.id;
  bool loading = false;
  int countPost = 0;
  List<Post> postsList = [];
  String postOrientation = "grid";

  get gridTilesList => null;

  void initState() {
    super.initState();
    getAllProfilePosts();
  }

  createProfileTopview() {
    return FutureBuilder(
        future: usersReference.document(widget.userProfileId).get(),
        builder: (context, dataSnapshot) {
          if (!dataSnapshot.hasData) {
            return circularProgress();
          }
          User user = User.fromDocument(dataSnapshot.data);
          return Padding(
            padding: EdgeInsets.all(17.0),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 45.0,
                      backgroundColor: Colors.grey,
                      backgroundImage: CachedNetworkImageProvider(user.url),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              createColumns("Posts", 0),
                              createColumns("Followers", 0),
                              createColumns("Following", 0),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    createButton(),
                  ],
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 13.0),
                  child: Text(
                    user.username,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 5.0),
                  child: Text(
                    user.profileName,
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 3.0),
                  child: Text(
                    user.bio,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Column createColumns(String title, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 30.0,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 5.0),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16.0,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ],
    );
  }

  createButton() {
    bool ownProfile = currentOnlineUserId == widget.userProfileId;
    if (ownProfile) {
      return createButtonTitleAndFunction(
        title: "EDit Profile",
        performFunction: editUserProfile,
      );
    }
  }

  Container createButtonTitleAndFunction(
      {String title, Function performFunction}) {
    return Container(
      padding: EdgeInsets.only(top: 3.0),
      child: FlatButton(
        onPressed: performFunction,
        child: Container(
          width: 245.0,
          height: 26.0,
          child: Text(
            title,
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(6.0),
          ),
        ),
      ),
    );
  }

  editUserProfile() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                EditProfilePage(currentOnlineUserId: currentOnlineUserId)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        context: context,
        strTitle: 'Profile',
      ),
      body: ListView(
        children: [
          createProfileTopview(),
          Divider(),
          createListAndGridPostOrientation(),
          Divider(
            height: 0.0,
          ),
          displayProfilePost(),
        ],
      ),
    );
  }

  displayProfilePost() {
    if (loading) {
      return circularProgress();
    } else if (postsList.isEmpty) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(30.0),
              child: Icon(
                Icons.photo_library,
                color: Colors.grey,
                size: 200.0,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(30.0),
              child: Text(
                "No Posts",
                style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 40.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    } else if (postOrientation == "grid") {
      // ignore: unused_local_variable
      List<GridTile> gridTiles = [];
      postsList.forEach((eachPost) {
        gridTilesList.add(GridTile(child: PostTile(eachPost)));
      });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTilesList,
      );
    } else if (postOrientation == "list") {
      return Column(
        children: postsList,
      );
    }
  }

  getAllProfilePosts() async {
    setState(() {
      loading = true;
    });
    // ignore: unused_local_variable
    QuerySnapshot querySnapshot = await postsReference
        .document(widget.userProfileId)
        .collection("usersPosts")
        .orderBy(timestamp, descending: true)
        .getDocuments();
    setState(() {
      loading = false;
      countPost = QuerySnapshot.documents.length;
      postsList = QuerySnapshot.documents
          .map((documentSnapshot) => Post.fromDocument(documentSnapshot))
          .toList();
    });
  }

  createListAndGridPostOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: Icon(Icons.grid_on),
          color: postOrientation == "grid"
              ? Theme.of(context).primaryColor
              : Colors.grey,
          onPressed: () => setOrientation("grid"),
        ),
        IconButton(
          icon: Icon(Icons.list),
          color: postOrientation == "list"
              ? Theme.of(context).primaryColor
              : Colors.grey,
          onPressed: () => setOrientation("list"),
        ),
      ],
    );
  }

  setOrientation(String orientation) {
    setState(() {
      this.postOrientation = orientation;
    });
  }
}
