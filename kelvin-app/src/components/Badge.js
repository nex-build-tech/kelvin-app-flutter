import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { colors, radius, fontSize } from '../theme';

const VARIANTS = {
  primary: { bg: colors.primaryLight, text: colors.primary      },
  success: { bg: colors.successLight, text: colors.success      },
  warning: { bg: colors.warningLight, text: colors.warning      },
  danger:  { bg: colors.dangerLight,  text: colors.danger       },
  info:    { bg: colors.infoLight,    text: colors.info         },
  neutral: { bg: colors.gray100,      text: colors.gray600      },
};

export default function Badge({ label, color = 'neutral', size = 'sm', dot = false }) {
  const v = VARIANTS[color] || VARIANTS.neutral;
  return (
    <View style={[styles.badge, { backgroundColor: v.bg }, size === 'xs' && styles.xs]}>
      {dot && <View style={[styles.dot, { backgroundColor: v.text }]} />}
      <Text style={[styles.text, { color: v.text }, size === 'xs' && styles.xsText]}>
        {label}
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  badge: {
    flexDirection: 'row', alignItems: 'center', gap: 4,
    paddingHorizontal: 8, paddingVertical: 3,
    borderRadius: radius.full, alignSelf: 'flex-start',
  },
  xs:     { paddingHorizontal: 6, paddingVertical: 2 },
  dot:    { width: 5, height: 5, borderRadius: 99 },
  text:   { fontSize: fontSize.xs, fontWeight: '600' },
  xsText: { fontSize: 10 },
});
