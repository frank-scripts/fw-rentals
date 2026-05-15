local config            = require 'config.client'
local currentSpawnPoint = 0
local rentalLocations   = {}
local cars              = {}
local bikes             = {}
local rentalVehicle     = 0

rentalLocations = lib.callback.await('qbx_rentals:server:getTables', false, 'locations')
cars = lib.callback.await('qbx_rentals:server:getTables', false, 'car')
bikes = lib.callback.await('qbx_rentals:server:getTables', false, 'bike')

-- NUI Callback for vehicle selection
RegisterNuiCallback('selectVehicle', function(data, cb)
    cb({ success = true })
    NUI.Close()
    
    local vehicleId = data.vehicleId
    local model, deposit, payment, rentalType
    
    -- Find the vehicle in cars or bikes
    for i = 1, #cars do
        if cars[i].model == vehicleId then
            model = cars[i].model
            deposit = cars[i].cost.deposit
            payment = cars[i].cost.payment
            rentalType = 'car'
            break
        end
    end
    
    if not model then
        for i = 1, #bikes do
            if bikes[i].model == vehicleId then
                model = bikes[i].model
                deposit = bikes[i].cost.deposit
                payment = bikes[i].cost.payment
                rentalType = 'bike'
                break
            end
        end
    end
    
    if model then
        TriggerEvent('qbx_rentals:client:spawnCar', model, deposit, payment, rentalType)
    end
end)

-- Events

RegisterNetEvent('qbx_rentals:client:openMenu', function(rentalType)
    local vehicles = {}
    
    if rentalType == 'car' then
        for i = 1, #cars do
            local v = cars[i]
            vehicles[i] = {
                id = v.model,
                make = v.make,
                name = v.label,
                description = v.description,
                deposit = v.cost.deposit,
                payment = v.cost.payment
            }
        end
    elseif rentalType == 'bike' then
        for i = 1, #bikes do
            local v = bikes[i]
            vehicles[i] = {
                id = v.model,
                make = v.make,
                name = v.label,
                description = v.description,
                deposit = v.cost.deposit,
                payment = v.cost.payment
            }
        end
    end
    
    NUI.Open({ vehicles = vehicles })
end)

RegisterNetEvent('qbx_rentals:client:spawnCar', function(model, deposit, payment, rentalType)
    local player = PlayerPedId()
    local spawnPoint

    for i = 1, #rentalLocations do
        if IsAnyVehicleNearPoint(rentalLocations[i].spawnPoint.x, rentalLocations[i].spawnPoint.y, rentalLocations[i].spawnPoint.z, 2.0) then
            lib.notify({
                title       = 'Area Blocked',
                description = 'Something is in the way!',
                type        = 'error'
            })
            return
        end
    end

    spawnPoint = currentSpawnPoint

    if spawnPoint == 0 then
        return
    end

    local canPurchase = lib.callback.await('qbx_rentals:server:moneyCheck', false, model, deposit, payment, rentalType)

    if not canPurchase then             
        lib.notify({
            title       = 'No money',
            description = 'You do not have the appropriate cash to rent this item',
            type        = 'error'
        })
        return
    end

    local netId = lib.callback.await('qbx_rentals:server:spawnVehicle', false, model, spawnPoint)

    rentalVehicle = netId
end)

RegisterNetEvent('qbx_rentals:client:returnVehicle', function()
    if rentalVehicle == 0 then return end

    local delVeh = lib.callback.await('qbx_rentals:server:deleteVehicle', false, rentalVehicle)

    if delVeh then
        rentalVehicle = 0
    end
end)

-- Functions

local createNPC = function()
    for k, ped in pairs(rentalLocations) do
        if ped.pedHash then
            local createdPed = CreatePed(5, ped.pedHash, ped.coords.x, ped.coords.y, ped.coords.z, ped.coords.w, false, false)
            SetModelAsNoLongerNeeded(ped.pedHash)
            FreezeEntityPosition(createdPed, true)
            SetEntityInvincible(createdPed, true)
            SetBlockingOfNonTemporaryEvents(createdPed, true)
            TaskStartScenarioInPlace(createdPed, 'WORLD_HUMAN_CLIPBOARD', 0, true)
        end
    end
end

local spawnNPC = function()
    for k, ped in pairs(rentalLocations) do
        if ped.pedHash then
            RequestModel(ped.pedHash)
            while not HasModelLoaded(ped.pedHash) do
                Wait(5)
            end
        end       
    end
    createNPC()
end

local createBike = function()
    for k, bike in pairs(rentalLocations) do
        if bike.bikeHash then
            local createdBike = CreateVehicle(bike.bikeHash, bike.coords.x, bike.coords.y, bike.coords.z, false, false)
            SetModelAsNoLongerNeeded(bike.bikeHash)
            SetEntityAsMissionEntity(createdBike, true, true)
            SetVehicleOnGroundProperly(createdBike)
            SetEntityInvincible(createdBike, true)
            SetVehicleDirtLevel(createdBike, 0.0)
            SetVehicleDoorsLocked(createdBike, 3)
            FreezeEntityPosition(createdBike, true)
            SetVehicleNumberPlateText(createdBike, 'Rent Me')
        end
    end
end

local spawnBike = function()
    for k, bike in pairs(rentalLocations) do
        if bike.bikeHash then
            RequestModel(bike.bikeHash)
            while not HasModelLoaded(bike.bikeHash) do
                Wait(5)
            end
        end
    end
    createBike()
end

CreateThread(function()
    spawnNPC()
    spawnBike()

    for k, rentals in pairs(rentalLocations) do
        exports.ox_target:addSphereZone({
            coords      = rentals.coords,
            size        = vec3(1, 1, 2),
            rotation    = -20,
            debug = config.debug,
            options = {
                {
                    icon = 'fa fa-briefcase',
                    label = 'Rentals',
                    onSelect = function()
                        currentSpawnPoint = rentals.spawnPoint
                        TriggerEvent('qbx_rentals:client:openMenu', rentals.rentalType)
                    end,
                    distance = 2,
                }
            }
        })

        if rentals.rentalType == 'car' then
            rentals.blip = AddBlipForCoord(rentals.coords.x, rentals.coords.y, rentals.coords.z)
            SetBlipSprite(rentals.blip, 56)
            SetBlipDisplay(rentals.blip, 4)
            SetBlipScale(rentals.blip, 0.65)
            SetBlipColour(rentals.blip, 50)
            SetBlipAsShortRange(rentals.blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentSubstringPlayerName(rentals.label)
            EndTextCommandSetBlipName(rentals.blip)
        end
    end
end)
