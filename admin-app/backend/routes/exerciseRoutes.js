const express = require("express");
const router = express.Router();
const Exercise = require("../models/Exercise");

// Lấy danh sách tất cả bài tập
router.get("/", async (req, res) => {
    try {
        const exercises = await Exercise.find();
        res.status(200).json(exercises);
    } catch (err) {
        res.status(500).json({ error: "Failed to fetch exercises" });
    }
});

// Lấy chi tiết một bài tập
router.get("/:id", async (req, res) => {
    try {
        const exercise = await Exercise.findById(req.params.id);
        if (!exercise) return res.status(404).json({ error: "Exercise not found" });
        res.status(200).json(exercise);
    } catch (err) {
        res.status(500).json({ error: "Failed to fetch exercise" });
    }
});

// Tạo mới một bài tập
router.post("/", async (req, res) => {
    try {
        const newExercise = new Exercise(req.body);
        const savedExercise = await newExercise.save();
        res.status(201).json(savedExercise);
    } catch (err) {
        res.status(400).json({ error: "Failed to create exercise" });
    }
});

// Cập nhật thông tin một bài tập
router.put("/:id", async (req, res) => {
    try {
        const updatedExercise = await Exercise.findByIdAndUpdate(req.params.id, req.body, { new: true });
        if (!updatedExercise) return res.status(404).json({ error: "Exercise not found" });
        res.status(200).json(updatedExercise);
    } catch (err) {
        res.status(400).json({ error: "Failed to update exercise" });
    }
});

// Xóa một bài tập
router.delete("/:id", async (req, res) => {
    try {
        const deletedExercise = await Exercise.findByIdAndDelete(req.params.id);
        if (!deletedExercise) return res.status(404).json({ error: "Exercise not found" });
        res.status(200).json({ message: "Exercise deleted successfully" });
    } catch (err) {
        res.status(500).json({ error: "Failed to delete exercise" });
    }
});

module.exports = router;
