import 'package:flutter/material.dart';
import 'package:algolia/algolia.dart';

class AlgoliaSearchWidget extends StatefulWidget {
  const AlgoliaSearchWidget({super.key});

  @override
  _AlgoliaSearchWidgetState createState() => _AlgoliaSearchWidgetState();
}

class _AlgoliaSearchWidgetState extends State<AlgoliaSearchWidget> {
  // Configuration Algolia
  final Algolia _algolia = Algolia.init(
    applicationId: 'AJTKLR4J89',
    apiKey: 'ae4df4d943cf7713dbada08bbf08db41',
  );

  // Variables pour dropdowns
  String? selectedDepartment;
  String? selectedCity;

  // Liste des résultats
  List<Map<String, dynamic>> searchResults = [];
  String errorMessage = '';

  // Fonction de recherche
  Future<void> executeSearch() async {
    debugPrint("Début de la fonction executeSearch");

    // Vérification des entrées utilisateur
    if (selectedDepartment == null || selectedCity == null) {
      setState(() {
        errorMessage = "Veuillez sélectionner un département et une ville.";
      });
      debugPrint("Erreur : Département ou ville non sélectionnés");
      return;
    }

    debugPrint("Département sélectionné : $selectedDepartment");
    debugPrint("Ville sélectionnée : $selectedCity");

    try {
      // Construire une requête avec filtre département et ville
      final String filters = 'department:"$selectedDepartment" AND city:"$selectedCity"';
      debugPrint("Filtres construits : $filters");

      final AlgoliaQuery query = _algolia.instance.index('users').query('')
        ..filters(filters);

      debugPrint("Requête Algolia créée avec succès.");

      // Exécuter la recherche
      final AlgoliaQuerySnapshot snapshot = await query.getObjects();
      debugPrint("Requête envoyée à Algolia. Résultats trouvés : ${snapshot.nbHits}");

      if (snapshot.nbHits == 0) {
        setState(() {
          searchResults = [];
          errorMessage = "Aucun résultat trouvé pour votre recherche.";
        });
        debugPrint("Aucun résultat trouvé.");
      } else {
        setState(() {
          searchResults = snapshot.hits.map((hit) => hit.data).toList();
          errorMessage = ''; // Réinitialiser le message d'erreur
        });
        debugPrint("Résultats traités avec succès : ${searchResults.length} résultats.");
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur lors de la recherche : $e';
      });
      debugPrint("Exception attrapée : $e");
    }

    debugPrint("Fin de la fonction executeSearch");
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Construction du widget de recherche.");

    return Scaffold(
      appBar: AppBar(
        title: const Text("Recherche Algolia"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dropdown pour sélectionner le département
            DropdownButton<String>(
              value: selectedDepartment,
              hint: const Text("Sélectionnez un département"),
              items: <String>['Ile-de-France', 'Provence-Alpes-Côte d\'Azur']
                  .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedDepartment = newValue!;
                  debugPrint("Département changé : $selectedDepartment");
                });
              },
            ),

            const SizedBox(height: 16),

            // Dropdown pour sélectionner la ville
            DropdownButton<String>(
              value: selectedCity,
              hint: const Text("Sélectionnez une ville"),
              items: <String>['Paris', 'Nice'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedCity = newValue!;
                  debugPrint("Ville changée : $selectedCity");
                });
              },
            ),

            const SizedBox(height: 16),

            // Bouton de recherche
            ElevatedButton(
              onPressed: executeSearch,
              child: const Text("Rechercher"),
            ),

            const SizedBox(height: 16),

            // Affichage du message d'erreur (s'il existe)
            if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: const TextStyle(color: Colors.red),
              ),

            const SizedBox(height: 16),

            // Affichage des résultats
            Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final result = searchResults[index];
                  debugPrint("Affichage du résultat $index : $result");
                  return Card(
                    child: ListTile(
                      title: Text(result['name'] ?? 'Nom non disponible'),
                      subtitle: Text(
                        '${result['department']}, ${result['city']}',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
