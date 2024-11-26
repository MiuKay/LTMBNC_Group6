import React from 'react';
import GenericScreen from '../components/GenericScreen';

const StepExerciseScreen = () => {
    const fields = [
        { key: 'title', label: 'Title' },
        { key: 'step', label: 'Step' },
        { key: 'name', label: 'Name' },
        { key: 'detail', label: 'Detail' },
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