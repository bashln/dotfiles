#!/usr/bin/env node
// Portable launcher for the @aikidosec/mcp server.
//
// Why this exists:
// - Windows: invoking `npx` (npx.cmd shim) without windowsHide opens a
//   console window per MCP start — flickering terminals.
// - Dotfiles are shared across machines: a hardcoded absolute path breaks
//   the other OS. This script resolves the installed entry per platform.
//
// It always spawns the real node binary (process.execPath) with
// windowsHide: true, so no .cmd/.ps1 shim is ever touched.
//
// Usage:
//   node aikido-mcp.cjs          -> resolve entry, spawn MCP server (stdio)
//   node aikido-mcp.cjs --check  -> print resolved entry, exit 0/1
'use strict';

const { spawn } = require('node:child_process');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');

const PKG = ['@aikidosec', 'mcp', 'dist', 'index.js'];

function roots() {
  const list = [];
  // Per-machine npm global roots.
  if (process.env.APPDATA) {
    list.push(path.join(process.env.APPDATA, 'npm', 'node_modules'));
  }
  if (process.env.npm_config_prefix) {
    list.push(path.join(process.env.npm_config_prefix, 'lib', 'node_modules'));
  }
  if (process.platform !== 'win32') {
    list.push('/usr/lib/node_modules');
    list.push('/usr/local/lib/node_modules');
    list.push(path.join(os.homedir(), '.npm-global', 'lib', 'node_modules'));
    list.push(path.join(os.homedir(), '.local', 'share', 'npm', 'node_modules'));
  }
  if (process.env.ProgramFiles) {
    list.push(path.join(process.env.ProgramFiles, 'nodejs', 'node_modules'));
  }
  // Config-local install (npm install inside ~/.config/opencode).
  list.push(path.join(__dirname, '..', 'node_modules'));
  list.push(path.join(os.homedir(), '.config', 'opencode', 'node_modules'));
  return list;
}

function resolveEntry() {
  for (const root of roots()) {
    const entry = path.join(root, ...PKG);
    try {
      fs.accessSync(entry, fs.constants.R_OK);
      return entry;
    } catch {
      // try next candidate
    }
  }
  return null;
}

const entry = resolveEntry();

if (process.argv.includes('--check')) {
  if (entry) {
    process.stdout.write(`aikido-mcp entry: ${entry}\n`);
    process.exit(0);
  }
  process.stderr.write(
    `aikido-mcp: @aikidosec/mcp not found. Searched:\n  ${roots().join('\n  ')}\n`
  );
  process.exit(1);
}

if (!entry) {
  process.stderr.write(
    `aikido-mcp: @aikidosec/mcp not found. Install it (npm i -g @aikidosec/mcp) or add its root to candidates.\n`
  );
  process.exit(1);
}

const child = spawn(process.execPath, [entry], {
  stdio: 'inherit',
  windowsHide: true,
});

child.on('error', (err) => {
  process.stderr.write(`aikido-mcp: failed to spawn: ${err.message}\n`);
  process.exit(1);
});

child.on('exit', (code, signal) => {
  if (signal) {
    process.kill(process.pid, signal);
  } else {
    process.exit(code ?? 0);
  }
});
