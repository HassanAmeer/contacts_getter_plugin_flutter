import 'package:flutter_test/flutter_test.dart';
import 'package:contacts_getter/contacts_getter.dart';
import 'package:contacts_getter/contacts_getter_platform_interface.dart';
import 'package:contacts_getter/contacts_getter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockContactsGetterPlatform
    with MockPlatformInterfaceMixin
    implements ContactsGetterPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final ContactsGetterPlatform initialPlatform = ContactsGetterPlatform.instance;

  test('$MethodChannelContactsGetter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelContactsGetter>());
  });

  test('getPlatformVersion', () async {
    ContactsGetter contactsGetterPlugin = ContactsGetter();
    MockContactsGetterPlatform fakePlatform = MockContactsGetterPlatform();
    ContactsGetterPlatform.instance = fakePlatform;

    expect(await contactsGetterPlugin.getPlatformVersion(), '42');
  });
}
