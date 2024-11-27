const express = require("express");
const router = express.Router();
const Tool = require("../models/Tools");
const admin = require("../db/firebase");

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

router.post("/", async (req, res) => {
    try {
        const newTool = new Tool(req.body);
        const savedTool = await newTool.save();

        const toolDoc = {
            id: savedTool.id,
            name: savedTool.name,
            pic: savedTool.pic || "",
        };

        await admin.firestore().collection("Tools").doc(savedTool._id.toString()).set(toolDoc);

        res.status(201).json(savedTool);
    } catch (err) {
        console.error("Error creating tool:", err);
        res.status(400).json({ error: "Failed to create tool" });
    }
});

router.put("/:id", async (req, res) => {
    try {
        const updatedTool = await Tool.findByIdAndUpdate(req.params.id, req.body, { new: true });
        if (!updatedTool) return res.status(404).json({ error: "Tool not found" });

        const toolDoc = {
            name: updatedTool.name,
            pic: updatedTool.pic || "",
        };
        await admin.firestore().collection("Tools").doc(req.params.id).update(toolDoc);

        res.status(200).json(updatedTool);
    } catch (err) {
        console.error("Error updating tool:", err);
        res.status(400).json({ error: "Failed to update tool" });
    }
});

router.delete("/:id", async (req, res) => {
    try {
        const deletedTool = await Tool.findByIdAndDelete(req.params.id);
        if (!deletedTool) return res.status(404).json({ error: "Tool not found" });

        await admin.firestore().collection("Tools").doc(req.params.id).delete();

        res.status(200).json({ message: "Tool deleted successfully" });
    } catch (err) {
        console.error("Error deleting tool:", err);
        res.status(500).json({ error: "Failed to delete tool" });
    }
});


module.exports = router; 