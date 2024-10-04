import 'dart:async';
import 'package:achraj/src/no_internet_page.dart';
import 'package:achraj/src/web_view_stack.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:splashify/splashify.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: Splashify(
        imagePath: 'assets/image.png',
        navigateDuration: 4,
        imageSize: 400,
        child: const WebViewApp(),
      ),
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
  late final WebViewController controller;
  bool isConnected = false;
  bool canNavigateBack = false;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(
        Uri.parse('https://devs.pearl-developer.com/achraj/'),
      );
    _startListening();
    _checkNavigationState();
  }

  @override
  void dispose() {
    listener.cancel();
    super.dispose();
  }

  void _startListening() {
    listener = InternetConnection().onStatusChange.listen((InternetStatus status) {
      bool previousConnectionStatus = isConnected;
      setState(() {
        isConnected = status == InternetStatus.connected;
      });

      if (!previousConnectionStatus && isConnected) {
        loadWebView();
      }
    });
  }

  void loadWebView() {
    controller.loadRequest(Uri.parse('https://devs.pearl-developer.com/achraj/'));
  }

  void _checkNavigationState() async {
    canNavigateBack = await controller.canGoBack();
    setState(() {});
  }

  Future<bool> _onWillPop() async {
    if (await controller.canGoBack()) {
      controller.goBack();
      return false;
    } else {
      return true; // Allows the app to close if no navigation history
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      statusBarIconBrightness: Brightness.light,
    ));

    return WillPopScope(
      onWillPop: _onWillPop, // Handle back button press
      child: Scaffold(
        body: SafeArea(
          child: isConnected
              ? RefreshIndicator(
            onRefresh: () async {
              loadWebView();
            },
            child: WebViewStack(controller: controller),
          )
              : NoInternetPage(
            onRetry: () {
              _startListening();
              loadWebView();
            },
          ),
        ),
      ),
    );
  }
}
