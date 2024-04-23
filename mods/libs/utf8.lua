--------------------------------------------------------------------------------
-- UTF-8 Library for Lua 5.1/5.2
--------------------------------------------------------------------------------
-- Lua-5.1-UTF-8 by meepen
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
-- Includes the basic 5.3 utf8 module, plus the function utf8.force().
--  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
local bit    = bit;
local error  = error;
local ipairs = ipairs;
local string = string;
local table  = table;
local unpack = unpack or table.unpack;
--
-- Pattern that can be used with the string library to match a single UTF-8 byte-sequence.
-- This expects the string to contain valid UTF-8 data.
--
local charpattern = "[%z\x01-\x7F\xC2-\xF4][\x80-\xBF]*"
--
-- Transforms indexes of a string to be positive.
-- Negative indices will wrap around like the string library's functions.
--
local function strRelToAbs(str, ...)
	local args = { ... };
	for k, v in ipairs(args) do
		v = v > 0 and v or #str + v + 1;
		if v < 1 or v > #str then
			error("bad index to string (out of range)", 3);
		end
		args[k] = v;
	end
	return unpack(args);
end
--
-- Decodes a single UTF-8 byte-sequence from a string, ensuring it is valid
-- Returns the index of the first and last character of the sequence
--
local function decode(str, startPos)
	if (#str == 0) then return nil; end
	startPos = strRelToAbs(str, startPos or 1);
	local b1 = str:byte(startPos, startPos);
	-- Single-byte sequence
	if b1 < 0x80 then
		return startPos, startPos;
	end
	-- Validate first byte of multi-byte sequence
	if b1 > 0xF4 or b1 < 0xC2 then
		return nil;
	end
	-- Get 'supposed' amount of continuation bytes from primary byte
	local contByteCount =	b1 >= 0xF0 and 3 or
							b1 >= 0xE0 and 2 or
							b1 >= 0xC0 and 1;
	local endPos = startPos + contByteCount;
	-- Validate our continuation bytes
	for _, bX in ipairs {str:byte(startPos + 1, endPos)} do
		if bit.band(bX, 0xC0) ~= 0x80 then
			return nil;
		end
	end
	return startPos, endPos;
end
--
-- Takes zero or more integers and returns a string containing the UTF-8 representation of each
--
local function char( ... )
	local buf = {};
	for k, v in ipairs { ... } do
		if v < 0 or v > 0x10FFFF then
			error("bad argument #" .. k .. " to char (out of range)", 2);
		end
		local b1, b2, b3, b4 = nil, nil, nil, nil;
		if v < 0x80 then -- Single-byte sequence
			table.insert(buf, string.char(v))
		elseif v < 0x800 then -- Two-byte sequence
			b1 = bit.bor(0xC0, bit.band(bit.rshift(v, 6), 0x1F));
			b2 = bit.bor(0x80, bit.band(v, 0x3F));
			table.insert(buf, string.char(b1, b2));
		elseif v < 0x10000 then -- Three-byte sequence
			b1 = bit.bor(0xE0, bit.band(bit.rshift(v, 12), 0x0F));
			b2 = bit.bor(0x80, bit.band(bit.rshift(v, 6), 0x3F));
			b3 = bit.bor(0x80, bit.band(v, 0x3F));
			table.insert(buf, string.char(b1, b2, b3));
		else -- Four-byte sequence
			b1 = bit.bor(0xF0, bit.band(bit.rshift(v, 18), 0x07));
			b2 = bit.bor(0x80, bit.band(bit.rshift(v, 12), 0x3F));
			b3 = bit.bor(0x80, bit.band(bit.rshift(v, 6), 0x3F));
			b4 = bit.bor(0x80, bit.band(v, 0x3F));
			table.insert(buf, string.char(b1, b2, b3, b4));
		end
	end
	return table.concat(buf, "");
end
--
-- Returns an integer-representation of a single UTF-8 codepoint in a string, delimited by startPos and endPos.
-- The delimited sequence must be valid, preferably one returned by utf8.decode().
--
local function cp_single(str, startPos, endPos)
	-- Amount of bytes making up our sequence
	local length = endPos - startPos + 1;
	if length == 1 then -- Single-byte codepoint
		return str:byte(startPos);
	else -- Multi-byte codepoint
		local b1 = str:byte(startPos);
		local cp = 0;
		for i = startPos + 1, endPos do
			local bX = str:byte(i);
			cp = bit.bor(bit.lshift(cp, 6), bit.band(bX, 0x3F));
			b1 = bit.lshift(b1, 1);
		end
		cp = bit.bor(cp, bit.lshift(bit.band(b1, 0x7F), (length - 1) * 5));
		return cp;
	end
end
--
-- Iterates over a UTF-8 string similarly to pairs
-- k = index of sequence, v = string value of sequence
--
local function chars(str)
	local i = 1;
	return function()
		-- Have we hit the end of the iteration set?
		if i > #str then
			return nil;
		end
		local startPos, endPos = decode(str, i);
		if not startPos then
			error("invalid UTF-8 code", 2);
		end
		i = endPos + 1;
		return startPos, string.sub(str, startPos, endPos);
	end
end
--
-- Iterates over a UTF-8 string similarly to pairs
-- k = index of sequence, v = codepoint of sequence
--
local function codes(str)
	local i = 1;
	return function()
		-- Have we hit the end of the iteration set?
		if i > #str then
			return nil;
		end
		local startPos, endPos = decode(str, i);
		if not startPos then
			error("invalid UTF-8 code", 2);
		end
		i = endPos + 1;
		return startPos, cp_single(str, startPos, endPos);
	end
end
--
-- Returns an integer-representation of the UTF-8 sequence(s) in a string
-- startPos defaults to 1, endPos defaults to startPos
--
local function codepoint(str, startPos, endPos)
	startPos, endPos = strRelToAbs(str, startPos or 1, endPos or startPos or 1);
	local ret = {};
	repeat
		local seqStartPos, seqEndPos = decode(str, startPos);
		if not seqStartPos then
			error("invalid UTF-8 code", 2);
		end
		table.insert(ret, cp_single(str, seqStartPos, seqEndPos));
		-- Increment current string index
		startPos = seqEndPos + 1;
	until seqEndPos >= endPos;
	return unpack(ret);
end
--
-- Returns the length of a UTF-8 string. false, index is returned if an invalid sequence is hit
-- startPos defaults to 1, endPos defaults to -1
--
local function len(str, startPos, endPos)
	startPos, endPos = strRelToAbs(str, startPos or 1, endPos or -1);
	local length = 0;
	repeat
		local seqStartPos, seqEndPos = decode(str, startPos);
		-- Hit an invalid sequence?
		if not seqStartPos then
			return false, startPos;
		end
		-- Increment current string pointer
		startPos = seqEndPos + 1;
		-- Increment length
		length = length + 1;
	until seqEndPos >= endPos;
	return length;
end
--
-- Returns the byte-index of the n'th UTF-8-character after the given byte-index (nil if none)
-- startPos defaults to 1 when n is positive and -1 when n is negative
-- If n is zero, this function instead returns the byte-index of the UTF-8-character startPos lies within.
--
local function offset(str, n, startPos)
	startPos = strRelToAbs(str, startPos or ( n >= 0 and 1 ) or #str);
	-- Find the beginning of the sequence over startPos
	if n == 0 then
		for i = startPos, 1, -1 do
			local seqStartPos, seqEndPos = decode(str, i);
			if seqStartPos then
				return seqStartPos;
			end
		end
		return nil
	end
	if not decode(str, startPos) then
		error("initial position is not beginning of a valid sequence", 2);
	end
	local itStart, itEnd, itStep = nil, nil, nil;
	if n > 0 then -- Find the beginning of the n'th sequence forwards
		itStart = startPos;
		itEnd = #str;
		itStep = 1;
	else -- Find the beginning of the n'th sequence backwards
		n = -n;
		itStart = startPos;
		itEnd = 1;
		itStep = -1;
	end
	for i = itStart, itEnd, itStep do
		local seqStartPos, seqEndPos = decode(str, i);
		if seqStartPos then
			n = n - 1;
			if n == 0 then
				return seqStartPos;
			end
		end
	end
	return nil;
end
--
-- Forces a string to contain only valid UTF-8 data.
-- Invalid sequences are replaced with U+FFFD.
--
local function force(str)
	local buf = {};
	local curPos, endPos = 1, #str;
	repeat
		local seqStartPos, seqEndPos = decode(str, curPos);
		if not seqStartPos then
			table.insert(buf, char(0xFFFD));
			curPos = curPos + 1;
		else
			table.insert(buf, str:sub(seqStartPos, seqEndPos));
			curPos = seqEndPos + 1;
		end
	until curPos > endPos;
	return table.concat(buf, "");
end
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
-- UTF-8 Casing Conversion Tables by starwing
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
-- These conversion tables cover up 95% of Unicode conversion needs. There are
-- some special conditions that just can't be evaluated through tables, and
-- unfortunately those aren't supported at the moment.
--
-- Read [https://github.com/starwing/luautf8/blob/master/parseucd.lua] for
-- information on how to generate these tables.
--  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
local function conv_table(data)
	for idx, entry in ipairs(data) do
		entry.first = entry[1];
		entry.last = entry[2];
		entry.step = entry[3];
		entry.offset = entry[4];
	end
	return data;
end

local tolower_table = conv_table({
    { 0x41, 0x5A, 1, 32 },
    { 0xC0, 0xD6, 1, 32 },
    { 0xD8, 0xDE, 1, 32 },
    { 0x100, 0x12E, 2, 1 },
    { 0x130, 0x130, 1, -199 },
    { 0x132, 0x136, 2, 1 },
    { 0x139, 0x147, 2, 1 },
    { 0x14A, 0x176, 2, 1 },
    { 0x178, 0x178, 1, -121 },
    { 0x179, 0x17D, 2, 1 },
    { 0x181, 0x181, 1, 210 },
    { 0x182, 0x184, 2, 1 },
    { 0x186, 0x186, 1, 206 },
    { 0x187, 0x187, 1, 1 },
    { 0x189, 0x18A, 1, 205 },
    { 0x18B, 0x18B, 1, 1 },
    { 0x18E, 0x18E, 1, 79 },
    { 0x18F, 0x18F, 1, 202 },
    { 0x190, 0x190, 1, 203 },
    { 0x191, 0x191, 1, 1 },
    { 0x193, 0x193, 1, 205 },
    { 0x194, 0x194, 1, 207 },
    { 0x196, 0x196, 1, 211 },
    { 0x197, 0x197, 1, 209 },
    { 0x198, 0x198, 1, 1 },
    { 0x19C, 0x19C, 1, 211 },
    { 0x19D, 0x19D, 1, 213 },
    { 0x19F, 0x19F, 1, 214 },
    { 0x1A0, 0x1A4, 2, 1 },
    { 0x1A6, 0x1A6, 1, 218 },
    { 0x1A7, 0x1A7, 1, 1 },
    { 0x1A9, 0x1A9, 1, 218 },
    { 0x1AC, 0x1AC, 1, 1 },
    { 0x1AE, 0x1AE, 1, 218 },
    { 0x1AF, 0x1AF, 1, 1 },
    { 0x1B1, 0x1B2, 1, 217 },
    { 0x1B3, 0x1B5, 2, 1 },
    { 0x1B7, 0x1B7, 1, 219 },
    { 0x1B8, 0x1BC, 4, 1 },
    { 0x1C4, 0x1C4, 1, 2 },
    { 0x1C5, 0x1C5, 1, 1 },
    { 0x1C7, 0x1C7, 1, 2 },
    { 0x1C8, 0x1C8, 1, 1 },
    { 0x1CA, 0x1CA, 1, 2 },
    { 0x1CB, 0x1DB, 2, 1 },
    { 0x1DE, 0x1EE, 2, 1 },
    { 0x1F1, 0x1F1, 1, 2 },
    { 0x1F2, 0x1F4, 2, 1 },
    { 0x1F6, 0x1F6, 1, -97 },
    { 0x1F7, 0x1F7, 1, -56 },
    { 0x1F8, 0x21E, 2, 1 },
    { 0x220, 0x220, 1, -130 },
    { 0x222, 0x232, 2, 1 },
    { 0x23A, 0x23A, 1, 10795 },
    { 0x23B, 0x23B, 1, 1 },
    { 0x23D, 0x23D, 1, -163 },
    { 0x23E, 0x23E, 1, 10792 },
    { 0x241, 0x241, 1, 1 },
    { 0x243, 0x243, 1, -195 },
    { 0x244, 0x244, 1, 69 },
    { 0x245, 0x245, 1, 71 },
    { 0x246, 0x24E, 2, 1 },
    { 0x370, 0x372, 2, 1 },
    { 0x376, 0x376, 1, 1 },
    { 0x37F, 0x37F, 1, 116 },
    { 0x386, 0x386, 1, 38 },
    { 0x388, 0x38A, 1, 37 },
    { 0x38C, 0x38C, 1, 64 },
    { 0x38E, 0x38F, 1, 63 },
    { 0x391, 0x3A1, 1, 32 },
    { 0x3A3, 0x3AB, 1, 32 },
    { 0x3CF, 0x3CF, 1, 8 },
    { 0x3D8, 0x3EE, 2, 1 },
    { 0x3F4, 0x3F4, 1, -60 },
    { 0x3F7, 0x3F7, 1, 1 },
    { 0x3F9, 0x3F9, 1, -7 },
    { 0x3FA, 0x3FA, 1, 1 },
    { 0x3FD, 0x3FF, 1, -130 },
    { 0x400, 0x40F, 1, 80 },
    { 0x410, 0x42F, 1, 32 },
    { 0x460, 0x480, 2, 1 },
    { 0x48A, 0x4BE, 2, 1 },
    { 0x4C0, 0x4C0, 1, 15 },
    { 0x4C1, 0x4CD, 2, 1 },
    { 0x4D0, 0x52E, 2, 1 },
    { 0x531, 0x556, 1, 48 },
    { 0x10A0, 0x10C5, 1, 7264 },
    { 0x10C7, 0x10CD, 6, 7264 },
    { 0x13A0, 0x13EF, 1, 38864 },
    { 0x13F0, 0x13F5, 1, 8 },
    { 0x1C90, 0x1CBA, 1, -3008 },
    { 0x1CBD, 0x1CBF, 1, -3008 },
    { 0x1E00, 0x1E94, 2, 1 },
    { 0x1E9E, 0x1E9E, 1, -7615 },
    { 0x1EA0, 0x1EFE, 2, 1 },
    { 0x1F08, 0x1F0F, 1, -8 },
    { 0x1F18, 0x1F1D, 1, -8 },
    { 0x1F28, 0x1F2F, 1, -8 },
    { 0x1F38, 0x1F3F, 1, -8 },
    { 0x1F48, 0x1F4D, 1, -8 },
    { 0x1F59, 0x1F5F, 2, -8 },
    { 0x1F68, 0x1F6F, 1, -8 },
    { 0x1F88, 0x1F8F, 1, -8 },
    { 0x1F98, 0x1F9F, 1, -8 },
    { 0x1FA8, 0x1FAF, 1, -8 },
    { 0x1FB8, 0x1FB9, 1, -8 },
    { 0x1FBA, 0x1FBB, 1, -74 },
    { 0x1FBC, 0x1FBC, 1, -9 },
    { 0x1FC8, 0x1FCB, 1, -86 },
    { 0x1FCC, 0x1FCC, 1, -9 },
    { 0x1FD8, 0x1FD9, 1, -8 },
    { 0x1FDA, 0x1FDB, 1, -100 },
    { 0x1FE8, 0x1FE9, 1, -8 },
    { 0x1FEA, 0x1FEB, 1, -112 },
    { 0x1FEC, 0x1FEC, 1, -7 },
    { 0x1FF8, 0x1FF9, 1, -128 },
    { 0x1FFA, 0x1FFB, 1, -126 },
    { 0x1FFC, 0x1FFC, 1, -9 },
    { 0x2126, 0x2126, 1, -7517 },
    { 0x212A, 0x212A, 1, -8383 },
    { 0x212B, 0x212B, 1, -8262 },
    { 0x2132, 0x2132, 1, 28 },
    { 0x2160, 0x216F, 1, 16 },
    { 0x2183, 0x2183, 1, 1 },
    { 0x24B6, 0x24CF, 1, 26 },
    { 0x2C00, 0x2C2F, 1, 48 },
    { 0x2C60, 0x2C60, 1, 1 },
    { 0x2C62, 0x2C62, 1, -10743 },
    { 0x2C63, 0x2C63, 1, -3814 },
    { 0x2C64, 0x2C64, 1, -10727 },
    { 0x2C67, 0x2C6B, 2, 1 },
    { 0x2C6D, 0x2C6D, 1, -10780 },
    { 0x2C6E, 0x2C6E, 1, -10749 },
    { 0x2C6F, 0x2C6F, 1, -10783 },
    { 0x2C70, 0x2C70, 1, -10782 },
    { 0x2C72, 0x2C75, 3, 1 },
    { 0x2C7E, 0x2C7F, 1, -10815 },
    { 0x2C80, 0x2CE2, 2, 1 },
    { 0x2CEB, 0x2CED, 2, 1 },
    { 0x2CF2, 0xA640, 31054, 1 },
    { 0xA642, 0xA66C, 2, 1 },
    { 0xA680, 0xA69A, 2, 1 },
    { 0xA722, 0xA72E, 2, 1 },
    { 0xA732, 0xA76E, 2, 1 },
    { 0xA779, 0xA77B, 2, 1 },
    { 0xA77D, 0xA77D, 1, -35332 },
    { 0xA77E, 0xA786, 2, 1 },
    { 0xA78B, 0xA78B, 1, 1 },
    { 0xA78D, 0xA78D, 1, -42280 },
    { 0xA790, 0xA792, 2, 1 },
    { 0xA796, 0xA7A8, 2, 1 },
    { 0xA7AA, 0xA7AA, 1, -42308 },
    { 0xA7AB, 0xA7AB, 1, -42319 },
    { 0xA7AC, 0xA7AC, 1, -42315 },
    { 0xA7AD, 0xA7AD, 1, -42305 },
    { 0xA7AE, 0xA7AE, 1, -42308 },
    { 0xA7B0, 0xA7B0, 1, -42258 },
    { 0xA7B1, 0xA7B1, 1, -42282 },
    { 0xA7B2, 0xA7B2, 1, -42261 },
    { 0xA7B3, 0xA7B3, 1, 928 },
    { 0xA7B4, 0xA7C2, 2, 1 },
    { 0xA7C4, 0xA7C4, 1, -48 },
    { 0xA7C5, 0xA7C5, 1, -42307 },
    { 0xA7C6, 0xA7C6, 1, -35384 },
    { 0xA7C7, 0xA7C9, 2, 1 },
    { 0xA7D0, 0xA7D6, 6, 1 },
    { 0xA7D8, 0xA7F5, 29, 1 },
    { 0xFF21, 0xFF3A, 1, 32 },
    { 0x10400, 0x10427, 1, 40 },
    { 0x104B0, 0x104D3, 1, 40 },
    { 0x10570, 0x1057A, 1, 39 },
    { 0x1057C, 0x1058A, 1, 39 },
    { 0x1058C, 0x10592, 1, 39 },
    { 0x10594, 0x10595, 1, 39 },
    { 0x10C80, 0x10CB2, 1, 64 },
    { 0x118A0, 0x118BF, 1, 32 },
    { 0x16E40, 0x16E5F, 1, 32 },
    { 0x1E900, 0x1E921, 1, 34 },
});

local toupper_table = conv_table({
    { 0x61, 0x7A, 1, -32 },
    { 0xB5, 0xB5, 1, 743 },
    { 0xE0, 0xF6, 1, -32 },
    { 0xF8, 0xFE, 1, -32 },
    { 0xFF, 0xFF, 1, 121 },
    { 0x101, 0x12F, 2, -1 },
    { 0x131, 0x131, 1, -232 },
    { 0x133, 0x137, 2, -1 },
    { 0x13A, 0x148, 2, -1 },
    { 0x14B, 0x177, 2, -1 },
    { 0x17A, 0x17E, 2, -1 },
    { 0x17F, 0x17F, 1, -300 },
    { 0x180, 0x180, 1, 195 },
    { 0x183, 0x185, 2, -1 },
    { 0x188, 0x18C, 4, -1 },
    { 0x192, 0x192, 1, -1 },
    { 0x195, 0x195, 1, 97 },
    { 0x199, 0x199, 1, -1 },
    { 0x19A, 0x19A, 1, 163 },
    { 0x19E, 0x19E, 1, 130 },
    { 0x1A1, 0x1A5, 2, -1 },
    { 0x1A8, 0x1AD, 5, -1 },
    { 0x1B0, 0x1B4, 4, -1 },
    { 0x1B6, 0x1B9, 3, -1 },
    { 0x1BD, 0x1BD, 1, -1 },
    { 0x1BF, 0x1BF, 1, 56 },
    { 0x1C5, 0x1C5, 1, -1 },
    { 0x1C6, 0x1C6, 1, -2 },
    { 0x1C8, 0x1C8, 1, -1 },
    { 0x1C9, 0x1C9, 1, -2 },
    { 0x1CB, 0x1CB, 1, -1 },
    { 0x1CC, 0x1CC, 1, -2 },
    { 0x1CE, 0x1DC, 2, -1 },
    { 0x1DD, 0x1DD, 1, -79 },
    { 0x1DF, 0x1EF, 2, -1 },
    { 0x1F2, 0x1F2, 1, -1 },
    { 0x1F3, 0x1F3, 1, -2 },
    { 0x1F5, 0x1F9, 4, -1 },
    { 0x1FB, 0x21F, 2, -1 },
    { 0x223, 0x233, 2, -1 },
    { 0x23C, 0x23C, 1, -1 },
    { 0x23F, 0x240, 1, 10815 },
    { 0x242, 0x247, 5, -1 },
    { 0x249, 0x24F, 2, -1 },
    { 0x250, 0x250, 1, 10783 },
    { 0x251, 0x251, 1, 10780 },
    { 0x252, 0x252, 1, 10782 },
    { 0x253, 0x253, 1, -210 },
    { 0x254, 0x254, 1, -206 },
    { 0x256, 0x257, 1, -205 },
    { 0x259, 0x259, 1, -202 },
    { 0x25B, 0x25B, 1, -203 },
    { 0x25C, 0x25C, 1, 42319 },
    { 0x260, 0x260, 1, -205 },
    { 0x261, 0x261, 1, 42315 },
    { 0x263, 0x263, 1, -207 },
    { 0x265, 0x265, 1, 42280 },
    { 0x266, 0x266, 1, 42308 },
    { 0x268, 0x268, 1, -209 },
    { 0x269, 0x269, 1, -211 },
    { 0x26A, 0x26A, 1, 42308 },
    { 0x26B, 0x26B, 1, 10743 },
    { 0x26C, 0x26C, 1, 42305 },
    { 0x26F, 0x26F, 1, -211 },
    { 0x271, 0x271, 1, 10749 },
    { 0x272, 0x272, 1, -213 },
    { 0x275, 0x275, 1, -214 },
    { 0x27D, 0x27D, 1, 10727 },
    { 0x280, 0x280, 1, -218 },
    { 0x282, 0x282, 1, 42307 },
    { 0x283, 0x283, 1, -218 },
    { 0x287, 0x287, 1, 42282 },
    { 0x288, 0x288, 1, -218 },
    { 0x289, 0x289, 1, -69 },
    { 0x28A, 0x28B, 1, -217 },
    { 0x28C, 0x28C, 1, -71 },
    { 0x292, 0x292, 1, -219 },
    { 0x29D, 0x29D, 1, 42261 },
    { 0x29E, 0x29E, 1, 42258 },
    { 0x345, 0x345, 1, 84 },
    { 0x371, 0x373, 2, -1 },
    { 0x377, 0x377, 1, -1 },
    { 0x37B, 0x37D, 1, 130 },
    { 0x3AC, 0x3AC, 1, -38 },
    { 0x3AD, 0x3AF, 1, -37 },
    { 0x3B1, 0x3C1, 1, -32 },
    { 0x3C2, 0x3C2, 1, -31 },
    { 0x3C3, 0x3CB, 1, -32 },
    { 0x3CC, 0x3CC, 1, -64 },
    { 0x3CD, 0x3CE, 1, -63 },
    { 0x3D0, 0x3D0, 1, -62 },
    { 0x3D1, 0x3D1, 1, -57 },
    { 0x3D5, 0x3D5, 1, -47 },
    { 0x3D6, 0x3D6, 1, -54 },
    { 0x3D7, 0x3D7, 1, -8 },
    { 0x3D9, 0x3EF, 2, -1 },
    { 0x3F0, 0x3F0, 1, -86 },
    { 0x3F1, 0x3F1, 1, -80 },
    { 0x3F2, 0x3F2, 1, 7 },
    { 0x3F3, 0x3F3, 1, -116 },
    { 0x3F5, 0x3F5, 1, -96 },
    { 0x3F8, 0x3FB, 3, -1 },
    { 0x430, 0x44F, 1, -32 },
    { 0x450, 0x45F, 1, -80 },
    { 0x461, 0x481, 2, -1 },
    { 0x48B, 0x4BF, 2, -1 },
    { 0x4C2, 0x4CE, 2, -1 },
    { 0x4CF, 0x4CF, 1, -15 },
    { 0x4D1, 0x52F, 2, -1 },
    { 0x561, 0x586, 1, -48 },
    { 0x10D0, 0x10FA, 1, 3008 },
    { 0x10FD, 0x10FF, 1, 3008 },
    { 0x13F8, 0x13FD, 1, -8 },
    { 0x1C80, 0x1C80, 1, -6254 },
    { 0x1C81, 0x1C81, 1, -6253 },
    { 0x1C82, 0x1C82, 1, -6244 },
    { 0x1C83, 0x1C84, 1, -6242 },
    { 0x1C85, 0x1C85, 1, -6243 },
    { 0x1C86, 0x1C86, 1, -6236 },
    { 0x1C87, 0x1C87, 1, -6181 },
    { 0x1C88, 0x1C88, 1, 35266 },
    { 0x1D79, 0x1D79, 1, 35332 },
    { 0x1D7D, 0x1D7D, 1, 3814 },
    { 0x1D8E, 0x1D8E, 1, 35384 },
    { 0x1E01, 0x1E95, 2, -1 },
    { 0x1E9B, 0x1E9B, 1, -59 },
    { 0x1EA1, 0x1EFF, 2, -1 },
    { 0x1F00, 0x1F07, 1, 8 },
    { 0x1F10, 0x1F15, 1, 8 },
    { 0x1F20, 0x1F27, 1, 8 },
    { 0x1F30, 0x1F37, 1, 8 },
    { 0x1F40, 0x1F45, 1, 8 },
    { 0x1F51, 0x1F57, 2, 8 },
    { 0x1F60, 0x1F67, 1, 8 },
    { 0x1F70, 0x1F71, 1, 74 },
    { 0x1F72, 0x1F75, 1, 86 },
    { 0x1F76, 0x1F77, 1, 100 },
    { 0x1F78, 0x1F79, 1, 128 },
    { 0x1F7A, 0x1F7B, 1, 112 },
    { 0x1F7C, 0x1F7D, 1, 126 },
    { 0x1F80, 0x1F87, 1, 8 },
    { 0x1F90, 0x1F97, 1, 8 },
    { 0x1FA0, 0x1FA7, 1, 8 },
    { 0x1FB0, 0x1FB1, 1, 8 },
    { 0x1FB3, 0x1FB3, 1, 9 },
    { 0x1FBE, 0x1FBE, 1, -7205 },
    { 0x1FC3, 0x1FC3, 1, 9 },
    { 0x1FD0, 0x1FD1, 1, 8 },
    { 0x1FE0, 0x1FE1, 1, 8 },
    { 0x1FE5, 0x1FE5, 1, 7 },
    { 0x1FF3, 0x1FF3, 1, 9 },
    { 0x214E, 0x214E, 1, -28 },
    { 0x2170, 0x217F, 1, -16 },
    { 0x2184, 0x2184, 1, -1 },
    { 0x24D0, 0x24E9, 1, -26 },
    { 0x2C30, 0x2C5F, 1, -48 },
    { 0x2C61, 0x2C61, 1, -1 },
    { 0x2C65, 0x2C65, 1, -10795 },
    { 0x2C66, 0x2C66, 1, -10792 },
    { 0x2C68, 0x2C6C, 2, -1 },
    { 0x2C73, 0x2C76, 3, -1 },
    { 0x2C81, 0x2CE3, 2, -1 },
    { 0x2CEC, 0x2CEE, 2, -1 },
    { 0x2CF3, 0x2CF3, 1, -1 },
    { 0x2D00, 0x2D25, 1, -7264 },
    { 0x2D27, 0x2D2D, 6, -7264 },
    { 0xA641, 0xA66D, 2, -1 },
    { 0xA681, 0xA69B, 2, -1 },
    { 0xA723, 0xA72F, 2, -1 },
    { 0xA733, 0xA76F, 2, -1 },
    { 0xA77A, 0xA77C, 2, -1 },
    { 0xA77F, 0xA787, 2, -1 },
    { 0xA78C, 0xA791, 5, -1 },
    { 0xA793, 0xA793, 1, -1 },
    { 0xA794, 0xA794, 1, 48 },
    { 0xA797, 0xA7A9, 2, -1 },
    { 0xA7B5, 0xA7C3, 2, -1 },
    { 0xA7C8, 0xA7CA, 2, -1 },
    { 0xA7D1, 0xA7D7, 6, -1 },
    { 0xA7D9, 0xA7F6, 29, -1 },
    { 0xAB53, 0xAB53, 1, -928 },
    { 0xAB70, 0xABBF, 1, -38864 },
    { 0xFF41, 0xFF5A, 1, -32 },
    { 0x10428, 0x1044F, 1, -40 },
    { 0x104D8, 0x104FB, 1, -40 },
    { 0x10597, 0x105A1, 1, -39 },
    { 0x105A3, 0x105B1, 1, -39 },
    { 0x105B3, 0x105B9, 1, -39 },
    { 0x105BB, 0x105BC, 1, -39 },
    { 0x10CC0, 0x10CF2, 1, -64 },
    { 0x118C0, 0x118DF, 1, -32 },
    { 0x16E60, 0x16E7F, 1, -32 },
    { 0x1E922, 0x1E943, 1, -34 },
});

local totitle_table = conv_table({
    { 0x61, 0x7A, 1, -32 },
    { 0xB5, 0xB5, 1, 743 },
    { 0xE0, 0xF6, 1, -32 },
    { 0xF8, 0xFE, 1, -32 },
    { 0xFF, 0xFF, 1, 121 },
    { 0x101, 0x12F, 2, -1 },
    { 0x131, 0x131, 1, -232 },
    { 0x133, 0x137, 2, -1 },
    { 0x13A, 0x148, 2, -1 },
    { 0x14B, 0x177, 2, -1 },
    { 0x17A, 0x17E, 2, -1 },
    { 0x17F, 0x17F, 1, -300 },
    { 0x180, 0x180, 1, 195 },
    { 0x183, 0x185, 2, -1 },
    { 0x188, 0x18C, 4, -1 },
    { 0x192, 0x192, 1, -1 },
    { 0x195, 0x195, 1, 97 },
    { 0x199, 0x199, 1, -1 },
    { 0x19A, 0x19A, 1, 163 },
    { 0x19E, 0x19E, 1, 130 },
    { 0x1A1, 0x1A5, 2, -1 },
    { 0x1A8, 0x1AD, 5, -1 },
    { 0x1B0, 0x1B4, 4, -1 },
    { 0x1B6, 0x1B9, 3, -1 },
    { 0x1BD, 0x1BD, 1, -1 },
    { 0x1BF, 0x1BF, 1, 56 },
    { 0x1C4, 0x1C4, 1, 1 },
    { 0x1C5, 0x1C5, 1, 0 },
    { 0x1C6, 0x1C6, 1, -1 },
    { 0x1C7, 0x1C7, 1, 1 },
    { 0x1C8, 0x1C8, 1, 0 },
    { 0x1C9, 0x1C9, 1, -1 },
    { 0x1CA, 0x1CA, 1, 1 },
    { 0x1CB, 0x1CB, 1, 0 },
    { 0x1CC, 0x1DC, 2, -1 },
    { 0x1DD, 0x1DD, 1, -79 },
    { 0x1DF, 0x1EF, 2, -1 },
    { 0x1F1, 0x1F1, 1, 1 },
    { 0x1F2, 0x1F2, 1, 0 },
    { 0x1F3, 0x1F5, 2, -1 },
    { 0x1F9, 0x21F, 2, -1 },
    { 0x223, 0x233, 2, -1 },
    { 0x23C, 0x23C, 1, -1 },
    { 0x23F, 0x240, 1, 10815 },
    { 0x242, 0x247, 5, -1 },
    { 0x249, 0x24F, 2, -1 },
    { 0x250, 0x250, 1, 10783 },
    { 0x251, 0x251, 1, 10780 },
    { 0x252, 0x252, 1, 10782 },
    { 0x253, 0x253, 1, -210 },
    { 0x254, 0x254, 1, -206 },
    { 0x256, 0x257, 1, -205 },
    { 0x259, 0x259, 1, -202 },
    { 0x25B, 0x25B, 1, -203 },
    { 0x25C, 0x25C, 1, 42319 },
    { 0x260, 0x260, 1, -205 },
    { 0x261, 0x261, 1, 42315 },
    { 0x263, 0x263, 1, -207 },
    { 0x265, 0x265, 1, 42280 },
    { 0x266, 0x266, 1, 42308 },
    { 0x268, 0x268, 1, -209 },
    { 0x269, 0x269, 1, -211 },
    { 0x26A, 0x26A, 1, 42308 },
    { 0x26B, 0x26B, 1, 10743 },
    { 0x26C, 0x26C, 1, 42305 },
    { 0x26F, 0x26F, 1, -211 },
    { 0x271, 0x271, 1, 10749 },
    { 0x272, 0x272, 1, -213 },
    { 0x275, 0x275, 1, -214 },
    { 0x27D, 0x27D, 1, 10727 },
    { 0x280, 0x280, 1, -218 },
    { 0x282, 0x282, 1, 42307 },
    { 0x283, 0x283, 1, -218 },
    { 0x287, 0x287, 1, 42282 },
    { 0x288, 0x288, 1, -218 },
    { 0x289, 0x289, 1, -69 },
    { 0x28A, 0x28B, 1, -217 },
    { 0x28C, 0x28C, 1, -71 },
    { 0x292, 0x292, 1, -219 },
    { 0x29D, 0x29D, 1, 42261 },
    { 0x29E, 0x29E, 1, 42258 },
    { 0x345, 0x345, 1, 84 },
    { 0x371, 0x373, 2, -1 },
    { 0x377, 0x377, 1, -1 },
    { 0x37B, 0x37D, 1, 130 },
    { 0x3AC, 0x3AC, 1, -38 },
    { 0x3AD, 0x3AF, 1, -37 },
    { 0x3B1, 0x3C1, 1, -32 },
    { 0x3C2, 0x3C2, 1, -31 },
    { 0x3C3, 0x3CB, 1, -32 },
    { 0x3CC, 0x3CC, 1, -64 },
    { 0x3CD, 0x3CE, 1, -63 },
    { 0x3D0, 0x3D0, 1, -62 },
    { 0x3D1, 0x3D1, 1, -57 },
    { 0x3D5, 0x3D5, 1, -47 },
    { 0x3D6, 0x3D6, 1, -54 },
    { 0x3D7, 0x3D7, 1, -8 },
    { 0x3D9, 0x3EF, 2, -1 },
    { 0x3F0, 0x3F0, 1, -86 },
    { 0x3F1, 0x3F1, 1, -80 },
    { 0x3F2, 0x3F2, 1, 7 },
    { 0x3F3, 0x3F3, 1, -116 },
    { 0x3F5, 0x3F5, 1, -96 },
    { 0x3F8, 0x3FB, 3, -1 },
    { 0x430, 0x44F, 1, -32 },
    { 0x450, 0x45F, 1, -80 },
    { 0x461, 0x481, 2, -1 },
    { 0x48B, 0x4BF, 2, -1 },
    { 0x4C2, 0x4CE, 2, -1 },
    { 0x4CF, 0x4CF, 1, -15 },
    { 0x4D1, 0x52F, 2, -1 },
    { 0x561, 0x586, 1, -48 },
    { 0x10D0, 0x10FA, 1, 0 },
    { 0x10FD, 0x10FF, 1, 0 },
    { 0x13F8, 0x13FD, 1, -8 },
    { 0x1C80, 0x1C80, 1, -6254 },
    { 0x1C81, 0x1C81, 1, -6253 },
    { 0x1C82, 0x1C82, 1, -6244 },
    { 0x1C83, 0x1C84, 1, -6242 },
    { 0x1C85, 0x1C85, 1, -6243 },
    { 0x1C86, 0x1C86, 1, -6236 },
    { 0x1C87, 0x1C87, 1, -6181 },
    { 0x1C88, 0x1C88, 1, 35266 },
    { 0x1D79, 0x1D79, 1, 35332 },
    { 0x1D7D, 0x1D7D, 1, 3814 },
    { 0x1D8E, 0x1D8E, 1, 35384 },
    { 0x1E01, 0x1E95, 2, -1 },
    { 0x1E9B, 0x1E9B, 1, -59 },
    { 0x1EA1, 0x1EFF, 2, -1 },
    { 0x1F00, 0x1F07, 1, 8 },
    { 0x1F10, 0x1F15, 1, 8 },
    { 0x1F20, 0x1F27, 1, 8 },
    { 0x1F30, 0x1F37, 1, 8 },
    { 0x1F40, 0x1F45, 1, 8 },
    { 0x1F51, 0x1F57, 2, 8 },
    { 0x1F60, 0x1F67, 1, 8 },
    { 0x1F70, 0x1F71, 1, 74 },
    { 0x1F72, 0x1F75, 1, 86 },
    { 0x1F76, 0x1F77, 1, 100 },
    { 0x1F78, 0x1F79, 1, 128 },
    { 0x1F7A, 0x1F7B, 1, 112 },
    { 0x1F7C, 0x1F7D, 1, 126 },
    { 0x1F80, 0x1F87, 1, 8 },
    { 0x1F90, 0x1F97, 1, 8 },
    { 0x1FA0, 0x1FA7, 1, 8 },
    { 0x1FB0, 0x1FB1, 1, 8 },
    { 0x1FB3, 0x1FB3, 1, 9 },
    { 0x1FBE, 0x1FBE, 1, -7205 },
    { 0x1FC3, 0x1FC3, 1, 9 },
    { 0x1FD0, 0x1FD1, 1, 8 },
    { 0x1FE0, 0x1FE1, 1, 8 },
    { 0x1FE5, 0x1FE5, 1, 7 },
    { 0x1FF3, 0x1FF3, 1, 9 },
    { 0x214E, 0x214E, 1, -28 },
    { 0x2170, 0x217F, 1, -16 },
    { 0x2184, 0x2184, 1, -1 },
    { 0x24D0, 0x24E9, 1, -26 },
    { 0x2C30, 0x2C5F, 1, -48 },
    { 0x2C61, 0x2C61, 1, -1 },
    { 0x2C65, 0x2C65, 1, -10795 },
    { 0x2C66, 0x2C66, 1, -10792 },
    { 0x2C68, 0x2C6C, 2, -1 },
    { 0x2C73, 0x2C76, 3, -1 },
    { 0x2C81, 0x2CE3, 2, -1 },
    { 0x2CEC, 0x2CEE, 2, -1 },
    { 0x2CF3, 0x2CF3, 1, -1 },
    { 0x2D00, 0x2D25, 1, -7264 },
    { 0x2D27, 0x2D2D, 6, -7264 },
    { 0xA641, 0xA66D, 2, -1 },
    { 0xA681, 0xA69B, 2, -1 },
    { 0xA723, 0xA72F, 2, -1 },
    { 0xA733, 0xA76F, 2, -1 },
    { 0xA77A, 0xA77C, 2, -1 },
    { 0xA77F, 0xA787, 2, -1 },
    { 0xA78C, 0xA791, 5, -1 },
    { 0xA793, 0xA793, 1, -1 },
    { 0xA794, 0xA794, 1, 48 },
    { 0xA797, 0xA7A9, 2, -1 },
    { 0xA7B5, 0xA7C3, 2, -1 },
    { 0xA7C8, 0xA7CA, 2, -1 },
    { 0xA7D1, 0xA7D7, 6, -1 },
    { 0xA7D9, 0xA7F6, 29, -1 },
    { 0xAB53, 0xAB53, 1, -928 },
    { 0xAB70, 0xABBF, 1, -38864 },
    { 0xFF41, 0xFF5A, 1, -32 },
    { 0x10428, 0x1044F, 1, -40 },
    { 0x104D8, 0x104FB, 1, -40 },
    { 0x10597, 0x105A1, 1, -39 },
    { 0x105A3, 0x105B1, 1, -39 },
    { 0x105B3, 0x105B9, 1, -39 },
    { 0x105BB, 0x105BC, 1, -39 },
    { 0x10CC0, 0x10CF2, 1, -64 },
    { 0x118C0, 0x118DF, 1, -32 },
    { 0x16E60, 0x16E7F, 1, -32 },
    { 0x1E922, 0x1E943, 1, -34 },
});
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
-- UTF-8 Extensions by DragShot
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
-- Include the functions utf8.sub(), utf8.upper(), utf8.lower() and
-- utf8.title(). All of them work with Unicode codepoints.
--  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
--
-- Transforms indexes of a utf8 string to be positive, using its length in codepoints.
-- Negative indices will wrap around like in the string functions.
--
local function ustrRelToAbs(str, startPos, endPos)
	local length = len(str);
	startPos = math.max(startPos < 0 and (length + startPos + 1) or startPos, 1);
	endPos = math.min(endPos < 0 and (length + endPos + 1) or endPos, length);
	return startPos, endPos;
end
--
-- Splits a string into many substrings by using the supplied separators.
-- The separators are appended at the end of each substring.
--
local function str_split(strng, ...)
	function dosplit(str, seps, pos, array)
		if (pos > #seps) then return; end
		local idx, length, sep = 1, string.len(str), seps[pos];
		while (idx <= length) do
			local nid, nlen = string.find(str, sep, idx, true);
			if (nid) then
				if (pos < #seps) then
					dosplit(string.sub(str, idx, nid-1)..sep, seps, pos + 1, array);
				else
					table.insert(array, string.sub(str, idx, nid-1)..sep);
				end
				idx = nlen + 1;
			else
				break;
			end
		end
		if (idx <= length) then
			if (pos < #seps) then
				dosplit(string.sub(str, idx), seps, pos + 1, array);
			else
				table.insert(array, string.sub(str, idx));
			end
		end
	end
	local seps, array = { ... }, {};
	if (#seps == 0) then
		seps = {' '};
	end
	dosplit(strng, seps, 1, array);
	return array;
end
--
-- Changes the casing of a single utf8 codepoint, by using the given conversion table.
--
local function convert_cp(ch, tbl)
	local begin_, end_ = 1, #tbl;
	while (begin_ < end_) do
		local mid = math.floor((begin_ + end_) / 2);
		if (tbl[mid].last < ch) then
			begin_ = mid + 1;
		elseif (tbl[mid].first > ch) then
			end_ = mid;
		elseif ((ch - tbl[mid].first) % tbl[mid].step == 0) then
			return ch + tbl[mid].offset;
		else
			return ch;
		end
	end
	return ch;
end
--
-- Changes the casing of all characters in a utf8 string, by using the given conversion table.
--
local function convert_string(str, tbl)
	local buf = {};
	local curPos, endPos = 1, #str;
	repeat
		local seqStartPos, seqEndPos = decode(str, curPos);
		if not seqStartPos then
			table.insert(buf, char(0xFFFD));
			curPos = curPos + 1;
		else
			local code = cp_single(str, seqStartPos, seqEndPos);
			table.insert(buf, char(convert_cp(code, tbl)));
			curPos = seqEndPos + 1
		end
	until curPos > endPos
	return table.concat(buf, '');
end
--
-- Returns a substring of a utf8 string ranging from startPos to endPos inclusive.
-- The positions correspond to Unicode codepoints instead of bytes.
--
local function sub(str, startPos, endPos)
	startPos, endPos = ustrRelToAbs(str, startPos, endPos or -1);
	if (endPos < startPos) then return ""; end
	local buf, pos = {}, 1;
	for _, ch in chars(str) do
		if (pos > endPos) then
			break;
		elseif (pos >= startPos) then
			table.insert(buf, ch);
		end
		pos = pos + 1;
	end
	return table.concat(buf, "");
end
--
-- Returns a copy of a utf8 string with all of its characters in uppercase.
--
local function upper(str)
	return convert_string(str, toupper_table);
end
--
-- Returns a copy of a utf8 string with all of its characters in lowercase.
--
local function lower(str)
	return convert_string(str, tolower_table);
end
--
-- Returns a copy of a utf8 string with each one of its words in titlecase.
--
local function title(str)
	local words = str_split(str, ' ', '\t', '\n', '-', '/', '\\', "'");
	local buf = {};
	for i, word in ipairs(words) do
		local seqStartPos, seqEndPos = decode(word);
		if not seqStartPos then
			table.insert(buf, char(0xFFFD)..lower(string.sub(word, 2)));
		else
			local code = cp_single(word, seqStartPos, seqEndPos);
			table.insert(buf, char(convert_cp(code, totitle_table)));
			if (seqEndPos < #word) then
				table.insert(buf, lower(string.sub(word, seqEndPos + 1)));
			end
		end
	end
	return table.concat(buf, '');
end

return {
	['charpattern'] = charpattern,
	['char'] = char,
	['chars'] = chars,
	['codes'] = codes,
	['codepoint'] = codepoint,
	['len'] = len,
	['offset'] = offset,
	['force'] = force,
	['sub'] = sub,
	['upper'] = upper,
	['lower'] = lower,
	['title'] = title
};
