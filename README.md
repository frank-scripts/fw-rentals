# fw-rentals
QBOX Compatible Rental System on your FiveM server... Just like Prodigy RP 2.0 UI.
A vehicle rental system for QBX servers featuring a custom NUI menu with a 3D tilted design.

## Dependencies

- [ox_lib](https://overextended.dev/ox_lib)
- [ox_target](https://overextended.dev/ox_target)
- [ox_inventory](https://overextended.dev/ox_inventory)
- [qbx_core](https://github.com/Qbox-project/qbx_core)
- [PolyZone](https://github.com/mkafrin/PolyZone)

## Installation

1. Place the resource in your resources folder
2. Ensure all dependencies are installed and started
3. Add `ensure qbx_rentals` to your server.cfg
4. Build the web UI (see Web UI section below)

## File Structure

```
fw-rentals/
├── fxmanifest.lua          # Resource manifest
├── config/
│   ├── client.lua          # Client config (debug mode)
│   └── server.lua          # Rental locations, vehicles, pricing
├── client/
│   ├── client.lua          # Main client logic (spawning, targeting, NUI)
│   ├── main.lua            # Additional client code
│   └── nui.lua             # NUI helper functions (Open, Close, SendMessage)
├── server/
│   ├── main.lua            # Additional server code
│   └── server.lua          # Server callbacks (money check, vehicle spawning)
└── web/
    ├── App.tsx             # Main React app entry
    ├── components/
    │   └── RentalMenu.tsx  # Rental menu UI component
    ├── hooks/
    │   └── useNui.ts       # NUI communication hooks
    ├── styles.css          # Global styles
    └── index.tsx           # React root
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
    { model = 'futo', cost = 600 },
    { model = 'bison', cost = 800 },
}

bikes = {
    { model = 'scorcher', cost = 20 },
    { model = 'bmx', cost = 40 },
}
```

### config/client.lua

```lua
return {
    debug = false  -- Shows PolyZone debug zones when true
}
```

## Web UI

The UI is built with React + TypeScript. The menu features a 3D tilted perspective and dynamic scroll fade.

### Building

```bash
cd web
npm install
npm run build
```

The build output goes to `web/dist/` which is loaded by FiveM.

### Preview Mode

Run `npm run dev` to preview the UI in a browser with mock data.

## NUI Communication

### Events (Client → UI)

| Action | Data | Description |
|--------|------|-------------|
| `open` | `{ vehicles: Vehicle[] }` | Opens the menu with vehicle list |
| `close` | - | Closes the menu |

### Callbacks (UI → Client)

| Callback | Data | Response | Description |
|----------|------|----------|-------------|
| `selectVehicle` | `{ vehicleId: string }` | `{ success: true }` | Player selects a vehicle |

### Vehicle Data Structure

```typescript
interface Vehicle {
    id: string;          // Vehicle model name
    name: string;        // Display name
    description: string; // Cost info (e.g., "$600 rental fee.")
}
```

## Server Callbacks

| Callback | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `qbx_rentals:server:getTables` | `rentalType` ('locations'/'car'/'bike') | table | Fetches config tables |
| `qbx_rentals:server:moneyCheck` | `source, model, cost, rentalType` | boolean | Validates & deducts payment |
| `qbx_rentals:server:spawnVehicle` | `source, model, coords` | netId | Spawns rental vehicle |
| `qbx_rentals:server:deleteVehicle` | `source, netId` | boolean | Deletes rental vehicle |

## Features

- **Car Rentals**: NPC-based interaction at multiple city locations
- **Bike Rentals**: Static bike models at scenic locations (no NPC)
- **Targeting**: Uses ox_target sphere zones for interaction
- **Blips**: Map markers for car rental locations
- **Rental Papers**: Gives inventory item with vehicle details
- **Vehicle Keys**: Integrates with vehiclekeys system
- **Payment**: Deducts cash from player inventory

## Credits

Inspired by qb-rentals by Carbon#1002 and g-bikerentals by Giana.
