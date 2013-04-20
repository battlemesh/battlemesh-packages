
local port = 6969
local n = require "nixio"

local s = n.socket("inet6","stream")

print(s:setopt("socket", "reuseaddr", 1))
print(s:setopt("socket", "rcvtimeo", 2))

if s:bind("*",port) == nil then
	print("Error: cannot bind at port " .. port)
	os.exit(1)
end


s:listen(1000)

local function handle_client(c)
	local data
	while true do
		data = c:read(1024)
		if not data or #data == 0 then
			break
		end
		print(string.format("Client sent [%s]", data))
	end
	c:close()
end

while true do
	local client, ip, port = s:accept()
	if client then
		handle_client(client)
	end
end
