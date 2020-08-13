import 'package:chatnow/models/user.dart';
import 'package:chatnow/pages/CreateAccountPage.dart';
import 'package:chatnow/pages/NotificationsPage.dart';
import 'package:chatnow/pages/ProfilePage.dart';
import 'package:chatnow/pages/SearchPage.dart';
import 'package:chatnow/pages/TimeLinePage.dart';
import 'package:chatnow/pages/UploadPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final usersReference = Firestore.instance.collection("users");
final StorageReference storageReference = FirebaseStorage.instance.ref().child("Post Pictures");
final postsReference = Firestore.instance.collection("post");
final activityFeedReference = Firestore.instance.collection("feed");
final commentsReference = Firestore.instance.collection("comments");
final DateTime timestamp = DateTime.now();
User currentUser;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isSignedIn = false;
  PageController pageController;
  int getPageIndex = 0;

  void initState() {
    super.initState();

    pageController = PageController();

    googleSignIn.onCurrentUserChanged.listen((googleSignInAccount) {
      controlSignIn(googleSignInAccount);
    }, onError: (gError) {
      print("Error message: " + gError);
    });

    googleSignIn
        .signInSilently(suppressErrors: false)
        .then((googleSignInAccount) {
      controlSignIn(googleSignInAccount);
    }).catchError((gError) {
      print("Error message: " + gError);
    });
  }

  controlSignIn(GoogleSignInAccount signInAccount) async {
    if (signInAccount != null) {
      await saveUserInfoToFirestore();
      setState(() {
        isSignedIn = true;
      });
    } else {
      setState(() {
        isSignedIn = false;
      });
    }
  }

  saveUserInfoToFirestore() async {
    final GoogleSignInAccount googleCurrentUser = googleSignIn.currentUser;
    DocumentSnapshot documentSnapshot =
        await usersReference.document(googleCurrentUser.id).get();

    if (!documentSnapshot.exists) {
      final username = await Navigator.push(context,
          MaterialPageRoute(builder: (context) => CreateAccountPage()));

      usersReference.document(googleCurrentUser.id).setData({
        "id": googleCurrentUser.id,
        "profileName": googleCurrentUser.displayName,
        " username": username,
        "url": googleCurrentUser.photoUrl,
        "email": googleCurrentUser.email,
        " bio": "",
        "timestamp": timestamp,
      });

      documentSnapshot =
          await usersReference.document(googleCurrentUser.id).get();
    }
    currentUser = User.fromDocument(documentSnapshot);
  }

  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  loginOUtUser() {
    googleSignIn.signOut();
  }

  loginUser() {
    googleSignIn.signIn();
  }

  onTapChangePage(int pageIndex) {
    pageController.animateToPage(pageIndex,
        duration: Duration(milliseconds: 400), curve: Curves.bounceInOut);
  }

  whenPageChanges(int pageIndex) {
    setState(() {
      this.getPageIndex = pageIndex;
    });
  }

  Scaffold buildHomeScreen() {
    return Scaffold(
      body: PageView(
        children: [
          TimeLinePage(),
          SearchPage(),
          UploadPage(googleCurrentUser: currentUser,),
          NotificationsPage(),
          ProfilePage(userProfileId: currentUser?.id),
        ],
        controller: pageController,
        onPageChanged: whenPageChanges,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: getPageIndex,
        onTap: onTapChangePage,
        backgroundColor: Theme.of(context).accentColor,
        activeColor: Colors.white,
        inactiveColor: Colors.blueGrey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home)),
          BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(
              icon: Icon(
            Icons.photo_camera,
            size: 37.0,
          )),
          BottomNavigationBarItem(icon: Icon(Icons.favorite)),
          BottomNavigationBarItem(icon: Icon(Icons.person)),
        ],
      ),
    );
  }

  Scaffold buildSignedInScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Theme.of(context).accentColor,
                Theme.of(context).primaryColor,
              ]),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'ChatNow',
              style: TextStyle(
                  fontSize: 92.0, color: Colors.white, fontFamily: 'signatra'),
            ),
            GestureDetector(
              onTap: loginUser,
              child: Container(
                width: 270.0,
                height: 65.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/google_signin_button.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isSignedIn) {
      return buildHomeScreen();
    } else {
      return buildSignedInScreen();
    }
  }
}
