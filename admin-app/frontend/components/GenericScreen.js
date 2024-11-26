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
    ScrollView,
    Alert
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
import { Picker } from '@react-native-picker/picker';

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
    const [detailModalVisible, setDetailModalVisible] = useState(false);
    const [detailItem, setDetailItem] = useState(null);
    const [sortField, setSortField] = useState(fields[0].key);
    const [sortOrder, setSortOrder] = useState('asc'); // 'asc' hoặc 'desc'

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

    const sortedItems = filteredItems.sort((a, b) => {
        if (a[sortField] < b[sortField]) return sortOrder === 'asc' ? -1 : 1;
        if (a[sortField] > b[sortField]) return sortOrder === 'asc' ? 1 : -1;
        return 0;
    });

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
                case 'date_of_birth':
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
            case 'pic':
            case 'video':
                return '';
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
            if (field.key !== 'uid') {
                const error = validateField(field.key, formData[field.key]);
                if (error) errors[field.key] = error;
            }
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
        Alert.alert(
            "Xác nhận xóa",
            "Bạn có chắc chắn muốn xóa mục này?",
            [
                {
                    text: "Hủy",
                    style: "cancel"
                },
                {
                    text: "Xóa",
                    onPress: async () => {
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
                    }
                }
            ]
        );
    };

    const renderItem = ({ item }) => (
        <TouchableOpacity onPress={() => openDetailModal(item)}>
            <Surface style={styles.itemCard} elevation={2}>
                <View style={styles.itemContent}>
                    {fields.map(field => (
                        <View key={field.key} style={styles.itemRow}>
                            <Text style={styles.itemLabel}>{field.label}</Text>
                            <Text 
                                style={styles.itemValue}
                                numberOfLines={1}
                                ellipsizeMode="tail"
                            >
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
        </TouchableOpacity>
    );

    const openDetailModal = (item) => {
        setDetailItem(item);
        setDetailModalVisible(true);
    };

    const closeDetailModal = () => {
        setDetailModalVisible(false);
        setDetailItem(null);
    };

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
            case 'level':
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
                                { value: 'Lean & Tone', label: 'Lean & Tone' },
                                { value: 'Improve Shape', label: 'Improve Shape' },
                                { value: 'Lose a Fat', label: 'Lose a Fat' }
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
                case 'date_of_birth':
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
            case 'uid':
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
                            editable={false}
                        />
                        {error && <Text style={styles.errorText}>{error}</Text>}
                    </View>
                );
            case 'pic':
            case 'video':
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

            <View style={styles.sortContainer}>
                <Text style={styles.sortLabel}>Sắp xếp theo:</Text>
                <Picker
                    selectedValue={sortField}
                    onValueChange={(itemValue) => setSortField(itemValue)}
                    style={styles.picker}
                >
                    {fields.map(field => (
                        <Picker.Item key={field.key} label={field.label} value={field.key} />
                    ))}
                </Picker>
                <Button
                    mode="outlined"
                    onPress={() => setSortOrder(prev => (prev === 'asc' ? 'desc' : 'asc'))}
                    style={styles.sortButton}
                >
                    {sortOrder === 'asc' ? 'Tăng dần' : 'Giảm dần'}
                </Button>
            </View>

            <FlatList
                data={sortedItems}
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

                <Modal
                    visible={detailModalVisible}
                    onDismiss={closeDetailModal}
                    contentContainerStyle={styles.modalContent}
                >
                    <Surface style={styles.modalSurface}>
                        <Text style={styles.modalTitle}>Chi tiết</Text>
                        <ScrollView style={styles.formContainer}>
                            {detailItem && fields.map(field => (
                                <View key={field.key} style={styles.formField}>
                                    <Text style={styles.fieldLabel}>{field.label}</Text>
                                    <Text style={styles.itemValue}>
                                        {detailItem[field.key] || 'N/A'}
                                    </Text>
                                </View>
                            ))}
                        </ScrollView>
                        <View style={styles.modalActions}>
                            <Button 
                                mode="outlined" 
                                onPress={closeDetailModal}
                                style={styles.modalButton}
                            >
                                Đóng
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
        backgroundColor: '#e0f7fa',
    },
    searchBar: {
        margin: 16,
        elevation: 4,
        borderRadius: 8,
        backgroundColor: '#ffffff',
    },
    listContent: {
        padding: 16,
        paddingBottom: 80,
    },
    itemCard: {
        marginBottom: 16,
        borderRadius: 12,
        overflow: 'hidden',
        backgroundColor: '#ffffff',
        elevation: 3,
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
        fontSize: 16,
        fontWeight: 'bold',
        flex: 1,
        color: '#00796b',
    },
    itemValue: {
        fontSize: 16,
        flex: 2,
        textAlign: 'right',
        color: '#004d40',
    },
    actionButtons: {
        flexDirection: 'row',
        justifyContent: 'flex-end',
        padding: 8,
        backgroundColor: '#e0f2f1',
    },
    editButton: {
        marginRight: 8,
        borderColor: '#00796b',
    },
    deleteButton: {
        marginLeft: 8,
        backgroundColor: '#d32f2f',
    },
    fab: {
        position: 'absolute',
        right: 16,
        bottom: 16,
        elevation: 8,
        backgroundColor: '#00796b',
    },
    modalContent: {
        padding: 20,
    },
    modalSurface: {
        backgroundColor: '#ffffff',
        borderRadius: 12,
        padding: 16,
        maxHeight: height * 0.8,
        elevation: 5,
    },
    modalTitle: {
        fontSize: 22,
        fontWeight: 'bold',
        marginBottom: 16,
        textAlign: 'center',
        color: '#00796b',
    },
    formContainer: {
        maxHeight: height * 0.6,
    },
    formField: {
        marginBottom: 16,
    },
    fieldLabel: {
        fontSize: 18,
        marginBottom: 8,
        color: '#004d40',
    },
    input: {
        backgroundColor: '#ffffff',
        borderColor: '#00796b',
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
    emptyText: {
        fontSize: 18,
        color: '#004d40',
    },
    sortContainer: {
        flexDirection: 'row',
        alignItems: 'center',
        margin: 16,
    },
    sortLabel: {
        fontSize: 16,
        marginRight: 8,
    },
    picker: {
        flex: 1,
        marginRight: 8,
    },
    sortButton: {
        borderColor: '#00796b',
    },
});

export default GenericScreen;