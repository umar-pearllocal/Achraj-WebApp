import 'dart:async';
import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'navigatorkey.dart';

 

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  late final StreamSubscription<ConnectivityResult> _subscription;

  @override
  void onInit() {
    super.onInit();
    _subscription = _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _updateConnectionStatus(result);
    });
  }

  @override
  void onClose() {
    _subscription.cancel();
    super.onClose();
  }

  void _updateConnectionStatus(ConnectivityResult connectivityResult) {
    // Get the current context from your NavigatorService
    BuildContext? context = NavigatorService.navigatorKey.currentContext;

    if (context != null) {
      if (connectivityResult == ConnectivityResult.none) {
        showNoInternetDialog(context);
      } else {
        if (Get.isSnackbarOpen) {
          Get.closeCurrentSnackbar();
        }
      }
    }
  }
}


void showNoInternetDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Stack(
        children: [
          // Blur effect in the background
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              color: Colors.black.withOpacity(0.5), // Optional color overlay
            ),
          ),
          // The AlertDialog itself
          Center(
            child: AlertDialog(
              backgroundColor: Colors.white.withOpacity(0.9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.wifi_off,
                    color: Colors.red[400],
                    size: 50,
                  ),
                  SizedBox(height: 16),
Text("noooo internrt"),
                  //pearlText(text: "No Internet Connection",fontSize: 20,fontWeight:FontWeight.bold,textAlign: TextAlign.center),
                  SizedBox(height: 10),
                  Text("please check yourt gehhws internrt"),

                  //pearlText(text: "Please check your internet settings.",textAlign: TextAlign.center),
                  SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child:Text("ok")
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    },
  );
}