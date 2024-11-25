const WorkoutHistory = require('../models/workoutHistoryModel');
const CategoryWorkout = require('../models/categoryWorkoutModel');

const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');

router.post('/', async (req, res) => {
    try {
        const { uid, idCate, exercisesArr, difficulty } = req.body;

        const idCateObjectId = mongoose.Types.ObjectId(idCate);
        const exercisesArrObjectIds = exercisesArr.map(id => mongoose.Types.ObjectId(id));

        const newHistory = new WorkoutHistory({
            _id: new mongoose.Types.ObjectId().toString(),
            uid,
            id_cate: idCateObjectId,
            exercisesArr: exercisesArrObjectIds,
            index: 0,
            duration: 0,
            caloriesBurned: 0,
            completedAt: null,
            difficulty,
        });

        await newHistory.save();

        res.json({ id: newHistory._id });
    } catch (err) {
        console.error("Error creating workout history:", err);
        res.status(500).json({ message: "Error creating workout history" });
    }
})

// PUT /api/workoutHistories/:historyId
router.put('/:historyId', async (req, res) => {
    try {
        const historyId = req.params.historyId;
        const { index, duration, caloriesBurned, completedAt } = req.body;

        const history = await WorkoutHistory.findById(historyId);
        if (!history) {
        return res.status(404).json({ message: "Workout history not found" });
        }

        history.index = index;
        history.duration += duration;
        history.caloriesBurned += caloriesBurned;
        history.completedAt = completedAt;

        await history.save();

        res.json({ message: "Workout history updated" });
    } catch (err) {
        console.error("Error updating workout history:", err);
        res.status(500).json({ message: "Error updating workout history" });
    }
});

// GET /api/workoutHistories/:uid
router.get('/user/:uid', async (req, res) => {
    try {
        const uid = req.params.uid;

        const histories = await WorkoutHistory.find({ uid })
            .sort({ completedAt: -1 })
            .populate('id_cate')
            .populate('exercisesArr');

        const resultList = histories.map((history) => {
            const category = history.id_cate;
            const exercisesArr = history.exercisesArr; // Đã được populate

            const index = history.index || 0;
            const progress = exercisesArr.length > 0 ? ((index + 1) / exercisesArr.length) : 0.0;

            return {
                id: history._id,
                name: category ? category.name : 'No Name',
                image: category ? category.pic : '',
                index,
                progress,
                exercisesArr,
                calo: history.caloriesBurned || 0,
                time: history.duration ? history.duration / 60 : 0,
            };
        })

        res.json(resultList);
    } catch (err) {
        console.error("Error fetching workout history:", err);
        res.status(500).json({ message: "Error fetching workout history" });
    }
});

module.exports = router;