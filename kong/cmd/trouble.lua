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
                    -- connect(host,    port,    password,opts)
    return redis_utils.connect(args[1], args[2], args[3], arg[4], arg[5])
  end
  error("unknown command '" .. args.command .. "'")
end

local lapp = [[
Usage: kong trouble COMMAND [OPTIONS]

Troubleshoot basic aspects of operating Kong.

The available commands are:
  tcp <host> <port>                                      Connect to a tcp socket of your choosing.
  redis --host <host> <port> <password> <ssl> <verify>   Connect to a redis instance of your choosing.
]]

return {
  lapp = lapp,
  execute = execute,
  sub_commands = {
    tcp = true,
    redis = true,
  },
}
