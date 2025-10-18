package com.example.lyrium

import android.app.Notification
import android.content.Context
import android.media.session.MediaController
import android.media.session.MediaSession
import android.media.session.PlaybackState
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import io.flutter.plugin.common.EventChannel

class MusicNotificationListener : NotificationListenerService() {

    companion object {
        var activeToken: MediaSession.Token? = null
        var activePackage: String? = null
        var activeTitle: String? = null
        // var activeArtist: String? = null
        var eventSink: EventChannel.EventSink? = null

        fun play(context: Context): Boolean {
            return activeToken?.let {
                try {
                    MediaController(context, it).transportControls.play()
                    true
                } catch (e: Exception) {
                    e.printStackTrace()
                    false
                }
            } ?: false
        }

        fun pause(context: Context): Boolean {
            return activeToken?.let {
                try {
                    MediaController(context, it).transportControls.pause()
                    true
                } catch (e: Exception) {
                    e.printStackTrace()
                    false
                }
            } ?: false
        }

        fun seekTo(context: Context, position: Long): Boolean {
            return activeToken?.let {
                try {
                    MediaController(context, it).transportControls.seekTo(position)
                    true
                } catch (e: Exception) {
                    e.printStackTrace()
                    false
                }
            } ?: false
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
            return activeToken?.let {
                try {
                    val controller = MediaController(context, it)
                    val metadata = controller.metadata ?: return null
        
                    // Try embedded bitmap first
                    val bitmap = metadata.getBitmap(android.media.MediaMetadata.METADATA_KEY_ALBUM_ART)
                        ?: metadata.getBitmap(android.media.MediaMetadata.METADATA_KEY_ART)
        
                    if (bitmap != null) {
                        val stream = java.io.ByteArrayOutputStream()
                        bitmap.compress(android.graphics.Bitmap.CompressFormat.PNG, 100, stream)
                        return stream.toByteArray()
                    }
        
                    // If only URI is available
                    val artUri = metadata.getString(android.media.MediaMetadata.METADATA_KEY_ALBUM_ART_URI)
                        ?: metadata.getString(android.media.MediaMetadata.METADATA_KEY_ART_URI)
        
                    artUri?.let {
                        try {
                            val uri = android.net.Uri.parse(it)
                            val resolver = context.contentResolver
                            val input = resolver.openInputStream(uri)
                            input?.use { ins -> return ins.readBytes() }
                        } catch (e: Exception) {
                            e.printStackTrace()
                        }
                    }
        
                    null
                } catch (e: Exception) {
                    e.printStackTrace()
                    null
                }
            }
        }
        

        fun getNowPlaying(context: Context): Map<String, Any?>? {
            return activeToken?.let {
                try {
                    val controller = MediaController(context, it)
                    val state = controller.playbackState
                    val metadata = controller.metadata

                    mapOf(
                        "package" to activePackage,
                        "title" to (activeTitle ?: metadata?.getString(android.media.MediaMetadata.METADATA_KEY_TITLE)),
                        "artist" to metadata?.getString(android.media.MediaMetadata.METADATA_KEY_ARTIST),
                        "album" to metadata?.getString(android.media.MediaMetadata.METADATA_KEY_ALBUM),
                        "duration" to  metadata?.getLong(android.media.MediaMetadata.METADATA_KEY_DURATION),
                        "progress" to state?.position,
                        "isPlaying" to (state?.state == PlaybackState.STATE_PLAYING)
                    )
                } catch (e: Exception) {
                    e.printStackTrace()
                    null
                }
            }
        }
        
    }

    override fun onListenerConnected() {
        super.onListenerConnected()
        sendActiveNotifications()
    }

    private fun sendActiveNotifications() {
        val active = activeNotifications ?: return
        for (sbn in active) handleNotification(sbn)
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        sbn?.let { handleNotification(it) }
    }

    private fun handleNotification(sbn: StatusBarNotification) {

        if (sbn.notification.category != Notification.CATEGORY_TRANSPORT) return
    
        val extras = sbn.notification.extras ?: return
        val title = extras.getCharSequence("android.title")?.toString()
        val artist = extras.getCharSequence("android.text")?.toString()
    
        val mediaSession = sbn.notification.extras.getParcelable(
            Notification.EXTRA_MEDIA_SESSION,
            android.media.session.MediaSession.Token::class.java
        )
        
        if (mediaSession != null) {
            activeToken = mediaSession
            activePackage = sbn.packageName
            activeTitle = title
        }
    
        // Call getNowPlaying here
        val nowPlaying = getNowPlaying(this)
    
        // Send through eventSink
        nowPlaying?.let { eventSink?.success(it) }
    }
    

    override fun onNotificationRemoved(sbn: StatusBarNotification?) {
        if (sbn?.packageName == activePackage) {
            activeToken = null
            activePackage = null
            activeTitle = null
        }
        eventSink?.success(null)
    }
}
