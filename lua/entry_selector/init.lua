local M = {}
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values
local action_state = require('telescope.actions.state')
local actions = require('telescope.actions')

M.config = {
    spaces = {},
    global_space_path = vim.fn.stdpath('data') .. "/entry_selector/global_space.txt"
}

local function create_file_if_not_exists(path)
    local dir = vim.fn.fnamemodify(path, ":h")
    if vim.fn.isdirectory(dir) == 0 then
        vim.fn.mkdir(dir, "p")
    end
    if vim.fn.filereadable(path) == 0 then
        local file = io.open(path, "w")
        if file then
            file:close()
        else
            error("Could not create the file: " .. path)
        end
    end
end

function M.setup(opts)
    M.config = vim.tbl_deep_extend("force", M.config, opts or {})
    create_file_if_not_exists(M.config.global_space_path)
    for space, path in pairs(M.config.spaces) do
        -- Ensure the user's spaces exists
        if vim.fn.filereadable(path) == 0 then
            error("The file associated to the space " .. space .. " does not exist or is not readable: ".. path)
        end
    end
end

local function remove_line(all_lines, line_to_remove)
    local new_lines = {}
    local removed = false
    for _, line in ipairs(all_lines) do
        if line ~= line_to_remove then
            table.insert(new_lines, line)
        else
            removed = true
        end
    end
    return new_lines, removed
end


function M.select_line(space_name)
    local path
    if space_name then
        if M.config.spaces and M.config.spaces[space_name] then
            path = M.config.spaces[space_name]
        else
            error("Space " .. space_name .. " is not defined")
        end
    else
        path = M.config.global_space_path
    end

    local lines = {}
    for line in io.lines(path) do
        table.insert(lines, line)
    end
    table.sort(lines)

    pickers.new({}, {
        prompt_title = "Select a line",
        finder = finders.new_table({
            results = lines,
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
            local add_or_insert_line = function()
                local selection = action_state.get_selected_entry()
                local current_line = action_state.get_current_line()
                if selection then
                    current_line = selection.value
                elseif current_line ~= "" and not vim.tbl_contains(lines, current_line) then
                    local file = io.open(path, "a")
                    if file then
                        file:write(current_line .. "\n")
                        file:close()
                    end
                end
                actions.close(prompt_bufnr)
                vim.api.nvim_put({current_line}, '', true, true)
            end

            actions.select_default:replace(add_or_insert_line)
            map('i', '<CR>', add_or_insert_line)
            map('n', '<CR>', add_or_insert_line)

            map('n', 'd', function()
                local selection = action_state.get_selected_entry()
                if not selection then
                    return
                end
                local filtered_lines, removed = remove_line(lines, selection.value)
                if not removed then
                    return
                end
                lines = filtered_lines
                local file = io.open(path, "w")
                if not file then
                    return
                end
                for _, line in ipairs(lines) do
                    file:write(line .. "\n")
                end
                file:close()
                -- Refresh current picker
                action_state.get_current_picker(prompt_bufnr):refresh(finders.new_table({
                    results = lines,
                    entry_maker = function(line)
                        return {
                            value = line,
                            display = line,
                            ordinal = line,
                        }
                    end,
                }), { reset_prompt = true })
            end)
            return true
        end
    }):find()
end

return M
