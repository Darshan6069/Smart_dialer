package com.example.smart_dialer

import android.os.Build
import android.telecom.Call
import android.telecom.InCallService
import android.telecom.CallAudioState
import androidx.annotation.RequiresApi

@RequiresApi(Build.VERSION_CODES.M)
class InCallServiceImpl : InCallService() {

    companion object {
        var activeInstance: InCallServiceImpl? = null
    }

    override fun onCreate() {
        super.onCreate()
        activeInstance = this
    }

    override fun onDestroy() {
        activeInstance = null
        super.onDestroy()
    }

    fun setSpeakerOn(enabled: Boolean) {
        val route = if (enabled) CallAudioState.ROUTE_SPEAKER else CallAudioState.ROUTE_EARPIECE
        setAudioRoute(route)
    }

    fun setMuteOn(enabled: Boolean) {
        setMuted(enabled)
    }

    private val callCallback = object : Call.Callback() {
        override fun onStateChanged(call: Call, state: Int) {
            super.onStateChanged(call, state)
            notifyState(call, state)
        }
    }

    private fun notifyState(call: Call, state: Int) {
        val number = call.details?.handle?.schemeSpecificPart ?: ""
        val stateString = when (state) {
            Call.STATE_CONNECTING -> "dialing"
            Call.STATE_DIALING -> "dialing"
            Call.STATE_RINGING -> "ringing"
            Call.STATE_ACTIVE -> "inCall" // Receiver took the call!
            Call.STATE_DISCONNECTED -> "idle"
            else -> "dialing"
        }
        MainActivity.onCallStateChangedListener?.invoke(stateString, number)
    }

    override fun onCallAdded(call: Call) {
        super.onCallAdded(call)
        try {
            call.registerCallback(callCallback)
            notifyState(call, call.state)
        } catch (e: Exception) {}
    }

    override fun onCallRemoved(call: Call) {
        try {
            call.unregisterCallback(callCallback)
            MainActivity.onCallStateChangedListener?.invoke("idle", "")
        } catch (e: Exception) {}
        super.onCallRemoved(call)
    }
}
