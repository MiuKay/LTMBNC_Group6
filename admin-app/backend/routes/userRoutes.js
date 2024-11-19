const express = require("express");
const router = express.Router();
const UserModel = require("../models/UserModel");

// Lấy danh sách tất cả người dùng
router.get("/", async (req, res) => {
    try {
        const users = await UserModel.find();
        res.status(200).json(users);
    } catch (err) {
        res.status(500).json({ error: "Failed to fetch users" });
    }
});

// Lấy chi tiết một người dùng
router.get("/:id", async (req, res) => {
    try {
        const user = await UserModel.findById(req.params.id);
        if (!user) return res.status(404).json({ error: "User not found" });
        res.status(200).json(user);
    } catch (err) {
        res.status(500).json({ error: "Failed to fetch user" });
    }
});

// Tạo mới một người dùng
router.post("/", async (req, res) => {
    try {
        const newUser = new UserModel(req.body);
        const savedUser = await newUser.save();
        res.status(201).json(savedUser);
    } catch (err) {
        res.status(400).json({ error: "Failed to create user" });
    }
});

// Cập nhật thông tin một người dùng
router.put("/:id", async (req, res) => {
    try {
        const updatedUser = await UserModel.findByIdAndUpdate(req.params.id, req.body, { new: true });
        if (!updatedUser) return res.status(404).json({ error: "User not found" });
        res.status(200).json(updatedUser);
    } catch (err) {
        res.status(400).json({ error: "Failed to update user" });
    }
});

// Xóa một người dùng
router.delete("/:id", async (req, res) => {
    try {
        if(req.params.id != null){
            const deletedUser = await UserModel.findByIdAndDelete(req.params.id);
            if (!deletedUser) return res.status(404).json({ error: "User not found" });
            res.status(200).json({ message: "User deleted successfully" });
        }
        else res.status(404).json({ message: "Failed to delete user" });

    } catch (err) {
        res.status(500).json({ error: "User not found" });
    }
});

module.exports = router;
