// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:local_auth/local_auth.dart';
// import 'pages/home.dart';
// import 'error.dart';
//
//
// var box;
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Hive.initFlutter();
//   box ??= await Hive.openBox('documents');
//
//   setCustomErrorWidget();
//
//   final LocalAuthentication auth = LocalAuthentication();
//
//   bool didAuthenticate = false;
//   try {
//     didAuthenticate = await auth.authenticate(
//         localizedReason: 'Please authenticate to enter the App.');
//   } on PlatformException {
//     log('Platform Error');
//   }
//
//   if (!didAuthenticate) {
//     SystemNavigator.pop(); // Close the app if authentication fails
//   } else {
//     runApp(const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: HomePage(),
//     ));
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

void main() {
  runApp(MaterialApp(
    home: const Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: _callNumber,
          child: Text('Call Number'),
        ),
      ),

  )));
}

_callNumber() async{
  const number = '8518080693'; //set the number here
  bool? res = await FlutterPhoneDirectCaller.callNumber(number);

}
