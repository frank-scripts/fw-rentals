--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
    
    Modified to use custom fw-rentals UI system
]]

local contextMenus = {}
local openContextMenu = nil

---@class ContextMenuItem
---@field title? string
---@field menu? string
---@field icon? string | {[1]: IconProp, [2]: string};
---@field iconColor? string
---@field image? string
---@field progress? number
---@field onSelect? fun(args: any)
---@field arrow? boolean
---@field description? string
---@field metadata? string | { [string]: any } | string[]
---@field disabled? boolean
---@field readOnly? boolean
---@field event? string
---@field serverEvent? string
---@field args? any

---@class ContextMenuArrayItem : ContextMenuItem
---@field title string

---@class ContextMenuProps
---@field id string
---@field title string
---@field menu? string
---@field onExit? fun()
---@field onBack? fun()
---@field canClose? boolean
---@field options { [string]: ContextMenuItem } | ContextMenuArrayItem[]

local function closeContext(_, cb, onExit)
    if cb then cb(1) end

    if not openContextMenu then return end

    if (cb or onExit) and contextMenus[openContextMenu].onExit then 
        contextMenus[openContextMenu].onExit() 
    end

    exports['fw-rentals']:closeMenu()
    openContextMenu = nil
end

--- Convert ox_lib context options to fw-menu items (display only)
---@param options table
---@return table[]
local function convertToMenuItems(options)
    local items = {}
    
    -- Handle array-style options
    if options[1] then
        for i, option in ipairs(options) do
            items[i] = {
                id = tostring(i),
                label = option.title or ('Option ' .. i),
                description = option.description,
                icon = type(option.icon) == 'table' and option.icon[2] or option.icon,
                closeOnClick = not option.readOnly,
            }
        end
    else
        -- Handle table-style options (key-value pairs)
        local idx = 1
        for key, option in pairs(options) do
            items[idx] = {
                id = tostring(idx), -- Use numeric index for lookup
                label = option.title or tostring(key),
                description = option.description,
                icon = type(option.icon) == 'table' and option.icon[2] or option.icon,
                closeOnClick = not option.readOnly,
            }
            idx = idx + 1
        end
    end
    
    return items
end

---@param id string
function lib.showContext(id)
    if not contextMenus[id] then error('No context menu of such id found.') end

    local data = contextMenus[id]
    openContextMenu = id

    -- Convert options for display
    local items = convertToMenuItems(data.options)

    -- Open custom menu - callback will look up from contextMenus DIRECTLY
    exports['fw-rentals']:openMenu(id, data.title, items, {
        position = 'right',
        callback = function(item, menuId)
            if not item or not item.id then return end
            
            -- Convert id to number for array lookup (like original ox_lib does)
            local idx = tonumber(item.id)
            if not idx then return end
            
            -- LOOK UP FROM THE ORIGINAL contextMenus TABLE - this preserves functions!
            local option = contextMenus[openContextMenu].options[idx]
            if not option then 
                print('[ox_lib context] No option found at index: ' .. idx)
                return 
            end
            
            -- Handle nested menu navigation
            if option.menu then
                if data.onBack then data.onBack() end
                lib.showContext(option.menu)
                return
            end
            
            -- Execute callbacks exactly like original ox_lib
            if option.onSelect then option.onSelect(option.args) end
            if option.event then TriggerEvent(option.event, option.args) end
            if option.serverEvent then TriggerServerEvent(option.serverEvent, option.args) end
            
            closeContext(false)
        end
    })
end

---@param context ContextMenuProps | ContextMenuProps[]
function lib.registerContext(context)
    for k, v in pairs(context) do
        if type(k) == 'number' then
            contextMenus[v.id] = v
        else
            contextMenus[context.id] = context
            break
        end
    end
end

---@return string?
function lib.getOpenContextMenu() return openContextMenu end

---@param onExit boolean?
function lib.hideContext(onExit) closeContext(nil, nil, onExit) end
