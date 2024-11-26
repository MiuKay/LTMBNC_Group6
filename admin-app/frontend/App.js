import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createDrawerNavigator } from '@react-navigation/drawer';
import { Provider as PaperProvider, MD3LightTheme } from 'react-native-paper';
import { QueryClient, QueryClientProvider } from 'react-query';
import { Platform, View } from 'react-native';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import { Ionicons } from '@expo/vector-icons';

import UserScreen from './screens/UserScreen';
import ExerciseScreen from './screens/ExerciseScreen';
import StepExerciseScreen from './screens/StepExerciseScreen';
import TipScreen from './screens/TipScreen';
import WorkoutScreen from './screens/WorkoutScreen';
import CategoryWorkoutScreen from './screens/CategoryWorkoutScreen';
import ToolScreen from './screens/ToolScreen';

const Drawer = createDrawerNavigator();
const queryClient = new QueryClient();

const theme = {
    ...MD3LightTheme,
    colors: {
        ...MD3LightTheme.colors,
        primary: '#1976D2',
        secondary: '#f50057',
    },
};

export default function App() {
    return (
        <GestureHandlerRootView style={{ flex: 1 }}>
            <QueryClientProvider client={queryClient}>
                <PaperProvider theme={theme}>
                    <NavigationContainer>
                        <Drawer.Navigator
                            id="DrawerNavigator"
                            initialRouteName="Users"
                            screenOptions={{
                                headerShown: true,
                                drawerType: Platform.OS === 'web' ? 'permanent' : 'front',
                                drawerStyle: {
                                    width: '75%',
                                    backgroundColor: '#f5f5f5',
                                },
                                headerStyle: {
                                    backgroundColor: '#1976D2',
                                },
                                headerTintColor: '#fff',
                                headerTitleStyle: {
                                    fontWeight: 'bold',
                                },
                                drawerActiveTintColor: '#1976D2',
                                drawerInactiveTintColor: '#424242',
                            }}
                        >
                            <Drawer.Screen
                                name="Users"
                                component={UserScreen}
                                options={{
                                    headerTitle: "Quản lý người dùng",
                                    drawerIcon: ({ color }) => (
                                        <Ionicons name="people-outline" size={24} color={color} />
                                    ),
                                    drawerLabel: "Người dùng"
                                }}
                            />
                            <Drawer.Screen
                                name="Exercises"
                                component={ExerciseScreen}
                                options={{
                                    headerTitle: "Quản lý bài tập",
                                    drawerIcon: ({ color }) => (
                                        <Ionicons name="fitness-outline" size={24} color={color} />
                                    ),
                                    drawerLabel: "Bài tập"
                                }}
                            />
                            <Drawer.Screen
                                name="Step Exercises"
                                component={StepExerciseScreen}
                                options={{
                                    headerTitle: "Quản lý bước tập",
                                    drawerIcon: ({ color }) => (
                                        <Ionicons name="footsteps-outline" size={24} color={color} />
                                    ),
                                    drawerLabel: "Bước tập"
                                }}
                            />
                            <Drawer.Screen
                                name="Tips"
                                component={TipScreen}
                                options={{
                                    headerTitle: "Quản lý mẹo tập",
                                    drawerIcon: ({ color }) => (
                                        <Ionicons name="bulb-outline" size={24} color={color} />
                                    ),
                                    drawerLabel: "Mẹo tập"
                                }}
                            />
                            <Drawer.Screen
                                name="Workouts"
                                component={WorkoutScreen}
                                options={{
                                    headerTitle: "Quản lý nội dung buổi tập",
                                    drawerIcon: ({ color }) => (
                                        <Ionicons name="barbell-outline" size={24} color={color} />
                                    ),
                                    drawerLabel: "Buổi tập"
                                }}
                            />
                            <Drawer.Screen
                                name="Category Workouts"
                                component={CategoryWorkoutScreen}
                                options={{
                                    headerTitle: "Quản lý danh mục buổi tập",
                                    drawerIcon: ({ color }) => (
                                        <Ionicons name="list-outline" size={24} color={color} />
                                    ),
                                    drawerLabel: "Danh mục buổi tập"
                                }}
                            />
                            <Drawer.Screen
                                name="Tools"
                                component={ToolScreen}
                                options={{
                                    headerTitle: "Quản lý công cụ",
                                    drawerIcon: ({ color }) => (
                                        <Ionicons name="construct-outline" size={24} color={color} />
                                    ),
                                    drawerLabel: "Công cụ"
                                }}
                            />
                        </Drawer.Navigator>
                    </NavigationContainer>
                </PaperProvider>
            </QueryClientProvider>
        </GestureHandlerRootView>
    );
}