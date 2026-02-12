const mongoose = require('mongoose');

const subjectSchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    name: {
        type: String,
        required: true
    },
    year: {
        type: String,
        required: true
    },
    instructor: String,
    room: String,
    color: {
        type: String,
        default: '#2196F3'
    }
}, { timestamps: true });

module.exports = mongoose.model('Subject', subjectSchema);
