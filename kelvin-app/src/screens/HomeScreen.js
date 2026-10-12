import React, { useState, useEffect, useRef } from 'react';
import {
  View, Text, ScrollView, StyleSheet, TouchableOpacity,
  RefreshControl, Animated,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import dayjs from 'dayjs';
import relativeTime from 'dayjs/plugin/relativeTime';
import { colors, spacing, radius, fontSize } from '../theme';
import { ME, KPI_CARDS, MY_TASKS, ACTIVITY_FEED, PROJECTS } from '../data/mock';
import { useLiveKpis, useLiveProjects, useLiveFeed } from '../hooks/useLiveData';
import { useAuth } from '../context/AuthContext';
import Card from '../components/Card';
import Badge from '../components/Badge';
import NotificationBell from '../components/NotificationBell';

dayjs.extend(relativeTime);

const STATUS_COLOR   = { 'on-track': 'success', 'at-risk': 'warning', 'delayed': 'danger' };
const PRIORITY_COLOR = { high: 'danger', medium: 'warning', low: 'neutral' };
const TYPE_ICON      = { followup: 'call-outline', approval: 'checkmark-circle-outline', task: 'checkbox-outline', visit: 'location-outline', update: 'refresh-outline' };

const FEED_POOL = [
  { icon: '📦', text: 'PO-2024-092 Voltas — delivery confirmed at Airport T3', time: dayjs() },
  { icon: '✅', text: 'SLA resolved: Fire Dampers Pharma Plant closed by Suresh I', time: dayjs() },
  { icon: '📞', text: 'Follow-up logged: Greenfield Dev — HVAC quote sent', time: dayjs() },
  { icon: '⚡', text: 'Approval pending: PO-2024-097 Daikin ₹14.2L — 1 day old', time: dayjs() },
  { icon: '📊', text: 'Airport T3 crossed 65% milestone — on track', time: dayjs() },
  { icon: '💬', text: 'WhatsApp: DLF Infra — site visit confirmed tomorrow 10 AM', time: dayjs() },
  { icon: '🔔', text: 'Reminder: ENQ-455 GMR Airports follow-up due today', time: dayjs() },
];

// Animated live KPI card
function LiveKpiCard({ label, value, icon, color }) {
  const animVal = useRef(new Animated.Value(value)).current;
  const [displayed, setDisplayed] = useState(value);
  const prevRef = useRef(value);

  useEffect(() => {
    const from = prevRef.current;
    const to   = value;
    if (from === to) return;
    const duration = 700;
    const start = Date.now();
    const frame = () => {
      const elapsed = Date.now() - start;
      const pct = Math.min(elapsed / duration, 1);
      const eased = 1 - Math.pow(1 - pct, 3);
      setDisplayed(Math.round(from + (to - from) * eased));
      if (pct < 1) requestAnimationFrame(frame);
      else { setDisplayed(to); prevRef.current = to; }
    };
    requestAnimationFrame(frame);
  }, [value]);

  const bg = {
    primary: { bg: colors.primaryLight, icon: colors.primary  },
    danger:  { bg: colors.dangerLight,  icon: colors.danger   },
    warning: { bg: colors.warningLight, icon: colors.warning  },
    success: { bg: colors.successLight, icon: colors.success  },
  }[color];

  return (
    <Card style={styles.kpiCard}>
      <View style={[styles.kpiIcon, { backgroundColor: bg.bg }]}>
        <Ionicons name={icon} size={20} color={bg.icon} />
      </View>
      <Text style={[styles.kpiValue, { color: bg.icon }]}>{displayed}</Text>
      <Text style={styles.kpiLabel}>{label}</Text>
    </Card>
  );
}

function TaskRow({ task, onDone }) {
  const isOverdue = dayjs(task.due).isBefore(dayjs(), 'day');
  return (
    <TouchableOpacity style={styles.taskRow} activeOpacity={0.7}>
      <TouchableOpacity onPress={() => onDone(task.id)} style={styles.taskCheck}>
        <Ionicons
          name={task.done ? 'checkmark-circle' : 'ellipse-outline'}
          size={22}
          color={task.done ? colors.success : colors.gray300}
        />
      </TouchableOpacity>
      <View style={styles.taskContent}>
        <Text style={[styles.taskTitle, task.done && styles.taskDone]} numberOfLines={1}>
          {task.title}
        </Text>
        <View style={styles.taskMeta}>
          <Ionicons name={TYPE_ICON[task.type] || 'ellipse-outline'} size={11} color={colors.gray400} />
          <Text style={styles.taskProject} numberOfLines={1}>{task.project}</Text>
          <Text style={[styles.taskDue, isOverdue && styles.overdue]}>
            {isOverdue ? 'Overdue' : dayjs(task.due).isSame(dayjs(), 'day') ? 'Today' : dayjs(task.due).format('DD MMM')}
          </Text>
        </View>
      </View>
      <Badge label={task.priority} color={PRIORITY_COLOR[task.priority]} size="xs" />
    </TouchableOpacity>
  );
}

export default function HomeScreen({ navigation }) {
  const insets = useSafeAreaInsets();
  const { user } = useAuth();

  // Live data
  const liveKpis     = useLiveKpis({ tasks: 12, breaches: 3, approvals: 5, enquiries: 8 });
  const liveProjects  = useLiveProjects(PROJECTS);
  const liveFeed      = useLiveFeed(ACTIVITY_FEED, FEED_POOL);

  const [tasks, setTasks]       = useState(MY_TASKS);
  const [refreshing, setRefreshing] = useState(false);
  const [now, setNow]           = useState(dayjs());
  const pulseDot                = useRef(new Animated.Value(1)).current;

  // Clock tick
  useEffect(() => {
    const id = setInterval(() => setNow(dayjs()), 60000);
    return () => clearInterval(id);
  }, []);

  // Live dot pulse
  useEffect(() => {
    Animated.loop(
      Animated.sequence([
        Animated.timing(pulseDot, { toValue: 0.3, duration: 800, useNativeDriver: true }),
        Animated.timing(pulseDot, { toValue: 1,   duration: 800, useNativeDriver: true }),
      ])
    ).start();
  }, []);

  const hour     = now.hour();
  const greeting = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';
  const firstName = (user?.name || ME.name).split(' ')[0];

  const toggleDone   = (id) => setTasks(prev => prev.map(t => t.id === id ? { ...t, done: !t.done } : t));
  const onRefresh    = () => { setRefreshing(true); setTimeout(() => setRefreshing(false), 1200); };
  const pendingTasks = tasks.filter(t => !t.done);
  const overdueTasks = pendingTasks.filter(t => dayjs(t.due).isBefore(dayjs(), 'day'));

  // Live KPI cards built from live hook data
  const kpiCards = [
    { id: 'tasks',     label: 'Tasks Today',   value: liveKpis.tasks,     icon: 'checkbox-outline',          color: 'primary' },
    { id: 'breaches',  label: 'SLA Breaches',  value: liveKpis.breaches,  icon: 'warning-outline',           color: 'danger'  },
    { id: 'approvals', label: 'Approvals Due', value: liveKpis.approvals, icon: 'checkmark-circle-outline',  color: 'warning' },
    { id: 'enquiries', label: 'Open Enquiries',value: liveKpis.enquiries, icon: 'mail-outline',              color: 'success' },
  ];

  return (
    <View style={styles.container}>
      {/* Header */}
      <View style={[styles.header, { paddingTop: insets.top + 12 }]}>
        <View style={{ flex: 1 }}>
          <Text style={styles.greeting}>{greeting}, {firstName} 👋</Text>
          <Text style={styles.headerSub}>{now.format('ddd, DD MMM YYYY')}</Text>
        </View>
        <NotificationBell
          onPress={() => navigation.navigate('Notifications')}
          color={colors.white}
        />
        <TouchableOpacity style={styles.avatarBtn} onPress={() => navigation.navigate('Profile')}>
          <View style={styles.avatar}>
            <Text style={styles.avatarText}>{user?.avatar || ME.avatar}</Text>
          </View>
          <View style={styles.avatarDot} />
        </TouchableOpacity>
      </View>

      <ScrollView
        showsVerticalScrollIndicator={false}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} tintColor={colors.primary} />}
        contentContainerStyle={{ paddingBottom: 100 }}
      >
        {/* Alert banner */}
        {overdueTasks.length > 0 && (
          <TouchableOpacity style={styles.alertBanner} onPress={() => navigation.navigate('Follow-ups')}>
            <Ionicons name="warning" size={16} color={colors.danger} />
            <Text style={styles.alertText}>
              {overdueTasks.length} overdue task{overdueTasks.length > 1 ? 's' : ''} — tap to view
            </Text>
            <Ionicons name="chevron-forward" size={14} color={colors.danger} />
          </TouchableOpacity>
        )}

        {/* SLA breach banner */}
        {liveKpis.breaches > 2 && (
          <View style={styles.slaBanner}>
            <View style={styles.slaDot} />
            <Text style={styles.slaText}>
              {liveKpis.breaches} active SLA breaches · {liveKpis.approvals} approvals pending
            </Text>
          </View>
        )}

        {/* Live KPI cards */}
        <ScrollView horizontal showsHorizontalScrollIndicator={false}
          style={styles.kpiScroll} contentContainerStyle={styles.kpiContent}>
          {kpiCards.map(k => <LiveKpiCard key={k.id} {...k} />)}
        </ScrollView>

        {/* My tasks */}
        <View style={styles.section}>
          <View style={styles.sectionHeader}>
            <Text style={styles.sectionTitle}>My Tasks Today</Text>
            <TouchableOpacity onPress={() => navigation.navigate('Follow-ups')}>
              <Text style={styles.seeAll}>See all ({pendingTasks.length})</Text>
            </TouchableOpacity>
          </View>
          <Card variant="flat">
            {pendingTasks.slice(0, 4).map((task, i) => (
              <View key={task.id}>
                <TaskRow task={task} onDone={toggleDone} />
                {i < Math.min(pendingTasks.length, 4) - 1 && <View style={styles.divider} />}
              </View>
            ))}
          </Card>
        </View>

        {/* Project pulse — live */}
        <View style={styles.section}>
          <View style={styles.sectionHeader}>
            <Text style={styles.sectionTitle}>Project Pulse</Text>
            <Text style={styles.seeAll}>{liveProjects.length} active</Text>
          </View>
          {liveProjects.slice(0, 5).map(p => (
            <Card key={p.id} style={styles.projectCard} variant="flat">
              <View style={styles.projectRow}>
                <View style={{ flex: 1 }}>
                  <Text style={styles.projectName} numberOfLines={1}>{p.name}</Text>
                  <Text style={styles.projectPhase}>{p.phase} · {p.value}</Text>
                </View>
                <Badge label={p.status.replace('-', ' ')} color={STATUS_COLOR[p.status]} size="xs" dot />
              </View>
              <View style={styles.progressTrack}>
                <View style={[styles.progressBar, {
                  width: `${p.pct}%`,
                  backgroundColor: p.status === 'delayed' ? colors.danger : p.status === 'at-risk' ? colors.warning : colors.success,
                }]} />
              </View>
              <Text style={styles.progressLabel}>{p.pct}% complete · {p.client}</Text>
            </Card>
          ))}
        </View>

        {/* Live activity feed */}
        <View style={styles.section}>
          <View style={styles.sectionHeader}>
            <View style={styles.liveRow}>
              <Animated.View style={[styles.liveDot, { opacity: pulseDot }]} />
              <Text style={styles.sectionTitle}>Live Activity</Text>
            </View>
            <Text style={styles.liveLabel}>updating live</Text>
          </View>
          <Card variant="flat">
            {liveFeed.slice(0, 7).map((item, i) => (
              <View key={item.id || i}>
                <View style={[styles.feedRow, item.isNew && styles.feedRowNew]}>
                  <Text style={styles.feedIcon}>{item.icon}</Text>
                  <View style={{ flex: 1 }}>
                    <Text style={styles.feedText}>{item.text}</Text>
                    <Text style={styles.feedTime}>{dayjs(item.time).fromNow()}</Text>
                  </View>
                  {item.isNew && (
                    <View style={styles.newPill}>
                      <Text style={styles.newPillText}>NEW</Text>
                    </View>
                  )}
                </View>
                {i < Math.min(liveFeed.length, 7) - 1 && <View style={styles.divider} />}
              </View>
            ))}
          </Card>
        </View>
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container:     { flex: 1, backgroundColor: colors.gray50 },
  header:        { backgroundColor: colors.primaryDark, paddingHorizontal: spacing.lg, paddingBottom: spacing.xl, flexDirection: 'row', alignItems: 'center', gap: 8 },
  greeting:      { color: colors.white, fontSize: fontSize.xl, fontWeight: '700' },
  headerSub:     { color: 'rgba(255,255,255,0.6)', fontSize: fontSize.sm, marginTop: 2 },
  avatarBtn:     { position: 'relative' },
  avatar:        { width: 40, height: 40, borderRadius: 20, backgroundColor: colors.primary, alignItems: 'center', justifyContent: 'center' },
  avatarText:    { color: colors.white, fontWeight: '700', fontSize: fontSize.md },
  avatarDot:     { width: 10, height: 10, borderRadius: 5, backgroundColor: colors.success, borderWidth: 2, borderColor: colors.primaryDark, position: 'absolute', bottom: 0, right: 0 },

  alertBanner:   { flexDirection: 'row', alignItems: 'center', gap: 6, backgroundColor: colors.dangerLight, marginHorizontal: spacing.lg, marginTop: spacing.lg, borderRadius: radius.md, paddingHorizontal: 12, paddingVertical: 10, borderWidth: 1, borderColor: '#FCA5A5' },
  alertText:     { flex: 1, color: colors.danger, fontSize: fontSize.sm, fontWeight: '600' },
  slaBanner:     { flexDirection: 'row', alignItems: 'center', gap: 8, backgroundColor: '#FEF9EC', marginHorizontal: spacing.lg, marginTop: 8, borderRadius: radius.md, paddingHorizontal: 12, paddingVertical: 9, borderWidth: 1, borderColor: '#FDE68A' },
  slaDot:        { width: 7, height: 7, borderRadius: 4, backgroundColor: colors.warning },
  slaText:       { fontSize: fontSize.xs, color: '#92400E', fontWeight: '600' },

  kpiScroll:     { marginTop: spacing.lg },
  kpiContent:    { paddingHorizontal: spacing.lg, gap: 10 },
  kpiCard:       { width: 130, alignItems: 'flex-start', padding: 12 },
  kpiIcon:       { width: 36, height: 36, borderRadius: radius.md, alignItems: 'center', justifyContent: 'center', marginBottom: 8 },
  kpiValue:      { fontSize: fontSize.xxl, fontWeight: '800', lineHeight: 28 },
  kpiLabel:      { fontSize: fontSize.xs, color: colors.gray500, marginTop: 2, lineHeight: 14 },

  section:       { paddingHorizontal: spacing.lg, marginTop: spacing.xl },
  sectionHeader: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 10 },
  sectionTitle:  { fontSize: fontSize.md, fontWeight: '700', color: colors.gray800 },
  seeAll:        { fontSize: fontSize.sm, color: colors.primary, fontWeight: '600' },
  liveRow:       { flexDirection: 'row', alignItems: 'center', gap: 7 },
  liveDot:       { width: 8, height: 8, borderRadius: 4, backgroundColor: colors.success },
  liveLabel:     { fontSize: 10, color: colors.success, fontWeight: '600' },

  taskRow:       { flexDirection: 'row', alignItems: 'center', gap: 10, paddingVertical: 10 },
  taskCheck:     { width: 26 },
  taskContent:   { flex: 1 },
  taskTitle:     { fontSize: fontSize.sm, fontWeight: '600', color: colors.gray800 },
  taskDone:      { textDecorationLine: 'line-through', color: colors.gray400 },
  taskMeta:      { flexDirection: 'row', alignItems: 'center', gap: 4, marginTop: 3 },
  taskProject:   { fontSize: 10, color: colors.gray500, flex: 1 },
  taskDue:       { fontSize: 10, color: colors.gray500 },
  overdue:       { color: colors.danger, fontWeight: '700' },
  divider:       { height: 1, backgroundColor: colors.gray100, marginLeft: 36 },

  projectCard:   { marginBottom: 8 },
  projectRow:    { flexDirection: 'row', alignItems: 'flex-start', gap: 8, marginBottom: 8 },
  projectName:   { fontSize: fontSize.sm, fontWeight: '700', color: colors.gray800 },
  projectPhase:  { fontSize: fontSize.xs, color: colors.gray500, marginTop: 2 },
  progressTrack: { height: 5, backgroundColor: colors.gray100, borderRadius: 99, overflow: 'hidden' },
  progressBar:   { height: '100%', borderRadius: 99 },
  progressLabel: { fontSize: 10, color: colors.gray500, marginTop: 4 },

  feedRow:       { flexDirection: 'row', alignItems: 'flex-start', gap: 10, paddingVertical: 10 },
  feedRowNew:    { backgroundColor: '#EFF6FF', marginHorizontal: -16, paddingHorizontal: 16 },
  feedIcon:      { fontSize: 16, marginTop: 1 },
  feedText:      { fontSize: fontSize.sm, color: colors.gray700, lineHeight: 18 },
  feedTime:      { fontSize: 10, color: colors.gray400, marginTop: 3 },
  newPill:       { backgroundColor: colors.primary, borderRadius: 6, paddingHorizontal: 6, paddingVertical: 2, alignSelf: 'flex-start' },
  newPillText:   { color: colors.white, fontSize: 8, fontWeight: '800', letterSpacing: 0.5 },
});
