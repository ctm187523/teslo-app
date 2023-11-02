
import 'package:flutter/material.dart';

//clase que muestra la pantalla de inicio con un circular progress
class CheckAuthStatusScree extends StatelessWidget {
  const CheckAuthStatusScree({super.key});

  @override
  Widget build(BuildContext context) {

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      )
    );
  }
}