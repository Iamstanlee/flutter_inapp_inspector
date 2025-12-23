import 'package:flutter/material.dart';
import 'package:flutter_inapp_inspector/src/feature_flag/feature_flag_inspector_screen.dart';
import 'package:flutter_inapp_inspector/src/http/request_inspector_screen.dart';
import 'package:flutter_inapp_inspector/src/log/log_inspector_screen.dart';
import 'package:flutter_inapp_inspector/src/storage/storage_inspector_screen.dart';

/// The main dashboard screen for the App Inspector.
///
/// This screen contains tabs for "Requests", "Storage", "Bloc", "Navigation", and "Logs".
class DashboardOverviewScreen extends StatefulWidget {
  final VoidCallback onClose;

  const DashboardOverviewScreen({
    required this.onClose,
    super.key,
  });

  @override
  State<DashboardOverviewScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardOverviewScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('APP INSPECTOR'),
        actions: [
          IconButton(
            onPressed: widget.onClose,
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
              size: 20,
            ),
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.http),
              text: 'Requests',
            ),
            Tab(
              icon: Icon(Icons.data_usage),
              text: 'Logs',
            ),
            // Tab(
            //   icon: Icon(Icons.navigation),
            //   text: 'Navigation',
            // ),
            Tab(
              icon: Icon(Icons.dataset_rounded),
              text: 'Storage',
            ),
            Tab(icon: Icon(Icons.flag), text: 'Flags'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          RequestInspectorScreen(),
          LogInspectorScreen(),
          // NavigationInspectorScreen(),
          StorageInspectorScreen(),
          FeatureFlagInspectorScreen(),
        ],
      ),
    );
  }
}
