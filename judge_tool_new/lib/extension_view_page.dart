import 'package:flutter/material.dart';
import 'image_search_page.dart';

class ExtensionViewPage extends StatelessWidget {
  final List<String> extensions = [
    'PAL',
    'SVI',
    'SVpromo'
  ]; // Extensions disponibles

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Extensions'),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Nombre de colonnes
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: extensions.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // Naviguer vers la page des cartes d'une extension
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ImageSearchPage(extension: extensions[index]),
                ),
              );
            },
            child: Card(
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                child: Text(
                  extensions[index],
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
