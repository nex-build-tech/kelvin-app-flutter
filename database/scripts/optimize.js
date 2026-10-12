const { config, getConnection } = require('./db_config');

async function optimizeDb() {
  console.log('========================================================');
  console.log(`🛠️ Kelvin Mech — MySQL Database Optimization & Defrag`);
  console.log(`🗄️ Database: ${config.database}`);
  console.log('========================================================');

  const startTime = Date.now();
  let conn;

  try {
    conn = await getConnection();
    const [tables] = await conn.query('SHOW FULL TABLES WHERE Table_type = "BASE TABLE"');
    const tableNames = tables.map((t) => Object.values(t)[0]);

    console.log(`Found ${tableNames.length} tables to analyze and optimize...\n`);

    for (const table of tableNames) {
      process.stdout.write(`  Optimizing table \`${table}\`... `);

      // 1. Analyze table (updates key distributions and statistics for query planner)
      await conn.query(`ANALYZE TABLE \`${table}\``);

      // 2. Check table integrity
      const [checkRows] = await conn.query(`CHECK TABLE \`${table}\``);
      const checkStatus = checkRows[checkRows.length - 1]?.Msg_text || 'OK';

      // 3. Optimize table (defragments tablespace and reclaims free pages)
      const [optRows] = await conn.query(`OPTIMIZE TABLE \`${table}\``);
      const optStatus = optRows[optRows.length - 1]?.Msg_text || 'OK';

      console.log(`[Status: ${checkStatus} | ${optStatus}]`);
    }

    const duration = Date.now() - startTime;
    console.log('\n========================================================');
    console.log(`✅ All tables analyzed, checked, and defragmented! (${duration}ms)`);
    console.log(`⚡ MySQL Query Optimizer indexes and table statistics refreshed.`);
    console.log('========================================================');
  } catch (err) {
    console.error('❌ Optimization failed:', err.message);
  } finally {
    if (conn) await conn.end();
  }
}

if (require.main === module) {
  optimizeDb();
}

module.exports = optimizeDb;
