const CateWorkTool = require('../models/cateWorkToolModel')
const Tool = require('../models/toolModel');

const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');

// GET /api/tools/category/:categoryId
router.get('/category/:categoryId', async (req, res) => {
    try {
        const categoryId = req.params.categoryId;
    
        // Step 1: Get id_tool from CateWorkTool
        const cateWorkTools = await CateWorkTool.find({ id_cate: categoryId });
        const toolId = cateWorkTools.map(cwt => cwt.id_tool);
    
        // Step 2: Fetch tool details
        const tools = await Tool.find({ _id: { $in: toolId } });
    
        const toolsList = tools.map(tool => ({
            id: tool._id,
            title: tool.name,
            image: tool.pic,
        }));
    
        res.json(toolsList);
    } catch (err) {
        console.error("Error fetching tools:", err);
        res.status(500).json({ message: "Error fetching tools" });
    }
});
  
  module.exports = router;