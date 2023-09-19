local log = require "kong.cmd.utils.log"
local redis_utils = require "kong.cmd.utils.redis"
local inspect = require("inspect")

local socket = require "socket"

local function test_tcp(host, port)
  log("testing port " .. port .. " on host " .. host)

  local tcp,err = socket.connect(host, port)
  if tcp ~= nil then
    log("Success!")
    tcp.close(tcp)
  else
    error(err)
  end

  os.exit(0)
end

local function execute(args)
  if args.command == "tcp" then
    return test_tcp(args[1], args[2])
  end

  if args.command == "redis" then
    local host, port, password, opts 
    if #args == 0 then 
      host, port, password, opts = redis_utils.get_params()
    else
      host = args[1]
      port = args[2]
      password = args[3]
      opts = { ssl = args[4], ssl_verify = args[5] }
    end
    return redis_utils.connect(host, port, password, opts)   
  end

  error("unknown command '" .. args.command .. "'")
end

local lapp = [[
Usage: kong trouble COMMAND [OPTIONS]

Troubleshoot basic aspects of operating Kong.

The available commands are:
  tcp <host> <port>                                      Connect to a tcp socket of your choosing.
  redis <host> <port> <password> <ssl> <verify>   Connect to a redis instance of your choosing.
]]

return {
  lapp = lapp,
  execute = execute,
  sub_commands = {
    tcp = true,
    redis = true,
  },
}
