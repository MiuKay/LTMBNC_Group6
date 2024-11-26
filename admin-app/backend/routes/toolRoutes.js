const express = require("express");
const router = express.Router();
const Tool = require("../models/Tools");

// Lấy danh sách tất cả Tools
router.get("/", async (req, res) => {
    try {
        const tools = await Tool.find();
        res.status(200).json(tools);
    } catch (err) {
        res.status(500).json({ error: "Failed to fetch tools" });
    }
});

// Lấy chi tiết một Tool
router.get("/:id", async (req, res) => {
    try {
        const tool = await Tool.findById(req.params.id);
        if (!tool) return res.status(404).json({ error: "Tool not found" });
        res.status(200).json(tool);
    } catch (err) {
        res.status(500).json({ error: "Failed to fetch tool" });
    }
});

// Tạo mới một Tool
router.post("/", async (req, res) => {
    try {
        const newTool = new Tool(req.body);
        const savedTool = await newTool.save();
        res.status(201).json(savedTool);
    } catch (err) {
        res.status(400).json({ error: "Failed to create tool" });
    }
});

// Cập nhật thông tin một Tool
router.put("/:id", async (req, res) => {
    try {
        const updatedTool = await Tool.findByIdAndUpdate(req.params.id, req.body, { new: true });
        if (!updatedTool) return res.status(404).json({ error: "Tool not found" });
        res.status(200).json(updatedTool);
    } catch (err) {
        res.status(400).json({ error: "Failed to update tool" });
    }
});

// Xóa một Tool
router.delete("/:id", async (req, res) => {
    try {
        const deletedTool = await Tool.findByIdAndDelete(req.params.id);
        if (!deletedTool) return res.status(404).json({ error: "Tool not found" });
        res.status(200).json({ message: "Tool deleted successfully" });
    } catch (err) {
        res.status(500).json({ error: "Failed to delete tool" });
    }
});

module.exports = router; 