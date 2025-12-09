import '../entities/vehicule.dart';

abstract class VehiculeRepository {
  Future<List<Vehicule>> getVehicules();
  Future<Vehicule> getVehiculeById(String id);
  Future<List<Vehicule>> searchVehicules(String query);
}
