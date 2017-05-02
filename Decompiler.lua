local Sub		= string.sub;
local Rep		= string.rep;
local Gsub		= string.gsub;
local Gmatch	= string.gmatch;
local Concat	= table.concat;
local StrByte	= string.byte;
 -- *Yawn* So I decided that this needed a decompiler to look at compiled source. Woops? Have fun although this is not needed for the whole thing to function.
return function(Byte)
	assert('Invalid bytecode string.', Sub(Byte, 1, 3) == '\217md');

	local Constants	= {};
	local Buff		= {};
	local Quo, Esc;
	local Final;

	for Idx = 1, #Byte do
		local Key	= Sub(Byte, Idx, Idx);

		Buff[#Buff + 1]	= Key;

		if (not Esc) then
			if (Key == '"') then
				if Quo then
					Constants[#Constants + 1]	= Sub(Concat(Buff), 1, -2);

					Quo	= false;
				else
					Buff	= {};

					Quo		= true;
				end;
			elseif (Key == '\255') then
				Buff	= nil;

				Final	= Sub(Byte, Idx + 1);

				break;
			end;

			Esc	= (Key == '\\');
		else
			Esc	= false;
		end;
	end;

	Buff	= {};

	for Str in Gmatch(Final, '%Z+') do
		local Args	= Sub(Str, 2);
		local Proc	= 0;
		local Now	= {StrByte(Str)};

		for Idx = 1, #Args do
			local Ke	= Sub(Args, Idx, Idx);

			if (Ke == '\255') then
				local Const	= Gsub(Constants[Proc], '\\([\\"])', '%1');

				Now[#Now + 1]	= Const;

				Proc			= 0;
			else
				Proc			= Proc + StrByte(Ke);
			end;
		end;

		Buff[#Buff + 1]	= Now;
	end;

	Final	= Buff;
	Buff	= '; Decompiled result...\n\n';

	local Stack	= 0;

	for Idx = 1, #Final do
		local Data	= Final[Idx];
		local Intr	= Data[1];
		local A, B	= Data[2], Data[3];

		if (Intr == 1) then -- NEW
			Buff	= Concat{Buff, Rep('\9', Stack), '<', A};

			Stack	= Stack + 1;
		elseif (Intr == 2) then -- ANEW
			Buff	= Concat{Buff, Rep('\9', Stack), '<~', A};
		elseif (Intr == 3) then -- SET
			Buff	= Concat{Buff, ' ', A, ':', B};
		elseif (Intr == 4) then -- NEG
			Buff	= Concat{Buff, ' !', A};
		elseif (Intr == 5) then -- GLO
			Buff	= Concat{Buff, '#', A, ':', B, '\n'};
		elseif (Intr == 6) then -- CLS
			if A then
				Stack	= Stack - 1;

				Buff	= Concat{Buff, Rep('\9', Stack), '<', A, '/>\n'};
			else
				Buff	= Concat{Buff, '>\n'};
			end;
		end;
	end;

	return Buff;
end;
