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

***NOTE: Both serializer and decompiler are out of date and will not work until further notice***
***ALSO NOTE: Currently very buggy after rewrite***

## Documentation

XML/HTML-like code can be compiled by calling the parser function and interpreted by the interpreter.
Example code (with additions due to function call related stuff):

```Lua
-- Example code
local Parser	= require('Parser');
local Interpret	= require('Interpreter');
local Code		= [[
<ScreenGui Name = 'heyyyy'>
	<Frame Name = 'owo' Size = UDim2(1 0 0.1 0)/>

	<Folder Name = 'Stuff I guess'>
		<StringValue Value = 'umu' Name = 'uwu'/>
		<StringValue Value = 'example' Name = 'yeet'/>
		<IntValue Value = 5 Name = 'number lol'/>
	</Folder>
</ScreenGui>
]];

local Bytecode	= Parser(Code);
local Function	= Interpret(Bytecode);

Function{UDim2 = UDim2.new}.Parent	= workspace;
```