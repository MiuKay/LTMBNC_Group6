import React from 'react';
import GenericScreen from '../components/GenericScreen';

const ExerciseScreen = () => {
    const fields = [
        { key: 'name', label: 'Name' },
        { key: 'descriptions', label: 'Description' },
        { key: 'difficulty', label: 'Difficulty' },
        { key: 'calo', label: 'Calories' },
        { key: 'rep', label: 'Repetitions' },
        { key: 'time', label: 'Time' },
        { key: 'pic', label: 'Picture' },
        { key: 'video', label: 'Video' },
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