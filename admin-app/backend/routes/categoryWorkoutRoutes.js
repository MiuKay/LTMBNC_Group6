const express = require("express");
const router = express.Router();
const CategoryWorkout = require("../models/CategoryWorkout");
const WorkoutModel = require("../models/WorkoutModel");


// Lấy danh sách tất cả CategoryWorkout
router.get("/", async (req, res) => {
    try {
        const categories = await CategoryWorkout.find();
        res.status(200).json(categories);
    } catch (err) {
        res.status(500).json({ error: "Failed to fetch categories" });
    }
});

// Lấy chi tiết một CategoryWorkout
router.get("/:id", async (req, res) => {
    try {
        const category = await CategoryWorkout.findById(req.params.id);
        if (!category) return res.status(404).json({ error: "Category not found" });
        res.status(200).json(category);
    } catch (err) {
        res.status(500).json({ error: "Failed to fetch category" });
    }
});

// Tạo mới một CategoryWorkout
router.post("/", async (req, res) => {
    try {
        const newCategory = new CategoryWorkout(req.body);
        const savedCategory = await newCategory.save();
        res.status(201).json(savedCategory);
    } catch (err) {
        res.status(400).json({ error: "Failed to create category" });
    }
});

// Cập nhật thông tin một CategoryWorkout
router.put("/:id", async (req, res) => {
    try {
        const updatedCategory = await CategoryWorkout.findByIdAndUpdate(req.params.id, req.body, { new: true });
        if (!updatedCategory) return res.status(404).json({ error: "Category not found" });
        res.status(200).json(updatedCategory);
    } catch (err) {
        res.status(400).json({ error: "Failed to update category" });
    }
});

// Xóa một CategoryWorkout
router.delete("/:id", async (req, res) => {
    try {
        const deletedCategory = await CategoryWorkout.findByIdAndDelete(req.params.id);
        console.log(`CategoryWorkout with id ${req.params.id} deleted`);
        await WorkoutModel.deleteMany({ id_cate: req.params.id }); // Xóa các Workout
        console.log(`Del workouts with id_cate: ${req.params.id}`);
        if (!deletedCategory) return res.status(404).json({ error: "Category not found" });
        res.status(200).json({ message: "Category deleted successfully" });
    } catch (err) {
        res.status(500).json({ error: "Failed to delete category" });
    }
});

module.exports = router; 