import React, { useState } from 'react';
import {
  View, Text, ScrollView, StyleSheet, TouchableOpacity, Modal, TextInput, Alert,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import dayjs from 'dayjs';
import { colors, spacing, radius, fontSize, shadow } from '../theme';
import { REMINDERS } from '../data/mock';

const TYPE_META = {
  call:     { icon: 'call-outline',            color: colors.primary  },
  report:   { icon: 'document-text-outline',   color: colors.info     },
  approval: { icon: 'checkmark-circle-outline',color: colors.warning  },
  visit:    { icon: 'location-outline',        color: colors.success  },
  task:     { icon: 'checkbox-outline',        color: colors.gray500  },
};
const PRIORITY_COLOR = { high: colors.danger, medium: colors.warning, low: colors.gray400 };

const REPEAT_LABELS = { none: 'Once', daily: 'Daily', weekly: 'Weekly', monthly: 'Monthly' };

export default function RemindersScreen() {
  const insets = useSafeAreaInsets();
  const [reminders, setReminders] = useState(REMINDERS);
  const [addVisible, setAddVisible] = useState(false);
  const [newTitle, setNewTitle]     = useState('');
  const [newPriority, setNewPriority] = useState('medium');

  const toggleDone = (id) => setReminders(prev => prev.map(r => r.id === id ? { ...r, done: !r.done } : r));
  const deleteR    = (id) => {
    Alert.alert('Delete Reminder', 'Remove this reminder?', [
      { text: 'Cancel', style: 'cancel' },
      { text: 'Delete', style: 'destructive', onPress: () => setReminders(prev => prev.filter(r => r.id !== id)) },
    ]);
  };

  const addReminder = () => {
    if (!newTitle.trim()) return;
    const r = {
      id: Date.now(), title: newTitle.trim(),
      time: dayjs().add(1, 'hour'), type: 'task',
      priority: newPriority, repeat: 'none', done: false,
    };
    setReminders(prev => [r, ...prev]);
    setNewTitle(''); setNewPriority('medium'); setAddVisible(false);
  };

  const today    = reminders.filter(r => !r.done && dayjs(r.time).isSame(dayjs(), 'day'));
  const upcoming = reminders.filter(r => !r.done && dayjs(r.time).isAfter(dayjs(), 'day'));
  const done     = reminders.filter(r => r.done);

  const ReminderRow = ({ item }) => {
    const tm = TYPE_META[item.type] || TYPE_META.task;
    const isOverdue = !item.done && dayjs(item.time).isBefore(dayjs(), 'minute');
    return (
      <View style={[styles.row, item.done && styles.rowDone, isOverdue && styles.rowOverdue]}>
        <TouchableOpacity onPress={() => toggleDone(item.id)} style={styles.checkWrap}>
          <View style={[styles.typeIcon, { backgroundColor: tm.color + '15' }]}>
            <Ionicons name={item.done ? 'checkmark-circle' : tm.icon} size={18}
              color={item.done ? colors.success : tm.color} />
          </View>
        </TouchableOpacity>
        <View style={{ flex: 1 }}>
          <Text style={[styles.rowTitle, item.done && styles.rowTitleDone]}>{item.title}</Text>
          <View style={styles.rowMeta}>
            <Ionicons name="time-outline" size={11} color={isOverdue ? colors.danger : colors.gray400} />
            <Text style={[styles.rowTime, isOverdue && { color: colors.danger, fontWeight: '700' }]}>
              {dayjs(item.time).format('h:mm A')} · {REPEAT_LABELS[item.repeat]}
            </Text>
            <View style={[styles.priorityDot, { backgroundColor: PRIORITY_COLOR[item.priority] }]} />
          </View>
        </View>
        {!item.done && (
          <TouchableOpacity onPress={() => deleteR(item.id)} style={styles.deleteBtn}>
            <Ionicons name="trash-outline" size={16} color={colors.gray300} />
          </TouchableOpacity>
        )}
      </View>
    );
  };

  const Section = ({ title, items, accent }) =>
    items.length === 0 ? null : (
      <View style={styles.section}>
        <View style={styles.sectionHead}>
          <View style={[styles.sectionDot, { backgroundColor: accent }]} />
          <Text style={styles.sectionTitle}>{title}</Text>
          <Text style={styles.sectionCount}>{items.length}</Text>
        </View>
        <View style={styles.sectionCard}>
          {items.map((item, i) => (
            <View key={item.id}>
              <ReminderRow item={item} />
              {i < items.length - 1 && <View style={styles.divider} />}
            </View>
          ))}
        </View>
      </View>
    );

  return (
    <View style={[styles.container, { backgroundColor: colors.gray50 }]}>
      {/* Header */}
      <View style={[styles.header, { paddingTop: insets.top + 12 }]}>
        <View>
          <Text style={styles.headerTitle}>Reminders</Text>
          <Text style={styles.headerSub}>{today.length} due today · {upcoming.length} upcoming</Text>
        </View>
        <TouchableOpacity style={styles.addBtn} onPress={() => setAddVisible(true)}>
          <Ionicons name="add" size={22} color={colors.white} />
        </TouchableOpacity>
      </View>

      <ScrollView showsVerticalScrollIndicator={false}
        contentContainerStyle={{ paddingHorizontal: spacing.lg, paddingBottom: 100, paddingTop: spacing.md }}>
        <Section title="Today" items={today} accent={colors.danger} />
        <Section title="Upcoming" items={upcoming} accent={colors.primary} />
        {done.length > 0 && (
          <View style={styles.section}>
            <View style={styles.sectionHead}>
              <View style={[styles.sectionDot, { backgroundColor: colors.success }]} />
              <Text style={styles.sectionTitle}>Completed</Text>
              <Text style={styles.sectionCount}>{done.length}</Text>
            </View>
            <View style={styles.sectionCard}>
              {done.map((item, i) => (
                <View key={item.id}>
                  <ReminderRow item={item} />
                  {i < done.length - 1 && <View style={styles.divider} />}
                </View>
              ))}
            </View>
          </View>
        )}
        {reminders.length === 0 && (
          <View style={styles.empty}>
            <Ionicons name="alarm-outline" size={52} color={colors.gray300} />
            <Text style={styles.emptyText}>No reminders yet</Text>
            <TouchableOpacity style={styles.emptyBtn} onPress={() => setAddVisible(true)}>
              <Text style={styles.emptyBtnText}>+ Add Reminder</Text>
            </TouchableOpacity>
          </View>
        )}
      </ScrollView>

      {/* Add Reminder Modal */}
      <Modal visible={addVisible} transparent animationType="slide">
        <View style={styles.modalOverlay}>
          <View style={styles.modalSheet}>
            <View style={styles.modalHandle} />
            <Text style={styles.modalTitle}>New Reminder</Text>
            <TextInput
              style={styles.titleInput}
              placeholder="What do you need to remember?"
              placeholderTextColor={colors.gray400}
              value={newTitle}
              onChangeText={setNewTitle}
              multiline
              autoFocus
            />
            <Text style={styles.modalLabel}>Priority</Text>
            <View style={styles.priorityRow}>
              {['high', 'medium', 'low'].map(p => (
                <TouchableOpacity key={p} style={[styles.prioBtn, newPriority === p && styles.prioBtnActive(p)]}
                  onPress={() => setNewPriority(p)}>
                  <View style={[styles.prioDot, { backgroundColor: PRIORITY_COLOR[p] }]} />
                  <Text style={[styles.prioText, newPriority === p && { color: PRIORITY_COLOR[p], fontWeight: '700' }]}>
                    {p.charAt(0).toUpperCase() + p.slice(1)}
                  </Text>
                </TouchableOpacity>
              ))}
            </View>
            <View style={styles.modalBtns}>
              <TouchableOpacity style={styles.cancelBtn} onPress={() => setAddVisible(false)}>
                <Text style={styles.cancelText}>Cancel</Text>
              </TouchableOpacity>
              <TouchableOpacity style={[styles.saveBtn, !newTitle.trim() && { opacity: 0.5 }]} onPress={addReminder}>
                <Ionicons name="alarm-outline" size={16} color={colors.white} />
                <Text style={styles.saveText}>Add Reminder</Text>
              </TouchableOpacity>
            </View>
          </View>
        </View>
      </Modal>
    </View>
  );
}

const styles = StyleSheet.create({
  container:      { flex: 1 },
  header:         { backgroundColor: colors.primaryDark, paddingHorizontal: spacing.lg, paddingBottom: spacing.lg, flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' },
  headerTitle:    { color: colors.white, fontSize: fontSize.xl, fontWeight: '700' },
  headerSub:      { color: 'rgba(255,255,255,0.6)', fontSize: fontSize.sm, marginTop: 2 },
  addBtn:         { width: 38, height: 38, borderRadius: 19, backgroundColor: colors.primary, alignItems: 'center', justifyContent: 'center' },
  section:        { marginBottom: spacing.lg },
  sectionHead:    { flexDirection: 'row', alignItems: 'center', gap: 8, marginBottom: 8 },
  sectionDot:     { width: 8, height: 8, borderRadius: 4 },
  sectionTitle:   { fontSize: fontSize.md, fontWeight: '700', color: colors.gray800, flex: 1 },
  sectionCount:   { fontSize: fontSize.sm, color: colors.gray400, fontWeight: '600' },
  sectionCard:    { backgroundColor: colors.white, borderRadius: radius.lg, borderWidth: 1, borderColor: colors.gray200, ...shadow.sm },
  row:            { flexDirection: 'row', alignItems: 'center', gap: 10, padding: 12 },
  rowDone:        { opacity: 0.5 },
  rowOverdue:     { backgroundColor: colors.dangerLight + '50' },
  checkWrap:      { width: 38 },
  typeIcon:       { width: 34, height: 34, borderRadius: 10, alignItems: 'center', justifyContent: 'center' },
  rowTitle:       { fontSize: fontSize.sm, fontWeight: '600', color: colors.gray800 },
  rowTitleDone:   { textDecorationLine: 'line-through', color: colors.gray400 },
  rowMeta:        { flexDirection: 'row', alignItems: 'center', gap: 4, marginTop: 3 },
  rowTime:        { fontSize: 10, color: colors.gray400 },
  priorityDot:    { width: 5, height: 5, borderRadius: 99 },
  deleteBtn:      { padding: 6 },
  divider:        { height: 1, backgroundColor: colors.gray100, marginLeft: 58 },
  empty:          { alignItems: 'center', paddingTop: 60, gap: 12 },
  emptyText:      { color: colors.gray400, fontSize: fontSize.md },
  emptyBtn:       { backgroundColor: colors.primary, borderRadius: radius.md, paddingHorizontal: 20, paddingVertical: 10, marginTop: 4 },
  emptyBtnText:   { color: colors.white, fontWeight: '700', fontSize: fontSize.sm },
  modalOverlay:   { flex: 1, backgroundColor: 'rgba(0,0,0,0.45)', justifyContent: 'flex-end' },
  modalSheet:     { backgroundColor: colors.white, borderTopLeftRadius: 22, borderTopRightRadius: 22, padding: 22, paddingBottom: 40 },
  modalHandle:    { width: 40, height: 4, borderRadius: 2, backgroundColor: colors.gray300, alignSelf: 'center', marginBottom: 18 },
  modalTitle:     { fontSize: fontSize.lg, fontWeight: '800', color: colors.gray900, marginBottom: 14 },
  titleInput:     { backgroundColor: colors.gray50, borderWidth: 1, borderColor: colors.gray200, borderRadius: radius.md, padding: 12, fontSize: fontSize.md, color: colors.gray800, minHeight: 72, textAlignVertical: 'top', marginBottom: 18 },
  modalLabel:     { fontSize: fontSize.sm, fontWeight: '700', color: colors.gray700, marginBottom: 8 },
  priorityRow:    { flexDirection: 'row', gap: 8, marginBottom: 22 },
  prioBtn:        { flex: 1, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 5, paddingVertical: 8, borderRadius: radius.md, borderWidth: 1, borderColor: colors.gray200, backgroundColor: colors.gray50 },
  prioBtnActive:  (p) => ({ borderColor: PRIORITY_COLOR[p], backgroundColor: PRIORITY_COLOR[p] + '10' }),
  prioDot:        { width: 7, height: 7, borderRadius: 99 },
  prioText:       { fontSize: fontSize.sm, color: colors.gray600 },
  modalBtns:      { flexDirection: 'row', gap: 10 },
  cancelBtn:      { flex: 1, paddingVertical: 12, borderRadius: radius.md, borderWidth: 1, borderColor: colors.gray200, alignItems: 'center' },
  cancelText:     { fontSize: fontSize.md, fontWeight: '600', color: colors.gray600 },
  saveBtn:        { flex: 2, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 6, paddingVertical: 12, borderRadius: radius.md, backgroundColor: colors.primary },
  saveText:       { fontSize: fontSize.md, fontWeight: '700', color: colors.white },
});
