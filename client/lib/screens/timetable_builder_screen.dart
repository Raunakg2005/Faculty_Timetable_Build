import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/subject.dart';
import '../models/time_slot.dart';
import '../providers/auth_provider.dart';
import '../providers/subject_provider.dart';
import '../providers/slot_provider.dart';

class TimetableBuilderScreen extends StatefulWidget {
  const TimetableBuilderScreen({super.key});

  @override
  State<TimetableBuilderScreen> createState() => _TimetableBuilderScreenState();
}

class _TimetableBuilderScreenState extends State<TimetableBuilderScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch subjects and slots for the logged-in user
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final subjectProvider = Provider.of<SubjectProvider>(context, listen: false);
      final slotProvider = Provider.of<SlotProvider>(context, listen: false);
      if (authProvider.user != null) {
        subjectProvider.fetchSubjects(authProvider.user!.id);
        slotProvider.fetchSlots(authProvider.user!.id);
      }
    });
  }
  String _selectedDay = 'Monday';
  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  
  // Subjects loaded from SubjectProvider, Slots from SlotProvider

  void _addSlot() {
    showDialog(
      context: context,
      builder: (context) => AddSlotDialog(
        subjects: Provider.of<SubjectProvider>(context, listen: false).subjects,
        selectedDay: _selectedDay,
        onAdd: (slot) async {
          await Provider.of<SlotProvider>(context, listen: false).createSlot(slot, Provider.of<AuthProvider>(context, listen: false).user!.id);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable Builder'),
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
          
          // Slots List
          Expanded(
            child: Consumer<SlotProvider>(
              builder: (context, slotProvider, child) {
                final slots = slotProvider.slots.where((s) => s.day == _selectedDay).toList();
                
                if (slotProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (slots.isEmpty) {
                  return Center(
                    child: Text(
                      'No classes scheduled for $_selectedDay',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: slots.length,
                  itemBuilder: (context, index) {
                    final slot = slots[index];
                    final subject = slot.subject;
                    
                    if (subject == null) return const SizedBox.shrink();
                    
                    final color = Color(int.parse(subject.color.replaceFirst('#', '0xFF')));

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Container(
                          width: 4,
                          color: color,
                        ),
                        title: Text('${subject.name} (${subject.year})'),
                        subtitle: Text('${slot.startTime} - ${slot.endTime}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            slotProvider.deleteSlot(slot.id);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSlot,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddSlotDialog extends StatefulWidget {
  final List<Subject> subjects;
  final String selectedDay;
  final Function(TimeSlot) onAdd;

  const AddSlotDialog({
    super.key,
    required this.subjects,
    required this.selectedDay,
    required this.onAdd,
  });

  @override
  State<AddSlotDialog> createState() => _AddSlotDialogState();
}

class _AddSlotDialogState extends State<AddSlotDialog> {
  Subject? _selectedSubject;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  late String _day;

  @override
  void initState() {
    super.initState();
    _day = widget.selectedDay;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Class Slot'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<Subject>(
            value: _selectedSubject,
            hint: const Text('Select Subject'),
            items: widget.subjects.map((s) {
              return DropdownMenuItem(
                value: s,
                child: Text(s.name),
              );
            }).toList(),
            onChanged: (val) => setState(() => _selectedSubject = val),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  icon: const Icon(Icons.access_time),
                  label: Text(_startTime.format(context)),
                  onPressed: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _startTime,
                    );
                    if (time != null) setState(() => _startTime = time);
                  },
                ),
              ),
              const Text(' - '),
              Expanded(
                child: TextButton.icon(
                  icon: const Icon(Icons.access_time),
                  label: Text(_endTime.format(context)),
                  onPressed: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _endTime,
                    );
                    if (time != null) setState(() => _endTime = time);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedSubject == null ? null : () {
            final slot = TimeSlot(
              id: DateTime.now().toString(),
              day: _day, // In real app, pass selected day
              startTime: _startTime.format(context),
              endTime: _endTime.format(context),
              subject: _selectedSubject,
            );
            widget.onAdd(slot);
            Navigator.pop(context);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
