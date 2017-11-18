local cfg={}

cfg.ssid="Atmega8"
cfg.pwd="tantrumm"

wifi.sta.config(cfg)
cfg = nil
collectgarbage()

tmr.alarm(0, 1000, 1, function()
  if wifi.sta.getip() == nil then 
    print("connecting to AP...")  
  else
    print('ip: ',wifi.sta.getip())

    tmr.stop(0) -- alarm stop

    sntp.sync(nil,
      function(sec, usec, server, info)
        rtctime.set(sec + 7200,0) 
        tm = rtctime.epoch2cal(rtctime.get())
        --[[
        if tm["hour"] > 7 and tm["hour"] < 23 then
            gpio.write(7, gpio.LOW)
        else
            gpio.write(7, gpio.HIGH)
        end
        ]]--
        print(string.format("Time Sync  %04d/%02d/%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"]))
    end,
    --[[sntp_sync_time]]--
    nil,--можно впиздошить функцию sync
    1)

    dofile("main.lua")
  end
end)

