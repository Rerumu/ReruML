# Intro

Woah. **Technology.**
This is the 3rd language I've made so far.
The language has a style similar to that of HTML and the like.
While it is made for use in ROBLOX to create instances you can use it with whatever system you have by simply changing the `Instance.new` local inside of it.

The language was inspired by [cntkillme](https://www.roblox.com/users/294568/profile) but with a different take on the structure.
This source is entirely made by [Rerumu](https://www.roblox.com/users/70540486/profile).
It is to be noted that the compiler and interpreter are independent and do not rely on eachother. That said, you can pre-compile your code into bytecode strings and they will run normally at runtime or be sent over machines to be interpreted.

As always; I am not perfect so please inform me of any bugs!

*Note: For those of you who may be a bit more into it or advanced I have created a decompiler you can debug with.*

## Example
Html is the closest syntax highlighting I can get to.

```Html
#UDim2:[*UDim2/new] ; The * means it is a path.
#Serv:[*game/GetService] ; Because I am lazy.
#Storage:[Serv game, "StarterGui"] ; Statements can only use " and no ' for strings.

; Semicolons are used to start and end comments unless a newline does so.

<ScreenGui Name:'Test' Parent:Storage> ; Globals are handled as usual.
	<~Frame ; The ~ means it is automatically closed.
		Name:'Top'
		Size:[UDim2 1, 0, 0.1, 0] ; Without the * it calls the function with the args given.
	>
	<~TextBox
		Name:'Text' ; Strings are handled as usual.
		Text:'Five hours later.'
		Position:[UDim2 0, 0, 0.1, 0]
		Size:[UDim2 1, 0, 0.1, 0]
		!Visible ; This makes it "not Visible". Opposite of what it was.
	>
<ScreenGui/> ; This closes and goes back to the previous layer if any.
```

The Lua should look a bit like this.

```Lua
local Confi	= require(PathToCompiler); -- The paths whatever they may be.
local Intr	= require(PathToInterpreter);

local Code	= [[
	#UDim2:[*UDim2/new]
	#Serv:[*game/GetService]
	#Storage:[Serv game, "StarterGui"]

	<ScreenGui Name:'Test' Parent:Storage>
		<~Frame
			Name:'Top'
			Size:[UDim2 1, 0, 0.1, 0]
		>
		<~TextBox
			Name:'Text'
			Text:'Five hours later.'
			Position:[UDim2 0, 0, 0.1, 0]
			Size:[UDim2 1, 0, 0.1, 0]
			!Visible
		>
	<ScreenGui/>
]];

local Byte	= Confi(Code);
local Gui	  = Intr(Byte, getfenv());

Gui(); -- Creates the Gui (and returns it).
```
