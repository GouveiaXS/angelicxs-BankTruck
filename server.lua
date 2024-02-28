if Config.UseESX then
    ESX = exports["es_extended"]:getSharedObject()
    TriggerEvent('qs-core:getSharedObject', function(obj) QS = obj end)

    ESX.RegisterServerCallback('angelicxs-BankTruck:PoliceAvailable:ESX',function(source,cb)
        local xPlayers = ESX.GetPlayers()
        local cops = 0

        for i=1, #xPlayers, 1 do
            local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
            for i = 1, #Config.LEOJobName do
                if xPlayer.job.name == Config.LEOJobName[i] then
                    cops = cops + 1
                end
            end
        end
        if cops >= Config.RequiredNumberLEO then
            cb(true)
        else
            cb(false)
        end	
    end)
    ESX.RegisterServerCallback('angelicxs-BankTruck:itemTaken:ESX',function(source,cb)
        local xPlayer = ESX.GetPlayerFromId(source)
        local info = xPlayer.getInventoryItem(Config.StartItemName)
        if info.count >= 1 then
            xPlayer.removeInventoryItem(Config.StartItemName, 1)
            cb(true)
        else
            cb(false)
        end
    end)


elseif Config.UseQBCore then
    QBCore = exports['qb-core']:GetCoreObject()

    QBCore.Functions.CreateCallback('angelicxs-BankTruck:PoliceAvailable:QBCore', function(source, cb)
        local cops = 0
        local players = QBCore.Functions.GetQBPlayers()
        for k, v in pairs(players) do
            for i = 1, #Config.LEOJobName do
                if v.PlayerData.job.name == Config.LEOJobName[i] then
                    cops = cops + 1
                end
            end
        end
        if cops >= Config.RequiredNumberLEO then
            cb(true)
        else
            cb(false)
        end	
    end)
    QBCore.Functions.CreateCallback('angelicxs-BankTruck:itemTaken:QBCore', function(source, cb)
        local Player = QBCore.Functions.GetPlayer(source)
        if Player.Functions.RemoveItem(Config.StartItemName, 1) then
            cb(true)
        else
            cb(false)
        end
    end)

end


RegisterNetEvent('angelicxs-BankTruck:Server:HeistReward', function()
	local src = source
    local type = nil
	local Player = nil
    local Number = math.random(Config.MarkedBillMinNumberAmount, Config.MarkedBillMaxNumberAmount)
    local info = {worth = math.random(Config.MarkedBillMin, Config.MarkedBillMax)}
    local type = Config.MarkedBillName
    if Config.UseMoneyNotItem then
        type = Config.MoneyType
        Number = math.floor(math.random(Config.MarkedBillMinNumberAmount, Config.MarkedBillMaxNumberAmount)*math.random(Config.MarkedBillMin, Config.MarkedBillMax))
    end
    if math.random(1,100) <= Config.GoldBarChance then
        type = Config.GoldBarName
        Number = math.random(Config.GoldBarMin, Config.GoldBarMax)
    end
    if Config.UseESX then
        Player = ESX.GetPlayerFromId(src)
        if type == Config.MoneyType then
            Player.addAccountMoney(Config.MoneyType,Number)
        else
            Player.addInventoryItem(type, Number)
        end
    elseif Config.UseQBCore then
        Player = QBCore.Functions.GetPlayer(src)
        if type == Config.MoneyType then
            Player.Functions.AddMoney(Config.MoneyType, Number)
            TriggerEvent('qb-log:server:CreateLog', 'bankrobbery', 'Bank Truck Heist', 'green', Config.MoneyType..' received worth $'..Number..'\n**Person**:\n'..GetPlayerName(src))
        else
            Player.Functions.AddItem(type, Number, false, info)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[type], 'add')
            if type == Config.GoldBarName then 
                TriggerEvent('qb-log:server:CreateLog', 'bankrobbery', 'Bank Truck Heist', 'green', 'Goldbars Received:\n'..Number..'\n**Person**:\n'..GetPlayerName(src))
            elseif type == Config.MarkedBillName then 
                TriggerEvent('qb-log:server:CreateLog', 'bankrobbery', 'Bank Truck Heist', 'green', 'Marked Bills Received:\n'..Number..' worth $'..info.worth..'\n**Person**:\n'..GetPlayerName(src))
            end
        end
    end
    if math.random(1, 100) <= Config.RareLootChance then
        if Config.UseESX then
            Player.addInventoryItem(Config.RareLootItem, Config.RareLootItemAmount)
        elseif Config.UseQBCore then
            Player.Functions.AddItem(Config.RareLootItem, Config.RareLootItemAmount)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.RareLootItem], 'add')
            TriggerEvent('qb-log:server:CreateLog', 'bankrobbery', 'Yacht Heist', 'green', 'Rare Loot Received: '..Config.RareLootItem..'\n**Person**:\n'..GetPlayerName(src))
        end
        TriggerClientEvent('angelicxs-BankTruck:Notify', src, Config.Lang['gained_rare'], Config.LangType['success'])
    end
end)
--- Guard Spawner
RegisterNetEvent('angelicxs-BankTruck:Server:Guards', function()
    local List = {}
    local time = os.time()
    local route = GuardSelector(Config.BankRoutes)
    List.model = GuardSelector(Config.GuardType)
    List.weapon = GuardSelector(Config.GuardWeapon)
    List.truck = GuardSelector(Config.BankTruck)
    TriggerClientEvent("angelicxs-BankTruck:Client:HesitSyncStarterStart", source, nil, route)
    TriggerClientEvent("angelicxs-BankTruck:Client:HesitSyncCopsStart", -1, nil, route)
    TriggerClientEvent("angelicxs-BankTruck:Client:BeginRoute", source, nil, time, route, List)
end)

-- Syncs
RegisterNetEvent('angelicxs-BankTruck:Server:TruckSync', function(finish, time, start, id)
    TriggerClientEvent("angelicxs-BankTruck:Client:TruckSync", -1, time, start, finish, id)
end)

RegisterServerEvent('angelicxs-BankTruck:Server:ThirdEyeSync', function(name, time)
    TriggerClientEvent('angelicxs-BankTruck:Client:ThirdEyeSync', -1, name, time)
end)

RegisterServerEvent('angelicxs-BankTruck:Server:ArmExplosion', function(name, time)
    TriggerClientEvent('angelicxs-BankTruck:Client:ArmExplosion', -1, name, time)
end)

function GuardSelector(Options)
    local List = Options
    local Number = 0
    math.random()
    local Selection = math.random(1, #List)
    for i = 1, #List do
        Number = Number + 1
        if Number == Selection then
            return List[i]
        end
    end
end

-- Exploit Trigger
RegisterServerEvent('angelicxs-BankTruck:ThatIsAThing', function(server)
    if server ~= nil then
        DropPlayer(server, "Go hack somewhere else.")
    end
    Print("\n\n\n\nWARNING WARNING WARNING\nPlayer ID "..tostring(server).." was kicked for attempting to exploit angelicxs-BankTruck. It is recommended you ban them.\nnWARNING WARNING WARNING\n\n\n\n")
end)

AddEventHandler('onResourceStop', function(resource)
    if GetCurrentResourceName() == resource then
        
    end
end)
