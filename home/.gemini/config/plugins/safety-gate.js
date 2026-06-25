#!/usr/bin/env node

const fs = require('fs');

function readStdin() {
  return new Promise((resolve) => {
    let data = '';
    process.stdin.on('data', chunk => {
      data += chunk;
    });
    process.stdin.on('end', () => {
      resolve(data);
    });
  });
}

async function main() {
  try {
    const inputStr = await readStdin();
    if (!inputStr.trim()) {
      console.log(JSON.stringify({ decision: "allow" }));
      return;
    }
    
    const input = JSON.parse(inputStr);
    const toolCall = input.toolCall;
    
    if (!toolCall) {
      console.log(JSON.stringify({ decision: "allow" }));
      return;
    }
    
    // Tools de escrita de arquivo → sempre pedir confirmação (modo consultor)
    const writeTools = ['write_file', 'edit_file'];
    if (writeTools.includes(toolCall.name)) {
      console.error(`[Safety Gate] Interceptado: ${toolCall.name}`);
      console.log(JSON.stringify({
        decision: "force_ask",
        reason: `Edição de arquivo detectada (${toolCall.name}). Confirma?`
      }));
      return;
    }
    
    // Interceptar comando de execução de terminal
    if (toolCall.name !== 'run_command') {
      console.log(JSON.stringify({ decision: "allow" }));
      return;
    }
    
    const cmd = (toolCall.args?.CommandLine || '').trim();
    
    // Padrões de comandos perigosos
    const dangerousRules = [
      {
        pattern: /\brm\s+-/i,
        name: "Remoção recursiva/forçada (rm -rf)"
      },
      {
        pattern: /\bdel\b.*\s+\/f/i,
        name: "Deleção forçada no Windows (del /f)"
      },
      {
        pattern: /\b(rd|rmdir)\b.*\s+\/s/i,
        name: "Remoção de diretórios recursiva (rmdir /s)"
      },
      {
        pattern: /\bformat\b/i,
        name: "Formatação de disco"
      },
      {
        pattern: /\b(diskpart|Format-Volume)\b/i,
        name: "Utilitário de particionamento/formatação"
      },
      {
        pattern: /\b(shutdown|restart|Stop-Computer)\b/i,
        name: "Desligamento ou reinicialização"
      },
      {
        pattern: /\b(kill|taskkill|Stop-Process)\b/i,
        name: "Terminar processos críticos"
      },
      {
        pattern: /\breg\s+delete\b/i,
        name: "Exclusão de chaves do Registro do Windows"
      },
      {
        pattern: /\bgit\s+push\b/i,
        name: "Git push (risco de sobrescrever remoto)"
      },
      {
        pattern: /\bgit\s+reset\s+--hard\b/i,
        name: "Git reset hard (perda de alterações locais)"
      },
      {
        pattern: /\bgit\s+clean\b/i,
        name: "Git clean (remoção de arquivos não rastreados)"
      },
      {
        pattern: /\bgit\s+branch\s+-D\b/i,
        name: "Exclusão forçada de branch"
      },
      {
        pattern: /\bgit\s+(checkout|restore)\s+\./i,
        name: "Descartar alterações locais do git"
      },
      {
        pattern: /\b(push|reset)\s+--force\b/i,
        name: "Operações forçadas (--force)"
      }
    ];
    
    let isDangerous = false;
    let matchedRuleName = "";
    
    for (const rule of dangerousRules) {
      if (rule.pattern.test(cmd)) {
        isDangerous = true;
        matchedRuleName = rule.name;
        break;
      }
    }
    
    if (isDangerous) {
      // Se for perigoso, força a confirmação do usuário (force_ask)
      console.error(`[Safety Gate] Interceptado: "${cmd}" devido a "${matchedRuleName}"`);
      console.log(JSON.stringify({
        decision: "force_ask",
        reason: `Comando potencialmente perigoso detectado (${matchedRuleName}): "${cmd}"`
      }));
    } else {
      // Se for seguro (ex: git status, dir, mkdir, npm install, etc.), permite automaticamente
      console.log(JSON.stringify({
        decision: "allow"
      }));
    }
  } catch (err) {
    // Caso ocorra erro na análise, por segurança, força a pergunta
    console.error(`[Safety Gate] Erro na verificação: ${err.message}`);
    console.log(JSON.stringify({
      decision: "force_ask",
      reason: `Erro ao analisar segurança do comando: ${err.message}`
    }));
  }
}

main();
