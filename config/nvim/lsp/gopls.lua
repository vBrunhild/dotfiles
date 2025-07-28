--- @class go_dir_custom_args
---
--- @field envvar_id string
---
--- @field custom_subdir string?

local mod_cache = nil
local std_lib = nil

---@param custom_args go_dir_custom_args
---@param on_complete fun(dir: string | nil)
local function identify_go_dir(custom_args, on_complete)
    local cmd = { 'go', 'env', custom_args.envvar_id }
    vim.system(cmd, { text = true }, function(output)
    local res = vim.trim(output.stdout or '')
        if output.code == 0 and res ~= '' then
            if custom_args.custom_subdir and custom_args.custom_subdir ~= '' then
                res = res .. custom_args.custom_subdir
            end

            on_complete(res)
        else
            vim.schedule(function()
                vim.notify(
                ('[gopls] identify ' .. custom_args.envvar_id .. ' dir cmd failed with code %d: %s\n%s'):format(
                        output.code,
                        vim.inspect(cmd),
                        output.stderr
                    )
                )
            end)

            on_complete(nil)
        end
    end)
end

---@return string?
local function get_std_lib_dir()
    if std_lib and std_lib ~= '' then
        return std_lib
    end

    identify_go_dir({ envvar_id = 'GOROOT', custom_subdir = '/src' }, function(dir)
        if dir then
            std_lib = dir
        end
    end)

    return std_lib
end

---@return string?
local function get_mod_cache_dir()
    if mod_cache and mod_cache ~= '' then
        return mod_cache
    end

    identify_go_dir({ envvar_id = 'GOMODCACHE' }, function(dir)
        if dir then
            mod_cache = dir
        end
    end)

    return mod_cache
end

---@param fname string
---@return string?
local function get_root_dir(fname)
    if mod_cache and fname:sub(1, #mod_cache) == mod_cache then
        local clients = vim.lsp.get_clients({ name = 'gopls' })
        if #clients > 0 then
            return clients[#clients].config.root_dir
        end
    end

    if std_lib and fname:sub(1, #std_lib) == std_lib then
        local clients = vim.lsp.get_clients({ name = 'gopls' })
        if #clients > 0 then
            return clients[#clients].config.root_dir
        end
    end

    return vim.fs.root(fname, 'go.work') or vim.fs.root(fname, 'go.mod') or vim.fs.root(fname, '.git')
end

return {
    cmd = { 'gopls' },
    filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
    root_dir = function(bufnr, on_dir)
        local fname = vim.api.nvim_buf_get_name(bufnr)
        get_mod_cache_dir()
        get_std_lib_dir()
        on_dir(get_root_dir(fname))
    end,
    settings = {
        gopls = {
            codelenses = {
                gc_details = false,
                generate = true,
                regenerate_cgo = true,
                run_govulncheck = true,
                test = true,
                tidy = true,
                upgrade_dependency = true,
                vendor = true
            },
            hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues =    true,
                functionTypeParameters = true,
                parameterValues = true,
                rangeVariableTypes = true
            },
            analyses = {
                nilness = true,
                unusedparams = true,
                unusedwrite = true,
                useany = true,
                unreachable = true,
                modernize = true,
                stylecheck = true,
                appends = true,
                asmdecl = true,
                assign = true,
                atomic = true,
                bools = true,
                buildtag = true,
                cgocall = true,
                composite = true,
                contextcheck = true,
                deba = true,
                atomicalign = true,
                composites = true,
                copylocks = true,
                deepequalerrors = true,
                defers = true,
                deprecated = true,
                directive = true,
                embed = true,
                errorsas = true,
                fillreturns = true,
                framepointer = true,
                gofix = true,
                hostport = true,
                infertypeargs = true,
                lostcancel = true,
                httpresponse = true,
                ifaceassert = true,
                loopclosure = true,
                nilfunc = true,
                nonewvars = true,
                noresultvalues = true,
                printf = true,
                shadow = true,
                shift = true,
                sigchanyzer = true,
                simplifycompositelit = true,
                simplifyrange = true,
                simplifyslice = true,
                slog = true,
                sortslice = true,
                stdmethods = true,
                stdversion = true,
                stringintconv = true,
                structtag = true,
                testinggoroutine = true,
                tests = true,
                timeformat = true,
                unmarshal = true,
                unsafeptr = true,
                unusedfunc = true,
                unusedresult = true,
                waitgroup = true,
                yield = true,
                unusedvariable = true
            },
            usePlaceholders = true,
            completeUnimported = true,
            staticcheck = true,
            directoryFilters = { "-.git" },
            semanticTokens = true
        }
    }
}

