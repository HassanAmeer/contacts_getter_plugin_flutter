// lib/src/models/others_info.dart

enum NetworkType { wifi, mobile, ethernet, unknown }

enum SimType { physical, esim, unknown }

class OthersInfo {
  final String deviceId; // Android ID
  final String deviceName; // e.g., Build.MODEL
  final String deviceImei;
  final String model; // Device model
  final NetworkType networkType;
  final String? simNumber; // Phone number
  final String simSerialNumber;
  final String? carrierName; // Operator
  final String? countryIso;
  final bool isActive;
  final SimType simType;

  OthersInfo({
    required this.deviceId,
    required this.deviceName,
    required this.deviceImei,
    required this.model,
    required this.networkType,
    this.simNumber,
    required this.simSerialNumber,
    this.carrierName,
    this.countryIso,
    required this.isActive,
    required this.simType,
  });

  factory OthersInfo.fromMap(Map<String, dynamic> map) {
    return OthersInfo(
      deviceId: map['deviceId'] ?? '',
      deviceName: map['deviceName'] ?? '',
      deviceImei: map['deviceImei'] ?? '',
      model: map['model'] ?? '',
      networkType: _parseNetworkType(map['networkType'] ?? 'unknown'),
      simNumber: map['simNumber'],
      simSerialNumber: map['simSerialNumber'] ?? '',
      carrierName: map['carrierName'],
      countryIso: map['countryIso'],
      isActive: map['isActive'] ?? false,
      simType: _parseSimType(map['simType'] ?? 'unknown'),
    );
  }

  static NetworkType _parseNetworkType(String type) {
    switch (type) {
      case 'wifi':
        return NetworkType.wifi;
      case 'mobile':
        return NetworkType.mobile;
      case 'ethernet':
        return NetworkType.ethernet;
      default:
        return NetworkType.unknown;
    }
  }

  static SimType _parseSimType(String type) {
    switch (type) {
      case 'physical':
        return SimType.physical;
      case 'esim':
        return SimType.esim;
      default:
        return SimType.unknown;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'deviceId': deviceId,
      'deviceName': deviceName,
      'deviceImei': deviceImei,
      'model': model,
      'networkType': networkType.toString().split('.').last,
      'simNumber': simNumber,
      'simSerialNumber': simSerialNumber,
      'carrierName': carrierName,
      'countryIso': countryIso,
      'isActive': isActive,
      'simType': simType.toString().split('.').last,
    };
  }
}
