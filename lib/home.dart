import 'package:flutter/material.dart';
import 'package:flutter_x_unity/unityView.dart';
import 'package:flutter/services.dart';

class Home extends StatefulWidget {

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> with TickerProviderStateMixin {

  static const platform = const MethodChannel('com.flutterxunity.unityview/channel');


  AnimationController _controller;
  BuildContext mContext;

  @override
  void initState() {
      
      _controller = AnimationController(duration: const Duration(milliseconds: 5000), vsync: this);
      _controller.repeat();
      super.initState();

      platform.setMethodCallHandler(_handleMethod);

  }

  @override
  Widget build(BuildContext context) {

    mContext = context;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Unity Integration'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 20, bottom: 20),
              child: RaisedButton(
                onPressed: this.openUnityView,
                child: Text('Enter the demo',
                style: TextStyle(fontSize: 20)),
                color: Colors.grey,
                textColor: Colors.redAccent,
              ),
            ),
            RotationTransition(
              turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
              child: Image.asset('lib/assets/images/wheel-6-300.png'),
            ),
          ],
        ),
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<void> openUnityView() async {
    try {
      final String result = await platform.invokeMethod('openUnityView');
      debugPrint('Result: $result ');
    } on PlatformException catch (e) {
      debugPrint("Error: '${e.message}'.");
    }
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case "unityViewCreated":
        // this.navigateToUnityPage();
        break;
      case "unityViewFinished":
        print("FLUTTER:: UNITY FINISHED!!");
        break;
      default:
        throw UnimplementedError("Unimplemented ${call.method} method");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
