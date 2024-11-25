const WorkoutSchedule = require('../models/workoutScheduleModel'); 

const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');
const format = require('date-fns/format');


function parseDate(str) {
    const [day, month, year] = str.split('/');
    return new Date(year, month - 1, day);
}

// Function to parse time strings in 'hh:mm AM/PM' format
function parseTime(str) {
    const [timePart, ampm] = str.split(' ');
    let [hourStr, minuteStr] = timePart.split(':');
    let hour = parseInt(hourStr);
    const minute = parseInt(minuteStr);

    if (ampm.toUpperCase() === 'PM' && hour !== 12) {
        hour += 12;
    } else if (ampm.toUpperCase() === 'AM' && hour === 12) {
        hour = 0;
    }

    return { hour, minute };
}

// Function to map weekday names to numbers (Sunday = 0, Monday = 1, ..., Saturday = 6)
function getWeekdayNumber(day) {
    switch (day.toLowerCase()) {
        case 'sunday': return 0;
        case 'monday': return 1;
        case 'tuesday': return 2;
        case 'wednesday': return 3;
        case 'thursday': return 4;
        case 'friday': return 5;
        case 'saturday': return 6;
        default: return -1;
    }
}

router.get('/user/:uid', async (req, res) => {
    try {
        const schedules = await WorkoutSchedule.find({ uid: req.params.uid });
        res.json(schedules);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});
  
//   // Add a new workout schedule
// POST /api/workoutSchedules
router.post('/', async (req, res) => {
    try {
        const { day, difficulty, hour, name, repeatInterval, uid } = req.body;
        const notify = true;

        // Validate inputs
        if (!name || !difficulty) {
            return res.status(400).json({ message: "Name and difficulty must not be empty." });
        }

        // Check for duplicate events
        const isDuplicate = await WorkoutSchedule.findOne({ uid, day, hour });
        if (isDuplicate) {
            return res.status(400).json({ message: "A workout is already scheduled for this day and time." });
        }

        const newSchedule = new WorkoutSchedule({
            _id: new mongoose.Types.ObjectId().toString(),
            uid,
            name,
            day,
            hour,
            difficulty,
            notify,
            repeatInterval,
            id_notify: "", // Implement notification logic if needed
        });

        await newSchedule.save();

        res.json({ message: "success" });
    } catch (err) {
        console.error("Error adding workout schedule:", err);
        res.status(500).json({ message: "Error adding workout schedule" });
    }
});

// Update a workout schedule by ID
router.put('/:id', async (req, res) => {
    try {
        const id = req.params.id;
        const { day, difficulty, hour, name, repeatInterval, uid } = req.body;
    
        // Validate inputs
        if (!name || !difficulty) {
            return res.status(400).json({ message: "Name and difficulty must not be empty." });
        }
    
        // Check for duplicate events
        const isDuplicate = await WorkoutSchedule.findOne({ uid, day, hour, _id: { $ne: id } });
        if (isDuplicate) {
            return res.status(400).json({ message: "A workout is already scheduled for this day and time." });
        }
    
        const schedule = await WorkoutSchedule.findById(id);
        if (!schedule) {
            return res.status(404).json({ message: "Workout schedule not found" });
        }
    
        schedule.day = day;
        schedule.difficulty = difficulty;
        schedule.hour = hour;
        schedule.name = name;
        schedule.repeatInterval  = repeatInterval;
    
        await schedule.save();
    
        res.json({ message: "success" });
    } catch (err) {
        console.error("Error updating workout schedule:", err);
        res.status(500).json({ message: "Error updating workout schedule" });
    }
});

// Delete a workout schedule by ID
router.delete('/:id', async (req, res) => {
    try {
        const id = req.params.id;

        await WorkoutSchedule.findByIdAndDelete(id);

        res.json({ message: "success" });
    } catch (err) {
        console.error("Error deleting workout schedule:", err);
        res.status(500).json({ message: "Error deleting workout schedule" });
    }
});

// GET /api/workoutSchedules/:userId
router.get('/:userId', async (req, res) => {
    try {
        const userId = req.params.userId;

        // Fetch schedules for the user
        const schedules = await WorkoutSchedule.find({ uid: userId });

        // Initialize the list to hold workout events
        const workoutList = [];

        // Set the end date to 30 days from now
        const endDate = new Date();
        endDate.setDate(endDate.getDate() + 30);

        // Process each schedule
        for (const schedule of schedules) {
            const repeatInterval = schedule.repeatInterval; // e.g., 'no', 'Everyday', 'Monday,Wednesday'
            const startDate = parseDate(schedule.day); // Parse 'day' from 'dd/MM/yyyy' format
            const name = schedule.name;
            const hour = schedule.hour; // e.g., '10:25 AM'
            const id = schedule._id.toString(); // Ensure id is a string

            // Parse the hour and minute from the 'hour' string
            const { hour: hourNum, minute: minuteNum } = parseTime(hour);

            // Determine how to process based on the repeat interval
            if (repeatInterval === "no") {
                // No repeat: Add the event only on the specified date and time
                const eventTime = new Date(
                    startDate.getFullYear(), startDate.getMonth(), startDate.getDate(),
                    hourNum, minuteNum, 0, 0
                );

                workoutList.push({
                    name: name,
                    start_time: eventTime.toISOString(),
                    id: id,
                });
            } else if (repeatInterval === "Everyday") {
                // Repeat every day: Add events from start date to end date
                let currentDate = new Date(startDate);
                while (currentDate <= endDate) {
                    const eventTime = new Date(
                        currentDate.getFullYear(), currentDate.getMonth(), currentDate.getDate(),
                        hourNum, minuteNum, 0, 0
                    );

                    const eventTimeFormatted = format(eventTime, 'dd/MM/yyyy hh:mm a');
                    workoutList.push({
                        name: name,
                        start_time: eventTimeFormatted,
                        id: id,
                    });
                    // Move to the next day
                    currentDate.setDate(currentDate.getDate() + 1);
                }
            } else {
                // Repeat on specific days of the week
                const daysOfWeek = repeatInterval.split(',').map(day => day.trim());
                const daysOfWeekNumbers = daysOfWeek.map(day => getWeekdayNumber(day));

                // Loop from start date to end date
                let currentDate = new Date(startDate);
                while (currentDate <= endDate) {
                    if (
                        currentDate >= startDate &&
                        daysOfWeekNumbers.includes(currentDate.getDay())
                    ) {
                        const eventTime = new Date(
                            currentDate.getFullYear(), currentDate.getMonth(), currentDate.getDate(),
                            hourNum, minuteNum, 0, 0
                        );
                        const eventTimeFormatted = format(eventTime, 'dd/MM/yyyy hh:mm a');
                        workoutList.push({
                            name: name,
                            start_time: eventTimeFormatted,
                            id: id,
                        });
                    }
                    // Move to the next day
                    currentDate.setDate(currentDate.getDate() + 1);
                }
            }
        }

        // Send the generated workout list as the response
        res.json(workoutList);
    } catch (err) {
        console.error("Error fetching workout schedule:", err);
        res.status(500).json({ message: "Error fetching workout schedule" });
    }
});


module.exports = router;