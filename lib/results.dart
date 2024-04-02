import 'package:cross_file_image/cross_file_image.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart' as rv;
import 'package:colorgram/colorgram.dart';

class ProcessPage extends StatefulWidget {
  final List<XFile> fileList;
  ProcessPage({required this.fileList});

  @override
  State<ProcessPage> createState() => _ProcessPageState(data: fileList);
}

/// NOTE: extractColor() function uses Flutter APIs that will not work in an isolate.
class _ProcessPageState extends State<ProcessPage> {
  // this function uses compute to implment colorgram algorithm on a seperate isolate
  Future<List<List<CgColor>>> _processImageList(List<XFile> files) async {
    List<List<CgColor>> store = [];

    for (XFile i in files) {
      store.add(await extractColor(FileImage(File(i.path)), 10));
    }

    return store;
  }

  final List<XFile> data; //List of chosen image in XFile class

  _ProcessPageState({required this.data});

// late so it only runs when called by FutureBuilder
  late var colors = _processImageList(data);
  Color boxHighlightColor = Colors.transparent;
  List selectedColorCode = ['', '', '', ''];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Center(
            child: FutureBuilder(
                future: colors,
                builder: (context, snapshot) {
                  Widget child;
                  if (snapshot.hasData &&
                      snapshot.connectionState == ConnectionState.done) {
                    var colorData = snapshot.data;
// colorData = List of List of CgColor
// colorDataIn = List of CgColor
                    child = ListView.builder(
                      itemCount: colorData!.length,
                      itemBuilder: (context, index) {
                        var colorDataIn = colorData[index];
                        var colorList = colorDataIn
                            .map(
                              (e) => Color.fromARGB(255, e.r, e.g, e.b),
                            )
                            .toList();
                        List<double> perList = [];
                        double temp = 0;
                        for (var i in colorDataIn) {
                          temp += i.percentage;
                          perList.add(temp);
                        }
                        return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(35.0),
                            ),
                            child: Column(children: [
                              // This column consists of all widgets in the card
                              Container(
                                  height: 200,
                                  width: double.infinity,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(35),
                                        topRight: Radius.circular(35)),
                                    child: Image(
                                      image: XFileImage(data[index]),
                                      fit: BoxFit.fitWidth,
                                    ),
                                  )),
                              Text(data[index].name),
                              Container(
                                  constraints: new BoxConstraints(
                                    minHeight: 5.0,
                                    maxHeight: 300.0,
                                  ),
                                  child: GridView.builder(
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 6),
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      itemCount: colorDataIn.length,
                                      itemBuilder: ((context, index) {
                                        var boxColors = colorDataIn[index];
                                        return InkWell(
                                            onTap: () {
                                              //print('RGB: ${boxColors.r},${boxColors.g},${boxColors.b},${boxColors.percentage}');

                                              selectedColorCode = [
                                                boxColors.r,
                                                boxColors.g,
                                                boxColors.b,
                                                (boxColors.percentage * 100)
                                                    .toStringAsFixed(1)
                                              ];
                                            },
                                            child: Container(
                                              margin: EdgeInsets.all(10),
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                  color: Color.fromARGB(
                                                      255,
                                                      boxColors.r,
                                                      boxColors.g,
                                                      boxColors.b)),
                                            ));
                                      }))),
                              const SizedBox(height: 20),
                              Container(
                                margin: EdgeInsets.all(10),
                                height: 30,
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        stops: perList,
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: colorList)),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                  'Selected: RGB: ${selectedColorCode[0]} ${selectedColorCode[1]} ${selectedColorCode[2]} \n Percentage: ${selectedColorCode[3]}%'),
                              SizedBox(height: 10),
                              Row(children: [
                                TextButton(
                                    onPressed: () =>
                                        Clipboard.setData(ClipboardData(
                                                text:
                                                    '${selectedColorCode[0]},${selectedColorCode[1]},${selectedColorCode[2]}'))
                                            .then((_) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text(
                                                      "RGB Color Code copied to clipboard")));
                                        }),
                                    child: Text('Copy RGB')),
                                TextButton(
                                    onPressed: () =>
                                        Clipboard.setData(ClipboardData(
                                                text:
                                                    '#${selectedColorCode[0].toRadixString(16)}${selectedColorCode[1].toRadixString(16)}${selectedColorCode[2].toRadixString(16)}'))
                                            .then((_) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text(
                                                      "Hex Color Code copied to clipboard")));
                                        }),
                                    child: Text('Copy Hex')),
                              ]),
                              SizedBox(
                                height: 10,
                              )
                            ]));
                      },
                    );
                  } else if (snapshot.hasError) {
                    child = Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: rv.RiveAnimation.asset(
                              r'assets\505.riv',
                            ),
                          ),
                          SizedBox(height: 20),
                          Text('An error has occured, please try again')
                        ]);
                  } else {
                    child = Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: rv.RiveAnimation.asset(
                              r'assets\epar-loading.riv',
                            ),
                          ),
                          SizedBox(height: 20),
                          Text("Running Colorgram Algorithm")
                        ]);
                  }
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: child,
                  );
                })));
  }
}
