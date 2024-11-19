import React from 'react';
import GenericScreen from '../components/GenericScreen';

const TipScreen = () => {
    const fields = [
        { key: 'title', label: 'Title' },
        { key: 'content', label: 'Content' },
        { key: 'category', label: 'Category' },
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