-- Neovide-specific settings
-- Aparência inspirada em Kitty/Ghostty (terminal-like)

if vim.g.neovide then
  -- === Transparência ===
  -- Kitty usa background_opacity 0.95; espelhamos aqui
  vim.g.neovide_opacity = 0.95

  -- === Cursor ===
  -- Block cursor como Kitty/Ghostty (sem animação para feel de terminal)
  vim.g.neovide_cursor_animation_length = 0
  vim.g.neovide_cursor_trail_length = 0
  vim.g.neovide_cursor_vfx_mode = "none"
  vim.o.guicursor = "n-v-c:block-Cursor,i-ci-ve:ver25-Cursor,r-cr:hor20-Cursor"

  -- === Mouse ===
  -- Esconde mouse ao digitar (como Kitty)
  vim.g.neovide_hide_mouse_when_typing = true

  -- === Floating windows ===
  -- Leve blur/transparência nos flutuantes para um visual moderno
  vim.g.neovide_floating_blur_amount_x = 10
  vim.g.neovide_floating_blur_amount_y = 10

  -- === Janela ===
  -- Desliga confirmação ao sair (como kitty: confirm_os_window_close 0)
  vim.g.neovide_confirm_quit = false

  -- === Underline ===
  -- Desliga scaling automático de underline pra evitar artefatos
  vim.g.neovide_underline_automatic_scaling = false
end
