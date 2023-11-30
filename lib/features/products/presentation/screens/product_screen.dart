

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teslo_shop/features/products/presentation/providers/product_provider.dart';


class ProductScreen extends ConsumerWidget {

  //propiedades
  final String productId;

  const ProductScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    final ProductState = ref.watch( productProvider(productId));
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Producto'),
        actions: [
          IconButton(onPressed: () {

          },
           icon: const Icon( Icons.camera_alt_outlined))
        ],    
      ),  

      body: Center(  child: Text( ProductState.product?.title ?? 'cargando')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon( Icons.save_as_outlined),
      )
    );
  }
}