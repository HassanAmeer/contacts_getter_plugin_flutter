// lib/src/models/others_info.dart

import 'package:contacts_getter/const/nullString.dart';

enum NetworkType { wifi, mobile, ethernet, unknown }

enum SimType { physical, esim, unknown }

class OthersInfo {
  String deviceId; // Android ID
  String deviceName; // e.g., Build.MODEL
  String deviceImei;
  String model; // Device model
  String networkType;
  String simNumber; // Phone number
  String simSerialNumber;
  String carrierName; // Operator
  String countryIso;
  bool isActive;
  String simType;

  OthersInfo({
    this.deviceId = "",
    this.deviceName = "",
    this.deviceImei = "",
    this.model = "",
    this.networkType = "",
    this.simNumber = "",
    this.simSerialNumber = "",
    this.carrierName = "",
    this.countryIso = "",
    this.isActive = true,
    this.simType = "unknown",
  });

  factory OthersInfo.fromMap(Map<String, dynamic> map) {
    return OthersInfo(
      deviceId: map['deviceId'] ?? '',
      deviceName: map['deviceName'] ?? '',
      deviceImei: map['deviceImei'] ?? '',
      model: map['model'] ?? '',
      networkType: parseNetworkType(map['networkType'] ?? 'unknown'),
      simNumber: map['simNumber'],
      simSerialNumber: map['simSerialNumber'] ?? '',
      carrierName: map['carrierName'],
      countryIso: map['countryIso'],
      isActive: map['isActive'] ?? false,
      simType: parseSimType(map['simType'] ?? 'unknown'),
    );
  }

  static String parseNetworkType(String type) {
    switch (type) {
      case 'wifi':
        return "wifi";
      case 'mobile':
        return "mobile";
      case 'ethernet':
        return "ethernet";
      default:
        return "unknown";
    }
  }

  static String parseSimType(String type) {
    switch (type) {
      case 'physical':
        return "physical";
      case 'esim':
        return "esim";
      default:
        return "unknown";
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'deviceId': deviceId.toString(),
      'deviceName': deviceName.toString(),
      'deviceImei': deviceImei.toString(),
      'model': model.toString(),
      'networkType': networkType.toString(),
      'simNumber': simNumber.toString(),
      'simSerialNumber': simSerialNumber.toString(),
      'carrierName': carrierName.toString(),
      'countryIso': countryIso.toString(),
      'isActive': isActive.toString().toNullString() == 'true',
      'simType': simType.toString(),
    };
  }
}
