const workoutService = require('../services/workoutService');

// Xử lý yêu cầu xóa lịch tập
const deleteWorkoutSchedule = async (req, res) => {
  try {
    const { scheduleId } = req.params;
    const result = await workoutService.deleteWorkoutSchedule(scheduleId);
    res.status(200).json({ message: result });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
};

// Xử lý yêu cầu lấy lịch tập theo ID
const getWorkoutScheduleById = async (req, res) => {
  try {
    const { scheduleId } = req.params;
    const schedule = await workoutService.getWorkoutScheduleById(scheduleId);
    res.status(200).json(schedule);
  } catch (e) {
    res.status(404).json({ error: e.message });
  }
};

// Xử lý yêu cầu cập nhật lịch tập
const updateSchedule = async (req, res) => {
  try {
    const updatedData = req.body;
    const result = await workoutService.updateSchedule(updatedData);
    res.status(200).json({ message: result });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
};

// Xử lý yêu cầu tạo lịch sử bài tập
const createEmptyWorkoutHistory = async (req, res) => {
  try {
    const historyData = req.body;
    const workoutId = await workoutService.createEmptyWorkoutHistory(historyData);
    res.status(201).json({ workoutId });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
};

module.exports = {
  deleteWorkoutSchedule,
  getWorkoutScheduleById,
  updateSchedule,
  createEmptyWorkoutHistory,
};
