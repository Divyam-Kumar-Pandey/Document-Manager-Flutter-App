// custom_error_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

void setCustomErrorWidget() {
  ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
    bool inDebugMode = kDebugMode;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline_outlined,
                    color: Colors.red,
                    size: 100,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Oops... something went wrong',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  if (inDebugMode)
                    SingleChildScrollView(
                      child: Text(
                        errorDetails.toString(),
                        style: TextStyle(color: Colors.red),
                      ),
                    )
                  else
                    const Text(
                      'Please contact support.',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  };
}
