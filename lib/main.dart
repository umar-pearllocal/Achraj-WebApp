import 'dart:async';
import 'package:achraj/src/no_internet_page.dart';
import 'package:achraj/src/web_view_stack.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:splashify/splashify.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: Splashify(
          imagePath: 'assets/image.png',
          backgroundColor: Colors.white,
          imageSize: 300,
          imageFadeIn: true,
          child: const WebViewApp()),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class WebViewApp extends StatefulWidget {
  const WebViewApp({super.key});

  @override
  State<WebViewApp> createState() => _WebViewAppState();
}

class _WebViewAppState extends State<WebViewApp> {
  late StreamSubscription<InternetStatus> listener;
  late WebViewController controller;
  bool isConnected = false;
  bool isReady = false; // To track whether the 2-second delay is over

  @override
  void initState() {
    super.initState();

    // Initialize WebView controller
    controller = WebViewController()
      ..loadRequest(
        Uri.parse('https://devs.pearl-developer.com/achraj/'),
      );

    // Introduce a 2-second delay before checking the network connection
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        isReady = true; // Mark the app as ready to display content after 2 seconds
      });
    });

    _startListening();
  }

  @override
  void dispose() {
    listener.cancel(); // Cancel the subscription when disposing
    super.dispose();
  }

  void _startListening() {
    listener = InternetConnection().onStatusChange.listen((InternetStatus status) {
      setState(() {
        isConnected = status == InternetStatus.connected;
      });
    });

    // Check initial connectivity status
    InternetConnection().hasInternetAccess.then((connected) {
      setState(() {
        isConnected = connected;
      });
    });
  }

  void loadWebView() {
    controller.loadRequest(Uri.parse('https://devs.pearl-developer.com/achraj/'));
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      statusBarIconBrightness: Brightness.light,
    ));

    // Check if the app is ready and has finished the 2-second delay
    if (!isReady) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: isConnected
            ? RefreshIndicator(
          onRefresh: () async {
            // Reload the WebView on refresh
            loadWebView();
          },
          child: WebViewStack(controller: controller),
        )
            : const NoInternetPage(
          onRetry: null, // You can pass a retry function here
        ),
      ),
    );
  }
}