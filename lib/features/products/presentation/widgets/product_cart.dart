
import 'package:flutter/material.dart';

import '../../domain/domain.dart';

class ProductCard extends StatelessWidget {

  //propiedades
  final Product product;

  //constructor
  const ProductCard({
    super.key,
    required this.product
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ImageViewew(images: product.images), //llamamos a la clase creada abajo para gestionar las imagenes
        Text( product.title, textAlign: TextAlign.center,),
        const SizedBox( height: 20)
      ],
    );
  }
}

class _ImageViewew extends StatelessWidget {
  
  //propiedades
  final List<String> images;
  
  //constructor
  const _ImageViewew({ required this.images });

  @override
  Widget build(BuildContext context) {

    //en caso de que no vengan imagenes mostramos una imagen por defecto
    if ( images.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset('assets/images/no-image.jpg', 
          fit: BoxFit.cover,
          height: 250,
        ), //cargamos la imagen de la carpeta assets del projecto
      );
    }
    
    //si tenemos imagenes las retornamos
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: FadeInImage(
        fit: BoxFit.cover,
        height: 250,
        fadeOutDuration: const Duration( milliseconds: 100),
        fadeInDuration: const Duration( milliseconds: 200),
        image: NetworkImage( images.first ), //cargamos la primera imagen 
        placeholder: const AssetImage('assets/loaders/bottle-loader.gif'), //mostramos la botella de carga de imagenes
      ),
    );
  }
}