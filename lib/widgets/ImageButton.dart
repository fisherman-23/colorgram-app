import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';

class ImageButton extends StatefulWidget {
  static List<XFile> source = [];
  final StreamController streamController;
  ImageButton({required this.streamController});

  @override
  State<ImageButton> createState() => _ImageButtonState();
}

class _ImageButtonState extends State<ImageButton> {
  DecorationImage decorationImage =
      const DecorationImage(image: AssetImage(r'assets\Plus.png'));
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(45),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30.0, sigmaY: 30.0),
          child: SizedBox(
            height: 230,
            width: 230,
            child: InkWell(
                child: Container(
                  decoration: BoxDecoration(
                      image: decorationImage,
                      borderRadius: BorderRadius.circular(45),
                      color: const Color.fromRGBO(255, 255, 255, 0.3)),
                ),
                onTap: () async {
                  final source = await ImagePicker()
                      .pickMultiImage(); //XFile List type, return []  if empty
                  // show image if selected, else display default
                  if (source.isNotEmpty) {
                    // Image(s) selected, update values
                    final bytes = await source[0].readAsBytes();
                    setState(() {
                      decorationImage = DecorationImage(
                          image: MemoryImage(bytes), fit: BoxFit.cover);

                      // to clear all in the list to avoid crossover
                      // adding list of XFile to the stream
                      widget.streamController.add(source);
                    });
                  } else {
                    // When no image is selected, clear all
                    setState(() {
                      decorationImage = const DecorationImage(
                          image: AssetImage(r'assets\Plus.png'));
                      // to handle if empty then update button
                      widget.streamController.add(source);
                    });
                  }
                }),
          ),
        ));
  }
}
