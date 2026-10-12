const fs = require('fs');
const path = require('path');
const { config, getConnection } = require('./db_config');

const SEED_FILE = path.join(__dirname, '..', 'seed.sql');

async function seed() {
  console.log('========================================================');
  console.log(`🌱 Seeding Initial Data -> ${config.database}`);
  console.log('========================================================');

  if (!fs.existsSync(SEED_FILE)) {
    console.error(`❌ Seed file not found at: ${SEED_FILE}`);
    process.exit(1);
  }

  const conn = await getConnection();
  const seedSql = fs.readFileSync(SEED_FILE, 'utf8');

  console.log('Inserting seed records for Users, Projects, Tasks, Approvals, Follow-ups...');
  const startTime = Date.now();

  try {
    await conn.query(seedSql);
    const duration = Date.now() - startTime;
    console.log(`✅ Seed data applied successfully (${duration}ms)!`);

    // Verify counts
    const tables = ['users', 'projects', 'tasks', 'follow_ups', 'approvals', 'enquiries', 'reminders', 'activity_logs'];
    console.log('--------------------------------------------------------');
    console.log('📊 Current Record Summary:');
    for (const t of tables) {
      try {
        const [rows] = await conn.query(`SELECT COUNT(*) AS total FROM \`${t}\``);
        console.log(`  - ${t.padEnd(16)}: ${rows[0].total} records`);
      } catch (_) {}
    }
    console.log('========================================================');
  } catch (err) {
    console.error('❌ Failed to seed data:', err.message);
  } finally {
    await conn.end();
  }
}

seed();
