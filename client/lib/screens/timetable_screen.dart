import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/session_provider.dart';
import '../providers/auth_provider.dart';
import 'create_session_screen.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  _TimetableScreenState createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  @override
  void initState() {
    super.initState();
    final userId = Provider.of<AuthProvider>(context, listen: false).user?.id;
    if (userId != null) {
      Provider.of<SessionProvider>(context, listen: false).fetchSessions(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessions = Provider.of<SessionProvider>(context).sessions;

    return Scaffold(
      body: ListView.builder(
        itemCount: sessions.length,
        itemBuilder: (context, index) {
          final session = sessions[index];
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              leading: Icon(session.type == 'Lecture' ? Icons.book : Icons.computer),
              title: Text(session.title),
              subtitle: Text('${session.dayOfWeek} - ${session.startTime} (${session.duration}h)\n${session.location}'),
              trailing: IconButton(
                icon: Icon(Icons.check),
                onPressed: () async {
                  try {
                    await Provider.of<SessionProvider>(context, listen: false).markAttendance(
                      session.id,
                      DateTime.now(),
                      'Present',
                    );
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Attendance marked!')));
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => CreateSessionScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
