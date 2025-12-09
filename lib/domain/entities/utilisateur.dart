class Utilisateur {
  final String id;
  final String nom;
  final String email;
  final String? telephone;

  Utilisateur({
    required this.id,
    required this.nom,
    required this.email,
    this.telephone,
  });
}
