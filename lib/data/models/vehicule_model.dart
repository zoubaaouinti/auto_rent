import '../../domain/entities/vehicule.dart';

class VehiculeModel extends Vehicule {
  VehiculeModel({
    required super.id,
    required super.marque,
    required super.modele,
    required super.annee,
    required super.immatriculation,
    required super.type,
    required super.carburant,
    required super.places,
    required super.transmission,
    required super.photos,
    required super.prixJour,
    required super.caution,
    required super.optionsIncluses,
    required super.gpsTracker,
  });

  factory VehiculeModel.fromJson(Map<String, dynamic> json) {
    return VehiculeModel(
      id: json['id'] as String,
      marque: json['marque'] as String,
      modele: json['modele'] as String,
      annee: json['annee'] as int,
      immatriculation: json['immatriculation'] as String,
      type: TypeVehicule.values.firstWhere((e) => e.toString() == 'TypeVehicule.' + (json['type'] as String)),
      carburant: Carburant.values.firstWhere((e) => e.toString() == 'Carburant.' + (json['carburant'] as String)),
      places: json['places'] as int,
      transmission: json['transmission'] as String,
      photos: List<String>.from(json['photos'] as List),
      prixJour: (json['prixJour'] as num).toDouble(),
      caution: (json['caution'] as num).toDouble(),
      optionsIncluses: (json['optionsIncluses'] as List)
          .map((o) => Option(
                id: o['id'] as String? ?? '',
                nom: o['nom'] as String,
                description: o['description'] as String? ?? '',
                prixSupplement: (o['prixSupplement'] as num?)?.toDouble() ?? 0.0,
                inclus: o['inclus'] as bool? ?? false,
              ))
          .toList(),
      gpsTracker: GpsTracker.values.firstWhere((e) => e.toString() == 'GpsTracker.' + (json['gpsTracker'] as String)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'marque': marque,
      'modele': modele,
      'annee': annee,
      'immatriculation': immatriculation,
      'type': type.toString().split('.').last,
      'carburant': carburant.toString().split('.').last,
      'places': places,
      'transmission': transmission,
      'photos': photos,
      'prixJour': prixJour,
      'caution': caution,
      'optionsIncluses': optionsIncluses
          .map((o) => {
                'id': o.id,
                'nom': o.nom,
                'description': o.description,
                'prixSupplement': o.prixSupplement,
                'inclus': o.inclus,
              })
          .toList(),
      'gpsTracker': gpsTracker.toString().split('.').last,
    };
  }
}
