const express = require('express');
const router = express.Router();
const taskController = require('../controllers/taskController');

router.get('/:userId', taskController.getTasks);
router.post('/', taskController.createTask);
router.put('/:taskId', taskController.updateTask);
router.post('/:taskId/respond', taskController.respondToTask);

module.exports = router;
