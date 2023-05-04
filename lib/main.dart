import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

// import 'package:image_cropper/image_cropper.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

import 'crop.dart';
// import 'package:simple_image_cropper/simple_image_cropper.dart';
// import 'package:google_ml_kit/google_ml_kit.dart';
// from firebase_ml_vision import FirebaseVisionImage;

Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      home: TakePictureScreen(
        // Pass the appropriate camera to the TakePictureScreen widget.
        camera: firstCamera,
      ),
    ),
  );
}

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isRearCameraSelected = false;
  // ImageLabeler _imageLabeler = GoogleMlKit.vision.imageLabeler();
  // ObjectDetector objectDetector = FirebaseObjectDetector();

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // .lensDirection == CameraLensDirection.front   ,
      // ? widget.camera
      // : widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    // _imageLabeler.close();
    // super.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // persistentFooterButtons: <Widget>[

      // ],
      appBar: AppBar(
        title: const Text('Take a picture'),
        actions: [],
      ),
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      body: Column(
        children: [
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // If the Future is complete, display the preview.

                return CameraPreview(_controller);
              } else {
                // Otherwise, display a loading indicator.
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        // Provide an onPressed callback.
        onPressed: () async {
          final image = await _controller.takePicture();

          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            final image = await _controller.takePicture();

            if (!mounted) return;

            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  imagePath: image.path,
                ),
              ),
            );
          } catch (e) {
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;
  String s = '';

  DisplayPictureScreen({super.key, required this.imagePath}) {
    // objdet().then((value) => {s = value ; str() });

    // s = await objdet();
    // str();
  }

  @override
  State<DisplayPictureScreen> createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  late InputImage
      inputImage; // Use DetectionMode.stream when processing camera feed.
  // late String s;
  String path = '';
// List<String> values = widget.s.split(',');
  late double left;
  late double top;
  late double width;
  late double height;
  @override
  void initState() {
    super.initState();
    path = widget.imagePath;
    InputImage.fromFilePath(widget.imagePath);

    objdet().then((value) => {
          setState(() {
            widget.s = value;
            List<String> values = widget.s.split(',');
            left = double.parse(values[0]);
            top = double.parse(values[1]);
            width = double.parse(values[2]);
            height = double.parse(values[3]);
          })
        });
  }

  Future<String> objdet() async {
    print('object detection');
    inputImage = InputImage.fromFilePath(widget.imagePath);
    // Use DetectionMode.stream when processing camera feed.
// Use DetectionMode.single when processing a single image.
    const mode = DetectionMode.single;

// Options to configure the detector while using with base model.
    final options = ObjectDetectorOptions(
        classifyObjects: true, mode: mode, multipleObjects: false);

// Options to configure the detector while using a local custom model.
// final options = LocalObjectDetectorOptions(...);

// Options to configure the detector while using a Firebase model.
// final options = FirebaseObjectDetectorOptions();

    final objectDetector = ObjectDetector(options: options);
    final List<DetectedObject> objects =
        await objectDetector.processImage(inputImage);

    for (DetectedObject detectedObject in objects) {
      final rect = detectedObject.boundingBox;
      final trackingId = detectedObject.trackingId;
      final setBounds = detectedObject.boundingBox;
    }

    final sortedObjects = objects.toList()
      ..sort((a, b) =>
          b.boundingBox.width.toInt() *
          b.boundingBox.height.toInt().compareTo(
              a.boundingBox.width.toInt() * a.boundingBox.height.toInt()));

// Get the largest detected object
    final largestObject = sortedObjects.first;

// Get the bounding box coordinates of the largest object
    final left = largestObject.boundingBox.left.toInt();
    final top = largestObject.boundingBox.top.toInt();
    final width = largestObject.boundingBox.width.toInt();
    final height = largestObject.boundingBox.height.toInt();

// Return the bounding box coordinates as a string in the format "left,top,width,height"
    return '$left,$top,$width,$height';
  }

  @override
  Widget build(BuildContext context) {
    // String s = await objdet();
    return Scaffold(
      // appBar: AppBar(title: Text(widget.s)),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Container(
          height: double.infinity,
          child:
              // Image.file(file)
              Image.file(
            File(
              widget.imagePath,
            ),
            fit: BoxFit.contain,
          )),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.save),
        onPressed: () {
          GallerySaver.saveImage(widget.imagePath)
              .then((value) => print('Image is saved' + widget.s));
          // .then((bool success) {
          // print('Image is saved');
          // } );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            IconButton(
              icon: Icon(Icons.zoom_in_map_outlined),
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ImageCropper(
                        widget.imagePath, left, top, width, height),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
