import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { colors, fontSize, spacing } from '../theme';

export default function Header({ title, subtitle, showBack = false, onBack, rightIcon, onRight }) {
  const insets = useSafeAreaInsets();
  return (
    <View style={[styles.container, { paddingTop: insets.top + 10 }]}>
      <View style={styles.inner}>
        {showBack ? (
          <TouchableOpacity onPress={onBack} style={styles.backBtn}>
            <Ionicons name="arrow-back" size={22} color={colors.white} />
          </TouchableOpacity>
        ) : (
          <View style={styles.logoRow}>
            <View style={styles.logoBox}>
              <Text style={styles.logoText}>K</Text>
            </View>
            <View>
              <Text style={styles.brandName}>Kelvin Mech</Text>
              <Text style={styles.brandSub}>Ops Platform</Text>
            </View>
          </View>
        )}

        <View style={styles.titleArea}>
          {showBack && <Text style={styles.pageTitle}>{title}</Text>}
          {showBack && subtitle ? <Text style={styles.pageSub}>{subtitle}</Text> : null}
        </View>

        {rightIcon ? (
          <TouchableOpacity onPress={onRight} style={styles.rightBtn}>
            <Ionicons name={rightIcon} size={22} color={colors.white} />
          </TouchableOpacity>
        ) : (
          <View style={styles.rightBtn} />
        )}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    backgroundColor: colors.primaryDark,
    paddingBottom: spacing.lg,
    paddingHorizontal: spacing.lg,
  },
  inner: {
    flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between',
  },
  logoRow: { flexDirection: 'row', alignItems: 'center', gap: 10 },
  logoBox: {
    width: 34, height: 34, borderRadius: 8,
    backgroundColor: colors.primary,
    alignItems: 'center', justifyContent: 'center',
  },
  logoText:  { color: colors.white, fontWeight: '800', fontSize: 18 },
  brandName: { color: colors.white, fontWeight: '700', fontSize: fontSize.md, lineHeight: 18 },
  brandSub:  { color: 'rgba(255,255,255,0.6)', fontSize: 10 },
  titleArea: { flex: 1, alignItems: 'center' },
  pageTitle: { color: colors.white, fontWeight: '700', fontSize: fontSize.lg },
  pageSub:   { color: 'rgba(255,255,255,0.7)', fontSize: fontSize.xs, marginTop: 1 },
  backBtn:   { width: 36, alignItems: 'flex-start' },
  rightBtn:  { width: 36, alignItems: 'flex-end' },
});
