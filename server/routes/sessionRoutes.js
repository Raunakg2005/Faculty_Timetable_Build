const express = require('express');
const router = express.Router();
const sessionController = require('../controllers/sessionController');

router.get('/:userId', sessionController.getSessions);
router.post('/', sessionController.createSession);
router.post('/:sessionId/attendance', sessionController.updateAttendance);

module.exports = router;
