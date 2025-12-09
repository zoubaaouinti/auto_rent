enum TypeVehicule {
  berline,
  suv,
  monospace,
  utilitaire,
  sport,
  cabriolet,
}

enum Carburant {
  essence,
  diesel,
  electrique,
  hybride,
  gpl,
}

enum GpsTracker {
  oui,
  non,
}

class Option {
  final String id;
  final String nom;
  final String description;
  final double prixSupplement;
  final bool inclus;

  Option({
    required this.id,
    required this.nom,
    required this.description,
    this.prixSupplement = 0.0,
    this.inclus = false,
  });
}

class Vehicule {
  final String id;
  final String marque;
  final String modele;
  final int annee;
  final String immatriculation;
  final TypeVehicule type;
  final Carburant carburant;
  final int places;
  final String transmission;
  final List<String> photos;
  final double prixJour;
  final double caution;
  final List<Option> optionsIncluses;
  final GpsTracker gpsTracker;

  Vehicule({
    required this.id,
    required this.marque,
    required this.modele,
    required this.annee,
    required this.immatriculation,
    required this.type,
    required this.carburant,
    required this.places,
    required this.transmission,
    required this.photos,
    required this.prixJour,
    required this.caution,
    required this.optionsIncluses,
    required this.gpsTracker,
  });
}
