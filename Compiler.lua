local Concat	= table.concat;
local Match		= string.match;
local Floor		= math.floor;
local Gsub		= string.gsub;
local Char		= string.char;
local Sub		= string.sub;
local Rep		= string.rep;
local Str		= tostring;

local Mixed		= {};
local Symbols	= {
	'<', '>', '!';
	'#', '=', '/';
};

local Tokens	= {
	'OPENC', 'CLOSEC', 'INV';
	'DEFINE', 'SET', 'SLICE';
};

for Idx = 1, #Symbols do
	Mixed[Symbols[Idx]]	= Tokens[Idx];
end;

Symbols	= nil;
Tokens	= nil;

local function Tokenize(Code)
	local Tokens	= {};
	local Buff		= {};
	local StrQ, StrA;
	local Embd	= 0;
	local Escaped;
	local Comment;

	for Idx = 1, #Code do
		local Key	= Sub(Code, Idx, Idx);
		local Peek	= Sub(Code, Idx + 1, Idx + 1);
		local Fin;

		Buff[#Buff + 1]	= Key;

		if (not Escaped) and (not StrQ) and (not StrA) and (Embd == 0) then
			if (Key == ';') then
				Comment	= (not Comment);

				if (not Comment) then
					Buff[#Buff]	= nil;
				end;
			elseif (Key == '\n') then
				Comment	= false;
			end;
		end;

		if Comment then
			Buff[#Buff]	= nil;
		elseif (Key == '"') and (not StrA) and (Embd == 0) and (not Escaped) then
			StrQ	= (not StrQ);
		elseif (Key == "'") and (not StrQ) and (Embd == 0) and (not Escaped) then
			Buff[#Buff]	= '"';

			StrA	= (not StrA);
		elseif (not StrA) and (not StrQ) and (not Escaped) then
			if (Key == '[') then
				Embd	= Embd + 1;
			elseif (Key == ']') then
				Embd	= Embd - 1;
			end;
		end;

		if (not Comment) then
			Fin				= Match(Concat(Buff), '^%s*(.-)%s*$');

			if (Embd == 0) and (not StrA) and (not StrQ) and Mixed[Key] then
				Tokens[#Tokens + 1]	= Mixed[Key];

				Buff	= {};
			elseif (Embd == 0) and (not StrA) and (not StrQ) and (Fin ~= '') and (Mixed[Peek] or Match(Peek, '^%s+$')) then
				Tokens[#Tokens + 1]	= 'DATA$' .. Fin;

				Buff	= {};
			end;
		end;

		if (not Escaped) then
			Escaped	= (Key == '\\');
		end;
	end;

	return Tokens;
end;

local function Safe(Str)
	return '"' .. Gsub(Str, '[\\"]', '\\%1') .. '"';
end;

local function Encode(Num)
	local Base	= Rep('\254', Floor(Num / 255));
	local Rem	= Num % 254;

	if (Rem == 0) then
		return Base .. '\1\255';
	else
		return Base .. Char(Rem) .. '\255';
	end
end;

local function Peek(Where, Index)
	local F	= Where[Index];

	if F then
		return Match(F, '^(%u+)$?(.*)$');
	end;
end;

return function(Code)
	local Tokens	= Tokenize(Code);
	local Consts	= {};
	local Instr		= {};
	local Skip		= 0;

	for Idx = 1, #Tokens do
		local Tok, Dt	= Peek(Tokens, Idx);

		if (Tok == 'DATA') then
			if (not Consts[Dt]) then
				local Form	= Safe(Dt);

				Skip		= Skip + 1;

				Consts[Dt]			= 'DATA$' .. Encode(Skip);
				Instr[#Instr + 1]	= Form;
			end;

			Tokens[Idx]	= Consts[Dt];
		end;
	end;

	Instr[#Instr + 1]	= '\255';
	Skip				= 0;

	for Idx = 1, #Tokens do
		local Index		= Skip + Idx;

		if (not Tokens[Idx]) then
			break;
		end;

		local Tok, Dt	= Peek(Tokens, Index);
		local Nex, Dx	= Peek(Tokens, Index + 1);

		if (Tok == 'OPENC') then
			local Th, Dh	= Peek(Tokens, Index + 2);
			local Add;

			if (Nex == 'SLICE') and (Th == 'DATA') then
				Instr[#Instr + 1]	= Concat{'\5', Dh, '\0'};

				Add	= 3;
			else
				local _, Name	= Peek(Tokens, Index + 1);

				Add		= 1;
				Skip	= Skip + 1;
				Instr[#Instr + 1]	= Concat{'\1', Name, '\0'};

				for Idx = (Skip + Idx), #Tokens do
					local T, D	= Peek(Tokens, Idx + Add);
					local N, K	= Peek(Tokens, Idx + Add + 1);

					if (T == 'CLOSEC') then
						break;
					elseif (T == 'INV') and (N == 'DATA') then
						Instr[#Instr + 1]	= Concat{'\3', K, '\0'};

						Add	= Add + 2;
					elseif (T == 'DATA') and (N == 'SET') then
						local _, K	= Peek(Tokens, Idx + Add + 2);

						Add	= Add + 2;

						Instr[#Instr + 1]	= Concat{'\2', D, K, '\0'};
					end;
				end;
			end;

			Skip	= Skip + Add;
		elseif (Tok == 'DEFINE') and (Nex == 'DATA') then
			local _, Def	= Peek(Tokens, Index + 3);

			Skip				= Skip + 3;
			Instr[#Instr + 1]	= Concat{'\4', Dx, Def, '\0'};
		end;
	end;

	return '\217md' .. Concat(Instr);
end;
