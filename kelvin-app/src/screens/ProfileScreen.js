import React, { useState } from 'react';
import { View, Text, ScrollView, StyleSheet, TouchableOpacity, Switch, Alert } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { colors, spacing, radius, fontSize, shadow } from '../theme';
import { ME } from '../data/mock';
import { useAuth } from '../context/AuthContext';

const NOTIF_SETTINGS = [
  { id: 1, label: 'SLA Breach Alerts',    sub: 'Immediate push for any breach',    key: 'sla',       default: true  },
  { id: 2, label: 'PO Approval Requests', sub: 'When someone requests approval',   key: 'approval',  default: true  },
  { id: 3, label: 'Follow-up Reminders',  sub: '30 min before due time',           key: 'followup',  default: true  },
  { id: 4, label: 'New Enquiries',         sub: 'When new enquiry arrives',         key: 'enquiry',   default: false },
  { id: 5, label: 'Project Updates',       sub: 'Daily digest at 9 AM',            key: 'project',   default: false },
  { id: 6, label: 'Weekly SLA Report',     sub: 'Every Monday morning',            key: 'report',    default: true  },
];

const MENU_ITEMS = [
  { icon: 'person-outline',          label: 'Edit Profile',       sub: 'Name, role, contact' },
  { icon: 'shield-checkmark-outline',label: 'Security',           sub: 'Password, biometrics' },
  { icon: 'phone-portrait-outline',  label: 'Linked Devices',     sub: '2 devices active'    },
  { icon: 'help-circle-outline',     label: 'Help & Support',     sub: 'FAQs, raise a ticket' },
  { icon: 'information-circle-outline',label:'About',             sub: 'Version 1.0.0 · MVP' },
];

export default function ProfileScreen({ navigation }) {
  const insets = useSafeAreaInsets();
  const { user, logout } = useAuth();
  const [notifs, setNotifs] = useState(
    Object.fromEntries(NOTIF_SETTINGS.map(n => [n.key, n.default]))
  );

  const toggle = (key) => setNotifs(prev => ({ ...prev, [key]: !prev[key] }));

  const displayUser = {
    name:   user?.name   || ME.name,
    role:   user?.role   || ME.role,
    email:  user?.email  || ME.email,
    avatar: user?.avatar || ME.avatar,
  };

  const handleLogout = () => {
    Alert.alert('Sign Out', 'Are you sure you want to sign out?', [
      { text: 'Cancel', style: 'cancel' },
      { text: 'Sign Out', style: 'destructive', onPress: logout },
    ]);
  };

  return (
    <View style={[styles.container, { backgroundColor: colors.gray50 }]}>
      {/* Header */}
      <View style={[styles.header, { paddingTop: insets.top + 12 }]}>
        <Text style={styles.headerTitle}>Profile</Text>
      </View>

      <ScrollView showsVerticalScrollIndicator={false}
        contentContainerStyle={{ paddingBottom: 100 }}>

        {/* Profile card */}
        <View style={styles.profileCard}>
          <View style={styles.avatarWrap}>
            <View style={styles.avatar}>
              <Text style={styles.avatarText}>{displayUser.avatar}</Text>
            </View>
            <View style={styles.onlineDot} />
          </View>
          <View style={{ flex: 1 }}>
            <Text style={styles.name}>{displayUser.name}</Text>
            <Text style={styles.role}>{displayUser.role}</Text>
            <Text style={styles.email}>{displayUser.email}</Text>
          </View>
          <TouchableOpacity style={styles.editChip}>
            <Ionicons name="pencil-outline" size={14} color={colors.primary} />
            <Text style={styles.editText}>Edit</Text>
          </TouchableOpacity>
        </View>

        {/* Stats row */}
        <View style={styles.statsRow}>
          {[
            { label: 'Tasks Done',    value: '47', color: colors.success },
            { label: 'POs Approved',  value: '23', color: colors.primary },
            { label: 'SLA Score',     value: '94%',color: colors.warning },
          ].map(s => (
            <View key={s.label} style={styles.statCard}>
              <Text style={[styles.statVal, { color: s.color }]}>{s.value}</Text>
              <Text style={styles.statLabel}>{s.label}</Text>
            </View>
          ))}
        </View>

        {/* Notification settings */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Notification Preferences</Text>
          <View style={styles.menuCard}>
            {NOTIF_SETTINGS.map((n, i) => (
              <View key={n.id}>
                <View style={styles.notifRow}>
                  <View style={{ flex: 1 }}>
                    <Text style={styles.notifLabel}>{n.label}</Text>
                    <Text style={styles.notifSub}>{n.sub}</Text>
                  </View>
                  <Switch
                    value={notifs[n.key]}
                    onValueChange={() => toggle(n.key)}
                    trackColor={{ false: colors.gray200, true: colors.primary + '60' }}
                    thumbColor={notifs[n.key] ? colors.primary : colors.gray400}
                  />
                </View>
                {i < NOTIF_SETTINGS.length - 1 && <View style={styles.divider} />}
              </View>
            ))}
          </View>
        </View>

        {/* Menu items */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Account</Text>
          <View style={styles.menuCard}>
            {MENU_ITEMS.map((m, i) => (
              <View key={m.label}>
                <TouchableOpacity style={styles.menuRow} activeOpacity={0.7}>
                  <View style={styles.menuIcon}>
                    <Ionicons name={m.icon} size={18} color={colors.primary} />
                  </View>
                  <View style={{ flex: 1 }}>
                    <Text style={styles.menuLabel}>{m.label}</Text>
                    <Text style={styles.menuSub}>{m.sub}</Text>
                  </View>
                  <Ionicons name="chevron-forward" size={16} color={colors.gray300} />
                </TouchableOpacity>
                {i < MENU_ITEMS.length - 1 && <View style={styles.divider} />}
              </View>
            ))}
          </View>
        </View>

        {/* Sign out */}
        <View style={styles.section}>
          <TouchableOpacity style={styles.signOutBtn} onPress={handleLogout}>
            <Ionicons name="log-out-outline" size={18} color={colors.danger} />
            <Text style={styles.signOutText}>Sign Out</Text>
          </TouchableOpacity>
          <Text style={styles.version}>Kelvin Mech Ops · v1.0.0 MVP · Powered by Ayu Ventures</Text>
        </View>
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container:    { flex: 1 },
  header:       { backgroundColor: colors.primaryDark, paddingHorizontal: spacing.lg, paddingBottom: spacing.lg },
  headerTitle:  { color: colors.white, fontSize: fontSize.xl, fontWeight: '700' },
  profileCard:  { flexDirection: 'row', alignItems: 'center', gap: 12, backgroundColor: colors.white, marginHorizontal: spacing.lg, marginTop: spacing.lg, borderRadius: radius.xl, padding: 16, ...shadow.md },
  avatarWrap:   { position: 'relative' },
  avatar:       { width: 52, height: 52, borderRadius: 26, backgroundColor: colors.primaryDark, alignItems: 'center', justifyContent: 'center' },
  avatarText:   { color: colors.white, fontSize: fontSize.lg, fontWeight: '800' },
  onlineDot:    { width: 13, height: 13, borderRadius: 99, backgroundColor: colors.success, borderWidth: 2, borderColor: colors.white, position: 'absolute', bottom: 0, right: 0 },
  name:         { fontSize: fontSize.lg, fontWeight: '800', color: colors.gray900 },
  role:         { fontSize: fontSize.sm, color: colors.primary, fontWeight: '600', marginTop: 1 },
  email:        { fontSize: fontSize.xs, color: colors.gray400, marginTop: 2 },
  editChip:     { flexDirection: 'row', alignItems: 'center', gap: 4, backgroundColor: colors.primaryLight, borderRadius: radius.full, paddingHorizontal: 10, paddingVertical: 5 },
  editText:     { fontSize: fontSize.xs, fontWeight: '700', color: colors.primary },
  statsRow:     { flexDirection: 'row', gap: 10, paddingHorizontal: spacing.lg, marginTop: spacing.md },
  statCard:     { flex: 1, backgroundColor: colors.white, borderRadius: radius.lg, padding: 12, alignItems: 'center', ...shadow.sm },
  statVal:      { fontSize: fontSize.xl, fontWeight: '800' },
  statLabel:    { fontSize: 10, color: colors.gray400, marginTop: 2, textAlign: 'center' },
  section:      { paddingHorizontal: spacing.lg, marginTop: spacing.xl },
  sectionTitle: { fontSize: fontSize.sm, fontWeight: '700', color: colors.gray500, textTransform: 'uppercase', letterSpacing: 0.5, marginBottom: 8 },
  menuCard:     { backgroundColor: colors.white, borderRadius: radius.lg, borderWidth: 1, borderColor: colors.gray200, overflow: 'hidden', ...shadow.sm },
  notifRow:     { flexDirection: 'row', alignItems: 'center', gap: 12, paddingHorizontal: 14, paddingVertical: 12 },
  notifLabel:   { fontSize: fontSize.sm, fontWeight: '600', color: colors.gray800 },
  notifSub:     { fontSize: fontSize.xs, color: colors.gray400, marginTop: 1 },
  menuRow:      { flexDirection: 'row', alignItems: 'center', gap: 12, paddingHorizontal: 14, paddingVertical: 12 },
  menuIcon:     { width: 34, height: 34, borderRadius: 10, backgroundColor: colors.primaryLight, alignItems: 'center', justifyContent: 'center' },
  menuLabel:    { fontSize: fontSize.sm, fontWeight: '600', color: colors.gray800 },
  menuSub:      { fontSize: fontSize.xs, color: colors.gray400, marginTop: 1 },
  divider:      { height: 1, backgroundColor: colors.gray100, marginLeft: 60 },
  signOutBtn:   { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 8, backgroundColor: colors.dangerLight, borderRadius: radius.lg, paddingVertical: 14, borderWidth: 1, borderColor: colors.danger + '30' },
  signOutText:  { fontSize: fontSize.md, fontWeight: '700', color: colors.danger },
  version:      { textAlign: 'center', fontSize: 10, color: colors.gray400, marginTop: 16, lineHeight: 16 },
});
