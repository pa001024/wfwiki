--Attempting to recreate Module:Weapons for Mods
--go away error messages
--

local p = {}

local ModData = mw.loadData( 'Module:Mods/data' )
local Shared = require( "Module:Shared" )
local Icon = require( "Module:Icon" )

local function getMod(name)
    local _mod = ModData["Mods"][name]
    if _mod ~= nil and _mod.Name == name then
        return _mod
    else
        for modName, Mod in pairs(ModData["Mods"]) do
            if modName == name or Mod.Name == name then
                return Mod
            end
        end
    end
end

local function ifModExists(name, _mod)
    if type(_mod) ~= table then
        _mod = ModData["Mods"][name]
    elseif _mod.Name == name then
        return true
    end
    
    if _mod ~= nil and _mod.Name == name then
        return true
    else
        for modName, Mod in pairs(ModData["Mods"]) do
            if modName == name or Mod.Name == name then
                return true
            end
        end
    end
    return false
end

function p.getValueRaw(frame)
    local ModName = frame.args[1]
    local ValName = frame.args[2]
    local Mod = getMod(ModName)
    if Mod ~= nil then
        return Mod[ValName]
    end
end

function p.getValue(frame)
    local ModName = frame.args[1]
    local ValName = frame.args[2]
    
    local Mod = getMod(ModName)
    
    if(ModName == nil) then
        return "ERROR: No mod specified"
    elseif(ValName == nil) then
        return "ERROR: No value specified"
    elseif ifModExists (ModName,Mod) == false then
        return "ERROR: No such mod "..ModName.." found"
    end
    
    local UpName = string.upper(ValName)
    if(UpName == "NAME") then
        return ModName
    elseif(UpName == "IMAGE") then
        if(Mod.Image ~= nil) then
            return Mod.Image
        else
            return "Panel.png"
        end
    elseif(UpName == "LINK") then
        if(Mod.Link ~= nil) then
            return Mod.Link
        else
            return Mod.Name
        end
    elseif(UpName == "POLARITY") then
        if(Mod.Polarity ~= nil) then
            return Mod.Polarity
        else
            return "None"
        end
    elseif(UpName == "POLARITYICON") then
        if(Mod.Polarity ~= nil) then
            return Icon._Pol(Mod.Polarity)
        else
            return "None"
        end
    elseif(UpName == "RARITY") then
        if(Mod.Rarity ~= nil) then
            return Mod.Rarity
        else
            return "Unknown"
        end
    elseif(UpName == "TRADETAX") then
        if(Mod.Rarity ~= nil) then
            if(Mod.Rarity == "Common") then
                return Icon._Item("Credits").." 2,000"
            elseif(Mod.Rarity == "Uncommon") then
                return Icon._Item("Credits").." 4,000"
            elseif(Mod.Rarity == "Rare") then
                return Icon._Item("Credits").." 8,000"
            elseif(Mod.Rarity == "Legendary") then
                return Icon._Item("Credits").." 1,000,000"
            else
                return nil
            end
        else
            return nil
        end
    elseif(UpName == "TRANSMUTABLE") then
        if(Mod.Transmutable ~= nil) then
            if(Mod.Transmutable) then
                return '[[Transmutation|<span style="color:green">Transmutable</span>]]'
            else
                return '[[Transmutation|<span style="color:red">Untransmutable</span>]]'
            end
        else
            return '[[Transmutation|<span style="color:green">Transmutable</span>]]'
        end
    else
        return ModData["Mods"][ModName][ValName]
    end
end

function p.buildModTableByRarity()
 
    buildLegendaryTable = ""
    countLegendary = 0
    buildRareTable = ""
    countRare = 0
    buildUncommonTable = ""
    countUncommon = 0
    buildCommonTable = ""
    countCommon = 0
 
    for key, Mod in Shared.skpairs(ModData["Mods"]) do
--        mw.log(Mod.Rarity)
 
 
        if Mod.Rarity == "Legendary" then
            buildLegendaryTable = buildLegendaryTable .. "[[File:" .. Mod.Image .. "|114px|link=" .. Mod.Name .."]]"
            countLegendary = countLegendary + 1
        elseif Mod.Rarity == "Rare" then
            buildRareTable = buildRareTable .. "[[File:" .. Mod.Image .. "|114px|link=" .. Mod.Name .."]]"
            countRare = countRare + 1
        elseif Mod.Rarity == "Uncommon" then
            buildUncommonTable = buildUncommonTable .. "[[File:" .. Mod.Image .. "|114px|link=" .. Mod.Name .."]]"
            countUncommon = countUncommon + 1
        elseif Mod.Rarity == "Common" then
            buildCommonTable = buildCommonTable .. "[[File:" .. Mod.Image .. "|114px|link=" .. Mod.Name .."]]"
            countCommon = countCommon +1
        end
    end
    
    countTotal = countLegendary + countRare + countUncommon + countCommon
        buildTable = 
countTotal .. "\n" ..
"{| border=\"1\" cellpadding=\"1\" cellspacing=\"1\" class=\"article-table\"\n" ..
"|-\n" ..
"!Legendary\n" .. countLegendary .. "\n" ..
"| " .. buildLegendaryTable .. "\n" ..
"|-\n" ..
"! Rare\n" .. countRare .. "\n" ..
"| " .. buildRareTable .. "\n" ..
"|-\n" ..
"! Uncommon\n" .. countUncommon .. "\n" ..
"| " .. buildUncommonTable .. "\n" ..
"|-\n" ..
"! Common\n" .. countCommon .. "\n" ..
"| " .. buildCommonTable .. "\n" ..
"|}"
 
    return buildTable
end

function p.buildModTableByPolarity()
 
    buildMaduraiTable = ""
    buildVazarinTable = ""
    buildNaramonTable = ""
    buildZenurikTable = ""
    buildPenjagaTable = "" --wtf is penjaga
    buildUnairuTable = ""
    
    countMadurai = 0
    countVazarin = 0
    countNaramon = 0
    countZenurik = 0
    countPenjaga = 0
    countUnairu = 0
 
--Madurai "V" "Madurai"
--Vazarin "D"
--Naramon "Bar"
--Zenurik "Ability" "Zenurik"
--Penjaga "Sentinel"
-- Unairu Pol Unairu  - R - Introduced in Update 13.0 and used for certain Melee Stance Mods. 
 
    for key, Mod in Shared.skpairs(ModData["Mods"]) do
--        mw.log(Mod.Polarity)
 
        if Mod.Polarity == "V" or Mod.Polarity == "Madurai" then
            buildMaduraiTable = buildMaduraiTable .. "[[File:" .. Mod.Image .. "|114px|link=" .. Mod.Name .."]]"
            countMadurai = countMadurai + 1
        elseif Mod.Polarity == "D" or Mod.Polarity == "Vazarin" then
            buildVazarinTable = buildVazarinTable .. "[[File:" .. Mod.Image .. "|114px|link=" .. Mod.Name .."]]"
            countVazarin = countVazarin + 1
        elseif Mod.Polarity == "Bar" or Mod.Polarity == "Dash" or Mod.Polarity == "Naramon" then
            buildNaramonTable = buildNaramonTable .. "[[File:" .. Mod.Image .. "|114px|link=" .. Mod.Name .."]]"
            countNaramon = countNaramon + 1
        elseif Mod.Polarity == "Ability" or Mod.Polarity == "Zenurik" or Mod.Polarity == "Scratch" then
            buildZenurikTable = buildZenurikTable .. "[[File:" .. Mod.Image .. "|114px|link=" .. Mod.Name .."]]"
            countZenurik = countZenurik + 1
        elseif Mod.Polarity == "Sentinel" or Mod.Polarity == "Penjaga" then
            buildPenjagaTable = buildPenjagaTable .. "[[File:" .. Mod.Image .. "|114px|link=" .. Mod.Name .."]]"
            countPenjaga = countPenjaga + 1
        elseif Mod.Polarity == "R" or Mod.Polarity == "Unairu" or Mod.Polarity == "Ward" then
            buildUnairuTable = buildUnairuTable .. "[[File:" .. Mod.Image .. "|114px|link=" .. Mod.Name .."]]"
            countUnairu = countUnairu + 1
        end
    end
 
    countTotal = countMadurai + countVazarin + countNaramon + countZenurik + countPenjaga + countUnairu
        buildTable = 
countTotal .. "\n" .. 
"{| border=\"1\" cellpadding=\"1\" cellspacing=\"1\" class=\"article-table\"\n" ..
"|-\n" ..
"!Madurai\n" .. countMadurai .. "\n" ..
"| " .. buildMaduraiTable .. "\n" ..
"|-\n" ..
"! Vazarin\n" .. countVazarin .. "\n" ..
"| " .. buildVazarinTable .. "\n" ..
"|-\n" ..
"! Naramon\n" .. countNaramon .. "\n" ..
"| " .. buildNaramonTable .. "\n" ..
"|-\n" ..
"! Zenurik\n" .. countZenurik .. "\n" ..
"| " .. buildZenurikTable .. "\n" ..
"|-\n" ..
"! Penjaga\n" .. countPenjaga .. "\n" ..
"| " .. buildPenjagaTable .. "\n" ..
"|-\n" ..
"!Unairu\n" .. countUnairu .. "\n" ..
"| " .. buildUnairuTable .. "\n" ..
"|}"
 
    return buildTable
end

function p.getPolarityList()
    local pols = {}
    
    for name, Mod in Shared.skpairs(ModData["Mods"]) do
        if(pols[Mod.Polarity] == nil) then 
            pols[Mod.Polarity] = 1 
        else 
            pols[Mod.Polarity] = pols[Mod.Polarity] + 1 
        end
    end
    
    local result = "POLARITIES:"
    for key, trash in Shared.skpairs(pols) do
        result = result.."\n"..key.." ("..trash..")"
    end
    return result
end

function p.getRarityList()
    local pols = {}
    
    for name, Mod in Shared.skpairs(ModData["Mods"]) do
        if(pols[Mod.Rarity] == nil) then 
            pols[Mod.Rarity] = 1 
        else 
            pols[Mod.Rarity] = pols[Mod.Rarity] + 1 
        end
    end
    
    local result = "RARITIES:"
    for key, trash in Shared.skpairs(pols) do
        result = result.."\n"..key.." ("..trash..")"
    end
    return result
end

return p
