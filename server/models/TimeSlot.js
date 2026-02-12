const mongoose = require('mongoose');

const timeSlotSchema = new mongoose.Schema({
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    day: { type: String, required: true }, // e.g., 'Monday'
    startTime: { type: String, required: true }, // store as string like '09:00'
    endTime: { type: String, required: true },
    subjectId: { type: mongoose.Schema.Types.ObjectId, ref: 'Subject', required: true },
}, { timestamps: true });

module.exports = mongoose.model('TimeSlot', timeSlotSchema);
