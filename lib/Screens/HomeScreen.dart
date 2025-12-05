import 'package:flutter/material.dart';
import '../models/car_model.dart';
import 'VehiculeDetailScreen .dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Vehicule> _filteredVehicules = [];
  final List<Vehicule> _allVehicules = [
    Vehicule(
      id: '1',
      marque: 'Toyota',
      modele: 'Corolla',
      annee: 2022,
      immatriculation: 'AB-123-CD',
      type: TypeVehicule.berline,
      carburant: Carburant.essence,
      places: 5,
      transmission: 'Automatique',
      photos: [
        'assets/images/auto1.webp',
        'assets/images/auto2.webp',
      ],
      prixJour: 450.0,
      caution: 5000.0,
      optionsIncluses: [
        Option(
          id: '1',
          nom: 'GPS',
          description: 'Navigation GPS intégrée',
          inclus: true,
        ),
      ],
      gpsTracker: GpsTracker.oui,
    ),
    Vehicule(
      id: '2',
      marque: 'Renault',
      modele: 'Clio',
      annee: 2021,
      immatriculation: 'EF-456-GH',
      type: TypeVehicule.berline,
      carburant: Carburant.diesel,
      places: 5,
      transmission: 'Manuelle',
      photos: [
        'assets/images/auto2.webp',
        'assets/images/auto3.webp',
      ],
      prixJour: 300.0,
      caution: 4000.0,
      optionsIncluses: [
        Option(
          id: '2',
          nom: 'Climatisation',
          description: 'Climatisation automatique',
          inclus: true,
        ),
      ],
      gpsTracker: GpsTracker.oui,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _filteredVehicules = _allVehicules;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredVehicules = _allVehicules.where((vehicule) {
        final vehiculeName = '${vehicule.marque} ${vehicule.modele}'.toLowerCase();
        return vehiculeName.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Louer une voiture'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher une voiture...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 20,
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredVehicules.isEmpty
                ? const Center(
                    child: Text('Aucune voiture trouvée'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredVehicules.length,
                    itemBuilder: (context, index) {
                      return _buildVehiculeCard(_filteredVehicules[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehiculeCard(Vehicule vehicule) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: InkWell(
        
          // Remplacez le onTap existant par :
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VehiculeDetailScreen(vehicule: vehicule),
              ),
            );
          },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: vehicule.photos.isNotEmpty
                  ? Image.asset(
                      vehicule.photos[0],
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 180,
                        color: Colors.grey[300],
                        child: const Icon(Icons.car_rental, size: 50),
                      ),
                    )
                  : Container(
                      height: 180,
                      color: Colors.grey[300],
                      child: const Icon(Icons.car_rental, size: 50),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${vehicule.marque} ${vehicule.modele}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          vehicule.type.toString().split('.').last,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildVehiculeFeature(
                        Icons.people,
                        '${vehicule.places} places',
                      ),
                      const SizedBox(width: 16),
                      _buildVehiculeFeature(
                        Icons.settings,
                        vehicule.transmission,
                      ),
                      const SizedBox(width: 16),
                      _buildVehiculeFeature(
                        Icons.local_gas_station,
                        vehicule.carburant.toString().split('.').last,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildVehiculeFeature(
                        Icons.gps_fixed,
                        'GPS: ${vehicule.gpsTracker.toString().split('.').last}',
                      ),
                      const SizedBox(width: 16),
                      _buildVehiculeFeature(
                        Icons.shield,
                        'Caution: ${vehicule.caution.toInt()} DH',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Prix par jour',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${vehicule.prixJour.toInt()} DH',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Action de réservation
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Réserver',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehiculeFeature(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}