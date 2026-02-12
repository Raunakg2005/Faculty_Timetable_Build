import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/task_provider.dart';
import '../providers/slot_provider.dart';
import '../providers/auth_provider.dart';

class SchedulerScreen extends StatefulWidget {
  const SchedulerScreen({super.key});

  @override
  State<SchedulerScreen> createState() => _SchedulerScreenState();
}

class _SchedulerScreenState extends State<SchedulerScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch slots and tasks when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final slotProvider = Provider.of<SlotProvider>(context, listen: false);
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      if (authProvider.user != null) {
        slotProvider.fetchSlots(authProvider.user!.id);
        taskProvider.fetchTasks(authProvider.user!.id);
      }
    });
  }

  int _parseTime(String timeStr) {
    try {
      final isPm = timeStr.toUpperCase().contains('PM');
      final isAm = timeStr.toUpperCase().contains('AM');
      
      final cleanTime = timeStr.replaceAll(RegExp(r'[a-zA-Z\s]'), '');
      final parts = cleanTime.split(':');
      
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      
      if (isPm && hour != 12) hour += 12;
      if (isAm && hour == 12) hour = 0;
      
      return hour * 60 + minute;
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final slotProvider = Provider.of<SlotProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final todayName = DateFormat('EEEE').format(DateTime.now());
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    
    // Filter slots for today
    final todaySlots = slotProvider.slots
        .where((s) => s.day == todayName)
        .toList();
    
    // Filter tasks due today
    final todayTasks = taskProvider.tasks
        .where((t) {
          if (t.dueDate == null) return false;
          final dueDate = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
          return dueDate.isAtSameMomentAs(todayDate) && !t.isCompleted;
        })
        .toList();
    
    // Sort slots by start time
    todaySlots.sort((a, b) {
      return _parseTime(a.startTime).compareTo(_parseTime(b.startTime));
    });
    
    final hasItems = todaySlots.isNotEmpty || todayTasks.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text("Today's Schedule - $todayName"),
        elevation: 0,
      ),
      body: slotProvider.isLoading || taskProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : !hasItems
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 80,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nothing scheduled today!',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enjoy your free time 🎉',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Classes Section
                    if (todaySlots.isNotEmpty) ...[
                      const Text(
                        'Classes',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...todaySlots.map((slot) {
                        final subject = slot.subject;
                        if (subject == null) return const SizedBox.shrink();
                        
                        final color = Color(int.parse(subject.color.replaceFirst('#', '0xFF')));

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: color.withOpacity(0.5), width: 1),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  color.withOpacity(0.1),
                                  Colors.white,
                                ],
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        slot.startTime,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Container(
                                        height: 30,
                                        width: 2,
                                        color: color.withOpacity(0.3),
                                        margin: const EdgeInsets.symmetric(vertical: 4),
                                      ),
                                      Text(
                                        slot.endTime,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          subject.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.class_, size: 14, color: Colors.grey.shade700),
                                            const SizedBox(width: 4),
                                            Text(subject.year, style: TextStyle(color: Colors.grey.shade700)),
                                            if (subject.room != null) ...[
                                              const SizedBox(width: 12),
                                              Icon(Icons.location_on, size: 14, color: Colors.grey.shade700),
                                              const SizedBox(width: 4),
                                              Text(subject.room!, style: TextStyle(color: Colors.grey.shade700)),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                    
                    // Tasks Section
                    if (todayTasks.isNotEmpty) ...[
                      if (todaySlots.isNotEmpty) const SizedBox(height: 24),
                      const Text(
                        'Tasks for Today',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...todayTasks.map((task) {
                        final isPersonal = task.type == 'Personal';
                        final color = isPersonal ? Colors.orange : Colors.purple;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: color.withOpacity(0.5), width: 2),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  color.withOpacity(0.15),
                                  Colors.white,
                                ],
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: color.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          isPersonal ? Icons.person : Icons.group,
                                          color: color,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              task.title,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: color,
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    task.type,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                if (!isPersonal && task.assignedTo.isNotEmpty) ...[
                                                  const SizedBox(width: 8),
                                                  Icon(
                                                    Icons.people,
                                                    size: 14,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${task.assignedTo.length} members',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey.shade600,
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.assignment_outlined,
                                        color: color,
                                        size: 28,
                                      ),
                                    ],
                                  ),
                                  if (task.description.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Text(
                                      task.description,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade700,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                  if (task.creatorId != null) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.person_outline,
                                          size: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Created by ${task.creatorId!.username}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ],
                ),
    );
  }
}
