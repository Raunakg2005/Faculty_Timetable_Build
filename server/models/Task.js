const mongoose = require('mongoose');

const taskSchema = new mongoose.Schema({
    creatorId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    title: { type: String, required: true },
    description: { type: String },
    type: { type: String, enum: ['Personal', 'Group'], required: true },
    dueDate: { type: Date },
    isCompleted: { type: Boolean, default: false },

    // For Group Tasks
    assignedTo: [{
        userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
        status: { type: String, enum: ['Pending', 'Accepted', 'Rejected'], default: 'Pending' },
        isCompleted: { type: Boolean, default: false }
    }]
}, { timestamps: true });

module.exports = mongoose.model('Task', taskSchema);
