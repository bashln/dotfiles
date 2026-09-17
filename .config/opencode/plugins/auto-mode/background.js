/**
 * Auto-Mode Background Service
 * 
 * Runs as a lightweight background process that intercepts
 * bash commands transparently. Integrates with opencode's
 * plugin system for automatic safety evaluation.
 * 
 * This is loaded by the plugin system and hooks into
 * the bash tool execution flow.
 */

const { AutoModeAikido } = require('./integration');
const fs = require('fs');
const path = require('path');

// ─── Singleton Instance ──────────────────────────────────────────────────

let instance = null;

function getInstance() {
  if (!instance) {
    instance = new AutoModeAikido({
      aikido: { enabled: true },
      scanOnEdit: true,
      preCommitScan: true,
      domainCheck: true
    });
  }
  return instance;
}

// ─── Command Interceptor ─────────────────────────────────────────────────

/**
 * Intercept and evaluate a bash command before execution.
 * Called by opencode's bash tool via the plugin system.
 * 
 * @param {string} command - The bash command to evaluate
 * @param {object} context - Execution context (agent, cwd, etc.)
 * @returns {{ allowed: boolean, decision: string, rationale?: string }}
 */
async function interceptCommand(command, context = {}) {
  const am = getInstance();
  const agent = context.agent || 'yolo';
  
  try {
    const result = await am.evaluateActionEnhanced(command, agent);
    
    return {
      allowed: result.decision !== 'DENY',
      decision: result.decision,
      riskLevel: result.riskLevel,
      rationale: result.rationale || null,
      aikidoSignals: result.aikidoSignals || []
    };
  } catch (err) {
    // On error, allow execution (fail open)
    console.error(`[Auto-Mode] Intercept error: ${err.message}`);
    return {
      allowed: true,
      decision: 'ERROR',
      rationale: `Evaluation failed: ${err.message}`
    };
  }
}

// ─── Plugin Hooks ────────────────────────────────────────────────────────

/**
 * Pre-execution hook — called before bash command runs.
 * Returns true to allow, false to block.
 */
async function preExecHook(command, context) {
  const result = await interceptCommand(command, context);
  
  // Log the interception
  logInterception(command, result);
  
  return result.allowed;
}

/**
 * Post-execution hook — called after bash command completes.
 * Used for post-edit scanning and logging.
 */
async function postExecHook(command, context, exitCode) {
  // Could trigger post-edit scans here if needed
  // For now, just log completion
}

// ─── Logging ─────────────────────────────────────────────────────────────

function logInterception(command, result) {
  const logFile = path.join(
    process.env.HOME || process.env.USERPROFILE,
    '.opencode',
    'auto-mode.log'
  );
  
  const entry = {
    timestamp: new Date().toISOString(),
    command: command.substring(0, 200), // Truncate long commands
    decision: result.decision,
    riskLevel: result.riskLevel,
    allowed: result.allowed
  };
  
  try {
    const logDir = path.dirname(logFile);
    if (!fs.existsSync(logDir)) {
      fs.mkdirSync(logDir, { recursive: true });
    }
    fs.appendFileSync(logFile, JSON.stringify(entry) + '\n');
  } catch {
    // Ignore logging errors
  }
}

// ─── Exports ─────────────────────────────────────────────────────────────

module.exports = {
  getInstance,
  interceptCommand,
  preExecHook,
  postExecHook
};