import '../../domain/entities/vehicule.dart';

abstract class VehiculeDataSource {
  Future<List<Vehicule>> getVehicules();
  Future<Vehicule> getVehiculeById(String id);
}
