const express = require("express");
const router = express.Router();
const Tip = require("../models/Tip");
const admin = require("../db/firebase");

// Lấy danh sách các mẹo
router.get("/", async (req, res) => {
    try {
        const tips = await Tip.find();
        res.status(200).json(tips);
    } catch (err) {
        res.status(500).json({ error: "Failed to fetch tips" });
    }
});

// Lấy chi tiết một mẹo
router.get("/:id", async (req, res) => {
    try {
        const tip = await Tip.findById(req.params.id);
        if (!tip) return res.status(404).json({ error: "Tip not found" });
        res.status(200).json(tip);
    } catch (err) {
        res.status(500).json({ error: "Failed to fetch tip" });
    }
});

router.post("/", async (req, res) => {
    try {
        const newTip = new Tip(req.body);
        const savedTip = await newTip.save();

        const tipDoc = {
            name: savedTip.name,
            detail: savedTip.detail,
            pic: savedTip.pic || "", 
        };

        await admin.firestore().collection("Tips").doc(savedTip._id.toString()).set(tipDoc);

        res.status(201).json(savedTip);
    } catch (err) {
        console.error("Error creating tip:", err);
        res.status(400).json({ error: "Failed to create tip" });
    }
});


router.put("/:id", async (req, res) => {
    try {
        const updatedTip = await Tip.findByIdAndUpdate(req.params.id, req.body, { new: true });
        if (!updatedTip) return res.status(404).json({ error: "Tip not found" });

        const tipDoc = {
            name: updatedTip.name,
            detail: updatedTip.detail,
            pic: updatedTip.pic || "",
        };
        await admin.firestore().collection("Tips").doc(req.params.id).update(tipDoc);

        res.status(200).json(updatedTip);
    } catch (err) {
        console.error("Error updating tip:", err);
        res.status(400).json({ error: "Failed to update tip" });
    }
});


// Xóa một mẹo
router.delete("/:id", async (req, res) => {
    try {
        const deletedTip = await Tip.findByIdAndDelete(req.params.id);
        if (!deletedTip) return res.status(404).json({ error: "Tip not found" });

        await admin.firestore().collection("Tips").doc(req.params.id).delete();

        res.status(200).json({ message: "Tip deleted successfully" });
    } catch (err) {
        console.error("Error deleting tip:", err);
        res.status(500).json({ error: "Failed to delete tip" });
    }
});


module.exports = router;
