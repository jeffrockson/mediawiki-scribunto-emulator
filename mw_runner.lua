-- mw_runner.lua
-- Local Scribunto-like environment bootstrap for VSCode debugging

-- Read environment variables from launch.json
local mw_path = os.getenv("MW_PATH")
local lua_lib_path = os.getenv("LUA_LIB_PATH")
local module_path = os.getenv("MODULE_PATH")

if not mw_path or not lua_lib_path or not module_path then
    error("MW_PATH and LUA_LIB_PATH and MODULE_PATH must be set in your launch.json env block")
end

-- Extend package path so 'mw.*' libraries resolve
package.path = table.concat({
    lua_lib_path .. "/?.lua",
    lua_lib_path .. "/ustring/?.lua",
    package.path
}, ";")

-- Preload MediaWiki modules manually
package.preload["mw"]        = function() return dofile(lua_lib_path .. "/mw.lua") end
package.preload["mw.title"]  = function() return dofile(lua_lib_path .. "/mw.title.lua") end
package.preload["mw.text"]   = function() return dofile(lua_lib_path .. "/mw.text.lua") end
package.preload["mw.html"]   = function() return dofile(lua_lib_path .. "/mw.html.lua") end
package.preload["mw.ustring"] = function() return dofile(lua_lib_path .. "/mw.ustring.lua") end
-- Require the MediaWiki core Lua library
mw = require("mw")
mw.title = require("mw.title")
mw.ustring = require("mw.ustring")
mw.text = require("mw.text")
mw.html = require("mw.html")

-- Minimal stub for getCurrentFrame
mw.getCurrentFrame = function()
    return {
        expandTemplate = function() return "" end,
        args = {}
    }
end

-- Override require() to simulate MediaWiki’s Module:Name resolution
local real_require = require
function require(name)
    -- Attempt normal require first (for standard libraries)
    local ok, result = pcall(real_require, name)
    if ok then return result end

    -- Strip "Module:" prefix for MediaWiki-style requires
    local moduleName = name:gsub("^Module:", "")
    local path = module_path .. "/" .. moduleName .. ".lua"

    local file = io.open(path, "r")
    if file then
        file:close()
        return dofile(path)
    else
        error("Cannot find module: " .. name .. " at path: " .. path)
    end
end

-- Override mw.title.new to work with local modules/subpages (simplified)
local original_mw_title_new = mw.title and mw.title.new

function mw.title.new(title)
    if not title:match("^Module:") then
        return original_mw_title_new and original_mw_title_new(title) or { exists = false, getContent = function() return nil end }
    end

    local base = module_path .. "/" .. title:gsub("^Module:", "")

    -- If the title already has an extension (.json or .csv or .lua), use it directly
    if base:match("%.[^/]+$") then
        local file = io.open(base, "r")
        if file then
            local content = file:read("*a")
            file:close()
            return { exists = true, getContent = function() return content end }
        end
    else
        -- No extension in title → try .lua only (per your rule)
        local luaPath = base .. ".lua"
        local file = io.open(luaPath, "r")
        if file then
            local content = file:read("*a")
            file:close()
            return { exists = true, getContent = function() return content end }
        end
    end

    -- Not found
    return { exists = false, getContent = function() return nil end }
end

-- Replace php.decodeJSON with this lua library
local json = require("dkjson")
mw.text.jsonDecode = function(str)
    return json.decode(str)
end

-- Load the target module passed from launch.json (the current file)
local target = os.getenv("TARGET")
if not target or target == "" then
    print("Usage: open a Lua file and press F5 to debug it.")
    os.exit(1)
end

print("[mw_runner] Debugging module:", target)
dofile(target)
