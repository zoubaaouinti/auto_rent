import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';

class RentalDetails {
  final String marque;
  final String modele;
  final String annee;
  final String immatriculation;
  final int places;
  final String transmission;
  final String carburant;
  final double prixTotal;
  final DateTime dateDebut;
  final DateTime dateFin;
  final int duree;
  final String lieuPrise;
  final String lieuRestitution;
  final String nomChauffeur;
  final double caution;
  final List<String> optionsIncluses;
  final List<String> images;

  RentalDetails({
    required this.marque,
    required this.modele,
    required this.annee,
    required this.immatriculation,
    required this.places,
    required this.transmission,
    required this.carburant,
    required this.prixTotal,
    required this.dateDebut,
    required this.dateFin,
    required this.duree,
    required this.lieuPrise,
    required this.lieuRestitution,
    required this.nomChauffeur,
    required this.caution,
    required this.optionsIncluses,
    required this.images,
  });
}

class RentalDetailScreen extends StatefulWidget {
  final RentalDetails rentalDetails;

  const RentalDetailScreen({super.key, required this.rentalDetails});

  @override
  State<RentalDetailScreen> createState() => _RentalDetailScreenState();
}

class _RentalDetailScreenState extends State<RentalDetailScreen> {
  final List<String> carImages = [
    'assets/images/auto1.webp',
    'assets/images/auto2.webp',
    'assets/images/auto3.webp',
  ];
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final rentalDetails = widget.rentalDetails;
    final dateFormat = DateFormat('dd/MM/yyyy');
    final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: '€');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la location'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageCarousel(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${rentalDetails.marque} ${rentalDetails.modele} (${rentalDetails.annee})',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        currencyFormat.format(rentalDetails.prixTotal),
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Immatriculation: ${rentalDetails.immatriculation}',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  _buildSpecsRow(
                    icon1: Icons.airline_seat_recline_normal,
                    text1: '${rentalDetails.places} places',
                    icon2: Icons.settings,
                    text2: rentalDetails.transmission,
                    icon3: Icons.local_gas_station,
                    text3: rentalDetails.carburant,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoSection(
                    title: 'Période de location',
                    icon: Icons.calendar_today,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Du ${dateFormat.format(rentalDetails.dateDebut)}'),
                        Text('Au ${dateFormat.format(rentalDetails.dateFin)}'),
                        Text('(${rentalDetails.duree} jours)'),
                      ],
                    ),
                  ),
                  _buildInfoSection(
                    title: 'Lieu de prise en charge',
                    icon: Icons.location_on,
                    child: Text(rentalDetails.lieuPrise),
                  ),
                  _buildInfoSection(
                    title: 'Lieu de restitution',
                    icon: Icons.location_on,
                    child: Text(rentalDetails.lieuRestitution),
                  ),
                  _buildInfoSection(
                    title: 'Chauffeur',
                    icon: Icons.person,
                    child: Text(rentalDetails.nomChauffeur),
                  ),
                  _buildInfoSection(
                    title: 'Caution',
                    icon: Icons.security,
                    child: Text(currencyFormat.format(rentalDetails.caution)),
                  ),
                  _buildInfoSection(
                    title: 'Options incluses',
                    icon: Icons.check_circle_outline,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: rentalDetails.optionsIncluses
                          .map((option) => Chip(
                                label: Text(option),
                                backgroundColor: Colors.blue[50],
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCarousel() {
    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: carImages.length,
          options: CarouselOptions(
            height: 250.0,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            viewportFraction: 0.9,
            aspectRatio: 2.0,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          itemBuilder: (context, index, realIndex) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8.0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.asset(
                  carImages[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: carImages.asMap().entries.map((entry) {
            return Container(
              width: 8.0,
              height: 8.0,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentIndex == entry.key
                    ? Theme.of(context).primaryColor
                    : Colors.grey.withOpacity(0.4),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSpecsRow({
    required IconData icon1,
    required String text1,
    required IconData icon2,
    required String text2,
    required IconData icon3,
    required String text3,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildSpecItem(icon1, text1),
        _buildSpecItem(icon2, text2),
        _buildSpecItem(icon3, text3),
      ],
    );
  }

  Widget _buildSpecItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Colors.blue),
        const SizedBox(height: 4),
        Text(text, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildInfoSection({required String title, required IconData icon, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.blue),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Padding(padding: const EdgeInsets.only(left: 28.0), child: child),
          const Divider(height: 1),
        ],
      ),
    );
  }
}
