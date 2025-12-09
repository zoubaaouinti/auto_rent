import '../../domain/entities/vehicule.dart';
import '../../domain/repositories/vehicule_repository.dart';
import '../datasources/vehicule_data_source.dart';

class VehiculeRepositoryImpl implements VehiculeRepository {
  final VehiculeDataSource dataSource;

  VehiculeRepositoryImpl({required this.dataSource});

  @override
  Future<List<Vehicule>> getVehicules() async {
    return await dataSource.getVehicules();
  }

  @override
  Future<Vehicule> getVehiculeById(String id) async {
    return await dataSource.getVehiculeById(id);
  }

  @override
  Future<List<Vehicule>> searchVehicules(String query) async {
    final vehicules = await getVehicules();
    return vehicules
        .where((v) =>
            v.marque.toLowerCase().contains(query.toLowerCase()) ||
            v.modele.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
