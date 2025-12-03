import 'dart:math';

class CalculationResult {
  final double min;
  final double max;
  final double average;
  final Map<String, double> allFormulas;

  CalculationResult({
    required this.min,
    required this.max,
    required this.average,
    required this.allFormulas,
  });
}

class OneRepMaxCalculator {
  static CalculationResult calculate(
      {required double weight, required int reps}) {
    if (weight <= 0 || reps <= 0) {
      return CalculationResult(min: 0, max: 0, average: 0, allFormulas: {});
    }

    final Map<String, double> results = {
      'Epley': _epley(weight, reps),
      'Brzycki': _brzycki(weight, reps),
      'Lombardi': _lombardi(weight, reps),
      'O\'Conner': _oConner(weight, reps),
      'Wathan': _wathan(weight, reps),
      'Mayhew': _mayhew(weight, reps),
      'Lander': _lander(weight, reps),
      'Baechle': _baechle(weight, reps),
    };

    final validResults = results.values.where((v) => v > 0).toList();
    if (validResults.isEmpty) {
      return CalculationResult(
          min: 0, max: 0, average: 0, allFormulas: results);
    }

    final double minResult = validResults.reduce(min);
    final double maxResult = validResults.reduce(max);
    final double averageResult =
        validResults.reduce((a, b) => a + b) / validResults.length;

    return CalculationResult(
      min: minResult,
      max: maxResult,
      average: averageResult,
      allFormulas: results,
    );
  }

  static double _epley(double weight, int reps) {
    if (reps == 1) return weight;
    return weight * (1 + reps / 30);
  }

  static double _brzycki(double weight, int reps) {
    if (reps == 1) return weight;
    return weight / (1.0278 - 0.0278 * reps);
  }

  static double _lombardi(double weight, int reps) {
    if (reps == 1) return weight;
    return weight * pow(reps, 0.10);
  }

  static double _oConner(double weight, int reps) {
    if (reps == 1) return weight;
    return weight * (1 + 0.025 * reps);
  }

  static double _wathan(double weight, int reps) {
    if (reps == 1) return weight;
    return (100 * weight) / (48.8 + 53.8 * exp(-0.075 * reps));
  }

  static double _mayhew(double weight, int reps) {
    if (reps == 1) return weight;
    return (100 * weight) / (52.2 + 41.9 * exp(-0.055 * reps));
  }

  static double _lander(double weight, int reps) {
    if (reps == 1) return weight;
    return (100 * weight) / (101.3 - 2.67123 * reps);
  }

  static double _baechle(double weight, int reps) {
    if (reps == 1) return weight;
    const coefficients = {
      2: 1.05,
      3: 1.08,
      4: 1.11,
      5: 1.15,
      6: 1.18,
      7: 1.21,
      8: 1.25,
      9: 1.29,
      10: 1.33,
      11: 1.37,
      12: 1.43,
    };
    final coefficient = coefficients[reps];
    if (coefficient != null) {
      return weight * coefficient;
    }
    // Return 0 or some indicator that the rep range is not supported by this formula
    return 0.0;
  }
}
