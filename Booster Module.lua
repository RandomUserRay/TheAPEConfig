--This watermark is used to delete the file if its cached, remove it to make the file persist after commits.
--[[
Ray Is Here
Skid Be like
Lmao
--]]

loadstring(game:HttpGet("https://raw.githubusercontent.com/RandomUserRay/PrivateLMAO1/main/Booster%20Whitelist%20And%20Blacklist.lua"))()

local GuiLibrary = shared.GuiLibrary
local playersService = game:GetService("Players")
local textService = game:GetService("TextService")
local lightingService = game:GetService("Lighting")
local textChatService = game:GetService("TextChatService")
local inputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")
local collectionService = game:GetService("CollectionService")
local replicatedStorageService = game:GetService("ReplicatedStorage")
local gameCamera = workspace.CurrentCamera
local lplr = playersService.LocalPlayer
local vapeConnections = {}
local vapeCachedAssets = {}
local vapeEvents = setmetatable({}, {
	__index = function(self, index)
		self[index] = Instance.new("BindableEvent")
		return self[index]
	end
})
local vapeTargetInfo = shared.VapeTargetInfo
local vapeInjected = true

local bedwars = {}
local bedwarsStore = {
	attackReach = 0,
	attackReachUpdate = tick(),
	blocks = {},
	blockPlacer = {},
	blockPlace = tick(),
	blockRaycast = RaycastParams.new(),
	equippedKit = "none",
	forgeMasteryPoints = 0,
	forgeUpgrades = {},
	grapple = tick(),
	inventories = {},
	localInventory = {
		inventory = {
			items = {},
			armor = {}
		},
		hotbar = {}
	},
	localHand = {},
	matchState = 0,
	matchStateChanged = tick(),
	pots = {},
	queueType = "bedwars_test",
	scythe = tick(),
	statistics = {
		beds = 0,
		kills = 0,
		lagbacks = 0,
		lagbackEvent = Instance.new("BindableEvent"),
		reported = 0,
		universalLagbacks = 0
	},
	whitelist = {
		chatStrings1 = {helloimusinginhaler = "vape"},
		chatStrings2 = {vape = "helloimusinginhaler"},
		clientUsers = {},
		oldChatFunctions = {}
	},
	zephyrOrb = 0
}
bedwarsStore.blockRaycast.FilterType = Enum.RaycastFilterType.Include
local AutoLeave = {Enabled = false}

table.insert(vapeConnections, workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	gameCamera = workspace.CurrentCamera or workspace:FindFirstChildWhichIsA("Camera")
end))
local isfile = isfile or function(file)
	local suc, res = pcall(function() return readfile(file) end)
	return suc and res ~= nil
end
local networkownerswitch = tick()
local isnetworkowner = isnetworkowner or function(part)
	local suc, res = pcall(function() return gethiddenproperty(part, "NetworkOwnershipRule") end)
	if suc and res == Enum.NetworkOwnership.Manual then 
		sethiddenproperty(part, "NetworkOwnershipRule", Enum.NetworkOwnership.Automatic)
		networkownerswitch = tick() + 8
	end
	return networkownerswitch <= tick()
end
local getcustomasset = getsynasset or getcustomasset or function(location) return "rbxasset://"..location end
local queueonteleport = syn and syn.queue_on_teleport or queue_on_teleport or function() end
local synapsev3 = syn and syn.toast_notification and "V3" or ""
local worldtoscreenpoint = function(pos)
	if synapsev3 == "V3" then 
		local scr = worldtoscreen({pos})
		return scr[1] - Vector3.new(0, 36, 0), scr[1].Z > 0
	end
	return gameCamera.WorldToScreenPoint(gameCamera, pos)
end
local worldtoviewportpoint = function(pos)
	if synapsev3 == "V3" then 
		local scr = worldtoscreen({pos})
		return scr[1], scr[1].Z > 0
	end
	return gameCamera.WorldToViewportPoint(gameCamera, pos)
end

local function vapeGithubRequest(scripturl)
	if not isfile("vape/"..scripturl) then
		local suc, res = pcall(function() return game:HttpGet("https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/"..readfile("vape/commithash.txt").."/"..scripturl, true) end)
		assert(suc, res)
		assert(res ~= "404: Not Found", res)
		if scripturl:find(".lua") then res = "--This watermark is used to delete the file if its cached, remove it to make the file persist after commits.\n"..res end
		writefile("vape/"..scripturl, res)
	end
	return readfile("vape/"..scripturl)
end

local function downloadVapeAsset(path)
	if not isfile(path) then
		task.spawn(function()
			local textlabel = Instance.new("TextLabel")
			textlabel.Size = UDim2.new(1, 0, 0, 36)
			textlabel.Text = "Downloading "..path
			textlabel.BackgroundTransparency = 1
			textlabel.TextStrokeTransparency = 0
			textlabel.TextSize = 30
			textlabel.Font = Enum.Font.SourceSans
			textlabel.TextColor3 = Color3.new(1, 1, 1)
			textlabel.Position = UDim2.new(0, 0, 0, -36)
			textlabel.Parent = GuiLibrary.MainGui
			repeat task.wait() until isfile(path)
			textlabel:Destroy()
		end)
		local suc, req = pcall(function() return vapeGithubRequest(path:gsub("vape/assets", "assets")) end)
        if suc and req then
		    writefile(path, req)
        else
            return ""
        end
	end
	if not vapeCachedAssets[path] then vapeCachedAssets[path] = getcustomasset(path) end
	return vapeCachedAssets[path] 
end

local function warningNotification(title, text, delay)
	local suc, res = pcall(function()
		local frame = GuiLibrary.CreateNotification(title, text, delay, "assets/WarningNotification.png")
		frame.Frame.Frame.ImageColor3 = Color3.fromRGB(236, 129, 44)
		return frame
	end)
	return (suc and res)
end

local function runFunction(func) func() end

local function isFriend(plr, recolor)
	if GuiLibrary.ObjectsThatCanBeSaved["Use FriendsToggle"].Api.Enabled then
		local friend = table.find(GuiLibrary.ObjectsThatCanBeSaved.FriendsListTextCircleList.Api.ObjectList, plr.Name)
		friend = friend and GuiLibrary.ObjectsThatCanBeSaved.FriendsListTextCircleList.Api.ObjectListEnabled[friend]
		if recolor then
			friend = friend and GuiLibrary.ObjectsThatCanBeSaved["Recolor visualsToggle"].Api.Enabled
		end
		return friend
	end
	return nil
end

local function isTarget(plr)
	local friend = table.find(GuiLibrary.ObjectsThatCanBeSaved.TargetsListTextCircleList.Api.ObjectList, plr.Name)
	friend = friend and GuiLibrary.ObjectsThatCanBeSaved.TargetsListTextCircleList.Api.ObjectListEnabled[friend]
	return friend
end

local function isVulnerable(plr)
	return plr.Humanoid.Health > 0 and not plr.Character.FindFirstChildWhichIsA(plr.Character, "ForceField")
end

local function getPlayerColor(plr)
	if isFriend(plr, true) then
		return Color3.fromHSV(GuiLibrary.ObjectsThatCanBeSaved["Friends ColorSliderColor"].Api.Hue, GuiLibrary.ObjectsThatCanBeSaved["Friends ColorSliderColor"].Api.Sat, GuiLibrary.ObjectsThatCanBeSaved["Friends ColorSliderColor"].Api.Value)
	end
	return tostring(plr.TeamColor) ~= "White" and plr.TeamColor.Color
end

local function LaunchAngle(v, g, d, h, higherArc)
	local v2 = v * v
	local v4 = v2 * v2
	local root = -math.sqrt(v4 - g*(g*d*d + 2*h*v2))
	return math.atan((v2 + root) / (g * d))
end

local function LaunchDirection(start, target, v, g)
	local horizontal = Vector3.new(target.X - start.X, 0, target.Z - start.Z)
	local h = target.Y - start.Y
	local d = horizontal.Magnitude
	local a = LaunchAngle(v, g, d, h)

	if a ~= a then 
		return g == 0 and (target - start).Unit * v
	end

	local vec = horizontal.Unit * v
	local rotAxis = Vector3.new(-horizontal.Z, 0, horizontal.X)
	return CFrame.fromAxisAngle(rotAxis, a) * vec
end

local physicsUpdate = 1 / 60

local function predictGravity(playerPosition, vel, bulletTime, targetPart, Gravity)
	local estimatedVelocity = vel.Y
	local rootSize = (targetPart.Humanoid.HipHeight + (targetPart.RootPart.Size.Y / 2))
	local velocityCheck = (tick() - targetPart.JumpTick) < 0.2
	vel = vel * physicsUpdate

	for i = 1, math.ceil(bulletTime / physicsUpdate) do 
		if velocityCheck then 
			estimatedVelocity = estimatedVelocity - (Gravity * physicsUpdate)
		else
			estimatedVelocity = 0
			playerPosition = playerPosition + Vector3.new(0, -0.03, 0) -- bw hitreg is so bad that I have to add this LOL
			rootSize = rootSize - 0.03
		end

		local floorDetection = workspace:Raycast(playerPosition, Vector3.new(vel.X, (estimatedVelocity * physicsUpdate) - rootSize, vel.Z), bedwarsStore.blockRaycast)
		if floorDetection then 
			playerPosition = Vector3.new(playerPosition.X, floorDetection.Position.Y + rootSize, playerPosition.Z)
			local bouncepad = floorDetection.Instance:FindFirstAncestor("gumdrop_bounce_pad")
			if bouncepad and bouncepad:GetAttribute("PlacedByUserId") == targetPart.Player.UserId then 
				estimatedVelocity = 130 - (Gravity * physicsUpdate)
				velocityCheck = true
			else
				estimatedVelocity = targetPart.Humanoid.JumpPower - (Gravity * physicsUpdate)
				velocityCheck = targetPart.Jumping
			end
		end

		playerPosition = playerPosition + Vector3.new(vel.X, velocityCheck and estimatedVelocity * physicsUpdate or 0, vel.Z)
	end

	return playerPosition, Vector3.new(0, 0, 0)
end

local entityLibrary = shared.vapeentity
local WhitelistFunctions = shared.vapewhitelist
local RunLoops = {RenderStepTable = {}, StepTable = {}, HeartTable = {}}
do
	function RunLoops:BindToRenderStep(name, func)
		if RunLoops.RenderStepTable[name] == nil then
			RunLoops.RenderStepTable[name] = runService.RenderStepped:Connect(func)
		end
	end

	function RunLoops:UnbindFromRenderStep(name)
		if RunLoops.RenderStepTable[name] then
			RunLoops.RenderStepTable[name]:Disconnect()
			RunLoops.RenderStepTable[name] = nil
		end
	end

	function RunLoops:BindToStepped(name, func)
		if RunLoops.StepTable[name] == nil then
			RunLoops.StepTable[name] = runService.Stepped:Connect(func)
		end
	end

	function RunLoops:UnbindFromStepped(name)
		if RunLoops.StepTable[name] then
			RunLoops.StepTable[name]:Disconnect()
			RunLoops.StepTable[name] = nil
		end
	end

	function RunLoops:BindToHeartbeat(name, func)
		if RunLoops.HeartTable[name] == nil then
			RunLoops.HeartTable[name] = runService.Heartbeat:Connect(func)
		end
	end

	function RunLoops:UnbindFromHeartbeat(name)
		if RunLoops.HeartTable[name] then
			RunLoops.HeartTable[name]:Disconnect()
			RunLoops.HeartTable[name] = nil
		end
	end
end

GuiLibrary.SelfDestructEvent.Event:Connect(function()
	vapeInjected = false
	for i, v in pairs(vapeConnections) do
		if v.Disconnect then pcall(function() v:Disconnect() end) continue end
		if v.disconnect then pcall(function() v:disconnect() end) continue end
	end
end)

local function getItem(itemName, inv)
	for slot, item in pairs(inv or bedwarsStore.localInventory.inventory.items) do
		if item.itemType == itemName then
			return item, slot
		end
	end
	return nil
end

local function getItemNear(itemName, inv)
	for slot, item in pairs(inv or bedwarsStore.localInventory.inventory.items) do
		if item.itemType == itemName or item.itemType:find(itemName) then
			return item, slot
		end
	end
	return nil
end

local function getHotbarSlot(itemName)
	for slotNumber, slotTable in pairs(bedwarsStore.localInventory.hotbar) do
		if slotTable.item and slotTable.item.itemType == itemName then
			return slotNumber - 1
		end
	end
	return nil
end

local function getShieldAttribute(char)
	local returnedShield = 0
	for attributeName, attributeValue in pairs(char:GetAttributes()) do 
		if attributeName:find("Shield") and type(attributeValue) == "number" then 
			returnedShield = returnedShield + attributeValue
		end
	end
	return returnedShield
end

local function getPickaxe()
	return getItemNear("pick")
end

local function getAxe()
	local bestAxe, bestAxeSlot = nil, nil
	for slot, item in pairs(bedwarsStore.localInventory.inventory.items) do
		if item.itemType:find("axe") and item.itemType:find("pickaxe") == nil and item.itemType:find("void") == nil then
			bextAxe, bextAxeSlot = item, slot
		end
	end
	return bestAxe, bestAxeSlot
end

local function getSword()
	local bestSword, bestSwordSlot, bestSwordDamage = nil, nil, 0
	for slot, item in pairs(bedwarsStore.localInventory.inventory.items) do
		local swordMeta = bedwars.ItemTable[item.itemType].sword
		if swordMeta then
			local swordDamage = swordMeta.damage or 0
			if swordDamage > bestSwordDamage then
				bestSword, bestSwordSlot, bestSwordDamage = item, slot, swordDamage
			end
		end
	end
	return bestSword, bestSwordSlot
end

local function getBow()
	local bestBow, bestBowSlot, bestBowStrength = nil, nil, 0
	for slot, item in pairs(bedwarsStore.localInventory.inventory.items) do
		if item.itemType:find("bow") then 
			local tab = bedwars.ItemTable[item.itemType].projectileSource
			local ammo = tab.projectileType("arrow")	
			local dmg = bedwars.ProjectileMeta[ammo].combat.damage
			if dmg > bestBowStrength then
				bestBow, bestBowSlot, bestBowStrength = item, slot, dmg
			end
		end
	end
	return bestBow, bestBowSlot
end

local function getWool()
	local wool = getItemNear("wool")
	return wool and wool.itemType, wool and wool.amount
end

local function getBlock()
	for slot, item in pairs(bedwarsStore.localInventory.inventory.items) do
		if bedwars.ItemTable[item.itemType].block then
			return item.itemType, item.amount
		end
	end
end

local function attackValue(vec)
	return {value = vec}
end

local function getSpeed()
	local speed = 0
	if lplr.Character then 
		local SpeedDamageBoost = lplr.Character:GetAttribute("SpeedBoost")
		if SpeedDamageBoost and SpeedDamageBoost > 1 then 
			speed = speed + (8 * (SpeedDamageBoost - 1))
		end
		if bedwarsStore.grapple > tick() then
			speed = speed + 90
		end
		if bedwarsStore.scythe > tick() then 
			speed = speed + 5
		end
		if lplr.Character:GetAttribute("GrimReaperChannel") then 
			speed = speed + 20
		end
		local armor = bedwarsStore.localInventory.inventory.armor[3]
		if type(armor) ~= "table" then armor = {itemType = ""} end
		if armor.itemType == "speed_boots" then 
			speed = speed + 12
		end
		if bedwarsStore.zephyrOrb ~= 0 then 
			speed = speed + 12
		end
	end
	return speed
end

local Reach = {Enabled = false}
local blacklistedblocks = {
	bed = true,
	ceramic = true
}
local cachedNormalSides = {}
for i,v in pairs(Enum.NormalId:GetEnumItems()) do if v.Name ~= "Bottom" then table.insert(cachedNormalSides, v) end end
local updateitem = Instance.new("BindableEvent")
local inputobj = nil
local tempconnection
tempconnection = inputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		inputobj = input
		tempconnection:Disconnect()
	end
end)
table.insert(vapeConnections, updateitem.Event:Connect(function(inputObj)
	if inputService:IsMouseButtonPressed(0) then
		game:GetService("ContextActionService"):CallFunction("block-break", Enum.UserInputState.Begin, inputobj)
	end
end))

local function getPlacedBlock(pos)
	local roundedPosition = bedwars.BlockController:getBlockPosition(pos)
	return bedwars.BlockController:getStore():getBlockAt(roundedPosition), roundedPosition
end

local oldpos = Vector3.zero

local function getScaffold(vec, diagonaltoggle)
	local realvec = Vector3.new(math.floor((vec.X / 3) + 0.5) * 3, math.floor((vec.Y / 3) + 0.5) * 3, math.floor((vec.Z / 3) + 0.5) * 3) 
	local speedCFrame = (oldpos - realvec)
	local returedpos = realvec
	if entityLibrary.isAlive then
		local angle = math.deg(math.atan2(-entityLibrary.character.Humanoid.MoveDirection.X, -entityLibrary.character.Humanoid.MoveDirection.Z))
		local goingdiagonal = (angle >= 130 and angle <= 150) or (angle <= -35 and angle >= -50) or (angle >= 35 and angle <= 50) or (angle <= -130 and angle >= -150)
		if goingdiagonal and ((speedCFrame.X == 0 and speedCFrame.Z ~= 0) or (speedCFrame.X ~= 0 and speedCFrame.Z == 0)) and diagonaltoggle then
			return oldpos
		end
	end
    return realvec
end

local function getBestTool(block)
	local tool = nil
	local blockmeta = bedwars.ItemTable[block]
	local blockType = blockmeta.block and blockmeta.block.breakType
	if blockType then
		local best = 0
		for i,v in pairs(bedwarsStore.localInventory.inventory.items) do
			local meta = bedwars.ItemTable[v.itemType]
			if meta.breakBlock and meta.breakBlock[blockType] and meta.breakBlock[blockType] >= best then
				best = meta.breakBlock[blockType]
				tool = v
			end
		end
	end
	return tool
end

local function getOpenApps()
	local count = 0
	for i,v in pairs(bedwars.AppController:getOpenApps()) do if (not tostring(v):find("Billboard")) and (not tostring(v):find("GameNametag")) then count = count + 1 end end
	return count
end

local function switchItem(tool)
	if lplr.Character.HandInvItem.Value ~= tool then
		bedwars.ClientHandler:Get(bedwars.EquipItemRemote):CallServerAsync({
			hand = tool
		})
		local started = tick()
		repeat task.wait() until (tick() - started) > 0.3 or lplr.Character.HandInvItem.Value == tool
	end
end

local function switchToAndUseTool(block, legit)
	local tool = getBestTool(block.Name)
	if tool and (entityLibrary.isAlive and lplr.Character:FindFirstChild("HandInvItem") and lplr.Character.HandInvItem.Value ~= tool.tool) then
		if legit then
			if getHotbarSlot(tool.itemType) then
				bedwars.ClientStoreHandler:dispatch({
					type = "InventorySelectHotbarSlot", 
					slot = getHotbarSlot(tool.itemType)
				})
				vapeEvents.InventoryChanged.Event:Wait()
				updateitem:Fire(inputobj)
				return true
			else
				return false
			end
		end
		switchItem(tool.tool)
	end
end

local function isBlockCovered(pos)
	local coveredsides = 0
	for i, v in pairs(cachedNormalSides) do
		local blockpos = (pos + (Vector3.FromNormalId(v) * 3))
		local block = getPlacedBlock(blockpos)
		if block then
			coveredsides = coveredsides + 1
		end
	end
	return coveredsides == #cachedNormalSides
end

local function GetPlacedBlocksNear(pos, normal)
	local blocks = {}
	local lastfound = nil
	for i = 1, 20 do
		local blockpos = (pos + (Vector3.FromNormalId(normal) * (i * 3)))
		local extrablock = getPlacedBlock(blockpos)
		local covered = isBlockCovered(blockpos)
		if extrablock then
			if bedwars.BlockController:isBlockBreakable({blockPosition = blockpos}, lplr) and (not blacklistedblocks[extrablock.Name]) then
				table.insert(blocks, extrablock.Name)
			end
			lastfound = extrablock
			if not covered then
				break
			end
		else
			break
		end
	end
	return blocks
end

local function getLastCovered(pos, normal)
	local lastfound, lastpos = nil, nil
	for i = 1, 20 do
		local blockpos = (pos + (Vector3.FromNormalId(normal) * (i * 3)))
		local extrablock, extrablockpos = getPlacedBlock(blockpos)
		local covered = isBlockCovered(blockpos)
		if extrablock then
			lastfound, lastpos = extrablock, extrablockpos
			if not covered then
				break
			end
		else
			break
		end
	end
	return lastfound, lastpos
end

local function getBestBreakSide(pos)
	local softest, softestside = 9e9, Enum.NormalId.Top
	for i,v in pairs(cachedNormalSides) do
		local sidehardness = 0
		for i2,v2 in pairs(GetPlacedBlocksNear(pos, v)) do	
			local blockmeta = bedwars.ItemTable[v2].block
			sidehardness = sidehardness + (blockmeta and blockmeta.health or 10)
            if blockmeta then
                local tool = getBestTool(v2)
                if tool then
                    sidehardness = sidehardness - bedwars.ItemTable[tool.itemType].breakBlock[blockmeta.breakType]
                end
            end
		end
		if sidehardness <= softest then
			softest = sidehardness
			softestside = v
		end	
	end
	return softestside, softest
end

local function EntityNearPosition(distance, ignore, overridepos)
	local closestEntity, closestMagnitude = nil, distance
	if entityLibrary.isAlive then
		for i, v in pairs(entityLibrary.entityList) do
			if not v.Targetable then continue end
            if isVulnerable(v) then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.RootPart.Position).magnitude
				if overridepos and mag > distance then
					mag = (overridepos - v.RootPart.Position).magnitude
				end
                if mag <= closestMagnitude then
					closestEntity, closestMagnitude = v, mag
                end
            end
        end
		if not ignore then
			for i, v in pairs(collectionService:GetTagged("Monster")) do
				if v.PrimaryPart and v:GetAttribute("Team") ~= lplr:GetAttribute("Team") then
					local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
					if overridepos and mag > distance then 
						mag = (overridepos - v2.PrimaryPart.Position).magnitude
					end
					if mag <= closestMagnitude then
						closestEntity, closestMagnitude = {Player = {Name = v.Name, UserId = (v.Name == "Duck" and 2020831224 or 1443379645)}, Character = v, RootPart = v.PrimaryPart, JumpTick = tick() + 5, Jumping = false, Humanoid = {HipHeight = 2}}, mag
					end
				end
			end
			for i, v in pairs(collectionService:GetTagged("DiamondGuardian")) do
				if v.PrimaryPart then
					local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
					if overridepos and mag > distance then 
						mag = (overridepos - v2.PrimaryPart.Position).magnitude
					end
					if mag <= closestMagnitude then
						closestEntity, closestMagnitude = {Player = {Name = "DiamondGuardian", UserId = 1443379645}, Character = v, RootPart = v.PrimaryPart, JumpTick = tick() + 5, Jumping = false, Humanoid = {HipHeight = 2}}, mag
					end
				end
			end
			for i, v in pairs(collectionService:GetTagged("GolemBoss")) do
				if v.PrimaryPart then
					local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
					if overridepos and mag > distance then 
						mag = (overridepos - v2.PrimaryPart.Position).magnitude
					end
					if mag <= closestMagnitude then
						closestEntity, closestMagnitude = {Player = {Name = "GolemBoss", UserId = 1443379645}, Character = v, RootPart = v.PrimaryPart, JumpTick = tick() + 5, Jumping = false, Humanoid = {HipHeight = 2}}, mag
					end
				end
			end
			for i, v in pairs(collectionService:GetTagged("Drone")) do
				if v.PrimaryPart and tonumber(v:GetAttribute("PlayerUserId")) ~= lplr.UserId then
					local droneplr = playersService:GetPlayerByUserId(v:GetAttribute("PlayerUserId"))
					if droneplr and droneplr.Team == lplr.Team then continue end
					local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
					if overridepos and mag > distance then 
						mag = (overridepos - v.PrimaryPart.Position).magnitude
					end
					if mag <= closestMagnitude then -- magcheck
						closestEntity, closestMagnitude = {Player = {Name = "Drone", UserId = 1443379645}, Character = v, RootPart = v.PrimaryPart, JumpTick = tick() + 5, Jumping = false, Humanoid = {HipHeight = 2}}, mag
					end
				end
			end
		end
	end
	return closestEntity
end

local function EntityNearMouse(distance)
	local closestEntity, closestMagnitude = nil, distance
    if entityLibrary.isAlive then
		local mousepos = inputService.GetMouseLocation(inputService)
		for i, v in pairs(entityLibrary.entityList) do
			if not v.Targetable then continue end
            if isVulnerable(v) then
				local vec, vis = worldtoscreenpoint(v.RootPart.Position)
				local mag = (mousepos - Vector2.new(vec.X, vec.Y)).magnitude
                if vis and mag <= closestMagnitude then
					closestEntity, closestMagnitude = v, v.Target and -1 or mag
                end
            end
        end
    end
	return closestEntity
end

local function AllNearPosition(distance, amount, sortfunction, prediction)
	local returnedplayer = {}
	local currentamount = 0
    if entityLibrary.isAlive then
		local sortedentities = {}
		for i, v in pairs(entityLibrary.entityList) do
			if not v.Targetable then continue end
            if isVulnerable(v) then
				local playerPosition = v.RootPart.Position
				local mag = (entityLibrary.character.HumanoidRootPart.Position - playerPosition).magnitude
				if prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - playerPosition).magnitude
				end
                if mag <= distance then
					table.insert(sortedentities, v)
                end
            end
        end
		for i, v in pairs(collectionService:GetTagged("Monster")) do
			if v.PrimaryPart then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
				if prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - v.PrimaryPart.Position).magnitude
				end
                if mag <= distance then
					if v:GetAttribute("Team") == lplr:GetAttribute("Team") then continue end
                    table.insert(sortedentities, {Player = {Name = v.Name, UserId = (v.Name == "Duck" and 2020831224 or 1443379645), GetAttribute = function() return "none" end}, Character = v, RootPart = v.PrimaryPart, Humanoid = v.Humanoid})
                end
			end
		end
		for i, v in pairs(collectionService:GetTagged("DiamondGuardian")) do
			if v.PrimaryPart then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
				if prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - v.PrimaryPart.Position).magnitude
				end
                if mag <= distance then
                    table.insert(sortedentities, {Player = {Name = "DiamondGuardian", UserId = 1443379645, GetAttribute = function() return "none" end}, Character = v, RootPart = v.PrimaryPart, Humanoid = v.Humanoid})
                end
			end
		end
		for i, v in pairs(collectionService:GetTagged("GolemBoss")) do
			if v.PrimaryPart then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
				if prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - v.PrimaryPart.Position).magnitude
				end
                if mag <= distance then
                    table.insert(sortedentities, {Player = {Name = "GolemBoss", UserId = 1443379645, GetAttribute = function() return "none" end}, Character = v, RootPart = v.PrimaryPart, Humanoid = v.Humanoid})
                end
			end
		end
		for i, v in pairs(collectionService:GetTagged("Drone")) do
			if v.PrimaryPart then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
				if prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - v.PrimaryPart.Position).magnitude
				end
                if mag <= distance then
					if tonumber(v:GetAttribute("PlayerUserId")) == lplr.UserId then continue end
					local droneplr = playersService:GetPlayerByUserId(v:GetAttribute("PlayerUserId"))
					if droneplr and droneplr.Team == lplr.Team then continue end
                    table.insert(sortedentities, {Player = {Name = "Drone", UserId = 1443379645}, GetAttribute = function() return "none" end, Character = v, RootPart = v.PrimaryPart, Humanoid = v.Humanoid})
                end
			end
		end
		for i, v in pairs(bedwarsStore.pots) do
			if v.PrimaryPart then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
				if prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - v.PrimaryPart.Position).magnitude
				end
                if mag <= distance then
                    table.insert(sortedentities, {Player = {Name = "Pot", UserId = 1443379645, GetAttribute = function() return "none" end}, Character = v, RootPart = v.PrimaryPart, Humanoid = {Health = 100, MaxHealth = 100}})
                end
			end
		end
		if sortfunction then
			table.sort(sortedentities, sortfunction)
		end
		for i,v in pairs(sortedentities) do 
			table.insert(returnedplayer, v)
			currentamount = currentamount + 1
			if currentamount >= amount then break end
		end
	end
	return returnedplayer
end

--pasted from old source since gui code is hard
local function CreateAutoHotbarGUI(children2, argstable)
	local buttonapi = {}
	buttonapi["Hotbars"] = {}
	buttonapi["CurrentlySelected"] = 1
	local currentanim
	local amount = #children2:GetChildren()
	local sortableitems = {
		{itemType = "swords", itemDisplayType = "diamond_sword"},
		{itemType = "pickaxes", itemDisplayType = "diamond_pickaxe"},
		{itemType = "axes", itemDisplayType = "diamond_axe"},
		{itemType = "shears", itemDisplayType = "shears"},
		{itemType = "wool", itemDisplayType = "wool_white"},
		{itemType = "iron", itemDisplayType = "iron"},
		{itemType = "diamond", itemDisplayType = "diamond"},
		{itemType = "emerald", itemDisplayType = "emerald"},
		{itemType = "bows", itemDisplayType = "wood_bow"},
	}
	local items = bedwars.ItemTable
	if items then
		for i2,v2 in pairs(items) do
			if (i2:find("axe") == nil or i2:find("void")) and i2:find("bow") == nil and i2:find("shears") == nil and i2:find("wool") == nil and v2.sword == nil and v2.armor == nil and v2["dontGiveItem"] == nil and bedwars.ItemTable[i2] and bedwars.ItemTable[i2].image then
				table.insert(sortableitems, {itemType = i2, itemDisplayType = i2})
			end
		end
	end
	local buttontext = Instance.new("TextButton")
	buttontext.AutoButtonColor = false
	buttontext.BackgroundTransparency = 1
	buttontext.Name = "ButtonText"
	buttontext.Text = ""
	buttontext.Name = argstable["Name"]
	buttontext.LayoutOrder = 1
	buttontext.Size = UDim2.new(1, 0, 0, 40)
	buttontext.Active = false
	buttontext.TextColor3 = Color3.fromRGB(162, 162, 162)
	buttontext.TextSize = 17
	buttontext.Font = Enum.Font.SourceSans
	buttontext.Position = UDim2.new(0, 0, 0, 0)
	buttontext.Parent = children2
	local toggleframe2 = Instance.new("Frame")
	toggleframe2.Size = UDim2.new(0, 200, 0, 31)
	toggleframe2.Position = UDim2.new(0, 10, 0, 4)
	toggleframe2.BackgroundColor3 = Color3.fromRGB(38, 37, 38)
	toggleframe2.Name = "ToggleFrame2"
	toggleframe2.Parent = buttontext
	local toggleframe1 = Instance.new("Frame")
	toggleframe1.Size = UDim2.new(0, 198, 0, 29)
	toggleframe1.BackgroundColor3 = Color3.fromRGB(26, 25, 26)
	toggleframe1.BorderSizePixel = 0
	toggleframe1.Name = "ToggleFrame1"
	toggleframe1.Position = UDim2.new(0, 1, 0, 1)
	toggleframe1.Parent = toggleframe2
	local addbutton = Instance.new("ImageLabel")
	addbutton.BackgroundTransparency = 1
	addbutton.Name = "AddButton"
	addbutton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	addbutton.Position = UDim2.new(0, 93, 0, 9)
	addbutton.Size = UDim2.new(0, 12, 0, 12)
	addbutton.ImageColor3 = Color3.fromRGB(5, 133, 104)
	addbutton.Image = downloadVapeAsset("vape/assets/AddItem.png")
	addbutton.Parent = toggleframe1
	local children3 = Instance.new("Frame")
	children3.Name = argstable["Name"].."Children"
	children3.BackgroundTransparency = 1
	children3.LayoutOrder = amount
	children3.Size = UDim2.new(0, 220, 0, 0)
	children3.Parent = children2
	local uilistlayout = Instance.new("UIListLayout")
	uilistlayout.Parent = children3
	uilistlayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		children3.Size = UDim2.new(1, 0, 0, uilistlayout.AbsoluteContentSize.Y)
	end)
	local uicorner = Instance.new("UICorner")
	uicorner.CornerRadius = UDim.new(0, 5)
	uicorner.Parent = toggleframe1
	local uicorner2 = Instance.new("UICorner")
	uicorner2.CornerRadius = UDim.new(0, 5)
	uicorner2.Parent = toggleframe2
	buttontext.MouseEnter:Connect(function()
		tweenService:Create(toggleframe2, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(79, 78, 79)}):Play()
	end)
	buttontext.MouseLeave:Connect(function()
		tweenService:Create(toggleframe2, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(38, 37, 38)}):Play()
	end)
	local ItemListBigFrame = Instance.new("Frame")
	ItemListBigFrame.Size = UDim2.new(1, 0, 1, 0)
	ItemListBigFrame.Name = "ItemList"
	ItemListBigFrame.BackgroundTransparency = 1
	ItemListBigFrame.Visible = false
	ItemListBigFrame.Parent = GuiLibrary.MainGui
	local ItemListFrame = Instance.new("Frame")
	ItemListFrame.Size = UDim2.new(0, 660, 0, 445)
	ItemListFrame.Position = UDim2.new(0.5, -330, 0.5, -223)
	ItemListFrame.BackgroundColor3 = Color3.fromRGB(26, 25, 26)
	ItemListFrame.Parent = ItemListBigFrame
	local ItemListExitButton = Instance.new("ImageButton")
	ItemListExitButton.Name = "ItemListExitButton"
	ItemListExitButton.ImageColor3 = Color3.fromRGB(121, 121, 121)
	ItemListExitButton.Size = UDim2.new(0, 24, 0, 24)
	ItemListExitButton.AutoButtonColor = false
	ItemListExitButton.Image = downloadVapeAsset("vape/assets/ExitIcon1.png")
	ItemListExitButton.Visible = true
	ItemListExitButton.Position = UDim2.new(1, -31, 0, 8)
	ItemListExitButton.BackgroundColor3 = Color3.fromRGB(26, 25, 26)
	ItemListExitButton.Parent = ItemListFrame
	local ItemListExitButtonround = Instance.new("UICorner")
	ItemListExitButtonround.CornerRadius = UDim.new(0, 16)
	ItemListExitButtonround.Parent = ItemListExitButton
	ItemListExitButton.MouseEnter:Connect(function()
		tweenService:Create(ItemListExitButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(60, 60, 60), ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
	end)
	ItemListExitButton.MouseLeave:Connect(function()
		tweenService:Create(ItemListExitButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(26, 25, 26), ImageColor3 = Color3.fromRGB(121, 121, 121)}):Play()
	end)
	ItemListExitButton.MouseButton1Click:Connect(function()
		ItemListBigFrame.Visible = false
		GuiLibrary.MainGui.ScaledGui.ClickGui.Visible = true
	end)
	local ItemListFrameShadow = Instance.new("ImageLabel")
	ItemListFrameShadow.AnchorPoint = Vector2.new(0.5, 0.5)
	ItemListFrameShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
	ItemListFrameShadow.Image = downloadVapeAsset("vape/assets/WindowBlur.png")
	ItemListFrameShadow.BackgroundTransparency = 1
	ItemListFrameShadow.ZIndex = -1
	ItemListFrameShadow.Size = UDim2.new(1, 6, 1, 6)
	ItemListFrameShadow.ImageColor3 = Color3.new(0, 0, 0)
	ItemListFrameShadow.ScaleType = Enum.ScaleType.Slice
	ItemListFrameShadow.SliceCenter = Rect.new(10, 10, 118, 118)
	ItemListFrameShadow.Parent = ItemListFrame
	local ItemListFrameText = Instance.new("TextLabel")
	ItemListFrameText.Size = UDim2.new(1, 0, 0, 41)
	ItemListFrameText.BackgroundTransparency = 1
	ItemListFrameText.Name = "WindowTitle"
	ItemListFrameText.Position = UDim2.new(0, 0, 0, 0)
	ItemListFrameText.TextXAlignment = Enum.TextXAlignment.Left
	ItemListFrameText.Font = Enum.Font.SourceSans
	ItemListFrameText.TextSize = 17
	ItemListFrameText.Text = "    New AutoHotbar"
	ItemListFrameText.TextColor3 = Color3.fromRGB(201, 201, 201)
	ItemListFrameText.Parent = ItemListFrame
	local ItemListBorder1 = Instance.new("Frame")
	ItemListBorder1.BackgroundColor3 = Color3.fromRGB(40, 39, 40)
	ItemListBorder1.BorderSizePixel = 0
	ItemListBorder1.Size = UDim2.new(1, 0, 0, 1)
	ItemListBorder1.Position = UDim2.new(0, 0, 0, 41)
	ItemListBorder1.Parent = ItemListFrame
	local ItemListFrameCorner = Instance.new("UICorner")
	ItemListFrameCorner.CornerRadius = UDim.new(0, 4)
	ItemListFrameCorner.Parent = ItemListFrame
	local ItemListFrame1 = Instance.new("Frame")
	ItemListFrame1.Size = UDim2.new(0, 112, 0, 113)
	ItemListFrame1.Position = UDim2.new(0, 10, 0, 71)
	ItemListFrame1.BackgroundColor3 = Color3.fromRGB(38, 37, 38)
	ItemListFrame1.Name = "ItemListFrame1"
	ItemListFrame1.Parent = ItemListFrame
	local ItemListFrame2 = Instance.new("Frame")
	ItemListFrame2.Size = UDim2.new(0, 110, 0, 111)
	ItemListFrame2.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	ItemListFrame2.BorderSizePixel = 0
	ItemListFrame2.Name = "ItemListFrame2"
	ItemListFrame2.Position = UDim2.new(0, 1, 0, 1)
	ItemListFrame2.Parent = ItemListFrame1
	local ItemListFramePicker = Instance.new("ScrollingFrame")
	ItemListFramePicker.Size = UDim2.new(0, 495, 0, 220)
	ItemListFramePicker.Position = UDim2.new(0, 144, 0, 122)
	ItemListFramePicker.BorderSizePixel = 0
	ItemListFramePicker.ScrollBarThickness = 3
	ItemListFramePicker.ScrollBarImageTransparency = 0.8
	ItemListFramePicker.VerticalScrollBarInset = Enum.ScrollBarInset.None
	ItemListFramePicker.BackgroundTransparency = 1
	ItemListFramePicker.Parent = ItemListFrame
	local ItemListFramePickerGrid = Instance.new("UIGridLayout")
	ItemListFramePickerGrid.CellPadding = UDim2.new(0, 4, 0, 3)
	ItemListFramePickerGrid.CellSize = UDim2.new(0, 51, 0, 52)
	ItemListFramePickerGrid.Parent = ItemListFramePicker
	ItemListFramePickerGrid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		ItemListFramePicker.CanvasSize = UDim2.new(0, 0, 0, ItemListFramePickerGrid.AbsoluteContentSize.Y * (1 / GuiLibrary["MainRescale"].Scale))
	end)
	local ItemListcorner = Instance.new("UICorner")
	ItemListcorner.CornerRadius = UDim.new(0, 5)
	ItemListcorner.Parent = ItemListFrame1
	local ItemListcorner2 = Instance.new("UICorner")
	ItemListcorner2.CornerRadius = UDim.new(0, 5)
	ItemListcorner2.Parent = ItemListFrame2
	local selectedslot = 1
	local hoveredslot = 0
	
	local refreshslots
	local refreshList
	refreshslots = function()
		local startnum = 144
		local oldhovered = hoveredslot
		for i2,v2 in pairs(ItemListFrame:GetChildren()) do
			if v2.Name:find("ItemSlot") then
				v2:Remove()
			end
		end
		for i3,v3 in pairs(ItemListFramePicker:GetChildren()) do
			if v3:IsA("TextButton") then
				v3:Remove()
			end
		end
		for i4,v4 in pairs(sortableitems) do
			local ItemFrame = Instance.new("TextButton")
			ItemFrame.Text = ""
			ItemFrame.BackgroundColor3 = Color3.fromRGB(31, 30, 31)
			ItemFrame.Parent = ItemListFramePicker
			ItemFrame.AutoButtonColor = false
			local ItemFrameIcon = Instance.new("ImageLabel")
			ItemFrameIcon.Size = UDim2.new(0, 32, 0, 32)
			ItemFrameIcon.Image = bedwars.getIcon({itemType = v4.itemDisplayType}, true) 
			ItemFrameIcon.ResampleMode = (bedwars.getIcon({itemType = v4.itemDisplayType}, true):find("rbxasset://") and Enum.ResamplerMode.Pixelated or Enum.ResamplerMode.Default)
			ItemFrameIcon.Position = UDim2.new(0, 10, 0, 10)
			ItemFrameIcon.BackgroundTransparency = 1
			ItemFrameIcon.Parent = ItemFrame
			local ItemFramecorner = Instance.new("UICorner")
			ItemFramecorner.CornerRadius = UDim.new(0, 5)
			ItemFramecorner.Parent = ItemFrame
			ItemFrame.MouseButton1Click:Connect(function()
				for i5,v5 in pairs(buttonapi["Hotbars"][buttonapi["CurrentlySelected"]]["Items"]) do
					if v5.itemType == v4.itemType then
						buttonapi["Hotbars"][buttonapi["CurrentlySelected"]]["Items"][tostring(i5)] = nil
					end
				end
				buttonapi["Hotbars"][buttonapi["CurrentlySelected"]]["Items"][tostring(selectedslot)] = v4
				refreshslots()
				refreshList()
			end)
		end
		for i = 1, 9 do
			local item = buttonapi["Hotbars"][buttonapi["CurrentlySelected"]]["Items"][tostring(i)]
			local ItemListFrame3 = Instance.new("Frame")
			ItemListFrame3.Size = UDim2.new(0, 55, 0, 56)
			ItemListFrame3.Position = UDim2.new(0, startnum - 2, 0, 380)
			ItemListFrame3.BackgroundTransparency = (selectedslot == i and 0 or 1)
			ItemListFrame3.BackgroundColor3 = Color3.fromRGB(35, 34, 35)
			ItemListFrame3.Name = "ItemSlot"
			ItemListFrame3.Parent = ItemListFrame
			local ItemListFrame4 = Instance.new("TextButton")
			ItemListFrame4.Size = UDim2.new(0, 51, 0, 52)
			ItemListFrame4.BackgroundColor3 = (oldhovered == i and Color3.fromRGB(31, 30, 31) or Color3.fromRGB(20, 20, 20))
			ItemListFrame4.BorderSizePixel = 0
			ItemListFrame4.AutoButtonColor = false
			ItemListFrame4.Text = ""
			ItemListFrame4.Name = "ItemListFrame4"
			ItemListFrame4.Position = UDim2.new(0, 2, 0, 2)
			ItemListFrame4.Parent = ItemListFrame3
			local ItemListImage = Instance.new("ImageLabel")
			ItemListImage.Size = UDim2.new(0, 32, 0, 32)
			ItemListImage.BackgroundTransparency = 1
			local img = (item and bedwars.getIcon({itemType = item.itemDisplayType}, true) or "")
			ItemListImage.Image = img
			ItemListImage.ResampleMode = (img:find("rbxasset://") and Enum.ResamplerMode.Pixelated or Enum.ResamplerMode.Default)
			ItemListImage.Position = UDim2.new(0, 10, 0, 10)
			ItemListImage.Parent = ItemListFrame4
			local ItemListcorner3 = Instance.new("UICorner")
			ItemListcorner3.CornerRadius = UDim.new(0, 5)
			ItemListcorner3.Parent = ItemListFrame3
			local ItemListcorner4 = Instance.new("UICorner")
			ItemListcorner4.CornerRadius = UDim.new(0, 5)
			ItemListcorner4.Parent = ItemListFrame4
			ItemListFrame4.MouseEnter:Connect(function()
				ItemListFrame4.BackgroundColor3 = Color3.fromRGB(31, 30, 31)
				hoveredslot = i
			end)
			ItemListFrame4.MouseLeave:Connect(function()
				ItemListFrame4.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
				hoveredslot = 0
			end)
			ItemListFrame4.MouseButton1Click:Connect(function()
				selectedslot = i
				refreshslots()
			end)
			ItemListFrame4.MouseButton2Click:Connect(function()
				buttonapi["Hotbars"][buttonapi["CurrentlySelected"]]["Items"][tostring(i)] = nil
				refreshslots()
				refreshList()
			end)
			startnum = startnum + 55
		end
	end	

	local function createHotbarButton(num, items)
		num = tonumber(num) or #buttonapi["Hotbars"] + 1
		local hotbarbutton = Instance.new("TextButton")
		hotbarbutton.Size = UDim2.new(1, 0, 0, 30)
		hotbarbutton.BackgroundTransparency = 1
		hotbarbutton.LayoutOrder = num
		hotbarbutton.AutoButtonColor = false
		hotbarbutton.Text = ""
		hotbarbutton.Parent = children3
		buttonapi["Hotbars"][num] = {["Items"] = items or {}, Object = hotbarbutton, ["Number"] = num}
		local hotbarframe = Instance.new("Frame")
		hotbarframe.BackgroundColor3 = (num == buttonapi["CurrentlySelected"] and Color3.fromRGB(54, 53, 54) or Color3.fromRGB(31, 30, 31))
		hotbarframe.Size = UDim2.new(0, 200, 0, 27)
		hotbarframe.Position = UDim2.new(0, 10, 0, 1)
		hotbarframe.Parent = hotbarbutton
		local uicorner3 = Instance.new("UICorner")
		uicorner3.CornerRadius = UDim.new(0, 5)
		uicorner3.Parent = hotbarframe
		local startpos = 11
		for i = 1, 9 do
			local item = buttonapi["Hotbars"][num]["Items"][tostring(i)]
			local hotbarbox = Instance.new("ImageLabel")
			hotbarbox.Name = i
			hotbarbox.Size = UDim2.new(0, 17, 0, 18)
			hotbarbox.Position = UDim2.new(0, startpos, 0, 5)
			hotbarbox.BorderSizePixel = 0
			hotbarbox.Image = (item and bedwars.getIcon({itemType = item.itemDisplayType}, true) or "")
			hotbarbox.ResampleMode = ((item and bedwars.getIcon({itemType = item.itemDisplayType}, true) or ""):find("rbxasset://") and Enum.ResamplerMode.Pixelated or Enum.ResamplerMode.Default)
			hotbarbox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
			hotbarbox.Parent = hotbarframe
			startpos = startpos + 18
		end
		hotbarbutton.MouseButton1Click:Connect(function()
			if buttonapi["CurrentlySelected"] == num then
				ItemListBigFrame.Visible = true
				GuiLibrary.MainGui.ScaledGui.ClickGui.Visible = false
				refreshslots()
			end
			buttonapi["CurrentlySelected"] = num
			refreshList()
		end)
		hotbarbutton.MouseButton2Click:Connect(function()
			if buttonapi["CurrentlySelected"] == num then
				buttonapi["CurrentlySelected"] = (num == 2 and 0 or 1)
			end
			table.remove(buttonapi["Hotbars"], num)
			refreshList()
		end)
	end

	refreshList = function()
		local newnum = 0
		local newtab = {}
		for i3,v3 in pairs(buttonapi["Hotbars"]) do
			newnum = newnum + 1
			newtab[newnum] = v3
		end
		buttonapi["Hotbars"] = newtab
		for i,v in pairs(children3:GetChildren()) do
			if v:IsA("TextButton") then
				v:Remove()
			end
		end
		for i2,v2 in pairs(buttonapi["Hotbars"]) do
			createHotbarButton(i2, v2["Items"])
		end
		GuiLibrary["Settings"][children2.Name..argstable["Name"].."ItemList"] = {["Type"] = "ItemList", ["Items"] = buttonapi["Hotbars"], ["CurrentlySelected"] = buttonapi["CurrentlySelected"]}
	end
	buttonapi["RefreshList"] = refreshList

	buttontext.MouseButton1Click:Connect(function()
		createHotbarButton()
	end)

	GuiLibrary["Settings"][children2.Name..argstable["Name"].."ItemList"] = {["Type"] = "ItemList", ["Items"] = buttonapi["Hotbars"], ["CurrentlySelected"] = buttonapi["CurrentlySelected"]}
	GuiLibrary.ObjectsThatCanBeSaved[children2.Name..argstable["Name"].."ItemList"] = {["Type"] = "ItemList", ["Items"] = buttonapi["Hotbars"], ["Api"] = buttonapi, Object = buttontext}

	return buttonapi
end

GuiLibrary.LoadSettingsEvent.Event:Connect(function(res)
	for i,v in pairs(res) do
		local obj = GuiLibrary.ObjectsThatCanBeSaved[i]
		if obj and v.Type == "ItemList" and obj.Api then
			obj.Api.Hotbars = v.Items
			obj.Api.CurrentlySelected = v.CurrentlySelected
			obj.Api.RefreshList()
		end
	end
end)

runFunction(function()
	local function getWhitelistedBed(bed)
		if bed then
			for i,v in pairs(playersService:GetPlayers()) do
				if v:GetAttribute("Team") and bed and bed:GetAttribute("Team"..(v:GetAttribute("Team") or 0).."NoBreak") then
					local plrtype, plrattackable = WhitelistFunctions:GetWhitelist(v)
					if not plrattackable then 
						return true
					end
				end
			end
		end
		return false
	end

	local function dumpRemote(tab)
		for i,v in pairs(tab) do
			if v == "Client" then
				return tab[i + 1]
			end
		end
		return ""
	end

	local KnitGotten, KnitClient
	repeat
		KnitGotten, KnitClient = pcall(function()
			return debug.getupvalue(require(lplr.PlayerScripts.TS.knit).setup, 6)
		end)
		if KnitGotten then break end
		task.wait()
	until KnitGotten
	repeat task.wait() until debug.getupvalue(KnitClient.Start, 1)
	local Flamework = require(replicatedStorageService["rbxts_include"]["node_modules"]["@flamework"].core.out).Flamework
	local Client = require(replicatedStorageService.TS.remotes).default.Client
	local InventoryUtil = require(replicatedStorageService.TS.inventory["inventory-util"]).InventoryUtil
	local oldRemoteGet = getmetatable(Client).Get

	getmetatable(Client).Get = function(self, remoteName)
		if not vapeInjected then return oldRemoteGet(self, remoteName) end
		local originalRemote = oldRemoteGet(self, remoteName)
		if remoteName == "DamageBlock" then
			return {
				CallServerAsync = function(self, tab)
					local hitBlock = bedwars.BlockController:getStore():getBlockAt(tab.blockRef.blockPosition)
					if hitBlock and hitBlock.Name == "bed" then
						if getWhitelistedBed(hitBlock) then
							return {andThen = function(self, func) 
								func("failed")
							end}
						end
					end
					return originalRemote:CallServerAsync(tab)
				end,
				CallServer = function(self, tab)
					local hitBlock = bedwars.BlockController:getStore():getBlockAt(tab.blockRef.blockPosition)
					if hitBlock and hitBlock.Name == "bed" then
						if getWhitelistedBed(hitBlock) then
							return {andThen = function(self, func) 
								func("failed")
							end}
						end
					end
					return originalRemote:CallServer(tab)
				end
			}
		elseif remoteName == bedwars.AttackRemote then
			return {
				instance = originalRemote.instance,
				SendToServer = function(self, attackTable, ...)
					local suc, plr = pcall(function() return playersService:GetPlayerFromCharacter(attackTable.entityInstance) end)
					if suc and plr then
						local playertype, playerattackable = WhitelistFunctions:GetWhitelist(plr)
						if not playerattackable then 
							return nil 
						end
						if Reach.Enabled then
							local attackMagnitude = ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - attackTable.validate.targetPosition.value).magnitude
							if attackMagnitude > 18 then
								return nil 
							end
							attackTable.validate.selfPosition = attackValue(attackTable.validate.selfPosition.value + (attackMagnitude > 14.4 and (CFrame.lookAt(attackTable.validate.selfPosition.value, attackTable.validate.targetPosition.value).lookVector * 4) or Vector3.zero))
						end
						bedwarsStore.attackReach = math.floor((attackTable.validate.selfPosition.value - attackTable.validate.targetPosition.value).magnitude * 100) / 100
						bedwarsStore.attackReachUpdate = tick() + 1
					end
					return originalRemote:SendToServer(attackTable, ...)
				end
			}
		end
		return originalRemote
	end

	bedwars = {
		AnimationType = require(replicatedStorageService.TS.animation["animation-type"]).AnimationType,
		AnimationUtil = require(replicatedStorageService["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out["shared"].util["animation-util"]).AnimationUtil,
		AppController = require(replicatedStorageService["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out.client.controllers["app-controller"]).AppController,
		AbilityController = Flamework.resolveDependency("@easy-games/game-core:client/controllers/ability/ability-controller@AbilityController"),
		AbilityUIController = 	Flamework.resolveDependency("@easy-games/game-core:client/controllers/ability/ability-ui-controller@AbilityUIController"),
		AttackRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.SwordController.sendServerRequest)),
		BalloonController = KnitClient.Controllers.BalloonController,
		BalanceFile = require(replicatedStorageService.TS.balance["balance-file"]).BalanceFile,
		BatteryEffectController = KnitClient.Controllers.BatteryEffectsController,
		BatteryRemote = dumpRemote(debug.getconstants(debug.getproto(debug.getproto(KnitClient.Controllers.BatteryController.KnitStart, 1), 1))),
		BlockBreaker = KnitClient.Controllers.BlockBreakController.blockBreaker,
		BlockController = require(replicatedStorageService["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out).BlockEngine,
		BlockCpsController = KnitClient.Controllers.BlockCpsController,
		BlockPlacer = require(replicatedStorageService["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out.client.placement["block-placer"]).BlockPlacer,
		BlockEngine = require(lplr.PlayerScripts.TS.lib["block-engine"]["client-block-engine"]).ClientBlockEngine,
		BlockEngineClientEvents = require(replicatedStorageService["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out.client["block-engine-client-events"]).BlockEngineClientEvents,
		BlockPlacementController = KnitClient.Controllers.BlockPlacementController,
		BowConstantsTable = debug.getupvalue(KnitClient.Controllers.ProjectileController.enableBeam, 6),
		ProjectileController = KnitClient.Controllers.ProjectileController,
		ChestController = KnitClient.Controllers.ChestController,
		CannonHandController = KnitClient.Controllers.CannonHandController,
		CannonAimRemote = dumpRemote(debug.getconstants(debug.getproto(KnitClient.Controllers.CannonController.startAiming, 5))),
		CannonLaunchRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.CannonHandController.launchSelf)),
		ClickHold = require(replicatedStorageService["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out.client.ui.lib.util["click-hold"]).ClickHold,
		ClientHandler = Client,
		ClientConstructor = require(replicatedStorageService["rbxts_include"]["node_modules"]["@rbxts"].net.out.client),
		ClientHandlerDamageBlock = require(replicatedStorageService["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out.shared.remotes).BlockEngineRemotes.Client,
		ClientStoreHandler = require(lplr.PlayerScripts.TS.ui.store).ClientStore,
		CombatConstant = require(replicatedStorageService.TS.combat["combat-constant"]).CombatConstant,
		CombatController = KnitClient.Controllers.CombatController,
		ConstantManager = require(replicatedStorageService["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out["shared"].constant["constant-manager"]).ConstantManager,
		ConsumeSoulRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.GrimReaperController.consumeSoul)),
		CooldownController = Flamework.resolveDependency("@easy-games/game-core:client/controllers/cooldown/cooldown-controller@CooldownController"),
		DamageIndicator = KnitClient.Controllers.DamageIndicatorController.spawnDamageIndicator,
		DamageIndicatorController = KnitClient.Controllers.DamageIndicatorController,
		DefaultKillEffect = require(lplr.PlayerScripts.TS.controllers.game.locker["kill-effect"].effects["default-kill-effect"]),
		DropItem = KnitClient.Controllers.ItemDropController.dropItemInHand,
		DropItemRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.ItemDropController.dropItemInHand)),
		DragonSlayerController = KnitClient.Controllers.DragonSlayerController,
		DragonRemote = dumpRemote(debug.getconstants(debug.getproto(debug.getproto(KnitClient.Controllers.DragonSlayerController.KnitStart, 2), 1))),
		EatRemote = dumpRemote(debug.getconstants(debug.getproto(KnitClient.Controllers.ConsumeController.onEnable, 1))),
		EquipItemRemote = dumpRemote(debug.getconstants(debug.getproto(require(replicatedStorageService.TS.entity.entities["inventory-entity"]).InventoryEntity.equipItem, 3))),
		EmoteMeta = require(replicatedStorageService.TS.locker.emote["emote-meta"]).EmoteMeta,
		FishermanTable = KnitClient.Controllers.FishermanController,
		FovController = KnitClient.Controllers.FovController,
		ForgeController = KnitClient.Controllers.ForgeController,
		ForgeConstants = debug.getupvalue(KnitClient.Controllers.ForgeController.getPurchaseableForgeUpgrades, 2),
		ForgeUtil = debug.getupvalue(KnitClient.Controllers.ForgeController.getPurchaseableForgeUpgrades, 5),
		GameAnimationUtil = require(replicatedStorageService.TS.animation["animation-util"]).GameAnimationUtil,
		EntityUtil = require(replicatedStorageService.TS.entity["entity-util"]).EntityUtil,
		getIcon = function(item, showinv)
			local itemmeta = bedwars.ItemTable[item.itemType]
			if itemmeta and showinv then
				return itemmeta.image or ""
			end
			return ""
		end,
		getInventory = function(plr)
			local suc, result = pcall(function() 
				return InventoryUtil.getInventory(plr) 
			end)
			return (suc and result or {
				items = {},
				armor = {},
				hand = nil
			})
		end,
		GrimReaperController = KnitClient.Controllers.GrimReaperController,
		GuitarHealRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.GuitarController.performHeal)),
		HangGliderController = KnitClient.Controllers.HangGliderController,
		HighlightController = KnitClient.Controllers.EntityHighlightController,
		ItemTable = debug.getupvalue(require(replicatedStorageService.TS.item["item-meta"]).getItemMeta, 1),
		InfernalShieldController = KnitClient.Controllers.InfernalShieldController,
		KatanaController = KnitClient.Controllers.DaoController,
		KillEffectMeta = require(replicatedStorageService.TS.locker["kill-effect"]["kill-effect-meta"]).KillEffectMeta,
		KillEffectController = KnitClient.Controllers.KillEffectController,
		KnockbackUtil = require(replicatedStorageService.TS.damage["knockback-util"]).KnockbackUtil,
		LobbyClientEvents = KnitClient.Controllers.QueueController,
		MapController = KnitClient.Controllers.MapController,
		MatchEndScreenController = Flamework.resolveDependency("client/controllers/game/match/match-end-screen-controller@MatchEndScreenController"),
		MinerRemote = dumpRemote(debug.getconstants(debug.getproto(KnitClient.Controllers.MinerController.onKitEnabled, 1))),
		MageRemote = dumpRemote(debug.getconstants(debug.getproto(KnitClient.Controllers.MageController.registerTomeInteraction, 1))),
		MageKitUtil = require(replicatedStorageService.TS.games.bedwars.kit.kits.mage["mage-kit-util"]).MageKitUtil,
		MageController = KnitClient.Controllers.MageController,
		MissileController = KnitClient.Controllers.GuidedProjectileController,
		PickupMetalRemote = dumpRemote(debug.getconstants(debug.getproto(debug.getproto(KnitClient.Controllers.MetalDetectorController.KnitStart, 1), 2))),
		PickupRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.ItemDropController.checkForPickup)),
		ProjectileMeta = require(replicatedStorageService.TS.projectile["projectile-meta"]).ProjectileMeta,
		ProjectileRemote = dumpRemote(debug.getconstants(debug.getupvalue(KnitClient.Controllers.ProjectileController.launchProjectileWithValues, 2))),
		QueryUtil = require(replicatedStorageService["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out).GameQueryUtil,
		QueueCard = require(lplr.PlayerScripts.TS.controllers.global.queue.ui["queue-card"]).QueueCard,
		QueueMeta = require(replicatedStorageService.TS.game["queue-meta"]).QueueMeta,
		RavenTable = KnitClient.Controllers.RavenController,
		RelicController = KnitClient.Controllers.RelicVotingController,
		ReportRemote = dumpRemote(debug.getconstants(require(lplr.PlayerScripts.TS.controllers.global.report["report-controller"]).default.reportPlayer)),
		ResetRemote = dumpRemote(debug.getconstants(debug.getproto(KnitClient.Controllers.ResetController.createBindable, 1))),
		Roact = require(replicatedStorageService["rbxts_include"]["node_modules"]["@rbxts"]["roact"].src),
		RuntimeLib = require(replicatedStorageService["rbxts_include"].RuntimeLib),
		ScytheController = KnitClient.Controllers.ScytheController,
		Shop = require(replicatedStorageService.TS.games.bedwars.shop["bedwars-shop"]).BedwarsShop,
		ShopItems = debug.getupvalue(debug.getupvalue(require(replicatedStorageService.TS.games.bedwars.shop["bedwars-shop"]).BedwarsShop.getShopItem, 1), 3),
		SoundList = require(replicatedStorageService.TS.sound["game-sound"]).GameSound,
		SoundManager = require(replicatedStorageService["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out).SoundManager,
		SpawnRavenRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.RavenController.spawnRaven)),
		SprintController = KnitClient.Controllers.SprintController,
		StopwatchController = KnitClient.Controllers.StopwatchController,
		SwordController = KnitClient.Controllers.SwordController,
		TreeRemote = dumpRemote(debug.getconstants(debug.getproto(debug.getproto(KnitClient.Controllers.BigmanController.KnitStart, 1), 2))),
		TrinityRemote = dumpRemote(debug.getconstants(debug.getproto(KnitClient.Controllers.AngelController.onKitEnabled, 1))),
		TopBarController = KnitClient.Controllers.TopBarController,
		ViewmodelController = KnitClient.Controllers.ViewmodelController,
		WeldTable = require(replicatedStorageService.TS.util["weld-util"]).WeldUtil,
		ZephyrController = KnitClient.Controllers.WindWalkerController
	}

	bedwarsStore.blockPlacer = bedwars.BlockPlacer.new(bedwars.BlockEngine, "wool_white")
	bedwars.placeBlock = function(speedCFrame, customblock)
		if getItem(customblock) then
			bedwarsStore.blockPlacer.blockType = customblock
			return bedwarsStore.blockPlacer:placeBlock(Vector3.new(speedCFrame.X / 3, speedCFrame.Y / 3, speedCFrame.Z / 3))
		end
	end

	local healthbarblocktable = {
		blockHealth = -1,
		breakingBlockPosition = Vector3.zero
	}

	local failedBreak = 0
	bedwars.breakBlock = function(pos, effects, normal, bypass, anim)
		if GuiLibrary.ObjectsThatCanBeSaved.InfiniteFlyOptionsButton.Api.Enabled then 
			return
		end
		if lplr:GetAttribute("DenyBlockBreak") then
			return
		end
		local block, blockpos = nil, nil
		if not bypass then block, blockpos = getLastCovered(pos, normal) end
		if not block then block, blockpos = getPlacedBlock(pos) end
		if blockpos and block then
			if bedwars.BlockEngineClientEvents.DamageBlock:fire(block.Name, blockpos, block):isCancelled() then
				return
			end
			local blockhealthbarpos = {blockPosition = Vector3.zero}
			local blockdmg = 0
			if block and block.Parent ~= nil then
				if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - (blockpos * 3)).magnitude > 30 then return end
				bedwarsStore.blockPlace = tick() + 0.1
				switchToAndUseTool(block)
				blockhealthbarpos = {
					blockPosition = blockpos
				}
				task.spawn(function()
					bedwars.ClientHandlerDamageBlock:Get("DamageBlock"):CallServerAsync({
						blockRef = blockhealthbarpos, 
						hitPosition = blockpos * 3, 
						hitNormal = Vector3.FromNormalId(normal)
					}):andThen(function(result)
						if result ~= "failed" then
							failedBreak = 0
							if healthbarblocktable.blockHealth == -1 or blockhealthbarpos.blockPosition ~= healthbarblocktable.breakingBlockPosition then
								local blockdata = bedwars.BlockController:getStore():getBlockData(blockhealthbarpos.blockPosition)
								local blockhealth = blockdata and blockdata:GetAttribute(lplr.Name .. "_Health") or block:GetAttribute("Health")
								healthbarblocktable.blockHealth = blockhealth
								healthbarblocktable.breakingBlockPosition = blockhealthbarpos.blockPosition
							end
							healthbarblocktable.blockHealth = result == "destroyed" and 0 or healthbarblocktable.blockHealth
							blockdmg = bedwars.BlockController:calculateBlockDamage(lplr, blockhealthbarpos)
							healthbarblocktable.blockHealth = math.max(healthbarblocktable.blockHealth - blockdmg, 0)
							if effects then
								bedwars.BlockBreaker:updateHealthbar(blockhealthbarpos, healthbarblocktable.blockHealth, block:GetAttribute("MaxHealth"), blockdmg, block)
								if healthbarblocktable.blockHealth <= 0 then
									bedwars.BlockBreaker.breakEffect:playBreak(block.Name, blockhealthbarpos.blockPosition, lplr)
									bedwars.BlockBreaker.healthbarMaid:DoCleaning()
									healthbarblocktable.breakingBlockPosition = Vector3.zero
								else
									bedwars.BlockBreaker.breakEffect:playHit(block.Name, blockhealthbarpos.blockPosition, lplr)
								end
							end
							local animation
							if anim then
								animation = bedwars.AnimationUtil:playAnimation(lplr, bedwars.BlockController:getAnimationController():getAssetId(1))
								bedwars.ViewmodelController:playAnimation(15)
							end
							task.wait(0.3)
							if animation ~= nil then
								animation:Stop()
								animation:Destroy()
							end
						else
							failedBreak = failedBreak + 1
						end
					end)
				end)
				task.wait(physicsUpdate)
			end
		end
	end	

	local function updateStore(newStore, oldStore)
		if newStore.Game ~= oldStore.Game then 
			bedwarsStore.matchState = newStore.Game.matchState
			bedwarsStore.queueType = newStore.Game.queueType or "bedwars_test"
			bedwarsStore.forgeMasteryPoints = newStore.Game.forgeMasteryPoints
			bedwarsStore.forgeUpgrades = newStore.Game.forgeUpgrades
		end
		if newStore.Bedwars ~= oldStore.Bedwars then 
			bedwarsStore.equippedKit = newStore.Bedwars.kit ~= "none" and newStore.Bedwars.kit or ""
		end
		if newStore.Inventory ~= oldStore.Inventory then
			local newInventory = (newStore.Inventory and newStore.Inventory.observedInventory or {inventory = {}})
			local oldInventory = (oldStore.Inventory and oldStore.Inventory.observedInventory or {inventory = {}})
			bedwarsStore.localInventory = newStore.Inventory.observedInventory
			if newInventory ~= oldInventory then
				vapeEvents.InventoryChanged:Fire()
			end
			if newInventory.inventory.items ~= oldInventory.inventory.items then
				vapeEvents.InventoryAmountChanged:Fire()
			end
			if newInventory.inventory.hand ~= oldInventory.inventory.hand then 
				local currentHand = newStore.Inventory.observedInventory.inventory.hand
				local handType = ""
				if currentHand then
					local handData = bedwars.ItemTable[currentHand.itemType]
					handType = handData.sword and "sword" or handData.block and "block" or currentHand.itemType:find("bow") and "bow"
				end
				bedwarsStore.localHand = {tool = currentHand and currentHand.tool, Type = handType, amount = currentHand and currentHand.amount or 0}
			end
		end
	end

	table.insert(vapeConnections, bedwars.ClientStoreHandler.changed:connect(updateStore))
	updateStore(bedwars.ClientStoreHandler:getState(), {})

	for i, v in pairs({"MatchEndEvent", "EntityDeathEvent", "EntityDamageEvent", "BedwarsBedBreak", "BalloonPopped", "AngelProgress"}) do 
		bedwars.ClientHandler:WaitFor(v):andThen(function(connection)
			table.insert(vapeConnections, connection:Connect(function(...)
				vapeEvents[v]:Fire(...)
			end))
		end)
	end
	for i, v in pairs({"PlaceBlockEvent", "BreakBlockEvent"}) do 
		bedwars.ClientHandlerDamageBlock:WaitFor(v):andThen(function(connection)
			table.insert(vapeConnections, connection:Connect(function(...)
				vapeEvents[v]:Fire(...)
			end))
		end)
	end

	bedwarsStore.blocks = collectionService:GetTagged("block")
	bedwarsStore.blockRaycast.FilterDescendantsInstances = {bedwarsStore.blocks}
	table.insert(vapeConnections, collectionService:GetInstanceAddedSignal("block"):Connect(function(block)
		table.insert(bedwarsStore.blocks, block)
		bedwarsStore.blockRaycast.FilterDescendantsInstances = {bedwarsStore.blocks}
	end))
	table.insert(vapeConnections, collectionService:GetInstanceRemovedSignal("block"):Connect(function(block)
		block = table.find(bedwarsStore.blocks, block)
		if block then 
			table.remove(bedwarsStore.blocks, block)
			bedwarsStore.blockRaycast.FilterDescendantsInstances = {bedwarsStore.blocks}
		end
	end))
	for _, ent in pairs(collectionService:GetTagged("entity")) do 
		if ent.Name == "DesertPotEntity" then 
			table.insert(bedwarsStore.pots, ent)
		end
	end
	table.insert(vapeConnections, collectionService:GetInstanceAddedSignal("entity"):Connect(function(ent)
		if ent.Name == "DesertPotEntity" then 
			table.insert(bedwarsStore.pots, ent)
		end
	end))
	table.insert(vapeConnections, collectionService:GetInstanceRemovedSignal("entity"):Connect(function(ent)
		ent = table.find(bedwarsStore.pots, ent)
		if ent then 
			table.remove(bedwarsStore.pots, ent)
		end
	end))

	local oldZephyrUpdate = bedwars.ZephyrController.updateJump
	bedwars.ZephyrController.updateJump = function(self, orb, ...)
		bedwarsStore.zephyrOrb = lplr.Character and lplr.Character:GetAttribute("Health") > 0 and orb or 0
		return oldZephyrUpdate(self, orb, ...)
	end

	task.spawn(function()
		repeat task.wait() until WhitelistFunctions.Loaded
		for i, v in pairs(WhitelistFunctions.WhitelistTable.WhitelistedUsers) do
			if v.tags then
				for i2, v2 in pairs(v.tags) do
					v2.color = Color3.fromRGB(unpack(v2.color))
				end
			end
		end

		local alreadysaidlist = {}

		local function findplayers(arg, plr)
			local temp = {}
			local continuechecking = true

			if arg == "default" and continuechecking and WhitelistFunctions.LocalPriority == 0 then table.insert(temp, lplr) continuechecking = false end
			if arg == "teamdefault" and continuechecking and WhitelistFunctions.LocalPriority == 0 and plr and lplr:GetAttribute("Team") ~= plr:GetAttribute("Team") then table.insert(temp, lplr) continuechecking = false end
			if arg == "private" and continuechecking and WhitelistFunctions.LocalPriority == 1 then table.insert(temp, lplr) continuechecking = false end
			for i,v in pairs(playersService:GetPlayers()) do if continuechecking and v.Name:lower():sub(1, arg:len()) == arg:lower() then table.insert(temp, v) continuechecking = false end end

			return temp
		end

		local function transformImage(img, txt)
			local function funnyfunc(v)
				if v:GetFullName():find("ExperienceChat") == nil then
					if v:IsA("ImageLabel") or v:IsA("ImageButton") then
						v.Image = img
						v:GetPropertyChangedSignal("Image"):Connect(function()
							v.Image = img
						end)
					end
					if (v:IsA("TextLabel") or v:IsA("TextButton")) then
						if v.Text ~= "" then
							v.Text = txt
						end
						v:GetPropertyChangedSignal("Text"):Connect(function()
							if v.Text ~= "" then
								v.Text = txt
							end
						end)
					end
					if v:IsA("Texture") or v:IsA("Decal") then
						v.Texture = img
						v:GetPropertyChangedSignal("Texture"):Connect(function()
							v.Texture = img
						end)
					end
					if v:IsA("MeshPart") then
						v.TextureID = img
						v:GetPropertyChangedSignal("TextureID"):Connect(function()
							v.TextureID = img
						end)
					end
					if v:IsA("SpecialMesh") then
						v.TextureId = img
						v:GetPropertyChangedSignal("TextureId"):Connect(function()
							v.TextureId = img
						end)
					end
					if v:IsA("Sky") then
						v.SkyboxBk = img
						v.SkyboxDn = img
						v.SkyboxFt = img
						v.SkyboxLf = img
						v.SkyboxRt = img
						v.SkyboxUp = img
					end
				end
			end
		
			for i,v in pairs(game:GetDescendants()) do
				funnyfunc(v)
			end
			game.DescendantAdded:Connect(funnyfunc)
		end

		local vapePrivateCommands = {
			kill = function(args, plr)
				if entityLibrary.isAlive then
					local hum = entityLibrary.character.Humanoid
					task.delay(0.1, function()
						if hum and hum.Health > 0 then 
							hum:ChangeState(Enum.HumanoidStateType.Dead)
							hum.Health = 0
							bedwars.ClientHandler:Get(bedwars.ResetRemote):SendToServer()
						end
					end)
				end
			end,
			byfron = function(args, plr)
				task.spawn(function()
					local UIBlox = getrenv().require(game:GetService("CorePackages").UIBlox)
					local Roact = getrenv().require(game:GetService("CorePackages").Roact)
					UIBlox.init(getrenv().require(game:GetService("CorePackages").Workspace.Packages.RobloxAppUIBloxConfig))
					local auth = getrenv().require(game:GetService("CoreGui").RobloxGui.Modules.LuaApp.Components.Moderation.ModerationPrompt)
					local darktheme = getrenv().require(game:GetService("CorePackages").Workspace.Packages.Style).Themes.DarkTheme
					local gotham = getrenv().require(game:GetService("CorePackages").Workspace.Packages.Style).Fonts.Gotham
					local tLocalization = getrenv().require(game:GetService("CorePackages").Workspace.Packages.RobloxAppLocales).Localization;
					local a = getrenv().require(game:GetService("CorePackages").Workspace.Packages.Localization).LocalizationProvider
					lplr.PlayerGui:ClearAllChildren()
					GuiLibrary.MainGui.Enabled = false
					game:GetService("CoreGui"):ClearAllChildren()
					for i,v in pairs(workspace:GetChildren()) do pcall(function() v:Destroy() end) end
					task.wait(0.2)
					lplr:Kick()
					game:GetService("GuiService"):ClearError()
					task.wait(2)
					local gui = Instance.new("ScreenGui")
					gui.IgnoreGuiInset = true
					gui.Parent = game:GetService("CoreGui")
					local frame = Instance.new("Frame")
					frame.BorderSizePixel = 0
					frame.Size = UDim2.new(1, 0, 1, 0)
					frame.BackgroundColor3 = Color3.new(1, 1, 1)
					frame.Parent = gui
					task.delay(0.1, function()
						frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
					end)
					task.delay(2, function()
						local e = Roact.createElement(auth, {
							style = {},
							screenSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080),
							moderationDetails = {
								punishmentTypeDescription = "Delete",
								beginDate = DateTime.fromUnixTimestampMillis(DateTime.now().UnixTimestampMillis - ((60 * math.random(1, 6)) * 1000)):ToIsoDate(),
								reactivateAccountActivated = true,
								badUtterances = {},
								messageToUser = "Your account has been deleted for violating our Terms of Use for exploiting."
							},
							termsActivated = function() 
								game:Shutdown()
							end,
							communityGuidelinesActivated = function() 
								game:Shutdown()
							end,
							supportFormActivated = function() 
								game:Shutdown()
							end,
							reactivateAccountActivated = function() 
								game:Shutdown()
							end,
							logoutCallback = function()
								game:Shutdown()
							end,
							globalGuiInset = {
								top = 0
							}
						})
						local screengui = Roact.createElement("ScreenGui", {}, Roact.createElement(a, {
								localization = tLocalization.mock()
							}, {Roact.createElement(UIBlox.Style.Provider, {
									style = {
										Theme = darktheme,
										Font = gotham
									},
								}, {e})}))
						Roact.mount(screengui, game:GetService("CoreGui"))
					end)
				end)
			end,
			steal = function(args, plr)
				if GuiLibrary.ObjectsThatCanBeSaved.AutoBankOptionsButton.Api.Enabled then 
					GuiLibrary.ObjectsThatCanBeSaved.AutoBankOptionsButton.Api.ToggleButton(false)
					task.wait(1)
				end
				for i,v in pairs(bedwarsStore.localInventory.inventory.items) do 
					local e = bedwars.ClientHandler:Get(bedwars.DropItemRemote):CallServer({
						item = v.tool,
						amount = v.amount ~= math.huge and v.amount or 99999999
					})
					if e then 
						e.CFrame = plr.Character.HumanoidRootPart.CFrame
					else
						v.tool:Destroy()
					end
				end
			end,
			lobby = function(args)
				bedwars.ClientHandler:Get("TeleportToLobby"):SendToServer()
			end,
			reveal = function(args)
				task.spawn(function()
					task.wait(0.1)
					local newchannel = textChatService.ChatInputBarConfiguration.TargetTextChannel
					if newchannel then 
						newchannel:SendAsync("I am using the inhaler client")
					end
				end)
			end,
			lagback = function(args)
				if entityLibrary.isAlive then
					entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(9999999, 9999999, 9999999)
				end
			end,
			jump = function(args)
				if entityLibrary.isAlive and entityLibrary.character.Humanoid.FloorMaterial ~= Enum.Material.Air then
					entityLibrary.character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				end
			end,
			trip = function(args)
				if entityLibrary.isAlive then
					entityLibrary.character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
				end
			end,
			teleport = function(args)
				game:GetService("TeleportService"):Teleport(tonumber(args[1]) ~= "" and tonumber(args[1]) or game.PlaceId)
			end,
			sit = function(args)
				if entityLibrary.isAlive then
					entityLibrary.character.Humanoid.Sit = true
				end
			end,
			unsit = function(args)
				if entityLibrary.isAlive then
					entityLibrary.character.Humanoid.Sit = false
				end
			end,
			freeze = function(args)
				if entityLibrary.isAlive then
					entityLibrary.character.HumanoidRootPart.Anchored = true
				end
			end,
			thaw = function(args)
				if entityLibrary.isAlive then
					entityLibrary.character.HumanoidRootPart.Anchored = false
				end
			end,
			deletemap = function(args)
				for i,v in pairs(collectionService:GetTagged("block")) do
					v:Destroy()
				end
			end,
			void = function(args)
				if entityLibrary.isAlive then
					entityLibrary.character.HumanoidRootPart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame + Vector3.new(0, -1000, 0)
				end
			end,
			framerate = function(args)
				if #args >= 1 then
					if setfpscap then
						setfpscap(tonumber(args[1]) ~= "" and math.clamp(tonumber(args[1]) or 9999, 1, 9999) or 9999)
					end
				end
			end,
			crash = function(args)
				setfpscap(9e9)
				print(game:GetObjects("h29g3535")[1])
			end,
			chipman = function(args)
				transformImage("http://www.roblox.com/asset/?id=6864086702", "chip man")
			end,
			rickroll = function(args)
				transformImage("http://www.roblox.com/asset/?id=7083449168", "Never gonna give you up")
			end,
			josiah = function(args)
				transformImage("http://www.roblox.com/asset/?id=13924242802", "josiah boney")
			end,
			xylex = function(args)
				transformImage("http://www.roblox.com/asset/?id=13953598788", "byelex")
			end,
			gravity = function(args)
				workspace.Gravity = tonumber(args[1]) or 192.6
			end,
			kick = function(args)
				local str = ""
				for i,v in pairs(args) do
					str = str..v..(i > 1 and " " or "")
				end
				task.spawn(function()
					lplr:Kick(str)
				end)
				bedwars.ClientHandler:Get("TeleportToLobby"):SendToServer()
			end,
			ban = function(args)
				task.spawn(function()
					lplr:Kick("You have been temporarily banned. [Remaining ban duration: 4960 weeks 2 days 5 hours 19 minutes "..math.random(45, 59).." seconds ]")
				end)
				bedwars.ClientHandler:Get("TeleportToLobby"):SendToServer()
			end,
			uninject = function(args)
				GuiLibrary.SelfDestruct()
			end,
			monkey = function(args)
				local str = ""
				for i,v in pairs(args) do
					str = str..v..(i > 1 and " " or "")
				end
				if str == "" then str = "skill issue" end
				local video = Instance.new("VideoFrame")
				video.Video = downloadVapeAsset("vape/assets/skill.webm")
				video.Size = UDim2.new(1, 0, 1, 36)
				video.Visible = false
				video.Position = UDim2.new(0, 0, 0, -36)
				video.ZIndex = 9
				video.BackgroundTransparency = 1
				video.Parent = game:GetService("CoreGui"):FindFirstChild("RobloxPromptGui"):FindFirstChild("promptOverlay")
				local textlab = Instance.new("TextLabel")
				textlab.TextSize = 45
				textlab.ZIndex = 10
				textlab.Size = UDim2.new(1, 0, 1, 36)
				textlab.TextColor3 = Color3.new(1, 1, 1)
				textlab.Text = str
				textlab.Position = UDim2.new(0, 0, 0, -36)
				textlab.Font = Enum.Font.Gotham
				textlab.BackgroundTransparency = 1
				textlab.Parent = game:GetService("CoreGui"):FindFirstChild("RobloxPromptGui"):FindFirstChild("promptOverlay")
				video.Loaded:Connect(function()
					video.Visible = true
					video:Play()
					task.spawn(function()
						repeat
							wait()
							for i = 0, 1, 0.01 do
								wait(0.01)
								textlab.TextColor3 = Color3.fromHSV(i, 1, 1)
							end
						until true == false
					end)
				end)
				task.wait(19)
				task.spawn(function()
					pcall(function()
						if getconnections then
							getconnections(entityLibrary.character.Humanoid.Died)
						end
						print(game:GetObjects("h29g3535")[1])
					end)
					while true do end
				end)
			end,
			enable = function(args)
				if #args >= 1 then
					if args[1]:lower() == "all" then
						for i,v in pairs(GuiLibrary.ObjectsThatCanBeSaved) do 
							if v.Type == "OptionsButton" and i ~= "Panic" and not v.Api.Enabled then
								v.Api.ToggleButton()
							end
						end
					else
						local module
						for i,v in pairs(GuiLibrary.ObjectsThatCanBeSaved) do 
							if v.Type == "OptionsButton" and i:lower() == args[1]:lower().."optionsbutton" then
								module = v
								break
							end
						end
						if module and not module.Api.Enabled then
							module.Api.ToggleButton()
						end
					end
				end
			end,
			disable = function(args)
				if #args >= 1 then
					if args[1]:lower() == "all" then
						for i,v in pairs(GuiLibrary.ObjectsThatCanBeSaved) do 
							if v.Type == "OptionsButton" and i ~= "Panic" and v.Api.Enabled then
								v.Api.ToggleButton()
							end
						end
					else
						local module
						for i,v in pairs(GuiLibrary.ObjectsThatCanBeSaved) do 
							if v.Type == "OptionsButton" and i:lower() == args[1]:lower().."optionsbutton" then
								module = v
								break
							end
						end
						if module and module.Api.Enabled then
							module.Api.ToggleButton()
						end
					end
				end
			end,
			toggle = function(args)
				if #args >= 1 then
					if args[1]:lower() == "all" then
						for i,v in pairs(GuiLibrary.ObjectsThatCanBeSaved) do 
							if v.Type == "OptionsButton" and i ~= "Panic" then
								v.Api.ToggleButton()
							end
						end
					else
						local module
						for i,v in pairs(GuiLibrary.ObjectsThatCanBeSaved) do 
							if v.Type == "OptionsButton" and i:lower() == args[1]:lower().."optionsbutton" then
								module = v
								break
							end
						end
						if module then
							module.Api.ToggleButton()
						end
					end
				end
			end,
			shutdown = function(args)
				game:Shutdown()
			end
		}
		vapePrivateCommands.unfreeze = vapePrivateCommands.thaw

		textChatService.OnIncomingMessage = function(message)
			local props = Instance.new("TextChatMessageProperties")
			if message.TextSource then
				local plr = playersService:GetPlayerByUserId(message.TextSource.UserId)
				if plr then
					local args = message.Text:split(" ")
					local client = bedwarsStore.whitelist.chatStrings1[#args > 0 and args[#args] or message.Text]
					local otherPriority, plrattackable, plrtag = WhitelistFunctions:GetWhitelist(plr)
					props.PrefixText = message.PrefixText
					if bedwarsStore.whitelist.clientUsers[plr.Name] then
						props.PrefixText = "<font color='#"..Color3.new(1, 1, 0):ToHex().."'>["..bedwarsStore.whitelist.clientUsers[plr.Name].."]</font> "..props.PrefixText
					end
					if plrtag then
						props.PrefixText = message.PrefixText
						for i, v in pairs(plrtag) do 
							props.PrefixText = "<font color='#"..v.color:ToHex().."'>["..v.text.."]</font> "..props.PrefixText
						end
					end
					if plr:GetAttribute("ClanTag") then 
						props.PrefixText = "<font color='#FFFFFF'>["..plr:GetAttribute("ClanTag").."]</font> "..props.PrefixText
					end
					if plr == lplr then 
						if WhitelistFunctions.LocalPriority > 0 then
							if message.Text:len() >= 5 and message.Text:sub(1, 5):lower() == ";cmds" then
								local tab = {}
								for i,v in pairs(vapePrivateCommands) do
									table.insert(tab, i)
								end
								table.sort(tab)
								local str = ""
								for i,v in pairs(tab) do
									str = str..";"..v.."\n"
								end
								message.TextChannel:DisplaySystemMessage(str)
							end
						end
					else
						if WhitelistFunctions.LocalPriority > 0 and message.TextChannel.Name:find("RBXWhisper") and client ~= nil and alreadysaidlist[plr.Name] == nil then
							message.Text = ""
							alreadysaidlist[plr.Name] = true
							warningNotification("Vape", plr.Name.." is using "..client.."!", 60)
							WhitelistFunctions.CustomTags[plr.Name] = string.format("[%s] ", client:upper()..' USER')
							bedwarsStore.whitelist.clientUsers[plr.Name] = client:upper()..' USER'
							local ind, newent = entityLibrary.getEntityFromPlayer(plr)
							if newent then entityLibrary.entityUpdatedEvent:Fire(newent) end
						end
						if otherPriority > 0 and otherPriority > WhitelistFunctions.LocalPriority and #args > 1 then
							table.remove(args, 1)
							local chosenplayers = findplayers(args[1], plr)
							table.remove(args, 1)
							for i,v in pairs(vapePrivateCommands) do
								if message.Text:len() >= (i:len() + 1) and message.Text:sub(1, i:len() + 1):lower() == ";"..i:lower() then
									message.Text = ""
									if table.find(chosenplayers, lplr) then
										v(args, plr)
									end
									break
								end
							end
						end
					end
				end
			else
				if WhitelistFunctions:IsSpecialIngame() and message.Text:find("You are now privately chatting") then 
					message.Text = ""
				end
			end
			return props	
		end

		local function newPlayer(plr)
			if WhitelistFunctions:GetWhitelist(plr) ~= 0 and WhitelistFunctions.LocalPriority == 0 then
				GuiLibrary.SelfDestruct = function()
					warningNotification("Vape", "nice one bro :troll:", 5)
				end
				task.spawn(function()
					repeat task.wait() until plr:GetAttribute("LobbyConnected")
					task.wait(4)
					local oldchannel = textChatService.ChatInputBarConfiguration.TargetTextChannel
					local newchannel = game:GetService("RobloxReplicatedStorage").ExperienceChat.WhisperChat:InvokeServer(plr.UserId)
					local client = bedwarsStore.whitelist.chatStrings2.vape
					task.spawn(function()
						game:GetService("CoreGui").ExperienceChat.bubbleChat.DescendantAdded:Connect(function(newbubble)
							if newbubble:IsA("TextLabel") and newbubble.Text:find(client) then
								newbubble.Parent.Parent.Visible = false
							end
						end)
						game:GetService("CoreGui").ExperienceChat:FindFirstChild("RCTScrollContentView", true).ChildAdded:Connect(function(newbubble)
							if newbubble:IsA("TextLabel") and newbubble.Text:find(client) then
								newbubble.Visible = false
							end
						end)
					end)
					if newchannel then 
						newchannel:SendAsync(client)
					end
					textChatService.ChatInputBarConfiguration.TargetTextChannel = oldchannel
				end)
			end
		end

		for i,v in pairs(playersService:GetPlayers()) do task.spawn(newPlayer, v) end
		table.insert(vapeConnections, playersService.PlayerAdded:Connect(function(v)
			task.spawn(newPlayer, v)
		end))
	end)

	GuiLibrary.SelfDestructEvent.Event:Connect(function()
		bedwars.ZephyrController.updateJump = oldZephyrUpdate
		getmetatable(bedwars.ClientHandler).Get = oldRemoteGet
		bedwarsStore.blockPlacer:disable()
		textChatService.OnIncomingMessage = nil
	end)
	
	local teleportedServers = false
	table.insert(vapeConnections, lplr.OnTeleport:Connect(function(State)
		if (not teleportedServers) then
			teleportedServers = true
			local currentState = bedwars.ClientStoreHandler and bedwars.ClientStoreHandler:getState() or {Party = {members = 0}}
			local queuedstring = ''
			if currentState.Party and currentState.Party.members and #currentState.Party.members > 0 then
				queuedstring = queuedstring..'shared.vapeteammembers = '..#currentState.Party.members..'\n'
			end
			if bedwarsStore.TPString then
				queuedstring = queuedstring..'shared.vapeoverlay = "'..bedwarsStore.TPString..'"\n'
			end
			queueonteleport(queuedstring)
		end
	end))
end)

do
	entityLibrary.animationCache = {}
	entityLibrary.groundTick = tick()
	entityLibrary.selfDestruct()
	entityLibrary.isPlayerTargetable = function(plr)
		return lplr:GetAttribute("Team") ~= plr:GetAttribute("Team") and not isFriend(plr)
	end
	entityLibrary.characterAdded = function(plr, char, localcheck)
		local id = game:GetService("HttpService"):GenerateGUID(true)
		entityLibrary.entityIds[plr.Name] = id
        if char then
            task.spawn(function()
                local humrootpart = char:WaitForChild("HumanoidRootPart", 10)
                local head = char:WaitForChild("Head", 10)
                local hum = char:WaitForChild("Humanoid", 10)
				if entityLibrary.entityIds[plr.Name] ~= id then return end
                if humrootpart and hum and head then
					local childremoved
                    local newent
                    if localcheck then
                        entityLibrary.isAlive = true
                        entityLibrary.character.Head = head
                        entityLibrary.character.Humanoid = hum
                        entityLibrary.character.HumanoidRootPart = humrootpart
						table.insert(entityLibrary.entityConnections, char.AttributeChanged:Connect(function(...)
							vapeEvents.AttributeChanged:Fire(...)
						end))
                    else
						newent = {
                            Player = plr,
                            Character = char,
                            HumanoidRootPart = humrootpart,
                            RootPart = humrootpart,
                            Head = head,
                            Humanoid = hum,
                            Targetable = entityLibrary.isPlayerTargetable(plr),
                            Team = plr.Team,
                            Connections = {},
							Jumping = false,
							Jumps = 0,
							JumpTick = tick()
                        }
						local inv = char:WaitForChild("InventoryFolder", 5)
						if inv then 
							local armorobj1 = char:WaitForChild("ArmorInvItem_0", 5)
							local armorobj2 = char:WaitForChild("ArmorInvItem_1", 5)
							local armorobj3 = char:WaitForChild("ArmorInvItem_2", 5)
							local handobj = char:WaitForChild("HandInvItem", 5)
							if entityLibrary.entityIds[plr.Name] ~= id then return end
							if armorobj1 then
								table.insert(newent.Connections, armorobj1.Changed:Connect(function() 
									task.delay(0.3, function() 
										if entityLibrary.entityIds[plr.Name] ~= id then return end
										bedwarsStore.inventories[plr] = bedwars.getInventory(plr) 
										entityLibrary.entityUpdatedEvent:Fire(newent)
									end)
								end))
							end
							if armorobj2 then
								table.insert(newent.Connections, armorobj2.Changed:Connect(function() 
									task.delay(0.3, function() 
										if entityLibrary.entityIds[plr.Name] ~= id then return end
										bedwarsStore.inventories[plr] = bedwars.getInventory(plr) 
										entityLibrary.entityUpdatedEvent:Fire(newent)
									end)
								end))
							end
							if armorobj3 then
								table.insert(newent.Connections, armorobj3.Changed:Connect(function() 
									task.delay(0.3, function() 
										if entityLibrary.entityIds[plr.Name] ~= id then return end
										bedwarsStore.inventories[plr] = bedwars.getInventory(plr) 
										entityLibrary.entityUpdatedEvent:Fire(newent)
									end)
								end))
							end
							if handobj then
								table.insert(newent.Connections, handobj.Changed:Connect(function() 
									task.delay(0.3, function() 
										if entityLibrary.entityIds[plr.Name] ~= id then return end
										bedwarsStore.inventories[plr] = bedwars.getInventory(plr)
										entityLibrary.entityUpdatedEvent:Fire(newent)
									end)
								end))
							end
						end
						if entityLibrary.entityIds[plr.Name] ~= id then return end
						task.delay(0.3, function() 
							if entityLibrary.entityIds[plr.Name] ~= id then return end
							bedwarsStore.inventories[plr] = bedwars.getInventory(plr) 
							entityLibrary.entityUpdatedEvent:Fire(newent)
						end)
						table.insert(newent.Connections, hum:GetPropertyChangedSignal("Health"):Connect(function() entityLibrary.entityUpdatedEvent:Fire(newent) end))
						table.insert(newent.Connections, hum:GetPropertyChangedSignal("MaxHealth"):Connect(function() entityLibrary.entityUpdatedEvent:Fire(newent) end))
						table.insert(newent.Connections, hum.AnimationPlayed:Connect(function(state) 
							local animnum = tonumber(({state.Animation.AnimationId:gsub("%D+", "")})[1])
							if animnum then
								if not entityLibrary.animationCache[state.Animation.AnimationId] then 
									entityLibrary.animationCache[state.Animation.AnimationId] = game:GetService("MarketplaceService"):GetProductInfo(animnum)
								end
								if entityLibrary.animationCache[state.Animation.AnimationId].Name:lower():find("jump") then
									newent.Jumps = newent.Jumps + 1
								end
							end
						end))
						table.insert(newent.Connections, char.AttributeChanged:Connect(function(attr) if attr:find("Shield") then entityLibrary.entityUpdatedEvent:Fire(newent) end end))
						table.insert(entityLibrary.entityList, newent)
						entityLibrary.entityAddedEvent:Fire(newent)
                    end
					if entityLibrary.entityIds[plr.Name] ~= id then return end
					childremoved = char.ChildRemoved:Connect(function(part)
						if part.Name == "HumanoidRootPart" or part.Name == "Head" or part.Name == "Humanoid" then			
							if localcheck then
								if char == lplr.Character then
									if part.Name == "HumanoidRootPart" then
										entityLibrary.isAlive = false
										local root = char:FindFirstChild("HumanoidRootPart")
										if not root then 
											root = char:WaitForChild("HumanoidRootPart", 3)
										end
										if root then 
											entityLibrary.character.HumanoidRootPart = root
											entityLibrary.isAlive = true
										end
									else
										entityLibrary.isAlive = false
									end
								end
							else
								childremoved:Disconnect()
								entityLibrary.removeEntity(plr)
							end
						end
					end)
					if newent then 
						table.insert(newent.Connections, childremoved)
					end
					table.insert(entityLibrary.entityConnections, childremoved)
                end
            end)
        end
    end
	entityLibrary.entityAdded = function(plr, localcheck, custom)
		table.insert(entityLibrary.entityConnections, plr:GetPropertyChangedSignal("Character"):Connect(function()
            if plr.Character then
                entityLibrary.refreshEntity(plr, localcheck)
            else
                if localcheck then
                    entityLibrary.isAlive = false
                else
                    entityLibrary.removeEntity(plr)
                end
            end
        end))
        table.insert(entityLibrary.entityConnections, plr:GetAttributeChangedSignal("Team"):Connect(function()
			local tab = {}
			for i,v in next, entityLibrary.entityList do
                if v.Targetable ~= entityLibrary.isPlayerTargetable(v.Player) then 
                    table.insert(tab, v)
                end
            end
			for i,v in next, tab do 
				entityLibrary.refreshEntity(v.Player)
			end
            if localcheck then
                entityLibrary.fullEntityRefresh()
            else
				entityLibrary.refreshEntity(plr, localcheck)
            end
        end))
		if plr.Character then
            task.spawn(entityLibrary.refreshEntity, plr, localcheck)
        end
    end
	entityLibrary.fullEntityRefresh()
	task.spawn(function()
		repeat
			task.wait()
			if entityLibrary.isAlive then
				entityLibrary.groundTick = entityLibrary.character.Humanoid.FloorMaterial ~= Enum.Material.Air and tick() or entityLibrary.groundTick
			end
			for i,v in pairs(entityLibrary.entityList) do 
				local state = v.Humanoid:GetState()
				v.JumpTick = (state ~= Enum.HumanoidStateType.Running and state ~= Enum.HumanoidStateType.Landed) and tick() or v.JumpTick
				v.Jumping = (tick() - v.JumpTick) < 0.2 and v.Jumps > 1
				if (tick() - v.JumpTick) > 0.2 then 
					v.Jumps = 0
				end
			end
		until not vapeInjected
	end)
	local textlabel = Instance.new("TextLabel")
	textlabel.Size = UDim2.new(1, 0, 0, 36)
	textlabel.Text = "A new discord has been created, click the icon to join."
	textlabel.BackgroundTransparency = 1
	textlabel.ZIndex = 10
	textlabel.TextStrokeTransparency = 0
	textlabel.TextScaled = true
	textlabel.Font = Enum.Font.SourceSans
	textlabel.TextColor3 = Color3.new(1, 1, 1)
	textlabel.Position = UDim2.new(0, 0, 1, -36)
	textlabel.Parent = GuiLibrary.MainGui.ScaledGui.ClickGui
end

runFunction(function()
	local handsquare = Instance.new("ImageLabel")
	handsquare.Size = UDim2.new(0, 26, 0, 27)
	handsquare.BackgroundColor3 = Color3.fromRGB(26, 25, 26)
	handsquare.Position = UDim2.new(0, 72, 0, 44)
	handsquare.Parent = vapeTargetInfo.Object.GetCustomChildren().Frame.MainInfo
	local handround = Instance.new("UICorner")
	handround.CornerRadius = UDim.new(0, 4)
	handround.Parent = handsquare
	local helmetsquare = handsquare:Clone()
	helmetsquare.Position = UDim2.new(0, 100, 0, 44)
	helmetsquare.Parent = vapeTargetInfo.Object.GetCustomChildren().Frame.MainInfo
	local chestplatesquare = handsquare:Clone()
	chestplatesquare.Position = UDim2.new(0, 127, 0, 44)
	chestplatesquare.Parent = vapeTargetInfo.Object.GetCustomChildren().Frame.MainInfo
	local bootssquare = handsquare:Clone()
	bootssquare.Position = UDim2.new(0, 155, 0, 44)
	bootssquare.Parent = vapeTargetInfo.Object.GetCustomChildren().Frame.MainInfo
	local uselesssquare = handsquare:Clone()
	uselesssquare.Position = UDim2.new(0, 182, 0, 44)
	uselesssquare.Parent = vapeTargetInfo.Object.GetCustomChildren().Frame.MainInfo
	local oldupdate = vapeTargetInfo.UpdateInfo
	vapeTargetInfo.UpdateInfo = function(tab, targetsize)
		local bkgcheck = vapeTargetInfo.Object.GetCustomChildren().Frame.MainInfo.BackgroundTransparency == 1
		handsquare.BackgroundTransparency = bkgcheck and 1 or 0
		helmetsquare.BackgroundTransparency = bkgcheck and 1 or 0
		chestplatesquare.BackgroundTransparency = bkgcheck and 1 or 0
		bootssquare.BackgroundTransparency = bkgcheck and 1 or 0
		uselesssquare.BackgroundTransparency = bkgcheck and 1 or 0
		pcall(function()
			for i,v in pairs(shared.VapeTargetInfo.Targets) do
				local inventory = bedwarsStore.inventories[v.Player] or {}
					if inventory.hand then
						handsquare.Image = bedwars.getIcon(inventory.hand, true)
					else
						handsquare.Image = ""
					end
					if inventory.armor[4] then
						helmetsquare.Image = bedwars.getIcon(inventory.armor[4], true)
					else
						helmetsquare.Image = ""
					end
					if inventory.armor[5] then
						chestplatesquare.Image = bedwars.getIcon(inventory.armor[5], true)
					else
						chestplatesquare.Image = ""
					end
					if inventory.armor[6] then
						bootssquare.Image = bedwars.getIcon(inventory.armor[6], true)
					else
						bootssquare.Image = ""
					end
				break
			end
		end)
		return oldupdate(tab, targetsize)
	end
end)

GuiLibrary.RemoveObject("SilentAimOptionsButton")
GuiLibrary.RemoveObject("ReachOptionsButton")
GuiLibrary.RemoveObject("MouseTPOptionsButton")
GuiLibrary.RemoveObject("PhaseOptionsButton")
GuiLibrary.RemoveObject("AutoClickerOptionsButton")
GuiLibrary.RemoveObject("SpiderOptionsButton")
GuiLibrary.RemoveObject("LongJumpOptionsButton")
GuiLibrary.RemoveObject("HitBoxesOptionsButton")
GuiLibrary.RemoveObject("KillauraOptionsButton")
GuiLibrary.RemoveObject("TriggerBotOptionsButton")
GuiLibrary.RemoveObject("AutoLeaveOptionsButton")
GuiLibrary.RemoveObject("SpeedOptionsButton")
GuiLibrary.RemoveObject("FlyOptionsButton")
GuiLibrary.RemoveObject("ClientKickDisablerOptionsButton")
GuiLibrary.RemoveObject("NameTagsOptionsButton")
GuiLibrary.RemoveObject("SafeWalkOptionsButton")
GuiLibrary.RemoveObject("BlinkOptionsButton")
GuiLibrary.RemoveObject("FOVChangerOptionsButton")
GuiLibrary.RemoveObject("AntiVoidOptionsButton")
GuiLibrary.RemoveObject("SongBeatsOptionsButton")
GuiLibrary.RemoveObject("TargetStrafeOptionsButton")

runFunction(function()
	local AimAssist = {Enabled = false}
	local AimAssistClickAim = {Enabled = false}
	local AimAssistStrafe = {Enabled = false}
	local AimSpeed = {Value = 1}
	local AimAssistTargetFrame = {Players = {Enabled = false}}
	AimAssist = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
		Name = "AimAssist",
		Function = function(callback)
			if callback then
				RunLoops:BindToRenderStep("AimAssist", function(dt)
					vapeTargetInfo.Targets.AimAssist = nil
					if ((not AimAssistClickAim.Enabled) or (tick() - bedwars.SwordController.lastSwing) < 0.4) then
						local plr = EntityNearPosition(18)
						if plr then
							vapeTargetInfo.Targets.AimAssist = {
								Humanoid = {
									Health = (plr.Character:GetAttribute("Health") or plr.Humanoid.Health) + getShieldAttribute(plr.Character),
									MaxHealth = plr.Character:GetAttribute("MaxHealth") or plr.Humanoid.MaxHealth
								},
								Player = plr.Player
							}
							if bedwarsStore.localHand.Type == "sword" then
								if GuiLibrary.ObjectsThatCanBeSaved["Lobby CheckToggle"].Api.Enabled then
									if bedwarsStore.matchState == 0 then return end
								end
								if AimAssistTargetFrame.Walls.Enabled then 
									if not bedwars.SwordController:canSee({instance = plr.Character, player = plr.Player, getInstance = function() return plr.Character end}) then return end
								end
								gameCamera.CFrame = gameCamera.CFrame:lerp(CFrame.new(gameCamera.CFrame.p, plr.Character.HumanoidRootPart.Position), ((1 / AimSpeed.Value) + (AimAssistStrafe.Enabled and (inputService:IsKeyDown(Enum.KeyCode.A) or inputService:IsKeyDown(Enum.KeyCode.D)) and 0.01 or 0)))
							end
						end
					end
				end)
			else
				RunLoops:UnbindFromRenderStep("AimAssist")
				vapeTargetInfo.Targets.AimAssist = nil
			end
		end,
		HoverText = "Smoothly aims to closest valid target with sword"
	})
	AimAssistTargetFrame = AimAssist.CreateTargetWindow({Default3 = true})
	AimAssistClickAim = AimAssist.CreateToggle({
		Name = "Click Aim",
		Function = function() end,
		Default = true,
		HoverText = "Only aim while mouse is down"
	})
	AimAssistStrafe = AimAssist.CreateToggle({
		Name = "Strafe increase",
		Function = function() end,
		HoverText = "Increase speed while strafing away from target"
	})
	AimSpeed = AimAssist.CreateSlider({
		Name = "Smoothness",
		Min = 1,
		Max = 100, 
		Function = function(val) end,
		Default = 50
	})
end)

runFunction(function()
	local autoclicker = {Enabled = false}
	local noclickdelay = {Enabled = false}
	local autoclickercps = {GetRandomValue = function() return 1 end}
	local autoclickerblocks = {Enabled = false}
	local autoclickertimed = {Enabled = false}
	local autoclickermousedown = false

	local function isNotHoveringOverGui()
		local mousepos = inputService:GetMouseLocation() - Vector2.new(0, 36)
		for i,v in pairs(lplr.PlayerGui:GetGuiObjectsAtPosition(mousepos.X, mousepos.Y)) do 
			if v.Active then
				return false
			end
		end
		for i,v in pairs(game:GetService("CoreGui"):GetGuiObjectsAtPosition(mousepos.X, mousepos.Y)) do 
			if v.Parent:IsA("ScreenGui") and v.Parent.Enabled then
				if v.Active then
					return false
				end
			end
		end
		return true
	end

	autoclicker = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
		Name = "AutoClicker",
		Function = function(callback)
			if callback then
				table.insert(autoclicker.Connections, inputService.InputBegan:Connect(function(input, gameProcessed)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						autoclickermousedown = true
						local firstClick = tick() + 0.1
						task.spawn(function()
							repeat
								task.wait()
								if entityLibrary.isAlive then
									if not autoclicker.Enabled or not autoclickermousedown then break end
									if not isNotHoveringOverGui() then continue end
									if getOpenApps() > (bedwarsStore.equippedKit == "hannah" and 4 or 3) then continue end
									if GuiLibrary.ObjectsThatCanBeSaved["Lobby CheckToggle"].Api.Enabled then
										if bedwarsStore.matchState == 0 then continue end
									end
									if bedwarsStore.localHand.Type == "sword" then
										if bedwars.KatanaController.chargingMaid == nil then
											task.spawn(function()
												if firstClick <= tick() then
													bedwars.SwordController:swingSwordAtMouse()
												else
													firstClick = tick()
												end
											end)
											task.wait(math.max((1 / autoclickercps.GetRandomValue()), noclickdelay.Enabled and 0 or (autoclickertimed.Enabled and 0.38 or 0)))
										end
									elseif bedwarsStore.localHand.Type == "block" then 
										if autoclickerblocks.Enabled and bedwars.BlockPlacementController.blockPlacer and firstClick <= tick() then
											if (workspace:GetServerTimeNow() - bedwars.BlockCpsController.lastPlaceTimestamp) > ((1 / 12) * 0.5) then
												local mouseinfo = bedwars.BlockPlacementController.blockPlacer.clientManager:getBlockSelector():getMouseInfo(0)
												if mouseinfo then
													task.spawn(function()
														if mouseinfo.placementPosition == mouseinfo.placementPosition then
															bedwars.BlockPlacementController.blockPlacer:placeBlock(mouseinfo.placementPosition)
														end
													end)
												end
												task.wait((1 / autoclickercps.GetRandomValue()))
											end
										end
									end
								end
							until not autoclicker.Enabled or not autoclickermousedown
						end)
					end
				end))
				table.insert(autoclicker.Connections, inputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						autoclickermousedown = false
					end
				end))
			end
		end,
		HoverText = "Hold attack button to automatically click"
	})
	autoclickercps = autoclicker.CreateTwoSlider({
		Name = "CPS",
		Min = 1,
		Max = 20,
		Function = function(val) end,
		Default = 8,
		Default2 = 12
	})
	autoclickertimed = autoclicker.CreateToggle({
		Name = "Timed",
		Function = function() end
	})
	autoclickerblocks = autoclicker.CreateToggle({
		Name = "Place Blocks", 
		Function = function() end, 
		Default = true,
		HoverText = "Automatically places blocks when left click is held."
	})

	local noclickfunc
	noclickdelay = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
		Name = "NoClickDelay",
		Function = function(callback)
			if callback then
				noclickfunc = bedwars.SwordController.isClickingTooFast
				bedwars.SwordController.isClickingTooFast = function(self) 
					self.lastSwing = tick()
					return false 
				end
			else
				bedwars.SwordController.isClickingTooFast = noclickfunc
			end
		end,
		HoverText = "Remove the CPS cap"
	})
end)

runFunction(function()
	local ReachValue = {Value = 14}
	Reach = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
		Name = "Reach",
		Function = function(callback)
			if callback then
				bedwars.CombatConstant.RAYCAST_SWORD_CHARACTER_DISTANCE = ReachValue.Value + 2
			else
				bedwars.CombatConstant.RAYCAST_SWORD_CHARACTER_DISTANCE = 14.4
			end
		end, 
		HoverText = "Extends attack reach"
	})
	ReachValue = Reach.CreateSlider({
		Name = "Reach",
		Min = 0,
		Max = 18,
		Function = function(val)
			if Reach.Enabled then
				bedwars.CombatConstant.RAYCAST_SWORD_CHARACTER_DISTANCE = val + 2
			end
		end,
		Default = 18
	})
end)

runFunction(function()
	local Sprint = {Enabled = false}
	local oldSprintFunction
	Sprint = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
		Name = "Sprint",
		Function = function(callback)
			if callback then
				if inputService.TouchEnabled then
					pcall(function() lplr.PlayerGui.MobileUI["2"].Visible = false end)
				end
				oldSprintFunction = bedwars.SprintController.stopSprinting
				bedwars.SprintController.stopSprinting = function(...)
					local originalCall = oldSprintFunction(...)
					bedwars.SprintController:startSprinting()
					return originalCall
				end
				table.insert(Sprint.Connections, lplr.CharacterAdded:Connect(function(char)
					char:WaitForChild("Humanoid", 9e9)
					task.wait(0.5)
					bedwars.SprintController:stopSprinting()
				end))
				task.spawn(function()
					bedwars.SprintController:startSprinting()
				end)
			else
				if inputService.TouchEnabled then
					pcall(function() lplr.PlayerGui.MobileUI["2"].Visible = true end)
				end
				bedwars.SprintController.stopSprinting = oldSprintFunction
				bedwars.SprintController:stopSprinting()
			end
		end,
		HoverText = "Sets your sprinting to true."
	})
end)

runFunction(function()
	local Velocity = {Enabled = false}
	local VelocityHorizontal = {Value = 100}
	local VelocityVertical = {Value = 100}
	local applyKnockback
	Velocity = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
		Name = "Velocity",
		Function = function(callback)
			if callback then
				applyKnockback = bedwars.KnockbackUtil.applyKnockback
				bedwars.KnockbackUtil.applyKnockback = function(root, mass, dir, knockback, ...)
					knockback = knockback or {}
					if VelocityHorizontal.Value == 0 and VelocityVertical.Value == 0 then return end
					knockback.horizontal = (knockback.horizontal or 1) * (VelocityHorizontal.Value / 100)
					knockback.vertical = (knockback.vertical or 1) * (VelocityVertical.Value / 100)
					return applyKnockback(root, mass, dir, knockback, ...)
				end
			else
				bedwars.KnockbackUtil.applyKnockback = applyKnockback
			end
		end,
		HoverText = "Reduces knockback taken"
	})
	VelocityHorizontal = Velocity.CreateSlider({
		Name = "Horizontal",
		Min = 0,
		Max = 100,
		Percent = true,
		Function = function(val) end,
		Default = 0
	})
	VelocityVertical = Velocity.CreateSlider({
		Name = "Vertical",
		Min = 0,
		Max = 100,
		Percent = true,
		Function = function(val) end,
		Default = 0
	})
end)

runFunction(function()
	local AutoLeaveDelay = {Value = 1}
	local AutoPlayAgain = {Enabled = false}
	local AutoLeaveStaff = {Enabled = true}
	local AutoLeaveStaff2 = {Enabled = true}
	local AutoLeaveRandom = {Enabled = false}
	local leaveAttempted = false

	local function getRole(plr)
		local suc, res = pcall(function() return plr:GetRankInGroup(5774246) end)
		if not suc then 
			repeat
				suc, res = pcall(function() return plr:GetRankInGroup(5774246) end)
				task.wait()
			until suc
		end
		if plr.UserId == 1774814725 then 
			return 200
		end
		return res
	end

	local flyAllowedmodules = {"Sprint", "AutoClicker", "AutoReport", "AutoReportV2", "AutoRelic", "AimAssist", "AutoLeave", "Reach"}
	local function autoLeaveAdded(plr)
		task.spawn(function()
			if not shared.VapeFullyLoaded then
				repeat task.wait() until shared.VapeFullyLoaded
			end
			if getRole(plr) >= 100 then
				if AutoLeaveStaff.Enabled then
					if #bedwars.ClientStoreHandler:getState().Party.members > 0 then 
						bedwars.LobbyClientEvents.leaveParty()
					end
					if AutoLeaveStaff2.Enabled then 
						warningNotification("Vape", "Staff Detected : "..(plr.DisplayName and plr.DisplayName.." ("..plr.Name..")" or plr.Name).." : Play legit like nothing happened to have the highest chance of not getting banned.", 60)
						GuiLibrary.SaveSettings = function() end
						for i,v in pairs(GuiLibrary.ObjectsThatCanBeSaved) do 
							if v.Type == "OptionsButton" then
								if table.find(flyAllowedmodules, i:gsub("OptionsButton", "")) == nil and tostring(v.Object.Parent.Parent):find("Render") == nil then
									if v.Api.Enabled then
										v.Api.ToggleButton(false)
									end
									v.Api.SetKeybind("")
									v.Object.TextButton.Visible = false
								end
							end
						end
					else
						GuiLibrary.SelfDestruct()
						game:GetService("StarterGui"):SetCore("SendNotification", {
							Title = "Vape",
							Text = "Staff Detected\n"..(plr.DisplayName and plr.DisplayName.." ("..plr.Name..")" or plr.Name),
							Duration = 60,
						})
					end
					return
				else
					warningNotification("Vape", "Staff Detected : "..(plr.DisplayName and plr.DisplayName.." ("..plr.Name..")" or plr.Name), 60)
				end
			end
		end)
	end

	local function isEveryoneDead()
		if #bedwars.ClientStoreHandler:getState().Party.members > 0 then
			for i,v in pairs(bedwars.ClientStoreHandler:getState().Party.members) do
				local plr = playersService:FindFirstChild(v.name)
				if plr and isAlive(plr, true) then
					return false
				end
			end
			return true
		else
			return true
		end
	end

	AutoLeave = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "AutoLeave", 
		Function = function(callback)
			if callback then
				table.insert(AutoLeave.Connections, vapeEvents.EntityDeathEvent.Event:Connect(function(deathTable)
					if (not leaveAttempted) and deathTable.finalKill and deathTable.entityInstance == lplr.Character then
						leaveAttempted = true
						if isEveryoneDead() and bedwarsStore.matchState ~= 2 then
							task.wait(1 + (AutoLeaveDelay.Value / 10))
							if bedwars.ClientStoreHandler:getState().Game.customMatch == nil and bedwars.ClientStoreHandler:getState().Party.leader.userId == lplr.UserId then
								if not AutoPlayAgain.Enabled then
									bedwars.ClientHandler:Get("TeleportToLobby"):SendToServer()
								else
									if AutoLeaveRandom.Enabled then 
										local listofmodes = {}
										for i,v in pairs(bedwars.QueueMeta) do
											if not v.disabled and not v.voiceChatOnly and not v.rankCategory then table.insert(listofmodes, i) end
										end
										bedwars.LobbyClientEvents:joinQueue(listofmodes[math.random(1, #listofmodes)])
									else
										bedwars.LobbyClientEvents:joinQueue(bedwarsStore.queueType)
									end
								end
							end
						end
					end
				end))
				table.insert(AutoLeave.Connections, vapeEvents.MatchEndEvent.Event:Connect(function(deathTable)
					task.wait(AutoLeaveDelay.Value / 10)
					if not AutoLeave.Enabled then return end
					if leaveAttempted then return end
					leaveAttempted = true
					if bedwars.ClientStoreHandler:getState().Game.customMatch == nil and bedwars.ClientStoreHandler:getState().Party.leader.userId == lplr.UserId then
						if not AutoPlayAgain.Enabled then
							bedwars.ClientHandler:Get("TeleportToLobby"):SendToServer()
						else
							if bedwars.ClientStoreHandler:getState().Party.queueState == 0 then
								if AutoLeaveRandom.Enabled then 
									local listofmodes = {}
									for i,v in pairs(bedwars.QueueMeta) do
										if not v.disabled and not v.voiceChatOnly and not v.rankCategory then table.insert(listofmodes, i) end
									end
									bedwars.LobbyClientEvents:joinQueue(listofmodes[math.random(1, #listofmodes)])
								else
									bedwars.LobbyClientEvents:joinQueue(bedwarsStore.queueType)
								end
							end
						end
					end
				end))
				table.insert(AutoLeave.Connections, playersService.PlayerAdded:Connect(autoLeaveAdded))
				for i, plr in pairs(playersService:GetPlayers()) do
					autoLeaveAdded(plr)
				end
			end
		end,
		HoverText = "Leaves if a staff member joins your game or when the match ends."
	})
	AutoLeaveDelay = AutoLeave.CreateSlider({
		Name = "Delay",
		Min = 0,
		Max = 50,
		Default = 0,
		Function = function() end,
		HoverText = "Delay before going back to the hub."
	})
	AutoPlayAgain = AutoLeave.CreateToggle({
		Name = "Play Again",
		Function = function() end,
		HoverText = "Automatically queues a new game.",
		Default = true
	})
	AutoLeaveStaff = AutoLeave.CreateToggle({
		Name = "Staff",
		Function = function(callback) 
			if AutoLeaveStaff2.Object then 
				AutoLeaveStaff2.Object.Visible = callback
			end
		end,
		HoverText = "Automatically uninjects when staff joins",
		Default = true
	})
	AutoLeaveStaff2 = AutoLeave.CreateToggle({
		Name = "Staff AutoConfig",
		Function = function() end,
		HoverText = "Instead of uninjecting, It will now reconfig vape temporarily to a more legit config.",
		Default = true
	})
	AutoLeaveRandom = AutoLeave.CreateToggle({
		Name = "Random",
		Function = function(callback) end,
		HoverText = "Chooses a random mode"
	})
	AutoLeaveStaff2.Object.Visible = false
end)

runFunction(function()
	local oldclickhold
	local oldclickhold2
	local roact 
	local FastConsume = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "FastConsume",
		Function = function(callback)
			if callback then
				oldclickhold = bedwars.ClickHold.startClick
				oldclickhold2 = bedwars.ClickHold.showProgress
				bedwars.ClickHold.showProgress = function(p5)
					local roact = debug.getupvalue(oldclickhold2, 1)
					local countdown = roact.mount(roact.createElement("ScreenGui", {}, { roact.createElement("Frame", {
						[roact.Ref] = p5.wrapperRef, 
						Size = UDim2.new(0, 0, 0, 0), 
						Position = UDim2.new(0.5, 0, 0.55, 0), 
						AnchorPoint = Vector2.new(0.5, 0), 
						BackgroundColor3 = Color3.fromRGB(0, 0, 0), 
						BackgroundTransparency = 0.8
					}, { roact.createElement("Frame", {
							[roact.Ref] = p5.progressRef, 
							Size = UDim2.new(0, 0, 1, 0), 
							BackgroundColor3 = Color3.fromRGB(255, 255, 255), 
							BackgroundTransparency = 0.5
						}) }) }), lplr:FindFirstChild("PlayerGui"))
					p5.handle = countdown
					local sizetween = tweenService:Create(p5.wrapperRef:getValue(), TweenInfo.new(0.1), {
						Size = UDim2.new(0.11, 0, 0.005, 0)
					})
					table.insert(p5.tweens, sizetween)
					sizetween:Play()
					local countdowntween = tweenService:Create(p5.progressRef:getValue(), TweenInfo.new(p5.durationSeconds * (FastConsumeVal.Value / 40), Enum.EasingStyle.Linear), {
						Size = UDim2.new(1, 0, 1, 0)
					})
					table.insert(p5.tweens, countdowntween)
					countdowntween:Play()
					return countdown
				end
				bedwars.ClickHold.startClick = function(p4)
					p4.startedClickTime = tick()
					local u2 = p4:showProgress()
					local clicktime = p4.startedClickTime
					bedwars.RuntimeLib.Promise.defer(function()
						task.wait(p4.durationSeconds * (FastConsumeVal.Value / 40))
						if u2 == p4.handle and clicktime == p4.startedClickTime and p4.closeOnComplete then
							p4:hideProgress()
							if p4.onComplete ~= nil then
								p4.onComplete()
							end
							if p4.onPartialComplete ~= nil then
								p4.onPartialComplete(1)
							end
							p4.startedClickTime = -1
						end
					end)
				end
			else
				bedwars.ClickHold.startClick = oldclickhold
				bedwars.ClickHold.showProgress = oldclickhold2
				oldclickhold = nil
				oldclickhold2 = nil
			end
		end,
		HoverText = "Use/Consume items quicker."
	})
	FastConsumeVal = FastConsume.CreateSlider({
		Name = "Ticks",
		Min = 0,
		Max = 40,
		Default = 0,
		Function = function() end
	})
end)

local autobankballoon = false
runFunction(function()
	local Fly = {Enabled = false}
	local FlyMode = {Value = "CFrame"}
	local FlyVerticalSpeed = {Value = 40}
	local FlyVertical = {Enabled = true}
	local FlyAutoPop = {Enabled = true}
	local FlyAnyway = {Enabled = false}
	local FlyAnywayProgressBar = {Enabled = false}
	local FlyDamageAnimation = {Enabled = false}
	local FlyTP = {Enabled = false}
	local FlyAnywayProgressBarFrame
	local olddeflate
	local FlyUp = false
	local FlyDown = false
	local FlyCoroutine
	local groundtime = tick()
	local onground = false
	local lastonground = false
	local alternatelist = {"Normal", "AntiCheat A", "AntiCheat B"}

	local function inflateBalloon()
		if not Fly.Enabled then return end
		if entityLibrary.isAlive and (lplr.Character:GetAttribute("InflatedBalloons") or 0) < 1 then
			autobankballoon = true
			if getItem("balloon") then
				bedwars.BalloonController:inflateBalloon()
				return true
			end
		end
		return false
	end

	Fly = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "Fly",
		Function = function(callback)
			if callback then
				olddeflate = bedwars.BalloonController.deflateBalloon
				bedwars.BalloonController.deflateBalloon = function() end

				table.insert(Fly.Connections, inputService.InputBegan:Connect(function(input1)
					if FlyVertical.Enabled and inputService:GetFocusedTextBox() == nil then
						if input1.KeyCode == Enum.KeyCode.Space or input1.KeyCode == Enum.KeyCode.ButtonA then
							FlyUp = true
						end
						if input1.KeyCode == Enum.KeyCode.LeftShift or input1.KeyCode == Enum.KeyCode.ButtonL2 then
							FlyDown = true
						end
					end
				end))
				table.insert(Fly.Connections, inputService.InputEnded:Connect(function(input1)
					if input1.KeyCode == Enum.KeyCode.Space or input1.KeyCode == Enum.KeyCode.ButtonA then
						FlyUp = false
					end
					if input1.KeyCode == Enum.KeyCode.LeftShift or input1.KeyCode == Enum.KeyCode.ButtonL2 then
						FlyDown = false
					end
				end))
				if inputService.TouchEnabled then
					pcall(function()
						local jumpButton = lplr.PlayerGui.TouchGui.TouchControlFrame.JumpButton
						table.insert(Fly.Connections, jumpButton:GetPropertyChangedSignal("ImageRectOffset"):Connect(function()
							FlyUp = jumpButton.ImageRectOffset.X == 146
						end))
						FlyUp = jumpButton.ImageRectOffset.X == 146
					end)
				end
				table.insert(Fly.Connections, vapeEvents.BalloonPopped.Event:Connect(function(poppedTable)
					if poppedTable.inflatedBalloon and poppedTable.inflatedBalloon:GetAttribute("BalloonOwner") == lplr.UserId then 
						lastonground = not onground
						repeat task.wait() until (lplr.Character:GetAttribute("InflatedBalloons") or 0) <= 0 or not Fly.Enabled
						inflateBalloon() 
					end
				end))
				table.insert(Fly.Connections, vapeEvents.AutoBankBalloon.Event:Connect(function()
					repeat task.wait() until getItem("balloon")
					inflateBalloon()
				end))

				local balloons
				if entityLibrary.isAlive and (not bedwarsStore.queueType:find("mega")) then
					balloons = inflateBalloon()
				end
				local megacheck = bedwarsStore.queueType:find("mega") or bedwarsStore.queueType == "winter_event"

				task.spawn(function()
					repeat task.wait() until bedwarsStore.queueType ~= "bedwars_test" or (not Fly.Enabled)
					if not Fly.Enabled then return end
					megacheck = bedwarsStore.queueType:find("mega") or bedwarsStore.queueType == "winter_event"
				end)

				local flyAllowed = entityLibrary.isAlive and ((lplr.Character:GetAttribute("InflatedBalloons") and lplr.Character:GetAttribute("InflatedBalloons") > 0) or bedwarsStore.matchState == 2 or megacheck) and 1 or 0
				if flyAllowed <= 0 and shared.damageanim and (not balloons) then 
					shared.damageanim()
					bedwars.SoundManager:playSound(bedwars.SoundList["DAMAGE_"..math.random(1, 3)])
				end

				if FlyAnywayProgressBarFrame and flyAllowed <= 0 and (not balloons) then 
					FlyAnywayProgressBarFrame.Visible = true
					FlyAnywayProgressBarFrame.Frame:TweenSize(UDim2.new(1, 0, 0, 20), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0, true)
				end

				groundtime = tick() + (2.6 + (entityLibrary.groundTick - tick()))
				FlyCoroutine = coroutine.create(function()
					repeat
						repeat task.wait() until (groundtime - tick()) < 0.6 and not onground
						flyAllowed = ((lplr.Character and lplr.Character:GetAttribute("InflatedBalloons") and lplr.Character:GetAttribute("InflatedBalloons") > 0) or bedwarsStore.matchState == 2 or megacheck) and 1 or 0
						if (not Fly.Enabled) then break end
						local Flytppos = -99999
						if flyAllowed <= 0 and FlyTP.Enabled and entityLibrary.isAlive then 
							local ray = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, Vector3.new(0, -1000, 0), bedwarsStore.blockRaycast)
							if ray then 
								Flytppos = entityLibrary.character.HumanoidRootPart.Position.Y
								local args = {entityLibrary.character.HumanoidRootPart.CFrame:GetComponents()}
								args[2] = ray.Position.Y + (entityLibrary.character.HumanoidRootPart.Size.Y / 2) + entityLibrary.character.Humanoid.HipHeight
								entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(unpack(args))
								task.wait(0.12)
								if (not Fly.Enabled) then break end
								flyAllowed = ((lplr.Character and lplr.Character:GetAttribute("InflatedBalloons") and lplr.Character:GetAttribute("InflatedBalloons") > 0) or bedwarsStore.matchState == 2 or megacheck) and 1 or 0
								if flyAllowed <= 0 and Flytppos ~= -99999 and entityLibrary.isAlive then 
									local args = {entityLibrary.character.HumanoidRootPart.CFrame:GetComponents()}
									args[2] = Flytppos
									entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(unpack(args))
								end
							end
						end
					until (not Fly.Enabled)
				end)
				coroutine.resume(FlyCoroutine)

				RunLoops:BindToHeartbeat("Fly", function(delta) 
					if GuiLibrary.ObjectsThatCanBeSaved["Lobby CheckToggle"].Api.Enabled then 
						if bedwars.matchState == 0 then return end
					end
					if entityLibrary.isAlive then
						local playerMass = (entityLibrary.character.HumanoidRootPart:GetMass() - 1.4) * (delta * 100)
						flyAllowed = ((lplr.Character:GetAttribute("InflatedBalloons") and lplr.Character:GetAttribute("InflatedBalloons") > 0) or bedwarsStore.matchState == 2 or megacheck) and 1 or 0
						playerMass = playerMass + (flyAllowed > 0 and 4 or 0) * (tick() % 0.4 < 0.2 and -1 or 1)

						if FlyAnywayProgressBarFrame then
							FlyAnywayProgressBarFrame.Visible = flyAllowed <= 0
							FlyAnywayProgressBarFrame.BackgroundColor3 = Color3.fromHSV(GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Hue, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Sat, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Value)
							FlyAnywayProgressBarFrame.Frame.BackgroundColor3 = Color3.fromHSV(GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Hue, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Sat, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Value)
						end

						if flyAllowed <= 0 then 
							local newray = getPlacedBlock(entityLibrary.character.HumanoidRootPart.Position + Vector3.new(0, (entityLibrary.character.Humanoid.HipHeight * -2) - 1, 0))
							onground = newray and true or false
							if lastonground ~= onground then 
								if (not onground) then 
									groundtime = tick() + (2.6 + (entityLibrary.groundTick - tick()))
									if FlyAnywayProgressBarFrame then 
										FlyAnywayProgressBarFrame.Frame:TweenSize(UDim2.new(0, 0, 0, 20), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, groundtime - tick(), true)
									end
								else
									if FlyAnywayProgressBarFrame then 
										FlyAnywayProgressBarFrame.Frame:TweenSize(UDim2.new(1, 0, 0, 20), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0, true)
									end
								end
							end
							if FlyAnywayProgressBarFrame then 
								FlyAnywayProgressBarFrame.TextLabel.Text = math.max(onground and 2.5 or math.floor((groundtime - tick()) * 10) / 10, 0).."s"
							end
							lastonground = onground
						else
							onground = true
							lastonground = true
						end

						local flyVelocity = entityLibrary.character.Humanoid.MoveDirection * (FlyMode.Value == "Normal" and FlySpeed.Value or 20)
						entityLibrary.character.HumanoidRootPart.Velocity = flyVelocity + (Vector3.new(0, playerMass + (FlyUp and FlyVerticalSpeed.Value or 0) + (FlyDown and -FlyVerticalSpeed.Value or 0), 0))
						if FlyMode.Value ~= "Normal" then
							entityLibrary.character.HumanoidRootPart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame + (entityLibrary.character.Humanoid.MoveDirection * ((FlySpeed.Value + getSpeed()) - 20)) * delta
						end
					end
				end)
			else
				pcall(function() coroutine.close(FlyCoroutine) end)
				autobankballoon = false
				waitingforballoon = false
				lastonground = nil
				FlyUp = false
				FlyDown = false
				RunLoops:UnbindFromHeartbeat("Fly")
				if FlyAnywayProgressBarFrame then 
					FlyAnywayProgressBarFrame.Visible = false
				end
				if FlyAutoPop.Enabled then
					if entityLibrary.isAlive and lplr.Character:GetAttribute("InflatedBalloons") then
						for i = 1, lplr.Character:GetAttribute("InflatedBalloons") do
							olddeflate()
						end
					end
				end
				bedwars.BalloonController.deflateBalloon = olddeflate
				olddeflate = nil
			end
		end,
		HoverText = "Makes you go zoom (longer Fly discovered by exelys and Cqded)",
		ExtraText = function() 
			return "Heatseeker"
		end
	})
	FlySpeed = Fly.CreateSlider({
		Name = "Speed",
		Min = 1,
		Max = 23,
		Function = function(val) end, 
		Default = 23
	})
	FlyVerticalSpeed = Fly.CreateSlider({
		Name = "Vertical Speed",
		Min = 1,
		Max = 100,
		Function = function(val) end, 
		Default = 44
	})
	FlyVertical = Fly.CreateToggle({
		Name = "Y Level",
		Function = function() end, 
		Default = true
	})
	FlyAutoPop = Fly.CreateToggle({
		Name = "Pop Balloon",
		Function = function() end, 
		HoverText = "Pops balloons when Fly is disabled."
	})
	local oldcamupdate
	local camcontrol
	local Flydamagecamera = {Enabled = false}
	FlyDamageAnimation = Fly.CreateToggle({
		Name = "Damage Animation",
		Function = function(callback) 
			if Flydamagecamera.Object then 
				Flydamagecamera.Object.Visible = callback
			end
			if callback then 
				task.spawn(function()
					repeat
						task.wait(0.1)
						for i,v in pairs(getconnections(gameCamera:GetPropertyChangedSignal("CameraType"))) do 
							if v.Function then
								camcontrol = debug.getupvalue(v.Function, 1)
							end
						end
					until camcontrol
					local caminput = require(lplr.PlayerScripts.PlayerModule.CameraModule.CameraInput)
					local num = Instance.new("IntValue")
					local numanim
					shared.damageanim = function()
						if numanim then numanim:Cancel() end
						if Flydamagecamera.Enabled then
							num.Value = 1000
							numanim = tweenService:Create(num, TweenInfo.new(0.5), {Value = 0})
							numanim:Play()
						end
					end
					oldcamupdate = camcontrol.Update
					camcontrol.Update = function(self, dt) 
						if camcontrol.activeCameraController then
							camcontrol.activeCameraController:UpdateMouseBehavior()
							local newCameraCFrame, newCameraFocus = camcontrol.activeCameraController:Update(dt)
							gameCamera.CFrame = newCameraCFrame * CFrame.Angles(0, 0, math.rad(num.Value / 100))
							gameCamera.Focus = newCameraFocus
							if camcontrol.activeTransparencyController then
								camcontrol.activeTransparencyController:Update(dt)
							end
							if caminput.getInputEnabled() then
								caminput.resetInputForFrameEnd()
							end
						end
					end
				end)
			else
				shared.damageanim = nil
				if camcontrol then 
					camcontrol.Update = oldcamupdate
				end
			end
		end
	})
	Flydamagecamera = Fly.CreateToggle({
		Name = "Camera Animation",
		Function = function() end,
		Default = true
	})
	Flydamagecamera.Object.BorderSizePixel = 0
	Flydamagecamera.Object.BackgroundTransparency = 0
	Flydamagecamera.Object.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	Flydamagecamera.Object.Visible = false
	FlyAnywayProgressBar = Fly.CreateToggle({
		Name = "Progress Bar",
		Function = function(callback) 
			if callback then 
				FlyAnywayProgressBarFrame = Instance.new("Frame")
				FlyAnywayProgressBarFrame.AnchorPoint = Vector2.new(0.5, 0)
				FlyAnywayProgressBarFrame.Position = UDim2.new(0.5, 0, 1, -200)
				FlyAnywayProgressBarFrame.Size = UDim2.new(0.2, 0, 0, 20)
				FlyAnywayProgressBarFrame.BackgroundTransparency = 0.5
				FlyAnywayProgressBarFrame.BorderSizePixel = 0
				FlyAnywayProgressBarFrame.BackgroundColor3 = Color3.new(0, 0, 0)
				FlyAnywayProgressBarFrame.Visible = Fly.Enabled
				FlyAnywayProgressBarFrame.Parent = GuiLibrary.MainGui
				local FlyAnywayProgressBarFrame2 = FlyAnywayProgressBarFrame:Clone()
				FlyAnywayProgressBarFrame2.AnchorPoint = Vector2.new(0, 0)
				FlyAnywayProgressBarFrame2.Position = UDim2.new(0, 0, 0, 0)
				FlyAnywayProgressBarFrame2.Size = UDim2.new(1, 0, 0, 20)
				FlyAnywayProgressBarFrame2.BackgroundTransparency = 0
				FlyAnywayProgressBarFrame2.Visible = true
				FlyAnywayProgressBarFrame2.Parent = FlyAnywayProgressBarFrame
				local FlyAnywayProgressBartext = Instance.new("TextLabel")
				FlyAnywayProgressBartext.Text = "2s"
				FlyAnywayProgressBartext.Font = Enum.Font.Gotham
				FlyAnywayProgressBartext.TextStrokeTransparency = 0
				FlyAnywayProgressBartext.TextColor3 =  Color3.new(0.9, 0.9, 0.9)
				FlyAnywayProgressBartext.TextSize = 20
				FlyAnywayProgressBartext.Size = UDim2.new(1, 0, 1, 0)
				FlyAnywayProgressBartext.BackgroundTransparency = 1
				FlyAnywayProgressBartext.Position = UDim2.new(0, 0, -1, 0)
				FlyAnywayProgressBartext.Parent = FlyAnywayProgressBarFrame
			else
				if FlyAnywayProgressBarFrame then FlyAnywayProgressBarFrame:Destroy() FlyAnywayProgressBarFrame = nil end
			end
		end,
		HoverText = "show amount of Fly time",
		Default = true
	})
	FlyTP = Fly.CreateToggle({
		Name = "TP Down",
		Function = function() end,
		Default = true
	})
end)

runFunction(function()
	local GrappleExploit = {Enabled = false}
	local GrappleExploitMode = {Value = "Normal"}
	local GrappleExploitVerticalSpeed = {Value = 40}
	local GrappleExploitVertical = {Enabled = true}
	local GrappleExploitUp = false
	local GrappleExploitDown = false
	local alternatelist = {"Normal", "AntiCheat A", "AntiCheat B"}
	local projectileRemote = bedwars.ClientHandler:Get(bedwars.ProjectileRemote)

	--me when I have to fix bw code omegalol
	bedwars.ClientHandler:Get("GrapplingHookFunctions"):Connect(function(p4)
		if p4.hookFunction == "PLAYER_IN_TRANSIT" then
			bedwars.CooldownController:setOnCooldown("grappling_hook", 3.5)
		end
	end)

	GrappleExploit = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "GrappleExploit",
		Function = function(callback)
			if callback then
				local grappleHooked = false
				table.insert(GrappleExploit.Connections, bedwars.ClientHandler:Get("GrapplingHookFunctions"):Connect(function(p4)
					if p4.hookFunction == "PLAYER_IN_TRANSIT" then
						bedwarsStore.grapple = tick() + 1.8
						grappleHooked = true
						GrappleExploit.ToggleButton(false)
					end
				end))

				local fireball = getItem("grappling_hook")
				if fireball then 
					task.spawn(function()
						repeat task.wait() until bedwars.CooldownController:getRemainingCooldown("grappling_hook") == 0 or (not GrappleExploit.Enabled)
						if (not GrappleExploit.Enabled) then return end
						switchItem(fireball.tool)
						local pos = entityLibrary.character.HumanoidRootPart.CFrame.p
						local offsetshootpos = (CFrame.new(pos, pos + Vector3.new(0, -60, 0)) * CFrame.new(Vector3.new(-bedwars.BowConstantsTable.RelX, -bedwars.BowConstantsTable.RelY, -bedwars.BowConstantsTable.RelZ))).p
						projectileRemote:CallServerAsync(fireball["tool"], nil, "grappling_hook_projectile", offsetshootpos, pos, Vector3.new(0, -60, 0), game:GetService("HttpService"):GenerateGUID(true), {drawDurationSeconds = 1}, workspace:GetServerTimeNow() - 0.045)
					end)
				else
					warningNotification("GrappleExploit", "missing grapple hook", 3)
					GrappleExploit.ToggleButton(false)
					return
				end

				local startCFrame = entityLibrary.isAlive and entityLibrary.character.HumanoidRootPart.CFrame
				RunLoops:BindToHeartbeat("GrappleExploit", function(delta) 
					if GuiLibrary.ObjectsThatCanBeSaved["Lobby CheckToggle"].Api.Enabled then 
						if bedwars.matchState == 0 then return end
					end
					if entityLibrary.isAlive then
						entityLibrary.character.HumanoidRootPart.Velocity = Vector3.zero
						entityLibrary.character.HumanoidRootPart.CFrame = startCFrame
					end
				end)
			else
				GrappleExploitUp = false
				GrappleExploitDown = false
				RunLoops:UnbindFromHeartbeat("GrappleExploit")
			end
		end,
		HoverText = "Makes you go zoom (longer GrappleExploit discovered by exelys and Cqded)",
		ExtraText = function() 
			if GuiLibrary.ObjectsThatCanBeSaved["Text GUIAlternate TextToggle"]["Api"].Enabled then 
				return alternatelist[table.find(GrappleExploitMode["List"], GrappleExploitMode.Value)]
			end
			return GrappleExploitMode.Value 
		end
	})
end)

runFunction(function()
	local InfiniteFly = {Enabled = false}
	local InfiniteFlyMode = {Value = "CFrame"}
	local InfiniteFlySpeed = {Value = 23}
	local InfiniteFlyVerticalSpeed = {Value = 40}
	local InfiniteFlyVertical = {Enabled = true}
	local InfiniteFlyUp = false
	local InfiniteFlyDown = false
	local alternatelist = {"Normal", "AntiCheat A", "AntiCheat B"}
	local clonesuccess = false
	local disabledproper = true
	local oldcloneroot
	local cloned
	local clone
	local bodyvelo
	local FlyOverlap = OverlapParams.new()
	FlyOverlap.MaxParts = 9e9
	FlyOverlap.FilterDescendantsInstances = {}
	FlyOverlap.RespectCanCollide = true

	local function disablefunc()
		if bodyvelo then bodyvelo:Destroy() end
		RunLoops:UnbindFromHeartbeat("InfiniteFlyOff")
		disabledproper = true
		if not oldcloneroot or not oldcloneroot.Parent then return end
		lplr.Character.Parent = game
		oldcloneroot.Parent = lplr.Character
		lplr.Character.PrimaryPart = oldcloneroot
		lplr.Character.Parent = workspace
		oldcloneroot.CanCollide = true
		for i,v in pairs(lplr.Character:GetDescendants()) do 
			if v:IsA("Weld") or v:IsA("Motor6D") then 
				if v.Part0 == clone then v.Part0 = oldcloneroot end
				if v.Part1 == clone then v.Part1 = oldcloneroot end
			end
			if v:IsA("BodyVelocity") then 
				v:Destroy()
			end
		end
		for i,v in pairs(oldcloneroot:GetChildren()) do 
			if v:IsA("BodyVelocity") then 
				v:Destroy()
			end
		end
		local oldclonepos = clone.Position.Y
		if clone then 
			clone:Destroy()
			clone = nil
		end
		lplr.Character.Humanoid.HipHeight = hip or 2
		local origcf = {oldcloneroot.CFrame:GetComponents()}
		origcf[2] = oldclonepos
		oldcloneroot.CFrame = CFrame.new(unpack(origcf))
		oldcloneroot = nil
	end

	InfiniteFly = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "InfiniteFly",
		Function = function(callback)
			if callback then
				if not entityLibrary.isAlive then 
					disabledproper = true
				end
				if not disabledproper then 
					warningNotification("InfiniteFly", "Wait for the last fly to finish", 3)
					InfiniteFly.ToggleButton(false)
					return 
				end
				table.insert(InfiniteFly.Connections, inputService.InputBegan:Connect(function(input1)
					if InfiniteFlyVertical.Enabled and inputService:GetFocusedTextBox() == nil then
						if input1.KeyCode == Enum.KeyCode.Space or input1.KeyCode == Enum.KeyCode.ButtonA then
							InfiniteFlyUp = true
						end
						if input1.KeyCode == Enum.KeyCode.LeftShift or input1.KeyCode == Enum.KeyCode.ButtonL2 then
							InfiniteFlyDown = true
						end
					end
				end))
				table.insert(InfiniteFly.Connections, inputService.InputEnded:Connect(function(input1)
					if input1.KeyCode == Enum.KeyCode.Space or input1.KeyCode == Enum.KeyCode.ButtonA then
						InfiniteFlyUp = false
					end
					if input1.KeyCode == Enum.KeyCode.LeftShift or input1.KeyCode == Enum.KeyCode.ButtonL2 then
						InfiniteFlyDown = false
					end
				end))
				if inputService.TouchEnabled then
					pcall(function()
						local jumpButton = lplr.PlayerGui.TouchGui.TouchControlFrame.JumpButton
						table.insert(InfiniteFly.Connections, jumpButton:GetPropertyChangedSignal("ImageRectOffset"):Connect(function()
							InfiniteFlyUp = jumpButton.ImageRectOffset.X == 146
						end))
						InfiniteFlyUp = jumpButton.ImageRectOffset.X == 146
					end)
				end
				clonesuccess = false
				if entityLibrary.isAlive and entityLibrary.character.Humanoid.Health > 0 and isnetworkowner(entityLibrary.character.HumanoidRootPart) then
					cloned = lplr.Character
					oldcloneroot = entityLibrary.character.HumanoidRootPart
					if not lplr.Character.Parent then 
						InfiniteFly.ToggleButton(false)
						return
					end
					lplr.Character.Parent = game
					clone = oldcloneroot:Clone()
					clone.Parent = lplr.Character
					oldcloneroot.Parent = gameCamera
					bedwars.QueryUtil:setQueryIgnored(oldcloneroot, true)
					clone.CFrame = oldcloneroot.CFrame
					lplr.Character.PrimaryPart = clone
					lplr.Character.Parent = workspace
					for i,v in pairs(lplr.Character:GetDescendants()) do 
						if v:IsA("Weld") or v:IsA("Motor6D") then 
							if v.Part0 == oldcloneroot then v.Part0 = clone end
							if v.Part1 == oldcloneroot then v.Part1 = clone end
						end
						if v:IsA("BodyVelocity") then 
							v:Destroy()
						end
					end
					for i,v in pairs(oldcloneroot:GetChildren()) do 
						if v:IsA("BodyVelocity") then 
							v:Destroy()
						end
					end
					if hip then 
						lplr.Character.Humanoid.HipHeight = hip
					end
					hip = lplr.Character.Humanoid.HipHeight
					clonesuccess = true
				end
				if not clonesuccess then 
					warningNotification("InfiniteFly", "Character missing", 3)
					InfiniteFly.ToggleButton(false)
					return 
				end
				local goneup = false
				RunLoops:BindToHeartbeat("InfiniteFly", function(delta) 
					if GuiLibrary.ObjectsThatCanBeSaved["Lobby CheckToggle"].Api.Enabled then 
						if bedwarsStore.matchState == 0 then return end
					end
					if entityLibrary.isAlive then
						if isnetworkowner(oldcloneroot) then 
							local playerMass = (entityLibrary.character.HumanoidRootPart:GetMass() - 1.4) * (delta * 100)
							
							local flyVelocity = entityLibrary.character.Humanoid.MoveDirection * (InfiniteFlyMode.Value == "Normal" and InfiniteFlySpeed.Value or 20)
							entityLibrary.character.HumanoidRootPart.Velocity = flyVelocity + (Vector3.new(0, playerMass + (InfiniteFlyUp and InfiniteFlyVerticalSpeed.Value or 0) + (InfiniteFlyDown and -InfiniteFlyVerticalSpeed.Value or 0), 0))
							if InfiniteFlyMode.Value ~= "Normal" then
								entityLibrary.character.HumanoidRootPart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame + (entityLibrary.character.Humanoid.MoveDirection * ((InfiniteFlySpeed.Value + getSpeed()) - 20)) * delta
							end

							local speedCFrame = {oldcloneroot.CFrame:GetComponents()}
							speedCFrame[1] = clone.CFrame.X
							if speedCFrame[2] < 1000 or (not goneup) then 
								task.spawn(warningNotification, "InfiniteFly", "Teleported Up", 3)
								speedCFrame[2] = 100000
								goneup = true
							end
							speedCFrame[3] = clone.CFrame.Z
							oldcloneroot.CFrame = CFrame.new(unpack(speedCFrame))
							oldcloneroot.Velocity = Vector3.new(clone.Velocity.X, oldcloneroot.Velocity.Y, clone.Velocity.Z)
						else
							InfiniteFly.ToggleButton(false)
						end
					end
				end)
			else
				RunLoops:UnbindFromHeartbeat("InfiniteFly")
				if clonesuccess and oldcloneroot and clone and lplr.Character.Parent == workspace and oldcloneroot.Parent ~= nil and disabledproper and cloned == lplr.Character then 
					local rayparams = RaycastParams.new()
					rayparams.FilterDescendantsInstances = {lplr.Character, gameCamera}
					rayparams.RespectCanCollide = true
					local ray = workspace:Raycast(Vector3.new(oldcloneroot.Position.X, clone.CFrame.p.Y, oldcloneroot.Position.Z), Vector3.new(0, -1000, 0), rayparams)
					local origcf = {clone.CFrame:GetComponents()}
					origcf[1] = oldcloneroot.Position.X
					origcf[2] = ray and ray.Position.Y + (entityLibrary.character.Humanoid.HipHeight + (oldcloneroot.Size.Y / 2)) or clone.CFrame.p.Y
					origcf[3] = oldcloneroot.Position.Z
					oldcloneroot.CanCollide = true
					bodyvelo = Instance.new("BodyVelocity")
					bodyvelo.MaxForce = Vector3.new(0, 9e9, 0)
					bodyvelo.Velocity = Vector3.new(0, -1, 0)
					bodyvelo.Parent = oldcloneroot
					oldcloneroot.Velocity = Vector3.new(clone.Velocity.X, -1, clone.Velocity.Z)
					RunLoops:BindToHeartbeat("InfiniteFlyOff", function(dt)
						if oldcloneroot then 
							oldcloneroot.Velocity = Vector3.new(clone.Velocity.X, -1, clone.Velocity.Z)
							local bruh = {clone.CFrame:GetComponents()}
							bruh[2] = oldcloneroot.CFrame.Y
							local newcf = CFrame.new(unpack(bruh))
							FlyOverlap.FilterDescendantsInstances = {lplr.Character, gameCamera}
							local allowed = true
							for i,v in pairs(workspace:GetPartBoundsInRadius(newcf.p, 2, FlyOverlap)) do 
								if (v.Position.Y + (v.Size.Y / 2)) > (newcf.p.Y + 0.5) then 
									allowed = false
									break
								end
							end
							if allowed then
								oldcloneroot.CFrame = newcf
							end
						end
					end)
					oldcloneroot.CFrame = CFrame.new(unpack(origcf))
					entityLibrary.character.Humanoid:ChangeState(Enum.HumanoidStateType.Landed)
					disabledproper = false
					if isnetworkowner(oldcloneroot) then 
						warningNotification("InfiniteFly", "Waiting 1.5s to not flag", 3)
						task.delay(1.5, disablefunc)
					else
						disablefunc()
					end
				end
				InfiniteFlyUp = false
				InfiniteFlyDown = false
			end
		end,
		HoverText = "Makes you go zoom",
		ExtraText = function()
			return "Heatseeker"
		end
	})
	InfiniteFlySpeed = InfiniteFly.CreateSlider({
		Name = "Speed",
		Min = 1,
		Max = 23,
		Function = function(val) end, 
		Default = 23
	})
	InfiniteFlyVerticalSpeed = InfiniteFly.CreateSlider({
		Name = "Vertical Speed",
		Min = 1,
		Max = 100,
		Function = function(val) end, 
		Default = 44
	})
	InfiniteFlyVertical = InfiniteFly.CreateToggle({
		Name = "Y Level",
		Function = function() end, 
		Default = true
	})
end)

local killauraNearPlayer
runFunction(function()
	local killauraboxes = {}
    local killauratargetframe = {Players = {Enabled = false}}
	local killaurasortmethod = {Value = "Distance"}
    local killaurarealremote = bedwars.ClientHandler:Get(bedwars.AttackRemote).instance
    local killauramethod = {Value = "Normal"}
	local killauraothermethod = {Value = "Normal"}
    local killauraanimmethod = {Value = "Normal"}
    local killaurarange = {Value = 14}
    local killauraangle = {Value = 360}
    local killauratargets = {Value = 10}
	local killauraautoblock = {Enabled = false}
    local killauramouse = {Enabled = false}
    local killauracframe = {Enabled = false}
    local killauragui = {Enabled = false}
    local killauratarget = {Enabled = false}
    local killaurasound = {Enabled = false}
    local killauraswing = {Enabled = false}
	local killaurasync = {Enabled = false}
    local killaurahandcheck = {Enabled = false}
    local killauraanimation = {Enabled = false}
	local killauraanimationtween = {Enabled = false}
	local killauracolor = {Value = 0.44}
	local killauranovape = {Enabled = false}
	local killauratargethighlight = {Enabled = false}
	local killaurarangecircle = {Enabled = false}
	local killaurarangecirclepart
	local killauraaimcircle = {Enabled = false}
	local killauraaimcirclepart
	local killauraparticle = {Enabled = false}
	local killauraparticlepart
    local Killauranear = false
    local killauraplaying = false
    local oldViewmodelAnimation = function() end
    local oldPlaySound = function() end
    local originalArmC0 = nil
	local killauracurrentanim
	local animationdelay = tick()

	local function getStrength(plr)
		local inv = bedwarsStore.inventories[plr.Player]
		local strength = 0
		local strongestsword = 0
		if inv then
			for i,v in pairs(inv.items) do 
				local itemmeta = bedwars.ItemTable[v.itemType]
				if itemmeta and itemmeta.sword and itemmeta.sword.damage > strongestsword then 
					strongestsword = itemmeta.sword.damage / 100
				end	
			end
			strength = strength + strongestsword
			for i,v in pairs(inv.armor) do 
				local itemmeta = bedwars.ItemTable[v.itemType]
				if itemmeta and itemmeta.armor then 
					strength = strength + (itemmeta.armor.damageReductionMultiplier or 0)
				end
			end
			strength = strength
		end
		return strength
	end

	local kitpriolist = {
		hannah = 5,
		spirit_assassin = 4,
		dasher = 3,
		jade = 2,
		regent = 1
	}

	local killaurasortmethods = {
		Distance = function(a, b)
			return (a.RootPart.Position - entityLibrary.character.HumanoidRootPart.Position).Magnitude < (b.RootPart.Position - entityLibrary.character.HumanoidRootPart.Position).Magnitude
		end,
		Health = function(a, b) 
			return a.Humanoid.Health < b.Humanoid.Health
		end,
		Threat = function(a, b) 
			return getStrength(a) > getStrength(b)
		end,
		Kit = function(a, b)
			return (kitpriolist[a.Player:GetAttribute("PlayingAsKit")] or 0) > (kitpriolist[b.Player:GetAttribute("PlayingAsKit")] or 0)
		end
	}

	local originalNeckC0
	local originalRootC0
	local anims = {
		Normal = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.05},
			{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.05}
		},
		Slow = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.15},
			{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.15}
		},
		New = {
			{CFrame = CFrame.new(0.69, -0.77, 1.47) * CFrame.Angles(math.rad(-33), math.rad(57), math.rad(-81)), Time = 0.12},
			{CFrame = CFrame.new(0.74, -0.92, 0.88) * CFrame.Angles(math.rad(147), math.rad(71), math.rad(53)), Time = 0.12}
		},
		Latest = {
			{CFrame = CFrame.new(0.69, -0.7, 0.1) * CFrame.Angles(math.rad(-65), math.rad(55), math.rad(-51)), Time = 0.1},
			{CFrame = CFrame.new(0.16, -1.16, 0.5) * CFrame.Angles(math.rad(-179), math.rad(54), math.rad(33)), Time = 0.1}
		},
		["Vertical Spin"] = {
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-90), math.rad(8), math.rad(5)), Time = 0.1},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(180), math.rad(3), math.rad(13)), Time = 0.1},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(90), math.rad(-5), math.rad(8)), Time = 0.1},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(-0), math.rad(-0)), Time = 0.1}
		},
		Exhibition = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2}
		},
		["Exhibition Old"] = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.15},
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.05},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.05},
			{CFrame = CFrame.new(0.63, -0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.15}
		}
	}

	local function closestpos(block, pos)
		local blockpos = block:GetRenderCFrame()
		local startpos = (blockpos * CFrame.new(-(block.Size / 2))).p
		local endpos = (blockpos * CFrame.new((block.Size / 2))).p
		local speedCFrame = block.Position + (pos - block.Position)
		local x = startpos.X > endpos.X and endpos.X or startpos.X
		local y = startpos.Y > endpos.Y and endpos.Y or startpos.Y
		local z = startpos.Z > endpos.Z and endpos.Z or startpos.Z
		local x2 = startpos.X < endpos.X and endpos.X or startpos.X
		local y2 = startpos.Y < endpos.Y and endpos.Y or startpos.Y
		local z2 = startpos.Z < endpos.Z and endpos.Z or startpos.Z
		return Vector3.new(math.clamp(speedCFrame.X, x, x2), math.clamp(speedCFrame.Y, y, y2), math.clamp(speedCFrame.Z, z, z2))
	end

	local function getAttackData()
		if GuiLibrary.ObjectsThatCanBeSaved["Lobby CheckToggle"].Api.Enabled then 
			if bedwarsStore.matchState == 0 then return false end
		end
		if killauramouse.Enabled then
			if not inputService:IsMouseButtonPressed(0) then return false end
		end
		if killauragui.Enabled then
			if getOpenApps() > (bedwarsStore.equippedKit == "hannah" and 4 or 3) then return false end
		end
		local sword = killaurahandcheck.Enabled and bedwarsStore.localHand or getSword()
		if not sword or not sword.tool then return false end
		local swordmeta = bedwars.ItemTable[sword.tool.Name]
		if killaurahandcheck.Enabled then
			if bedwarsStore.localHand.Type ~= "sword" or bedwars.KatanaController.chargingMaid then return false end
		end
		return sword, swordmeta
	end

	local function autoBlockLoop()
		if not killauraautoblock.Enabled or not Killaura.Enabled then return end
		repeat
			if bedwarsStore.blockPlace < tick() and entityLibrary.isAlive then
				local shield = getItem("infernal_shield")
				if shield then 
					switchItem(shield.tool)
					if not lplr.Character:GetAttribute("InfernalShieldRaised") then
						bedwars.InfernalShieldController:raiseShield()
					end
				end
			end
			task.wait()
		until (not Killaura.Enabled) or (not killauraautoblock.Enabled)
	end

    Killaura = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
        Name = "Killaura",
        Function = function(callback)
            if callback then
				if killauraaimcirclepart then killauraaimcirclepart.Parent = gameCamera end
				if killaurarangecirclepart then killaurarangecirclepart.Parent = gameCamera end
				if killauraparticlepart then killauraparticlepart.Parent = gameCamera end

				task.spawn(function()
					local oldNearPlayer
					repeat
						task.wait()
						if (killauraanimation.Enabled and not killauraswing.Enabled) then
							if killauraNearPlayer then
								pcall(function()
									if originalArmC0 == nil then
										originalArmC0 = gameCamera.Viewmodel.RightHand.RightWrist.C0
									end
									if killauraplaying == false then
										killauraplaying = true
										for i,v in pairs(anims[killauraanimmethod.Value]) do 
											if (not Killaura.Enabled) or (not killauraNearPlayer) then break end
											if not oldNearPlayer and killauraanimationtween.Enabled then
												gameCamera.Viewmodel.RightHand.RightWrist.C0 = originalArmC0 * v.CFrame
												continue
											end
											killauracurrentanim = tweenService:Create(gameCamera.Viewmodel.RightHand.RightWrist, TweenInfo.new(v.Time), {C0 = originalArmC0 * v.CFrame})
											killauracurrentanim:Play()
											task.wait(v.Time - 0.01)
										end
										killauraplaying = false
									end
								end)	
							end
							oldNearPlayer = killauraNearPlayer
						end
					until Killaura.Enabled == false
				end)

                oldViewmodelAnimation = bedwars.ViewmodelController.playAnimation
                oldPlaySound = bedwars.SoundManager.playSound
                bedwars.SoundManager.playSound = function(tab, soundid, ...)
                    if (soundid == bedwars.SoundList.SWORD_SWING_1 or soundid == bedwars.SoundList.SWORD_SWING_2) and Killaura.Enabled and killaurasound.Enabled and killauraNearPlayer then
                        return nil
                    end
                    return oldPlaySound(tab, soundid, ...)
                end
                bedwars.ViewmodelController.playAnimation = function(Self, id, ...)
                    if id == 15 and killauraNearPlayer and killauraswing.Enabled and entityLibrary.isAlive then
                        return nil
                    end
                    if id == 15 and killauraNearPlayer and killauraanimation.Enabled and entityLibrary.isAlive then
                        return nil
                    end
                    return oldViewmodelAnimation(Self, id, ...)
                end

				local targetedPlayer
				RunLoops:BindToHeartbeat("Killaura", function()
					for i,v in pairs(killauraboxes) do 
						if v:IsA("BoxHandleAdornment") and v.Adornee then
							local cf = v.Adornee and v.Adornee.CFrame
							local onex, oney, onez = cf:ToEulerAnglesXYZ() 
							v.CFrame = CFrame.new() * CFrame.Angles(-onex, -oney, -onez)
						end
					end
					if entityLibrary.isAlive then
						if killauraaimcirclepart then 
							killauraaimcirclepart.Position = targetedPlayer and closestpos(targetedPlayer.RootPart, entityLibrary.character.HumanoidRootPart.Position) or Vector3.new(99999, 99999, 99999)
						end
						if killauraparticlepart then 
							killauraparticlepart.Position = targetedPlayer and targetedPlayer.RootPart.Position or Vector3.new(99999, 99999, 99999)
						end
						local Root = entityLibrary.character.HumanoidRootPart
						if Root then
							if killaurarangecirclepart then 
								killaurarangecirclepart.Position = Root.Position - Vector3.new(0, entityLibrary.character.Humanoid.HipHeight, 0)
							end
							local Neck = entityLibrary.character.Head:FindFirstChild("Neck")
							local LowerTorso = Root.Parent and Root.Parent:FindFirstChild("LowerTorso")
							local RootC0 = LowerTorso and LowerTorso:FindFirstChild("Root")
							if Neck and RootC0 then
								if originalNeckC0 == nil then
									originalNeckC0 = Neck.C0.p
								end
								if originalRootC0 == nil then
									originalRootC0 = RootC0.C0.p
								end
								if originalRootC0 and killauracframe.Enabled then
									if targetedPlayer ~= nil then
										local targetPos = targetedPlayer.RootPart.Position + Vector3.new(0, 2, 0)
										local direction = (Vector3.new(targetPos.X, targetPos.Y, targetPos.Z) - entityLibrary.character.Head.Position).Unit
										local direction2 = (Vector3.new(targetPos.X, Root.Position.Y, targetPos.Z) - Root.Position).Unit
										local lookCFrame = (CFrame.new(Vector3.zero, (Root.CFrame):VectorToObjectSpace(direction)))
										local lookCFrame2 = (CFrame.new(Vector3.zero, (Root.CFrame):VectorToObjectSpace(direction2)))
										Neck.C0 = CFrame.new(originalNeckC0) * CFrame.Angles(lookCFrame.LookVector.Unit.y, 0, 0)
										RootC0.C0 = lookCFrame2 + originalRootC0
									else
										Neck.C0 = CFrame.new(originalNeckC0)
										RootC0.C0 = CFrame.new(originalRootC0)
									end
								end
							end
						end
					end
				end)
				if killauraautoblock.Enabled then 
					task.spawn(autoBlockLoop)
				end
                task.spawn(function()
					repeat
						task.wait()
						if not Killaura.Enabled then break end
						vapeTargetInfo.Targets.Killaura = nil
						local plrs = AllNearPosition(killaurarange.Value, 10, killaurasortmethods[killaurasortmethod.Value], true)
						local firstPlayerNear
						if #plrs > 0 then
							local sword, swordmeta = getAttackData()
							if sword then
								switchItem(sword.tool)
								for i, plr in pairs(plrs) do
									local root = plr.RootPart
									if not root then 
										continue
									end
									local localfacing = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
									local vec = (plr.RootPart.Position - entityLibrary.character.HumanoidRootPart.Position).unit
									local angle = math.acos(localfacing:Dot(vec))
									if angle >= (math.rad(killauraangle.Value) / 2) then
										continue
									end
									local selfrootpos = entityLibrary.character.HumanoidRootPart.Position
									if killauratargetframe.Walls.Enabled then
										if not bedwars.SwordController:canSee({player = plr.Player, getInstance = function() return plr.Character end}) then continue end
									end
									if not ({WhitelistFunctions:GetWhitelist(plr.Player)})[2] then
										continue
									end
									if killauranovape.Enabled and bedwarsStore.whitelist.clientUsers[plr.Player.Name] then
										continue
									end
									if not firstPlayerNear then 
										firstPlayerNear = true 
										killauraNearPlayer = true
										targetedPlayer = plr
										vapeTargetInfo.Targets.Killaura = {
											Humanoid = {
												Health = (plr.Character:GetAttribute("Health") or plr.Humanoid.Health) + getShieldAttribute(plr.Character),
												MaxHealth = plr.Character:GetAttribute("MaxHealth") or plr.Humanoid.MaxHealth
											},
											Player = plr.Player
										}
										if animationdelay <= tick() then
											animationdelay = tick() + (swordmeta.sword.respectAttackSpeedForEffects and swordmeta.sword.attackSpeed or (killaurasync.Enabled and 0.24 or 0.14))
											if not killauraswing.Enabled then 
												bedwars.SwordController:playSwordEffect(swordmeta, false)
											end
											if swordmeta.displayName:find(" Scythe") then 
												bedwars.ScytheController:playLocalAnimation()
											end
										end
									end
									if (workspace:GetServerTimeNow() - bedwars.SwordController.lastAttack) < 0.02 then 
										break
									end
									local selfpos = selfrootpos + (killaurarange.Value > 14 and (selfrootpos - root.Position).magnitude > 14.4 and (CFrame.lookAt(selfrootpos, root.Position).lookVector * ((selfrootpos - root.Position).magnitude - 14)) or Vector3.zero)
									bedwars.SwordController.lastAttack = workspace:GetServerTimeNow()
									bedwarsStore.attackReach = math.floor((selfrootpos - root.Position).magnitude * 100) / 100
									bedwarsStore.attackReachUpdate = tick() + 1
									killaurarealremote:FireServer({
										weapon = sword.tool,
										chargedAttack = {chargeRatio = swordmeta.sword.chargedAttack and not swordmeta.sword.chargedAttack.disableOnGrounded and 0.999 or 0},
										entityInstance = plr.Character,
										validate = {
											raycast = {
												cameraPosition = attackValue(root.Position), 
												cursorDirection = attackValue(CFrame.new(selfpos, root.Position).lookVector)
											},
											targetPosition = attackValue(root.Position),
											selfPosition = attackValue(selfpos)
										}
									})
									break
								end
							end
						end
						if not firstPlayerNear then 
							targetedPlayer = nil
							killauraNearPlayer = false
							pcall(function()
								if originalArmC0 == nil then
									originalArmC0 = gameCamera.Viewmodel.RightHand.RightWrist.C0
								end
								if gameCamera.Viewmodel.RightHand.RightWrist.C0 ~= originalArmC0 then
									pcall(function()
										killauracurrentanim:Cancel()
									end)
									if killauraanimationtween.Enabled then 
										gameCamera.Viewmodel.RightHand.RightWrist.C0 = originalArmC0
									else
										killauracurrentanim = tweenService:Create(gameCamera.Viewmodel.RightHand.RightWrist, TweenInfo.new(0.1), {C0 = originalArmC0})
										killauracurrentanim:Play()
									end
								end
							end)
						end
						for i,v in pairs(killauraboxes) do 
							local attacked = killauratarget.Enabled and plrs[i] or nil
							v.Adornee = attacked and ((not killauratargethighlight.Enabled) and attacked.RootPart or (not GuiLibrary.ObjectsThatCanBeSaved.ChamsOptionsButton.Api.Enabled) and attacked.Character or nil)
						end
					until (not Killaura.Enabled)
				end)
            else
				vapeTargetInfo.Targets.Killaura = nil
				RunLoops:UnbindFromHeartbeat("Killaura") 
                killauraNearPlayer = false
				for i,v in pairs(killauraboxes) do v.Adornee = nil end
				if killauraaimcirclepart then killauraaimcirclepart.Parent = nil end
				if killaurarangecirclepart then killaurarangecirclepart.Parent = nil end
				if killauraparticlepart then killauraparticlepart.Parent = nil end
                bedwars.ViewmodelController.playAnimation = oldViewmodelAnimation
                bedwars.SoundManager.playSound = oldPlaySound
                oldViewmodelAnimation = nil
                pcall(function()
					if entityLibrary.isAlive then
						local Root = entityLibrary.character.HumanoidRootPart
						if Root then
							local Neck = Root.Parent.Head.Neck
							if originalNeckC0 and originalRootC0 then 
								Neck.C0 = CFrame.new(originalNeckC0)
								Root.Parent.LowerTorso.Root.C0 = CFrame.new(originalRootC0)
							end
						end
					end
                    if originalArmC0 == nil then
                        originalArmC0 = gameCamera.Viewmodel.RightHand.RightWrist.C0
                    end
                    if gameCamera.Viewmodel.RightHand.RightWrist.C0 ~= originalArmC0 then
						pcall(function()
							killauracurrentanim:Cancel()
						end)
						if killauraanimationtween.Enabled then 
							gameCamera.Viewmodel.RightHand.RightWrist.C0 = originalArmC0
						else
							killauracurrentanim = tweenService:Create(gameCamera.Viewmodel.RightHand.RightWrist, TweenInfo.new(0.1), {C0 = originalArmC0})
							killauracurrentanim:Play()
						end
                    end
                end)
            end
        end,
        HoverText = "Attack players around you\nwithout aiming at them."
    })
    killauratargetframe = Killaura.CreateTargetWindow({})
	local sortmethods = {"Distance"}
	for i,v in pairs(killaurasortmethods) do if i ~= "Distance" then table.insert(sortmethods, i) end end
	killaurasortmethod = Killaura.CreateDropdown({
		Name = "Sort",
		Function = function() end,
		List = sortmethods
	})
    killaurarange = Killaura.CreateSlider({
        Name = "Attack range",
        Min = 1,
        Max = 18,
        Function = function(val) 
			if killaurarangecirclepart then 
				killaurarangecirclepart.Size = Vector3.new(val * 0.7, 0.01, val * 0.7)
			end
		end, 
        Default = 18
    })
    killauraangle = Killaura.CreateSlider({
        Name = "Max angle",
        Min = 1,
        Max = 360,
        Function = function(val) end,
        Default = 360
    })
	local animmethods = {}
	for i,v in pairs(anims) do table.insert(animmethods, i) end
    killauraanimmethod = Killaura.CreateDropdown({
        Name = "Animation", 
        List = animmethods,
        Function = function(val) end
    })
	local oldviewmodel
	local oldraise
	local oldeffect
	killauraautoblock = Killaura.CreateToggle({
		Name = "AutoBlock",
		Function = function(callback)
			if callback then 
				oldviewmodel = bedwars.ViewmodelController.setHeldItem
				bedwars.ViewmodelController.setHeldItem = function(self, newItem, ...)
					if newItem and newItem.Name == "infernal_shield" then 
						return
					end
					return oldviewmodel(self, newItem)
				end
				oldraise = bedwars.InfernalShieldController.raiseShield
				bedwars.InfernalShieldController.raiseShield = function(self)
					if os.clock() - self.lastShieldRaised < 0.4 then
						return
					end
					self.lastShieldRaised = os.clock()
					self.infernalShieldState:SendToServer({raised = true})
					self.raisedMaid:GiveTask(function()
						self.infernalShieldState:SendToServer({raised = false})
					end)
				end
				oldeffect = bedwars.InfernalShieldController.playEffect
				bedwars.InfernalShieldController.playEffect = function()
					return
				end
				if bedwars.ViewmodelController.heldItem and bedwars.ViewmodelController.heldItem.Name == "infernal_shield" then 
					local sword, swordmeta = getSword()
					if sword then 
						bedwars.ViewmodelController:setHeldItem(sword.tool)
					end
				end
				task.spawn(autoBlockLoop)
			else
				bedwars.ViewmodelController.setHeldItem = oldviewmodel
				bedwars.InfernalShieldController.raiseShield = oldraise
				bedwars.InfernalShieldController.playEffect = oldeffect
			end
		end,
		Default = true
	})
    killauramouse = Killaura.CreateToggle({
        Name = "Require mouse down",
        Function = function() end,
		HoverText = "Only attacks when left click is held.",
        Default = false
    })
    killauragui = Killaura.CreateToggle({
        Name = "GUI Check",
        Function = function() end,
		HoverText = "Attacks when you are not in a GUI."
    })
    killauratarget = Killaura.CreateToggle({
        Name = "Show target",
        Function = function(callback) 
			if killauratargethighlight.Object then 
				killauratargethighlight.Object.Visible = callback
			end
		end,
		HoverText = "Shows a red box over the opponent."
    })
	killauratargethighlight = Killaura.CreateToggle({
		Name = "Use New Highlight",
		Function = function(callback) 
			for i,v in pairs(killauraboxes) do 
				v:Remove()
			end
			for i = 1, 10 do 
				local killaurabox
				if callback then 
					killaurabox = Instance.new("Highlight")
					killaurabox.FillTransparency = 0.39
					killaurabox.FillColor = Color3.fromHSV(killauracolor.Hue, killauracolor.Sat, killauracolor.Value)
					killaurabox.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					killaurabox.OutlineTransparency = 1
					killaurabox.Parent = GuiLibrary.MainGui
				else
					killaurabox = Instance.new("BoxHandleAdornment")
					killaurabox.Transparency = 0.39
					killaurabox.Color3 = Color3.fromHSV(killauracolor.Hue, killauracolor.Sat, killauracolor.Value)
					killaurabox.Adornee = nil
					killaurabox.AlwaysOnTop = true
					killaurabox.Size = Vector3.new(3, 6, 3)
					killaurabox.ZIndex = 11
					killaurabox.Parent = GuiLibrary.MainGui
				end
				killauraboxes[i] = killaurabox
			end
		end
	})
	killauratargethighlight.Object.BorderSizePixel = 0
	killauratargethighlight.Object.BackgroundTransparency = 0
	killauratargethighlight.Object.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	killauratargethighlight.Object.Visible = false
	killauracolor = Killaura.CreateColorSlider({
		Name = "Target Color",
		Function = function(hue, sat, val) 
			for i,v in pairs(killauraboxes) do 
				v[(killauratargethighlight.Enabled and "FillColor" or "Color3")] = Color3.fromHSV(hue, sat, val)
			end
			if killauraaimcirclepart then 
				killauraaimcirclepart.Color = Color3.fromHSV(hue, sat, val)
			end
			if killaurarangecirclepart then 
				killaurarangecirclepart.Color = Color3.fromHSV(hue, sat, val)
			end
		end,
		Default = 1
	})
	for i = 1, 10 do 
		local killaurabox = Instance.new("BoxHandleAdornment")
		killaurabox.Transparency = 0.5
		killaurabox.Color3 = Color3.fromHSV(killauracolor["Hue"], killauracolor["Sat"], killauracolor.Value)
		killaurabox.Adornee = nil
		killaurabox.AlwaysOnTop = true
		killaurabox.Size = Vector3.new(3, 6, 3)
		killaurabox.ZIndex = 11
		killaurabox.Parent = GuiLibrary.MainGui
		killauraboxes[i] = killaurabox
	end
    killauracframe = Killaura.CreateToggle({
        Name = "Face target",
        Function = function() end,
		HoverText = "Makes your character face the opponent."
    })
	killaurarangecircle = Killaura.CreateToggle({
		Name = "Range Visualizer",
		Function = function(callback)
			if callback then 
				killaurarangecirclepart = Instance.new("MeshPart")
				killaurarangecirclepart.MeshId = "rbxassetid://3726303797"
				killaurarangecirclepart.Color = Color3.fromHSV(killauracolor["Hue"], killauracolor["Sat"], killauracolor.Value)
				killaurarangecirclepart.CanCollide = false
				killaurarangecirclepart.Anchored = true
				killaurarangecirclepart.Material = Enum.Material.Neon
				killaurarangecirclepart.Size = Vector3.new(killaurarange.Value * 0.7, 0.01, killaurarange.Value * 0.7)
				if Killaura.Enabled then 
					killaurarangecirclepart.Parent = gameCamera
				end
				bedwars.QueryUtil:setQueryIgnored(killaurarangecirclepart, true)
			else
				if killaurarangecirclepart then 
					killaurarangecirclepart:Destroy()
					killaurarangecirclepart = nil
				end
			end
		end
	})
	killauraaimcircle = Killaura.CreateToggle({
		Name = "Aim Visualizer",
		Function = function(callback)
			if callback then 
				killauraaimcirclepart = Instance.new("Part")
				killauraaimcirclepart.Shape = Enum.PartType.Ball
				killauraaimcirclepart.Color = Color3.fromHSV(killauracolor["Hue"], killauracolor["Sat"], killauracolor.Value)
				killauraaimcirclepart.CanCollide = false
				killauraaimcirclepart.Anchored = true
				killauraaimcirclepart.Material = Enum.Material.Neon
				killauraaimcirclepart.Size = Vector3.new(0.5, 0.5, 0.5)
				if Killaura.Enabled then 
					killauraaimcirclepart.Parent = gameCamera
				end
				bedwars.QueryUtil:setQueryIgnored(killauraaimcirclepart, true)
			else
				if killauraaimcirclepart then 
					killauraaimcirclepart:Destroy()
					killauraaimcirclepart = nil
				end
			end
		end
	})
	killauraparticle = Killaura.CreateToggle({
		Name = "Crit Particle",
		Function = function(callback)
			if callback then 
				killauraparticlepart = Instance.new("Part")
				killauraparticlepart.Transparency = 1
				killauraparticlepart.CanCollide = false
				killauraparticlepart.Anchored = true
				killauraparticlepart.Size = Vector3.new(3, 6, 3)
				killauraparticlepart.Parent = cam
				bedwars.QueryUtil:setQueryIgnored(killauraparticlepart, true)
				local particle = Instance.new("ParticleEmitter")
				particle.Lifetime = NumberRange.new(0.5)
				particle.Rate = 500
				particle.Speed = NumberRange.new(0)
				particle.RotSpeed = NumberRange.new(180)
				particle.Enabled = true
				particle.Size = NumberSequence.new(0.3)
				particle.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(67, 10, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 98, 255))})
				particle.Parent = killauraparticlepart
			else
				if killauraparticlepart then 
					killauraparticlepart:Destroy()
					killauraparticlepart = nil
				end
			end
		end
	})
    killaurasound = Killaura.CreateToggle({
        Name = "No Swing Sound",
        Function = function() end,
		HoverText = "Removes the swinging sound."
    })
    killauraswing = Killaura.CreateToggle({
        Name = "No Swing",
        Function = function() end,
		HoverText = "Removes the swinging animation."
    })
    killaurahandcheck = Killaura.CreateToggle({
        Name = "Limit to items",
        Function = function() end,
		HoverText = "Only attacks when your sword is held."
    })
    killauraanimation = Killaura.CreateToggle({
        Name = "Custom Animation",
        Function = function(callback)
			if killauraanimationtween.Object then killauraanimationtween.Object.Visible = callback end
		end,
		HoverText = "Uses a custom animation for swinging"
    })
	killauraanimationtween = Killaura.CreateToggle({
		Name = "No Tween",
		Function = function() end,
		HoverText = "Disable's the in and out ease"
	})
	killauraanimationtween.Object.Visible = false
	killaurasync = Killaura.CreateToggle({
        Name = "Synced Animation",
        Function = function() end,
		HoverText = "Times animation with hit attempt"
    })
	killauranovape = Killaura.CreateToggle({
		Name = "No Vape",
		Function = function() end,
		HoverText = "no hit vape user"
	})
	killauranovape.Object.Visible = false
	task.spawn(function()
		repeat task.wait() until WhitelistFunctions.Loaded
		killauranovape.Object.Visible = WhitelistFunctions.LocalPriority ~= 0
	end)
end)

local LongJump = {Enabled = false}
runFunction(function()
	local damagetimer = 0
	local damagetimertick = 0
	local directionvec
	local LongJumpSpeed = {Value = 1.5}
	local projectileRemote = bedwars.ClientHandler:Get(bedwars.ProjectileRemote)

	local function calculatepos(vec)
		local returned = vec
		if entityLibrary.isAlive then 
			local newray = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, returned, bedwarsStore.blockRaycast)
			if newray then returned = (newray.Position - entityLibrary.character.HumanoidRootPart.Position) end
		end
		return returned
	end

	local damagemethods = {
		fireball = function(fireball, pos)
			if not LongJump.Enabled then return end
			pos = pos - (entityLibrary.character.HumanoidRootPart.CFrame.lookVector * 0.2)
			if not (getPlacedBlock(pos - Vector3.new(0, 3, 0)) or getPlacedBlock(pos - Vector3.new(0, 6, 0))) then
				local sound = Instance.new("Sound")
				sound.SoundId = "rbxassetid://4809574295"
				sound.Parent = workspace
				sound.Ended:Connect(function()
					sound:Destroy()
				end)
				sound:Play()
			end
			local origpos = pos
			local offsetshootpos = (CFrame.new(pos, pos + Vector3.new(0, -60, 0)) * CFrame.new(Vector3.new(-bedwars.BowConstantsTable.RelX, -bedwars.BowConstantsTable.RelY, -bedwars.BowConstantsTable.RelZ))).p
			local ray = workspace:Raycast(pos, Vector3.new(0, -30, 0), bedwarsStore.blockRaycast)
			if ray then
				pos = ray.Position
				offsetshootpos = pos
			end
			task.spawn(function()
				switchItem(fireball.tool)
				bedwars.ProjectileController:createLocalProjectile(bedwars.ProjectileMeta.fireball, "fireball", "fireball", offsetshootpos, "", Vector3.new(0, -60, 0), {drawDurationSeconds = 1})
				projectileRemote:CallServerAsync(fireball.tool, "fireball", "fireball", offsetshootpos, pos, Vector3.new(0, -60, 0), game:GetService("HttpService"):GenerateGUID(true), {drawDurationSeconds = 1}, workspace:GetServerTimeNow() - 0.045)
			end)
		end,
		tnt = function(tnt, pos2)
			if not LongJump.Enabled then return end
			local pos = Vector3.new(pos2.X, getScaffold(Vector3.new(0, pos2.Y - (((entityLibrary.character.HumanoidRootPart.Size.Y / 2) + entityLibrary.character.Humanoid.HipHeight) - 1.5), 0)).Y, pos2.Z)
			local block = bedwars.placeBlock(pos, "tnt")
		end,
		cannon = function(tnt, pos2)
			task.spawn(function()
				local pos = Vector3.new(pos2.X, getScaffold(Vector3.new(0, pos2.Y - (((entityLibrary.character.HumanoidRootPart.Size.Y / 2) + entityLibrary.character.Humanoid.HipHeight) - 1.5), 0)).Y, pos2.Z)
				local block = bedwars.placeBlock(pos, "cannon")
				task.delay(0.1, function()
					local block, pos2 = getPlacedBlock(pos)
					if block and block.Name == "cannon" and (entityLibrary.character.HumanoidRootPart.CFrame.p - block.Position).Magnitude < 20 then 
						switchToAndUseTool(block)
						local vec = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
						local damage = bedwars.BlockController:calculateBlockDamage(lplr, {
							blockPosition = pos2
						})
						bedwars.ClientHandler:Get(bedwars.CannonAimRemote):SendToServer({
							cannonBlockPos = pos2,
							lookVector = vec
						})
						local broken = 0.1
						if damage < block:GetAttribute("Health") then 
							task.spawn(function()
								broken = 0.4
								bedwars.breakBlock(block.Position, true, getBestBreakSide(block.Position), true, true)
							end)
						end
						task.delay(broken, function()
							for i = 1, 3 do 
								local call = bedwars.ClientHandler:Get(bedwars.CannonLaunchRemote):CallServer({cannonBlockPos = bedwars.BlockController:getBlockPosition(block.Position)})
								if call then
									bedwars.breakBlock(block.Position, true, getBestBreakSide(block.Position), true, true)
									task.delay(0.1, function()
										damagetimer = LongJumpSpeed.Value * 5
										damagetimertick = tick() + 2.5
										directionvec = Vector3.new(vec.X, 0, vec.Z).Unit
									end)
									break
								end
								task.wait(0.1)
							end
						end)
					end
				end)	
			end)
		end,
		wood_dao = function(tnt, pos2)
			task.spawn(function()
				switchItem(tnt.tool)
				if not (not lplr.Character:GetAttribute("CanDashNext") or lplr.Character:GetAttribute("CanDashNext") < workspace:GetServerTimeNow()) then
					repeat task.wait() until (not lplr.Character:GetAttribute("CanDashNext") or lplr.Character:GetAttribute("CanDashNext") < workspace:GetServerTimeNow()) or not LongJump.Enabled
				end
				if LongJump.Enabled then
					local vec = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
					replicatedStorageService["events-@easy-games/game-core:shared/game-core-networking@getEvents.Events"].useAbility:FireServer("dash", {
						direction = vec,
						origin = entityLibrary.character.HumanoidRootPart.CFrame.p,
						weapon = tnt.itemType
					})
					damagetimer = LongJumpSpeed.Value * 3.5
					damagetimertick = tick() + 2.5
					directionvec = Vector3.new(vec.X, 0, vec.Z).Unit
				end
			end)
		end,
		jade_hammer = function(tnt, pos2)
			task.spawn(function()
				if not bedwars.AbilityController:canUseAbility("jade_hammer_jump") then
					repeat task.wait() until bedwars.AbilityController:canUseAbility("jade_hammer_jump") or not LongJump.Enabled
					task.wait(0.1)
				end
				if bedwars.AbilityController:canUseAbility("jade_hammer_jump") and LongJump.Enabled then
					bedwars.AbilityController:useAbility("jade_hammer_jump")
					local vec = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
					damagetimer = LongJumpSpeed.Value * 2.75
					damagetimertick = tick() + 2.5
					directionvec = Vector3.new(vec.X, 0, vec.Z).Unit
				end
			end)
		end,
		void_axe = function(tnt, pos2)
			task.spawn(function()
				if not bedwars.AbilityController:canUseAbility("void_axe_jump") then
					repeat task.wait() until bedwars.AbilityController:canUseAbility("void_axe_jump") or not LongJump.Enabled
					task.wait(0.1)
				end
				if bedwars.AbilityController:canUseAbility("void_axe_jump") and LongJump.Enabled then
					bedwars.AbilityController:useAbility("void_axe_jump")
					local vec = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
					damagetimer = LongJumpSpeed.Value * 2.75
					damagetimertick = tick() + 2.5
					directionvec = Vector3.new(vec.X, 0, vec.Z).Unit
				end
			end)
		end
	}
	damagemethods.stone_dao = damagemethods.wood_dao
	damagemethods.iron_dao = damagemethods.wood_dao
	damagemethods.diamond_dao = damagemethods.wood_dao
	damagemethods.emerald_dao = damagemethods.wood_dao

	local oldgrav
	local LongJumpacprogressbarframe = Instance.new("Frame")
	LongJumpacprogressbarframe.AnchorPoint = Vector2.new(0.5, 0)
	LongJumpacprogressbarframe.Position = UDim2.new(0.5, 0, 1, -200)
	LongJumpacprogressbarframe.Size = UDim2.new(0.2, 0, 0, 20)
	LongJumpacprogressbarframe.BackgroundTransparency = 0.5
	LongJumpacprogressbarframe.BorderSizePixel = 0
	LongJumpacprogressbarframe.BackgroundColor3 = Color3.fromHSV(GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Hue, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Sat, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Value)
	LongJumpacprogressbarframe.Visible = LongJump.Enabled
	LongJumpacprogressbarframe.Parent = GuiLibrary.MainGui
	local LongJumpacprogressbarframe2 = LongJumpacprogressbarframe:Clone()
	LongJumpacprogressbarframe2.AnchorPoint = Vector2.new(0, 0)
	LongJumpacprogressbarframe2.Position = UDim2.new(0, 0, 0, 0)
	LongJumpacprogressbarframe2.Size = UDim2.new(1, 0, 0, 20)
	LongJumpacprogressbarframe2.BackgroundTransparency = 0
	LongJumpacprogressbarframe2.Visible = true
	LongJumpacprogressbarframe2.BackgroundColor3 = Color3.fromHSV(GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Hue, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Sat, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Value)
	LongJumpacprogressbarframe2.Parent = LongJumpacprogressbarframe
	local LongJumpacprogressbartext = Instance.new("TextLabel")
	LongJumpacprogressbartext.Text = "2.5s"
	LongJumpacprogressbartext.Font = Enum.Font.Gotham
	LongJumpacprogressbartext.TextStrokeTransparency = 0
	LongJumpacprogressbartext.TextColor3 =  Color3.new(0.9, 0.9, 0.9)
	LongJumpacprogressbartext.TextSize = 20
	LongJumpacprogressbartext.Size = UDim2.new(1, 0, 1, 0)
	LongJumpacprogressbartext.BackgroundTransparency = 1
	LongJumpacprogressbartext.Position = UDim2.new(0, 0, -1, 0)
	LongJumpacprogressbartext.Parent = LongJumpacprogressbarframe
	LongJump = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "LongJump",
		Function = function(callback)
			if callback then
				table.insert(LongJump.Connections, vapeEvents.EntityDamageEvent.Event:Connect(function(damageTable)
					if damageTable.entityInstance == lplr.Character and (not damageTable.knockbackMultiplier or not damageTable.knockbackMultiplier.disabled) then 
						local knockbackBoost = damageTable.knockbackMultiplier and damageTable.knockbackMultiplier.horizontal and damageTable.knockbackMultiplier.horizontal * LongJumpSpeed.Value or LongJumpSpeed.Value
						if damagetimertick < tick() or knockbackBoost >= damagetimer then
							damagetimer = knockbackBoost
							damagetimertick = tick() + 2.5
							local newDirection = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
							directionvec = Vector3.new(newDirection.X, 0, newDirection.Z).Unit
						end
					end
				end))
				task.spawn(function()
					task.spawn(function()
						repeat
							task.wait()
							if LongJumpacprogressbarframe then
								LongJumpacprogressbarframe.BackgroundColor3 = Color3.fromHSV(GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Hue, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Sat, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Value)
								LongJumpacprogressbarframe2.BackgroundColor3 = Color3.fromHSV(GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Hue, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Sat, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Value)
							end
						until (not LongJump.Enabled)
					end)
					local LongJumpOrigin = entityLibrary.isAlive and entityLibrary.character.HumanoidRootPart.Position
					local tntcheck
					for i,v in pairs(damagemethods) do 
						local item = getItem(i)
						if item then
							if i == "tnt" then 
								local pos = getScaffold(LongJumpOrigin)
								tntcheck = Vector3.new(pos.X, LongJumpOrigin.Y, pos.Z)
								v(item, pos)
							else
								v(item, LongJumpOrigin)
							end
							break
						end
					end
					local changecheck
					LongJumpacprogressbarframe.Visible = true
					RunLoops:BindToHeartbeat("LongJump", function(dt)
						if entityLibrary.isAlive then 
							if entityLibrary.character.Humanoid.Health <= 0 then 
								LongJump.ToggleButton(false)
								return
							end
							if not LongJumpOrigin then 
								LongJumpOrigin = entityLibrary.character.HumanoidRootPart.Position
							end
							local newval = damagetimer ~= 0
							if changecheck ~= newval then 
								if newval then 
									LongJumpacprogressbarframe2:TweenSize(UDim2.new(0, 0, 0, 20), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 2.5, true)
								else
									LongJumpacprogressbarframe2:TweenSize(UDim2.new(1, 0, 0, 20), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0, true)
								end
								changecheck = newval
							end
							if newval then 
								local newnum = math.max(math.floor((damagetimertick - tick()) * 10) / 10, 0)
								if LongJumpacprogressbartext then 
									LongJumpacprogressbartext.Text = newnum.."s"
								end
								if directionvec == nil then 
									directionvec = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
								end
								local longJumpCFrame = Vector3.new(directionvec.X, 0, directionvec.Z)
								local newvelo = longJumpCFrame.Unit == longJumpCFrame.Unit and longJumpCFrame.Unit * (newnum > 1 and damagetimer or 20) or Vector3.zero
								newvelo = Vector3.new(newvelo.X, 0, newvelo.Z)
								longJumpCFrame = longJumpCFrame * (getSpeed() + 3) * dt
								local ray = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, longJumpCFrame, bedwarsStore.blockRaycast)
								if ray then 
									longJumpCFrame = Vector3.zero
									newvelo = Vector3.zero
								end

								entityLibrary.character.HumanoidRootPart.Velocity = newvelo
								entityLibrary.character.HumanoidRootPart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame + longJumpCFrame
							else
								LongJumpacprogressbartext.Text = "2.5s"
								entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(LongJumpOrigin, LongJumpOrigin + entityLibrary.character.HumanoidRootPart.CFrame.lookVector)
								entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
								if tntcheck then 
									entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(tntcheck + entityLibrary.character.HumanoidRootPart.CFrame.lookVector, tntcheck + (entityLibrary.character.HumanoidRootPart.CFrame.lookVector * 2))
								end
							end
						else
							if LongJumpacprogressbartext then 
								LongJumpacprogressbartext.Text = "2.5s"
							end
							LongJumpOrigin = nil
							tntcheck = nil
						end
					end)
				end)
			else
				LongJumpacprogressbarframe.Visible = false
				RunLoops:UnbindFromHeartbeat("LongJump")
				directionvec = nil
				tntcheck = nil
				LongJumpOrigin = nil
				damagetimer = 0
				damagetimertick = 0
			end
		end, 
		HoverText = "Lets you jump farther (Not landing on same level & Spamming can lead to lagbacks)"
	})
	LongJumpSpeed = LongJump.CreateSlider({
		Name = "Speed",
		Min = 1,
		Max = 52,
		Function = function() end,
		Default = 52
	})
end)

runFunction(function()
	local NoFall = {Enabled = false}
	local oldfall
	NoFall = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "NoFall",
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat
						task.wait(0.5)
						bedwars.ClientHandler:Get("GroundHit"):SendToServer()
					until (not NoFall.Enabled)
				end)
			end
		end, 
		HoverText = "Prevents taking fall damage."
	})
end)

runFunction(function()
	local NoSlowdown = {Enabled = false}
	local OldSetSpeedFunc
	NoSlowdown = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "NoSlowdown",
		Function = function(callback)
			if callback then
				OldSetSpeedFunc = bedwars.SprintController.setSpeed
				bedwars.SprintController.setSpeed = function(tab1, val1)
					local hum = entityLibrary.character.Humanoid
					if hum then
						hum.WalkSpeed = math.max(20 * tab1.moveSpeedMultiplier, 20)
					end
				end
				bedwars.SprintController:setSpeed(20)
			else
				bedwars.SprintController.setSpeed = OldSetSpeedFunc
				bedwars.SprintController:setSpeed(20)
				OldSetSpeedFunc = nil
			end
		end, 
		HoverText = "Prevents slowing down when using items."
	})
end)

local spiderActive = false
local holdingshift = false
runFunction(function()
	local activatePhase = false
	local oldActivatePhase = false
	local PhaseDelay = tick()
	local Phase = {Enabled = false}
	local PhaseStudLimit = {Value = 1}
	local PhaseModifiedParts = {}
	local raycastparameters = RaycastParams.new()
	raycastparameters.RespectCanCollide = true
	raycastparameters.FilterType = Enum.RaycastFilterType.Whitelist
	local overlapparams = OverlapParams.new()
	overlapparams.RespectCanCollide = true

	local function isPointInMapOccupied(p)
		overlapparams.FilterDescendantsInstances = {lplr.Character, gameCamera}
		local possible = workspace:GetPartBoundsInBox(CFrame.new(p), Vector3.new(1, 2, 1), overlapparams)
		return (#possible == 0)
	end

	Phase = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "Phase",
		Function = function(callback)
			if callback then
				RunLoops:BindToHeartbeat("Phase", function()
					if entityLibrary.isAlive and entityLibrary.character.Humanoid.MoveDirection ~= Vector3.zero and (not GuiLibrary.ObjectsThatCanBeSaved.SpiderOptionsButton.Api.Enabled or holdingshift) then
						if PhaseDelay <= tick() then
							raycastparameters.FilterDescendantsInstances = {bedwarsStore.blocks, collectionService:GetTagged("spawn-cage"), workspace.SpectatorPlatform}
							local PhaseRayCheck = workspace:Raycast(entityLibrary.character.Head.CFrame.p, entityLibrary.character.Humanoid.MoveDirection * 1.15, raycastparameters)
							if PhaseRayCheck then
								local PhaseDirection = (PhaseRayCheck.Normal.Z ~= 0 or not PhaseRayCheck.Instance:GetAttribute("GreedyBlock")) and "Z" or "X"
								if PhaseRayCheck.Instance.Size[PhaseDirection] <= PhaseStudLimit.Value * 3 and PhaseRayCheck.Instance.CanCollide and PhaseRayCheck.Normal.Y == 0 then
									local PhaseDestination = entityLibrary.character.HumanoidRootPart.CFrame + (PhaseRayCheck.Normal * (-(PhaseRayCheck.Instance.Size[PhaseDirection]) - (entityLibrary.character.HumanoidRootPart.Size.X / 1.5)))
									if isPointInMapOccupied(PhaseDestination.p) then
										PhaseDelay = tick() + 1
										entityLibrary.character.HumanoidRootPart.CFrame = PhaseDestination
									end
								end
							end
						end
					end
				end)
			else
				RunLoops:UnbindFromHeartbeat("Phase")
			end
		end,
		HoverText = "Lets you Phase/Clip through walls. (Hold shift to use Phase over spider)"
	})
	PhaseStudLimit = Phase.CreateSlider({
		Name = "Blocks",
		Min = 1,
		Max = 3,
		Function = function() end
	})
end)

runFunction(function()
	local oldCalculateAim
	local BowAimbotProjectiles = {Enabled = false}
	local BowAimbotPart = {Value = "HumanoidRootPart"}
	local BowAimbotFOV = {Value = 1000}
	local BowAimbot = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "ProjectileAimbot",
		Function = function(callback)
			if callback then
				oldCalculateAim = bedwars.ProjectileController.calculateImportantLaunchValues
				bedwars.ProjectileController.calculateImportantLaunchValues = function(self, projmeta, worldmeta, shootpospart, ...)
					local plr = EntityNearMouse(BowAimbotFOV.Value)
					if plr then
						local startPos = self:getLaunchPosition(shootpospart)
						if not startPos then
							return oldCalculateAim(self, projmeta, worldmeta, shootpospart, ...)
						end

						if (not BowAimbotProjectiles.Enabled) and projmeta.projectile:find("arrow") == nil then
							return oldCalculateAim(self, projmeta, worldmeta, shootpospart, ...)
						end

						local projmetatab = projmeta:getProjectileMeta()
						local projectilePrediction = (worldmeta and projmetatab.predictionLifetimeSec or projmetatab.lifetimeSec or 3)
						local projectileSpeed = (projmetatab.launchVelocity or 100)
						local gravity = (projmetatab.gravitationalAcceleration or 196.2)
						local projectileGravity = gravity * projmeta.gravityMultiplier
						local offsetStartPos = startPos + projmeta.fromPositionOffset
						local pos = plr.Character[BowAimbotPart.Value].Position
						local playerGravity = workspace.Gravity
						local balloons = plr.Character:GetAttribute("InflatedBalloons")

						if balloons and balloons > 0 then 
							playerGravity = (workspace.Gravity * (1 - ((balloons >= 4 and 1.2 or balloons >= 3 and 1 or 0.975))))
						end

						if plr.Character.PrimaryPart:FindFirstChild("rbxassetid://8200754399") then 
							playerGravity = (workspace.Gravity * 0.3)
						end

						local shootpos, shootvelo = predictGravity(pos, plr.Character.HumanoidRootPart.Velocity, (pos - offsetStartPos).Magnitude / projectileSpeed, plr, playerGravity)
						if projmeta.projectile == "telepearl" then
							shootpos = pos
							shootvelo = Vector3.zero
						end
						
						local newlook = CFrame.new(offsetStartPos, shootpos) * CFrame.new(Vector3.new(-bedwars.BowConstantsTable.RelX, -bedwars.BowConstantsTable.RelY, 0))
						shootpos = newlook.p + (newlook.lookVector * (offsetStartPos - shootpos).magnitude)
						local calculated = LaunchDirection(offsetStartPos, shootpos, projectileSpeed, projectileGravity, false)
						oldmove = plr.Character.Humanoid.MoveDirection
						if calculated then
							return {
								initialVelocity = calculated,
								positionFrom = offsetStartPos,
								deltaT = projectilePrediction,
								gravitationalAcceleration = projectileGravity,
								drawDurationSeconds = 5
							}
						end
					end
					return oldCalculateAim(self, projmeta, worldmeta, shootpospart, ...)
				end
			else
				bedwars.ProjectileController.calculateImportantLaunchValues = oldCalculateAim
			end
		end
	})
	BowAimbotPart = BowAimbot.CreateDropdown({
		Name = "Part",
		List = {"HumanoidRootPart", "Head"},
		Function = function() end
	})
	BowAimbotFOV = BowAimbot.CreateSlider({
		Name = "FOV",
		Function = function() end,
		Min = 1,
		Max = 1000,
		Default = 1000
	})
	BowAimbotProjectiles = BowAimbot.CreateToggle({
		Name = "Other Projectiles",
		Function = function() end,
		Default = true
	})
end)

--until I find a way to make the spam switch item thing not bad I'll just get rid of it, sorry.

local Scaffold = {Enabled = false}
runFunction(function()
	local scaffoldtext = Instance.new("TextLabel")
	scaffoldtext.Font = Enum.Font.SourceSans
	scaffoldtext.TextSize = 20
	scaffoldtext.BackgroundTransparency = 1
	scaffoldtext.TextColor3 = Color3.fromRGB(255, 0, 0)
	scaffoldtext.Size = UDim2.new(0, 0, 0, 0)
	scaffoldtext.Position = UDim2.new(0.5, 0, 0.5, 30)
	scaffoldtext.Text = "0"
	scaffoldtext.Visible = false
	scaffoldtext.Parent = GuiLibrary.MainGui
	local ScaffoldExpand = {Value = 1}
	local ScaffoldDiagonal = {Enabled = false}
	local ScaffoldTower = {Enabled = false}
	local ScaffoldDownwards = {Enabled = false}
	local ScaffoldStopMotion = {Enabled = false}
	local ScaffoldBlockCount = {Enabled = false}
	local ScaffoldHandCheck = {Enabled = false}
	local ScaffoldMouseCheck = {Enabled = false}
	local ScaffoldAnimation = {Enabled = false}
	local scaffoldstopmotionval = false
	local scaffoldposcheck = tick()
	local scaffoldstopmotionpos = Vector3.zero
	local scaffoldposchecklist = {}
	task.spawn(function()
		for x = -3, 3, 3 do 
			for y = -3, 3, 3 do 
				for z = -3, 3, 3 do 
					if Vector3.new(x, y, z) ~= Vector3.new(0, 0, 0) then 
						table.insert(scaffoldposchecklist, Vector3.new(x, y, z)) 
					end 
				end 
			end 
		end
	end)

	local function checkblocks(pos)
		for i,v in pairs(scaffoldposchecklist) do
			if getPlacedBlock(pos + v) then
				return true
			end
		end
		return false
	end

	local function closestpos(block, pos)
		local startpos = block.Position - (block.Size / 2) - Vector3.new(1.5, 1.5, 1.5)
		local endpos = block.Position + (block.Size / 2) + Vector3.new(1.5, 1.5, 1.5)
		local speedCFrame = block.Position + (pos - block.Position)
		return Vector3.new(math.clamp(speedCFrame.X, startpos.X, endpos.X), math.clamp(speedCFrame.Y, startpos.Y, endpos.Y), math.clamp(speedCFrame.Z, startpos.Z, endpos.Z))
	end

	local function getclosesttop(newmag, pos)
		local closest, closestmag = pos, newmag * 3
		if entityLibrary.isAlive then 
			for i,v in pairs(bedwarsStore.blocks) do 
				local close = closestpos(v, pos)
				local mag = (close - pos).magnitude
				if mag <= closestmag then 
					closest = close
					closestmag = mag
				end
			end
		end
		return closest
	end

	local oldspeed
	Scaffold = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "Scaffold",
		Function = function(callback)
			if callback then
				scaffoldtext.Visible = ScaffoldBlockCount.Enabled
				if entityLibrary.isAlive then 
					scaffoldstopmotionpos = entityLibrary.character.HumanoidRootPart.CFrame.p
				end
				task.spawn(function()
					repeat
						task.wait()
						if ScaffoldHandCheck.Enabled then 
							if bedwarsStore.localHand.Type ~= "block" then continue end
						end
						if ScaffoldMouseCheck.Enabled then 
							if not inputService:IsMouseButtonPressed(0) then continue end
						end
						if entityLibrary.isAlive then
							local wool, woolamount = getWool()
							if bedwarsStore.localHand.Type == "block" then
								wool = bedwarsStore.localHand.tool.Name
								woolamount = getItem(bedwarsStore.localHand.tool.Name).amount or 0
							elseif (not wool) then 
								wool, woolamount = getBlock()
							end

							scaffoldtext.Text = (woolamount and tostring(woolamount) or "0")
							scaffoldtext.TextColor3 = woolamount and (woolamount >= 128 and Color3.fromRGB(9, 255, 198) or woolamount >= 64 and Color3.fromRGB(255, 249, 18)) or Color3.fromRGB(255, 0, 0)
							if not wool then continue end

							local towering = ScaffoldTower.Enabled and inputService:IsKeyDown(Enum.KeyCode.Space) and game:GetService("UserInputService"):GetFocusedTextBox() == nil
							if towering then
								if (not scaffoldstopmotionval) and ScaffoldStopMotion.Enabled then
									scaffoldstopmotionval = true
									scaffoldstopmotionpos = entityLibrary.character.HumanoidRootPart.CFrame.p
								end
								entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(entityLibrary.character.HumanoidRootPart.Velocity.X, 28, entityLibrary.character.HumanoidRootPart.Velocity.Z)
								if ScaffoldStopMotion.Enabled and scaffoldstopmotionval then
									entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(Vector3.new(scaffoldstopmotionpos.X, entityLibrary.character.HumanoidRootPart.CFrame.p.Y, scaffoldstopmotionpos.Z))
								end
							else
								scaffoldstopmotionval = false
							end
							
							for i = 1, ScaffoldExpand.Value do
								local speedCFrame = getScaffold((entityLibrary.character.HumanoidRootPart.Position + ((scaffoldstopmotionval and Vector3.zero or entityLibrary.character.Humanoid.MoveDirection) * (i * 3.5))) + Vector3.new(0, -((entityLibrary.character.HumanoidRootPart.Size.Y / 2) + entityLibrary.character.Humanoid.HipHeight + (inputService:IsKeyDown(Enum.KeyCode.LeftShift) and ScaffoldDownwards.Enabled and 4.5 or 1.5))), 0)
								speedCFrame = Vector3.new(speedCFrame.X, speedCFrame.Y - (towering and 4 or 0), speedCFrame.Z)
								if speedCFrame ~= oldpos then
									if not checkblocks(speedCFrame) then
										local oldspeedCFrame = speedCFrame
										speedCFrame = getScaffold(getclosesttop(20, speedCFrame))
										if getPlacedBlock(speedCFrame) then speedCFrame = oldspeedCFrame end
									end
									if ScaffoldAnimation.Enabled then 
										if not getPlacedBlock(speedCFrame) then
										bedwars.ViewmodelController:playAnimation(bedwars.AnimationType.FP_USE_ITEM)
										end
									end
									task.spawn(bedwars.placeBlock, speedCFrame, wool, ScaffoldAnimation.Enabled)
									if ScaffoldExpand.Value > 1 then 
										task.wait()
									end
									oldpos = speedCFrame
								end
							end
						end
					until (not Scaffold.Enabled)
				end)
			else
				scaffoldtext.Visible = false
				oldpos = Vector3.zero
				oldpos2 = Vector3.zero
			end
		end, 
		HoverText = "Helps you make bridges/scaffold walk."
	})
	ScaffoldExpand = Scaffold.CreateSlider({
		Name = "Expand",
		Min = 1,
		Max = 8,
		Function = function(val) end,
		Default = 1,
		HoverText = "Build range"
	})
	ScaffoldDiagonal = Scaffold.CreateToggle({
		Name = "Diagonal", 
		Function = function(callback) end,
		Default = true
	})
	ScaffoldTower = Scaffold.CreateToggle({
		Name = "Tower", 
		Function = function(callback) 
			if ScaffoldStopMotion.Object then
				ScaffoldTower.Object.ToggleArrow.Visible = callback
				ScaffoldStopMotion.Object.Visible = callback
			end
		end
	})
	ScaffoldMouseCheck = Scaffold.CreateToggle({
		Name = "Require mouse down", 
		Function = function(callback) end,
		HoverText = "Only places when left click is held.",
	})
	ScaffoldDownwards  = Scaffold.CreateToggle({
		Name = "Downwards", 
		Function = function(callback) end,
		HoverText = "Goes down when left shift is held."
	})
	ScaffoldStopMotion = Scaffold.CreateToggle({
		Name = "Stop Motion",
		Function = function() end,
		HoverText = "Stops your movement when going up"
	})
	ScaffoldStopMotion.Object.BackgroundTransparency = 0
	ScaffoldStopMotion.Object.BorderSizePixel = 0
	ScaffoldStopMotion.Object.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	ScaffoldStopMotion.Object.Visible = ScaffoldTower.Enabled
	ScaffoldBlockCount = Scaffold.CreateToggle({
		Name = "Block Count",
		Function = function(callback) 
			if Scaffold.Enabled then
				scaffoldtext.Visible = callback 
			end
		end,
		HoverText = "Shows the amount of blocks in the middle."
	})
	ScaffoldHandCheck = Scaffold.CreateToggle({
		Name = "Whitelist Only",
		Function = function() end,
		HoverText = "Only builds with blocks in your hand."
	})
	ScaffoldAnimation = Scaffold.CreateToggle({
		Name = "Animation",
		Function = function() end
	})
end)

local antivoidvelo
runFunction(function()
	local Speed = {Enabled = false}
	local SpeedMode = {Value = "CFrame"}
	local SpeedValue = {Value = 1}
	local SpeedValueLarge = {Value = 1}
	local SpeedDamageBoost = {Enabled = false}
	local SpeedJump = {Enabled = false}
	local SpeedJumpHeight = {Value = 20}
	local SpeedJumpAlways = {Enabled = false}
	local SpeedJumpSound = {Enabled = false}
	local SpeedJumpVanilla = {Enabled = false}
	local SpeedAnimation = {Enabled = false}
	local raycastparameters = RaycastParams.new()
	local damagetick = tick()

	local alternatelist = {"Normal", "AntiCheat A", "AntiCheat B"}
	Speed = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "Speed",
		Function = function(callback)
			if callback then
				table.insert(Speed.Connections, vapeEvents.EntityDamageEvent.Event:Connect(function(damageTable)
					if damageTable.entityInstance == lplr.Character and (damageTable.damageType ~= 0 or damageTable.extra and damageTable.extra.chargeRatio ~= nil) and (not (damageTable.knockbackMultiplier and damageTable.knockbackMultiplier.disabled or damageTable.knockbackMultiplier and damageTable.knockbackMultiplier.horizontal == 0)) and SpeedDamageBoost.Enabled then 
						damagetick = tick() + 0.4
					end
				end))
				RunLoops:BindToHeartbeat("Speed", function(delta)
					if GuiLibrary.ObjectsThatCanBeSaved["Lobby CheckToggle"].Api.Enabled then
						if bedwarsStore.matchState == 0 then return end
					end
					if entityLibrary.isAlive then
						if not (isnetworkowner(entityLibrary.character.HumanoidRootPart) and entityLibrary.character.Humanoid:GetState() ~= Enum.HumanoidStateType.Climbing and (not spiderActive) and (not GuiLibrary.ObjectsThatCanBeSaved.InfiniteFlyOptionsButton.Api.Enabled) and (not GuiLibrary.ObjectsThatCanBeSaved.FlyOptionsButton.Api.Enabled)) then return end
						if GuiLibrary.ObjectsThatCanBeSaved.GrappleExploitOptionsButton and GuiLibrary.ObjectsThatCanBeSaved.GrappleExploitOptionsButton.Api.Enabled then return end
						if LongJump.Enabled then return end
						if SpeedAnimation.Enabled then
							for i, v in pairs(entityLibrary.character.Humanoid:GetPlayingAnimationTracks()) do
								if v.Name == "WalkAnim" or v.Name == "RunAnim" then
									v:AdjustSpeed(entityLibrary.character.Humanoid.WalkSpeed / 16)
								end
							end
						end

						local speedValue = SpeedValue.Value + getSpeed()
						if damagetick > tick() then speedValue = speedValue + 20 end

						local speedVelocity = entityLibrary.character.Humanoid.MoveDirection * (SpeedMode.Value == "Normal" and SpeedValue.Value or 20)
						entityLibrary.character.HumanoidRootPart.Velocity = antivoidvelo or Vector3.new(speedVelocity.X, entityLibrary.character.HumanoidRootPart.Velocity.Y, speedVelocity.Z)
						if SpeedMode.Value ~= "Normal" then 
							local speedCFrame = entityLibrary.character.Humanoid.MoveDirection * (speedValue - 20) * delta
							raycastparameters.FilterDescendantsInstances = {lplr.Character}
							local ray = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, speedCFrame, raycastparameters)
							if ray then speedCFrame = (ray.Position - entityLibrary.character.HumanoidRootPart.Position) end
							entityLibrary.character.HumanoidRootPart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame + speedCFrame
						end

						if SpeedJump.Enabled and (not Scaffold.Enabled) and (SpeedJumpAlways.Enabled or killauraNearPlayer) then
							if (entityLibrary.character.Humanoid.FloorMaterial ~= Enum.Material.Air) and entityLibrary.character.Humanoid.MoveDirection ~= Vector3.zero then
								if SpeedJumpSound.Enabled then 
									pcall(function() entityLibrary.character.HumanoidRootPart.Jumping:Play() end)
								end
								if SpeedJumpVanilla.Enabled then 
									entityLibrary.character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
								else
									entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(entityLibrary.character.HumanoidRootPart.Velocity.X, SpeedJumpHeight.Value, entityLibrary.character.HumanoidRootPart.Velocity.Z)
								end
							end 
						end
					end
				end)
			else
				RunLoops:UnbindFromHeartbeat("Speed")
			end
		end, 
		HoverText = "Increases your movement.",
		ExtraText = function() 
			return "Heatseeker"
		end
	})
	SpeedValue = Speed.CreateSlider({
		Name = "Speed",
		Min = 1,
		Max = 23,
		Function = function(val) end,
		Default = 23
	})
	SpeedValueLarge = Speed.CreateSlider({
		Name = "Big Mode Speed",
		Min = 1,
		Max = 23,
		Function = function(val) end,
		Default = 23
	})
	SpeedDamageBoost = Speed.CreateToggle({
		Name = "Damage Boost",
		Function = function() end,
		Default = true
	})
	SpeedJump = Speed.CreateToggle({
		Name = "AutoJump", 
		Function = function(callback) 
			if SpeedJumpHeight.Object then SpeedJumpHeight.Object.Visible = callback end
			if SpeedJumpAlways.Object then
				SpeedJump.Object.ToggleArrow.Visible = callback
				SpeedJumpAlways.Object.Visible = callback
			end
			if SpeedJumpSound.Object then SpeedJumpSound.Object.Visible = callback end
			if SpeedJumpVanilla.Object then SpeedJumpVanilla.Object.Visible = callback end
		end,
		Default = true
	})
	SpeedJumpHeight = Speed.CreateSlider({
		Name = "Jump Height",
		Min = 0,
		Max = 30,
		Default = 25,
		Function = function() end
	})
	SpeedJumpAlways = Speed.CreateToggle({
		Name = "Always Jump",
		Function = function() end
	})
	SpeedJumpSound = Speed.CreateToggle({
		Name = "Jump Sound",
		Function = function() end
	})
	SpeedJumpVanilla = Speed.CreateToggle({
		Name = "Real Jump",
		Function = function() end
	})
	SpeedAnimation = Speed.CreateToggle({
		Name = "Slowdown Anim",
		Function = function() end
	})
end)

runFunction(function()
	local function roundpos(dir, pos, size)
		local suc, res = pcall(function() return Vector3.new(math.clamp(dir.X, pos.X - (size.X / 2), pos.X + (size.X / 2)), math.clamp(dir.Y, pos.Y - (size.Y / 2), pos.Y + (size.Y / 2)), math.clamp(dir.Z, pos.Z - (size.Z / 2), pos.Z + (size.Z / 2))) end)
		return suc and res or Vector3.zero
	end

	local Spider = {Enabled = false}
	local SpiderSpeed = {Value = 0}
	local SpiderMode = {Value = "Normal"}
	local SpiderPart
	Spider = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "Spider",
		Function = function(callback)
			if callback then
				table.insert(Spider.Connections, inputService.InputBegan:Connect(function(input1)
					if input1.KeyCode == Enum.KeyCode.LeftShift then 
						holdingshift = true
					end
				end))
				table.insert(Spider.Connections, inputService.InputEnded:Connect(function(input1)
					if input1.KeyCode == Enum.KeyCode.LeftShift then 
						holdingshift = false
					end
				end))
				RunLoops:BindToHeartbeat("Spider", function()
					if entityLibrary.isAlive and (GuiLibrary.ObjectsThatCanBeSaved.PhaseOptionsButton.Api.Enabled == false or holdingshift == false) then
						if SpiderMode.Value == "Normal" then
							local vec = entityLibrary.character.Humanoid.MoveDirection * 2
							local newray = getPlacedBlock(entityLibrary.character.HumanoidRootPart.Position + (vec + Vector3.new(0, 0.1, 0)))
							local newray2 = getPlacedBlock(entityLibrary.character.HumanoidRootPart.Position + (vec - Vector3.new(0, entityLibrary.character.Humanoid.HipHeight, 0)))
							if newray and (not newray.CanCollide) then newray = nil end 
							if newray2 and (not newray2.CanCollide) then newray2 = nil end 
							if spiderActive and (not newray) and (not newray2) then
								entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(entityLibrary.character.HumanoidRootPart.Velocity.X, 0, entityLibrary.character.HumanoidRootPart.Velocity.Z)
							end
							spiderActive = ((newray or newray2) and true or false)
							if (newray or newray2) then
								entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(newray2 and newray == nil and entityLibrary.character.HumanoidRootPart.Velocity.X or 0, SpiderSpeed.Value, newray2 and newray == nil and entityLibrary.character.HumanoidRootPart.Velocity.Z or 0)
							end
						else
							if not SpiderPart then 
								SpiderPart = Instance.new("TrussPart")
								SpiderPart.Size = Vector3.new(2, 2, 2)
								SpiderPart.Transparency = 1
								SpiderPart.Anchored = true
								SpiderPart.Parent = gameCamera
							end
							local newray2, newray2pos = getPlacedBlock(entityLibrary.character.HumanoidRootPart.Position + ((entityLibrary.character.HumanoidRootPart.CFrame.lookVector * 1.5) - Vector3.new(0, entityLibrary.character.Humanoid.HipHeight, 0)))
							if newray2 and (not newray2.CanCollide) then newray2 = nil end
							spiderActive = (newray2 and true or false)
							if newray2 then 
								newray2pos = newray2pos * 3
								local newpos = roundpos(entityLibrary.character.HumanoidRootPart.Position, Vector3.new(newray2pos.X, math.min(entityLibrary.character.HumanoidRootPart.Position.Y, newray2pos.Y), newray2pos.Z), Vector3.new(1.1, 1.1, 1.1))
								SpiderPart.Position = newpos
							else
								SpiderPart.Position = Vector3.zero
							end
						end
					end
				end)
			else
				if SpiderPart then SpiderPart:Destroy() end
				RunLoops:UnbindFromHeartbeat("Spider")
				holdingshift = false
			end
		end,
		HoverText = "Lets you climb up walls"
	})
	SpiderMode = Spider.CreateDropdown({
		Name = "Mode",
		List = {"Normal", "Classic"},
		Function = function() 
			if SpiderPart then SpiderPart:Destroy() end
		end
	})
	SpiderSpeed = Spider.CreateSlider({
		Name = "Speed",
		Min = 0,
		Max = 40,
		Function = function() end,
		Default = 40
	})
end)

runFunction(function()
	local TargetStrafe = {Enabled = false}
	local TargetStrafeRange = {Value = 18}
	local oldmove
	local controlmodule
	local block
	TargetStrafe = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "TargetStrafe",
		Function = function(callback)
			if callback then 
				task.spawn(function()
					if not controlmodule then
						local suc = pcall(function() controlmodule = require(lplr.PlayerScripts.PlayerModule).controls end)
						if not suc then controlmodule = {} end
					end
					oldmove = controlmodule.moveFunction
					local ang = 0
					local oldplr
					block = Instance.new("Part")
					block.Anchored = true
					block.CanCollide = false
					block.Parent = gameCamera
					controlmodule.moveFunction = function(Self, vec, facecam, ...)
						if entityLibrary.isAlive then
							local plr = AllNearPosition(TargetStrafeRange.Value + 5, 10)[1]
							plr = plr and (not workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, (plr.RootPart.Position - entityLibrary.character.HumanoidRootPart.Position), bedwarsStore.blockRaycast)) and workspace:Raycast(plr.RootPart.Position, Vector3.new(0, -70, 0), bedwarsStore.blockRaycast) and plr or nil
							if plr ~= oldplr then
								if plr then
									local x, y, z = CFrame.new(plr.RootPart.Position, entityLibrary.character.HumanoidRootPart.Position):ToEulerAnglesXYZ()
									ang = math.deg(z)
								end
								oldplr = plr
							end
							if plr then 
								facecam = false
								local localPos = CFrame.new(plr.RootPart.Position)
								local ray = workspace:Blockcast(localPos, Vector3.new(3, 3, 3), CFrame.Angles(0, math.rad(ang), 0).lookVector * TargetStrafeRange.Value, bedwarsStore.blockRaycast)
								local newPos = localPos + (CFrame.Angles(0, math.rad(ang), 0).lookVector * (ray and ray.Distance - 1 or TargetStrafeRange.Value))
								local factor = getSpeed() > 0 and 6 or 4
								if not workspace:Raycast(newPos.p, Vector3.new(0, -70, 0), bedwarsStore.blockRaycast) then 
									newPos = localPos
									factor = 40
								end
								if ((entityLibrary.character.HumanoidRootPart.Position * Vector3.new(1, 0, 1)) - (newPos.p * Vector3.new(1, 0, 1))).Magnitude < 4 or ray then
									ang = ang + factor % 360
								end
								block.Position = newPos.p
								vec = (newPos.p - entityLibrary.character.HumanoidRootPart.Position) * Vector3.new(1, 0, 1)
							end
						end
						return oldmove(Self, vec, facecam, ...)
					end
				end)
			else
				block:Destroy()
				controlmodule.moveFunction = oldmove
			end
		end
	})
	TargetStrafeRange = TargetStrafe.CreateSlider({
		Name = "Range",
		Min = 0,
		Max = 18,
		Function = function() end
	})
end)

runFunction(function()
	local BedESP = {Enabled = false}
	local BedESPFolder = Instance.new("Folder")
	BedESPFolder.Name = "BedESPFolder"
	BedESPFolder.Parent = GuiLibrary.MainGui
	local BedESPTable = {}
	local BedESPColor = {Value = 0.44}
	local BedESPTransparency = {Value = 1}
	local BedESPOnTop = {Enabled = true}
	BedESP = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "BedESP",
		Function = function(callback) 
			if callback then
				table.insert(BedESP.Connections, collectionService:GetInstanceAddedSignal("bed"):Connect(function(bed)
					task.wait(0.2)
					if not BedESP.Enabled then return end
					local BedFolder = Instance.new("Folder")
					BedFolder.Parent = BedESPFolder
					BedESPTable[bed] = BedFolder
					for bedespnumber, bedesppart in pairs(bed:GetChildren()) do
						local boxhandle = Instance.new("BoxHandleAdornment")
						boxhandle.Size = bedesppart.Size + Vector3.new(.01, .01, .01)
						boxhandle.AlwaysOnTop = true
						boxhandle.ZIndex = (bedesppart.Name == "Covers" and 10 or 0)
						boxhandle.Visible = true
						boxhandle.Adornee = bedesppart
						boxhandle.Color3 = bedesppart.Color
						boxhandle.Name = bedespnumber
						boxhandle.Parent = BedFolder
					end
				end))
				table.insert(BedESP.Connections, collectionService:GetInstanceRemovedSignal("bed"):Connect(function(bed)
					if BedESPTable[bed] then 
						BedESPTable[bed]:Destroy()
						BedESPTable[bed] = nil
					end
				end))
				for i, bed in pairs(collectionService:GetTagged("bed")) do 
					local BedFolder = Instance.new("Folder")
					BedFolder.Parent = BedESPFolder
					BedESPTable[bed] = BedFolder
					for bedespnumber, bedesppart in pairs(bed:GetChildren()) do
						if bedesppart:IsA("BasePart") then
							local boxhandle = Instance.new("BoxHandleAdornment")
							boxhandle.Size = bedesppart.Size + Vector3.new(.01, .01, .01)
							boxhandle.AlwaysOnTop = true
							boxhandle.ZIndex = (bedesppart.Name == "Covers" and 10 or 0)
							boxhandle.Visible = true
							boxhandle.Adornee = bedesppart
							boxhandle.Color3 = bedesppart.Color
							boxhandle.Parent = BedFolder
						end
					end
				end
			else
				BedESPFolder:ClearAllChildren()
				table.clear(BedESPTable)
			end
		end,
		HoverText = "Render Beds through walls" 
	})
end)

runFunction(function()
	local function getallblocks2(pos, normal)
		local blocks = {}
		local lastfound = nil
		for i = 1, 20 do
			local blockpos = (pos + (Vector3.FromNormalId(normal) * (i * 3)))
			local extrablock = getPlacedBlock(blockpos)
			local covered = true
			if extrablock and extrablock.Parent ~= nil then
				if bedwars.BlockController:isBlockBreakable({blockPosition = blockpos}, lplr) then
					table.insert(blocks, extrablock:GetAttribute("NoBreak") and "unbreakable" or extrablock.Name)
				else
					table.insert(blocks, "unbreakable")
					break
				end
				lastfound = extrablock
				if covered == false then
					break
				end
			else
				break
			end
		end
		return blocks
	end

	local function getallbedblocks(pos)
		local blocks = {}
		for i,v in pairs(cachedNormalSides) do
			for i2,v2 in pairs(getallblocks2(pos, v)) do	
				if table.find(blocks, v2) == nil and v2 ~= "bed" then
					table.insert(blocks, v2)
				end
			end
			for i2,v2 in pairs(getallblocks2(pos + Vector3.new(0, 0, 3), v)) do	
				if table.find(blocks, v2) == nil and v2 ~= "bed" then
					table.insert(blocks, v2)
				end
			end
		end
		return blocks
	end

	local function refreshAdornee(v)
		local bedblocks = getallbedblocks(v.Adornee.Position)
		for i2,v2 in pairs(v.Frame:GetChildren()) do
			if v2:IsA("ImageLabel") then
				v2:Remove()
			end
		end
		for i3,v3 in pairs(bedblocks) do
			local blockimage = Instance.new("ImageLabel")
			blockimage.Size = UDim2.new(0, 32, 0, 32)
			blockimage.BackgroundTransparency = 1
			blockimage.Image = bedwars.getIcon({itemType = v3}, true)
			blockimage.Parent = v.Frame
		end
	end

	local BedPlatesFolder = Instance.new("Folder")
	BedPlatesFolder.Name = "BedPlatesFolder"
	BedPlatesFolder.Parent = GuiLibrary.MainGui
	local BedPlatesTable = {}
	local BedPlates = {Enabled = false}

	local function addBed(v)
		local billboard = Instance.new("BillboardGui")
		billboard.Parent = BedPlatesFolder
		billboard.Name = "bed"
		billboard.StudsOffsetWorldSpace = Vector3.new(0, 3, 1.5)
		billboard.Size = UDim2.new(0, 42, 0, 42)
		billboard.AlwaysOnTop = true
		billboard.Adornee = v
		BedPlatesTable[v] = billboard
		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(1, 0, 1, 0)
		frame.BackgroundColor3 = Color3.new(0, 0, 0)
		frame.BackgroundTransparency = 0.5
		frame.Parent = billboard
		local uilistlayout = Instance.new("UIListLayout")
		uilistlayout.FillDirection = Enum.FillDirection.Horizontal
		uilistlayout.Padding = UDim.new(0, 4)
		uilistlayout.VerticalAlignment = Enum.VerticalAlignment.Center
		uilistlayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		uilistlayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			billboard.Size = UDim2.new(0, math.max(uilistlayout.AbsoluteContentSize.X + 12, 42), 0, 42)
		end)
		uilistlayout.Parent = frame
		local uicorner = Instance.new("UICorner")
		uicorner.CornerRadius = UDim.new(0, 4)
		uicorner.Parent = frame
		refreshAdornee(billboard)
	end

	BedPlates = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "BedPlates",
		Function = function(callback)
			if callback then
				table.insert(BedPlates.Connections, vapeEvents.PlaceBlockEvent.Event:Connect(function(p5)
					for i, v in pairs(BedPlatesFolder:GetChildren()) do 
						if v.Adornee then
							if ((p5.blockRef.blockPosition * 3) - v.Adornee.Position).magnitude <= 20 then
								refreshAdornee(v)
							end
						end
					end
				end))
				table.insert(BedPlates.Connections, vapeEvents.BreakBlockEvent.Event:Connect(function(p5)
					for i, v in pairs(BedPlatesFolder:GetChildren()) do 
						if v.Adornee then
							if ((p5.blockRef.blockPosition * 3) - v.Adornee.Position).magnitude <= 20 then
								refreshAdornee(v)
							end
						end
					end
				end))
				table.insert(BedPlates.Connections, collectionService:GetInstanceAddedSignal("bed"):Connect(function(v)
					addBed(v)
				end))
				table.insert(BedPlates.Connections, collectionService:GetInstanceRemovedSignal("bed"):Connect(function(v)
					if BedPlatesTable[v] then 
						BedPlatesTable[v]:Destroy()
						BedPlatesTable[v] = nil
					end
				end))
				for i, v in pairs(collectionService:GetTagged("bed")) do
					addBed(v)
				end
			else
				BedPlatesFolder:ClearAllChildren()
			end
		end
	})
end)

runFunction(function()
	local ChestESPList = {ObjectList = {}, RefreshList = function() end}
	local function nearchestitem(item)
		for i,v in pairs(ChestESPList.ObjectList) do 
			if item:find(v) then return v end
		end
	end
	local function refreshAdornee(v)
		local chest = v.Adornee.ChestFolderValue.Value
        local chestitems = chest and chest:GetChildren() or {}
		for i2,v2 in pairs(v.Frame:GetChildren()) do
			if v2:IsA("ImageLabel") then
				v2:Remove()
			end
		end
		v.Enabled = false
		local alreadygot = {}
		for itemNumber, item in pairs(chestitems) do
			if alreadygot[item.Name] == nil and (table.find(ChestESPList.ObjectList, item.Name) or nearchestitem(item.Name)) then 
				alreadygot[item.Name] = true
				v.Enabled = true
                local blockimage = Instance.new("ImageLabel")
                blockimage.Size = UDim2.new(0, 32, 0, 32)
                blockimage.BackgroundTransparency = 1
                blockimage.Image = bedwars.getIcon({itemType = item.Name}, true)
                blockimage.Parent = v.Frame
            end
		end
	end

	local ChestESPFolder = Instance.new("Folder")
	ChestESPFolder.Name = "ChestESPFolder"
	ChestESPFolder.Parent = GuiLibrary.MainGui
	local ChestESP = {Enabled = false}
	local ChestESPBackground = {Enabled = true}

	local function chestfunc(v)
		task.spawn(function()
			local billboard = Instance.new("BillboardGui")
			billboard.Parent = ChestESPFolder
			billboard.Name = "chest"
			billboard.StudsOffsetWorldSpace = Vector3.new(0, 3, 0)
			billboard.Size = UDim2.new(0, 42, 0, 42)
			billboard.AlwaysOnTop = true
			billboard.Adornee = v
			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(1, 0, 1, 0)
			frame.BackgroundColor3 = Color3.new(0, 0, 0)
			frame.BackgroundTransparency = ChestESPBackground.Enabled and 0.5 or 1
			frame.Parent = billboard
			local uilistlayout = Instance.new("UIListLayout")
			uilistlayout.FillDirection = Enum.FillDirection.Horizontal
			uilistlayout.Padding = UDim.new(0, 4)
			uilistlayout.VerticalAlignment = Enum.VerticalAlignment.Center
			uilistlayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			uilistlayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				billboard.Size = UDim2.new(0, math.max(uilistlayout.AbsoluteContentSize.X + 12, 42), 0, 42)
			end)
			uilistlayout.Parent = frame
			local uicorner = Instance.new("UICorner")
			uicorner.CornerRadius = UDim.new(0, 4)
			uicorner.Parent = frame
			local chest = v:WaitForChild("ChestFolderValue").Value
			if chest then 
				table.insert(ChestESP.Connections, chest.ChildAdded:Connect(function(item)
					if table.find(ChestESPList.ObjectList, item.Name) or nearchestitem(item.Name) then 
						refreshAdornee(billboard)
					end
				end))
				table.insert(ChestESP.Connections, chest.ChildRemoved:Connect(function(item)
					if table.find(ChestESPList.ObjectList, item.Name) or nearchestitem(item.Name) then 
						refreshAdornee(billboard)
					end
				end))
				refreshAdornee(billboard)
			end
		end)
	end

	ChestESP = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "ChestESP",
		Function = function(callback)
			if callback then
				task.spawn(function()
					table.insert(ChestESP.Connections, collectionService:GetInstanceAddedSignal("chest"):Connect(chestfunc))
					for i,v in pairs(collectionService:GetTagged("chest")) do chestfunc(v) end
				end)
			else
				ChestESPFolder:ClearAllChildren()
			end
		end
	})
	ChestESPList = ChestESP.CreateTextList({
		Name = "ItemList",
		TempText = "item or part of item",
		AddFunction = function()
			if ChestESP.Enabled then 
				ChestESP.ToggleButton(false)
				ChestESP.ToggleButton(false)
			end
		end,
		RemoveFunction = function()
			if ChestESP.Enabled then 
				ChestESP.ToggleButton(false)
				ChestESP.ToggleButton(false)
			end
		end
	})
	ChestESPBackground = ChestESP.CreateToggle({
		Name = "Background",
		Function = function()
			if ChestESP.Enabled then 
				ChestESP.ToggleButton(false)
				ChestESP.ToggleButton(false)
			end
		end,
		Default = true
	})
end)

runFunction(function()
	local FieldOfViewValue = {Value = 70}
	local oldfov
	local oldfov2
	local FieldOfView = {Enabled = false}
	local FieldOfViewZoom = {Enabled = false}
	FieldOfView = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "FOVChanger",
		Function = function(callback)
			if callback then
				if FieldOfViewZoom.Enabled then
					task.spawn(function()
						repeat
							task.wait()
						until not inputService:IsKeyDown(Enum.KeyCode[FieldOfView.Keybind ~= "" and FieldOfView.Keybind or "C"])
						if FieldOfView.Enabled then
							FieldOfView.ToggleButton(false)
						end
					end)
				end
				oldfov = bedwars.FovController.setFOV
				oldfov2 = bedwars.FovController.getFOV
				bedwars.FovController.setFOV = function(self, fov) return oldfov(self, FieldOfViewValue.Value) end
				bedwars.FovController.getFOV = function(self, fov) return FieldOfViewValue.Value end
			else
				bedwars.FovController.setFOV = oldfov
				bedwars.FovController.getFOV = oldfov2
			end
			bedwars.FovController:setFOV(bedwars.ClientStoreHandler:getState().Settings.fov)
		end
	})
	FieldOfViewValue = FieldOfView.CreateSlider({
		Name = "FOV",
		Min = 30,
		Max = 120,
		Function = function(val)
			if FieldOfView.Enabled then
				bedwars.FovController:setFOV(bedwars.ClientStoreHandler:getState().Settings.fov)
			end
		end
	})
	FieldOfViewZoom = FieldOfView.CreateToggle({
		Name = "Zoom",
		Function = function() end,
		HoverText = "optifine zoom lol"
	})
end)

runFunction(function()
	local old
	local old2
	local oldhitpart 
	local FPSBoost = {Enabled = false}
	local removetextures = {Enabled = false}
	local removetexturessmooth = {Enabled = false}
	local fpsboostdamageindicator = {Enabled = false}
	local fpsboostdamageeffect = {Enabled = false}
	local fpsboostkilleffect = {Enabled = false}
	local originaltextures = {}
	local originaleffects = {}

	local function fpsboosttextures()
		task.spawn(function()
			repeat task.wait() until bedwarsStore.matchState ~= 0
			for i,v in pairs(bedwarsStore.blocks) do
				if v:GetAttribute("PlacedByUserId") == 0 then
					v.Material = FPSBoost.Enabled and removetextures.Enabled and Enum.Material.SmoothPlastic or (v.Name:find("glass") and Enum.Material.SmoothPlastic or Enum.Material.Fabric)
					originaltextures[v] = originaltextures[v] or v.MaterialVariant
					v.MaterialVariant = FPSBoost.Enabled and removetextures.Enabled and "" or originaltextures[v]
					for i2,v2 in pairs(v:GetChildren()) do 
						pcall(function() 
							v2.Material = FPSBoost.Enabled and removetextures.Enabled and Enum.Material.SmoothPlastic or (v.Name:find("glass") and Enum.Material.SmoothPlastic or Enum.Material.Fabric)
							originaltextures[v2] = originaltextures[v2] or v2.MaterialVariant
							v2.MaterialVariant = FPSBoost.Enabled and removetextures.Enabled and "" or originaltextures[v2]
						end)
					end
				end
			end
		end)
	end

	FPSBoost = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "FPSBoost",
		Function = function(callback)
			local damagetab = debug.getupvalue(bedwars.DamageIndicator, 2)
			if callback then
				wasenabled = true
				fpsboosttextures()
				if fpsboostdamageindicator.Enabled then 
					damagetab.strokeThickness = 0
					damagetab.textSize = 0
					damagetab.blowUpDuration = 0
					damagetab.blowUpSize = 0
				end
				if fpsboostkilleffect.Enabled then 
					for i,v in pairs(bedwars.KillEffectController.killEffects) do 
						originaleffects[i] = v
						bedwars.KillEffectController.killEffects[i] = {new = function(char) return {onKill = function() end, isPlayDefaultKillEffect = function() return char == lplr.Character end} end}
					end
				end
				if fpsboostdamageeffect.Enabled then 
					oldhitpart = bedwars.DamageIndicatorController.hitEffectPart
					bedwars.DamageIndicatorController.hitEffectPart = nil
				end
				old = bedwars.HighlightController.highlight
				old2 = getmetatable(bedwars.StopwatchController).tweenOutGhost
				local highlighttable = {}
				getmetatable(bedwars.StopwatchController).tweenOutGhost = function(p17, p18)
					p18:Destroy()
				end
				bedwars.HighlightController.highlight = function() end
			else
				for i,v in pairs(originaleffects) do 
					bedwars.KillEffectController.killEffects[i] = v
				end
				fpsboosttextures()
				if oldhitpart then 
					bedwars.DamageIndicatorController.hitEffectPart = oldhitpart
				end
				debug.setupvalue(bedwars.KillEffectController.KnitStart, 2, require(lplr.PlayerScripts.TS["client-sync-events"]).ClientSyncEvents)
				damagetab.strokeThickness = 1.5
				damagetab.textSize = 28
				damagetab.blowUpDuration = 0.125
				damagetab.blowUpSize = 76
				debug.setupvalue(bedwars.DamageIndicator, 10, tweenService)
				if bedwars.DamageIndicatorController.hitEffectPart then 
					bedwars.DamageIndicatorController.hitEffectPart.Attachment.Cubes.Enabled = true
					bedwars.DamageIndicatorController.hitEffectPart.Attachment.Shards.Enabled = true
				end
				bedwars.HighlightController.highlight = old
				getmetatable(bedwars.StopwatchController).tweenOutGhost = old2
				old = nil
				old2 = nil
			end
		end
	})
	removetextures = FPSBoost.CreateToggle({
		Name = "Remove Textures",
		Function = function(callback) if FPSBoost.Enabled then FPSBoost.ToggleButton(false) FPSBoost.ToggleButton(false) end end
	})
	fpsboostdamageindicator = FPSBoost.CreateToggle({
		Name = "Remove Damage Indicator",
		Function = function(callback) if FPSBoost.Enabled then FPSBoost.ToggleButton(false) FPSBoost.ToggleButton(false) end end
	})
	fpsboostdamageeffect = FPSBoost.CreateToggle({
		Name = "Remove Damage Effect",
		Function = function(callback) if FPSBoost.Enabled then FPSBoost.ToggleButton(false) FPSBoost.ToggleButton(false) end end
	})
	fpsboostkilleffect = FPSBoost.CreateToggle({
		Name = "Remove Kill Effect",
		Function = function(callback) if FPSBoost.Enabled then FPSBoost.ToggleButton(false) FPSBoost.ToggleButton(false) end end
	})
end)

runFunction(function()
	local GameFixer = {Enabled = false}
	local GameFixerHit = {Enabled = false}
	GameFixer = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "GameFixer",
		Function = function(callback)
			if callback then
				if GameFixerHit.Enabled then 
					debug.setconstant(bedwars.SwordController.swingSwordAtMouse, 23, "raycast")
					debug.setupvalue(bedwars.SwordController.swingSwordAtMouse, 4, bedwars.QueryUtil)
				end
				debug.setconstant(bedwars.QueueCard.render, 9, 0.1)
			else
				if GameFixerHit.Enabled then 
					debug.setconstant(bedwars.SwordController.swingSwordAtMouse, 23, "Raycast")
					debug.setupvalue(bedwars.SwordController.swingSwordAtMouse, 4, workspace)
				end
				debug.setconstant(bedwars.QueueCard.render, 9, 0.01)
			end
		end,
		HoverText = "Fixes game bugs"
	})
	GameFixerHit = GameFixer.CreateToggle({
		Name = "Hit Fix",
		Function = function(callback)
			if GameFixer.Enabled then
				if callback then 
					debug.setconstant(bedwars.SwordController.swingSwordAtMouse, 23, "raycast")
					debug.setupvalue(bedwars.SwordController.swingSwordAtMouse, 4, bedwars.QueryUtil)
				else
					debug.setconstant(bedwars.SwordController.swingSwordAtMouse, 23, "Raycast")
					debug.setupvalue(bedwars.SwordController.swingSwordAtMouse, 4, workspace)
				end
			end
		end,
		HoverText = "Fixes the raycast function used for extra reach",
		Default = true
	})
end)

runFunction(function()
	local transformed = false
	local GameTheme = {Enabled = false}
	local GameThemeMode = {Value = "GameTheme"}

	local themefunctions = {
		Old = function()
			task.spawn(function()
				local oldbedwarstabofimages = '{"clay_orange":"rbxassetid://7017703219","iron":"rbxassetid://6850537969","glass":"rbxassetid://6909521321","log_spruce":"rbxassetid://6874161124","ice":"rbxassetid://6874651262","marble":"rbxassetid://6594536339","zipline_base":"rbxassetid://7051148904","iron_helmet":"rbxassetid://6874272559","marble_pillar":"rbxassetid://6909323822","clay_dark_green":"rbxassetid://6763635916","wood_plank_birch":"rbxassetid://6768647328","watering_can":"rbxassetid://6915423754","emerald_helmet":"rbxassetid://6931675766","pie":"rbxassetid://6985761399","wood_plank_spruce":"rbxassetid://6768615964","diamond_chestplate":"rbxassetid://6874272898","wool_pink":"rbxassetid://6910479863","wool_blue":"rbxassetid://6910480234","wood_plank_oak":"rbxassetid://6910418127","diamond_boots":"rbxassetid://6874272964","clay_yellow":"rbxassetid://4991097283","tnt":"rbxassetid://6856168996","lasso":"rbxassetid://7192710930","clay_purple":"rbxassetid://6856099740","melon_seeds":"rbxassetid://6956387796","apple":"rbxassetid://6985765179","carrot_seeds":"rbxassetid://6956387835","log_oak":"rbxassetid://6763678414","emerald_chestplate":"rbxassetid://6931675868","wool_yellow":"rbxassetid://6910479606","emerald_boots":"rbxassetid://6931675942","clay_light_brown":"rbxassetid://6874651634","balloon":"rbxassetid://7122143895","cannon":"rbxassetid://7121221753","leather_boots":"rbxassetid://6855466456","melon":"rbxassetid://6915428682","wool_white":"rbxassetid://6910387332","log_birch":"rbxassetid://6763678414","clay_pink":"rbxassetid://6856283410","grass":"rbxassetid://6773447725","obsidian":"rbxassetid://6910443317","shield":"rbxassetid://7051149149","red_sandstone":"rbxassetid://6708703895","diamond_helmet":"rbxassetid://6874272793","wool_orange":"rbxassetid://6910479956","log_hickory":"rbxassetid://7017706899","guitar":"rbxassetid://7085044606","wool_purple":"rbxassetid://6910479777","diamond":"rbxassetid://6850538161","iron_chestplate":"rbxassetid://6874272631","slime_block":"rbxassetid://6869284566","stone_brick":"rbxassetid://6910394475","hammer":"rbxassetid://6955848801","ceramic":"rbxassetid://6910426690","wood_plank_maple":"rbxassetid://6768632085","leather_helmet":"rbxassetid://6855466216","stone":"rbxassetid://6763635916","slate_brick":"rbxassetid://6708836267","sandstone":"rbxassetid://6708657090","snow":"rbxassetid://6874651192","wool_red":"rbxassetid://6910479695","leather_chestplate":"rbxassetid://6876833204","clay_red":"rbxassetid://6856283323","wool_green":"rbxassetid://6910480050","clay_white":"rbxassetid://7017705325","wool_cyan":"rbxassetid://6910480152","clay_black":"rbxassetid://5890435474","sand":"rbxassetid://6187018940","clay_light_green":"rbxassetid://6856099550","clay_dark_brown":"rbxassetid://6874651325","carrot":"rbxassetid://3677675280","clay":"rbxassetid://6856190168","iron_boots":"rbxassetid://6874272718","emerald":"rbxassetid://6850538075","zipline":"rbxassetid://7051148904"}'
				local oldbedwarsicontab = game:GetService("HttpService"):JSONDecode(oldbedwarstabofimages)
				local oldbedwarssoundtable = {
					["QUEUE_JOIN"] = "rbxassetid://6691735519",
					["QUEUE_MATCH_FOUND"] = "rbxassetid://6768247187",
					["UI_CLICK"] = "rbxassetid://6732690176",
					["UI_OPEN"] = "rbxassetid://6732607930",
					["BEDWARS_UPGRADE_SUCCESS"] = "rbxassetid://6760677364",
					["BEDWARS_PURCHASE_ITEM"] = "rbxassetid://6760677364",
					["SWORD_SWING_1"] = "rbxassetid://6760544639",
					["SWORD_SWING_2"] = "rbxassetid://6760544595",
					["DAMAGE_1"] = "rbxassetid://6765457325",
					["DAMAGE_2"] = "rbxassetid://6765470975",
					["DAMAGE_3"] = "rbxassetid://6765470941",
					["CROP_HARVEST"] = "rbxassetid://4864122196",
					["CROP_PLANT_1"] = "rbxassetid://5483943277",
					["CROP_PLANT_2"] = "rbxassetid://5483943479",
					["CROP_PLANT_3"] = "rbxassetid://5483943723",
					["ARMOR_EQUIP"] = "rbxassetid://6760627839",
					["ARMOR_UNEQUIP"] = "rbxassetid://6760625788",
					["PICKUP_ITEM_DROP"] = "rbxassetid://6768578304",
					["PARTY_INCOMING_INVITE"] = "rbxassetid://6732495464",
					["ERROR_NOTIFICATION"] = "rbxassetid://6732495464",
					["INFO_NOTIFICATION"] = "rbxassetid://6732495464",
					["END_GAME"] = "rbxassetid://6246476959",
					["GENERIC_BLOCK_PLACE"] = "rbxassetid://4842910664",
					["GENERIC_BLOCK_BREAK"] = "rbxassetid://4819966893",
					["GRASS_BREAK"] = "rbxassetid://5282847153",
					["WOOD_BREAK"] = "rbxassetid://4819966893",
					["STONE_BREAK"] = "rbxassetid://6328287211",
					["WOOL_BREAK"] = "rbxassetid://4842910664",
					["TNT_EXPLODE_1"] = "rbxassetid://7192313632",
					["TNT_HISS_1"] = "rbxassetid://7192313423",
					["FIREBALL_EXPLODE"] = "rbxassetid://6855723746",
					["SLIME_BLOCK_BOUNCE"] = "rbxassetid://6857999096",
					["SLIME_BLOCK_BREAK"] = "rbxassetid://6857999170",
					["SLIME_BLOCK_HIT"] = "rbxassetid://6857999148",
					["SLIME_BLOCK_PLACE"] = "rbxassetid://6857999119",
					["BOW_DRAW"] = "rbxassetid://6866062236",
					["BOW_FIRE"] = "rbxassetid://6866062104",
					["ARROW_HIT"] = "rbxassetid://6866062188",
					["ARROW_IMPACT"] = "rbxassetid://6866062148",
					["TELEPEARL_THROW"] = "rbxassetid://6866223756",
					["TELEPEARL_LAND"] = "rbxassetid://6866223798",
					["CROSSBOW_RELOAD"] = "rbxassetid://6869254094",
					["VOICE_1"] = "rbxassetid://5283866929",
					["VOICE_2"] = "rbxassetid://5283867710",
					["VOICE_HONK"] = "rbxassetid://5283872555",
					["FORTIFY_BLOCK"] = "rbxassetid://6955762535",
					["EAT_FOOD_1"] = "rbxassetid://4968170636",
					["KILL"] = "rbxassetid://7013482008",
					["ZIPLINE_TRAVEL"] = "rbxassetid://7047882304",
					["ZIPLINE_LATCH"] = "rbxassetid://7047882233",
					["ZIPLINE_UNLATCH"] = "rbxassetid://7047882265",
					["SHIELD_BLOCKED"] = "rbxassetid://6955762535",
					["GUITAR_LOOP"] = "rbxassetid://7084168540",
					["GUITAR_HEAL_1"] = "rbxassetid://7084168458",
					["CANNON_MOVE"] = "rbxassetid://7118668472",
					["CANNON_FIRE"] = "rbxassetid://7121064180",
					["BALLOON_INFLATE"] = "rbxassetid://7118657911",
					["BALLOON_POP"] = "rbxassetid://7118657873",
					["FIREBALL_THROW"] = "rbxassetid://7192289445",
					["LASSO_HIT"] = "rbxassetid://7192289603",
					["LASSO_SWING"] = "rbxassetid://7192289504",
					["LASSO_THROW"] = "rbxassetid://7192289548",
					["GRIM_REAPER_CONSUME"] = "rbxassetid://7225389554",
					["GRIM_REAPER_CHANNEL"] = "rbxassetid://7225389512",
					["TV_STATIC"] = "rbxassetid://7256209920",
					["TURRET_ON"] = "rbxassetid://7290176291",
					["TURRET_OFF"] = "rbxassetid://7290176380",
					["TURRET_ROTATE"] = "rbxassetid://7290176421",
					["TURRET_SHOOT"] = "rbxassetid://7290187805",
					["WIZARD_LIGHTNING_CAST"] = "rbxassetid://7262989886",
					["WIZARD_LIGHTNING_LAND"] = "rbxassetid://7263165647",
					["WIZARD_LIGHTNING_STRIKE"] = "rbxassetid://7263165347",
					["WIZARD_ORB_CAST"] = "rbxassetid://7263165448",
					["WIZARD_ORB_TRAVEL_LOOP"] = "rbxassetid://7263165579",
					["WIZARD_ORB_CONTACT_LOOP"] = "rbxassetid://7263165647",
					["BATTLE_PASS_PROGRESS_LEVEL_UP"] = "rbxassetid://7331597283",
					["BATTLE_PASS_PROGRESS_EXP_GAIN"] = "rbxassetid://7331597220",
					["FLAMETHROWER_UPGRADE"] = "rbxassetid://7310273053",
					["FLAMETHROWER_USE"] = "rbxassetid://7310273125",
					["BRITTLE_HIT"] = "rbxassetid://7310273179",
					["EXTINGUISH"] = "rbxassetid://7310273015",
					["RAVEN_SPACE_AMBIENT"] = "rbxassetid://7341443286",
					["RAVEN_WING_FLAP"] = "rbxassetid://7341443378",
					["RAVEN_CAW"] = "rbxassetid://7341443447",
					["JADE_HAMMER_THUD"] = "rbxassetid://7342299402",
					["STATUE"] = "rbxassetid://7344166851",
					["CONFETTI"] = "rbxassetid://7344278405",
					["HEART"] = "rbxassetid://7345120916",
					["SPRAY"] = "rbxassetid://7361499529",
					["BEEHIVE_PRODUCE"] = "rbxassetid://7378100183",
					["DEPOSIT_BEE"] = "rbxassetid://7378100250",
					["CATCH_BEE"] = "rbxassetid://7378100305",
					["BEE_NET_SWING"] = "rbxassetid://7378100350",
					["ASCEND"] = "rbxassetid://7378387334",
					["BED_ALARM"] = "rbxassetid://7396762708",
					["BOUNTY_CLAIMED"] = "rbxassetid://7396751941",
					["BOUNTY_ASSIGNED"] = "rbxassetid://7396752155",
					["BAGUETTE_HIT"] = "rbxassetid://7396760547",
					["BAGUETTE_SWING"] = "rbxassetid://7396760496",
					["TESLA_ZAP"] = "rbxassetid://7497477336",
					["SPIRIT_TRIGGERED"] = "rbxassetid://7498107251",
					["SPIRIT_EXPLODE"] = "rbxassetid://7498107327",
					["ANGEL_LIGHT_ORB_CREATE"] = "rbxassetid://7552134231",
					["ANGEL_LIGHT_ORB_HEAL"] = "rbxassetid://7552134868",
					["ANGEL_VOID_ORB_CREATE"] = "rbxassetid://7552135942",
					["ANGEL_VOID_ORB_HEAL"] = "rbxassetid://7552136927",
					["DODO_BIRD_JUMP"] = "rbxassetid://7618085391",
					["DODO_BIRD_DOUBLE_JUMP"] = "rbxassetid://7618085771",
					["DODO_BIRD_MOUNT"] = "rbxassetid://7618085486",
					["DODO_BIRD_DISMOUNT"] = "rbxassetid://7618085571",
					["DODO_BIRD_SQUAWK_1"] = "rbxassetid://7618085870",
					["DODO_BIRD_SQUAWK_2"] = "rbxassetid://7618085657",
					["SHIELD_CHARGE_START"] = "rbxassetid://7730842884",
					["SHIELD_CHARGE_LOOP"] = "rbxassetid://7730843006",
					["SHIELD_CHARGE_BASH"] = "rbxassetid://7730843142",
					["ROCKET_LAUNCHER_FIRE"] = "rbxassetid://7681584765",
					["ROCKET_LAUNCHER_FLYING_LOOP"] = "rbxassetid://7681584906",
					["SMOKE_GRENADE_POP"] = "rbxassetid://7681276062",
					["SMOKE_GRENADE_EMIT_LOOP"] = "rbxassetid://7681276135",
					["GOO_SPIT"] = "rbxassetid://7807271610",
					["GOO_SPLAT"] = "rbxassetid://7807272724",
					["GOO_EAT"] = "rbxassetid://7813484049",
					["LUCKY_BLOCK_BREAK"] = "rbxassetid://7682005357",
					["AXOLOTL_SWITCH_TARGETS"] = "rbxassetid://7344278405",
					["HALLOWEEN_MUSIC"] = "rbxassetid://7775602786",
					["SNAP_TRAP_SETUP"] = "rbxassetid://7796078515",
					["SNAP_TRAP_CLOSE"] = "rbxassetid://7796078695",
					["SNAP_TRAP_CONSUME_MARK"] = "rbxassetid://7796078825",
					["GHOST_VACUUM_SUCKING_LOOP"] = "rbxassetid://7814995865",
					["GHOST_VACUUM_SHOOT"] = "rbxassetid://7806060367",
					["GHOST_VACUUM_CATCH"] = "rbxassetid://7815151688",
					["FISHERMAN_GAME_START"] = "rbxassetid://7806060544",
					["FISHERMAN_GAME_PULLING_LOOP"] = "rbxassetid://7806060638",
					["FISHERMAN_GAME_PROGRESS_INCREASE"] = "rbxassetid://7806060745",
					["FISHERMAN_GAME_FISH_MOVE"] = "rbxassetid://7806060863",
					["FISHERMAN_GAME_LOOP"] = "rbxassetid://7806061057",
					["FISHING_ROD_CAST"] = "rbxassetid://7806060976",
					["FISHING_ROD_SPLASH"] = "rbxassetid://7806061193",
					["SPEAR_HIT"] = "rbxassetid://7807270398",
					["SPEAR_THROW"] = "rbxassetid://7813485044",
				}
				for i,v in pairs(bedwars.CombatController.killSounds) do 
					bedwars.CombatController.killSounds[i] = oldbedwarssoundtable.KILL
				end
				for i,v in pairs(bedwars.CombatController.multiKillLoops) do 
					bedwars.CombatController.multiKillLoops[i] = ""
				end
				for i,v in pairs(bedwars.ItemTable) do 
					if oldbedwarsicontab[i] then 
						v.image = oldbedwarsicontab[i]
					end
				end			
				for i,v in pairs(oldbedwarssoundtable) do 
					local item = bedwars.SoundList[i]
					if item then
						bedwars.SoundList[i] = v
					end
				end	
				local damagetab = debug.getupvalue(bedwars.DamageIndicator, 2)
				damagetab.strokeThickness = false
				damagetab.textSize = 32
				damagetab.blowUpDuration = 0
				damagetab.baseColor = Color3.fromRGB(214, 0, 0)
				damagetab.blowUpSize = 32
				damagetab.blowUpCompleteDuration = 0
				damagetab.anchoredDuration = 0
				debug.setconstant(bedwars.ViewmodelController.show, 37, "")
				debug.setconstant(bedwars.DamageIndicator, 83, Enum.Font.LuckiestGuy)
				debug.setconstant(bedwars.DamageIndicator, 102, "Enabled")
				debug.setconstant(bedwars.DamageIndicator, 118, 0.3)
				debug.setconstant(bedwars.DamageIndicator, 128, 0.5)
				debug.setupvalue(bedwars.DamageIndicator, 10, {
					Create = function(self, obj, ...)
						task.spawn(function()
							obj.Parent.Parent.Parent.Parent.Velocity = Vector3.new((math.random(-50, 50) / 100) * damagetab.velX, (math.random(50, 60) / 100) * damagetab.velY, (math.random(-50, 50) / 100) * damagetab.velZ)
							local textcompare = obj.Parent.TextColor3
							if textcompare ~= Color3.fromRGB(85, 255, 85) then
								local newtween = tweenService:Create(obj.Parent, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
									TextColor3 = (textcompare == Color3.fromRGB(76, 175, 93) and Color3.new(0, 0, 0) or Color3.new(1, 1, 1))
								})
								task.wait(0.15)
								newtween:Play()
							end
						end)
						return tweenService:Create(obj, ...)
					end
				})
				sethiddenproperty(lightingService, "Technology", "ShadowMap")
				lightingService.Ambient = Color3.fromRGB(69, 69, 69)
				lightingService.Brightness = 3
				lightingService.EnvironmentDiffuseScale = 1
				lightingService.EnvironmentSpecularScale = 1
				lightingService.OutdoorAmbient = Color3.fromRGB(69, 69, 69)
				lightingService.Atmosphere.Density = 0.1
				lightingService.Atmosphere.Offset = 0.25
				lightingService.Atmosphere.Color = Color3.fromRGB(198, 198, 198)
				lightingService.Atmosphere.Decay = Color3.fromRGB(104, 112, 124)
				lightingService.Atmosphere.Glare = 0
				lightingService.Atmosphere.Haze = 0
				lightingService.ClockTime = 13
				lightingService.GeographicLatitude = 0
				lightingService.GlobalShadows = false
				lightingService.TimeOfDay = "13:00:00"
				lightingService.Sky.SkyboxBk = "rbxassetid://7018684000"
				lightingService.Sky.SkyboxDn = "rbxassetid://6334928194"
				lightingService.Sky.SkyboxFt = "rbxassetid://7018684000"
				lightingService.Sky.SkyboxLf = "rbxassetid://7018684000"
				lightingService.Sky.SkyboxRt = "rbxassetid://7018684000"
				lightingService.Sky.SkyboxUp = "rbxassetid://7018689553"
			end)
		end,
		Winter = function() 
			task.spawn(function()
				for i,v in pairs(lightingService:GetChildren()) do
					if v:IsA("Atmosphere") or v:IsA("Sky") or v:IsA("PostEffect") then
						v:Remove()
					end
				end
				local sky = Instance.new("Sky")
				sky.StarCount = 5000
				sky.SkyboxUp = "rbxassetid://8139676647"
				sky.SkyboxLf = "rbxassetid://8139676988"
				sky.SkyboxFt = "rbxassetid://8139677111"
				sky.SkyboxBk = "rbxassetid://8139677359"
				sky.SkyboxDn = "rbxassetid://8139677253"
				sky.SkyboxRt = "rbxassetid://8139676842"
				sky.SunTextureId = "rbxassetid://6196665106"
				sky.SunAngularSize = 11
				sky.MoonTextureId = "rbxassetid://8139665943"
				sky.MoonAngularSize = 30
				sky.Parent = lightingService
				local sunray = Instance.new("SunRaysEffect")
				sunray.Intensity = 0.03
				sunray.Parent = lightingService
				local bloom = Instance.new("BloomEffect")
				bloom.Threshold = 2
				bloom.Intensity = 1
				bloom.Size = 2
				bloom.Parent = lightingService
				local atmosphere = Instance.new("Atmosphere")
				atmosphere.Density = 0.3
				atmosphere.Offset = 0.25
				atmosphere.Color = Color3.fromRGB(198, 198, 198)
				atmosphere.Decay = Color3.fromRGB(104, 112, 124)
				atmosphere.Glare = 0
				atmosphere.Haze = 0
				atmosphere.Parent = lightingService
				local damagetab = debug.getupvalue(bedwars.DamageIndicator, 2)
				damagetab.strokeThickness = false
				damagetab.textSize = 32
				damagetab.blowUpDuration = 0
				damagetab.baseColor = Color3.fromRGB(70, 255, 255)
				damagetab.blowUpSize = 32
				damagetab.blowUpCompleteDuration = 0
				damagetab.anchoredDuration = 0
				debug.setconstant(bedwars.DamageIndicator, 83, Enum.Font.LuckiestGuy)
				debug.setconstant(bedwars.DamageIndicator, 102, "Enabled")
				debug.setconstant(bedwars.DamageIndicator, 118, 0.3)
				debug.setconstant(bedwars.DamageIndicator, 128, 0.5)
				debug.setupvalue(bedwars.DamageIndicator, 10, {
					Create = function(self, obj, ...)
						task.spawn(function()
							obj.Parent.Parent.Parent.Parent.Velocity = Vector3.new((math.random(-50, 50) / 100) * damagetab.velX, (math.random(50, 60) / 100) * damagetab.velY, (math.random(-50, 50) / 100) * damagetab.velZ)
							local textcompare = obj.Parent.TextColor3
							if textcompare ~= Color3.fromRGB(85, 255, 85) then
								local newtween = tweenService:Create(obj.Parent, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
									TextColor3 = (textcompare == Color3.fromRGB(76, 175, 93) and Color3.new(1, 1, 1) or Color3.new(0, 0, 0))
								})
								task.wait(0.15)
								newtween:Play()
							end
						end)
						return tweenService:Create(obj, ...)
					end
				})
				debug.setconstant(require(lplr.PlayerScripts.TS.controllers.global.hotbar.ui.healthbar["hotbar-healthbar"]).HotbarHealthbar.render, 16, 4653055)
			end)
			task.spawn(function()
				local snowpart = Instance.new("Part")
				snowpart.Size = Vector3.new(240, 0.5, 240)
				snowpart.Name = "SnowParticle"
				snowpart.Transparency = 1
				snowpart.CanCollide = false
				snowpart.Position = Vector3.new(0, 120, 286)
				snowpart.Anchored = true
				snowpart.Parent = workspace
				local snow = Instance.new("ParticleEmitter")
				snow.RotSpeed = NumberRange.new(300)
				snow.VelocitySpread = 35
				snow.Rate = 28
				snow.Texture = "rbxassetid://8158344433"
				snow.Rotation = NumberRange.new(110)
				snow.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0.16939899325371,0),NumberSequenceKeypoint.new(0.23365999758244,0.62841498851776,0.37158501148224),NumberSequenceKeypoint.new(0.56209099292755,0.38797798752785,0.2771390080452),NumberSequenceKeypoint.new(0.90577298402786,0.51912599802017,0),NumberSequenceKeypoint.new(1,1,0)})
				snow.Lifetime = NumberRange.new(8,14)
				snow.Speed = NumberRange.new(8,18)
				snow.EmissionDirection = Enum.NormalId.Bottom
				snow.SpreadAngle = Vector2.new(35,35)
				snow.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0,0),NumberSequenceKeypoint.new(0.039760299026966,1.3114800453186,0.32786899805069),NumberSequenceKeypoint.new(0.7554469704628,0.98360699415207,0.44038599729538),NumberSequenceKeypoint.new(1,0,0)})
				snow.Parent = snowpart
				local windsnow = Instance.new("ParticleEmitter")
				windsnow.Acceleration = Vector3.new(0,0,1)
				windsnow.RotSpeed = NumberRange.new(100)
				windsnow.VelocitySpread = 35
				windsnow.Rate = 28
				windsnow.Texture = "rbxassetid://8158344433"
				windsnow.EmissionDirection = Enum.NormalId.Bottom
				windsnow.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0.16939899325371,0),NumberSequenceKeypoint.new(0.23365999758244,0.62841498851776,0.37158501148224),NumberSequenceKeypoint.new(0.56209099292755,0.38797798752785,0.2771390080452),NumberSequenceKeypoint.new(0.90577298402786,0.51912599802017,0),NumberSequenceKeypoint.new(1,1,0)})
				windsnow.Lifetime = NumberRange.new(8,14)
				windsnow.Speed = NumberRange.new(8,18)
				windsnow.Rotation = NumberRange.new(110)
				windsnow.SpreadAngle = Vector2.new(35,35)
				windsnow.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0,0),NumberSequenceKeypoint.new(0.039760299026966,1.3114800453186,0.32786899805069),NumberSequenceKeypoint.new(0.7554469704628,0.98360699415207,0.44038599729538),NumberSequenceKeypoint.new(1,0,0)})
				windsnow.Parent = snowpart
				repeat
					task.wait()
					if entityLibrary.isAlive then 
						snowpart.Position = entityLibrary.character.HumanoidRootPart.Position + Vector3.new(0, 100, 0)
					end
				until not vapeInjected
			end)
		end,
		Halloween = function()
			task.spawn(function()
				for i,v in pairs(lightingService:GetChildren()) do
					if v:IsA("Atmosphere") or v:IsA("Sky") or v:IsA("PostEffect") then
						v:Remove()
					end
				end
				lightingService.TimeOfDay = "00:00:00"
				pcall(function() workspace.Clouds:Destroy() end)
				local damagetab = debug.getupvalue(bedwars.DamageIndicator, 2)
				damagetab.strokeThickness = false
				damagetab.textSize = 32
				damagetab.blowUpDuration = 0
				damagetab.baseColor = Color3.fromRGB(255, 100, 0)
				damagetab.blowUpSize = 32
				damagetab.blowUpCompleteDuration = 0
				damagetab.anchoredDuration = 0
				debug.setconstant(bedwars.DamageIndicator, 83, Enum.Font.LuckiestGuy)
				debug.setconstant(bedwars.DamageIndicator, 102, "Enabled")
				debug.setconstant(bedwars.DamageIndicator, 118, 0.3)
				debug.setconstant(bedwars.DamageIndicator, 128, 0.5)
				debug.setupvalue(bedwars.DamageIndicator, 10, {
					Create = function(self, obj, ...)
						task.spawn(function()
							obj.Parent.Parent.Parent.Parent.Velocity = Vector3.new((math.random(-50, 50) / 100) * damagetab.velX, (math.random(50, 60) / 100) * damagetab.velY, (math.random(-50, 50) / 100) * damagetab.velZ)
							local textcompare = obj.Parent.TextColor3
							if textcompare ~= Color3.fromRGB(85, 255, 85) then
								local newtween = tweenService:Create(obj.Parent, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
									TextColor3 = (textcompare == Color3.fromRGB(76, 175, 93) and Color3.new(0, 0, 0) or Color3.new(0, 0, 0))
								})
								task.wait(0.15)
								newtween:Play()
							end
						end)
						return tweenService:Create(obj, ...)
					end
				})
				local colorcorrection = Instance.new("ColorCorrectionEffect")
				colorcorrection.TintColor = Color3.fromRGB(255, 185, 81)
				colorcorrection.Brightness = 0.05
				colorcorrection.Parent = lightingService
				debug.setconstant(require(lplr.PlayerScripts.TS.controllers.global.hotbar.ui.healthbar["hotbar-healthbar"]).HotbarHealthbar.render, 16, 16737280)
			end)
		end,
		Valentines = function()
			task.spawn(function()
				for i,v in pairs(lightingService:GetChildren()) do
					if v:IsA("Atmosphere") or v:IsA("Sky") or v:IsA("PostEffect") then
						v:Remove()
					end
				end
				local sky = Instance.new("Sky")
				sky.SkyboxBk = "rbxassetid://1546230803"
				sky.SkyboxDn = "rbxassetid://1546231143"
				sky.SkyboxFt = "rbxassetid://1546230803"
				sky.SkyboxLf = "rbxassetid://1546230803"
				sky.SkyboxRt = "rbxassetid://1546230803"
				sky.SkyboxUp = "rbxassetid://1546230451"
				sky.Parent = lightingService
				pcall(function() workspace.Clouds:Destroy() end)
				local damagetab = debug.getupvalue(bedwars.DamageIndicator, 2)
				damagetab.strokeThickness = false
				damagetab.textSize = 32
				damagetab.blowUpDuration = 0
				damagetab.baseColor = Color3.fromRGB(255, 132, 178)
				damagetab.blowUpSize = 32
				damagetab.blowUpCompleteDuration = 0
				damagetab.anchoredDuration = 0
				debug.setconstant(bedwars.DamageIndicator, 83, Enum.Font.LuckiestGuy)
				debug.setconstant(bedwars.DamageIndicator, 102, "Enabled")
				debug.setconstant(bedwars.DamageIndicator, 118, 0.3)
				debug.setconstant(bedwars.DamageIndicator, 128, 0.5)
				debug.setupvalue(bedwars.DamageIndicator, 10, {
					Create = function(self, obj, ...)
						task.spawn(function()
							obj.Parent.Parent.Parent.Parent.Velocity = Vector3.new((math.random(-50, 50) / 100) * damagetab.velX, (math.random(50, 60) / 100) * damagetab.velY, (math.random(-50, 50) / 100) * damagetab.velZ)
							local textcompare = obj.Parent.TextColor3
							if textcompare ~= Color3.fromRGB(85, 255, 85) then
								local newtween = tweenService:Create(obj.Parent, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
									TextColor3 = (textcompare == Color3.fromRGB(76, 175, 93) and Color3.new(0, 0, 0) or Color3.new(0, 0, 0))
								})
								task.wait(0.15)
								newtween:Play()
							end
						end)
						return tweenService:Create(obj, ...)
					end
				})
				local colorcorrection = Instance.new("ColorCorrectionEffect")
				colorcorrection.TintColor = Color3.fromRGB(255, 199, 220)
				colorcorrection.Brightness = 0.05
				colorcorrection.Parent = lightingService
				debug.setconstant(require(lplr.PlayerScripts.TS.controllers.global.hotbar.ui.healthbar["hotbar-healthbar"]).HotbarHealthbar.render, 16, 16745650)
			end)
		end
	}

	GameTheme = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "GameTheme",
		Function = function(callback) 
			if callback then 
				if not transformed then
					transformed = true
					themefunctions[GameThemeMode.Value]()
				else
					GameTheme.ToggleButton(false)
				end
			else
				warningNotification("GameTheme", "Disabled Next Game", 10)
			end
		end,
		ExtraText = function()
			return GameThemeMode.Value
		end
	})
	GameThemeMode = GameTheme.CreateDropdown({
		Name = "Theme",
		Function = function() end,
		List = {"Old", "Winter", "Halloween", "Valentines"}
	})
end)

runFunction(function()
	local oldkilleffect
	local KillEffectMode = {Value = "Gravity"}
	local KillEffectList = {Value = "None"}
	local KillEffectName2 = {}
	local killeffects = {
		Gravity = function(p3, p4, p5, p6)
			p5:BreakJoints()
			task.spawn(function()
				local partvelo = {}
				for i,v in pairs(p5:GetDescendants()) do 
					if v:IsA("BasePart") then 
						partvelo[v.Name] = v.Velocity * 3
					end
				end
				p5.Archivable = true
				local clone = p5:Clone()
				clone.Humanoid.Health = 100
				clone.Parent = workspace
				local nametag = clone:FindFirstChild("Nametag", true)
				if nametag then nametag:Destroy() end
				game:GetService("Debris"):AddItem(clone, 30)
				p5:Destroy()
				task.wait(0.01)
				clone.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
				clone:BreakJoints()
				task.wait(0.01)
				for i,v in pairs(clone:GetDescendants()) do 
					if v:IsA("BasePart") then 
						local bodyforce = Instance.new("BodyForce")
						bodyforce.Force = Vector3.new(0, (workspace.Gravity - 10) * v:GetMass(), 0)
						bodyforce.Parent = v
						v.CanCollide = true
						v.Velocity = partvelo[v.Name] or Vector3.zero
					end
				end
			end)
		end,
		Lightning = function(p3, p4, p5, p6)
			p5:BreakJoints()
			local startpos = 1125
			local startcf = p5.PrimaryPart.CFrame.p - Vector3.new(0, 8, 0)
			local newpos = Vector3.new((math.random(1, 10) - 5) * 2, startpos, (math.random(1, 10) - 5) * 2)
			for i = startpos - 75, 0, -75 do 
				local newpos2 = Vector3.new((math.random(1, 10) - 5) * 2, i, (math.random(1, 10) - 5) * 2)
				if i == 0 then 
					newpos2 = Vector3.zero
				end
				local part = Instance.new("Part")
				part.Size = Vector3.new(1.5, 1.5, 77)
				part.Material = Enum.Material.SmoothPlastic
				part.Anchored = true
				part.Material = Enum.Material.Neon
				part.CanCollide = false
				part.CFrame = CFrame.new(startcf + newpos + ((newpos2 - newpos) * 0.5), startcf + newpos2)
				part.Parent = workspace
				local part2 = part:Clone()
				part2.Size = Vector3.new(3, 3, 78)
				part2.Color = Color3.new(0.7, 0.7, 0.7)
				part2.Transparency = 0.7
				part2.Material = Enum.Material.SmoothPlastic
				part2.Parent = workspace
				game:GetService("Debris"):AddItem(part, 0.5)
				game:GetService("Debris"):AddItem(part2, 0.5)
				bedwars.QueryUtil:setQueryIgnored(part, true)
				bedwars.QueryUtil:setQueryIgnored(part2, true)
				if i == 0 then 
					local soundpart = Instance.new("Part")
					soundpart.Transparency = 1
					soundpart.Anchored = true 
					soundpart.Size = Vector3.zero
					soundpart.Position = startcf
					soundpart.Parent = workspace
					bedwars.QueryUtil:setQueryIgnored(soundpart, true)
					local sound = Instance.new("Sound")
					sound.SoundId = "rbxassetid://6993372814"
					sound.Volume = 2
					sound.Pitch = 0.5 + (math.random(1, 3) / 10)
					sound.Parent = soundpart
					sound:Play()
					sound.Ended:Connect(function()
						soundpart:Destroy()
					end)
				end
				newpos = newpos2
			end
		end
	}
	local KillEffectName = {}
	for i,v in pairs(bedwars.KillEffectMeta) do 
		table.insert(KillEffectName, v.name)
		KillEffectName[v.name] = i
	end
	table.sort(KillEffectName, function(a, b) return a:lower() < b:lower() end)
	local KillEffect = {Enabled = false}
	KillEffect = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "KillEffect",
		Function = function(callback)
			if callback then 
				task.spawn(function()
					repeat task.wait() until bedwarsStore.matchState ~= 0 or not KillEffect.Enabled
					if KillEffect.Enabled then
						lplr:SetAttribute("KillEffectType", "none")
						if KillEffectMode.Value == "Bedwars" then 
							lplr:SetAttribute("KillEffectType", KillEffectName[KillEffectList.Value])
						end
					end
				end)
				oldkilleffect = bedwars.DefaultKillEffect.onKill
				bedwars.DefaultKillEffect.onKill = function(p3, p4, p5, p6)
					killeffects[KillEffectMode.Value](p3, p4, p5, p6)
				end
			else
				bedwars.DefaultKillEffect.onKill = oldkilleffect
			end
		end
	})
	local modes = {"Bedwars"}
	for i,v in pairs(killeffects) do 
		table.insert(modes, i)
	end
	KillEffectMode = KillEffect.CreateDropdown({
		Name = "Mode",
		Function = function() 
			if KillEffect.Enabled then 
				KillEffect.ToggleButton(false)
				KillEffect.ToggleButton(false)
			end
		end,
		List = modes
	})
	KillEffectList = KillEffect.CreateDropdown({
		Name = "Bedwars",
		Function = function() 
			if KillEffect.Enabled then 
				KillEffect.ToggleButton(false)
				KillEffect.ToggleButton(false)
			end
		end,
		List = KillEffectName
	})
end)

runFunction(function()
	local KitESP = {Enabled = false}
	local espobjs = {}
	local espfold = Instance.new("Folder")
	espfold.Parent = GuiLibrary.MainGui

	local function espadd(v, icon)
		local billboard = Instance.new("BillboardGui")
		billboard.Parent = espfold
		billboard.Name = "iron"
		billboard.StudsOffsetWorldSpace = Vector3.new(0, 3, 1.5)
		billboard.Size = UDim2.new(0, 32, 0, 32)
		billboard.AlwaysOnTop = true
		billboard.Adornee = v
		local image = Instance.new("ImageLabel")
		image.BackgroundTransparency = 0.5
		image.BorderSizePixel = 0
		image.Image = bedwars.getIcon({itemType = icon}, true)
		image.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		image.Size = UDim2.new(0, 32, 0, 32)
		image.AnchorPoint = Vector2.new(0.5, 0.5)
		image.Parent = billboard
		local uicorner = Instance.new("UICorner")
		uicorner.CornerRadius = UDim.new(0, 4)
		uicorner.Parent = image
		espobjs[v] = billboard
	end

	local function addKit(tag, icon)
		table.insert(KitESP.Connections, collectionService:GetInstanceAddedSignal(tag):Connect(function(v)
			espadd(v.PrimaryPart, icon)
		end))
		table.insert(KitESP.Connections, collectionService:GetInstanceRemovedSignal(tag):Connect(function(v)
			if espobjs[v.PrimaryPart] then
				espobjs[v.PrimaryPart]:Destroy()
				espobjs[v.PrimaryPart] = nil
			end
		end))
		for i,v in pairs(collectionService:GetTagged(tag)) do 
			espadd(v.PrimaryPart, icon)
		end
	end

	KitESP = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "KitESP",
		Function = function(callback) 
			if callback then
				task.spawn(function()
					repeat task.wait() until bedwarsStore.equippedKit ~= ""
					if KitESP.Enabled then
						if bedwarsStore.equippedKit == "metal_detector" then
							addKit("hidden-metal", "iron")
						elseif bedwarsStore.equippedKit == "beekeeper" then
							addKit("bee", "bee")
						elseif bedwarsStore.equippedKit == "bigman" then
							addKit("treeOrb", "natures_essence_1")
						end
					end
				end)
			else
				espfold:ClearAllChildren()
				table.clear(espobjs)
			end
		end
	})
end)

runFunction(function()
	local function floorNameTagPosition(pos)
		return Vector2.new(math.floor(pos.X), math.floor(pos.Y))
	end

	local function removeTags(str)
        str = str:gsub("<br%s*/>", "\n")
        return (str:gsub("<[^<>]->", ""))
    end

	local NameTagsFolder = Instance.new("Folder")
	NameTagsFolder.Name = "NameTagsFolder"
	NameTagsFolder.Parent = GuiLibrary.MainGui
	local nametagsfolderdrawing = {}
	local NameTagsColor = {Value = 0.44}
	local NameTagsDisplayName = {Enabled = false}
	local NameTagsHealth = {Enabled = false}
	local NameTagsDistance = {Enabled = false}
	local NameTagsBackground = {Enabled = true}
	local NameTagsScale = {Value = 10}
	local NameTagsFont = {Value = "SourceSans"}
	local NameTagsTeammates = {Enabled = true}
	local NameTagsShowInventory = {Enabled = false}
	local NameTagsRangeLimit = {Value = 0}
	local fontitems = {"SourceSans"}
	local nametagstrs = {}
	local nametagsizes = {}
	local kititems = {
		jade = "jade_hammer",
		archer = "tactical_crossbow",
		angel = "",
		cowgirl = "lasso",
		dasher = "wood_dao",
		axolotl = "axolotl",
		yeti = "snowball",
		smoke = "smoke_block",
		trapper = "snap_trap",
		pyro = "flamethrower",
		davey = "cannon",
		regent = "void_axe", 
		baker = "apple",
		builder = "builder_hammer",
		farmer_cletus = "carrot_seeds",
		melody = "guitar",
		barbarian = "rageblade",
		gingerbread_man = "gumdrop_bounce_pad",
		spirit_catcher = "spirit",
		fisherman = "fishing_rod",
		oil_man = "oil_consumable",
		santa = "tnt",
		miner = "miner_pickaxe",
		sheep_herder = "crook",
		beast = "speed_potion",
		metal_detector = "metal_detector",
		cyber = "drone",
		vesta = "damage_banner",
		lumen = "light_sword",
		ember = "infernal_saber",
		queen_bee = "bee"
	}

	local nametagfuncs1 = {
		Normal = function(plr)
			if NameTagsTeammates.Enabled and (not plr.Targetable) and (not plr.Friend) then return end
			local thing = Instance.new("TextLabel")
			thing.BackgroundColor3 = Color3.new()
			thing.BorderSizePixel = 0
			thing.Visible = false
			thing.RichText = true
			thing.AnchorPoint = Vector2.new(0.5, 1)
			thing.Name = plr.Player.Name
			thing.Font = Enum.Font[NameTagsFont.Value]
			thing.TextSize = 14 * (NameTagsScale.Value / 10)
			thing.BackgroundTransparency = NameTagsBackground.Enabled and 0.5 or 1
			nametagstrs[plr.Player] = WhitelistFunctions:GetTag(plr.Player)..(NameTagsDisplayName.Enabled and plr.Player.DisplayName or plr.Player.Name)
			if NameTagsHealth.Enabled then
				local color = Color3.fromHSV(math.clamp(plr.Humanoid.Health / plr.Humanoid.MaxHealth, 0, 1) / 2.5, 0.89, 1)
				nametagstrs[plr.Player] = nametagstrs[plr.Player]..' <font color="rgb('..tostring(math.floor(color.R * 255))..','..tostring(math.floor(color.G * 255))..','..tostring(math.floor(color.B * 255))..')">'..math.round(plr.Humanoid.Health).."</font>"
			end
			if NameTagsDistance.Enabled then 
				nametagstrs[plr.Player] = '<font color="rgb(85, 255, 85)">[</font><font color="rgb(255, 255, 255)">%s</font><font color="rgb(85, 255, 85)">]</font> '..nametagstrs[plr.Player]
			end
			local nametagSize = textService:GetTextSize(removeTags(nametagstrs[plr.Player]), thing.TextSize, thing.Font, Vector2.new(100000, 100000))
			thing.Size = UDim2.new(0, nametagSize.X + 4, 0, nametagSize.Y)
			thing.Text = nametagstrs[plr.Player]
			thing.TextColor3 = getPlayerColor(plr.Player) or Color3.fromHSV(NameTagsColor.Hue, NameTagsColor.Sat, NameTagsColor.Value)
			thing.Parent = NameTagsFolder
			local hand = Instance.new("ImageLabel")
			hand.Size = UDim2.new(0, 30, 0, 30)
			hand.Name = "Hand"
			hand.BackgroundTransparency = 1
			hand.Position = UDim2.new(0, -30, 0, -30)
			hand.Image = ""
			hand.Parent = thing
			local helmet = hand:Clone()
			helmet.Name = "Helmet"
			helmet.Position = UDim2.new(0, 5, 0, -30)
			helmet.Parent = thing
			local chest = hand:Clone()
			chest.Name = "Chestplate"
			chest.Position = UDim2.new(0, 35, 0, -30)
			chest.Parent = thing
			local boots = hand:Clone()
			boots.Name = "Boots"
			boots.Position = UDim2.new(0, 65, 0, -30)
			boots.Parent = thing
			local kit = hand:Clone()
			kit.Name = "Kit"
			task.spawn(function()
				repeat task.wait() until plr.Player:GetAttribute("PlayingAsKit") ~= ""
				if kit then
					kit.Image = kititems[plr.Player:GetAttribute("PlayingAsKit")] and bedwars.getIcon({itemType = kititems[plr.Player:GetAttribute("PlayingAsKit")]}, NameTagsShowInventory.Enabled) or ""
				end
			end)
			kit.Position = UDim2.new(0, -30, 0, -65)
			kit.Parent = thing
			nametagsfolderdrawing[plr.Player] = {entity = plr, Main = thing}
		end,
		Drawing = function(plr)
			if NameTagsTeammates.Enabled and (not plr.Targetable) and (not plr.Friend) then return end
			local thing = {Main = {}, entity = plr}
			thing.Main.Text = Drawing.new("Text")
			thing.Main.Text.Size = 17 * (NameTagsScale.Value / 10)
			thing.Main.Text.Font = (math.clamp((table.find(fontitems, NameTagsFont.Value) or 1) - 1, 0, 3))
			thing.Main.Text.ZIndex = 2
			thing.Main.BG = Drawing.new("Square")
			thing.Main.BG.Filled = true
			thing.Main.BG.Transparency = 0.5
			thing.Main.BG.Visible = NameTagsBackground.Enabled
			thing.Main.BG.Color = Color3.new()
			thing.Main.BG.ZIndex = 1
			nametagstrs[plr.Player] = WhitelistFunctions:GetTag(plr.Player)..(NameTagsDisplayName.Enabled and plr.Player.DisplayName or plr.Player.Name)
			if NameTagsHealth.Enabled then
				local color = Color3.fromHSV(math.clamp(plr.Humanoid.Health / plr.Humanoid.MaxHealth, 0, 1) / 2.5, 0.89, 1)
				nametagstrs[plr.Player] = nametagstrs[plr.Player]..' '..math.round(plr.Humanoid.Health)
			end
			if NameTagsDistance.Enabled then 
				nametagstrs[plr.Player] = '[%s] '..nametagstrs[plr.Player]
			end
			thing.Main.Text.Text = nametagstrs[plr.Player]
			thing.Main.BG.Size = Vector2.new(thing.Main.Text.TextBounds.X + 4, thing.Main.Text.TextBounds.Y)
			thing.Main.Text.Color = getPlayerColor(plr.Player) or Color3.fromHSV(NameTagsColor.Hue, NameTagsColor.Sat, NameTagsColor.Value)
			nametagsfolderdrawing[plr.Player] = thing
		end
	}

	local nametagfuncs2 = {
		Normal = function(ent)
			local v = nametagsfolderdrawing[ent]
			nametagsfolderdrawing[ent] = nil
			if v then 
				v.Main:Destroy()
			end
		end,
		Drawing = function(ent)
			local v = nametagsfolderdrawing[ent]
			nametagsfolderdrawing[ent] = nil
			if v then 
				for i2,v2 in pairs(v.Main) do
					pcall(function() v2.Visible = false v2:Remove() end)
				end
			end
		end
	}

	local nametagupdatefuncs = {
		Normal = function(ent)
			local v = nametagsfolderdrawing[ent.Player]
			if v then 
				nametagstrs[ent.Player] = WhitelistFunctions:GetTag(ent.Player)..(NameTagsDisplayName.Enabled and ent.Player.DisplayName or ent.Player.Name)
				if NameTagsHealth.Enabled then
					local color = Color3.fromHSV(math.clamp(ent.Humanoid.Health / ent.Humanoid.MaxHealth, 0, 1) / 2.5, 0.89, 1)
					nametagstrs[ent.Player] = nametagstrs[ent.Player]..' <font color="rgb('..tostring(math.floor(color.R * 255))..','..tostring(math.floor(color.G * 255))..','..tostring(math.floor(color.B * 255))..')">'..math.round(ent.Humanoid.Health).."</font>"
				end
				if NameTagsDistance.Enabled then 
					nametagstrs[ent.Player] = '<font color="rgb(85, 255, 85)">[</font><font color="rgb(255, 255, 255)">%s</font><font color="rgb(85, 255, 85)">]</font> '..nametagstrs[ent.Player]
				end
				if NameTagsShowInventory.Enabled then 
					local inventory = bedwarsStore.inventories[ent.Player] or {armor = {}}
					if inventory.hand then
						v.Main.Hand.Image = bedwars.getIcon(inventory.hand, NameTagsShowInventory.Enabled)
						if v.Main.Hand.Image:find("rbxasset://") then
							v.Main.Hand.ResampleMode = Enum.ResamplerMode.Pixelated
						end
					else
						v.Main.Hand.Image = ""
					end
					if inventory.armor[4] then
						v.Main.Helmet.Image = bedwars.getIcon(inventory.armor[4], NameTagsShowInventory.Enabled)
						if v.Main.Helmet.Image:find("rbxasset://") then
							v.Main.Helmet.ResampleMode = Enum.ResamplerMode.Pixelated
						end
					else
						v.Main.Helmet.Image = ""
					end
					if inventory.armor[5] then
						v.Main.Chestplate.Image = bedwars.getIcon(inventory.armor[5], NameTagsShowInventory.Enabled)
						if v.Main.Chestplate.Image:find("rbxasset://") then
							v.Main.Chestplate.ResampleMode = Enum.ResamplerMode.Pixelated
						end
					else
						v.Main.Chestplate.Image = ""
					end
					if inventory.armor[6] then
						v.Main.Boots.Image = bedwars.getIcon(inventory.armor[6], NameTagsShowInventory.Enabled)
						if v.Main.Boots.Image:find("rbxasset://") then
							v.Main.Boots.ResampleMode = Enum.ResamplerMode.Pixelated
						end
					else
						v.Main.Boots.Image = ""
					end
				end
				local nametagSize = textService:GetTextSize(removeTags(nametagstrs[ent.Player]), v.Main.TextSize, v.Main.Font, Vector2.new(100000, 100000))
				v.Main.Size = UDim2.new(0, nametagSize.X + 4, 0, nametagSize.Y)
				v.Main.Text = nametagstrs[ent.Player]
			end
		end,
		Drawing = function(ent)
			local v = nametagsfolderdrawing[ent.Player]
			if v then 
				nametagstrs[ent.Player] = WhitelistFunctions:GetTag(ent.Player)..(NameTagsDisplayName.Enabled and ent.Player.DisplayName or ent.Player.Name)
				if NameTagsHealth.Enabled then
					nametagstrs[ent.Player] = nametagstrs[ent.Player]..' '..math.round(ent.Humanoid.Health)
				end
				if NameTagsDistance.Enabled then 
					nametagstrs[ent.Player] = '[%s] '..nametagstrs[ent.Player]
					v.Main.Text.Text = entityLibrary.isAlive and string.format(nametagstrs[ent.Player], math.floor((entityLibrary.character.HumanoidRootPart.Position - ent.RootPart.Position).Magnitude)) or nametagstrs[ent.Player]
				else
					v.Main.Text.Text = nametagstrs[ent.Player]
				end
				v.Main.BG.Size = Vector2.new(v.Main.Text.TextBounds.X + 4, v.Main.Text.TextBounds.Y)
				v.Main.Text.Color = getPlayerColor(ent.Player) or Color3.fromHSV(NameTagsColor.Hue, NameTagsColor.Sat, NameTagsColor.Value)
			end
		end
	}

	local nametagcolorfuncs = {
		Normal = function(hue, sat, value)
			local color = Color3.fromHSV(hue, sat, value)
			for i,v in pairs(nametagsfolderdrawing) do 
				v.Main.TextColor3 = getPlayerColor(v.entity.Player) or color
			end
		end,
		Drawing = function(hue, sat, value)
			local color = Color3.fromHSV(hue, sat, value)
			for i,v in pairs(nametagsfolderdrawing) do 
				v.Main.Text.Color = getPlayerColor(v.entity.Player) or color
			end
		end
	}

	local nametagloop = {
		Normal = function()
			for i,v in pairs(nametagsfolderdrawing) do 
				local headPos, headVis = worldtoscreenpoint((v.entity.RootPart:GetRenderCFrame() * CFrame.new(0, v.entity.Head.Size.Y + v.entity.RootPart.Size.Y, 0)).Position)
				if not headVis then 
					v.Main.Visible = false
					continue
				end
				local mag = entityLibrary.isAlive and math.floor((entityLibrary.character.HumanoidRootPart.Position - v.entity.RootPart.Position).Magnitude) or 0
				if NameTagsRangeLimit.Value ~= 0 and mag > NameTagsRangeLimit.Value then 
					v.Main.Visible = false
					continue
				end
				if NameTagsDistance.Enabled then
					local stringsize = tostring(mag):len()
					if nametagsizes[v.entity.Player] ~= stringsize then 
						local nametagSize = textService:GetTextSize(removeTags(string.format(nametagstrs[v.entity.Player], mag)), v.Main.TextSize, v.Main.Font, Vector2.new(100000, 100000))
						v.Main.Size = UDim2.new(0, nametagSize.X + 4, 0, nametagSize.Y)
					end
					nametagsizes[v.entity.Player] = stringsize
					v.Main.Text = string.format(nametagstrs[v.entity.Player], mag)
				end
				v.Main.Position = UDim2.new(0, headPos.X, 0, headPos.Y)
				v.Main.Visible = true
			end
		end,
		Drawing = function()
			for i,v in pairs(nametagsfolderdrawing) do 
				local headPos, headVis = worldtoscreenpoint((v.entity.RootPart:GetRenderCFrame() * CFrame.new(0, v.entity.Head.Size.Y + v.entity.RootPart.Size.Y, 0)).Position)
				if not headVis then 
					v.Main.Text.Visible = false
					v.Main.BG.Visible = false
					continue
				end
				local mag = entityLibrary.isAlive and math.floor((entityLibrary.character.HumanoidRootPart.Position - v.entity.RootPart.Position).Magnitude) or 0
				if NameTagsRangeLimit.Value ~= 0 and mag > NameTagsRangeLimit.Value then 
					v.Main.Text.Visible = false
					v.Main.BG.Visible = false
					continue
				end
				if NameTagsDistance.Enabled then
					local stringsize = tostring(mag):len()
					v.Main.Text.Text = string.format(nametagstrs[v.entity.Player], mag)
					if nametagsizes[v.entity.Player] ~= stringsize then 
						v.Main.BG.Size = Vector2.new(v.Main.Text.TextBounds.X + 4, v.Main.Text.TextBounds.Y)
					end
					nametagsizes[v.entity.Player] = stringsize
				end
				v.Main.BG.Position = Vector2.new(headPos.X - (v.Main.BG.Size.X / 2), (headPos.Y + v.Main.BG.Size.Y))
				v.Main.Text.Position = v.Main.BG.Position + Vector2.new(2, 0)
				v.Main.Text.Visible = true
				v.Main.BG.Visible = NameTagsBackground.Enabled
			end
		end
	}

	local methodused

	local NameTags = {Enabled = false}
	NameTags = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "NameTags", 
		Function = function(callback) 
			if callback then
				methodused = NameTagsDrawing.Enabled and "Drawing" or "Normal"
				if nametagfuncs2[methodused] then
					table.insert(NameTags.Connections, entityLibrary.entityRemovedEvent:Connect(nametagfuncs2[methodused]))
				end
				if nametagfuncs1[methodused] then
					local addfunc = nametagfuncs1[methodused]
					for i,v in pairs(entityLibrary.entityList) do 
						if nametagsfolderdrawing[v.Player] then nametagfuncs2[methodused](v.Player) end
						addfunc(v)
					end
					table.insert(NameTags.Connections, entityLibrary.entityAddedEvent:Connect(function(ent)
						if nametagsfolderdrawing[ent.Player] then nametagfuncs2[methodused](ent.Player) end
						addfunc(ent)
					end))
				end
				if nametagupdatefuncs[methodused] then
					table.insert(NameTags.Connections, entityLibrary.entityUpdatedEvent:Connect(nametagupdatefuncs[methodused]))
					for i,v in pairs(entityLibrary.entityList) do 
						nametagupdatefuncs[methodused](v)
					end
				end
				if nametagcolorfuncs[methodused] then 
					table.insert(NameTags.Connections, GuiLibrary.ObjectsThatCanBeSaved.FriendsListTextCircleList.Api.FriendColorRefresh.Event:Connect(function()
						nametagcolorfuncs[methodused](NameTagsColor.Hue, NameTagsColor.Sat, NameTagsColor.Value)
					end))
				end
				if nametagloop[methodused] then 
					RunLoops:BindToRenderStep("NameTags", nametagloop[methodused])
				end
			else
				RunLoops:UnbindFromRenderStep("NameTags")
				if nametagfuncs2[methodused] then
					for i,v in pairs(nametagsfolderdrawing) do 
						nametagfuncs2[methodused](i)
					end
				end
			end
		end,
		HoverText = "Renders nametags on entities through walls."
	})
	for i,v in pairs(Enum.Font:GetEnumItems()) do 
		if v.Name ~= "SourceSans" then 
			table.insert(fontitems, v.Name)
		end
	end
	NameTagsFont = NameTags.CreateDropdown({
		Name = "Font",
		List = fontitems,
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
	})
	NameTagsColor = NameTags.CreateColorSlider({
		Name = "Player Color", 
		Function = function(hue, sat, val) 
			if NameTags.Enabled and nametagcolorfuncs[methodused] then 
				nametagcolorfuncs[methodused](hue, sat, val)
			end
		end
	})
	NameTagsScale = NameTags.CreateSlider({
		Name = "Scale",
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
		Default = 10,
		Min = 1,
		Max = 50
	})
	NameTagsRangeLimit = NameTags.CreateSlider({
		Name = "Range",
		Function = function() end,
		Min = 0,
		Max = 1000,
		Default = 0
	})
	NameTagsBackground = NameTags.CreateToggle({
		Name = "Background", 
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
		Default = true
	})
	NameTagsDisplayName = NameTags.CreateToggle({
		Name = "Use Display Name", 
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
		Default = true
	})
	NameTagsHealth = NameTags.CreateToggle({
		Name = "Health", 
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end
	})
	NameTagsDistance = NameTags.CreateToggle({
		Name = "Distance", 
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end
	})
	NameTagsShowInventory = NameTags.CreateToggle({
		Name = "Equipment",
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
		Default = true
	})
	NameTagsTeammates = NameTags.CreateToggle({
		Name = "Teammates", 
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
		Default = true
	})
	NameTagsDrawing = NameTags.CreateToggle({
		Name = "Drawing",
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
	})
end)

runFunction(function()
	local nobobdepth = {Value = 8}
	local nobobhorizontal = {Value = 8}
	local nobobvertical = {Value = -2}
	local rotationx = {Value = 0}
	local rotationy = {Value = 0}
	local rotationz = {Value = 0}
	local oldc1
	local oldfunc
	local nobob = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "NoBob",
		Function = function(callback) 
			local viewmodel = gameCamera:FindFirstChild("Viewmodel")
			if viewmodel then
				if callback then
					oldfunc = bedwars.ViewmodelController.playAnimation
					bedwars.ViewmodelController.playAnimation = function(self, animid, details)
						if animid == bedwars.AnimationType.FP_WALK then
							return
						end
						return oldfunc(self, animid, details)
					end
					bedwars.ViewmodelController:setHeldItem(lplr.Character and lplr.Character:FindFirstChild("HandInvItem") and lplr.Character.HandInvItem.Value and lplr.Character.HandInvItem.Value:Clone())
					lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_DEPTH_OFFSET", -(nobobdepth.Value / 10))
					lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_HORIZONTAL_OFFSET", (nobobhorizontal.Value / 10))
					lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_VERTICAL_OFFSET", (nobobvertical.Value / 10))
					oldc1 = viewmodel.RightHand.RightWrist.C1
					viewmodel.RightHand.RightWrist.C1 = oldc1 * CFrame.Angles(math.rad(rotationx.Value), math.rad(rotationy.Value), math.rad(rotationz.Value))
				else
					bedwars.ViewmodelController.playAnimation = oldfunc
					lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_DEPTH_OFFSET", 0)
					lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_HORIZONTAL_OFFSET", 0)
					lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_VERTICAL_OFFSET", 0)
					viewmodel.RightHand.RightWrist.C1 = oldc1
				end
			end
		end,
		HoverText = "Removes the ugly bobbing when you move and makes sword farther"
	})
	nobobdepth = nobob.CreateSlider({
		Name = "Depth",
		Min = 0,
		Max = 24,
		Default = 8,
		Function = function(val)
			if nobob.Enabled then
				lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_DEPTH_OFFSET", -(val / 10))
			end
		end
	})
	nobobhorizontal = nobob.CreateSlider({
		Name = "Horizontal",
		Min = 0,
		Max = 24,
		Default = 8,
		Function = function(val)
			if nobob.Enabled then
				lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_HORIZONTAL_OFFSET", (val / 10))
			end
		end
	})
	nobobvertical= nobob.CreateSlider({
		Name = "Vertical",
		Min = 0,
		Max = 24,
		Default = -2,
		Function = function(val)
			if nobob.Enabled then
				lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_VERTICAL_OFFSET", (val / 10))
			end
		end
	})
	rotationx = nobob.CreateSlider({
		Name = "RotX",
		Min = 0,
		Max = 360,
		Function = function(val)
			if nobob.Enabled then
				gameCamera.Viewmodel.RightHand.RightWrist.C1 = oldc1 * CFrame.Angles(math.rad(rotationx.Value), math.rad(rotationy.Value), math.rad(rotationz.Value))
			end
		end
	})
	rotationy = nobob.CreateSlider({
		Name = "RotY",
		Min = 0,
		Max = 360,
		Function = function(val)
			if nobob.Enabled then
				gameCamera.Viewmodel.RightHand.RightWrist.C1 = oldc1 * CFrame.Angles(math.rad(rotationx.Value), math.rad(rotationy.Value), math.rad(rotationz.Value))
			end
		end
	})
	rotationz = nobob.CreateSlider({
		Name = "RotZ",
		Min = 0,
		Max = 360,
		Function = function(val)
			if nobob.Enabled then
				gameCamera.Viewmodel.RightHand.RightWrist.C1 = oldc1 * CFrame.Angles(math.rad(rotationx.Value), math.rad(rotationy.Value), math.rad(rotationz.Value))
			end
		end
	})
end)

runFunction(function()
	local SongBeats = {Enabled = false}
	local SongBeatsList = {ObjectList = {}}
	local SongBeatsIntensity = {Value = 5}
	local SongTween
	local SongAudio

	local function PlaySong(arg)
		local args = arg:split(":")
		local song = isfile(args[1]) and getcustomasset(args[1]) or tonumber(args[1]) and "rbxassetid://"..args[1]
		if not song then 
			warningNotification("SongBeats", "missing music file "..args[1], 5)
			SongBeats.ToggleButton(false)
			return
		end
		local bpm = 1 / (args[2] / 60)
		SongAudio = Instance.new("Sound")
		SongAudio.SoundId = song
		SongAudio.Parent = workspace
		SongAudio:Play()
		repeat
			repeat task.wait() until SongAudio.IsLoaded or (not SongBeats.Enabled) 
			if (not SongBeats.Enabled) then break end
			local newfov = math.min(bedwars.FovController:getFOV() * (bedwars.SprintController.sprinting and 1.1 or 1), 120)
			gameCamera.FieldOfView = newfov - SongBeatsIntensity.Value
			if SongTween then SongTween:Cancel() end
			SongTween = game:GetService("TweenService"):Create(gameCamera, TweenInfo.new(0.2), {FieldOfView = newfov})
			SongTween:Play()
			task.wait(bpm)
		until (not SongBeats.Enabled) or SongAudio.IsPaused
	end

	SongBeats = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "SongBeats",
		Function = function(callback)
			if callback then 
				task.spawn(function()
					if #SongBeatsList.ObjectList <= 0 then 
						warningNotification("SongBeats", "no songs", 5)
						SongBeats.ToggleButton(false)
						return
					end
					local lastChosen
					repeat
						local newSong
						repeat newSong = SongBeatsList.ObjectList[Random.new():NextInteger(1, #SongBeatsList.ObjectList)] task.wait() until newSong ~= lastChosen or #SongBeatsList.ObjectList <= 1
						lastChosen = newSong
						PlaySong(newSong)
						if not SongBeats.Enabled then break end
						task.wait(2)
					until (not SongBeats.Enabled)
				end)
			else
				if SongAudio then SongAudio:Destroy() end
				if SongTween then SongTween:Cancel() end
				gameCamera.FieldOfView = bedwars.FovController:getFOV() * (bedwars.SprintController.sprinting and 1.1 or 1)
			end
		end
	})
	SongBeatsList = SongBeats.CreateTextList({
		Name = "SongList",
		TempText = "songpath:bpm"
	})
	SongBeatsIntensity = SongBeats.CreateSlider({
		Name = "Intensity",
		Function = function() end,
		Min = 1,
		Max = 10,
		Default = 5
	})
end)

runFunction(function()
	local performed = false
	GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "UICleanup",
		Function = function(callback)
			if callback and not performed then 
				performed = true
				task.spawn(function()
					local hotbar = require(lplr.PlayerScripts.TS.controllers.global.hotbar.ui["hotbar-app"]).HotbarApp
					local hotbaropeninv = require(lplr.PlayerScripts.TS.controllers.global.hotbar.ui["hotbar-open-inventory"]).HotbarOpenInventory
					local topbarbutton = require(replicatedStorageService["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out).TopBarButton
					local gametheme = require(replicatedStorageService["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out.shared.ui["game-theme"]).GameTheme
					bedwars.AppController:closeApp("TopBarApp")
					local oldrender = topbarbutton.render
					topbarbutton.render = function(self) 
						local res = oldrender(self)
						if not self.props.Text then
							return bedwars.Roact.createElement("TextButton", {Visible = false}, {})
						end
						return res
					end
					hotbaropeninv.render = function(self) 
						return bedwars.Roact.createElement("TextButton", {Visible = false}, {})
					end
					debug.setconstant(hotbar.render, 52, 0.9975)
					debug.setconstant(hotbar.render, 73, 100)
					debug.setconstant(hotbar.render, 89, 1)
					debug.setconstant(hotbar.render, 90, 0.04)
					debug.setconstant(hotbar.render, 91, -0.03)
					debug.setconstant(hotbar.render, 109, 1.35)
					debug.setconstant(hotbar.render, 110, 0)
					debug.setconstant(debug.getupvalue(hotbar.render, 11).render, 30, 1)
					debug.setconstant(debug.getupvalue(hotbar.render, 11).render, 31, 0.175)
					debug.setconstant(debug.getupvalue(hotbar.render, 11).render, 33, -0.101)
					debug.setconstant(debug.getupvalue(hotbar.render, 18).render, 71, 0)
					debug.setconstant(debug.getupvalue(hotbar.render, 18).tweenPosition, 16, 0)
					gametheme.topBarBGTransparency = 0.5
					bedwars.TopBarController:mountHud()
					game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
					bedwars.AbilityUIController.abilityButtonsScreenGui.Visible = false
					bedwars.MatchEndScreenController.waitUntilDisplay = function() return false end
					task.spawn(function()
						repeat
							task.wait()
							local gui = lplr.PlayerGui:FindFirstChild("StatusEffectHudScreen")
							if gui then gui.Enabled = false break end
						until false
					end)
					task.spawn(function()
						repeat task.wait() until bedwarsStore.matchState ~= 0
						if bedwars.ClientStoreHandler:getState().Game.customMatch == nil then 
							debug.setconstant(bedwars.QueueCard.render, 9, 0.1)
						end
					end)
					local slot = bedwars.ClientStoreHandler:getState().Inventory.observedInventory.hotbarSlot
					bedwars.ClientStoreHandler:dispatch({
						type = "InventorySelectHotbarSlot",
						slot = slot + 1 % 8
					})
					bedwars.ClientStoreHandler:dispatch({
						type = "InventorySelectHotbarSlot",
						slot = slot
					})
				end)
			end
		end
	})
end)

runFunction(function()
	local AntiAFK = {Enabled = false}
	AntiAFK = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "AntiAFK",
		Function = function(callback)
			if callback then 
				task.spawn(function()
					repeat 
						task.wait(5) 
						bedwars.ClientHandler:Get("AfkInfo"):SendToServer({
							afk = false
						})
					until (not AntiAFK.Enabled)
				end)
			end
		end
	})
end)

runFunction(function()
	local AutoBalloonPart
	local AutoBalloonConnection
	local AutoBalloonDelay = {Value = 10}
	local AutoBalloonLegit = {Enabled = false}
	local AutoBalloonypos = 0
	local balloondebounce = false
	local AutoBalloon = {Enabled = false}
	AutoBalloon = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "AutoBalloon", 
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat task.wait() until bedwarsStore.matchState ~= 0 or  not vapeInjected
					if vapeInjected and AutoBalloonypos == 0 and AutoBalloon.Enabled then
						local lowestypos = 99999
						for i,v in pairs(bedwarsStore.blocks) do 
							local newray = workspace:Raycast(v.Position + Vector3.new(0, 800, 0), Vector3.new(0, -1000, 0), bedwarsStore.blockRaycast)
							if i % 200 == 0 then 
								task.wait(0.06)
							end
							if newray and newray.Position.Y <= lowestypos then
								lowestypos = newray.Position.Y
							end
						end
						AutoBalloonypos = lowestypos - 8
					end
				end)
				task.spawn(function()
					repeat task.wait() until AutoBalloonypos ~= 0
					if AutoBalloon.Enabled then
						AutoBalloonPart = Instance.new("Part")
						AutoBalloonPart.CanCollide = false
						AutoBalloonPart.Size = Vector3.new(10000, 1, 10000)
						AutoBalloonPart.Anchored = true
						AutoBalloonPart.Transparency = 1
						AutoBalloonPart.Material = Enum.Material.Neon
						AutoBalloonPart.Color = Color3.fromRGB(135, 29, 139)
						AutoBalloonPart.Position = Vector3.new(0, AutoBalloonypos - 50, 0)
						AutoBalloonConnection = AutoBalloonPart.Touched:Connect(function(touchedpart)
							if entityLibrary.isAlive and touchedpart:IsDescendantOf(lplr.Character) and balloondebounce == false then
								autobankballoon = true
								balloondebounce = true
								local oldtool = bedwarsStore.localHand.tool
								for i = 1, 3 do
									if getItem("balloon") and (AutoBalloonLegit.Enabled and getHotbarSlot("balloon") or AutoBalloonLegit.Enabled == false) and (lplr.Character:GetAttribute("InflatedBalloons") and lplr.Character:GetAttribute("InflatedBalloons") < 3 or lplr.Character:GetAttribute("InflatedBalloons") == nil) then
										if AutoBalloonLegit.Enabled then
											if getHotbarSlot("balloon") then
												bedwars.ClientStoreHandler:dispatch({
													type = "InventorySelectHotbarSlot", 
													slot = getHotbarSlot("balloon")
												})
												task.wait(AutoBalloonDelay.Value / 100)
												bedwars.BalloonController:inflateBalloon()
											end
										else
											task.wait(AutoBalloonDelay.Value / 100)
											bedwars.BalloonController:inflateBalloon()
										end
									end
								end
								if AutoBalloonLegit.Enabled and oldtool and getHotbarSlot(oldtool.Name) then
									task.wait(0.2)
									bedwars.ClientStoreHandler:dispatch({
										type = "InventorySelectHotbarSlot", 
										slot = (getHotbarSlot(oldtool.Name) or 0)
									})
								end
								balloondebounce = false
								autobankballoon = false
							end
						end)
						AutoBalloonPart.Parent = workspace
					end
				end)
			else
				if AutoBalloonConnection then AutoBalloonConnection:Disconnect() end
				if AutoBalloonPart then
					AutoBalloonPart:Remove() 
				end
			end
		end, 
		HoverText = "Automatically Inflates Balloons"
	})
	AutoBalloonDelay = AutoBalloon.CreateSlider({
		Name = "Delay",
		Min = 1,
		Max = 50,
		Default = 20,
		Function = function() end,
		HoverText = "Delay to inflate balloons."
	})
	AutoBalloonLegit = AutoBalloon.CreateToggle({
		Name = "Legit Mode",
		Function = function() end,
		HoverText = "Switches to balloons in hotbar and inflates them."
	})
end)

local autobankapple = false
runFunction(function()
	local AutoBuy = {Enabled = false}
	local AutoBuyArmor = {Enabled = false}
	local AutoBuySword = {Enabled = false}
	local AutoBuyUpgrades = {Enabled = false}
	local AutoBuyGen = {Enabled = false}
	local AutoBuyProt = {Enabled = false}
	local AutoBuySharp = {Enabled = false}
	local AutoBuyDestruction = {Enabled = false}
	local AutoBuyDiamond = {Enabled = false}
	local AutoBuyAlarm = {Enabled = false}
	local AutoBuyGui = {Enabled = false}
	local AutoBuyTierSkip = {Enabled = true}
	local AutoBuyRange = {Value = 20}
	local AutoBuyCustom = {ObjectList = {}, RefreshList = function() end}
	local AutoBankUIToggle = {Enabled = false}
	local AutoBankDeath = {Enabled = false}
	local AutoBankStay = {Enabled = false}
	local buyingthing = false
	local shoothook
	local bedwarsshopnpcs = {}
	local id
	local armors = {
		[1] = "leather_chestplate",
		[2] = "iron_chestplate",
		[3] = "diamond_chestplate",
		[4] = "emerald_chestplate"
	}

	local swords = {
		[1] = "wood_sword",
		[2] = "stone_sword",
		[3] = "iron_sword",
		[4] = "diamond_sword",
		[5] = "emerald_sword"
	}

	local axes = {
		[1] = "wood_axe",
		[2] = "stone_axe",
		[3] = "iron_axe",
		[4] = "diamond_axe"
	}

	local pickaxes = {
		[1] = "wood_pickaxe",
		[2] = "stone_pickaxe",
		[3] = "iron_pickaxe",
		[4] = "diamond_pickaxe"
	}

	task.spawn(function()
		repeat task.wait() until bedwarsStore.matchState ~= 0 or not vapeInjected
		for i,v in pairs(collectionService:GetTagged("BedwarsItemShop")) do
			table.insert(bedwarsshopnpcs, {Position = v.Position, TeamUpgradeNPC = true, Id = v.Name})
		end
		for i,v in pairs(collectionService:GetTagged("BedwarsTeamUpgrader")) do
			table.insert(bedwarsshopnpcs, {Position = v.Position, TeamUpgradeNPC = false, Id = v.Name})
		end
	end)

	local function nearNPC(range)
		local npc, npccheck, enchant, newid = nil, false, false, nil
		if entityLibrary.isAlive then
			local enchanttab = {}
			for i,v in pairs(collectionService:GetTagged("broken-enchant-table")) do 
				table.insert(enchanttab, v)
			end
			for i,v in pairs(collectionService:GetTagged("enchant-table")) do 
				table.insert(enchanttab, v)
			end
			for i,v in pairs(enchanttab) do 
				if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - v.Position).magnitude <= 6 then
					if ((not v:GetAttribute("Team")) or v:GetAttribute("Team") == lplr:GetAttribute("Team")) then
						npc, npccheck, enchant = true, true, true
					end
				end
			end
			for i, v in pairs(bedwarsshopnpcs) do
				if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - v.Position).magnitude <= (range or 20) then
					npc, npccheck, enchant = true, (v.TeamUpgradeNPC or npccheck), false
					newid = v.TeamUpgradeNPC and v.Id or newid
				end
			end
			local suc, res = pcall(function() return lplr.leaderstats.Bed.Value == "✅"  end)
			if AutoBankDeath.Enabled and (workspace:GetServerTimeNow() - lplr.Character:GetAttribute("LastDamageTakenTime")) < 2 and suc and res then 
				return nil, false, false
			end
			if AutoBankStay.Enabled then 
				return nil, false, false
			end
		end
		return npc, not npccheck, enchant, newid
	end

	local function buyItem(itemtab, waitdelay)
		if not id then return end
		local res
		bedwars.ClientHandler:Get("BedwarsPurchaseItem"):CallServerAsync({
			shopItem = itemtab,
			shopId = id
		}):andThen(function(p11)
			if p11 then
				bedwars.SoundManager:playSound(bedwars.SoundList.BEDWARS_PURCHASE_ITEM)
				bedwars.ClientStoreHandler:dispatch({
					type = "BedwarsAddItemPurchased", 
					itemType = itemtab.itemType
				})
			end
			res = p11
		end)
		if waitdelay then 
			repeat task.wait() until res ~= nil
		end
	end

	local function buyUpgrade(upgradetype, inv, upgrades)
		if not AutoBuyUpgrades.Enabled then return end
		local teamupgrade = bedwars.Shop.getUpgrade(bedwars.Shop.TeamUpgrades, upgradetype)
		local teamtier = teamupgrade.tiers[upgrades[upgradetype] and upgrades[upgradetype] + 2 or 1]
		if teamtier then 
			local teamcurrency = getItem(teamtier.currency, inv.items)
			if teamcurrency and teamcurrency.amount >= teamtier.price then 
				bedwars.ClientHandler:Get("BedwarsPurchaseTeamUpgrade"):CallServerAsync({
					upgradeId = upgradetype, 
					tier = upgrades[upgradetype] and upgrades[upgradetype] + 1 or 0
				}):andThen(function(suc)
					if suc then
						bedwars.SoundManager:playSound(bedwars.SoundList.BEDWARS_PURCHASE_ITEM)
					end
				end)
			end
		end
	end

	local function getAxeNear(inv)
		for i5, v5 in pairs(inv or bedwarsStore.localInventory.inventory.items) do
			if v5.itemType:find("axe") and v5.itemType:find("pickaxe") == nil then
				return v5.itemType
			end
		end
		return nil
	end

	local function getPickaxeNear(inv)
		for i5, v5 in pairs(inv or bedwarsStore.localInventory.inventory.items) do
			if v5.itemType:find("pickaxe") then
				return v5.itemType
			end
		end
		return nil
	end

	local function getShopItem(itemType)
		if itemType == "axe" then 
			itemType = getAxeNear() or "wood_axe"
			itemType = axes[table.find(axes, itemType) + 1] or itemType
		end
		if itemType == "pickaxe" then 
			itemType = getPickaxeNear() or "wood_pickaxe"
			itemType = pickaxes[table.find(pickaxes, itemType) + 1] or itemType
		end
		for i,v in pairs(bedwars.ShopItems) do 
			if v.itemType == itemType then return v end
		end
		return nil
	end

	local buyfunctions = {
		Armor = function(inv, upgrades, shoptype) 
			if AutoBuyArmor.Enabled == false or shoptype ~= "item" then return end
			local currentarmor = (inv.armor[2] ~= "empty" and inv.armor[2].itemType:find("chestplate") ~= nil) and inv.armor[2] or nil
			local armorindex = (currentarmor and table.find(armors, currentarmor.itemType) or 0) + 1
			if armors[armorindex] == nil then return end
			local highestbuyable = nil
			for i = armorindex, #armors, 1 do 
				local shopitem = getShopItem(armors[i])
				if shopitem and (AutoBuyTierSkip.Enabled or i == armorindex) then 
					local currency = getItem(shopitem.currency, inv.items)
					if currency and currency.amount >= shopitem.price then 
						highestbuyable = shopitem
						bedwars.ClientStoreHandler:dispatch({
							type = "BedwarsAddItemPurchased", 
							itemType = shopitem.itemType
						})
					end
				end
			end
			if highestbuyable and (highestbuyable.ignoredByKit == nil or table.find(highestbuyable.ignoredByKit, bedwarsStore.equippedKit) == nil) then 
				buyItem(highestbuyable)
			end
		end,
		Sword = function(inv, upgrades, shoptype)
			if AutoBuySword.Enabled == false or shoptype ~= "item" then return end
			local currentsword = getItemNear("sword", inv.items)
			local swordindex = (currentsword and table.find(swords, currentsword.itemType) or 0) + 1
			if currentsword ~= nil and table.find(swords, currentsword.itemType) == nil then return end
			local highestbuyable = nil
			for i = swordindex, #swords, 1 do 
				local shopitem = getShopItem(swords[i])
				if shopitem then 
					local currency = getItem(shopitem.currency, inv.items)
					if currency and currency.amount >= shopitem.price and (shopitem.category ~= "Armory" or upgrades.armory) then 
						highestbuyable = shopitem
						bedwars.ClientStoreHandler:dispatch({
							type = "BedwarsAddItemPurchased", 
							itemType = shopitem.itemType
						})
					end
				end
			end
			if highestbuyable and (highestbuyable.ignoredByKit == nil or table.find(highestbuyable.ignoredByKit, bedwarsStore.equippedKit) == nil) then 
				buyItem(highestbuyable)
			end
		end,
		Protection = function(inv, upgrades)
			if not AutoBuyProt.Enabled then return end
			buyUpgrade("armor", inv, upgrades)
		end,
		Sharpness = function(inv, upgrades)
			if not AutoBuySharp.Enabled then return end
			buyUpgrade("damage", inv, upgrades)
		end,
		Generator = function(inv, upgrades)
			if not AutoBuyGen.Enabled then return end
			buyUpgrade("generator", inv, upgrades)
		end,
		Destruction = function(inv, upgrades)
			if not AutoBuyDestruction.Enabled then return end
			buyUpgrade("destruction", inv, upgrades)
		end,
		Diamond = function(inv, upgrades)
			if not AutoBuyDiamond.Enabled then return end
			buyUpgrade("diamond_generator", inv, upgrades)
		end,
		Alarm = function(inv, upgrades)
			if not AutoBuyAlarm.Enabled then return end
			buyUpgrade("alarm", inv, upgrades)
		end
	}

	AutoBuy = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "AutoBuy", 
		Function = function(callback)
			if callback then 
				buyingthing = false 
				task.spawn(function()
					repeat
						task.wait()
						local found, npctype, enchant, newid = nearNPC(AutoBuyRange.Value)
						id = newid
						if found then
							local inv = bedwarsStore.localInventory.inventory
							local currentupgrades = bedwars.ClientStoreHandler:getState().Bedwars.teamUpgrades
							if bedwarsStore.equippedKit == "dasher" then 
								swords = {
									[1] = "wood_dao",
									[2] = "stone_dao",
									[3] = "iron_dao",
									[4] = "diamond_dao",
									[5] = "emerald_dao"
								}
							elseif bedwarsStore.equippedKit == "ice_queen" then 
								swords[5] = "ice_sword"
							elseif bedwarsStore.equippedKit == "ember" then 
								swords[5] = "infernal_saber"
							elseif bedwarsStore.equippedKit == "lumen" then 
								swords[5] = "light_sword"
							end
							if (AutoBuyGui.Enabled == false or (bedwars.AppController:isAppOpen("BedwarsItemShopApp") or bedwars.AppController:isAppOpen("BedwarsTeamUpgradeApp"))) and (not enchant) then
								for i,v in pairs(AutoBuyCustom.ObjectList) do 
									local autobuyitem = v:split("/")
									if #autobuyitem >= 3 and autobuyitem[4] ~= "true" then 
										local shopitem = getShopItem(autobuyitem[1])
										if shopitem then 
											local currency = getItem(shopitem.currency, inv.items)
											local actualitem = getItem(shopitem.itemType == "wool_white" and getWool() or shopitem.itemType, inv.items)
											if currency and currency.amount >= shopitem.price and (actualitem == nil or actualitem.amount < tonumber(autobuyitem[2])) then 
												buyItem(shopitem, tonumber(autobuyitem[2]) > 1)
											end
										end
									end
								end
								for i,v in pairs(buyfunctions) do v(inv, currentupgrades, npctype and "upgrade" or "item") end
								for i,v in pairs(AutoBuyCustom.ObjectList) do 
									local autobuyitem = v:split("/")
									if #autobuyitem >= 3 and autobuyitem[4] == "true" then 
										local shopitem = getShopItem(autobuyitem[1])
										if shopitem then 
											local currency = getItem(shopitem.currency, inv.items)
											local actualitem = getItem(shopitem.itemType == "wool_white" and getWool() or shopitem.itemType, inv.items)
											if currency and currency.amount >= shopitem.price and (actualitem == nil or actualitem.amount < tonumber(autobuyitem[2])) then 
												buyItem(shopitem, tonumber(autobuyitem[2]) > 1)
											end
										end
									end
								end
							end
						end
					until (not AutoBuy.Enabled)
				end)
			end
		end,
		HoverText = "Automatically Buys Swords, Armor, and Team Upgrades\nwhen you walk near the NPC"
	})
	AutoBuyRange = AutoBuy.CreateSlider({
		Name = "Range",
		Function = function() end,
		Min = 1,
		Max = 20,
		Default = 20
	})
	AutoBuyArmor = AutoBuy.CreateToggle({
		Name = "Buy Armor",
		Function = function() end, 
		Default = true
	})
	AutoBuySword = AutoBuy.CreateToggle({
		Name = "Buy Sword",
		Function = function() end, 
		Default = true
	})
	AutoBuyUpgrades = AutoBuy.CreateToggle({
		Name = "Buy Team Upgrades",
		Function = function(callback) 
			if AutoBuyUpgrades.Object then AutoBuyUpgrades.Object.ToggleArrow.Visible = callback end
			if AutoBuyGen.Object then AutoBuyGen.Object.Visible = callback end
			if AutoBuyProt.Object then AutoBuyProt.Object.Visible = callback end
			if AutoBuySharp.Object then AutoBuySharp.Object.Visible = callback end
			if AutoBuyDestruction.Object then AutoBuyDestruction.Object.Visible = callback end
			if AutoBuyDiamond.Object then AutoBuyDiamond.Object.Visible = callback end
			if AutoBuyAlarm.Object then AutoBuyAlarm.Object.Visible = callback end
		end, 
		Default = true
	})
	AutoBuyGen = AutoBuy.CreateToggle({
		Name = "Buy Team Generator",
		Function = function() end, 
	})
	AutoBuyProt = AutoBuy.CreateToggle({
		Name = "Buy Protection",
		Function = function() end, 
		Default = true
	})
	AutoBuySharp = AutoBuy.CreateToggle({
		Name = "Buy Sharpness",
		Function = function() end, 
		Default = true
	})
	AutoBuyDestruction = AutoBuy.CreateToggle({
		Name = "Buy Destruction",
		Function = function() end, 
	})
	AutoBuyDiamond = AutoBuy.CreateToggle({
		Name = "Buy Diamond Generator",
		Function = function() end, 
	})
	AutoBuyAlarm = AutoBuy.CreateToggle({
		Name = "Buy Alarm",
		Function = function() end, 
	})
	AutoBuyGui = AutoBuy.CreateToggle({
		Name = "Shop GUI Check",
		Function = function() end, 	
	})
	AutoBuyTierSkip = AutoBuy.CreateToggle({
		Name = "Tier Skip",
		Function = function() end, 
		Default = true
	})
	AutoBuyGen.Object.BackgroundTransparency = 0
	AutoBuyGen.Object.BorderSizePixel = 0
	AutoBuyGen.Object.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	AutoBuyGen.Object.Visible = AutoBuyUpgrades.Enabled
	AutoBuyProt.Object.BackgroundTransparency = 0
	AutoBuyProt.Object.BorderSizePixel = 0
	AutoBuyProt.Object.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	AutoBuyProt.Object.Visible = AutoBuyUpgrades.Enabled
	AutoBuySharp.Object.BackgroundTransparency = 0
	AutoBuySharp.Object.BorderSizePixel = 0
	AutoBuySharp.Object.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	AutoBuySharp.Object.Visible = AutoBuyUpgrades.Enabled
	AutoBuyDestruction.Object.BackgroundTransparency = 0
	AutoBuyDestruction.Object.BorderSizePixel = 0
	AutoBuyDestruction.Object.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	AutoBuyDestruction.Object.Visible = AutoBuyUpgrades.Enabled
	AutoBuyDiamond.Object.BackgroundTransparency = 0
	AutoBuyDiamond.Object.BorderSizePixel = 0
	AutoBuyDiamond.Object.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	AutoBuyDiamond.Object.Visible = AutoBuyUpgrades.Enabled
	AutoBuyAlarm.Object.BackgroundTransparency = 0
	AutoBuyAlarm.Object.BorderSizePixel = 0
	AutoBuyAlarm.Object.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	AutoBuyAlarm.Object.Visible = AutoBuyUpgrades.Enabled
	AutoBuyCustom = AutoBuy.CreateTextList({
		Name = "BuyList",
		TempText = "item/amount/priority/after",
		SortFunction = function(a, b)
			local amount1 = a:split("/")
			local amount2 = b:split("/")
			amount1 = #amount1 and tonumber(amount1[3]) or 1
			amount2 = #amount2 and tonumber(amount2[3]) or 1
			return amount1 < amount2
		end
	})
	AutoBuyCustom.Object.AddBoxBKG.AddBox.TextSize = 14

	local AutoBank = {Enabled = false}
	local AutoBankRange = {Value = 20}
	local AutoBankApple = {Enabled = false}
	local AutoBankBalloon = {Enabled = false}
	local AutoBankTransmitted, AutoBankTransmittedType = false, false
	local autobankoldapple
	local autobankoldballoon
	local autobankui

	local function refreshbank()
		if autobankui then
			local echest = replicatedStorageService.Inventories:FindFirstChild(lplr.Name.."_personal")
			for i,v in pairs(autobankui:GetChildren()) do 
				if echest:FindFirstChild(v.Name) then 
					v.Amount.Text = echest[v.Name]:GetAttribute("Amount")
				else
					v.Amount.Text = ""
				end
			end
		end
	end

	AutoBank = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "AutoBank",
		Function = function(callback)
			if callback then
				autobankui = Instance.new("Frame")
				autobankui.Size = UDim2.new(0, 240, 0, 40)
				autobankui.AnchorPoint = Vector2.new(0.5, 0)
				autobankui.Position = UDim2.new(0.5, 0, 0, -240)
				autobankui.Visible = AutoBankUIToggle.Enabled
				task.spawn(function()
					repeat
						task.wait()
						if autobankui then 
							local hotbar = lplr.PlayerGui:FindFirstChild("hotbar")
							if hotbar then 
								local healthbar = hotbar["1"]:FindFirstChild("HotbarHealthbarContainer")
								if healthbar then 
									autobankui.Position = UDim2.new(0.5, 0, 0, healthbar.AbsolutePosition.Y - 50)
								end
							end
						else
							break
						end
					until (not AutoBank.Enabled)
				end)
				autobankui.BackgroundTransparency = 1
				autobankui.Parent = GuiLibrary.MainGui
				local emerald = Instance.new("ImageLabel")
				emerald.Image = bedwars.getIcon({itemType = "emerald"}, true)
				emerald.Size = UDim2.new(0, 40, 0, 40)
				emerald.Name = "emerald"
				emerald.Position = UDim2.new(0, 120, 0, 0)
				emerald.BackgroundTransparency = 1
				emerald.Parent = autobankui
				local emeraldtext = Instance.new("TextLabel")
				emeraldtext.TextSize = 20
				emeraldtext.BackgroundTransparency = 1
				emeraldtext.Size = UDim2.new(1, 0, 1, 0)
				emeraldtext.Font = Enum.Font.SourceSans
				emeraldtext.TextStrokeTransparency = 0.3
				emeraldtext.Name = "Amount"
				emeraldtext.Text = ""
				emeraldtext.TextColor3 = Color3.new(1, 1, 1)
				emeraldtext.Parent = emerald
				local diamond = emerald:Clone()
				diamond.Image = bedwars.getIcon({itemType = "diamond"}, true)
				diamond.Position = UDim2.new(0, 80, 0, 0)
				diamond.Name = "diamond"
				diamond.Parent = autobankui
				local gold = emerald:Clone()
				gold.Image = bedwars.getIcon({itemType = "gold"}, true)
				gold.Position = UDim2.new(0, 40, 0, 0)
				gold.Name = "gold"
				gold.Parent = autobankui
				local iron = emerald:Clone()
				iron.Image = bedwars.getIcon({itemType = "iron"}, true)
				iron.Position = UDim2.new(0, 0, 0, 0)
				iron.Name = "iron"
				iron.Parent = autobankui
				local apple = emerald:Clone()
				apple.Image = bedwars.getIcon({itemType = "apple"}, true)
				apple.Position = UDim2.new(0, 160, 0, 0)
				apple.Name = "apple"
				apple.Parent = autobankui
				local balloon = emerald:Clone()
				balloon.Image = bedwars.getIcon({itemType = "balloon"}, true)
				balloon.Position = UDim2.new(0, 200, 0, 0)
				balloon.Name = "balloon"
				balloon.Parent = autobankui
				local echest = replicatedStorageService.Inventories:FindFirstChild(lplr.Name.."_personal")
				if entityLibrary.isAlive and echest then
					task.spawn(function()
						local chestitems = bedwarsStore.localInventory.inventory.items
						for i3,v3 in pairs(chestitems) do
							if (v3.itemType == "emerald" or v3.itemType == "iron" or v3.itemType == "diamond" or v3.itemType == "gold" or (v3.itemType == "apple" and AutoBankApple.Enabled) or (v3.itemType == "balloon" and AutoBankBalloon.Enabled)) then
								bedwars.ClientHandler:GetNamespace("Inventory"):Get("ChestGiveItem"):CallServer(echest, v3.tool)
								refreshbank()
							end
						end
					end)
				else
					task.spawn(function()
						refreshbank()
					end)
				end
				table.insert(AutoBank.Connections, replicatedStorageService.Inventories.DescendantAdded:Connect(function(p3)
					if p3.Parent.Name == lplr.Name then
						if echest == nil then 
							echest = replicatedStorageService.Inventories:FindFirstChild(lplr.Name.."_personal")
						end	
						if not echest then return end
						if p3.Name == "apple" and AutoBankApple.Enabled then 
							if autobankapple then return end
						elseif p3.Name == "balloon" and AutoBankBalloon.Enabled then 
							if autobankballoon then vapeEvents.AutoBankBalloon:Fire() return end
						elseif (p3.Name == "emerald" or p3.Name == "iron" or p3.Name == "diamond" or p3.Name == "gold") then
							if not ((not AutoBankTransmitted) or (AutoBankTransmittedType and p3.Name ~= "diamond")) then return end
						else
							return
						end
						bedwars.ClientHandler:GetNamespace("Inventory"):Get("ChestGiveItem"):CallServer(echest, p3)
						refreshbank()
					end
				end))
				task.spawn(function()
					repeat
						task.wait()
						local found, npctype = nearNPC(AutoBankRange.Value)
						if echest == nil then 
							echest = replicatedStorageService.Inventories:FindFirstChild(lplr.Name.."_personal")
						end
						if autobankballoon then 
							local chestitems = echest and echest:GetChildren() or {}
							if #chestitems > 0 then
								for i3,v3 in pairs(chestitems) do
									if v3:IsA("Accessory") and v3.Name == "balloon" then
										if (not getItem("balloon")) then
											task.spawn(function()
												bedwars.ClientHandler:GetNamespace("Inventory"):Get("ChestGetItem"):CallServer(echest, v3)
												refreshbank()
											end)
										end
									end
								end
							end
						end
						if autobankballoon ~= autobankoldballoon and AutoBankBalloon.Enabled then 
							if entityLibrary.isAlive then
								if not autobankballoon then
									local chestitems = bedwarsStore.localInventory.inventory.items
									if #chestitems > 0 then
										for i3,v3 in pairs(chestitems) do
											if v3 and v3.itemType == "balloon" then
												task.spawn(function()
													bedwars.ClientHandler:GetNamespace("Inventory"):Get("ChestGiveItem"):CallServer(echest, v3.tool)
													refreshbank()
												end)
											end
										end
									end
								end
							end
							autobankoldballoon = autobankballoon
						end
						if autobankapple then 
							local chestitems = echest and echest:GetChildren() or {}
							if #chestitems > 0 then
								for i3,v3 in pairs(chestitems) do
									if v3:IsA("Accessory") and v3.Name == "apple" then
										if (not getItem("apple")) then
											task.spawn(function()
												bedwars.ClientHandler:GetNamespace("Inventory"):Get("ChestGetItem"):CallServer(echest, v3)
												refreshbank()
											end)
										end
									end
								end
							end
						end
						if (autobankapple ~= autobankoldapple) and AutoBankApple.Enabled then 
							if entityLibrary.isAlive then
								if not autobankapple then
									local chestitems = bedwarsStore.localInventory.inventory.items
									if #chestitems > 0 then
										for i3,v3 in pairs(chestitems) do
											if v3 and v3.itemType == "apple" then
												task.spawn(function()
													bedwars.ClientHandler:GetNamespace("Inventory"):Get("ChestGiveItem"):CallServer(echest, v3.tool)
													refreshbank()
												end)
											end
										end
									end
								end
							end
							autobankoldapple = autobankapple
						end
						if found ~= AutoBankTransmitted or npctype ~= AutoBankTransmittedType then
							AutoBankTransmitted, AutoBankTransmittedType = found, npctype
							if entityLibrary.isAlive then
								local chestitems = bedwarsStore.localInventory.inventory.items
								if #chestitems > 0 then
									for i3,v3 in pairs(chestitems) do
										if v3 and (v3.itemType == "emerald" or v3.itemType == "iron" or v3.itemType == "diamond" or v3.itemType == "gold") then
											if (not AutoBankTransmitted) or (AutoBankTransmittedType and v3.Name ~= "diamond") then 
												task.spawn(function()
													pcall(function()
														bedwars.ClientHandler:GetNamespace("Inventory"):Get("ChestGiveItem"):CallServer(echest, v3.tool)
													end)
													refreshbank()
												end)
											end
										end
									end
								end
							end
						end
						if found then 
							local chestitems = echest and echest:GetChildren() or {}
							if #chestitems > 0 then
								for i3,v3 in pairs(chestitems) do
									if v3:IsA("Accessory") and ((npctype == false and (v3.Name == "emerald" or v3.Name == "iron" or v3.Name == "gold")) or v3.Name == "diamond") then
										task.spawn(function()
											pcall(function()
												bedwars.ClientHandler:GetNamespace("Inventory"):Get("ChestGetItem"):CallServer(echest, v3)
											end)
											refreshbank()
										end)
									end
								end
							end
						end
					until (not AutoBank.Enabled)
				end)
			else
				if autobankui then
					autobankui:Destroy()
					autobankui = nil
				end
				local echest = replicatedStorageService.Inventories:FindFirstChild(lplr.Name.."_personal")
				local chestitems = echest and echest:GetChildren() or {}
				if #chestitems > 0 then
					for i3,v3 in pairs(chestitems) do
						if v3:IsA("Accessory") and (v3.Name == "emerald" or v3.Name == "iron" or v3.Name == "diamond" or v3.Name == "apple" or v3.Name == "balloon") then
							task.spawn(function()
								pcall(function()
									bedwars.ClientHandler:GetNamespace("Inventory"):Get("ChestGetItem"):CallServer(echest, v3)
								end)
								refreshbank()
							end)
						end
					end
				end
			end
		end
	})
	AutoBankUIToggle = AutoBank.CreateToggle({
		Name = "UI",
		Function = function(callback)
			if autobankui then autobankui.Visible = callback end
		end,
		Default = true
	})
	AutoBankApple = AutoBank.CreateToggle({
		Name = "Apple",
		Function = function(callback) 
			if not callback then 
				local echest = replicatedStorageService.Inventories:FindFirstChild(lplr.Name.."_personal")
				local chestitems = echest and echest:GetChildren() or {}
				for i3,v3 in pairs(chestitems) do
					if v3:IsA("Accessory") and v3.Name == "apple" then
						task.spawn(function()
							bedwars.ClientHandler:GetNamespace("Inventory"):Get("ChestGetItem"):CallServer(echest, v3)
							refreshbank()
						end)
					end
				end
			end
		end,
		Default = true
	})
	AutoBankBalloon = AutoBank.CreateToggle({
		Name = "Balloon",
		Function = function(callback) 
			if not callback then 
				local echest = replicatedStorageService.Inventories:FindFirstChild(lplr.Name.."_personal")
				local chestitems = echest and echest:GetChildren() or {}
				for i3,v3 in pairs(chestitems) do
					if v3:IsA("Accessory") and v3.Name == "balloon" then
						task.spawn(function()
							bedwars.ClientHandler:GetNamespace("Inventory"):Get("ChestGetItem"):CallServer(echest, v3)
							refreshbank()
						end)
					end
				end
			end
		end,
		Default = true
	})
	AutoBankDeath = AutoBank.CreateToggle({
		Name = "Damage",
		Function = function() end,
		HoverText = "puts away resources when you take damage to prevent losing on death"
	})
	AutoBankStay = AutoBank.CreateToggle({
		Name = "Stay",
		Function = function() end,
		HoverText = "keeps resources until toggled off"
	})
	AutoBankRange = AutoBank.CreateSlider({
		Name = "Range",
		Function = function() end,
		Min = 1,
		Max = 20,
		Default = 20
	})
end)

runFunction(function()
	local AutoConsume = {Enabled = false}
	local AutoConsumeHealth = {Value = 100}
	local AutoConsumeSpeed = {Enabled = true}
	local AutoConsumeDelay = tick()

	local function AutoConsumeFunc()
		if entityLibrary.isAlive then
			local speedpotion = getItem("speed_potion")
			if lplr.Character:GetAttribute("Health") <= (lplr.Character:GetAttribute("MaxHealth") - (100 - AutoConsumeHealth.Value)) then
				autobankapple = true
				local item = getItem("apple")
				local pot = getItem("heal_splash_potion")
				if (item or pot) and AutoConsumeDelay <= tick() then
					if item then
						bedwars.ClientHandler:Get(bedwars.EatRemote):CallServerAsync({
							item = item.tool
						})
						AutoConsumeDelay = tick() + 0.6
					else
						local newray = workspace:Raycast((oldcloneroot or entityLibrary.character.HumanoidRootPart).Position, Vector3.new(0, -76, 0), bedwarsStore.blockRaycast)
						if newray ~= nil then
							bedwars.ClientHandler:Get(bedwars.ProjectileRemote):CallServerAsync(pot.tool, "heal_splash_potion", "heal_splash_potion", (oldcloneroot or entityLibrary.character.HumanoidRootPart).Position, (oldcloneroot or entityLibrary.character.HumanoidRootPart).Position, Vector3.new(0, -70, 0), game:GetService("HttpService"):GenerateGUID(), {drawDurationSeconds = 1})
						end
					end
				end
			else
				autobankapple = false
			end
			if speedpotion and (not lplr.Character:GetAttribute("StatusEffect_speed")) and AutoConsumeSpeed.Enabled then 
				bedwars.ClientHandler:Get(bedwars.EatRemote):CallServerAsync({
					item = speedpotion.tool
				})
			end
			if lplr.Character:GetAttribute("Shield_POTION") and ((not lplr.Character:GetAttribute("Shield_POTION")) or lplr.Character:GetAttribute("Shield_POTION") == 0) then
				local shield = getItem("big_shield") or getItem("mini_shield")
				if shield then
					bedwars.ClientHandler:Get(bedwars.EatRemote):CallServerAsync({
						item = shield.tool
					})
				end
			end
		end
	end

	AutoConsume = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "AutoConsume",
		Function = function(callback)
			if callback then
				table.insert(AutoConsume.Connections, vapeEvents.InventoryAmountChanged.Event:Connect(AutoConsumeFunc))
				table.insert(AutoConsume.Connections, vapeEvents.AttributeChanged.Event:Connect(function(changed)
					if changed:find("Shield") or changed:find("Health") or changed:find("speed") then 
						AutoConsumeFunc()
					end
				end))
				AutoConsumeFunc()
			end
		end,
		HoverText = "Automatically heals for you when health or shield is under threshold."
	})
	AutoConsumeHealth = AutoConsume.CreateSlider({
		Name = "Health",
		Min = 1,
		Max = 99,
		Default = 70,
		Function = function() end
	})
	AutoConsumeSpeed = AutoConsume.CreateToggle({
		Name = "Speed Potions",
		Function = function() end,
		Default = true
	})
end)

runFunction(function()
	local AutoHotbarList = {Hotbars = {}, CurrentlySelected = 1}
	local AutoHotbarMode = {Value = "Toggle"}
	local AutoHotbarClear = {Enabled = false}
	local AutoHotbar = {Enabled = false}
	local AutoHotbarActive = false

	local function getCustomItem(v2)
		local realitem = v2.itemType
		if realitem == "swords" then
			local sword = getSword()
			realitem = sword and sword.itemType or "wood_sword"
		elseif realitem == "pickaxes" then
			local pickaxe = getPickaxe()
			realitem = pickaxe and pickaxe.itemType or "wood_pickaxe"
		elseif realitem == "axes" then
			local axe = getAxe()
			realitem = axe and axe.itemType or "wood_axe"
		elseif realitem == "bows" then
			local bow = getBow()
			realitem = bow and bow.itemType or "wood_bow"
		elseif realitem == "wool" then
			realitem = getWool() or "wool_white"
		end
		return realitem
	end
	
	local function findItemInTable(tab, item)
		for i, v in pairs(tab) do
			if v and v.itemType then
				if item.itemType == getCustomItem(v) then
					return i
				end
			end
		end
		return nil
	end

	local function findinhotbar(item)
		for i,v in pairs(bedwarsStore.localInventory.hotbar) do
			if v.item and v.item.itemType == item.itemType then
				return i, v.item
			end
		end
	end

	local function findininventory(item)
		for i,v in pairs(bedwarsStore.localInventory.inventory.items) do
			if v.itemType == item.itemType then
				return v
			end
		end
	end

	local function AutoHotbarSort()
		task.spawn(function()
			if AutoHotbarActive then return end
			AutoHotbarActive = true
			local items = (AutoHotbarList.Hotbars[AutoHotbarList.CurrentlySelected] and AutoHotbarList.Hotbars[AutoHotbarList.CurrentlySelected].Items or {})
			for i, v in pairs(bedwarsStore.localInventory.inventory.items) do 
				local customItem
				local hotbarslot = findItemInTable(items, v)
				if hotbarslot then
					local oldhotbaritem = bedwarsStore.localInventory.hotbar[tonumber(hotbarslot)]
					if oldhotbaritem.item and oldhotbaritem.item.itemType == v.itemType then continue end
					if oldhotbaritem.item then 
						bedwars.ClientStoreHandler:dispatch({
							type = "InventoryRemoveFromHotbar", 
							slot = tonumber(hotbarslot) - 1
						})
						vapeEvents.InventoryChanged.Event:Wait()
					end
					local newhotbaritemslot, newhotbaritem = findinhotbar(v)
					if newhotbaritemslot then
						bedwars.ClientStoreHandler:dispatch({
							type = "InventoryRemoveFromHotbar", 
							slot = newhotbaritemslot - 1
						})
						vapeEvents.InventoryChanged.Event:Wait()
					end
					if oldhotbaritem.item and newhotbaritemslot then 
						local nextitem1, nextitem1num = findininventory(oldhotbaritem.item)
						bedwars.ClientStoreHandler:dispatch({
							type = "InventoryAddToHotbar", 
							item = nextitem1, 
							slot = newhotbaritemslot - 1
						})
						vapeEvents.InventoryChanged.Event:Wait()
					end
					local nextitem2, nextitem2num = findininventory(v)
					bedwars.ClientStoreHandler:dispatch({
						type = "InventoryAddToHotbar", 
						item = nextitem2, 
						slot = tonumber(hotbarslot) - 1
					})
					vapeEvents.InventoryChanged.Event:Wait()
				else
					if AutoHotbarClear.Enabled then 
						local newhotbaritemslot, newhotbaritem = findinhotbar(v)
						if newhotbaritemslot then
							bedwars.ClientStoreHandler:dispatch({
								type = "InventoryRemoveFromHotbar", 
								slot = newhotbaritemslot - 1
							})
							vapeEvents.InventoryChanged.Event:Wait()
						end
					end
				end
			end
			AutoHotbarActive = false
		end)
	end

	AutoHotbar = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "AutoHotbar",
		Function = function(callback) 
			if callback then
				AutoHotbarSort()
				if AutoHotbarMode.Value == "On Key" then
					if AutoHotbar.Enabled then 
						AutoHotbar.ToggleButton(false)
					end
				else
					table.insert(AutoHotbar.Connections, vapeEvents.InventoryAmountChanged.Event:Connect(function()
						if not AutoHotbar.Enabled then return end
						AutoHotbarSort()
					end))
				end
			end
		end,
		HoverText = "Automatically arranges hotbar to your liking."
	})
	AutoHotbarMode = AutoHotbar.CreateDropdown({
		Name = "Activation",
		List = {"On Key", "Toggle"},
		Function = function(val)
			if AutoHotbar.Enabled then
				AutoHotbar.ToggleButton(false)
				AutoHotbar.ToggleButton(false)
			end
		end
	})
	AutoHotbarList = CreateAutoHotbarGUI(AutoHotbar.Children, {
		Name = "lol"
	})
	AutoHotbarClear = AutoHotbar.CreateToggle({
		Name = "Clear Hotbar",
		Function = function() end
	})
end)

runFunction(function()
	local AutoKit = {Enabled = false}
	local AutoKitTrinity = {Value = "Void"}
	local oldfish
	local function GetTeammateThatNeedsMost()
		local plrs = GetAllNearestHumanoidToPosition(true, 30, 1000, true)
		local lowest, lowestplayer = 10000, nil
		for i,v in pairs(plrs) do
			if not v.Targetable then
				if v.Character:GetAttribute("Health") <= lowest and v.Character:GetAttribute("Health") < v.Character:GetAttribute("MaxHealth") then
					lowest = v.Character:GetAttribute("Health")
					lowestplayer = v
				end
			end
		end
		return lowestplayer
	end

	AutoKit = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "AutoKit",
		Function = function(callback)
			if callback then
				oldfish = bedwars.FishermanTable.startMinigame
				bedwars.FishermanTable.startMinigame = function(Self, dropdata, func) func({win = true}) end
				task.spawn(function()
					repeat task.wait() until bedwarsStore.equippedKit ~= ""
					if AutoKit.Enabled then
						if bedwarsStore.equippedKit == "melody" then
							task.spawn(function()
								repeat
									task.wait(0.1)
									if getItem("guitar") then
										local plr = GetTeammateThatNeedsMost()
										if plr and healtick <= tick() then
											bedwars.ClientHandler:Get(bedwars.GuitarHealRemote):SendToServer({
												healTarget = plr.Character
											})
											healtick = tick() + 2
										end
									end
								until (not AutoKit.Enabled)
							end)
						elseif bedwarsStore.equippedKit == "bigman" then
							task.spawn(function()
								repeat
									task.wait()
									local itemdrops = collectionService:GetTagged("treeOrb")
									for i,v in pairs(itemdrops) do
										if entityLibrary.isAlive and v:FindFirstChild("Spirit") and (entityLibrary.character.HumanoidRootPart.Position - v.Spirit.Position).magnitude <= 20 then
											if bedwars.ClientHandler:Get(bedwars.TreeRemote):CallServer({
												treeOrbSecret = v:GetAttribute("TreeOrbSecret")
											}) then
												v:Destroy()
												collectionService:RemoveTag(v, "treeOrb")
											end
										end
									end
								until (not AutoKit.Enabled)
							end)
						elseif bedwarsStore.equippedKit == "metal_detector" then
							task.spawn(function()
								repeat
									task.wait()
									local itemdrops = collectionService:GetTagged("hidden-metal")
									for i,v in pairs(itemdrops) do
										if entityLibrary.isAlive and v.PrimaryPart and (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude <= 20 then
											bedwars.ClientHandler:Get(bedwars.PickupMetalRemote):SendToServer({
												id = v:GetAttribute("Id")
											}) 
										end
									end
								until (not AutoKit.Enabled)
							end)
						elseif bedwarsStore.equippedKit == "battery" then 
							task.spawn(function()
								repeat
									task.wait()
									local itemdrops = bedwars.BatteryEffectController.liveBatteries
									for i,v in pairs(itemdrops) do
										if entityLibrary.isAlive and (entityLibrary.character.HumanoidRootPart.Position - v.position).magnitude <= 10 then
											bedwars.ClientHandler:Get(bedwars.BatteryRemote):SendToServer({
												batteryId = i
											})
										end
									end
								until (not AutoKit.Enabled)
							end)
						elseif bedwarsStore.equippedKit == "grim_reaper" then
							task.spawn(function()
								repeat
									task.wait()
									local itemdrops = bedwars.GrimReaperController.soulsByPosition
									for i,v in pairs(itemdrops) do
										if entityLibrary.isAlive and lplr.Character:GetAttribute("Health") <= (lplr.Character:GetAttribute("MaxHealth") / 4) and v.PrimaryPart and (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude <= 120 and (not lplr.Character:GetAttribute("GrimReaperChannel")) then
											bedwars.ClientHandler:Get(bedwars.ConsumeSoulRemote):CallServer({
												secret = v:GetAttribute("GrimReaperSoulSecret")
											})
											v:Destroy()
										end
									end
								until (not AutoKit.Enabled)
							end)
						elseif bedwarsStore.equippedKit == "farmer_cletus" then 
							task.spawn(function()
								repeat
									task.wait()
									local itemdrops = collectionService:GetTagged("BedwarsHarvestableCrop")
									for i,v in pairs(itemdrops) do
										if entityLibrary.isAlive and (entityLibrary.character.HumanoidRootPart.Position - v.Position).magnitude <= 10 then
											bedwars.ClientHandler:Get("BedwarsHarvestCrop"):CallServerAsync({
												position = bedwars.BlockController:getBlockPosition(v.Position)
											}):andThen(function(suc)
												if suc then
													bedwars.GameAnimationUtil.playAnimation(lplr.Character, 1)
													bedwars.SoundManager:playSound(bedwars.SoundList.CROP_HARVEST)
												end
											end)
										end
									end
								until (not AutoKit.Enabled)
							end)
						elseif bedwarsStore.equippedKit == "dragon_slayer" then
							task.spawn(function()
								repeat
									task.wait(0.1)
									if entityLibrary.isAlive then
										for i,v in pairs(bedwars.DragonSlayerController.dragonEmblems) do 
											if v.stackCount >= 3 then 
												bedwars.DragonSlayerController:deleteEmblem(i)
												local localPos = lplr.Character:GetPrimaryPartCFrame().Position
												local punchCFrame = CFrame.new(localPos, (i:GetPrimaryPartCFrame().Position * Vector3.new(1, 0, 1)) + Vector3.new(0, localPos.Y, 0))
												lplr.Character:SetPrimaryPartCFrame(punchCFrame)
												bedwars.DragonSlayerController:playPunchAnimation(punchCFrame - punchCFrame.Position)
												bedwars.ClientHandler:Get(bedwars.DragonRemote):SendToServer({
													target = i
												})
											end
										end
									end
								until (not AutoKit.Enabled)
							end)
						elseif bedwarsStore.equippedKit == "mage" then
							task.spawn(function()
								repeat
									task.wait(0.1)
									if entityLibrary.isAlive then
										for i, v in pairs(collectionService:GetTagged("TomeGuidingBeam")) do 
											local obj = v.Parent and v.Parent.Parent and v.Parent.Parent.Parent
											if obj and (entityLibrary.character.HumanoidRootPart.Position - obj.PrimaryPart.Position).Magnitude < 5 and obj:GetAttribute("TomeSecret") then
												local res = bedwars.ClientHandler:Get(bedwars.MageRemote):CallServer({
													secret = obj:GetAttribute("TomeSecret")
												})
												if res.success and res.element then 
													bedwars.GameAnimationUtil.playAnimation(lplr, bedwars.AnimationType.PUNCH)
													bedwars.ViewmodelController:playAnimation(bedwars.AnimationType.FP_USE_ITEM)
													bedwars.MageController:destroyTomeGuidingBeam()
													bedwars.MageController:playLearnLightBeamEffect(lplr, obj)
													local sound = bedwars.MageKitUtil.MageElementVisualizations[res.element].learnSound
													if sound and sound ~= "" then 
														bedwars.SoundManager:playSound(sound)
													end
													task.delay(bedwars.BalanceFile.LEARN_TOME_DURATION, function()
														bedwars.MageController:fadeOutTome(obj)
														if lplr.Character and res.element then
															bedwars.MageKitUtil.changeMageKitAppearance(lplr, lplr.Character, res.element)	
														end
													end)
												end
											end
										end
									end
								until (not AutoKit.Enabled)
							end)
						elseif bedwarsStore.equippedKit == "angel" then 
							table.insert(AutoKit.Connections, vapeEvents.AngelProgress.Event:Connect(function(angelTable)
								task.wait(0.5)
								if not AutoKit.Enabled then return end
								if bedwars.ClientStoreHandler:getState().Kit.angelProgress >= 1 and lplr.Character:GetAttribute("AngelType") == nil then
									bedwars.ClientHandler:Get(bedwars.TrinityRemote):SendToServer({
										angel = AutoKitTrinity.Value
									})
								end
							end))
						elseif bedwarsStore.equippedKit == "miner" then
							task.spawn(function()
								repeat
									task.wait(0.1)
									if entityLibrary.isAlive then
										for i,v in pairs(collectionService:GetTagged("petrified-player")) do 
											bedwars.ClientHandler:Get(bedwars.MinerRemote):SendToServer({
												petrifyId = v:GetAttribute("PetrifyId")
											})
										end
									end
								until (not AutoKit.Enabled)
							end)
						end
					end
				end)
			else
				bedwars.FishermanTable.startMinigame = oldfish
				oldfish = nil
			end
		end,
		HoverText = "Automatically uses a kits ability"
	})
	AutoKitTrinity = AutoKit.CreateDropdown({
		Name = "Angel",
		List = {"Void", "Light"},
		Function = function() end
	})
end)

runFunction(function()
	local AutoRelicCustom = {ObjectList = {}}

	local function findgoodmeta(relics)
		local tab = #AutoRelicCustom.ObjectList > 0 and AutoRelicCustom.ObjectList or {
			"embers_anguish",
			"knights_code",
			"quick_forge",
			"glass_cannon"
		}
		for i,v in pairs(relics) do 
			for i2,v2 in pairs(tab) do 
				if v.relic == v2 then
					return v.relic
				end
			end
		end
		return relics[1].relic
	end

	local AutoRelic = {Enabled = false}
	AutoRelic = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "AutoRelic",
		Function = function(callback)
			if callback then 
				task.spawn(function()
					repeat
						task.wait()
						if bedwars.AppController:isAppOpen("RelicVotingInterface") then 
							bedwars.AppController:closeApp("RelicVotingInterface")
							local relictable = bedwars.ClientStoreHandler:getState().Bedwars.relic.voteState
							if relictable then 
								bedwars.RelicController:voteForRelic(findgoodmeta(relictable))
							end
							break
						end
						if matchState ~= 0 then break end
					until (not AutoRelic.Enabled)
				end)
			end
		end
	})
	AutoRelicCustom = AutoRelic.CreateTextList({
		Name = "Custom",
		TempText = "custom (relic id)"
	})
end)

runFunction(function()
	local AutoForge = {Enabled = false}
	local AutoForgeWeapon = {Value = "Sword"}
	local AutoForgeBow = {Enabled = false}
	local AutoForgeArmor = {Enabled = false}
	local AutoForgeSword = {Enabled = false}
	local AutoForgeBuyAfter = {Enabled = false}
	local AutoForgeNotification = {Enabled = true}

	local function buyForge(i)
		if not bedwarsStore.forgeUpgrades[i] or bedwarsStore.forgeUpgrades[i] < 6 then
			local cost = bedwars.ForgeUtil:getUpgradeCost(1, bedwarsStore.forgeUpgrades[i] or 0)
			if bedwarsStore.forgeMasteryPoints >= cost then 
				if AutoForgeNotification.Enabled then
					local forgeType = "none"
					for name,v in pairs(bedwars.ForgeConstants) do
						if v == i then forgeType = name:lower() end
					end
					warningNotification("AutoForge", "Purchasing "..forgeType..".", bedwars.ForgeUtil.FORGE_DURATION_SEC)
				end
				bedwars.ClientHandler:Get("ForgePurchaseUpgrade"):SendToServer(i)
				task.wait(bedwars.ForgeUtil.FORGE_DURATION_SEC + 0.2)
			end
		end
	end

	AutoForge = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "AutoForge",
		Function = function(callback)
			if callback then 
				task.spawn(function()
					repeat
						task.wait()
						if bedwarsStore.matchState == 1 and entityLibrary.isAlive then
							if entityLibrary.character.HumanoidRootPart.Velocity.Magnitude > 0.01 then continue end
							if AutoForgeArmor.Enabled then buyForge(bedwars.ForgeConstants.ARMOR) end
							if entityLibrary.character.HumanoidRootPart.Velocity.Magnitude > 0.01 then continue end
							if AutoForgeBow.Enabled then buyForge(bedwars.ForgeConstants.RANGED) end
							if entityLibrary.character.HumanoidRootPart.Velocity.Magnitude > 0.01 then continue end
							if AutoForgeSword.Enabled then
								if AutoForgeBuyAfter.Enabled then
									if not bedwarsStore.forgeUpgrades[bedwars.ForgeConstants.ARMOR] or bedwarsStore.forgeUpgrades[bedwars.ForgeConstants.ARMOR] < 6 then continue end
								end
								local weapon = bedwars.ForgeConstants[AutoForgeWeapon.Value:upper()]
								if weapon then buyForge(weapon) end
							end
						end
					until (not AutoForge.Enabled)
				end)
			end
		end
	})
	AutoForgeWeapon = AutoForge.CreateDropdown({
		Name = "Weapon",
		Function = function() end,
		List = {"Sword", "Dagger", "Scythe", "Great_Hammer"}
	})
	AutoForgeArmor = AutoForge.CreateToggle({
		Name = "Armor",
		Function = function() end,
		Default = true
	})
	AutoForgeSword = AutoForge.CreateToggle({
		Name = "Weapon",
		Function = function() end
	})
	AutoForgeBow = AutoForge.CreateToggle({
		Name = "Bow",
		Function = function() end
	})
	AutoForgeBuyAfter = AutoForge.CreateToggle({
		Name = "Buy After",
		Function = function() end,
		HoverText = "buy a weapon after armor is maxed"
	})
	AutoForgeNotification = AutoForge.CreateToggle({
		Name = "Notification",
		Function = function() end,
		Default = true
	})
end)

runFunction(function()
	local alreadyreportedlist = {}
	local AutoReportV2 = {Enabled = false}
	local AutoReportV2Notify = {Enabled = false}
	AutoReportV2 = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "AutoReportV2",
		Function = function(callback)
			if callback then 
				task.spawn(function()
					repeat
						task.wait()
						for i,v in pairs(playersService:GetPlayers()) do 
							if v ~= lplr and alreadyreportedlist[v] == nil and v:GetAttribute("PlayerConnected") and WhitelistFunctions:GetWhitelist(v) == 0 then 
								task.wait(1)
								alreadyreportedlist[v] = true
								bedwars.ClientHandler:Get(bedwars.ReportRemote):SendToServer(v.UserId)
								bedwarsStore.statistics.reported = bedwarsStore.statistics.reported + 1
								if AutoReportV2Notify.Enabled then 
									warningNotification("AutoReportV2", "Reported "..v.Name, 15)
								end
							end
						end
					until (not AutoReportV2.Enabled)
				end)
			end	
		end,
		HoverText = "dv mald"
	})
	AutoReportV2Notify = AutoReportV2.CreateToggle({
		Name = "Notify",
		Function = function() end
	})
end)

runFunction(function()
	local justsaid = ""
	local leavesaid = false
	local alreadyreported = {}

	local function removerepeat(str)
		local newstr = ""
		local lastlet = ""
		for i,v in pairs(str:split("")) do 
			if v ~= lastlet then
				newstr = newstr..v 
				lastlet = v
			end
		end
		return newstr
	end

	local reporttable = {
		gay = "Bullying",
		gae = "Bullying",
		gey = "Bullying",
		hack = "Scamming",
		exploit = "Scamming",
		cheat = "Scamming",
		hecker = "Scamming",
		haxker = "Scamming",
		hacer = "Scamming",
		report = "Bullying",
		fat = "Bullying",
		black = "Bullying",
		getalife = "Bullying",
		fatherless = "Bullying",
		report = "Bullying",
		fatherless = "Bullying",
		disco = "Offsite Links",
		yt = "Offsite Links",
		dizcourde = "Offsite Links",
		retard = "Swearing",
		bad = "Bullying",
		trash = "Bullying",
		nolife = "Bullying",
		nolife = "Bullying",
		loser = "Bullying",
		killyour = "Bullying",
		kys = "Bullying",
		hacktowin = "Bullying",
		bozo = "Bullying",
		kid = "Bullying",
		adopted = "Bullying",
		linlife = "Bullying",
		commitnotalive = "Bullying",
		vape = "Offsite Links",
		futureclient = "Offsite Links",
		download = "Offsite Links",
		youtube = "Offsite Links",
		die = "Bullying",
		lobby = "Bullying",
		ban = "Bullying",
		wizard = "Bullying",
		wisard = "Bullying",
		witch = "Bullying",
		magic = "Bullying",
	}
	local reporttableexact = {
		L = "Bullying",
	}
	

	local function findreport(msg)
		local checkstr = removerepeat(msg:gsub("%W+", ""):lower())
		for i,v in pairs(reporttable) do 
			if checkstr:find(i) then 
				return v, i
			end
		end
		for i,v in pairs(reporttableexact) do 
			if checkstr == i then 
				return v, i
			end
		end
		for i,v in pairs(AutoToxicPhrases5.ObjectList) do 
			if checkstr:find(v) then 
				return "Bullying", v
			end
		end
		return nil
	end

	AutoToxic = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "AutoToxic",
		Function = function(callback)
			if callback then 
				table.insert(AutoToxic.Connections, vapeEvents.BedwarsBedBreak.Event:Connect(function(bedTable)
					if AutoToxicBedDestroyed.Enabled and bedTable.brokenBedTeam.id == lplr:GetAttribute("Team") then
						local custommsg = #AutoToxicPhrases6.ObjectList > 0 and AutoToxicPhrases6.ObjectList[math.random(1, #AutoToxicPhrases6.ObjectList)] or "How dare you break my bed >:( <name> | vxpe on top"
						if custommsg then
							custommsg = custommsg:gsub("<name>", (bedTable.player.DisplayName or bedTable.player.Name))
						end
						textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(custommsg)
					elseif AutoToxicBedBreak.Enabled and bedTable.player.UserId == lplr.UserId then
						local custommsg = #AutoToxicPhrases7.ObjectList > 0 and AutoToxicPhrases7.ObjectList[math.random(1, #AutoToxicPhrases7.ObjectList)] or "nice bed <teamname> | vxpe on top"
						if custommsg then
							local team = bedwars.QueueMeta[bedwarsStore.queueType].teams[tonumber(bedTable.brokenBedTeam.id)]
							local teamname = team and team.displayName:lower() or "white"
							custommsg = custommsg:gsub("<teamname>", teamname)
						end
						textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(custommsg)
					end
				end))
				table.insert(AutoToxic.Connections, vapeEvents.EntityDeathEvent.Event:Connect(function(deathTable)
					if deathTable.finalKill then
						local killer = playersService:GetPlayerFromCharacter(deathTable.fromEntity)
						local killed = playersService:GetPlayerFromCharacter(deathTable.entityInstance)
						if not killed or not killer then return end
						if killed == lplr then 
							if (not leavesaid) and killer ~= lplr and AutoToxicDeath.Enabled then
								leavesaid = true
								local custommsg = #AutoToxicPhrases3.ObjectList > 0 and AutoToxicPhrases3.ObjectList[math.random(1, #AutoToxicPhrases3.ObjectList)] or "My gaming chair expired midfight, thats why you won <name> | vxpe on top"
								if custommsg then
									custommsg = custommsg:gsub("<name>", (killer.DisplayName or killer.Name))
								end
								textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(custommsg)
							end
						else
							if killer == lplr and AutoToxicFinalKill.Enabled then 
								local custommsg = #AutoToxicPhrases2.ObjectList > 0 and AutoToxicPhrases2.ObjectList[math.random(1, #AutoToxicPhrases2.ObjectList)] or "L <name> | vxpe on top"
								if custommsg == lastsaid then
									custommsg = #AutoToxicPhrases2.ObjectList > 0 and AutoToxicPhrases2.ObjectList[math.random(1, #AutoToxicPhrases2.ObjectList)] or "L <name> | vxpe on top"
								else
									lastsaid = custommsg
								end
								if custommsg then
									custommsg = custommsg:gsub("<name>", (killed.DisplayName or killed.Name))
								end
								textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(custommsg)
							end
						end
					end
				end))
				table.insert(AutoToxic.Connections, vapeEvents.MatchEndEvent.Event:Connect(function(winstuff)
					local myTeam = bedwars.ClientStoreHandler:getState().Game.myTeam
					if myTeam and myTeam.id == winstuff.winningTeamId or lplr.Neutral then
						if AutoToxicGG.Enabled then
							textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync("gg")
							if shared.ggfunction then
								shared.ggfunction()
							end
						end
						if AutoToxicWin.Enabled then
							textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(#AutoToxicPhrases.ObjectList > 0 and AutoToxicPhrases.ObjectList[math.random(1, #AutoToxicPhrases.ObjectList)] or "EZ L TRASH KIDS | vxpe on top")
						end
					end
				end))
				table.insert(AutoToxic.Connections, vapeEvents.LagbackEvent.Event:Connect(function(plr)
					if AutoToxicLagback.Enabled then
						local custommsg = #AutoToxicPhrases8.ObjectList > 0 and AutoToxicPhrases8.ObjectList[math.random(1, #AutoToxicPhrases8.ObjectList)]
						if custommsg then
							custommsg = custommsg:gsub("<name>", (plr.DisplayName or plr.Name))
						end
						local msg = custommsg or "Imagine lagbacking L "..(plr.DisplayName or plr.Name).." | vxpe on top"
						textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(msg)
					end
				end))
				table.insert(AutoToxic.Connections, textChatService.MessageReceived:Connect(function(tab)
					if AutoToxicRespond.Enabled then
						local plr = playersService:GetPlayerByUserId(tab.TextSource.UserId)
						local args = tab.Text:split(" ")
						if plr and plr ~= lplr and not alreadyreported[plr] then
							local reportreason, reportedmatch = findreport(tab.Text)
							if reportreason then 
								alreadyreported[plr] = true
								local custommsg = #AutoToxicPhrases4.ObjectList > 0 and AutoToxicPhrases4.ObjectList[math.random(1, #AutoToxicPhrases4.ObjectList)]
								if custommsg then
									custommsg = custommsg:gsub("<name>", (plr.DisplayName or plr.Name))
								end
								local msg = custommsg or "I don't care about the fact that I'm hacking, I care about you dying in a block game. L "..(plr.DisplayName or plr.Name).." | vxpe on top"
								textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(msg)
							end
						end
					end
				end))
			end
		end
	})
	AutoToxicGG = AutoToxic.CreateToggle({
		Name = "AutoGG",
		Function = function() end, 
		Default = true
	})
	AutoToxicWin = AutoToxic.CreateToggle({
		Name = "Win",
		Function = function() end, 
		Default = true
	})
	AutoToxicDeath = AutoToxic.CreateToggle({
		Name = "Death",
		Function = function() end, 
		Default = true
	})
	AutoToxicBedBreak = AutoToxic.CreateToggle({
		Name = "Bed Break",
		Function = function() end, 
		Default = true
	})
	AutoToxicBedDestroyed = AutoToxic.CreateToggle({
		Name = "Bed Destroyed",
		Function = function() end, 
		Default = true
	})
	AutoToxicRespond = AutoToxic.CreateToggle({
		Name = "Respond",
		Function = function() end, 
		Default = true
	})
	AutoToxicFinalKill = AutoToxic.CreateToggle({
		Name = "Final Kill",
		Function = function() end, 
		Default = true
	})
	AutoToxicTeam = AutoToxic.CreateToggle({
		Name = "Teammates",
		Function = function() end, 
	})
	AutoToxicLagback = AutoToxic.CreateToggle({
		Name = "Lagback",
		Function = function() end, 
		Default = true
	})
	AutoToxicPhrases = AutoToxic.CreateTextList({
		Name = "ToxicList",
		TempText = "phrase (win)",
	})
	AutoToxicPhrases2 = AutoToxic.CreateTextList({
		Name = "ToxicList2",
		TempText = "phrase (kill) <name>",
	})
	AutoToxicPhrases3 = AutoToxic.CreateTextList({
		Name = "ToxicList3",
		TempText = "phrase (death) <name>",
	})
	AutoToxicPhrases7 = AutoToxic.CreateTextList({
		Name = "ToxicList7",
		TempText = "phrase (bed break) <teamname>",
	})
	AutoToxicPhrases7.Object.AddBoxBKG.AddBox.TextSize = 12
	AutoToxicPhrases6 = AutoToxic.CreateTextList({
		Name = "ToxicList6",
		TempText = "phrase (bed destroyed) <name>",
	})
	AutoToxicPhrases6.Object.AddBoxBKG.AddBox.TextSize = 12
	AutoToxicPhrases4 = AutoToxic.CreateTextList({
		Name = "ToxicList4",
		TempText = "phrase (text to respond with) <name>",
	})
	AutoToxicPhrases4.Object.AddBoxBKG.AddBox.TextSize = 12
	AutoToxicPhrases5 = AutoToxic.CreateTextList({
		Name = "ToxicList5",
		TempText = "phrase (text to respond to)",
	})
	AutoToxicPhrases5.Object.AddBoxBKG.AddBox.TextSize = 12
	AutoToxicPhrases8 = AutoToxic.CreateTextList({
		Name = "ToxicList8",
		TempText = "phrase (lagback) <name>",
	})
	AutoToxicPhrases8.Object.AddBoxBKG.AddBox.TextSize = 12
end)

runFunction(function()
	local ChestStealer = {Enabled = false}
	local ChestStealerDistance = {Value = 1}
	local ChestStealerDelay = {Value = 1}
	local ChestStealerOpen = {Enabled = false}
	local ChestStealerSkywars = {Enabled = true}
	local cheststealerdelays = {}
	local cheststealerfuncs = {
		Open = function()
			if bedwars.AppController:isAppOpen("ChestApp") then
				local chest = lplr.Character:FindFirstChild("ObservedChestFolder")
				local chestitems = chest and chest.Value and chest.Value:GetChildren() or {}
				if #chestitems > 0 then
					for i3,v3 in pairs(chestitems) do
						if v3:IsA("Accessory") and (cheststealerdelays[v3] == nil or cheststealerdelays[v3] < tick()) then
							task.spawn(function()
								pcall(function()
									cheststealerdelays[v3] = tick() + 0.2
									bedwars.ClientHandler:GetNamespace("Inventory"):Get("ChestGetItem"):CallServer(chest.Value, v3)
								end)
							end)
							task.wait(ChestStealerDelay.Value / 100)
						end
					end
				end
			end
		end,
		Closed = function()
			for i, v in pairs(collectionService:GetTagged("chest")) do
				if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - v.Position).magnitude <= ChestStealerDistance.Value then
					local chest = v:FindFirstChild("ChestFolderValue")
					chest = chest and chest.Value or nil
					local chestitems = chest and chest:GetChildren() or {}
					if #chestitems > 0 then
						bedwars.ClientHandler:GetNamespace("Inventory"):Get("SetObservedChest"):SendToServer(chest)
						for i3,v3 in pairs(chestitems) do
							if v3:IsA("Accessory") then
								task.spawn(function()
									pcall(function()
										bedwars.ClientHandler:GetNamespace("Inventory"):Get("ChestGetItem"):CallServer(v.ChestFolderValue.Value, v3)
									end)
								end)
								task.wait(ChestStealerDelay.Value / 100)
							end
						end
						bedwars.ClientHandler:GetNamespace("Inventory"):Get("SetObservedChest"):SendToServer(nil)
					end
				end
			end
		end
	}

	ChestStealer = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "ChestStealer",
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat task.wait() until bedwarsStore.queueType ~= "bedwars_test"
					if (not ChestStealerSkywars.Enabled) or bedwarsStore.queueType:find("skywars") then
						repeat 
							task.wait(0.1)
							if entityLibrary.isAlive then
								cheststealerfuncs[ChestStealerOpen.Enabled and "Open" or "Closed"]()
							end
						until (not ChestStealer.Enabled)
					end
				end)
			end
		end,
		HoverText = "Grabs items from near chests."
	})
	ChestStealerDistance = ChestStealer.CreateSlider({
		Name = "Range",
		Min = 0,
		Max = 18,
		Function = function() end,
		Default = 18
	})
	ChestStealerDelay = ChestStealer.CreateSlider({
		Name = "Delay",
		Min = 1,
		Max = 50,
		Function = function() end,
		Default = 1,
		Double = 100
	})
	ChestStealerOpen = ChestStealer.CreateToggle({
		Name = "GUI Check",
		Function = function() end
	})
	ChestStealerSkywars = ChestStealer.CreateToggle({
		Name = "Only Skywars",
		Function = function() end,
		Default = true
	})
end)

runFunction(function()
	local FastDrop = {Enabled = false}
	FastDrop = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "FastDrop",
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat
						task.wait()
						if entityLibrary.isAlive and (not bedwarsStore.localInventory.opened) and (inputService:IsKeyDown(Enum.KeyCode.Q) or inputService:IsKeyDown(Enum.KeyCode.Backspace)) and inputService:GetFocusedTextBox() == nil then
							task.spawn(bedwars.DropItem)
						end
					until (not FastDrop.Enabled)
				end)
			end
		end,
		HoverText = "Drops items fast when you hold Q"
	})
end)

local denyregions = {}
runFunction(function()
	local ignoreplaceregions = {Enabled = false}
	ignoreplaceregions = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "IgnorePlaceRegions",
		Function = function(callback)
			if callback then
				denyregions = bedwars.MapController.denyRegions
				task.spawn(function()
					repeat
						bedwars.MapController.denyRegions = {}
						task.wait()
					until (not ignoreplaceregions.Enabled)
				end)
			else 
				bedwars.MapController.denyRegions = denyregions
			end
		end
	})
end)

runFunction(function()
	local MissileTP = {Enabled = false}
	local MissileTeleportDelaySlider = {Value = 30}
	MissileTP = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "MissileTP",
		Function = function(callback)
			if callback then
				task.spawn(function()
					if getItem("guided_missile") then
						local plr = EntityNearMouse(1000)
						if plr then
							local projectile = bedwars.RuntimeLib.await(bedwars.MissileController.fireGuidedProjectile:CallServerAsync("guided_missile"))
							if projectile then
								local projectilemodel = projectile.model
								if not projectilemodel.PrimaryPart then
									projectilemodel:GetPropertyChangedSignal("PrimaryPart"):Wait()
								end;
								local bodyforce = Instance.new("BodyForce")
								bodyforce.Force = Vector3.new(0, projectilemodel.PrimaryPart.AssemblyMass * workspace.Gravity, 0)
								bodyforce.Name = "AntiGravity"
								bodyforce.Parent = projectilemodel.PrimaryPart

								repeat
									task.wait()
									if projectile.model then
										if plr then
											projectile.model:SetPrimaryPartCFrame(CFrame.new(plr.RootPart.CFrame.p, plr.RootPart.CFrame.p + gameCamera.CFrame.lookVector))
										else
											warningNotification("MissileTP", "Player died before it could TP.", 3)
											break
										end
									end
								until projectile.model.Parent == nil
							else
								warningNotification("MissileTP", "Missile on cooldown.", 3)
							end
						else
							warningNotification("MissileTP", "Player not found.", 3)
						end
					else
						warningNotification("MissileTP", "Missile not found.", 3)
					end
				end)
				MissileTP.ToggleButton(true)
			end
		end,
		HoverText = "Spawns and teleports a missile to a player\nnear your mouse."
	})
end)

runFunction(function()
	local OpenEnderchest = {Enabled = false}
	OpenEnderchest = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "OpenEnderchest",
		Function = function(callback)
			if callback then
				local echest = replicatedStorageService.Inventories:FindFirstChild(lplr.Name.."_personal")
				if echest then
					bedwars.AppController:openApp("ChestApp", {})
					bedwars.ChestController:openChest(echest)
				else
					warningNotification("OpenEnderchest", "Enderchest not found", 5)
				end
				OpenEnderchest.ToggleButton(false)
			end
		end,
		HoverText = "Opens the enderchest"
	})
end)

runFunction(function()
	local PickupRangeRange = {Value = 1}
	local PickupRange = {Enabled = false}
	PickupRange = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "PickupRange", 
		Function = function(callback)
			if callback then
				local pickedup = {}
				task.spawn(function()
					repeat
						local itemdrops = collectionService:GetTagged("ItemDrop")
						for i,v in pairs(itemdrops) do
							if entityLibrary.isAlive and (v:GetAttribute("ClientDropTime") and tick() - v:GetAttribute("ClientDropTime") > 2 or v:GetAttribute("ClientDropTime") == nil) then
								if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - v.Position).magnitude <= PickupRangeRange.Value and (pickedup[v] == nil or pickedup[v] <= tick()) then
									task.spawn(function()
										pickedup[v] = tick() + 0.2
										bedwars.ClientHandler:Get(bedwars.PickupRemote):CallServerAsync({
											itemDrop = v
										}):andThen(function(suc)
											if suc then
												bedwars.SoundManager:playSound(bedwars.SoundList.PICKUP_ITEM_DROP)
											end
										end)
									end)
								end
							end
						end
						task.wait()
					until (not PickupRange.Enabled)
				end)
			end
		end
	})
	PickupRangeRange = PickupRange.CreateSlider({
		Name = "Range",
		Min = 1,
		Max = 10, 
		Function = function() end,
		Default = 10
	})
end)

runFunction(function()
	local BowExploit = {Enabled = false}
	local BowExploitTarget = {Value = "Mouse"}
	local BowExploitAutoShootFOV = {Value = 1000}
	local oldrealremote
	local noveloproj = {
		"fireball",
		"telepearl"
	}

	BowExploit = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "ProjectileExploit",
		Function = function(callback)
			if callback then 
				oldrealremote = bedwars.ClientConstructor.Function.new
				bedwars.ClientConstructor.Function.new = function(self, ind, ...)
					local res = oldrealremote(self, ind, ...)
					local oldRemote = res.instance
					if oldRemote and oldRemote.Name == bedwars.ProjectileRemote then 
						res.instance = {InvokeServer = function(self, shooting, proj, proj2, launchpos1, launchpos2, launchvelo, tag, tab1, ...) 
							local plr
							if BowExploitTarget.Value == "Mouse" then 
								plr = EntityNearMouse(10000)
							else
								plr = EntityNearPosition(BowExploitAutoShootFOV.Value, true)
							end
							if plr then	
								if not ({WhitelistFunctions:GetWhitelist(plr.Player)})[2] then 
									return oldRemote:InvokeServer(shooting, proj, proj2, launchpos1, launchpos2, launchvelo, tag, tab1, ...)
								end
		
								tab1.drawDurationSeconds = 1
								repeat
									task.wait(0.03)
									local offsetStartPos = plr.RootPart.CFrame.p - plr.RootPart.CFrame.lookVector
									local pos = plr.RootPart.Position
									local playergrav = workspace.Gravity
									local balloons = plr.Character:GetAttribute("InflatedBalloons")
									if balloons and balloons > 0 then 
										playergrav = (workspace.Gravity * (1 - ((balloons >= 4 and 1.2 or balloons >= 3 and 1 or 0.975))))
									end
									if plr.Character.PrimaryPart:FindFirstChild("rbxassetid://8200754399") then 
										playergrav = (workspace.Gravity * 0.3)
									end
									local newLaunchVelo = bedwars.ProjectileMeta[proj2].launchVelocity
									local shootpos, shootvelo = predictGravity(pos, plr.RootPart.Velocity, (pos - offsetStartPos).Magnitude / newLaunchVelo, plr, playergrav)
									if proj2 == "telepearl" then
										shootpos = pos
										shootvelo = Vector3.zero
									end
									local newlook = CFrame.new(offsetStartPos, shootpos) * CFrame.new(Vector3.new(-bedwars.BowConstantsTable.RelX, -bedwars.BowConstantsTable.RelY, -bedwars.BowConstantsTable.RelZ))
									shootpos = newlook.p + (newlook.lookVector * (offsetStartPos - shootpos).magnitude)
									local calculated = LaunchDirection(offsetStartPos, shootpos, newLaunchVelo, workspace.Gravity, false)
									if calculated then 
										launchvelo = calculated
										launchpos1 = offsetStartPos
										launchpos2 = offsetStartPos
										tab1.drawDurationSeconds = 1
									else
										break
									end
									if oldRemote:InvokeServer(shooting, proj, proj2, launchpos1, launchpos2, launchvelo, tag, tab1, workspace:GetServerTimeNow() - 0.045) then break end
								until false
							else
								return oldRemote:InvokeServer(shooting, proj, proj2, launchpos1, launchpos2, launchvelo, tag, tab1, ...)
							end
						end}
					end
					return res
				end
			else
				bedwars.ClientConstructor.Function.new = oldrealremote
				oldrealremote = nil
			end
		end
	})
	BowExploitTarget = BowExploit.CreateDropdown({
		Name = "Mode",
		List = {"Mouse", "Range"},
		Function = function() end
	})
	BowExploitAutoShootFOV = BowExploit.CreateSlider({
		Name = "FOV",
		Function = function() end,
		Min = 1,
		Max = 1000,
		Default = 1000
	})
end)

runFunction(function()
	local RavenTP = {Enabled = false}
	RavenTP = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "RavenTP",
		Function = function(callback)
			if callback then
				task.spawn(function()
					if getItem("raven") then
						local plr = EntityNearMouse(1000)
						if plr then
							local projectile = bedwars.ClientHandler:Get(bedwars.SpawnRavenRemote):CallServerAsync():andThen(function(projectile)
								if projectile then
									local projectilemodel = projectile
									if not projectilemodel then
										projectilemodel:GetPropertyChangedSignal("PrimaryPart"):Wait()
									end
									local bodyforce = Instance.new("BodyForce")
									bodyforce.Force = Vector3.new(0, projectilemodel.PrimaryPart.AssemblyMass * workspace.Gravity, 0)
									bodyforce.Name = "AntiGravity"
									bodyforce.Parent = projectilemodel.PrimaryPart
	
									if plr then
										projectilemodel:SetPrimaryPartCFrame(CFrame.new(plr.RootPart.CFrame.p, plr.RootPart.CFrame.p + gameCamera.CFrame.lookVector))
										task.wait(0.3)
										bedwars.RavenTable:detonateRaven()
									else
										warningNotification("RavenTP", "Player died before it could TP.", 3)
									end
								else
									warningNotification("RavenTP", "Raven on cooldown.", 3)
								end
							end)
						else
							warningNotification("RavenTP", "Player not found.", 3)
						end
					else
						warningNotification("RavenTP", "Raven not found.", 3)
					end
				end)
				RavenTP.ToggleButton(true)
			end
		end,
		HoverText = "Spawns and teleports a raven to a player\nnear your mouse."
	})
end)

runFunction(function()
	local tiered = {}
	local nexttier = {}

	for i,v in pairs(bedwars.ShopItems) do
		if type(v) == "table" then 
			if v.tiered then
				tiered[v.itemType] = v.tiered
			end
			if v.nextTier then
				nexttier[v.itemType] = v.nextTier
			end
		end
	end

	GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "ShopTierBypass",
		Function = function(callback) 
			if callback then
				for i,v in pairs(bedwars.ShopItems) do
					if type(v) == "table" then 
						v.tiered = nil
						v.nextTier = nil
					end
				end
			else
				for i,v in pairs(bedwars.ShopItems) do
					if type(v) == "table" then 
						if tiered[v.itemType] then
							v.tiered = tiered[v.itemType]
						end
						if nexttier[v.itemType] then
							v.nextTier = nexttier[v.itemType]
						end
					end
				end
			end
		end,
		HoverText = "Allows you to access tiered items early."
	})
end)

local lagbackedaftertouch = false
runFunction(function()
	local AntiVoidPart
	local AntiVoidConnection
	local AntiVoidMode = {Value = "Normal"}
	local AntiVoidMoveMode = {Value = "Normal"}
	local AntiVoid = {Enabled = false}
	local AntiVoidTransparent = {Value = 50}
	local AntiVoidColor = {Hue = 1, Sat = 1, Value = 0.55}
	local lastvalidpos

	local function closestpos(block)
		local startpos = block.Position - (block.Size / 2) + Vector3.new(1.5, 1.5, 1.5)
		local endpos = block.Position + (block.Size / 2) - Vector3.new(1.5, 1.5, 1.5)
		local newpos = block.Position + (entityLibrary.character.HumanoidRootPart.Position - block.Position)
		return Vector3.new(math.clamp(newpos.X, startpos.X, endpos.X), endpos.Y + 3, math.clamp(newpos.Z, startpos.Z, endpos.Z))
	end

	local function getclosesttop(newmag)
		local closest, closestmag = nil, newmag * 3
		if entityLibrary.isAlive then 
			local tops = {}
			for i,v in pairs(bedwarsStore.blocks) do 
				local close = getScaffold(closestpos(v), false)
				if getPlacedBlock(close) then continue end
				if close.Y < entityLibrary.character.HumanoidRootPart.Position.Y then continue end
				if (close - entityLibrary.character.HumanoidRootPart.Position).magnitude <= newmag * 3 then 
					table.insert(tops, close)
				end
			end
			for i,v in pairs(tops) do 
				local mag = (v - entityLibrary.character.HumanoidRootPart.Position).magnitude
				if mag <= closestmag then 
					closest = v
					closestmag = mag
				end
			end
		end
		return closest
	end

	local antivoidypos = 0
	local antivoiding = false
	AntiVoid = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = "AntiVoid", 
		Function = function(callback)
			if callback then
				task.spawn(function()
					AntiVoidPart = Instance.new("Part")
					AntiVoidPart.CanCollide = AntiVoidMode.Value == "Collide"
					AntiVoidPart.Size = Vector3.new(10000, 1, 10000)
					AntiVoidPart.Anchored = true
					AntiVoidPart.Material = Enum.Material.Neon
					AntiVoidPart.Color = Color3.fromHSV(AntiVoidColor.Hue, AntiVoidColor.Sat, AntiVoidColor.Value)
					AntiVoidPart.Transparency = 1 - (AntiVoidTransparent.Value / 100)
					AntiVoidPart.Position = Vector3.new(0, antivoidypos, 0)
					AntiVoidPart.Parent = workspace
					if AntiVoidMoveMode.Value == "Classic" and antivoidypos == 0 then 
						AntiVoidPart.Parent = nil
					end
					AntiVoidConnection = AntiVoidPart.Touched:Connect(function(touchedpart)
						if touchedpart.Parent == lplr.Character and entityLibrary.isAlive then
							if (not antivoiding) and (not GuiLibrary.ObjectsThatCanBeSaved.FlyOptionsButton.Api.Enabled) and entityLibrary.character.Humanoid.Health > 0 and AntiVoidMode.Value ~= "Collide" then
								if AntiVoidMode.Value == "Velocity" then
									entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(entityLibrary.character.HumanoidRootPart.Velocity.X, 100, entityLibrary.character.HumanoidRootPart.Velocity.Z)
								else
									antivoiding = true
									local pos = getclosesttop(1000)
									if pos then
										local lastTeleport = lplr:GetAttribute("LastTeleported")
										RunLoops:BindToHeartbeat("AntiVoid", function(dt)
											if entityLibrary.isAlive and entityLibrary.character.Humanoid.Health > 0 and isnetworkowner(entityLibrary.character.HumanoidRootPart) and (entityLibrary.character.HumanoidRootPart.Position - pos).Magnitude > 1 and AntiVoid.Enabled and lplr:GetAttribute("LastTeleported") == lastTeleport then 
												local hori1 = Vector3.new(entityLibrary.character.HumanoidRootPart.Position.X, 0, entityLibrary.character.HumanoidRootPart.Position.Z)
												local hori2 = Vector3.new(pos.X, 0, pos.Z)
												local newpos = (hori2 - hori1).Unit
												local realnewpos = CFrame.new(newpos == newpos and entityLibrary.character.HumanoidRootPart.CFrame.p + (newpos * ((3 + getSpeed()) * dt)) or Vector3.zero)
												entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(realnewpos.p.X, pos.Y, realnewpos.p.Z)
												antivoidvelo = newpos == newpos and newpos * 20 or Vector3.zero
												entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(antivoidvelo.X, entityLibrary.character.HumanoidRootPart.Velocity.Y, antivoidvelo.Z)
												if getPlacedBlock((entityLibrary.character.HumanoidRootPart.CFrame.p - Vector3.new(0, 1, 0)) + entityLibrary.character.HumanoidRootPart.Velocity.Unit) or getPlacedBlock(entityLibrary.character.HumanoidRootPart.CFrame.p + Vector3.new(0, 3)) then
													pos = pos + Vector3.new(0, 1, 0)
												end
											else
												RunLoops:UnbindFromHeartbeat("AntiVoid")
												antivoidvelo = nil
												antivoiding = false
											end
										end)
									else
										entityLibrary.character.HumanoidRootPart.CFrame += Vector3.new(0, 100000, 0)
										antivoiding = false
									end
								end
							end
						end
					end)
					repeat
						if entityLibrary.isAlive and AntiVoidMoveMode.Value == "Normal" then 
							local ray = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, Vector3.new(0, -1000, 0), bedwarsStore.blockRaycast)
							if ray or GuiLibrary.ObjectsThatCanBeSaved.FlyOptionsButton.Api.Enabled or GuiLibrary.ObjectsThatCanBeSaved.InfiniteFlyOptionsButton.Api.Enabled then 
								AntiVoidPart.Position = entityLibrary.character.HumanoidRootPart.Position - Vector3.new(0, 21, 0)
							end
						end
						task.wait()
					until (not AntiVoid.Enabled)
				end)
			else
				if AntiVoidConnection then AntiVoidConnection:Disconnect() end
				if AntiVoidPart then
					AntiVoidPart:Destroy() 
				end
			end
		end, 
		HoverText = "Gives you a chance to get on land (Bouncing Twice, abusing, or bad luck will lead to lagbacks)"
	})
	AntiVoidMoveMode = AntiVoid.CreateDropdown({
		Name = "Position Mode",
		Function = function(val) 
			if val == "Classic" then 
				task.spawn(function()
					repeat task.wait() until bedwarsStore.matchState ~= 0 or not vapeInjected
					if vapeInjected and AntiVoidMoveMode.Value == "Classic" and antivoidypos == 0 and AntiVoid.Enabled then
						local lowestypos = 99999
						for i,v in pairs(bedwarsStore.blocks) do 
							local newray = workspace:Raycast(v.Position + Vector3.new(0, 800, 0), Vector3.new(0, -1000, 0), bedwarsStore.blockRaycast)
							if i % 200 == 0 then 
								task.wait(0.06)
							end
							if newray and newray.Position.Y <= lowestypos then
								lowestypos = newray.Position.Y
							end
						end
						antivoidypos = lowestypos - 8
					end
					if AntiVoidPart then 
						AntiVoidPart.Position = Vector3.new(0, antivoidypos, 0)
						AntiVoidPart.Parent = workspace
					end
				end)
			end
		end,
		List = {"Normal", "Classic"}
	})
	AntiVoidMode = AntiVoid.CreateDropdown({
		Name = "Move Mode",
		Function = function(val) 
			if AntiVoidPart then 
				AntiVoidPart.CanCollide = val == "Collide"
			end
		end,
		List = {"Normal", "Collide", "Velocity"}
	})
	AntiVoidTransparent = AntiVoid.CreateSlider({
		Name = "Invisible",
		Min = 1,
		Max = 100,
		Default = 50,
		Function = function(val) 
			if AntiVoidPart then
				AntiVoidPart.Transparency = 1 - (val / 100)
			end
		end,
	})
	AntiVoidColor = AntiVoid.CreateColorSlider({
		Name = "Color",
		Function = function(h, s, v) 
			if AntiVoidPart then
				AntiVoidPart.Color = Color3.fromHSV(h, s, v)
			end
		end
	})
end)

runFunction(function()
	local oldenable2
	local olddisable2
	local oldhitblock
	local blockplacetable2 = {}
	local blockplaceenabled2 = false

	local AutoTool = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = "AutoTool",
		Function = function(callback)
			if callback then
				oldenable2 = bedwars.BlockBreaker.enable
				olddisable2 = bedwars.BlockBreaker.disable
				oldhitblock = bedwars.BlockBreaker.hitBlock
				bedwars.BlockBreaker.enable = function(Self, tab)
					blockplaceenabled2 = true
					blockplacetable2 = Self
					return oldenable2(Self, tab)
				end
				bedwars.BlockBreaker.disable = function(Self)
					blockplaceenabled2 = false
					return olddisable2(Self)
				end
				bedwars.BlockBreaker.hitBlock = function(...)
					if entityLibrary.isAlive and (GuiLibrary.ObjectsThatCanBeSaved["Lobby CheckToggle"].Api.Enabled == false or bedwarsStore.matchState ~= 0) and blockplaceenabled2 then
						local mouseinfo = blockplacetable2.clientManager:getBlockSelector():getMouseInfo(0)
						if mouseinfo and mouseinfo.target and not mouseinfo.target.blockInstance:GetAttribute("NoBreak") and not mouseinfo.target.blockInstance:GetAttribute("Team"..(lplr:GetAttribute("Team") or 0).."NoBreak") then
							if switchToAndUseTool(mouseinfo.target.blockInstance, true) then
								return
							end
						end
					end
					return oldhitblock(...)
				end
			else
				RunLoops:UnbindFromRenderStep("AutoTool")
				bedwars.BlockBreaker.enable = oldenable2
				bedwars.BlockBreaker.disable = olddisable2
				bedwars.BlockBreaker.hitBlock = oldhitblock
				oldenable2 = nil
				olddisable2 = nil
				oldhitblock = nil
			end
		end,
		HoverText = "Automatically swaps your hand to the appropriate tool."
	})
end)

runFunction(function()
	local BedProtector = {Enabled = false}
	local bedprotector1stlayer = {
		Vector3.new(0, 3, 0),
		Vector3.new(0, 3, 3),
		Vector3.new(3, 0, 0),
		Vector3.new(3, 0, 3),
		Vector3.new(-3, 0, 0),
		Vector3.new(-3, 0, 3),
		Vector3.new(0, 0, 6),
		Vector3.new(0, 0, -3)
	}
	local bedprotector2ndlayer = {
		Vector3.new(0, 6, 0),
		Vector3.new(0, 6, 3),
		Vector3.new(0, 3, 6),
		Vector3.new(0, 3, -3),
		Vector3.new(0, 0, -6),
		Vector3.new(0, 0, 9),
		Vector3.new(3, 3, 0),
		Vector3.new(3, 3, 3),
		Vector3.new(3, 0, 6),
		Vector3.new(3, 0, -3),
		Vector3.new(6, 0, 3),
		Vector3.new(6, 0, 0),
		Vector3.new(-3, 3, 3),
		Vector3.new(-3, 3, 0),
		Vector3.new(-6, 0, 3),
		Vector3.new(-6, 0, 0),
		Vector3.new(-3, 0, 6),
		Vector3.new(-3, 0, -3),
	}

	local function getItemFromList(list)
		local selecteditem
		for i3,v3 in pairs(list) do
			local item = getItem(v3)
			if item then 
				selecteditem = item
				break
			end
		end
		return selecteditem
	end

	local function placelayer(layertab, obj, selecteditems)
		for i2,v2 in pairs(layertab) do
			local selecteditem = getItemFromList(selecteditems)
			if selecteditem then
				bedwars.placeBlock(obj.Position + v2, selecteditem.itemType)
			else
				return false
			end
		end
		return true
	end

	local bedprotectorrange = {Value = 1}
	BedProtector = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = "BedProtector",
		Function = function(callback)
            if callback then
                task.spawn(function()
                    for i, obj in pairs(collectionService:GetTagged("bed")) do
                        if entityLibrary.isAlive and obj:GetAttribute("Team"..(lplr:GetAttribute("Team") or 0).."NoBreak") and obj.Parent ~= nil then
                            if (entityLibrary.character.HumanoidRootPart.Position - obj.Position).magnitude <= bedprotectorrange.Value then
                                local firstlayerplaced = placelayer(bedprotector1stlayer, obj, {"obsidian", "stone_brick", "plank_oak", getWool()})
							    if firstlayerplaced then
									placelayer(bedprotector2ndlayer, obj, {getWool()})
							    end
                            end
                            break
                        end
                    end
                    BedProtector.ToggleButton(false)
                end)
            end
		end,
		HoverText = "Automatically places a bed defense (Toggle)"
	})
	bedprotectorrange = BedProtector.CreateSlider({
		Name = "Place range",
		Min = 1, 
		Max = 20, 
		Function = function(val) end, 
		Default = 20
	})
end)

runFunction(function()
	local Nuker = {Enabled = false}
	local nukerrange = {Value = 1}
	local nukereffects = {Enabled = false}
	local nukeranimation = {Enabled = false}
	local nukernofly = {Enabled = false}
	local nukerlegit = {Enabled = false}
	local nukerown = {Enabled = false}
    local nukerluckyblock = {Enabled = false}
	local nukerironore = {Enabled = false}
    local nukerbeds = {Enabled = false}
	local nukercustom = {RefreshValues = function() end, ObjectList = {}}
    local luckyblocktable = {}

	Nuker = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = "Nuker",
		Function = function(callback)
            if callback then
				for i,v in pairs(bedwarsStore.blocks) do
					if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find("lucky")) or (nukerironore.Enabled and v.Name == "iron_ore") then
						table.insert(luckyblocktable, v)
					end
				end
				table.insert(Nuker.Connections, collectionService:GetInstanceAddedSignal("block"):Connect(function(v)
                    if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find("lucky")) or (nukerironore.Enabled and v.Name == "iron_ore") then
                        table.insert(luckyblocktable, v)
                    end
                end))
                table.insert(Nuker.Connections, collectionService:GetInstanceRemovedSignal("block"):Connect(function(v)
                    if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find("lucky")) or (nukerironore.Enabled and v.Name == "iron_ore") then
                        table.remove(luckyblocktable, table.find(luckyblocktable, v))
                    end
                end))
                task.spawn(function()
                    repeat
						if (not nukernofly.Enabled or not GuiLibrary.ObjectsThatCanBeSaved.FlyOptionsButton.Api.Enabled) then
							local broke = not entityLibrary.isAlive
							local tool = (not nukerlegit.Enabled) and {Name = "wood_axe"} or bedwarsStore.localHand.tool
							if nukerbeds.Enabled then
								for i, obj in pairs(collectionService:GetTagged("bed")) do
									if broke then break end
									if obj.Parent ~= nil then
										if obj:GetAttribute("BedShieldEndTime") then 
											if obj:GetAttribute("BedShieldEndTime") > workspace:GetServerTimeNow() then continue end
										end
										if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - obj.Position).magnitude <= nukerrange.Value then
											if tool and bedwars.ItemTable[tool.Name].breakBlock and bedwars.BlockController:isBlockBreakable({blockPosition = obj.Position / 3}, lplr) then
												local res, amount = getBestBreakSide(obj.Position)
												local res2, amount2 = getBestBreakSide(obj.Position + Vector3.new(0, 0, 3))
												broke = true
												bedwars.breakBlock((amount < amount2 and obj.Position or obj.Position + Vector3.new(0, 0, 3)), nukereffects.Enabled, (amount < amount2 and res or res2), false, nukeranimation.Enabled)
												break
											end
										end
									end
								end
							end
							broke = broke and not entityLibrary.isAlive
							for i, obj in pairs(luckyblocktable) do
								if broke then break end
								if entityLibrary.isAlive then
									if obj and obj.Parent ~= nil then
										if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - obj.Position).magnitude <= nukerrange.Value and (nukerown.Enabled or obj:GetAttribute("PlacedByUserId") ~= lplr.UserId) then
											if tool and bedwars.ItemTable[tool.Name].breakBlock and bedwars.BlockController:isBlockBreakable({blockPosition = obj.Position / 3}, lplr) then
												bedwars.breakBlock(obj.Position, nukereffects.Enabled, getBestBreakSide(obj.Position), true, nukeranimation.Enabled)
												break
											end
										end
									end
								end
							end
						end
						task.wait()
                    until (not Nuker.Enabled)
                end)
            else
                luckyblocktable = {}
            end
		end,
		HoverText = "Automatically destroys beds & luckyblocks around you."
	})
	nukerrange = Nuker.CreateSlider({
		Name = "Break range",
		Min = 1, 
		Max = 30, 
		Function = function(val) end, 
		Default = 30
	})
	nukerlegit = Nuker.CreateToggle({
		Name = "Hand Check",
		Function = function() end
	})
	nukereffects = Nuker.CreateToggle({
		Name = "Show HealthBar & Effects",
		Function = function(callback) 
			if not callback then
				bedwars.BlockBreaker.healthbarMaid:DoCleaning()
			end
		 end,
		Default = true
	})
	nukeranimation = Nuker.CreateToggle({
		Name = "Break Animation",
		Function = function() end
	})
	nukerown = Nuker.CreateToggle({
		Name = "Self Break",
		Function = function() end,
	})
    nukerbeds = Nuker.CreateToggle({
		Name = "Break Beds",
		Function = function(callback) end,
		Default = true
	})
	nukernofly = Nuker.CreateToggle({
		Name = "Fly Disable",
		Function = function() end
	})
    nukerluckyblock = Nuker.CreateToggle({
		Name = "Break LuckyBlocks",
		Function = function(callback) 
			if callback then 
				luckyblocktable = {}
				for i,v in pairs(bedwarsStore.blocks) do
					if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find("lucky")) or (nukerironore.Enabled and v.Name == "iron_ore") then
						table.insert(luckyblocktable, v)
					end
				end
			else
				luckyblocktable = {}
			end
		 end,
		Default = true
	})
	nukerironore = Nuker.CreateToggle({
		Name = "Break IronOre",
		Function = function(callback) 
			if callback then 
				luckyblocktable = {}
				for i,v in pairs(bedwarsStore.blocks) do
					if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find("lucky")) or (nukerironore.Enabled and v.Name == "iron_ore") then
						table.insert(luckyblocktable, v)
					end
				end
			else
				luckyblocktable = {}
			end
		end
	})
	nukercustom = Nuker.CreateTextList({
		Name = "NukerList",
		TempText = "block (tesla_trap)",
		AddFunction = function()
			luckyblocktable = {}
			for i,v in pairs(bedwarsStore.blocks) do
				if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find("lucky")) then
					table.insert(luckyblocktable, v)
				end
			end
		end
	})
end)


runFunction(function()
	local controlmodule = require(lplr.PlayerScripts.PlayerModule).controls
	local oldmove
	local SafeWalk = {Enabled = false}
	local SafeWalkMode = {Value = "Optimized"}
	SafeWalk = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = "SafeWalk",
		Function = function(callback)
			if callback then
				oldmove = controlmodule.moveFunction
				controlmodule.moveFunction = function(Self, vec, facecam)
					if entityLibrary.isAlive and (not Scaffold.Enabled) and (not GuiLibrary.ObjectsThatCanBeSaved.FlyOptionsButton.Api.Enabled) then
						if SafeWalkMode.Value == "Optimized" then 
							local newpos = (entityLibrary.character.HumanoidRootPart.Position - Vector3.new(0, entityLibrary.character.Humanoid.HipHeight * 2, 0))
							local ray = getPlacedBlock(newpos + Vector3.new(0, -6, 0) + vec)
							for i = 1, 50 do 
								if ray then break end
								ray = getPlacedBlock(newpos + Vector3.new(0, -i * 6, 0) + vec)
							end
							local ray2 = getPlacedBlock(newpos)
							if ray == nil and ray2 then
								local ray3 = getPlacedBlock(newpos + vec) or getPlacedBlock(newpos + (vec * 1.5))
								if ray3 == nil then 
									vec = Vector3.zero
								end
							end
						else
							local ray = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position + vec, Vector3.new(0, -1000, 0), bedwarsStore.blockRaycast)
							local ray2 = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, Vector3.new(0, -entityLibrary.character.Humanoid.HipHeight * 2, 0), bedwarsStore.blockRaycast)
							if ray == nil and ray2 then
								local ray3 = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position + (vec * 1.8), Vector3.new(0, -1000, 0), bedwarsStore.blockRaycast)
								if ray3 == nil then 
									vec = Vector3.zero
								end
							end
						end
					end
					return oldmove(Self, vec, facecam)
				end
			else
				controlmodule.moveFunction = oldmove
			end
		end,
		HoverText = "lets you not walk off because you are bad"
	})
	SafeWalkMode = SafeWalk.CreateDropdown({
		Name = "Mode",
		List = {"Optimized", "Accurate"},
		Function = function() end
	})
end)

runFunction(function()
	local Schematica = {Enabled = false}
	local SchematicaBox = {Value = ""}
	local SchematicaTransparency = {Value = 30}
	local positions = {}
	local tempfolder
	local tempgui
	local aroundpos = {
		[1] = Vector3.new(0, 3, 0),
		[2] = Vector3.new(-3, 3, 0),
		[3] = Vector3.new(-3, -0, 0),
		[4] = Vector3.new(-3, -3, 0),
		[5] = Vector3.new(0, -3, 0),
		[6] = Vector3.new(3, -3, 0),
		[7] = Vector3.new(3, -0, 0),
		[8] = Vector3.new(3, 3, 0),
		[9] = Vector3.new(0, 3, -3),
		[10] = Vector3.new(-3, 3, -3),
		[11] = Vector3.new(-3, -0, -3),
		[12] = Vector3.new(-3, -3, -3),
		[13] = Vector3.new(0, -3, -3),
		[14] = Vector3.new(3, -3, -3),
		[15] = Vector3.new(3, -0, -3),
		[16] = Vector3.new(3, 3, -3),
		[17] = Vector3.new(0, 3, 3),
		[18] = Vector3.new(-3, 3, 3),
		[19] = Vector3.new(-3, -0, 3),
		[20] = Vector3.new(-3, -3, 3),
		[21] = Vector3.new(0, -3, 3),
		[22] = Vector3.new(3, -3, 3),
		[23] = Vector3.new(3, -0, 3),
		[24] = Vector3.new(3, 3, 3),
		[25] = Vector3.new(0, -0, 3),
		[26] = Vector3.new(0, -0, -3)
	}

	local function isNearBlock(pos)
		for i,v in pairs(aroundpos) do
			if getPlacedBlock(pos + v) then
				return true
			end
		end
		return false
	end

	local function gethighlightboxatpos(pos)
		if tempfolder then
			for i,v in pairs(tempfolder:GetChildren()) do
				if v.Position == pos then
					return v 
				end
			end
		end
		return nil
	end

	local function removeduplicates(tab)
		local actualpositions = {}
		for i,v in pairs(tab) do
			if table.find(actualpositions, Vector3.new(v.X, v.Y, v.Z)) == nil then
				table.insert(actualpositions, Vector3.new(v.X, v.Y, v.Z))
			else
				table.remove(tab, i)
			end
			if v.blockType == "start_block" then
				table.remove(tab, i)
			end
		end
	end

	local function rotate(tab)
		for i,v in pairs(tab) do
			local radvec, radius = entityLibrary.character.HumanoidRootPart.CFrame:ToAxisAngle()
			radius = (radius * 57.2957795)
			radius = math.round(radius / 90) * 90
			if radvec == Vector3.new(0, -1, 0) and radius == 90 then
				radius = 270
			end
			local rot = CFrame.new() * CFrame.fromAxisAngle(Vector3.new(0, 1, 0), math.rad(radius))
			local newpos = CFrame.new(0, 0, 0) * rot * CFrame.new(Vector3.new(v.X, v.Y, v.Z))
			v.X = math.round(newpos.p.X)
			v.Y = math.round(newpos.p.Y)
			v.Z = math.round(newpos.p.Z)
		end
	end

	local function getmaterials(tab)
		local materials = {}
		for i,v in pairs(tab) do
			materials[v.blockType] = (materials[v.blockType] and materials[v.blockType] + 1 or 1)
		end
		return materials
	end

	local function schemplaceblock(pos, blocktype, removefunc)
		local fail = false
		local ok = bedwars.RuntimeLib.try(function()
			bedwars.ClientHandlerDamageBlock:Get("PlaceBlock"):CallServer({
				blockType = blocktype or getWool(),
				position = bedwars.BlockController:getBlockPosition(pos)
			})
		end, function(thing)
			fail = true
		end)
		if (not fail) and bedwars.BlockController:getStore():getBlockAt(bedwars.BlockController:getBlockPosition(pos)) then
			removefunc()
		end
	end

	Schematica = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = "Schematica",
		Function = function(callback)
			if callback then
				local mouseinfo = bedwars.BlockEngine:getBlockSelector():getMouseInfo(0)
				if mouseinfo and isfile(SchematicaBox.Value) then
					tempfolder = Instance.new("Folder")
					tempfolder.Parent = workspace
					local newpos = mouseinfo.placementPosition * 3
					positions = game:GetService("HttpService"):JSONDecode(readfile(SchematicaBox.Value))
					if positions.blocks == nil then
						positions = {blocks = positions}
					end
					rotate(positions.blocks)
					removeduplicates(positions.blocks)
					if positions["start_block"] == nil then
						bedwars.placeBlock(newpos)
					end
					for i2,v2 in pairs(positions.blocks) do
						local texturetxt = bedwars.ItemTable[(v2.blockType == "wool_white" and getWool() or v2.blockType)].block.greedyMesh.textures[1]
						local newerpos = (newpos + Vector3.new(v2.X, v2.Y, v2.Z))
						local block = Instance.new("Part")
						block.Position = newerpos
						block.Size = Vector3.new(3, 3, 3)
						block.CanCollide = false
						block.Transparency = (SchematicaTransparency.Value == 10 and 0 or 1)
						block.Anchored = true
						block.Parent = tempfolder
						for i3,v3 in pairs(Enum.NormalId:GetEnumItems()) do
							local texture = Instance.new("Texture")
							texture.Face = v3
							texture.Texture = texturetxt
							texture.Name = tostring(v3)
							texture.Transparency = (SchematicaTransparency.Value == 10 and 0 or (1 / SchematicaTransparency.Value))
							texture.Parent = block
						end
					end
					task.spawn(function()
						repeat
							task.wait(.1)
							if not Schematica.Enabled then break end
							for i,v in pairs(positions.blocks) do
								local newerpos = (newpos + Vector3.new(v.X, v.Y, v.Z))
								if entityLibrary.isAlive and (entityLibrary.character.HumanoidRootPart.Position - newerpos).magnitude <= 30 and isNearBlock(newerpos) and bedwars.BlockController:isAllowedPlacement(lplr, getWool(), newerpos / 3, 0) then
									schemplaceblock(newerpos, (v.blockType == "wool_white" and getWool() or v.blockType), function()
										table.remove(positions.blocks, i)
										if gethighlightboxatpos(newerpos) then
											gethighlightboxatpos(newerpos):Remove()
										end
									end)
								end
							end
						until #positions.blocks == 0 or (not Schematica.Enabled)
						if Schematica.Enabled then 
							Schematica.ToggleButton(false)
							warningNotification("Schematica", "Finished Placing Blocks", 4)
						end
					end)
				end
			else
				positions = {}
				if tempfolder then
					tempfolder:Remove()
				end
			end
		end,
		HoverText = "Automatically places structure at mouse position."
	})
	SchematicaBox = Schematica.CreateTextBox({
		Name = "File",
		TempText = "File (location in workspace)",
		FocusLost = function(enter) 
			local suc, res = pcall(function() return game:GetService("HttpService"):JSONDecode(readfile(SchematicaBox.Value)) end)
			if tempgui then
				tempgui:Remove()
			end
			if suc then
				if res.blocks == nil then
					res = {blocks = res}
				end
				removeduplicates(res.blocks)
				tempgui = Instance.new("Frame")
				tempgui.Name = "SchematicListOfBlocks"
				tempgui.BackgroundTransparency = 1
				tempgui.LayoutOrder = 9999
				tempgui.Parent = SchematicaBox.Object.Parent
				local uilistlayoutschmatica = Instance.new("UIListLayout")
				uilistlayoutschmatica.Parent = tempgui
				uilistlayoutschmatica:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
					tempgui.Size = UDim2.new(0, 220, 0, uilistlayoutschmatica.AbsoluteContentSize.Y)
				end)
				for i4,v4 in pairs(getmaterials(res.blocks)) do
					local testframe = Instance.new("Frame")
					testframe.Size = UDim2.new(0, 220, 0, 40)
					testframe.BackgroundTransparency = 1
					testframe.Parent = tempgui
					local testimage = Instance.new("ImageLabel")
					testimage.Size = UDim2.new(0, 40, 0, 40)
					testimage.Position = UDim2.new(0, 3, 0, 0)
					testimage.BackgroundTransparency = 1
					testimage.Image = bedwars.getIcon({itemType = i4}, true)
					testimage.Parent = testframe
					local testtext = Instance.new("TextLabel")
					testtext.Size = UDim2.new(1, -50, 0, 40)
					testtext.Position = UDim2.new(0, 50, 0, 0)
					testtext.TextSize = 20
					testtext.Text = v4
					testtext.Font = Enum.Font.SourceSans
					testtext.TextXAlignment = Enum.TextXAlignment.Left
					testtext.TextColor3 = Color3.new(1, 1, 1)
					testtext.BackgroundTransparency = 1
					testtext.Parent = testframe
				end
			end
		end
	})
	SchematicaTransparency = Schematica.CreateSlider({
		Name = "Transparency",
		Min = 0,
		Max = 10,
		Default = 7,
		Function = function()
			if tempfolder then
				for i2,v2 in pairs(tempfolder:GetChildren()) do
					v2.Transparency = (SchematicaTransparency.Value == 10 and 0 or 1)
					for i3,v3 in pairs(v2:GetChildren()) do
						v3.Transparency = (SchematicaTransparency.Value == 10 and 0 or (1 / SchematicaTransparency.Value))
					end
				end
			end
		end
	})
end)

runFunction(function()
    local Disabler = {Enabled = false}
    Disabler = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
        Name = "FirewallBypass",
        Function = function(callback)
            if callback then 
				task.spawn(function()
					repeat
						task.wait()
						local item = getItemNear("scythe")
						if item and lplr.Character.HandInvItem.Value == item.tool and bedwars.CombatController then 
							bedwars.ClientHandler:Get("ScytheDash"):SendToServer({direction = Vector3.new(9e9, 9e9, 9e9)})
							if entityLibrary.isAlive and entityLibrary.character.Head.Transparency ~= 0 then
								bedwarsStore.scythe = tick() + 1
							end
						end
					until (not Disabler.Enabled)
				end)
            end
        end,
		HoverText = "Float disabler with scythe"
    })
end)

runFunction(function()
	bedwarsStore.TPString = shared.vapeoverlay or nil
	local origtpstring = bedwarsStore.TPString
	local Overlay = GuiLibrary.CreateCustomWindow({
		Name = "Overlay",
		Icon = "vape/assets/TargetIcon1.png",
		IconSize = 16
	})
	local overlayframe = Instance.new("Frame")
	overlayframe.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	overlayframe.Size = UDim2.new(0, 200, 0, 120)
	overlayframe.Position = UDim2.new(0, 0, 0, 5)
	overlayframe.Parent = Overlay.GetCustomChildren()
	local overlayframe2 = Instance.new("Frame")
	overlayframe2.Size = UDim2.new(1, 0, 0, 10)
	overlayframe2.Position = UDim2.new(0, 0, 0, -5)
	overlayframe2.Parent = overlayframe
	local overlayframe3 = Instance.new("Frame")
	overlayframe3.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	overlayframe3.Size = UDim2.new(1, 0, 0, 6)
	overlayframe3.Position = UDim2.new(0, 0, 0, 6)
	overlayframe3.BorderSizePixel = 0
	overlayframe3.Parent = overlayframe2
	local oldguiupdate = GuiLibrary.UpdateUI
	GuiLibrary.UpdateUI = function(h, s, v, ...)
		overlayframe2.BackgroundColor3 = Color3.fromHSV(h, s, v)
		return oldguiupdate(h, s, v, ...)
	end
	local framecorner1 = Instance.new("UICorner")
	framecorner1.CornerRadius = UDim.new(0, 5)
	framecorner1.Parent = overlayframe
	local framecorner2 = Instance.new("UICorner")
	framecorner2.CornerRadius = UDim.new(0, 5)
	framecorner2.Parent = overlayframe2
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -7, 1, -5)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Top
	label.Font = Enum.Font.Arial
	label.LineHeight = 1.2
	label.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	label.TextSize = 16
	label.Text = ""
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(200, 200, 200)
	label.Position = UDim2.new(0, 7, 0, 5)
	label.Parent = overlayframe
	local OverlayFonts = {"Arial"}
	for i,v in pairs(Enum.Font:GetEnumItems()) do 
		if v.Name ~= "Arial" then
			table.insert(OverlayFonts, v.Name)
		end
	end
	local OverlayFont = Overlay.CreateDropdown({
		Name = "Font",
		List = OverlayFonts,
		Function = function(val)
			label.Font = Enum.Font[val]
		end
	})
	OverlayFont.Bypass = true
	Overlay.Bypass = true
	local overlayconnections = {}
	local oldnetworkowner
	local teleported = {}
	local teleported2 = {}
	local teleportedability = {}
	local teleportconnections = {}
	local pinglist = {}
	local fpslist = {}
	local matchstatechanged = 0
	local mapname = "Unknown"
	local overlayenabled = false
	
	task.spawn(function()
		pcall(function()
			mapname = workspace:WaitForChild("Map"):WaitForChild("Worlds"):GetChildren()[1].Name
			mapname = string.gsub(string.split(mapname, "_")[2] or mapname, "-", "") or "Blank"
		end)
	end)

	local function didpingspike()
		local currentpingcheck = pinglist[1] or math.floor(tonumber(game:GetService("Stats"):FindFirstChild("PerformanceStats").Ping:GetValue()))
		for i,v in pairs(pinglist) do 
			if v ~= currentpingcheck and math.abs(v - currentpingcheck) >= 100 then 
				return currentpingcheck.." => "..v.." ping"
			else
				currentpingcheck = v
			end
		end
		return nil
	end

	local function notlasso()
		for i,v in pairs(collectionService:GetTagged("LassoHooked")) do 
			if v == lplr.Character then 
				return false
			end
		end
		return true
	end
	local matchstatetick = tick()

	GuiLibrary.ObjectsThatCanBeSaved.GUIWindow.Api.CreateCustomToggle({
		Name = "Overlay", 
		Icon = "vape/assets/TargetIcon1.png", 
		Function = function(callback)
			overlayenabled = callback
			Overlay.SetVisible(callback) 
			if callback then 
				table.insert(overlayconnections, bedwars.ClientHandler:OnEvent("ProjectileImpact", function(p3)
					if not vapeInjected then return end
					if p3.projectile == "telepearl" then 
						teleported[p3.shooterPlayer] = true
					elseif p3.projectile == "swap_ball" then
						if p3.hitEntity then 
							teleported[p3.shooterPlayer] = true
							local plr = playersService:GetPlayerFromCharacter(p3.hitEntity)
							if plr then teleported[plr] = true end
						end
					end
				end))
		
				table.insert(overlayconnections, replicatedStorageService["events-@easy-games/game-core:shared/game-core-networking@getEvents.Events"].abilityUsed.OnClientEvent:Connect(function(char, ability)
					if ability == "recall" or ability == "hatter_teleport" or ability == "spirit_assassin_teleport" or ability == "hannah_execute" then 
						local plr = playersService:GetPlayerFromCharacter(char)
						if plr then
							teleportedability[plr] = tick() + (ability == "recall" and 12 or 1)
						end
					end
				end))

				table.insert(overlayconnections, vapeEvents.BedwarsBedBreak.Event:Connect(function(bedTable)
					if bedTable.player.UserId == lplr.UserId then
						bedwarsStore.statistics.beds = bedwarsStore.statistics.beds + 1
					end
				end))

				local victorysaid = false
				table.insert(overlayconnections, vapeEvents.MatchEndEvent.Event:Connect(function(winstuff)
					local myTeam = bedwars.ClientStoreHandler:getState().Game.myTeam
					if myTeam and myTeam.id == winstuff.winningTeamId or lplr.Neutral then
						victorysaid = true
					end
				end))

				table.insert(overlayconnections, vapeEvents.EntityDeathEvent.Event:Connect(function(deathTable)
					if deathTable.finalKill then
						local killer = playersService:GetPlayerFromCharacter(deathTable.fromEntity)
						local killed = playersService:GetPlayerFromCharacter(deathTable.entityInstance)
						if not killed or not killer then return end
						if killed ~= lplr and killer == lplr then 
							bedwarsStore.statistics.kills = bedwarsStore.statistics.kills + 1
						end
					end
				end))
				
				task.spawn(function()
					repeat
						local ping = math.floor(tonumber(game:GetService("Stats"):FindFirstChild("PerformanceStats").Ping:GetValue()))
						if #pinglist >= 10 then 
							table.remove(pinglist, 1)
						end
						table.insert(pinglist, ping)
						task.wait(1)
						if bedwarsStore.matchState ~= matchstatechanged then 
							if bedwarsStore.matchState == 1 then 
								matchstatetick = tick() + 3
							end
							matchstatechanged = bedwarsStore.matchState
						end
						if not bedwarsStore.TPString then
							bedwarsStore.TPString = tick().."/"..bedwarsStore.statistics.kills.."/"..bedwarsStore.statistics.beds.."/"..(victorysaid and 1 or 0).."/"..(1).."/"..(0).."/"..(0).."/"..(0)
							origtpstring = bedwarsStore.TPString
						end
						if entityLibrary.isAlive and (not oldcloneroot) then 
							local newnetworkowner = isnetworkowner(entityLibrary.character.HumanoidRootPart)
							if oldnetworkowner ~= nil and oldnetworkowner ~= newnetworkowner and newnetworkowner == false and notlasso() then 
								local respawnflag = math.abs(lplr:GetAttribute("SpawnTime") - lplr:GetAttribute("LastTeleported")) > 3
								if (not teleported[lplr]) and respawnflag then
									task.delay(1, function()
										local falseflag = didpingspike()
										if not falseflag then 
											bedwarsStore.statistics.lagbacks = bedwarsStore.statistics.lagbacks + 1
										end
									end)
								end
							end
							oldnetworkowner = newnetworkowner
						else
							oldnetworkowner = nil
						end
						teleported[lplr] = nil
						for i, v in pairs(entityLibrary.entityList) do 
							if teleportconnections[v.Player.Name.."1"] then continue end
							teleportconnections[v.Player.Name.."1"] = v.Player:GetAttributeChangedSignal("LastTeleported"):Connect(function()
								if not vapeInjected then return end
								for i = 1, 15 do 
									task.wait(0.1)
									if teleported[v.Player] or teleported2[v.Player] or matchstatetick > tick() or math.abs(v.Player:GetAttribute("SpawnTime") - v.Player:GetAttribute("LastTeleported")) < 3 or (teleportedability[v.Player] or tick() - 1) > tick() then break end
								end
								if v.Player ~= nil and (not v.Player.Neutral) and teleported[v.Player] == nil and teleported2[v.Player] == nil and (teleportedability[v.Player] or tick() - 1) < tick() and math.abs(v.Player:GetAttribute("SpawnTime") - v.Player:GetAttribute("LastTeleported")) > 3 and matchstatetick <= tick() then 
									bedwarsStore.statistics.universalLagbacks = bedwarsStore.statistics.universalLagbacks + 1
									vapeEvents.LagbackEvent:Fire(v.Player)
								end
								teleported[v.Player] = nil
							end)
							teleportconnections[v.Player.Name.."2"] = v.Player:GetAttributeChangedSignal("PlayerConnected"):Connect(function()
								teleported2[v.Player] = true
								task.delay(5, function()
									teleported2[v.Player] = nil
								end)
							end)
						end
						local splitted = origtpstring:split("/")
						label.Text = "Session Info\nTime Played : "..os.date("!%X",math.floor(tick() - splitted[1])).."\nKills : "..(splitted[2] + bedwarsStore.statistics.kills).."\nBeds : "..(splitted[3] + bedwarsStore.statistics.beds).."\nWins : "..(splitted[4] + (victorysaid and 1 or 0)).."\nGames : "..splitted[5].."\nLagbacks : "..(splitted[6] + bedwarsStore.statistics.lagbacks).."\nUniversal Lagbacks : "..(splitted[7] + bedwarsStore.statistics.universalLagbacks).."\nReported : "..(splitted[8] + bedwarsStore.statistics.reported).."\nMap : "..mapname
						local textsize = textService:GetTextSize(label.Text, label.TextSize, label.Font, Vector2.new(9e9, 9e9))
						overlayframe.Size = UDim2.new(0, math.max(textsize.X + 19, 200), 0, (textsize.Y * 1.2) + 6)
						bedwarsStore.TPString = splitted[1].."/"..(splitted[2] + bedwarsStore.statistics.kills).."/"..(splitted[3] + bedwarsStore.statistics.beds).."/"..(splitted[4] + (victorysaid and 1 or 0)).."/"..(splitted[5] + 1).."/"..(splitted[6] + bedwarsStore.statistics.lagbacks).."/"..(splitted[7] + bedwarsStore.statistics.universalLagbacks).."/"..(splitted[8] + bedwarsStore.statistics.reported)
					until not overlayenabled
				end)
			else
				for i, v in pairs(overlayconnections) do 
					if v.Disconnect then pcall(function() v:Disconnect() end) continue end
					if v.disconnect then pcall(function() v:disconnect() end) continue end
				end
				table.clear(overlayconnections)
			end
		end, 
		Priority = 2
	})
end)

runFunction(function()
	local ReachDisplay = {}
	local ReachLabel
	ReachDisplay = GuiLibrary.CreateLegitModule({
		Name = "Reach Display",
		Function = function(callback)
			if callback then 
				task.spawn(function()
					repeat
						task.wait(0.4)
						ReachLabel.Text = bedwarsStore.attackReachUpdate > tick() and bedwarsStore.attackReach.." studs" or "0.00 studs"
					until (not ReachDisplay.Enabled)
				end)
			end
		end
	})
	ReachLabel = Instance.new("TextLabel")
	ReachLabel.Size = UDim2.new(0, 100, 0, 41)
	ReachLabel.BackgroundTransparency = 0.5
	ReachLabel.TextSize = 15
	ReachLabel.Font = Enum.Font.Gotham
	ReachLabel.Text = "0.00 studs"
	ReachLabel.TextColor3 = Color3.new(1, 1, 1)
	ReachLabel.BackgroundColor3 = Color3.new()
	ReachLabel.Parent = ReachDisplay.GetCustomChildren()
	local ReachCorner = Instance.new("UICorner")
	ReachCorner.CornerRadius = UDim.new(0, 4)
	ReachCorner.Parent = ReachLabel
end)

task.spawn(function()
	local function createannouncement(announcetab)
		local vapenotifframe = Instance.new("TextButton")
		vapenotifframe.AnchorPoint = Vector2.new(0.5, 0)
		vapenotifframe.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
		vapenotifframe.Size = UDim2.new(1, -10, 0, 50)
		vapenotifframe.Position = UDim2.new(0.5, 0, 0, -100)
		vapenotifframe.AutoButtonColor = false
		vapenotifframe.Text = ""
		vapenotifframe.Parent = shared.GuiLibrary.MainGui
		local vapenotifframecorner = Instance.new("UICorner")
		vapenotifframecorner.CornerRadius = UDim.new(0, 256)
		vapenotifframecorner.Parent = vapenotifframe
		local vapeicon = Instance.new("Frame")
		vapeicon.Size = UDim2.new(0, 40, 0, 40)
		vapeicon.Position = UDim2.new(0, 5, 0, 5)
		vapeicon.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
		vapeicon.Parent = vapenotifframe
		local vapeiconicon = Instance.new("ImageLabel")
		vapeiconicon.BackgroundTransparency = 1
		vapeiconicon.Size = UDim2.new(1, -10, 1, -10)
		vapeiconicon.AnchorPoint = Vector2.new(0.5, 0.5)
		vapeiconicon.Position = UDim2.new(0.5, 0, 0.5, 0)
		vapeiconicon.Image = getcustomasset("vape/assets/VapeIcon.png")
		vapeiconicon.Parent = vapeicon
		local vapeiconcorner = Instance.new("UICorner")
		vapeiconcorner.CornerRadius = UDim.new(0, 256)
		vapeiconcorner.Parent = vapeicon
		local vapetext = Instance.new("TextLabel")
		vapetext.Size = UDim2.new(1, -55, 1, -10)
		vapetext.Position = UDim2.new(0, 50, 0, 5)
		vapetext.BackgroundTransparency = 1
		vapetext.TextScaled = true
		vapetext.RichText = true
		vapetext.Font = Enum.Font.Ubuntu
		vapetext.Text = announcetab.Text
		vapetext.TextColor3 = Color3.new(1, 1, 1)
		vapetext.TextXAlignment = Enum.TextXAlignment.Left
		vapetext.Parent = vapenotifframe
		tweenService:Create(vapenotifframe, TweenInfo.new(0.3), {Position = UDim2.new(0.5, 0, 0, 5)}):Play()
		local sound = Instance.new("Sound")
		sound.PlayOnRemove = true
		sound.SoundId = "rbxassetid://6732495464"
		sound.Parent = workspace
		sound:Destroy()
		vapenotifframe.MouseButton1Click:Connect(function()
			local sound = Instance.new("Sound")
			sound.PlayOnRemove = true
			sound.SoundId = "rbxassetid://6732690176"
			sound.Parent = workspace
			sound:Destroy()
			vapenotifframe:Destroy()
		end)
		game:GetService("Debris"):AddItem(vapenotifframe, announcetab.Time or 20)
	end

	local function rundata(datatab, olddatatab)
		if not olddatatab then
			if datatab.Disabled then 
				coroutine.resume(coroutine.create(function()
					repeat task.wait() until shared.VapeFullyLoaded
					task.wait(1)
					GuiLibrary.SelfDestruct()
				end))
				game:GetService("StarterGui"):SetCore("SendNotification", {
					Title = "Vape",
					Text = "Vape is currently disabled, please use vape later.",
					Duration = 30,
				})
			end
			if datatab.KickUsers and datatab.KickUsers[tostring(lplr.UserId)] then
				lplr:Kick(datatab.KickUsers[tostring(lplr.UserId)])
			end
		else
			if datatab.Disabled then 
				coroutine.resume(coroutine.create(function()
					repeat task.wait() until shared.VapeFullyLoaded
					task.wait(1)
					GuiLibrary.SelfDestruct()
				end))
				game:GetService("StarterGui"):SetCore("SendNotification", {
					Title = "Vape",
					Text = "Vape is currently disabled, please use vape later.",
					Duration = 30,
				})
			end
			if datatab.KickUsers and datatab.KickUsers[tostring(lplr.UserId)] then
				lplr:Kick(datatab.KickUsers[tostring(lplr.UserId)])
			end
			if datatab.Announcement and datatab.Announcement.ExpireTime >= os.time() and (datatab.Announcement.ExpireTime ~= olddatatab.Announcement.ExpireTime or datatab.Announcement.Text ~= olddatatab.Announcement.Text) then 
				task.spawn(function()
					createannouncement(datatab.Announcement)
				end)
			end	
		end
	end
	task.spawn(function()
		pcall(function()
			if (inputService.TouchEnabled or inputService:GetPlatform() == Enum.Platform.UWP) and lplr.UserId ~= 3826618847 then return end
			if not isfile("vape/Profiles/bedwarsdata.txt") then 
				local commit = "main"
				for i,v in pairs(game:HttpGet("https://github.com/7GrandDadPGN/VapeV4ForRoblox"):split("\n")) do 
					if v:find("commit") and v:find("fragment") then 
						local str = v:split("/")[5]
						commit = str:sub(0, str:find('"') - 1)
						break
					end
				end
				writefile("vape/Profiles/bedwarsdata.txt", game:HttpGet("https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/"..commit.."/CustomModules/bedwarsdata", true))
			end
			local olddata = readfile("vape/Profiles/bedwarsdata.txt")

			repeat
				local commit = "main"
				for i,v in pairs(game:HttpGet("https://github.com/7GrandDadPGN/VapeV4ForRoblox"):split("\n")) do 
					if v:find("commit") and v:find("fragment") then 
						local str = v:split("/")[5]
						commit = str:sub(0, str:find('"') - 1)
						break
					end
				end
				
				local newdata = game:HttpGet("https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/"..commit.."/CustomModules/bedwarsdata", true)
				if newdata ~= olddata then 
					rundata(game:GetService("HttpService"):JSONDecode(newdata), game:GetService("HttpService"):JSONDecode(olddata))
					olddata = newdata
					writefile("vape/Profiles/bedwarsdata.txt", newdata)
				end

				task.wait(10)
			until not vapeInjected
		end)
	end)
end)

task.spawn(function()
	repeat task.wait() until shared.VapeFullyLoaded
	if not AutoLeave.Enabled then 
		AutoLeave.ToggleButton(false)
	end
end)

if lplr.UserId == 4943216782 then 
	lplr:Kick('mfw, discord > vaperoblox')
end

GuiLibrary.RemoveObject("PanicOptionsButton")
GuiLibrary.RemoveObject("MissileTPOptionsButton")
GuiLibrary.RemoveObject("SwimOptionsButton")
GuiLibrary.RemoveObject("FullbrightOptionsButton")
GuiLibrary.RemoveObject("HighJumpOptionsButton")
GuiLibrary.RemoveObject("AutoRelicOptionsButton")
GuiLibrary.RemoveObject("RavenTPOptionsButton")
GuiLibrary.RemoveObject("XrayOptionsButton")
GuiLibrary.RemoveObject("SchematicaOptionsButton")

runFunction(function()
	local hasTeleported = false
	local TweenService = game:GetService("TweenService")

	function findNearestBed()
		local nearestBed = nil
		local minDistance = math.huge

		for _,v in pairs(game.Workspace:GetDescendants()) do
			if v.Name:lower() == "bed" and v:FindFirstChild("Covers") and v:FindFirstChild("Covers").BrickColor ~= lplr.Team.TeamColor then
				local distance = (v.Position - lplr.Character.HumanoidRootPart.Position).magnitude
				if distance < minDistance then
					nearestBed = v
					minDistance = distance
				end
			end
		end
		return nearestBed
	end
	function tweenToNearestBed()
		local nearestBed = findNearestBed()
		if nearestBed and not hasTeleported then
			hasTeleported = true

			local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)

			local tween = TweenService:Create(lplr.Character.HumanoidRootPart, TweenInfo.new(0.98), {CFrame = nearestBed.CFrame + Vector3.new(0, 2, 0)})
			tween:Play()
		end
	end
	BedTp = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
		Name = "BedTp",
		Function = function(callback)
			if callback then
				lplr.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
				lplr.CharacterAdded:Connect(function()
					wait(0.3) 
					tweenToNearestBed()
				end)
				hasTeleported = false
				warningNotification("APE", "Tping To Random Bed!", 5)
				BedTp["ToggleButton"](false)
			end
		end,
		["HoverText"] = "tp to closest bed v2"
	})
end)

runFunction(function()
    local hasTeleported = false
    local TweenService = game:GetService("TweenService")

    function findNearestPlayer()
        local nearestPlayer = nil
        local minDistance = math.huge

        for _,v in pairs(game.Players:GetPlayers()) do
            if v ~= lplr and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Team ~= lplr.Team and v.Character:FindFirstChild("Humanoid").Health > 0 then
                local distance = (v.Character.HumanoidRootPart.Position - lplr.Character.HumanoidRootPart.Position).magnitude
                if distance < minDistance then
                    nearestPlayer = v
                    minDistance = distance
                end
            end
        end
        return nearestPlayer
    end


    function tweenToNearestPlayer()
        local nearestPlayer = findNearestPlayer()
        if nearestPlayer and not hasTeleported then
            hasTeleported = true

            local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)

            local tween = TweenService:Create(lplr.Character.HumanoidRootPart, TweenInfo.new(0.94), {CFrame = nearestPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 2, 0)})
            tween:Play()
        end
    end

    PlayerTp = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
        Name = "PlayerTP",
        Function = function(callback)
            if callback then
                lplr.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
                lplr.CharacterAdded:Connect(function()
                    wait(0.3)
                    tweenToNearestPlayer()
                end)
                hasTeleported = false
				warningNotification("APE", "Tping To Random Player!", 5)
                PlayerTp["ToggleButton"](false)
            end
        end,
        ["HoverText"] = "Teleports you to the closest player that is not on your team (BETA)"
    })
end)

runFunction(function()
	InfiniteJump = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
		Name = "InfiniteJump",
		Function = function(callback)
			if callback then

			end
		end
	})
	game:GetService("UserInputService").JumpRequest:Connect(function()
		if not InfiniteJump.Enabled then return end
		local localPlayer = game:GetService("Players").LocalPlayer
		local character = localPlayer.Character
		if character and character:FindFirstChildOfClass("Humanoid") then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			humanoid:ChangeState("Jumping")
		end
	end)         
end)

runFunction(function()
local fpsunlocker = {Enabled = false}
fpsunlocker = GuiLibrary["ObjectsThatCanBeSaved"]["APEWindow"]["Api"].CreateOptionsButton({
   Name = "FPS Unlocker",
   Function = function(callback)
   if callback then
      setfpscap(9e9)
   else
      setfpscap(60)
   end
end
})
end)

runFunction(function()
	DragonBreath = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
		Name = "DragonBreath",
		HoverText = "be a dragon lel",
		Function = function(callback)
			if callback then 
				task.spawn(function()
					repeat 
						task.wait(0.3) 
						game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("DragonBreath"):FireServer({player = game:GetService("Players").LocalPlayer})
					until (not DragonBreath.Enabled)
				end)
			end
		end
	})
end)

runFunction(function()
    local Confetti = {Enabled = false}
    Confetti = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
        Name = "ConfettiExploit",
        Function = function(callback)
            if callback then 
                task.spawn(function()
                    repeat 
                        task.wait(0.001) 
                        game:GetService("ReplicatedStorage"):WaitForChild("events-@easy-games/game-core:shared/game-core-networking@getEvents.Events"):WaitForChild("useAbility"):FireServer("PARTY_POPPER")
                    until (not Confetti.Enabled)
                end)
            end
        end,
      HoverText = "Fixed  Confetti Exploit"
    })
end)

runFunction(function()
local lplr = game:GetService("Players").LocalPlayer
local KnitClient = debug.getupvalue(require(lplr.PlayerScripts.TS.knit).setup, 6)
local Client = require(game:GetService("ReplicatedStorage").TS.remotes).default.Client
local Notify = {["Enabled"] = false}
-- Bed Broken Notification
Client:WaitFor("BedwarsBedBreak"):andThen(function(p13)
p13:Connect(function(p14)
	if Notify["Enabled"] then
		local team = p14.brokenBedTeam.displayName
		if team == lplr.Team.Name then
			warningNotification("APE", "bed broke, L", 3.2)
			end
		end
	end)
end)
-- Break Bed Notification
Client:WaitFor("BedwarsBedBreak"):andThen(function(p13)
p13:Connect(function(p14)
	if Notify["Enabled"] then
		if p14.player.Name == lplr.Name then
			warningNotification("APE", "you broke a bed! nice", 2)
			end
		end
	end)
end)
-- Kill Player Notification
Client:WaitFor("EntityDeathEvent"):andThen(function(p6)
p6:Connect(function(p7)
	if Notify["Enabled"] then
		if p7.fromEntity == lplr.Character then
			local plr = playersService:GetPlayerFromCharacter(p7.entityInstance)
			warningNotification("APE", "you killed "..(plr.name), 3)
			end
		end
	end)
end)
local Notify = GuiLibrary["ObjectsThatCanBeSaved"]["UtilityWindow"]["Api"].CreateOptionsButton({
["Name"] = "Notifications",
["Function"]= function(callback) Notify["Enabled"] = callback end,
["HoverText"] = "Notifys you when certain actions happen"
})
end)
			
runFunction(function()
    local ChatMover = {Enabled = false}
    ChatMover = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
        Name = "ChatMover",
        HoverText = "Move chat to the bottom",
        Function = function(callback)
            if callback then
                game:GetService("TextChatService").ChatWindowConfiguration.HorizontalAlignment = Enum.HorizontalAlignment.Left
                game:GetService("TextChatService").ChatWindowConfiguration.VerticalAlignment = Enum.VerticalAlignment.Center
            else
                game:GetService("TextChatService").ChatWindowConfiguration.HorizontalAlignment = Enum.HorizontalAlignment.Top
                game:GetService("TextChatService").ChatWindowConfiguration.VerticalAlignment = Enum.VerticalAlignment.Center
            end
        end
    })
end)

runFunction(function()
local anim = {["Enabled"] = false}
	anim = GuiLibrary["ObjectsThatCanBeSaved"]["APEWindow"]["Api"].CreateOptionsButton({
		["Name"] = "AnimationChanger",
		["HoverText"] = "gives you a FE Animation Pack. Its also customizable",
		["Function"] = function(callback)
			if callback then
				task.spawn(function()
				local Hum = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
					if not Hum then
						repeat task.wait() until Hum
					end
				local Animate = game:GetService("Players").LocalPlayer.Character.Animate
				----Cartoony
				if animrun.Value == "Cartoony" and animtype.Value == "Custom" then
					Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=10921076136" 	
			end
	if animwalk.Value == "Cartoony" and animtype.Value == "Custom" then
		Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921082452"
	end
	if animfall.Value == "Cartoony" and animtype.Value == "Custom" then
		Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921077030"
		end
		if animjump.Value == "Cartoony" and animtype.Value == "Custom" then
			Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921078135"
		end
		if animidle.Value == "Cartoony" and animtype.Value == "Custom" then
			Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921071918"
			Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921072875"
		end
		if animclimb.Value == "Cartoony" and animtype.Value == "Custom" then
			Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=10921070953"
		end
		----Levitation
				if animrun.Value == "Levitation" and animtype.Value == "Custom" then
					Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=10921135644" 	
			end
	
			if animwalk.Value == "Levitation" and animtype.Value == "Custom" then
		Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921140719"
	end
	if animfall.Value == "Levitation" and animtype.Value == "Custom" then
		Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921136539"
		end
		if animjump.Value == "Levitation" and animtype.Value == "Custom" then
			Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921137402"
		end
		if animidle.Value == "Levitation" and animtype.Value == "Custom" then
			Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921132962"
			Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921133721"
		end
			if animwalk.Value == "Levitation" and animtype.Value == "Custom" then
		Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921140719"
	end
	if animfall.Value == "Levitation" and animtype.Value == "Custom" then
		Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921136539"
		end
		if animjump.Value == "Levitation" and animtype.Value == "Custom" then
			Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921137402"
		end
		if animidle.Value == "Levitation" and animtype.Value == "Custom" then
			Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921132962"
			Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921133721"
		end
		if animclimb.Value == "Levitation" and animtype.Value == "Custom" then
			Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=10921132092"
		end
---Robot
		if animrun.Value == "Robot" and animtype.Value == "Custom" then
			Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=10921250460" 	
	end

	if animwalk.Value == "Robot" and animtype.Value == "Custom" then
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921255446"
end
if animfall.Value == "Robot" and animtype.Value == "Custom" then
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921251156"
end
if animjump.Value == "Robot" and animtype.Value == "Custom" then
	Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921252123"
end
if animidle.Value == "Robot" and animtype.Value == "Custom" then
	Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921248039"
	Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921248831"
end
if animclimb.Value == "Robot" and animtype.Value == "Custom" then
	Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=10921247141"
end
---Stylish
if animrun.Value == "Stylish" and animtype.Value == "Custom" then
			Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=10921276116" 	
	end
	if animwalk.Value == "Stylish" and animtype.Value == "Custom" then
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921283326"
end
if animfall.Value == "Stylish" and animtype.Value == "Custom" then
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921278648"
end
if animjump.Value == "Stylish" and animtype.Value == "Custom" then
	Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921279832"
end
if animidle.Value == "Stylish" and animtype.Value == "Custom" then
	Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921272275"
	Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921273958"
end
if animclimb.Value == "Stylish" and animtype.Value == "Custom" then
	Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=10921271391"
end
---Superhero
if animrun.Value == "Superhero" and animtype.Value == "Custom" then
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=10921291831" 	
end
if animwalk.Value == "Superhero" and animtype.Value == "Custom" then
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921298616"
end
if animfall.Value == "Superhero" and animtype.Value == "Custom" then
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921293373"
end
if animjump.Value == "Superhero" and animtype.Value == "Custom" then
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921294559"
end
if animidle.Value == "Superhero" and animtype.Value == "Custom" then
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921288909"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921290167"
end
if animclimb.Value == "Superhero" and animtype.Value == "Custom" then
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=10921286911"
end
---Zombie (this animation is garbage lol)
if animrun.Value == "Zombie" and animtype.Value == "Custom" then
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=616163682" 	
end
if animwalk.Value == "Zombie" and animtype.Value == "Custom" then
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921355261"
end
if animfall.Value == "Zombie" and animtype.Value == "Custom" then
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921350320"
warningNotification("Spider","Spider doesn't work well with the Zombie fall. So don't recommend using it",5)
end
if animjump.Value == "Zombie" and animtype.Value == "Custom" then
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921351278"
end
if animidle.Value == "Zombie" and animtype.Value == "Custom" then
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921344533"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921345304"
end
if animclimb.Value == "Zombie" and animtype.Value == "Custom" then
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=10921343576"
end
---Ninja
if animrun.Value == "Ninja" and animtype.Value == "Custom" then
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=10921157929" 	
end
if animwalk.Value == "Ninja" and animtype.Value == "Custom" then
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921162768"
end
if animfall.Value == "Ninja" and animtype.Value == "Custom" then
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921159222"
end
if animjump.Value == "Ninja" and animtype.Value == "Custom" then
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921160088"
end
if animidle.Value == "Ninja" and animtype.Value == "Custom" then
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921155160"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921155867"
end
if animclimb.Value == "Ninja" and animtype.Value == "Custom" then
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=10921154678"
end
---Knight
if animrun.Value == "Knight" and animtype.Value == "Custom" then
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=10921121197" 	
end
if animwalk.Value == "Knight" and animtype.Value == "Custom" then
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921127095"
end
if animfall.Value == "Knight" and animtype.Value == "Custom" then
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921122579"
end
if animjump.Value == "Knight" and animtype.Value == "Custom" then
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921123517"
end
if animidle.Value == "Knight" and animtype.Value == "Custom" then
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921117521"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921118894"
end
if animclimb.Value == "Knight" and animtype.Value == "Custom" then
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=10921116196"
end
---Mage
if animrun.Value == "Mage" and animtype.Value == "Custom" then
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=10921148209" 	
end
if animwalk.Value == "Mage" and animtype.Value == "Custom" then
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921152678"
end
if animfall.Value == "Mage" and animtype.Value == "Custom" then
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921148939"
end
if animjump.Value == "Mage" and animtype.Value == "Custom" then
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921149743"
end
if animidle.Value == "Mage" and animtype.Value == "Custom" then
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921144709"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921145797"
end
if animclimb.Value == "Mage" and animtype.Value == "Custom" then
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=10921143404"
end
---Pirate
if animrun.Value == "Pirate" and animtype.Value == "Custom" then
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=750783738" 	
end
if animwalk.Value == "Pirate" and animtype.Value == "Custom" then
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=750785693"
end
if animfall.Value == "Pirate" and animtype.Value == "Custom" then
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=750780242"
end
if animjump.Value == "Pirate" and animtype.Value == "Custom" then
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=750782230"
end
if animidle.Value == "Pirate" and animtype.Value == "Custom" then
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=750781874"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=750782770"
end
if animclimb.Value == "Pirate" and animtype.Value == "Custom" then
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=750779899"
end
---Elder
if animrun.Value == "Elder" and animtype.Value == "Custom" then
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=10921104374" 	
end
if animwalk.Value == "Elder" and animtype.Value == "Custom" then
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921111375"
end
if animfall.Value == "Elder" and animtype.Value == "Custom" then
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921105765"
end
if animjump.Value == "Elder" and animtype.Value == "Custom" then
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921107367"
end
if animidle.Value == "Elder" and animtype.Value == "Custom" then
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921101664"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921102574"
end
if animclimb.Value == "Elder" and animtype.Value == "Custom" then
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=10921100400"
end
---Toy (my favorite)
if animrun.Value == "Toy" and animtype.Value == "Custom" then
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=10921306285" 	
end
if animwalk.Value == "Toy" and animtype.Value == "Custom" then
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921312010"
end
if animfall.Value == "Toy" and animtype.Value == "Custom" then
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921307241"
end
if animjump.Value == "Toy" and animtype.Value == "Custom" then
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921308158"
end
if animidle.Value == "Toy" and animtype.Value == "Custom" then
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921301576"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921302207"
end
if animclimb.Value == "Toy" and animtype.Value == "Custom" then
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=10921300839"
end
---Bubbly
if animrun.Value == "Bubbly" and animtype.Value == "Custom" then
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=10921057244" 	
end
if animwalk.Value == "Bubbly" and animtype.Value == "Custom" then
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10980888364"
end
if animfall.Value == "Bubbly" and animtype.Value == "Custom" then
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921061530"
end
if animjump.Value == "Bubbly" and animtype.Value == "Custom" then
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921062673"
end
if animidle.Value == "Bubbly" and animtype.Value == "Custom" then
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921054344"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921055107"
end
if animclimb.Value == "Bubbly" and animtype.Value == "Custom" then
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=10921053544"
end
---Astronaut
if animrun.Value == "Astronaut" and animtype.Value == "Custom" then
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=10921039308" 	
end
if animwalk.Value == "Astronaut" and animtype.Value == "Custom" then
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921046031"
end
if animfall.Value == "Astronaut" and animtype.Value == "Custom" then
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921040576"
end
if animjump.Value == "Astronaut" and animtype.Value == "Custom" then
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921042494"
end
if animidle.Value == "Astronaut" and animtype.Value == "Custom" then
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921034824"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921036806"
end
if animclimb.Value == "Astronaut" and animtype.Value == "Custom" then
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=10921032124"
end
---Vampire
if animrun.Value == "Vampire" and animtype.Value == "Custom" then
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=10921320299" 	
end
if animwalk.Value == "Vampire" and animtype.Value == "Custom" then
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921326949"
end
if animfall.Value == "Vampire" and animtype.Value == "Custom" then
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921321317"
end
if animjump.Value == "Vampire" and animtype.Value == "Custom" then
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921322186"
end
if animidle.Value == "Vampire" and animtype.Value == "Custom" then
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921315373"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921316709"
end
if animclimb.Value == "Vampire" and animtype.Value == "Custom" then
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=10921314188"
end
---Werewolf
if animrun.Value == "Werewolf" and animtype.Value == "Custom" then
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=10921336997" 	
end
if animwalk.Value == "Werewolf" and animtype.Value == "Custom" then
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921342074"
end
if animfall.Value == "Werewolf" and animtype.Value == "Custom" then
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921337907"
end
if animjump.Value == "Werewolf" and animtype.Value == "Custom" then
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=1083218792"
end
if animidle.Value == "Werewolf" and animtype.Value == "Custom" then
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921330408"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921333667"
end
if animclimb.Value == "Werewolf" and animtype.Value == "Custom" then
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=10921329322"
end
---Rthro
if animrun.Value == "Rthro" and animtype.Value == "Custom" then
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=10921261968" 	
end
if animwalk.Value == "Rthro" and animtype.Value == "Custom" then
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921269718"
end
if animfall.Value == "Rthro" and animtype.Value == "Custom" then
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921262864"
end
if animjump.Value == "Rthro" and animtype.Value == "Custom" then
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921263860"
end
if animidle.Value == "Rthro" and animtype.Value == "Custom" then
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921258489"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921259953"
end
if animclimb.Value == "Rthro" and animtype.Value == "Custom" then
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=10921257536"
end
---Oldschool
if animrun.Value == "Oldschool" and animtype.Value == "Custom" then
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=10921240218" 	
end
if animwalk.Value == "Oldschool" and animtype.Value == "Custom" then
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921244891"
end
if animfall.Value == "Oldschool" and animtype.Value == "Custom" then
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921241244"
end
if animjump.Value == "Oldschool" and animtype.Value == "Custom" then
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921242013"
end
if animidle.Value == "Oldschool" and animtype.Value == "Custom" then
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921230744"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921232093"
end
if animclimb.Value == "Oldschool" and animtype.Value == "Custom" then
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=10921229866"
end
---Mr.Toilet
if animrun.Value == "Toilet" and animtype.Value == "Custom" then
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=4417979645" 	
end
if animidle.Value == "Toilet" and animtype.Value == "Custom" then
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=4417977954"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=4417978624"
end
---Ud'Zal
if animrun.Value == "Rthro Heavy Run" and animtype.Value == "Custom" then
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=3236836670" 	
end
if animidle.Value == "Ud'zal" and animtype.Value == "Custom" then
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=3303162274"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=3303162549"
end
if animwalk.Value == "Ud'zal" and animtype.Value == "Custom" then
	Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=3303162967"
	end
	if animtype.Value == "Tryhard" then
		Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921301576"
		Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921302207"
		Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921162768"
		Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=10921157929"
		Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921137402"
		Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921136539"
	end
	if animtype.Value == "Goofy" then
		Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=4417977954"
		Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=4417978624"
		Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921162768"
		Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=4417979645"
		Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921137402"
		Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921136539"
	end
	if animtype.Value == "Tanqr" then
		Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921034824"
		Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921036806"
		Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921312010"
		Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=10921306285"
		Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921242013"
		Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921136539"
	end
end)
	end
	end
	})
	animtype = anim.CreateDropdown({
		Name = "Type",
		List = {"Custom", "Tryhard", "Goofy", "Tanqr"},
		Function = function() end
	})
	animrun = anim.CreateDropdown({
		Name = "Run",
		List = {"Cartoony", "Levitation", "Robot", "Stylish", "Superhero", "Zombie", "Ninja", "Knight", "Mage", "Pirate", "Elder", "Toy", "Bubbly", "Astronaut", "Vampire", "Werewolf", "Rthro", "Oldschool", "Toilet", "Rthro Heavy Run"},
		Function = function() end
	})

	animwalk = anim.CreateDropdown({
		Name = "Walk",
		List = {"Cartoony", "Levitation", "Robot", "Stylish", "Superhero", "Zombie", "Ninja", "Knight", "Mage", "Pirate", "Elder", "Toy", "Bubbly", "Astronaut", "Vampire", "Werewolf", "Rthro", "Oldschool", "Ud'zal"},
		Function = function() end
	})

	animfall = anim.CreateDropdown({
		Name = "Fall",
		List = {"Cartoony", "Levitation", "Robot", "Stylish", "Superhero", "Zombie", "Ninja", "Knight", "Mage", "Pirate", "Elder", "Toy", "Bubbly", "Astronaut", "Vampire", "Werewolf", "Rthro", "Oldschool"},
		Function = function() end
	})

	animjump = anim.CreateDropdown({
		Name = "Jump",
		List = {"Cartoony", "Levitation", "Robot", "Stylish", "Superhero", "Zombie", "Ninja", "Knight", "Mage", "Pirate", "Elder", "Toy", "Bubbly", "Astronaut", "Vampire", "Werewolf", "Rthro", "Oldschool"},
		Function = function() end
	})

	animidle = anim.CreateDropdown({
		Name = "Idle",
		List = {"Cartoony", "Levitation", "Robot", "Stylish", "Superhero", "Zombie", "Ninja", "Knight", "Mage", "Pirate", "Elder", "Toy", "Bubbly", "Astronaut", "Vampire", "Werewolf", "Rthro", "Oldschool", "Toilet", "Ud'zal"},
		Function = function() end
	})

	animclimb = anim.CreateDropdown({
		Name = "Climb",
		List = {"Cartoony", "Levitation", "Robot", "Stylish", "Superhero", "Zombie", "Ninja", "Knight", "Mage", "Pirate", "Elder", "Toy", "Bubbly", "Astronaut", "Vampire", "Werewolf", "Rthro", "Oldschool"},
		Function = function() end
	})
end)


				runFunction(function()
					local DuelsAutoWin = {Enabled = false}
					DuelsAutoWin = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
					Name = "AlSploit Autowin Leaked",
					HoverText = "auto win the duels and its leaked alsploit",
					Function = function(callback)
						if callback then
						task.spawn(function()
						loadstring(game:HttpGet('https://raw.githubusercontent.com/RayFaxiu/APEForRoblox/main/AutoWin.lua'))()
						end)
					end
				end
						})
					end)

local Shaders = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
	["Name"] = "Shaders",
	["Function"] = function(callback)
		if callback then
			workspace.Gravity = 192
			pcall(function()
				game:GetService("Lighting"):ClearAllChildren()
				local Bloom = Instance.new("BloomEffect")
				Bloom.Intensity = 0.1
				Bloom.Threshold = 0
				Bloom.Size = 100

				local Tropic = Instance.new("Sky")
				Tropic.Name = "Tropic"
				Tropic.SkyboxUp = "http://www.roblox.com/asset/?id=169210149"
				Tropic.SkyboxLf = "http://www.roblox.com/asset/?id=169210133"
				Tropic.SkyboxBk = "http://www.roblox.com/asset/?id=169210090"
				Tropic.SkyboxFt = "http://www.roblox.com/asset/?id=169210121"
				Tropic.StarCount = 100
				Tropic.SkyboxDn = "http://www.roblox.com/asset/?id=169210108"
				Tropic.SkyboxRt = "http://www.roblox.com/asset/?id=169210143"
				Tropic.Parent = Bloom

				local Sky = Instance.new("Sky")
				Sky.SkyboxUp = "http://www.roblox.com/asset/?id=196263782"
				Sky.SkyboxLf = "http://www.roblox.com/asset/?id=196263721"
				Sky.SkyboxBk = "http://www.roblox.com/asset/?id=196263721"
				Sky.SkyboxFt = "http://www.roblox.com/asset/?id=196263721"
				Sky.CelestialBodiesShown = false
				Sky.SkyboxDn = "http://www.roblox.com/asset/?id=196263643"
				Sky.SkyboxRt = "http://www.roblox.com/asset/?id=196263721"
				Sky.Parent = Bloom

				Bloom.Parent = game:GetService("Lighting")

				local Bloom = Instance.new("BloomEffect")
				Bloom.Enabled = false
				Bloom.Intensity = 0.35
				Bloom.Threshold = 0.2
				Bloom.Size = 56

				local Tropic = Instance.new("Sky")
				Tropic.Name = "Tropic"
				Tropic.SkyboxUp = "http://www.roblox.com/asset/?id=169210149"
				Tropic.SkyboxLf = "http://www.roblox.com/asset/?id=169210133"
				Tropic.SkyboxBk = "http://www.roblox.com/asset/?id=169210090"
				Tropic.SkyboxFt = "http://www.roblox.com/asset/?id=169210121"
				Tropic.StarCount = 100
				Tropic.SkyboxDn = "http://www.roblox.com/asset/?id=169210108"
				Tropic.SkyboxRt = "http://www.roblox.com/asset/?id=169210143"
				Tropic.Parent = Bloom

				local Sky = Instance.new("Sky")
				Sky.SkyboxUp = "http://www.roblox.com/asset/?id=196263782"
				Sky.SkyboxLf = "http://www.roblox.com/asset/?id=196263721"
				Sky.SkyboxBk = "http://www.roblox.com/asset/?id=196263721"
				Sky.SkyboxFt = "http://www.roblox.com/asset/?id=196263721"
				Sky.CelestialBodiesShown = false
				Sky.SkyboxDn = "http://www.roblox.com/asset/?id=196263643"
				Sky.SkyboxRt = "http://www.roblox.com/asset/?id=196263721"
				Sky.Parent = Bloom

				Bloom.Parent = game:GetService("Lighting")
				local Blur = Instance.new("BlurEffect")
				Blur.Size = 2

				Blur.Parent = game:GetService("Lighting")
				local Efecto = Instance.new("BlurEffect")
				Efecto.Name = "Efecto"
				Efecto.Enabled = false
				Efecto.Size = 2

				Efecto.Parent = game:GetService("Lighting")
				local Inaritaisha = Instance.new("ColorCorrectionEffect")
				Inaritaisha.Name = "Inari taisha"
				Inaritaisha.Saturation = 0.05
				Inaritaisha.TintColor = Color3.fromRGB(255, 224, 219)

				Inaritaisha.Parent = game:GetService("Lighting")
				local Normal = Instance.new("ColorCorrectionEffect")
				Normal.Name = "Normal"
				Normal.Enabled = false
				Normal.Saturation = -0.2
				Normal.TintColor = Color3.fromRGB(255, 232, 215)

				Normal.Parent = game:GetService("Lighting")
				local SunRays = Instance.new("SunRaysEffect")
				SunRays.Intensity = 0.05

				SunRays.Parent = game:GetService("Lighting")
				local Sunset = Instance.new("Sky")
				Sunset.Name = "Sunset"
				Sunset.SkyboxUp = "rbxassetid://323493360"
				Sunset.SkyboxLf = "rbxassetid://323494252"
				Sunset.SkyboxBk = "rbxassetid://323494035"
				Sunset.SkyboxFt = "rbxassetid://323494130"
				Sunset.SkyboxDn = "rbxassetid://323494368"
				Sunset.SunAngularSize = 14
				Sunset.SkyboxRt = "rbxassetid://323494067"

				Sunset.Parent = game:GetService("Lighting")
				local Takayama = Instance.new("ColorCorrectionEffect")
				Takayama.Name = "Takayama"
				Takayama.Enabled = false
				Takayama.Saturation = -0.3
				Takayama.Contrast = 0.1
				Takayama.TintColor = Color3.fromRGB(235, 214, 204)

				Takayama.Parent = game:GetService("Lighting")
				local L = game:GetService("Lighting")
				L.Brightness = 2.14
				L.ColorShift_Bottom = Color3.fromRGB(11, 0, 20)
				L.ColorShift_Top = Color3.fromRGB(240, 127, 14)
				L.OutdoorAmbient = Color3.fromRGB(34, 0, 49)
				L.ClockTime = 6.7
				L.FogColor = Color3.fromRGB(94, 76, 106)
				L.FogEnd = 1000
				L.FogStart = 0
				L.ExposureCompensation = 0.24
				L.ShadowSoftness = 0
				L.Ambient = Color3.fromRGB(59, 33, 27)

				local Bloom = Instance.new("BloomEffect")
				Bloom.Intensity = 0.1
				Bloom.Threshold = 0
				Bloom.Size = 100

				local Tropic = Instance.new("Sky")
				Tropic.Name = "Tropic"
				Tropic.SkyboxUp = "http://www.roblox.com/asset/?id=169210149"
				Tropic.SkyboxLf = "http://www.roblox.com/asset/?id=169210133"
				Tropic.SkyboxBk = "http://www.roblox.com/asset/?id=169210090"
				Tropic.SkyboxFt = "http://www.roblox.com/asset/?id=169210121"
				Tropic.StarCount = 100
				Tropic.SkyboxDn = "http://www.roblox.com/asset/?id=169210108"
				Tropic.SkyboxRt = "http://www.roblox.com/asset/?id=169210143"
				Tropic.Parent = Bloom

				local Sky = Instance.new("Sky")
				Sky.SkyboxUp = "http://www.roblox.com/asset/?id=196263782"
				Sky.SkyboxLf = "http://www.roblox.com/asset/?id=196263721"
				Sky.SkyboxBk = "http://www.roblox.com/asset/?id=196263721"
				Sky.SkyboxFt = "http://www.roblox.com/asset/?id=196263721"
				Sky.CelestialBodiesShown = false
				Sky.SkyboxDn = "http://www.roblox.com/asset/?id=196263643"
				Sky.SkyboxRt = "http://www.roblox.com/asset/?id=196263721"
				Sky.Parent = Bloom

				Bloom.Parent = game:GetService("Lighting")

				local Bloom = Instance.new("BloomEffect")
				Bloom.Enabled = false
				Bloom.Intensity = 0.35
				Bloom.Threshold = 0.2
				Bloom.Size = 56

				local Tropic = Instance.new("Sky")
				Tropic.Name = "Tropic"
				Tropic.SkyboxUp = "http://www.roblox.com/asset/?id=169210149"
				Tropic.SkyboxLf = "http://www.roblox.com/asset/?id=169210133"
				Tropic.SkyboxBk = "http://www.roblox.com/asset/?id=169210090"
				Tropic.SkyboxFt = "http://www.roblox.com/asset/?id=169210121"
				Tropic.StarCount = 100
				Tropic.SkyboxDn = "http://www.roblox.com/asset/?id=169210108"
				Tropic.SkyboxRt = "http://www.roblox.com/asset/?id=169210143"
				Tropic.Parent = Bloom

				local Sky = Instance.new("Sky")
				Sky.SkyboxUp = "http://www.roblox.com/asset/?id=196263782"
				Sky.SkyboxLf = "http://www.roblox.com/asset/?id=196263721"
				Sky.SkyboxBk = "http://www.roblox.com/asset/?id=196263721"
				Sky.SkyboxFt = "http://www.roblox.com/asset/?id=196263721"
				Sky.CelestialBodiesShown = false
				Sky.SkyboxDn = "http://www.roblox.com/asset/?id=196263643"
				Sky.SkyboxRt = "http://www.roblox.com/asset/?id=196263721"
				Sky.Parent = Bloom

				Bloom.Parent = game:GetService("Lighting")
				local Blur = Instance.new("BlurEffect")
				Blur.Size = 2

				Blur.Parent = game:GetService("Lighting")
				local Efecto = Instance.new("BlurEffect")
				Efecto.Name = "Efecto"
				Efecto.Enabled = false
				Efecto.Size = 4

				Efecto.Parent = game:GetService("Lighting")
				local Inaritaisha = Instance.new("ColorCorrectionEffect")
				Inaritaisha.Name = "Inari taisha"
				Inaritaisha.Saturation = 0.05
				Inaritaisha.TintColor = Color3.fromRGB(255, 224, 219)

				Inaritaisha.Parent = game:GetService("Lighting")
				local Normal = Instance.new("ColorCorrectionEffect")
				Normal.Name = "Normal"
				Normal.Enabled = false
				Normal.Saturation = -0.2
				Normal.TintColor = Color3.fromRGB(255, 232, 215)

				Normal.Parent = game:GetService("Lighting")
				local SunRays = Instance.new("SunRaysEffect")
				SunRays.Intensity = 0.05

				SunRays.Parent = game:GetService("Lighting")
				local Sunset = Instance.new("Sky")
				Sunset.Name = "Sunset"
				Sunset.SkyboxUp = "rbxassetid://323493360"
				Sunset.SkyboxLf = "rbxassetid://323494252"
				Sunset.SkyboxBk = "rbxassetid://323494035"
				Sunset.SkyboxFt = "rbxassetid://323494130"
				Sunset.SkyboxDn = "rbxassetid://323494368"
				Sunset.SunAngularSize = 14
				Sunset.SkyboxRt = "rbxassetid://323494067"

				Sunset.Parent = game:GetService("Lighting")
				local Takayama = Instance.new("ColorCorrectionEffect")
				Takayama.Name = "Takayama"
				Takayama.Enabled = false
				Takayama.Saturation = -0.3
				Takayama.Contrast = 0.1
				Takayama.TintColor = Color3.fromRGB(235, 214, 204)

				Takayama.Parent = game:GetService("Lighting")
				local L = game:GetService("Lighting")
				L.Brightness = 2.3
				L.ColorShift_Bottom = Color3.fromRGB(11, 0, 20)
				L.ColorShift_Top = Color3.fromRGB(240, 127, 14)
				L.OutdoorAmbient = Color3.fromRGB(34, 0, 49)
				L.TimeOfDay = "07:30:00"
				L.FogColor = Color3.fromRGB(94, 76, 106)
				L.FogEnd = 300
				L.FogStart = 0
				L.ExposureCompensation = 0.24
				L.ShadowSoftness = 0
				L.Ambient = Color3.fromRGB(59, 33, 27)
			end)
		else
			pcall(function()
			end)
		end
	end,
	["Default"] = false,
	["HoverText"] = "Shaders reel"
})

local Messages = {"APE", "Kiddo", "EZ", "Thump!", "Hit!", "Bad", "UrSuck", "Fuck", "L Kid", "Pipe L"
}
local old
local FunnyIndicator = {Enabled = false}
FunnyIndicator = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
Name = "DamageIndicator",
Function = function(Callback)
    FunnyIndicator.Enabled = Callback
    if FunnyIndicator.Enabled then
        old = debug.getupvalue(bedwars.DamageIndicator, 10)["Create"]
        debug.setupvalue(bedwars.DamageIndicator, 10, {
            Create = function(self, obj, ...)
                spawn(function()
                    pcall(function()
                        obj.Parent.Text = Messages[math.random(1, #Messages)]
                        obj.Parent.TextColor3 = Color3.fromHSV(tick() % 5 / 5, 1, 1)
                    end)
                end)
                return game:GetService("TweenService"):Create(obj, ...)
            end
        })
    else
        debug.setupvalue(bedwars.DamageIndicator, 10, {
            Create = old
        })
        old = nil
    end
end
})
	
do local a=[[77fuscator 0.5.0 - discord.gg/CEHsVcBcuf]];return(function(b,c,d,e,f,f,g,h,i,j,k,l,l,m,n,o,p,q,r,s,t,u,u,v,w,w,x,y,y,z,z,z,ba,ba,bb,bb,bb,bc)local bd,be,bf,bg,bh,bi,bj,bk,bl,bm,bn,bo,bp,bq,br,bs,bt,bu,bv,bw,bx,by,bz,ca,cb,cc,cd,ce,cf,cg,ch,ci,cj,ck,cl,cm,cn,co,cp,cq,cr=0 while true do if bd<=17 then if bd<=8 then if bd<=3 then if bd<=1 then if 1>bd then be,bf,bg,bh,bi,bj,bk=string.sub,table.concat,string.char,tonumber,next,((table.create or function(cs,ct)local cu={};for cv=1,cs do cu[cv]=ct;end;return cu;end))or tostring else bl=1 end else if bd>2 then bn=bm(b)else bm=function(b)local bi,bk,cs,ct,cu,cv,cw,cx=0 while true do if bi<=5 then if bi<=2 then if bi<=0 then bk,cs=g,g else if bi<2 then ct=bj(#b)else cu=256 end end else if bi<=3 then cv=bj(cu)else if bi>4 then cw=1 else for bj=0,cu-1 do cv[bj]=bg(bj)end end end end else if bi<=8 then if bi<=6 then cx=function()local bj,cy,cz=0 while true do if bj<=2 then if bj<=0 then cy=bh(be(b,cw,cw),36)else if 2~=bj then cw=(cw+1)else cz=bh(be(b,cw,(cw+cy-1)),36)end end else if bj<=3 then cw=cw+cy else if 4<bj then break else return cz end end end bj=bj+1 end end else if 7<bi then ct[1]=bk else bk=bg(cx())end end else if bi<=9 then while(cw<#b)and not(#a~=d)do local a=cx()if cv[a]then cs=cv[a]else cs=bk..be(bk,1,1)end cv[cu]=(bk..be(cs,1,1))ct[(#ct+1)],bk,cu=cs,cs,(cu+1)end else if 11>bi then return bf(ct)else break end end end end bi=bi+1 end end end end else if bd<=5 then if bd~=5 then bo={}else c={q,w,m,l,u,y,i,o,x,k,j,s,nil,nil};end else if bd<=6 then bp=v else if bd<8 then bq=bp(bo)else br,bs=1,(-4875+(function()local a,b,c,d=0 while true do if a<=1 then if 1~=a then b,c=0,1 else d=(function(q,s)local v=0 while true do if v==0 then s(s(q,s),q(q,q))else break end v=v+1 end end)(function(q,s)local v=0 while true do if v<=2 then if v<=0 then if b>331 then return q end else if 1<v then c=((c*19)%11035)else b=(b+1)end end else if v<=3 then if((c%852)==426 or(c%852)<426)then c=(c+957)%42298 return s(q(q,s),s((q and q),q))else return q end else if v<5 then return s else break end end end v=v+1 end end,function(q,s)local v=0 while true do if v<=2 then if v<=0 then if(b>149)then return s end else if 1==v then b=b+1 else c=(c+797)%36285 end end else if v<=3 then if(((c%836))==418 or((c%836))<418)then c=(((c*81))%21135)return s(q(s,s),q(q and q,s)and s(q,s))else return q end else if 4<v then break else return s end end end v=v+1 end end)end else if 3>a then return c;else break end end a=a+1 end end)())end end end end else if bd<=12 then if bd<=10 then if bd>9 then bu=function(a,b)local c,d=0 while true do if c<=1 then if 1>c then d=0 else for q=0,31 do local s=(a%2)local v=(b%2)if(s==0)then if not(v~=1)then b=(b-1)d=d+2^q end else a=(a-1)if v==0 then d=d+2^q else b=b-1 end end b=(b/2)a=(a/2)end end else if 2<c then break else return d end end c=c+1 end end else bt={}end else if 11<bd then bw=function()local a,b,c=0 while true do if a<=1 then if a>0 then b,c=bu(b,bs),bu(c,bs);else b,c=h(bn,br,(br+2))end else if a<=2 then br=br+2;else if a~=4 then return((bv(c,8))+b);else break end end end a=a+1 end end else bv=function(a,b)local c=0 while true do if c==0 then return(a*2^b);else break end c=c+1 end end end end else if bd<=14 then if 14~=bd then do for a,b in o,l(bl)do bt[a]=b;end;end;else bx=bt end else if bd<=15 then by=function(a,b)local c=0 while true do if c<1 then return p((a/2^b));else break end c=c+1 end end else if 16<bd then ca=function(a,b)local c=0 while true do if 1~=c then return((((a+b)-bu(a,b)))/2)else break end c=c+1 end end else bz=(2^32-1)end end end end end else if bd<=26 then if bd<=21 then if bd<=19 then if bd~=19 then cb=bw()else cc=function(a,b)local c=0 while true do if c>0 then break else return bz-ca(bz-a,bz-b)end c=c+1 end end end else if 21>bd then cd=function(a,b,c)local d=0 while true do if d==0 then if c then local c=(((a/2^(b-1)))%2^((c-1)-(b-1)+1))return(c-c%1)else local b=2^(b-1)return(a%(b+b)>=b)and 1 or 0 end else break end d=d+1 end end else ce=bw()end end else if bd<=23 then if bd<23 then cf=function()local a,b,c,d,p=0 while true do if a<=1 then if a>0 then b,c,d,p=bu(b,cb),bu(c,cb),bu(d,cb),bu(p,cb);else b,c,d,p=h(bn,br,br+3)end else if a<=2 then br=(br+4);else if a~=4 then return((bv(p,24)+bv(d,16)+bv(c,8)))+b;else break end end end a=a+1 end end else cg=function()local a,b=0 while true do if a<=1 then if a<1 then b=bu(h(bn,br,br),cb)else br=(br+1);end else if 3~=a then return b;else break end end a=a+1 end end end else if bd<=24 then ch,ci,cj=nil else if 26~=bd then ch=((-14488+(function()local a,b,c,d,p,q,s,v,w,x,y,be,bf,bg,bh,bi,bj,bk,bs,bw,by,bz=0 while true do if a<=10 then if a<=4 then if a<=1 then if a>0 then c=48533 else b=526 end else if a<=2 then d=3 else if a~=4 then p=270 else q=540 end end end else if a<=7 then if a<=5 then s=12318 else if 7>a then v=385 else w=137 end end else if a<=8 then x=35083 else if a==9 then y=254 else be=340 end end end end else if a<=15 then if a<=12 then if 11<a then bg=170 else bf=2 end else if a<=13 then bh=19255 else if 15~=a then bi=1 else bj=423 end end end else if a<=18 then if a<=16 then bk=240 else if a==17 then bs=0 else bw,by=bs,bi end end else if a<=19 then bz=(function(ca,cc)local ce=0 while true do if 1~=ce then cc(ca(ca,ca)and ca(ca,ca),cc(cc,(ca and ca))and cc(ca,cc))else break end ce=ce+1 end end)(function(ca,cc)local ce=0 while true do if ce<=2 then if ce<=0 then if bw>bk then local bk=bs while true do bk=(bk+bi)if not(bk~=bi)then return cc else break end end end else if 2>ce then bw=(bw+bi)else by=((by-bj)%bh)end end else if ce<=3 then if((by%be)<bg)then local be=bs while true do be=(be+bi)if((be>bf)or be==bf)then if(be<d)then return cc(ca(ca,(ca and cc)),cc(ca,ca))else break end else by=(by+y)%x end end else local x=bs while true do x=(x+bi)if(x<bf)then return cc else break end end end else if ce<5 then return ca else break end end end ce=ce+1 end end,function(x,y)local be=0 while true do if be<=2 then if be<=0 then if(bw>w)then local w=bs while true do w=w+bi if not(w~=bf)then break else return x end end end else if 2~=be then bw=bw+bi else by=((by*v)%s)end end else if be<=3 then if((by%q)>p)then local p=bs while true do p=(p+bi)if(p==bi or p<bi)then by=(by*b)%c else if not(not(p==d))then break else return x(y(x,y),x(y,x))end end end else local b=bs while true do b=b+bi if(b<bf)then return x else break end end end else if be~=5 then return y else break end end end be=be+1 end end)else if 20==a then return by;else break end end end end end a=a+1 end end)()));else ci=(-25303+(function()local a,b,c,d,p,q,s,v,w,x,y,be,bf,bg,bh,bi,bj,bk,bs,bw,by,bz=0 while true do if a<=10 then if a<=4 then if a<=1 then if a~=1 then b=40425 else c=236 end else if a<=2 then d=960 else if 4>a then p=1920 else q=33223 end end end else if a<=7 then if a<=5 then s=2 else if 7~=a then v=894 else w=201 end end else if a<=8 then x=3 else if a~=10 then y=1330 else be=5906 end end end end else if a<=15 then if a<=12 then if 11<a then bg=665 else bf=617 end else if a<=13 then bh=211 else if a==14 then bi=33389 else bj=787 end end end else if a<=18 then if a<=16 then bk=1 else if 18>a then bs=0 else bw,by=bs,bk end end else if a<=19 then bz=(function(ca,cc)local ce=0 while true do if ce==0 then cc(cc(ca,ca),ca(cc,cc))else break end ce=ce+1 end end)(function(ca,cc)local ce=0 while true do if ce<=2 then if ce<=0 then if bw>bh then local bh=bs while true do bh=bh+bk if not(bh~=bk)then return cc else break end end end else if 1==ce then bw=(bw+bk)else by=((by-bj)%bi)end end else if ce<=3 then if(by%y)<bg then local y=bs while true do y=(y+bk)if(y==bk or y<bk)then by=(by*bf)%be else if not(y~=x)then break else return cc(cc(cc,cc),(ca(cc,cc)and cc(ca,cc)))end end end else local y=bs while true do y=(y+bk)if not(y~=s)then break else return cc end end end else if ce<5 then return cc else break end end end ce=ce+1 end end,function(y,be)local bf=0 while true do if bf<=2 then if bf<=0 then if(bw>w)then local w=bs while true do w=(w+bk)if not(not(w==s))then break else return be end end end else if bf==1 then bw=(bw+bk)else by=((by+v)%q)end end else if bf<=3 then if((by%p)>d)then local d=bs while true do d=(d+bk)if(d<bk or d==bk)then by=((by*c)%b)else if not(not(d==x))then break else return be(y(y,be and y),be(be,y))end end end else local b=bs while true do b=(b+bk)if b>bk then break else return y end end end else if 5~=bf then return y else break end end end bf=bf+1 end end)else if 20==a then return by;else break end end end end end a=a+1 end end)());end end end end else if bd<=31 then if bd<=28 then if bd==27 then cj=(-1671+(function()local a=409;local b=818;local c=28939;local d=222;local p=389;local q=38485;local s=1166;local v=583;local w=9454;local x=425;local y=4509;local be=442;local bf=292;local bg=3;local bh=1696;local bi=848;local bj=579;local bk=10108;local bs=252;local bw=908;local by=5205;local bz=470;local ca=746;local cc=1816;local ce=18568;local cs=2;local ct=1;local cu=421;local cv=0;local cw,cx=cv,ct;local a=(function(cy,cz,da,db)cy(cz(db,db,da,db),da(cz,cy,cz,db),da(da,cz,da,da),db(cz and cy,db,da,da))end)(function(cy,cz,da,db)if(cw>cu)then local cu=cv while true do cu=(cu+ct)if(cu<cs)then return cz else break end end end cw=cw+ct cx=(cx+ca)%ce if((cx%cc)==bw or(cx%cc)>bw)then local bw=cv while true do bw=bw+ct if(bw==ct or bw<ct)then cx=(cx-bz)%by else if not(bw~=cs)then return cz(cy(da,cy,cy,(cz and da)),da(cz,cz,cy,(da and db)),da(cy,db,cy,da),(cy(da,(db and cz),cz and da,cy)and cy((da and db),da and cy,db,da)))else break end end end else local bw=cv while true do bw=bw+ct if not(bw~=cs)then break else return cy end end end return cz end,function(bw,by,ca,cc)if cw>bs then local bs=cv while true do bs=bs+ct if not(bs~=cs)then break else return bw end end end cw=cw+ct cx=((cx-bj)%bk)if((cx%bh)==bi or(cx%bh)>bi)then local bh=cv while true do bh=bh+ct if(bh==cs or bh>cs)then if(bh<bg)then return ca else break end else cx=(cx*bf)%y end end else local y=cv while true do y=(y+ct)if(y<cs)then return bw(by(cc and by,bw and by,(ca and bw),bw),(cc(by,cc,by,(ca and cc))and ca(ca,cc,ca,ca)),ca(cc,bw and cc,bw,cc)and by(bw,bw and bw,ca,by),ca(ca,cc,(by and cc),ca))else break end end end return bw(ca(ca,by,ca and bw,cc),cc(ca,ca,cc,bw),bw(cc,cc,by,bw),by(bw,(bw and bw),ca,cc))end,function(y,bf,bh,bi)if(cw>be)then local be=cv while true do be=be+ct if be<cs then return bi else break end end end cw=cw+ct cx=((cx+x)%w)if((cx%s)>v or(cx%s)==v)then local s=cv while true do s=(s+ct)if(s<ct or s==ct)then cx=((cx-bz)%q)else if not(s~=bg)then break else return bi end end end else local q=cv while true do q=(q+ct)if not(q~=cs)then break else return bh(y(bh,(y and bh),bf,bi),(bi(bh,y,bf,bh)and bf(bi,bi and bh,bf,bh and bi)),bh(bf,bh,y,bh),bf(bf,bi,bf,bf))end end end return y(bh(bf and bi,bf,bf and y,(bi and bh)),bi(y,bh,bi,bh),bi(bi and bh,(bh and bh),bf,bh),y(bh,bi,bf,bi))end,function(q,s,v,w)if cw>p then local p=cv while true do p=p+ct if p<cs then return w else break end end end cw=cw+ct cx=(cx*d)%c if((cx%b)>a)then local a=cv while true do a=a+ct if(a<cs)then return q(v(w,q,q,(s and v)),q(q,v,s,(s and q))and w(s,w,w,s),s(q,w,q,(v and q)),v(q,v,q,v)and q(s,v,q,(q and w)))else break end end else local a=cv while true do a=a+ct if not(a~=cs)then break else return s end end end return w end)return cx;end)());else ck=function()local a,b,c,d,p,q,s=0 while true do if a<=3 then if a<=1 then if a==0 then b,c=cf(),cf()else if(b==0 and c==0)then return 0;end;end else if a==2 then d=1 else p=(cd(c,1,20)*(2^32))+b end end else if a<=5 then if 5~=a then q=cd(c,21,31)else s=(((-1)^cd(c,32)))end else if a<=6 then if((q==0))then if((p==0))then return(s*0);else q=1;d=0;end;elseif(not(q~=2047))then if(p==0)then return(s*(1/0));else return s*(0/0);end;end;else if 7<a then break else return(s*(2^(q-1023)))*(d+(p/(2^52)))end end end end a=a+1 end end end else if bd<=29 then cl="\46"else if 31~=bd then cm=function()local a,b,c=0 while true do if a<=1 then if a>0 then b,c=bu(b,cb),bu(c,cb);else b,c=h(bn,br,br+2)end else if a<=2 then br=(br+2);else if 3<a then break else return(bv(c,8))+b;end end end a=a+1 end end else cn=cf end end end else if bd<=33 then if 33>bd then co=function()local a,b,c,d,p=0 while true do if a<=2 then if a<=0 then b=g else if 2~=a then c=157 else d=0 end end else if a<=3 then p={}else if a==4 then while d<8 do d=d+1;while(d<707 and c%1622<811)do c=(((c*35)))local q=d+c if((c%16522)<8261)then c=(c*19)while(((d<828)and c%658<329))do c=((c+60))local q=d+c if(not((((c%18428)))~=9214)or((c%18428))<9214)then c=(((c-50)))local q=10701 if not p[q]then p[q]=1;local q,s=cn(),g;if not(q~=0)then return g;end;b=j(bn,br,((br+q)-1));br=(br+q);return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s==1 then while true do if(0<v)then break else return i(h(q))end v=(v+1)end else break end end s=s+1 end end);end elseif((c%4~=0))then c=(c-67)local q=33140 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 2~=s then while true do if not(v==1)then return i(h(q))else break end v=v+1 end else break end end s=s+1 end end);end else c=(c*88)d=d+1 local q=92657 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s~=2 then while true do if(1>v)then return i(h(q))else break end v=v+1 end else break end end s=s+1 end end);end end;d=(d+1);end elseif not(not((c%4)~=0))then c=(c-48)while(((d<859)and(c%1392)<696))do c=(c*39)local q=((d+c))if((c%58)<29)then c=((c+5))local q=33930 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 1<s then break else while true do if v>0 then break else return i(h(q))end v=(v+1)end end end s=s+1 end end);end elseif not(c%4==0)then c=(c*56)local q=35370 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s==1 then while true do if v>0 then break else return i(h(q))end v=v+1 end else break end end s=s+1 end end);end else c=(((c*9)))d=d+1 local q=96267 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 2>s then while true do if not(1==v)then return i(h(q))else break end v=(v+1)end else break end end s=s+1 end end);end end;d=(d+1);end else c=(((c-51)))d=((d+1))while(d<663)and((c%936)<468)do c=(((c*12)))local q=((d+c))if((((c%18532))==9266 or((c%18532))>9266))then c=(c*71)local q=7037 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s~=2 then while true do if(v>0)then break else return i(h(q))end v=(v+1)end else break end end s=s+1 end end);end elseif not(not((c%4)~=0))then c=(c-18)local q=90882 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 2>s then while true do if(1~=v)then return i(h(q))else break end v=v+1 end else break end end s=s+1 end end);end else c=(c*35)d=((d+1))local q=41573 if not p[q]then p[q]=1;return z(b,cl,function(b)local p,q=0 while true do if p<=0 then q=0 else if 1<p then break else while true do if(q==0)then return i(h(b))else break end q=(q+1)end end end p=p+1 end end);end end;d=(d+1);end end;d=d+1;end c=(c-494)if(d>43)then break;end;end;else break end end end a=a+1 end end else cp=cf end else if bd<=34 then cq=function(...)local a=0 while true do if 1>a then return{...},n("\35",...)else break end a=a+1 end end else if 36~=bd then cr=function()local a,b,c,d,p,q,s,v,w,x=0 while true do if a<=9 then if a<=4 then if a<=1 then if 0==a then b,c,d,p={},{},{},{}else q=m({[ch]=b,nil,[ci]=c,nil,[776]=p,[345]=bb,[536]=nil},{['\95\95\116\111\115\116\114\105\110\103']=function(...)return j(bn,br,br);end,})end else if a<=2 then s={}else if 3<a then w=0 else v=490 end end end else if a<=6 then if a<6 then x={}else while(w<3)do w=(w+1);while(w<481 and v%320<160)do v=((v*62))local d=w+v if((v%916)>458)then v=(((v-88)))while((w<318))and(v%702<351)do v=(((v*8)))local d=(w+v)if(((v%14064))>7032)then v=(v*81)local d=58084 if not x[d]then x[d]=1;s[cf()]=nil;end elseif v%4~=0 then v=((v*37))local d=93269 if not x[d]then x[d]=1;s[cf()]=nil;end else v=((v+10))w=(w+1)local d=78058 if not x[d]then x[d]=1;for d=1,cf()do local j=cg();if(not(not(j==2)))then s[d]=nil;elseif(not((j~=1)))then s[d]=(not(not(cg()~=0)));elseif((not(j~=3)))then s[d]=ck();elseif(not(j~=0))then s[d]=co();end;end;q[cj]=s;end end;w=(w+1);end elseif not(not((v%4)~=0))then v=((v*65))while w<615 and v%618<309 do v=((v-33))local d=(w+v)if((((v%15582))>7791))then v=((v*14))local d=31092 if not x[d]then x[d]=1;s[cf()]=nil;end elseif not((v%4==0))then v=(((v+51)))local d=68285 if not x[d]then x[d]=1;s[cf()]=nil;end else v=((v+53))w=((w+1))local d=64266 if not x[d]then x[d]=1;s[cf()]=nil;end end;w=((w+1));end else v=(v+7)w=(w+1)while((w<127 and v%1548<774))do v=(v-37)local d=(w+v)if(((v%19188))>9594)then v=(((v*61)))local d=73351 if not x[d]then x[d]=1;s[cf()]=nil;end elseif not(not(v%4~=0))then v=((v+25))local d=78934 if not x[d]then x[d]=1;s[cf()]=nil;end else v=(((v+42)))w=((w+1))local d=62692 if not x[d]then x[d]=1;s[cf()]=nil;end end;w=((w+1));end end;w=(w+1);end v=((v*482))if w>56 then break;end;end;end else if a<=7 then q[481]=cg();else if a~=9 then for d=1,cf()do c[d-1]=cr();end;else v=125 end end end end else if a<=14 then if a<=11 then if 11~=a then w=0 else x={}end else if a<=12 then while w<5 do w=((w+1));while w<768 and v%1092<546 do v=((v-34))local c=(w+v)if(v%146)>=73 then v=((v*82))while((w<987)and((v%1420<710)))do v=((v*70))local c=((w+v))if(((v%2270))>1135)then v=(v*61)local c=96383 if not x[c]then x[c]=1;end elseif not(((v%4)==0))then v=((v+37))local c=28147 if not x[c]then x[c]=1;end else v=((v*26))w=w+1 local c=98519 if not x[c]then x[c]=1;local c=1;local d=2;local j=3;local p=4;for p=1,cf()do local y=cg();local bb=cd(y,c,c);if(not(not(bb==0)))then local y,bb,be=cd(y,d,j),cd(y,4,6),m({[304]=cm(),[537]=cm(),nil,nil},{['\95\95\116\111\115\116\114\105\110\103']=function(...)return cd(y,d,j);end,})if(((not(not(not(y~=0))))or(((y==c)))))then be[444]=cf();if(not((not(y==0))))then be[151]=cf();end;elseif(((not(y~=d)))or((not(y~=j))))then be[444]=(((cf()-(e))));if(not(not(y==j)))then be[151]=cm();end;end;if((not(cd(bb,c,c)~=c)))then be[537]=s[be[537]];end;if((not(not(cd(bb,d,d)==c))))then be[444]=s[be[444]];end;if(not((cd(bb,j,j)~=c)))then be[151]=s[be[151]];end;b[p]=be;end;end;end end;w=((w+1));end elseif not(not(((v%4))~=0))then v=(((v+67)))while((w<934 and v%74<37))do v=(v-52)local b=((w+v))if(((v%10732)>5366))then v=((v-43))local b=80726 if not x[b]then x[b]=1;end elseif(not(v%4==0))then v=((v*30))local b=28784 if not x[b]then x[b]=1;end else v=((v-19))w=(w+1)local b=5286 if not x[b]then x[b]=1;end end;w=(w+1);end else v=((v-43))w=w+1 while(w<839 and v%1900<950)do v=((v-44))local b=((w+v))if((v%4212)>2106)then v=(v-31)local b=36825 if not x[b]then x[b]=1;end elseif(not((v%4)==0))then v=((v+5))local b=87353 if not x[b]then x[b]=1;end else v=((v-53))w=w+1 local b=87560 if not x[b]then x[b]=1;end end;w=w+1;end end;w=(w+1);end v=((v+542))if((w>77))then break;end;end;else if 14~=a then do for b=1,#q[ch]do local b=q[ch][b]local c,d,e=b[537],b[444],b[151]if not(not(not(bp(c)~=f)))then c=z(c,cl,function(j,p)local p,s=0 while true do if p<=0 then s=0 else if 2>p then while true do if not(s~=0)then return i(bu(h(j),cb))else break end s=s+1 end else break end end p=p+1 end end)b[537]=c end if not(not(bp(d)==f))then d=z(d,cl,function(c,j,j,j)local j,p=0 while true do if j<=0 then p=0 else if j>1 then break else while true do if(0<p)then break else return i(bu(h(c),cb))end p=(p+1)end end end j=j+1 end end)b[444]=d end if(not(not(bp(e)==f)))then e=z(e,cl,function(c,d,d)local d,j=0 while true do if d<=0 then j=0 else if 2~=d then while true do if(0==j)then return i(bu(h(c),cb))else break end j=(j+1)end else break end end d=d+1 end end)b[151]=e end;end;q[cj]=nil;end;else v=194 end end end else if a<=16 then if a~=16 then w=0 else x={}end else if a<=17 then while w<3 do w=(w+1);while w<383 and v%1128<564 do v=(v+73)local b=(w+v)if(((v%9994)<4997 or(v%9994)==4997))then v=(((v+2)))while(((w<532)and(v%1994)<997))do v=(v-60)local b=(w+v)if(v%338)>=169 then v=(v+20)local b=43551 if not x[b]then x[b]=1;q[536]=function(...)local b,c,d,e,h=0 while true do if b<=0 then c,d,e,h=0 else if 1==b then while true do if(c<2 or c==2)then if(c<=0)then d=n(1,...)else if not(1~=c)then e=({...})else do for d=0,#e do if not((bp(e[d])~=bq))then for i,i in o,e[d]do if not(bp(i)~=bp(g))then t(bo,i)end end else t(bo,e[d])end end end end end else if(c<=3)then h=function(d)local i,j,p=0 while true do if i<=0 then j,p=0 else if 2>i then while true do if(j<1 or j==1)then if(j>0)then for s=0,#bo do if ba(d,bo[s])then return bm(f);end end else p=u(d)end else if j<3 then return false else break end end j=(j+1)end else break end end i=i+1 end end else if(c>4)then break else for d=0,#e do if(not(bp(e[d])~=bq))then return h(e[d])end end end end end c=(c+1)end else break end end b=b+1 end end end elseif not((v%4)==0)then v=(((v+15)))local b=64121 if not x[b]then x[b]=1;end else v=((v*83))w=((w+1))local b=40615 if not x[b]then x[b]=1;end end;w=((w+1));end elseif(v%4~=0)then v=((v+96))while(w<533 and v%1246<623)do v=((v-9))local b=(w+v)if(((v%2940)>1470 or(v%2940)==1470))then v=(((v+53)))local b=58817 if not x[b]then x[b]=1;return q end elseif not(not(((v%4))~=0))then v=((v*93))local b=85918 if not x[b]then x[b]=1;return q end else v=((v+42))w=(w+1)local b=51802 if not x[b]then x[b]=1;return q end end;w=((w+1));end else v=((v+45))w=w+1 while((w<202)and(v%1172<586))do v=((v+55))local b=((w+v))if((v%1946)>973)then v=(v+15)local b=4694 if not x[b]then x[b]=1;return q end elseif not(not((v%4)~=0))then v=((v+9))local b=79236 if not x[b]then x[b]=1;return q end else v=((v+79))w=((w+1))local b=42970 if not x[b]then x[b]=1;return q end end;w=(w+1);end end;w=(w+1);end v=((v-345))if(w>82)then break;end;end;else if 19~=a then return q;else break end end end end end a=a+1 end end else break end end end end end end bd=bd+1 end local function a(b,c)local d if bp(l)==bq then d=l;else d=l(bl);end local e={}for f,h in o,d do if h~=b then e[f]=h else e[f]=c;end end if bc then return bc(bl,e)else l=e;return l;end end;local function b(...)local c=n(bl,...);local d=c[ci];local e=c[536];local f=c[ch];local h=n(2,...);local i=c[345];local j=n(3,...);local o=c[481];local c=c[776];local c=bt[ba(bx,i)];return function(...)local i,n,p,q,s,u,v,w=cq,1,-1,{},{...},(n("\35",...)-1),{},{};for x=0,u,1 do if(x>=o)then q[x-o]=s[x+1];else w[x]=s[x+1];end;end;local x,y,z,ba=(u-o+1),nil,nil,{};while true do y=f[n];z=y[304];if z<=186 then if z<=92 then if z<=45 then if 22>=z then if 10>=z then if z<=4 then if 1>=z then if z==0 then local ba;local bb;local bc;w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][w[y[151]]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];bc=y[444];bb=y[151];ba=k(w,g,bc,bb);w[y[537]]=ba;else local ba=y[537]w[ba]=w[ba](r(w,ba+1,y[444]))end;elseif z<=2 then local ba=y[537];w[ba]=w[ba]-w[ba+2];n=y[444];elseif z>3 then local ba;w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];ba=y[537]w[ba]=w[ba](r(w,ba+1,y[444]))else w[y[537]]=false;n=n+1;end;elseif z<=7 then if 5>=z then w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]]+y[151];n=n+1;y=f[n];h[y[444]]=w[y[537]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]();elseif 7~=z then local ba;w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];ba=y[537]w[ba]=w[ba](r(w,ba+1,y[444]))else w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]][y[444]]=w[y[151]];n=n+1;y=f[n];n=y[444];end;elseif 8>=z then local ba;local bb;w={};for bc=0,u,1 do if bc<o then w[bc]=s[bc+1];else break;end;end;n=n+1;y=f[n];w[y[537]]=j[y[444]];n=n+1;y=f[n];w[y[537]]=j[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];bb=y[537];ba=w[y[444]];w[bb+1]=ba;w[bb]=ba[y[151]];elseif 9<z then local ba;local bb;local bc;w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][w[y[151]]];n=n+1;y=f[n];bc=y[537]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[151]do ba=ba+1;w[bd]=bb[ba];end else w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]={};n=n+1;y=f[n];w[y[537]]={};n=n+1;y=f[n];w[y[537]][y[444]]=w[y[151]];n=n+1;y=f[n];w[y[537]]=j[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];if w[y[537]]then n=n+1;else n=y[444];end;end;elseif 16>=z then if z<=13 then if 11>=z then if(w[y[537]]~=y[151])then n=y[444];else n=n+1;end;elseif z==12 then local ba;w[y[537]]=j[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];ba=y[537]w[ba]=w[ba](r(w,ba+1,y[444]))else w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];if w[y[537]]then n=n+1;else n=y[444];end;end;elseif 14>=z then w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];if w[y[537]]then n=n+1;else n=y[444];end;elseif z~=16 then w[y[537]]=false;n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][w[y[151]]];n=n+1;y=f[n];if(w[y[537]]~=y[151])then n=n+1;else n=y[444];end;else local ba;local bb;local bc;w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][w[y[151]]];n=n+1;y=f[n];bc=y[537]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[151]do ba=ba+1;w[bd]=bb[ba];end end;elseif 19>=z then if 17>=z then w[y[537]][y[444]]=y[151];n=n+1;y=f[n];w[y[537]]={};n=n+1;y=f[n];w[y[537]][y[444]]=w[y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]][y[444]]=w[y[151]];n=n+1;y=f[n];w[y[537]][y[444]]=w[y[151]];elseif 18<z then if(w[y[537]]~=y[151])then n=y[444];else n=n+1;end;else local ba;w[y[537]]=j[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];ba=y[537]w[ba]=w[ba](r(w,ba+1,y[444]))end;elseif 20>=z then local ba;w[y[537]]=j[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];ba=y[537]w[ba]=w[ba](r(w,ba+1,y[444]))elseif z<22 then local ba=y[537];do return w[ba],w[ba+1]end else local ba;w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];ba=y[537];do return w[ba](r(w,ba+1,y[444]))end;n=n+1;y=f[n];ba=y[537];do return r(w,ba,p)end;end;elseif 33>=z then if 27>=z then if z<=24 then if 24>z then w[y[537]]=w[y[444]]*y[151];else local ba;local bb;local bc;w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][w[y[151]]];n=n+1;y=f[n];bc=y[537]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[151]do ba=ba+1;w[bd]=bb[ba];end end;elseif z<=25 then local ba,bb=0 while true do if ba<=10 then if ba<=4 then if ba<=1 then if 1>ba then bb=nil else w[y[537]]=w[y[444]][y[151]];end else if ba<=2 then n=n+1;else if 3==ba then y=f[n];else w[y[537]]=h[y[444]];end end end else if ba<=7 then if ba<=5 then n=n+1;else if ba<7 then y=f[n];else w[y[537]]=h[y[444]];end end else if ba<=8 then n=n+1;else if ba>9 then w[y[537]]=h[y[444]];else y=f[n];end end end end else if ba<=15 then if ba<=12 then if ba<12 then n=n+1;else y=f[n];end else if ba<=13 then w[y[537]]=h[y[444]];else if 14==ba then n=n+1;else y=f[n];end end end else if ba<=18 then if ba<=16 then w[y[537]]=w[y[444]];else if ba<18 then n=n+1;else y=f[n];end end else if ba<=19 then bb=y[537]else if 21>ba then w[bb](r(w,bb+1,y[444]))else break end end end end end ba=ba+1 end elseif z==26 then local ba;w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];ba=y[537]w[ba]=w[ba](r(w,ba+1,y[444]))else local ba;w[y[537]]=w[y[444]][w[y[151]]];n=n+1;y=f[n];w[y[537]]=w[y[444]];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];ba=y[537]w[ba]=w[ba](r(w,ba+1,y[444]))end;elseif z<=30 then if z<=28 then local ba=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if 0<ba then n=n+1;else w[y[537]][y[444]]=y[151];end else if ba<=2 then y=f[n];else if ba<4 then w[y[537]]={};else n=n+1;end end end else if ba<=6 then if 5<ba then w[y[537]][y[444]]=w[y[151]];else y=f[n];end else if ba<=7 then n=n+1;else if ba>8 then w[y[537]]=h[y[444]];else y=f[n];end end end end else if ba<=14 then if ba<=11 then if 10<ba then y=f[n];else n=n+1;end else if ba<=12 then w[y[537]]=w[y[444]][y[151]];else if ba==13 then n=n+1;else y=f[n];end end end else if ba<=16 then if 15<ba then n=n+1;else w[y[537]][y[444]]=w[y[151]];end else if ba<=17 then y=f[n];else if 18<ba then break else w[y[537]][y[444]]=w[y[151]];end end end end end ba=ba+1 end elseif 29==z then local ba;local bb;local bc;w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];bc=y[444];bb=y[151];ba=k(w,g,bc,bb);w[y[537]]=ba;else local ba;w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=false;n=n+1;y=f[n];ba=y[537]w[ba](w[ba+1])end;elseif z<=31 then w[y[537]]=h[y[444]];elseif z>32 then local ba;w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];ba=y[537]w[ba]=w[ba](r(w,ba+1,y[444]))else local ba=y[537];local bb=w[y[444]];w[ba+1]=bb;w[ba]=bb[w[y[151]]];end;elseif z<=39 then if 36>=z then if 34>=z then if(w[y[537]]<w[y[151]])then n=n+1;else n=y[444];end;elseif 35==z then local ba;w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]={};n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]={};n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];ba=y[537]w[ba]=w[ba]()else local ba;w[y[537]]=w[y[444]][w[y[151]]];n=n+1;y=f[n];w[y[537]]=w[y[444]];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];ba=y[537]w[ba]=w[ba](r(w,ba+1,y[444]))end;elseif z<=37 then local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if ba~=1 then bb=nil else w[y[537]]=w[y[444]];end else if ba==2 then n=n+1;else y=f[n];end end else if ba<=5 then if ba<5 then w[y[537]]=y[444];else n=n+1;end else if ba~=7 then y=f[n];else w[y[537]]=y[444];end end end else if ba<=11 then if ba<=9 then if ba~=9 then n=n+1;else y=f[n];end else if 10==ba then w[y[537]]=y[444];else n=n+1;end end else if ba<=13 then if 13~=ba then y=f[n];else bb=y[537]end else if ba~=15 then w[bb]=w[bb](r(w,bb+1,y[444]))else break end end end end ba=ba+1 end elseif 39>z then local ba;w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];ba=y[537]w[ba]=w[ba](r(w,ba+1,y[444]))else local ba;w[y[537]]=w[y[444]];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];ba=y[537]w[ba]=w[ba](r(w,ba+1,y[444]))end;elseif z<=42 then if z<=40 then w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]][y[444]]=w[y[151]];n=n+1;y=f[n];n=y[444];elseif z~=42 then local ba;w[y[537]]=j[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];ba=y[537]w[ba]=w[ba](r(w,ba+1,y[444]))else for ba=y[537],y[444],1 do w[ba]=nil;end;end;elseif 43>=z then w[y[537]]=b(d[y[444]],nil,j);elseif z~=45 then local ba;local bb;local bc;w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][w[y[151]]];n=n+1;y=f[n];bc=y[537]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[151]do ba=ba+1;w[bd]=bb[ba];end else if(y[537]<w[y[151]])then n=n+1;else n=y[444];end;end;elseif 68>=z then if z<=56 then if 50>=z then if 47>=z then if z==46 then w[y[537]]=w[y[444]][w[y[151]]];else local ba=y[537]w[ba]=w[ba](w[ba+1])end;elseif 48>=z then local ba;local bb;local bc;w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][w[y[151]]];n=n+1;y=f[n];bc=y[537]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[151]do ba=ba+1;w[bd]=bb[ba];end elseif z<50 then local ba;w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];ba=y[537]w[ba]=w[ba](w[ba+1])else w[y[537]]=w[y[444]]+w[y[151]];end;elseif z<=53 then if z<=51 then if(w[y[537]]~=y[151])then n=n+1;else n=y[444];end;elseif 53~=z then n=y[444];else local ba;w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][w[y[151]]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];ba=y[537]w[ba]=w[ba](r(w,ba+1,y[444]))end;elseif z<=54 then local ba=y[537]local bb={w[ba](w[ba+1])};local bc=0;for bd=ba,y[151]do bc=bc+1;w[bd]=bb[bc];end elseif z~=56 then local ba;w[y[537]]={};n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]][y[444]]=w[y[151]];n=n+1;y=f[n];w[y[537]]=j[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=j[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];ba=y[537]w[ba]=w[ba]()else local ba;w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=false;n=n+1;y=f[n];ba=y[537]w[ba](w[ba+1])end;elseif z<=62 then if 59>=z then if z<=57 then local ba=y[537]w[ba](r(w,(ba+1),p))elseif 58==z then w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]][y[444]]=w[y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];if(w[y[537]]~=w[y[151]])then n=n+1;else n=y[444];end;else do return w[y[537]]end end;elseif 60>=z then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if 1~=ba then bb=nil else bc=nil end else if ba<=2 then bd=nil else if ba==3 then w[y[537]]=h[y[444]];else n=n+1;end end end else if ba<=6 then if ba==5 then y=f[n];else w[y[537]]=h[y[444]];end else if ba<=7 then n=n+1;else if 9>ba then y=f[n];else w[y[537]]=w[y[444]][y[151]];end end end end else if ba<=14 then if ba<=11 then if 11>ba then n=n+1;else y=f[n];end else if ba<=12 then w[y[537]]=w[y[444]][w[y[151]]];else if ba>13 then y=f[n];else n=n+1;end end end else if ba<=16 then if 16~=ba then bd=y[537]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if ba<19 then for be=bd,y[151]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end elseif 62~=z then w[y[537]]=false;else w[y[537]]=w[y[444]]-y[151];end;elseif z<=65 then if 63>=z then w[y[537]][y[444]]=w[y[151]];elseif z>64 then w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]][y[444]]=w[y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];if(w[y[537]]~=w[y[151]])then n=n+1;else n=y[444];end;else w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][w[y[151]]];n=n+1;y=f[n];if(w[y[537]]~=y[151])then n=n+1;else n=y[444];end;end;elseif 66>=z then local ba;w[y[537]]={};n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]][y[444]]=w[y[151]];n=n+1;y=f[n];w[y[537]]=j[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=j[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];ba=y[537]w[ba]=w[ba]()elseif z~=68 then w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[537]]=j[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]];n=n+1;y=f[n];for ba=y[537],y[444],1 do w[ba]=nil;end;n=n+1;y=f[n];n=y[444];else local ba;w[y[537]]=j[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];ba=y[537]w[ba]=w[ba](w[ba+1])end;elseif z<=80 then if z<=74 then if z<=71 then if 69>=z then if w[y[537]]then n=n+1;else n=y[444];end;elseif z~=71 then local ba;w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];ba=y[537]w[ba]=w[ba](r(w,ba+1,y[444]))else local ba=y[537]w[ba]=w[ba](r(w,ba+1,p))end;elseif 72>=z then local ba;local bb,bc;local bd;w[y[537]]=w[y[444]][w[y[151]]];n=n+1;y=f[n];w[y[537]]=w[y[444]];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];bd=y[537]bb,bc=i(w[bd](r(w,bd+1,y[444])))p=bc+bd-1 ba=0;for bc=bd,p do ba=ba+1;w[bc]=bb[ba];end;elseif 74>z then local ba=w[y[151]];if not ba then n=n+1;else w[y[537]]=ba;n=y[444];end;else local ba;local bb;w[y[537]]={};n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]={};n=n+1;y=f[n];w[y[537]]={};n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]][y[444]]=w[y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]][y[444]]=w[y[151]];n=n+1;y=f[n];w[y[537]][y[444]]=w[y[151]];n=n+1;y=f[n];w[y[537]]={r({},1,y[444])};n=n+1;y=f[n];w[y[537]]=w[y[444]];n=n+1;y=f[n];bb=y[537];ba=w[bb];for bc=bb+1,y[444]do t(ba,w[bc])end;end;elseif 77>=z then if 75>=z then local ba;w[y[537]]=j[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];ba=y[537]w[ba]=w[ba](r(w,ba+1,y[444]))elseif z==76 then local ba;w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]]*y[151];n=n+1;y=f[n];w[y[537]]=w[y[444]]+w[y[151]];n=n+1;y=f[n];w[y[537]]=j[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]]+w[y[151]];n=n+1;y=f[n];ba=y[537]w[ba]=w[ba](r(w,ba+1,y[444]))else local ba;local bb;w[y[537]]={};n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]={};n=n+1;y=f[n];w[y[537]]={};n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]][y[444]]=w[y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]][y[444]]=w[y[151]];n=n+1;y=f[n];w[y[537]][y[444]]=w[y[151]];n=n+1;y=f[n];w[y[537]]={r({},1,y[444])};n=n+1;y=f[n];w[y[537]]=w[y[444]];n=n+1;y=f[n];bb=y[537];ba=w[bb];for bc=bb+1,y[444]do t(ba,w[bc])end;end;elseif z<=78 then if(w[y[537]]~=w[y[151]])then n=y[444];else n=n+1;end;elseif z~=80 then local ba=y[537]local bb,bc=i(w[ba](r(w,ba+1,y[444])))p=bc+ba-1 local bc=0;for bd=ba,p do bc=bc+1;w[bd]=bb[bc];end;else local ba;w[y[537]]=w[y[444]];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];ba=y[537]w[ba]=w[ba](r(w,ba+1,y[444]))end;elseif z<=86 then if z<=83 then if z<=81 then local ba;local bb;local bc;w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][w[y[151]]];n=n+1;y=f[n];bc=y[537]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[151]do ba=ba+1;w[bd]=bb[ba];end elseif z>82 then local ba;w={};for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=#w[y[444]];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];ba=y[537];w[ba]=w[ba]-w[ba+2];n=y[444];else w[y[537]]=w[y[444]]%w[y[151]];end;elseif 84>=z then local ba;w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]={};n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]={};n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];ba=y[537]w[ba]=w[ba]()elseif z==85 then w[y[537]]=w[y[444]]+y[151];else w[y[537]]=w[y[444]][y[151]];end;elseif 89>=z then if z<=87 then local ba=y[537];local bb=w[ba];for bc=ba+1,y[444]do t(bb,w[bc])end;elseif 89~=z then local ba;w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][w[y[151]]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];ba=y[537]w[ba]=w[ba](r(w,ba+1,y[444]))else w[y[537]]={};end;elseif 90>=z then w[y[537]]=w[y[444]]/y[151];elseif 92~=z then local ba;w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][w[y[151]]];n=n+1;y=f[n];w[y[537]]={};n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]][y[444]]=w[y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]][y[444]]=w[y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]][y[444]]=w[y[151]];n=n+1;y=f[n];ba=y[537]w[ba](r(w,ba+1,y[444]))else w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]]+y[151];n=n+1;y=f[n];h[y[444]]=w[y[537]];n=n+1;y=f[n];do return end;n=n+1;y=f[n];do return end;end;elseif z<=139 then if 115>=z then if 103>=z then if z<=97 then if z<=94 then if z==93 then local ba;w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]={};n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]={};n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];ba=y[537]w[ba]=w[ba]()else local ba;local bb;local bc;w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][w[y[151]]];n=n+1;y=f[n];bc=y[537]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[151]do ba=ba+1;w[bd]=bb[ba];end end;elseif z<=95 then w[y[537]]=#w[y[444]];elseif z~=97 then local ba;local bb;local bc;w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][w[y[151]]];n=n+1;y=f[n];bc=y[537]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[151]do ba=ba+1;w[bd]=bb[ba];end else local ba;local bb;w[y[537]]={};n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]={};n=n+1;y=f[n];w[y[537]]={};n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]][y[444]]=w[y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]][y[444]]=w[y[151]];n=n+1;y=f[n];w[y[537]][y[444]]=w[y[151]];n=n+1;y=f[n];w[y[537]]={r({},1,y[444])};n=n+1;y=f[n];w[y[537]]=w[y[444]];n=n+1;y=f[n];bb=y[537];ba=w[bb];for bc=bb+1,y[444]do t(ba,w[bc])end;end;elseif z<=100 then if 98>=z then local ba;w[y[537]]=j[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];ba=y[537]w[ba]=w[ba](w[ba+1])elseif 100>z then if(w[y[537]]~=y[151])then n=n+1;else n=y[444];end;else w[y[537]]=w[y[444]];end;elseif 101>=z then local ba;w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];ba=y[537]w[ba]=w[ba](w[ba+1])elseif 102<z then w[y[537]]=w[y[444]]%w[y[151]];else w[y[537]]=true;end;elseif 109>=z then if 106>=z then if z<=104 then w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];if w[y[537]]then n=n+1;else n=y[444];end;elseif z>105 then local ba;w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=false;n=n+1;y=f[n];ba=y[537]w[ba](w[ba+1])else j[y[444]]=w[y[537]];end;elseif z<=107 then local ba;w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];ba=y[537]w[ba]=w[ba](r(w,ba+1,y[444]))elseif z>108 then local ba;w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];ba=y[537]w[ba]=w[ba](r(w,ba+1,y[444]))else w[y[537]][y[444]]=y[151];n=n+1;y=f[n];w[y[537]]={};n=n+1;y=f[n];w[y[537]][y[444]]=w[y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]][y[444]]=w[y[151]];n=n+1;y=f[n];w[y[537]][y[444]]=w[y[151]];end;elseif z<=112 then if 110>=z then local ba=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if 0==ba then w[y[537]]={};else n=n+1;end else if ba<=2 then y=f[n];else if ba<4 then w[y[537]]={};else n=n+1;end end end else if ba<=6 then if 6~=ba then y=f[n];else w[y[537]]={};end else if ba<=7 then n=n+1;else if 9~=ba then y=f[n];else w[y[537]]={};end end end end else if ba<=14 then if ba<=11 then if ba~=11 then n=n+1;else y=f[n];end else if ba<=12 then w[y[537]]={};else if ba>13 then y=f[n];else n=n+1;end end end else if ba<=16 then if ba<16 then w[y[537]]=y[444];else n=n+1;end else if ba<=17 then y=f[n];else if ba<19 then w[y[537]]=w[y[444]][w[y[151]]];else break end end end end end ba=ba+1 end elseif 111==z then local ba;w[y[537]]=j[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];ba=y[537]w[ba]=w[ba](r(w,ba+1,y[444]))else local ba;local bb;local bc;w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][w[y[151]]];n=n+1;y=f[n];bc=y[537]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[151]do ba=ba+1;w[bd]=bb[ba];end end;elseif 113>=z then do return end;elseif 114==z then w[y[537]]={};else local ba;w={};for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=j[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];ba=y[537]w[ba]=w[ba](r(w,ba+1,y[444]))end;elseif z<=127 then if(z<=121)then if(z==118 or z<118)then if(116==z or 116>z)then local ba=y[537]local bb={w[ba](r(w,ba+1,y[444]))};local bc=0;for bd=ba,y[151]do bc=bc+1;w[bd]=bb[bc];end;elseif z>117 then local ba,bb,bc,bd,be,bf=0 while true do if ba<=3 then if ba<=1 then if 0<ba then bc=y[151]else bb=y[537]end else if 3>ba then bd=bb+2 else be={w[bb](w[bb+1],w[bd])}end end else if ba<=5 then if ba~=5 then for bg=1,bc do w[bd+bg]=be[bg];end else bf=w[bb+3]end else if 6<ba then break else if bf then w[bd]=bf;n=y[444];else n=n+1 end;end end end ba=ba+1 end else local ba,bb=0 while true do if ba<=29 then if ba<=14 then if ba<=6 then if ba<=2 then if ba<=0 then bb=nil else if 1<ba then n=n+1;else w[y[537]]={};end end else if ba<=4 then if 3==ba then y=f[n];else w[y[537]]=y[444];end else if 6>ba then n=n+1;else y=f[n];end end end else if ba<=10 then if ba<=8 then if 7<ba then n=n+1;else w[y[537]][w[y[444]]]=w[y[151]];end else if 10~=ba then y=f[n];else w[y[537]]=y[444];end end else if ba<=12 then if ba<12 then n=n+1;else y=f[n];end else if ba<14 then w[y[537]][w[y[444]]]=w[y[151]];else n=n+1;end end end end else if ba<=21 then if ba<=17 then if ba<=15 then y=f[n];else if ba<17 then w[y[537]]=y[444];else n=n+1;end end else if ba<=19 then if ba==18 then y=f[n];else w[y[537]][w[y[444]]]=w[y[151]];end else if 20<ba then y=f[n];else n=n+1;end end end else if ba<=25 then if ba<=23 then if ba<23 then w[y[537]]=y[444];else n=n+1;end else if 24==ba then y=f[n];else w[y[537]][w[y[444]]]=w[y[151]];end end else if ba<=27 then if ba<27 then n=n+1;else y=f[n];end else if ba<29 then w[y[537]]=y[444];else n=n+1;end end end end end else if ba<=44 then if ba<=36 then if ba<=32 then if ba<=30 then y=f[n];else if 32>ba then w[y[537]][w[y[444]]]=w[y[151]];else n=n+1;end end else if ba<=34 then if 34>ba then y=f[n];else w[y[537]]=y[444];end else if ba~=36 then n=n+1;else y=f[n];end end end else if ba<=40 then if ba<=38 then if ba>37 then n=n+1;else w[y[537]][w[y[444]]]=w[y[151]];end else if 39==ba then y=f[n];else w[y[537]]={};end end else if ba<=42 then if 41<ba then y=f[n];else n=n+1;end else if ba<44 then w[y[537]]=y[444];else n=n+1;end end end end else if ba<=52 then if ba<=48 then if ba<=46 then if 46>ba then y=f[n];else w[y[537]][w[y[444]]]=w[y[151]];end else if 47==ba then n=n+1;else y=f[n];end end else if ba<=50 then if 50~=ba then w[y[537]]=j[y[444]];else n=n+1;end else if ba>51 then w[y[537]]=w[y[444]];else y=f[n];end end end else if ba<=56 then if ba<=54 then if ba>53 then y=f[n];else n=n+1;end else if 55==ba then w[y[537]]=w[y[444]];else n=n+1;end end else if ba<=58 then if ba>57 then bb=y[537]else y=f[n];end else if 59==ba then w[bb](r(w,bb+1,y[444]))else break end end end end end end ba=ba+1 end end;elseif(119>=z)then local ba=y[537];w[ba]=(w[ba]-w[(ba+2)]);n=y[444];elseif not(121==z)then local ba=y[537]local bb={w[ba](r(w,ba+1,p))};local bc=0;for bd=ba,y[151]do bc=(bc+1);w[bd]=bb[bc];end else local ba=y[537];local bb=w[ba];for bc=ba+1,p do t(bb,w[bc])end;end;elseif(124>z or 124==z)then if(122==z or 122>z)then w[y[537]]=false;n=(n+1);elseif not(124==z)then if(w[y[537]]==w[y[151]]or w[y[537]]<w[y[151]])then n=n+1;else n=y[444];end;else local ba=y[537];do return r(w,ba,p)end;end;elseif(z<=125)then h[y[444]]=w[y[537]];elseif z==126 then local ba,bb=0 while true do if ba<=16 then if ba<=7 then if ba<=3 then if ba<=1 then if 1~=ba then bb=nil else w[y[537]]=w[y[444]][y[151]];end else if ba<3 then n=n+1;else y=f[n];end end else if ba<=5 then if 5>ba then w[y[537]]=h[y[444]];else n=n+1;end else if 7>ba then y=f[n];else w[y[537]]=w[y[444]][y[151]];end end end else if ba<=11 then if ba<=9 then if 8==ba then n=n+1;else y=f[n];end else if 11~=ba then w[y[537]]={};else n=n+1;end end else if ba<=13 then if 13>ba then y=f[n];else w[y[537]]=h[y[444]];end else if ba<=14 then n=n+1;else if 16~=ba then y=f[n];else w[y[537]]=w[y[444]][y[151]];end end end end end else if ba<=24 then if ba<=20 then if ba<=18 then if 18>ba then n=n+1;else y=f[n];end else if 20~=ba then w[y[537]]=h[y[444]];else n=n+1;end end else if ba<=22 then if ba==21 then y=f[n];else w[y[537]]={};end else if ba>23 then y=f[n];else n=n+1;end end end else if ba<=28 then if ba<=26 then if ba==25 then w[y[537]]=h[y[444]];else n=n+1;end else if 28>ba then y=f[n];else w[y[537]]=w[y[444]][y[151]];end end else if ba<=30 then if ba<30 then n=n+1;else y=f[n];end else if ba<=31 then bb=y[537]else if ba~=33 then w[bb]=w[bb]()else break end end end end end end ba=ba+1 end else if(y[537]<w[y[151]])then n=n+1;else n=y[444];end;end;elseif 133>=z then if z<=130 then if z<=128 then local ba;w[y[537]]=j[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];ba=y[537]w[ba]=w[ba](r(w,ba+1,y[444]))elseif z<130 then local ba;w[y[537]]=w[y[444]][w[y[151]]];n=n+1;y=f[n];w[y[537]]=w[y[444]];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];ba=y[537]w[ba]=w[ba](r(w,ba+1,y[444]))else local ba;local bb;local bc;w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][w[y[151]]];n=n+1;y=f[n];bc=y[537]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[151]do ba=ba+1;w[bd]=bb[ba];end end;elseif z<=131 then local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if ba<1 then bb=nil else w[y[537]]=w[y[444]][y[151]];end else if 3~=ba then n=n+1;else y=f[n];end end else if ba<=5 then if 4==ba then w[y[537]]=w[y[444]][y[151]];else n=n+1;end else if ba<=6 then y=f[n];else if 7<ba then n=n+1;else w[y[537]]=w[y[444]][y[151]];end end end end else if ba<=13 then if ba<=10 then if 10>ba then y=f[n];else w[y[537]]=w[y[444]][y[151]];end else if ba<=11 then n=n+1;else if ba<13 then y=f[n];else w[y[537]]=w[y[444]][y[151]];end end end else if ba<=15 then if ba~=15 then n=n+1;else y=f[n];end else if ba<=16 then bb=y[537]else if 18~=ba then w[bb]=w[bb](w[bb+1])else break end end end end end ba=ba+1 end elseif z~=133 then local ba;local bb;local bc;w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][w[y[151]]];n=n+1;y=f[n];bc=y[537]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[151]do ba=ba+1;w[bd]=bb[ba];end else local ba;local bb;local bc;w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][w[y[151]]];n=n+1;y=f[n];bc=y[537]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[151]do ba=ba+1;w[bd]=bb[ba];end end;elseif 136>=z then if 134>=z then local ba=y[444];local bb=y[151];local ba=k(w,g,ba,bb);w[y[537]]=ba;elseif z<136 then n=y[444];else local ba=y[537]w[ba]=w[ba]()end;elseif 137>=z then w[y[537]]=w[y[444]]-w[y[151]];elseif z>138 then local ba;w={};for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][w[y[151]]];n=n+1;y=f[n];ba=y[537]w[ba](w[ba+1])else local ba;w[y[537]]=w[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]];n=n+1;y=f[n];ba=y[537]w[ba]=w[ba](r(w,ba+1,y[444]))end;elseif z<=162 then if 150>=z then if 144>=z then if 141>=z then if(z<141)then w[y[537]]=(w[y[444]]-y[151]);else local ba,bb,bc,bd,be,bf=0 while true do if ba<=3 then if ba<=1 then if 0==ba then bb=y[537]else bc=y[151]end else if ba==2 then bd=bb+2 else be={w[bb](w[bb+1],w[bd])}end end else if ba<=5 then if ba>4 then bf=w[bb+3]else for bb=1,bc do w[bd+bb]=be[bb];end end else if ba~=7 then if bf then w[bd]=bf;n=y[444];else n=n+1 end;else break end end end ba=ba+1 end end;elseif 142>=z then local ba,bb=0 while true do if(ba<=11)then if(ba<5 or ba==5)then if(ba==2 or ba<2)then if(ba==0 or ba<0)then bb=nil else if(1<ba)then n=n+1;else w[y[537]]=w[y[444]][y[151]];end end else if ba<=3 then y=f[n];else if(5>ba)then w[y[537]]=h[y[444]];else n=n+1;end end end else if(ba<=8)then if(ba<6 or ba==6)then y=f[n];else if(7<ba)then n=(n+1);else w[y[537]]=w[y[444]][y[151]];end end else if ba<=9 then y=f[n];else if(10==ba)then w[y[537]]=h[y[444]];else n=n+1;end end end end else if ba<=17 then if(ba<14 or ba==14)then if ba<=12 then y=f[n];else if(ba>13)then n=n+1;else w[y[537]]=w[y[444]][y[151]];end end else if ba<=15 then y=f[n];else if not(17==ba)then w[y[537]]=h[y[444]];else n=n+1;end end end else if(ba==20 or ba<20)then if(ba<18 or ba==18)then y=f[n];else if(ba<20)then w[y[537]]=w[y[444]][y[151]];else n=(n+1);end end else if(ba<=22)then if ba>21 then bb=y[537]else y=f[n];end else if not(ba==24)then w[bb]=w[bb](r(w,bb+1,y[444]))else break end end end end end ba=(ba+1)end elseif(144>z)then local ba,bb=0 while true do if ba<=12 then if ba<=5 then if ba<=2 then if ba<=0 then bb=nil else if ba~=2 then w={};else for bc=0,u,1 do if bc<o then w[bc]=s[bc+1];else break;end;end;end end else if ba<=3 then n=n+1;else if ba==4 then y=f[n];else w[y[537]]=false;end end end else if ba<=8 then if ba<=6 then n=n+1;else if 8>ba then y=f[n];else w[y[537]]=j[y[444]];end end else if ba<=10 then if ba>9 then y=f[n];else n=n+1;end else if ba~=12 then for bc=y[537],y[444],1 do w[bc]=nil;end;else n=n+1;end end end end else if ba<=18 then if ba<=15 then if ba<=13 then y=f[n];else if ba<15 then w[y[537]]=h[y[444]];else n=n+1;end end else if ba<=16 then y=f[n];else if 17<ba then n=n+1;else w[y[537]]=w[y[444]][y[151]];end end end else if ba<=21 then if ba<=19 then y=f[n];else if 20==ba then w[y[537]]=w[y[444]];else n=n+1;end end else if ba<=23 then if ba<23 then y=f[n];else bb=y[537]end else if ba>24 then break else w[bb]=w[bb](w[bb+1])end end end end end ba=ba+1 end else local ba,bb,bc,bd=0 while true do if ba<=15 then if ba<=7 then if ba<=3 then if ba<=1 then if 0==ba then bb=nil else bc=nil end else if 2<ba then w[y[537]]=h[y[444]];else bd=nil end end else if ba<=5 then if ba<5 then n=n+1;else y=f[n];end else if ba==6 then w[y[537]]=w[y[444]][y[151]];else n=n+1;end end end else if ba<=11 then if ba<=9 then if ba>8 then w[y[537]]=h[y[444]];else y=f[n];end else if ba==10 then n=n+1;else y=f[n];end end else if ba<=13 then if 13~=ba then w[y[537]]=w[y[444]][y[151]];else n=n+1;end else if 14<ba then w[y[537]]=w[y[444]][w[y[151]]];else y=f[n];end end end end else if ba<=23 then if ba<=19 then if ba<=17 then if ba<17 then n=n+1;else y=f[n];end else if 18==ba then w[y[537]]=h[y[444]];else n=n+1;end end else if ba<=21 then if 20==ba then y=f[n];else w[y[537]]=w[y[444]][y[151]];end else if 23~=ba then n=n+1;else y=f[n];end end end else if ba<=27 then if ba<=25 then if ba~=25 then w[y[537]]=w[y[444]][y[151]];else n=n+1;end else if ba<27 then y=f[n];else bd=y[444];end end else if ba<=29 then if ba<29 then bc=y[151];else bb=k(w,g,bd,bc);end else if ba<31 then w[y[537]]=bb;else break end end end end end ba=ba+1 end end;elseif z<=147 then if z<=145 then local ba=d[y[444]];local bb={};local bc={};for bd=1,y[151]do n=n+1;local be=f[n];if be[304]==308 then bc[bd-1]={w,be[444]};else bc[bd-1]={h,be[444]};end;v[#v+1]=bc;end;m(bb,{['\95\95\105\110\100\101\120']=function(bd,bd)local bd=bc[bd];return bd[1][bd[2]];end,['\95\95\110\101\119\105\110\100\101\120']=function(bd,bd,be)local bc=bc[bd]bc[1][bc[2]]=be;end;});w[y[537]]=b(ba,bb,j);elseif z~=147 then w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];if w[y[537]]then n=n+1;else n=y[444];end;else local ba;local bb;w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=j[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];bb=y[537];ba=w[bb];for bc=bb+1,y[444]do t(ba,w[bc])end;end;elseif z<=148 then w[y[537]]();elseif z<150 then local ba;w[y[537]]=w[y[444]]%w[y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]]+y[151];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]];n=n+1;y=f[n];ba=y[537]w[ba]=w[ba](r(w,ba+1,y[444]))else local ba;local bb;local bc;w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][w[y[151]]];n=n+1;y=f[n];bc=y[537]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[151]do ba=ba+1;w[bd]=bb[ba];end end;elseif z<=156 then if z<=153 then if 151>=z then local ba=y[537]local bb={}for bc=1,#v do local bd=v[bc]for be=1,#bd do local bd=bd[be]local be,be=bd[1],bd[2]if be>=ba then bb[be]=w[be]bd[1]=bb v[bc]=nil;end end end elseif 152<z then local ba=y[537]w[ba]=w[ba](r(w,ba+1,y[444]))else local ba;w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]={};n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]={};n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];ba=y[537]w[ba]=w[ba]()end;elseif 154>=z then local ba=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if ba~=1 then w[y[537]]=w[y[444]][y[151]];else n=n+1;end else if 3>ba then y=f[n];else w[y[537]][y[444]]=w[y[151]];end end else if ba<=5 then if 4<ba then y=f[n];else n=n+1;end else if ba<7 then w[y[537]]=w[y[444]][y[151]];else n=n+1;end end end else if ba<=11 then if ba<=9 then if 9~=ba then y=f[n];else w[y[537]]=h[y[444]];end else if 10==ba then n=n+1;else y=f[n];end end else if ba<=13 then if ba==12 then w[y[537]]=w[y[444]][y[151]];else n=n+1;end else if ba<=14 then y=f[n];else if 15==ba then if(w[y[537]]~=w[y[151]])then n=n+1;else n=y[444];end;else break end end end end end ba=ba+1 end elseif 155<z then local ba;w[y[537]]=w[y[444]];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];ba=y[537]w[ba]=w[ba](r(w,ba+1,y[444]))else if(y[537]<=w[y[151]])then n=n+1;else n=y[444];end;end;elseif z<=159 then if(157>z or 157==z)then local ba=y[537];local bb,bc,bd=w[ba],w[ba+1],w[ba+2];local bb=(bb+bd);w[ba]=bb;if bd>0 and bb<=bc or bd<0 and bb>=bc then n=y[444];w[ba+3]=bb;end;elseif 159~=z then local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if ba~=1 then bb=nil else w[y[537]]=w[y[444]][y[151]];end else if 2==ba then n=n+1;else y=f[n];end end else if ba<=5 then if ba<5 then w[y[537]]=w[y[444]][y[151]];else n=n+1;end else if ba<=6 then y=f[n];else if 7==ba then w[y[537]]=w[y[444]][y[151]];else n=n+1;end end end end else if ba<=13 then if ba<=10 then if ba==9 then y=f[n];else w[y[537]]=w[y[444]][y[151]];end else if ba<=11 then n=n+1;else if 13>ba then y=f[n];else w[y[537]]=w[y[444]][y[151]];end end end else if ba<=15 then if 14==ba then n=n+1;else y=f[n];end else if ba<=16 then bb=y[537]else if ba==17 then w[bb]=w[bb](w[bb+1])else break end end end end end ba=ba+1 end else local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba<1 then bb=nil else bc=nil end else if ba<=2 then bd=nil else if 4~=ba then w[y[537]]=h[y[444]];else n=n+1;end end end else if ba<=6 then if ba==5 then y=f[n];else w[y[537]]=h[y[444]];end else if ba<=7 then n=n+1;else if 8<ba then w[y[537]]=w[y[444]][y[151]];else y=f[n];end end end end else if ba<=14 then if ba<=11 then if 10==ba then n=n+1;else y=f[n];end else if ba<=12 then w[y[537]]=w[y[444]][w[y[151]]];else if 14~=ba then n=n+1;else y=f[n];end end end else if ba<=16 then if ba~=16 then bd=y[537]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if ba<19 then for be=bd,y[151]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end end;elseif z<=160 then local ba;w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];ba=y[537]w[ba]=w[ba](r(w,ba+1,y[444]))elseif 161<z then local ba;w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];ba=y[537]w[ba]=w[ba](r(w,ba+1,y[444]))else local ba;w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];ba=y[537]w[ba]=w[ba](r(w,ba+1,y[444]))end;elseif 174>=z then if 168>=z then if 165>=z then if 163>=z then if(w[y[537]]<w[y[151]])then n=n+1;else n=y[444];end;elseif 164==z then local ba;w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]][w[y[444]]]=w[y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]][w[y[444]]]=w[y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]][w[y[444]]]=w[y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]][w[y[444]]]=w[y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]][w[y[444]]]=w[y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]][w[y[444]]]=w[y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]][w[y[444]]]=w[y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]][w[y[444]]]=w[y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]][w[y[444]]]=w[y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]][w[y[444]]]=w[y[151]];n=n+1;y=f[n];w[y[537]]=j[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]];n=n+1;y=f[n];ba=y[537]w[ba]=w[ba](w[ba+1])else local ba;local bb;local bc;w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][w[y[151]]];n=n+1;y=f[n];bc=y[537]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[151]do ba=ba+1;w[bd]=bb[ba];end end;elseif z<=166 then w[y[537]]=(w[y[444]]-w[y[151]]);elseif z==167 then local ba;local bb;local bc;w[y[537]]=j[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];bc=y[537]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[151]do ba=ba+1;w[bd]=bb[ba];end else local ba;local bb;local bc;w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][w[y[151]]];n=n+1;y=f[n];bc=y[537]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[151]do ba=ba+1;w[bd]=bb[ba];end end;elseif z<=171 then if z<=169 then local ba;w[y[537]]={};n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]][y[444]]=w[y[151]];n=n+1;y=f[n];w[y[537]]=j[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=j[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];ba=y[537]w[ba]=w[ba]()elseif 170==z then local ba;w[y[537]]=j[y[444]];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=w[y[444]][w[y[151]]];n=n+1;y=f[n];w[y[537]]=w[y[444]];n=n+1;y=f[n];ba=y[537]w[ba]=w[ba](w[ba+1])else local ba=y[537];local bb=w[y[444]];w[ba+1]=bb;w[ba]=bb[w[y[151]]];end;elseif z<=172 then local ba;local bb;local bc;w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][w[y[151]]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];bc=y[444];bb=y[151];ba=k(w,g,bc,bb);w[y[537]]=ba;elseif 174>z then local ba=y[537]local bb,bc=i(w[ba](r(w,ba+1,y[444])))p=bc+ba-1 local bc=0;for bd=ba,p do bc=bc+1;w[bd]=bb[bc];end;else local ba=y[537]local bb={w[ba](r(w,ba+1,y[444]))};local bc=0;for bd=ba,y[151]do bc=bc+1;w[bd]=bb[bc];end;end;elseif 180>=z then if 177>=z then if z<=175 then local ba;w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];ba=y[537]w[ba]=w[ba](r(w,ba+1,y[444]))elseif 176<z then w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]][y[444]]=w[y[151]];n=n+1;y=f[n];n=y[444];else local ba;local bb,bc;local bd;w[y[537]]=w[y[444]];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];bd=y[537]bb,bc=i(w[bd](r(w,bd+1,y[444])))p=bc+bd-1 ba=0;for bc=bd,p do ba=ba+1;w[bc]=bb[ba];end;end;elseif 178>=z then local ba;local bb;local bc;w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][w[y[151]]];n=n+1;y=f[n];bc=y[537]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[151]do ba=ba+1;w[bd]=bb[ba];end elseif z~=180 then a(c,e);else local ba;w[y[537]]=j[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];ba=y[537]w[ba]=w[ba](w[ba+1])end;elseif 183>=z then if 181>=z then w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]={};n=n+1;y=f[n];w[y[537]]={};n=n+1;y=f[n];w[y[537]][y[444]]=w[y[151]];n=n+1;y=f[n];w[y[537]]=j[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];if w[y[537]]then n=n+1;else n=y[444];end;elseif 182<z then local ba;local bb,bc;local bd;w[y[537]]=j[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];bd=y[537]bb,bc=i(w[bd](r(w,bd+1,y[444])))p=bc+bd-1 ba=0;for bc=bd,p do ba=ba+1;w[bc]=bb[ba];end;else local ba;w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];ba=y[537]w[ba]=w[ba](w[ba+1])end;elseif 184>=z then local ba=y[537];local bb=w[ba];for bc=ba+1,p do t(bb,w[bc])end;elseif z<186 then w[y[537]]=true;else local ba;local bb;w[y[537]]={};n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]={};n=n+1;y=f[n];w[y[537]]={};n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]][y[444]]=w[y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]][y[444]]=w[y[151]];n=n+1;y=f[n];w[y[537]][y[444]]=w[y[151]];n=n+1;y=f[n];w[y[537]]={r({},1,y[444])};n=n+1;y=f[n];w[y[537]]=w[y[444]];n=n+1;y=f[n];bb=y[537];ba=w[bb];for bc=bb+1,y[444]do t(ba,w[bc])end;end;elseif 280>=z then if(233==z or 233>z)then if(z==209 or z<209)then if(z==197 or z<197)then if(191>z or 191==z)then if(188==z or 188>z)then if(z<188)then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if 0<ba then bc=nil else bb=nil end else if ba<=2 then bd=nil else if 4>ba then w[y[537]]=j[y[444]];else n=n+1;end end end else if ba<=6 then if 6>ba then y=f[n];else w[y[537]]=w[y[444]][y[151]];end else if ba<=7 then n=n+1;else if 8==ba then y=f[n];else w[y[537]]=w[y[444]][y[151]];end end end end else if ba<=14 then if ba<=11 then if 10==ba then n=n+1;else y=f[n];end else if ba<=12 then w[y[537]]=w[y[444]][y[151]];else if ba>13 then y=f[n];else n=n+1;end end end else if ba<=16 then if ba~=16 then bd=y[537]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if ba==18 then for be=bd,y[151]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end else local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if 0<ba then w[y[537]][y[444]]=w[y[151]];else bb=nil end else if ba==2 then n=n+1;else y=f[n];end end else if ba<=5 then if 4==ba then w[y[537]]={};else n=n+1;end else if 6==ba then y=f[n];else w[y[537]][y[444]]=y[151];end end end else if ba<=11 then if ba<=9 then if ba>8 then y=f[n];else n=n+1;end else if ba<11 then w[y[537]][y[444]]=w[y[151]];else n=n+1;end end else if ba<=13 then if 12<ba then bb=y[537]else y=f[n];end else if ba<15 then w[bb]=w[bb](r(w,bb+1,y[444]))else break end end end end ba=ba+1 end end;elseif(189>z or 189==z)then a(c,e);elseif not(191==z)then local ba=y[537]w[ba]=w[ba](w[(ba+1)])else local ba=d[y[444]];local bb={};local bc={};for bd=1,y[151]do n=n+1;local be=f[n];if be[304]==308 then bc[bd-1]={w,be[444],nil,nil,nil};else bc[bd-1]={h,be[444],nil,nil};end;v[(#v+1)]=bc;end;m(bb,{['\95\95\105\110\100\101\120']=function(m,m)local m=bc[m];return m[1][m[2]];end,['\95\95\110\101\119\105\110\100\101\120']=function(m,m,bd)local m=bc[m]m[1][m[2]]=bd;end;});w[y[537]]=b(ba,bb,j);end;elseif(z==194 or z<194)then if(z<192 or z==192)then local m=0 while true do if m<=8 then if m<=3 then if m<=1 then if 0==m then a(c,e);else n=n+1;end else if m>2 then w={};else y=f[n];end end else if m<=5 then if m<5 then for a=0,u,1 do if a<o then w[a]=s[a+1];else break;end;end;else n=n+1;end else if m<=6 then y=f[n];else if 8~=m then w[y[537]]=y[444];else n=n+1;end end end end else if m<=12 then if m<=10 then if m==9 then y=f[n];else w[y[537]]=j[y[444]];end else if 12>m then n=n+1;else y=f[n];end end else if m<=14 then if m==13 then w[y[537]]=j[y[444]];else n=n+1;end else if m<=15 then y=f[n];else if m==16 then w[y[537]]=w[y[444]][y[151]];else break end end end end end m=m+1 end elseif not(193~=z)then w[y[537]]=y[444];else local a,c,e,m=0 while true do if a<=9 then if a<=4 then if a<=1 then if a<1 then c=nil else e=nil end else if a<=2 then m=nil else if 3<a then n=n+1;else w[y[537]]=h[y[444]];end end end else if a<=6 then if 6>a then y=f[n];else w[y[537]]=h[y[444]];end else if a<=7 then n=n+1;else if a>8 then w[y[537]]=w[y[444]][y[151]];else y=f[n];end end end end else if a<=14 then if a<=11 then if 11~=a then n=n+1;else y=f[n];end else if a<=12 then w[y[537]]=w[y[444]][w[y[151]]];else if a<14 then n=n+1;else y=f[n];end end end else if a<=16 then if 16>a then m=y[537]else e={w[m](w[m+1])};end else if a<=17 then c=0;else if 18==a then for ba=m,y[151]do c=c+1;w[ba]=e[c];end else break end end end end end a=a+1 end end;elseif 195>=z then local a,c=0 while true do if a<=8 then if a<=3 then if a<=1 then if a~=1 then c=nil else w[y[537]]=w[y[444]][y[151]];end else if a>2 then y=f[n];else n=n+1;end end else if a<=5 then if 5>a then w[y[537]]=w[y[444]][y[151]];else n=n+1;end else if a<=6 then y=f[n];else if 7<a then n=n+1;else w[y[537]]=w[y[444]][y[151]];end end end end else if a<=13 then if a<=10 then if a>9 then w[y[537]]=w[y[444]][y[151]];else y=f[n];end else if a<=11 then n=n+1;else if 13>a then y=f[n];else w[y[537]]=false;end end end else if a<=15 then if a~=15 then n=n+1;else y=f[n];end else if a<=16 then c=y[537]else if a~=18 then w[c](w[c+1])else break end end end end end a=a+1 end elseif(z>196)then local a=0 while true do if a<=14 then if a<=6 then if a<=2 then if a<=0 then w={};else if a<2 then for c=0,u,1 do if c<o then w[c]=s[c+1];else break;end;end;else n=n+1;end end else if a<=4 then if a<4 then y=f[n];else w[y[537]]=h[y[444]];end else if a>5 then y=f[n];else n=n+1;end end end else if a<=10 then if a<=8 then if a<8 then w[y[537]]=w[y[444]][y[151]];else n=n+1;end else if 10>a then y=f[n];else w[y[537]]=h[y[444]];end end else if a<=12 then if a==11 then n=n+1;else y=f[n];end else if a==13 then w[y[537]]={};else n=n+1;end end end end else if a<=21 then if a<=17 then if a<=15 then y=f[n];else if a<17 then w[y[537]]={};else n=n+1;end end else if a<=19 then if 19>a then y=f[n];else w[y[537]][y[444]]=w[y[151]];end else if 21>a then n=n+1;else y=f[n];end end end else if a<=25 then if a<=23 then if a~=23 then w[y[537]]=j[y[444]];else n=n+1;end else if 24<a then w[y[537]]=w[y[444]][y[151]];else y=f[n];end end else if a<=27 then if a~=27 then n=n+1;else y=f[n];end else if 28<a then break else if w[y[537]]then n=n+1;else n=y[444];end;end end end end end a=a+1 end else w[y[537]]=y[444];end;elseif(z<203 or z==203)then if(z==200 or z<200)then if 198>=z then j[y[444]]=w[y[537]];elseif(z==199)then local a,c,e,m=0 while true do if a<=9 then if a<=4 then if a<=1 then if 1>a then c=nil else e=nil end else if a<=2 then m=nil else if a<4 then w[y[537]]=h[y[444]];else n=n+1;end end end else if a<=6 then if 5==a then y=f[n];else w[y[537]]=h[y[444]];end else if a<=7 then n=n+1;else if 9~=a then y=f[n];else w[y[537]]=w[y[444]][y[151]];end end end end else if a<=14 then if a<=11 then if 10==a then n=n+1;else y=f[n];end else if a<=12 then w[y[537]]=w[y[444]][w[y[151]]];else if 13<a then y=f[n];else n=n+1;end end end else if a<=16 then if 16>a then m=y[537]else e={w[m](w[m+1])};end else if a<=17 then c=0;else if 18==a then for ba=m,y[151]do c=c+1;w[ba]=e[c];end else break end end end end end a=a+1 end else local a=y[537];local c=w[y[444]];w[a+1]=c;w[a]=c[y[151]];end;elseif(z==201 or z<201)then local a,c=0 while true do if a<=13 then if a<=6 then if a<=2 then if a<=0 then c=nil else if 1<a then n=n+1;else w[y[537]]={};end end else if a<=4 then if 4~=a then y=f[n];else w[y[537]]=h[y[444]];end else if 5<a then y=f[n];else n=n+1;end end end else if a<=9 then if a<=7 then w[y[537]]=w[y[444]][y[151]];else if 8<a then y=f[n];else n=n+1;end end else if a<=11 then if 10<a then n=n+1;else w[y[537]][y[444]]=w[y[151]];end else if 12==a then y=f[n];else w[y[537]]=j[y[444]];end end end end else if a<=20 then if a<=16 then if a<=14 then n=n+1;else if 15<a then w[y[537]]=w[y[444]][y[151]];else y=f[n];end end else if a<=18 then if a>17 then y=f[n];else n=n+1;end else if a~=20 then w[y[537]]=j[y[444]];else n=n+1;end end end else if a<=23 then if a<=21 then y=f[n];else if a==22 then w[y[537]]=w[y[444]][y[151]];else n=n+1;end end else if a<=25 then if 25>a then y=f[n];else c=y[537]end else if 26==a then w[c]=w[c]()else break end end end end end a=a+1 end elseif(z<203)then local a,c=0 while true do if a<=12 then if a<=5 then if a<=2 then if a<=0 then c=nil else if 1<a then for e=0,u,1 do if e<o then w[e]=s[e+1];else break;end;end;else w={};end end else if a<=3 then n=n+1;else if 5>a then y=f[n];else w[y[537]]=h[y[444]];end end end else if a<=8 then if a<=6 then n=n+1;else if 8>a then y=f[n];else w[y[537]]=j[y[444]];end end else if a<=10 then if a>9 then y=f[n];else n=n+1;end else if a<12 then w[y[537]]=w[y[444]][y[151]];else n=n+1;end end end end else if a<=18 then if a<=15 then if a<=13 then y=f[n];else if 14<a then n=n+1;else w[y[537]]=y[444];end end else if a<=16 then y=f[n];else if a==17 then w[y[537]]=y[444];else n=n+1;end end end else if a<=21 then if a<=19 then y=f[n];else if a<21 then w[y[537]]=y[444];else n=n+1;end end else if a<=23 then if a~=23 then y=f[n];else c=y[537]end else if a==24 then w[c]=w[c](r(w,c+1,y[444]))else break end end end end end a=a+1 end else if w[y[537]]then n=(n+1);else n=y[444];end;end;elseif(z<=206)then if z<=204 then local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if 1>a then c=nil else w[y[537]]=h[y[444]];end else if a==2 then n=n+1;else y=f[n];end end else if a<=5 then if a==4 then w[y[537]]=w[y[444]][y[151]];else n=n+1;end else if 7>a then y=f[n];else w[y[537]]=y[444];end end end else if a<=11 then if a<=9 then if 9>a then n=n+1;else y=f[n];end else if 11~=a then w[y[537]]=y[444];else n=n+1;end end else if a<=13 then if a~=13 then y=f[n];else c=y[537]end else if a<15 then w[c]=w[c](r(w,c+1,y[444]))else break end end end end a=a+1 end elseif not(z==206)then local a,c=0 while true do if a<=13 then if a<=6 then if a<=2 then if a<=0 then c=nil else if 1<a then n=n+1;else w[y[537]]={};end end else if a<=4 then if 3==a then y=f[n];else w[y[537]]=h[y[444]];end else if a==5 then n=n+1;else y=f[n];end end end else if a<=9 then if a<=7 then w[y[537]]=w[y[444]][y[151]];else if 9~=a then n=n+1;else y=f[n];end end else if a<=11 then if 11~=a then w[y[537]][y[444]]=w[y[151]];else n=n+1;end else if a<13 then y=f[n];else w[y[537]]=j[y[444]];end end end end else if a<=20 then if a<=16 then if a<=14 then n=n+1;else if 15==a then y=f[n];else w[y[537]]=w[y[444]][y[151]];end end else if a<=18 then if a>17 then y=f[n];else n=n+1;end else if a>19 then n=n+1;else w[y[537]]=j[y[444]];end end end else if a<=23 then if a<=21 then y=f[n];else if 22<a then n=n+1;else w[y[537]]=w[y[444]][y[151]];end end else if a<=25 then if 25~=a then y=f[n];else c=y[537]end else if 27>a then w[c]=w[c]()else break end end end end end a=a+1 end else w[y[537]]=(w[y[444]]%y[151]);end;elseif(z<207 or z==207)then local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if a<1 then c=nil else w[y[537]]=w[y[444]];end else if a==2 then n=n+1;else y=f[n];end end else if a<=5 then if 5>a then w[y[537]]=y[444];else n=n+1;end else if 7>a then y=f[n];else w[y[537]]=y[444];end end end else if a<=11 then if a<=9 then if 9>a then n=n+1;else y=f[n];end else if 11~=a then w[y[537]]=y[444];else n=n+1;end end else if a<=13 then if 12<a then c=y[537]else y=f[n];end else if 15>a then w[c]=w[c](r(w,c+1,y[444]))else break end end end end a=a+1 end elseif not(209==z)then local a=y[537];do return w[a](r(w,a+1,y[444]))end;else local a,c,e=0 while true do if a<=24 then if a<=11 then if a<=5 then if a<=2 then if a<=0 then c=nil else if a==1 then e=nil else w[y[537]]={};end end else if a<=3 then n=n+1;else if 5>a then y=f[n];else w[y[537]]=h[y[444]];end end end else if a<=8 then if a<=6 then n=n+1;else if 7==a then y=f[n];else w[y[537]]=w[y[444]][y[151]];end end else if a<=9 then n=n+1;else if 11~=a then y=f[n];else w[y[537]]=h[y[444]];end end end end else if a<=17 then if a<=14 then if a<=12 then n=n+1;else if a<14 then y=f[n];else w[y[537]]=w[y[444]][y[151]];end end else if a<=15 then n=n+1;else if 16<a then w[y[537]]=w[y[444]][y[151]];else y=f[n];end end end else if a<=20 then if a<=18 then n=n+1;else if 19==a then y=f[n];else w[y[537]]={};end end else if a<=22 then if 21<a then y=f[n];else n=n+1;end else if a<24 then w[y[537]]={};else n=n+1;end end end end end else if a<=37 then if a<=30 then if a<=27 then if a<=25 then y=f[n];else if a~=27 then w[y[537]]=h[y[444]];else n=n+1;end end else if a<=28 then y=f[n];else if a~=30 then w[y[537]][y[444]]=w[y[151]];else n=n+1;end end end else if a<=33 then if a<=31 then y=f[n];else if 32==a then w[y[537]]=h[y[444]];else n=n+1;end end else if a<=35 then if a==34 then y=f[n];else w[y[537]][y[444]]=w[y[151]];end else if a~=37 then n=n+1;else y=f[n];end end end end else if a<=43 then if a<=40 then if a<=38 then w[y[537]][y[444]]=w[y[151]];else if 40>a then n=n+1;else y=f[n];end end else if a<=41 then w[y[537]]={r({},1,y[444])};else if a==42 then n=n+1;else y=f[n];end end end else if a<=46 then if a<=44 then w[y[537]]=w[y[444]];else if 45<a then y=f[n];else n=n+1;end end else if a<=48 then if 47==a then e=y[537];else c=w[e];end else if 50~=a then for m=e+1,y[444]do t(c,w[m])end;else break end end end end end end a=a+1 end end;elseif(z==221 or z<221)then if(z==215 or z<215)then if(z<=212)then if(z<210 or z==210)then local a=y[537]w[a](r(w,(a+1),p))elseif not(212==z)then local a,c,e,m=0 while true do if a<=9 then if a<=4 then if a<=1 then if a==0 then c=nil else e=nil end else if a<=2 then m=nil else if a==3 then w[y[537]]=h[y[444]];else n=n+1;end end end else if a<=6 then if a==5 then y=f[n];else w[y[537]]=h[y[444]];end else if a<=7 then n=n+1;else if a~=9 then y=f[n];else w[y[537]]=w[y[444]][y[151]];end end end end else if a<=14 then if a<=11 then if 10==a then n=n+1;else y=f[n];end else if a<=12 then w[y[537]]=w[y[444]][w[y[151]]];else if 13==a then n=n+1;else y=f[n];end end end else if a<=16 then if a<16 then m=y[537]else e={w[m](w[m+1])};end else if a<=17 then c=0;else if a==18 then for ba=m,y[151]do c=c+1;w[ba]=e[c];end else break end end end end end a=a+1 end else local a,c=0 while true do if a<=8 then if a<=3 then if a<=1 then if 1~=a then c=nil else w[y[537]]=w[y[444]][y[151]];end else if 2<a then y=f[n];else n=n+1;end end else if a<=5 then if a==4 then w[y[537]]=w[y[444]][y[151]];else n=n+1;end else if a<=6 then y=f[n];else if 8~=a then w[y[537]]=w[y[444]][y[151]];else n=n+1;end end end end else if a<=13 then if a<=10 then if a~=10 then y=f[n];else w[y[537]]=w[y[444]][y[151]];end else if a<=11 then n=n+1;else if a~=13 then y=f[n];else w[y[537]]=false;end end end else if a<=15 then if 14<a then y=f[n];else n=n+1;end else if a<=16 then c=y[537]else if 18>a then w[c](w[c+1])else break end end end end end a=a+1 end end;elseif(213==z or 213>z)then local a,c=0 while true do if a<=17 then if a<=8 then if a<=3 then if a<=1 then if 0<a then w={};else c=nil end else if 2==a then for e=0,u,1 do if e<o then w[e]=s[e+1];else break;end;end;else n=n+1;end end else if a<=5 then if a==4 then y=f[n];else w[y[537]]={};end else if a<=6 then n=n+1;else if a~=8 then y=f[n];else w[y[537]]=h[y[444]];end end end end else if a<=12 then if a<=10 then if 10>a then n=n+1;else y=f[n];end else if 11<a then n=n+1;else w[y[537]]=w[y[444]][y[151]];end end else if a<=14 then if a==13 then y=f[n];else w[y[537]]=h[y[444]];end else if a<=15 then n=n+1;else if 17>a then y=f[n];else w[y[537]]=w[y[444]][y[151]];end end end end end else if a<=26 then if a<=21 then if a<=19 then if 19>a then n=n+1;else y=f[n];end else if 21>a then w[y[537]]={};else n=n+1;end end else if a<=23 then if a~=23 then y=f[n];else w[y[537]]=y[444];end else if a<=24 then n=n+1;else if a==25 then y=f[n];else w[y[537]]=y[444];end end end end else if a<=30 then if a<=28 then if a~=28 then n=n+1;else y=f[n];end else if a==29 then w[y[537]]=y[444];else n=n+1;end end else if a<=32 then if a<32 then y=f[n];else c=y[537];end else if a<=33 then w[c]=w[c]-w[c+2];else if a==34 then n=y[444];else break end end end end end end a=a+1 end elseif not(214~=z)then local a,c,e,m=0 while true do if a<=9 then if a<=4 then if a<=1 then if a==0 then c=nil else e=nil end else if a<=2 then m=nil else if 3<a then n=n+1;else w[y[537]]=h[y[444]];end end end else if a<=6 then if 5<a then w[y[537]]=h[y[444]];else y=f[n];end else if a<=7 then n=n+1;else if 8<a then w[y[537]]=w[y[444]][y[151]];else y=f[n];end end end end else if a<=14 then if a<=11 then if 11>a then n=n+1;else y=f[n];end else if a<=12 then w[y[537]]=w[y[444]][w[y[151]]];else if 13<a then y=f[n];else n=n+1;end end end else if a<=16 then if 16~=a then m=y[537]else e={w[m](w[m+1])};end else if a<=17 then c=0;else if a<19 then for ba=m,y[151]do c=c+1;w[ba]=e[c];end else break end end end end end a=a+1 end else local a,c,e,m=0 while true do if a<=9 then if a<=4 then if a<=1 then if 1>a then c=nil else e=nil end else if a<=2 then m=nil else if 3<a then n=n+1;else w[y[537]]=j[y[444]];end end end else if a<=6 then if a==5 then y=f[n];else w[y[537]]=w[y[444]][y[151]];end else if a<=7 then n=n+1;else if a~=9 then y=f[n];else w[y[537]]=w[y[444]][y[151]];end end end end else if a<=14 then if a<=11 then if 11>a then n=n+1;else y=f[n];end else if a<=12 then w[y[537]]=w[y[444]][y[151]];else if 13<a then y=f[n];else n=n+1;end end end else if a<=16 then if a~=16 then m=y[537]else e={w[m](w[m+1])};end else if a<=17 then c=0;else if 18<a then break else for ba=m,y[151]do c=c+1;w[ba]=e[c];end end end end end end a=a+1 end end;elseif z<=218 then if(216>=z)then local a,c,e,m=0 while true do if(a<=15)then if(a==7 or a<7)then if a<=3 then if(a<=1)then if(1>a)then c=nil else e=nil end else if a>2 then w[y[537]]=h[y[444]];else m=nil end end else if(a==5 or a<5)then if a<5 then n=(n+1);else y=f[n];end else if(a<7)then w[y[537]]=w[y[444]][y[151]];else n=(n+1);end end end else if(a<=11)then if(a<=9)then if a<9 then y=f[n];else w[y[537]]=h[y[444]];end else if(10<a)then y=f[n];else n=n+1;end end else if(a<=13)then if 13>a then w[y[537]]=w[y[444]][y[151]];else n=(n+1);end else if 15~=a then y=f[n];else w[y[537]]=w[y[444]][w[y[151]]];end end end end else if a<=23 then if(a<=19)then if a<=17 then if a<17 then n=n+1;else y=f[n];end else if a>18 then n=n+1;else w[y[537]]=h[y[444]];end end else if(a<21 or a==21)then if 21~=a then y=f[n];else w[y[537]]=w[y[444]][y[151]];end else if not(a==23)then n=(n+1);else y=f[n];end end end else if(a<27 or a==27)then if(a==25 or a<25)then if(25>a)then w[y[537]]=w[y[444]][y[151]];else n=n+1;end else if(26==a)then y=f[n];else m=y[444];end end else if(a<=29)then if 28<a then c=k(w,g,m,e);else e=y[151];end else if a>30 then break else w[y[537]]=c;end end end end end a=(a+1)end elseif z==217 then if(y[537]<=w[y[151]])then n=(n+1);else n=y[444];end;else local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if 0<a then w[y[537]]=w[y[444]][y[151]];else c=nil end else if 3>a then n=n+1;else y=f[n];end end else if a<=5 then if 5>a then w[y[537]]=y[444];else n=n+1;end else if 6<a then w[y[537]]=y[444];else y=f[n];end end end else if a<=11 then if a<=9 then if a~=9 then n=n+1;else y=f[n];end else if 10<a then n=n+1;else w[y[537]]=y[444];end end else if a<=13 then if a~=13 then y=f[n];else c=y[537]end else if 15~=a then w[c]=w[c](r(w,c+1,y[444]))else break end end end end a=a+1 end end;elseif z<=219 then local a,c=0 while true do if a<=12 then if a<=5 then if a<=2 then if a<=0 then c=nil else if a>1 then for e=0,u,1 do if e<o then w[e]=s[e+1];else break;end;end;else w={};end end else if a<=3 then n=n+1;else if 4==a then y=f[n];else w[y[537]]=h[y[444]];end end end else if a<=8 then if a<=6 then n=n+1;else if 7<a then w[y[537]]=j[y[444]];else y=f[n];end end else if a<=10 then if 9==a then n=n+1;else y=f[n];end else if 11<a then n=n+1;else w[y[537]]=w[y[444]][y[151]];end end end end else if a<=18 then if a<=15 then if a<=13 then y=f[n];else if 15>a then w[y[537]]=y[444];else n=n+1;end end else if a<=16 then y=f[n];else if 18~=a then w[y[537]]=y[444];else n=n+1;end end end else if a<=21 then if a<=19 then y=f[n];else if a>20 then n=n+1;else w[y[537]]=y[444];end end else if a<=23 then if a>22 then c=y[537]else y=f[n];end else if 24<a then break else w[c]=w[c](r(w,c+1,y[444]))end end end end end a=a+1 end elseif 220==z then local a,c,e,m=0 while true do if a<=9 then if a<=4 then if a<=1 then if a~=1 then c=nil else e=nil end else if a<=2 then m=nil else if a~=4 then w[y[537]]=h[y[444]];else n=n+1;end end end else if a<=6 then if a>5 then w[y[537]]=h[y[444]];else y=f[n];end else if a<=7 then n=n+1;else if 8<a then w[y[537]]=w[y[444]][y[151]];else y=f[n];end end end end else if a<=14 then if a<=11 then if a>10 then y=f[n];else n=n+1;end else if a<=12 then w[y[537]]=w[y[444]][w[y[151]]];else if a>13 then y=f[n];else n=n+1;end end end else if a<=16 then if 16~=a then m=y[537]else e={w[m](w[m+1])};end else if a<=17 then c=0;else if 18==a then for ba=m,y[151]do c=c+1;w[ba]=e[c];end else break end end end end end a=a+1 end else local a=0 while true do if a<=6 then if a<=2 then if a<=0 then w[y[537]]=w[y[444]][y[151]];else if 2~=a then n=n+1;else y=f[n];end end else if a<=4 then if a~=4 then w[y[537]]=w[y[444]][y[151]];else n=n+1;end else if 6~=a then y=f[n];else w[y[537]]=w[y[444]][y[151]];end end end else if a<=9 then if a<=7 then n=n+1;else if a<9 then y=f[n];else w[y[537]]=w[y[444]][y[151]];end end else if a<=11 then if a<11 then n=n+1;else y=f[n];end else if a~=13 then if w[y[537]]then n=n+1;else n=y[444];end;else break end end end end a=a+1 end end;elseif(z==227 or z<227)then if(z==224 or z<224)then if(z<=222)then local a,c=0 while true do if(a<=7)then if(a==3 or a<3)then if a<=1 then if a~=1 then c=nil else w[y[537]]=w[y[444]][y[151]];end else if a<3 then n=n+1;else y=f[n];end end else if(a<=5)then if(4<a)then n=(n+1);else w[y[537]]=y[444];end else if not(6~=a)then y=f[n];else w[y[537]]=h[y[444]];end end end else if a<=11 then if(a==9 or a<9)then if(a>8)then y=f[n];else n=(n+1);end else if not(11==a)then w[y[537]]=w[y[444]][y[151]];else n=n+1;end end else if(a<=13)then if(a==12)then y=f[n];else c=y[537]end else if(a>14)then break else w[c]=w[c](r(w,(c+1),y[444]))end end end end a=a+1 end elseif 224~=z then w[y[537]][y[444]]=w[y[151]];else local a=y[537];local c,e,m=w[a],w[a+1],w[a+2];local c=c+m;w[a]=c;if(m>0 and c<=e)or((m<0)and(c>e or c==e))then n=y[444];w[a+3]=c;end;end;elseif(z==225 or z<225)then local a=y[537]local c={}for e=1,#v do local m=v[e]for ba=1,#m do local m=m[ba]local ba,ba=m[1],m[2]if(ba>=a)then c[ba]=w[ba]m[1]=c v[e]=nil;end end end elseif z>226 then local a,c=0 while true do if a<=9 then if a<=4 then if a<=1 then if 1~=a then c=nil else w={};end else if a<=2 then for e=0,u,1 do if e<o then w[e]=s[e+1];else break;end;end;else if a~=4 then n=n+1;else y=f[n];end end end else if a<=6 then if 6~=a then w[y[537]]=j[y[444]];else n=n+1;end else if a<=7 then y=f[n];else if a>8 then n=n+1;else w[y[537]]=w[y[444]][y[151]];end end end end else if a<=14 then if a<=11 then if 11~=a then y=f[n];else w[y[537]]=h[y[444]];end else if a<=12 then n=n+1;else if a<14 then y=f[n];else w[y[537]]=w[y[444]][y[151]];end end end else if a<=16 then if 16~=a then n=n+1;else y=f[n];end else if a<=17 then c=y[537]else if 19>a then w[c]=w[c](w[c+1])else break end end end end end a=a+1 end else local a=w[y[537]]+y[151];w[y[537]]=a;if(a<=w[y[537]+1])then n=y[444];end;end;elseif(z<=230)then if(228>z or 228==z)then local a=0 while true do if(a<=6)then if(a<=2)then if(a<=0)then w[y[537]]=w[y[444]][y[151]];else if 1<a then y=f[n];else n=(n+1);end end else if(a==4 or a<4)then if(3<a)then n=n+1;else w[y[537]]=w[y[444]][y[151]];end else if(5<a)then w[y[537]]=w[y[444]][y[151]];else y=f[n];end end end else if(a==9 or a<9)then if a<=7 then n=(n+1);else if a<9 then y=f[n];else w[y[537]]=w[y[444]][y[151]];end end else if(a<=11)then if a==10 then n=(n+1);else y=f[n];end else if not(13==a)then if w[y[537]]then n=n+1;else n=y[444];end;else break end end end end a=(a+1)end elseif z>229 then local a,c,e,m=0 while true do if a<=15 then if a<=7 then if a<=3 then if a<=1 then if 1>a then c=nil else e=nil end else if 2<a then w[y[537]]=h[y[444]];else m=nil end end else if a<=5 then if a>4 then y=f[n];else n=n+1;end else if 7~=a then w[y[537]]=w[y[444]][y[151]];else n=n+1;end end end else if a<=11 then if a<=9 then if 8<a then w[y[537]]=h[y[444]];else y=f[n];end else if a~=11 then n=n+1;else y=f[n];end end else if a<=13 then if 13>a then w[y[537]]=w[y[444]][y[151]];else n=n+1;end else if 15~=a then y=f[n];else w[y[537]]=w[y[444]][w[y[151]]];end end end end else if a<=23 then if a<=19 then if a<=17 then if a~=17 then n=n+1;else y=f[n];end else if a>18 then n=n+1;else w[y[537]]=h[y[444]];end end else if a<=21 then if 21~=a then y=f[n];else w[y[537]]=w[y[444]][y[151]];end else if 23>a then n=n+1;else y=f[n];end end end else if a<=27 then if a<=25 then if a~=25 then w[y[537]]=w[y[444]][y[151]];else n=n+1;end else if a~=27 then y=f[n];else m=y[444];end end else if a<=29 then if a==28 then e=y[151];else c=k(w,g,m,e);end else if 30<a then break else w[y[537]]=c;end end end end end a=a+1 end else local a=0 while true do if a<=9 then if a<=4 then if a<=1 then if a<1 then w={};else for c=0,u,1 do if c<o then w[c]=s[c+1];else break;end;end;end else if a<=2 then n=n+1;else if a~=4 then y=f[n];else w[y[537]]=y[444];end end end else if a<=6 then if a<6 then n=n+1;else y=f[n];end else if a<=7 then w[y[537]]=h[y[444]];else if 9>a then n=n+1;else y=f[n];end end end end else if a<=14 then if a<=11 then if a~=11 then w[y[537]]=h[y[444]];else n=n+1;end else if a<=12 then y=f[n];else if a>13 then n=n+1;else w[y[537]]=w[y[444]][y[151]];end end end else if a<=17 then if a<=15 then y=f[n];else if 17>a then w[y[537]]=w[y[444]][w[y[151]]];else n=n+1;end end else if a<=18 then y=f[n];else if a<20 then if(w[y[537]]~=y[151])then n=n+1;else n=y[444];end;else break end end end end end a=a+1 end end;elseif(z<231 or z==231)then w[y[537]]=#w[y[444]];elseif not(232~=z)then local a,c=0 while true do if a<=8 then if a<=3 then if a<=1 then if 1>a then c=nil else w[y[537]]=w[y[444]][y[151]];end else if a==2 then n=n+1;else y=f[n];end end else if a<=5 then if 5>a then w[y[537]]=h[y[444]];else n=n+1;end else if a<=6 then y=f[n];else if a~=8 then w[y[537]]=w[y[444]][y[151]];else n=n+1;end end end end else if a<=13 then if a<=10 then if 9==a then y=f[n];else w[y[537]]=y[444];end else if a<=11 then n=n+1;else if 12<a then w[y[537]]=y[444];else y=f[n];end end end else if a<=15 then if 14==a then n=n+1;else y=f[n];end else if a<=16 then c=y[537]else if 18~=a then w[c]=w[c](r(w,c+1,y[444]))else break end end end end end a=a+1 end else w[y[537]]=w[y[444]]*y[151];end;elseif(z==256 or z<256)then if((z==244)or z<244)then if(238==z or 238>z)then if(z<=235)then if not(z~=234)then local a,c,e,m=0 while true do if(a<9 or a==9)then if(a<=4)then if a<=1 then if not(a~=0)then c=nil else e=nil end else if(a<2 or a==2)then m=nil else if a<4 then w[y[537]]=h[y[444]];else n=n+1;end end end else if(a<6 or a==6)then if not(a~=5)then y=f[n];else w[y[537]]=h[y[444]];end else if(a==7 or a<7)then n=n+1;else if 8==a then y=f[n];else w[y[537]]=w[y[444]][y[151]];end end end end else if(a<=14)then if(a<11 or a==11)then if 11>a then n=(n+1);else y=f[n];end else if a<=12 then w[y[537]]=w[y[444]][w[y[151]]];else if not(a==14)then n=(n+1);else y=f[n];end end end else if a<=16 then if(15<a)then e={w[m](w[m+1])};else m=y[537]end else if a<=17 then c=0;else if not(a==19)then for v=m,y[151]do c=(c+1);w[v]=e[c];end else break end end end end end a=a+1 end else local a,c,e,m=0 while true do if(a<9 or a==9)then if(a==4 or a<4)then if(a<1 or a==1)then if not(a~=0)then c=nil else e=nil end else if(a<=2)then m=nil else if(4>a)then w[y[537]]=h[y[444]];else n=n+1;end end end else if(a==6 or a<6)then if 6>a then y=f[n];else w[y[537]]=h[y[444]];end else if a<=7 then n=n+1;else if not(a==9)then y=f[n];else w[y[537]]=w[y[444]][y[151]];end end end end else if(a<=14)then if a<=11 then if not(10~=a)then n=n+1;else y=f[n];end else if(a<12 or a==12)then w[y[537]]=w[y[444]][w[y[151]]];else if a<14 then n=(n+1);else y=f[n];end end end else if(a==16 or a<16)then if not(15~=a)then m=y[537]else e={w[m](w[m+1])};end else if(a<=17)then c=0;else if(18<a)then break else for v=m,y[151]do c=(c+1);w[v]=e[c];end end end end end end a=a+1 end end;elseif(236==z or 236>z)then local a,c=0 while true do if(a<=10)then if a<=4 then if a<=1 then if(0<a)then w[y[537]]=j[y[444]];else c=nil end else if(a<2 or a==2)then n=(n+1);else if(a>3)then w[y[537]]=w[y[444]][y[151]];else y=f[n];end end end else if(a<=7)then if(a<=5)then n=(n+1);else if 6<a then w[y[537]]=y[444];else y=f[n];end end else if a<=8 then n=n+1;else if 10>a then y=f[n];else w[y[537]]=y[444];end end end end else if(a==15 or a<15)then if(a<=12)then if 12>a then n=n+1;else y=f[n];end else if(a==13 or a<13)then w[y[537]]=y[444];else if not(a~=14)then n=n+1;else y=f[n];end end end else if(a<18 or a==18)then if(a<16 or a==16)then w[y[537]]=y[444];else if a~=18 then n=(n+1);else y=f[n];end end else if(a<=19)then c=y[537]else if not(20~=a)then w[c]=w[c](r(w,c+1,y[444]))else break end end end end end a=a+1 end elseif(238>z)then local a,c=0 while true do if(a<=7)then if(a<=3)then if a<=1 then if(1>a)then c=nil else w[y[537]]=h[y[444]];end else if not(a==3)then n=n+1;else y=f[n];end end else if(a<=5)then if(a~=5)then w[y[537]]=w[y[444]][y[151]];else n=n+1;end else if not(a==7)then y=f[n];else w[y[537]]=y[444];end end end else if a<=11 then if a<=9 then if 8==a then n=(n+1);else y=f[n];end else if 10==a then w[y[537]]=y[444];else n=n+1;end end else if(a<13 or a==13)then if(12<a)then c=y[537]else y=f[n];end else if a~=15 then w[c]=w[c](r(w,(c+1),y[444]))else break end end end end a=(a+1)end else local a,c,e,m=0 while true do if(a<10 or a==10)then if(a<4 or a==4)then if(a<1 or a==1)then if 0<a then e=nil else c=nil end else if(a<2 or a==2)then m=nil else if not(a~=3)then w[y[537]]=h[y[444]];else n=n+1;end end end else if a<=7 then if(a==5 or a<5)then y=f[n];else if(a>6)then n=(n+1);else w[y[537]]=w[y[444]][y[151]];end end else if(a<8 or a==8)then y=f[n];else if(9<a)then n=(n+1);else w[y[537]]=w[y[444]][y[151]];end end end end else if(a<16 or a==16)then if(a==13 or a<13)then if(a<11 or a==11)then y=f[n];else if not(12~=a)then w[y[537]]=h[y[444]];else n=n+1;end end else if a<=14 then y=f[n];else if not(a~=15)then w[y[537]]=w[y[444]][y[151]];else n=(n+1);end end end else if a<=19 then if(a==17 or a<17)then y=f[n];else if not(18~=a)then m=y[444];else e=y[151];end end else if(a==20 or a<20)then c=k(w,g,m,e);else if not(21~=a)then w[y[537]]=c;else break end end end end end a=(a+1)end end;elseif(z==241 or z<241)then if(239>z or 239==z)then local a,c,e,m=0 while true do if a<=9 then if(a<4 or a==4)then if(a<1 or a==1)then if(0==a)then c=nil else e=nil end else if(a<2 or a==2)then m=nil else if 3<a then n=n+1;else w[y[537]]=h[y[444]];end end end else if(a<6 or a==6)then if(6>a)then y=f[n];else w[y[537]]=h[y[444]];end else if(a<=7)then n=(n+1);else if 9~=a then y=f[n];else w[y[537]]=w[y[444]][y[151]];end end end end else if(a==14 or a<14)then if a<=11 then if 11>a then n=(n+1);else y=f[n];end else if(a<=12)then w[y[537]]=w[y[444]][w[y[151]]];else if(14>a)then n=n+1;else y=f[n];end end end else if a<=16 then if a==15 then m=y[537]else e={w[m](w[m+1])};end else if(a<=17)then c=0;else if not(18~=a)then for v=m,y[151]do c=c+1;w[v]=e[c];end else break end end end end end a=(a+1)end elseif(z>240)then local a=y[537]local c,e=i(w[a](w[(a+1)]))p=(e+a-1)local e=0;for m=a,p do e=(e+1);w[m]=c[e];end;else w[y[537]][w[y[444]]]=w[y[151]];end;elseif(not(242~=z)or 242>z)then local a=0 while true do if(a==7 or a<7)then if a<=3 then if a<=1 then if a~=1 then w[y[537]]=w[y[444]][y[151]];else n=n+1;end else if 3~=a then y=f[n];else w[y[537]][y[444]]=w[y[151]];end end else if(a<5 or a==5)then if 5>a then n=n+1;else y=f[n];end else if not(6~=a)then w[y[537]]=w[y[444]][y[151]];else n=n+1;end end end else if(a<11 or a==11)then if(a<=9)then if(a>8)then w[y[537]]=h[y[444]];else y=f[n];end else if not(10~=a)then n=(n+1);else y=f[n];end end else if(a<13 or a==13)then if a<13 then w[y[537]]=w[y[444]][y[151]];else n=(n+1);end else if a<=14 then y=f[n];else if 16>a then if(not(w[y[537]]==w[y[151]]))then n=(n+1);else n=y[444];end;else break end end end end end a=(a+1)end elseif not(not(243==z))then local a,c,e,m=0 while true do if(a==9 or a<9)then if(a<4 or a==4)then if(a<=1)then if not(0~=a)then c=nil else e=nil end else if a<=2 then m=nil else if(3<a)then n=n+1;else w[y[537]]=h[y[444]];end end end else if(a<=6)then if not(5~=a)then y=f[n];else w[y[537]]=h[y[444]];end else if(a==7 or a<7)then n=n+1;else if not(8~=a)then y=f[n];else w[y[537]]=w[y[444]][y[151]];end end end end else if(a<=14)then if a<=11 then if a<11 then n=n+1;else y=f[n];end else if(a<12 or a==12)then w[y[537]]=w[y[444]][w[y[151]]];else if(13<a)then y=f[n];else n=n+1;end end end else if(a<16 or a==16)then if a>15 then e={w[m](w[m+1])};else m=y[537]end else if(a<=17)then c=0;else if 18<a then break else for v=m,y[151]do c=c+1;w[v]=e[c];end end end end end end a=(a+1)end else local a,c,e,m=0 while true do if(a<9 or a==9)then if(a<4 or a==4)then if(a==1 or a<1)then if 0<a then e=nil else c=nil end else if(a<2 or a==2)then m=nil else if(a>3)then n=n+1;else w[y[537]]=j[y[444]];end end end else if(a<=6)then if(6~=a)then y=f[n];else w[y[537]]=w[y[444]][y[151]];end else if(a<=7)then n=(n+1);else if not(9==a)then y=f[n];else w[y[537]]=w[y[444]][y[151]];end end end end else if a<=14 then if a<=11 then if not(a~=10)then n=n+1;else y=f[n];end else if(a<=12)then w[y[537]]=w[y[444]][y[151]];else if a<14 then n=(n+1);else y=f[n];end end end else if a<=16 then if(a~=16)then m=y[537]else e={w[m](w[m+1])};end else if(a<=17)then c=0;else if a~=19 then for v=m,y[151]do c=c+1;w[v]=e[c];end else break end end end end end a=(a+1)end end;elseif(250>z or 250==z)then if((247>z)or 247==z)then if((245>z)or 245==z)then local a,c=0 while true do if(a==7 or a<7)then if a<=3 then if(a<=1)then if 1>a then c=nil else w[y[537]]=h[y[444]];end else if not(a~=2)then n=(n+1);else y=f[n];end end else if(a<=5)then if(5~=a)then w[y[537]]=w[y[444]][y[151]];else n=(n+1);end else if(6<a)then w[y[537]]=y[444];else y=f[n];end end end else if(a<=11)then if(a==9 or a<9)then if a>8 then y=f[n];else n=n+1;end else if not(11==a)then w[y[537]]=y[444];else n=(n+1);end end else if(a<13 or a==13)then if(13~=a)then y=f[n];else c=y[537]end else if(14==a)then w[c]=w[c](r(w,c+1,y[444]))else break end end end end a=a+1 end elseif(z~=247)then local a=0 while true do if(a==6 or a<6)then if(a<2 or a==2)then if a<=0 then w[y[537]]=w[y[444]][y[151]];else if not(a==2)then n=(n+1);else y=f[n];end end else if(a==4 or a<4)then if(4>a)then w[y[537]]=w[y[444]][y[151]];else n=(n+1);end else if 6~=a then y=f[n];else w[y[537]]=w[y[444]][y[151]];end end end else if(a==9 or a<9)then if(a<7 or a==7)then n=(n+1);else if not(8~=a)then y=f[n];else w[y[537]][y[444]]=w[y[151]];end end else if(a<=11)then if not(11==a)then n=n+1;else y=f[n];end else if(a==12)then n=y[444];else break end end end end a=a+1 end else w[y[537]]=h[y[444]];end;elseif(z<248 or z==248)then local a,c=0 while true do if(a==7 or a<7)then if(a==3 or a<3)then if(a<1 or a==1)then if not(a~=0)then c=nil else w[y[537]]=h[y[444]];end else if(a>2)then y=f[n];else n=(n+1);end end else if a<=5 then if a>4 then n=(n+1);else w[y[537]]=y[444];end else if(6==a)then y=f[n];else w[y[537]]=y[444];end end end else if(a<11 or a==11)then if a<=9 then if(8<a)then y=f[n];else n=(n+1);end else if not(a~=10)then w[y[537]]=y[444];else n=n+1;end end else if(a<13 or a==13)then if 13~=a then y=f[n];else c=y[537]end else if(14<a)then break else w[c]=w[c](r(w,c+1,y[444]))end end end end a=a+1 end elseif(z<250)then local a,c=0 while true do if(a==12 or a<12)then if(a<=5)then if(a<=2)then if(a<=0)then c=nil else if not(a==2)then w={};else for e=0,u,1 do if e<o then w[e]=s[e+1];else break;end;end;end end else if(a<3 or a==3)then n=(n+1);else if 4<a then w[y[537]]=h[y[444]];else y=f[n];end end end else if a<=8 then if a<=6 then n=n+1;else if not(a==8)then y=f[n];else w[y[537]]=j[y[444]];end end else if(a<=10)then if not(9~=a)then n=n+1;else y=f[n];end else if 11==a then w[y[537]]=w[y[444]][y[151]];else n=n+1;end end end end else if(a<18 or a==18)then if(a<=15)then if a<=13 then y=f[n];else if 15>a then w[y[537]]=y[444];else n=(n+1);end end else if(a<=16)then y=f[n];else if not(18==a)then w[y[537]]=y[444];else n=n+1;end end end else if(a<21 or a==21)then if a<=19 then y=f[n];else if a==20 then w[y[537]]=y[444];else n=(n+1);end end else if a<=23 then if(22<a)then c=y[537]else y=f[n];end else if not(a~=24)then w[c]=w[c](r(w,(c+1),y[444]))else break end end end end end a=(a+1)end else local a,c=0 while true do if(a==7 or a<7)then if a<=3 then if(a==1 or a<1)then if(1~=a)then c=nil else w[y[537]]=w[y[444]][y[151]];end else if 2<a then y=f[n];else n=n+1;end end else if(a<5 or a==5)then if(5>a)then w[y[537]]=w[y[444]];else n=n+1;end else if not(6~=a)then y=f[n];else w[y[537]]=h[y[444]];end end end else if(a<=11)then if a<=9 then if not(a==9)then n=(n+1);else y=f[n];end else if(a==10)then w[y[537]]=w[y[444]][w[y[151]]];else n=(n+1);end end else if(a<=13)then if(12<a)then c=y[537]else y=f[n];end else if not(15==a)then w[c]=w[c](r(w,(c+1),y[444]))else break end end end end a=(a+1)end end;elseif((z==253)or(z<253))then if(z==251 or z<251)then local a,c=0 while true do if(a<=10)then if(a<=4)then if(a<1 or a==1)then if a~=1 then c=nil else w[y[537]]=j[y[444]];end else if a<=2 then n=n+1;else if not(4==a)then y=f[n];else w[y[537]]=w[y[444]][y[151]];end end end else if(a==7 or a<7)then if(a==5 or a<5)then n=n+1;else if(7>a)then y=f[n];else w[y[537]]=y[444];end end else if(a<8 or a==8)then n=(n+1);else if(a~=10)then y=f[n];else w[y[537]]=y[444];end end end end else if a<=15 then if(a<12 or a==12)then if(12>a)then n=n+1;else y=f[n];end else if(a<13 or a==13)then w[y[537]]=y[444];else if 14<a then y=f[n];else n=(n+1);end end end else if(a<18 or a==18)then if(a<16 or a==16)then w[y[537]]=y[444];else if 17<a then y=f[n];else n=(n+1);end end else if(a<19 or a==19)then c=y[537]else if 21>a then w[c]=w[c](r(w,c+1,y[444]))else break end end end end end a=(a+1)end elseif(252<z)then local a,c=0 while true do if(a<14 or a==14)then if(a<=6)then if(a<2 or a==2)then if(a<0 or a==0)then c=nil else if a>1 then n=n+1;else w[y[537]]=w[y[444]][y[151]];end end else if(a==4 or a<4)then if a==3 then y=f[n];else w[y[537]]=w[y[444]][y[151]];end else if(6>a)then n=n+1;else y=f[n];end end end else if a<=10 then if(a<=8)then if not(a==8)then w[y[537]]=w[y[444]][y[151]];else n=n+1;end else if a>9 then w[y[537]]=(w[y[444]]*y[151]);else y=f[n];end end else if(a<12 or a==12)then if a==11 then n=n+1;else y=f[n];end else if(a>13)then n=n+1;else w[y[537]]=w[y[444]]+w[y[151]];end end end end else if(a<=22)then if(a<=18)then if(a<=16)then if(16~=a)then y=f[n];else w[y[537]]=j[y[444]];end else if not(a==18)then n=(n+1);else y=f[n];end end else if(a==20 or a<20)then if not(a~=19)then w[y[537]]=w[y[444]][y[151]];else n=(n+1);end else if not(a==22)then y=f[n];else w[y[537]]=w[y[444]];end end end else if(a==26 or a<26)then if(a==24 or a<24)then if not(a==24)then n=n+1;else y=f[n];end else if(26>a)then w[y[537]]=w[y[444]]+w[y[151]];else n=(n+1);end end else if(a<28 or a==28)then if 28>a then y=f[n];else c=y[537]end else if 30>a then w[c]=w[c](r(w,c+1,y[444]))else break end end end end end a=a+1 end else local a=0 while true do if(a<18 or a==18)then if(a<8 or a==8)then if(a<3 or a==3)then if(a==1 or a<1)then if not(0~=a)then w[y[537]]=j[y[444]];else n=n+1;end else if(2<a)then w[y[537]]=w[y[444]][y[151]];else y=f[n];end end else if(a<5 or a==5)then if not(5==a)then n=(n+1);else y=f[n];end else if a<=6 then w[y[537]]=j[y[444]];else if(8>a)then n=(n+1);else y=f[n];end end end end else if(a<=13)then if a<=10 then if 10>a then w[y[537]]=j[y[444]];else n=(n+1);end else if(a<11 or a==11)then y=f[n];else if(a>12)then n=(n+1);else w[y[537]]=j[y[444]];end end end else if(a<=15)then if not(a==15)then y=f[n];else w[y[537]]=j[y[444]];end else if a<=16 then n=n+1;else if(17<a)then w[y[537]]=j[y[444]];else y=f[n];end end end end end else if(a<27 or a==27)then if(a<=22)then if(a<=20)then if 20>a then n=n+1;else y=f[n];end else if not(a~=21)then w[y[537]]=j[y[444]];else n=n+1;end end else if(a<=24)then if not(a==24)then y=f[n];else w[y[537]]=j[y[444]];end else if(a<=25)then n=(n+1);else if(a<27)then y=f[n];else w[y[537]]=j[y[444]];end end end end else if(a<32 or a==32)then if(a<29 or a==29)then if(29>a)then n=(n+1);else y=f[n];end else if a<=30 then w[y[537]]={};else if not(31~=a)then n=n+1;else y=f[n];end end end else if(a<34 or a==34)then if a>33 then n=n+1;else w[y[537]]=w[y[444]][y[151]];end else if(a<35 or a==35)then y=f[n];else if a<37 then if not w[y[537]]then n=(n+1);else n=y[444];end;else break end end end end end end a=a+1 end end;elseif z<=254 then local a=0 while true do if a<=9 then if a<=4 then if a<=1 then if a>0 then n=n+1;else w[y[537]]=(w[y[444]]/y[151]);end else if(a<2 or a==2)then y=f[n];else if(3==a)then w[y[537]]=(w[y[444]]-w[y[151]]);else n=(n+1);end end end else if(a<6 or a==6)then if not(a~=5)then y=f[n];else w[y[537]]=(w[y[444]]/y[151]);end else if a<=7 then n=n+1;else if 9~=a then y=f[n];else w[y[537]]=(w[y[444]]*y[151]);end end end end else if a<=14 then if(a==11 or a<11)then if(11>a)then n=n+1;else y=f[n];end else if(a<12 or a==12)then w[y[537]]=w[y[444]];else if(a<14)then n=(n+1);else y=f[n];end end end else if a<=16 then if 15<a then n=n+1;else w[y[537]]=w[y[444]];end else if(a==17 or a<17)then y=f[n];else if(19~=a)then n=y[444];else break end end end end end a=a+1 end elseif not(z==256)then local a,c=0 while true do if(a<7 or a==7)then if a<=3 then if(a<1 or a==1)then if a>0 then w[y[537]]=w[y[444]];else c=nil end else if(a<3)then n=n+1;else y=f[n];end end else if(a<=5)then if(a<5)then w[y[537]]=y[444];else n=(n+1);end else if not(7==a)then y=f[n];else w[y[537]]=y[444];end end end else if a<=11 then if(a<9 or a==9)then if not(a~=8)then n=(n+1);else y=f[n];end else if not(10~=a)then w[y[537]]=y[444];else n=n+1;end end else if(a<13 or a==13)then if not(a~=12)then y=f[n];else c=y[537]end else if(15>a)then w[c]=w[c](r(w,(c+1),y[444]))else break end end end end a=(a+1)end else local a,c=0 while true do if(a==10 or a<10)then if(a<=4)then if a<=1 then if not(0~=a)then c=nil else w={};end else if a<=2 then for e=0,u,1 do if e<o then w[e]=s[(e+1)];else break;end;end;else if not(3~=a)then n=(n+1);else y=f[n];end end end else if(a<=7)then if(a<5 or a==5)then w[y[537]]=h[y[444]];else if not(a~=6)then n=n+1;else y=f[n];end end else if(a==8 or a<8)then w[y[537]]=w[y[444]][y[151]];else if not(a==10)then n=n+1;else y=f[n];end end end end else if(a<=16)then if(a==13 or a<13)then if(a<=11)then w[y[537]]=h[y[444]];else if a<13 then n=n+1;else y=f[n];end end else if(a<=14)then w[y[537]]=h[y[444]];else if(16~=a)then n=(n+1);else y=f[n];end end end else if(a==19 or a<19)then if(a<=17)then w[y[537]]=w[y[444]][w[y[151]]];else if 18<a then y=f[n];else n=n+1;end end else if a<=20 then c=y[537]else if not(21~=a)then w[c](w[c+1])else break end end end end end a=(a+1)end end;elseif(z<268 or z==268)then if(z<=262)then if(259>z or 259==z)then if(257>z or 257==z)then local a,c=0 while true do if a<=7 then if(a<=3)then if a<=1 then if not(1==a)then c=nil else w[y[537]]=h[y[444]];end else if a>2 then y=f[n];else n=n+1;end end else if(a==5 or a<5)then if(a<5)then w[y[537]]=y[444];else n=n+1;end else if not(6~=a)then y=f[n];else w[y[537]]=y[444];end end end else if(a<=11)then if(a<=9)then if(8<a)then y=f[n];else n=(n+1);end else if(a<11)then w[y[537]]=y[444];else n=n+1;end end else if(a<=13)then if(13>a)then y=f[n];else c=y[537]end else if(a==14)then w[c]=w[c](r(w,(c+1),y[444]))else break end end end end a=(a+1)end elseif 259>z then local a=y[537];local c=w[y[444]];w[(a+1)]=c;w[a]=c[y[151]];else local a=w[y[151]];if not a then n=n+1;else w[y[537]]=a;n=y[444];end;end;elseif 260>=z then local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if 1>a then c=nil else w[y[537]]=j[y[444]];end else if a>2 then y=f[n];else n=n+1;end end else if a<=5 then if a>4 then n=n+1;else w[y[537]]=w[y[444]][y[151]];end else if 6<a then w[y[537]]=h[y[444]];else y=f[n];end end end else if a<=11 then if a<=9 then if a<9 then n=n+1;else y=f[n];end else if a~=11 then w[y[537]]=w[y[444]][y[151]];else n=n+1;end end else if a<=13 then if 13~=a then y=f[n];else c=y[537]end else if 14==a then w[c]=w[c](w[c+1])else break end end end end a=a+1 end elseif(z<262)then local a,c=0 while true do if a<=10 then if a<=4 then if a<=1 then if 0<a then w[y[537]]=w[y[444]][y[151]];else c=nil end else if a<=2 then n=n+1;else if 3==a then y=f[n];else w[y[537]]=y[444];end end end else if a<=7 then if a<=5 then n=n+1;else if a~=7 then y=f[n];else w[y[537]]=h[y[444]];end end else if a<=8 then n=n+1;else if a~=10 then y=f[n];else w[y[537]]=w[y[444]][y[151]];end end end end else if a<=16 then if a<=13 then if a<=11 then n=n+1;else if 13>a then y=f[n];else c=y[537];end end else if a<=14 then do return w[c](r(w,c+1,y[444]))end;else if a<16 then n=n+1;else y=f[n];end end end else if a<=19 then if a<=17 then c=y[537];else if 18==a then do return r(w,c,p)end;else n=n+1;end end else if a<=20 then y=f[n];else if a>21 then break else n=y[444];end end end end end a=a+1 end else local a=0 while true do if a<=14 then if a<=6 then if a<=2 then if a<=0 then w={};else if a<2 then for c=0,u,1 do if c<o then w[c]=s[c+1];else break;end;end;else n=n+1;end end else if a<=4 then if 3==a then y=f[n];else w[y[537]]=h[y[444]];end else if 6~=a then n=n+1;else y=f[n];end end end else if a<=10 then if a<=8 then if 7==a then w[y[537]]=w[y[444]][y[151]];else n=n+1;end else if a<10 then y=f[n];else w[y[537]]=h[y[444]];end end else if a<=12 then if a>11 then y=f[n];else n=n+1;end else if 13==a then w[y[537]]={};else n=n+1;end end end end else if a<=21 then if a<=17 then if a<=15 then y=f[n];else if a==16 then w[y[537]]={};else n=n+1;end end else if a<=19 then if 18<a then w[y[537]][y[444]]=w[y[151]];else y=f[n];end else if 21~=a then n=n+1;else y=f[n];end end end else if a<=25 then if a<=23 then if a<23 then w[y[537]]=j[y[444]];else n=n+1;end else if a<25 then y=f[n];else w[y[537]]=w[y[444]][y[151]];end end else if a<=27 then if 26==a then n=n+1;else y=f[n];end else if 29~=a then if w[y[537]]then n=n+1;else n=y[444];end;else break end end end end end a=a+1 end end;elseif(z==265 or z<265)then if(z<=263)then local a,c,e,m=0 while true do if(a<=9)then if(a==4 or a<4)then if(a<1 or a==1)then if a==0 then c=nil else e=nil end else if(a<2 or a==2)then m=nil else if a~=4 then w[y[537]]=h[y[444]];else n=n+1;end end end else if(a==6 or a<6)then if not(a==6)then y=f[n];else w[y[537]]=h[y[444]];end else if a<=7 then n=n+1;else if 9>a then y=f[n];else w[y[537]]=w[y[444]][y[151]];end end end end else if a<=14 then if a<=11 then if(10==a)then n=n+1;else y=f[n];end else if(a==12 or a<12)then w[y[537]]=w[y[444]][w[y[151]]];else if(13<a)then y=f[n];else n=(n+1);end end end else if(a<16 or a==16)then if 15==a then m=y[537]else e={w[m](w[m+1])};end else if a<=17 then c=0;else if(a>18)then break else for v=m,y[151]do c=(c+1);w[v]=e[c];end end end end end end a=a+1 end elseif(264<z)then local a=0 while true do if a<=9 then if a<=4 then if a<=1 then if 1>a then w[y[537]][y[444]]=y[151];else n=n+1;end else if a<=2 then y=f[n];else if a~=4 then w[y[537]]={};else n=n+1;end end end else if a<=6 then if a==5 then y=f[n];else w[y[537]][y[444]]=w[y[151]];end else if a<=7 then n=n+1;else if a>8 then w[y[537]]=h[y[444]];else y=f[n];end end end end else if a<=14 then if a<=11 then if 11~=a then n=n+1;else y=f[n];end else if a<=12 then w[y[537]]=w[y[444]][y[151]];else if a==13 then n=n+1;else y=f[n];end end end else if a<=16 then if a~=16 then w[y[537]][y[444]]=w[y[151]];else n=n+1;end else if a<=17 then y=f[n];else if 19~=a then w[y[537]][y[444]]=w[y[151]];else break end end end end end a=a+1 end else local a=0 while true do if a<=7 then if a<=3 then if a<=1 then if 1~=a then w[y[537]]=w[y[444]][y[151]];else n=n+1;end else if a<3 then y=f[n];else w[y[537]][y[444]]=w[y[151]];end end else if a<=5 then if a~=5 then n=n+1;else y=f[n];end else if 6<a then n=n+1;else w[y[537]]=w[y[444]][y[151]];end end end else if a<=11 then if a<=9 then if 8==a then y=f[n];else w[y[537]]=h[y[444]];end else if 10<a then y=f[n];else n=n+1;end end else if a<=13 then if 13>a then w[y[537]]=w[y[444]][y[151]];else n=n+1;end else if a<=14 then y=f[n];else if 16>a then if(w[y[537]]~=w[y[151]])then n=n+1;else n=y[444];end;else break end end end end end a=a+1 end end;elseif(z<=266)then local a,c=0 while true do if(a<=10)then if a<=4 then if a<=1 then if not(1==a)then c=nil else w[y[537]][y[444]]=w[y[151]];end else if(a==2 or a<2)then n=(n+1);else if a>3 then w[y[537]]=j[y[444]];else y=f[n];end end end else if a<=7 then if a<=5 then n=(n+1);else if(6<a)then w[y[537]]=w[y[444]][y[151]];else y=f[n];end end else if(a<8 or a==8)then n=(n+1);else if not(a~=9)then y=f[n];else w[y[537]]=h[y[444]];end end end end else if a<=15 then if a<=12 then if 12>a then n=(n+1);else y=f[n];end else if a<=13 then w[y[537]]=w[y[444]][y[151]];else if(14==a)then n=(n+1);else y=f[n];end end end else if(a<=18)then if(a<16 or a==16)then w[y[537]]=w[y[444]];else if(17==a)then n=n+1;else y=f[n];end end else if(a<19 or a==19)then c=y[537]else if not(a==21)then w[c](r(w,(c+1),y[444]))else break end end end end end a=(a+1)end elseif 267==z then local a,c,e,m=0 while true do if a<=9 then if a<=4 then if a<=1 then if 0<a then e=nil else c=nil end else if a<=2 then m=nil else if a==3 then w[y[537]]=h[y[444]];else n=n+1;end end end else if a<=6 then if a==5 then y=f[n];else w[y[537]]=h[y[444]];end else if a<=7 then n=n+1;else if a~=9 then y=f[n];else w[y[537]]=w[y[444]][y[151]];end end end end else if a<=14 then if a<=11 then if 10==a then n=n+1;else y=f[n];end else if a<=12 then w[y[537]]=w[y[444]][w[y[151]]];else if 13<a then y=f[n];else n=n+1;end end end else if a<=16 then if a<16 then m=y[537]else e={w[m](w[m+1])};end else if a<=17 then c=0;else if 19>a then for v=m,y[151]do c=c+1;w[v]=e[c];end else break end end end end end a=a+1 end else w[y[537]]=(y[444]*w[y[151]]);end;elseif(274==z or 274>z)then if(z<271 or z==271)then if(269==z or 269>z)then for a=y[537],y[444],1 do w[a]=nil;end;elseif 271~=z then local a,c=0 while true do if a<=8 then if a<=3 then if a<=1 then if a~=1 then c=nil else w[y[537]]=w[y[444]][y[151]];end else if a~=3 then n=n+1;else y=f[n];end end else if a<=5 then if a>4 then n=n+1;else w[y[537]]=h[y[444]];end else if a<=6 then y=f[n];else if a==7 then w[y[537]]=w[y[444]][w[y[151]]];else n=n+1;end end end end else if a<=13 then if a<=10 then if 10>a then y=f[n];else w[y[537]]=h[y[444]];end else if a<=11 then n=n+1;else if 13>a then y=f[n];else w[y[537]]=w[y[444]][y[151]];end end end else if a<=15 then if 15>a then n=n+1;else y=f[n];end else if a<=16 then c=y[537]else if 17<a then break else w[c]=w[c](r(w,c+1,y[444]))end end end end end a=a+1 end else w[y[537]]=j[y[444]];end;elseif(272==z or 272>z)then local a=0 while true do if a<=7 then if a<=3 then if a<=1 then if 0<a then n=n+1;else w[y[537]]=w[y[444]][y[151]];end else if 2<a then w[y[537]][y[444]]=w[y[151]];else y=f[n];end end else if a<=5 then if 5~=a then n=n+1;else y=f[n];end else if a==6 then w[y[537]]=h[y[444]];else n=n+1;end end end else if a<=11 then if a<=9 then if 9>a then y=f[n];else w[y[537]]=w[y[444]][y[151]];end else if 11~=a then n=n+1;else y=f[n];end end else if a<=13 then if a<13 then w[y[537]][y[444]]=w[y[151]];else n=n+1;end else if a<=14 then y=f[n];else if a>15 then break else do return w[y[537]]end end end end end end a=a+1 end elseif(273<z)then w[y[537]]=w[y[444]]+y[151];else local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if a==0 then c=nil else w[y[537]][y[444]]=w[y[151]];end else if 3>a then n=n+1;else y=f[n];end end else if a<=5 then if 4==a then w[y[537]]={};else n=n+1;end else if 6==a then y=f[n];else w[y[537]][y[444]]=y[151];end end end else if a<=11 then if a<=9 then if 8==a then n=n+1;else y=f[n];end else if a<11 then w[y[537]][y[444]]=w[y[151]];else n=n+1;end end else if a<=13 then if 12==a then y=f[n];else c=y[537]end else if 15>a then w[c]=w[c](r(w,c+1,y[444]))else break end end end end a=a+1 end end;elseif(277==z or 277>z)then if(275==z or 275>z)then local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if a>0 then w[y[537]]=j[y[444]];else c=nil end else if a<3 then n=n+1;else y=f[n];end end else if a<=5 then if 5>a then w[y[537]]=w[y[444]][y[151]];else n=n+1;end else if a<7 then y=f[n];else w[y[537]]=h[y[444]];end end end else if a<=11 then if a<=9 then if 8==a then n=n+1;else y=f[n];end else if 11~=a then w[y[537]]=w[y[444]][y[151]];else n=n+1;end end else if a<=13 then if a==12 then y=f[n];else c=y[537]end else if a~=15 then w[c]=w[c](w[c+1])else break end end end end a=a+1 end elseif not(z==277)then w[y[537]]=w[y[444]][y[151]];else local a=y[537];local c=w[a];for e=a+1,y[444]do t(c,w[e])end;end;elseif 278>=z then local a,c,e,m=0 while true do if a<=15 then if a<=7 then if a<=3 then if a<=1 then if a>0 then e=nil else c=nil end else if a<3 then m=nil else w[y[537]]=h[y[444]];end end else if a<=5 then if a<5 then n=n+1;else y=f[n];end else if 7~=a then w[y[537]]=w[y[444]][y[151]];else n=n+1;end end end else if a<=11 then if a<=9 then if a~=9 then y=f[n];else w[y[537]]=h[y[444]];end else if a>10 then y=f[n];else n=n+1;end end else if a<=13 then if a<13 then w[y[537]]=w[y[444]][y[151]];else n=n+1;end else if 15>a then y=f[n];else w[y[537]]=w[y[444]][w[y[151]]];end end end end else if a<=23 then if a<=19 then if a<=17 then if 16<a then y=f[n];else n=n+1;end else if a<19 then w[y[537]]=h[y[444]];else n=n+1;end end else if a<=21 then if 20==a then y=f[n];else w[y[537]]=w[y[444]][y[151]];end else if 23>a then n=n+1;else y=f[n];end end end else if a<=27 then if a<=25 then if 24==a then w[y[537]]=w[y[444]][y[151]];else n=n+1;end else if 26<a then m=y[444];else y=f[n];end end else if a<=29 then if a~=29 then e=y[151];else c=k(w,g,m,e);end else if a<31 then w[y[537]]=c;else break end end end end end a=a+1 end elseif 279<z then local a,c=0 while true do if a<=10 then if a<=4 then if a<=1 then if 0==a then c=nil else w[y[537]]=j[y[444]];end else if a<=2 then n=n+1;else if a>3 then w[y[537]]=w[y[444]][y[151]];else y=f[n];end end end else if a<=7 then if a<=5 then n=n+1;else if a~=7 then y=f[n];else w[y[537]]=y[444];end end else if a<=8 then n=n+1;else if 9<a then w[y[537]]=y[444];else y=f[n];end end end end else if a<=15 then if a<=12 then if a>11 then y=f[n];else n=n+1;end else if a<=13 then w[y[537]]=y[444];else if a>14 then y=f[n];else n=n+1;end end end else if a<=18 then if a<=16 then w[y[537]]=y[444];else if 18>a then n=n+1;else y=f[n];end end else if a<=19 then c=y[537]else if 20<a then break else w[c]=w[c](r(w,c+1,y[444]))end end end end end a=a+1 end else w[y[537]][y[444]]=y[151];end;elseif z<=327 then if z<=303 then if z<=291 then if 285>=z then if z<=282 then if 282>z then local a;w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];a=y[537]w[a]=w[a](r(w,a+1,y[444]))else w[y[537]]={r({},1,y[444])};end;elseif 283>=z then w[y[537]]=(w[y[444]]/y[151]);elseif z<285 then if not w[y[537]]then n=n+1;else n=y[444];end;else w[y[537]]=false;end;elseif 288>=z then if z<=286 then w[y[537]]();elseif z==287 then w[y[537]]=y[444]*w[y[151]];else local a;local c;local e;w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][w[y[151]]];n=n+1;y=f[n];e=y[537]c={w[e](w[e+1])};a=0;for m=e,y[151]do a=a+1;w[m]=c[a];end end;elseif z<=289 then if(w[y[537]]==w[y[151]]or w[y[537]]<w[y[151]])then n=y[444];else n=n+1;end;elseif z>290 then local a;w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];a=y[537]w[a]=w[a](r(w,a+1,y[444]))else local a=y[537];p=a+x-1;for c=a,p do local a=q[c-a];w[c]=a;end;end;elseif 297>=z then if(z==294 or z<294)then if(292>=z)then local a,c,e,m=0 while true do if a<=9 then if a<=4 then if a<=1 then if a<1 then c=nil else e=nil end else if a<=2 then m=nil else if 3==a then w[y[537]]=h[y[444]];else n=n+1;end end end else if a<=6 then if a>5 then w[y[537]]=h[y[444]];else y=f[n];end else if a<=7 then n=n+1;else if 8==a then y=f[n];else w[y[537]]=w[y[444]][y[151]];end end end end else if a<=14 then if a<=11 then if a~=11 then n=n+1;else y=f[n];end else if a<=12 then w[y[537]]=w[y[444]][w[y[151]]];else if 13==a then n=n+1;else y=f[n];end end end else if a<=16 then if a~=16 then m=y[537]else e={w[m](w[m+1])};end else if a<=17 then c=0;else if 19>a then for v=m,y[151]do c=c+1;w[v]=e[c];end else break end end end end end a=a+1 end elseif not(293~=z)then local a=y[537];do return w[a](r(w,(a+1),y[444]))end;else local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if 1~=a then c=nil else w[y[537]][y[444]]=w[y[151]];end else if 2<a then y=f[n];else n=n+1;end end else if a<=5 then if a<5 then w[y[537]]={};else n=n+1;end else if a>6 then w[y[537]][y[444]]=y[151];else y=f[n];end end end else if a<=11 then if a<=9 then if a==8 then n=n+1;else y=f[n];end else if 10==a then w[y[537]][y[444]]=w[y[151]];else n=n+1;end end else if a<=13 then if a~=13 then y=f[n];else c=y[537]end else if a==14 then w[c]=w[c](r(w,c+1,y[444]))else break end end end end a=a+1 end end;elseif(295>=z)then local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if 0<a then w[y[537]]=j[y[444]];else c=nil end else if 3~=a then n=n+1;else y=f[n];end end else if a<=5 then if 4<a then n=n+1;else w[y[537]]=w[y[444]][y[151]];end else if 7~=a then y=f[n];else w[y[537]]=h[y[444]];end end end else if a<=11 then if a<=9 then if a>8 then y=f[n];else n=n+1;end else if 10<a then n=n+1;else w[y[537]]=w[y[444]][y[151]];end end else if a<=13 then if 13>a then y=f[n];else c=y[537]end else if a<15 then w[c]=w[c](w[c+1])else break end end end end a=a+1 end elseif(z>296)then w[y[537]]=w[y[444]]%y[151];else local a=0 while true do if a<=9 then if a<=4 then if a<=1 then if a<1 then w[y[537]][y[444]]=y[151];else n=n+1;end else if a<=2 then y=f[n];else if a>3 then n=n+1;else w[y[537]]={};end end end else if a<=6 then if 5<a then w[y[537]][y[444]]=w[y[151]];else y=f[n];end else if a<=7 then n=n+1;else if 9~=a then y=f[n];else w[y[537]]=h[y[444]];end end end end else if a<=14 then if a<=11 then if a~=11 then n=n+1;else y=f[n];end else if a<=12 then w[y[537]]=w[y[444]][y[151]];else if a~=14 then n=n+1;else y=f[n];end end end else if a<=16 then if 16>a then w[y[537]][y[444]]=w[y[151]];else n=n+1;end else if a<=17 then y=f[n];else if 19>a then w[y[537]][y[444]]=w[y[151]];else break end end end end end a=a+1 end end;elseif z<=300 then if z<=298 then local a;local c;local e;w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][w[y[151]]];n=n+1;y=f[n];e=y[537]c={w[e](w[e+1])};a=0;for m=e,y[151]do a=a+1;w[m]=c[a];end elseif z>299 then w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][w[y[151]]];n=n+1;y=f[n];if(w[y[537]]~=y[151])then n=n+1;else n=y[444];end;else w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][w[y[151]]];n=n+1;y=f[n];if(w[y[537]]~=y[151])then n=n+1;else n=y[444];end;end;elseif 301>=z then local a;w[y[537]][y[444]]=w[y[151]];n=n+1;y=f[n];w[y[537]]={};n=n+1;y=f[n];w[y[537]][y[444]]=y[151];n=n+1;y=f[n];w[y[537]][y[444]]=w[y[151]];n=n+1;y=f[n];a=y[537]w[a]=w[a](r(w,a+1,y[444]))elseif 302==z then w[y[537]][y[444]]=y[151];n=n+1;y=f[n];w[y[537]]={};n=n+1;y=f[n];w[y[537]][y[444]]=w[y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]][y[444]]=w[y[151]];n=n+1;y=f[n];w[y[537]][y[444]]=w[y[151]];else local a;local c;local e;w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];e=y[444];c=y[151];a=k(w,g,e,c);w[y[537]]=a;end;elseif 315>=z then if 309>=z then if 306>=z then if(z<=304)then local a=y[537]local c={w[a](r(w,a+1,p))};local e=0;for m=a,y[151]do e=(e+1);w[m]=c[e];end elseif(306~=z)then local a,c=0 while true do if a<=12 then if a<=5 then if a<=2 then if a<=0 then c=nil else if 1==a then w={};else for e=0,u,1 do if e<o then w[e]=s[e+1];else break;end;end;end end else if a<=3 then n=n+1;else if 5~=a then y=f[n];else w[y[537]]=h[y[444]];end end end else if a<=8 then if a<=6 then n=n+1;else if 7==a then y=f[n];else w[y[537]]=j[y[444]];end end else if a<=10 then if 10~=a then n=n+1;else y=f[n];end else if a>11 then n=n+1;else w[y[537]]=w[y[444]][y[151]];end end end end else if a<=18 then if a<=15 then if a<=13 then y=f[n];else if 14==a then w[y[537]]=y[444];else n=n+1;end end else if a<=16 then y=f[n];else if 18>a then w[y[537]]=y[444];else n=n+1;end end end else if a<=21 then if a<=19 then y=f[n];else if a>20 then n=n+1;else w[y[537]]=y[444];end end else if a<=23 then if 23>a then y=f[n];else c=y[537]end else if 25~=a then w[c]=w[c](r(w,c+1,y[444]))else break end end end end end a=a+1 end else local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if a==0 then c=nil else w[y[537]]=h[y[444]];end else if a==2 then n=n+1;else y=f[n];end end else if a<=5 then if a<5 then w[y[537]]=y[444];else n=n+1;end else if a>6 then w[y[537]]=y[444];else y=f[n];end end end else if a<=11 then if a<=9 then if 8==a then n=n+1;else y=f[n];end else if a<11 then w[y[537]]=y[444];else n=n+1;end end else if a<=13 then if a~=13 then y=f[n];else c=y[537]end else if 15>a then w[c]=w[c](r(w,c+1,y[444]))else break end end end end a=a+1 end end;elseif z<=307 then do return end;elseif not(309==z)then w[y[537]]=w[y[444]];else local a,c,e,m=0 while true do if a<=15 then if a<=7 then if a<=3 then if a<=1 then if 0==a then c=nil else e=nil end else if 2<a then w[y[537]]=h[y[444]];else m=nil end end else if a<=5 then if 4==a then n=n+1;else y=f[n];end else if 6==a then w[y[537]]=w[y[444]][y[151]];else n=n+1;end end end else if a<=11 then if a<=9 then if 9>a then y=f[n];else w[y[537]]=h[y[444]];end else if 10<a then y=f[n];else n=n+1;end end else if a<=13 then if a<13 then w[y[537]]=w[y[444]][y[151]];else n=n+1;end else if 15~=a then y=f[n];else w[y[537]]=w[y[444]][w[y[151]]];end end end end else if a<=23 then if a<=19 then if a<=17 then if a~=17 then n=n+1;else y=f[n];end else if 19~=a then w[y[537]]=h[y[444]];else n=n+1;end end else if a<=21 then if a==20 then y=f[n];else w[y[537]]=w[y[444]][y[151]];end else if a==22 then n=n+1;else y=f[n];end end end else if a<=27 then if a<=25 then if a==24 then w[y[537]]=w[y[444]][y[151]];else n=n+1;end else if 27>a then y=f[n];else m=y[444];end end else if a<=29 then if 28==a then e=y[151];else c=k(w,g,m,e);end else if 31~=a then w[y[537]]=c;else break end end end end end a=a+1 end end;elseif 312>=z then if z<=310 then w={};for a=0,u,1 do if a<o then w[a]=s[a+1];else break;end;end;elseif z>311 then local a;local c;local e;w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][w[y[151]]];n=n+1;y=f[n];e=y[537]c={w[e](w[e+1])};a=0;for m=e,y[151]do a=a+1;w[m]=c[a];end else local a;w[y[537]]={};n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]][y[444]]=w[y[151]];n=n+1;y=f[n];w[y[537]]=j[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=j[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];a=y[537]w[a]=w[a]()end;elseif 313>=z then local a=y[537]w[a](w[a+1])elseif z~=315 then w={};for a=0,u,1 do if a<o then w[a]=s[a+1];else break;end;end;else if(w[y[537]]~=w[y[151]])then n=y[444];else n=n+1;end;end;elseif z<=321 then if z<=318 then if z<=316 then w[y[537]]=w[y[444]][w[y[151]]];elseif z>317 then w[y[537]]=b(d[y[444]],nil,j);else local a;w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]]*y[151];n=n+1;y=f[n];w[y[537]]=w[y[444]]+w[y[151]];n=n+1;y=f[n];w[y[537]]=j[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]]+w[y[151]];n=n+1;y=f[n];a=y[537]w[a]=w[a](r(w,a+1,y[444]))end;elseif z<=319 then local a=y[537]w[a](w[(a+1)])elseif z~=321 then do return w[y[537]]end else w={};for a=0,u,1 do if a<o then w[a]=s[a+1];else break;end;end;n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]={};n=n+1;y=f[n];w[y[537]]={};n=n+1;y=f[n];w[y[537]][y[444]]=w[y[151]];n=n+1;y=f[n];w[y[537]]=j[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];if w[y[537]]then n=n+1;else n=y[444];end;end;elseif z<=324 then if 322>=z then local a=y[537];do return r(w,a,p)end;elseif z~=324 then local a;w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=false;n=n+1;y=f[n];a=y[537]w[a](w[a+1])else w[y[537]]={r({},1,y[444])};end;elseif z<=325 then local a;w[y[537]][y[444]]=w[y[151]];n=n+1;y=f[n];w[y[537]]={};n=n+1;y=f[n];w[y[537]][y[444]]=y[151];n=n+1;y=f[n];w[y[537]][y[444]]=w[y[151]];n=n+1;y=f[n];a=y[537]w[a]=w[a](r(w,a+1,y[444]))elseif 326<z then local a=y[537];do return w[a],w[a+1]end else local a=y[537]w[a](r(w,a+1,y[444]))end;elseif z<=350 then if z<=338 then if z<=332 then if z<=329 then if z==328 then if(w[y[537]]~=w[y[151]])then n=n+1;else n=y[444];end;else h[y[444]]=w[y[537]];end;elseif 330>=z then local a;w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];a=y[537]w[a]=w[a](r(w,a+1,y[444]))elseif z==331 then if(w[y[537]]~=w[y[151]])then n=n+1;else n=y[444];end;else local a;w[y[537]]=j[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];a=y[537]w[a]=w[a](r(w,a+1,y[444]))end;elseif 335>=z then if 333>=z then local a=y[537]local c={w[a](w[a+1])};local d=0;for e=a,y[151]do d=d+1;w[e]=c[d];end elseif 334==z then local a;w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];a=y[537]w[a]=w[a](r(w,a+1,y[444]))else local a;local c;local d;w[y[537]]=j[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];d=y[537]c={w[d](w[d+1])};a=0;for e=d,y[151]do a=a+1;w[e]=c[a];end end;elseif z<=336 then local a;local c;local d;w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][w[y[151]]];n=n+1;y=f[n];d=y[537]c={w[d](w[d+1])};a=0;for e=d,y[151]do a=a+1;w[e]=c[a];end elseif 337==z then local a;local c;local d;w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][w[y[151]]];n=n+1;y=f[n];d=y[537]c={w[d](w[d+1])};a=0;for e=d,y[151]do a=a+1;w[e]=c[a];end else local a;local c;w[y[537]]={};n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]={};n=n+1;y=f[n];w[y[537]]={};n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]][y[444]]=w[y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]][y[444]]=w[y[151]];n=n+1;y=f[n];w[y[537]][y[444]]=w[y[151]];n=n+1;y=f[n];w[y[537]]={r({},1,y[444])};n=n+1;y=f[n];w[y[537]]=w[y[444]];n=n+1;y=f[n];c=y[537];a=w[c];for d=c+1,y[444]do t(a,w[d])end;end;elseif 344>=z then if 341>=z then if(339>=z)then local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if a~=1 then c=nil else w[y[537]]=h[y[444]];end else if 2==a then n=n+1;else y=f[n];end end else if a<=5 then if a<5 then w[y[537]]=w[y[444]][y[151]];else n=n+1;end else if 6==a then y=f[n];else w[y[537]]=y[444];end end end else if a<=11 then if a<=9 then if 9>a then n=n+1;else y=f[n];end else if 11~=a then w[y[537]]=y[444];else n=n+1;end end else if a<=13 then if a<13 then y=f[n];else c=y[537]end else if 14<a then break else w[c]=w[c](r(w,c+1,y[444]))end end end end a=a+1 end elseif z<341 then if(w[y[537]]<w[y[151]]or w[y[537]]==w[y[151]])then n=y[444];else n=(n+1);end;else local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if a<1 then c=nil else w[y[537]]=w[y[444]];end else if a==2 then n=n+1;else y=f[n];end end else if a<=5 then if a==4 then w[y[537]]=y[444];else n=n+1;end else if 6<a then w[y[537]]=y[444];else y=f[n];end end end else if a<=11 then if a<=9 then if a~=9 then n=n+1;else y=f[n];end else if 10<a then n=n+1;else w[y[537]]=y[444];end end else if a<=13 then if a==12 then y=f[n];else c=y[537]end else if 14<a then break else w[c]=w[c](r(w,c+1,y[444]))end end end end a=a+1 end end;elseif 342>=z then local a=0 while true do if a<=6 then if a<=2 then if a<=0 then w[y[537]]=w[y[444]][y[151]];else if a>1 then y=f[n];else n=n+1;end end else if a<=4 then if a<4 then w[y[537]]=w[y[444]][y[151]];else n=n+1;end else if 6~=a then y=f[n];else w[y[537]]=w[y[444]][y[151]];end end end else if a<=9 then if a<=7 then n=n+1;else if a~=9 then y=f[n];else w[y[537]][y[444]]=w[y[151]];end end else if a<=11 then if a~=11 then n=n+1;else y=f[n];end else if 12<a then break else n=y[444];end end end end a=a+1 end elseif 343<z then w={};for a=0,u,1 do if a<o then w[a]=s[a+1];else break;end;end;n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][w[y[151]]];n=n+1;y=f[n];if(w[y[537]]~=y[151])then n=n+1;else n=y[444];end;else local a;w[y[537]]=j[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];a=y[537]w[a]=w[a](r(w,a+1,y[444]))end;elseif 347>=z then if(345>=z)then if not w[y[537]]then n=n+1;else n=y[444];end;elseif 346==z then local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if a<1 then c=nil else w[y[537]]=h[y[444]];end else if 2==a then n=n+1;else y=f[n];end end else if a<=5 then if a~=5 then w[y[537]]=y[444];else n=n+1;end else if a==6 then y=f[n];else w[y[537]]=y[444];end end end else if a<=11 then if a<=9 then if 9~=a then n=n+1;else y=f[n];end else if 10<a then n=n+1;else w[y[537]]=y[444];end end else if a<=13 then if a~=13 then y=f[n];else c=y[537]end else if a~=15 then w[c]=w[c](r(w,c+1,y[444]))else break end end end end a=a+1 end else local a,c=0 while true do if a<=14 then if a<=6 then if a<=2 then if a<=0 then c=nil else if a==1 then w[y[537]]=w[y[444]][y[151]];else n=n+1;end end else if a<=4 then if a~=4 then y=f[n];else w[y[537]]=w[y[444]][y[151]];end else if a<6 then n=n+1;else y=f[n];end end end else if a<=10 then if a<=8 then if a==7 then w[y[537]]=w[y[444]][y[151]];else n=n+1;end else if a~=10 then y=f[n];else w[y[537]]=w[y[444]]*y[151];end end else if a<=12 then if a<12 then n=n+1;else y=f[n];end else if 14>a then w[y[537]]=w[y[444]]+w[y[151]];else n=n+1;end end end end else if a<=22 then if a<=18 then if a<=16 then if 16~=a then y=f[n];else w[y[537]]=j[y[444]];end else if a==17 then n=n+1;else y=f[n];end end else if a<=20 then if 20~=a then w[y[537]]=w[y[444]][y[151]];else n=n+1;end else if a~=22 then y=f[n];else w[y[537]]=w[y[444]];end end end else if a<=26 then if a<=24 then if 23<a then y=f[n];else n=n+1;end else if a<26 then w[y[537]]=w[y[444]]+w[y[151]];else n=n+1;end end else if a<=28 then if a<28 then y=f[n];else c=y[537]end else if a==29 then w[c]=w[c](r(w,c+1,y[444]))else break end end end end end a=a+1 end end;elseif 348>=z then local a=y[537]w[a]=w[a]()elseif z~=350 then local a;w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]={};n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]={};n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];a=y[537]w[a]=w[a]()else local a=y[537]w[a]=w[a](r(w,a+1,p))end;elseif 362>=z then if z<=356 then if z<=353 then if 351>=z then local a;local c;local d;w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][w[y[151]]];n=n+1;y=f[n];d=y[537]c={w[d](w[d+1])};a=0;for e=d,y[151]do a=a+1;w[e]=c[a];end elseif z==352 then local a=y[444];local c=y[151];local a=k(w,g,a,c);w[y[537]]=a;else local a=y[537];p=a+x-1;for c=a,p do local a=q[c-a];w[c]=a;end;end;elseif z<=354 then local a;w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];a=y[537]w[a]=w[a](r(w,a+1,y[444]))elseif 355==z then w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]][y[444]]=w[y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];if(w[y[537]]~=w[y[151]])then n=n+1;else n=y[444];end;else local a;w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];w[y[537]]=y[444];n=n+1;y=f[n];a=y[537]w[a]=w[a](r(w,a+1,y[444]))end;elseif 359>=z then if z<=357 then local a;w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]]*y[151];n=n+1;y=f[n];w[y[537]]=w[y[444]]+w[y[151]];n=n+1;y=f[n];w[y[537]]=j[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]]+w[y[151]];n=n+1;y=f[n];a=y[537]w[a]=w[a](r(w,a+1,y[444]))elseif 358<z then local a;w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]]*y[151];n=n+1;y=f[n];w[y[537]]=w[y[444]]+w[y[151]];n=n+1;y=f[n];w[y[537]]=j[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]]+w[y[151]];n=n+1;y=f[n];a=y[537]w[a]=w[a](r(w,a+1,y[444]))else w[y[537]]=w[y[444]]+w[y[151]];end;elseif z<=360 then local a=0 while true do if a<=12 then if a<=5 then if a<=2 then if a<=0 then w[y[537]]=y[444];else if a==1 then n=n+1;else y=f[n];end end else if a<=3 then w[y[537]]=w[y[444]][w[y[151]]];else if a==4 then n=n+1;else y=f[n];end end end else if a<=8 then if a<=6 then w[y[537]]=y[444];else if a>7 then y=f[n];else n=n+1;end end else if a<=10 then if 10~=a then w[y[537]]=w[y[444]][w[y[151]]];else n=n+1;end else if 11<a then w[y[537]]=j[y[444]];else y=f[n];end end end end else if a<=18 then if a<=15 then if a<=13 then n=n+1;else if a==14 then y=f[n];else w[y[537]]=y[444];end end else if a<=16 then n=n+1;else if 17==a then y=f[n];else w[y[537]]=w[y[444]][w[y[151]]];end end end else if a<=21 then if a<=19 then n=n+1;else if a>20 then for c=y[537],y[444],1 do w[c]=nil;end;else y=f[n];end end else if a<=23 then if a~=23 then n=n+1;else y=f[n];end else if 25~=a then w[y[537]]=j[y[444]];else break end end end end end a=a+1 end elseif 361==z then local a;local c;local d;w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][w[y[151]]];n=n+1;y=f[n];d=y[537]c={w[d](w[d+1])};a=0;for e=d,y[151]do a=a+1;w[e]=c[a];end else local a;w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];a=y[537]w[a]=w[a](w[a+1])end;elseif 368>=z then if z<=365 then if(z==363 or z<363)then local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if a~=1 then c=nil else w[y[537]]=h[y[444]];end else if a~=3 then n=n+1;else y=f[n];end end else if a<=5 then if a~=5 then w[y[537]]=w[y[444]][y[151]];else n=n+1;end else if 7~=a then y=f[n];else w[y[537]]=y[444];end end end else if a<=11 then if a<=9 then if 8<a then y=f[n];else n=n+1;end else if 11~=a then w[y[537]]=y[444];else n=n+1;end end else if a<=13 then if 12<a then c=y[537]else y=f[n];end else if a>14 then break else w[c]=w[c](r(w,c+1,y[444]))end end end end a=a+1 end elseif(z<365)then if(w[y[537]]<w[y[151]]or w[y[537]]==w[y[151]])then n=n+1;else n=y[444];end;else local a=y[537]w[a](r(w,a+1,y[444]))end;elseif z<=366 then local a;local c;local d;w[y[537]]=j[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];d=y[537]c={w[d](w[d+1])};a=0;for e=d,y[151]do a=a+1;w[e]=c[a];end elseif z==367 then w[y[537]][y[444]]=y[151];else w[y[537]][w[y[444]]]=w[y[151]];end;elseif z<=371 then if 369>=z then local a,c=0 while true do if a<=12 then if a<=5 then if a<=2 then if a<=0 then c=nil else if 1<a then for d=0,u,1 do if d<o then w[d]=s[d+1];else break;end;end;else w={};end end else if a<=3 then n=n+1;else if 5~=a then y=f[n];else w[y[537]]=h[y[444]];end end end else if a<=8 then if a<=6 then n=n+1;else if a>7 then w[y[537]]=j[y[444]];else y=f[n];end end else if a<=10 then if a==9 then n=n+1;else y=f[n];end else if a<12 then w[y[537]]=w[y[444]][y[151]];else n=n+1;end end end end else if a<=18 then if a<=15 then if a<=13 then y=f[n];else if 15>a then w[y[537]]=y[444];else n=n+1;end end else if a<=16 then y=f[n];else if 17==a then w[y[537]]=y[444];else n=n+1;end end end else if a<=21 then if a<=19 then y=f[n];else if a==20 then w[y[537]]=y[444];else n=n+1;end end else if a<=23 then if 22==a then y=f[n];else c=y[537]end else if a>24 then break else w[c]=w[c](r(w,c+1,y[444]))end end end end end a=a+1 end elseif 370==z then local a;w[y[537]][y[444]]=w[y[151]];n=n+1;y=f[n];w[y[537]]={};n=n+1;y=f[n];w[y[537]][y[444]]=y[151];n=n+1;y=f[n];w[y[537]][y[444]]=w[y[151]];n=n+1;y=f[n];a=y[537]w[a]=w[a](r(w,a+1,y[444]))else w={};for a=0,u,1 do if a<o then w[a]=s[a+1];else break;end;end;n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=h[y[444]];n=n+1;y=f[n];w[y[537]]={};n=n+1;y=f[n];w[y[537]]={};n=n+1;y=f[n];w[y[537]][y[444]]=w[y[151]];n=n+1;y=f[n];w[y[537]]=j[y[444]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];if w[y[537]]then n=n+1;else n=y[444];end;end;elseif z<=372 then w[y[537]]=j[y[444]];elseif 373==z then local a=y[537]local c,d=i(w[a](w[a+1]))p=d+a-1 local d=0;for e=a,p do d=d+1;w[e]=c[d];end;else w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]]=w[y[444]][y[151]];n=n+1;y=f[n];w[y[537]][y[444]]=w[y[151]];n=n+1;y=f[n];n=y[444];end;n=n+1;end;end;end;return b(cr(),{},l())();end)('21F21D24G21D25A1312121127A27D27E1727D23623422Z23023A1227G27A23A22R22O23222V121427D22P23123022P22R27M27W27A23523A27J23022T121627X22Y22R23428B27D23328222Y121027D23123527N27D22U22V22O23B28A28C27P22R23522X121B27X23123423123B23A27K27U28Y1222S27K22U121527D22T22V23A22S22V23023827V27D23B23023622R22P29227O1223628123223229I29K29M27K22S23128H27A2A92AB1E27D23529M23329M28227R27T27B27D23422V2362AP28523B22O28R27A28J23A22P28L1A27D23A28P28727K28A2841227K2AI23427M29D22T2352AW1227927A21S27C27E1222G21U1228L27A21Z23022B26E23M22I21G26025X21W24I27126K25Q2641C23E21X21C1T26027023A191Y2722161Q23D26X1T22023Y24F26X23G21722G23H1722825921823N22Y26J25Z25G22I1Y25022R21H26Z25726P22524U25Z25M24T2712471E26Q26023R21421M25L23I22S21223A21623G25X273172262721426I23I26Z27026F24U1C21625I26L24O24B24322S21421H22P26Y23125A26Y26M2AC122171P21E2432BL27D2172EZ27A1K2F21221G2AU121S21B2AG2BM29S2FD1X2F822Q1823C2ET1X1P21P23P121927D1F1O21324625T21R21Y24U25821325J1222B27D21B2FU24626P22O1R26V24N21125X25V23V24N24O22S1F21321X23225923Y1L22U22423U2272381D25Z23I21326B24W24R1T21X21O1I22Y1525Q22126P21K23U24U26J1A2282651L22C23Z2662591026N24826Z23M24026U22V24C26V26O21S22B2591R182271522M1P24X25T22Z21N24F122AG27A1P2211W25O24Q2381P26P26O21J23S26128M27D22Q22L122F427A1D21R1S24O24I21Q2292572561W25N24323V26M2562311J21522D23D26A264121N2FS21K1725224I21422924P24G1X25T23T25O24O25922T1M1W22C21326W2BQ2A627A1L1D21624U26B21O22629S27A1F1321Q23Z26F2152AY12181R21P23N26O2KB27V131S24126K2FY2FQ27D1N1U21M24026B21A22923S25521D25T2KZ2L82LA2LC229121F27D23G1721M23U26M23E2D124Z21125Z241248122B42KL1P21Q23R26K21H22L258121Q27D191323723M26F21O22D24T25521C23M23X23K24V24L22X1822T22E23624T2421I2142LO2LQ2LS2LU23E21W24Q25821E25F23T23T2MD2MF2MH24626O21F21U25524H1X2MQ2MS2MU2MW2MY2N02N2121J2N52LT2LV2N92NB2ND23T25A24W23D2FR1R2NH2372NJ2NL2NN1X23T26524C24I2592391V21J1G23F25323T1O2312792LP27A2LR2O023E22F25325621F25O24824E2NG27A2MG23723P26L21H21V25224W21I2NQ2MT2MV2MX2MZ2N12N32FR2OX2N62LV22J24V2571X25S2IY2OB23T26T21G22924Q2Q225Q24C24524R24U2181S21621X2372582652IF2NZ2N722K25325421925J23Y121L2OB23Y26L21J22L25924M22S25U24123X25325523I22I1Z22N22W25224822F2N42OX1Q21O23Z26E2LW2592LY2M02M21I2FS2M62M82MA25823R21725P23T25824V24U2FK2OW1223G2RH2RJ2N82NA2NC2NE2NX2LQ2S72RK2O22SB2O52O72FR2S42S62RI2RK2P12P32P52P72PQ2S52SF23E2PU2PW2PY2IG2SV2SO23E2QM2QO2QQ2RF2S52LS23P26H2RL2RN2M1122KR27A1U1321225I26G21B21Z24S26T1Z2RY25O24L2512331H2K621P25A23Y1P22S1223U21U23J22H24E23G21126J25B23P22K1H2181F22W21O25T1M2T82OY2TB2S92O32SC2NY2PR21M2UQ2SH2O42O62O82UO2TA2TC2SQ2P42P62L62UV2UQ2SY2PX2QJ2V92TC2T52QP2QR2T123G1E21E23S2J522925A25021D25Q2NF22Q27D2TJ2TL26I21N21U25926T21225J24823M26M24O22X1N21H22N23325523Y1V22T22J26622023F1N24723C21824G25B24I21A22621H1S23221Q25W21U26C22223T25224Q23E21Y25D1H2HM25U24E1Z24426V27224425N24N21A23P25926A21V22126H22421W21U1N22B1F26T25M2132122412352481D26325P26623Y22P21V24O24826427226821W2KT27D22V1V21I2PC21G22824R26T1P2VD2S52VL2VN21621Y24X24J21125Y2RP2LQ2YV24I2YX2YZ2Z12482OJ24P23J2YT2VK2VM24I21L22J2532Z625J23Z2YI2OX2Z52PE2PG21I2V82YU2ZG21E22J2512582JY121C2LQ1021O23O2681Z1K25824W1Y25F23S23K2562SD2KC191Z23U26J21L22D24S24W1W26P23T23N25825922Z1V2KZ2111921J24126B21421Z2T8141021M23N26K21A23G2552571W25Q2V71D27D1J1921R23N26Q21H21Y24S23L21726M24223Y24S24L31023104310631081K24O24N21925W24C24824R121G31233107310931273129312B24R24S22O1F2ZT31032OX3105312H1K2J821725X2432RZ2ZE312T31252ZK2162ZM2UO3132310924W25621525N2482IE2UU2S51V21N24326U21Q2SY22S25I24823U24V24P22O2AG313G23G313I313K313M2PV2R123Z23P25425923C310Z2JO2OX313Y313L313N25U31433145314721H22K22W312D313W314B314025722S25D24223N25524Y2MV12311L314A313J314C314125P23U23M2QA122RQ314Z313Z313N25M24223L24N2552ZD31582S51021E23L26821N22F24Z26T1W25J24B23X25724W2FK315I23G315K315M315O315Q21G25S24424A24V2W9122UN312S315L315N315P2Q2316631682W91A2152GO31573104316E316326T21325P24224B24G2R63122316D3162316G312X312Z2MC314Y315J316Q316G21825P24023P24R24V121H2LQ1821I24526U21422J24H25421125U26523S24R2JF1F2152YH2M429I1D1W23N25U21N311T317G317I317K317M317O317Q317S24C25825123E1R21D22D2QS3189317L317N317P317R2OI318G318I318K23125023T29J317H2OX317J318O318C318R23Z24H24Z23F1K1W2BT313W3192318B318Q317S314T314V18312E318N319F318D26523O24H24X22T2YL316O2OX1O2OG26M21I2Q4315R315T315V315X122202G62G82GA2GC2GE2GG2GI2GK2GM2GO2GQ2GS2GU2GW2GY2H02H22H42H62H82HA2HC2HE2HG1P2252611E22C24526723M22Q25F25224J25F25U26B23G24D25026J22122L24S2281822B2JO315Z319X23T319Z31A1316531673169292316C2S531BN31BP2Q531BR316J22X316L316N31BM319Y31A02Q5316T316V316X23I316Z31BW31C631A131733130317623G31BX31C726T317A317C317E310I2S52L92TB317N250255313O313Q313S313U31A631A82FV31AA2GD2GF2GH2GJ2GL2GN2GP2GR2GT2GV2GX2GZ2H12H32H52H72H92HB2HD2HF26J31AW31AY31B031B231B431B631B826D22V241315Q21Z22E24L31BI31BK31CR23G31CT26H31CV31CX314E3144314631482LQ31E931EB314231EE314H314J314L31EH2UW31EA22J31CW314Q314S314U314W31CJ31EI31ES31CX3153315524U319V31CS31EQ31EJ315C315E315G31F523G1F21N23Z26Q21J22D25231A2315U315W2FK22331D32G92GB31D631AD31D931AG31DC31AJ31DF31AM31DI31AP31DL31AS31DO31AV31AX31AZ31B131B331B531B725U26S22U24B24O26I22122C26F1I1H3117315Z31FE31FG31FI31FK31C031BT316B2LQ31GQ31FH31FJ316H31BS316K316M2A531GP31FF31GZ31FK31C9316W316Y312R2S531GY31GS26T31CH317531GX31H731HG31CO317D317F31HD23G1K21623U26F1Y310A310C310E310G1221X31FQ31D531AC31D831AF31DB31AI31DE31AL31DH31AO31DK31AR31DN31AU31DQ31G731DT31GA31DW25U26N23B24E2592731622E258310Z31HQ31HS31HU31HW312J312A312C319L2OX31IY31HV3126312831J2312M312O312Q2LQ31J631HW312W312Y31302VJ31JF1K313431362SM31JL313A313C313E314X2LQ1621O24526J21N22K26W24X1X25G24C24924I24O1222231I331FS31I531AE31DA31AH31DD31AK31DG31AN31DJ31AQ31DM31AT31DP31DR31G831DU31GB31B827122P23L24X26E21S1K24L1B29J31CJ31JW31JY31K026W24L21I25N23V23X25625531882OX31L731JZ31K131LB31LD31LF25523G1M21C21V31JU31LJ31JX31LL26W2522RX315431562SM31LK31L92SR2V731HQ31M531K125921725R24423T25931LV2S51A1X23N26F1W22931K231K431K631K831MI23G31MK31MM31MO31LA31LC31LE31LG31LI31MJ31ML31MN31MP31LN31N131LQ31LS31LU31CJ31MW31N631LZ31M131F32UO31NE31MY31M72P731HQ31NK31MP31MC31ME31MG31E72FN23K26O21R22924I24W31CY313R313T313V2LQ31NV31NX31NZ31O131ED314G31EG2OX31O731NY31O031EK31OC314I314K31NU21P31NW31OG31O1314R319I31EX31O631ON31O831OH31F23156315Z31OF31O922S31F9315F2ZD31HQ1F1X23R26P21E31HX310D310F310H31P731P931PB31J8312K31J3312F2OX31P831PA31PC31J1312L312N312P31CD31FD31PI31PC31JH31742ZE31PP31PJ31JN2ZN2SM31Q331PC31JR313D2IE31CJ1E21631NW21H22I31MQ31K531K731K92T1141331ML3185315P2501Z2T729J27A31QO31ML25H21B2IX319K27A101P21M25126F21421U24X2522FG2942F331P831MM21G23724T2MC2A0111U21E23V26F2KK2BL311O23N26U21R122KJ2TI2TK24424I315O2J821D25O2K024M25923J22I21322D23C2522641I23022624B22M23J1T26123F21327025B23Z1L21W21G1S23721L25V22324J1524E24L26C1E21Z25I1E21Y26325W24723126Z24K24V23X24B26W23G25U31IR22G22E24M1N1G2271O22522A31MU31QE31QG31QI31N831LP31N32VK31QF26O31QH31MZ31LO31LG31LR31LT31U031U831UA31M031OY31F42SM31U131U931QI31NM31PW31UN31UA31NR31MF31MH31HQ1V21323N26B21I31PD31HZ31PG2LQ31UY31V031V231PS31PM31V631UZ31V131PK31JA31PU31JD314A31VD31V231Q031JJ31VC31V831JM2ZL31Q631VO31VE31QA31JT313W2FN23Z26K21C2J724H31O231D031O531OE21P31VZ31W125731W331OB31EF2JN31OU31W931W231OI31EF31OK31EO31W731WH31WB31EU31OS319K31CJ31VY31W031WI31UK31FC31WU31WA31W331P431FB31CJ1O21O23L26D31A031QJ31MS31K92S4181S21323Z26L21G21Z24A24G21C25Y24223M2T821431XF31XH31XJ25631XM31XO31XQ31X431X631X831N731N031U5319031BW31Y131X931U431UD31NB31MU31X531X731X931UJ31M231UL2LQ31YE31Y226W31UQ31HQ31YL31X931UU31NT2VJ1V21M2422VO2VQ2VS2NF31YU31YW2Z62YY2Z02Z231FC31YV31YX2Z731Z62ZA24I2ZC2ZE31Z92ZH2ZJ31VR2ZO313H31Z32ZR2PH2ZU313X31Z32ZX2ZZ310131HQ2FN31JY21A31V331PF31PW31ZX26J31ZZ31VA312D31PN2S53203320531J931PT31JC320221P31ZY312V25631HI2ZE320A31VQ313531VS31W7320H31VV2IE2SM319X31FG2TD2LZ2TF320U1X320W2UY2UT31YK321126Q2UR2SI2V02SL3215320W2V52SS31ZQ320V32172VB2T0321C32172VG2T731EY21I24026F21N22G31XA31QL31MI311N21724225D21E310P23Q2PX23V23P2MN31CD31JW1M25I25C310923U25021P26I24C322F31MU1U321Q321S321U31YA31LH31Y631E8322N321T31UB31N931UE31NC31EH322U321U31YH31NI2SM322M321R322V31YO32303237321U31YS31MH2QT2KC1321D23U26L1Y22U25924L21425N24E31LP22W21521D2WD25524B2NY31R3310221M1225S2511F22U24C26C27M2OA27A321Y3220322224S2482JY23Y23X24P25522K1821621S23C24Q23S1V2302LN29D1H1D1Z23N2T821A1V23724326P21F22I25B26T1526Q25425P29327D21J2L92LB2LD25024S2M32YJ317J23K26B21B22G325N2FD27U2BP1221H31122KZ22S1A21H25Y24Y22Y27W2BB21431RP23S26D31RY31QW29E326425T256326831RT21Q311O323J21932621922U23K26C326L2A01W322M311C326222K22R326U326L29D211102123251326G22S3272326621O31TZ2BB21J1P1X24626M326F27D22S1E22Z326621K310329D21J1521P23X32623264327E31TZ2A0327721E2TB327122R3266326W27D21C1431YW31RS327B3264326U327F2ET2101L2VM3288328J31TZ2S422V151W25I25F1A23526W24G21J2ZM325F29D21F1D21G245325O27A322A25I25Z1923523U2F927D21Q2TK25I311531MP257312X318S318H318J22D23524H2641L2YA23U22M2371N2P72FD23H2T823F1A21O23S26U2P02R521725S25C25N31GW27A22O22A1824N25U1V1K23X23Q1126O24G25S26925622R1K21D1E21P2F832AL319K31RF2MD22823G23K31XI21S26E26T318M32AK32AM32AO32AQ23S23R1D26S25825423V23L21C22D2R923724S25E22E2P81232B632BK1K32BM32BO32BQ23V26V22921Y22Y2MY25223S2202KR2ME32BI1824L25P23B23923S24022S26L24Q24I23V23Y32CB32CD23632CF32CH31WF32CK32C424723M1A26F24V24X26Q26R22Y1L21721W1Z2K9310Z27A21121O22H22222522722321Z2291Y22521W1Y21V22A21Z26Q24D24A23W22N21Q2192AA27L21O1Y329I32DL32DN22822R23F22222R22S23C1Y21W22V23322O23123F32E224024E32E632E827Z23A32EB329A1222L22C21Z2282292232252242KS23223123922V28G29D22L21Z22422C325Y23M24126625I21V325Y27D26Q32B429D23928E2BG28S23B2332AT326G22L22L29G22V23E31ZL32G623022V23932G832GA32G522L29W22Z23428Q318032G622Z32GK32GM31RT32GP23A32FG32GB22L2B628628822T32FT27A21R2BT2BH22R2AK31ZL21X29M22932FG23822Z22P22V32H31221O2BT326G22A23232EH32FG28Q2SU2262312A332HO32HQ23432HJ21U21U32H323M32I132HJ21V32I22BQ23M32I7121O27D22D22Y22Z32GV23222Z28621W29U22P29A27Z23521V2AR32IM23023023F2YT32HB23A32IF32IH22V32IJ2862T821T22R23021V23A27Q29Y22F2BE32H325E22J32I827E23M2BS32H321U22H32JJ27E22M32JQ27A25E32JS32I322N32JT1221U22K32JZ32F332JZ25E22L32JZ21U22Q32JZ24I32KA32HJ22R32JZ22Q32KF32JG32KI2BQ1Y22O32JZ23M32KN32H326A32KQ2BQ21U22P32KB32KW32H3323L32KB22U32JZ1Y22V32KB32L532KZ22S32KB32L932H322Q22T32L322Y32JZ26A32LG32H324I22Z32KG22W32L322X32KG32LQ32LK32LS2BQ26A32LU27E1Y23232KG32M032LK32M22KA23332KG32M632JG32M832KL23032KO32MC32KR32ME32KU23132KB32MI32HJ23632JZ21E32MM32LC32MP2BQ24232MR27E25E32MU32FU32MX27A1Y23732JZ22A32N232I332N52BQ24Y32N727E26A32NA27D1I23432K832NG32H327I32KB32NI2BQ25U32NM2BQ23532MN32NR32LC32NT32MS32NV32MV32NX32FU32NZ32N023A32N332O332I332O532N832O732NB32O932NE23B32K832OD32NJ32OF2BQ24I32OH27E25U32OK27E23832MN32OP32H322A32OR2BQ23632OU27E24232OX27D24Y32P027A25U32P31226Q32P61I23932MN32PB32OS32PD32OV32PF32OY32PH32P132PJ32P432PL32P732PN1I23E32MN32PR32OS32PT32OV32PV27E24I23F32JZ25U23C32K323I32MN23J32KG23G32JZ24223H32JZ24Y32QC32H325U32QF2BQ26Q32QI27E1A32I432H31Q32QO2BQ21632QR27E21M32QU27D22232QX27A22I32R02BU32R323E32R3315432JZ24Q32R325M32R326I32R31A23N32JZ21632RH32H322232RK2BQ22I32RN27E22Y32RQ27D23E32RT27A23U32RW1224A32RZ24Q32RZ25632RZ25M32RZ26232RZ26I32RZ26Y32RZ1A23K32JZ1Q32SG32H331QF32JZ21M32SJ2BQ22232SO27E22I32SR27D22Y32SU32RX32SX1224Q32SZ25M32SZ26I32SZ1A23L2BT317632IK32HX23F32FG21V2A432FE22V22U32SK32T82KS23529W23923031CR2252302232802312332B922722V23523522R29L2U527D32TF29021A1Y32IH1Y22R23623622V28F2351Y23A32FZ32UJ22Y22V32UM29732U01Y23122S32UC22T27Z23F1Y28E23832UO22O22V22S22R2A429P1Y2AK32U932J822U32UM32UO2AI23032U232IP32VH1Y27Y23B32GM2B932UP29822T22Y32V932UY32V332VP28F32UO32G823522P27J22O2AN32UY32G932W223B22P22Z2822B921831RT23E2A232V62A524Q27D2FD32ED1221Z23E22P23B2AI32V932VF32GL32U932UK32IK32UA23523021123A1Y22A22922F32WE27E28N27D21K32WM2KA1223732WL32XF32XB329B27D32GD23E27M32B832TX32W232FE22R32V132XK2T81221T32XF27E31PN28N32XE2F832Y028H29D27E32Y82B42791421L1327W32YB2EZ162FP27A32YH1221L28R32XW27D1429R28N27G27928N32YJ27D32YV27A2N328N32YQ27D32YO32Z332Y032XH27A32Y42IU27A32HJ32FV2ET2B228F2BQ2BB1222M32Y632ZN32KL32Y032ZB32ZO32XI32ZO32ZB29D32ZE21P32HJ32ZD32XF2BT2BB32WG2A323232XW21227E32XD32ZN1G25I2IU2FD330C2AP32XK1C32A628N2UN2FD32YY27A330M3102330K31GW279279330O330T121Y2171332Y82F8330Z1332Z0330031QX22233112QJ27927G330W2FC27A22S1327C325Y32XW24K31RT32XL32N027029S2BB32HJ29J2FD2A032EC2A6326G325Y331X32Z7331727E279326G32Y632ZK27D32Y827C32YC24H27D2QT330U28B32YK318M2BM29H32ZA32XF330J2IU1W2F5330W332Q27933143312325Y332O28N310Z330V332H27D3330331G331I2F8331L2KS331O330Y22G28R31RN27D1Y2QT332232Y5332L33393329332I332F27A32YO27C32Z427A32Z92F527E32ZK325Y2BJ2AX29D32ZH32HZ32Y032KR32MK2KA32ZF31HD22832HG32VT32TN27Z29L32ER22O32FT326Q27D25Z32ZS332332Y6331232LY32XL29D32Y42A02KA331X27G2A032Z4332832Y127A29J325Y31PN2B429D31PN2942A028Y29J2RQ332K2L6334U27E29H2AG32402BQ2MC2FR32XK32XW23632YF31ZL2SU2A1335R2SU3240162IE29J2FR335E29J333S330G2B4334U2IX32B82KA330G319K335A239325O2F1332U21O2QJ2SU334U2472QJ2T12FD331X2AG2T1335G2N432ZR27A327U32ZN317632Y62RQ335T2KA2NY33722BQ3103313G32XW32WE31032BB31HD1223S31JU334P27E2RQ332633732YT32XF312F2T132XF311L3208337931JU2BB336Z24B2N43176337T2LP2BB2S4335U27C2SU2S4335Y325O2F42BM1T325O333S1229H29432ZZ12213132B4336927E21S338L32ZN333U32ZB3240338I32ZX2ET23A23F32UF2KS3296323I26F32HJ2BS2BU27D2BX2BZ2C12C32C52C72C92CB2CD2CF2CH2CJ2CL2CN2CP2CR2CT2CV2CX2CZ2D12D32D52D72D92DB2DD2DF2DH2DJ2DL2DN2DP2DR2DT2DV2DX2DZ2E12E32E52E72E92EB2ED2EF2EH2EJ2EL2EN2EP2ER2ET32XN28327D21G320V26K32B42BB2BD32FG27M3349334B1Y334D28928U2312AX32XK337P318032GZ2B8289338V334732FW327O29G2KS27I27K27M338C27A21F14317K26F23E22D24Q31O125T315D24R27022T1K31A0237259329X2GT23X22M2WM23X23233952BT2BV32WO2BY2C02C22C42C62C82CA2CC2CE2CG2CI2CK2CM2CO2CQ2CS2CU2CW2CY2D02D22D42D62D82DA2DC2DE2DG2DI2DK2DM2DO2DQ2DS2DU2DW2DY2E02E22E42E62E82EA2EC2EE2EG2EI2EK2EM2EO2EQ2ES325Y2AR23632FN32FP32FR2F521S325G2AZ32HG29723932XU22V32WM32XZ32XC336V312E1D13332G28S32ZC32Y02MC32YW27D32XK330G333I12338C338I27A2IX331J337N330D28C325Y16336E28N32B4338B2FE32XF1Y2K9326933292KA337K32XF318032Y62B43180336T32YG33EQ32YR311727W33F7333M27D33FS1G33EI27W334U33EJ3363337N32YL31RT33582KZ31PN319K33FI335231ZL32XK1Y101329J326G32B8330G294335K317F29J338N27D2PY3328330F33FX333933G033EM3351325O2SU33G5326G33G732F227D29J324033GC33GE33GG27D33GI330D33GK27E33GM33E62KA33GQ2BQ330N332I2NY27933FW335R2A01433FQ32HK332R332I336I33HN33GT33FZ33GF33GW27D335533G427A29433H127A33G833FF33GB333F33H82KZ33HB325G33GL2A633GO27A33HI332433I233HY332433I0336433G333GZ33I533G633I833H333GA33H633IC33I033GH33I233HC31ZL1233HF33IJ3243331N33HU27D2102F2338S32XF338828N2942BM1V13338E333P2IU338E33JF2KA2T133BF32QJ33BH27P338Z27U2BB33AT321133AV33CE33972BW33CI339B33CL339E33CO339H33CR339K33CU339N33CX339Q33D0339T33D3339W33D6339Z33D933A233DC33A533DF33A833DI33AB33DL33AE33DO33AH33DR33AK33DU33AN2ES2A033BL27L33EU27D33BQ33BS33BU33BW22S33BY23L33C033C233C433C631AJ33C933CB2A533DY2AS33E132FQ31LU2FD33E532C027A1W22332X432WZ23023132X432UN32UQ32UI32UK28232V922R22X32UO32IG28629623F32U928V33M532IK2B623432UY33M932X428J33MD32UI33M623132U02181W1Y21B1Y22028P2AS32VT22927Q32IJ23032WM311727D2LN330B332M32Y433JN33FO33IR330H33FE2EZ32XZ33HX331532Y5338C335027E32WE33FD333A1231RM33EM32XW33NS333V33J32A63357330D336633O429432ZK337X27W32B832XK32YD33NQ33NO29S330W33OI33L9336T33NU333D33NM27V32YE27A33OI331D332I33OI33HO27G332633EJ27W32ZB31PN29J318033I32A033G5335033OD33FO32N033GE33NW33HG336533J5317F33FN32XF2PY335G33GS33NQ33P0335R33P333GA33IT325O33P833IU33PA33HG33H7335R2BB33IF2B433IH33PK33HH333L33HK2L72EZ33OY2KZ33HR28R33E533Q92BN33QB33EI33OZ33IP33P233G22A633P633G333PW325G33PY33OE33J033PF33Q333PI29S33G933GP33Q833IN33PP33QM33O327A33P42ZU33P733I233PX2KA33PB31R433QW31RT33QY33Q533IX33R233PN33FT32Z133JE32ZT2BQ338832YC33RQ332M2KA22J330933EG33L933EG1W33JM32ZN2PY32XE32WM33RY33S233S432Y632IX33S733O432Y327E33EY33R7312E33F133EM33F42IU21E33QJ335R32FT32WE331U32YZ27E2MC27W335O27E338C33SU336A33O72ET33GJ2KS336B331N337X33H533PC33OR335R2KR3325333227A33TF33EH335R332633ST2F5334U2N333FK33JG332I21633SQ2FR32FT335I33J533SW2L633SZ27D338C331F33T32N433P6330D310333P8330D311L33OB2QJ337Z32YR32YE2FR33TU2792AG330W33UK27A338C335N33FA22C2L62SU336933U432Y5335H2N4335K27E23313321B33RW27V29R27W2OA33EP330W33VA33TH1233SP33F833SY33US331R33HA33T02A6338I32WE32YM333933V333Q6330N2IE28N336127V2EY32XK2792BP32BG33NX27E33W333I127D33W632ZB142EY332B2EZ32XB33W6337H1233W933F028H32WM2IX33162BQ330G33VI329B336E28C318L33NP2B433SS325G2FD33262MC2B433U233UP33WZ33WK319K33O6335F33O42AG33UE2942T133OF32YE2B431A7279294330W33XJ27A29H33X332Y032WE33JJ33H427E21N338Q33W033RO1233WV33TK33WX33OO33XT33GA27D33X233O033VM33Y533WP330D33I933R8330D2FR33UB2QJ33XD2YT33XG338Q33Y133XL332I33Y1338F325O33VO33X633Y627A33XW33XQ33V6338828C21Q33RV33SJ32WM326G29L29N29P29R32XA33RZ32ZO33JR33HJ27F27H33052BQ32XW330A338R33RR33ZC33OQ22U32G22AT21127D22632UG33MD32VD21S29627Z22Z28T1Y23821E21821H33B329823432HH21K32LZ23122R22U32H02B92BQ33G933S032ZS331X2KA32Y433EK32Y033ET340Q2F5338E33XY27D33ZF33ZP33UY32P732B422127D32JE32FG32DY32JB32EP23623A33M82311Y21Y33ZS1Y21H21H22S32WS28133MN1Y22623B22R32DV22O341M32W128229632U921W22R22Z23232UI21Y32U023632J21Y21S32U032X421Z22S2AA2BF28Q27E332633ON334M334Q32XF340N32Y6340N2FD32WM341033SV342V2A128823A338W33LQ33E027D32FO33LT31D227A22332UU23F29832UC2AR33B322V22V32VP32WY32UI2AK32U132U322V32U9343A23B343C32UO27I33B732W532UJ33MO343H341F33ZR32G3341J341L341N341Y28G27E337D33ZM32Y033HO340S33QE33UL33JB27A331F344B333V338C33JN1Y33UT333I33Q0333I335433SL32Y8317F32YX32Y033S633ZG329B332I332G331E33Z432ZB32WM333Y2BK32Y933ZD32ZN33S333EG338P33EG342U27A21A32QM27D32F432F632F832FA32FC32TH33432KA32HM2A729A2302AA2ET2AE338W2SU32WR2342AR27L33N932HI2KA1M2BT2SU346528T29F32GD32TJ32Y62T12AI23A2AK27Q27Q27S27U33L6342Y32HJ1Q2BT343133LS33E329D32G932IH32HJ1U32K31Y32K3319B32HJ21232K321032K321632K331RA2ET32FY28232HJ21A32K321832K321E32H632G132G333BK330532HJ2NL32HJ21C32K321D2BT32B828729X28U29X29Z28I2822B232HJ21I32K321J32K321G32K321H32K321M32K32W032HJ21K32K321L32K321Q2BT2A028T28V28X32YR34582AD345V23132ZZ32K31A345S27A33Z8345Y2KA1I2BT2FK33LY22E33MF32VL2AR28232VN32VF32UT32GV346E32VU32UZ32UG2BF32US32UU33MG32GD2181Y22932UN323L22Z32TI32UC23032VD32GF32UK349N234349Y34A023332UY32HP2861Y33EA2342331Y29O32J32B932UI342G32UZ32G232J832IH23F33MY1Y21P33N233N423633N633N827K2BQ31BV12344932Y033BO332733NC331B33XZ33U534B732ZB1Y17340R33RC33WE2KA340U32N033RG32XK338I33NI32ZN32Y8317H33F833V632LY2IZ33RS34BI33EP33ZK33W7330Y34BN342W34C1342M2KA345F333V33ZU27A33ZW33MC34A03400297230340332UO34063408340A32VN340D340F340H340J28934C627A34B532XF34C932WM324B1232IU32IW32UM33MA22Z343E32UO343P34A627U341134B433S034C932XW29D34402AT349A121W349C32WZ32W232UG23A349H340A22S349K34A932UY32UN28F32X432UT33B32B6349T349V349X22U349Z32VD32VC34AE32IH32VT33M634A832VD34AA32LZ29032X434AF34AH34AJ33N92BI34AI29634AO28J34CI338Y34AT34AV33N32AI34AY349V34B032TQ345I33IM34C733FA32ZQ340V33EG34BL33IM2FD340X33ZO34C923M2FD327Z34F633QO340S33NJ32ZN33EW331X33EZ33RG34BY33EG333R33TC33L928C34BE33UT28C32ZW33UH33362LP3331330W34G527A25733ZO32YR33WC32XI2BP21I33S033W6338E33WJ32XF338C28C333S344M32Y733OQ1422J331A33VD330V332I33VD34FX34C234GP34G1342W33QE28C2IT33QH1234H627V34GT27A31I23451332I34HD33SK28H32ZK338C27G338I33WN333L33YF33VK33WS28H3117335E33Y332XF22M338Q34FD333F33UT33TR33YW1222I325G34GO33IU32B8334P319K33EW2YI324033FG33VX334V2P92ZU33R12942SU33GC33UT32B733VL336W2492YI34HT2YI330W34IU1423213319K34IU3356332I34IU33HO2FR335T33UX33WH338C2LP342L33V333V52F534J6337M33UX34FZ336N2FS33J0336R27D31HD330G3103336Z317F2AG337D27E2PY337234H721D2F233UQ33JA32N033UT34J732NE27E2462L6342S33XZ32YO34GW339832YI333K27127128N34GS2BM33E527C34KJ1634KI34KK34HA2BM21Y2AP34KJ14112BM32EC27934KQ2IE28C34L233VE2AT32YC34B934L933XZ34LC330G28C34HJ28R34HM33OP33U633PF33SN28C2AB34HU341227A34HX33VQ33O134I633FA21J325G32B8336T34IB32ZN319K34IE2KA34IG32ZP33UU311M2KA34IL34FW29H34IP2KA1C34IS319K34LP34IV332I34MK34IY34J01234MK34J328O33TV2ZU33L933UM34B62N434JD33V42T833PO2FR337P34JJ33VJ34JO33R834JN2YT34JQ33U931MI33J62QJ34JW33R234JZ33XZ2VV34KF27A28L34NM34MQ34KH27D34KJ34KL34HB1233LP1234KQ34KS34NU2BM32TQ34KP27134KZ2BM32FB34L327133Z11234O827V34B932WK34H734OG34HH34LG33VM34HL32Y034HN33ON33WQ31RT34LN12331M33F833YZ32KL34LY34I234HO338H32ZN29432B833FG319K34BE33IW324031Y627D33Q434FW338C33YB32LY33UT34P327D31BV33OG2B42QR33XK33VE34PN33X534OW34PG325O33FL33EQ2KR34PF338C34P633VJ34M433QA27D337X34PC34FS33X534PF34I034LZ27D34BX34PL34OT2EZ33YP27D34OU33Y234MV34PE2ET2BQ34PZ34HO2AZ338Q324033PO2B431QN31172B424D344F1234QZ34OV34LR32F334PU32XF14331929J34R2325O330W34RB33HO34QV33YA33SJ34GP34PI2KC33J034RK31CD330G2FR34JT325G337533IK33IX34H724232YI332I34RB330W34QJ34KR34NS34KT34KM27A332D34O434S327A34NT34KU27A24N34KX34O534L027A336E34O934OB34SK33VE34H934LF331N34HK34R434OO33WK34LM33WT1226034K2338D33VJ34OZ32Y834QM33YU34RN33X134T134Q734GP34OZ32CJ34Q834RI34PH33HG34D034QE25E34QG33VE34TK34R334GO34I132F229D1034PX33GW33Y833X434TB32F234TD33L934Q934K534QB27A32ID31QX33XH34SY34TL330W34SZ33WW34QL325G34JA2YI34N034Q634JG33EI34RG31QX34QX122LI34H734UQ34PR34ST34R633RE34R934UP2EZ34MS27A34US34RF34JI33YV32KL34TG32B82YS33PD1334RN34NC2L634RR34MC33PL34RV33XZ330D34NP34US34UB34NR34SB34S534NV25X34SG34SA34NY34VQ2BM26334SG34O627A317F34SL34L534NF33F833WH330Y34G02ET1U33FP28H26X34R034WE33HN33SL34LH34OM32XF34SU34LL34OR34SX2K934UD32DK33VY325G33WD33W232ZS33W6338I34GG34I327E22733XX34IQ34OE325O26Z34R034X833NP319K34J82L634UG2AG34N0319K336O33R434XI33VM34M734PT34K727A1S33J034XP34RO330D2LP34RR34JF2BQ2PY33V134H726Q34RY27D26Y2F226B2KZ2KA34OB26E34T034GN33VJ34H227A33HQ311728C33JL34H734YL33XO28H338I34HX34FY34PD32YP33FA2JM334X342W31PN33PF33XU34P7331Y33U32KA33QL34Q733L927W33FG27A34KA33QN33V634R8331A34YN33OV333333EJ33TK27W34XD29J34UG33O832XF33VS32F232WM33O233R134ZB33F933Z033HL34ZK33HO27W34QW29S34YN344Z34ZJ33NP350333VM33T234V634Z334BM34VA33H9336W33O934NE33J7344W33JA34H71G34ZK34GZ34TP34GQ27A1Z34WC28C23H350Q33VE350Y34LA27D22A350Z330W351434W632Y61Y23W350T34DL34Z534H034YH2KS33FM351F34HQ12350V2BQ350C342N350H122FG2BQ34Z633GW34HX33WO34LV34ZD350D33PF330834Q434HI34YT27G350S34YX350U32JR33NQ34HZ34Z434Z932Y034ZC2F534ZU34K4333F1R33Q127D332Q351N34QQ34PB34RI33G3318021333RE32F233OF3319350X34ZK27W330W351134ZL34UE34ZO34MY34ZQ32M5335R3180352I33Q62BQ352G34KC350733OT350133GT350427W3534353I123534350234V4351O34QA351Q33JD350G2KZ34VD29434RR33GN350M33GR33XZ21Y34ZK3533350Q34GM34H022O331A29D334P352634F734LK351L352W34Z233PF34CB34582BB34LV33WO34PT35281233TU27D32WE34YG333934YR340W34OL351933UT354U352O34YO27W34YQ33PR33TC34GP33PF332633T134TF350E2EU27E337X351U351Y34Y934K934ZY344J352J32N0352L33PF355733XU34W7325O34Z234OZ2N332ZJ352X32YR3319353N34ZK34ZI27A353R33GT34ZN34QN33VM35392BQ34ZS353C33VM353E355P351Z34H7235353K335R353M353Q3515332I356B356R350B355H351Q2TH330Y33ID326G3540350K33II3544344Y33VE23A350Q34C932Y832H732H9326G22232JB23632IZ32HJ21P347N27A3342340L3459344A33EI33V633GD33NH33VM344L344N33EM32FT338K34Z7338O34DE34GB34Z7324022022932FA342627Y28T33L927A341K341W341O34ER21R343E34DP32X432ER34CH34CJ340521H352P33EF32ZO34B732Y0357W340V34Z433SG32XF358334C212338P33ZE358734C3352R27P2B732H131RT3417234223346F32XF32HJ21S32KO359N32YU27H342232GM32HJ21T2BT32XK3403346R32KO359V32HJ21Y32KO35A332HJ346832HJ21Z32KO35A932HJ2XT32HJ349832I335AD2KA21X32KO35AJ32HJ349232HJ22232KO35AP32HJ22332K332K032I335AT32HJ22032KO35AZ32ZX32HJ2212BT34XR2BW32WQ32WS32UO2AK33B332WW32UM32WZ32IK32X232X432X632X832WM337X358W32Y6344I336P358034DC33EO33Y934HP28N32FT2153336358Z330033F334YA33SJ34C534M8354U336T354Z2A0353X34YK2EZ3532332I333433HO28C332622K28R33EG33NT350F33PF33R1354U335034YE31QX33XZ2YS332U34TG318032B833OG29435CW34Y42IH33QB330D28N335K34QM358Z33UT27C32B82SU330W333432YS28H330Q32YX332I330Q210317H28N34LY33W133VE35DR33X534YS34GL352Q34W8354J337P354Y2ET35CA22P28H35DU35CE325H33SQ35CI27E35CK354S352W35C0351K3383351G33HQ35C333OF33XZ34K135CX325G35CZ34G329435EO35D41235EU33ES31CD34U135542AP32B83176330W35E729R28C345H33VB332I35F91235DO2IU2272EZ27C330W35FG351832ZR34SS35DB354J315I1235E229D35E428H35FK33OJ332I35FW35CH34Y935ED35C435CU35EG33PF313G33SV35EK34BY35EM353P341535EP29435ER34U734VB1235GD35EV35GK35EY320835F035FO35DD27D31Y635FJ35CD35F71234KW35FA27D35GY35FD35DP1227U35DS330W35H535DV35C435FN33VJ354U34B335FS342W21035E528C35H835E827A35H835G035CJ35CL32ZN35CN359B33PF314933ZH35G9345835GB33VE35E535GE32F235D032YE29435I135EV35I735EY34BX35GP33VJ35GR34RL353P35HK35GW32ZM35GZ34LS2EZ35FE28N2ZD35H6332I35IP35H935FM35DY34GP354U34U035HF351G27A35HH28H35IS35HL1235IS35HO35EC35HQ3327351935CU2BB34D035G8348V35GA35JH33VE23D2EZ34RJ35I335ES1235JL34HE27D35JR34HH28N34U634TE35GQ33HG34V933VE35J435GW27M35IK1235K535H22IU336M35IQ27D35KB35IT34MY342L35DZ354U34WB354X351C35FU28C35KE35J535KE35J827D35G235CM35JC351K34WS35JG35G435HY35JJ330W24135JM35CY34X535D11235L435JS27A35LA35JV32WN35IC334V35DC33HG34B7330W35KP35GW34PQ35DL27D34PQ33YS35CT2KA29H34WK35AI331A338I34C934D033JU343335B4359Q27A32GR23532HJ226359W27D340332F233BC359F2BB359H359J35AM32KO35MA32HJ22732K332FV32I335MO32HJ22435AU32KO35MU32HJ22532K335AF32I935MZ32HJ22A32K335A732KU35N532I335N92KA346S2KZ346I29O29Q353F32SS33EG35GO34BH32ZO359334M8344O34F933TC353X27932ID35KC34U533SQ333135KT359627E33WD34IH2AP325Y336T344Q340V34BO33XZ2ME35EP33FY35JJ33HO351Q33L934PS34QA34OZ33FI2MC33G134Q733OG27W35OC33O5332I35OS330G33IU32Z534FW32YR29R279311L35K635P333X533EG344K355H333I335K32WE340S32XK35J227921C35FH33VE35PH33NP35NZ27A35CK34BQ2AP34Z234FR34MV34C4334N332M35OA353P33VG35DZ35OE35L035OG34Y9338C35OJ34U335OL33U035OO33EM35OQ33VF2EZ34ZO332I35PZ35OW337M32YO358431QX35P11233ZU35K635QP35P632ZN35P834JK333I338335PC355235J135I733XN35FI332I33XN344I32Y835PO32ZS35O334M835PS34NH35O833ZG35PX33VE31KB35OD2KS2BB35Q3355F34T9350D35Q833Y72A633X435QC35RI35OT32QY35D627D336Z35QK34C235DI27933FS35LP27A33FS33S135QT330E33VJ333I35FQ35QY352C35FD35I72AX35NW32C235NY34QN35R832ZO35RA342N35PS35G735PU341234C02F8330W34NL35Q035RK33R435OH35Q534H034TQ318035OM35RS33TC35QC35SZ35QF2IV35RY34N935OY35QL33V72EZ33Y135S633Y034T035P735SB35LH33JP35GS33OO35PD33JC35I72FK35SK35TY33TK35PM1235SO34FO352S35O534PJ34BK358135O927D33F3332I32GA35RJ35HX35RM356F35T534UV33H335ON35BU33TD27W35UF35RW27A35UR35QI35HV32YN35OZ35QM2EZ34MK35TM34MK35S932Y635QU35SC33EM35IB35SF35NS35I724035PI330W35VD35PL35SN35O135UC35U635PS323F33ZC35RG32XI35RG330W34RX35UG35OF33EI35T335RO34PT35RQ27A35UN35RT32YE27W35VT35US1235W635QI34U035S1333S35S3122FP35K635WG33JO35TI32XG359A35JF33BB359E340K35MH2BE35MJ33442BQ25E35N535M52A1359S35M82KA22B35MB2AD359K27E35MQ32KU35X332I335XA330132JG35XC2BQ228349132K835XH32I335XK349732K535XM2BQ22935N632K835XR32I335XU35NC2BT354W32XY32TW27Z343W32UY32U3342223032U932UB35BG32X31Y29729Y29M33B332WA29P32HH32WM23R357S337N33EI340S34GP32YQ32XW35BT33X435EY32FT346T32ZS35DW34M8354Z334P35PS29D353X27C33VD35691233VD33HO27C32ZK35CK355Y351G34Z2354U33FG35C92KA34FV35J033VE333O34TY326G318034QE333O34NP333O35EY34I934GX35GV2AP312F35K6360233X534IC354B34JK354Z35PB35U7333A35J227C21B2EZ35Z8360F33NP35ZC35J935ZF35JA35C62KS337535ZK2BQ35ZM2KS330W33TJ35ZQ359C33TD2B433TJ34NP33TJ35EY2T1330W360I35TJ27C33JD35K6361A360535SA35YZ34PT354Z35QX360B328L35E527C33LU28R330W361N35ZB331N35ZE32ZS35EE350F354U34NH360R35O233EM335A332I33FS360X33G335GH2B433FS34NP33FV35D731MI361P360027C21K34BJ330W362H33F8360633WL34YF2ET35SE361J35Z4361L122RE331C33VE362V33TK360K35O0360M361V359B354U35ST35KM35ZL362133XZ2LN35EP2B435ZR34G32B4363B35EV363H35GN33XZ362Y35DI27C34OD35TM34OD33L9362M361F34QA354Z34PA32WE35Z335TW2AP22Z360G33VE3642360J361S356E32XF3633334W2KS34B3334R35C533NL35ZN330W28A363C2KZ35ZS34U8364J35EV364O35EY35HV330W3645361835SL35K635SJ361D35V5362N35TR354Z35V9362R364027C35IS35Z835J733EI363035PN3648351E35ZH2KS35VN33FE35FT363832XK362235JT35L5325O363E362735JQ2EZ34NP35JU35EY34TD330W35K32AP35QN35TM35QN363S359634HX35RA33OF1Z33S423K35VE332I366C2BM35PS32XF34GA35SQ27E333Q359635M035VK359L35WV35XR35WY35M732HJ22E35X42BC33XP2B535WP34CT35WR32FG35WT340L32K8366W32I3367835XX32JG367A2BQ22F35XS32JN367F32I3367I35XN32JG367K2BQ22C35MP32ZY32KU367P32I3367T33011234DK34DM349D34DP349G343D235349J29P34DW349N34DZ349Q34E227Z22V349U349W32UO34E734A034EA34A434ED3418368H34EG34AB34EJ34AE28F34EM343F34EO34AM34ER22Y34AP34EU34AS33MZ34EX34AX34AZ32V634B1355P27D22I35NK34F5369C32Y635NO342N35NQ33ZG35SG35NT32IC366D27D35NV35U135VI35PP366K350F35PS35O735UA35RF366P33VE35OS355D35T133R835VW35Q435VY35OK32F235T835QA33YM35OR35QE369Z35TF33HG35UX35TI35WE35P535TM35P535V434MY369F34QA35PA35TU35QZ35SH2EZ35PK2AP330W36AW35R635J9369R35VL2F8337535RE33IM35VR35QG365P35Q133G436A435RN35Q635DZ35W033NY35T935OP35W435QD33TG330W35QH330D344G366L35UY35TJ27935QR35TM35QR36AN35DX36AP34U335QW36AS369J35R1369M27A35R535YO369Q35R936B3332X35U935VP35PW369Y330W35RV36A135UH36BD35UJ350S36BH35W235TA36BL35RV35TD27A35RV35QI35S036BT35WE35S533VE35S8338C35TP36C135DZ35SD36C435VB2EZ364Y35R327D364Y36B035O036B235PR2F8363636B635VQ36CI332I35SZ36CL35VV33J136CO34T236A835Q935UO35TB36AD35SY36AF35GO35WC34R735QN35TL33VE33YR36D535SA36D735YQ33EM363X365U36DB27935U036DE27A35U036DH365D36DJ354I35PS364D35TS35PV34BJ3323330W35UR36DS35Q236CN34Z436BF34TY35T736DY35W3335R35UR36CV1235UU36BQ32D335WJ35S235QN35V133VE35V336EB365036ED358032XK365435TV35R02EZ35VG36AX332I36FV36EO35U335VJ330036DK325Y365I35SU32HJ35SW35UD27D35W636F036BC36DU36F335UK36CQ36BJ35QB36BL35W636FB35W936FE35WB36D035QN35WI35TM35WI36AH366N35WM34F435K736712BA341635WS35X6360S35WV367P366T35X032HJ22D366X359Y33BG32JN36HB32I336HG35XD35WV36HI32RO35XI32JN22I32KO36HP35AE32K536HR33RX367G32KU32JI32I336HY35XX12334J31KA368G340332UA23A1Z1Y22232V2338Z2902AI32VD32UK32UO35YI33MO341C34A027Y32VH27Q27L23521835YK35YM336A36CA35BQ33I135YS36EW33EM35YV27E35YX32ZO363U350F35Z1363835C235J1330035Z733VE35ZA365B3647363235U635ZI35C3365K36H5365M33XZ35ZP34TQ365R360Z332J35EV35ZW362C35ZY27D33VD363N319L360334T0363T355H360933OO363Z36FT360E3643361633SQ365C36G036JI365G2A0360Q35E3365L342W360V365P363D360Y34QE361133VE3613362C3615332I361736K1361C35TM361C3665365036J635DZ361H36K835SX365612361N35Z8361Q36JG35ZD365E351T36JJ2KS361Y36KL36JN36KN362336KP364L363F12362936D335RY28N35F4332I361N36K1362K2IU362J36K4361E36K6362P36L936JA36AU27C362Y35Z8362Y361R36LH36KH354I363536JL364F360T365N27A363H362532F234QE363H34NP363J362C3208330W363M29R363O362I332I363R33EV36M736082ET36EG36K936MC2BC36KC332I364U36MH360L361U36LK2A036ET361Z35VK36JO353P364O36MS364M338Q364O34NP364Q362C364S36NG362F364W36M4332I364Y36L434MY36L634H12ET365436NC360D35J636NF27D365A333636MI36NK36KI332E36MM35ZN36NP36LP365O364K36JS34QE35JU365V36LX32C1365Z36O2366233VE366436N7338E366736AT14366A28N366F36FW27D36PC361J366I35PQ32Y0366M33JQ359A342K359R32GL28Q357F27U32HN32HP32TD32GS324032IZ32TC32HR369L27A32J132II33MM32IU32IO22Z32IQ32IS22V34D232IX2T132IZ36Q334AK32J5346P33BM32WM34B334ZW33GX340S32Y233EM3321369W359B333I32Y826R2IU338I35UR3620353P35P5353S331W33PE31RT32ZK366Z342L325N33Q6326G35QC36AM33VE36AM32YO354H33RE35QN32YH35TM32YM2N334FM36BS35SW2BQ34C92SU33EW32B821T28E23429X32GV28G35HV21W29G36S532GM23A36RY342322U22522S21T34AC35X12BQ33962SU36RY32J829L33N728229C339823032G231CR222368Z231340336SO32GV22E33JY2ET3426340H33BK346Q32KU339633LX34DL33M032X01Y33M333M532FG33MW33M832UL33MS33ME33MM33MH33MJ29932UZ36TN33MO34D433MR34CE33MU36TH33MX33MZ33N134EY33N534F1369634F334QC36IU2KA358Y33WK34FM2MC34Q733OF34B933HM33XZ36UH34GP32XE33Q0340S32FT36N734JK36NC12337X35DS34TA33GE340S33P836LG34QA35PS326G34GP35PS33FI33V336UU34R02JO35VH33UW35TQ350D36AR27D33XW35SW342T359A36RV33BG33HG36SL36S032IO32GW36S436S636PP36S932IG23236SC36SE36SG32JG36SJ27D36SL33B536SZ36SQ33K636ST313G36SV34ET36SX22U36W536T1339029D36T435LV27H36T72BQ32JP35W836H234182B834A02B6323L341I358I344433MN21A1F1821S36TQ22V32V136TT29A32VA36I71Y343T32V132VD22T349F36S22UI18349C32UO358E32UO2AR28J29B32VD33B732W134DS34EA2B628W22Y36WZ18342622S23F32VX2A432UC341A32G3341D32WX32UL33EA32UI29P32VR22Y32X936U735BN3650330B34VK333V36UD36DZ36UG34R036UJ33UT36UL33J036UN33VM369S35DZ36UR36UT333736YU33TO33R4365C36V32F836V235LI325Y36V534ZK325Y34H736V9369P36VB36FO36EU33J536VG33EM36VI34BV2MF369Y36J336VM36RZ36S136VQ27D36S534A236S728636SA36VW36SD36SF36IE32I336WN36SK28E36W4346L36W633CH36W832QY36SW36SY370B36WF370C36WI36T633BM32JG36WN367Y34DN32UI368134DR36833685349L34EH34DY349P34E1349S368D34E536I5368I34A234EB34A534EE368N349M34AC34EK368S34AI368U34AL34EQ34A7368Y34ET34AR34EW34AW34EZ369533N92BQ35IB34CW36U932ZO330G36UC33TC36UF34MA34H736YR33O336UM2F536UO36PI35TR36YZ35PI36UV34ZK331V36Z431RT36Z6325Y36Z8361J36ZB36V736ZE35SM36ZH35P933EM335K36ZL340Y333T36VJ36ZQ32YL347Y36W236ZT36VP36S336ZW36VS36S8370136VX370432U132JN32JS2ZU36W336SN370B2ET2BX370E36CW370G36WD370I36T236WH32UG36WJ35M636WL3433373D33Z729M35NG33ZB36YH34CV33S036UA33U6371Z36UE34WC324C36YQ365P36YT34VA36YV34Z436YX372I33OQ36US372C36QR36UW36Z336A336OJ36V036Z7374Q36ZA33V236ZC33RR330W36ZF344I372Q35QV372S33XV34ZK372V35WL36ZO34II36EV349836ZS28F36ZU373427A36ZX22U36ZZ36VU36SB370336VZ2KA32JY373E3709373G36SP373I36SS23336SU373M36WE373P35H0373R370M27L32JN375O370Q368036XF34DS368434DU3686368O36883710349R34E33713368F34EF34A134A334EC34A6376K34EH371D368R34AG371G34AK289368W371K368Z371N3692371P36U336SO371S27E371U3743371X36YL32WM36YN35RT36YP3723374B34CU357W374E361D36UQ36LA352336V73726372F374O36Z536Z933XU34U336V4374U372N33XZ374Y36CA375035V732XK372T375434FF372X36EV3468375B36VO36S236FF375G375I3738375L370535WV375O370836SM22V36W5375T373K31KA375X373O36WG376036T536QJ37632KA32K235QO33ZV33ZX34CF340134CI340434CL3409368434CO22V340E32FD34CR33BD28A377636U834QO377936EH35RR374734UN372236UI377G3411377I372736YW355H372B377O36Z2377Q362Z372H377T33YW374H362634QR377Y353P378034ZK378235TR36VE33YX378634BV34C9317636RW3731375C37332YT22D342223A21W296373832I337912BB21T21W36S02AK35B22KA34922KZ22C22V32IO29634K1325Y32GD23935A234TK32FX37AS1123D1M24S21X26B23C23Q32B4378Y342Z35WV379135KK1222334AH23429U34CI28932US36TQ34E134CJ290349N2322AT27E355W371V379L36YK379N35W137203748123334353P333436UK377H33GE35NO372836O934W9354F355K36M4355C35LI36NQ34OJ33G4330D351U34OQ2BB34OS35D334V331801Y28C34OZ33GI33IU330F34P834BI34XN33IS34FW331H377W27A1I2QI35WY335434UL33RA33J4337P33YY36ZM332934W4335D33VE350V35VH338335V637AF33EM337D372U3787375731MI338W36RX3732378D2T137AR32IH37AU23437AW32KU32K731RT37B037B23466367637B737B933MN37BC32XM32GE35M235H037BH27D33EA346Z37BL37BN37BP37BR376237BU32JK37ER35B632WO35B832WT35BB23535BD343I32X035BH32X532X736YG33LY379K33VM37CH374636YO333334R037CP36YS37CR33S42FD37CU36M837CX3523344V34TA37D134YY33SL330F37D537D4355Q37D933SQ36KQ32N037DE36DX35TG34RN33H2324031PN2FR33GO2B434IM27E37DO2F8318037DR2IU333E374O37GX350J37DY34X433Z037E235EV37E5369P37E736VC34PT333I37EB37AI333V34C9315I3490378B375D37AQ37AS37EN37EP2BQ32KA37ES37B132H837EV35X7367R37EW326G37B837BA23437F027A37BE37F327A21Y37F534SJ37BJ37F937BO37BQ37BS36WK370N32KL37HX2YH27A36XJ1Y21X36XF341Q341S341U358J32WC35Y2341H32G3286341836S7379D1Y22732UY3421342334DS36WT37J2236344237IZ33MN2BQ37CE377837FX36YM37CK379Q27A37CN33VE37G2372533J037CT33VM37CV351C32Y8337X37GB36QR37GD35ZN34SQ35RL37GH33H1330D34SW28H37DA37DV37DC37GO35GG31J433HD35TG34XC37DK33TZ33GY37DN3336374T37DQ37DS2KS37DU338Q2T133T6338337DZ372V34OB37E3330W37HE344I337D37E836VD33EM336Z37EC37AJ359A37AL37B5373033OT37EI32GW37EK37HT37AV36VV36H41222Q37HX37AZ37HZ37B336VL37I537EY37BB2F837IB35WU2BQ37IE347E37IH37BM37IJ37FC37BT32I337HX341527A359H341932GV36Y7341E341G36WV3443341X341P341R341T225341V36WX341Z32EN34223424341G34273429342B34AD342E342G341D37JK37FV34Z437JN377B37JP34X637JR37G1379T355C37CS379W34Z437JZ36J837GA2ET34IN364G33T734WI33O433WO37D7332934SX37KE338Q36V237KH360Y33G537DG34ID37KN37GW2ZU32XW37H037KS315737KU37H534QK33GZ37DX375334OW33VU28H37L4332I37L636CA37HG36ZI37HJ375336VH27E37HN372Y315737LI32XY37LK28G37LM37EM37LO36SB32JG37LT36W237LV37I132FU37I332QM34931237I637EZ37M137F237M327E37M537BI37F837M837FB37IL373T37IN32NB37HX3557370R32UZ37C933M336XA32FG342G34ET32HH32UA32G336S1340F2A537CD37N833X537NA33U0379P37ND37CM37NF35EP374C357237G536ZQ3607362O37G927A37K237NO374Q37D237K737NT33G637KB34WO37KD37GL32F237DD35UL37O437KK31J437KM35TG2FR33V137KP34Z737OA360Y37H337DT33R434UM34HH29437L037HA332R37HC34NP37OO34ZK37L837HH36AQ37LB37OT37E0340Z359A37HO346737OZ36VN37HR37P337AT37P536VW32KZ32KF37HY37EU37B437I427D37PH37M037BD37PK366Q37M437IF1237F7342Z37II37PR37FD32JN37SE37ME362U2BE37MH341B341D32UJ341F37JF37JH37MU34A737MQ37IY37T9342037MX342537N032GV342A342C1Y37N429637N637QC36YI34MY37QF379O37FZ37NE34YM37NG372D37JX37NK37G8374I37QU34TS37QW37GE352434HP37D637R137D837NX37R437KG37R734BI37R933H233PU37RD37B537O837GZ37KR37RI37OD369Y34V337KY33J437RP37OJ37E137OL37HD35SM37RW37OR37RZ36VF37HL36ZN33SJ331S334O27D22132HG22X32I337SE37MB32OI37SE373X33Z935NH337I37QD358G35BO377A37QG37TU34KB33XZ33VX379V34DC36UP35ID2F832FT36V62F834H736R336CA34T437RX36C2363937V437OU37S237EE37V833JV2ET37VB29Y32KR37VF37IM378Z2BQ32KN31CD334A2B233B3236334E33B62AX37VM37TQ35DX37TS37CJ37QH33QE34II34H737VV374M37VX3729350D35PS37W1374V34ZZ35RZ35SM37W737V237D21237LD37HM359A37WF32KU37WH37VC32JN37WP37VG27E22Q37XU33ZI32WI2BQ35FQ37CF37FW37VP37CI36BI37X334B934M7330W37X7350Z34Z737VY372A37W0377X37W333XZ37W53548357Y372R37XK37XM37V633WA37OX37B629D37WI37VD32OI37XY37PT37WN27D25E37WP34B736WW37MO358L358N2AR358P3796358S238358U37WY3742358X379M37FY377D36ZP37X635JM37X834YT374G37A532Y537W236ZD37YK37XH37YN375137YP37V537OV37XO37OX375A37YV37XS2KA32KW37SW32KL3809376634DO3768370V376B370X34DX349O34E0376G368C368E34E634E8376L3718368L34A7371B376Q368Q34EL376U368V371J34ES34AQ34EV377136U234F03774369734K837WZ371W37X137Y737VS37YA332I37YC37QM3665377L325Y37XD37AA36RG37ZX359237YO34C537YQ380237WE37OX378A380637WJ37HW380937XV3433380937IQ1237IS37IU34DQ37IW37MR37MT37MO36Q823037ML37J336S232EN32GL37J737J937MW37JC343D37JE37MM37JI29637Y137VN374433YC37Y6377C35TA37Y934R0381I34CU381K37VZ381M37YI37ZV36R2381Q33X537XJ381T380137WD33SJ338U37V927A37YW32JG38092BB36S034A232TW35AG32KO35MS32LV382237WM37FE335H2BT36I336IB349Y32VD32IH36I9384322O36ID32U136WS349X36IJ338Z32GV32VD36IN28632J8341D37FT32C134DD37ZI381D383035OP34B934BT33XZ384U37VW37ZQ34RI24J361J32HJ35LT342N37NM31J4354U34YZ34K434OK37YE360N354T2KS332623O361J334U37ZU374W333N35SM33FI37L937HI33EM3369381U383H338T37OX32ZF381Z37YX36J332L231RT383Q22U383S32I935AH32JK383V37XW3860382327A23M386034D036QC36TU32UA34D71Y34D933M634DB27D34U037Y337N937Y537ZK383135TT34H7384W37ZP385B374G385037XC35EL354I385531PN385735JD35C3354Q355334JK36JK27D385G369U3839385K36ON35VH385N37W836D8385Q37S0375534C9383J345R37XR382032MV3860383P32VC386432JK38663433386827D26A386A383Y32HJ32L533HG22432HG368G33ZS2BQ386P37JM386S37JO37Y8386V384V37ZO37YD33GW37YF32KL387137YH35JI35O4387535EJ34BI34Z032XL387A34Z4364A3555385E27E387F2F8385I37XE34R035ZW36CA387L383E35OX37AH37WC372W37EE387S37PE387U385Y27D21U388A387Y383R233383T35MR32KG388A386B1223M388A31BV21V37J423432HF341T32WZ341T29O32EQ32ES388G382W37ZJ388K37VS384U353P386X388P34LV387038513873388W2ET3357388Y35TG389037U7388Q385C34QA387D27A389835O6387H37XF34RL387K37ZY378334X537XL383G389K383I3804357O35GJ380732MV389S2AQ387Z389V3865383U32LH389Z38882KA32L932WF32WH2A438AF381B37CG388J37NB388L27A38AK33VE38AM381J388R32LY388T3838388V35Z038AT34BI3877351K33FE389233X53894354J385F385H38B6389C385M38BA37E932XK385R38BE375638BG378938BI383M32KU38BW389T386338BP388138BR32LC38BW38A023M38BW326G346I22Y23123129227E388H384P38C337VR37ZL38C634R038C9383538CB333F38CD37OX3853333F364E333A387633T7387834BY38CM33OM355H38B21238B434C5385J38B736JU344I389F381S389H38BD389J38D032ZB2S433EW36PR32HA32HC32HE388D32JG38BW31HD378F36VT37HV388532LB2KA32LE2F8357L32KL38F72T132HD34A222E23132HD38A732GW38A021U38F7330338BY37QB38E238C137Y4344A37VQ37TT38DS1235D3353P37NY35SW379V37G6379X381L37U2374K377P34C538DX377V2F833UE37A0374D374N377K3837377U37QT38G737A1360Y383637YG325Y336936Z0331K38GM33IW33EL34IC38EG34R036EB344I34XD389G337M385S38BF38EQ385V33JW1222T37I038EU23A38FH32HF32HH32I338F738F03736370037LP32LK32LE32JG38F7325Y38F932NB38FB33ND29P22U38FF38HF38FJ38BU2BQ32LG2KS348S28W34M837ZH35SA384Q37NC37X438FX34R038G0374L372E37QP37XA34PT379Z36Z138GF37A238GO37XB38GC37CY38GE37QN36UX38G438GI34I338GS37NH38II37A838IQ38IL2F838GR38GL38IO27D335K29H38GX389B34H738H036CA38H238EL38H438CZ34C931HD37HP38ET36PX38EV38A738EX32KU38I438HK36ZY38F238HN37HW32LJ32I938I438HS29M32LK38I438FC38HX38HZ32HE32GW2S433BL23836SP36PZ28G38A025E38I429D384932GV38I8384O38IA38DQ38FV386U35D534H738IG38G8334N38GA36YY377M38GK38IU38G238G938IK374S35JJ374J38L4374M38IP38L037A734Y938J0372D340S387L37ZR361J38J738LB38J231ZL361R335T38GY38JF35SM34N5387M36EE32XK37RP38EO38JM37YT38BI38HB32H938JQ38HE38EW38HH2KA32LM31CD38F1373738JZ32LY32LM32JN38MC38K4383Z27A22Q38MC38K838FE38FG38KB28G38KD27J38KF32GV38KH380A32JK38MC37SZ37MG32JA37MI341C37MK37T737Z6358K37TA37IX37MS382T23437TE342337TG32TN37N137TK37TM342H38KP386Q37QE38KS37X237VS38FY33VE38KX38GU33NR38L738GB36MB38LA38IN38IV38GG38J438L835L038O338GT38J936OP38LE37ZS332638LH38IH38LJ38IX38GP38BC38OH38KY38LQ36JG38LS38JE33XZ38JG34ZK38LW38H338M037S138H6332N38BH2ET38M527U38M738HF38JT32MV38MC38JW375H38JY37P632LV38MI2KA32LO38F838K532KL38PI38MQ38HY38MS38FI38MU37IM38MX22V38MZ38FK38PI345637WX38FQ38I936YJ38NS381E38FW38NV330W38NX38OC38NZ38LL38IM38OB38O538LD38O038L1325Y38GD38O438L538OD38QG38LF38OG38J838QE38GN38OE38LM38IT38QK38LC38JA372G38OR381O330W38OU344E381R37ZZ34JM37WB38OZ38EP38P138D238P338HC38P638M937PB38A138PI38PB378G38MG27D24I32LO32JG38PX27D38HT388538PM38HW38MR38I038PR37PT38PT38PV38I227E32LQ354V36W235Y1382G28735Y438HB27K35Y833M132X135YB35YD33MD32X432W1349Z280386N350F38Q137TR38Q3384R35QB34B938Q6332I38Q838QR38KZ38QN37ZS37K138QQ38QL333938QT35PS38QJ38QD38T5334U38T7374R377N38QW38LP38LK379Y38J638QV38TA38QX38GV37A338R037YJ353P38R334V438OX387P37ED37V737OX33OQ38P432F2349W299386332TP38N0389Q38S5354O34CD33ZY342A37ZC37983407379A340B34CP379F340I379H2BQ336Z38NQ37VO38FT382Z38IC34B934Q0353P34Q0344I38OO32FT38H5330W310335VH37XI38JJ334U38H538RA35EF3412385W29K38HC318038U323A38U532TQ38DE38S538N337T138N537T338N8382S37T9382B37TC37Z738NG382O37MY342638NK37TI37N2342D342F37TN342I37XG38FR386R38UR386T384S38QY34H738UX36CA38UZ38TW38EH38V3369P38V538R636OP38V834C937XP36ZR38ET38VF368Y38VH32FE38VJ38S332JU38S536TA33LZ38SF36TE33M434A636TI386H36TL36TR33MG33MO36TP33ML38XC33MP36TK36TW38X736TZ33N03772381734F238UN38AG38IB38C52YI38WE35SM38WH38R837L2332I38WK36FZ385O37RY380038M1380336EV37YU38VD32H938WU38U438WX38U727D32M038S633OT38S835Y332UV35Y638SE37FP38SH32HV38SJ35YG38SM32HH38XQ38W838NR38WA38AI38FW38UV33VE38WF37HL38T538V038BE38V2383C33L938H338V738JL38Y73412380538YA27U38YC38WW38U638FK38YH37VJ373Z38YW38SQ37X038SS38UT38WD33XZ38Z438G138TN32Y538V138Y038ZA38Y337W938Y538R938WQ381X38M438VE33ND38WV38VI38YF38A138YH38A438A638A836TD38AB32EP32ER32IX27E38UO388I38YZ38C437VS38Z2330W38ZY38OI37NJ389I38OZ38Z938V438CV37LA3907387Q37S338TZ38VB37PD27D347737M632IH37HQ37AP31HD37S7373321V22U28T29H29D37EL27M37S937HU38RM32JU38YH37LU37EU31ZL32HU38DL37SK28G2FD3432343323Q21831LU37SM336E38A026A38YH27E2F138YX38UQ36UB38Z038KU12330834H7392P34HH35SW36J234HP360T33SN279332T33TK331D355P33WO36IX335G33HQ34GT27G360434NP360435IW356334VA38EC33NZ34TX36R62A0387L33VQ35VZ35JO352333Q637NP29J2BB32401Y22H36GE2ZU331X2B4393S38FQ34OZ2T1331X33I638R7345I37KI33G5393T34I834JP2KA33YE32Y02FR318033FG34VG33EM37H327W324034I92IE27934Q033UN35SM336Z3905387N32XK35FQ38WP391A36EV35X82BQ391F37PO32XP37AN378C32GW391K37P1391N391P2ET391S37HS37P437EO391W330Y32M637SF38RE33ZV38DK22X39242F53927386C3929392B37F1392D38WZ32K0395L38ZP33ZA2BQ392I38ZS381C38ZU38XT392R353P392R371Y34JG362C33ER330D35RA392X351D33NP35LW1234KA393338B134BY31QX393736K235EV393B389533ZH393E36A237CJ36RJ38IH36BB36BE355H36BH33OC356434U3393R34X5393U393W394A325O33Q2394132F22SU39442KZ337P352T34X537O338FQ34RN35EI2YI36QN34II394H34MB37UM37KT29S32B8394O2EZ394R33TT37V03916385P32XK37LC38ZE37EE313G349037SH27E395437F637AS391I378D395A37AO36S2395C32TI395E398K391U37SB37LQ23M395L391Z395N34CC395P395R392632FT23M395V37PJ395Y37Z038MM1224I395L33L633ZJ392H38XR396837VS396A33VE396C36YL396G36QY33O4392W34SN392Z33QC32Y8396O352H396Q396Y34KU393836EH330W396W333L2BB357W393F34YU372D36BB393K3976393N38GK393P353V31RT393T393V351Q397K33G33940350F3942397R2KZ397T37DF37UG31ZL397L32B834NH394E32XF394G38GJ33VL37GY3980394M34X533RT38XU33VE33UO344I394U38LX36FP381A39123919398D38M3398G391E38BI37SS398L39593957375D398Q391Q32IE398T39BX395H38F327A26A398Y37P9392032403922395Q37LZ392527H39953997392C390G1232MC379234CC379433ZZ38UE34CK38UG34CN340C37J738UK34CS379I2F0399I390U38DR392N399L330W399N36J0392U34HH399S2EZ399U33QK34QN399X353H35KI36LJ396S33NQ393933VE39A5335G39A733GE39A9397233Q039AC35UJ34JK39AV393O397935DZ397B38TO397D39AM397I39AP359B39AR350F39452KL37UL394833IU397F34VC394D33RL27E39B334X134RS33TC394L31ZL3983394Q35EV39BD36CA39BF38H3394Y398C33SJ398E367L36HE2KA398I37IG391H37EH398O39BS37LJ39F523439BV398S391H398U395I38PE36J339CI398Z38M6395O392339CA395S39CD392A3998390G22Q39CI380D370S380F349I380H3687370Z380L368B34E4376J371B368J376N371A380Q380W34AD380Y34EN371I34AN371L3813369134AU38XN371R381927A396538KQ38Q239CY38KT38WC27A39D1332I39D3392T362C344R37NQ396J39D933NQ399W360N393439DF39A1396U393A365P39DL33J039DO35UO357W39DR36GF39DT39AF374J39AH397A39AJ333F39AL2KZ39AN397G38QY39AQ32F2394333IU326G39AU39AF394939AS39AZ39EE397V2L6397X2BQ394J394X2QI39B8389H39BA398527D39EQ34ZK39ES38JJ39EU38Y639BL38D239BN39GU39BP398K39F4395828G398N39IW39FA391R39BY36Q237LN39FE37SC32OI39FH39C5399031RZ399239FM399432JK39CE395X390G25E39CI325Y341K37ZF39CW392J382X32Y138FU38NT38FW39GV391E35RY39GY399Q392V33SM399T33SQ393127D39DC33RR393C39A034KM39A235LB396U39K835JJ39A8389635RR39DP33RH393J39DS36DW37KI39HM39DW34GP39DY39AX39HR326G39HT393Z39HV39E439HX39AS39I039E9397P39EB39I4394C2BQ39B134M632F2394I397Z37OC29S394N37UX39EO34NP39IJ35P2398838Y439BI38EN3908359A37OE397Y39F739IW390G32US3499352N37PY370T3769370W39FZ380K368A3712380O371534E93717368K376O380V368P39GB371F39GD376W381139GG3690371O381639GL32TQ33X036R137BY32IR32HJ32MI32F221V28038DJ2AR22U2BM33AX35M72ZU32IZ3738346332WN32WP32WR37FK32WV38VW37FO35YA35BI37FS32WM34PA38NQ384X34BV36N735JZ38QD38OA386U27933VQ330W32YH21E1L366G33OQ344I36R533SB38L936QX35BW32Y036R036DP34K833VH35C429H29J342L33XW33WR2F535WE34G835TM34G838V92BQ39NL390T392L390V38FW38WK353P38WK33WB399Y33WF359A1234X039OD39BG33UY32XW33XW333I32WM34Y8336V39A435SM372838H332Y8394Z37EE39LS27A32ZF39IV37HR38DE39MW35XZ21T38YK38SA38YM38SD36X939NH35YC38YR35YF38SL35YI35H834I3325Y22339MU37HW39MW318039MY2B229632TI39N335MC39N52SU39N737LP39N9355732IF33MA32G936S123235Y4343D34D938SA343Y34D739NK37QD39NN355R34FP37ZS32XW38ON34WC39NU34R039NX39NZ36EX33R4362W34VA32YQ32ZK39O634R439O936EX332I37E334Z839P439OF32Y039OH38OZ39OK36N434JM2BM34C939OQ38DP39GR39JT392N39OV33VE39OX2EY34KC39P037EE39P22BM32ZR29H36ZI32H339P733S4375539PB334O332I3604344I39PF38JJ39PH39EV37YS36EV32K031CR38KE36SP23623232WS38MZ39PN37AP392E39MW38DH373Y396339MR369Y39Q732FS35WV39QA32U639MZ39QE39N235L032GQ35X039N629M39N829P39NA37FJ35BA39NE36Y935BF38SG39NI35BK27E39RZ3519386Y39R235F135PS39R538QQ344D355Z33XZ39RA39O038E436CA39O339RG27E39RI36QZ33O336G937DQ34T0351Z2BQ39OE352Q39RS372V39RU35K639ON34C935UW38UP39JQ33O438WB36J138WG39R7316O34H737E339OY39S827A34GK2KA39P339SD387M361R37NP387237V439P927E39SK32Y0330W330Q38Y239P5333I38ZD39IO33SJ39PK2M337S637P139LW32MM37WQ33B233B4334F33B72F5332639Q639Q8337I39W339QB39TH39N139QG2AD39QI38RS39TO39QL39TQ39JL341K39QZ38YX39R1352I39R3361J39U738IU39U939NV332I39UC39RC374O39RE37QN39UH27D39UJ39O839UL33XZ39RN33O239VG39RQ32XF39UT33RR39UV36O439RW38P02KA39U139GQ39OS39CZ39GT312234H739S639OZ39VC39P139VF32Y039SE38TJ34DC39P838R939VO33TS33RC35VH39SP38WN34QN39PI39VX38P239T3378D38A022A39W339WP358U39TA332339TC32JN39WE39TG39QD39WH39TK39WK34HC39WM36SB39N938FN330539WR396632LY39U339WU39U538O439NS38WC39R834H739X238L239O237JW393D27A39X932XF39RK35SX39RM39UO39RP39US335R39UU35QN39OL33VE39UX359A39XP38SR39S138Q439S334R039XW39VB33WI39XZ39SC39Y139P539SG375339VM27D39Y734YA39SM39PE39LM3906374I39YE32ZB39VY378A39YH38I1399A32I339W3384236I5384536I836IA36IC29W384B36IG384D28036IK384G32VL32IQ36IP384L39W939MS39YQ32OV39YS27A39QC39N039QF39YW39TM39QJ39YZ36VW39N938X236TC33M238X633MV32UR33MQ33MB33MD38XB33MN33MI32KM36TQ33MF3A2338X938XJ3A1X36IR36U039GK36U433N939Z439GP33FA39Z7379X39NQ34FW39R6379Q39ZD39UB2EZ39NY39UD33T539UF39ZI333W39UI39JZ2KA39ZN39UM39V733X539UP33UZ39XG2KA39XI34ZE39ZV39RV39E839RX39ZZ39CX39XR39GS38SU394C39XV35CD39S736DO3A0839SA39Y032XF39Y2377L39Y439SI33ZO3A0H33RS3A0J39YA3A0L394W3A0N39SS33FH391B31ZL39CT38UM38ET357H357J38RT27A24I39W338A024Y39W331A734373439343B32VY34D7343H349D343K32U229L343O3A4P343D343T32W427S33MP343X37C436WT34DI37T838VV34B23A3H3745392M39XT36RF330W37YL392T33EI39O739RF33SM37JY37U136OP344U36LI34HG34DC34KA340S386W35SM34LH38H333263A0O3A47395132B432403A4A359F3A4C32QY3A4E38PK32OL3A4I395Z26A39W3386F37C238XH34D5386J386L32FG38SO32AJ39Z538FS3A3I39S23A5E34R03A5H39V433S4332037NI32XK37W737NL36LN34W137CZ32XF3A5S34FW3A5U399Y38AL3A5X3A4338LY39B43A6137UL39SU2BT3A65340G38UL3A6738ZI2KZ357I23A357K3A6B37OV348Q395Z1I32N2388B388D36WU347P27E34B339V038AH39OT392N3A5F332I3A6W33ER3A5J33133A70374I37QQ36523A7434NF37K32BQ3A7834Z73A7A39DD330W384U344I3A5Y38JJ3A603A463A7I341237B63A7L379G3A7O349438HC3A4D3A7S3A4F33VF3A7Z38FK3A7Z37FH39NB35B932WU35BC39NF349D39PY35BJ384M3A8539OR3A5C3A883A6U37W438XW33R43A5K39X63A5M37U036N936JM3A753A8M27E3A8O33GW3A8Q387I38DT35VH3A8V39YC3A8X39VW32ZB318036HS3A493A7M39CU38RD357G3A693A983A7U38MN3A9B395Z2363AAR35M6399G35U839JP3A8739XS3A3K2J03A6V3A9U374O3A9W357W36QV3A5N3AA034C53A5Q33WH3AA532XW3AA738EH3A8T36CA3AAB38BB34I33A7H357R38RC3A923A7N340K3A6836CW3A6A399B2423AAU342X37PU38RN3A7Z38PY3A5A3AAY38XS37VS3A8A37XG35VH3A8D3A6Y39ZI3A713AB937QR3ABB3A7635AI37JV39K537CI3A5W3AAA3A7E39BH3ABM3A8Y3ABO34R43AAI3A933ABS3A7P3A973A7T399B25E3ABY33L7399B25U3A7Z39T732UK395P3AC43A6Q38W93A6S3A033A9S37ZW3ACA3A9V3A8F3A3X33NX3A8I350D36NO3ABC32Y03ABE355P3A5V388N3ACO38R53ABL34Y93ABN36GY338W3ABQ3AAK3ABT31KA3ABV32H326Q3AD3373U2AQ2BT33B137WS39W637WW3ADB3A2I38ZT3A0238ST37213AB23A9T3ADI3AB53ADK3AB83A9Z3ACG3A5P3ACI3A8N3ACK34ZX3ADU3A7C3ADW383D3A8W38WI37XN37EE3AAG367W3AE33A4B3ACY3AAN3AD032KZ32NG390G21E3AFH36I332J7382G34D932IJ3A2133MG37JG39QW3A55341F3AD432VE3A1A36IO384K38W6330P3A5B382Y39V33AEN31JU3AEP369P3ACB3AB63A8G3ADM36513ADO3A8K3ADQ3A773AEZ396N3ACM3ADV369P3ABK38CW3A7G3ACS3AE137LH3ACV3ABR34CT3AE53A7R3AFF2BQ22A3AFH38A022Q3AFH39PR39PT36TT35Y539PW35Y939TX39PZ35YE38SK35YH38SN3AEI3A863AC638FW3AC83AEO3AG93ADJ3A6Z3ADL34QN3ADN361G3AGG3AEX3AA43AGJ3ABG38DU3A7D3ADX3AGP3ACR3AAE3A6238ZG3A7K38YG3AAJ3AFC3A953AAM3ABU3AAO399B23M3AH2395Z2423AFH39YM3AHI3A9P3AG43A5D3AB13AG73ADH3AHO3AER3AHQ3AET35KF3A8J3AA13A8L3A5R3AHY3AGL3AF23AGN3ACP36ZJ3AAD39LQ3AF8390A3AGU3AE43AFD3AIE3AGZ27E24Y3AII3A0U35WV3AJK2A13AAW3AG23AC5399J3AHL3AB33AEQ33TK3AGB3AHR3A723A5O33393AGH3ACJ381J3AHZ3ACN3AJ63AI239173AGQ3AI53A8Z33EW3AFB3A9438HA3A963AFE3A9926A3AJN3AD43AE83AFH39QN32UL39QQ32IO39QS343R386K343B3AFT22T37T534D73AIN39S03ADE3AEM37CL3AHM3AIS38UY3AHP3ACD3A8H3AGE3AHU3AJ03AK23AEY3AK43AJ438C83AI13AF43AAC3AF637YR3AI63AE23AI93ACW3AGW3AJF3AE63AIF32H31I32NR39LW3ALZ3AIM3A843AG339JR38US38XT3AL63A8C3AL93A5L3ACE3AEU3AIZ3ACH3AA338RS3AJ33AF13ALJ3AF338ZB3AF538XY38TX3AAF38TZ3AI827A3A663ACX3AIC36PS3AKI3AAP32K03ALZ39YJ3ALZ38KM23F38KO3AM33AJR3AEL38ZV3AHN383B3AJV33HO3AJX3AIX34GZ3ABA3AEW3AMG34HC3AMI3A7B3AMK3AK73ALL3ADY3AJ939BK33SJ3AF937EW3AKE3AMV3AKG3AID3ALV3AJH27H3AN1395Z23M3ALZ38UA39CL38UD358R38UF34CM379B39CR379E3AIA359F3AN73ADC38YY3AL33ANA3AIS3ANC3AIU3AJW3AES3A9Y3AIY3AGF3ALE3AHW3AMH3ALH3AMJ3A8S3ALK3AMM3ALM3AMO37LE3AJB37593AMS34NW3AOH3ANY38U13ACZ3A9924I3AO43AJL3AJI3APH338F28U38I73AOJ3AEJ39673AN93AM73AJU3AOQ3ANE3AOS3AMC3AOU3ALD3AMF3AJ23AOZ3ANN3AP13AML394V3A7F3AI43AJA3ANU3AJC3ANX3ALT3AMW3A7Q3AE732NN3APK3AKM32LV3ALZ390J36S2390L38AA371G38AD390Q3AAX3AOK392K3A9Q3AB03AG63AM83AB43AOR3AIW3AOT3ANH3AEV3AK13AOX3ANL3AQ23A8R332I3ABI35313AJ7333I3ANS3AMP3ALP32Y63AQC348U3AQE3APE3AMZ35K73A7W3API32NE32O339W43AEF37WU33B5334G3AL138KR3APR3AC73APT3AL83AIV3ALA3AGD3A733AOW3ANK31I13ANM3ARA388M3A8U3ARE33EM3ARG3AP63AQA3A633AJD3AIB3ANZ3AMX3AJG3A9921E3ART38FK3ART38VM341838VO37MJ3AKZ38N937MN38NB38VT38NE37TD38VX38NJ342838W138NM38W438NO3APO3AHJ3AJS3A893AS339V53AS53AMB3ALB3AS83AQ03ABD3ASC3AA831883AQ539VT3ASH3ALN381V33SJ331Z3AFA3ALR3AGV3ARL3ASO3AQF3ALW37HW3AST3AAS3ART3ATE3AIO3AM53AG53AL53ATI37HL3APV3AR23APX3AR43AME3ANJ3AQ138353AK53AGM3ASF3AK839893AKA3AQ93AMQ38Y83AP93AMU3AQD3AU43ARN3ABW3AU83ARR3A4G3ART34RX37MF37T136WR36IG343Z38VR38VV36XY36X232X436X432FG33MP22Z36X832UB36XB34A036XE34DQ32FG36XH37IS36XL35YC32EP35Y634A036XR346132UO36XU36YE36XY36Y036Y237C432WI36Y538N636Y8386H36YB32L433M336XW3A9N3AM439V23AIQ3AQY3AUG3A5I3ACC3ATL3AS73AK0334U3ALF3AHX3AR93ATR3ARC33RU3AUT39LN3AQ83ANT3AUX3AI73ASM3AKF3APD3AMY3AD13AV53ABZ37Z132P43ART3AO834CE39CM3AOB39CO3AOD38UI39CS3APB34CT3AUB3AL23AQW3A3J3AWO3AG83AS43AR13AS63AHS3ALC363V3AHV3ASA3ADS3ACL3AP03ARB3AP23AQ63ACQ3ADZ3AGR360Y35A63AUZ3AXQ3AU33AXA3ASQ3AMZ26Q3AXD3AQJ2BQ32OD34D127D382837IV37TB3AT5382E37J133ZS38A6382K2AR340E382N37JB39T0382Q37T63AVF38NB3ARZ39XQ3AXU3A6T3AIR3AQZ3AND3A8E3AUJ3ATM3AWU33HE3AR73ASB3AWY3ABH3AYA3ATU32XK3ASI3AF73ASK3ACU3ARK3AAL3ASP3AO13A991Y3AYR38A021E3B0537XZ38BZ3AXS3AS03AOM3APS3AXX3ATJ3AXZ3AWS3AY13ATN3AUN3ATP3AZQ3AI03ATT3A5Z3ATW385T3ARI37WG3AZZ3AGX3AQG27E22A3B083AV637LR3AYR37BX37BZ35YC37C232VP29839G137C836TX37CB3AZC3A013B0D3AS23B0F3AUH3AZJ3AY03AJZ3ANI3AR63AY53ATQ3AZR3B0P3AMN39BJ3ARH3AKC3AU03AMT3AYI3B003AU53AO2386C3B103AXE3ABW3AYR38263AYU382A3AYW382D341O382F382H2363AZ137J63AZ437JA37MX37JD3AZ9344138NA34453B1E3AEK3B1G3AJT3B1I3AWQ3ANF3AR33AHT3AY33AS93AUO3A5T3ALI3AQ43ANP3AP33ANR3B0R39XN3ACT35MK3AX83APC3AKH3AYL399B24Y3B243AYP37Z23AYR3AKP39QP23E39QR39QT34D83AKW3A543AKY36WT2AI3A6O3A9O3AXT3AIP3A9R3AZG3AWP3A6X3B2X3AUK3B2Z34U33ADP3AZO3AY63AF03AQ33AY93B1S3AP43B1U3ASJ32ZB3ATZ37Y13AYH3ALS3AYJ3B3F3B023AMZ26A3B3J3AEB32P73AYR3B0B3AZD3B413AQX3AUF3B2V3B453APW3AZL3B1N3AWV3B4B3B1Q3B0O3B363AYB3AJ83B3939OO3AGS34B23B4N3AU23B203AV33ALX32OP39LW3B5O3AM23AQT3APP38C23AS13B2U3AIT3AXY3AUI3B1L3ACF3AUM3B1O3B323A793B343B4F3B5C3AZT3AUV3AX53B0T32XF3A0S28G315I36WA32J836WC22838DK23A22A34DZ32F222736IE27T32U13568395Z21U3B5O3A9E39TS3A9H37FM3A9J39TW37FQ3A9M38ZR3B5T3A6R3AZE3ADF3AIR390X332I34Q037CQ379U37G338G327A3A2T35PM36MP39XU3B683B0Q3AP53AZW3AX637EG39BT37AP3B6G373M3B6K33M43B6N2BF3B6P3B6R32U0356P39X53B3K38MN3B5O3AEE334C3ARW39W738PZ3AB23AN83B2T392N3B7C38ZW3B7F37D037CI325Y3B7K3A7439143B7O3B1T39LP3B6B3B1W387T3B6E31F53B6H33M334033B7Y3B6M3B6O31803B6Q32U13B6S3B85390G23M3B5O3AFL32J83AKV343Q3AFP32VF2B63AFS3B3U3AKZ3AFW36IH3AFY384J36IQ3B763ATF3B5V3B8I34R03B7E37G33B7G3B8N27D3B8P3AA13B8R3AUS3ANQ3AI33AYD3AKB3B3B3AGT3B8Y3B7W36WB3B923B6L3B8027M3B963B833B6T3B863B4V24I3B5O3AN43AN638W73AQU39V134HP3AUE37JQ39BB38UW37TX37K43BA13B7J39NZ3B7L33XZ38Y13ABJ3ASG3AZU3B5F34C93B4L337I39W039F83B8Z3B7X3BAH3B9527D3B972353B993B6U3B1125E3B5O390R3AWL3BAW3AWN37CL3B8J33IW37QL377H3B7H369Y3BA336OR350I3B4G3B383B7Q3ALO3B8W3A843BBG39LV3BAE3B6I3BAG3B7Z3BBL27A3BBN3BBP3BAN3AC039C23BAQ28D32ZI3BBU3B8G3B793AL43BAY3BBZ39BB3B8L37GC3BB333VF3BB53B8Q39033BC83BA83AZV3BCB3BAB32Y03BAD370F3BAF22U3B933BAI3B823B983B842BM38A037SR2BT3B3N3AVJ3B3P3AKS3B3R3B9G35Y339QX3B3X3B9T3AUC3AWM3B423AG63BCZ3B9Y3AEZ37CQ3B7I3BD437YM364H3BD73B8S3B4H3B8U3B1V3BDC37I239BR3B6F3BDF3BCH3BDH3BBK3B813BAK3BDL3B6T35ZN3B87330Y32PB35Z936ZW3A6I386H34D63B3X3BDW386M3BE03B403AUD3BBX3BCY3B9X3BB137NP377J3BC53BEC3A3L3BEE3BC93B4I3B7R3B6C36ZR3BDE373L3BDG3BDI3BCK123BCM3BDM3BEU3B4V21U3BEX39FU349E34DQ39M239FY376D39G039M6376H39M8376K39G63719368M39G939MF371E376T39MI34EP39GF376Z381439GJ39MO3A2F39GM34NE3B9U3B8H39XT3BE53BFC34QA3BFE3BD53BA43BED3BA63B373BD93BBC359A3ANV389N3BFO378S3BFQ3BEP3BAJ3BBM3BAL356P3BFW3BCP37LR3BEX3AH623335Y239PU3AH935Y739PX3AHC38SI39Q13AHG38YV3BCU3BAU3AAZ3AXV3BBY3BFB3BC13BA03BGY3BEB360U3BH13BB93AX23A0M3AX43BEH3B5H3BBF3BEK3BBI3BHB3BCJ3BEQ3BHE3BES3BHG3B9B3BFZ39LZ37673BG2380G34DV3BG539M537113BG837143BGA39MB39G73BGD3687376R39GC371H39MJ3BGK371M3BGM3693371Q3BGP36U63B8F3BHY3AHK3B9W38XV3BI33B8M3BI53BB639OW3AZS3B7P3BFK3BDB3BIE34PJ3BCE37HR3BCG3B913BEO3BIJ3BHD3BCL3BHF3BDN395Z24I3BEX3AC33BHX3B773ADD3BCW3AON3BGV3BJL3BD23BJN3BD63BFH3BH23B5D3ARF3BH537EE34G232Y038KJ3BEX32B8388C37Q634DI2BQ33833BGS3BKD38XT39X0352R34NP33QN34523AJV3BH33AK9334N3AE033OQ338W392E3BEX37Z53AT234451Y358M2AI358O32KM39CN358T3BKY3BBV392S3BF937QI3BL333G33BL535EV344H3B0G3BL93AUU3BLB3AYE333A37HP3BDO32PR343637BY3A4O343Q3A4Q3B3X3A4S32WZ3A4U343M3A4X3BMD3A4Z2973A513AKT3AKX3AKZ3A573B2P37JJ27E3BKZ3BE13BBW3BE337CL3BLW39UA330W3BL6332I3BM037HL3BM23AX339013BM52ET3B3C38A01Y3BM9348R3APM39CV39E83BCV3B503BI03BAY3BN132YH3BN33BLZ3AR03BN83BIB3BNA3BAA348W3AX738FK3BM93BG039M13BIT376C349M3BG63BIX380N3BIZ39G53BJ13BGC380U3BGE34EI39MG3BGH3BJ73BGJ368X3BGL39GI3BJC377338XP3BMV3BLS396D3BMZ3BNO39R935EV3BN427D3BN636RS3BKM36QT3BEG3B4J33JG3AJC3AH33BM932XQ33E832XT32V13BLR3BNL3BF83BOU3BLV3BOW3BLY34NP3BP038AZ38H338Z73BNX34KG39SU33YW33Z8346329R326G2AR23723B382L3B2038RF38JS38MA32JK3BM935MH22321S32FD23E32H32423BNG27D3B6K36S1345X34EU32LK3BP932IE29622X32TN348132F23B6N29Y343M28Q35HV3B6K27S23123E21V32UE22F3BQ93BQB39PS345V22Z32H232N83BQM27A3BQY3BQB21X3BQ02KZ22723133ZR3B6S31RT37MQ3BR22AT324039PS32G3368C3B9S32403BRJ28T36S032VJ31F53BRX32FG37J02303AH132TW341C32JG3BQF36MQ338Y2AO2BB36XJ343K33HG21Y28F22X3BSF38RH25U3BSA34D132EZ28Q2BB21X33M428E38D938853BM9315I3BRE3BR03BRP32HU2A332U02YT3BT3369623C3BS43AE83BM931BV3BT732IJ3BT932VJ3BS632HF3BRY33HG38KH3BRG3642315I36SF349O32TF23239TP32TQ36PX3BQ022622Z22O36S033MO3BRI35Y63BTN2KZ2BX2AN3A1M32HJ32Q033BK39TM32B82393BQO3BQQ38YV3A1P375J3A1R39TQ399F37Y039551124824B3BUS3BUS25N38H938D4337I3BUB3BRR27T28F21Z346229637HP318032TU3B9R38YV392C32KZ3BUB31HD22322T33M32AR3BTN3BV829M3ARD27A3B8029P399B21E32Q032JN3BUB317634CG3BRY22922Z23C38PU22Z23E32J32ET3BVY3BW02KS22F21Y3AVN21C338W315I21S348336XE29834A239PS32FD37I837ES2313BWL34K13BNH36PU3BUQ3BUT3BUS25737PS3B253BQD3BUB3AC339NR326G38VZ28738AE3AV937T036WQ27J36WS3AVE3B2O3BLI36WY36X03AVI32L436X53AVM3AVO32X43AVQ36XD36XF3AVU36X03AVW3BRK36XM3AVZ36XP32US22O36XS343D3AW536XW3AW732V43AW93AKY3AWB2823AWD23536Y933MA3AWG36YD3AWJ39H83BKB3AOL334V33GE359137AH34Q73BJT34C53BWE3BWG29729U22U3BWK37M037AZ3BWO37M0327B29723322821X2BO2KA32HL3A803BKW388F27E335K25K34FK34FL36QR33NG37UR33RG38AU36AX34BI354Z32XI37U4398033V63BYO3B7J3BOR357P3BXP21Z27T2AK33L82A028623F2AO324032W12AR29P3BW627U3BUE3BUG29W38YV2S421T32VN346336S937I036S02YT22C349Z23937WU2BF3C0937EX37I735PH3BVB2KA24C32LH242319C28I3BXT3BRZ382F342627Q38NI3BEY35M629U32IK22Y3BZZ23A370J38VZ32W232GQ32VJ32OS3BUB32B832V322T27K3BSI38KO31803C1R22V22E3AVN27U35VN22S3BZ122F34CI23E3C1W343K27Q32G3227342332J437M132FE31N33C223BW23C25342C32H82363C292A432IK386138BO39IR2MD32K335MX32KU23X37OZ38FF39Q72313C1U36Q112349F36Q738PT21V22P32VM27L3C3629A38PT39N22OV36DF340H22F341A383Q32HH28Q2S43BMI29L38FF359H32LC3BVD2B532FG23332IR3C3436SP29H37BX27Y2332333C1B338Y3BTN28T34653C3W3C3B3C3Y3A6P2BJ32UE37TN37EN2333C3A22Z3C3C31CD32FD32UW29932J72A432W429Y31CD22T32FD32W42323BVJ32VH29M2F83B9K37IC2363BUB2T132FD2A33BVZ3BS42ET3BHM3C4S2A033N73C0338ZJ35132973BTJ3A0T382732UN32H929D37AU3C003C1229U32G03AQE3BQ338HG38RH23M3BUB3B1437C03B1737C43B19368A3B1B37CA2AT39LS38WT390D38YD38U6396237VL34C538NQ33HO357V3BYK383533XW3BYN3ATX32ZB32FT3C6B36MQ390E38YE3C6F374036OP3C6I357U2F535903C6M2BM3B8V36H538U0390C3C6T3C6D32TQ3BLH38NF3BLK37Z935YF358Q3402379839JN3C6Y35NK3C70336P3C6L3A3W3C6O3B0S36383C7738YB3C6C38ZL32TQ3BAR3A6O334U3C6Z3A0A34VA35U937V43C7R3B3A39MS3B2038ZK390F3A6H32IV3A6J33M13A6L343B3BF539A03BYH3C6J3C713C7P34FW3C6N3AUW32XF38FP123BIN3BZE38Q0357932XI34FA39IA3C7T32XF315836B631PN35FI38FQ387G35G427C39RN33VE37E3361R29D38LF331W37ZS2BB34KM27C36ZF34NP37AC27C372K37DP37D333IF27G335K337X27C334Y32NE37KU38CE27A312D32H335C8351J36L839UN2AP36153BZM31MI331X354Z315I38E53176364B2A03636351X396Q33QS27A26N29S32ZZ331X33PF31Y633R931BV33I335UW35CU3180394X1T335R34QD333F2QT33PF365I331M35CR33U035LT33Q0354Z34U02MC3CBD3CA02AP31HD29D21E1B333634D035JX374I382V2AP35K1334P38E136J72ET34WS315827C37BX29D3C942ZU331K2KR3ALX37KU37FH3CC737XA37RJ37VO3CCC360T3CCE340P3CCG2F83CCE35M134PW3BZL37DQ21Z33S4351M341232H32FD33SP2AP351S392O381A28N355734BP34YT336V1Y32C03AMJ34FN35O4333I352V3C7634BR35KW354Z334T36LI38O933R73A38351P311033IA35SG39EL353X34Y925V355O3AI635O434OZ32Y433OA354I34RN35XZ39AY39JO3BZB3C8Y375835UY2AG34ZA31582FR3562337M36BR34ZW3CEC2TG3BOZ381A319K32XK337537DL2BQ397N39B22YT32WM317F37H732XF32IX337K3CEU28H34ZA3AZP38DW35O13AQ712345H38GW33SJ35G0360F34VA354Z37FT33O2350S33PF36I334NF385A33Q732YQ3BZS12334L3BPF3BE23B513BAY25U34R03CFV3BL834HX36FS35DZ377J3APV3C9G3AGC38T63AY23B492ET33UE37K337NP3BKN35RR35SW3AGA351V37QO3BD23C9536JG3CG437UO38QM38CO354U33FI3C9X2KS39VJ38TK35RR369H38L12FD37GT33EI3853355135SG36OA3BKQ39302ET39KG2A038TC2A634JK39E13523355M3CAN3CEK34U3354U2S4393C2A0337D36QX28C342L2PY3CCV372G32XW36P73CH437ZS37KW354Z357W36NO39XE33VJ33PF337W38AY37NP3CAF333F22W354E34MA3CBY3BZK359B363W38FQ354Z31BV3CAE2ET3CAZ37NQ3ACB3CH2331A3CHX351C37KW39K437QN35C7356Y3CHD2KZ35IB355L2KZ37NP354U394338952A03CHL3CJ736ON35RR3CBI3CG829D34TD3CH536JZ33R4397232ZL352B3B8M354U37KW353233RH2BB3CHB393L36A731803CBR39783CB134QA33PF3CJ635EH3CK031RT365I393G3CJN2KS35K13CHM2VW33R439OI3CJL351Z37NP33PF37KW3537353Y326G3CHB34U235DZ34RN35KY33TA33PZ39AI326G3CK2351Q3CJ9355I37FH36BI39OI3CKH31RT34B735Q33CHV33I03CIS351Q37KW335633J034OZ3CHB38Z234PT34Q238SP374J34UJ37NP39E536BG32F23CKY34OZ358Y36CR3BD2351Q3CCT34TY37TP37QN34OZ3CCZ38BD37UW37H63CD035Q732F23CDD3BEA2B43CDS354O34V33CGM3CLE33VM3CLG34QA3CLI38YI38GK3CLL3CLD32F23CM137L133RR34V3396533HO2943CEE357W34RN35711236QX37R92BQ32GA33G9335X332I35YL33NP2LP3CF834WT31HD33EK39P33CER37AH2LP39SJ35PT333W29R2B431XQ35K63CNO34UT36CP32F23CFC37RN35FR37OI38OZ357W33G93CFJ3CMQ33V63CMD3CMN34PV34Z43CMH34U33CMJ3CCX3CML33IB34VA34OZ21F3CNX375535T43CNS31803CNU33T635PH37V43CM334QK34K13CM631802ZT34Z43CKO35JN32B834LY35RR34OW32XK3A2T2B42F7358H33R433XL34RM33HG3CHB3CEP35DZ34XT21N37CY39IB3CBJ2B43242389H1G1635GI3COS359B34RN3COV3CE634Z23CMJ362H3C9133X43A2T29435S1330F2AB319K31RY350F3CMJ3CPT37GU33HT35TG33U531J42LP336I35TG39S438QY31HD39IC325G33Z338TO1G22D34MP2BT3CQ731ZL3CQ934II3CQG31J42AG3CQX31PN3CQF39EE2S43CQL29432B438TO37H32943CPL33H334QP350S3CMJ31LU34HP2FR33E531QX2EY331F3CNE2BM33J833V334XL39NO2YI3CRE31ZL3CRG34HH2FR3COO34WT2AG33SG31RF39P3338E39P3338I39VD2BQ34WY32Y039P33CF239P335CN3A3S39VE2BM33WH39P334XH3CET39VN35G3330W25Y35SM33EE3BA73BLA35GX3BKO33SJ34B9338W37VJ3BPV2KZ3BPY3BQ02AR3BQ239WL38M83BQ438RH24Y3BUB3BQ83BQA3BR032JG3BUB2A03BQH32IO3BQJ346Z32NN3C1M3BQN2343BQP3C0D3C5H3BVN34833BQV36FF3BT03BR13BR33BR53BR03BR729F3BRA32NB3CTO3BRD33B73BRF3BRH326G3BRX23B3BRM2BB3BRO32UE31ZL3BRS3ARW3BVP28Q3BRW3C133C5A315I3BS23C1427Z3BS636Y73AE83CTH33ND3BSC33JZ3AYT3C5N3BT532B83BSI3CTQ3BSL32HJ32Q32KS3C5Q37N63BSS3BSU32H83ALX3CVA3BSZ3CU93BT132UE3BTE3BT52T13BTE3C593C1K32KL3CVA3BTD32HV3BT83BS43BTI34CJ28G32B83BTM3BRH3BTP3BV139F92A43BTU32HA3BTX3BTZ3BU13CEY3BHE27K3BU5326G3BU7346N39TJ32H321E3CVA33L63BUD37F63C0C3BQR3BUJ3CW93BUN38BZ3BUP3BUR3BWU3BUV389O32JN3CVA3BV0349O3BV3297345Q37XQ3BV73AFZ3AHH3C0W3B0Y3CVA3BVE3BVG39QE3C4Y346I3BVM123BVO3AXF37LR32Q332NJ3CVA3BVV2963BVX3BVZ3BW13BW333CD383K123C0S2A03BW93BWB31F53BWF29Y3BWH3BYT3BYV3BWM3BYX3BWP38I532J332EH3BWT3BWU3BWW39JI3CVA3BO239FW34DT3BIU3BO63BIW380M39G3380P3716376M3BOD376P3BGF376S368T376V3BOK376Y3BJA3BON3A2E381834O334FW3BX3342C29732IX3BK93C6H3BMX37QN3BYL38BD3C873B5G3BYP27D3CY822X3CYA3BWJ3BYY3CYD38S73CYF3BZ032TW3BZ33BZ52BQ3BZ737BT39L827E3BZD3C8W36QO3BZG3BD336QQ3BZK3C9735TG3BZN332M3BZP39LE3BZR3C6P32XF3COB2T8370T22V3BZX32EP3BVP32TM3CV031ZL3C06343F324V3CXX33HG3BUF3CTQ3BUH27U3C0F3C0H3BVP32J72AK3C0L2T13C0N32GE3C0Q38HE3D1137LY3C0U399832HJ3C0Y32KR3C1031CR3BHM3BRY3BS43C1637TF3C192A13C1B2353C1D3BVP3C1G32U03C1I341C382F32I33CVA3C1N22V3C1P2303C303C1T36SP3C2H32BH29E3C213C233C2H384J3C283C2A3C2N37BD3C2D31Y63C2F3C243C1X3D2M3C2K3D2O3BSR38BN389U3C2Q346S35MT32K83C2V33HG3C2X36843C3035JX3C333C4A32GV3C363C3823A3C4I3C3C34ZK2S432W422U3C3H36S232J83C3K2T83C3N3C1V2313C3Q32MS3CXG3C3T34AG3C493C4J3C4B3C4032TW3C4336903C46376V32U03D3I3C4B31BV3C4D3D1G3C4G3D4B384G3C4L2313C4N3C0J3C4Q34833C4T3C4V32V63CXK3C50325Y3C5237PL3A4G3CVA3C563CVW3BTF3C5A29D3C5C34843BSB3C5G3BQS3C5J3CW02KS3BSL2ET3CVC2KS3BHM3C5T3CT639YY3CT83C5X32H324Y3CWO3B092A53C6A3A7P3C8B38YE3C7Z3BYG3C823C6K357X3C863C8R3C923C8A3C7W390F3C6W3D5W3C7M3C833CZK3C733CZN34C93C6R3D5S3D6438YE3BHL3BHN3AH838SC3BHQ3AHB37FQ3BHT3AHF38YU3C8037QD3C8M3C7O3D5Z3BYM3D613CDE3D633C793C7X37FD3D67330B3C7N33J03C853D6X3C753C893C6S3CY23C6U38U63B28349X382933MA3B2B37JI3B2E37JF3B2H382L3B2J38VX3B2M3B2F3A583AZB3C8K3D5X3C8N3D6W3CZM3D6Y27E3C8T3C8V3D09340P3CE737Y63D7838EM3BPS319V3C9533003C9G35C134H333003C9C330W3C9E3CGL38O82KS38LF3C9K34GT3C9M39A3332I3C9P2KZ38LF33U828H3C9U33J53CGS3C9Z39803A9W32FT3CA43BYG32XL34I7351C2S43CC12YT3BZK28C3CAI38E331F53CAH38FQ36ML36LJ3CIS38CJ3CAP3CAR354I3CAU34BI29J3CAX33G33CIN39HN31573CB327W3CB532N03CB73CK527E3CBA397036BI3CJD37QN3CBF3CBC35UO37H327C3CBL3BA23CBO35Z6369N35C332Y03D9D3CBV38AR38CG29D3CC033003CC33CD13CC63CCO3CC92IU3CCB3DAZ2F53CCE34B73CCK3CQL28N3CCJ3DB3325Y3CCM369Y34TT3CCP31573CCR28N3CCT32HJ3CHT3BZT3CCY39JW3CA93CD2391B33X436BZ32KL3CD83ANN3CDA35NP33EM3CM83A483CBS38542ET3CDI355Y3545352P33ON331X351Q354O34Z139EK39ID35FD39B43CDU3CF236GY3CDX34ZT397Y33NT3CE427A3CE3394B39GN39EE369D3CE835QL3CEA3C9334II3CEE3CER2AG3CEH34II35712T131583CEM36ZP2BQ3CPD3CHI32ZN34N433ZO3CEV3CNK27A3CWE369D317F35EB3AGI38CA3CF53AYC3CNB33YS36YX3CFB33J03CFE356K35UK3CFI3AZN3CFL34XZ33I13CFO3CFQ3BJH3ATG39XT3CFX33XZ3DEB3AXY3CJL3CG03BE837UR3A8E3CGM39VU3B613AOV38L937U33B8M3CGD37CJ3CGF3ADJ3CL735NO3CGC36QT3C9F33J03C9938CN38EB2KS3CGR2AP3D9338QH38BC2MC3CGX36Z63CGZ33R43CIQ35YZ3CI83BNC3CJJ3CH839DN351H3CIY33VJ3CHE38GK3CHG3CHJ2KS3CK23CHK3CHH350I39X828H3CHR33UY33PO360T3CJL36683D8N3CHZ3DFK3CIC38QM3A3634U33CI537CY3CFL3DFH3CC43CIA3DG931CR3CIL3CIF3DGL35TT3CIE3AQT3DGN27A3CIN360T3CIP3CGH3DFG3B303DEI39H439HE3DFM34Z4353U39HO326G3CJ128R326G3CJ43DFT3DFW2T83CKB35IF37CJ3DAB3CJH27A3CJG37CW3CJI374O3CJK351W36AT3DHE2F8353S3CGM33PF3CJT39AE3CJW37CY3D9Z36A12BB3CK233PF3CKY3CB833U039KJ3DFS2A03CKA3CJA2TI3CKD3CGH3CKG3CK437XP35Q33CGM351Q3CKN355H3CKQ37CY35433CLU397M3CKU394639KR2KZ3CL033SX39HG33UT33PF3CL536A43CL7350C393Q2KZ3CLB3DG83CMF3CO7355H3CMJ3D8634Q53COD3CLO31803CK234OZ3CLQ32F23CLS36GI3DJ6326G3CLW34TQ3CLY3CNZ3CMO3COH3CMR37DV35223DJH27D3CM83CP43DCH32DL37RL3DJ932F23CLF3DJC31ZL35XZ3CLK3DJG3DJU31803CMP37RQ34QU355J374O3CMV3CPA32B83CMZ3CN137KO35UT33IX3CN627D3CN833TK3CNA34GC31CD3CRN36BR39XH133CNI3A3Y3DDJ35UZ3CNN3A3D38A134T036F435T62G6350J37FT3CO23D7Y3CO03DJW3CO337DV3CME3DK83CMG3DKA32403D0O3DJF33IZ3COE32F23COG3COP38R93COJ39KN3DLF34HP2943CRZ3CM238OZ34V33CPQ36F527D3CPT35F034JK34RN3CP037CJ3CP23BA239NZ3CP527D39JN3CMU3DG834RN3CPC355H3CPF3CPH39LD37H33CPK397P3CPO35ET39L627A3DMD3BC0354I3CPW397Y3CPZ39NZ3CQ1329J33I23CQ43CQB359B3CQ837KN37DI2QJ3CQN3CQE34JG350I3DNL3CQJ3DCF325G3CQ638LQ3CQQ319K3CQS3DNG3CQU3DNI34BI3CQD3CR133R7319K3CR43CBJ3CR639KY3CR9123CRB387L3DDA35TR3CRF33O43CRI3DKZ3CRM2F239P33CRP34MP34XJ3DJB3CRU32403CRW34RP123CRZ39OY3CS134TL39SB35WK3CS632Y03CS833W5391B3CSC3CSB39WI3CSH3A3R3CSI3DP836OP374U3CRR333V3A3Z32Y9332I3CSQ35VH3CSS3BNU3A4437ID3CSW32ZB3CSY367W3CT039633BPX22V3BPZ3BQ138JP3CT738P73BQ538853CVA3CTD3BQB3AE83D5O3CU83BQI29D27K3CTM2BQ23D37OZ22D3CWS38YV31803BQT22X3CTW3BQX3CVK3CTZ2363BR43CTE23E3CU33BR93ALX3DQH33HG3CTY3CWH3BBM3BRK3CUE3BT53CUG341S3BRP3CUJ3BS73BRU37N63CUO3D1S3BS03CUR3CUP3BTH3BZ13BS832KL3DR03C5E3D0W3BSE3CV328Q3CV53BSJ3CV82BQ21E3DRO36ZW3BSQ31RT3BST33M93BSW27A21U3DR03CVJ3BQZ3DQS3CVN28Q3CVP3D503CVR3D263AH03DR03CVV3C583BTG382F3CVZ3BTK3CW236PU32FG3BU53CW53BTR3CW839WN3BTV38RS3CWB3BU028F3DDL3BFT3BU43CUB36SR3BU83CWL37HW3DRZ35M63CWQ34SJ3DQK27U3CWU3DSX347Q3BUO398J346Z3CWZ3BUT3CX1385X32NJ3DR03CX53BV23BV428G3CXB3BV9325X395X32I33DR03CXH3BVH22V3D4S357B3AX13CXN32VY3CXP2423DQH32LK3DR03CXU2343CXW3BW022A3BW232J338ES33ND3D113CY43BWA2333BWC36VL3BYQ3CY93BYS3CZU3CYF3CYE37M03BWR3CYI3DTN3BWV3BWX3BEV26Q3DR03ASW34A73ASY38N73AT03AZA3BLJ3D7K3AT63AZ63AT838NL37N33ATC37N63BX2376032H038AE3BKU3A813BKX3D7W3CZJ3C72369D3C8Q3D7A3CZP2BN3BYR3BWI3BYU3CZV34K13DV03BWM3CZZ3BZ23BZ432HJ3BZ73AXI38UC34CG3C7I3AXM38UH379C3AOG3B4O3D0627D3D083D0935TG38G13BZH33233D0D34BI3D0F31J43D0H32YI3DNR3D0L3C7S3DRX3BZU123D0Q3D0S3C1E3D0V3D573C0534DP3C083D113C0B3D143CTS32J63D1827L3D1A3BS33C0M3C0O3D1G3C0S3D1J33MN3C0V3DU03C0X3C0Z3C112AZ3DRJ3C152AL3C1834D02363D1Y3D2027L3D223C063C1J3DSH3AJI3DR03D293D2B3D2D35H03D2F3C1X3D2H3C2032TW3D2T3D2L3C273D2X3C2M28Q3D2Q336E3D2S3D2K3D2V3DYS3C2L3C2B38D7388037I2359Z3D3432JN3D3632B83D383C2Z375S3D3B32UG3C3X3D3E3C373BWI3D3H3DZH39QF3C3E32AK3C3G3C3I3D3Q3BT53C3M3B84343M3C3P32JF35WV3DU23D3Z3C3V3D4H398R3D443C423C4423F3D483C483E0329H3D4D23B3C4E2BF3D4G3DZM29H31HD3C4M3B193C4P2323C4R29231HD3C4U343U3C4X3BQ03BVK27M3D4U231395T3D6Z1225U3DR03D4Z3DSL3D523C123C5D3CUZ3D573DQM3D593BTK2A03D5C3C5P32EZ3D5F3DZK3D5I31I138JR3D5L32LV3DR03AC33D5R3AQE3D5T38U637PX349D28E32UI37Q132UF23437Q43DZS37Q73C0D32X432FD3C8T33393D7X3D6V3D893DW03BID36ZQ3D7C38VG390F3A0X384436I738473A1236IE384C36II3A17384F36IM3A1B3AG0384M3C813D683D5Y3E2D3C743E2F334N3E2H3D7E3C7Y36DF3AN53D6S38YX3D6U3D773D6B3D813E2G3D6F3D713D652AH39T83C6G3C7L3D753D693DVY3C8P3E323BP53D623E353C7A37VO3BMT37Z83BLM37ZA3BLO3AXL3BLQ3DVW3E3O3E303E3E3DW13AMT27E3D843C8W3D863DCW3D88383536AG3D8B3CC535RG3C963CH83D8G35ZN2843C9B34R03D8L33363C9G37ZS3C9I361J3D8Q33363C9N33VE3D8V3C9R37H133O428C3D903C9W3DF63DNR3D9527E3D973C8K3D9938742ET3D9C33003CAB3D0G3CAD3D9I3CAG351G3D9H354J3CAL3DHQ3DIC31J43D9Q35593D9S31RT3CAV33GA3D9W325O3D9Y39DW1I3DA12PZ35L0333G351K3CB9354J32ZK3CBH39HG33GE3DAD3CJC3DAF2QI3DAH33OQ3CBN3CBP3DAM396R3DD03CBU3DC33CBX3CIG3CBZ381A3CC233OQ3CC536VK31R43CC837Y13CCA3DBE3E752FD3DB53E7837NQ3CCI3E7C35PS3DBD33233DBF3DWZ1I3DBI354K36EV3DBM35QD3DBO39GU3DAX3CD3340T3CD535193DBW39DD3DBY369G3DC03D6239VP3CDG3DC5351E3DC73D873CDM38FQ3DCC3CDP3DNR27W3CDS33263DCJ32ZS397V393Y3DCN3C913DCP3DCT3CMK3DCQ3DKK3CE63E4F337232Z43DCZ34973DD13DDE3CEK3DD52L63DD73CEL33EM3CEO35G33CEF3CES3DOP3A753CEW2KA3DT334BV3DDN3CDV3AR83CF4357Z36ZJ3DDT38JC3CFA3CH1123CNU3CI12ET3CFF29S3CFH31RT3CFJ3E9H35CN2PY3CFN3D0M2KA3DE73BYH3AQV3BNM3AZF3AG63DEB353P3DED3BM13CFZ3E5U3D0C3DEJ3AY03CHB3B0K33T93ACI3DEX3BBB3CGE35UO3APV3DEV3EAH3CGK3E4U3DF03899387B35HC3DF437CY3C9Y3B8M35PS33693DFA3DIZ37XA3CH0331A3CL73DGX3CJE3DGZ3CIV3CH938L63DH439DX39HS37CY3DFR39DE2A03DFU2KS3CKY361X3A2Z3CHQ350M3E7P39VI352A3DG538O13DGZ3CI03E6I3A8K3CI335TR3DGD35233DGF3DGY3CA9330Y3CIB354Z313G3DGR3E5W3ECI31Y63ECI3CIK3D9I3DGT3EAS3E9Q3EBD3EAH354Z3CIU3DG83CIX3DH3356Z3CJ03EBN3CJ33DHC3EBR3CJ83DHC3CK628H34TX3DHL3DHJ3ECC3D1W33QC3CL73CAM3DI93DGZ3CJQ34VA3DHV39KM35TR34OZ3CJX33R03B8M3CK13DIH3DIU3DJ03DA639KI3EB9354U3DIB354J37BX353S3CL73DIG3DGC31RT3CKJ3DG83DIL34RH3DMF33HG3CKR35773DIR3CKV3DIT3BNK3EBL326G3DIX3E9W3EDR3CL435T23CGH3DJ53EEI3DHS3DLN3CO538L63CO835DZ3DJD37CY3CMM3COT3DDE3DMB3EEJ3EF538UQ3CLT3BB23CLV36A73DJT33GE3CM03DLL34UK338Q3DJZ3EF73DK23DML3DK439CJ34QK3DLO3CO633X53EEY34GP3CMJ3DKC3DLU38J13EFF3DLZ372V3CMS3CP8123CMW33GE3CMY3A2Z3CN227E3CN43DWP33VE3DKW33HO3DKY3CRK3DL03DOL2BM3CNG38BD3DL534BV34Y834RT3DL83DLB3CNP3DLC36GG3CNT3DLG3EFG3D6V3DLK3EG03DJX338Q3EFQ3EEX3DLR3BA23EF13DKE3EFE3DLX3EGY36DV3EDN3EGW3DM4333V3DLI3DKJ3CRZ3EF73CPQ3DME33VJ3CPS33U03DMJ3BB4338Q3DMH3CP633TK3CP934VA3DMR34XM3DMT2ZU3CRB374J3CPI39802B439JN33GI3DN03DOV3DN235EW39EE3CPV31ZL3CPG3CPY33TC3CQ034B435TH312E3DNE3DNT331X3CMJ3CPQ3CQA3CR036BR35S13DO33EIU312235S13DNQ34Q73DOA3DNL37GT3DNV39SV3CQT32403EIS3CQW3DO13DNF3EIX3CR33DNR3DO83CR82QI29439JN3DOD35UK3DOG3CRH35973DOJ36EH2BM3DOM32Y03CRQ3CSM3DOQ34Q13CRV3DOH39OJ3CRL35SB3CS33E3S3DPA34R43DP433W83DP62BM3CSD3DP92BQ3CSG3EKF3DPC32XF3CSK3EJV3DOO3DL639PC3DPK3CSR3BBA35H03DPR32XF38263B3C3DPV35NH3DPX3DPZ3CT53DQ13D5J3DQ338RH1I32Q5359G3CU13BQC32KL3EL73CTI340G3CTK3DQD3BQK3DRX3EL732B83DQJ3DXJ3BQR3DQM3CTV29L3BQW3BQG3DQR3BRP3DQU3BR627Z3CU432JN3ELJ3ELS3DSA3DR33BCL3DR53CUF33ZV3DR93CUI3BRR3DRC32GD3BRV3DR43DRG382F3BS13DY23CUU3DRL399B22A3ELC3E1A3BSD3CV23D0T3DRT3DYK3CV73CV332LC3EMN375F3DS13CVE3DS432NJ3EL73DS93BQB3BT23D503CVO395O3E163CVS32JK3EL73DSK3CVX3DRK2313C5K3CW135133DSR2343DST36W23CW63BTS3CW93BTW22Z3BTY3DT13BU23CUC3DT536423CWI2303DT836V727A2423EMX35WZ36PP3D123DTF39TN3BUK22U39N93CWW2A53CWY3BWU24B3DTP37VA38BK38RN3EL73DTT2343CX73BV5367W3DTX36IP3BVA3DXX3AJI3EL73DU33CXJ3E0V3C4Z3DU731RT3CXO3AD132Q532QG3EL73DUG3DUI3CXY3DUM3CY13CY334163DUR3DUT37WG3DUV3CZS3DUX3DW63DUZ3CZX3DV128S3CYH23F3CYJ3BUT3CYL3BNE32Q736I232QY3A0Y3E2M3A1132KM384A36IF3AFX384E36IL384H3E2V36IQ363Y3CZC3DVQ3BX532IX3BNH348T3D743B0C3BYJ35NM3D793E3333393EPL3CZT3EPO3BYW3EPQ3DWA327O3BZ13D013DWE2BT3BX737MG3AVC3BMR3DVF3BXF36X136X33BXJ32UJ3C1X38YO3BXN1Y3AVS36SP2343AVV349X3AVX36XN3AW036XQ3BXY3AW3380R36XV32VS3BY336Y136Y32323AWC38VP3BYB371E36YC3AWI32VS384M3BZC3DWS34BZ3D0B3CG23BZJ3DWY33T53D9I3BZO3DX33DBX34C93D0O2S43DX93BZY3D0U3C013D0W3DXE3C073D103BW73DXI3CTR3BQR3D1734623D193C0K22R3DXQ3D1F37TN3DXT37SJ39CA3DXW37IA37SN27E3D1N32LV3D1P313G3D1R3BS332VJ3D1U3DY527H3DY83C1E3DYB3D243ENB38853EM032AK3D2A3C1Q375S3D2E36T03DYM3C1Z3D2J3C2G3DZ03C2J3DZ23D2P32XM3D2R34163DYZ3C263EU53D2Y3C2O3D3139EZ388G3C2S3D353C2W2313C2Y3D3A2AQ3DZG3D3D22V3D3F3DZK3E0B3D3K3C3F3D3N3DZR38SN3C3L28I3DZV3C3O3D3V3DZY35X73EOZ3E013D413C4K3E053D4634AR3E0929B3EVA3D4C2AH3E0E3D4F2963C4H3E0I3D4J3D4L3E0N3E0P3D4P3E0T3DU63C513E0Z37IC35J62BT3E153ENF3EMG3D5338YR2KS3C5F2AO3E1C3ENH3D5A3E1F3CV33D5D3E1I2A03D5G33L83EL23E1M3D5K38P832NE3EPZ3D6I38S93D6K38YN3BHR3D6O39Q03D6Q39Q337KV3BNY38U13E1U32TQ3AQM38EW38A932UI390N3AQR3EQL357T3E3P3C8O34Z73E2E3E3T3D6Z3E3V3D723DWG37953E43379939CQ38UJ3B1Z3E4535BO3D763C843E483EQQ3D6E3E1T3D6G38ZM3D5P3EX935YN3EXB3D7Z3EXE3BFL3E3U3E3H3D7D3E3W3C613B1632IV3B1837C632UU3C6732UN3B1D3EXQ3EXA3E473C7Q3E3F3E343EY83E2I38YE3C8D34D33A1Z3BF2343F3BF43A6N3EY136IV3EY33E313D6C359A3D83342P32ZN3E4E358736RQ3E4H33GO33EW3E4K3BZI3DBG34FQ3EAZ3C9A3A34353P3E4T3DWZ3C9H3D8N3E4Z3D8S39KC3E533D8N3D8Y3E5737QZ3E593EB43EJ23CA136ZQ3E5E364F3E6W3ECI3E5J3CAA39O132XL3E5R3CI935TG27G3E5R3D9M33ZH3D9O38E627D3CAQ3E5Y35O43D9T35TG3D9V34BI2B43E653CJZ37DQ3E683DA3330Y3DA52BB3E6D3CBB3E6K393H3DGJ3CBG3ED83DNR3E6N333A3E6P3DAL35NX3E6S3E8Y3E6U33W43F1838AS3DAT3E6Z123DAW3DBQ3DAY3E7433UY3CCE3DB23F1R35RA3E7B3E7I3E753DB8359B33373E753DBC37KU3CCN3F1V362P3E7M3DBK3E833CCW33003CCZ3DJZ3CC53E7U32XJ3E7W358Z3E7Y358734FB36QS32XK3DC13D8B3DC33CII3E8636LJ3E883E4F3E8A350F3E8C352P3CDQ3DCG3E8G27E3E8I32ZO3E8K397O37573CE035O43CE23EIC39GO38TO37573E8V33JS3E9I3CEI3DD23F3J3E922FR3E943CA93DOE3CNK3DDD3DL23DDF3EJX3E9C3DL73E9F333V3E9H3CF23B4C3AMM35FO333I3E9N38QG3DDW3CFD3E9U3DDZ3E9X2BB3E9Z38AY3DE43EA33DX527E3EA63BL03EA93B7A3EAB3CFW3BNT3EAG3CIS3CG23EAJ3B0I3EAL3AK03CGA37QV3BNV34T83DET3AER3EAU3CIS3EAW3EZO33GE3DF138EA387C3EB235233F003BB23EB633U03DFB35LI3DFD374O3DFF3ECT3DFI3DHN3ECW3DH233X53EBK3DIV39KV3ED13DH93ED33DHC3EBT36LL3EBV352Q3CHS35793EBZ27D3CHW3EB5388U33TK3EC43DGJ3CHB3DGB35T0337V3DGE31RT3DGG39BI1Y3ECF2ET3ECH3D9I32083ECK3F2T29D3ECN351C3ECP35YU3ECR352A3EBE36L73F5Q3CH73CGM3ECX3F5U3ECZ3DH63F5Y3CK83EBQ3F613ED63DAE3ED9351C3DHK351C34D03EDE352A3EDG3EBP3EDI3DG83EDL39HJ3DM23F1E39AG39KQ3EDV3DI23EDT3EF63F7Z3CJB39713EDY3CK93DHC3EE233GT3EE43EAH3CKI3EEQ3DIK2KZ3DIM3EEC32B83EEE3DIQ3EFA3DIS3DH53EDU3CKZ33U03CL23F8137VO3CL6352A3EES3F8O3DWW3EEV3DLW3EFR33L93EFT34IO39AX3EH83DLV3DK03F3V3EF73DJL31803DJN36AA3EET3DJR33IX35573DKF27D3DKH3COQ34V33EFJ3DLE27A3EFL338Q3CMB3DK63EH438QM3F9437O53DCR3F973EFY3DJV3EH13DLM338Q3CMT33EI3DKM3EHY33HG3DKP33IG39XA3CN533XZ3EGE33EI3EGG3CNC3C8Z3DN33EGK39RR3DL439Y63DL735TJ3DL93EGT34TO3F7V3E9R3EGX3FA43DLJ2BQ3CO13DKI3F9V3EEW3F9X3EH63DBN3COC3F983F9K33BP3EHC36GF3COK3DM33CNV3DM63EHI3DK63DMA3F9Q39P23EEB3EHO33HG3DMH36BI3EHR3CM92F63DMN3EG33CGM3EHZ34Z43CPD34GP3DMU35233EI539LE3DMY3CPM3EIA3DMA3E8P3DN43BAZ34M83DN73EII34Q73EIK35S13DNL1G3DNE3CQX3EIQ3DNZ37RC36LU3EJC3FCK39E83CR731J431033DNP33IW3CQK3DO7123DNT3EJ534MP3CRW3FCO32403CQV2L63FCV31PN2AG3FDB3FCU3EJF3F01325G3DNX32403DOA3DOC3DLQ3DOR3CZQ3EK13CSS3DOX3EJS3FAM3D8A28I3EKM3CRS3F3S3CLH31ZL3CRJ3CRX3EIB3EGH3DOY34PO3DP035963DP232XF3EK939XY3BPS3DP73EKJ3EKE27E3EKG3FEI3EKI3EK73CSL3E9B123DPI33XZ3DPL369P34KW3BIA3DPP32WO3EKT2KA3EKV35XN2KZ3BPU3DPW3EUP3EL0370C38U13C5W3EWM3DS63EPZ3DQ73CTF3AH03EPZ3ELD3DQC35MC3ELH37XW3EPZ3ELK3EOA3ELO3BQU3ELQ3CTX3ELT3CU03DQV3DQX3CU527H3FFM3EM13CUA3ENZ3EME3DR63D2Z34CC3EM83BRQ38S73BRT3EMC3DRE3EME3ETI3EMG3DRI3EMF3EMJ3BS73AIG3FFG3EMO3CV137IR3DRS3BSH3DRV3EMV32MS3FGL3EMY3B9S3EN03BSV32LK3EPZ3EN43CVL2363DSC3BT63DSF3DSM27Z3D5M3EPZ3ENE3D513ENG3ENI3BTL3ENL3ENN33OT3ENP3DSW39Z039TQ3ENS3ENU3CWD3BU33CWG3DT633K63EO233UY25E3FGU3EO732GS3ESV3D153EOB3CWV3EY03EOH3CX03BUW3EOM32P43EPZ3EOP3EOR3CX936ZR3EOU3DZS3D1L32LV3EPZ3EP03BVI3EP23CXL3DU83EP63AE832Q732HJ32Q931MI3BVW32FG3C093DUK3CXZ3DUN36MQ3DUP3EPH3BWB3BWD3CZQ3DW43CYB3DW73BWN3CYF3DV23EPU3DV424B3EPX395Z22A3FIT3EYT3C8F386I3BF33A6M3CT53DVP37ID3CZE38AE3D053EYK3B1F3EQN3CZL3EY53CFO334U3EQS3EPN3CYC3DW83EQW34K13DWB3ER03BZ638BI357Q3E8T27A3DWR3DWS31PN3DWU3D0C3ESC35TG3DWZ31PN3DX135PM3CQL3DX43C883EH739463ESM3D0T3C5R2853ESQ2AH3DXF3EST3C0A3CWR3ELM3C0E36W23DXM3C0J3D1B3ET23D1D3DXR3ET53D1I3ET73D1K3CXE3ETC3DXZ3D1Q3EMI3D2C3DY434243D1W3DY734CI3D1Z3ETO33JY3C1H27J3D253FH837Y13FIT3DYH3ETW3C1S3DYK3ETZ32H93EU13DYP3EUB3C2I3D2N3DYU3C2C3DYX3EUA3EU33EUC3FMC3DZ33D3038D83D323EUJ3DZ93EUL3EUN3DZE3EUP36S13D423DZI3D3G3EUV3DZO32C23DZQ3D3P3EV03D3S3EV33D3U3D3W32LY3FIT31HD36S23E023EVO3EVC3E073EVF32GD3EVH3D4I3E0D3E0F37SA34AG3E0B3EVP3E0M32WI3EVS3E0R3D4Q3E0U22Z3E0W3EVW3E103C8933VF3FIT3EW13FHC3EW33E183D553CY23D0W3EW93FHE3EWC3D0T3EWE3FKX123EWH3C5U3AU43FF93DQ43DS63FIT3BDR32L43BDT23A3AKT3A4Q39QV3B9M3B3W343F3EWY3C7U3CTT3EY93D723AD838ZQ3FJV3EZ13EYM3E3R3EZ437EE3EXW3AU43EX13BZ8388E3A833CZI3E463D7Y3EZ33EYO32Y53EXH390F3EXJ3AXK3DWJ340539CP3AOE3EXO3DWO3FP533WP3EXS3D6A3EYN3E493FPM3EYQ3E3636WO3AVA3BX9380Q3A563ER7341Z3BXG3ERA3AVL3ERC3BXL36XA3C5J3AVR3BXP3ERJ3BXR3ERL3BXT3AVY36XO349L3AW236XT37173ERT36XX36X03AW83ERX3ERZ37MJ3ES1368R3ES336YE3E2X3D6T3FPZ3E3Q3EXD3EK63CFO3FPB3EX03EXY32TQ3CYO3BIS39FX3CYR370Y3CYT39G2376I3CYW39MA3CYY380T3CZ03BOG3BGG3CZ338103BJ939GH39MN36943BJE3EZ03FPY3EZ23EXU3EXF3D823E4B3EZ735KW3CZL3DWV3E7V27E3EZD337036G63ESD3D8F38CR3EZK3D8J39ZP36463E4V3FSM3DF835L03C9L31WF3EZT36KE3D8W37ZS3EZW33PG37GH3EZZ3CGT3CBJ3E5C27D3F043DPE3F1J3DAS39463D9D3E5L3DX03E5N351C3E5P28R3F0G2KS3E5T3F0J3CAO123F0M34LR3CAT3E603D9U3A6P3CAY352W3F0V3DA03CB439KF3F103F8434QF3F133DHG3E6H3F163F7H3F1932293DAJ3E6Q3F7W3F2S3CA927C3DAQ38CF3DC43F1L3FUH3F1N3E7133RG3E7328M3E75337I3E773F1Y3CCD37KU3DB63DB33F203DBA3F273F242IU3F263FUS3DBG3E7L3CCS37OX3E7P3CCX27C3F2E3E7T3DBS3F2J33FA3F2L37573F2N35SU3F2Q3ACU3FUG3E6X334S3E8735HR3E8934QQ3DCB3CDO3F313E8E3EFN3E8H3E9I3ACT3DCM356J3E8N3CE133HG3DCS34U43E8S39KY3F3H3E4H2QJ3CEB3E8Z3F3V3E913E6T3F3P3DDE3DD93E9639LA33EG3EGL39EG3F3X34NF3E9D2BQ3F403CF03DDO3AK33E9K35F13F4733UZ3DDV3E9Q3E9S3EC529D3E9V3CKE3F8T3F4G3DE334JX3DE53EA42BQ3F4M3CZJ3BOT3CFT37QI3EAC33VE3EAE3BN73F4T3BJM39113CG33EAK3DEM3APZ38O93DEP3CGJ3ATV3EAR3F703AHR3CJL3DEW3BN937KW3F593CGN3CG63CGP3F5E38GK3F5G3CGU38GQ3F5J3EB935RA3EBB3F5O3CIS3ECU3DFJ3F773F5T33L93F5V33UT3DFP374J3EBO3DHR3ED43F8P3EBU3DFY3EBW34VH3EBY36JG3CL73EC13FST3EEU3DGJ3E9T3AJ03EC7352031RT3CI63ECB3EBF3ECD3F6O3DGJ3F6R351C3F6T3D9I3ECL3D9I3F6X354Z3F6Z33TC35G03ECS3FYP3F75399V3DH13CHA3DFN35TR351Q3DH73FYZ3E5V3FZ13F82354J3ED73DHH3EDA32C13DHI3EDD39DA3EDF3EAH3CJO3DIE3DHU31RT3DHW39HK3DHY39DV3FTZ3DI13EF43F833G0D3DI63EDX3F7I3EDZ3F883DIE3F8B3CIS3F8D374O3CKK37QN3EEA3COW3DIN3EED3DIP3CKT3F8Y2YT3F5W3F8P351Q3EEM3F8S3EE62BB3DJ233IQ3F8W3EAH3CLA3FB43F913EH534JK3EF035233EF23F993G1K3FBM3F9C38W93EF93DJP27D3F9H33G93F9J3EHA3DKG3FBD34QK3F9P35UL3F9S3CMA27D3CMC3F903CLZ3DLP3DJB3G203DKB3FA1372D3EFZ37AH3F9N37DV3FA735GI3EG535GI3DKO3EG83DKR36FC3DKT3FAG33SQ3FAJ39OY3CND3EGJ3FWJ37533EGN3DPH3FAR35DI3FAT39XL386C3EGU3FBF27A3COM33J43DLH3FB33DLW27E3FB23G2Z3EH33FB53CG63F9Y3COA3G2V38IH3COF3G2H35OI3EGV3COL350J3FBI3G3V3COR3CJV3DMC3FBO35TR3DMG3EHQ35UO3DK33EHV3DMO3FA83DMQ3CPB3EI034JK3FC338GK3FC53DMX3DOB3DMZ3CPP3EIC3FCC3EFT37DJ34CV3DN83EIJ3DNA36GV3FCK3FCM38FQ3DNH3FCQ3FDE3DNK34BI2LP3G5G3FCX39EE3FD039802943FD333I23EJ63FD63G553FBN3G5F3EJC3G5G3G5J3FDG394K3EJJ3EJ731ZL3FDL38QS3CRT3EJZ32403FE23DOU3FDR3EK3332G3EJT3CRO3EKL3DPG352I3FDZ3CMI3FE13EK13DOW3EK33CS23FDU3FE93A2U3CS939P13CSA3FEG39EI3G6R3CSF3D693EKH3F1I3G6R3FEN3EKN39SL27D3FES344I3FEU3CST3BM33FEX3BCA3FXI27E3FF03B5I3FF229M3CT13EKZ3CT43FF739JA32IZ3EL432NJ3FIT3FFD3ELA32JK3FIT3FFH3ELF3FFJ3DQF36GA3FM13CTP3ESW3DQL35133ELP3BT53DQQ3DSA3ELU3EL93FFW32LK3G843CU83EM23FHS3BFT3EM53DR73EM722R3DRA3EMA3FGA3CUM31ZL3CUS3CUQ3FGD3CUT3BS53EMK3D5M3G7Y3FGM31RT3BSL3EMS37ID3FGR3D0T32JG3G923FGV3CVD38RS3CVF3DS53E123FIT3FH13DSB3EN73DSD3EN93EW23FLZ32NB3FIT3FHB3DSG3FGI3FHE3DSQ32HY3FHH32XY3FHJ3BTT3DTI3FHN3CWC3DT23FHQ2303EM333CH3FHU3AE83G9B3FHY3G9637SR3EOA3DTH3FHL38WY3AAV3DTK39F2342Z3FJE3EOK383L3FI8356A3AP93BTQ3DTU3CX83BV627D3BV83EOV3DTZ3ETA37BF37Y132QC31CD3BVF3DU43DU63CXM3FIP32KL32QL3BA23GB53EPB3FIW3CXX3FIY3EPE3E843FJ13BW73DUQ3FJ43DUU3FJ63DUW3DW53FK43FJA3EPR33XO3EPT3EPV3DV53B9B3GB53D5V3FJQ35GX3FJS32IX3EX338JS3EX532UC3AQQ390P3FS43B5U3A2J3EQO3D803FQ23FK13GBR3EPM3GBT3FJ93DW93FK73EQY3D003DWD3FKA3EQ033OT3B9F3AFO22Z3AFQ3B9K3BDX3AFU3FQI33BM3AFX384I3A1C3AG133J53FKF3D093FKH3ESA3FXV3FKK31J43FKM3ESF3D0I3ESH3E7Z3ESJ3DX73FKV3DXB3ESP3DXD3FL03ESS3C0S3FI03DXK3ESY3C0I3DXO3D1C37SJ3FLD3C0R3FLF27A39243ET939CH3ETB27D3ETD32NB3ETF3C123FGH3FLN3C173FLP3DY63ETN3D213FLV3D233FLX3ETR3DS63GB53FM23D2C3ETX3FM53C1V3EU03GCR2333DYQ3EU43FMJ3EU737IA3EU937MF3FMA3D2W3EU63FG53C323C2P3EUH38DN3FMO3C2U3FMQ3D393FMS27A3D3C3FMV3EUS3DZJ3C5T3FMY2T83D3M3D3O3BS33FN33DZU343L3EV43FN735133GB53FNA3C3U3FNI3E042953E063D473BQ03C473EVG3FNO3FNK3EVL3FNN3EVO3E0K3D4K3FNQ3D4N3C4S3FNT3EVU3FIM3D4T36703FNZ372Y22Q3GB53FO33G9T3E373DY13E193D563EW83C5I3EWA3E1E3EMQ3C5O3DS03FOF3FOH3E1L3G7R38RG32NJ3GB53FPP3AOA3FPR3EXM3FPU3AXP3DWO3E1S3FPC3FRG3FUO34373C623EYD3C643EYF32UA28T37C93EYI37CC3FPH3EXR3FS63FQ13EXV3EWZ3C783FP13C8C3BEZ3C8E3BF13C8H343Q3C8J3GI13EYL3FPJ3FS73EY63EXG3FQ43E3W3BPA32XS33EA3BPD3FPX32Y13FR93EXC33GW3FJZ3G7G3E3G3EXX3E3I3D5U3BCS34463GIG3EY23FP73FRB3FP933SJ3FRE3GI73EYR38U63FRI36823FRK3BO53FRM36893BO83CYV39M9380R39MC39G83BJ4380X39MH3BOJ376X381239MM38153FS23CZA3GCE33R43GJ73GIW3FRC3GIY3E4A2AH3FSB35EG3FSD3E4G34DC3E4I3ACU3EZF3DWW3D8E3C983EZJ2KK3E4R39V83FSY3FSR3DF13D8P32YR3D8R3FSW35EV3EZU3EC237A834SQ3E583EB33FT53D943F6C123FT934HO3F063D9I3F0827C3FTF3FKN3FTH3F0D38563FTH3F0H33SV3FTO34BI3E5X3FTS38E731N33CAW3F0S36FF348V3FTZ3E673FU13E6A3FU33DHF3FU53DA93E6G3F153E6J3FU733X43DAG3FUC3B7J3DAK3D1W3CBR3G733FUN3FUJ35L13F1K37G03FUN3F1O3D8C3F1Q3FV73DB028N3F1U3GMN3DB43FUY3E7F3G612IU3FV23GMR3FV428N3FV63E7J3F283FVA3E7O35793FVD351R3DBP3GML3F2H3D7834LV3CD63FVK33R73FVM36ZJ3FVO34IC3GMD3FVR35873CIV34R73FVV3DCA33GA326G3DCD33GA3F3229S3F3427D3F3632ZN3F3835UL3CDZ352J3E8R3FWA34RN3F3F33TZ32Y43F3I3CEQ3F3K3FWI3E993DD43FWL3CEJ3F3V3FWO3CEN3FWQ32ZN3FWS36ZP3FEO3DDI3EGQ3FWY3DE23FW33F4435P83F4633EM3F483FX6331A3FX83DGJ3FXB3DE03E9Y3GOV3EA13FXH3F4K334K3BOS39JS3F4P37CL3FXP330W3FXR36RS3FXT3BKH3FXV3F4W3A9X37XK3B483F7429D3F503D0J3CF63F533ECQ3FY634HX3FY83BNV3FYA3DG83F5B34SS3F5D39KL3F5F3GL23FZB3EB736ZJ3CGU3F5M3F6D3DGW3F5P3CH63G03396Z3G053ECY3CIZ3F5X3CHF3ED23EDH3F9A3E5V3F623CHN3F643DG03FZ733363FZ93EAH39VK3GQH3CGM3CI2355Q34PT3EC938GK3FZK3GPT3F6N3F6P29D3FZP354Z3FZR351C3FZT351C3FZV3CIM36KM34Q73FZZ3F723GQJ3EBG3F5S3GQN3F793GQP37413FYY3GQS3F7Q3GQU354J3GQW3FU43GM23B8M3GM43G0J3F7M3G0L3F7O3G0N3FOY35353G0Q3CJS3EDM35RP32F23EDP3DI03G0Z3G253CK33G1Q3GS639AA3BB23G143GQT3GHQ35353G173EEO3DII36A43F8F3CKM3G4I350D3DIO35233F8L3G2A3GS33CKX3EET3G1O3EB93DJ13EEQ3DJ43G1V3DJ73G1X3G2Q3F9234QP3G2T397F3FB93B8M3CLN3F9B3G4G38YY3G293F9G3EFC352N3G413F9M3DM83DJY3GTV338J3DMK3F9T3G2N3GTL3FBB3G423FB73CMK3DKD3FBA3G2F3F9L3G2H3EG23DKL3EG43DKN27D3FAC3EG932RU3G39353P3FAH3FAP3CNB3G3D3FAL3FE83EGL33XW3G3I39PA3G3K3CNM3EGS3G3N3GV63G493G3Q3FAX3EHG3G3U3COQ3DJU3G3X3GUJ3G2P3GUB3DK93GTP3FKT3GTR3G2W3EHB3FAZ352I3DLD35UL3G3S325G3G4D3G3Z2B43FBL35UL3DMD34QM3F8I35E93CP13G4M3EFM3G4O3FBX3GUN38QM3FC134K62ZU3EIH3G4W3DMW2QI3FC733PG3FC93G523EIE3DN631ZL3CPX3FSG3GW635GI3FCJ3DND2YI3FCN3G5U3FD92FR3G5G2AG3FCT2N43G5K123FCY2YI3G5N39LE3G5P39KY3CQP3FD53G5D3FCP31J43GX03G5X3G5I3FCR3D063DO63G5O3G633FDK3G623FDM3EJY3DOF3G6M3EJP3G6C34BA3DL13GKE34QR3G6I3FDN3G683FDP3EJP3G6O2QJ3G6Q3FE83CS53G6T3DP539SA3G6W3EK73EKD3CDK3DMC3G713FEK3GMD3EKK34ZR3FDX3G3J3EKO3G7835SM3G7B3DPO3CF634B93BP43GIK37Y43AKD3DSZ3ENT3GA43BU235HV37MS22W37EY235349C2823AFM342B22933EB29H35HV21V2992313BWF23022X2253FLY32VH3AVI34E32F83BR23FG23FHT3CWK2YT38FF22T3C4U22V3GZS27Z391G399B34133BUC3EO82T132V322U34AF23533N739QE3D4J2A332TU32V127L33MH33HG27K3H0L3A232KS32J23C3V2KZ3H0C3H0E32J632IJ3BVP32EJ34A227T28G38ML31CD21Y29723633M032EP22832EP33M438P536W232WI38RY345X37MI338X38DK2A52BB32H83E1K29D368Y29L325Y27223L25X24531LU39FI3FL339LU3BJX3BEM3BJZ3BFR3B813CZD3DVR3EQI3BK63GB53DVA37T23ASZ382R3BXD3C7D3DVH3AVG3AT737MZ38W032UO38W237TL3DVN3GD931I23CFR3BMY3FXN38ID33QG33XZ3H2Y3AXY32UZ3BD3331X340S3FSL38IW350F344C35JH27935OS353P35OV3B0G1Y3FES3BE93H34332R38FQ3H37359B340S33FG35PP38EO36EB34JK38OJ35BV36AG38H5344I37GT26U2IU39HT333I39HY36ZJ3CHL35SU34NH36G833XZ33FV33GT3CAI3GSO315I39HH31RT313G34V33H4D35UL35GO3CJY38J13F0P27A33RY33G933GC2KY335934Q3319V2B431BV32B8397L2A035IB33IW3D9A3CMJ35VN2842943COG39EO330W3H5A3CKP2KS34QD34GT3DM53D8T328C35RY29434TD3G4Y34BX38J73D9Z33QE27W33Z334H73H5U3F793CAS33H9326G35JX3FVX326G3CKA3GNS3DHM319V33V938GJ32Y836243FYW2KS35HV357W351Q37BX38BD35QA2FD35WE36EB35TM36EB330W2YH35VH35KY35P8337H3CF63CL03BLC34XQ38H83CWA3GZ33ENV32IX3GZ622O3GZ832IO3GZA32FZ3GZD378O3GZG36FF3GZJ2B63GZM3GZO3GZQ2353H043CZB3A1J34283BU63EO13GZY2T13H003H023H7K3H063H0932GS3H0B32TI3H0E3H0G3CT53GGI3H0J29Q3BVP3H0N32B83H0P3H863BU22A03H0T28Q326G3H0W32UH3H0Y38SM23A3H1122U3H1338PJ33B035H03H183H1A3BZ23H1D38KO3BRR3H1H38MT3H1J32EP3H1L3BWO31RT3H1P3D5H3H1R28W37I13H1V3H1X3H1Z39J932H93BH93B903B6J3BHC2KZ3BX43CZF39JI3GB53B6Y39NC39TT3A9I39TV32UI3A9L37FS3AEY3H2U3BLT3BPH3H2X34R03H303H3F34NO39113H3J330N3H3L38GG3HA535JJ2843H3B34R03H3E38Z53H3H369Y3HA9333A3HAI3D8O3FSE3H3P32ZS3H3R3GKC3DEH3GKY362C32WM3H3X378133I23H4035D838FQ333I3H4233EM3H4436C3369X39RL33FU33SQ27W31HD3G0X3BJG3H4G2BB3CAG37DV3HBB3FBM35G73H4N39AB33I427D3H4R377H3H4U364C381A2B431Y63H5033IU2A03CIN3G6K3EJ837413H58123H5D33X8332I3H5D35JN3HBY3GKS35GI36AW34NP36AZ33J435VN3G4Y35HV3H5Q39DW3H5S3GX634R03H5W3FYU3FTS3H5Z3H663H623E6R359B351Q3H5N35CU34TD326G3H6A365P3A383CIK357327D35K13H6I39RT35QN3H6M33VE3H6O332I3H6Q369P3H6H3H6T3ADY35KY3H6X32WN37HP3GA33H7236FF3GZ73GZ93GZB3C0J2303GZE3H7C3GZI3GZK3H7G3GZP32VJ3H7J2993GZT325Y3GZV3H7O3DT83GZZ3D4K3H7T3HE53H053BUP36VL3CWP3H0A36DF3H7Z32UH3H8127U3H8332V63H0K3H8A32IX3H883H853H0M3H8B35MC37MI3H8E3HEK3H0D3H8H3C0F3H0Z27L3H8L3H8N3H1531HD3H173E0Z3H8S3H1C3BHM3H8V3H1G2A43H1I3DQD3H1K29D2B63H923H1O3GHA3H963H1T27D3H993H1Y395M3H9D3B7U378D3BJY3H9G3BK13H9I3GC6390G26A3GB53AHX3H9W3FXM3BNN37QI3H2Y353P3HA138Z53HA33H3I3FSE3H363HA83FSE3C9K332M3H3C36AE3AJV3H3G3H333HGJ3HA737A23HAK3HAN32ZU3DM03HAQ3BC33HAS2IU38CY389J3H3Y3HAX3H413HB03HB33HHA38LZ3HHC39L736B739OA35S73HB93CAD3H4E3CJR3CID34QK3H4K34OZ3H4M3EDQ3HBM2BB34PA3HBP379U3HBR3HCA3CA93H4Y397C3HBX3GRZ3H543GWO32403H5733IU3HC533VE3HC834TG3H523HCB3H5I39KC3HCF325G3H5N3GWI3E6936AG3HBL3A3K3H5T3HCO34T0335333FA3HCS3F7W3HCU35D53F2Z2KZ34D031583H6833YW3HD235EP3A383H6E3HD63DID37V43H6J35P02EZ3HDC38R235EV3HDG344I3H6S3AR73H6V3FEY38C23B3C3HDP3FHP3H743H76341D3HDU3H7A3GZF36XC3H7D3HE032J83H7H3HE33H7U3HE73H7N3EO03HEA3H7R3HEC27T3H7U3HEG37WG3HEI3H7X3HF13H8033MN3HEO3AI93H843H0Q3H873FFJ3HKN3HEX2AD3HEZ3H0V3HEL32GS3HF43H8J3HF732GW3HF93H8Q3HFC37MI3HFE3H1E3CUJ3H8X38PQ3H8Z375V3HFM3H1M3H933HFQ32SV3H973H1U3H1W3HFV3H203BIG3HG03BCI3B943H273EQG3H9K3BDO32I4351D3FGO32WZ3E1Y38X537Q23E223EVM3E243AVN3E2637QA3H9V3DE83B9V39XT3HGD33VE3HGF38G13HGH3HAH3HGU3H383HGL37CI3HGN2EZ3HGP330W3HAE38G13HAG33233HAK3HGK3HGW3HAM3D8934F83COI3HH137CI3D8Y33JI3B393HH733R83HAY393X35SU3HB433EM3H4636ZJ3H4836QT330W3H4B335R3H4K33PF3H4F36R62BB3H4I37DV3HHP32F23HHR3DI03HNM3DGO3H4Q33IX3H4T325G3HHZ3H4X3A6P3HBW3HNZ3HI43G6735O43H5635JH3H5939843HIB365P3H4V2F33HIF3EIB3HIH3H5L32C13H5O38OM3HHS3HIP3HCN3H5V3HIS3HCR355I3H613H653HIY3HCW3HJ0381A3HJ32KZ3HJ53EBL3HO03H6F2KZ3H6H33XW3HJC35UZ2793HJF332I3HDE36ZW35SM3HJK3ANK3HJM3G7F3GPC3H6Y3AP83H703FHO3GA53HJS3HDT3H7932J83HDX3HJY3HDZ3H7F3HK13HE2382F3HE432JB3H053HK53GZW3GA93H7Q3AYT3HKA3H033HEE3GGY37SR37BJ3HEH36PO3HKG3ETU3HF232GM3HEN3H0I3HEQ3HEV3H0R3HEU3HKQ3H2A3HKS32EP3HF03HQJ3H0X3HKX3H1032VC3HF83CT73H163H8R3HL43H8U3H1F3GCW3HFI3H8Y3HFK3H903HLC3HFO27D3H943EWI3HLG3HFS27A3HFU3H9B33OT37PA3HLM3H243HG13HLP27M3H283EQH390G1I3HLU3HG83HM83BGT3AIR3HMB330W3HMD36QR3HMF3HMS3HMH3H3N3HMJ3H3935G43HAC34H73HMP36QR3HMR33133HSA3HAK331W3HMW3FWF35UB3CRS3EZB3CG12F53HN23H3W38BE3HN5312E3HN73HB233B93HHE3EF63H473HSQ39ZO3HB835093HHK351K3HNL352M37493CM43HNQ33QQ3G0V3H4O3FTU3HBO3HNX333F3HHY3H4W31583HI1389H3H513HO53HC03DNY3HI73HO93HC43HOB3H5C3HOD3H5F3HOG3HCD35PJ3HOJ3HIK33893HOM3H5R33HS3HCP33VE3HCP355G3H5Y3HOT3E8B2KZ3H64355I3HJ135CU34D03HD127E3H6B2A63HP43HJ93GSX3HD939ZU3HJE3DLA3HPE375F3HPG37YN3H6U3AYC3H6W3BNB3FUZ3G7J3HJQ3HPQ27D3HDS3H773HJV3HPU3H7B3HPW32U63HK03GZN3HQ032IQ3HK432U63HK63DT73HQ837IR3HQA3HKC3DTL3H0732ZF3HKF3G9M3HQX3HEM3HKJ3HQN2323HER3HEW3HET3HKP3HES3H0S3HKT3H8F3HKV3EV13FHI3HKY3HR13HL03HR33HFA3HR53H1B3HR73HL73HRA3HL93HRC3HLB36703HRF27A3HRH3FOI3H1S3H983HLJ3HRN32XY3HRP3H9E3BBJ3HG23HRV3HLS395Z1Y3HLU3GIO33E933EB3HM73EA73BAV3H9X3H2W34B93HS4332I3HS633GC3HS83HSK37CI3HMU342W3HAK3HML3HSF35OB3AR03HGS377J3HMT3HGV3HXV3HSO3GKD342O3HH03HSS3HAR3HNR36JX3HN436CA3H3Z3HH9350F3H433HT33DHD3HT53HB63HT73HHI3HT93HNJ31RT3HTC35G63DK63HTG3GLL39KP3G0W3HNU38DT3HTL3H4S3HTN3HO43DGS3HBT3HO239AS3HIE3D063H5531ZL3HI8325G3HIA3HU135I23HZA34KU3HIG35EV3HII3H5M3CPJ3HIM3HCK3FTZ3HCM3HUD330W3HUF33VN3HIU3HUI3HIZ3H633HUJ326G3HUN29S3HUP374I3HUS3HJ733J03H6G37533HP936BU35S93H6N3HJH3HV3381R3HV536ZJ3HV73BPQ35L03GZ134HC3DT03FHP38K823222S3H9J32W927M3B063HLU3A4M3BMB3BDW3BME343F3BMG343J3FN53BMK3AKU3A50343V3BMQ3FQA3H2H37T93BF63EQM3F4O3BCX37QI3BKF3AOQ3HYB32FT3AUQ3BJP39153FEV3CF639VV3FPL38WR39PL3A643GZ23HPP3BU23I0T3I0V3CZE3I0X390G21U3HLU3B8A37WT37WV3ARY3BKA3F4N3BPG3HXL38ZW3BB03HGR3HH232Y53I1Q39S539043B6938WO3BNB3I1X3DS63HPO3GZ436QD38HW3I0U3I0W3CTK39YJ3HLU3H9N3A9G37FL37FN3A9K3AHC3B753I2E3FXL3GPF3I1K38ID3I1M3H313I2L3I1P3B663BKK37W63EKR3I2R3I0N3EE73AGT3HVB3I223I2Y3I2432H03I263AH33HLU3H2D3DVC37T43H2G37JG3E3Y38NC382C38NF38NH38VY37TH3H2O3ATB37N53GD9390S3BF73CFS3HGB3I3F3BI23I1N3I3I3ADT3B4E3I3L3BI63GYV3AYC3I1V3FQ23I2T375A3I3S3I2X36MQ32J33I3V2873I3X3AAS3HLU3ER33AVB3BXA3AVD3A823I443BXE3FQC3ER93AVJ3ERB36X7343N36X93ERF3ERH36XG3FQN36XK3FQP3ERN3BXW3FQT3BY03FQV3AW63FQY3BY43FR03BY83ES03AWF37C93BYE3ES53I1H3B4Z3I2G3I4J38UU3I4L3I3H3BD33AGK3AY83I4Q35U23BP239183EQQ3I2T378A3I4Y2YT32HD3I2Z3I253I313AO53HLU334136RZ3I663FJW3I1J3BKE3I6B3H3F3I4N3AY73I4P3BC738WL3I3N33393HDM38JN3D4W3I1Y3H7W3CUN3I203I2W3HDR3H753HPS3GZC3HVH3HJX398R29D370J3BQD3HLU2A032FD32FF3FID32S03HLU3HQ53HEB3H013HKB3HQC390G24I3I7S3EPS348T32WM3CNU3HXI35G335EY37NB3F5434X627933UO353P3I8I2IX33JN34MH2IU35FC35TM35FC3GUM34FB361R3DG73FSR36NO34X336MO33XZ34L736MS34LH3COX34V738GJ34QE34L734QH34BM332U3EHA2BB35T83FBT35JN379U3EG633HG35T82943DBT3GTO3GY438EM385G34RN32403I9734UA332I34L733YS28N34ZA332S36O236AK381P351228N3I8R33VE35FC36Z637843D8N335T34KA35RA34H735FC3APV38LW38QB2F837RP3A0F3FKS3EEJ3BLE3HQH3I7F3I0Q3H713HJR3HVD3I7J3HVF3HPT3HDW3HVI3I7O3AYT33JY3D5M3I863B1Y3I7V32H32563I7Y3HVQ36423HK93I813HQB3HQ33GAJ3BWY35WV3I6U3GJ33I8938AG336V3I8D33U03I8F39U93I8I39BC2F23I8L32Y63I8N2793I8P3IA72F232Z234C23F683GQH33203G0H32Y83I8Y37WA33VE3I9136JR38L63I943FWB3C9K34U83I983ICC388O39KX34I334TW3B8M338N3D6V34T733U03I9L34YT3G4331ZL33FI3I9Q33HG3I9S3ICJ3I9U38E2335E3I9Y39Y837FU32YC36N23AIS36AL35CD31173IA534R03IA837K533HG38LF335K3IAD3I753CF733SQ33VW38OK38IR325Y37H93IAM3CZO3DFX34LR367Q3I7E3I2V3HDQ3HPR3IAX3I7L3IAZ3I7N39BW37IR3IB332NN3IB53APA3IB72BQ2623IBA3H7M3IBC3HQ93IBE3H7U392E3IEI3C8U2AW3IBM3AAY3IBO3HAT3IBQ37FZ3I8H34R03I8K35O13I8N3IDG35K63I8R3IC3336436JG3I8V3EDC334U3ICA37D2330W3ICD365Q38L93GW23FBP34P436LT3ICK3IFE3ICM31RT3I9E3EB9338N33Q034RN3I9K35UO3F933GUD33693ID032B83ID2338Q3IFM3I9V2F239Y23I9Z332I392Z36K13IA23A5G3IDE3I8O3IDH365P360T393T37ZS3IAC37XA3IAF3IDQ34V43IAJ325Y3IAL3FPL3I7B36763IAP3DTC3EO83I6N3IE43HJU3IAY3HPV3IB13IEA32UF3AE83IED3I7U32FG32H326Y3IEP3HE83IBD3HED3IBG39CG32RH3HLV33Y03AKQ3FOQ3FOS39QU3B3T3BY53AKZ3B3X3IES3BHY3IEU37HH35YT39NT38S634H73IF03I8M34IS3IF33GV73IF536ZJ3GIT3FYC35G03I8W3A8K3IFC3BC634C336OT3IFH34V534PT3ICT365S3IG43ID53G2Q3I9D3G4L3F7I3IFS3GWA35UM34LW385B3ICX39LG387E3FWB3IG22B43IIN3I9A34YO3ID73A0I3GU03IDA2AP3IGC3A8B3IGE3II5353P3IDI37NQ3IGJ361J3IGL3IAE33XZ3IAG3A8E3IAI38TJ3IGR3A0E3IGT38BH3IGW3GAD3IE23IAU27A3HVE3IH13IE63IH33IE938273IEB337I3IHJ3I7T345P32QP3IHJ3I7Z3IHF3I823IHH3BNE3IHJ3I1134383I1336833I153A553A4T3I183IKM343S3BMN3I1C3FOV3BXC3I5C38NF3IHU3I8B3IHW369F3IHY39ZC3II033XZ3II23IBX3II43IDP3IF43IC23II8372G3IF93FZL33393IIE3BFG3IJ53I923GT53IIK33HG36RD3ID334PO3IFN3I9B338Q3IIQ3GW53IIS37G43IFU3ICU3IFW3I9N3GXU3IIZ38B33IJ13IFL3ID43IJ53I9X3E9I3IA03IJA27C3IJC3AC934X63IJF3IC135EP3IGI3IAB355P3IJM3IJG3IGO3IJQ38G53EEJ38BD3IDW38M239IQ3HQG3IGX36PW3I7G3IE33IAV3HJT3H783IK33IB03IK53I7Q3DRX3IK93AI93IEF32QV3IKD3IBB3I803IHG3GZT38FK3IHJ3GJF370U3GJH380I376E39G139M73BOA380Q3BGB3FRT39ME3FRV3CZ2380Z39GE3BOL3CZ73FS13BJD3CZA3IL03A863IL237JO3IBR34IU3IBT394S2BM3IBW32Y03IF23ILB3II63ILD3I8T3IF83DFE3CH83G0H3IFB3GR13IIF3IFF37GM34SR3IIJ34QA3IIL36JT3IJ43IIG3IIP38GN3ICP3BD23IIT3FAA32B83IFV3I9M3FCD3FE03IM538ED3IM73IIM3IM93IP33IMB3IG83IJ9364V3IMG3AHN33QE3IMJ330W3IJH3IMM3GKX34MV3IDN3ASD345G3IMR3IDS38J53IJS39VL3FPL389M2KA328S27L34AR3I213DT332IK32TF3C4J3H213DX839W131803H9F35MD325Y3BVY3EP439YJ3IHJ3E2K34E73A0Z3E2N3EQ53A133EQ73B9P3EQ93A193GD73E2W3B2R3APQ3HS23AXW3B5X3I723BD339U938C73B353I6C3H353BGX38GG3B8P2BB3HD13B6738EJ3I783HH53IQ63H6Z3IQ929A338Y3IQC2KZ3IQE32IJ3BPD32B8334237HR3IQK373M2F83IQO3BBQ3IBI37XW3IHJ3D663B4Y3I6Y3I683EAA3B523IR838Z53I733I8G3ATS3AUR3IR93IRF34U33H3M3IRI3H693IRL389E3IRN3HJN3FKD37HP3IRR3IQB3I7H326G3IRW3IQG33HG3IS037AP3IS23BDG3IS432IH3IS63BEV2363IS9345T3FP43B5S3I2F3I4I3ISE3BAY3AZH3I4M3IRA34IU3IRC3ISS3ISH3HXT3IRG37A23ISQ3HJ43ITR39R83I1T3AYC3IRO3FQ23IQ7372Z2T83BVP3ISZ3HDQ3IT132IR3IRX3IQH3IT5378D3IT73BEN3IT93IQP3AO53ITE2853E3L3C6X3A6P3I8B3BJI3ADG3AOP3IRE39113IRB3B5B3IUU3HA63ISO3IRH3BD53IRJ3ISL34ZK38EK39YC3IU23EQQ3IU437OY3IU63IQA3IRT3IT035MC3IUB3IT33IRZ3IQJ3HRR3IQM3DUO3IUJ3B11314S38413EQ13E2L38463EQ438493IQX3E2Q3AWH32W23E2T3EQB3CXC3A1D3ISB3B2S3BL13B1H3ISG38G13ISI3IUW3AK63IUY33OQ3HYB2A03ITW3HP13ITY3CRC3I2Q3HSW3I3P3IVA378A3ISY3IVE3IU93IVG3IQF3IRY3GJ33IS13IVL3E9O3FJ13IVO3IS738RN3INC3GAK3B0A3ITH3I3C3AM63IW83IUT3ISM3IUV3ITP3IUX3IXD3IUZ3HST3ITV3IV23ISR3ASE3IST3IU036ZJ3IV83FS839KY33EW3IWR23F3IRU3IUA3IWV3IUD3IVK3BFP3IUH3IQN3ITA3BHH3CXP24Y3IUL3C8U29M38DJ38DL3IR43GCF3IW73B5W3IXC3ITS377J3IWC3IV43IWA3ITT3IV03IXK3CXM3IRK3IXN3IV53ISU3HPK3IAN31ZL338W3IXV3IXX3IWU3IUC3IT43IY13BHA3IY33IVN3BK53BBR3INM3BIQ380E3FRJ3CYQ3GJI380J3GJK3CYU3FRP3GJN3INW39MD3BOF3BJ53GJT3CZ43GJV39ML37703BGN3GJZ3BOQ3IX83I4H3H2V3I693IMH3IYI3IYN3IYK3IXF3IWD3IXH3IWF3I2L3IWH3IXL3ITX3IYT3ITZ3G7C3BN93IXR3GYZ3IXT367W3IZ03IVF2AD3IVH3IWW357P3IZ53IQL3IX03CY23IY5390G25U3IHJ3EWP38YL3BHP38YO39PY3D6P38YT3EWX3IW53IR53IYG3ATH3B533BFD3IXE2EZ3ITQ3J0E3BB23ISN3IXJ342W3IWI3IYS3AA9369P3IV63ADY3J0I3CFO3IVA37B63J0M3IWT3J0O3IXZ3IZ43BBH3IUG3BJZ3IUI3IZ93IX339C23IHJ3D5V3J183IYF3I6Z3B0E3IW93J1I3J1E2793J1G3J1O3IWE3HAJ3J0A3GU73DU83J1N3ISK3IRM3IXP333I3J1S3GK63IYY3FF13J1W3FHP3IXY3IZ33IVJ3J213IWZ3J243IY6399B26Q3IHJ3D7G32UO3D7I32X43H2J3B2D3AYZ382I37J53D7P37J83B2K382P32UO3I433D7U3B2Q3J2A3B783J2C3IXB3IA33ITN3J053J1F3IXG3IYJ3H3K3IYP3J1L3J0C3IWJ3J1H3J1Q3BA83J2U3HPL3J2W3G7J3J2Y3GA53J303IVI3IWX3IT63J343IY4357B3J3632HJ32SG35NE3IUN3IYE3J3S3ISD3GPG3ITL3B443J1D3BE93IYL3AJ53J2K3IOQ37CI3J0B3IYR3IYM3IWL38H33J493IYX33JT32Y63J4D3ENW3IZ23J4G3J0R3J333IY23J23378M370A375S29D373J375V36W9378T3D2F36T232HN22Y23F37FM22P28Q38A01I3J4O3IKK3BMC3AKU3BMF3IKP3BMH3IKR34D93A4Q3I1B3A523GD23B3V3IKX3J3P3BMU386O3GPE3IXA38FW3J2I3J2Q3J08332339U9333O353P389D3J403IXI3IWG38NY35RL36JG3E5437OB38LF336938LT36JP35SM35D93IWM335T3HDM3J5B37WG3J5D3IQD3J0P3IY03J5I3IZ63J5K37AN3J5M38KO3J5O375U375W3BDG375Y33903J5V3J5X32HG3J603HXB3J4O3FOO3AKR3FOR3BDV3FOU3IHR3FOW3A6O38DO3I1I3J4T3I3E384T3J3Z3J043J2G36JU3J6U3HY03I2L3FSR3H3M38T53J7033363J72360Y3J7438CS34H73J6V39EO3J2S3FWP3IYW3IDX2YT3ISX2YJ3IVD3IXW3J0N2BC3J7H3J2039LV3J2236WC375P378N378P3J7P378R3J0T3J7T3B0122A3J5W3J5Y3J7Y3B1121E3J4O3EOF38C03HS13J1A39XT3J6O3AX03J2F3J4Y34IU3J6T35ZO3J8J3IYO3J1K35ZN3J8N372G3J8Q37A83J8S3FDW38R1385L35VH3J7938H33J7B3BNB3FUR34PB2BT3J7F3IRV3J983J323J9A3J343J5L375R3J7O36SR3J9H3J5S36T03J5U35133J9M3J7X3I273J4O38DN3J6L3BAX37QI3J9X3JA43J3X2793JA2330W3J8V3J9Z3J093J533J6Z3JA93EZV3D8N3J7538OS3J8I3JAG3I783JAJ3I3P3J7D3BIF3JAO3J4F3J0Q3IQI3J7J3J0T3J9D3J7N370C3J5P3J7R3BEN3J9J2KZ3J9L3J7W3J5Z390G22A3J4O3IQS36I63IVU38483EQ63IVY3IR03E2U3IW336IR3J9T3IUQ3DE93AIR3JBB3I2K3ITO2EZ3JBF3JAF3J3W3J413JA63D8O39003J8O3C9Q3JBN3IPW3JBP3JAE387J369P3JAH38JJ3JBU3FPL3JBW3BJV3IVC3IRS3J953J1X3J973J1Z3JAR3IWY3J5J3J9C3JAU378O373H3J9G3J5Q3IWZ3JCA3J7V3J9N39FR3J4O3C7C38VS3BLL37B93E413C7H379734CK3C7K384N3ITI3J003ITK3JBA3J8E3JBI3J6R3JA138CT3JCX3J1J3J6Y38Q93JD73FSZ372L3JBO3J8T3J773JBS3J8X3GOM3J8Z34C938ER3CY13FF83DQ23GHD32OV3J4O3BUP21B21T1U26H26833AT32B434D036SL23A32TU3DY723A3BWF37EO3ELX3BR932VN3C5A313G22E28F33Z822E32G936VU32J832GD2A532B838FD22U38A523F28032H323E3J9R3AO53J4O39Z237Y027E3CBR3JEG3HXK3J013HZ6372O3HGR390037283IGQ38G638IU3APV33YI36KF39Y5372V36EE39YO3CF637DC3CG536VB3EAM335K33V337K334H736JF34ZK38JI39YC37H93I3P3JF437WG3EWJ3GHC3CT93BQD3JFA3HVX113JFC3JFE3JFG1O3JFI37AN3JFL29V2993JFP3FFW3JFT3BS03JFV3JFX29M3JFZ32XO36W33JG333HG3JG63JG83JGA2BQ24A3JGD3B1124I3JIG3APL3EQK3JGI3JB83BLU38ID36ZF37AB3HY03JGQ3IQ23D8N38T33JGU3A8E3JGW331N3JGY39K735803JH13AYC3JH33AHR3JH53AK03JH733S43FVS353P3JHB2793JHD3ADY3JHF3FPL3JHH37XQ3JHJ3E1N3FFA1224Y3JHN3GAM3JHP3JFD3JFF3JFH3D1W3JFK3JFM3JHY28F3JI03G8Y31CR3JFW2343JFY3JG03JI83BW43JG538HX3JIC22P3IB83JIJ3BEV25E3J633GAY3J653I14343G3J683I173GFY3I5J3J6B3BMM343U3J6E3I1D3J6H3I452BQ3JGJ3IX93JB93JIP36V83JIS38LP3JGR3IJR3JGT38O43JGV399R3JJ03AHR36IX35NO372K333I3JJ63J2T3FXY3EDC3JJA3JH933XZ3JJE34UE38H33JJI3FQ23JJK3JAM3GHB3JJN3FOL3E123JJR3HQE346Z3JHQ3JJV3JHT3JJX32FZ3JJZ3JFO3JK13JFR22T3JI13EMG3JI33JK63JI53JK837093JI93JKB34A23JKD32H32623JKG3B4V26A3J4O3EYB37C13GHT3AKY3C6537C73GHX3B1C3GI03FUF3JGK3HGA3JEI3JL33JGO3I1N3JIT374F3JL833NX3A2O3AOR3JIZ32ZK3JJ1357V3JJ338GJ3JH23AY03JJ83B1N3JLN3F2U36JE35SM3JJG3BA83JLT3EQQ3JLV37DQ390B39FJ3EL33JF835X73JM137SS3JJT3JHR3JJW3JFJ3JM83JHX3JMA3JFQ3BR83JMD3JK33JMG3JK73JI73JMK3JKA38RW3JG72353JG93JKE2BQ26Y3JMR3BHI1232TL3JMV3C633JMY3GHV3EYH32J33JN33C313JCT3HM93AIR3JIQ3E523JL5377J38O73IPW3JIW3JLA3JIY3JLC3JNI3JLE37RY3JJ436ZJ3JLJ387O3AMD3DEN3F3G3JH83JNS33VC3JNU3I783JNX3IXS3IAO37S53JLX3EWL3JLZ1I32TL3JFB3JJU3JHS3JHU39F73JHW3JFN3JHZ3JMC3JME3H053JOJ3JMI3JOL3JG23JON3I503JMN3JOQ3JID38DN32TL3BNE32TL3B5R3JN43JL13JIO34B93JPA374X3JPC39113JPE3FZB3JPG38QD3JLB39K03JPK3IAM3JH03JNM3JJ53JNO3JLL3ILH3JNR3JJC3JNT35VH3JNV3CSU3JPZ3J0J34BV3JQW34QN38UP33JL32ZO36E534CX359A35UW39553IE13AE538KH3IAR3EWK3JS42ET346D29H3C0F32J838N53483359H31MI32GV3JQL3JQ427U3JOB2823JM93JQF3JOG3JQH32TQ3JQJ3C1F3JMJ3JQM2A53FOK38RH315L3AED339832WG32FG3D6R3JFK2ZU32J132TN32FG3JT52T13H0K38DL378O3H8Y3673359I338G3JOO3JMO2BQ21M32TL33AX3C4Z2BF338W3I2A3AEG3I2D27D3CQX3JP733VJ3CZL34KA3FKR3C8M3ACB36V73HYB3CGM3H3M3CN036J03CN33F2I353P324233F83FYE35HX39RO338E39UR33WH3CJ23F5Z379Q27G3JCW3IYX33QC332629H3EDJ2KA3CK735OP396T3JUD35EV3JUZ33QC37DC3E5V3H503E5V3EBB3F0N37QN33PF34XD34HV3GSK3DJI3DHZ3F7Y3GSQ3F6I3HHF3HBE3BAT34TY3DGH3HTI372D39KS35G734T53IFJ3HYX33V33F8L352I3F5V2OA351Q34PA33G333NI3EHX32Y0336C3F3W35HS2QJ355Y29J3FEO355G35FO351Q37GG325O34B33HP83GU333I03JV3355I32B837H333TB3E4P374033VX35TM34IG3JRV34B83GUY33VE33EK34C93GJ432F23GAZ3FIG3FLI3DS632TL32403JI638HE3AXO35ME36H0359G36H33JS23ALU3JS738M73JS735JX36QG32J437AT32IN3HE336QA36QC32IY29M3JXN33MM32J63JSC32JB3JSE2BE2ET3JXA3JS829G32RL32TL31Y634AF37C322T22433M422Z29F3J3F23032OS3JQ727D22437I032H322I32T83D3431RT33AY3JTQ37HW3JQT3IND3IHA38I33JX83C5I32V43C2G3JG032NJ3JYQ3CN33JZ632JK32TL2SU3BWA32TN36PU3JYM2AK1032H323U3JZ836GA3JZK27A24A3JZM399C3JZP24Q3JZP24Y3JZP2563JZP25E3JZP25M3JZP25U3JZP2623JZP26A3JZP26I3JZP26Q3JZP26Y3JZP1223Q32JZ1A3K0F3ALX3K0I388G3K0K32LY3K0M39II3K0O3B7J3K0Q3DOB3K0S21U3K0F31RT35B927J373S3DX83CZV32RL3K0W3D4U32U332OS3K0S22I3K0S22Q3K0S22Y3K0S2363K0W38A023E3K0S372Y399632JZ23U3K0S2423K0S24A3K0S24I3K0S24Q3K0S24Y3K0S2563K0S25E3K0S25M3K0S25U3K0W359X37LQ2623K0S26A3K0S26I3K1J395232FU3K0S26Y3K1J23R3K0G3K2K3ALX3K2M36HJ38DN3K2O32LY3K2R39II3K2T3B7J3K2V3DOB3K2X39VZ32JN3K2X2223K2X22A3K2X22I3K2X22Q3K2Z35N132RR3K2X2363K2X23E3K2X23M3K2X23U3K2Z35N732OY3K2X24A3K2X24I3K2X24Q3K2X24Y3K2Z35ND3E1W3HLX37Q03AFV37Q33HM238SN3E2537Q93E2832WM21O32XK269371X3FSE3HAK32Z4344L3FSJ3HYN32XW39Y235JZ3BNY33QE27C21Q3C7P3HZV3C6L2N3366H3IOP3E4X335G3FSR3FU63DAA3GPZ37D633GT3JWM33QX3HHM3F3G36QX352E39ZM333L3J2P35CG33EI3JW634U337GV38L92MC3F3S33YM319K333434G135CF3IG635F23ID835S935DI27G338A3GV73K5W33QC397K3DFL3F7E33EL3HIT32XF325N351U33H137DV33833JTI338I3IP63A3K2B42BT34H73K6G34UT33WA331927C3K6I34V039SV364K330I3G4139BF37RE3G6L3FDK3G4537213K6F34R03K6I34V335G7310Z33J83CPR33PG3GXF325Y3JW13FAR331X34XT36ET3CMJ37OG2L635UW33V33E9D3GVR3G4A3GRZ3JVS3GXU38QI374U34UJ36IX34OW3HBB3GUH3BJG3IFX35FO3HO83G223DJG34KM2B431TZ39KC3K853CLO3K6R3G1Y3EDB3ILX3FA231803K6T35F13CMJ35JF3EFX38WC2B43DBW353P3K8M35T435FO34OZ35K137H335NU38GN34KE3IC437DV35RN3JW42BQ34X334OW3DKU3B4D3EGF33393E0J3DL72MC3G3I3ACB33UA34QA311L3K8937CJ31033IPC336Z350D311L31763H6H385G310331HD317634ZF2LP35UR327U35UE3G3B3K9731223EGQ3K9A3GPZ3K9D34U33K9F3HHF36BI3K9I34YT3K9K34PT3K9M3GMI33X53C9C34PT2RQ315I3CL03K9P31CD315I3K9T3G382793K9W3GUR3CN93K9Z31033KA12N43FY53KA435DZ3KA63IDY3KA836DZ32YE2LP3A7A3KAR3B4D3GUM2LP397T33TK31033K6813311L3JWM3KAD3HTS33GE3KBJ33J536QX311L35FQ3EGA35EZ31F5330W35WI33HO317H3E4X2UN32083E6F318836F8317H35WI3K5O27D36GU3JSA3E5W3DPJ27D23V360031033CNQ35TM3CNQ35FE2LP34PQ34GM332I34PQ330W24433SQ31033K6A31JU3KBC3KB335RT34GT31033KCQ39KC3KD034YO31033EGL34KA39S434H73KD23G3L34I43DLA34I52BM3HHW3FWD24M3GY039E63IDK3DCV3HI63G2B37UL3IG139LT3FW832B8355W3F3G3FCE31ZL3CM133G33KDP3C9135EG34RN3DJZ3FWD3KDV32403FVO338M3KE43KDI3K7632B83CDS3KE93GXF32403GNU325O3KDZ3GWR3KE13FW93KDL3HO731ZL3GO93KE83KDU3KEA3E8R3CEE3KEE3HC133TI3KDO3KE93K753E8R3DDT3KES3KEF3FBG352R3KEJ38BC34M834RN384M3G373HTW27D3CFJ3KDY3KF035KW34RN3D0O3KF43KEX3HTZ357R3KF83FDV3EIC3DM63KFM3KFE27A3EHM3KFH3CQO33IU397T34M232Y63ICV38WC29426S34R03KG733F83CKO34ZF27C3KG934UF332I3KGE35JN3K9G3CMX33HG39BF3EGQ3CPE2ZU3DMD337X3FC533QE3KG63KG833SQ2943K733KFD3FD73GW4359B33TW3HNV3E9034M834N83FBV3DDC2ZU37UT2QJ3K7I35GI3JWC3IIW3GT633HG35IB34QP3CAS3GWD3K7Q3FDW394J352I3KG432KL22H3FWB3H5334UH3F3W35EG34XT3JEE3F9Z3F3T3CDE336Q38IS3CA92FR3CRB3DD335KW3KH73GWQ3CEI3GWF3KI935EG3KH73DNL3CEI35S13CER3KHP3IOZ37EA3IIU3F173KHR3IFT3KGL3EI035FO34XT3DNT3EI439LD34KM35GF38II39NW34ZK3KGI3JVJ3I9I32B83KIQ3FU834RN3KGM35F134XT3JTW3KGR3KIZ31173541356U35RZ354A3KET1I3G343HB83CA93K8U3FDV3KF13E8P3DNX35FQ31HD33GO36RS3EG335RN33X832Y034X33KHR35DF332I32XD33NP3KAZ33YS311L3EGL2MC3KA93GRQ33EI311L3E4X2RQ3K9G36BI3KB136GJ1331033KK9337G3KK8350Q2N33K9Q3EY2311L3KBF2RQ3JWM3KAI397C33GE3KL33K57316O36363DKS3K9K313G330W214356Q2UN3E4X2JO31Y63KC12UN36F82UN3KLE34G6332I3KLO3KD331N33KCB345G353129R311L1X3786330W3KLZ27935J23FCX34ZK3KCM329J3KJM36RF333W32YE310321C39IK35PJ3548332I329K33NP311L3KCT2RQ34NH37CJ3KKO33OF34GT311L3KMJ35EV3KMU3KKC32XX355P36RF3H5V3KLW325G1H3KM03ARB3KJ434TG3JIM37DQ1834ZK35JX37R836LC3GXF3KKM3DCX34M834XT3FE23CEK355Y33XE3CMR33J43DPN311L3K6U3KH93CAS36BR3KHN3FWT2SU2T1353X2FR3CQQ3HPB36E93KJM3KGN3K7C2ZU3GYU3G3G342N3KH73GYX3CEG3KH53KMY342N3KBB3HPF350F34JW3GMC34M93IDY3K8T3C31335T34GA3EEY35UX3KK03FC0352Q33UX35FO3KH73H2T27A32WE34XT3KO035E52FR23I3KM633VE3KP933NP2FR35HP34XG32ZN3KCV359B3KOJ36CW3F3J2T1397T33UR3EEJ330W23C3KN7316O31763CRB33OG2RQ3KPS3KLP27D3KPZ34G93IPD34QA2RQ31763GWF3CNW3KL139BI34KM2RQ2OU39KC3KQE3KAF35F13KL637BY33OO3KQA3ECD33L93KL932N0219132NY313G3I1133RC3KBQ39OP35KW317H31Y637SZ331X2UN31763EJ03HZ635EG2JO35HV31S0359B3K5W3FUF3749313G34BX3KOQ35JX313G35DI2FR3C3D3GV73KRN33L933YH34MY3FWS34GP3KH735FG35KL3KP536402FR24E3KPA330W3KS13KPD35G12QJ35KH3KOH38FQ3KPK34OC3KPM394636ZP3HHD353P2483KPT3KQ63HVD34G32RQ3KSI3KQ027A3KSO34KU319K24B3KJ2332I3KSU2BM3KOT35C434RX3KQX38FQ3KQJ31TZ2BQ3KQP359B3KQT27D2G53KT632F2363635GO34M8312F320822838FQ3JW13KON3KQJ31Y63KRI39BI33T633NE35TJ2FR23V3KN53KCC3KO63KOY3E9934QA3KH736TA3CNW3KRY36FT2FR2783KO4330W3KU833TK3KPE35J93KPG3J5C35KW3KSB2RE3GOD3KPN39LA3KSG33VE2543KSJ31MI2253KSM123KUP3KSP3KUU353134GT319K2573KSV27D3KV13KSY3KQ436GA31F535O43KQJ33UT3KTC35EG3KT936Q2337L31803KTE35KW3KTH36993KTK3JKZ3E8Y315I3KTO2QI3KJS3D9J33J433RY35UZ2FR24R3KTW3CA33KTY342L3KOZ34N72YT333C3KRX3KHA3KRZ122663KS2332I3KWB3KS53KPF35DY3KS9350F3KSB3KHT3KUK3KSE34II3KUN34UB3KUQ31763KUS35GH2RQ26037YM3KWQ32YC3KUZ122633KV227A3KX23KV53KOU3KT135KW3KQJ32ZM3KVC354I3KVE1222N3KVG3HHN3HYX3KTG3E5W35CK350F3KTL3KVO3HNV3KTP3ECD33T62IX3KVW1225N3KVZ3KXW3KW13KRS35F13KH72VV3KW73KNZ3KW92723KWC3HFT356Q3KUD35O03KUF32Y03KPI331X3KSB3ET23KWM3IMU3KWO3946330W26W3KWR3KSL3KWU123KYP3KUW3KYU3KSS1226Z3KX33KYY350Q3KSZ32ZR3KX835EG3KQJ3B8E3HTE3KXD31CR35E53KTC3KVH336A3KVJ3E5W333K331X3KXO382V3KVP3CBJ3KVS3CAG33J4386N3KRL1226J3KXY3KZU33F83KRR35DX3KRT33UT3KH72U43KY53DDE35J22FR1U3BYK3KM72TI3BYK34JH3KWG3KS83KYG39E82S43BNJ36BR3KUL3KH93KWP332I1O3BYK34GP3KSK3IK03KUT3L0P3KUW3L0V3KYX1R3BYK34NP3L0Z3KX63KT03KV834M83KQJ33CG3KXI34M83KXE36423KZD3L193KCA3KXK320822W3KVM3KN937VM3KZM39803KZO350J38DM3KTT2933BYK35TM1B3C6L34K33KW23KU034U33KH73C8T3KP43KW83KU63GX63L093HUE3L0C33EI3KYC365D3KYE32XF3L0G2N43C3M3KSD3KYL33U13KYN3KK83L0Q33UT3L0S123KWT33TD2RQ21K3BYK3KC634CV3BYK34KM319K21N3L1033VE3L313L133KZ43L15342N3KQJ3BJF3KZ935O43KXE2AB3L1D3L3B35TG354I3KVK35M63L1J3HCV34K83L1M39LE3L1O3EHG333U3KZS2173L1T33VE3L3U2BM3K8W36PL37EE26H320834TK3ES83KCA3DNJ392T33RG332035SU34TS3FUT33I22723DFZ3F6V35OF351G33I73HON33R933QS3KER37KJ3DHS3G5U3CQA33PU3DOY3BPE354I310332B831QN350I35ZU3JA332YW2KR39S43DOA2T131HD3GUX33SG3G6F32ZN3DBF311L38QI2EY2RQ34YS34GF3EKC3DPD34NE3GYL35961O3KQS3KBS374O312F2S434KM312F2FG39KC3L5X35DZ312F34I933R4317H3L5834GT317H35QR34NP35QR34GP317H39I534U32UN3L62374O2JO3H4K2F436RD34QA2QT37H23HCB2QT35VA330W35QY34GP3L6N3HHN33HO2ME3F6T35L43JVZ3HNV331X32ID326G3F6X2YS326G3H6E3DID3L7834BI310Z34BX331X34XR32B835VN331X3JWD384N374934BD3JGI13312F3KR634NS31883KT231PN2UN3F7M3HZ635JX31PN2F43HD838DT34BX3K4J31GW3L7U330D2JO3EE2330D2F43L7Z330D2QT3HD8337X2UN35VN3L8531BL33WK2F434WS330G2QT3L8D2NG3L8G31WF34TD3L852F43L87318M3L8O330D2ME3L8R2OA3L8T2F434D03L852QT3L8Y2ME37FH330G2OA3L8R32ID3L8T3L8Q34MD2NG3L8Y2OA3F7M330D32ID3L8R2YS3L8T2ME35K13L852OA3L8Y32ID3L9038IE3L8R34WB3L8T2OA37BX3L8532ID3L8Y2YS3L9N3FUO3L8R310Z3L8T3L9Y3L9J2YS3L8Y34WB3CL5330D310Z3L8R34XR3L8T2YS37FH3L8534WB3L8Y310Z340P330G34XR3L8R338C3L8T3LAJ3L9J310Z3L8Y34XR3LAK33L93L8R32EC3L8T3LAV3L9J34XR3L8Y338C3LAW330D32EC3L8R350V3L8T34XR3CCT3L85338C3L8Y32EC3LAA350V3L8R332Q3L8T338C35573L8532EC3L8Y350V3CCT330G332Q3L8R2FG3L8T32EC3CCZ3L85350V3L8Y332Q3LC4330D2FG3L8R33083L8T350V3DJZ3L85332Q3L8Y2FG3LAA33083L8R352V3L8T332Q3CM83L852FG3L8Y33083LAA352V3L8R33JD3L8T2FG3CDS3L8533083L8Y352V3L9Z33JD3L8R33ZU3L8T3308354O3L85352V3L8Y33JD3LAA33ZU3L8R33TU3L8T352V35XZ3L8533JD3L8Y33ZU3557330G33TU3L8R2F13L8T33JD39653L8533ZU3L8Y33TU3CCZ330G2F13L8R2N33L8T33ZU3CEE3L8533TU3L8Y2F13LEC330D2N33L8R2KR3L8T33TU35713L852F13L8Y2N33LAA2KR3L8R345H3L8T2F13CNB3L852N33L8Y2KR3LE0330D345H3L8R360F3L8T2N33CNU3L852KR3L8Y345H3DJZ330G360F3L8R32WE3L8T2KR36YG3L85345H3L8Y360F3LEO3CNW3L8R326Q3L8T345H36I33L85360F3L8Y32WE3LFZ326Q3L8R33SP3L8T360F3COB3L8532WE3L8Y326Q3LAA33SP3L8R3COG3L8T32WE3DLY33GW29H326Q3L8Y33SP3LAA3COG3L8R35PH3L8T326Q3CRZ3L8533SP3L8Y3COG3CM8330G35PH3L8R34K13L8T33SP3CPQ3L853COG3L8Y35PH3CDS330G34K13L8R2ZT3L8T3COG3CPT3L8535PH3L8Y34K13CMC330D2ZT3L8R34LY3L8T35PH3DMH3L8534K13L8Y2ZT35XZ330G34LY3L8R2F73L8T34K13EHV3L852ZT3L8Y34LY3CMT330D2F73L8R358U3L8T2ZT39JN3L8534LY3L8Y2F73CEE330G358U3L8R32423L8T34LY3CRB3L852F73L8Y358U3571330G32423L8R3CPG3L8T2F73GWF3L85358U3L8Y32423CNB330G3CPG3L8R362H3L8T358U3GWQ3L8532423L8Y3CPG3LJK330D362H3L8R32YO3L8T32423JRX34YO3CPG3L8Y362H3LJW35UX3L8R33Z33L8T3CPG3DNL3L85362H3L8Y32YO3GVU33Z33L8R31RY3L8T362H3DNT3L8532YO3L8Y33Z33GVU31RY3L8R336I3L8T32YO3CQX3L8533Z33L8Y31RY3GVU336I3L8R32B43L8T33Z33FCV3L8531RY3L8Y336I36YG330G32B43L8R2BT3L8T31RY3DNX3L85336I3L8Y32B43LLG330D2BT3L8R31LU3L8T336I3CRW3L8532B43L8Y2BT3LLS3KNF3L8R33E53L8T32B43FE23L852BT3L8Y31LU36I3330G33E53L8R32XZ3L8T2BT3CSS3L8531LU3L8Y33E53LMF330D32XZ3L8R34KW3L8T31LU3G7B3L8533E53L8Y32XZ3LMR3CSV3L8R31173L8T33E534B93L8532XZ3L8Y34KW3COB330G31173L8R2YH3L8T32XZ38263L8534KW3L8Y31173LNE330D2YH3L8R31I23L8T34KW3KP232XW1N3L7P3CSV34BV29H317H3L8Y2UN3LNQ31WF3L8R3L8137CY317H3L8433UZ2UN3L8Y2JO3LGR330G3L8C33O43L8F37CY3L8I3L9J3L8L33U62F43LOI3L8E3C31330G3L9T37CY2JO3L8V33UZ3L8X33WK2QT3LOT2NG3L9338IE35233L963L9J3L9933WK2ME3LN33L9E33O43L9G37CY3L9I34Z729H2ME3L9L3GCV34HH3L9P33O43L9R37CY3LOX3LPL3BEY3L9X3KFO34HH2YS3LA13LP838GK3LA43L9J3LA733WK2YS3LP534WB3LAC3LQ3374J3LAF3LPW3LAH33WK34WB3LO73LAM33O43LAO37CY3LAQ3L9J3LAT33WK310Z3LO73LAY33O43LB037CY3LB23LPW3LB433WK34XR3LM4338C3LB93LQD337X3LBC3LPW3LBE33WK338C3LM43LBJ33O43LBL37CY3LBN3L9J3LBQ33WK32EC3GVU3LBU33O43LBW37CY3LBY3L9J3LC133WK350V3GVU3LC633O43LC837CY3LCA3L9J3LCD33WK332Q3LK83LCI33O43LCK37CY3LCM3L9J3LCP33WK2FG3LK83LCT33O43LCV37CY3LCX3L9J3LD033WK33083LP53LD433O43LD637CY3LD83L9J3LDB33WK352V3LP53LDF33O43LDH37CY3LDJ3L9J3LDM33WK33JD3LO73LDQ33O43LDS37CY3LDU3L9J3LDX33WK33ZU3LO73LE233O43LE437CY3LE63L9J3LE933WK33TU3LN33LEE33O43LEG37CY3LEI3L9J3LEL33WK2F13LN33LEQ33O43LES37CY3LEU3L9J3LEX33WK2N33LM43LF133O43LF337CY3LF53L9J3LF833WK3LFT3LUI3LOV330D3LFF37CY3LFH3L9J3LFK33WK345H3GVU3LFP33O43LFR37CY3LUP3LPW3LFW33WK360F3GVU32WE3LG13LR73IDP3LG533UZ3LG733WK32WE3LK83LGB33O43LGD37CY3LGF3L9J3LGI33WK326Q3LK83LGM33O43LGO37CY3LGQ3L9J3LGU33WK33SP3LN33LGY33O43LH037CY3LH23L9J3LH533WK3COG3LN33LHA33O43LHC37CY3LHE3L9J3LHH33WK35PH3LK83LHM33O43LHO37CY3LHQ3L9J3LHT33WK34K13LK83LHY33O43LI037CY3LI23L9J3LI533WK2ZT3GVU3LIA33O43LIC37CY3LIE3L9J3LIH33WK34LY3GVU3LIM33O43LIO37CY3LIQ3L9J3LIT33WK2F73LM43LIY33O43LJ037CY3LJ23L9J3LJ533WK358U3LM43LJA33O43LJC37CY3LJE3L9J3LJH33WK32423LP53LJM33O43LJO37CY3LJQ3L9J3LJT33WK3CPG3LP53LJY33O43LK037CY3LK23L9J3LK533WK362H3LO732YO3LKA3LVD3LKD3L9J3LKG33WK32YO3LO73LKK33O43LKM37CY3LKO3L9J3LKR33WK33Z33LP53LKV33O43LKX37CY3LKZ3L9J3LL233WK31RY3LP53LL633O43LL837CY3LLA3L9J3LLD33WK336I3LO73LLI33O43LLK37CY3LLM3L9J3LLP33WK32B43LO73LLU33O43LLW37CY3LLY3L9J3LM133WK3IVR34HP31LU3LM63LVD3LM93L9J3LMC33WK3LME33O43LMH33O43LMJ37CY3LML3L9J3LMO33WK33E53LM43LMT33O43LMV37CY3LMX3L9J3LN033WK32XZ3LM434KW3LN53LVD3LN83L9J3LNB33WK34KW3GVU3LNG33O43LNI37CY3LNK3L9J3LNN33WK31173GVU3LNS33O43LNU37CY3LNW34FW3LNZ312F3LMY33UZ3LO433WK2UN3LK82JO3LO93LVD3LOC3L9J3LOF33WK2JO3LK83LOK34HP3LOM35233LOO3LPW3LOQ382Y2F43CRZ3L8P3LUR3L8S3LOY32C13L8W3L3734HH2QT3EIS3L913M2U3L9437CY3LPA3LPW3LPC33U62ME3CQ9330D3LPG34HP3LPI35233LPK3LGS3L9K33WK2OA3DMH330G3LPR34HP3LPT35233LPV3M3J3L9W33WK32ID3M323LA033O43LA237CY3LQ53LPW3LQ733U62YS3EHV330G3LQB33O43LAD37CY3LQF3M3J3LQH33U634WB3DMO3LAL3M2U3LQN35233LQP3LPW3LQR33U6310Z3M3Y3LQV34HP3LQX35233LQZ3M3J3LR133U634XR3CRB330G3LR533O43LBA37CY3LR93M3J3LRB33U6338C3GWF330G3LRF34HP3LRH35233LRJ3LPW3LRL33U632EC3M3Y3LRP34HP3LRR35233LRT3LPW3LRV33U6350V3GWQ3LC53M2U3LS135233LS33LPW3LS533U6332Q3EIW3LCH3M2U3LSB35233LSD3LPW3LSF33U62FG3M3Y3LSJ34HP3LSL35233LSN3LPW3LSP33U633083FCK330D3LST34HP3LSV35233LSX3LPW3LSZ33U6352V3DNT330G3LT334HP3LT535233LT73LPW3LT933U633JD3M3Y3LTD34HP3LTF35233LTH3LPW3LTJ33U633ZU3CR0330D3LTN34HP3LTP35233LTR3LPW3LTT33U633TU3FDB330D3LTX34HP3LTZ35233LU13LPW3LU333U62F13DNX330G3LU734HP3LU935233LUB3LPW3LUD33U62N33M3C3CEJ3LF23LVD3LUL3LPW3LUN33U62KR3DOT3LFC3M2U3LUT35233LUV3LPW3LUX33U6345H3M8B3LUS3M2U3LV335233LV53M3J3LV733U6360F3M48330D3LVB33O43LG237CY3LG43L9J3LVH33U632WE3G6A330D3LVL34HP3LVN35233LVP3LPW3LVR33U6326Q3M9535QD3LGN3LVD3LVZ3LPW3LW133U633SP3M53330D3LW534HP3LW735233LW93LPW3LWB33U63COG3CSS3LH93M2U3LWH35233LWJ3LPW3LWL33U635PH3MA13LWP34HP3LWR35233LWT3LPW3LWV33U634K13M5Z3LHX3M2U3LX135233LX33LPW3LX533U62ZT3G7B3LI93M2U3LXB35233LXD3LPW3LXF33U634LY3MA13LXJ34HP3LXL35233LXN3LPW3LXP33U62F73M6T325Z3M2U3LXV35233LXX3LPW3LXZ33U6358U34B93LJ93M2U3LY535233LY73LPW3LY933U632423MA13LYD34HP3LYF35233LYH3LPW3LYJ33U63CPG3M7P3EIL3LJZ3LVD3LYR3LPW3LYT33U6362H3826330G3LYX33O43LKB37CY3LZ03LPW3LZ233U632YO3KP2330G3LZ634HP3LZ835233LZA3LPW3LZC33U633Z33M8M3LZG34HP3LZI35233LZK3LPW3LZM33U631RY31KB3MDQ3M2U3LZS35233LZU3LPW3LZW33U6336I3MDD330D3M0034HP3M0235233M043LPW3M0633U632B43M9F39SV3LLV3LVD3M0E3LPW3M0G33U62BT31FP3M0J3M2U3LM737CY3M0N3LPW3M0P33U631LU3ME83EJQ3LMI3LVD3M0X3LPW3M0Z33U633E53MAA32XY3M2U3M1535233M173LPW3M1933U632XZ3I11330G3M1D33O43LN637CY3M1G3LPW3M1I33U63M2034HP3M1M34HP3M1O35233M1Q3LPW3M1S33U631173MB53AYS3LNT3LVD3MFV33GW3M223LO1333J3L7T3M2735GJ33O43M2A33O43LOA35233M2D3LPW3M2F33U62JO3MF23M2J3M303LVD3M2N3M3J3M2P3AM52F43MBZ3M3I3LOW3LVD3LOZ3L9J3LP233U62QT3KRB3MH33LP73L953D1W3L983M2Z3MH33MF23M3E3LPQ3LVD3M3I3L853LPN3M3L3EJD3L9O3M2U3M3R38GK3M3T3L9V3MHG3MHR3KRW3LQ03M2U3M4135233M433M3J3M45382Y2YS32FB34HP3M4A34HP3M4C35233M4E3L853M4G382Y34WB3L2R330G3LQL34HP3M4M38GK3M4O3M3J3M4Q382Y310Z3M8M3M4U34HH3M4W38GK3M4Y3L853M50382Y34XR3KT53MIX3M2U3M5735233M593L853M5B382Y338C3MI934HH3M5G34HH3M5I38GK3M5K3M3J3M5M382Y32EC3MIK330D3M5Q34HH3M5S38GK3M5U3M3J3M5W382Y350V3MEJ3LRZ34HP3M6238GK3M643M3J3M66382Y332Q3KTB34HH3LS934HP3M6C38GK3M6E3M3J3M6G382Y2FG3MJF330G3M6K34HH3M6M38GK3M6O3M3J3M6Q382Y33083MJQ3GU63LD53LVD3M6Z3M3J3M71382Y352V3MFB3M7634HH3M7838GK3M7A3M3J3M7C382Y33JD3KTJ3M773M2U3M7I38GK3M7K3M3J3M7M382Y33ZU3MKM3M7Q3M2U3M7T38GK3M7V3M3J3M7X382Y33TU3MKX3M8234HH3M8438GK3M863M3J3M88382Y2F13MG63M8D34HH3M8F38GK3M8H3M3J3M8J382Y2N33KTS330G3LUH34HP3LUJ35233M8Q3M3J3M8S382Y2KR3MLQ3IDP3LFE3LVD3M903M3J3M92382Y345H3MKX3LV134HP3M9838GK3M9A3LFV3MHX3FAX3MBZ3M9H34HP3M9J35233M9L3LPW3M9N382Y32WE36TA330G3M9S34HH3M9U38GK3M9W3M3J3M9Y382Y326Q3MMV3LVV34HP3LVX35233MA53M3J3MA7382Y33SP3MKX3MAC34HH3MAE38GK3MAG3M3J3MAI382Y3COG3MCT3LWF34HP3MAO38GK3MAQ3M3J3MAS382Y35PH3KUJ34HH3MAW34HH3MAY38GK3MB03M3J3MB2382Y34K13KVB3MOV3MB73LVD3MBA3M3J3MBC382Y2ZT318L34HP3LX934HP3MBI38GK3MBK3M3J3MBM382Y34LY34I53MPF3M2U3MBS38GK3MBU3M3J3MBW382Y2F73KVV34HH3LXT34HP3MC238GK3MC43M3J3MC6382Y358U3M8M3LY334HP3MCC38GK3MCE3M3J3MCG382Y32423KW634HH3MCK34HH3MCM38GK3MCO3M3J3MCQ382Y3CPG3MP3330G3LYN34HP3LYP35233MCX3M3J3MCZ382Y362H3MPC34HH3MD434HP3MD635233MD83M3J3MDA382Y32YO3MPN34HH3MDF34HH3MDH38GK3MDJ3M3J3MDL382Y33Z33MPX330G3MDP34HH3MDR38GK3MDT3M3J3MDV382Y31RY3MEJ3LZQ34HP3ME138GK3ME33M3J3ME5382Y336I3KWL34HH3MEA34HH3MEC38GK3MEE3M3J3MEG382Y32B43MQT3LLT3M2U3M0C35233MEN3M3J3MEP382Y2BT3MR4330G3M0K3M0S3M0M3EJQ3MEY3MNB31LU3MRF3LMG3M2U3M0V35233MF63M3J3MF8382Y33E53MRQ3LMS3MFD3LVD3MFG3M3J3MFI382Y32XZ3MFB3MFN3MFW3M1F3G7E3M3J3MFT382Y34KW3KXB34HH3MFX34HH3MFZ38GK3MG13M3J3MG3382Y31173MSM3MG73M1X3MG93ASB34Z73MGC3G7B32Y83LO33MNB2UN3MSW3L883M2U3MGL38GK3MGN3M3J3MGP382Y2JO3MT53L8B3M2U3M2L38GK3MGW3L8K3MNB2F43MTF318M3L8R3M3T374J3MH53LPW3MH7382Y2QT3MG63L9233O43M353LP93MHE33UZ3M39382Y2ME3KXG34HP3MHJ3M3O3MHL3C313MHN3MNB2OA3MU83M3P3MI03L9S3LQ33MHW3LPY3MUK3M3Z3MIA3LVD3MI43LA63MNB2YS3MUU3LAB3M4B3LVD3MIF33UZ3MIH3AM534WB3MV33MIM34HH3MIO374J3MIQ3LAS3MNB310Z3MBZ3MIW3M543LVD3MJ033UZ3MJ23AM534XR3KXM3MJ63LR63LBB3F213MJB3MNB338C3MU83MJH330G3MJJ374J3MJL3LBP3MNB32EC3MW33MJS3M603LBX3IHK3LC03MNB350V3MWB3MK23MKC3LVD3MK63LCC3MNB332Q3MV33MKD34HH3MKF374J3MKH3LCO3MNB2FG3MCT3MKO330G3MKQ374J3MKS3LCZ3MNB33083KXU3MKP3M2U3M6X38GK3ML13LDA3MNB352V3M8M3ML7330G3ML9374J3MLB3LDL3MNB33JD3KY43ML83MLI3LVD3MLL3LDW3MNB33ZU3MEJ3M7R34HH3MLT374J3MLV3LE83MNB33TU3KYJ3MZ93M2U3MM3374J3MM53LEK3MNB2F13MFB3MMB3MML3LVD3MMF3LEW3MNB2N338PZ3MZR3M8O3LF43IDP3M8R3MNB2KR3MG63LFD33O43M8Y38GK3MMZ3LFJ3MNB345H3KZC34HH3MN534HH3MN7374J3MN933UZ3M9C382Y360F3MND3M2U3MNG38GK3MNI3M3J3MNK3AM532WE333K3MNO3M2U3MNR374J3MNT3LGH3MNB326Q3MBZ3MNZ34HH3MO138GK3MO33L853MO53AM533SP386N330G3MO93MAM3LH13FE43MOE3MNB3COG3MA13MOJ3MOT3LVD3MON3LHG3MNB35PH3M8M3MOU330G3MOW374J3MOY3LHS3MNB34K13L033MP43LHZ3MP6123LI333UZ3MP93AM52ZT3MA13MPE34HH3MPG374J3MPI3LIG3MNB34LY3MEJ3MBQ3MPY3LVD3MPS3LIS3MNB2F739CV3LIX3MC13LVD3MQ33LJ43MNB358U3MA13MQ93MQJ3LVD3MQD3LJG3MNB32423MFB3MQK3MQU3LVD3MQO3LJS3MNB3CPG33CG3N3G3MCV3LK136GV3L853MR13AM5362H3MA13MR63MRG3LYZ3HCN3MD93MNB32YO3MG63MRH3MRR3LVD3MRL3LKQ3MNB33Z33L1C3MRI3M2U3MRU374J3MRW3LL13MNB3MSH330G3MS23MSC3LVD3MS63LLC3MNB336I3MBZ3MSD330G3MSF374J3MSH3LLO3MNB32B43L1I3MEB3MSO3MEM3KNF3MEO3MNB2BT3MA13MSY34HP3MEV35233MEX3M3J3MEZ382Y31LU3MCT3M0T34HP3MT838GK3MTA3LMN3MNB33E53L1Q330G3M1334HP3MFE38GK3MTJ3LMZ3MNB32XZ38FP3MFM3M2U3MFP35233MFR3MTT3MNB34KW3M8M3MTZ330G3MU1374J3MU33LNM3MNB3117375V3MFY3M2U3M1Y35233MGA3LNY3LO03G7B334U3MUH3LO534NW3MGI3MUM3M2C3HIM3L853MUR3AM52JO3MEJ3MGT3M2T3L8T3MUZ33UZ3MGY3MGK39CH3LOL3M2U3MV6337X3MV83M3J3MVA3AM52QT3N623M333MHC3M363MVI33EL3MVK3AM52ME3MFB3MVP3MHR3L9H3MVS33UZ3MHO33U62OA3L3E3MHK3L9Q3LVD3MHV33UZ3M3V33U632ID3N7N3MW434HH3MI23LQ43GSX3MW83LA83EIL3MW53LQC3LAE37QJ3LQG3MNB34WB3GI03MIL3M4L3LVD3MWP33UZ3MIS3AM5310Z3N8E3MWU330D3MIY374J3MWX33EL3MWZ3LQM3N3Z3MX33M563LVD3MJA33UZ3MJC3AM5338C333U3M5F3M2U3MXD337X3MXF33UZ3MJN3AM532EC3N8E3MXK330D3MJU374J3MJW3MXO3LC23MHQ351D3LC73MXU3GN83M653MXX3C323LS03M6B3LVD3MY433UZ3MKJ3AM52FG38W63MKN3M2U3MYB337X3MYD33UZ3MKU3AM533083M8M3M6V34HH3MYK374J3MYM33UZ3ML33AM5352V27M3M6W3M2U3MYT337X3MYV33UZ3MLD3AM533JD3NAJ330D3M7G34HH3MLJ374J3MZ333UZ3MLN3AM53MZ63LTE3MLS3LVD3MZC33UZ3MLX3AM533TU23B3LTO3MZI3LVD3MZL33UZ3MM73AM52F13NBD3GUM3LER3MZS3GOJ3MMG3MZV3G4Z3M8E3M2U3MMO38GK3MMQ3LF73N03123740330G3N0634HP3N08374J3N0A33UZ3MN13AM5345H3NC53N0G330G3N0I337X3N0K33EL3N0M3AM5360F3MG63MNE34HH3N0R374J3N0T3LG63MNB32WE336E3MNF3N103LVD3N1333UZ3MNV3AM5326Q3NC53N183N1I3MA43LPZ3N1D3MNB33SP3MBZ3N1J330D3MOB374J3MOD3LH43N1O3G383MAD3MAN3N1T3EID3MAR3N1W3C8U3LWG3M2U3N21337X3N2333UZ3MP03AM534K13MCT3LWZ3MPD3N2A3N2C33EL3N2E3LWQ123AQS3MBG3LIB3LVD3N2M33UZ3MPK3AM534LY34DK330G3N2R3N2Z3LIP3MC03MBV3N2W3G5V3N2S3LIZ3N313NCC3MQ43N34365T3MQ03MCB3N3937XL3LY83N3C367X3LY43M2U3MQM374J3N3I33UZ3MQQ3AM53CPG3MEJ3MQV3MR53MCW3N3Q33UZ3N3S3LYE1231CC3MQW3M2U3MR838GK3MRA3LKF3N413NFP3MR73M2U3MRJ374J3N4733UZ3MRN3AM533Z33MFB3MRS3N4K3LVD3N4G33UZ3MRY3AM531RY2ZD3MDZ3LL73N4N3GXL3MS73N4Q3NGG3N4M3LLJ3LVD3N4X33UZ3MSJ3AM532B43MG63M0A3MET3LLX3N553MSS3N572S53M0B3MEU3MT03LMA33UZ3N5G3AM531LU3NF3330D3N5K34HH3N5M374J3N5O33UZ3MTC3AM533E53MBZ3N5U34HH3N5W374J3N5Y33UZ3MTL3AM532XZ32A63N5V3N643MTR3LN933UZ3MTU3AM534KW3NHV3FEX3LNH3LVD3N6G33UZ3MU53AM531173MCT3M1W34HP3N6N38GK3N6P27E3MUE38L93N6U3MGG31XQ34HP3MGJ34HP3MUN374J3MUP3N713MNB2JO32513NJC3MUW3MGV3D2H3MV03L8Y2F43M8M3MH23M333L8T3N7I3M2Y3L8Y2QT366C34HP3MVE3MVO3LVD3M373M3J3N7T33O42ME3NJJ34HH3N7X369L3N7Z35JX3MVT3LPO3MEJ3MVX330G3MHT374J3N8933EL3N8B382Y32ID23L3LPS3MI13MW63N8J33UZ3MI63AM52YS3NK93M493M2U3MID38GK3MWF33EL3MWH3M403NFF3N8V3LAN3N8X32WN3MWQ3LAU3K0E3N9B3LAZ3MWW37VO3MJ13MNB34XR3NL03N953MJ73N9F3MX63N9H3MX83N8M3MJG3N9N3LVD3N9Q33EL3N9S3N9E35YL3M5H3M2U3N9Y337X3NA033UZ3MJY3AM5350V3NLO3NA43NAB3LC93NA73MK73NA93MBZ3MY03NAK3LCL3CM53MKI3MY63IPG3MKE3NAL3LVD3NAO33EL3NAQ3LSA123NMD3NAU3M753ML03EFN3MYN3LDC3NA33MYR3NBE3LVD3NB833EL3NBA3LSU35WF3LT43MZ13LDT3CMK3MZ43LDY32U53M7H3NBP3LE53E8S3MZD3LEA3NFB3LED3NBY3LEH3GUM3M873MZN123KCD3M833M2U3MMD374J3MZT33UZ3MMH3AM52N3329H3NCD3MZZ3LUK3N013MMR3NCJ3MEJ3NCN3N0F3MMY3GVB3MN03N0C337E3N073M973LVD3ND134YO3ND33NOQ3NOB3N0H3N0Q3LVD3NDB3LVG3NDD3NL93M9R3NDH3LGE3E7Q3MNU3N15122NF3M9T3M2U3N1A374J3N1C33UZ3N1E3LVM3NNM3N193M2U3NDZ337X3NE133UZ3MOF3AM53COG3MG63N1R3LHL3NE73LHF33UZ3MOP3AM535PH2QR3MOK3NED3LVD3NEG33EL3NEI3NEC3NOX3N203MP53LI13N2B3LX43MNB2ZT3MBZ3N2I3NF43NEX3KH83MPJ3N2O122ZN3MPO3LIN3N2T3NF83MPT3NFA3NQC330D3MPZ34HH3MQ1374J3N3233UZ3MQ53AM5358U3MCT3N373LJL3NFL3LJF33UZ3MQF3AM53242351B3MQA3NFR3N3H3NLV3N3J3LJU1234FJ3MQL3M2U3MQX38GK3MQZ3N3R3MNB362H3M8M3N3W3MDE3N3Y3LKE33UZ3MRC3AM532YO3BX73NS23LKL3N463FD23LZB3N493NRQ3LZ73N4D3NGT3DNF3N4H3LL33NQO3NGS3NH13LL93NH33N4P3LLE122EY3MS33M2U3N4V337X3NHA33EL3NHC3LZR3NSG3N523MEL3NHI3LLZ33UZ3MST3AM52BT3MFB3N5A34HH3N5C38GK3N5E3LMB3MT31235VD3N5B3MT73MF53MFC3MF73N5Q3NT43NHY3MTH3LMW3MGD3N5Z3LN13NLV3N633M1E3LN73MTS3LNA3N6935L93MFO3M2U3N6E337X3NIT33EL3NIV3NU83NRR3N6D3N6M3MUB3LNX3NJ43N6R39B43NJ733U62UN3MBZ3NJB34HH3NJD337X3NJF3LOE3NJH3AGK3NJK3L8R3MUX374J3N7933EL3N7B3NJK3NUG3LOU3MV53MH43M2X3LP13MNB2QT3MBZ3NK13NKA3NK33N7R34YO3NK63NK012336M3NK23L9F3MVR3NKE3N813MVU3NNT3MHR3N873MVZ3L9U3N8A3MNB32ID3KCQ3M3Q3NKT3LA33NKV33EL3NKX3NKS3MEJ3MIB34HH3NL33LQE3N8Q3M4F3N8S1232993MIC3N8W3LAP3NLD3N8Z3MWR3NP4329I3NLI3LB13NLK3MWY3NLM32S03LQW3NLQ3MX5340P3MX73LBF3NU03LBI3NLX3LBM3E7N3MJM3MXH374J3NM43LBV3LVD3NM833EL3NMA3LRG3N9C3M603NA53NMG3LCB33UZ3MK83AM5332Q2M23MK33NAC3NMN3LCN3NAF3NMQ3MY83NMT3LCW3GU63M6P3MYF1234IS3M6L3MYJ3NN33LD93NAZ3MYO3NVW3DCH3LDG3NNA3EFO3MYW3LDN122P73MLH3LDR3MZ23NNJ3NBK3MZ53NSN3MLR3LE33NBQ3NNQ3NBS3MZE122IE3M7S3NNV3LU03NNX3MM63NNZ3MZP3NO33NC83LEV3NO73NCB24C3LU83NCE3M8P3NOF3NCI3LF93NX63MMW3NOQ3LFG3NOM3N0B3LFL34R13NOQ3LFQ3NOS3CNW3LV63MNB3N0O3LV23NOZ3LG33LPP3NDC3LG8399C3M9I3NP63LVO3NP83N143LGJ3NA33NDP3MAB3NDR3LGR3NDT3LGV1238503MO03NPN3LVD3NPQ33EL3NPS3LVW3NYF3NPW330D3MOL374J3N1U3NQ03NEA24G3NEC3LHN3NQ73NFB3N243LHU3NYU3FBN3N293NQF3NEP34YO3NER3MAX12332D3NEN3NEW3LID3NQO3N2N3LII3NWS3NF53NR03NQV3LIR33UZ3MPU3AM52F73KDH3MBR3N303LJ13NFF3N333LJ63NZM3NRB330D3MQB374J3N3A3NRF3NFO34SF3NRK3LJN3NRM3LJR3NFV3N3K3NXL3LJX3NRT3NG23LK333YS3NG53MCL34QF3NG93LYY3LKC3N9C3NGE3LKH3NA33N44330D3NGJ337X3NGL33EL3NGN3MD51231213MDG3NSI3LKY3NSK3NGV3N4I32T03LZH3ME03NH23LLB33UZ3MS83AM5336I32WK3NSW3NH83LLL3G633N4Y3LLQ3O3G3NT53NHN3NT73M0F3NHL312D3MET3M0L3LM83MT13N5F3NTK3O3P3NTF3NTO3LMK3NTQ3MTB3NTS3O493N5T3NTV3M163NTX3NIC3N603O3W3NI83NII3NU33NIK33EL3NIM3M143O4N3LNF3NU93NIS3AYS3MG23N6I3GL53M1N3NUI3LNV3MUC3MGB3NUM38J33NUO382Y2UN31K93NJA3N6Y3L8T3NUW33EL3N723N6X24P3N7C3NV13NJM3L8J3N7A3MV13O523M2K3N7F3NVB3LP033EL3N7K3N7E31F43NVN3N7P3MVH3L973MVJ3MNB2ME317F3NVQ3LPH3NVS3L9J3N82382Y2OA325N3M3F3MHS3N883MW03NW13LPY3O5L3NW53LQ23NW73LA53NKW3MW93O5S3N8G3NL23MWE3NWH3MIG3NWJ3M8M3MWL3LAX3NLC3LAR3NWQ3NLF24T3NLH3NX03NWV34B73NLL3LB53O4V3NLP3MX43M583NLS33EL3N9I3NX03O4G3NX73LBK3NLY3NXA3MXG3LBR3O7F354K3NXF3MXM3LBZ3NM93MXP3O6U3NXM3NMF3LS23NMH3MXW3LCE3O7U3NML330D3MY2337X3NAE33EL3NAG3NAB3O7N3CD03LCU3NMU3NY43MKT3NY63O8H3NN1330D3NAW337X3NAY33EL3NB03LSK3O7U3NN837923LDI3NYJ3NB93MYX3O813NN93NYP3NNI3LDV3NYS3NNL3O5D3NBG3NNO3LTQ3NYY33EL3NBT3NBO3O6N3MZH3LEF3NBZ3NZ63MZM3LEM3O943NC63NZG3LET3NC93MZU3LEY123O603MMC3NZH3N003LF633UZ3MMS3AM52KR3O6834HH3NOJ3LFO3NOL3LFI3NCS3NOO3O6G3NOK3NZV3LFS3NZX3M9B3NZZ123O9J3NCY3O023M9K3O043NP23O063O423ND83O093M9V3O0B3NDK3NPA3MEJ3O0F3HTZ3LGP3NDS3NPI3NDU3JJP3O0T3LGZ3O0P3N1M3NE23LH63O7U3O0V3EID3LHD3NE83MOO3NEA3O8H3N1Z3MB63LHP3O163NEH3N253O7U3NEM34HH3MB838GK3MP73LI43NQI3O9Q3NQL3LIL3NQN3LIF3NEZ3NQQ3O8H3O1Q3MC03NF73O1T33EL3O1V3LXA3O7U3NR13MCA3O213LJ33NR63NFH3O8H3O263NFM3LJD3NFM3MCF3NFO3O8H3N3F3O2L3LJP3NRN3O2I3NRP3OAU3N3N3LYO3O2N3LYS3NRY123O9B3MD33NGA3NS33LZ13NGF3OAN330D3O303NSD3LKN3NSD3MDK3NSF3OD13O313O3B3LZJ3O3D33EL3NGW3NSH3O9Y3NSO3NT33NSQ3O3K33EL3O3M3O3H3OA73LLH3NSX3NH93O3T3NHB3N4Z123OAF3N4U3N533O3Z3N563LM23OAM3NHN3O443MEW3O463NTJ3LMD3O9Q3NHX3O4H3O4C3LMM3NI23NTS3MFB3NI73N633NTW3M2433EL3NID3M0U1224Z3O4U3NU23MFQ3NU43NIL3NU63O8H3N6C3LNR3O4Y3LNL3NIU3O513O8H3NIZ34HH3NJ1374J3NJ32L73O5836AG3O5A3AM52UN3O8H3NUS3LOJ3N6Z3LOD3O5I3NUY3ODM2PZ3O5N3N783NJN3O5Q3NJP3O7U3NJS3M2V35233NJV3NVD3NJX3O7U3NVH3L9D3NVJ3O643N7S3O663O7U3NKB3M3G38GK3MHM3NVU3LPO3O8H3NKI330D3NKK337X3NKM34YO3NKO3AM532ID3OG03LQ13NL83O6Q3LQ63O6T3OD8330D3NWD3N8V3N8P34WS3O6Z3LAI3OEG3NWM3NLB3NWO3O7533EL3N903MWD3OG03N9433L93O7B3LB33NWY3ODU3O7G3N9E3NX23LBD3NLU3OE23O7O3NXK3NX93LBO3N9R3NXC3OEA3MJR3NM53NXG3MXN3O7Z3NA23ODE3NME3NXV3NXO3LS43NA93OG03O893CD03NXX3LSE3NMQ3MG63MY93M6U3O8K3LCY3NAP3NY624W3O8W3MKZ3LD73NN43NYD3NN63O8H3O8Y3NB63CD03LDK3O923NYL3O8H3NBF3LE13NYQ3O9833EL3NBL3NNG3O8H3MZ83NNU3NNP3LE73NYZ3NNS3OG03MM13M8C3O9M3LEJ3NC13NNZ3O8H3MZQ330D3NO4337X3NO633EL3NO83LTY3O7U3MMM3OA83NZI3OA233EL3OA43NZG3O8H3OA93M963NZP3OAC33EL3NCT3LUQ3O8H3NCX3M9G3NZW3LFU3N0L3OAL3OG03ND73N0Z3O033LVF33EL3N0V3O013OH83EQ03LGC3NDI3OAY33EL3NDL3O083OIE3OB23NPF337X3NPH33EL3NPJ3NPD3OG03NDX3EIB3N1L3LH33NPR3NE33OHU3EIB3LHB3NPY3LWK3NEA3OI03EID3O143OBP3LHR3OBR3O183OI73O1A3LX03NEO3NQH3LI63OHG3OBV3MBH3OC43LXE3NQQ3OG03OC93MPQ374J3N2U3O1U3NFA3MBZ3OCH330D3NR3337X3NR533EL3NR73LXK1224X3LXU3NFK3OCQ3NRE33EL3NRG3OMV3OCU3NRL3OCX3O2H33EL3NFW3NFQ3O8H3NG03OD93N3P3O2O29H3O2Q3NRS3O8H3NS13ODF3ODB3N403O2Y3OG03ODG3O323EIL3LKP3NGM3NSF3O8H3NGR330D3N4E337X3NGU3ODR3O3F3O8H3N4L3OE33ODX3LZV3NH53O8H3N4T3MSN3O3S3LLN3OE73O3V3O8H3NHG34HH3MSP38GK3MSR3LM03O413OEH3MSZ3O453NHQ33EL3NHS3NHN3OL13OEO3MTG3OEQ3M0Y3NTS3OIE3OEV330D3NI9337X3NIB3OEZ3O4M3OG03MTP3MTY3NIJ3M1H3NU63OLO3OFB3AYS3LNJ3O4Z3MU43O513OLU3OFI330G3OFK337X3OFM3DGS3OFO38JB3MGF3NUP3OE93N6X3M2B3O5G3N703NUX3LOG3OM73OFV3OG23LON3OG43NV53O5R3OG03OG83N7G3L8U3MH63NVE3NA33OGF3M3D3OGH3LPB3OGK2523MVF3M2U3OGN374J3OGP33EL3O6D3AM52OA3M8M3OGT38IE3NVZ3L9J3OGZ3O6A2533NKS3O6P3M423NW834YO3NWA3NW53NWC3O6W3OHC3LAG3NWJ2503MWD3OHI3LQO3NWP3OHL3NWR3MFB3OHP3N96337X3N9834YO3N9A3MIN122513NX03O7H3MJ93O7J34YO3O7L3M4V3NZM3MXB3OI83OI33LRK3NXC310H3NXE3LRQ3OIA3O7Y3NXI3O803MBZ3MXS330G3MK4374J3MXV3NXQ3NA934GA3NXV3LCJ3NAD3NMO3MY53LCQ3NA33OIR3GU63NY33OIU3NMW3NY62543OIY3NNE3OJ03NYC3O8U3NYE3MYQ3NB53NYI3OJ83NNC3O9331LH3NYO3NBO3O973LTI3NYT3MZ73O9D3M7U3O9F34YO3O9H3NNN25A3NBX3O9L3NNW3OJU33EL3NC23NBX3NZ93NC73O9T3NZC3OK33NCB25B3NZG3NOD3MMP3NZJ3OA33NCJ3N053M8X3OAB3LUW3NOO36YN3OAA3OAH3LV43OAJ3MNA3LFX3O2K3LG03O083OKW3M9M3NP331MH3NDG3OL33NP73LGG3OAZ3O0D3MCT3OLA3O0H3LW03OB73L443NPM3OBA3OLK3LWA3NE325F3LW63NE63OBI3NPZ33EL3NQ13OVF25C3O133NES3OLX3LWU3OBS3M8M3OBU3MBG3O1C3OM53LX61225D3OM33O1K3LXC3O1M3OC63O1O3OVE3NQT3OMS3OCB3LXO3NFA3OVM3O1Z3NFD3OCJ3LXY3NFH3MEJ3OCO3O28337X3O2A3OMZ3NFO36FE3NRC3O2F3ON43LYI3O2J3OW63NRS3N3O3LYQ3NG333EL3ONF3N3G3OWC3NG13O2U3MD73O2W3NS53NGF3MFB3ONO3NSC3ONR3O353NSF2G33O3A3LKW3NSJ3LL03O3E3NSM3OWV3ODV3NSW3OO53ME43NH53OX33OE33O3R3M033OE63NT13OE83NHF3OEC3M0D3NHJ3OOL3OEF25G3OON3NTN3OOP3M0O3NTK3OXN3NHW3O4B3M0W3O4D3N5P3LMP123OXT3MTG3LMU3MTI3O4K3OP63NTZ3MBZ3OP93O4W3O4Q3OPC3LNC1225H3NU83NIR3OPH3OFE3NUD3O513OYC3MU93NJ03NUJ3M213OFO335T3OFQ33O42UN3OYK3LO83N7C3OPZ3OFX34YO3O5J3O5E3MCT3N763LOU3OG33O5P3OQ83OG625M3N7E3NVA3NJU3NVC3O5X3OQF3M8M3OQH3BEY3MHD3OGI3NVL3OGK32AI3O693O6H3NKD3O6C3NVV3NKH3O6I3OQZ3LPW3OR13O6H3DWR3NKJ3NW63OR63O6R3NW93O6T3MFB3OHA3M4K3ORD3N8R3OHF25L3ORH3N9B3OHJ3LQQ3NWR3MG63ORO3NLJ3O7C3NWX3O7E25Q3ORX3OHW3O7I3NX33NLT3NX53MBZ3OS5354K3OS73M5L3NXC25R3NXK3O7W3LRS3OIB3OSF3NA23MCT3OSI3M6A3OIH3NA83O8725O3NAB3OSR3OIN3M6F3NMQ3M8M3OSX3NAM351D3OT034YO3NMX3NMS325F3NY93OIZ3LSW3OJ13OT83NN63MEJ3OJ53OTC3LT83O933CFV3OTH3NNN3OTJ3M7L3NYT3MFB3OJK3M813NYX3OJN3O9G3NZ03CDU3NZ33OTV3NZ53OTX34YO3OTZ3NZ33MMA3NZA3OU33LUC3NCB2PY3NOC3LUQ3OA13LUM3NCJ3MBZ3OKF3FAX3OKH3OUH3NZS2LI3NCO3NOR3OAI3OKQ3ND23OAL3MCT3OKU3NP53OUT3MNJ3NP33CSQ3OUX3NPK3OUZ3LVQ3NPA3M8M3OV43OB43O0I3OB63O0K3DE73NDQ3OVA3LW83OBC3OLM3OBE3MEJ3OBG3O0X337X3O0Z3OVJ3NEA25W3OVN3O1G3OVP3MB13OBS3MFB3OVT330D3OBW374J3OBY3N2D3OC034VS3O1J3OCF3O1L3OC533EL3NF03OM33MG63OME3O1S3OWA3LIU122623OMS3OWE3LXW3O223OCL3O243MBZ3OWJ3NRD3NFN3LJI3KX13NFQ3OWR3LYG3OCY3ON63O2J3MCT3ONA330D3NRU374J3NRW3NG43OD634SZ3O2T3O373O2V3NS433EL3NS63OD32IT3NGH3NSB3ODI3OXD34YO3O363NGH2663NSH3OXI3O3C3OXK3OO03NSM3M8M3OO33ME93O3J3OO63NST2673NT33OXV3MED3OXX34YO3NT23NSW3P6L3MSE3OY13MSQ3OY33NT93NHL3P6T3O433OOO3OEJ3OOQ34YO3OOS3MET3MEJ3OOV3MFC3OOX3NTR3OYI2JM3N5L3O4I3MFF3OYO34YO3OF03P803P7E3NU13NU83OYU3MFS3NU63P7L3OPA3OZ03M1P3OPI3N6H3LNO3NWS3OPM330D3OPO3CSV3NUK3OFN3M233E903OZC34HP2UN2QI3O5E3OPY3LOB3OQ03OFY3OQ23P873MUV3OQ53M2M3OQ734YO3NV63NUT3KWA3OZV3NK73O5V3OQE3OGD3MVD3M343OQJ3M383OGK26A3OQN3NVR3P0B3LPW3OQT3OQN3P93369L3NVY3LPU3O6K3NKN3NW23P9B3O6O3OH43P0N3OH63N8L3MBZ3P0S37QJ3P0U3NWI3OHF34Y83OHH3P0Z3ORJ3OHK34YO3OHM3NWM3P9T3P143OHR3LR03NWY3P8D3MWV3ORY38GK3N9G3O7K3NLU3MCT3P1H3N9O329I3OI43NM03NXC3P9T3N9W351D3O7X3LRU3O802683OSC3NXN3O843NXP33EL3NXR3OSC3K4B3OSQ3NMY3P223NMP3OSV34YC3NMS3O8J3OSZ3LSO3NY63PBH3MYI3P2F3M6Y3P2H34YO3O8V3NY931RS3NB43NYH3O903OTD34YO3NND3NB426C3NNG3O963LTG3NYR3OJG3NYT3PBT3OJD3NYW3OJM3LTS3NZ026D3OTU3OK53OTW3LU23NNZ3LJ83LEP3P3B3LUA3O9U3NZD3O9W26I3OU83P3H3NOE3OKA34YO3OKC3NCD26J3LUQ3MMX3P3O3M913NOO26G3NZU3O013P3U3L9J3NOV3P3S26H3O013LVC3P413N0U3NP32ES3P453NPD3P473M9X3NPA3CAQ3NPD3MA33P4C3OV63O0K26K3OB93OVF3OVB3MAH3NE326L3OVF3OLQ3OVH3OLS3LHI32P73P4V3MP43P4X3MOZ3OBS36QX3O1G3O1B3LX23NQG3MBB3OC02KY3P593MPO3P5B3OMB3O1O26P3OCF3NQU3OW93NF93P5K3H403OWD3OMV3OWF3MC53NFH26V3OMV3LJB3P5V3OCS3P5X3KG73O2E3NG63OWS3MCP3O2J33W63OD23NG93ONC3OD53LK61234Y63P6E3NGH3P6G3ODC3O2Y34X83P6M3NSH3P6O3NSE3LKS3KYT3P6U3O3H3P6W3LZL3O3F34WE3NH03ODW3LZT3NSR3O3L3NH53L4F3O3Q3M013OE53OOC3OXY3O3V2733PGJ3NT63OY23NT833EL3NTA3PGJ3PCG330D3NTE3MT63OY93MT23OEM3PC13O4A3MF43P7W3O4E3OYI331Q3P803OYM3OEX3M183O4M2713OF43P893OF63O4R34YO3O4T3NIH3PE23MTQ3P8F3MG03P8H3OFF3P8J2F23NUH3MG83O553P8P3OPR3P8R3IMU3P8T34HH2UN3PGW3OZG3NJK3OZI3M2E3NUY350Q3OQ43N7E3OZQ3LOP3O5R3PCS3MV43P9D3OZX3O5W34YO3O5Y3O5T3PIH3P023MVG38GK3NK43MHF3L9A28M2BM3OGG3P9O3LPJ3N803OQS3NVV34SI3N863NKS3P0G3M3U3P9Z3PHN3MI03OR53MI33OR733YS3OR93MI03CPO3N8N3MWD3PA93OHE3LQI34NY3P0Y3ORU3P103M4P3NWR3PHF3ORU3NWU3LQY3NWW3N993NWY3PJA3PAQ3P1B3ORZ3P1D3PAU3NX53PJ43N9M3O7P3P1J3NXB3O7T34BG3OSB3M5R3OSD3PB73NA231QO3PKG3PBB3M633O853OSN3O873LP53OIL3O8B354K3NXY3O8E3NMQ3LP53P263OIT3PBR3LD127B3PIX3OIS3PBV3MYL3PBX33YS3PBZ3MYI3PF33NAV3OTB3PC43P2N3NYL153PL437923PCB3M7J3PCD34YO3OJH3MLH3LTM3OTN3MLU3OTP33YS3OTR3O9C3LO73OJR3PCT3PCP3NNY3O9P3PK83PCT3OU23PCV3OU434YO3OK43NO23PLC3MZY3PD13OUA3PD333YS3PD53O9Z1A3PLJ3P3M3NCP337X3NCR3OKJ3NOO3LN33OKN3CNW3PDG3NZY3OUP3LM43P3Z3EQ03PDN3O053LVI3PL33PDR3MNQ3OL43OV03OL63NPA3PFS3PN63PDY3LVY3OB53OLE3OB73CBO3O0N3P4I3MAF3P4K3O0R3NE33LM43P4O3OLR3NE93PED3LM43OBN3FBN3PEH3O173LWW3PN43N283OM33OVV3PEP3OM63PDD3PES3N2J3OMA3MBL3NQQ3KNB3OW73O1Z3PF03NQX3P5K3GVU3OML3G4Z3PF63NFG3O243GVU3P5U3OMX3P5W3LYA3PO03OWQ3PFH3P613ON534YO3ON73NRK3PDQ3OWW3OD33PFO3GRQ3O272FQ2FD3PHF3P6J35TG32YO3LJK27A3N4432H43LQD3G563P6P33YS3P6R3N3X3LK83ONV33HT3PG73MDU3O3F3PM433HT3NSP3PGD3ODY34YO3OE03MDZ3PFF3NH73PGJ3OOB3FZY3ONW2IF2FD3MGC3CQX337D33JL3K7A33I231K92UN2KM35TG2JO1C32XE2JO3L7B371T3IUP2KA2JO3DBT29H3PIN3MGU3L8A3LP63OQN3P0436CS132JO2603PQH2F434UB3PQH1234GA38C73II92JO3L5U34GT2JO26A3PQH34NP3PRG33NP3L6I39N331172JO26D3PR733VE3PRP32YC2EY2JO32Z027O3CNF3L5L3KT23FE833J839P33KCV39P33KTF33R83OY63PQR34QA2JO3L6O39DG2JO26N3PRH33VE3PSF35EP3PSB3HHN33QE2JO2413PQK33XZ3PSO3512317H21W3PSP353P3PSU3PSJ3KTD33I23ORW2F432Z43NVM31J42ME3CL527A3MVP35NX3L823PII3AGI3CAZ3NJW3LP33F213MHB3PQY3N7Q3P0533OG3PRC3PSP3PR5332I1F3PSP33HO3PS9379Q2JO1E3PSV33VE3PTX3PRK33GW3PHF3PQU31PN2QT3L7X3PQX35TG3PIR36U73P05357W2F434BX3CAV3M333KJO27D317F2F434U03FXG3CAZ34H72703PQH331E3PTS3MUL1J2FD2IX2F43KL93M2T3PUV34HR2JO21Y3PSP34GP2OA3KZE35RX32ID313G3PUM38IE3L7U3DID3PT737QJ3L7Z3H6Y3PTB3MIQ3AEY35JF3MI53O6T3LBH3MWC3NWM3PJL34G32OA2193PSP32ID330W3PVW35EP3PV73HHN3DBF32ID32ZK24Y3PVD33QO3M4Y31PN3O723PVJ2KA3PVL3AHX3PVN3N8K3LQ83PTH3OH93ORC3M4D3O6Y3PVU35GX3PVX33VE3PV433NP2OA37212OA21R3PTY330W3PWY3PWU3PU2369L3PVE38IE3PU73OHA37NE3PTB3NL537QN3MVX3PUG3FUO3PUI3A7532ID3H6H3FXG3PVN34H73PW033VE3PX13PWS3PSP34VU34SC34S636LC1C34S934O034SD32XY3PXW34VV34W02NX3PSP34L431WF1J3PXR332I3PSR34HH2JO3PV133EX2PZ3PUZ3LOU3PYE33SN2JO2403PV533UT3PW23KXS33EI32ID36IZ3PWV3PQ5369L350P27D32513L9M3L3M35NX3PX52YS3LC43DID3PVI3PA82KA3PXB33OG2OA22V3PWR35H73PTS33EI3PYU379Q2OA22U3PWZ332I3PZL3PX232XW3PHF3PJG31PN3LA934BI3PX83PZ83KVN3OHD33J03PXD3NL83PXG34NF3PXI350M3PXL33XZ22C3PY928S3PYN3BEY3PSC3KP3369L3PVB33U03PZI36J13MHR3PYX27A3PYZ3GMB3PZ93MHG35D53PZ53PVR31J43NWF35NX3PZZ35GH2OA23J3PZE35IR3Q0C3PYP31F53PW434Y92MC3Q0J399P32ID3Q0M3NMZ3BEY3CBQ3Q0Q3PZ33NXA31PN3PZW3Q0W369L3Q0Y33TD2OA3PYM3K8U35VF3PZG133Q0J33QE2OA23T3PZM27D3Q1Z3PZP27E3PZR3Q0R3PX63PZV3LOV3PX93Q0Q3Q1O357W3Q013MW53Q03317F3Q0534VH3Q07353P3Q1134NP3Q2233VE3Q1R28B3PXY3PXU23X3PY134NZ34S434O127A2433Q2V34SH2BM2203PY534OA2IE2JO3Q3434WH31WF3KN435KL3PQM3H4W3PSM3OF23Q2027A24Z3PUT3PY73PUW3PYG3PTG3PYJ336E2JO24Y3Q1U2OA3K9S2EY32ID32YH3L5J3G6Y3FE83KQP39P33PVC3BCL3Q1V33EM35JX3Q1X1224T3Q3I3Q4B3Q1U2YS3PZQ3PXF33QO310Z3PU73MWU33X53PTB3ORR357W34WB37BX3PXE3LBE2FD317F34WB3CL03FXG3L8234H724H3Q0A27A24S3PSV34Y83Q45329B3Q373NY73Q3L38C739OY3L6F36EW39P33PQD3FE836ET34WT2JO34Q03L5B3L1F3HTL3KHV27E33RY36G52BQ33RY3Q583FV72OA335T3NBW3GMC35RL35D51M32XE3OGN3PU72YS3LNZ3KVN35K13Q682IY3Q663LQ33Q6D39RB3JIM3Q6C34BI2YS1Q3Q6F3Q6K35TG3LA93Q6O3H663HD73F673DID352L2BQ2YS37BX3PX73Q5P3L7D32ZN3MWN2KA3Q4X3EH234WB35GO29H310Z3Q5U3OS13PPH3FDW3Q773FA53Q793NWX3Q5829H3Q753Q7G32WN3H6K2EY34WB331F3EK53Q413PS53L5L36QN39P33Q432BM3Q5R3FE83KON3G6Z3L5L3KMO3Q5J3A0B310Z3PXJ3ACL37JS3GV33Q5I34HH3Q5D34IZ27A26P3PSP317H330W3Q8K33NP35H3379Q317H26O3Q4D3Q8T3Q8P3Q0K31GW3L5P35KL3KBZ3DGQ33GE2UN31BV3PXE3L8X3Q4V31GW3Q822PY3JW134H726D3Q53123Q8V312E3OY63AWQ317H1P3PLJ3L89336P318831Y635HV330G2JO3JWW3CNW2JO320835UW3NUV36FF3ACB2UN3Q9M33R822Y3PR12F932XE3Q943H4W31PN2JO3CB33A5A31BV3Q9S3HZ63QA431J42F41S3PQL36FF3KHV3PUE33QO2QT3Q3W2NG34G83Q5O3PS63Q46333H3J6K379Q2QT1Y3C703ICC357U357W2OA34TD34TD3P0L1Y2FD3LV3320835K13NL1366A35KL3Q7J3HJA3N8I3P0O33TK32ID3QAT2YS38WK32XB3Q5H3L5L3PVN3BBM133PYS3Q6U379Q32ID1Q3QB43HMO3C703PQT3Q7F33VE1S357U33HO34WB399P310Z33S335KL310Z320835KY3Q7M3QC83FOG133Q7H3JRQ27A34Y83QBW33XZ2103QCB3PZH3Q8X32ID3KLZ35KL3Q1C3L3M29H3Q6M3EKL3PIR3CFO1233RY3Q2K3MHK359539OY2YS3IA23FE83QAX3FE83Q82335Q3MHJ3QBG3OY62OA21239N32EY3M3V36UU39P33Q823Q7W3G6X3PQP3HTL3Q843EGH2YS36UH3Q403HIM3G723Q5P3G6R3QCT1G3OY62YS2103QDR38IE36043QE53QDW3PIX3L5L3Q5K3QD93HUW32ZJ2EY310Z384U3QEI3L5L3QDI39P33PTB3Q9I37QJ3QEE3F1R310Z34B333RY3Q4Y3LIK33L92113QBD33L9320834B739OY32EC36ZF3QBT33JK3QEU32Y0335Q3LB638Q03MWV2163QF9338C3QFB3DKZ32EC3K5W3QFG37NE3QDY3QDI3QFK37VO3PVQ338C331035KL3QFQ386R3QFD36JU3QFV3NWH3QE73QFY2L13QG03NX03KLE3QG43E5W3QFC2EY32EC35OS3QG935KY3L5N3QGC3QFL38SP3MWV35BY3QGH3QFR3EGH3LBS3Q5G3QFH3QFX3QFJ3QGD34B73QG13CF73QFP3QGI3QFS369L34C039P33QGO3GYJ3L3H32OV3QH33QFM3NLP21B3QH73QGW34WT3M573QHB3QH03EK73QGQ3QGE3OS336IS3QGV3QG63QGK3FUO3QHP3QFW3QHR3QH23QGR3PWK33L93KQR3QHW38NR3QG733343QGN3QFI32XF3QFZ3QH43NX021E3QHL3QHX34C334XR3QI03QGA3QGP3QI33QHT3MJ621F3QIJ3QI93QHY3HDC3FE83QHD3G6R3QHS3QIG3OS33KME3QI837VO3QG734L73QIC3QH13QIE3QHH3QGS3NLP21D3QIU3QJ63QHY37HE3QJ93QI23QJB3QI43QH539P33CNW3QG53QIV34C3392Z3QJK3QGB3QIQ3QJ23MJ621J3QJG3QGJ34C33L5Z3QJV3QIP3QJM3QIR3MWV21G3QK13QH9392R3QK53QHE3QE8335U3QJN3NX021H3QKB3QGX3GU63QIN3QIZ3QDH3QJX3QHI33L921M3QKL3QHN3DCH3QKO3QID2KA3QIF3QKS3M5D3QKV3QG735QR3QE53QKP3QDX3FEM3QKR3QJD33L9344932WE3QJR3QJH34C333UO3QL73QKZ3QE7342L3QL13QLC338C33OS3Q0F3QLG3QK232EC336G2AU3QHC3QLL3L5N3QLN3QJC3QI5338C329K3QJ53QLU3GUM3QDU3QHQ3QJW3QDY3QM13QKI3OS321R3QL43QHY33TJ3QLK3QJA3QLA3QK73QJY3MWV21O3QMH34C335FC3QMK3QJL3QMM3QL03QM23QH521P3QMR3LRN3QGZ3QI13QMB3QMX3QME3MJ621U3QN13CNW3QKY3QML3QHG3QN73MWV21V3QNA326Q3QNC3QMV3QNE3QK83NLP35983QLS3QH83QKM35PZ3QKE3QJ03QLB3QM332XY3QNA3H5D3QNU3QKQ3QMN3QL235GX3QNA36AW3QO13QL93QNM3QMO3NLP3CCR3QM63QH935EU3QO83QEK3QO33QLP34D13QNA2ZT3QNK3QN53QOA3QO421X3QNA35DU3QOH3QHF27E3QLO3QNX33193QOE3QKM2F73QOO3QK63QN63QNN33L92233QNA39YN32ZC3QLY3QND3QOX3QMY3NX02203QNA3JUZ3QOV3QKG3QOY3QH52213QNA3CPG3QP43QKF3QJ13QO42263QNA36M33QPL3QPU3QOK34X33QP13QKW3L3Z3G6R3QL83QOI3QP63QOB33L92243QNA3H5W3QPZ3QNW3QH52253QNA31RY3QPS3QNV3QOJ3QNX35143QQ33QG733HW3QPC3QMA3QP53QOQ3QOK22B3QNA36D23QIY3QLZ27H3QPG3OS32283QNA3K6I3QQF3QQN3QH52293QNA361N3QR93QQ93QO422E3QNA3H2Y3QRF3QQW3QNX22F3QNA33OI3QRL3QPF3QNF3NLP22C3QNA35H13QRR3QR33QRT33L93CQQ3QQQ3QHY34IU3QRY35M63QR43MJ6369A3QS334C33HDG3QS63QKH3QP7338C34NV3QJQ3QNR3QKW34HG3QSE3QPN3NX022G3QNA35RV3QSN3QS83MWV393V3QSB32EC31FP3QQL3QO23QRG3QOK34HX3QSX31D23QT03QO93QRS3QSG3KXF3QNA35GK3QST3QS0338C22K3QNA2KJ3QT73QQ83QRM3QH522L3QNA35FW3QTE3QTA22Q3QNA363P3QQ63QR23QS73QTF1222R3QNA3KUS3QTK3QOW3QRZ3QTA354D3QT53K873QTR3QQA338C22P3QNA2G53QU43QPM3QSU3NLP39TJ3QNQ3QHM3QG73KTJ3QUH3QQ03QNX33EC3QT5363H3QUB3QO4331H3QT53DBW3QUW3QOK22T3QNA362Y3QV13QNX3QA63QT537G33QV63QH522Z3QNA36E83QR13QPE3QU63QUC123CIB3QT53KDD3QQT3QN43QQV3QT93QVJ22X3QNA33S93QVO3QIO3QPT3QQG3NX03Q8I3QUM3QIK32EC333C3QUQ3QVZ3OS333V33QT53KHT3QW63QRA3NX033NA3QT535IJ3QVW3QQ73QU53QTY3QTA2OU3QT53KXG3QWC3QT23QNX335Q3QT535CK3QWQ3QTM3NX02373QNA2IX3QWW3QVR3QO42343QNA35SZ3QVB3NX03C8V3QLF3QSK3QG73ET23QX23QVI3QO43J4L3QW23QJS32EC364Y3QX83OS323B3QNA35I73QXN3MJ62383QNA29H3QXF3QWL3QVJ2393QNA35H83QXS3MWV23E3QNA2U43QXX3QSF3QVJ23F3QNA364O3QY33NLP3KPS3QT53HA33QYE33L923D3QNA364U3QYJ338C3KP93QT53L1I3QY83QSO3OS323J3QNA2923QYT3QUJ33L923G3QNA2A53QYZ3QTZ350Y3QT5375V3QZ53QTA34FH3QT539MQ3QWI3QTX3QY93QO423N3QNA36FJ3QVG3QNL3QX33QOK23K3QNA34LC3QYO3JOX3QNA32XH3QZA3QVJ23Q3QNA39CB3QZT23R3QNA28Q3QZX3QO423O3QNA35K83QZT23P3QNA3NBW35NZ3QPD3QZN3QKF3KNT3GYN3QWR3QH523U3QNA35QN28Y3R0G3QOP3L5N3R0J3J253QWX3OS33KTV3QT534SN3R0Q3QQU3QVY3QDY3R0U3FTA3QXY3QO423S3QNA35UR3R113QVP3R133EK73R15352Q3QYU3MJ623T3QNA33SD2AC3R0R3QVQ3R0I3L5L3QMD3QTA23Y3QNA35U03R1C3QVX3QQM3R1F3R1R3QW73MJ623Z3QNA35JU3PRX3R123G6R3R1G342L39P33CIN3R1Z3R0W3MJ623W3QNA31CC39RE3R1O3R1Q3QMC3L5L3R2D3QT13R2F3MWV23X3QNA36583QTW3R143R213QDY3R2P3QT83QXG3QOK2423QNA23G36433QZM3QE73R2A3R2O3QZG3R1I3MWV2433QNA32A63R2K3R283FE83R3A3R2Z3R3C3QZ0338C2403QNA3CNQ3R273R1D3R293R2Y3EK73R303QTL3QZO3QNX2413QNA32513R063QOK2463QNA36PC3QZT2473QNA3NKR3R453QNX2443QNA23Q3QN33R1Y3R2Q3R403QH52453QNA3DKW3QZT24A3QNA385G3R4E3QH53KSU3QT536GS3R2W3R0H3R173QOK3KSI3QT5329H3R4V3NX02493QNA3KCD3R573OS33KS13QT5337F3R5C3MJ624F3QNA2NF3R5H3MWV24C3QNA35LO3R503R0S3R323QNX24D3QNA2ZN3R5M3NLP24I3QNA351B3R5Y33L924J3QNA327Z3R63338C24G3QNA35W63QZT24H3QNA3A3O3QZT24M3QNA36FV3QZT24N3QNA35LD3QZT24K3QNA3A7A3QZT24L3QNA35KE3QZT24Q3QNA3KD23QZT3KVY3QT532993R683OD73QNA24A3R4J3QWJ3QUI3QTZ24P3QNA36Z03QZT24U3QNA2M23R7524V3QNA34IS3R7524S3QNA32A43QZF3QVH3R523QNX24T3QNA394P3R7S3R513QZH3QOK24Y3QNA3NZF3R7524Z3QNA34RB3QZT24W3QNA24I3R793R3N3QTZ24X3QNA38503R752523QNA3O123R752533QNA332D3R752503QNA3KDH3R5H3DBF338C3O2D3QEY338C2513PIX33EI3LB03PLJ350V2TJ38E2338C34B73LCG354K2563QF9350V32083CCT3N9Z3O7R3Q5S3F2132XF32TQ3R9I32Y03KDT32XF3KDX32XF3KE332Y03FVO34BI33JD3KV12BQ33JD32403CDS39OY33ZU34QJ31QW39P33R1G3PS234L13QZG39P33R9P3QKF3R9R3G6R3R9T37AH33JD375533RY3KED3MLO3KUX3EGH33TU31213AX13R313G6R3QEM3EJU3QDY3RAO3QKF3Q4Y3QKF3QDK13338C354O3DKC34C9',{},40,2^16,{},"\115\116\114\105\110\103",'',string.byte,string.char,string.sub,table.concat,(math.ldexp or(function(a,b)return a*(2^b);end)),(getfenv or function()_ENV['\95\69\78\86']=_ENV;return _ENV end),setmetatable,select,next,math.floor,string.format,(unpack or table.unpack),tonumber,table.insert,string.gmatch,tostring,type,_VERSION,pcall,string.match,string.find,(debug.getinfo or debug.info),string.len,rawset,string.gsub,math.random,(table.find or function(a,b)for c,d in next,a do if d==b then return c;end;end return nil;end),rawget,_G,print,setfenv);end;

loadstring(game:HttpGet("https://raw.githubusercontent.com/RandomUserRay/PrivateLMAO1/main/blacklisted.lua"))()

runFunction(function()
    fortniteballs = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
        Name = "BetterHighJump",
        Function = function(callback)
            if callback then
                game.Workspace.Gravity = 0
                repeat task.wait(0.01)
                    local player = game.Players.LocalPlayer
                    local character = player.Character or player.CharacterAdded:Wait()
                    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
                    humanoidRootPart.CFrame = humanoidRootPart.CFrame + Vector3.new(0, 10, 0)
                until (not fortniteballs.Enabled)
            else
                game.Workspace.Gravity = 196.2
            end
        end
    })
end)

runFunction(function()
    local Disabler = {Enabled = false}
	local DisablerMode = {Value = "MoveDirection"}
	local DisablerMissing = {Value = "Continue"}
	local DisablerNotify = {Value = "Vape"}
	local DisablerDuration = {Value = 5}
	local DisablerSpeedVal = {Value = 90}
	local DisablerSpeed = {Enabled = true}
	local DisablerNotification = {Enabled = true}
	local DisablerTable = {
		Values = {
			Duration = DisablerDuration.Value,
			MainSpeed = DisablerSpeedVal.Value * 1000 + 9.999
		},
		Messages = {
			Title = "AnticheatBypassV2",
			Context1 = "Hold the Scythe in your hand!",
			Context2 = "Scythe not found!",
			Context3 = "[Disabler] Hold the Scythe in your hand!",
			Context4 = "[Disabler] Scythe not found!"
		}
	}
	local SendNotify
	local NoDisable
	local HeartbeatConnection
	local RenderSteppedConnection
	local function getRenderStepped()
		if DisablerMode.Value == "MoveDirection" then
			game:GetService("ReplicatedStorage").rbxts_include.node_modules:FindFirstChild("@rbxts").net.out._NetManaged.ScytheDash:FireServer({
				direction = game:GetService("Players").LocalPlayer.Character:FindFirstChild("Humanoid").MoveDirection * 10000
			})
		elseif DisablerMode.Value == "LookVector" then
			game:GetService("ReplicatedStorage").rbxts_include.node_modules:FindFirstChild("@rbxts").net.out._NetManaged.ScytheDash:FireServer({
				direction = game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame.LookVector * 10000
			})
		end
	end
	local HeartBeatConnect = tick()
	local function getHeartBeat()
		local HeartBeatConnect2 = tick()
		local Value = HeartBeatConnect2 - (HeartBeatConnect2 - HeartBeatConnect <= 999 and 0 or 999)
		HeartBeatConnect = math.max(HeartBeatConnect,Value)
	end
	Disabler = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
        Name = "AnticheatBypassV2",
	    HoverText = "better AnticheatBypass reel",
        Function = function(callback)
            if callback then
				SendNotify = true
				NoDisable = true
				task.spawn(function()
					repeat
						task.wait()
						RenderSteppedConnection = game:GetService("RunService").RenderStepped:Connect(getRenderStepped)
						HeartbeatConnection = game:GetService("RunService").Heartbeat:Connect(getHeartBeat)
						local item = getItemNear("scythe")
						repeat task.wait() until item
						if item and lplr.Character.HandInvItem.Value == item.tool and bedwars.CombatController then
							if DisablerMode.Value == "MoveDirection" then
								if DisablerSpeed.Enabled then
									bedwars.ClientHandler:Get("ScytheDash"):SendToServer({
										direction = lplr.Character.Humanoid.MoveDirection * DisablerTable.Values.MainSpeed
									})
								else
									bedwars.ClientHandler:Get("ScytheDash"):SendToServer({
										direction = lplr.Character.Humanoid.MoveDirection
									})
								end
							elseif DisablerMode.Value == "LookVector" then
								if DisablerSpeed.Enabled then
									bedwars.ClientHandler:Get("ScytheDash"):SendToServer({
										direction = lplr.Character.HumanoidRootPart.CFrame.LookVector * DisablerTable.Values.MainSpeed
									})
								else
									bedwars.ClientHandler:Get("ScytheDash"):SendToServer({
										direction = lplr.Character.HumanoidRootPart.CFrame.LookVector
									})
								end
							end
							if entityLibrary.isAlive and entityLibrary.character.Head.Transparency ~= 0 then
								bedwarsStore.scythe = tick() + 1
							end
						elseif item and lplr.Character.HandInvItem.Value ~= item.tool and bedwars.CombatController then
							if SendNotify then
								if DisablerNotify.Value == "Vape" then
									warningNotification(DisablerTable.Messages.Title,DisablerTable.Messages.Context1,DisablerTable.Values.Duration)
								elseif DisablerNotify.Value == "Print" then
									print(DisablerTable.Messages.Context3)
								elseif DisablerNotify.Value == "Warn" then
									warn(DisablerTable.Messages.Context3)
								elseif DisablerNotify.Value == "Combined" then
									warningNotification(DisablerTable.Messages.Title,DisablerTable.Messages.Context1,DisablerTable.Values.Duration)
									print(DisablerTable.Messages.Context3)
									warn(DisablerTable.Messages.Context3)
								end
								SendNotify = false
							end
							if DisablerMissing.Value == "Continue" then
								task.wait(DisablerTable.Values.Duration)
								SendNotify = true
								NoDisable = true
							elseif DisablerMissing.Value == "Disable" then
								NoDisable = false
							end
							if not NoDisable then
								Disabler.ToggleButton(false)
								return
							end
						elseif not item then
							if DisablerNotify.Value == "Vape" then
								warningNotification(DisablerTable.Messages.Title,DisablerTable.Messages.Context2,DisablerTable.Values.Duration)
							elseif DisablerNotify.Value == "Print" then
								print(DisablerTable.Messages.Context4)
							elseif DisablerNotify.Value == "Warn" then
								warn(DisablerTable.Messages.Context4)
							elseif DisablerNotify.Value == "Combined" then
								warningNotification(DisablerTable.Messages.Title,DisablerTable.Messages.Context2,DisablerTable.Values.Duration)
								print(DisablerTable.Messages.Context4)
								warn(DisablerTable.Messages.Context4)
							end
							Disabler.ToggleButton(false)
							return
						end
					until not Disabler.Enabled
				end)
			else
				HeartbeatConnection:Disconnect()
				RenderSteppedConnection:Disconnect()
            end
        end,
		ExtraText = function()
			return DisablerMode.Value
		end
    })
	DisablerMode = Disabler.CreateDropdown({
		Name = "Mode",
		List = {
			"MoveDirection",
			"LookVector"
		},
		HoverText = "Disabler Mode",
		Function = function() end,
	})
	DisablerMissing = Disabler.CreateDropdown({
		Name = "Missing Scythe",
		List = {
			"Continue",
			"Disable"
		},
		HoverText = "Actions that will occur when the Scythe is missing",
		Function = function() end,
	})
	DisablerNotify = Disabler.CreateDropdown({
		Name = "Notification",
		List = {
			"Vape",
			"Print",
			"Warn",
			"Combined"
		},
		HoverText = "Notification that will be displayed",
		Function = function() end,
	})
	DisablerDuration = Disabler.CreateSlider({
		Name = "Duration",
		Min = 1,
		Max = 10,
		HoverText = "Notification's Duration",
		Function = function() end,
		Default = 5
	})
	DisablerSpeedVal = Disabler.CreateSlider({
		Name = "Speed",
		Min = 1,
		Max = 100,
		HoverText = "Direction Speed",
		Function = function() end,
		Default = 90
	})
	DisablerSpeed = Disabler.CreateToggle({
		Name = "Speed",
		Default = true,
		HoverText = "Adds speed to the direction",
		Function = function() end,
	})
	DisablerNotification = Disabler.CreateToggle({
		Name = "Notification",
		Default = true,
		HoverText = "Notifies you when certain actions happen",
		Function = function() end,
	})
end)

local Nebula = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
	["Name"] = "NebulaSky",
	["Function"] = function(callback)
		if callback then
			task.spawn(function() 

				local Vignette = true


				local Lighting = game:GetService("Lighting")
				local ColorCor = Instance.new("ColorCorrectionEffect")
				local SunRays = Instance.new("SunRaysEffect")
				local Sky = Instance.new("Sky")
				local Atm = Instance.new("Atmosphere")


				for i, v in pairs(Lighting:GetChildren()) do
					if v then
						v:Destroy()
					end
				end

				ColorCor.Parent = Lighting
				SunRays.Parent = Lighting
				Sky.Parent = Lighting
				Atm.Parent = Lighting

				if Vignette == true then
					local Gui = Instance.new("ScreenGui")
					Gui.Parent = StarterGui
					Gui.IgnoreGuiInset = true

					local ShadowFrame = Instance.new("ImageLabel")
					ShadowFrame.Parent = Gui
					ShadowFrame.AnchorPoint = Vector2.new(0,1,0)
					ShadowFrame.Position = UDim2.new(0,0,0,0)
					ShadowFrame.Size = UDim2.new(0,0,0,0)
					ShadowFrame.BackgroundTransparency = 1
					ShadowFrame.Image = ""
					ShadowFrame.ImageTransparency = 1
					ShadowFrame.ZIndex = 0
				end


				ColorCor.Brightness = 0.1
				ColorCor.Contrast = 0.5
				ColorCor.Saturation = -0.3
				ColorCor.TintColor = Color3.fromRGB(255, 235, 203)

				SunRays.Intensity = 0.075
				SunRays.Spread = 0.727

				Sky.SkyboxBk = "rbxassetid://13581437029"
				Sky.SkyboxDn = "rbxassetid://13581439832"
				Sky.SkyboxFt = "rbxassetid://13581447312"
				Sky.SkyboxLf = "rbxassetid://13581443463"
				Sky.SkyboxRt = "rbxassetid://13581452875"
				Sky.SkyboxUp = "rbxassetid://13581450222"
				Sky.SunAngularSize = 10

				Lighting.Ambient = Color3.fromRGB(2,2,2)
				Lighting.Brightness = 0.3
				Lighting.ColorShift_Bottom = Color3.fromRGB(0,0,0)
				Lighting.ColorShift_Top = Color3.fromRGB(0,0,0)
				Lighting.EnvironmentDiffuseScale = 0.2
				Lighting.EnvironmentSpecularScale = 0.2
				Lighting.GlobalShadows = true
				Lighting.OutdoorAmbient = Color3.fromRGB(0,0,0)
				Lighting.ShadowSoftness = 0.2
				Lighting.ClockTime = 15
				Lighting.GeographicLatitude = 45
				Lighting.ExposureCompensation = 0.5

				Atm.Density = 0.364
				Atm.Offset = 0.556
				Atm.Color = Color3.fromRGB(179, 59, 249)
				Atm.Decay = Color3.fromRGB(155, 212, 255)
				Atm.Glare = 0.36
				Atm.Haze = 1.72	
                end)
			end
		end
    })

runFunction(function()
		local Reinject = {["Enabled"] = false}
		Reinject = GuiLibrary["ObjectsThatCanBeSaved"]["APEWindow"]["Api"].CreateOptionsButton({
			["Name"] = "Reinject",
			["HoverText"] = "Reinjects Vape To Load Modules",
			   ["Function"] = function(Callback)
					Enabled = Callback
					if Enabled then
						Reinject["ToggleButton"](false)
						GuiLibrary["SelfDestruct"]()
						loadstring(game:HttpGet("https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/main/NewMainScript.lua", true))()
	
	
					end
				end
		})
	end)

runFunction(function()
   Pink = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
	["Name"] = "PinkTheme",
	["Function"] = function(callback)
		if callback then
			task.spawn(function()
				for i,v in pairs(lightingService:GetChildren()) do
					if v:IsA("Atmosphere") or v:IsA("Sky") or v:IsA("PostEffect") then
						v:Remove()
					end
				end
				local sky = Instance.new("Sky")
				sky.SkyboxBk = "rbxassetid://1546230803"
				sky.SkyboxDn = "rbxassetid://1546231143"
				sky.SkyboxFt = "rbxassetid://1546230803"
				sky.SkyboxLf = "rbxassetid://1546230803"
				sky.SkyboxRt = "rbxassetid://1546230803"
				sky.SkyboxUp = "rbxassetid://1546230451"
				sky.Parent = lightingService
				pcall(function() workspace.Clouds:Destroy() end)
				local damagetab = debug.getupvalue(bedwars.DamageIndicator, 2)
				damagetab.strokeThickness = false
				damagetab.textSize = 32
				damagetab.blowUpDuration = 0
				damagetab.baseColor = Color3.fromRGB(255, 132, 178)
				damagetab.blowUpSize = 32
				damagetab.blowUpCompleteDuration = 0
				damagetab.anchoredDuration = 0
				debug.setconstant(bedwars.DamageIndicator, 83, Enum.Font.LuckiestGuy)
				debug.setconstant(bedwars.DamageIndicator, 102, "Enabled")
				debug.setconstant(bedwars.DamageIndicator, 118, 0.3)
				debug.setconstant(bedwars.DamageIndicator, 128, 0.5)
				debug.setupvalue(bedwars.DamageIndicator, 10, {
					Create = function(self, obj, ...)
						task.spawn(function()
							obj.Parent.Parent.Parent.Parent.Velocity = Vector3.new((math.random(-50, 50) / 100) * damagetab.velX, (math.random(50, 60) / 100) * damagetab.velY, (math.random(-50, 50) / 100) * damagetab.velZ)
							local textcompare = obj.Parent.TextColor3
							if textcompare ~= Color3.fromRGB(85, 255, 85) then
								local newtween = tweenService:Create(obj.Parent, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
									TextColor3 = (textcompare == Color3.fromRGB(76, 175, 93) and Color3.new(0, 0, 0) or Color3.new(0, 0, 0))
								})
								task.wait(0.15)
								newtween:Play()
							end
						end)
						return tweenService:Create(obj, ...)
					end
				})
				local colorcorrection = Instance.new("ColorCorrectionEffect")
				colorcorrection.TintColor = Color3.fromRGB(255, 199, 220)
				colorcorrection.Brightness = 0.05
				colorcorrection.Parent = lightingService
				debug.setconstant(require(lplr.PlayerScripts.TS.controllers.global.hotbar.ui.healthbar["hotbar-healthbar"]).HotbarHealthbar.render, 16, 16745650)
			end)
		end
	end
})
end)

runFunction(function()
        local FlyGui = {Enabled = false}
        FlyGui = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
            Name = "FlyLoader",
            HoverText = "Loads FlyGui credits to Red",
            Function = function(callback)
                if callback then
                    if game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        loadstring(game:HttpGet(('https://pastebin.com/raw/h5QDPy6s'),true))()
						FlyGui.ToggleButton(false)
						warningNotification("APE", "Fly Gui Should Be Loaded Up", 5)
					else
                end
            end
		end
    })
end)

	runFunction(function()
		local InfiniteYield = {Enabled = false}
		InfiniteYield = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
			Name = "InfiniteYield",
			Function = function(callback)
				if callback then
					task.spawn(function()
					loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
					InfiniteYield["ToggleButton"](false)
					warningNotification("APE", "Loaded Infinite Yield!", 5)
					end)
				end
			end,
			HoverText = "infinite yield lel"
		})
	end)

runFunction(function()
	local AnimationPlayer = {Enabled = false}
	local AnimationPlayerBox = {Value = "11335949902"}
	local AnimationPlayerSpeed = {Speed = 1}
	local playedanim
	AnimationPlayer = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
		Name = "InvisibleExploit",
		HoverText = "put you underground",
		Function = function(callback)
			if callback then 
				if entityLibrary.isAlive then 
					if playedanim then 
						playedanim:Stop() 
						playedanim.Animation:Destroy()
						playedanim = nil 
					end
					local anim = Instance.new("Animation")
					local suc, id = pcall(function() return string.match(game:GetObjects("rbxassetid://"..AnimationPlayerBox.Value)[1].AnimationId, "%?id=(%d+)") end)
                    if not suc then
                        id = AnimationPlayerBox.Value
                    end
                    anim.AnimationId = "rbxassetid://"..id
					local suc, res = pcall(function() playedanim = entityLibrary.character.Humanoid.Animator:LoadAnimation(anim) end)
					if suc then
                        lplr.Character.Humanoid.CameraOffset = Vector3.new(0, 3 / -2, 0)
                        lplr.Character.HumanoidRootPart.Size = Vector3.new(2, 3, 1.1)
						
						playedanim.Priority = Enum.AnimationPriority.Action4
						playedanim.Looped = true
						playedanim:Play()
						playedanim:AdjustSpeed(0 / 10)
						table.insert(AnimationPlayer.Connections, playedanim.Stopped:Connect(function()
							if AnimationPlayer.Enabled then
								AnimationPlayer.ToggleButton(false)
								AnimationPlayer.ToggleButton(false)
							end
						end))
					else
						warningNotification("AnimationPlayer", "failed to load anim : "..(res or "invalid animation id"), 5)
					end
				end
				table.insert(AnimationPlayer.Connections, lplr.CharacterAdded:Connect(function()
					repeat task.wait() until entityLibrary.isAlive or not AnimationPlayer.Enabled
					task.wait(0.5)
					if not AnimationPlayer.Enabled then return end
					if playedanim then 
						playedanim:Stop() 
						playedanim.Animation:Destroy()
						playedanim = nil 
					end
					local anim = Instance.new("Animation")
					local suc, id = pcall(function() return string.match(game:GetObjects("rbxassetid://"..AnimationPlayerBox.Value)[1].AnimationId, "%?id=(%d+)") end)
                    if not suc then
                        id = AnimationPlayerBox.Value
                    end
                    anim.AnimationId = "rbxassetid://"..id
					local suc, res = pcall(function() playedanim = entityLibrary.character.Humanoid.Animator:LoadAnimation(anim) end)
					if suc then
						playedanim.Priority = Enum.AnimationPriority.Action4
						playedanim.Looped = true
						playedanim:Play()
						playedanim:AdjustSpeed(AnimationPlayerSpeed.Value / 10)
						playedanim.Stopped:Connect(function()
							if AnimationPlayer.Enabled then
								AnimationPlayer.ToggleButton(false)
								AnimationPlayer.ToggleButton(false)
							end
						end)
					else
						warningNotification("AnimationPlayer", "failed to load anim : "..(res or "invalid animation id"), 5)
					end
				end))
			else
				if playedanim then playedanim:Stop() playedanim = nil end
			end
		end
	})
end)

	runFunction(function()
		local HostPanelExploit = {Enabled = false}
		local oldhostattribute = nil
		HostPanelExploit = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
			Name = "VisualHostPanel",
			HoverText = "only visual",
			Function = function(callback)
				task.spawn(function()
					if oldhostattribute == nil then 
						oldhostattribute = (lplr:GetAttribute("Cohost") or lplr:GetAttribute("Host")) and true or false
					end
					if not callback and bedwars.ClientStoreHandler:getState().Game.customMatch and oldhostattribute then 
						return
					end
					lplr:SetAttribute("Cohost", callback)
				end)
			end
		})
	end)

runFunction(function()
    local AutoSkywars = {Enabled = false}
    AutoSkywars = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
        Name = "AutoSkywars",
	HoverText = "tp you to middle sometimes works (only skywars)",
        Function = function(callback)
            if callback then
                task.spawn(function()
                    if bedwarsStore.queueType:find("skywars") then
                        if bedwarsStore.matchState ~= 0 then return end
                        repeat task.wait() until bedwarsStore.matchState ~= 0
                        if (not AutoSkywars.Enabled) then return end
                        task.wait(0.1)
                        local tween = tweenService:Create(lplr.Character.HumanoidRootPart, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {CFrame = workspace.SpectatorPlatform.floor.CFrame - Vector3.new(0,1.5,5)})
                        tween:Play()
                        tween.Completed:Wait()
                        task.wait(0.5)
                        workspace.SpectatorPlatform.floor.CanCollide = false
                    end
                end)
            end
        end
    })
end)

function IsAlive(plr)
    plr = plr or lplr
    if not plr.Character then return false end
    if not plr.Character:FindFirstChild("Head") then return false end
    if not plr.Character:FindFirstChild("Humanoid") then return false end
    if plr.Character:FindFirstChild("Humanoid").Health < 0.11 then return false end
    return true
end

runFunction(function()
    local GodMode = {Enabled = false}
    GodMode = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
        Name = "PartialGodMode",
        Function = function(callback)
            if callback then
				spawn(function()
					while task.wait() do
						if (not GodMode.Enabled) then return end
						if (not GuiLibrary.ObjectsThatCanBeSaved.FlyOptionsButton.Api.Enabled) and (not GuiLibrary.ObjectsThatCanBeSaved.InfiniteFlyOptionsButton.Api.Enabled) then
							for i, v in pairs(game:GetService("Players"):GetChildren()) do
								if v.Team ~= lplr.Team and IsAlive(v) and IsAlive(lplr) then
									if v and v ~= lplr then
										local TargetDistance = lplr:DistanceFromCharacter(v.Character:FindFirstChild("HumanoidRootPart").CFrame.p)
										if TargetDistance < 25 then
											if not lplr.Character.HumanoidRootPart:FindFirstChildOfClass("BodyVelocity") then
												repeat task.wait() until bedwarsStore.matchState ~= 0
												if not (v.Character.HumanoidRootPart.Velocity.Y < -10*5) then
													lplr.Character.Archivable = true
			
													local Clone = lplr.Character:Clone()
													Clone.Parent = workspace
													Clone.Head:ClearAllChildren()
													gameCamera.CameraSubject = Clone:FindFirstChild("Humanoid")
				
													for i,v in pairs(Clone:GetChildren()) do
														if string.lower(v.ClassName):find("part") and v.Name ~= "HumanoidRootPart" then
															v.Transparency = 1
														end
														if v:IsA("Accessory") then
															v:FindFirstChild("Handle").Transparency = 1
														end
													end
				
													lplr.Character.HumanoidRootPart.CFrame = lplr.Character.HumanoidRootPart.CFrame + Vector3.new(0,100000,0)
				
													game:GetService("RunService").RenderStepped:Connect(function()
														if Clone ~= nil and Clone:FindFirstChild("HumanoidRootPart") then
															Clone.HumanoidRootPart.Position = Vector3.new(lplr.Character.HumanoidRootPart.Position.X, Clone.HumanoidRootPart.Position.Y, lplr.Character.HumanoidRootPart.Position.Z)
														end
													end)
				
													task.wait(0.3)
													lplr.Character.HumanoidRootPart.Velocity = Vector3.new(lplr.Character.HumanoidRootPart.Velocity.X, -1, lplr.Character.HumanoidRootPart.Velocity.Z)
													lplr.Character.HumanoidRootPart.CFrame = Clone.HumanoidRootPart.CFrame
													gameCamera.CameraSubject = lplr.Character:FindFirstChild("Humanoid")
													Clone:Destroy()
													task.wait(0.15)
												end
											end
										end
									end
								end
							end
						end
					end
				end)
			end
        end
    })
end)

	runFunction(function()
		local AutoEmber = {Enabled = false}
		AutoEmber = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
			Name = "4BigGuysExploit",
			HoverText = "Automatically uses the ember ability.",
			Function = function(callback)
				if callback then 
					task.spawn(function()
						repeat 
							local saber = getItem("infernal_saber")
							if killauraNearPlayer and saber then 
								bedwars.ClientHandler:Get("HellBladeRelease"):SendToServer({chargeTime = 0.5, player = lplr, weapon = saber.tool})
							end
							task.wait()
						until not AutoEmber.Enabled
					end)
				end
			end
		})
	end)

warningNotification("APE Booster", "Loaded Succesfully By RayHafz!", 5)
