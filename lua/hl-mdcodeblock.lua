local M = {}

M.namespace = vim.api.nvim_create_namespace "hlmdcb_namespace"

M.config = {
    hl_group = "MDCodeBlock",     -- default highlight group
    events = {                    -- refresh event
        "FileChangedShellPost",
        "Syntax",
        "TextChanged",
        "TextChangedI",
        "InsertLeave",
        "WinScrolled",
        "BufEnter",
    },
    padding_right = 4,            -- always append 4 space at lineend
    timer_delay = 20,             -- refresh delay(ms)
    query_by_ft = {
        markdown = {              -- filetype
            'markdown',           -- parser
            '(fenced_code_block) @codeblock', -- query
        },
        rmd = {                   -- filetype
            'markdown',           -- parser
            '(fenced_code_block) @codeblock', -- query
        },
    },
    minumum_len = 100,            -- minimum len to highlight (number | function)
    -- minumum_len = function ()
    --     return math.floor(vim.o.columns * 0.9)
    -- end
}

M.refresh = function ()
    local language = vim.bo.filetype
    local query = M.config.query_by_ft[language]
    if query == nil then return end

    local bufnr = vim.api.nvim_get_current_buf()
    local language_tree = vim.treesitter.get_parser()
    local syntax_tree = language_tree:parse()
    local root = syntax_tree[1]:root()
    local query = vim.treesitter.query.parse(query[1], query[2])
    local win_view = vim.fn.winsaveview()
    local left_offset = win_view.leftcol
    local win_start = win_view.topline - 20
    local win_end = win_start + vim.fn.winheight(0) + 20
    local minumum_len = M.config.minumum_len
    if type(minumum_len) == "function" then minumum_len = minumum_len() end
    if win_start < 0 then win_start = 0 end

    vim.api.nvim_buf_clear_namespace(bufnr, M.namespace, 0, -1)

    for _, match, metadata in query:iter_matches(root, bufnr, win_start, win_end) do
        for id, node in pairs(match) do
            local start_row, _, end_row, _ = unpack(vim.tbl_extend("force", { node:range() }, (metadata[id] or {}).range or {}))

            local start_line = vim.api.nvim_buf_get_lines(bufnr, start_row, start_row + 1, false)[1]
            local _, padding = start_line:find "^ +"
            local padding_left = math.max((padding or 0) - left_offset, 0)

            local max_line_length = 0
            for i = start_row, end_row - 1 do
                local line = vim.fn.getline(i + 1)
                local len = vim.fn.strwidth(line)
                max_line_length = math.max(max_line_length, len)
            end
            max_line_length = math.max(max_line_length, minumum_len)

            for i = start_row, end_row - 1 do
                local line = vim.fn.getline(i + 1)
                local len = vim.fn.strwidth(line)
                local extend_len = max_line_length - len + M.config.padding_right - math.max(0, left_offset - len)
                vim.api.nvim_buf_add_highlight(bufnr, M.namespace, M.config.hl_group, i, padding_left, -1)
                vim.api.nvim_buf_set_extmark(bufnr, M.namespace, i, 0, {
                    virt_text = { { string.rep(" ", extend_len), M.config.hl_group } },
                    virt_text_win_col = math.max(len - left_offset, 0),
                })
            end
        end
    end
end

M.setup = function (config)
    config = config or {}
    M.config = vim.tbl_deep_extend("force", M.config, config)

    local timer_id = -1
    vim.api.nvim_create_autocmd(M.config.events, {
        callback = function ()
            vim.fn.timer_stop(timer_id)
            timer_id = vim.fn.timer_start(M.config.timer_delay, M.refresh)
        end
    })
end

return M
