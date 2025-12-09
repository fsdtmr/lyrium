import 'package:flutter/material.dart';
import 'package:lyrium/controller.dart';
import 'package:lyrium/widgets/settings.dart';
import 'package:provider/provider.dart';

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
          // ListTile(
          //   onTap: () => shareDB(),
          //   leading: Icon(Icons.import_export),
          //   title: Text("Export"),
          // ),
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

  void shareDB() {
    // SharePlus.instance.share(ShareParams(files: [
    //   D
    //   XFile(path)
    // ]));
  }
}
