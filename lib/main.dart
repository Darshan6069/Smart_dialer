import 'package:flutter/material.dart';
import 'app.dart';
import 'injection_container.dart' as di;

void main() async {
  // Ensure Flutter engine bindings are initialized prior to loading native dependencies
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize standard GetIt repositories, datasources, usecases and boxes
  await di.init();

  runApp(const SmartDialerApp());
}
