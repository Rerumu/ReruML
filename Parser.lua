-- 3 bits for opcodes (8 instructs)
-- 5 bits for stack (32 places)
-- 16 bits for heap (65k places)

-- 0	LOADK
-- 1	NEW
-- 2	SET
-- 3	INV
-- 4	CLS
-- 5	CALL

-- Types
-- 0 > nil
-- 1 > bool
-- 2 > int
-- 3 > double
-- 4 > string

--[[
	Compiles instructions which are 3 bytes long
	Optimizations are made for large projects, but evade function calls
	as they will flush the beginning of the stack (depending on how many args they take)
--]]

local Concat	= table.concat;
local Format	= string.format;
local Match		= string.match;
local Tonum		= tonumber;
local Floor		= math.floor;
local Char		= string.char;
local Type		= type;
local Sub		= string.sub;

local Nil		= newproxy(false); -- Marker userdata

local function Flush(B)
	for Index in next, B do
		B[Index]	= nil;
	end;
end;

local function AsConstant(Value)
	local New;
	
	if Tonum(Value) then
		New	= Tonum(Value);
	elseif Match(Value, '^([\'"]).*%1$') then
		New	= Sub(Value, 2, -2);
	elseif (Value == 'true') then
		New	= true;
	elseif (Value == 'false') then
		New	= false;
	elseif (Value == 'nil') then
		New	= Nil;
	else
		New	= Value;
	end;
	
	return New;
end;

local function AsInstruct(List, Op, Stack, R)
	List[#List + 1]	= Concat{Char(Op + (Stack * 2 ^ 3)), Char(R % 256), Char(Floor(R / 256))};
end;

local function AsTokens(Stream)
	local Numstream		= #Stream;
	local Tokens		= {};
	local Buffer		= {};
	
	local Consts		= {};
	local Numconsts		= 0;
	
	local OQ, OA;
	local Cmt;
	local Esc;
	
	for Idx = 1, Numstream do
		local Char	= Sub(Stream, Idx, Idx);
		
		if (not Cmt) then
			if (not OQ) and (not OA) then -- Long ifs are fun
				if (Char == '<') or (Char == '>') or (Char == '(') or (Char == ')') or (Char == '/') or (Char == '=') or (Char == '!') then
					if Buffer[1] then
						Consts[#Consts + 1]	= AsConstant(Concat(Buffer));
						Tokens[#Tokens + 1]	= {'X', Consts[#Consts]};
						
						Flush(Buffer);
					end;
					
					Tokens[#Tokens + 1]	= {Char};
				elseif Match(Char, '%S') then
					Buffer[#Buffer + 1]	= Char;
				elseif Buffer[1] then
					Consts[#Consts + 1]	= AsConstant(Concat(Buffer));
					Tokens[#Tokens + 1]	= {'X', Consts[#Consts]};
					
					Flush(Buffer);
				end;
				
				if (Char == '"') then
					OQ	= true;
				elseif (Char == "'") then
					OA	= true;
				elseif (Char == '*') then
					Buffer[#Buffer]	= nil;
					
					Cmt	= true;
				end;
			else
				Buffer[#Buffer + 1]	= Char;
				
				if (OQ and (Char == '"')) or (OA and (Char == "'")) then
					Consts[#Consts + 1]	= AsConstant(Concat(Buffer));
					Tokens[#Tokens + 1]	= {'X', Consts[#Consts]};
					
					OQ	= false;
					OA	= false;
					
					Flush(Buffer);
				end;
			end;
		elseif (not Esc) and ((Char == '\n') or (Char == '*')) then
			Cmt	= false;
		end;
		
		if (not Esc) then
			Esc	= (Char == '\\');
		end;
	end;
	
	for Idx = 1, #Consts do
		local Value	= Consts[Idx];
		
		if (not Consts[Value]) then
			Numconsts	= Numconsts + 1;
			
			Consts[Value]	= true;
		end;
	end;
	
	return Tokens, Numconsts;
end;

return function(Code)
	local Tokens, Const	= AsTokens(Code);
	local Constants		= {};
	local MappedTo		= {}; -- TODO: Work out MappedTo overwrites
	
	local Final			= {};
	local FakeStack		= {};
	local FakeDicti		= {};
	local StackPointer	= 0;
	local NamedAs;
	
	local function IsAt(What, Type)
		return Tokens[What] and (Tokens[What][1] == Type);
	end;
	
	local function KfStack(Const, Force)
		if (not Force) and FakeDicti[Const] then
			return FakeDicti[Const];
		else
			local Point	= StackPointer;
			local Index	= MappedTo[Const];
			local Old	= FakeStack[Point];
			
			if (not Index) then
				local Num	= #Constants + 1;
				local Ty	= Type(Const);
				
				if (Const == Nil) then
					Constants[Num]	= '\0';
				elseif (Ty == 'boolean') then
					Constants[Num]	= Concat{'\1', Char(Const and 1 or 0)};
				elseif (Ty == 'number') then
					if ((Const % 1) == 0) then -- Is integer
						Constants[Num]	= Format('\2%08x', Const);
					else
						local Str	= Format('%e', Const);
						
						Constants[Num]	= Concat{'\3', Char(#Str), Str};
					end;
				elseif (Ty == 'string') then
					Constants[Num]	= Format('\4%08x%s', #Const, Const);
				end;
				
				Index			= Num;
				MappedTo[Const]	= Num;
			end;
			
			if Old then
				FakeDicti[Old]	= nil;
			end;
			
			AsInstruct(Final, 0, Point, Index - 1);
			FakeDicti[Const]	= Point;
			FakeStack[Point]	= Const;
			StackPointer		= (Point + 1) % 32;
			
			return Point;
		end;
	end;
	
	local Idx	= 1;
	for _ = 1, #Tokens do -- LOADK is already handled for us ok same
		if (not Tokens[Idx]) then
			break;
		end;
		
		if IsAt(Idx, '<') then
			if IsAt(Idx + 1, 'X') then
				NamedAs	= Tokens[Idx + 1][2];
				AsInstruct(Final, 1, KfStack(NamedAs), 0);
				
				Idx	= Idx + 1;
			elseif IsAt(Idx + 1, '/') then
				AsInstruct(Final, 4, KfStack(Tokens[Idx + 2][2]), 0);
				
				Idx	= Idx + 2;
			end;
		elseif IsAt(Idx, 'X') then
			repeat
				if IsAt(Idx, 'X') then
					if IsAt(Idx + 3, '(') then
						local Idz	= 0;
						
						while (not IsAt(Idx + Idz + 4, ')')) do
							if (Idz == 0) then
								StackPointer	= 0;
							end;
							
							KfStack(Tokens[Idx + Idz + 4][2], true);
							Idz	= Idz + 1;
						end;
						
						if (Idz > 30) then
							error('Too many arguments to function call');
						else
							local AtFake	= FakeStack[Idz];
							
							AsInstruct(Final, 5, Idz, KfStack(Tokens[Idx + 2][2]));
							AsInstruct(Final, 2, KfStack(Tokens[Idx][2], true), Idz);
							
							if (AtFake ~= nil) then
								FakeStack[AtFake]	= nil;
								FakeStack[Idz]		= nil;
							end;
							
							Idx	= Idx + Idz + 5;
						end;
					else -- Stuff after a function call gets skipped?
						AsInstruct(Final, 2, KfStack(Tokens[Idx][2]), KfStack(Tokens[Idx + 2][2]));
						
						Idx	= Idx + 3;
					end;
				elseif IsAt(Idx, '!') then
					AsInstruct(Final, 3, KfStack(Tokens[Idx + 1][2]), 0);
					
					Idx	= Idx + 1;
				end;
			until IsAt(Idx, '>') or IsAt(Idx, '/');
			
			if IsAt(Idx, '/') then -- Abnormal close
				AsInstruct(Final, 4, KfStack(NamedAs), 0);
			end;
			
			NamedAs	= nil;
		end;
		
		Idx	= Idx + 1;
	end;
	
	return Concat{
		'RML\0';
		Format('%08x', #Constants);
		Concat(Constants);
		Format('%08x', #Final);
		Concat(Final);
	};
end;