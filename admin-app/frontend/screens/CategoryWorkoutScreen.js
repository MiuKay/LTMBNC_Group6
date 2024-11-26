import React from 'react';
import GenericScreen from '../components/GenericScreen';

const CategoryWorkoutScreen = () => {
    const fields = [
        { key: 'id', label: 'ID' },
        { key: 'level', label: 'Level' },
        { key: 'name', label: 'Name' },
        { key: 'pic', label: 'Picture' },
    ];

    return (
        <GenericScreen
            endpoint="/categoryWorkouts"
            queryKey="categoryWorkouts"
            fields={fields}
        />
    );
};

export default CategoryWorkoutScreen; 