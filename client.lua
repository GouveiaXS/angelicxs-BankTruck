ESX = nil
QBcore = nil
PlayerJob = nil
PlayerGrade = nil

local onjob = false
local isLawEnforcement = false
local StartNPC = nil
local PedSpawned = false
local oxTargets = {}
local Blips = {}
local EPlant = {}
local ELoot = {}
local GaurdList = {}
local VehicleList = {}


RegisterNetEvent('angelicxs-BankTruck:Notify', function(message, type)
	if Config.UseCustomNotify then
        TriggerEvent('angelicxs-BankTruck:CustomNotify',message, type)
	elseif Config.UseESX then
		ESX.ShowNotification(message)
	elseif Config.UseQBCore then
		QBCore.Functions.Notify(message, type)
	end
end)

CreateThread(function()
    if Config.UseESX then
        ESX = exports["es_extended"]:getSharedObject()
	while not ESX.IsPlayerLoaded() do
            Wait(100)
        end
    
        local playerData = ESX.GetPlayerData()
        CreateThread(function()
            while true do
                if playerData ~= nil then
                    PlayerJob = playerData.job.name
                    PlayerGrade = playerData.job.grade
                    isLawEnforcement = LawEnforcement()
                    break
                end
                Wait(100)
            end
        end)
        RegisterNetEvent('esx:setJob', function(job)
            PlayerJob = job.name
            PlayerGrade = job.grade
            isLawEnforcement = LawEnforcement()
        end)

    elseif Config.UseQBCore then

        QBCore = exports['qb-core']:GetCoreObject()
        
        CreateThread(function ()
			while true do
                local playerData = QBCore.Functions.GetPlayerData()
				if playerData.citizenid ~= nil then
					PlayerJob = playerData.job.name
					PlayerGrade = playerData.job.grade.level
                    isLawEnforcement = LawEnforcement()
					break
				end
				Wait(100)
			end
		end)

        RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
            PlayerJob = job.name
            PlayerGrade = job.grade.level
            isLawEnforcement = LawEnforcement()
        end)
    end

    if Config.UseThirdEye then
        local eye_options = {{
            event = "angelicxs-BankTruck:RobberyCheck",
            icon = 'fas fa-phone',
            canInteract = function()
                return hasItem()
            end,
            label = Config.Lang['call_card'],
        }}
        if Config.ThirdEyeName == 'ox_target' then
            exports.ox_target:addModel(Config.Payphonemodels, eye_options)
        else
            exports[Config.ThirdEyeName]:AddTargetModel(Config.Payphonemodels,{
                options = eye_options,
                distance = 2.5,
            })
        end
    end
    
    if Config.StartBlip then
		local blip = AddBlipForCoord(Config.StartPed.x,Config.StartPed.y,Config.StartPed.z)
		SetBlipSprite(blip, Config.StartBlipIcon)
		SetBlipColour(blip, Config.StartBlipColour)
		SetBlipScale(blip, 0.7)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName('STRING')
		AddTextComponentString(Config.StartBlipText)
		EndTextCommandSetBlipName(blip)
	end
end)

CreateThread(function()
    if Config.Use3DText then
        for i = 1, #Config.Payphonemodels do
            local Phone = Config.Payphonemodels[i]
            while true do
                local Sleep = 2500
                local Player = PlayerPedId()
                local Pos = GetEntityCoords(Player)
                local obj = GetClosestObjectOfType(Pos.x, Pos.y, Pos.z, 75, Phone, false, true, true)
                if DoesEntityExist(obj) then
                    sleep = 1000
                    local Dist = #(Pos - GetEntityCoords(obj))
                    if Dist <= 50 then
                        Sleep = 500
                        if Dist <= 3 then
                            Sleep = 0
                            DrawText3Ds(Config.StartPed.x, Config.StartPed.y, Config.StartPed.z, Config.Lang['request'])
                            if IsControlJustReleased(0, 38) then
                                TriggerEvent('angelicxs-BankTruck:RobberyCheck')
                            end
                        end
                    end
                end
                Wait(Sleep)
            end
        end
    end
end)

-- Starting NPC Spawn
CreateThread(function()
    if Config.UsePed then
        CreateThread(function()
            while Config.Use3DText do
                local Sleep = 2000
                local Player = PlayerPedId()
                local Pos = GetEntityCoords(Player)
                local Dist = #(Pos - vector3(Config.StartPed.x, Config.StartPed.y, Config.StartPed.z))
                if Dist <= 50 then
                    Sleep = 500
                    if Dist <= 3 then
                        Sleep = 0
                        DrawText3Ds(Config.StartPed.x, Config.StartPed.y, Config.StartPed.z, Config.Lang['request'])
                        if IsControlJustReleased(0, 38) then
                            TriggerEvent('angelicxs-BankTruck:RobberyCheck')
                        end
                    end
                end
                Wait(Sleep)
            end
        end)
        while true do
            local Player = PlayerPedId()
            local Pos = GetEntityCoords(Player)
            local Dist = #(Pos - vector3(Config.StartPed.x, Config.StartPed.y, Config.StartPed.z))
            if Dist <= 50 and not PedSpawned then
                TriggerEvent('angelicxs-BankTruck:SpawnNPC',Config.StartPed,Config.StartModel)
                PedSpawned = true
            elseif DoesEntityExist(StartNPC) and PedSpawned then
                local Dist2 = #(Pos - GetEntityCoords(StartNPC))
                if Dist2 > 50 then
                    DeleteEntity(StartNPC)
                    PedSpawned = false
                    if Config.UseThirdEye then
                        if Config.ThirdEyeName == 'ox_target' then
                            exports.ox_target:removeZone('BankTruckNPC')
                        else
                            exports[Config.ThirdEyeName]:RemoveZone('BankTruckNPC')
                        end
                    end
                end
            end
            Wait(2000)
        end
    end
end)

RegisterNetEvent('angelicxs-BankTruck:SpawnNPC',function(coords,model)
    local hash = HashGrabber(model)
    StartNPC = CreatePed(3, hash, coords.x, coords.y, (coords.z-1), coords.w, false, false)
    FreezeEntityPosition(StartNPC, true)
    SetEntityInvincible(StartNPC, true)
    SetBlockingOfNonTemporaryEvents(StartNPC, true)
    TaskStartScenarioInPlace(StartNPC,'WORLD_HUMAN_STAND_IMPATIENT', 0, false)
    SetModelAsNoLongerNeeded(model)
    if Config.UseThirdEye then
        if Config.ThirdEyeName == 'ox_target' then
            local options = {
                {
                    name = 'BankTruckNPC',
                    event = 'angelicxs-BankTruck:RobberyCheck',
                    icon = 'fas fa-truck',
                    label = Config.Lang['call_card'],
                },
            }
            exports.ox_target:addLocalEntity(StartNPC, options)
        else
            exports[Config.ThirdEyeName]:AddEntityZone('BankTruckNPC', StartNPC, {
                name="BankTruckNPC",
                debugPoly=false,
                useZ = true
                }, {
                options = {
                    {
                    event = 'angelicxs-BankTruck:RobberyCheck',
                    icon = 'fas fa-truck',
                    label = Config.Lang['call_card'],
                    },
                    
                },
                distance = 2
            })        
        end
    end
end)

RegisterNetEvent('angelicxs-BankTruck:RobberyCheck', function()
    if not Config.AllowLeoRob and isLawEnforcement then
        TriggerEvent('angelicxs-BankTruck:Notify', Config.Lang['nocop'], Config.LangType['info'])
        return
    end
    if onjob then
        TriggerEvent('angelicxs-BankTruck:Notify', Config.Lang['onjob'], Config.LangType['info'])
        return
    end
    local StartRobbery = true
    local hasItem = true
    TriggerEvent('angelicxs-BankTruck:Notify', Config.Lang['checking'], Config.LangType['info'])
    if Config.RequireMinimumLEO then
        StartRobbery = false
        if Config.UseESX then
            ESX.TriggerServerCallback('angelicxs-BankTruck:PoliceAvailable:ESX', function(cb)
                StartRobbery = cb
            end)                                    
        elseif Config.UseQBCore then
            QBCore.Functions.TriggerCallback('angelicxs-BankTruck:PoliceAvailable:QBCore', function(cb)
                StartRobbery = cb
            end)
        end
        Wait(1000)
    end
    if not StartRobbery then
        TriggerEvent('angelicxs-BankTruck:Notify', Config.Lang['mincops'], Config.LangType['error'])
        return
    end
    if Config.RequireStartItem then
        hasItem = false
        if Config.UseESX then
            ESX.TriggerServerCallback('angelicxs-BankTruck:itemTaken:ESX', function(cb)
                hasItem = cb
            end)                                    
        elseif Config.UseQBCore then
            QBCore.Functions.TriggerCallback('angelicxs-BankTruck:itemTaken:QBCore', function(cb)
                hasItem = cb
            end)
        end
        Wait(1000)
    end
    if hasItem then
        onjob = true
        TriggerServerEvent('angelicxs-BankTruck:Server:Guards')
        TriggerEvent('angelicxs-BankTruck:Notify', Config.Lang['startHeist'], Config.LangType['info'])
    else
        TriggerEvent('angelicxs-BankTruck:Notify', Config.Lang['noitem'], Config.LangType['error'])
    end
end)

RegisterNetEvent('angelicxs-BankTruck:Client:HesitSyncStarterStart', function(finish, start)
    BlipAdder(start, finish)
end)

RegisterNetEvent('angelicxs-BankTruck:Client:HesitSyncCopsStart', function(finish, start)
    if isLawEnforcement then
        CreateThread(function()
            BlipAdder(start, finish)
        end)
        TriggerEvent('angelicxs-BankTruck:Notify', Config.Lang['cop_notify'], Config.LangType['info'])
    end
end)

RegisterNetEvent('angelicxs-BankTruck:Client:BeginRoute', function(finish, time, start, list)
    GaurdList[time] = {}
    local vehicle, id = TruckSpawner(time, start, finsh, list.truck)
    if not vehicle or not id then return end
    GuardSpawner(time, list.model, list.weapon, vehicle, start)
    TriggerEvent('angelicxs-BankTruck:PoliceAlert', GetEntityCoords(vehicle))
    TriggerServerEvent('angelicxs-BankTruck:Server:TruckSync', finish, time, start, id)
    onjob = false
    if not DoesEntityExist(GaurdList[time][1]) then
        GuardSpawner(time, list.model, list.weapon, vehicle, start)
    end
end)


RegisterNetEvent('angelicxs-BankTruck:Client:TruckSync', function(time, inital, final, netid)
    local leoprotect = false
    if isLawEnforcement and not Config.AllowLeoRob then
        leoprotect = true
    end
    local obj = NetworkGetEntityFromNetworkId(netid)
    local FailSafe = 600
    while not DoesEntityExist(obj) do
        Wait(10000)
        if DoesEntityExist(obj) then
            obj = NetworkGetEntityFromNetworkId(netid)
        end
        FailSafe = FailSafe - 1
        if FailSafe <= 0 then break end
    end
    if FailSafe <= 0 then return end
    if not leoprotect then
        if Config.UseThirdEye then
            if Config.ThirdEyeName == 'ox_target' then
                local options = {
                    {
                        onSelect = function()
                            TriggerServerEvent('angelicxs-BankTruck:Server:ArmExplosion', obj, time)
                            LootAnim(obj)
                        end,
                        icon = 'fas fa-truck',
                        label = Config.Lang['arm'],
                        canInteract = function(entity)
                            if GetVehicleBodyHealth(obj) <= 2 then return false end
                            return not EPlant[time] and IsVehicleStopped(obj) and not IsPedInAnyVehicle(PlayerPedId(), true)
                        end,
                    },
                    {
                        onSelect = function()
                            TriggerEvent('angelicxs-BankTruck:Loot', obj, netid, time)
                        end,
                        name = Config.Lang['loot'],
                        icon = 'fas fa-truck',
                        label = Config.Lang['loot'],
                        canInteract = function(entity)
                            if GetVehicleBodyHealth(obj) > 2 then return false end
                            return not ELoot[time] and not IsPedInAnyVehicle(PlayerPedId(), true)
                        end,
                    },
                }
                exports.ox_target:addLocalEntity(obj, options)
            else
                exports[Config.ThirdEyeName]:AddTargetEntity( obj, {
                    options = {
                        {
                            action = function()
                                TriggerServerEvent('angelicxs-BankTruck:Server:ArmExplosion', obj, time)
                                LootAnim(obj)
                            end,
                            icon = 'fas fa-truck',
                            label = Config.Lang['arm'],
                            canInteract = function(entity)
                                if GetVehicleBodyHealth(obj) <= 2 then return false end
                                return not EPlant[time] and IsVehicleStopped(obj) and not IsPedInAnyVehicle(PlayerPedId(), true)
                            end,
                        },
                        {
                            action = function()
                                TriggerEvent('angelicxs-BankTruck:Loot', obj, netid, time)
                            end,
                            icon = 'fas fa-truck',
                            label = Config.Lang['loot'],
                            canInteract = function(entity)
                                if GetVehicleBodyHealth(obj) > 2 then return false end
                                return not ELoot[time] and not IsPedInAnyVehicle(PlayerPedId(), true)
                            end,
                        },
                    },
                    distance = 2
                })        
            end
        end
    end
    local active = false
    while true do 
        local Pos = GetEntityCoords(PlayerPedId())
        local truckPos = GetEntityCoords(obj)
        if #(Pos-truckPos) <= 350 and DoesEntityExist(obj) then
            active = true
            TriggerEvent('angelicxs-BankTruck:Notify', Config.Lang['truck_ping'], Config.LangType['info'])
            break
        elseif not DoesEntityExist(obj) then
            break
        end
        Wait(1000)
    end
    CreateThread(function()
        while active do
            local truckPos = GetEntityCoords(obj)
            Blips.TrackerDevice = AddBlipForRadius(truckPos.x, truckPos.y, truckPos.z, 50.0)
            SetBlipHighDetail(Blips.TrackerDevice, true)
            SetBlipColour(Blips.TrackerDevice, 28)
            SetBlipAlpha(Blips.TrackerDevice, 160)
            SetBlipAsShortRange(Blips.TrackerDevice, true)
            Wait(1000)
            if GetVehicleBodyHealth(obj) <= 2 or not DoesEntityExist(obj) then
                RemoveBlip(Blips.TrackerDevice)
                break
            end
            RemoveBlip(Blips.TrackerDevice)
        end 
    end)
    while Config.Use3DText do
        if leoprotect then
            break
        end
        local Sleep = 2000
        local Player = PlayerPedId()
        local Pos = GetEntityCoords(Player)
        local truckPos = GetEntityCoords(obj)
        local Dist = #(Pos - truckPos)
        if Dist <= 50 then
            Sleep = 500
            if Dist <= 7 then
                Sleep = 0
                if GetVehicleBodyHealth(obj) <= 2 and not ELoot[time] and not IsPedInAnyVehicle(Player, true) then
                    DrawText3Ds(truckPos.x, truckPos.y, truckPos.z, Config.Lang['loot3d'])
                    if IsControlJustReleased(0, 38) then
                        TriggerEvent('angelicxs-BankTruck:Loot', obj, netid, time)
                    end
                elseif not EPlant[time] and IsVehicleStopped(obj) and not IsPedInAnyVehicle(Player, true) then
                    DrawText3Ds(truckPos.x, truckPos.y, truckPos.z, Config.Lang['arm3d'])
                    if IsControlJustReleased(0, 38) then
                        TriggerServerEvent('angelicxs-BankTruck:Server:ArmExplosion', obj, time)
                        LootAnim(obj)
                    end
                end
                
            end
        end
        if not DoesEntityExist(obj) then
            break
        end
        Wait(Sleep)
    end 
end)

RegisterNetEvent('angelicxs-BankTruck:Client:ArmExplosion', function(obj, number)
    EPlant[number] = true
    local timer = Config.ArmExplosionTimer * 100
    if not DoesEntityExist(obj) then return end
    local truckPos = GetEntityCoords(obj)
    local Player = PlayerPedId()
    local dist = #(GetEntityCoords(Player)-truckPos)
    if  dist <= 150 then
        CreateThread(function()
            while true do
                dist = #(GetEntityCoords(Player)-truckPos)
                if timer <= 0 then break end
                Wait(1250)
            end
        end)
        while true do
            if dist <= 15 then
                DrawText3Ds(truckPos.x, truckPos.y, truckPos.z, Config.Lang['explosion']..tostring(math.ceil(timer/100)))
            end
            timer = timer - 1
            if timer <= 0 then
                break
            end
            Wait(0)
        end
        SetVehicleBodyHealth(obj, 1)
        AddExplosion(truckPos.x, truckPos.y, truckPos.z, 9, 100.0, true, false, false, false)
    end
end)

RegisterNetEvent('angelicxs-BankTruck:Loot', function(obj, netid, time)
    if not DoesEntityExist(obj) then return end
    TriggerServerEvent('angelicxs-BankTruck:Server:ThirdEyeSync', netid, time)
    LootAnim(obj)
    TriggerServerEvent('angelicxs-BankTruck:Server:HeistReward')
end)

RegisterNetEvent('angelicxs-BankTruck:Client:ThirdEyeSync', function(netid, time)
    ELoot[time] = true
    local obj = NetworkGetEntityFromNetworkId(netid)
    while not DoesEntityExist(obj) do
        if DoesEntityExist(obj) then
            obj = NetworkGetEntityFromNetworkId(netid)
        end
        Wait(10000)
    end
    if Config.ThirdEyeName == 'ox_target' then
        exports.ox_target:removeLocalEntity(obj, Config.Lang['loot'])
    else
        exports['qb-target']:RemoveTargetEntity(obj, Config.Lang['loot'])
    end
end)

-- Functions

function LawEnforcement()
    for i = 1, #Config.LEOJobName do
        if PlayerJob == Config.LEOJobName[i] then
            return true
        end
    end
    return false
end

function LootAnim(obj)
    local Player = PlayerPedId()
    TaskTurnPedToFaceEntity(Player, obj, -1)
    FreezeEntityPosition(Player, true)
    RequestAnimDict("anim@amb@clubhouse@tutorial@bkr_tut_ig3@")
    while not HasAnimDictLoaded("anim@amb@clubhouse@tutorial@bkr_tut_ig3@") do
        Wait(10)
    end
    TaskPlayAnim(Player,"anim@amb@clubhouse@tutorial@bkr_tut_ig3@","machinic_loop_mechandplayer",1.0, -1.0, -1, 49, 0, 0, 0, 0)
    Wait(5500)	
    ClearPedTasks(Player)
    FreezeEntityPosition(Player, false)
    RemoveAnimDict("anim@amb@clubhouse@tutorial@bkr_tut_ig3@")
end

function HashGrabber(model)
    local hash = GetHashKey(model)
    if not HasModelLoaded(hash) then
        RequestModel(hash)
        Wait(10)
    end
    while not HasModelLoaded(hash) do
      Wait(10)
    end
    return hash
end

function DrawText3Ds(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.30, 0.30)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry('STRING')
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end

function hasItem()
	local hasItem = false
    if not Config.RequireStartItem then
        return true
    end
    if Config.UseESX then
        local PlayerData = ESX.GetPlayerData()
        for k, v in ipairs(PlayerData.inventory) do
            if v.name == Config.StartItemName and v.count > 0 then
                hasItem = true
                break
            end
        end
    elseif Config.UseQBCore then
        hasItem = QBCore.Functions.HasItem(Config.StartItemName)
    end
	return hasItem
end

function TruckSpawner(time, start, finsh, truck)
    local hash = HashGrabber(truck)
    local limit = 99999999999999999*60
    if Config.TimeLimit then
        limit = Config.TimeToFindLimit*60*2
    end
    while true do
        local dist = #(GetEntityCoords(PlayerPedId())-vector3(start.x, start.y, start.z))
        if dist <= 350 or limit <= 0 then
            break
        end
        limit = limit - 1
        Wait(500)
    end
    if limit <= 0 then TriggerEvent('angelicxs-BankTruck:Notify', src, Config.Lang['time_limit'], Config.LangType['error']) return false end
    ClearAreaOfVehicles(start.x, start.y, start.z, 10)
    VehicleList[time] = CreateVehicle(hash, start.x, start.y, start.z, start.w, true, false)
    while not DoesEntityExist(VehicleList[time]) do Wait(100) end
    NetworkRegisterEntityAsNetworked(VehicleList[time])
    local id = NetworkGetNetworkIdFromEntity(VehicleList[time])
	SetNetworkIdCanMigrate(id, true)
	SetNetworkIdExistsOnAllMachines(id, true)
    --SetVehicleHasBeenOwnedByPlayer(VehicleList[time], true)
    SetEntityAsMissionEntity(VehicleList[time], true, true)
    SetVehicleDoorsLockedForAllPlayers(VehicleList[time], true)
    SetVehicleFuelLevel(VehicleList[time], 99.0)
    SetVehicleOnGroundProperly(VehicleList[time])
    CreateThread(function()
        while true do
            if GetVehicleBodyHealth(VehicleList[time]) <= 2 then
                if DoesEntityExist(VehicleList[time]) then
                    Wait(300000)
                    DeleteEntity(VehicleList[time])
                    break
                else
                    break
                end
            end
            Wait(120000)
        end
    end)
    CreateThread(function()
        while DoesEntityExist(VehicleList[time]) do
            local pos = GetEntityCoords(VehicleList[time])
            local dist = #(pos-Config.AttemptedFinal)
            if dist < 10 then
                Wait(180000)
                DeleteEntity(VehicleList[time])
                break
            end
            Wait(1000)
        end
    end)
    return VehicleList[time], id
end

function GuardSpawner(time, model, weapon, vehicle, start)
    local finish = Config.AttemptedFinal
    local hash = HashGrabber(model)
    while true do
        local dist = #(GetEntityCoords(PlayerPedId())-vector3(start.x, start.y, start.z))
        if dist <= 200 then
            break
        end
        Wait(0)
    end
    for i = -1, 2 do
        GaurdList[time][i] = CreatePedInsideVehicle(vehicle, 4, hash, i, true, true)
        while not DoesEntityExist(GaurdList[time][i]) do Wait(50) end
        SetEntityAsMissionEntity(GaurdList[time][i], true, true)
        NetworkRegisterEntityAsNetworked(GaurdList[time][i])
        SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(GaurdList[time][i]), true)
        SetNetworkIdExistsOnAllMachines(NetworkGetNetworkIdFromEntity(GaurdList[time][i]), true)
        SetPedArmour(GaurdList[time][i], Config.GuardArmour)
        GiveWeaponToPed(GaurdList[time][i], weapon, 500)
        SetPedFleeAttributes(GaurdList[time][i], 0, false)
        SetPedCombatAttributes(GaurdList[time][i], 0, true)
        SetPedCombatAttributes(GaurdList[time][i], 1, true)
        SetPedCombatAttributes(GaurdList[time][i], 2, true)
        SetPedCombatAttributes(GaurdList[time][i], 3, true)
        SetPedCombatAttributes(GaurdList[time][i], 46, true)
        SetPedCombatAbility(GaurdList[time][i], 2)
        SetPedCombatMovement(GaurdList[time][i], 1)
        SetPedAsCop(GaurdList[time][i], true)
        SetPedAccuracy(GaurdList[time][i], 100)
        SetPedCombatRange(GaurdList[time][i], 2)
        SetEntityVisible(GaurdList[time][i], true)
        SetPedKeepTask(GaurdList[time][i], true)
        if i == -1 then
            SetDriverAbility(GaurdList[time][i], 100)
            TaskVehicleDriveWander(GaurdList[time][i], vehicle, 150.0, 447)
            CreateThread(function()
                while true do
                    local dist = #(GetEntityCoords(PlayerPedId())-GetEntityCoords(vehicle))
                    if dist <= 15 or (GetVehicleBodyHealth(vehicle) <= 950) then
                        TaskVehicleDriveToCoord(GaurdList[time][i], vehicle, finish.x, finish.y, finish.z, 150.0, 1, GetEntityModel(vehicle), 524288, 20, 1)
                        break
                    end
                    Wait(1000)
                end
            end)
        end
        CreateThread(function()
            while DoesEntityExist(vehicle) do
                local pos = GetEntityCoords(vehicle)
                local dist = #(pos-finish)
                if dist < 10 then
                    TaskLeaveVehicle(GaurdList[time][i],vehicle,0)
                    Wait(180000)
                    DeleteEntity(vehicle)
                    SetEntityAsNoLongerNeeded(GaurdList[time][i])
                    break
                end
                Wait(1000)
            end
        end)
        CreateThread(function()
            Wait(30000)
            while DoesEntityExist(vehicle) do
                if GetVehicleBodyHealth(vehicle) <= 750 or IsVehicleStopped(vehicle) then
                    ClearPedTasks(GaurdList[time][i])
                    TaskLeaveVehicle(GaurdList[time][i],vehicle,0)
                    while IsPedInVehicle(GaurdList[time][i], vehicle, true) do Wait(100) end
                    TaskCombatPed(GaurdList[time][i], PlayerPedId(), 0, 16)
                    break
                end
                Wait(1000)
            end
        end)
    end
    SetModelAsNoLongerNeeded(model)
end

function BlipAdder(start, finish)
    if Config.AllowStartLocationBlip then
        CreateThread(function()
            Blips.inital = AddBlipForCoord(start.x,start.y,start.z)
            SetBlipSprite(Blips.inital, Config.StartBlipIcon)
            SetBlipColour(Blips.inital, Config.StartBlipColour)
            SetBlipScale(Blips.inital, 1.5)
            SetBlipAsShortRange(Blips.inital, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(Config.Lang['blip_inital'])
            EndTextCommandSetBlipName(Blips.inital)
            Wait(60000)
            RemoveBlip(Blips.inital)
        end)
    end
end

AddEventHandler('onResourceStop', function(resource)
    if GetCurrentResourceName() == resource then
        local onjob = false
        if DoesBlipExist(Blips.TrackerDevice) then
            RemoveBlip(Blips.TrackerDevice)
        end
        if DoesBlipExist(Blips.inital) then
            RemoveBlip(Blips.inital)
        end
        if DoesEntityExist(StartNPC) then
            DeleteEntity(StartNPC)
        end 
        for k,v in pairs(GaurdList)do
            for a,d in pairs(v) do
                if DoesEntityExist(d) then
                    DeleteEntity(d)
                end
            end
        end
        for k,v in pairs(VehicleList)do
            if DoesEntityExist(v) then
                DeleteEntity(v)
            end
        end
    end
end)
