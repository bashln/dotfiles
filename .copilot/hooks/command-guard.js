#!/usr/bin/env node
/**
 * command-guard.js — Guarda de comandos de terminal para agentes do VS Code.
 *
 * Evento: PreToolUse. Classifica cada comando em tres faixas:
 *   allow -> aprovado automaticamente (comando seguro)
 *   ask   -> exige confirmacao do usuario (destrutivo, irreversivel ou sensivel)
 *   deny  -> bloqueado (catastrofico: apaga disco/raiz, executa payload remoto, etc.)
 *
 * Contrato (VS Code agent hooks):
 *   stdin  : { hook_event_name, tool_name, tool_input, cwd, session_id, ... }
 *   stdout : { hookSpecificOutput: { hookEventName, permissionDecision, permissionDecisionReason } }
 *            ou { continue: true } quando o hook nao tem opiniao sobre a chamada.
 *
 * Personalizacao opcional: crie `command-guard.config.json` ao lado deste arquivo:
 *   { "extraDeny": ["^docker\\s+system\\s+prune"], "extraAsk": ["^terraform\\s+apply"] }
 * Precedencia: extraDeny > deny > extraAsk > ask > allow (padrao).
 *
 * Variaveis de ambiente:
 *   COMMAND_GUARD_LOG=0  desativa o log em command-guard.log (auditoria).
 */
"use strict";

const fs = require("fs");
const os = require("os");
const path = require("path");

/* ---------------------------------------------------------------- infra */

const TERMINAL_TOOL_RE =
  /^(run_?in_?terminal|send_?to_?terminal|kill_?terminal|run_?command|terminal|bash|shell|powershell|cmd|execute)$/i;

const LOG_ENABLED = process.env.COMMAND_GUARD_LOG !== "0";
const LOG_FILE = path.join(__dirname, "command-guard.log");

function readStdin() {
  try {
    return fs.readFileSync(0, "utf8");
  } catch {
    return "";
  }
}

function write(payload) {
  process.stdout.write(JSON.stringify(payload));
}

function decide(decision, reason) {
  write({
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: decision,
      permissionDecisionReason: reason,
    },
  });
}

function noOpinion() {
  write({ continue: true });
}

function log(entry) {
  if (!LOG_ENABLED) return;
  try {
    fs.appendFileSync(
      LOG_FILE,
      JSON.stringify({ ts: new Date().toISOString(), ...entry }) + "\n",
    );
  } catch {
    /* log nunca deve quebrar o hook */
  }
}

/* ------------------------------------------------------- entrada do hook */

function extractCommands(input) {
  const ti = (input && (input.tool_input || input.toolInput)) || {};
  const found = [];
  const push = (v) => {
    if (typeof v === "string" && v.trim()) found.push(v);
  };
  for (const key of ["command", "cmd", "commandLine", "script", "commands"]) {
    const v = ti[key];
    if (Array.isArray(v)) v.forEach(push);
    else if (v && typeof v === "object") Object.values(v).forEach(push);
    else push(v);
  }
  return [...new Set(found)];
}

/** Divide o comando em segmentos respeitando aspas simples/duplas. */
function splitSegments(cmd) {
  const segs = [];
  let cur = "";
  let quote = null;
  for (let i = 0; i < cmd.length; i++) {
    const ch = cmd[i];
    if (quote) {
      cur += ch;
      if (ch === quote) quote = null;
      continue;
    }
    if (ch === '"' || ch === "'") {
      quote = ch;
      cur += ch;
      continue;
    }
    if (ch === "\n" || ch === ";" || ch === "|" || ch === "&") {
      while (i + 1 < cmd.length && /[;&|\n]/.test(cmd[i + 1])) i++;
      if (cur.trim()) segs.push(cur.trim());
      cur = "";
      continue;
    }
    cur += ch;
  }
  if (cur.trim()) segs.push(cur.trim());
  return segs;
}

/* --------------------------------------------------------------- regras */

// Catastrofico / irreversivel: nunca executa.
const DENY_RULES = [
  {
    re: /\brm\s+(?:-[a-z]+\s+)*-[a-z]*r[a-z]*f[a-z]*\s+['"]?(?:\/|~|\$HOME)['"]?(?:\s|\/?\*|$)/i,
    why: "remoção recursiva da raiz ou do diretório home",
  },
  {
    re: /\brm\s+(?:-[a-z]+\s+)*-[a-z]*f[a-z]*r[a-z]*\s+['"]?(?:\/|~|\$HOME)['"]?(?:\s|\/?\*|$)/i,
    why: "remoção recursiva da raiz ou do diretório home",
  },
  {
    re: /\b(?:rd|rmdir)\s+\/s\s+\/q\s+"?[a-z]:\\?"?\s*$/i,
    why: "remoção recursiva de uma unidade inteira",
  },
  {
    re: /\b(?:Remove-Item|ri|del|erase|rd|rmdir)\b[^|;]*\b[a-zA-Z]:\\\s*(?:$|["'])/i,
    why: "remoção da raiz de uma unidade",
  },
  {
    re: /\b(?:Remove-Item|rd|rmdir)\b[^|;]*(?:-Recurse|\/s)[^|;]*[a-zA-Z]:\\(?:Windows|Program Files|ProgramData|Users)\b/i,
    why: "remoção de diretório de sistema",
  },
  { re: /\bmkfs(?:\.\w+)?\b/i, why: "formatação de sistema de arquivos" },
  { re: /\bformat\s+[a-z]:/i, why: "formatação de uma unidade" },
  { re: /\b(?:diskpart|fdisk|parted)\b/i, why: "manipulação de partições" },
  {
    re: /\bdd\b[^|;]*\bof=\s*\/(?:dev|proc)\//i,
    why: "escrita direta em dispositivo de bloco",
  },
  { re: /:\s*\(\s*\)\s*\{[^}]*\|[^}]*&[^}]*\}\s*;\s*:/, why: "fork bomb" },
  {
    re: /\b(?:shutdown|reboot|halt|poweroff)\b/i,
    why: "desligamento/reinício da máquina",
  },
  {
    re: /\b(?:Stop|Restart)-Computer\b/i,
    why: "desligamento/reinício da máquina",
  },
  {
    re: /\b(?:curl|wget)\b[^|]*\|\s*(?:sudo\s+)?(?:sh|bash|zsh|dash|python\d?|node|perl|ruby)\b/i,
    why: "download de script executado direto no shell",
  },
  {
    re: /\b(?:iwr|irm|Invoke-WebRequest|Invoke-RestMethod)\b[^|]*\|\s*(?:iex|Invoke-Expression)\b/i,
    why: "download de código executado dinamicamente",
  },
  {
    re: /\biex\s*\(\s*(?:iwr|irm|new-object\s+net\.webclient)/i,
    why: "execução de código baixado da internet",
  },
  {
    re: /\bnew-object\s+net\.webclient\b[^|]*\.DownloadString/i,
    why: "execução de código baixado da internet",
  },
  {
    re: /\breg\s+delete\s+["']?HKLM/i,
    why: "remoção de chave crítica do registro do Windows",
  },
  {
    re: /\b(?:bcdedit|vssadmin\s+delete|wbadmin\s+delete|cipher\s+\/w)\b/i,
    why: "alteração de inicialização/backup do sistema",
  },
  {
    re: /\bchmod\s+(?:-[A-Za-z]+\s+)?777\s+\/(?:\s|$)/i,
    why: "permissão total na raiz do sistema de arquivos",
  },
  {
    re: /\bchown\s+-R\b[^|;]*\s\/(?:\s|$)/i,
    why: "troca recursiva de dono na raiz do sistema de arquivos",
  },
  {
    re: />\s*\/(?:dev|proc|sys)\//i,
    why: "escrita em dispositivo/pseudossistema",
  },
];

// Destrutivo ou sensivel: exige confirmacao humana.
const ASK_RULES = [
  {
    re: /^(?:rm|rmdir|rd|del|erase|unlink|shred|truncate)\b/i,
    why: "remoção de arquivos",
    regenerableOk: true,
  },
  {
    re: /^(?:Remove-Item|Clear-Content|Remove-ItemProperty|ri)\b/i,
    why: "remoção/limpeza de arquivos",
    regenerableOk: true,
  },
  {
    re: /^(?:mv|move|ren|rename|Move-Item|Rename-Item)\b/i,
    why: "mover ou renomear arquivos (risco de sobrescrever)",
  },
  {
    re: /^(?:kill|killall|pkill|taskkill|Stop-Process|spps)\b/i,
    why: "encerrar processos",
  },
  { re: /^(?:ps|top)\b/i, why: "monitor interativo de processos" },
  { re: /^(?:sudo|runas|doas|gsudo)\b/i, why: "elevação de privilégio" },
  {
    re: /^Start-Process\b[^|]*-Verb\s+["']?RunAs/i,
    why: "elevação de privilégio",
  },
  {
    re: /^(?:chmod|chown|chgrp|chattr|icacls|cacls|takeown|attrib|Set-Acl|Set-ItemProperty|reg)\b/i,
    why: "permissões, atributos ou registro do sistema",
  },
  {
    re: /^(?:curl|wget|Invoke-WebRequest|Invoke-RestMethod|iwr|irm|Start-BitsTransfer|nc|ncat|telnet|scp|sftp|ssh|rsync)\b/i,
    why: "acesso de rede ou transferência de dados para fora",
  },
  {
    re: /^(?:eval|Invoke-Expression|iex)\b/i,
    why: "execução dinâmica de código",
  },
  { re: /^(?:xargs|jq)\b/i, why: "processamento com execução dinâmica" },
  {
    re: /-EncodedCommand\b|FromBase64String|^certutil\s+-decode|^(?:base64|base64\.exe)\s+-(?:d|D)\b/i,
    why: "payload codificado (possível ofuscação)",
  },
  {
    re: /^docker\s+(?:rm|rmi|prune|container\s+rm|image\s+rm|volume\s+rm|network\s+rm|system\s+prune)\b/i,
    why: "remoção de recursos Docker",
  },
  {
    re: /^docker\s+compose\s+(?:down|rm)\b[^|]*\s-v\b/i,
    why: "remoção de volumes Docker (perda de dados)",
  },
  {
    re: /^kubectl\s+(?:delete|drain|cordon)\b/i,
    why: "remoção/isolamento de recursos Kubernetes",
  },
  {
    re: /^(?:npm|pnpm|yarn)\s+(?:i|install|add|ci)\b[^|]*(?:\s-g\b|\s--global\b)/i,
    why: "instalação global de pacote",
  },
  { re: /^(?:npm|pnpm|yarn)\s+publish\b/i, why: "publicação de pacote" },
  {
    re: /^(?:pip|pip3|pipx)\s+(?:install|uninstall|upgrade)\b/i,
    why: "instalação/remoção de pacote Python",
  },
  {
    re: /^(?:choco|winget|scoop|snap|apt|apt-get|yum|dnf|pacman|zypper)\s+(?:install|remove|uninstall|upgrade|dist-upgrade|autoremove|purge)\b/i,
    why: "gerenciador de pacotes do sistema",
  },
  {
    re: /^(?:cargo|go|gem|composer|dotnet)\s+(?:install|uninstall|get|add)\b[^|]*(?:\s-g\b|\s--global\b|--tool)/i,
    why: "instalação global de ferramenta",
  },
  { re: /^setx\b/i, why: "alteração permanente de variável de ambiente" },
  {
    re: /^\[Environment\]::SetEnvironmentVariable/i,
    why: "alteração permanente de variável de ambiente",
  },
  {
    re: /^(?:sc|net)\s+(?:stop|start|delete|user|localgroup|share)\b/i,
    why: "serviços, contas ou compartilhamentos do sistema",
  },
  {
    re: /^(?:find|fd)\b[^|]*\s-(?:delete|exec|execdir|ok|okdir)\b/i,
    why: "busca com execução ou remoção em massa",
  },
  { re: /^(?:sed|perl)\b[^|]*\s-i\b/i, why: "edição em massa in-place" },
  {
    re: /^(?:sort|tree|xxd|sed)\b[^|]*\s-(?:o|output)\b/i,
    why: "escrita em arquivo via comando",
  },
  {
    re: /^git\b[^|]*\s(?:push|clean|reset\s+--hard|filter-branch|update-ref|stash\s+(?:drop|clear)|branch\s+-[dD]|tag\s+-d|config\s+--global|remote\s+(?:add|remove|set-url)|checkout\s+(?:-f|--force))\b/i,
    why: "operação Git que descarta, reescreve, apaga ou publica histórico",
  },
  {
    re: /^git\s+restore\b(?![^|]*--staged)/i,
    why: "descarte de alterações locais",
  },
  { re: /^git\s+rebase\b/i, why: "reescrita de histórico local" },
];

// Alvos de remoção considerados descartaveis (podem ser recriados).
const REGENERABLE_RE =
  /(?:^|[/\\\s"'])(?:node_modules|dist|build|out|coverage|\.next|\.nuxt|\.cache|\.turbo|\.parcel-cache|tmp|temp|__pycache__|\.pytest_cache|\.mypy_cache|\.ruff_cache|target[/\\](?:debug|release)|obj|binaries|bin[/\\](?:debug|release))[/\\\s"']*$/i;

const REDIRECT_RE =
  /(?:^|[\s&;|])(?:\d?>>?)\s*(?:"([^"]+)"|'([^']+)'|([^\s;&|)]+))/g;
const WRITE_CMD_RE =
  /\b(?:Out-File|Set-Content|Add-Content|Tee-Object)\b[^|]*(?:-FilePath|-Path)\s*"?([A-Za-z]:\\[^"'\s|]+|\/[^\s"'|]+|~\/[^\s"'|]+)/i;

/* ------------------------------------------------------------- analise */

function tokens(seg) {
  return (seg.match(/"[^"]*"|'[^']*'|[^\s]+/g) || [])
    .map((t) => t.replace(/^["']|["']$/g, ""))
    .filter((t) => t && !t.startsWith("-") && !/^\/[a-z]{1,3}$/i.test(t))
    .slice(1); // descarta o proprio nome do comando
}

function isRegenerableOnly(seg) {
  const toks = tokens(seg);
  if (!toks.length) return false;
  const tmp = os.tmpdir().replace(/\\/g, "/").toLowerCase();
  return toks.every((t) => {
    const norm = t.replace(/\\/g, "/").replace(/^\.\//, "");
    if (norm === "*" || norm === "./*" || norm === "." || norm === "./")
      return false;
    if (
      /^[a-z]:\//i.test(norm) ||
      norm.startsWith("/") ||
      norm.startsWith("~/")
    ) {
      const low = norm.toLowerCase();
      return (
        low.startsWith(tmp) ||
        low.startsWith("/tmp/") ||
        low.startsWith("/var/tmp/")
      );
    }
    if (REGENERABLE_RE.test("/" + norm)) return true;
    return norm
      .split("/")
      .some((part) => REGENERABLE_RE.test("/" + part + "/"));
  });
}

function writeTargets(seg) {
  const out = [];
  let m;
  REDIRECT_RE.lastIndex = 0;
  while ((m = REDIRECT_RE.exec(seg))) out.push(m[1] || m[2] || m[3]);
  const m2 = seg.match(WRITE_CMD_RE);
  if (m2) out.push(m2[1]);
  return out.filter(Boolean);
}

function isOutsideWorkspace(target, cwd) {
  const p = target.replace(/\\/g, "/");
  if (!/^(?:[a-z]:\/|\/|~\/)/i.test(p)) return false; // caminho relativo: dentro do workspace
  const low = p.toLowerCase();
  if (
    ["/dev/null", "/dev/stdout", "nul", "nul:", "$null"].some((n) =>
      low.startsWith(n),
    )
  )
    return false;
  const tmp = os.tmpdir().replace(/\\/g, "/").toLowerCase();
  if (
    low.startsWith(tmp) ||
    low.startsWith("/tmp") ||
    low.startsWith("/var/tmp")
  )
    return false;
  const base = ((cwd || process.cwd()) + "/").replace(/\\/g, "/").toLowerCase();
  return !low.startsWith(base);
}

function loadExtraRules() {
  try {
    const cfg = JSON.parse(
      fs.readFileSync(
        path.join(__dirname, "command-guard.config.json"),
        "utf8",
      ),
    );
    const build = (arr) =>
      (Array.isArray(arr) ? arr : []).map((s) => new RegExp(s, "i"));
    return {
      deny: build(cfg.extraDeny),
      ask: build(cfg.extraAsk),
      allow: build(cfg.extraAllow),
    };
  } catch {
    return { deny: [], ask: [], allow: [] };
  }
}

function classify(full, segments, cwd) {
  const extra = loadExtraRules();

  for (const r of extra.deny)
    if (r.test(full))
      return {
        decision: "deny",
        reason: "Bloqueado por regra local (extraDeny).",
      };
  for (const r of DENY_RULES)
    if (r.re.test(full))
      return {
        decision: "deny",
        reason: `Bloqueado por política de segurança: ${r.why}`,
      };

  for (const seg of segments) {
    for (const t of writeTargets(seg)) {
      if (isOutsideWorkspace(t, cwd)) {
        return {
          decision: "ask",
          reason: `Confirmação necessária: escrita no caminho "${t}", fora do workspace.`,
        };
      }
    }
    for (const r of extra.ask)
      if (r.test(seg))
        return {
          decision: "ask",
          reason: `Confirmação necessária (regra local): ${seg}`,
        };

    for (const r of ASK_RULES) {
      if (!r.re.test(seg)) continue;
      if (r.regenerableOk && isRegenerableOnly(seg)) continue; // limpeza de artefatos recriáveis
      if (extra.allow.some((a) => a.test(seg))) continue;
      return {
        decision: "ask",
        reason: `Confirmação necessária: ${r.why}. Comando: ${seg}`,
      };
    }
  }

  return {
    decision: "allow",
    reason: "Comando classificado como seguro pelo command-guard.",
  };
}

/* ----------------------------------------------------------------- main */

function main() {
  const raw = readStdin();
  let input = {};
  try {
    input = JSON.parse(raw || "{}");
  } catch {
    log({ event: "parse_error", raw: raw.slice(0, 500) });
    noOpinion();
    return;
  }

  const toolName = String(input.tool_name || input.toolName || "");
  const commands = extractCommands(input);

  if (!TERMINAL_TOOL_RE.test(toolName) || !commands.length) {
    noOpinion(); // não é comando de terminal: sem opinião
    return;
  }

  const full = commands.join("\n");
  const segments = commands.flatMap((c) => splitSegments(c));
  const cwd = input.cwd || process.cwd();
  const { decision, reason } = classify(full, segments, cwd);

  log({ tool: toolName, decision, reason, cwd, commands });
  decide(decision, reason);
}

try {
  main();
} catch {
  noOpinion(); // falha do guard nunca deve travar a sessão
}
