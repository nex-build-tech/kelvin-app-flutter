import React from 'react';
import { View, StyleSheet } from 'react-native';
import { colors, radius, shadow } from '../theme';

export default function Card({ children, style, variant = 'default' }) {
  return (
    <View style={[styles.card, variant === 'flat' && styles.flat, style]}>
      {children}
    </View>
  );
}

const styles = StyleSheet.create({
  card: {
    backgroundColor: colors.white,
    borderRadius: radius.lg,
    padding: 14,
    ...shadow.sm,
  },
  flat: {
    borderWidth: 1,
    borderColor: colors.gray200,
    shadowOpacity: 0,
    elevation: 0,
  },
});
