package com.example.lyrium

import android.app.Notification
import android.content.ComponentName
import android.content.Context
import android.graphics.Bitmap
import android.media.MediaMetadata
import android.media.session.MediaController
import android.media.session.MediaSession
import android.media.session.MediaSessionManager
import android.media.session.PlaybackState
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import io.flutter.plugin.common.EventChannel
import java.io.ByteArrayOutputStream

class MusicNotificationListener : NotificationListenerService() {

    companion object {
        var instance: MusicNotificationListener? = null
        var eventSink: EventChannel.EventSink? = null

        // We keep track of the currently "focused" token to control media
        private var activeToken: MediaSession.Token? = null

        fun update(retries: Int = 10) : Boolean {
            val currentInstance = instance
            if (currentInstance != null) {
                currentInstance.updateActiveSession()
            } else {
                if (retries > 0) {
                    android.os.Handler(android.os.Looper.getMainLooper())
                            .postDelayed({ update(retries - 1) }, 200)
                } else {
                    return false;
                }
            }

            return true
        }

        // 1. GET LIST: Returns a list of ALL active media sessions found in notifications
        fun getActiveMediaSessions(context: Context): List<Map<String, Any?>> {
            val currentInstance = instance ?: return emptyList()
            val list = mutableListOf<Map<String, Any?>>()

            try {
                val notifications = currentInstance.activeNotifications
                for (sbn in notifications) {
                    // Check if notification has a Media Session Token attached
                    val token =
                            sbn.notification.extras.getParcelable(
                                    Notification.EXTRA_MEDIA_SESSION,
                                    MediaSession.Token::class.java
                            )

                    if (token != null) {
                        val controller = MediaController(context, token)
                        val data = controllerToMap(controller, sbn.packageName)
                        list.add(data)
                    }
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
            return list
        }

        // 2. CONTROLS: Play/Pause/Seek
        fun play(context: Context) = sendControl(context) { it.play() }
        fun pause(context: Context) = sendControl(context) { it.pause() }
        fun skipNext(context: Context) = sendControl(context) { it.skipToNext() }
        fun skipPrevious(context: Context) = sendControl(context) { it.skipToPrevious() }
        fun seekTo(context: Context, pos: Long) = sendControl(context) { it.seekTo(pos) }

        private fun sendControl(
                context: Context,
                action: (MediaController.TransportControls) -> Unit
        ): Boolean {
            val token = activeToken ?: return false
            return try {
                val controller = MediaController(context, token)
                action(controller.transportControls)
                true
            } catch (e: Exception) {
                false
            }
        }

        fun getPosition(context: android.content.Context): Long? {
            return activeToken?.let {
                try {
                    val controller = android.media.session.MediaController(context, it)
                    controller.playbackState?.position
                } catch (e: Exception) {
                    e.printStackTrace()
                    null
                }
            }
        }

        fun getImageData(context: Context): ByteArray? {
            val token = activeToken ?: return null
            return try {
                val controller = MediaController(context, token)
                val metadata = controller.metadata ?: return null

                // Try Bitmap first
                val bitmap =
                        metadata.getBitmap(MediaMetadata.METADATA_KEY_ALBUM_ART)
                                ?: metadata.getBitmap(MediaMetadata.METADATA_KEY_ART)

                if (bitmap != null) {
                    val stream = ByteArrayOutputStream()
                    bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
                    return stream.toByteArray()
                }

                null
            } catch (e: Exception) {
                null
            }
        }

        private fun controllerToMap(
                controller: MediaController,
                packageName: String?
        ): Map<String, Any?> {
            val meta = controller.metadata
            val state = controller.playbackState

            return mapOf(
                    "packageName" to (packageName ?: controller.packageName),
                    "title" to meta?.getString(MediaMetadata.METADATA_KEY_TITLE),
                    "artist" to meta?.getString(MediaMetadata.METADATA_KEY_ARTIST),
                    "album" to meta?.getString(MediaMetadata.METADATA_KEY_ALBUM),
                    "duration" to meta?.getLong(MediaMetadata.METADATA_KEY_DURATION),
                    "position" to state?.position,
                    "playbackSpeed" to state?.playbackSpeed,
                    "isPlaying" to (state?.state == PlaybackState.STATE_PLAYING)
            )
        }
    }

    // --- SERVICE INSTANCE LOGIC ---

    private lateinit var sessionManager: MediaSessionManager

    override fun onCreate() {
        super.onCreate()
        sessionManager = getSystemService(Context.MEDIA_SESSION_SERVICE) as MediaSessionManager
    }

    override fun onListenerConnected() {
        super.onListenerConnected()
        instance = this
        updateActiveSession()
    }

    override fun onListenerDisconnected() {
        instance = null
        super.onListenerDisconnected()
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        if (shouldIgnore(sbn)) return
        updateActiveSession()
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification?) {
        if (shouldIgnore(sbn)) return
        // If the app we are listening to dies, try to find another one or clear
        if (sbn?.packageName == activeToken?.let { MediaController(this, it).packageName }) {
            updateActiveSession() // Will find next best or null
        }
    }

    private fun shouldIgnore(sbn: StatusBarNotification?): Boolean {
        return sbn == null ||
                sbn.notification.extras.getParcelable<MediaSession.Token>(
                        Notification.EXTRA_MEDIA_SESSION,
                        MediaSession.Token::class.java
                ) == null
    }

    private fun updateActiveSession() {
        try {
            val componentName = ComponentName(this, MusicNotificationListener::class.java)
            val sessions = sessionManager.getActiveSessions(componentName)

            var targetController =
                    sessions.firstOrNull { it.playbackState?.state == PlaybackState.STATE_PLAYING }

            if (targetController == null && sessions.isNotEmpty()) {
                targetController = sessions[0]
            }

            if (targetController != null) {
                activeToken = targetController.sessionToken

                val data = controllerToMap(targetController, targetController.packageName)
                eventSink?.success(data)
            } else {
                activeToken = null
                eventSink?.success(null)
            }
        } catch (e: SecurityException) {} catch (e: Exception) {
            e.printStackTrace()
        }
    }
}
