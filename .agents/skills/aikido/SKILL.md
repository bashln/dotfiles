---
name: aikido
description: Executa varreduras SAST/segredos via Aikido Security MCP, consulta o feed de vulnerabilidades/SLA e gerencia autenticação/setup do plugin. Use quando o usuário pedir scan de segurança com Aikido, listar vulnerabilidades do feed, verificar segredos expostos, ou configurar o Aikido MCP.
---

# Aikido Security — Skill para Agentes

Integração oficial com as capacidades do [Aikido Security](https://aikido.dev) via MCP server (`aikido-mcp`). Permite analisar código gerado ou modificado contra vulnerabilidades SAST e segredos vazados, triar issues do feed com filtros de SLA e gerenciar o setup de autenticação.

---

## Modos de Operação

Esta skill opera em três fluxos principais:
1. **Scan de Código (`scan`)**: Varredura de código modificado ou gerado na sessão.
2. **Triagem de Issues (`issues`)**: Consulta ao feed de segurança centralizado da organização.
3. **Configuração e Conectividade (`setup`)**: Validação de ambiente e login idempotente.

---

## 1. Scan de Código (SAST & Segredos)

Execute após escrever/modificar código, antes de commits ou quando o usuário solicitar varredura de segurança.

### Workflow

1. **Identificar arquivos:** Selecione todos os arquivos criados, alterados ou tocados na sessão (via `git status` / `git diff` ou solicitação do usuário).
2. **Escolher ferramenta correta (otimização de contexto):**
   - **Arquivos em disco:** Use preferencialmente `aikido-mcp:aikido_scan_paths`. Passe apenas os caminhos dos arquivos (absolutos ou com `root`). **NUNCA leia o conteúdo dos arquivos para o prompt antes de chamar a ferramenta** — o servidor MCP lê os arquivos diretamente do disco, economizando contexto.
   - **Snippets em memória / diffs não salvos:** Use `aikido-mcp:aikido_full_scan` passando o conteúdo dos arquivos.
   - **Limite de lote:** Mantenha no máximo **50 arquivos por requisição**. Loteie em múltiplas chamadas se houver mais arquivos.
3. **Tratamento de Vulnerabilidades e Loop de Correção:**
   - Se encontrar problemas, relate claramente: título, descrição, severidade, arquivo e número de linhas.
   - Aplique as correções recomendadas pela remediação do Aikido.
   - **Fix-and-Rescan Loop (Circuit Breaker):**
     - Após aplicar as alterações, re-execute o scan (`aikido_scan_paths` ou `aikido_full_scan`) para confirmar a resolução e garantir que nenhum novo risco foi inserido.
     - Limite de parada: repita o ciclo de correção no máximo **3 tentativas**.
     - Se o alerta persistir após 3 tentativas e você puder justificar com clareza que se trata de falso positivo ou risco aceito com segurança, interrompa e informe o usuário. Caso contrário, pause e solicite orientação humana.
4. **Relatório final:** Confirme se o código está limpo ("All clear") ou liste itens pendentes com justificativa.

---

## 2. Triagem do Feed de Segurança (Issues)

Consulta e detalhamento de vulnerabilidades corporativas, dependências (SCA), contêineres e nuvem detectadas pelo Aikido.

### Workflow

1. **Listagem:** Chame `aikido-mcp:aikido_issues_list`.
2. **Escopo:** Passe filtros de escopo apenas se especificados pelo usuário ou contexto: `repo_name`, `repo_branch_name`, `cloud_name`, `vm_name`, `domain_name`, `container_name`, `team_name`, `workspace_name`.
3. **Tipos de Issue (`issue_types`):**
   - `sast` (análise estática de código)
   - `leaked_secret` (segredos expostos)
   - `open_source` (vulnerabilidades SCA / CVEs de dependências)
   - `iac` (infraestrutura como código)
   - `docker_container`, `cloud_instance`, `cloud`, `surface_monitoring`
   - `malware`, `eol` (pacotes descontinuados), `license`
4. **Filtros de SLA:**
   - `out_of_sla: true` para itens vencidos.
   - `sla_due_soon: true` para itens com SLA próximo ao vencimento.
5. **Paginação:**
   - O feed retorna 25 itens por página (`page` com índice zero).
   - Avance `page` apenas se o usuário pedir mais resultados.
6. **Detalhamento por ID:**
   - Se o usuário pedir para investigar um problema específico ou passar um `issue_id`, forneça `issue_id: "<id>"`.
   - *Nota:* O parâmetro `issue_id` sobrescreve outros filtros e retorna o detalhe profundo daquele item único.
7. **Formato de exibição dos achados:**
   ```
   Issue #<N>: <issue_title>
    - ID: <issue_id>
    - Issue type: <issue_type>
    - Severity: <issue_severity> (<issue_severity_label>)
    - Location: <issue_file>:<issue_start_line>
    - SLA due date: <issue_remediate_by_date>
    - Remediation: <issue_remediation>
   ```

---

## 3. Setup e Verificação de Autenticação

Use quando o usuário solicitar configuração, alternância de contas ou quando chamadas ao MCP falharem por falta de login.

### Workflow

1. **Pré-requisito obrigatório (Node.js):**
   - Execute `node --version`.
   - Se o Node.js não estiver instalado ou for inferior a `18.19.0`, pare e informe que o Node.js >= 18.19.0 é obrigatório para rodar o servidor MCP do Aikido.
2. **Verificação de Login:**
   - Chame `aikido-mcp:aikido_login` sem argumentos.
   - Se retornar "Already signed in", confirme que o plugin está ativo e pronto.
3. **Novo login / Troca de conta:**
   - Se `force_reauth: true` ou se não estiver logado, a ferramenta retornará uma URL de login.
   - Apresente a URL na íntegra ao usuário (sem alterar parâmetros de `state` ou `redirect_uri`).
   - Após o usuário efetuar login no navegador, chame `aikido-mcp:aikido_login` novamente para validar.

---

## Tratamento de Falhas do Servidor MCP

Se o servidor `aikido-mcp` não estiver disponível ou falhar na inicialização:
- Avise o usuário: *"O servidor Aikido MCP é necessário para esta operação, mas não está carregado no ambiente."*
- Oriente o usuário a verificar se o `aikido-mcp` está configurado nas opções MCP do cliente (ou no `opencode.json` / `.agents/gemini/mcp.toml` conforme o [mcp-bootstrap](file:///c:/Users/itinerario/Documents/leo/development/dotfiles/.agents/skills/mcp-bootstrap/SKILL.md)).

