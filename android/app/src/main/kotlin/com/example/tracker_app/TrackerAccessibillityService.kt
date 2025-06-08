package com.example.tracker_app

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.auth.FirebaseAuth
import android.util.Log

class TrackAccessibilityService : AccessibilityService() {
    private var scrollCount = 0
    private var tapCount = 0
    private val db = FirebaseFirestore.getInstance()
    private val TAG = "AccessibilityService"

    override fun onServiceConnected() {
        Log.d(TAG, "Accessibility service connected")
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent) {
        when (event.eventType) {
            AccessibilityEvent.TYPE_VIEW_SCROLLED -> {
                scrollCount++
                Log.d(TAG, "Scroll detected. Total: $scrollCount")
                saveDataToFirebase()
            }
            AccessibilityEvent.TYPE_VIEW_CLICKED -> {
                tapCount++
                Log.d(TAG, "Tap detected. Total: $tapCount")
                saveDataToFirebase()
            }
        }
    }

    private fun saveDataToFirebase() {
        val user = FirebaseAuth.getInstance().currentUser
        user?.let {
            val data = hashMapOf(
                "scrollCount" to scrollCount,
                "tapCount" to tapCount,
                "timestamp" to System.currentTimeMillis(),
                "userId" to user.uid
            )

            db.collection("users")
                .document(user.uid)
                .collection("activityLogs")
                .add(data)
                .addOnSuccessListener {
                    Log.d(TAG, "Data saved to Firestore")
                }
                .addOnFailureListener { e ->
                    Log.e(TAG, "Error saving to Firestore", e)
                }
        } ?: run {
            Log.e(TAG, "No authenticated user")
        }
    }

    override fun onInterrupt() {
        Log.d(TAG, "Accessibility service interrupted")
    }
}