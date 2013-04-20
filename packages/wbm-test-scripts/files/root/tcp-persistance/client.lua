local n = require "nixio"
local port = 6969

local s = n.socket("inet6","stream")

s:connect(arg[1],port)
local fails = 0
while true do
	n.nanosleep(1,0)
	local d,c,e = s:write('0')
	if not d or d <= 0 then
		fails = fails +1
		print(fails)

		s:close()
		s = n.socket("inet6","stream")
		s:connect(arg[1],port)
	end
end


