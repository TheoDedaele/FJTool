import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ImageSearchPage extends StatefulWidget {
  final String?
      extension; // Extension spécifique (ou null pour toutes les cartes)

  const ImageSearchPage({this.extension});

  @override
  _ImageSearchPageState createState() => _ImageSearchPageState();
}

class _ImageSearchPageState extends State<ImageSearchPage> {
  TextEditingController _searchController = TextEditingController();
  List<String> allImages = [];
  List<String> filteredImages = [];

  @override
  void initState() {
    super.initState();
    _loadImages(); // Charger les images automatiquement
  }

  Future<void> _loadImages() async {
    // Lire le fichier AssetManifest.json pour récupérer toutes les images
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    // Filtrer les fichiers en fonction du dossier ou récupérer toutes les cartes
    final images = manifestMap.keys.where((key) {
      if (widget.extension != null) {
        return key.startsWith('assets/Cartes/${widget.extension}/');
      }
      return key.startsWith('assets/Cartes/');
    }).toList();

    setState(() {
      allImages = images; // Charger toutes les images disponibles
      filteredImages = images; // Afficher toutes les images au départ
    });
  }

  void _filterImages(String query) {
    setState(() {
      filteredImages = allImages
          .where((image) => image
              .toLowerCase()
              .contains(query.toLowerCase())) // Recherche partielle
          .toList();
    });
  }

  Future<void> _openLimitlessPage(String imagePath) async {
    // Extraire les informations depuis le nom de l'image
    final RegExp regex = RegExp(r'assets/Cartes/.+/([A-Z]+)0*(\d+).+\.jpg',
        caseSensitive: false);
    final match = regex.firstMatch(imagePath);

    if (match != null) {
      final extensionCode =
          match.group(1)!.toUpperCase(); // Code d'extension (ex : SVP, LOR)
      final cardNumber =
          match.group(2); // Numéro de la carte (sans les zéros inutiles)

      final url = 'https://limitlesstcg.com/cards/$extensionCode/$cardNumber';
      print('Generated URL: $url');

      final Uri uri = Uri.parse(url);

      // Vérifie et ouvre l'URL
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        print('Impossible d\'ouvrir $url');
        throw 'Impossible d\'ouvrir $url';
      }
    } else {
      print('Nom de fichier non valide : $imagePath');
    }
  }

  void _showImageSlider(BuildContext context, int initialIndex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.7, // Ajuste la hauteur du slider
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: PageController(initialPage: initialIndex),
                  itemCount: filteredImages.length,
                  itemBuilder: (context, index) {
                    return Center(
                      child: Column(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.0, // Marges latérales
                                vertical:
                                    8.0, // Marges en haut et en bas pour ne pas couper
                              ),
                              child: Image.asset(
                                filteredImages[index],
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          SizedBox(
                              height:
                                  8), // Petit espace entre l'image et le bouton
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: ElevatedButton(
                              onPressed: () {
                                _openLimitlessPage(filteredImages[index]);
                              },
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 12.0),
                                minimumSize: Size(double.infinity,
                                    50), // Bouton pleine largeur
                              ),
                              child: Text('Limitless'),
                            ),
                          ),
                          SizedBox(height: 8), // Petit espace sous le bouton
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.extension ?? 'All Cards'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search images...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) => _filterImages(value), // Recherche dynamique
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Nombre de colonnes
                childAspectRatio: 3 / 2, // Ratio largeur/hauteur des images
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: filteredImages.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    _showImageSlider(context, index);
                  },
                  child: Card(
                    elevation: 2.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.asset(
                        filteredImages[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
