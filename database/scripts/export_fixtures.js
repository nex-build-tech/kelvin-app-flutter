const fs = require('fs');
const path = require('path');
const { config, getConnection } = require('./db_config');

const FIXTURES_DIR = path.join(__dirname, '..', 'fixtures');

async function exportFixtures() {
  console.log('========================================================');
  console.log(`📤 Exporting Database Tables to JSON Fixtures`);
  console.log(`📁 Target Directory: database/fixtures/`);
  console.log('========================================================\n');

  if (!fs.existsSync(FIXTURES_DIR)) {
    fs.mkdirSync(FIXTURES_DIR, { recursive: true });
  }

  let conn;

  try {
    conn = await getConnection();
    const [tables] = await conn.query('SHOW FULL TABLES WHERE Table_type = "BASE TABLE"');
    const tableNames = tables.map((t) => Object.values(t)[0]);

    for (const table of tableNames) {
      if (table === 'schema_migrations') continue;

      const [rows] = await conn.query(`SELECT * FROM \`${table}\``);
      const fixtureFile = path.join(FIXTURES_DIR, `${table}.json`);

      fs.writeFileSync(fixtureFile, JSON.stringify(rows, null, 2), 'utf8');
      console.log(`  ✓ Exported ${String(rows.length).padStart(3)} rows -> ${table}.json`);
    }

    console.log('\n========================================================');
    console.log(`🎉 Fixtures exported successfully to database/fixtures/!`);
    console.log('========================================================');
  } catch (err) {
    console.error('❌ Failed to export fixtures:', err.message);
  } finally {
    if (conn) await conn.end();
  }
}

if (require.main === module) {
  exportFixtures();
}

module.exports = exportFixtures;
