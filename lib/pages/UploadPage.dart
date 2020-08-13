import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatnow/models/user.dart';
import 'package:chatnow/pages/HomePage.dart';
import 'package:chatnow/widgets/ProgressWidget.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as ImD;

class UploadPage extends StatefulWidget {
  final User googleCurrentUser;

  UploadPage({this.googleCurrentUser});

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> with AutomaticKeepAliveClientMixin<UploadPage> {
  File file;
  bool uploading = false;
  String postId = Uuid().v4();
  TextEditingController descriptionTextEditingController =
      TextEditingController();
  TextEditingController locationTextEditingController = TextEditingController();

  get placeMarks => null;

  File get compressedImageFile => null;

  get path => null;
  captureImageWithCamera() async {
    Navigator.pop(context);
    // ignore: deprecated_member_use
    File imageFile = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 600,
      maxWidth: 970,
    );
    setState(() {
      this.file = imageFile;
    });
  }

  pickImageFromGallery() async {
    Navigator.pop(context);
    // ignore: deprecated_member_use
    File imageFile = await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );
    setState(() {
      this.file = imageFile;
    });
  }

  takeImage(mcontext) {
    return showDialog(
      context: mcontext,
      builder: (context) {
        return SimpleDialog(
          title: Text(
            "New Post",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          children: [
            SimpleDialogOption(
              child: Text(
                "Capture Image With Camera",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: captureImageWithCamera,
            ),
            SimpleDialogOption(
              child: Text(
                "Select Image From Gallery",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: pickImageFromGallery,
            ),
            SimpleDialogOption(
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  displayUploadScreen() {
    return Container(
      color: Theme.of(context).accentColor.withOpacity(0.5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate,
            color: Colors.grey,
            size: 200.0,
          ),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9.0)),
                child: Text(
                  "Upload Image",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
                onPressed: () => takeImage(context)),
          ),
        ],
      ),
    );
  }

  clearPostInfo() {
    locationTextEditingController.clear();
    descriptionTextEditingController.clear();
    setState(() {
      file = null;
    });
  }

  getUserCurrentLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    // ignore: unused_local_variable
    List<Placemark> placemark = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark mPlacemark = placeMarks[0];
    // ignore: unused_local_variable
    String completeAddressInfo =
        "${mPlacemark.subThoroughfare}, ${mPlacemark.thoroughfare}, ${mPlacemark.subLocality} ${mPlacemark.locality}, ${mPlacemark.subAdministrativeArea} ${mPlacemark.administrativeArea}, ${mPlacemark.postalCode} ${mPlacemark.country},";
    String specificAddress = '${mPlacemark.locality}, ${mPlacemark.country}';
    locationTextEditingController.text = specificAddress;
  }

  compressingPhoto() async {
    final tDirectory = await getTemporaryDirectory();
    final path = tDirectory.path;
    ImD.Image mImageFile = ImD.decodeImage(file.readAsBytesSync());
    // ignore: unused_local_variable
    final compressImageFile = File('$path/img_$postId.png')
      ..writeAsBytesSync(ImD.encodePng(
        mImageFile,
      ));
    setState(() {
      file = compressedImageFile;
    });
  }

  controlUploadAndSave() async {
    setState(() {
      uploading = true;
    });
    await compressingPhoto();
    String downloadUrl = await uploadPhoto(file);

    savePostInfoToFirestore(
        url: downloadUrl,
        location: locationTextEditingController.text,
        description: descriptionTextEditingController.text);
    locationTextEditingController.clear();
    descriptionTextEditingController.clear();

    setState(() {
      file = null;
      uploading = false;
      postId = Uuid().v4();
    });
  }

  savePostInfoToFirestore({String url, String location, String description}) {
    postsReference
        .document(widget.googleCurrentUser.id)
        .collection('userPosts')
        .document(postId)
        .setData({
      "postId": postId,
      "ownerId": widget.googleCurrentUser.id,
      "timestamp": timestamp,
      "likes": {},
      "username": widget.googleCurrentUser.username,
      "description": description,
      "location": location,
      "url": url,
    });
  }

  Future<String> uploadPhoto(mImageFile) async {
    StorageUploadTask mStorageUploadTask =
        storageReference.child('Post_$postId.png').putFile(mImageFile);
    StorageTaskSnapshot storageTaskSnapshot =
        await mStorageUploadTask.onComplete;
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  displayUploadFormScreen() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: clearPostInfo,
        ),
        title: Text(
          "New Post",
          style: TextStyle(
            fontSize: 24.0,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          FlatButton(
            onPressed: uploading ? null : () => controlUploadAndSave(),
            child: Text(
              'Share',
              style: TextStyle(
                color: Colors.lightGreenAccent,
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
          )
        ],
      ),
      body: ListView(
        children: [
          uploading ? linearProgress() : Text(""),
          Container(
            height: 230.0,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  child: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: FileImage(file), fit: BoxFit.cover)),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 12.0),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  CachedNetworkImageProvider(widget.googleCurrentUser.url),
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                style: TextStyle(
                  color: Colors.white,
                ),
                controller: descriptionTextEditingController,
                decoration: InputDecoration(
                  hintText: 'Say something about image',
                  hintStyle: TextStyle(
                    color: Colors.white,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.person_pin,
              color: Colors.white,
              size: 36.0,
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                style: TextStyle(
                  color: Colors.white,
                ),
                controller: locationTextEditingController,
                decoration: InputDecoration(
                  hintText: 'Write your Location here. ',
                  hintStyle: TextStyle(
                    color: Colors.white,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            width: 220.0,
            height: 110.0,
            alignment: Alignment.center,
            // ignore: missing_required_param
            child: RaisedButton.icon(
              onPressed: getUserCurrentLocation,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(35.0),
              ),
              color: Colors.green,
              icon: Icon(
                Icons.location_on,
                color: Colors.white,
              ),
              label: Text(
                'Get my Current Location',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool get wantKeepAlive => true;

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    return file == null ? displayUploadScreen() : displayUploadFormScreen();
  }
}
                                                         