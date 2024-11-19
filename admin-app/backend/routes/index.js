// Import các module cần thiết
const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const bodyParser = require("body-parser");

// Khởi tạo ứng dụng Express
const app = express();

// Sử dụng middleware
app.use(cors()); // Cho phép CORS
app.use(bodyParser.json()); // Phân tích dữ liệu JSON từ request

// Kết nối tới MongoDB
mongoose.connect("mongodb://localhost:27017/fitnessApp", {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
    .then(() => console.log("MongoDB connected"))
    .catch((err) => console.error("MongoDB connection error: ", err));

// Import các routes
const userRoutes = require("./userRoutes");
const exerciseRoutes = require("./exerciseRoutes");
const stepExerciseRoutes = require("./stepExerciseRoutes");
const tipRoutes = require("./tipRoutes");
const workoutScheduleRoutes = require("./workoutScheduleRoutes");

// Sử dụng các routes
app.use("/api/v1/users", userRoutes);
app.use("/api/v1/exercises", exerciseRoutes);
app.use("/api/v1/stepExercises", stepExerciseRoutes);
app.use("/api/v1/tips", tipRoutes);
app.use("/api/v1/workoutSchedules", workoutScheduleRoutes);

// Khởi tạo port cho ứng dụng
const PORT = process.env.PORT || 5000;

// Lắng nghe yêu cầu từ client
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
