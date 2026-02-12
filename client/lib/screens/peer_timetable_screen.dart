import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class PeerTimetableScreen extends StatefulWidget {
  final String userId;
  final String username;

  const PeerTimetableScreen({
    super.key,
    required this.userId,
    required this.username,
  });

  @override
  State<PeerTimetableScreen> createState() => _PeerTimetableScreenState();
}

class _PeerTimetableScreenState extends State<PeerTimetableScreen> {
  List<dynamic> _slots = [];
  bool _isLoading = true;
  String _selectedDay = DateFormat('EEEE').format(DateTime.now());
  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  @override
  void initState() {
    super.initState();
    _fetchSlots();
  }

  Future<void> _fetchSlots() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.get('/slots/${widget.userId}');
      if (mounted) {
        setState(() {
          _slots = data as List;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load timetable: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final daySlots = _slots.where((slot) => slot['day'] == _selectedDay).toList();
    // Sort by start time
    daySlots.sort((a, b) {
      final aTime = a['startTime'] as String;
      final bTime = b['startTime'] as String;
      return aTime.compareTo(bTime);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.username}'s Timetable"),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Day Selector
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _days.length,
              itemBuilder: (context, index) {
                final day = _days[index];
                final isSelected = day == _selectedDay;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(day),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedDay = day);
                    },
                  ),
                );
              },
            ),
          ),
          
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : daySlots.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 64,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No classes on $_selectedDay',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchSlots,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: daySlots.length,
                          itemBuilder: (context, index) {
                            final slot = daySlots[index];
                            final subject = slot['subjectId'];
                            
                            // Parse color from subject or use default
                            Color cardColor = Colors.blue;
                            if (subject != null && subject['color'] != null) {
                              try {
                                final colorString = subject['color'] as String;
                                cardColor = Color(int.parse(colorString.replaceFirst('#', '0xFF')));
                              } catch (e) {
                                cardColor = Colors.blue;
                              }
                            }

                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: cardColor.withOpacity(0.5), width: 2),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      cardColor.withOpacity(0.1),
                                      Colors.white,
                                    ],
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      // Time Column
                                      Column(
                                        children: [
                                          Text(
                                            slot['startTime'] ?? '',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Container(
                                            height: 40,
                                            width: 2,
                                            color: cardColor.withOpacity(0.3),
                                            margin: const EdgeInsets.symmetric(vertical: 4),
                                          ),
                                          Text(
                                            slot['endTime'] ?? '',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 24),
                                      // Subject Details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              subject?['name'] ?? 'Unknown Subject',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            if (subject?['year'] != null) ...[
                                              Row(
                                                children: [
                                                  Icon(Icons.school, 
                                                    size: 16, 
                                                    color: Colors.grey.shade700
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    subject['year'],
                                                    style: TextStyle(
                                                      color: Colors.grey.shade700,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                            ],
                                            if (subject?['instructor'] != null) ...[
                                              Row(
                                                children: [
                                                  Icon(Icons.person, 
                                                    size: 16, 
                                                    color: Colors.grey.shade700
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    subject['instructor'],
                                                    style: TextStyle(
                                                      color: Colors.grey.shade700,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                            ],
                                            if (subject?['room'] != null) ...[
                                              Row(
                                                children: [
                                                  Icon(Icons.location_on, 
                                                    size: 16, 
                                                    color: Colors.grey.shade700
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    subject['room'],
                                                    style: TextStyle(
                                                      color: Colors.grey.shade700,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
