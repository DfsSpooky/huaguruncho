import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/sync/sync_controller.dart';
import '../data/weather_repository.dart';
import '../domain/weather_model.dart';

final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  final dio = ref.watch(dioClientProvider);
  return WeatherRepository(dioClient: dio);
});

final selectedWeatherStationIndexProvider = StateProvider<int>((ref) => 2); // default: Laguna Huascacocha

final weatherStationsProvider = FutureProvider<List<WeatherStationModel>>((ref) async {
  final repo = ref.watch(weatherRepositoryProvider);
  return repo.getWeatherStations();
});

final weatherAlertsProvider = FutureProvider<List<WeatherAlertModel>>((ref) async {
  final repo = ref.watch(weatherRepositoryProvider);
  return repo.getWeatherAlerts();
});
