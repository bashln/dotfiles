local function augroup(name)
  return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end

vim.api.nvim_create_autocmd("DirChanged", {
  group = augroup("persistence_dir_changed"),
  callback = function()
    local ok, persistence = pcall(require, "persistence")
    if ok then
      persistence.save()
    end
  end,
})

vim.api.nvim_create_autocmd("VimLeavePre", {
  group = augroup("persistence_vim_leave"),
  callback = function()
    local ok, persistence = pcall(require, "persistence")
    if ok then
      persistence.save()
    end
  end,
})
