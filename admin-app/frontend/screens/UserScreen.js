import React from 'react';
import GenericScreen from '../components/GenericScreen';

const UserScreen = () => {
    const fields = [
        { key: 'uid', label: 'User ID' },
        { key: 'fname', label: 'First Name' },
        { key: 'lname', label: 'Last Name' },
        { key: 'email', label: 'Email' },
        { key: 'dateOfBirth', label: 'Date of Birth' },
        { key: 'gender', label: 'Gender' },
        { key: 'weight', label: 'Weight' },
        { key: 'height', label: 'Height' },
        { key: 'level', label: 'Level' },
        { key: 'pic', label: 'Picture  ' }

    ];

    // Customize the GenericScreen component with additional props
    return (
        <GenericScreen
            endpoint="/users"
            queryKey="users"
            fields={fields}
            itemsPerPage={10}
            searchFields={['fname', 'lname', 'email', 'uid']}
            defaultSort="fname"
        />
    );
};

export default UserScreen;