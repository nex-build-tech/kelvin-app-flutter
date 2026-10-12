const readline = require('readline');
const { execSync } = require('child_process');
const path = require('path');

function clearScreen() {
  process.stdout.write('\x1Bc');
}

function promptMenu() {
  console.log('================================================================');
  console.log('       ❄️  KELVIN MECH — DATABASE OPERATIONS CONSOLE  ❄️        ');
  console.log('================================================================');
  console.log('  [1]  🔍 Health Check & Diagnostics       (Table stats, sizes, ping)');
  console.log('  [2]  🚀 Run Migrations (Forward)         (Apply all pending DDLs)');
  console.log('  [3]  ⏪ Rollback Last Migration          (Undo most recent DDL)');
  console.log('  [4]  📋 Migration Status                 (View applied vs pending)');
  console.log('  [5]  ✨ Create New Migration             (Generate next DDL template)');
  console.log('  [6]  🌱 Seed Demo Data                   (Insert realistic MEP records)');
  console.log('  [7]  💾 Create SQL Backup                (Safe backup to backups/)');
  console.log('  [8]  ♻️ Restore Database                 (Restore from backup file)');
  console.log('  [9]  🛠️ Optimize & Defrag Tables         (ANALYZE & OPTIMIZE tables)');
  console.log('  [10] 🔎 Verify Data Integrity            (Check foreign keys & orphans)');
  console.log('  [11] 📤 Export to JSON Fixtures          (Export tables as .json files)');
  console.log('  [12] 📥 Import from JSON Fixtures        (Load .json fixtures into DB)');
  console.log('  [13] 🔒 Export Sanitized/Anonymized Dump (GDPR/PII masked export)');
  console.log('  [14] ⚠️ Full Database Reset              (Drop DB + Migrate + Seed)');
  console.log('  [0]  🚪 Exit Console');
  console.log('================================================================');
}

function runScript(scriptName, args = '') {
  const scriptPath = path.join(__dirname, scriptName);
  try {
    console.log('\n----------------------------------------------------------------');
    execSync(`node "${scriptPath}" ${args}`, { stdio: 'inherit' });
    console.log('----------------------------------------------------------------\n');
  } catch (err) {
    console.error(`\n❌ Error executing ${scriptName}`);
  }
}

function start() {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });

  function ask() {
    promptMenu();
    rl.question('👉 Select an option [0-14]: ', (choice) => {
      const trimmed = choice.trim();

      switch (trimmed) {
        case '1':
          runScript('check_db.js');
          break;
        case '2':
          runScript('migrate.js', 'up');
          break;
        case '3':
          runScript('migrate.js', 'down');
          break;
        case '4':
          runScript('migrate.js', 'status');
          break;
        case '5':
          rl.question('\nEnter migration name (e.g. add_equipment_vendor): ', (name) => {
            if (name.trim()) {
              runScript('create_migration.js', name.trim());
            }
            ask();
          });
          return;
        case '6':
          runScript('seed.js');
          break;
        case '7':
          runScript('backup.js');
          break;
        case '8':
          rl.question('\nEnter backup file path (press Enter for latest): ', (target) => {
            runScript('restore.js', target.trim());
            ask();
          });
          return;
        case '9':
          runScript('optimize.js');
          break;
        case '10':
          runScript('verify_integrity.js');
          break;
        case '11':
          runScript('export_fixtures.js');
          break;
        case '12':
          runScript('import_fixtures.js');
          break;
        case '13':
          runScript('anonymize.js');
          break;
        case '14':
          rl.question('\n⚠️ ARE YOU SURE? This will wipe and rebuild the database! (y/N): ', (ans) => {
            if (ans.trim().toLowerCase() === 'y') {
              runScript('reset.js');
            } else {
              console.log('Reset cancelled.');
            }
            ask();
          });
          return;
        case '0':
          console.log('\n👋 Exiting Kelvin Mech Database Console. Have a great day!\n');
          rl.close();
          return;
        default:
          console.log('\n⚠️ Invalid option. Please enter a number between 0 and 14.\n');
          break;
      }

      rl.question('Press Enter to return to menu...', () => {
        clearScreen();
        ask();
      });
    });
  }

  ask();
}

start();
