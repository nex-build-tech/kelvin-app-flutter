import React, { useEffect, useRef, useState } from 'react';
import { StatusBar, View, Animated } from 'react-native';
import { NavigationContainer } from '@react-navigation/native';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';

import HomeScreen            from './src/screens/HomeScreen';
import FollowUpsScreen       from './src/screens/FollowUpsScreen';
import QuickActionsScreen    from './src/screens/QuickActionsScreen';
import RemindersScreen       from './src/screens/RemindersScreen';
import ProfileScreen         from './src/screens/ProfileScreen';
import SplashScreen          from './src/screens/SplashScreen';
import LoginScreen           from './src/screens/LoginScreen';
import NotificationsScreen   from './src/screens/NotificationsScreen';
import { colors }            from './src/theme';
import { AuthProvider, useAuth } from './src/context/AuthContext';
import { NotificationProvider }  from './src/context/NotificationContext';

const Tab   = createBottomTabNavigator();
const Stack = createNativeStackNavigator();

const TAB_ICONS = {
  Home:        { active: 'home',          inactive: 'home-outline'          },
  'Follow-ups':{ active: 'call',          inactive: 'call-outline'          },
  Actions:     { active: 'flash',         inactive: 'flash-outline'         },
  Reminders:   { active: 'alarm',         inactive: 'alarm-outline'         },
  Profile:     { active: 'person-circle', inactive: 'person-circle-outline' },
};

function TabNavigator() {
  return (
    <Tab.Navigator
      screenOptions={({ route }) => ({
        headerShown: false,
        tabBarActiveTintColor:   colors.primary,
        tabBarInactiveTintColor: colors.gray400,
        tabBarStyle: {
          backgroundColor: colors.white,
          borderTopColor:  colors.gray200,
          borderTopWidth:  1,
          paddingTop: 6, paddingBottom: 6, height: 62,
        },
        tabBarLabelStyle: { fontSize: 10, fontWeight: '600', marginTop: 2 },
        tabBarIcon: ({ focused, color }) => {
          const icons = TAB_ICONS[route.name];
          return <Ionicons name={focused ? icons.active : icons.inactive} size={22} color={color} />;
        },
      })}
    >
      <Tab.Screen name="Home"       component={HomeScreen}        />
      <Tab.Screen name="Follow-ups" component={FollowUpsScreen}   />
      <Tab.Screen
        name="Actions"
        component={QuickActionsScreen}
        options={{
          tabBarIcon: ({ focused }) => (
            <View style={{
              width: 50, height: 50, borderRadius: 25,
              backgroundColor: colors.primary,
              alignItems: 'center', justifyContent: 'center',
              marginBottom: 8,
              shadowColor: colors.primary,
              shadowOffset: { width: 0, height: 4 },
              shadowOpacity: 0.45, shadowRadius: 10, elevation: 10,
            }}>
              <Ionicons name="flash" size={24} color={colors.white} />
            </View>
          ),
          tabBarLabel: () => null,
        }}
      />
      <Tab.Screen name="Reminders" component={RemindersScreen} />
      <Tab.Screen name="Profile"   component={ProfileScreen}   />
    </Tab.Navigator>
  );
}

// Main stack: tabs + notification screen
function MainStack() {
  return (
    <Stack.Navigator screenOptions={{ headerShown: false }}>
      <Stack.Screen name="Tabs"          component={TabNavigator}        />
      <Stack.Screen name="Notifications" component={NotificationsScreen} options={{ animation: 'slide_from_right' }} />
    </Stack.Navigator>
  );
}

// Auth-aware root navigator
function RootNavigator() {
  const { user, loading } = useAuth();
  const [showSplash, setShowSplash] = useState(true);
  const fadeOut = useRef(new Animated.Value(1)).current;

  useEffect(() => {
    // Wait for auth check to finish + minimum splash time (2.6s), then fade out
    const minTime = 2600;
    const start   = Date.now();
    const check = () => {
      if (loading) {
        // Auth still loading — poll again
        setTimeout(check, 50);
        return;
      }
      const elapsed = Date.now() - start;
      const wait    = Math.max(0, minTime - elapsed);
      setTimeout(() => {
        Animated.timing(fadeOut, { toValue: 0, duration: 350, useNativeDriver: true }).start(() => {
          setShowSplash(false);
        });
      }, wait);
    };
    check();
  }, [loading]);

  if (showSplash) {
    return (
      <Animated.View style={{ flex: 1, opacity: fadeOut }}>
        <SplashScreen />
      </Animated.View>
    );
  }

  return (
    <Stack.Navigator screenOptions={{ headerShown: false }}>
      {user ? (
        <Stack.Screen name="Main"  component={MainStack}  />
      ) : (
        <Stack.Screen name="Login" component={LoginScreen} options={{ animation: 'fade' }} />
      )}
    </Stack.Navigator>
  );
}

export default function App() {
  return (
    <SafeAreaProvider>
      <AuthProvider>
        <NotificationProvider>
          <StatusBar barStyle="light-content" backgroundColor={colors.primaryDark} />
          <NavigationContainer>
            <RootNavigator />
          </NavigationContainer>
        </NotificationProvider>
      </AuthProvider>
    </SafeAreaProvider>
  );
}
