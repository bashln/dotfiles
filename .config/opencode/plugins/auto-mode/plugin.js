/**
 * Auto-Mode Plugin for OpenCode
 * 
 * Inspired by Codex Auto-Mode, Claude safety rails, and Agy guardrails.
 * Intercepts dangerous actions and routes them through a reviewer agent.
 */

const fs = require('fs');
const path = require('path');

class AutoModePlugin {
  constructor(config = {}) {
    this.config = {
      enabled: true,
      policyFile: config.policyFile || 'auto-mode-policy.md',
      circuitBreaker: {
        maxConsecutiveDenials: 3,
        maxDenialsInWindow: 10,
        windowSize: 50,
        ...config.circuitBreaker
      },
      logFile: config.logFile || path.join(
        process.env.HOME || process.env.USERPROFILE,
        '.opencode',
        'auto-mode.log'
      ),
      escalationTimeout: config.escalationTimeout || 300,
      ...config
    };
    
    this.sessionDenials = [];
    this.consecutiveDenials = 0;
    this.overrideLog = [];
    
    this.loadPolicy();
  }

  loadPolicy() {
    try {
      const policyPath = path.join(
        process.env.HOME || process.env.USERPROFILE,
        '.config',
        'opencode',
        this.config.policyFile
      );
      
      if (fs.existsSync(policyPath)) {
        const policyContent = fs.readFileSync(policyPath, 'utf8');
        this.policy = this.parsePolicy(policyContent);
        console.log(`[Auto-Mode] Loaded policy from ${policyPath}`);
      } else {
        console.log(`[Auto-Mode] No policy file found, using defaults`);
        this.policy = this.getDefaultPolicy();
      }
    } catch (error) {
      console.error(`[Auto-Mode] Error loading policy: ${error.message}`);
      this.policy = this.getDefaultPolicy();
    }
  }

  parsePolicy(content) {
    const policy = {
      allow: [],
      deny: [],
      escalate: []
    };

    let currentSection = null;
    let inCodeBlock = false;
    const lines = content.split('\n');

    for (const line of lines) {
      const trimmed = line.trim();
      
      if (trimmed.startsWith('```')) {
        inCodeBlock = !inCodeBlock;
        continue;
      }
      
      if (!inCodeBlock) {
        if (trimmed.startsWith('## Allow List')) {
          currentSection = 'allow';
        } else if (trimmed.startsWith('## Deny List')) {
          currentSection = 'deny';
        } else if (trimmed.startsWith('## Escalate List')) {
          currentSection = 'escalate';
        } else if (trimmed.startsWith('##')) {
          currentSection = null;
        }
      }
      
      if (inCodeBlock && currentSection && trimmed.startsWith('- "')) {
        const match = trimmed.match(/^- "(.+)"$/);
        if (match) {
          policy[currentSection].push(match[1]);
        }
      }
    }

    return policy;
  }

  getDefaultPolicy() {
    return {
      allow: [
        'git status', 'git diff', 'git log', 'git show',
        'cat *', 'ls *', 'find *', 'grep *',
        'npm test', 'npm run lint', 'npm run build'
      ],
      deny: [
        'rm -rf /', 'rm -rf ~', 'chmod 777',
        'curl * | *', 'wget * | *',
        'grep -r password', 'grep -r secret'
      ],
      escalate: [
        'curl *', 'wget *', 'npm install *',
        'git push *', 'git commit *'
      ]
    };
  }

  evaluateAction(action, agent = 'unknown') {
    const riskLevel = this.assessRisk(action);
    const decision = this.makeDecision(action, riskLevel);
    
    const result = {
      timestamp: new Date().toISOString(),
      action,
      riskLevel,
      decision,
      agent,
      session: this.getSessionId()
    };

    this.logDecision(result);
    
    if (decision === 'DENY') {
      this.consecutiveDenials++;
      this.sessionDenials.push(result);
      
      if (this.consecutiveDenials >= this.config.circuitBreaker.maxConsecutiveDenials) {
        result.circuitBreakerTripped = true;
        this.handleCircuitBreakerTrip();
      }
    } else if (decision === 'APPROVE') {
      this.consecutiveDenials = 0;
    }

    return result;
  }

  assessRisk(action) {
    const actionLower = action.toLowerCase();
    
    // Check deny list first (critical) - sort by specificity (longer patterns first)
    const sortedDeny = [...this.policy.deny].sort((a, b) => b.length - a.length);
    if (this.matchesPattern(actionLower, sortedDeny)) {
      return 'critical';
    }
    
    // Check escalate list (high) - sort by specificity
    const sortedEscalate = [...this.policy.escalate].sort((a, b) => b.length - a.length);
    if (this.matchesPattern(actionLower, sortedEscalate)) {
      return 'high';
    }
    
    // Check allow list (low) - sort by specificity
    const sortedAllow = [...this.policy.allow].sort((a, b) => b.length - a.length);
    if (this.matchesPattern(actionLower, sortedAllow)) {
      return 'low';
    }
    
    // Default to medium
    return 'medium';
  }

  makeDecision(action, riskLevel) {
    switch (riskLevel) {
      case 'critical':
        return 'DENY';
      case 'high':
        return 'ESCALATE';
      case 'medium':
        return 'ESCALATE';
      case 'low':
        return 'APPROVE';
      default:
        return 'ESCALATE';
    }
  }

  matchesPattern(action, patterns) {
    if (!patterns || !Array.isArray(patterns)) return false;
    
    return patterns.some(pattern => {
      // No wildcards: substring/contains match
      // e.g., "grep -r password" matches "grep -r password ."
      if (!pattern.includes('*')) {
        return action.includes(pattern);
      }
      
      // Single trailing wildcard only (e.g., "curl *"): prefix match
      // Skip if pattern has multiple wildcards — fall through to regex
      if (pattern.endsWith(' *') && pattern.indexOf('*') === pattern.length - 1) {
        const prefix = pattern.slice(0, -2);
        return action === prefix || action.startsWith(prefix + ' ');
      }
      
      // Mixed or multiple wildcards: regex match
      // e.g., "curl * | *" → /^curl .* \| .*$/i
      const escaped = pattern.replace(/[.+?^${}()|[\]\\]/g, '\\$&');
      const regex = new RegExp(
        '^' + escaped.replace(/\*/g, '.*') + '$',
        'i'
      );
      return regex.test(action);
    });
  }

  handleCircuitBreakerTrip() {
    console.error('[Auto-Mode] CIRCUIT BREAKER TRIPPED');
    console.error(`[Auto-Mode] ${this.consecutiveDenials} consecutive denials`);
    console.error('[Auto-Mode] Session paused. Manual intervention required.');
    
    this.logDecision({
      timestamp: new Date().toISOString(),
      event: 'CIRCUIT_BREAKER_TRIP',
      consecutiveDenials: this.consecutiveDenials,
      totalDenialsInSession: this.sessionDenials.length
    });
  }

  handleOverride(action, user, reason) {
    const override = {
      timestamp: new Date().toISOString(),
      action,
      overriddenBy: user,
      reason,
      retryAllowed: true
    };
    
    this.overrideLog.push(override);
    this.logDecision({
      ...override,
      event: 'OVERRIDE'
    });
    
    return override;
  }

  logDecision(decision) {
    try {
      const logDir = path.dirname(this.config.logFile);
      if (!fs.existsSync(logDir)) {
        fs.mkdirSync(logDir, { recursive: true });
      }
      
      fs.appendFileSync(
        this.config.logFile,
        JSON.stringify(decision) + '\n'
      );
    } catch (error) {
      console.error(`[Auto-Mode] Error logging decision: ${error.message}`);
    }
  }

  getSessionId() {
    return process.env.OPENCODE_SESSION || 'default';
  }

  getStats() {
    return {
      consecutiveDenials: this.consecutiveDenials,
      totalDenialsInSession: this.sessionDenials.length,
      overrides: this.overrideLog.length,
      circuitBreakerTripped: this.consecutiveDenials >= this.config.circuitBreaker.maxConsecutiveDenials
    };
  }

  reset() {
    this.consecutiveDenials = 0;
    this.sessionDenials = [];
    this.overrideLog = [];
    console.log('[Auto-Mode] Session reset');
  }
}

// Export for OpenCode plugin system
module.exports = AutoModePlugin;

// CLI usage
if (require.main === module) {
  const args = process.argv.slice(2);
  
  if (args.length === 0) {
    console.log('Usage: node plugin.js <command> [agent]');
    console.log('Example: node plugin.js "npm install express" yolo');
    process.exit(1);
  }
  
  const plugin = new AutoModePlugin();
  const action = args[0];
  const agent = args[1] || 'unknown';
  
  const result = plugin.evaluateAction(action, agent);
  
  console.log('\n=== Auto-Mode Decision ===');
  console.log(`ACTION: ${result.action}`);
  console.log(`RISK LEVEL: ${result.riskLevel}`);
  console.log(`DECISION: ${result.decision}`);
  
  if (result.decision === 'DENY') {
    console.log('RATIONALE: Action matches deny policy');
    console.log('ALTERNATIVE: Review action and use approved alternative');
  }
  
  if (result.circuitBreakerTripped) {
    console.log('\n⚠️  CIRCUIT BREAKER TRIPPED');
    console.log('Session paused due to too many denials');
  }
  
  console.log('\nStats:', plugin.getStats());
}