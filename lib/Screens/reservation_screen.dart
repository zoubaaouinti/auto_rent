import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/car_model.dart';

class ReservationScreen extends StatefulWidget {
  final Vehicule vehicule;

  const ReservationScreen({Key? key, required this.vehicule}) : super(key: key);

  @override
  _ReservationScreenState createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  late DateTime _selectedStartDate;
  late DateTime _selectedEndDate;
  final List<DateTime> _selectedDates = [];
  final List<DateTime> _nonAvailableDates = []; // À remplir avec les dates non disponibles
  bool _withDriver = false;
  final _pickupLocationController = TextEditingController();
  final _returnLocationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedStartDate = DateTime.now();
    _selectedEndDate = DateTime.now().add(const Duration(days: 1));
  }

  @override
  void dispose() {
    _pickupLocationController.dispose();
    _returnLocationController.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      if (_selectedDates.contains(selectedDay)) {
        _selectedDates.remove(selectedDay);
      } else {
        _selectedDates.add(selectedDay);
      }

      if (_selectedDates.isNotEmpty) {
        _selectedDates.sort((a, b) => a.compareTo(b));
        _selectedStartDate = _selectedDates.first;
        _selectedEndDate = _selectedDates.last;
      }
    });
  }

  bool _isDayDisabled(DateTime day) {
    return _nonAvailableDates.any((date) => 
      date.year == day.year && 
      date.month == day.month && 
      date.day == day.day
    ) || day.isBefore(DateTime.now().subtract(const Duration(days: 1)));
  }

  int get _totalDays => _selectedStartDate.difference(_selectedEndDate).abs().inDays + 1;
  double get _totalPrice => _totalDays * widget.vehicule.prixJour;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Réserver un véhicule'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec informations du véhicule
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.vehicule.marque} ${widget.vehicule.modele}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.vehicule.prixJour} DH / jour',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            
            // Calendrier
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    TableCalendar(
                      firstDay: DateTime.now(),
                      lastDay: DateTime.now().add(const Duration(days: 365)),
                      focusedDay: _selectedStartDate,
                      calendarFormat: CalendarFormat.month,
                      selectedDayPredicate: (day) => _selectedDates.any((d) => 
                        d.year == day.year && 
                        d.month == day.month && 
                        d.day == day.day
                      ),
                      availableCalendarFormats: const {
                        CalendarFormat.month: 'Mois',
                      },
                      rangeStartDay: _selectedStartDate,
                      rangeEndDay: _selectedEndDate,
                      rangeSelectionMode: RangeSelectionMode.toggledOn,
                      onDaySelected: _onDaySelected,
                      enabledDayPredicate: (day) => !_isDayDisabled(day),
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        rangeStartDecoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        rangeEndDecoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        rangeHighlightColor: Colors.blue.withOpacity(0.2),
                        disabledTextStyle: const TextStyle(color: Colors.red),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Les dates en rouge sont déjà réservées',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Option chauffeur
            Card(
              child: SwitchListTile(
                title: const Text('Avec chauffeur'),
                value: _withDriver,
                onChanged: (value) {
                  setState(() {
                    _withDriver = value;
                  });
                },
              ),
            ),

            // Lieu de prise
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lieu de prise du véhicule',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    TextField(
                      controller: _pickupLocationController,
                      decoration: const InputDecoration(
                        hintText: 'Adresse de prise du véhicule',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Lieu de restitution (caché si avec chauffeur)
            if (!_withDriver) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Lieu de restitution',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      TextField(
                        controller: _returnLocationController,
                        decoration: const InputDecoration(
                          hintText: 'Adresse de restitution du véhicule',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Récapitulatif
            const SizedBox(height: 24),
            // Dans la méthode build, trouvez la section du récapitulatif et modifiez comme suit :
            Card(
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                children: [
                    _buildSummaryRow('Prix journalier', '${widget.vehicule.prixJour} DH'),
                    _buildSummaryRow('Nombre de jours', '$_totalDays jours'),
                    _buildSummaryRow('Total location', '${_totalPrice.toStringAsFixed(2)} DH'),
                    if (_withDriver)
                    _buildSummaryRow('Supplément chauffeur', '+ ${200 * _totalDays} DH'),
                    _buildSummaryRow('Caution', '${widget.vehicule.caution} DH'),
                    const Divider(),
                    _buildSummaryRow(
                    'Montant total',
                    '${_withDriver ? (_totalPrice + (200 * _totalDays) + widget.vehicule.caution) : (_totalPrice + widget.vehicule.caution)} DH',
                    isBold: true,
                    textColor: Colors.green,
                    ),
                    const SizedBox(height: 8),
                    Text(
                    'Une caution de ${widget.vehicule.caution} DH sera bloquée sur votre carte',
                    style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                    ),
                ],
                ),
            ),
            ),

            // Bouton de réservation
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _validateForm() ? _submitReservation : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Confirmer la réservation'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: textColor,
              fontSize: isBold ? 18 : null,
            ),
          ),
        ],
      ),
    );
  }

  bool _validateForm() {
    return _selectedDates.isNotEmpty && 
           _pickupLocationController.text.isNotEmpty &&
           (_withDriver || _returnLocationController.text.isNotEmpty);
  }

  void _submitReservation() {
    // Implémentez la logique de soumission ici
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réservation confirmée'),
        content: Text(
          'Votre réservation pour ${widget.vehicule.marque} ${widget.vehicule.modele} '
          'du ${DateFormat('dd/MM/yyyy').format(_selectedStartDate)} '
          'au ${DateFormat('dd/MM/yyyy').format(_selectedEndDate)} a été enregistrée.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(true); // Retour à l'écran précédent
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}