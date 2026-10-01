;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-
;; Shell & PATH (cross-platform: pwsh on Windows, bash/fish on Linux)
(cond ((eq system-type 'windows-nt)
       ;; cmdproxy natively handles .cmd/.bat — required for LSP/npm on Windows.
       (let ((pwsh (or (executable-find "pwsh") (executable-find "powershell")))
             (cmdproxy (executable-find "cmdproxy")))
         (setq shell-file-name (or cmdproxy "cmdproxy.exe"))
         (setq-default explicit-shell-file-name (or pwsh "cmdproxy.exe"))
         (setq-default vterm-shell (or pwsh "cmdproxy.exe"))))
      (t
       (setq shell-file-name (or (executable-find "bash") "/bin/bash"))
       (setq-default explicit-shell-file-name (or (executable-find "fish") (executable-find "bash") "/bin/bash"))
       (setq-default vterm-shell (or (executable-find "fish") (executable-find "bash") "/bin/bash"))))

;; Windows: o Emacs não traz `diff`. apheleia (aplica o resultado via patch
;; RCS `diff --rcs`) e diff-hl-flydiff (gutter) dependem dele. Git for Windows
;; fornece diff/patch em <git>/usr/bin. Windows-only: Linux intocado.
(when (eq system-type 'windows-nt)
  (when-let* ((git (executable-find "git")))
    (let ((git-usr-bin (expand-file-name
                        "../usr/bin" (file-name-directory git))))
      (when (and (file-directory-p git-usr-bin)
                 (not (member git-usr-bin exec-path)))
        (push git-usr-bin exec-path)))))

;; Windows: `M-x doom/reload' exporta a env EMACS escapando espacos com "\ "
;; (escape de shell POSIX). O PowerShell nao entende e o sync falha com
;; "...emacs nao e reconhecido...". Normaliza a env so durante o reload.
(when (eq system-type 'windows-nt)
  (require 'cl-lib)
  (defun +leo/win-normalize-emacs-env (value)
    "Corrige o valor de $EMACS setado por `doom/reload' no Windows."
    (when (and (stringp value)
               (string-match-p (regexp-quote "\\ ") value))
      (setq value (replace-regexp-in-string (regexp-quote "\\ ") " " value))
      (unless (file-exists-p value)
        (let ((exe (concat value ".exe")))
          (when (file-exists-p exe)
            (setq value exe)))))
    value)

  (defun +leo/doom-reload-emacs-env-a (old-fn &rest args)
    "Corrige $EMACS antes de `doom/reload' (Windows + PowerShell)."
    (let ((orig-setenv (symbol-function #'setenv)))
      (cl-letf (((symbol-function #'setenv)
                 (lambda (var &optional value)
                   (funcall orig-setenv
                            var
                            (if (equal var "EMACS")
                                (+leo/win-normalize-emacs-env value)
                              value)))))
        (apply old-fn args))))

  (when (fboundp 'doom/reload)
    (advice-add 'doom/reload :around #'+leo/doom-reload-emacs-env-a)))

;; Go tools PATH (cross-platform)
(let* ((home (or (getenv "HOME") (getenv "USERPROFILE") ""))
       (go-bin (expand-file-name "go/bin" home)))
  (when (file-directory-p go-bin)
    (setenv "PATH" (concat go-bin (path-separator) (or (getenv "PATH") "")))
    (push go-bin exec-path)))

;; Fontes
(let ((font-family (if (eq system-type 'windows-nt) "JetBrainsMono NF" "JetBrainsMono Nerd Font")))
  (setq doom-font (font-spec :family font-family :size 12)
        doom-variable-pitch-font (font-spec :family font-family :size 12)))

;; Tema
;; (setq doom-theme 'doom-rose-pine-moon)
;; ----------------------------------------------------------------------------
;; REQUISITOS DO SISTEMA
;; ----------------------------------------------------------------------------
;; LSP, Formatters, Linters - ver README do projeto
;; -------------------------------
;; 1. ORG MODE CUSTOMIZATIONS
;; -------------------------------
(after! org
  (setq org-default-notes-file (expand-file-name "inbox.org" org-directory)
        org-ellipsis " ◉ "
        org-log-done 'time
        org-log-into-drawer t
        org-hide-emphasis-markers t
        org-todo-keywords
        '((sequence "TODO(t)" "IN-PROGRESS(i)" "WAIT(w)" "PROJ(p)" "|" "DONE(d)" "CANCELLED(c)")))
  (add-to-list 'org-modules 'org-habit)
  (add-to-list 'org-modules 'org-tempo))

;; Custom bullets - org-modern configuration (used by +pretty flag)
(setq org-modern-star 'replace
      org-modern-replace-stars '("◉" "○" "✸" "✿" "◉" "○")
      org-modern-hide-stars nil)

(use-package! org-auto-tangle
  :hook (org-mode . org-auto-tangle-mode)
  :config (setq org-auto-tangle-default t))

(map! :leader :desc "Org babel tangle" "m B" #'org-babel-tangle)

(after! ispell
  (setq ispell-program-name "hunspell"
        ispell-dictionary "pt_BR"
        ispell-async-preparse-characters "–")  ; hyphen
  (unless (assoc "pt_BR" ispell-local-dictionary-alist)
    (add-to-list 'ispell-local-dictionary-alist
                 '("pt_BR" "[[:alpha:]]" "[^[:alpha:]]" "[']" t
                   ("-d" "pt_BR") nil utf-8))))

;; -------------------------------
;; 3. DESENVOLVIMENTO & LSP
;; -------------------------------
;; Typescript/Web defaults
(after! typescript-mode
  (setq typescript-indent-level 2))

(after! web-mode
  (setq web-mode-markup-indent-offset 2
        web-mode-css-indent-offset 2
        web-mode-code-indent-offset 2))

;; Treesitter Auto Install — compila localmente com MSYS2 GCC
(let ((msys2-bin "C:/msys64/ucrt64/bin"))
  (push msys2-bin exec-path)
  (setenv "PATH" (concat msys2-bin ";" (getenv "PATH"))))

;; Patch LANGUAGE_VERSION para compatibilidade com Emacs 30 ABI (ABI 15 -> 14)
(defadvice! +treesit-patch-abi-a (old-fn out-dir lang url &optional revision source-dir cc c++)
  "Patch LANGUAGE_VERSION to ABI 14 before building grammar."
  :around #'treesit--install-language-grammar-1
  (let* ((lang-sym (if (symbolp lang) lang (intern lang)))
         (clone-dir (make-temp-file "treesit-patched" t))
         (workdir (expand-file-name "repo" clone-dir)))
    (unwind-protect
        (progn
          (if revision
              (treesit--call-process-signal
               "git" nil t nil "clone" url "--depth" "1" "--quiet"
               "-b" revision workdir)
            (treesit--call-process-signal
             "git" nil t nil "clone" url "--depth" "1" "--quiet" workdir))
          (let ((src-dir (expand-file-name (or source-dir "src") workdir)))
            (dolist (f '("parser.c" "scanner.c" "scanner.cc"))
              (let ((fp (expand-file-name f src-dir)))
                (when (file-exists-p fp)
                  (with-temp-buffer
                    (insert-file-contents fp)
                    (goto-char (point-min))
                    (when (re-search-forward
                           "#define LANGUAGE_VERSION \\([0-9]+\\)" nil t)
                      (let ((old (match-string 1)))
                        (replace-match "14" nil nil nil 1)
                        (write-region (point-min) (point-max) fp nil 'quiet)
                        (message "Patched %s %s: %s -> 14"
                                 lang-sym f old))))))))
          (apply old-fn out-dir lang-sym workdir revision source-dir cc c++))
      (ignore-errors (delete-directory clone-dir t)))))

(use-package! treesit-auto
  :config
  (setq treesit-auto-install 'treesit-auto-install-compile)
  (global-treesit-auto-mode))

;; FIX: Kotlin Tree-sitter Grammar — registra fonte e auto-instala se ausente
(after! treesit
  (setq treesit-font-lock-level 4)
  (add-to-list 'treesit-language-source-alist
               '(kotlin "https://github.com/fwcd/tree-sitter-kotlin"))
  (when (fboundp 'treesit-language-available-p)
    (unless (treesit-language-available-p 'kotlin)
      (message "Kotlin treesit grammar ausente. Instale manualmente com M-x treesit-install-language-grammar"))))

(after! smartparens
  (remove-hook 'doom-first-buffer-hook #'smartparens-global-mode)
  (smartparens-global-mode -1)
  (add-hook 'prog-mode-hook #'smartparens-mode))

;; Copilot - FIX: Não conflita com corfu
(use-package! copilot
  :commands (copilot-mode)
  :bind (:map copilot-completion-map
              ;; MUDANÇA: Use C-j ao invés de TAB para não conflitar com corfu
              ("<backtab>" . 'copilot-accept-completion))
  ;; ("C-M-TAB" . 'copilot-accept-completion-by-word))
  :config
  (setq copilot-indent-offset-warning-disable t)
  (add-to-list 'copilot-indentation-alist '(prog-mode 2))
  (map! :leader "t C" #'copilot-mode))  ; `t c` é do Doom (fill-column-indicator)

(use-package! kdl-mode
  :mode "\\.kdl\\'")

;; -------------------------------
;; 3. COMPLETION CUSTOMIZATIONS (Vertico/Corfu)
;; -------------------------------
;; Apenas o que diverge dos defaults do módulo :completion corfu (+orderless).
;; `corfu-auto`, cycle, preselect, quit-no-match, popupinfo-delay e os keymaps
;; TAB/S-TAB já vêm do módulo corfu e de :config default.
(after! corfu
  (setq corfu-auto-delay 0.05
        corfu-auto-prefix 1
        corfu-popupinfo-max-height 6))

(after! eldoc
  (setq eldoc-echo-area-use-multiline-p nil
        eldoc-display-functions '(eldoc-display-in-echo-area)))

;; `SPC b b` (switch buffer) e `SPC f r` (recent files -> consult-recent-file)
;; já são nativos do Doom/vertico.

(map! "C-." #'embark-act)

;; -------------------------------
;; 5. FORMATAÇÃO & AUTO-SAVE
;; -------------------------------
;; Trim de trailing whitespace vem do módulo nativo :editor whitespace (+trim,
;; via ws-butler). `require-final-newline` e `org-startup-indented` já são
;; defaults do core do Doom e do módulo :lang org, respectivamente.

;; FIX Windows: apheleia roda os formatters prettier-* via helper `apheleia-npx`
;; (script com shebang `#!/usr/bin/env bash`). No Windows o apheleia prefixa o
;; interpretador da shebang e chama `bash`, que resolve pro WSL (sem distro
;; instalada) e falha com "Failed to run bash: exit status 1". Aqui rodamos
;; `node` + prettier.cjs direto, sem shell. Restrito ao Windows: o Linux
;; (mesma config versionada) fica inalterado.
(when (eq system-type 'windows-nt)
  (after! apheleia
    (dolist (name '(prettier prettier-css prettier-html prettier-graphql
                    prettier-javascript prettier-json prettier-json-stringify
                    prettier-markdown prettier-ruby prettier-scss
                    prettier-svelte prettier-typescript prettier-yaml))
      (let ((cmd (alist-get name apheleia-formatters)))
        (when (and (consp cmd) (equal (car cmd) "apheleia-npx"))
          (setf (alist-get name apheleia-formatters)
                (append
                 (list "node"
                       ;; prettier do projeto tem prioridade; senão o global.
                       (or (when-let* ((proj (locate-dominating-file
                                              default-directory "node_modules")))
                             (let ((p (expand-file-name
                                       "node_modules/prettier/bin/prettier.cjs" proj)))
                               (when (file-exists-p p) p)))
                           (expand-file-name
                            "npm/node_modules/prettier/bin/prettier.cjs"
                            (or (getenv "APPDATA") (getenv "USERPROFILE") ""))))
                 (cddr cmd))))))))

;; -------------------------------
;; 4. LSP TUNING & BOOSTER
;; -------------------------------
(after! lsp-mode
  (setq lsp-go-use-gofumpt t
        lsp-go-analyses '((nilness . t) (unusedparams . t) (unusedwrite . t))
        lsp-use-plists t
        lsp-idle-delay 0.500
        lsp-log-io nil
        lsp-enable-file-watchers nil
        lsp-headerline-breadcrumb-enable nil))

(after! lsp-eslint
  (setq lsp-eslint-enable t
        lsp-eslint-auto-fix-on-save nil
        lsp-eslint-run "onType"))

(after! lsp-sqls
  (setq lsp-sqls-workspace-config '((formatter (language "sql" (indent 2))) (lint (colon true)) (connections ())))
  (add-hook 'sql-mode-hook #'lsp-deferred))

;; Emacs LSP Booster
(defun lsp-booster--advice-json-parse (old-fn &rest args)
  "Try to parse bytecode instead of json."
  (or
   (when (equal (following-char) ?#)
     (let ((bytecode (read (current-buffer))))
       (when (byte-code-function-p bytecode)
         (funcall bytecode))))
   (apply old-fn args)))

(when (fboundp (if (progn (require 'json nil t) (fboundp 'json-parse-buffer)) 'json-parse-buffer 'json-read))
  (advice-add (if (progn (require 'json nil t) (fboundp 'json-parse-buffer)) 'json-parse-buffer 'json-read)
              :around #'lsp-booster--advice-json-parse))

(defun lsp-booster--advice-final-command (old-fn cmd &optional test?)
  "Prepend emacs-lsp-booster command to lsp CMD."
  (let ((orig-result (funcall old-fn cmd test?)))
    (if (and (not test?)
             (not (file-remote-p default-directory))
             lsp-use-plists
             (not (functionp 'json-rpc-connection))
             (executable-find "emacs-lsp-booster"))
        (cons "emacs-lsp-booster" orig-result)
      orig-result)))

(when (fboundp 'lsp-resolve-final-command)
  (advice-add 'lsp-resolve-final-command :around #'lsp-booster--advice-final-command))

;; I/O Tuning
(setq read-process-output-max (* 1024 1024))
(setenv "LSP_USE_PLISTS" "true")

;; -------------------------------
;; 7. EXTRA TOOLS & KEYBINDINGS
;; -------------------------------
;; vterm: Doom já binda `SPC o t` (+vterm/toggle) e `SPC o T` (+vterm/here).

;; Treemacs (Doom nativo: `SPC o p` toggle, `SPC o P` find file)
(after! treemacs
  ;; Navegação tipo Neovim no treemacs
  (map! :map treemacs-mode-map
        :n "h" #'treemacs-COLLAPSE-project   ;; Colapsar/ir para parent (como 'h' no nvim-tree)
        :n "l" #'treemacs-RET-action        ;; Expandir/entrar (como 'l' no nvim-tree)
        :n "<backspace>" #'treemacs-goto-parent-node  ;; Subir um nível
        :n "<return>" #'treemacs-RET-action ;; Enter para abrir
        :n "r" #'treemacs-rename-file       ;; Rename rápido
        :n "d" #'treemacs-delete-file       ;; Delete rápido
        :n "c" #'treemacs-create-file        ;; Criar arquivo
        :n "C" #'treemacs-create-directory   ;; Criar diretório
        :n "y" #'treemacs-copy-file          ;; Copiar
        :n "Y" #'treemacs-copy-absolute-path-at-point ;; Copiar path
        :n "s" #'treemacs-visit-node-ace     ;; Abrir em split
        :n "v" #'treemacs-visit-node-ace-horizontal ;; Abrir em vsplit
        :n "w" #'treemacs-set-width))

;; Search files with fd (Telescope-like)
(map! :leader
      :desc "Search files (fd)" "s z" #'consult-fd)

;; Dired/dirvish já são nativos: `SPC o -` (dired-jump), `SPC o /` (dirvish),
;; `SPC o p` (dirvish-side).

;; Otimização de Garbage Collection (GCMH)
(use-package! gcmh
  :hook (after-init . gcmh-mode)
  :config
  (setq gcmh-idle-delay 5
        gcmh-high-cons-threshold (* 16 1024 1024)))

;; Scrolling (`fast-but-imprecise-scrolling' já é default do core do Doom)
(setq scroll-conservatively 101
      scroll-margin 5
      scroll-preserve-screen-position t
      auto-window-vscroll nil)

;; Personal Keybindings
(map! :leader
      :desc "Kill buffer (force)" "b D" #'kill-buffer-and-window)

;; Navegação de janelas: `C-w h/j/k/l/w/c/o` já vêm do evil-window-map.

;; Mover linha ou região usando ALT + J e ALT + K, similar ao comportamento do Neovim
(defun +leo/move-line-up ()
  "Move the current line up by one."
  (interactive)
  (transpose-lines 1)
  (forward-line -2))

(defun +leo/move-line-down ()
  "Move the current line down by one."
  (interactive)
  (forward-line 1)
  (transpose-lines 1)
  (forward-line -1))

(defun +leo/move-text-up ()
  "Move region up, or current line up if no region is active."
  (interactive)
  (if (use-region-p)
      (let* ((beg (region-beginning))
             (end (region-end))
             (text (delete-and-extract-region beg end)))
        ;; vai pra linha anterior e insere
        (goto-char beg)
        (forward-line -1)
        (let ((new-beg (point)))
          (insert text)
          ;; reativa a região no novo lugar
          (set-mark new-beg)
          (goto-char (+ new-beg (length text)))
          (setq deactivate-mark nil)))
    (+leo/move-line-up)))

(defun +leo/move-text-down ()
  "Move region down, or current line down if no region is active."
  (interactive)
  (if (use-region-p)
      (let* ((beg (region-beginning))
             (end (region-end))
             (text (delete-and-extract-region beg end)))
        (goto-char beg)
        (forward-line 1)
        (let ((new-beg (point)))
          (insert text)
          (set-mark new-beg)
          (goto-char (+ new-beg (length text)))
          (setq deactivate-mark nil)))
    (+leo/move-line-down)))

(map! :nvi "M-j" #'+leo/move-text-down
      :nvi "M-k" #'+leo/move-text-up)

;; -------------------------------
;; 8. NEOVIM PARITY & BEHAVIORS
;; -------------------------------
;; Clipboard: p e x não sobrescrevem registro principal
(setq evil-kill-on-visual-paste nil) ;; p no visual mode não mata o registro

(map! :n "x" "\"_x")                ;; x deleta para o black hole register

;; Indent visual com reselect já vem do módulo evil (+evil/shift-left/right).

;; Harpoon (Quick file access)
(use-package! harpoon
  :config
  (map! :leader
        :desc "Harpoon toggle"       "j t" #'harpoon-toggle-file
        :desc "Harpoon list"         "j l" #'harpoon-toggle-quick-menu
        :desc "Harpoon 1"            "j 1" #'harpoon-go-to-1
        :desc "Harpoon 2"            "j 2" #'harpoon-go-to-2
        :desc "Harpoon 3"            "j 3" #'harpoon-go-to-3
        :desc "Harpoon 4"            "j 4" #'harpoon-go-to-4))

;; Trouble-like (Diagnostics): use o prefixo nativo `SPC c x` (+default/diagnostics)
;; e `SPC x` (scratch buffer) do Doom.

;; Popup Rules (Trouble-like Panel)
(set-popup-rule! "^\\*Flycheck errors\\*$" :side 'bottom :size 0.25 :select nil :quit nil :ttl nil)

(after! flycheck
  (setq flycheck-global-modes nil))

;; `SPC c r` (lsp-rename) já é nativo do Doom.

;; =============================================================================
;; NEOVIM FULL PARITY - NOVAS CONFIGURAÇÕES
;; =============================================================================
;; -----------------------------
;; 9. DIRVISH - FILE MANAGER OIL.NVIM-LIKE
;; -----------------------------
;; 100% nativo no módulo `:emacs dired +dirvish`: pacote, hook
;; `dirvish-override-dired-mode`, atributos e keymaps (`h`/`l`, TAB, `?`, `q`,
;; `b`, `F`, prefixos `y`/`s`). Atalhos de líder: `SPC o /` (dirvish),
;; `SPC o -` (dired-jump), `SPC o p` (dirvish-side), `SPC o P`
;; (+dired/dirvish-side-and-follow).

;; -----------------------------
;; 10. MARKDOWN FOLDING (Neovim zj/zk/zl/zu/zi)
;; -----------------------------
(defun +markdown-fold-level (level)
  "Fold all markdown headings of LEVEL or above."
  (interactive "nFold level (1-6): ")
  (save-excursion
    (widen) (outline-show-all) (outline-hide-sublevels level) (recenter)))

(defun +markdown-fold-unfold ()
  "Unfold all headings."
  (interactive)
  (save-excursion
    (widen) (outline-show-all) (recenter)))

(defun +markdown-fold-toggle-current ()
  "Toggle fold on current heading."
  (interactive)
  (save-excursion
    (outline-back-to-heading) (outline-toggle-children) (recenter)))

(after! markdown-mode
  (add-hook 'markdown-mode-hook #'outline-minor-mode)
  (map! :map markdown-mode-map
        :nv "zj" (lambda () (interactive) (+markdown-fold-level 1))
        :nv "zk" (lambda () (interactive) (+markdown-fold-level 2))
        :nv "zl" (lambda () (interactive) (+markdown-fold-level 3))
        :nv "z;" (lambda () (interactive) (+markdown-fold-level 4))
        :nv "zu" #'+markdown-fold-unfold
        :nv "zi" #'+markdown-fold-toggle-current
        :nv "zo" #'outline-show-subtree
        :nv "zc" #'outline-hide-subtree)
  (setq-hook! 'markdown-mode-hook
    outline-regexp "^#\\{1,6\\}\\s-"
    outline-level (lambda () (1- (length (match-string 0))))))

;; -----------------------------
;; 11. AUTOCMDS (LazyVim parity)
;; -----------------------------
;; `q` fecha buffers de utilidade nativamente: `special-mode' já binda
;; `q`->quit-window (help/info/apropos/compilation) e evil-collection idem.

;; Conceallevel para arquivos específicos
(setq-hook! 'json-mode-hook conceal-level 0)

;; -----------------------------
;; 12. INCREMENTAL RENAME (Inc-replace)
;; -----------------------------
(use-package! iedit
  :defer t
  :config
  (setq iedit-auto-save-occurrence-in-kill-ring nil)
  ;; Keymaps para iedit
  (map! :n "g." #'iedit-mode
        :map iedit-mode-keymap
        "C-n" #'iedit-next-occurrence
        "C-p" #'iedit-prev-occurrence
        "C-g" #'iedit-quit
        "ESC" #'iedit-quit))

;; Inc-rename com preview em tempo real (`c D` é +lookup/references no Doom).
(map! :leader
      :desc "Incremental rename (iedit)" "c R" #'iedit-mode)

;; -----------------------------
;; 13. DIFF-HL (Git gutter)
;; -----------------------------
;; 100% nativo no módulo `:ui vc-gutter +pretty`: hooks (global-diff-hl-mode,
;; diff-hl-dired-mode, flydiff) e atalhos de hunk em `SPC g` (`g s` stage,
;; `g r` revert, `g ]` next, `g [` prev), além de `]d`/`[d`.

;; -----------------------------
;; 15. EVIL-ESCAPE (jk/kj)
;; -----------------------------
(use-package! evil-escape
  :after evil
  :config
  (setq evil-escape-key-sequence "jk"
        evil-escape-delay 0.1
        evil-escape-unordered-key-sequence t))

;; -----------------------------
;; 16. PULSAR (Highlight após movimentos)
;; -----------------------------
(use-package! pulsar
  ;; Desativado por padrao durante investigacao de lentidao em arquivos sob /mnt/*.
  ;; :hook (after-init . pulsar-global-mode)
  :config
  (setq pulsar-delay 0.05
        pulsar-iterations 10
        pulsar-face 'pulsar-magenta)
  ;; Mantem a lista pronta caso o modo seja reativado depois.
  (add-to-list 'pulsar-pulse-functions 'evil-scroll-page-down)
  (add-to-list 'pulsar-pulse-functions 'evil-scroll-page-up)
  (add-to-list 'pulsar-pulse-functions 'recenter-top-bottom)
  (add-to-list 'pulsar-pulse-functions 'evil-goto-mark))

;; -----------------------------
;; 17. CONSULT-DIR (Navegação rápida)
;; -----------------------------
;; Nativo no módulo vertico: `consult-dir-project-list-function`, remap de
;; `list-directory` e atalhos `C-x C-d` / `C-x C-j`.

;; -----------------------------
;; 18. PATH NAVIGATION (Windows/UNC)
;; -----------------------------
(defun +path-normalize (path)
  "Normalize PATH for cross-platform compatibility."
  (when path
    (let ((normalized (expand-file-name path)))
      ;; Handle UNC paths
      (when (and (> (length normalized) 2)
                 (string= (substring normalized 0 2) "//"))
        (setq normalized (concat "\\\\" (substring normalized 2))))
      ;; Normalize separators only for Windows-style paths.
      (if (or (eq system-type 'windows-nt)
              (+path-unc-p normalized))
          (replace-regexp-in-string "/" "\\\\" normalized)
        normalized))))

(defun +path-unc-p (path)
  "Check if PATH is a UNC path."
  (and path
       (> (length path) 2)
       (or (string= (substring path 0 2) "\\\\")
           (string= (substring path 0 2) "//"))))

(defun +path-directory-exists-p (path)
  "Check if directory exists (handles UNC paths)."
  (when path
    (or (file-directory-p path)
        (and (+path-unc-p path)
             (file-directory-p (+path-normalize path))))))

(defun +browse-directory (dir)
  "Browse directory with Dirvish, handling UNC/Windows paths."
  (interactive "DDirectory: ")
  (let ((normalized (+path-normalize dir)))
    (if (+path-directory-exists-p normalized)
        (dirvish normalized)
      (message "Directory not found: %s" normalized))))

(defun +browse-current-directory ()
  "Browse current file's directory (handles UNC paths)."
  (interactive)
  (let ((dir (file-name-directory (or buffer-file-name default-directory))))
    (+browse-directory dir)))

(map! :leader
      :desc "Browse directory" "f b" #'+browse-directory
      :desc "Browse current dir" "f B" #'+browse-current-directory)

;; -----------------------------
;; 20. QOL FINAL ADJUSTMENTS
;; -----------------------------
;; Better help display
(setq which-key-idle-delay 0.4
      which-key-idle-secondary-delay 0.1
      which-key-max-display-columns 6
      which-key-min-display-lines 4)

;; Auto-save improvements (`auto-save-default' já é do core do Doom)
(setq auto-save-interval 300
      auto-save-timeout 30)

;; `consult-fd-args' já é configurado pelo módulo vertico (com suporte Windows).

;; Popup rules: dirvish já é tratado pelo módulo dired.
(set-popup-rule! "^\*harpoon" :side 'bottom :size 0.25 :select t)

;; As faces do org migraram para custom.el (custom-file do Doom).

