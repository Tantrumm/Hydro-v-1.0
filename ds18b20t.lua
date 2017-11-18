-- read temperature with DS18B20
local R = {}

function R.getTemperature(pin)

local t = require("ds18b20")
t.setup(pin)
t.setting({"28:FF:FF:FF:FF:FF:FF:FF","28:FF:FF:FF:FF:FF:FF:FF"}, 12)


t.read(
    function(ind,rom,res,temp,tdec,par)

        R[ind] = temp

    end,{});
    
        if(R[1] and R[2] ~= nil) then
            R[1] = math.floor(R[1]*100)/100 -- округление до сотых
            R[2] = math.floor(R[2]*100)/100 -- округление до сотых
        end
        --[[else
            R[1] = -1
            R[2] = -1
        end]]--
   
end

return R

--ds18b20 = nil
--package.loaded["ds18b20"]=nil


