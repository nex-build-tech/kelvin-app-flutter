import React, { useState } from 'react';
import {
  View, Text, StyleSheet, FlatList, TouchableOpacity,
  Alert, Animated, RefreshControl,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import dayjs from 'dayjs';
import relativeTime from 'dayjs/plugin/relativeTime';
import { useNotifications } from '../context/NotificationContext';
import { colors } from '../theme';

dayjs.extend(relativeTime);

const TYPE_FILTERS = ['All', 'SLA', 'Approvals', 'Enquiries', 'System'];
const TYPE_MAP = { SLA: 'sla', Approvals: 'approval', Enquiries: 'enquiry', System: 'system' };

const COLOR_MAP = {
  danger:  { bg: '#FEF2F2', icon: '#EF4444', border: '#FECACA' },
  warning: { bg: '#FFFBEB', icon: '#F59E0B', border: '#FDE68A' },
  primary: { bg: '#EFF6FF', icon: '#1A56DB', border: '#BFDBFE' },
  success: { bg: '#F0FDF4', icon: '#10B981', border: '#A7F3D0' },
  info:    { bg: '#F0F9FF', icon: '#0EA5E9', border: '#BAE6FD' },
};

export default function NotificationsScreen({ navigation }) {
  const { notifications, markRead, markAllRead, clearAll, unreadCount } = useNotifications();
  const [filter, setFilter]       = useState('All');
  const [refreshing, setRefreshing] = useState(false);

  const filtered = filter === 'All'
    ? notifications
    : notifications.filter(n => n.type === TYPE_MAP[filter]);

  const onRefresh = () => {
    setRefreshing(true);
    setTimeout(() => setRefreshing(false), 800);
  };

  const handleClearAll = () => {
    Alert.alert('Clear All Notifications', 'This will remove all notifications. Continue?', [
      { text: 'Cancel', style: 'cancel' },
      { text: 'Clear All', style: 'destructive', onPress: clearAll },
    ]);
  };

  const renderItem = ({ item }) => {
    const c = COLOR_MAP[item.color] || COLOR_MAP.primary;
    return (
      <TouchableOpacity
        style={[styles.notifCard, !item.read && styles.notifCardUnread]}
        onPress={() => markRead(item.id)}
        activeOpacity={0.75}
      >
        {/* Unread dot */}
        {!item.read && <View style={styles.unreadDot} />}

        {/* Icon */}
        <View style={[styles.iconWrap, { backgroundColor: c.bg, borderColor: c.border }]}>
          <Ionicons name={item.icon} size={20} color={c.icon} />
        </View>

        {/* Content */}
        <View style={styles.notifContent}>
          <Text style={[styles.notifTitle, !item.read && styles.notifTitleUnread]} numberOfLines={1}>
            {item.title}
          </Text>
          <Text style={styles.notifBody} numberOfLines={2}>{item.body}</Text>
          <Text style={styles.notifTime}>{dayjs(item.time).fromNow()}</Text>
        </View>

        {/* Mark read */}
        {!item.read && (
          <TouchableOpacity style={styles.readBtn} onPress={() => markRead(item.id)}>
            <Ionicons name="checkmark-circle-outline" size={20} color={colors.primary} />
          </TouchableOpacity>
        )}
      </TouchableOpacity>
    );
  };

  return (
    <SafeAreaView style={styles.safe} edges={['top']}>
      {/* Header */}
      <View style={styles.header}>
        <TouchableOpacity onPress={() => navigation.goBack()} style={styles.backBtn}>
          <Ionicons name="arrow-back" size={22} color={colors.gray800} />
        </TouchableOpacity>
        <View style={{ flex: 1 }}>
          <Text style={styles.headerTitle}>Notifications</Text>
          {unreadCount > 0 && (
            <Text style={styles.headerSub}>{unreadCount} unread</Text>
          )}
        </View>
        <TouchableOpacity onPress={markAllRead} style={styles.actionBtn}>
          <Ionicons name="checkmark-done-outline" size={20} color={colors.primary} />
        </TouchableOpacity>
        <TouchableOpacity onPress={handleClearAll} style={styles.actionBtn}>
          <Ionicons name="trash-outline" size={20} color={colors.danger} />
        </TouchableOpacity>
      </View>

      {/* Filter tabs */}
      <View style={styles.filterWrap}>
        {TYPE_FILTERS.map(f => (
          <TouchableOpacity
            key={f}
            style={[styles.filterTab, filter === f && styles.filterTabActive]}
            onPress={() => setFilter(f)}
          >
            <Text style={[styles.filterText, filter === f && styles.filterTextActive]}>{f}</Text>
          </TouchableOpacity>
        ))}
      </View>

      {/* List */}
      <FlatList
        data={filtered}
        keyExtractor={item => String(item.id)}
        renderItem={renderItem}
        contentContainerStyle={styles.list}
        showsVerticalScrollIndicator={false}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} tintColor={colors.primary} />}
        ListEmptyComponent={
          <View style={styles.empty}>
            <Ionicons name="notifications-off-outline" size={48} color={colors.gray300} />
            <Text style={styles.emptyText}>No notifications here</Text>
          </View>
        }
        ItemSeparatorComponent={() => <View style={{ height: 8 }} />}
      />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe:              { flex: 1, backgroundColor: colors.gray50 },

  header:            { flexDirection: 'row', alignItems: 'center', paddingHorizontal: 16, paddingVertical: 12, backgroundColor: colors.white, borderBottomWidth: 1, borderBottomColor: colors.gray100, gap: 8 },
  backBtn:           { width: 36, height: 36, borderRadius: 18, backgroundColor: colors.gray100, alignItems: 'center', justifyContent: 'center' },
  headerTitle:       { fontSize: 18, fontWeight: '800', color: colors.gray900 },
  headerSub:         { fontSize: 11, color: colors.primary, fontWeight: '600', marginTop: 1 },
  actionBtn:         { width: 36, height: 36, borderRadius: 18, backgroundColor: colors.gray100, alignItems: 'center', justifyContent: 'center' },

  filterWrap:        { flexDirection: 'row', paddingHorizontal: 16, paddingVertical: 10, backgroundColor: colors.white, gap: 8, borderBottomWidth: 1, borderBottomColor: colors.gray100 },
  filterTab:         { paddingHorizontal: 12, paddingVertical: 5, borderRadius: 20, backgroundColor: colors.gray100 },
  filterTabActive:   { backgroundColor: colors.primary },
  filterText:        { fontSize: 12, fontWeight: '600', color: colors.gray500 },
  filterTextActive:  { color: colors.white },

  list:              { padding: 16, paddingBottom: 32 },

  notifCard:         { flexDirection: 'row', alignItems: 'flex-start', backgroundColor: colors.white, borderRadius: 16, padding: 14, borderWidth: 1, borderColor: colors.gray100, shadowColor: '#000', shadowOffset: { width: 0, height: 1 }, shadowOpacity: 0.04, shadowRadius: 4, elevation: 2 },
  notifCardUnread:   { borderColor: colors.primary + '30', backgroundColor: '#EFF6FF' },
  unreadDot:         { position: 'absolute', top: 14, left: 7, width: 7, height: 7, borderRadius: 4, backgroundColor: colors.primary },
  iconWrap:          { width: 40, height: 40, borderRadius: 12, alignItems: 'center', justifyContent: 'center', borderWidth: 1, marginRight: 12, flexShrink: 0 },
  notifContent:      { flex: 1 },
  notifTitle:        { fontSize: 13, fontWeight: '600', color: colors.gray600, marginBottom: 3 },
  notifTitleUnread:  { fontWeight: '800', color: colors.gray900 },
  notifBody:         { fontSize: 12, color: colors.gray500, lineHeight: 18, marginBottom: 5 },
  notifTime:         { fontSize: 11, color: colors.gray400, fontWeight: '500' },
  readBtn:           { marginLeft: 8, flexShrink: 0 },

  empty:             { alignItems: 'center', paddingTop: 80, gap: 12 },
  emptyText:         { fontSize: 15, color: colors.gray400, fontWeight: '600' },
});
