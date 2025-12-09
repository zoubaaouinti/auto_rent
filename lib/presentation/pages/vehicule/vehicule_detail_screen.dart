import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../domain/entities/vehicule.dart';

class VehiculeDetailScreen extends StatefulWidget {
  final Vehicule vehicule;

  const VehiculeDetailScreen({super.key, required this.vehicule});

  @override
  _VehiculeDetailScreenState createState() => _VehiculeDetailScreenState();
}

class _VehiculeDetailScreenState extends State<VehiculeDetailScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final Set<DateTime> _nonAvailableDates = {
    DateTime.now().add(const Duration(days: 2)),
    DateTime.now().add(const Duration(days: 3)),
    DateTime.now().add(const Duration(days: 7)),
  };

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    if (widget.vehicule.photos.length <= 1) return;

    Future.delayed(const Duration(seconds: 3), () {
      if (_pageController.hasClients) {
        if (_currentPage < widget.vehicule.photos.length - 1) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        } else {
          _pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
        _startAutoPlay();
      }
    });
  }

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
            // Carousel with dots
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                SizedBox(
                  height: 250,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: widget.vehicule.photos.length,
                    itemBuilder: (context, index) {
                      return AnimatedBuilder(
                        animation: _pageController,
                        builder: (context, child) {
                          double value = 1.0;
                          if (_pageController.position.haveDimensions) {
                            value = _pageController.page! - index;
                            value = (1 - (value.abs() * 0.3)).clamp(0.8, 1.0);
                          }
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Transform.scale(
                                scale: value,
                                child: child,
                              ),
                            ),
                          );
                        },
                        child: Image.asset(
                          widget.vehicule.photos[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.car_rental, size: 50),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (widget.vehicule.photos.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List<Widget>.generate(
                        widget.vehicule.photos.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: _currentPage == index ? 12.0 : 8.0,
                          height: 8.0,
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: _currentPage == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.vehicule.marque} ${widget.vehicule.modele}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Année: ${widget.vehicule.annee} | ${widget.vehicule.immatriculation}',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Text(
                        '${widget.vehicule.prixJour.toInt()} DH / jour',
                        style: const TextStyle(fontSize: 20, color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text(
                        'Caution: ${widget.vehicule.caution.toInt()} DH',
                        style: const TextStyle(fontSize: 16, color: Colors.orange),
                      ),
                    ],
                  ),
                  const Divider(height: 32),

                  const Text('Caractéristiques principales', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    children: [
                      _buildFeatureItem(Icons.category, 'Type', _formatEnum(widget.vehicule.type.toString())),
                      _buildFeatureItem(Icons.local_gas_station, 'Carburant', _formatEnum(widget.vehicule.carburant.toString())),
                      _buildFeatureItem(Icons.people, 'Places', '${widget.vehicule.places}'),
                      _buildFeatureItem(Icons.settings, 'Transmission', widget.vehicule.transmission),
                      _buildFeatureItem(Icons.gps_fixed, 'GPS', _formatEnum(widget.vehicule.gpsTracker.toString())),
                    ],
                  ),

                  const SizedBox(height: 24),

                  if (widget.vehicule.optionsIncluses.isNotEmpty) ...[
                    const Text('Options incluses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ...widget.vehicule.optionsIncluses
                        .where((o) => o.inclus)
                        .map((o) => ListTile(
                              leading: const Icon(Icons.check_circle, color: Colors.green, size: 24),
                              title: Text(o.nom, style: const TextStyle(fontWeight: FontWeight.w500)),
                              subtitle: o.description.isNotEmpty ? Text(o.description) : null,
                              dense: true,
                              visualDensity: const VisualDensity(vertical: -3),
                            ))
                        .toList(),
                    const SizedBox(height: 16),
                  ],

                  const Divider(height: 32),

                  const Text('Disponibilité', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TableCalendar(
                        firstDay: DateTime.now(),
                        lastDay: DateTime.now().add(const Duration(days: 90)),
                        focusedDay: DateTime.now(),
                        calendarFormat: CalendarFormat.month,
                        availableCalendarFormats: const {CalendarFormat.month: 'Mois'},
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          titleTextStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          leftChevronIcon: const Icon(Icons.chevron_left, size: 24),
                          rightChevronIcon: const Icon(Icons.chevron_right, size: 24),
                        ),
                        calendarStyle: CalendarStyle(
                          todayDecoration: BoxDecoration(color: Colors.blue.shade100, shape: BoxShape.circle),
                          defaultTextStyle: const TextStyle(color: Colors.green),
                          weekendTextStyle: const TextStyle(color: Colors.red),
                          outsideDaysVisible: false,
                        ),
                        daysOfWeekStyle: const DaysOfWeekStyle(
                          weekdayStyle: TextStyle(fontWeight: FontWeight.bold),
                          weekendStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                        calendarBuilders: CalendarBuilders(
                          defaultBuilder: (context, day, _) {
                            bool isAvailable = !_nonAvailableDates.any((d) => d.year == day.year && d.month == day.month && d.day == day.day) &&
                                !day.isBefore(DateTime.now().subtract(const Duration(days: 1)));

                            return Center(
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: isAvailable ? Colors.green.shade50 : Colors.red.shade50,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: isAvailable ? Colors.green : Colors.red, width: 1.5),
                                ),
                                child: Center(
                                  child: Text(
                                    day.day.toString(),
                                    style: TextStyle(
                                      color: isAvailable ? Colors.green : Colors.red,
                                      fontWeight: isSameDay(day, DateTime.now()) ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        child: const Text('Réserver maintenant', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 2),
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  String _formatEnum(String enumValue) {
    return enumValue.split('.').last[0].toUpperCase() + enumValue.split('.').last.substring(1).toLowerCase();
  }
}
