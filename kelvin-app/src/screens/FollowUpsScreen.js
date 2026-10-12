import React, { useState } from 'react';
import {
  View, Text, ScrollView, StyleSheet, TouchableOpacity, Alert, TextInput,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import dayjs from 'dayjs';
import { colors, spacing, radius, fontSize, shadow } from '../theme';
import { FOLLOWUPS } from '../data/mock';
import Badge from '../components/Badge';

const STATUS_META = {
  overdue:   { color: 'danger',  label: 'Overdue',   bg: colors.dangerLight  },
  'due-today':{ color: 'warning', label: 'Due Today', bg: colors.warningLight },
  upcoming:  { color: 'neutral', label: 'Upcoming',  bg: colors.gray100      },
};

const CHANNEL_ICON = { whatsapp: 'logo-whatsapp', call: 'call', email: 'mail' };
const CHANNEL_COLOR = { whatsapp: '#25D366', call: colors.primary, email: colors.info };

const FILTERS = ['All', 'Overdue', 'Due Today', 'Upcoming'];

export default function FollowUpsScreen() {
  const insets = useSafeAreaInsets();
  const [followups, setFollowups] = useState(FOLLOWUPS);
  const [filter, setFilter]       = useState('All');
  const [search, setSearch]       = useState('');
  const [noteModal, setNoteModal] = useState(null);

  const filtered = followups.filter(f => {
    const matchFilter =
      filter === 'All'      ? true :
      filter === 'Overdue'  ? f.status === 'overdue' :
      filter === 'Due Today'? f.status === 'due-today' :
                              f.status === 'upcoming';
    const matchSearch = search === '' || f.contact.toLowerCase().includes(search.toLowerCase()) || f.company.toLowerCase().includes(search.toLowerCase());
    return matchFilter && matchSearch;
  });

  const markDone = (id) => {
    Alert.alert('Mark Complete', 'Mark this follow-up as done?', [
      { text: 'Cancel', style: 'cancel' },
      { text: 'Done ✓', onPress: () => setFollowups(prev => prev.filter(f => f.id !== id)) },
    ]);
  };

  const snooze = (id) => {
    Alert.alert('Snooze', 'Snooze for how long?', [
      { text: '1 hour',    onPress: () => setFollowups(prev => prev.map(f => f.id === id ? { ...f, status: 'upcoming', due: dayjs(f.due).add(1,'hour') } : f)) },
      { text: 'Tomorrow',  onPress: () => setFollowups(prev => prev.map(f => f.id === id ? { ...f, status: 'upcoming', due: dayjs(f.due).add(1,'day')  } : f)) },
      { text: 'Cancel', style: 'cancel' },
    ]);
  };

  const sendPing = (f) => {
    const msgs = {
      whatsapp: `Hi ${f.contact}, this is a quick follow-up regarding ${f.topic}. Could you please update us at your earliest convenience?`,
      call:     `Call ${f.contact} at ${f.phone} — re: ${f.topic}`,
      email:    `Draft email to ${f.contact} — ${f.topic}`,
    };
    Alert.alert(`Send via ${f.channel}`, msgs[f.channel], [
      { text: 'Send ✓', onPress: () => {} },
      { text: 'Cancel', style: 'cancel' },
    ]);
  };

  const overdueCount   = followups.filter(f => f.status === 'overdue').length;
  const dueTodayCount  = followups.filter(f => f.status === 'due-today').length;

  return (
    <View style={[styles.container, { backgroundColor: colors.gray50 }]}>
      {/* Header */}
      <View style={[styles.header, { paddingTop: insets.top + 12 }]}>
        <Text style={styles.headerTitle}>Follow-ups</Text>
        <View style={styles.headerStats}>
          {overdueCount  > 0 && <View style={styles.statChip}><Text style={[styles.statNum, { color: colors.danger }]}>{overdueCount}</Text><Text style={styles.statLabel}> overdue</Text></View>}
          {dueTodayCount > 0 && <View style={styles.statChip}><Text style={[styles.statNum, { color: colors.warning }]}>{dueTodayCount}</Text><Text style={styles.statLabel}> today</Text></View>}
        </View>
      </View>

      {/* Search */}
      <View style={styles.searchWrap}>
        <Ionicons name="search" size={16} color={colors.gray400} style={{ marginLeft: 10 }} />
        <TextInput
          placeholder="Search contact or company..."
          placeholderTextColor={colors.gray400}
          value={search}
          onChangeText={setSearch}
          style={styles.searchInput}
        />
        {search !== '' && (
          <TouchableOpacity onPress={() => setSearch('')} style={{ paddingRight: 10 }}>
            <Ionicons name="close-circle" size={16} color={colors.gray400} />
          </TouchableOpacity>
        )}
      </View>

      {/* Filter tabs */}
      <ScrollView horizontal showsHorizontalScrollIndicator={false}
        style={styles.filterScroll} contentContainerStyle={styles.filterContent}>
        {FILTERS.map(f => (
          <TouchableOpacity key={f} onPress={() => setFilter(f)}
            style={[styles.filterTab, filter === f && styles.filterTabActive]}>
            <Text style={[styles.filterText, filter === f && styles.filterTextActive]}>{f}</Text>
          </TouchableOpacity>
        ))}
      </ScrollView>

      {/* List */}
      <ScrollView showsVerticalScrollIndicator={false} contentContainerStyle={{ paddingHorizontal: spacing.lg, paddingBottom: 100, paddingTop: 4 }}>
        {filtered.length === 0 && (
          <View style={styles.empty}>
            <Ionicons name="checkmark-done-circle-outline" size={48} color={colors.gray300} />
            <Text style={styles.emptyText}>All caught up!</Text>
          </View>
        )}
        {filtered.map(f => {
          const sm = STATUS_META[f.status];
          const isOverdue = f.status === 'overdue';
          return (
            <View key={f.id} style={[styles.card, isOverdue && styles.cardOverdue]}>
              {/* Top row */}
              <View style={styles.cardTop}>
                <View style={{ flex: 1 }}>
                  <Text style={styles.contactName}>{f.contact}</Text>
                  <Text style={styles.company}>{f.company}</Text>
                </View>
                <Badge label={sm.label} color={sm.color} size="xs" dot />
              </View>

              {/* Topic */}
              <Text style={styles.topic}>{f.topic}</Text>
              <Text style={styles.project}>{f.project}</Text>

              {/* Meta */}
              <View style={styles.metaRow}>
                <Ionicons name="time-outline" size={12} color={colors.gray400} />
                <Text style={[styles.metaText, isOverdue && { color: colors.danger, fontWeight: '700' }]}>
                  {isOverdue ? `Overdue · was ${dayjs(f.due).format('DD MMM')}` : dayjs(f.due).isSame(dayjs(), 'day') ? 'Due Today' : dayjs(f.due).format('DD MMM, h:mm A')}
                </Text>
              </View>

              {/* Actions */}
              <View style={styles.actions}>
                <TouchableOpacity style={[styles.actionBtn, { backgroundColor: CHANNEL_COLOR[f.channel] + '15', borderColor: CHANNEL_COLOR[f.channel] + '40' }]}
                  onPress={() => sendPing(f)}>
                  <Ionicons name={CHANNEL_ICON[f.channel]} size={14} color={CHANNEL_COLOR[f.channel]} />
                  <Text style={[styles.actionText, { color: CHANNEL_COLOR[f.channel] }]}>
                    {f.channel === 'whatsapp' ? 'WhatsApp' : f.channel === 'call' ? 'Call' : 'Email'}
                  </Text>
                </TouchableOpacity>

                <TouchableOpacity style={[styles.actionBtn, { backgroundColor: colors.warningLight, borderColor: colors.warning + '40' }]}
                  onPress={() => snooze(f.id)}>
                  <Ionicons name="alarm-outline" size={14} color={colors.warning} />
                  <Text style={[styles.actionText, { color: colors.warning }]}>Snooze</Text>
                </TouchableOpacity>

                <TouchableOpacity style={[styles.actionBtn, { backgroundColor: colors.successLight, borderColor: colors.success + '40' }]}
                  onPress={() => markDone(f.id)}>
                  <Ionicons name="checkmark-circle-outline" size={14} color={colors.success} />
                  <Text style={[styles.actionText, { color: colors.success }]}>Done</Text>
                </TouchableOpacity>
              </View>
            </View>
          );
        })}
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container:         { flex: 1 },
  header:            { backgroundColor: colors.primaryDark, paddingHorizontal: spacing.lg, paddingBottom: spacing.lg, flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' },
  headerTitle:       { color: colors.white, fontSize: fontSize.xl, fontWeight: '700' },
  headerStats:       { flexDirection: 'row', gap: 12 },
  statChip:          { flexDirection: 'row', alignItems: 'center' },
  statNum:           { fontWeight: '800', fontSize: fontSize.md },
  statLabel:         { color: 'rgba(255,255,255,0.7)', fontSize: fontSize.sm },
  searchWrap:        { flexDirection: 'row', alignItems: 'center', backgroundColor: colors.white, marginHorizontal: spacing.lg, marginTop: spacing.md, borderRadius: radius.md, borderWidth: 1, borderColor: colors.gray200, ...shadow.sm },
  searchInput:       { flex: 1, paddingVertical: 9, paddingHorizontal: 8, fontSize: fontSize.sm, color: colors.gray800 },
  filterScroll:      { maxHeight: 44, marginTop: spacing.sm },
  filterContent:     { paddingHorizontal: spacing.lg, gap: 8, alignItems: 'center' },
  filterTab:         { paddingHorizontal: 14, paddingVertical: 6, borderRadius: radius.full, backgroundColor: colors.gray100 },
  filterTabActive:   { backgroundColor: colors.primary },
  filterText:        { fontSize: fontSize.sm, color: colors.gray600, fontWeight: '500' },
  filterTextActive:  { color: colors.white, fontWeight: '700' },
  empty:             { alignItems: 'center', paddingTop: 60, gap: 12 },
  emptyText:         { color: colors.gray400, fontSize: fontSize.md },
  card:              { backgroundColor: colors.white, borderRadius: radius.lg, padding: 14, marginBottom: 10, borderWidth: 1, borderColor: colors.gray200, ...shadow.sm },
  cardOverdue:       { borderColor: '#FCA5A5', borderLeftWidth: 3, borderLeftColor: colors.danger },
  cardTop:           { flexDirection: 'row', alignItems: 'flex-start', marginBottom: 6 },
  contactName:       { fontSize: fontSize.md, fontWeight: '700', color: colors.gray900 },
  company:           { fontSize: fontSize.sm, color: colors.gray500, marginTop: 1 },
  topic:             { fontSize: fontSize.sm, color: colors.gray700, marginBottom: 2 },
  project:           { fontSize: fontSize.xs, color: colors.primary, fontWeight: '600', marginBottom: 8 },
  metaRow:           { flexDirection: 'row', alignItems: 'center', gap: 4, marginBottom: 12 },
  metaText:          { fontSize: fontSize.xs, color: colors.gray400 },
  actions:           { flexDirection: 'row', gap: 8 },
  actionBtn:         { flex: 1, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 4, paddingVertical: 7, borderRadius: radius.md, borderWidth: 1 },
  actionText:        { fontSize: fontSize.xs, fontWeight: '700' },
});
