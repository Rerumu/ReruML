local Properties	= { -- Bunch of properties.
	'Active',
	'AlwaysOnTop',
	'BackgroundColor3',
	'BackgroundTransparency',
	'BorderColor3',
	'BorderSizePixel',
	'ClipsDescendants',
	'Draggable',
	'Enabled',
	'Font',
	'Image',
	'ImageColor3',
	'ImageTransparency',
	'LayoutOrder',
	'LightInfluence',
	'Name',
	'Position',
	'Rotation',
	'Size',
	'SizeConstraint',
	'SizeOffset',
	'StudsOffset',
	'StudsOffsetWorldSpace',
	'Text',
	'TextColor3',
	'TextScaled',
	'TextStrokeColor3',
	'TextStrokeTransparency',
	'TextTransparency',
	'TextWrapped',
	'TextXAlignment',
	'TextYAlignment',
	'Visible',
	'ZIndex',
};

local function Catch(Object, Property)
	return Object[Property];
end;

local function Num(Number)
	return math.floor(Number * 1000) / 1000;
end;

local function TypeHandle(Data)
	local Type	= typeof(Data);
	local Ret;
	
	if (Type == 'string') then
		return '"' .. tostring(Data) .. '"';
	elseif (Type == 'EnumItem') then
		return '"' .. tostring(Data):match'[^%.]+$' .. '"';
	elseif (Type == 'number') then
		return tostring(Num(Data));
	elseif (Type == 'boolean') then
		return tostring(Data);
	elseif (Type == 'UDim2') then
		Ret	= table.concat({Num(Data.X.Scale), Num(Data.X.Offset), Num(Data.Y.Scale), Num(Data.Y.Offset)}, ', ');
	elseif (Type == 'Vector2') then
		Ret	= Num(Data.X) .. ', ' .. Num(Data.Y);
	elseif (Type == 'Color3') then
		Ret	= table.concat({Num(Data.r), Num(Data.g), Num(Data.b)}, ', ');
	else
		return 'nil';
	end;
	
	return string.format('[%s %s]', Type, Ret);
end;

local function Serialize(Object, Result, Inline)
	local Result	= Result or '#UDim2 = [*UDim2/new]\n#Color3 = [*Color3/new]\n#Vector2 = [*Vector2/new]\n\n';
	local Inline	= Inline or 0;
	local Child		= Object'GetChildren';
	local Property	= {Object.ClassName};
	
	Result	= string.format('%s%s<%s', Result, string.rep('\9', Inline), (#Child == 0 and '~') or '');
	
	for _, Prop in next, Properties do
		local Has, Got	= pcall(Catch, Object, Prop);
		
		if Has then -- Got real lazy but I really can't think of a more efficient way.
			Property[#Property + 1]	= Prop;
			Property[#Property + 1]	= '=';
			Property[#Property + 1]	= TypeHandle(Got);
		end;
	end;
	
	Result	= Result .. table.concat(Property, '\32') .. '>\n';
	
	if (#Child ~= 0) then
		for _, Chi in next, Child do
			Result	= Serialize(Chi, Result, Inline + 1);
		end;
		
		Result	= string.format('%s%s</%s>\n', Result, string.rep('\9', Inline), Object.ClassName);
	end;
	
	return Result;
end;

return Serialize;