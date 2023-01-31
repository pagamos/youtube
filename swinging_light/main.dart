import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
        duration: const Duration(milliseconds: 1500), vsync: this)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          animationController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          animationController.forward();
        }
      });

    animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
        body: Container(
      width: size.width,
      height: size.height,
      color: Colors.black87,
      child: AnimatedBuilder(
          animation: animationController,
          builder: (_, child) {
            Tween<double> tween = Tween(begin: -20, end: 20);
            animation = tween.animate(CurvedAnimation(
                parent: animationController, curve: Curves.fastOutSlowIn));

            double radio = 150;
            double x =
                radio * sin(pi * 2 * animation.value / 360) + size.width / 2;
            double y = radio * cos(pi * 2 * animation.value / 360);

            return Stack(
              children: [
                Center(
                  child: Container(
                    margin: EdgeInsets.only(top: 250),
                    child: Cube(
                      onSceneCreated: ((Scene scene) {
                        scene.camera.position.z = 10;
                        scene.camera.position.x = 10;
                        scene.camera.position.y = 5;
                        scene.world.add(Object(
                            fileName: 'assets/images/3d/pigeon.obj',
                            scale: Vector3(7.0, 7.0, 7.0)));
                      }),
                    ),
                  ),
                ),
                Positioned(
                  top: y - 150 + animation.value,
                  left: x - size.width / 2 + animation.value / 10 * 5,
                  child: Transform.rotate(
                    angle: animation.value / 100 * -1,
                    child: Container(
                      width: size.width / 2,
                      height: 400,
                      child: CustomPaint(
                        painter: MyLightPainter(
                          widthScreen: size.width,
                          heightScreen: size.height,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  // light
                  top: y + 20,
                  left: x - 15 + animation.value / 10 * 3,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                            width: 2, color: Colors.white.withOpacity(0.2)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.white.withOpacity(0.5),
                              spreadRadius: 15,
                              blurRadius: 20,
                              offset: Offset(0, 0))
                        ]),
                  ),
                ),
                CustomPaint(
                  // line wire
                  size: Size(300, 300),
                  painter: MyLinePainter(
                      posX: size.width / 2 - 2,
                      animationValue: animation.value),
                ),
                Positioned(
                  top: y,
                  left: x - 12.5 + animation.value / 10,
                  child: Transform.rotate(
                    angle: animation.value / 100 * -1,
                    child: Container(
                      width: 25,
                      height: 25,
                      child: CustomPaint(
                        size: Size(26, 26),
                        painter: MyLampBasePainter(
                            // the black thing like a cone
                            posX: size.width / 2),
                      ),
                    ),
                  ),
                )
              ],
            );
          }),
    ));
  }
}

class MyLightPainter extends CustomPainter {
  final double widthScreen;
  final double heightScreen;

  const MyLightPainter({this.widthScreen = 0.0, this.heightScreen = 1});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    double quarterWidth = size.width / 4;

    Path pathLines = Path()
      ..addRect(Rect.fromLTWH(-widthScreen / 2, -heightScreen / 2,
          widthScreen * 2, heightScreen * 2))
      ..moveTo(size.width, 150)
      ..lineTo(quarterWidth, size.height + 150)
      ..quadraticBezierTo(size.width, size.height + 300,
          widthScreen - quarterWidth, size.height + 150);
    canvas.drawPath(pathLines, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class MyLinePainter extends CustomPainter {
  final double posX;
  final double animationValue;

  const MyLinePainter({this.posX = 0.0, this.animationValue = 1});

  @override
  void paint(Canvas canvas, Size size) {
    double radio = 150;
    double x = radio * sin(pi * 2 * animationValue / 360) + posX;
    double y = radio * cos(pi * 2 * animationValue / 360);

    final p1 = Offset(posX + 2, 0);
    final p2 = Offset(x + 2, y);
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;
    canvas.drawLine(p1, p2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class MyLampBasePainter extends CustomPainter {
  final double posX;

  const MyLampBasePainter({this.posX = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    Path pathLines = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2 - 3, 0)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width / 2 + 3, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height);

    canvas.drawPath(pathLines, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
