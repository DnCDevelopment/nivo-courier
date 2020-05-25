import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StreamState extends StatelessWidget {
  final Widget _activeWidget;
  final AsyncSnapshot<DocumentSnapshot> _snapshot;

  StreamState(this._activeWidget, this._snapshot);

  @override
  Widget build(BuildContext context) {
    if (_snapshot.hasError) {
      return Text('Error: ${_snapshot.error}');
    }
    switch (_snapshot.connectionState) {
      case ConnectionState.none:
        return LinearProgressIndicator();
      case ConnectionState.waiting:
        return LinearProgressIndicator();
      case ConnectionState.active:
        return _activeWidget;
        break;
      case ConnectionState.done:
        return _activeWidget;
        break;
    }
    return null;
  }
}
