// Import required packages for Flutter, contacts plugin, permissions, and date formatting
import 'package:contacts_getter/contacts_getter.dart';
import 'package:contacts_getter/models/callLogsModel.dart';
import 'package:contacts_getter/models/contactsModel.dart';
import 'package:contacts_getter/models/messagesModel.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';

// Main entry point of the application
void main() {
  runApp(const FileManagerDemoApp());
}

// Main application widget, sets up the MaterialApp with a modern theme
class FileManagerDemoApp extends StatelessWidget {
  const FileManagerDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Configure MaterialApp with Material 3 theme and custom styling
    return MaterialApp(
      title: 'Contacts Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          primary: Colors.indigo,
          secondary: Colors.indigoAccent,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          elevation: 2,
          shadowColor: Colors.black26,
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),

        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
          titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
      home: const HomePage(),
    );
  }
}

// Stateful widget for the home page, manages state for data fetching and UI
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// State class for HomePage, handles permissions, data fetching, and tabbed UI
class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  // Lists to store fetched data
  List<Contact> contacts = [];
  List<CallLog> callLogs = [];
  List<Message> messages = [];

  // Flags for loading and error states per tab
  bool isContactsLoading = false;
  bool isCallLogsLoading = false;
  bool isMessagesLoading = false;
  String? contactsError;
  String? callLogsError;
  String? messagesError;

  // Tab controller for managing Contacts, Call Logs, and Messages tabs
  late TabController _tabController;

  // Keys for AnimatedList
  final GlobalKey<AnimatedListState> _contactsListKey =
      GlobalKey<AnimatedListState>();
  final GlobalKey<AnimatedListState> _callLogsListKey =
      GlobalKey<AnimatedListState>();
  final GlobalKey<AnimatedListState> _messagesListKey =
      GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    // Initialize TabController with 3 tabs
    _tabController = TabController(length: 3, vsync: this);
    // Fetch data on app startup
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchData());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Requests required permissions (contacts, phone, SMS)
  Future<bool> _requestPermissions() async {
    // Request multiple permissions at once
    Map<Permission, PermissionStatus> statuses = await [
      Permission.contacts,
      Permission.phone,
      Permission.sms,
    ].request();

    // Check if each permission is granted
    bool contactsAccess = statuses[Permission.contacts]?.isGranted ?? false;
    bool callLogAccess = statuses[Permission.phone]?.isGranted ?? false;
    bool smsAccess = statuses[Permission.sms]?.isGranted ?? false;

    // Log permission denials for debugging
    if (!contactsAccess) debugPrint("👉🏻 Contacts permission denied");
    if (!callLogAccess) debugPrint("👉🏻 Phone permission denied");
    if (!smsAccess) debugPrint("👉🏻 SMS permission denied");

    // Return true only if all permissions are granted
    return contactsAccess && callLogAccess && smsAccess;
  }

  // Fetches contacts, call logs, and messages, and updates the UI
  Future<void> _fetchData() async {
    // Check permissions
    bool hasPermissions = await _requestPermissions();
    if (!hasPermissions) {
      setState(() {
        contactsError = callLogsError = messagesError =
            "Please grant all required permissions";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please grant all required permissions")),
      );
      return;
    }

    // Fetch contacts
    setState(() {
      isContactsLoading = true;
      contactsError = null;
    });
    try {
      debugPrint("👉🏻 Calling getContacts");
      var fetchedContacts = await ContactsGetter().getContacts(
        limit: 10,
        orderByDesc: true,
      );
      debugPrint("👉🏻 Contacts: $fetchedContacts");
      setState(() {
        contacts = fetchedContacts;
      });
      for (var contact in fetchedContacts) {
        debugPrint(
          "👉🏻 Contact: ${contact.displayName}, ${contact.phoneNumber}",
        );
      }
    } catch (e) {
      debugPrint("👉🏻 Error getting contacts: $e");
      setState(() {
        contactsError = "Error getting contacts: $e";
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error getting contacts: $e")));
    }
    setState(() {
      isContactsLoading = false;
    });

    // Fetch call logs
    setState(() {
      isCallLogsLoading = true;
      callLogsError = null;
    });
    try {
      debugPrint("👉🏻 Calling getCallLogs");
      var fetchedCallLogs = await ContactsGetter().getCallLogs(
        limit: 10,
        orderByDesc: true,
      );
      debugPrint("👉🏻 Call Logs: $fetchedCallLogs");
      setState(() {
        callLogs = fetchedCallLogs;
      });
      for (var call in fetchedCallLogs) {
        debugPrint(
          "👉🏻 Call: ${call.number}, ${call.type}, ${call.date}, ${call.duration}s",
        );
      }
    } catch (e) {
      debugPrint("👉🏻 Error getting call logs: $e");
      setState(() {
        callLogsError = "Error getting call logs: $e";
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error getting call logs: $e")));
    }
    setState(() {
      isCallLogsLoading = false;
    });

    // Fetch messages
    setState(() {
      isMessagesLoading = true;
      messagesError = null;
    });
    try {
      debugPrint("👉🏻 Calling getMessages");
      var fetchedMessages = await ContactsGetter().getMessages(
        limit: 10,
        orderByDesc: true,
      );
      debugPrint("👉🏻 Messages: $fetchedMessages");
      setState(() {
        messages = fetchedMessages;
      });
      for (var message in fetchedMessages) {
        debugPrint(
          "👉🏻 Message: ${message.address}, ${message.type}, ${message.body}, ${message.date}",
        );
      }
    } catch (e) {
      debugPrint("👉🏻 Error getting messages: $e");
      setState(() {
        messagesError = "Error getting messages: $e";
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error getting messages: $e")));
    }
    setState(() {
      isMessagesLoading = false;
    });
  }

  // Adds a new contact using name and phone number from a dialog
  Future<void> _addContact() async {
    // Check if WRITE_CONTACTS permission is granted
    bool hasPermissions = await _requestPermissions();
    if (!hasPermissions) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please grant all required permissions")),
      );
      return;
    }

    // Controllers for the dialog input fields
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    bool isNameValid = true;
    bool isPhoneValid = true;

    // Show dialog to input contact details
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text("Add New Contact"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Name",
                  prefixIcon: const Icon(Icons.person, color: Colors.indigo),
                  errorText: isNameValid ? null : "Name is required",
                ),
                onChanged: (value) {
                  setDialogState(() {
                    isNameValid = value.trim().isNotEmpty;
                  });
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: "Phone Number",
                  prefixIcon: const Icon(Icons.phone, color: Colors.indigo),
                  errorText: isPhoneValid ? null : "Phone number is required",
                ),
                keyboardType: TextInputType.phone,
                onChanged: (value) {
                  setDialogState(() {
                    isPhoneValid = value.trim().isNotEmpty;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () {
                setDialogState(() {
                  isNameValid = nameController.text.trim().isNotEmpty;
                  isPhoneValid = phoneController.text.trim().isNotEmpty;
                });
                if (isNameValid && isPhoneValid) {
                  Navigator.pop(context, true);
                }
              },
              child: const Text("Add"),
            ),
          ],
        ),
      ),
    );

    // If user confirms, add the contact
    if (nameController.text.trim().isNotEmpty &&
        phoneController.text.trim().isNotEmpty) {
      setState(() {
        isContactsLoading = true;
      });
      try {
        final success = await ContactsGetter().addContact(
          name: nameController.text.trim(),
          phoneNumber: phoneController.text.trim(),
        );
        debugPrint("👉🏻 Add contact result: $success");
        if (success) {
          await _fetchData();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Contact added successfully")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to add contact")),
          );
        }
      } catch (e) {
        debugPrint("👉🏻 Error adding contact: $e");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error adding contact: $e")));
      }
      setState(() {
        isContactsLoading = false;
      });
    }

    // Dispose controllers to prevent memory leaks
    nameController.dispose();
    phoneController.dispose();
  }

  // Deletes a contact by ID and refreshes the UI
  Future<void> _deleteContact(String contactId) async {
    // Check if WRITE_CONTACTS permission is granted
    bool hasPermissions = await _requestPermissions();
    if (!hasPermissions) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please grant all required permissions")),
      );
      return;
    }

    setState(() {
      isContactsLoading = true;
    });
    try {
      final success = await ContactsGetter().deleteContact(
        contactId: contactId,
      );
      debugPrint("👉🏻 Delete contact result: $success");
      if (success) {
        await _fetchData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Contact deleted successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to delete contact")),
        );
      }
    } catch (e) {
      debugPrint("👉🏻 Error deleting contact: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error deleting contact: $e")));
    }
    setState(() {
      isContactsLoading = false;
    });
  }

  // Clears all call logs and refreshes the UI
  Future<void> _clearCallLogs() async {
    // Check if WRITE_CALL_LOG permission is granted
    bool hasPermissions = await _requestPermissions();
    if (!hasPermissions) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please grant all required permissions")),
      );
      return;
    }

    setState(() {
      isCallLogsLoading = true;
    });
    try {
      final success = await ContactsGetter().clearCallLogs();
      debugPrint("👉🏻 Clear call logs result: $success");
      if (success) {
        await _fetchData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Call logs cleared successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to clear call logs")),
        );
      }
    } catch (e) {
      debugPrint("👉🏻 Error clearing call logs: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error clearing call logs: $e")));
    }
    setState(() {
      isCallLogsLoading = false;
    });
  }

  // Builds a card for each contact with animation
  Widget _buildContactCard(Contact contact, int index) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.indigo.withOpacity(0.1),
          child: const Icon(Icons.person, color: Colors.indigo),
        ),
        title: Text(
          contact.displayName ?? 'Unknown',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(contact.phoneNumber ?? 'No phone'),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.redAccent),
          onPressed: () => _deleteContact(contact.id),
        ),
      ),
    );
  }

  // Builds a card for each call log with animation
  Widget _buildCallLogCard(CallLog call, int index) {
    final date = DateTime.fromMillisecondsSinceEpoch(
      call.date.millisecondsSinceEpoch,
    );
    final formattedDate = DateFormat('MMM dd, yyyy HH:mm').format(date);
    IconData icon;
    Color iconColor;
    switch (call.type) {
      case CallType.incoming:
        icon = Icons.call_received;
        iconColor = Colors.green;
        break;
      case CallType.outgoing:
        icon = Icons.call_made;
        iconColor = Colors.blue;
        break;
      case CallType.missed:
        icon = Icons.call_missed;
        iconColor = Colors.red;
        break;
      default:
        icon = Icons.call;
        iconColor = Colors.grey;
    }
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.1),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          call.number ?? 'Unknown',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('$formattedDate • ${call.duration}s'),
      ),
    );
  }

  // Builds a card for each message with animation
  Widget _buildMessageCard(Message message, int index) {
    final date = DateTime.fromMillisecondsSinceEpoch(
      message.date.millisecondsSinceEpoch,
    );
    final formattedDate = DateFormat('MMM dd, yyyy HH:mm').format(date);
    final body = message.body.length > 50
        ? '${message.body.substring(0, 50)}...'
        : message.body;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              (message.type == MessageType.sent ? Colors.blue : Colors.green)
                  .withOpacity(0.1),
          child: Icon(
            message.type == MessageType.sent ? Icons.send : Icons.message,
            color: message.type == MessageType.sent
                ? Colors.blue
                : Colors.green,
          ),
        ),
        title: Text(
          message.address ?? 'Unknown',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('$body\n$formattedDate'),
      ),
    );
  }

  // Builds an empty state widget with an icon and message
  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Builds an error state widget with a retry button
  Widget _buildErrorState(String error, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(
            error,
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contacts Demo"),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: "Contacts", icon: Icon(Icons.contacts)),
            Tab(text: "Call Logs", icon: Icon(Icons.call)),
            Tab(text: "Messages", icon: Icon(Icons.message)),
          ],
        ),
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: _addContact,
              tooltip: "Add Contact",
              child: const Icon(Icons.person_add),
            )
          : null,
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              // Contacts tab
              Stack(
                children: [
                  if (contactsError != null)
                    _buildErrorState(contactsError!, _fetchData)
                  else if (contacts.isEmpty && !isContactsLoading)
                    _buildEmptyState("No contacts found", Icons.contacts)
                  else
                    AnimatedList(
                      key: _contactsListKey,
                      initialItemCount: contacts.length,
                      padding: const EdgeInsets.only(top: 8, bottom: 80),
                      itemBuilder: (context, index, animation) =>
                          SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(1, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: _buildContactCard(contacts[index], index),
                          ),
                    ),
                  if (isContactsLoading)
                    Container(
                      color: Colors.black.withOpacity(0.3),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
              // Call Logs tab
              Stack(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: ElevatedButton.icon(
                          onPressed: _clearCallLogs,
                          icon: const Icon(Icons.delete_sweep),
                          label: const Text("Clear Call Logs"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
                          ),
                        ),
                      ),
                      Expanded(
                        child: callLogsError != null
                            ? _buildErrorState(callLogsError!, _fetchData)
                            : callLogs.isEmpty && !isCallLogsLoading
                            ? _buildEmptyState("No call logs found", Icons.call)
                            : AnimatedList(
                                key: _callLogsListKey,
                                initialItemCount: callLogs.length,
                                padding: const EdgeInsets.only(bottom: 80),
                                itemBuilder: (context, index, animation) =>
                                    SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(1, 0),
                                        end: Offset.zero,
                                      ).animate(animation),
                                      child: _buildCallLogCard(
                                        callLogs[index],
                                        index,
                                      ),
                                    ),
                              ),
                      ),
                    ],
                  ),
                  if (isCallLogsLoading)
                    Container(
                      color: Colors.black.withOpacity(0.3),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
              // Messages tab
              Stack(
                children: [
                  messagesError != null
                      ? _buildErrorState(messagesError!, _fetchData)
                      : messages.isEmpty && !isMessagesLoading
                      ? _buildEmptyState("No messages found", Icons.message)
                      : AnimatedList(
                          key: _messagesListKey,
                          initialItemCount: messages.length,
                          padding: const EdgeInsets.only(top: 8, bottom: 80),
                          itemBuilder: (context, index, animation) =>
                              SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(1, 0),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: _buildMessageCard(
                                  messages[index],
                                  index,
                                ),
                              ),
                        ),
                  if (isMessagesLoading)
                    Container(
                      color: Colors.black.withOpacity(0.3),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
