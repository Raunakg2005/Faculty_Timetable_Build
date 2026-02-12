const express = require('express');
const router = express.Router();
const slotController = require('../controllers/slotController');

router.get('/:userId', slotController.getSlots);
router.post('/', slotController.createSlot);
router.put('/:slotId', slotController.updateSlot);
router.delete('/:slotId', slotController.deleteSlot);

module.exports = router;
