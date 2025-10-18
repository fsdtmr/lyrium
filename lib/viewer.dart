import 'package:flutter/material.dart';
import 'package:lyrium/controller.dart';
import 'package:lyrium/editor.dart';
import 'package:lyrium/utils/clock.dart';
import 'package:lyrium/models.dart';
import 'package:lyrium/utils/duration.dart';
import 'package:lyrium/utils/lrc.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class LyricPlayerContainer extends StatelessWidget {
  const LyricPlayerContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicController>(
      builder: (context, controller, _) {
        final track = controller.lyrics;
        final isPlaying = controller.isPlaying;
        final atPosition = controller.progress;

        if (track == null) {
          return const Center(child: Text("No track selected"));
        }

        return LyricsView(
          lyrics: track,
          isPlaying: isPlaying,
          atPosition: atPosition,
          getPrimaryPosition: controller.position,
          togglePause: (b) => controller.togglePause(pause: b),
          seek: controller.seekTo,
          onSave: (LyricsTrack lyrics) async {},
        );
      },
    );
  }
}

class LyricsView extends StatefulWidget {
  final LyricsTrack? lyrics;
  final Future<void> Function(bool) togglePause;
  final Future<void> Function(Duration) seek;
  final Future<void> Function(LyricsTrack lyrics) onSave;
  final Future<Duration> Function() getPrimaryPosition;

  final bool isPlaying;
  final Duration? atPosition;
  const LyricsView({
    super.key,
    this.lyrics,
    required this.togglePause,
    required this.seek,
    required this.isPlaying,
    required this.atPosition,
    required this.onSave,
    required this.getPrimaryPosition,
  });

  @override
  State<LyricsView> createState() => _LyricsViewState();
}

class _LyricsViewState extends State<LyricsView> {
  late List<LRCLine>? lyrics;
  final ItemScrollController itemScrollController = ItemScrollController();

  late Duration duration = const Duration(seconds: 0);
  double position = 0.0;
  Duration newPosition = const Duration(seconds: 0);
  int lyindex = -1;
  late ClockManager watchManager;
  @override
  void initState()  {
    duration = widget.lyrics?.duration?.toDuration() ?? Duration.zero;

    lyrics = toLRCLineList(widget.lyrics?.syncedLyrics ?? "");

    watchManager = ClockManager((Duration elapsed) {
      if (mounted) {
        if (elapsed > duration) {
          elapsed = duration;
          watchManager.pause();
        }

        setState(() {
          newPosition = elapsed;
          position = elapsed.inMilliseconds / duration.inMilliseconds;

          lyindex = findlyric(newPosition);
        });
        scrollto(lyindex);
      }
    });
    Future.microtask(() async {
      watchManager.seek(await widget.getPrimaryPosition());
      if (widget.isPlaying) {
        watchManager.play(startfrom: widget.atPosition);
      }
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant LyricsView oldWidget) {
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (oldWidget.isPlaying != widget.isPlaying) {
        if (widget.isPlaying) {
          watchManager.play();
          watchManager.seek(widget.atPosition ?? watchManager.elapsed);
        } else {
          watchManager.pause();
          // Bug: seeking creates a invalid state
          // watchManager.seek(widget.atPosition ?? watchManager.elapsed);
        }
      }
    } else if (widget.atPosition != oldWidget.atPosition) {
      watchManager.seek(widget.atPosition ?? watchManager.elapsed);
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    if (lyrics == null || lyrics!.isEmpty) {
      return const Center(child: Text("No lyrics available"));
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (notification) {
            if (animating) {
              notification.disallowIndicator();
            }
            return true;
          },
          child: ScrollablePositionedList.separated(
            separatorBuilder: (context, index) => SizedBox(
              height: 20, // Space between lyrics lines
            ),
            itemScrollController: itemScrollController,
            itemCount: lyrics!.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  incrementLyric(index - lyindex);
                },

                child: Builder(
                  builder: (builder) {
                    final line = lyrics![index];

                    return AnimatedOpacity(
                      opacity: index == lyindex ? 1 : .5,
                      duration: Durations.short4,
                      child: Text(
                        line.text,
                        textScaler: TextScaler.linear(2),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),

      bottomNavigationBar: SizedBox(
        height: 120, // Increased height
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                SizedBox(width: 8.0),
                Text(
                  newPosition.toShortString(),
                  style: const TextStyle(fontSize: 12),
                ),
                Expanded(
                  child: Slider(value: position, onChanged: onSeeked),
                ),
                Text(
                  widget.lyrics?.duration.toShortString() ?? "-----",
                  style: const TextStyle(fontSize: 12),
                ),

                SizedBox(width: 8.0),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_note),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (c) => SimpleLyricEditor(
                          initial:
                              widget.lyrics?.syncedLyrics ??
                              widget.lyrics?.plainLyrics ??
                              "",
                        ),
                      ),
                    );
                  },
                ),
                Spacer(),
                IconButton(
                  icon: const Icon(Icons.fast_rewind),
                  onPressed: () {
                    incrementLyric(-1);
                  },
                ),
                IconButton(
                  icon: Icon(
                    watchManager.paused ? Icons.play_arrow : Icons.pause,
                  ),
                  onPressed: () {
                    watchManager.paused
                        ? watchManager.play()
                        : watchManager.pause();

                    widget.togglePause(watchManager.paused);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.fast_forward),
                  onPressed: () {
                    incrementLyric(1);
                  },
                ),

                Spacer(),

                IconButton(
                  onPressed: () => {},
                  icon: Icon(Icons.bookmark_outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void onSeeked(double value) {
    newPosition = duration * value;

    setState(() {
      position = value;

      lyindex = findlyric(newPosition);
    });

    watchManager.seek(newPosition);

    widget.seek(newPosition);
  }

  int prevIndex = 0;
  int findlyric(Duration newPosition) {
    if (lyrics == null || lyrics!.isEmpty) return -1;

    int left = 0;
    int right = lyrics!.length - 1;
    int resultIndex = 0;

    if (prevIndex >= 0 && prevIndex < lyrics!.length) {
      if (lyrics![prevIndex].timestamp <= newPosition) {
        left = prevIndex;
      } else {
        right = prevIndex;
      }
    }

    while (left <= right) {
      int mid = left + ((right - left) >> 1);
      if (lyrics![mid].timestamp <= newPosition) {
        resultIndex = mid;
        left = mid + 1;
      } else {
        right = mid - 1;
      }
    }

    prevIndex = resultIndex;

    return resultIndex;
  }

  void incrementLyric(int i) {
    var nextindex = (lyindex += i)
        .remainder(lyrics!.length)
        .clamp(0, lyrics!.length - 1);
    setState(() {
      lyindex = nextindex;
      newPosition = lyrics![lyindex].timestamp;
      position = newPosition.inMilliseconds / duration.inMilliseconds;
    });

    watchManager.seek(newPosition);

    widget.seek(newPosition);
  }

  int animatingto = -1;
  bool animating = false;

  void scrollto(int lyindex) {
    if (animatingto == lyindex) return;
    animating = true;

    if (!itemScrollController.isAttached) return;
    itemScrollController
        .scrollTo(index: lyindex, duration: Durations.short4, alignment: .3)
        .then((q) {
          animating = false;
        });

    animatingto = lyindex;
  }
}
