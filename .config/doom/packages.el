;;; packages.el -*- no-byte-compile: t; lexical-binding: t; -*-

;; --- TEMAS ---
(package! catppuccin-theme)
(package! kaolin-themes)

;; --- AI ---
(package! copilot
  :recipe (:host github :repo "copilot-emacs/copilot.el" :files ("*.el")))

;; --- ORG MODE ---
;; org-superstar, org-appear, org-modern já vêm com :lang org +pretty
;; Mantive apenas extras:
(package! org-auto-tangle)
(package! org-super-agenda)

;; --- UI & UX ---
(package! pulsar)

;; --- EDITING ---
(package! iedit)

;; --- DEV & TOOLS ---
(package! treesit-auto)
(package! harpoon)


(package! gcmh)
(package! kdl-mode)

;; NOTAS SOBRE REMOÇÕES:
;; - vertico, orderless, consult, embark, marginalia: Removidos pois o módulo :completion vertico já instala.
;; - corfu, corfu-terminal: Removidos pois o módulo :completion corfu já instala.
;; - js2-mode: Removido pois o módulo :lang javascript já traz suporte adequado (e treesitter é o futuro).
;; - org-bullets: Obsoleto, o Doom usa org-superstar nativamente.
;; - dirvish: declarado pelo módulo :emacs dired (+dirvish).
;; - consult-dir: declarado pelo módulo :completion vertico.
;; - diff-hl: declarado pelo módulo :ui vc-gutter.
;; - evil-escape: declarado pelo módulo :editor evil.
;; - powershell: declarado pelo módulo :lang sh.
