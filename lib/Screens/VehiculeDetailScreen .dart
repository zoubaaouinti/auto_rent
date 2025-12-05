// lib/Screens/VehiculeDetailScreen.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/car_model.dart';

class VehiculeDetailScreen extends StatefulWidget {
  final Vehicule vehicule;

  const VehiculeDetailScreen({super.key, required this.vehicule});

  @override
  _VehiculeDetailScreenState createState() => _VehiculeDetailScreenState();
}

class _VehiculeDetailScreenState extends State<VehiculeDetailScreen> {
  DateTime? _selectedDay;
  DateTime _focusedDay = DateTime.now();
  final Set<DateTime> _nonAvailableDates = {
    DateTime.now().add(const Duration(days: 2)),
    DateTime.now().add(const Duration(days: 3)),
    DateTime.now().add(const Duration(days: 7)),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.vehicule.marque} ${widget.vehicule.modele}'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carousel d'images
            SizedBox(
              height: 250,
              child: PageView.builder(
                itemCount: widget.vehicule.photos.length,
                itemBuilder: (context, index) {
                  return Image.asset(
                    widget.vehicule.photos[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.car_rental, size: 50),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre et prix
                  Text(
                    '${widget.vehicule.marque} ${widget.vehicule.modele} ${widget.vehicule.annee}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.vehicule.prixJour.toInt()} DH / jour',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(height: 32),
                  // Caractéristiques
                  const Text(
                    'Caractéristiques',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Grille d'icônes
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 4,
                    children: [
                      _buildFeatureItem(Icons.people, '${widget.vehicule.places} places'),
                      _buildFeatureItem(Icons.settings, widget.vehicule.transmission),
                      _buildFeatureItem(Icons.local_gas_station, 
                          widget.vehicule.carburant.toString().split('.').last),
                      _buildFeatureItem(Icons.confirmation_number, 
                          widget.vehicule.immatriculation),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Calendrier de disponibilité
                  const Text(
                    'Disponibilité',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TableCalendar(
                        firstDay: DateTime.now(),
                        lastDay: DateTime.now().add(const Duration(days: 365)),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) {
                          return isSameDay(_selectedDay, day);
                        },
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                        calendarStyle: CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          disabledDecoration: BoxDecoration(
                            color: Colors.red.shade100,
                            shape: BoxShape.circle,
                          ),
                          outsideDaysVisible: false,
                        ),
                        enabledDayPredicate: (day) {
                          // Désactive les jours passés et les jours non disponibles
                          return !_nonAvailableDates.contains(DateTime(
                                  day.year, day.month, day.day)) &&
                              !isSameDay(day, DateTime.now().subtract(const Duration(days: 1))) &&
                              !day.isBefore(DateTime.now().subtract(const Duration(days: 1)));
                        },
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Options incluses
                  const Text(
                    'Options incluses',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...widget.vehicule.optionsIncluses
                      .where((option) => option.inclus)
                      .map((option) => ListTile(
                            leading: const Icon(Icons.check_circle, color: Colors.green),
                            title: Text(option.nom),
                            subtitle: Text(option.description),
                          ))
                      .toList(),
                  const SizedBox(height: 24),
                  // Bouton de réservation
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedDay == null
                          ? null
                          : () {
                              // Action de réservation
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      child: Text(
                        _selectedDay == null
                            ? 'Sélectionnez une date'
                            : 'Réserver pour le ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
                        style: const TextStyle(fontSize: 16),
                      ),
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

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}