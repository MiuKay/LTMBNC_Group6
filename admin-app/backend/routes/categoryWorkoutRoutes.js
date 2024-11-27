const express = require("express");
const router = express.Router();
const CategoryWorkout = require("../models/CategoryWorkout");
const WorkoutModel = require("../models/WorkoutModel");
const admin = require("../db/firebase");


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

router.post("/", async (req, res) => {
    try {
        // Lưu CategoryWorkout vào MongoDB
        const newCategory = new CategoryWorkout(req.body);
        const savedCategory = await newCategory.save();

        const categoryDoc = {
            id: savedCategory.id,
            name: savedCategory.name,
            level: savedCategory.level,
            pic: savedCategory.pic || "",
        };

        await admin.firestore().collection("CategoryWorkout").doc(savedCategory._id.toString()).set(categoryDoc);

        res.status(201).json(savedCategory);
    } catch (err) {
        console.error("Error creating category:", err);
        res.status(400).json({ error: "Failed to create category" });
    }
});


// Cập nhật thông tin một CategoryWorkout
router.put("/:id", async (req, res) => {
    try {
        const updatedCategory = await CategoryWorkout.findByIdAndUpdate(req.params.id, req.body, { new: true });
        if (!updatedCategory) return res.status(404).json({ error: "Category not found" });

        const categoryDoc = {
            name: updatedCategory.name,
            level: updatedCategory.level,
            pic: updatedCategory.pic || "",
        };
        await admin.firestore().collection("CategoryWorkout").doc(req.params.id).update(categoryDoc);

        res.status(200).json(updatedCategory);
    } catch (err) {
        console.error("Error updating category:", err);
        res.status(400).json({ error: "Failed to update category" });
    }
});


router.delete("/:id", async (req, res) => {
    try {
        const deletedCategory = await CategoryWorkout.findByIdAndDelete(req.params.id);
        if (!deletedCategory) return res.status(404).json({ error: "Category not found" });

        await WorkoutModel.deleteMany({ id_cate: req.params.id });

        await admin.firestore().collection("categoryWorkouts").doc(req.params.id).delete();

        res.status(200).json({ message: "Category deleted successfully" });
    } catch (err) {
        console.error("Error deleting category:", err);
        res.status(500).json({ error: "Failed to delete category" });
    }
});


module.exports = router; 