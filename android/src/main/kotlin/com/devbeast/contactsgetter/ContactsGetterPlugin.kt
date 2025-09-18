
package com.devbeast.contactsgetter

import android.Manifest
import android.content.ContentProviderOperation
import android.content.ContentResolver
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.provider.CallLog
import android.provider.ContactsContract
import android.provider.Telephony
import android.telephony.TelephonyManager
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.util.Log
import androidx.core.app.ActivityCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

// Flutter plugin to handle contacts, call logs, messages, and device info operations
class ContactsGetterPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private lateinit var telephonyManager: TelephonyManager
    private lateinit var connectivityManager: ConnectivityManager

    // Called when the plugin is attached to the Flutter engine
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d("ContactsGetterPlugin", "Plugin initialized: onAttachedToEngine called")
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "contacts_getter")
        channel.setMethodCallHandler(this)
        telephonyManager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
        connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
    }

    // Handles method calls from Flutter
    override fun onMethodCall(call: MethodCall, result: Result) {
        Log.d("ContactsGetterPlugin", "Method invoked: ${call.method}")
        when (call.method) {
            "getPlatformVersion" -> {
                Log.d("ContactsGetterPlugin", "Returning platform version")
                result.success("Android ${Build.VERSION.RELEASE}")
            }
            "getContacts" -> {
                if (hasPermission(Manifest.permission.READ_CONTACTS)) {
                    Log.d("ContactsGetterPlugin", "Permission granted for READ_CONTACTS")
                    val contacts = getContacts(call.arguments as Map<String, Any?>)
                    result.success(contacts)
                } else {
                    Log.e("ContactsGetterPlugin", "READ_CONTACTS permission denied")
                    result.error("PERMISSION_DENIED", "READ_CONTACTS permission required", null)
                }
            }
            "getCallLogs" -> {
                if (hasPermission(Manifest.permission.READ_CALL_LOG)) {
                    Log.d("ContactsGetterPlugin", "Permission granted for READ_CALL_LOG")
                    val callLogs = getCallLogs(call.arguments as Map<String, Any?>)
                    result.success(callLogs)
                } else {
                    Log.e("ContactsGetterPlugin", "READ_CALL_LOG permission denied")
                    result.error("PERMISSION_DENIED", "READ_CALL_LOG permission required", null)
                }
            }
            "getMessages" -> {
                if (hasPermission(Manifest.permission.READ_SMS)) {
                    Log.d("ContactsGetterPlugin", "Permission granted for READ_SMS")
                    val messages = getMessages(call.arguments as Map<String, Any?>)
                    result.success(messages)
                } else {
                    Log.e("ContactsGetterPlugin", "READ_SMS permission denied")
                    result.error("PERMISSION_DENIED", "READ_SMS permission required", null)
                }
            }
            "getOthersInfo" -> {
                if (hasPermission(Manifest.permission.READ_PHONE_STATE)) {
                    Log.d("ContactsGetterPlugin", "Permission granted for READ_PHONE_STATE")
                    val othersInfo = getOthersInfo()
                    result.success(othersInfo)
                } else {
                    Log.e("ContactsGetterPlugin", "READ_PHONE_STATE permission denied")
                    result.error("PERMISSION_DENIED", "READ_PHONE_STATE permission required", null)
                }
            }
            "addContact" -> {
                if (hasPermission(Manifest.permission.WRITE_CONTACTS)) {
                    Log.d("ContactsGetterPlugin", "Permission granted for WRITE_CONTACTS")
                    val success = addContact(call.arguments as Map<String, Any?>)
                    result.success(success)
                } else {
                    Log.e("ContactsGetterPlugin", "WRITE_CONTACTS permission denied")
                    result.error("PERMISSION_DENIED", "WRITE_CONTACTS permission required", null)
                }
            }
            "deleteContact" -> {
                if (hasPermission(Manifest.permission.WRITE_CONTACTS)) {
                    Log.d("ContactsGetterPlugin", "Permission granted for WRITE_CONTACTS")
                    val success = deleteContact(call.arguments as Map<String, Any?>)
                    result.success(success)
                } else {
                    Log.e("ContactsGetterPlugin", "WRITE_CONTACTS permission denied")
                    result.error("PERMISSION_DENIED", "WRITE_CONTACTS permission required", null)
                }
            }
            "clearCallLogs" -> {
                if (hasPermission(Manifest.permission.WRITE_CALL_LOG)) {
                    Log.d("ContactsGetterPlugin", "Permission granted for WRITE_CALL_LOG")
                    val success = clearCallLogs()
                    result.success(success)
                } else {
                    Log.e("ContactsGetterPlugin", "WRITE_CALL_LOG permission denied")
                    result.error("PERMISSION_DENIED", "WRITE_CALL_LOG permission required", null)
                }
            }
            else -> {
                Log.w("ContactsGetterPlugin", "Method not implemented: ${call.method}")
                result.notImplemented()
            }
        }
    }

    // Checks if a specific permission is granted
    private fun hasPermission(permission: String): Boolean {
        val granted = ActivityCompat.checkSelfPermission(context, permission) == PackageManager.PERMISSION_GRANTED
        Log.d("ContactsGetterPlugin", "Checking permission $permission: $granted")
        return granted
    }

    // Fetches contacts from the device
    private fun getContacts(args: Map<String, Any?>): List<Map<String, Any?>> {
        Log.d("ContactsGetterPlugin", "getContacts called with args: $args")
        val fromDate = args["fromDate"] as? Long ?: 0L
        val limit = args["limit"] as? Int ?: Int.MAX_VALUE
        val orderByDesc = args["orderByDesc"] as? Boolean ?: true

        val cursor = context.contentResolver.query(
            ContactsContract.Contacts.CONTENT_URI,
            null, null, null, null
        ) ?: run {
            Log.e("ContactsGetterPlugin", "Contacts cursor is null")
            return emptyList()
        }

        val contacts = mutableListOf<Map<String, Any?>>()
        cursor.use {
            while (it.moveToNext() && contacts.size < limit) {
                val id = it.getString(it.getColumnIndexOrThrow(ContactsContract.Contacts._ID))
                val name = it.getString(it.getColumnIndexOrThrow(ContactsContract.Contacts.DISPLAY_NAME))
                val hasPhone = it.getInt(it.getColumnIndexOrThrow(ContactsContract.Contacts.HAS_PHONE_NUMBER)) > 0

                var phone: String? = null
                if (hasPhone) {
                    val phoneCursor = context.contentResolver.query(
                        ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
                        null,
                        "${ContactsContract.CommonDataKinds.Phone.CONTACT_ID} = ?",
                        arrayOf(id),
                        null
                    )
                    phoneCursor?.use { pCursor ->
                        if (pCursor.moveToFirst()) {
                            phone = pCursor.getString(pCursor.getColumnIndexOrThrow(ContactsContract.CommonDataKinds.Phone.NUMBER))
                        }
                    }
                }

                contacts.add(mapOf(
                    "id" to id,
                    "displayName" to name,
                    "phoneNumber" to phone,
                    "email" to null,
                    "photoUri" to null
                ))
            }
        }
        Log.d("ContactsGetterPlugin", "Returning ${contacts.size} contacts")
        return contacts
    }

    // Fetches call logs from the device
    private fun getCallLogs(args: Map<String, Any?>): List<Map<String, Any?>> {
        Log.d("ContactsGetterPlugin", "getCallLogs called with args: $args")
        val fromDate = args["fromDate"] as? Long ?: 0L
        val limit = args["limit"] as? Int ?: Int.MAX_VALUE
        val orderByDesc = args["orderByDesc"] as? Boolean ?: true

        val selection = if (fromDate > 0) "${CallLog.Calls.DATE} >= ?" else null
        val selectionArgs = if (fromDate > 0) arrayOf(fromDate.toString()) else null
        val sortOrder = if (orderByDesc) "${CallLog.Calls.DATE} DESC" else "${CallLog.Calls.DATE} ASC"

        val cursor = try {
            context.contentResolver.query(
                CallLog.Calls.CONTENT_URI,
                null,
                selection,
                selectionArgs,
                sortOrder
            )
        } catch (e: IllegalArgumentException) {
            Log.e("ContactsGetterPlugin", "Failed to query call logs: $e")
            return emptyList()
        } ?: run {
            Log.e("ContactsGetterPlugin", "Call logs cursor is null")
            return emptyList()
        }

        val callLogs = mutableListOf<Map<String, Any?>>()
        cursor.use {
            while (it.moveToNext() && callLogs.size < limit) {
                val id = it.getString(it.getColumnIndexOrThrow(CallLog.Calls._ID))
                val number = it.getString(it.getColumnIndexOrThrow(CallLog.Calls.NUMBER))
                val date = it.getLong(it.getColumnIndexOrThrow(CallLog.Calls.DATE))
                val type = when (it.getInt(it.getColumnIndexOrThrow(CallLog.Calls.TYPE))) {
                    CallLog.Calls.INCOMING_TYPE -> "incoming"
                    CallLog.Calls.OUTGOING_TYPE -> "outgoing"
                    CallLog.Calls.MISSED_TYPE -> "missed"
                    else -> "unknown"
                }
                val duration = it.getLong(it.getColumnIndexOrThrow(CallLog.Calls.DURATION))

                callLogs.add(mapOf(
                    "id" to id,
                    "number" to number,
                    "date" to date,
                    "type" to type,
                    "duration" to duration
                ))
            }
        }
        Log.d("ContactsGetterPlugin", "Returning ${callLogs.size} call logs")
        return callLogs
    }

    // Fetches SMS messages from the device
    private fun getMessages(args: Map<String, Any?>): List<Map<String, Any?>> {
        Log.d("ContactsGetterPlugin", "getMessages called with args: $args")
        val fromDate = args["fromDate"] as? Long ?: 0L
        val limit = args["limit"] as? Int ?: Int.MAX_VALUE
        val orderByDesc = args["orderByDesc"] as? Boolean ?: true

        val selection = if (fromDate > 0) "${Telephony.Sms.DATE} >= ?" else null
        val selectionArgs = if (fromDate > 0) arrayOf(fromDate.toString()) else null
        val sortOrder = if (orderByDesc) "${Telephony.Sms.DATE} DESC" else "${Telephony.Sms.DATE} ASC"

        val uri = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            Telephony.Sms.CONTENT_URI
        } else {
            Telephony.Sms.Inbox.CONTENT_URI
        }

        val cursor = context.contentResolver.query(
            uri,
            null,
            selection,
            selectionArgs,
            sortOrder
        ) ?: run {
            Log.e("ContactsGetterPlugin", "Messages cursor is null")
            return emptyList()
        }

        val messages = mutableListOf<Map<String, Any?>>()
        cursor.use {
            while (it.moveToNext() && messages.size < limit) {
                val id = it.getString(it.getColumnIndexOrThrow(Telephony.Sms._ID))
                val address = it.getString(it.getColumnIndexOrThrow(Telephony.Sms.ADDRESS))
                val body = it.getString(it.getColumnIndexOrThrow(Telephony.Sms.BODY))
                val date = it.getLong(it.getColumnIndexOrThrow(Telephony.Sms.DATE))
                val type = when (it.getInt(it.getColumnIndexOrThrow(Telephony.Sms.TYPE))) {
                    Telephony.Sms.MESSAGE_TYPE_INBOX -> "received"
                    Telephony.Sms.MESSAGE_TYPE_SENT -> "sent"
                    else -> "unknown"
                }
                val read = it.getInt(it.getColumnIndexOrThrow(Telephony.Sms.READ)) == 1

                messages.add(mapOf(
                    "id" to id,
                    "address" to address,
                    "body" to body,
                    "date" to date,
                    "type" to type,
                    "read" to read
                ))
            }
        }
        Log.d("ContactsGetterPlugin", "Returning ${messages.size} messages")
        return messages
    }

    // Fetches device and SIM information
    private fun getOthersInfo(): Map<String, Any?> {
        Log.d("ContactsGetterPlugin", "getOthersInfo called")
        val imei = if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    telephonyManager.imei
                } else {
                    @Suppress("DEPRECATION")
                    telephonyManager.deviceId ?: ""
                }
            } catch (e: SecurityException) {
                Log.e("ContactsGetterPlugin", "Failed to get IMEI: $e")
                ""
            }
        } else {
            Log.w("ContactsGetterPlugin", "IMEI access restricted on Android 10+")
            ""
        }

        val networkType = when {
            connectivityManager.activeNetwork == null -> "unknown"
            else -> {
                val capabilities = connectivityManager.getNetworkCapabilities(connectivityManager.activeNetwork)
                when {
                    capabilities?.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) == true -> "wifi"
                    capabilities?.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) == true -> "mobile"
                    capabilities?.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET) == true -> "ethernet"
                    else -> "unknown"
                }
            }
        }

        val simType = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
            try {
                if (telephonyManager.simState == TelephonyManager.SIM_STATE_READY) {
                    "physical"
                } else {
                    "none"
                }
            } catch (e: Exception) {
                Log.e("ContactsGetterPlugin", "Failed to check SIM state: $e")
                "unknown"
            }
        } else {
            "unknown"
        }

        val simSerialNumber = if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            try {
                telephonyManager.simSerialNumber ?: ""
            } catch (e: SecurityException) {
                Log.e("ContactsGetterPlugin", "Failed to get SIM serial number: $e")
                ""
            }
        } else {
            Log.w("ContactsGetterPlugin", "SIM serial number access restricted on Android 10+")
            ""
        }

        val deviceId = try {
            android.provider.Settings.Secure.getString(context.contentResolver, android.provider.Settings.Secure.ANDROID_ID)
        } catch (e: Exception) {
            Log.e("ContactsGetterPlugin", "Failed to get Android ID: $e")
            ""
        }

        val result = mapOf(
            "deviceId" to deviceId,
            "deviceName" to Build.MODEL,
            "deviceImei" to imei,
            "model" to Build.MODEL,
            "networkType" to networkType,
            "simNumber" to (telephonyManager.line1Number ?: ""),
            "simSerialNumber" to simSerialNumber,
            "carrierName" to (telephonyManager.networkOperatorName ?: ""),
            "countryIso" to (telephonyManager.networkCountryIso ?: ""),
            "isActive" to (telephonyManager.simState == TelephonyManager.SIM_STATE_READY),
            "simType" to simType
        )
        Log.d("ContactsGetterPlugin", "Returning others info: $result")
        return result
    }

    // Adds a new contact with the provided name and phone number
    private fun addContact(args: Map<String, Any?>): Boolean {
        Log.d("ContactsGetterPlugin", "addContact called with args: $args")
        val name = args["name"] as? String ?: return false
        val phoneNumber = args["phoneNumber"] as? String ?: return false

        val ops = ArrayList<ContentProviderOperation>()
        ops.add(
            ContentProviderOperation.newInsert(ContactsContract.RawContacts.CONTENT_URI)
                .withValue(ContactsContract.RawContacts.ACCOUNT_TYPE, null)
                .withValue(ContactsContract.RawContacts.ACCOUNT_NAME, null)
                .build()
        )
        ops.add(
            ContentProviderOperation.newInsert(ContactsContract.Data.CONTENT_URI)
                .withValueBackReference(ContactsContract.Data.RAW_CONTACT_ID, 0)
                .withValue(ContactsContract.Data.MIMETYPE, ContactsContract.CommonDataKinds.StructuredName.CONTENT_ITEM_TYPE)
                .withValue(ContactsContract.CommonDataKinds.StructuredName.DISPLAY_NAME, name)
                .build()
        )
        ops.add(
            ContentProviderOperation.newInsert(ContactsContract.Data.CONTENT_URI)
                .withValueBackReference(ContactsContract.Data.RAW_CONTACT_ID, 0)
                .withValue(ContactsContract.Data.MIMETYPE, ContactsContract.CommonDataKinds.Phone.CONTENT_ITEM_TYPE)
                .withValue(ContactsContract.CommonDataKinds.Phone.NUMBER, phoneNumber)
                .withValue(ContactsContract.CommonDataKinds.Phone.TYPE, ContactsContract.CommonDataKinds.Phone.TYPE_MOBILE)
                .build()
        )

        return try {
            context.contentResolver.applyBatch(ContactsContract.AUTHORITY, ops)
            Log.d("ContactsGetterPlugin", "Contact added: $name, $phoneNumber")
            true
        } catch (e: Exception) {
            Log.e("ContactsGetterPlugin", "Failed to add contact: $e")
            false
        }
    }

    // Deletes a contact by ID
    private fun deleteContact(args: Map<String, Any?>): Boolean {
        Log.d("ContactsGetterPlugin", "deleteContact called with args: $args")
        val contactId = args["contactId"] as? String ?: return false

        val uri = ContactsContract.RawContacts.CONTENT_URI.buildUpon()
            .appendQueryParameter(ContactsContract.CALLER_IS_SYNCADAPTER, "true")
            .build()

        return try {
            val deleted = context.contentResolver.delete(
                uri,
                "${ContactsContract.RawContacts.CONTACT_ID}=?",
                arrayOf(contactId)
            )
            Log.d("ContactsGetterPlugin", "Contact deletion result: $deleted rows deleted for contactId=$contactId")
            deleted > 0
        } catch (e: Exception) {
            Log.e("ContactsGetterPlugin", "Failed to delete contact: $e")
            false
        }
    }

    // Clears all call logs from the device
    private fun clearCallLogs(): Boolean {
        Log.d("ContactsGetterPlugin", "clearCallLogs called")
        return try {
            val deleted = context.contentResolver.delete(CallLog.Calls.CONTENT_URI, null, null)
            Log.d("ContactsGetterPlugin", "Call logs cleared: $deleted rows deleted")
            deleted >= 0
        } catch (e: Exception) {
            Log.e("ContactsGetterPlugin", "Failed to clear call logs: $e")
            false
        }
    }

    // Called when the plugin is detached from the Flutter engine
    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d("ContactsGetterPlugin", "Plugin detached: onDetachedFromEngine called")
        channel.setMethodCallHandler(null)
    }
}
