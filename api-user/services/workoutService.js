const CategoryWorkout = require("../models/CategoryWorkout");
const Workout = require("../models/Workout");
const Exercise = require("../models/Exercises");
const CateWorkTool = require("../models/CateWork_tool");
const Tool = require("../models/Tool");
const StepExercise = require("../models/Step_exercises");
const WorkoutSchedule = require('../models/WorkoutSchedule'); 
const moment = require('moment');

class WorkoutService {
    // Fetch CategoryWorkout List
    async fetchCategoryWorkoutList() {
        try {
            const categoryWorkoutList = [];

            // Lấy tất cả các CategoryWorkout
            const categories = await CategoryWorkout.find();

            for (const category of categories) {
                const categoryId = category._id;
                const image = category.pic;
                const title = category.name;

                // Lấy tất cả các Workout thuộc category hiện tại
                const workouts = await Workout.find({ id_cate: categoryId });
                const exerciseCount = workouts.length;

                // Lấy danh sách các exercise name
                const exerciseNames = [...new Set(workouts.map(workout => workout.name_exercise))];

                // Lấy danh sách các Exercise với difficulty 'Beginner'
                const exercises = await Exercise.find({
                    name: { $in: exerciseNames },
                    difficulty: "Beginner",
                });

                // Tính tổng thời gian và calo
                const totalTimeInSeconds = exercises.reduce((sum, exercise) => {
                    const time = parseInt(exercise.time, 10) || 0;
                    return sum + time;
                }, 0);

                const totalCalo = exercises.reduce((sum, exercise) => {
                    const calo = parseInt(exercise.calo, 10) || 0;
                    return sum + calo;
                }, 0);

                const totalTimeInMinutes = Math.round(totalTimeInSeconds / 60);

                // Thêm dữ liệu vào danh sách
                categoryWorkoutList.push({
                    id: categoryId,
                    image,
                    title,
                    exercises: `${exerciseCount} Exercises`,
                    time: `${totalTimeInMinutes} Mins`,
                    calo: `${totalCalo} Calories Burn`,
                    difficulty: "Beginner",
                });
            }

            return categoryWorkoutList;
        } catch (error) {
            console.error("Error fetching category workouts:", error);
            throw new Error("Failed to fetch category workouts");
        }
    }

    // Fetch CategoryWorkout List by Level
    async fetchCategoryWorkoutWithLevelList(level) {
        try {
            const categoryWorkoutList = [];
            const categories = await CategoryWorkout.find({ level: level });

            for (const category of categories) {
                const categoryId = category._id;
                const image = category.pic;
                const title = category.name;

                const workouts = await Workout.find({ id_cate: categoryId });
                const exerciseCount = workouts.length;

                const exerciseNames = [...new Set(workouts.map(workout => workout.name_exercise))];

                if (exerciseNames.length > 0) {
                    const exercises = await Exercise.find({
                        name: { $in: exerciseNames },
                        difficulty: "Beginner",
                    });

                    const totalTimeInSeconds = exercises.reduce((sum, exercise) => {
                        const time = parseInt(exercise.time, 10) || 0;
                        return sum + time;
                    }, 0);

                    const totalCalo = exercises.reduce((sum, exercise) => {
                        const calo = parseInt(exercise.calo, 10) || 0;
                        return sum + calo;
                    }, 0);

                    const totalTimeInMinutes = Math.round(totalTimeInSeconds / 60);

                    categoryWorkoutList.push({
                        id: categoryId,
                        image,
                        title,
                        exercises: `${exerciseCount} Exercises`,
                        time: `${totalTimeInMinutes} Mins`,
                        calo: `${totalCalo} Calories Burn`,
                        difficulty: "Beginner",
                    });
                }
            }

            return categoryWorkoutList;
        } catch (error) {
            console.error("Error fetching category workouts by level:", error);
            throw new Error("Failed to fetch category workouts by level");
        }
    }

    // Fetch tools for a specific category
    async fetchToolsForCategory(categoryId) {
        try {
            // Step 1: Fetch tool IDs from CateWork_tool
            const cateWorkTools = await CateWorkTool.find({ id_cate: categoryId });
            const toolIds = cateWorkTools.map(doc => doc.id_tool);

            if (toolIds.length > 0) {
                // Step 2: Fetch tool details
                const tools = await Tool.find({ _id: { $in: toolIds } });
                return tools.map(tool => ({
                    id: tool._id,
                    title: tool.name,
                    image: tool.pic,
                }));
            }
            return [];
        } catch (error) {
            console.error("Error fetching tools:", error);
            throw new Error("Failed to fetch tools");
        }
    }

    // Fetch exercises by category and difficulty
    async fetchExercisesByCategoryAndDifficulty(categoryId, difficulty) {
        try {
            // Step 1: Fetch workouts sorted by step
            const workouts = await Workout.find({ id_cate: categoryId }).sort({ step: 1 });

            // Get unique exercise names
            const exerciseNames = [...new Set(workouts.map(workout => workout.name_exercise))];

            if (exerciseNames.length > 0) {
                // Step 2: Fetch exercises matching the names and difficulty
                const exercises = await Exercise.find({
                    name: { $in: exerciseNames },
                    difficulty: difficulty,
                });

                // Map exercises for quick lookup
                const exerciseMap = {};
                exercises.forEach(exercise => {
                    exerciseMap[exercise.name] = exercise;
                });

                // Sort exercises by the original workout order
                return exerciseNames
                    .filter(name => exerciseMap[name]) // Filter valid exercises
                    .map(name => exerciseMap[name]);  // Map to sorted exercises
            }
            return [];
        } catch (error) {
            console.error("Error fetching exercises:", error);
            throw new Error("Failed to fetch exercises");
        }
    }

    async fetchTimeAndCalo(categoryId, difficulty) {
        try {
            // Step 1: Fetch workouts by category
            const workouts = await Workout.find({ id_cate: categoryId });

            // Collect all unique exercise names
            const exerciseNames = [...new Set(workouts.map(workout => workout.name_exercise))];

            if (exerciseNames.length === 0) return { time: "0 Mins", calo: "0 Calo Burned" };

            // Step 2: Fetch exercises by names and difficulty
            const exercises = await Exercise.find({
                name: { $in: exerciseNames },
                difficulty: difficulty,
            });

            // Step 3: Calculate total time and calories
            let totalTimeInSeconds = 0;
            let totalCalo = 0;

            exercises.forEach(exercise => {
                // Parse time and calories to integers if they are strings
                const time = typeof exercise.time === "string" ? parseInt(exercise.time, 10) : exercise.time;
                const calo = typeof exercise.calo === "string" ? parseInt(exercise.calo, 10) : exercise.calo;

                totalTimeInSeconds += time || 0;
                totalCalo += calo || 0;
            });

            // Convert total time in seconds to minutes
            const totalTimeInMinutes = Math.round(totalTimeInSeconds / 60);

            return {
                time: `${totalTimeInMinutes} Mins`,
                calo: `${totalCalo} Calo Burned`,
            };
        } catch (error) {
            console.error("Error fetching time and calories:", error);
            throw new Error("Failed to fetch time and calories");
        }
    }

    // Fetch step exercises for a specific exercise name
    async fetchStepExercises(name) {
        try {
            // Fetch step exercises by name and sort by step order
            const stepExercises = await StepExercise.find({ name }).sort({ step: 1 });

            // Convert to plain objects if needed
            return stepExercises.map(stepExercise => ({
                id: stepExercise._id,
                ...stepExercise.toObject(),
            }));
        } catch (error) {
            console.error("Error fetching step exercises:", error);
            throw new Error("Failed to fetch step exercises");
        }
    }

    fetchWorkoutSchedule = async (userId) => {
        const workoutList = [];
        const endDate = moment().add(30, 'days'); // 30 ngày tới
        const dateFormat = 'DD/MM/YYYY hh:mm A'; // Định dạng ngày
        const hourFormat = 'hh:mm A'; // Định dạng giờ
      
        try {
          const schedules = await WorkoutSchedule.find({ uid: userId }).lean();
      
          for (const doc of schedules) {
            const repeatInterval = doc.repeat_interval;
            const startDate = moment(doc.day, 'DD/MM/YYYY'); // Parse ngày
            const hourTime = moment(doc.hour, hourFormat); // Parse giờ
      
            if (repeatInterval === 'no') {
              // Không lặp lại, chỉ thêm vào ngày chỉ định
              const eventTime = moment(startDate).set({
                hour: hourTime.hour(),
                minute: hourTime.minute(),
              });
              workoutList.push({
                name: doc.name,
                start_time: eventTime.format(dateFormat),
                id: doc.id,
              });
            } else if (repeatInterval === 'Everyday') {
              // Lặp lại hàng ngày
              let currentDate = startDate.clone();
              while (currentDate.isBefore(endDate)) {
                const eventTime = currentDate.clone().set({
                  hour: hourTime.hour(),
                  minute: hourTime.minute(),
                });
                workoutList.push({
                  name: doc.name,
                  start_time: eventTime.format(dateFormat),
                  id: doc.id,
                });
                currentDate.add(1, 'days'); // Tiến tới ngày tiếp theo
              }
            } else {
              // Lặp lại theo ngày cụ thể trong tuần
              const daysOfWeek = repeatInterval.split(',');
              let currentDate = startDate.clone().startOf('week'); // Đầu tuần
      
              while (currentDate.isBefore(endDate)) {
                for (const day of daysOfWeek) {
                  const eventDay = findNextDateForDay(day, currentDate);
                  if (eventDay.isBetween(startDate.clone().subtract(1, 'days'), endDate)) {
                    const eventTime = eventDay.clone().set({
                      hour: hourTime.hour(),
                      minute: hourTime.minute(),
                    });
                    workoutList.push({
                      name: doc.name,
                      start_time: eventTime.format(dateFormat),
                      id: doc.id,
                    });
                  }
                }
                currentDate.add(7, 'days'); // Tiến tới tuần tiếp theo
              }
            }
          }
        } catch (e) {
          console.error("Error fetching workout schedule:", e);
        }
        return workoutList;
      };
      
    findNextDateForDay = (day, currentDate) => {
        const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
        const targetDayIndex = days.indexOf(day);
        const daysToAdd = (targetDayIndex - currentDate.isoWeekday() + 7) % 7 || 7;
        return currentDate.clone().add(daysToAdd, 'days');
      };

    // Xóa lịch tập
    deleteWorkoutSchedule = async (scheduleId) => {
    try {
      const schedule = await WorkoutSchedule.findOne({ id: scheduleId });
      if (!schedule) {
        throw new Error('Schedule not found.');
      }
  
      const notificationId = schedule.id_notify;
      if (notificationId) {
        await NotificationService.cancelNotificationById(parseInt(notificationId));
      }
  
      await WorkoutSchedule.deleteOne({ id: scheduleId });
  
      return 'success';
    } catch (e) {
      console.error(`Error deleting workout schedule: ${e}`);
      throw new Error(e.message);
    }
  };
  
  // Lấy lịch tập theo ID
  getWorkoutScheduleById = async (scheduleId) => {
    try {
      const schedule = await WorkoutSchedule.findOne({ id: scheduleId });
      if (!schedule) {
        throw new Error('Workout schedule not found.');
      }
      return schedule;
    } catch (e) {
      console.error(`Error fetching workout schedule: ${e}`);
      throw new Error(e.message);
    }
  };
  
  // Cập nhật lịch tập
  updateSchedule = async ({
    id,
    day,
    difficulty,
    hour,
    name,
    repeatInterval,
    uid,
    notify,
    id_notify,
  }) => {
    try {
      if (!name || !difficulty) {
        throw new Error('Name and difficulty must not be empty.');
      }
  
      const category = await CategoryWorkout.findOne({ name });
      if (!category) {
        throw new Error('Category not found.');
      }
  
      const selectedDateTime = moment(`${day} ${hour}`, 'DD/MM/YYYY hh:mm A');
      if (selectedDateTime.isBefore(moment())) {
        throw new Error('The selected date and time cannot be in the past.');
      }
  
      const isDuplicate = await WorkoutSchedule.findOne({
        uid,
        day,
        hour,
        _id: { $ne: id }, // Loại trừ sự kiện hiện tại
      });
  
      if (isDuplicate) {
        throw new Error('A workout is already scheduled for this day and time.');
      }
  
      if (id_notify) {
        await NotificationService.cancelNotificationById(parseInt(id_notify));
      }
  
      let newNotifyId = id_notify;
      if (notify) {
        newNotifyId = await NotificationService.scheduleWorkoutNotification({
          id,
          scheduledTime: selectedDateTime.toDate(),
          workoutName: name,
          repeatInterval,
          id_cate: category._id,
          pic: category.pic,
          diff: difficulty,
        });
      }
  
      await WorkoutSchedule.findOneAndUpdate(
        { id },
        {
          difficulty,
          hour,
          name,
          repeat_interval: repeatInterval,
          notify,
          id_cate: category._id,
          pic: category.pic,
          id_notify: newNotifyId,
        }
      );
  
      return 'success';
    } catch (e) {
      console.error(`Error updating workout schedule: ${e}`);
      throw new Error(e.message);
    }
  };
  
  // Tạo lịch sử bài tập trống
  createEmptyWorkoutHistory = async ({ uid, idCate, exercisesArr, difficulty }) => {
    try {
      const historyData = {
        uid,
        id_cate: idCate,
        exercisesArr: exercisesArr.map((e) => e.toObject()),
        index: 0,
        duration: 0,
        caloriesBurned: 0,
        completedAt: null,
        difficulty,
      };
  
      const newHistory = new WorkoutHistory(historyData);
      const savedHistory = await newHistory.save();
  
      await WorkoutHistory.findByIdAndUpdate(savedHistory._id, { id: savedHistory._id });
  
      return savedHistory._id;
    } catch (e) {
      console.error(`Error creating workout history: ${e}`);
      throw new Error(e.message);
    }
  };
      
}

module.exports = new WorkoutService();