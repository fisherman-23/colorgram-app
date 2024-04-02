import 'dart:async';
import 'package:flutter/material.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:colorgram_app/widgets/ImageButton.dart';
import 'package:colorgram_app/widgets/ExtractButton.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

List<int> hslToRgb(double h, double s, double l) {
  double r, g, b;

  if (s == 0) {
    r = g = b = l; // Achromatic
  } else {
    double hueToRgb(double p, double q, double t) {
      if (t < 0) t += 1;
      if (t > 1) t -= 1;
      if (t < 1 / 6) return p + (q - p) * 6 * t;
      if (t < 1 / 2) return q;
      if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6;
      return p;
    }

    double q = l < 0.5 ? l * (1 + s) : l + s - l * s;
    double p = 2 * l - q;
    r = hueToRgb(p, q, h / 360 + 1 / 3);
    g = hueToRgb(p, q, h / 360);
    b = hueToRgb(p, q, h / 360 - 1 / 3);
  }

  return [(r * 255).round(), (g * 255).round(), (b * 255).round()];
}

/*
gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Color.fromARGB(255, 182, 190, 216),
                  Color.fromARGB(255, 221, 191, 207),
                  Color.fromARGB(255, 193, 129, 129)
                ],
              )
*/
class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamController<List<XFile>> sourceStream = StreamController
      .broadcast(); //meant to be shared across files and classes
  Timer? timer;
  double h = 0;

  @override
  void initState() {
    super.initState();
    sourceStream.stream.listen((seconds) {
      print(seconds);
    });
  }

  var temp = [255, 255, 255];
  void initTimer() {
    if (timer != null && timer!.isActive) return;

    timer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      //job
      setState(() {
        h++;
        temp = hslToRgb(h, 0.5, 0.5);

        if (h == 360) {
          h = 0;
        }
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    initTimer();
    return MaterialApp(
      home: Scaffold(
          body: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: [
                    0.15,
                    1,
                  ],
                      colors: [
                    Colors.white,
                    Color.fromARGB(255, temp[0], temp[1], temp[2]),
                  ])),
              child: Column(
                children: [
                  Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(16, 80, 16, 80),
                      child: Column(children: [
                        GradientText(
                          'Colorgram',
                          style: TextStyle(
                              fontSize: 50.0,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w700),
                          colors: [
                            Color.fromARGB(255, 255, 123, 81),
                            Color.fromARGB(255, 117, 184, 32),
                            Color.fromARGB(255, 32, 184, 175),
                            Color.fromARGB(255, 86, 84, 200),
                            Color.fromARGB(255, 149, 84, 200),
                            Color.fromARGB(255, 200, 84, 84)
                          ],
                        ),
                        SizedBox(height: 15),
                        Text(
                            'Created by fisherman-23, thanks to the original work of darosh.github with colorgram.js ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontFamily: 'Montserrat')),
                      ])),
                  ImageButton(
                    streamController: sourceStream,
                  ),
                  ExtractButton(
                    streamController: sourceStream,
                  )
                ],
              ))),
    );
  }
}
