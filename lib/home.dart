import 'package:flutter/material.dart';
import 'package:lyrium/controller.dart';
import 'package:lyrium/service/service.dart';
import 'package:lyrium/widgets/lyrics_sheet.dart';
import 'package:provider/provider.dart';
import 'package:lyrium/viewer.dart';
import 'package:lyrium/search.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<MusicController>();

    return Scaffold(
      appBar: ctrl.lyrics == null
          ? ctrl.hasAccess
                ? null
                : AppBar(
                    title: GestureDetector(
                      onTap: () => _openSearchDialog(context),
                      child: Text("Search lyrics"),
                    ),
                  )
          : AppBar(
              title: GestureDetector(
                onTap: () => _openSearchDialog(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ctrl.info?.trackName ?? "",
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      ctrl.info?.artistName ?? "",
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(5),
                child: LinearProgressIndicator(value: ctrl.progressValue),
              ),
            ),
      body: AnimatedOpacity(
        opacity: 1,
        duration: Durations.medium4,
        child: Center(
          child: Builder(
            builder: (c) {
              if (!ctrl.isReady || ctrl.hasAccess) {
                return AnimatedCrossFade(
                  crossFadeState: ctrl.isReady
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: Durations.long1,
                  firstChild: LinearProgressIndicator(),

                  secondChild: AnimatedCrossFade(
                    firstChild: ctrl.info == null
                        ? _buildNoMusic()
                        : _buildFetcher(context, ctrl),
                    secondChild: _buildViewer(context, ctrl),
                    crossFadeState: ctrl.lyrics == null
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    duration: Durations.long1,
                  ),
                );
              } else {
                return _buildAccessRequired(context, ctrl);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNoMusic() => const Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.music_note, size: 80, color: Colors.deepPurple),
      SizedBox(height: 16),
      Text(
        'No Music Playing',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 8),
      Text('Start playing a song to see info here.'),
    ],
  );

  Widget _buildFetcher(BuildContext context, MusicController ctrl) {
    return GestureDetector(
      onDoubleTap: () => _openSearchDialog(context),
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

  Widget _buildViewer(BuildContext context, MusicController ctrl) {
    return LyricPlayerContainer();
  }

  Widget _buildAccessRequired(BuildContext context, MusicController? ctrl) {
    if (ctrl == null) {
      return LinearProgressIndicator();
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.notifications_off, size: 80, color: Colors.grey),
        const SizedBox(height: 16),
        const Text("Notification Access Required"),
        ElevatedButton(
          onPressed: ctrl.openNotificationAccessSettings,
          child: const Text("Grant Access"),
        ),
      ],
    );
  }

  Future<void> _openSearchDialog(BuildContext context) async {
    final ctrl = context.read<MusicController>();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: SearchSelector(
            initailQuery: ctrl.info,
            onResultSelected: (result, mode) async {
              if (!ctrl.hasAccess) {
                showLyricsSheet(context, result);

                return;
              }
              final confirmed = !mode
                  ? false
                  : await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Are you sure?"),
                          content: const Text("Do you want to overwrite?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text("Yes"),
                            ),
                          ],
                        );
                      },
                    );

              if (confirmed == true) {
                await ctrl.saveLyrics(result);
              } else {
                ctrl.setLyrics(result);
              }
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    );
  }
}
