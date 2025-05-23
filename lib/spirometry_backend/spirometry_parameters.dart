import 'package:fl_chart/fl_chart.dart';

class SpirometryParameters {
  final double fvc; // Forced Vital Capacity
  final double fev1; // Forced Expiratory Volume in 1 second
  final double fev1FvcRatio; // FEV1/FVC ratio
  final double fef2575; // Forced Expiratory Flow at 25-75% of FVC
  final double pef; // Peak Expiratory Flow
  final double fet; // Forced Expiratory Time
  final double fivc; // Forced Inspiratory Vital Capacity
  final double pif; // Peak Inspiratory Flow

  SpirometryParameters({
    required this.fvc,
    required this.fev1,
    required this.fev1FvcRatio,
    required this.fef2575,
    required this.pef,
    required this.fet,
    required this.fivc,
    required this.pif,
  });

  static SpirometryParameters calculate(
      List<FlSpot> flowVolumePoints, List<FlSpot> volumeTimePoints) {
    if (flowVolumePoints.isEmpty || volumeTimePoints.isEmpty) {
      return SpirometryParameters(
        fvc: 0.0,
        fev1: 0.0,
        fev1FvcRatio: 0.0,
        fef2575: 0.0,
        pef: 0.0,
        fet: 0.0,
        fivc: 0.0,
        pif: 0.0,
      );
    }

    // Sort points by volume for flow-volume curve
    final sortedFlowVolume = List<FlSpot>.from(flowVolumePoints)
      ..sort((a, b) => a.x.compareTo(b.x));

    // Sort points by time for volume-time curve
    final sortedVolumeTime = List<FlSpot>.from(volumeTimePoints)
      ..sort((a, b) => a.x.compareTo(b.x));

    // Calculate FVC (maximum volume)
    final fvc = sortedFlowVolume.last.x.toDouble();

    // Calculate FEV1 (volume at 1 second)
    final fev1 = _findVolumeAtTime(sortedVolumeTime, 1.0);

    // Calculate FEV1/FVC ratio
    final fev1FvcRatio = fvc > 0 ? fev1 / fvc : 0.0;

    // Calculate PEF (maximum flow)
    final pef = sortedFlowVolume
        .map((point) => point.y)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    // Calculate FET (time to reach FVC)
    final fet = (sortedVolumeTime.last.x - sortedVolumeTime.first.x).toDouble();

    // Calculate FEF25-75 (average flow between 25% and 75% of FVC)
    final volume25 = fvc * 0.25;
    final volume75 = fvc * 0.75;
    final fef2575 = _calculateFEF2575(sortedFlowVolume, volume25, volume75);

    // Calculate FIVC and PIF (assuming negative flow values represent inspiration)
    final inspiratoryPoints =
        sortedFlowVolume.where((point) => point.y < 0).toList();
    final fivc = inspiratoryPoints.isNotEmpty
        ? inspiratoryPoints.last.x.toDouble()
        : 0.0;
    final pif = inspiratoryPoints.isNotEmpty
        ? inspiratoryPoints
            .map((point) => -point.y)
            .reduce((a, b) => a > b ? a : b)
            .toDouble()
        : 0.0;

    return SpirometryParameters(
      fvc: fvc,
      fev1: fev1,
      fev1FvcRatio: fev1FvcRatio,
      fef2575: fef2575,
      pef: pef,
      fet: fet,
      fivc: fivc,
      pif: pif,
    );
  }

  static double _findVolumeAtTime(List<FlSpot> volumeTimePoints, double time) {
    for (int i = 0; i < volumeTimePoints.length - 1; i++) {
      if (volumeTimePoints[i].x <= time && volumeTimePoints[i + 1].x >= time) {
        // Linear interpolation
        final t = (time - volumeTimePoints[i].x) /
            (volumeTimePoints[i + 1].x - volumeTimePoints[i].x);
        return (volumeTimePoints[i].y +
                t * (volumeTimePoints[i + 1].y - volumeTimePoints[i].y))
            .toDouble();
      }
    }
    return 0.0;
  }

  static double _calculateFEF2575(
      List<FlSpot> flowVolumePoints, double volume25, double volume75) {
    final pointsInRange = flowVolumePoints
        .where((point) => point.x >= volume25 && point.x <= volume75)
        .toList();

    if (pointsInRange.isEmpty) return 0.0;

    // Calculate average flow in the range
    final sum = pointsInRange.fold<double>(0.0, (sum, point) => sum + point.y);
    return sum / pointsInRange.length;
  }
}
