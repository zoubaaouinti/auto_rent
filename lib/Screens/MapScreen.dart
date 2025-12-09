import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../models/car_model.dart';
import '../widgets/vehicle_filter_drawer.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final List<Marker> _markers = [];
  bool _isLoading = true;
  LatLng? _currentPosition;
  int _currentCarouselIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late FilterOptions _filters;
  List<Vehicule> _allVehicles = [];
  List<Vehicule> _filteredVehicles = [];

  @override
  void initState() {
    super.initState();
    _filters = FilterOptions();
    _loadAvailableVehicles();
  }

  Future<void> _loadAvailableVehicles() async {
    _allVehicles = [
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
        photos: ['assets/images/auto1.webp', 'assets/images/auto2.webp'],
        prixJour: 450.0,
        caution: 5000.0,
        optionsIncluses: [
          Option(
            id: '1',
            nom: 'GPS',
            description: 'Navigation GPS intégrée',
            inclus: true,
          ),
          Option(
            id: '2',
            nom: 'Climatisation',
            description: 'Climatisation automatique',
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
        photos: ['assets/images/auto2.webp', 'assets/images/auto1.webp'],
        prixJour: 350.0,
        caution: 4000.0,
        optionsIncluses: [
          Option(
            id: '1',
            nom: 'Climatisation',
            description: 'Climatisation manuelle',
            inclus: true,
          ),
        ],
        gpsTracker: GpsTracker.non,
      ),
    ];
    
    _applyFilters();
  }

  void _applyFilters() {
    if (!mounted) return;
    
    setState(() {
      _filteredVehicles = _allVehicles.where((vehicle) {
        if (_filters.selectedBrand != null && 
            vehicle.marque != _filters.selectedBrand) {
          return false;
        }
        
        if (_filters.selectedModel != null && 
            vehicle.modele != _filters.selectedModel) {
          return false;
        }
        
        if (_filters.selectedTypes.isNotEmpty && 
            !_filters.selectedTypes.contains(vehicle.type)) {
          return false;
        }
        
        if (_filters.transmission != null && 
            vehicle.transmission != _filters.transmission) {
          return false;
        }
        
        if (_filters.selectedEnergies.isNotEmpty && 
            !_filters.selectedEnergies.contains(vehicle.carburant)) {
          return false;
        }
        
        if (vehicle.prixJour < _filters.priceRange.start || 
            vehicle.prixJour > _filters.priceRange.end) {
          return false;
        }
        
        return true;
      }).toList();
      _updateMarkers();
      _isLoading = false;
    });
  }

 void _updateMarkers() {
  _markers.clear();
  
  // Ajouter le marqueur de position actuelle
  if (_currentPosition != null) {
    _markers.add(
      Marker(
        width: 40.0,
        height: 40.0,
        point: _currentPosition!,
        child: Container(
          child: const Icon(
            Icons.location_on,
            color: Colors.blue,
            size: 40,
          ),
        ),
      ),
    );
  }

  // Ajouter les marqueurs des véhicules
  for (var vehicule in _filteredVehicles) {
    _markers.add(
      Marker(
        width: 40.0,
        height: 40.0,
        point: LatLng(
          33.5731 + (vehicule.id == '1' ? 0.01 : 0), 
          -7.5898 + (vehicule.id == '1' ? 0.01 : 0)
        ),
        child: GestureDetector(
          onTap: () => _showVehicleDetails(vehicule),
          child: const Icon(
            Icons.directions_car,
            color: Colors.red,
            size: 40,
          ),
        ),
      ),
    );
  }
}

  void _showVehicleDetails(Vehicule vehicule) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildVehicleInfo(vehicule, ctx),
    );
  }

  Widget _buildVehicleInfo(Vehicule vehicule, BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (_, controller) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SingleChildScrollView(
            controller: controller,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                
                SizedBox(
                  height: 220,
                  child: Stack(
                    children: [
                      CarouselSlider.builder(
                        itemCount: vehicule.photos.length,
                        itemBuilder: (context, index, realIndex) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                vehicule.photos[index],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: Icon(Icons.image_not_supported),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                        options: CarouselOptions(
                          height: 220,
                          autoPlay: true,
                          aspectRatio: 16/9,
                          viewportFraction: 1.0,
                          enlargeCenterPage: true,
                          autoPlayAnimationDuration: const Duration(milliseconds: 800),
                          onPageChanged: (index, reason) {
                            setState(() {
                              _currentCarouselIndex = index;
                            });
                          },
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            vehicule.photos.length,
                            (index) => Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentCarouselIndex == index
                                    ? Colors.blue
                                    : Colors.grey[300],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
                              '${vehicule.marque} ${vehicule.modele} (${vehicule.annee})',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Disponible',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      Text(
                        '${vehicule.prixJour} DH/jour',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      const Text(
                        'Détails techniques',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow(Icons.confirmation_number, 'Immatriculation', vehicule.immatriculation),
                      _buildDetailRow(Icons.directions_car, 'Type', _getTypeVehiculeName(vehicule.type)),
                      _buildDetailRow(Icons.local_gas_station, 'Carburant', _getCarburantName(vehicule.carburant)),
                      _buildDetailRow(Icons.people, 'Places', '${vehicule.places} personnes'),
                      _buildDetailRow(Icons.settings, 'Transmission', vehicule.transmission),
                      _buildDetailRow(Icons.gps_fixed, 'GPS', vehicule.gpsTracker == GpsTracker.oui ? 'Oui' : 'Non'),
                      
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.security, color: Colors.orange[700]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Caution',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '${vehicule.caution} DH',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      if (vehicule.optionsIncluses.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Options incluses',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...vehicule.optionsIncluses.where((opt) => opt.inclus).map((option) => 
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                                const SizedBox(width: 8),
                                Text(option.nom),
                              ],
                            ),
                          ),
                        ).toList(),
                      ],
                      
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            // Navigation vers l'écran de réservation
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Réserver maintenant',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _getTypeVehiculeName(TypeVehicule type) {
    switch (type) {
      case TypeVehicule.berline:
        return 'Berline';
      case TypeVehicule.suv:
        return 'SUV';
      case TypeVehicule.monospace:
        return 'Monospace';
      case TypeVehicule.utilitaire:
        return 'Utilitaire';
      case TypeVehicule.sport:
        return 'Sport';
      case TypeVehicule.cabriolet:
        return 'Cabriolet';
    }
  }

  String _getCarburantName(Carburant carburant) {
    switch (carburant) {
      case Carburant.essence:
        return 'Essence';
      case Carburant.diesel:
        return 'Diesel';
      case Carburant.electrique:
        return 'Électrique';
      case Carburant.hybride:
        return 'Hybride';
      case Carburant.gpl:
        return 'GPL';
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _updateMarkers();
      });

      _mapController.move(
        _currentPosition!,
        15.0,
      );
    } catch (e) {
      debugPrint("Erreur de géolocalisation: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Carte'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadAvailableVehicles();
            },
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _getCurrentLocation,
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              if (_filters.hasActiveFilters)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      drawer: VehicleFilterDrawer(
        allVehicles: _allVehicles,
        initialFilters: _filters,
        onFiltersChanged: (newFilters) {
          setState(() {
            _filters = _filters.copyWith(
              selectedBrand: newFilters.selectedBrand,
              selectedModel: newFilters.selectedModel,
              selectedTypes: newFilters.selectedTypes,
              transmission: newFilters.transmission,
              selectedEnergies: newFilters.selectedEnergies,
              priceRange: newFilters.priceRange,
            );
            _applyFilters();
          });
        },
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: const LatLng(33.5731, -7.5898),
              zoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.auto_rent',
              ),
              MarkerLayer(markers: _markers),
            ],
          ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: _buildLegend(),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildLegendItem(
            color: Colors.blue,
            text: 'Véhicule disponible',
          ),
          _buildLegendItem(
            color: Colors.blue,
            text: 'Votre position',
            icon: Icons.location_pin,
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String text,
    IconData? icon,
  }) {
    return Row(
      children: [
        icon != null
            ? Icon(icon, color: color, size: 16)
            : Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}