
import 'package:flutter/material.dart';

//clase para crear un loader de carga cuando seleccionamos un producto
class FullScreenLoader extends StatelessWidget {
  const FullScreenLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand(
      child: Center(
        child: CircularProgressIndicator( strokeWidth: 2,), 
      ),
    );
  }
}