--Eventually to be used for ability tooltip.
--First version will be for pulling ability icons for Warframe tooltip

local p ={}

local AbilityData = mw.loadData( "Module:Ability/data" )
local ConclaveData = mw.loadData( "Module:Ability/Conclave/data" )
local WarframeData = mw.loadData( 'Module:Warframes/data' )
local Shared = require( "Module:Shared" )
local trans = require("Module:Translate")

local function getAbility(abiName, conclave)
    local dataName = AbilityData
    if conclave then
        dataName = ConclaveData
    end
    local temp = dataName["Ability"][abiName]
    if temp ~= nil and type(temp) == "table" then
        return temp
    else
        return nil
    end
end

local function getAbilityData(abiName, valName)
    local ability = getAbility(abiName)
    return ability[valName]
end

local function getWarframe(FrameName) --NOTE: Copied from Module:Warframes. Apparently two modules can't `require` each other. That causes infinite loop.
    local warframe = WarframeData["Warframes"][FrameName]
    if warframe ~= nil and warframe.Name == FrameName then
        return warframe
    else
        for key, Warframe in Shared.skpairs(WarframeData["Warframes"]) do
            if(Warframe.Name == FrameName or key == FrameName) then
                return Warframe            
            end
        end
    end
    return nil
end

local function getAbilityList(Warframe)
    local WarframeTemp = mw.text.split(Warframe, " ", true)
    if WarframeTemp[2] == "Umbra" then
        local temp = AbilityData["Warframe"][Warframe]
        if temp ~= nil then
            return temp
        end
    else
        local temp = AbilityData["Warframe"][WarframeTemp[1]]
        if temp ~= nil then
            return temp
        end
    end
end

function p.getValue(frame)
    local abiName = frame.args ~= nil and frame.args[1] or nil
    local valName = frame.args ~= nil and frame.args[2] or nil
    local ability = getAbility(abiName)
    if ability ~= nil then
        local temp = ability[valName]
        if temp ~= nil then
            return temp
        else
            return "Check the value name"
        end
    else
        return "Check the ability name"
    end
end

local function getValue(ability, valName)
    if ability ~= nil then
        local temp = ability[valName]
        if temp ~= nil then
            return temp
        else
            return "Check the value name"
        end
    else
        return "Check the ability name"
    end
end

local function getLink(ability)
    local temp = ability["Link"]
    if temp ~= nil then
        return temp
    else
        return nil
    end
end

function p.getAbilityIcons(frame)
    local Warframe = frame.args[1]
    local abilities = getAbilityList(Warframe)
    local result = ""
    if abilities == nil then
        return "Data not found"
    end
    for i, ability in pairs(abilities) do
        local fileName = getAbilityData(ability, "DarkIcon")
        result = result.."[[File:"..fileName.."|42px]]"
    end
    return result
end

function p.getAbilityIconsList(wfName)
--Used in M:Warframes-p.tooltip
    local abilities = getAbilityList(wfName)
    local result = ""
    if abilities == nil then
        return "Data not found"
    end
    for i, ability in pairs(abilities) do
        local fileName = getAbilityData(ability, "WhiteIcon")
        result = result.."[[File:"..fileName.."|30px]]".." "..ability
        if i < 4 then
            result = result.."<br>"
        end
    end
    return result
end

function p.tooltipText(frame)
    local abiName = frame.args ~= nil and frame.args[1]
    local conclave = frame.args["Conclave"] == "true" and true
    local aConclave = false
    local conclaveParam = ''
    local ability = getAbility(abiName)
    local namespace = ''
    
    if ability ~= nil then
        local wfName = nil
        if conclave then
            wfName = ability.Warframe
            local warframe = getWarframe(wfName)
            aConclave = warframe.Conclave
            if aConclave then
                namespace = 'Conclave:'
                conclaveParam = ' data-param2="true"'
            end
        end
        
        local link = getLink(ability)
        if link == nil then
            link = abiName
        end
        local zhName = trans.toChineseCI(link)
        local linkText = '[['..namespace..link..'|'..zhName..']]'
        
        if link == nil then link = abiName end
        
        return '<span class="ability-tooltip" data-param="'..abiName..'"'..conclaveParam..' style="white-space:pre">'..'[[File:'..getValue(ability,"DarkIcon",true)..'|x19px|link='..namespace..link..']] '..linkText..'</span>'
    else
        return '<span style="color:red">{{[[Template:A|Ability]]}} '..abiName..' not found[[Category:Ability '..'Tooltip error]]</span>'
    end
end

function p.tooltip(frame)
    local abiName = frame.args ~= nil and frame.args[1] or nil
    local conclave = frame.args[2] == "true" and true
    local aConclave = false --availableInConclave
    local conclaveNotice = ''
    local ability = getAbility(abiName)
    local cAbility = nil
    
    if ability == nil then
        return "Data not found"
    end
    
    local wfName = nil
    if conclave then
        wfName = ability.Warframe
        local warframe = getWarframe(wfName)
        aConclave = warframe.Conclave
        if aConclave then
            cAbility = getAbility(abiName, true)
        end
    end
    
    if conclave and aConclave == false then
        conclaveNotice = '\n{| class="Data" style="font-size:10px; white-space:normal;"\n|-\n|Note: Not available in Conclave, displaying Cooperative stats and Cooperative Link.\n|}'
    end

    local description = ability["Description"]
    if cAbility ~= nil then
        description = cAbility["Description"]
    end
    
    local key = '<span style="position:relative; background-color:#272727;color:white;padding:1px 4px;border:2px solid #aaadb4;border-radius:5px;font-size:12px;">'..ability["Key"]..'</span>'

    local result = '{| class="Sub" style="width:500px;"\n|-\n| class="Spacer" style="padding:0;"| [[File:'..ability["CardImage"]..'|130px]]\n| class="Spacer"|'
    result = result..'\n| class="Data" style="line-height:20px; text-align:center; width:64px; padding:2px;"| [[File:'..ability["WhiteIcon"]..'|48px]]<br><div style="display:inline-block; margin: 4px 2px 8px 2px;"><div style="display:inline-block; position:relative; top:-2px;">[[File:EnergyIcon32x.png|18px]]</div> <span style="font-size:14px; font-weight:bold;">'..ability["Cost"]..'</span></div><br><div style="display:inline-block;">'..key..'</div>'
    result = result..'\n| class="Spacer"|\n| class="Data" style="font-size:13px; line-height:16px; padding:2px 3px 2px 3px; white-space:normal;"|<span style="font-weight:bold; font-size:15px;">'..ability["Warframe"]..'</span><br>'..description..conclaveNotice..'\n|}'
    
    return result
end

function p.getAbilityReplaceList(frame)
    --local Type = frame.args ~= nil and frame.args[1] or frame
    local fullList = {}
    
    --local avoidNames ={'Exalted Blade (Umbra)','Corvas (Atmosphere)','Cyngas (Atmosphere)','Dargyn','Dual Decurion (Atmosphere)','Fluctus (Atmosphere)','Grattler (Atmosphere)','Imperator (Atmosphere)','Imperator Vandal (Atmosphere)','Phaedra (Atmosphere)','Rampart','Velocitus (Atmosphere)'}
    
    local function addToList(name,link)
        if link == nil then
            link = name
        end
        --local 6s = '      '
        --local 8s = '        '
        local temp = '      <Replacement>\n        <Find>\[\['..link..']]</Find>\n        <Replace>{{A|'..name..'}}</Replace>\n        <Comment />\n        <IsRegex>false</IsRegex>\n        <Enabled>true</Enabled>\n         <Minor>false</Minor>\n        <BeforeOrAfter>false</BeforeOrAfter>\n        <RegularExpressionOptions>IgnoreCase</RegularExpressionOptions>\n      </Replacement>'
        return table.insert(fullList,temp)
    end
    
    for i, val in Shared.skpairs(AbilityData["Ability"]) do
        if not Shared.contains(avoidNames,i) then
            
            addToList(i,val.Link)
        end
    end

    return table.concat(fullList, "\n")
end

return p
