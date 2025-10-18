import 'package:flutter/material.dart';
import 'package:lyrium/datahelper.dart';
import 'package:lyrium/models.dart';

void showLyricsSheet(BuildContext context, LyricsTrack song) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (context, ctrl) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            song.artist,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          DataHelper.instance.delete(song).then((c) {
                            if (c == song.id) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Deleted')),
                              );
                            }
                          }),
                      icon: const Icon(Icons.delete),
                      tooltip: 'Delete',
                    ),
                    IconButton(
                      onPressed: () =>
                          DataHelper.instance.saveTrack(song, null).then((c) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Saved')),
                            );
                          }),
                      icon: const Icon(Icons.save),
                      tooltip: 'Save',
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      tooltip: 'Close',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    controller: ctrl,
                    child: Text(
                      song.lyrics,
                      style: const TextStyle(height: 1.45, fontSize: 15),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      );
    },
  );
}

extension on LyricsTrack {
  String get lyrics => syncedLyrics ?? plainLyrics ?? "";

  String get title => trackName;

  String get artist => artistName ?? "";
}
