--[[ Pepsi's UI Library
Better and updated web-based docs are planned in distant future.
Library v0.36 [
    CreateWindow: Function (
        (table | nil) Options [
            (string | nil) Name = "Window Name"
            (boolean | nil) MobileButton = true or false // Draggable show/hide button for touch devices. Default: automatic (touch & no keyboard)
            (JSON | nil) DefaultTheme/Theme = "[...]"
            (boolean | nil) Themeable/DefaultTheme/Theme = true or false | Options [
                (string | number | nil) Image = "rbxassetid://7483871523" | 7483871523
                (boolean | nil) Credit = true or false // You're removing my credits? Kinda hurts.
                (string | table | nil) Info = "Extra info displayed in designer" | Lines ["line 1", "line 2", "line 3", "and so on..."]
				(string | number | table | nil) Background/Backdrop/Grahpic = "rbxassetid://13337" | 13337 | Options [
					(string | number | nil) 1/Asset = "rbxassetid://13337" | 13337
					(number | nil) 2/Transparency = 0.5 | 50 // Both examples will make the backdrop half visible
					(boolean | number | nil) 3/Visible = true or false | 1 or 0 // 1: true, 0: false
				]
            ]
        ]
    ) -> Window [
        CreateTab: Function (
            (table | nil) Options [
                (string | nil) Name = "Tab Name"
                (string | number | nil) Image = "rbxassetid://133337" | 133337
            ]
        ) -> Tab [
            CreateSection: Function (
                (table) Options [
                    (string | nil) Name = "Section Name"
                    (string | nil) Side = "Left" or "Right"
                ]
            ) -> Section [
                AddLabel: Function (
                    (table) Options [
                        (string | nil) Text/Value/Name = "Label Text"
                        (string | nil) Flag = "FlagName"
                        (any) UnloadValue = UnloadValue
                        (function | nil) UnloadFunc = Function
                    ]
                ) -> Label [
                    Options: Table
                    Name: String
                    Type: String
                    Default: String
                    Parent: Section
                    Instance: Instance
                    Set: Function (NewText) -> NewText
					RawSet: Function (NewText) -> NewText // Same function as Set. For backwards compatibility.
                    Reset: Function -> DefaultText
                    Get: Function -> CurrentText
					Update: Function -> CurrentText // Same function as Get, exists for compat.
                ]
                AddToggle: Function (
                    (table) Options [
                        (string) Name = "Toggle Name"
                        (boolean | nil) Value/Enabled = true or false
                        (function | nil) Callback = Function (NewValue, OldValue)
                        (string | nil) Flag = "FlagName"
                        (table | nil) Location = Table
                        (string | nil) LocationFlag = "LocationFlag"
                        (any) UnloadValue = UnloadValue
                        (function | nil) UnloadFunc = Function
                        (boolean | nil) Locked = true or false
                        (table | boolean | EnumItem | nil) Keybind/Key/KeyBind = Keybind [
                            (string | nil) Flag = "ToggleKeybindFlag"
                            (EnumItem | nil) Value = Enum.KeyCode.F
                            (function | nil) Callback = Function (NewValue, OldValue)
                            (function | nil) Pressed = Function
                            (string | nil) Mode = "Dynamic" or "Hold" or "Toggle"
                            (number | nil) DynamicTime = 0.65
                            (table | nil) Location = Table
                            (string | nil) LocationFlag = "LocationFlag"
                            (table | nil) KeyNames = Table
                        ]
                        (function | nil) Condition = Function (NewValue, LastValue) // Will only allow the toggle state to be changed, if this function returns true
						(boolean | nil) AllowDuplicateCalls = true or false // Allow the callback to be fired with same value set()
                    ]
                ) -> ToggleInfo [
                    Options: Table
                    Type: String
                    Name: String
                    Default: Boolean
                    Parent: Section
                    Instance: Instance
                    SetLocked: Function (LockedState) -> LockState
                    Unlock: function
                    Lock: Function
                    Update: Function -> CurrentValue
                    Set: Function (NewValue) -> NewValue
                    RawSet: Function (NewValue, Condition) -> NewValue // Sets the flag without firing the callback
                    Reset: Function -> DefaultText
                    Get: Function -> CurrentValue
                    SetCondition: Function (NewCondition) -> NewCondition
                ]
                AddTextbox: Function (
                    (table) Options [
                        (string) Name = "Textbox Name"
                        (string | number) Value = "String" or 1337
                        (function | nil) Callback = Function (NewValue, OldValue)
                        (string | nil) Flag = "FlagName"
                        (table | nil) Location = Table
                        (string | nil) LocationFlag = "LocationFlag"
                        (any) UnloadValue = UnloadValue
                        (function | nil) UnloadFunc = Function
                        (string | nil) Placeholder = "Text to display by default"
                        (string | nil) Type = "number"
                        (number | nil) Min = 0
                        (number | nil) Max = 100
                        (number | nil) Decimals/Precision/Precise = 2
                        (boolean | nil) Hex = true or false
                        (boolean | nil) Binary = true or false
                        (number | nil) Base = 10
                        (boolean | nil) Rich/RichText/RichTextBox = true or false
                        (boolean | nil) Lines/MultiLine = true or false
                        (boolean | nil) Scaled/TextScaled = true or false
                        (EnumItem | nil) Font/TextFont = Enum.Font.GothamBold
                        (function | nil) PreFormat = Function (Value)
                        (function | nil) PostFormat = Function (Value)
                        (table | nil) CustomProperties = Properties [
                        	TextTruncate = Enum.TextTruncate.None
                        ]
						(boolean | nil) AllowDuplicateCalls = true or false // Allow the callback to be fired with same value set()
                    ]
                ) -> Textbox [
                    Options: Table
                    Name: String
                    Type: String
                    Default: String/Number
                    Parent: Section
                    Instance: Textbox
                    Update: Function -> CurrentValue
                    Set: Function (NewValue) -> NewValue
					RawSet: Function (NewValue) -> NewValue // Sets the flag without firing the callback
                    Reset: Function -> DefaultText
                    Get: Function -> CurrentValue
                ]
                AddSlider: Function (
                    (table) Options [
                        (string) Name = "Slider Name"
                        (number | nil) Value = 0
                        (function | nil) Callback = Function (Value, OldValue)
                        (string | nil) Flag = "FlagName"
                        (table | nil) Location = Table
                        (string | nil) LocationFlag = "LocationFlag"
                        (any) UnloadValue = UnloadValue
                        (function | nil) UnloadFunc = Function
                        (number) Min = 0
                        (number) Max = 100
                        (number | nil) Decimals/Precision/Precise = 2
                        (string | function | nil) Format = "Value %s" | Function (Value, LastValue)
                        (boolean | nil) IllegalInput = true or false // Allow textbox to break min & max limits
                        (boolean | table | nil) Textbox/InputBox/CustomInput = true | Options [
                            (boolean | nil) Hex = true or false
                            (boolean | nil) Binary = true or false
                            (number | nil) Base = 10
                            (function | nil) PreFormat = Function (Value)
                            (function | nil) PostFormat = Function (Value)
                            (boolean | nil) IllegalInput = true or false // Allow textbox to break min & max limits
                        ]
						(boolean | nil) AllowDuplicateCalls = true or false // Allow the callback to be fired with same value set()
                    ]
                ) -> Slider [
                    Options: Table
                    Name: String
                    Type: String
                    Default: Number
                    Parent: Section
                    Instance: Instance
                    Update: Function (FromValue) -> CurrentValue
                    Set: Function (NewValue) -> NewValue
                	RawSet: Function (NewValue) -> NewValue // Changes value without firing callback
                    Reset: Function -> DefaultText
                    Get: Function -> CurrentValue
                    SetConstraints: Function (NewMin, NewMax)
                    SetMin: Function (NewMin)
                    SetMax: Function (NewMax)
                ]
                AddButton: Function (
                    (table) Options [
                        (string) Name = "Button Name"
                        (function | nil) Callback = Function (NumPresses)
                        (function | nil) MouseEnterCallback = Function (NumPresses)
                        (function | nil) MouseLeaveCallback = Function (NumPresses)
                        (function | nil) CallbackRight = Function (NumPresses)
                        (function | nil) ConditionRight = Function (NumPresses)
						(function | nil) Condition = Function (NumPresses) // Will only allow the button to be pressed, if this function returns true
						(boolean | nil) Locked = true or false
                    ]
                    (table | nil) Options ...
                ) -> Buttons [
                    Options: Table
                    Name: String
                    Type: String
                    Parent: Section
                    Instance: Instance
                    Update: Function -> ButtonName
                    Press: Function (...)
                    SetLocked: Function (LockedState) -> LockState
                    Unlock: function
                    Lock: Function
					SetCondition: Function(NewCondition) -> NewCondition
					RawPress: Function (...) // Does not update press count
                    Get: Function -> Callback, NumPresses
					SetText: Function (NewText) -> NewText
					SetCallback: Function (NewCallback) -> NewCallback
                ]
                AddKeybind: Function (
                    (table) Options [
                        (string) Name = "Keybind Name"
                        (EnumItem | nil) Value = Enum.KeyCode.F
                        (function | nil) Callback = Function (NewValue, OldValue)
                        (string | nil) Flag = "FlagName"
                        (table | nil) Location = Table
                        (string | nil) LocationFlag = "LocationFlag"
                        (any) UnloadValue = UnloadValue
                        (function | nil) UnloadFunc = Function
                        (function | nil) Pressed = Function (InputObject, GameProcessed)
                        (table | nil) KeyNames = Table
						(boolean | nil) AllowDuplicateCalls = true or false // Allow the callback to be fired with same value set()
                    ]
                ) -> Keybind [
                    Options: Table
                    Name: String
                    Type: String
                    Parent: Section
                    Instance: Instance
                    Update: Function
                    Set: Function (NewValue) -> NewValue
                    Reset: Function -> DefaultText
                    Get: Function -> CurrentValue
                ]
                AddDropdown: Function (
                    (table) Options [
                        (string) Name = "Dropdown Name"
                        (any) Value = Value
                        (function | nil) Callback = Function (NewValue, LastValue)
                        (string | nil) Flag = "FlagName"
                        (table | nil) Location = Table
                        (string | nil) LocationFlag = "LocationFlag"
                        (any) UnloadValue = UnloadValue
                        (function | nil) UnloadFunc = Function
                        (table | Instance | Enum | function) List = Table | workspace | Enum.Font | Function () -> New List
                        (string | function | table | nil) Filter = "StringToMatch" | Function (ValueToCheck) | Table [
                            (boolean | nil) [0] = InverseBool
                            (any) [1] ... = "StringToMatch" | Enum.Font.GothamBold/ValuesToMatch
                        ]
                        (string | function | table | nil) Method = "GetDescendants" | workspace.GetDescendants | Parameters [
                        	(string | function) [1/Method] = "GetFriendsOnline" | Player.GetFriendsOnline
                        	(any) [1/2/Args/Arguments] ... = 50
                        ]
                        (string | nil) BlankValue/NoValueString/Nothing = "No Selection"
                        (boolean | function | nil) Sort = true or false | Function
                        (boolean | string | nil) Multi/Multiple/MultiSelect = true or false | "Text to display"
                        (function | nil) ItemAdded/AddedCallback = Function (Item, AllItems)
                        (function | nil) ItemRemoved/RemovedCallback = Function (Item, AllItems)
                        (function | nil) ItemChanged/ChangedCallback = Function (Item, SelectedState, Items)
                        (function | nil) ItemsCleared/ClearedCallback = Function (Items, PreviousItems)
						(EnumItem/Keycode | nil) ScrollUpButton = Enum.KeyCode.Up // Default is Enum.KeyCode.Up
						(EnumItem/Keycode | nil) ScrollDownButton = Enum.KeyCode.Down // Default is Enum.KeyCode.Down
						(number | nil) ScrollButtonRate / ScrollRate = 5 // How fast the scroller goes by pressing the scroll buttons
						(bool | nil) DisablePrecisionScrolling = true or false // Dissallows use of keys to control pan
						(boolean | nil) AllowDuplicateCalls = true or false // Allow the callback to be fired with same value set()
                    ]
                ) -> Dropdown [
                    Options: Table
                    Name: String
                    Type: String
                    Default: Value
                    Parent: Section
                    Instance: Instance
                    Update: Function
                    Set: Function (NewValue) -> NewValue
					RawSet: Function (NewValue) -> NewValue // Sets value without firing callback
                    Reset: Function -> DefaultValue
                    Get: Function -> CurrentValue
                    UpdateList: Function (
                    	(table | Instance | Enum | function) List = Table | workspace | Enum.Font | Function () -> New List
                    	(boolean | nil) ValidateValues = true or false | nil // When set to true, will call Validate() on it
                    ) -> NewList
                    Validate: Function (
                    	(any | nil) InvalidValue = "Optional value to be set, if the list's current value is no longer in list"
                    ) -> IsValidBool
                ]
                AddSearchBox: Function (
                    (table) Options [
                        (string) Name = "SearchBox Name"
                        (any) Value = Value
                        (function | nil) Callback = Function (NewValue, LastValue)
                        (string | nil) Flag = "FlagName"
                        (table | nil) Location = Table
                        (string | nil) LocationFlag = "LocationFlag"
                        (any) UnloadValue = UnloadValue
                        (function | nil) UnloadFunc = Function
                        (table | Instance | Enum | function) List = Table | workspace | Enum.Font | Function () -> New List
                        (string | function | table | nil) Filter = "StringToMatch" | Function (ValueToCheck) | Table [
                            (boolean | nil) [0] = InverseBool
                            (string | any | nil) [1] ... = "StringToMatch" | Enum.Font.GothamBold
                        ]
                        (string | function | table | nil) Method = "GetDescendants" | workspace.GetDescendants | Parameters [
                        	(string | function) [1/Method] = "GetFriendsOnline" | Player.GetFriendsOnline
                        	(any) [1/2/Args/Arguments] ... = 50
                        ]
                        (boolean | function | nil) Sort = true or false | Function
                        (string | nil) BlankValue/NoValueString/Nothing = "No Selection"
                        (boolean | string | nil) Multi/Multiple/MultiSelect = true or false | "Text to display"
                        (function | nil) ItemAdded/AddedCallback = Function (Item, AllItems)
                        (function | nil) ItemRemoved/RemovedCallback = Function (Item, AllItems)
                        (function | nil) ItemChanged/ChangedCallback = Function (Item, SelectedState, Items)
                        (function | nil) ItemsCleared/ClearedCallback = Function (Items, PreviousItems)
						(EnumItem/Keycode | nil) ScrollUpButton = Enum.KeyCode.Up // Default is Enum.KeyCode.Up
						(EnumItem/Keycode | nil) ScrollDownButton = Enum.KeyCode.Down // Default is Enum.KeyCode.Down
						(number | nil) ScrollButtonRate / ScrollRate = 5 // How fast the scroller goes by pressing the scroll buttons
						(bool | nil) DisablePrecisionScrolling = true or false // Dissallows use of keys to control pan
						(boolean | nil) RegEx = true or false // Enables use of %d and %w, etc (False by default)
						(boolean | nil) AllowDuplicateCalls = true or false // Allow the callback to be fired with same value set()
                    ]
                ) -> SearchBox [
                    Options: Table
                    Name: String
                    Type: String
                    Default: Value
                    Parent: Section
                    Instance: Instance
                    Update: Function
                    Set: Function (NewValue) -> NewValue
					RawSet: Function (NewValue) -> NewValue // Sets value without firing callback
                    Reset: Function -> DefaultValue
                    Get: Function -> CurrentValue
                    UpdateList: Function (
                    	(table | Instance | Enum | function) List = Table | workspace | Enum.Font | Function () -> New List
                    	(boolean | nil) ValidateValues = true or false | nil // When set to true, will call Validate() on it
                    ) -> NewList
                    Validate: Function (
                    	(any | nil) InvalidValue = "Optional value to be set, if the list's current value is no longer in list"
                    ) -> IsValidBool
                ]
                AddColorpicker: Function (
                    (table) Options [
                        (string) Name = "Colorpicker Name"
                        (string | Color3 | nil) Value = "rainbow" or "random" | Color3.new()
                        (function | nil) Callback = Function (NewValue, LastValue)
                        (string | nil) Flag = "FlagName"
                        (table | nil) Location = Table
                        (string | nil) LocationFlag = "LocationFlag"
                        (any) UnloadValue = UnloadValue
                        (function | nil) UnloadFunc = Function
                        (boolean | nil) Rainbow = true or false
                        (boolean | nil) Random = true or false
						(boolean | nil) AllowDuplicateCalls = true or false // Allow the callback to be fired with same value set()
                    ]
                ) -> Colorpicker [
                    Options: Table
                    Name: String
                    Type: String
                    Default: Color3
                    Parent: Section
                    Instance: Instance
                    Update: Function
                    Set: Function (NewValue) -> NewValue
					RawSet: Function (NewValue) -> NewValue // Sets value without firing callback
                    Reset: Function -> DefaultColor
                    Get: Function -> CurrentValue
                    SetRainbow: Function (
                        (boolean | nil) RainbowMode = true or false
                    )
                ]
                AddPersistence: Function (
                    (table) Options [
                        (string) Name = "Persistence Name"
                        (string | nil) Value = "FileName"
                        (function | nil) Callback = Function (NewValue, LastValue)
                        (string | nil) Flag = "FlagName"
                        (table | nil) Location = Table
                        (string | nil) LocationFlag = "LocationFlag"
                        (any) UnloadValue = UnloadValue
                        (function | nil) UnloadFunc = Function
                        (string | nil) Workspace = "FolderName"
                        (boolean | string | number | table | nil) Persistive/Flags = true | "all" | 1 (Window) or 2 (Tab) or 3 (Section) | FlagNames [...]
                        (string | nil) Suffix = "Mods"
                        (function | nil) LoadCallback = Function (FilePath, FileName) // 'PreLoad'
                        (function | nil) SaveCallback = Function (FilePath, FileName)
                        (function | nil) PostLoadCallback = Function (FilePath, FileName)
                        (function | nil) PostSaveCallback = Function (FilePath, FileName)
						(EnumItem/Keycode | nil) ScrollUpButton = Enum.KeyCode.Up // Default is Enum.KeyCode.Up
						(EnumItem/Keycode | nil) ScrollDownButton = Enum.KeyCode.Down // Default is Enum.KeyCode.Down
						(number | nil) ScrollButtonRate / ScrollRate = 5 // How fast the scroller goes by pressing the scroll buttons
						(bool | nil) DisablePrecisionScrolling = true or false // Dissallows use of keys to control pan
						(boolean | nil) AllowDuplicateCalls = true or false // Allow the callback to be fired with same value set()
                    ]
                ) -> Persistence [
                    Options: Table
                    Name: String
                    Type: String
                    Default: Value
                    Parent: Section
                    Instance: Instance
                    Update: Function
                    Set: Function (NewValue) -> NewValue
					RawSet: Function (NewValue) -> NewValue // Sets value without firing callback
                    Reset: Function -> DefaultFile
                    Get: Function -> CurrentValue
					SaveFile: Function (FileName) // Mimics the Save Button with optional file input
					LoadFile: Function (FileName) // Mimics the Load Button with optional file input
					LoadJSON: Function (JSON) // Mimics the Load Button with specific json
					LoadFileRaw: Function (FileName) // Mimics the Load Button with optional file input using Obj:RawSet
					LoadJSONRaw: Function (JSON) // Mimics the Load Button with specific json using Obj:RawSet
					GetJSON: Function (Func) // Gets the json, and passes it as the first argument of Func. Set to true to use setclipboard
                ]
            ]
            Flags: Table
        ]
        CreateDesigner: Function (
            (table) Options [
				(string | number | table | nil) Background/Backdrop/Grahpic = "rbxassetid://13337" | 13337 | Options [
					(string | number | nil) 1/Asset = "rbxassetid://13337" | 13337
					(number | nil) 2/Transparency = 0.5 | 50 // Both examples will make the backdrop half visible
					(boolean | number | nil) 3/Visible = true or false | 1 or 0 // 1: true, 0: false
				]
                (string | number | nil) Image = "rbxassetid://7483871523" | 7483871523
                (string | table | nil) Info = "Extra info displayed in designer" | Lines ["line 1", "line 2", "line 3", "and so on..."]
                (boolean | nil) Credit = true
            ]
        ) -> Designer [
            Options: Table
            Parent: Window
            Name: String
            Type: String
            Instance: Instance,
            SetBackground: Function (
            	(string | boolean | number | nil) AssetString = "rbxassetid://7483871523" | true or false (as Visible arg) | 7483871523 or transparency (0-100 or 0-1) | nil (Toggle visibility)
            	(number | boolean | nil) Transparency = 0.7 or 70 | true or false (as Visible arg)
            	(number | boolean | nil) Visible = true/1 or false/0 | nil (Dont change)
            )
        ]
        MoveTabSlider: Function (
            (Instance) tabObject = tabVar
        )
        GoHome: Function
        Flags: Table
    ]
    Designer: Designer
    LP: LocalPlayer
    Players: game.Players
    Mouse: LP:GetMouse()
    Unload: Function
	ResetAll: Function // Resets all elements to their default value
	SaveFile: Function (FileName) // Only if designer is present; this would save all non-deisgner elements
	LoadFile: Function (FileName)
	LoadJSON: Function (JSON)
	LoadFileRaw: Function (FileName)
	LoadJSONRaw: Function (JSON)
	GetJSON: Function (Func)
	signals: Table // All :connection()'s go in that table, and are disconnected upon unloading the gui. Feel free to add yours here, too
    (function | nil) UnloadCallback = Function
	(EnumItem/Keycode | nil) scrollupbutton = Enum.KeyCode.Up // Default is Enum.KeyCode.Up
	(EnumItem/Keycode | nil) scrolldownbutton = Enum.KeyCode.Down // Default is Enum.KeyCode.Down
    Subs: Shared Functions [
		updatecolors: Function // Re-Applys all colors from designer
		Wait: Function (Time) // Only waits & returns true if the library has not been unloaded
		removeSpaces: Function (String)
		Color3ToHex: Function (Color3)
		Color3FromHex: Function (String/Hex)
		textToSize: Function (String)
		Instance_new: Function (Class, Parent) // Automatically protects instances with syn.protect_gui, and adds the instance to library.objects (all objects destroyed when unloading)
    ]
]
]]
local library = {
	Version = "0.37",
	WorkspaceName = "QuickX Hub",
	flags = {},
	signals = {},
	objects = {},
	elements = {},
	globals = {},
	subs = {},
	colored = {},
	configuration = {
		hideKeybind = shared.force_toggle_gui_keybind or Enum.KeyCode.RightShift,
		smoothDragging = false,
		uiScale = 1,
		easingStyle = Enum.EasingStyle.Quart,
		easingDirection = Enum.EasingDirection.Out
	},
	colors = {
		main = Color3.fromRGB(38, 235, 120),
		background = Color3.fromRGB(14, 17, 15),
		outerBorder = Color3.fromRGB(14, 14, 14),
		innerBorder = Color3.fromRGB(34, 62, 46),
		topGradient = Color3.fromRGB(13, 19, 15),
		bottomGradient = Color3.fromRGB(13, 19, 15),
		sectionBackground = Color3.fromRGB(19, 24, 21),
		section = Color3.fromRGB(205, 205, 205),
		otherElementText = Color3.fromRGB(122, 122, 122),
		elementText = Color3.fromRGB(236, 236, 236),
		elementBorder = Color3.fromRGB(36, 54, 43),
		selectedOption = Color3.fromRGB(30, 38, 33),
		unselectedOption = Color3.fromRGB(21, 29, 24),
		hoveredOptionTop = Color3.fromRGB(36, 58, 44),
		unhoveredOptionTop = Color3.fromRGB(42, 42, 42),
		hoveredOptionBottom = Color3.fromRGB(46, 46, 46),
		unhoveredOptionBottom = Color3.fromRGB(34, 34, 34),
		tabText = Color3.fromRGB(255, 255, 255)
	},
	gui_parent = (function()
		local x, c = pcall(function()
			return game:GetService("CoreGui")
		end)
		if x and c then
			return c
		end
		x, c = pcall(function()
			return (game:IsLoaded() or (game.Loaded:Wait() or true)) and game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
		end)
		if x and c then
			return c
		end
		x, c = pcall(function()
			return game:GetService("StarterGui")
		end)
		if x and c then
			return c
		end
		return error("Seriously bad engine. Can't find a place to store the GUI. Robust code can't help this much incompetence.")
	end)(),
	colorpicker = false,
	colorpickerconflicts = {},
	rainbowflags = {},
	rainbows = 0,
	rainbowsg = 0
}
library.Subs = library.subs
local library_flags = library.flags
library.Flags = library_flags
local destroyrainbows, destroyrainbowsg
local function darkenColor(clr, intensity)
	if intensity and (intensity ~= 1) then
	else
		return clr
	end
	if clr and ((typeof(clr) == "Color3") or (type(clr) == "table")) then
		return Color3.new(clr.R / intensity, clr.G / intensity, clr.B / intensity)
	end
end
library.subs.darkenColor = darkenColor
local __runscript = true
local function wait_check(...)
	if __runscript then
		return wait(...)
	else
		wait()
		return false
	end
end
library.subs.Wait, library.subs.wait, library.Wait = wait_check, wait_check, wait_check
function library.IsGuiValid()
	return __runscript
end
local lasthidebing = 0
local temp = game:FindService("MarketplaceService") or game:GetService("MarketplaceService")
local Marketplace = (temp and (cloneref and cloneref(temp))) or temp
local resolvevararg, temp
do
	local lwr = string.lower
	function library.defaultSort(a, b)
		return lwr(tostring(b)) > lwr(tostring(a))
	end
end
do
	local varargresolve = {
		Window = {"Name", "Theme"},
		Tab = {"Name", "Image"},
		Section = {"Name", "Side"},
		Label = {"Text", "Flag", "UnloadValue", "UnloadFunc"},
		Toggle = {"Name", "Value", "Callback", "Flag", "Location", "LocationFlag", "UnloadValue", "UnloadFunc", "Locked", "Keybind", "Condition", "AllowDuplicateCalls"},
		Textbox = {"Name", "Value", "Callback", "Flag", "Location", "LocationFlag", "UnloadValue", "UnloadFunc", "Placeholder", "Type", "Min", "Max", "Decimals", "Hex", "Binary", "Base", "RichTextBox", "MultiLine", "TextScaled", "TextFont", "PreFormat", "PostFormat", "CustomProperties", "AllowDuplicateCalls"},
		Slider = {"Name", "Value", "Callback", "Flag", "Location", "LocationFlag", "UnloadValue", "UnloadFunc", "Min", "Max", "Decimals", "Format", "IllegalInput", "Textbox", "AllowDuplicateCalls"},
		Button = {"Name", "Callback", "Locked", "Condition"},
		Keybind = {"Name", "Value", "Callback", "Flag", "Location", "LocationFlag", "UnloadValue", "UnloadFunc", "Pressed", "KeyNames", "AllowDuplicateCalls"},
		Dropdown = {"Name", "Value", "Callback", "Flag", "Location", "LocationFlag", "UnloadValue", "UnloadFunc", "List", "Filter", "Method", "Nothing", "Sort", "MultiSelect", "ItemAdded", "ItemRemoved", "ItemChanged", "ItemsCleared", "ScrollUpButton", "ScrollDownButton", "ScrollButtonRate", "DisablePrecisionScrolling", "AllowDuplicateCalls"},
		SearchBox = {"Name", "Value", "Callback", "Flag", "Location", "LocationFlag", "UnloadValue", "UnloadFunc", "List", "Filter", "Method", "Nothing", "Sort", "MultiSelect", "ItemAdded", "ItemRemoved", "ItemChanged", "ItemsCleared", "ScrollUpButton", "ScrollDownButton", "ScrollButtonRate", "DisablePrecisionScrolling", "RegEx", "AllowDuplicateCalls"},
		Colorpicker = {"Name", "Value", "Callback", "Flag", "Location", "LocationFlag", "UnloadValue", "UnloadFunc", "Rainbow", "Random", "AllowDuplicateCalls"},
		Persistence = {"Name", "Value", "Callback", "Flag", "Location", "LocationFlag", "UnloadValue", "UnloadFunc", "Workspace", "Persistive", "Suffix", "LoadCallback", "SaveCallback", "PostLoadCallback", "PostSaveCallback", "ScrollUpButton", "ScrollDownButton", "ScrollButtonRate", "DisablePrecisionScrolling", "AllowDuplicateCalls"},
		Designer = {"Backdrop", "Image", "Info", "Credit"}
	}
	function resolvevararg(objtype, ...)
		local data = varargresolve[objtype]
		local t = {}
		if data then
			for index, value in next, {...} do
				t[data[index]] = value
			end
		end
		return t
	end
end
local resolvercache = {}
library.resolvercache = resolvercache
local function resolveid(image, flag)
	if image then
		if type(image) == "string" then
			if ((#image > 14) and (string.sub(image, 1, 13) == "rbxassetid://")) or ((#image > 12) and (string.sub(image, 1, 11) == "rbxasset://")) or ((#image > 12) and (string.sub(image, 1, 11) ~= "rbxthumb://")) then
				if flag then
					local thing = library.elements[flag] or library.designerelements[flag]
					if thing and thing.Set then
						task.spawn(thing.Set, thing, image)
					end
				end
				return image
			end
		end
		local orig = image
		if resolvercache[orig] then
			if flag then
				local thing = library.elements[flag] or library.designerelements[flag]
				if thing and thing.Set then
					task.spawn(thing.Set, thing, resolvercache[orig])
				end
			end
			return resolvercache[orig]
		end
		image = tonumber(image) or image
		local succezz = pcall(function()
			local typ = type(image)
			if typ == "string" then
				if getsynasset then
					if (#image > 11) and (string.sub(image, 1, 11) == "synasset://") then
						return getsynasset(string.sub(image, 12))
					elseif shared.no_http_assets then
					elseif (#image > 14) and (string.sub(image, 1, 14) == "synasseturl://") then
						local x, e = pcall(function()
							local codename, fixes = string.gsub(image, ".", function(c)
								if (c:lower() == c:upper()) and not tonumber(c) then
									return ""
								end
							end)
							codename = string.sub(codename, 1, 24) .. tostring(fixes)
							local fold = isfolder("./QuickX Hub")
							if fold then
							else
								makefolder("./QuickX Hub")
							end
							fold = isfolder("./QuickX Hub/Themes")
							if fold then
							else
								makefolder("./QuickX Hub/Themes")
							end
							fold = isfolder("./QuickX Hub/Themes/SynapseAssetsCache")
							if fold then
							else
								makefolder("./QuickX Hub Themes/SynapseAssetsCache")
							end
							if fold and isfile("./QuickX Hub/Themes/SynapseAssetsCache/" .. codename .. ".dat") then
							else
								if shared.no_http_assets then
									image = nil
									do
										return error("User has HTTP assets disabled.")
									end
									return (error("Attempt to bypass user HTTP preference"))(#-wot)
								end
								local res = shared.no_http_assets or game:HttpGet(string.sub(image, 15))
								if res ~= nil then
									writefile("./QuickX Hub/Themes/SynapseAssetsCache/" .. codename .. ".dat", res)
								end
							end
							return getsynasset(readfile("./QuickX Hub/Themes/SynapseAssetsCache/" .. codename .. ".dat"))
						end)
						if x and (e ~= nil) then
							return e
						end
					end
				end
				if (#image < 11) or ((string.sub(image, 1, 13) ~= "rbxassetid://") and (string.sub(image, 1, 11) ~= "rbxasset://") and (string.sub(image, 1, 11) ~= "rbxthumb://")) then
					image = tonumber(image:gsub("%D", ""), 10) or image
					typ = type(image)
				end
			end
			if (typ == "number") and (image > 0) then
				pcall(function()
					local nfo = Marketplace and Marketplace:GetProductInfo(image)
					image = tostring(image)
					if nfo and (nfo.AssetTypeId == 1) then
						image = "rbxassetid://" .. image
					elseif nfo.AssetTypeId == 13 then
						local decal = game:GetObjects("rbxassetid://" .. image)[1]
						image = "rbxassetid://" .. ((decal and decal.Texture) or "0"):match("%d+$")
						decal = (decal and decal:Destroy() and nil) or nil
					end
				end)
			else
				image = nil
			end
		end)
		if succezz and image then
			if orig then
				resolvercache[orig] = image
			end
			resolvercache[image] = image
			if flag then
				local thing = library.elements[flag] or library.designerelements[flag]
				if thing and thing.Set then
					task.spawn(thing.Set, thing, image)
				end
			end
		end
	end
	return image
end
library.subs.ResolveID = resolveid
library.resolvercache = resolvercache
local GetPath
do
	local HTTP = game:GetService("HttpService")
	function GetPath(Object)
		local RealName = ""
		for _ = 1, 42 do
			local Terminal
			local Parent = Object.Parent
			local Name
			if Parent then
				if Parent == game then
					Name = Object.ClassName
					Terminal = true
				end
			else
				Name = "NIL"
				Terminal = true
			end
			RealName = `][|+|{Name or Object.Name}][|-|{RealName}`
			Object = Parent
			if Terminal then
				break
			end
		end
		return HTTP:UrlEncode(RealName)
	end
	library.subs.GetPath = GetPath
	library.GetPath = GetPath
end
local ResolvePath
do
	local function UnHexCharacters(Characters)
		return string.char(tonumber(Characters, 16))
	end
	local function NilPatch()
		return getnilinstances()
	end
	function ResolvePath(RealName)
		RealName = string.gsub(RealName, "%%(%x%x)", UnHexCharacters)
		local Names = {}
		for Segment in string.gmatch(RealName, "%]%[|%+|(.-)%]%[|%-|") do
			Names[1 + #Names] = Segment
		end
		local Name = Names[1]
		local Object
		if Name == "NIL" then
			if getnilinstances then
				Object = {
					GetChildren = NilPatch
				}
			else
				return
			end
		else
			Object = game:GetService(Name) or game:FindFirstChildOfClass(Name) or game:FindFirstChildWhichIsA(Name) or game:FindFirstChild(Name)
		end
		for Index, Name in next, Names, 1 do
			local NextName = Names[1 + Index]
			for _, Child in next, Object:GetChildren() do
				if Child.Name == Name then
					if NextName then
						if Child:FindFirstChild(NextName) then
						else
							continue
						end
						local Fail
						for _, FutureName in next, Names, Index + 1 do
							if Child:FindFirstChild(FutureName, true) then
							else
								Fail = true
								break
							end
						end
						if Fail then
							continue
						end
					end
					Object = Child
				end
			end
			if Object then
			else
				break
			end
		end
		return Object
	end
	library.subs.ResolvePath = ResolvePath
	library.ResolvePath = ResolvePath
end
local function ResolveDropdownItemName(multiselect, passed_multiselect, Name, selectedOption, flagName, blankstring)
	local resolvedstr = "Select Item"
	if multiselect then
		resolvedstr = "Select Item(s)"
		if passed_multiselect == "string" then
			return passed_multiselect
		end
		Name = blankstring or selectedOption
	end
	if selectedOption and (type(selectedOption) ~= "table") then
		resolvedstr = tostring(selectedOption)
	else
		local val = library_flags[flagName]
		if (val ~= nil) and (type(val) ~= "table") then
			return tostring(val)
		elseif blankstring and (type(blankstring) == "string") then
			resolvedstr = blankstring
		elseif Name and (type(Name) == "string") then
			return Name
		end
	end
	return resolvedstr or "Select Item"
end
local colored, colors = library.colored, library.colors
-- Quick Hub V2 polish: rounds every element frame (toggle, slider, textbox, dropdown...)
-- and swaps its square 1px border for a theme-aware UIStroke. Set shared.quick_no_polish = true to disable.
local polishQueue, polishScheduled = {}, false
local function polishFlush()
	polishScheduled = false
	local queue = polishQueue
	polishQueue = {}
	local borders
	for _, inst in next, queue do
		pcall(function()
			if inst.Parent and (inst.Name ~= "tabsHolderGradientImg") and (inst.Image == "rbxassetid://2454009026") and not inst:FindFirstChildOfClass("UICorner") then
				local corner = Instance.new("UICorner")
				corner.CornerRadius = UDim.new(0, 5)
				corner.Parent = inst
				if inst.BorderSizePixel > 0 then
					if not borders then
						borders = {}
						for _, data in next, colored do
							if data[2] == "BorderColor3" then
								borders[data[1]] = data
							end
						end
					end
					local entry = borders[inst]
					if entry then
						local stroke = Instance.new("UIStroke")
						stroke.Color = inst.BorderColor3
						stroke.Thickness = 1
						stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
						stroke.Parent = inst
						inst.BorderSizePixel = 0
						entry[1], entry[2] = stroke, "Color"
					end
				end
			end
		end)
	end
end
local function queuePolish(inst)
	if shared.quick_no_polish then
		return
	end
	polishQueue[1 + #polishQueue] = inst
	if not polishScheduled then
		polishScheduled = true
		task.defer(polishFlush)
	end
end
local WhiteColor3 = Color3.new(1, 1, 1)
local tweenService = game:GetService("TweenService")
local updatecolors, MainScreenGui
do
	local MayGC = 0
	task.spawn(function()
		local IsDescendantOf = game.IsDescendantOf
		local RemoveTable = table.remove
		while wait_check() do
			while shared.NO_LIB_GC do
				wait(20)
				if wait_check() then
				else
					return
				end
			end
			wait(10)
			local Breathe = 30
			for DataIndex = #colored, 1, -1 do
				if MayGC > 0 then
					break
				end
				Breathe -= 1
				if Breathe <= 0 then
					Breathe = 30
					if wait_check() then
						if MayGC > 0 then
							break
						end
					else
						return
					end
				end
				if MayGC > 0 then
					break
				end
				local data = colored[DataIndex]
				data = data and data[1]
				if data and (typeof(data) == "Instance") and IsDescendantOf(data, MainScreenGui) then
				elseif MayGC <= 0 then
					RemoveTable(colored, DataIndex)
				else
					break
				end
			end
			local sigs = library.signals
			local len = sigs and #sigs
			if len then
				local Dyn = math.round(len / 10)
				Dyn = ((Dyn < 1) and 1) or Dyn
				for DataIndex = len, 1, -1 do
					Breathe -= 1
					if Breathe <= 0 then
						Breathe = Dyn
						if wait_check() then
						else
							return
						end
					end
					local data = sigs[DataIndex]
					if data and (typeof(data) == "RBXScriptConnection") and data.Connected then
					else
						RemoveTable(sigs, DataIndex)
					end
				end
			end
		end
	end)
	local function colortwee(data, tweenit)
		local cclr = colors[data[3]]
		local darkness = data[4]
		tweenService:Create(data[1], TweenInfo.new(tweenit, library.configuration.easingStyle, library.configuration.easingDirection), {
			[data[2]] = (darkness and (darkness ~= 1) and darkenColor(cclr, darkness)) or cclr
		}):Play()
	end
	local function colordarktwee(data)
		local cclr = colors[data[3]]
		local darkness = data[4]
		data[1][data[2]] = (darkness and (darkness ~= 1) and darkenColor(cclr, darkness)) or cclr
	end
	function updatecolors(tweenit)
		MayGC += 1
		if library.objects and ((#library.objects > 0) or next(library.objects)) then
			for _, data in next, colored do
				local x, e
				if tweenit then
					x, e = pcall(colortwee, data, tweenit)
				end
				if x then
				else
					x, e = pcall(colordarktwee, data)
					if x then
					elseif e then
						warn(debug.traceback(e))
					end
				end
			end
			pcall(function()
				if library.Backdrop then
					library.Backdrop.Visible = library_flags["__Designer.Background.UseBackgroundImage"] and true
					library.Backdrop.Image = resolveid(library_flags["__Designer.Background.ImageAssetID"], "__Designer.Background.ImageAssetID") or ""
					library.Backdrop.ImageColor3 = library_flags["__Designer.Background.ImageColor"] or WhiteColor3
					library.Backdrop.ImageTransparency = (library_flags["__Designer.Background.ImageTransparency"] or 95) / 100
				end
			end)
		end
		MayGC -= 1
	end
end
local function updatecolorsnotween()
	updatecolors()
end
library.subs.updatecolors = updatecolors
library.colors = setmetatable({}, {
	__index = colors,
	__newindex = function(_, k, v)
		if colors[k] ~= v then
			colors[k] = v
			spawn(updatecolorsnotween)
		end
	end
})
local elements = library.elements
-- only one UI at a time: if the script is executed again, remove the copy that is still loaded from the earlier run
if shared.libraries and (#shared.libraries > 0) then
	for _, old in ipairs(table.clone(shared.libraries)) do
		if (type(old) == "table") and (type(old.unload) == "function") then
			pcall(old.unload)
		end
	end
end
shared.libraries = shared.libraries or {}
local colorpickerconflicts = library.colorpickerconflicts
local keyHandler = {
	notAllowedKeys = {
		[Enum.KeyCode.Return] = true,
		[Enum.KeyCode.Space] = true,
		[Enum.KeyCode.Tab] = true,
		[Enum.KeyCode.Unknown] = true,
		[Enum.KeyCode.Backspace] = true
	},
	notAllowedMouseInputs = {
		[Enum.UserInputType.MouseMovement] = true,
		[Enum.UserInputType.MouseWheel] = true,
		[Enum.UserInputType.MouseButton1] = true,
		[Enum.UserInputType.MouseButton2] = true,
		[Enum.UserInputType.MouseButton3] = true
	},
	allowedKeys = {
		[Enum.KeyCode.LeftShift] = "LShift",
		[Enum.KeyCode.RightShift] = "RShift",
		[Enum.KeyCode.LeftControl] = "LCtrl",
		[Enum.KeyCode.RightControl] = "RCtrl",
		[Enum.KeyCode.LeftAlt] = "LAlt",
		[Enum.KeyCode.RightAlt] = "RAlt",
		[Enum.KeyCode.CapsLock] = "CAPS",
		[Enum.KeyCode.One] = "1",
		[Enum.KeyCode.Two] = "2",
		[Enum.KeyCode.Three] = "3",
		[Enum.KeyCode.Four] = "4",
		[Enum.KeyCode.Five] = "5",
		[Enum.KeyCode.Six] = "6",
		[Enum.KeyCode.Seven] = "7",
		[Enum.KeyCode.Eight] = "8",
		[Enum.KeyCode.Nine] = "9",
		[Enum.KeyCode.Zero] = "0",
		[Enum.KeyCode.KeypadOne] = "Num-1",
		[Enum.KeyCode.KeypadTwo] = "Num-2",
		[Enum.KeyCode.KeypadThree] = "Num-3",
		[Enum.KeyCode.KeypadFour] = "Num-4",
		[Enum.KeyCode.KeypadFive] = "Num-5",
		[Enum.KeyCode.KeypadSix] = "Num-6",
		[Enum.KeyCode.KeypadSeven] = "Num-7",
		[Enum.KeyCode.KeypadEight] = "Num-8",
		[Enum.KeyCode.KeypadNine] = "Num-9",
		[Enum.KeyCode.KeypadZero] = "Num-0",
		[Enum.KeyCode.Minus] = "-",
		[Enum.KeyCode.Equals] = "=",
		[Enum.KeyCode.Tilde] = "~",
		[Enum.KeyCode.LeftBracket] = "[",
		[Enum.KeyCode.RightBracket] = "]",
		[Enum.KeyCode.RightParenthesis] = ")",
		[Enum.KeyCode.LeftParenthesis] = "(",
		[Enum.KeyCode.Semicolon] = ";",
		[Enum.KeyCode.Quote] = "'",
		[Enum.KeyCode.BackSlash] = "\\",
		[Enum.KeyCode.Comma] = ",",
		[Enum.KeyCode.Period] = ".",
		[Enum.KeyCode.Slash] = "/",
		[Enum.KeyCode.Asterisk] = "*",
		[Enum.KeyCode.Plus] = "+",
		[Enum.KeyCode.Period] = ".",
		[Enum.KeyCode.Backquote] = "`"
	}
}
local function SeverAllConnections(t, cache)
	cache = cache or {}
	for k, v in next, t or {} do
		t[k] = nil
		if v ~= nil then
			if cache[v] then
				continue
			end
			local te = v and typeof(v)
			if te then
				if te == "RBXScriptConnection" then
					v:Disconnect()
				elseif te == "Instance" then
					v:Destroy()
				elseif te == "table" then
					cache[v] = true
					SeverAllConnections(v, cache)
				end
			end
		end
	end
end
library.Subs.SeverAllConnections = SeverAllConnections
local function hardunload(library)
	if library.UnloadCallback and (type(library.UnloadCallback) == "function") then
		local x, e = pcall(library.UnloadCallback)
		if x then
		else
			task.spawn(error, e or "error with unloadcallback", 2)
		end
	end
	for cflag, data in next, elements do
		if data.Type ~= "Persistence" then
			if data.Set and data.Options.UnloadValue ~= nil then
				data.Set(data.Options.UnloadValue)
			end
			if data.Options.UnloadFunc then
				local y, u = pcall(data.Options.UnloadFunc)
				if y then
				elseif u then
					warn(debug.traceback("Error unloading '" .. tostring(cflag) .. "'\n" .. u))
				end
			end
		end
	end
	local hardcache = {}
	SeverAllConnections(library.signals, hardcache)
	SeverAllConnections(library.objects, hardcache)
	hardcache = (table.clear(hardcache) and nil) or nil
	library.signals = nil
	library.objects = nil
end
library.Subs.UnloadArg = hardunload
local function unloadall()
	if shared.libraries then
		local b = 50
		while #shared.libraries > 0 do
			b -= 1
			if b < 0 then
				b = 50
				wait(warn("Looped 50 times while unloading....?"))
			end
			local v = shared.libraries[1]
			if v and v.unload and (type(v.unload) == "function") then
				if pcall(v.unload) then
				else
					pcall(hardunload, v)
					for k in next, v do
						v[k] = nil
					end
				end
				if shared.libraries then
					pcall(function()
						table.remove(shared.libraries, 1)
					end)
				else
					return pcall(hardunload, library)
				end
			end
		end
	end
	shared.libraries = nil
end
shared.unloadall = unloadall
library.unloadall = unloadall
shared.libraries[1 + #shared.libraries] = library
shared.latest_library = library
function library.unload()
	__runscript = nil
	hardunload(library)
	if shared.libraries then
		for k, v in next, shared.libraries or {} do
			if v == library then
				for k in next, table.remove(shared.libraries or {}, k) do
					v[k] = nil
				end
				break
			end
		end
		if shared.libraries and (#shared.libraries == 0) then
			shared.libraries, shared.latest_library = nil
		end
	end
	if (library ~= shared.latest_library) or next(shared.latest_library) then
	else
		shared.latest_library = nil
	end
	if library and next(library) then
		warn("Unloaded", library)
	end
end
library.Unload = library.unload
local Instance_new = (syn and syn.protect_gui and function(...)
	local x = {Instance.new(...)}
	if x[1] then
		library.objects[1 + #library.objects] = x[1]
		pcall(syn.protect_gui, x[1])
		local class = (...)
		if (class == "ImageLabel") or (class == "ImageButton") then
			queuePolish(x[1])
		end
	end
	return unpack(x)
end) or function(...)
	local x = {Instance.new(...)}
	if x[1] then
		library.objects[1 + #library.objects] = x[1]
		local class = (...)
		if (class == "ImageLabel") or (class == "ImageButton") then
			queuePolish(x[1])
		end
	end
	return unpack(x)
end
library.subs.Instance_new = Instance_new
local playersservice = game:GetService("Players")
local function getresolver(listt, filter, method, _)
	local huo, args = type(filter), {}
	local hou = typeof(listt)
	return ((hou == "function") and function(...)
		return listt(...)
	end) or ((hou == "table") and function()
		return listt
	end) or function()
		local hardtype
		local g = listt
		for _ = 1, 5 do
			hardtype = typeof(g)
			if hardtype == "function" then
				local x, e = pcall(listt)
				if x and e then
					g = e
				end
				hardtype = typeof(g)
			end
			if hardtype == "Instance" then
				local lastg = g
				if (method == nil) and (listt == playersservice) then
					g = listt:GetPlayers()
				end
				if method then
					local metype = type(method)
					if metype == "table" then
						method = method.Method or method[1]
						args = method.Args or method.Arguments or unpack(method, ((method.Method ~= nil) and 1) or 2)
						metype = type(method)
					end
					local y, u
					if metype == "function" then
						y, u = pcall(method, listt, unpack(args))
					elseif metype == "string" then
						local y, u = pcall(function()
							return listt[method](listt, unpack(args))
						end)
					else
						warn("Idk how to handle method type of", metype, debug.traceback(""))
					end
					if u then
						if y then
							g = u
						else
							warn("Error trying method", method, "on", listt, debug.traceback(u))
						end
					end
				end
				if g == lastg then
					g = listt:GetChildren()
				end
			end
			if hardtype == "Enum" then
				g = listt:GetEnumItems()
			end
			hardtype = typeof(g)
			if hardtype == "table" then
				break
			end
		end
		hardtype = typeof(g)
		if hardtype ~= "table" then
			warn("Could not resolve " .. hou .. " type to a list.")
			return {}
		end
		if filter then
			if huo == "function" then
				local accept = {}
				for _, v in next, g do
					local x, e = pcall(filter, v)
					if x and e then
						accept[1 + #accept] = ((e == true) and v) or e
					end
				end
				g = accept
			elseif huo == "string" then
				local accept = {}
				for _, v in next, g do
					if tostring(v):lower():find(huo) then
						accept[1 + #accept] = v
					end
				end
				g = accept
			elseif huo == "table" then
				local accept = {}
				if type(filter[1]) == "string" then
					for _, v in next, g do
						if tostring(v):lower():find(huo) then
							accept[1 + #accept] = v
						elseif filter[0] then
							accept[1 + #accept] = v
						end
					end
				else
					for _, v in next, g do
						if not table.find(filter, v) and not table.find(filter, tostring(v)) then
							accept[1 + #accept] = v
						elseif filter[0] then
						else
							accept[1 + #accept] = v
						end
					end
				end
				g = accept
			end
		end
		return g
	end
end
library.subs.GetResolver = getresolver
local function resetall()
	destroyrainbowsg = true
	pcall(function()
		for k, v in next, elements do
			if v and k and v.Set and (v.Default ~= nil) and (library_flags[k] ~= v.Default) and (string.sub(k, 1, 11) ~= "__Designer.") then
				v:Set(v.Default)
			end
		end
	end)
end
library.ResetAll = resetall
local textService = game:GetService("TextService")
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local LP = playersservice.LocalPlayer
library.LP = LP
library.Players = playersservice
library.UserInputService = userInputService
library.RunService = runService
local mouse = LP and LP:GetMouse()
if mouse then
elseif PluginManager and runService:IsStudio() then
	shared.library_plugin = shared.library_plugin or print("Creating Studio Test-Plugin...") or PluginManager():CreatePlugin()
	mouse = shared.library_plugin:GetMouse()
	library.plugin = shared.library_plugin
end
library.Mouse = mouse
local textToSize
do
	local textService = game:GetService("TextService")
	local bigv2 = Vector2.one * math.huge
	function textToSize(object)
		return textService:GetTextSize(object.Text, object.TextSize, object.Font, bigv2)
	end
	library.subs.textToSize = textToSize
end
local function removeSpaces(str)
	if str then
		return (str:gsub(" ", ""))
	end
end
library.subs.removeSpaces = removeSpaces
local function Color3FromHex(hex)
	hex = hex:gsub("#", ""):upper():gsub("0[Xx]", "")
	return Color3.fromRGB(tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16))
end
library.subs.Color3FromHex = Color3FromHex
local floor = math.floor
local function Color3ToHex(color)
	local r, g, b = string.format("%0.2X", floor(color.R * 255)), string.format("%0.2X", floor(color.G * 255)), string.format("%0.2X", floor(color.B * 255))
	if #r < 2 then
		r = "0" .. r
	end
	if #g < 2 then
		g = "0" .. g
	end
	if #b < 2 then
		b = "0" .. b
	end
	return string.format("%s%s%s", r, g, b)
end
library.subs.Color3ToHex = Color3ToHex
local UIT = Enum.UserInputType
local function isPress(input)
	local t = input.UserInputType
	return (t == UIT.MouseButton1) or (t == UIT.Touch)
end
local function isMove(input)
	local t = input.UserInputType
	return (t == UIT.MouseMovement) or (t == UIT.Touch)
end
local function getPointerPos(input)
	if input and (input.UserInputType == UIT.Touch) then
		return Vector2.new(input.Position.X, input.Position.Y)
	end
	return userInputService:GetMouseLocation()
end
local function lockScrolling(from, locked)
	pcall(function()
		local sf = from and from:FindFirstAncestorOfClass("ScrollingFrame")
		if sf then
			sf.ScrollingEnabled = not locked
		end
	end)
end
local function maxNotifWidth()
	local w = (MainScreenGui and MainScreenGui.AbsoluteSize.X) or 0
	if w < 100 then
		return 1e4
	end
	return math.max(140, w - 30)
end
local isDraggingSomething = false
local function clampedPosition(startPosition, delta)
	local x, y = startPosition.X.Offset + delta.X, startPosition.Y.Offset + delta.Y
	local gui = MainScreenGui
	local size = gui and gui.AbsoluteSize
	if size and (size.X > 0) and (size.Y > 0) then
		local baseX, baseY = startPosition.X.Scale * size.X, startPosition.Y.Scale * size.Y
		x = math.clamp(baseX + x, 0, size.X) - baseX
		y = math.clamp(baseY + y, 0, size.Y) - baseY
	end
	return UDim2.new(startPosition.X.Scale, x, startPosition.Y.Scale, y)
end
local function makeDraggable(topBarObject, object, touchHandle)
	local dragging, startPosition, dragStart, dragInput
	local function beginDrag(input)
		dragging = true
		dragStart = input.Position
		startPosition = object.Position
		if input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
		local endsig
		endsig = input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
				if endsig then
					endsig:Disconnect()
					endsig = nil
				end
			end
		end)
		library.signals[1 + #library.signals] = endsig
	end
	library.signals[1 + #library.signals] = topBarObject.InputBegan:Connect(function(input)
		local t = input.UserInputType
		if (t == Enum.UserInputType.MouseButton1) or ((t == Enum.UserInputType.Touch) and not touchHandle) then
			beginDrag(input)
		end
	end)
	if touchHandle then
		library.signals[1 + #library.signals] = touchHandle.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch then
				beginDrag(input)
			end
		end)
	end
	library.signals[1 + #library.signals] = topBarObject.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)
	library.signals[1 + #library.signals] = userInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			if not isDraggingSomething and library.configuration.smoothDragging then
				tweenService:Create(object, TweenInfo.new(0.25, library.configuration.easingStyle, library.configuration.easingDirection), {
					Position = clampedPosition(startPosition, delta)
				}):Play()
			elseif isDraggingSomething or library.configuration.smoothDragging then
			else
				object.Position = clampedPosition(startPosition, delta)
			end
		end
	end)
end
library.subs.makeDraggable = makeDraggable
local JSONEncode, JSONDecode
do
	local temp_http = game:FindService("HttpService") or game:GetService("HttpService")
	local httpservice = temp_http
	if cloneref and (type(cloneref) == "function") then
		httpservice, temp_http = cloneref(httpservice), nil
	end
	library.Http = httpservice
	local JSONEncodeFunc = httpservice.JSONEncode
	function JSONEncode(...)
		return pcall(JSONEncodeFunc, httpservice, ...)
	end
	library.JSONEncode = JSONEncode
	local JSONDecodeFunc = httpservice.JSONDecode
	function JSONDecode(...)
		return pcall(JSONDecodeFunc, httpservice, ...)
	end
	library.JSONDecode = JSONDecode
end
local convertfilename
do
	local string_gsub = string.gsub
	function convertfilename(str, default, replace)
		replace = replace or "_"
		local corrections = 0
		local predname = string_gsub(str, "%W", function(c)
			local byt = c:byte()
			if ((byt == 0) or (byt == 32) or (byt == 33) or (byt == 59) or (byt == 61) or ((byt >= 35) and (byt <= 41)) or ((byt >= 43) and (byt <= 57)) or ((byt >= 64) and (byt <= 123)) or ((byt >= 125) and (byt <= 127))) then
			else
				corrections = 1 + corrections
				return replace
			end
		end)
		return (default and (corrections == #predname) and tostring(default)) or predname
	end
	library.subs.ConvertFilename = convertfilename
end
local Vector2Half = Vector2.new(0.5, 0.5)
local UDim2ScaleHalf = UDim2.fromScale(0.5, 0.5)
local UDim2ScaleOne = UDim2.fromScale(1, 1)
do
	do
		local function NewOption(TextStr, Order, Parent)
			local Option = Instance_new("Frame")
			local BBorder = Instance_new("Frame")
			local Inner_2 = Instance_new("Frame")
			local Border_2 = Instance_new("Frame")
			local Text = Instance_new("TextLabel")
			local Button = Instance_new("TextButton")
			Option.AnchorPoint = Vector2.new(0, 0.5)
			Option.BackgroundColor3 = library.colors.background
			colored[1 + #colored] = {Option, "BackgroundColor3", "background"}
			Option.BorderColor3 = Color3.fromRGB(27, 27, 27)
			Option.LayoutOrder = Order or #Parent:GetChildren()
			Option.Name = "Option"
			Option.Position = UDim2.new(0, 5, 0.5, 0)
			Option.Size = UDim2.fromOffset(350, 25)
			BBorder.AnchorPoint = Vector2Half
			BBorder.BackgroundColor3 = library.colors.background
			colored[1 + #colored] = {BBorder, "BackgroundColor3", "background"}
			BBorder.BorderColor3 = Color3.fromRGB(50, 43, 50)
			BBorder.BorderMode = Enum.BorderMode.Inset
			BBorder.Name = "BBorder"
			BBorder.Parent = Option
			BBorder.Position = UDim2ScaleHalf
			BBorder.Size = UDim2ScaleOne
			Inner_2.AnchorPoint = Vector2Half
			Inner_2.BackgroundColor3 = library.colors.background
			colored[1 + #colored] = {Inner_2, "BackgroundColor3", "background"}
			Inner_2.BorderColor3 = Color3.fromRGB(27, 27, 27)
			Inner_2.Name = "Inner"
			Inner_2.Parent = Option
			Inner_2.Position = UDim2ScaleHalf
			Inner_2.Size = UDim2.new(1, -6, 1, -6)
			Border_2.AnchorPoint = Vector2Half
			Border_2.BackgroundColor3 = library.colors.background
			colored[1 + #colored] = {Border_2, "BackgroundColor3", "background"}
			Border_2.BorderColor3 = Color3.fromRGB(50, 43, 50)
			Border_2.BorderMode = Enum.BorderMode.Inset
			Border_2.Name = "Border"
			Border_2.Parent = Inner_2
			Border_2.Position = UDim2ScaleHalf
			Border_2.Size = UDim2ScaleOne
			Text.AnchorPoint = Vector2Half
			Text.BackgroundColor3 = WhiteColor3
			Text.BackgroundTransparency = 1
			Text.Font = Enum.Font.GothamBold
			Text.FontSize = Enum.FontSize.Size14
			Text.Name = "Text"
			Text.Parent = Border_2
			Text.Position = UDim2ScaleHalf
			Text.Size = UDim2ScaleOne
			Text.TextColor3 = library.colors.elementText
			colored[1 + #colored] = {Text, "TextColor3", "elementText"}
			Text.TextSize = 12
			Text.TextStrokeTransparency = 1
			Button.BackgroundColor3 = WhiteColor3
			Button.BackgroundTransparency = 1
			Button.BorderSizePixel = 0
			Button.Font = Enum.Font.SourceSans
			Button.FontSize = Enum.FontSize.Size14
			Button.Name = "Button"
			Button.Parent = Option
			Button.Size = UDim2ScaleOne
			Button.Text = ""
			Button.TextColor3 = Color3.fromRGB(0, 0, 0)
			Button.TextSize = 12
			Button.TextTransparency = 1
			Text.Text = TextStr
			local siz = textToSize(Text)
			Option.Size = UDim2.new(0, math.max(siz.X, 28) + 12, 0, 25)
			Option.Parent = Parent
			return Option, Button, Text
		end
		local function AddOption(OptionData, Key, OptionCount, Parent, Close, PromptEvent, KeepOpen)
			local Enabled = OptionData.Enabled
			if OptionData.Disabled then
				Enabled = false
			else
				Enabled = Enabled or (Enabled == nil)
			end
			local OptionText = OptionData.Text or OptionData.String or OptionData.Message or OptionData.Value or OptionData.Name or Key
			local Callback = OptionData.Callback or OptionData.OnPressed or OptionData.Function or nil
			local Order = tonumber(OptionData.Slot or OptionData.Order or OptionData.LayoutOrder or OptionData.Index or OptionCount)
			local OptionIns, OptionButton, OptionTxt = NewOption(tostring(OptionText), Order, Parent)
			local OptionObj = {
				Text = OptionText,
				Callback = Callback,
				ButtonObject = OptionIns,
				Pressed = OptionButton.MouseButton1Click,
				PressedRight = OptionButton.MouseButton2Click,
				Activated = OptionButton.Activated,
				TextButton = OptionButton,
				Order = Order,
				Enabled = Enabled
			}
			function OptionObj.Remove()
				do
					local Btn = OptionObj.ButtonObject
					if Btn then
						Btn:Destroy()
					end
				end
				for k in next, OptionObj do
					rawset(OptionObj, k, nil)
				end
				return true
			end
			local Proxy
			local function Clicked(f)
				return function(...)
					if f then
						task.spawn(f, ...)
					end
					PromptEvent:Fire(Key, OptionButton.Text, ...)
					if KeepOpen then
					else
						Close()
					end
				end
			end
			function OptionObj.Press(...)
				OptionObj.Update()
				Proxy = Proxy or Clicked(Callback)
				Proxy(...)
			end
			function OptionObj.Lock()
				OptionObj.Enabled = false
				OptionObj.Update()
			end
			function OptionObj.Unlock()
				OptionObj.Enabled = true
				OptionObj.Update()
			end
			function OptionObj.SetLocked(self, state)
				if type(self) == "boolean" then
					state = self
				end
				OptionObj.Enabled = state
				OptionObj.Update()
			end
			function OptionObj.SetCondition(self, Condition)
				if type(self) ~= "table" then
					Condition = self
				end
				OptionObj.Condition = Condition
				OptionObj.Update()
			end
			function OptionObj.Update()
				do
					local OptionText = OptionObj.Text or OptionData.Text or OptionData.String or OptionData.Message or OptionData.Value or OptionData.Name or OptionButton.Text or Key
					OptionButton.Text = tostring(OptionText)
				end
				OptionIns.LayoutOrder = tonumber(OptionObj.Order or OptionData.Slot or OptionData.Order or OptionData.LayoutOrder or OptionData.Index or OptionIns.LayoutOrder or OptionCount)
				do
					local Enabled = OptionData.Enabled
					local Cond = OptionObj.Condition
					if Cond then
						local x, e = pcall(Cond, OptionObj)
						if x then
							Enabled = e and true
						else
							warn(debug.traceback(string.format("Error in prompt-option %s's Condition function: %s", OptionButton.Text, e), 2))
						end
					else
						if OptionData.Disabled then
							Enabled = false
						else
							Enabled = (Enabled and true) or (Enabled == nil)
						end
					end
					local Proxy
					do
						local nCallback = (Enabled and (OptionData.Callback or OptionData.OnPressed or OptionData.Function)) or nil
						if Proxy and (Callback == nCallback) then
						else
							Callback = nCallback
							Proxy = Clicked(Callback)
							local newsig = (OptionObj.PressedConnection and OptionObj.PressedConnection:Disconnect() and nil) or (Callback and OptionObj.Pressed:Connect(Proxy)) or nil
							OptionObj.PressedConnection = newsig
							library.signals[1 + #library.signals] = newsig
						end
						local PC = OptionObj.PressedConnection
						if Enabled then
							if PC then
								if Callback then
								else
									OptionObj.PressedConnection = (PC:Disconnect() and nil) or nil
								end
							elseif Callback then
								Proxy = Proxy or Clicked(Callback)
								local newsig = OptionObj.Pressed:Connect(Proxy)
								OptionObj.PressedConnection = newsig
								library.signals[1 + #library.signals] = newsig
							end
						elseif PC then
							OptionObj.PressedConnection = (PC:Disconnect() and nil) or nil
						end
					end
					OptionObj.Enabled = Enabled
					OptionTxt.TextTransparency = (Enabled and 0) or 0.5
				end
				return OptionObj
			end
			OptionObj.Update()
			return OptionObj
		end
		local function SortByLayoutOrder(a, b)
			return a.Order < b.Order
		end
		local DefaultSelections = {
			Ok = true
		}
		function library.Prompt(self, PromptData, ...)
			if rawequal(self, library) then
			else
				PromptData, self = self, library
			end
			local PromptEvent = Instance_new("BindableEvent")
			local PromptObj = {
				OnSelect = PromptEvent.Event,
				Active = true,
				SelectedEvent = PromptEvent
			}
			local ChoicePopup = Instance_new("Frame")
			local Buttons = Instance_new("ScrollingFrame")
			local Title = Instance_new("TextLabel")
			local Description = Instance_new("TextLabel")
			local DoClose = PromptData.CloseButton
			DoClose = (DoClose == nil) or (DoClose == true) or DoClose or nil
			local Close = DoClose and Instance_new("ImageButton")
			do
				local Border = Instance_new("Frame")
				local Inner = Instance_new("Frame")
				local InnerBorder = Instance_new("Frame")
				local Bar = Instance_new("Frame")
				local Splitter = Instance_new("Frame")
				local ButtonBar = Instance_new("Frame")
				local UIListLayout = Instance_new("UIListLayout")
				ChoicePopup.AnchorPoint = Vector2Half
				ChoicePopup.BackgroundColor3 = library.colors.background
				colored[1 + #colored] = {ChoicePopup, "BackgroundColor3", "background"}
				ChoicePopup.BorderColor3 = library.colors.outerBorder
				colored[1 + #colored] = {ChoicePopup, "BorderColor3", "outerBorder"}
				ChoicePopup.Name = "ChoicePopup"
				ChoicePopup.Position = UDim2ScaleHalf
				ChoicePopup.Size = UDim2.new(0, 325, 0, 100)
				Border.AnchorPoint = Vector2Half
				Border.BackgroundColor3 = library.colors.background
				colored[1 + #colored] = {Border, "BackgroundColor3", "background"}
				Border.BorderColor3 = library.colors.innerBorder
				colored[1 + #colored] = {Border, "BorderColor3", "innerBorder"}
				Border.BorderMode = Enum.BorderMode.Inset
				Border.Name = "Border"
				Border.Parent = ChoicePopup
				Border.Position = UDim2ScaleHalf
				Border.Size = UDim2ScaleOne
				Inner.AnchorPoint = Vector2Half
				Inner.BackgroundColor3 = library.colors.background
				colored[1 + #colored] = {Inner, "BackgroundColor3", "background"}
				Inner.BorderColor3 = library.colors.outerBorder
				colored[1 + #colored] = {Inner, "BorderColor3", "outerBorder"}
				Inner.Name = "Inner"
				Inner.Parent = ChoicePopup
				Inner.Position = UDim2ScaleHalf
				Inner.Size = UDim2.new(1, -8, 1, -8)
				InnerBorder.AnchorPoint = Vector2Half
				InnerBorder.BackgroundColor3 = library.colors.background
				colored[1 + #colored] = {InnerBorder, "BackgroundColor3", "background"}
				InnerBorder.BorderColor3 = library.colors.innerBorder
				colored[1 + #colored] = {InnerBorder, "BorderColor3", "innerBorder"}
				InnerBorder.BorderMode = Enum.BorderMode.Inset
				InnerBorder.Name = "InnerBorder"
				InnerBorder.Parent = Inner
				InnerBorder.Position = UDim2ScaleHalf
				InnerBorder.Size = UDim2ScaleOne
				Bar.BackgroundColor3 = library.colors.main
				colored[1 + #colored] = {Bar, "BackgroundColor3", "main"}
				Bar.BorderSizePixel = 0
				Bar.Name = "Bar"
				Bar.Parent = InnerBorder
				Bar.Size = UDim2.new(1, 0, 0, 3)
				Splitter.AnchorPoint = Vector2.new(0, 1)
				Splitter.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
				Splitter.BorderSizePixel = 0
				Splitter.Name = "Splitter"
				Splitter.Parent = InnerBorder
				Splitter.Position = UDim2.new(0, 0, 1, -35)
				Splitter.Size = UDim2.new(1, 0, 0, 1)
				Title.BackgroundColor3 = WhiteColor3
				Title.BackgroundTransparency = 1
				Title.Font = Enum.Font.GothamBold
				Title.FontSize = Enum.FontSize.Size18
				Title.Parent = InnerBorder
				Title.Position = UDim2.new(0, 6, 0, 4)
				Title.Size = UDim2.new(0, 300, 0, 25)
				Title.TextColor3 = library.colors.elementText
				colored[1 + #colored] = {Title, "TextColor3", "elementText"}
				Title.TextSize = 15
				Title.TextStrokeTransparency = 1
				Title.TextXAlignment = Enum.TextXAlignment.Left
				Description.BackgroundColor3 = WhiteColor3
				Description.BackgroundTransparency = 1
				Description.Font = Enum.Font.GothamBold
				Description.FontSize = Enum.FontSize.Size14
				Description.Name = "Description"
				Description.Parent = InnerBorder
				Description.Position = UDim2.new(0, 6, 0, 25)
				Description.Size = UDim2.new(0, 300, 0, 25)
				Description.TextColor3 = library.colors.elementText
				colored[1 + #colored] = {Description, "TextColor3", "elementText"}
				Description.TextSize = 12
				Description.TextStrokeTransparency = 1
				Description.TextTruncate = Enum.TextTruncate.AtEnd
				Description.TextWrap = true
				Description.TextWrapped = true
				Description.TextXAlignment = Enum.TextXAlignment.Left
				if Close then
					Close.AnchorPoint = Vector2.xAxis
					Close.BackgroundColor3 = WhiteColor3
					Close.BackgroundTransparency = 1
					Close.Image = "http://www.roblox.com/asset/?id=9064270627"
					Close.ImageColor3 = library.colors.section
					colored[1 + #colored] = {Close, "ImageColor3", "section"}
					Close.Name = "Close"
					Close.Parent = InnerBorder
					Close.Position = UDim2.new(1, -9, 0, 11)
					Close.ScaleType = Enum.ScaleType.Fit
					Close.Size = UDim2.fromOffset(10, 10)
				end
				ButtonBar.AnchorPoint = Vector2.yAxis
				ButtonBar.BackgroundColor3 = library.colors.sectionBackground
				colored[1 + #colored] = {ButtonBar, "BackgroundColor3", "sectionBackground"}
				ButtonBar.BorderSizePixel = 0
				ButtonBar.Name = "ButtonBar"
				ButtonBar.Parent = InnerBorder
				ButtonBar.Position = UDim2.new(0, 0, 1, 0)
				ButtonBar.Size = UDim2.new(1, 0, 0, 35)
				Buttons.AutomaticCanvasSize = Enum.AutomaticSize.X
				Buttons.BackgroundColor3 = library.colors.sectionBackground
				colored[1 + #colored] = {Buttons, "BackgroundColor3", "sectionBackground"}
				Buttons.BorderColor3 = library.colors.background
				colored[1 + #colored] = {Buttons, "BorderColor3", "background"}
				Buttons.BorderSizePixel = 0
				Buttons.BottomImage = ""
				Buttons.CanvasSize = UDim2.new(0, 0, 0, 0)
				Buttons.MidImage = ""
				Buttons.Name = "Buttons"
				Buttons.Parent = ButtonBar
				Buttons.Position = UDim2.new(0, 6, 0, 0)
				Buttons.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
				Buttons.ScrollBarImageTransparency = 1
				Buttons.ScrollBarThickness = 0
				Buttons.ScrollingDirection = Enum.ScrollingDirection.X
				Buttons.Selectable = false
				Buttons.Size = UDim2.new(1, -12, 1, 0)
				Buttons.TopImage = ""
				UIListLayout.FillDirection = Enum.FillDirection.Horizontal
				UIListLayout.Padding = UDim.new(0, 10)
				UIListLayout.Parent = Buttons
				UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
				UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			end
			PromptObj.FrameInstance = ChoicePopup
			PromptObj.Closed = ChoicePopup.Destroying
			local function ClosePrompt(method)
				PromptObj.Active = (ChoicePopup and ChoicePopup:Destroy() and nil) or (PromptEvent:Fire("Close", method and (method == "timeout_")) and nil) or nil
			end
			PromptObj.Close = ClosePrompt
			if Close then
				library.signals[1 + #library.signals] = Close.MouseButton1Click:Connect(((DoClose ~= true) and DoClose) or ClosePrompt)
			end
			do
				local NameTxt = PromptData.Name
				Title.Text = ((NameTxt ~= nil) and tostring(NameTxt)) or "Untitled Prompt"
			end
			do
				local DescriptionTxt = PromptData.Description
				if DescriptionTxt == nil then
					DescriptionTxt = PromptData.Text
					if DescriptionTxt == nil then
						DescriptionTxt = PromptData.String
						if DescriptionTxt == nil then
							DescriptionTxt = PromptData.Message
							if DescriptionTxt == nil then
								DescriptionTxt = PromptData.Value
							end
						end
					end
				end
				Description.Text = ((DescriptionTxt ~= nil) and tostring(DescriptionTxt)) or ""
			end
			do
				local Selections = PromptData.Options or PromptData.Buttons or PromptData.Choices
				if Selections then
					if type(Selections) ~= "table" then
						Selections = {
							OK = Selections
						}
					end
				else
					Selections = DefaultSelections
				end
				local OptionCount = 0
				local ButtonsProxy = {}
				PromptObj.Buttons = ButtonsProxy
				function PromptObj.ReOrder(self, SortFunc)
					if self ~= ButtonsProxy then
						SortFunc, self = self, nil
					end
					if SortFunc and (type(SortFunc) ~= "function") then
						SortFunc = SortByLayoutOrder
					end
					local BtnOrder = {}
					for _, Data in next, ButtonsProxy do
						BtnOrder[1 + #BtnOrder] = Data
					end
					table.sort(BtnOrder, SortFunc or SortByLayoutOrder)
					for Order, Data in next, BtnOrder do
						Data.Order = Order or Data.Order
						local UpdateFunc = Data.Update
						if UpdateFunc then
							spawn(UpdateFunc)
						else
							local Frame = Data.ButtonObject
							if Frame then
								Frame.LayoutOrder = Order
							end
						end
					end
					return ButtonsProxy
				end
				function PromptObj.PressAll(self, ...)
					local isSelf
					if self and rawequal(self, PromptObj) then
						isSelf = true
					end
					for _, Data in next, ButtonsProxy do
						local f = Data.Callback
						if f then
							if isSelf then
								f(...)
							else
								f(self, ...)
							end
						end
					end
				end
				local KeepOpen = PromptData.KeepOpen
				for Key, OptionData in next, Selections do
					OptionCount += 1
					do
						local typ = OptionData and type(OptionData)
						if typ ~= "table" then
							OptionData = {
								Name = ((typ == "string") and (type(Key) == "number") and OptionData) or Key,
								Callback = ((typ == "function") and OptionData) or ClosePrompt
							}
						end
					end
					ButtonsProxy[Key] = AddOption(OptionData, Key, OptionCount, Buttons, ClosePrompt, PromptEvent, KeepOpen)
				end
			end
			do
				local to = PromptData.Timeout
				to = to and tonumber(to)
				if to then
					task.delay(to, ClosePrompt, "timeout_")
				end
			end
			ChoicePopup.Parent = MainScreenGui
			makeDraggable(ChoicePopup, ChoicePopup)
			return PromptObj, ChoicePopup
		end
	end
	do
		local Popups = Instance_new("Frame")
		local UIListLayout = Instance_new("UIListLayout")
		library.NotifyLayout = UIListLayout
		Popups.BackgroundColor3 = WhiteColor3
		Popups.BackgroundTransparency = 1
		Popups.Name = "Popups"
		Popups.Position = UDim2.fromOffset(10, 10)
		Popups.Size = UDim2.new(1, -20, 1, -20)
		UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
		UIListLayout.Padding = UDim.new(0, 5)
		UIListLayout.Parent = Popups
		UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
		Popups.Parent = MainScreenGui
		library.NotificationsFrame = Popups
		local Inverse = true
		local os_clock = os.clock
		local Notifications = {}
		library.Notifications = Notifications
		spawn(function()
			local v1, vtop, htop = Enum.FillDirection.Vertical, Enum.VerticalAlignment.Top, Enum.HorizontalAlignment.Center
			while wait_check() do
				local Len = #Notifications
				while wait_check() and (Len <= 0) do
					Len = #Notifications
					if wait_check(0.25) then
					else
						return
					end
				end
				Inverse = ((UIListLayout.FillDirection == v1) and (UIListLayout.VerticalAlignment ~= vtop)) or (UIListLayout.HorizontalAlignment ~= htop)
				local BreathingRoom, now = 10, os_clock()
				local Order = 0
				for Index = Len, 1, -1 do
					BreathingRoom -= 1
					if BreathingRoom <= 0 then
						if wait_check() then
							BreathingRoom, now = 10, os_clock()
						else
							return
						end
					end
					local Noti = Notifications[Index]
					local Obj = Noti and Noti.Object
					if Obj and Noti.Active and (Noti.Paused or ((now - Noti.Expires) < Noti.Duration)) then
						if Noti.TextLabel.Text ~= Noti.Text then
							Noti:SetText(Noti.Text)
						end
						if Obj.Visible then
							Order += 1
							Obj.LayoutOrder = Order * ((Inverse and -1) or 1)
						end
						continue
					end
					Noti.Object = ((Noti.Object and Noti.Object:Destroy()) and nil) or (Noti.Destroy() and nil) or (table.remove(Notifications, Index) and nil) or nil
				end
			end
		end)
		function library.Notify(self, NotificationData, ...)
			if rawequal(self, library) then
			else
				NotificationData, self = self, library
			end
			local now = os_clock()
			local dur = NotificationData.Time or 6
			local TextStr = NotificationData.Text or NotificationData.String or NotificationData.Value or NotificationData.Message or NotificationData.Msg
			TextStr = ((TextStr == nil) and "No text given") or tostring(TextStr)
			local NotificationObj = {
				InitTime = now,
				Active = true,
				Forced = false,
				Duration = dur,
				Expires = now + dur,
				Paused = (NotificationData.Paused and true) or false,
				Text = TextStr,
				Arguments = NotificationData
			}
			NotificationObj.Forced = NotificationObj.Paused
			local Notification = Instance_new("Frame")
			NotificationObj.Object = Notification
			local Border = Instance_new("Frame")
			local Inner = Instance_new("Frame")
			local Border_2 = Instance_new("Frame")
			local Text = Instance_new("TextLabel")
			NotificationObj.TextLabel = Text
			local Bar = Instance_new("Frame")
			local Close = Instance_new("ImageButton")
			Notification.AnchorPoint = Vector2.one
			Notification.BackgroundColor3 = library.colors.background
			colored[1 + #colored] = {Notification, "BackgroundColor3", "background"}
			Notification.BorderColor3 = library.colors.outerBorder
			colored[1 + #colored] = {Notification, "BorderColor3", "outerBorder"}
			Notification.Name = "Notification"
			Notification.Position = UDim2.new(1, -10, 1, -10)
			Notification.Size = UDim2.new(0, 5e4, 0, 32)
			Border.AnchorPoint = Vector2Half
			Border.BackgroundColor3 = library.colors.background
			colored[1 + #colored] = {Border, "BackgroundColor3", "background"}
			Border.BorderColor3 = library.colors.innerBorder
			colored[1 + #colored] = {Border, "BorderColor3", "innerBorder"}
			Border.BorderMode = Enum.BorderMode.Inset
			Border.Name = "Border"
			Border.Parent = Notification
			Border.Position = UDim2ScaleHalf
			Border.Size = UDim2ScaleOne
			Inner.AnchorPoint = Vector2.one / 2
			Inner.BackgroundColor3 = library.colors.background
			colored[1 + #colored] = {Inner, "BackgroundColor3", "background"}
			Inner.BorderColor3 = library.colors.outerBorder
			colored[1 + #colored] = {Inner, "BorderColor3", "outerBorder"}
			Inner.Name = "Inner"
			Inner.Parent = Notification
			Inner.Position = UDim2ScaleHalf
			Inner.Size = UDim2.new(1, -8, 1, -8)
			Border_2.AnchorPoint = Vector2.one / 2
			Border_2.BackgroundColor3 = library.colors.background
			colored[1 + #colored] = {Border_2, "BackgroundColor3", "background"}
			Border_2.BorderColor3 = library.colors.innerBorder
			colored[1 + #colored] = {Border_2, "BorderColor3", "innerBorder"}
			Border_2.BorderMode = Enum.BorderMode.Inset
			Border_2.Name = "Border"
			Border_2.Parent = Inner
			Border_2.Position = UDim2ScaleHalf
			Border_2.Size = UDim2ScaleOne
			for _, f in next, {Border, Inner, Border_2} do
				f.BackgroundTransparency = 1
				f.BorderSizePixel = 0
			end
			Notification.BorderSizePixel = 0
			local NotifCorner = Instance_new("UICorner")
			NotifCorner.CornerRadius = UDim.new(0, 8)
			NotifCorner.Parent = Notification
			local NotifStroke = Instance_new("UIStroke")
			NotifStroke.Color = library.colors.innerBorder
			colored[1 + #colored] = {NotifStroke, "Color", "innerBorder"}
			NotifStroke.Thickness = 1
			NotifStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			NotifStroke.Parent = Notification
			Text.AnchorPoint = Vector2.new(0, 0.5)
			Text.BackgroundTransparency = 1
			Text.Font = Enum.Font.GothamBold
			Text.FontSize = Enum.FontSize.Size14
			Text.Name = "Text"
			Text.Parent = Border_2
			Text.Position = UDim2.new(0, 14, 0.5, 0)
			Text.Size = UDim2.new(1, -40, 1, -7)
			Text.Text = TextStr
			Text.TextColor3 = library.colors.elementText
			colored[1 + #colored] = {Text, "TextColor3", "elementText"}
			Text.TextScaled = false
			Text.TextSize = 12
			Text.TextStrokeTransparency = 1
			Text.TextWrap = true
			Text.TextWrapped = true
			Text.TextXAlignment = Enum.TextXAlignment.Left
			Bar.BackgroundColor3 = library.colors.main
			colored[1 + #colored] = {Bar, "BackgroundColor3", "main"}
			Bar.BorderSizePixel = 0
			Bar.Name = "Bar"
			Bar.Parent = Border_2
			Bar.AnchorPoint = Vector2.new(0, 0.5)
			Bar.Position = UDim2.new(0, 4, 0.5, 0)
			Bar.Size = UDim2.new(0, 3, 1, -8)
			local BarCorner = Instance_new("UICorner")
			BarCorner.CornerRadius = UDim.new(1, 0)
			BarCorner.Parent = Bar
			Close.AnchorPoint = Vector2.new(1, 0.5)
			Close.BackgroundTransparency = 1
			Close.Image = "rbxassetid://5492252477"
			Close.ImageColor3 = library.colors.elementText
			colored[1 + #colored] = {Close, "ImageColor3", "elementText"}
			Close.Name = "Close"
			Close.Parent = Border_2
			Close.Position = UDim2.new(1, -6, 0.5, 0)
			Close.ScaleType = Enum.ScaleType.Fit
			Close.Size = UDim2.fromOffset(10, 10)
			Notification.Size = UDim2.new(0, math.min(64 + textToSize(Text).X, maxNotifWidth()), 0, 32)
			Notification.Parent = Popups
			Notification.LayoutOrder = #Notification.Parent:GetChildren() * ((Inverse and 1) or -1)
			if Popups.Parent then
			else
				Popups.Parent = MainScreenGui
			end
			NotificationObj.OnClose = Close.Activated
			NotificationObj.InputBegan = Notification.InputBegan
			NotificationObj.Destroying = Notification.Destroying
			NotificationObj.MouseEnter = Notification.MouseEnter
			NotificationObj.MouseLeave = Notification.MouseLeave
			function NotificationObj.SetText(self, Str)
				if rawequal(self, NotificationObj) then
				else
					Str = self
				end
				Str = ((Str == nil) and "No text given") or tostring(Str)
				Text.Text, NotificationObj.Text = Str, Str
				Notification.Size = UDim2.new(0, math.min(44 + Text.TextBounds.X, maxNotifWidth()), 0, 32)
				return Str, Text
			end
			local function Pause(self, Set, NoForce)
				if rawequal(self, NotificationObj) then
				else
					Set, NoForce = self, Set
				end
				local IsPaused = NotificationObj.Paused
				if Set == nil then
					Set = not IsPaused
				else
					Set = Set or false
				end
				if Set or (IsPaused == Set) then
				else
					NotificationObj.Expires = math.max(NotificationObj.Expires, os_clock() + math.clamp(NotificationObj.Duration / 2.5, 1, 3))
				end
				NotificationObj.Paused = Set
				if NoForce then
				else
					NotificationObj.Forced = Set
				end
				return Set
			end
			NotificationObj.SetPaused = Pause
			function NotificationObj.AddTime(self, Extension)
				if rawequal(self, NotificationObj) then
				else
					Extension = self
				end
				NotificationObj.Expires += Extension
			end
			function NotificationObj.Hide(self, SetPause)
				if Notification and NotificationObj.Active then
					if rawequal(self, NotificationObj) then
					else
						SetPause = self
					end
					if SetPause then
						Pause(true)
					end
					Notification.Visible = false
				end
			end
			function NotificationObj.Show(self, SetPause)
				if Notification and NotificationObj.Active then
					if rawequal(self, NotificationObj) then
					else
						SetPause = self
					end
					if SetPause then
						Pause(false)
					end
					Notification.Visible = true
				end
			end
			function NotificationObj.SetVisible(self, Visible, SetPause)
				if Notification and NotificationObj.Active then
					if rawequal(self, NotificationObj) then
					else
						Visible, SetPause = self, Visible
					end
					if Visible == nil then
						Notification.Visible = not Notification.Visible
					else
						Notification.Visible = (Visible and true) or false
					end
					if SetPause then
						Pause(Notification.Visible)
					end
				end
			end
			library.signals[1 + #library.signals] = Notification.MouseEnter:Connect(function()
				if NotificationObj.Forced then
					return
				end
				Pause(true, true)
			end)
			library.signals[1 + #library.signals] = Notification.MouseLeave:Connect(function()
				if NotificationObj.Forced then
					return
				end
				Pause(false, true)
			end)
			local function Destroy()
				if Notification then
					Notification:Destroy()
				end
				NotificationObj.Active = false
				NotificationObj.Object = nil
			end
			NotificationObj.Destroy = Destroy
			library.signals[1 + #library.signals] = Close.Activated:Connect(Destroy)
			Notifications[1 + #Notifications] = NotificationObj
			return NotificationObj, Notification, Text
		end
	end
end
library.ToggleStyle = "Pill"
library.toggleRestylers = {}
-- Square is the original look; every other name below is an alternative toggle shape
library.ToggleStyleConfigs = {
	Pill = {w = 38, h = 20, mode = "alpha"},
	Capsule = {w = 48, h = 14, mode = "width"},
	Circle = {w = 20, h = 20, mode = "center"},
	Diamond = {w = 16, h = 16, mode = "center", rot = 45, corner = 3, fcorner = 2}
}
function library.SetToggleStyle(name)
	if type(name) ~= "string" then
		return library.ToggleStyle
	end
	name = name:gsub("%s*%(.-%)%s*$", "")
	if (name ~= "Square") and not library.ToggleStyleConfigs[name] then
		name = "Square"
	end
	library.ToggleStyle = name
	for _, f in ipairs(library.toggleRestylers or {}) do
		pcall(f)
	end
	return name
end
-- =====================================================================
--  QuickX Icon Engine
--  Icons are drawn from Frames (no asset ids, no uploads) and follow the theme colors.
--    CreateTab({Name = "Farm", Icon = "sprout"})          icon + text
--    CreateTab({Name = "Farm", Icon = "sprout", IconOnly = true})
--    CreateTab("Farm", "sprout")                          short form
--    library:CreateIcon(parent, "sword", {Size = 18})     use an icon anywhere
--    library:AddIcon("logo", 132029940467197, "brand")    add your own (asset id) + aliases
--    library:GetIcons()                                   list every icon name
-- =====================================================================
do
	local ICON_DATA = {
		["alert"] = "q12 3.8 21.4 20 2.6 20;p12 9.5 12 14;C12 16.9 1.1",
		["arrowdown"] = "p12 4.5 12 19.5;p18 13.5 12 19.5 6 13.5",
		["arrowleft"] = "p19.5 12 4.5 12;p10.5 6 4.5 12 10.5 18",
		["arrowright"] = "p4.5 12 19.5 12;p13.5 6 19.5 12 13.5 18",
		["arrowup"] = "p12 19.5 12 4.5;p6 10.5 12 4.5 18 10.5",
		["bag"] = "r4.5 8 15 13 3 0;p8.4 8.2 8.9 6.4 10.2 5.1 12 4.6 13.8 5.1 15.1 6.4 15.6 8.2",
		["bell"] = "q6 16.5 6.8 15.3 7.3 13.8 7.5 12.1 7.5 10 7.8 7.8 8.8 6 10.2 4.9 12 4.5 13.8 4.9 15.2 6 16.2 7.8 16.5 10 16.5 12.1 16.7 13.8 17.2 15.3 18 16.5;p4.5 17 19.5 17;p14.3 18.3 13.4 19.5 12 19.9 10.6 19.5 9.7 18.3;p12 2.8 12 4.5",
		["bomb"] = "c10.5 13.6 7.2;p15.6 8.4 18.6 5.4;p19.8 2.6 19.8 5.6;p18.3 4.1 21.3 4.1;p6.7 12.6 7.1 11.6 7.7 10.8 8.5 10.2 9.5 9.8",
		["book"] = "r5 3.5 14 17.5 2.5 0;p9 3.5 9 21;p12.5 8 16 8;p12.5 11.4 16 11.4",
		["bookmark"] = "q6.5 3.5 6.5 20.5 12 16 17.5 20.5 17.5 3.5",
		["bug"] = "r8 8 8 12.5 4 0;c12 6.2 2.2;p8 11.5 4.5 9.8;p8 15 4 15;p8.4 18.6 5.2 20.6;p16 11.5 19.5 9.8;p16 15 20 15;p15.6 18.6 18.8 20.6;p12 10 12 19",
		["bulb"] = "p8.1 14.4 6.7 13 5.9 11.2 5.6 9.3 5.9 7.3 6.9 5.6 8.3 4.2 10 3.3 12 3 14 3.3 15.7 4.2 17.1 5.6 18.1 7.3 18.4 9.3 18.1 11.2 17.3 13 15.9 14.4;p16.6 13.9 15 16.8 15 17.8 9 17.8 9 16.8 7.4 13.9;p9.6 20.6 14.4 20.6",
		["calendar"] = "r3.5 5 17 15.5 3 0;p3.5 10 20.5 10;p8 3 8 6.8;p16 3 16 6.8;C8.5 14.3 0.9;C12 14.3 0.9;C15.5 14.3 0.9",
		["camera"] = "r2.5 7 19 13 3.4 0;p8.4 7 9.8 4.4 14.2 4.4 15.6 7;c12 13.5 3.8",
		["cart"] = "p2.5 4.5 5 4.5 7.9 15.5 18.6 15.5 20.6 8 5.9 8;C9.6 19.4 1.6;C16.6 19.4 1.6",
		["chart"] = "B4.5 11 4 9.5 1.1 0;B10 4.5 4 16 1.1 0;B15.5 8 4 12.5 1.1 0",
		["chat"] = "q6 4 18 4 19.2 4.2 20.1 4.9 20.8 5.8 21 7 21 14 20.8 15.2 20.1 16.1 19.2 16.8 18 17 12.5 17 8 21 8 17 6 17 4.8 16.8 3.9 16.1 3.2 15.2 3 14 3 7 3.2 5.8 3.9 4.9 4.8 4.2 6 4;p7.5 9 16.5 9;p7.5 12.4 13 12.4",
		["check"] = "p4.5 12.5 9.5 17.5 19.5 6.5",
		["chevrondown"] = "p18.5 9 12 15.5 5.5 9",
		["chevronleft"] = "p15 5.5 8.5 12 15 18.5",
		["chevronright"] = "p9 5.5 15.5 12 9 18.5",
		["chevronup"] = "p5.5 15 12 8.5 18.5 15",
		["clock"] = "c12 12 9;p12 6.5 12 12 15.8 14.4",
		["close"] = "p5.5 5.5 18.5 18.5;p18.5 5.5 5.5 18.5",
		["cloud"] = "q7 19 5.1 18.7 3.7 17.9 2.8 16.6 2.5 15 2.8 13.5 3.6 12.3 4.9 11.4 6.4 11.1 7 9.3 8 7.7 9.3 6.5 11 5.8 12.8 5.5 14.6 5.8 16.2 6.5 17.4 7.6 18.3 9 18.8 10.6 20 11.1 20.9 12 21.3 13.2 21.5 14.6 21.2 16.4 20.2 17.8 18.9 18.7 17.2 19",
		["code"] = "p8.2 6.5 2.8 12 8.2 17.5;p15.8 6.5 21.2 12 15.8 17.5;p13.5 4.5 10.5 19.5",
		["coin"] = "c12 12 9;c12 12 5.3;C12 12 1.2",
		["compass"] = "c12 12 9;q15.6 8.4 13.2 13.2 8.4 15.6 10.8 10.8",
		["controller"] = "r2.5 7 19 10.5 5.2 0;p7 10.4 7 14.2;p5.1 12.3 8.9 12.3;C15.8 11.2 1.1;C18.2 13.4 1.1",
		["copy"] = "r9 9 11.5 12 2.5 0;p14.8 5 7.5 5 5 7.5 5 14.5",
		["cpu"] = "r6.5 6.5 11 11 2.2 0;r10 10 4 4 1 0;p9.8 3 9.8 6.5;p14.2 3 14.2 6.5;p9.8 17.5 9.8 21;p14.2 17.5 14.2 21;p3 9.8 6.5 9.8;p3 14.2 6.5 14.2;p17.5 9.8 21 9.8;p17.5 14.2 21 14.2",
		["crown"] = "q3.5 18.5 3.5 8 8.5 12.5 12 5 15.5 12.5 20.5 8 20.5 18.5;p3.5 21 20.5 21",
		["cube"] = "q12 2.5 20.5 7.2 20.5 16.8 12 21.5 3.5 16.8 3.5 7.2;p3.8 7.4 12 12 20.2 7.4;p12 12 12 21.3",
		["cursor"] = "q5 3.5 19.5 10.4 12.3 12.5 10.2 19.8",
		["database"] = "q4.5 6.5 4.9 5.6 6.1 4.8 7.7 4.3 9.8 4 12 3.9 14.2 4 16.3 4.3 17.9 4.8 19.1 5.6 19.5 6.5 19.1 7.4 17.9 8.2 16.3 8.7 14.2 9 12 9.1 9.8 9 7.7 8.7 6.1 8.2 4.9 7.4 4.5 6.5;p4.5 6.5 4.5 17.5;p19.5 6.5 19.5 17.5;p4.5 12 4.9 12.9 6.1 13.6 7.7 14.1 9.8 14.4 12 14.6 14.2 14.4 16.3 14.1 17.9 13.6 19.1 12.9 19.5 12;p4.5 17.5 4.9 18.4 6.1 19.2 7.7 19.7 9.8 20 12 20.1 14.2 20 16.3 19.7 17.9 19.2 19.1 18.4 19.5 17.5",
		["dice"] = "r4 4 16 16 3.6 0;C8.6 8.6 1.4;C15.4 8.6 1.4;C12 12 1.4;C8.6 15.4 1.4;C15.4 15.4 1.4",
		["download"] = "p12 4 12 15;p7 10.8 12 15.8 17 10.8;p4.5 16.5 4.5 20 19.5 20 19.5 16.5",
		["drop"] = "q12 3 13.3 4.7 14.6 6.3 15.8 7.9 16.9 9.6 17.7 11.2 18.3 12.8 18.5 14.5 18.2 16.3 17.5 18 16.3 19.4 14.7 20.4 12.9 20.9 11.1 20.9 9.3 20.4 7.7 19.4 6.5 18 5.8 16.3 5.5 14.5 5.7 12.8 6.3 11.2 7.1 9.6 8.2 7.9 9.4 6.3 10.7 4.7 12 3;p15.4 15.7 14.8 16.8 13.9 17.5 12.9 18 11.7 18.1",
		["edit"] = "q4 20 4.6 15.4 15.6 4.4 19.6 8.4 8.6 19.4;p12.6 7.4 16.6 11.4",
		["egg"] = "q12 3 13.6 3.3 15.1 4.2 16.4 5.6 17.4 7.2 18.3 9.1 19 11 19.4 12.9 19.5 14.5 19.2 16.4 18.5 18.1 17.3 19.5 15.8 20.6 14 21.3 12 21.5 10 21.3 8.2 20.6 6.7 19.5 5.5 18.1 4.8 16.4 4.5 14.5 4.6 12.9 5 11 5.7 9.1 6.6 7.2 7.6 5.6 8.9 4.2 10.4 3.3 12 3;C9.3 13.3 1.2;C14.4 10.8 1.1;C14.7 16 1.4",
		["eye"] = "q2 12 3.2 10.5 4.6 9.3 6.2 8.3 8.1 7.7 10 7.3 12 7.1 14 7.3 15.9 7.7 17.8 8.3 19.4 9.3 20.8 10.5 22 12 20.8 13.5 19.4 14.7 17.8 15.7 15.9 16.3 14 16.7 12 16.9 10 16.7 8.1 16.3 6.2 15.7 4.6 14.7 3.2 13.5 2 12;c12 12 3.1",
		["eyeoff"] = "q2 12 3.2 10.5 4.6 9.3 6.2 8.3 8.1 7.7 10 7.3 12 7.1 14 7.3 15.9 7.7 17.8 8.3 19.4 9.3 20.8 10.5 22 12 20.8 13.5 19.4 14.7 17.8 15.7 15.9 16.3 14 16.7 12 16.9 10 16.7 8.1 16.3 6.2 15.7 4.6 14.7 3.2 13.5 2 12;c12 12 3.1;p3.5 3.5 20.5 20.5",
		["file"] = "q6.5 3 14 3 19 8 19 19.5 18.9 20.1 18.6 20.6 18.1 20.9 17.5 21 6.5 21 5.9 20.9 5.5 20.6 5.1 20.1 5 19.5 5 4.5 5.1 3.9 5.5 3.5 5.9 3.1 6.5 3;p14 3.2 14 8 18.8 8;p8.5 13 15.5 13;p8.5 16.8 15.5 16.8",
		["filter"] = "q3.5 5 20.5 5 14 12.4 14 19 10 17 10 12.4",
		["fish"] = "q3 12 4.4 10.2 5.9 8.9 7.5 8 9.2 7.6 10.8 7.6 12.5 8 14.1 8.9 15.6 10.2 17 12 15.6 13.8 14.1 15.1 12.5 16 10.8 16.4 9.2 16.4 7.5 16 5.9 15.1 4.4 13.8 3 12;q17 12 21.5 7.6 21.5 16.4;C7.6 11 1.1",
		["flag"] = "p5.5 3.5 5.5 21;p5.5 4.5 19 4.5 16 9 19 13.5 5.5 13.5",
		["flame"] = "q12 2.8 12.7 4.1 13.7 5.5 15 6.9 16.3 8.4 17.4 10.1 18.2 12.1 18.5 14.5 18.3 16.4 17.6 18.1 16.6 19.5 15.3 20.6 13.8 21.3 12 21.5 10.2 21.3 8.7 20.6 7.4 19.5 6.4 18.1 5.7 16.4 5.5 14.5 5.7 12.9 6.1 11.4 6.8 10.1 7.7 9 8.2 10.3 8.8 11.3 9.6 12 10.6 12.4 10.5 10.2 10.5 8.1 10.8 6.2 11.3 4.4 12 2.8;q12 21.5 10.8 21.3 9.8 20.6 9.2 19.7 9 18.6 9.2 17.5 9.9 16.4 10.9 15.3 12 14.2 13.1 15.3 14.1 16.4 14.8 17.5 15 18.6 14.8 19.7 14.2 20.6 13.2 21.3 12 21.5",
		["folder"] = "q3 7 3.2 6.2 3.6 5.6 4.2 5.2 5 5 9 5 11.5 7.5 19 7.5 19.8 7.7 20.4 8.1 20.8 8.7 21 9.5 21 17.5 20.8 18.3 20.4 18.9 19.8 19.3 19 19.5 5 19.5 4.2 19.3 3.6 18.9 3.2 18.3 3 17.5",
		["gem"] = "q7 4 17 4 21.5 9.5 12 21 2.5 9.5;p2.5 9.5 21.5 9.5;p8.6 9.5 12 21 15.4 9.5;p9.8 4 8.6 9.5;p14.2 4 15.4 9.5",
		["ghost"] = "p4.5 10 4.8 8.1 5.5 6.2 6.7 4.7 8.2 3.5 10.1 2.8 12 2.5 13.9 2.8 15.8 3.5 17.3 4.7 18.5 6.2 19.2 8.1 19.5 10;p4.5 10 4.5 20.5 8.2 17.6 12 20.5 15.8 17.6 19.5 20.5 19.5 10;C9.2 10.4 1.3;C14.8 10.4 1.3",
		["gift"] = "r4.5 12 15 8.5 2 0;r3 8 18 4 1.6 0;p12 8 12 20.5;p12 8 10.2 7.8 8.6 7.2 7.4 6.2 7 5 7.2 4.1 7.7 3.5 8.4 3.2 9.2 3.3 10.4 4 11.3 5.1 11.8 6.5 12 8;p12 8 13.8 7.8 15.4 7.2 16.6 6.2 17 5 16.8 4.1 16.3 3.5 15.6 3.2 14.8 3.3 13.6 4 12.7 5.1 12.2 6.5 12 8",
		["globe"] = "c12 12 9;r7.5 3 9 18 4.5 0;p3 12 21 12",
		["grid"] = "r3.8 3.8 6.8 6.8 2 0;r13.4 3.8 6.8 6.8 2 0;r3.8 13.4 6.8 6.8 2 0;r13.4 13.4 6.8 6.8 2 0",
		["hammer"] = "B9.7 4.9 12 5.4 1.6 40;p13.9 9.7 6.5 18.5 w2.8",
		["heart"] = "C8.7 10.3 4.5;C15.3 10.3 4.5;B7.5 9 9 9 0.5 45",
		["home"] = "p3 11.5 12 3.5 21 11.5;p5.5 10 5.5 20.5 18.5 20.5 18.5 10;p10 20.5 10 15 14 15 14 20.5",
		["image"] = "r3.5 4.5 17 15 3.2 0;C8.6 9.6 1.7;p3.8 17 9 12.2 14 16.4 17 13.8 20.2 17",
		["info"] = "c12 12 9;p12 11 12 16.8;C12 7.7 1.2",
		["key"] = "c7.8 16.2 4.4;p11.1 13 20.5 3.6;p16.4 7.8 19.2 10.6;p18 6.2 20.2 8.4",
		["layers"] = "q12 3.5 21 8.5 12 13.5 3 8.5;p3 12.5 12 17.5 21 12.5;p3 16.5 12 21.5 21 16.5",
		["leaf"] = "q4 20 4.1 17.4 4.6 15 5.2 12.9 6.1 11 7.3 9.3 8.6 7.9 10.2 6.7 11.9 5.7 13.7 5 15.7 4.4 17.8 4.1 20 4 19.9 6.2 19.6 8.3 19 10.3 18.3 12.1 17.3 13.8 16.1 15.4 14.7 16.7 13 17.9 11.1 18.8 9 19.4 6.6 19.9 4 20;p4 20 13 11",
		["link"] = "r2.5 13.4 11.5 5.4 2.7 -45;r9.5 5.6 11.5 5.4 2.7 -45;p9.2 14.8 14.8 9.2",
		["list"] = "C5 6.5 1.2;p9 6.5 20 6.5;C5 12 1.2;p9 12 20 12;C5 17.5 1.2;p9 17.5 20 17.5",
		["lock"] = "r5 11 14 10 2.5 0;p7.8 11 7.8 8;p7.8 8 8.2 6.2 9.4 4.7 11.1 3.9 12.9 3.9 14.6 4.7 15.8 6.2 16.2 8;p16.2 8 16.2 11;C12 15.2 1.5;p12 15.2 12 18",
		["logout"] = "p9.5 4 5.5 4 4.5 5 4.5 19 5.5 20 9.5 20;p10 12 20 12;p16 8 20 12 16 16",
		["magnet"] = "p5 4 5 12;p19 4 19 12;p5 12 5.3 14 6.1 15.8 7.4 17.3 9.1 18.4 11 18.9 13 18.9 14.9 18.4 16.6 17.3 17.9 15.8 18.7 14 19 12;p2.8 8 7.2 8;p16.8 8 21.2 8",
		["mail"] = "r3 5.5 18 13 2.8 0;p3.8 7.6 12 13.6 20.2 7.6",
		["menu"] = "p4 6.5 20 6.5;p4 12 20 12;p4 17.5 20 17.5",
		["minus"] = "p4.5 12 19.5 12",
		["moon"] = "q20.5 13.6 19.8 16 18.5 18.1 16.7 19.8 14.5 20.9 12 21.4 9.5 21.2 7.2 20.3 5.2 18.8 3.7 16.8 2.8 14.5 2.6 12 3.1 9.5 4.2 7.3 5.9 5.5 8 4.2 10.4 3.5 9.3 5 8.6 6.7 8.3 8.6 8.6 10.4 9.3 12.1 10.4 13.6 11.9 14.7 13.6 15.4 15.4 15.7 17.3 15.4 19 14.7 20.5 13.6",
		["mountain"] = "p2.5 20 9.5 6.5 16.5 20;p12.8 13 16.3 7 21.5 20;p2.5 20 21.5 20",
		["music"] = "p9.5 17.5 9.5 5.8;p9.5 5.8 19 3.6;p19 3.6 19 15.5;C7 17.8 2.7;C16.5 15.8 2.7",
		["pause"] = "B6.2 4.5 4 15 1.4 0;B13.8 4.5 4 15 1.4 0",
		["paw"] = "B7.2 12.2 9.6 8.6 4.3 0;C5.6 10.6 2.1;C9.4 6.4 2.2;C14.6 6.4 2.2;C18.4 10.6 2.1",
		["pickaxe"] = "p6.4 4.7 8 4 9.8 3.8 11.5 4 13.3 4.6 15 5.4 16.6 6.6 17.9 7.9 19.1 9.4 19.9 11.1 20.4 12.8 20.5 14.5 20.2 16.3 w2.6;p16.4 6.8 6.2 18.9",
		["pin"] = "p8.3 14.7 6.9 13.3 5.9 11.6 5.6 9.6 5.9 7.6 6.8 5.8 8.2 4.3 10 3.4 12 3.1 14 3.4 15.8 4.3 17.2 5.8 18.1 7.6 18.4 9.6 18.1 11.6 17.1 13.3 15.7 14.7;p8.3 14.6 12 21.5 15.7 14.6;C12 9.5 2.2",
		["pine"] = "q12 2.5 17.6 9.6 14.8 9.6 19.2 16 4.8 16 9.2 9.6 6.4 9.6;p12 16 12 21.5",
		["play"] = "q7 4.6 19 12 7 19.4",
		["plus"] = "p12 4.5 12 19.5;p4.5 12 19.5 12",
		["potion"] = "p9 3.5 15 3.5;p10.5 3.5 10.5 9.5;p13.5 3.5 13.5 9.5;p10.5 9.5 8.6 10.7 7.2 12.2 6.2 13.8 5.8 15.5 5.7 17.2 6.1 18.7 6.9 19.9 8 20.7 9.5 21 14.5 21 16 20.7 17.1 19.9 17.9 18.7 18.3 17.2 18.2 15.5 17.8 13.8 16.8 12.2 15.4 10.7 13.5 9.5;p6.9 15.2 17.1 15.2",
		["power"] = "p16.6 6.4 18.4 8.2 19.6 10.4 20 12.9 19.6 15.4 18.5 17.7 16.7 19.5 14.5 20.6 12 21 9.5 20.6 7.3 19.5 5.5 17.7 4.4 15.4 4 12.9 4.4 10.4 5.6 8.2 7.4 6.4;p12 3 12 12",
		["pulse"] = "p2.5 12 7 12 9.6 4.8 14.2 19.4 16.8 12 21.5 12",
		["refresh"] = "p19.3 8.6 19.8 10.4 20 12.3 19.7 14.2 18.9 16 17.8 17.5 16.3 18.7 14.6 19.6 12.7 20 10.8 19.9 8.9 19.4 7.3 18.5 5.9 17.1;p4.7 15.4 4.2 13.6 4 11.7 4.3 9.8 5.1 8 6.2 6.5 7.7 5.3 9.4 4.4 11.3 4 13.2 4.1 15.1 4.6 16.7 5.5 18.1 6.9;p10 18 5.9 17.1 6 21.3;p14 6 18.1 6.9 18 2.7",
		["rocket"] = "q12 2.5 13.5 3.7 14.7 5.1 15.5 6.8 16.1 8.5 16.4 10.4 16.4 12.4 16.1 14.4 15.6 16.5 8.4 16.5 7.9 14.4 7.6 12.4 7.6 10.4 7.9 8.5 8.5 6.8 9.3 5.1 10.5 3.7 12 2.5;c12 9.6 2.1;p8.4 12.6 5.2 16 5.2 19.4 8.8 18;p15.6 12.6 18.8 16 18.8 19.4 15.2 18;p12 19 12 22",
		["save"] = "r4 4 16 16 2.8 0;p8 4 8 9 15.5 9 15.5 4;r7.5 13.2 9 7 1.5 0",
		["search"] = "c10.5 10.5 6.5;p15.4 15.4 20.8 20.8",
		["send"] = "q21.5 2.5 2.5 10.5 10.4 13.6 13.5 21.5;p21.5 2.5 10.4 13.6",
		["server"] = "r3.5 3.5 17 7 2.6 0;r3.5 13.5 17 7 2.6 0;C7.6 7 1.1;C7.6 17 1.1;p12 7 17 7;p12 17 17 17",
		["settings"] = "c12 12 3.1;c12 12 6.6;p20.3 12 22.4 12 w3.4;p17.9 17.9 19.4 19.4 w3.4;p12 20.3 12 22.4 w3.4;p6.1 17.9 4.6 19.4 w3.4;p3.7 12 1.6 12 w3.4;p6.1 6.1 4.6 4.6 w3.4;p12 3.7 12 1.6 w3.4;p17.9 6.1 19.4 4.6 w3.4",
		["shield"] = "q12 3 19.5 6 19.5 12 19.2 14.1 18.4 16 17.2 17.6 15.7 19 13.9 20.1 12 21 10.1 20.1 8.3 19 6.8 17.6 5.6 16 4.8 14.1 4.5 12 4.5 6;p8.6 12 11 14.4 15.6 9.6",
		["skull"] = "p5.1 14.5 4.3 12.6 4 10.5 4.3 8.4 5.1 6.5 6.3 4.8 8 3.6 9.9 2.8 12 2.5 14.1 2.8 16 3.6 17.7 4.8 18.9 6.5 19.7 8.4 20 10.5 19.7 12.6 18.9 14.5;p18.9 14.5 16.5 16.2 16.5 20.5 7.5 20.5 7.5 16.2 5.1 14.5;C8.9 11.6 1.9;C15.1 11.6 1.9;p10.5 20.5 10.5 17.6;p13.5 20.5 13.5 17.6;q12 14.3 11.2 15.6 12.8 15.6 w1.2",
		["sliders"] = "p4 6.5 20 6.5;p4 12 20 12;p4 17.5 20 17.5;C15 6.5 2.5;C8 12 2.5;C16 17.5 2.5",
		["smile"] = "c12 12 9;C9 9.6 1.1;C15 9.6 1.1;p16.7 13.7 15.6 15.3 13.9 16.3 12 16.7 10.1 16.3 8.4 15.3 7.3 13.7",
		["sparkles"] = "q10.5 3.5 12.3 9.2 18 11 12.3 12.8 10.5 18.5 8.7 12.8 3 11 8.7 9.2;q18.6 3 19.4 5.1 21.5 6 19.4 6.9 18.6 9 17.8 6.9 15.7 6 17.8 5.1;C18.5 18 1.3",
		["sprout"] = "p12 21 12 11.5;p12 14 9.5 13.8 7.5 13.1 6 11.9 5 10.4 4.4 8.6 4.2 6.8 6.6 6.9 8.6 7.5 10.1 8.5 11.2 10 11.8 11.8 12 14;p12 11.5 12.2 9.5 12.7 7.7 13.6 6.3 14.8 5.1 16.2 4.2 18 3.7 20 3.5 19.8 5.5 19.3 7.3 18.4 8.8 17.2 10 15.8 10.8 14 11.3 12 11.5",
		["star"] = "q12 3 14.4 9.3 21.1 9.6 15.9 13.9 17.6 20.4 12 16.7 6.4 20.4 8.1 13.9 2.9 9.6 9.6 9.3",
		["stop"] = "B5.5 5.5 13 13 2.6 0",
		["sun"] = "c12 12 4.5;p19.7 12 22.2 12;p17.4 17.4 19.2 19.2;p12 19.7 12 22.2;p6.6 17.4 4.8 19.2;p4.3 12 1.8 12;p6.6 6.6 4.8 4.8;p12 4.3 12 1.8;p17.4 6.6 19.2 4.8",
		["sword"] = "q20.3 3.7 20 7.7 11.3 16.3 7.7 12.7 16.3 4;p4.3 11.3 12.7 19.7;p8.5 15.5 5.3 18.7;C4.3 19.7 1.5",
		["tag"] = "q4 4.5 12.6 4.5 20.5 12.4 12.4 20.5 4 12;C8.6 8.9 1.4",
		["target"] = "c12 12 8.5;c12 12 4.4;C12 12 1.3;p12 1.8 12 5;p12 19 12 22.2;p1.8 12 5 12;p19 12 22.2 12",
		["terminal"] = "r2.5 4 19 16 3.2 0;p6.6 9.6 10 12.4 6.6 15.2;p12.5 15.4 17.4 15.4",
		["trash"] = "p4 6.5 20 6.5;p9 6.5 9 4 15 4 15 6.5;p6.3 6.5 7.4 20.5 16.6 20.5 17.7 6.5;p10.2 10.5 10.2 16.5;p13.8 10.5 13.8 16.5",
		["trend"] = "p3 17 9.5 10.5 13.5 14.5 21 6.5;p15.4 6.5 21 6.5 21 12.1",
		["trophy"] = "q7 3.5 17 3.5 17 9.5 16.6 11.7 15.6 13.4 14 14.6 12 15 10 14.6 8.4 13.4 7.4 11.7 7 9.5;p7 5.5 4 5.5 4.2 7.8 4.8 9.4 5.9 10.4 7.4 11;p17 5.5 20 5.5 19.8 7.8 19.2 9.4 18.1 10.4 16.6 11;p12 15 12 19;p8 20.5 16 20.5",
		["unlock"] = "r5 11 14 10 2.5 0;p7.8 11 7.8 7.5;p7.8 7.5 8.2 5.7 9.2 4.1 10.8 3.1 12.6 2.7 14.4 3.1 16 4.1 17 5.7 17.4 7.5;p17.4 7.5 17.4 8.6;C12 15.2 1.5;p12 15.2 12 18",
		["upload"] = "p12 16 12 5;p7 9.2 12 4.2 17 9.2;p4.5 16.5 4.5 20 19.5 20 19.5 16.5",
		["user"] = "c12 7.8 4;p4 20.5 4.2 18.6 4.9 16.8 6 15.2 7.5 13.9 9.2 13 11 12.6 13 12.6 14.8 13 16.5 13.9 18 15.2 19.1 16.8 19.8 18.6 20 20.5;p4 20.5 20 20.5",
		["users"] = "c9 8 3.4;p2.5 20 2.8 18.2 3.5 16.5 4.7 15.1 6.3 14.1 8.1 13.6 9.9 13.6 11.7 14.1 13.3 15.1 14.5 16.5 15.2 18.2 15.5 20;p2.5 20 15.5 20;p16.8 5 18.3 5.7 19.2 7.1 19.4 8.8 18.7 10.3 17.3 11.2;p18.2 13.6 19.4 14.5 20.4 15.9 21.1 17.7 21.5 20",
		["volume"] = "q3.5 9.5 7.5 9.5 12 5.6 12 18.4 7.5 14.5 3.5 14.5;p15.6 8 16.7 9.4 17.3 11.1 17.3 12.9 16.7 14.6 15.6 16;p18.4 5.4 19.6 6.8 20.5 8.4 21 10.2 21.2 12 21 13.8 20.5 15.6 19.6 17.2 18.4 18.6",
		["wand"] = "p4.5 19.5 14.5 9.5 w3.2;p18 3 18 9;p15 6 21 6;C20.6 12 1;C8.6 5 1",
		["wifi"] = "p2.6 7.1 4.1 6.1 5.8 5.3 7.5 4.6 9.3 4.2 11.1 4 12.9 4 14.7 4.2 16.5 4.6 18.2 5.3 19.9 6.1 21.4 7.1;p5.5 11.6 6.9 10.7 8.5 10 10.3 9.5 12 9.4 13.7 9.5 15.5 10 17.1 10.7 18.5 11.6;p8.4 16 10.1 15 12 14.6 13.9 15 15.6 16;C12 19.6 1.3",
		["zap"] = "q13 2.5 4.8 13.4 11.4 13.4 10.6 21.5 19.2 10.4 12.6 10.4",
	}
	local ICON_ALIAS = {
		["account"] = "user",
		["activity"] = "pulse",
		["add"] = "plus",
		["aim"] = "target",
		["aimbot"] = "target",
		["animal"] = "paw",
		["apps"] = "grid",
		["attack"] = "sword",
		["attract"] = "magnet",
		["audio"] = "volume",
		["autoclick"] = "cursor",
		["back"] = "arrowleft",
		["backpack"] = "bag",
		["blade"] = "sword",
		["bolt"] = "zap",
		["boom"] = "bomb",
		["boost"] = "potion",
		["box"] = "cube",
		["brew"] = "potion",
		["buff"] = "potion",
		["build"] = "hammer",
		["burn"] = "flame",
		["buy"] = "cart",
		["cash"] = "coin",
		["chain"] = "link",
		["chest"] = "gift",
		["chick"] = "egg",
		["chip"] = "cpu",
		["click"] = "cursor",
		["cmd"] = "terminal",
		["cog"] = "settings",
		["coins"] = "coin",
		["collapse"] = "chevronup",
		["collect"] = "magnet",
		["combat"] = "sword",
		["comment"] = "chat",
		["config"] = "settings",
		["console"] = "terminal",
		["controls"] = "sliders",
		["craft"] = "hammer",
		["crate"] = "gift",
		["crop"] = "sprout",
		["cross"] = "close",
		["crosshair"] = "target",
		["crystal"] = "gem",
		["danger"] = "skull",
		["dark"] = "moon",
		["data"] = "database",
		["day"] = "sun",
		["db"] = "database",
		["dead"] = "skull",
		["death"] = "skull",
		["debug"] = "bug",
		["defense"] = "shield",
		["delete"] = "trash",
		["dev"] = "code",
		["diamond"] = "gem",
		["dir"] = "folder",
		["discord"] = "chat",
		["disk"] = "save",
		["doc"] = "file",
		["down"] = "arrowdown",
		["duplicate"] = "copy",
		["eggs"] = "egg",
		["emoji"] = "smile",
		["end"] = "stop",
		["esp"] = "eye",
		["exit"] = "logout",
		["expand"] = "chevrondown",
		["explode"] = "bomb",
		["exploit"] = "bug",
		["farm"] = "sprout",
		["farming"] = "sprout",
		["fast"] = "zap",
		["favorite"] = "star",
		["fight"] = "sword",
		["files"] = "folder",
		["find"] = "search",
		["fire"] = "flame",
		["fishing"] = "fish",
		["flask"] = "potion",
		["forest"] = "pine",
		["fps"] = "cpu",
		["friends"] = "users",
		["funnel"] = "filter",
		["gallery"] = "image",
		["gamble"] = "dice",
		["game"] = "controller",
		["gamepad"] = "controller",
		["games"] = "controller",
		["gear"] = "settings",
		["graph"] = "chart",
		["group"] = "users",
		["grow"] = "sprout",
		["growth"] = "trend",
		["guide"] = "book",
		["halloween"] = "ghost",
		["hamburger"] = "menu",
		["happy"] = "smile",
		["hatch"] = "egg",
		["heartbeat"] = "pulse",
		["hide"] = "eyeoff",
		["hint"] = "bulb",
		["hold"] = "pause",
		["host"] = "server",
		["house"] = "home",
		["hub"] = "server",
		["idea"] = "bulb",
		["inventory"] = "bag",
		["item"] = "cube",
		["kill"] = "sword",
		["king"] = "crown",
		["launch"] = "rocket",
		["layout"] = "grid",
		["leave"] = "logout",
		["left"] = "arrowleft",
		["light"] = "sun",
		["lightning"] = "zap",
		["like"] = "heart",
		["liquid"] = "drop",
		["location"] = "pin",
		["locked"] = "lock",
		["love"] = "heart",
		["luck"] = "dice",
		["magic"] = "sparkles",
		["map"] = "pin",
		["mark"] = "bookmark",
		["message"] = "chat",
		["mine"] = "pickaxe",
		["mining"] = "pickaxe",
		["misc"] = "grid",
		["money"] = "coin",
		["monster"] = "ghost",
		["mouse"] = "cursor",
		["nature"] = "leaf",
		["navigate"] = "compass",
		["network"] = "wifi",
		["next"] = "arrowright",
		["night"] = "moon",
		["notification"] = "bell",
		["notifications"] = "bell",
		["off"] = "power",
		["options"] = "sliders",
		["ore"] = "pickaxe",
		["package"] = "cube",
		["padlock"] = "lock",
		["pencil"] = "edit",
		["performance"] = "cpu",
		["person"] = "user",
		["pet"] = "paw",
		["pets"] = "paw",
		["photo"] = "camera",
		["picture"] = "image",
		["ping"] = "wifi",
		["plane"] = "send",
		["plant"] = "sprout",
		["pointer"] = "cursor",
		["premium"] = "crown",
		["present"] = "gift",
		["profile"] = "user",
		["profit"] = "trend",
		["protect"] = "shield",
		["pull"] = "magnet",
		["pvp"] = "sword",
		["quest"] = "book",
		["quests"] = "book",
		["rain"] = "drop",
		["random"] = "dice",
		["reload"] = "refresh",
		["resume"] = "play",
		["reward"] = "trophy",
		["rewards"] = "trophy",
		["right"] = "arrowright",
		["roll"] = "dice",
		["run"] = "play",
		["schedule"] = "calendar",
		["screenshot"] = "camera",
		["script"] = "code",
		["scroll"] = "book",
		["secure"] = "shield",
		["share"] = "send",
		["shop"] = "bag",
		["shutdown"] = "power",
		["signal"] = "wifi",
		["skill"] = "wand",
		["skills"] = "wand",
		["song"] = "music",
		["sound"] = "music",
		["sparkle"] = "sparkles",
		["speaker"] = "volume",
		["speed"] = "zap",
		["spell"] = "wand",
		["spooky"] = "ghost",
		["stack"] = "layers",
		["stars"] = "sparkles",
		["start"] = "play",
		["statistics"] = "chart",
		["stats"] = "chart",
		["steal"] = "egg",
		["storage"] = "database",
		["store"] = "bag",
		["sync"] = "refresh",
		["tasks"] = "list",
		["team"] = "users",
		["teleport"] = "pin",
		["text"] = "file",
		["tick"] = "check",
		["time"] = "clock",
		["timer"] = "clock",
		["tip"] = "bulb",
		["tool"] = "hammer",
		["tools"] = "hammer",
		["tp"] = "pin",
		["tree"] = "pine",
		["trending"] = "trend",
		["unlocked"] = "unlock",
		["up"] = "arrowup",
		["url"] = "link",
		["view"] = "eye",
		["vip"] = "crown",
		["visuals"] = "eye",
		["warning"] = "alert",
		["water"] = "drop",
		["weapon"] = "sword",
		["weather"] = "cloud",
		["web"] = "globe",
		["wiki"] = "book",
		["win"] = "trophy",
		["world"] = "globe",
		["x"] = "close",
	}
	local iconCache = {}
	local customIcons = {}
	local function iconKey(name)
		return (tostring(name):lower():gsub("[%s_%-]", ""))
	end
	local function parseIcon(str)
		local prims = {}
		for token in string.gmatch(str, "[^;]+") do
			local body = string.sub(token, 2)
			local width
			local wpos = string.find(body, "w", 1, true)
			if wpos then
				width = tonumber(string.sub(body, wpos + 1))
				body = string.sub(body, 1, wpos - 1)
			end
			local nums = {}
			for n in string.gmatch(body, "%-?[%d%.]+") do
				nums[1 + #nums] = tonumber(n)
			end
			prims[1 + #prims] = {
				kind = string.sub(token, 1, 1),
				nums = nums,
				width = width
			}
		end
		return prims
	end
	local function getIcon(name)
		if type(name) ~= "string" then
			return nil
		end
		local key = iconKey(name)
		local custom = customIcons[key]
		if custom then
			return custom
		end
		key = ICON_ALIAS[key] or key
		custom = customIcons[key]
		if custom then
			return custom
		end
		local cached = iconCache[key]
		if cached then
			return cached
		end
		local data = ICON_DATA[key]
		if data then
			cached = {
				name = key,
				prims = parseIcon(data)
			}
			iconCache[key] = cached
			return cached
		end
		return nil
	end
	local function createIcon(parent, name, options)
		options = options or {}
		local entry = (type(name) == "table" and name) or getIcon(name)
		if not entry then
			return nil
		end
		local size = tonumber(options.Size) or 16
		local k = size / 24
		local thick = tonumber(options.Thickness) or 2.1
		local z = tonumber(options.ZIndex) or 6
		local colorKey = options.ColorKey or "tabText"
		local staticColor = options.Color
		local holder = Instance_new("Frame")
		holder.Name = "icon_" .. tostring(entry.name or "custom")
		holder.BackgroundTransparency = 1
		holder.BorderSizePixel = 0
		holder.Size = UDim2.fromOffset(size, size)
		holder.ZIndex = z - 1
		holder.Parent = parent
		local entries = {}
		local function paint(inst, prop)
			local e = {inst, prop, colorKey}
			if staticColor then
				inst[prop] = staticColor
			else
				inst[prop] = library.colors[colorKey]
				colored[1 + #colored] = e
			end
			entries[1 + #entries] = e
		end
		if entry.asset then
			local img = Instance_new("ImageLabel")
			img.BackgroundTransparency = 1
			img.BorderSizePixel = 0
			img.Size = UDim2.fromScale(1, 1)
			img.ScaleType = Enum.ScaleType.Fit
			img.ZIndex = z
			local ok, res = pcall(resolveid, entry.asset)
			img.Image = (ok and res) or ""
			if options.KeepColor then
				img.ImageColor3 = WhiteColor3
			else
				paint(img, "ImageColor3")
			end
			img.Parent = holder
			return holder, entries
		end
		local function line(x1, y1, x2, y2, w)
			local dx, dy = x2 - x1, y2 - y1
			local len = math.sqrt(dx * dx + dy * dy)
			local f = Instance_new("Frame")
			f.AnchorPoint = Vector2Half
			f.BorderSizePixel = 0
			f.Position = UDim2.fromOffset((x1 + x2) / 2 * k, (y1 + y2) / 2 * k)
			f.Size = UDim2.fromOffset(len * k + w, w)
			f.Rotation = math.deg(math.atan2(dy, dx))
			f.ZIndex = z
			local c = Instance_new("UICorner")
			c.CornerRadius = UDim.new(0.5, 0)
			c.Parent = f
			paint(f, "BackgroundColor3")
			f.Parent = holder
		end
		local function box(x, y, w, h, rad, rot, fill, sw)
			x, y, w, h, rad = x * k, y * k, w * k, h * k, rad * k
			local f = Instance_new("Frame")
			f.AnchorPoint = Vector2Half
			f.BorderSizePixel = 0
			f.Rotation = rot or 0
			f.ZIndex = z
			f.Position = UDim2.fromOffset(x + w / 2, y + h / 2)
			local c = Instance_new("UICorner")
			if fill then
				f.Size = UDim2.fromOffset(w, h)
				c.CornerRadius = UDim.new(0, rad)
				paint(f, "BackgroundColor3")
			else
				local s = math.max(1.4, (sw or thick) * k)
				f.BackgroundTransparency = 1
				f.Size = UDim2.fromOffset(math.max(w - s, 1), math.max(h - s, 1))
				c.CornerRadius = UDim.new(0, math.max(rad - s / 2, 0))
				local st = Instance_new("UIStroke")
				st.Thickness = s
				st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				paint(st, "Color")
				st.Parent = f
			end
			c.Parent = f
			f.Parent = holder
		end
		for _, p in ipairs(entry.prims) do
			local n = p.nums
			local kind = p.kind
			if kind == "p" or kind == "q" then
				local w = math.max(1.4, (p.width or thick) * k)
				local count = math.floor(#n / 2)
				for i = 1, count - 1 do
					line(n[2 * i - 1], n[2 * i], n[2 * i + 1], n[2 * i + 2], w)
				end
				if kind == "q" and count > 2 then
					line(n[2 * count - 1], n[2 * count], n[1], n[2], w)
				end
			elseif kind == "c" or kind == "C" then
				box(n[1] - n[3], n[2] - n[3], n[3] * 2, n[3] * 2, n[3], 0, kind == "C", p.width)
			elseif kind == "r" or kind == "B" then
				box(n[1], n[2], n[3], n[4], n[5] or 0, n[6] or 0, kind == "B", p.width)
			end
		end
		return holder, entries
	end
	library.subs.GetIcon = getIcon
	library.subs.CreateIcon = createIcon
	function library:CreateIcon(parent, name, options)
		return createIcon(parent, name, options)
	end
	function library:HasIcon(name)
		return getIcon(name) ~= nil
	end
	function library:AddIcon(name, value, ...)
		assert(type(name) == "string", "AddIcon: the icon name must be a string")
		local entry
		local vt = type(value)
		if vt == "number" or (vt == "string" and (value:match("^%d+$") or value:match("^rbxasset") or value:match("^https?://"))) then
			entry = {
				asset = value
			}
		elseif vt == "string" then
			entry = {
				prims = parseIcon(value)
			}
		else
			error("AddIcon: value must be an asset id or an icon string")
		end
		local key = iconKey(name)
		entry.name = key
		customIcons[key] = entry
		for _, alias in next, {...} do
			customIcons[iconKey(alias)] = entry
		end
		return entry
	end
	function library:GetIcons()
		local list, seen = {}, {}
		for key in next, ICON_DATA do
			list[1 + #list] = key
			seen[key] = true
		end
		for key, entry in next, customIcons do
			if (not seen[key]) and (entry.name == key) then
				list[1 + #list] = key
			end
		end
		table.sort(list)
		return list
	end
end
function library:CreateWindow(options, ...)
	options = (options and (type(options) == "string") and resolvevararg("Window", options, ...)) or options
	local homepage
	local windowoptions = options
	local windowName = options.Name or "QuickX Hub"
	options.Name = windowName
	if options.ToggleStyle then
		library.ToggleStyle = tostring(options.ToggleStyle)
	end
	if windowName and (#windowName > 0) and (library.WorkspaceName == "QuickX Hub") then
		library.WorkspaceName = convertfilename(windowName, "QuickX Hub")
	end
	local pepsiLibrary = Instance_new("ScreenGui")
	library.MainScreenGui, MainScreenGui = pepsiLibrary, pepsiLibrary
	local TOP_H = 42
	local TAB_ROW_H = 40 -- sub tab row (MAIN / PLAYER / SETTING)
	local SIDEBAR_W = 148 -- left sidebar that holds the tabs
	local HEADER_HEIGHT = TOP_H + TAB_ROW_H
	local topbar = {
		minimized = false,
		maximized = false,
		tabsShown = true,
		page = "home",
		tabs = {}
	}
	local main = Instance_new("Frame")
	local mainCorner = Instance_new("UICorner")
	local mainStroke = Instance_new("UIStroke")
	local mainBorder = Instance_new("Frame")
	local tabSliderClip = Instance_new("Frame")
	local tabSlider = Instance_new("Frame")
	local innerMain = Instance_new("Frame")
	local innerMainBorder = Instance_new("Frame")
	local innerBackdrop = Instance_new("ImageLabel")
	local innerMainHolder = Instance_new("Frame")
	local headerBar = Instance_new("Frame")
	local headerLogo = Instance_new("ImageLabel")
	local tabArrowLeft = Instance_new("TextButton")
	local tabArrowLeftIcon = Instance_new("ImageLabel")
	local tabArrowRight = Instance_new("TextButton")
	local tabArrowRightIcon = Instance_new("ImageLabel")
	local tabsHolder = Instance_new("ScrollingFrame")
	local tabHolderList = Instance_new("UIListLayout")
	local tabScrollTrack = Instance_new("Frame")
	local tabScrollThumb = Instance_new("Frame")
	local tabScrollThumbCorner = Instance_new("UICorner")
	local submenuOpen
	library.globals["__Window" .. options.Name] = {
		submenuOpen = submenuOpen
	}
	pepsiLibrary.Name = "     "
	pepsiLibrary.Parent = library.gui_parent
	pepsiLibrary.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	pepsiLibrary.DisplayOrder = 10
	pepsiLibrary.ResetOnSpawn = false
	pepsiLibrary.IgnoreGuiInset = true
	-- window body: flat dark card with soft corners
	main.Name = "main"
	main.Parent = pepsiLibrary
	main.AnchorPoint = Vector2Half
	main.BackgroundColor3 = library.colors.background
	colored[1 + #colored] = {main, "BackgroundColor3", "background"}
	main.BorderSizePixel = 0
	if options.StartLocationUDim2 then
		main.Position = options.StartLocationUDim2
	elseif options.StartLocation then
		local AbsolutePosition = options.StartLocation
		main.Position = UDim2.fromOffset(AbsolutePosition.X, AbsolutePosition.Y)
	elseif options.StartLocationScale then
		local LocationRatioProjected = options.StartLocation * pepsiLibrary.AbsoluteSize
		main.Position = UDim2.fromOffset(LocationRatioProjected.X, LocationRatioProjected.Y)
	else
		main.Position = UDim2ScaleHalf
	end
	main.Size = UDim2.fromOffset(560, 500)
	makeDraggable(main, main, headerBar)
	mainCorner.Name = "mainCorner"
	mainCorner.CornerRadius = UDim.new(0, 14)
	mainCorner.Parent = main
	mainStroke.Name = "mainStroke"
	mainStroke.Color = library.colors.innerBorder
	colored[1 + #colored] = {mainStroke, "Color", "innerBorder"}
	mainStroke.Thickness = 1
	mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	mainStroke.Parent = main
	do
		-- faint scan lines + a glowing accent line on top (pure Frames)
		local tex = Instance_new("Frame")
		tex.Name = "texture"
		tex.Parent = main
		tex.BackgroundTransparency = 1
		tex.BorderSizePixel = 0
		tex.Size = UDim2ScaleOne
		tex.ZIndex = 0
		tex.ClipsDescendants = true
		local texList = Instance_new("UIListLayout")
		texList.Padding = UDim.new(0, 10)
		texList.SortOrder = Enum.SortOrder.LayoutOrder
		texList.Parent = tex
		for i = 1, 80 do
			local ln = Instance_new("Frame")
			ln.BorderSizePixel = 0
			ln.BackgroundColor3 = library.colors.main
			ln.BackgroundTransparency = 0.955
			ln.Size = UDim2.new(1, 0, 0, 1)
			ln.LayoutOrder = i
			ln.ZIndex = 0
			ln.Parent = tex
		end
		local accent = Instance_new("Frame")
		accent.Name = "accentLine"
		accent.Parent = main
		accent.BorderSizePixel = 0
		accent.BackgroundColor3 = library.colors.main
		colored[1 + #colored] = {accent, "BackgroundColor3", "main"}
		accent.Position = UDim2.new(0, 16, 0, 0)
		accent.Size = UDim2.new(1, -32, 0, 2)
		accent.ZIndex = 8
		local accentGrad = Instance_new("UIGradient")
		accentGrad.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0.05), NumberSequenceKeypoint.new(1, 1)})
		accentGrad.Parent = accent
	end
	-- old double border frames are kept (hidden) so nothing that looks them up breaks
	mainBorder.Name = "mainBorder"
	mainBorder.Parent = main
	mainBorder.BackgroundTransparency = 1
	mainBorder.BorderSizePixel = 0
	mainBorder.Size = UDim2ScaleOne
	mainBorder.Visible = false
	innerMain.Name = "innerMain"
	innerMain.Parent = main
	innerMain.BackgroundTransparency = 1
	innerMain.BorderSizePixel = 0
	innerMain.Size = UDim2ScaleOne
	innerMainBorder.Name = "innerMainBorder"
	innerMainBorder.Parent = innerMain
	innerMainBorder.BackgroundTransparency = 1
	innerMainBorder.BorderSizePixel = 0
	innerMainBorder.Size = UDim2ScaleOne
	innerMainBorder.Visible = false
	innerMainHolder.Name = "innerMainHolder"
	innerMainHolder.Parent = innerMain
	innerMainHolder.BackgroundColor3 = WhiteColor3
	innerMainHolder.BackgroundTransparency = 1
	innerMainHolder.Position = UDim2.new(0, 0, 0, HEADER_HEIGHT)
	innerMainHolder.Size = UDim2.new(1, 0, 1, -HEADER_HEIGHT)
	innerMainHolder.ClipsDescendants = true
	innerBackdrop.Name = "innerBackdrop"
	innerBackdrop.Parent = innerMainHolder
	innerBackdrop.BackgroundColor3 = WhiteColor3
	innerBackdrop.BackgroundTransparency = 1
	innerBackdrop.Size = UDim2ScaleOne
	innerBackdrop.ZIndex = -1
	innerBackdrop.ScaleType = Enum.ScaleType.Fit
	innerBackdrop.Visible = library_flags["__Designer.Background.UseBackgroundImage"] and true
	innerBackdrop.ImageColor3 = library_flags["__Designer.Background.ImageColor"] or WhiteColor3
	innerBackdrop.ImageTransparency = (library_flags["__Designer.Background.ImageTransparency"] or 95) / 100
	innerBackdrop.Image = resolveid(library_flags["__Designer.Background.ImageAssetID"], "__Designer.Background.ImageAssetID") or ""
	library.Backdrop = innerBackdrop
	-- header: top bar (logo, name, breadcrumb, search, window buttons) + row of tab pills
	headerBar.Name = "headerBar"
	headerBar.Parent = innerMain
	headerBar.BackgroundTransparency = 1
	headerBar.BorderSizePixel = 0
	headerBar.Size = UDim2.new(1, 0, 0, HEADER_HEIGHT)
	headerLogo.Name = "headerLogo"
	headerLogo.Parent = headerBar
	headerLogo.BackgroundTransparency = 1
	headerLogo.BorderSizePixel = 0
	headerLogo.Position = UDim2.new(0, 12, 0, (TOP_H - 28) / 2)
	headerLogo.Size = UDim2.fromOffset(28, 28)
	headerLogo.ScaleType = Enum.ScaleType.Fit
	headerLogo.ZIndex = 2
	do
		local logoId = options.Logo or options.Icon
		local resolvedLogo
		if logoId then
			local ok, res = pcall(resolveid, logoId)
			resolvedLogo = (ok and res) or nil
		end
		headerLogo.Image = resolvedLogo or "rbxassetid://132029940467197"
	end
	tabArrowLeft.Name = "tabArrowLeft"
	tabArrowLeft.Parent = headerBar
	tabArrowLeft.AnchorPoint = Vector2.new(0.5, 0.5)
	tabArrowLeft.AutoButtonColor = false
	tabArrowLeft.BackgroundTransparency = 1
	tabArrowLeft.BorderSizePixel = 0
	tabArrowLeft.Position = UDim2.new(0, 16, 0, TOP_H + 24)
	tabArrowLeft.Size = UDim2.fromOffset(26, 26)
	tabArrowLeft.Text = ""
	tabArrowLeft.Visible = false
	tabArrowLeft.ZIndex = 3
	tabArrowLeftIcon.Name = "icon"
	tabArrowLeftIcon.Parent = tabArrowLeft
	tabArrowLeftIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	tabArrowLeftIcon.BackgroundTransparency = 1
	tabArrowLeftIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
	tabArrowLeftIcon.Rotation = 180
	tabArrowLeftIcon.Size = UDim2.fromOffset(10, 10)
	tabArrowLeftIcon.Image = "rbxassetid://71659683"
	tabArrowLeftIcon.ImageColor3 = library.colors.otherElementText
	tabArrowLeftIcon.ZIndex = 4
	tabArrowRight.Name = "tabArrowRight"
	tabArrowRight.Parent = headerBar
	tabArrowRight.AnchorPoint = Vector2.new(0.5, 0.5)
	tabArrowRight.AutoButtonColor = false
	tabArrowRight.BackgroundTransparency = 1
	tabArrowRight.BorderSizePixel = 0
	tabArrowRight.Position = UDim2.new(1, -16, 0, TOP_H + 24)
	tabArrowRight.Size = UDim2.fromOffset(26, 26)
	tabArrowRight.Text = ""
	tabArrowRight.Visible = false
	tabArrowRight.ZIndex = 3
	tabArrowRightIcon.Name = "icon"
	tabArrowRightIcon.Parent = tabArrowRight
	tabArrowRightIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	tabArrowRightIcon.BackgroundTransparency = 1
	tabArrowRightIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
	tabArrowRightIcon.Size = UDim2.fromOffset(10, 10)
	tabArrowRightIcon.Image = "rbxassetid://71659683"
	tabArrowRightIcon.ImageColor3 = library.colors.otherElementText
	tabArrowRightIcon.ZIndex = 4
	tabsHolder.Name = "tabsHolder"
	tabsHolder.Parent = innerMain
	tabsHolder.Active = true
	tabsHolder.BackgroundColor3 = library.colors.sectionBackground
	colored[1 + #colored] = {tabsHolder, "BackgroundColor3", "sectionBackground"}
	tabsHolder.BackgroundTransparency = 0.08
	tabsHolder.BorderSizePixel = 0
	tabsHolder.Position = UDim2.new(0, 8, 0, HEADER_HEIGHT + 2)
	tabsHolder.Size = UDim2.new(0, SIDEBAR_W - 12, 1, -(HEADER_HEIGHT + 10))
	tabsHolder.ZIndex = 2
	tabsHolder.CanvasSize = UDim2.new()
	tabsHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
	tabsHolder.ScrollBarThickness = 2
	tabsHolder.ScrollBarImageColor3 = library.colors.main
	tabsHolder.ScrollingDirection = Enum.ScrollingDirection.Y
	tabsHolder.ElasticBehavior = Enum.ElasticBehavior.Never
	do
		local sbCorner = Instance_new("UICorner")
		sbCorner.CornerRadius = UDim.new(0, 11)
		sbCorner.Parent = tabsHolder
		local sbStroke = Instance_new("UIStroke")
		sbStroke.Color = library.colors.innerBorder
		colored[1 + #colored] = {sbStroke, "Color", "innerBorder"}
		sbStroke.Thickness = 1
		sbStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		sbStroke.Parent = tabsHolder
	end
	tabHolderList.Name = "tabHolderList"
	tabHolderList.Parent = tabsHolder
	tabHolderList.FillDirection = Enum.FillDirection.Vertical
	tabHolderList.SortOrder = Enum.SortOrder.LayoutOrder
	tabHolderList.HorizontalAlignment = Enum.HorizontalAlignment.Center
	tabHolderList.Padding = UDim.new(0, 5)
	local tabHolderPadding = Instance_new("UIPadding")
	tabHolderPadding.PaddingLeft = UDim.new(0, 6)
	tabHolderPadding.PaddingRight = UDim.new(0, 6)
	tabHolderPadding.PaddingTop = UDim.new(0, 8)
	tabHolderPadding.PaddingBottom = UDim.new(0, 8)
	tabHolderPadding.Parent = tabsHolder
	-- thin scroll indicator under the tabs
	tabScrollTrack.Name = "tabScrollTrack"
	tabScrollTrack.Parent = innerMain
	tabScrollTrack.BackgroundTransparency = 1
	tabScrollTrack.BorderSizePixel = 0
	tabScrollTrack.Position = UDim2.new(0, 30, 0, TOP_H + 46)
	tabScrollTrack.Size = UDim2.new(1, -60, 0, 3)
	tabScrollTrack.ZIndex = 2
	tabScrollTrack.Visible = false
	tabScrollThumb.Name = "tabScrollThumb"
	tabScrollThumb.Parent = tabScrollTrack
	tabScrollThumb.BackgroundColor3 = library.colors.hoveredOptionTop
	colored[1 + #colored] = {tabScrollThumb, "BackgroundColor3", "hoveredOptionTop"}
	tabScrollThumb.BorderSizePixel = 0
	tabScrollThumb.Size = UDim2.new(1, 0, 1, 0)
	tabScrollThumb.Visible = false
	tabScrollThumbCorner.CornerRadius = UDim.new(1, 0)
	tabScrollThumbCorner.Parent = tabScrollThumb
	-- legacy underline objects (kept hidden for compatibility)
	tabSliderClip.Name = "tabSliderClip"
	tabSliderClip.Parent = main
	tabSliderClip.BackgroundTransparency = 1
	tabSliderClip.BorderSizePixel = 0
	tabSliderClip.Size = UDim2.new(1, 0, 0, 1)
	tabSliderClip.Visible = false
	tabSlider.Name = "tabSlider"
	tabSlider.Parent = tabSliderClip
	tabSlider.BackgroundColor3 = library.colors.main
	colored[1 + #colored] = {tabSlider, "BackgroundColor3", "main"}
	tabSlider.BorderSizePixel = 0
	tabSlider.Visible = false
	-- ===== top bar: [logo + name] [sidebar] [Workspace > Tab] ...... [gear] [Search] [Ctrl K] [-] [ ] [x] =====
	do
		local hasKeyboard = userInputService.KeyboardEnabled
		local function track(inst, prop, colorName)
			colored[1 + #colored] = {inst, prop, colorName}
		end
		local function corner(parent, r)
			local c = Instance_new("UICorner")
			c.CornerRadius = UDim.new(0, r)
			c.Parent = parent
			return c
		end
		local function stroke(parent, thick, colorName)
			local s = Instance_new("UIStroke")
			s.Thickness = thick
			s.Color = library.colors[colorName]
			track(s, "Color", colorName)
			s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			s.Parent = parent
			return s
		end
		local function label(parent, text, size, font, colorName)
			local l = Instance_new("TextLabel")
			l.BackgroundTransparency = 1
			l.BorderSizePixel = 0
			l.Font = font
			l.Text = text
			l.TextSize = size
			l.TextColor3 = library.colors[colorName]
			track(l, "TextColor3", colorName)
			l.TextXAlignment = Enum.TextXAlignment.Left
			l.TextTruncate = Enum.TextTruncate.AtEnd
			l.ZIndex = 3
			l.Parent = parent
			return l
		end
		local function textWidth(text, size, font)
			local ok, v = pcall(function()
				return textService:GetTextSize(text, size, font, Vector2.new(1000, 100)).X
			end)
			return (ok and v) or (#text * size * 0.55)
		end
		-- little rectangle / square outline / ring used to draw the icons
		local function bar(parent, w, h, x, y, rot)
			local f = Instance_new("Frame")
			f.AnchorPoint = Vector2Half
			f.BackgroundColor3 = library.colors.otherElementText
			track(f, "BackgroundColor3", "otherElementText")
			f.BorderSizePixel = 0
			f.Position = UDim2.new(0.5, x, 0.5, y)
			f.Size = UDim2.fromOffset(w, h)
			f.Rotation = rot or 0
			f.ZIndex = 5
			f.Parent = parent
			return f
		end
		local function outline(parent, w, h, x, y, r, thick)
			local f = Instance_new("Frame")
			f.AnchorPoint = Vector2Half
			f.BackgroundTransparency = 1
			f.BorderSizePixel = 0
			f.Position = UDim2.new(0.5, x, 0.5, y)
			f.Size = UDim2.fromOffset(w, h)
			f.ZIndex = 5
			f.Parent = parent
			corner(f, r)
			stroke(f, thick or 1.5, "otherElementText")
			return f
		end
		local function iconButton(w)
			local b = Instance_new("TextButton")
			b.AutoButtonColor = false
			b.BackgroundColor3 = library.colors.hoveredOptionTop
			track(b, "BackgroundColor3", "hoveredOptionTop")
			b.BackgroundTransparency = 1
			b.BorderSizePixel = 0
			b.Text = ""
			b.Size = UDim2.fromOffset(w, 26)
			b.ZIndex = 4
			b.Parent = headerBar
			corner(b, 6)
			library.signals[1 + #library.signals] = b.MouseEnter:Connect(function()
				tweenService:Create(b, TweenInfo.new(0.12), {
					BackgroundTransparency = 0.35
				}):Play()
			end)
			library.signals[1 + #library.signals] = b.MouseLeave:Connect(function()
				tweenService:Create(b, TweenInfo.new(0.12), {
					BackgroundTransparency = 1
				}):Play()
			end)
			return b
		end

		-- thin line under the top bar
		local divider = Instance_new("Frame")
		divider.Name = "topBarDivider"
		divider.Parent = headerBar
		divider.BackgroundColor3 = library.colors.innerBorder
		track(divider, "BackgroundColor3", "innerBorder")
		divider.BackgroundTransparency = 0.35
		divider.BorderSizePixel = 0
		divider.Position = UDim2.new(0, 0, 0, TOP_H - 1)
		divider.Size = UDim2.new(1, 0, 0, 1)
		divider.ZIndex = 2

		-- hub name + small sub title (game name) next to the logo
		local hubName = label(headerBar, tostring(windowName), 13, Enum.Font.GothamBold, "elementText")
		hubName.Name = "hubName"
		hubName.Position = UDim2.fromOffset(48, 6)
		hubName.Size = UDim2.fromOffset(104, 16)
		local subText = options.SubTitle or options.Subtitle or options.Game
		if not subText then
			-- game.Name is just the DataModel name ("Ugc"), so ask Marketplace for the real place name
			local mapName
			pcall(function()
				local ms = game:GetService("MarketplaceService")
				local info = ms:GetProductInfo(game.PlaceId)
				mapName = info and info.Name
			end)
			if not mapName or mapName == "" then
				pcall(function()
					mapName = game.Name
				end)
			end
			subText = "[" .. tostring(mapName or "Unknown") .. "] Premium"
		end
		local hubSub = label(headerBar, tostring(subText or ""), 10, Enum.Font.Gotham, "otherElementText")
		hubSub.Name = "hubSubTitle"
		hubSub.Position = UDim2.fromOffset(56, 20)
		hubSub.Size = UDim2.fromOffset(92, 12)
		hubSub.TextSize = 9
		-- QuickX brand card: glowing logo tile, gradient name, live status dot
		do
			local brand = Instance_new("Frame")
			brand.Name = "brandCard"
			brand.Parent = headerBar
			brand.BackgroundColor3 = library.colors.main
			track(brand, "BackgroundColor3", "main")
			brand.BackgroundTransparency = 0.86
			brand.BorderSizePixel = 0
			brand.Position = UDim2.fromOffset(8, 4)
			brand.Size = UDim2.fromOffset(148, 34)
			brand.ZIndex = 1
			corner(brand, 11)
			stroke(brand, 1, "main").Transparency = 0.55
			local bg = Instance_new("UIGradient")
			bg.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0.75)})
			bg.Parent = brand
			local tile = Instance_new("Frame")
			tile.Name = "logoTile"
			tile.Parent = headerBar
			tile.BackgroundColor3 = Color3.fromRGB(6, 16, 11)
			tile.BorderSizePixel = 0
			tile.Position = UDim2.fromOffset(13, 8)
			tile.Size = UDim2.fromOffset(26, 26)
			tile.ZIndex = 2
			corner(tile, 8)
			local tileStroke = stroke(tile, 1.2, "main")
			tileStroke.Transparency = 0.2
			tweenService:Create(tileStroke, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Transparency = 0.8}):Play()
			headerLogo.Position = UDim2.fromOffset(16, 11)
			headerLogo.Size = UDim2.fromOffset(20, 20)
			headerLogo.ZIndex = 4
			hubName.Position = UDim2.fromOffset(46, 5)
			hubName.Size = UDim2.fromOffset(100, 15)
			hubName.Font = Enum.Font.GothamBlack
			hubName.TextSize = 13
			local ng = Instance_new("UIGradient")
			ng.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(120, 255, 175))
			ng.Parent = hubName
			local dot = Instance_new("Frame")
			dot.Name = "statusDot"
			dot.Parent = headerBar
			dot.BackgroundColor3 = library.colors.main
			track(dot, "BackgroundColor3", "main")
			dot.BorderSizePixel = 0
			dot.Position = UDim2.fromOffset(46, 24)
			dot.Size = UDim2.fromOffset(5, 5)
			dot.ZIndex = 4
			corner(dot, 3)
			tweenService:Create(dot, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {BackgroundTransparency = 0.7}):Play()
		end

		-- right side buttons, placed from the right edge inwards
		local rx = 12
		local function placeRightFixed(obj, w, h)
			obj.AnchorPoint = Vector2.new(1, 0)
			obj.Position = UDim2.new(1, -rx, 0, (TOP_H - h) / 2)
			rx = rx + w + 4
		end
		local closeBtn = iconButton(26)
		closeBtn.Name = "closeButton"
		placeRightFixed(closeBtn, 26, 26)
		bar(closeBtn, 13, 1.5, 0, 0, 45)
		bar(closeBtn, 13, 1.5, 0, 0, -45)
		local maxBtn = iconButton(26)
		maxBtn.Name = "maximizeButton"
		placeRightFixed(maxBtn, 26, 26)
		outline(maxBtn, 10, 10, 0, 0, 2, 1.4)
		local minBtn = iconButton(26)
		minBtn.Name = "minimizeButton"
		placeRightFixed(minBtn, 26, 26)
		bar(minBtn, 11, 1.5, 0, 3, 0)
		if hasKeyboard then
			local chip = Instance_new("TextLabel")
			chip.Name = "shortcutChip"
			chip.Parent = headerBar
			chip.BackgroundColor3 = library.colors.selectedOption
			track(chip, "BackgroundColor3", "selectedOption")
			chip.BackgroundTransparency = 0.2
			chip.BorderSizePixel = 0
			chip.Font = Enum.Font.GothamMedium
			chip.Text = "Ctrl K"
			chip.TextSize = 10
			chip.TextColor3 = library.colors.otherElementText
			track(chip, "TextColor3", "otherElementText")
			chip.ZIndex = 4
			chip.Size = UDim2.fromOffset(42, 20)
			corner(chip, 5)
			placeRightFixed(chip, 42, 20)
		end
		local searchBtn = iconButton(70)
		searchBtn.Name = "searchButton"
		placeRightFixed(searchBtn, 70, 26)
		outline(searchBtn, 8, 8, -22, -1, 8, 1.5)
		bar(searchBtn, 5, 1.5, -17.5, 3.5, 45)
		local searchText = label(searchBtn, "Search", 11, Enum.Font.Gotham, "otherElementText")
		searchText.Position = UDim2.fromOffset(28, 0)
		searchText.Size = UDim2.new(1, -30, 1, 0)
		searchText.ZIndex = 5
		local gearBtn = iconButton(26)
		gearBtn.Name = "settingsButton"
		placeRightFixed(gearBtn, 26, 26)
		outline(gearBtn, 8, 8, 0, 0, 8, 2)
		for i = 0, 7 do
			local a = math.rad(i * 45)
			bar(gearBtn, 3, 3, math.cos(a) * 6.5, math.sin(a) * 6.5, i * 45)
		end

		-- sidebar-style toggle: shows / hides the tab row to give the content more room
		local sideBtn = iconButton(26)
		sideBtn.Name = "sidebarButton"
		sideBtn.Position = UDim2.fromOffset(192, (TOP_H - 26) / 2)
		outline(sideBtn, 15, 13, 0, 0, 3, 1.4)
		bar(sideBtn, 1.4, 13, -2.5, 0, 0)
		-- home button: back to the landing page
		local homeBtn = iconButton(26)
		homeBtn.Name = "homeButton"
		homeBtn.Position = UDim2.fromOffset(160, (TOP_H - 26) / 2)
		do
			local hIcon = library.subs.CreateIcon(homeBtn, "home", {Size = 16, ColorKey = "otherElementText", ZIndex = 6, Thickness = 2})
			if hIcon then
				hIcon.AnchorPoint = Vector2Half
				hIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
			end
		end
		library.signals[1 + #library.signals] = homeBtn.MouseButton1Click:Connect(function()
			if topbar.goHome then
				topbar.goHome()
			end
		end)

		-- breadcrumb:  Workspace > <current tab>
		local crumbX = 196
		local crumb = Instance_new("Frame")
		crumb.Name = "breadcrumb"
		crumb.Visible = false
		crumb.Parent = headerBar
		crumb.BackgroundTransparency = 1
		crumb.BorderSizePixel = 0
		crumb.ClipsDescendants = true
		crumb.Position = UDim2.fromOffset(crumbX, 0)
		crumb.Size = UDim2.new(1, -(crumbX + rx), 0, TOP_H)
		crumb.ZIndex = 3
		local wsText = tostring(options.Breadcrumb or "Workspace")
		local wsW = math.ceil(textWidth(wsText, 11, Enum.Font.Gotham))
		local wsLabel = label(crumb, wsText, 11, Enum.Font.Gotham, "otherElementText")
		wsLabel.Position = UDim2.fromOffset(0, 0)
		wsLabel.Size = UDim2.new(0, wsW + 2, 1, 0)
		local chev = Instance_new("ImageLabel")
		chev.Name = "chevron"
		chev.Parent = crumb
		chev.AnchorPoint = Vector2.new(0, 0.5)
		chev.BackgroundTransparency = 1
		chev.Image = "rbxassetid://71659683"
		chev.ImageColor3 = library.colors.otherElementText
		track(chev, "ImageColor3", "otherElementText")
		chev.Position = UDim2.new(0, wsW + 9, 0.5, 0)
		chev.Size = UDim2.fromOffset(8, 8)
		chev.ZIndex = 3
		local curLabel = label(crumb, "", 11, Enum.Font.GothamBold, "elementText")
		curLabel.Name = "currentTab"
		curLabel.Position = UDim2.new(0, wsW + 24, 0, 0)
		curLabel.Size = UDim2.new(1, -(wsW + 24), 1, 0)
		function topbar.setCrumb(name)
			curLabel.Text = tostring(name or "")
		end

		-- page switch (landing page / app with left sidebar) + minimize (collapse to just the top bar)
		function topbar.apply()
			local hh = HEADER_HEIGHT
			local inApp = topbar.page == "app"
			local live = not topbar.minimized
			local sideW = (inApp and topbar.tabsShown) and (SIDEBAR_W - 4) or 0
			tabsHolder.Visible = inApp and topbar.tabsShown and live
			innerMainHolder.Visible = inApp and live
			innerMainHolder.Position = UDim2.new(0, sideW, 0, hh)
			innerMainHolder.Size = UDim2.new(1, -sideW, 1, -hh)
			if topbar.navRow then
				topbar.navRow.Visible = live
			end
			if topbar.homeFrame then
				topbar.homeFrame.Visible = (not inApp) and live
			end
			if library.RefreshLayout then
				library.RefreshLayout()
			end
		end

		-- search popup: type to filter the tabs, tap one to jump to it
		local panel = Instance_new("Frame")
		panel.Name = "searchPanel"
		panel.Parent = main
		panel.Visible = false
		panel.AnchorPoint = Vector2.new(1, 0)
		panel.Position = UDim2.new(1, -12, 0, TOP_H + 4)
		panel.Size = UDim2.fromOffset(230, 38)
		panel.BackgroundColor3 = library.colors.sectionBackground
		track(panel, "BackgroundColor3", "sectionBackground")
		panel.BorderSizePixel = 0
		panel.ZIndex = 40
		corner(panel, 8)
		stroke(panel, 1, "innerBorder")
		local box = Instance_new("TextBox")
		box.Name = "searchBox"
		box.Parent = panel
		box.BackgroundTransparency = 1
		box.BorderSizePixel = 0
		box.ClearTextOnFocus = false
		box.Font = Enum.Font.Gotham
		box.PlaceholderText = "Search tab..."
		box.PlaceholderColor3 = library.colors.otherElementText
		box.Text = ""
		box.TextColor3 = library.colors.elementText
		track(box, "TextColor3", "elementText")
		box.TextSize = 12
		box.TextXAlignment = Enum.TextXAlignment.Left
		box.Position = UDim2.fromOffset(12, 0)
		box.Size = UDim2.new(1, -24, 0, 38)
		box.ZIndex = 41
		local list = Instance_new("ScrollingFrame")
		list.Name = "results"
		list.Parent = panel
		list.Active = true
		list.BackgroundTransparency = 1
		list.BorderSizePixel = 0
		list.Position = UDim2.fromOffset(6, 38)
		list.Size = UDim2.new(1, -12, 0, 0)
		list.CanvasSize = UDim2.new()
		list.AutomaticCanvasSize = Enum.AutomaticSize.Y
		list.ScrollBarThickness = 2
		list.ZIndex = 41
		local listLayout = Instance_new("UIListLayout")
		listLayout.SortOrder = Enum.SortOrder.LayoutOrder
		listLayout.Padding = UDim.new(0, 2)
		listLayout.Parent = list
		local rows = {}
		local function closeSearch()
			if panel.Visible then
				pcall(function()
					box:ReleaseFocus()
				end)
			end
			panel.Visible = false
		end
		local function refresh()
			for _, r in ipairs(rows) do
				r:Destroy()
			end
			table.clear(rows)
			local q = string.lower(box.Text or "")
			local count = 0
			for _, entry in ipairs(topbar.tabs) do
				if (q == "") or string.find(string.lower(entry.Name), q, 1, true) then
					count = count + 1
					local r = Instance_new("TextButton")
					r.AutoButtonColor = false
					r.BackgroundColor3 = library.colors.selectedOption
					r.BorderSizePixel = 0
					r.Font = Enum.Font.Gotham
					r.Text = entry.Name
					r.TextColor3 = library.colors.elementText
					r.TextSize = 12
					r.TextXAlignment = Enum.TextXAlignment.Left
					r.Size = UDim2.new(1, -4, 0, 26)
					r.LayoutOrder = count
					r.ZIndex = 42
					local pad = Instance_new("UIPadding")
					pad.PaddingLeft = UDim.new(0, 10)
					pad.Parent = r
					corner(r, 6)
					r.Parent = list
					r.MouseButton1Click:Connect(function()
						closeSearch()
						entry.Go()
					end)
					rows[1 + #rows] = r
				end
			end
			local shown = math.min(count, 6)
			list.Size = UDim2.new(1, -12, 0, shown * 28)
			panel.Size = UDim2.fromOffset(230, 38 + ((shown > 0) and (shown * 28 + 6) or 0))
		end
		local function openSearch()
			if topbar.minimized then
				topbar.minimized = false
				topbar.apply()
			end
			box.Text = ""
			refresh()
			panel.Visible = true
			box:CaptureFocus()
		end
		local function toggleSearch()
			if panel.Visible then
				closeSearch()
			else
				openSearch()
			end
		end
		library.signals[1 + #library.signals] = box:GetPropertyChangedSignal("Text"):Connect(refresh)
		library.signals[1 + #library.signals] = box.FocusLost:Connect(function(enterPressed)
			if enterPressed then
				local q = string.lower(box.Text or "")
				if q ~= "" then
					for _, entry in ipairs(topbar.tabs) do
						if string.find(string.lower(entry.Name), q, 1, true) then
							closeSearch()
							entry.Go()
							return
						end
					end
				end
			end
			task.delay(0.2, function()
				if panel.Parent and not box:IsFocused() then
					panel.Visible = false
				end
			end)
		end)
		library.signals[1 + #library.signals] = userInputService.InputBegan:Connect(function(input)
			if (input.KeyCode == Enum.KeyCode.K) and main.Visible and (userInputService:IsKeyDown(Enum.KeyCode.LeftControl) or userInputService:IsKeyDown(Enum.KeyCode.RightControl)) then
				toggleSearch()
			end
		end)

		-- button actions
		library.signals[1 + #library.signals] = searchBtn.MouseButton1Click:Connect(toggleSearch)
		library.signals[1 + #library.signals] = gearBtn.MouseButton1Click:Connect(function()
			closeSearch()
			for i = #topbar.tabs, 1, -1 do
				if topbar.tabs[i].Last then
					topbar.tabs[i].Go()
					return
				end
			end
		end)
		library.signals[1 + #library.signals] = sideBtn.MouseButton1Click:Connect(function()
			closeSearch()
			topbar.minimized = false
			topbar.tabsShown = not topbar.tabsShown
			topbar.apply()
		end)
		library.signals[1 + #library.signals] = minBtn.MouseButton1Click:Connect(function()
			closeSearch()
			topbar.minimized = not topbar.minimized
			topbar.apply()
		end)
		library.signals[1 + #library.signals] = maxBtn.MouseButton1Click:Connect(function()
			closeSearch()
			topbar.minimized = false
			topbar.maximized = not topbar.maximized
			main.Position = UDim2ScaleHalf
			topbar.apply()
		end)
		library.signals[1 + #library.signals] = closeBtn.MouseButton1Click:Connect(function()
			closeSearch()
			if options.CloseUnloads then
				library.unload()
			else
				main.Visible = false
			end
		end)
	end
	local uiScale = Instance_new("UIScale")
	uiScale.Name = "uiScale"
	uiScale.Scale = 1
	uiScale.Parent = main
	library.UIScaleObject = uiScale
	local function guiScale()
		local s = uiScale.Scale
		return ((type(s) == "number") and (s > 0) and s) or 1
	end
	local function getViewport()
		local size = pepsiLibrary.AbsoluteSize
		if (size.X < 50) or (size.Y < 50) then
			local cam = game:GetService("Workspace").CurrentCamera
			size = (cam and cam.ViewportSize) or Vector2.new(1280, 720)
		end
		return size
	end
	-- user chosen size (in unscaled units), set by the resize grip in the bottom right corner
	local MIN_W, MIN_H = 380, 240
	local userW, userH
	local resizeGrip
	local function relayout()
		if not __runscript then
			return
		end
		local view = getViewport()
		local baseW, baseH, minH, margin = 560, 500, 260, 12
		local userMul = tonumber(library.configuration.uiScale) or 1
		local maxByW = (view.X - margin) / baseW
		local maxByH = (view.Y - margin) / minH
		local scale = math.min(1, maxByW) * userMul
		if topbar.maximized then
			scale = math.min(maxByW, (view.Y - margin) / 360, 2.2)
		end
		scale = math.max(math.min(scale, maxByW, maxByH), 0.4)
		local width = baseW
		local height = math.clamp(math.floor((view.Y - margin) / scale), minH, (topbar.maximized and 4000) or baseH)
		if not topbar.maximized then
			if userW then
				local fitW = math.max(math.floor((view.X - margin) / scale), MIN_W)
				width = math.clamp(userW, MIN_W, fitW)
			end
			if userH then
				local fitH = math.max(math.floor((view.Y - margin) / scale), MIN_H)
				height = math.clamp(userH, MIN_H, fitH)
			end
		end
		if topbar.minimized then
			height = TOP_H
		end
		uiScale.Scale = scale
		main.Size = UDim2.fromOffset(width, height)
		if resizeGrip then
			resizeGrip.Visible = not (topbar.minimized or topbar.maximized) and (library.configuration.resizable ~= false)
		end
	end
	function library.ResetWindow()
		userW, userH = nil, nil
		main.Position = UDim2ScaleHalf
		relayout()
	end
	library.signals[1 + #library.signals] = pepsiLibrary:GetPropertyChangedSignal("AbsoluteSize"):Connect(relayout)
	library.RefreshLayout = relayout
	-- the camera's viewport size can still be a default value on the very first frame, so re-layout when it settles
	pcall(function()
		local cam = game:GetService("Workspace").CurrentCamera
		if cam then
			library.signals[1 + #library.signals] = cam:GetPropertyChangedSignal("ViewportSize"):Connect(relayout)
		end
	end)
	-- resize grip (bottom right corner): drag to stretch the window to any size
	do
		local grip = Instance_new("TextButton")
		grip.Name = "resizeGrip"
		grip.AnchorPoint = Vector2.new(1, 1)
		grip.Position = UDim2.new(1, -2, 1, -2)
		grip.Size = UDim2.fromOffset(26, 26)
		grip.BackgroundTransparency = 1
		grip.BorderSizePixel = 0
		grip.AutoButtonColor = false
		grip.Text = ""
		grip.ZIndex = 60
		grip.Parent = main
		resizeGrip = grip
		local dots = {}
		for row = 0, 2 do
			for col = 0, 2 - row do
				local dot = Instance_new("Frame")
				dot.Name = "gripDot"
				dot.AnchorPoint = Vector2.new(1, 1)
				dot.Position = UDim2.new(1, -(6 + col * 5), 1, -(6 + row * 5))
				dot.Size = UDim2.fromOffset(3, 3)
				dot.BackgroundColor3 = library.colors.otherElementText
				dot.BackgroundTransparency = 0.25
				dot.BorderSizePixel = 0
				dot.ZIndex = 61
				colored[1 + #colored] = {dot, "BackgroundColor3", "otherElementText"}
				local dotCorner = Instance_new("UICorner")
				dotCorner.CornerRadius = UDim.new(1, 0)
				dotCorner.Parent = dot
				dot.Parent = grip
				dots[1 + #dots] = dot
			end
		end
		local resizing, hovering = false, false
		local startInput, startPos, startW, startH, startPosition
		local function paint()
			local active = resizing or hovering
			for _, dot in ipairs(dots) do
				tweenService:Create(dot, TweenInfo.new(0.15), {
					BackgroundColor3 = (active and library.colors.main) or library.colors.otherElementText,
					BackgroundTransparency = (active and 0) or 0.25
				}):Play()
			end
		end
		library.signals[1 + #library.signals] = grip.MouseEnter:Connect(function()
			hovering = true
			paint()
		end)
		library.signals[1 + #library.signals] = grip.MouseLeave:Connect(function()
			hovering = false
			paint()
		end)
		library.signals[1 + #library.signals] = grip.InputBegan:Connect(function(input)
			local t = input.UserInputType
			if (t ~= Enum.UserInputType.MouseButton1) and (t ~= Enum.UserInputType.Touch) then
				return
			end
			if topbar.maximized or topbar.minimized then
				return
			end
			resizing = true
			isDraggingSomething = true
			startInput = (t == Enum.UserInputType.Touch) and input or nil
			startPos = input.Position
			startW, startH = main.Size.X.Offset, main.Size.Y.Offset
			startPosition = main.Position
			paint()
			local endsig
			endsig = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					resizing = false
					isDraggingSomething = false
					paint()
					if endsig then
						endsig:Disconnect()
						endsig = nil
					end
				end
			end)
			library.signals[1 + #library.signals] = endsig
		end)
		library.signals[1 + #library.signals] = userInputService.InputChanged:Connect(function(input)
			if not resizing then
				return
			end
			if startInput then
				if input ~= startInput then
					return
				end
			elseif input.UserInputType ~= Enum.UserInputType.MouseMovement then
				return
			end
			local s = guiScale()
			local view = getViewport()
			local margin = 12
			local delta = input.Position - startPos
			local newW = math.clamp(startW + (delta.X / s), MIN_W, math.max(math.floor((view.X - margin) / s), MIN_W))
			local newH = math.clamp(startH + (delta.Y / s), MIN_H, math.max(math.floor((view.Y - margin) / s), MIN_H))
			userW, userH = newW, newH
			main.Size = UDim2.fromOffset(newW, newH)
			-- keep the top left corner where it is (the window is anchored at its centre), then keep it on screen
			local halfW, halfH = (newW * s) / 2, (newH * s) / 2
			local cx = (startPosition.X.Scale * view.X) + startPosition.X.Offset + ((newW - startW) * s) / 2
			local cy = (startPosition.Y.Scale * view.Y) + startPosition.Y.Offset + ((newH - startH) * s) / 2
			cx = math.clamp(cx, halfW, math.max(view.X - halfW, halfW))
			cy = math.clamp(cy, halfH, math.max(view.Y - halfH, halfH))
			main.Position = UDim2.new(startPosition.X.Scale, cx - (startPosition.X.Scale * view.X), startPosition.Y.Scale, cy - (startPosition.Y.Scale * view.Y))
		end)
	end
	relayout()
	task.delay(0.3, relayout)
	local mobileButton
	do
		local want = options.MobileButton
		if want == nil then
			want = shared.force_mobile_button
		end
		if want == nil then
			want = userInputService.TouchEnabled and not userInputService.KeyboardEnabled
		end
		if want then
			mobileButton = Instance_new("ImageButton")
			mobileButton.Name = "QuickHubToggle"
			mobileButton.AnchorPoint = Vector2.new(0, 0)
			mobileButton.Position = UDim2.new(0, 20, 0, 100)
			mobileButton.Size = UDim2.new(0, 55, 0, 55)
			mobileButton.AutoButtonColor = false
			mobileButton.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
			mobileButton.BackgroundTransparency = 0
			mobileButton.BorderSizePixel = 0
			mobileButton.Image = "rbxassetid://132029940467197" -- QuickX Hub
			mobileButton.ImageTransparency = 0
			mobileButton.ScaleType = Enum.ScaleType.Fit
			mobileButton.ZIndex = 20
			local mobileButtonCorner = Instance_new("UICorner")
			mobileButtonCorner.CornerRadius = UDim.new(0, 14)
			mobileButtonCorner.Parent = mobileButton
			local mobileButtonStroke = Instance_new("UIStroke")
			mobileButtonStroke.Thickness = 0
			mobileButtonStroke.Color = library.colors.main
			colored[1 + #colored] = {mobileButtonStroke, "Color", "main"}
			mobileButtonStroke.Parent = mobileButton
			mobileButton.Parent = pepsiLibrary
			local pressed, pressPos, startPos, moved
			library.signals[1 + #library.signals] = mobileButton.InputBegan:Connect(function(input)
				if pressed or not isPress(input) then
					return
				end
				pressed, pressPos, startPos, moved = input, input.Position, mobileButton.Position, false
				local sig
				sig = input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						if sig then
							sig:Disconnect()
							sig = nil
						end
						if pressed == input then
							pressed = nil
							if not moved then
								main.Visible = not main.Visible
							end
						end
					end
				end)
				library.signals[1 + #library.signals] = sig
			end)
			library.signals[1 + #library.signals] = userInputService.InputChanged:Connect(function(input)
				if pressed and isMove(input) and ((input == pressed) or ((pressed.UserInputType == Enum.UserInputType.MouseButton1) and (input.UserInputType == Enum.UserInputType.MouseMovement))) then
					local delta = input.Position - pressPos
					if moved or (delta.Magnitude > 8) then
						moved = true
						mobileButton.Position = clampedPosition(startPos, delta)
					end
				end
			end)
		end
	end
	local IgnoreCoreInputs
	do
		local os_clock = os.clock
		library.signals[1 + #library.signals] = userInputService.InputBegan:Connect(function(keyCode)
			if IgnoreCoreInputs or userInputService:GetFocusedTextBox() then
				return
			elseif (keyCode.KeyCode == library.configuration.hideKeybind) or (shared.force_toggle_gui_keybind and (shared.force_toggle_gui_keybind == keyCode.KeyCode)) then
				if (lasthidebing == nil) or ((os_clock() - lasthidebing) > 0.35) then
					main.Visible = not main.Visible
				end
				lasthidebing = nil
			end
		end)
	end
	local windowFunctions = {
		tabCount = 0,
		selected = {},
		Flags = elements
	}
	library.globals["__Window" .. windowName].windowFunctions = windowFunctions
	windowFunctions.MobileButton = mobileButton
	windowFunctions.RefreshLayout = relayout
	function windowFunctions:Show(x)
		main.Visible = (x == nil) or (x == true) or (x == 1)
		return main.Visible
	end
	function windowFunctions:Hide(x)
		main.Visible = (x == false) or (x == 0)
		return main.Visible
	end
	function windowFunctions:Visibility(x)
		if x == nil then
			main.Visible = not main.Visible
		else
			main.Visible = x and true
		end
		return main.Visible
	end
	local LastTabWindowSlideThingyOfDeath, tabScrollTween
	local function tabMetrics()
		local s = guiScale()
		local view = tabsHolder.AbsoluteSize.Y / s
		local canvas = tabsHolder.AbsoluteCanvasSize.Y / s
		return s, view, canvas, math.max(canvas - view, 0)
	end
	local function updateTabScroll()
	end
	local function scrollTabsTo(y)
		local _, _, _, maxScroll = tabMetrics()
		y = math.clamp(y, 0, maxScroll)
		if tabScrollTween then
			tabScrollTween:Cancel()
		end
		tabScrollTween = tweenService:Create(tabsHolder, TweenInfo.new(0.3, library.configuration.easingStyle, library.configuration.easingDirection), {
			CanvasPosition = Vector2.new(0, y)
		})
		tabScrollTween:Play()
	end
	-- keeps the picked tab fully inside the sidebar
	function windowFunctions:MoveTabSlider(tabObject)
		LastTabWindowSlideThingyOfDeath = tabObject
		task.defer(function()
			local item = tabObject
			if item and (item.Parent ~= tabsHolder) then
				item = item.Parent
			end
			if not (__runscript and item and (item.Parent == tabsHolder)) then
				return
			end
			local s, view = tabMetrics()
			local top = ((item.AbsolutePosition.Y - tabsHolder.AbsolutePosition.Y) / s) + tabsHolder.CanvasPosition.Y
			local bottom = top + (item.AbsoluteSize.Y / s)
			local pos = tabsHolder.CanvasPosition.Y
			if top < (pos + 6) then
				scrollTabsTo(top - 6)
			elseif bottom > (pos + view - 6) then
				scrollTabsTo(bottom - view + 6)
			end
		end)
	end
	function windowFunctions:ReplaceTabSliderInstant()
		updateTabScroll()
	end
	-- page transition: the new tab's content glides in from the side the tab was picked on
	local function slideHolderIn(holder, travel)
		if not holder then
			return
		end
		if windowFunctions.holderTween then
			windowFunctions.holderTween:Cancel()
			windowFunctions.holderTween = nil
		end
		holder.Position = UDim2.new(0.06, 0, 0, 0)
		holder.Visible = true
		local glide = tweenService:Create(holder, TweenInfo.new(0.42, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Position = UDim2.new(0, 0, 0, 0)
		})
		windowFunctions.holderTween = glide
		glide:Play()
	end
	library.signals[1 + #library.signals] = tabsHolder:GetPropertyChangedSignal("CanvasPosition"):Connect(updateTabScroll)
	library.signals[1 + #library.signals] = tabsHolder:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(updateTabScroll)
	library.signals[1 + #library.signals] = tabsHolder:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateTabScroll)
	library.signals[1 + #library.signals] = tabArrowLeft.MouseButton1Click:Connect(function()
		local _, view = tabMetrics()
		scrollTabsTo(tabsHolder.CanvasPosition.X - math.max(view * 0.6, 90))
	end)
	library.signals[1 + #library.signals] = tabArrowRight.MouseButton1Click:Connect(function()
		local _, view = tabMetrics()
		scrollTabsTo(tabsHolder.CanvasPosition.X + math.max(view * 0.6, 90))
	end)
	library.signals[1 + #library.signals] = main:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		task.delay(0.05, function()
			if __runscript then
				updateTabScroll()
			end
		end)
	end)

	-- =====================================================================
	--  Landing page (big card) + sub tabs MAIN / PLAYER / SETTING + left sidebar
	--    CreateTab({Name = "Farm", Category = "MAIN"})        -- "MAIN", "PLAYER" or "SETTING"
	--    tabs without a Category are sorted by name (player / esp / teleport / misc -> PLAYER,
	--    config / theme / setting -> SETTING, everything else -> MAIN); the built in Settings tab is SETTING
	--    CreateWindow options: Home = false (skip the landing page), HeroTitle, HeroName, HeroVersion,
	--                          Links = {Discord = "...", YouTube = "...", Website = "..."}  (tap = copy link)
	--    windowFunctions:ShowHome() / windowFunctions:OpenCategory("PLAYER")
	-- =====================================================================
	local CATEGORIES = {"MAIN", "PLAYER", "SETTING"}
	local CAT_INFO = {
		MAIN = {icon = "controller", desc = "Farm, combat and the core features of the script"},
		PLAYER = {icon = "user", desc = "Speed, jump, fly, ESP and everything about you"},
		SETTING = {icon = "settings", desc = "Theme, config and tools for the hub"}
	}
	windowFunctions.category = nil
	windowFunctions.lastInCat = {}
	local navRow, homeFrame, sidebarTitle, emptyLabel, heroPanel, cardsRow, heroDesc, heroChevrons, socialHint
	local navButtons, cardRefs = {}, {}
	local function normCat(c)
		if c == nil then
			return nil
		end
		c = string.upper(tostring(c))
		if c == "SETTINGS" then
			c = "SETTING"
		end
		if (c == "MAIN") or (c == "PLAYER") or (c == "SETTING") then
			return c
		end
		return nil
	end
	local function resolveCategory(opts, name)
		if opts.LastTab then
			return "SETTING"
		end
		local c = normCat(opts.Category or opts.Group or opts.Page)
		if c then
			return c
		end
		local n = string.lower(tostring(name or ""))
		for _, kw in ipairs({"setting", "config", "theme", "credit"}) do
			if string.find(n, kw, 1, true) then
				return "SETTING"
			end
		end
		for _, kw in ipairs({"player", "character", "avatar", "esp", "visual", "teleport", "movement", "misc", "local", "fly", "speed", "camera"}) do
			if string.find(n, kw, 1, true) then
				return "PLAYER"
			end
		end
		return "MAIN"
	end
	local function mkCorner(parent, r, isScale)
		local c = Instance_new("UICorner")
		c.CornerRadius = isScale and UDim.new(r, 0) or UDim.new(0, r)
		c.Parent = parent
		return c
	end
	local function mkStroke(parent, thick, colorName, transp)
		local s = Instance_new("UIStroke")
		s.Thickness = thick
		s.Color = library.colors[colorName]
		colored[1 + #colored] = {s, "Color", colorName}
		s.Transparency = transp or 0
		s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		s.Parent = parent
		return s
	end
	local function mkFrame(parent, size, pos, color, transp, z)
		local f = Instance_new("Frame")
		f.BorderSizePixel = 0
		f.Size = size
		f.Position = pos or UDim2.new()
		if color then
			f.BackgroundColor3 = color
			f.BackgroundTransparency = transp or 0
		else
			f.BackgroundTransparency = 1
		end
		f.ZIndex = z or 3
		f.Parent = parent
		return f
	end
	local function mkText(parent, text, size, font, color, z)
		local l = Instance_new("TextLabel")
		l.BackgroundTransparency = 1
		l.BorderSizePixel = 0
		l.Text = text
		l.TextSize = size
		l.Font = font
		l.TextColor3 = color
		l.TextXAlignment = Enum.TextXAlignment.Left
		l.ZIndex = z or 4
		l.Parent = parent
		return l
	end
	local function mkTrackedText(parent, text, size, font, colorName, z)
		local l = mkText(parent, text, size, font, library.colors[colorName], z)
		colored[1 + #colored] = {l, "TextColor3", colorName}
		return l
	end
	local function mkGradient(parent, c0, c1, rot)
		local g = Instance_new("UIGradient")
		g.Color = ColorSequence.new(c0, c1)
		g.Rotation = rot or 0
		g.Parent = parent
		return g
	end
	local function mkAspect(parent, ratio, fit)
		local a = Instance_new("UIAspectRatioConstraint")
		a.AspectRatio = ratio
		if fit then
			a.AspectType = Enum.AspectType.FitWithinMaxSize
		end
		a.Parent = parent
		return a
	end

	-- ---------- sub tab row ----------
	navRow = mkFrame(innerMain, UDim2.new(1, 0, 0, TAB_ROW_H), UDim2.fromOffset(0, TOP_H), nil, nil, 3)
	navRow.Name = "navRow"
	topbar.navRow = navRow
	do
		local navDivider = mkFrame(navRow, UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, 1, -1), library.colors.innerBorder, 0.35, 2)
		colored[1 + #colored] = {navDivider, "BackgroundColor3", "innerBorder"}
		local navList = mkFrame(navRow, UDim2.fromOffset((#CATEGORIES * 104) + ((#CATEGORIES - 1) * 8), 32), UDim2.new(0.5, 0, 0.5, 0), nil, nil, 3)
		navList.AnchorPoint = Vector2Half
		navList.Name = "navList"
		local navLayout = Instance_new("UIListLayout")
		navLayout.FillDirection = Enum.FillDirection.Horizontal
		navLayout.SortOrder = Enum.SortOrder.LayoutOrder
		navLayout.Padding = UDim.new(0, 8)
		navLayout.Parent = navList
		for i, cat in ipairs(CATEGORIES) do
			local btn = Instance_new("TextButton")
			btn.Name = "nav" .. cat
			btn.AutoButtonColor = false
			btn.BackgroundColor3 = library.colors.hoveredOptionTop
			colored[1 + #colored] = {btn, "BackgroundColor3", "hoveredOptionTop"}
			btn.BackgroundTransparency = 1
			btn.BorderSizePixel = 0
			btn.Font = Enum.Font.GothamBold
			btn.Text = ""
			btn.TextSize = 12
			btn.TextXAlignment = Enum.TextXAlignment.Left
			btn.Size = UDim2.fromOffset(104, 32)
			btn.LayoutOrder = i
			btn.ZIndex = 4
			btn.Parent = navList
			mkCorner(btn, 8)
			-- label is its own TextLabel (no UIPadding on the button: padding also shifted the icon and made it overlap the text)
			local lbl = Instance_new("TextLabel")
			lbl.Name = "navLabel"
			lbl.BackgroundTransparency = 1
			lbl.BorderSizePixel = 0
			lbl.Font = Enum.Font.GothamBold
			lbl.Text = cat
			lbl.TextSize = 12
			lbl.TextXAlignment = Enum.TextXAlignment.Left
			lbl.Position = UDim2.fromOffset(38, 0)
			lbl.Size = UDim2.new(1, -38, 1, 0)
			lbl.ZIndex = 5
			lbl.Parent = btn
			local txtEntry = {lbl, "TextColor3", "tabText", 1.6}
			colored[1 + #colored] = txtEntry
			lbl.TextColor3 = darkenColor(library.colors.tabText, 1.6)
			local holder, iconEntries = library.subs.CreateIcon(btn, CAT_INFO[cat].icon, {Size = 16, ColorKey = "tabText", ZIndex = 6, Thickness = 2})
			iconEntries = iconEntries or {}
			if holder then
				holder.AnchorPoint = Vector2.new(0, 0.5)
				holder.Position = UDim2.new(0, 13, 0.5, 0)
			end
			for _, e in ipairs(iconEntries) do
				e[4] = 1.6
				e[1][e[2]] = darkenColor(library.colors.tabText, 1.6)
			end
			local line = Instance_new("Frame")
			line.Name = "underline"
			line.AnchorPoint = Vector2.new(0.5, 1)
			line.BackgroundColor3 = library.colors.main
			colored[1 + #colored] = {line, "BackgroundColor3", "main"}
			line.BorderSizePixel = 0
			line.Position = UDim2.new(0.5, 0, 1, 3)
			line.Size = UDim2.new(0, 0, 0, 2)
			line.ZIndex = 5
			line.Parent = btn
			mkCorner(line, 1)
			navButtons[cat] = {btn = btn, lbl = lbl, txt = txtEntry, icons = iconEntries, line = line}
			library.signals[1 + #library.signals] = btn.MouseEnter:Connect(function()
				if windowFunctions.category ~= cat then
					tweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.6}):Play()
				end
			end)
			library.signals[1 + #library.signals] = btn.MouseLeave:Connect(function()
				tweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
			end)
			library.signals[1 + #library.signals] = btn.MouseButton1Click:Connect(function()
				windowFunctions.SwitchCategory(cat)
			end)
		end
	end
	local function paintNav(active)
		local info = TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		for cat, nb in next, navButtons do
			local on = cat == active
			local key = (on and "main") or "tabText"
			local fac = (not on) and 1.6 or nil
			nb.txt[3] = key
			nb.txt[4] = fac
			tweenService:Create(nb.lbl, info, {TextColor3 = darkenColor(library.colors[key], fac)}):Play()
			for _, e in ipairs(nb.icons) do
				e[3] = key
				e[4] = fac
				tweenService:Create(e[1], info, {[e[2]] = darkenColor(library.colors[key], fac)}):Play()
			end
			tweenService:Create(nb.line, info, {Size = UDim2.new(on and 1 or 0, on and -24 or 0, 0, 2)}):Play()
			if on then
				tweenService:Create(nb.btn, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
			end
		end
	end

	-- ---------- sidebar title + empty page text ----------
	sidebarTitle = mkText(tabsHolder, "", 10, Enum.Font.GothamBold, library.colors.otherElementText, 4)
	colored[1 + #colored] = {sidebarTitle, "TextColor3", "otherElementText"}
	sidebarTitle.Name = "sidebarTitle"
	sidebarTitle.LayoutOrder = 0
	sidebarTitle.Size = UDim2.new(1, 0, 0, 22)
	do
		local tp = Instance_new("UIPadding")
		tp.PaddingLeft = UDim.new(0, 6)
		tp.Parent = sidebarTitle
	end
	topbar.filter = ""
	do
		local sideSearch = mkFrame(tabsHolder, UDim2.new(1, -4, 0, 30), nil, library.colors.unselectedOption, 0, 4)
		sideSearch.Name = "sideSearch"
		sideSearch.LayoutOrder = 1
		colored[1 + #colored] = {sideSearch, "BackgroundColor3", "unselectedOption"}
		mkCorner(sideSearch, 10)
		mkStroke(sideSearch, 1, "innerBorder", 0.45)
		local sIcon = library.subs.CreateIcon(sideSearch, "search", {Size = 13, ColorKey = "otherElementText", ZIndex = 6, Thickness = 2})
		if sIcon then
			sIcon.AnchorPoint = Vector2.new(0, 0.5)
			sIcon.Position = UDim2.new(0, 10, 0.5, 0)
		end
		local sBox = Instance_new("TextBox")
		sBox.Name = "sideSearchBox"
		sBox.BackgroundTransparency = 1
		sBox.BorderSizePixel = 0
		sBox.ClearTextOnFocus = false
		sBox.Font = Enum.Font.Gotham
		sBox.PlaceholderText = "Search..."
		sBox.PlaceholderColor3 = library.colors.otherElementText
		sBox.Text = ""
		sBox.TextColor3 = library.colors.elementText
		colored[1 + #colored] = {sBox, "TextColor3", "elementText"}
		sBox.TextSize = 11
		sBox.TextXAlignment = Enum.TextXAlignment.Left
		sBox.Position = UDim2.fromOffset(30, 0)
		sBox.Size = UDim2.new(1, -36, 1, 0)
		sBox.ZIndex = 6
		sBox.Parent = sideSearch
		library.signals[1 + #library.signals] = sBox:GetPropertyChangedSignal("Text"):Connect(function()
			topbar.filter = string.lower(sBox.Text or "")
			windowFunctions.RefreshSidebar()
		end)
	end
	emptyLabel = mkText(innerMainHolder, "No tabs in this section yet", 13, Enum.Font.GothamMedium, library.colors.otherElementText, 2)
	colored[1 + #colored] = {emptyLabel, "TextColor3", "otherElementText"}
	emptyLabel.Name = "emptyLabel"
	emptyLabel.Size = UDim2.fromScale(1, 1)
	emptyLabel.TextXAlignment = Enum.TextXAlignment.Center
	emptyLabel.Visible = false

	-- ---------- landing page ----------
	homeFrame = mkFrame(innerMain, UDim2.new(1, 0, 1, -HEADER_HEIGHT), UDim2.fromOffset(0, HEADER_HEIGHT), nil, nil, 2)
	homeFrame.Name = "homeFrame"
	homeFrame.ClipsDescendants = true
	topbar.homeFrame = homeFrame

	local heroTitleText = string.upper((tostring(options.HeroTitle or "QuickX"):match("%S+")) or "QUICKX")
	local heroName = tostring(options.HeroName or "QuickX Hub")
	if not string.find(string.upper(heroName), "HUB", 1, true) then
		heroName = heroName .. " Hub"
	end
	local heroVersion = string.upper(tostring(options.HeroVersion or options.Version or "V1.0"))

	heroPanel = mkFrame(homeFrame, UDim2.new(1, -28, 0, 200), UDim2.fromOffset(14, 6), Color3.fromRGB(6, 18, 12), 0, 3)
	heroPanel.Name = "heroPanel"
	heroPanel.ClipsDescendants = true
	mkCorner(heroPanel, 14)
	mkGradient(heroPanel, Color3.fromRGB(5, 30, 20), Color3.fromRGB(3, 10, 7), 20)
	mkStroke(heroPanel, 1.4, "main", 0.55)
	-- ===== QuickX banner: neon streaks + big glowing title + logo =====
	do
		-- diagonal neon streaks
		local streakHolder = mkFrame(heroPanel, UDim2.new(1, 0, 1, 0), nil, nil, nil, 3)
		streakHolder.Name = "streaks"
		streakHolder.ClipsDescendants = true
		local streakDefs = {
			-- x scale, width, transparency, speed
			{0.02, 3, 0.05, 4.0}, {0.10, 1, 0.55, 5.0}, {0.30, 1, 0.7, 6.0}, {0.47, 2, 0.45, 4.6},
			{0.62, 1, 0.6, 5.4}, {0.78, 3, 0.1, 4.2}, {0.88, 1, 0.5, 6.2}, {0.97, 2, 0.2, 3.8}
		}
		for i, d in ipairs(streakDefs) do
			local st = mkFrame(streakHolder, UDim2.new(0, d[2], 2.2, 0), UDim2.new(d[1], 0, 0.5, 0), library.colors.main, d[3], 3)
			st.Name = "streak" .. i
			st.AnchorPoint = Vector2Half
			st.Rotation = 35
			colored[1 + #colored] = {st, "BackgroundColor3", "main"}
			local sgd = Instance_new("UIGradient")
			sgd.Rotation = 90
			sgd.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.35, 0),
				NumberSequenceKeypoint.new(0.65, 0),
				NumberSequenceKeypoint.new(1, 1)
			})
			sgd.Parent = st
			tweenService:Create(st, TweenInfo.new(d[4], Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
				BackgroundTransparency = math.min(d[3] + 0.4, 0.95),
				Position = UDim2.new(d[1] + 0.02, 0, 0.5, 0)
			}):Play()
		end
	end

	-- left: title + tagline + socials
	local heroLeft = mkFrame(heroPanel, UDim2.new(0.62, -10, 1, 0), UDim2.fromOffset(20, 0), nil, nil, 5)
	heroLeft.Name = "heroLeft"
	do
		local ll = Instance_new("UIListLayout")
		ll.SortOrder = Enum.SortOrder.LayoutOrder
		ll.VerticalAlignment = Enum.VerticalAlignment.Center
		ll.Padding = UDim.new(0, 4)
		ll.Parent = heroLeft
		heroChevrons = mkText(heroLeft, '<font color="#26eb78">&gt;&gt;</font> <font color="#ffffff">&gt;&gt;</font> <font color="#26eb78">&gt;&gt;</font> <font color="#ffffff">&gt;&gt;</font>', 11, Enum.Font.GothamBlack, Color3.new(1, 1, 1), 5)
		heroChevrons.RichText = true
		heroChevrons.LayoutOrder = 1
		heroChevrons.Size = UDim2.new(1, 0, 0, 14)
		local titleLbl = mkText(heroLeft, heroName, 34, Enum.Font.GothamBlack, Color3.new(1, 1, 1), 5)
		titleLbl.Name = "heroTitle"
		titleLbl.LayoutOrder = 2
		titleLbl.Size = UDim2.new(1, 0, 0, 46)
		titleLbl.TextScaled = true
		local tcon = Instance_new("UITextSizeConstraint")
		tcon.MaxTextSize = 38
		tcon.MinTextSize = 12
		tcon.Parent = titleLbl
		local tgrad = Instance_new("UIGradient")
		tgrad.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(110, 255, 170))
		tgrad.Rotation = 90
		tgrad.Parent = titleLbl
		local tglow = Instance_new("UIStroke")
		tglow.Color = library.colors.main
		colored[1 + #colored] = {tglow, "Color", "main"}
		tglow.Thickness = 2.2
		tglow.Transparency = 0.72
		tglow.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
		tglow.Parent = titleLbl
		tweenService:Create(tglow, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Transparency = 0.9}):Play()
		heroDesc = mkTrackedText(heroLeft, "Smooth  -  Fast  -  Clean.  Built by QuickX for the best experience.", 10, Enum.Font.Gotham, "otherElementText", 5)
		heroDesc.LayoutOrder = 5
		heroDesc.Size = UDim2.new(1, -4, 0, 28)
		heroDesc.TextWrapped = true
		heroDesc.TextYAlignment = Enum.TextYAlignment.Top
		local socials = mkFrame(heroLeft, UDim2.new(1, 0, 0, 28), nil, nil, nil, 5)
		socials.LayoutOrder = 6
		local sl = Instance_new("UIListLayout")
		sl.FillDirection = Enum.FillDirection.Horizontal
		sl.VerticalAlignment = Enum.VerticalAlignment.Center
		sl.Padding = UDim.new(0, 8)
		sl.SortOrder = Enum.SortOrder.LayoutOrder
		sl.Parent = socials
		local links = (type(options.Links) == "table" and options.Links) or {}
		local socialDefs = {
			{icon = "discord", url = links.Discord or options.Discord},
			{icon = "play", url = links.YouTube or options.YouTube},
			{icon = "globe", url = links.Website or links.TikTok or options.Website}
		}
		for i, def in ipairs(socialDefs) do
			local sb = Instance_new("TextButton")
			sb.AutoButtonColor = false
			sb.Text = ""
			sb.BackgroundColor3 = library.colors.main
			colored[1 + #colored] = {sb, "BackgroundColor3", "main"}
			sb.BackgroundTransparency = 0.82
			sb.BorderSizePixel = 0
			sb.Size = UDim2.fromOffset(26, 26)
			sb.LayoutOrder = i
			sb.ZIndex = 5
			sb.Parent = socials
			mkCorner(sb, 1, true)
			mkStroke(sb, 1.4, "main", 0.2)
			local ic = library.subs.CreateIcon(sb, def.icon, {Size = 14, ColorKey = "main", ZIndex = 7, Thickness = 2.2})
			if ic then
				ic.AnchorPoint = Vector2Half
				ic.Position = UDim2.new(0.5, 0, 0.5, 0)
			end
			library.signals[1 + #library.signals] = sb.MouseEnter:Connect(function()
				tweenService:Create(sb, TweenInfo.new(0.15), {BackgroundTransparency = 0.5}):Play()
			end)
			library.signals[1 + #library.signals] = sb.MouseLeave:Connect(function()
				tweenService:Create(sb, TweenInfo.new(0.15), {BackgroundTransparency = 0.82}):Play()
			end)
			library.signals[1 + #library.signals] = sb.MouseButton1Click:Connect(function()
				if def.url then
					pcall(function()
						setclipboard(tostring(def.url))
					end)
					if socialHint then
						socialHint.Text = "Link copied!"
						task.delay(1.6, function()
							if socialHint and socialHint.Parent then
								socialHint.Text = ""
							end
						end)
					end
				end
			end)
		end
		socialHint = mkTrackedText(socials, "", 10, Enum.Font.GothamMedium, "main", 5)
		socialHint.LayoutOrder = 9
		socialHint.Size = UDim2.fromOffset(70, 26)
	end

	-- right: logo with glow + spinning ring
	local artHolder = mkFrame(heroPanel, UDim2.new(0.38, -8, 1, 0), UDim2.new(0.62, 0, 0, 0), nil, nil, 4)
	artHolder.Name = "artHolder"
	do
		local logoId = options.HeroLogo or "rbxassetid://132029940467197"
		if type(logoId) == "number" then
			logoId = "rbxassetid://" .. tostring(logoId)
		end
		local center = mkFrame(artHolder, UDim2.new(1, 0, 1, 0), UDim2.new(0.5, 0, 0.5, 0), nil, nil, 4)
		center.AnchorPoint = Vector2Half
		local glow1 = mkFrame(center, UDim2.new(0.95, 0, 0.95, 0), UDim2.new(0.5, 0, 0.5, 0), library.colors.main, 0.86, 4)
		glow1.AnchorPoint = Vector2Half
		colored[1 + #colored] = {glow1, "BackgroundColor3", "main"}
		mkAspect(glow1, 1)
		mkCorner(glow1, 0.5, true)
		local glow2 = mkFrame(center, UDim2.new(0.6, 0, 0.6, 0), UDim2.new(0.5, 0, 0.5, 0), library.colors.main, 0.78, 4)
		glow2.AnchorPoint = Vector2Half
		colored[1 + #colored] = {glow2, "BackgroundColor3", "main"}
		mkAspect(glow2, 1)
		mkCorner(glow2, 0.5, true)
		tweenService:Create(glow1, TweenInfo.new(2.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {BackgroundTransparency = 0.74}):Play()
		tweenService:Create(glow2, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {BackgroundTransparency = 0.9}):Play()
		local ring = mkFrame(center, UDim2.new(0.82, 0, 0.82, 0), UDim2.new(0.5, 0, 0.5, 0), nil, nil, 6)
		ring.Name = "logoRing"
		ring.AnchorPoint = Vector2Half
		mkAspect(ring, 1)
		mkCorner(ring, 0.5, true)
		local ringStroke = mkStroke(ring, 2, "main", 0)
		local ringGrad = Instance_new("UIGradient")
		ringGrad.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.5, 1),
			NumberSequenceKeypoint.new(1, 0)
		})
		ringGrad.Parent = ringStroke
		tweenService:Create(ringGrad, TweenInfo.new(3.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {Rotation = 360}):Play()
		local logo = Instance_new("ImageLabel")
		logo.Name = "quickxLogo"
		logo.BackgroundTransparency = 1
		logo.BorderSizePixel = 0
		logo.Image = logoId
		logo.ScaleType = Enum.ScaleType.Fit
		logo.AnchorPoint = Vector2Half
		logo.Position = UDim2.new(0.5, 0, 0.5, 0)
		logo.Size = UDim2.new(0.66, 0, 0.66, 0)
		logo.ZIndex = 8
		logo.Parent = center
		mkAspect(logo, 1)
		tweenService:Create(logo, TweenInfo.new(2.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
			Position = UDim2.new(0.5, 0, 0.46, 0)
		}):Play()
		-- version pill (top right)
		local pill = mkFrame(heroPanel, UDim2.fromOffset(74, 20), UDim2.new(1, -12, 0, 10), library.colors.main, 0.8, 9)
		pill.AnchorPoint = Vector2.new(1, 0)
		colored[1 + #colored] = {pill, "BackgroundColor3", "main"}
		mkCorner(pill, 10)
		mkStroke(pill, 1.2, "main", 0.2)
		local pt = mkTrackedText(pill, "UPDATE " .. heroVersion, 9, Enum.Font.GothamBlack, "main", 10)
		pt.Size = UDim2.new(1, 0, 1, 0)
		pt.TextXAlignment = Enum.TextXAlignment.Center
	end

	-- cards at the bottom: MAIN / PLAYER / SETTING
	cardsRow = mkFrame(homeFrame, UDim2.new(1, -28, 0, 84), UDim2.new(0, 14, 1, -12), nil, nil, 3)
	cardsRow.Name = "cardsRow"
	cardsRow.AnchorPoint = Vector2.new(0, 1)
	for i, cat in ipairs(CATEGORIES) do
		local card = Instance_new("TextButton")
		card.Name = "card" .. cat
		card.AutoButtonColor = false
		card.Text = ""
		card.BackgroundColor3 = Color3.fromRGB(15, 23, 18)
		card.BorderSizePixel = 0
		card.Size = UDim2.new(1 / #CATEGORIES, -7, 1, 0)
		card.Position = UDim2.new((i - 1) / #CATEGORIES, (i - 1) * 3, 0, 0)
		card.ZIndex = 4
		card.Parent = cardsRow
		mkCorner(card, 12)
		mkGradient(card, Color3.fromRGB(255, 255, 255), Color3.fromRGB(120, 150, 132), 0)
		local cstroke = mkStroke(card, 1.5, "main", 0.4)
		local cscale = Instance_new("UIScale")
		cscale.Parent = card
		local ctitle = mkText(card, cat, 17, Enum.Font.GothamBlack, Color3.new(1, 1, 1), 6)
		ctitle.Position = UDim2.fromOffset(14, 8)
		ctitle.Size = UDim2.new(0.62, 0, 0, 22)
		local cdesc = mkTrackedText(card, CAT_INFO[cat].desc, 9, Enum.Font.Gotham, "otherElementText", 6)
		cdesc.Position = UDim2.fromOffset(14, 31)
		cdesc.Size = UDim2.new(0.62, 0, 0, 24)
		cdesc.TextWrapped = true
		cdesc.TextYAlignment = Enum.TextYAlignment.Top
		local ccount = mkTrackedText(card, "0 TABS", 9, Enum.Font.GothamBold, "main", 6)
		ccount.AnchorPoint = Vector2.new(0, 1)
		ccount.Position = UDim2.new(0, 14, 1, -8)
		ccount.Size = UDim2.new(0.62, 0, 0, 12)
		local cicon = library.subs.CreateIcon(card, CAT_INFO[cat].icon, {Size = 34, ColorKey = "main", ZIndex = 7, Thickness = 2.6})
		if cicon then
			cicon.AnchorPoint = Vector2.new(1, 0.5)
			cicon.Position = UDim2.new(1, -16, 0.5, 0)
		end
		cardRefs[cat] = {card = card, desc = cdesc, count = ccount}
		library.signals[1 + #library.signals] = card.MouseEnter:Connect(function()
			tweenService:Create(cscale, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Scale = 1.03}):Play()
			tweenService:Create(cstroke, TweenInfo.new(0.18), {Transparency = 0, Thickness = 2}):Play()
		end)
		library.signals[1 + #library.signals] = card.MouseLeave:Connect(function()
			tweenService:Create(cscale, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Scale = 1}):Play()
			tweenService:Create(cstroke, TweenInfo.new(0.18), {Transparency = 0.4, Thickness = 1.5}):Play()
		end)
		library.signals[1 + #library.signals] = card.MouseButton1Down:Connect(function()
			tweenService:Create(cscale, TweenInfo.new(0.08), {Scale = 0.97}):Play()
		end)
		library.signals[1 + #library.signals] = card.MouseButton1Click:Connect(function()
			tweenService:Create(cscale, TweenInfo.new(0.12), {Scale = 1}):Play()
			windowFunctions.SwitchCategory(cat)
		end)
	end

	-- landing page adapts to the window height
	local function layoutHome()
		local s = guiScale()
		local h = homeFrame.AbsoluteSize.Y / s
		if h < 40 then
			return
		end
		local cardH = math.clamp(math.floor(h * 0.3), 64, 100)
		cardsRow.Size = UDim2.new(1, -28, 0, cardH)
		local heroH = math.max(h - cardH - 12 - 6 - 10, 90)
		heroPanel.Size = UDim2.new(1, -28, 0, heroH)
		for _, r in next, cardRefs do
			r.desc.Visible = cardH >= 78
		end
		heroDesc.Visible = heroH >= 196
		heroChevrons.Visible = heroH >= 150
	end
	library.signals[1 + #library.signals] = homeFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(layoutHome)
	task.defer(layoutHome)

	-- ---------- page / category switching ----------
	function windowFunctions.RefreshSidebar()
		if (topbar.page == "app") and (not windowFunctions.category) and topbar.tabs[1] then
			windowFunctions.category = topbar.tabs[1].Category
			paintNav(windowFunctions.category)
		end
		local cat = windowFunctions.category
		local counts = {MAIN = 0, PLAYER = 0, SETTING = 0}
		for _, entry in ipairs(topbar.tabs) do
			if entry.Category then
				counts[entry.Category] = (counts[entry.Category] or 0) + 1
			end
		end
		local shown = 0
		for _, entry in ipairs(topbar.tabs) do
			local vis = (topbar.page == "app") and (entry.Category == cat)
			if vis and topbar.filter and (topbar.filter ~= "") then
				vis = string.find(string.lower(tostring(entry.Name)), topbar.filter, 1, true) ~= nil
			end
			if entry.Wrap then
				entry.Wrap.Visible = vis
			end
			if vis then
				shown = shown + 1
			end
		end
		sidebarTitle.Text = string.upper(tostring(cat or "")) .. "   -   " .. tostring(counts[cat or "MAIN"] or 0)
		emptyLabel.Visible = (topbar.page == "app") and (shown == 0)
		for c, r in next, cardRefs do
			local n = counts[c] or 0
			r.count.Text = tostring(n) .. ((n == 1) and " TAB" or " TABS")
		end
	end
	function windowFunctions.SwitchCategory(cat, noSelect)
		cat = normCat(cat)
		if not cat then
			return
		end
		windowFunctions.category = cat
		topbar.page = "app"
		topbar.minimized = false
		paintNav(cat)
		topbar.apply()
		windowFunctions.RefreshSidebar()
		if noSelect then
			return
		end
		local target = windowFunctions.lastInCat[cat]
		if not target then
			for _, entry in ipairs(topbar.tabs) do
				if entry.Category == cat then
					target = entry
					break
				end
			end
		end
		if target then
			target.Go()
		else
			local sel = windowFunctions.selected
			if sel.deactivate then
				pcall(sel.deactivate, 0)
			end
			if sel.holder then
				sel.holder.Visible = false
			end
			sel.button, sel.holder, sel.deactivate = nil, nil, nil
			topbar.setCrumb(cat)
		end
	end
	function windowFunctions.ShowHome()
		topbar.page = "home"
		topbar.minimized = false
		windowFunctions.category = nil
		paintNav(nil)
		topbar.setCrumb("Home")
		topbar.apply()
		windowFunctions.RefreshSidebar()
		homeFrame.Position = UDim2.fromOffset(0, HEADER_HEIGHT + 14)
		tweenService:Create(homeFrame, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Position = UDim2.fromOffset(0, HEADER_HEIGHT)
		}):Play()
	end
	windowFunctions.OpenCategory = windowFunctions.SwitchCategory
	topbar.goHome = windowFunctions.ShowHome
	if options.Home == false then
		topbar.page = "app"
	end
	paintNav(nil)
	topbar.apply()
	windowFunctions.RefreshSidebar()
	windowFunctions.LastTab = nil
	function windowFunctions:CreateTab(options, ...)
		options = (options and (type(options) == "string") and resolvevararg("Tab", options, ...)) or options or {
			Name = "Pepsi Style: Elite Lego Hax"
		}
		local image = options.Image
		local iconEntry
		do
			local want = options.Icon
			if want == nil then
				want = image
			end
			if want ~= nil then
				iconEntry = library.subs.GetIcon(want)
				if iconEntry then
					if iconEntry.asset then
						image = iconEntry.asset
						iconEntry = nil
					else
						image = nil
					end
				elseif (options.Icon ~= nil) and (image == nil) then
					image = options.Icon
				end
			end
		end
		if image then
			image = resolveid(image)
		end
		local hadTabName = options.Name ~= nil
		local tabName = options.Name or ((options.LastTab and "Settings") or "Unnamed Tab")
		local TAB_PILL_SIZE = UDim2.new(1, -4, 0, 36)
		local tabCategory = resolveCategory(options, tabName)
		local tabEntry
		if (not iconEntry) and (not image) then
			-- no icon given: try the tab name (or its first word) as an icon name, else a plain grid icon
			local lname = string.lower(tostring(tabName))
			iconEntry = library.subs.GetIcon(lname) or library.subs.GetIcon((lname:match("%a+") or "")) or library.subs.GetIcon("grid")
		end
		options.Name = tabName
		local crumbName = ((not hadTabName) and options.LastTab and "Settings") or tabName
		windowFunctions.tabCount = windowFunctions.tabCount + 1
		local newTab = Instance_new("TextButton")
		local newTabHolder = Instance_new("Frame")
		library.globals["__Window" .. windowName].newTabHolder = newTabHolder
		local left = Instance_new("ScrollingFrame")
		local leftList = Instance_new("UIListLayout")
		local leftPadding = Instance_new("UIPadding")
		local right = Instance_new("ScrollingFrame")
		local rightList = Instance_new("UIListLayout")
		local rightPadding = Instance_new("UIPadding")
		newTab.Name = removeSpaces((tabName and tostring(tabName):lower() or "???") .. "Tab")
		local tabWrap = Instance_new("Frame")
		local tabBase = Instance_new("Frame")
		local tabBaseCorner = Instance_new("UICorner")
		local tabFill = Instance_new("Frame")
		local tabFillCorner = Instance_new("UICorner")
		local tabFillStroke = Instance_new("UIStroke")
		local tabShine = Instance_new("Frame")
		local tabShineCorner = Instance_new("UICorner")
		local tabShineGradient = Instance_new("UIGradient")
		local tabIsFirst = windowFunctions.tabCount == 1
		tabWrap.Name = newTab.Name .. "Pill"
		tabWrap.Parent = tabsHolder
		tabWrap.BackgroundTransparency = 1
		tabWrap.BorderSizePixel = 0
		tabWrap.LayoutOrder = (options.LastTab and 99999) or tonumber(options.TabOrder or options.LayoutOrder) or (2 + windowFunctions.tabCount)
		tabWrap.Size = TAB_PILL_SIZE
		tabWrap.Visible = false
		newTab.Parent = tabWrap
		newTab.AutoButtonColor = false
		newTab.BorderSizePixel = 0
		newTab.BackgroundTransparency = 1
		newTab.LayoutOrder = tabWrap.LayoutOrder
		newTab.Position = UDim2.fromOffset(0, 0)
		newTab.Size = UDim2.fromScale(1, 1)
		newTab.ZIndex = 4
		-- layer 1: grey pill
		tabBase.Name = "base"
		tabBase.Parent = tabWrap
		tabBase.BackgroundColor3 = library.colors.selectedOption
		colored[1 + #colored] = {tabBase, "BackgroundColor3", "selectedOption"}
		tabBase.BorderSizePixel = 0
		tabBase.Size = UDim2.fromScale(1, 1)
		tabBase.ZIndex = 1
		tabBase.BackgroundTransparency = 1
		tabBaseCorner.CornerRadius = UDim.new(0, 10)
		tabBaseCorner.Parent = tabBase
		-- layer 2: red fill that wipes in / out, with a soft glow and a glossy top edge
		tabFill.Name = "fill"
		tabFill.Parent = tabWrap
		tabFill.AnchorPoint = Vector2.new(0, 0)
		tabFill.BackgroundColor3 = library.colors.main
		colored[1 + #colored] = {tabFill, "BackgroundColor3", "main"}
		tabFill.BorderSizePixel = 0
		tabFill.BackgroundTransparency = 0.84
		tabFill.Position = UDim2.fromScale(0, 0)
		tabFill.Size = UDim2.new((tabIsFirst and 1) or 0, 0, 1, 0)
		tabFill.ZIndex = 2
		tabFillCorner.CornerRadius = UDim.new(0, 10)
		tabFillCorner.Parent = tabFill
		tabFillStroke.Color = library.colors.main
		colored[1 + #colored] = {tabFillStroke, "Color", "main"}
		tabFillStroke.Thickness = 1
		tabFillStroke.Transparency = (tabIsFirst and 0.6) or 1
		tabFillStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		tabFillStroke.Parent = tabFill
		tabShine.Name = "shine"
		tabShine.Parent = tabFill
		tabShine.BackgroundColor3 = Color3.new(1, 1, 1)
		tabShine.BorderSizePixel = 0
		tabShine.Size = UDim2.fromScale(1, 1)
		tabShine.ZIndex = 3
		tabShineCorner.CornerRadius = UDim.new(0, 10)
		tabShine.BackgroundTransparency = 1
		tabShineCorner.Parent = tabShine
		tabShineGradient.Rotation = 90
		tabShineGradient.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.78), NumberSequenceKeypoint.new(0.55, 0.95), NumberSequenceKeypoint.new(1, 1)})
		tabShineGradient.Parent = tabShine
		-- left accent bar (grows in for the active tab)
		local tabBar = Instance_new("Frame")
		tabBar.Name = "accentBar"
		tabBar.Parent = tabWrap
		tabBar.AnchorPoint = Vector2.new(0, 0.5)
		tabBar.BackgroundColor3 = library.colors.main
		colored[1 + #colored] = {tabBar, "BackgroundColor3", "main"}
		tabBar.BorderSizePixel = 0
		tabBar.Position = UDim2.new(0, 2, 0.5, 0)
		tabBar.Size = UDim2.fromOffset(3, (tabIsFirst and 16) or 0)
		tabBar.ZIndex = 5
		do
			local tbc = Instance_new("UICorner")
			tbc.CornerRadius = UDim.new(0, 2)
			tbc.Parent = tabBar
		end
		local colored_newTab_TextColor3 = nil
		local tabIconHolder, tabIconEntries, tabIconScale, tabImage
		do
			local iconSize = tonumber(options.IconSize) or 16
			colored_newTab_TextColor3 = {newTab, "TextColor3", "tabText"}
			colored[1 + #colored] = colored_newTab_TextColor3
			newTab.Font = Enum.Font.GothamBold
			newTab.Text = (tabName and tostring(tabName)) or "???"
			newTab.TextSize = 12
			newTab.TextXAlignment = Enum.TextXAlignment.Left
			newTab.TextTruncate = Enum.TextTruncate.AtEnd
			local textPad = Instance_new("UIPadding")
			textPad.PaddingLeft = UDim.new(0, 14 + iconSize + 9)
			textPad.PaddingRight = UDim.new(0, 8)
			textPad.Parent = newTab
			if not tabIsFirst then
				colored_newTab_TextColor3[4] = 1.35
				newTab.TextColor3 = darkenColor(library.colors.tabText, 1.35)
			else
				newTab.TextColor3 = library.colors.tabText
			end
			if image then
				tabImage = Instance_new("ImageLabel")
				tabImage.Name = "tabImage"
				tabImage.BackgroundTransparency = 1
				tabImage.BorderSizePixel = 0
				tabImage.AnchorPoint = Vector2.new(0, 0.5)
				tabImage.Position = UDim2.new(0, 14, 0.5, 0)
				tabImage.Size = UDim2.fromOffset(iconSize + 2, iconSize + 2)
				tabImage.Image = image
				tabImage.ImageColor3 = options.ImageColor or options.Color or WhiteColor3
				tabImage.ImageTransparency = (tabIsFirst and 0) or 0.4
				tabImage.ScaleType = Enum.ScaleType.Fit
				tabImage.ZIndex = 6
				tabImage.Parent = tabWrap
			elseif iconEntry then
				tabIconHolder, tabIconEntries = library.subs.CreateIcon(tabWrap, iconEntry, {
					Size = iconSize,
					ColorKey = "tabText",
					ZIndex = 6,
					Thickness = options.IconThickness
				})
				tabIconHolder.AnchorPoint = Vector2.new(0, 0.5)
				tabIconHolder.Position = UDim2.new(0, 14, 0.5, 0)
				tabIconScale = Instance_new("UIScale")
				tabIconScale.Scale = (tabIsFirst and 1.14) or 1
				tabIconScale.Parent = tabIconHolder
				if not tabIsFirst then
					for _, e in ipairs(tabIconEntries) do
						e[4] = 1.35
						e[1][e[2]] = darkenColor(library.colors.tabText, 1.35)
					end
				else
					for _, e in ipairs(tabIconEntries) do
						e[3] = "main"
						e[1][e[2]] = library.colors.main
					end
				end
			end
		end
		-- keeps the fill's visible rectangle the same while the side it grows from changes
		local function reanchorFill(ax)
			local w = tabFill.Size.X.Scale
			local x = ax
			if w > 0.001 then
				x = (tabFill.Position.X.Scale - (tabFill.AnchorPoint.X * w)) + (ax * w)
			end
			tabFill.AnchorPoint = Vector2.new(ax, 0)
			tabFill.Position = UDim2.new(x, 0, 0, 0)
		end
		-- travel: +1 when the selection moves to the right, -1 to the left, 0 / nil unknown
		local function setTabState(active, travel)
			travel = travel or 0
			local info = TweenInfo.new(0.34, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			if active then
				reanchorFill((travel > 0 and 0) or (travel < 0 and 1) or 0.5)
			else
				reanchorFill((travel > 0 and 1) or (travel < 0 and 0) or 0.5)
			end
			tweenService:Create(tabFill, info, {
				Size = UDim2.new((active and 1) or 0, 0, 1, 0)
			}):Play()
			tweenService:Create(tabFillStroke, info, {
				Transparency = (active and 0.6) or 1
			}):Play()
			tweenService:Create(tabBase, TweenInfo.new(0.2), {
				BackgroundColor3 = library.colors.selectedOption,
				BackgroundTransparency = 1
			}):Play()
			tweenService:Create(tabBar, info, {
				Size = UDim2.fromOffset(3, (active and 16) or 0)
			}):Play()
			if colored_newTab_TextColor3 then
				colored_newTab_TextColor3[4] = ((not active) and 1.35) or nil
				tweenService:Create(newTab, info, {
					TextColor3 = darkenColor(library.colors.tabText, ((not active) and 1.35) or nil)
				}):Play()
			end
			if tabImage then
				tweenService:Create(tabImage, info, {
					ImageTransparency = (active and 0) or 0.4
				}):Play()
			end
			if tabIconEntries then
				for _, e in ipairs(tabIconEntries) do
					e[4] = ((not active) and 1.35) or nil
					e[3] = (active and "main") or "tabText"
					tweenService:Create(e[1], info, {
						[e[2]] = darkenColor(library.colors[e[3]], e[4])
					}):Play()
				end
				if tabIconScale then
					tweenService:Create(tabIconScale, TweenInfo.new(0.34, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
						Scale = (active and 1.14) or 1
					}):Play()
				end
			end
		end
		library.signals[1 + #library.signals] = newTab.MouseEnter:Connect(function()
			if windowFunctions.selected.button ~= newTab then
				tweenService:Create(tabBase, TweenInfo.new(0.15), {
					BackgroundColor3 = library.colors.hoveredOptionTop,
					BackgroundTransparency = 0.5
				}):Play()
			end
		end)
		library.signals[1 + #library.signals] = newTab.MouseLeave:Connect(function()
			if windowFunctions.selected.button ~= newTab then
				tweenService:Create(tabBase, TweenInfo.new(0.15), {
					BackgroundColor3 = library.colors.selectedOption,
					BackgroundTransparency = 1
				}):Play()
			end
		end)
		local function goto(silent)
			if windowFunctions.CloseDropdown then
				pcall(windowFunctions.CloseDropdown)
				windowFunctions.CloseDropdown = nil
			end
			if (silent ~= true) and ((topbar.page ~= "app") or (windowFunctions.category ~= tabCategory)) then
				windowFunctions.SwitchCategory(tabCategory, true)
			end
			if not library.colorpicker and not submenuOpen and (windowFunctions.selected.button ~= newTab) and newTab.Parent and newTabHolder.Parent then
				pcall(function()
					for _, e in next, library.elements do
						if e and (type(e) == "table") then
							if e.Update then
								pcall(e.Update)
							end
							if e.UpdateAll then
								pcall(e.UpdateAll)
							end
						end
					end
				end)
				local previousButton = windowFunctions.selected.button
				local previousHolder = windowFunctions.selected.holder
				local travel = 1
				if previousButton and previousButton.Parent and (previousButton.AbsolutePosition.Y > newTab.AbsolutePosition.Y) then
					travel = -1
				end
				windowFunctions:MoveTabSlider(newTab)
				if windowFunctions.selected.deactivate then
					pcall(windowFunctions.selected.deactivate, travel)
				end
				if previousHolder then
					previousHolder.Visible = false
					previousHolder.Position = UDim2.new(0, 0, 0, 0)
				end
				windowFunctions.selected.button = newTab
				windowFunctions.selected.holder = newTabHolder
				windowFunctions.selected.deactivate = function(t)
					setTabState(false, t)
				end
				setTabState(true, travel)
				slideHolderIn(newTabHolder, travel)
				windowFunctions.LastTab = colored_newTab_TextColor3
				windowFunctions.lastInCat[tabCategory] = tabEntry
				topbar.setCrumb(crumbName)
			end
		end
		if homepage or (newTab.LayoutOrder > 4) then
		else
			homepage = goto
		end
		library.signals[1 + #library.signals] = newTab.MouseButton1Click:Connect(function()
			goto()
		end)
		tabEntry = {
			Name = tostring(crumbName),
			Go = goto,
			Last = (options.LastTab and true) or false,
			Category = tabCategory,
			Wrap = tabWrap
		}
		topbar.tabs[1 + #topbar.tabs] = tabEntry
		windowFunctions.RefreshSidebar()
		if windowFunctions.tabCount == 1 then
			topbar.setCrumb(crumbName)
			windowFunctions.selected.holder = newTabHolder
			windowFunctions.selected.button = newTab
			windowFunctions.selected.deactivate = function(t)
				setTabState(false, t)
			end
		end
		newTabHolder.Name = removeSpaces((tabName and tabName:lower()) or "???") .. "TabHolder"
		newTabHolder.Parent = innerMainHolder
		newTabHolder.BackgroundColor3 = WhiteColor3
		newTabHolder.BackgroundTransparency = 1
		newTabHolder.Size = UDim2ScaleOne
		newTabHolder.Visible = windowFunctions.tabCount == 1
		left.Name = "left"
		left.Parent = newTabHolder
		left.BackgroundColor3 = WhiteColor3
		left.BackgroundTransparency = 1
		left.Position = UDim2.new(0, 14, 0, 0)
		left.Size = UDim2.new(0.5, -21, 1, -8)
		left.CanvasSize = UDim2.new()
		left.ScrollBarThickness = 0
		leftList.Name = "leftList"
		leftList.Parent = left
		leftList.HorizontalAlignment = Enum.HorizontalAlignment.Center
		leftList.SortOrder = Enum.SortOrder.LayoutOrder
		leftList.Padding = UDim.new(0, 12)
		leftPadding.Name = "leftPadding"
		leftPadding.Parent = left
		leftPadding.PaddingTop = UDim.new(0, 4)
		right.Name = "right"
		right.Parent = newTabHolder
		right.BackgroundColor3 = WhiteColor3
		right.BackgroundTransparency = 1
		right.Size = UDim2.new(0.5, -21, 1, -8)
		right.CanvasSize = UDim2.new()
		right.ScrollBarThickness = 0
		right.Position = UDim2.new(0.5, 7, 0, 0)
		rightList.Name = "rightList"
		rightList.Parent = right
		rightList.HorizontalAlignment = Enum.HorizontalAlignment.Center
		rightList.SortOrder = Enum.SortOrder.LayoutOrder
		rightList.Padding = UDim.new(0, 12)
		rightPadding.Name = "rightPadding"
		rightPadding.Parent = right
		rightPadding.PaddingTop = UDim.new(0, 4)
		-- if a tab only has sections on one side, let that side fill the whole width
		local function updateColumns()
			local nl, nr = 0, 0
			for _, c in ipairs(left:GetChildren()) do
				if c:IsA("Frame") then
					nl = nl + 1
				end
			end
			for _, c in ipairs(right:GetChildren()) do
				if c:IsA("Frame") then
					nr = nr + 1
				end
			end
			local halfSize = UDim2.new(0.5, -21, 1, -8)
			local fullSize = UDim2.new(1, -28, 1, -8)
			if (nl > 0) and (nr == 0) then
				left.Position = UDim2.new(0, 14, 0, 0)
				left.Size = fullSize
				right.Visible = false
				left.Visible = true
			elseif (nr > 0) and (nl == 0) then
				right.Position = UDim2.new(0, 14, 0, 0)
				right.Size = fullSize
				left.Visible = false
				right.Visible = true
			else
				left.Position = UDim2.new(0, 14, 0, 0)
				left.Size = halfSize
				right.Position = UDim2.new(0.5, 7, 0, 0)
				right.Size = halfSize
				left.Visible = true
				right.Visible = true
			end
		end
		library.signals[1 + #library.signals] = left.ChildAdded:Connect(updateColumns)
		library.signals[1 + #library.signals] = left.ChildRemoved:Connect(updateColumns)
		library.signals[1 + #library.signals] = right.ChildAdded:Connect(updateColumns)
		library.signals[1 + #library.signals] = right.ChildRemoved:Connect(updateColumns)
		local tabFunctions = {
			Flags = {},
			Remove = function()
				local relod
				if newTab then
					tabWrap.Parent = nil
					relod = true
				end
				if newTabHolder then
					newTabHolder.Parent = nil
					relod = true
				end
				if relod then
					windowFunctions:UpdateAll()
				end
			end,
			Select = goto
		}
		function tabFunctions:CreateSection(options, ...)
			options = (options and (type(options) == "string") and resolvevararg("Tab", options, ...)) or options
			local sectionName, holderSide = options.Name or "Unnamed Section", options.Side
			options.Name = sectionName
			local SECTION_HEAD = 34
			local newSection = Instance_new("Frame")
			local newSectionCorner = Instance_new("UICorner")
			local accentGlow = Instance_new("Frame")
			local accentGlowGradient = Instance_new("UIGradient")
			local accentLine = Instance_new("Frame")
			local accentLineGradient = Instance_new("UIGradient")
			local sectionHolder = Instance_new("Frame")
			local sectionList = Instance_new("UIListLayout")
			local sectionPadding = Instance_new("UIPadding")
			local sectionHeadline = Instance_new("TextLabel")
			colorpickerconflicts[1 + #colorpickerconflicts] = accentGlow
			colorpickerconflicts[1 + #colorpickerconflicts] = accentLine
			colorpickerconflicts[1 + #colorpickerconflicts] = sectionHeadline
			newSection.Name = removeSpaces((sectionName and sectionName:lower() or "???") .. "Section")
			newSection.Parent = (holderSide and (((holderSide:lower() == "left") and left) or right)) or left
			newSection.BackgroundColor3 = library.colors.sectionBackground
			colored[1 + #colored] = {newSection, "BackgroundColor3", "sectionBackground"}
			newSection.BorderSizePixel = 0
			newSection.Size = UDim2.new(1, 0, 0, SECTION_HEAD + 8)
			newSection.Visible = false
			newSectionCorner.CornerRadius = UDim.new(0, 12)
			newSectionCorner.Parent = newSection
			do
				local nsStroke = Instance_new("UIStroke")
				nsStroke.Color = library.colors.innerBorder
				colored[1 + #colored] = {nsStroke, "Color", "innerBorder"}
				nsStroke.Thickness = 1
				nsStroke.Transparency = 0.3
				nsStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				nsStroke.Parent = newSection
			end
			accentGlow.Name = "accentGlow"
			accentGlow.Parent = newSection
			accentGlow.BackgroundColor3 = library.colors.main
			colored[1 + #colored] = {accentGlow, "BackgroundColor3", "main"}
			accentGlow.BackgroundTransparency = 0.82
			accentGlow.BorderSizePixel = 0
			accentGlow.Size = UDim2.new(1, 0, 0, 6)
			accentGlow.ZIndex = 2
			accentGlowGradient.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 1)})
			accentGlowGradient.Parent = accentGlow
			accentLine.Name = "accentLine"
			accentLine.Parent = newSection
			accentLine.BackgroundColor3 = library.colors.main
			colored[1 + #colored] = {accentLine, "BackgroundColor3", "main"}
			accentLine.BorderSizePixel = 0
			accentLine.Size = UDim2.new(1, 0, 0, 2)
			accentLine.ZIndex = 3
			accentLineGradient.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 1)})
			accentLineGradient.Parent = accentLine
			sectionHolder.Name = "sectionHolder"
			sectionHolder.Parent = newSection
			sectionHolder.BackgroundColor3 = WhiteColor3
			sectionHolder.BackgroundTransparency = 1
			sectionHolder.Size = UDim2ScaleOne
			sectionList.Name = "sectionList"
			sectionList.Parent = sectionHolder
			sectionList.HorizontalAlignment = Enum.HorizontalAlignment.Center
			sectionList.SortOrder = Enum.SortOrder.LayoutOrder
			sectionList.Padding = UDim.new(0, 6)
			sectionPadding.Name = "sectionPadding"
			sectionPadding.Parent = sectionHolder
			sectionPadding.PaddingTop = UDim.new(0, SECTION_HEAD)
			sectionPadding.PaddingLeft = UDim.new(0, 6)
			sectionPadding.PaddingRight = UDim.new(0, 6)
			sectionHeadline.Name = "sectionHeadline"
			sectionHeadline.Parent = newSection
			sectionHeadline.BackgroundColor3 = WhiteColor3
			sectionHeadline.BackgroundTransparency = 1
			sectionHeadline.Position = UDim2.new(0, 24, 0, 12)
			sectionHeadline.Size = UDim2.new(1, -68, 0, 14)
			sectionHeadline.ZIndex = 3
			sectionHeadline.Font = Enum.Font.GothamBold
			sectionHeadline.Text = (sectionName and sectionName or "???")
			sectionHeadline.TextColor3 = library.colors.section
			colored[1 + #colored] = {sectionHeadline, "TextColor3", "section"}
			sectionHeadline.TextSize = 12
			sectionHeadline.TextXAlignment = Enum.TextXAlignment.Left
			sectionHeadline.TextTruncate = Enum.TextTruncate.AtEnd
			do
				local headBar = Instance_new("Frame")
				headBar.Name = "headBar"
				headBar.Parent = newSection
				headBar.BackgroundColor3 = library.colors.main
				colored[1 + #colored] = {headBar, "BackgroundColor3", "main"}
				headBar.BorderSizePixel = 0
				headBar.Position = UDim2.new(0, 12, 0, 13)
				headBar.Size = UDim2.fromOffset(3, 12)
				headBar.ZIndex = 3
				local hbc = Instance_new("UICorner")
				hbc.CornerRadius = UDim.new(0, 2)
				hbc.Parent = headBar
			end
			-- gives an element a rounded dark "row" background
			local function applyCard(frame)
				frame.BackgroundColor3 = library.colors.unselectedOption
				frame.BackgroundTransparency = 0
				frame.BorderSizePixel = 0
				colored[1 + #colored] = {frame, "BackgroundColor3", "unselectedOption"}
				local cardCorner = Instance_new("UICorner")
				cardCorner.CornerRadius = UDim.new(0, 9)
				cardCorner.Parent = frame
				local cardStroke = Instance_new("UIStroke")
				cardStroke.Color = library.colors.innerBorder
				colored[1 + #colored] = {cardStroke, "Color", "innerBorder"}
				cardStroke.Thickness = 1
				cardStroke.Transparency = 0.55
				cardStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				cardStroke.Parent = frame
			end
			-- collapse arrow (top right): folds the card up to just its title
			local sectionCollapsed = (options.Collapsed or options.Closed or options.Minimized) and true or false
			local collapseTween
			local collapseAnimating = false
			local collapseButton = Instance_new("TextButton")
			local collapseIcon = Instance_new("ImageLabel")
			colorpickerconflicts[1 + #colorpickerconflicts] = collapseButton
			collapseButton.Name = "collapseButton"
			collapseButton.Parent = newSection
			collapseButton.AnchorPoint = Vector2.new(1, 0)
			collapseButton.AutoButtonColor = false
			collapseButton.BackgroundTransparency = 1
			collapseButton.BorderSizePixel = 0
			collapseButton.Position = UDim2.new(1, -6, 0, 4)
			collapseButton.Size = UDim2.fromOffset(34, 30)
			collapseButton.Text = ""
			collapseButton.ZIndex = 4
			collapseIcon.Name = "icon"
			collapseIcon.Parent = collapseButton
			collapseIcon.AnchorPoint = Vector2.new(0.5, 0.5)
			collapseIcon.BackgroundTransparency = 1
			collapseIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
			collapseIcon.Size = UDim2.fromOffset(10, 10)
			collapseIcon.Rotation = (sectionCollapsed and 90) or -90
			collapseIcon.Image = "rbxassetid://71659683"
			collapseIcon.ImageColor3 = library.colors.otherElementText
			colored[1 + #colored] = {collapseIcon, "ImageColor3", "otherElementText"}
			collapseIcon.ZIndex = 5
			local function sectionHeight()
				if sectionCollapsed then
					return SECTION_HEAD
				end
				return SECTION_HEAD + 8 + sectionList.AbsoluteContentSize.Y
			end
			local function refreshColumnCanvas(extra)
				local currentHolder = newSection.Parent
				local columnLayout = currentHolder and currentHolder:FindFirstChildOfClass("UIListLayout")
				if columnLayout then
					currentHolder.CanvasSize = UDim2.fromOffset(0, columnLayout.AbsoluteContentSize.Y + 22 + (tonumber(extra) or 0))
				end
			end
			local function setSectionCollapsed(state)
				state = (state and true) or false
				if state == sectionCollapsed then
					return sectionCollapsed
				end
				if windowFunctions.CloseDropdown then
					pcall(windowFunctions.CloseDropdown)
					windowFunctions.CloseDropdown = nil
				end
				sectionCollapsed = state
				if collapseTween then
					collapseTween:Cancel()
				end
				local info = TweenInfo.new(0.25, library.configuration.easingStyle, library.configuration.easingDirection)
				collapseAnimating = true
				newSection.ClipsDescendants = true
				sectionHolder.Visible = true
				tweenService:Create(collapseIcon, info, {
					Rotation = (state and 90) or -90
				}):Play()
				local thisTween = tweenService:Create(newSection, info, {
					Size = UDim2.new(1, 0, 0, sectionHeight())
				})
				collapseTween = thisTween
				library.signals[1 + #library.signals] = thisTween.Completed:Connect(function()
					if collapseTween == thisTween then
						collapseTween = nil
						collapseAnimating = false
						sectionHolder.Visible = not sectionCollapsed
						newSection.ClipsDescendants = sectionCollapsed
						refreshColumnCanvas()
					end
				end)
				thisTween:Play()
				return sectionCollapsed
			end
			library.signals[1 + #library.signals] = collapseButton.MouseButton1Click:Connect(function()
				setSectionCollapsed(not sectionCollapsed)
			end)
			library.signals[1 + #library.signals] = collapseButton.MouseEnter:Connect(function()
				tweenService:Create(collapseIcon, TweenInfo.new(0.15), {
					ImageColor3 = library.colors.elementText
				}):Play()
			end)
			library.signals[1 + #library.signals] = collapseButton.MouseLeave:Connect(function()
				tweenService:Create(collapseIcon, TweenInfo.new(0.15), {
					ImageColor3 = library.colors.otherElementText
				}):Play()
			end)
			library.signals[1 + #library.signals] = newSection:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
				if collapseAnimating then
					refreshColumnCanvas()
				end
			end)
			local sectionFunctions = {
				Flags = {},
				Remove = function()
					if newSection then
						newSection.Parent = nil
						windowFunctions:UpdateAll()
					end
				end
			}
			function sectionFunctions:Update(extra)
				if newSection.Visible then
				else
					newSection.Visible = true
				end
				if collapseTween then
					collapseTween:Cancel()
					collapseTween = nil
					collapseAnimating = false
				end
				sectionHolder.Visible = not sectionCollapsed
				newSection.ClipsDescendants = sectionCollapsed
				newSection.Size = UDim2.new(1, 0, 0, sectionHeight())
				refreshColumnCanvas(extra)
			end
			function sectionFunctions:SetCollapsed(state)
				return setSectionCollapsed(state)
			end
			function sectionFunctions:Collapse()
				return setSectionCollapsed(true)
			end
			function sectionFunctions:Expand()
				return setSectionCollapsed(false)
			end
			function sectionFunctions:ToggleCollapsed()
				return setSectionCollapsed(not sectionCollapsed)
			end
			function sectionFunctions:IsCollapsed()
				return sectionCollapsed
			end
			function sectionFunctions:UpdateAll(...)
				for _, obj in next, sectionFunctions.Flags do
					if obj then
						if obj.Update then
							pcall(obj.Update)
						end
						if obj.UpdateAll then
							pcall(obj.UpdateAll)
						end
					end
				end
				sectionFunctions:Update(...)
			end
			function sectionFunctions:AddToggle(options, ...)
				options = (options and type(options) == "string" and resolvevararg("Tab", options, ...)) or options
				local toggleName, alreadyEnabled, callback, flagName = assert(options.Name, "Missing Name for new toggle."), options.Value or options.Enabled, options.Callback, options.Flag or (function()
					library.unnamedtoggles = 1 + (library.unnamedtoggles or 0)
					return "Toggle" .. tostring(library.unnamedtoggles)
				end)()
				if elements[flagName] ~= nil then
					warn(debug.traceback("Warning! Re-used flag '" .. flagName .. "'", 3))
				end
				local newToggle = Instance_new("Frame")
				local toggle = Instance_new("ImageLabel")
				local toggleCorner = Instance_new("UICorner")
				local toggleStroke = Instance_new("UIStroke")
				local toggleInner = Instance_new("ImageLabel")
				local toggleInnerCorner = Instance_new("UICorner")
				local toggleButton = Instance_new("TextButton")
				local toggleHeadline = Instance_new("TextLabel")
				local keybindPositioner = Instance_new("Frame")
				local keybindList = Instance_new("UIListLayout")
				local keybindButton = Instance_new("TextButton")
				local lockedup = options.Locked
				newToggle.Name = removeSpaces((toggleName and toggleName:lower() or "???") .. "Toggle")
				newToggle.Parent = sectionHolder
				applyCard(newToggle)
				newToggle.Size = UDim2.new(1, 0, 0, 34)
				toggle.Name = "toggle"
				toggle.Parent = newToggle
				toggle.AnchorPoint = Vector2.new(1, 0.5)
				toggle.BackgroundColor3 = library.colors.topGradient
				local colored_toggle_BackgroundColor3 = {toggle, "BackgroundColor3", "topGradient"}
				colored[1 + #colored] = colored_toggle_BackgroundColor3
				toggle.BorderSizePixel = 0
				toggle.Position = UDim2.new(1, -10, 0.5, 0)
				toggle.Size = UDim2.fromOffset(20, 20)
				toggle.Image = ""
				toggle.ImageColor3 = library.colors.bottomGradient
				local colored_toggle_ImageColor3 = {toggle, "ImageColor3", "bottomGradient"}
				colored[1 + #colored] = colored_toggle_ImageColor3
				toggleCorner.CornerRadius = UDim.new(0, 5)
				toggleCorner.Parent = toggle
				toggleStroke.Color = library.colors.innerBorder
				local colored_toggleStroke_Color = {toggleStroke, "Color", "innerBorder"}
				colored[1 + #colored] = colored_toggleStroke_Color
				toggleStroke.Thickness = 1
				toggleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				toggleStroke.Parent = toggle
				toggleInner.Name = "toggleInner"
				toggleInner.Parent = toggle
				toggleInner.BackgroundColor3 = library.colors.topGradient
				local colored_toggleInner_BackgroundColor3 = {toggleInner, "BackgroundColor3", "topGradient"}
				colored[1 + #colored] = colored_toggleInner_BackgroundColor3
				toggleInner.BorderSizePixel = 0
				toggleInner.Size = UDim2ScaleOne
				toggleInner.Image = ""
				toggleInner.ImageColor3 = library.colors.bottomGradient
				local colored_toggleInner_ImageColor3 = {toggleInner, "ImageColor3", "bottomGradient"}
				colored[1 + #colored] = colored_toggleInner_ImageColor3
				toggleInnerCorner.CornerRadius = UDim.new(0, 5)
				toggleInnerCorner.Parent = toggleInner
				-- check mark drawn from two small bars (no font symbols needed)
				local function makeCheckArm(px, py, w, h, rot)
					local arm = Instance_new("Frame")
					arm.AnchorPoint = Vector2.new(0.5, 0.5)
					arm.BackgroundColor3 = Color3.new(1, 1, 1)
					arm.BackgroundTransparency = 1
					arm.BorderSizePixel = 0
					arm.Position = UDim2.fromScale(px / 20, py / 20)
					arm.Rotation = rot
					arm.Size = UDim2.fromScale(w / 20, h / 20)
					arm.ZIndex = 2
					local armCorner = Instance_new("UICorner")
					armCorner.CornerRadius = UDim.new(1, 0)
					armCorner.Parent = arm
					arm.Parent = toggleInner
					return arm
				end
				local checkArmA = makeCheckArm(6.25, 12.25, 7, 2.6, 45)
				local checkArmB = makeCheckArm(11.75, 10.25, 12, 2.6, -45)
				-- alternative looks (Pill / Capsule / Circle / Diamond). Square above is the default look.
				local toggleW = 20
				local lastOn = false
				local altHolder = Instance_new("Frame")
				altHolder.Name = "altToggle"
				altHolder.Parent = newToggle
				altHolder.AnchorPoint = Vector2.new(1, 0.5)
				altHolder.BackgroundTransparency = 1
				altHolder.BorderSizePixel = 0
				altHolder.Position = UDim2.new(1, -10, 0.5, 0)
				altHolder.Size = UDim2.fromOffset(38, 20)
				altHolder.Visible = false
				local altTrack = Instance_new("Frame")
				altTrack.Name = "track"
				altTrack.Parent = altHolder
				altTrack.AnchorPoint = Vector2Half
				altTrack.BackgroundColor3 = library.colors.topGradient
				colored[1 + #colored] = {altTrack, "BackgroundColor3", "topGradient"}
				altTrack.BorderSizePixel = 0
				altTrack.Position = UDim2ScaleHalf
				altTrack.Size = UDim2ScaleOne
				local altTrackCorner = Instance_new("UICorner")
				altTrackCorner.CornerRadius = UDim.new(0.5, 0)
				altTrackCorner.Parent = altTrack
				local altStroke = Instance_new("UIStroke")
				altStroke.Color = library.colors.innerBorder
				local colored_altStroke_Color = {altStroke, "Color", "innerBorder"}
				colored[1 + #colored] = colored_altStroke_Color
				altStroke.Thickness = 1
				altStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				altStroke.Parent = altTrack
				local altFill = Instance_new("Frame")
				altFill.Name = "fill"
				altFill.Parent = altTrack
				altFill.BackgroundColor3 = library.colors.main
				colored[1 + #colored] = {altFill, "BackgroundColor3", "main"}
				altFill.BorderSizePixel = 0
				altFill.ZIndex = 2
				local altFillCorner = Instance_new("UICorner")
				altFillCorner.CornerRadius = UDim.new(0.5, 0)
				altFillCorner.Parent = altFill
				local altFillGloss = Instance_new("UIGradient")
				altFillGloss.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(175, 175, 175))
				altFillGloss.Rotation = 90
				altFillGloss.Parent = altFill
				local altKnob = Instance_new("Frame")
				altKnob.Name = "knob"
				altKnob.Parent = altTrack
				altKnob.AnchorPoint = Vector2Half
				altKnob.BackgroundColor3 = Color3.new(1, 1, 1)
				altKnob.BorderSizePixel = 0
				altKnob.Size = UDim2.fromOffset(14, 14)
				altKnob.Position = UDim2.new(0, 10, 0.5, 0)
				altKnob.ZIndex = 4
				altKnob.Visible = false
				local altKnobCorner = Instance_new("UICorner")
				altKnobCorner.CornerRadius = UDim.new(0.5, 0)
				altKnobCorner.Parent = altKnob
				local altKnobShadow = Instance_new("UIStroke")
				altKnobShadow.Color = Color3.new(0, 0, 0)
				altKnobShadow.Transparency = 0.75
				altKnobShadow.Thickness = 1
				altKnobShadow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				altKnobShadow.Parent = altKnob
				local function paintAlt(on, instant)
					local cfg = library.ToggleStyleConfigs[library.ToggleStyle or "Square"]
					if not cfg then
						return
					end
					local info = (instant and TweenInfo.new(0)) or TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
					colored_altStroke_Color[3] = (on and "main") or "innerBorder"
					tweenService:Create(altStroke, info, {
						Color = (on and library.colors.main) or library.colors.innerBorder
					}):Play()
					if cfg.mode == "alpha" then
						tweenService:Create(altFill, info, {
							BackgroundTransparency = (on and 0) or 1
						}):Play()
						tweenService:Create(altKnob, info, {
							Position = UDim2.new(0, (on and (cfg.w - 10)) or 10, 0.5, 0),
							BackgroundColor3 = (on and Color3.new(1, 1, 1)) or library.colors.otherElementText
						}):Play()
					elseif cfg.mode == "width" then
						tweenService:Create(altFill, info, {
							Size = UDim2.new((on and 1) or 0, 0, 1, 0)
						}):Play()
					else
						tweenService:Create(altFill, info, {
							Size = (on and UDim2.fromScale(0.62, 0.62)) or UDim2.fromScale(0, 0)
						}):Play()
					end
				end
				local function applyStyle()
					local cfg = library.ToggleStyleConfigs[library.ToggleStyle or "Square"]
					if cfg then
						toggle.Visible = false
						altHolder.Visible = true
						toggleW = cfg.w
						altHolder.Size = UDim2.fromOffset(cfg.w, cfg.h)
						altTrack.Rotation = cfg.rot or 0
						altTrackCorner.CornerRadius = (cfg.corner and UDim.new(0, cfg.corner)) or UDim.new(0.5, 0)
						altFillCorner.CornerRadius = (cfg.fcorner and UDim.new(0, cfg.fcorner)) or UDim.new(0.5, 0)
						altKnob.Visible = cfg.mode == "alpha"
						if cfg.mode == "alpha" then
							altFill.AnchorPoint = Vector2.new(0, 0)
							altFill.Position = UDim2.fromScale(0, 0)
							altFill.Size = UDim2.fromScale(1, 1)
						elseif cfg.mode == "width" then
							altFill.AnchorPoint = Vector2.new(0, 0)
							altFill.Position = UDim2.fromScale(0, 0)
							altFill.BackgroundTransparency = 0
						else
							altFill.AnchorPoint = Vector2Half
							altFill.Position = UDim2ScaleHalf
							altFill.BackgroundTransparency = 0
						end
						paintAlt(lastOn, true)
					else
						toggle.Visible = true
						altHolder.Visible = false
						toggleW = 20
					end
					toggleHeadline.Size = UDim2.new(1, -(toggleW + 28), 1, 0)
					keybindPositioner.Size = UDim2.new(1, -(toggleW + 20), 1, 0)
				end
				toggleButton.Name = "toggleButton"
				toggleButton.Parent = newToggle
				toggleButton.BackgroundColor3 = WhiteColor3
				toggleButton.BackgroundTransparency = 1
				toggleButton.Size = UDim2ScaleOne
				toggleButton.ZIndex = 5
				toggleButton.Font = Enum.Font.SourceSans
				toggleButton.Text = ""
				toggleButton.TextColor3 = Color3.new()
				toggleButton.TextSize = 12
				toggleButton.TextTransparency = 1
				toggleHeadline.Name = "toggleHeadline"
				toggleHeadline.Parent = newToggle
				toggleHeadline.BackgroundColor3 = WhiteColor3
				toggleHeadline.BackgroundTransparency = 1
				toggleHeadline.Position = UDim2.new(0, 12, 0, 0)
				toggleHeadline.Size = UDim2.new(1, -48, 1, 0)
				toggleHeadline.Font = Enum.Font.GothamBold
				toggleHeadline.Text = toggleName or "???"
				toggleHeadline.TextColor3 = library.colors.otherElementText
				local colored_toggleHeadline_TextColor3 = {toggleHeadline, "TextColor3", "otherElementText", (lockedup and 2.5) or nil}
				colored[1 + #colored] = colored_toggleHeadline_TextColor3
				toggleHeadline.TextSize = 12
				toggleHeadline.TextXAlignment = Enum.TextXAlignment.Left
				toggleHeadline.TextTruncate = Enum.TextTruncate.AtEnd
				applyStyle()
				library.toggleRestylers[1 + #library.toggleRestylers] = function()
					if newToggle.Parent then
						applyStyle()
					end
				end
				-- one place that paints the on / off look
				local function paintToggle(on)
					on = (on and true) or false
					lastOn = on
					paintAlt(on)
					local info = TweenInfo.new(0.2, library.configuration.easingStyle, library.configuration.easingDirection)
					colored_toggleInner_BackgroundColor3[3] = (on and "main") or "topGradient"
					colored_toggleInner_BackgroundColor3[4] = nil
					colored_toggleInner_ImageColor3[3] = (on and "main") or "bottomGradient"
					colored_toggleInner_ImageColor3[4] = nil
					colored_toggleStroke_Color[3] = (on and "main") or "innerBorder"
					colored_toggleHeadline_TextColor3[3] = (on and "elementText") or "otherElementText"
					colored_toggleHeadline_TextColor3[4] = (lockedup and 2.5) or nil
					tweenService:Create(toggleInner, info, {
						BackgroundColor3 = (on and library.colors.main) or library.colors.topGradient
					}):Play()
					tweenService:Create(toggleStroke, info, {
						Color = (on and library.colors.main) or library.colors.innerBorder
					}):Play()
					tweenService:Create(toggleHeadline, info, {
						TextColor3 = darkenColor((on and library.colors.elementText) or library.colors.otherElementText, (lockedup and 2.5) or nil)
					}):Play()
					tweenService:Create(checkArmA, info, {
						BackgroundTransparency = (on and 0) or 1
					}):Play()
					tweenService:Create(checkArmB, info, {
						BackgroundTransparency = (on and 0) or 1
					}):Play()
				end
				local last_v
				local function Set(t, newStatus)
					if (nil == newStatus) and (t ~= nil) then
						newStatus = t
					end
					last_v = library_flags[flagName]
					if options.Condition ~= nil then
						if type(options.Condition) == "function" then
							local v, e = pcall(options.Condition, newStatus, last_v)
							if e then
								if v then
								else
									warn(debug.traceback(string.format("Error in toggle %s's Condition function: %s", flagName, e), 2))
								end
							else
								return last_v
							end
						end
					end
					if (newStatus ~= nil) and (type(newStatus) == "boolean") then
						library_flags[flagName] = newStatus
						if options.Location then
							options.Location[options.LocationFlag or flagName] = newStatus
						end
						paintToggle(newStatus)
						if callback and (last_v ~= newStatus or options.AllowDuplicateCalls) then
							if callback and __runscript then
								task.spawn(callback, newStatus, last_v)
							end
						end
					end
					return newStatus
				end
				options.Keybind = options.Keybind or options.Key or options.KeyBind
				local haskbflag, kbUpdate, kbData
				if options.Keybind then
					local options = options.Keybind
					local htyp = typeof(options)
					if htyp == "EnumItem" then
						options = {
							Value = options
						}
					elseif htyp ~= "table" then
						options = {}
					end
					local presetKeybind, callback, kbpresscallback, kbflag = options.Value or options.Key, options.Callback, options.Pressed, options.Flag or (function()
						if flagName then
							return flagName .. "_ToggleKeybind"
						end
						library.unnamedkeybinds = 1 + (library.unnamedkeybinds or 0)
						return "Keybind" .. tostring(library.unnamedkeybinds)
					end)()
					if elements[kbflag] ~= nil or kbflag == flagName then
						warn(debug.traceback("Warning! Re-used flag '" .. kbflag .. "'", 3))
					end
					haskbflag = kbflag
					library.keyHandler = keyHandler
					local keyHandler = options.KeyNames or keyHandler
					local bindedKey = presetKeybind
					local justBinded = false
					local keyName = keyHandler.allowedKeys[bindedKey] or (bindedKey and (bindedKey.Name or tostring(bindedKey):gsub("Enum.KeyCode.", ""))) or "NONE"
					local newKeybind = newToggle
					keybindPositioner.Name = "keybindPositioner"
					keybindPositioner.Parent = newKeybind
					keybindPositioner.BackgroundColor3 = WhiteColor3
					keybindPositioner.BackgroundTransparency = 1
					keybindPositioner.Position = UDim2.new(0, 0, 0, 0)
					keybindPositioner.Size = UDim2.new(1, -(toggleW + 20), 1, 0)
					keybindPositioner.ZIndex = 1 + toggleButton.ZIndex
					keybindList.Name = "keybindList"
					keybindList.Parent = keybindPositioner
					keybindList.FillDirection = Enum.FillDirection.Horizontal
					keybindList.HorizontalAlignment = Enum.HorizontalAlignment.Right
					keybindList.SortOrder = Enum.SortOrder.LayoutOrder
					keybindList.VerticalAlignment = Enum.VerticalAlignment.Center
					keybindButton.Name = "keybindButton"
					keybindButton.Parent = keybindPositioner
					keybindButton.Active = false
					keybindButton.BackgroundColor3 = WhiteColor3
					keybindButton.BackgroundTransparency = 1
					keybindButton.Position = UDim2.fromScale(0.598130822, 0.184210524)
					keybindButton.Selectable = false
					keybindButton.Size = UDim2.fromOffset(46, 12)
					keybindButton.Font = Enum.Font.GothamBold
					keybindButton.Text = keyName or (presetKeybind and tostring(presetKeybind):gsub("Enum.KeyCode.", "")) or "[NONE]"
					keybindButton.TextColor3 = library.colors.otherElementText
					local colored_keybindButton_TextColor3 = {keybindButton, "TextColor3", "otherElementText"}
					colored[1 + #colored] = colored_keybindButton_TextColor3
					keybindButton.TextSize = 12
					keybindButton.TextXAlignment = Enum.TextXAlignment.Right
					keybindButton.Size = UDim2.fromOffset(textToSize(keybindButton).X + 4, 12)
					local klast_v = bindedKey or presetKeybind
					local function newkey()
						if lockedup then
							return
						end
						local old_texts = keybindButton.Text
						colored_keybindButton_TextColor3[3] = "main"
						colored_keybindButton_TextColor3[4] = nil
						tweenService:Create(keybindButton, TweenInfo.new(0.35, library.configuration.easingStyle, library.configuration.easingDirection), {
							TextColor3 = library.colors.main
						}):Play()
						if klast_v then
							keybindButton.Text = "(Was " .. (klast_v and tostring(klast_v):gsub("Enum.KeyCode.", "") or "[NONE]") .. ") [...]"
						else
							keybindButton.Text = "[...]"
						end
						local receivingKey
						receivingKey = userInputService.InputBegan:Connect(function(key)
							if lockedup then
								return receivingKey:Disconnect()
							end
							klast_v = library_flags[kbflag]
							if keyHandler.notAllowedKeys[key.KeyCode] then
							else
								if key.KeyCode ~= Enum.KeyCode.Unknown then
									bindedKey = (key.KeyCode ~= Enum.KeyCode.Escape and key.KeyCode) or library_flags[kbflag]
									library_flags[kbflag] = bindedKey
									if options.Location then
										options.Location[options.LocationFlag or kbflag] = bindedKey
									end
									if bindedKey then
										keyName = keyHandler.allowedKeys[bindedKey] or (bindedKey and (bindedKey.Name or tostring(bindedKey):gsub("Enum.KeyCode.", ""))) or "NONE"
										keybindButton.Text = "[" .. (keyName or (bindedKey and bindedKey.Name) or "NONE") .. "]"
										keybindButton.Size = UDim2.fromOffset(textToSize(keybindButton).X + 4, 12)
										justBinded = true
										colored_keybindButton_TextColor3[3] = "otherElementText"
										colored_keybindButton_TextColor3[4] = nil
										tweenService:Create(keybindButton, TweenInfo.new(0.35, library.configuration.easingStyle, library.configuration.easingDirection), {
											TextColor3 = library.colors.otherElementText
										}):Play()
										receivingKey:Disconnect()
									end
									if __runscript and callback and (klast_v ~= bindedKey) then
										task.spawn(callback, bindedKey, klast_v)
									end
									return
								elseif (key.KeyCode == Enum.KeyCode.Unknown) and not keyHandler.notAllowedMouseInputs[key.UserInputType] then
									bindedKey = key.UserInputType
									library_flags[kbflag] = bindedKey
									if options.Location then
										options.Location[options.LocationFlag or kbflag] = bindedKey
									end
									keyName = keyHandler.allowedKeys[bindedKey]
									keybindButton.Text = "[" .. (keyName or (bindedKey and bindedKey.Name) or tostring(bindedKey.KeyCode):gsub("Enum.KeyCode.", "")) .. "]"
									keybindButton.Size = UDim2.fromOffset(textToSize(keybindButton).X + 4, 12)
									justBinded = true
									colored_keybindButton_TextColor3[3] = "otherElementText"
									colored_keybindButton_TextColor3[4] = nil
									tweenService:Create(keybindButton, TweenInfo.new(0.35, library.configuration.easingStyle, library.configuration.easingDirection), {
										TextColor3 = library.colors.otherElementText
									}):Play()
									receivingKey:Disconnect()
									if __runscript and callback and (klast_v ~= bindedKey) then
										task.spawn(callback, bindedKey, klast_v)
									end
									return
								end
							end
							if key.KeyCode == Enum.KeyCode.Backspace or Enum.KeyCode.Escape == key.KeyCode then
								old_texts, bindedKey = "[NONE]", nil
							end
							keybindButton.Text = old_texts
							colored_keybindButton_TextColor3[3] = "otherElementText"
							colored_keybindButton_TextColor3[4] = nil
							tweenService:Create(keybindButton, TweenInfo.new(0.35, library.configuration.easingStyle, library.configuration.easingDirection), {
								TextColor3 = library.colors.otherElementText
							}):Play()
							receivingKey:Disconnect()
							if __runscript and callback and (klast_v ~= bindedKey) then
								task.spawn(callback, bindedKey, klast_v)
							end
						end)
						library.signals[1 + #library.signals] = receivingKey
					end
					library.signals[1 + #library.signals] = keybindButton.MouseButton1Click:Connect(newkey)
					if kbpresscallback and not justBinded then
						library.signals[1 + #library.signals] = userInputService.InputBegan:Connect(function(key, chatting)
							chatting = chatting or (userInputService:GetFocusedTextBox() and true)
							if chatting or justBinded then
							else
								if keyHandler.notAllowedKeys[key.KeyCode] or keyHandler.notAllowedMouseInputs[key.UserInputType] then
								else
									if (bindedKey == key.UserInputType) or not justBinded and (bindedKey == key.KeyCode) then
										if kbpresscallback then
											task.spawn(kbpresscallback, key, chatting)
										end
									end
									justBinded = false
								end
							end
						end)
					end
					options.Mode = (options.Mode and string.lower(tostring(options.Mode))) or "dynamic"
					local modes = {
						dynamic = 1,
						hold = 1,
						toggle = 1
					}
					library.signals[1 + #library.signals] = userInputService.InputBegan:Connect(function(input, chatting)
						if justBinded then
							wait(0.1)
							justBinded = false
							return
						elseif lockedup then
							return
						end
						chatting = chatting or userInputService:GetFocusedTextBox()
						if chatting then
						else
							local key = library_flags[kbflag]
							local mode = options.Mode
							if modes[mode] then
							else
								mode = "dynamic"
								options.Mode = mode
							end
							if (key == input.KeyCode) or (key == input.UserInputType) then
								if (mode == "dynamic") or (mode == "both") or mode == "hold" then
									if mode == "dynamic" and library_flags[flagName] then
										return Set(false)
									end
									Set(true)
									local now = os.clock()
									local waittil
									if mode == "dynamic" then
										waittil = Instance_new("BindableEvent")
									end
									local xconnection
									xconnection = userInputService.InputEnded:Connect(function(input, chatting)
										chatting = chatting or userInputService:GetFocusedTextBox()
										if chatting or ((key ~= input.KeyCode) and (key ~= input.UserInputType)) then
										else
											xconnection = (xconnection and xconnection:Disconnect() and nil) or nil
											if (mode == "hold") or ((os.clock() - now) > math.clamp(tonumber(options.DynamicTime) or 0.65, 0.05, 20)) then
												Set(false)
											end
										end
									end)
									library.signals[1 + #library.signals] = xconnection
								else
									Set(not library_flags[flagName])
								end
							end
						end
					end)
					local function kbset(t, key)
						if (nil == key) and (t ~= nil) then
							key = t
						end
						if (key == "nil") or (key == "NONE") or (key == "none") then
							key = nil
						end
						last_v = library_flags[kbflag]
						bindedKey = key
						library_flags[kbflag] = key
						if options.Location then
							options.Location[options.LocationFlag or kbflag] = key
						end
						keyName = ((key == nil) and "NONE") or keyHandler.allowedKeys[key]
						keybindButton.Text = "[" .. (keyName or key.Name or tostring(key):gsub("Enum.KeyCode.", "")) .. "]"
						keybindButton.Size = UDim2.fromOffset(textToSize(keybindButton).X + 4, 12)
						justBinded = true
						colored_keybindButton_TextColor3[3] = "otherElementText"
						colored_keybindButton_TextColor3[4] = nil
						tweenService:Create(keybindButton, TweenInfo.new(0.35, library.configuration.easingStyle, library.configuration.easingDirection), {
							TextColor3 = library.colors.otherElementText
						}):Play()
						if __runscript and callback and ((last_v ~= key) or options.AllowDuplicateCalls) then
							task.spawn(callback, key, last_v)
						end
						return key
					end
					if presetKeybind ~= nil then
						kbset(presetKeybind)
					else
						library_flags[kbflag] = bindedKey
						if options.Location then
							options.Location[options.LocationFlag or kbflag] = bindedKey
						end
					end
					local default = library_flags[kbflag]
					local function UpdateKb()
						callback, kbpresscallback = options.Callback, options.Pressed
						local key = library_flags[kbflag]
						bindedKey = key
						keyName = keyHandler.allowedKeys[bindedKey] or (bindedKey and (bindedKey.Name or tostring(bindedKey):gsub("Enum.KeyCode.", ""))) or "NONE"
						keybindButton.Text = "[" .. (keyName or (key and key.Name) or tostring(key):gsub("Enum.KeyCode.", "")) .. "]"
						keybindButton.Size = UDim2.fromOffset(textToSize(keybindButton).X + 4, 12)
						colored_keybindButton_TextColor3[3] = "otherElementText"
						colored_keybindButton_TextColor3[4] = (lockedup and 2.5) or nil
						tweenService:Create(keybindButton, TweenInfo.new(0.35, library.configuration.easingStyle, library.configuration.easingDirection), {
							TextColor3 = (lockedup and darkenColor(library.colors.otherElementText, colored_keybindButton_TextColor3[4])) or library.colors.otherElementText
						}):Play()
						return key
					end
					kbUpdate = UpdateKb
					local objectdata = {
						Options = options,
						Name = kbflag,
						Flag = kbflag,
						Type = "Keybind",
						Default = default,
						Parent = sectionFunctions,
						Instance = keybindButton,
						Get = function()
							return library_flags[kbflag]
						end,
						Set = kbset,
						RawSet = function(t, key)
							if t ~= nil and key == nil then
								key = t
							end
							library_flags[kbflag] = key
							UpdateKb()
							return key
						end,
						Update = UpdateKb,
						Reset = function()
							return kbset(nil, default)
						end
					}
					kbData = objectdata
					tabFunctions.Flags[kbflag], sectionFunctions.Flags[kbflag], elements[kbflag] = objectdata, objectdata, objectdata
				end
				sectionFunctions:Update()
				library.signals[1 + #library.signals] = toggleButton.MouseButton1Click:Connect(function()
					if submenuOpen or lockedup or library.colorpicker then
					else
						local newval = not library_flags[flagName]
						if options.Condition ~= nil then
							if type(options.Condition) == "function" then
								local v, e = pcall(options.Condition, newval, not newval)
								if e then
									if v then
									else
										warn(debug.traceback(string.format("Error in toggle %s's Condition function: %s", flagName, e), 2))
									end
								else
									return last_v
								end
							end
						end
						library_flags[flagName] = newval
						if options.Location then
							options.Location[options.LocationFlag or flagName] = newval
						end
						paintToggle(newval)
						if callback and __runscript then
							task.spawn(callback, newval)
						end
					end
				end)
				library.signals[1 + #library.signals] = newToggle.MouseEnter:Connect(function()
					tweenService:Create(newToggle, TweenInfo.new(0.2, library.configuration.easingStyle, library.configuration.easingDirection), {
						BackgroundColor3 = library.colors.unselectedOption:Lerp(Color3.new(1, 1, 1), 0.05)
					}):Play()
					if not library_flags[flagName] then
						tweenService:Create(toggleStroke, TweenInfo.new(0.2, library.configuration.easingStyle, library.configuration.easingDirection), {
							Color = library.colors.hoveredOptionTop
						}):Play()
					end
				end)
				library.signals[1 + #library.signals] = newToggle.MouseLeave:Connect(function()
					tweenService:Create(newToggle, TweenInfo.new(0.2, library.configuration.easingStyle, library.configuration.easingDirection), {
						BackgroundColor3 = library.colors.unselectedOption
					}):Play()
					if not library_flags[flagName] then
						tweenService:Create(toggleStroke, TweenInfo.new(0.2, library.configuration.easingStyle, library.configuration.easingDirection), {
							Color = library.colors.innerBorder
						}):Play()
					end
				end)
				paintToggle(library_flags[flagName])
				local function Update()
					toggleName, callback = options.Name or toggleName, options.Callback
					local boolstatus = library_flags[flagName]
					paintToggle(boolstatus)
					toggleHeadline.Text = toggleName or "???"
					return boolstatus
				end
				if alreadyEnabled ~= nil then
					Set(alreadyEnabled)
				else
					library_flags[flagName] = alreadyEnabled and true
					if options.Location then
						options.Location[options.LocationFlag or flagName] = alreadyEnabled and true
					end
				end
				local default = library_flags[flagName] and true
				Update()
				if kbUpdate then
					kbUpdate()
				end
				local objectdata = {
					Options = options,
					Type = "Toggle",
					Name = flagName,
					Flag = flagName,
					Default = default,
					Parent = sectionFunctions,
					Instance = toggleButton,
					Set = Set,
					Remove = function()
						if newToggle then
							newToggle.Parent = nil
							sectionFunctions:Update()
						end
					end,
					RawSet = function(t, newStatus, condition)
						if t ~= nil and type(t) ~= "table" then
							newStatus, condition = t, newStatus
						end
						last_v = library_flags[flagName]
						if (condition ~= false) and (condition ~= 0) then
							local overridecondition = condition and (type(condition) == "function") and condition
							if overridecondition or (options.Condition ~= nil) then
								if type(overridecondition or options.Condition) == "function" then
									local v, e = pcall(overridecondition or options.Condition, newStatus, last_v)
									if e then
										if v then
										else
											warn(debug.traceback(string.format("Error in toggle (RawSet) %s's Condition function: %s", flagName, e), 2))
										end
									else
										return last_v
									end
								end
							end
						end
						library_flags[flagName] = newStatus
						if options.Location then
							options.Location[options.LocationFlag or flagName] = newStatus
						end
						Update()
						return newStatus
					end,
					KeybindData = kbData,
					Get = function()
						return library_flags[flagName]
					end,
					Update = Update,
					Reset = function()
						return Set(nil, default)
					end,
					SetLocked = function(t, state)
						if type(t) ~= "table" then
							state = t
						end
						local last_v = lockedup
						if state == nil then
							lockedup = not lockedup
						else
							lockedup = state
						end
						if lockedup ~= last_v then
							colored_toggleHeadline_TextColor3[4] = (lockedup and 2.5) or nil
							Update()
							if kbUpdate then
								kbUpdate()
							end
						end
						return lockedup
					end,
					Lock = function()
						if lockedup then
						else
							lockedup = true
							colored_toggleHeadline_TextColor3[4] = 2.5
							Update()
							if kbUpdate then
								kbUpdate()
							end
						end
						return lockedup
					end,
					Unlock = function()
						if lockedup then
							lockedup = false
							colored_toggleHeadline_TextColor3[4] = nil
							Update()
							if kbUpdate then
								kbUpdate()
							end
						end
						return lockedup
					end,
					SetCondition = function(t, condition)
						if (type(t) ~= "table") and (condition == nil) then
							condition = t
						end
						options.Condition = condition
						return condition
					end
				}
				if kbData then
					kbData.ToggleData = objectdata
				end
				tabFunctions.Flags[flagName], sectionFunctions.Flags[flagName], elements[flagName] = objectdata, objectdata, objectdata
				return objectdata
			end
			sectionFunctions.CreateToggle = sectionFunctions.AddToggle
			sectionFunctions.NewToggle = sectionFunctions.AddToggle
			sectionFunctions.Toggle = sectionFunctions.AddToggle
			sectionFunctions.Tog = sectionFunctions.AddToggle
			function sectionFunctions:AddButton(...)
				local args
				if ... and not select(2, ...) and (type(...) == "table") and (#... > 0) and (type((...)[1]) == "table") and (...)[1].Name then
					args = ...
				else
					args = {...}
				end
				local buttons, offset = {}, 0
				local frames = {}
				local fram
				local function layoutRow(rowFrame)
					local list = frames[rowFrame]
					if not list then
						return
					end
					local alive = {}
					for _, v in next, list do
						if v and v.ButtonFrame and v.ButtonFrame.Parent then
							alive[1 + #alive] = v
						end
					end
					local n = #alive
					local gap = (n > 1 and 6) or 0
					for i, v in next, alive do
						v.ButtonFrame.Size = UDim2.new(1 / n, -((gap * (n - 1)) / n), 1, 0)
						v.ButtonFrame.Position = UDim2.new((i - 1) / n, (gap * (i - 1)) / n, 0, 0)
					end
				end
				for _, options in next, args do
					options = (options and options[1] and (type(options[1]) == "string") and resolvevararg("Button", unpack(options))) or options
					local buttonName, callback = assert(options.Name, "Missing Name for new button."), options.Callback or (warn("AddButton missing callback. Name:", options.Name or "No Name", debug.traceback("")) and nil) or function()
					end
					local lockedup = options.Locked
					local realButton = Instance_new("TextButton")
					realButton.Name = "realButton"
					realButton.AutoButtonColor = false
					realButton.BackgroundColor3 = WhiteColor3
					realButton.BackgroundTransparency = 1
					realButton.Size = UDim2ScaleOne
					realButton.ZIndex = 5
					realButton.Font = Enum.Font.GothamBold
					realButton.Text = (buttonName and tostring(buttonName)) or "???"
					realButton.TextColor3 = library.colors.tabText
					local colored_realButton_TextColor3 = {realButton, "TextColor3", "tabText"}
					colored[1 + #colored] = colored_realButton_TextColor3
					realButton.TextSize = 12
					local textsize = textToSize(realButton).X + 28
					if newSection.Parent and (((newSection.Parent.AbsoluteSize.X / guiScale()) - 12) < (offset + textsize)) then
						offset, fram = 0, nil
					end
					local newButton = fram or Instance_new("Frame")
					fram = newButton
					local framButtons = frames[fram] or {}
					frames[fram] = framButtons
					local button = Instance_new("ImageLabel")
					local buttonCorner = Instance_new("UICorner")
					newButton.Name = removeSpaces((buttonName and buttonName:lower() or "???") .. "Holder")
					newButton.Parent = sectionHolder
					newButton.BackgroundColor3 = WhiteColor3
					newButton.BackgroundTransparency = 1
					newButton.Size = UDim2.new(1, 0, 0, 32)
					button.Name = "button"
					button.Parent = newButton
					button.Active = true
					button.BackgroundColor3 = library.colors.main
					local colored_button_BackgroundColor3 = {button, "BackgroundColor3", "main"}
					colored[1 + #colored] = colored_button_BackgroundColor3
					button.BorderSizePixel = 0
					button.Selectable = true
					button.Image = ""
					button.ImageColor3 = library.colors.bottomGradient
					local colored_button_ImageColor3 = {button, "ImageColor3", "bottomGradient"}
					colored[1 + #colored] = colored_button_ImageColor3
					button.Position = UDim2.new(0, 0, 0, 0)
					button.Size = UDim2.new(1, 0, 1, 0)
					buttonCorner.CornerRadius = UDim.new(0, 7)
					buttonCorner.Parent = button
					-- pro look: soft top-to-bottom shading, light edge, glossy top half, flash when pressed
					local btnShade = Instance_new("UIGradient")
					btnShade.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(168, 168, 168))
					btnShade.Rotation = 90
					btnShade.Parent = button
					local btnEdge = Instance_new("UIStroke")
					btnEdge.Color = Color3.new(1, 1, 1)
					btnEdge.Transparency = 0.82
					btnEdge.Thickness = 1
					btnEdge.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
					btnEdge.Parent = button
					local btnGloss = Instance_new("Frame")
					btnGloss.Name = "gloss"
					btnGloss.BackgroundColor3 = Color3.new(1, 1, 1)
					btnGloss.BorderSizePixel = 0
					btnGloss.Position = UDim2.new(0, 2, 0, 1)
					btnGloss.Size = UDim2.new(1, -4, 0.5, -1)
					btnGloss.ZIndex = 2
					btnGloss.Parent = button
					local btnGlossCorner = Instance_new("UICorner")
					btnGlossCorner.CornerRadius = UDim.new(0, 6)
					btnGlossCorner.Parent = btnGloss
					local btnGlossFade = Instance_new("UIGradient")
					btnGlossFade.Rotation = 90
					btnGlossFade.Transparency = NumberSequence.new(0.8, 1)
					btnGlossFade.Parent = btnGloss
					local btnFlash = Instance_new("Frame")
					btnFlash.Name = "flash"
					btnFlash.BackgroundColor3 = Color3.new(1, 1, 1)
					btnFlash.BackgroundTransparency = 1
					btnFlash.BorderSizePixel = 0
					btnFlash.Size = UDim2ScaleOne
					btnFlash.ZIndex = 3
					btnFlash.Parent = button
					local btnFlashCorner = Instance_new("UICorner")
					btnFlashCorner.CornerRadius = UDim.new(0, 7)
					btnFlashCorner.Parent = btnFlash
					library.signals[1 + #library.signals] = realButton.MouseButton1Down:Connect(function()
						if lockedup then
							return
						end
						btnFlash.BackgroundTransparency = 0.7
						tweenService:Create(btnFlash, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							BackgroundTransparency = 1
						}):Play()
					end)
					realButton.Parent = button
					offset = offset + textsize + 6
					sectionFunctions:Update()
					local presses = 0
					local function do_callback(f, c)
						local callback = f or options.Callback or callback
						local c = c or options.Condition
						if lockedup then
							return
						end
						if (c ~= nil) and (type(c) == "function") and __runscript then
							local v, e = pcall(c, presses)
							if e then
								if v then
								else
									warn(debug.traceback(string.format("Error in button %s's Condition function: %s", buttonName, e), 2))
								end
							else
								return
							end
						end
						if submenuOpen or library.colorpicker then
						else
							presses = 1 + presses
							if callback and __runscript then
								task.spawn(callback, presses)
							end
						end
					end
					library.signals[1 + #library.signals] = realButton.MouseButton1Click:Connect(function()
						return do_callback()
					end)
					library.signals[1 + #library.signals] = realButton.MouseButton2Click:Connect(function()
						return do_callback(options.CallbackRight, options.ConditionRight)
					end)
					local imin
					local function restColor()
						return (lockedup and library.colors.selectedOption) or library.colors.main
					end
					local function hoverColor()
						return library.colors.main:Lerp(Color3.new(1, 1, 1), 0.14)
					end
					library.signals[1 + #library.signals] = button.MouseEnter:Connect(function(...)
						imin = 1
						if not lockedup then
							tweenService:Create(button, TweenInfo.new(0.2, library.configuration.easingStyle, library.configuration.easingDirection), {
								BackgroundColor3 = hoverColor()
							}):Play()
						end
						local mec = options.MouseEnterCallback
						if mec and (type(mec) == "function") then
							local x, e = pcall(mec, ...)
							if x then
							elseif e then
								warn(debug.traceback(string.format("Error in button %s's MouseEnterCallback function: %s", buttonName, e), 2))
							end
						end
					end)
					library.signals[1 + #library.signals] = button.MouseLeave:Connect(function(...)
						imin = nil
						tweenService:Create(button, TweenInfo.new(0.2, library.configuration.easingStyle, library.configuration.easingDirection), {
							BackgroundColor3 = restColor()
						}):Play()
						local mlc = options.MouseLeaveCallback
						if mlc and (type(mlc) == "function") then
							local x, e = pcall(mlc, ...)
							if x then
							elseif e then
								warn(debug.traceback(string.format("Error in button %s's MouseLeaveCallback function: %s", buttonName, e), 2))
							end
						end
					end)
					library.signals[1 + #library.signals] = realButton.MouseButton1Down:Connect(function()
						if not lockedup then
							tweenService:Create(button, TweenInfo.new(0.08), {
								BackgroundColor3 = darkenColor(library.colors.main, 1.3)
							}):Play()
						end
					end)
					library.signals[1 + #library.signals] = realButton.MouseButton1Up:Connect(function()
						if not lockedup then
							tweenService:Create(button, TweenInfo.new(0.15), {
								BackgroundColor3 = (imin and hoverColor()) or library.colors.main
							}):Play()
						end
					end)
					local function Update(Recursive)
						buttonName, callback = options.Name or buttonName, options.Callback or (warn(debug.traceback("AddButton missing callback. Name:" .. (options.Name or buttonName or "No Name"), 2)) and nil) or function()
						end
						colored_button_BackgroundColor3[3] = (lockedup and "selectedOption") or "main"
						colored_button_BackgroundColor3[4] = nil
						colored_realButton_TextColor3[3] = (lockedup and "otherElementText") or "tabText"
						colored_realButton_TextColor3[4] = nil
						tweenService:Create(button, TweenInfo.new(0.35, library.configuration.easingStyle, library.configuration.easingDirection), {
							BackgroundColor3 = (lockedup and library.colors.selectedOption) or (imin and library.colors.main:Lerp(Color3.new(1, 1, 1), 0.14)) or library.colors.main
						}):Play()
						tweenService:Create(realButton, TweenInfo.new(0.35, library.configuration.easingStyle, library.configuration.easingDirection), {
							TextColor3 = (lockedup and library.colors.otherElementText) or library.colors.tabText
						}):Play()
						realButton.Text = (buttonName and tostring(buttonName)) or "???"
						local newtextsize = textToSize(realButton).X + 28
						if textsize ~= newtextsize then
							textsize = newtextsize
							if Recursive ~= "Recursive" then
								if buttons and buttons.UpdateAll then
									buttons.UpdateAll()
								end
							end
						end
						return presses, textsize
					end
					Update()
					local objectdata = {
						Options = options,
						Name = buttonName,
						Flag = buttonName,
						Type = "Button",
						Parent = sectionFunctions,
						Instance = realButton,
						Frame = fram or newButton,
						ButtonFrame = button,
						Remove = function()
							if button then
								button.Parent = nil
								buttons.UpdateAll()
								sectionFunctions.UpdateAll()
							end
						end,
						Press = function(...)
							if lockedup then
								return presses
							end
							if (options.Condition ~= nil) and (type(options.Condition) == "function") then
								local v, e = pcall(options.Condition, presses)
								if e then
									if v then
									else
										warn(debug.traceback(string.format("Error in button %s's Condition function: %s", buttonName, e), 2))
									end
								else
									return presses
								end
							end
							local args = {...}
							local a1 = args[1]
							if a1 and type(a1) == "table" then
								table.remove(args, 1)
							end
							presses = 1 + presses
							if callback and __runscript then
								task.spawn(callback, presses, ...)
							end
							return presses
						end,
						RawPress = function(...)
							local args = {...}
							local a1 = args[1]
							if a1 and (type(a1) == "table") then
								table.remove(args, 1)
							end
							if callback and __runscript then
								task.spawn(callback, presses, ...)
							end
							return presses
						end,
						Get = function()
							return callback, presses
						end,
						SetLocked = function(t, state)
							if type(t) ~= "table" then
								state = t
							end
							local last_v = lockedup
							if state == nil then
								lockedup = not lockedup
							else
								lockedup = state
							end
							if lockedup ~= last_v then
								Update()
							end
							return lockedup
						end,
						Lock = function()
							if lockedup then
							else
								lockedup = true
								Update()
							end
							return lockedup
						end,
						Unlock = function()
							if lockedup then
								lockedup = false
								Update()
							end
							return lockedup
						end,
						SetCondition = function(t, condition)
							if (type(t) ~= "table") and (condition == nil) then
								condition = t
							end
							options.Condition = condition
							return condition
						end,
						Update = Update,
						SetText = function(t, str)
							if (type(t) ~= "table") and (str == nil) then
								str = t
							end
							buttonName = str
							options.Name = str
							realButton.Text = (buttonName and tostring(buttonName)) or "???"
							return str
						end,
						SetCallback = function(t, call)
							if (type(t) ~= "table") and (call == nil) then
								call = t
							end
							options.Callback = call
							callback = call
							return call
						end
					}
					tabFunctions.Flags[buttonName], sectionFunctions.Flags[buttonName], elements[buttonName] = objectdata, objectdata, objectdata
					buttons[1 + #buttons] = objectdata
					framButtons[1 + #framButtons] = objectdata
					layoutRow(fram)
				end
				function buttons.PressAll()
					for _, v in next, buttons do
						v.Press()
					end
				end
				function buttons.UpdateAll()
					for fram, Fram in next, frames do
						if Fram and fram then
							for _, v in next, Fram do
								if v and v.Instance and fram:IsAncestorOf(v.Instance) then
									v.Update("Recursive")
								end
							end
							layoutRow(fram)
						end
					end
				end
				buttons.Update = buttons.UpdateAll
				function buttons.RemoveAll()
					for _, v in next, buttons do
						v.Remove()
					end
				end
				function buttons.Remove()
					for fram in next, frames do
						if fram then
							fram.Parent = nil
						end
					end
				end
				if #buttons == 1 then
					for k, v in next, buttons[1] do
						if buttons[k] == nil then
							buttons[k] = v
						end
					end
				end
				return buttons
			end
			sectionFunctions.CreateButton = sectionFunctions.AddButton
			sectionFunctions.NewButton = sectionFunctions.AddButton
			sectionFunctions.Button = sectionFunctions.AddButton
			function sectionFunctions:AddTextbox(options, ...)
				options = (options and (type(options) == "string") and resolvevararg("Textbox", options, ...)) or options
				local textboxName, presetValue, placeholder, callback, flagName = assert(options.Name, "Missing Name for new textbox."), options.Value, options.Placeholder, options.Callback, options.Flag or (function()
					library.unnamedtextboxes = 1 + (library.unnamedtextboxes or 0)
					return "Textbox" .. tostring(library.unnamedtextboxes)
				end)()
				if elements[flagName] ~= nil then
					warn(debug.traceback("Warning! Re-used flag '" .. flagName .. "'", 3))
				end
				local requiredtype = options.Type
				local newTextbox = Instance_new("Frame")
				local textbox = Instance_new("ImageLabel")
				local textboxInner = Instance_new("ImageLabel")
				local realTextbox = Instance_new("TextBox")
				local textboxHeadline = Instance_new("TextLabel")
				newTextbox.Name = removeSpaces((textboxName and textboxName:lower()) or "???") .. "Holder"
				newTextbox.Parent = sectionHolder
				applyCard(newTextbox)
				newTextbox.Size = UDim2.new(1, 0, 0, 42)
				textbox.Name = "textbox"
				textbox.Parent = newTextbox
				textbox.Active = true
				textbox.BackgroundColor3 = library.colors.topGradient
				local colored_textbox_BackgroundColor3 = {textbox, "BackgroundColor3", "topGradient"}
				colored[1 + #colored] = colored_textbox_BackgroundColor3
				textbox.BorderColor3 = library.colors.elementBorder
				colored[1 + #colored] = {textbox, "BorderColor3", "elementBorder"}
				textbox.Position = UDim2.fromScale(0.031, 0.48)
				textbox.Selectable = true
				textbox.Size = UDim2.fromOffset(206, 18)
				textbox.Image = "rbxassetid://2454009026"
				textbox.ImageColor3 = library.colors.bottomGradient
				local colored_textbox_ImageColor3 = {textbox, "ImageColor3", "bottomGradient"}
				colored[1 + #colored] = colored_textbox_ImageColor3
				textboxInner.Name = "textboxInner"
				textboxInner.Parent = textbox
				textboxInner.Active = true
				textboxInner.AnchorPoint = Vector2Half
				textboxInner.BackgroundColor3 = library.colors.topGradient
				colored[1 + #colored] = {textboxInner, "BackgroundColor3", "topGradient"}
				textboxInner.BorderColor3 = library.colors.elementBorder
				colored[1 + #colored] = {textboxInner, "BorderColor3", "elementBorder"}
				textboxInner.Position = UDim2ScaleHalf
				textboxInner.Selectable = true
				textboxInner.Size = UDim2.new(1, -4, 1, -4)
				textboxInner.Image = ""
				textboxInner.BackgroundTransparency = 1
				textboxInner.BorderSizePixel = 0
				textboxInner.ImageColor3 = library.colors.bottomGradient
				colored[1 + #colored] = {textboxInner, "ImageColor3", "bottomGradient"}
				realTextbox.Name = "realTextbox"
				if options.Rich or options.RichText or options.RichTextBox then
					realTextbox.RichText = true
				end
				if options.MultiLine or options.Lines then
					realTextbox.MultiLine = true
				end
				if options.Font or options.TextFont then
					realTextbox.Font = options.Font
				end
				if options.TextScaled or options.Scaled then
					realTextbox.TextScaled = true
				end
				realTextbox.BackgroundColor3 = WhiteColor3
				realTextbox.BackgroundTransparency = 1
				realTextbox.Position = UDim2.new(0.0295485705)
				realTextbox.Size = UDim2.fromScale(0.97, 1)
				realTextbox.ZIndex = 5
				realTextbox.Font = Enum.Font.GothamBold
				realTextbox.LineHeight = 1.15
				realTextbox.Text = tostring(presetValue)
				realTextbox.TextColor3 = library.colors.otherElementText
				colored[1 + #colored] = {realTextbox, "TextColor3", "otherElementText"}
				realTextbox.TextSize = 12
				if options.ClearTextOnFocus or options.ClearText then
					realTextbox.ClearTextOnFocus = true
				else
					realTextbox.ClearTextOnFocus = false
				end
				realTextbox.PlaceholderText = (placeholder ~= nil and tostring(placeholder)) or (presetValue ~= nil and tostring(presetValue)) or ""
				realTextbox.TextXAlignment = Enum.TextXAlignment.Left
				if options.CustomProperties and (type(options.CustomProperties) == "table") then
					for k, v in next, options.CustomProperties do
						local oof, e = pcall(function()
							realTextbox[k] = v
						end)
						if oof then
						elseif e then
							warn("Error setting Textbox", flagName, "|", e, debug.traceback(""))
						end
					end
				end
				realTextbox.Parent = textbox
				textboxHeadline.Name = "textboxHeadline"
				textboxHeadline.Parent = newTextbox
				textboxHeadline.Active = true
				textboxHeadline.BackgroundColor3 = WhiteColor3
				textboxHeadline.BackgroundTransparency = 1
				textboxHeadline.Position = UDim2.new(0.031)
				textboxHeadline.Selectable = true
				textboxHeadline.Size = UDim2.fromOffset(206, 20)
				textboxHeadline.ZIndex = 5
				textboxHeadline.Font = Enum.Font.GothamBold
				textboxHeadline.LineHeight = 1.15
				textboxHeadline.Text = (textboxName and tostring(textboxName)) or "???"
				textboxHeadline.TextColor3 = library.colors.elementText
				colored[1 + #colored] = {textboxHeadline, "TextColor3", "elementText"}
				textboxHeadline.TextSize = 12
				textboxHeadline.TextXAlignment = Enum.TextXAlignment.Left
				sectionFunctions:Update()
				local last_v = presetValue
				local function resolvevalue(val)
					if options.PreFormat then
						local typ = type(options.PreFormat)
						if typ == "function" then
							local x, e = pcall(options.PreFormat, val)
							if x then
							elseif e then
								warn("Error in Pre-Format (Textbox " .. flagName .. "):", e)
							else
								val = e
							end
						end
					end
					if requiredtype == "number" then
						if options.Hex or options.Binary or options.Base then
							val = tonumber(val, (options.Hex and 16) or (options.Binary and 2) or options.Base or 10) or 0
						else
							val = tonumber(val) or tonumber(val:gsub("%D", ""), 10) or 0
						end
						if options.Max or options.Min then
							val = math.clamp(val, options.Min or -math.huge, options.Max or math.huge)
						end
						local decimalprecision = tonumber(options.Decimals or options.Precision or options.Precise)
						if decimalprecision then
							val = tonumber(string.format("%0." .. tostring(decimalprecision) .. "f", val))
						end
					end
					if options.PostFormat then
						local typ = type(options.PostFormat)
						if typ == "function" then
							local x, e = pcall(options.PostFormat, val)
							if x then
							elseif e then
								warn("Error in Post-Format (Textbox " .. flagName .. "):", e)
							else
								val = e
							end
						end
					end
					return (val and tonumber(val)) or val
				end
				library.signals[1 + #library.signals] = realTextbox.FocusLost:Connect(function()
					last_v = library_flags[flagName]
					local val = resolvevalue(realTextbox.Text)
					library_flags[flagName] = val
					if options.Location then
						options.Location[options.LocationFlag or flagName] = val
					end
					if __runscript and callback and (last_v ~= val) then
						task.spawn(callback, tostring(val), last_v, realTextbox)
					end
				end)
				library.signals[1 + #library.signals] = newTextbox.MouseEnter:Connect(function()
					colored_textbox_BackgroundColor3[3] = "main"
					colored_textbox_BackgroundColor3[4] = 1.5
					colored_textbox_ImageColor3[3] = "main"
					colored_textbox_ImageColor3[4] = 2.5
					tweenService:Create(textbox, TweenInfo.new(0.35, library.configuration.easingStyle, library.configuration.easingDirection), {
						BackgroundColor3 = darkenColor(library.colors.main, 1.5),
						ImageColor3 = darkenColor(library.colors.main, 2.5)
					}):Play()
				end)
				library.signals[1 + #library.signals] = newTextbox.MouseLeave:Connect(function()
					colored_textbox_BackgroundColor3[3] = "topGradient"
					colored_textbox_BackgroundColor3[4] = nil
					colored_textbox_ImageColor3[3] = "bottomGradient"
					colored_textbox_ImageColor3[4] = nil
					tweenService:Create(textbox, TweenInfo.new(0.35, library.configuration.easingStyle, library.configuration.easingDirection), {
						BackgroundColor3 = library.colors.topGradient,
						ImageColor3 = library.colors.bottomGradient
					}):Play()
				end)
				local function set(t, str)
					if (nil == str) and (t ~= nil) then
						str = t
					end
					last_v = library_flags[flagName]
					library_flags[flagName] = str
					if options.Location then
						options.Location[options.LocationFlag or flagName] = str
					end
					local sstr = ((str ~= nil) and tostring(str)) or "Empty Text"
					if realTextbox.Text ~= sstr then
						realTextbox.Text = sstr
					end
					if callback and __runscript and ((last_v ~= str) or options.AllowDuplicateCalls) then
						task.spawn(callback, str, last_v, realTextbox)
					end
					return str
				end
				if presetValue ~= nil then
					set(presetValue)
				else
					library_flags[flagName] = presetValue
					if options.Location then
						options.Location[options.LocationFlag or flagName] = presetValue
					end
				end
				local default = library_flags[flagName]
				local function update()
					textboxName, placeholder, callback = options.Name or textboxName, options.Placeholder or placeholder, options.Callback
					local str = library_flags[flagName]
					str = ((str ~= nil) and tostring(str)) or "Empty Text"
					if realTextbox.Text ~= str then
						realTextbox.Text = str
					end
					textboxHeadline.Text = (textboxName and tostring(textboxName)) or "???"
					return str
				end
				local objectdata = {
					Options = options,
					Name = flagName,
					Flag = flagName,
					Type = "Textbox",
					Default = default,
					Parent = sectionFunctions,
					Instance = realTextbox,
					Get = function()
						return library_flags[flagName]
					end,
					Set = set,
					Update = update,
					Remove = function()
						if newTextbox then
							newTextbox.Parent = nil
							sectionFunctions:Update()
						end
					end,
					RawSet = function(t, str)
						if (t ~= nil) and (str == nil) then
							str = t
						end
						last_v = library_flags[flagName]
						library_flags[flagName] = str
						if options.Location then
							options.Location[options.LocationFlag or flagName] = str
						end
						update()
						return str
					end,
					Reset = function()
						return set(nil, default)
					end
				}
				tabFunctions.Flags[flagName], sectionFunctions.Flags[flagName], elements[flagName] = objectdata, objectdata, objectdata
				return objectdata
			end
			sectionFunctions.AddTextBox = sectionFunctions.AddTextbox
			sectionFunctions.NewTextBox = sectionFunctions.AddTextbox
			sectionFunctions.CreateTextBox = sectionFunctions.AddTextbox
			sectionFunctions.TextBox = sectionFunctions.AddTextbox
			sectionFunctions.NewTextbox = sectionFunctions.AddTextbox
			sectionFunctions.CreateTextbox = sectionFunctions.AddTextbox
			sectionFunctions.Textbox = sectionFunctions.AddTextbox
			sectionFunctions.Box = sectionFunctions.AddTextbox
			function sectionFunctions:AddKeybind(options, ...)
				options = (options and type(options) == "string" and resolvevararg("Keybind", options, ...)) or options
				local keybindName, presetKeybind, callback, presscallback, flag = assert(options.Name, "Missing Name for new keybind."), options.Value, options.Callback, options.Pressed, options.Flag or (function()
					library.unnamedkeybinds = 1 + (library.unnamedkeybinds or 0)
					return "Keybind" .. tostring(library.unnamedkeybinds)
				end)()
				local IsCore = (options.CoreBinding and true) or nil
				if elements[flag] ~= nil then
					warn(debug.traceback("Warning! Re-used flag '" .. flag .. "'", 3))
				end
				library.keyHandler = keyHandler
				local keyHandler = options.KeyNames or keyHandler
				local newKeybind = Instance_new("Frame")
				local keybindHeadline = Instance_new("TextLabel")
				local keybindPositioner = Instance_new("Frame")
				local keybindList = Instance_new("UIListLayout")
				local keybindButton = Instance_new("TextButton")
				local bindedKey = presetKeybind
				local justBinded = false
				local keyName = (presetKeybind and tostring(presetKeybind):gsub("Enum.KeyCode.", "") or "")
				newKeybind.Name = "newKeybind"
				newKeybind.Parent = sectionHolder
				applyCard(newKeybind)
				newKeybind.Size = UDim2.new(1, 0, 0, 28)
				keybindHeadline.Name = "keybindHeadline"
				keybindHeadline.Parent = newKeybind
				keybindHeadline.BackgroundColor3 = WhiteColor3
				keybindHeadline.BackgroundTransparency = 1
				keybindHeadline.Position = UDim2.new(0, 10, 0.5, -6)
				keybindHeadline.Size = UDim2.fromOffset(215, 12)
				keybindHeadline.Font = Enum.Font.GothamBold
				keybindHeadline.Text = (keybindName and tostring(keybindName)) or "???"
				keybindHeadline.TextColor3 = library.colors.elementText
				colored[1 + #colored] = {keybindHeadline, "TextColor3", "elementText"}
				keybindHeadline.TextSize = 12
				keybindHeadline.TextXAlignment = Enum.TextXAlignment.Left
				keybindPositioner.Name = "keybindPositioner"
				keybindPositioner.Parent = newKeybind
				keybindPositioner.BackgroundColor3 = WhiteColor3
				keybindPositioner.BackgroundTransparency = 1
				keybindPositioner.Position = UDim2.new(0, 0, 0, 0)
				keybindPositioner.Size = UDim2.new(1, -10, 1, 0)
				keybindList.Name = "keybindList"
				keybindList.Parent = keybindPositioner
				keybindList.FillDirection = Enum.FillDirection.Horizontal
				keybindList.HorizontalAlignment = Enum.HorizontalAlignment.Right
				keybindList.SortOrder = Enum.SortOrder.LayoutOrder
				keybindList.VerticalAlignment = Enum.VerticalAlignment.Center
				keybindButton.Name = "keybindButton"
				keybindButton.Parent = keybindPositioner
				keybindButton.Active = false
				keybindButton.BackgroundColor3 = WhiteColor3
				keybindButton.BackgroundTransparency = 1
				keybindButton.Position = UDim2.fromScale(0.598130822, 0.184210524)
				keybindButton.Selectable = false
				keybindButton.Size = UDim2.fromOffset(46, 12)
				keybindButton.Font = Enum.Font.GothamBold
				keybindButton.Text = (presetKeybind and tostring(presetKeybind):gsub("Enum.KeyCode.", "")) or "[NONE]"
				keybindButton.TextColor3 = library.colors.otherElementText
				local colored_keybindButton_TextColor3 = {keybindButton, "TextColor3", "otherElementText"}
				colored[1 + #colored] = colored_keybindButton_TextColor3
				keybindButton.TextSize = 12
				keybindButton.TextXAlignment = Enum.TextXAlignment.Right
				keybindButton.Size = UDim2.fromOffset(textToSize(keybindButton).X + 4, 12)
				sectionFunctions:Update()
				local last_v = bindedKey or presetKeybind
				local function newkey()
					local IgnoreKey
					if IsCore then
						IgnoreKey = tick()
						IgnoreCoreInputs = IgnoreKey
					end
					local old_texts = keybindButton.Text
					colored_keybindButton_TextColor3[3] = "main"
					colored_keybindButton_TextColor3[4] = nil
					tweenService:Create(keybindButton, TweenInfo.new(0.35, library.configuration.easingStyle, library.configuration.easingDirection), {
						TextColor3 = library.colors.main
					}):Play()
					if last_v then
						keybindButton.Text = "(Was " .. (last_v and tostring(last_v):gsub("Enum.KeyCode.", "") or "[NONE]") .. ") [...]"
					else
						keybindButton.Text = "[...]"
					end
					local receivingKey
					receivingKey = userInputService.InputBegan:Connect(function(key)
						last_v = library_flags[flag]
						if keyHandler.notAllowedKeys[key.KeyCode] then
						else
							if key.KeyCode ~= Enum.KeyCode.Unknown then
								bindedKey = ((key.KeyCode ~= Enum.KeyCode.Escape) and key.KeyCode) or library_flags[flag]
								library_flags[flag] = bindedKey
								if options.Location then
									options.Location[options.LocationFlag or flag] = bindedKey
								end
								if bindedKey then
									keyName = keyHandler.allowedKeys[bindedKey]
									keybindButton.Text = "[" .. (keyName or bindedKey.Name or tostring(key.KeyCode):gsub("Enum.KeyCode.", "")) .. "]"
									keybindButton.Size = UDim2.fromOffset(textToSize(keybindButton).X + 4, 12)
									justBinded = true
									colored_keybindButton_TextColor3[3] = "otherElementText"
									colored_keybindButton_TextColor3[4] = nil
									tweenService:Create(keybindButton, TweenInfo.new(0.35, library.configuration.easingStyle, library.configuration.easingDirection), {
										TextColor3 = library.colors.otherElementText
									}):Play()
									receivingKey:Disconnect()
								end
								if callback and __runscript and (last_v ~= bindedKey) then
									task.spawn(callback, bindedKey, last_v)
								end
								if IsCore then
									delay(0.1, function()
										if IgnoreCoreInputs and (IgnoreCoreInputs == IgnoreKey) then
											IgnoreCoreInputs = nil
										end
									end)
								end
								return
							elseif (key.KeyCode == Enum.KeyCode.Unknown) and not keyHandler.notAllowedMouseInputs[key.UserInputType] then
								bindedKey = key.UserInputType
								library_flags[flag] = bindedKey
								if options.Location then
									options.Location[options.LocationFlag or flag] = bindedKey
								end
								keyName = ((key == nil) and "NONE") or keyHandler.allowedKeys[key]
								keybindButton.Text = "[" .. (keyName or bindedKey.Name or tostring(key.KeyCode):gsub("Enum.KeyCode.", "")) .. "]"
								keybindButton.Size = UDim2.fromOffset(textToSize(keybindButton).X + 4, 12)
								justBinded = true
								colored_keybindButton_TextColor3[3] = "otherElementText"
								colored_keybindButton_TextColor3[4] = nil
								tweenService:Create(keybindButton, TweenInfo.new(0.35, library.configuration.easingStyle, library.configuration.easingDirection), {
									TextColor3 = library.colors.otherElementText
								}):Play()
								receivingKey:Disconnect()
								if callback and __runscript and (last_v ~= bindedKey) then
									task.spawn(callback, bindedKey, last_v)
								end
								if IsCore then
									delay(0.1, function()
										if IgnoreCoreInputs and (IgnoreCoreInputs == IgnoreKey) then
											IgnoreCoreInputs = nil
										end
									end)
								end
								return
							end
						end
						if (key.KeyCode == Enum.KeyCode.Backspace) or (Enum.KeyCode.Escape == key.KeyCode) then
							old_texts, bindedKey = "[NONE]", nil
						end
						keybindButton.Text = old_texts
						colored_keybindButton_TextColor3[3] = "otherElementText"
						colored_keybindButton_TextColor3[4] = nil
						tweenService:Create(keybindButton, TweenInfo.new(0.35, library.configuration.easingStyle, library.configuration.easingDirection), {
							TextColor3 = library.colors.otherElementText
						}):Play()
						receivingKey:Disconnect()
						if callback and __runscript(last_v ~= bindedKey) then
							task.spawn(callback, bindedKey, last_v)
						end
					end)
					library.signals[1 + #library.signals] = receivingKey
				end
				library.signals[1 + #library.signals] = keybindButton.MouseButton1Click:Connect(newkey)
				library.signals[1 + #library.signals] = newKeybind.InputEnded:Connect(function(input)
					if submenuOpen or library.colorpicker or (input.UserInputType ~= Enum.UserInputType.MouseButton1) then
					else
						newkey()
					end
				end)
				if presscallback then
					library.signals[1 + #library.signals] = userInputService.InputBegan:Connect(function(key, chatting)
						if keyHandler.notAllowedKeys[key.KeyCode] or keyHandler.notAllowedMouseInputs[key.UserInputType] then
						else
							if (justBinded or (bindedKey ~= key.UserInputType)) and (justBinded or chatting or (bindedKey ~= key.KeyCode)) then
							else
								if presscallback then
									task.spawn(presscallback, key, chatting)
								end
							end
							if justBinded then
								justBinded = false
							end
						end
					end)
				end
				local function set(t, key)
					if (nil == key) and (t ~= nil) then
						key = t
					end
					if (key == "nil") or (key == "NONE") or (key == "none") then
						key = nil
					end
					last_v = library_flags[flag]
					bindedKey = key
					library_flags[flag] = key
					if options.Location then
						options.Location[options.LocationFlag or flag] = key
					end
					keyName = (key == nil and "NONE") or keyHandler.allowedKeys[key]
					keybindButton.Text = "[" .. (keyName or key.Name or tostring(key):gsub("Enum.KeyCode.", "")) .. "]"
					keybindButton.Size = UDim2.fromOffset(textToSize(keybindButton).X + 4, 12)
					justBinded = true
					colored_keybindButton_TextColor3[3] = "otherElementText"
					colored_keybindButton_TextColor3[4] = nil
					tweenService:Create(keybindButton, TweenInfo.new(0.35, library.configuration.easingStyle, library.configuration.easingDirection), {
						TextColor3 = library.colors.otherElementText
					}):Play()
					if callback and __runscript and ((last_v ~= key) or options.AllowDuplicateCalls) then
						task.spawn(callback, key, last_v)
					end
					return key
				end
				if presetKeybind ~= nil then
					set(presetKeybind)
				else
					library_flags[flag] = bindedKey
					if options.Location then
						options.Location[options.LocationFlag or flag] = bindedKey
					end
				end
				local default = library_flags[flag]
				local function update()
					keybindName, callback, presscallback = options.Name or keybindName, options.Callback, options.Pressed
					local key = library_flags[flag]
					keyName = ((key == nil) and "NONE") or keyHandler.allowedKeys[key]
					keybindButton.Text = "[" .. (keyName or key.Name or tostring(key):gsub("Enum.KeyCode.", "")) .. "]"
					keybindButton.Size = UDim2.fromOffset(textToSize(keybindButton).X + 4, 12)
					colored_keybindButton_TextColor3[3] = "otherElementText"
					colored_keybindButton_TextColor3[4] = nil
					tweenService:Create(keybindButton, TweenInfo.new(0.35, library.configuration.easingStyle, library.configuration.easingDirection), {
						TextColor3 = library.colors.otherElementText
					}):Play()
					keybindHeadline.Text = (keybindName and tostring(keybindName)) or "???"
					return key
				end
				local objectdata = {
					Options = options,
					Name = flag,
					Flag = flag,
					Type = "Keybind",
					Default = default,
					Parent = sectionFunctions,
					Instance = keybindButton,
					Get = function()
						return library_flags[flag]
					end,
					Set = set,
					Remove = function()
						if newKeybind then
							newKeybind.Parent = nil
							sectionFunctions:Update()
						end
					end,
					RawSet = function(t, key)
						if (nil == key) and (t ~= nil) then
							key = t
						end
						if (key == "nil") or (key == "NONE") or (key == "none") then
							key = nil
						end
						last_v = library_flags[flag]
						bindedKey = key
						library_flags[flag] = key
						if options.Location then
							options.Location[options.LocationFlag or flag] = key
						end
						justBinded = true
						return key
					end,
					Update = update,
					Reset = function()
						return set(nil, default)
					end
				}
				tabFunctions.Flags[flag], sectionFunctions.Flags[flag], elements[flag] = objectdata, objectdata, objectdata
				return objectdata
			end
			sectionFunctions.NewKeybind = sectionFunctions.AddKeybind
			sectionFunctions.CreateKeybind = sectionFunctions.AddKeybind
			sectionFunctions.Keybind = sectionFunctions.AddKeybind
			sectionFunctions.Bind = sectionFunctions.AddKeybind
			function sectionFunctions:AddLabel(options, ...)
				options = (options and (type(options) == "string") and resolvevararg("Label", options, ...)) or options
				local labelName, flag = options.Text or options.Value or options.Name, options.Flag or (function()
					library.unnamedlabels = 1 + (library.unnamedlabels or 0)
					return "Label" .. tostring(library.unnamedlabels)
				end)()
				if elements[flag] ~= nil then
					warn(debug.traceback("Warning! Re-used flag '" .. flag .. "'", 3))
				end
				local newLabel = Instance_new("Frame")
				local labelHeadline = Instance_new("TextLabel")
				local labelPositioner = Instance_new("Frame")
				local labelButton = Instance_new("TextButton")
				newLabel.Name = "newLabel"
				newLabel.Parent = sectionHolder
				newLabel.BackgroundColor3 = WhiteColor3
				newLabel.BackgroundTransparency = 1
				newLabel.Size = UDim2.new(1, 0, 0, 22)
				labelHeadline.Name = "labelHeadline"
				labelHeadline.Parent = newLabel
				labelHeadline.BackgroundColor3 = WhiteColor3
				labelHeadline.BackgroundTransparency = 1
				labelHeadline.Position = UDim2.new(0, 4, 0, 0)
				labelHeadline.Size = UDim2.new(1, -8, 1, 0)
				labelHeadline.Font = Enum.Font.GothamMedium
				labelHeadline.Text = (labelName and tostring(labelName)) or "Empty Text"
				labelHeadline.TextColor3 = library.colors.elementText
				colored[1 + #colored] = {labelHeadline, "TextColor3", "elementText"}
				labelHeadline.TextSize = 12
				labelHeadline.TextXAlignment = Enum.TextXAlignment.Left
				labelHeadline.TextTruncate = Enum.TextTruncate.AtEnd
				labelPositioner.Name = "labelPositioner"
				labelPositioner.Parent = newLabel
				labelPositioner.BackgroundColor3 = WhiteColor3
				labelPositioner.BackgroundTransparency = 1
				labelPositioner.Position = UDim2.new(0.00448430516)
				labelPositioner.Size = UDim2.fromOffset(214, 19)
				sectionFunctions:Update()
				local function set(t, str)
					if (nil == str) and (t ~= nil) then
						str = t
					end
					labelHeadline.Text = ((nil ~= str) and tostring(str)) or "Empty Text"
					return str
				end
				local default = labelHeadline.Text
				local objectdata = {
					Options = options,
					Name = flag,
					Flag = flag,
					Type = "Label",
					Default = default,
					Parent = sectionFunctions,
					Instance = labelHeadline,
					Get = function()
						return labelHeadline.Text, labelHeadline
					end,
					Set = set,
					SetText = set,
					Remove = function()
						if newLabel then
							newLabel.Parent = nil
							sectionFunctions:Update()
						end
					end,
					RawSet = set,
					Update = function()
						return labelHeadline.Text
					end,
					Reset = function()
						return set(nil, default)
					end
				}
				tabFunctions.Flags[flag], sectionFunctions.Flags[flag], elements[flag] = objectdata, objectdata, objectdata
				return objectdata
			end
			sectionFunctions.NewLabel = sectionFunctions.AddLabel
			sectionFunctions.CreateLabel = sectionFunctions.AddLabel
			sectionFunctions.Label = sectionFunctions.AddLabel
			sectionFunctions.Text = sectionFunctions.AddLabel
			-- Game card: map icon, name, creator, "Premium" badge and a grid of live stats
			-- options: Info (table with fields + Listen), Perf (table with .FPS), GetPing (function), Badge (string)
			function sectionFunctions:AddGameCard(options)
				options = options or {}
				local info = options.Info or {}
				local perf = options.Perf or {}
				local CARD_H = 174
				local WHITE = Color3.fromRGB(255, 255, 255)
				local card = Instance_new("Frame")
				card.Name = "gameCard"
				card.Parent = sectionHolder
				applyCard(card)
				card.Size = UDim2.new(1, 0, 0, CARD_H)
				card.ClipsDescendants = true
				-- map cover image behind the header (falls back to the big map icon until the cover loads)
				local banner = Instance_new("ImageLabel")
				banner.Name = "cover"
				banner.Parent = card
				banner.BackgroundColor3 = library.colors.background
				colored[1 + #colored] = {banner, "BackgroundColor3", "background"}
				banner.BorderSizePixel = 0
				banner.Size = UDim2.new(1, 0, 0, 80)
				banner.ScaleType = Enum.ScaleType.Crop
				banner.ZIndex = 1
				if game.GameId and (game.GameId ~= 0) then
					banner.Image = "rbxthumb://type=GameIcon&id=" .. tostring(game.GameId) .. "&w=420&h=420"
				end
				-- dim layer so the text stays readable on any cover
				local dim = Instance_new("Frame")
				dim.Name = "coverDim"
				dim.Parent = card
				dim.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
				dim.BackgroundTransparency = 0.45
				dim.BorderSizePixel = 0
				dim.Size = UDim2.new(1, 0, 0, 80)
				dim.ZIndex = 2
				-- fade the bottom of the cover into the card
				local fade = Instance_new("Frame")
				fade.Name = "coverFade"
				fade.Parent = card
				fade.BackgroundColor3 = library.colors.unselectedOption
				colored[1 + #colored] = {fade, "BackgroundColor3", "unselectedOption"}
				fade.BorderSizePixel = 0
				fade.Position = UDim2.fromOffset(0, 40)
				fade.Size = UDim2.new(1, 0, 0, 40)
				fade.ZIndex = 2
				local fadeGradient = Instance_new("UIGradient")
				fadeGradient.Rotation = 90
				fadeGradient.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)})
				fadeGradient.Parent = fade
				-- map icon
				local icon = Instance_new("ImageLabel")
				icon.Name = "mapIcon"
				icon.Parent = card
				icon.BackgroundColor3 = library.colors.background
				colored[1 + #colored] = {icon, "BackgroundColor3", "background"}
				icon.BorderSizePixel = 0
				icon.Position = UDim2.fromOffset(10, 10)
				icon.Size = UDim2.fromOffset(58, 58)
				icon.ScaleType = Enum.ScaleType.Crop
				icon.ZIndex = 3
				if game.GameId and (game.GameId ~= 0) then
					icon.Image = "rbxthumb://type=GameIcon&id=" .. tostring(game.GameId) .. "&w=150&h=150"
				else
					icon.Image = "rbxassetid://132029940467197"
				end
				local iconCorner = Instance_new("UICorner")
				iconCorner.CornerRadius = UDim.new(0, 12)
				iconCorner.Parent = icon
				local iconStroke = Instance_new("UIStroke")
				iconStroke.Thickness = 1.5
				iconStroke.Transparency = 0.25
				iconStroke.Color = library.colors.main
				colored[1 + #colored] = {iconStroke, "Color", "main"}
				iconStroke.Parent = icon
				local function makeText(parent, text, size, font, colorName, pos, w, h, align)
					local l = Instance_new("TextLabel")
					l.BackgroundTransparency = 1
					l.BorderSizePixel = 0
					l.Font = font
					l.Text = text
					l.TextSize = size
					l.TextColor3 = library.colors[colorName]
					colored[1 + #colored] = {l, "TextColor3", colorName}
					l.TextXAlignment = align or Enum.TextXAlignment.Left
					l.TextTruncate = Enum.TextTruncate.AtEnd
					l.Position = pos
					l.Size = UDim2.new(w[1], w[2], 0, h)
					l.ZIndex = 4
					l.Parent = parent
					return l
				end
				local nameLabel = makeText(card, "Loading...", 15, Enum.Font.GothamBold, "elementText", UDim2.fromOffset(78, 11), {1, -88}, 18)
				local creatorLabel = makeText(card, "", 11, Enum.Font.Gotham, "otherElementText", UDim2.fromOffset(78, 31), {1, -88}, 14)
				-- badges
				local function makeBadge(text, x, w, accent)
					local b = Instance_new("Frame")
					b.Name = "badge"
					b.Parent = card
					b.BackgroundColor3 = (accent and library.colors.main) or library.colors.background
					colored[1 + #colored] = {b, "BackgroundColor3", (accent and "main") or "background"}
					b.BackgroundTransparency = (accent and 0.05) or 0.2
					b.BorderSizePixel = 0
					b.Position = UDim2.fromOffset(x, 49)
					b.Size = UDim2.fromOffset(w, 17)
					b.ZIndex = 4
					local c = Instance_new("UICorner")
					c.CornerRadius = UDim.new(1, 0)
					c.Parent = b
					local t = Instance_new("TextLabel")
					t.BackgroundTransparency = 1
					t.Size = UDim2.new(1, 0, 1, 0)
					t.Font = Enum.Font.GothamBold
					t.Text = text
					t.TextSize = 9
					t.TextColor3 = (accent and WHITE) or library.colors.otherElementText
					if not accent then
						colored[1 + #colored] = {t, "TextColor3", "otherElementText"}
					end
					t.ZIndex = 5
					t.Parent = b
					return t
				end
				makeBadge(string.upper(tostring(options.Badge or "Premium")), 78, 62, true)
				local playerBadge = makeBadge("LIVE", 146, 40, false)
				-- stat chips
				local grid = Instance_new("Frame")
				grid.Name = "stats"
				grid.Parent = card
				grid.BackgroundTransparency = 1
				grid.BorderSizePixel = 0
				grid.Position = UDim2.fromOffset(8, 80)
				grid.Size = UDim2.new(1, -16, 0, 86)
				grid.ZIndex = 2
				local gridLayout = Instance_new("UIGridLayout")
				gridLayout.CellSize = UDim2.new(0.3333, -4, 0, 40)
				gridLayout.CellPadding = UDim2.fromOffset(6, 6)
				gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
				gridLayout.Parent = grid
				local chips = {}
				local function makeChip(order, caption)
					local chip = Instance_new("Frame")
					chip.Name = caption
					chip.Parent = grid
					chip.LayoutOrder = order
					chip.BackgroundColor3 = library.colors.sectionBackground
					colored[1 + #colored] = {chip, "BackgroundColor3", "sectionBackground"}
					chip.BorderSizePixel = 0
					chip.ZIndex = 3
					local c = Instance_new("UICorner")
					c.CornerRadius = UDim.new(0, 7)
					c.Parent = chip
					local value = makeText(chip, "--", 13, Enum.Font.GothamBold, "elementText", UDim2.fromOffset(0, 5), {1, 0}, 18, Enum.TextXAlignment.Center)
					makeText(chip, caption, 9, Enum.Font.GothamMedium, "otherElementText", UDim2.fromOffset(0, 23), {1, 0}, 12, Enum.TextXAlignment.Center)
					chips[caption] = value
					return value
				end
				makeChip(1, "PLAYERS")
				makeChip(2, "PING")
				makeChip(3, "FPS")
				makeChip(4, "UPTIME")
				makeChip(5, "VISITS")
				makeChip(6, "FAVORITES")
				local function fmt(n)
					n = tonumber(n)
					if not n then
						return "--"
					end
					if n >= 1e9 then
						return string.format("%.1fB", n / 1e9)
					elseif n >= 1e6 then
						return string.format("%.1fM", n / 1e6)
					elseif n >= 1e3 then
						return string.format("%.1fK", n / 1e3)
					end
					return tostring(math.floor(n))
				end
				local function refreshInfo()
					nameLabel.Text = tostring(info.Name or "Unknown")
					local by = tostring(info.Creator or "")
					creatorLabel.Text = (by ~= "" and ("by " .. by)) or ""
					if info.CoverId then
						banner.Image = "rbxthumb://type=Asset&id=" .. tostring(info.CoverId) .. "&w=768&h=432"
					end
					chips.VISITS.Text = fmt(info.Visits)
					chips.FAVORITES.Text = fmt(info.Favorites)
				end
				local function refreshLive()
					local count = #game:GetService("Players"):GetPlayers()
					local maxp = info.MaxPlayers or game:GetService("Players").MaxPlayers
					chips.PLAYERS.Text = tostring(count) .. "/" .. tostring(maxp or "?")
					local ping = options.GetPing and options.GetPing()
					chips.PING.Text = (ping and (tostring(ping) .. " ms")) or "--"
					chips.FPS.Text = tostring(math.floor(perf.FPS or 0))
					local t = math.floor(game:GetService("Workspace").DistributedGameTime)
					if t >= 3600 then
						chips.UPTIME.Text = string.format("%d:%02d:%02d", t // 3600, (t % 3600) // 60, t % 60)
					else
						chips.UPTIME.Text = string.format("%02d:%02d", t // 60, t % 60)
					end
				end
				if info.Listen then
					info.Listen(refreshInfo)
				else
					refreshInfo()
				end
				refreshLive()
				task.spawn(function()
					while card and card:IsDescendantOf(game) do
						pcall(refreshLive)
						task.wait(1)
					end
				end)
				sectionFunctions:Update()
				return {
					Instance = card,
					Refresh = function()
						refreshInfo()
						refreshLive()
					end,
					Remove = function()
						if card then
							card.Parent = nil
							sectionFunctions:Update()
						end
					end
				}
			end
			sectionFunctions.GameCard = sectionFunctions.AddGameCard
			-- Custom Slider (Alchemy style): label "Name : value", thin track, rounded-square knob with glow, 30px touch zone
			function sectionFunctions:AddSlider(options, ...)
				options = (options and (type(options) == "string") and resolvevararg("Slider", options, ...)) or options
				local sliderName, maxValue, minValue, presetValue, callback, flagName = assert(options.Name, "Missing Name for new slider."), assert(options.Max, "Missing Max for new slider."), assert(options.Min, "Missing Min for new slider."), options.Value, options.Callback, options.Flag or (function()
					library.unnamedsliders = 1 + (library.unnamedsliders or 0)
					return "Slider" .. tostring(library.unnamedsliders)
				end)()
				if elements[flagName] ~= nil then
					warn(debug.traceback("Warning! Re-used flag '" .. flagName .. "'", 3))
				end
				local decimalprecision = tonumber(options.Decimals or options.Precision or options.Precise)
				if decimalprecision and ((options.Max - options.Min) > 1) then
					decimalprecision = 1
				end
				if decimalprecision then
					decimalprecision = math.clamp(decimalprecision, 0, 99)
					if decimalprecision <= 0 then
						decimalprecision = nil
					else
						decimalprecision = tostring(decimalprecision)
					end
				end
				local formattyp = options.Format and type(options.Format)
				local usetextbox = options.Textbox or options.InputBox or options.CustomInput
				local startingValue = presetValue or minValue
				local sliderDragging = false
				-- plain number text (shown in the pill on the right)
				local function formatValue(val)
					if val == nil then
						return ""
					end
					if decimalprecision then
						return string.format("%0." .. decimalprecision .. "f", val)
					end
					return tostring(val)
				end
				-- text on the left: the slider name, or the developer's own Format text
				local function resolvedisplay(val, was)
					if formattyp == "string" then
						return string.format(options.Format, val)
					elseif formattyp == "function" then
						local oof, g = pcall(options.Format, val, was)
						if oof and g then
						else
							warn("Your format function for", sliderName, "Slider:", flagName, "has returned nothing. It should return a string to display.", debug.traceback(""))
							return "Format Function Errored"
						end
						return tostring(g)
					end
					return tostring(sliderName or "???")
				end
				local showPill = (usetextbox and true) or (not formattyp)
				local newSlider = Instance_new("Frame")
				local slider = Instance_new("Frame")
				local sliderCorner = Instance_new("UICorner")
				local sliderStroke = Instance_new("UIStroke")
				local sliderHeadline = Instance_new("TextLabel")
				local valueBox = Instance_new(usetextbox and "TextBox" or "TextLabel")
				local valueCorner = Instance_new("UICorner")
				local valuePadding = Instance_new("UIPadding")
				local hitArea = Instance_new("Frame")
				local track = Instance_new("Frame")
				local trackCorner = Instance_new("UICorner")
				local sliderColored = Instance_new("Frame")
				local fillCorner = Instance_new("UICorner")
				local knob = Instance_new("Frame")
				local knobCorner = Instance_new("UICorner")
				local knobStroke = Instance_new("UIStroke")
				-- outer wrapper (keeps the old layout slot, just taller)
				newSlider.Name = "newSlider"
				newSlider.Parent = sectionHolder
				newSlider.BackgroundColor3 = WhiteColor3
				newSlider.BackgroundTransparency = 1
				newSlider.BorderSizePixel = 0
				newSlider.Size = UDim2.new(1, 0, 0, 50)
				-- card
				slider.Name = "slider"
				slider.Parent = newSlider
				slider.BackgroundColor3 = library.colors.unselectedOption
				colored[1 + #colored] = {slider, "BackgroundColor3", "unselectedOption"}
				slider.BackgroundTransparency = 0
				slider.BorderSizePixel = 0
				slider.Position = UDim2.new(0, 0, 0, 0)
				slider.Size = UDim2.new(1, 0, 1, 0)
				sliderCorner.CornerRadius = UDim.new(0, 6)
				sliderCorner.Parent = slider
				sliderStroke.Color = library.colors.innerBorder
				colored[1 + #colored] = {sliderStroke, "Color", "innerBorder"}
				sliderStroke.Thickness = 1
				sliderStroke.Transparency = 1
				sliderStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				sliderStroke.Parent = slider
				-- name (left)
				sliderHeadline.Name = "sliderHeadline"
				sliderHeadline.Parent = slider
				sliderHeadline.BackgroundTransparency = 1
				sliderHeadline.BorderSizePixel = 0
				sliderHeadline.Position = UDim2.new(0, 10, 0, 6)
				sliderHeadline.Size = UDim2.new(1, (showPill and -84) or -20, 0, 18)
				sliderHeadline.Font = Enum.Font.GothamBold
				sliderHeadline.Text = resolvedisplay(startingValue)
				sliderHeadline.TextColor3 = library.colors.elementText
				colored[1 + #colored] = {sliderHeadline, "TextColor3", "elementText"}
				sliderHeadline.TextSize = 12
				sliderHeadline.TextXAlignment = Enum.TextXAlignment.Left
				sliderHeadline.TextTruncate = Enum.TextTruncate.AtEnd
				-- value pill (right). It is a number box when Textbox is on.
				valueBox.Name = (usetextbox and "realTextbox") or "valueLabel"
				valueBox.Parent = slider
				valueBox.AnchorPoint = Vector2.new(1, 0)
				valueBox.Position = UDim2.new(1, -8, 0, 5)
				valueBox.BackgroundColor3 = library.colors.hoveredOptionTop
				colored[1 + #colored] = {valueBox, "BackgroundColor3", "hoveredOptionTop"}
				valueBox.BorderSizePixel = 0
				valueBox.Font = Enum.Font.GothamBold
				valueBox.Text = (usetextbox and tostring(startingValue)) or formatValue(startingValue)
				valueBox.TextColor3 = library.colors.elementText
				colored[1 + #colored] = {valueBox, "TextColor3", "elementText"}
				valueBox.TextSize = 12
				valueBox.Visible = showPill
				valueCorner.CornerRadius = UDim.new(0, 5)
				valueCorner.Parent = valueBox
				if usetextbox then
					valueBox.Size = UDim2.fromOffset(58, 22)
					valueBox.ClearTextOnFocus = false
					valueBox.PlaceholderText = ""
				else
					valuePadding.PaddingLeft = UDim.new(0, 8)
					valuePadding.PaddingRight = UDim.new(0, 8)
					valuePadding.Parent = valueBox
					valueBox.Size = UDim2.fromOffset(0, 22)
					valueBox.AutomaticSize = Enum.AutomaticSize.X
					local minSize = Instance_new("UISizeConstraint")
					minSize.MinSize = Vector2.new(50, 22)
					minSize.Parent = valueBox
				end
				-- big invisible touch zone under the name row
				hitArea.Name = "hitArea"
				hitArea.Parent = slider
				hitArea.Active = true
				hitArea.BackgroundTransparency = 1
				hitArea.BorderSizePixel = 0
				hitArea.Position = UDim2.new(0, 0, 0, 24)
				hitArea.Size = UDim2.new(1, 0, 1, -24)
				-- track
				track.Name = "track"
				track.Parent = hitArea
				track.AnchorPoint = Vector2.new(0, 0.5)
				track.BackgroundColor3 = library.colors.innerBorder
				colored[1 + #colored] = {track, "BackgroundColor3", "innerBorder"}
				track.BorderSizePixel = 0
				track.Position = UDim2.new(0, 16, 0.5, 0)
				track.Size = UDim2.new(1, -32, 0, 4)
				trackCorner.CornerRadius = UDim.new(1, 0)
				trackCorner.Parent = track
				-- colored fill
				sliderColored.Name = "sliderColored"
				sliderColored.Parent = track
				sliderColored.BackgroundColor3 = library.colors.main
				colored[1 + #colored] = {sliderColored, "BackgroundColor3", "main"}
				sliderColored.BorderSizePixel = 0
				sliderColored.Size = UDim2.new(0, 0, 1, 0)
				fillCorner.CornerRadius = UDim.new(1, 0)
				fillCorner.Parent = sliderColored
				-- knob
				knob.Name = "knob"
				knob.Parent = track
				knob.AnchorPoint = Vector2.new(0.5, 0.5)
				knob.BackgroundColor3 = library.colors.main
				colored[1 + #colored] = {knob, "BackgroundColor3", "main"}
				knob.BorderSizePixel = 0
				knob.Position = UDim2.new(0, 0, 0.5, 0)
				knob.Size = UDim2.fromOffset(14, 14)
				knob.ZIndex = 2
				knobCorner.CornerRadius = UDim.new(1, 0)
				knobCorner.Parent = knob
				knobStroke.Color = library.colors.main
				colored[1 + #colored] = {knobStroke, "Color", "main"}
				knobStroke.Thickness = 3
				knobStroke.Transparency = 0.72
				knobStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				knobStroke.Parent = knob
				-- value <-> position helpers
				local fillTween, knobTween
				local function toScale(v)
					local range = (maxValue or 0) - (minValue or 0)
					if (type(v) ~= "number") or (range == 0) then
						return 0
					end
					return math.clamp((v - minValue) / range, 0, 1)
				end
				local function render(scale, animate)
					if fillTween then
						fillTween:Cancel()
						fillTween = nil
					end
					if knobTween then
						knobTween:Cancel()
						knobTween = nil
					end
					if animate then
						local info = TweenInfo.new(0.25, library.configuration.easingStyle, library.configuration.easingDirection)
						fillTween = tweenService:Create(sliderColored, info, {
							Size = UDim2.new(scale, 0, 1, 0)
						})
						knobTween = tweenService:Create(knob, info, {
							Position = UDim2.new(scale, 0, 0.5, 0)
						})
						fillTween:Play()
						knobTween:Play()
					else
						sliderColored.Size = UDim2.new(scale, 0, 1, 0)
						knob.Position = UDim2.new(scale, 0, 0.5, 0)
					end
				end
				local function refreshTexts(val, was)
					sliderHeadline.Text = resolvedisplay(val, was)
					if usetextbox then
						valueBox.Text = tostring(val)
					elseif not formattyp then
						valueBox.Text = formatValue(val)
					end
				end
				render(toScale(startingValue), false)
				local realTextbox = (usetextbox and valueBox) or nil
				local function Set(t, newValue)
					if (nil == newValue) and (t ~= nil) then
						newValue = t
					end
					minValue, maxValue = options.Min, options.Max
					if newValue and (options.IllegalInput or ((not minValue or (newValue >= minValue)) and (not maxValue or (newValue <= maxValue)))) then
						local last_val = library_flags[flagName]
						library_flags[flagName] = newValue
						if options.Location then
							options.Location[options.LocationFlag or flagName] = newValue
						end
						render(toScale((options.IllegalInput and math.clamp(newValue, minValue or -math.huge, maxValue or math.huge)) or newValue), true)
						refreshTexts(newValue, last_val)
						if callback and __runscript and ((last_val ~= newValue) or options.AllowDuplicateCalls) then
							task.spawn(callback, newValue, last_val)
						end
					end
					return newValue
				end
				if presetValue ~= nil then
					Set(presetValue)
				else
					library_flags[flagName] = startingValue
					if options.Location then
						options.Location[options.LocationFlag or flagName] = startingValue
					end
				end
				if usetextbox then
					if type(usetextbox) ~= "table" then
						usetextbox = options
					end
					library.signals[1 + #library.signals] = realTextbox.FocusLost:Connect(function()
						local val = realTextbox.Text
						if usetextbox.PreFormat then
							local typ = type(usetextbox.PreFormat)
							if typ == "function" then
								local x, e = pcall(usetextbox.PreFormat, val)
								if x then
									val = e
								elseif e then
									warn("Error in Pre-Format (Textbox " .. flagName .. "):", e)
								end
							end
						end
						val = (not usetextbox.Hex and not usetextbox.Binary and not usetextbox.Base and (tonumber(val) or tonumber(val:gsub("%D", ""), 10) or 0)) or tonumber(val, (usetextbox.Hex and 16) or (usetextbox.Binary and 2) or usetextbox.Base or 10) or 0
						if options.IllegalInput or (options.Max and options.Min) then
						else
							val = math.clamp(val, options.Min or -math.huge, options.Max or math.huge)
						end
						local decimals = tonumber(options.Decimals or options.Precision or options.Precise)
						if decimals then
							val = tonumber(string.format("%0." .. tostring(decimals) .. "f", val))
						end
						if usetextbox.PostFormat then
							local typ = type(usetextbox.PostFormat)
							if typ == "function" then
								local x, e = pcall(usetextbox.PostFormat, val)
								if x then
									val = e
								elseif e then
									warn("Error in Post-Format (Textbox " .. flagName .. "):", e)
								end
							end
						end
						Set((val and tonumber(val)) or presetValue or 0)
						-- if the typed number was refused (out of range) put the real value back
						realTextbox.Text = tostring(library_flags[flagName])
					end)
					library.signals[1 + #library.signals] = realTextbox.Focused:Connect(function()
						tweenService:Create(sliderStroke, TweenInfo.new(0.15), {
							Color = library.colors.main
						}):Play()
					end)
					library.signals[1 + #library.signals] = realTextbox.FocusLost:Connect(function()
						if not sliderDragging then
							tweenService:Create(sliderStroke, TweenInfo.new(0.15), {
								Color = library.colors.innerBorder
							}):Play()
						end
					end)
				end
				sectionFunctions:Update()
				-- look while hovering (mouse) / pressing (finger or mouse)
				local hovering = false
				local function paintState()
					local target = library.colors.innerBorder
					if sliderDragging then
						target = library.colors.main
					elseif hovering then
						target = darkenColor(library.colors.main, 1.8)
					end
					tweenService:Create(sliderStroke, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Color = target,
						Transparency = (sliderDragging and 0.2) or (hovering and 0.55) or 1
					}):Play()
					tweenService:Create(knob, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = (sliderDragging and UDim2.fromOffset(18, 18)) or UDim2.fromOffset(14, 14)
					}):Play()
					tweenService:Create(knobStroke, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Transparency = (sliderDragging and 0.45) or (hovering and 0.6) or 0.72
					}):Play()
				end
				library.signals[1 + #library.signals] = slider.MouseEnter:Connect(function()
					hovering = true
					if not sliderDragging then
						paintState()
					end
				end)
				library.signals[1 + #library.signals] = slider.MouseLeave:Connect(function()
					hovering = false
					if not sliderDragging then
						paintState()
					end
				end)
				-- turn a finger / mouse position into a value
				local function sliding(input)
					local last_val = library_flags[flagName]
					local scale = math.clamp((input.Position.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
					local raw = scale * (maxValue - minValue) + minValue
					local sliderValue
					if decimalprecision then
						sliderValue = tonumber(string.format("%0." .. decimalprecision .. "f", raw))
					end
					sliderValue = sliderValue or tonumber(string.format("%0.2f", floor(raw + 0.5)))
					render(toScale(sliderValue), false)
					library_flags[flagName] = sliderValue
					if options.Location then
						options.Location[options.LocationFlag or flagName] = sliderValue
					end
					refreshTexts(sliderValue, last_val)
					if callback and __runscript and (last_val ~= sliderValue) then
						task.spawn(callback, sliderValue, last_val)
					end
				end
				local sliderInput, sliderStateSig
				local function endSliderDrag(input)
					-- on touch only the finger that started the drag may end it (other fingers: joystick, jump...)
					if sliderDragging and isPress(input) and ((not sliderInput) or (sliderInput.UserInputType ~= Enum.UserInputType.Touch) or (input == sliderInput)) then
						sliderDragging = false
						isDraggingSomething = false
						sliderInput = nil
						if sliderStateSig then
							sliderStateSig:Disconnect()
							sliderStateSig = nil
						end
						lockScrolling(newSlider, false)
						paintState()
					end
				end
				library.signals[1 + #library.signals] = hitArea.InputBegan:Connect(function(input)
					if library.colorpicker or isDraggingSomething or not isPress(input) then
					else
						sliderDragging = true
						isDraggingSomething = true
						sliderInput = input
						lockScrolling(newSlider, true)
						paintState()
						sliding(input)
						if sliderStateSig then
							sliderStateSig:Disconnect()
						end
						-- failsafe: if the release event gets swallowed, the slider can never stay stuck
						sliderStateSig = input.Changed:Connect(function()
							if (input.UserInputState == Enum.UserInputState.End) or (input.UserInputState == Enum.UserInputState.Cancel) then
								endSliderDrag(input)
							end
						end)
					end
				end)
				library.signals[1 + #library.signals] = hitArea.InputEnded:Connect(endSliderDrag)
				library.signals[1 + #library.signals] = userInputService.InputEnded:Connect(endSliderDrag)
				library.signals[1 + #library.signals] = userInputService.InputChanged:Connect(function(input)
					if not library.colorpicker and sliderDragging and isMove(input) and ((not sliderInput) or (sliderInput.UserInputType ~= Enum.UserInputType.Touch) or (input == sliderInput)) then
						sliding(input)
					end
				end)
				local default = library_flags[flagName]
				local function Update(t, last_val)
					if (last_val == nil) and (t ~= nil) and (type(t) ~= "table") then
						last_val = t
					end
					sliderName, maxValue, minValue, callback = options.Name or sliderName, options.Max or maxValue, options.Min or minValue, options.Callback
					local newValue = library_flags[flagName]
					if type(newValue) == "number" then
						render(toScale(math.clamp(newValue, options.Min or -math.huge, options.Max or math.huge)), true)
					end
					refreshTexts(newValue, last_val)
					return newValue
				end
				local objectdata = {
					Options = options,
					Name = flagName,
					Flag = flagName,
					Type = "Slider",
					Default = default,
					Parent = sectionFunctions,
					Instance = sliderHeadline,
					Set = Set,
					Get = function()
						return library_flags[flagName]
					end,
					SetConstraints = function(t, min, max)
						if t and type(t) ~= "table" then
							min, max = t, min
						end
						if min then
							options.Min = min
						end
						if max then
							options.Max = max
						end
						Update()
					end,
					SetMin = function(t, min)
						if min == nil and t ~= nil then
							min = t
						end
						if min and min ~= options.Min then
							options.Min = min
							Update()
						end
					end,
					SetMax = function(t, max)
						if max == nil and t ~= nil then
							max = t
						end
						if max and max ~= options.Max then
							options.Max = max
							Update()
						end
					end,
					Update = Update,
					Remove = function()
						if newSlider then
							newSlider.Parent = nil
							sectionFunctions:Update()
						end
					end,
					RawSet = function(t, newValue)
						if nil == newValue and t ~= nil then
							newValue = t
						end
						local last_val = library_flags[flagName]
						library_flags[flagName] = newValue
						if options.Location then
							options.Location[options.LocationFlag or flagName] = newValue
						end
						Update(nil, last_val)
					end,
					Reset = function()
						return Set(nil, default)
					end
				}
				tabFunctions.Flags[flagName], sectionFunctions.Flags[flagName], elements[flagName] = objectdata, objectdata, objectdata
				return objectdata
			end
			sectionFunctions.NewSlider = sectionFunctions.AddSlider
			sectionFunctions.CreateSlider = sectionFunctions.AddSlider
			sectionFunctions.NumberConstraint = sectionFunctions.AddSlider
			sectionFunctions.Slider = sectionFunctions.AddSlider
			sectionFunctions.Slide = sectionFunctions.AddSlider
			function sectionFunctions:AddSearchBox(options, ...)
				options = (options and (type(options) == "string") and resolvevararg("SearchBox", options, ...)) or options
				local dropdownName, listt, val, callback, flagName = assert(options.Name, "Missing Name for new searchbox."), assert(options.List, "Missing List for new searchbox."), options.Value, options.Callback, options.Flag or (function()
					library.unnamedsearchbox = 1 + (library.unnamedsearchbox or 0)
					return "SearchBox" .. tostring(library.unnamedsearchbox)
				end)()
				if elements[flagName] ~= nil then
					warn(debug.traceback("Warning! Re-used flag '" .. flagName .. "'", 3))
				end
				local newDropdown = Instance_new("Frame")
				local dropdown = Instance_new("ImageLabel")
				local dropdownInner = Instance_new("ImageLabel")
				local dropdownToggle = Instance_new("ImageButton")
				local dropdownSelection = Instance_new("TextBox")
				local dropdownHeadline = Instance_new("TextLabel")
				local dropdownHolderFrame = Instance_new("ImageLabel")
				local dropdownHolderInner = Instance_new("ImageLabel")
				local realDropdownHolder = Instance_new("ScrollingFrame")
				local realDropdownHolderList = Instance_new("UIListLayout")
				local dropdownEnabled = false
				local resolvelist = getresolver(listt, options.Filter)
				local list = resolvelist()
				if next(list) then
				else
					local EmptyVal = options.EmptyValue
					if EmptyVal ~= nil then
						table.insert(list, 1, EmptyVal)
					end
				end
				local multiselect = options.MultiSelect or options.Multi or options.Multiple
				local passed_multiselect = multiselect and type(multiselect)
				local actualblankstr = options.BlankValue or options.NoValueString or options.Nothing
				local blankstring = not multiselect and actualblankstr
				local selectedOption = val or list[1] or blankstring
				local addcallback = options.ItemAdded or options.AddedCallback
				local delcallback = options.ItemRemoved or options.RemovedCallback
				local clrcallback = options.ItemsCleared or options.ClearedCallback
				local modcallback = options.ItemChanged or options.ChangedCallback
				if blankstring and (val == nil) then
					val = blankstring
				end
				if val ~= nil then
					selectedOption = val
				end
				if multiselect and (not selectedOption or (type(selectedOption) ~= "table")) then
					selectedOption = {}
				end
				local selectedObjects = {}
				local optionCount = 0
				newDropdown.Name = "newDropdown"
				newDropdown.Parent = sectionHolder
				applyCard(newDropdown)
				newDropdown.Size = UDim2.new(1, 0, 0, 42)
				dropdown.Name = "dropdown"
				dropdown.Parent = newDropdown
				dropdown.Active = true
				dropdown.BackgroundColor3 = library.colors.topGradient
				local colored_dropdown_BackgroundColor3 = {dropdown, "BackgroundColor3", "topGradient"}
				colored[1 + #colored] = colored_dropdown_BackgroundColor3
				dropdown.BorderColor3 = library.colors.elementBorder
				colored[1 + #colored] = {dropdown, "BorderColor3", "elementBorder"}
				dropdown.Position = UDim2.fromScale(0.027, 0.45)
				dropdown.Selectable = true
				dropdown.Size = UDim2.fromOffset(206, 18)
				dropdown.Image = "rbxassetid://2454009026"
				dropdown.ImageColor3 = library.colors.bottomGradient
				local colored_dropdown_ImageColor3 = {dropdown, "ImageColor3", "bottomGradient"}
				colored[1 + #colored] = colored_dropdown_ImageColor3
				dropdownInner.Name = "dropdownInner"
				dropdownInner.Parent = dropdown
				dropdownInner.Active = true
				dropdownInner.AnchorPoint = Vector2Half
				dropdownInner.BackgroundColor3 = library.colors.topGradient
				colored[1 + #colored] = {dropdownInner, "BackgroundColor3", "topGradient"}
				dropdownInner.BorderColor3 = library.colors.elementBorder
				colored[1 + #colored] = {dropdownInner, "BorderColor3", "elementBorder"}
				dropdownInner.Position = UDim2ScaleHalf
				dropdownInner.Selectable = true
				dropdownInner.Size = UDim2.new(1, -4, 1, -4)
				dropdownInner.Image = "rbxassetid://2454009026"
				dropdownInner.ImageColor3 = library.colors.bottomGradient
				colored[1 + #colored] = {dropdownInner, "ImageColor3", "bottomGradient"}
				dropdownToggle.Name = "dropdownToggle"
				dropdownToggle.Parent = dropdown
				dropdownToggle.BackgroundColor3 = WhiteColor3
				dropdownToggle.BackgroundTransparency = 1
				dropdownToggle.Position = UDim2.fromScale(0.9, 0.17)
				dropdownToggle.Rotation = 90
				dropdownToggle.Size = UDim2.fromOffset(12, 12)
				dropdownToggle.ZIndex = 6
				dropdownToggle.Image = "rbxassetid://71659683"
				dropdownToggle.ImageColor3 = Color3.fromRGB(171, 171, 171)
				dropdownSelection.Name = "dropdownSelection"
				dropdownSelection.Parent = dropdown
				dropdownSelection.BackgroundColor3 = WhiteColor3
				dropdownSelection.BackgroundTransparency = 1
				dropdownSelection.Position = UDim2.new(0.0295485705)
				dropdownSelection.Size = UDim2.fromScale(0.85, 1)
				dropdownSelection.ZIndex = 5
				dropdownSelection.Font = Enum.Font.GothamBold
				dropdownSelection.LineHeight = 1.15
				dropdownSelection.Text = ResolveDropdownItemName(multiselect, passed_multiselect, options.Name, selectedOption, flagName, blankstring)
				dropdownSelection.TextColor3 = library.colors.otherElementText
				colored[1 + #colored] = {dropdownSelection, "TextColor3", "otherElementText"}
				dropdownSelection.TextSize = 12
				dropdownSelection.TextXAlignment = Enum.TextXAlignment.Left
				dropdownSelection.ClearTextOnFocus = true
				dropdownHeadline.Name = "dropdownHeadline"
				dropdownHeadline.Parent = newDropdown
				dropdownHeadline.BackgroundColor3 = WhiteColor3
				dropdownHeadline.BackgroundTransparency = 1
				dropdownHeadline.Position = UDim2.fromScale(0.034, 0.03)
				dropdownHeadline.Size = UDim2.fromOffset(167, 11)
				dropdownHeadline.Font = Enum.Font.GothamBold
				dropdownHeadline.Text = (dropdownName and tostring(dropdownName)) or "???"
				dropdownHeadline.TextColor3 = library.colors.elementText
				colored[1 + #colored] = {dropdownHeadline, "TextColor3", "elementText"}
				dropdownHeadline.TextSize = 12
				dropdownHeadline.TextXAlignment = Enum.TextXAlignment.Left
				dropdownHolderFrame.Name = "dropdownHolderFrame"
				dropdownHolderFrame.Parent = newDropdown
				dropdownHolderFrame.Active = true
				dropdownHolderFrame.BackgroundColor3 = library.colors.topGradient
				colored[1 + #colored] = {dropdownHolderFrame, "BackgroundColor3", "topGradient"}
				dropdownHolderFrame.BorderColor3 = library.colors.elementBorder
				colored[1 + #colored] = {dropdownHolderFrame, "BorderColor3", "elementBorder"}
				dropdownHolderFrame.Position = UDim2.fromScale(0.025, 1.012)
				dropdownHolderFrame.Selectable = true
				dropdownHolderFrame.Size = UDim2.fromOffset(206, 22)
				dropdownHolderFrame.Visible = false
				dropdownHolderFrame.Image = "rbxassetid://2454009026"
				dropdownHolderFrame.ImageColor3 = library.colors.bottomGradient
				colored[1 + #colored] = {dropdownHolderFrame, "ImageColor3", "bottomGradient"}
				dropdownHolderInner.Name = "dropdownHolderInner"
				dropdownHolderInner.Parent = dropdownHolderFrame
				dropdownHolderInner.Active = true
				dropdownHolderInner.AnchorPoint = Vector2Half
				dropdownHolderInner.BackgroundColor3 = library.colors.topGradient
				colored[1 + #colored] = {dropdownHolderInner, "BackgroundColor3", "topGradient"}
				dropdownHolderInner.BorderColor3 = library.colors.elementBorder
				dropdownHolderInner.Position = UDim2ScaleHalf
				dropdownHolderInner.Selectable = true
				dropdownHolderInner.Size = UDim2.new(1, -4, 1, -4)
				dropdownHolderInner.Image = "rbxassetid://2454009026"
				dropdownHolderInner.ImageColor3 = library.colors.bottomGradient
				colored[1 + #colored] = {dropdownHolderInner, "ImageColor3", "bottomGradient"}
				realDropdownHolder.Name = "realDropdownHolder"
				realDropdownHolder.Parent = dropdownHolderInner
				realDropdownHolder.BackgroundColor3 = WhiteColor3
				realDropdownHolder.BackgroundTransparency = 1
				realDropdownHolder.Selectable = false
				realDropdownHolder.Size = UDim2ScaleOne
				realDropdownHolder.CanvasSize = UDim2.new()
				realDropdownHolder.ScrollBarThickness = 5
				realDropdownHolder.ScrollingDirection = Enum.ScrollingDirection.Y
				realDropdownHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
				realDropdownHolder.ScrollBarImageTransparency = 0.5
				realDropdownHolder.ScrollBarImageColor3 = library.colors.section
				colored[1 + #colored] = {realDropdownHolder, "ScrollBarImageColor3", "section"}
				realDropdownHolderList.Name = "realDropdownHolderList"
				realDropdownHolderList.Parent = realDropdownHolder
				realDropdownHolderList.HorizontalAlignment = Enum.HorizontalAlignment.Center
				realDropdownHolderList.SortOrder = Enum.SortOrder.LayoutOrder
				sectionFunctions:Update()
				local restorezindex = {}
				library.signals[1 + #library.signals] = newDropdown.MouseEnter:Connect(function()
					colored_dropdown_BackgroundColor3[3] = "main"
					colored_dropdown_BackgroundColor3[4] = 1.5
					colored_dropdown_ImageColor3[3] = "main"
					colored_dropdown_ImageColor3[4] = 2.5
					tweenService:Create(dropdown, TweenInfo.new(0.25, library.configuration.easingStyle, library.configuration.easingDirection), {
						BackgroundColor3 = darkenColor(library.colors.main, 1.5),
						ImageColor3 = darkenColor(library.colors.main, 2.5)
					}):Play()
				end)
				library.signals[1 + #library.signals] = newDropdown.MouseLeave:Connect(function()
					if dropdownEnabled then
					else
						colored_dropdown_BackgroundColor3[3] = "topGradient"
						colored_dropdown_BackgroundColor3[4] = nil
						colored_dropdown_ImageColor3[3] = "bottomGradient"
						colored_dropdown_ImageColor3[4] = nil
						tweenService:Create(dropdown, TweenInfo.new(0.25, library.configuration.easingStyle, library.configuration.easingDirection), {
							BackgroundColor3 = library.colors.topGradient,
							ImageColor3 = library.colors.bottomGradient
						}):Play()
					end
				end)
				local function UpdateDropdownHolder()
					if optionCount >= 6 then
						realDropdownHolder.CanvasSize = UDim2:fromOffset(realDropdownHolderList.AbsoluteContentSize.Y + 2)
					elseif optionCount <= 5 then
						dropdownHolderFrame.Size = UDim2.fromOffset(206, realDropdownHolderList.AbsoluteContentSize.Y + 4)
					end
				end
				local SetupValidation, validate
				do
					local Signals = {}
					local Setup
					function SetupValidation()
						for k, v in next, Signals do
							if v then
								v:Disconnect()
							end
							Signals[k] = nil
						end
						if options.AutoValidate and list and (typeof(list) == "Instance") then
							local Val = library_flags[flagName] or selectedOption
							if multiselect then
								for _, v in next, Val do
									Setup(v)
								end
							else
								Setup(Val)
							end
						end
					end
					local gpcs = game.GetPropertyChangedSignal
					function Setup(v)
						if typeof(v) == "Instance" then
							local Signal
							Signal = gpcs(v, "Parent"):Connect(function()
								if options.AutoValidate then
									if list and (v.Parent ~= list) then
										if Signal then
											Signal:Disconnect()
										end
										Signal = nil
										validate()
									end
								else
									for k, v in next, Signals do
										v = v and v:Disconnect()
										Signals[k] = nil
									end
								end
							end)
							library.signals[1 + #library.signals] = Signal
						end
					end
				end
				local function AddOptions(optionsTable, filter)
					if options.Sort then
						local didstuff
						local dosort = options.Sort
						if dosort and (type(dosort) == "function") then
							local g, h = pcall(table.sort, optionsTable, dosort)
							if g then
								didstuff = true
							elseif h then
								warn("Error sorting list:", debug.traceback(h))
							end
						end
						if didstuff then
						else
							table.sort(optionsTable, library.defaultSort)
						end
					end
					if blankstring and ((optionsTable[1] ~= blankstring) or table.find(optionsTable, blankstring, 2)) then
						local exists = table.find(optionsTable, blankstring)
						if exists then
							for _ = 1, 35 do
								table.remove(optionsTable, exists)
								exists = table.find(optionsTable, blankstring)
								if exists then
								else
									break
								end
							end
						end
						table.insert(optionsTable, 1, blankstring)
					end
					optionCount = 0
					realDropdownHolderList.Parent = nil
					realDropdownHolder:ClearAllChildren()
					realDropdownHolderList.Parent = realDropdownHolder
					for _, v in next, optionsTable do
						if not filter or tostring(v):lower():find(dropdownSelection.Text:lower(), 1, not options.RegEx) then
							optionCount = optionCount + 1
							UpdateDropdownHolder()
							local newOption = Instance_new("ImageLabel")
							local optionButton = Instance_new("TextButton")
							if selectedOption == v then
								selectedObjects[1] = newOption
								selectedObjects[2] = optionButton
							end
							newOption.Name = "Frame"
							newOption.Parent = realDropdownHolder
							local togged = (not multiselect and (selectedOption == v)) or (multiselect and table.find(selectedOption, v))
							newOption.BackgroundColor3 = (togged and library.colors.selectedOption) or library.colors.topGradient
							newOption.BorderSizePixel = 0
							newOption.Size = UDim2.fromOffset(202, 18)
							newOption.Image = "rbxassetid://2454009026"
							newOption.ImageColor3 = (togged and library.colors.unselectedOption) or library.colors.bottomGradient
							local stringed = tostring(v)
							optionButton.Name = stringed
							optionButton.Parent = newOption
							optionButton.Active = true
							optionButton.AnchorPoint = Vector2Half
							optionButton.BackgroundColor3 = WhiteColor3
							optionButton.BackgroundTransparency = 1
							optionButton.Position = UDim2ScaleHalf
							optionButton.Selectable = true
							optionButton.Size = UDim2.new(1, -10, 1)
							optionButton.ZIndex = 5
							optionButton.Font = Enum.Font.GothamBold
							optionButton.Text = (togged and (" " .. stringed)) or stringed
							optionButton.TextColor3 = (togged and library.colors.main) or library.colors.otherElementText
							optionButton.TextSize = 12
							optionButton.TextXAlignment = Enum.TextXAlignment.Left
							library.signals[1 + #library.signals] = optionButton[(multiselect and "MouseButton1Click") or "MouseButton1Down"]:Connect(function()
								if library.colorpicker then
								else
									restorezindex[newSection] = restorezindex[newSection] or newSection.ZIndex
									restorezindex[newDropdown] = restorezindex[newDropdown] or newDropdown.ZIndex
									restorezindex[sectionHolder] = restorezindex[sectionHolder] or sectionHolder.ZIndex
									if multiselect then
										local cloned = {unpack(selectedOption)}
										local togged = table.find(selectedOption, v)
										if togged then
											table.remove(selectedOption, togged)
										else
											selectedOption[1 + #selectedOption] = v
										end
										togged = table.find(selectedOption, v)
										optionButton.Text = (togged and (" " .. stringed)) or stringed
										newOption.BackgroundColor3 = (togged and library.colors.selectedOption) or library.colors.topGradient
										newOption.ImageColor3 = (togged and library.colors.unselectedOption) or library.colors.bottomGradient
										optionButton.TextColor3 = (togged and library.colors.main) or library.colors.otherElementText
										if callback and __runscript then
											task.spawn(callback, selectedOption, cloned)
										end
										if togged then
											if addcallback then
												task.spawn(addcallback, v, selectedOption)
											end
										elseif delcallback then
											task.spawn(delcallback, v, selectedOption)
										end
										if modcallback then
											task.spawn(modcallback, v, togged, selectedOption)
										end
										if #selectedOption == 0 and clrcallback then
											task.spawn(clrcallback, selectedOption, cloned)
										end
										return
									else
										dropdownSelection.Text = stringed
										if selectedOption ~= v then
											local last_v = library_flags[flagName]
											do
												local First = selectedObjects[1]
												if First then
													selectedObjects[1].BackgroundColor3 = library.colors.topGradient
													selectedObjects[1].ImageColor3 = library.colors.bottomGradient
												end
											end
											do
												local Second = selectedObjects[2]
												if Second then
													selectedObjects[2].Text = selectedObjects[2].Name
													selectedObjects[2].TextColor3 = library.colors.otherElementText
												end
											end
											selectedOption = v
											selectedObjects[1] = newOption
											selectedObjects[2] = optionButton
											newOption.BackgroundColor3 = library.colors.selectedOption
											newOption.ImageColor3 = library.colors.unselectedOption
											optionButton.TextColor3 = library.colors.main
											dropdownHolderFrame.Visible = false
											dropdownToggle.Rotation = 90
											dropdownEnabled = false
											newDropdown.ZIndex = 1
											colored_dropdown_BackgroundColor3[3] = "topGradient"
											colored_dropdown_BackgroundColor3[4] = nil
											colored_dropdown_ImageColor3[3] = "bottomGradient"
											colored_dropdown_ImageColor3[4] = nil
											tweenService:Create(dropdown, TweenInfo.new(0.35, library.configuration.easingStyle, library.configuration.easingDirection), {
												BackgroundColor3 = library.colors.topGradient,
												ImageColor3 = library.colors.bottomGradient
											}):Play()
											library_flags[flagName] = selectedOption
											if options.Location then
												options.Location[options.LocationFlag or flagName] = selectedOption
											end
											dropdownSelection.Text = tostring(selectedOption)
											if submenuOpen then
												submenuOpen = nil
											end
											if callback and __runscript then
												task.spawn(callback, selectedOption, last_v)
											end
										else
											submenuOpen = nil
											dropdownToggle.Rotation = 90
											colored_dropdown_BackgroundColor3[3] = "topGradient"
											colored_dropdown_BackgroundColor3[4] = nil
											colored_dropdown_ImageColor3[3] = "bottomGradient"
											colored_dropdown_ImageColor3[4] = nil
											tweenService:Create(dropdown, TweenInfo.new(0.35, library.configuration.easingStyle, library.configuration.easingDirection), {
												BackgroundColor3 = library.colors.topGradient,
												ImageColor3 = library.colors.bottomGradient
											}):Play()
											dropdownHolderFrame.Visible = false
										end
									end
									for ins, z in next, restorezindex do
										ins.ZIndex = z
									end
								end
							end)
							library.signals[1 + #library.signals] = optionButton.MouseEnter:Connect(function()
								tweenService:Create(newOption, TweenInfo.new(0.35, library.configuration.easingStyle, library.configuration.easingDirection), {
									BackgroundColor3 = library.colors.hoveredOptionTop,
									ImageColor3 = library.colors.hoveredOptionBottom
								}):Play()
							end)
							library.signals[1 + #library.signals] = optionButton.MouseLeave:Connect(function()
								local togged = (not multiselect and selectedOption == v) or (multiselect and table.find(selectedOption, v))
								tweenService:Create(newOption, TweenInfo.new(0.35, library.configuration.easingStyle, library.configuration.easingDirection), {
									BackgroundColor3 = (togged and library.colors.selectedOption) or library.colors.topGradient,
									ImageColor3 = (togged and library.colors.unselectedOption) or library.colors.bottomGradient
								}):Play()
							end)
							UpdateDropdownHolder()
						end
					end
					UpdateDropdownHolder()
				end
				local precisionscrolling, update, showing
				local function display(dropdownEnabled, f)
					if dropdownEnabled and windowFunctions.CloseDropdown then
						pcall(windowFunctions.CloseDropdown)
						windowFunctions.CloseDropdown = nil
					end
					if (submenuOpen == dropdown) or (submenuOpen == nil) then
						if dropdownEnabled then
							list = resolvelist()
							if next(list) then
							else
								local EmptyVal = options.EmptyValue
								if EmptyVal ~= nil then
									table.insert(list, 1, EmptyVal)
								end
							end
							windowFunctions.CloseDropdown = display
							AddOptions(list, f)
							submenuOpen = dropdown
							dropdownToggle.Rotation = 270
							restorezindex[newSection] = restorezindex[newSection] or newSection.ZIndex
							restorezindex[newDropdown] = restorezindex[newDropdown] or newDropdown.ZIndex
							restorezindex[sectionHolder] = restorezindex[sectionHolder] or sectionHolder.ZIndex
							newSection.ZIndex = 50 + newSection.ZIndex
							newDropdown.ZIndex = 2
							sectionHolder.ZIndex = 2
							colored_dropdown_BackgroundColor3[3] = "main"
							colored_dropdown_BackgroundColor3[4] = 1.5
							colored_dropdown_ImageColor3[3] = "main"
							colored_dropdown_ImageColor3[4] = 2.5
							tweenService:Create(dropdown, TweenInfo.new(0.35, library.configuration.easingStyle, library.configuration.easingDirection), {
								BackgroundColor3 = darkenColor(library.colors.main, 1.5),
								ImageColor3 = darkenColor(library.colors.main, 2.5)
							}):Play()
							dropdownHolderFrame.Visible = true
							if options.DisablePrecisionScrolling then
							else
								local scrollrate = tonumber(options.ScrollButtonRate or options.ScrollRate) or 5
								local upkey = options.ScrollUpButton or library.scrollupbutton or shared.scrollupbutton or Enum.KeyCode.Up
								local downkey = options.ScrollDownButton or library.scrolldownbutton or shared.scrolldownbutton or Enum.KeyCode.Down
								precisionscrolling = (precisionscrolling and precisionscrolling:Disconnect() and nil) or userInputService.InputBegan:Connect(function(input)
									if input.UserInputType == Enum.UserInputType.Keyboard then
										local code = input.KeyCode
										local isup = code == upkey
										local isdown = code == downkey
										if isup or isdown then
											local txt = userInputService:GetFocusedTextBox()
											if txt and (txt ~= dropdownSelection) then
											else
												while wait_check() and userInputService:IsKeyDown(code) do
													realDropdownHolder.CanvasPosition = Vector2:new(math.clamp(realDropdownHolder.CanvasPosition.Y + ((isup and -scrollrate) or scrollrate), 0, realDropdownHolder.AbsoluteCanvasSize.Y))
												end
											end
										end
									end
								end)
								library.signals[1 + #library.signals] = precisionscrolling
							end
						else
							submenuOpen = nil
							dropdownToggle.Rotation = 90
							colored_dropdown_BackgroundColor3[3] = "topGradient"
							colored_dropdown_BackgroundColor3[4] = nil
							colored_dropdown_ImageColor3[3] = "bottomGradient"
							colored_dropdown_ImageColor3[4] = nil
							tweenService:Create(dropdown, TweenInfo.new(0.35, library.configuration.easingStyle, library.configuration.easingDirection), {
								BackgroundColor3 = library.colors.topGradient,
								ImageColor3 = library.colors.bottomGradient
							}):Play()
							dropdownHolderFrame.Visible = false
							for ins, z in next, restorezindex do
								ins.ZIndex = z
							end
							if precisionscrolling then
								precisionscrolling:Disconnect()
							end
							precisionscrolling = nil
							if dropdownSelection:IsFocused() then
							else
								dropdownSelection.Text = ResolveDropdownItemName(multiselect, passed_multiselect, options.Name, selectedOption, flagName, blankstring)
							end
						end
					end
					showing = dropdownEnabled
					if showing or dropdownEnabled then
					else
						delay(0.01, update)
					end
				end
				local Set = (multiselect and function(t, dat)
					if (nil == dat) and (t ~= nil) then
						dat = t
					end
					local lastv = library_flags[flagName]
					if lastv and (selectedOption == lastv) then
					else
						if lastv and (type(lastv) == "table") then
							selectedOption = library_flags[flagName]
						else
							library_flags[flagName] = selectedOption
						end
						warn("Attempting to use new table for", flagName, " Please use :Set(), because setting it through flags table may cause errors. Unsafe operation", debug.traceback(""))
						lastv = library_flags[flagName]
					end
					local cloned = {unpack(selectedOption)}
					if not dat then
						if #selectedOption ~= 0 then
							table.clear(selectedOption)
							if callback and __runscript then
								task.spawn(callback, selectedOption, cloned)
							end
						end
						return selectedOption
					elseif type(dat) ~= "table" then
						warn("Expected table for argument #1 on Set for MultiSelect searchbox. Got", dat, debug.traceback(""))
						return selectedOption
					end
					for k = table.pack(unpack(dat)).n, 1, -1 do
						if dat[k] == nil then
							table.remove(dat, k)
						end
					end
					local proceed = #cloned ~= #dat
					table.clear(selectedOption)
					for k, v in next, dat do
						selectedOption[k] = v
						if proceed or (cloned[k] == v) then
						else
							proceed = 1
						end
					end
					dropdownSelection.Text = ResolveDropdownItemName(multiselect, passed_multiselect, options.Name, selectedOption, flagName, blankstring)
					if proceed and callback and __runscript then
						task.spawn(callback, selectedOption, cloned)
					end
					if options.AutoValidate then
						SetupValidation()
					end
					return selectedOption
				end) or function(t, str)
					if str then
					elseif (nil == str) and t then
						str = t
					end
					local last_v = library_flags[flagName]
					selectedOption = str
					library_flags[flagName] = str
					if options.Location then
						options.Location[options.LocationFlag or flagName] = str
					end
					dropdownSelection.Text = ResolveDropdownItemName(multiselect, passed_multiselect, options.Name, selectedOption, flagName, blankstring)
					if callback and __runscript and ((last_v ~= str) or options.AllowDuplicateCalls) then
						task.spawn(callback, str, last_v)
					end
					if options.AutoValidate then
						SetupValidation()
					end
					return str
				end
				if val ~= nil then
					Set(val)
				else
					library_flags[flagName] = selectedOption
					if options.Location then
						options.Location[options.LocationFlag or flagName] = selectedOption
					end
					if options.AutoValidate then
						SetupValidation()
					end
				end
				library.signals[1 + #library.signals] = dropdownToggle.MouseButton1Click:Connect(function()
					showing = not showing
					display(showing)
				end)
				library.signals[1 + #library.signals] = dropdownSelection.Focused:Connect(function()
					showing = true
					display(true)
				end)
				library.signals[1 + #library.signals] = dropdownSelection:GetPropertyChangedSignal("Text"):Connect(function()
					if showing and dropdownSelection:IsFocused() then
						display(true, #dropdownSelection.Text > 0)
					end
				end)
				if multiselect then
				else
					library.signals[1 + #library.signals] = dropdownSelection.FocusLost:Connect(function(b)
						if showing then
							wait()
						end
						showing = false
						display(false)
						if b then
							Set(dropdownSelection.Text)
						end
					end)
				end
				AddOptions(list)
				local default = library_flags[flagName]
				if type(default) == "table" then
					default = table.clone(default)
				end
				function update()
					dropdownName, callback = options.Name or dropdownName, options.Callback
					local ProperBlankString
					if blankstring and (type(blankstring) == "string") then
						ProperBlankString = blankstring
					end
					dropdownHeadline.Text = (dropdownName and tostring(dropdownName)) or "???"
					return dropdownSelection.Text
				end
				function validate(fallbackValue)
					if list and table.find(list, library_flags[flagName]) then
						update()
						return true
					end
					if fallbackValue == nil then
						fallbackValue = list[1]
					elseif fallbackValue == "__DEFAULT" then
						fallbackValue = default
					end
					if multiselect and (type(fallbackValue) ~= "table") then
						fallbackValue = {fallbackValue}
					end
					return Set(fallbackValue)
				end
				local objectdata = {
					Options = options,
					Name = flagName,
					Flag = flagName,
					Type = "SearchBox",
					Default = default,
					Parent = sectionFunctions,
					Instance = dropdownSelection,
					Validate = validate,
					Set = Set,
					Remove = function()
						if newDropdown then
							newDropdown.Parent = nil
							sectionFunctions:Update()
						end
					end,
					RawSet = ((multiselect and function(t, dat)
						if (nil == dat) and (t ~= nil) then
							dat = t
						end
						local lastv = library_flags[flagName]
						if not lastv or (selectedOption ~= lastv) then
							if lastv and (type(lastv) == "table") then
								selectedOption = library_flags[flagName]
							else
								library_flags[flagName] = selectedOption
							end
							warn("Attempting to use new table for", flagName, " Please use :Set(), as setting through flags table may cause errors", debug.traceback(""))
							lastv = library_flags[flagName]
						end
						local cloned = {unpack(selectedOption)}
						if not dat then
							if #selectedOption ~= 0 then
								table.clear(selectedOption)
								if callback and __runscript then
									task.spawn(callback, selectedOption, cloned)
								end
							end
							return selectedOption
						elseif type(dat) ~= "table" then
							warn("Expected table for argument #1 on Set for MultiSelect searchbox. Got", dat, debug.traceback(""))
							return selectedOption
						end
						for k = table.pack(unpack(dat)).n, 1, -1 do
							if dat[k] == nil then
								table.remove(dat, k)
							end
						end
						table.clear(selectedOption)
						for k, v in next, dat do
							selectedOption[k] = v
						end
						update()
						return selectedOption
					end) or function(t, str)
						if (nil == str) and t then
							str = t
						end
						selectedOption = str
						library_flags[flagName] = str
						if options.Location then
							options.Location[options.LocationFlag or flagName] = str
						end
						update()
						return str
					end),
					Get = function()
						return library_flags[flagName]
					end,
					Update = update,
					Reset = function()
						return Set(nil, default)
					end
				}
				function objectdata.UpdateList(t, listt, updateValues)
					if ((nil == listt) and (t ~= nil)) or ((type(t) == "table") and (type(listt) ~= "table")) then
						listt, updateValues = t, listt
					end
					if listt == objectdata then
						listt = nil
					end
					resolvelist = getresolver(listt or options.List, options.Filter, options.Method)
					list = resolvelist()
					if next(list) then
					else
						local EmptyVal = options.EmptyValue
						if EmptyVal ~= nil then
							table.insert(list, 1, EmptyVal)
						end
					end
					if updateValues then
						validate()
					end
					if showing then
						local Og = realDropdownHolder.CanvasPosition
						display(false)
						display(true)
						if Og.Y > 0 then
							realDropdownHolder.CanvasPosition = Vector2.yAxis * math.clamp(Og.Y, 0, realDropdownHolder.AbsoluteCanvasSize.Y)
						end
					end
					return list
				end
				tabFunctions.Flags[flagName], sectionFunctions.Flags[flagName], elements[flagName] = objectdata, objectdata, objectdata
				return objectdata
			end
			sectionFunctions.NewSearchBox = sectionFunctions.AddSearchBox
			sectionFunctions.CreateSearchBox = sectionFunctions.AddSearchBox
			sectionFunctions.SearchBox = sectionFunctions.AddSearchBox
			sectionFunctions.CreateSearchbox = sectionFunctions.AddSearchBox
			sectionFunctions.NewSearchbox = sectionFunctions.AddSearchBox
			sectionFunctions.AddSearchbox = sectionFunctions.AddSearchBox
			sectionFunctions.Searchbox = sectionFunctions.AddSearchBox
			sectionFunctions.Sbox = sectionFunctions.AddSearchBox
			sectionFunctions.SBox = sectionFunctions.AddSearchBox
			if isfolder and makefolder and listfiles and readfile and writefile then
				function sectionFunctions:AddPersistence(options, ...)
					options = (options and (type(options) == "string") and resolvevararg("Tab", options, ...)) or options
					local dropdownName, custom_workspace, val, persistiveflags, suffix, callback, loadcallback, savecallback, postload, postsave, flagName = assert(options.Name, "Missing Name for new persistence."), options.Workspace or library.WorkspaceName, options.Value, options.Persistive or options.Flags or "all", options.Suffix, options.Callback, options.LoadCallback, options.SaveCallback, options.PostLoadCallback, options.PostSaveCallback, options.Flag or (function()
						library.unnamedpersistence = 1 + (library.unnamedpersistence or 0)
						return "Persistence" .. tostring(library.unnamedpersistence)
					end)()
					if elements[flagName] ~= nil then
						warn(debug.traceback("Warning! Re-used flag '" .. flagName .. "'", 3))
					end
					local designerpersists = options.Desginer
					local newDropdown = Instance_new("Frame")
					local dropdown = Instance_new("ImageLabel")
					local dropdownInner = Instance_new("ImageLabel")
					local dropdownToggle = Instance_new("ImageButton")
					local dropdownSelection = Instance_new("TextBox")
					local dropdownHeadline = Instance_new("TextLabel")
					local dropdownHolderFrame = Instance_new("ImageLabel")
					local dropdownHolderInner = Instance_new("ImageLabel")
					local realDropdownHolder = Instance_new("ScrollingFrame")
					local realDropdownHolderList = Instance_new("UIListLayout")
					local dropdownEnabled = false
					if isfolder("./QuickX Hub") then
					else
						makefolder("./QuickX Hub")
					end
					local common_string = "./QuickX Hub/" .. tostring(custom_workspace or library.WorkspaceName)
					local function resolvelist(nofold)
						if custom_workspace ~= options.Workspace then
							custom_workspace = options.Workspace
							common_string = "./QuickX Hub/" .. tostring(custom_workspace or library.WorkspaceName)
						end
						if isfolder and makefolder and listfiles then
						else
							return {}
						end
						if isfolder(common_string) then
						else
							if nofold then
								return {}
							end
							makefolder(common_string)
						end
						assert(isfolder(common_string), "Couldn't create folder: " .. tostring(library.WorkspaceName or "No workspace name?"))
						local names, files = {}, listfiles(common_string)
						if #files > 0 then
							local len = #common_string + 2
							for _, f in next, files do
								names[1 + #names] = string.sub(f, len, -5)
							end
							table.sort(names)
						end
						return names
					end
					local list = resolvelist(true)
					local blankstring = options.BlankValue or options.NoValueString or options.Nothing
					local selectedObjects = {}
					local optionCount = 0
					if blankstring and (val == nil) then
						val = blankstring
					end
					local selectedOption = val or blankstring or list[1]
					newDropdown.Name = "newDropdown"
					newDropdown.Parent = sectionHolder
					newDropdown.BackgroundColor3 = WhiteColor3
					newDropdown.BackgroundTransparency = 1
					newDropdown.Size = UDim2.new(1, 0, 0, 42)
					dropdown.Name = "dropdown"
					dropdown.Parent = newDropdown
					dropdown.Active = true
					dropdown.BackgroundColor3 = library.colors.topGradient
					local colored_dropdown_BackgroundColor3 = {dropdown, "BackgroundColor3", "topGradient"}
					colored[1 + #colored] = colored_dropdown_BackgroundColor3
					dropdown.BorderColor3 = library.colors.elementBorder
					colored[1 + #colored] = {dropdown, "BorderColor3", "elementBorder"}
					dropdown.Position = UDim2.fromScale(0.027, 0.45)
					dropdown.Selectable = true
					dropdown.Size = UDim2.fromOffset(206, 18)
					dropdown.Image = "rbxassetid://2454009026"
					dropdown.ImageColor3 = library.colors.bottomGradient
					local colored_dropdown_ImageColor3 = {dropdown, "ImageColor3", "bottomGradient"}
					colored[1 + #colored] = colored_dropdown_ImageColor3
					dropdownInner.Name = "dropdownInner"
					dropdownInner.Parent = dropdown
					dropdownInner.Active = true
					dropdownInner.AnchorPoint = Vector2Half
					dropdownInner.BackgroundColor3 = library.colors.topGradient
					colored[1 + #colored] = {dropdownInner, "BackgroundColor3", "topGradient"}
					dropdownInner.BorderColor3 = library.colors.elementBorder
					colored[1 + #colored] = {dropdownInner, "BorderColor3", "elementBorder"}
					dropdownInner.Position = UDim2ScaleHalf
					dropdownInner.Selectable = true
					dropdownInner.Size = UDim2.new(1, -4, 1, -4)
					dropdownInner.Image = "rbxassetid://2454009026"
					dropdownInner.ImageColor3 = library.colors.bottomGradient
					colored[1 + #colored] = {dropdownInner, "ImageColor3", "bottomGradient"}
					dropdownToggle.Name = "dropdownToggle"
					dropdownToggle.Parent = dropdown
					dropdownToggle.BackgroundColor3 = WhiteColor3
					dropdownToggle.BackgroundTransparency = 1
					dropdownToggle.Position = UDim2.fromScale(0.9, 0.17)
					dropdownToggle.Rotation = 90
					dropdownToggle.Size = UDim2.fromOffset(12, 12)
					dropdownToggle.ZIndex = 2
					dropdownToggle.Image = "rbxassetid://71659683"
					dropdownToggle.ImageColor3 = Color3.fromRGB(171, 171, 171)
					dropdownSelection.Name = "dropdownSelection"
					dropdownSelection.Parent = dropdown
					dropdownSelection.BackgroundColor3 = WhiteColor3
					dropdownSelection.BackgroundTransparency = 1
					dropdownSelection.Position = UDim2.new(0.0295485705)
					dropdownSelection.Size = UDim2.fromScale(0.97, 1)
					dropdownSelection.ZIndex = 5
					dropdownSelection.Font = Enum.Font.GothamBold
					dropdownSelection.LineHeight = 1.15
					dropdownSelection.Text = (selectedOption and tostring(selectedOption)) or "nil"
					dropdownSelection.TextColor3 = library.colors.otherElementText
					colored[1 + #colored] = {dropdownSelection, "TextColor3", "otherElementText"}
					dropdownSelection.TextSize = 12
					dropdownSelection.TextXAlignment = Enum.TextXAlignment.Left
					dropdownHeadline.Name = "dropdownHeadline"
					dropdownHeadline.Parent = newDropdown
					dropdownHeadline.BackgroundColor3 = WhiteColor3
					dropdownHeadline.BackgroundTransparency = 1
					dropdownHeadline.Position = UDim2.fromScale(0.034, 0.03)
					dropdownHeadline.Size = UDim2.fromOffset(167, 11)
					dropdownHeadline.Font = Enum.Font.GothamBold
					dropdownHeadline.Text = (dropdownName and tostring(dropdownName)) or "???"
					dropdownHeadline.TextColor3 = library.colors.elementText
					colored[1 + #colored] = {dropdownHeadline, "TextColor3", "elementText"}
					dropdownHeadline.TextSize = 12
					dropdownHeadline.TextXAlignment = Enum.TextXAlignment.Left
					dropdownHolderFrame.Name = "dropdownHolderFrame"
					dropdownHolderFrame.Parent = newDropdown
					dropdownHolderFrame.Active = true
					dropdownHolderFrame.BackgroundColor3 = library.colors.topGradient
					colored[1 + #colored] = {dropdownHolderFrame, "BackgroundColor3", "topGradient"}
					dropdownHolderFrame.BorderColor3 = library.colors.elementBorder
					colored[1 + #colored] = {dropdownHolderFrame, "BorderColor3", "elementBorder"}
					dropdownHolderFrame.Position = UDim2.fromScale(0.025, 1.012)
					dropdownHolderFrame.Selectable = true
					dropdownHolderFrame.Size = UDim2.fromOffset(206, 22)
					dropdownHolderFrame.Visible = false
					dropdownHolderFrame.Image = "rbxassetid://2454009026"
					dropdownHolderFrame.ImageColor3 = library.colors.bottomGradient
					colored[1 + #colored] = {dropdownHolderFrame, "ImageColor3", "bottomGradient"}
					dropdownHolderInner.Name = "dropdownHolderInner"
					dropdownHolderInner.Parent = dropdownHolderFrame
					dropdownHolderInner.Active = true
					dropdownHolderInner.AnchorPoint = Vector2Half
					dropdownHolderInner.BackgroundColor3 = library.colors.topGradient
					colored[1 + #colored] = {dropdownHolderInner, "BackgroundColor3", "topGradient"}
					dropdownHolderInner.BorderColor3 = library.colors.elementBorder
					colored[1 + #colored] = {dropdownHolderInner, "BorderColor3", "elementBorder"}
					dropdownHolderInner.Position = UDim2ScaleHalf
					dropdownHolderInner.Selectable = true
					dropdownHolderInner.Size = UDim2.new(1, -4, 1, -4)
					dropdownHolderInner.Image = "rbxassetid://2454009026"
					dropdownHolderInner.ImageColor3 = library.colors.bottomGradient
					colored[1 + #colored] = {dropdownHolderInner, "ImageColor3", "bottomGradient"}
					realDropdownHolder.Name = "realDropdownHolder"
					realDropdownHolder.Parent = dropdownHolderInner
					realDropdownHolder.BackgroundColor3 = WhiteColor3
					realDropdownHolder.BackgroundTransparency = 1
					realDropdownHolder.Selectable = false
					realDropdownHolder.Size = UDim2ScaleOne
					realDropdownHolder.CanvasSize = UDim2.new()
					realDropdownHolder.ScrollBarThickness = 5
					realDropdownHolder.ScrollingDirection = Enum.ScrollingDirection.Y
					realDropdownHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
					realDropdownHolder.ScrollBarImageTransparency = 0.5
					realDropdownHolder.ScrollBarImageColor3 = library.colors.section
					colored[1 + #colored] = {realDropdownHolder, "ScrollBarImageColor3", "section"}
					realDropdownHolderList.Name = "realDropdownHolderList"
					realDropdownHolderList.Parent = realDropdownHolder
					realDropdownHolderList.HorizontalAlignment = Enum.HorizontalAlignment.Center
					realDropdownHolderList.SortOrder = Enum.SortOrder.LayoutOrder
					sectionFunctions:Update()
					library.signals[1 + #library.signals] = newDropdown.MouseEnter:Connect(function()
						colored_dropdown_BackgroundColor3[3] = "main"
						colored_dropdown_BackgroundColor3[4] = 1.5
						colored_dropdown_ImageColor3[3] = "main"
						colored_dropdown_ImageColor3[4] = 2.5
						tweenService:Create(dropdown, TweenInfo.new(0.25, library.configuration.easingStyle, library.configuration.easingDirection), {
							BackgroundColor3 = darkenColor(library.colors.main, 1.5),
							ImageColor3 = darkenColor(library.colors.main, 2.5)
						}):Play()
					end)
					library.signals[1 + #library.signals] = newDropdown.MouseLeave:Connect(function()
						if dropdownEnabled then
						else
							colored_dropdown_BackgroundColor3[3] = "topGradient"
							colored_dropdown_BackgroundColor3[4] = nil
							colored_dropdown_ImageColor3[3] = "bottomGradient"
							colored_dropdown_ImageColor3[4] = nil
							tweenService:Create(dropdown, TweenInfo.new(0.25, library.configuration.easingStyle, library.configuration.easingDirection), {
								BackgroundColor3 = library.colors.topGradient,
								ImageColor3 = library.colors.bottomGradient
							}):Play()
						end
					end)
					local restorezindex = {}
					local function UpdateDropdownHolder()
						if optionCount >= 6 then
							realDropdownHolder.CanvasSize = UDim2:fromOffset(realDropdownHolderList.AbsoluteContentSize.Y + 2)
						elseif optionCount <= 5 then
							dropdownHolderFrame.Size = UDim2.fromOffset(206, (realDropdownHolderList.AbsoluteContentSize.Y + 4))
						end
					end
					local function AddOptions(optionsTable, filter)
						if options.Sort then
							local didstuff, dosort = nil, options.Sort
							if type(dosort) == "function" then
								local g, h = pcall(table.sort, optionsTable, dosort)
								if g then
									didstuff = true
								elseif h then
									warn("Error sorting list:", h, debug.traceback(""))
								end
							end
							if didstuff then
							else
								table.sort(optionsTable, library.defaultSort)
							end
						end
						if options.ForceSelect then
						elseif blankstring and ((optionsTable[1] ~= blankstring) or table.find(optionsTable, blankstring, 2)) then
							local exists = table.find(optionsTable, blankstring)
							if exists then
								for _ = 1, 35 do
									table.remove(optionsTable, exists)
									exists = table.find(optionsTable, blankstring)
									if exists then
									else
										break
									end
								end
							end
							table.insert(optionsTable, 1, blankstring)
						end
						optionCount = 0
						realDropdownHolderList.Parent = nil
						realDropdownHolder:ClearAllChildren()
						realDropdownHolderList.Parent = realDropdownHolder
						for _, v in next, optionsTable do
							if filter then
							elseif tostring(v):lower():find(dropdownSelection.Text:lower(), 1, true) then
								optionCount += 1
								UpdateDropdownHolder()
								local newOption = Instance_new("ImageLabel")
								local optionButton = Instance_new("TextButton")
								if (selectedOption == v) or not selectedObjects[1] or not selectedObjects[2] then
									selectedObjects[1] = newOption
									selectedObjects[2] = optionButton
								end
								newOption.Name = "Frame"
								newOption.Parent = realDropdownHolder
								newOption.BackgroundColor3 = ((selectedOption == v) and library.colors.selectedOption) or library.colors.topGradient
								newOption.BorderSizePixel = 0
								newOption.Size = UDim2.fromOffset(202, 18)
								newOption.Image = "rbxassetid://2454009026"
								newOption.ImageColor3 = ((selectedOption == v) and library.colors.unselectedOption) or library.colors.bottomGradient
								optionButton.Name = tostring(v)
								optionButton.Parent = newOption
								optionButton.AnchorPoint = Vector2Half
								optionButton.BackgroundColor3 = WhiteColor3
								optionButton.BackgroundTransparency = 1
								optionButton.Position = UDim2ScaleHalf
								optionButton.Size = UDim2.new(1, -10, 1)
								optionButton.ZIndex = 5
								optionButton.Font = Enum.Font.GothamBold
								optionButton.Text = ((selectedOption == v) and (" " .. tostring(v))) or tostring(v)
								optionButton.TextColor3 = ((selectedOption == v) and library.colors.main or library.colors.otherElementText)
								optionButton.TextSize = 12
								optionButton.TextXAlignment = Enum.TextXAlignment.Left
								library.signals[1 + #library.signals] = optionButton.MouseButton1Down:Connect(function()
									dropdownSelection.Text = tostring(v)
									restorezindex[newSection] = restorezindex[newSection] or newSection.ZIndex
									restorezindex[newDropdown] = restorezindex[newDropdown] or newDropdown.ZIndex
									restorezindex[sectionHolder] = restorezindex[sectionHolder] or sectionHolder.ZIndex
									if selectedOption ~= v then
										local last_v = library_flags[flagName]
										selectedObjects[1].BackgroundColor3 = library.colors.topGradient
										selectedObjects[1].ImageColor3 = library.colors.bottomGradient
										selectedObjects[2].Text = selectedObjects[2].Name
										selectedObjects[2].TextColor3 = library.colors.otherElementText
										selectedOption = v
										selectedObjects[1] = newOption
										selectedObjects[2] = optionButton
										newOption.BackgroundColor3 = library.colors.selectedOption
										newOption.ImageColor3 = library.colors.unselectedOption
										optionButton.TextColor3 = library.colors.main
										dropdownHolderFrame.Visible = false
										dropdownToggle.Rotation = 90
										dropdownEnabled = false
										colored_dropdown_BackgroundColor3[3] = "topGradient"
										colored_dropdown_BackgroundColor3[4] = nil
										colored_dropdown_ImageColor3[3] = "bottomGradient"
										colored_dropdown_ImageColor3[4] = nil
										tweenService:Create(dropdown, TweenInfo.new(0.35, library.configuration.easingStyle, library.configuration.easingDirection), {
											BackgroundColor3 = library.colors.topGradient,
											ImageColor3 = library.colors.bottomGradient
										}):Play()
										library_flags[flagName] = selectedOption
										if options.Location then
											options.Location[options.LocationFlag or flagName] = selectedOption
										end
										dropdownSelection.Text = tostring(selectedOption)
										if submenuOpen then
											submenuOpen = nil
										end
										if callback and __runscript then
											task.spawn(callback, selectedOption, last_v)
										end
									else
										submenuOpen = nil
										dropdownToggle.Rotation = 90
										newDropdown.ZIndex = 1
										sectionHolder.ZIndex = 1
										colored_dropdown_BackgroundColor3[3] = "topGradient"
										colored_dropdown_BackgroundColor3[4] = nil
										colored_dropdown_ImageColor3[3] = "bottomGradient"
										colored_dropdown_ImageColor3[4] = nil
										tweenService:Create(dropdown, TweenInfo.new(0.35, library.configuration.easingStyle, library.configuration.easingDirection), {
											BackgroundColor3 = library.colors.topGradient,
											ImageColor3 = library.colors.bottomGradient
										}):Play()
										dropdownHolderFrame.Visible = false
									end
									for ins, z in next, restorezindex do
										ins.ZIndex = z
									end
								end)
								library.signals[1 + #library.signals] = optionButton.MouseEnter:Connect(function()
									tweenService:Create(newOption, TweenInfo.new(0.35, library.configuration.easingStyle, library.configuration.easingDirection), {
										BackgroundColor3 = library.colors.hoveredOptionTop,
										ImageColor3 = library.colors.hoveredOptionBottom
									}):Play()
								end)
								library.signals[1 + #library.signals] = optionButton.MouseLeave:Connect(function()
									tweenService:Create(newOption, TweenInfo.new(0.35, library.configuration.easingStyle, library.configuration.easingDirection), {
										BackgroundColor3 = library.colors.unhoveredOptionTop,
										ImageColor3 = library.colors.unhoveredOptionBottom
									}):Play()
								end)
								UpdateDropdownHolder()
							end
						end
					end
					local precisionscrolling, update, showing
					local function display(dropdownEnabled, f)
						if dropdownEnabled and windowFunctions.CloseDropdown then
							pcall(windowFunctions.CloseDropdown)
							windowFunctions.CloseDropdown = nil
						end
						if (submenuOpen == dropdown) or (submenuOpen == nil) then
							if dropdownEnabled then
								list = resolvelist(true)
								windowFunctions.CloseDropdown = display
								AddOptions(list, f)
								submenuOpen = dropdown
								restorezindex[newSection] = restorezindex[newSection] or newSection.ZIndex
								restorezindex[newDropdown] = restorezindex[newDropdown] or newDropdown.ZIndex
								restorezindex[sectionHolder] = restorezindex[sectionHolder] or sectionHolder.ZIndex
								newSection.ZIndex = 50 + newSection.ZIndex
								dropdownToggle.Rotation = 270
								newDropdown.ZIndex = 2
								sectionHolder.ZIndex = 2
								colored_dropdown_BackgroundColor3[3] = "main"
								colored_dropdown_BackgroundColor3[4] = 1.5
								colored_dropdown_ImageColor3[3] = "main"
								colored_dropdown_ImageColor3[4] = 2.5
								tweenService:Create(dropdown, TweenInfo.new(0.35, library.configuration.easingStyle, library.configuration.easingDirection), {
									BackgroundColor3 = darkenColor(library.colors.main, 1.5),
									ImageColor3 = darkenColor(library.colors.main, 2.5)
								}):Play()
								dropdownHolderFrame.Visible = true
								if options.DisablePrecisionScrolling then
								else
									local upkey = options.ScrollUpButton or library.scrollupbutton or shared.scrollupbutton or Enum.KeyCode.Up
									local downkey = options.ScrollDownButton or library.scrolldownbutton or shared.scrolldownbutton or Enum.KeyCode.Down
									precisionscrolling = (precisionscrolling and precisionscrolling:Disconnect() and nil) or userInputService.InputBegan:Connect(function(input)
										if input.UserInputType == Enum.UserInputType.Keyboard then
											local code = input.KeyCode
											local isup = code == upkey
											local isdown = code == downkey
											if isup or isdown then
												if userInputService:GetFocusedTextBox() then
												else
													while wait_check() and userInputService:IsKeyDown(code) do
														realDropdownHolder.CanvasPosition = Vector2:new(math.clamp(realDropdownHolder.CanvasPosition.Y + ((isup and -5) or 5), 0, realDropdownHolder.AbsoluteCanvasSize.Y))
													end
												end
											end
										end
									end)
									library.signals[1 + #library.signals] = precisionscrolling
								end
							else
								submenuOpen = nil
								dropdownToggle.Rotation = 90
								colored_dropdown_BackgroundColor3[3] = "topGradient"
								colored_dropdown_BackgroundColor3[4] = nil
								colored_dropdown_ImageColor3[3] = "bottomGradient"
								colored_dropdown_ImageColor3[4] = nil
								tweenService:Create(dropdown, TweenInfo.new(0.35, library.configuration.easingStyle, library.configuration.easingDirection), {
									BackgroundColor3 = library.colors.topGradient,
									ImageColor3 = library.colors.bottomGradient
								}):Play()
								dropdownHolderFrame.Visible = false
								for ins, z in next, restorezindex do
									ins.ZIndex = z
								end
								precisionscrolling = (precisionscrolling and precisionscrolling:Disconnect() and nil) or nil
							end
							showing = dropdownEnabled
							if showing or dropdownEnabled then
							else
								delay(0.01, update)
							end
						end
					end
					local last_v
					local function Set(t, str)
						if str then
						elseif (nil == str) and t then
							str = t
						end
						selectedOption = str
						last_v = library_flags[flagName]
						library_flags[flagName] = str
						if options.Location then
							options.Location[options.LocationFlag or flagName] = str
						end
						local sstr = (selectedOption and tostring(selectedOption)) or blankstring or "No Blank String"
						dropdownSelection.Text = sstr
						if callback and __runscript and ((last_v ~= str) or options.AllowDuplicateCalls) then
							task.spawn(callback, str, last_v)
						end
						return str
					end
					if val ~= nil then
						Set(val)
					else
						Set(options.Placeholder or "Filename")
					end
					library.signals[1 + #library.signals] = dropdownSelection.Focused:Connect(function()
						showing = true
						display(true)
					end)
					library.signals[1 + #library.signals] = dropdownSelection:GetPropertyChangedSignal("Text"):Connect(function()
						if showing then
							display(true, #dropdownSelection.Text > 0)
						end
					end)
					library.signals[1 + #library.signals] = dropdownSelection.FocusLost:Connect(function(b)
						if showing then
							wait()
						end
						showing = false
						display(false)
						if b then
							Set(dropdownSelection.Text)
						end
					end)
					AddOptions(list)
					local function savestuff(s, get, skip_designer)
						if s and (type(s) == "string") then
						else
							s = nil
						end
						local rawfile = "json__save"
						if get then
						else
							local filenameddst = string.gsub(s or dropdownSelection.Text or "", "%W", "")
							if #filenameddst == 0 then
								return
							end
							rawfile = string.format("%s/%s.txt", common_string, filenameddst)
						end
						if savecallback then
							local x, e = pcall(savecallback, rawfile, library_flags[flagName])
							if x then
							elseif e then
								warn("Error while calling the Pre-Save callback:", e, debug.traceback(""))
							end
						end
						local working_with = {}
						if (persistiveflags == 1) or (persistiveflags == true) or (persistiveflags == "*") then
							persistiveflags = "all"
						elseif persistiveflags == 2 then
							persistiveflags = "tab"
						elseif persistiveflags == 3 then
							persistiveflags = "section"
						end
						if (persistiveflags == "all") or (persistiveflags == "tab") or (persistiveflags == "section") then
							for cflag, data in next, ((persistiveflags == "all") and elements) or ((persistiveflags == "tab") and tabFunctions.Flags) or (persistiveflags == "section" and sectionFunctions.Flags) do
								if (data.Type ~= "Persistence") and ((not skip_designer and designerpersists) or (string.sub(cflag, 1, 11) ~= "__Designer.")) then
									working_with[cflag] = data
								end
							end
						elseif type(persistiveflags) == "table" then
							if #persistiveflags > 0 then
								local inverted = (persistiveflags[0] == false) or persistiveflags.Inverted
								for k, cflag in next, persistiveflags do
									if k > 0 then
										local data = elements[cflag]
										if data and (data.Type ~= "Persistence") and ((skip_designer or designerpersists) or (string.sub(cflag, 1, 11) ~= "__Designer.")) then
											working_with[cflag] = (not inverted and data) or nil
										end
									end
								end
							else
								for cflag, persists in next, elements do
									if persists and ((skip_designer or designerpersists) or (string.sub(cflag, 1, 11) ~= "__Designer.")) then
										local data = elements[cflag]
										if data then
											working_with[cflag] = data
										end
									end
								end
							end
						end
						local saving = {}
						for cflag in next, working_with do
							local value = library_flags[cflag]
							if value and (type(value) == "table") and next(value) then
								value = table.clone(value)
								for k, v in next, value do
									if v and (typeof(v) == "Instance") then
										local y, o = pcall(GetPath, v)
										if y and o then
											value[k] = o
										end
									end
								end
							end
							local good, jval
							if value ~= nil then
								good, jval = JSONEncode(value)
							else
								good, jval = true, "null"
							end
							if good and ((jval ~= "null") or (value == nil)) then
							else
								local typ = typeof(value)
								if typ == "Color3" then
									value = (library.rainbowflags[cflag] and "rainbow") or Color3ToHex(value)
								elseif typ == "Instance" then
									local y, o = pcall(GetPath, value)
									if y and o then
										value = o
									end
								end
								value = tostring(value)
								good, jval = JSONEncode(value)
								if good and ((jval ~= "null") or (value == nil)) then
								else
									warn("Could not save value:", value, debug.traceback(""))
								end
							end
							if good and jval then
								saving[cflag] = value
							end
						end
						local ret
						local good, content = JSONEncode(saving)
						if good and content then
							if get then
								ret = content
							else
								if isfolder(common_string) then
								else
									makefolder(common_string)
								end
								writefile(rawfile, content)
							end
						end
						if postsave then
							local x, e = pcall(postsave, rawfile, library_flags[flagName])
							if x then
							elseif e then
								warn("Error while calling the Post-Save callback:", e, debug.traceback(""))
							end
						end
						return ret
					end
					local function loadstuff(s, jsonmode, silent, skip_designer)
						if s and (type(s) == "string") then
						else
							s = nil
						end
						local filename = "json__load"
						if jsonmode then
						else
							local filenameddst = convertfilename(s or dropdownSelection.Text, nil, "")
							if #filenameddst == 0 then
								return
							end
							filename = string.format("%s/%s.txt", common_string, filenameddst)
						end
						if loadcallback then
							local x, e = pcall(loadcallback, (jsonmode and s) or filename, library_flags[flagName])
							if x then
							elseif e then
								warn("Error while calling the Pre-Load callback:", e, debug.traceback(""))
							end
						end
						if jsonmode or not isfile or isfile(filename) then
							local content = (jsonmode and s) or (not jsonmode and readfile(filename))
							if content and (#content > 1) then
								local good, jcontent = JSONDecode(content)
								if good and jcontent then
									for cflag, val in next, jcontent do
										if skip_designer and (string.sub(tostring(cflag), 1, 11) == "__Designer.") then
											continue
										end
										if val then
											if (type(val) == "string") and (#val > 4) then
												if (#val > 7) and (#val < 64) and (string.sub(val, 1, 5) == "Enum.") then
													local e = string.find(val, ".", 6, true)
													if e then
														local en = Enum[string.sub(val, 6, e - 1)]
														en = en and en[string.sub(val, e + 1)]
														if en then
															val = en
														else
															warn("Tried & failed to convert '" .. val .. "' to EnumItem")
														end
													end
												elseif (string.sub(val, 1, 15) == "%5D%5B%7C%2B%7C") or (string.sub(val, 1, 5) == "][|+|") then
													local y, o = pcall(ResolvePath, val)
													val = (y and o) or nil
												end
											elseif (type(val) == "table") and next(val) then
												val = table.clone(val)
												for k, v in next, val do
													if v and (type(v) == "string") and ((string.sub(v, 1, 15) == "%5D%5B%7C%2B%7C") or (string.sub(v, 1, 5) == "][|+|")) then
														local y, o = pcall(ResolvePath, v)
														val[k] = (y and o) or nil
													end
												end
											end
										end
										local data = elements[cflag]
										if data and (data.Type ~= "Persistence") then
											if silent and data.RawSet then
												data:RawSet(val)
											elseif data.Set then
												data:Set(val)
											else
												library_flags[cflag] = val
											end
										end
									end
								end
							end
						end
						if postload then
							local x, e = pcall(postload, filename, library_flags[flagName])
							if x then
							elseif e then
								warn("Error while calling the Post-Load callback:", e, debug.traceback(""))
							end
						end
					end
					local fram
					do
						local buttons, offset = {}, 0
						for _, options in next, {{
							Name = "Save" .. ((suffix and (" " .. tostring(suffix))) or ""),
							Callback = savestuff
							}, {
								Name = "Load" .. ((suffix and (" " .. tostring(suffix))) or ""),
								Callback = loadstuff
							}} do
							local buttonName, callback = options.Name, options.Callback
							local realButton = Instance_new("TextButton")
							realButton.Name = "realButton"
							realButton.BackgroundColor3 = WhiteColor3
							realButton.BackgroundTransparency = 1
							realButton.Size = UDim2ScaleOne
							realButton.ZIndex = 5
							realButton.Font = Enum.Font.GothamBold
							realButton.Text = (buttonName and tostring(buttonName)) or "???"
							realButton.TextColor3 = library.colors.elementText
							colored[1 + #colored] = {realButton, "TextColor3", "elementText"}
							realButton.TextSize = 12
							local textsize = textToSize(realButton).X + 14
							if newSection.Parent and ((newSection.Parent.AbsoluteSize.X / guiScale()) < (offset + textsize + 8)) then
								offset, fram = 0, nil
							end
							local newButton = fram or Instance_new("Frame")
							fram = newButton
							local button = Instance_new("ImageLabel")
							newButton.Name = removeSpaces((buttonName and buttonName:lower() or "???") .. "Holder")
							newButton.Parent = sectionHolder
							newButton.BackgroundColor3 = WhiteColor3
							newButton.BackgroundTransparency = 1
							newButton.Size = UDim2.new(1, 0, 0, 24)
							button.Name = "button"
							button.Parent = newButton
							button.Active = true
							button.BackgroundColor3 = library.colors.topGradient
							local colored_button_BackgroundColor3 = {button, "BackgroundColor3", "topGradient"}
							colored[1 + #colored] = colored_button_BackgroundColor3
							button.BorderColor3 = library.colors.elementBorder
							colored[1 + #colored] = {button, "BorderColor3", "elementBorder"}
							button.Position = UDim2.new(0.031, offset, 0.166)
							button.Selectable = true
							button.Size = UDim2.fromOffset(28, 18)
							button.Image = "rbxassetid://2454009026"
							button.ImageColor3 = library.colors.bottomGradient
							local colored_button_ImageColor3 = {button, "ImageColor3", "bottomGradient"}
							colored[1 + #colored] = colored_button_ImageColor3
							local buttonInner = Instance_new("ImageLabel")
							buttonInner.Name = "buttonInner"
							buttonInner.Parent = button
							buttonInner.Active = true
							buttonInner.AnchorPoint = Vector2Half
							buttonInner.BackgroundColor3 = library.colors.topGradient
							colored[1 + #colored] = {buttonInner, "BackgroundColor3", "topGradient"}
							buttonInner.BorderColor3 = library.colors.elementBorder
							colored[1 + #colored] = {buttonInner, "BorderColor3", "elementBorder"}
							buttonInner.Position = UDim2ScaleHalf
							buttonInner.Selectable = true
							buttonInner.Size = UDim2.new(1, -4, 1, -4)
							buttonInner.Image = "rbxassetid://2454009026"
							buttonInner.ImageColor3 = library.colors.bottomGradient
							colored[1 + #colored] = {buttonInner, "ImageColor3", "bottomGradient"}
							button.Size = UDim2.fromOffset(textsize, 18)
							realButton.Parent = button
							offset += textsize + 6
							sectionFunctions:Update()
							local presses = 0
							local function do_callback(f, c)
								local callback = f or options.Callback or callback
								local c = c or options.Condition
								if (c ~= nil) and (type(c) == "function") and __runscript then
									local v, e = pcall(c, presses)
									if e then
										if v then
										else
											warn(debug.traceback(string.format("Error in button %s's Condition function: %s", buttonName, e), 2))
										end
									else
										return
									end
								end
								if submenuOpen or library.colorpicker then
								else
									presses = 1 + presses
									if callback and __runscript then
										task.spawn(callback, presses)
									end
								end
							end
							library.signals[1 + #library.signals] = realButton.MouseButton1Click:Connect(function()
								return do_callback()
							end)
							library.signals[1 + #library.signals] = realButton.MouseButton2Click:Connect(function()
								return do_callback(options.CallbackRight, options.ConditionRight)
							end)
							library.signals[1 + #library.signals] = button.MouseEnter:Connect(function()
								colored_button_BackgroundColor3[3] = "main"
								colored_button_BackgroundColor3[4] = 1.5
								colored_button_ImageColor3[3] = "main"
								colored_button_ImageColor3[4] = 2.5
								tweenService:Create(button, TweenInfo.new(0.35, library.configuration.easingStyle, library.configuration.easingDirection), {
									BackgroundColor3 = darkenColor(library.colors.main, 1.5),
									ImageColor3 = darkenColor(library.colors.main, 2.5)
								}):Play()
							end)
							library.signals[1 + #library.signals] = button.MouseLeave:Connect(function()
								colored_button_BackgroundColor3[3] = "topGradient"
								colored_button_BackgroundColor3[4] = nil
								colored_button_ImageColor3[3] = "bottomGradient"
								colored_button_ImageColor3[4] = nil
								tweenService:Create(button, TweenInfo.new(0.35, library.configuration.easingStyle, library.configuration.easingDirection), {
									BackgroundColor3 = library.colors.topGradient,
									ImageColor3 = library.colors.bottomGradient
								}):Play()
							end)
						end
					end
					local default = library_flags[flagName]
					function update()
						dropdownName, custom_workspace, persistiveflags, suffix, callback, loadcallback, savecallback, postload, postsave = options.Name or dropdownName, options.Workspace or library.WorkspaceName, options.Persistive or options.Flags or "all", options.Suffix, options.Callback, options.LoadCallback, options.SaveCallback, options.PostLoadCallback, options.PostSaveCallback
						local sstr = tostring(library_flags[flagName])
						dropdownHeadline.Text = (dropdownName and tostring(dropdownName)) or "???"
						return sstr
					end
					local objectdata = {
						Options = options,
						Name = flagName,
						Flag = flagName,
						Type = "Persistence",
						Default = default,
						Parent = sectionFunctions,
						Instance = dropdownSelection,
						Set = Set,
						Remove = function()
							local relod
							if newDropdown then
								newDropdown.Parent = nil
								relod = true
							end
							if fram then
								fram.Parent = nil
								relod = true
							end
							if relod then
								sectionFunctions:Update()
							end
						end,
						SaveFile = function(t, str, ret, skip_designer)
							if t ~= nil and type(t) ~= "table" then
								str, ret = t, str
							end
							if type(str) == "string" then
								str = str:match("(.+)%..+$") or str
							end
							return savestuff(str, ret, skip_designer)
						end,
						LoadFile = function(t, str, jsonmode, skip_designer)
							if (t ~= nil) and (type(t) ~= "table") then
								str, jsonmode = t, str
							end
							if isfile and isfile(str) then
								return loadstuff(readfile(str), true, nil, skip_designer)
							elseif jsonmode then
							elseif type(str) == "string" then
								str = str:match("(.+)%..+$") or str
							end
							return loadstuff(str, jsonmode, nil, skip_designer)
						end,
						LoadJSON = function(_, json, skip_designer)
							return loadstuff(json, true, nil, skip_designer)
						end,
						LoadFileRaw = function(t, str, jsonmode, skip_designer)
							if (t ~= nil) and (type(t) ~= "table") then
								str, jsonmode = t, str
							end
							if isfile and isfile(str) then
								return loadstuff(readfile(str), true, true, skip_designer)
							elseif not jsonmode and (type(str) == "string") then
								str = str:match("(.+)%..+$") or str
							end
							return loadstuff(str, jsonmode, true, skip_designer)
						end,
						LoadJSONRaw = function(_, json, skip_designer)
							return loadstuff(json, true, true, skip_designer)
						end,
						GetJSON = function(t, clipboard, skip_designer)
							if (nil == clipboard) and (t ~= nil) then
								clipboard = t
							end
							local json = savestuff(nil, true, skip_designer)
							local clipfunc = (clipboard and (type(clipboard) == "function") and clipboard) or setclipboard
							if clipboard and clipfunc then
								clipfunc(json)
							end
							return json
						end,
						RawSet = function(t, str)
							if (nil == str) and (t ~= nil) then
								str = t
							end
							selectedOption = str
							last_v = library_flags[flagName]
							library_flags[flagName] = str
							if options.Location then
								options.Location[options.LocationFlag or flagName] = str
							end
							update()
							return str
						end,
						Get = function()
							return library_flags[flagName]
						end,
						Update = update,
						Reset = function()
							return Set(nil, default)
						end
					}
					tabFunctions.Flags[flagName], sectionFunctions.Flags[flagName], elements[flagName] = objectdata, objectdata, objectdata
					return objectdata
				end
			else
				function sectionFunctions.AddPersistence()
					if library.warnedpersistance then
					else
						library.warnedpersistance = 1
						warn(debug.traceback("Persistance not supported. Missing some file functions."))
						warn("Looking for functions: isfolder  makefolder  listfiles  readfile  writefile")
						warn((isfolder and "") or "\nMissing isfolder", (makefolder and "\n") or "\nMissing makefolder", (listfiles and "") or "\nMissing listfiles", (readfile and "") or "\nMissing readfile", (writefile and "") or "\nMissing writefile")
					end
					function sectionFunctions.AddPersistence()
					end
				end
			end
			sectionFunctions.NewPersistence = sectionFunctions.AddPersistence
			sectionFunctions.CreatePersistence = sectionFunctions.AddPersistence
			sectionFunctions.Persistence = sectionFunctions.AddPersistence
			sectionFunctions.CreateSaveLoad = sectionFunctions.AddPersistence
			sectionFunctions.SaveLoad = sectionFunctions.AddPersistence
			sectionFunctions.SL = sectionFunctions.AddPersistence
			-- Custom Dropdown: tap card opens a list right inside the section (no floating menu, nothing gets cut off),
			-- big 36px rows, check marks, count badge for multi-select, scrolls when the list is long
			function sectionFunctions:AddDropdown(options, ...)
				options = (options and (type(options) == "string") and resolvevararg("Dropdown", options, ...)) or options
				local dropdownName, listt, val, callback, flagName = assert(options.Name, "Missing Name for new dropdown."), assert(options.List, "Missing List for new dropdown."), options.Value, options.Callback, options.Flag or (function()
					library.unnameddropdown = 1 + (library.unnameddropdown or 0)
					return "Dropdown" .. tostring(library.unnameddropdown)
				end)()
				if elements[flagName] ~= nil then
					warn(debug.traceback("Warning! Re-used flag '" .. flagName .. "'", 3))
				end
				local HEADER_H, ROW_H, ROW_GAP, LIST_PAD = 32, 30, 3, 6
				local multiselect = options.MultiSelect or options.Multi or options.Multiple
				local addcallback = options.ItemAdded or options.AddedCallback
				local delcallback = options.ItemRemoved or options.RemovedCallback
				local clrcallback = options.ItemsCleared or options.ClearedCallback
				local modcallback = options.ItemChanged or options.ChangedCallback
				local blankstring = not multiselect and (options.BlankValue or options.NoValueString or options.Nothing)
				local resolvelist = getresolver(listt, options.Filter, options.Method)
				local list = resolvelist()
				if next(list) then
				else
					local EmptyVal = options.EmptyValue
					if EmptyVal ~= nil then
						table.insert(list, 1, EmptyVal)
					end
				end
				local selectedOption = list[1]
				local passed_multiselect = multiselect and type(multiselect)
				if blankstring and (val == nil) then
					val = blankstring
				end
				if val ~= nil then
					selectedOption = val
				end
				if selectedOption and (type(selectedOption) == "table") then
				elseif multiselect then
					selectedOption = {}
				end
				local optionCount = 0
				local showing = false
				local rows = {}
				local emptyLabel
				local animUntil = 0
				local sizeTween
				local newDropdown = Instance_new("Frame")
				local dropdown = Instance_new("Frame")
				local dropdownCorner = Instance_new("UICorner")
				local dropdownStroke = Instance_new("UIStroke")
				local header = Instance_new("TextButton")
				local dropdownHeadline = Instance_new("TextLabel")
				local dropdownSelection = Instance_new("TextLabel")
				local countBadge = Instance_new("TextLabel")
				local countCorner = Instance_new("UICorner")
				local dropdownToggle = Instance_new("ImageLabel")
				local divider = Instance_new("Frame")
				local realDropdownHolder = Instance_new("ScrollingFrame")
				local realDropdownHolderList = Instance_new("UIListLayout")
				local realDropdownHolderPadding = Instance_new("UIPadding")
				-- outer slot in the section
				newDropdown.Name = "newDropdown"
				newDropdown.Parent = sectionHolder
				newDropdown.BackgroundColor3 = WhiteColor3
				newDropdown.BackgroundTransparency = 1
				newDropdown.BorderSizePixel = 0
				newDropdown.Size = UDim2.new(1, 0, 0, HEADER_H)
				-- card (clips the list while it grows)
				dropdown.Name = "dropdown"
				dropdown.Parent = newDropdown
				dropdown.BackgroundColor3 = library.colors.unselectedOption
				colored[1 + #colored] = {dropdown, "BackgroundColor3", "unselectedOption"}
				dropdown.BorderSizePixel = 0
				dropdown.ClipsDescendants = true
				dropdown.Position = UDim2.new(0, 0, 0, 0)
				dropdown.Size = UDim2.new(1, 0, 1, 0)
				dropdownCorner.CornerRadius = UDim.new(0, 6)
				dropdownCorner.Parent = dropdown
				dropdownStroke.Color = library.colors.innerBorder
				colored[1 + #colored] = {dropdownStroke, "Color", "innerBorder"}
				dropdownStroke.Thickness = 1
				dropdownStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				dropdownStroke.Transparency = 0.55
				dropdownStroke.Parent = dropdown
				-- header = the big tap target
				header.Name = "dropdownHeader"
				header.Parent = dropdown
				header.AutoButtonColor = false
				header.BackgroundTransparency = 1
				header.BorderSizePixel = 0
				header.Size = UDim2.new(1, 0, 0, HEADER_H)
				header.Text = ""
				header.ZIndex = 2
				dropdownHeadline.Name = "dropdownHeadline"
				dropdownHeadline.Parent = header
				dropdownHeadline.BackgroundTransparency = 1
				dropdownHeadline.BorderSizePixel = 0
				dropdownHeadline.Position = UDim2.new(0, 10, 0, 0)
				dropdownHeadline.Size = UDim2.new(1, (multiselect and -70) or -38, 0, HEADER_H)
				dropdownHeadline.Font = Enum.Font.GothamBold
				dropdownHeadline.Text = (dropdownName and tostring(dropdownName)) or "???"
				dropdownHeadline.TextColor3 = library.colors.elementText
				colored[1 + #colored] = {dropdownHeadline, "TextColor3", "elementText"}
				dropdownHeadline.TextSize = 12
				dropdownHeadline.TextXAlignment = Enum.TextXAlignment.Left
				dropdownHeadline.TextTruncate = Enum.TextTruncate.AtEnd
				dropdownSelection.Name = "dropdownSelection"
				dropdownSelection.Parent = header
				dropdownSelection.BackgroundTransparency = 1
				dropdownSelection.BorderSizePixel = 0
				dropdownSelection.Position = UDim2.new(0, 14, 0, 24)
				dropdownSelection.Size = UDim2.new(1, (multiselect and -90) or -54, 0, 20)
				dropdownSelection.Font = Enum.Font.GothamBold
				dropdownSelection.Text = ""
				dropdownSelection.TextColor3 = library.colors.elementText
				colored[1 + #colored] = {dropdownSelection, "TextColor3", "elementText"}
				dropdownSelection.TextSize = 12
				dropdownSelection.TextXAlignment = Enum.TextXAlignment.Left
				dropdownSelection.TextTruncate = Enum.TextTruncate.AtEnd
				dropdownSelection.Visible = false
				countBadge.Name = "countBadge"
				countBadge.Parent = header
				countBadge.AnchorPoint = Vector2.new(1, 0.5)
				countBadge.BackgroundColor3 = library.colors.main
				colored[1 + #colored] = {countBadge, "BackgroundColor3", "main"}
				countBadge.BorderSizePixel = 0
				countBadge.Position = UDim2.new(1, -30, 0, HEADER_H / 2)
				countBadge.Size = UDim2.fromOffset(22, 16)
				countBadge.Font = Enum.Font.GothamBold
				countBadge.Text = "0"
				countBadge.TextColor3 = Color3.new(1, 1, 1)
				countBadge.TextSize = 11
				countBadge.Visible = false
				countCorner.CornerRadius = UDim.new(1, 0)
				countCorner.Parent = countBadge
				dropdownToggle.Name = "dropdownToggle"
				dropdownToggle.Parent = header
				dropdownToggle.AnchorPoint = Vector2.new(0.5, 0.5)
				dropdownToggle.BackgroundTransparency = 1
				dropdownToggle.BorderSizePixel = 0
				dropdownToggle.Position = UDim2.new(1, -16, 0, HEADER_H / 2)
				dropdownToggle.Rotation = 90
				dropdownToggle.Size = UDim2.fromOffset(10, 10)
				dropdownToggle.Image = "rbxassetid://71659683"
				dropdownToggle.ImageColor3 = library.colors.elementText
				colored[1 + #colored] = {dropdownToggle, "ImageColor3", "elementText"}
				-- line between header and list
				divider.Name = "divider"
				divider.Parent = dropdown
				divider.BackgroundColor3 = library.colors.innerBorder
				colored[1 + #colored] = {divider, "BackgroundColor3", "innerBorder"}
				divider.BorderSizePixel = 0
				divider.Position = UDim2.new(0, 10, 0, HEADER_H)
				divider.Size = UDim2.new(1, -20, 0, 1)
				divider.Visible = false
				-- the list
				realDropdownHolder.Name = "realDropdownHolder"
				realDropdownHolder.Parent = dropdown
				realDropdownHolder.Active = true
				realDropdownHolder.BackgroundTransparency = 1
				realDropdownHolder.BorderSizePixel = 0
				realDropdownHolder.Position = UDim2.new(0, 0, 0, HEADER_H + 1)
				realDropdownHolder.Size = UDim2.new(1, 0, 0, 0)
				realDropdownHolder.CanvasSize = UDim2.new()
				realDropdownHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
				realDropdownHolder.ScrollBarThickness = 3
				realDropdownHolder.ScrollBarImageTransparency = 0.3
				realDropdownHolder.ScrollBarImageColor3 = library.colors.section
				colored[1 + #colored] = {realDropdownHolder, "ScrollBarImageColor3", "section"}
				realDropdownHolder.ScrollingDirection = Enum.ScrollingDirection.Y
				realDropdownHolder.Selectable = false
				realDropdownHolder.Visible = false
				realDropdownHolderList.Name = "realDropdownHolderList"
				realDropdownHolderList.Parent = realDropdownHolder
				realDropdownHolderList.Padding = UDim.new(0, ROW_GAP)
				realDropdownHolderList.SortOrder = Enum.SortOrder.LayoutOrder
				realDropdownHolderPadding.Parent = realDropdownHolder
				realDropdownHolderPadding.PaddingTop = UDim.new(0, LIST_PAD)
				realDropdownHolderPadding.PaddingBottom = UDim.new(0, LIST_PAD)
				realDropdownHolderPadding.PaddingLeft = UDim.new(0, 8)
				realDropdownHolderPadding.PaddingRight = UDim.new(0, 8)
				sectionFunctions:Update()
				-- the list keeps the section height in step while the card grows / shrinks
				library.signals[1 + #library.signals] = sectionList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
					if showing or (os.clock() < animUntil) then
						sectionFunctions:Update()
					end
				end)
				local display, update, validate, SetupValidation, precisionscrolling
				local function isSelected(v)
					if multiselect then
						return (type(selectedOption) == "table") and (table.find(selectedOption, v) ~= nil)
					end
					return selectedOption == v
				end
				local function selectionText()
					if multiselect then
						if passed_multiselect == "string" then
							return multiselect
						end
						local names = {}
						if type(selectedOption) == "table" then
							for _, v in next, selectedOption do
								names[1 + #names] = tostring(v)
							end
						end
						if #names > 0 then
							return table.concat(names, ", ")
						end
						return tostring(options.BlankValue or options.NoValueString or options.Nothing or "Select Item(s)")
					end
					return ResolveDropdownItemName(multiselect, passed_multiselect, options.Name, selectedOption, flagName, blankstring)
				end
				local function refreshHeader()
					dropdownSelection.Text = selectionText()
					dropdownHeadline.Text = ((dropdownName and tostring(dropdownName)) or "???") .. " : " .. dropdownSelection.Text
					if multiselect then
						local count = (type(selectedOption) == "table" and #selectedOption) or 0
						countBadge.Visible = count > 0
						countBadge.Text = tostring(count)
					end
				end
				refreshHeader()
				-- paint one row: selected / hovered / normal
				local function paintRow(r, hover, instant)
					local on = isSelected(r.value) and true or false
					r.on = on
					local c = library.colors
					local bg, bgT
					if hover then
						bg, bgT = c.hoveredOptionTop, 0
					elseif on then
						bg, bgT = c.selectedOption, 0
					else
						bg, bgT = c.selectedOption, 1
					end
					local textColor = (on and c.main) or c.elementText
					local armT = (on and 0) or 1
					if instant then
						r.row.BackgroundColor3 = bg
						r.row.BackgroundTransparency = bgT
						r.label.TextColor3 = textColor
						for _, arm in next, r.arms do
							arm.BackgroundTransparency = armT
						end
						if r.box then
							r.box.BackgroundTransparency = armT
							r.boxStroke.Color = (on and c.main) or c.otherElementText
						end
					else
						local info = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
						tweenService:Create(r.row, info, {
							BackgroundColor3 = bg,
							BackgroundTransparency = bgT
						}):Play()
						tweenService:Create(r.label, info, {
							TextColor3 = textColor
						}):Play()
						for _, arm in next, r.arms do
							tweenService:Create(arm, info, {
								BackgroundTransparency = armT
							}):Play()
						end
						if r.box then
							tweenService:Create(r.box, info, {
								BackgroundTransparency = armT
							}):Play()
							tweenService:Create(r.boxStroke, info, {
								Color = (on and c.main) or c.otherElementText
							}):Play()
						end
					end
				end
				local function refreshRows()
					for i = 1, #rows do
						local r = rows[i]
						if r and (r.on ~= (isSelected(r.value) and true or false)) then
							paintRow(r, false)
						end
					end
				end
				local function clearRows()
					for i = #rows, 1, -1 do
						local r = rows[i]
						if r and r.row then
							r.row:Destroy()
						end
						rows[i] = nil
					end
					if emptyLabel then
						emptyLabel:Destroy()
						emptyLabel = nil
					end
				end
				local function listHeight()
					local n = math.max(optionCount, 1)
					local content = (n * ROW_H) + ((n - 1) * ROW_GAP) + (LIST_PAD * 2)
					-- 4 full rows + half of the next one, so people see that the list scrolls
					local cap = LIST_PAD + (4 * (ROW_H + ROW_GAP)) + (ROW_H / 2)
					return math.min(content, cap)
				end
				do
					local Signals = {}
					local Setup
					function SetupValidation()
						for k, v in next, Signals do
							v = v and v:Disconnect()
							Signals[k] = nil
						end
						if options.AutoValidate and list and (typeof(list) == "Instance") then
							local Val = library_flags[flagName] or selectedOption
							if multiselect then
								for _, v in next, Val do
									Setup(v)
								end
							else
								Setup(Val)
							end
						end
					end
					local gpcs = game.GetPropertyChangedSignal
					function Setup(v)
						if typeof(v) == "Instance" then
							local Signal
							Signal = gpcs(v, "Parent"):Connect(function()
								if options.AutoValidate then
									if list and (v.Parent ~= list) then
										Signal = (Signal and Signal:Disconnect() and nil) or nil
										validate()
									end
								else
									for k, v in next, Signals do
										v = v and v:Disconnect()
										Signals[k] = nil
									end
								end
							end)
							library.signals[1 + #library.signals] = Signal
						end
					end
				end
				local Set = (multiselect and function(t, dat)
					if (nil == dat) and (t ~= nil) then
						dat = t
					end
					local lastv = library_flags[flagName]
					if lastv and (selectedOption == lastv) then
					else
						if lastv and (type(lastv) == "table") then
							selectedOption = library_flags[flagName]
						else
							library_flags[flagName] = selectedOption
						end
						warn("Attempting to use new table for", flagName, " Please use :Set(), as setting through flags table may cause errors", debug.traceback(""))
						lastv = library_flags[flagName]
					end
					local cloned = {unpack(selectedOption)}
					if not dat then
						if #selectedOption ~= 0 then
							table.clear(selectedOption)
							refreshHeader()
							refreshRows()
							if callback and __runscript then
								task.spawn(callback, selectedOption, cloned)
							end
						end
						return selectedOption
					elseif type(dat) ~= "table" then
						warn("Expected table for argument #1 on Set for MultiSelect dropdown. Got", dat, debug.traceback(""))
						return selectedOption
					end
					for k = table.pack(unpack(dat)).n, 1, -1 do
						if dat[k] == nil then
							table.remove(dat, k)
						end
					end
					local proceed = #cloned ~= #dat
					table.clear(selectedOption)
					for k, v in next, dat do
						selectedOption[k] = v
						if proceed then
						elseif cloned[k] ~= v then
							proceed = 1
						end
					end
					refreshHeader()
					refreshRows()
					if proceed and callback and __runscript then
						task.spawn(callback, selectedOption, cloned)
					end
					if options.AutoValidate then
						SetupValidation()
					end
					return selectedOption
				end) or function(t, str)
					if (nil == str) and (t ~= nil) then
						str = t
					end
					local last_v = library_flags[flagName]
					selectedOption = str
					library_flags[flagName] = str
					if options.Location then
						options.Location[options.LocationFlag or flagName] = str
					end
					refreshHeader()
					refreshRows()
					if callback and __runscript and ((last_v ~= str) or options.AllowDuplicateCalls) then
						task.spawn(callback, str, last_v)
					end
					if options.AutoValidate then
						SetupValidation()
					end
					return str
				end
				if val ~= nil then
					Set(val)
				else
					library_flags[flagName] = selectedOption
					if options.Location then
						options.Location[options.LocationFlag or flagName] = selectedOption
					end
					if options.AutoValidate then
						SetupValidation()
					end
				end
				-- sort / blank-value handling + counting (same rules as before)
				local function prepareList(optionsTable)
					if options.Sort then
						local didstuff, dosort = nil, options.Sort
						if type(dosort) == "function" then
							local g, h = pcall(table.sort, optionsTable, dosort)
							if g then
								didstuff = true
							elseif h then
								warn("Error sorting list:", debug.traceback(h))
							end
						elseif (dosort ~= 1) and (dosort ~= true) then
							warn("Potential mistake for passed Sort argument:", dosort, debug.traceback(""))
						end
						if not didstuff then
							table.sort(optionsTable, library.defaultSort)
						end
					end
					if blankstring and ((optionsTable[1] ~= blankstring) or table.find(optionsTable, blankstring, 2)) then
						local exists = table.find(optionsTable, blankstring)
						if exists then
							for _ = 1, 35 do
								table.remove(optionsTable, exists)
								exists = table.find(optionsTable, blankstring)
								if exists then
								else
									break
								end
							end
						end
						table.insert(optionsTable, 1, blankstring)
					end
					optionCount = 0
					for _ in next, optionsTable do
						optionCount = optionCount + 1
					end
				end
				prepareList(list)
				-- a check mark drawn from two small bars (no font symbols needed)
				local function makeArm(parent, px, py, w, h, rot, color)
					local arm = Instance.new("Frame")
					arm.AnchorPoint = Vector2.new(0.5, 0.5)
					arm.BackgroundColor3 = color
					arm.BackgroundTransparency = 1
					arm.BorderSizePixel = 0
					arm.Position = UDim2.fromScale(px / 20, py / 20)
					arm.Rotation = rot
					arm.Size = UDim2.fromScale(w / 20, h / 20)
					local armCorner = Instance.new("UICorner")
					armCorner.CornerRadius = UDim.new(1, 0)
					armCorner.Parent = arm
					arm.Parent = parent
					return arm
				end
				-- what happens when a row is tapped
				local function pick(r)
					if library.colorpicker then
						return
					end
					local v = r.value
					if multiselect then
						local cloned = {unpack(selectedOption)}
						local togged = table.find(selectedOption, v)
						if togged then
							table.remove(selectedOption, togged)
						else
							selectedOption[1 + #selectedOption] = v
						end
						togged = table.find(selectedOption, v)
						paintRow(r, false)
						refreshHeader()
						if __runscript then
							if callback then
								task.spawn(callback, selectedOption, cloned)
							end
							if togged then
								if addcallback then
									task.spawn(addcallback, v, selectedOption)
								end
							elseif delcallback then
								task.spawn(delcallback, v, selectedOption)
							end
							if modcallback then
								task.spawn(modcallback, v, togged, selectedOption)
							end
							if (#selectedOption == 0) and clrcallback then
								task.spawn(clrcallback, selectedOption, cloned)
							end
						end
						return
					end
					if selectedOption ~= v then
						local last_v = library_flags[flagName]
						selectedOption = v
						library_flags[flagName] = selectedOption
						if options.Location then
							options.Location[options.LocationFlag or flagName] = selectedOption
						end
						refreshRows()
						refreshHeader()
						if callback and __runscript then
							task.spawn(callback, selectedOption, last_v)
						end
					end
					-- short pause so people see the check mark, then fold the list
					task.delay(0.12, function()
						if showing then
							display(false)
						end
					end)
				end
				local function buildRows()
					clearRows()
					local n = 0
					for _, v in next, list do
						n = n + 1
						local r = {
							value = v
						}
						local stringed = tostring(v)
						local row = Instance.new("TextButton")
						row.Name = stringed
						row.AutoButtonColor = false
						row.BackgroundColor3 = library.colors.selectedOption
						row.BackgroundTransparency = 1
						row.BorderSizePixel = 0
						row.LayoutOrder = n
						row.Size = UDim2.new(1, 0, 0, ROW_H)
						row.Text = ""
						local rowCorner = Instance.new("UICorner")
						rowCorner.CornerRadius = UDim.new(0, 6)
						rowCorner.Parent = row
						local label = Instance.new("TextLabel")
						label.BackgroundTransparency = 1
						label.BorderSizePixel = 0
						label.Position = UDim2.new(0, 12, 0, 0)
						label.Size = UDim2.new(1, -48, 1, 0)
						label.Font = Enum.Font.GothamMedium
						label.Text = stringed
						label.TextColor3 = library.colors.elementText
						label.TextSize = 12
						label.TextXAlignment = Enum.TextXAlignment.Left
						label.TextTruncate = Enum.TextTruncate.AtEnd
						label.Parent = row
						local check = Instance.new("Frame")
						check.AnchorPoint = Vector2.new(1, 0.5)
						check.BackgroundColor3 = library.colors.main
						check.BackgroundTransparency = 1
						check.BorderSizePixel = 0
						check.Position = UDim2.new(1, -12, 0.5, 0)
						check.Size = UDim2.fromOffset(20, 20)
						if multiselect then
							-- multi-select: little checkbox
							local boxCorner = Instance.new("UICorner")
							boxCorner.CornerRadius = UDim.new(0, 6)
							boxCorner.Parent = check
							local boxStroke = Instance.new("UIStroke")
							boxStroke.Color = library.colors.otherElementText
							boxStroke.Thickness = 2
							boxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
							boxStroke.Parent = check
							r.box, r.boxStroke = check, boxStroke
						end
						check.Parent = row
						local armColor = (multiselect and Color3.new(1, 1, 1)) or library.colors.main
						r.arms = {makeArm(check, 6.25, 12.25, 7, 2.6, 45, armColor), makeArm(check, 11.75, 10.25, 12, 2.6, -45, armColor)}
						r.row, r.label = row, label
						rows[n] = r
						row.MouseButton1Click:Connect(function()
							pick(r)
						end)
						row.MouseEnter:Connect(function()
							paintRow(r, true)
						end)
						row.MouseLeave:Connect(function()
							paintRow(r, false)
						end)
						row.InputBegan:Connect(function(input)
							if isPress(input) then
								paintRow(r, true)
							end
						end)
						row.InputEnded:Connect(function(input)
							if isPress(input) then
								paintRow(r, false)
							end
						end)
						row.Parent = realDropdownHolder
						paintRow(r, false, true)
					end
					if n == 0 then
						emptyLabel = Instance.new("TextLabel")
						emptyLabel.BackgroundTransparency = 1
						emptyLabel.BorderSizePixel = 0
						emptyLabel.Size = UDim2.new(1, 0, 0, ROW_H)
						emptyLabel.Font = Enum.Font.GothamMedium
						emptyLabel.Text = "Nothing here yet"
						emptyLabel.TextColor3 = library.colors.otherElementText
						emptyLabel.TextSize = 13
						emptyLabel.Parent = realDropdownHolder
					end
				end
				local function scrollToSelected()
					if not showing then
						return
					end
					for i = 1, #rows do
						if rows[i] and isSelected(rows[i].value) then
							realDropdownHolder.CanvasPosition = Vector2.new(0, math.max(0, LIST_PAD + ((i - 1) * (ROW_H + ROW_GAP)) - ROW_H))
							break
						end
					end
				end
				-- if the opened list sticks out below the visible area, scroll the page a little
				local function ensureVisible()
					local sf = newDropdown:FindFirstAncestorOfClass("ScrollingFrame")
					if sf and showing then
						local overflow = (newDropdown.AbsolutePosition.Y + newDropdown.AbsoluteSize.Y) - (sf.AbsolutePosition.Y + sf.AbsoluteSize.Y)
						if overflow > 0 then
							tweenService:Create(sf, TweenInfo.new(0.25, library.configuration.easingStyle, library.configuration.easingDirection), {
								CanvasPosition = Vector2.new(sf.CanvasPosition.X, sf.CanvasPosition.Y + math.ceil(overflow / guiScale()) + 8)
							}):Play()
						end
					end
				end
				function display(open)
					open = (open and true) or false
					if open and windowFunctions.CloseDropdown and (windowFunctions.CloseDropdown ~= display) then
						pcall(windowFunctions.CloseDropdown)
						windowFunctions.CloseDropdown = nil
					end
					list = resolvelist()
					if next(list) then
					else
						local EmptyVal = options.EmptyValue
						if EmptyVal ~= nil then
							table.insert(list, 1, EmptyVal)
						end
					end
					prepareList(list)
					showing = open
					local info = TweenInfo.new(0.25, library.configuration.easingStyle, library.configuration.easingDirection)
					if sizeTween then
						sizeTween:Cancel()
						sizeTween = nil
					end
					animUntil = os.clock() + 0.6
					if precisionscrolling then
						precisionscrolling:Disconnect()
						precisionscrolling = nil
					end
					if open then
						windowFunctions.CloseDropdown = display
						buildRows()
						local h = listHeight()
						realDropdownHolder.Size = UDim2.new(1, 0, 0, h)
						realDropdownHolder.CanvasPosition = Vector2.new(0, 0)
						realDropdownHolder.Visible = true
						divider.Visible = true
						sizeTween = tweenService:Create(newDropdown, info, {
							Size = UDim2.new(1, 0, 0, HEADER_H + 1 + h)
						})
						sizeTween:Play()
						tweenService:Create(dropdownToggle, info, {
							Rotation = 270,
							ImageColor3 = library.colors.main
						}):Play()
						tweenService:Create(dropdownStroke, info, {
							Color = library.colors.main
						}):Play()
						if not options.DisablePrecisionScrolling then
							local upkey = options.ScrollUpButton or library.scrollupbutton or shared.scrollupbutton or Enum.KeyCode.Up
							local downkey = options.ScrollDownButton or library.scrolldownbutton or shared.scrolldownbutton or Enum.KeyCode.Down
							precisionscrolling = userInputService.InputBegan:Connect(function(input)
								if input.UserInputType == Enum.UserInputType.Keyboard then
									local code = input.KeyCode
									local isup = code == upkey
									local isdown = code == downkey
									if isup or isdown then
										local txt = userInputService:GetFocusedTextBox()
										if txt then
										else
											while wait_check() and userInputService:IsKeyDown(code) do
												realDropdownHolder.CanvasPosition = Vector2.new(0, math.clamp(realDropdownHolder.CanvasPosition.Y + ((isup and -5) or 5), 0, realDropdownHolder.AbsoluteCanvasSize.Y))
											end
										end
									end
								end
							end)
							library.signals[1 + #library.signals] = precisionscrolling
						end
						task.delay(0.05, scrollToSelected)
						task.delay(0.3, function()
							if showing then
								sectionFunctions:Update()
								ensureVisible()
							end
						end)
					else
						if windowFunctions.CloseDropdown == display then
							windowFunctions.CloseDropdown = nil
						end
						local closing = tweenService:Create(newDropdown, info, {
							Size = UDim2.new(1, 0, 0, HEADER_H)
						})
						sizeTween = closing
						closing.Completed:Connect(function(state)
							if (state == Enum.PlaybackState.Completed) and not showing then
								realDropdownHolder.Visible = false
								divider.Visible = false
								clearRows()
								sectionFunctions:Update()
							end
						end)
						closing:Play()
						tweenService:Create(dropdownToggle, info, {
							Rotation = 90,
							ImageColor3 = library.colors.otherElementText
						}):Play()
						tweenService:Create(dropdownStroke, info, {
							Color = library.colors.innerBorder
						}):Play()
					end
					if multiselect or (next(list) and table.find(list, library_flags[flagName])) then
					else
						Set(list[1])
					end
					if open then
						refreshRows()
					else
						task.delay(0.01, update)
					end
				end
				-- tap feedback + open / close
				library.signals[1 + #library.signals] = header.MouseButton1Click:Connect(function()
					if not library.colorpicker then
						display(not showing)
					end
				end)
				library.signals[1 + #library.signals] = header.InputBegan:Connect(function(input)
					if isPress(input) then
						tweenService:Create(dropdown, TweenInfo.new(0.1), {
							BackgroundColor3 = library.colors.unhoveredOptionTop
						}):Play()
					end
				end)
				library.signals[1 + #library.signals] = header.InputEnded:Connect(function(input)
					if isPress(input) then
						tweenService:Create(dropdown, TweenInfo.new(0.15), {
							BackgroundColor3 = library.colors.topGradient
						}):Play()
					end
				end)
				library.signals[1 + #library.signals] = header.MouseEnter:Connect(function()
					if not showing then
						tweenService:Create(dropdownStroke, TweenInfo.new(0.15), {
							Color = darkenColor(library.colors.main, 1.8)
						}):Play()
					end
				end)
				library.signals[1 + #library.signals] = header.MouseLeave:Connect(function()
					tweenService:Create(dropdown, TweenInfo.new(0.15), {
						BackgroundColor3 = library.colors.topGradient
					}):Play()
					if not showing then
						tweenService:Create(dropdownStroke, TweenInfo.new(0.15), {
							Color = library.colors.innerBorder
						}):Play()
					end
				end)
				function update()
					dropdownName, callback = options.Name or dropdownName, options.Callback
					refreshHeader()
					dropdownHeadline.Text = ((dropdownName and tostring(dropdownName)) or "???") .. " : " .. dropdownSelection.Text
					refreshRows()
					return dropdownSelection.Text
				end
				function validate(fallbackValue)
					if list and table.find(list, library_flags[flagName]) then
						update()
						return true
					end
					if fallbackValue ~= nil then
						if fallbackValue == "__DEFAULT" then
							fallbackValue = fallbackValue
						end
					else
						fallbackValue = list[1]
					end
					return Set((multiselect and {fallbackValue}) or fallbackValue)
				end
				local default = library_flags[flagName]
				if type(default) == "table" then
					default = table.clone(default)
				end
				local objectdata = {
					Options = options,
					Name = flagName,
					Flag = flagName,
					Type = "Dropdown",
					Default = default,
					Parent = sectionFunctions,
					Instance = dropdownSelection,
					Get = function()
						return library_flags[flagName]
					end,
					Set = Set,
					Remove = function()
						if newDropdown then
							newDropdown.Parent = nil
							sectionFunctions:Update()
						end
					end,
					RawSet = ((multiselect and function(t, dat)
						if (nil == dat) and (t ~= nil) then
							dat = t
						end
						local lastv = library_flags[flagName]
						if lastv and (selectedOption == lastv) then
						else
							if lastv and type(lastv) == "table" then
								selectedOption = library_flags[flagName]
							else
								library_flags[flagName] = selectedOption
							end
							warn("Attempting to use new table for", flagName, " Please use :Set(), as setting through flags table may cause errors", debug.traceback(""))
							lastv = library_flags[flagName]
						end
						local cloned = {unpack(selectedOption)}
						if not dat then
							if #selectedOption ~= 0 then
								table.clear(selectedOption)
							end
							return selectedOption
						elseif type(dat) ~= "table" then
							warn("Expected table for argument #1 on Set for MultiSelect dropdown. Got", dat, debug.traceback(""))
							return selectedOption
						end
						for k = table.pack(unpack(dat)).n, 1, -1 do
							if dat[k] == nil then
								table.remove(dat, k)
							end
						end
						table.clear(selectedOption)
						for k, v in next, dat do
							selectedOption[k] = v
						end
						return selectedOption
					end) or function(t, str)
						if (nil == str) and (t ~= nil) then
							str = t
						end
						selectedOption = str
						library_flags[flagName] = str
						if options.Location then
							options.Location[options.LocationFlag or flagName] = str
						end
						update()
						return str
					end),
					Update = update,
					Reset = function()
						return Set(nil, default)
					end
				}
				function objectdata.UpdateList(t, listt, updateValues)
					if ((nil == listt) and (t ~= nil)) or ((type(t) == "table") and (type(listt) ~= "table")) then
						listt, updateValues = t, listt
					end
					if listt == objectdata then
						listt = nil
					end
					resolvelist = getresolver(listt or options.List, options.Filter, options.Method)
					list = resolvelist()
					if next(list) then
					else
						local EmptyVal = options.EmptyValue
						if EmptyVal ~= nil then
							table.insert(list, 1, EmptyVal)
						end
					end
					if updateValues then
						validate()
					end
					if showing then
						-- list is open right now: rebuild the rows in place and resize the card
						local Og = realDropdownHolder.CanvasPosition
						prepareList(list)
						buildRows()
						local h = listHeight()
						realDropdownHolder.Size = UDim2.new(1, 0, 0, h)
						animUntil = os.clock() + 0.6
						if sizeTween then
							sizeTween:Cancel()
						end
						sizeTween = tweenService:Create(newDropdown, TweenInfo.new(0.25, library.configuration.easingStyle, library.configuration.easingDirection), {
							Size = UDim2.new(1, 0, 0, HEADER_H + 1 + h)
						})
						sizeTween:Play()
						if Og.Y > 0 then
							task.delay(0.05, function()
								realDropdownHolder.CanvasPosition = Vector2.new(0, math.clamp(Og.Y, 0, realDropdownHolder.AbsoluteCanvasSize.Y))
							end)
						end
					end
					return list
				end
				tabFunctions.Flags[flagName], sectionFunctions.Flags[flagName], elements[flagName] = objectdata, objectdata, objectdata
				return objectdata
			end
			sectionFunctions.AddDropDown = sectionFunctions.AddDropdown
			sectionFunctions.NewDropDown = sectionFunctions.AddDropdown
			sectionFunctions.NewDropdown = sectionFunctions.AddDropdown
			sectionFunctions.CreateDropdown = sectionFunctions.AddDropdown
			sectionFunctions.CreateDropdown = sectionFunctions.AddDropdown
			sectionFunctions.DropDown = sectionFunctions.AddDropdown
			sectionFunctions.Dropdown = sectionFunctions.AddDropdown
			sectionFunctions.DD = sectionFunctions.AddDropdown
			sectionFunctions.Dd = sectionFunctions.AddDropdown
			function sectionFunctions:AddColorpicker(options, ...)
				options = (options and type(options) == "string" and resolvevararg("Colorpicker", options, ...)) or options
				if options.Random == true then
					options.Value = "random"
				elseif options.Rainbow == true then
					options.Value = "rainbow"
				end
				local colorPickerName, presetColor, callback, flagName = assert(options.Name, "Missing Name for new colorpicker."), options.Value, options.Callback, options.Flag or (function()
					library.unnamedcolorpicker = 1 + (library.unnamedcolorpicker or 0)
					return "Colorpicker" .. tostring(library.unnamedcolorpicker)
				end)()
				if elements[flagName] ~= nil then
					warn(debug.traceback("Warning! Re-used flag '" .. flagName .. "'", 3))
				end
				local designers = options.__designer
				options.__designer = nil
				local rainbowColorMode = false
				if presetColor == "random" then
					presetColor = Color3.new(math.random(), math.random(), math.random())
				elseif presetColor == "rainbow" then
					presetColor = WhiteColor3
					rainbowColorMode = true
				end
				local newColorPicker = Instance_new("Frame")
				local colorPicker = Instance_new("ImageLabel")
				local colorPickerInner = Instance_new("ImageLabel")
				local colorPickerHeadline = Instance_new("TextLabel")
				local colorPickerButton = Instance_new("TextButton")
				local colorPickerHolderFrame = Instance_new("ImageLabel")
				local colorPickerHolderInner = Instance_new("ImageLabel")
				local color = Instance_new("ImageLabel")
				local selectorColor = Instance_new("Frame")
				local hue = Instance_new("ImageLabel")
				local hueGradient = Instance_new("UIGradient")
				local selectorHue = Instance_new("Frame")
				local randomColor = Instance_new("ImageLabel")
				local randomColorInner = Instance_new("ImageLabel")
				local randomColorButton = Instance_new("ImageButton")
				local hexInputBox = Instance_new("TextBox")
				local hexInput = Instance_new("ImageLabel")
				local hexInputInner = Instance_new("ImageLabel")
				local rainbow = Instance_new("ImageLabel")
				local rainbowInner = Instance_new("ImageLabel")
				local rainbowButton = Instance_new("ImageButton")
				local startingColor = presetColor or WhiteColor3
				local colorPickerEnabled = false
				local colorH, colorS, colorV = 1, 1, 1
				local colorInput, hueInput
				local oldBackgroundColor = Color3.new()
				local oldImageColor = oldBackgroundColor
				local oldColor = oldBackgroundColor
				local rainbowColorValue = 0
				newColorPicker.Name = "newColorPicker"
				newColorPicker.Parent = sectionHolder
				applyCard(newColorPicker)
				newColorPicker.Size = UDim2.new(1, 0, 0, 28)
				colorPicker.Name = "colorPicker"
				colorPicker.Parent = newColorPicker
				colorPicker.Active = true
				colorPicker.BackgroundColor3 = library.colors.topGradient
				local colored_colorPicker_BackgroundColor3 = {colorPicker, "BackgroundColor3", "topGradient"}
				colored[1 + #colored] = colored_colorPicker_BackgroundColor3
				colorPicker.BorderColor3 = library.colors.elementBorder
				colored[1 + #colored] = {colorPicker, "BorderColor3", "elementBorder"}
				colorPicker.Position = UDim2.new(1, -36, 0.5, -6)
				colorPicker.Selectable = true
				colorPicker.Size = UDim2.fromOffset(24, 12)
				colorPicker.Image = "rbxassetid://2454009026"
				colorPicker.ImageColor3 = library.colors.bottomGradient
				local colored_colorPicker_ImageColor3 = {colorPicker, "ImageColor3", "bottomGradient"}
				colored[1 + #colored] = colored_colorPicker_ImageColor3
				colorPickerInner.Name = "colorPickerInner"
				colorPickerInner.Parent = colorPicker
				colorPickerInner.Active = true
				colorPickerInner.AnchorPoint = Vector2Half
				colorPickerInner.BorderColor3 = library.colors.elementBorder
				colored[1 + #colored] = {colorPickerInner, "BorderColor3", "elementBorder"}
				colorPickerInner.Position = UDim2ScaleHalf
				colorPickerInner.Selectable = true
				colorPickerInner.Size = UDim2.new(1, -4, 1, -4)
				colorPickerInner.Image = "rbxassetid://2454009026"
				colorPickerInner.BackgroundColor3 = darkenColor(startingColor, 1.5)
				colorPickerInner.ImageColor3 = darkenColor(startingColor, 2.5)
				colorPickerHeadline.Name = "colorPickerHeadline"
				colorPickerHeadline.Parent = newColorPicker
				colorPickerHeadline.BackgroundColor3 = WhiteColor3
				colorPickerHeadline.BackgroundTransparency = 1
				colorPickerHeadline.Position = UDim2.new(0, 10, 0.5, -6)
				colorPickerHeadline.Size = UDim2.fromOffset(173, 11)
				colorPickerHeadline.Font = Enum.Font.GothamBold
				colorPickerHeadline.Text = colorPickerName or "???"
				colorPickerHeadline.TextColor3 = library.colors.elementText
				colored[1 + #colored] = {colorPickerHeadline, "TextColor3", "elementText"}
				colorPickerHeadline.TextSize = 12
				colorPickerHeadline.TextXAlignment = Enum.TextXAlignment.Left
				colorPickerButton.Name = "colorPickerButton"
				colorPickerButton.Parent = newColorPicker
				colorPickerButton.BackgroundColor3 = WhiteColor3
				colorPickerButton.BackgroundTransparency = 1
				colorPickerButton.Size = UDim2ScaleOne
				colorPickerButton.ZIndex = 5
				colorPickerButton.Font = Enum.Font.SourceSans
				colorPickerButton.Text = ""
				colorPickerButton.TextColor3 = Color3.new()
				colorPickerButton.TextSize = 12
				colorPickerButton.TextTransparency = 1
				colorPickerButton.BorderColor3 = library.colors.elementBorder
				local colored_colorPickerButton_BorderColor3 = {colorPickerButton, "BorderColor3", "elementBorder"}
				colored[1 + #colored] = colored_colorPickerButton_BorderColor3
				local function UpdateColorPicker(force, rainbsow)
					local last_vv = library_flags[flagName]
					local newColor = force or Color3.fromHSV(colorH, colorS, colorV)
					if not force then
						colorH, colorS, colorV = newColor:ToHSV()
					end
					colorPickerInner.BackgroundColor3 = darkenColor(newColor, 1.5)
					colorPickerInner.ImageColor3 = darkenColor(newColor, 2.5)
					color.BackgroundColor3 = Color3.fromHSV(colorH, 1, 1)
					library_flags[flagName] = newColor
					if options.Location then
						options.Location[options.LocationFlag or flagName] = newColor
					end
					hexInputBox.Text = Color3ToHex(newColor)
					if force then
						color.BackgroundColor3 = force
						selectorColor.Position = UDim2.new(force and select(3, Color3.toHSV(force)))
					end
					local pos = 1 - (Color3.toHSV(newColor))
					local scalex = selectorHue.Position.X.Scale
					if (scalex ~= pos) and not (((pos == 0) or (pos == 1)) and ((scalex == 1) or (scalex == 0))) then
						selectorHue.Position = UDim2.new(pos)
					end
					if callback and __runscript and (last_vv ~= newColor) then
						task.spawn(callback, newColor, last_vv, rainbsow)
					end
				end
				library.signals[1 + #library.signals] = colorPickerButton.MouseButton1Click:Connect(function()
					if windowFunctions.CloseDropdown then
						pcall(windowFunctions.CloseDropdown)
						windowFunctions.CloseDropdown = nil
					end
					if (submenuOpen == colorPicker) or (submenuOpen == nil) then
						colorPickerEnabled = not colorPickerEnabled
						library.colorpicker = colorPickerEnabled
						colorPickerHolderFrame.Visible = colorPickerEnabled
						if colorPickerEnabled then
							for _, v in next, colorpickerconflicts do
								v.Visible = false
							end
							submenuOpen = colorPicker
							newColorPicker.ZIndex = 2
							newSection.ZIndex = 100 + newSection.ZIndex
							colorPickerButton.BorderColor3 = library.colors.main
							colored_colorPickerButton_BorderColor3[3] = "main"
							UpdateColorPicker()
							sectionFunctions:Update(260)
							-- the tray grows below the row, then the page glides so the whole tray is on screen
							task.spawn(function()
								pcall(function()
									local sf = newSection.Parent
									if not (sf and sf:IsA("ScrollingFrame")) then
										return
									end
									local t0 = os.clock()
									while colorPickerEnabled and colorPickerHolderFrame.Parent and sf.Parent do
										local elapsed = os.clock() - t0
										local topGap = colorPickerHolderFrame.AbsolutePosition.Y - sf.AbsolutePosition.Y
										local botGap = (sf.AbsolutePosition.Y + sf.AbsoluteSize.Y) - (colorPickerHolderFrame.AbsolutePosition.Y + colorPickerHolderFrame.AbsoluteSize.Y)
										local need = 0
										if (colorPickerHolderFrame.AbsoluteSize.Y + 12) > sf.AbsoluteSize.Y then
											need = topGap - 6
										elseif botGap < 6 then
											need = 6 - botGap
										elseif topGap < 6 then
											need = topGap - 6
										end
										if (elapsed > 0.9) or ((math.abs(need) < 1) and (elapsed > 0.3)) then
											break
										end
										if math.abs(need) >= 1 then
											local step = need * 0.2
											if math.abs(step) < 1 then
												step = (need > 0 and 1) or -1
											end
											sf.CanvasPosition = Vector2.new(0, math.max(0, sf.CanvasPosition.Y + (step / guiScale())))
										end
										task.wait()
									end
								end)
							end)
						else
							for _, v in next, colorpickerconflicts do
								v.Visible = true
							end
							submenuOpen = nil
							newColorPicker.ZIndex = 0
							newSection.ZIndex = newSection.ZIndex - 100
							colorPickerButton.BorderColor3 = library.colors.elementBorder
							colored_colorPickerButton_BorderColor3[3] = "elementBorder"
							sectionFunctions:Update()
						end
					end
				end)
				colorPickerHolderFrame.Name = "colorPickerHolderFrame"
				colorPickerHolderFrame.Parent = newColorPicker
				colorPickerHolderFrame.Active = true
				colorPickerHolderFrame.BackgroundColor3 = library.colors.topGradient
				colored[1 + #colored] = {colorPickerHolderFrame, "BackgroundColor3", "topGradient"}
				colorPickerHolderFrame.BorderColor3 = library.colors.elementBorder
				colored[1 + #colored] = {colorPickerHolderFrame, "BorderColor3", "elementBorder"}
				colorPickerHolderFrame.Selectable = true
				colorPickerHolderFrame.Position = UDim2.fromScale(0.025, 1.012)
				colorPickerHolderFrame.Size = UDim2.fromOffset(206, 250)
				colorPickerHolderFrame.Visible = false
				colorPickerHolderFrame.Image = "rbxassetid://2454009026"
				colorPickerHolderFrame.ImageColor3 = library.colors.bottomGradient
				colored[1 + #colored] = {colorPickerHolderFrame, "ImageColor3", "bottomGradient"}
				colorPickerHolderInner.Name = "colorPickerHolderInner"
				colorPickerHolderInner.Parent = colorPickerHolderFrame
				colorPickerHolderInner.Active = true
				colorPickerHolderInner.AnchorPoint = Vector2Half
				colorPickerHolderInner.BackgroundColor3 = library.colors.topGradient
				colored[1 + #colored] = {colorPickerHolderInner, "BackgroundColor3", "topGradient"}
				colorPickerHolderInner.BorderColor3 = library.colors.elementBorder
				colored[1 + #colored] = {colorPickerHolderInner, "BorderColor3", "elementBorder"}
				colorPickerHolderInner.Position = UDim2ScaleHalf
				colorPickerHolderInner.Selectable = true
				colorPickerHolderInner.Size = UDim2.new(1, -4, 1, -4)
				colorPickerHolderInner.Image = "rbxassetid://2454009026"
				colorPickerHolderInner.ImageColor3 = library.colors.bottomGradient
				colored[1 + #colored] = {colorPickerHolderInner, "ImageColor3", "bottomGradient"}
				color.Name = "color"
				color.Parent = colorPickerHolderInner
				color.BackgroundColor3 = startingColor
				color.BorderSizePixel = 0
				color.Position = UDim2.fromOffset(5, 5)
				color.Size = UDim2.new(1, -10, 0, 192)
				color.Image = "rbxassetid://4155801252"
				selectorColor.Name = "selectorColor"
				selectorColor.Parent = color
				selectorColor.AnchorPoint = Vector2Half
				selectorColor.BackgroundColor3 = Color3.fromRGB(144, 144, 144)
				selectorColor.BorderColor3 = Color3.fromRGB(69, 65, 70)
				selectorColor.Position = UDim2.new(startingColor and select(3, Color3.toHSV(startingColor)))
				selectorColor.Size = UDim2.fromOffset(4, 4)
				hue.Name = "hue"
				hue.Parent = colorPickerHolderInner
				hue.BackgroundColor3 = WhiteColor3
				hue.BorderSizePixel = 0
				hue.Position = UDim2.fromOffset(5, 202)
				hue.Size = UDim2.new(1, -10, 0, 14)
				hue.Image = "rbxassetid://3570695787"
				hue.ScaleType = Enum.ScaleType.Slice
				hue.SliceScale = 0.01
				hueGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 4)), ColorSequenceKeypoint.new(0.17, Color3.fromRGB(235, 7, 255)), ColorSequenceKeypoint.new(0.33, Color3:fromRGB(9, 189)), ColorSequenceKeypoint.new(0.5, Color3:fromRGB(193, 196)), ColorSequenceKeypoint.new(0.66, Color3:new(1)), ColorSequenceKeypoint.new(0.84, Color3.fromRGB(255, 247)), ColorSequenceKeypoint.new(1, Color3.new(1))})
				hueGradient.Name = "hueGradient"
				hueGradient.Parent = hue
				selectorHue.Name = "selectorHue"
				selectorHue.Parent = hue
				selectorHue.BackgroundColor3 = Color3:fromRGB(125, 255)
				selectorHue.BackgroundTransparency = 0.2
				selectorHue.BorderColor3 = Color3:fromRGB(84, 91)
				selectorHue.Position = UDim2.new(1 - (Color3.toHSV(startingColor)))
				selectorHue.Size = UDim2:new(2, 1)
				hexInput.Name = "hexInput"
				hexInput.Parent = colorPickerHolderInner
				hexInput.Active = true
				hexInput.BackgroundColor3 = library.colors.topGradient
				colored[1 + #colored] = {hexInput, "BackgroundColor3", "topGradient"}
				hexInput.BorderColor3 = library.colors.elementBorder
				colored[1 + #colored] = {hexInput, "BorderColor3", "elementBorder"}
				hexInput.Position = UDim2.fromOffset(5, 223)
				hexInput.Selectable = true
				hexInput.Size = UDim2.fromOffset(150, 18)
				hexInput.Image = "rbxassetid://2454009026"
				hexInput.ImageColor3 = library.colors.bottomGradient
				colored[1 + #colored] = {hexInput, "ImageColor3", "bottomGradient"}
				hexInputInner.Name = "hexInputInner"
				hexInputInner.Parent = hexInput
				hexInputInner.Active = true
				hexInputInner.AnchorPoint = Vector2Half
				hexInputInner.BackgroundColor3 = library.colors.topGradient
				colored[1 + #colored] = {hexInputInner, "BackgroundColor3", "topGradient"}
				hexInputInner.BorderColor3 = library.colors.elementBorder
				colored[1 + #colored] = {hexInputInner, "BorderColor3", "elementBorder"}
				hexInputInner.Position = UDim2ScaleHalf
				hexInputInner.Selectable = true
				hexInputInner.Size = UDim2.new(1, -4, 1, -4)
				hexInputInner.Image = "rbxassetid://2454009026"
				hexInputInner.ImageColor3 = library.colors.bottomGradient
				colored[1 + #colored] = {hexInputInner, "ImageColor3", "bottomGradient"}
				hexInputBox.Name = "hexInputBox"
				hexInputBox.Parent = hexInput
				hexInputBox.BackgroundColor3 = WhiteColor3
				hexInputBox.BackgroundTransparency = 1
				hexInputBox.Size = UDim2ScaleOne
				hexInputBox.ZIndex = 5
				hexInputBox.Font = Enum.Font.GothamBold
				hexInputBox.PlaceholderText = "Hex Input"
				hexInputBox.Text = Color3ToHex(startingColor)
				hexInputBox.TextColor3 = library.colors.elementText
				colored[1 + #colored] = {hexInputBox, "TextColor3", "elementText"}
				hexInputBox.TextSize = 12
				hexInputBox.ClearTextOnFocus = false
				randomColor.Name = "randomColor"
				randomColor.Parent = colorPickerHolderInner
				randomColor.Active = true
				randomColor.BackgroundColor3 = library.colors.topGradient
				colored[1 + #colored] = {randomColor, "BackgroundColor3", "topGradient"}
				randomColor.BorderColor3 = library.colors.elementBorder
				colored[1 + #colored] = {randomColor, "BorderColor3", "elementBorder"}
				randomColor.Position = UDim2.fromOffset(158, 223)
				randomColor.Selectable = true
				randomColor.Size = UDim2.fromOffset(18, 18)
				randomColor.Image = "rbxassetid://2454009026"
				randomColor.ImageColor3 = library.colors.bottomGradient
				colored[1 + #colored] = {randomColor, "ImageColor3", "bottomGradient"}
				randomColorInner.Name = "randomColorInner"
				randomColorInner.Parent = randomColor
				randomColorInner.Active = true
				randomColorInner.AnchorPoint = Vector2Half
				randomColorInner.BackgroundColor3 = library.colors.topGradient
				colored[1 + #colored] = {randomColorInner, "BackgroundColor3", "topGradient"}
				randomColorInner.BorderColor3 = library.colors.elementBorder
				colored[1 + #colored] = {randomColorInner, "BorderColor3", "elementBorder"}
				randomColorInner.Position = UDim2ScaleHalf
				randomColorInner.Selectable = true
				randomColorInner.Size = UDim2.new(1, -4, 1, -4)
				randomColorInner.Image = "rbxassetid://2454009026"
				randomColorInner.ImageColor3 = library.colors.bottomGradient
				colored[1 + #colored] = {randomColorInner, "ImageColor3", "bottomGradient"}
				randomColorButton.Name = "randomColorButton"
				randomColorButton.Parent = randomColor
				randomColorButton.BackgroundColor3 = WhiteColor3
				randomColorButton.BackgroundTransparency = 1
				randomColorButton.Size = UDim2ScaleOne
				randomColorButton.ZIndex = 5
				randomColorButton.Image = "rbxassetid://7484765651"
				rainbow.Name = "rainbow"
				rainbow.Parent = colorPickerHolderInner
				rainbow.Active = true
				rainbow.BackgroundColor3 = library.colors.topGradient
				colored[1 + #colored] = {rainbow, "BackgroundColor3", "topGradient"}
				rainbow.BorderColor3 = library.colors.elementBorder
				colored[1 + #colored] = {rainbow, "BorderColor3", "elementBorder"}
				rainbow.Position = UDim2.fromOffset(158 + 18 + 4, 223)
				rainbow.Selectable = true
				rainbow.Size = UDim2.fromOffset(18, 18)
				rainbow.Image = "rbxassetid://2454009026"
				rainbow.ImageColor3 = library.colors.bottomGradient
				colored[1 + #colored] = {rainbow, "ImageColor3", "bottomGradient"}
				rainbowInner.Name = "rainbowInner"
				rainbowInner.Parent = randomColor
				rainbowInner.Active = true
				rainbowInner.AnchorPoint = Vector2Half
				rainbowInner.BackgroundColor3 = library.colors.topGradient
				colored[1 + #colored] = {rainbowInner, "BackgroundColor3", "topGradient"}
				rainbowInner.BorderColor3 = library.colors.elementBorder
				colored[1 + #colored] = {rainbowInner, "BorderColor3", "elementBorder"}
				rainbowInner.Position = UDim2ScaleHalf
				rainbowInner.Selectable = true
				rainbowInner.Size = UDim2.new(1, -4, 1, -4)
				rainbowInner.Image = "rbxassetid://2454009026"
				rainbowInner.ImageColor3 = library.colors.bottomGradient
				colored[1 + #colored] = {rainbowInner, "ImageColor3", "bottomGradient"}
				rainbowButton.Name = "rainbowButton"
				rainbowButton.Parent = rainbow
				rainbowButton.BackgroundColor3 = WhiteColor3
				rainbowButton.BackgroundTransparency = 1
				rainbowButton.Size = UDim2ScaleOne
				rainbowButton.ZIndex = 5
				rainbowButton.Image = "rbxassetid://7484772919"
				local indexwith = (designers and "rainbows") or "rainbowsg"
				local function setrainbow(t, rainbowColorMod)
					if nil == rainbowColorMod and t ~= nil then
						rainbowColorMod = t
					end
					if rainbowColorMod == nil or type(rainbowColorMod) ~= "boolean" then
						rainbowColorMode = not rainbowColorMode
					else
						rainbowColorMode = rainbowColorMod
					end
					if colorInput then
						colorInput = (colorInput:Disconnect() and nil) or nil
					end
					if hueInput then
						hueInput = (hueInput:Disconnect() and nil) or nil
					end
					pcall(function()
						if destroyrainbows and library.rainbows <= 0 then
							destroyrainbows = nil
						end
						if destroyrainbowsg and library.rainbowsg <= 0 then
							destroyrainbowsg = nil
						end
					end)
					if rainbowColorMode then
						pcall(function()
							if not library.rainbowflags[flagName] then
								library[indexwith] = 1 + library[indexwith]
							end
							library.rainbowflags[flagName] = true
							oldImageColor = colorPickerInner.ImageColor3
							oldBackgroundColor = colorPickerInner.BackgroundColor3
							oldColor = color.BackgroundColor3
							pcall(function()
								local common_float = 1 / 255
								while wait_check() and rainbowColorMode and ((options.Value == "rainbow") or (not (designers or destroyrainbowsg) or (designers and not destroyrainbows))) do
									rainbowColorValue = common_float + rainbowColorValue
									if rainbowColorValue > 1 then
										rainbowColorValue = 0
									end
									colorH = rainbowColorValue
									UpdateColorPicker(Color3.fromHSV(rainbowColorValue, 1, 1), true)
								end
							end)
						end)
						pcall(function()
							rainbowColorMode = nil
							if __runscript then
								if library.rainbowflags[flagName] then
									library[indexwith] = library[indexwith] - 1
								end
								library.rainbowflags[flagName] = nil
							end
						end)
					end
					UpdateColorPicker(library_flags[flagName])
				end
				library.signals[1 + #library.signals] = randomColorButton.MouseButton1Click:Connect(function()
					if rainbowColorMode then
						setrainbow(false)
					end
					UpdateColorPicker(Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255)))
				end)
				library.signals[1 + #library.signals] = rainbowButton.MouseButton1Click:Connect(setrainbow)
				sectionFunctions:Update()
				library.signals[1 + #library.signals] = newColorPicker.MouseEnter:Connect(function()
					tweenService:Create(colorPicker, TweenInfo.new(0.25, library.configuration.easingStyle, library.configuration.easingDirection), {
						BackgroundColor3 = darkenColor(library.colors.main, 1.5),
						ImageColor3 = darkenColor(library.colors.main, 2.5)
					}):Play()
					colored_colorPicker_BackgroundColor3[3] = "main"
					colored_colorPicker_BackgroundColor3[4] = 1.5
					colored_colorPicker_ImageColor3[3] = "main"
					colored_colorPicker_ImageColor3[4] = 2.5
				end)
				library.signals[1 + #library.signals] = newColorPicker.MouseLeave:Connect(function()
					if colorPickerEnabled then
					else
						tweenService:Create(colorPicker, TweenInfo.new(0.25, library.configuration.easingStyle, library.configuration.easingDirection), {
							BackgroundColor3 = library.colors.topGradient,
							ImageColor3 = library.colors.bottomGradient
						}):Play()
						colored_colorPicker_BackgroundColor3[3] = "topGradient"
						colored_colorPicker_BackgroundColor3[4] = nil
						colored_colorPicker_ImageColor3[3] = "bottomGradient"
						colored_colorPicker_ImageColor3[4] = nil
					end
				end)
				library.signals[1 + #library.signals] = hexInputBox.FocusLost:Connect(function()
					if #hexInputBox.Text > 5 then
						local last_vv = library_flags[flagName]
						local not_bloxed, clr = pcall(Color3FromHex, hexInputBox.Text)
						UpdateColorPicker((not_bloxed and clr) or last_vv)
					end
				end)
				colorH = 1 - (math.clamp(selectorHue.AbsolutePosition.X - hue.AbsolutePosition.X, 0, hue.AbsoluteSize.X) / hue.AbsoluteSize.X)
				colorS = (math.clamp(selectorColor.AbsolutePosition.X - color.AbsolutePosition.X, 0, color.AbsoluteSize.X) / color.AbsoluteSize.X)
				colorV = 1 - (math.clamp(selectorColor.AbsolutePosition.Y - color.AbsolutePosition.Y, 0, color.AbsoluteSize.Y) / color.AbsoluteSize.Y)
				local function stopColorDrag(input)
					if not isPress(input) then
						return
					end
					local was = false
					if colorInput then
						colorInput:Disconnect()
						colorInput = nil
						was = true
					end
					if hueInput then
						hueInput:Disconnect()
						hueInput = nil
						was = true
					end
					if was then
						isDraggingSomething = false
						lockScrolling(newColorPicker, false)
					end
				end
				library.signals[1 + #library.signals] = color.InputBegan:Connect(function(input)
					if isPress(input) then
						if colorInput then
							colorInput:Disconnect()
						end
						isDraggingSomething = true
						lockScrolling(newColorPicker, true)
						colorInput = runService.RenderStepped:Connect(function()
							local pointer = getPointerPos(input)
							local colorX = (math.clamp(pointer.X - color.AbsolutePosition.X, 0, color.AbsoluteSize.X) / color.AbsoluteSize.X)
							local colorY = (math.clamp(pointer.Y - color.AbsolutePosition.Y, 0, color.AbsoluteSize.Y) / color.AbsoluteSize.Y)
							selectorColor.Position = UDim2.fromScale(colorX, colorY)
							colorS = colorX
							colorV = 1 - colorY
							UpdateColorPicker()
						end)
						library.signals[1 + #library.signals] = colorInput
					end
				end)
				library.signals[1 + #library.signals] = hue.InputBegan:Connect(function(input)
					if isPress(input) then
						if hueInput then
							hueInput:Disconnect()
						end
						isDraggingSomething = true
						lockScrolling(newColorPicker, true)
						hueInput = runService.RenderStepped:Connect(function()
							local pointer = getPointerPos(input)
							local hueX = math.clamp(pointer.X - hue.AbsolutePosition.X, 0, hue.AbsoluteSize.X) / hue.AbsoluteSize.X
							selectorHue.Position = UDim2.new(hueX)
							colorH = 1 - hueX
							UpdateColorPicker()
						end)
						library.signals[1 + #library.signals] = hueInput
					end
				end)
				library.signals[1 + #library.signals] = color.InputEnded:Connect(stopColorDrag)
				library.signals[1 + #library.signals] = hue.InputEnded:Connect(stopColorDrag)
				library.signals[1 + #library.signals] = userInputService.InputEnded:Connect(stopColorDrag)
				if rainbowColorMode then
					spawn(function()
						rainbowColorMode = nil
						setrainbow(true)
					end)
				end
				local function Set(t, clr)
					if clr == nil and t ~= nil then
						clr = t
					end
					if clr == "rainbow" then
						if not rainbowColorMode then
							task.spawn(setrainbow, true)
						end
						return
					elseif clr == "random" then
						clr = Color3.new(math.random(), math.random(), math.random())
					elseif type(clr) == "string" and tonumber(clr, 16) then
						clr = Color3FromHex(clr)
					end
					task.spawn(setrainbow, false)
					local last_v = library_flags[flagName]
					library_flags[flagName] = clr
					if options.Location then
						options.Location[options.LocationFlag or flagName] = clr
					end
					color.BackgroundColor3 = clr
					selectorColor.Position = UDim2.new(clr and select(3, Color3.toHSV(clr)))
					selectorHue.Position = UDim2.new(1 - (Color3.toHSV(clr)))
					colorPickerInner.BackgroundColor3 = darkenColor(clr, 1.5)
					colorPickerInner.ImageColor3 = darkenColor(clr, 2.5)
					hexInputBox.Text = Color3ToHex(clr)
					colorH, colorS, colorV = Color3.toHSV(clr)
					if callback and __runscript and ((last_v ~= clr) or options.AllowDuplicateCalls) then
						task.spawn(callback, clr, last_v)
					end
					return clr
				end
				if presetColor ~= nil then
					Set(presetColor)
				else
					library_flags[flagName] = startingColor
					if options.Location then
						options.Location[options.LocationFlag or flagName] = startingColor
					end
				end
				local default = options.Value or startingColor or library_flags[flagName]
				local function update()
					colorPickerName, callback = options.Name or colorPickerName, options.Callback
					local clr = library_flags[flagName]
					color.BackgroundColor3 = clr
					selectorColor.Position = UDim2.new(clr and select(3, Color3.toHSV(clr)))
					selectorHue.Position = UDim2.new(1 - (Color3.toHSV(clr)))
					colorPickerInner.BackgroundColor3 = darkenColor(clr, 1.5)
					colorPickerInner.ImageColor3 = darkenColor(clr, 2.5)
					hexInputBox.Text = Color3ToHex(clr)
					colorPickerHeadline.Text = colorPickerName or "???"
					return clr
				end
				local objectdata = {
					Options = options,
					Name = flagName,
					Flag = flagName,
					Type = "Colorpicker",
					Default = default,
					Parent = sectionFunctions,
					Instance = newColorPicker,
					SetRainbow = setrainbow,
					Get = function()
						return library_flags[flagName]
					end,
					GetRainbow = function()
						return rainbowColorMode
					end,
					Set = Set,
					Remove = function()
						if newColorPicker then
							newColorPicker.Parent = nil
							sectionFunctions:Update()
						end
					end,
					RawSet = function(t, clr)
						if clr == nil and t ~= nil then
							clr = t
						end
						if clr == "rainbow" then
							if not rainbowColorMode then
								task.spawn(setrainbow, true)
							end
							return clr
						elseif clr == "random" then
							clr = Color3.new(math.random(), math.random(), math.random())
						elseif clr and (type(clr) == "string") and tonumber(clr, 16) then
							clr = Color3FromHex(clr)
						end
						task.spawn(setrainbow, false)
						library_flags[flagName] = clr
						if options.Location then
							options.Location[options.LocationFlag or flagName] = clr
						end
						return clr
					end,
					Update = update,
					Reset = function()
						return Set(nil, default)
					end
				}
				tabFunctions.Flags[flagName], sectionFunctions.Flags[flagName], elements[flagName] = objectdata, objectdata, objectdata
				return objectdata
			end
			sectionFunctions.AddColorPicker = sectionFunctions.AddColorpicker
			sectionFunctions.NewColorpicker = sectionFunctions.AddColorpicker
			sectionFunctions.NewColorPicker = sectionFunctions.AddColorpicker
			sectionFunctions.CreateColorPicker = sectionFunctions.AddColorpicker
			sectionFunctions.CreateColorpicker = sectionFunctions.AddColorpicker
			sectionFunctions.ColorPicker = sectionFunctions.AddColorpicker
			sectionFunctions.Colorpicker = sectionFunctions.AddColorpicker
			sectionFunctions.Cp = sectionFunctions.AddColorpicker
			sectionFunctions.CP = sectionFunctions.AddColorpicker
			return sectionFunctions
		end
		tabFunctions.AddSection = tabFunctions.CreateSection
		tabFunctions.NewSection = tabFunctions.CreateSection
		tabFunctions.Section = tabFunctions.CreateSection
		tabFunctions.Sec = tabFunctions.CreateSection
		tabFunctions.S = tabFunctions.CreateSection
		function tabFunctions:UpdateAll()
			local target = self or tabFunctions
			if target and (type(target) == "table") and target.Flags then
				for _, e in next, target.Flags do
					if e and (type(e) == "table") and e.Update then
						pcall(e.Update)
					end
				end
			end
		end
		if LastTabWindowSlideThingyOfDeath then
		else
			LastTabWindowSlideThingyOfDeath = newTab
		end
		return tabFunctions
	end
	windowFunctions.AddTab = windowFunctions.CreateTab
	windowFunctions.NewTab = windowFunctions.CreateTab
	windowFunctions.Tab = windowFunctions.CreateTab
	windowFunctions.T = windowFunctions.CreateTab
	function windowFunctions:CreateDesigner(options, ...)
		assert(shared.bypasstablimit or (library.Designer == nil), "Designer already exists")
		options = (options and type(options) == "string" and resolvevararg("Tab", options, ...)) or options
		options = options or {}
		options.Image = 132029940467197 -- QuickX Hub (locked: any Image passed in is ignored)
		options.LastTab = true
		local designer = windowFunctions:CreateTab(options)
		-- sections are listed top to bottom in the order they are created
		local gamesection = designer:CreateSection({
			Name = "Game",
			Side = "Left"
		})
		local pcsection = designer:CreateSection({
			Name = "PC Tools",
			Side = "Right"
		})
		local serversection = designer:CreateSection({
			Name = "Server",
			Side = "Right"
		})
		do
			local Players = game:GetService("Players")
			local RunService = game:GetService("RunService")
			local TeleportService = game:GetService("TeleportService")
			local HttpService = game:GetService("HttpService")
			local LocalPlayer = Players.LocalPlayer
			local perf = {
				FPS = 60
			}
			do
				local frames, last = 0, os.clock()
				library.signals[1 + #library.signals] = RunService.Heartbeat:Connect(function()
					frames = frames + 1
					local now = os.clock()
					if (now - last) >= 0.5 then
						perf.FPS = frames / (now - last)
						frames, last = 0, now
					end
				end)
			end
			local function getPing()
				local ok, v = pcall(function()
					return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
				end)
				return (ok and v and math.floor(v + 0.5)) or nil
			end
			local function notify(text)
				pcall(function()
					library:Notify({
						Text = text,
						Time = 4
					})
				end)
			end
			local function copy(text, what)
				local fn = setclipboard or toclipboard or (syn and syn.write_clipboard) or shared.clipboard_func
				if fn then
					pcall(fn, tostring(text))
					notify((what or "Text") .. " copied")
				else
					notify("Clipboard is not supported by this executor")
				end
			end
			-- info about the map we are playing (filled in the background, the card updates itself)
			local gameInfo = {
				Name = "Loading...",
				Creator = "",
				MaxPlayers = Players.MaxPlayers
			}
			local listeners = {}
			local function pushInfo()
				for _, fn in ipairs(listeners) do
					pcall(fn, gameInfo)
				end
			end
			function gameInfo.Listen(fn)
				listeners[1 + #listeners] = fn
				pcall(fn, gameInfo)
			end
			task.spawn(function()
				-- let the window finish its first layout before any network call (HttpGet can freeze the game for a moment on some executors)
				task.wait(2)
				pcall(function()
					local info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
					if info then
						gameInfo.Name = info.Name or gameInfo.Name
						gameInfo.Creator = (info.Creator and info.Creator.Name) or ""
						gameInfo.Created = info.Created
						gameInfo.Updated = info.Updated
					end
				end)
				pushInfo()
				if game.GameId ~= 0 then
					pcall(function()
						local data = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games?universeIds=" .. tostring(game.GameId)))
						local g = data and data.data and data.data[1]
						if g then
							gameInfo.Name = g.name or gameInfo.Name
							gameInfo.Visits = g.visits
							gameInfo.Favorites = g.favoritedCount
							gameInfo.MaxPlayers = g.maxPlayers or gameInfo.MaxPlayers
							gameInfo.Created = g.created or gameInfo.Created
							gameInfo.Updated = g.updated or gameInfo.Updated
							if g.creator and g.creator.name then
								gameInfo.Creator = g.creator.name
							end
						end
					end)
					pushInfo()
					-- first screenshot of the map = cover image
					pcall(function()
						local media = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v2/games/" .. tostring(game.GameId) .. "/media"))
						for _, item in ipairs((media and media.data) or {}) do
							if item.imageId and ((item.assetType == "Image") or (item.assetTypeId == 1)) then
								gameInfo.CoverId = item.imageId
								break
							end
						end
					end)
					pushInfo()
				end
			end)
			-- Game section: card + ids
			gamesection:AddGameCard({
				Info = gameInfo,
				Perf = perf,
				GetPing = getPing,
				Badge = "Premium"
			})
			gamesection:AddLabel({
				Text = "Universe ID: " .. tostring(game.GameId)
			})
			gamesection:AddLabel({
				Text = "Place ID: " .. tostring(game.PlaceId)
			})
			local jobShort = tostring(game.JobId or "")
			gamesection:AddLabel({
				Text = "Server ID: " .. ((jobShort ~= "" and (string.sub(jobShort, 1, 18) .. "...")) or "N/A")
			})
			local updatedLabel = gamesection:AddLabel({
				Text = "Updated: ..."
			})
			gameInfo.Listen(function(i)
				if i.Updated then
					updatedLabel.Set("Updated: " .. string.sub(tostring(i.Updated), 1, 10))
				end
			end)
			gamesection:AddButton({{
				Name = "Copy Place ID",
				Callback = function()
					copy(game.PlaceId, "Place ID")
				end
			}, {
				Name = "Copy Job ID",
				Callback = function()
					copy(game.JobId, "Job ID")
				end
			}})
			gamesection:AddButton({{
				Name = "Copy Join Script",
				Callback = function()
					copy(string.format("game:GetService(\"TeleportService\"):TeleportToPlaceInstance(%d, \"%s\", game:GetService(\"Players\").LocalPlayer)", game.PlaceId, tostring(game.JobId)), "Join script")
				end
			}, {
				Name = "Copy Game Link",
				Callback = function()
					copy("https://www.roblox.com/games/" .. tostring(game.PlaceId), "Game link")
				end
			}})
			-- PC Tools
			local execName = "Unknown"
			pcall(function()
				if identifyexecutor then
					execName = tostring((identifyexecutor()))
				end
			end)
			pcsection:AddLabel({
				Text = "Executor: " .. execName
			})
			local fpsOn, fpsValue = false, 144
			local function applyFps()
				if setfpscap then
					pcall(setfpscap, (fpsOn and fpsValue) or 60)
				end
			end
			pcsection:AddToggle({
				Name = "FPS Unlocker",
				Flag = "__PC.FPSUnlock",
				Value = false,
				UnloadValue = false,
				Callback = function(state)
					local was = fpsOn
					fpsOn = (state and true) or false
					if fpsOn or was then
						if not setfpscap then
							notify("setfpscap is not supported by this executor")
						end
						applyFps()
					end
				end
			})
			pcsection:AddSlider({
				Name = "FPS Cap",
				Flag = "__PC.FPSCap",
				Value = 144,
				Min = 30,
				Max = 360,
				Format = "FPS Cap: %s",
				Textbox = true,
				Callback = function(v)
					fpsValue = tonumber(v) or 144
					if fpsOn then
						applyFps()
					end
				end
			})
			local afkConn
			pcsection:AddToggle({
				Name = "Anti AFK",
				Flag = "__PC.AntiAFK",
				Value = false,
				UnloadValue = false,
				Callback = function(state)
					if state then
						if not afkConn then
							afkConn = LocalPlayer.Idled:Connect(function()
								pcall(function()
									local vu = game:GetService("VirtualUser")
									vu:CaptureController()
									vu:ClickButton2(Vector2.new())
								end)
							end)
							library.signals[1 + #library.signals] = afkConn
						end
					elseif afkConn then
						afkConn:Disconnect()
						afkConn = nil
					end
				end
			})
			local rejoinConn, lastRejoin = nil, 0
			pcsection:AddToggle({
				Name = "Auto Rejoin On Kick",
				Flag = "__PC.AutoRejoin",
				Value = false,
				UnloadValue = false,
				Callback = function(state)
					if state then
						if not rejoinConn then
							rejoinConn = game:GetService("GuiService").ErrorMessageChanged:Connect(function(msg)
								if msg and (msg ~= "") and ((os.clock() - lastRejoin) > 15) then
									lastRejoin = os.clock()
									notify("Disconnected, rejoining...")
									task.wait(2)
									pcall(function()
										TeleportService:Teleport(game.PlaceId, LocalPlayer)
									end)
								end
							end)
							library.signals[1 + #library.signals] = rejoinConn
						end
					elseif rejoinConn then
						rejoinConn:Disconnect()
						rejoinConn = nil
					end
				end
			})
			pcsection:AddToggle({
				Name = "Disable 3D Rendering",
				Flag = "__PC.NoRender",
				Value = false,
				UnloadValue = false,
				Callback = function(state)
					pcall(function()
						RunService:Set3dRenderingEnabled(not state)
					end)
				end
			})
			-- small draggable FPS / ping / players overlay
			local hud, hudText
			local function ensureHud()
				if hud then
					return hud
				end
				hud = Instance_new("Frame")
				hud.Name = "statsHud"
				hud.Parent = pepsiLibrary
				hud.AnchorPoint = Vector2.new(1, 0)
				hud.Position = UDim2.new(1, -16, 0, 16)
				hud.Size = UDim2.fromOffset(250, 28)
				hud.BackgroundColor3 = library.colors.background
				colored[1 + #colored] = {hud, "BackgroundColor3", "background"}
				hud.BackgroundTransparency = 0.1
				hud.BorderSizePixel = 0
				hud.ZIndex = 40
				local hudCorner = Instance_new("UICorner")
				hudCorner.CornerRadius = UDim.new(0, 8)
				hudCorner.Parent = hud
				local hudStroke = Instance_new("UIStroke")
				hudStroke.Thickness = 1.2
				hudStroke.Color = library.colors.main
				colored[1 + #colored] = {hudStroke, "Color", "main"}
				hudStroke.Parent = hud
				hudText = Instance_new("TextLabel")
				hudText.BackgroundTransparency = 1
				hudText.Position = UDim2.fromOffset(8, 0)
				hudText.Size = UDim2.new(1, -16, 1, 0)
				hudText.Font = Enum.Font.GothamBold
				hudText.TextSize = 12
				hudText.TextColor3 = library.colors.elementText
				colored[1 + #colored] = {hudText, "TextColor3", "elementText"}
				hudText.ZIndex = 41
				hudText.Parent = hud
				makeDraggable(hud, hud)
				task.spawn(function()
					while hud and hud:IsDescendantOf(game) do
						if hud.Visible then
							local ping = getPing()
							hudText.Text = string.format("FPS %d   |   PING %s   |   PLAYERS %d/%d", math.floor(perf.FPS), (ping and (tostring(ping) .. "ms")) or "--", #Players:GetPlayers(), gameInfo.MaxPlayers or Players.MaxPlayers)
						end
						task.wait(0.5)
					end
				end)
				return hud
			end
			pcsection:AddToggle({
				Name = "Stats Overlay (FPS / Ping)",
				Flag = "__PC.StatsHud",
				Value = false,
				UnloadValue = false,
				Callback = function(state)
					if state or hud then
						ensureHud().Visible = (state and true) or false
					end
				end
			})
			pcsection:AddToggle({
				Name = "Resizable Window",
				Flag = "__PC.Resizable",
				Value = true,
				Callback = function(state)
					library.configuration.resizable = (state and true) or false
					if library.RefreshLayout then
						library.RefreshLayout()
					end
				end
			})
			pcsection:AddButton({{
				Name = "Reset Window Size / Position",
				Callback = function()
					if library.ResetWindow then
						library.ResetWindow()
					end
				end
			}})
			pcsection:AddKeybind({
				Name = "Panic Key (Unload UI)",
				Flag = "__PC.PanicKey",
				Pressed = function()
					library.unload()
				end
			})
			-- Server tools
			local jobInput = ""
			serversection:AddButton({{
				Name = "Rejoin",
				Callback = function()
					notify("Rejoining...")
					pcall(function()
						if #Players:GetPlayers() <= 1 then
							TeleportService:Teleport(game.PlaceId, LocalPlayer)
						else
							TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
						end
					end)
				end
			}, {
				Name = "Server Hop",
				Callback = function()
					notify("Searching for a server...")
					task.spawn(function()
						local ok = pcall(function()
							local data = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/Public?sortOrder=Asc&limit=100"))
							local pool = {}
							for _, s in ipairs((data and data.data) or {}) do
								if (s.id ~= game.JobId) and (s.playing or 0) < (s.maxPlayers or 0) then
									pool[1 + #pool] = s
								end
							end
							if #pool == 0 then
								notify("No other server found")
								return
							end
							TeleportService:TeleportToPlaceInstance(game.PlaceId, pool[math.random(1, #pool)].id, LocalPlayer)
						end)
						if not ok then
							notify("Server hop failed")
						end
					end)
				end
			}})
			serversection:AddButton({{
				Name = "Join Smallest Server",
				Callback = function()
					notify("Searching for a small server...")
					task.spawn(function()
						local ok = pcall(function()
							local data = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/Public?sortOrder=Asc&limit=100"))
							local best
							for _, s in ipairs((data and data.data) or {}) do
								if (s.id ~= game.JobId) and (s.playing or 0) < (s.maxPlayers or 0) then
									if (not best) or (s.playing < best.playing) then
										best = s
									end
								end
							end
							if not best then
								notify("No other server found")
								return
							end
							TeleportService:TeleportToPlaceInstance(game.PlaceId, best.id, LocalPlayer)
						end)
						if not ok then
							notify("Could not search servers")
						end
					end)
				end
			}})
			serversection:AddTextbox({
				Name = "Job ID",
				Flag = "__PC.JobIdInput",
				Value = "",
				Placeholder = "Paste a Job ID",
				Callback = function(text)
					jobInput = tostring(text or "")
				end
			})
			serversection:AddButton({{
				Name = "Join Job ID",
				Callback = function()
					local id = string.gsub(jobInput, "%s", "")
					if #id < 8 then
						notify("Enter a valid Job ID first")
						return
					end
					notify("Joining server...")
					pcall(function()
						TeleportService:TeleportToPlaceInstance(game.PlaceId, id, LocalPlayer)
					end)
				end
			}})
		end
		local colorsection = designer:CreateSection({
			Name = "Colors"
		})
		local backgroundsection = designer:CreateSection({
			Name = "Background",
			Side = "right"
		})
		local detailssection = designer:CreateSection({
			Name = "More Info"
		})
		local filessection = designer:CreateSection({
			Name = "Profiles",
			Side = "right"
		})
		local settingssection = designer:CreateSection({
			Name = "Settings",
			Side = "right"
		})
		local designerelements = {}
		library.designerelements = designerelements
		for _, v in next, {{"Main", "main"}, {"Background", "background"}, {"Outer Border", "outerBorder"}, {"Inner Border", "innerBorder"}, {"Top Gradient", "topGradient"}, {"Bottom Gradient", "bottomGradient"}, {"Section Background", "sectionBackground"}, {"Section", "section"}, {"Element Text", "elementText"}, {"Other Element Text", "otherElementText"}, {"Tab Text", "tabText"}, {"Element Border", "elementBorder"}, {"Selected Option", "selectedOption"}, {"Unselected Option", "unselectedOption"}, {"Hovered Option Top", "hoveredOptionTop"}, {"Unhovered Option Top", "unhoveredOptionTop"}, {"Hovered Option Bottom", "hoveredOptionBottom"}, {"Unhovered Option Bottom", "unhoveredOptionBottom"}} do
			local nam, codename = v[1], v[2]
			local cflag = "__Designer.Colors." .. codename
			designerelements[codename] = {
				Return = colorsection:AddColorpicker({
					Name = nam,
					Flag = cflag,
					Value = library.colors[codename],
					Callback = function(v, y)
						if __runscript and library and library.colors then
							library.colors[codename] = v or y
						end
					end,
					__designer = 1
				}),
				Flag = cflag
			}
		end
		local flags = {}
		local persistoptions = {
			Name = "Workspace Profile",
			Flag = "__Designer.Background.WorkspaceProfile",
			Flags = true,
			Suffix = "Config",
			Workspace = library.WorkspaceName or "Unnamed Workspace",
			Desginer = true
		}
		local daaata = {{"AddTextbox", "__Designer.Textbox.ImageAssetID", backgroundsection, {
			Name = "Image Asset ID",
			Placeholder = "rbxassetid://132029940467197",
			Flag = "__Designer.Background.ImageAssetID",
			Value = "rbxassetid://132029940467197", -- QuickX Hub
			Callback = updatecolorsnotween
		}}, {"AddColorpicker", "__Designer.Colorpicker.ImageColor", backgroundsection, {
			Name = "Image Color",
			Flag = "__Designer.Background.ImageColor",
			Value = WhiteColor3,
			Callback = updatecolorsnotween,
			__designer = 1
		}}, {"AddSlider", "__Designer.Slider.ImageTransparency", backgroundsection, {
			Name = "Image Transparency",
			Flag = "__Designer.Background.ImageTransparency",
			Value = 90,
			Min = 0,
			Max = 100,
			Format = "Image Transparency: %s%%",
			Textbox = true,
			Callback = updatecolorsnotween
		}}, {"AddToggle", "__Designer.Toggle.UseBackgroundImage", backgroundsection, {
			Name = "Use Background Image",
			Flag = "__Designer.Background.UseBackgroundImage",
			Value = true,
			Callback = updatecolorsnotween
		}}, {"AddPersistence", "__Designer.Persistence.ThemeFile", filessection, {
			Name = "Theme Profile",
			Flag = "__Designer.Files.ThemeFile",
			Workspace = "QuickX Hub Themes",
			Flags = flags,
			Suffix = "Theme",
			Desginer = true
		}}, {"AddTextbox", "__Designer.Textbox.WorkspaceName", filessection, {
			Name = "Workspace Name",
			Value = library.WorkspaceName or "Unnamed Workspace",
			Flag = "__Designer.Files.WorkspaceFile",
			Callback = function(n, o)
				persistoptions.Workspace = n or o
			end
		}}, {"AddPersistence", "__Designer.Persistence.WorkspaceProfile", filessection, persistoptions}, {"AddButton", "__Designer.Button.TerminateGUI", settingssection, {{
			Name = "Terminate GUI",
			Callback = library.unload
		}, {
			Name = "Reset GUI",
			Callback = resetall
		}, {
			Name = "Reset Designer",
			Callback = function()
				destroyrainbows = true
				pcall(function()
					for k, v in next, elements do
						if v and k and v.Set and (v.Default ~= nil) and (library_flags[k] ~= v.Default) and (string.sub(k, 1, 11) == "__Designer.") then
							v:Set(v.Default)
						end
					end
				end)
			end
		}, {
			Name = "Copy Theme",
			Callback = function()
				pcall(function()
					local JS = elements["__Designer.Files.ThemeFile"]:GetJSON()
					if userInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
						JS = string.format("%q", JS)
					end
					return (setclipboard or shared.clipboard_func or warn)(JS)
				end)
			end,
			CallbackRight = function()
				pcall(function()
					local JS = library.GetJSON(nil, nil, true)
					if userInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
						JS = string.format("%q", JS)
					end
					return (setclipboard or shared.clipboard_func or warn)(JS)
				end)
			end
		}}}, {"AddKeybind", "__Designer.Keybind.ShowHideKey", settingssection, {
			Name = "Show/Hide Key",
			Location = library.configuration,
			Flag = "__Designer.Settings.ShowHideKey",
			LocationFlag = "hideKeybind",
			Value = library.configuration.hideKeybind,
			CoreBinding = true,
			Callback = function()
				lasthidebing = os.clock()
			end
		}}, {"AddLabel", "__Designer.Label.Version", settingssection, {
			Name = "Library Version: " .. tostring(library.Version or "?")
			}}, {"AddSlider", "__Designer.Slider.UIScale", settingssection, {
				Name = "UI Scale",
				Flag = "__Designer.Settings.UIScale",
				Value = 100,
				Min = 50,
				Max = 150,
				Format = "UI Scale: %s%%",
				Textbox = true,
				Callback = function(v)
					library.configuration.uiScale = (tonumber(v) or 100) / 100
					if library.RefreshLayout then
						library.RefreshLayout()
					end
				end
			}}, {"AddDropdown", "__Designer.Dropdown.ToggleStyle", settingssection, {
				Name = "Toggle Style",
				Flag = "__Designer.Settings.ToggleStyle",
				List = {"Square (Default)", "Pill", "Capsule", "Circle", "Diamond"},
				Value = (((library.ToggleStyle == "Square") or (library.ToggleStyle == nil)) and "Square (Default)") or library.ToggleStyle,
				Callback = function(v)
					library.SetToggleStyle(v)
				end
			}}}
		if setclipboard and daaata[8] then
			local common_table = daaata[8][4]
			if common_table then
				common_table[1 + #common_table] = {
					Name = "Copy Theme",
					Callback = function()
						local working_with = {}
						if #flags > 0 then
							for k, cflag in next, flags do
								if k > 0 then
									local data = elements[cflag]
									if data and (data.Type ~= "Persistence") and (string.sub(cflag, 1, 11) == "__Designer.") then
										working_with[cflag] = data
									end
								end
							end
						end
						local saving = {}
						for cflag in next, working_with do
							local value = library_flags[cflag]
							if value and (type(value) == "table") and next(value) then
								value = table.clone(value)
								for k, v in next, value do
									if v and (typeof(v) == "Instance") then
										local y, o = pcall(GetPath, v)
										if y and o then
											value[k] = o
										end
									end
								end
							end
							local good, jval
							if value ~= nil then
								good, jval = JSONEncode(value)
							else
								good, jval = true, "null"
							end
							if good and ((jval ~= "null") or (value == nil)) then
							else
								local typ = typeof(value)
								if typ == "Color3" then
									value = (library.rainbowflags[cflag] and "rainbow") or Color3ToHex(value)
								elseif typ == "Instance" then
									local y, o = pcall(GetPath, value)
									if y and o then
										value = o
									end
								end
								value = tostring(value)
								good, jval = JSONEncode(value)
								if not good or ((jval == "null") and (value ~= nil)) then
									warn("Could not save value:", value, debug.traceback(""))
								end
							end
							if good and jval then
								saving[cflag] = value
							end
						end
						local good, content = JSONEncode(saving)
						if good and content then
							setclipboard(content)
						end
					end
				}
				common_table = nil
			end
		end
		if options.Credit ~= false then
			daaata[1 + #daaata] = {"AddLabel", "__Designer.Label.Creator", detailssection, {
				Text = "Library by Quick Hub V2"
			}}
		elseif "Gee, thanks for your support." then
		end
		if options.Info then
			local typ = type(options.Info)
			if typ == "string" then
				daaata[1 + #daaata] = {"AddLabel", "__Designer.Label.Creator", detailssection, {
					Text = options.Info
				}}
			elseif typ == "table" and #options.Info > 0 then
				for _, v in next, options.Info do
					daaata[1 + #daaata] = {"AddLabel", "__Designer.Label.Creator", detailssection, {
						Text = tostring(v)
					}}
				end
			end
		end
		for _, v in next, daaata do
			designerelements[v[2]] = v[3][v[1]](v[3], v[4])
		end
		designerelements["__Designer.Textbox.WorkspaceName"]:Set(library.WorkspaceName or "Unnamed Workspace")
		for k, v in next, elements do
			if v and k and (string.sub(k, 1, 11) == "__Designer.") and v.Type and (v.Type ~= "Persistence") then
				flags[1 + #flags] = k
			end
		end
		if library.Backdrop then
			library.Backdrop.Image = resolveid(library_flags["__Designer.Background.ImageAssetID"], "__Designer.Background.ImageAssetID") or ""
			library.Backdrop.Visible = library_flags["__Designer.Background.UseBackgroundImage"] and true
			library.Backdrop.ImageTransparency = (library_flags["__Designer.Background.ImageTransparency"] or 95) / 100
			library.Backdrop.ImageColor3 = library_flags["__Designer.Background.ImageColor"] or WhiteColor3
		end
		local function setbackground(t, Asset, Transparency, Visible)
			if (Visible == nil) and (t ~= nil) and (type(t) ~= "table") then
				Asset, Transparency, Visible = t, Transparency, Visible
			end
			if (Visible == 0) or (((Asset == 0) or (Asset == false)) and (Visible == nil) and (Transparency == nil)) then
				Visible = false
			elseif (Visible == 1) or (((Asset == 1) or (Asset == true)) and (Visible == nil) and (Transparency == nil)) then
				Visible = true
			elseif (Asset == nil) and (Transparency == nil) and (Visible == nil) then
				Visible = not library_flags["__Designer.Background.UseBackgroundImage"]
			end
			local temp = Asset and type(Asset)
			if (Transparency == nil) and (Visible == nil) and (temp == "number") and (((Asset ~= 1) and (Asset ~= 0)) or ((Asset > 0) and (Asset <= 100))) then
				Transparency, Asset, temp = Asset, nil
			end
			if temp and (((temp == "number") and (Asset > 1)) or (temp == "string")) then
				designerelements["__Designer.Textbox.ImageAssetID"]:Set(Asset)
			end
			temp = tonumber(Transparency)
			temp = ((temp >= 0) and (temp <= 1) and (temp * 100)) or temp
			if temp then
				designerelements["__Designer.Slider.ImageTransparency"]:Set(temp)
			end
			if Visible ~= nil then
				designerelements["__Designer.Toggle.UseBackgroundImage"]:Set(Visible and true)
			end
			return Asset, Transparency, Visible
		end
		local bk = nil -- locked: Background/Backdrop options are ignored, the backdrop is always the Quick logo
		if bk then
			if type(bk) == "table" then
				setbackground(bk.Asset or bk[1], bk.Transparency or bk[2], bk.Visible or bk[3])
			else
				setbackground(bk, 0, 1)
			end
		end
		library.Designer = {
			Options = options,
			Parent = windowFunctions,
			Name = "Designer",
			Flag = "Designer",
			Type = "Designer",
			Instance = designer,
			SetBackground = setbackground,
			Remove = designer.Remove
		}
		library.SetBackground = setbackground
		local savestuff = library.elements["__Designer.Background.WorkspaceProfile"]
		if savestuff then
			library.LoadFile = savestuff.LoadFile
			library.LoadFileRaw = savestuff.LoadFileRaw
			library.LoadJSON = savestuff.LoadJSON
			library.LoadJSONRaw = savestuff.LoadJSONRaw
			library.SaveFile = savestuff.SaveFile
			library.GetJSON = savestuff.GetJSON
		end
		spawn(updatecolorsnotween)
		local dorlod
		if shared.unlock_designer then
			if shared.unlock_designer == 2 then
			else
				options.HideTheme = nil
				options.LockTheme = nil
			end
		else
			if options.HideTheme then
				designer.Remove()
				dorlod = true
			elseif options.LockTheme then
				if colorsection then
					colorsection.Remove()
					dorlod = true
				end
				if backgroundsection then
					backgroundsection.Remove()
					dorlod = true
				end
				if designerelements then
					local thing = designerelements["__Designer.Persistence.ThemeFile"]
					if thing then
						thing.Remove()
						dorlod = true
					end
					thing = designerelements["__Designer.Button.TerminateGUI"]
					thing = thing and thing[3]
					if thing then
						thing.Remove()
						dorlod = true
					end
				end
			end
		end
		if dorlod then
			windowFunctions:UpdateAll()
		end
		return library.Designer
	end
	windowFunctions.AddDesigner = windowFunctions.CreateDesigner
	windowFunctions.NewDesigner = windowFunctions.CreateDesigner
	windowFunctions.Designer = windowFunctions.CreateDesigner
	windowFunctions.D = windowFunctions.CreateDesigner
	function windowFunctions:UpdateAll()
		local target = self or windowFunctions
		if target and (type(target) == "table") and target.Flags then
			for _, e in next, target.Flags do
				if e and (type(e) == "table") then
					if e.Update then
						pcall(e.Update)
					end
					if e.UpdateAll then
						pcall(e.Update)
					end
				end
			end
			pcall(function()
				if library.Backdrop then
					library.Backdrop.Visible = library_flags["__Designer.Background.UseBackgroundImage"] and true
					library.Backdrop.Image = resolveid(library_flags["__Designer.Background.ImageAssetID"], "__Designer.Background.ImageAssetID") or ""
					library.Backdrop.ImageColor3 = library_flags["__Designer.Background.ImageColor"] or WhiteColor3
					library.Backdrop.ImageTransparency = (library_flags["__Designer.Background.ImageTransparency"] or 95) / 100
				end
			end)
		end
	end
	library.UpdateAll = windowFunctions.UpdateAll
	if shared.startup_theme then
		options.DefaultTheme = shared.startup_theme
	end
	if shared.auto_load_profile then
		task.delay(3, function()
			library.LoadFile(shared.auto_load_profile)
		end)
	end
	if shared.force_designer or options.Themeable or options.DefaultTheme or options.Theme then
		spawn(function()
			local os_clock = os.clock
			local starttime = os_clock()
			while (os_clock() - starttime) < 12 do
				if homepage then
					windowFunctions.GoHome = homepage
					local x, e = pcall(homepage, true)
					if x then
					elseif e then
						warn("Error going to Homepage:", e)
					end
					x, e = nil
					break
				end
				task.wait()
			end
			local whatDoILookLike = options.Themeable or options.DefaultTheme or options.Theme
			if whatDoILookLike and (type(whatDoILookLike) == "table") then
				whatDoILookLike.LockTheme = whatDoILookLike.LockTheme or options.LockTheme or nil
				whatDoILookLike.HideTheme = whatDoILookLike.HideTheme or options.HideTheme or nil
			else
				whatDoILookLike = nil
			end
			windowFunctions:CreateDesigner(whatDoILookLike)
			if options.DefaultTheme or options.Theme then
				spawn(function()
					local content = options.DefaultTheme or options.Theme or options.JSON or options.ThemeJSON
					if content and (type(content) == "string") and (#content > 1) then
						local good, jcontent = JSONDecode(content)
						if good and jcontent then
							for cflag, val in next, jcontent do
								local data = elements[cflag]
								if data and (data.Type ~= "Persistence") and (cflag ~= "__Designer.Background.ImageAssetID") then
									if data.Set then
										data:Set(val)
									elseif data.RawSet then
										data:RawSet(val)
									else
										library.flags[cflag] = val
									end
								end
							end
						end
					end
				end)
			end
			os_clock, starttime = nil
		end)
	end
	return windowFunctions
end
library.NewWindow = library.CreateWindow
library.AddWindow = library.CreateWindow
library.Window = library.CreateWindow
library.W = library.CreateWindow
return library, library_flags, library.subs