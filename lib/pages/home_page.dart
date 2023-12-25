// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors, avoid_print, unnecessary_null_comparison
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1_connect_server/components/object_detector_logic.dart';
import 'package:flutter_application_1_connect_server/pages/camera_view.dart';
import 'package:flutter_application_1_connect_server/screens/forgot_pw_page.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';

class ImageUploader extends StatefulWidget {
  const ImageUploader({super.key});

  @override
  _ImageUploaderState createState() => _ImageUploaderState();
}

class _ImageUploaderState extends State<ImageUploader> {
  final user = FirebaseAuth.instance.currentUser!;

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  File? _image;
  bool isUploading = false;
  String responseMessage = '';

  Future getImage(ImageSource source) async {
    final image = await ImagePicker().pickImage(source: source);

    setState(() {
      if (image != null) {
        _image = File(image.path);
        responseMessage = '';
      } else {
        print('No image selected.');
      }
    });
  }

  Future uploadImage() async {
    if (_image == null) {
      print('No image selected.');
      return;
    }

    setState(() {
      isUploading = true;
    });

    final uri = Uri.parse("http://192.168.74.83:5000/upload");
    var request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('image', _image!.path));
    var response = await request.send();

    if (response.statusCode == 200) {
      print('Image uploaded');
      String responseBody = await response.stream.bytesToString();
      setState(() {
        responseMessage = responseBody;
      });
    } else {
      print('Image not uploaded');
    }

    setState(() {
      isUploading = false;
    });
  }

  void resetImage() {
    setState(() {
      _image = null;
      responseMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: resetImage,
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.grey[300],
          child: ListView(
            padding: const EdgeInsets.all(45),
            children: [
              DrawerHeader(
                child: Icon(
                  Icons.person,
                  color: Colors.grey[900],
                  size: 70,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.rightToLeft,
                        child: const ObjectDetectorLogic(),
                      ),
                    );
                  },
                ),
                title: const Text(
                  'D E T E C T O R',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: IconButton(
                  icon: const Icon(Icons.person_2_rounded),
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.rightToLeft,
                        child: const ForgotPassword(),
                      ),
                    );
                  },
                ),
                title: const Text(
                  'P R O F I L E',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: signUserOut,
                ),
                title: const Text(
                  'L O G O U T',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.grey[300],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image != null
                ? Expanded(
                    child: AspectRatio(
                      aspectRatio: 4,
                      child: Image.file(
                        _image!,
                        // fit: BoxFit.,
                      ),
                    ),
                  )
                : const Text('No image selected.'),
            Text(
              responseMessage,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[900],
                fontSize: 25,
              ),
            ),
            const SizedBox(height: 100),
            Visibility(
              visible: _image != null && !isUploading,
              child: Padding(
                padding: const EdgeInsets.only(right: 40),
                child: ElevatedButton(
                  onPressed: () => uploadImage(),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.grey[900],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 19,
                      horizontal: 60,
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  child: const Text('Upload Image'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Visibility(
              visible: isUploading,
              child: const CircularProgressIndicator.adaptive(),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => getImage(ImageSource.gallery),
            tooltip: 'Pick Image',
            backgroundColor: Colors.grey[900],
            child: Icon(
              Icons.add_photo_alternate_outlined,
              color: Colors.white,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.fade,
                    child: const CameraView(),
                  ),
                );
              },
              tooltip: 'Take Photo',
              backgroundColor: Colors.grey[900],
              child: Icon(
                Icons.camera,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
