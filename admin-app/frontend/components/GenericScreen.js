import React, { useState, useCallback } from 'react';
import { 
    View, 
    FlatList, 
    StyleSheet, 
    TouchableOpacity, 
    RefreshControl,
    Platform,
    Dimensions 
} from 'react-native';
import {
    Text,
    Card,
    FAB,
    Portal,
    Dialog,
    Button,
    Searchbar,
    TextInput,
    SegmentedButtons,
    Snackbar,
    IconButton,
} from 'react-native-paper';
import DateTimePicker from '@react-native-community/datetimepicker';
import { useGetList, useCreate, useUpdate, useDelete } from '../hooks/useAPI';

const { width } = Dimensions.get('window');

const GenericScreen = ({ 
    endpoint, 
    queryKey, 
    fields, 
    title = 'Items' 
}) => {
    // State Management
    const [searchQuery, setSearchQuery] = useState('');
    const [selectedItem, setSelectedItem] = useState(null);
    const [modalVisible, setModalVisible] = useState(false);
    const [formData, setFormData] = useState({});
    const [formErrors, setFormErrors] = useState({});
    const [snackbarVisible, setSnackbarVisible] = useState(false);
    const [snackbarMessage, setSnackbarMessage] = useState('');

    // API Hooks
    const { 
        data: items = [], 
        isLoading, 
        refetch 
    } = useGetList(endpoint, queryKey);
    const createMutation = useCreate(endpoint, queryKey);
    const updateMutation = useUpdate(endpoint, queryKey);
    const deleteMutation = useDelete(endpoint, queryKey);

    // Filtering and Searching
    const filteredItems = items.filter(item => 
        fields.some(field => 
            String(item[field.key])
                .toLowerCase()
                .includes(searchQuery.toLowerCase())
        )
    );

    // Form Validation
    const validateField = useCallback((key, value) => {
        switch (key) {
            case 'email':
                const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                return emailRegex.test(value) ? '' : 'Email không hợp lệ';
            case 'dateOfBirth':
                const dateRegex = /^\d{2}\/\d{2}\/\d{4}$/;
                return dateRegex.test(value) ? '' : 'Định dạng phải là dd/mm/yyyy';
            case 'weight':
            case 'height':
                return !isNaN(value) && value > 1 ? '' : 'Giá trị phải lớn hơn 1';
            default:
                return value?.trim() ? '' : 'Trường này là bắt buộc';
        }
    }, []);

    // Modal Handlers
    const openModal = (item = null) => {
        setSelectedItem(item);
        setFormData(item ? { ...item } : {});
        setFormErrors({});
        setModalVisible(true);
    };

    const closeModal = () => {
        setModalVisible(false);
        setSelectedItem(null);
        setFormData({});
        setFormErrors({});
    };

    // Save Handler
    const handleSave = async () => {
        const errors = {};
        fields.forEach(field => {
            const error = validateField(field.key, formData[field.key]);
            if (error) errors[field.key] = error;
        });

        if (Object.keys(errors).length > 0) {
            setFormErrors(errors);
            return;
        }

        try {
            if (selectedItem) {
                await updateMutation.mutateAsync({ 
                    id: selectedItem._id, 
                    data: formData 
                });
                setSnackbarMessage('Chỉnh sửa thành công');
            } else {
                await createMutation.mutateAsync(formData);
                setSnackbarMessage('Thêm mới thành công');
            }
            refetch();
            closeModal();
        } catch (error) {
            console.error(error);
            setSnackbarMessage('Có lỗi xảy ra');
        } finally {
            setSnackbarVisible(true);
        }
    };

    // Delete Handler
    const handleDelete = async (id) => {
        try {
            await deleteMutation.mutateAsync(id);
            refetch();
            setSnackbarMessage('Xóa thành công');
        } catch (error) {
            console.error(error);
            setSnackbarMessage('Có lỗi xảy ra');
        } finally {
            setSnackbarVisible(true);
        }
    };

    // Render Item
    const renderItem = ({ item }) => (
        <Card style={styles.itemCard}>
            {fields.map(field => (
                <View key={field.key} style={styles.itemRow}>
                    <Text style={styles.itemLabel}>{field.label}:</Text>
                    <Text style={styles.itemValue}>
                        {item[field.key] || 'N/A'}
                    </Text>
                </View>
            ))}
            <View style={styles.actionButtons}>
                <Button 
                    mode="outlined" 
                    onPress={() => openModal(item)}
                >
                    Chỉnh sửa
                </Button>
                <Button 
                    mode="contained" 
                    onPress={() => handleDelete(item._id)}
                    color="red"
                >
                    Xóa
                </Button>
            </View>
        </Card>
    );

    // Render Form Field
    const renderFormField = (field) => {
        const error = formErrors[field.key];
        const [showDatePicker, setShowDatePicker] = useState(false);

        switch (field.key) {
            case 'gender':
                return (
                    <View key={field.key}>
                        <Text>{field.label}</Text>
                        <SegmentedButtons
                            value={formData[field.key] || ''}
                            onValueChange={(value) => setFormData(prev => ({
                                ...prev, 
                                [field.key]: value
                            }))}
                            buttons={[
                                { value: 'male', label: 'Nam' },
                                { value: 'female', label: 'Nữ' },
                                { value: 'other', label: 'Khác' }
                            ]}
                        />
                        {error && <Text style={styles.errorText}>{error}</Text>}
                    </View>
                );
            case 'weight':
            case 'height':
                return (
                    <View key={field.key}>
                        <TextInput
                            label={field.label}
                            value={formData[field.key] || ''}
                            onChangeText={(text) => setFormData(prev => ({
                                ...prev, 
                                [field.key]: text
                            }))}
                            error={!!error}
                            keyboardType="numeric"
                        />
                        {error && <Text style={styles.errorText}>{error}</Text>}
                    </View>
                );
            case 'dateOfBirth':
                return (
                    <View key={field.key} style={{ position: 'relative', marginBottom: 20 }}>
                        <TextInput
                            label={field.label}
                            value={formData[field.key] || ''}
                            onChangeText={(text) => setFormData(prev => ({
                                ...prev,
                                [field.key]: text
                            }))}
                            error={!!error}
                            style={{ paddingRight: 40 }}
                        />
                        <IconButton
                            icon="calendar"
                            onPress={() => setShowDatePicker(true)}
                            style={{ position: 'absolute', right: 0, top: 10 }}
                        />
                        {showDatePicker && (
                            <DateTimePicker
                                value={formData[field.key] ? new Date(formData[field.key]) : new Date()}
                                mode="date"
                                display="default"
                                onChange={(event, selectedDate) => {
                                    setShowDatePicker(false);
                                    if (selectedDate) {
                                        const currentDate = selectedDate;
                                        const formattedDate = `${currentDate.getDate().toString().padStart(2, '0')}/${(currentDate.getMonth() + 1).toString().padStart(2, '0')}/${currentDate.getFullYear()}`;
                                        setFormData(prev => ({
                                            ...prev,
                                            [field.key]: formattedDate
                                        }));
                                    }
                                }}
                            />
                        )}
                        {error && <Text style={styles.errorText}>{error}</Text>}
                    </View>
                );
            default:
                return (
                    <View key={field.key}>
                        <TextInput
                            label={field.label}
                            value={formData[field.key] || ''}
                            onChangeText={(text) => setFormData(prev => ({
                                ...prev, 
                                [field.key]: text
                            }))}
                            error={!!error}
                        />
                        {error && <Text style={styles.errorText}>{error}</Text>}
                    </View>
                );
        }
    };

    return (
        <View style={styles.container}>
            <Searchbar
                placeholder="Tìm kiếm..."
                onChangeText={setSearchQuery}
                value={searchQuery}
                style={styles.searchBar}
            />

            <FlatList
                data={filteredItems}
                renderItem={renderItem}
                keyExtractor={item => item._id}
                refreshControl={
                    <RefreshControl 
                        refreshing={isLoading} 
                        onRefresh={refetch} 
                    />
                }
                ListEmptyComponent={
                    <View style={styles.emptyContainer}>
                        <Text>Không có dữ liệu</Text>
                    </View>
                }
            />

            <Portal>
                <Dialog
                    visible={modalVisible}
                    onDismiss={closeModal}
                >
                    <Dialog.Title>
                        {selectedItem ? 'Chỉnh sửa' : 'Thêm mới'}
                    </Dialog.Title>
                    <Dialog.Content>
                        {fields.map(renderFormField)}
                    </Dialog.Content>
                    <Dialog.Actions>
                        <Button onPress={closeModal}>Hủy</Button>
                        <Button onPress={handleSave}>Lưu</Button>
                    </Dialog.Actions>
                </Dialog>
            </Portal>

            <FAB
                icon="plus"
                style={styles.fab}
                onPress={() => openModal()}
            />

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
        backgroundColor: '#f5f5f5',
        padding: 10,
    },
    searchBar: {
        marginBottom: 10,
    },
    itemCard: {
        marginBottom: 10,
        padding: 15,
    },
    itemRow: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        marginBottom: 5,
    },
    itemLabel: {
        fontWeight: 'bold',
    },
    itemValue: {
        flex: 1,
        textAlign: 'right',
    },
    actionButtons: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        marginTop: 10,
    },
    fab: {
        position: 'absolute',
        margin: 16,
        right: 0,
        bottom: 0,
    },
    errorText: {
        color: 'red',
        marginTop: 5,
    },
    emptyContainer: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        marginTop: 50,
    },
});

export default GenericScreen;