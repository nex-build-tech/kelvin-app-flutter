const { config, getConnectionWithoutDb } = require('./db_config');
const { execSync } = require('child_process');
const path = require('path');

async function reset() {
  console.log('========================================================');
  console.log(`⚠️ RESETTING DATABASE: ${config.database}`);
  console.log('========================================================');

  const serverConn = await getConnectionWithoutDb();

  try {
    console.log(`Dropping database \`${config.database}\` if exists...`);
    await serverConn.query(`DROP DATABASE IF EXISTS \`${config.database}\``);

    console.log(`Creating fresh database \`${config.database}\`...`);
    await serverConn.query(
      `CREATE DATABASE \`${config.database}\` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci`
    );
    await serverConn.end();

    console.log('\nRunning all database migrations...');
    const migrateScript = path.join(__dirname, 'migrate.js');
    execSync(`node "${migrateScript}" up`, { stdio: 'inherit' });

    console.log('\nSeeding initial data...');
    const seedScript = path.join(__dirname, 'seed.js');
    execSync(`node "${seedScript}"`, { stdio: 'inherit' });

    console.log('\n========================================================');
    console.log(`🎉 Database ${config.database} reset & seeded completely!`);
    console.log('========================================================');
  } catch (err) {
    console.error('❌ Database reset failed:', err.message);
  }
}

reset();
