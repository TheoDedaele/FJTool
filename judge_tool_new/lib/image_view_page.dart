import 'package:flutter/material.dart';

class ImageViewPage extends StatelessWidget {
  final String imagePath;

  // Constructeur pour passer le chemin de l'image
  const ImageViewPage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Viewer'),
      ),
      body: Center(
        child: Hero(
          tag: imagePath, // Identifiant unique pour l'animation Hero
          child: Image.asset(imagePath, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
