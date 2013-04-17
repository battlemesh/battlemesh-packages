#!/usr/bin/lua
--[[
    Copyright (C) 2013 OpenWRT.org
    
    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

    The full GNU General Public License is included in this distribution in
    the file called "COPYING".
--]]

util = {}

function util.sprintf(...)
	return string.format(...)
end

function util.printf(...)
	print(sprintf(...))
end

function util.printable(table)
	local i,t
	for i,t in ipairs(table) do
		if #t > 0 then print(t) end
	end
end


function util.replace(s,p1,p2)
	if s == nil then
		return nil
	end
	local sout
	if type(p1) == "table" then
		local i,p
		sout = s
		for i,p in ipairs(p1) do
			sout = string.gsub(sout,p,p2)
		end
	else
		sout = string.gsub(s,p1,p2)
	end

	return sout
end

function util.find(s,p)
	return string.find(s,p)
end


function util.lines(str)
	local t = {}
	local function helper(line) table.insert(t, line) return "" end
	helper((str:gsub("(.-)\r?\n", helper)))
	return t
end

function util.split(str, pat)
	local t = {} 
	if pat == nil then pat=' ' end
	local fpat = "(.-)" .. pat
	local last_end = 1
	local s, e, cap = str:find(fpat, 1)
	while s do
	   if s ~= 1 or cap ~= "" then
	  table.insert(t,cap)
	   end
	   last_end = e+1
	   s, e, cap = str:find(fpat, last_end)
	end
	if last_end <= #str then
	   cap = str:sub(last_end)
	   table.insert(t, cap)
	end
	return t
end

function util.exec(cmd, clean)
	local f = io.popen(cmd, 'r')
	local s = f:read('*a')
	f:close()
	if clean then
	   s = string.gsub(s, '^%s+', '')
	   s = string.gsub(s, '%s+$', '')
	   s = string.gsub(s, '[\n\r]+', ' ')
	end
	return s
end

return util

