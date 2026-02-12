const mongoose = require('mongoose');

const sessionSchema = new mongoose.Schema({
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    title: { type: String, required: true },
    type: { type: String, enum: ['Lecture', 'Lab'], required: true },
    dayOfWeek: { type: String, required: true }, // e.g., 'Monday'
    startTime: { type: String, required: true }, // e.g., '10:00'
    duration: { type: Number, required: true }, // in hours (1 for Lecture, 2 for Lab)
    location: { type: String },
    attendance: [{
        date: { type: Date },
        status: { type: String, enum: ['Present', 'Absent', 'Cancelled'], default: 'Present' }
    }]
}, { timestamps: true });

module.exports = mongoose.model('Session', sessionSchema);
