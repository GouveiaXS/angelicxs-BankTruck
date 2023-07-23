----------------------------------------------------------------------
-- Thanks for supporting AngelicXS Scripts!							--
-- Support can be found at: https://discord.gg/tQYmqm4xNb			--
-- More paid scripts at: https://angelicxs.tebex.io/ 				--
-- More FREE scripts at: https://github.com/GouveiaXS/ 				--
----------------------------------------------------------------------
-- Model info: https://docs.fivem.net/docs/game-references/ped-models/
-- Blip info: https://docs.fivem.net/docs/game-references/blips/


Config = {}


Config.UseESX = false						-- Use ESX Framework (GO TO FXMANIFEST AND UNCOMMENT '@es_extended/imports.lua' )
Config.UseQBCore = true					-- Use QBCore Framework (Ignored if Config.UseESX = true)

Config.UseCustomNotify = false				-- Use a custom notification script, must complete event below.

-- Only complete this event if Config.UseCustomNotify is true; mythic_notification provided as an example
RegisterNetEvent('angelicxs-BankTruck:CustomNotify')
AddEventHandler('angelicxs-BankTruck:CustomNotify', function(message, type)
    --exports.mythic_notify:SendAlert(type, message, 4000)
end)

-- Visual Preference
Config.Use3DText = true 					-- Use 3D text for NPC interactions; only turn to false if Config.UseThirdEye is turned on and IS working.
Config.UseThirdEye = true 					-- Enables using a third eye (third eye requires the following arguments debugPoly, useZ, options {event, icon, label}, distance)
Config.ThirdEyeName = 'qb-target' 			-- Name of third eye aplication
Config.ServerPrints = true                  -- If true provides some minor information on the heist periodically

--LEO Configuration
Config.RequireMinimumLEO = true 			-- When on will require a minimum number of LEOs to be available to start robbery
Config.RequiredNumberLEO = 0 				-- Minimum number of LEO needed for robbery to start when Config.RequireMinimumLEO = true
Config.AllowLeoRob = false                  -- If true lets LEOs start the event/rob the truck
Config.LEOJobName = {'police', 'bcso'} 		-- Job name of law enforcement officers
Config.Cooldown = 90						-- How long until the heist is able to be redone after activating (in minutes)
RegisterNetEvent('angelicxs-BankTruck:PoliceAlert')
AddEventHandler('angelicxs-BankTruck:PoliceAlert', function(coords)
    -- TriggerEvent("police:client:policeAlert", coords, "Bank Truck Robbery Alert")

    -- local data = exports['cd_dispatch']:GetPlayerInfo()
    -- TriggerServerEvent('cd_dispatch:AddNotification', {
    --     job_table = {'police', 'bcso'}, 
    --     coords = coords,
    --     title = '10-XXXX - Bank Truck Robbery',
    --     message = 'A bank truck gps pinger has gone haywire and is requesting assistance!', 
    --     flash = 0,
    --     unique_id = tostring(math.random(0000000,9999999)),
    --     blip = {
    --         sprite = 410, 
    --         scale = 1.2, 
    --         colour = 5,
    --         flashes = false, 
    --         text = '911 - Bank Truck Alert',
    --         time = (5*60*1000),
    --         sound = 1,
    --     }
    -- })
end)

-- Input Config
Config.RequireStartItem = false 			-- If true requires an item to start heist 
Config.StartItemName = 'calling_card' 		-- If Config.RequireStartItem = true, name of start item
Config.Payphonemodels = {
	1158960338,
    1511539537,
    1281992692,
    -429560270,
    -1559354806,
    -78626473,
    295857659,
    -2103798695,
    -870868698,
    -1126237515,
    506770882,
}
Config.ArmExplosionTimer = 30				-- Time in seconds it takes for explosion to arm and destory truck to loot it
Config.AllowStartLocationBlip = true        -- If true, marks on the map for 60 seconds the start point of the truck
Config.TimeLimit = true                     -- If true, puts a time limit to get to truck start position
Config.TimeToFindLimit = 30                 -- If Config.TimeLimit = true, amount of time in minutes to get to truck position before failing

-- Reward Config
Config.GoldBarChance = 25					-- Chance to receive gold bars instead of marked bills
Config.GoldBarName = 'goldbar'				-- Name of gold bar item
Config.GoldBarMin = 10						-- Minimum number of gold bars recevied
Config.GoldBarMax = 100						-- Maximum number of gold bars received
Config.MarkedBillName = 'markedbills'		-- Name of marked bill item
Config.MarkedBillMinNumberAmount = 1		-- Minimum number of marked bills received
Config.MarkedBillMaxNumberAmount = 5		-- Maximum number of marked bills received
Config.MarkedBillMin = 1000					-- Minimum value of marked bills
Config.MarkedBillMax = 10000				-- Maximum value of marked bills
Config.UseMoneyNotItem = true               -- If true, DOES NOT use money as an item.
Config.MoneyType = 'cash'                   -- If Config.UseMoneyNotItem = true, what acccount the money goes into.

Config.RareLootChance = 1					-- Chance to receive rare item in addition to normal reward
Config.RareLootItem = 'gold_monkey_idol'	-- Name of rare loot item
Config.RareLootItemAmount = 1				-- Amount of rare loot item received

-- Starting Ped Config
Config.UsePed = true										-- Use a ped to start the mission instead of using a payphone
Config.StartPed = vector4(-2309.4, 317.07, 169.6, 96.22)	-- Location for starting NPC
Config.StartModel = 'u_m_m_willyfist'                   	-- Model of starting NPC
Config.StartBlip = false 				                	-- Enable Blip for starting NPC
Config.StartBlipIcon = 67 			                    	-- Starting blip icon (if Config.StarBlip = true)
Config.StartBlipColour = 50 			                	-- Colour of blip icon (if Config.StarBlip = true)
Config.StartBlipText = 'Truck Informant'                	-- Blip text on map (if Config.StarBlip = true)

-- Guard Config
Config.BankRoutes = {                                       -- Start locations of bank truck
    vector4(-2958.72, 493.05, 15.31, 89.11),
    vector4(784.52, -3103.21, 5.8, 341.01),
    vector4(143.13, -1062.75, 29.19, 65.45),
    vector4(1952.38, 3736.85, 32.34, 220.29),
    vector4(-132.03, 6466.75, 31.38, 136.79),
}
Config.AttemptedFinal = vector3(-46.37, -762.79, 32.82) -- Attempted final location of the bank truck
Config.BankTruck = {									-- Bank truck model
	'stockade',
	'stockade3'
}
Config.GuardType = { 									-- Guard models
    "mp_m_securoguard_01",
    "s_m_m_prisguard_01",
	's_m_y_cop_01',
	's_m_y_hwaycop_01',
}
Config.GuardWeapon = { 									-- Guard weapons, all guards will have same weapons
    'weapon_carbinerifle',
}
Config.GuardArmour = 200 								-- Guard Armour

Config.LangType = {
	['error'] = 'error',
	['success'] = 'success',
	['info'] = 'primary'
}

Config.Lang = {
    ['checking'] = "Let\'s see....",
	['call_card'] = "Use Calling Card",
	['request'] = 'Press ~r~[E]~w~ to request information on the truck.',
	['startHeist'] = 'I marked where a bank truck is schedulued to leave from. The truck tracker itself is live, once someone gets in range they will be able to track the position. Get there first, it looked fully loaded!',
    ['mincops'] = 'No risk, no reward. Come back later!',
	['gained'] = "You got ",
	['gained_rare'] = "You found a rare item!",
	['goldBars'] = " gold bars!",
	['markedBills'] = " marked bills!",
	['arm'] = 'Arm Explosive',
	['arm3d'] = 'Press ~r~[E]~w~ to arm explosive.',
	['loot'] = 'Loot',
	['loot3d'] = 'Press ~r~[E]~w~ to Loot.',
	['allDown'] = 'Security systems are already down!',
	['noitem'] = 'You do not have the required item!',
	['blip_inital'] = 'Bank Truck Start',
	['blip_final'] = 'Bank Truck End',
	['explosion'] = 'Explosion in ',
	['cop_notify'] = 'Emergancy Alert! We lost contact with a bank truck, it is live pinging its lcoation to everyone within range; they have provided us with their start and final destination.',
    ['truck_ping'] = 'You are receiving an unknown gps live ping.',
    ['time_limit'] = 'You were too late, the truck was safely delivered.',
    ['nocop'] = 'What? Are you a cop? I\'m not talking to any cops.',
    ['onjob'] = "I already gave you a job!"

}
