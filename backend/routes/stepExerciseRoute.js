const StepExercise = require('../models/stepExerciseModel'); 

const express = require('express');
const router = express.Router();

// Fetch all step exercises
router.get('/', async (req, res) => {
    try {
        const stepExercises = await StepExercise.find();
        res.json(stepExercises);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});
  
  // Add a new step exercise
router.post('/', async (req, res) => {
    const { name, step, title, detail } = req.body;

    const stepExercise = new StepExercise({
        name,
        step,
        title,
        detail,
    });

    try {
        const newStepExercise = await stepExercise.save();
        res.status(201).json(newStepExercise); // Send back the newly created step exercise
    } catch (err) {
        res.status(400).json({ message: err.message });
    }
});
  
  // Update a step exercise by ID
router.put('/:id', async (req, res) => {
    try {
        const stepExercise = await StepExercise.findById(req.params.id);
        if (!stepExercise) return res.status(404).json({ message: 'Step Exercise not found' });
    
        stepExercise.name = req.body.name ?? stepExercise.name;
        stepExercise.step = req.body.step ?? stepExercise.step;
        stepExercise.title = req.body.title ?? stepExercise.title;
        stepExercise.detail = req.body.detail ?? stepExercise.detail;
    
        const updatedStepExercise = await stepExercise.save();
        res.json(updatedStepExercise); // Send back the updated step exercise
    } catch (err) {
        res.status(400).json({ message: err.message });
    }
});
  
  // Delete a step exercise by ID
router.delete('/:id', async (req, res) => {
    try {
        const stepExercise = await StepExercise.findById(req.params.id);
        if (!stepExercise) return res.status(404).json({ message: 'Step Exercise not found' });
    
        await stepExercise.remove();
        res.json({ message: 'Step Exercise deleted' });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

router.get('/:name', async (req, res) => {
    try {
        const name = req.params.name;
    
        const stepExercises = await StepExercise.find({ name: name }).sort('step');
    
        res.json(stepExercises);
    } catch (err) {
        console.error("Error fetching step exercises:", err);
        res.status(500).json({ message: "Error fetching step exercises" });
    }
});

module.exports = router;