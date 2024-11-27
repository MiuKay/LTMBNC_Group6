const express = require("express");
const router = express.Router();
const UserModel = require("../models/UserModel");

const admin = require("../db/firebase");

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

// Route tạo mới người dùng
router.post("/", async (req, res) => {
    try {
      const newUser = new UserModel(req.body);
      const savedUser = await newUser.save();

      const firebaseUser = await admin.auth().createUser({
        uid: savedUser._id.toString(),
        email: savedUser.email,
        password: req.body.password || "123456",
      });
  
      const userDoc = {
        uid: firebaseUser.uid, 
        fname: savedUser.fname,
        lname: savedUser.lname,
        email: savedUser.email,
        date_of_birth: savedUser.date_of_birth,
        gender: savedUser.gender,
        weight: savedUser.weight,
        height: savedUser.height,
        pic: savedUser.pic || "",
        level: savedUser.level,
        activate: savedUser.activate,
        role: savedUser.role,
        otp: savedUser.otp,
        expiresAt: savedUser.expiresAt,
        password: savedUser.password,
      };

      await admin.firestore().collection("users").doc(firebaseUser.uid).set(userDoc);

      res.status(201).json({ savedUser, firebaseUser });
    } catch (err) {
      console.error("Error creating user:", err);
      res.status(400).json({ error: "Failed to create user", details: err.message });
    }
  });

router.put("/:id", async (req, res) => {
try {

    const updatedUser = await UserModel.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!updatedUser) return res.status(404).json({ error: "User not found" });

    await admin.auth().updateUser(updatedUser._id.toString(), {
    email: req.body.email,
    });

    await admin.firestore().collection("users").doc(updatedUser._id.toString()).update(req.body);

    res.status(200).json(updatedUser);
} catch (err) {
    console.error("Error updating user:", err);
    res.status(400).json({ error: "Failed to update user", details: err.message });
}
});

router.delete("/:id", async (req, res) => {
try {
    const userId = req.params.id;

    const deletedUser = await UserModel.findByIdAndDelete(userId);
    if (!deletedUser) return res.status(404).json({ error: "User not found" });

    await admin.auth().deleteUser(userId);

    await admin.firestore().collection("users").doc(userId).delete();

    res.status(200).json({ message: "User deleted successfully" });
} catch (err) {
    console.error("Error deleting user:", err);
    res.status(500).json({ error: "Failed to delete user", details: err.message });
}
});

module.exports = router;
