const Tip = require('../models/tipModel');

const express = require('express');
const router = express.Router();

// Fetch all tips
router.get('/', async (req, res) => {
    try {
        const tips = await Tip.find();
        res.json(tips);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});
  
// Add a new tip
router.post('/', async (req, res) => {
    const { detail, name, pic } = req.body;

    const tip = new Tip({
        detail,
        name,
        pic,
    });

    try {
        const newTip = await tip.save();
        res.status(201).json(newTip); // Send back the newly created tip
    } catch (err) {
        res.status(400).json({ message: err.message });
    }
});
  
  // Update a tip by ID
router.put('/:id', async (req, res) => {
    try {
        const tip = await Tip.findById(req.params.id);
        if (!tip) return res.status(404).json({ message: 'Tip not found' });
    
        tip.detail = req.body.detail || tip.detail;
        tip.name = req.body.name || tip.name;
        tip.pic = req.body.pic || tip.pic;
    
        const updatedTip = await tip.save();
        res.json(updatedTip); // Send back the updated tip
    } catch (err) {
        res.status(400).json({ message: err.message });
    }
});
  
// Delete a tip by ID
router.delete('/:id', async (req, res) => {
    try {
    const tip = await Tip.findById(req.params.id);
    if (!tip) return res.status(404).json({ message: 'Tip not found' });

    await tip.remove();
    res.json({ message: 'Tip deleted' });
    } catch (err) {
    res.status(500).json({ message: err.message });
    }
});



module.exports = router;