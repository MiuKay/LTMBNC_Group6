import React from 'react';
import GenericScreen from '../components/GenericScreen';

const ToolScreen = () => {
    const fields = [
        { key: 'id', label: 'ID' },
        { key: 'name', label: 'Name' },
        { key: 'pic', label: 'Picture' },
    ];

    return (
        <GenericScreen
            endpoint="/tools"
            queryKey="tools"
            fields={fields}
        />
    );
};

export default ToolScreen; 