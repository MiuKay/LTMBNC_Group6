const express = require("express");
const router = express.Router();
const Workout = require("../models/WorkoutModel");

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

// Tạo mới một Workout
router.post("/", async (req, res) => {
    try {
        const newWorkout = new Workout(req.body);
        const savedWorkout = await newWorkout.save();
        res.status(201).json(savedWorkout);
    } catch (err) {
        res.status(400).json({ error: "Failed to create workout" });
    }
});

// Cập nhật thông tin một Workout
router.put("/:id", async (req, res) => {
    try {
        const updatedWorkout = await Workout.findByIdAndUpdate(req.params.id, req.body, { new: true });
        if (!updatedWorkout) return res.status(404).json({ error: "Workout not found" });
        res.status(200).json(updatedWorkout);
    } catch (err) {
        res.status(400).json({ error: "Failed to update workout" });
    }
});

// Xóa một Workout
router.delete("/:id", async (req, res) => {
    try {
        const deletedWorkout = await Workout.findByIdAndDelete(req.params.id);
        if (!deletedWorkout) return res.status(404).json({ error: "Workout not found" });
        res.status(200).json({ message: "Workout deleted successfully" });
    } catch (err) {
        res.status(500).json({ error: "Failed to delete workout" });
    }
});

module.exports = router; 