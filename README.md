# contacts_getter

A Flutter plugin for accessing and managing contacts, call logs, and messages on Android.

## ✨ Features
- **📱 Fetch Contacts**: Retrieve contact details (ID, name, phone number, email, photo URI) with pagination and sorting options
- **📞 Fetch Call Logs**: Access call log entries (number, date, type, duration) with filtering and sorting
- **💬 Fetch Messages**: Get SMS messages (address, body, date, type, read status) with limits and ordering
- **➕ Add Contacts**: Create new contacts with name, phone number, and optional email
- **🗑️ Delete Contacts**: Remove contacts by ID
- **🧹 Clear Call Logs**: Delete all call log entries


## Platform Support

- ✅ Android
- ❌ iOS (not implemented)


### Screenshots
 <img src="https://github.com/HassanAmeer/contact_getter_flutter_plugin/blob/main/screenshots/demo.png" style="width:50%">
 <hr>



## 📦 Installation
### Add the plugin to your `pubspec.yaml`:

```yaml
dependencies:
  contacts_getter: any

run the command:
```bash
    flutter pub get
```


## 🔐 Permissions
Request permissions in your app using permission_handler:

### 1. request a permissions thats you need
```dart
  getPermissions() async {
    // Request permissions based on Android version
    // by adding this package
    // import 'package:permission_handler/permission_handler.dart';

    Map<Permission, PermissionStatus> statuses = await [
      Permission.contacts, 
      Permission.phone, 
      Permission.sms, 
    ].request();


    bool hasAccess =
        statuses[Permission.contacts]?.isGranted ??
        true && statuses[Permission.phone]!.isGranted ??
        true && statuses[Permission.sms]!.isGranted ??
        true;

    if (!hasAccess) {
      debugPrint("Required permissions denied");
      await Mediagetter().showToast(
        "Please grant permissions",
        length: ToastLength.long,
      );
      return;
    }
  }
```

## Usage
Import the plugin and use its methods to interact with contacts, call logs, and messages.
`import 'package:contacts_getter/contacts_getter.dart';`

 - Example
   - A simple example to fetch and display contacts on button press:

### 2.
```dart
import 'package:flutter/material.dart';
import 'package:contacts_getter/contacts_getter.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Contact> contacts = [];

  Future<void> fetchContacts() async {
    if (await Permission.contacts.request().isGranted) {
      final fetchedContacts = await ContactsGetter().getContacts(limit: 10);
      setState(() {
        contacts = fetchedContacts;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Contacts permission denied")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Contacts Getter")),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: fetchContacts,
            child: const Text("Fetch Contacts"),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(contacts[index].displayName ?? 'Unknown'),
                subtitle: Text(contacts[index].phoneNumber ?? 'No phone'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

# others methods
```dart
      ContactsGetter().getContacts();
      ContactsGetter().getCallLogs();
      ContactsGetter().getMessages();
      ....
```