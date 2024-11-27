const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const User = require('../models/user');
const WorkoutSchedule = require('../models/WorkoutSchedule');
const mongoose = require('mongoose');
const nodemailer = require('nodemailer');

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
        if (!email || !password) {
            return { success: false, message: "Vui lòng nhập đầy đủ thông tin" };
        }

        const emailRegex = /^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+$/;
        if (!emailRegex.test(email)) {
            return { success: false, message: "Vui lòng nhập đúng định dạng email" };
        }

        const user = await User.findOne({ email });
        if (!user) {
            return { success: false, message: "Không tìm thấy tài khoản với email này." };
        }

        if (!user.activate) {
            return { success: false, message: "Tài khoản chưa được kích hoạt" };
        }

        const isPasswordCorrect = await bcrypt.compare(password, user.password);
        if (!isPasswordCorrect) {
            return { success: false, message: "Mật khẩu không chính xác" };
        }

        const token = jwt.sign(
            { userId: user.uid, email: user.email },
            process.env.JWT_SECRET,
            { expiresIn: '30d' }
        );

        const notificationsData = await this.loadAllNotifications({ uid: user.uid });

        return { success: true, token: token, notifications: notificationsData };
    } catch (err) {
        return { success: false, message: err.message };
    }
  }

  async loadAllNotifications({ uid }) {
    try {
      // Lấy lịch từ MongoDB cho người dùng
      const workoutScheduleSnapshot = await WorkoutSchedule.find({ uid: uid });
  
      const notifications = [];
  
      // Duyệt qua các lịch và lấy các thông tin cần thiết
      for (const workoutScheduleDoc of workoutScheduleSnapshot) {
        const { notify, id, hour, day, name, repeat_interval, id_cate, pic, difficulty, id_notify } = workoutScheduleDoc;
  
        // Kiểm tra nếu notify là false, bỏ qua và không làm gì
        if (!notify) {
          continue;
        }
  
        const selectedDay = new Date(day);  // Chuyển ngày thành đối tượng Date
        const selectedHour = new Date(`1970-01-01T${hour}:00Z`);  // Chuyển giờ thành đối tượng Date
        const selectedDateTime = new Date(selectedDay.setHours(selectedHour.getHours(), selectedHour.getMinutes()));
  
        // Kiểm tra nếu lịch là trong quá khứ và không phải lịch lặp lại
        if (selectedDateTime < new Date() && repeat_interval === 'no') {
          continue; // Bỏ qua lịch đã qua và không phải lịch lặp lại
        }
  
        // Thêm thông tin vào danh sách thông báo
        notifications.push({
          id,
          scheduledTime: selectedDateTime,
          workoutName: name,
          repeat_interval,
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

  async forgetPassword(email, newPass, otp) {
    try {
      // Kiểm tra định dạng email
      if (!/^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+$/.test(email)) {
        return "Vui lòng điền đúng định dạng email";
      }
  
      // Tìm người dùng bằng email
      const user = await User.findOne({ email });
      if (!user) {
        return "Không tìm thấy người dùng.";
      }
  
      // Kiểm tra OTP
      if (!user.otp || !user.expiresAt) {
        return "OTP không tồn tại.";
      }
      if (Date.now().millisecondsSinceEpoch > user.expiresAt) {
        return "OTP đã hết hạn.";
      }
      if (user.otp !== otp) {
        return "OTP không đúng.";
      }

      // Mã hóa mật khẩu
      const hashedPassword = await bcrypt.hash(newPass, 10);
  
      // Cập nhật mật khẩu
      user.password = hashedPassword; 

      await user.save();
  
      return "success";
    } catch (error) {
      console.error("Error resetting password:", error);
      return `Có lỗi xảy ra: ${error.message}`;
    }
  };
  
  async sendOtpEmail(uid) {
    try {
      // Tìm người dùng bằng UID
      const user = await User.findById(uid);
      if (!user) {
        return "Không tìm thấy người dùng.";
      }
  
      // Tạo OTP
      const otp = await this.generateOtp();
      const expiryTime = Date.now() + 2 * 60 * 1000; // 2 phút
  
      // Cập nhật OTP và thời gian hết hạn
      user.otp = otp;
      user.expiresAt = expiryTime;
      await user.save();
  
      const smtpServer = nodemailer.createTransport({
        service: 'gmail',
        auth: {
          user: 'tvih6693@gmail.com',
          pass: 'sssq sgfi oifh kxja',
        },
      });
      const message = {
        from: 'fitnessapp@gmail.com',
        to: user.email,
        subject: 'Mã OTP của bạn',
        text: `Mã OTP của bạn là: ${otp}. Mã này có hiệu lực trong 2 phút.`,
      };
  
      // Gửi email
      await smtpServer.sendMail(message);

      return "success";
    } catch (error) {
      console.error("Error sending OTP email:", error);
      return `Có lỗi xảy ra: ${error.message}`;
    }
  };

  async sendOtpEmailResetPass(email) {
    try {
      // Kiểm tra định dạng email
      if (!/^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+$/.test(email)) {
        return "Vui lòng điền đúng định dạng email";
      }
  
      // Tìm người dùng bằng email
      const user = await User.findOne({ email });
      if (!user) {
        return "Không tìm thấy người dùng.";
      }
  
      // Tạo OTP
      const otp = await this.generateOtp();
      const expiryTime = Date.now() + 2 * 60 * 1000; // 2 phút
  
      // Cập nhật OTP và thời gian hết hạn
      user.otp = otp;
      user.expiresAt = expiryTime;
      await user.save();
  
      // Cấu hình và gửi email
      const smtpServer = nodemailer.createTransport({
        service: 'gmail',
        auth: {
          user: 'tvih6693@gmail.com',
          pass: 'sssq sgfi oifh kxja',
        },
      });
      const message = {
        from: 'fitnessapp@gmail.com',
        to: user.email,
        subject: 'Mã OTP của bạn',
        text: `Mã OTP của bạn là: ${otp}. Mã này có hiệu lực trong 2 phút.`,
      };
  
      // Gửi email
      await smtpServer.sendMail(message);

      return "success";
    } catch (error) {
      console.error("Error sending OTP email:", error);
      return `Có lỗi xảy ra: ${error.message}`;
    }
  };

  async verifyOtp(uid, otp){
    try {
      // Tìm người dùng bằng UID
      const user = await User.findById(uid);
      if (!user) {
        return "OTP không tồn tại.";
      }
  
      // Kiểm tra OTP và thời gian hết hạn
      if (!user.otp || !user.expiresAt) {
        return "OTP không hợp lệ.";
      }
      if (Date.now() > user.expiresAt) {
        return "OTP đã hết hạn.";
      }
      if (user.otp !== otp) {
        return "OTP không đúng.";
      }
  
      // Kích hoạt tài khoản
      user.activate = true;

      await user.save();
  
      return "success";
    } catch (error) {
      console.error("Error verifying OTP:", error);
      return `Có lỗi xảy ra: ${error.message}`;
    }
  };
  
  async generateOtp(){
    return Math.random().toString().slice(2, 8); // Tạo OTP 6 chữ số
  };
  
}

module.exports = new AuthService();
