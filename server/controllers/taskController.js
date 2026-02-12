const Task = require('../models/Task');

// Get tasks for a user (Personal and Group tasks where they are involved)
exports.getTasks = async (req, res) => {
    try {
        const { userId } = req.params;
        const tasks = await Task.find({
            $or: [
                { creatorId: userId }, // Created by user
                { 'assignedTo.userId': userId } // Assigned to user
            ]
        }).populate('creatorId', 'username email').populate('assignedTo.userId', 'username email');
        res.json(tasks);
    } catch (error) {
        res.status(500).json({ message: 'Server error', error: error.message });
    }
};

// Create a new task
exports.createTask = async (req, res) => {
    try {
        const { creatorId, title, description, type, dueDate, assignedTo } = req.body;

        const newTask = new Task({
            creatorId,
            title,
            description,
            type,
            dueDate,
            assignedTo: type === 'Group' ? assignedTo : [] // Only add assignees if group task
        });

        await newTask.save();
        res.status(201).json(newTask);
    } catch (error) {
        res.status(500).json({ message: 'Server error', error: error.message });
    }
};

// Update task status (for personal tasks or creator updating group task)
exports.updateTask = async (req, res) => {
    try {
        const { taskId } = req.params;
        const updates = req.body;

        const task = await Task.findByIdAndUpdate(taskId, updates, { new: true });
        if (!task) return res.status(404).json({ message: 'Task not found' });

        res.json(task);
    } catch (error) {
        res.status(500).json({ message: 'Server error', error: error.message });
    }
};

// Accept or Reject a group task assignment
exports.respondToTask = async (req, res) => {
    try {
        const { taskId } = req.params;
        const { userId, status } = req.body; // status: 'Accepted' or 'Rejected'

        const task = await Task.findById(taskId);
        if (!task) return res.status(404).json({ message: 'Task not found' });

        const assignment = task.assignedTo.find(a => a.userId.toString() === userId);
        if (!assignment) return res.status(404).json({ message: 'User not assigned to this task' });

        assignment.status = status;
        await task.save();

        res.json(task);
    } catch (error) {
        res.status(500).json({ message: 'Server error', error: error.message });
    }
};
