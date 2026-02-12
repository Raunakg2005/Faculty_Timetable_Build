const Session = require('../models/Session');

// Get all sessions for a user
exports.getSessions = async (req, res) => {
    try {
        const { userId } = req.params;
        const sessions = await Session.find({ userId });
        res.json(sessions);
    } catch (error) {
        res.status(500).json({ message: 'Server error', error: error.message });
    }
};

// Create a new session
exports.createSession = async (req, res) => {
    try {
        const { userId, title, type, dayOfWeek, startTime, duration, location } = req.body;
        const newSession = new Session({
            userId,
            title,
            type,
            dayOfWeek,
            startTime,
            duration,
            location
        });
        await newSession.save();
        res.status(201).json(newSession);
    } catch (error) {
        res.status(500).json({ message: 'Server error', error: error.message });
    }
};

// Update attendance
exports.updateAttendance = async (req, res) => {
    try {
        const { sessionId } = req.params;
        const { date, status } = req.body;

        const session = await Session.findById(sessionId);
        if (!session) return res.status(404).json({ message: 'Session not found' });

        session.attendance.push({ date, status });
        await session.save();
        res.json(session);
    } catch (error) {
        res.status(500).json({ message: 'Server error', error: error.message });
    }
};
