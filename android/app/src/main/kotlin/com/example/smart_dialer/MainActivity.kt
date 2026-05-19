package com.example.smart_dialer

import android.app.Activity
import android.app.role.RoleManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.telecom.TelecomManager
import android.telephony.PhoneStateListener
import android.telephony.TelephonyCallback
import android.telephony.TelephonyManager
import android.media.AudioManager
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val DIALER_CHANNEL = "com.smartdialer.app/dialer"
    private val RECORDING_CHANNEL = "com.smartdialer.app/recording"
    private val REQUEST_CODE_SET_DEFAULT_DIALER = 123
    private val REDIRECT_ROLE_REQUEST_CODE = 456

    private var pendingResult: MethodChannel.Result? = null
    private var dialerMethodChannel: MethodChannel? = null
    private var telephonyCallbackInstance: Any? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Initialize channel reference
        dialerMethodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, DIALER_CHANNEL)

        onCallStateChangedListener = { state, number ->
            runOnUiThread {
                dialerMethodChannel?.invokeMethod("onCallStateChanged", mapOf(
                    "state" to state,
                    "phoneNumber" to number
                ))
            }
        }

        // Pre-initialize TelephonyCallback for API 31+ dynamically to avoid class verifier errors
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            telephonyCallbackInstance = ModernTelephonyCallback({ isDefaultDialer() }) { stateString ->
                runOnUiThread {
                    dialerMethodChannel?.invokeMethod("onCallStateChanged", mapOf(
                        "state" to stateString,
                        "phoneNumber" to ""
                    ))
                }
            }
        }

        // Register initial telephony listeners safely
        registerTelephonyListener()

        // 1. Dialer Method Channel
        dialerMethodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "getSystemDialer" -> {
                    result.success(isDefaultDialer())
                }
                "setSystemDialer" -> {
                    pendingResult = result
                    requestDefaultDialer()
                }
                "makeCall" -> {
                    val phoneNumber = call.argument<String>("phoneNumber")
                    if (phoneNumber != null) {
                        result.success(makePhoneCall(phoneNumber))
                    } else {
                        result.error("INVALID_ARGUMENT", "Phone number is null", null)
                    }
                }
                "endCall" -> {
                    result.success(endActiveCall())
                }
                "registerCallStateListener" -> {
                    result.success(registerTelephonyListener())
                }
                "setSpeakerphoneOn" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    result.success(setSpeakerphoneOn(enabled))
                }
                "setMicrophoneMute" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    result.success(setMicrophoneMute(enabled))
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        // 2. Recording Method Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, RECORDING_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isRecordingSupported" -> {
                    result.success(true)
                }
                "startAudioRecord" -> {
                    result.success(true)
                }
                "stopAudioRecord" -> {
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    // Modern TelephonyCallback for API 31+
    @RequiresApi(Build.VERSION_CODES.S)
    private class ModernTelephonyCallback(
        private val isDefaultDialer: () -> Boolean,
        private val onStateChanged: (String) -> Unit
    ) : TelephonyCallback(), TelephonyCallback.CallStateListener {
        override fun onCallStateChanged(state: Int) {
            val stateString = when (state) {
                TelephonyManager.CALL_STATE_IDLE -> "idle"
                TelephonyManager.CALL_STATE_RINGING -> "ringing"
                TelephonyManager.CALL_STATE_OFFHOOK -> if (isDefaultDialer()) "dialing" else "inCall"
                else -> "idle"
            }
            onStateChanged(stateString)
        }
    }

    // Legacy PhoneStateListener for API < 31
    private val legacyCallStateListener = object : PhoneStateListener() {
        @Suppress("DEPRECATION")
        override fun onCallStateChanged(state: Int, incomingNumber: String?) {
            super.onCallStateChanged(state, incomingNumber)
            val stateString = when (state) {
                TelephonyManager.CALL_STATE_IDLE -> "idle"
                TelephonyManager.CALL_STATE_RINGING -> "ringing"
                TelephonyManager.CALL_STATE_OFFHOOK -> if (isDefaultDialer()) "dialing" else "inCall"
                else -> "idle"
            }
            runOnUiThread {
                dialerMethodChannel?.invokeMethod("onCallStateChanged", mapOf(
                    "state" to stateString,
                    "phoneNumber" to (incomingNumber ?: "")
                ))
            }
        }
    }

    private fun registerTelephonyListener(): Boolean {
        return try {
            val telephonyManager = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val callback = telephonyCallbackInstance as? TelephonyCallback
                if (callback != null) {
                    val executor = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                        mainExecutor
                    } else {
                        android.os.Handler(mainLooper).let { handler -> java.util.concurrent.Executor { handler.post(it) } }
                    }
                    telephonyManager.registerTelephonyCallback(executor, callback)
                }
            } else {
                @Suppress("DEPRECATION")
                telephonyManager.listen(legacyCallStateListener, PhoneStateListener.LISTEN_CALL_STATE)
            }
            true
        } catch (e: SecurityException) {
            false
        } catch (e: Exception) {
            false
        }
    }

    private fun unregisterTelephonyListener() {
        try {
            val telephonyManager = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val callback = telephonyCallbackInstance as? TelephonyCallback
                if (callback != null) {
                    telephonyManager.unregisterTelephonyCallback(callback)
                }
            } else {
                @Suppress("DEPRECATION")
                telephonyManager.listen(legacyCallStateListener, PhoneStateListener.LISTEN_NONE)
            }
        } catch (e: Exception) {
            // Safety guard
        }
    }

    private fun isDefaultDialer(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val telecomManager = getSystemService(Context.TELECOM_SERVICE) as TelecomManager
            return telecomManager.defaultDialerPackage == packageName
        }
        return false
    }

    private fun requestDefaultDialer() {
        if (isDefaultDialer()) {
            requestCallRedirectionRole()
            pendingResult?.success(true)
            pendingResult = null
            return
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val roleManager = getSystemService(Context.ROLE_SERVICE) as RoleManager
            if (roleManager.isRoleAvailable(RoleManager.ROLE_DIALER)) {
                val intent = roleManager.createRequestRoleIntent(RoleManager.ROLE_DIALER)
                startActivityForResult(intent, REQUEST_CODE_SET_DEFAULT_DIALER)
            } else {
                pendingResult?.success(false)
                pendingResult = null
            }
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            @Suppress("DEPRECATION")
            val intent = Intent(TelecomManager.ACTION_CHANGE_DEFAULT_DIALER).apply {
                putExtra(TelecomManager.EXTRA_CHANGE_DEFAULT_DIALER_PACKAGE_NAME, packageName)
            }
            startActivityForResult(intent, REQUEST_CODE_SET_DEFAULT_DIALER)
        } else {
            pendingResult?.success(false)
            pendingResult = null
        }
    }

    private fun requestCallRedirectionRole() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val roleManager = getSystemService(Context.ROLE_SERVICE) as RoleManager
            if (roleManager.isRoleAvailable(RoleManager.ROLE_CALL_REDIRECTION) &&
                !roleManager.isRoleHeld(RoleManager.ROLE_CALL_REDIRECTION)) {
                val intent = roleManager.createRequestRoleIntent(RoleManager.ROLE_CALL_REDIRECTION)
                startActivityForResult(intent, REDIRECT_ROLE_REQUEST_CODE)
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_CODE_SET_DEFAULT_DIALER) {
            val isDefault = isDefaultDialer()
            if (isDefault) {
                requestCallRedirectionRole()
            }
            pendingResult?.success(isDefault)
            pendingResult = null
        } else if (requestCode == REDIRECT_ROLE_REQUEST_CODE) {
            // Call Redirection role request handler
        }
    }

    private fun makePhoneCall(phoneNumber: String): Boolean {
        return try {
            val telecomManager = getSystemService(Context.TELECOM_SERVICE) as TelecomManager
            val uri = Uri.fromParts("tel", phoneNumber, null)
            val extras = Bundle()
            telecomManager.placeCall(uri, extras)
            true
        } catch (e: SecurityException) {
            // Fallback to traditional intent if placeCall is security guarded or blocked
            try {
                val intent = Intent(Intent.ACTION_CALL).apply {
                    data = Uri.parse("tel:$phoneNumber")
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                startActivity(intent)
                true
            } catch (ex: Exception) {
                false
            }
        } catch (e: Exception) {
            false
        }
    }

    private fun endActiveCall(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            return try {
                val telecomManager = getSystemService(Context.TELECOM_SERVICE) as TelecomManager
                telecomManager.endCall()
                true
            } catch (e: Exception) {
                false
            }
        }
        return false
    }

    private fun setSpeakerphoneOn(enabled: Boolean): Boolean {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && InCallServiceImpl.activeInstance != null) {
                InCallServiceImpl.activeInstance?.setSpeakerOn(enabled)
            } else {
                val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
                audioManager.mode = AudioManager.MODE_IN_COMMUNICATION
                audioManager.isSpeakerphoneOn = enabled
            }
            true
        } catch (e: Exception) {
            false
        }
    }

    private fun setMicrophoneMute(enabled: Boolean): Boolean {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && InCallServiceImpl.activeInstance != null) {
                InCallServiceImpl.activeInstance?.setMuteOn(enabled)
            } else {
                val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
                audioManager.isMicrophoneMute = enabled
            }
            true
        } catch (e: Exception) {
            false
        }
    }

    override fun onDestroy() {
        onCallStateChangedListener = null
        super.onDestroy()
        unregisterTelephonyListener()
    }

    companion object {
        var onCallStateChangedListener: ((String, String) -> Unit)? = null
    }
}
