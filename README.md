# HIGHLIGHT MARKDOWN CODEBLOCK

JUST DO HIGHLIGHT MARKDOWN CODEBLOCK

![show](show.png)

## REQUIRE

1. nvim version >= 0.11.0
2. nvim-treesitter

## USAGE

```lua
    -- packer
    require('packer').startup({
        -- ...
        use {
            'yaocccc/nvim-hl-mdcodeblock.lua',
            after = 'nvim-treesitter',
            config = function ()
                require('hl-mdcodeblock').setup({
                    -- option
                })
            end
        }
    })
    

    -- lazy
    {
        "yaocccc/nvim-hl-mdcodeblock.lua",
        dependencies = { 'nvim-treesitter/nvim-treesitter' },
        ft = 'markdown',
        opts = {}
    }
```

## OPTIONS

```lua
    {
        hl_group = "MDCodeBlock",   -- default highlight group
        bg = "#282828"              -- default bg if you never set hl config
        events = {                  -- refresh event
            "FileChangedShellPost",
            "Syntax",
            "TextChanged",
            "TextChangedI",
            "InsertLeave",
            "WinScrolled",
            "BufEnter",
        },
        padding_right = 4,          -- always append 4 space at line end
        timer_delay = 20,           -- refresh delay(ms)
        query_by_ft = {             -- special parser query by filetype
            markdown = {            -- filetype
                'markdown',         -- parser
                '(fenced_code_block) @codeblock', -- query
            },
            rmd = {                 -- filetype
                'markdown',         -- parser
                '(fenced_code_block) @codeblock', -- query
            },
        },
        minumum_len = 60,           -- minimum len to highlight (number | function)
        -- minumum_len = function () return math.max(math.floor(vim.api.nvim_win_get_width(0) * 0.8), 100) end
    }
```
