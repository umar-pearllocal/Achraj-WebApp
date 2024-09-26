import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'src/no_internet_page.dart'; // Assuming your NoInternetPage is in this path
import 'src/web_view_stack.dart'; // Assuming WebViewStack is in this path

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
  late WebViewController controller;
  bool isConnected = true;
  late StreamSubscription<ConnectivityResult> subscription; // Subscription for listening to connectivity changes

  @override
  void initState() {
    super.initState();

    // Initialize the WebViewController
    controller = WebViewController()
      ..setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (error) {
            setState(() {
              isConnected = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse('https://devs.pearl-developer.com/achraj/'));

    // Start listening to connectivity changes
    subscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      _updateConnectionStatus(result);
    });
  }

  // Method to handle connectivity changes
  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    if (result == ConnectivityResult.none) {
      // No internet access, show NoInternetPage
      setState(() {
        isConnected = false;
      });
    } else {
      // Internet access is available, reload WebView if necessary
      setState(() {
        isConnected = true;
      });
      if (controller != null) {
        controller.reload(); // Reload the WebView on reconnection
      }
    }
  }

  @override
  void dispose() {
    subscription.cancel(); // Cancel the subscription when the widget is disposed
    super.dispose();
  }

  Future<void> _reloadWebView() async {
    if (isConnected) {
      controller.reload(); // Reloads the WebView on refresh
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isConnected
            ? Stack(
          children: [
            RefreshIndicator(
              onRefresh: _reloadWebView,
              child: WebViewStack(controller: controller),
            ),
          ],
        )
            : NoInternetPage(
          onRetry: _reloadWebView, // Retry on network error
        ),
      ),
    );
  }
}
