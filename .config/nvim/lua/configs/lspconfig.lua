require("nvchad.configs.lspconfig").defaults()

local servers = {
  "html",
  "cssls",
  "ts_ls",
  "jdtls",
  "jsonls",
  "templ",
  "gopls",
  "sqls",
  "pylsp",
  "tailwind-css-server",
}

vim.lsp.config("gopls", {
  settings = {
    gopls = {
      completeUnimported = true,
      usePlaceholders = true,
      analyses = {
        unusedparams = true,
      },
    },
  },
})

vim.lsp.config("pylsp", {
  settings = {
    pylsp = {
      signature = {
        formatter = "null",
      },
      plugins = {

        pycodestyle = {
          enabled = false,
        },
      },
    },
  },
})

vim.lsp.enable(servers)
