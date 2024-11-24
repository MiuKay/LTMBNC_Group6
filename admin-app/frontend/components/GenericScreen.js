import React, { useState, useCallback } from 'react';
import { 
    View, 
    FlatList, 
    StyleSheet, 
    TouchableOpacity,
    RefreshControl,
    Platform,
    Dimensions,
    StatusBar,
    KeyboardAvoidingView,
    ScrollView
} from 'react-native';
import {
    Text,
    Card,
    FAB,
    Portal,
    Modal,
    Button,
    Searchbar,
    TextInput,
    SegmentedButtons,
    Snackbar,
    IconButton,
    Surface,
    useTheme,
    ActivityIndicator
} from 'react-native-paper';
import DateTimePicker from '@react-native-community/datetimepicker';
import { useGetList, useCreate, useUpdate, useDelete } from '../hooks/useAPI';

const { width, height } = Dimensions.get('window');

const GenericScreen = ({ 
    endpoint, 
    queryKey, 
    fields, 
    title = 'Items' 
}) => {
    const theme = useTheme();
    const [searchQuery, setSearchQuery] = useState('');
    const [selectedItem, setSelectedItem] = useState(null);
    const [modalVisible, setModalVisible] = useState(false);
    const [formData, setFormData] = useState({});
    const [formErrors, setFormErrors] = useState({});
    const [snackbarVisible, setSnackbarVisible] = useState(false);
    const [snackbarMessage, setSnackbarMessage] = useState('');
    const [refreshing, setRefreshing] = useState(false);

    const { 
        data: items = [], 
        isLoading, 
        refetch 
    } = useGetList(endpoint, queryKey);
    const createMutation = useCreate(endpoint, queryKey);
    const updateMutation = useUpdate(endpoint, queryKey);
    const deleteMutation = useDelete(endpoint, queryKey);

    const filteredItems = items.filter(item => 
        fields.some(field => 
            String(item[field.key])
                .toLowerCase()
                .includes(searchQuery.toLowerCase())
        )
    );

    const convertStringToDate = (dateString) => {
        if (!dateString) return new Date();
        
        // Chuyển đổi từ định dạng dd/mm/yyyy sang Date object
        const [day, month, year] = dateString.split('/').map(Number);
        if (!day || !month || !year) return new Date();
        
        const date = new Date(year, month - 1, day);
        return isNaN(date.getTime()) ? new Date() : date;
    };
    
    const formatDate = (date) => {
        if (!date) return '';
        
        const day = date.getDate().toString().padStart(2, '0');
        const month = (date.getMonth() + 1).toString().padStart(2, '0');
        const year = date.getFullYear();
        
        return `${day}/${month}/${year}`;
    };

    const validateField = useCallback((key, value) => {
        switch (key) {
            case 'email':
                const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                return emailRegex.test(value) ? '' : 'Email không hợp lệ';
                case 'dateOfBirth':
                    if (!value) return 'Trường này là bắt buộc';
                    
                    // Kiểm tra định dạng dd/mm/yyyy
                    const dateRegex = /^(\d{2})\/(\d{2})\/(\d{4})$/;
                    if (!dateRegex.test(value)) return 'Định dạng phải là dd/mm/yyyy';
                    
                    // Kiểm tra tính hợp lệ của ngày
                    const [day, month, year] = value.split('/').map(Number);
                    const date = new Date(year, month - 1, day);
                    if (
                        date.getDate() !== day ||
                        date.getMonth() !== month - 1 ||
                        date.getFullYear() !== year ||
                        year < 1900 ||
                        year > new Date().getFullYear()
                    ) {
                        return 'Ngày không hợp lệ';
                    }
                    
                    return '';
            case 'weight':
            case 'height':
                return !isNaN(value) && value > 0 ? '' : 'Giá trị phải lớn hơn 0';
            default:
                return value?.trim() ? '' : 'Trường này là bắt buộc';
        }
    }, []);

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
            await refetch();
            closeModal();
        } catch (error) {
            console.error(error);
            setSnackbarMessage('Có lỗi xảy ra');
        } finally {
            setSnackbarVisible(true);
        }
    };

    const handleDelete = async (id) => {
        try {
            await deleteMutation.mutateAsync(id);
            await refetch();
            setSnackbarMessage('Xóa thành công');
        } catch (error) {
            console.error(error);
            setSnackbarMessage('Có lỗi xảy ra');
        } finally {
            setSnackbarVisible(true);
        }
    };

    const renderItem = ({ item }) => (
        <Surface style={styles.itemCard} elevation={2}>
            <View style={styles.itemContent}>
                {fields.map(field => (
                    <View key={field.key} style={styles.itemRow}>
                        <Text style={styles.itemLabel}>{field.label}</Text>
                        <Text style={styles.itemValue}>
                            {item[field.key] || 'N/A'}
                        </Text>
                    </View>
                ))}
            </View>
            <View style={styles.actionButtons}>
                <Button 
                    mode="outlined" 
                    onPress={() => openModal(item)}
                    style={styles.editButton}
                    icon="pencil"
                >
                    Sửa
                </Button>
                <Button 
                    mode="contained" 
                    onPress={() => handleDelete(item._id)}
                    style={styles.deleteButton}
                    icon="delete"
                    buttonColor={theme.colors.error}
                >
                    Xóa
                </Button>
            </View>
        </Surface>
    );

    const renderFormField = (field) => {
        const error = formErrors[field.key];
        const [showDatePicker, setShowDatePicker] = useState(false);

        switch (field.key) {
            case 'gender':
                return (
                    <View key={field.key} style={styles.formField}>
                        <Text style={styles.fieldLabel}>{field.label}</Text>
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
                            style={styles.segmentedButtons}
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
                            value={String(formData[field.key] || '')}
                            onChangeText={(text) => setFormData(prev => ({
                                ...prev, 
                                [field.key]: text
                            }))}
                            error={!!error}
                            keyboardType="numeric"
                            style={styles.input}
                            mode="outlined"
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
                                    // Cho phép nhập trực tiếp
                                    setFormData(prev => ({
                                        ...prev,
                                        [field.key]: text
                                    }));
                                }}
                                error={!!error}
                                placeholder="dd/mm/yyyy"
                                right={
                                    <TextInput.Icon 
                                        icon="calendar" 
                                        onPress={() => setShowDatePicker(true)}
                                    />
                                }
                                style={styles.input}
                                mode="outlined"
                            />
                            {showDatePicker && (
                                <DateTimePicker
                                    value={
                                        formData[field.key] 
                                            ? convertStringToDate(formData[field.key]) 
                                            : new Date()
                                    }
                                    mode="date"
                                    display="default"
                                    onChange={(event, selectedDate) => {
                                        setShowDatePicker(false);
                                        // Chỉ cập nhật nếu người dùng chọn ngày (không phải hủy)
                                        if (event.type === 'set' && selectedDate) {
                                            const formattedDate = formatDate(selectedDate);
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
                    <View key={field.key} style={styles.formField}>
                        <TextInput
                            label={field.label}
                            value={formData[field.key] || ''}
                            onChangeText={(text) => setFormData(prev => ({
                                ...prev, 
                                [field.key]: text
                            }))}
                            error={!!error}
                            style={styles.input}
                            mode="outlined"
                        />
                        {error && <Text style={styles.errorText}>{error}</Text>}
                    </View>
                );
        }
    };

    const onRefresh = useCallback(async () => {
        setRefreshing(true);
        await refetch();
        setRefreshing(false);
    }, [refetch]);

    return (
        <KeyboardAvoidingView 
            style={styles.container} 
            behavior={Platform.OS === 'ios' ? 'padding' : undefined}
        >
            <StatusBar backgroundColor={theme.colors.primary} />
            
            <Searchbar
                placeholder="Tìm kiếm..."
                onChangeText={setSearchQuery}
                value={searchQuery}
                style={styles.searchBar}
                icon="magnify"
                clearIcon="close"
            />

            <FlatList
                data={filteredItems}
                renderItem={renderItem}
                keyExtractor={item => item._id}
                contentContainerStyle={styles.listContent}
                refreshControl={
                    <RefreshControl 
                        refreshing={refreshing || isLoading} 
                        onRefresh={onRefresh}
                        colors={[theme.colors.primary]}
                    />
                }
                ListEmptyComponent={
                    <View style={styles.emptyContainer}>
                        <Text style={styles.emptyText}>
                            {isLoading ? 'Đang tải...' : 'Không có dữ liệu'}
                        </Text>
                    </View>
                }
            />

            <Portal>
                <Modal
                    visible={modalVisible}
                    onDismiss={closeModal}
                    contentContainerStyle={styles.modalContent}
                >
                    <Surface style={styles.modalSurface}>
                        <Text style={styles.modalTitle}>
                            {selectedItem ? 'Chỉnh sửa' : 'Thêm mới'}
                        </Text>
                        <ScrollView style={styles.formContainer}>
                            {fields.map(renderFormField)}
                        </ScrollView>
                        <View style={styles.modalActions}>
                            <Button 
                                mode="outlined" 
                                onPress={closeModal}
                                style={styles.modalButton}
                            >
                                Hủy
                            </Button>
                            <Button 
                                mode="contained" 
                                onPress={handleSave}
                                style={styles.modalButton}
                                loading={createMutation.isLoading || updateMutation.isLoading}
                            >
                                Lưu
                            </Button>
                        </View>
                    </Surface>
                </Modal>
            </Portal>

            <FAB
                icon="plus"
                style={styles.fab}
                onPress={() => openModal()}
                color="white"
            />

            <Snackbar
                visible={snackbarVisible}
                onDismiss={() => setSnackbarVisible(false)}
                duration={2000}
                style={styles.snackbar}
                action={{
                    label: 'Đóng',
                    onPress: () => setSnackbarVisible(false),
                }}
            >
                {snackbarMessage}
            </Snackbar>
        </KeyboardAvoidingView>
    );
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: '#f5f5f5',
    },
    searchBar: {
        margin: 16,
        elevation: 4,
    },
    listContent: {
        padding: 16,
        paddingBottom: 80,
    },
    itemCard: {
        marginBottom: 16,
        borderRadius: 8,
        overflow: 'hidden',
    },
    itemContent: {
        padding: 16,
    },
    itemRow: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        marginBottom: 8,
    },
    itemLabel: {
        fontSize: 14,
        fontWeight: '600',
        flex: 1,
    },
    itemValue: {
        fontSize: 14,
        flex: 2,
        textAlign: 'right',
    },
    actionButtons: {
        flexDirection: 'row',
        justifyContent: 'flex-end',
        padding: 8,
        backgroundColor: '#f9f9f9',
    },
    editButton: {
        marginRight: 8,
    },
    deleteButton: {
        marginLeft: 8,
    },
    fab: {
        position: 'absolute',
        right: 16,
        bottom: 16,
        elevation: 8,
    },
    modalContent: {
        padding: 20,
    },
    modalSurface: {
        backgroundColor: 'white',
        borderRadius: 8,
        padding: 16,
        maxHeight: height * 0.8,
    },
    modalTitle: {
        fontSize: 20,
        fontWeight: 'bold',
        marginBottom: 16,
        textAlign: 'center',
    },
    formContainer: {
        maxHeight: height * 0.6,
    },
    formField: {
        marginBottom: 16,
    },
    fieldLabel: {
        fontSize: 16,
        marginBottom: 8,
    },
    input: {
        backgroundColor: 'white',
    },
    dateInput: {
        width: '100%',
    },
    segmentedButtons: {
        marginTop: 8,
    },
    errorText: {
        color: 'red',
        fontSize: 12,
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