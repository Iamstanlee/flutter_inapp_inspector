import 'package:flutter/material.dart';
import 'package:flutter_inapp_inspector/src/theme.dart';

import 'dashboard/dashboard_screen.dart';

const fabKey = Key('app_inspector_fab_btn');

/// The main widget for the App Inspector.
///
/// This widget adds a floating action button to the app that opens the
/// App Inspector dashboard when tapped.
class AppInspectorView extends StatefulWidget {
  const AppInspectorView({super.key});

  @override
  State<AppInspectorView> createState() => _AppInspectorViewState();
}

class _AppInspectorViewState extends State<AppInspectorView> {
  bool _isDashboardVisible = false;
  Offset? movedFabPosition;
  Offset initialFabPosition = const Offset(8, 44);
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    final Size mediaSize = MediaQuery.sizeOf(context);
    return Material(
      type: MaterialType.transparency,
      child: Theme(
        data: inspectorTheme(
            brightness: MediaQuery.platformBrightnessOf(context)),
        child: Stack(
          children: [
            // Dashboard
            if (_isDashboardVisible)
              Positioned.fill(
                child: Navigator(
                  key: _navigatorKey,
                  onGenerateRoute: (settings) {
                    return MaterialPageRoute(
                      builder: (context) => DashboardOverviewScreen(
                        onClose: _closeDashboard,
                      ),
                    );
                  },
                ),
              ),

            Positioned(
              left: movedFabPosition?.dx,
              top: movedFabPosition?.dy ?? initialFabPosition.dy,
              right:
                  movedFabPosition?.dx == null ? initialFabPosition.dx : null,
              child: Draggable(
                feedback: const Icon(
                  Icons.bug_report,
                  color: Colors.black,
                ),
                onDragEnd: (drag) {
                  setState(() {
                    late final double dx;
                    late final double dy;

                    if (drag.offset.dx >= (mediaSize.width / 2)) {
                      dx = mediaSize.width - 50;
                    } else {
                      dx = 0;
                    }

                    if (drag.offset.dy <= 0) {
                      dy = 24;
                    } else if (drag.offset.dy >= mediaSize.height - 100) {
                      dy = mediaSize.height - 100;
                    } else {
                      dy = drag.offset.dy;
                    }

                    movedFabPosition = Offset(dx, dy);
                  });
                },
                child: _isDashboardVisible
                    ? const SizedBox.shrink()
                    : _buildFloatingActionButton(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      key: fabKey,
      mini: true,
      onPressed: _toggleDashboard,
      backgroundColor: Colors.red,
      child: Icon(
        _isDashboardVisible ? Icons.logout : Icons.bug_report,
        color: Colors.white,
      ),
    );
  }

  void _toggleDashboard() {
    setState(() {
      _isDashboardVisible = !_isDashboardVisible;
    });
  }

  void _closeDashboard() {
    setState(() {
      _isDashboardVisible = false;
    });
  }
}
