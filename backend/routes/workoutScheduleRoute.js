const WorkoutSchedule = require('../models/workoutScheduleModel'); 

const express = require('express');
const router = express.Router();

router.get('/:uid', async (req, res) => {
    try {
        const schedules = await WorkoutSchedule.find({ uid: req.params.uid });
        res.json(schedules);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});
  
  // Add a new workout schedule
router.post('/', async (req, res) => {
    const { day, difficulty, hour, name, repeatInterval, uid, id_notify } = req.body;

    const workoutSchedule = new WorkoutSchedule({
        id: new mongoose.Types.ObjectId(),
        uid,
        name,
        day,
        hour,
        difficulty,
        notify: true,
        repeatInterval,
        id_notify,
    });

    try {
        const newSchedule = await workoutSchedule.save();
        res.status(201).json(newSchedule); // Send back the newly created workout schedule
    } catch (err) {
        res.status(400).json({ message: err.message });
    }
});

// Update a workout schedule by ID
router.put('/:id', async (req, res) => {
    try {
        const schedule = await WorkoutSchedule.findById(req.params.id);

        if (!schedule) {
            return res.status(404).json({ message: 'Workout schedule not found' });
        }

        schedule.difficulty = req.body.difficulty || schedule.difficulty;
        schedule.hour = req.body.hour || schedule.hour;
        schedule.name = req.body.name || schedule.name;
        schedule.repeatInterval = req.body.repeatInterval || schedule.repeatInterval;

        const updatedSchedule = await schedule.save();
        res.json(updatedSchedule); // Send back the updated workout schedule
    } catch (err) {
        res.status(400).json({ message: err.message });
    }
});

// Delete a workout schedule by ID
router.delete('/:id', async (req, res) => {
    try {
        const schedule = await WorkoutSchedule.findById(req.params.id);

        if (!schedule) {
            return res.status(404).json({ message: 'Workout schedule not found' });
        }

        await schedule.remove();
        res.json({ message: 'Workout schedule deleted' });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});



module.exports = router;