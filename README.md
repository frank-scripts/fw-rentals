# fw-rentals

**Version 1.0.1**

QBOX Compatible Rental System for FiveM servers with a custom NUI menu inspired by Prodigy RP 2.0.

## Dependencies

- [ox_lib](https://overextended.dev/ox_lib)
- [ox_target](https://overextended.dev/ox_target)
- [ox_inventory](https://overextended.dev/ox_inventory)
- [qbx_core](https://github.com/Qbox-project/qbx_core)
- [PolyZone](https://github.com/mkafrin/PolyZone)

## Installation

1. Download or clone this resource into your server's `resources` folder
2. Ensure all dependencies are installed and running
3. Build the web UI:
   ```bash
   cd web
   npm install
   npm run build
   ```
4. Add `ensure fw-rentals` to your `server.cfg` (after dependencies)
5. Configure rental locations and vehicles in `config/server.lua`
6. Restart your server or refresh resources

## Optional: Replace ox_lib Menus

This resource includes modified ox_lib files that replace the default ox_lib menus with the custom purple UI. This allows you to use the same UI style across your entire server.

### Steps to Replace ox_lib Menus

1. Navigate to your `ox_lib/resource/interface/client/` folder
2. Replace the following files with the versions from this resource:
   - `menu.lua` → Use `/REPLACE ME OX LIB/menu.lua`
   - `context.lua` → Use `/REPLACE ME OX LIB/context.lua`
3. Restart your server

### What This Does

- `lib.showMenu()` and `lib.registerMenu()` will use the custom UI
- `lib.showContext()` and `lib.registerContext()` will use the custom UI
- All existing ox_lib menu calls in your other resources will automatically use the new UI
- Callbacks (`onSelect`, `event`, `serverEvent`) work exactly as before

### Compatibility

- Works with existing resources using ox_lib menus
- No changes needed to your other scripts
- Supports all ox_lib menu features (icons, descriptions, callbacks, nested menus)

## File Structure

```
fw-rentals/
+-- fxmanifest.lua              # Resource manifest
+-- config/
|   +-- client.lua              # Client config (debug mode)
|   +-- server.lua              # Rental locations, vehicles, pricing
+-- client/
|   +-- client.lua              # Main client logic (spawning, targeting, NUI)
|   +-- main.lua                # Additional client code
|   +-- nui.lua                 # NUI helper functions (Open, Close, SendMessage)
|   +-- menu.lua                # Custom menu system exports
+-- server/
|   +-- main.lua                # Additional server code
|   +-- server.lua              # Server callbacks (money check, vehicle spawning)
+-- web/
|   +-- App.tsx                 # Main React app entry
|   +-- components/
|   |   +-- RentalMenu.tsx      # Rental menu UI component
|   |   +-- Menu.tsx            # Generic menu component
|   +-- hooks/
|   |   +-- useNui.ts           # NUI communication hooks
|   +-- styles.css              # Global styles
|   +-- index.tsx               # React root
+-- REPLACE ME OX LIB/
    +-- menu.lua                # ox_lib menu replacement
    +-- context.lua             # ox_lib context replacement
```

## Configuration

### config/server.lua

**Rental Locations:**
```lua
rentalLocations = {
    {
        label       = 'Car Rentals',     -- Blip label
        rentalType  = 'car',             -- 'car' or 'bike'
        coords      = vec4(x, y, z, w),  -- NPC/interaction position
        pedHash     = `a_m_y_business_03`, -- Ped model (cars only)
        spawnPoint  = vec4(x, y, z, w),  -- Vehicle spawn location
    },
    -- Bike locations use bikeHash instead of pedHash
}
```

**Vehicles:**
```lua
cars = {
    { make = 'BF', model = 'faggio', label = 'Faggio', description = 'A cheap scooter', cost = { deposit = 100, payment = 50 } },
    { make = 'Vapid', model = 'bison', label = 'Bison', description = 'A work truck', cost = { deposit = 200, payment = 150 } },
}

bikes = {
    { make = 'Pedal', model = 'scorcher', label = 'Scorcher', description = 'Mountain bike', cost = { deposit = 20, payment = 10 } },
}
```

### config/client.lua

```lua
return {
    debug = false  -- Shows PolyZone debug zones when true
}
```

## Web UI

The UI is built with React + TypeScript featuring:
- 3D tilted perspective
- Dynamic scroll fade
- Custom purple scrollbar
- Right-side positioning

### Building

```bash
cd web
npm install
npm run build
```

The build output goes to `web/dist/` which is loaded by FiveM.

### Preview Mode

Run `npm run dev` to preview the UI in a browser with mock data.

## Exports

### Client Exports (menu.lua)

```lua
-- Open a custom menu
exports['fw-rentals']:openMenu(id, title, items, options)

-- Close the current menu
exports['fw-rentals']:closeMenu()

-- Register a reusable menu
exports['fw-rentals']:registerMenu(id, data)

-- Open a registered menu
exports['fw-rentals']:openRegisteredMenu(id)
```

## Features

- **Car Rentals**: NPC-based interaction at multiple city locations
- **Bike Rentals**: Static bike models at scenic locations (no NPC)
- **Targeting**: Uses ox_target sphere zones for interaction
- **Blips**: Map markers for car rental locations
- **Rental Papers**: Gives inventory item with vehicle details
- **Vehicle Keys**: Integrates with vehiclekeys system
- **Payment**: Deducts cash from player inventory
- **Custom UI**: Purple-themed menu with 3D tilt and smooth animations

---

## Changelog

### Version 1.0.1
- Improved UI fade at bottom for when it has a scroll menu
- All New scrollbar Inspired from Prodigys
- Improved UI Support for OX LIB Context Menu and OX LIB Menus
- Added more vehicles to rental options and descriptions to the vehicles instead of showing model name and just price

### Version 1.0.0
- Simple Menu for Rental System Inspired from Prodigy RP 2.0, with basic cars setup and bike rentals for QBX

---

## Credits

Inspired by Prodigy RP 2.0 UI for their Rental System.
