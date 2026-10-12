import React, { useState } from 'react';
import {
  View, Text, ScrollView, StyleSheet, TouchableOpacity, Alert, Modal, TextInput,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { colors, spacing, radius, fontSize, shadow } from '../theme';
import { APPROVALS, ENQUIRIES } from '../data/mock';
import Badge from '../components/Badge';

const URGENCY_COLOR = { high: 'danger', medium: 'warning', low: 'neutral' };

function ApprovalCard({ item, onApprove, onReject }) {
  const urgencyPct = { high: 85, medium: 55, low: 25 }[item.urgency];
  const barColor   = { high: colors.danger, medium: colors.warning, low: colors.success }[item.urgency];
  return (
    <View style={[styles.card, item.urgency === 'high' && styles.cardUrgent]}>
      <View style={styles.cardHead}>
        <View>
          <Text style={styles.poNum}>{item.po}</Text>
          <Text style={styles.cardSub}>{item.vendor}</Text>
        </View>
        <View style={{ alignItems: 'flex-end' }}>
          <Text style={styles.amount}>{item.amount}</Text>
          <Badge label={item.urgency} color={URGENCY_COLOR[item.urgency]} size="xs" />
        </View>
      </View>
      <Text style={styles.itemDesc}>{item.item}</Text>
      <View style={styles.pendingRow}>
        <Ionicons name="time-outline" size={12} color={item.days >= 4 ? colors.danger : colors.gray400} />
        <Text style={[styles.pendingText, item.days >= 4 && { color: colors.danger, fontWeight: '700' }]}>
          Pending {item.days} day{item.days > 1 ? 's' : ''} · Raised by {item.requestedBy}
        </Text>
      </View>
      <View style={styles.urgencyTrack}>
        <View style={[styles.urgencyBar, { width: `${urgencyPct}%`, backgroundColor: barColor }]} />
      </View>
      <View style={styles.approvalBtns}>
        <TouchableOpacity style={styles.rejectBtn} onPress={() => onReject(item)}>
          <Ionicons name="close-circle-outline" size={16} color={colors.danger} />
          <Text style={styles.rejectText}>Reject</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.approveBtn} onPress={() => onApprove(item)}>
          <Ionicons name="checkmark-circle-outline" size={16} color={colors.white} />
          <Text style={styles.approveText}>Approve</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
}

function EnquiryCard({ item, onAssign, onConvert }) {
  const STATUS_COLOR = { new: 'danger', contacted: 'warning', 'site-visit': 'primary', quoted: 'success' };
  const SOURCE_ICON  = { whatsapp: 'logo-whatsapp', email: 'mail-outline', referral: 'people-outline', direct: 'call-outline' };
  return (
    <View style={styles.card}>
      <View style={styles.cardHead}>
        <View>
          <Text style={styles.poNum}>{item.ref}</Text>
          <Text style={styles.cardSub}>{item.client}</Text>
        </View>
        <Badge label={item.status.replace('-', ' ')} color={STATUS_COLOR[item.status]} size="xs" dot />
      </View>
      <Text style={styles.itemDesc}>{item.scope}</Text>
      <View style={styles.enqMeta}>
        <View style={styles.metaChip}>
          <Ionicons name={SOURCE_ICON[item.source]} size={12} color={colors.gray500} />
          <Text style={styles.metaChipText}>{item.source}</Text>
        </View>
        <View style={styles.metaChip}>
          <Ionicons name="cash-outline" size={12} color={colors.gray500} />
          <Text style={styles.metaChipText}>{item.value}</Text>
        </View>
        <View style={styles.metaChip}>
          <Ionicons name="time-outline" size={12} color={colors.gray500} />
          <Text style={styles.metaChipText}>{item.received.fromNow()}</Text>
        </View>
      </View>
      <View style={styles.enqBtns}>
        <TouchableOpacity style={styles.enqSecBtn} onPress={() => onAssign(item)}>
          <Ionicons name="person-add-outline" size={14} color={colors.primary} />
          <Text style={styles.enqSecText}>Assign</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.enqPrimBtn} onPress={() => onConvert(item)}>
          <Ionicons name="arrow-forward-circle-outline" size={14} color={colors.white} />
          <Text style={styles.enqPrimText}>Log Follow-up</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
}

export default function QuickActionsScreen() {
  const insets = useSafeAreaInsets();
  const [tab, setTab]             = useState('approvals');
  const [approvals, setApprovals] = useState(APPROVALS);
  const [enquiries]               = useState(ENQUIRIES);
  const [noteVisible, setNote]    = useState(false);
  const [noteText, setNoteText]   = useState('');
  const [selectedPO, setSelPO]    = useState(null);

  const handleApprove = (item) => {
    setSelPO(item);
    setNote(true);
  };

  const confirmApprove = () => {
    setNote(false);
    setApprovals(prev => prev.filter(a => a.id !== selectedPO.id));
    Alert.alert('✅ Approved', `${selectedPO.po} approved successfully.`);
    setNoteText('');
  };

  const handleReject = (item) => {
    Alert.alert('Reject PO', `Reject ${item.po} — ${item.vendor}?`, [
      { text: 'Cancel', style: 'cancel' },
      {
        text: 'Reject', style: 'destructive',
        onPress: () => {
          setApprovals(prev => prev.filter(a => a.id !== item.id));
          Alert.alert('❌ Rejected', `${item.po} has been rejected.`);
        },
      },
    ]);
  };

  const handleAssign = (item) => Alert.alert('Assign', `Assign ${item.ref} to a team member?`, [
    { text: 'Priya S',  onPress: () => {} },
    { text: 'Kavya N',  onPress: () => {} },
    { text: 'Cancel', style: 'cancel' },
  ]);

  const handleConvert = (item) => Alert.alert('Log Follow-up', `Log a follow-up call/visit for ${item.ref}?`, [
    { text: 'Log it ✓', onPress: () => {} },
    { text: 'Cancel', style: 'cancel' },
  ]);

  const tabs = [
    { key: 'approvals',  label: 'Approvals',  count: approvals.length,  icon: 'checkmark-circle-outline' },
    { key: 'enquiries',  label: 'Enquiries',  count: enquiries.length,  icon: 'mail-outline'             },
  ];

  return (
    <View style={[styles.container, { backgroundColor: colors.gray50 }]}>
      {/* Header */}
      <View style={[styles.header, { paddingTop: insets.top + 12 }]}>
        <Text style={styles.headerTitle}>Quick Actions</Text>
        <Text style={styles.headerSub}>Approve, assign & take action</Text>
      </View>

      {/* Tabs */}
      <View style={styles.tabBar}>
        {tabs.map(t => (
          <TouchableOpacity key={t.key} style={[styles.tab, tab === t.key && styles.tabActive]}
            onPress={() => setTab(t.key)}>
            <Ionicons name={t.icon} size={16} color={tab === t.key ? colors.primary : colors.gray400} />
            <Text style={[styles.tabText, tab === t.key && styles.tabTextActive]}>{t.label}</Text>
            {t.count > 0 && (
              <View style={[styles.tabBadge, tab === t.key && styles.tabBadgeActive]}>
                <Text style={[styles.tabBadgeText, tab === t.key && { color: colors.white }]}>{t.count}</Text>
              </View>
            )}
          </TouchableOpacity>
        ))}
      </View>

      <ScrollView showsVerticalScrollIndicator={false}
        contentContainerStyle={{ paddingHorizontal: spacing.lg, paddingBottom: 100, paddingTop: spacing.md }}>

        {tab === 'approvals' && (
          <>
            {approvals.length === 0 ? (
              <View style={styles.empty}>
                <Ionicons name="checkmark-done-circle-outline" size={52} color={colors.gray300} />
                <Text style={styles.emptyTitle}>All clear!</Text>
                <Text style={styles.emptyText}>No pending approvals</Text>
              </View>
            ) : (
              <>
                <View style={styles.totalRow}>
                  <Text style={styles.totalLabel}>Total value pending</Text>
                  <Text style={styles.totalAmt}>₹{approvals.reduce((s,a) => s + parseFloat(a.amount.replace('₹','').replace('L','')), 0).toFixed(1)}L</Text>
                </View>
                {approvals.map(a => (
                  <ApprovalCard key={a.id} item={a} onApprove={handleApprove} onReject={handleReject} />
                ))}
              </>
            )}
          </>
        )}

        {tab === 'enquiries' && enquiries.map(e => (
          <EnquiryCard key={e.id} item={e} onAssign={handleAssign} onConvert={handleConvert} />
        ))}
      </ScrollView>

      {/* Approve note modal */}
      <Modal visible={noteVisible} transparent animationType="slide">
        <View style={styles.modalOverlay}>
          <View style={styles.modalSheet}>
            <Text style={styles.modalTitle}>Approve {selectedPO?.po}</Text>
            <Text style={styles.modalSub}>{selectedPO?.vendor} · {selectedPO?.amount}</Text>
            <TextInput
              style={styles.noteInput}
              placeholder="Add approval note (optional)..."
              placeholderTextColor={colors.gray400}
              multiline
              numberOfLines={3}
              value={noteText}
              onChangeText={setNoteText}
            />
            <View style={styles.modalBtns}>
              <TouchableOpacity style={styles.modalCancel} onPress={() => setNote(false)}>
                <Text style={styles.modalCancelText}>Cancel</Text>
              </TouchableOpacity>
              <TouchableOpacity style={styles.modalConfirm} onPress={confirmApprove}>
                <Ionicons name="checkmark-circle" size={18} color={colors.white} />
                <Text style={styles.modalConfirmText}>Confirm Approve</Text>
              </TouchableOpacity>
            </View>
          </View>
        </View>
      </Modal>
    </View>
  );
}

const styles = StyleSheet.create({
  container:       { flex: 1 },
  header:          { backgroundColor: colors.primaryDark, paddingHorizontal: spacing.lg, paddingBottom: spacing.lg },
  headerTitle:     { color: colors.white, fontSize: fontSize.xl, fontWeight: '700' },
  headerSub:       { color: 'rgba(255,255,255,0.6)', fontSize: fontSize.sm, marginTop: 2 },
  tabBar:          { flexDirection: 'row', backgroundColor: colors.white, paddingHorizontal: spacing.lg, paddingVertical: 8, borderBottomWidth: 1, borderColor: colors.gray200, gap: 8 },
  tab:             { flex: 1, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 6, paddingVertical: 8, borderRadius: radius.md, backgroundColor: colors.gray50 },
  tabActive:       { backgroundColor: colors.primaryLight },
  tabText:         { fontSize: fontSize.sm, fontWeight: '600', color: colors.gray500 },
  tabTextActive:   { color: colors.primary },
  tabBadge:        { backgroundColor: colors.gray200, borderRadius: 99, paddingHorizontal: 6, paddingVertical: 1 },
  tabBadgeActive:  { backgroundColor: colors.primary },
  tabBadgeText:    { fontSize: 10, fontWeight: '700', color: colors.gray600 },
  totalRow:        { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: spacing.sm, paddingHorizontal: 2 },
  totalLabel:      { fontSize: fontSize.sm, color: colors.gray500 },
  totalAmt:        { fontSize: fontSize.lg, fontWeight: '800', color: colors.warning },
  card:            { backgroundColor: colors.white, borderRadius: radius.lg, padding: 14, marginBottom: 10, borderWidth: 1, borderColor: colors.gray200, ...shadow.sm },
  cardUrgent:      { borderLeftWidth: 3, borderLeftColor: colors.danger },
  cardHead:        { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 6 },
  poNum:           { fontSize: fontSize.md, fontWeight: '800', color: colors.gray900, fontFamily: 'monospace' },
  cardSub:         { fontSize: fontSize.sm, color: colors.gray500, marginTop: 2 },
  amount:          { fontSize: fontSize.lg, fontWeight: '800', color: colors.gray900, textAlign: 'right' },
  itemDesc:        { fontSize: fontSize.sm, color: colors.gray600, marginBottom: 8 },
  pendingRow:      { flexDirection: 'row', alignItems: 'center', gap: 4, marginBottom: 8 },
  pendingText:     { fontSize: fontSize.xs, color: colors.gray400 },
  urgencyTrack:    { height: 4, backgroundColor: colors.gray100, borderRadius: 99, overflow: 'hidden', marginBottom: 12 },
  urgencyBar:      { height: '100%', borderRadius: 99 },
  approvalBtns:    { flexDirection: 'row', gap: 10 },
  rejectBtn:       { flex: 1, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 6, paddingVertical: 9, borderRadius: radius.md, borderWidth: 1.5, borderColor: colors.danger + '60', backgroundColor: colors.dangerLight },
  rejectText:      { fontSize: fontSize.sm, fontWeight: '700', color: colors.danger },
  approveBtn:      { flex: 2, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 6, paddingVertical: 9, borderRadius: radius.md, backgroundColor: colors.success },
  approveText:     { fontSize: fontSize.sm, fontWeight: '700', color: colors.white },
  enqMeta:         { flexDirection: 'row', gap: 8, marginBottom: 10, flexWrap: 'wrap' },
  metaChip:        { flexDirection: 'row', alignItems: 'center', gap: 4, backgroundColor: colors.gray50, paddingHorizontal: 8, paddingVertical: 3, borderRadius: radius.full, borderWidth: 1, borderColor: colors.gray200 },
  metaChipText:    { fontSize: 10, color: colors.gray500 },
  enqBtns:         { flexDirection: 'row', gap: 8 },
  enqSecBtn:       { flex: 1, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 5, paddingVertical: 8, borderRadius: radius.md, borderWidth: 1, borderColor: colors.primary + '40', backgroundColor: colors.primaryLight },
  enqSecText:      { fontSize: fontSize.sm, fontWeight: '700', color: colors.primary },
  enqPrimBtn:      { flex: 2, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 5, paddingVertical: 8, borderRadius: radius.md, backgroundColor: colors.primary },
  enqPrimText:     { fontSize: fontSize.sm, fontWeight: '700', color: colors.white },
  empty:           { alignItems: 'center', paddingTop: 60, gap: 10 },
  emptyTitle:      { fontSize: fontSize.lg, fontWeight: '700', color: colors.gray700 },
  emptyText:       { fontSize: fontSize.sm, color: colors.gray400 },
  modalOverlay:    { flex: 1, backgroundColor: 'rgba(0,0,0,0.5)', justifyContent: 'flex-end' },
  modalSheet:      { backgroundColor: colors.white, borderTopLeftRadius: 20, borderTopRightRadius: 20, padding: 24, paddingBottom: 40 },
  modalTitle:      { fontSize: fontSize.lg, fontWeight: '800', color: colors.gray900, marginBottom: 4 },
  modalSub:        { fontSize: fontSize.sm, color: colors.gray500, marginBottom: 16 },
  noteInput:       { backgroundColor: colors.gray50, borderWidth: 1, borderColor: colors.gray200, borderRadius: radius.md, padding: 12, fontSize: fontSize.sm, color: colors.gray800, minHeight: 80, textAlignVertical: 'top', marginBottom: 16 },
  modalBtns:       { flexDirection: 'row', gap: 10 },
  modalCancel:     { flex: 1, paddingVertical: 12, borderRadius: radius.md, borderWidth: 1, borderColor: colors.gray300, alignItems: 'center' },
  modalCancelText: { fontSize: fontSize.md, fontWeight: '600', color: colors.gray600 },
  modalConfirm:    { flex: 2, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 6, paddingVertical: 12, borderRadius: radius.md, backgroundColor: colors.success },
  modalConfirmText:{ fontSize: fontSize.md, fontWeight: '700', color: colors.white },
});
