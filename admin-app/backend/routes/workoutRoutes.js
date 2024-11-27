const express = require("express");
const router = express.Router();
const Workout = require("../models/WorkoutModel");
const admin = require("../db/firebase");

// Lấy danh sách tất cả Workout
router.get("/", async (req, res) => {
    try {
        const workouts = await Workout.find();
        res.status(200).json(workouts);
    } catch (err) {
        res.status(500).json({ error: "Failed to fetch workouts" });
    }
});

// Lấy chi tiết một Workout
router.get("/:id", async (req, res) => {
    try {
        const workout = await Workout.findById(req.params.id);
        if (!workout) return res.status(404).json({ error: "Workout not found" });
        res.status(200).json(workout);
    } catch (err) {
        res.status(500).json({ error: "Failed to fetch workout" });
    }
});

router.post("/", async (req, res) => {
    try {
        const newWorkout = new Workout(req.body);
        const savedWorkout = await newWorkout.save();

        const workoutDoc = {
            id_cate: savedWorkout.id_cate,
            name_exercise: savedWorkout.name_exercise,
            step: savedWorkout.step || 0,
        };
        await admin.firestore().collection("Workout").doc(savedWorkout._id.toString()).set(workoutDoc);

        res.status(201).json(savedWorkout);
    } catch (err) {
        console.error("Error creating workout:", err);
        res.status(400).json({ error: "Failed to create workout" });
    }
});

router.put("/:id", async (req, res) => {
    try {
        const updatedWorkout = await Workout.findByIdAndUpdate(req.params.id, req.body, { new: true });
        if (!updatedWorkout) return res.status(404).json({ error: "Workout not found" });

        const workoutDoc = {
            id_cate: updatedWorkout.id_cate,
            name_exercise: updatedWorkout.name_exercise,
            step: updatedWorkout.step || 0,
        };

        await admin.firestore().collection("Workout").doc(req.params.id).update(workoutDoc);

        res.status(200).json(updatedWorkout);
    } catch (err) {
        console.error("Error updating workout:", err);
        res.status(400).json({ error: "Failed to update workout" });
    }
});

router.delete("/:id", async (req, res) => {
    try {
        const deletedWorkout = await Workout.findByIdAndDelete(req.params.id);
        if (!deletedWorkout) return res.status(404).json({ error: "Workout not found" });

        await admin.firestore().collection("Workout").doc(req.params.id).delete();

        res.status(200).json({ message: "Workout deleted successfully" });
    } catch (err) {
        console.error("Error deleting workout:", err);
        res.status(500).json({ error: "Failed to delete workout" });
    }
});


module.exports = router; 