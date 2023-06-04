local config = require('tasks.config')
local runner = require('tasks.runner')
local utils = require('tasks.utils')

local M = {}

--- Apply user settings.
---@param values table
function M.setup(values) setmetatable(config, { __index = vim.tbl_deep_extend('force', config.defaults, values) }) end

--- Execute a task from a module.
---@param module_type string: Name of a module or `auto` string to pick a first module that match a condition.
---@param task_name string
---@vararg string additional arguments that will be passed to the last task.
function M.start(module_type, task_name, ...)
    local current_job_name = runner.get_current_job_name()
    if current_job_name then
        utils.notify(string.format('Another job is currently running: "%s"', current_job_name), vim.log.levels.ERROR)
        return
    end

    local module, module_name = utils.get_module(module_type)
    if not module then
        return
    end

    local commands = module.tasks[task_name]
    if not commands then
        utils.notify(string.format('Unable to find a task named "%s" in module "%s"', task_name, module_name), vim.log.levels.ERROR)
        return
    end

    if config.save_before_run then
        vim.api.nvim_command('silent! wall')
    end

    local module_config = config.default_params[module_name]
    if not vim.tbl_islist(commands) then
        commands = { commands }
    end
    runner.chain_commands(task_name, commands, module_config, { ... })
end

--- Cancel last current task.
function M.cancel()
    if not runner.cancel_job() then
        utils.notify('No running process')
    end
end

return M
