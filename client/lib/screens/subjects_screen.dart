import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/subject.dart';
import '../providers/subject_provider.dart';
import '../providers/auth_provider.dart';

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
// Subjects will be managed by SubjectProvider

  void _addSubject() {
    showDialog(
      context: context,
      builder: (context) => AddSubjectDialog(
        onAdd: (subject) async {
          final auth = Provider.of<AuthProvider>(context, listen: false);
          if (auth.user != null) {
            await Provider.of<SubjectProvider>(context, listen: false).createSubject(subject, auth.user!.id);
            // Refresh list after creation
            Provider.of<SubjectProvider>(context, listen: false).fetchSubjects(auth.user!.id);
          }
        },
      ),
    );
  }

  void _editSubject(int index) {
    final subjectProvider = Provider.of<SubjectProvider>(context, listen: false);
    final subject = subjectProvider.subjects[index];
    showDialog(
      context: context,
      builder: (context) => AddSubjectDialog(
        subject: subject,
        onAdd: (updated) async {
          await subjectProvider.updateSubject(updated);
          final auth = Provider.of<AuthProvider>(context, listen: false);
          if (auth.user != null) {
            subjectProvider.fetchSubjects(auth.user!.id);
          }
        },
      ),
    );
  }

  void _deleteSubject(int index) {
    final subjectProvider = Provider.of<SubjectProvider>(context, listen: false);
    final subjectId = subjectProvider.subjects[index].id;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subject'),
        content: Text('Are you sure you want to delete ${subjectProvider.subjects[index].name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await subjectProvider.deleteSubject(subjectId);
              final auth = Provider.of<AuthProvider>(context, listen: false);
              if (auth.user != null) {
                subjectProvider.fetchSubjects(auth.user!.id);
              }
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subjectProvider = Provider.of<SubjectProvider>(context);
    final subjects = subjectProvider.subjects;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    // Fetch subjects if not loaded
    if (subjects.isEmpty && auth.user != null) {
      subjectProvider.fetchSubjects(auth.user!.id);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Subjects'),
        elevation: 0,
      ),
      body: subjects.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book_outlined, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('No subjects yet', style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
                  const SizedBox(height: 8),
                  Text('Tap + to add your first subject', style: TextStyle(color: Colors.grey.shade500)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                final subject = subjects[index];
                final color = Color(int.parse(subject.color.replaceFirst('#', '0xFF')));
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: color, width: 2),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: color.withOpacity(0.2),
                      child: Text(subject.name.substring(0, 1).toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(subject.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Year: ${subject.year}'),
                        if (subject.instructor != null) Text('Instructor: ${subject.instructor}'),
                        if (subject.room != null) Text('Room: ${subject.room}'),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      icon: const Icon(Icons.more_vert),
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 20), SizedBox(width: 8), Text('Edit')])),
                        const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 20, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          _editSubject(index);
                        } else if (value == 'delete') {
                          _deleteSubject(index);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addSubject,
        icon: const Icon(Icons.add),
        label: const Text('Add Subject'),
      ),
    );
  }
}

class AddSubjectDialog extends StatefulWidget {
  final Subject? subject;
  final Function(Subject) onAdd;

  const AddSubjectDialog({
    super.key,
    this.subject,
    required this.onAdd,
  });

  @override
  State<AddSubjectDialog> createState() => _AddSubjectDialogState();
}

class _AddSubjectDialogState extends State<AddSubjectDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _instructorController;
  late TextEditingController _roomController;
  String _selectedColor = '#2196F3';

  final List<String> _colors = [
    '#2196F3', // Blue
    '#4CAF50', // Green
    '#FF9800', // Orange
    '#9C27B0', // Purple
    '#F44336', // Red
    '#00BCD4', // Cyan
    '#FF5722', // Deep Orange
    '#3F51B5', // Indigo
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.subject?.name ?? '');
    _codeController = TextEditingController(text: widget.subject?.year ?? '');
    _instructorController = TextEditingController(text: widget.subject?.instructor ?? '');
    _roomController = TextEditingController(text: widget.subject?.room ?? '');
    _selectedColor = widget.subject?.color ?? '#2196F3';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _instructorController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final subject = Subject(
        id: widget.subject?.id ?? DateTime.now().toString(),
        name: _nameController.text,
        year: _codeController.text,
        instructor: _instructorController.text.isEmpty ? null : _instructorController.text,
        room: _roomController.text.isEmpty ? null : _roomController.text,
        color: _selectedColor,
      );
      widget.onAdd(subject);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.subject == null ? 'Add Subject' : 'Edit Subject'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Subject Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter subject name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Year/Class *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter year/class' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _instructorController,
                decoration: const InputDecoration(
                  labelText: 'Instructor (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _roomController,
                decoration: const InputDecoration(
                  labelText: 'Room (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Color', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _colors.map((color) {
                  final isSelected = color == _selectedColor;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.black : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
