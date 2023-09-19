local redis = require "resty.redis"
local timeout = 2000

local function get_params()
  local host, port, ssl, ssl_verify, password
  local opts = {}

    print("Running in interactive mode. \nIf you wish to specify at the CLI please use the following positional arguments\nUsage: redis.lua <host> <port> <password> <ssl> <verify>\n")
    io.write("Enter the Redis host: ")
    host = io.read()
    io.write("Enter the Redis port: ")
    port = tonumber(io.read())
    io.write("Enter the Redis password (If AUTH is not used, leave this blank): \n")
    os.execute("stty -echo")
    password = io.read()
    os.execute("stty echo")
    io.write("Are you using SSL? (y/n): ")
    ssl = io.read()
    if ssl == "y" then
      opts.ssl = true
      io.write("Are you using SSL verification? (y/n): ")
      ssl_verify = io.read()
      if ssl_verify == "y" then
        opts.ssl_verify = true
      else
        opts.ssl_verify = false
      end
    else
      opts.ssl = false
    end
return host, port, password, opts
end


local function connect(host, port, password, opts)

  local red = redis:new()
  red:set_timeout(timeout)
  
  local ok, err = red:connect(host, port, opts)
  if not ok then
    print("❌ Failed to connect to Redis: " .. err)
    os.exit(1)
  end
  
  if password and password ~= "" then
    local ok, err
    ok, err = red:auth(password)
    if not ok then
      print("❌ Failed to connect to Redis: " .. err)
      os.exit(1)
    else
      print("✅ Successfully connected to Redis")
    end
  end
  
  print("Attempting to write to Redis with\n\tKey: Kong\n\tValue: King of the API Jungle\n")
  local ok, err = red:set("Kong", "King of the API Jungle")
  
  if not ok then
    print("❌ Failed to set Kong: " .. err)
    os.exit(1)
  end
  
  print("Attempting to read from Redis with key: Kong")
  local ok, err = red:get("Kong")
  if not ok then
    print("❌ Failed to get Kong: " .. err)
    os.exit(1)
  end
  print("Retrived value from\n\tkey: Kong\n\tValue: " .. ok)
  
end

return {
    connect = connect,
    get_params = get_params,
  }
