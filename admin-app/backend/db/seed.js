const mongoose = require("mongoose");
const UserModel = require("../models/UserModel");
const Exercise = require("../models/Exercise");
const StepExercise = require("../models/StepExercise");
const Tip = require("../models/Tip");
const WorkoutSchedule = require("../models/WorkoutSchedule");

// Kết nối MongoDB
mongoose
    .connect("mongodb://localhost:27017/fitnessApp", {
        useNewUrlParser: true,
        useUnifiedTopology: true,
    })
    .then(() => console.log("MongoDB connected"))
    .catch((err) => console.error("MongoDB connection error:", err));

// Dữ liệu mẫu
const userSample = {
    uid: "user123",
    fname: "John",
    lname: "Doe",
    email: "johndoe@example.com",
    dateOfBirth: "15/08/1990",
    gender: "Male",
    weight: "70",
    height: "175",
    pic: "profile_pic.jpg",
    level: "Intermediate",
};

const exerciseSample = {
    calo: 200,
    descriptions: "Push-ups for upper body strength",
    difficulty: "Easy",
    name: "Push-ups",
    pic: "pushups.jpg",
    rep: 20,
    time: 30,
    video: "pushups_tutorial.mp4",
};

const stepExerciseSample = {
    name: "Push-ups",
    step: 1,
    title: "Get into position",
    detail: "Start in a plank position with your arms straight and hands shoulder-width apart.",
};

const tipSample = {
    detail: "Drink water regularly to stay hydrated.",
    name: "Hydration",
    pic: "hydration.jpg",
};

const workoutScheduleSample = {
    id: "schedule001",
    uid: "user123",
    name: "Morning Routine",
    day: "Monday",
    hour: "07:00",
    difficulty: "Medium",
    notify: true,
    repeatInterval: "Weekly",
};

// Hàm lưu dữ liệu mẫu vào MongoDB
const seedData = async () => {
    try {
        // Tạo dữ liệu mẫu
        await UserModel.create(userSample);
        console.log("User sample created");

        await Exercise.create(exerciseSample);
        console.log("Exercise sample created");

        await StepExercise.create(stepExerciseSample);
        console.log("StepExercise sample created");

        await Tip.create(tipSample);
        console.log("Tip sample created");

        await WorkoutSchedule.create(workoutScheduleSample);
        console.log("WorkoutSchedule sample created");
    } catch (err) {
        console.error("Error seeding data:", err);
    } finally {
        mongoose.connection.close();
    }
};

// Gọi hàm seedData
seedData();
