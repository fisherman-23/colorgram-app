import 'dart:async';

import 'package:colorgram_app/results.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ExtractButton extends StatefulWidget {
  final StreamController streamController;
  ExtractButton({required this.streamController});

  @override
  State<ExtractButton> createState() => ExtractButtonState();
}

class ExtractButtonState extends State<ExtractButton> {
  List<XFile> temp = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.streamController.stream.listen((data) {
      temp = data;
      setState(() {});
    });
  }

  Widget build(BuildContext context) {
    return TextButton(
        onPressed: temp.isEmpty
            ? null
            : () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProcessPage(fileList: temp)),
                ),
        child: Text('Extract'));
  }
}
//=> ImageButton.source.isEmpty ? null : print('not empty'),
