import 'package:contacts_getter/models/callLogsModel.dart';
import 'package:contacts_getter/models/contactsModel.dart';
import 'package:contacts_getter/models/messagesModel.dart';
import 'package:contacts_getter/models/othersInfoModel.dart';
import 'contacts_getter_platform_interface.dart';

class ContactsGetter {
  Future<String?> getPlatformVersion() {
    return ContactsGetterPlatform.instance.getPlatformVersion();
  }

  Future<List<Contact>> getContacts({
    DateTime? fromDate,
    int? limit,
    bool orderByDesc = true,
  }) {
    return ContactsGetterPlatform.instance.getContacts(
      fromDate: fromDate,
      limit: limit,
      orderByDesc: orderByDesc,
    );
  }

  Future<List<CallLog>> getCallLogs({
    DateTime? fromDate,
    int? limit,
    bool orderByDesc = true,
  }) {
    return ContactsGetterPlatform.instance.getCallLogs(
      fromDate: fromDate,
      limit: limit,
      orderByDesc: orderByDesc,
    );
  }

  Future<List<Message>> getMessages({
    DateTime? fromDate,
    int? limit,
    bool orderByDesc = true,
  }) {
    return ContactsGetterPlatform.instance.getMessages(
      fromDate: fromDate,
      limit: limit,
      orderByDesc: orderByDesc,
    );
  }

  Future<OthersInfo> getOthersInfo() {
    return ContactsGetterPlatform.instance.getOthersInfo();
  }

  Future<bool> addContact({required String name, required String phoneNumber}) {
    return ContactsGetterPlatform.instance.addContact(
      name: name,
      phoneNumber: phoneNumber,
    );
  }

  Future<bool> deleteContact({required String contactId}) {
    return ContactsGetterPlatform.instance.deleteContact(contactId: contactId);
  }

  Future<bool> clearCallLogs() {
    return ContactsGetterPlatform.instance.clearCallLogs();
  }
}
