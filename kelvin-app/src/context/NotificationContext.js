import React, { createContext, useContext, useState, useEffect, useRef } from 'react';
import dayjs from 'dayjs';

const NotificationContext = createContext(null);

const INITIAL_NOTIFS = [
  { id: 1,  type: 'sla',      title: 'SLA Breach — Critical',        body: 'Copper Pipes ABC Tower overdue by 5 days',           read: false, time: dayjs().subtract(5,  'minute'), icon: 'warning',              color: 'danger'  },
  { id: 2,  type: 'approval', title: 'Approval Requested',           body: 'PO-2024-090 Daikin India ₹29.1L awaiting your sign-off', read: false, time: dayjs().subtract(18, 'minute'), icon: 'checkmark-circle',     color: 'warning' },
  { id: 3,  type: 'enquiry',  title: 'New Enquiry Received',         body: 'Greenfield Developers — Residential Tower MEP Bengaluru', read: false, time: dayjs().subtract(1,  'hour'),   icon: 'mail',                 color: 'primary' },
  { id: 4,  type: 'sla',      title: 'SLA Warning',                  body: 'Voltas AHU PO-090 vendor response overdue 3 days',    read: true,  time: dayjs().subtract(2,  'hour'),   icon: 'alert-circle',         color: 'warning' },
  { id: 5,  type: 'system',   title: 'Weekly SLA Report Ready',      body: 'May week-2 report generated — 94% compliance',       read: true,  time: dayjs().subtract(4,  'hour'),   icon: 'document-text',        color: 'info'    },
  { id: 6,  type: 'approval', title: 'PO Approved by Director',      body: 'PO-2024-088 ABB India ₹18.2L approved by Sachin G',  read: true,  time: dayjs().subtract(6,  'hour'),   icon: 'checkmark-done-circle',color: 'success' },
  { id: 7,  type: 'enquiry',  title: 'Enquiry Follow-up Due',        body: 'ENQ-455 GMR Airports — site visit scheduled tomorrow',read: true,  time: dayjs().subtract(1,  'day'),   icon: 'calendar',             color: 'primary' },
  { id: 8,  type: 'system',   title: 'New Team Member Added',        body: 'Deepa M joined as Accounts Manager',                 read: true,  time: dayjs().subtract(2,  'day'),   icon: 'person-add',           color: 'success' },
];

const LIVE_NOTIFS = [
  { type: 'sla',      title: 'SLA Breach Update',         body: 'Fire Dampers Pharma Plant — now 13h overdue',          icon: 'warning',          color: 'danger'  },
  { type: 'approval', title: 'Approval Needed Urgently',  body: 'PO-2024-096 Grundfos ₹12L — pending 1 day',           icon: 'time',             color: 'warning' },
  { type: 'enquiry',  title: 'WhatsApp Enquiry',          body: 'New message from DLF Infra — HVAC scope query',        icon: 'logo-whatsapp',    color: 'success' },
  { type: 'system',   title: 'Project Milestone Hit',     body: 'Airport Terminal T3 crossed 62% — on track',           icon: 'flag',             color: 'primary' },
  { type: 'sla',      title: 'SLA Resolved',              body: 'ENQ-447 closed — Green Valley converted to project',   icon: 'checkmark-circle', color: 'success' },
  { type: 'approval', title: 'PO Approved',               body: 'PO-2024-089 Daikin ₹18.5L approved by Suresh I',      icon: 'checkmark-done-circle', color: 'success' },
  { type: 'enquiry',  title: 'Site Visit Confirmed',      body: 'Prestige Group — Hotel MEP site visit tomorrow 10 AM', icon: 'location',         color: 'primary' },
];

export function NotificationProvider({ children }) {
  const [notifications, setNotifications] = useState(INITIAL_NOTIFS);
  const poolRef = useRef(0);

  // Simulate live incoming notifications every 20s
  useEffect(() => {
    const id = setInterval(() => {
      const next = LIVE_NOTIFS[poolRef.current % LIVE_NOTIFS.length];
      poolRef.current++;
      const newNotif = { ...next, id: Date.now(), read: false, time: dayjs() };
      setNotifications(prev => [newNotif, ...prev.slice(0, 29)]);
    }, 20000);
    return () => clearInterval(id);
  }, []);

  const markRead    = (id) => setNotifications(prev => prev.map(n => n.id === id ? { ...n, read: true } : n));
  const markAllRead = ()   => setNotifications(prev => prev.map(n => ({ ...n, read: true })));
  const clearAll    = ()   => setNotifications([]);
  const unreadCount = notifications.filter(n => !n.read).length;

  return (
    <NotificationContext.Provider value={{ notifications, unreadCount, markRead, markAllRead, clearAll }}>
      {children}
    </NotificationContext.Provider>
  );
}

export const useNotifications = () => useContext(NotificationContext);
