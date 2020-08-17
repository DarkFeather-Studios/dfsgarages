local ESX
local UnattendedVehicles

AddEventHandler("onServerResourceStart", function(resourceName)
    if resourceName==GetCurrentResourceName() then
        while not ESX do
            TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)
            Wait(0)
        end
        
        --MySQL.Sync.execute("UPDATE `owned_vehicles` SET `garage_id` = 1")

        exports.dfs:RegisterServerCallback("dfsg:SelectOwnedVehicle", function(playerId, Plate)
            return MySQL.Sync.fetchAll("SELECT * FROM `owned_vehicles` WHERE `plate` = @plate", {["@plate"] = Plate})[1]
        end)

        exports.dfs:RegisterServerCallback("dfsg:PayImpoundFee", function(playerId, Cost)
            local xPlayer = ESX.GetPlayerFromId(playerId)
            if xPlayer.getMoney() >= Cost then
                xPlayer.removeMoney(Cost)
                return true
            end
            return false
        end)

        exports.dfs:RegisterServerCallback("dfsg:GetVehicleImpoundFees", function(playerId)
            local myIdentity = exports.dfs:GetTheirIdentity(playerId)
            local myName = myIdentity.FirstName .. " " .. myIdentity.LastName
            local AllCarResult = MySQL.Sync.fetchAll("SELECT * FROM `owned_vehicles` WHERE `owner` = @steam", {["@steam"] = exports.dfs:GetTheirIdentifiers(playerId).SteamID})
            local sellPrice
            local ImpoundPrices = {}
            for k, vehicleData in pairs(AllCarResult) do
                sellPrice = MySQL.Sync.fetchScalar("SELECT `sellprice` FROM `vehicle_sold` where `plate` = @plate", {["@plate"] = vehicleData.plate})
                ImpoundPrices[vehicleData.plate] = math.floor(sellPrice > 20 and sellPrice or 1500)
                --print("Set "..tostring(vehicleData.plate).."'s impound fee to $"..ImpoundPrices[vehicleData.plate])
            end
            return ImpoundPrices
        end)

        exports.dfs:RegisterServerCallback("dfsg:GetMyVehiclesAtGarage", function(playerId, garageId)
            local result = MySQL.Sync.fetchAll("SELECT * FROM `owned_vehicles` WHERE `owner` = @steam AND `garage_id` = @garageid",
                {["@steam"] = exports.dfs:GetTheirIdentifiers(playerId).SteamID, ["@garageid"] = garageId})
            for k, CarData in pairs(result) do
                result[k].damages  = json.decode(CarData.damages or json.encode({}))
                result[k].position = json.decode(CarData.position or json.encode({x=0, y=0, z=0}))
                result[k].vehicle  = json.decode(CarData.vehicle)
            end
            return result
        end)


        exports.dfs:RegisterServerCallback("dfsg:UpdateVehicle", function(playerId, PlateNumber, Position, Damages, newCarName, storeAtGarageId, newPlate, newOwner, newProps)
            local vehicleDB = MySQL.Sync.fetchAll("SELECT * FROM `owned_vehicles` WHERE `plate` = @plate", {["@plate"] = PlateNumber})[1]
            if not vehicleDB then
                return false
            end
            local vehicleProps = json.decode(vehicleDB.vehicle)
            if newPlate and newPlate ~= PlateNumber then
                vehicleProps.plate = newPlate
            end
            MySQL.Sync.execute("UPDATE `owned_vehicles` SET `owner` = @newowner, `plate` = @newPlate, `vehicle` = @newProps, `damages` = @damages, `vehiclename` = @newname, `garage_id` = @GarageToStoreAt, `position` = @pos WHERE `plate` = @platenumber", 
                {
                    ["@newowner"] = newOwner and #newOwner > 0 and newOwner or exports.dfs:GetTheirIdentifiers(playerId).SteamID, 
                    ["@newPlate"] = newPlate and #newPlate > 0 and newPlate or PlateNumber, 
                    ["@newProps"] = json.encode(#newProps > 0 and newProps or vehicleProps), 
                    ["@damages"] = json.encode(Damages), 
                    ["@newname"] = newCarName and #newCarName > 0 and newCarName or vehicleDB.vehiclename, 
                    ["@GarageToStoreAt"] = storeAtGarageId, 
                    ["@pos"] = type(Position) == "table" and json.encode(Position) or "(NULL)",
                    ["@platenumber"] = PlateNumber
                }
            )
            if storeAtGarageId ~= 0 then
                TriggerClientEvent("dfsg:RemoveVehicleFromBabysat", -1, PlateNumber)
            end
            return true
        end)

        --[[
        exports.dfs:RegisterServerCallback("dfsg:FindMyVehicle", function(playerId, Plate)
            for k, Vehicle in pairs(GetAllVehicles()) do
                if GetVehicleNumberPlateText(Vehicle) == Plate then
                    return NetworkGetNetworkIdFromEntity(Vehicle), MySQL.Sync.fetchScalar("SELECT `sellprice` FROM `vehicle_sold` WHERE `plate` = @plate", {["@plate"] = Plate})
                end
            end
        end)
]]
        Citizen.CreateThread(function()
            while true do
                Wait(60000)
                TriggerEvent('persistent-vehicles/save-vehicles-to-file')
            end
        end)
    end
end)

RegisterNetEvent("dfsg:SetVehicleRecovered")
AddEventHandler("dfsg:SetVehicleRecovered", function(Plate)
    TriggerEvent('persistent-vehicles/server/forget-vehicle', Plate)
    TriggerClientEvent("dfsg:DeleteVehicle", -1, Plate)
end)

function table.Contains(set, item)
    for key, value in pairs(set) do
        if value == item then return true end
    end
    return false
end
--[[
RegisterNetEvent('dfsga:CheckInitMessage')
AddEventHandler('dfsga:CheckInitMessage', function()
    local src = source
    local messages = MySQL.Sync.fetchAll("SELECT phone_messages.* FROM phone_messages LEFT JOIN users ON users.identifier = @identifier WHERE phone_messages.receiver = users.phone_number", 
                    {['@identifier'] = exports.dfs:GetTheirIdentifiers(src).SteamID})
    for k, Message in pairs(messages) do
        if Message.transmitter == "George&Andy Valet" then
            return
        end
    end
    TriggerEvent('gcPhone:_internalAddMessage', "George&Andy Valet", exports.dfs:GetTheirIdentity(src).PhoneNumber, "Hello, this is Jesse, from G&A Valet bringing you the new way to request one of your vehicles from anywhere.", false, function(message) TriggerClientEvent("gcPhone:receiveMessage", src, message) end)
    TriggerEvent('gcPhone:_internalAddMessage', "George&Andy Valet", exports.dfs:GetTheirIdentity(src).PhoneNumber, "You can text me all, or part of the name or license plate, and I will shoot you back a text to make sure it's all good.", false, function(message) TriggerClientEvent("gcPhone:receiveMessage", src, message) end)
    TriggerEvent('gcPhone:_internalAddMessage', "George&Andy Valet", exports.dfs:GetTheirIdentity(src).PhoneNumber, "Remember, the more information you give me, the more likely I'll know which car to bring you!", false, function(message) TriggerClientEvent("gcPhone:receiveMessage", src, message) end)
    --BUG: GCPhone doesn't auto-recognize the server-generated messages
end)

local SelectedVehicleInfos = {}
local Cost = 0

RegisterNetEvent('gcPhone:sendMessage') --INtercepts messages sent
AddEventHandler('gcPhone:sendMessage', function(phoneNumber, message)
    local src = source
    if phoneNumber == "George&Andy Valet" then
        if SelectedVehicleInfos[src] then
            message = message:lower()
            local AcceptedNos = {"n", "o", "no", "on"}
            for k, String in pairs(AcceptedNos) do
                if string.find(message, String) then
                    TriggerEvent('gcPhone:_internalAddMessage', "George&Andy Valet", exports.dfs:GetTheirIdentity(src).PhoneNumber, "Sorry about that! Care to try again?", false, function(message) TriggerClientEvent("gcPhone:receiveMessage", src, message) end)
                    SelectedVehicleInfos[src] = nil
                    return
                end
            end

            local AcceptedYess = {
                "y",
                "e",
                "s",
                "ye",
                "es",
                "ys",
                "yse",
            }
            for k, String in pairs(AcceptedYess) do
                if string.find(message, String) then
                    TriggerEvent('gcPhone:_internalAddMessage', "George&Andy Valet", exports.dfs:GetTheirIdentity(src).PhoneNumber, "A'ight! She's on the way!", false, function(message) TriggerClientEvent("gcPhone:receiveMessage", src, message) end)
                    --TODO: Charge bank for $Cost
                    TriggerClientEvent("dfsga:StartVehicleTransfer", src, SelectedVehicleInfos[src].garage_id, SelectedVehicleInfos[src])
                    return
                end
            end
        else
            SelectedVehicleInfos[src] = MySQL.Sync.fetchAll("SELECT * FROM `owned_vehicles` WHERE `owner` = @steam AND (`plate` LIKE UPPER(@partial) OR UPPER(`vehiclename`) LIKE UPPER(@partial)) LIMIT 1", 
            {["@steam"] = exports.dfs:GetTheirIdentifiers(src).SteamID, ["@partial"] = "%"..message.."%"})[1]
            print(">>>"..json.encode(SelectedVehicleInfos))
            print(">>>"..json.encode(SelectedVehicleInfos[src]))
            local doReturn = false
            if not SelectedVehicleInfos[src] or not SelectedVehicleInfos[src].garage_id then
                print(">>>No Match Found...?<<<")
                SelectedVehicleInfos[src] = nil;
                TriggerEvent('gcPhone:_internalAddMessage', "George&Andy Valet", exports.dfs:GetTheirIdentity(src).PhoneNumber, "Can't bring you a car we don't have!", false, function(message) TriggerClientEvent("gcPhone:receiveMessage", src, message) end)
                return
            end
            exports.dfs:TriggerClientCallback("dfsga:CheckDistance", src, function(Distance)
                if Distance == -1 then
                    print(">>>No Match Found...> But in bold this time!<<<")
                    TriggerEvent('gcPhone:_internalAddMessage', "George&Andy Valet", exports.dfs:GetTheirIdentity(src).PhoneNumber, "Can't bring you a car we don't have!", false, function(message) TriggerClientEvent("gcPhone:receiveMessage", src, message) end)
                    doReturn = true
                    return
                end 
                Cost = math.floor(500 + (Distance * 0.66))
            end, SelectedVehicleInfos[src].garage_id)
            TriggerEvent('gcPhone:_internalAddMessage', "George&Andy Valet", exports.dfs:GetTheirIdentity(src).PhoneNumber, "Alright, if you're asking for your "..
            (SelectedVehicleInfos[src].plate and SelectedVehicleInfos[src].plate or "")..
            (SelectedVehicleInfos[src].vehiclename and string.format(" %s %s ", "named", SelectedVehicleInfos[src].vehiclename) or "")..
            " to be brought to you for $"..Cost..", text back YES, otherwise, text back NO", false, function(message) TriggerClientEvent("gcPhone:receiveMessage", src, message) end)
        end
    end
end)
]]