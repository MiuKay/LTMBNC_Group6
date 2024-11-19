import React from 'react';
import GenericScreen from '../components/GenericScreen';

const StepExerciseScreen = () => {
    const fields = [
        { key: 'exerciseId', label: 'Exercise ID' },
        { key: 'stepNumber', label: 'Step Number' },
        { key: 'description', label: 'Description' },
    ];

    return (
        <GenericScreen
            endpoint="/stepExercises"
            queryKey="stepExercises"
            fields={fields}
        />
    );
};

export default StepExerciseScreen;