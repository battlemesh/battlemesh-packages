#!/usr/bin/lua

math.randomseed( os.time() )

nodearray = {}
nodes_file = io.popen("wget -q http://[::1]:2006/route -O - |  awk '{print $1}' | grep fd..: | cut  -d ':' -f 3 | sort -u")
while true do
		local line = nodes_file:read('*l')
		if line == nil then break end
		nodearray[#nodearray + 1] = line
end
nodes_file:close()

assert(#nodearray > 1)

i = math.random(1, #nodearray)
chosen1 = nodearray[i]
j = i
while i == j do
		j = math.random(1, #nodearray)
end
chosen2 = nodearray[j]

print(chosen1 .. " -->  " .. chosen2)

addr1 = "fdba:1:" .. chosen1 .. "::1"
addr2 = "fdba:1:" .. chosen2 .. "::1"

os.execute("ssh -i /root/id_rsa -o 'UserKnownHostsFile /dev/null' -o 'StrictHostKeyChecking no' " .. addr1 .. " 'netperf -v 0 -f k -H " .. addr2 .. "'")



