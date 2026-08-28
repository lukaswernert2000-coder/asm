import 'package:asm/core/theme/asm_theme.dart';
import 'package:asm/core/widgets/_gallery_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AsmApp extends StatelessWidget {
  const AsmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ASM',
      debugShowCheckedModeBanner: false,
      theme: AsmTheme.dark,
      darkTheme: AsmTheme.dark,
      themeMode: ThemeMode.dark,
      home: kDebugMode
          ? const GalleryScreen()
          : const Scaffold(body: Center(child: Text('ASM'))),
    );
  }
}
