--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
    
    Modified to use custom fw-rentals UI system
]]

---@type { [string]: MenuProps }
local registeredMenus = {}
---@type MenuProps | nil
local openMenu

---@alias MenuPosition 'top-left' | 'top-right' | 'bottom-left' | 'bottom-right'
---@alias MenuChangeFunction fun(selected: number, scrollIndex?: number, args?: any, checked?: boolean)

---@class MenuOptions
---@field label string
---@field progress? number
---@field colorScheme? string
---@field icon? string | {[1]: IconProp, [2]: string};
---@field iconColor? string
---@field values? table<string | { label: string, description: string }>
---@field checked? boolean
---@field description? string
---@field defaultIndex? number
---@field args? {[any]: any}
---@field close? boolean

---@class MenuProps
---@field id string
---@field title string
---@field options MenuOptions[]
---@field position? MenuPosition
---@field disableInput? boolean
---@field canClose? boolean
---@field onClose? fun(keyPressed?: 'Escape' | 'Backspace')
---@field onSelected? MenuChangeFunction
---@field onSideScroll? MenuChangeFunction
---@field onCheck? MenuChangeFunction
---@field cb? MenuChangeFunction

--- Convert ox_lib position to fw-menu position
---@param position? MenuPosition
---@return 'left' | 'right'
local function convertPosition(position)
    if position == 'top-left' or position == 'bottom-left' then
        return 'left'
    end
    return 'right'
end

--- Convert ox_lib menu options to fw-menu items (display only)
---@param options MenuOptions[]
---@return table[]
local function convertToMenuItems(options)
    local items = {}
    
    for i, option in ipairs(options) do
        items[i] = {
            id = tostring(i),
            label = option.label,
            description = option.description,
            icon = type(option.icon) == 'table' and option.icon[2] or option.icon,
            closeOnClick = option.close ~= false,
        }
    end
    
    return items
end

---@param data MenuProps
---@param cb? MenuChangeFunction
function lib.registerMenu(data, cb)
    if not data.id then error('No menu id was provided.') end
    if not data.title then error('No menu title was provided.') end
    if not data.options then error('No menu options were provided.') end
    data.cb = cb
    registeredMenus[data.id] = data
end

---@param id string
---@param startIndex? number
function lib.showMenu(id, startIndex)
    local menu = registeredMenus[id]
    if not menu then
        error(('No menu with id %s was found'):format(id))
    end

    if table.type(menu.options) == 'empty' then
        error(('Can\'t open empty menu with id %s'):format(id))
    end
    
    if openMenu then
        lib.hideMenu(false)
    end

    openMenu = menu

    -- Convert to fw-menu format and open
    local items = convertToMenuItems(menu.options)
    local position = convertPosition(menu.position)
    
    exports['fw-rentals']:openMenu(menu.id, menu.title, items, {
        position = position,
        callback = function(item, menuId)
            if not item or not item.id then return end
            
            -- Convert id to number (like original ox_lib: data[1] += 1)
            local selected = tonumber(item.id)
            if not selected then return end
            
            -- LOOK UP FROM THE ORIGINAL registeredMenus TABLE - this preserves functions!
            local option = openMenu.options[selected]
            if not option then return end
            
            local args = option.args
            
            -- Trigger the callback exactly like original ox_lib
            -- Original: menu.cb(data[1], data[2], menu.options[data[1]].args, data[3])
            if openMenu.cb then
                openMenu.cb(selected, nil, args, nil)
            end
        end
    })
end

---@param onExit boolean?
function lib.hideMenu(onExit)
    local menu = openMenu
    openMenu = nil

    if not menu then return end

    exports['fw-rentals']:closeMenu()

    if onExit and menu.onClose then
        menu.onClose()
    end
end

---@param id string
---@param options MenuOptions | MenuOptions[]
---@param index? number
function lib.setMenuOptions(id, options, index)
    if index then
        registeredMenus[id].options[index] = options
    else
        if not options[1] then error('Invalid override format used, expected table of options.') end
        registeredMenus[id].options = options
    end
end

---@return string?
function lib.getOpenMenu() return openMenu and openMenu.id end
