--BUG: will not start right (Nil JobName) if in character select when script starts
local PulledOutCars = {} --Used for event-based updates on vehicles currently pulled out
local retreiveFromImpoundCosts = {}
local StoredCars = {}
local ImpoundedCars = {}
local MyIdentity
local ESX
local currentCar
local JobName


--AddEventHandler('kashacters:PlayerSpawned', function()
AddEventHandler("kashacters:PlayerSpawned", function()
    RequestModel("s_m_y_xmech_01") --Andy mech driving civ car
    RequestModel("s_m_y_xmech_02") --George mech driving getaway car

    exports.dfs:RegisterClientCallback("dfsga:CheckDistance", function(GarageID)
        if GarageID == 0 then
            return -1
        end
        return GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), Config.GarageLocations[GarageID].Pull, true) --BUG, no workie, attempt to index nil value ?
    end)


    AddTextEntry("DFS_GARAGES_STORE", "Press ~E~ to store your vehicle")
    AddTextEntry("DFS_GARAGES_PULL", "Press ~E~ to get a vehicle")
    AddTextEntry("DFS_GARAGES_RENAME", "Enter a name for your vehicle")
    WarMenu.CreateMenu("cdfsull", "Select a Vehicle to Request")
    WarMenu.CreateSubMenu("carselectpull", "cdfsull", "DEBUG_REPLACE")
    WarMenu.CreateMenu("recoverymain", "Select a vehicle to recover")
    WarMenu.CreateSubMenu("recoveryselector", "recoverymain", "2DEBUG_REPLACE2")
    while not MyIdentity do Wait(0) end
    JobName = MyIdentity.JobName
    while not ESX do
        TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)
        Wait(0)
    end
    --TriggerServerEvent("dfsg:Connected")
    __main__()

    TriggerServerEvent("dfsga:CheckInitMessage")
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    JobName = job

    for k, v in pairs(Config.GarageLocations) do
        RemoveBlip(v.BlipObject)
        Config.GarageLocations[k].BlipObject = nil
    end

    for k, v in pairs(Config.ImpoundLocations) do
        RemoveBlip(v.BlipObject)
        Config.ImpoundLocations[k].BlipObject = nil
    end

    RemoveBlip(Config.RecoveryLocationBlip)
    Config.RecoveryLocationBlip = nil
end)

--[[NOTE: GTA does NOT like long-distance transfers at all and will just shit itself.
local runningXfer = false
RegisterNetEvent("dfsga:StartVehicleTransfer")
AddEventHandler("dfsga:StartVehicleTransfer", function(garageIdToSpawnAt, vehicleDetails)
    if runningXfer then 
        return
    end
    runningXfer = true
    local offset = 1
    local success
    local position3
    print("Attempting to get roadside point")
    while not success do
        position3 = vector3(
            Config.GarageLocations[garageIdToSpawnAt].Pull.x + (math.random(offset)-offset/2), 
            Config.GarageLocations[garageIdToSpawnAt].Pull.y + (math.random(offset)-offset/2), --This crap is done because lua's math.random can't handle -0.1<>0.1
            Config.GarageLocations[garageIdToSpawnAt].Pull.z
        )
        success, position3 = GetPointOnRoadSide(position3.x, position3.y, position3.z, 1)
        offset = offset + 1
        Wait(0)
    end
    print("Got roadside point, creating your car...")
    local newPlayerCar = exports.dfs:SpawnVehicle(json.decode(vehicleDetails.vehicle).model, position3, 0.0, false, true, true, true, vehicleDetails.vehicle, json.decode(vehicleDetails.vehicle).plate, true)
    print("Done. Creating Andy...")
    local hotMech 
    while not DoesEntityExist(hotMech) do
        hotMech = CreatePedInsideVehicle(newPlayerCar, 25, GetHashKey("s_m_y_xmech_01"), -1, true, true)
        SetEntityAsMissionEntity(hotMech)
        Wait(0)
    end
    SetPedCanBeKnockedOffVehicle(hotMech, 1)
    while not IsPedInAnyVehicle(hotMech, false) do
        TaskEnterVehicle(hotMech, newPlayerCar, 1000, -1, 2.0, 1, 0.0)
        Wait(1000)
    end
    print("Done. Telling andy to drive at gunpoint.")
    TaskVehicleDriveToCoordLongrange(hotMech, newPlayerCar, GetEntityCoords(PlayerPedId()), 26.0, 262623, 2.5) --Fourth arg is "Speed". 26 is 59MPH, but we're going to try 79.
    local destPos = GetEntityCoords(PlayerPedId())
    AddBlipForEntity(newPlayerCar)
    AddBlipForEntity(hotMech)
    Wait(5000)
    print("Creating george's ride")
    local newChaseCar = exports.dfs:SpawnVehicle(GetHashKey("blade"), position3, 0.0, false, false, true, false, nil, "GA VALET", true)
    print("Creating george via primordial mushroom soup")
    local dudMech 
    while not DoesEntityExist(dudMech) do
        dudMech = CreatePedInsideVehicle(newChaseCar, 25, GetHashKey("s_m_y_xmech_02"), -1, true, true)
        SetEntityAsMissionEntity(dudMech)
        Wait(0)
    end
    print("Telling his ugly ass to drive")
    TaskVehicleEscort(dudMech, newChaseCar, newPlayerCar, -1, 26.0, 262623, 5.0, 0, 10.0)
    print("He be a drivin")
    AddBlipForEntity(newChaseCar)
    AddBlipForEntity(dudMech)
    
    while true do
        if GetDistanceBetweenCoords(destPos, GetEntityCoords(newPlayerCar)) < 25.0 then
            TaskLeaveVehicle(hotMech, newPlayerCar, 0)
            TaskEnterVehicle(hotMech, newChaseCar, 15000, 0, 2.0, 1, 0)
            Wait(15000)
            SetEntityAsNoLongerNeeded(hotMech)
            SetEntityAsNoLongerNeeded(dudMech)
            SetEntityAsNoLongerNeeded(newChaseCar)
            runningXfer = false
            return
        end

        Wait(0)
    end
end)]]

function __main__()
    print("Starting DFS_Garages!")
    local Sleep = 1000
    local PlayerCoords
    while true do
        Sleep = 1000
        PlayerCoords = GetEntityCoords(PlayerPedId())
        currentCar = GetVehiclePedIsIn(PlayerPedId(), false)
        for k, Garages in pairs(Config.GarageLocations) do
            if not Garages.JobRequired or table.Contains(Garages.JobRequired, JobName) then
                if GetDistanceBetweenCoords(Garages.Store, PlayerCoords, true) < 30.0 and IsPedInVehicleOfType(Garages.Type)  then
                    --         type,                         x,                 y,                  z,              dirx, diry, dirz,   rotx, roty, rotz,   scalex, scaley, scalez, r,   g, b, a,   bounce, facecam, unk,   texd, texn, drawonentsonly
                    DrawMarker(3,                            Garages.Store.x,    Garages.Store.y,    Garages.Store.z + 0.75, 0.0, 0.0, 0.0,     0.0, 0.0, 0.0,      1.0,    1.0,   -1.0,    255, 0, 0, 255, false,   true,   0,      nil, nil, false)
                    DrawMarker(GetMarkerID(Garages.Type), Garages.Store.x,    Garages.Store.y,    Garages.Store.z, 0.0, 0.0, 0.0,     0.0, 0.0, 0.0,      1.0,    1.0,    1.0,    255, 0, 0, 255, false,   true,   0,      nil, nil, false)
                    Sleep = 0
                    DisplayHelpTextThisFrame("Press ~E~ to store your "..Garages.Type, false)
                    if IsControlJustPressed(0, 38) and GetDistanceBetweenCoords(Garages.Store, PlayerCoords, true) < 7.5 then
                        if exports.dfs_PoliceJob:IsCop() or VerifyOwnershipOfVehicle(GetVehicleNumberPlateText(currentCar)) then
                            exports.dfs:TriggerServerCallback("dfspj:CheckBolo", function(Active)
                                if Active then
                                    exports.mythic_notify:SendAlert("inform", "The valet won't take this car because he would have to report it to the police!", 10000)
                                else
                                    TriggerEvent('persistent-vehicles/forget-vehicle', currentCar)
                                    UpdateVehicle(currentCar, "STORECAR", nil, nil, nil, k, nil, nil)
                                    TaskLeaveVehicle(PlayerPedId(), currentCar, 0)
                                    exports.dfs:DeleteVehicle(currentCar)
                                end
                            end, GetVehicleNumberPlateText(currentCar))
                        end
                    end
                end

                if GetDistanceBetweenCoords(Garages.Pull, PlayerCoords, true) < 15.0 and not IsPedInAnyVehicle(PlayerPedId(), true) then
                    DrawMarker(3,                            Garages.Pull.x,    Garages.Pull.y,    Garages.Pull.z + 0.75, 0.0, 0.0, 0.0,     0.0, 0.0, 0.0,      1.0, 1.0, 1.0,          255, 0, 0, 255, false,   true,   0,      nil, nil, false)
                    DrawMarker(GetMarkerID(Garages.Type), Garages.Pull.x,    Garages.Pull.y,    Garages.Pull.z, 0.0, 0.0, 0.0,     0.0, 0.0, 0.0,      1.0, 1.0, 1.0,          255, 0, 0, 255, false,   true,   0,      nil, nil, false)
                    Sleep = 0
                    DisplayHelpTextThisFrame("Press ~E~ to request a "..Garages.Type.." from the valet", false)
                    if IsControlJustPressed(0, 38) and GetDistanceBetweenCoords(Garages.Pull, PlayerCoords, true) < 5.0 then
                        exports.dfs:TriggerServerCallback("dfsg:GetMyVehiclesAtGarage", function(TableData)
                            StoredCars = TableData
                        end, k)
                        WarMenu.OpenMenu("cdfsull")
                    end
                end

                if not Garages.BlipObject then
                    AddTextEntry("DFS_GARAGENAME_"..Garages.Name, Garages.Name)
                    Garages.BlipObject = AddBlipForCoord(Garages.Store+(Garages.Pull-Garages.Store))
                    SetBlipAsShortRange(Garages.BlipObject, true)
                    SetBlipColour(Garages.BlipObject, 38)
                    SetBlipDisplay(Garages.BlipObject, 6)
                    SetBlipScale(Garages.BlipObject, 0.75)
                    SetBlipSprite(Garages.BlipObject, GetBlipIDByType(Garages.Type))
                    SetBlipNameFromTextFile(Garages.BlipObject, "DFS_GARAGENAME_"..Garages.Name)
                end
            end
        end

        if GetDistanceBetweenCoords(Config.RecoveryLocation, PlayerCoords, true) < 15.0 then
            DrawMarker(29, Config.RecoveryLocation.x, Config.RecoveryLocation.y, Config.RecoveryLocation.z - 0.75, 0.0, 0.0, 0.0,     0.0, 0.0, 0.0,      1.0, 1.0, 1.0,          255, 0, 0, 255, false,   true,   0,      nil, nil, false)
            DrawMarker(21, Config.RecoveryLocation, 0.0, 0.0, 0.0,     0.0, 0.0, 0.0,      1.0, 1.0, 1.0,          255, 0, 0, 255, false,   true,   0,      nil, nil, false)
            DrawMarker(36, Config.RecoveryLocation.x, Config.RecoveryLocation.y, Config.RecoveryLocation.z + 0.75, 0.0, 0.0, 0.0,     0.0, 0.0, 0.0,      1.0, 1.0, 1.0,          255, 0, 0, 255, false,   true,   0,      nil, nil, false)
            Sleep = 0
            DisplayHelpTextThisFrame("Press ~E~ to recover a vehicle.")
            if IsControlJustPressed(0, 38) and GetDistanceBetweenCoords(Config.RecoveryLocation, PlayerCoords, true) < 5.0 then
                exports.dfs:TriggerServerCallback("dfsg:GetMyVehiclesAtGarage", function(TableData)
                    StoredCars = TableData
                end, 0)
                WarMenu.OpenMenu("recoverymain")
            end
        end

        if not Config.RecoveryLocationBlip then
            AddTextEntry("DFS_RECOVERYSTATION", "Track your Missing Vehicle! By G&A Valet")
            Config.RecoveryLocationBlip = AddBlipForCoord(Config.RecoveryLocation)
            SetBlipAsShortRange(Config.RecoveryLocationBlip, true)
            SetBlipColour(Config.RecoveryLocationBlip, 38)
            SetBlipDisplay(Config.RecoveryLocationBlip, 6)
            SetBlipScale(Config.RecoveryLocationBlip, 0.75)
            SetBlipSprite(Config.RecoveryLocationBlip, 490)
            SetBlipNameFromTextFile(Config.RecoveryLocationBlip, "DFS_RECOVERYSTATION")
        end

        for k, Impound in pairs(Config.ImpoundLocations) do
            if GetDistanceBetweenCoords(Impound.Loc, PlayerCoords, true) < 15.0 and not IsPedInAnyVehicle(PlayerPedId(), true) then
                DrawMarker(3,                            Impound.Loc.x,    Impound.Loc.y,    Impound.Loc.z + 0.75, 0.0, 0.0, 0.0,     0.0, 0.0, 0.0,      1.0, 1.0, 1.0,          255, 0, 0, 255, false,   true,   0,      nil, nil, false)
                DrawMarker(30, Impound.Loc.x,    Impound.Loc.y,    Impound.Loc.z, 0.0, 0.0, 0.0,     0.0, 90.0, 0.0,      1.0, 1.0, 1.0,          255, 0, 0, 255, false,   true,   0,      nil, nil, false)
                DrawMarker(GetMarkerID(Impound.Type), Impound.Loc.x,    Impound.Loc.y,    Impound.Loc.z, 0.0, 0.0, 0.0,     0.0, 0.0, 0.0,      1.0, 1.0, 1.0,          255, 0, 0, 255, false,   true,   0,      nil, nil, false)
                Sleep = 0
                DisplayHelpTextThisFrame("Press ~E~ to request your "..Impound.Type.." from the "..Impound.Name, false)
                if IsControlJustPressed(0, 38) and GetDistanceBetweenCoords(Impound.Loc, PlayerCoords, true) < 2.5 then
                    exports.dfs:TriggerServerCallback("dfsg:GetMyVehiclesAtGarage", function(TableData)
                        StoredCars = TableData
                    end, -k)
                    exports.dfs:TriggerServerCallback("dfsg:GetVehicleImpoundFees", function(tableData)
                        retreiveFromImpoundCosts = tableData
                    end)
                    WarMenu.OpenMenu("cdfsull")
                end
            end

            if not Impound.BlipObject then
                AddTextEntry("DFS_GARAGENAME_"..Impound.Name, Impound.Name)
                Impound.BlipObject = AddBlipForCoord(Impound.Loc)
                SetBlipAsShortRange(Impound.BlipObject, true)
                SetBlipColour(Impound.BlipObject, 38)
                SetBlipDisplay(Impound.BlipObject, 6)
                SetBlipScale(Impound.BlipObject, 0.75)
                SetBlipSprite(Impound.BlipObject, 107)
                SetBlipNameFromTextFile(Impound.BlipObject, "DFS_GARAGENAME_"..Impound.Name)
            end
        end
        Wait(Sleep)
    end
end

function VerifyOwnershipOfVehicle(Plate)
    return exports.dfs:TriggerServerCallback("dfsg:SelectOwnedVehicle", function(CarData)
        if CarData.owner == exports.dfs:GetMyIdentifiers().SteamID then --BUG: CRASH
            return true
        end
        return false
    end, Plate)
end

function GetBlipIDByType(Type)
    if Type == "plane" then 
        return 359
    elseif Type == "heli" then
        return 360
    elseif Type=="boat" then
        return 356
    elseif Type=="car" then
        return 524
    else
        return 387
    end
end

Citizen.CreateThread(function()
    local SelectedCarData
    local SelectedGarageId = 1
    local carStatus
    --WarMenu.debug = true
    while true do 
        if WarMenu.IsMenuOpened('cdfsull') then
            for k, Car in pairs(StoredCars) do
                if not Car.vehiclename then
                    Car.vehiclename = exports.dfs_PoliceJob:GetColorName(tonumber(Car.vehicle.color1)).." "..GetDisplayNameFromVehicleModel(Car.model)
                end
                if WarMenu.MenuButton(Car.vehiclename, "carselectpull") then
                    SelectedCarData = Car
                    SelectedGarageId = Car.garage_id
                    break
                end
            end
            DisableAllControlActions(0)
            WarMenu.Display()
        elseif WarMenu.IsMenuOpened('carselectpull') then
            if WarMenu.Button("Rename") then
                local newCarName = RenameCar(SelectedCarData.vehiclename)
                if not newCarName or #newCarName == 0 or #(newCarName):gsub(" ", "") == 0 then
                    newCarName = SelectedCarData.vehiclename
                end
                UpdateVehicle(nil, "WarMenu>RenameCar", SelectedCarData.plate, nil, newCarName, SelectedGarageId, nil, nil)
            elseif WarMenu.Button(SelectedGarageId > 0 and "Pull Out" or "Retreive $"..retreiveFromImpoundCosts[SelectedCarData.plate]) then
                WarMenu.CloseMenu()
                if SelectedGarageId < 0 then
                    exports.dfs:TriggerServerCallback("dfsg:PayImpoundFee", function(Success) 
                        if Success then
                            SpawnCar(SelectedCarData)
                        else
                            TriggerEvent('esx:showNotification', string.format('You need $~r~%s~w~ in Cash to retrieve this vehicle!', retreiveFromImpoundCosts[SelectedCarData.plate]))
                        end
                    end, retreiveFromImpoundCosts[SelectedCarData.plate])
                else
                    TriggerEvent("dfscl:GetKeysForCar", GetVehicleNumberPlateText(SpawnCar(SelectedCarData))) --Get car keys event, should autostart engine
                    SetPedIntoVehicle(PlayerPedId(), newCar, -1)
                end
            end
            DisableAllControlActions(0)
            WarMenu.Display()
        elseif WarMenu.IsMenuOpened("recoverymain") then
            for k, Car in pairs(StoredCars) do
                if not Car.vehiclename then
                    Car.vehiclename = exports.dfs_PoliceJob:GetColorName(tonumber(Car.vehicle.color1)).." "..GetDisplayNameFromVehicleModel(Car.model)
                end
                if WarMenu.MenuButton(Car.vehiclename, "recoveryselector") then
                    SelectedCarData = Car
                    SelectedGarageId = Car.garage_id
                    carStatus = GetCarStatus(Car.plate)
                    exports.dfs:TriggerServerCallback("dfsg:GetVehicleImpoundFees", function(tableData)
                        retreiveFromImpoundCosts = tableData
                    end)
                end
            end
            DisableAllControlActions(0)
            WarMenu.Display()
        elseif WarMenu.IsMenuOpened("recoveryselector") then
            if WarMenu.Button(carStatus == -1 and ("Recover $"..retreiveFromImpoundCosts[SelectedCarData.plate]) or not carStatus and "Report Stolen" or carStatus and ("Track $"..math.floor(retreiveFromImpoundCosts[SelectedCarData.plate]/10))) then
                if carStatus == -1 then
                    exports.dfs:TriggerServerCallback("dfsg:PayImpoundFee", function(Success)
                        if Success then
                            UpdateVehicle(nil, "WarMenu.recoverselector", SelectedCarData.plate, nil, nil, 10, nil, nil)
                            TriggerServerEvent("dfsg:SetVehicleRecovered", SelectedCarData.plate)
							ESX.ShowNotification("Your car is in the BCSO Vehicle Recovery Garage.")
                        else
                            ESX.ShowNotification("Your credit card was declined!")
                        end
                    end, retreiveFromImpoundCosts[SelectedCarData.plate])
                elseif not carStatus then
                    exports.dfs:TriggerServerCallback("dfspj:CreateBolo", function(success) 
                        exports.mythic_notify:SendAlert("success", "Your Vehicle with Plate: "..SelectedCarData.plate.." has been reported stolen!", 9999)
                    end, SelectedCarData.plate or "INVALID", "Reported 10-16; Stolen", 9999) 
                elseif carStatus then
                    exports.dfs:TriggerServerCallback("epv:FetchVehicle", function(evpData)
                        exports.dfs:TriggerServerCallback("dfsg:PayImpoundFee", function(Success)
                            if Success then
                                SetNewWaypoint(evpData.pos.x, evpData.pos.y)
                                TriggerEvent("alerts:addblip", evpData.pos.x, evpData.pos.y, evpData.pos.z, 33.3, nil, 620, false, 90000, false)
								ESX.ShowNotification("We've sent your vehicle's location to your GPS!")
                            else
								ESX.ShowNotification("Your credit card was declined!")
                            end
                        end, math.floor(retreiveFromImpoundCosts[SelectedCarData.plate]/10))
                    end, SelectedCarData.plate)
                end
                WarMenu.CloseMenu()
            else
                DisableAllControlActions(0)
                WarMenu.Display()
            end
        end
        if IsControlJustPressed(0, 177) then --	BACKSPACE / ESC / RIGHT MOUSE BUTTON
            WarMenu.CloseMenu()
        end
        Wait(0)
    end
end) 
--GetEntityCoords can be used as a substitue for the water, EngineHealth is server compatible, 
--BUG: Track even if it's been stolen as soon as it;s unattended
function GetCarStatus(Plate)
    local SelectedVehicle
    local SelectedVehiclePersistenceData 
    local LastDriver
    exports.dfs:TriggerServerCallback("epv:FetchVehicle", function(vehicleData)
        SelectedVehiclePersistenceData = vehicleData
    end, Plate)

    for k, Vehicle in pairs(exports.dfs:GetAllVehicles()) do
        if GetVehicleNumberPlateText(Vehicle) == Plate then
            SelectedVehicle = Vehicle
            break
        end
    end

    LastDriver = GetLastPedInVehicleSeat(SelectedVehicle, -1)
    if SelectedVehiclePersistenceData.pos.z < 0 then
        return -1 --Recoverable
    elseif DoesEntityExist(SelectedVehicle) or (DoesEntityExist(LastDriver) and LastDriver ~= PlayerPedId()) then
        return false --Stolen
    else
        return true --Can do tracker
    end
end

function SpawnCar(CarData)
    local newCar = exports.dfs:SpawnVehicle(CarData.vehicle.model, GetEntityCoords(PlayerPedId()), GetEntityHeading(PlayerPedId()), true, true, true, true, CarData.vehicle, CarData.vehicle.plate, true)

    if CarData.Damages then
        SetVehicleEngineHealth(newCar, CarData.Damages.EngineHealth)
        SetVehicleBodyHealth(newCar, CarData.Damages.BodyHealth)
        SetVehiclePetrolTankHealth(newCar, CarData.Damages.FuelTankHealth)
        for k, isDoorBroken in pairs(CarData.Damages.BrokenDoors) do
            if isDoorBroken then
                SetVehicleDoorBroken(newCar, k-1, true)
            end
        end
        for k, isWindowBroken in pairs(CarData.Damages.BrokenWindows) do
            if isWindowBroken then
                Citizen.CreateThread(function(windowIndex)
                    SmashVehicleWindow(newCar, k-1)
                end)
            end
        end
        for k, isTireBurst in pairs(CarData.Damages.BrokenTires) do
            if isTireBurst then
                SetVehicleTyreBurst(newCar, k-1, true, 1000)
            end
        end
    end
    local carPosition = GetEntityCoords(newCar)
    UpdateVehicle(newCar, "SPAWNCAR", nil, {x=carPosition.x, y=carPosition.y, z=carPosition.z}, nil, 0, nil, nil)
    return newCar
end


function table.Contains(set, item)
    for key, value in pairs(set) do
        if value == item then return true end
    end
    return false
end

function RenameCar(DefaultText)
    DisplayOnscreenKeyboard(1, "DFS_GARAGES_RENAME", "P2", DefaultText or "", "", "", "", 32) --First "" is defualt, rest ar ontop
    while UpdateOnscreenKeyboard() == 0 do
        DisableAllControlActions(0)
        Wait(0)
    end
    return GetOnscreenKeyboardResult()
end

function GetMarkerID(Type)
    if Type=="car" then
        return 36
    elseif Type=="heli" then 
        return 34
    elseif Type=="boat" then
        return 35
    elseif Type=="plane" then
        return 33
    else
        return 32
    end
end

function IsPedInVehicleOfType(Type)
    if GetPedInVehicleSeat(currentCar, -1) == PlayerPedId() then
        if Type=="heli" then
            return IsPedInAnyHeli(PlayerPedId())
        elseif Type=="plane" then 
            return IsPedInAnyPlane(PlayerPedId())
        elseif Type=="boat" then
            return IsPedInAnyBoat(PlayerPedId())
        elseif Type=="car" then 
            return IsPedInAnyVehicle(PlayerPedId()) and (IsThisModelACar(GetEntityModel(GetVehiclePedIsIn(PlayerPedId(), false))) or IsThisModelABike(GetEntityModel(GetVehiclePedIsIn(PlayerPedId(), false)))) or IsThisModelAQuadbike(GetEntityModel(GetVehiclePedIsIn(PlayerPedId(), false)))
        end
    end
    return false
end

Citizen.CreateThread(function()
    while true do
        MyIdentity = exports.dfs:GetMyIdentity()
        TriggerEvent('persistent-vehicles/server/update-vehicle', GetVehiclePedIsIn(PlayerPedId(), false))
        Wait(60000)
    end
end)

RegisterNetEvent("dfsg:DeleteVehicle")
AddEventHandler("dfsg:DeleteVehicle", function(VehiclePlate)
    for k, v in pairs(exports.dfs:GetAllVehicles()) do
        if VehiclePlate == GetVehicleNumberPlateText(v) then
            TriggerEvent('persistent-vehicles/forget-vehicle', v)
            exports.dfs:DeleteVehicle(v)
            return
        end
    end
end)

RegisterCommand("impound", function()
    local CarTarget = exports.dfs:GetVehicleInFrontOfMe()
    if DoesEntityExist(CarTarget) and (exports.dfs_PoliceJob:IsCop() or exports.db_perms:HasPermission("impound", 998)) then
        TriggerEvent("mythic_progbar:client:progress", {
            name = "GetVinNumber",
            duration = 50000,
            label = "Checking VIN Number...",
            canCancel = true,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            },
        }, function(status)
                if status then
                    return
                end
                TriggerEvent("mythic_progbar:client:progress", {
                    name = "CallDOT",
                    duration = 90000,
                    label = "Calling the DoT to get the vehicle...",
                    canCancel = true,
                    controlDisables = {
                        disableMovement = true,
                        disableCarMovement = true,
                        disableMouse = false,
                        disableCombat = true,
                    },
                }, function(status)
                        if status then
                            return
                        end
                        TriggerEvent('persistent-vehicles/forget-vehicle', CarTarget)
                        TaskLeaveVehicle(PlayerPedId(), CarTarget, 0)
                        UpdateVehicle(CarTarget, "IMPOUND", nil, nil, nil, GetVehicleImpoundId(CarTarget), nil, nil)
                        if not exports.dfs:DeleteVehicle(CarTarget) then 
                            TriggerEvent("alerts:add", {255, 255, 255}, {40, 183, 40}, "DoT", "I can't get there right now!") 
                            UpdateVehicle(CarTarget, "IMPOUND", nil, nil, nil, 0, nil, nil)
                        end
                    end)
            end)
    end
end)

function GetVehicleImpoundId(vehicle)
    local model = GetEntityModel(vehicle)
    if IsThisModelACar(model) then
        if GetEntityCoords(vehicle).y > 818.83 then
            return -2
        end
        return -1
    elseif IsThisModelAHeli(model) then
        return -3
    elseif IsThisModelAPlane(model) then
        return -4
    elseif IsThisModelABoat(model) then
        return -5
    end
    return -1
end

function UpdateVehicle(vehicle, methodName, Plate, Position, newCarName, storeAtGarageId, newPlate, newOwner)
    local _Plate = Plate or GetVehicleNumberPlateText(vehicle)
    if not _Plate or #_Plate == 0 then
        print("^1ERROR: dfs_garages>client.lua>UpdateVehicle"..methodName.."; Could not update vheicle; valid plate not specified!^7")
        return
    end
    exports.dfs:TriggerServerCallback("dfsg:UpdateVehicle", function(Success)
        if not Success then
            print("^1ERROR: dfs_garages>client.lua>UpdateVehicle>"..methodName.."; Unknown Failure resulting in a partial crash!^7")
        end
    end, _Plate, Position or {x=0, y=0, z=0}, vehicle and GenerateCarDamagesReport(vehicle) or "", newCarName or "", storeAtGarageId or "", newPlate or _Plate or GetVehicleNumberPlateText(vehicle), newOwner or "", vehicle and ESX.Game.GetVehicleProperties(vehicle) or "")
end

function GenerateCarDamagesReport(car)
    return {
        EngineHealth = GetVehicleEngineHealth(CurrentVehicle),
        BodyHealth = GetVehicleBodyHealth(CurrentVehicle),
        FuelTankHealth = GetVehiclePetrolTankHealth(CurrentVehicle),
        BrokenDoors = {
            DoesVehicleHaveDoor(Vehicle, 0) and IsVehicleDoorDamaged(Vehicle, 0),
            DoesVehicleHaveDoor(Vehicle, 1) and IsVehicleDoorDamaged(Vehicle, 1),
            DoesVehicleHaveDoor(Vehicle, 2) and IsVehicleDoorDamaged(Vehicle, 2),
            DoesVehicleHaveDoor(Vehicle, 3) and IsVehicleDoorDamaged(Vehicle, 3),
            DoesVehicleHaveDoor(Vehicle, 4) and IsVehicleDoorDamaged(Vehicle, 4),
            DoesVehicleHaveDoor(Vehicle, 5) and IsVehicleDoorDamaged(Vehicle, 5)
        },
        BrokenWindows = {
            (not IsVehicleWindowIntact(Vehicle,  0) and DoesVehicleHaveDoor(Vehicle, 1) and not IsVehicleDoorDamaged(Vehicle, 0)),
            (not IsVehicleWindowIntact(Vehicle,  1) and DoesVehicleHaveDoor(Vehicle, 0) and not IsVehicleDoorDamaged(Vehicle, 1) and not IsBike(Vehicle)),
            not (IsVehicleWindowIntact(Vehicle,  2) or AreAllVehicleWindowsIntact(Vehicle)),
            not (IsVehicleWindowIntact(Vehicle,  3) or AreAllVehicleWindowsIntact(Vehicle)),
            not (IsVehicleWindowIntact(Vehicle,  4) or AreAllVehicleWindowsIntact(Vehicle)),
            not (IsVehicleWindowIntact(Vehicle,  5) or AreAllVehicleWindowsIntact(Vehicle)),
            not (IsVehicleWindowIntact(Vehicle,  6) or AreAllVehicleWindowsIntact(Vehicle)),
            not (IsVehicleWindowIntact(Vehicle,  7) or AreAllVehicleWindowsIntact(Vehicle)),
            not (IsVehicleWindowIntact(Vehicle,  8) or AreAllVehicleWindowsIntact(Vehicle))
        },
        BrokenTires = {
            IsVehicleTyreBurst(Vehicle, 0, false) or IsVehicleTyreBurst(Vehicle, 0, true),
            IsVehicleTyreBurst(Vehicle, 1, false) or IsVehicleTyreBurst(Vehicle, 1, true),
            IsVehicleTyreBurst(Vehicle, 2, false) or IsVehicleTyreBurst(Vehicle, 2, true),
            IsVehicleTyreBurst(Vehicle, 3, false) or IsVehicleTyreBurst(Vehicle, 3, true),
            IsVehicleTyreBurst(Vehicle, 4, false) or IsVehicleTyreBurst(Vehicle, 4, true),
            IsVehicleTyreBurst(Vehicle, 5, false) or IsVehicleTyreBurst(Vehicle, 5, true),
        }
    }
end