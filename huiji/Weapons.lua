--This will eventually contain data for various weapons
--For use in automating assorted wiki functions and to reduce the number of updates needed
--But starting with Melee Stances

local p = {}

local WeaponData = mw.loadData( 'Module:Weapons/data' )
local ConclaveData = mw.loadData( 'Module:Weapons/Conclave/data' )
local Icon = require( "Module:Icon" )
local Shared = require( "Module:Shared" )
local Elements = {"Impact", "Puncture", "Slash", "Heat", "Cold", "Toxin", "Electricity", "Blast", "Corrosive", "Radiation", "Magnetic", "Gas", "Viral"}
local Physical = {"Impact", "Puncture", "Slash"}
local UseDefaultList = {"NOISELEVEL", "AMMOTYPE", "MAXAMMO", "DISPOSITION", "CHANNELMULT"}
local trans = require("Module:Translate")
local props = {} -- smw properties
local termBase = require("Module:Weapons/terms")
local originChecklist = require("Module:Weapons/originChecklist")

function transReleaseUpdate(text)
	if not text then
		return text
	end
	local result
    if string.match(text, '|Update ([0-9%.]+)%]%]') then
		result = string.gsub(text, '|Update ([0-9%.]+)%]%]', '|更新%1]]')
    elseif string.match(text, '|Hotfix ([0-9%.]+)%]%]') then
		result = string.gsub(text, '|Hotfix ([0-9%.]+)%]%]', '|热修%1]]')
    elseif string.match(text, '%[%[Update ([0-9%.]+)%]%]') then
		result = string.gsub(text, '%[%[Update ([0-9%.]+)%]%]', '[[更新%1]]')
    elseif string.match(text, '|Update: ([^0-9^%]]-)( ?[0-9]?)%]%]') then
		result = string.gsub(text, '|Update: ([^0-9^%]]-)( ?[0-9]?)%]%]', function (a, b) return '|更新：' .. trans.toChineseCI(a) .. b .. ']]' end)
    elseif string.match(text, '|Hotfix: ([^0-9^%]]-)( ?[0-9]?)%]%]') then
		result = string.gsub(text, '|Hotfix: ([^0-9^%]]-)( ?[0-9]?)%]%]', function (a, b) return '|热修：' .. trans.toChineseCI(a) .. b .. ']]' end)
    else
		result = text
	end
	return result
end

function transAccuracy(acc)
	if not acc then
		return acc
	end
	result = string.gsub(acc, '([0-9%.]+) when aimed', '瞄准时%1')
	result = string.gsub(result, '[Aa]imed', '瞄准时')
	return result
end

function transWeaponUser(text)
	if not text then
		return text
	end
	local result
	result = string.gsub(text, '%]%]s', ']]')
	result = string.gsub(result, '%]%]es', ']]')
	result = string.gsub(result, '%[%[([^|]-)%]%]', function (a) return '[[' .. a .. '|' .. trans.toChineseCI(a) .. ']]' end)
    result = string.gsub(result, '%[%[([^|]-)|([^|]-)%]%]', function (a, b) return '[[' .. a .. '|' .. trans.toChineseCI(b) .. ']]' end)
    result = string.gsub(result, ' [Ss]kin%)', ')')
    return result
end

function transStagger(text)
	if text == 'Yes' then
		return '是'
	else
		return text
    end	
end

function transZoom(text)
	if not text then
		return text
	end
	local result
	result = string.gsub(text, '[Cc]ritical [Dd]amage', '暴击伤害')
	result = string.gsub(result, '[Cc]ritical [Mm]ultiplier', '暴击倍率')
	result = string.gsub(result, '[Cc]ritical [Cc]hance', '暴击几率')
	result = string.gsub(result, '[Hh]eadshot [Dd]amage', '爆头伤害')
	result = string.gsub(result, '[Dd]amage', '伤害')
    result = string.gsub(result, '[Zz]oom', '变焦')
    return result
end

function transTerm(text)
	return termBase[text] or text
end

function originCheck(name)
	local result
	for k,v in pairs(originChecklist) do
		if v then
			if string.match(name, k) then
				result = true
				break
			end
		else
			if string.match(name, k) then
				result = false
			end
		end
	end
	if result == nil then
		result = true
	end
	return result
end

function p.doPlural(Text, Value)
    if(tonumber(Value) == 1) then
        Text = string.gsub(Text, "(<.+>)", "")
    else
        Text = string.gsub(Text, "<(.+)>", "%1")
    end
    return Text
end

local function checkWeapon(weap, weapName, conclave)
    if weap == nil or type(weap) ~= 'table' then
        if conclave then
            return p.getConclaveWeapon(weapName)
        else
            return p.getWeapon(weapName)
        end
    elseif type(weap) == 'table' then
        return weap
    end
end

function p.weaponExists(frame)
    local weapName = frame.args ~= nil and frame.args[1] or nil

    return p._weaponExists(weapName)
end

function p._weaponExists(weapName, weap)
    local weap = checkWeapon(weap, weapName)

    if weapName == 'Dark Split-Sword' then
        return true
    elseif weap then
        return true
    end

    if weapName == nil then
        return 'Enter weapon name.'
    elseif weap == nil then
        return 'No weapon '..weapName..' found.'
    end
end

function p.getLink(weapName, weap)
    local weap = checkWeapon(weap, weapName)
    local exists = p._weaponExists(weapName, weap)
    if weapName == "Dark Split-Sword" then
        return "Dark Split-Sword"
    elseif exists == true then
        local temp = weap.Link
        if weap.Type == "Arch-Gun (Atmosphere)" then
            local atmoTemp = Shared.splitString(weap.Name, "%s")
            local atmoCount = Shared.tableCount(atmoTemp)
            if atmoCount == 2 then
                return atmoTemp[1]
            elseif atmoCount >= 2 then
                return table.concat(atmoTemp, ' ', 1, (atmoCount-1))
            end
            return weap.Name
        elseif temp then
            return temp
        else
            return weap.Name
        end
    elseif weapName == nil then
        return false
    else
        return false
    end
end

function p.getWeapon(WeapName)
    for key, Weapon in Shared.skpairs(WeaponData["Weapons"]) do
        if(Weapon.Name == WeapName or key == WeapName) then
            return Weapon            
        end
    end
    return nil
end

function p.getConclaveWeapon(WeapName)
    local weapon = ConclaveData["Weapons"][WeapName]

    if weapon ~= nil and weapon.Name == WeapName then
        return weapon
    else
        for key, Weapon in Shared.skpairs(ConclaveData["Weapons"]) do
            if(Weapon.Name == WeapName or key == WeapName) then
                return Weapon            
            end
        end
    end

    return nil
end

function p.isMelee(frame)
    if(frame == nil) then
        return nil
    end
    local Weapon = frame.args ~= nil and frame.args[1] or frame
    if(type(Weapon) == "string") then
        Weapon = p.getWeapon(Weapon)
    end

    if(Weapon == nil) then
        return nil
    end

    if(Weapon.Type ~= nil and (Weapon.Type == "Melee" or Weapon.Type == "Arch-Melee")) then
        return "yes"
    end

    return nil
end

function p.isArchwing(frame)
    if(frame == nil) then
        return nil
    end
    local Weapon = frame.args ~= nil and frame.args[1] or frame
    if(type(Weapon) == "string") then
        Weapon = p.getWeapon(Weapon)
    end

    if(Weapon == nil) then
        return nil
    end

    if(Weapon.Type ~= nil and (Weapon.Type == "Arch-Gun" or Weapon.Type == "Arch-Melee")) then
        return "yes"
    end

    return nil
end

local function getAttack(Weapon, AttackType)
    if(Weapon == nil or AttackType == nil) then
        return nil
    elseif(type(Weapon) == "string") then
        Weapon = p.getWeapon(Weapon)
    end
    AttackType = string.upper(AttackType)
    if (AttackType == nil or AttackType == "NORMAL" or AttackType == "NORMALATTACK") then
        if(Weapon.NormalAttack ~= nil) then
            return Weapon.NormalAttack
        elseif(Weapon.Damage ~= nil) then 
            return Weapon 
        else 
            return nil
        end
    elseif(AttackType == "CHARGE" or AttackType == "CHARGEATTACK") then
        return Weapon.ChargeAttack
    elseif(AttackType == "AREA" or AttackType == "AREAATTACK") then
        return Weapon.AreaAttack
    elseif(AttackType == "SECONDARYAREA" or AttackType == "SECONDARYAREAATTACK") then
        return Weapon.SecondaryAreaAttack
    elseif(AttackType == "THROW" or AttackType == "THROWATTACK") then
        return Weapon.ThrowAttack
    elseif(AttackType == "CHARGEDTHROW" or AttackType == "CHARGEDTHROWATTACK") then
        return Weapon.ChargedThrowAttack
    elseif(AttackType == "SECONDARY" or AttackType == "SECONDARYATTACK") then
        return Weapon.SecondaryAttack
    else
        return nil
    end
end

local function hasAttack(Weapon, AttackType)
    if(getAttack(Weapon, AttackType) ~= nil) then 
        return true 
    else 
        return nil 
    end
end

function p.hasAttack(frame)
    local WeapName = frame.args[1]
    local AttackName = frame.args[2]

    if(WeapName == nil) then
        return "ERROR: No weapon name"
    elseif(AttackName == nil) then
        AttackName = "Normal"
    end

    local Weapon = p.getWeapon(WeapName)
    if(Weapon == nil) then return "ERROR: No weapon "..WeapName.." found" end

    return hasAttack(Weapon, AttackName)
end

function hasMultipleTypes(Attack)
    local typeCount = 0
    if(Attack ~= nil and Attack.Damage ~= nil) then
        for key, dmg in Shared.skpairs(Attack.Damage) do
            if(dmg > 0) then
                typeCount = typeCount + 1
            end
        end
    end
    if(typeCount > 1) then return "yes" else return nil end
end

function p.hasMultipleTypes(frame)
    local WeapName = frame.args[1]
    local AttackName = frame.args[2]
    if(AttackName == nil) then AttackName = "Normal" end
    local attack = getAttack(WeapName, AttackName)
    return hasMultipleTypes(attack)
end

function p.attackLoop(Weapon)
    if(Weapon == nil) then
        return function() return nil end
    end
    local aType = "Normal"
    local iterator = function()
            if(aType == "Normal") then
                local attack = getAttack(Weapon, aType)
                aType = "Charge"
                if attack ~= nil and attack.Damage ~= nil then return "Normal", attack end
            end
            if(aType == "Charge") then
                local attack = getAttack(Weapon, aType)
                aType = "Area"
                if attack ~= nil and attack.Damage ~= nil then return "Charge", attack end
            end
            if(aType == "Area") then
                local attack = getAttack(Weapon, aType)
                aType = "SecondaryArea"
                if attack ~= nil and attack.Damage ~= nil then return "Area", attack end
            end
            if(aType == "SecondaryArea") then
                local attack = getAttack(Weapon, aType)
                aType = "Secondary"
                if attack ~= nil and attack.Damage ~= nil then return "SecondaryArea", attack end
            end
            if(aType == "Secondary") then
                local attack = getAttack(Weapon, aType)
                aType = "Throw"
                if attack ~= nil and attack.Damage ~= nil then return "Secondary", attack end
            end
            if(aType == "Throw") then
                local attack = getAttack(Weapon, aType)
                aType = "ChargedThrow"
                if attack ~= nil and attack.Damage ~= nil then return "Throw", attack end
            end
            if(aType == "ChargedThrow") then
                local attack = getAttack(Weapon, aType)
                aType = "end"
                if attack ~= nil and attack.Damage ~= nil then return "ChargedThrow", attack end
            end

            return nil
        end
    return iterator
end

function p.getStance(StanceName)
    for i, Stance in pairs(WeaponData["Stances"]) do
        if(Stance.Name == StanceName) then
            return Stance
        end
    end
    return nil
end

local function getAugments(Weapon)
    local name = Weapon.Name ~= nil and Weapon.Name or Weapon
    local augments = {}
    for i, Augment in pairs(WeaponData["Augments"]) do
        for j, WeapName in pairs(Augment.Weapons) do
            if(WeapName == name) then
                table.insert(augments, Augment)
            end
        end
    end
    return augments
end

local function getFamily(FamilyName)
    local familyMembers = {}
    for i, Weapon in Shared.skpairs(WeaponData["Weapons"]) do
        if(Weapon.Family == FamilyName) then
            table.insert(familyMembers, Weapon)
        end
    end
    return familyMembers
end

local function linkMeleeClass(weapClass)
    if(weapClass == nil) then
        return nil
    else
    	weapClass = trans.toChineseCat(weapClass)
        return "[[:分类:"..weapClass.."|"..weapClass.."]]"
    end
end

--Returns all melee weapons.
--If weapType is not nil, only grab for a specific type
--For example, if weapType is "Nikana", only pull Nikanas
local function getMeleeWeapons(weapClass, PvP)
    local weaps = {}
    local weapClasses = {}
    if(weapClass ~= nil) then
        weapClasses = Shared.splitString(weapClass, ',')
    end

    for i, weap in Shared.skpairs(WeaponData["Weapons"]) do
        if(weap.Type ~= nil and weap.Type == "Melee" and weap.Name ~= 'Cadus') then
            local classMatch = (weapClass == nil or Shared.contains(weapClasses, weap.Class))
            local pvpMatch = (PvP == nil or (PvP and weap.Conclave ~= nil and weap.Conclave))
            if (classMatch and pvpMatch) then
                table.insert(weaps, weap)
            end
        end
    end

    return weaps
end

--Learning new things... Trying to allow sending in an arbitrary function
function p.getWeapons(validateFunction)
    local weaps = {}
    for i, weap in Shared.skpairs(WeaponData["Weapons"]) do
        if(validateFunction(weap)) then
            table.insert(weaps, weap)
        end
    end
    return weaps
end

local function asPercent(val, digits)
    if(digits == nil) then digits = 2 end
    if(val == nil) then val = 0 end
    local result = val * 100
    return Shared.round(result, digits).."%"
end

local function asMultiplier(val)
    if(val == nil) then
        return "1.0x"
    end
    return Shared.round(val, 2, 1).."x"
end

--Returns all melee weapons.
--If weapType is not nil, only grab for a specific type
--For example, if weapType is "Nikana", only pull Nikanas
local function getStances(weapType, pvpOnly, weapName)
    local stances = {}

    if weapType ~= "Exalted Weapon" then
        for i, stance in Shared.skpairs(WeaponData["Stances"]) do
            local classMatch = (weapType == nil or weapType == stance.Class)
            local pvpMatch = (pvpOnly ~= nil and pvpOnly) or (stance.PvP == nil or not stance.PvP)
            if (classMatch and pvpMatch) then
                table.insert(stances, stance)
            end
        end
    else
        for i, stance in Shared.skpairs(WeaponData["Stances"]) do
            local nameMatch = (weapName == nil or weapName == stance.Weapon)
            if nameMatch then
                table.insert(stances, stance)
            end
        end
    end
    return stances
end

local function HasTrait(Weapon, Trait)
    if(Trait == nil or Weapon.Traits == nil) then
        return false
    end

    for i, theTrait in pairs(Weapon.Traits) do
        if(theTrait == Trait) then
            return true
        end
    end

    return false
end

--If Type is not nil, get damage weapon deals of that type
--If it deals no damage of that type, return 0 instead of nil
--It Type is nil, return total damage
local function GetDamage(Attack, Type, ByPellet)
    if(ByPellet == nil) then ByPellet = false end
    if(Attack == nil or Attack.Damage == nil) then return 0 end

    local pCount = 1
    if(ByPellet and Attack.PelletCount ~= nil) then pCount = Attack.PelletCount end
    if(Type == nil) then
        local total = 0
            for i, d in Shared.skpairs(Attack.Damage) do
                total = total + d
            end
        return total / pCount
    else
        if(Type == "Physical") then
            local Impact = Attack.Damage["Impact"] ~= nil and Attack.Damage["Impact"] or 0
            local Puncture = Attack.Damage["Puncture"] ~= nil and Attack.Damage["Puncture"] or 0
            local Slash = Attack.Damage["Slash"] ~= nil and Attack.Damage["Slash"] or 0
            return (Impact + Puncture + Slash) / pCount
        elseif(Type == "Element") then
            for dType, dmg in Shared.skpairs(Attack.Damage) do
                if(not Shared.contains(Physical, dType) or dmg <= 0) then
                    return dmg / pCount
                end
            end
            return 0
        elseif(Attack.Damage[Type] == nil) then
            return 0
        else
            return Attack.Damage[Type] / pCount
        end
    end
end

--Returns the damage string as it's formatted in a comparison row
--So instead of '0', returns '-', and appends the icon for an element if necessary
local function GetDamageString(Attack, Type, ByPellet)
    if(ByPellet == nil) then ByPellet = false end
    local pCount = 1
    if(ByPellet and Attack.PelletCount ~= nil) then pCount = Attack.PelletCount end
    if(Type == nil) then
        if(not hasMultipleTypes(Attack)) then
            for key, val in pairs(Attack.Damage) do
                if(val > 0) then
                    return Icon._Proc(key).." "..Shared.round(val / pCount, 2)
                end
            end
            return ""
        else
            return Shared.round(GetDamage(Attack, nil, ByPellet), {2, 1})
        end
    else
        local thisVal = GetDamage(Attack, Type, ByPellet)
        if(thisVal == 0) then
            return ""
        else
            return Shared.round(thisVal, {2, 1})
        end
    end
end

local function GetDamageBias(Attack)
    if(Attack.Damage ~= nil and Shared.tableCount(Attack.Damage) > 1) then
        local total = 0
        local bestDmg = 0
        local bestElement = nil
        local count = 0
        for Element, Dmg in pairs(Attack.Damage) do
            if(Dmg > bestDmg) then
                bestDmg = Dmg
                bestElement = Element
            end
            total = total + Dmg
            if(Dmg > 0) then
                count = count + 1
            end
        end
        --Make sure there are two damage instances that are above zero
        if(count > 1) then
            return (bestDmg / total), bestElement
        else
            return nil
        end
    else
        return nil
    end
end

--If the attack has at least two damage types,
--  Returns something like "58.3% Slash"
--If it doesn't, returns nil
local function GetDamageBiasString(Attack, hideType)
    local bestPercent, bestElement = GetDamageBias(Attack, hideType)
    if(bestPercent ~= nil) then
        local result = asPercent(bestPercent, 0)
        if(hideType == nil or not hideType) then
            result = result.." "..Icon._Proc(bestElement, "text")
        end
        return result
    else
        return nil
    end
end

local function GetPolarityString(Weapon)
    if(Weapon.Polarities == nil or type(Weapon.Polarities) ~= "table" or Shared.tableCount(Weapon.Polarities) == 0) then
        return "无"
    else
        local resString = ""
        for i, pol in pairs(Weapon.Polarities) do
            local tempPol = Icon._Pol(pol)
            if tempPol == "<span style=\"color:red;\">Invalid</span>" and Weapon.Name == "Exalted Blade" then
                resString = resString..transTerm(pol)
            else
                resString = resString..tempPol
            end
        end
        return resString
    end
end

function p.GetPolarityString(Weapon)
    return GetPolarityString(Weapon)
end

local function GetStancePolarity(Weapon)
    if(Weapon.StancePolarity == nil or Weapon.StancePolarity == "None") then
        return "无"
    else
        return Icon._Pol(Weapon.StancePolarity)
    end
end

local function getWeaponStanceList(Weapon)
    if(Weapon == nil or Weapon.Type ~= "Melee") then return nil end

    local stances = getStances(Weapon.Class, Weapon.Conclave, Weapon.Name)

    local result = ""

    for i, stance in pairs(stances) do
        if (string.len(result) > 0) then
            result = result.."<br/>"
        end

        local polarity = ''
        local link = ''
        if Weapon.Class ~= "Exalted Weapon" then
            polarity = " ("..Icon._Pol(stance.Polarity)..")"
            link = "[["..stance.Name..'|'..trans.toChineseCI(stance.Name).."]]"
        else
            link = "[["..stance.Link..'|'..trans.toChineseCI(stance.Name).."]]"
        end

        result = result.."<span class=\"mod-tooltip\" data-param=\""..stance.Name.."\" style=\"white-space:pre\">"..link.."</span>"..polarity
        --If this is a PvP Stance, add the disclaimer
        if(stance.PvP ~= nil and stance.PvP) then
            result = result.." (仅限PvP)"
        end
    end

    return result
end

local function getAttackValue(Weapon, Attack, ValName, giveDefault, asString)
    if(giveDefault == nil) then giveDefault = false end
    if(asString == nil) then asString = false end
    if(Attack == nil) then 
        if(asString) then
            return ""
        else
            return nil 
        end
    end
    regularVal = Shared.titleCase(string.sub(ValName, 1, 1), string.sub(ValName, 2))
    ValName = string.upper(ValName)
    if(ValName == "DAMAGE") then
        if(Attack.Damage ~= nil) then
            if(asString) then
                return GetDamageString(Attack, nil)
            else
                return GetDamage(Attack)
            end
        elseif giveDefault then
            return 0
        else
            return nil
        end
    elseif(ValName == "DAMAGEPLUS") then
        if(Attack.Damage ~= nil) then
            if(asString) then
                if(hasMultipleTypes(Attack)) then
                    return GetDamageString(Attack, nil).."（"..GetDamageBiasString(Attack, nil, "").."）"
                else
                    return GetDamageString(Attack, nil)
                end
            else
                return GetDamage(Attack)
            end
        elseif giveDefault then
            return 0
        else
            return nil
        end
    elseif(Shared.contains(Elements, regularVal) or ValName == "PHYSICAL" or ValName == "ELEMENT") then
        if(Attack.Damage ~= nil) then
            if(asString) then
            	return GetDamageString(Attack,  regularVal)
            else
                return GetDamage(Attack,  regularVal)
            end
        elseif giveDefault then
            return 0
        else
            return nil
        end
    elseif(ValName == "ATTACKNAME") then
        if(Attack.AttackName ~= nil) then
            return transTerm(Attack.AttackName)
        elseif(giveDefault) then
            return ""
        else
            return nil
        end
    elseif(ValName == "AMMOCOST") then
        if(Attack.AmmoCost ~= nil) then
            if(asString) then
                return "单次射击"..Attack.AmmoCost.."发弹药"
            else
                return Attack.AmmoCost
            end
        elseif(giveDefault) then
            return 1
        else
            return nil
        end
    elseif(ValName == "BURSTCOUNT") then
        if(Attack.BurstCount ~= nil) then
            if(asString) then
                local result = Attack.BurstCount.."发"
                local dmg = GetDamage(Attack) * Attack.BurstCount
                return result.."（总伤害"..Shared.round(dmg, 2, 1).."）"
            else
                return Attack.BurstCount
            end
        elseif giveDefault then
            return 0
        else
            return nil
        end
    elseif(ValName == "BURSTFIRERATE") then
        if(Attack.BurstFireRate ~= nil) then
            return Attack.BurstFireRate
        elseif giveDefault then
            return 0
        else
            return nil
        end
    elseif(ValName == "CHARGETIME") then
        if(Attack.ChargeTime ~= nil) then
            if(asString) then
                return Shared.round(Attack.ChargeTime, 2, 1).."秒"
            else
                return Attack.ChargeTime
            end
        elseif giveDefault then
            return 0
        else
            return nil
        end
    elseif(ValName == "CRITCHANCE") then
        if(Attack.CritChance ~= nil) then
            if(asString) then
                return asPercent(Attack.CritChance)
            else
                return Attack.CritChance
            end
        end
        if(hasAttack(Weapon, "Normal")) then
            local normAtt = getAttack(Weapon, "Normal")
            if(normAtt.CritChance ~= nil) then
                if(asString) then
                    return asPercent(normAtt.CritChance)
                else
                    return normAtt.CritChance
                end
            end
        end
        if giveDefault then
            if(asString) then
                return asPercent(0)
            else
                return 0
            end
        else
            return nil
        end
    elseif(ValName == "CRITMULTIPLIER") then
        if(Attack.CritMultiplier ~= nil) then
            if(asString) then
                return asMultiplier(Attack.CritMultiplier)
            else
                return Attack.CritMultiplier
            end
        end
        if(hasAttack(Weapon, "Normal")) then
            local normAtt = getAttack(Weapon, "Normal")
            if(normAtt.CritMultiplier ~= nil) then
                if(asString) then
                    return asMultiplier(normAtt.CritMultiplier)
                else
                    return normAtt.CritMultiplier
                end
            end
        end
        if giveDefault then
            if(asString) then
                return asMultiplier(0)
            else
                return 0
            end
        else
            return nil
        end
    elseif(ValName == "DAMAGEBIAS") then
        if(hasMultipleTypes(Attack) and Shared.tableCount(Attack.Damage) <= 4) then
            if(asString) then
                --return "[[File:Balance.png|x18px]] "..GetDamageBiasString(Attack, nil, "")
                return GetDamageBiasString(Attack)
            else
                return GetDamageBiasString(Attack)
            end
        else
            if(asString) then
                return ""
            else
                return nil
            end
        end
    elseif(ValName == "BULLETTYPE") then
        if(Attack.ShotType ~= nil) then
            return Attack.ShotType
        elseif(giveDefault) then
            return "未知"
        else
            return nil
        end
    elseif(ValName == "DURATION") then
        if(Attack.Duration ~= nil) then
            if(asString) then
                return Shared.round(Attack.Duration, 1, 0).."秒"
            else
                return Attack.Duration
            end
        elseif giveDefault then
            return 0
        else
            return nil
        end
    elseif(ValName == "ELEMENTTYPE") then
        if(Attack.Damage ~= nil) then
            for dType, dmg in Shared.skpairs(Attack.Damage) do
				if not (Shared.contains(Physical, dType) or dmg <= 0) then
                    if(asString) then
                        return Icon._Proc(dType)
                    else
                        return dType
                    end
                end
            end
            return ''
        elseif asString then
            return ""
        else
            return nil
        end
    elseif(ValName =="ELEMENTTYPENAME") then
        if(Attack.Damage ~= nil) then
            for dType, dmg in Shared.skpairs(Attack.Damage) do
                if(not Shared.contains(Physical, dType) or dmg <= 0) then
                    return dType
                end
            end
        elseif asString then
            return ""
        else
            return nil
        end
    elseif(ValName == "FALLOFF") then
        if(Attack.Falloff ~= nil) then
            local falloffText = Shared.round(Attack.Falloff.StartRange, 2, 1).."米内最大伤害"
            falloffText = falloffText.."<br/>"..Shared.round(Attack.Falloff.EndRange, 2, 1).."米外最小伤害"
            if(Attack.Falloff.Reduction ~= nil) then
                falloffText = falloffText.."<br/>最大衰减率为"..asPercent(Attack.Falloff.Reduction)
            end
            return falloffText
        else
            return nil
        end
    elseif(ValName == "FIRERATE") then
        local returnVal = 0
        if(Attack.FireRate ~= nil) then
            returnVal = Attack.FireRate
        elseif giveDefault then
            if(Weapon.FireRate ~= nil) then
                returnVal = Weapon.FireRate
            else
                returnVal = 0
            end
        else
            return nil
        end
        if(asString) then
            if(Weapon.Type ~= nil and Weapon.Type ~= "Melee" and Weapon.Type ~= "Arch-Melee") then
                if(forTable) then
                    return Shared.round(returnVal, {3, 1}) -- .." rps"
                else
                    return Shared.round(returnVal, {3, 1}).."发/秒"
                end
            else
                return Shared.round(returnVal, {3, 1})
            end
        else
            return returnVal
        end
    elseif(ValName == "HEADSHOTMULTIPLIER") then 
        --search in current attack, then normal, and finally fall back on base weapon value if for some reason that exists
        if(Attack.HeadshotMultiplier ~= nil) then
            if(asString) then
                return asMultiplier(Attack.HeadshotMultiplier)
            else
                return Attack.HeadshotMultiplier
            end
        end
        if(hasAttack(Weapon, "Normal")) then
            local normAtt = getAttack(Weapon, "Normal")
            if(normAtt.HeadshotMultiplier ~= nil) then
                if(asString) then
                    return asMultiplier(normAtt.HeadshotMultiplier)
                else
                    return normAtt.HeadshotMultiplier
                end
            end
        end
        if(Weapon.HeadshotMultiplier ~= nil) then
            if(asString) then
                return asMultiplier(Weapon.HeadshotMultiplier)
            else
                return Weapon.HeadshotMultiplier
            end
        end
        if giveDefault then
            if(Weapon.Type ~= nil) then
                --Setting multiplier based on default for each weapon type
                if(Weapon.Type == "Secondary") then
                    if(Weapon.Class == "Shotgun Sidearm") then
                        return '1.2x'
                    elseif(Weapon.Class == "Crossbow" or Weapon.Class == "Thrown") then
                        return '1.5x'
                    else
                        if(Weapon.Trigger == 'Auto') then
                            return '1.2x'
                        else
                            return '1.5x'
                        end
                    end
                elseif(Weapon.Type == "Primary") then
                    if(Weapon.Class == "Shotgun") then
                        return "1.2x"
                    elseif(Weapon.Class == "Bow") then
                        return "2.0x"
                    elseif(Weapon.Class == "Sniper Rifle") then
                        return "1.4x"
                    elseif(Weapon.Class == "Launcher") then
                        return "1.0x"
                    else
                        if(Weapon.Trigger == "Auto") then
                            return '1.2x'
                        else
                            return '1.5x'
                        end
                    end
                end
            end
        else
            return nil
        end
    elseif(ValName == "NOISELEVEL") then
        if(Attack.NoiseLevel ~= nil) then
            return Attack.NoiseLevel
        else
            return nil
        end
    elseif(ValName == "PELLETCOUNT") then
        if(Attack.PelletCount ~= nil) then
            if(asString) then
                if(Attack.PelletName ~= nil) then
                    return Attack.PelletCount.."个"..transTerm(Attack.PelletName)
                else
                    return Attack.PelletCount.."个弹片"
                end
            else
                return Attack.PelletCount
            end
        elseif giveDefault then
            return 0
        else
            return nil
        end
    elseif(ValName == "PELLETDAMAGE") then
        if(Attack.PelletCount ~= nil) then
            local result = GetDamageString(Attack, nil, true)
            if(Attack.PelletName ~= nil) then
                return "每个"..transTerm(Attack.PelletName)..result.."伤害"
            else
                return "每个弹片"..result.."伤害"
            end
        else
            return nil
        end
    elseif(ValName == "PELLETNAME") then
        if(Attack.PelletCount ~= nil) then
            if(Attack.PelletName ~= nil) then
                return transTerm(Attack.PelletName)
            else
                return "弹片"
            end
        else
            return nil
        end
    elseif(ValName == "PELLETPLUS") then
        if(Attack.PelletCount ~= nil) then
            local result = Attack.PelletCount.."（"
            if(Attack.PelletName ~= nil) then
                result = result.."每个"..transTerm(Attack.PelletName)
            else
                result = result.."每个弹片"
            end
	    return result..Shared.round(GetDamage(Attack, nil, true), 2, 1).."伤害）"
        else
            return nil
        end
    elseif(ValName == "PROJECTILESPEED") then
        if(Attack.ShotSpeed ~= nil) then
            if(asString) then
                return Attack.ShotSpeed.."米/秒"
            else
                return Attack.ShotSpeed
            end
        elseif(giveDefault) then
            if(asString) then
                return "0米/秒"
            else
                return 0
            end
        else
            return nil
        end
    elseif(ValName == "PUNCHTHROUGH") then
        if(Attack.PunchThrough ~= nil) then
            if(asString) then
                return Shared.round(Attack.PunchThrough, 2, 1).."米"
            else
                return Attack.PunchThrough
            end
        elseif giveDefault then
            if(asString) then
                return "0米"
            else
                return 0
            end
        else
            return nil
        end
    elseif(ValName == "RADIUS") then
        if(Attack.Radius ~= nil) then
            if(asString) then
                return Shared.round(Attack.Radius, 2, 1).."米"
            else
                return Attack.Radius
            end
        elseif giveDefault then
            if(asString) then
                return "0米"
            else
                return 0
            end
        else
            return nil
        end
    elseif(ValName == "RANGE") then
        if(Attack.Range ~= nil) then
            if(asString) then
                return Attack.Range.."米"
            else
                return Attack.Range
            end
        elseif(giveDefault) then
            if(asString) then
                return "0米"
            else
                return 0
            end
        else
            return nil
        end
    elseif(ValName == "RELOAD") then
        --man screw you too Fusilai
        if(Attack.Reload ~= nil) then
            if(asString) then
                return Shared.round(Attack.Reload, 2, 1).."秒"
            else
                return Attack.Reload
            end
        elseif giveDefault then
            return 0
        else
            return nil
        end
    elseif(ValName == "SPOOL") then
        if(Attack.Spool ~= nil) then
            if(asString) then
                return Attack.Spool.."发"
            else
                return Attack.Spool
            end
        else
            return nil
        end
    elseif(ValName == "STANCES") then
        return getWeaponStanceList(Weapon)    
    elseif(ValName == "STATUSCHANCE") then
        if(Attack.StatusChance ~= nil) then
            if(asString) then
                local result = asPercent(Attack.StatusChance)
                return result
            else
                return Attack.StatusChance
            end
        end
        if(hasAttack(Weapon, "Normal")) then
            local normAtt = getAttack(Weapon, "Normal")
            if(normAtt.StatusChance ~= nil) then
                if(asString) then
                    return asPercent(normAtt.StatusChance)
                else
                    return normAtt.StatusChance
                end
            end
        end
        if giveDefault then
            return 0
        else
            return nil
        end
    elseif(ValName == "TRIGGER") then
        if(Attack.Trigger ~= nil) then
        	if(asString) then
        		return transTerm(Attack.Trigger)
    		else
    			return Attack.Trigger
    		end	
		end
        if(Weapon.Trigger ~= nil) then
            if(asString) then
        		return transTerm(Weapon.Trigger)
    		else
    			return Weapon.Trigger
    		end	
        end
        if giveDefault then
            return 0
        else
            return nil
        end
    else
        return "ERROR: No such value "..ValName
    end
end

local function getValue(Weapon, ValName, giveDefault, asString)
    if(giveDefault == nil) then giveDefault = false end
    if(asString == nil) then asString = false end

    if(type(ValName) == "table") then
        local VName1 = string.upper(ValName[1])
        local VName2 = string.upper(ValName[2])
        if(VName1 == nil or VName2 == nil) then
            return nil
        end

        if(VName1 == "ATTACK" or VName1 == "NORMALATTACK" or VName1 == "NORMAL") then
            return getAttackValue(Weapon, getAttack(Weapon, "Normal"), VName2, giveDefault, asString)
        elseif(VName1 == "AREA" or VName1 == "AREAATTACK") then
            return getAttackValue(Weapon, getAttack(Weapon, "Area"), VName2, giveDefault, asString)
        elseif(VName1 == "SECONDARYAREA" or VName1 == "SECONDARYAREAATTACK") then
            return getAttackValue(Weapon, getAttack(Weapon, "SecondaryArea"), VName2, giveDefault, asString)
        elseif(VName1 == "CHARGE" or VName1 == "CHARGEATTACK") then
            return getAttackValue(Weapon, getAttack(Weapon, "Charge"), VName2, giveDefault, asString)
        elseif(VName1 == "CHARGEDTHROW" or VName1 == "CHARGEDTHROWATTACK") then
            return getAttackValue(Weapon, getAttack(Weapon, "ChargedThrow"), VName2, giveDefault, asString)
        elseif(VName1 == "THROW" or VName1 == "THROWATTACK") then
            return getAttackValue(Weapon, getAttack(Weapon, "Throw"), VName2, giveDefault, asString)
        elseif(VName1 == "SECONDARY" or VName1 == "SECONDARYATTACK") then
            return getAttackValue(Weapon, getAttack(Weapon, "Secondary"), VName2, giveDefault, asString)
        else
            return "错误: 无此攻击类型 '"..VName1.."'"
        end
    end

    ValName = string.upper(ValName)
    if(ValName == "NAME") then
        if(Weapon.Name ~= nil) then
            if(forTable) then 
                if (string.find(Weapon.Name,"Atmosphere")~=nil) then
                    return "[["..string.gsub(Weapon.Name,"%s%(Atmosphere%)","").."|"..string.gsub(Weapon.Name,"osphere","").."]]"
                else
                    return "[["..Weapon.Name..'|'..trans.toChineseCI(Weapon.Name).."]]"
                end
            else
                return Weapon.Name
            end
        elseif giveDefault then
            return ""
        else
            return nil
        end
    elseif(ValName == "ACCURACY") then
        if(Weapon.Accuracy ~= nil) then
            return transAccuracy(Weapon.Accuracy)
        elseif giveDefault then
            return 0
        else
            return nil
        end
    elseif(ValName == "AMMOTYPE") then
        if(Weapon.AmmoType ~= nil) then
            return trans.toChineseCat(Weapon.AmmoType)
        elseif giveDefault then
            if(Weapon.Type ~= nil) then
                if(Weapon.Type == "Secondary") then
                    return "手枪"
                elseif(Weapon.Type == "Primary") then
                    if(Weapon.Class == nil or Weapon.Class == "Rifle") then
                        return "步枪"
                    elseif(Weapon.Class == "Shotgun") then
                        return "霰弹枪"
                    elseif(Weapon.Class == "Bow") then
                        return "弓"
                    elseif(Weapon.Class == "Sniper" or Weapon.Class == "Launcher") then
                        return "狙击枪"
                    end
                end
            end
        else
            return nil
        end
    elseif(ValName == "AUGMENT") then
        local augments = getAugments(Weapon)
        if(Shared.tableCount(augments) > 0) then
            local AugString = ""
            for i, Aug in pairs(augments) do
                if(i>1) then AugString = AugString.."<br/>" end
                AugString = AugString.."[["..Aug.Name..'|'..trans.toChineseCI(Aug.Name).."]]"
            end
            return AugString
        else
            return nil
        end
    elseif(ValName == "BLOCKRESIST") then
        if(Weapon.Class ~= nil) then
            if(Weapon.Type == "Melee") then
                if(Weapon.BlockResist ~= nil) then
                    if(asString) then
                        return asPercent(Weapon.BlockResist)
                    else
                        return Weapon.BlockResist
                    end
                elseif(Weapon.Class == "Claws" or Weapon.Class == "Dagger" or Weapon.Class == "Dual Daggers" or Weapon.Class == "Glaive" or Weapon.Class == "Nunchaku" or Weapon.Class == "Rapier" or Weapon.Class == "Sparring" or Weapon.Class == "Tonfa" or Weapon.Class == "Whip") then
                    if(asString) then
                        return "35%"
                    else
                        return .35
                    end
                elseif(Weapon.Class == "Blade and Whip" or Weapon.Class == "Dual Swords" or Weapon.Class == "Fist" or Weapon.Class == "Gunblade" or Weapon.Class == "Staff" or Weapon.Class == "Sword") then
                    if(asString) then
                        return "60%"
                    else
                        return .6
                    end
                elseif(Weapon.Class == "Hammer" or Weapon.Class == "Heavy Blade" or Weapon.Class == "Machete" or Weapon.Class == "Nikana" or Weapon.Class == "Polearm" or Weapon.Class == "Scythe" or Weapon.Class == "Sword and Shield") then
                    if(asString) then
                        return "85%"
                    else
                        return .85
                    end
                end

            else
                return ""
            end
        else
            return ""
        end
    elseif(ValName == "CHANNELMULT") then
        if(Weapon.ChannelMult ~= nil) then
            if(asString) then
                return asMultiplier(Weapon.ChannelMult)
            else
                return Weapon.ChannelMult
            end
        elseif giveDefault and (Weapon.Type ~= nil and Weapon.Type == "Melee") then
            if(asString) then
                return "1.5x"
            else
                return 1.5
            end
        else
            return nil
        end
    elseif(ValName == "CLASS") then
        if(Weapon.Class ~= nil) then
            if(asString and Weapon.Type == "Melee") then
                return "[[:分类:"..trans.toChineseCat(Weapon.Class).."|"..trans.toChineseCat(Weapon.Class).."]]"
            elseif asString then
            	return trans.toChineseCat(Weapon.Class)
            else
                return Weapon.Class
            end
        elseif giveDefault then
            return ""
        else
            return nil
        end
    elseif(ValName == "CONCLAVE") then
        if(Weapon.Conclave ~= nil) then
            if(asString) then
                if(Weapon.Conclave) then return "是" else return "否" end
            else
                return Weapon.Conclave
            end
        elseif giveDefault then
            return false
        else
            return nil
        end
    elseif(ValName == "DISPOSITION") then
        if(Weapon.Type ~= nil and (Weapon.Type == "Arch-Gun" or Weapon.Type == "Arch-Melee")) then return nil end

        if(Weapon.Disposition ~= nil) then
            if(asString) then
                if (Weapon.Disposition < 0.7) then return Icon._Dis(1)..' （'..Weapon.Disposition..'）'
                elseif(Weapon.Disposition < 0.9) then return Icon._Dis(2)..' （'..Weapon.Disposition..'）'
                elseif(Weapon.Disposition <= 1.1) then return Icon._Dis(3)..' （'..Weapon.Disposition..'）'
                elseif(Weapon.Disposition <= 1.3) then return Icon._Dis(4)..' （'..Weapon.Disposition..'）'
                else                     return Icon._Dis(5)..' （'..Weapon.Disposition..'）' end
            else
                return Weapon.Disposition
            end
        elseif giveDefault then
            if(asString) then
                return "未知"
            else
                return 0
            end
        else
            return nil
        end
    elseif(ValName == "DISPOSITION5") then
        if(Weapon.Type ~= nil and (Weapon.Type == "Arch-Gun" or Weapon.Type == "Arch-Melee") or Weapon.Type == "Emplacement") then return nil end

        if(Weapon.Disposition ~= nil) then
            if (Weapon.Disposition < 0.7) then return 1
            elseif(Weapon.Disposition < 0.9) then return 2
            elseif(Weapon.Disposition <= 1.1) then return 3
            elseif(Weapon.Disposition <= 1.3) then return 4
            else                     return 5 end
        elseif giveDefault then
            if(asString) then
                return "Unknown"
            else
                return 0
            end
        else
            return nil
        end
    elseif(ValName == "FAMILY") then
        if(Weapon.Family ~= nil) then
            if(asString) then
                if(Weapon.Family ~= nil) then
                    local FamilyString = ""
                    local Family = getFamily(Weapon.Family)
                    for i, Weap in pairs(Family) do
                        if(Weap.Name ~= Weapon.Name) then
                            if(string.len(FamilyString) > 0) then FamilyString = FamilyString.."<br/>" end
                            FamilyString = FamilyString.."[["..Weap.Name..'|'..trans.toChineseCI(Weap.Name).."]]"
                        end
                    end
                    return FamilyString
                end
            else
                return Weapon.Family
            end
        elseif giveDefault then
            return ""
        else
            return nil
        end
    elseif(ValName == "FINISHERDAMAGE") then
        if(Weapon.FinisherDamage ~= nil) then
            if(asString) then
                return Shared.round(Weapon.FinisherDamage, 2, 1)
            else
                return Weapon.FinisherDamage
            end
        elseif giveDefault then
            return 0
        else
            return nil
        end
    elseif(ValName == "IMAGE") then
        if(Weapon.Image ~= nil) then
            return Weapon.Image
        elseif giveDefault then
            return "Panel.png"
        else
            return nil
        end
    elseif(ValName == "INTRODUCED") then
        if(Weapon.Introduced ~= nil) then
            return transReleaseUpdate(Weapon.Introduced)
        elseif giveDefault then
            return ""
        else
            return nil
        end
    elseif(ValName == "JUMPATTACK") then
        if(Weapon.JumpAttack ~= nil) then
            if(asString) then
                if(Weapon.JumpElement ~= nil) then
                    return Icon._Proc(Weapon.JumpElement).." "..Shared.round(Weapon.JumpAttack, 2, 1)
                else
                    return Shared.round(Weapon.JumpAttack, 2, 1)
                end
            else
                return Weapon.JumpAttack
            end
        elseif giveDefault then
            return 0
        else
            return nil
        end
    elseif(ValName == "JUMPELEMENT") then
        if(Weapon.JumpElement ~= nil) then
            return Weapon.JumpElement
        elseif giveDefault then
            return ""
        else
            return nil
        end
    elseif(ValName == "JUMPRADIUS") then
        if(Weapon.JumpRadius ~= nil) then
            if(asString) then
                return Shared.round(Weapon.JumpRadius, 2, 1).."米"
            else
                return Weapon.JumpRadius
            end
        elseif giveDefault then
            return 0
        else
            return nil
        end
    elseif(ValName == "MAGAZINE") then
        if(Weapon.Magazine ~= nil) then
            if(asString) then
            return Weapon.Magazine..p.doPlural("发/弹匣", Weapon.Magazine)
            else
                return Weapon.Magazine
            end
        elseif giveDefault then
            if(asString) then
                return "0发/弹匣"
            else
                return 0
            end
        else
            return nil
        end
    elseif(ValName == "MASTERY") then
        if(Weapon.Mastery ~= nil) then
            return Weapon.Mastery
        elseif giveDefault then
            return 0
        else
            return nil
        end
    elseif(ValName == "MAXAMMO") then
        local returnVal = 0
        if(Weapon.MaxAmmo ~= nil) then
            returnVal = Weapon.MaxAmmo
        elseif giveDefault then
            if(Weapon.Type ~= nil) then
                if(Weapon.Type == "Secondary") then
                    returnVal = 210
                elseif(Weapon.Type == "Primary") then
                    if(Weapon.Class == nil or Weapon.Class == "Rifle") then
                        returnVal = 540
                    elseif(Weapon.Class == "Shotgun") then
                        returnVal = 120
                    elseif(Weapon.Class == "Bow" or Weapon.Class == "Sniper") then
                        returnVal = 72
                    end
                end
            end
        else
            return nil
        end
        if(asString) then
            if(returnVal > 0) then
                return returnVal.."发"
            else
                return nil
            end
        else
            if(returnVal > 0) then
                return returnVal
            else
                return nil
            end
        end
    elseif(ValName == "NOISELEVEL") then
        if(Weapon.NoiseLevel ~= nil) then
            return transTerm(Weapon.NoiseLevel)
        elseif giveDefault then
            if(Weapon.Type ~= nil and Weapon.Type ~= "Melee" and Weapon.Type ~= "Arch-Melee") then
                if(Weapon.Class ~= nil and (Weapon.Class == "Bow" or Weapon.Class == "Thrown")) then
                    return "无声"
                else
                    return "引起警戒"
                end
            else
                return nil
            end
        else
            return nil
        end
    elseif(ValName == "POLARITIES") then
        if(Weapon.Polarities ~= nil) then
            if(asString) then
                return GetPolarityString(Weapon)
            else
                return Weapon.Polarities
            end
        elseif giveDefault then
            if(asString) then
                return "无"
            else
                return {}
            end
        else
            return nil
        end
    elseif(ValName == "RELOAD") then
		if(Weapon.Reload ~= nil) then
            if(asString) then
                if(Weapon.ReloadStyle ~= nil) then
                    if(Weapon.ReloadStyle == "ByRound" and Weapon.Magazine ~= nil) then
                        local result = Shared.round(Weapon.Reload / Weapon.Magazine, 2, 1).."秒/发"
                        result = result.."（总时间"..Shared.round(Weapon.Reload, 2, 1).."秒）"
                        if(forTable) then result = Shared.round(Weapon.Reload, 2, 1).."秒" end
                        return result
                    elseif(Weapon.ReloadStyle == "Regenerate") then
                        local result = Shared.round(Weapon.Reload, 2, 1).."发/秒"
                        if(Weapon.Magazine ~= nil) then
                            result=result.."（总时间"..Shared.round(Weapon.Magazine / Weapon.Reload, 2, 1).."秒）" 
                            if(forTable) then result=Shared.round(Weapon.Magazine / Weapon.Reload, 2, 1).."秒" end
                        end
                        return result
                    end
                end
                return Shared.round(Weapon.Reload, 2, 1).."秒"
            else
                return Weapon.Reload
            end
        elseif giveDefault then
            return 0
        else
            return nil
        end
    elseif(ValName == "SLIDEATTACK") then
        if(Weapon.SlideAttack ~= nil) then
            if(asString) then
                if(Weapon.SlideElement ~= nil) then
                    return Icon._Proc(Weapon.SlideElement).." "..Shared.round(Weapon.SlideAttack, 2, 1)
                else
                    return Shared.round(Weapon.SlideAttack, 2, 1)
                end
            else
                return Weapon.SlideAttack
            end
        elseif giveDefault then
            return 0
        else
            return nil
        end
    elseif(ValName == "SLIDEELEMENT") then
        if(Weapon.SlideElement ~= nil) then
            return Weapon.SlideElement
        elseif giveDefault then
            return ""
        else
            return nil
        end
    elseif(ValName == "SNIPERCOMBORESET") then
        if(Weapon.SniperComboReset ~= nil) then
            if(asString) then
                return Shared.round(Weapon.SniperComboReset, 2, 1).."秒"
            else
                return Weapon.SniperComboReset
            end
        elseif giveDefault then
            return 0
        else
            return nil
        end
    elseif(ValName == "SNIPERCOMBOMIN") then
        if(Weapon.SniperComboMin ~= nil) then
            if(asString) then
                return Weapon.SniperComboMin.."发"
            else
                return Weapon.SniperComboMin
            end
        elseif giveDefault then
            return 0
        else
            return nil
        end
    elseif(ValName == "STAGGER") then
        if(Weapon.Stagger ~= nil) then
            return transStagger(Weapon.Stagger)
        elseif giveDefault then
            return "否"
        else
            return nil
        end
    elseif(ValName == "STANCEPOLARITY") then
        if(Weapon.StancePolarity ~= nil) then
            if(asString) then
                return Icon._Pol(Weapon.StancePolarity)
            else
                return Weapon.StancePolarity
            end
        elseif giveDefault then
            return "无"
        else
            return nil
        end
    elseif(ValName == "SYNDICATEEFFECT") then
        if(Weapon.SyndicateEffect ~= nil) then
            if(asString) then
                return "[["..Weapon.SyndicateEffect..'|'..trans.toChineseCI(Weapon.SyndicateEffect).."]]"
            else
                return Weapon.SyndicateEffect
            end
        else
            return nil
        end
    elseif(ValName == "TRAITS") then
        if(Weapon.Traits ~= nil) then
            return Weapon.Traits
        elseif giveDefault then
            return {}
        else
            return nil
        end
    elseif(ValName == "TRIGGER") then
        if(Weapon.Trigger ~= nil) then
            return Weapon.Trigger
        elseif giveDefault then
            return ""
        else
            return nil
        end
    elseif(ValName == "TYPE") then
        if(Weapon.Type ~= nil) then
        	if(asString) then
            	return transTerm(Weapon.Type)
        	else
        		return Weapon.Type
    		end
        elseif giveDefault then
            return ""
        else
            return nil
        end
    elseif(ValName == "USERS") then
        if(Weapon.Users ~= nil) then
            if(asString) then
                local result = ""
                for i, str in pairs(Weapon.Users) do
                    if(i > 1) then result = result..'<br/>' end
                    result = result..transWeaponUser(str)
                end
                return result
            else
                return Weapon.Users
            end
        elseif giveDefault then
            return {}
        else
            return nil
        end
    elseif(ValName == "WALLATTACK") then
        if(Weapon.WallAttack ~= nil) then
            if(asString) then
                if(Weapon.WallElement ~= nil) then
                    return Icon._Proc(Weapon.WallElement).." "..Shared.round(Weapon.WallAttack, 2, 1)
                else
                    return Shared.round(Weapon.WallAttack, 2, 1)
                end
            else
                return Weapon.WallAttack
            end
        elseif giveDefault then
            return 0
        else
            return nil
        end
    elseif(ValName == "WALLELEMENT") then
        if(Weapon.WallElement ~= nil) then
            return Weapon.WallElement
        elseif giveDefault then
            return ""
        else
            return nil
        end
    elseif(ValName == "ZOOM") then
        if(Weapon.Zoom ~= nil) then
            if(asString) then
                local result = ""
                for i, str in pairs(Weapon.Zoom) do
                    if(i > 1) then result = result..'<br/>' end
                    result = result..transZoom(str)
                end
                return result
            else
                return Weapon.Zoom
            end
        else
            return nil
        end
    elseif(ValName == "SPECIALFSPEED") then -- to show we can put very special keywords... if wanted
        if(Weapon.Name == "Drakgoon") then 
            if(asString) then 
                return "反弹：25米/秒"
            else
                return 25
            end
        elseif(getAttackValue(Weapon,getAttack(Weapon,"Area"),"PROJECTILESPEED")~=nil) then
            if(asString) then 
                return getAttackValue(Weapon,getAttack(Weapon,"Area"),"PROJECTILESPEED",true,true)
            else
                return getAttackValue(Weapon,getAttack(Weapon,"Area"),"PROJECTILESPEED")
            end
        elseif(getAttackValue(Weapon,getAttack(Weapon,"Secondary"),"PROJECTILESPEED")~=nil) then
            if(asString) then 
                return getAttackValue(Weapon,getAttack(Weapon,"Secondary"),"PROJECTILESPEED",true,true)
            else
                return getAttackValue(Weapon,getAttack(Weapon,"Secondary"),"PROJECTILESPEED")
            end
        elseif(giveDefault) then
            if(asString) then 
                return "0米/秒"
            else
                return 0
            end            
        else 
            return nil
        end
    else
        return getAttackValue(Weapon, getAttack(Weapon, "Normal"), ValName, giveDefault, asString)
    end
end

function p.getValue(frame)
    local WeapName = frame.args[1]
    local ValName1 = frame.args[2]
    local ValName2 = frame.args[3]
    if(WeapName == nil) then
        return ""
    elseif(ValName1 == nil) then
        return "ERROR: No value selected"
    end

    local theWeap = p.getWeapon(WeapName)
    if(theWeap == nil) then
        return ""
    end

    local vName
    local useDefault
    if(ValName2 == nil or ValName2 == "") then
        vName = ValName1
        useDefault = Shared.contains(UseDefaultList, string.upper(ValName1))
    else
        vName = {ValName1, ValName2}
        useDefault = Shared.contains(UseDefaultList, string.upper(ValName2))
    end

    return transTerm(getValue(theWeap, vName, useDefault, true))
end

local function BuildGunComparisonRow(Weapon)
    local styleString = ""--"border: 1px solid lightgray;"
    local td = '|| style = "'..styleString..'" |'
    local result = ''
    result = '\n|-\n| style = "'..styleString..'"|[['..Weapon.Name..'|'..trans.toChineseCI(Weapon.Name).."]]"
    local attName = ""
    if(hasAttack(Weapon, "Charge")) then
        attName = "Charge"
    elseif(hasAttack(Weapon, "Normal")) then
        attName = "Normal"
    else
        return ""
    end

    local trigger = getValue(Weapon, "Trigger")
    result = result..td..transTerm(trigger)
    if(trigger == "Charge") then
        local cTime = getValue(Weapon, {attName, "ChargeTime"})
        if(cTime ~= nil) then
            result = result.."（"..Shared.round(cTime, 2, 1).."秒）" 
        end
    elseif(trigger == "Burst") then
        local bCount = getValue(Weapon, {attName, "BurstCount"})
        if(bCount ~= nil) then
            result = result.."（"..bCount.."发）" 
        end
    end

    result = result..'||data-sort-value="'..getValue(Weapon, {attName, "Damage"})..'" style="'..styleString..'"|'..getValue(Weapon, {attName, "Damage"}, false, true)
    result = result..td..getValue(Weapon, {attName, "CritChance"}, true, true)..td..getValue(Weapon, {attName, "CritMultiplier"}, true, true)
    result = result..td..asPercent(getValue(Weapon, {attName, "StatusChance"}, true))
    result = result..td..transTerm(getValue(Weapon,{attName, "BulletType"},true))
    result = result..td..Shared.round(getValue(Weapon, {attName, "FireRate"}, true), 3, 1)..td..Weapon.Magazine..td..(Weapon.Reload or getValue(Weapon, {attName, "Reload"}, true))
    result = result..td..Weapon.Mastery
    if(getValue(Weapon, "Type") ~= "Arch-Gun") then
        if(Weapon.Disposition ~= nil) then
        	if Weapon.Disposition < 0.7 then
        	    result = result..'||data-sort-value="'..Weapon.Disposition..'" style="'..styleString..'"|'..Icon._Dis(1)..' （'..Weapon.Disposition..'）'
        	elseif Weapon.Disposition < 0.875 and Weapon.Disposition >= 0.7 then
        	    result = result..'||data-sort-value="'..Weapon.Disposition..'" style="'..styleString..'"|'..Icon._Dis(2)..' （'..Weapon.Disposition..'）'
        	elseif Weapon.Disposition < 1.125 and Weapon.Disposition >= 0.875 then
        	    result = result..'||data-sort-value="'..Weapon.Disposition..'" style="'..styleString..'"|'..Icon._Dis(3)..' （'..Weapon.Disposition..'）'
        	elseif Weapon.Disposition < 1.305 and Weapon.Disposition >= 1.125 then
        	    result = result..'||data-sort-value="'..Weapon.Disposition..'" style="'..styleString..'"|'..Icon._Dis(4)..' （'..Weapon.Disposition..'）'
        	elseif Weapon.Disposition >= 1.305 then
        	    result = result..'||data-sort-value="'..Weapon.Disposition..'" style="'..styleString..'"|'..Icon._Dis(5)..' （'..Weapon.Disposition..'）'
            end
        else
            result = result..'||data-sort-value="0" style="'..styleString..'"|未知'
        end
    end

    return result
end

local function BuildGunComparisonTable(Weapons)
    local styleString = "border: 1px solid black;border-collapse: collapse;"--"background-color:transparent;color:black;border: 1px solid black;border-collapse: collapse;"
    local tHeader = ""
    tHeader = tHeader..'\n{| cellpadding="1" cellspacing="0" class="listtable sortable filterable" style="font-size:11px;"'--margin:auto;text-align:center;border:1px solid black;font-size:11px;"'
    tHeader = tHeader..'\n! class="filterable-head" style="'..styleString..'"|名称'
    tHeader = tHeader..'\n! class="filterable-head" style="'..styleString..'"|[[Fire_Rate|扳机]]'
    tHeader = tHeader..'\n! data-sort-type="number" class="filterable-head" style="'..styleString..'"|[[Damage 2.0|伤害]]'
    tHeader = tHeader..'\n! data-sort-type="number" class="filterable-head" style="'..styleString..'"|[[Critical_Hit|暴击几率]]'
    tHeader = tHeader..'\n! data-sort-type="number" class="filterable-head" style="'..styleString..'"|[[Critical_Hit|暴击伤害]]'
    tHeader = tHeader..'\n! data-sort-type="number" class="filterable-head" style="'..styleString..'"|[[Status_Effect|触发几率]]'
    tHeader = tHeader..'\n! data-sort-type="number" class="filterable-head" style="'..styleString..'"|射击类型'
    tHeader = tHeader..'\n! data-sort-type="number" class="filterable-head" style="'..styleString..'"|[[Fire Rate|射速]]'
    tHeader = tHeader..'\n! data-sort-type="number" class="filterable-head" style="'..styleString..'"|[[Ammo|弹匣容量]]'
    tHeader = tHeader..'\n! data-sort-type="number" class="filterable-head" style="'..styleString..'"|[[Reload_Speed|装填时间]]'
    tHeader = tHeader..'\n! data-sort-type="number" class="filterable-head" style="'..styleString..'"|[[Mastery_Rank|段位]]'
    if (Shared.tableCount(Weapons) > 1) and getValue(Weapons[1], "Type") ~= "Arch-Gun" then
        tHeader = tHeader..'\n! class="filterable-head" data-sort-type="number" style="'..styleString..'"|[[Riven Mods#Disposition|倾向性]]'
    end
    local tRows = ""
    for i, Weap in pairs(Weapons) do
        local didWork, rowStr = pcall(BuildGunComparisonRow, Weap)
        if(didWork)then
            tRows = tRows..rowStr
        else
            mw.log("Error trying to build row for "..Weap.Name..": "..rowStr)
        end
    end

    return tHeader..tRows.."\n|}"
end

local function BuildMeleeComparisonRow(Weapon, addClass)
    local styleString = ""--"border: 1px solid lightgray;"
    local td = '|| style = "'..styleString..'" |'
    if(addClass == nil) then addClass = false end
    local result = '\n|-\n| style = "'..styleString..'"|[['..Weapon.Name..'|'..trans.toChineseCI(Weapon.Name).."]]"
    if(addClass) then
        result = result..td..linkMeleeClass(Weapon.Class)
    end
    result = result..'||data-sort-value="'..GetDamage(getAttack(Weapon, "Normal"))..'" style="'..styleString..'"|'..GetDamageString(getAttack(Weapon, "Normal"))
    result = result..td..Weapon.SlideAttack
    result = result..td..Shared.round(getValue(Weapon, "FireRate", true), 3, 2)..td..getValue(Weapon, "CritChance", true, true)..td..getValue(Weapon, "CritMultiplier", true, true)
    result = result..td..getValue(Weapon, "StatusChance", true, true)
    if Weapon.Mastery then 
    	result = result..td..Weapon.Mastery
    else
    	result = result..td..'未知'
    end
    if(getValue(Weapon, "Type") ~= "Arch-Melee") then
        result = result..td..GetStancePolarity(Weapon)
        if(Weapon.Disposition ~= nil) then
        	if Weapon.Disposition < 0.7 then
        	    result = result..'||data-sort-value="'..Weapon.Disposition..'" style="'..styleString..'"|'..Icon._Dis(1)..' （'..Weapon.Disposition..'）'
        	elseif Weapon.Disposition < 0.875 and Weapon.Disposition >= 0.7 then
        	    result = result..'||data-sort-value="'..Weapon.Disposition..'" style="'..styleString..'"|'..Icon._Dis(2)..' （'..Weapon.Disposition..'）'
        	elseif Weapon.Disposition < 1.125 and Weapon.Disposition >= 0.875 then
        	    result = result..'||data-sort-value="'..Weapon.Disposition..'" style="'..styleString..'"|'..Icon._Dis(3)..' （'..Weapon.Disposition..'）'
        	elseif Weapon.Disposition < 1.305 and Weapon.Disposition >= 1.125 then
        	    result = result..'||data-sort-value="'..Weapon.Disposition..'" style="'..styleString..'"|'..Icon._Dis(4)..' （'..Weapon.Disposition..'）'
        	elseif Weapon.Disposition >= 1.305 then
        	    result = result..'||data-sort-value="'..Weapon.Disposition..'" style="'..styleString..'"|'..Icon._Dis(5)..' （'..Weapon.Disposition..'）'
            end
        else
            result = result..'||data-sort-value="0" style="'..styleString..'"|未知'
        end
    end
    return result
end

local function BuildMeleeComparisonTable(Weapons, addClass)
    if(addClass == nil) then addClass = false end
    local styleString = "border: 1px solid black;border-collapse: collapse;"--"background-color:transparent;color:black;border: 1px solid black;border-collapse: collapse;"
    local tHeader = ""
    tHeader = tHeader..'\n{| cellpadding="1" cellspacing="0" class="listtable sortable filterable" style="font-size:11px;"'--margin:auto;text-align:center;font-size:11px;"'
    tHeader = tHeader..'\n! class="filterable-head" style="'..styleString..'"|名称'
    if(addClass) then
        tHeader = tHeader..'\n! class="filterable-head" style="'..styleString..'"|类型'
    end
    tHeader = tHeader..'\n! data-sort-type="number" class="filterable-head" style="'..styleString..'"|[[Damage 2.0|伤害]]'
    tHeader = tHeader..'\n! class="filterable-head" data-sort-type="number" style="'..styleString..'"|[[Damage 2.0|滑砍]]'
    tHeader = tHeader..'\n! class="filterable-head" data-sort-type="number" style="'..styleString..'"|[[Maneuvers#Melee|攻击速度]]'
    tHeader = tHeader..'\n! data-sort-type="number" class="filterable-head" style="'..styleString..'"|[[Critical_Hit|暴击几率]]'
    tHeader = tHeader..'\n! data-sort-type="number" class="filterable-head" style="'..styleString..'"|[[Critical_Hit|暴击伤害]]'
    tHeader = tHeader..'\n! class="filterable-head" data-sort-type="number" style="'..styleString..'"|[[Status Chance|触发几率]]'
    tHeader = tHeader..'\n! data-sort-type="number" class="filterable-head" style="'..styleString..'"|[[Mastery_Rank|段位]]'
    --if (Shared.tableCount(Weapons) > 1) and getValue(Weapons[1], "Type") == "Melee" then
        tHeader = tHeader..'\n! style="'..styleString..'"|[[Stance|架式]]'
        tHeader = tHeader..'\n! data-sort-type="number" style="'..styleString..'"|[[Riven Mods#Disposition|倾向性]]'
    --end

    local tRows = ""
    for i, Weap in pairs(Weapons) do
        tRows = tRows..BuildMeleeComparisonRow(Weap, addClass)
    end

    return tHeader..tRows.."\n|}"
end

local function buildInfoboxRow(Label, Text, Collapse, Digits, Addon)
    local result = ""

    if(Collapse == nil) then
        Collapse = false
    elseif(Collapse == 1) then
        Collapse = true
    end
    if(Text ~= nil) then
        result = '<div style="margin:-2px -4px;padding:2px;" '
        if(Collapse) then
            result = result..'class="Infobox_Collapsible"'
        end
        result = result..'>'
        result = result..'\n{| style="width:100%;"'
        result = result..'\n|-'
        result = result..'\n| class="left" | <span style="white-space:nowrap;">'
            result = result.."'''"..Label.."'''"
        result = result..'</span>'
        result = result..'\n| class="right" | '
        if(Digits == nil) then
            result = result..Text
        else
            result = result..Shared.round(Text, Digits)
        end
        if(Addon ~= nil) then
            result = result..p.doPlural(Addon, Text)
        end
        result = result..'\n|}'
        result = result..'\n</div>'
    end
    return result
end

local function buildInfoboxCategory(CategoryName)
    local result = '\n|-\n! colspan="2" class="category" | '..CategoryName
    result = result..'\n|-\n| colspan="2" |'
    return result
end

local function makeAttackInfoboxRows(Weapon, Attack, AttackName)
    if(Attack == nil) then
        return ""
    end
    local result = buildInfoboxCategory(AttackName)

    local Physical = GetDamage(Attack, "Physical")
    if(Physical > 0) then
        result = result..buildInfoboxRow("[[Damage 2.0|物理伤害]]", getAttackValue(Weapon, Attack, "Physical", true, true))
        result = result..buildInfoboxRow(Icon._Proc("Impact", "Text", "white", nil, true), getAttackValue(Weapon, Attack, "Impact", true, true), true)
        result = result..buildInfoboxRow(Icon._Proc("Puncture", "Text", "white", nil, true), getAttackValue(Weapon, Attack, "Puncture", true, true), true)
        result = result..buildInfoboxRow(Icon._Proc("Slash", "Text", "white", nil, true), getAttackValue(Weapon, Attack, "Slash", true, true), true)
    end

    for element, damage in Shared.skpairs(Attack.Damage) do
        if(element ~= "Impact" and element ~= "Puncture" and element ~= "Slash") then
            result = result..buildInfoboxRow(Icon._Proc(element, "Text", "white", nil, true), getAttackValue(Weapon, Attack, element, true, true))
        end
    end
    result = result..buildInfoboxRow("占比最高伤害 %", GetDamageBiasString(Attack), true)
    result = result..buildInfoboxRow("[[Fire Rate#Charged Weapons|蓄力时间]]", Attack.ChargeTime, nil, 1, "秒")
    result = result..buildInfoboxRow("[[Critical Hit#Critical Hit Chance|暴击几率]]", getAttackValue(Weapon, Attack, "CritChance", false, true))
    result = result..buildInfoboxRow("[[Critical Hit#Critical Damage Multiplier|暴击倍率]]", getAttackValue(Weapon, Attack, "CritMultiplier", false, true))
    result = result..buildInfoboxRow("[[Status Chance|触发几率]]", getAttackValue(Weapon, Attack, "StatusChance", false, true))
    result = result..buildInfoboxRow("[[Punch Through|穿透]]", getAttackValue(Weapon, Attack, "PunchThrough", false, true))
    result = result..buildInfoboxRow("[[Fire Rate|射速]]", getAttackValue(Weapon, Attack, "FireRate", false, true), nil)
    result = result..buildInfoboxRow("连射射速", Attack.BurstFireRate, true, {2, 1}, "发/<sub>秒/连射</sub>")
    result = result..buildInfoboxRow("[[Multishot|弹片数量]]", Attack.PelletCount, nil, 0, "弹片数/发")
    if(Attack.Bullet ~= nil) then
        if(Attack.Bullet.Speed ~= nil) then
            result = result..buildInfoboxRow("[[Projectile Speed|飞行速度]]", Attack.Bullet.Speed, true, 2, "&thinsp;米/秒")
        else
            result = result..buildInfoboxRow("[[Projectile Speed|飞行速度]]", trans.toChineseCat(Attack.Bullet.Type), true)
        end
    end
    result = result..buildInfoboxRow("半径", getAttackValue(Weapon, Attack, "Radius", false, true), nil)
    if(AttackName ~= "Normal Attacks") then
        result = result..buildInfoboxRow("扳机", trans.toChineseCat(getAttackValue(Weapon, Attack, "Trigger", false, true)), nil)
    end
    if(Attack.Falloff ~= nil) then
        local falloffText = Shared.round(Attack.Falloff.StartRange, 2, 1).."米内为满伤害"
        falloffText = falloffText.."<br/>大于"..Shared.round(Attack.Falloff.EndRange, 2, 1).."米后为最低伤害"
        if(Attack.Falloff.Reduction ~= nil) then
            falloffText = falloffText.."<br/>"..asPercent(Attack.Falloff.Reduction).."最大衰减"
        end
        result = result..buildInfoboxRow("伤害衰减", falloffText)
    end

    return result
end

--Returns a list of weapons for a stance
--Adds a ✓ if the weapon matches the polarity
function p.getStanceWeaponList(frame)
    local StanceName = frame.args ~= nil and frame.args[1] or frame
    local Stance = p.getStance(StanceName)

    if(Stance == nil) then
        return "ERROR: "..StanceName.." not found"
    end

    local weaps = getMeleeWeapons(Stance.Class, Stance.PvP)
    local result = ""

    for i, weap in Shared.skpairs(weaps) do
        if (string.len(result) > 0) then
            result = result.."\n"  
        end

        result = result.."*[["..weap.Name..'|'..trans.toChineseCI(weap.Name).."]]"

        if(weap.StancePolarity == Stance.Polarity) then
            result = result.." ✓"
        end
    end

    return result
end

--Returns a list of stances for a weapon
--Adds the polarity for each stance
function p.getWeaponStanceList(frame)
    local WeaponName = frame.args ~= nil and frame.args[1] or frame
    local Weapon = getWeapon(WeaponName)

    if(Weapon == nil) then
        return "ERROR: "..WeaponName.." not found"
    end

    return getWeaponStanceList(Weapon)
end

function p.getStanceGallery(frame)
    local StanceType = frame.args ~= nil and frame.args[1] or frame
    local Stances = getStances(StanceType, true)
    local result, galleryTagBody = {}, {}
    table.insert(result, "=="..trans.toChineseCat(StanceType).."[[Stance|架式MOD]]==")
    for i, Stance in pairs(Stances) do
    	local imageQueryResult = mw.smw.ask{'[['..Stance.Name..']]', '?#-=page', '?image#-=image', limit = 1, mainlabel = '-'}
        local theImage = #imageQueryResult > 0 and imageQueryResult[1].image or "Panel.png"
        table.insert(galleryTagBody, theImage .. '|link=' .. Stance.Name .. '|[['..Stance.Name..'|'..trans.toChineseCI(Stance.Name)..']]'..(Stance.PvP and '<br/>（仅限[[武形秘仪]]）' or ''))
    end
    table.insert(result, frame:extensionTag('gallery', table.concat(galleryTagBody, '\n'), { mode = 'traditional', heights = '250px' , widths = '150px', class = 'frameless' }))
    return table.concat(result, '\n')
end

local function getWeaponGallery(Weapons, frame)
	local galleryTagBody = {}
    for i, Weapon in pairs(Weapons) do
        local theImage = Weapon.Image ~= nil and Weapon.Image or "Panel.png"
        table.insert(galleryTagBody, theImage .. '|link=' .. Weapon.Name .. '|[['..Weapon.Name..'|'..trans.toChineseCI(Weapon.Name)..']]')
    end
    return frame:extensionTag('gallery', table.concat(galleryTagBody, '\n'), { mode = 'traditional', heights = '150px' , widths = '250px', class = 'frameless' })
end

function p.getMeleeWeaponGallery(frame)
    local Type = frame.args ~= nil and frame.args[1] or frame
    if(Type == nil) then
        return ""
    end
    local WeapArray = getMeleeWeapons(Type)
    local result = "=="..trans.toChineseCat(Type).."武器==\n"
    result = result..getWeaponGallery(WeapArray, frame)
    return result
end

function p.getWeaponCount(frame)
    local Type = frame.args ~= nil and frame.args[1] or frame
    local getFullList = frame.args ~= nil and frame.args[2]
    if getFullList == "nil" then --bleh, this lovely parsing of invokes..
        getFullList = nil
    end
    local getAll = frame.args ~= nil and frame.args[3]
    local count = 0
    local fullList = ""
    for i, val in Shared.skpairs(WeaponData["Weapons"]) do
        if(not Shared.contains(WeaponData["IgnoreInCount"], i) and getAll ~= "true") or getAll == "true" then
            if(Type == nil or Type == "") then
                count = count + 1
                if(getFullList ~= nil) then fullList = fullList..'\n# '..val.Name end
            elseif(Type == "Warframe") then
                if(val.Type == "Primary" or val.Type == "Secondary" or val.Type == "Melee") then
                    count = count + 1
                    if(getFullList ~= nil) then fullList = fullList..'\n# '..val.Name end
                end
            elseif(Type == "Archwing") then
                if(val.Type == "Arch-Gun" or val.Type == "Arch-Melee") then
                    count = count + 1
                    if(getFullList ~= nil) then fullList = fullList..'\n# '..val.Name end
                end
            elseif(Type == "Rest") then
                if(val.Type ~= "Arch-Gun" and val.Type ~= "Arch-Melee" and val.Type ~= "Primary" and val.Type ~= "Secondary" and val.Type ~= "Melee") then
                    count = count + 1
                    if(getFullList ~= nil) then fullList = fullList..'\n# '..val.Name end
                end
            else
                if(val.Type == Type) then
                    count = count + 1
                    if(getFullList ~= nil) then fullList = fullList..'\n# '..val.Name end
                end
            end
        end
    end
    if(getFullList ~= nil) then return fullList end
    return count
end

function getSecondaryCategory(weapon)
    local class = getValue(weapon, "Class", true)
    if(class == "Thrown") then
        return "Thrown"
    elseif(class == "Dual Shotguns" or class == "Shotgun Sidearm") then
        return "Shotgun"
    else
        local trigger = getValue(weapon, "Trigger", true)
        if(trigger == "Semi-Auto" or trigger == "Burst") then
            return "Semi-Auto"
        elseif(trigger == "Auto" or trigger == "Auto-Spool") then
            return "Auto"
        end
    end
    return "Other"
end

--Gets melee weapon comparison
--If an argument is specified, gets only for a specific class
function p.getMeleeComparisonTable(frame)
    local Type = frame.args ~= nil and frame.args[1] or nil
    local WeapArray = getMeleeWeapons(Type)
    local addClass = Type == nil or Shared.contains(Type, ",")
    return BuildMeleeComparisonTable(WeapArray, addClass)
end

function getSecondaryCategory(weapon)
    local class = getValue(weapon, "Class", true)
    if(class == "Thrown") then
        return "Thrown"
    elseif(class == "Dual Shotguns" or class == "Shotgun Pistol") then
        return "Shotgun"
    else
        local trigger = getValue(weapon, "Trigger", true)
        if(trigger == "Semi-Auto" or trigger == "Burst") then
            return "Semi-Auto"
        elseif(trigger == "Auto" or trigger == "Auto-Spool") then
            return "Auto"
        end
    end
    return "Other"
end

--Gets ALL Secondaries to compare
function p.getSecondaryComparisonTable(frame)
    local Type = frame.args ~= nil and frame.args[1] or nil
    local WeapArray = p.getWeapons(function(x) 
                                local result = false
                                if(getValue(x, "Type", true) == "Secondary") then
                                    if(Type ~= nil) then
                                        return getSecondaryCategory(x) == Type
                                    else
                                        return true
                                    end
                                end
                                    return result
                                end)
    return BuildGunComparisonTable(WeapArray)
end

function p.getCompTableArchGuns(frame)
    local ArchType="Arch-Gun"
    if (frame.args ~= nil) then 
        if (frame.args[1] == "Arch-Gun (Atmosphere)") then
            ArchType="Arch-Gun (Atmosphere)"
        end
    end

    local WeapArray = {}
    WeapArray = p.getWeapons(function(x) 
                                    return getValue(x, "Type", true) == ArchType
                                    end)

	local Head={{"Name",false,"Name"}}
	 -- better if Name is always the first column !!!
	table.insert(Head,{"Trigger",false,"[[Fire Rate|扳机类型]]"})
	table.insert(Head,{{"default","Damage"},true,"[[Damage 2.0|伤害]]"})
	table.insert(Head,{"CritChance",true,"[[Critical Chance|暴击几率]]"})
	table.insert(Head,{"CritMultiplier",true,"[[Critical multiplier|暴击伤害]]"})
	table.insert(Head,{"StatusChance",true,"[[Status Chance|触发几率]]"})
	table.insert(Head,{{"default","BulletType"},false,"[[Projectile Speed|抛射物类型]]"})
	table.insert(Head,{"FireRate",true,"[[Fire Rate|射速]]"})
	table.insert(Head,{"Magazine",true,"[[Ammo#Magazine Capacity|弹匣容量]]"})
	table.insert(Head,{"Reload",true,"[[Reload Speed|装填时间]]"})
	table.insert(Head,{"Mastery",true,"[[Mastery Rank|段位]]"})
    return BuildCompTable(Head,WeapArray)
end

function p.getCompTableMelees(frame)
    --Changed formatting, now only takes type since only class handled is Melee
    --Keeping old formatting to avoid breaking pages
    local Type = frame.args ~= nil and frame.args[2] or nil
    if(Type == nil) then Type = frame.args ~= nil and frame.args[1] or nil end 
    if(Type == "All") then Type = nil end
    local WeapArray = {}
    WeapArray = getMeleeWeapons(Type)
    local addClass = Type == nil or Shared.contains(Type, ",")

	local Head={{"Name",false,"Name"}}
	 -- better if Name is always the first column !!!
	table.insert(Head,{"Class",false,"Type"})
	table.insert(Head,{{"Normal","Damage"},true,"[[Damage|近战攻击]]"})
	table.insert(Head,{"SlideAttack",true,"[[Melee#Slide Attack|滑行攻击]]"})
	table.insert(Head,{{"default","FireRate"},true,"[[Attack Speed|攻击速度]]"})
	table.insert(Head,{"CritChance",true,"[[Critical Chance|暴击几率]]"})
	table.insert(Head,{"CritMultiplier",true,"[[Critical multiplier|暴击伤害]]"})
	table.insert(Head,{"StatusChance",true,"[[Status Chance|触发几率]]"})
	table.insert(Head,{"Mastery",true,"[[Mastery Rank|段位]]"})
	table.insert(Head,{"STANCEPOLARITY",false,"[[Stance|架势]]"})
	table.insert(Head,{"Disposition",true,"[[Riven Mods#Disposition|裂罅倾向性]]"})
	for k, v in pairs(Head[1]) do mw.log(k, v) end

    return BuildCompTable(Head,WeapArray)
end

function getPrimaryCategory(weapon)
    local class = getValue(weapon, "Class", true)
    if(class == "Shotgun") then
        return "Shotgun"
    elseif(class == "Bow") then
        return "Bow"
    elseif(class == "Sniper Rifle") then
        return "Sniper"
    elseif(class == "Rifle") then
        local trigger = getValue(weapon, "Trigger", true)
        if(trigger == "Semi-Auto" or trigger == "Burst") then
            return "Semi-Auto"
        elseif(trigger == "Auto" or trigger == "Auto-Spool") then
            return "Auto"
        end
    end
    return "Other"
end

--Gets ALL Primaries to compare
function p.getPrimaryComparisonTable(frame)
    local Type = frame.args ~= nil and frame.args[1] or nil
    local WeapArray = p.getWeapons(function(x) 
                                if(getValue(x, "Type", true) == "Primary") then
                                    if(Type ~= nil) then
                                        return getPrimaryCategory(x) == Type
                                    else
                                        return true
                                    end
                                end
                                    return false
                                end)
    return BuildGunComparisonTable(WeapArray)
end

function p.getSentinelWeaponComparison(frame)
    local WeapArray = p.getWeapons(function(x) 
                                    return getValue(x, "Type", true) == "Sentinel"
                                end)
    return BuildGunComparisonTable(WeapArray)
end

function p.getArchGunComparison(frame)
    local WeapArray = p.getWeapons(function(x) 
                                    return getValue(x, "Type", true) == "Arch-Gun"
                                end)
    return BuildGunComparisonTable(WeapArray)
end

function p.getArchMeleeComparison(frame)
    local WeapArray = p.getWeapons(function(x) 
                                    return getValue(x, "Type", true) == "Arch-Melee"
                                end)
    return BuildMeleeComparisonTable(WeapArray)
end

function p.getPolarityTable()
    local tHeader = ""
    tHeader = tHeader..'\n{| style="width: 100%; border-collapse: collapse; cellpadding: 2" border="1"'
    tHeader = tHeader..'\n! colspan="2" style="width:33%" | 主武器'
    tHeader = tHeader..'\n! colspan="2" style="width:33%" | 副武器'
    tHeader = tHeader..'\n! colspan="2" | 近战武器'
    local tRows = ""

    local Melees = p.getWeapons(function(x) return p.isMelee(x) and Shared.tableCount(getValue(x, "Polarities", true)) > 0 end)
    local Pistols = p.getWeapons(function(x) return x.Type == "Secondary" and  Shared.tableCount(getValue(x, "Polarities", true)) > 0 end)
    local Primaries = p.getWeapons(function(x) return (x.Type == "Primary") and Shared.tableCount(getValue(x, "Polarities", true)) > 0 end)

    local ACount = Shared.tableCount(Melees)
    local maxLen = ACount
    local BCount = Shared.tableCount(Pistols)
    if(BCount > maxLen) then
        maxLen = BCount
    end
    local CCount = Shared.tableCount(Primaries)
    if(CCount > maxLen) then
        maxLen = CCount
    end

    for i=1, maxLen, 1 do
        tRows = tRows.."\n|-"
        if(i <= CCount) then
            tRows = tRows.."\n|[["..Primaries[i].Name.."|"..trans.toChineseCI(Primaries[i].Name).."]]||"..p.GetPolarityString(Primaries[i])
        else
            tRows = tRows.."\n| ||"
        end
        if(i <= BCount) then
            tRows = tRows.."\n|[["..Pistols[i].Name.."|"..trans.toChineseCI(Pistols[i].Name).."]]||"..p.GetPolarityString(Pistols[i])
        else
            tRows = tRows.."\n| ||"
        end
        if(i <= ACount) then
            tRows = tRows.."\n|[["..Melees[i].Name.."|"..trans.toChineseCI(Melees[i].Name).."]]||"..p.GetPolarityString(Melees[i])
        else
            tRows = tRows.."\n| ||"
        end
    end

    return tHeader..tRows.."\n|}"
end

function buildCompareString(Val1, Val2, ValName, Digits, Addon, Words, Start)
    if(Val1 == nil or Val2 == nil) then
        return ""
    end
    local V1Str = Val1
    local V2Str = Val2
    if(Digits ~= nil) then
        local didWork, rowStr = pcall(Shared.round, Val1, Digits)
        if(didWork) then
            V1Str = rowStr
            local didWork, rowStr = pcall(Shared.round, Val2, Digits)
            if(didWork) then
                V2Str = rowStr
            else
                mw.log("Failed to round "..Val2)
            end
        else
            mw.log("Failed to round "..Val1)
        end
    end
    if(Addon ~= nil) then
        V1Str = V1Str..p.doPlural(Addon, Val1)
        V2Str = V2Str..p.doPlural(Addon, Val2)
    end
    local bigWord = Words ~= nil and Words[1] or "更高的"
    local smallWord = Words ~= nil and Words[2] or "更低的"
    local start = Start ~= nil and Start or "\n**"

    if(Val1 > Val2) then
        return start.." "..bigWord..""..ValName.."（"..V1Str..' <i class="fa fa-arrows-h" aria-hidden="true"></i> '..V2Str.."）"
    elseif(Val2 > Val1) then
        return start.." "..smallWord..""..ValName.."（"..V1Str..' <i class="fa fa-arrows-h" aria-hidden="true"></i> '..V2Str.."）"
    else
        return ""
    end
end

function buildGunComparisonString(Weapon1, Weapon2)
    local result = "* "..trans.toChineseCI(Weapon1.Name).."与[["..Weapon2.Name..'|'..trans.toChineseCI(Weapon2.Name).."]]相比："

    if(hasAttack(Weapon1, "Normal") and hasAttack(Weapon2, "Normal")) then
    	local Att1 = getAttack(Weapon1, "Normal")
        local Att2 = getAttack(Weapon2, "Normal")
        local dmgString = ""
        dmgString = dmgString..buildCompareString(GetDamage(Att1), GetDamage(Att2), "基础伤害", {2, 1})
        dmgString = dmgString..buildCompareString(Att1.Damage["Impact"], Att2.Damage["Impact"], Icon._Proc("Impact", "text").."伤害", {2, 1}, nil, {"更高的", "更低的"}, "\n***")
        dmgString = dmgString..buildCompareString(Att1.Damage["Puncture"], Att2.Damage["Puncture"], Icon._Proc("Puncture", "text").."伤害", {2, 1}, nil, {"更高的", "更低的"}, "\n***")
        dmgString = dmgString..buildCompareString(Att1.Damage["Slash"], Att2.Damage["Slash"], Icon._Proc("Slash", "text").."伤害", {2, 1}, nil, {"更高的", "更低的"}, "\n***")
        if(string.len(dmgString) > 0 and GetDamage(Att1) == GetDamage(Att2)) then
            dmgString = "\n**基础伤害相同，但伤害组成不同："..dmgString    
        end
        result = result..dmgString
    end
    if(hasAttack(Weapon1, "Charge")and hasAttack(Weapon2, "Charge")) then
        result = result..buildCompareString(GetDamage(Weapon1.ChargeAttack), GetDamage(Weapon2.ChargeAttack), "蓄力攻击伤害", {2, 1})
        result = result..buildCompareString(getValue(Weapon1, {"Charge", "ChargeTime"}), getValue(Weapon2, {"Charge", "ChargeTime"}), "蓄力时间", {2, 1}, "秒", {"更慢的", "更快的"})
    end
    if(hasAttack(Weapon1, "Area") and hasAttack(Weapon2, "Area")) then
        result = result..buildCompareString(GetDamage(Weapon1.AreaAttack), GetDamage(Weapon2.AreaAttack), "范围攻击伤害", {2, 1})
    end
    if(hasAttack(Weapon1, "Secondary") and hasAttack(Weapon2, "Secondary")) then
        result = result..buildCompareString(GetDamage(Weapon1.SecondaryAttack), GetDamage(Weapon2.SecondaryAttack), "次要攻击伤害", {2, 1})
    end

    if(hasAttack(Weapon1, "Normal") and hasAttack(Weapon2, "Normal") ) then
    	local Att1 = getAttack(Weapon1, "Normal")
        local Att2 = getAttack(Weapon2, "Normal")
        if(Att1.CritChance ~= nil and Att2.CritChance ~= nil) then
        	result = result..buildCompareString((Att1.CritChance * 100), (Att2.CritChance * 100), "暴击几率", 2, "%")
        end
        result = result..buildCompareString(Att1.CritMultiplier, Att2.CritMultiplier, "暴击伤害倍率", 2, "x")
        if(Att1.StatusChance ~= nil and Att2.StatusChance ~= nil) then
        	result = result..buildCompareString((Att1.StatusChance * 100), (Att2.StatusChance * 100), "触发几率", 2, "%")
        end
        result = result..buildCompareString(Att1.FireRate, Att2.FireRate, "射速", 2, "发/秒")
    end

    result = result..buildCompareString(Weapon1.Magazine, Weapon2.Magazine, "弹匣", 0, "发", {"更大的", "更小的"})
    result = result..buildCompareString(Weapon1.MaxAmmo, Weapon2.MaxAmmo, "弹药上限", 0, "发", {"更大的", "更小的"})
    result = result..buildCompareString(Weapon1.Reload, Weapon2.Reload, "装填速度", 2, "秒", {"更慢的", "更快的"})
    result = result..buildCompareString(Weapon1.Spool, Weapon2.Spool, "预热速度", 0, "发", {"更慢的", "更快的"})

    --Handling Damage Falloff        
    if(Weapon1.Falloff ~= nil and Weapon2.Falloff == nil) then
        result = result.."\n** "..Weapon1.Falloff.StartRange.."米 - "..Weapon1.Falloff.EndRange.."米伤害衰减范围"
    elseif(Weapon2.Falloff ~= nil and Weapon1.Falloff == nil) then
        result = result.."\n** 无"..Weapon2.Falloff.StartRange.."米 - "..Weapon2.Falloff.EndRange.."米伤害衰减范围"
    elseif(Weapon1.Falloff ~= nil and Weapon2.Falloff ~= nil and Weapon1.Falloff.Reduction ~= Weapon2.Falloff.Reduction) then
     result = result..buildCompareString(Weapon1.Falloff.Reduction * 100, Weapon2.Falloff.Reduction * 100, "伤害衰减率", 2, "%", {"更大的", "更小的"})
    end

    --Handling Syndicate radial effects
    if(Weapon1.SyndicateEffect ~= nil and Weapon2.SyndicateEffect == nil) then
        result = result.."\n** 内置[["..Weapon1.SyndicateEffect..'|'..trans.toChineseCI(Weapon1.SyndicateEffect).."]]效果"
    elseif(Weapon2.SyndicateEffect ~= nil and Weapon1.SyndicateEffect == nil) then
        result = result.."\n** 缺少内置[["..Weapon2.SyndicateEffect..'|'..trans.toChineseCI(Weapon2.SyndicateEffect).."]]效果"
    elseif(Weapon1.SyndicateEffect ~= nil and Weapon2.SyndicateEffect ~= nil and Weapon1.SyndicateEffect ~= Weapon2.SyndicateEffect2) then
        result = result.."\n** 不同的内置[[Syndicate Radial Effects|集团效果]]：[["..Weapon1.SyndicateEffect..'|'..trans.toChineseCI(Weapon1.SyndicateEffect).."]] &harr; [["..Weapon2.SyndicateEffect..'|'..trans.toChineseCI(Weapon2.SyndicateEffect).."]]"
    end

    --Handling Polarities
    local Pol1 = Weapon1.Polarities ~= nil and Weapon1.Polarities or {}
    local Pol2 = Weapon2.Polarities ~= nil and Weapon2.Polarities or {}
    local count1 = Shared.tableCount(Pol1)
    local count2 = Shared.tableCount(Pol2)
    local isDifferent = count1 ~= count2
    if(not isDifferent and count1 > 0) then
        table.sort(Pol1, function(x, y) return x < y end)
        table.sort(Pol2, function(x, y) return x < y end)
        for i, pol in pairs(Pol1) do
            if(pol ~= Pol2[i]) then
                isDifferent = true
            end
        end
    end

    if(isDifferent) then
        result = result.."\n** 不同的极性（"..p.GetPolarityString(Weapon1)..' <i class="fa fa-arrows-h" aria-hidden="true"></i> '..p.GetPolarityString(Weapon2).."）"
    end

    result = result..buildCompareString(Weapon1.Mastery, Weapon2.Mastery, "[[Mastery Rank|段位]]需求", 0)
    return result
end

function buildMeleeComparisonString(Weapon1, Weapon2)
    local result = "* "..trans.toChineseCI(Weapon1.Name).."与[["..Weapon2.Name..'|'..trans.toChineseCI(Weapon2.Name).."]]相比："
    local Att1 = getAttack(Weapon1, "Normal")
    local Att2 = getAttack(Weapon2, "Normal")
    local dmgString = ""
    dmgString = dmgString..buildCompareString(GetDamage(Att1), GetDamage(Att2), "基础伤害", {2, 1})
    dmgString = dmgString..buildCompareString(Att1.Damage["Impact"], Att2.Damage["Impact"], Icon._Proc("Impact", "text").."伤害", {2, 1}, nil, {"更高的", "更低的"}, "\n***")
    dmgString = dmgString..buildCompareString(Att1.Damage["Puncture"], Att2.Damage["Puncture"], Icon._Proc("Puncture", "text").."伤害", {2, 1}, nil, {"更高的", "更低的"}, "\n***")
    dmgString = dmgString..buildCompareString(Att1.Damage["Slash"], Att2.Damage["Slash"], Icon._Proc("Slash", "text").."伤害", {2, 1}, nil, {"更高的", "更低的"}, "\n***")
    if(string.len(dmgString) > 0 and GetDamage(Att1) == GetDamage(Att2)) then
	dmgString = "\n**基础伤害相同，但伤害组成不同："..dmgString    
    end
    result = result..dmgString

    result = result..buildCompareString((Att1.CritChance * 100), (Att2.CritChance * 100), "暴击几率", 2, "%")
    result = result..buildCompareString(Att1.CritMultiplier, Att2.CritMultiplier, "暴击伤害倍率", 2, "x")
    result = result..buildCompareString((Att1.StatusChance * 100), (Att2.StatusChance * 100), "触发几率", 2, "%")
    result = result..buildCompareString(Att1.FireRate, Att2.FireRate, "攻击速度", 2)
    result = result..buildCompareString(Icon._Pol(Weapon1.StancePolarity), Icon._Pol(Weapon2.StancePolarity), "架式极性", nil, nil, {"不同的", "不同的"})
    result = result..buildCompareString(Weapon1.ChannelMult, Weapon2.ChannelMult, "导引伤害倍率", 1, "x", {"更大的", "更小的"})

    --Handling Polarities
    local Pol1 = Weapon1.Polarities ~= nil and Weapon1.Polarities or {}
    local Pol2 = Weapon2.Polarities ~= nil and Weapon2.Polarities or {}
    local count1 = Shared.tableCount(Pol1)
    local count2 = Shared.tableCount(Pol2)
    local isDifferent = count1 ~= count2
    if(not isDifferent and count1 > 0) then
        table.sort(Pol1, function(x, y) return x < y end)
        table.sort(Pol2, function(x, y) return x < y end)
        for i, pol in pairs(Pol1) do
            if(pol ~= Pol2[i]) then
                isDifferent = true
            end
        end
    end

    if(isDifferent) then
        result = result.."\n** 不同的极性（"..p.GetPolarityString(Weapon1)..' <i class="fa fa-arrows-h" aria-hidden="true"></i> '..p.GetPolarityString(Weapon2).."）"
    end

    result = result..buildCompareString(Weapon1.Mastery, Weapon2.Mastery, "[[Mastery Rank|段位]]需求", 0)
    return result
end

function p.buildComparison(frame)
    local WeapName1 = frame.args[1]
    local WeapName2 = frame.args[2]

    if(WeapName1 == nil or WeapName2 == nil) then
        return '<span style="color:red">ERROR: Must compare two weapons</span>'
    end

    local Weapon1 = p.getWeapon(WeapName1)
    if(Weapon1 == nil) then
        return '<span style="color:red">ERROR: Could not find '..WeapName1..'</span>'
    end
    local Weapon2 = p.getWeapon(WeapName2)
    if(Weapon2 == nil) then
        return '<span style="color:red">ERROR: Could not find '..WeapName2..'</span>'
    end

    if(p.isMelee(Weapon1)) then
        return buildMeleeComparisonString(Weapon1, Weapon2)
    else
        return buildGunComparisonString(Weapon1, Weapon2)
    end
end

function p.buildFamilyComparison(frame)
    local WeapName = frame.args[1]
    if(WeapName == nil) then
        return '<span style="color:red">ERROR: Must provide a Weapon name</span>'
    end

    local Weapon = p.getWeapon(WeapName)
    if(Weapon == nil) then
        return '<span style="color:red">ERROR: Could not find '..WeapName1..'</span>'
    end
    if(Weapon.Family == nil) then
        return '<span style="color:red">ERROR: '..WeapName..' doesn\'t have a family</span>'
    end

    local relatives = getFamily(Weapon.Family)
    local result = {}
    for i, NewWeapon in pairs(relatives) do
        if(WeapName ~= NewWeapon.Name) then
            if(NewWeapon.Type == "Melee") then
                table.insert(result, buildMeleeComparisonString(Weapon, NewWeapon))
            else
                table.insert(result, buildGunComparisonString(Weapon, NewWeapon))
            end
        end
    end
    return table.concat(result, "\n")
end

function p.buildAutoboxCategories(frame)
    local WeapName = frame.args ~= nil and frame.args[1] or frame
    local Weapon = p.getWeapon(WeapName)
    local result = "[[Category:武器]]"
    if(Weapon == nil) then
        return ""
    end
    if(Weapon.Type ~= nil) then
        result= result.."[[Category:"..trans.toChineseCat(Weapon.Type.." Weapons").."]]"
    end
    if(Weapon.Class ~= nil) then
        result= result.."[[Category:"..trans.toChineseCat(Weapon.Class).."]]"
    end

    local augments = getAugments(Weapon)
    if(Shared.tableCount(augments) > 0) then
        result = result.."[[Category:强化武器]]"
    end

    if(HasTrait(Weapon, "Prime")) then
        result = result.."[[Category:Prime]]"
        if(HasTrait(Weapon, "Never Vaulted")) then
            result = result.."[[Category:未入库]]"
        elseif(HasTrait(Weapon, "Vaulted")) then
            result = result.."[[Category:已入库]]"
        end
    end

    if(Weapon.Damage ~= nil) then
        local bestPercent, bestElement = GetDamageBias(Weapon)
        if(bestElement == "Impact" or bestElement == "Puncture" or bestElement == "Slash") then
            result = result.."[[Category:"..trans.toChineseCat(bestElement.." Damage Weapons").."]]"
        end

        for key, value in Shared.skpairs(Weapon.Damage) do
            if(key ~= "Impact" and key ~= "Puncture" and key ~= "Slash") then
                result = result.."[[Category:"..trans.toChineseCat(key.." Damage Weapons").."]]"
            end
        end
    end

    -- setup smw properties
    local weapons = WeaponData.Weapons
    local weaponName = Weapon.Name or WeapName
   	props['image'] = Weapon.Image
	props['has prime'] = weapons[weaponName .. ' Prime'] and 'yes' or 'no'
	props['has mara'] = weapons['Mara ' .. weaponName] and 'yes' or 'no'
	props['has vandal'] = weapons[weaponName .. ' Vandal'] and 'yes' or 'no'
	props['has prisma'] = (weapons['Prisma ' .. weaponName] and weaponName~= 'Machete') and 'yes' or 'no'
	props['has wraith'] = weapons[weaponName .. ' Wraith'] and 'yes' or 'no'
	table.insert(props, 'has mk1=' .. (weapons['MK1-' .. weaponName] and 'yes' or 'no'))
	props['has dex'] = (weapons['Dex ' .. weaponName] and weaponName ~= 'Furis') and 'yes' or 'no'
	props['has dex'] = (props['has dex'] == 'no' and weaponName == 'Afuris') and 'yes' or props['has dex']
	props['has sancti'] = weapons['Sancti ' .. weaponName] and 'yes' or 'no'
	props['has telos'] = weapons['Telos ' .. weaponName] and 'yes' or 'no'
	props['has rakta'] = weapons['Rakta ' .. weaponName] and 'yes' or 'no'
	props['has secura'] = weapons['Secura ' .. weaponName] and 'yes' or 'no'
	props['has synoid'] = weapons['Synoid ' .. weaponName] and 'yes' or 'no'
	props['has vaykor'] = weapons['Vaykor ' .. weaponName] and 'yes' or 'no'
	props['is origin'] = originCheck(weaponName) and 'yes' or 'no'
	props['mastery'] = Weapon.Mastery
	props['disposition'] = Weapon.Disposition
	props['polarity'] = GetPolarityString(Weapon)
	local smwResult = mw.smw.set(props)
    return smwResult and result or result .. smwResult.error
end

function p.buildAutobox(frame)
    local WeapName = frame.args ~= nil and frame.args[1] or frame
    local Weapon = p.getWeapon(WeapName)
    if(Weapon == nil) then
        return buildInfoboxRow("ERROR", "Weapon not found in [[Module:Weapons/data]]")
    end

    if(Weapon.Type == "Melee") then
        return p.buildMeleeAutobox(frame)
    else
        return p.buildGunAutobox(frame)
    end
end

function p.buildGunAutobox(frame)
    local WeapName = frame.args ~= nil and frame.args[1] or frame
    local Weapon = p.getWeapon(WeapName)
    if(Weapon == nil) then
        return buildInfoboxRow("ERROR", "Weapon not found in [[Module:Weapons/data]]")
    end
    local result = ""

    result = '\n|-\n| colspan="2" class="image" | [[File:'..getValue(Weapon, "Image", true)..'|220px]]<br/>'
    result = result..buildInfoboxCategory("详细信息")
    result = result..buildInfoboxRow("[[Mastery Rank|段位需求]]", getValue(Weapon, "Mastery"))
    result = result..buildInfoboxRow("武器槽位", trans.toChineseCat(getValue(Weapon, "Type")))
    result = result..buildInfoboxRow("武器类型", trans.toChineseCat(getValue(Weapon, "Class")))
    result = result..buildInfoboxRow("扳机类型", trans.toChineseCat(Weapon.Trigger))

    result = result..buildInfoboxCategory("功能")
    result = result..buildInfoboxRow("[[Ammo#Ammo Packs|弹药类型]]", trans.toChineseCat(Weapon.AmmoType), true)
    result = result..buildInfoboxRow("[[Noise Level|噪音等级]]", trans.toChineseCat(getValue(Weapon, "NoiseLevel", true)), true)
    result = result..buildInfoboxRow("[[Accuracy|精准度]]", getValue(Weapon, "Accuracy"), true)
    result = result..buildInfoboxRow("[[Zoom|瞄准变焦]]", Weapon.Zoom, true)
    result = result..buildInfoboxRow("[[Accuracy|子弹扩散]]", Weapon.Spread, true)
    result = result..buildInfoboxRow("[[Recoil|后坐力]]", Weapon.Recoil, true)
    result = result..buildInfoboxRow("[[Ammo#Magazine Capacity|弹匣容量]]", getValue(Weapon, "Magazine", false, true), nil)
    result = result..buildInfoboxRow("[[Ammo#Ammo Maximum|弹药上限]]", getValue(Weapon, "MaxAmmo", true, true), true)
    result = result..buildInfoboxRow("[[Reload|装填时间]]", getValue(Weapon, "Reload", false, true))
    result = result..buildInfoboxRow("[[Reload|装填速率]]", Weapon.RoundReload, nil, 2, " round<s>/sec")
    if(Weapon.Disposition ~= nil) then
    	result = result..buildInfoboxRow("[[Riven Mods#Disposition|裂罅倾向性]]", Icon._Dis(Weapon.Disposition, "Text"))
    end

    if(hasAttack(Weapon, "Normal")) then
    	result = result..makeAttackInfoboxRows(Weapon, Weapon, "普通攻击")
    end
    result = result..makeAttackInfoboxRows(Weapon, Weapon.AreaAttack, "范围攻击")
    result = result..makeAttackInfoboxRows(Weapon, Weapon.ChargeAttack, "[[Fire Rate#Charged Weapons|蓄力攻击]]")
    result = result..makeAttackInfoboxRows(Weapon, Weapon.SecondaryAttack, "特殊攻击")

    result = result..buildInfoboxCategory("杂项")
    if(Weapon.ZoomLevels ~= nil) then
        result = result..buildInfoboxRow("[[Sniper Rifle|变焦倍率]]", table.concat(Weap.ZoomLevels, "<br/>"))
    end
    result = result..buildInfoboxRow("[[Sniper Rifle|连击重置]]", Weapon.SniperComboReset)
    result = result..buildInfoboxRow("[[Sniper Rifle|最小连击数]]",Weapon.SniperComboMin)
    if(Weapon.SyndicateEffect ~= nil) then
        result = result..buildInfoboxRow("[[Syndicate Radial Effects|集团效果]]", "[["..trans.toChineseCI(Weapon.SyndicateEffect).."]]")
    end

    local augments = getAugments(Weapon)
    if(Shared.tableCount(augments) > 0) then
        local AugString = ""
        for i, Aug in pairs(augments) do
            if(i>1) then AugString = AugString.."<br/>" end
            AugString = AugString.."[["..trans.toChineseCI(Aug.Name).."]]"
        end
        result = result..buildInfoboxRow("[[Weapon Augment Mods|强化]]", AugString)
    end

    result = result..buildInfoboxRow("[[Polarity|极性]]", GetPolarityString(Weapon))

    local canPvP = (getValue(Weapon, "Conclave", true)) and "是" or "否"
    result = result..buildInfoboxRow("[[Conclave|武形秘仪]]可用", canPvP, true)

    if(Weapon.Users ~= nil) then
        local userString = ""
        --table.concat not working here because???
        --so doing it the hard way
        for i, User in pairs(Weapon.Users) do
            if(i>1) then userString = userString.."<br/>" end
            userString= userString..transWeaponUser(User)
        end
        result = result..buildInfoboxRow("武器使用者", userString)
    end
    result = result..buildInfoboxRow("发布时间", transReleaseUpdate(Weapon.Introduced))

    if(Weapon.Family ~= nil) then
        local FamilyString = ""
        local Family = getFamily(Weapon.Family)
        for i, Weap in pairs(Family) do
            if(Weap.Name ~= Weapon.Name) then
                if(string.len(FamilyString) > 0) then FamilyString = FamilyString.."<br/>" end
                FamilyString = FamilyString.."[["..trans.toChineseCI(Weap.Name).."]]"
            end
        end
        if(string.len(FamilyString) > 0) then
    result = result..buildInfoboxRow("相关武器", FamilyString)
        end
    end

    return result
end

function p.buildMeleeAutobox(frame)
    local WeapName = frame.args ~= nil and frame.args[1] or frame
    local Weapon = p.getWeapon(WeapName)
    if(Weapon == nil) then
        return buildInfoboxRow("ERROR", "Weapon not found in [[Module:Weapons/data]]")
    end
    local result = ""
    local imgFile = Weapon.Image ~= nil and Weapon.Image or "Panel.png"

    result = '\n|-\n| colspan="2" class="image" | [[File:'..imgFile..'|220px]]<br/>'
    result = result..buildInfoboxCategory("详细信息")
    result = result..buildInfoboxRow("[[Mastery Rank|段位需求]]", Weapon.Mastery)

    result = result..buildInfoboxRow("武器槽位", trans.toChineseCI(Weapon.Type))
    result = result..buildInfoboxRow("武器类型", trans.toChineseCI(Weapon.Class))

    result = result..buildInfoboxCategory("功能")
    if(Weapon.Bullet ~= nil) then
        result = result..buildInfoboxRow("[[Throwing Speed|飞行速度]]", Weapon.Bullet.Speed, true, 2, "&thinsp;米/秒")
        result = result..buildInfoboxRow("范围上限", Weapon.Bullet.Range, true, 2, " m")
    end
    result = result..buildInfoboxRow("[[Attack Speed|攻击速度]]", Weapon.FireRate, nil)
    if(Weapon.Disposition ~= nil) then
        result = result..buildInfoboxRow("[[Riven Mods#Disposition|裂罅倾向性]]", Icon._Dis(Weapon.Disposition, "Text"))
    end
    result = result..buildInfoboxCategory("普通攻击")
    local Physical = GetDamage(Weapon, "物理")
    if(Physical > 0) then
        result = result..buildInfoboxRow("[[Damage 2.0|物理伤害]]", Physical, nil, {2, 1})
        result = result..buildInfoboxRow(Icon._Proc("Impact", "Text", "white", nil, true), GetDamage(Weapon, "Impact"), true, {2, 1})
        result = result..buildInfoboxRow(Icon._Proc("Puncture", "Text", "white", nil, true), GetDamage(Weapon, "Puncture"), true, {2, 1})
        result = result..buildInfoboxRow(Icon._Proc("Slash", "Text", "white", nil, true), GetDamage(Weapon, "Slash"), true, {2, 1})
    end

    for element, damage in Shared.skpairs(Weapon.Damage) do
        if(element ~= "Impact" and element ~= "Puncture" and element ~= "Slash") then
            result = result..buildInfoboxRow(Icon._Proc(element, "Text", "white", nil, true), damage, nil, {2, 1})
        end
    end
    result = result..buildInfoboxRow("占比最高伤害 %", GetDamageBiasString(Weapon), true)

    result = result..buildInfoboxRow("[[Critical Hit#Critical Hit Chance|暴击几率]]", asPercent(Weapon.CritChance))
    result = result..buildInfoboxRow("[[Critical Hit#Critical Damage Multiplier|暴击倍率]]", asMultiplier(Weapon.CritMultiplier))
    result = result..buildInfoboxRow("[[Status Chance|触发几率]]", asPercent(Weapon.StatusChance))

    result = result..makeAttackInfoboxRows(Weapon, Weapon.ThrowAttack, "投掷攻击")
    result = result..makeAttackInfoboxRows(Weapon, Weapon.ChargedThrowAttack, "蓄力投掷攻击")

    if(Weapon.JumpAttack ~= nil)then
        result = result..buildInfoboxCategory("[[Melee 2.0#Slam Attack|震地攻击]]")
        if(Weapon.JumpElement ~= nil) then
            result = result..buildInfoboxRow(Icon._Proc(Weapon.JumpElement, "text", "white", nil, true), Weapon.JumpAttack)
        else
            result = result..buildInfoboxRow("[[Damage 2.0|物理伤害]]", Weapon.JumpAttack)
        end
        result = result..buildInfoboxRow("打击范围", Weapon.JumpRadius, nil, 2, "m")
    end

    if(Weapon.SlideAttack ~= nil)then
        result = result..buildInfoboxCategory("[[Melee 2.0#Slide Attack|滑行攻击]]")
        if(Weapon.SlideElement ~= nil) then
            result = result..buildInfoboxRow(Icon._Proc(Weapon.SlideElement, "text", "white", nil, true), Weapon.SlideAttack)
        else
            result = result..buildInfoboxRow("[[Damage 2.0|物理伤害]]", Weapon.SlideAttack)
        end
    end

    if(Weapon.WallAttack ~= nil)then
        result = result..buildInfoboxCategory("[[Melee 2.0#Wall Attack|蹬墙攻击]]")
        if(Weapon.WallElement ~= nil) then
            result = result..buildInfoboxRow(Icon._Proc(Weapon.WallElement, "text", "white", nil, true), Weapon.WallAttack)
        else
            result = result..buildInfoboxRow("[[Damage 2.0|物理伤害]]", Weapon.WallAttack)
        end
    end

    result = result..buildInfoboxCategory("杂项")
    result = result..buildInfoboxRow("[[Melee 2.0#Ground Finisher|处决伤害]]", Weapon.FinisherDamage, true)
    result = result..buildInfoboxRow("失衡", Weapon.Stagger)

    local augments = getAugments(Weapon)
    if(Shared.tableCount(augments) > 0) then
        local AugString = ""
        for i, Aug in pairs(augments) do
            if(i>1) then AugString = AugString.."<br/>" end
            AugString = AugString.."[["..Aug.Name.."]]"
        end
        result = result..buildInfoboxRow("[[Weapon Augment Mods|强化]]", AugString)
    end

    result = result..buildInfoboxRow("[[Polarity|极性]]", GetPolarityString(Weapon))
    result = result..buildInfoboxRow("[[Stance|架式]]", getWeaponStanceList(Weapon))
    if(Weapon.StancePolarity ~= nil) then
        result = result..buildInfoboxRow("[[Stance|架式]]&thinsp;[[Polarity|极性]]", Icon._Pol(Weapon.StancePolarity))
    end

    local canPvP = (getValue(Weapon, "Conclave", true)) and "是" or "否"
    result = result..buildInfoboxRow("[[Conclave|武形秘仪]]可用", canPvP, true)
    if(Weapon.Users ~= nil) then
        local userString = ""
        --table.concat not working here because???
        --so doing it the hard way
        for i, User in pairs(Weapon.Users) do
            if(i>1) then userString = userString.."<br/>" end
            userString= userString..transWeaponUser(User)
        end
        result = result..buildInfoboxRow("武器使用者", userString)
    end
    result = result..buildInfoboxRow("发布时间", transReleaseUpdate(Weapon.Introduced))

    if(Weapon.Family ~= nil) then
        local FamilyString = ""
        local Family = getFamily(Weapon.Family)
        for i, Weap in pairs(Family) do
            if(Weap.Name ~= Weapon.Name) then
                if(string.len(FamilyString) > 0) then FamilyString = FamilyString.."<br/>" end
                FamilyString = FamilyString.."[["..Weap.Name.."]]"
            end
        end
        if(string.len(FamilyString) > 0) then
    result = result..buildInfoboxRow("相关武器", FamilyString)
        end
    end

    return result
end

function p.buildAugmentTable(frame)
    local result = ""
    result = result..'\n{|class="listtable sortable" style="width:100%;"'
    result = result..'\n|-'
    result = result..'\n! 名称'
    result = result..'\n! 类型'
    result = result..'\n! 来源'
    result = result..'\n! 武器'

    for i, Augment in pairs(WeaponData["Augments"]) do
        local thisStr = "\n|-"
        thisStr = thisStr.."\n| [["..Augment.Name..'|'..trans.toChineseCI(Augment.Name).."]]"
        thisStr = thisStr.."\n| "..trans.toChineseCI(Augment.Category)
        thisStr = thisStr.."\n| [["..Augment.Source..'|'..trans.toChineseCI(Augment.Source).."]]"
        thisStr = thisStr.."\n| "
        for i, weap in pairs(Augment.Weapons) do
            if(i>1) then thisStr = thisStr.."<br/>" end
            thisStr = thisStr.."[["..weap..'|'..trans.toChineseCI(weap).."]]"
        end
        result = result..thisStr
    end

    result = result..'\n|}'
    return result 
end

function noNil(val, default)
    if(val ~= nil) then
        return val
    else
        if(default ~= nil) then
            return default
        else
            return ""
        end
    end
end

function isSingleDamage(Attack)
	if(Attack.Damage ~= nil and Shared.tableCount(Attack.Damage) == 1) then
		return true
    else
        return false
    end
end

function getSingleDamge(Attack)
	local singleElement, singleDamage
	if isSingleDamage(Attack) then
		for Element, Dmg in pairs(Attack.Damage) do
			singleElement = Element
			singleDamage = Dmg
		end
	end
	return singleElement, singleDamage
end

function p.buildDamageTypeTable(frame)
    local DamageType = frame.args ~= nil and frame.args[1] or frame
    local attackList = {'Normal', 'Charge', 'Secondary', 'Area', 'SecondaryArea', 'Throw', 'ChargedThrow'}
    local specialAttackList = {'Jump', 'Wall', 'Slide'}
    local WeapArray = WeaponData["Weapons"]
    local procString = Icon._Proc(DamageType,'text')
    local procShort = Icon._Proc(DamageType)
    local result = ""
    local tHeader = '{|class = "listtable sortable filterable" style="margin:auto;"'
    tHeader = tHeader..'\n|-'
    tHeader = tHeader..'\n! class="filterable-head" | 名称'
    tHeader = tHeader..'\n! class="filterable-head" | 类型'
    tHeader = tHeader..'\n! class="filterable-head" | 种类'
    tHeader = tHeader..'\n! class="filterable-head" | 模式'
    tHeader = tHeader..'\n!'..procString
    tHeader = tHeader..'\n!'..procShort..'%'
    local tRows = ""
    for i, Weapon in pairs(WeapArray) do
    	local Dmg, Element, attackName, isSpecial
    	for i, v in ipairs(attackList) do
        	if (hasAttack(Weapon, v)) then
            	Dmg, Element = GetDamageBias(getAttack(Weapon, v))
            	Element = getSingleDamge(getAttack(Weapon, v)) or Element
            	if (Element == DamageType) then
            		attackName = v
            		isSpecial = false
            		break
            	end
            end
        end
        if (not attackName) then
        	for i, v in ipairs(specialAttackList) do
        		if (DamageType == getValue(Weapon, v .. 'Element')) then
        			attackName = v .. 'Attack'
        			isSpecial = true
        			break
        		end
        	end
        end
        if (attackName) then
        	local thisRow = '\n|-\n|'
	        thisRow = thisRow.."[["..Weapon.Name.."|"..trans.toChineseCI(Weapon.Name).."]]||"..transTerm(Weapon.Type).."|| "..getValue(Weapon, "Class", true, true)
	        if (isSpecial) then
	            thisRow = thisRow.."||"..transTerm(attackName)..'||'..getValue(Weapon, attackName).."||"..'100% '..procString
	        else
	            thisRow = thisRow.."||"..(getValue(Weapon, {attackName, 'AttackName'}) or transTerm(attackName))..'||'..getValue(Weapon, {attackName, DamageType}).."||"..(getValue(Weapon, {attackName, "DamageBias"}, true) or ('100% '..procString))
	        end

	        tRows = tRows..thisRow
        end
    end
    result = tHeader..tRows.."\n|}"
    return result
end

function p.buildWeaponByMasteryRank(frame)
    local MasteryRank
    local MRTable = {}
    for i, Weapon in Shared.skpairs(WeaponData["Weapons"]) do
        if(MRTable[Weapon.Mastery] == nil) then
            MRTable[Weapon.Mastery] = {}
        end
        if(MRTable[Weapon.Mastery][Weapon.Type] == nil) then
            MRTable[Weapon.Mastery][Weapon.Type] = {}
        end
        table.insert(MRTable[Weapon.Mastery][Weapon.Type], Weapon)
    end
    local result = ""
    for i, TypeTable in Shared.skpairs(MRTable) do
        local thisTable = "\n==Mastery Rank "..i.." Required=="
        if(i == 0) then
            thisTable = "==No Mastery Rank Required=="
        end
        thisTable = thisTable..'\n{| style="width:80%;margin:auto"'
        thisTable = thisTable..'\n|-\n| style="vertical-align:top;width:33%;" |'
        if(TypeTable["Primary"] ~= nil and Shared.tableCount(TypeTable["Primary"]) > 0) then
            thisTable = thisTable.."\n===Primary==="
            for i, Weap in Shared.skpairs(TypeTable["Primary"]) do
                thisTable = thisTable.."\n* [["..Weap.Name.."]]"
            end
        end

        thisTable = thisTable..'\n| style="vertical-align:top;width:33%;" |'
        if(TypeTable["Secondary"] ~= nil and Shared.tableCount(TypeTable["Secondary"]) > 0) then
            thisTable = thisTable.."\n===Secondary==="
            for i, Weap in Shared.skpairs(TypeTable["Secondary"]) do
                thisTable = thisTable.."\n* [["..Weap.Name.."]]"
            end
        end

        thisTable = thisTable..'\n| style="vertical-align:top;width:33%;" |'
        if(TypeTable["Melee"] ~= nil and Shared.tableCount(TypeTable["Melee"]) > 0) then
            thisTable = thisTable.."\n===Melee==="
            for i, Weap in Shared.skpairs(TypeTable["Melee"]) do
                thisTable = thisTable.."\n* [["..Weap.Name.."]]"
            end
        end
        thisTable = thisTable.."\n|}"
        result = result..thisTable
    end
    return result
end

function p.getConclaveList(frame)
    local WeaponType = frame.args[1]

    local weapArray = p.getWeapons(function(x) 
                                    if(x.Type ~= nil and x.Conclave ~= nil) then
                                        return x.Type == WeaponType and x.Conclave
                                    else
                                        return false
                                    end
                                end)

    local result = ""
    for i, Weap in Shared.skpairs(weapArray) do
        result = result..'\n* '.."[["..trans.toChineseCI(Weap.Name).."]]"
    end
    return result
end

local function BuildCompRow(Head, Weapon, UseCompDisplay)
    --User:Falterfire 6/12/18 - Adding new Comparison Display functionality
    --                          Toggled with a variable, which is false if not specified
    if UseCompDisplay == nil then UseCompDisplay = false end
    local styleString = ""--"border: 1px solid lightgray;"
    local td = ''
    local result = ''
    local ValNameZ = nil
    local ValName = nil

    --User:Faltefire 6/12/18 - By default, use old version of code
    if not UseCompDisplay or Weapon.ComparisonDisplay == nil then
        local attName = ""
        if(hasAttack(Weapon, "Charge")) then
            attName = "Charge"
        elseif(hasAttack(Weapon, "Normal")) then
            attName = "Normal"
        else
            return ""
        end

    	result = '\n|-\n|'

        for i, Hline in ipairs(Head) do
            ValName = Hline[1]

            if(type(ValName) == "table" and ValName[1]=="default") then
                ValName = {attName, ValName[2]}
            elseif(type(ValName) == "table") then 
                ValName = {ValName[1], ValName[2]}
            end

            if(i == 1) then td = '' else td='||' end
            if(getValue(Weapon, ValName)~=nil) then
                --Add a data sort value if requested
                if(Hline[2]) then 
                    result = result..td..'data-sort-value="'..getValue(Weapon, ValName)..'" style="'..styleString..'"|'..getValue(Weapon, ValName, true, true, true)
                else
                	local displayVal = getValue(Weapon, ValName, true, true, true)
                	if ValName == 'Name' then
                		displayVal = '[[' .. displayVal .. '|' .. trans.toChineseCI(displayVal) .. ']]'
                	end
                    result = result..td..'style="'..styleString..'"|'..displayVal
                end
            else 
                result = result..td..'style = "'..styleString..'"|'.."N/A" 
            end
        end
    else
        --User:Faltefire 6/12/18 - Swap to new version if ComparisonDisplay is set for this weapon and UseCompDisplay is true
        for i, row in pairs(Weapon.ComparisonDisplay) do
            local attCount = Shared.tableCount(row.Attacks)
            if attCount > 0 then
                local rowText = '\n|-\n|'
                local attName = row.Attacks[1]
                for j, Hline in ipairs(Head) do
                    ValName = Hline[1]
                    local KeyName = ''

                    --If we're using the ComparisonDisplay, we're overriding the attempt to shunt to a different attack
                    --So always use attName + ValName, with one two exceptions: Damage and Name are overridden
                    if(type(ValName) == "table") then
                        ValName = {attName, ValName[2]}
                        KeyName = string.upper(ValName[2])
                    else
                        KeyName = string.upper(ValName)
                    end

                    if(j == 1) then td = '' else td='||' end
                    if KeyName == 'NAME' then
                        local rowName = string.gsub(row.Name, "%[NAME%]", Weapon.Name)
                        --Replace the default name with the name from ComparisonDisplay
                        rowText = rowText..td..'style="'..styleString..'"|[['..Weapon.Name..'|'..rowName..']]'
                    elseif KeyName == 'DAMAGE' then
                        --For damage, go with the listed attack
                        if attCount == 1 then
                           rowText = rowText..td..'data-sort-value="'..getValue(Weapon, {attName, "Damage"})..'" style="'..styleString..'"|'..getValue(Weapon, {attName, "Damage"}, true, true, true)
                        else
                            --If multiple attacks are listed, show the combined damage
                            local attDmg = 0
                            for k, att in pairs(row.Attacks) do
                                mw.log(att)
                                attDmg = attDmg + getValue(Weapon, {att, "Damage"})
                            end
                            rowText = rowText..td..'data-sort-value="'..attDmg..'" style="'..styleString..'"|'..attDmg
                        end
                    else
                        if(getValue(Weapon, ValName) ~= nil) then
                            --Add a data sort value if requested
                            if(Hline[2]) then 
                                rowText = rowText..td..'data-sort-value="'..getValue(Weapon, ValName)..'" style="'..styleString..'"|'..getValue(Weapon, ValName, true, true, true)
                            else
                                rowText = rowText..td..'style="'..styleString..'"|'..getValue(Weapon, ValName, true, true, true)
                            end
                        else 
                            rowText = rowText..td..'style = "'..styleString..'"|'.."N/A" 
                        end
                    end
                end

                result = result..rowText
            end
        end
    end

    return result
end

local function BuildCompTable(Head, Weapons, UseCompDisplay)
    local styleString = "border: 1px solid black;border-collapse: collapse;"
    local tHeader = ""
    tHeader = tHeader..'\n{| cellpadding="1" cellspacing="0" class="listtable sortable" style="font-size:11px;"'
	for i, Hline in ipairs(Head) do
		if(Hline[2] == true) then
			tHeader = tHeader..'\n! data-sort-type="number" style="'..styleString..'"|'..Hline[3]..''
		else
			tHeader = tHeader..'\n! style="'..styleString..'"|'..Hline[3]..'' 
		end
	end
--	mw.log(tHeader)

    local tRows = ""
    for i, Weap in pairs(Weapons) do
        rowStr = BuildCompRow(Head, Weap, UseCompDisplay)
        tRows = tRows..rowStr
    end
--    mw.log(tRows)
    return  tHeader..tRows.."\n|}[[分类:自动生成的对照表]]"
end

function p.getCompTableGuns(frame)
    local Catt = frame.args ~= nil and frame.args[1]
    local Type = frame.args ~= nil and frame.args[2] or nil
        if(Type == "All") then Type = nil end
    local WeapArray = {}
    if(Catt == "Primary") then WeapArray = p.getWeapons(function(x) 
                                if(getValue(x, "Type", true) == "Primary") then
                                    if(Type ~= nil) then return getPrimaryCategory(x) == Type else return true end
                                end
                                    return false
                                end)
    elseif(Catt == "Secondary") then WeapArray = p.getWeapons(function(x) 
                                if(getValue(x, "Type", true) == "Secondary") then
                                    if(Type ~= nil) then return getSecondaryCategory(x) == Type else return true end
                                end
                                    return false
                                end)
	elseif(Catt == "Sentinel") then WeapArray = p.getWeapons(function(x) 
                                    return getValue(x, "Type", true) == "Sentinel"
                                    end)
    else return "\n Error : Wrong Class (use Primary, Secondary, or Sentinel) [[Category:Invalid Comp Table]]"
    end

	local Head={{"Name",false,"名称"}}
	 -- better if Name is always the first column !!!
	table.insert(Head,{"Trigger",false,"[[Fire_Rate|扳机类型]]"})
	table.insert(Head,{{"default","Damage"},true,"[[Damage 2.0|伤害]]"})
	table.insert(Head,{{"default", "CritChance"},true,"[[Critical_Hit|暴击几率]]"})
	table.insert(Head,{{"default", "CritMultiplier"},true,"[[Critical_Hit|暴击伤害]]"})
	table.insert(Head,{{"default", "StatusChance"},true,"[[Status_Effect|触发几率]]"})
	table.insert(Head,{{"default","BulletType"},false,"抛射物类型"})   
	table.insert(Head,{{"default", "FireRate"},true,"[[Fire Rate|射速]]"})
	table.insert(Head,{"Magazine",true,"[[Ammo|弹匣容量]]"})
	table.insert(Head,{"Reload",true,"[[Reload_Speed|装填时间]]"})
	table.insert(Head,{"Mastery",true,"[[Mastery_Rank|段位]]"})
	table.insert(Head,{"Disposition",true,"[[Riven Mods#Disposition|裂罅倾向性]]"})

    return BuildCompTable(Head, WeapArray, true)
end

function p.getCompTableSpeedGuns(frame)
    local Catt = frame.args ~= nil and frame.args[1]
    local Type = frame.args ~= nil and frame.args[2] or nil
        if(Type == "All") then Type = nil end
    local WeapArray = {}
    if(Catt == "Primary") then WeapArray = p.getWeapons(function(x) 
                                if(getValue(x, "Type", true) == "Primary") then
                                    if(Type ~= nil) then return getPrimaryCategory(x) == Type else return true end
                                end
                                    return false
                                end)
    elseif(Catt == "Secondary") then WeapArray = p.getWeapons(function(x) 
                                if(getValue(x, "Type", true) == "Secondary") then
                                    if(Type ~= nil) then return getSecondaryCategory(x) == Type else return true end
                                end
                                    return false
                                end)
	elseif(Catt == "Sentinel") then WeapArray = p.getWeapons(function(x) 
                                    return getValue(x, "Type", true) == "Sentinel"
                                    end)
	elseif(Catt == "Arch-Gun") then WeapArray = p.getWeapons(function(x) 
                                    return getValue(x, "Type", true) == "Arch-Gun"
                                    end)
    else return "\n Error : Wrong Class (use Primary, Secondary, Sentinel, or Arch-Gun) [[Category:Invalid Comp Table]]"
    end
    -- special sorting for projectile weapons
    local WeapArray2 = {}
    for k, Weapon in ipairs(WeapArray) do
        local attName = ""
        if(hasAttack(Weapon, "Charge")) then
            attName = "Charge"
        elseif(hasAttack(Weapon, "Normal")) then
            attName = "Normal"
        else
            return ""
        end
        if(getValue(Weapon,{attName, "BulletType"}, false) == "Projectile") then
            table.insert(WeapArray2, Weapon)
        elseif(getValue(Weapon,{"Area", "BulletType"}, false) == "Projectile") then
            table.insert(WeapArray2, Weapon)
        elseif(getValue(Weapon,{"Secondary", "BulletType"}, false) == "Projectile") then
            table.insert(WeapArray2, Weapon)
        elseif (getValue(Weapon,{attName, "BulletType"}, false) == "Thrown") then
            table.insert(WeapArray2, Weapon)
        end
    end

	local Head={{"Name",false,"名称"}}
	 -- better if Name is always the first column !!!
	table.insert(Head,{"Class",false,"类型"})
	table.insert(Head,{{"Normal","PROJECTILESPEED"},true,"飞行速度"})
	table.insert(Head,{{"Charge","PROJECTILESPEED"},true,"蓄力后飞行速度"})
	table.insert(Head,{"SPECIALFSPEED",true,"次要开火模式 / 特殊"})

    return BuildCompTable(Head,WeapArray2)
end

function p.getCompTableSpeedMelees(frame)
    local Catt = frame.args ~= nil and frame.args[1]
    local Type = frame.args ~= nil and frame.args[2] or nil
    if(Type == "All") then Type = nil end
    local WeapArray = {}
    if(Catt == "Melee") then WeapArray = getMeleeWeapons(Type)
	                                local addClass = Type == nil or Shared.contains(Type, ",")
	elseif(Catt == "Arch-Melee") then WeapArray = p.getWeapons(function(x) 
                                    return getValue(x, "Type", true) == "Arch-Melee"
                                end)
    else return "\n Error : Wrong Class (use Melee or Arch-Melee) [[Category:Invalid Comp Table]]"
    end
    -- special sorting for projectile weapons ONLY WORKS FOR GLAIVE TYPE MELEE WEAPONS !!!
    local WeapArray2 = {}
    for k, Weapon in ipairs(WeapArray) do
        if (getValue(Weapon,{"Normal", "BulletType"}, false) == "Thrown") then
            table.insert(WeapArray2, Weapon)
        end
    end

	local Head={{"Name",false,"名称"}}
	 -- better if Name is always the first column !!!
	table.insert(Head,{{"Normal","PROJECTILESPEED"},true,"飞行速度"})
	table.insert(Head,{"SPECIALFSPEED",true,"特殊"}) 

    return BuildCompTable(Head,WeapArray2)
end

function p.weaponTooltipText(frame)
    local weapName = frame.args ~= nil and frame.args[1]
    local conclave = frame.args["Conclave"] == "true" and true
    local conclaveParam = ''
    local linkText = ''
    local namespace = ''

    local weap = checkWeapon(weap, weapName, conclave)
    if weap == nil and conclave == true then
        weap = checkWeapon(weap, weapName)
    end

    if weap ~= nil or weapName == "Dark Split-Sword" then
        local link = p.getLink(weapName, weap)

        if conclave == true then
            conclaveParam = ' data-param2="true"'
            if weap.Conclave == true then
                namespace = 'Conclave:'
            end
        end

        if link then
            linkText = '[['..namespace..link..'|'..trans.toChineseCI(weapName)..']]'
        else
            linkText = '[['..namespace..weapName..'|'..trans.toChineseCI(weapName)..']]'
        end

        if link ~= false then
            local image = ''
            if weapName == "Dark Split-Sword" then
                local tempWeap = p.getWeapon("Dark Split-Sword (Dual Swords)")
                image = getValue(tempWeap,"Image",true)
            else
                image = getValue(weap,"Image",true)
            end
            return '<span class="weapon-tooltip" data-param="'..weapName..'"'..conclaveParam..' style="white-space:pre">'..'[[File:'..image..'|x19px|link='..namespace..link..']] '..linkText..'</span>'
        else
            return '<span style="color:red;">{{[[Template:Weapon|Weapon]]}}</span> "'..weapName..'" not found[[Category:Weapon '..'Tooltip error]]'
        end
    else
        return '<span style="color:red;">{{[[Template:Weapon|Weapon]]}}</span> "'..weapName..'" not found[[Category:Weapon '..'Tooltip error]]'
    end
end

function p.weaponTooltip(frame)
    local weapName = frame.args ~= nil and frame.args[1]
    local conclave = frame.args[2] == "true" and true
    --there's no "Dark Split-Sword" in m:weapons/data -> setting name to dual sword variant
    if weapName == 'Dark Split-Sword' then
        weapName = 'Dark Split-Sword (Dual Swords)'
    end

    local A2Name = nil
    local A2Value = nil
    local C1Name = nil
    local C1Value = nil
    local C1Toggle = nil
    local C2Name = nil
    local C2Value = nil
    local D1Name = nil
    local D1Value = nil
    local D1Value2 = nil
    local titleText = ''
    local hasCharged = false
    local attackType = 'Normal'
    local attack = nil
    local attackText = ''
    local space = '&nbsp;'
    local attackBiasText = ''

    if weapName == nil then
        return nil
    end

    local Weapon = nil
    local cAvailability = false
    if conclave then
        Weapon = p.getConclaveWeapon(weapName)
        if Weapon ~= nil then
            cAvailability = getValue(Weapon, "Conclave", true, false, false)
        end
        if not cAvailability then
            Weapon = p.getWeapon(weapName)
        end
    else
        Weapon = p.getWeapon(weapName)
    end

    local conclaveNotice = ''
    if conclave and cAvailability == false then
        conclaveNotice = '\n{| class="Data" style="font-size:10px; white-space:normal;"\n|-\n|Note: Not available in Conclave, displaying Cooperative stats and Cooperative Link.\n|}'
    end

    if Weapon == nil then
        return 'No weapon '..weapName..' found.'
    end

    local function Value(valueName, asString, forTable, giveDefault)
        --note that the three last parameters aren't in the same order in functions "Value" and "getValue"
        if(asString == nil) then asString = false end
        if(forTable == nil) then forTable = false end
        if(giveDefault == nil) then giveDefault = true end
        return getValue(Weapon, valueName, giveDefault, asString, forTable)
    end

    local function whitePols(valueName)
        local pols = Value(valueName)
        local polIcon = ''

        if type(pols) == "table" then
            local i = 0
            if pols[1] == nil then
                polIcon = 'None'
                return polIcon
            else
                while pols[i+1] ~= nil do
                    i = i + 1
                end
                for j = 1, i do
                    polIcon = polIcon..Icon._Pol(pols[j],'white','x16')
                end
                return polIcon
            end
        elseif pols ~= nil and type(pols) == "string" and pols ~= "None" then
            return Icon._Pol(pols,'white','x16')
        end
        return 'None'
    end

    --for weapons which have no max ammo
    local ammoException = nil
    if Value("MaxAmmo") == nil then
        ammoException = true
    end

    local isMelee = p.isMelee(Weapon) == "yes"

    local chargedExceptions = {"Tiberon Prime", "Kohm", "Kohmak", "Twin Kohmak", "Stug"} -- weapons which have a charged attack but normal attack values are used for the tooltip
    local secondaryExceptions = {"Penta", "Carmine Penta", "Secura Penta"}
    local areaExceptions = {"Ogris", "Zarr", "Tonkor", "Kulstar", "Angstrum", "Prisma Angstrum"}
    local secondaryAreaExceptions ={"Lenz"}

    if isMelee ~= true then
        if Shared.contains(chargedExceptions, weapName) ~= true and Value({"Charge","AttackName"}) ~= nil then
            hasCharged = true
            attackType = 'Charge'
        end
        if Shared.contains(secondaryExceptions, weapName) then
            attackType = 'Secondary'
        elseif Shared.contains(areaExceptions, weapName) then
            attackType = 'Area'
        elseif Shared.contains(secondaryAreaExceptions, weapName) then
            attackType = 'SecondaryArea'
        end
    end

    attack = getAttack(Weapon, attackType)
    local count = 0
    for type, dmg in Shared.skpairs(attack.Damage) do
        if count == 0 then
            attackText = '\n| style=\"padding-right:2px;\" |'..Icon._Proc(type,'','white','x16')..space..dmg
            count = count + 1
        else
            attackText = attackText..'|| style=\"padding-right:4px;\" |'..Icon._Proc(type,'','white','x16')..space..dmg
        end
    end

    if(hasMultipleTypes(attack)) then
        attackBiasText = '\n| colspan=4 |'..GetDamageString(attack, nil).." ("..GetDamageBiasString(attack,nil,'',nil,'white','x16')..")"
    end

    local mRankIcon = ''
    local mRank = Value("Mastery",false,false,false)
    local mRankIconLoc = 'top:4px; left:9.5px;'
    if mRank then
        if string.len(mRank) >= 2 then
            mRankIconLoc = 'top:4px; left:5px;'
        end
        mRankIcon = '<div style="position:absolute;top:6px; left:4px; color:white; font-size:16px; font-weight:bold; text-shadow: 0 0 1px #0D1B1C, 0 0 4px #0D1B1C, 1px 1px 2px #0D1B1C, -1px 1px 2px #0D1B1C, 1px -1px 2px #0D1B1C, -1px -1px 2px #0D1B1C;">[[File:MasteryAffinity64.png|28px]]<div style="position:absolute;'..mRankIconLoc..'">'..mRank..'</div></div>'
    end

    local dispoIcon = ''
    local dispoVal = Value("Disposition5",false,false,false)
    if dispoVal then
        dispoIcon = '<div style="position:absolute;top:6px; right:4px; color:white; font-size:16px; font-weight:bold; text-shadow: 0 0 1px #0D1B1C, 0 0 4px #0D1B1C, 1px 1px 2px #0D1B1C, -1px 1px 2px #0D1B1C, 1px -1px 2px #0D1B1C, -1px -1px 2px #0D1B1C;">[[File:RivenIcon64.png|28px]]<div style="position:absolute;top:3.5px; right:9.5px;">'..dispoVal..'</div></div>'
    end

    if isMelee == true then
        A2Name = '类型'
        A2Value = 'Class'
        C1Name = '攻速'
        C1Value = 'FireRate'
        C1Toggle = true
        C2Name = '滑行伤害'
        C2Value = 'SlideAttack'
        D1Name = '极性'
        D1Value = 'Polarities'
        D1Value2 = 'StancePolarity'
    else
        A2Name = '扳机'
        A2Value = 'Trigger'
        if hasCharged == true then
            C1Name = 'Charge Time'
            if weapName == "Staticor" then
                C1Value = {'Area','ChargeTime'}
            else
                C1Value = {'Charge','ChargeTime'}
            end
            C1Toggle = true
        else
            C1Name = 'Fire Rate'
            C1Value = 'FireRate'
        end
        C2Name = '噪音'
        C2Value = 'NoiseLevel'
        D1Name = '极性'
        D1Value = 'Polarities'
    end

    local function Link(linkName)
        local spanStart = '<span class=\"LinkText\">'
        local spanEnd = '</span>'
        return spanStart..linkName..spanEnd
    end

    local zeroPadding = '\n| style=\"padding:0px;\" |'
    local newRow = '\n|-'
    local spacer = '\n| class=\"Spacer\" |'
    local halfTable = '\n| class=\"TableHalf\" |'
    local dataText = '\n{| class=\"Data\" style=\"font-size:12px;\"'
    local dataTextCenter = '\n{| class=\"Data\" style=\"font-size:12px; text-align:center;\"'
    local tableEnd = '\n|}'

    local Type = ''
    local tType = Value("Type")
    if tType == "Arch-Gun (Atmosphere)" then
        Type = "Arch-Gun (Atmo)"
    else
        Type = tType
    end

    local image = '\n| class=\"Image\" style=\"height:120px;\" | <div style="position:relative; z-index:2;">[[File:'..Value("Image")..'|160px]]</div>'

    --creating the table
    local result = '<div style="position:relative;">\n{| class=\"Sub\"'..newRow..image..mRankIcon..dispoIcon..newRow..spacer..newRow..zeroPadding
    result = result..dataText..newRow
    result = result..halfTable..Link("Slot")..space..Type..halfTable..Link(A2Name)..space..Value(A2Value)..tableEnd
    result = result..newRow..spacer..titleText..newRow..zeroPadding
    result = result..dataTextCenter..newRow..attackText
    if(attackBiasText ~= '') then
        result = result..newRow..attackBiasText
    end
    result = result..tableEnd
    result = result..newRow..spacer..newRow..zeroPadding..dataText..newRow..halfTable..Link("Crit")..space..Value("CritChance",true)..' | '..Value("CritMultiplier",true)..halfTable..Link("Status")..space..Value("StatusChance",true)
    result = result..newRow..halfTable..Link(C1Name)..space..Value(C1Value,C1Toggle)..halfTable..Link(C2Name)..space..Value(C2Value)
    --if not melee and not fishing spear => reload and ammo stats
    if not isMelee and Weapon.Type ~= "Gear" then
        result = result..newRow..halfTable..Link("Reload")..space..Value("Reload", true, true)..halfTable..Link("Ammo")..space..Value("Magazine")
        --if has max ammo => add max ammo stat
        if ammoException == nil then
            result = result..'&thinsp;/&thinsp;'..Value("MaxAmmo")
        end
        result = result..newRow..'\n| style=\"text-align:center;\" colspan=2 |'..Link(D1Name)..space..whitePols(D1Value)
    elseif isMelee then
        result = result..newRow..'\n| style=\"text-align:center;\" colspan=2 |'..Link(D1Name)..space..whitePols(D1Value2)..' | '..whitePols(D1Value)
    end
    result = result..tableEnd..conclaveNotice..tableEnd..'\n</div>'

    return result
end

function p.getWeaponReplaceList(frame)
    --local Type = frame.args ~= nil and frame.args[1] or frame
    local fullList = {}
    local primaries = {}
    local secondaries = {}
    local melees = {}
    local archGuns = {}
    local archMelees = {}
    local theRest ={}

    local avoidNames ={'Exalted Blade (Umbra)','Corvas (Atmosphere)','Cyngas (Atmosphere)','Dargyn','Dual Decurion (Atmosphere)','Fluctus (Atmosphere)','Grattler (Atmosphere)','Imperator (Atmosphere)','Imperator Vandal (Atmosphere)','Phaedra (Atmosphere)','Rampart','Velocitus (Atmosphere)'}

    local function addToList(name,link,list)
        if link == nil then
            link = name
        end
        --local 6s = '      '
        --local 8s = '        '
        local temp = '      <Replacement>\n        <Find>\[\['..link..']]</Find>\n        <Replace>{{Weapon|'..name..'}}</Replace>\n        <Comment />\n        <IsRegex>false</IsRegex>\n        <Enabled>true</Enabled>\n         <Minor>false</Minor>\n        <BeforeOrAfter>false</BeforeOrAfter>\n        <RegularExpressionOptions>IgnoreCase</RegularExpressionOptions>\n      </Replacement>'
        return table.insert(list,temp)
    end

    for i, val in Shared.skpairs(WeaponData["Weapons"]) do
        if not Shared.contains(avoidNames,val.Name) then

            if val.Type == "Primary" then
                addToList(val.Name,val.Link,primaries)
            elseif val.Type == "Secondary" then
                addToList(val.Name,val.Link,secondaries)
            elseif val.Type == "Melee" then
                addToList(val.Name,val.Link,melees)
            elseif val.Type == "Arch-Gun" then
                addToList(val.Name,val.Link,archGuns)
            elseif val.Type == "Arch-Melee" then
                addToList(val.Name,val.Link,archMelees)
            else
                addToList(val.Name,val.Link,theRest)
            end
        end
    end

    table.insert(fullList,table.concat(primaries,'\n'))
    table.insert(fullList,table.concat(secondaries,'\n'))
    table.insert(fullList,table.concat(melees,'\n'))
    table.insert(fullList,table.concat(archGuns,'\n'))
    table.insert(fullList,table.concat(archMelees,'\n'))
    table.insert(fullList,table.concat(theRest,'\n'))

    return table.concat(fullList, "\n")
end

--Runs a bunch of things to quickly check if anything broke
function p.checkForBugs(frame)
    return p.buildComparison({args = {"Lato", "Lato Prime"}})..p.buildComparison({args = {"Glaive", "Glaive Prime"}})..p.buildAutobox("Dread")..p.buildAutobox("Cerata")
end

return p
