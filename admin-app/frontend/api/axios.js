import axios from 'axios';

const api = axios.create({
    baseURL: 'http://192.168.1.229:5000/api/v1',
    headers: {
        'Content-Type': 'application/json',
    },
});

// Hàm lấy danh sách
export const fetchList = async (endpoint) => {
    const response = await api.get(endpoint);
    return response.data;
};

// Hàm lấy chi tiết
export const fetchById = async (endpoint, id) => {
    const response = await api.get(`${endpoint}/${id}`);
    return response.data;
};

// Hàm tạo mới
export const createItem = async (endpoint, data) => {
    const response = await api.post(endpoint, data);
    return response.data;
};

// Hàm cập nhật
export const updateItem = async (endpoint, id, data) => {
    const response = await api.put(`${endpoint}/${id}`, data);
    return response.data;
};

// Hàm xóa
export const deleteItem = async (endpoint, id) => {
    const response = await api.delete(`${endpoint}/${id}`);
    return response.data;
};

export default api;