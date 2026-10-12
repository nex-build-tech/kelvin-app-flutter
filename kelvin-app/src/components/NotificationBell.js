import React, { useRef, useEffect } from 'react';
import { View, TouchableOpacity, Text, StyleSheet, Animated } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useNotifications } from '../context/NotificationContext';
import { colors } from '../theme';

export default function NotificationBell({ onPress, color = colors.white }) {
  const { unreadCount } = useNotifications();
  const wiggle = useRef(new Animated.Value(0)).current;
  const prevCount = useRef(unreadCount);

  useEffect(() => {
    if (unreadCount > prevCount.current) {
      // Wiggle animation when new notification arrives
      Animated.sequence([
        Animated.timing(wiggle, { toValue: -12, duration: 80,  useNativeDriver: true }),
        Animated.timing(wiggle, { toValue: 12,  duration: 80,  useNativeDriver: true }),
        Animated.timing(wiggle, { toValue: -8,  duration: 70,  useNativeDriver: true }),
        Animated.timing(wiggle, { toValue: 8,   duration: 70,  useNativeDriver: true }),
        Animated.timing(wiggle, { toValue: -4,  duration: 60,  useNativeDriver: true }),
        Animated.timing(wiggle, { toValue: 0,   duration: 60,  useNativeDriver: true }),
      ]).start();
    }
    prevCount.current = unreadCount;
  }, [unreadCount]);

  return (
    <TouchableOpacity onPress={onPress} style={styles.wrap} activeOpacity={0.7}>
      <Animated.View style={{ transform: [{ rotate: wiggle.interpolate({ inputRange: [-12, 12], outputRange: ['-12deg', '12deg'] }) }] }}>
        <Ionicons name="notifications-outline" size={24} color={color} />
      </Animated.View>
      {unreadCount > 0 && (
        <View style={styles.badge}>
          <Text style={styles.badgeText}>{unreadCount > 99 ? '99+' : unreadCount}</Text>
        </View>
      )}
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  wrap:      { width: 40, height: 40, alignItems: 'center', justifyContent: 'center' },
  badge:     { position: 'absolute', top: 4, right: 4, minWidth: 17, height: 17, borderRadius: 9, backgroundColor: colors.danger, alignItems: 'center', justifyContent: 'center', paddingHorizontal: 3, borderWidth: 1.5, borderColor: colors.white },
  badgeText: { color: colors.white, fontSize: 9, fontWeight: '800' },
});
