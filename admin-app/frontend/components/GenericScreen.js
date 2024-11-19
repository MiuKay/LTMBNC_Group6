import React, { useState } from 'react';
import { View, Platform, StyleSheet } from 'react-native';
import {
    DataTable,
    Portal,
    Modal,
    TextInput,
    Button,
    Title,
    Snackbar,
    Card,
    IconButton,
    Searchbar,
    SegmentedButtons,
    Text,
    Menu,
} from 'react-native-paper';
import { useGetList, useCreate, useUpdate, useDelete } from '../hooks/useAPI';

const GenericScreen = ({ endpoint, queryKey, fields, title = 'Items' }) => {
    const [visible, setVisible] = useState(false);
    const [editItem, setEditItem] = useState(null);
    const [formData, setFormData] = useState({});
    const [formErrors, setFormErrors] = useState({});
    const [snackbarVisible, setSnackbarVisible] = useState(false);
    const [snackbarMessage, setSnackbarMessage] = useState('');
    const [searchQuery, setSearchQuery] = useState('');
    const [page, setPage] = useState(0);
    const [itemsPerPage, setItemsPerPage] = useState(10);
    const [sortBy, setSortBy] = useState('');
    const [sortDirection, setSortDirection] = useState('asc');

    const { data: items, isLoading, refetch } = useGetList(endpoint, queryKey);
    const createMutation = useCreate(endpoint, queryKey);
    const updateMutation = useUpdate(endpoint, queryKey);
    const deleteMutation = useDelete(endpoint, queryKey);

    // Validation rules for different field types
    const validateField = (key, value) => {
        switch (key) {
            case 'email':
                const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                return emailRegex.test(value) ? '' : 'Invalid email format';
            case 'dateOfBirth':
                const dateRegex = /^\d{4}-\d{2}-\d{2}$/;
                return dateRegex.test(value) ? '' : 'Use format YYYY-MM-DD';
            case 'weight':
                return !isNaN(value) && value > 0 ? '' : 'Enter valid weight';
            case 'height':
                return !isNaN(value) && value > 0 ? '' : 'Enter valid height';
            case 'pic':
                const urlRegex = /^(http|https):\/\/[^ "]+$/;
                return urlRegex.test(value) ? '' : 'Enter valid URL';
            default:
                return value?.trim() ? '' : 'This field is required';
        }
    };

    // Filter items based on search query
    const filteredItems = items?.filter(item =>
        fields.some(field =>
            String(item[field.key])?.toLowerCase().includes(searchQuery.toLowerCase())
        )
    ) || [];

    // Sort items
    const sortedItems = [...(filteredItems || [])].sort((a, b) => {
        if (!sortBy) return 0;
        const aValue = String(a[sortBy]).toLowerCase();
        const bValue = String(b[sortBy]).toLowerCase();
        return sortDirection === 'asc'
            ? aValue.localeCompare(bValue)
            : bValue.localeCompare(aValue);
    });

    // Paginate items
    const paginatedItems = sortedItems.slice(
        page * itemsPerPage,
        (page + 1) * itemsPerPage
    );

    const showModal = (item = null) => {
        if (item) {
            setEditItem(item);
            setFormData(item);
        } else {
            setEditItem(null);
            setFormData({});
        }
        setFormErrors({});
        setVisible(true);
    };

    const hideModal = () => {
        setVisible(false);
        setEditItem(null);
        setFormData({});
        setFormErrors({});
    };

    const validateForm = () => {
        const errors = {};
        fields.forEach(field => {
            const error = validateField(field.key, formData[field.key]);
            if (error) {
                errors[field.key] = error;
            }
        });
        setFormErrors(errors);
        return Object.keys(errors).length === 0;
    };

    const handleSave = async () => {
        if (!validateForm()) {
            setSnackbarMessage('Please fix the form errors');
            setSnackbarVisible(true);
            return;
        }

        try {
            if (editItem) {
                await updateMutation.mutateAsync({ id: editItem._id, data: formData });
                setSnackbarMessage('Updated successfully');
            } else {
                await createMutation.mutateAsync(formData);
                setSnackbarMessage('Created successfully');
            }
            hideModal();
            setSnackbarVisible(true);
            refetch();
        } catch (error) {
            setSnackbarMessage(error.message || 'An error occurred');
            setSnackbarVisible(true);
        }
    };

    const handleDelete = async (id) => {
        if (window.confirm('Are you sure you want to delete this item?')) {
            try {
                console.log("uid :", id)
                await deleteMutation.mutateAsync(id);
                setSnackbarMessage('Deleted successfully');
                setSnackbarVisible(true);
                refetch();
            } catch (error) {
                setSnackbarMessage(error.message || 'An error occurred');
                setSnackbarVisible(true);
            }
        }
    };

    const handleSort = (key) => {
        if (sortBy === key) {
            setSortDirection(sortDirection === 'asc' ? 'desc' : 'asc');
        } else {
            setSortBy(key);
            setSortDirection('asc');
        }
    };

    const renderFormField = (field) => {
        const error = formErrors[field.key];

        switch (field.key) {
            case 'gender':
                return (
                    <View key={field.key} style={styles.formField}>
                        <Title style={styles.fieldLabel}>{field.label}</Title>
                        <SegmentedButtons
                            value={formData[field.key] || ''}
                            onValueChange={(value) => {
                                setFormData({ ...formData, [field.key]: value });
                                setFormErrors({ ...formErrors, [field.key]: '' });
                            }}
                            buttons={[
                                { value: 'male', label: 'Male' },
                                { value: 'female', label: 'Female' },
                                { value: 'other', label: 'Other' }
                            ]}
                            style={styles.segmentedButton}
                        />
                        {error && <Text style={styles.errorText}>{error}</Text>}
                    </View>
                );

            case 'dateOfBirth':
                return (
                    <View key={field.key} style={styles.formField}>
                        <TextInput
                            label={field.label}
                            value={formData[field.key] || ''}
                            onChangeText={(text) => {
                                setFormData({ ...formData, [field.key]: text });
                                setFormErrors({ ...formErrors, [field.key]: '' });
                            }}
                            error={!!error}
                            style={styles.input}
                            placeholder="YYYY-MM-DD"
                            right={<TextInput.Icon icon="calendar" />}
                        />
                        {error && <Text style={styles.errorText}>{error}</Text>}
                    </View>
                );

            case 'weight':
            case 'height':
                return (
                    <View key={field.key} style={styles.formField}>
                        <TextInput
                            label={field.label}
                            value={formData[field.key] || ''}
                            onChangeText={(text) => {
                                setFormData({ ...formData, [field.key]: text });
                                setFormErrors({ ...formErrors, [field.key]: '' });
                            }}
                            error={!!error}
                            keyboardType="numeric"
                            style={styles.input}
                            right={<TextInput.Affix text={field.key === 'weight' ? 'kg' : 'cm'} />}
                        />
                        {error && <Text style={styles.errorText}>{error}</Text>}
                    </View>
                );

            case 'level':
                return (
                    <View key={field.key} style={styles.formField}>
                        <Title style={styles.fieldLabel}>{field.label}</Title>
                        <SegmentedButtons
                            value={formData[field.key] || ''}
                            onValueChange={(value) => {
                                setFormData({ ...formData, [field.key]: value });
                                setFormErrors({ ...formErrors, [field.key]: '' });
                            }}
                            buttons={[
                                { value: 'beginner', label: 'Beginner' },
                                { value: 'intermediate', label: 'Intermediate' },
                                { value: 'advanced', label: 'Advanced' }
                            ]}
                            style={styles.segmentedButton}
                        />
                        {error && <Text style={styles.errorText}>{error}</Text>}
                    </View>
                );

            case 'pic':
                return (
                    <View key={field.key} style={styles.formField}>
                        <TextInput
                            label={field.label}
                            value={formData[field.key] || ''}
                            onChangeText={(text) => {
                                setFormData({ ...formData, [field.key]: text });
                                setFormErrors({ ...formErrors, [field.key]: '' });
                            }}
                            error={!!error}
                            style={styles.input}
                            placeholder="Enter image URL"
                        />
                        {formData[field.key] && (
                            <img
                                src={formData[field.key]}
                                alt="Preview"
                                style={styles.imagePreview}
                                onError={(e) => {
                                    e.target.style.display = 'none';
                                    setFormErrors({
                                        ...formErrors,
                                        [field.key]: 'Invalid image URL'
                                    });
                                }}
                            />
                        )}
                        {error && <Text style={styles.errorText}>{error}</Text>}
                    </View>
                );

            default:
                return (
                    <View key={field.key} style={styles.formField}>
                        <TextInput
                            label={field.label}
                            value={formData[field.key] || ''}
                            onChangeText={(text) => {
                                setFormData({ ...formData, [field.key]: text });
                                setFormErrors({ ...formErrors, [field.key]: '' });
                            }}
                            error={!!error}
                            style={styles.input}
                        />
                        {error && <Text style={styles.errorText}>{error}</Text>}
                    </View>
                );
        }
    };

    const renderCell = (item, field) => {
        switch (field.key) {
            case 'pic':
                return (
                    <img
                        src={item[field.key]}
                        alt="Profile"
                        style={styles.cellImage}
                        onError={(e) => e.target.src = '/placeholder-image.png'}
                    />
                );
            case 'level':
                return (
                    <View style={[styles.levelBadge, styles[`level${item[field.key]}`]]}>
                        <Text>{item[field.key]}</Text>
                    </View>
                );
            default:
                return item[field.key];
        }
    };

    if (isLoading) {
        return (
            <View style={styles.loadingContainer}>
                <Title>Loading...</Title>
            </View>
        );
    }

    return (
        <View style={styles.container}>
            <Card style={styles.card}>
                <Card.Content>
                    <View style={styles.header}>
                        <Searchbar
                            placeholder="Search..."
                            onChangeText={setSearchQuery}
                            value={searchQuery}
                            style={styles.searchBar}
                        />
                        <Button
                            mode="contained"
                            onPress={() => showModal()}
                            icon="plus"
                            style={styles.addButton}
                        >
                            Add New
                        </Button>
                    </View>

                    <DataTable>
                        <DataTable.Header>
                            {fields.map((field) => (
                                <DataTable.Title
                                    key={field.key}
                                    style={styles.column}
                                    sortDirection={sortBy === field.key ? sortDirection : 'none'}
                                    onPress={() => handleSort(field.key)}
                                >
                                    {field.label}
                                </DataTable.Title>
                            ))}
                            <DataTable.Title style={styles.actionsColumn}>
                                Actions
                            </DataTable.Title>
                        </DataTable.Header>

                        {paginatedItems.map((item) => (
                            <DataTable.Row key={item._id}>
                                {fields.map((field) => (
                                    <DataTable.Cell key={field.key} style={styles.column}>
                                        {renderCell(item, field)}
                                    </DataTable.Cell>
                                ))}
                                <DataTable.Cell style={styles.actionsColumn}>
                                    <IconButton
                                        icon="pencil"
                                        size={20}
                                        onPress={() => showModal(item)}
                                    />
                                    <IconButton
                                        icon="delete"
                                        size={20}
                                        onPress={() => handleDelete(item._id)}
                                    />
                                </DataTable.Cell>
                            </DataTable.Row>
                        ))}

                        <DataTable.Pagination
                            page={page}
                            numberOfPages={Math.ceil(filteredItems.length / itemsPerPage)}
                            onPageChange={setPage}
                            label={`${page + 1} of ${Math.ceil(filteredItems.length / itemsPerPage)}`}
                            itemsPerPage={itemsPerPage}
                            setItemsPerPage={setItemsPerPage}
                            showFastPaginationControls
                        />
                    </DataTable>
                </Card.Content>
            </Card>

            <Portal>
                <Modal
                    visible={visible}
                    onDismiss={hideModal}
                    contentContainerStyle={styles.modal}
                >
                    <Card>
                        <Card.Title title={editItem ? 'Edit Item' : 'Add New Item'} />
                        <Card.Content>
                            <View style={styles.formContainer}>
                                {fields.map(renderFormField)}
                            </View>
                            <View style={styles.buttonContainer}>
                                <Button
                                    onPress={hideModal}
                                    style={styles.modalButton}
                                >
                                    Cancel
                                </Button>
                                <Button
                                    mode="contained"
                                    onPress={handleSave}
                                    style={styles.modalButton}
                                    loading={createMutation.isLoading || updateMutation.isLoading}
                                >
                                    Save
                                </Button>
                            </View>
                        </Card.Content>
                    </Card>
                </Modal>
            </Portal>

            <Snackbar
                visible={snackbarVisible}
                onDismiss={() => setSnackbarVisible(false)}
                duration={3000}
            >
                {snackbarMessage}
            </Snackbar>
        </View>
    );
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
        padding: 16,
        backgroundColor: '#f5f5f5',
    },
    card: {
        marginBottom: 16,
    },
    header: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        marginBottom: 16,
    },
    searchBar: {
        flex: 1,
        marginRight: 16,
    },
    addButton: {
        marginLeft: 8,
    },
    column: {
        flex: 1,
    },
    actionsColumn: {
        flex: 0.5,
        justifyContent: 'flex-end',
    },
    modal: {
        margin: 20,
        backgroundColor: 'white',
        borderRadius: 8,
        padding: 0,
        maxWidth: Platform.OS === 'web' ? 500 : '100%',
        alignSelf: 'center',
        width: '100%',
    },
    input: {
        marginBottom: 12,
    },
    buttonContainer: {
        flexDirection: 'row',
        justifyContent: 'flex-end',
        marginTop: 16,
    },
    modalButton: {
        marginLeft: 8,
    },
    loadingContainer: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
    },
});

export default GenericScreen;