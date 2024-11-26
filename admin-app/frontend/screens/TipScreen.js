import React from 'react';
import GenericScreen from '../components/GenericScreen';

const TipScreen = () => {
    const fields = [
        { key: 'name', label: 'Name' },
        { key: 'detail', label: 'Detail' },
        { key: 'pic', label: 'Picture' },
    ];

    return (
        <GenericScreen
            endpoint="/tips"
            queryKey="tips"
            fields={fields}
        />
    );
};

export default TipScreen;