// ignore_for_file: unnecessary_import, depend_on_referenced_packages, unused_field

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:image_picker/image_picker.dart';

class ObjectDetectorView extends StatefulWidget {
  const ObjectDetectorView({
    Key? key,
    required this.title,
    this.text,
    required this.onImage,
  }) : super(key: key);
  final String title;
  final String? text;
  final Function(InputImage inputImage) onImage;
  @override
  State<ObjectDetectorView> createState() => _ObjectDetectorViewState();
}

class _ObjectDetectorViewState extends State<ObjectDetectorView> {
  File? _image;
  String? _path;
  ImagePicker? _imagePicker;
  final bool _allowPicker = true;

  @override
  void initState() {
    super.initState();

    _imagePicker = ImagePicker();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.grey[900],
        elevation: 0.5,
        centerTitle: true,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.grey[300],
      ),
      backgroundColor: Colors.grey[300],
      body: _galleryBody(),
    );
  }

  Widget _galleryBody() {
    return ListView(
      shrinkWrap: true,
      children: [
        _image != null
            ? SizedBox(
                height: 440,
                width: 400,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    Image.file(_image!),
                  ],
                ),
              )
            : const Icon(
                Icons.image_outlined,
                size: 200,
              ),
        const SizedBox(height: 25),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton(
            onPressed: () => _getImage(ImageSource.gallery),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.grey[900]),
              padding: MaterialStateProperty.all(
                const EdgeInsets.symmetric(vertical: 15),
              ),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
            child: const Center(
              child: Text(
                "From Gallery",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
        if (_image != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('\n\n${widget.text ?? ''}'),
          ),
      ],
    );
  }

  Future _getImage(ImageSource source) async {
    setState(
      () {
        _image = null;
        _path = null;
      },
    );
    final pickedFile = await _imagePicker?.pickImage(source: source);
    if (pickedFile != null) {
      _processPickedFile(pickedFile);
    }
    setState(() {});
  }

  Future _processPickedFile(XFile? pickedFile) async {
    final path = pickedFile?.path;
    if (path == null) {
      return;
    }
    setState(
      () {
        _image = File(path);
      },
    );
    _path = path;
    final inputImage = InputImage.fromFilePath(path);
    widget.onImage(inputImage);
  }
}
