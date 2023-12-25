// ignore_for_file: avoid_print, depend_on_referenced_packages

import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'object_detector_view.dart';

class ObjectDetectorLogic extends StatefulWidget {
  const ObjectDetectorLogic({super.key});

  @override
  State<ObjectDetectorLogic> createState() => _ObjectDetectorView();
}

class _ObjectDetectorView extends State<ObjectDetectorLogic> {
  late ObjectDetector _objectDetector;
  bool _canProcess = false;
  bool _isBusy = false;
  String? _text;

  @override
  void initState() {
    super.initState();
    _initializeDetector(DetectionMode.single);
  }

  @override
  void dispose() {
    _canProcess = false;
    _objectDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ObjectDetectorView(
      title:  'Object Detection',
      text: _text,
      onImage: (inputImage) {
        processImage(inputImage);
      },
    );
  }

  void _initializeDetector(DetectionMode mode) async {
    print('Set detector in mode: $mode');

    const path = 'assets/ml/object_labeler.tflite';
    final modelPath = await _getModel(path);
    final options = LocalObjectDetectorOptions(
      mode: mode,
      modelPath: modelPath,
      classifyObjects: true,
      multipleObjects: true,
    );
    _objectDetector = ObjectDetector(options: options);

    _canProcess = true;
  }

  Future<void> processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });
    final objects = await _objectDetector.processImage(inputImage);

    String text = 'Objects found: ${objects.length}\n\n';
    for (final object in objects) {
      text += 'Object Identified :  ${object.labels.map((e) => e.text)}\n\n';
    }
    _text = text;
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }

  Future<String> _getModel(String assetPath) async {
    if (io.Platform.isAndroid) {
      return 'flutter_assets/$assetPath';
    }
    final path = '${(await getApplicationSupportDirectory()).path}/$assetPath';
    // dirname(path): This is the positional parameter passed to the Directory constructor. It represents the path to the parent directory of the directory that needs to be created. The dirname() function, provided by the io library, takes a path as input and returns the parent directory path.
    await io.Directory(dirname(path)).create(recursive: true);
    // recursive: This is a named parameter that specifies whether the directory should be created recursively if the parent directories do not exist. By default, its value is false. If recursive is set to true, the create() method will create all the necessary parent directories recursively. This means that if any of the parent directories in the path do not exist, they will be created along with the target directory. If recursive is set to false and a parent directory is missing, an error will be thrown.
    final file = io.File(path);
    if (!await file.exists()) {
      final byteData = await rootBundle.load(assetPath);
      await file.writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    }
    return file.path;
  }
}
