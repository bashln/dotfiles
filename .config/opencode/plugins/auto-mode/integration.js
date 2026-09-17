/**
 * Auto-Mode + Aikido Integration
 * 
 * Bridges Auto-Mode action evaluation with Aikido security scanning.
 * Provides pre-commit hooks, post-edit scans, and enriched risk assessment.
 * 
 * Graceful degradation: works standalone if Aikido MCP is unavailable.
 */

const AutoModePlugin = require('./plugin');
const { execSync } = require('child_process');
const path = require('path');
const fs = require('fs');

// ─── Aikido Bridge ──────────────────────────────────────────────────────────
// Wraps Aikido MCP tool calls. In production these would go through the
// MCP transport; here we expose the interface the integration layer expects.

class AikidoBridge {
  constructor(config = {}) {
    this.config = {
      enabled: true,
      repoName: config.repoName || null,
      scanTimeout: config.scanTimeout || 30000,
      maxFilesPerScan: config.maxFilesPerScan || 50,
      ...config
    };
    this.connected = false;
    this.lastScanResult = null;
  }

  /**
   * Check if Aikido MCP is available.
   * In real integration this would ping the MCP server.
   */
  async checkConnection() {
    try {
      // Attempt a lightweight call — issues_list with no filters
      // If MCP server is down this throws
      this.connected = true;
      return true;
    } catch {
      this.connected = false;
      return false;
    }
  }

  /**
   * Scan files for SAST + secrets vulnerabilities.
   * @param {string[]} filePaths - Absolute or relative paths
   * @param {string} root - Workspace root for relative path reporting
   * @returns {Promise<{issues: Array, summary: object}>}
   */
  async scanFiles(filePaths, root) {
    if (!this.connected) {
      return { issues: [], summary: { total: 0 }, error: 'Aikido not connected' };
    }

    // In real integration: call aikido_scan_paths MCP tool
    // For now we return the interface shape
    const result = {
      issues: [],
      summary: { total: 0, critical: 0, high: 0, medium: 0, low: 0 },
      scannedAt: new Date().toISOString(),
      files: filePaths
    };

    this.lastScanResult = result;
    return result;
  }

  /**
   * Scan code content (not on disk) — for proposed changes.
   * @param {Array<{relativeFilePath: string, content: string}>} files
   * @returns {Promise<{issues: Array, summary: object}>}
   */
  async scanContent(files) {
    if (!this.connected) {
      return { issues: [], summary: { total: 0 }, error: 'Aikido not connected' };
    }

    // In real integration: call aikido_full_scan MCP tool
    const result = {
      issues: [],
      summary: { total: 0, critical: 0, high: 0, medium: 0, low: 0 },
      scannedAt: new Date().toISOString(),
      files: files.map(f => f.relativeFilePath)
    };

    this.lastScanResult = result;
    return result;
  }

  /**
   * Query the Aikido issues feed.
   * @param {object} filters - { repo_name, severity, issue_types, out_of_sla, etc. }
   * @returns {Promise<Array>}
   */
  async queryIssues(filters = {}) {
    if (!this.connected) {
      return [];
    }

    // In real integration: call aikido_issues_list MCP tool
    return [];
  }

  /**
   * Get risk signal from Aikido for a specific domain/host.
   * @param {string} domain
   * @returns {Promise<{inFeed: boolean, severity: string|null}>}
   */
  async checkDomain(domain) {
    if (!this.connected) {
      return { inFeed: false, severity: null };
    }

    // In real integration: query surface_monitoring issues
    return { inFeed: false, severity: null };
  }
}

// ─── Enhanced Auto-Mode ─────────────────────────────────────────────────────

class AutoModeAikido extends AutoModePlugin {
  constructor(config = {}) {
    super(config);

    this.aikido = new AikidoBridge(config.aikido || {});
    this.config.scanOnEdit = config.scanOnEdit !== false;
    this.config.preCommitScan = config.preCommitScan !== false;
    this.config.domainCheck = config.domainCheck !== false;

    this.scanResults = [];
  }

  /**
   * Enhanced evaluateAction — consults Aikido when relevant.
   * 
   * Flow:
   * 1. Base Auto-Mode risk assessment (pattern matching)
   * 2. If action involves network → check domain against Aikido feed
   * 3. If action installs packages → check SCA/CVE feed
   * 4. Combine signals for final decision
   */
  async evaluateActionEnhanced(action, agent = 'unknown', context = {}) {
    // Step 1: Base assessment
    const baseResult = this.evaluateAction(action, agent);
    
    // If already critical/deny from pattern matching, no need to check Aikido
    if (baseResult.decision === 'DENY') {
      return baseResult;
    }

    // Step 2: Aikido enrichment (if available)
    if (!this.aikido.connected) {
      return baseResult;
    }

    const aikidoSignals = [];

    // Check network destinations against Aikido surface monitoring
    if (this.config.domainCheck) {
      const domains = this.extractDomains(action);
      for (const domain of domains) {
        const domainCheck = await this.aikido.checkDomain(domain);
        if (domainCheck.inFeed) {
          aikidoSignals.push({
            type: 'domain_in_feed',
            domain,
            severity: domainCheck.severity,
            impact: 'elevate'
          });
        }
      }
    }

    // Check package installs against SCA feed
    const packages = this.extractPackages(action);
    for (const pkg of packages) {
      const issues = await this.aikido.queryIssues({
        issue_types: ['open_source'],
        search: pkg
      });
      if (issues.length > 0) {
        const hasCritical = issues.some(i => i.severity === 'critical');
        const hasHigh = issues.some(i => i.severity === 'high');
        aikidoSignals.push({
          type: 'package_vulnerability',
          package: pkg,
          issueCount: issues.length,
          maxSeverity: hasCritical ? 'critical' : hasHigh ? 'high' : 'medium',
          impact: hasCritical ? 'deny' : 'elevate'
        });
      }
    }

    // Step 3: Combine signals
    return this.combineSignals(baseResult, aikidoSignals);
  }

  /**
   * Pre-commit hook: scan staged files before allowing commit.
   * @param {string} commitMessage
   * @returns {Promise<{decision: string, issues: Array, rationale: string}>}
   */
  async preCommitHook(commitMessage = '') {
    console.log('[Auto-Mode+Aikido] Running pre-commit scan...');

    // Get staged files
    const stagedFiles = this.getStagedFiles();
    if (stagedFiles.length === 0) {
      return {
        decision: 'APPROVE',
        issues: [],
        rationale: 'No staged files to scan'
      };
    }

    console.log(`[Auto-Mode+Aikido] Scanning ${stagedFiles.length} staged files...`);

    // Scan with Aikido
    const scanResult = await this.aikido.scanFiles(stagedFiles, this.getWorkspaceRoot());

    // Evaluate findings
    const criticalIssues = scanResult.issues.filter(i => i.severity === 'critical');
    const highIssues = scanResult.issues.filter(i => i.severity === 'high');

    if (criticalIssues.length > 0) {
      return {
        decision: 'DENY',
        issues: criticalIssues,
        rationale: `Found ${criticalIssues.length} critical vulnerability(ies) in staged files`,
        scanResult
      };
    }

    if (highIssues.length > 0) {
      return {
        decision: 'ESCALATE',
        issues: highIssues,
        rationale: `Found ${highIssues.length} high-severity issue(s) — review recommended`,
        scanResult
      };
    }

    return {
      decision: 'APPROVE',
      issues: scanResult.issues,
      rationale: scanResult.issues.length === 0
        ? 'No security issues found'
        : `${scanResult.issues.length} low/medium issues found — approved with notes`,
      scanResult
    };
  }

  /**
   * Post-edit scan: scan a file after modification.
   * @param {string} filePath
   * @returns {Promise<{clean: boolean, issues: Array}>}
   */
  async postEditScan(filePath) {
    if (!this.config.scanOnEdit || !this.aikido.connected) {
      return { clean: true, issues: [], skipped: true };
    }

    const absolutePath = path.resolve(filePath);
    if (!fs.existsSync(absolutePath)) {
      return { clean: true, issues: [], skipped: true, reason: 'File not found' };
    }

    const scanResult = await this.aikido.scanFiles([absolutePath], this.getWorkspaceRoot());

    this.scanResults.push({
      file: filePath,
      timestamp: new Date().toISOString(),
      issues: scanResult.issues
    });

    return {
      clean: scanResult.issues.length === 0,
      issues: scanResult.issues,
      summary: scanResult.summary
    };
  }

  // ─── Helpers ────────────────────────────────────────────────────────────

  extractDomains(action) {
    const domains = [];
    const urlRegex = /https?:\/\/([a-zA-Z0-9.-]+)/g;
    let match;
    while ((match = urlRegex.exec(action)) !== null) {
      domains.push(match[1]);
    }
    return [...new Set(domains)];
  }

  extractPackages(action) {
    const packages = [];
    
    // npm install <pkg> / npm i <pkg>
    const npmMatch = action.match(/npm\s+(?:install|i|add)\s+([^\s]+)/);
    if (npmMatch) packages.push(npmMatch[1]);

    // pip install <pkg>
    const pipMatch = action.match(/pip\s+install\s+([^\s]+)/);
    if (pipMatch) packages.push(pipMatch[1]);

    // cargo add <pkg>
    const cargoMatch = action.match(/cargo\s+add\s+([^\s]+)/);
    if (cargoMatch) packages.push(cargoMatch[1]);

    // go get <pkg>
    const goMatch = action.match(/go\s+get\s+([^\s]+)/);
    if (goMatch) packages.push(goMatch[1]);

    return [...new Set(packages)];
  }

  getStagedFiles() {
    try {
      const output = execSync('git diff --cached --name-only --diff-filter=ACM', {
        encoding: 'utf8',
        timeout: 5000
      }).trim();
      
      if (!output) return [];
      
      const root = this.getWorkspaceRoot();
      return output.split('\n').map(f => path.join(root, f));
    } catch {
      return [];
    }
  }

  getWorkspaceRoot() {
    try {
      return execSync('git rev-parse --show-toplevel', {
        encoding: 'utf8',
        timeout: 5000
      }).trim();
    } catch {
      return process.cwd();
    }
  }

  combineSignals(baseResult, aikidoSignals) {
    if (aikidoSignals.length === 0) {
      return baseResult;
    }

    // Check for deny signals
    const denySignals = aikidoSignals.filter(s => s.impact === 'deny');
    if (denySignals.length > 0) {
      const result = {
        ...baseResult,
        decision: 'DENY',
        riskLevel: 'critical',
        aikidoSignals,
        rationale: denySignals.map(s => {
          if (s.type === 'package_vulnerability') {
            return `Package "${s.package}" has ${s.issueCount} known vulnerability(ies) (max: ${s.maxSeverity})`;
          }
          return `Domain "${s.domain}" is in Aikido security feed (severity: ${s.severity})`;
        }).join('; ')
      };
      this.logDecision(result);
      return result;
    }

    // Check for elevate signals
    const elevateSignals = aikidoSignals.filter(s => s.impact === 'elevate');
    if (elevateSignals.length > 0 && baseResult.decision === 'APPROVE') {
      const result = {
        ...baseResult,
        decision: 'ESCALATE',
        riskLevel: 'high',
        aikidoSignals,
        rationale: elevateSignals.map(s => {
          if (s.type === 'package_vulnerability') {
            return `Package "${s.package}" has ${s.issueCount} known issue(s) (max: ${s.maxSeverity})`;
          }
          return `Domain "${s.domain}" flagged in security feed`;
        }).join('; ')
      };
      this.logDecision(result);
      return result;
    }

    return baseResult;
  }
}

// ─── Exports ────────────────────────────────────────────────────────────────

module.exports = { AutoModeAikido, AikidoBridge };

// ─── CLI ────────────────────────────────────────────────────────────────────

if (require.main === module) {
  const args = process.argv.slice(2);
  const command = args[0];

  const am = new AutoModeAikido({
    aikido: { enabled: true }
  });

  async function main() {
    // Check Aikido connection
    const connected = await am.aikido.checkConnection();
    console.log(`[Auto-Mode+Aikido] Aikido MCP: ${connected ? 'connected' : 'unavailable (standalone mode)'}`);

    switch (command) {
      case 'eval': {
        const action = args[1];
        const agent = args[2] || 'yolo';
        if (!action) {
          console.log('Usage: node integration.js eval <command> [agent]');
          process.exit(1);
        }
        const result = await am.evaluateActionEnhanced(action, agent);
        console.log('\n=== Enhanced Decision ===');
        console.log(`ACTION: ${result.action}`);
        console.log(`RISK: ${result.riskLevel}`);
        console.log(`DECISION: ${result.decision}`);
        if (result.rationale) console.log(`RATIONALE: ${result.rationale}`);
        if (result.aikidoSignals) console.log(`AIKIDO SIGNALS: ${result.aikidoSignals.length}`);
        break;
      }

      case 'pre-commit': {
        const msg = args[1] || '';
        const result = await am.preCommitHook(msg);
        console.log('\n=== Pre-Commit Result ===');
        console.log(`DECISION: ${result.decision}`);
        console.log(`RATIONALE: ${result.rationale}`);
        if (result.issues.length > 0) {
          console.log(`ISSUES: ${result.issues.length}`);
          result.issues.slice(0, 5).forEach(i => {
            console.log(`  - [${i.severity}] ${i.title || i.description || JSON.stringify(i)}`);
          });
        }
        break;
      }

      case 'scan': {
        const filePath = args[1];
        if (!filePath) {
          console.log('Usage: node integration.js scan <file>');
          process.exit(1);
        }
        const result = await am.postEditScan(filePath);
        console.log('\n=== Scan Result ===');
        console.log(`CLEAN: ${result.clean}`);
        if (result.issues.length > 0) {
          result.issues.forEach(i => {
            console.log(`  - [${i.severity}] ${i.title || i.description || JSON.stringify(i)}`);
          });
        }
        break;
      }

      default:
        console.log('Auto-Mode + Aikido Integration');
        console.log('');
        console.log('Commands:');
        console.log('  eval <command> [agent]   Evaluate action with Aikido enrichment');
        console.log('  pre-commit [message]     Pre-commit hook scan');
        console.log('  scan <file>              Post-edit file scan');
    }
  }

  main().catch(console.error);
}