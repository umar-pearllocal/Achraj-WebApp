import 'dart:async';
import 'package:achraj/src/no_internet_page.dart';
import 'package:achraj/src/web_view_stack.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const WebViewApp(),
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

  @override
  void initState() {
    super.initState();
    _startListening();
    controller = WebViewController()
      ..loadRequest(
        Uri.parse('https://devs.pearl-developer.com/achraj/'),
      );
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

        if (isConnected) {
          // Load the web view if connected
          loadWebView();
        }
      });
    });
  }

  void loadWebView() {
    controller.loadRequest(Uri.parse('https://devs.pearl-developer.com/achraj/'));
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black, // Use your desired color here
      statusBarIconBrightness: Brightness.light, // Use Brightness.dark if your status bar icons are light-colored
    ));
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