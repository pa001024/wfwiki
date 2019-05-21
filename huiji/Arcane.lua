--Duplicating Module:Focus for Arcanes
--go away error messages
--

local p = {}

local ArcaneData = mw.loadData( 'Module:Arcane/data' )
local Shared = require( 'Module:Shared' )
local trans = require("Module:Translate")

function p.getValueRaw(frame)
    local ArcaneName = frame.args[1]
    local ValName = frame.args[2]
    return ArcaneData["Arcanes"][ArcaneName][ValName]
end

function p.getValue(frame)
    local ArcaneName = frame.args ~= nil and frame.args[1] or nil
    local ValName = frame.args ~= nil and frame.args[2] or nil
    
    local value = p.Value(ArcaneName,ValName)
    if value ~= nil then
        return value
    else
        return "Name or value incorrect"
    end
end

function p.Value(ArcaneName, ValName)
    if(ArcaneName == nil) then
        return "ERROR: No arcane specified"
    elseif(ValName == nil) then
        return "ERROR: No value specified"
    end
    
    ArcaneName = Shared.trim(ArcaneName)
    ValName = Shared.trim(ValName)
    if(ArcaneData["Arcanes"][ArcaneName] == nil) then
        return nil
    end
    
    local Arcane = ArcaneData["Arcanes"][ArcaneName]
    
    local UpName = string.upper(ValName)
    if(UpName == "NAME") then
        return ArcaneName
    elseif(UpName == "IMAGE") then
        if(Arcane.Image ~= nil) then
            return Arcane.Image
        else
            return "Arcane Placeholder 160.png"
        end
    elseif(UpName == "DESC4") then
        if(Arcane.Desc4 ~= nil) then
            return Arcane.Desc4
        else
            return "nil"
        end
    elseif(UpName == "CRITERIA") then
        if(Arcane.Criteria ~= nil) then
            return Arcane.Criteria
        else
            return "nil"
        end
    elseif ArcaneData["Arcanes"][ArcaneName][ValName] ~= nil then
        return ArcaneData["Arcanes"][ArcaneName][ValName]
    end
    return nil
end

function p.tooltipText(frame)
    local ArcaneName = frame.args ~= nil and frame.args[1] or nil
    local renamed = frame.args ~= nil and frame.args[2] or nil
    if renamed == '' then
        renamed = nil
    end
    local param2 = ''
    
    if ArcaneName == nil then
        return '<span style="color:red;">{{[[Template:Arcane|Arcane]]}}</span>Enter Arcane\'s name'
    end
    
    local link = '[['..ArcaneName..']]'
    local icon = p.Value(ArcaneName,"Icon")
    if icon == nil then
        icon = "CosmeticEnhancer.png" --default icon for Arcanes
    end
    
    local name = p.Value(ArcaneName,"Name")
    local zhName = trans.toChineseCI(name)
    if name ~= nil then
        local link = '[['..name..'|'..zhName..']]'
        if renamed ~= nil then
            param2 = ' data-name="'..renamed..'"'
            link = '[['..name..'|'..renamed..']]'
        end
        return '<span class="arcane-tooltip" data-param="'..name..'"'..param2..' style="white-space:pre">[[File:'..icon..'|x19px|link='..name..']] '..link..'</span>'
    else
        return '<span style="color:red;">{{[[Template:Arcane|Arcane]]}}</span> "'..ArcaneName..'" not found[[Category:Arcane '..'Tooltip error]]'
    end
end

function p.tooltip(frame)
    local ArcaneName = frame.args ~= nil and frame.args[1] or nil
    local renamed = frame.args ~= nil and frame.args[2] or nil
    if renamed == '' then
        renamed = nil
    end
    
    local name = p.Value(ArcaneName,"Name")
    local zhName = trans.toChineseCI(name)
    if name ~= nil then
    
        local image = p.Value(ArcaneName,"Image")
        if image == nil then
            image = "CosmeticEnhancer.png" --default image for Arcanes
        end
        result ={'{| class="Tooltip"\n|-\n| style="padding:0px;"|\n{| class="Sub"\n|-\n| class="Image"| [[File:'..image..'|160px]]\n|-\n| class="Spacer"|'}
        if renamed ~= nil then
            table.insert(result,('\n|-\n! class="Title"|'..zhName..'\n|-\n| class="Spacer"|'))
        end
        local criteria = p.Value(ArcaneName,"Criteria")
        local desc = p.Value(ArcaneName,"Desc4")
        table.insert(result,('\n|-\n| style="background-color: #0D1B1C; color: #eeeeee; padding: 10px; font-size:13px; line-height: 16px;"|<span style="font-weight: bold;font-size: 14px;">Rank 3:</span> '..criteria..'<br>'..desc..'\n|}\n|-\n|}'))
    else
        return "Something went from with Module:Arcane (p.tooltip)"
    end
    return table.concat(result)
end

return p