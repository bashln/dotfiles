#!/usr/bin/env node
/**
 * Auto-Mode Bash Interceptor
 * 
 * Wraps bash commands and routes them through Auto-Mode evaluation.
 * Can be used as a standalone CLI or integrated into opencode's bash tool.
 * 
 * Usage:
 *   node bash-interceptor.js run <command> [agent]
 *   node bash-interceptor.js check <command>
 *   node bash-interceptor.js hook
 */

const AutoModePlugin = require('./plugin');
const { execSync, spawn } = require('child_process');
const readline = require('readline');

// ─── Configuration ────────────────────────────────────────────────────────

const CONFIG = {
  logFile: `${process.env.HOME || process.env.USERPROFILE}/.opencode/auto-mode.log`,
  denyExitCode: 126, // Standard "permission denied" exit code
  escalatePrompt: true
};

// ─── Auto-Mode Instance ───────────────────────────────────────────────────

let autoMode = null;

function getAutoMode() {
  if (!autoMode) {
    autoMode = new AutoModePlugin();
  }
  return autoMode;
}

// ─── Helpers ──────────────────────────────────────────────────────────────

function log(msg) {
  process.stderr.write(`\x1b[34m[Auto-Mode]\x1b[0m ${msg}\n`);
}

function warn(msg) {
  process.stderr.write(`\x1b[33m[Auto-Mode]\x1b[0m ${msg}\n`);
}

function error(msg) {
  process.stderr.write(`\x1b[31m[Auto-Mode]\x1b[0m ${msg}\n`);
}

function success(msg) {
  process.stderr.write(`\x1b[32m[Auto-Mode]\x1b[0m ${msg}\n`);
}

// ─── Run Command ──────────────────────────────────────────────────────────

async function runCommand(command, agent = 'yolo') {
  const am = getAutoMode();
  
  // Evaluate the command
  const result = await am.evaluateAction(command, agent);
  
  // Log the decision
  process.stderr.write(`\n`);
  log(`ACTION: ${result.action}`);
  log(`RISK: ${result.riskLevel}`);
  log(`DECISION: ${result.decision}`);
  
  if (result.rationale) {
    log(`RATIONALE: ${result.rationale}`);
  }
  
  if (result.aikidoSignals && result.aikidoSignals.length > 0) {
    log(`AIKIDO SIGNALS: ${result.aikidoSignals.length}`);
    result.aikidoSignals.forEach(s => {
      if (s.type === 'package_vulnerability') {
        warn(`  Package "${s.package}" has ${s.issueCount} vulnerability(ies) (max: ${s.maxSeverity})`);
      } else if (s.type === 'domain_in_feed') {
        warn(`  Domain "${s.domain}" is in security feed`);
      }
    });
  }
  
  process.stderr.write(`\n`);
  
  // Handle decision
  switch (result.decision) {
    case 'APPROVE':
      success('Command approved — executing...');
      executeCommand(command);
      break;
      
    case 'DENY':
      error('Command DENIED by Auto-Mode');
      if (result.rationale) {
        error(`Reason: ${result.rationale}`);
      }
      error('Use --no-auto-mode to bypass (not recommended)');
      process.exit(CONFIG.denyExitCode);
      break;
      
    case 'ESCALATE':
      if (CONFIG.escalatePrompt) {
        warn('Command requires approval');
        const approved = await promptUser(command, result);
        if (approved) {
          success('Command approved by user — executing...');
          executeCommand(command);
        } else {
          error('Command denied by user');
          process.exit(CONFIG.denyExitCode);
        }
      } else {
        // Auto-approve escalations when prompt is disabled
        warn('Auto-approving escalation (prompt disabled)');
        executeCommand(command);
      }
      break;
      
    default:
      error(`Unknown decision: ${result.decision}`);
      process.exit(1);
  }
}

// ─── Execute Command ──────────────────────────────────────────────────────

function executeCommand(command) {
  try {
    // Use shell to preserve pipes, redirections, etc.
    const result = execSync(command, {
      encoding: 'utf8',
      stdio: 'inherit',
      timeout: 300000 // 5 minutes
    });
    process.exit(0);
  } catch (err) {
    process.exit(err.status || 1);
  }
}

// ─── Prompt User ──────────────────────────────────────────────────────────

function promptUser(command, result) {
  return new Promise((resolve) => {
    const rl = readline.createInterface({
      input: process.stdin,
      output: process.stderr
    });
    
    const shortCmd = command.length > 60 ? command.substring(0, 57) + '...' : command;
    
    process.stderr.write(`\n`);
    process.stderr.write(`\x1b[1;33m⚠  Auto-Mode Escalation\x1b[0m\n`);
    process.stderr.write(`\n`);
    process.stderr.write(`  Command: \x1b[36m${shortCmd}\x1b[0m\n`);
    process.stderr.write(`  Risk:    \x1b[33m${result.riskLevel}\x1b[0m\n`);
    
    if (result.rationale) {
      process.stderr.write(`  Reason:  ${result.rationale}\n`);
    }
    
    process.stderr.write(`\n`);
    process.stderr.write(`  Allow this command? (y/N) `);
    
    rl.question('', (answer) => {
      rl.close();
      const approved = answer.toLowerCase() === 'y' || answer.toLowerCase() === 'yes';
      resolve(approved);
    });
  });
}

// ─── Check Command (no execution) ────────────────────────────────────────

async function checkCommand(command, agent = 'yolo') {
  const am = getAutoMode();
  const result = await am.evaluateAction(command, agent);
  
  console.log(JSON.stringify(result, null, 2));
  return result;
}

// ─── Hook Mode (stdin/stdout) ─────────────────────────────────────────────

async function hookMode() {
  const am = getAutoMode();
  
  // Read command from stdin
  const rl = readline.createInterface({
    input: process.stdin,
    terminal: false
  });
  
  let command = '';
  
  for await (const line of rl) {
    command += line + '\n';
  }
  
  command = command.trim();
  
  if (!command) {
    process.exit(0);
  }
  
  // Evaluate
  const result = await am.evaluateAction(command, 'yolo');
  
  // Output decision as JSON
  console.log(JSON.stringify({
    decision: result.decision,
    riskLevel: result.riskLevel,
    rationale: result.rationale || null
  }));
  
  // Exit code indicates if command should run
  process.exit(result.decision === 'DENY' ? 1 : 0);
}

// ─── CLI ──────────────────────────────────────────────────────────────────

async function main() {
  const args = process.argv.slice(2);
  const command = args[0];
  
  switch (command) {
    case 'run':
      const cmd = args[1];
      const agent = args[2] || 'yolo';
      if (!cmd) {
        error('Usage: bash-interceptor.js run <command> [agent]');
        process.exit(1);
      }
      await runCommand(cmd, agent);
      break;
      
    case 'check':
      const checkCmd = args[1];
      const checkAgent = args[2] || 'yolo';
      if (!checkCmd) {
        error('Usage: bash-interceptor.js check <command> [agent]');
        process.exit(1);
      }
      await checkCommand(checkCmd, checkAgent);
      break;
      
    case 'hook':
      await hookMode();
      break;
      
    default:
      console.log('Auto-Mode Bash Interceptor');
      console.log('');
      console.log('Usage:');
      console.log('  node bash-interceptor.js run <command> [agent]    Execute command with Auto-Mode');
      console.log('  node bash-interceptor.js check <command> [agent]  Check command without executing');
      console.log('  node bash-interceptor.js hook                     Hook mode (stdin/stdout)');
      break;
  }
}

main().catch(err => {
  error(err.message);
  process.exit(1);
});