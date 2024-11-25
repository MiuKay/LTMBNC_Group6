const Exercise = require('../models/excerciseModel');
const Workout = require('../models/workoutModel');
const CategoryWorkout = require('../models/categoryWorkoutModel');

const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');

router.get('/', async (req, res) => {
    try{
        const categories = await CategoryWorkout.find();

        const categoryWorkoutList = await Promise.all(
            categories.map(async (category) => {
                const categoryId = category._id;
                const image = category.pic;
                const title = category.name;

                // Fetch workouts for this category
                // const workouts = await Workout.find({id_cate: categoryId})
                const workouts = await Workout.find({ id_cate: categoryId })
                    .populate({
                        path: 'exercise',
                        match: { difficulty: 'Beginner' }, // Fetch exercises with difficulty 'Beginner'
                    }
                );
                const filteredWorkouts = workouts.filter(workout => workout.exercise);

                const exerciseCount = filteredWorkouts.length;

                //Calculate total time and calories
                let totalTimeInSeconds = 0;
                let totalCalo = 0;
                
                filteredWorkouts.forEach(workout => {
                    const exercise = workout.exercise;
                    totalTimeInSeconds += exercise.time || 0;
                    totalCalo += exercise.calo || 0;
                });

                const totalTimeInMinutes = Math.round(totalTimeInSeconds / 60);

                return {
                    id: categoryId,
                    image,
                    title,
                    exercises:`${exerciseCount} Exercises`,
                    time: `${totalTimeInMinutes} Mins`,
                    calo: `${totalCalo} Calories Burn`
                }
            })
        )
        res.json(categoryWorkoutList);
    }catch(error){
        console.error("Error fetching category workouts", error);
        res.status(500).json({error: true, message: "Error fetching category workouts"})
    }
})

// Add this to routes/categoryWorkoutRoutes.js

// GET /api/categoryWorkouts/level/:level
router.get('/level/:level', async (req, res) => {
    try {
        const level = req.params.level;
        const categories = await CategoryWorkout.find({ level: level });

        // Tương tự như route trên, bạn cần xử lý categories để tạo categoryWorkoutList
        const categoryWorkoutList = await Promise.all(
            categories.map(async (category) => {
                const categoryId = category._id;
                const image = category.pic;
                const title = category.name;

                // Fetch workouts for this category
                const workouts = await Workout.find({ id_cate: categoryId })
                    .populate({
                        path: 'exercise',
                        match: { difficulty: level },
                    });
                const filteredWorkouts = workouts.filter(workout => workout.exercise);
                const exerciseCount = filteredWorkouts.length;

                // Calculate total time and calories
                let totalTimeInSeconds = 0;
                let totalCalo = 0;

                filteredWorkouts.forEach(workout => {
                    const exercise = workout.exercise;
                    totalTimeInSeconds += exercise.time || 0;
                    totalCalo += exercise.calo || 0;
                });

                const totalTimeInMinutes = Math.round(totalTimeInSeconds / 60);

                return {
                    id: categoryId,
                    image,
                    title,
                    exercises: `${exerciseCount} Exercises`,
                    time: `${totalTimeInMinutes} Mins`,
                    calo: `${totalCalo} Calories Burn`,
                };
            })
        );

        res.json(categoryWorkoutList);
    } catch (err) {
        console.error("Error fetching category workouts:", err);
        res.status(500).json({ message: "Error fetching category workouts" });
    }
});

// Add this to routes/categoryWorkoutRoutes.js

// GET /api/categoryWorkouts/:categoryId/difficulty/:difficulty/timeAndCalo
router.get('/:categoryId/difficulty/:difficulty/timeAndCalo', async (req, res) => {
    try {
        const { categoryId, difficulty } = req.params;
    
        // Fetch workouts
        const workouts = await Workout.find({ id_cate: categoryId })
            .populate({
                path: 'exercise',
                match: { difficulty: difficulty },
            });
        const filteredWorkouts = workouts.filter(workout => workout.exercise);
    
        let totalTimeInSeconds = 0;
        let totalCalo = 0;
    
        filteredWorkouts.forEach(workout => {
            const exercise = workout.exercise;
            totalTimeInSeconds += exercise.time || 0;
            totalCalo += exercise.calo || 0;
        }); 

        const totalTimeInMinutes = Math.round(totalTimeInSeconds / 60);
    
        res.json({
            time: `${totalTimeInMinutes} Mins`,
            calo: `${totalCalo} Calo Burned`,
        });
    } catch (err) {
        console.error("Error fetching time and calories:", err);
        res.status(500).json({ message: "Error fetching time and calories" });
    }
});
  

module.exports = router;