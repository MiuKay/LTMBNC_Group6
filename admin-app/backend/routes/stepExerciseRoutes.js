const express = require("express");
const router = express.Router();
const StepExercise = require("../models/StepExercise");

// Lấy danh sách các bước tập luyện
router.get("/", async (req, res) => {
    try {
        const steps = await StepExercise.find();
        res.status(200).json(steps);
    } catch (err) {
        res.status(500).json({ error: "Failed to fetch step exercises" });
    }
});

// Lấy chi tiết một bước tập luyện
router.get("/:id", async (req, res) => {
    try {
        const step = await StepExercise.findById(req.params.id);
        if (!step) return res.status(404).json({ error: "Step exercise not found" });
        res.status(200).json(step);
    } catch (err) {
        res.status(500).json({ error: "Failed to fetch step exercise" });
    }
});

// Tạo mới một bước tập luyện
router.post("/", async (req, res) => {
    try {
        const newStep = new StepExercise(req.body);
        const savedStep = await newStep.save();
        res.status(201).json(savedStep);
    } catch (err) {
        res.status(400).json({ error: "Failed to create step exercise" });
    }
});

// Cập nhật thông tin một bước tập luyện
router.put("/:id", async (req, res) => {
    try {
        const updatedStep = await StepExercise.findByIdAndUpdate(req.params.id, req.body, { new: true });
        if (!updatedStep) return res.status(404).json({ error: "Step exercise not found" });
        res.status(200).json(updatedStep);
    } catch (err) {
        res.status(400).json({ error: "Failed to update step exercise" });
    }
});

// Xóa một bước tập luyện
router.delete("/:id", async (req, res) => {
    try {
        const deletedStep = await StepExercise.findByIdAndDelete(req.params.id);
        if (!deletedStep) return res.status(404).json({ error: "Step exercise not found" });
        res.status(200).json({ message: "Step exercise deleted successfully" });
    } catch (err) {
        res.status(500).json({ error: "Failed to delete step exercise" });
    }
});

module.exports = router;
