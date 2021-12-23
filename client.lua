local function printTable( t )
 
    local printTable_cache = {}
 
    local function sub_printTable( t, indent )
 
        if ( printTable_cache[tostring(t)] ) then
            print( indent .. "*" .. tostring(t) )
        else
            printTable_cache[tostring(t)] = true
            if ( type( t ) == "table" ) then
                for pos,val in pairs( t ) do
                    if ( type(val) == "table" ) then
                        print( indent .. "[" .. pos .. "] => " .. tostring( t ).. " {" )
                        sub_printTable( val, indent .. string.rep( " ", string.len(pos)+8 ) )
                        print( indent .. string.rep( " ", string.len(pos)+6 ) .. "}" )
                    elseif ( type(val) == "string" ) then
                        print( indent .. "[" .. pos .. '] => "' .. val .. '"' )
                    else
                        print( indent .. "[" .. pos .. "] => " .. tostring(val) )
                    end
                end
            else
                print( indent..tostring(t) )
            end
        end
    end
 
    if ( type(t) == "table" ) then
        print( tostring(t) .. " {" )
        sub_printTable( t, "  " )
        print( "}" )
    else
        sub_printTable( t, "  " )
    end
end

ESX = nil

local npcPos = {}
local openStorage = {}
local shopData = {}
local shopIsOpen = false
local storageIsOpen = false
local nearestShop 

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	Citizen.Wait(400)
	loadShops()
	while true do
		Citizen.Wait(0)
		local playerPos = GetEntityCoords(PlayerPedId())
		for i=1,#npcPos do
			local distanceNPC = #(playerPos - vector3(npcPos[i][1], npcPos[i][2], npcPos[i][3]))
			if distanceNPC < 2 and not shopIsOpen then
				ESX.ShowHelpNotification(Config.openShopText)
				if IsControlJustPressed(0, 46) then
					refreshDataBase()
					Citizen.Wait(150)
					SendNUIMessage({
						type = "show",
						shopData = shopData[i]
					})
					SetNuiFocus(true, true)
					shopIsOpen = true
				end
			end
			if shopIsOpen then
				local distanceCloseNPC = #(playerPos - getNearestShop(true, GetEntityCoords(PlayerPedId())))
				if distanceCloseNPC > 5 then
					SendNUIMessage({
						type = "hide",
					})
					SetNuiFocus(false, false)
					shopIsOpen = false
				end
			end
		end
		for x=1,#openStorage do
			local distanceNPC = #(playerPos - vector3(openStorage[x][1], openStorage[x][2], openStorage[x][3]))
			if distanceNPC < 2 and not storageIsOpen then
				ESX.ShowHelpNotification(Config.openStorageText)
				if IsControlJustPressed(0, 46) then
					refreshDataBase()
					Citizen.Wait(150)
					local storeNameCheck = shopData[x][1]["store_name"]
					ESX.TriggerServerCallback('mc_shop:IsPlayerOwnerOfThisShop', function(cb)
						if cb then
							local lehetsegesItem = Config.itemsInShop
							SendNUIMessage({
								type = "openStorage",
								shopData = shopData[x],
								nagykerAr = lehetsegesItem
							})
							SetNuiFocus(true, true)
							storageIsOpen = true
						else
							TriggerEvent("chatMessage", Config.NameChat .. Config.NotYours)
						end
					end, storeNameCheck)
				end
			end
		end
	end
end)

function getNearestShop(coord, posShop)
	local playerPos = posShop
	local min = 999999999 * 99999
	local minIndex = 0 
	for i=1, #npcPos do
		local distanceNPC = #(playerPos - vector3(npcPos[i][1], npcPos[i][2], npcPos[i][3]))
		if distanceNPC < min then
			min = distanceNPC
			minIndex = i
		end
	end
	if coord then
		return vector3(npcPos[minIndex][1], npcPos[minIndex][2], npcPos[minIndex][3])
	else
		return min
	end
end

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerData)
	Citizen.Wait(400)
	loadShops()
end)

RegisterNUICallback("closeShop", function()
    SetNuiFocus(false, false)
    shopIsOpen = false
end)
RegisterNUICallback("kivetel", function(data)
	ESX.TriggerServerCallback('mc_shop:IsPlayerOwnerOfThisShop', function(cb)
		if cb then
			TriggerServerEvent("mc_shop:kivetel", data)
		else
			TriggerEvent("chatMessage", Config.NameChat .. Config.NotYours)
		end
	end, data["shopName"])
end)
RegisterNUICallback("setPrice", function(data)
    ESX.TriggerServerCallback('mc_shop:IsPlayerOwnerOfThisShop', function(cb)
		if cb then
			TriggerServerEvent("mc_shop:setPrice", data)
		else
			TriggerEvent("chatMessage", Config.NameChat .. Config.NotYours)
		end
	end, data["product_shopName"])
end)
RegisterNUICallback("newItem", function(data)
    ESX.TriggerServerCallback('mc_shop:IsPlayerOwnerOfThisShop', function(cb)
		if cb then
			TriggerServerEvent("mc_shop:newItem", data)
		else
			TriggerEvent("chatMessage", Config.NameChat .. Config.NotYours)
		end
	end, data["product_shopName"])
end)
RegisterNUICallback("closeStorage", function()
    SetNuiFocus(false, false)
    storageIsOpen = false
end)
RegisterNUICallback("removeProduct", function(data)
	ESX.TriggerServerCallback('mc_shop:IsPlayerOwnerOfThisShop', function(cb)
		if cb then
			TriggerServerEvent("mc_shop:removeProductFromStorage", data)
		else
			TriggerEvent("chatMessage", Config.NameChat .. Config.NotYours)
		end
	end, data["product_shopName"])
end)
RegisterNUICallback("refreshStorageCount", function(data, cb)
    local itemDetails = data
    TriggerServerEvent("mc_shop:refreshStorageCount", itemDetails)
end)
RegisterNUICallback("buyProduct", function(data, cb)
    local itemDetails = data
    TriggerServerEvent("mc_shop:completeTheBuy", itemDetails)
end)
RegisterCommand("createshop", function(source, args, rawCommand)
	createShopMenu()
end)

local cr_name = "Üres"
local cr_loc = "Nincs megadva"
local cr_loc_pos
local cr_loc_head
local cr_stor_loc = "Nincs megadva"
local cr_stor_loc_pos
local cr_id = "Üres"
local options = {
	{label = "Bolt tulajdonos idje".. " ( ".. cr_id .. ")", value = "cr_id_v"},
	{label = "Bolt neve".. " ( ".. cr_name .. ")", value = "cr_name_v"},
	{label = "NPC helye" .. " ( ".. cr_loc .. ")", value = "cr_loc"},
	{label = "Raktár helye".. " ( ".. cr_stor_loc .. ")", value = "cr_stor_loc"},
	{label = "Bolt elkészítése", value = "createShopSubmit"},
	{label = "Bezárás", value = "close"},
}
function createShopMenu()
	ESX.UI.Menu.Open("default", GetCurrentResourceName(), "createShop",{
		title = "mc_shop - Bolt létrehozás",
		align = Config.MenuAlign,
		elements = options
	}, function(data, menu)
		if data.current.value == "cr_name_v" then
			menu.close()
			DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP8", "", "", "", "", "", 32 + 1)
			
			while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
				Citizen.Wait( 0 )
			end
			
			cr_name = GetOnscreenKeyboardResult()
			
			if cr_name then
				options = {
					{label = "Bolt tulajdonos idje".. " ( ".. cr_id .. ")", value = "cr_id_v"},
					{label = "Bolt neve".. " ( ".. cr_name .. ")", value = "cr_name_v"},
					{label = "NPC helye" .. " ( ".. cr_loc .. ")", value = "cr_loc"},
					{label = "Raktár helye".. " ( ".. cr_stor_loc .. ")", value = "cr_stor_loc"},
					{label = "Bolt elkészítése", value = "createShopSubmit"},
					{label = "Bezárás", value = "close"},
				}
				createShopMenu()
			end
		elseif data.current.value == "cr_id_v" then
			menu.close()
			DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP8", "", "", "", "", "", 32 + 1)
			
			while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
				Citizen.Wait( 0 )
			end
			
			cr_id = tonumber(GetOnscreenKeyboardResult())
			
			if cr_id then
				options = {
					{label = "Bolt tulajdonos idje".. " ( ".. cr_id .. ")", value = "cr_id_v"},
					{label = "Bolt neve".. " ( ".. cr_name .. ")", value = "cr_name_v"},
					{label = "NPC helye" .. " ( ".. cr_loc .. ")", value = "cr_loc"},
					{label = "Raktár helye".. " ( ".. cr_stor_loc .. ")", value = "cr_stor_loc"},
					{label = "Bolt elkészítése", value = "createShopSubmit"},
					{label = "Bezárás", value = "close"},
				}
				createShopMenu()
			end		
		elseif data.current.value == "cr_loc" then
			menu.close()
			cr_loc_pos = GetEntityCoords(PlayerPedId())
			cr_loc_head = GetEntityHeading(PlayerPedId())
			if cr_loc == "Nincs megadva" then
				cr_loc = "Megadva"
				options = {
					{label = "Bolt tulajdonos idje".. " ( ".. cr_id .. ")", value = "cr_id_v"},
					{label = "Bolt neve".. " ( ".. cr_name .. ")", value = "cr_name_v"},
					{label = "NPC helye" .. " ( ".. cr_loc .. ")", value = "cr_loc"},
					{label = "Raktár helye".. " ( ".. cr_stor_loc .. ")", value = "cr_stor_loc"},
					{label = "Bolt elkészítése", value = "createShopSubmit"},
					{label = "Bezárás", value = "close"},
				}
			end
			createShopMenu()
		elseif data.current.value == "cr_stor_loc" then
			menu.close()
			cr_stor_loc_pos = GetEntityCoords(PlayerPedId())
			if cr_stor_loc == "Nincs megadva" then
				cr_stor_loc = "Megadva"
				options = {
					{label = "Bolt tulajdonos idje".. " ( ".. cr_id .. ")", value = "cr_id_v"},
					{label = "Bolt neve".. " ( ".. cr_name .. ")", value = "cr_name_v"},
					{label = "NPC helye" .. " ( ".. cr_loc .. ")", value = "cr_loc"},
					{label = "Raktár helye".. " ( ".. cr_stor_loc .. ")", value = "cr_stor_loc"},
					{label = "Bolt elkészítése", value = "createShopSubmit"},
					{label = "Bezárás", value = "close"},
				}
			end
			createShopMenu()
		elseif data.current.value == "createShopSubmit" then 
			if cr_stor_loc == "Megadva" and cr_loc == "Megadva" and cr_name ~= "Üres" and cr_id ~= "Üres" then
				ESX.TriggerServerCallback('mc_shop:createShopCheck', function(cb)
					if cb ~= false then
						TriggerEvent("mc_shop:createNewShop", cr_name, cb, cr_loc_pos, cr_stor_loc_pos, cr_loc_head)
						cr_name = "Üres"
						cr_loc = "Nincs megadva"
						cr_stor_loc = "Nincs megadva"
						cr_id = "Üres"
						options = {
							{label = "Bolt tulajdonos idje".. " ( ".. cr_id .. ")", value = "cr_id_v"},
							{label = "Bolt neve".. " ( ".. cr_name .. ")", value = "cr_name_v"},
							{label = "NPC helye" .. " ( ".. cr_loc .. ")", value = "cr_loc"},
							{label = "Raktár helye".. " ( ".. cr_stor_loc .. ")", value = "cr_stor_loc"},
							{label = "Bolt elkészítése", value = "createShopSubmit"},
							{label = "Bezárás", value = "close"},
						}
						menu.close()
					end
				end, cr_id, cr_name)
			else
				TriggerEvent("chatMessage", Config.NameChat .. Config.parameter)
			end
		elseif data.current.value == "close" then
			menu.close()
		end
	end,
	function(data, menu)
		menu.close()
	end)
end
function loadShops()
	ESX.TriggerServerCallback('mc_shop:getShops', function(cb)
		for i=1,#cb do
			local pos = json.decode((cb[i].coords))
			local posStorage = json.decode((cb[i].coordsStorage))
			table.insert(shopData, {cb[i]})
			local blip = AddBlipForCoord(pos[1], pos[2], pos[3])
			SetBlipSprite (blip, 52)
			SetBlipScale  (blip, 1.0)
			SetBlipColour (blip, 2)
			SetBlipCategory(blip, 10)
			BeginTextCommandSetBlipName('STRING')
			AddTextComponentString(cb[i].store_name)
			EndTextCommandSetBlipName(blip)

		    RequestModel(GetHashKey(Config.NPCName))
		    while not HasModelLoaded(GetHashKey(Config.NPCName)) do
		    	Wait(1)
		    end
		  
		    local ped =  CreatePed(4, Config.NPCHash, pos[1], pos[2], pos[3]-1, 3374176, false, true)
		    SetEntityHeading(ped, pos[4])
		    FreezeEntityPosition(ped, true)
		    SetEntityInvincible(ped, true)
		    SetBlockingOfNonTemporaryEvents(ped, true)

		    table.insert(npcPos, {pos[1], pos[2], pos[3], pos[4]})
		    table.insert(openStorage, {posStorage[1], posStorage[2], posStorage[3]})
		end
	end)
end

function refreshDataBase()
	shopData = {}
	ESX.TriggerServerCallback('mc_shop:getShops', function(cb)
		for i=1,#cb do
			table.insert(shopData, {cb[i]})
		end
	end)
	shopDataCh = false
end

RegisterNetEvent('mc_shop:createNewShop')
AddEventHandler('mc_shop:createNewShop', function(store_name, license, posShop, posStor, headShop)
	if getNearestShop(false, posShop) > 10 then
		local tableShop = {
			store_name = store_name,
			license = license,
			coords = "{"..posShop.x..",".. posShop.y..",".. posShop.z ..",".. headShop .."}",
			coordsStorage = "{".. posStor.x .. ",".. posStor.y .. "," .. posStor.z .. "}",
			items = "",
		}
		table.insert(shopData, {tableShop})
		local blip = AddBlipForCoord(posShop.x, posShop.y, posShop.z)
		SetBlipSprite (blip, 52)
		SetBlipScale  (blip, 1.0)
		SetBlipColour (blip, 2)
		SetBlipCategory(blip, 10)
		BeginTextCommandSetBlipName('STRING')
		AddTextComponentString(store_name)
		EndTextCommandSetBlipName(blip)

		RequestModel(GetHashKey("u_m_y_baygor"))
		while not HasModelLoaded(GetHashKey("u_m_y_baygor")) do
			Wait(1)
		end
			  
		local ped =  CreatePed(4, 0x5244247D, posShop.x, posShop.y, posShop.z-1, 3374176, false, true)
		SetEntityHeading(ped, headShop)
		FreezeEntityPosition(ped, true)
		SetEntityInvincible(ped, true)
		SetBlockingOfNonTemporaryEvents(ped, true)

		TriggerEvent("chatMessage", Config.NameChat .. Config.Succes)
		table.insert(npcPos, {posShop.x, posShop.y, posShop.z, headShop})
		table.insert(openStorage, {posStor.x, posStor.y, posStor.z})
		TriggerServerEvent("mc_shop:updateShop", tableShop)
	else
		TriggerEvent("chatMessage", Config.NameChat .. "Ilyen közel nem lehet kettő bolt.")
	end
end)

function DrawText3Ds(x, y, z, text)
	SetTextScale(0.4, 0.4)
	SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end