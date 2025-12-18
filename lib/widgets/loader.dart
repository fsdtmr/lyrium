import 'package:flutter/material.dart';

class LoaderWidget<T> extends StatelessWidget {
  final Future<T> future;
  final Route Function(T? result) onRoute;
  final Widget Function(BuildContext context, ConnectionState connectionState)
  onConnection;
  final Widget Function(BuildContext context, Object? error) onError;

  const LoaderWidget({
    super.key,
    required this.future,
    required this.onRoute,
    required this.onConnection,
    required this.onError,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<T>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.connectionState == ConnectionState.done) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(context, onRoute(snapshot.data));
            });
            return Container();
          } else if (snapshot.hasError) {
            return onError(context, snapshot.error);
          } else {
            return Center(child: Text("Unexpected state"));
          }
        },
      ),
    );
  }
}
