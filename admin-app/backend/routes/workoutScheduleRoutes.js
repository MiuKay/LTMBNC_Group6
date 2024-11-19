const express = require("express");
const router = express.Router();
const WorkoutSchedule = require("../models/WorkoutSchedule");

// Lấy danh sách lịch tập
router.get("/", async (req, res) => {
    try {
        const schedules = await WorkoutSchedule.find();
        res.status(200).json(schedules);
    } catch (err) {
        res.status(500).json({ error: "Failed to fetch workout schedules" });
    }
});

// Lấy chi tiết một lịch tập
router.get("/:id", async (req, res) => {
    try {
        const schedule = await WorkoutSchedule.findById(req.params.id);
        if (!schedule) return res.status(404).json({ error: "Workout schedule not found" });
        res.status(200).json(schedule);
    } catch (err) {
        res.status(500).json({ error: "Failed to fetch workout schedule" });
    }
});

// Tạo mới một lịch tập
router.post("/", async (req, res) => {
    try {
        const newSchedule = new WorkoutSchedule(req.body);
        const savedSchedule = await newSchedule.save();
        res.status(201).json(savedSchedule);
    } catch (err) {
        res.status(400).json({ error: "Failed to create workout schedule" });
    }
});

// Cập nhật thông tin một lịch tập
router.put("/:id", async (req, res) => {
    try {
        const updatedSchedule = await WorkoutSchedule.findByIdAndUpdate(req.params.id, req.body, { new: true });
        if (!updatedSchedule) return res.status(404).json({ error: "Workout schedule not found" });
        res.status(200).json(updatedSchedule);
    } catch (err) {
        res.status(400).json({ error: "Failed to update workout schedule" });
    }
});

// Xóa một lịch tập
router.delete("/:id", async (req, res) => {
    try {
        const deletedSchedule = await WorkoutSchedule.findByIdAndDelete(req.params.id);
        if (!deletedSchedule) return res.status(404).json({ error: "Workout schedule not found" });
        res.status(200).json({ message: "Workout schedule deleted successfully" });
    } catch (err) {
        res.status(500).json({ error: "Failed to delete workout schedule" });
    }
});

module.exports = router;
