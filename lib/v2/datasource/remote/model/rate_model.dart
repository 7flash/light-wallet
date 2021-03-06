import 'package:equatable/equatable.dart';

class RateModel extends Equatable {
  final double seedsPerUSD;

  const RateModel(this.seedsPerUSD);

  @override
  List<Object> get props => [seedsPerUSD];

  factory RateModel.fromJson(Map<String, dynamic> json) {
    if (json.isNotEmpty) {
      return RateModel(_parseQuantityString(json["rows"][0]["current_seeds_per_usd"] as String?));
    } else {
      return const RateModel(0);
    }
  }

  static double _parseQuantityString(String? quantityString) {
    if (quantityString == null) {
      return 0;
    }
    return double.parse(quantityString.split(" ")[0]);
  }

  double toUSD(double seedsAmount) {
    return seedsPerUSD > 0 ? seedsAmount / seedsPerUSD : 0;
  }

  double toSeeds(double usdAmount) {
    return seedsPerUSD > 0 ? usdAmount * seedsPerUSD : 0;
  }
}
