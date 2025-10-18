package com.example.lyrium

import android.content.Intent
import android.provider.Settings
import android.text.TextUtils
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val EVENT_CHANNEL = "music_notifications"
    private val METHOD_CHANNEL = "music_notifications/methods"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL)
                .setStreamHandler(
                        object : EventChannel.StreamHandler {
                            override fun onListen(
                                    arguments: Any?,
                                    events: EventChannel.EventSink?
                            ) {
                                MusicNotificationListener.eventSink = events
                            }

                            override fun onCancel(arguments: Any?) {
                                MusicNotificationListener.eventSink = null
                            }
                        }
                )

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL)
                .setMethodCallHandler { call, result ->
                    when (call.method) {
                        "play" -> result.success(MusicNotificationListener.play(this))
                        "pause" -> result.success(MusicNotificationListener.pause(this))
                        "seekTo" -> {
                            val position = (call.arguments as? Int)?.toLong() ?: 0L
                            result.success(MusicNotificationListener.seekTo(this, position))
                        }
                        "getPosition" -> result.success(MusicNotificationListener.getPosition(this))
                        "getImageData" ->
                                result.success(MusicNotificationListener.getImageData(this))
                        "getNowPlaying" ->
                                result.success(MusicNotificationListener.getNowPlaying(this))
                        "openNotificationAccessSettings" -> {
                            val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
                            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            startActivity(intent)
                            result.success(true)
                        }
                        "hasNotificationAccess" -> result.success(hasNotificationAccessPermission())
                        else -> result.notImplemented()
                    }
                }
    }

    private fun hasNotificationAccessPermission(): Boolean {
        val enabledListeners =
                Settings.Secure.getString(contentResolver, "enabled_notification_listeners")
        return !TextUtils.isEmpty(enabledListeners) && enabledListeners.contains(packageName)
    }
}
