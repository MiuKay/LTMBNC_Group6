const express = require("express");
const router = express.Router();
const tipService = require("../services/tipService"); 

// API: Lấy danh sách các mẹo
router.get("/", async (req, res) => {
    try {
        const tips = await tipService.fetchTips();
        res.status(200).json(tips);
    } catch (error) {
        res.status(500).json({ error: "Failed to fetch tips" });
    }
});

module.exports = router;
