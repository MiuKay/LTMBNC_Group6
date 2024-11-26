import React from 'react';
import GenericScreen from '../components/GenericScreen';

const WorkoutScreen = () => {
    const fields = [
        { key: 'id_cate', label: 'Category ID' },
        { key: 'name_exercise', label: 'Exercise Name' },
        { key: 'step', label: 'Step' },
    ];

    return (
        <GenericScreen
            endpoint="/workouts"
            queryKey="workouts"
            fields={fields}
        />
    );
};

export default WorkoutScreen; 