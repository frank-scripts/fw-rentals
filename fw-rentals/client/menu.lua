---@class MenuAPI
---@field private menus table<string, MenuData>
---@field private currentMenu string|nil
MenuAPI = {
    menus = {},
    currentMenu = nil
}

---@class MenuData
---@field id string
---@field title string
---@field items MenuItem[]
---@field position 'left'|'right'
---@field callback function|nil

---@class MenuItem
---@field id string
---@field label string
---@field description? string
---@field icon? string
---@field metadata? table
---@field closeOnClick? boolean Default: true

--- Register a menu definition (can be opened later by ID)
---@param id string Unique menu identifier
---@param title string Menu title displayed in header
---@param items MenuItem[] Array of menu items
---@param options? { position?: 'left'|'right', callback?: function }
function MenuAPI.Register(id, title, items, options)
    options = options or {}
    MenuAPI.menus[id] = {
        id = id,
        title = title,
        items = items,
        position = options.position or 'right',
        callback = options.callback
    }
end

--- Open a registered menu by ID
---@param id string The menu ID to open
function MenuAPI.Open(id)
    local menu = MenuAPI.menus[id]
    if not menu then
        return print('[fw-menu] Menu not found: ' .. id)
    end
    
    MenuAPI.currentMenu = id
    NUI.Open({
        menuId = id,
        title = menu.title,
        items = menu.items,
        position = menu.position
    })
end

--- Open a menu with inline data (no registration needed)
---@param id string Unique identifier for this menu instance
---@param title string Menu title
---@param items MenuItem[] Menu items
---@param options? { position?: 'left'|'right', callback?: function }
function MenuAPI.OpenWith(id, title, items, options)
    options = options or {}
    MenuAPI.Register(id, title, items, options)
    MenuAPI.Open(id)
end

--- Close the current menu
function MenuAPI.Close()
    if MenuAPI.currentMenu then
        NUI.Close()
        MenuAPI.currentMenu = nil
    end
end

--- Check if a menu is currently open
---@return boolean
function MenuAPI.IsOpen()
    return MenuAPI.currentMenu ~= nil
end

--- Get the currently open menu ID
---@return string|nil
function MenuAPI.GetCurrentMenu()
    return MenuAPI.currentMenu
end

--- Remove a registered menu
---@param id string Menu ID to remove
function MenuAPI.Remove(id)
    MenuAPI.menus[id] = nil
end

--- Update items in a registered menu
---@param id string Menu ID
---@param items MenuItem[] New items
function MenuAPI.UpdateItems(id, items)
    local menu = MenuAPI.menus[id]
    if menu then
        menu.items = items
        -- If this menu is currently open, refresh it
        if MenuAPI.currentMenu == id then
            NUI.SendMessage('updateItems', { items = items })
        end
    end
end

-- Handle item selection from NUI
RegisterNuiCallback('menuSelect', function(data, cb)
    cb({ success = true })
    
    print('[fw-menu] menuSelect received:')
    print('  - data: ' .. json.encode(data))
    
    local menuId = MenuAPI.currentMenu
    if not menuId then 
        print('[fw-menu] No current menu')
        return 
    end
    
    local menu = MenuAPI.menus[menuId]
    if not menu then 
        print('[fw-menu] Menu not found: ' .. tostring(menuId))
        return 
    end
    
    local item = data and data.item
    if not item then 
        print('[fw-menu] No item in data')
        return 
    end
    
    print('[fw-menu] Item selected:')
    print('  - id: ' .. tostring(item.id))
    print('  - label: ' .. tostring(item.label))
    print('  - has callback: ' .. tostring(menu.callback ~= nil))
    
    local closeOnClick = item.closeOnClick
    if closeOnClick == nil then closeOnClick = true end
    
    -- Trigger callback if defined
    if menu.callback then
        print('[fw-menu] Calling callback...')
        local success, err = pcall(menu.callback, item, menuId)
        if not success then
            print('[fw-menu] Callback error: ' .. tostring(err))
        else
            print('[fw-menu] Callback completed successfully')
        end
    else
        print('[fw-menu] No callback defined for menu')
    end
    
    -- Trigger exported event for external scripts
    TriggerEvent('fw-menu:itemSelected', menuId, item)
    
    -- Close menu if closeOnClick is true
    if closeOnClick then
        MenuAPI.Close()
    end
end)

-- Exports for external resources
exports('openMenu', function(id, title, items, options)
    MenuAPI.OpenWith(id, title, items, options)
end)

exports('closeMenu', function()
    MenuAPI.Close()
end)

exports('registerMenu', function(id, title, items, options)
    MenuAPI.Register(id, title, items, options)
end)

exports('openRegisteredMenu', function(id)
    MenuAPI.Open(id)
end)

exports('isMenuOpen', function()
    return MenuAPI.IsOpen()
end)

exports('updateMenuItems', function(id, items)
    MenuAPI.UpdateItems(id, items)
end)

exports('removeMenu', function(id)
    MenuAPI.Remove(id)
end)
