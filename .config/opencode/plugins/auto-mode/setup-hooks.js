#!/usr/bin/env node
/**
 * Auto-Mode Hook Setup
 * 
 * Installs git hooks and configures bash tool interception.
 * 
 * Usage:
 *   node setup-hooks.js install [repo-path]
 *   node setup-hooks.js uninstall [repo-path]
 *   node setup-hooks.js status [repo-path]
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const HOOK_SOURCE = path.join(__dirname, 'pre-commit');
const HOOK_NAME = 'pre-commit';

// ─── Helpers ──────────────────────────────────────────────────────────────

function log(msg) {
  console.log(`\x1b[34m[Auto-Mode]\x1b[0m ${msg}`);
}

function success(msg) {
  console.log(`\x1b[32m[Auto-Mode]\x1b[0m ${msg}`);
}

function warn(msg) {
  console.log(`\x1b[33m[Auto-Mode]\x1b[0m ${msg}`);
}

function error(msg) {
  console.log(`\x1b[31m[Auto-Mode]\x1b[0m ${msg}`);
}

function getGitRoot(repoPath) {
  try {
    return execSync('git rev-parse --show-toplevel', {
      encoding: 'utf8',
      cwd: repoPath || process.cwd()
    }).trim();
  } catch {
    return null;
  }
}

// ─── Install ──────────────────────────────────────────────────────────────

function install(repoPath) {
  const gitRoot = getGitRoot(repoPath);
  
  if (!gitRoot) {
    error('Not a git repository. Run this from inside a git repo.');
    process.exit(1);
  }
  
  const hooksDir = path.join(gitRoot, '.git', 'hooks');
  const hookTarget = path.join(hooksDir, HOOK_NAME);
  
  // Ensure hooks directory exists
  if (!fs.existsSync(hooksDir)) {
    fs.mkdirSync(hooksDir, { recursive: true });
  }
  
  // Check if hook already exists
  if (fs.existsSync(hookTarget)) {
    const content = fs.readFileSync(hookTarget, 'utf8');
    if (content.includes('Auto-Mode')) {
      warn('Auto-Mode hook already installed — updating...');
    } else {
      // Backup existing hook
      const backup = `${hookTarget}.backup`;
      fs.copyFileSync(hookTarget, backup);
      warn(`Existing hook backed up to ${backup}`);
    }
  }
  
  // Copy hook
  fs.copyFileSync(HOOK_SOURCE, hookTarget);
  
  // Make executable (Unix only)
  try {
    fs.chmodSync(hookTarget, '755');
  } catch {
    // Windows — chmod not needed
  }
  
  success(`Pre-commit hook installed in ${gitRoot}`);
  log('Commits will now be scanned for security issues.');
}

// ─── Uninstall ────────────────────────────────────────────────────────────

function uninstall(repoPath) {
  const gitRoot = getGitRoot(repoPath);
  
  if (!gitRoot) {
    error('Not a git repository.');
    process.exit(1);
  }
  
  const hookTarget = path.join(gitRoot, '.git', 'hooks', HOOK_NAME);
  
  if (!fs.existsSync(hookTarget)) {
    warn('No pre-commit hook found.');
    return;
  }
  
  const content = fs.readFileSync(hookTarget, 'utf8');
  if (!content.includes('Auto-Mode')) {
    warn('Existing hook is not from Auto-Mode — not removing.');
    return;
  }
  
  // Remove hook
  fs.unlinkSync(hookTarget);
  
  // Restore backup if exists
  const backup = `${hookTarget}.backup`;
  if (fs.existsSync(backup)) {
    fs.renameSync(backup, hookTarget);
    success('Restored previous hook from backup.');
  } else {
    success('Auto-Mode pre-commit hook removed.');
  }
}

// ─── Status ───────────────────────────────────────────────────────────────

function status(repoPath) {
  const gitRoot = getGitRoot(repoPath);
  
  if (!gitRoot) {
    error('Not a git repository.');
    process.exit(1);
  }
  
  const hookTarget = path.join(gitRoot, '.git', 'hooks', HOOK_NAME);
  
  console.log('\n=== Auto-Mode Hook Status ===');
  console.log(`Repository: ${gitRoot}`);
  
  if (fs.existsSync(hookTarget)) {
    const content = fs.readFileSync(hookTarget, 'utf8');
    if (content.includes('Auto-Mode')) {
      success('Pre-commit hook: INSTALLED');
    } else {
      warn('Pre-commit hook: EXISTS (not Auto-Mode)');
    }
  } else {
    warn('Pre-commit hook: NOT INSTALLED');
  }
  
  // Check Aikido availability
  try {
    execSync('npx --version', { stdio: 'ignore' });
    success('Aikido MCP: AVAILABLE');
  } catch {
    warn('Aikido MCP: NOT AVAILABLE (npx not found)');
  }
  
  console.log('');
}

// ─── CLI ──────────────────────────────────────────────────────────────────

const args = process.argv.slice(2);
const command = args[0];
const repoPath = args[1] || process.cwd();

switch (command) {
  case 'install':
    install(repoPath);
    break;
  case 'uninstall':
    uninstall(repoPath);
    break;
  case 'status':
    status(repoPath);
    break;
  default:
    console.log('Auto-Mode Hook Setup');
    console.log('');
    console.log('Usage:');
    console.log('  node setup-hooks.js install [repo-path]   Install pre-commit hook');
    console.log('  node setup-hooks.js uninstall [repo-path]  Remove pre-commit hook');
    console.log('  node setup-hooks.js status [repo-path]     Show hook status');
    break;
}