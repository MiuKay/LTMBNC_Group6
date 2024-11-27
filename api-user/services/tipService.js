const Tip = require("../models/TipModel"); // Import Tip model

class TipService {
    // Lấy danh sách các mẹo
    async fetchTips() {
        try {
            const tipsList = await Tip.find(); 
            return tipsList;
        } catch (error) {
            console.error("Error fetching tips:", error);
            throw new Error("Failed to fetch tips");
        }
    }
}

module.exports = new TipService();
