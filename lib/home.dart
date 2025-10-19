import 'package:flutter/material.dart';
import 'package:lyrium/controller.dart';
import 'package:lyrium/search.dart';
import 'package:lyrium/service/service.dart';
import 'package:provider/provider.dart';
import 'package:lyrium/viewer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MusicController>(
      builder: (BuildContext context, MusicController ctrl, Widget? child) {
        return AnimatedCrossFade(
          firstChild: Padding(
            padding: EdgeInsetsGeometry.all(9.0),
            child: Center(
              child: SizedBox(width: 300, child: LinearProgressIndicator()),
            ),
          ),
          secondChild: Builder(
            builder: (context) {
              if (ctrl.showTrack) {
                return Scaffold(
                  appBar: AppBar(
                    title: ctrl.info == null && ctrl.lyrics == null
                        ? DefaultHeader(mode: false)
                        : GestureDetector(
                            onTap: () {
                              ctrl.setShowTrackMode(false);
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ctrl.info?.trackName ??
                                      ctrl.lyrics?.trackName ??
                                      "Track",
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  ctrl.info?.artistName ??
                                      ctrl.lyrics?.trackName ??
                                      "Artist",
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(5),
                      child: LinearProgressIndicator(
                        value: ctrl.progressValue,
                        backgroundColor: ctrl.lyrics != null
                            ? null
                            : Colors.transparent,
                      ),
                    ),
                  ),
                  body: Builder(
                    builder: (context) {
                      if (ctrl.lyrics == null) {
                        return Center(
                          child: Builder(
                            builder: (context) {
                              if (ctrl.hasAccess) {
                                if (ctrl.info != null) {
                                  return _buildFetcher(context, ctrl);
                                } else {
                                  return _buildNoMusic();
                                }
                              } else {
                                return _buildAccessRequired(context, ctrl);
                              }
                            },
                          ),
                        );
                      }

                      final track = ctrl.lyrics;
                      final isPlaying = ctrl.isPlaying;
                      final atPosition = ctrl.progress;
                      return LyricsView(
                        lyrics: track,
                        isPlaying: isPlaying,
                        atPosition: atPosition,
                        getPrimaryPosition: ctrl.position,
                        togglePause: (b) => ctrl.togglePause(pause: b),
                        seek: ctrl.seekTo,
                        onSave: ctrl.saveLyrics,
                      );
                      ;
                    },
                  ),
                );
              } else {
                return Scaffold(
                  body: QuickSearch(
                    emptyResults: (c) => buildUserSuggesions(c, ctrl),
                  ),
                );
              }
            },
          ),
          crossFadeState: ctrl.isReady
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: Durations.long1,
        );
      },
    );
  }

  Widget _buildFetcher(BuildContext context, MusicController ctrl) {
    return GestureDetector(
      onDoubleTap: () => ctrl.setShowTrackMode(false),
      onLongPress: () async {
        try {
          await ctrl.fetchAndSaveLyrics();
        } catch (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error Fetching: $e")));
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // const Text("🔍", textScaler: TextScaler.linear(5)),
            // Slider(value: ctrl.progressValue, onChanged: ctrl.seek),
            FutureBuilder(
              future: MusicNotificationService.getImage(),
              builder: (c, s) {
                return AspectRatio(
                  aspectRatio: 1,
                  child: s.data ?? SizedBox.shrink(),
                );
              },
            ),
            SizedBox(height: 30),
            FittedBox(
              child: Text(
                ctrl.info?.trackName ?? "",
                style: Theme.of(
                  context,
                ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            Text(ctrl.info?.artistName ?? ""),
            Text(
              "Hold to fetch",
              style: TextStyle(color: Colors.grey.withAlpha(100)),
            ),
          ],
        ),
      ),
    );
  }

  buildUserSuggesions(BuildContext context, MusicController controller) {
    if (controller.isReady) {
      if (controller.hasAccess) {
        if (controller.info == null) {
          return _buildNoMusic();
        }
        if (controller.lyrics == null) {
          return _buildNoResults();
        }
      } else {
        return _buildAccessRequired(context, controller);
      }
    }

    return SizedBox.shrink();
  }

  Widget _buildNoMusic() => const Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.select_all, size: 80, color: Colors.deepPurple),
      SizedBox(height: 16),
      Text(
        'No Music Playing',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 8),
      Text('Start playing a song to see info here.'),
    ],
  );

  Widget _buildAccessRequired(BuildContext context, MusicController? ctrl) {
    if (ctrl == null) {
      return LinearProgressIndicator();
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.notifications_off, size: 80, color: Colors.grey),
        const SizedBox(height: 16),
        const Text("Enable Notification Access?"),
        ElevatedButton(
          onPressed: ctrl.openNotificationAccessSettings,
          child: const Text("Grant Access"),
        ),
      ],
    );
  }

  Widget _buildNoResults() => const Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.search_off, size: 80, color: Colors.grey),
      SizedBox(height: 16),
      Text(
        'Not Found',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 8),
    ],
  );
}
