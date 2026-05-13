const express = require('express');
const router = express.Router();
const workoutController = require('../controllers/workoutController');
const auth = require('../middleware/auth');

router.post('/save', auth, workoutController.saveWorkout);
router.get('/history/:userId', auth, workoutController.getWorkoutHistory);
router.get('/stats/:userId', auth, workoutController.getWorkoutStats);
router.delete('/:id', auth, workoutController.deleteWorkout);

module.exports = router;