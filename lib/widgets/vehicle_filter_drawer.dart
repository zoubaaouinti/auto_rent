// lib/widgets/vehicle_filter_drawer.dart
import 'package:flutter/material.dart';
import '../models/car_model.dart';

class VehicleFilterDrawer extends StatefulWidget {
  final List<Vehicule> allVehicles;
  final Function(FilterOptions) onFiltersChanged;
  final FilterOptions initialFilters;

  const VehicleFilterDrawer({
    Key? key,
    required this.allVehicles,
    required this.onFiltersChanged,
    required this.initialFilters,
  }) : super(key: key);

  @override
  _VehicleFilterDrawerState createState() => _VehicleFilterDrawerState();
}

class _VehicleFilterDrawerState extends State<VehicleFilterDrawer> {
  late FilterOptions _filters;

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
  }

  @override
  Widget build(BuildContext context) {
    final brands = widget.allVehicles.map((v) => v.marque).toSet().toList();
    final models = widget.allVehicles
        .where((v) => _filters.selectedBrand == null || 
                       v.marque == _filters.selectedBrand)
        .map((v) => v.modele)
        .toSet()
        .toList();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Filtres',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          // Filtre par marque
          ExpansionTile(
            title: const Text('Marque'),
            children: brands.map((brand) {
              return RadioListTile<String>(
                title: Text(brand),
                value: brand,
                groupValue: _filters.selectedBrand,
                onChanged: (value) {
                  setState(() {
                    _filters.selectedBrand = value;
                    _filters.selectedModel = null;
                    _applyFilters();
                  });
                },
              );
            }).toList(),
          ),
          
          // Filtre par modèle
          if (_filters.selectedBrand != null)
            ExpansionTile(
              title: const Text('Modèle'),
              children: models.map((model) {
                return RadioListTile<String>(
                  title: Text(model),
                  value: model,
                  groupValue: _filters.selectedModel,
                  onChanged: (value) {
                    setState(() {
                      _filters.selectedModel = value;
                      _applyFilters();
                    });
                  },
                );
              }).toList(),
            ),
          
          // Filtre par type de carrosserie
          ExpansionTile(
            title: const Text('Carrosserie'),
            children: TypeVehicule.values.map((type) {
              final isSelected = _filters.selectedTypes.contains(type);
              return ListTile(
                leading: Icon(
                  _getTypeIcon(type),
                  color: isSelected ? Colors.red : null,
                ),
                title: Text(_getTypeVehiculeName(type)),
                trailing: isSelected 
                    ? const Icon(Icons.check, color: Colors.red)
                    : null,
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _filters.selectedTypes.remove(type);
                    } else {
                      _filters.selectedTypes.add(type);
                    }
                    _applyFilters();
                  });
                },
              );
            }).toList(),
          ),
          
          // Filtre par transmission
          ExpansionTile(
            title: const Text('Transmission'),
            children: ['Manuelle', 'Automatique', 'Séquentielle'].map((transmission) {
              return RadioListTile<String>(
                title: Text(transmission),
                value: transmission,
                groupValue: _filters.transmission,
                onChanged: (value) {
                  setState(() {
                    _filters.transmission = value;
                    _applyFilters();
                  });
                },
              );
            }).toList(),
          ),
          
          // Filtre par énergie
          ExpansionTile(
            title: const Text('Énergie'),
            children: Carburant.values.map((carburant) {
              final isSelected = _filters.selectedEnergies.contains(carburant);
              return CheckboxListTile(
                title: Text(_getCarburantName(carburant)),
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _filters.selectedEnergies.add(carburant);
                    } else {
                      _filters.selectedEnergies.remove(carburant);
                    }
                    _applyFilters();
                  });
                },
              );
            }).toList(),
          ),
          
          // Filtre par prix
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Prix par jour',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                RangeSlider(
                  values: _filters.priceRange,
                  min: 0,
                  max: 1000,
                  divisions: 20,
                  labels: RangeLabels(
                    '${_filters.priceRange.start.toInt()} DH',
                    '${_filters.priceRange.end.toInt()} DH',
                  ),
                  onChanged: (RangeValues values) {
                    setState(() {
                      _filters.priceRange = values;
                    });
                  },
                  onChangeEnd: (_) => _applyFilters(),
                ),
              ],
            ),
          ),
          // Ajoutez cette section après le filtre de prix
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Filtrer par distance',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Switch(
                        value: _filters.filterByDistance,
                        onChanged: (value) {
                          setState(() {
                            _filters = _filters.copyWith(
                              filterByDistance: value,
                            );
                            widget.onFiltersChanged(_filters);
                          });
                        },
                        activeColor: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                  if (_filters.filterByDistance) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Rayon: ${_filters.maxDistance.toStringAsFixed(1)} km',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    Slider(
                      value: _filters.maxDistance,
                      min: 1.0,
                      max: 50.0,
                      divisions: 49,
                      label: '${_filters.maxDistance.toStringAsFixed(1)} km',
                      onChanged: (value) {
                        setState(() {
                          _filters = _filters.copyWith(maxDistance: value);
                        });
                      },
                      onChangeEnd: (_) {
                        widget.onFiltersChanged(_filters);
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Boutons de réinitialisation
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _filters = FilterOptions();
                        _applyFilters();
                      });
                    },
                    child: const Text('Réinitialiser'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Appliquer'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _applyFilters() {
    widget.onFiltersChanged(_filters);
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

  IconData _getTypeIcon(TypeVehicule type) {
    switch (type) {
      case TypeVehicule.berline:
        return Icons.directions_car;
      case TypeVehicule.suv:
        return Icons.airport_shuttle;
      case TypeVehicule.monospace:
        return Icons.airline_seat_recline_extra;
      case TypeVehicule.utilitaire:
        return Icons.local_shipping;
      case TypeVehicule.sport:
        return Icons.sports_motorsports;
      case TypeVehicule.cabriolet:
        return Icons.airline_seat_recline_normal;
    }
  }
}

class FilterOptions {
  String? selectedBrand;
  String? selectedModel;
  List<TypeVehicule> selectedTypes = [];
  String? transmission;
  List<Carburant> selectedEnergies = [];
  RangeValues priceRange = const RangeValues(0, 1000);
  bool filterByDistance = false;
  double maxDistance = 10.0; // en kilomètres

  bool get hasActiveFilters => 
      selectedBrand != null || 
      selectedModel != null || 
      selectedTypes.isNotEmpty || 
      transmission != null || 
      selectedEnergies.isNotEmpty ||
      filterByDistance;

  FilterOptions copyWith({
    String? selectedBrand,
    String? selectedModel,
    List<TypeVehicule>? selectedTypes,
    String? transmission,
    List<Carburant>? selectedEnergies,
    RangeValues? priceRange,
    bool? filterByDistance,
    double? maxDistance,
  }) {
    return FilterOptions()
      ..selectedBrand = selectedBrand ?? this.selectedBrand
      ..selectedModel = selectedModel ?? this.selectedModel
      ..selectedTypes = selectedTypes ?? List.from(this.selectedTypes)
      ..transmission = transmission ?? this.transmission
      ..selectedEnergies = selectedEnergies ?? List.from(this.selectedEnergies)
      ..priceRange = priceRange ?? this.priceRange
      ..filterByDistance = filterByDistance ?? this.filterByDistance
      ..maxDistance = maxDistance ?? this.maxDistance;
  }
}