// lib/main.dart

import 'package:flutter/widgets.dart';

main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(context) => Center(
    child: Text('Hello Flutter!', textDirection: TextDirection.ltr)
  );
}
