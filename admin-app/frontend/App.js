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
import WorkoutScheduleScreen from './screens/WorkoutScheduleScreen';

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
                                    width: Platform.OS === 'web' ? 280 : '75%',
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
                                name="Workout Schedules"
                                component={WorkoutScheduleScreen}
                                options={{
                                    headerTitle: "Quản lý lịch tập",
                                    drawerIcon: ({ color }) => (
                                        <Ionicons name="calendar-outline" size={24} color={color} />
                                    ),
                                    drawerLabel: "Lịch tập"
                                }}
                            />
                        </Drawer.Navigator>
                    </NavigationContainer>
                </PaperProvider>
            </QueryClientProvider>
        </GestureHandlerRootView>
    );
}