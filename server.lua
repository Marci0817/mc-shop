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

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


ESX.RegisterServerCallback('mc_shop:getShops', function(playerId, cb)
	MySQL.Async.fetchAll("SELECT * FROM mc_shop ORDER BY id",{}, 
    function(result)
    	cb(result)
    end) 
end)
local keresetSQL = {}
ESX.RegisterServerCallback('mc_shop:IsPlayerOwnerOfThisShop', function(playerId, cb, store_name)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    local license
    for k,v in ipairs(GetPlayerIdentifiers(xPlayer.source)) do
        if string.match(v, 'license:') then
            license = string.sub(v, 9)
            break
        end
    end
    MySQL.Async.fetchAll("SELECT * FROM mc_shop WHERE store_name = @store_name AND license = @license",
        {
            ["@store_name"] = store_name,
            ["@license"] = license
        }, 
    function(result)
        if result[1] then 
            cb(true)
        else
            cb(false)
        end
    end) 
end)

--[[RegisterCommand("createshop", function(source, args, rawCommand)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.getGroup() == "admin" then
		if args[1] ~= nil and args[2] ~= nil and args[3] ~= nil and args[4] ~= nil and args[5] ~= nil and args[6] ~= nil then	
            -------- Ez azért van mert változott egy dolog és nem szeretnék mindent átírni ---------
            local temp = args[2]            
            local temp2 = args[3] 
            local temp3 = args[4]
            args[2] = args[5]
            if not args[6] then
                args[6] = ""
            end
            args[3] = args[6]
            args[4] = tonumber(temp)
            args[5] = tonumber(temp2)
            args[6] = tonumber(temp3)
            --print(args[2] .. " ".. args[3] .. " ".. args[4] .. " ".. args[5] .. " ".. args[6] .. " ")
            ----------------------------------------------------------------------------------------
			local xTarget = ESX.GetPlayerFromId(tonumber(args[1]))
			if tonumber(args[1]) then
				if not args[3] then
					args[3] = ""
				end
				MySQL.Async.fetchAll("SELECT * FROM mc_shop WHERE store_name = @store_name",{
					["@store_name"] = args[2] .. " ".. args[3],
				}, 
			    function(result)
			        if result[1] == nil then
			           	local identifier
						for k,v in ipairs(GetPlayerIdentifiers(xTarget.source)) do
							if string.match(v, 'license:') then
								identifier = string.sub(v, 9)
								break
							end
						end
                        --print(args[4] .. " " .. args[5] .. " " .. args[6])
			            TriggerClientEvent("mc_shop:createNewShop", xPlayer.source, args[2], args[3], identifier, args[4] , args[5] , args[6])
					else
						TriggerClientEvent("chatMessage", xPlayer.source, Config.NameChat .. Config.StoreExsist)
			        end
			    end)
			end
	    else
			TriggerClientEvent(chatMessage, source, Config.NameChat .. Config.Use)
	    end
	else
		TriggerClientEvent("chatMessage", source, Config.NameChat .. Config.NoPermission)
	end
end)]]

ESX.RegisterServerCallback('mc_shop:createShopCheck', function(playerId, cb, player_ID, store_name)
    local xTarget = ESX.GetPlayerFromId(tonumber(player_ID))
    local xPlayer = ESX.GetPlayerFromId(playerId)
    local license
    MySQL.Async.fetchAll("SELECT * FROM mc_shop WHERE store_name = @store_name",{
        ["@store_name"] = store_name,
    }, 
    function(result)
        if result[1] == nil then
            if xTarget then
                local identifier
                for k,v in ipairs(GetPlayerIdentifiers(xTarget.source)) do
                    if string.match(v, 'license:') then
                        identifier = string.sub(v, 9)
                        break
                    end
                end
                cb(identifier)
            else
                TriggerClientEvent("chatMessage", xPlayer.source, Config.NameChat .. Config.notOnline)
            end
        else
            cb(false)
            TriggerClientEvent("chatMessage", xPlayer.source, Config.NameChat .. Config.StoreExsist)
        end
    end)
end)
RegisterNetEvent("mc_shop:removeProductFromStorage")
AddEventHandler("mc_shop:removeProductFromStorage", function(data)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll("SELECT * FROM mc_shop WHERE store_name = @store_name",{
        ["@store_name"] = data["product_shopName"],
    }, 
    function(result)
        if result then
            local items = makeItVector(result[1])
            local anIndex = nil
            for i=1,#items do
                if items[i][2] == data["product_name"] then
                    anIndex = i
                    break
                end
            end
            if anIndex == nil then
                TriggerClientEvent("chatMessage", xPlayer.source, Config.NameChat .. Config.removeError)
            else
                local xzt =  tonumber(result[1].kereset)
                local xzt2 = tonumber(items[anIndex][4]) --count
                local xzt3
                for i=1,#Config.itemsInShop do
                    if Config.itemsInShop[i][1] == data["product_name"] then
                        xzt3 = tonumber(Config.itemsInShop[i][2])
                        break
                    end
                end
                xzt = xzt + math.floor((xzt2 * xzt3)/2)
                table.remove(items, anIndex)
                MySQL.Async.fetchAll("UPDATE mc_shop SET items = @items WHERE store_name = @store_name",{
                    ["@items"] = backToString(items),
                    ["@store_name"] = data["product_shopName"]
                },
                function(result)
                    
                end)
                MySQL.Async.fetchAll("UPDATE mc_shop SET kereset = @kereset WHERE store_name = @store_name",{
                    ["@kereset"] = xzt,
                    ["@store_name"] = data["product_shopName"]
                },
                function(result)
                    TriggerClientEvent("chatMessage", xPlayer.source, Config.NameChat .. Config.removeSucces)
                end)
            end
        else
            TriggerClientEvent("chatMessage", xPlayer.source, Config.NameChat .. Config.StoreExsist)
        end
    end)
end)
RegisterNetEvent("mc_shop:kivetel")
AddEventHandler("mc_shop:kivetel", function(data)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xyPenz = 0
    MySQL.Async.fetchAll("SELECT * FROM mc_shop WHERE store_name = @store_name",{
        ["@store_name"] = data["shopName"],
    }, 
    function(result)
        xyPenz = result[1].kereset
        FUCK(xyPenz)

    end)
    MySQL.Async.fetchAll("UPDATE mc_shop SET kereset = @kereset WHERE store_name = @store_name",{
        ["@kereset"] = 0,
        ["@store_name"] = data["shopName"]
    },
    function(result)
        TriggerClientEvent("chatMessage", xPlayer.source, Config.NameChat .. Config.SuccesKereslet)
    end)
    function FUCK(rrr)
        xPlayer.addMoney(rrr)
    end
end)
RegisterNetEvent("mc_shop:newItem")
AddEventHandler("mc_shop:newItem", function(data)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll("SELECT * FROM mc_shop WHERE store_name = @store_name",{
        ["@store_name"] = data["product_shopName"],
    }, 
    function(result)
        local ct = makeItVector(result[1])
        local tc = nil
        for i=1,#Config.itemsInShop do
            if Config.itemsInShop[i][1] == data["product_newValue"] then
                tc = i
                break
            end
        end
        if tc ~= nil then
            local vanEmar = false
            for i=1,#ct do
                if ct[i][2] == data["product_newValue"] then
                    vanEmar = true
                    break
                end
            end
            if not vanEmar then
                local newString = backToString(ct)
                if newString == "" then
                    newString = Config.itemsInShop[tc][3] .. "," .. Config.itemsInShop[tc][1] .. "," .. Config.itemsInShop[tc][2] .. ",1"
                else
                    newString = newString .. "][" .. Config.itemsInShop[tc][3] .. "," .. Config.itemsInShop[tc][1] .. "," .. Config.itemsInShop[tc][2] .. ",1"
                end
                MySQL.Async.fetchAll("UPDATE mc_shop SET items = @items WHERE store_name = @store_name",{
                    ["@items"] = newString,
                    ["@store_name"] = data["product_shopName"]
                },
                function(result)
                    Citizen.Wait(10)
                    TriggerClientEvent("chatMessage", xPlayer.source, Config.NameChat .. Config.SikeresItemAdd)
                    Citizen.Wait(10)
                end)
            else
                TriggerClientEvent("chatMessage", xPlayer.source, Config.NameChat .. Config.vanMarIlyen)
            end
        else
            TriggerClientEvent("chatMessage", xPlayer.source, Config.NameChat .. Config.nincsIlyenItem)
        end
    end)
end)
RegisterNetEvent("mc_shop:setPrice")
AddEventHandler("mc_shop:setPrice", function(data)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll("SELECT * FROM mc_shop WHERE store_name = @store_name",{
        ["@store_name"] = data["product_shopName"],
    }, 
    function(result)
        local ct = makeItVector(result[1])
        local tc
        for i=1,#Config.itemsInShop do
            if Config.itemsInShop[i][1] == data["product_name"] then
                tc = tonumber(Config.itemsInShop[i][2])
                break
            end
        end
        if tc <= tonumber(data["product_newValue"]) then
            local tztz
            for x=1,#ct do
                if ct[x][2] == data["product_name"] then
                    tztz = x
                    break
                end
            end
            ct[tztz][3] = tonumber(data["product_newValue"])
            MySQL.Async.fetchAll("UPDATE mc_shop SET items = @items WHERE store_name = @store_name",{
                ["@items"] = backToString(ct),
                ["@store_name"] = data["product_shopName"]
            },
            function(result)
                TriggerClientEvent("chatMessage", xPlayer.source, Config.NameChat .. Config.SuccesArValtozas)
            end)
        else
            TriggerClientEvent("chatMessage", xPlayer.source, Config.NameChat .. Config.nagyKerAr)
        end
    end)
end)
RegisterNetEvent("mc_shop:refreshStorageCount")
AddEventHandler("mc_shop:refreshStorageCount", function(itemDetails)
    local isExsist = ""
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll("SELECT * FROM mc_shop WHERE store_name = @store_name",{
        ["@store_name"] = itemDetails["product_shopName"]
    }, 
    function(result)
        if result[1] then
            local temp2 = makeItVector(result[1])     
            local keresItem = nil
            for i=1,#temp2 do
                if temp2[i][2] == itemDetails["product_name"] then
                    keresItem = i
                    isExsist = ""
                    break
                end
                if i == #temp2 and keresItem == nil then
                    isExsist = "InvaildItem"
                end
            end
            if keresItem ~= nil and isExsist == "" then
                local indexStor = nil
                for i=1,#Config.itemsInShop do
                    if Config.itemsInShop[i][1] == itemDetails["product_name"] then
                        indexStor = i
                        break
                    end
                end
                local tempSum = tonumber(itemDetails["product_count"]) * tonumber(Config.itemsInShop[indexStor][2])
                if itemDetails["product_price"] ~= tempSum then
                    isExsist = "PriceChange"
                end
            end
            if isExsist == "" then
                if xPlayer.getMoney() >= tonumber(itemDetails["product_price"]) then
                    xPlayer.removeMoney(tonumber(itemDetails["product_price"]))
                    local tempSum2 = tonumber(temp2[keresItem][4]) + tonumber(itemDetails["product_count"])
                    temp2[keresItem][4] = tostring(tempSum2)
                    MySQL.Async.fetchAll("UPDATE mc_shop SET items = @items WHERE store_name = @store_name",{
                        ["@items"] = backToString(temp2),
                        ["@store_name"] = itemDetails["product_shopName"]
                    },
                    function(result)
                        
                    end)
                else
                    TriggerClientEvent("chatMessage", xPlayer.source, Config.NameChat .. Config.NotEnoughMoney)
                end
            elseif isExsist == "InvaildItem" then
                TriggerClientEvent("chatMessage", xPlayer.source, Config.NameChat .. Config.InvaildItem)
                if Config.Debug then
                    print("mc_shop: [".. xPlayer.source .."] "..GetPlayerName(xPlayer.source).. " próbálkozott valami csúnyasággal.")
                end
            elseif isExsist == "PriceChange" then
                TriggerClientEvent("chatMessage", xPlayer.source, Config.NameChat .. Config.PriceNemJo)
                if Config.Debug then
                    print("mc_shop: [".. xPlayer.source .."] "..GetPlayerName(xPlayer.source).. " próbálkozott valami csúnyasággal.")
                end
            else
                TriggerClientEvent("chatMessage", xPlayer.source, Config.NameChat .. Config.ismeretlen)
                if Config.Debug then
                    print("mc_shop: [".. xPlayer.source .."] "..GetPlayerName(xPlayer.source).. " egy ismeretlen hibát okozott. ( Keresse meg Marci#0102 -t )")
                end
            end
        else
            TriggerClientEvent("chatMessage", xPlayer.source, Config.NameChat .. Config.NoShop)
            if Config.Debug then
                 print("mc_shop: [".. xPlayer.source .."] "..GetPlayerName(xPlayer.source).. " próbálkozott valami csúnyasággal.")
            end
        end

    end)
end)

RegisterNetEvent("mc_shop:completeTheBuy")
AddEventHandler("mc_shop:completeTheBuy", function(itemDetails)
        local isExsist = ""
        local xPlayer = ESX.GetPlayerFromId(source)
        MySQL.Async.fetchAll("SELECT * FROM mc_shop WHERE store_name = @store_name",{
            ["@store_name"] = itemDetails["product_shopName"]
        }, 
        function(result)
            if result[1] then
                local temp = mysplit(result[1].items, "][") --1. Név 2. lehívó 3. Ár 4. raktáron
                local temp2 = {}
                for i=1,#temp do
                    table.insert(temp2, mysplit(temp[i], ","))
                end
                local keresItem = nil
                for i=1,#temp2 do
                    if temp2[i][2] == itemDetails["product_name"] then
                        keresItem = i
                        isExsist = ""
                        break
                    end
                    if i == #temp2 and keresItem == nil then
                        isExsist = "InvaildItem"
                    end
                end
                if keresItem ~= nil and isExsist == "" then
                    if itemDetails["product_price"] ~= itemDetails["product_count"] * tonumber(temp2[keresItem][3]) then
                        isExsist = "PriceChange"
                    end
                end
                if isExsist == "" then
                    if xPlayer.getMoney() >= tonumber(itemDetails["product_price"]) then
                        if xPlayer.canCarryItem(itemDetails["product_name"], tonumber(itemDetails["product_count"])) then
                            MySQL.Async.fetchAll("SELECT * FROM mc_shop WHERE store_name = @store_name",
                            {
                                ["@store_name"] =  itemDetails["product_shopName"]
                            }, 
                            function(result)
                                if result[1].kereset and result[1].items then
                                    local tempMoney = tonumber(result[1].kereset)
                                    tempMoney = tempMoney + tonumber(itemDetails["product_price"])
                                    local iii = makeItVector(result[1])
                                    local va = nil
                                    for i=1,#iii do
                                        if iii[i][2] == itemDetails["product_name"] then
                                            va = i
                                            break
                                        end
                                    end
                                    if tonumber(tonumber(iii[va][4]) - tonumber(itemDetails["product_count"])) >= 0 then
                                        keresetKeres(tempMoney, itemDetails["product_shopName"])
                                        --[[MySQL.Async.fetchAll("UPDATE mc_shop SET kereset = @kereset WHERE store_name = @store_name ",{
                                            ["@kereset"] = tempMoney,
                                            ["@store_name"] = itemDetails["product_shopName"]
                                        },
                                        function(result)
                                        end)]]
                                        iii[va][4] = tonumber(iii[va][4]) - tonumber(itemDetails["product_count"])
                                        MySQL.Async.fetchAll("UPDATE mc_shop SET items = @items WHERE store_name = @store_name ",{
                                            ["@items"] = backToString(iii),
                                            ["@store_name"] = itemDetails["product_shopName"]
                                        },
                                        function(result)
                                            xPlayer.removeMoney(tonumber(itemDetails["product_price"]))
                                            xPlayer.addInventoryItem(itemDetails["product_name"], tonumber(itemDetails["product_count"]))
                                            TriggerClientEvent("chatMessage", xPlayer.source, Config.NameChat .. Config.SuccesBuy)
                                        end)
                                    else
                                        TriggerClientEvent("chatMessage", xPlayer.source, Config.NameChat .. Config.OutOfStock)
                                    end
                                end
                            end)
                        else
                            TriggerClientEvent("chatMessage", xPlayer.source, Config.NameChat .. Config.cantCarry)
                        end
                    else
                        TriggerClientEvent("chatMessage", xPlayer.source, Config.NameChat .. Config.NotEnoughMoney)
                    end
                elseif isExsist == "InvaildItem" then
                    TriggerClientEvent("chatMessage", xPlayer.source, Config.NameChat .. Config.InvaildItem)
                    if Config.Debug then
                        print("[".. xPlayer.source .."] "..GetPlayerName(xPlayer.source).. " próbálkozott valami csúnyasággal.")
                    end
                elseif isExsist == "PriceChange" then
                    TriggerClientEvent("chatMessage", xPlayer.source, Config.NameChat .. Config.PriceNemJo)
                    if Config.Debug then
                        print("[".. xPlayer.source .."] "..GetPlayerName(xPlayer.source).. " próbálkozott valami csúnyasággal.")
                    end
                else
                    TriggerClientEvent("chatMessage", xPlayer.source, Config.NameChat .. Config.ismeretlen)
                    if Config.Debug then
                        print("[".. xPlayer.source .."] "..GetPlayerName(xPlayer.source).. " egy ismeretlen hibát okozott. ( Keresse meg Marci#0102 -t )")
                    end
                end
            else
                TriggerClientEvent("chatMessage", xPlayer.source, Config.NameChat .. Config.NoShop)
                if Config.Debug then
                    print("[".. xPlayer.source .."] "..GetPlayerName(xPlayer.source).. " próbálkozott valami csúnyasággal.")
                end
            end
        end)
end)

RegisterNetEvent("mc_shop:updateShop")
AddEventHandler("mc_shop:updateShop", function(data)
    MySQL.Async.fetchAll("INSERT INTO mc_shop (license, store_name, coords, coordsStorage, items) VALUES(@license, @store_name, @coords, @coordsStorage, @items)",{
    	["@license"] = data.license,
    	["@store_name"] = data.store_name,
    	["@coords"] = data.coords,
        ["@coordsStorage"] = data.coordsStorage,
    	["@items"] = data.items
    },
    function(result)
        --print("sikerese")
    end)
end)

function mysplit (inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
end
function backToString(t)
    local s = {""}
    for i=1,#t do
      for j=1,#t[i] do
        s[#s+1] = t[i][j]
        if j ~= #t[i] then
          s[#s+1] = ","
        end
      end
      if i~= #t then
       s[#s+1] = "]["
      end
    end
    s[#s+1] = ""
    s = table.concat(s)
    return s
end
function makeItVector(t)
    local temp = mysplit(t.items, "][")
    local temp2 = {}
    for i=1,#temp do
        table.insert(temp2, mysplit(temp[i], ","))
    end
    return temp2
end
function keresetKeres(x,y) -- x a pénz, y a bolt neve
    local z = nil
    for i=1,#keresetSQL do
        if keresetSQL[i][2] == y then
            z = i
            break
        end
    end
    if z ~= nil then
        keresetSQL[z][1] = keresetSQL[z][1] + tonumber(x)
    else
        table.insert(keresetSQL, {x, y})
    end
    --printTable(keresetSQL)
end
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(15000)
        if #keresetSQL > 0 then
            for i=1,#keresetSQL do
                MySQL.Async.fetchAll("UPDATE mc_shop SET kereset = @kereset WHERE store_name = @store_name ",{
                    ["@kereset"] = keresetSQL[i][1],
                    ["@store_name"] = keresetSQL[i][2]
                },
                function(result)
                end)
            end
            keresetSQL = {}
            --print("mc_shop: Adatbázis kereslet feltöltve.")
        end
    end
end)                     