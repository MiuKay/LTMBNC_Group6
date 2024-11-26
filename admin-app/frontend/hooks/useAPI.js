import { useQuery, useMutation, useQueryClient } from 'react-query';
import api from '../api/axios';

export const useGetList = (endpoint, queryKey) => {
    return useQuery(queryKey, async () => {
        const response = await api.get(endpoint);
        return response.data;
    }, {
        onError: (error) => {
            console.error("Error fetching list:", error);
        }
    });
};

export const useGetById = (endpoint, id, queryKey) => {
    return useQuery([queryKey, id], async () => {
        const response = await api.get(`${endpoint}/${id}`);
        return response.data;
    }, {
        onError: (error) => {
            console.error("Error fetching item by ID:", error);
        }
    });
};

export const useCreate = (endpoint, queryKey) => {
    const queryClient = useQueryClient();

    return useMutation(
        async (data) => {
            const response = await api.post(endpoint, data);
            return response.data;
        },
        {
            onSuccess: () => {
                queryClient.invalidateQueries(queryKey);
            },
            onError: (error) => {
                console.error("Error creating item:", error);
            },
            onSettled: () => {
                queryClient.invalidateQueries(queryKey);
            }
        }
    );
};

export const useUpdate = (endpoint, queryKey) => {
    const queryClient = useQueryClient();

    return useMutation(
        async ({ id, data }) => {
            const response = await api.put(`${endpoint}/${id}`, data);
            return response.data;
        },
        {
            onSuccess: () => {
                queryClient.invalidateQueries(queryKey);
            },
            onError: (error) => {
                console.error("Error updating item:", error);
            },
            onSettled: () => {
                queryClient.invalidateQueries(queryKey);
            }
        }
    );
};

export const useDelete = (endpoint, queryKey) => {
    const queryClient = useQueryClient();

    return useMutation(
        async (id) => {
            await api.delete(`${endpoint}/${id}`);
        },
        {
            onSuccess: () => {
                queryClient.invalidateQueries(queryKey);
            },
            onError: (error) => {
                console.error("Error deleting item:", error);
            },
            onSettled: () => {
                queryClient.invalidateQueries(queryKey);
            }
        }
    );
};