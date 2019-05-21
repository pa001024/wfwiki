--WARFRAME Wiki Icon Module
--http://warframe.wikia.com/
--Written by User:ChickenBar

local p = {}

local IconData = mw.loadData( 'Module:Icon/data' )


function p.Item(frame)
	local iconname = frame.args[1]
	local textexist = frame.args[2]
	local imagesize = frame.args.imgsize
 
	return p._Item(iconname, textexist, imagesize)
end

--Extracting out to this function allows other Modules to call item text
--Since any templates output by another module won't be parsed by the wiki
function p._Item(iconname, textexist, imagesize)
	local iconname = string.gsub(" "..string.lower( iconname ), "%W%l", string.upper):sub(2)
	local link = ''
	if IconData["Items"][iconname] == nil then
		return "<span style=\"color:red;\">Invalid</span>[[Category:Icon Module error]]"  
	else
		link = IconData["Items"][iconname]["link"]
		title = IconData["Items"][iconname]["title"]
		iconname = IconData["Items"][iconname]["icon"]
		if (imagesize == nil or imagesize == '') then
			imagesize = 'x26'
		end
		
		local imgText = '[[File:'..iconname..'|'..imagesize..'px'
		if(link ~= nil) then
			imgText = imgText..'|link='..link
		elseif(title~=nil) then
			imgText = imgText..'|'..title
		end
		imgText = imgText..']]'
		
		if (textexist == 'text' or textexist == 'Text') then
			if (link ~= nil) then
				return imgText..' [['..link..']]'
			elseif (title ~= nil) then
				return imgText..' '..title
			else
				return imgText
			end
		end
		return imgText
	end
end

function p.Pol(frame)
    local iconname = frame.args[1]
    local color = frame.args[2]
    local imagesize = frame.args.imgsize
    return p._Pol(iconname, color, imagesize)
end

function p._Pol(iconname, color, imagesize)
    if IconData["Polarities"][iconname] == nil then          
        return "<span style=\"color:red;\">Invalid</span>"  
    else
        if color == 'white' then
            iconname = IconData["Polarities"][iconname]["icon"][2] --white icon
        else
            iconname = IconData["Polarities"][iconname]["icon"][1] --black icon
        end
        if (imagesize == nil or imagesize == '') then
            imagesize = 'x20'                                 
        end
        return '[[File:'..iconname..'|'..imagesize..'px|link=Polarity]]'
    end
end

function p.Dis( frame )
    local name = frame.args[1]
    local color = frame.args[2]
    local size = frame.args.imgsize
    return p._Dis(name, color, size)
end

function p._Dis(name, color, size)
    local link = 'Riven_Mods#Disposition'
    if(color == nil or color == '') then color = 'black' end
    if(size  == nil or size  == '') then size  = 27      end
    if name  == nil then          
        return "<span style=\"color:red;\">Invalid</span>"  
    else
        name = tonumber(name)
        if    (name < 0.7) then return '[['..link..'|<span style="font-size:'..size..'px; color:'..color..'; display:inline; position:relative; top:2px">●○○○○</span>]]'
        elseif(name < 0.9) then return '[['..link..'|<span style="font-size:'..size..'px; color:'..color..'; display:inline; position:relative; top:2px">●●○○○</span>]]'
        elseif(name <= 1.1) then return '[['..link..'|<span style="font-size:'..size..'px; color:'..color..'; display:inline; position:relative; top:2px">●●●○○</span>]]'
        elseif(name <= 1.3) then return '[['..link..'|<span style="font-size:'..size..'px; color:'..color..'; display:inline; position:relative; top:2px">●●●●○</span>]]'
        else                     return '[['..link..'|<span style="font-size:'..size..'px; color:'..color..'; display:inline; position:relative; top:2px">●●●●●</span>]]' end
    end
end

function p.Affinity( frame )
    local iconname = frame.args[1]
    local textexist = frame.args[2]
    local imagesize = frame.args.imgsize
    return p._Affinity(iconname, textexist, imagesize)
end

function p._Affinity(iconname, textexist, imagesize)
    local link = ''
    if IconData["Affinity"][iconname] == nil then          
		return "<span style=\"color:red;\">Invalid</span>"  
	else
		link = IconData["Affinity"][iconname]["link"]
        local imgname = IconData["Affinity"][iconname]["icon"]
		if (imagesize == nil or imagesize == '') then
			imagesize = 'x26'                                 
		end
		if (textexist == 'text' or textexist == 'Text') then                           
			return '[[File:'..imgname..'|'..imagesize..'px|link='..link..']] [['..link..'|'..iconname..']]'
		end
		return '[[File:'..imgname..'|'..imagesize..'px|link='..link..']]'
	end
end

function p.Faction( frame )
        local iconname = frame.args[1]        
	    local textexist = frame.args[2]          
        local color = frame.args[3]
        local imagesize = frame.args.imgsize
        local link = ''
        if IconData["Factions"][iconname] == nil then          
              return '[['..iconname..']]'  
        else
           link = IconData["Factions"][iconname]["link"]
           if color == 'white' then
              iconname = IconData["Factions"][iconname]["icon"][2]   --white icon
           else
	      iconname = IconData["Factions"][iconname]["icon"][1]   --black icon
	   end
           if (imagesize == nil or imagesize == '') then
              imagesize = 'x20'                                 
           end
	   if (textexist == 'text' or textexist == 'Text') then                           
              return '[[File:'..iconname..'|'..imagesize..'px|link='..link..']][['..link..']]'
           end
	   return '[[File:'..iconname..'|'..imagesize..'px|link='..link..']]'
        end
end

function p.Syndicate( frame )
    local iconname = frame.args[1]        
    local textexist = frame.args[2]          
    local color = frame.args[3]
    local imagesize = frame.args.imgsize
    
    local link = ''
    
    if IconData["Syndicates"][iconname] == nil then          
        return ""  
    end
    
    link = IconData["Syndicates"][iconname]["link"]
    if color == 'white' then
        iconname = IconData["Syndicates"][iconname]["icon"][2]   --white icon
    else
        iconname = IconData["Syndicates"][iconname]["icon"][1]   --black icon
    end
    
    if (imagesize == nil or imagesize == '') then
        imagesize = 'x32'
    end
    
    if (textexist == 'text' or textexist == 'Text') then
        return '[[File:'..iconname..'|'..imagesize..'px|link='..link..']][['..link..']]'
    else
        return '[[File:'..iconname..'|'..imagesize..'px|link='..link..']]'
    end
end

function p.Prime(frame)
    local primename = frame.args[1]
    local partname = frame.args[2]
    local imagesize = frame.args.imgsize
    return p._Prime(primename, partname, imagesize)
end

function p._Prime(primename, partname, imagesize)
    local primename = string.gsub(" "..string.lower( primename ), "%W%l", string.upper):sub(2)
    if(textexist == nil) then textexist = 'text' end
    
    local link = ''
    if IconData["Primes"][primename] == nil then          
        return "Unconfirmed Item"
    end
    
    link = IconData["Primes"][primename]["link"]
    iconname = IconData["Primes"][primename]["icon"]
    if (imagesize == nil or imagesize == '') then
        imagesize = '32'                                 
    end
    
    if partname ~= nil then 
        partname = string.gsub(" "..string.lower( partname ), "%W%l", string.upper):sub(2) 
        
        local result = ''
        if primename == "Forma" then
            result =  '[[File:'..iconname..'|x'..imagesize..'px|link='..link..']]'
            result = result..' [['..link..'#Acquisition|'..primename.." "..partname..']]'
        else 
            result = '[[File:'..iconname..'|x'..imagesize..'px|link='..link..']]'
            result = result..' [['..link..'#Acquisition|'..primename..' Prime '..partname..']]'
        end
        return result
    end

    return '[[File:'..iconname..'|x'..imagesize..'px|link='..link..']]'
end

function p.Resource( frame )
    local iconname = frame.args[1]        
    local textexist = frame.args[2]
    local imagesize = frame.args.imgsize
 
    return p._Resource(iconname, textexist, imagesize)
end

function p._Resource(iconname, textexist, imagesize)
    local link = ''
    if IconData["Resources"][iconname] == nil then          
        if (textexist == 'text' or textexist == 'Text') then                           
            return '[['.. iconname ..']]'
        end
        -- TODO: A placeholder icon and do this for all the item types
        return ""
    else
        link = IconData["Resources"][iconname]["link"]
        iconname = IconData["Resources"][iconname]["icon"]
        if (imagesize == nil or imagesize == '') then
            imagesize = 'x32'                                 
        end
        if (textexist == 'text' or textexist == 'Text') then                           
            return '[[File:'..iconname..'|'..imagesize..'px|link='..link..']] [['..link..']]'
        end
        return '[[File:'..iconname..'|'..imagesize..'px|link='..link..']]'
    end
end

function p.Fish( frame )
    local iconname = frame.args[1]        
    local textexist = frame.args[2]
    local imagesize = frame.args.imgsize
 
    return p._Fish(iconname, textexist, imagesize)
end

function p._Fish(iconname, textexist, imagesize)
    local link = ''
    if IconData["Fish"][iconname] == nil then          
        return ""  
    else
        link = IconData["Fish"][iconname]["link"]
        iconname = IconData["Fish"][iconname]["icon"]
        if (imagesize == nil or imagesize == '') then
            imagesize = 'x32'                                 
        end
        if (textexist == 'text' or textexist == 'Text') then                           
            return '[[File:'..iconname..'|'..imagesize..'px|link='..link..']] [['..link..'|'..title..']]'                         
        end
        return '[[File:'..iconname..'|'..imagesize..'px|link='..link..']]'
    end
end

function p.Proc( frame )
    local iconname = frame.args[1]        
    local textexist = frame.args[2]          
    local color = frame.args[3]
    local imagesize = frame.args.imgsize
    local ignoreColor = frame.args.ignoreColor
    if(ignoreColor ~= nil and string.upper(ignoreColor) ~= "NO" and string.upper(ignoreColor) ~= "FALSE") then
        ignoreColor = true
    else
        ignoreColor = false
    end
    return p._Proc(iconname, textexist, color, imagesize, ignoreColor)
end

function p._Proc(iconname, textexist, color, imagesize, ignoreTextColor)
    local link = ''
    local iconFile = ""
    local textcolor = ''
    local title = ''
    local span1 = ''
    local span2 = ''
    
    if (string.upper(iconname) == "UNKNOWN") then
        return ""
    elseif IconData["Procs"][iconname] == nil then          
        return "<span style=\"color:red;\">Invalid</span>"
    else
        local spanTable = tooltipSpan(iconname, "Proc")
        if spanTable then
            span1 = spanTable[1]
            span2 = spanTable[2]
        end
        local tooltip = IconData["Procs"][iconname]["title"]
        link = IconData["Procs"][iconname]["link"]
        if color == 'white' then
            iconFile = IconData["Procs"][iconname]["icon"][2]   --white icon
        else
            iconFile = IconData["Procs"][iconname]["icon"][1]   --black icon
        end
    
        if (imagesize == nil or imagesize == '') then
            imagesize = 'x18'                                 
        end
        if (textexist == 'text' or textexist == 'Text') then  
            textcolor = IconData["Procs"][iconname]["color"]
            if(ignoreTextColor == nil or not ignoreTextColor) then
                if(tooltip ~= nil and tooltip ~= '') then
                    return span1..'[[File:'..iconFile..'|'..imagesize..'px|link='..link..'|'..tooltip..']] [['..link..'|<span style=\"color:'..textcolor..';\">'..iconname..'</span>]]'..span2
                else
                    return span1..'[[File:'..iconFile..'|'..imagesize..'px|link='..link..']] [['..link..'|<span style=\"color:'..textcolor..';\">'..iconname..'</span>]]'..span2
                end
            else
                if(tooltip ~= nil and tooltip ~= '') then
                    return span1..'[[File:'..iconFile..'|'..imagesize..'px|link='..link..'|'..tooltip..']] [['..link..'|'..iconname..']]'..span2
                else
                    return span1..'[[File:'..iconFile..'|'..imagesize..'px|link='..link..']] [['..link..'|'..iconname..']]'..span2
                end
            end 
        end
        if(tooltip ~= nil and tooltip ~= '') then
            return span1..'[[File:'..iconFile..'|'..imagesize..'px|link='..link..'|'..tooltip..']]'..span2
        else
            return span1..'[[File:'..iconFile..'|'..imagesize..'px|link='..link..']]'..span2
        end
    end
end

function p.Focus( frame )
    local iconname = frame.args[1]
    local textexist = frame.args[2]
    local color = frame.args[3]
    local icontype = frame.args[4]
    local imagesize = frame.args.imgsize
    if IconData["Focus"][iconname] == nil then          
        return "<span style=\"color:red;\">Invalid</span>"  
    else
        if icontype == 'seal' then
            if color == 'white' then
                iconname = IconData["Focus"][iconname]["seal"][2]
            else
                iconname = IconData["Focus"][iconname]["seal"][1]
            end
        else
            if color == 'white' then
                iconname = IconData["Focus"][iconname]["icon"][2]
            else
                iconname = IconData["Focus"][iconname]["icon"][1]
            end
        end
            if (imagesize == nil or imagesize == '') then
              imagesize = 'x20'
           end
           if (textexist == 'text' or textexist == 'Text') then  
              textcolor = IconData["Focus"][frame.args[1]]["color"]                 
              return '[[File:'..iconname..'|'..imagesize..'px|sub|link=Focus]][[Focus|'..frame.args[1]..']]'
          end
          return '[[File:'..iconname..'|'..imagesize..'px|link=Focus]]'
      end
end

function p.Way( frame )
        local iconname = frame.args[1]
        local imagesize = frame.args.imgsize
        local link = ''
        if IconData["Ways"][iconname] == nil then          
              return "<span style=\"color:red;\">Missing<br>Icon</span>"  
        else
	        iconname = IconData["Ways"][iconname]
	    end
        if (imagesize == nil or imagesize == '') then
            imagesize = 'x18'
        end
	    return '[[File:'..iconname..'|'..imagesize..'px|link='..link..']]'
end


function p.HUD( frame )
        local iconname = frame.args[1]        
	    local textexist = frame.args[2]          
        local color = frame.args[3]
        local imagesize = frame.args.imgsize
        local link = ''
        if IconData["Heads-Up Display"][iconname] == nil then          
              return '[['..iconname..']]'  
        else
           link = IconData["Heads-Up Display"][iconname]["link"]
           if color == 'white' then
              iconname = IconData["Heads-Up Display"][iconname]["icon"][2]   --white icon
           else
	      iconname = IconData["Heads-Up Display"][iconname]["icon"][1]   --black icon
	   end
           if (imagesize == nil or imagesize == '') then
              imagesize = 'x20'                                 
           end
	   if (textexist == 'text' or textexist == 'Text') then                           
              return '[[File:'..iconname..'|'..imagesize..'px|link=Heads-Up Display]][[Heads-Up Display|'..link..']]'
           end
	   return '[[File:'..iconname..'|'..imagesize..'px|link=Heads-Up Display]]'
        end
end

function p.Flag( frame )
    local iconname = frame.args[1]
    local tooltip = frame.args[2]
    local dest = frame.args[3]        
	local textexist = frame.args[4]
    if IconData["Flags"][iconname] == nil then          
        return "<span style=\"color:red;\">Invalid</span>"  
    else
        iconname = IconData["Flags"][iconname]
        if tooltip == nil then
            tooltip = ''
        end
        if dest == nil then
            dest = ''
        end
        if (textexist == 'text' or textexist == 'Text') then 
            return '[[File:'..iconname..'|'..tooltip..'|16px|link='..dest..']] [['..dest..'|'..tooltip..']]'
        end
        return '[[File:'..iconname..'|'..tooltip..'|16px|link='..dest..']]'
    end
end

function p.Melee(frame)
    local AttackType = frame.args[1]
    local ProcType = frame.args[2]
    local imagesize = frame.args.imgsize
    return p._Melee(AttackType, ProcType, imagesize)
end

function p._Melee(AttackType, ProcType, imagesize)
    if(AttackType == nil or AttackType == '') then 
        AttackType = "DEFAULT" 
    else
        AttackType = string.upper(AttackType)
    end
    if(ProcType == nil or ProcType == '') then
        ProcType = "DEFAULT"
    else
        ProcType = string.upper(ProcType)
    end
    if (imagesize == nil or imagesize == '') then
        imagesize = 'x22'                                 
    end
        
    
    if(IconData["Melee"][ProcType] == nil or IconData["Melee"][ProcType][AttackType] == nil) then
        return "<span style=\"color:red;\">Invalid</span>"  
    end
    
    local icon = IconData["Melee"][ProcType][AttackType].icon
    local link = IconData["Melee"][ProcType][AttackType].link
	local title = IconData["Melee"][ProcType][AttackType].title
    local tooltip = IconData["Melee"][ProcType][AttackType].tooltip
    if(icon == nil or icon == '') then
        return "<span style=\"color:red;\">Invalid</span>"  
    end
        
    local result = '[[File:'..icon
    if(tooltip ~= nil and tooltip ~= '') then result = result..'|'..tooltip end
    result = result..'|'..imagesize..'px'
    if link ~= nil then result = result..'|link='..link end
    if title ~= nil then result = result..'|'..title end
    result = result..']]'
    return result
end

function p.Zaw(frame)
    local zawname_input = frame.args[1]
	local textexist = frame.args[2]          
    local imagesize_input = frame.args.imgsize
    return p._Zaw(zawname_input, textexist, imagesize_input)
end

function p._Zaw(zawname, textexist, imagesize)
	zawname = string.gsub(" "..string.lower( zawname ), "%W%l", string.upper):sub(2)
	local link = ''
	if IconData["Zaws"][zawname] == nil then
		return "<span style=\"color:red;\">Invalid</span>[[Category:Icon Module error]]"
	else
		link = IconData["Zaws"][zawname]["link"]
		local title = IconData["Zaws"][zawname]["title"]
		zawname = IconData["Zaws"][zawname]["icon"]
		if (imagesize == nil or imagesize == '') then
			imagesize = 'x26'
		end
		
		local imgText = '[[File:'..zawname..'|'..imagesize..'px'
		if(link ~= nil) then
			imgText = imgText..'|link='..link
		elseif(title ~= nil) then
		    imgText = imgText..'|'..title
		end
		imgText = imgText..']]'
		
		if (textexist == 'text' or textexist == 'Text') then
			if (link ~= nil) then
			    if(title ~= nil) then
				    return imgText..' [['..link..'|'..title..']]'
				else
				    return imgText..' [['..link..']]'
				end
			elseif(title ~= nil) then
			    return imgText..' '..title
			else
				return imgText
			end
		end
		return imgText
	end
end

function p.Buff(frame)
    local iconname = frame.args[1]
    local color = frame.args[2]
    local imagesize = frame.args.imgsize
    local link = IconData["Buff"][iconname]["link"]
    local iconFile = ""
    
    if IconData["Buff"][iconname] == nil then          
        return "<span style=\"color:red;\">Invalid</span>"  
    else
        if color == 'white' then
            iconFile = IconData["Buff"][iconname]["icon"][1]   --white icon
        else
            iconFile = IconData["Buff"][iconname]["icon"][2]   --black icon
        end
        if (imagesize == nil or imagesize == '') then
            imagesize = 'x40'                                 
        end
	    return '[[File:'..iconFile..'|'..imagesize..'px|link='..link..']]'
    end
end

function tooltipCheck(name, typename)
    local procList = {"Impact","Puncture","Slash",{"Cold","Freeze"},{"Electricity","Electric"},{"Heat","Fire"},{"Toxin","Poison"},"Void","Blast","Corrosive","Gas","Magnetic","Radiation","Viral","True"}
    if typename == "Proc" then
        for i, Name in pairs(procList) do
            if type(Name) == 'table' then
                if Name[1] == name or Name[2] == name then
                    name = Name[1]
                    return name
                end
            elseif type(Name) == 'string' then
                if Name == name then
                    return name
                end
            end
        end
    end

    return nil
end

function tooltipSpan(name, typename)
    local iconName = tooltipCheck(name, typename)
    local span = {}
    if iconName and typename == 'Proc' then
        span[1] = '<span class=\"damagetype-tooltip\" data-param=\"'..iconName..'\">'
        span[2] = '</span>'
        return span
    end
    return nil
end

function p.Test2(par1, par2)
    spans = tooltipSpan(par1, par2)
    return spans[1]..spans[2]
end

function p.Test(frame)
    return p._Proc(frame.args[1])
end

return p