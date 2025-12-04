import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'RentalDetailScreen.dart';

// Modèle intégré pour les locations
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

class RentalHistoryScreen extends StatelessWidget {
  RentalHistoryScreen({Key? key}) : super(key: key);

  final List<RentalHistory> rentals = RentalHistory.getDummyData();

  void _navigateToDetail(BuildContext context, RentalHistory rental) {
    final details = RentalDetails(
      marque: rental.carModel.split(' ')[0],
      modele: rental.carModel.split(' ').sublist(1).join(' '),
      annee: '2023',
      immatriculation: 'AB-123-CD',
      places: 5,
      transmission: 'Automatique',
      carburant: 'Diesel',
      prixTotal: rental.totalPrice,
      dateDebut: rental.startDate,
      dateFin: rental.endDate,
      duree: rental.durationInDays,
      lieuPrise: 'Aéroport de Paris-Charles de Gaulle',
      lieuRestitution: 'Aéroport de Paris-Charles de Gaulle',
      nomChauffeur: 'Jean Dupont',
      caution: 500.0,
      optionsIncluses: ['GPS', 'Bluetooth', 'Climatisation', 'Sièges chauffants'],
      images: [
        rental.carImage,
        'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=500&auto=format',
        'https://images.unsplash.com/photo-1494905998402-395d579af36f?w=500&auto=format',
      ],
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RentalDetailScreen(rentalDetails: details),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des locations'),
        centerTitle: true,
        elevation: 0,
      ),
      body: rentals.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: rentals.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _navigateToDetail(context, rentals[index]),
                  child: _buildRentalCard(rentals[index]),
                );
              },
            ),
    );
  }

  Widget _buildRentalCard(RentalHistory rental) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image de la voiture
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              rental.carImage,
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 150,
                color: Colors.grey[200],
                child: const Icon(Icons.car_rental, size: 50, color: Colors.grey),
              ),
            ),
          ),
          
          // Détails de la location
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modèle et type de voiture
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      rental.carModel,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(rental.status).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStatusText(rental.status),
                        style: TextStyle(
                          color: _getStatusColor(rental.status),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  rental.carType,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Dates de location
                _buildInfoRow(
                  Icons.calendar_today,
                  '${rental.getFormattedDate(rental.startDate)} - ${rental.getFormattedDate(rental.endDate)}',
                ),
                const SizedBox(height: 8),
                
                // Durée
                _buildInfoRow(
                  Icons.access_time,
                  '${rental.durationInDays} jours de location',
                ),
                
                const SizedBox(height: 16),
                
                // Prix total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Prix total',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${rental.totalPrice.toStringAsFixed(2)} €',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_toggle_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune location trouvée',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vos locations apparaîtront ici',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'upcoming':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'Terminée';
      case 'upcoming':
        return 'À venir';
      case 'cancelled':
        return 'Annulée';
      default:
        return status;
    }
  }
}
