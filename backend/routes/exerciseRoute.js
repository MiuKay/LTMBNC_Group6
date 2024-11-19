const Exercise = require('../models/excerciseModel');

const express = require('express');
const router = express.Router();

router.get('/', async (req, res) => {
    try {
        const exercises = await Exercise.find();
        res.json(exercises);
    } catch (err) {
        res.status(500).json({ message: err.message }); 
    }
});
  
  // Add a new exercise
router.post('/', async (req, res) => {
    const { calo, descriptions, difficulty, name, pic, rep, time, video } = req.body;

    const exercise = new Exercise({
        calo,
        descriptions,
        difficulty,
        name,
        pic,
        rep,
        time,
        video,
    });

    try {
        const newExercise = await exercise.save();
        res.status(201).json(newExercise); // Send back the newly created exercise
    } catch (err) {
        res.status(400).json({ message: err.message });
    }
});

// Update an exercise by ID
router.put('/:id', async (req, res) => {
    try {
        const exercise = await Exercise.findById(req.params.id);
        if (!exercise) return res.status(404).json({ message: 'Exercise not found' });

        exercise.calo = req.body.calo || exercise.calo;
        exercise.descriptions = req.body.descriptions || exercise.descriptions;
        exercise.difficulty = req.body.difficulty || exercise.difficulty;
        exercise.name = req.body.name || exercise.name;
        exercise.pic = req.body.pic || exercise.pic;
        exercise.rep = req.body.rep || exercise.rep;
        exercise.time = req.body.time || exercise.time;
        exercise.video = req.body.video || exercise.video;

        const updatedExercise = await exercise.save();
        res.json(updatedExercise); // Send back the updated exercise
    } catch (err) {
        res.status(400).json({ message: err.message });
    }
});

// Delete an exercise by ID
router.delete('/:id', async (req, res) => {
    try {
        const exercise = await Exercise.findById(req.params.id);
        if (!exercise) return res.status(404).json({ message: 'Exercise not found' });

        await exercise.remove();
        res.json({ message: 'Exercise deleted' });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});



module.exports = router;