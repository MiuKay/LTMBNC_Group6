const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const User = require('../models/user');
const WorkoutSchedule = require('../models/WorkoutSchedule');
const mongoose = require('mongoose');

class AuthService {
  
  async signupUser({ email, password, fname, lname }) {
    try {
      // Kiểm tra thông tin đầu vào
      if (!email || !password || !fname || !lname) {
        throw new Error('Vui lòng điền đầy đủ thông tin');
      }

      // Kiểm tra định dạng email
      const emailRegex = /^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+$/;
      if (!emailRegex.test(email)) {
        throw new Error('Vui lòng điền đúng định dạng email');
      }

      // Kiểm tra email đã tồn tại hay chưa
      const existingUser = await User.findOne({ email });
      if (existingUser) {
        throw new Error('Email này đã được đăng ký.');
      }

      // Mã hóa mật khẩu
      const hashedPassword = await bcrypt.hash(password, 10);


      // Tạo người dùng mới
      const newUser = new User({
        fname,
        lname,
        email,
        password: hashedPassword,
        role: 'user',
        activate: false,
      });

      // Lưu người dùng vào MongoDB
      await newUser.save();

      const updatedUser = await User.findOneAndUpdate(
        { email : email }, 
        {
          uid: newUser._id.toString()
        },
        { new: true }
      )

      return { success: true, message: 'Đăng ký thành công!' };
    } catch (error) {
      return { success: false, message: error.message };
    }
  }

  async loginUser({ email, password }) {
    try {
      // Kiểm tra thông tin đầu vào
      if (!email || !password) {
        return "Vui lòng nhập đầy đủ thông tin"; // Lỗi nhập thiếu
      }
  
      // Kiểm tra định dạng email
      const emailRegex = /^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+$/;
      if (!emailRegex.test(email)) {
        return "Vui lòng nhập đúng định dạng email"; // Email sai định dạng
      }
  
      // Tìm người dùng trong cơ sở dữ liệu MongoDB
      const user = await User.findOne({ email });
      if (!user) {
        return "Không tìm thấy tài khoản với email này.";
      }
  
      // Kiểm tra trạng thái kích hoạt của người dùng
      if (!user.activate) {
        return "Tài khoản chưa được kích hoạt";
      }
  
      // Kiểm tra mật khẩu
      const isPasswordCorrect = await bcrypt.compare(password, user.password);
      if (!isPasswordCorrect) {
        return "Mật khẩu không chính xác";
      }
  
      // Tạo token JWT cho người dùng khi đăng nhập thành công
      const token = jwt.sign(
        { userId: user.uid, email: user.email },
        process.env.JWT_SECRET,  // Mã bí mật để tạo token
        { expiresIn: '30d' }  // Token hết hạn sau 30 ngày
      );
  
      // Gọi hàm loadAllNotifications để lấy các thông tin cần thiết
      const notificationsData = await this.loadAllNotifications({ uid: user.uid });
  
      // Trả về token và thông tin lịch
      return { success: true, token: token, notifications: notificationsData };
    } catch (err) {
      return { success: false, message: err.message };  // Trả về lỗi nếu có
    }
  }
  
  async loadAllNotifications({ uid }) {
    try {
      // Lấy lịch từ MongoDB cho người dùng
      const workoutScheduleSnapshot = await WorkoutSchedule.find({ uid: uid });
  
      const notifications = [];
  
      // Duyệt qua các lịch và lấy các thông tin cần thiết
      for (const workoutScheduleDoc of workoutScheduleSnapshot) {
        const { notify, id, hour, day, name, repeatInterval, id_cate, pic, difficulty } = workoutScheduleDoc;
  
        // Kiểm tra nếu notify là false, bỏ qua và không làm gì
        if (!notify) {
          continue;
        }
  
        const selectedDay = new Date(day);  // Chuyển ngày thành đối tượng Date
        const selectedHour = new Date(`1970-01-01T${hour}:00Z`);  // Chuyển giờ thành đối tượng Date
        const selectedDateTime = new Date(selectedDay.setHours(selectedHour.getHours(), selectedHour.getMinutes()));
  
        // Kiểm tra nếu lịch là trong quá khứ và không phải lịch lặp lại
        if (selectedDateTime < new Date() && repeatInterval === 'no') {
          continue; // Bỏ qua lịch đã qua và không phải lịch lặp lại
        }
  
        // Thêm thông tin vào danh sách thông báo
        notifications.push({
          id,
          scheduledTime: selectedDateTime,
          workoutName: name,
          repeatInterval,
          id_cate,
          pic,
          diff: difficulty
        });
      }
  
      return notifications; 
    } catch (err) {
      return { success: false, message: err.message }; 
    }
  }

  async completeUserProfile({ uid, dateOfBirth, gender, weight, height }) {
    let res = "Có lỗi gì đó xảy ra";
    let pic = "";  // Giả sử bạn không sử dụng ảnh đại diện trong ví dụ này.
  
    // Kiểm tra đầu vào
    if (!dateOfBirth || !gender || !weight || !height) {
      return "Vui lòng điền đầy đủ thông tin.";
    }
    if (isNaN(weight) || parseFloat(weight) <= 30) {
      return "Cân nặng phải là số và lớn hơn 30.";
    }
    if (isNaN(height) || parseFloat(height) <= 50 || parseFloat(height) >= 300) {
      return "Chiều cao phải là số và lớn hơn 50 và nhỏ hơn 300.";
    }
  
    try {
      // Tìm và cập nhật thông tin người dùng trong MongoDB
      const updatedUser = await User.findOneAndUpdate(
        { uid: uid }, // Tìm người dùng theo uid
        {
          date_of_birth: dateOfBirth,
          gender: gender,
          weight: weight,
          height: height,
          pic: pic, 
        },
        { new: true }  
      );
  
      if (updatedUser) {
        res = "success";
      } else {
        res = "Không tìm thấy người dùng.";
      }
    } catch (e) {
      res = e.toString();
    }
  
    return res;
  }

  async getUserInfo(uid) {
    try {
      const user = await User.findById(uid);  
      if (user) {
        return user;  
      } else {
        return null;  
      }
    } catch (error) {
      console.error('Error fetching user info:', error);
      throw error;
    }
  }

  async updateUserProfileImage(uid, imageUrl) {
    try {
      const updatedUser = await User.findByIdAndUpdate(uid, {
        pic: imageUrl,  
      }, { new: true });  
  
      if (updatedUser) {
        console.log('User profile image updated successfully');
      } else {
        console.log('User not found');
      }
    } catch (error) {
      console.error('Error updating user profile image:', error);
      throw error;
    }
  }
  
  async updateUserLevel(uid, level) {
    try {
      const updatedUser = await User.findByIdAndUpdate(uid, {
        level: level, 
      }, { new: true }); 
  
      if (updatedUser) {
        console.log('User level updated successfully');
      } else {
        console.log('User not found');
      }
    } catch (error) {
      console.error('Error updating user level:', error);
      throw error;
    }
  }
  
}

module.exports = new AuthService();
