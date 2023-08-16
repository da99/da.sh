
local set        = vim.opt
local g          = vim.g
local fn         = vim.fn
local api        = vim.api
local set_keymap = api.nvim_set_keymap
local cmd        = vim.cmd
local env        = vim.env
local is_256     = env.TERM == "xterm-256color"
local lsp        = vim.lsp

-- require "paq" {
--   'nathom/filetype.nvim',
--   'simrat39/symbols-outline.nvim',
--   "vim-crystal/vim-crystal",
-- }
-- require('filetype').setup({})

g.indentLine_char                = '┊'
g.indentLine_setColors           = 0
g.mapleader               = ' '

if is_256 then
  -- require('lspconfig')
  local util = require 'lspconfig.util'
  require'lspconfig'.jsonls.setup{}
  require'lspconfig'.crystalline.setup{
  }
  require'lspconfig'.denols.setup{
    root_dir = util.root_pattern('deno.json', 'deno.jsonc', '.git', '.'),
  }
  set.termguicolors = true
  g.rg_highlight                   = true -- Highlight :Rg results
  g.rg_command                     = "rg --vimgrep --hidden -g '!.git/'"

  require("bluloco").setup({
  style = "auto",               -- "auto" | "dark" | "light"
  transparent = false,
  italics = true,
  terminal = vim.fn.has("gui_running") == 1, -- bluoco colors are enabled in gui terminals per default.
  guicursor   = true,
  })

  vim.opt.termguicolors = true
    cmd([[
      set cursorlineopt=number
      set cursorline
      set background=light
      hi Search ctermbg=2    ctermfg=232    guibg=#000000  guifg=NONE  cterm=bold      gui=bold,italic
      hi Pmenu  ctermbg=233  ctermfg=137    guibg=#D5D5D5  guifg=#171717  cterm=none      gui=NONE
      hi PmenuSel guifg=#E5C078 guibg=#000000
      hi PmenuThumb guibg=#C3A56A
      hi NormalFloat guibg=#000000
      hi Conceal guifg=#1E1E1E
      " hi PmenuThumb      ctermbg=235  ctermfg=137    guibg=NONE     guifg=#171717  cterm=none      gui=none
      highlight Comment cterm=italic gui=italic
      " set guicursor+=n-v-c-sm:blinkon1
    ]])

  if (fn.filereadable('/tmp/light.editor') == 1) then
    cmd([[
      packadd vim-github-colorscheme
      set background=light
      colorscheme github
      set background=light
      hi ActiveWindow guibg=#DBDBDB
      hi InactiveWinAow guibg=#EAEAEA
    ]])
  else
    vim.cmd([[
      set background=dark
      colorscheme bluloco
    ]])
  end
end

set.signcolumn  = "number"
set.scrolloff   = 3    -- Start scrolling when we're 2 lines away from margins
set.autoread    = true -- Reload files changed outside vim:
set.smartindent = true
set.showtabline = 1 -- Only when 2 or more tab pages
set.wrap        = false
set.expandtab   = true
set.list        = true -- https://www.reddit.com/r/neovim/comments/chlmfk/highlight_trailing_whitespaces_in_neovim/
set.cmdheight   = 2
set.shiftwidth  = 2
set.ignorecase  = true

-- " Suppress the annoying 'match x of y', 'The only match' and 'Pattern not
-- " found' messages
set.shortmess:append('c')

-- from: https://github.com/skwp/dotfiles/blob/master/vimrc
set.listchars = { tab = '⇒␣', trail = '·', nbsp = '␠', extends = '⮚', precedes = '⮘' }
set.list = true
-- eol:¬,
-- =============================================================================


local vim_temp_dir = "/progs/tmp/nvim"
set.swapfile  = false
set.backup    = false
set.directory = vim_temp_dir .. "/.swap"
set.undodir   = vim_temp_dir .. "/.undo"
set.backupdir = vim_temp_dir .. "/.backup"

set.number     = true
set.updatetime = 1000
set.timeoutlen = 500
set.shell      = "sh"

-- ============================================================================
-- Key maps:
-- ============================================================================
-- autocmd FileType help nnoremap <buffer>' <CMD>cclose<CR>
set_keymap('n', '<SPACE>', '<NOP>', {noremap = true})
-- ============================================================================
-- ======================= Dangerous ==========================================
-- ============================================================================
set_keymap('n', '<Leader>die', '<CMD>:Delete!<CR>', {})
-- ============================================================================

-- =============================================================================
-- Visual:
-- https://vi.stackexchange.com/questions/8433/how-do-you-indent-without-leaving-visual-mode-and-losing-your-current-select
-- =============================================================================
set_keymap('v', '>', '>gv', {noremap = true, silent = true})  -- # https://vi.stackexchange.com/questions/8433/how-do-you-indent-without-leaving-visual-mode-and-losing-your-current-select
set_keymap('v', '<', '<gv', {noremap = true, silent = true})
set_keymap('v', '<C-Space>', '<ESC>', {})
set_keymap('x', 'ga', '<Plug>(EasyAlign)', {})
-- =============================================================================
--
--

-- =============================================================================
-- Terminal mode:
-- =============================================================================
-- nnoremap <Leader>term <C-w><C-s>6<C-w>+<C-w><down>:<C-u>term<CR>
-- tnoremap <C-v> <C-\><C-n>"+pi
set_keymap('t', '<C-t><C-t>', '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>', {})
set_keymap('t', '<C-w>', '<C-\\><C-n><C-w>', {noremap=true, silent=true})
-- =============================================================================

-- =============================================================================
-- Insert mode:
-- =============================================================================
set_keymap('i', '<C-Space>', '<ESC>', {})
set_keymap('i', '<C-v>', '<ESC>"+pa', {})
set_keymap('i', '<C-s>', '<ESC>:update<CR>a', {})
set_keymap('i', '<M-x>', '<CMD>lua vim.lsp.buf.signature_help()<CR>', {noremap=true})
set_keymap('i', '<M-c>', '<CMD>lua MiniCompletion.complete_twostage()<CR>', {noremap=true})
-- =============================================================================

-- =============================================================================
-- Normal mode:
-- =============================================================================
set_keymap('n', '<C-z>', 'u', {silent = true}) -- " http://vim.wikia.com/wiki/Saving_a_file
set_keymap('n', 'ga', '<Plug>(EasyAlign)', {noremap = true})

-- =============================================================================
-- Comments:
-- =============================================================================
set_keymap('n', '<Leader>div', 'A<CR><ESC><Leader>kommdi=<ESC>v"9y76pgcco<ESC>gcc', {noremap=false, silent=true})
set_keymap('n', '<Leader>blo', '<Leader>div<Leader>div<UP><UP>i<BS><CR>', {noremap=false, silent=true})

set_keymap('n', '<Leader>hy', ':! xdg-open https://www.google.com/search?q=<C-r><C-w>', {noremap=true, silent=false})

set_keymap('n', '<Leader>xx', '<CMD>TroubleToggle document_diagnostics<CR>', {noremap=true, silent=true})
-- " Turn off the highlighted items searched for:
-- "   <C-l> is nvim default for :
-- "     n  <C-L>       * <Cmd>nohlsearch|diffupdate|normal! <C-L><CR>
-- " Clear highlight search and do a regular search.
set_keymap('n', '<ESC>', '<CMD>nohlsearch <BAR> diffupdate <BAR> normal! <C-L><CR>', {});

set_keymap('n', '<C-s>', ':update<CR>', {})

set_keymap('n', '<C-t><C-t>', ':lua require("FTerm").toggle()<CR>', {})

-- =============================================================================
-- Columns:
-- =============================================================================
set_keymap('n', '<Leader>col', '<CMD>set cursorcolumn!<CR>', {noremap = true, silent = true})
set_keymap('n', '<Leader>=', '10l', {noremap = true})
set_keymap('n', '<Leader>-', '10h', {noremap = true})
-- =============================================================================

-- =============================================================================
-- Tabs:
-- =============================================================================
set_keymap('n', '<Leader><TAB>', '<CMD>tabnext<CR>', {noremap=true, silent=true})
-- =============================================================================

set_keymap('n', '<Leader>ol', '<CMD>:call ToggleLocationList()<CR>', {})
set_keymap('n', '<Leader>op', '<CMD>:call ToggleQuickfixList()<CR>', {})

set_keymap('n', '<Leader>ee', '<CMD>Neotree<CR>', {})

set_keymap('n', '<Leader>bb', '<CMD>bnext<CR>', {})
set_keymap('n', '<Leader>bd', ':Bdelete menu<CR>', {silent = true})
set_keymap('n', '<Leader>bv', '<CMD>bprevious<CR>', {})
-- set_keymap('n', '<Leader>a', ':Startify<CR>', {})
set_keymap('n', '<Leader>000', ':qa<CR>', {})
set_keymap('n', '<Leader>l', 'o<ESC>', {})
set_keymap('n', '<Leader>L', 'O<ESC>', {})

-- " ===============================================
-- " LSP:
-- " ===============================================
set_keymap('n', '<Leader>qa', '<CMD>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', { noremap=true, silent=true })
set_keymap('n', '<Leader>qq', '<CMD>lua vim.lsp.buf.hover()<CR>', {})
set_keymap('n', '<Leader>qw', '<CMD>lua vim.lsp.buf.definition()<CR>', {noremap = true})
set_keymap('n', '<Leader>qr', '<CMD>lua vim.lsp.buf.rename()<CR>', {noremap = true})
-- " ===============================================

set_keymap('n', '<Leader>rg', '<CMD>:Rg<CR>', {})

set_keymap('n', '++', '<CMD>:cnext<CR>', {})
set_keymap('n', '__', '<CMD>:cprevious<CR>', {})

-- " ===============================================
-- " Dev:
-- " ===============================================
for i = 1, 3 do
  set_keymap('n', '<Leader>' .. i .. 'e', ":! da.sh sh tmp/run." .. i .. ".sh<CR><CR>:e tmp/run." ..  i .. ".sh<CR>G", {noremap=true})
  set_keymap('n', '<Leader>' .. i .. i, ":lua local f = require('FTerm'); f.toggle(); vim.defer_fn(function () f.run(vim.fn.getcwd() .. '/tmp/run." .. i .. ".sh'); end, 450); <CR>", {noremap=true})
end
set_keymap('n', '<Leader>pp', ':lua print(vim.inspect())<Left><Left>', {})

-- ===============================================
-- Buffers:
-- ===============================================
-- for i = 1, 9 do
--  set_keymap('n', '<Leader>b' .. i, '<CMD>buffer ' .. i .. '<CR>', {noremap = true, silent = true})
-- end

-- ===============================================
-- Fuzzy finders:
-- ===============================================
set_keymap('n', '<Leader>tr', "<CMD>Telescope oldfiles<CR>", {noremap = true, silent = true})
set_keymap('n', '<Leader>ty', "<CMD>Telescope find_files<CR>", {noremap = true, silent = true})
-- set_keymap('n', '<Leader>fg', "<CMD>Telescope buffers<CR>", {noremap = true, silent = true})
set_keymap('n', '<Leader>tf', "<CMD>Telescope current_buffer_fuzzy_find<CR>", {noremap = true, silent = true})
-- set_keymap('n', '<Leader>fr', "<CMD>Telescope command_history<CR>", {noremap = true, silent = true})
set_keymap('n', '<Leader>t ', "<CMD>Telescope<CR>", {noremap = true, silent = true})
-- set_keymap('n', '<Leader>ss', "<Plug>Lightspeed_s", {noremap = false, silent = false})
-- set_keymap('n', '<Leader>sa', "<Plug>Lightspeed_S", {noremap = false, silent = false})
-- ===============================================

-- ===============================================
-- Nvim-snippy:
-- ===============================================
-- set_keymap('i', '<M-s>', "snippy#can_expand_or_advance() ? '<Plug>(snippy-expand-or-advance)' : ''", {noremap=false, expr = true})
-- imap <expr> <S-Tab> snippy#can_jump(-1) ? '<Plug>(snippy-previous)' : '<S-Tab>'
-- smap <expr> <Tab> snippy#can_jump(1) ? '<Plug>(snippy-next)' : '<Tab>'
-- smap <expr> <S-Tab> snippy#can_jump(-1) ? '<Plug>(snippy-previous)' : '<S-Tab>'
-- xmap <Tab> <Plug>(snippy-cut-text)
-- ===============================================

-- cmd([[
--  inoremap <silent><expr> <Tab> pumvisible() ? "\<C-n>" : "\<TAB>"
--  inoremap <silent><expr> <CR>  pumvisible() ? "\<C-y>" : v:lua.MPairs.autopairs_cr()
--  cnoremap         <expr> <CR>  pumvisible() ? "<C-y> " : "<CR>"
-- ]])

-- =============================================================================

-- =============================================================================
-- WhichKey: https://github.com/folke/which-key.nvim
-- =============================================================================
    vim.o.timeout = true
    vim.o.timeoutlen = 300
    require("which-key").setup {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    }


-- =============================================================================
-- Disable builtin plugins I don't need for now:
-- From: https://dev.to/voyeg3r/my-ever-growing-neovim-init-lua-h0p
-- =============================================================================
local disabled_built_ins = {
    "netrw",
    "netrwPlugin",
    "netrwSettings",
    "netrwFileHandlers",
    "gzip",
    "zip",
    "zipPlugin",
    "tar",
    "tarPlugin",
    "getscript",
    "getscriptPlugin",
    "vimball",
    "vimballPlugin",
    "2html_plugin",
    "logipat",
    "rrhelper",
    "spellfile_plugin",
    "matchit"
}

for _, plugin in pairs(disabled_built_ins) do
    g["loaded_" .. plugin] = 1
end
-- =============================================================================

-- =============================================================================
cmd([[
  augroup my_defaults
    autocmd!
    autocmd TermOpen * IndentLinesDisable | startinsert
    autocmd TermClose * if !v:event.status | exe 'bdelete! '..expand('<abuf>') | endif
    autocmd BufNewFile,BufRead *.njk, set ft=jinja
    autocmd BufRead,BufNewFile *.xdefaults setfiletype xdefaults
  augroup END
]])
-- =============================================================================

-- ===============================================
-- Colorschemes:
-- ===============================================
-- use 'endel/vim-github-colorscheme'
-- use 'EdenEast/nightfox.nvim'
-- use 'folke/tokyonight.nvim'

if is_256 then
    -- require('nightfox').setup({
    --   options = { dim_inactive = true }
    -- })
    -- cmd([[
    --   set background=dark
    --   colorscheme toast
    --   hi Normal guibg=#10161B
    -- ]])
    -- cmd([[
    --   set background=dark
    --   colorscheme OceanicNext
    --   hi Normal guibg=#0F161A
    -- ]])
    -- cmd([[
    --   set background=dark
    --
    --   augroup MyColors
    --     autocmd!
    --     autocmd ColorScheme * hi String guifg=#7CC745 | hi NormalFloat guibg=#202033 | hi Pmenu guibg=#202033 | hi PmenuSel guifg=#ffcb65 guibg=#161630 | hi PmenuThumb guibg=#202033
    --   augroup END
    --
    --   colorscheme aurora
    -- ]])
    -- cmd([[
      -- " colorscheme nimda
      -- " hi Normal guibg=#E3E3E3
    -- ]])
    --   packadd jellybeans.vim
    --   set background=dark
    --   colorscheme jellybeans
    --   set background=dark
    --   hi InactiveWindow guibg=#192330
    -- ]])

  -- cmd([[
  --   packadd onedark.vim
  --   colorscheme onedark
  --   highlight Normal guibg=#1A1C20
  --   ]])
  -- cmd([[
  --   packadd vim-one
  --   colorscheme one
  --   highlight Normal guibg=#E8E8E8
  -- ]])
end -- if is_256


-- =============================================================================
-- Mini nvim
require('mini.statusline').setup()
require('mini.tabline').setup()
require('mini.trailspace').setup()
require('mini.pairs').setup()
require('mini.comment').setup()
require('mini.bracketed').setup()
cmd(' highlight MiniTablineCurrent guibg=#000000 ')
cmd(' highlight MiniTablineHidden guibg=#282c34 ')
cmd(' highlight MiniTablineModifiedCurrent guibg=#e8ad00 guifg=#000000 ')
cmd(' highlight MiniTablineModifiedVisible guibg=#7f5e36 guifg=#000000 ')
cmd(' highlight MiniTablineModifiedHidden guibg=#7f5e36 guifg=#000000 ')

local hipatterns = require('mini.hipatterns')
hipatterns.setup({
  highlighters = {
    -- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
    todo  = { pattern = '%f[%w]()TODO()%f[%W]',  group = 'MiniHipatternsTodo'  },
    note  = { pattern = '%f[%w]()NOTE()%f[%W]',  group = 'MiniHipatternsNote'  },

    -- Highlight hex color strings (`#rrggbb`) using that color
    hex_color = hipatterns.gen_highlighter.hex_color(),
  },
})
-- =============================================================================


-- You dont need to set any of these options. These are the default ones. Only
-- the loading is important
local telescope = require('telescope')
telescope.setup()
telescope.load_extension('fzf')

require('gitsigns').setup()
-- require("symbols-outline").setup()

-- =============================================================================
-- Mason.nvim
-- =============================================================================
require('mason').setup()
require("mason-lspconfig").setup()

-- require("filetype").setup({})

-- =============================================================================
if true then
  return 0
end
-- =============================================================================

-- =============================================================================
-- require("filetype").setup({
--   overrides = {
--     extensions = {
--       cr = "crystal"
--     }
--   }
-- })
-- =============================================================================

-- =============================================================================
require("which-key").setup({ })
require'FTerm'.setup({ cmd = 'fish -i' })
require('neoscroll').setup()
require('nvim-autopairs').setup{
  disable_filetype = { "TelescopePrompt" , "guihua", "guihua_rust", "clap_input" },
  map_cr = false
}
require'nvim-tree'.setup {}

-- =====================================
-- BufferLine
-- =====================================
require('bufferline').setup({
  highlights = {
    -- tab = { bg = "#000000" },
    background = { bg = "#000000" },
    fill = { bg = "#000000" },
    tab            = { bg = "#000000" },
    buffer_visible = { bg = "#000000" },
  },
  options = {
    show_buffer_close_icons = false,
    separator_style = "thin",
    diagnostics = "nvim_lsp",
    numbers = function(opts)
      return string.format('%s·%s', opts.ordinal, opts.id)
    end
  }
})

-- =====================================
-- LuaLine:
-- =====================================
local function a_file()
  local ft = vim.bo.filetype
  local bt = vim.bo.buftype
  return not (ft == "help" or ft == "alpha" or ft == "" or bt == "terminal" or bt == "nofile")
end

local function dirname()
  -- local ft = vim.bo.filetype
  if a_file() or vim.bo.filetype == "help" then
    local filename = fn.expand('%')
    local basename = fn.fnamemodify(filename, ":t")
    local dir      = fn.fnamemodify(filename, ":h")
    local base_dir = fn.fnamemodify(dir, ":t")
    return base_dir.."/"..basename
  elseif vim.bo.buftype == "terminal" then
    return fn.matchstr(fn.expand('%'), '[^:]\\+$')
  else
    return ""
  end
  --  if vim.bo.modified then
  --  elseif vim.bo.modifiable  vim.bo.readonly
end -- function

local function branch_or_base_name(x)
  local ft = vim.bo.filetype
  if (ft == "help" or ft == "alpha" or ft == "") then
    return ""
  else
    return x
  end
end -- function

require('lualine').setup {
  options = {
    theme = 'onedark',
    component_separators = { left = '', right = ''},
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { },
    lualine_c = {{'branch', fmt = branch_or_base_name}, dirname, 'filetype'},
    lualine_x = { },
    lualine_y = { 'diagnostics', 'fileformat', 'encoding', 'progress', 'location' },
    lualine_z = { },
  },
  inactive_sections = {
    lualine_a = { 'filename', dirname },
    lualine_b = { },
    lualine_c = { },
    lualine_x = { },
    lualine_y = { },
    lualine_z = { },
  }
}
-- =============================================================================
-- End LuaLine
-- =============================================================================


-- =============================================================================
-- Kommentary:
-- =============================================================================
local komm = require('kommentary.config')
set_keymap('n', '<Leader>kommd', '<Plug>kommentary_line_decrease', {})
komm.configure_language("default", {
  prefer_single_line_comments = true,
  ignore_whitespace = false
})
komm.configure_language("fish", {
  prefer_single_line_comments = true,
  single_line_comment_string = "#",
})
-- =============================================================================

-- =============================================================================
-- Colorizer:
-- =============================================================================
require('colorizer').setup({
  'typescript';
  'vim';
  'lua';
  'jinja';
  'less';
  'html';
  'sh';
  'zsh';
  css = {names = true}
}, {names = false})
-- =============================================================================


-- =============================================================================
-- Treesitter:
-- =============================================================================
require'nvim-treesitter.configs'.setup({
  ensure_installed = {"bash", "css", "fish", "json", "lua","ruby", "scss", "toml", "vim", "yaml"},
  rainbow = {
    enable = true,
    extended_mode = true,
    max_file_lines = 1500
  },
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  }
})


-- =============================================================================
-- Telescope:
-- =============================================================================
require('telescope').setup{
  defaults = {
    -- Default configuration for telescope goes here:
    -- config_key = value,
    mappings = {
      i = {
        ["<C-h>"] = "which_key"
      },
      n = {
        ["<C-h>"] = "which_key"
      },
    },
    initial_mode = "insert"
  },
  pickers = {
    -- Default configuration for builtin pickers goes here:
    command_history = {
      mappings = {
        i = {
          ["<CR>"] = "edit_command_line"
        },
      },
    }
    -- Now the picker_config_key will be applied every time you call this
    -- builtin picker
  },
  extensions = {
    -- Your extension configuration goes here:
    -- extension_name = {
    --   extension_config_key = value,
    -- }
    -- please take a look at the readme of the extension you want to configure
  }
}
-- =============================================================================

-- =============================================================================
-- Lightspeed:
-- =============================================================================
require'lightspeed'.setup {
  ignore_case = true,
  safe_labels = {},
  jump_to_unique_chars = false,
  labels = {
    "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=",
    "!", "@", "#", "$", "%", "^", "&", "*", "(", ")",      "+"
  }
}
-- =============================================================================

-- =============================================================================
-- LSP:
-- =============================================================================
-- local lsp_util = require('lspconfig.util')
require'trouble'.setup({})
require'lspkind'.init({ mode = 'symbol' })
require'lspconfig'.denols.setup{}
require'lspconfig'.cssls.setup{}
require'lspconfig'.sumneko_lua.setup({ })
require'lspconfig'.jsonls.setup{ cmd = { "vscode-json-languageserver", "--stdio" } } -- https://github.com/pwntester/nvim-lsp
require'lspconfig'.crystalline.setup{}
require "lspconfig".efm.setup {
    init_options = {documentFormatting = true},
    settings = { rootMarkers = {".git/"}, },
    filetypes = {'sh'}
}
lsp.handlers["textDocument/hover"] = lsp.with( lsp.handlers.hover, {
  -- border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }
  -- border = { "/", "-", "\\", "|" }
  border = 'rounded'
})
-- # From: https://github.com/samhh/dotfiles/blob/99e67298fbcb61d7398ad1850f3c2df31d90bd0d/home/.config/nvim/plugin/lsp.lua#L120
lsp.handlers["textDocument/publishDiagnostics"] = lsp.with(
  lsp.diagnostic.on_publish_diagnostics,
  {
    virtual_text = false,
    signs = true,
    update_in_insert = false,
    underline = true,
    border = 'rounded'
  }
  )

-- require "lsp_signature".setup({
--   bind = true, -- This is mandatory, otherwise border config won't get registered.
--   handler_opts = {
--     border = "rounded"
--   }
-- })
-- =============================================================================


-- =============================================================================
-- Mini.nvim:
-- =============================================================================
require('mini.surround').setup({})
require('mini.completion').setup({
  mappings = {
    force_twostep = '', -- Force two-step completion
    force_fallback = '', -- Force fallback completion
  }
})
cmd(' autocmd! MiniCompletion InsertCharPre * ')
-- =============================================================================
