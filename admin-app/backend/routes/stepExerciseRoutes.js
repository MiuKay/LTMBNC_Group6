const express = require("express");
const router = express.Router();
const StepExercise = require("../models/StepExercise");
const admin = require("../db/firebase");

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

router.post("/", async (req, res) => {
    try {
        // Lưu vào MongoDB
        const newStep = new StepExercise(req.body);
        const savedStep = await newStep.save();

        // Lưu vào Firestore
        const stepDoc = {
            name: savedStep.name,
            step: savedStep.step,
            title: savedStep.title,
            detail: savedStep.detail,
        };

        await admin.firestore().collection("Step_exercies").doc(savedStep._id.toString()).set(stepDoc);

        res.status(201).json(savedStep);
    } catch (err) {
        console.error("Error creating step exercise:", err);
        res.status(400).json({ error: "Failed to create step exercise" });
    }
});


router.put("/:id", async (req, res) => {
    try {
        // Cập nhật trên MongoDB
        const updatedStep = await StepExercise.findByIdAndUpdate(req.params.id, req.body, { new: true });
        if (!updatedStep) return res.status(404).json({ error: "Step exercise not found" });

        // Cập nhật trên Firestore
        const stepDoc = {
            name: updatedStep.name,
            step: updatedStep.step,
            title: updatedStep.title,
            detail: updatedStep.detail,
        };
        await admin.firestore().collection("Step_exercies").doc(req.params.id).update(stepDoc);

        res.status(200).json(updatedStep);
    } catch (err) {
        console.error("Error updating step exercise:", err);
        res.status(400).json({ error: "Failed to update step exercise" });
    }
});

router.delete("/:id", async (req, res) => {
    try {

        const deletedStep = await StepExercise.findByIdAndDelete(req.params.id);
        if (!deletedStep) return res.status(404).json({ error: "Step exercise not found" });

        await admin.firestore().collection("Step_exercies").doc(req.params.id).delete();

        res.status(200).json({ message: "Step exercise deleted successfully" });
    } catch (err) {
        console.error("Error deleting step exercise:", err);
        res.status(500).json({ error: "Failed to delete step exercise" });
    }
});


module.exports = router;
