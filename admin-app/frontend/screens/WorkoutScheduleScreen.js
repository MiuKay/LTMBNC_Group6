import React from 'react';
import GenericScreen from '../components/GenericScreen';

const WorkoutScheduleScreen = () => {
    const fields = [
        { key: 'userId', label: 'User ID' },
        { key: 'date', label: 'Date' },
        { key: 'exerciseId', label: 'Exercise ID' },
        { key: 'status', label: 'Status' },
    ];

    return (
        <GenericScreen
            endpoint="/workoutSchedules"
            queryKey="workoutSchedules"
            fields={fields}
        />
    );
};

export default WorkoutScheduleScreen;