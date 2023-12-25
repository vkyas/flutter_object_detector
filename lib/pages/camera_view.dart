import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1_connect_server/components/scan_controller.dart';
import 'package:get/get.dart';

class CameraView extends StatefulWidget {
  const CameraView({super.key});

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> with WidgetsBindingObserver {
  late ScanControler scanController;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.grey[900],
        title: const Text(
          "Live Object Detection",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        elevation: 0.5,
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        top: false,
        bottom: false,
        child: GetBuilder<ScanControler>(
            init: ScanControler(),
            builder: (controller) {
              scanController = controller;
              return Stack(
                children: [
                  Positioned(
                    top: 0.0,
                    left: 0.0,
                    width: size.width,
                    height: size.height,
                    child: SizedBox(
                      height: size.height,
                      child: (!controller.isCameraInitialized.value)
                          ? const Center(
                              child: Text("Preview Loading..."),
                            )
                          : AspectRatio(
                              aspectRatio:
                                  controller.cameraController.value.aspectRatio,
                              child: CameraPreview(controller.cameraController),
                            ),
                    ),
                  ),
                  Stack(
                      children:
                          displayBoxesAroundRecognizedObjects(controller, size))
                ],
              );
            }),
      ),
    );
  }

  List<Widget> displayBoxesAroundRecognizedObjects(
      ScanControler controler, Size screen) {
    if (controler.detectedList == null) return [];

    double factorX = screen.width;
    double factorY = screen.height;

    return controler.detectedList!.map((result) {
      return Positioned(
        left: result["rect"]["x"] * factorX,
        top: result["rect"]["y"] * factorY,
        width: result["rect"]["w"] * factorX,
        height: result["rect"]["h"] * factorY,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            border: Border.all(
                color: (result['confidenceInClass'] * 100) > 55
                    ? Colors.green
                    : Colors.red,
                width: 2.0),
          ),
          child: Text(
            "${result['detectedClass']} ${(result['confidenceInClass'] * 100).toStringAsFixed(0)}%",
            style: TextStyle(
              background: Paint()
                ..color = (result['confidenceInClass'] * 100) > 55
                    ? Colors.green
                    : Colors.red,
              color: Colors.black,
              fontSize: 18.0,
            ),
          ),
        ),
      );
    }).toList();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.paused:
        scanController.cameraController.stopImageStream();
        break;
      case AppLifecycleState.resumed:
        if (!scanController.cameraController.value.isStreamingImages) {
          await scanController.startStream();
        }
        break;
      default:
    }
  }
}
