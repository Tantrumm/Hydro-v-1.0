--dofile("ds18b20t.lua")
local T = require("ds18b20t")
local TH = require("dht11")
local LCD = require("lcd")

--dofile("mqtt_ex2.lua")
local MQTT = require("mqtt_ex2")

pinLed=7
gpio.mode(pinLed, gpio.OUTPUT)

pinHumi=6
gpio.mode(pinHumi, gpio.OUTPUT)


LCD.cls();
--LCD.lcdprint("Hello world!",0,0);

tmr.alarm(0, 1000, 1, function()
    T.getTemperature(2)
    TH.getData(5)
    LCD.cls()

    LCD.lcdprint("T1:" .. tostring(T[1]) .. " T2:" .. tostring(T[2]),0,0)

    LCD.lcdprint("T:" .. tostring(TH[1]) .. " H:" .. tostring(TH[2]),1,0)

   --[[ if tm ~= nil then
        LCD.lcdprint(string.format("       %04d/%02d/%02d %02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"]+2, tm["min"]),3,0)
    end
   ]]-- 

    if tonumber(TH[2]) < 40 then
        gpio.write(pinHumi, gpio.LOW)
    else gpio.write(pinHumi, gpio.HIGH)
    end
    
end)


cron.schedule("* * * * *", function(e)
    tm = rtctime.epoch2cal(rtctime.get())

    MQTT.publishSensors(T[1],T[2],TH[1],TH[2])

    print(string.format("*** Cron Job 0 ***  %04d/%02d/%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"]))
   
    if gpio.read(pinLed) and 6 < tm["hour"] and  tm["hour"] < 23 then
         gpio.write(pinLed, gpio.LOW)
    else
        gpio.write(pinLed, gpio.HIGH)
    end

end)

cron.schedule("00 06 * * *", function(e)
    tm = rtctime.epoch2cal(rtctime.get())

    gpio.write(pinLed, gpio.LOW)

    print(string.format("***LIGHT ON***  %04d/%02d/%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"]))
end)

cron.schedule("30 23 * * *", function(e)
    tm = rtctime.epoch2cal(rtctime.get())
    gpio.write(pinLed, gpio.HIGH)

    print(string.format("***LIGHT OFF***  %04d/%02d/%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"]))
end)

cron.schedule("00 * * * *", function(e)
    tm = rtctime.epoch2cal(rtctime.get())
    sntp.sync(nil,
          function(sec, usec, server, info)
            rtctime.set(sec + 7200,0) 
            tm = rtctime.epoch2cal(rtctime.get())

            print(string.format("Time Sync  %04d/%02d/%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"]))
        end,
        --[[sntp_sync_time]]--
        nil,--можно впиздошить функцию sync
        1)
end)

cron.schedule("00 00 * * *", function(e)
    tm = rtctime.epoch2cal(rtctime.get())
    node.restart()
end)
