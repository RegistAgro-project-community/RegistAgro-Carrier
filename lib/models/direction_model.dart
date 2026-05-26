class DirectionModel {
  final List<double> origin;
  final List<double> destination;
  final String? start_at;
  final String? update_at;

  DirectionModel({
    required this.destination,
    required this.origin,
    this.start_at,
    this.update_at,
  });
}
