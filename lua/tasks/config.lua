local Path = require('plenary.path')

local config = {
    defaults = {
        default_params = {
            cargo = {
                dap_name = 'lldb',
            },
            cmake = {
                cmd = 'cmake',
                build_dir = tostring(Path:new('{cwd}', 'build', '{os}-{build_type}')),
                build_type = 'Debug',
                dap_name = 'lldb',
                args = {
                    configure = { '-D', 'CMAKE_EXPORT_COMPILE_COMMANDS=1', '-G', 'Unix Makefiles' },
                },
            },
            conan = {
                conan_cmd = 'conan',
                cmake_cmd = 'cmake',
                build_dir = tostring(Path:new('{cwd}', 'build', '{os}-{build_type}')),
                build_type = 'Debug',
                dap_name = 'lldb',
                args = {
                    configure = { '-D', 'CMAKE_EXPORT_COMPILE_COMMANDS=1', '-G', 'Unix Makefiles' },
                },
            },
        },
        save_before_run = true,
        quickfix = {
            pos = 'botright',
            height = 12,
            only_on_error = true,
        },
        dap_open_command = function() return require('dap').repl.open() end,
    },
}

setmetatable(config, { __index = config.defaults })

return config
