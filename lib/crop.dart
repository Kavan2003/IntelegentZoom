import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'dart:async';
import 'dart:io';
import 'package:image/image.dart' as Img;

class ImageCropper extends StatefulWidget {
  final String imagePath;
  final double left;
  final double top;
  final double width;
  final double height;
  // final String s;
  ImageCropper(
    this.imagePath,
    this.left,
    this.top,
    this.width,
    this.height, {
    super.key,
  });

  @override
  _ImageCropperState createState() => _ImageCropperState();
}

class _ImageCropperState extends State<ImageCropper> {
  late Future<dynamic> _imageFuture;
  late ui.Image image;

  @override
  void initState() {
    super.initState();
    _imageFuture = loadImage();
  }

  Future loadImage() async {
    File imageFile = File(widget.imagePath);
    Uint8List imageBytes = await imageFile.readAsBytes();
    Img.Image? decodedImage = Img.decodeImage(imageBytes);
    ui.Codec codec =
        await ui.instantiateImageCodec(Img.encodePng(decodedImage!));
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    image = frameInfo.image;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _imageFuture,
        builder: (context, snapshot) => Center(
          child: CustomPaint(
            painter: ImageCropperPainter(
                widget.left, widget.top, widget.width, widget.height, image),
            child: Container(),
          ),
        ),
      ),
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
                icon: Icon(Icons.save),
                onPressed: () {
                  GallerySaver.saveImage(
                    widget.imagePath,
                  ).then((value) => print('Image is saved'));
                  // .then((bool success) {
                  // print('Image is saved');
                  // } );
                }),
          ],
        ),
      ),
    );
  }

  // Widget build(BuildContext context) {
  //   return FutureBuilder(
  //     future: loadImage(),
  //     builder: (context, snapshot) {
  //       if (snapshot.connectionState == ConnectionState.done) {
  //         return Center(
  //           child: CustomPaint(
  //             painter: ImageCropperPainter(
  //               widget.left,
  //               widget.top,
  //               widget.width,
  //               widget.height,
  //               image,
  //             ),
  //             child: Container(),
  //           ),
  //         );
  //       } else {
  //         // Show a loading indicator while the image is loading
  //         return const Center(child: RefreshProgressIndicator());
  //       }
  //     },
  //   );
  // }
}

class ImageCropperPainter extends CustomPainter {
  final double left;
  final double top;
  final double width;
  final double height;
  final ui.Image image;

  ImageCropperPainter(this.left, this.top, this.width, this.height, this.image);

  @override
  void paint(Canvas canvas, Size size) {
    if (image == null) {
      return;
    }

    var src = Rect.fromLTWH(left, top, width, height);
    var dest = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawImageRect(image, src, dest, Paint());
  }

  @override
  bool shouldRepaint(ImageCropperPainter oldDelegate) {
    return this.image != oldDelegate.image;
  }
}
