# Intro

Woah. **Technology.**
This is the 3rd language I've made so far.
The language has a style similar to that of HTML and the like.
While it is made for use in ROBLOX to create instances you can use it with whatever system you have by simply changing the `Instance.new` local inside of it.

The language was inspired by [cntkillme](https://www.roblox.com/users/294568/profile) but with a different take on the structure.
This source is entirely made by [Rerumu](https://www.roblox.com/users/70540486/profile).
It is to be noted that the compiler and interpreter are independent and do not rely on eachother. That said, you can pre-compile your code into bytecode strings and they will run normally at runtime or be sent over machines to be interpreted.

Recent addition of a serializer. Why create instances using this and (probably) take forever when you can just use the serializer? Calling the serializer with the arguments Serializer(Instance Object) will return a ReruML string of code to generate the instance with all its children. **Cough** Compiling your guis serverside and sending bytecode to the client to obfuscate and prevent tampering. **Cough**

As always; I am not perfect so please inform me of any bugs!

*Note: For those of you who may be a bit more into it or advanced I have created a decompiler you can debug with.*

## Example
Html is the closest syntax highlighting I can get to.

```Html
#UDim2 = [*UDim2/new] ; Semicolons are comments.
#Color3 = [*Color3/new]

<ScreenGui Enabled = true Name = "Screen">
	<TextLabel Active = false BackgroundColor3 = [Color3 1, 1, 1] BackgroundTransparency = 0 BorderColor3 = [Color3 0.105, 0.164, 0.207] BorderSizePixel = 1 ClipsDescendants = false Draggable = false Font = "SourceSans" LayoutOrder = 0 Name = "Test" Position = [UDim2 0, 0, 0, 0] Rotation = 0 Size = [UDim2 1, 0, 0.05, 0] SizeConstraint = "RelativeXY" Text = "ton for pres" TextColor3 = [Color3 0.105, 0.164, 0.207] TextScaled = false TextStrokeColor3 = [Color3 0, 0, 0] TextStrokeTransparency = 1 TextTransparency = 0 TextWrapped = false TextXAlignment = "Center" TextYAlignment = "Center" Visible = true ZIndex = 1></TextLabel>
	<TextBox Active = true BackgroundColor3 = [Color3 0.333, 0.666, 0.498] BackgroundTransparency = 0 BorderColor3 = [Color3 0.105, 0.164, 0.207] BorderSizePixel = 1 ClipsDescendants = false Draggable = false Font = "SourceSans" LayoutOrder = 0 Name = "TextBox" Position = [UDim2 0, 0, 0.5, 0] Rotation = 0 Size = [UDim2 1, 0, 0, 50] SizeConstraint = "RelativeXY" Text = "woosh" TextColor3 = [Color3 0.105, 0.164, 0.207] TextScaled = false TextStrokeColor3 = [Color3 0, 0, 0] TextStrokeTransparency = 1 TextTransparency = 0 TextWrapped = false TextXAlignment = "Center" TextYAlignment = "Center" Visible = true ZIndex = 1></TextBox>
</ScreenGui>
```

The Lua should look a bit like this.

```Lua
local Confi	= require(PathToCompiler); -- The paths whatever they may be.
local Intr	= require(PathToInterpreter);

local Code	= [[
	#UDim2 = [*UDim2/new]
	#Color3 = [*Color3/new]

	<ScreenGui Enabled = true Name = "Screen">
		<TextLabel Active = false BackgroundColor3 = [Color3 1, 1, 1] BackgroundTransparency = 0 BorderColor3 = [Color3 0.105, 0.164, 0.207] BorderSizePixel = 1 ClipsDescendants = false Draggable = false Font = "SourceSans" LayoutOrder = 0 Name = "Test" Position = [UDim2 0, 0, 0, 0] Rotation = 0 Size = [UDim2 1, 0, 0.05, 0] SizeConstraint = "RelativeXY" Text = "ton for pres" TextColor3 = [Color3 0.105, 0.164, 0.207] TextScaled = false TextStrokeColor3 = [Color3 0, 0, 0] TextStrokeTransparency = 1 TextTransparency = 0 TextWrapped = false TextXAlignment = "Center" TextYAlignment = "Center" Visible = true ZIndex = 1></TextLabel>
		<TextBox Active = true BackgroundColor3 = [Color3 0.333, 0.666, 0.498] BackgroundTransparency = 0 BorderColor3 = [Color3 0.105, 0.164, 0.207] BorderSizePixel = 1 ClipsDescendants = false Draggable = false Font = "SourceSans" LayoutOrder = 0 Name = "TextBox" Position = [UDim2 0, 0, 0.5, 0] Rotation = 0 Size = [UDim2 1, 0, 0, 50] SizeConstraint = "RelativeXY" Text = "woosh" TextColor3 = [Color3 0.105, 0.164, 0.207] TextScaled = false TextStrokeColor3 = [Color3 0, 0, 0] TextStrokeTransparency = 1 TextTransparency = 0 TextWrapped = false TextXAlignment = "Center" TextYAlignment = "Center" Visible = true ZIndex = 1></TextBox>
	</ScreenGui>
]];

local Byte	= Confi(Code);
local Gui	= Intr(Byte, getfenv());

Gui().Parent	= workspace; -- Creates the Gui (and returns it).
```
