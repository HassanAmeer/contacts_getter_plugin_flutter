import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'contacts_getter_platform_interface.dart';
import 'models/callLogsModel.dart';
import 'models/contactsModel.dart';
import 'models/messagesModel.dart';
import 'models/othersInfoModel.dart';

class MethodChannelContactsGetter extends ContactsGetterPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('contacts_getter');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    debugPrint("👉🏻 getPlatformVersion result: $version");
    return version;
  }

  @override
  Future<List<Contact>> getContacts({
    DateTime? fromDate,
    int? limit,
    bool orderByDesc = true,
  }) async {
    // debugPrint("👉🏻 getContacts called");
    final Map<String, dynamic> arguments = {
      'fromDate': fromDate?.millisecondsSinceEpoch,
      'limit': limit,
      'orderByDesc': orderByDesc,
    };

    final result = await methodChannel.invokeMethod<List>(
      'getContacts',
      arguments,
    );
    // debugPrint("👉🏻 getContacts result: $result");

    if (result == null) return [];

    var convertedIntoModel = result.map((e) {
      final map = Map<String, dynamic>.from(e as Map);
      return Contact.fromMap(map);
    }).toList();

    return convertedIntoModel;
  }

  @override
  Future<List<CallLog>> getCallLogs({
    DateTime? fromDate,
    int? limit,
    bool orderByDesc = true,
  }) async {
    final Map<String, dynamic> arguments = {
      'fromDate': fromDate?.millisecondsSinceEpoch,
      'limit': limit,
      'orderByDesc': orderByDesc,
    };

    final result = await methodChannel.invokeMethod<List>(
      'getCallLogs',
      arguments,
    );

    if (result == null) return [];

    var convertedIntoModel = result.map((e) {
      final map = Map<String, dynamic>.from(e as Map);
      return CallLog.fromMap(map);
    }).toList();

    return convertedIntoModel;
  }

  @override
  Future<List<Message>> getMessages({
    DateTime? fromDate,
    int? limit,
    bool orderByDesc = true,
  }) async {
    final Map<String, dynamic> arguments = {
      'fromDate': fromDate?.millisecondsSinceEpoch,
      'limit': limit,
      'orderByDesc': orderByDesc,
    };

    final result = await methodChannel.invokeMethod<List>(
      'getMessages',
      arguments,
    );

    if (result == null) return [];

    var convertedIntoModel = result.map((e) {
      final map = Map<String, dynamic>.from(e as Map);
      return Message.fromMap(map);
    }).toList();

    return convertedIntoModel;
  }

  @override
  Future<OthersInfo> getOthersInfo() async {
    final result = await methodChannel.invokeMethod<Map>('getOthersInfo');

    if (result == null) {
      throw Exception('Failed to get others info');
    }

    final map = Map<String, dynamic>.from(result);
    return OthersInfo.fromMap(map);
  }

  @override
  // Adds a new contact with the given name and phone number
  Future<bool> addContact({
    required String name,
    required String phoneNumber,
  }) async {
    final bool success = await methodChannel.invokeMethod('addContact', {
      'name': name,
      'phoneNumber': phoneNumber,
    });
    return success;
  }

  @override
  // Deletes a contact by ID
  Future<bool> deleteContact({required String contactId}) async {
    final bool success = await methodChannel.invokeMethod('deleteContact', {
      'contactId': contactId,
    });
    return success;
  }

  @override
  // Clears all call logs
  Future<bool> clearCallLogs() async {
    final bool success = await methodChannel.invokeMethod('clearCallLogs');
    return success;
  }
}
