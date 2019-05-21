--This will eventually contain data for various weapons
--For use in automating assorted wiki functions and to reduce the number of updates needed
-- • 

local p = {}

local WeaponData = mw.loadData( 'Module:Weapons/data' )
local ConclaveData = mw.loadData( 'Module:Weapons/Conclave/data' )
local Icon = require( "Module:Icon" )
local Shared = require( "Module:Shared" )
local Elements = {"Impact", "Puncture", "Slash", "Heat", "Cold", "Toxin", "Electricity", "Blast", "Corrosive", "Radiation", "Magnetic", "Gas", "Viral"}
local Physical = {"Impact", "Puncture", "Slash"}
local UseDefaultList = {"NOISELEVEL", "AMMOTYPE", "MAXAMMO", "DISPOSITION", "CHANNELMULT", "HEADSHOTMULTIPLIER"}
local VariantList = {"Prime", "Prisma", "Wraith", "Vandal", "Vaykor", "Synoid", "Telos", "Secura", "Sancti", "Rakta", "Mara", "MK1"}

function p.doPlural(Text, Value)
    if(tonumber(Value) == 1) then
        Text = string.gsub(Text, "(<.+>)", "")
    else
        Text = string.gsub(Text, "<(.+)>", "%1")
    end
    return Text
end

function p.isVariant(WeapName)
    for i, var in pairs(VariantList) do
        if(string.find(WeapName, var)) then
            local baseName = string.gsub(WeapName, ' ?'..var..' ?-?', '')
            return true, var, baseName
        end
    end

    return false, 'Base', WeapName
end

function p.buildName(BaseName, Variant)
    if(Variant == nil or Variant == 'Base' or Variant == '') then
        return BaseName
    elseif(Variant == 'Prime' or Variant == 'Wraith' or Variant == 'Vandal') then
        return BaseName..' '..Variant
    elseif(Variant == "MK1") then
        return "MK1-"..BaseName
    else
        return Variant..' '..BaseName
    end
end

--It's a bit of a mess, but this is for compressing a list with variants
--So if a list has Braton, Braton Prime, and MK1-Braton it'll list as
--                  Braton (MK1, Prime)
function p.shortLinkList(Weapons)
    --First grabbing all the pieces and stashing them in a table
    local baseNames = {}
    for key, weap in Shared.skpairs(Weapons) do
        local isVar, varType, baseName = p.isVariant(weap.Name)
        if(baseNames[baseName] == nil) then baseNames[baseName] = {} end
        table.insert(baseNames[baseName], varType)
    end

    --Then the fun part: Pulling the table together
    local result = {}
    for baseName, variants in Shared.skpairs(baseNames) do
        --So first, check if 'Base' is in the list
        --Because if it isn't, list all variants separately
        if(Shared.contains(variants, "Base")) then
            table.sort(variants)
            --First, get the basic version
            local thisRow = '[['..baseName.."]]"
            --then, if there are variants...
            if(Shared.tableCount(variants) > 1) then
                --List them in parentheses one at a time
                thisRow = thisRow..' ('
                local count = 0
                for i, varName in pairs(variants) do
                    if(varName ~= 'Base') then
                        if(count > 0) then thisRow = thisRow..', ' end
                        thisRow = thisRow..'[['..p.buildName(baseName, varName)..'|'..varName..']]'
                        count = count + 1
                    end
                end
                thisRow = thisRow..')'
            end
            table.insert(result, thisRow)
        else
            for i, varName in pairs(variants) do
                table.insert(result, '[['..p.buildName(baseName, varName)..']]')
            end
        end
    end
    return result
end

function p.getWeapon(WeapName)
    local weapon = WeaponData["Weapons"][WeapName]

    if weapon ~= nil and weapon.Name == WeapName then
        return weapon
    else
        for key, Weapon in Shared.skpairs(WeaponData["Weapons"]) do
            if(Weapon.Name == WeapName or key == WeapName) then
                return Weapon            
            end
        end
    end

    return nil
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
        return "[[:Category:"..weapClass.."|"..weapClass.."]]"
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
        if((weap.Ignore == nil or not weap.Ignore) and weap.Type ~= nil and weap.Type == "Melee") then
            local classMatch = (weapClass == nil or Shared.contains(weapClasses, weap.Class))
            local pvpMatch = (PvP == nil or (PvP and weap.Conclave ~= nil and weap.Conclave))
            if (classMatch and pvpMatch) then
                table.insert(weaps, weap)
            end
        end
    end

    return weaps
end

--As above, but for Conclave stats
local function getConclaveMeleeWeapons(weapClass, PvP)
    local weaps = {}
    local weapClasses = {}
    if(weapClass ~= nil) then
        weapClasses = Shared.splitString(weapClass, ',')
    end

    for i, weap in Shared.skpairs(ConclaveData["Weapons"]) do
        if((weap.Ignore == nil or not weap.Ignore) and weap.Type ~= nil and weap.Type == "Melee") then
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
        if((weap.Ignore == nil or not weap.Ignore) and validateFunction(weap)) then
            table.insert(weaps, weap)
        end
    end
    return weaps
end

--Same as getWeapons, but for Conclave data
function p.getConclaveWeapons(validateFunction)
    local weaps = {}
    for i, weap in Shared.skpairs(ConclaveData["Weapons"]) do
        if((weap.Ignore == nil or not weap.Ignore) and validateFunction(weap)) then
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
    if(Attack == nil or Attack.Damage == nil) then return "" end

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

local function GetDamageBias(Attack, IncludeSingle)
    if(IncludeSingle == nil) then IncludeSingle = false end

    if(Attack.Damage ~= nil and Shared.tableCount(Attack.Damage) > 0) then
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
        --Exception for physical damage types
        if(count > 1 or (IncludeSingle and count > 0)) then
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
local function GetDamageBiasString(Attack, HideType, ShowText, IncludeSingle, Color)
    if(HideType == nil) then HideType = false end
    if(ShowText == nil) then ShowText = "" end
    if(IncludeSingle == nil) then IncludeSingle = false end

    local bestPercent, bestElement = GetDamageBias(Attack, IncludeSingle)
    if(bestPercent ~= nil) then
        local result = asPercent(bestPercent, 0)
        if(not HideType) then
            result = Icon._Proc(bestElement, ShowText, Color).." "..result
        end
        return result
    else
        return nil
    end
end

function p.GetPolarityString(Weapon)
    if(Weapon.Polarities == nil or type(Weapon.Polarities) ~= "table" or Shared.tableCount(Weapon.Polarities) == 0) then
        return "None"
    else
        local resString = ""
        for i, pol in pairs(Weapon.Polarities) do
            local tempPol = Icon._Pol(pol)
            if tempPol == "<span style=\"color:red;\">Invalid</span>" and Weapon.Name == "Exalted Blade" then
                resString = resString..pol
            else
                resString = resString..tempPol
            end
        end
        return resString
    end
end

local function GetStancePolarity(Weapon)
    if(Weapon.StancePolarity == nil or Weapon.StancePolarity == "None") then
        return "None"
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
            link = "[["..stance.Name.."]]"
        else
            link = "[["..stance.Link..'|'..stance.Name.."]]"
        end

        result = result.."<span class=\"mod-tooltip\" data-param=\""..stance.Name.."\" style=\"white-space:pre\">"..link.."</span>"..polarity
        --If this is a PvP Stance, add the disclaimer
        if(stance.PvP ~= nil and stance.PvP) then
            result = result.." (PvP Only)"
        end
    end

    return result
end

local function getAttackValue(Weapon, Attack, ValName, giveDefault, asString, forTable)
    if(giveDefault == nil) then giveDefault = false end
    if(asString == nil) then asString = false end
    if(forTable == nil) then forTable = false end
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
                    return GetDamageString(Attack, nil).." ("..GetDamageBiasString(Attack, nil, "")..")"
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
                if(hasMultipleTypes(Attack)) then
                    return GetDamageString(Attack,  regularVal)
                else
                    return nil
                end
            else
                return GetDamage(Attack,  regularVal)
            end
        elseif giveDefault then
            return 0
        else
            return nil
        end
    elseif(ValName == "ACCURACY") then
        if(Attack.Accuracy ~= nil) then
            return Attack.Accuracy
        elseif(Attack == Weapon.NormalAttack) then
            return Weapon.Accuracy
        elseif giveDefault then
            return 0
        else
            return nil
        end
    elseif(ValName == "ATTACKNAME") then
        if(Attack.AttackName ~= nil) then
            return Attack.AttackName
        elseif(giveDefault) then
            return ""
        else
            return nil
        end
    elseif(ValName == "AMMOCOST") then
        if(Attack.AmmoCost ~= nil) then
            if(asString) then
                return Attack.AmmoCost.." ammo per shot"
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
                local result = Attack.BurstCount.." rounds"
                local dmg = GetDamage(Attack) * Attack.BurstCount
                return result.." ("..Shared.round(dmg, 2, 1).." total damage)"
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
                return Shared.round(Attack.ChargeTime, 2, 1).." s"
            else
                return Attack.ChargeTime
            end
        elseif giveDefault then
            return 0
        else
            return nil
        end
    elseif(ValName == "CRITCHANCE") then -- note there is getValue version
    --search in current attack, then normal, 
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
    elseif(ValName == "CRITMULTIPLIER") then -- note there is getValue version
    --search in current attack, then normal, 
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
        if(Shared.tableCount(Attack.Damage) <= 4) then
            if (GetDamageBiasString(Attack, nil, nil, giveDefault)~=nil) then
                return GetDamageBiasString(Attack, nil, nil, giveDefault)
            else
                return ""
            end
        else
            if(asString or giveDefault) then
                return ""
            else
                return nil
            end
        end
    elseif(ValName == "BULLETTYPE") then
        if(Attack.ShotType ~= nil) then
            return Attack.ShotType
        elseif(giveDefault) then
            return "Unknown"
        else
            return nil
        end
    elseif(ValName == "DURATION") then
        if(Attack.Duration ~= nil) then
            if(asString) then
                return Shared.round(Attack.Duration, 1, 0).." s"
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
                if(not Shared.contains(Physical, dType) or dmg <= 0) then
                    if(asString) then
                        return Icon._Proc(dType)
                    else
                        return dType
                    end
                end
            end
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
            local falloffText = "Full damage up to "..Shared.round(Attack.Falloff.StartRange, 2, 1).." m"
            falloffText = falloffText.."<br/>Min damage at "..Shared.round(Attack.Falloff.EndRange, 2, 1).." m"
            if(Attack.Falloff.Reduction ~= nil) then
                falloffText = falloffText.."<br/>"..asPercent(Attack.Falloff.Reduction).." max reduction"
            end
            return falloffText
        else
            return nil
        end
    elseif(ValName == "FIRERATE") then --search in current attack, then normal, then weapon supertable
        local returnVal = 0
        if(Attack.FireRate ~= nil) then
            returnVal = Attack.FireRate
        elseif(hasAttack(Weapon, "Normal")) then
            local normAtt = getAttack(Weapon, "Normal")
            if(normAtt.FireRate ~= nil) then 
                returnVal = normAtt.FireRate
            end            
        elseif(Weapon.FireRate ~= nil) then
            returnVal = Weapon.FireRate
        end
        if(asString) then
            if(Weapon.Type ~= nil and Weapon.Type ~= "Melee" and Weapon.Type ~= "Arch-Melee") then
                if(forTable) then
                    return Shared.round(returnVal, {3, 1}) -- .." rps"
                else
                    return Shared.round(returnVal, {3, 1})..p.doPlural(" round<s> per sec", returnVal)
                end
            else
                return Shared.round(returnVal, {3, 1})
            end
        else
            return returnVal
        end
        if (giveDefault) then
            returnVal = 0
        else
            return nil
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
                    return Attack.PelletCount.." "..Attack.PelletName.."s"
                else
                    return Attack.PelletCount.." Pellets"
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
                return result.." per "..string.lower(Attack.PelletName)
            else
                return result.." per pellet"
            end
        else
            return nil
        end
    elseif(ValName == "PELLETNAME") then
        if(Attack.PelletCount ~= nil) then
            if(Attack.PelletName ~= nil) then
                return Attack.PelletName
            else
                return "Pellet"
            end
        else
            return nil
        end
    elseif(ValName == "PELLETPLUS") then
        if(Attack.PelletCount ~= nil) then
            local result = Attack.PelletCount.." ("
            result = result..Shared.round(GetDamage(Attack, nil, true), 2, 1)
            if(Attack.PelletName ~= nil) then
                return result.." damage per "..string.lower(Attack.PelletName)..")"
            else
                return result.." damage per pellet)"
            end
        else
            return nil
        end
    elseif(ValName == "PROJECTILESPEED") then
        if(Attack.ShotSpeed ~= nil) then
            if(asString) then
                return Attack.ShotSpeed.." m/s"
            else
                return Attack.ShotSpeed
            end
        elseif(giveDefault) then
            if(asString) then
                return "0 m/s"
            else
                return 0
            end
        else
            return nil
        end
    elseif(ValName == "PUNCHTHROUGH") then
        if(Attack.PunchThrough ~= nil) then
            if(asString) then
                return Shared.round(Attack.PunchThrough, 2, 1).." m"
            else
                return Attack.PunchThrough
            end
        elseif giveDefault then
            if(asString) then
                return "0 m"
            else
                return 0
            end
        else
            return nil
        end
    elseif(ValName == "RADIUS") then
        if(Attack.Radius ~= nil) then
            if(asString) then
                return Shared.round(Attack.Radius, 2, 1).." m"
            else
                return Attack.Radius
            end
        elseif giveDefault then
            if(asString) then
                return "0 m"
            else
                return 0
            end
        else
            return nil
        end
    elseif(ValName == "RANGE") then
        if(Attack.Range ~= nil) then
            if(asString) then
                return Attack.Range.." m"
            else
                return Attack.Range
            end
        elseif(giveDefault) then
            if(asString) then
                return "0 m"
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
                return Shared.round(Attack.Reload, 2, 1).." s"
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
                return Attack.Spool.." rounds"
            else
                return Attack.Spool
            end
        else
            return nil
        end
    elseif(ValName == "STANCES") then
        return getWeaponStanceList(Weapon)    
    elseif(ValName == "STATUSCHANCE") then -- search in current attck, then normal
        if(Attack.StatusChance ~= nil) then
            if(asString) then
                return asPercent(Attack.StatusChance)
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
            if(asString) then
                return asPercent(0)
            else
                return 0
            end
        else
            return nil
        end
    elseif(ValName == "TRIGGER") then -- use getValue for tables
    -- search in current attack, then weapon supertable
        if(Attack.Trigger ~= nil) then
            return Attack.Trigger
        end
        if(Weapon.Trigger ~= nil) then
            return Weapon.Trigger
        end
        if giveDefault then
            return "Unknown"
        else
            return nil
        end
    else
        return "ERROR: No such value "..ValName
    end
end

local function getValue(Weapon, ValName, giveDefault, asString, forTable)
    if(giveDefault == nil) then giveDefault = false end
    if(asString == nil) then asString = false end
    if(forTable == nil) then forTable = false end

    if(type(ValName) == "table") then
        local VName1 = string.upper(ValName[1])
        local VName2 = string.upper(ValName[2])
        if(VName1 == nil or VName2 == nil) then
            return nil
        end

        if(VName1 == "ATTACK" or VName1 == "NORMALATTACK" or VName1 == "NORMAL") then
            return getAttackValue(Weapon, getAttack(Weapon, "Normal"), VName2, giveDefault, asString, forTable)
        elseif(VName1 == "AREA" or VName1 == "AREAATTACK") then
            return getAttackValue(Weapon, getAttack(Weapon, "Area"), VName2, giveDefault, asString, forTable)
        elseif(VName1 == "SECONDARYAREA" or VName1 == "SECONDARYAREAATTACK") then
            return getAttackValue(Weapon, getAttack(Weapon, "SecondaryArea"), VName2, giveDefault, asString, forTable)
        elseif(VName1 == "CHARGE" or VName1 == "CHARGEATTACK") then
            return getAttackValue(Weapon, getAttack(Weapon, "Charge"), VName2, giveDefault, asString, forTable)
        elseif(VName1 == "CHARGEDTHROW" or VName1 == "CHARGEDTHROWATTACK") then
            return getAttackValue(Weapon, getAttack(Weapon, "ChargedThrow"), VName2, giveDefault, asString, forTable)
        elseif(VName1 == "THROW" or VName1 == "THROWATTACK") then
            return getAttackValue(Weapon, getAttack(Weapon, "Throw"), VName2, giveDefault, asString, forTable)
        elseif(VName1 == "SECONDARY" or VName1 == "SECONDARYATTACK") then
            return getAttackValue(Weapon, getAttack(Weapon, "Secondary"), VName2, giveDefault, asString, forTable)
        else
            return "ERROR: No such attack '"..VName1.."'"
        end
    end

    ValName = string.upper(ValName)
    if(ValName == "NAME") then
        if(Weapon.Name ~= nil) then
            if(forTable) then 
                if (string.find(Weapon.Name,"Atmosphere")~=nil) then
                    return "[["..string.gsub(Weapon.Name,"%s%(Atmosphere%)","").."|"..string.gsub(Weapon.Name,"osphere","").."]]"
                else
                    return "[["..Weapon.Name.."]]"
                end
            else
                return Weapon.Name
            end
        elseif giveDefault then
            return ""
        else
            return nil
        end
    elseif(ValName == "AMMOTYPE") then
        if(Weapon.AmmoType ~= nil) then
            return Weapon.AmmoType
        elseif giveDefault then
            if(Weapon.Type ~= nil) then
                if(Weapon.Type == "Secondary") then
                    return "Pistol"
                elseif(Weapon.Type == "Primary") then
                    if(Weapon.Class == nil or Weapon.Class == "Rifle") then
                        return "Rifle"
                    elseif(Weapon.Class == "Shotgun") then
                        return "Shotgun"
                    elseif(Weapon.Class == "Bow") then
                        return "Bow"
                    elseif(Weapon.Class == "Sniper Rifle" or Weapon.Class == "Launcher") then
                        return "Sniper"
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
                AugString = AugString.."[["..Aug.Name.."]]"
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
                return "[[:Category:"..Weapon.Class.."|"..Weapon.Class.."]]"
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
                if(Weapon.Conclave) then return "Yes" else return "No" end
            else
                return Weapon.Conclave
            end
        elseif giveDefault then
            return false
        else
            return nil
        end
    elseif(ValName == "DISPOSITION") then
        if(Weapon.Type ~= nil and (Weapon.Type == "Arch-Gun" or Weapon.Type == "Arch-Melee") or Weapon.Type == "Emplacement") then return nil end

        if(Weapon.Disposition ~= nil) then
            if(asString) then
                return Icon._Dis(Weapon.Disposition)..'<div style="display:inline; position:relative; bottom:2px">('..Weapon.Disposition..')</div>'
            else
                return Weapon.Disposition
            end
        elseif giveDefault then
            if(asString) then
                return "Unknown"
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
                            FamilyString = FamilyString.."[["..Weap.Name.."]]"
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
            return Weapon.Introduced
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
                return Shared.round(Weapon.JumpRadius, 2, 1).." m"
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
                if (forTable) then 
                    return Weapon.Magazine
                else
                    return Weapon.Magazine..p.doPlural(" round<s> per mag", Weapon.Magazine)
                end
            else
                return Weapon.Magazine
            end
        elseif giveDefault then
            if(asString) then
                return "0 rounds per mag"
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
                    elseif(Weapon.Class == "Bow" or Weapon.Class == "Sniper Rifle") then
                        returnVal = 72
                    end
                end
            end
        else
            return nil
        end
        if(asString) then
            if(returnVal > 0) then
                return returnVal.." rounds"
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
            return Weapon.NoiseLevel
        elseif giveDefault then
            if(Weapon.Type ~= nil and Weapon.Type ~= "Melee" and Weapon.Type ~= "Arch-Melee") then
                if(Weapon.Class ~= nil and (Weapon.Class == "Bow" or Weapon.Class == "Thrown")) then
                    return "Silent"
                else
                    return "Alarming"
                end
            else
                return nil
            end
        else
            return nil
        end
    elseif(ValName == "POLARITIES") then
        if(Weapon.Polarities ~= nil and type(Weapon.Polarities) == "table") then
            if(asString) then
                return p.GetPolarityString(Weapon)
            else
                return Weapon.Polarities
            end
        elseif giveDefault then
            if(asString) then
                return "None"
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
                        local result = Shared.round(Weapon.Reload / Weapon.Magazine, 2, 1).." sec per round"
                        result = result.." ("..Shared.round(Weapon.Reload, 2, 1).."s total)"
                        if(forTable) then result = Shared.round(Weapon.Reload, 2, 1).." s" end
                        return result
                    elseif(Weapon.ReloadStyle == "Regenerate") then
                        local result = Shared.round(Weapon.Reload, 2, 1).." rounds per sec"
                        if(Weapon.Magazine ~= nil) then
                            result=result.." ("..Shared.round(Weapon.Magazine / Weapon.Reload, 2, 1).."s total)" 
                            if(forTable) then result=Shared.round(Weapon.Magazine / Weapon.Reload, 2, 1).." s" end
                        end
                        return result
                    end
                end
                return Shared.round(Weapon.Reload, 2, 1).." s"
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
                return Shared.round(Weapon.SniperComboReset, 2, 1).." s"
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
                return Weapon.SniperComboMin.." shots"
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
            return Weapon.Stagger
        elseif giveDefault then
            return "No"
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
            return "None"
        else
            return nil
        end
    elseif(ValName == "SYNDICATEEFFECT") then
        if(Weapon.SyndicateEffect ~= nil) then
            if(asString) then
                return "[["..Weapon.SyndicateEffect.."]]"
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
    elseif(ValName == "TRIGGER") then  -- Note there is a specific version for each attack in getAttackValue
        if(Weapon.Trigger ~= nil) then
            if (forTable) then -- return chargetime and burstcount only in tables
                local trigger = Weapon.Trigger
                if(trigger == "Charge") then
                    local cTime = getAttackValue(Weapon, getAttack(Weapon,"Charge"), "ChargeTime", false)
                    if(cTime ~= nil) then
                        return trigger.." ("..Shared.round(cTime, 2, 1).."s)" 
                    else 
                        return trigger
                    end
                elseif(trigger == "Burst") then
                    local bCount = getAttackValue(Weapon, getAttack(Weapon,"Normal"), "BurstCount", false)
                    if(bCount ~= nil) then
                        return trigger.." ("..bCount..")" 
                    else
                        return trigger
                    end
                else
                    return trigger
                end
            else
                return Weapon.Trigger
            end

        elseif giveDefault then
            return "Unknown"
        else
            return nil
        end
    elseif(ValName == "CRITCHANCE") then -- Note there is a specific version for each attack in getAttackValue    
    -- search in charge attck, then normal, then secondary if still null
        local returnVal=0
        local Attack={}
        if(hasAttack(Weapon, "Charge")) then
            local chargAtt = getAttack(Weapon, "Charge")
            if(chargAtt.CritChance ~= nil) then
                returnVal=chargAtt.CritChance
                Attack=chargAtt
            end
        end
        if(hasAttack(Weapon, "Normal") and returnVal ==0) then
            local normAtt = getAttack(Weapon, "Normal")
            if(normAtt.CritChance ~= nil) then
                returnVal=normAtt.CritChance
                Attack=normAtt
            end
        end
        if(hasAttack(Weapon, "Secondary") and returnVal ==0) then
            local secAtt = getAttack(Weapon, "Secondary")
            if(secAtt.CritChance ~= nil) then
                returnVal=secAtt.CritChance
                Attack=secAtt
            end
        end
        if(asString and returnVal ~= 0) then
            return asPercent(returnVal)
        else
            return returnVal
        end
        if giveDefault then
            return 0
        else
            return nil
        end
    elseif(ValName == "CRITMULTIPLIER") then--Note there is a specific version for each attack in getAttackValue
    -- search in charge attck, then normal, then secondary if still null
        local returnVal=0
        local Attack={}
        if(hasAttack(Weapon, "Charge")) then
            local chargAtt = getAttack(Weapon, "Charge")
            if(chargAtt.CritMultiplier ~= nil) then
                returnVal=chargAtt.CritMultiplier
                Attack=chargAtt
            end
        end
        if(hasAttack(Weapon, "Normal") and returnVal ==0) then
            local normAtt = getAttack(Weapon, "Normal")
            if(normAtt.CritMultiplier ~= nil) then
                returnVal=normAtt.CritMultiplier
                Attack=normAtt
            end
        end
        if(hasAttack(Weapon, "Secondary") and returnVal ==0) then
            local secAtt = getAttack(Weapon, "Secondary")
            if(secAtt.CritMultiplier ~= nil) then
                returnVal=secAtt.CritMultiplier
                Attack=secAtt
            end
        end
        if(asString and returnVal ~= 0) then
            return asMultiplier(returnVal)
        else
            return returnVal
        end
        if giveDefault then
            return 0
        else
            return nil
        end
    elseif(ValName == "FIRERATE") then  -- Note there is a specific version for each attack in getAttackValue        -- search in global weapon then normal attck, then charge, then secondary if still null
        local returnVal=0
        local Attack={}
        if(Weapon.FireRate ~= nil) then
            returnVal = Weapon.FireRate
        end
        if(hasAttack(Weapon, "Normal") and returnVal ==0) then
            local normAtt = getAttack(Weapon, "Normal")
            if(normAtt.FireRate ~= nil) then
                returnVal=normAtt.FireRate
                Attack=normAtt
            end
        end
        if(hasAttack(Weapon, "Charge") and returnVal ==0) then
            local chargAtt = getAttack(Weapon, "Charge")
            if(chargAtt.FireRate ~= nil) then
                returnVal=chargAtt.FireRate
                Attack=chargAtt
            end
        end
        if(hasAttack(Weapon, "Secondary") and returnVal ==0) then
            local secAtt = getAttack(Weapon, "Secondary")
            if(secAtt.FireRate ~= nil) then
                returnVal=secAtt.FireRate
                Attack=secAtt
            end
        end
        if(asString and returnVal ~= 0) then
            if(Weapon.Type ~= nil and Weapon.Type ~= "Melee" and Weapon.Type ~= "Arch-Melee") then
                if(forTable) then
                    return Shared.round(returnVal, {3, 1}) -- .." rps"
                else
                    return Shared.round(returnVal, {3, 1})..p.doPlural(" round<s> per sec", returnVal)
                end
            else
                return Shared.round(returnVal, {3, 1})
            end
        else
            return returnVal
        end
        if giveDefault then
            return 0
        else
            return nil
        end
    elseif(ValName == "STATUSCHANCE") then  -- Note there is a specific version for each attack in getAttackValue
        -- search in charge attck, then normal, then secondary if still null
        local returnVal=0
        local Attack={}
        if(hasAttack(Weapon, "Charge")) then
            local chargAtt = getAttack(Weapon, "Charge")
            if(chargAtt.StatusChance ~= nil) then
                returnVal=chargAtt.StatusChance
                Attack=chargAtt
            end
        end
        if(hasAttack(Weapon, "Normal") and returnVal ==0) then
            local normAtt = getAttack(Weapon, "Normal")
            if(normAtt.StatusChance ~= nil) then
                returnVal=normAtt.StatusChance
                Attack=normAtt
            end
        end
        if(hasAttack(Weapon, "Secondary") and returnVal ==0) then
            local secAtt = getAttack(Weapon, "Secondary")
            if(secAtt.StatusChance ~= nil) then
                returnVal=secAtt.StatusChance
                Attack=secAtt
            end
        end
        if(asString and returnVal ~= 0) then
                return asPercent(returnVal)
            else
                return returnVal
            end
        if giveDefault then
            return 0
        else
            return nil
        end
    elseif(ValName == "TYPE") then
        if(Weapon.Type ~= nil) then
            return Weapon.Type
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
                    result = result..str
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
                    result = result..str
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
                return "bounce: 25 m/s"
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
                return "0 m/s"
            else
                return 0
            end            
        else 
            return nil
        end

    else
        --if everything failed (and it should NOT) try in the getAttackValue
        return getAttackValue(Weapon, getAttack(Weapon, "Normal"), ValName, giveDefault, asString) 
    end
end

function p.getValue(frame)
    local WeapName = frame.args[1]
    local ValName1 = frame.args[2]
    local ValName2 = frame.args[3]
    local AsString = frame.args["Raw"] == nil
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

    return getValue(theWeap, vName, useDefault, AsString)
end

function p.getConclaveValue(frame)
    local WeapName = frame.args[1]
    local ValName1 = frame.args[2]
    local ValName2 = frame.args[3]
    if(WeapName == nil) then
        return ""
    elseif(ValName1 == nil) then
        return "ERROR: No value selected"
    end

    local theWeap = p.getConclaveWeapon(WeapName)
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

    return getValue(theWeap, vName, useDefault, true)
end

local function buildInfoboxRow(Label, Text, Collapse, Digits, Addon)
    local result = ""

    if(Collapse == nil) then
        Collapse = false
    elseif(Collapse == 1) then
        Collapse = true
    end
    if(Text ~= nil) then
        result = '<div style="margin-left:-3px;" '
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

        if(Stance.PvP) then
            result = result.."*[[Conclave:"..weap.Name.."|"..weap.Name.."]]"
        else
            result = result.."*[["..weap.Name.."]]"
        end

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
    local result = "=="..StanceType.." [[Stance|Stance Mods]]=="
    result = result..'\n{| style="margin:auto;text-align:center;"'
    local nameRow = ''
    for i, Stance in pairs(Stances) do
        local theImage = Stance.Image ~= nil and Stance.Image or "Panel.png"
        if((i - 1) % 4 == 0) then 
            result = result..nameRow..'\n|-' 
            nameRow = '\n|-'
        end
        result = result..'\n| style="width:165px" |[[File:'..Stance.Image..'|150px|link='..Stance.Name..']]'
        nameRow = nameRow..'\n| style="vertical-align: text-top;" |[['..Stance.Name..']]'
        if(Stance.PvP ~= nil and Stance.PvP) then
            nameRow = nameRow..'<br/>([[Conclave]] only)'
        end
    end
    result = result..nameRow
    result = result..'\n|}'
    return result
end

local function getWeaponGallery(Weapons)
    local result = '{| style="margin:auto;text-align:center;"'
    local nameRow = ''
    for i, Weapon in pairs(Weapons) do
        local theImage = Weapon.Image ~= nil and Weapon.Image or "Panel.png"
        if((i - 1) % 4 == 0) then 
            result = result..nameRow..'\n|-' 
            nameRow = '\n|-'
        end
        result = result..'\n| style="width:165px" |[[File:'..theImage..'|150px|link='..Weapon.Name..']]'
        nameRow = nameRow..'\n| style="vertical-align: text-top;" |[['..Weapon.Name..']]'
    end
    result = result..nameRow
    result = result..'\n|}'
    return result
end

function p.getMeleeWeaponGallery(frame)
    local Type = frame.args ~= nil and frame.args[1] or frame
    if(Type == nil) then
        return ""
    end
    local WeapArray = getMeleeWeapons(Type)
    local result = "=="..Type.." Weapons==\n"
    result = result..getWeaponGallery(WeapArray)
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

function p.getPolarityTable()
    local tHeader = ""
    tHeader = tHeader..'\n{| style="width: 100%; border-collapse: collapse; cellpadding: 2" border="1"'
    tHeader = tHeader..'\n! colspan="2" |Primary Weapons'
    tHeader = tHeader..'\n! colspan="2" |Secondary Weapons'
    tHeader = tHeader..'\n! colspan="2" |Melee Weapons'
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
            tRows = tRows.."\n|[["..Primaries[i].Name.."]]||"..p.GetPolarityString(Primaries[i])
        else
            tRows = tRows.."\n| ||"
        end
        if(i <= BCount) then
            tRows = tRows.."\n|[["..Pistols[i].Name.."]]||"..p.GetPolarityString(Pistols[i])
        else
            tRows = tRows.."\n| ||"
        end
        if(i <= ACount) then
            tRows = tRows.."\n|[["..Melees[i].Name.."]]||"..p.GetPolarityString(Melees[i])
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
    local bigWord = Words ~= nil and Words[1] or "Higher"
    local smallWord = Words ~= nil and Words[2] or "Lower"
    local start = Start ~= nil and Start or "\n**"

    if(Val1 > Val2) then
        return start.." "..bigWord.." "..ValName.." ("..V1Str.." vs. "..V2Str..")"
    elseif(Val2 > Val1) then
        return start.." "..smallWord.." "..ValName.." ("..V1Str.." vs. "..V2Str..")"
    else
        return ""
    end
end

function buildGunComparisonString(Weapon1, Weapon2, Conclave)
    local result = ""
    if(Conclave) then
        result = "* "..Weapon1.Name..", compared to [[Conclave:"..Weapon2.Name.."|"..Weapon2.Name.."]]:"
    else
        result = "* "..Weapon1.Name..", compared to [["..Weapon2.Name.."]]:"
    end

    if(hasAttack(Weapon1, "Normal") and hasAttack(Weapon2, "Normal")) then
        local Att1 = getAttack(Weapon1, "Normal")
        local Att2 = getAttack(Weapon2, "Normal")
        local dmgString = ""
        dmgString = dmgString..buildCompareString(GetDamage(Att1), GetDamage(Att2), "base damage", {2, 1})
        dmgString = dmgString..buildCompareString(Att1.Damage["Impact"], Att2.Damage["Impact"], Icon._Proc("Impact", "text").." damage", {2, 1}, nil, {"Higher", "Lower"}, "\n***")
        dmgString = dmgString..buildCompareString(Att1.Damage["Puncture"], Att2.Damage["Puncture"], Icon._Proc("Puncture", "text").." damage", {2, 1}, nil, {"Higher", "Lower"}, "\n***")
        dmgString = dmgString..buildCompareString(Att1.Damage["Slash"], Att2.Damage["Slash"], Icon._Proc("Slash", "text").." damage", {2, 1}, nil, {"Higher", "Lower"}, "\n***")
        if(string.len(dmgString) > 0 and GetDamage(Att1) == GetDamage(Att2)) then
            dmgString = "\n**Equal base damage, but different composition:"..dmgString    
        end
        result = result..dmgString
    end
    if(hasAttack(Weapon1, "Charge")and hasAttack(Weapon2, "Charge")) then
        result = result..buildCompareString(GetDamage(Weapon1.ChargeAttack), GetDamage(Weapon2.ChargeAttack), "charge attack damage", {2, 1})
        result = result..buildCompareString(getValue(Weapon1, {"Charge", "ChargeTime"}), getValue(Weapon2, {"Charge", "ChargeTime"}), "charge time", {2, 1}, " s", {"Slower", "Faster"})
    end
    if(hasAttack(Weapon1, "Area") and hasAttack(Weapon2, "Area")) then
        result = result..buildCompareString(GetDamage(Weapon1.AreaAttack), GetDamage(Weapon2.AreaAttack), "area attack damage", {2, 1})
    end
    if(hasAttack(Weapon1, "Secondary") and hasAttack(Weapon2, "Secondary")) then
        result = result..buildCompareString(GetDamage(Weapon1.SecondaryAttack), GetDamage(Weapon2.SecondaryAttack), "secondary attack damage", {2, 1})
    end

    if(hasAttack(Weapon1, "Normal") and hasAttack(Weapon2, "Normal") ) then
        local Att1 = getAttack(Weapon1, "Normal")
        local Att2 = getAttack(Weapon2, "Normal")
        if(Att1.CritChance ~= nil and Att2.CritChance ~= nil) then
            result = result..buildCompareString((Att1.CritChance * 100), (Att2.CritChance * 100), "[[critical chance]]", 2, "%")
        end
        result = result..buildCompareString(Att1.CritMultiplier, Att2.CritMultiplier, "[[critical multiplier]]", 2, "x")
        if(Att1.StatusChance ~= nil and Att2.StatusChance ~= nil) then
            result = result..buildCompareString((Att1.StatusChance * 100), (Att2.StatusChance * 100), "[[status chance]]", 2, "%")
        end
        result = result..buildCompareString(Att1.FireRate, Att2.FireRate, "[[fire rate]]", 2, " round<s>/sec")

        --Handling Damage Falloff        
        if(Att1.Falloff ~= nil and Att2.Falloff == nil) then
            result = result.."\n** "..Att1.Falloff.StartRange.."m - "..Att1.Falloff.EndRange.."m damage falloff"
            if(Att1.Falloff.Reduction ~= nil) then
               result = result.." with up to "..(Att1.Falloff.Reduction * 100).."% damage reduction"
            end
        elseif(Att2.Falloff ~= nil and Att1.Falloff == nil) then
            result = result.."\n** No "..Att2.Falloff.StartRange.."m - "..Att2.Falloff.EndRange.."m damage falloff"
            if(Att2.Falloff.Reduction ~= nil) then
                result = result.." with up to "..(Att2.Falloff.Reduction * 100).."% damage reduction"
            end
        elseif(Att1.Falloff ~= nil and Att2.Falloff ~= nil) then
            result = result..buildCompareString(Att1.Falloff.StartRange, Att2.Falloff.StartRange, "range before damage falloff starts", 2, "m", {"Longer", "Shorter"})
            result = result..buildCompareString(Att1.Falloff.EndRange, Att2.Falloff.EndRange, "range before damage falloff ends", 2, "m", {"Longer", "Shorter"})
            if(Att1.Falloff.Reduction ~= nil and Att2.Falloff.Reduction ~= nil) then
                result = result..buildCompareString(Att1.Falloff.Reduction * 100, Att2.Falloff.Reduction * 100, "max damage reduction due to falloff", 2, "%", {"Larger", "Smaller"})
            end
        end
    end

    result = result..buildCompareString(Weapon1.Magazine, Weapon2.Magazine, "magazine", 0, " round<s>", {"Larger", "Smaller"})
    result = result..buildCompareString(Weapon1.MaxAmmo, Weapon2.MaxAmmo, "max ammo capacity", 0, " round<s>", {"Larger", "Smaller"})
    --If this is a weapon that regenerates ammo, flip the comparison
    if (Weapon1.ReloadStyle ~= nil and Weapon1.ReloadStyle == "Regenerate") then
        result = result..buildCompareString(Weapon1.Reload, Weapon2.Reload, "[[reload speed]]", 2, " round<s>/sec", {"Faster", "Slower"})
    else
        result = result..buildCompareString(Weapon1.Reload, Weapon2.Reload, "[[reload speed]]", 2, " s", {"Slower", "Faster"})
    end
    result = result..buildCompareString(Weapon1.Spool, Weapon2.Spool, "spool-up", 0, " round<s>", {"Slower", "Faster"})
    local Acc1 = getValue(Weapon1, "Accuracy")
    local Acc2 = getValue(Weapon2, "Accuracy")
    if(type(Acc1) == "number" and type(Acc2) == "number") then
        result = result..buildCompareString(Acc1, Acc2, "accurate", 0, nil, {"More", "Less"})
    end

    --Handling Syndicate radial effects
    if(Weapon1.SyndicateEffect ~= nil and Weapon2.SyndicateEffect == nil) then
        result = result.."\n** Innate [["..Weapon1.SyndicateEffect.."]] effect"
    elseif(Weapon2.SyndicateEffect ~= nil and Weapon1.SyndicateEffect == nil) then
        result = result.."\n** Lack of an innate [["..Weapon2.SyndicateEffect.."]] effect"
    elseif(Weapon1.SyndicateEffect ~= nil and Weapon2.SyndicateEffect ~= nil and Weapon1.SyndicateEffect ~= Weapon2.SyndicateEffect2) then
        result = result.."\n** Different innate [[Syndicate Radial Effects|Syndicate Effect]]: [["..Weapon1.SyndicateEffect.."]] vs. [["..Weapon2.SyndicateEffect.."]]"
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
        result = result.."\n** Different polarities ("..p.GetPolarityString(Weapon1).." vs. "..p.GetPolarityString(Weapon2)..")"
    end

    result = result..buildCompareString(Weapon1.Mastery, Weapon2.Mastery, "[[Mastery Rank]] required", 0)
    return result
end

function buildMeleeComparisonString(Weapon1, Weapon2, Conclave)
    local result = ""
    if(Conclave) then
        result = "* "..Weapon1.Name..", compared to [[Conclave:"..Weapon2.Name.."|"..Weapon2.Name.."]]:"
    else
        result = "* "..Weapon1.Name..", compared to [["..Weapon2.Name.."]]:"
    end

    local dmgString = ""
    local Att1 = getAttack(Weapon1, "Normal")
    local Att2 = getAttack(Weapon2, "Normal")
    dmgString = dmgString..buildCompareString(GetDamage(Att1), GetDamage(Att2), "base damage", {2, 1})
    dmgString = dmgString..buildCompareString(Att1.Damage["Impact"], Att2.Damage["Impact"], Icon._Proc("Impact", "text").." damage", {2, 1}, nil, {"Higher", "Lower"}, "\n***")
    dmgString = dmgString..buildCompareString(Att1.Damage["Puncture"], Att2.Damage["Puncture"], Icon._Proc("Puncture", "text").." damage", {2, 1}, nil, {"Higher", "Lower"}, "\n***")
    dmgString = dmgString..buildCompareString(Att1.Damage["Slash"], Att2.Damage["Slash"], Icon._Proc("Slash", "text").." damage", {2, 1}, nil, {"Higher", "Lower"}, "\n***")
    if(string.len(dmgString) > 0 and GetDamage(Att1) == GetDamage(Att2)) then
        dmgString = "\n**Equal base damage, but different composition:"..dmgString    
    end
    result = result..dmgString

    if(Att1.CritChance ~= nil and Att2.CritChance ~= nil) then
        result = result..buildCompareString((Att1.CritChance * 100), (Att2.CritChance * 100), "[[critical chance]]", 2, "%")
    end
    result = result..buildCompareString(Att1.CritMultiplier, Att2.CritMultiplier, "[[critical multiplier]]", {2, 1}, "x")

    if(Att1.StatusChance ~= nil and Att2.StatusChance ~= nil) then
        result = result..buildCompareString((Att1.StatusChance * 100), (Att2.StatusChance * 100), "[[status chance]]", 2, "%")
    end
    result = result..buildCompareString(Att1.FireRate, Att2.FireRate, "[[attack speed]]", 2)
    result = result..buildCompareString(Icon._Pol(Weapon1.StancePolarity), Icon._Pol(Weapon2.StancePolarity), "Stance Polarity", nil, nil, {"Different", "Different"})
    result = result..buildCompareString(getValue(Weapon1, "ChannelMult", true), getValue(Weapon2, "ChannelMult", true), "Channeling Multiplier", 1, "x")

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
        result = result.."\n** Different polarities ("..p.GetPolarityString(Weapon1).." vs. "..p.GetPolarityString(Weapon2)..")"
    end

    result = result..buildCompareString(Weapon1.Mastery, Weapon2.Mastery, "[[Mastery Rank]] required", 0)
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
        return buildMeleeComparisonString(Weapon1, Weapon2).."[[Category:Automatic Comparison]]"
    else
        return buildGunComparisonString(Weapon1, Weapon2).."[[Category:Automatic Comparison]]"
    end
end

function p.buildConclaveComparison(frame)
    local WeapName1 = frame.args[1]
    local WeapName2 = frame.args[2]

    if(WeapName1 == nil or WeapName2 == nil) then
        return '<span style="color:red">ERROR: Must compare two weapons</span>'
    end

    local Weapon1 = p.getConclaveWeapon(WeapName1)
    if(Weapon1 == nil) then
        return '<span style="color:red">ERROR: Could not find '..WeapName1..'</span>'
    end
    local Weapon2 = p.getConclaveWeapon(WeapName2)
    if(Weapon2 == nil) then
        return '<span style="color:red">ERROR: Could not find '..WeapName2..'</span>'
    end

    if(p.isMelee(Weapon1)) then
        return buildMeleeComparisonString(Weapon1, Weapon2, true).."[[Category:Automatic Comparison]]"
    else
        return buildGunComparisonString(Weapon1, Weapon2, true).."[[Category:Automatic Comparison]]"
    end
end

function p.buildFamilyComparison(frame)
    local WeapName = frame.args ~= nil and frame.args[1] or frame
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
            if(p.isMelee(NewWeapon)) then
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
    local result = "[[Category:Automatic Weapon Box]][[Category:Weapons]]"
    if(Weapon == nil) then
        return ""
    elseif(Weapon.IgnoreCategories ~= nil and Weapon.IgnoreCategories) then
        return ""
    end
    if(Weapon.Type ~= nil) then
        if(Weapon.Type == "Arch-Melee") then
            result = result.."[[Category:Archwing Melee]]"
        elseif(Weapon.Type == "Arch-Gun") then
            result = result.."[[Category:Archwing Gun]]"
        else
            result= result.."[[Category:"..Weapon.Type.." Weapons]]"
        end
    end
    if(Weapon.Class ~= nil) then
        if(Weapon.Class == "Rifle") then
            result = result.."[[Category:Assault Rifle]]"
        else
            result = result.."[[Category:"..Weapon.Class.."]]"
        end
    end

    local augments = getAugments(Weapon)
    if(Shared.tableCount(augments) > 0) then
        result = result.."[[Category:Augmented Weapons]]"
    end

    if(HasTrait(Weapon, "Prime")) then
        result = result.."[[Category:Prime]][[Category:Prime Weapons]]"
        if(HasTrait(Weapon, "Never Vaulted")) then
            result = result.."[[Category:Never Vaulted]]"
        elseif(HasTrait(Weapon, "Vaulted")) then
            result = result.."[[Category:Vaulted]]"
        end
    end

    if(HasTrait(Weapon, "Grineer")) then
        result = result.."[[Category:Grineer Weapons]]"
    elseif(HasTrait(Weapon, "Corpus")) then
        result = result.."[[Category:Corpus Weapons]]"
    elseif(HasTrait(Weapon, "Infested")) then
        result = result.."[[Category:Infested Weapons]]"
    elseif(HasTrait(Weapon, "Tenno")) then
        result = result.."[[Category:Tenno Weapons]]"
    end

    local attack = nil
    if(hasAttack(Weapon, "Normal")) then
        attack = getAttack(Weapon, "Normal")
    elseif(hasAttack(Weapon, "Charge")) then
        attack = getAttack(Weapon, "Charge")
    end
    if(attack ~= nil) then
        local bestPercent, bestElement = GetDamageBias(attack)
        if(bestElement == "Impact" or bestElement == "Puncture" or bestElement == "Slash") then
            if(bestPercent > .38) then
                result = result.."[[Category:"..bestElement.." Damage Weapons]]"
            else
                result = result.."[[Category:Balanced Physical Damage Weapons]]"
            end
        end

        for key, value in Shared.skpairs(attack.Damage) do
            if(key ~= "Impact" and key ~= "Puncture" and key ~= "Slash") then
                result = result.."[[Category:"..key.." Damage Weapons]]"
            end
        end
    end

    if(hasAttack(Weapon, "Secondary")) then
        result = result.."[[Category:Weapons with Alt Fire]]"
    end

    return result
end

function p.buildAugmentTable(frame)
    local result = ""
    result = result..'\n{|class="listtable sortable" style="width:100%;"'
    result = result..'\n|-'
    result = result..'\n! Name'
    result = result..'\n! Category'
    result = result..'\n! Source'
    result = result..'\n! Weapon'

    for i, Augment in pairs(WeaponData["Augments"]) do
        local thisStr = "\n|-"
        thisStr = thisStr.."\n| <span class=\"mod-tooltip\" data-param=\""..Augment.Name.."\" style=\"white-space:pre\">[["..Augment.Name.."]]</span>" --span class = displays the mod tooltip in the table on hover.
        thisStr = thisStr.."\n| "..Augment.Category
        thisStr = thisStr.."\n| [["..Augment.Source.."]]"
        thisStr = thisStr.."\n| "
        for i, weap in pairs(Augment.Weapons) do
            if(i>1) then thisStr = thisStr.."<br/>" end
            thisStr = thisStr.."[["..weap.."]]"
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

function p.buildDamageTypeTable(frame)
    local DamageType = frame.args ~= nil and frame.args[1] or frame
    local Weapons = {}
    local WeapArray = p.getWeapons(function(x) 
                                    local Dmg, Element 
                                    if (hasAttack(x, "Normal")) then
                                        Dmg, Element = GetDamageBias(getAttack(x, "Normal"), true)
                                    elseif(hasAttack(x, "Charge")) then
                                        Dmg, Element = GetDamageBias(getAttack(x, "Charge"), true)
                                    else
                                        return false
                                    end
                                    return Element == DamageType end)

    local procString = Icon._Proc(DamageType,'text')
    local procShort = Icon._Proc(DamageType)
    local result = ""
    local tHeader = '{|class = "listtable sortable" style="margin:auto;"'
    tHeader = tHeader..'\n|-'
    tHeader = tHeader..'\n!Name'
    tHeader = tHeader..'\n!Type'
    tHeader = tHeader..'\n!Class'
    tHeader = tHeader..'\n!'..procString
    tHeader = tHeader..'\n!'..procShort..'%'
    local tRows = ""
    for i, Weapon in pairs(WeapArray) do
        local thisRow = '\n|-\n|'
        thisRow = thisRow.."[["..Weapon.Name.."]]||"..Weapon.Type.."|| "..getValue(Weapon, "Class", true, true)
        if(hasAttack(Weapon, "Normal")) then
            local tempBias = getValue(Weapon, {"Normal", "DamageBias"}, true)
            local tempBiasStripped = string.match(tempBias,"(%d*)%%")
            thisRow = thisRow.."||"..getValue(Weapon, {"Normal", DamageType}).."||".."data-sort-value="..tempBiasStripped.."|"..tempBias
        elseif(hasAttack(Weapon, "Charge")) then
            local tempBias = getValue(Weapon, {"Charge", "DamageBias"}, true)
            local tempBiasStripped = string.match(tempBias,"(%d*)%%")
            thisRow = thisRow.."||"..getValue(Weapon, {"Charge", DamageType}).."||".."data-sort-value="..tempBiasStripped.."|"..tempBias
        end

        tRows = tRows..thisRow
    end
    result = tHeader..tRows.."\n|}"
    return result
end

function p.buildWeaponByMasteryRank(frame)
    local MasteryRank
    local MRTable = {}
    for i, Weapon in Shared.skpairs(WeaponData["Weapons"]) do
        if(Weapon.Mastery ~= nil) then
            if(MRTable[Weapon.Mastery] == nil) then
                MRTable[Weapon.Mastery] = {}
            end
            if(MRTable[Weapon.Mastery][Weapon.Type] == nil) then
                MRTable[Weapon.Mastery][Weapon.Type] = {}
            end
            table.insert(MRTable[Weapon.Mastery][Weapon.Type], Weapon)
        end
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
            local tempList = p.shortLinkList(TypeTable["Primary"])
            for i, text in pairs(tempList) do
                thisTable = thisTable.."\n* "..text
            end
        end

        thisTable = thisTable..'\n| style="vertical-align:top;width:33%;" |'
        if(TypeTable["Secondary"] ~= nil and Shared.tableCount(TypeTable["Secondary"]) > 0) then
            thisTable = thisTable.."\n===Secondary==="
            local tempList = p.shortLinkList(TypeTable["Secondary"])
            for i, text in pairs(tempList) do
                thisTable = thisTable.."\n* "..text
            end
        end

        thisTable = thisTable..'\n| style="vertical-align:top;width:33%;" |'
        if(TypeTable["Melee"] ~= nil and Shared.tableCount(TypeTable["Melee"]) > 0) then
            thisTable = thisTable.."\n===Melee==="
            local tempList = p.shortLinkList(TypeTable["Melee"])
            for i, text in pairs(tempList) do
                thisTable = thisTable.."\n* "..text
            end
        end
        thisTable = thisTable.."\n|}"
        result = result..thisTable
    end
    return result
end

function p.getMasteryShortList(frame)
    local WeaponType = frame.args[1]
    local MasteryRank = tonumber(frame.args[2])

    local weapArray = p.getWeapons(function(x) 
                                    if(x.Type ~= nil and x.Mastery ~= nil) then
                                        return x.Type == WeaponType and x.Mastery == MasteryRank
                                    else
                                        return false
                                    end
                                end)

    local result = ""
    local shortList = p.shortLinkList(weapArray)
    for i, pair in Shared.skpairs(shortList) do
        if(string.len(result) > 0) then result = result.." • " end
        result = result..pair
    end
    return result
end

function p.getRivenDispositionList(frame)
    local WeaponType = frame.args[1]
    local Disposition = tonumber(frame.args[2])

    local weapArray = p.getWeapons(function(x) 
        if(x.Type ~= nil and x.Disposition ~= nil) then
            return (string.upper(WeaponType) == "ALL" or x.Type == WeaponType) and x.Disposition == Disposition
        else
            return false
        end
    end)

    local result = ""
    local shortList = p.shortLinkList(weapArray)
    for i, pair in Shared.skpairs(shortList) do
        result = result..'\n* '..pair
    end
    return result
end

function p.getRivenDispositionTable(frame)
    local WeaponType = frame.args[1]

    local result = '{| class="article-table" border="0" cellpadding="1" cellspacing="1" style="width: 100%"'
    result = result..'\n|-'
    for i = 5, 1, -1 do
        if      (i == 5) then j = 1.5
        elseif  (i == 4) then j = 1.3
        elseif  (i == 3) then j = 1.1
        elseif  (i == 2) then j = 0.89
        else                  j = 0.69 end
        result = result..'\n! scope="col" style="text-align:center;"|'..Icon._Dis(j)
    end
    result = result..'\n|-'
    for i = 5, 1, -1 do
        result = result..'\n| style="vertical-align:top" |'
        if      (i == 5) then
            for j = 1550, 1301, -1 do
                result = result..p.getRivenDispositionList({args = {WeaponType, j/1000}}) end
        elseif  (i == 4) then
            for j = 1300, 1101, -1 do
                result = result..p.getRivenDispositionList({args = {WeaponType, j/1000}}) end
        elseif  (i == 3) then
            for j = 1100, 900, -1 do
                result = result..p.getRivenDispositionList({args = {WeaponType, j/1000}}) end
        elseif  (i == 2) then
            for j = 899, 700, -1 do
                result = result..p.getRivenDispositionList({args = {WeaponType, j/1000}}) end
        else
            for j = 699, 500, -1 do
                result = result..p.getRivenDispositionList({args = {WeaponType, j/1000}}) end
        end
    end
    result = result..'\n|}'

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
    local shortList = p.shortLinkList(weapArray)
    for i, pair in Shared.skpairs(shortList) do
        result = result..'\n* '..pair
    end
    return result
end

--Runs a bunch of things to quickly check if anything broke
function p.checkForBugs(frame)
    return p.buildComparison({args = {"Lato", "Lato Prime"}})..p.buildComparison({args = {"Glaive", "Glaive Prime"}})..p.getMeleeComparisonTable({})..p.getSecondaryComparisonTable({})
end

function p.checkElements(frame)
    local result = "wyrd"
    for key, theWeap in Shared.skpairs(WeaponData["Weapons"]) do
        for attName, Attack in p.attackLoop(theWeap) do
            local elementCount = 0
            if(Attack.Damage ~= nil) then
                for element, dmg in Shared.skpairs(Attack.Damage) do
                    if(not Shared.contains(Physical, element)) then
                        elementCount = elementCount + 1
                    end
                end
            else
                result = result.."\n"..key.." attempted to loop the "..attName.." attack"
            end
            if(elementCount > 1) then
                result = result.."\n"..key.." has "..elementCount.." elements in its "..attName.." attack"
            end
        end
    end
    return result
end

function p.checkForMissingData(frame)
    local result = ""
    for key, weapon in Shared.skpairs(WeaponData["Weapons"]) do
        if(weapon.Name == nil) then
            result = result.."\n"..key.." does not have a Name"
        end
        if(weapon.Image == nil) then
            result = result.."\n"..key.." does not have an Image"
        end
        if(weapon.Mastery == nil) then
            result = result.."\n"..key.." does not have Mastery"
        end
        if(weapon.Disposition == nil and p.isArchwing(weapon) == nil) then
            result = result.."\n"..key.." does not have Disposition"
        end
        if(weapon.Type == nil) then
            result = result.."\n"..key.." does not have a Type"
        end
        if(weapon.Class == nil and p.isArchwing(weapon) == nil) then
            result = result.."\n"..key.." does not have a Class"
        end
        if(weapon.NormalAttack ~= nil and weapon.NormalAttack.Damage == nil) then
            result = result.."\n"..key.." does not do Normal Attacks"
        end
    end
    if (result == "") then
        result = "All weapons complete based on this test"
    end
    return result
end

function p.buildTunaWeaponTable(frame)
    local Category = frame.args ~= nil and frame.args[1] or frame
    local Weapons = p.getWeapons( function(x)
                                    return getValue(x, "Type", true) == Category
                                end)

    local result = '{| style="margin:auto;text-align:center;"'
    local i = 0
    for key, Weapon in Shared.skpairs(Weapons) do
        i = i + 1
        local theImage = Weapon.Image ~= nil and Weapon.Image or "Panel.png"
        if((i - 1) % 7 == 0) then 
            result = result..'\n|-'
        end
        result = result..'\n| style="width:85px" |[[File:'..Weapon.Name..'.png|70px]]'
    end
    result = result..'\n|}'
    return result
end

-- and we are back... new table building functions !

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
                    result = result..td..'style="'..styleString..'"|'..getValue(Weapon, ValName, true, true, true)
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
    return  tHeader..tRows.."\n|}[[Category:Automatic Comparison Table]]"
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
	elseif(Catt == "Robotic") then WeapArray = p.getWeapons(function(x) 
                                    return getValue(x, "Type", true) == "Robotic"
                                    end)
    else return "\n Error : Wrong Class (use Primary, Secondary, or Robotic) [[Category:Invalid Comp Table]]"
    end

	local Head={{"Name",false,"Name"}}
	 -- better if Name is always the first column !!!
	table.insert(Head,{"Trigger",false,"[[Fire Rate|Trigger Type]]"})
	table.insert(Head,{{"default","Damage"},true,"[[Damage]]"})
	table.insert(Head,{{"default", "CritChance"},true,"[[Critical Chance]]"})
	table.insert(Head,{{"default", "CritMultiplier"},true,"[[Critical multiplier|Critical Damage]]"})
	table.insert(Head,{{"default", "StatusChance"},true,"[[Status Chance]]"})
	table.insert(Head,{{"default","BulletType"},false,"Projectile Type"})
	table.insert(Head,{{"default", "FireRate"},true,"[[Fire Rate]]"})
	table.insert(Head,{"Magazine",true,"[[Ammo#Magazine Capacity|Magazine Size]]"})
	table.insert(Head,{"Reload",true,"[[Reload Speed|Reload Time]]"})
	table.insert(Head,{"Mastery",true,"[[Mastery Rank]]"})
	table.insert(Head,{"Disposition",true,"[[Riven Mods#Disposition|Disposition]]"})

    return BuildCompTable(Head, WeapArray, true)
end

function p.getCompTableConclaveGuns(frame)
    local Catt = frame.args ~= nil and frame.args[1]
    local Type = frame.args ~= nil and frame.args[2] or nil
        if(Type == "All") then Type = nil end
    local WeapArray = {}
    if(Catt == "Primary") then WeapArray = p.getConclaveWeapons(function(x) 
                                if((getValue(x, "Type", true) == "Primary") and (getValue(x, "Conclave", true) == true)) then
                                    if(Type ~= nil) then return getPrimaryCategory(x) == Type else return true end
                                end
                                    return false
                                end)
    elseif(Catt == "Secondary") then WeapArray = p.getConclaveWeapons(function(x) 
                                if((getValue(x, "Type", true) == "Secondary") and (getValue(x, "Conclave", true) == true)) then
                                    if(Type ~= nil) then return getSecondaryCategory(x) == Type else return true end
                                end
                                    return false
                                end)
    else return "\n Error : Wrong Class (use Primary or Secondary) [[Category:Invalid Comp Table]]"
    end

	local Head={{"Name",false,"Name"}}
	 -- better if Name is always the first column !!!
	table.insert(Head,{"Trigger",false,"[[Fire Rate|Trigger Type]]"})
	table.insert(Head,{{"default","Damage"},true,"[[Damage]]"})
	table.insert(Head,{"HeadshotMultiplier",true,"HS Multiplier"})
	table.insert(Head,{{"default","BulletType"},false,"Projectile Type"})
	table.insert(Head,{"FireRate",true,"[[Fire Rate]]"})
	table.insert(Head,{"Magazine",true,"[[Ammo#Magazine Capacity|Magazine Size]]"})
	table.insert(Head,{"Reload",true,"[[Reload Speed|Reload Time]]"})
	table.insert(Head,{"Mastery",true,"[[Mastery Rank]]"})

    return BuildCompTable(Head,WeapArray)
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
	table.insert(Head,{"Trigger",false,"[[Fire Rate|Trigger Type]]"})
	table.insert(Head,{{"default","Damage"},true,"[[Damage]]"})
	table.insert(Head,{"CritChance",true,"[[Critical Chance]]"})
	table.insert(Head,{"CritMultiplier",true,"[[Critical multiplier|Critical Damage]]"})
	table.insert(Head,{"StatusChance",true,"[[Status Chance]]"})
	table.insert(Head,{{"default","BulletType"},false,"Projectile Type"})
	table.insert(Head,{"FireRate",true,"[[Fire Rate]]"})
	table.insert(Head,{"Magazine",true,"[[Ammo#Magazine Capacity|Magazine Size]]"})
	table.insert(Head,{"Reload",true,"[[Reload Speed|Reload Time]]"})
	table.insert(Head,{"Mastery",true,"[[Mastery Rank]]"})
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
	table.insert(Head,{{"Normal","Damage"},true,"[[Damage|Normal]]"})
	table.insert(Head,{"SlideAttack",true,"[[Melee#Slide Attack|Slide]]"})
	table.insert(Head,{{"default","FireRate"},true,"[[Attack Speed]]"})
	table.insert(Head,{"CritChance",true,"[[Critical Chance]]"})
	table.insert(Head,{"CritMultiplier",true,"[[Critical multiplier|Critical Damage]]"})
	table.insert(Head,{"StatusChance",true,"[[Status Chance]]"})
	table.insert(Head,{"Mastery",true,"[[Mastery Rank]]"})
	table.insert(Head,{"STANCEPOLARITY",false,"[[Stance]]"})
	table.insert(Head,{"Disposition",true,"[[Riven Mods#Disposition|Disposition]]"})
	for k, v in pairs(Head[1]) do mw.log(k, v) end

    return BuildCompTable(Head,WeapArray)
end

--As above, but for conclave
function p.getCompTableConclaveMelees(frame)
    local Type = frame.args ~= nil and frame.args[1] or nil
    if(Type == "All") then Type = nil end
    local WeapArray = {}
    WeapArray = getConclaveMeleeWeapons(Type)
    local addClass = Type == nil or Shared.contains(Type, ",")

	local Head={{"Name",false,"Name"}}
	 -- better if Name is always the first column !!!
	table.insert(Head,{"Class",false,"Type"})
	table.insert(Head,{{"Normal","Damage"},true,"[[Damage|Normal]]"})
	table.insert(Head,{"SlideAttack",true,"[[Melee#Slide Attack|Slide]]"})
	table.insert(Head,{{"default","FireRate"},true,"[[Attack Speed]]"})
	table.insert(Head,{"Mastery",true,"[[Mastery_Rank|Mastery Rank]]"})
	table.insert(Head,{"STANCEPOLARITY",false,"[[Stance]]"})
	for k, v in pairs(Head[1]) do mw.log(k, v) end

    return BuildCompTable(Head,WeapArray)
end

function p.getCompTableArchMelees(frame)
    local WeapArray = {}
    WeapArray = p.getWeapons(function(x) 
                                    return getValue(x, "Type", true) == "Arch-Melee"
                                end)

	local Head={{"Name",false,"Name"}}
	 -- better if Name is always the first column !!!
	table.insert(Head,{{"Normal","Damage"},true,"[[Damage|Normal]]"})
	table.insert(Head,{"SlideAttack",true,"[[Melee#Slide Attack|Slide]]"})
	table.insert(Head,{{"default","FireRate"},true,"[[Attack Speed]]"})
	table.insert(Head,{"CritChance",true,"[[Critical Chance]]"})
	table.insert(Head,{"CritMultiplier",true,"[[Critical multiplier|Critical Damage]]"})
	table.insert(Head,{"StatusChance",true,"[[Status Chance]]"})
	table.insert(Head,{"Mastery",true,"[[Mastery Rank]]"})
	for k, v in pairs(Head[1]) do mw.log(k, v) end

    return BuildCompTable(Head,WeapArray)
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
	elseif(Catt == "Robotic") then WeapArray = p.getWeapons(function(x) 
                                    return getValue(x, "Type", true) == "Robotic"
                                    end)
	elseif(Catt == "Arch-Gun") then WeapArray = p.getWeapons(function(x) 
                                    return getValue(x, "Type", true) == "Arch-Gun"
                                    end)
    else return "\n Error : Wrong Class (use Primary, Secondary, Robotic, or Arch-Gun) [[Category:Invalid Comp Table]]"
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

	local Head={{"Name",false,"Name"}}
	 -- better if Name is always the first column !!!
	table.insert(Head,{"Class",false,"Type"})
	table.insert(Head,{{"Normal","PROJECTILESPEED"},true,"Flight Speed"})
	table.insert(Head,{{"Charge","PROJECTILESPEED"},true,"Charge Flight Speed"})
	table.insert(Head,{"SPECIALFSPEED",true,"Alt-Fire / Special"})

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

	local Head={{"Name",false,"Name"}}
	 -- better if Name is always the first column !!!
	table.insert(Head,{{"Normal","PROJECTILESPEED"},true,"Flight Speed"})
	table.insert(Head,{"SPECIALFSPEED",true,"Special"})

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

        if link == weapName then
            linkText = '[['..namespace..link..'|'..link..']]'
        elseif link then
            linkText = '[['..namespace..link..'|'..weapName..']]'
        else
            linkText = '[['..namespace..weapName..'|'..weapName..']]'
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
        A2Name = 'Type'
        A2Value = 'Class'
        C1Name = 'Atk. Speed'
        C1Value = 'FireRate'
        C1Toggle = true
        C2Name = 'Slide Atk.'
        C2Value = 'SlideAttack'
        D1Name = 'Polarities'
        D1Value = 'Polarities'
        D1Value2 = 'StancePolarity'
    else
        A2Name = 'Trigger'
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
        C2Name = 'Noise'
        C2Value = 'NoiseLevel'
        D1Name = 'Polarities'
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

function p.test(WeapName)
    local Weapon = p.getWeapon(WeapName)

    return BuildGunComparisonDisplay(Weapon)
end

return p