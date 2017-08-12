local StrByte	= string.byte;
local Remove	= table.remove;
local Insert	= table.insert;
local Concat	= table.concat;
local Gmatch	= string.gmatch;
local Match		= string.match;
local Gsub		= string.gsub;
local Tonu		= tonumber;
local Str		= tostring;
local New		= Instance.new;
local Sub		= string.sub;
local Upk		= unpack;

local function Process(Env, ...)
	local Args	= {...};
	local Ret	= {};

	for Idx = 1, #Args do
		local Arg	= Args[Idx];

		if (Arg ~= 'nil') then
			if (Arg == 'true') then
				Ret[Idx]	= true;
			elseif (Arg == 'false') then
				Ret[Idx]	= false;
			elseif Tonu(Arg) then
				Ret[Idx]	= Tonu(Arg);
			elseif (Env[Arg] ~= nil) then
				Ret[Idx]	= Env[Arg];
			else
				local A, B	= Match(Arg, '^(.)(.*).$');

				if (A == '"') then
					Ret[Idx]	= B;
				elseif (A == '[') then
					A, B	= Match(B, '^(.)(.*)$');

					if (A == '*') then
						local Curr	= Env;

						for Path in Gmatch(B, '[^/]+') do
							Curr	= Curr[Path];
						end;

						Ret[Idx]	= Curr;
					else
						local Name, Args	= Match(A .. B, '^(%S+)%s*(.*)$');

						if Name then
							local Funct			= Env[Name];
							local NumA			= #Args;
							local Prc			= {};
							local Bf			= {};
							local Qo, Qa, Es;

							for Idz = 1, NumA do
								local Ke	= Sub(Args, Idz, Idz);

								Bf[#Bf + 1]	= Ke;

								if (Ke == "'") and (not Qo) and (not Es) then
									Qa	= (not Qa);
								elseif (Ke == '"') and (not Qa) and (not Es) then
									Qo	= (not Qo);
								end;

								if ((Ke == ',') and (not Qo) and (not Qa)) or (Idz == NumA) then
									if (Ke == ',') then
										Bf[#Bf]	= nil;
									end;

									Prc[#Prc + 1]	= Match(Concat(Bf), '^%s*(.-)%s*$');

									Bf				= {};
								end;

								if (not Es) then
									Es	= (Ke == '\\');
								else
									Es	= false;
								end;
							end;

							Ret[Idx]	= Funct(Process(Env, Upk(Prc)));
						end;
					end;
				end;
			end;
		end;
	end;

	return Upk(Ret);
end;

return function(Byte, Env)
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
	Buff	= nil;

	return function()
		local Stacks	= {};
		local Current;
		local First; -- The return.

		for Idx = 1, #Final do
			local Data	= Final[Idx];
			local Intr	= Data[1];
			local A, B	= Data[2], Data[3];
			
			if (Intr == 1) then -- NEW
				local Cr	= New(A);

				Cr.Parent	= Current;

				Current	= Cr;
				Insert(Stacks, 1, Cr);
				
				if (not First) then
					First	= Cr;
				end;
			elseif (Intr == 2) then -- SET
				Current[A]	= Process(B);
			elseif (Intr == 3) then -- NEG
				Current[A]	= (not Current[A]);
			elseif (Intr == 4) then -- GLO
				Env[A]		= Process(B);
			elseif (Intr == 5) then -- CLS
				if Stacks[1] and (Stacks[1].ClassName == A) then
					Remove(Stacks, 1); -- Fixed some parenting stuff.
				end;

				Current	= Stacks[1];
			end;
		end;

		return First;
	end;
end;