import 'package:contacts_getter/models/callLogsModel.dart';
import 'package:contacts_getter/models/contactsModel.dart';
import 'package:contacts_getter/models/messagesModel.dart';
import 'package:contacts_getter/models/othersInfoModel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'contacts_getter_method_channel.dart';

abstract class ContactsGetterPlatform extends PlatformInterface {
  /// Constructs a ContactsGetterPlatform.
  ContactsGetterPlatform() : super(token: _token);

  static final Object _token = Object();

  static ContactsGetterPlatform _instance = MethodChannelContactsGetter();

  /// The default instance of [ContactsGetterPlatform] to use.
  ///
  /// Defaults to [MethodChannelContactsGetter].
  static ContactsGetterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ContactsGetterPlatform] when
  /// they register themselves.
  static set instance(ContactsGetterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  //// 1.
  Future<List<Contact>> getContacts({
    DateTime? fromDate,
    int? limit,
    bool orderByDesc = true,
  }) {
    throw UnimplementedError('getContacts() has not been implemented.');
  }

  //// 2.
  Future<List<CallLog>> getCallLogs({
    DateTime? fromDate,
    int? limit,
    bool orderByDesc = true,
  }) {
    throw UnimplementedError('getCallLogs() has not been implemented.');
  }

  //// 3.
  Future<List<Message>> getMessages({
    DateTime? fromDate,
    int? limit,
    bool orderByDesc = true,
  }) {
    throw UnimplementedError('getMessages() has not been implemented.');
  }

  //// 4.
  Future<OthersInfo> getOthersInfo() {
    throw UnimplementedError('getOthersInfo() has not been implemented.');
  }

  //// 4.
  Future<bool> addContact({required String name, required String phoneNumber}) {
    throw UnimplementedError('addContact() has not been implemented.');
  }

  //// 4.
  Future<bool> deleteContact({required String contactId}) {
    throw UnimplementedError('deleteContact() has not been implemented.');
  }

  //// 4.
  Future<bool> clearCallLogs() {
    throw UnimplementedError('clearCallLogs() has not been implemented.');
  }
}
