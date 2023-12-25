// ignore_for_file: avoid_print

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanControler extends GetxController {
  late CameraController cameraController;
  late List<CameraDescription> cameras;
  var isCameraInitialized = false.obs;
  var modelPath = 'assets/models/ssd_mobilenet.tflite';
  var labelPath = 'assets/models/ssd_mobilenet.txt';
  List? detectedList;

  var cameraCount = 0;

  @override
  void onInit() {
    initCamera();
    loadModel();
    super.onInit();
  }

  @override
  void dispose() {
    super.dispose();
    cameraController.dispose();
    Tflite.close();
  }

  void initCamera() async {
    // check camera permission
    // if granted
    var cameraPermission = await Permission.camera.request().isGranted;
    if (cameraPermission) {
      cameras = await availableCameras();
      cameraController = CameraController(cameras[0], ResolutionPreset.max,
          imageFormatGroup: Platform.isIOS
              ? ImageFormatGroup.bgra8888
              : ImageFormatGroup.yuv420);

      await startStream();

      isCameraInitialized(true);
    } else {
      print("Camera permission not granted");
    }
  }

  Future<void> startStream() async {
    await cameraController.initialize().then((value) {
      cameraController.startImageStream((image) {
        cameraCount++;
        if (cameraCount % 10 == 0) {
          cameraCount = 0;
          objectDetection(image);
        }
      });
      update();
    });
  }

  void loadModel() async {
    await Tflite.loadModel(
        model: modelPath,
        labels: labelPath,
        isAsset: true,
        numThreads: 1,
        useGpuDelegate: false);
  }

  void objectDetection(CameraImage image) async {
    var detector = await Tflite.detectObjectOnFrame(
        bytesList: image.planes.map((plane) {
          return plane.bytes;
        }).toList(),
        imageHeight: image.height,
        imageWidth: image.width,
        imageMean: 127.5, // defaults to 127.5
        imageStd: 127.5, // defaults to 127.5
        rotation: 90, // defaults to 90, Android only
        numResultsPerClass: 2, // defaults to 5
        threshold: 0.4, // defaults to 0.1
        asynch: true);

    if (detector != null) {
      detectedList = [];
      detectedList = detector;
      update();
    }
  }
}
