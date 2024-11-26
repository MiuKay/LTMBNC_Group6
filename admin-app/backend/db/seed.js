const mongoose = require("mongoose");
const UserModel = require("../models/UserModel");
const Exercise = require("../models/Exercise");
const StepExercise = require("../models/StepExercise");
const Tip = require("../models/Tip");
const CategoryWorkout = require("../models/CategoryWorkout");
const Tools = require("../models/Tools");
const WorkoutModel = require("../models/WorkoutModel");

// Kết nối MongoDB
mongoose
    .connect("mongodb://localhost:27017/fitnessApp", {
        useNewUrlParser: true,
        useUnifiedTopology: true,
    })
    .then(() => console.log("MongoDB connected"))
    .catch((err) => console.error("MongoDB connection error:", err));

// Dữ liệu mẫu cho User
const userSamples = [
    { fname: "John", lname: "Doe", email: "johndoe@example.com", date_of_birth: "15/08/1990", gender: "male", weight: "70", height: "175", level: "Lean & Tone" },
    { fname: "Jane", lname: "Smith", email: "janesmith@example.com", date_of_birth: "20/05/1992", gender: "female", weight: "60", height: "165", level: "Improve Shape" },
];

// Dữ liệu mẫu cho Exercise
const exerciseSamples = [
    { calo: 200, descriptions: "Push-ups for upper body strength", difficulty: "Easy", name: "Push-ups", rep: 20, time: 30 },
    { calo: 150, descriptions: "Squats for lower body strength", difficulty: "Medium", name: "Squats", rep: 15, time: 25 },
];

// Dữ liệu mẫu cho StepExercise
const stepExerciseSamples = [
    { name: "Push-ups", step: 1, title: "Get into position", detail: "Start in a plank position with your arms straight." },
    { name: "Squats", step: 1, title: "Stand tall", detail: "Stand with your feet shoulder-width apart." },
];

// Dữ liệu mẫu cho Tip
const tipSamples = [
    { detail: "Drink water regularly to stay hydrated.", name: "Hydration" },
    { detail: "Warm up before exercising to prevent injuries.", name: "Warm-up" },
];

// Dữ liệu mẫu cho CategoryWorkout
const categoryWorkoutSamples = [
    { level: ["Lose a Fat","Lean & Tone"], name: "Full body" },
    { level: ["Lean & Tone"], name: "Upper body" },
    { level: ["Improve Shape"], name: "Lower body" },
];

// Dữ liệu mẫu cho Tools
const toolsSamples = [
    { name: "Skipping rope" },
    { name: "Dumbbells" },
    { name: "Resistance bands" },
];

// Dữ liệu mẫu cho Workout
const workoutSamples = [
    { id_cate: "1", name_exercise: "Push-ups", step: 1 },
    { id_cate: "2", name_exercise: "Squats", step: 1 },
    { id_cate: "3", name_exercise: "Lunges", step: 1 },
];

// Hàm lưu dữ liệu mẫu vào MongoDB
const seedData = async () => {
    try {
        // Tạo dữ liệu mẫu cho User
        await UserModel.insertMany(userSamples);
        console.log("User samples created");

        // Tạo dữ liệu mẫu cho Exercise
        await Exercise.insertMany(exerciseSamples);
        console.log("Exercise samples created");

        // Tạo dữ liệu mẫu cho StepExercise
        await StepExercise.insertMany(stepExerciseSamples);
        console.log("StepExercise samples created");

        // Tạo dữ liệu mẫu cho Tip
        await Tip.insertMany(tipSamples);
        console.log("Tip samples created");

        // Tạo dữ liệu mẫu cho CategoryWorkout
        const categories = await CategoryWorkout.insertMany(categoryWorkoutSamples);
        console.log("CategoryWorkout samples created");

        // Tạo dữ liệu mẫu cho Workout
        workoutSamples.forEach(workout => {
            workout.id_cate = categories[Math.floor(Math.random() * categories.length)].id; // Gán id_cate ngẫu nhiên từ các category đã tạo
        });
        await WorkoutModel.insertMany(workoutSamples);
        console.log("Workout samples created");

        // Tạo dữ liệu mẫu cho Tools
        await Tools.insertMany(toolsSamples);
        console.log("Tools samples created");

        // Kiểm tra các Workout còn lại
        const be4delWorkouts = await WorkoutModel.find();
        console.log("Before delete Workouts:", be4delWorkouts);

/*         // Bước 1: Xóa một CategoryWorkout
        const categoryToDelete = categories[2]; // Lấy category đầu tiên
        await CategoryWorkout.findByIdAndDelete(categoryToDelete._id); // Xóa CategoryWorkout
        console.log(`CategoryWorkout with id ${categoryToDelete.id} deleted`);

        // Bước 2: Tìm và xóa các Workout có id_cate tương ứng
        await WorkoutModel.deleteMany({ id_cate: categoryToDelete.id }); // Xóa các Workout
        console.log(`Del workouts with id_cate: ${categoryToDelete.id}`); */

        // Kiểm tra các Workout còn lại
        const remainingWorkouts = await WorkoutModel.find();
        console.log("Remaining Workouts:", remainingWorkouts);
    } catch (err) {
        console.error("Error seeding data:", err);
    } finally {
        mongoose.connection.close();
    }
};

// Gọi hàm seedData
seedData();
