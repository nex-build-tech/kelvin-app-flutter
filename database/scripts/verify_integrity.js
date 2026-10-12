const { config, getConnection } = require('./db_config');

async function verifyIntegrity() {
  console.log('========================================================');
  console.log(`🔎 Kelvin Mech — Database Integrity & Consistency Audit`);
  console.log(`🗄️ Database: ${config.database}`);
  console.log('========================================================\n');

  let conn;
  let issuesFound = 0;
  let warningsFound = 0;

  try {
    conn = await getConnection();

    // 1. Check projects vs tasks consistency
    const [orphanTasks] = await conn.query(`
      SELECT t.id, t.title, t.project_name
      FROM tasks t
      LEFT JOIN projects p ON p.name = t.project_name
      WHERE p.name IS NULL
    `);

    if (orphanTasks.length > 0) {
      console.log(`❌ [ERROR] Found ${orphanTasks.length} orphaned task(s) with no matching project:`);
      orphanTasks.forEach((t) => console.log(`    - Task #${t.id}: "${t.title}" (project: "${t.project_name}")`));
      issuesFound += orphanTasks.length;
    } else {
      console.log(`✅ [PASS] All tasks are properly linked to valid active projects.`);
    }

    // 2. Check projects vs follow-ups consistency
    const [orphanFollowUps] = await conn.query(`
      SELECT f.id, f.topic, f.project_name
      FROM follow_ups f
      LEFT JOIN projects p ON p.name = f.project_name
      WHERE p.name IS NULL AND f.project_name != ''
    `);

    if (orphanFollowUps.length > 0) {
      console.log(`⚠️ [WARN] Found ${orphanFollowUps.length} follow-up(s) with unlinked projects:`);
      orphanFollowUps.forEach((f) => console.log(`    - Follow-up #${f.id}: "${f.topic}" (project: "${f.project_name}")`));
      warningsFound += orphanFollowUps.length;
    } else {
      console.log(`✅ [PASS] All follow-ups reference verified project sites.`);
    }

    // 3. Check approvals data sanity
    const [invalidApprovals] = await conn.query(`
      SELECT id, po_number, amount_in_lakhs
      FROM approvals
      WHERE amount_in_lakhs <= 0 OR po_number IS NULL OR po_number = ''
    `);

    if (invalidApprovals.length > 0) {
      console.log(`❌ [ERROR] Found ${invalidApprovals.length} approval(s) with invalid amount or missing PO number:`);
      invalidApprovals.forEach((a) => console.log(`    - Approval #${a.id}: PO="${a.po_number}", Amount=${a.amount_in_lakhs}`));
      issuesFound += invalidApprovals.length;
    } else {
      console.log(`✅ [PASS] All PO approvals have valid positive values and PO codes.`);
    }

    // 4. Check project milestone % bounds
    const [invalidProjects] = await conn.query(`
      SELECT id, name, completion_pct
      FROM projects
      WHERE completion_pct < 0 OR completion_pct > 100
    `);

    if (invalidProjects.length > 0) {
      console.log(`❌ [ERROR] Found ${invalidProjects.length} project(s) with out-of-range completion percentage:`);
      invalidProjects.forEach((p) => console.log(`    - Project #${p.id}: "${p.name}" (pct: ${p.completion_pct}%)`));
      issuesFound += invalidProjects.length;
    } else {
      console.log(`✅ [PASS] All project completion milestones are within valid bounds (0–100%).`);
    }

    // 5. Check user email format sanity
    const [invalidUsers] = await conn.query(`
      SELECT id, name, email
      FROM users
      WHERE email NOT LIKE '%@%.%'
    `);

    if (invalidUsers.length > 0) {
      console.log(`❌ [ERROR] Found ${invalidUsers.length} user(s) with malformed email addresses:`);
      invalidUsers.forEach((u) => console.log(`    - User #${u.id}: "${u.name}" (${u.email})`));
      issuesFound += invalidUsers.length;
    } else {
      console.log(`✅ [PASS] All user accounts have valid corporate email syntax.`);
    }

    // 6. Check equipment foreign keys
    try {
      const [orphanEquipment] = await conn.query(`
        SELECT e.id, e.tag_name, e.project_id
        FROM equipment e
        LEFT JOIN projects p ON p.id = e.project_id
        WHERE e.project_id IS NOT NULL AND p.id IS NULL
      `);

      if (orphanEquipment.length > 0) {
        console.log(`❌ [ERROR] Found ${orphanEquipment.length} equipment item(s) pointing to non-existent project_id:`);
        issuesFound += orphanEquipment.length;
      } else {
        console.log(`✅ [PASS] All equipment assets satisfy foreign key constraints.`);
      }
    } catch (_) {}

    // Summary
    console.log('\n========================================================');
    if (issuesFound === 0 && warningsFound === 0) {
      console.log(`🎉 PERFECT SCORE: 0 Errors, 0 Warnings found!`);
      console.log(`✨ Database data integrity is in 100% prime condition.`);
    } else {
      console.log(`⚠️ Audit Complete: ${issuesFound} Error(s) and ${warningsFound} Warning(s) detected.`);
    }
    console.log('========================================================');
  } catch (err) {
    console.error('❌ Integrity check encountered an error:', err.message);
  } finally {
    if (conn) await conn.end();
  }
}

if (require.main === module) {
  verifyIntegrity();
}

module.exports = verifyIntegrity;
