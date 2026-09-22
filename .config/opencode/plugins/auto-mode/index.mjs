// auto-mode — opencode plugin entry (ESM)
//
// Bridges the pattern engine (plugin.js) into opencode's plugin hook API.
// plugin.js stays CommonJS so its CLI usage (`node plugin.js "cmd" yolo`)
// keeps working; this file only adapts it for opencode.
//
// Enforcement point: `permission.ask`.
//   DENY     → output.status = "deny"   (critical patterns, e.g. rm -rf /)
//   ESCALATE → output.status = "ask"    (medium/high → user prompt)
//   APPROVE  → untouched (resolves via normal config permission rules)

import { createRequire } from 'node:module';

const require = createRequire(import.meta.url);
const AutoModePlugin = require('./plugin.js');

function extractCommand(perm) {
  // Only bash/shell executions are in scope.
  if (perm.type !== 'bash' && perm.type !== 'shell') return null;

  const p = perm.pattern;
  if (typeof p === 'string' && p.trim()) return p;
  if (Array.isArray(p) && p.length) return p.join('\n');
  if (typeof perm.metadata?.command === 'string') return perm.metadata.command;
  return null;
}

export default async function autoModePlugin(input, options = {}) {
  const engine = new AutoModePlugin({
    enabled: options.enabled !== false,
    policyFile: options.policyFile || 'auto-mode-policy.md',
    escalationTimeout: options.escalationTimeout || 300,
    circuitBreaker: options.circuitBreaker
  });

  const agent = options.agent || 'yolo';

  return {
    async 'permission.ask'(perm, output) {
      const command = extractCommand(perm);
      if (!command) return;

      try {
        const result = engine.evaluateAction(command, agent);

        if (result.decision === 'DENY') {
          output.status = 'deny';
        } else if (result.decision === 'ESCALATE') {
          output.status = 'ask';
        }
        // APPROVE → leave to normal permission config.
      } catch (err) {
        // Fail open: pattern engine broke — do not lock the session.
        console.error(`[Auto-Mode] evaluate failed: ${err.message}`);
      }
    }
  };
}
