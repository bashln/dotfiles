local M = {}

M.bg_blurred_darker = os.getenv("HOME") .. "/dotfiles/.config/wezterm/assets/bg-blurred-darker.png"
M.bg_blurred = os.getenv("HOME") .. "/dotfiles/.config/wezterm/assets/bg_blurred.png"
M.bg_blurred_darker_w11 = os.getenv("HOME") .. "/.config/wezterm/assets/bg-blurred-darker-w11.png"
M.bg_blurred_w11 = os.getenv("HOME") .. "/.config/wezterm/assets/bg-blurred-w11.png"
-- M.bg_image = M.bg_blurred_darker
-- M.bg_image = M.bg_blurred_darker_w11
M.bg_image = M.bg_blurred_w11
-- M.bg_image = M.bg_blurred

return M
