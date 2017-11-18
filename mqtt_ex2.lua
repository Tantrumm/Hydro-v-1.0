local M = {}
-- Configuration to connect to the MQTT broker.
BROKER = "m11.cloudmqtt.com"   -- Ip/hostname of MQTT broker
BRPORT = 10698            -- MQTT broker port
BRUSER = "wadootac"       -- If MQTT authenitcation is used then define the user
BRPWD  = "MJgP7OFXwA82"   -- The above user password
CLIENTID = "ESP8266-" ..  node.chipid() -- The MQTT ID. Change to something you like

-- MQTT topics to subscribe
topics = {"topic1","topic2","topic3","topic4"} -- Add/remove topics to the array

-- Control variables.
pub_sem = 0         -- MQTT Publish semaphore. Stops the publishing whne the previous hasn't ended
current_topic  = 1  -- variable for one currently being subscribed to
topicsub_delay = 50 -- microseconds between subscription attempts, worked for me (local network) down to 5...YMMV
id1 = 0
id2 = 0

-- connect to the broker
print "Connecting to MQTT broker. Please wait..."
m = mqtt.Client(CLIENTID, 120, BRUSER, BRPWD)
m:connect( BROKER , BRPORT, 0, function(conn)
     print("Connected to MQTT:" .. BROKER .. ":" .. BRPORT .." as " .. CLIENTID )
     mqtt_sub() --run the subscription function
end)

function mqtt_sub()
     if table.getn(topics) < current_topic then
          -- if we have subscribed to all topics in the array, run the main prog
          run_main_prog()
     else
          --subscribe to the topic
          m:subscribe(topics[current_topic] , 0, function(conn)
               print("Subscribing topic: " .. topics[current_topic - 1] )
          end)
          current_topic = current_topic + 1  -- Goto next topic
          --set the timer to rerun the loop as long there is topics to subscribe
          tmr.alarm(5, topicsub_delay, 0, mqtt_sub )
     end
end


-- Sample publish functions:
function M.publishSensors(t1,t2,dhtTemp,dhtHumi)

    if t1 and t2 and dhtTemp and dhtHumi ~= nil then

         one = m:publish("sensors/ds18b20_1",t1,1,0, function(conn) end)
       
         two = m:publish("sensors/ds18b20_2",t2,1,0, function(conn) end)
    
         three = m:publish("sensors/dht11Temp",dhtTemp,1,0, function(conn) end)

         four = m:publish("sensors/dht11Humi",dhtHumi,1,0, function(conn) end)

         five = m:publish("digit/led",gpio.read(7),1,0, function(conn) end)
         
         six = m:publish("digit/humiReg",gpio.read(6),1,0, function(conn) 

         if not one and not two and not three and not four then
            node.restart()
         end

        end)
       
    end
end
--[[
function M.publish_dht11(data)
   --if pub_sem == 0 then
     --pub_sem = 1
     m:publish("sensors/dht11",data,0,0, function(conn) 
        print("Sending data2: " .. id2)
        --pub_sem = 0
        id2 = id2 + 1
     end)
   --end  
end
]]--
--main program to run after the subscriptions are done
function run_main_prog()
     print("Main program")
     
     --tmr.alarm(2, 5000, 1, publish_data1 )
    --tmr.alarm(3, 6000, 1, publish_data2 )
     -- Callback to receive the subscribed topic messages. 
     m:on("message", function(conn, topic, data)
        print(topic .. ":" )
        if (data ~= nil ) then
        
          print ( data )

          if data == "reset" then
            node.restart()
          end
          
        end
      end )
end

return M
