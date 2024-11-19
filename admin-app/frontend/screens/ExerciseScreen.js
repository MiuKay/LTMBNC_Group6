import React from 'react';
import GenericScreen from '../components/GenericScreen';

const ExerciseScreen = () => {
    const fields = [
        { key: 'name', label: 'Name' },
        { key: 'description', label: 'Description' },
        { key: 'difficulty', label: 'Difficulty' },
    ];

    return (
        <GenericScreen
            endpoint="/exercises"
            queryKey="exercises"
            fields={fields}
        />
    );
};

export default ExerciseScreen;