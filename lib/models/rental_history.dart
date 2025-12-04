class RentalHistory {
  final String id;
  final String carImage;
  final String carModel;
  final String carType;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final String status; // 'completed', 'upcoming', 'cancelled'

  RentalHistory({
    required this.id,
    required this.carImage,
    required this.carModel,
    required this.carType,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    this.status = 'completed',
  });

  // Méthode pour générer des données de démo
  static List<RentalHistory> getDummyData() {
    return [
      RentalHistory(
        id: '1',
        carImage: 'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=500&auto=format',
        carModel: 'Peugeot 208',
        carType: 'Berline',
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now().subtract(const Duration(days: 25)),
        totalPrice: 450.0,
        status: 'completed',
      ),
      RentalHistory(
        id: '2',
        carImage: 'https://images.unsplash.com/photo-1503376785-2ccf7f504264?w=500&auto=format',
        carModel: 'Mercedes Classe A',
        carType: 'Berline',
        startDate: DateTime.now().add(const Duration(days: 5)),
        endDate: DateTime.now().add(const Duration(days: 10)),
        totalPrice: 800.0,
        status: 'upcoming',
      ),
      RentalHistory(
        id: '3',
        carImage: 'https://images.unsplash.com/photo-1503376785-2ccf7f504264?w=500&auto=format',
        carModel: 'Renault Clio',
        carType: 'Citadine',
        startDate: DateTime.now().subtract(const Duration(days: 15)),
        endDate: DateTime.now().subtract(const Duration(days: 10)),
        totalPrice: 350.0,
        status: 'completed',
      ),
    ];
  }

  // Formatte la date au format JJ/MM/AAAA
  String getFormattedDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Formate la durée en jours
  int get durationInDays => endDate.difference(startDate).inDays;
}
