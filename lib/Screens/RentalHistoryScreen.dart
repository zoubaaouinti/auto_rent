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
  final bool withDriver;
  int? carRating;
  int? driverRating;
  String? reviewComment;

  RentalHistory({
    required this.id,
    required this.carImage,
    required this.carModel,
    required this.carType,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    this.status = 'completed',
    this.withDriver = false,
    this.carRating,
    this.driverRating,
    this.reviewComment,
    
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
        withDriver: true,
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
        withDriver: true,
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

class RentalHistoryScreen extends StatefulWidget {
  const RentalHistoryScreen({Key? key}) : super(key: key);

  @override
  _RentalHistoryScreenState createState() => _RentalHistoryScreenState();
}

class _RentalHistoryScreenState extends State<RentalHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<RentalHistory> _rentals = RentalHistory.getDummyData();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showRatingDialog(RentalHistory rental) {
    showDialog(
      context: context,
      builder: (context) => _RatingDialog(
        rental: rental,
        onRatingSubmitted: (updatedRental) {
          setState(() {
            final index = _rentals.indexWhere((r) => r.id == updatedRental.id);
            if (index != -1) {
              _rentals[index] = updatedRental;
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Locations'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'À venir'),
            Tab(text: 'Terminées'),
            Tab(text: 'Annulées'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRentalList(_rentals.where((r) => r.status == 'upcoming').toList()),
          _buildRentalList(_rentals.where((r) => r.status == 'completed').toList()),
          _buildRentalList(_rentals.where((r) => r.status == 'cancelled').toList()),
        ],
      ),
    );
  }

  Widget _buildRentalList(List<RentalHistory> rentals) {
    if (rentals.isEmpty) {
      return const Center(
        child: Text('Aucune location trouvée'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rentals.length,
      itemBuilder: (context, index) {
        final rental = rentals[index];
        return _buildRentalCard(rental);
      },
    );
  }

  Widget _buildRentalCard(RentalHistory rental) {
  return Card(
    margin: const EdgeInsets.only(bottom: 16),
    child: InkWell(
      onTap: () {
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
        ).then((_) {
          setState(() {});
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec image et statut
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
                child: rental.carImage.startsWith('http')
                    ? Image.network(
                        rental.carImage,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
                      )
                    : Image.asset(
                        rental.carImage,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
                      ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(rental.status).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(rental.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Détails de la location
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${rental.carModel} • ${rental.carType}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  Icons.calendar_today,
                  '${DateFormat('dd/MM/yyyy').format(rental.startDate)} - ${DateFormat('dd/MM/yyyy').format(rental.endDate)}',
                ),
                const SizedBox(height: 4),
                _buildDetailRow(
                  Icons.attach_money,
                  'Total: ${rental.totalPrice.toStringAsFixed(2)} DH',
                ),
                if (rental.carRating != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ...List.generate(
                        5,
                        (index) => Icon(
                          index < rental.carRating! ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 20,
                        ),
                      ),
                      if (rental.reviewComment?.isNotEmpty ?? false) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '"${rental.reviewComment!}"',
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 12,
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ],
                  ),
                ] else if (rental.status == 'completed') ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _showRatingDialog(rental),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        backgroundColor: Colors.blue.shade50,
                        foregroundColor: Theme.of(context).primaryColor,
                      ),
                      child: const Text('Évaluer cette location'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// Ajoutez cette méthode utilitaire pour l'image de remplacement
Widget _buildPlaceholderImage() {
  return Container(
    height: 120,
    color: Colors.grey[200],
    child: const Center(
      child: Icon(Icons.car_rental, size: 50, color: Colors.grey),
    ),
  );
}

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
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

class _RatingDialog extends StatefulWidget {
  final RentalHistory rental;
  final Function(RentalHistory) onRatingSubmitted;

  const _RatingDialog({
    required this.rental,
    required this.onRatingSubmitted,
  });

  @override
  _RatingDialogState createState() => _RatingDialogState();
}

class _RatingDialogState extends State<_RatingDialog> {
  late int _carRating;
  late int _driverRating;
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carRating = widget.rental.carRating ?? 0;
    _driverRating = widget.rental.driverRating ?? 0;
    _commentController.text = widget.rental.reviewComment ?? '';
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Évaluer votre location'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notez le véhicule:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _carRating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 30,
                  ),
                  onPressed: () {
                    setState(() {
                      _carRating = index + 1;
                    });
                  },
                );
              }),
            ),
            if (widget.rental.withDriver) ...[
              const SizedBox(height: 16),
              const Text(
                'Notez le chauffeur:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _driverRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 30,
                    ),
                    onPressed: () {
                      setState(() {
                        _driverRating = index + 1;
                      });
                    },
                  );
                }),
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Commentaire (optionnel)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _carRating > 0
              ? () {
                  final updatedRental = widget.rental
                    ..carRating = _carRating
                    ..driverRating = widget.rental.withDriver ? _driverRating : null
                    ..reviewComment = _commentController.text;
                  widget.onRatingSubmitted(updatedRental);
                  Navigator.pop(context);
                }
              : null,
          child: const Text('Soumettre'),
        ),
      ],
    );
  }
}
