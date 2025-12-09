import 'package:flutter/material.dart';
import 'package:lyrium/controller.dart';
import 'package:lyrium/models.dart';
import 'package:lyrium/search.dart';
import 'package:lyrium/widgets/settings.dart';
import 'package:lyrium/widgets/submit_form.dart';
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
          firstChild: Scaffold(
            body: Center(
              child: SizedBox(width: 50, child: LinearProgressIndicator()),
            ),
          ),
          secondChild: buildpage(ctrl),
          crossFadeState: ctrl.isReady
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: Durations.long1,
        );
      },
    );
  }

  Widget buildpage(MusicController ctrl) {
    if (!ctrl.isReady) return SizedBox.shrink();

    return Builder(
      builder: (context) {
        if (ctrl.showTrack) {
          return Scaffold(
            drawer: buildDrawer(),
            appBar: buildLyricsAppBar(ctrl),
            body: buildcontent(ctrl),
          );
        } else {
          return QuickSearch(initailQuery: ctrl.info);
        }
      },
    );
  }

  AppBar buildLyricsAppBar(MusicController ctrl) {
    return AppBar(
      actions: [
        IconButton(
          onPressed: () => ctrl.setShowTrackMode(false),
          icon: RotatedBox(quarterTurns: 1, child: Icon(Icons.chevron_right)),
        ),
      ],
      leading: FutureBuilder(
        future: ctrl.image,
        builder: (c, s) => Padding(
          padding: EdgeInsetsGeometry.all(8.0),
          child: SizedBox(
            width: 30,
            height: 30,
            child: s.data ?? Icon(Icons.music_note),
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ctrl.info?.trackName ?? ctrl.lyrics?.track.trackName ?? "No Track",
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            ctrl.info?.artistName ??
                ctrl.lyrics?.track.artistName ??
                "No Artist",
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget buildcontent(MusicController ctrl) {
    return Builder(
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

        final textColor =
            Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;

        var textStyle = TextStyle(
          fontSize: 40,

          fontWeight: FontWeight.w800,
          color: textColor.withAlpha(127),
        );
        var highlighttextStyle = TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w800,
          color: textColor,
        );

        var textScaler = TextScaler.linear(2);

        return SizedBox(
          // width: 500,
          // height: 500,
          child: LyricsView(
            controller: TempController(
              lyrics: track ?? LyricsTrack.empty(),
              isPlaying: isPlaying,
              atPosition: atPosition,
              getPrimaryPosition: ctrl.position,
              onTogglePause: (b) => ctrl.togglePause(pause: b),
              onSeek: ctrl.seekTo,
            ),
            textStyle: textStyle,
            highlightTextStyle: highlighttextStyle,
            onSave: () => opensubmitform(
              context,
              DraftTrack.from(ctrl.lyrics!, ctrl.lyrics!.syncedLyrics!),
            ),
          ),
        );
      },
    );
  }

  PreferredSize buildnotificationpr(MusicController ctrl) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(5),
      child: LinearProgressIndicator(
        value: ctrl.progressValue,
        backgroundColor: ctrl.lyrics != null ? null : Colors.transparent,
      ),
    );
  }

  bool busyFeching = false;

  Widget _buildFetcher(BuildContext context, MusicController ctrl) {
    return GestureDetector(
      onTap: () async {
        if (busyFeching) return;
        try {
          busyFeching = true;
          setState(() {});
          await ctrl.fetchAndSaveLyrics();
        } catch (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error Fetching: $e")));

          ctrl.setShowTrackMode(false);
        } finally {
          setState(() {});
          busyFeching = false;
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedPadding(
              padding: busyFeching
                  ? EdgeInsetsGeometry.all(20)
                  : EdgeInsetsGeometry.all(0),
              duration: Durations.long1,
              child: FutureBuilder(
                future: ctrl.image,
                builder: (c, s) {
                  return s.data ??
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Theme.of(context).secondaryHeaderColor,
                          ),
                          child: Icon(
                            Icons.music_note,
                            size: 300,
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                        ),
                      );
                },
              ),
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
            Text("Search", style: TextStyle(color: Colors.grey.withAlpha(100))),
          ],
        ),
      ),
    );
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
    if (ctrl.hasAccess) {
      return IconButton(onPressed: () {}, icon: Icon(Icons.search));
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.notifications_off, size: 80, color: Colors.grey),
        const SizedBox(height: 16),
        const Text("Enable Notification Access?"),
        ElevatedButton(
          onPressed: () => ctrl.openNotificationAccessSettings().then((c) {
            ctrl.rebuildUntil(() => ctrl.hasAccess);
          }),
          child: const Text("Grant Access"),
        ),
      ],
    );
  }

  void showDrawer() {}

  Widget buildDrawer() {
    return AppDrawer();
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            onTap: () => Provider.of<MusicController>(
              context,
              listen: false,
            ).setShowTrackMode(true),
            leading: Icon(Icons.play_arrow),
            title: Text("Now Playing"),
          ),
          ListTile(
            onTap: () => showAboutDialog(
              context: context,
              applicationVersion: packageInfo.version,
              children: [Text(packageInfo.installerStore ?? "")],
            ),
            leading: Icon(Icons.info),
            title: Text("About"),
          ),
        ],
      ),
    );
  }
}
