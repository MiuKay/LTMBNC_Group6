const express = require("express");
const router = express.Router();
const Exercise = require("../models/Exercise");
const admin = require("../db/firebase");

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

router.post("/", async (req, res) => {
    try {

      const newExercise = new Exercise(req.body);
      const savedExercise = await newExercise.save();

      const exerciseDoc = {
        name: savedExercise.name,
        descriptions: savedExercise.descriptions,
        difficulty: savedExercise.difficulty,
        calo: savedExercise.calo,
        rep: savedExercise.rep,
        time: savedExercise.time,
        pic: savedExercise.pic || "",
        video: savedExercise.video || "",
      };
  
      await admin.firestore().collection("Exercies").doc(savedExercise._id.toString()).set(exerciseDoc);

      res.status(201).json(savedExercise);
    } catch (err) {
      console.error("Error creating exercise:", err);
      res.status(400).json({ error: "Failed to create exercise", details: err.message });
    }
});
  

router.put("/:id", async (req, res) => {
    try {
      const updatedExercise = await Exercise.findByIdAndUpdate(req.params.id, req.body, { new: true });
      if (!updatedExercise) return res.status(404).json({ error: "Exercise not found" });
  
      const exerciseDoc = {
        name: req.body.name,
        descriptions: req.body.descriptions,
        difficulty: req.body.difficulty,
        calo: req.body.calo,
        rep: req.body.rep,
        time: req.body.time,
        pic: req.body.pic || "",
        video: req.body.video || "",
      };
  
      await admin.firestore().collection("Exercies").doc(req.params.id).update(exerciseDoc);

      res.status(200).json(updatedExercise);
    } catch (err) {
      console.error("Error updating exercise:", err);
      res.status(400).json({ error: "Failed to update exercise", details: err.message });
    }
});
  

router.delete("/:id", async (req, res) => {
    try {
      const exerciseId = req.params.id;

      const deletedExercise = await Exercise.findByIdAndDelete(exerciseId);
      if (!deletedExercise) return res.status(404).json({ error: "Exercise not found" });

      await admin.firestore().collection("Exercies").doc(exerciseId).delete();

      res.status(200).json({ message: "Exercise deleted successfully" });
    } catch (err) {
      console.error("Error deleting exercise:", err);
      res.status(500).json({ error: "Failed to delete exercise", details: err.message });
    }
});
  
module.exports = router;
