const express = require('express');
const router = express.Router();
const subjectController = require('../controllers/subjectController');

router.get('/:userId', subjectController.getSubjects);
router.post('/', subjectController.createSubject);
router.put('/:subjectId', subjectController.updateSubject);
router.delete('/:subjectId', subjectController.deleteSubject);

module.exports = router;
