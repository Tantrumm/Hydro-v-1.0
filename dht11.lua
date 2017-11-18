local Q = {}

function Q.getData(pin)
status, temp, humi, temp_dec, humi_dec = dht.read(pin)

    if status == dht.OK then

    Q[1] = temp .. "." ..  temp_dec
    Q[2] = humi .. "." ..  humi_dec

    --[[if Q[1] and Q[2] == nil then
        Q[1] = -1
        Q[2] = -1
    end]]--
     --[[   local str = string.format("T:%d.%01d H:%d.%01d",
              temp,
              temp_dec,
              humi,
              humi_dec
        )
    return str]]--
  
elseif status == dht.ERROR_CHECKSUM then
    print( "DHT Checksum error." )
elseif status == dht.ERROR_TIMEOUT then
    print( "DHT timed out." )
end

end

return Q
