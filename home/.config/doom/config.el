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

;; Go tools PATH (cross-platform)
(let* ((home (or (getenv "HOME") (getenv "USERPROFILE") ""))
       (go-bin (expand-file-name "go/bin" home)))
  (when (file-directory-p go-bin)
    (setenv "PATH" (concat go-bin (path-separator) (or (getenv "PATH") "")))
    (push go-bin exec-path)))

;; Fontes
(let ((font-family (if (eq system-type 'windows-nt) "BlexMono Nerd Font" "JetBrainsMono Nerd Font")))
  (setq doom-font (font-spec :family font-family :size 14)
        doom-variable-pitch-font (font-spec :family font-family :size 14)))

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
  (map! :leader "t c" #'copilot-mode))

(use-package! kdl-mode
  :mode "\\.kdl\\'")

;; -------------------------------
;; 3. COMPLETION CUSTOMIZATIONS (Vertico/Corfu)
;; -------------------------------
(after! corfu
  (setq corfu-auto t
        corfu-auto-delay 0.05
        corfu-auto-prefix 1
        corfu-cycle t
        corfu-quit-no-match 'separator
        corfu-preselect 'prompt
        corfu-popupinfo-delay 0.5
        corfu-popupinfo-max-height 6)
  (map! :map corfu-map
        "TAB" #'corfu-next
        [tab] #'corfu-next
        "S-TAB" #'corfu-previous
        [backtab] #'corfu-previous))

(after! orderless
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles basic partial-completion)))))

(after! eldoc
  (setq eldoc-echo-area-use-multiline-p nil
        eldoc-display-functions '(eldoc-display-in-echo-area)))

(map! :leader
      "b b" #'consult-buffer
      "f r" #'consult-recent-file)
(map! "C-." #'embark-act)

;; -------------------------------
;; 5. FORMATAÇÃO & AUTO-SAVE
;; -------------------------------

;; Hooks de Limpeza (Igual ao Nvim)
(add-hook 'before-save-hook 'delete-trailing-whitespace)
(setq require-final-newline t)

;; Org-mode: indentação automática (não precisa de formatter externo)
(setq org-startup-indented t)

;; Auto-format on save via módulo :editor format (doom já faz isso)
;; Apenas prioritizamos linguagens específicas
(setq-hook! 'lua-mode-hook +format-with-lsp nil)
(setq-hook! 'python-mode-hook +format-with-lsp nil)

;; Windows: apheleia chama prettier direto (sem apheleia-npx bash script)
(when (eq system-type 'windows-nt)
  (after! apheleia
    (setf (alist-get 'prettier apheleia-formatters)
          '("prettier" "--stdin-filepath" filepath
            (apheleia-formatters-js-indent "--use-tabs" "--tab-width")))
    (setf (alist-get 'prettier-javascript apheleia-formatters)
          '("prettier" "--stdin-filepath" filepath
            "--parser=babel-flow"
            (apheleia-formatters-js-indent "--use-tabs" "--tab-width")))
    (setf (alist-get 'prettier-typescript apheleia-formatters)
          '("prettier" "--stdin-filepath" filepath
            "--parser=typescript"
            (apheleia-formatters-js-indent "--use-tabs" "--tab-width")))))

;; -------------------------------
;; 4. LSP TUNING & BOOSTER
;; -------------------------------

(defvar +lsp-ensure-typescript-h nil)
(setq +lsp-ensure-typescript-h
      (lambda ()
        "Only start LSP if TypeScript is available in the project."
        (or (locate-dominating-file (or (buffer-file-name) default-directory) "node_modules/typescript")
            (locate-dominating-file (or (buffer-file-name) default-directory) ".git"))))

(defun +lsp-run-if-project-ready-a (old-fn &rest args)
  "Run OLD-FN only when the current project is ready for LSP."
  (when (funcall +lsp-ensure-typescript-h)
    (apply old-fn args)))

(after! lsp-mode
  (when (and (fboundp 'lsp!)
             (not (advice-member-p #'+lsp-run-if-project-ready-a 'lsp!)))
    (advice-add 'lsp! :around #'+lsp-run-if-project-ready-a))

  (setq lsp-go-use-gofumpt t
        lsp-go-analyses '((nilness . t) (unusedparams . t) (unusedwrite . t))
        lsp-use-plists t
        lsp-idle-delay 0.500
        lsp-log-io nil
        lsp-enable-file-watchers nil
        lsp-completion-provider :none
        lsp-headerline-breadcrumb-enable nil
        +format-with-lsp nil))

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

;; Toggle vterm (Toggleterm equivalent)
(map! :leader
      :desc "Toggle vterm" "t v" #'+vterm/toggle)

;; Treemacs (Doom default SPC o p)
;; Configuração Neovim-like: SPC e para toggle, h/l para navegar, backspace para subir
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
        :n "w" #'treemacs-set-width)

  ;; Abrir/fechar treemacs com SPC e (como nvim-tree)
  (map! :leader
        :desc "Toggle Treemacs (Neovim-style)" "e" #'treemacs))

;; Search files with fd (Telescope-like)
(map! :leader
      :desc "Search files (fd)" "s z" #'consult-fd)

;; File explorer atalhos (Neovim-style)
(map! :leader
      :desc "Dired here (Oil.nvim style)" "f e" #'dired-jump
      :desc "Dired at root" "f E" (lambda () (interactive) (dired (or (projectile-project-root) default-directory))))

;; Otimização de Garbage Collection (GCMH)
(use-package! gcmh
  :hook (after-init . gcmh-mode)
  :config
  (setq gcmh-idle-delay 5
        gcmh-high-cons-threshold (* 16 1024 1024)))

;; Otimização de Scrolling
(setq fast-but-imprecise-scrolling t)
(setq scroll-conservatively 101
      scroll-margin 5
      scroll-preserve-screen-position t
      auto-window-vscroll nil)

;; Personal Keybindings

;; Buffer management (Neovim-style: SPC b d para delete, SPC b D para delete force)
(map! :leader
      :desc "Kill buffer (force)" "b D" #'kill-buffer-and-window
      :desc "Kill other buffers" "b O" #'doom/kill-other-buffers)

(defun +leo/windows-mounted-path-p (&optional path)
  "Return non-nil when PATH points to a Windows-mounted /mnt filesystem."
  (let ((target (if path (expand-file-name path) (or buffer-file-name default-directory))))
    (and target
         (string-prefix-p "/mnt/" target))))

;; Navegação de janelas tipo Neovim (C-w hjkl)
(map! :n "C-w h" #'evil-window-left
      :n "C-w j" #'evil-window-down
      :n "C-w k" #'evil-window-up
      :n "C-w l" #'evil-window-right
      :n "C-w w" #'evil-window-next
      :n "C-w c" #'evil-window-delete
      :n "C-w o" #'doom/window-maximize-buffer)

;; Dired com navegação tipo Oil.nvim
(after! dired
  (setq dired-dwim-target t)
  (map! :map dired-mode-map
        :n "h" #'dired-up-directory
        :n "l" #'dired-find-file
        :n "<backspace>" #'dired-up-directory
        :n "." #'dired-hide-details-mode
        :n "y" #'dired-copy-filename-as-kill
        :n "Y" #'dired-do-copy
        :n "d" #'dired-do-delete
        :n "D" #'dired-do-delete
        :n "r" #'dired-do-rename
        :n "c" #'dired-do-copy
        :n "m" #'dired-mark
        :n "u" #'dired-unmark
        :n "U" #'dired-unmark-all-marks
        :n "v" #'dired-view-file
        :n "s" #'dired-sort-toggle-or-edit))

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

;; Visual Mode: Indent com reselect (como no Neovim)
(map! :v "<" (lambda () (interactive) (evil-shift-left (region-beginning) (region-end)) (evil-normal-state) (evil-visual-restore))
      :v ">" (lambda () (interactive) (evil-shift-right (region-beginning) (region-end)) (evil-normal-state) (evil-visual-restore)))

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

;; Trouble-like (Diagnostics)
(map! :leader
      (:prefix-map ("x" . "diagnostics/trouble")
       :desc "Document diagnostics" "x" #'consult-lsp-diagnostics
       :desc "Project diagnostics"  "X" (lambda () (interactive) (consult-lsp-diagnostics t))
       :desc "Flycheck list"        "l" #'flycheck-list-errors))

;; Popup Rules (Trouble-like Panel)
(set-popup-rule! "^\\*Flycheck errors\\*$" :side 'bottom :size 0.25 :select nil :quit nil :ttl nil)

(after! flycheck
  (setq flycheck-global-modes nil))
(map! :leader
      :desc "LSP Rename (Inc Rename)" "c r" #'lsp-rename)

;; =============================================================================
;; NEOVIM FULL PARITY - NOVAS CONFIGURAÇÕES
;; =============================================================================

;; -----------------------------
;; 9. DIRVISH - FILE MANAGER OIL.NVIM-LIKE
;; -----------------------------
;; NOTA: Configurado para trabalhar junto com o módulo :emacs dired
(use-package! dirvish
  :commands (dirvish dirvish-quick-access dirvish-side)
  :init
  ;; Ativar dirvish ao entrar em dired, adicionando o hook ao final da lista.
  (add-hook 'dired-mode-hook #'dirvish-override-dired-mode t)
  :config
  (setq dirvish-attributes '(vc-state subtree-state all-the-icons collapse))
  (setq dirvish-mode-line-format '(:left (sort symlink) :right (omit yank index)))
  (setq dirvish-subtree-state-style 'arrow)

  ;; Keymaps Oil.nvim-like
  (map! :map dirvish-mode-map
        :n "h" #'dirvish-up-directory           ;; Subir diretório
        :n "l" #'dirvish-find-file             ;; Entrar/arquivo
        :n "<backspace>" #'dirvish-up-directory ;; Subir (como no nvim-tree)
        :n "q" #'dirvish-quit                   ;; Fechar com q
        :n "y" #'dirvish-copy-file-path         ;; Copiar path
        :n "Y" #'dirvish-yank-paths             ;; Yank múltiplos
        :n "d" #'dirvish-delete-files           ;; Deletar
        :n "r" #'dirvish-rename-file            ;; Renomear
        :n "c" #'dirvish-create-file            ;; Criar arquivo
        :n "C" #'dirvish-create-directory       ;; Criar diretório
        :n "." #'dired-hide-details-mode         ;; Toggle detalhes
        :n "TAB" #'dirvish-subtree-toggle       ;; Expandir/colapsar
        :n "<return>" #'dirvish-find-file      ;; Enter
        :n "v" #'dirvish-preview-toggle         ;; Toggle preview
        :n "s" #'dirvish-split-file-here        ;; Abrir em split
        :n "S" #'dirvish-vsplit-file-here       ;; Abrir em vsplit
        :n "g." #'dired-omit-mode)              ;; Toggle hidden files

  ;; Atalhos de líder
  (map! :leader
        :desc "Dirvish here (Oil style)" "-" (lambda () (interactive) (dirvish (or default-directory "~")))
        :desc "Dirvish side panel" "o d" #'dirvish-side
        :desc "Dirvish quick access" "f a" #'dirvish-quick-access))

;; Dired subtree (expandir/colapsar diretórios)
(use-package! dired-subtree
  :after dired
  :config
  (setq dired-subtree-use-backgrounds nil)
  (map! :map dired-mode-map
        :n "TAB" #'dired-subtree-toggle
        :n "<backtab>" #'dired-subtree-remove))

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

;; Fechar buffers de utilidade com 'q'
(defun +close-buffer-with-q ()
  "Close buffer with 'q' key in utility modes."
  (when (and (boundp 'buffer-file-name)
             (not buffer-file-name)
             (or (derived-mode-p 'help-mode)
                 (derived-mode-p 'man-mode)
                 (derived-mode-p 'apropos-mode)
                 (derived-mode-p 'Info-mode)
                 (derived-mode-p 'flycheck-error-list-mode)
                 (derived-mode-p 'compilation-mode)))
    (local-set-key (kbd "q") #'quit-window)))

(add-hook 'help-mode-hook #'+close-buffer-with-q)
(add-hook 'man-mode-hook #'+close-buffer-with-q)
(add-hook 'apropos-mode-hook #'+close-buffer-with-q)
(add-hook 'Info-mode-hook #'+close-buffer-with-q)
(add-hook 'flycheck-error-list-mode-hook #'+close-buffer-with-q)
(add-hook 'compilation-mode-hook #'+close-buffer-with-q)



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

;; Inc-rename com preview em tempo real
(map! :leader
      :desc "Incremental rename (iedit)" "c R" #'iedit-mode
      :desc "Rename in defun" "c D" #'iedit-mode-toggle-on-function)

;; -----------------------------
;; 13. DIFF-HL (Git gutter)
;; -----------------------------
(use-package! diff-hl
  :hook ((prog-mode . diff-hl-mode)
         (dired-mode . diff-hl-dired-mode))
  :config
  (diff-hl-margin-mode)
  (diff-hl-flydiff-mode)

  ;; Keymaps para git actions
  (map! :leader
        (:prefix ("g" . "git")
         :desc "Git gutter next" "n" #'diff-hl-next-hunk
         :desc "Git gutter prev" "p" #'diff-hl-previous-hunk
         :desc "Git gutter stage" "s" #'diff-hl-stage-current-hunk
         :desc "Git gutter revert" "r" #'diff-hl-revert-hunk
         :desc "Git gutter show" "d" #'diff-hl-show-hunk)))

;; -----------------------------
;; 15. EVIL-ESCAPE (jk/kj)
;; -----------------------------
(use-package! evil-escape
  :after evil
  :config
  (setq evil-escape-key-sequence "jk"
        evil-escape-delay 0.1
        evil-escape-unordered-key-sequence t)
  (evil-escape-mode 1))

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
(use-package! consult-dir
  :after consult
  :config
  (setq consult-dir-project-list-function #'consult-dir-projectile-dirs)
  (map! :leader
        :desc "Jump directory" "f d" #'consult-dir
        :desc "Jump directory (other window)" "f D" #'consult-dir-jump-file))

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

;; Auto-save improvements
(setq auto-save-default t
      auto-save-interval 300
      auto-save-timeout 30)

;; Better grep/fd integration
(setq consult-fd-args "fd --hidden --color=never --full-path")

;; Final popup rules
(set-popup-rule! "^\*Dirvish" :side 'left :size 0.3 :select t :quit t)
(set-popup-rule! "^\*harpoon" :side 'bottom :size 0.25 :select t)

;; Org face sizes (migrated from custom.el)
(custom-set-faces
 '(org-checkbox ((t (:height 1.5))))
 '(org-document-title ((t (:height 1.5 :bold t :underline nil))))
 '(org-level-1 ((t (:inherit outline-1 :height 1.5))))
 '(org-level-2 ((t (:inherit outline-2 :height 1.4))))
 '(org-level-3 ((t (:inherit outline-3 :height 1.3))))
 '(org-level-4 ((t (:inherit outline-3 :height 1.3))))
 '(org-level-5 ((t (:inherit outline-3 :height 1.2))))
 '(org-level-6 ((t (:inherit outline-3 :height 1.2))))
 '(org-level-7 ((t (:inherit outline-3 :height 1.1))))
 '(org-level-8 ((t (:inherit outline-3 :height 1.1)))))
