import 'package:call_log/call_log.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:permission_handler/permission_handler.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  int _scrollCount = 0;
  int _tapCount = 0;
  List<CallLogEntry> _callLogs = [];
  final User? _user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final Iterable<CallLogEntry> entries = await CallLog.query();
    _callLogs = entries.toList();

    // Load touch stats from Firebase
    if (_user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user.uid)
          .collection('activityLogs')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (doc.docs.isNotEmpty) {
        final data = doc.docs.first.data();
        setState(() {
          _scrollCount = data['scrollCount'] ?? 0;
          _tapCount = data['tapCount'] ?? 0;
        });
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracking Dashboard'),
        actions: [
          IconButton(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Touch Input Stats',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatCard('Scrolls', _scrollCount.toString()),
                          _buildStatCard('Taps', _tapCount.toString()),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Call Logs',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      if (_callLogs.isEmpty)
                        const Text('No call logs available')
                      else
                        ..._callLogs.take(10).map((log) => _buildCallLogItem(log)).toList(),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildCallLogItem(CallLogEntry log) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(log.timestamp ?? 0);
    final formattedDate = DateFormat('MMM dd, yyyy hh:mm a').format(dateTime);
    final callType = _getCallType(log.callType);
    final duration = Duration(seconds: log.duration ?? 0);

    return ListTile(
      leading: Icon(_getCallTypeIcon(log.callType)),
      title: Text(log.name ?? log.number ?? 'Unknown'),
      subtitle: Text(formattedDate),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(callType),
          Text('${duration.inMinutes}m ${duration.inSeconds.remainder(60)}s')
        ],
      ),
    );
  }

  String _getCallType(CallType? callType) {
    switch (callType) {
      case CallType.incoming:
        return 'Incoming';
      case CallType.outgoing:
        return 'Outgoing';
      case CallType.missed:
        return 'Missed';
      default:
        return 'Unknown';
    }
  }

  IconData _getCallTypeIcon(CallType? callType) {
    switch (callType) {
      case CallType.incoming:
        return Icons.call_received;
      case CallType.outgoing:
        return Icons.call_made;
      case CallType.missed:
        return Icons.call_missed;
      default:
        return Icons.call;
    }
  }
}