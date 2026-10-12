const express = require('express');
const cors = require('cors');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '.env') });
const { pool, testConnection } = require('./config/db');

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());

// Request logger
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.originalUrl}`);
  next();
});

// --------------------------------------------------------------------------
// 1. Health & Status
// --------------------------------------------------------------------------
app.get('/api/health', async (req, res) => {
  try {
    const [result] = await pool.query('SELECT 1 + 1 AS solution');
    res.json({
      status: 'online',
      platform: 'Kelvin Mech Operations API',
      database: 'connected (MySQL)',
      timestamp: new Date(),
    });
  } catch (err) {
    res.status(503).json({
      status: 'degraded',
      database: 'disconnected',
      error: err.message,
    });
  }
});

// --------------------------------------------------------------------------
// 2. Authentication Routes
// --------------------------------------------------------------------------
app.post('/api/auth/login', async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password required' });
  }

  try {
    const [rows] = await pool.query(
      'SELECT id, name, email, role, phone, department FROM users WHERE LOWER(email) = LOWER(?) AND password = ?',
      [email.trim(), password.trim()]
    );

    if (rows.length === 0) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    res.json({
      user: rows[0],
      token: `mock_jwt_${rows[0].id}_${Date.now()}`,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.put('/api/auth/profile', async (req, res) => {
  const { id, name, phone, department } = req.body;
  if (!id) return res.status(400).json({ error: 'User ID is required' });

  try {
    await pool.query(
      'UPDATE users SET name = COALESCE(?, name), phone = COALESCE(?, phone), department = COALESCE(?, department) WHERE id = ?',
      [name, phone, department, id]
    );
    const [rows] = await pool.query('SELECT id, name, email, role, phone, department FROM users WHERE id = ?', [id]);
    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// --------------------------------------------------------------------------
// 3. Projects Routes
// --------------------------------------------------------------------------
app.get('/api/projects', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM projects ORDER BY id ASC');
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/projects', async (req, res) => {
  const { name, completion_pct, status, phase, contract_value, client_name } = req.body;
  try {
    const [result] = await pool.query(
      'INSERT INTO projects (name, completion_pct, status, phase, contract_value, client_name) VALUES (?, ?, ?, ?, ?, ?)',
      [name, completion_pct || 0, status || 'onTrack', phase || 'Execution', contract_value, client_name]
    );
    res.status(201).json({ id: result.insertId, ...req.body });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// --------------------------------------------------------------------------
// 4. Checklist Tasks
// --------------------------------------------------------------------------
app.get('/api/tasks', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM tasks ORDER BY due_date ASC');
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.patch('/api/tasks/:id/toggle', async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query('UPDATE tasks SET is_done = NOT is_done WHERE id = ?', [id]);
    const [rows] = await pool.query('SELECT * FROM tasks WHERE id = ?', [id]);
    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// --------------------------------------------------------------------------
// 5. Follow-ups (CRM)
// --------------------------------------------------------------------------
app.get('/api/followups', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM follow_ups ORDER BY due_date ASC');
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/followups', async (req, res) => {
  const { contact_name, company, topic, phone, project_name, due_date, status, channel } = req.body;
  try {
    const [result] = await pool.query(
      'INSERT INTO follow_ups (contact_name, company, topic, phone, project_name, due_date, status, channel) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      [contact_name, company, topic, phone, project_name, due_date || new Date(), status || 'upcoming', channel || 'call']
    );
    res.status(201).json({ id: result.insertId, ...req.body });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete('/api/followups/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query('DELETE FROM follow_ups WHERE id = ?', [id]);
    res.json({ success: true, id: parseInt(id, 10) });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.patch('/api/followups/:id/snooze', async (req, res) => {
  const { id } = req.params;
  const { hours } = req.body;
  const addHours = parseInt(hours || 24, 10);
  try {
    await pool.query('UPDATE follow_ups SET due_date = DATE_ADD(NOW(), INTERVAL ? HOUR), status = "upcoming" WHERE id = ?', [addHours, id]);
    const [rows] = await pool.query('SELECT * FROM follow_ups WHERE id = ?', [id]);
    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// --------------------------------------------------------------------------
// 6. PO Approvals
// --------------------------------------------------------------------------
app.get('/api/approvals', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM approvals ORDER BY days_pending DESC');
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/approvals/:id/approve', async (req, res) => {
  const { id } = req.params;
  const { note } = req.body;
  try {
    await pool.query('UPDATE approvals SET status = "approved", signoff_note = ? WHERE id = ?', [note || null, id]);
    const [rows] = await pool.query('SELECT * FROM approvals WHERE id = ?', [id]);
    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/approvals/:id/reject', async (req, res) => {
  const { id } = req.params;
  const { note } = req.body;
  try {
    await pool.query('UPDATE approvals SET status = "rejected", signoff_note = ? WHERE id = ?', [note || null, id]);
    const [rows] = await pool.query('SELECT * FROM approvals WHERE id = ?', [id]);
    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// --------------------------------------------------------------------------
// 7. Enquiries
// --------------------------------------------------------------------------
app.get('/api/enquiries', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM enquiries ORDER BY id DESC');
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.patch('/api/enquiries/:id/assign', async (req, res) => {
  const { id } = req.params;
  const { assigned_to } = req.body;
  try {
    await pool.query('UPDATE enquiries SET assigned_to = ? WHERE id = ?', [assigned_to, id]);
    const [rows] = await pool.query('SELECT * FROM enquiries WHERE id = ?', [id]);
    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// --------------------------------------------------------------------------
// 8. Reminders
// --------------------------------------------------------------------------
app.get('/api/reminders', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM reminders ORDER BY scheduled_time ASC');
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/reminders', async (req, res) => {
  const { title, scheduled_time, reminder_type, priority, repeat_frequency } = req.body;
  try {
    const [result] = await pool.query(
      'INSERT INTO reminders (title, scheduled_time, reminder_type, priority, repeat_frequency) VALUES (?, ?, ?, ?, ?)',
      [title, scheduled_time || new Date(), reminder_type || 'task', priority || 'medium', repeat_frequency || 'none']
    );
    res.status(201).json({ id: result.insertId, ...req.body });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.patch('/api/reminders/:id/toggle', async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query('UPDATE reminders SET is_done = NOT is_done WHERE id = ?', [id]);
    const [rows] = await pool.query('SELECT * FROM reminders WHERE id = ?', [id]);
    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// --------------------------------------------------------------------------
// 9. Activity Logs
// --------------------------------------------------------------------------
app.get('/api/activity', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM activity_logs ORDER BY created_at DESC LIMIT 20');
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Start Server
app.listen(PORT, async () => {
  console.log('====================================================');
  console.log(`🚀 Kelvin Mech REST API Server running on port ${PORT}`);
  console.log(`👉 Health check: http://localhost:${PORT}/api/health`);
  console.log('====================================================');
  await testConnection();
});
