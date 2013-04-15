local bit = require "nixio".bit

module "crc16"

function hash(str)
	local crc;
	
	local function initCrc()
		crc = 0xffff;
	end
	
	local function updCrc(byte)
		crc = bit.bxor(crc, byte);
		for i=1,8 do
			local j = bit.band(crc, 1);
			crc = bit.rshift(crc, 1);
			if j ~= 0 then
				crc = bit.bxor(crc, 0x8408);
			end
		end
	end

	local function getCrc(str)
		initCrc();
		for i = 1, #str  do
			updCrc(str:byte(i));
		end
		return crc;
	end
	return getCrc(str);
end

return { hash = hash }
