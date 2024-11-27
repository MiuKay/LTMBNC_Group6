const express = require("express");
const router = express.Router();
const workoutService = require("../services/workoutService");
const workoutController = require('../controller/workoutController');

router.get("/category-workouts", async (req, res) => {
    try {
        const categoryWorkoutList = await workoutService.fetchCategoryWorkoutList();
        res.status(200).json(categoryWorkoutList);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// API: Lấy danh sách CategoryWorkout theo level
router.get("/category-workouts/:level", async (req, res) => {
    try {
        const level = req.params.level;
        const categoryWorkoutList = await workoutService.fetchCategoryWorkoutWithLevelList(level);
        res.status(200).json(categoryWorkoutList);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// API: Fetch tools for a specific category
router.get("/tools/:categoryId", async (req, res) => {
    try {
        const categoryId = req.params.categoryId;
        const toolsList = await workoutService.fetchToolsForCategory(categoryId);
        res.status(200).json(toolsList);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// API: Fetch exercises by category and difficulty
router.get("/exercises", async (req, res) => {
    try {
        const { categoryId, difficulty } = req.query;
        if (!categoryId || !difficulty) {
            return res.status(400).json({ error: "categoryId and difficulty are required" });
        }

        const exercises = await workoutService.fetchExercisesByCategoryAndDifficulty(categoryId, difficulty);
        res.status(200).json(exercises);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// API: Fetch time and calories burned
router.get("/time-and-calo", async (req, res) => {
    try {
        const { categoryId, difficulty } = req.query;

        if (!categoryId || !difficulty) {
            return res.status(400).json({ error: "categoryId and difficulty are required" });
        }

        const result = await workoutService.fetchTimeAndCalo(categoryId, difficulty);
        res.status(200).json(result);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// API: Fetch step exercises by name
router.get("/step-exercises/:name", async (req, res) => {
    try {
        const { name } = req.params;
        const steps = await workoutService.fetchStepExercises(name);
        res.status(200).json(steps);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Lấy lịch trình tập luyện
router.get('/schedule', async (req, res) => {
  const { userId } = req.query;
  try {
    const schedules = await workoutService.fetchWorkoutSchedule(userId);
    res.status(200).json(schedules);
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});


router.post('/schedule', async (req, res) => {
  try {
    const response = await workoutService.addWorkoutSchedule(req.body);
    res.status(200).json(response);
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

router.delete('/:scheduleId', workoutController.deleteWorkoutSchedule);
router.get('/:scheduleId', workoutController.getWorkoutScheduleById);
router.put('/update', workoutController.updateSchedule);
router.post('/history', workoutController.createEmptyWorkoutHistory);

module.exports = router;
