import { useQuery, useMutation, useQueryClient } from 'react-query';
import api from '../api/axios';

export const useGetList = (endpoint, queryKey) => {
    return useQuery(queryKey, async () => {
        const response = await api.get(endpoint);
        return response.data;
    });
};

export const useGetById = (endpoint, id, queryKey) => {
    return useQuery([queryKey, id], async () => {
        const response = await api.get(`${endpoint}/${id}`);
        return response.data;
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
        }
    );
};