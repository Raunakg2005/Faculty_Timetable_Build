const Slot = require('../models/TimeSlot');

// Get slots for a user
exports.getSlots = async (req, res) => {
    try {
        const { userId } = req.params;
        console.log('Fetching slots for user:', userId);
        const slots = await Slot.find({ userId }).populate('subjectId');
        console.log('Found slots:', slots.length);
        res.json(slots);
    } catch (error) {
        console.error('Get slots error:', error);
        res.status(500).json({ message: 'Server error', error: error.message });
    }
};

// Create a new slot
exports.createSlot = async (req, res) => {
    try {
        console.log('Creating slot:', req.body);
        const { userId, day, startTime, endTime, subjectId } = req.body;
        const newSlot = new Slot({ userId, day, startTime, endTime, subjectId });
        await newSlot.save();
        console.log('Slot created:', newSlot);
        await newSlot.populate('subjectId');
        res.status(201).json(newSlot);
    } catch (error) {
        console.error('Create slot error:', error);
        res.status(500).json({ message: 'Server error', error: error.message });
    }
};

// Update a slot
exports.updateSlot = async (req, res) => {
    try {
        const { slotId } = req.params;
        const { day, startTime, endTime, subjectId } = req.body;
        const slot = await Slot.findByIdAndUpdate(
            slotId,
            { day, startTime, endTime, subjectId },
            { new: true }
        ).populate('subjectId');
        if (!slot) {
            return res.status(404).json({ message: 'Slot not found' });
        }
        res.json(slot);
    } catch (error) {
        console.error('Update slot error:', error);
        res.status(500).json({ message: 'Server error', error: error.message });
    }
};

// Delete a slot
exports.deleteSlot = async (req, res) => {
    try {
        const { slotId } = req.params;
        const slot = await Slot.findByIdAndDelete(slotId);
        if (!slot) {
            return res.status(404).json({ message: 'Slot not found' });
        }
        res.json({ message: 'Slot deleted successfully' });
    } catch (error) {
        console.error('Delete slot error:', error);
        res.status(500).json({ message: 'Server error', error: error.message });
    }
};
