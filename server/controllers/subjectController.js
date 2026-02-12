const Subject = require('../models/Subject');

// Get all subjects for a user
exports.getSubjects = async (req, res) => {
    try {
        const { userId } = req.params;
        console.log('Fetching subjects for user:', userId);
        const subjects = await Subject.find({ userId });
        console.log('Found subjects:', subjects.length);
        res.json(subjects);
    } catch (error) {
        console.error('Get subjects error:', error);
        res.status(500).json({ message: 'Server error', error: error.message });
    }
};

// Create a new subject
exports.createSubject = async (req, res) => {
    try {
        console.log('Creating subject:', req.body);
        const { userId, name, year, instructor, room, color } = req.body;

        const newSubject = new Subject({
            userId,
            name,
            year,
            instructor,
            room,
            color
        });

        await newSubject.save();
        console.log('Subject created:', newSubject);
        res.status(201).json(newSubject);
    } catch (error) {
        console.error('Create subject error:', error);
        res.status(500).json({ message: 'Server error', error: error.message });
    }
};

// Update a subject
exports.updateSubject = async (req, res) => {
    try {
        const { subjectId } = req.params;
        const { name, year, instructor, room, color } = req.body;

        const subject = await Subject.findByIdAndUpdate(
            subjectId,
            { name, year, instructor, room, color },
            { new: true }
        );

        if (!subject) {
            return res.status(404).json({ message: 'Subject not found' });
        }

        res.json(subject);
    } catch (error) {
        console.error('Update subject error:', error);
        res.status(500).json({ message: 'Server error', error: error.message });
    }
};

// Delete a subject
exports.deleteSubject = async (req, res) => {
    try {
        const { subjectId } = req.params;

        const subject = await Subject.findByIdAndDelete(subjectId);

        if (!subject) {
            return res.status(404).json({ message: 'Subject not found' });
        }

        res.json({ message: 'Subject deleted successfully' });
    } catch (error) {
        console.error('Delete subject error:', error);
        res.status(500).json({ message: 'Server error', error: error.message });
    }
};
