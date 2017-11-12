local Match	= string.match;
local Tonum	= tonumber;
local Byte	= string.byte;
local Sub	= string.sub;
local Upk	= unpack;
local New	= Instance.new; -- Editable to whatever I guess

local function Extract(Bit, Start, End)
	local Res	= (Bit / 2 ^ Start) % 2 ^ (End - Start + 1);

	return Res - Res % 1;
end;

return function(Bytes)
	local Constants	= {};
	local Instructs	= {};
	local Sig, Ksts	= Match(Bytes, '^(RML)%z(%x+)');
	local Posi		= 1;
	
	if (not Sig) then
		error('Bytecode format not supported');
	else
		Bytes	= Sub(Bytes, 5 + #Ksts);
		Ksts	= Tonum(Ksts, 16);
	end;
	
	for Idx	= 1, Ksts do
		local Type	= Byte(Bytes, Posi, Posi);
		
		if (Type == 0) then
			Constants[Idx]	= 0;
		elseif (Type == 1) then
			Constants[Idx]	= Byte(Bytes, Posi + 1, Posi + 1) == 1;
			
			Posi	= Posi + 1;
		elseif (Type == 2) then
			Constants[Idx]	= Tonum(Sub(Bytes, Posi + 1, Posi + 8), 16);
			
			Posi	= Posi + 8;
		elseif (Type == 3) then
			local Len	= Byte(Bytes, Posi + 1, Posi + 1);
			
			Constants[Idx]	= Tonum(Sub(Bytes, Posi + 2, Posi + 1 + Len));
			
			Posi	= Posi + Len + 1;
		elseif (Type == 4) then
			local Len	= Tonum(Sub(Bytes, Posi + 1, Posi + 8), 16);
			
			Constants[Idx]	= Sub(Bytes, Posi + 9, Posi + Len + 8);
			
			Posi	= Posi + Len + 8;
		end;
		
		Posi	= Posi + 1;
	end;
	
	Ksts	= Tonum(Sub(Bytes, Posi, Posi + 7), 16);
	Posi	= Posi + 8;
	
	for Idx = 1, Ksts do
		local A, B, C	= Byte(Bytes, Posi, Posi + 2);
		local Opco		= Extract(A, 0, 2);
		local Stack		= Extract(A, 3, 7);
		
		Instructs[#Instructs + 1]	= {
			Opco, Stack,
			B + (C * 256);
		};
		
		Posi	= Posi + 3;
	end;
	
	return function(Env)
		local Lays	= 0;
		local Stack	= {};
		local Tree	= {};
		local Return;
		
		for Idx = 1, Ksts do
			local Inst	= Instructs[Idx];
			local Op	= Inst[1];
			local Stk	= Inst[2];
			local Lay	= Tree[Lays];
			
			if (Op == 0) then -- LOADK
				Stack[Stk]	= Constants[Inst[3] + 1];
			elseif (Op == 1) then -- NEW
				local Inst	= New(Stack[Stk]);
				
				if (Lays == 0) then
					Return	= Inst;
				end;
				
				Lays		= Lays + 1;
				Tree[Lays]	= Inst;
			elseif (Op == 2) then -- SET
				Lay[Stack[Stk]]	= Stack[Inst[3]]; -- TODO: Fix stack not resetting on calls?
			elseif (Op == 3) then -- INV
				local Prop	= Stack[Stk];
				
				Lay[Prop]	= (not Lay[Prop]);
			elseif (Op == 4) then -- CLS
				if (Lay.ClassName == Stack[Stk]) then -- Check classname
					Tree[Lays]		= nil;
					Lays			= Lays - 1;
					
					Lay.Parent	= Tree[Lays];
				else
					error('Runtime error while closing');
				end;
			elseif (Op == 5) then -- CALL
				Stack[Stk]	= Env[Stack[Inst[3]]](Upk(Stack, 0, Stk - 1));
			end;
		end;
		
		return Return;
	end;
end;