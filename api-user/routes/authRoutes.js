const express = require('express');
const router = express.Router();
const authService = require('../services/authService');

// Endpoint đăng ký người dùng
router.post('/signup', async (req, res) => {
  const { email, password, fname, lname } = req.body;
  const result = await authService.signupUser({ email, password, fname, lname });
  if (result.success) {
    res.status(201).json({ message: result.message, token: result.token });
  } else {
    res.status(400).json({ message: result.message });
  }
});

// Route đăng nhập
router.post('/login', async (req, res) => {
  const { email, password } = req.body;  // Lấy email và password từ body request

  try {
    const loginResult = await authService.loginUser({ email, password });

    // Kiểm tra kết quả đăng nhập
    if (loginResult.success) {
      // Nếu đăng nhập thành công, trả về token và thông tin thông báo
      return res.status(200).json({
        success: true,
        token: loginResult.token,
        notifications: loginResult.notifications,
      });
    } else {
      // Nếu đăng nhập thất bại, trả về thông báo lỗi
      return res.status(400).json({
        success: false,
        message: loginResult.message,
      });
    }
  } catch (err) {
    // Xử lý lỗi
    return res.status(500).json({
      success: false,
      message: err.message,
    });
  }
});

// Route để hoàn thành hồ sơ người dùng
router.post('/complete-profile', async (req, res) => {
  const { uid, dateOfBirth, gender, weight, height } = req.body;

  // Gọi service để cập nhật hồ sơ người dùng
  const result = await authService.completeUserProfile({
    uid,
    dateOfBirth,
    gender,
    weight,
    height,
  });

  if (result === "success") {
    res.status(200).json({ message: "Thông tin hồ sơ đã được cập nhật thành công" });
  } else {
    res.status(400).json({ message: result });
  }
});

// Đổi `/getInfo` thành `/getInfo/:uid`
router.get('/getInfo/:uid', async (req, res) => {
  const { uid } = req.params;  // Lấy UID từ URL params
  
  try {
    const user = await authService.getUserInfo(uid);
    if (user) {
      res.status(200).json({ user });
    } else {
      res.status(404).json({ message: 'User not found' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Error fetching user info', error: error.message });
  }
});

// Route cập nhật ảnh đại diện người dùng
router.post('/update-pic', async (req, res) => {
  const { uid, imageUrl } = req.body;
  
  if (!imageUrl) {
    return res.status(400).json({ message: 'Image URL is required' });
  }
  
  try {
    await authService.updateUserProfileImage(uid, imageUrl);
    res.status(200).json({ message: 'Profile image updated successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Error updating profile image', error: error.message });
  }
});

// Route cập nhật cấp độ người dùng
router.post('/update-level', async (req, res) => {
  const { uid, level } = req.body;
  
  if (!level) {
    return res.status(400).json({ message: 'Level is required' });
  }
  
  try {
    await authService.updateUserLevel(uid, level);
    res.status(200).json({ message: 'User level updated successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Error updating user level', error: error.message });
  }
});

router.post('/forget-password', async (req, res) => {
  const { email, newPass, otp } = req.body;

  try {
    const result = await authService.forgetPassword(email, newPass, otp);
    if (result === "success") {
      res.status(200).json({ message: "Mật khẩu đã được đặt lại thành công" });
    } else {
      res.status(400).json({ message: result });
    }
  } catch (error) {
    res.status(500).json({ message: "Có lỗi xảy ra", error: error.message });
  }
});

router.post('/send-otp', async (req, res) => {
  const { uid } = req.body;

  try {
    const result = await authService.sendOtpEmail(uid);
    if (result === "success") {
      res.status(200).json({ message: "OTP đã được gửi" });
    } else {
      res.status(400).json({ message: result });
    }
  } catch (error) {
    res.status(500).json({ message: "Có lỗi xảy ra", error: error.message });
  }
});

router.post('/reset-password', async (req, res) => {
  const { email } = req.body;

  try {
    const result = await authService.sendOtpEmailResetPass(email);
    if (result === "success") {
      res.status(200).json({ message: "OTP đã được gửi" });
    } else {
      res.status(400).json({ message: result });
    }
  } catch (error) {
    res.status(500).json({ message: "Có lỗi xảy ra", error: error.message });
  }
});

router.post('/verify-otp', async (req, res) => {
  const { uid, otp } = req.body;

  try {
    const result = await authService.verifyOtp(uid, otp);
    if (result === "success") {
      res.status(200).json({ message: "OTP đã được xác thực" });
    } else {
      res.status(400).json({ message: result });
    }
  } catch (error) {
    res.status(500).json({ message: "Có lỗi xảy ra", error: error.message });
  }
});


module.exports = router;
