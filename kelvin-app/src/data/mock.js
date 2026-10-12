import dayjs from 'dayjs';
import relativeTime from 'dayjs/plugin/relativeTime';
dayjs.extend(relativeTime);

export const ME = {
  name: 'Suresh Iyer',
  role: 'Procurement Manager',
  avatar: 'SI',
  email: 'suresh@kelvinmech.com',
};

export const KPI_CARDS = [
  { id: 1, label: 'My Open Tasks',      value: 12,  color: 'primary', icon: 'checkmark-circle-outline' },
  { id: 2, label: 'SLA Breaches',       value: 3,   color: 'danger',  icon: 'warning-outline'          },
  { id: 3, label: 'Pending Approvals',  value: 4,   color: 'warning', icon: 'time-outline'             },
  { id: 4, label: 'Enquiries Today',    value: 7,   color: 'success', icon: 'mail-outline'             },
];

export const MY_TASKS = [
  { id: 1,  title: 'Follow up — Voltas AHU delivery',       project: 'Metro Station MEP', due: dayjs().subtract(1, 'day'),   priority: 'high',   done: false, type: 'followup'  },
  { id: 2,  title: 'Approve PO-2024-090 — Daikin India',    project: 'Metro Station MEP', due: dayjs(),                      priority: 'high',   done: false, type: 'approval'  },
  { id: 3,  title: 'Send BOQ revision to ABC Builders',      project: 'ABC Tower MEP',     due: dayjs(),                      priority: 'medium', done: false, type: 'task'      },
  { id: 4,  title: 'Site visit — Sunrise Mall Block A',      project: 'Sunrise Mall MEP',  due: dayjs().add(1, 'day'),        priority: 'medium', done: false, type: 'visit'     },
  { id: 5,  title: 'PO-2024-096 — Grundfos Pumps review',   project: 'City Hospital',      due: dayjs().add(1, 'day'),        priority: 'low',    done: false, type: 'approval'  },
  { id: 6,  title: 'Confirm ETA — Bharat Steel delivery',   project: 'City Hospital',      due: dayjs().add(2, 'day'),        priority: 'medium', done: false, type: 'followup'  },
  { id: 7,  title: 'Update progress — Airport T3 (62%)',     project: 'Airport Terminal T3',due: dayjs().add(2, 'day'),        priority: 'low',    done: false, type: 'update'    },
];

export const FOLLOWUPS = [
  { id: 1,  contact: 'Rajesh Mehta',   company: 'Voltas Ltd',      topic: 'AHU Unit delivery ETA confirmation',    phone: '+91 98765 43210', project: 'Metro Station MEP', due: dayjs().subtract(1, 'day'), status: 'overdue',   channel: 'whatsapp' },
  { id: 2,  contact: 'Anita Sharma',   company: 'Daikin India',    topic: 'PO-2024-090 acceptance + payment terms', phone: '+91 87654 32109', project: 'Metro Station MEP', due: dayjs(),                   status: 'due-today', channel: 'call'     },
  { id: 3,  contact: 'Sunil Verma',    company: 'Bharat Steel',    topic: 'MS Pipes 50m — revised ETA',             phone: '+91 76543 21098', project: 'City Hospital',      due: dayjs(),                   status: 'due-today', channel: 'email'    },
  { id: 4,  contact: 'Priya Kapoor',   company: 'Carrier HVAC',    topic: 'AHU Chiller specs confirmation',         phone: '+91 65432 10987', project: 'ABC Tower MEP',      due: dayjs().add(1, 'day'),     status: 'upcoming',  channel: 'whatsapp' },
  { id: 5,  contact: 'Mohan Das',      company: 'Finolex Cables',  topic: 'Cable delivery to Airport T3 site',     phone: '+91 54321 09876', project: 'Airport Terminal T3', due: dayjs().add(2, 'day'),     status: 'upcoming',  channel: 'call'     },
  { id: 6,  contact: 'Kavitha Nair',   company: 'Armacell India',  topic: 'Insulation rolls dispatch confirmation', phone: '+91 43210 98765', project: 'ABC Tower MEP',      due: dayjs().add(3, 'day'),     status: 'upcoming',  channel: 'email'    },
];

export const APPROVALS = [
  { id: 1,  po: 'PO-2024-090', vendor: 'Daikin India Ltd',    item: 'VRF Units ×8 — Metro Station',   amount: '₹29.1L', days: 5, urgency: 'high',   status: 'pending', requestedBy: 'Priya S'  },
  { id: 2,  po: 'PO-2024-092', vendor: 'Carrier HVAC India',  item: 'AHU Chillers ×2 — ABC Tower',    amount: '₹45.0L', days: 3, urgency: 'medium', status: 'pending', requestedBy: 'Kavya N'  },
  { id: 3,  po: 'PO-2024-094', vendor: 'ABB India Pvt Ltd',   item: 'LT Panel Set — Airport T3',      amount: '₹9.6L',  days: 2, urgency: 'medium', status: 'pending', requestedBy: 'Priya S'  },
  { id: 4,  po: 'PO-2024-096', vendor: 'Grundfos Pumps',      item: 'Pump Set ×6 — City Hospital',    amount: '₹12.0L', days: 1, urgency: 'low',    status: 'pending', requestedBy: 'Suresh I' },
];

export const REMINDERS = [
  { id: 1,  title: 'Call Voltas — AHU delivery update',    time: dayjs().hour(10).minute(0),  type: 'call',    priority: 'high',   repeat: 'none',   done: false },
  { id: 2,  title: 'Send weekly SLA report to Director',   time: dayjs().hour(11).minute(30), type: 'report',  priority: 'medium', repeat: 'weekly', done: false },
  { id: 3,  title: 'PO approval deadline — Daikin India',  time: dayjs().hour(14).minute(0),  type: 'approval',priority: 'high',   repeat: 'none',   done: false },
  { id: 4,  title: 'Site visit — Sunrise Mall Block A',    time: dayjs().add(1,'day').hour(9).minute(0), type: 'visit', priority: 'medium', repeat: 'none', done: false },
  { id: 5,  title: 'Review Metro Station progress %',      time: dayjs().add(1,'day').hour(16).minute(0),type: 'task', priority: 'low',  repeat: 'none', done: false },
  { id: 6,  title: 'Monthly vendor rating update',         time: dayjs().add(2,'day').hour(10).minute(0),type: 'task', priority: 'low',  repeat: 'monthly',done: false},
];

export const ENQUIRIES = [
  { id: 1,  ref: 'ENQ-461', client: 'Greenfield Developers', scope: 'Residential Tower MEP — Bengaluru', value: '~₹3.2 Cr', source: 'whatsapp', received: dayjs().subtract(2,'hour'),  status: 'new',        priority: 'high'   },
  { id: 2,  ref: 'ENQ-460', client: 'DLF Infra Ltd',         scope: 'Commercial Complex HVAC — Pune',    value: '~₹1.8 Cr', source: 'email',    received: dayjs().subtract(4,'hour'),  status: 'contacted',  priority: 'medium' },
  { id: 3,  ref: 'ENQ-458', client: 'Prestige Group',        scope: 'Hotel MEP — Chennai',               value: '~₹5.1 Cr', source: 'referral', received: dayjs().subtract(1,'day'),   status: 'site-visit', priority: 'high'   },
  { id: 4,  ref: 'ENQ-455', client: 'GMR Airports',          scope: 'Airport Lounge Expansion MEP',      value: '~₹2.4 Cr', source: 'direct',   received: dayjs().subtract(2,'day'),   status: 'quoted',     priority: 'medium' },
];

export const PROJECTS = [
  { id: 1, name: 'Airport Terminal T3',   pct: 62, status: 'on-track', phase: 'Execution',     value: '₹4.2 Cr', client: 'GMR Airports'        },
  { id: 2, name: 'ABC Tower MEP',         pct: 88, status: 'on-track', phase: 'Commissioning', value: '₹2.8 Cr', client: 'ABC Infra Ltd'        },
  { id: 3, name: 'City Hospital Block-C', pct: 45, status: 'delayed',  phase: 'Execution',     value: '₹1.9 Cr', client: 'City Corp Hospitals'  },
  { id: 4, name: 'Metro Station MEP',     pct: 71, status: 'at-risk',  phase: 'Execution',     value: '₹3.1 Cr', client: 'Metro Rail Authority' },
  { id: 5, name: 'Luxe Residences',       pct: 95, status: 'on-track', phase: 'Handover',      value: '₹0.9 Cr', client: 'Prestige Group'       },
];

export const ACTIVITY_FEED = [
  { id: 1,  icon: '✅', text: 'PO-2024-089 approved — ₹18.5L Daikin',           time: dayjs().subtract(8,'minute'),  color: 'success' },
  { id: 2,  icon: '🚨', text: 'SLA BREACH — Copper Pipes 5 days overdue',        time: dayjs().subtract(22,'minute'), color: 'danger'  },
  { id: 3,  icon: '📥', text: 'New enquiry — Greenfield Developers (WhatsApp)',  time: dayjs().subtract(2,'hour'),    color: 'primary' },
  { id: 4,  icon: '⚠️', text: 'City Hospital timeline revised — 2 week delay',  time: dayjs().subtract(3,'hour'),    color: 'warning' },
  { id: 5,  icon: '✅', text: 'Luxe Residences 95% — handover checklist started',time: dayjs().subtract(5,'hour'),    color: 'success' },
];
