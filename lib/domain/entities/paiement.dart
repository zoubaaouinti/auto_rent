enum StatutPaiement { en_attente, paye, echec }

class Paiement {
  final String id;
  final double montant;
  final DateTime date;
  final StatutPaiement statut;

  Paiement({
    required this.id,
    required this.montant,
    required this.date,
    required this.statut,
  });
}
